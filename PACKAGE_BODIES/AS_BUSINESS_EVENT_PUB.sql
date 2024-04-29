--------------------------------------------------------
--  DDL for Package Body AS_BUSINESS_EVENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_BUSINESS_EVENT_PUB" as
/* $Header: asxpbevb.pls 120.1 2005/06/14 01:30:44 appldev  $ */
--
-- NAME
-- AS_BUSINESS_EVENT_PUB
--
-- HISTORY
--   9/24/03            SUMAHALI        CREATED
--
--

G_PKG_NAME      CONSTANT VARCHAR2(30):='AS_BUSINESS_EVENT_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(12):='asxpbevb.pls';

-- Start of Comments
--
--      API name        : Before_Oppty_Update
--      Type            : Public
--      Function        : When called before Opportunity header update, takes
--                        snapshot of Opp header and returns an event key in
--                        x_event_key which is to be passed, when raising a
--                        business event after the update is over using the
--                        Update_oppty_post_event procedure. If lead_id is
--                        NULL then a new Event key is returned without taking
--                        a snapshot. This can be used before creating a new
--                        opportunity since no lead_id is available.
--
--      Pre-reqs        : Existing lead_id or NULL value.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_lead_id               IN NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--          x_event_key             OUT NOCOPY VARCHAR2
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments


PROCEDURE Before_Oppty_Update(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                   IN NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_event_key                 OUT NOCOPY VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30) := 'Before_Oppty_Update';
l_api_version_number    CONSTANT NUMBER       := 2.0;
l_debug                 BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpb.Before_Oppty_Update';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT BEFORE_OPPTY_UPDATE_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'start');
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: Calling AS_BUSINESS_EVENT_PVT.Before_Oppty_Update');
    END IF;

    AS_BUSINESS_EVENT_PVT.Before_Oppty_Update
    (
        p_lead_id       => p_lead_id,
        x_event_key     => x_event_key
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- End of API body.
    --

    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;


    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'end');

        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                        || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;


    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

End Before_Oppty_Update;

-- Start of Comments
--
--      API name        : Update_oppty_post_event
--      Type            : Public
--      Function        : Raises a business event for Opportunity header update.
--                        The Procedure Before_Oppty_Update should have been
--                        called and the same event key must be passed.
--
--      Pre-reqs        : Existing lead_id and x_event_key from
--                        Before_Oppty_Update call.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_event_key             IN  VARCHAR2
--          p_lead_id               IN  NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments

PROCEDURE Update_oppty_post_event(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                   IN NUMBER,
    p_event_key                 IN VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30) := 'Update_oppty_post_event';
l_api_version_number    CONSTANT NUMBER       := 2.0;
l_debug                 BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpb.Update_oppty_post_event';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT UPDATE_OPPTY_POST_EVENT_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'start');
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: Calling AS_BUSINESS_EVENT_PVT.Update_oppty_post_event');
    END IF;

    AS_BUSINESS_EVENT_PVT.Update_oppty_post_event
    (
        p_lead_id       => p_lead_id,
        p_event_key     => p_event_key
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- End of API body.
    --

    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;


    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'end');

        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                        || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;


    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

End Update_oppty_post_event;

-- Start of Comments
--
--      API name        : Before_Opp_Lines_Update
--      Type            : Public
--      Function        : When called before Opportunity line update, takes
--                        snapshot of Opp lines and returns an event key in
--                        x_event_key which is to be passed, when raising a
--                        business event after the update is over using the
--                        Upd_Opp_Lines_post_event procedure. If lead_id is
--                        NULL then a new Event key is returned without taking
--                        a snapshot. This can be used before creating a new
--                        opportunity since no lead_id is available.
--
--      Pre-reqs        : Existing lead_id or NULL value.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_lead_id               IN NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--          x_event_key             OUT NOCOPY VARCHAR2
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments


