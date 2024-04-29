--------------------------------------------------------
--  DDL for Package Body CS_MULTIORG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_MULTIORG_PUB" as
/* $Header: csxpmoib.pls 115.1 2003/08/06 01:44:30 takwong noship $ */

/*********** Global  Variables  ********************************/
G_PKG_NAME     CONSTANT  VARCHAR2(30)  := 'CS_MultiOrg_PUB' ;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_OrgId
--   Type    :  Public
--   Purpose :  This public API is to get the MutliOrg id.
--              The implementation will be a wrapper on CS_MultiOrg_PVT.Get_OrgId private API.
--   Pre-Req :
--   Parameters:
--       p_api_version          IN                  NUMBER      Required
--       p_init_msg_list        IN                  VARCHAR2
--       p_commit               IN                  VARCHAR2
--       p_validation_level     IN                  NUMBER
--       x_return_status        OUT     NOCOPY      VARCHAR2
--       x_msg_count            OUT     NOCOPY      NUMBER
--       x_msg_data             OUT     NOCOPY      VARCHAR2
--       p_incident_id          IN                  NUMBER      Required
--       x_org_id			    OUT	    NOCOPY	    NUMBER,
--       x_profile			    OUT 	NOCOPY	    VARCHAR2

--   Version : Current version 1.0
--   End of Comments
--
--

PROCEDURE Get_OrgId(
    p_api_version		IN              NUMBER,
    p_init_msg_list		IN 	            VARCHAR2,
    p_commit			IN			    VARCHAR2,
    p_validation_level	IN	            NUMBER,
    x_return_status		OUT     NOCOPY 	VARCHAR2,
    x_msg_count			OUT 	NOCOPY 	NUMBER,
    x_msg_data			OUT 	NOCOPY 	VARCHAR2,
    p_incident_id		IN	            NUMBER,
    x_org_id			OUT	    NOCOPY	NUMBER,
    x_profile			OUT 	NOCOPY	VARCHAR2
)
IS
    l_api_name       CONSTANT  VARCHAR2(30) := 'Get_OrgId' ;
    l_api_name_full  CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
    l_api_version    CONSTANT  NUMBER       := 1.0 ;

    l_return_status      VARCHAR2(1) ;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    l_debug     number      :=  ASO_DEBUG_PUB.G_DEBUG_LEVEL ;

BEGIN
    --  Standard Start of API Savepoint
    SAVEPOINT   CS_Charge_Create_Order_PUB;

    --  Standard Call to check API compatibility
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    if (l_debug > 0) then
        aso_debug_pub.add('Public API: ' || l_api_name_full || ' start', 1, 'Y');
        aso_debug_pub.add ('Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'), 1, 'Y');
    end if;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --
    -- Local Procedure

    if (l_debug > 0) then
        aso_debug_pub.add(l_api_name_full || ': Incident Id =' || p_incident_id, 1, 'Y');

        -- Call CS_MultiOrg_PVT.Get_OrgId Private API
        aso_debug_pub.add(l_api_name_full || ': Before call CS_MultiOrg_PVT.Get_OrgId', 1, 'Y');
    end if;

    CS_MultiOrg_PVT.Get_OrgId(
                p_api_version           =>  p_api_version,
                p_init_msg_list         =>  p_init_msg_list,
                p_commit                =>  p_commit,
                p_validation_level      =>  p_validation_level,
                x_return_status         =>  l_return_status,
                x_msg_count             =>  l_msg_count,
                x_msg_data              =>  l_msg_data,
                p_incident_id           =>  p_incident_id,
                x_org_id                =>  x_org_id,
                x_profile               =>  x_profile
                );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        if (l_debug > 0) then
            aso_debug_pub.add(l_api_name_full || ': STS error: Calling CS_MultiOrg_PVT.Get_OrgId failed', 1, 'Y');
        end if;
        --FND_MESSAGE.Set_Name('CS','CS_CHG_PROCEDURE_FAILED');
        --FND_MESSAGE.Set_Token('PROCEDURE','CS_MultiOrg_PVT.Get_OrgId');
        --FND_MSG_PUB.Add;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        if (l_debug > 0) then
            aso_debug_pub.add(l_api_name_full || ': Unexpected error: Calling CS_MultiOrg_PVT.Get_OrgId failed',1, 'Y');
        end if;
        --FND_MESSAGE.Set_Name('CS','CS_CHG_PROCEDURE_FAILED');
        --FND_MESSAGE.Set_Token('PROCEDURE','CS_MultiOrg_PVT.Get_OrgId');
        --FND_MSG_PUB.Add;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    if (l_debug > 0) then
        aso_debug_pub.add(l_api_name_full || ': After call CS_MultiOrg_PVT.Get_OrgId', 1, 'Y');
        aso_debug_pub.add(l_api_name_full || ': x_org_id =' || x_org_id, 1, 'Y');
        aso_debug_pub.add(l_api_name_full || ': x_profile =' || x_profile, 1, 'Y');
    end if;

    --
    -- End of API body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    if (l_debug > 0) then
        aso_debug_pub.add ('Public API: ' || l_api_name_full || ' end', 1, 'Y');
        aso_debug_pub.add ('End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'), 1, 'Y');
    end if;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count     =>      x_msg_count,
            p_data      =>      x_msg_data
        );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO CS_Charge_Create_Order_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count,
                    p_data      =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO CS_Charge_Create_Order_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count,
                    p_data      =>      x_msg_data
                );
         WHEN OTHERS THEN
            ROLLBACK TO CS_Charge_Create_Order_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME,
                        l_api_name
                    );
            END IF;
            FND_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count,
                    p_data      =>      x_msg_data
                );
    END Get_OrgId;

End CS_MultiOrg_PUB;

/
