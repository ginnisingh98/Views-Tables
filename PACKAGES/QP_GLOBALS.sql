--------------------------------------------------------
--  DDL for Package QP_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: QPXSGLBS.pls 120.4 2006/02/22 10:24:28 shulin ship $ */

--  Procedure Get_Entities_Tbl;
--
--  Used by generator to avoid overriding or duplicating existing
--  entity constants.
--
--  DO NOT MODIFY

PROCEDURE Get_Entities_Tbl;

--  Product entity constants.

--  START GEN entities
G_ENTITY_PRICE_LIST			 CONSTANT VARCHAR2(30) := 'PRICE_LIST';
G_ENTITY_PRICE_LIST_LINE		 CONSTANT VARCHAR2(30) := 'PRICE_LIST_LINE';
G_ENTITY_ALL                   CONSTANT VARCHAR2(30) := 'ALL';
G_ENTITY_MODIFIER_LIST         CONSTANT VARCHAR2(30) := 'MODIFIER_LIST';
G_ENTITY_MODIFIERS             CONSTANT VARCHAR2(30) := 'MODIFIERS';
G_ENTITY_QUALIFIERS            CONSTANT VARCHAR2(30) := 'QUALIFIERS';
G_ENTITY_PRICING_ATTR          CONSTANT VARCHAR2(30) := 'PRICING_ATTR';
G_ENTITY_QUALIFIER_RULES       CONSTANT VARCHAR2(30) := 'QUALIFIER_RULES';
G_ENTITY_LINE_PRICING_PATTR    CONSTANT VARCHAR2(30) := 'LINE_PRICING_PATTR';
G_ENTITY_FORMULA               CONSTANT VARCHAR2(30) := 'FORMULA';
G_ENTITY_FORMULA_LINES         CONSTANT VARCHAR2(30) := 'FORMULA_LINES';
G_ENTITY_LIMITS                CONSTANT VARCHAR2(30) := 'LIMITS';
G_ENTITY_LIMIT_ATTRS           CONSTANT VARCHAR2(30) := 'LIMIT_ATTRS';
G_ENTITY_LIMIT_BALANCES        CONSTANT VARCHAR2(30) := 'LIMIT_BALANCES';
G_ENTITY_CURR_LISTS            CONSTANT VARCHAR2(30) := 'CURR_LISTS';
G_ENTITY_CURR_DETAILS          CONSTANT VARCHAR2(30) := 'CURR_DETAILS';
G_ENTITY_CON                   CONSTANT VARCHAR2(30) := 'CON';
G_ENTITY_SEG                   CONSTANT VARCHAR2(30) := 'SEG';
G_ENTITY_PTE                   CONSTANT VARCHAR2(30) := 'PTE';
G_ENTITY_RQT                   CONSTANT VARCHAR2(30) := 'RQT';
G_ENTITY_SSC                   CONSTANT VARCHAR2(30) := 'SSC';
G_ENTITY_PSG                   CONSTANT VARCHAR2(30) := 'PSG';
G_ENTITY_SOU                   CONSTANT VARCHAR2(30) := 'SOU';
G_ENTITY_BSO                   CONSTANT VARCHAR2(30) := 'BSO'; --Bug#3385041
G_ENTITY_FNA                   CONSTANT VARCHAR2(30) := 'FNA';
--  END GEN entities

--  Operations.

G_OPR_CREATE	    CONSTANT	VARCHAR2(30) := 'CREATE';
G_OPR_UPDATE	    CONSTANT	VARCHAR2(30) := 'UPDATE';
G_OPR_DELETE	    CONSTANT	VARCHAR2(30) := 'DELETE';
G_OPR_LOCK	    CONSTANT	VARCHAR2(30) := 'LOCK';
G_OPR_NONE	    CONSTANT	VARCHAR2(30) := FND_API.G_MISS_CHAR;

--Maintaining list header phases

G_MAINTAIN_LIST_HEADER_PHASES  CONSTANT Varchar2(30)  := 'MAINTAIN_LIST_HEADER_PHASES';

--Delayed Request Types
-- start bug2091362
G_DUPLICATE_MODIFIER_LINES CONSTANT Varchar2(30) := 'DUPLICATE_MODIFIER_LINES';
-- end bug2091362

