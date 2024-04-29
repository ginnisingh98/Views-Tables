--------------------------------------------------------
--  DDL for Package ASO_QUOTE_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_HOOK" AUTHID CURRENT_USER as
/* $Header: asocztes.pls 120.0.12010000.14 2015/02/11 21:48:19 vidsrini noship $ */
/*# These public APIs allows to return the model configuration effective date and the model configuration lookup date.
    Also retruns initialization parameters to pass from Quoting to Configurator when the configurator session is launched
 * @rep:scope public
 * @rep:product ASO
 * @rep:displayname Order Capture
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY ASO_QUOTE
*/

-- Start of Comments
-- Start of Comments
-- Package name     : ASO_QUOTE_HOOK
-- Purpose          :
-- This is a new API to return the model configuration effective date
-- and the model configuration lookup date.


TYPE MARGIN_LINE_Rec_Type IS RECORD
(
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       UNIT_COST                       NUMBER := FND_API.G_MISS_NUM,
       MARGIN_AMOUNT                   NUMBER := FND_API.G_MISS_NUM,
       MARGIN_PERCENT                   NUMBER := FND_API.G_MISS_NUM
);

G_MISS_MAR_LINE_REC          MARGIN_LINE_Rec_Type;
TYPE  MARGIN_LINE_Tbl_Type   IS TABLE OF MARGIN_LINE_Rec_Type INDEX BY BINARY_INTEGER;
G_MISS_MAR_LINE_TBL          MARGIN_LINE_Tbl_Type;



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
/*#
* Use this procedure to Get Model Configuration Date.
* @param  P_QUOTE_HEADER_ID               Quote header id for the quote.
* @param  P_QUOTE_LINE_ID                 Quote line id for the top level model item in the quote.
* @param  X_CONFIG_EFFECTIVE_DATE         Model configuration effective date.
* @param  X_CONFIG_MODEL_LOOKUP_DATE      Model configuration lookup date.
* @rep:scope          public
* @rep:lifecycle      active
* @rep:category  BUSINESS_ENTITY     ASO_QUOTE
* @rep:displayname      Get Model Configuration Date
*/


PROCEDURE Get_Model_Configuration_Date(
     P_QUOTE_HEADER_ID                           IN NUMBER ,
     P_QUOTE_LINE_ID                                   IN NUMBER,
     X_CONFIG_EFFECTIVE_DATE              OUT NOCOPY /* file.sql.39 change */     DATE,
    X_CONFIG_MODEL_LOOKUP_DATE    OUT NOCOPY /* file.sql.39 change */     DATE
    );

/*#
* Use this procedure to Get Model Init Parameters.
* @param  P_QUOTE_HEADER_ID               Quote header id for the quote.
* @param  P_QUOTE_LINE_ID                 Quote line id for the top level model item in the quote.
* @param  X_CONFIG_INIT_PARAMETER         Initialization parameters from Quoting to Configurator when the configurator session is launched.
* @rep:scope          public
* @rep:lifecycle      active
* @rep:category  BUSINESS_ENTITY     ASO_QUOTE
* @rep:displayname      Get Model Init Parameters
*/

PROCEDURE Get_Model_Init_Parameters(
     P_QUOTE_HEADER_ID         IN NUMBER ,
     P_QUOTE_LINE_ID           IN NUMBER,
     X_CONFIG_INIT_PARAMETER   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

/*#
* Use this procedure to Compute Margin.
* @param  P_QUOTE_HEADER_ID               Quote header id for the quote.
* @param  P_QUOTE_LINE_ID                 Quote line id for the quote.
* @param  X_MARGIN_LINE_TBL               Contains margin information corresponding to each line in the quote.
* @param  X_QUOTE_UNIT_COST               Cost at the quote level.
* @param  X_QUOTE_MARGIN                  Margin at the quote level.
* @param  X_QUOTE_MARGIN_PER              Margin Percent at the quote level.
* @rep:scope          public
* @rep:lifecycle      active
* @rep:category  BUSINESS_ENTITY     ASO_QUOTE
* @rep:displayname      Compute Margin
*/

PROCEDURE Compute_Margin(
     P_QUOTE_HEADER_ID         IN NUMBER ,
     P_QUOTE_LINE_ID           IN  NUMBER := NULL,
     X_MARGIN_LINE_TBL         OUT NOCOPY /* file.sql.39 change */ MARGIN_LINE_Tbl_Type,
     X_QUOTE_UNIT_COST         OUT NOCOPY /* file.sql.39 change */ NUMBER,
     X_QUOTE_MARGIN            OUT NOCOPY /* file.sql.39 change */ NUMBER,
     X_QUOTE_MARGIN_PER        OUT NOCOPY /* file.sql.39 change */ NUMBER
    );

/*#
* Use this procedure to identify the Quotes/Shopping Carts that should be purged. The procedure must store the list of candidate quotes/carts in the ASO_PURGE_QUOTES table.
* @param  p_operating_unit               Include quotes for the operating unit specified in this parameter. If it is blank, it will include all operating units that the user has access to.
* @param  P_quote_expiration_days        The number of days after the Quote Expiration Date. Specify the number of days as n. Current Date - Quote Expiration Date >= n.
* @param  P_last_update_days             The number of days after the Quote Last Update Date. Specify the number of days as n. Current Date - Quote Last Update Date>= n.
* @param  P_istore_cart                  Include or exclude iStore shopping carts. If the value is 'Yes', this parameter includes Oracle iStore shopping carts in the purge process.
                                         If the value is 'No', this parameter excludes Oracle iStore shopping carts from the purge process.
* @param  p_review_candidate_quotes      If the value is 'Yes', this parameter lets you review the quotes to be removed.
                                          If the value is 'No', the quotes that are referenced in the ASO_PURGE_QUOTES table are purged and the remaining parameters are ignored.
* @param  p_purge_hook_enabled           Set this parameter to 'Yes' if the hook is enabled. Set it to 'No' if it is not enabled. The default is 'No'.
* @rep:scope          public
* @rep:lifecycle      active
* @rep:category  BUSINESS_ENTITY     ASO_QUOTE
* @rep:displayname      Purge Quote
*/

PROCEDURE Populate_Purge_Quotes_temp(
p_operating_unit IN NUMBER,
P_quote_expiration_days IN  NUMBER,
P_last_update_days IN  NUMBER,
P_istore_cart IN  VARCHAR2 ,
p_review_candidate_quotes IN  VARCHAR2,
p_purge_hook_enabled OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);
End ASO_QUOTE_HOOK;

/
