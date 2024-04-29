--------------------------------------------------------
--  DDL for Package Body INV_KANBAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_KANBAN_PUB" as
/* $Header: INVPKBNB.pls 120.1 2005/06/14 06:10:16 appldev  $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_Kanban_PUB';

--  Start of Comments
--  API name    Update_Card_Supply_Status
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

Procedure Update_Card_Supply_Status
(p_api_version_number            IN  NUMBER,
 p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE,
 p_commit                        IN  VARCHAR2 := FND_API.G_FALSE,
 x_msg_count                     OUT NOCOPY NUMBER,
 x_msg_data                      OUT NOCOPY VARCHAR2,
 X_Return_Status      		 OUT NOCOPY Varchar2,
 p_Kanban_Card_Id        	     Number,
 p_Supply_Status                     Number)
IS

l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Update_Card_Supply_Status';

Begin


    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

	INV_Kanban_PVT.Update_Card_Supply_Status
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_Kanban_card_Id              => p_Kanban_card_Id
    ,   p_Supply_Status               => p_Supply_Status);


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Card_Supply_Status'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Update_Card_Supply_Status;

END INV_Kanban_PUB;

/
