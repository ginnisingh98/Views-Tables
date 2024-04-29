--------------------------------------------------------
--  DDL for Package OKL_RULE_EXTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RULE_EXTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRREXS.pls 115.10 2003/10/14 18:32:39 ashariff noship $ */
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
  G_API_TYPE        CONSTANT VARCHAR2(4) := '_PVT';
  G_API_VERSION     CONSTANT NUMBER := 1.0;
  G_SCOPE           CONSTANT VARCHAR2(4) := '_PVT';
 -- GLOBAL VARIABLES
---------------------------------------------------------------------------
   G_PKG_NAME           CONSTANT VARCHAR2(200) := 'OKL_RULE_EXTRACT_PVT';
   G_APP_NAME           CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
---------------------------------------------------------------------------
--structures to hold rule code records
Type rule_rec_type  is record ( rgs_code                       FND_DESCR_FLEX_COL_USAGE_VL.DESCRIPTIVE_FLEX_CONTEXT_CODE%TYPE := OKC_API.G_MISS_CHAR,
                                application_column_name        FND_DESCR_FLEX_COL_USAGE_VL.APPLICATION_COLUMN_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                column_seq_num                 VARCHAR2(3) := OKC_API.G_MISS_CHAR);
Type rule_tbl_type is table of rule_rec_type index by BINARY_INTEGER;
--structures to hold subclass-rulegroup records
Type sc_rg_rec_type is record (scs_code    OKC_SUBCLASS_RG_DEFS.SCS_CODE%TYPE := OKC_API.G_MISS_CHAR,
                               rgd_code    OKC_SUBCLASS_RG_DEFS.RGD_CODE%TYPE := OKC_API.G_MISS_CHAR,
                               meaning     FND_LOOKUPS.MEANING%TYPE := OKC_API.G_MISS_CHAR,
                               description FND_LOOKUPS.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR);
Type sc_rg_tbl_type  is table of sc_rg_Rec_Type index by BINARY_INTEGER;
--structures to hold rule group - rules records
Type rg_rules_rec_type is record (rgd_code                      OKC_RG_DEF_RULES.RGD_CODE%TYPE := OKC_API.G_MISS_CHAR,
                                  rdf_code                      OKC_RG_DEF_RULES.RDF_CODE%TYPE := OKC_API.G_MISS_CHAR,
                                  application_column_name       FND_DESCR_FLEX_COL_USAGE_VL.APPLICATION_COLUMN_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                  column_seq_num                VARCHAR2(3) := OKC_API.G_MISS_CHAR,
                                  optional_yn                   OKC_RG_DEF_RULES.OPTIONAL_YN%TYPE := OKC_API.G_MISS_CHAR,
                                  min_cardinality               VARCHAR2(9) := OKC_API.G_MISS_CHAR,
                                  max_cardinality               VARCHAR2(9) := OKC_API.G_MISS_CHAR);
Type rg_rules_tbl_type is table of rg_rules_rec_type index by BINARY_INTEGER;
--structures to hold rule-segment records
--this will hold the retreived metadata for rendering of
--rule segments
Type rul_segment_rec_type is record (rgd_code                   OKC_RG_DEF_RULES.RGD_CODE%TYPE := OKC_API.G_MISS_CHAR,
                                     rgs_code                   OKC_RG_DEF_RULES.RDF_CODE%TYPE := OKC_API.G_MISS_CHAR,
                                     application_column_name    FND_DESCR_FLEX_COL_USAGE_VL.APPLICATION_COLUMN_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                     end_user_column_name       FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                     sequence                   VARCHAR2(3) := OKC_API.G_MISS_CHAR,
                                     enabled_flag               FND_DESCR_FLEX_COL_USAGE_VL.ENABLED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
                                     displayed_flag             FND_DESCR_FLEX_COL_USAGE_VL.DISPLAY_FLAG%TYPE := OKC_API.G_MISS_CHAR,
                                     required_flag              FND_DESCR_FLEX_COL_USAGE_VL.REQUIRED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
                                     default_size               VARCHAR2(3)    := OKC_API.G_MISS_CHAR,
                                     left_prompt                FND_DESCR_FLEX_COL_USAGE_VL.FORM_LEFT_PROMPT%TYPE := OKC_API.G_MISS_CHAR,
                                     select_clause              VARCHAR2(2000) := OKC_API.G_MISS_CHAR,
                                     from_clause                VARCHAR2(2000) := OKC_API.G_MISS_CHAR,
                                     where_clause               VARCHAR2(2000) := OKC_API.G_MISS_CHAR,
                                     order_by_clause            VARCHAR2(2000) := OKC_API.G_MISS_CHAR,
                                     object_code                JTF_OBJECTS_B.OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
                                     longlist_flag              VARCHAR2(1) := OKC_API.G_MISS_CHAR,
                                     format_type                FND_DESCR_FLEX_COL_USAGE_VL.DEFAULT_TYPE%TYPE,
                                     id1_col                    DBA_TAB_COLUMNS.COLUMN_NAME%TYPE,
                                     id2_col                    DBA_TAB_COLUMNS.COLUMN_NAME%TYPE,
                                     rule_info_col              DBA_TAB_COLUMNS.COLUMN_NAME%TYPE,
                                     name_col                   DBA_TAB_COLUMNS.COLUMN_NAME%TYPE,
                                     value_set_name             FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%TYPE,
                                     additional_columns         FND_FLEX_VALIDATION_TABLES.ADDITIONAL_QUICKPICK_COLUMNS%TYPE);
