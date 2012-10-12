
#include <stdlib.h>
#include <guacamole/client.h>
#include <guacamole/protocol.h>

/* Client plugin arguments */
const char* GUAC_CLIENT_ARGS[] = { NULL };

int guac_client_init(guac_client* client, int argc, char** argv) {

    /* Send the name of the connection */
    guac_protocol_send_name(client->socket, "Bouncing Ball");

    /* Send the display size */
    guac_protocol_send_size(client->socket, GUAC_DEFAULT_LAYER, 1024, 768);

    /* Fill with solid color */
    guac_protocol_send_rect(client->socket, GUAC_DEFAULT_LAYER,
            0, 0, 1024, 768);

    guac_protocol_send_cfill(client->socket,
            GUAC_COMP_OVER, GUAC_DEFAULT_LAYER,
            0x80, 0x80, 0x80, 0xFF);

    /* Flush buffer */
    guac_socket_flush(client->socket);

    /* Done */
    return 0;

}

