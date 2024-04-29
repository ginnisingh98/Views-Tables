--------------------------------------------------------
--  DDL for Package ASO_CREDIT_CHECK_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_CREDIT_CHECK_VUHK" AUTHID CURRENT_USER as
/* $Header: asohqccs.pls 120.1 2005/06/29 12:31:57 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_CREDIT_CHECK_VUHK
-- Purpose          :
-- This package is the spec required for customer user hooks needed to
-- simplify the customization process. It consists of both the pre and
-- post processing APIs.





--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Credit_Check
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Qte_Header_Rec          IN   Qte_Header_Rec_Type  Required
--       P_result_out              IN   VARCHAR2   Only used in Post Procedure.
--       P_cc_hold_comment         IN   VARCHAR2   Only used in Post Procedure.
--
--   OUT:
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--

PROCEDURE Credit_Check_PRE(
  P_API_VERSION		    IN	NUMBER,
  P_INIT_MSG_LIST	    IN	VARCHAR2  := FND_API.G_FALSE,
  P_COMMIT		    IN 	VARCHAR2  := FND_API.G_FALSE,
  P_QTE_HEADER_REC          IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
  X_RETURN_STATUS	    OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  X_MSG_COUNT		    OUT NOCOPY /* file.sql.39 change */  NUMBER,
  X_MSG_DATA		    OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );



PROCEDURE Credit_Check_POST(
  P_API_VERSION		    IN	NUMBER,
  P_INIT_MSG_LIST	    IN	VARCHAR2  := FND_API.G_FALSE,
  P_COMMIT		    IN 	VARCHAR2  := FND_API.G_FALSE,
  P_QTE_HEADER_REC          IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
  P_RESULT_OUT              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  P_CC_HOLD_COMMENT         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  X_RETURN_STATUS	    OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  X_MSG_COUNT		    OUT NOCOPY /* file.sql.39 change */  NUMBER,
  X_MSG_DATA		    OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

End ASO_CREDIT_CHECK_VUHK;

 

/
