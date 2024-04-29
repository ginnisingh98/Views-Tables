--------------------------------------------------------
--  DDL for Package ASO_CREDIT_CHECK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_CREDIT_CHECK_PUB" AUTHID CURRENT_USER as
/* $Header: asopqccs.pls 120.1 2005/06/29 12:37:27 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_CREDIT_CHECK_PUB
-- Purpose          :
--
-- History          :
-- NOTE             :

-- End of Comments

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Credit Check
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Qte_Header_Rec          IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type  Required
--
--   OUT:
--       x_result_out		   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_cc_hold_comment         OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 0.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Credit_Check(
  P_API_VERSION		          IN	NUMBER,
  P_INIT_MSG_LIST	          IN	VARCHAR2  := FND_API.G_FALSE,
  P_COMMIT		          IN 	VARCHAR2  := FND_API.G_FALSE,
  P_QTE_HEADER_REC                IN    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
  X_RESULT_OUT                    OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
  X_CC_HOLD_COMMENT               OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
  X_RETURN_STATUS	          OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2,
  X_MSG_COUNT		          OUT NOCOPY /* file.sql.39 change */ 	NUMBER,
  X_MSG_DATA		          OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
);

End ASO_CREDIT_CHECK_PUB;


 

/