PROCEDURE Before_Opp_Lines_Update(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                   IN NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_event_key                 OUT NOCOPY VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30) := 'Before_Opp_Lines_Update';
l_api_version_number    CONSTANT NUMBER       := 2.0;
l_debug                 BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpb.Before_Opp_Lines_Update';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT BEFORE_OPP_LINES_UPDATE_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'start');
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: Calling AS_BUSINESS_EVENT_PVT.Before_Opp_Lines_Update');
    END IF;

    AS_BUSINESS_EVENT_PVT.Before_Opp_Lines_Update
    (
        p_lead_id       => p_lead_id,
        x_event_key     => x_event_key
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- End of API body.
    --

    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;


    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'end');

        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                        || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;


    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

End Before_Opp_Lines_Update;

-- Start of Comments
--
--      API name        : Upd_Opp_Lines_post_event
--      Type            : Public
--      Function        : Raises a business event for Opportunity line update.
--                        The Procedure Before_Opp_Lines_Update should have been
--                        called and the same event key must be passed.
--
--      Pre-reqs        : Existing lead_id and x_event_key from
--                        Before_Opp_Lines_Update call.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_event_key             IN  VARCHAR2
--          p_lead_id               IN  NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments

PROCEDURE Upd_Opp_Lines_post_event(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                   IN NUMBER,
    p_event_key                 IN VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30) := 'Upd_Opp_Lines_post_event';
l_api_version_number    CONSTANT NUMBER       := 2.0;
l_debug                 BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpb.Upd_Opp_Lines_post_event';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT UPD_OPP_LINES_POST_EVENT_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'start');
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: Calling AS_BUSINESS_EVENT_PVT.Upd_Opp_Lines_post_event');
    END IF;

    AS_BUSINESS_EVENT_PVT.Upd_Opp_Lines_post_event
    (
        p_lead_id       => p_lead_id,
        p_event_key     => p_event_key
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- End of API body.
    --

    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;


    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'end');

        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                        || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;


    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

End Upd_Opp_Lines_post_event;

-- Start of Comments
--
--      API name        : Before_Opp_STeam_Update
--      Type            : Public
--      Function        : When called before Opportunity sales team update, takes
--                        snapshot of Opp sales team and returns an event key in
--                        x_event_key which is to be passed, when raising a
--                        business event after the update is over using the
--                        Upd_Opp_STeam_post_event procedure. If lead_id is
--                        NULL then a new Event key is returned without taking
--                        a snapshot. This can be used before creating a new
--                        opportunity since no lead_id is available.
--
--      Pre-reqs        : Existing lead_id or NULL value.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_lead_id               IN NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--          x_event_key             OUT NOCOPY VARCHAR2
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments


PROCEDURE Before_Opp_STeam_Update(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                   IN NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_event_key                 OUT NOCOPY VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30) := 'Before_Opp_STeam_Update';
l_api_version_number    CONSTANT NUMBER       := 2.0;
l_debug                 BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpb.Before_Opp_STeam_Update';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT BEFORE_OPP_STEAM_UPDATE_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'start');
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: Calling AS_BUSINESS_EVENT_PVT.Before_Opp_STeam_Update');
    END IF;

    AS_BUSINESS_EVENT_PVT.Before_Opp_STeam_Update
    (
        p_lead_id       => p_lead_id,
        x_event_key     => x_event_key
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- End of API body.
    --

    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;


    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'end');

        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                        || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;


    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

End Before_Opp_STeam_Update;

-- Start of Comments
--
--      API name        : Upd_Opp_STeam_post_event
--      Type            : Public
--      Function        : Raises a business event for Opportunity sales team
--                        update. The Procedure Before_Opp_STeam_Update should
--                        have been called and the same event key must be passed.
--
--      Pre-reqs        : Existing lead_id and x_event_key from
--                        Before_Opp_STeam_Update call.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_event_key             IN  VARCHAR2
--          p_lead_id               IN  NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments

