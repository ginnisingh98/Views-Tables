--------------------------------------------------------
--  DDL for Package Body CCT_MEDIA_CMD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_MEDIA_CMD_PKG" AS
    PROCEDURE EXECUTE_SERVER_CMD_BY_AGENTID
    (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2 Default FND_API.G_FALSE,
        p_commit            IN  VARCHAR2 Default FND_API.G_FALSE,

        p_cmd               IN  VARCHAR2,
        p_agent_id          IN  NUMBER,
        x_result            OUT NOCOPY VARCHAR2,

        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'EXECUTE_SERVER_CMD_BY_AGENTID';
        l_api_version       CONSTANT NUMBER         := 1.0;
        l_server_id         NUMBER;

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
	-- Query server id from agent id
        select mcm_id into l_server_id from CCT_AGENT_RT_STATS where agent_id = p_agent_id;

	-- call EXECUTE_SERVER_CMD with l_server_id
	IEO_ICSM_CMD_PUB.EXECUTE_SERVER_CMD(p_api_version,
                           p_init_msg_list,
                           p_commit,
                           p_cmd,
                           l_server_id,
                           x_result,
                           x_return_status,
                           x_msg_count,
                           x_msg_data);

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
        WHEN no_data_found THEN
	    x_msg_data := G_AGENT_NOT_LOGGED_IN;
            x_return_status := FND_API.G_RET_STS_ERROR;
	    x_msg_count := 1;

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
    END EXECUTE_SERVER_CMD_BY_AGENTID;


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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'OCCT_DIAL';
        l_api_version       CONSTANT NUMBER         := 1.0;
        -- String that will store all the parameters
	l_cmd               VARCHAR2(256)            := 'EXECUTE_ONEWAY mediaCommand occtDial ' || p_agent_id || ' ' || p_destination;

        -- Don't care about the result for now
        l_result            VARCHAR2(256);

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

        EXECUTE_SERVER_CMD_BY_AGENTID(
              p_api_version,
              p_init_msg_list,
              p_commit,
              l_cmd,
              p_agent_id,
              l_result,
              x_return_status,
              x_msg_count,
              x_msg_data);

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
    END OCCT_DIAL;

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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'OCCT_TRANSFER';
        l_api_version       CONSTANT NUMBER         := 1.0;
        -- String that will store all the parameters
	l_cmd               VARCHAR2(256)            := 'EXECUTE_ONEWAY mediaCommand occtInitTransfer ' || p_agent_id || ' ' || p_destination;

        -- Don't care about the result for now
        l_result            VARCHAR2(256);

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

        EXECUTE_SERVER_CMD_BY_AGENTID(
              p_api_version,
              p_init_msg_list,
              p_commit,
              l_cmd,
              p_agent_id,
              l_result,
              x_return_status,
              x_msg_count,
              x_msg_data);

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
    END OCCT_INIT_TRANSFER;


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
    )
    IS
        l_api_name          CONSTANT VARCHAR2(30)   := 'OCCT_CONFERENCE';
        l_api_version       CONSTANT NUMBER         := 1.0;
        -- String that will store all the parameters
	l_cmd               VARCHAR2(256)            := 'EXECUTE_ONEWAY mediaCommand occtInitConference ' || p_agent_id || ' ' || p_destination;

        -- Don't care about the result for now
        l_result            VARCHAR2(256);

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

        EXECUTE_SERVER_CMD_BY_AGENTID(
              p_api_version,
              p_init_msg_list,
              p_commit,
              l_cmd,
              p_agent_id,
              l_result,
              x_return_status,
              x_msg_count,
              x_msg_data);

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
    END OCCT_INIT_CONFERENCE;

END CCT_MEDIA_CMD_PKG;

/
