--------------------------------------------------------
--  DDL for Package CCT_MEDIA_CMD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_MEDIA_CMD_PKG" AUTHID CURRENT_USER AS

    G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CCT_MEDIA_CMD_PKG';
    G_SERVER_DOWN CONSTANT VARCHAR2(30) := 'SERVER_DOWN';
    G_AGENT_NOT_LOGGED_IN CONSTANT VARCHAR2(30) := 'AGENT_NOT_LOGGED_IN';

    -- OCCT_DIAL
    -- Execute the dial telephony command.
    -- The new call will be placed on the first available
    -- line of the teleset. Please make sure there is no
    -- outstanding calls at the agent when executing the dial command.
    --
    -- @param in p_agent_id  the agent id
    -- @param in p_destination the number to dial in dialable format
    PROCEDURE OCCT_DIAL
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_agent_id          IN  NUMBER,
	p_destination	    IN  VARCHAR2,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );


    -- OCCT_INIT_TRANSFER
    -- Initiate the consultation call in preparation for transfering
    -- the call.
    -- Please make sure the call that the agent
    -- want to transfer is the only call that the agent is
    -- currently involved in.
    --
    -- @param in p_agent_id  the agent id
    -- @param in p_destination the number to dial in dialable format
    PROCEDURE OCCT_INIT_TRANSFER
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_agent_id          IN  NUMBER,
	p_destination	    IN  VARCHAR2,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );

    -- OCCT_INIT_CONFERENCE
    -- Initiate the consultation call in preparation for conferencing.
    -- Please make sure the call that the agent
    -- want to conference is the only call that the agent is
    -- currently involved in.
    --
    -- @param in p_agent_id  the agent id
    -- @param in p_destination the number to dial in dialable format
    PROCEDURE OCCT_INIT_CONFERENCE
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_agent_id          IN  NUMBER,
	p_destination	    IN  VARCHAR2,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );

END CCT_MEDIA_CMD_PKG;

 

/
