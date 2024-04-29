--------------------------------------------------------
--  DDL for Package Body IEO_ICSM_CMD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_ICSM_CMD_PUB" AS
/* $Header: ieocmdb.pls 115.12 2003/09/03 20:03:41 edwang noship $ */

    FUNCTION GET_NODE_STATUS
    (
        p_node_id           IN  NUMBER
    )
    RETURN NUMBER
    IS
        node_status NUMBER;
    BEGIN
        select status into node_status from IEO_NODES where node_id = p_node_id ;
        return node_status ;
    END GET_NODE_STATUS;

    FUNCTION GET_SERVER_STATUS
    (
        p_server_id           IN  NUMBER
    )
    RETURN NUMBER
    IS
        server_status NUMBER;
    BEGIN
        select status into server_status from IEO_SVR_RT_INFO where server_id = p_server_id ;
        return server_status ;
    EXCEPTION
        WHEN no_data_found THEN
            return 1;
    END GET_SERVER_STATUS;


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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'EXECUTE_SERVER_CMD';
        l_api_version       CONSTANT NUMBER         := 1.0;
        l_server_id         NUMBER;
        request_id          NUMBER;
    BEGIN
        -- Standard Start of API savepoint

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

        IF GET_SERVER_STATUS(p_server_id) <> 4 THEN
            x_return_status := G_SERVER_DOWN ;
            RETURN ;
        END IF;

        l_server_id := p_server_id + G_SERVER_MASK ;

        --DBMS_OUTPUT.put_line('enqueuing');

        IEO_ICSM_AQ_PUB.enqueue_request
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            l_server_id,
            p_cmd,
            request_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

        --DBMS_OUTPUT.put_line('dequeuing');

        IEO_ICSM_AQ_PUB.dequeue_response
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            request_id,
            60,
            x_result,
            x_return_status,
            x_msg_count,
            x_msg_data
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
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
    END EXECUTE_SERVER_CMD;

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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'EXECUTE_ICSM_CMD';
        l_api_version       CONSTANT NUMBER         := 1.0;
        request_id          NUMBER;
    BEGIN
        -- Standard Start of API savepoint

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

        IF GET_NODE_STATUS(p_node_id) = 0 THEN
            x_return_status := G_ICSM_DOWN ;
            RETURN ;
        END IF;

        --DBMS_OUTPUT.put_line('enqueuing');

        IEO_ICSM_AQ_PUB.enqueue_request
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_node_id,
            p_cmd,
            request_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

        --DBMS_OUTPUT.put_line('dequeuing');

        IEO_ICSM_AQ_PUB.dequeue_response
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            request_id,
            60,
            x_result,
            x_return_status,
            x_msg_count,
            x_msg_data
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
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
    END EXECUTE_ICSM_CMD;

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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'TEST_IP';
        l_api_version       CONSTANT NUMBER         := 1.0;
        xml_data            VARCHAR2(2048);
        request_id          NUMBER;
    BEGIN
        -- Standard Start of API savepoint

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

        IF GET_NODE_STATUS(p_node_id) = 0 THEN
            x_return_status := G_ICSM_DOWN ;
            RETURN ;
        END IF;

        xml_data := 'TEST_IP ' || p_ip_addr ;

        --DBMS_OUTPUT.put_line('enqueuing');

        IEO_ICSM_AQ_PUB.enqueue_request
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_node_id,
            xml_data,
            request_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

        --DBMS_OUTPUT.put_line('dequeuing');

        IEO_ICSM_AQ_PUB.dequeue_response
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            request_id,
            60,
            x_result,
            x_return_status,
            x_msg_count,
            x_msg_data
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
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
/*        WHEN OTHERS THEN
            ROLLBACK TO ENQUEUE_REQUEST_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF  FND_MSG_PUB.Check_Msg_Level
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
    END TEST_IP;


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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'START_SERVER';
        l_api_version       CONSTANT NUMBER         := 1.0;
        xml_data            VARCHAR2(2048);
        request_id          NUMBER;
    BEGIN
        -- Standard Start of API savepoint

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

        IF GET_NODE_STATUS(p_node_id) = 0 THEN
            x_return_status := G_ICSM_DOWN ;
            RETURN ;
        END IF;

        xml_data := 'START_SERVER ' || p_server_name ;

        IEO_ICSM_AQ_PUB.enqueue_request
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_node_id,
            xml_data,
            request_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

        IEO_ICSM_AQ_PUB.dequeue_response
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            request_id,
            60,
            xml_data,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

        -- End of API body.

        -- get the return data for response
	   x_xml_data := xml_data;

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

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
    END START_SERVER;

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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'STOP_SERVER';
        l_api_version       CONSTANT NUMBER         := 1.0;
        xml_data            VARCHAR2(2048);
        request_id          NUMBER;
    BEGIN
        -- Standard Start of API savepoint

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

        IF GET_NODE_STATUS(p_node_id) = 0 THEN
            x_return_status := G_ICSM_DOWN ;
            RETURN ;
        END IF;

        xml_data := 'STOP_SERVER ' || p_server_name ;

        IEO_ICSM_AQ_PUB.enqueue_request
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_node_id,
            xml_data,
            request_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

        IEO_ICSM_AQ_PUB.dequeue_response
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            request_id,
            60,
            xml_data,
            x_return_status,
            x_msg_count,
            x_msg_data
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
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
    END STOP_SERVER;


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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'PING_SERVER';
        l_api_version       CONSTANT NUMBER         := 1.0;
        xml_data            VARCHAR2(2048);
        request_id          NUMBER;
    BEGIN
        -- Standard Start of API savepoint

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

        IF GET_NODE_STATUS(p_node_id) = 0 THEN
            x_return_status := G_ICSM_DOWN ;
            RETURN ;
        END IF;

        xml_data := 'PING_SERVER ' ||  p_server_name;

        IEO_ICSM_AQ_PUB.enqueue_request
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_node_id,
            xml_data,
            request_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

        IEO_ICSM_AQ_PUB.dequeue_response
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            request_id,
            60,
            x_status,
            x_return_status,
            x_msg_count,
            x_msg_data
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

        WHEN FND_API.G_EXC_ERROR THEN
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
    END PING_SERVER;


    PROCEDURE SHUTDOWN_ICSM
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_node_id           IN  NUMBER,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'SHUTDOWN_ICSM';
        l_api_version       CONSTANT NUMBER         := 1.0;
        xml_data            VARCHAR2(2048);
        request_id          NUMBER;
    BEGIN
        -- Standard Start of API savepoint

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

        IF GET_NODE_STATUS(p_node_id) = 0 THEN
            x_return_status := G_ICSM_DOWN ;
            RETURN ;
        END IF;

        xml_data := 'SHUTDOWN_ICSM';

        IEO_ICSM_AQ_PUB.enqueue_request
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_node_id,
            xml_data,
            request_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

        IEO_ICSM_AQ_PUB.dequeue_response
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            request_id,
            60,
            xml_data,
            x_return_status,
            x_msg_count,
            x_msg_data
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

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
    END SHUTDOWN_ICSM;


    PROCEDURE STOP_ALL_SERVER
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_node_id           IN  NUMBER,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'STOP_ALL_SERVER';
        l_api_version       CONSTANT NUMBER         := 1.0;
        xml_data            VARCHAR2(2048);
        request_id          NUMBER;
    BEGIN
        -- Standard Start of API savepoint

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

        IF GET_NODE_STATUS(p_node_id) = 0 THEN
            x_return_status := G_ICSM_DOWN ;
            RETURN ;
        END IF;

        xml_data := 'STOP_ALL';

        IEO_ICSM_AQ_PUB.enqueue_request
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_node_id,
            xml_data,
            request_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

        IEO_ICSM_AQ_PUB.dequeue_response
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            request_id,
            60,
            xml_data,
            x_return_status,
            x_msg_count,
            x_msg_data
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

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
    END STOP_ALL_SERVER;

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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'GET_LOG_FILES';
        l_api_version       CONSTANT NUMBER         := 1.0;
        xml_data            VARCHAR2(2048);
        request_id          NUMBER;
    BEGIN
        -- Standard Start of API savepoint

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

        IF GET_NODE_STATUS(p_node_id) = 0 THEN
            x_return_status := G_ICSM_DOWN ;
            RETURN ;
        END IF;

        xml_data := 'GET_LOG_FILES ' || p_server_name ||' '|| p_fetch_count ||' '||p_page_count;

        IEO_ICSM_AQ_PUB.enqueue_request
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_node_id,
            xml_data,
            request_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

        IEO_ICSM_AQ_PUB.dequeue_response
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            request_id,
            60,
            x_xml_data,
            x_return_status,
            x_msg_count,
            x_msg_data
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

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
    END GET_LOG_FILES;

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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'DELETE_FILE';
        l_api_version       CONSTANT NUMBER         := 1.0;
        xml_data            VARCHAR2(2048);
        request_id          NUMBER;
    BEGIN
        -- Standard Start of API savepoint

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

        IF GET_NODE_STATUS(p_node_id) = 0 THEN
            x_return_status := G_ICSM_DOWN ;
            RETURN ;
        END IF;

        xml_data := 'DELETE_FILE ' || p_server_name || ' ' || p_file_name;

        IEO_ICSM_AQ_PUB.enqueue_request
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            p_node_id,
            xml_data,
            request_id,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

        IEO_ICSM_AQ_PUB.dequeue_response
        (
            p_api_version,
            p_init_msg_list,
            p_commit,
            request_id,
            60,
            xml_data,
            x_return_status,
            x_msg_count,
            x_msg_data
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

        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
            (
                p_count => x_msg_count,
                p_data  => x_msg_data
            );
    END DELETE_FILE;



END IEO_ICSM_CMD_PUB;

/
