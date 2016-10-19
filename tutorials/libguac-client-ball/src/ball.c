#include "ball.h"

#include <guacamole/client.h>
#include <guacamole/layer.h>
#include <guacamole/protocol.h>
#include <guacamole/socket.h>
#include <guacamole/timestamp.h>
#include <guacamole/user.h>

#include <pthread.h>
#include <stdlib.h>

/* Client plugin arguments (empty) */
const char* TUTORIAL_ARGS[] = { NULL };

void* ball_render_thread(void* arg) {

    /* Get data */
    guac_client* client = (guac_client*) arg;
    ball_client_data* data = (ball_client_data*) client->data;

    /* Init time of last frame to current time */
    guac_timestamp last_frame = guac_timestamp_current();

    /* Update ball position as long as client is running */
    while (client->state == GUAC_CLIENT_RUNNING) {

        /* Default to 30ms frames */
        int frame_duration = 30;

        /* Lengthen frame duration if client is lagging */
        int processing_lag = guac_client_get_processing_lag(client);
        if (processing_lag > frame_duration)
            frame_duration = processing_lag;

        /* Sleep for duration of frame, then get timestamp */
        usleep(frame_duration * 1000);
        guac_timestamp current = guac_timestamp_current();

        /* Calculate change in time */
        int delta_t = current - last_frame;

        /* Update position */
        data->ball_x += data->ball_velocity_x * delta_t / 1000;
        data->ball_y += data->ball_velocity_y * delta_t / 1000;

        /* Bounce if necessary */
        if (data->ball_x < 0) {
            data->ball_x = -data->ball_x;
            data->ball_velocity_x = -data->ball_velocity_x;
        }
        else if (data->ball_x >= 1024 - 128) {
            data->ball_x = (2 * (1024 - 128)) - data->ball_x;
            data->ball_velocity_x = -data->ball_velocity_x;
        }

        if (data->ball_y < 0) {
            data->ball_y = -data->ball_y;
            data->ball_velocity_y = -data->ball_velocity_y;
        }
        else if (data->ball_y >= 768 - 128) {
            data->ball_y = (2 * (768 - 128)) - data->ball_y;
            data->ball_velocity_y = -data->ball_velocity_y;
        }

        guac_protocol_send_move(client->socket, data->ball,
                GUAC_DEFAULT_LAYER, data->ball_x, data->ball_y, 0);

        /* End frame and flush socket */
        guac_client_end_frame(client);
        guac_socket_flush(client->socket);

        /* Update timestamp */
        last_frame = current;

    }

    return NULL;

}

int ball_join_handler(guac_user* user, int argc, char** argv) {

    /* Get client associated with user */
    guac_client* client = user->client;

    /* Get ball layer from client data */
    ball_client_data* data = (ball_client_data*) client->data;
    guac_layer* ball = data->ball;

    /* Get user-specific socket */
    guac_socket* socket = user->socket;

    /* Send the display size */
    guac_protocol_send_size(socket, GUAC_DEFAULT_LAYER, 1024, 768);

    /* Create background tile */
    guac_layer* texture = guac_client_alloc_buffer(client);

    guac_protocol_send_rect(socket, texture, 0, 0, 64, 64);
    guac_protocol_send_cfill(socket, GUAC_COMP_OVER, texture,
            0x88, 0x88, 0x88, 0xFF);

    guac_protocol_send_rect(socket, texture, 0, 0, 32, 32);
    guac_protocol_send_cfill(socket, GUAC_COMP_OVER, texture,
            0xDD, 0xDD, 0xDD, 0xFF);

    guac_protocol_send_rect(socket, texture, 32, 32, 32, 32);
    guac_protocol_send_cfill(socket, GUAC_COMP_OVER, texture,
            0xDD, 0xDD, 0xDD, 0xFF);

    /* Prepare a curve which covers the entire layer */
    guac_protocol_send_rect(socket, GUAC_DEFAULT_LAYER,
            0, 0, 1024, 768);

    /* Fill curve with texture */
    guac_protocol_send_lfill(socket,
            GUAC_COMP_OVER, GUAC_DEFAULT_LAYER,
            texture);

    /* Set up ball layer */
    guac_protocol_send_size(socket, ball, 128, 128);

    /* Prepare a circular curve */
    guac_protocol_send_arc(socket, data->ball,
            64, 64, 62, 0, 6.28, 0);

    guac_protocol_send_close(socket, data->ball);

    /* Draw a 4-pixel black border */
    guac_protocol_send_cstroke(socket,
            GUAC_COMP_OVER, data->ball,
            GUAC_LINE_CAP_ROUND, GUAC_LINE_JOIN_ROUND, 4,
            0x00, 0x00, 0x00, 0xFF);

    /* Fill the circle with color */
    guac_protocol_send_cfill(socket,
            GUAC_COMP_OVER, data->ball,
            0x00, 0x80, 0x80, 0x80);

    /* Free texture (no longer needed) */
    guac_client_free_buffer(client, texture);

    /* Mark end-of-frame */
    guac_protocol_send_sync(socket, client->last_sent_timestamp);

    /* Flush buffer */
    guac_socket_flush(socket);

    /* User successfully initialized */
    return 0;

}

int ball_free_handler(guac_client* client) {

    ball_client_data* data = (ball_client_data*) client->data;

    /* Wait for render thread to terminate */
    pthread_join(data->render_thread, NULL);

    /* Free client-level ball layer */
    guac_client_free_layer(client, data->ball);

    /* Free client-specific data */
    free(data);

    /* Data successfully freed */
    return 0;

}

int guac_client_init(guac_client* client) {

    /* Allocate storage for client-specific data */
    ball_client_data* data = malloc(sizeof(ball_client_data));

    /* Set up client data and handlers */
    client->data = data;

    /* Allocate layer at the client level */
    data->ball = guac_client_alloc_layer(client);

    /* Start ball at upper left */
    data->ball_x = 0;
    data->ball_y = 0;

    /* Move at a reasonable pace to the lower right */
    data->ball_velocity_x = 200; /* pixels per second */
    data->ball_velocity_y = 200; /* pixels per second */

    /* Start render thread */
    pthread_create(&data->render_thread, NULL, ball_render_thread, client);

    /* This example does not implement any arguments */
    client->args = TUTORIAL_ARGS;

    /* Client-level handlers */
    client->join_handler = ball_join_handler;
    client->free_handler = ball_free_handler;

    return 0;

}
