--------------------------------------------------------
--  DDL for Package QP_DATA_COMPARE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_DATA_COMPARE_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVDATS.pls 120.0 2005/06/02 01:35:00 appldev noship $ */

G_LIST_HEADER_TBL  CONSTANT VARCHAR2(30) := 'QP_LIST_HEADERS';
G_LIST_LINE_TBL    CONSTANT VARCHAR2(30) := 'QP_LIST_LINES';

TYPE LIST_HEADER_REC_TYPE IS RECORD
(
LIST_HEADER_ID                      NUMBER,
REQUEST_ID                          NUMBER ,
LIST_TYPE_CODE                      VARCHAR2(30),
START_DATE_ACTIVE                   DATE,
END_DATE_ACTIVE                     DATE,
AUTOMATIC_FLAG                      VARCHAR2(1),
CURRENCY_CODE                       VARCHAR2(30),
ROUNDING_FACTOR                     NUMBER ,
SHIP_METHOD_CODE                    VARCHAR2(30),
FREIGHT_TERMS_CODE                  VARCHAR2(30),
TERMS_ID                            NUMBER,
COMMENTS                            VARCHAR2(100),
DISCOUNT_LINES_FLAG                 VARCHAR2(30),
GSA_INDICATOR                       VARCHAR2(1),
PRORATE_FLAG                        VARCHAR2(30),
SOURCE_SYSTEM_CODE                  VARCHAR2(30),
ASK_FOR_FLAG                        VARCHAR2(1),
ACTIVE_FLAG                         VARCHAR2(1),
PARENT_LIST_HEADER_ID               NUMBER,
START_DATE_ACTIVE_FIRST             DATE,
END_DATE_ACTIVE_FIRST               DATE,
ACTIVE_DATE_FIRST_TYPE              VARCHAR2(30),
START_DATE_ACTIVE_SECOND            DATE,
END_DATE_ACTIVE_SECOND              DATE,
ACTIVE_DATE_SECOND_TYPE             VARCHAR2(30),
LIMIT_EXISTS_FLAG                   VARCHAR2(1),
MOBILE_DOWNLOAD                     VARCHAR2(1),
CURRENCY_HEADER_ID                  NUMBER,
PTE_CODE                            VARCHAR2(30),
LIST_SOURCE_CODE                    VARCHAR2(30),
ORIG_SYSTEM_HEADER_REF              VARCHAR2(30),
ORIG_ORG_ID                         NUMBER,
GLOBAL_FLAG                         VARCHAR2(1),
SOLD_TO_ORG_ID                      NUMBER,
SHAREABLE_FLAG                      VARCHAR2(1),
LOCKED_FROM_LIST_HEADER_ID          NUMBER,
LANGUAGE                            VARCHAR2(4),
SOURCE_LANG                         VARCHAR2(4),
NAME                                VARCHAR2(240),
DESCRIPTION                         VARCHAR2(2000),
VERSION_NO                          VARCHAR2(30));

TYPE QUALIFIER_REC_TYPE IS RECORD
(
QUALIFIER_ID                  NUMBER,
QUALIFIER_GROUPING_NO         NUMBER,
QUALIFIER_CONTEXT             VARCHAR2(30),
QUALIFIER_ATTRIBUTE           VARCHAR2(30),
QUALIFIER_ATTR_VALUE          VARCHAR2(240),
COMPARISON_OPERATOR_CODE      VARCHAR2(30),
EXCLUDER_FLAG                 VARCHAR2(1),
QUALIFIER_RULE_ID             NUMBER,
START_DATE_ACTIVE             DATE,
END_DATE_ACTIVE               DATE,
CREATED_FROM_RULE_ID          NUMBER,
QUALIFIER_PRECEDENCE          NUMBER,
LIST_HEADER_ID                NUMBER,
LIST_LINE_ID                  NUMBER,
QUALIFIER_DATATYPE            VARCHAR2(10),
QUALIFIER_ATTR_VALUE_TO       VARCHAR2(240),
ACTIVE_FLAG                   VARCHAR2(1),
LIST_TYPE_CODE                VARCHAR2(30),
QUAL_ATTR_VALUE_FROM_NUMBER   NUMBER,
QUAL_ATTR_VALUE_TO_NUMBER     NUMBER,
SEARCH_IND                    NUMBER,
QUALIFIER_GROUP_CNT           NUMBER,
HEADER_QUALS_EXIST_FLAG       VARCHAR2(1),
DISTINCT_ROW_COUNT            NUMBER,
OTHERS_GROUP_CNT              NUMBER,
ORIG_SYS_QUALIFIER_REF        VARCHAR2(50),
ORIG_SYS_HEADER_REF           VARCHAR2(50),
ORIG_SYS_LINE_REF             VARCHAR2(50),
SEGMENT_ID                    NUMBER);

