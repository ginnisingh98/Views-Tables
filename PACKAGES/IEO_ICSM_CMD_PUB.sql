--------------------------------------------------------
--  DDL for Package IEO_ICSM_CMD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_ICSM_CMD_PUB" AUTHID CURRENT_USER AS
/* $Header: ieocmds.pls 115.9 2003/09/03 20:02:56 edwang noship $ */

    G_PKG_NAME  CONSTANT VARCHAR2(30) := 'IEO_ICSM_CMD_PUB';
    G_ICSM_DOWN CONSTANT VARCHAR2(30) := 'ICSM_DOWN';
    G_SERVER_DOWN CONSTANT VARCHAR2(30) := 'SERVER_DOWN';
    G_SERVER_MASK CONSTANT NUMBER := 5000000;

    -- IS_NODE_UP
    -- Test if Node is up
    -- @param in  p_node_id the node id
    -- @param out x_result  Y if node is up , N if not
    FUNCTION GET_NODE_STATUS
    (
        p_node_id           IN  NUMBER
    )
    RETURN NUMBER ;

    FUNCTION GET_SERVER_STATUS
    (
        p_server_id           IN  NUMBER
    )
    RETURN NUMBER ;


    -- EXECUTE_SERVER_CMD
    -- execute a generic command
    -- @param in  p_cmd       the cmd string
    -- @param in  p_server_id the server id
    -- @param out x_result  Y = valid , N = not valid
    PROCEDURE EXECUTE_SERVER_CMD
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_cmd               IN  VARCHAR2,
        p_server_id         IN  NUMBER,
        x_result            OUT NOCOPY VARCHAR2,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );


    -- EXECUTE_ICSM_CMD
    -- execute a generic ICSM command
    -- @param in  p_cmd       the cmd string
    -- @param in  p_node_id   the ICSM node id
    -- @param out x_result    Y = valid , N = not valid
    PROCEDURE EXECUTE_ICSM_CMD
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_cmd               IN  VARCHAR2,
        p_node_id           IN  NUMBER,
        x_result            OUT NOCOPY VARCHAR2,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );

    -- TEST_IP
    -- Test the validity of an IP address on a node
    -- @param in  p_ip_addr the IP address
    -- @param in  p_node_id the node id
    -- @param out x_result  Y = valid , N = not valid
    PROCEDURE TEST_IP
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_ip_addr           IN  VARCHAR2,
        p_node_id           IN  NUMBER,
        x_result            OUT NOCOPY VARCHAR2,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );

    -- START_SERVER
    -- Start a server
    -- @param in  p_server_name the server name to start
    -- @param in  p_node_id the node id
    PROCEDURE START_SERVER
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_server_name       IN  VARCHAR2,
        p_node_id           IN  NUMBER,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2,
	    x_xml_data          OUT NOCOPY VARCHAR2
    );

    -- STOP_SERVER
    -- Stop a server
    -- @param in  p_server_name the server name to stop
    -- @param in  p_node_id the node id
    PROCEDURE STOP_SERVER
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_server_name       IN  VARCHAR2,
        p_node_id           IN  NUMBER,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );

    -- PING_SERVER
    -- Start a server
    -- @param in  p_server_name the server name to start
    -- @param in  p_node_id     the node id
    -- @param out x_status      the status
    PROCEDURE PING_SERVER
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_server_name       IN  VARCHAR2,
        p_node_id           IN  NUMBER,
        x_status            OUT NOCOPY VARCHAR2,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );


    -- SHUTDOWN_ICSM
    -- Shutdown ICSM
    -- @param in  p_node_id the node id
    PROCEDURE SHUTDOWN_ICSM
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_node_id           IN  NUMBER,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );

    -- STOP_ALL_SERVER
    -- Stop all serevr
    -- @param in p_node_id the node id
    PROCEDURE STOP_ALL_SERVER
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_node_id           IN  NUMBER,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );

    -- GET_LOG_FILES
    -- Get log files in XML format
    -- @param in p_node_id      the node id
    -- @param in p_server_name  the server name
    -- @param in p_fetch_count  the max rows need to be returned
    -- @param in p_page_count   the page count
    -- @param out x_xml_data    the xml data
    PROCEDURE GET_LOG_FILES
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_node_id           IN  NUMBER,
        p_server_name       IN  VARCHAR2,
        p_fetch_count       IN  NUMBER,
        p_page_count        IN  NUMBER,
        x_xml_data          OUT NOCOPY VARCHAR2,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );

    -- DELETE_FILE
    -- Delete a file on ICSM server
    -- @param in p_node_id      the node id
    -- @param in p_server_name  the server name
    -- @param in p_file_name    the file name
    PROCEDURE DELETE_FILE
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_node_id           IN  NUMBER,
        p_server_name       IN  VARCHAR2,
        p_file_name         IN  VARCHAR2,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );

END IEO_ICSM_CMD_PUB;

 

/
