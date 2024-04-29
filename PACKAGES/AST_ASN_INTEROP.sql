--------------------------------------------------------
--  DDL for Package AST_ASN_INTEROP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_ASN_INTEROP" AUTHID CURRENT_USER as
/* $Header: astasnis.pls 115.3 2004/03/23 08:53:06 subabu noship $ */
-- Start of Comments
-- Package name     : AST_ASN_INTEROP
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  AST_ASN_INTEROP
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN:
--      p_api_version_number IN NUMBER   Required
--      p_init_msg_list      IN VARCHAR2 Optional Default = FND_API_G_FALSE
--      p_commit             IN VARCHAR2 Optional Default = FND_API.G_FALSE
--      p_validation_level   IN NUMBER   Optional Default =
--                                                   FND_API.G_VALID_LEVEL_FULL
--      p_lead_id			 IN    NUMBER,
--   OUT:
--      x_return_status      OUT  VARCHAR2
--      x_msg_count          OUT  NUMBER
--      x_msg_data           OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments

PROCEDURE RECONCILE_SALESCREDIT(
    p_api_version_number         IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                     IN    VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      	 IN    NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_lead_id			 IN    NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE CHECK_SALES_STAGE(
    p_api_version_number         IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level      	 IN    NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_sales_lead_id		 IN    NUMBER,
    X_sales_stage_id             OUT   NOCOPY NUMBER,
    X_sales_methodology_id       OUT   NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2);

PROCEDURE RECONCILE_SALESMETHODOLOGY(
    p_api_version_number         IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                     IN    VARCHAR2 DEFAULT  FND_API.G_FALSE,
    p_validation_level      	 IN    NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_lead_id		         IN    NUMBER,
    p_sales_stage_id             IN    NUMBER,
    p_sales_methodology_id       IN    NUMBER,
    P_Admin_Flag                 IN    VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Group_Id             IN    NUMBER,
    P_Identity_Salesforce_Id     IN    NUMBER       := NULL,
    P_identity_salesgroup_id     IN    NUMBER       := NULL,
    P_profile_tbl                IN  AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

END AST_ASN_INTEROP;

 

/