TYPE LIST_LINE_REC_TYPE IS RECORD
(
LIST_LINE_ID                  NUMBER,
LIST_HEADER_ID                NUMBER,
LIST_LINE_TYPE_CODE           VARCHAR2(30),
START_DATE_ACTIVE             DATE,
END_DATE_ACTIVE               DATE,
AUTOMATIC_FLAG                VARCHAR2(1),
MODIFIER_LEVEL_CODE           VARCHAR2(30),
PRICE_BY_FORMULA_ID           NUMBER,
PRIMARY_UOM_FLAG              VARCHAR2(1),
PRICE_BREAK_TYPE_CODE         VARCHAR2(30),
ARITHMETIC_OPERATOR           VARCHAR2(30),
OPERAND                       NUMBER,
OVERRIDE_FLAG                 VARCHAR2(1),
ACCRUAL_QTY                   NUMBER,
ACCRUAL_UOM_CODE              VARCHAR2(30),
ESTIM_ACCRUAL_RATE            NUMBER,
GENERATE_USING_FORMULA_ID     NUMBER,
LIST_LINE_NO                  VARCHAR2(30),
ESTIM_GL_VALUE                NUMBER,
BENEFIT_PRICE_LIST_LINE_ID    NUMBER,
EXPIRATION_PERIOD_START_DATE  DATE,
NUMBER_EXPIRATION_PERIODS     NUMBER,
EXPIRATION_PERIOD_UOM         VARCHAR2(30),
EXPIRATION_DATE               DATE,
ACCRUAL_FLAG                  VARCHAR2(1),
PRICING_PHASE_ID              NUMBER,
PRICING_GROUP_SEQUENCE        NUMBER,
INCOMPATIBILITY_GRP_CODE      VARCHAR2(30),
PRODUCT_PRECEDENCE            NUMBER,
PRORATION_TYPE_CODE           VARCHAR2(30),
ACCRUAL_CONVERSION_RATE       NUMBER,
BENEFIT_QTY                   NUMBER,
BENEFIT_UOM_CODE              VARCHAR2(30),
QUALIFICATION_IND             NUMBER,
LIMIT_EXISTS_FLAG             VARCHAR2(1),
GROUP_COUNT                   NUMBER,
NET_AMOUNT_FLAG               VARCHAR2(1),
RECURRING_VALUE               NUMBER,
ACCUM_CONTEXT                 VARCHAR2(30),
ACCUM_ATTRIBUTE               VARCHAR2(30),
ACCUM_ATTR_RUN_SRC_FLAG       VARCHAR2(1),
BREAK_UOM_CODE                VARCHAR2(30),
BREAK_UOM_CONTEXT             VARCHAR2(30),
BREAK_UOM_ATTRIBUTE           VARCHAR2(30),
PATTERN_ID                    NUMBER,
PRODUCT_UOM_CODE              VARCHAR2(30),
PRICING_ATTRIBUTE_COUNT       NUMBER,
HASH_KEY                      VARCHAR2(30),
CACHE_KEY                     VARCHAR2(30));

TYPE PRICING_ATTRIBUTE_REC_TYPE IS RECORD
(
PRICING_ATTRIBUTE_ID           NUMBER,
LIST_LINE_ID                   NUMBER,
EXCLUDER_FLAG                  VARCHAR2(1),
ACCUMULATE_FLAG                VARCHAR2(1),
PRODUCT_ATTRIBUTE_CONTEXT      VARCHAR2(30),
PRODUCT_ATTRIBUTE              VARCHAR2(30),
PRODUCT_ATTR_VALUE             VARCHAR2(30),
PRODUCT_UOM_CODE               VARCHAR2(30),
PRICING_ATTRIBUTE_CONTEXT      VARCHAR2(30),
PRICING_ATTRIBUTE              VARCHAR2(30),
PRICING_ATTR_VALUE_FROM        VARCHAR2(240),
PRICING_ATTR_VALUE_TO          VARCHAR2(240),
ATTRIBUTE_GROUPING_NO          NUMBER,
PRODUCT_ATTRIBUTE_DATATYPE     VARCHAR2(1),
PRICING_ATTRIBUTE_DATATYPE     VARCHAR2(1),
COMPARISON_OPERATOR_CODE       VARCHAR2(30),
LIST_HEADER_ID                 NUMBER,
PRICING_PHASE_ID               NUMBER,
QUALIFICATION_IND              NUMBER,
PRICING_ATTR_VALUE_FROM_NUMBER NUMBER,
PRICING_ATTR_VALUE_TO_NUMBER   NUMBER,
DISTINCT_ROW_COUNT             NUMBER,
SEARCH_IND                     NUMBER,
PATTERN_VALUE_FROM_POSITIVE    VARCHAR2(240),
PATTERN_VALUE_TO_POSITIVE      VARCHAR2(240),
PATTERN_VALUE_FROM_NEGATIVE    VARCHAR2(240),
PATTERN_VALUE_TO_NEGATIVE      VARCHAR2(240),
PRODUCT_SEGMENT_ID             NUMBER,
PRICING_SEGMENT_ID             NUMBER);

