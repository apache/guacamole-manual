#ifndef BALL_CLIENT_H
#define BALL_CLIENT_H

#include <guacamole/layer.h>

#include <pthread.h>

typedef struct ball_client_data {

    guac_layer* ball;

    int ball_x;
    int ball_y;

    int ball_velocity_x;
    int ball_velocity_y;

    pthread_t render_thread;

} ball_client_data;

#endif