G_DUPLICATE_QUALIFIERS CONSTANT Varchar2(30)  := 'DUPLICATE_QUALIFIERS';
G_DUPLICATE_LIST_LINES CONSTANT Varchar2(30)  := 'DUPLICATE_LIST_LINES';
G_UPDATE_CHILD_BREAKS  CONSTANT Varchar2(30)  := 'UPDATE_CHILD_BREAK_LINES';
G_UPDATE_CHILD_PRICING_ATTR  CONSTANT Varchar2(30)  := 'UPDATE_CHILD_PRICING_ATTR';
G_VALIDATE_LINES_FOR_CHILD CONSTANT Varchar2(30)  := 'VALIDATE_LINES_FOR_CHILD';
G_OVERLAPPING_PRICE_BREAKS CONSTANT Varchar2(30)  := 'OVERLAPPING_BREAKS';
G_SINGLE_PRICE_LIST CONSTANT Varchar2(30)  := 'SINGLE_PRICE_LIST';
G_UPDATE_LIST_QUAL_IND CONSTANT Varchar2(30) := 'UPDATE_LIST_QUALIFICATION_IND';
G_UPDATE_LINE_QUAL_IND CONSTANT Varchar2(30) := 'UPDATE_LINE_QUALIFICATION_IND';
G_UPDATE_PRICING_ATTR_PHASE CONSTANT Varchar2(30) := 'UPDATE_PRICING_ATTR_PHASE';
G_UPDATE_PRICING_PHASE CONSTANT Varchar2(30) := 'UPDATE_PRICING_PHASE';
G_WARN_SAME_QUALIFIER_GROUP CONSTANT Varchar2(30) := 'WARN_SAME_QUALIFIER_GROUP';
G_MAINTAIN_QUALIFIER_DEN_COLS Varchar2(30) := 'MAINTAIN_QUALIFIER_DEN_COLS';
G_MULTIPLE_PRICE_BREAK_ATTRS CONSTANT Varchar2(30) := 'MULTIPLE_PRICE_BREAK_ATTRS';
G_MIXED_QUAL_SEG_LEVELS CONSTANT Varchar2(30) := 'MIXED_QUAL_SEG_LEVELS';
G_UPDATE_LIMITS_COLUMNS CONSTANT Varchar2(30) := 'UPDATE_LIMITS_COLUMNS';
G_MAINTAIN_FACTOR_LIST_ATTRS Varchar2(30) := 'MAINTAIN_FACTOR_LIST_ATTRS';
G_VALIDATE_SELLING_ROUNDING Varchar2(30) := 'VALIDATE_SELLING_ROUNDING';
G_CHECK_SEGMENT_LEVEL_IN_GROUP Varchar2(30) := 'CHECK_SEGMENT_LEVEL_IN_GROUP';
G_CHECK_LINE_FOR_HEADER_QUAL Varchar2(30) := 'CHECK_LINE_FOR_HEADER_QUAL';
--hw
G_UPDATE_CHANGED_LINES_ADD varchar2(30) := 'UPDATE_CHANGED_LINES_ADD';
G_UPDATE_CHANGED_LINES_DEL varchar2(30) := 'UPDATE_CHANGED_LINES_DEL';
G_UPDATE_CHANGED_LINES_PH varchar2(30) := 'UPDATE_CHANGED_LINES_PHASE';
G_UPDATE_CHANGED_LINES_ACT varchar2(30) := 'UPDATE_CHANGED_LINES_ACTIVE';
-- New Delayed Request Types added for 11.5.10
G_UPDATE_QUALIFIER_STATUS varchar2(30) := 'UPDATE_QUALIFIER_STATUS';
G_UPDATE_ATTRIBUTE_STATUS varchar2(30) := 'UPDATE_ATTRIBUTE_STATUS';
G_CREATE_SECURITY_PRIVILEGE varchar2(30) := 'CREATE_SECURITY_PRIVILEGE';
-- Essilor Fix bug 2789138
G_UPDATE_MANUAL_MODIFIER_FLAG CONSTANT Varchar2(30) := 'UPDATE_MANUAL_MODIFIER_FLAG';
G_UPDATE_HVOP CONSTANT varchar2(30) := 'UPDATE_HVOP_PROFILE';
--Delayed request
G_MAINTAIN_HEADER_PATTERN varchar2(30)  := 'MAINTAIN_HEADER_PATTERN';
G_MAINTAIN_LINE_PATTERN varchar2(30)    := 'MAINTAIN_LINE_PATTERN';
G_MAINTAIN_PRODUCT_PATTERN varchar2(30) := 'MAINTAIN_PRODUCT_PATTERN';
--Delayed request
G_CHECK_ENABLED_FUNC_AREAS VARCHAR2(30) := 'CHECK_ENABLED_FUNC_AREAS';