PROCEDURE Upd_Opp_STeam_post_event(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                   IN NUMBER,
    p_event_key                 IN VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30) := 'Upd_Opp_STeam_post_event';
l_api_version_number    CONSTANT NUMBER       := 2.0;
l_debug                 BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpb.Upd_Opp_STeam_post_event';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT UPD_OPP_STEAM_POST_EVENT_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'start');
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: Calling AS_BUSINESS_EVENT_PVT.Upd_Opp_STeam_post_event');
    END IF;

    AS_BUSINESS_EVENT_PVT.Upd_Opp_STeam_post_event
    (
        p_lead_id       => p_lead_id,
        p_event_key     => p_event_key
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- End of API body.
    --

    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;


    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'end');

        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                        || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;


    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

End Upd_Opp_STeam_post_event;

-- Start of Comments
--
--      API name        : Before_Cust_STeam_Update
--      Type            : Public
--      Function        : When called before Customer sales team update, takes
--                        snapshot of Cust sales team and returns an event key in
--                        x_event_key which is to be passed, when raising a
--                        business event after the update is over using the
--                        Upd_Cust_STeam_post_event procedure. If cust_id is
--                        NULL then a new Event key is returned without taking
--                        a snapshot. This can be used before creating a new
--                        customer since no cust_id is available.
--
--      Pre-reqs        : Existing cust_id or NULL value.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_cust_id               IN NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--          x_event_key             OUT NOCOPY VARCHAR2
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments


PROCEDURE Before_Cust_STeam_Update(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_cust_id                   IN NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_event_key                 OUT NOCOPY VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30) := 'Before_Cust_STeam_Update';
l_api_version_number    CONSTANT NUMBER       := 2.0;
l_debug                 BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpb.Before_Cust_STeam_Update';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT BEFORE_CUST_STEAM_UPDATE_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'start');
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: Calling AS_BUSINESS_EVENT_PVT.Before_Cust_STeam_Update');
    END IF;

    AS_BUSINESS_EVENT_PVT.Before_Cust_STeam_Update
    (
        p_cust_id       => p_cust_id,
        x_event_key     => x_event_key
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- End of API body.
    --

    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;


    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'end');

        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                        || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;


    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

End Before_Cust_STeam_Update;

-- Start of Comments
--
--      API name        : Upd_Cust_STeam_post_event
--      Type            : Public
--      Function        : Raises a business event for Customer sales team
--                        update. The Procedure Before_Cust_STeam_Update should
--                        have been called and the same event key must be passed.
--
--      Pre-reqs        : Existing cust_id and x_event_key from
--                        Before_Cust_STeam_Update call.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_event_key             IN  VARCHAR2
--          p_cust_id               IN  NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments

PROCEDURE Upd_Cust_STeam_post_event(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_cust_id                   IN NUMBER,
    p_event_key                 IN VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2(30) := 'Upd_Cust_STeam_post_event';
l_api_version_number    CONSTANT NUMBER       := 2.0;
l_debug                 BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpb.Upd_Cust_STeam_post_event';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT UPD_CUST_STEAM_POST_EVENT_PUB;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'start');
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --

    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: Calling AS_BUSINESS_EVENT_PVT.Upd_Cust_STeam_post_event');
    END IF;

    AS_BUSINESS_EVENT_PVT.Upd_Cust_STeam_post_event
    (
        p_cust_id       => p_cust_id,
        p_event_key     => p_event_key
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR then
        raise FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- End of API body.
    --

    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;


    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Public API: ' || l_api_name || 'end');

        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                        || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
    END IF;


    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

        WHEN OTHERS THEN
            AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                 P_MODULE => l_module
                ,P_API_NAME => L_API_NAME
                ,P_PKG_NAME => G_PKG_NAME
                ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                ,P_SQLCODE => SQLCODE
                ,P_SQLERRM => SQLERRM
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);

End Upd_Cust_STeam_post_event;

END AS_BUSINESS_EVENT_PUB;

/
