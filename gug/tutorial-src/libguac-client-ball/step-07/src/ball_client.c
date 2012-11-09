
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <guacamole/client.h>
#include <guacamole/protocol.h>
#include <guacamole/timestamp.h>

#include "ball_client.h"

/* Client plugin arguments */
const char* GUAC_CLIENT_ARGS[] = { NULL };

int guac_client_init(guac_client* client, int argc, char** argv) {

    ball_client_data* data = malloc(sizeof(ball_client_data));
    guac_layer* texture;

    /* Send the name of the connection */
    guac_protocol_send_name(client->socket, "Bouncing Ball");

    /* Set size in data */
    data->width = client->info.optimal_width;
    data->height = client->info.optimal_height;

    /* Send the display size */
    guac_protocol_send_size(client->socket, GUAC_DEFAULT_LAYER,
            data->width, data->height);

    /* Create background tile */
    texture = guac_client_alloc_buffer(client);

    guac_protocol_send_rect(client->socket, texture, 0, 0, 64, 64);
    guac_protocol_send_cfill(client->socket, GUAC_COMP_OVER, texture,
            0x88, 0x88, 0x88, 0xFF);

    guac_protocol_send_rect(client->socket, texture, 0, 0, 32, 32);
    guac_protocol_send_cfill(client->socket, GUAC_COMP_OVER, texture,
            0xDD, 0xDD, 0xDD, 0xFF);

    guac_protocol_send_rect(client->socket, texture, 32, 32, 32, 32);
    guac_protocol_send_cfill(client->socket, GUAC_COMP_OVER, texture,
            0xDD, 0xDD, 0xDD, 0xFF);

    /* Fill with solid color */
    guac_protocol_send_rect(client->socket, GUAC_DEFAULT_LAYER,
            0, 0, data->width, data->height);

    guac_protocol_send_lfill(client->socket,
            GUAC_COMP_OVER, GUAC_DEFAULT_LAYER,
            texture);

    /* Set up client data and handlers */
    client->data = data;
    client->handle_messages = ball_client_handle_messages;
    client->mouse_handler = ball_client_mouse_handler;

    /* Set up our ball layer */
    data->ball = guac_client_alloc_layer(client);

    /* Start ball at upper left */
    data->ball_x = 0;
    data->ball_y = 0;

    /* Move at a reasonable pace to the lower right */
    data->moving = 1;
    data->ball_velocity_x = 200; /* pixels per second */
    data->ball_velocity_y = 200;   /* pixels per second */
    data->last_update = guac_timestamp_current();

    guac_protocol_send_size(client->socket, data->ball, 128, 128);

    /* Fill with solid color */
    guac_protocol_send_arc(client->socket, data->ball,
            64, 64, 62, 0, 6.28, 0);

    guac_protocol_send_close(client->socket, data->ball);

    guac_protocol_send_cstroke(client->socket,
            GUAC_COMP_OVER, data->ball,
            GUAC_LINE_CAP_ROUND, GUAC_LINE_JOIN_ROUND, 4,
            0x00, 0x00, 0x00, 0xFF);

    guac_protocol_send_cfill(client->socket,
            GUAC_COMP_OVER, data->ball,
            0x00, 0x80, 0x80, 0x80);

    /* Flush buffer */
    guac_socket_flush(client->socket);

    /* Done */
    return 0;

}

int ball_client_handle_messages(guac_client* client) {

    /* Get data */
    ball_client_data* data = (ball_client_data*) client->data;

    guac_timestamp current;
    int delta_t;

    /* Sleep for a bit, then get timestamp */
    usleep(30000);
    current = guac_timestamp_current();

    if (data->moving) {

        /* Calculate change in time */
        delta_t = current - data->last_update;

        /* Update position */
        data->ball_x += data->ball_velocity_x * delta_t / 1000;
        data->ball_y += data->ball_velocity_y * delta_t / 1000;

        /* Bounce if necessary */
        if (data->ball_x < 0) {
            data->ball_x = -data->ball_x;
            data->ball_velocity_x = -data->ball_velocity_x;
        }
        else if (data->ball_x >= data->width - 128) {
            data->ball_x = (2*(data->width - 128)) - data->ball_x;
            data->ball_velocity_x = -data->ball_velocity_x;
        }

        if (data->ball_y < 0) {
            data->ball_y = -data->ball_y;
            data->ball_velocity_y = -data->ball_velocity_y;
        }
        else if (data->ball_y >= (data->height - 128)) {
            data->ball_y = (2*(data->height - 128)) - data->ball_y;
            data->ball_velocity_y = -data->ball_velocity_y;
        }

        guac_protocol_send_move(client->socket, data->ball,
                GUAC_DEFAULT_LAYER, data->ball_x, data->ball_y, 0);

    }

    /* Update timestamp */
    data->last_update = current;

    return 0;

}

int ball_client_mouse_handler(guac_client* client, int x, int y, int mask) {

    ball_client_data* data = (ball_client_data*) client->data;

    if (mask != 0) {

        data->moving = 0;

        data->ball_x = x - 64;
        data->ball_y = y - 64;

        guac_protocol_send_move(client->socket, data->ball,
                GUAC_DEFAULT_LAYER, data->ball_x, data->ball_y, 0);

    }
    else {
        data->moving = 1;
    }

    return 0;

}