TYPE RLTD_MODIFIER_REC_TYPE IS RECORD
(
RLTD_MODIFIER_ID          NUMBER,
RLTD_MODIFIER_GRP_NO      NUMBER,
FROM_RLTD_MODIFIER_ID     NUMBER,
TO_RLTD_MODIFIER_ID       NUMBER,
RLTD_MODIFIER_GRP_TYPE    VARCHAR2(30));

TYPE LIST_HEADER_PHASES_REC_TYPE IS RECORD
(
LIST_HEADER_ID            NUMBER,
PRICING_PHASE_ID          NUMBER,
QUALIFIER_FLAG            VARCHAR2(1));

TYPE PRICING_PHASES_REC_TYPE IS RECORD
(
MODIFIER_LEVEL_CODE       VARCHAR2(30),
PHASE_SEQUENCE            NUMBER,
PRICING_PHASE_ID          NUMBER,
INCOMPAT_RESOLVE_CODE     VARCHAR2(30),
NAME                      VARCHAR2(30),
SEEDED_FLAG               VARCHAR2(1),
FREEZE_OVERRIDE_FLAG      VARCHAR2(1),
USER_FREEZE_OVERRIDE_FLAG VARCHAR2(1),
USER_INCOMPAT_RESOLVE_CODE  VARCHAR2(30),
LINE_GROUP_EXISTS         VARCHAR2(1),
OID_EXISTS                VARCHAR2(1),
RLTD_EXISTS               VARCHAR2(1),
FREIGHT_EXISTS            VARCHAR2(1),
MANUAL_MODIFIER_FLAG      VARCHAR2(1));

TYPE ADV_MOD_PRODUCTS_REC_TYPE IS RECORD
( PRICING_PHASE_ID        NUMBER,
PRODUCT_ATTRIBUTE         VARCHAR2(30),
PRODUCT_ATTR_VALUE        VARCHAR2(240));

TYPE ATTRIBUTE_GROUPS_REC_TYPE IS RECORD
(
LIST_HEADER_ID            NUMBER,
LIST_LINE_ID              NUMBER,
ACTIVE_FLAG               VARCHAR2(1),
LIST_TYPE_CODE            VARCHAR2(30),
START_DATE_ACTIVE_Q       DATE,
END_DATE_ACTIVE_Q         DATE,
PATTERN_ID                NUMBER,
CURRENCY_CODE             VARCHAR2(30),
ASK_FOR_FLAG              VARCHAR2(1),
LIMIT_EXISTS              VARCHAR2(1),
SOURCE_SYSTEM_CODE        VARCHAR2(30),
EFFECTIVE_PRECEDENCE      NUMBER,
GROUPING_NO               NUMBER,
PRICING_PHASE_ID          NUMBER,
MODIFIER_LEVEL_CODE       VARCHAR2(30),
HASH_KEY                  VARCHAR2(2000),
CACHE_KEY                 VARCHAR2(240));

TYPE PATTERNS_REC_TYPE IS RECORD
(
PATTERN_ID                NUMBER,
SEGMENT_ID                NUMBER,
PATTERN_TYPE              VARCHAR2(30),
PATTERN_STRING            VARCHAR2(2000));

TYPE PATTERN_PHASES_REC_TYPE IS RECORD
(
LIST_HEADER_ID            NUMBER,
PATTERN_ID                NUMBER,
PRICING_PHASE_ID          NUMBER);


PROCEDURE List_Header_Data(p_html_list_line_id NUMBER,
                           p_forms_list_line_id NUMBER,
                           p_file_dir VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Qualifier_Data(p_html_list_line_id NUMBER,
                         p_forms_list_line_id NUMBER,
                         p_file_dir VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE List_Line_Data(p_html_list_line_id NUMBER,
                         p_forms_list_line_id NUMBER,
                         p_file_dir VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Pricing_Attribute_Data(p_html_list_line_id NUMBER,
                                 p_forms_list_line_id NUMBER,
                                 p_file_dir VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Rltd_Modifier_Data(p_html_list_line_id NUMBER,
                             p_forms_list_line_id NUMBER,
                             p_file_dir VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Attribute_Groups_Data(p_html_list_line_id NUMBER,
                                p_forms_list_line_id NUMBER,
                                p_file_dir VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE List_Header_Phases_Data(p_html_list_line_id NUMBER,
                                  p_forms_list_line_id NUMBER,
                                  p_file_dir VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Pricing_Phases_Data(p_data_creation_method VARCHAR2,
                              p_file_dir VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Adv_Mod_Products_Data(p_list_line_id NUMBER,
                                p_data_creation_method VARCHAR2,
                                p_file_dir VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Patterns_Data(p_html_list_line_id NUMBER,
                        p_forms_list_line_id NUMBER,
                        p_pattern_type VARCHAR2,
                        p_file_dir VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Pattern_Phases_Data(p_html_list_line_id NUMBER,
                              p_forms_list_line_id NUMBER,
                              p_pattern_type VARCHAR2,
                              p_file_dir VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Profiles_Data(p_list_line_id NUMBER,
                        p_data_creation_method VARCHAR2,
                        p_file_dir VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2);
END QP_Data_Compare_PVT;

 

/
