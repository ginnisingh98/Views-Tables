--------------------------------------------------------
--  DDL for Package PV_BG_PARTNER_MATCHING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_BG_PARTNER_MATCHING_PUB" AUTHID CURRENT_USER as
/* $Header: pvxvpmbs.pls 115.1 2004/05/22 16:25:59 dhii ship $ */
-- Start of Comments
-- Package name     : PV_BG_PARTNER_MATCHING_PUB
-- Purpose          : Background Partner Matching API's
-- NOTE             :
-- History          :
--      01/07/2003 PKLIN  Created.
--
--
-- End of Comments


PROCEDURE Start_Partner_Matching(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    P_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Identity_Salesforce_Id  IN  NUMBER,
    P_Salesgroup_Id           IN  NUMBER,
    P_Lead_id                 IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

PROCEDURE Partner_Matching(
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );


PROCEDURE Start_Campaign_Assignment(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    P_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Identity_Salesforce_Id  IN  NUMBER,
    P_Lead_id                 IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    );

PROCEDURE Campaign_Routing(
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2 );

End PV_BG_PARTNER_MATCHING_PUB;

 

/