--Delayed request for upgrading price beaks
G_UPGRADE_PRICE_BREAKS VARCHAR2(30) := 'UPGRADE_PRICE_BREAKS';

--  Max number of defaulting tterations.

G_MAX_DEF_ITERATIONS          CONSTANT NUMBER:= 5;

-- for bug 3531890
G_SPECIAL_ATTRIBUTE_TYPE varchar2(30) := 'ENGINE';
G_SPECIAL_CONTEXT varchar2(30) := 'GLOBAL_VARIABLES';
G_SPECIAL_ATTRIBUTE1 varchar2(30) := 'STEP_NUMBER';
--4949185, 5018856, 5024801, 5024919
G_CHECK_DUP_PRICELIST_LINES varchar2(1) := NULL;

--  Index table type used by JVC controllers.

TYPE Index_Tbl_Type IS TABLE OF BINARY_INTEGER
    INDEX BY BINARY_INTEGER;

--  API Operation control flags.

TYPE Control_Rec_Type IS RECORD
(   controlled_operation          BOOLEAN := FALSE
,   default_attributes            BOOLEAN := TRUE
,   check_security                BOOLEAN := TRUE
,   change_attributes             BOOLEAN := TRUE
,   validate_entity               BOOLEAN := TRUE
,   write_to_db                   BOOLEAN := TRUE
,   process                       BOOLEAN := TRUE
,   process_entity                VARCHAR2(30) := G_ENTITY_ALL
,   clear_api_cache               BOOLEAN := TRUE
,   clear_api_requests            BOOLEAN := TRUE
,   request_category              VARCHAR2(30):= NULL
,   request_name                  VARCHAR2(30):= NULL
,   called_from_ui                VARCHAR2(1) := 'Y'
);

--  Variable representing missing control record.

G_MISS_CONTROL_REC            Control_Rec_Type;

--  API request record type.

TYPE Request_Rec_Type IS RECORD
(   entity                        VARCHAR2(30) := NULL
,   step                          VARCHAR2(30) := NULL
,   name                          VARCHAR2(30) := NULL
,   category                      VARCHAR2(30) := NULL
,   processed                     BOOLEAN := FALSE
,   attribute1                    VARCHAR2(240) := NULL
,   attribute2                    VARCHAR2(240) := NULL
,   attribute3                    VARCHAR2(240) := NULL
,   attribute4                    VARCHAR2(240) := NULL
,   attribute5                    VARCHAR2(240) := NULL
);

--  API Request table type.

TYPE Request_Tbl_Type IS TABLE OF Request_Rec_Type
    INDEX BY BINARY_INTEGER;

TYPE Number_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

-- Variable representing a missing table
G_MISS_NUMBER_TBL  Number_Tbl_Type;

--  Initialize control record.

FUNCTION Init_Control_Rec
(   p_operation                     IN  VARCHAR2
,   p_control_rec                   IN  Control_Rec_Type
)RETURN Control_Rec_Type;

--  Function Equal
--  Number comparison.

FUNCTION Equal
(   p_attribute1                    IN  NUMBER
,   p_attribute2                    IN  NUMBER
)RETURN BOOLEAN;

--  Varchar2 comparison.

FUNCTION Equal
(   p_attribute1                    IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
)RETURN BOOLEAN;

--  Date comparison.

FUNCTION Equal
(   p_attribute1                    IN  DATE
,   p_attribute2                    IN  DATE
)RETURN BOOLEAN;

END QP_Globals;

 

/
