--------------------------------------------------------
--  DDL for Package OKL_RULE_EXTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RULE_EXTRACT_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPREXS.pls 120.6 2008/02/29 10:49:34 asawanka ship $ */
/*#
 *Contract Rules API allows users to query terms and conditions
 *related to data for  a lease contract using calls to PL/SQL functions.
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname Contract Rules API
 * @rep:category BUSINESS_ENTITY OKL_ORIGINATION
 * @rep:lifecycle active
 * @rep:compatibility S
 */

---------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
  G_FND_APP                        CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC     CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED            CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED            CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED       CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN             CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN              CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_ERROR                          CONSTANT VARCHAR2(30)  := 'OKL_CONTRACTS_ERROR';
  G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED             CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UPPERCASE_REQ';
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION   EXCEPTION;
  G_API_TYPE        CONSTANT VARCHAR2(4) := '_PUB';
  G_API_VERSION     CONSTANT NUMBER := 1.0;
  G_SCOPE           CONSTANT VARCHAR2(4) := '_PUB';
 -- GLOBAL VARIABLES
---------------------------------------------------------------------------
   G_PKG_NAME           CONSTANT VARCHAR2(200) := 'OKL_RULE_EXTRACT_PUB';
   G_APP_NAME           CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
---------------------------------------------------------------------------
--structures to hold rule code records
SUBTYPE rule_rec_type is OKL_RULE_EXTRACT_PVT.rule_rec_type;
SUBTYPE rule_tbl_type is OKL_RULE_EXTRACT_PVT.rule_tbl_type;
--structures to hold subclass-rulegroup records
SUBTYPE sc_rg_rec_type is OKL_RULE_EXTRACT_PVT.sc_rg_rec_type;
SUBTYPE sc_rg_tbl_type is OKL_RULE_EXTRACT_PVT.sc_rg_tbl_type;
--structures to hold rule group - rules records
SUBTYPE rg_rules_rec_type is OKL_RULE_EXTRACT_PVT.rg_rules_rec_type;
SUBTYPE rg_rules_tbl_type is OKL_RULE_EXTRACT_PVT.rg_rules_tbl_type;
--structures to hold rule-segment records
--this will hold the retreived metadata for rendering of
--rule segments
SUBTYPE rul_segment_rec_type is OKL_RULE_EXTRACT_PVT.rul_segment_rec_type;
SUBTYPE rule_segment_tbl_type is OKL_RULE_EXTRACT_PVT.rule_segment_tbl_type;
-- bug 3029276.
--structures to hold rule-segment records
--this will hold the retreived metadata for rendering of
--rule segments and also to hold ids and names for each segment.
SUBTYPE rule_segment_rec_type2 is OKL_RULE_EXTRACT_PVT.rule_segment_rec_type2;
SUBTYPE rule_segment_tbl_type2 is OKL_RULE_EXTRACT_PVT.rule_segment_tbl_type2;

--start of comments
--API Name     : Get_Subclass_Rgs
--Description  :API to fetch all the rule groups attached to a subclass
--end of comments
/*#
 * Get subclass rule groups.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Error message data
 * @param p_chr_id Contract identifier
 * @param x_sc_rg_tbl Subclass rule groups table
 * @rep:displayname Get Subclass Rule Groups
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_ORIGINATION
 */
PROCEDURE Get_subclass_Rgs (p_api_version     IN  NUMBER,
                            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                            x_return_status   OUT NOCOPY VARCHAR2,
                            x_msg_count       OUT NOCOPY NUMBER,
                            x_msg_data        OUT NOCOPY VARCHAR2,
                            p_chr_id          IN Varchar2,
                            x_sc_rg_tbl       OUT NOCOPY sc_rg_tbl_type);
--start of comments
--API Name     : Get_Rg_Rules
--Description  : API to fetch all the rules attached to a rule group
--end of comments
/*#
 * Get rule group rules.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Error message data
 * @param p_rgd_code Rule group code
 * @param x_rg_rules_tbl Rule records table
 * @rep:displayname Get Rule Group Rules
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_ORIGINATION
 */
PROCEDURE Get_Rg_Rules (p_api_version     IN  NUMBER,
                        p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        x_return_status   OUT NOCOPY VARCHAR2,
                        x_msg_count       OUT NOCOPY NUMBER,
                        x_msg_data        OUT NOCOPY VARCHAR2,
                        p_rgd_code        IN  Varchar2,
                        x_rg_rules_tbl    OUT NOCOPY rg_rules_tbl_type);
--start of comments
--API Name     : Get_Rule_Def
--Description  : API to fetch rule definition - metadata for each rule segment
--end of comments
/*#
 * Get rule group rules.
 * @param p_api_version API version
 * @param p_init_msg_list  Initialize message stack
 * @param x_return_status  Return status from the API
 * @param x_msg_count  Message count if error messages are encountered
 * @param x_msg_data  Error message data
 * @param p_rgd_code Rule group code
 * @param p_rgs_code Rule code
 * @param p_buy_or_sell Contract intent
 * @param x_rule_segment_tbl Rule segment table
 * @rep:displayname Get Rule Group Rules
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY OKL_ORIGINATION
 */
PROCEDURE Get_Rule_Def (p_api_version       IN  NUMBER,
                        p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_msg_count         OUT NOCOPY NUMBER,
                        x_msg_data          OUT NOCOPY VARCHAR2,
                        p_rgd_code          IN  VARCHAR2,
                        p_rgs_code          IN  VARCHAR2,
                        p_buy_or_sell       IN  VARCHAR2,
                        x_rule_segment_tbl  OUT NOCOPY rule_segment_tbl_type);


-- bug 3029276
--start of comments
--API Name     : Get_Rules_Metadata
--Description  : API to fetch rule definition - metadata for each rule segment
--               and retrieve ids and names for each segment.
--end of comments

PROCEDURE Get_Rules_Metadata (p_api_version       IN  NUMBER,
                              p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_msg_count         OUT NOCOPY NUMBER,
                              x_msg_data          OUT NOCOPY VARCHAR2,
                              p_rgd_code          IN  VARCHAR2,
                              p_rgs_code          IN  VARCHAR2,
                              p_buy_or_sell       IN  VARCHAR2,
                              p_contract_id       IN  OKC_K_HEADERS_B.ID%TYPE := OKC_API.G_MISS_NUM,
                              p_line_id           IN  OKC_K_LINES_B.ID%TYPE := OKC_API.G_MISS_NUM,
                              p_party_id          IN  OKC_K_PARTY_ROLES_B.ID%TYPE := OKC_API.G_MISS_NUM,
                              p_template_table    IN  VARCHAR2,
                              p_rule_id_column    IN  VARCHAR2,
                              p_entity_column     IN  VARCHAR2,
                              x_rule_segment_tbl  OUT NOCOPY rule_segment_tbl_type2);

---------- -- end bug 3029276



End OKL_RULE_EXTRACT_PUB;

/
