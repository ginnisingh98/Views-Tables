--------------------------------------------------------
--  DDL for Package IEO_ICSM_AQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_ICSM_AQ_PUB" AUTHID CURRENT_USER AS
/* $Header: ieoaqps.pls 115.6 2002/12/20 23:10:42 edwang noship $ */

    G_PKG_NAME  CONSTANT VARCHAR2(30) := 'IEO_ICSM_AQ_PUB';
    G_TIMEOUT   CONSTANT VARCHAR2(8) := 'TIMEOUT' ;

    --
    --	ENQUEUE_REQUEST
    --  Enqueue request to ICSM
    --  @param in   p_node_id    the node_id of ICSM
    --  @param in   p_xml_data   the xml data string
    --  @param out  x_request_id the request id
    --
    PROCEDURE ENQUEUE_REQUEST
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_node_id           IN  VARCHAR2,
        p_xml_data          IN  VARCHAR2,

        x_request_id        OUT NOCOPY NUMBER,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );

    --
    --	ENQUEUE_RESPONSE
    --  Enqueue response, used by ICSM
    --  @param in   p_request_id the request id
    --  @param in   p_xml_data   the xml data string
    --
    PROCEDURE ENQUEUE_RESPONSE
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_node_id           IN  NUMBER,
        p_request_id        IN  NUMBER,
        p_xml_data          IN  VARCHAR2,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );

    --
    --	DEQUEUE_REQUEST
    --  dequeue request, used by ICSM
    --  @param in   p_node_id    the node id
    --  @param out  p_xml_data   the xml data string
    --
    PROCEDURE DEQUEUE_REQUEST
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_node_id           IN  NUMBER,
        p_wait              IN  NUMBER,

        x_xml_data          OUT NOCOPY VARCHAR2,
        x_request_id        OUT NOCOPY NUMBER,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );

    --
    --	DEQUEUE_RESPONSE
    --  dequeue response, used by client
    --  @param in   p_request_id the request id
    --  @param in   p_wait       timeout
    --  @param out  x_xml_data   the xml data string
    --
    PROCEDURE DEQUEUE_RESPONSE
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_request_id        IN  NUMBER,
        p_wait              IN  NUMBER,

        x_xml_data          OUT NOCOPY VARCHAR2,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    );


END IEO_ICSM_AQ_PUB;

 

/
