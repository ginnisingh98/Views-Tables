--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_HOOK" as
/* $Header: asoczteb.pls 120.0.12010000.3 2014/08/07 19:51:24 vidsrini noship $ */
-- Start of Comments
-- Start of Comments
-- Package name     : ASO_QUOTE_HOOK
-- Purpose          :
-- This is a new API to return the model configuration effective date
-- and the model configuration lookup date.





--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_Model_Configuration_Date
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       P_QUOTE_HEADER_ID      IN   NUMBER   Optional  Default = FND_API.G_MISS_NUM
--       P_QUOTE_LINE_ID           IN   NUMBER      Optional  Default = FND_API.G_MISS_NUM
--
--
--   OUT:
--       X_CONFIG_EFFECTIVE_DATE                           OUT NOCOPY /* file.sql.39 change */   DATE
--       X_CONFIG_MODEL_LOOKUP_DATE               OUT NOCOPY /* file.sql.39 change */   DATE
--    Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Get_Model_Configuration_Date(
     P_QUOTE_HEADER_ID                           IN NUMBER ,
     P_QUOTE_LINE_ID                                   IN NUMBER,
     X_CONFIG_EFFECTIVE_DATE              OUT NOCOPY /* file.sql.39 change */     DATE,
    X_CONFIG_MODEL_LOOKUP_DATE    OUT NOCOPY /* file.sql.39 change */     DATE
    ) IS
BEGIN
    X_CONFIG_EFFECTIVE_DATE:= NULL;
    X_CONFIG_MODEL_LOOKUP_DATE:=NULL;

END Get_Model_Configuration_Date;


PROCEDURE Get_Model_Init_Parameters(
     P_QUOTE_HEADER_ID         IN NUMBER ,
     P_QUOTE_LINE_ID           IN NUMBER,
     X_CONFIG_INIT_PARAMETER   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    ) IS
BEGIN

X_CONFIG_INIT_PARAMETER := NULL;

END Get_Model_Init_Parameters;


PROCEDURE Compute_Margin(
     P_QUOTE_HEADER_ID         IN NUMBER ,
     P_QUOTE_LINE_ID           IN  NUMBER := NULL,
     X_MARGIN_LINE_TBL         OUT NOCOPY /* file.sql.39 change */ MARGIN_LINE_Tbl_Type,
     X_QUOTE_UNIT_COST         OUT NOCOPY /* file.sql.39 change */ NUMBER,
     X_QUOTE_MARGIN            OUT NOCOPY /* file.sql.39 change */ NUMBER,
     X_QUOTE_MARGIN_PER        OUT NOCOPY /* file.sql.39 change */ NUMBER
    ) IS
BEGIN
  X_MARGIN_LINE_TBL:=G_MISS_MAR_LINE_TBL;
  X_QUOTE_UNIT_COST:=NULL;
  X_QUOTE_MARGIN:=null;
  X_QUOTE_MARGIN_PER:=null;

END Compute_Margin;

PROCEDURE Populate_Purge_Quotes_temp( p_operating_unit IN NUMBER,
P_quote_expiration_days IN  NUMBER,
	    P_last_update_days IN  NUMBER,
	    P_istore_cart IN  VARCHAR2 ,
	    p_review_candidate_quotes IN  VARCHAR2,
			p_purge_hook_enabled OUT NOCOPY /* file.sql.39 change */  varchar2) is
Begin
 /**** Customer MUST set P_PURGE_HOOK_ENABLED parameter VALUE as 'Y' if they use this hook to populate ASO_PURGE_QUOTES table. ****/

 /**** Customer can use the IN parameter values and add additional conditions by write custom code to insert into the ASO_PURGE_QUOTES and ****/

 /**** Only the Quotes populated in ASO_PURGE_QUOTES table will be used for purging the Quotes. ****/

 /****

Example:
 Insert into ASO_PURGE_QUOTES (quote_header_id)  Select quote_header_id from aso_quote_headers where INVOICE_TO_CUST_ACCOUNT_ID = 9999 and p_operating_unit = 999;

 and use the other parameters values to add validation on QUOTE_EXPIRATION_DATE, LAST_UPDATE_DATE AND QUOTE_SOURCE_CODE

 P_PURGE_HOOK_ENABLED : = 'Y;

****/

P_PURGE_HOOK_ENABLED := 'N';

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' Then
 aso_debug_pub.add('Populate_Purge_Quotes_temp p_operating_unit:' || p_operating_unit , 1, 'N');
 aso_debug_pub.add('Populate_Purge_Quotes_temp P_quote_expiration_days:' || P_quote_expiration_days, 1, 'N');
 aso_debug_pub.add('Populate_Purge_Quotes_temp P_last_update_days:'  || P_last_update_days, 1, 'N');
 aso_debug_pub.add('Populate_Purge_Quotes_temp P_istore_cart:' || P_istore_cart, 1, 'N');
 aso_debug_pub.add('Populate_Purge_Quotes_temp p_review_candidate_quotes:' || p_review_candidate_quotes, 1, 'N');
End if;
end ;

End ASO_QUOTE_HOOK;

/
