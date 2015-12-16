package org.glyptodon.guacamole.auth;

import org.glyptodon.guacamole.properties.StringGuacamoleProperty;

public class TutorialGuacamoleProperties {

    /**
     * This class should not be instantiated.
     */
    private TutorialGuacamoleProperties() {}

    /**
     * The only user to allow.
     */
    public static final StringGuacamoleProperty TUTORIAL_USER = 
        new StringGuacamoleProperty() {

        @Override
        public String getName() { return "tutorial-user"; }

    };

    /**
     * The password required for the specified user.
     */
    public static final StringGuacamoleProperty TUTORIAL_PASSWORD = 
        new StringGuacamoleProperty() {

        @Override
        public String getName() { return "tutorial-password"; }

    };


    /**
     * The protocol to use when connecting.
     */
    public static final StringGuacamoleProperty TUTORIAL_PROTOCOL = 
        new StringGuacamoleProperty() {

        @Override
        public String getName() { return "tutorial-protocol"; }

    };


    /**
     * All parameters associated with the connection, as a comma-delimited
     * list of name="value" 
     */
    public static final StringGuacamoleProperty TUTORIAL_PARAMETERS = 
        new StringGuacamoleProperty() {

        @Override
        public String getName() { return "tutorial-parameters"; }

    };

}
