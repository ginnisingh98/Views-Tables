--------------------------------------------------------
--  DDL for Package Body IEO_ICSM_AQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_ICSM_AQ_PUB" AS
/* $Header: ieoaqpb.pls 115.6 2002/12/20 23:10:46 edwang noship $ */

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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'ENQUEUE_REQUEST';
        l_api_version       CONSTANT NUMBER         := 1.0;
        enqueue_options     dbms_aq.enqueue_options_t;
        message_properties  dbms_aq.message_properties_t;
        message_handle      RAW(16);
        message             SYSTEM.ieo_icsm_msg_type;
        request_id          NUMBER ;
        xml_data_null       EXCEPTION;
    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT    ENQUEUE_REQUEST_PUB;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call
        (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME
        )
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- API body

        IF p_xml_data IS NULL then
            raise xml_data_null;
        END IF;

        -- select request id from sequence
        select ieo_icsm_aq_s1.nextval into request_id from dual ;

        message_properties.correlation := p_node_id;
        message_properties.expiration := 600;
        enqueue_options.visibility := DBMS_AQ.IMMEDIATE;
        message := SYSTEM.ieo_icsm_msg_type(p_node_id,request_id,p_xml_data);

        dbms_aq.enqueue
        (
            queue_name          => IEO_QUEUE.queue_name_1,
            enqueue_options     => enqueue_options,
            message_properties  => message_properties,
            payload             => message,
            msgid               => message_handle
        );

        x_request_id := request_id ;
        -- End of API body.

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
        (
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    EXCEPTION

        WHEN xml_data_null THEN
            ROLLBACK TO ENQUEUE_REQUEST_PUB;
            FND_MESSAGE.SET_NAME('IEO','IEO_AQ_XML_DATA_NULL');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO ENQUEUE_REQUEST_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO ENQUEUE_REQUEST_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
/*        WHEN OTHERS THEN
            ROLLBACK TO ENQUEUE_REQUEST_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              IF     FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (
                    G_PKG_NAME,
                    l_api_name
                );
            END IF;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );*/
    END ENQUEUE_REQUEST;

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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'ENQUEUE_RESPONSE';
        l_api_version       CONSTANT NUMBER         := 1.0;
        enqueue_options     dbms_aq.enqueue_options_t;
        message_properties  dbms_aq.message_properties_t;
        message_handle      RAW(16);
        message             SYSTEM.ieo_icsm_msg_type;
        xml_data_null      EXCEPTION;
    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT    ENQUEUE_RESPONSE_PUB;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call
        (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME
        )
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- API body

        IF p_xml_data IS NULL then
            raise xml_data_null;
        END IF;

        message_properties.correlation := p_request_id;
        message_properties.expiration := 600;
        enqueue_options.visibility := DBMS_AQ.IMMEDIATE;
        message := SYSTEM.ieo_icsm_msg_type(p_node_id,p_request_id,p_xml_data);

        dbms_aq.enqueue
        (
            queue_name          => IEO_QUEUE.queue_name_2,
            enqueue_options     => enqueue_options,
            message_properties  => message_properties,
            payload             => message,
            msgid               => message_handle
        );

        -- End of API body.

        -- Standard check of p_commit.
        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get
        (
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    EXCEPTION

        WHEN xml_data_null THEN
            ROLLBACK TO ENQUEUE_RESPONSE_PUB;
            FND_MESSAGE.SET_NAME('IEO','IEO_AQ_XML_DATA_NULL');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO ENQUEUE_RESPONSE_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO ENQUEUE_RESPONSE_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
/*        WHEN OTHERS THEN
            ROLLBACK TO ENQUEUE_RESPONSE_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              IF     FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (
                    G_PKG_NAME,
                    l_api_name
                );
            END IF;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );*/
    END ENQUEUE_RESPONSE;

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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'DEQUEUE_REQUEST';
        l_api_version       CONSTANT NUMBER         := 1.0;
        dequeue_options     dbms_aq.dequeue_options_t;
        message_properties  dbms_aq.message_properties_t;
        message_handle      RAW(16);
        message             SYSTEM.ieo_icsm_msg_type;
        no_messages         exception;
        pragma exception_init  (no_messages, -25228);
    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT    DEQUEUE_REQUEST_PUB;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call
        (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME
        )
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- API body

        dequeue_options.correlation := p_node_id;
        dequeue_options.wait := p_wait ;
        dequeue_options.visibility := DBMS_AQ.IMMEDIATE;
        dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE ;

    	dbms_aq.dequeue
    	(
		    queue_name          => IEO_QUEUE.queue_name_1,
		    dequeue_options     => dequeue_options,
		    message_properties  => message_properties,
		    payload             => message,
		    msgid               => message_handle
		);

        x_xml_data := message.xml_data ;
        x_request_id := message.request_id ;

    EXCEPTION
        WHEN no_messages THEN
            x_return_status := G_TIMEOUT ;
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO DEQUEUE_REQUEST_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO DEQUEUE_REQUEST_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
/*        WHEN OTHERS THEN
            ROLLBACK TO DEQUEUE_REQUEST_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              IF     FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (
                    G_PKG_NAME,
                    l_api_name
                );
            END IF;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );*/
    END DEQUEUE_REQUEST;


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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'DEQUEUE_RESPONSE';
        l_api_version       CONSTANT NUMBER         := 1.0;
        dequeue_options     dbms_aq.dequeue_options_t;
        message_properties  dbms_aq.message_properties_t;
        message_handle      RAW(16);
        message             SYSTEM.ieo_icsm_msg_type;
        no_messages         exception;
        pragma exception_init  (no_messages, -25228);
    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT    DEQUEUE_RESPONSE_PUB;

        -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call
        (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME
        )
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.To_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- API body

        --DBMS_OUTPUT.put_line('before dequeuing in dequeue response');

        dequeue_options.correlation := p_request_id;
        dequeue_options.wait := p_wait ;
        dequeue_options.visibility := DBMS_AQ.IMMEDIATE;
        dequeue_options.navigation := DBMS_AQ.FIRST_MESSAGE ;

    	dbms_aq.dequeue
    	(
		    queue_name          => IEO_QUEUE.queue_name_2,
		    dequeue_options     => dequeue_options,
		    message_properties  => message_properties,
		    payload             => message,
		    msgid               => message_handle
		);

        --DBMS_OUTPUT.put_line('after dequeuing in dequeue response');

        x_xml_data := message.xml_data ;
    EXCEPTION
        WHEN no_messages THEN
            --DBMS_OUTPUT.put_line('timeout dequeuing response');
            x_return_status := G_TIMEOUT;
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO DEQUEUE_RESPONSE_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO DEQUEUE_RESPONSE_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
/*        WHEN OTHERS THEN
            ROLLBACK TO DEQUEUE_RESPONSE_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              IF     FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                (
                    G_PKG_NAME,
                    l_api_name
                );
            END IF;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );*/
    END DEQUEUE_RESPONSE;

END IEO_ICSM_AQ_PUB;

/