Type rule_segment_tbl_type is table of rul_segment_rec_type index by BINARY_INTEGER;

-- bug 3029276
Type rule_segment_rec_type2 is record (rgd_code                   OKC_RG_DEF_RULES.RGD_CODE%TYPE := OKC_API.G_MISS_CHAR,
                                        rgs_code                   OKC_RG_DEF_RULES.RDF_CODE%TYPE := OKC_API.G_MISS_CHAR,
                                        application_column_name    FND_DESCR_FLEX_COL_USAGE_VL.APPLICATION_COLUMN_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                        end_user_column_name       FND_DESCR_FLEX_COL_USAGE_VL.END_USER_COLUMN_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                        sequence                   VARCHAR2(3) := OKC_API.G_MISS_CHAR,
                                        enabled_flag               FND_DESCR_FLEX_COL_USAGE_VL.ENABLED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
                                        displayed_flag             FND_DESCR_FLEX_COL_USAGE_VL.DISPLAY_FLAG%TYPE := OKC_API.G_MISS_CHAR,
                                        required_flag              FND_DESCR_FLEX_COL_USAGE_VL.REQUIRED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
                                        default_size               VARCHAR2(3)    := OKC_API.G_MISS_CHAR,
                                        left_prompt                FND_DESCR_FLEX_COL_USAGE_VL.FORM_LEFT_PROMPT%TYPE := OKC_API.G_MISS_CHAR,
                                        select_clause              VARCHAR2(2000) := OKC_API.G_MISS_CHAR,
                                        from_clause                VARCHAR2(2000) := OKC_API.G_MISS_CHAR,
                                        where_clause               VARCHAR2(2000) := OKC_API.G_MISS_CHAR,
                                        order_by_clause            VARCHAR2(2000) := OKC_API.G_MISS_CHAR,
                                        object_code                JTF_OBJECTS_B.OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
                                        longlist_flag              VARCHAR2(1) := OKC_API.G_MISS_CHAR,
                                        format_type                FND_DESCR_FLEX_COL_USAGE_VL.DEFAULT_TYPE%TYPE,
                                        id1_col                    DBA_TAB_COLUMNS.COLUMN_NAME%TYPE,
                                        id2_col                    DBA_TAB_COLUMNS.COLUMN_NAME%TYPE,
                                        rule_info_col              DBA_TAB_COLUMNS.COLUMN_NAME%TYPE,
                                        name_col                   DBA_TAB_COLUMNS.COLUMN_NAME%TYPE,
                                        value_set_name             FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%TYPE,
                                        additional_columns         FND_FLEX_VALIDATION_TABLES.ADDITIONAL_QUICKPICK_COLUMNS%TYPE,
                                        x_id1                      VARCHAR2(300) := OKC_API.G_MISS_CHAR,
                                        x_id2                      VARCHAR2(300) := OKC_API.G_MISS_CHAR,
                                        x_name                     VARCHAR2(1000) := OKC_API.G_MISS_CHAR,
                                        x_desc                     VARCHAR2(1000) := OKC_API.G_MISS_CHAR,
                                        x_segment_status           VARCHAR2(7) := 'VALID'
                                           );
Type rule_segment_tbl_type2 is table of rule_segment_rec_type2 index by BINARY_INTEGER;

subtype rulv_rec_type is OKL_RULE_PUB.rulv_rec_type;
--------------------------



--start of comments
--API Name     : Get_Subclass_Rgs
--Description  :API to fetch all the rule groups attached to a subclass
--end of comments
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

End OKL_RULE_EXTRACT_PVT;

 

/
