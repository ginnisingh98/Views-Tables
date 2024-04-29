--------------------------------------------------------
--  DDL for Package ONT_LINE_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_LINE_DEF_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXRLINS.pls 120.0 2005/06/01 00:11:40 appldev noship $ */

g_cached_record          OE_AK_ORDER_LINES_V%ROWTYPE;
g_attr_rules_cache 	     ONT_DEF_UTIL.Attr_Def_Rule_Tbl_Type;

FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
) RETURN VARCHAR2;

FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
) RETURN DATE;

FUNCTION Sync_LINE_Cache
(   p_LINE_ID                       IN  NUMBER
) RETURN NUMBER;

FUNCTION Get_Foreign_Attr_Val_Varchar2
(   p_foreign_attr_code             IN  VARCHAR2
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   p_foreign_database_object_name  IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Get_Foreign_Attr_Val_Date
(   p_foreign_attr_code             IN  VARCHAR2
,   p_record                        IN  OE_AK_ORDER_LINES_V%ROWTYPE
,   p_foreign_database_object_name  IN  VARCHAR2
) RETURN DATE;

PROCEDURE Clear_LINE_Cache;

PROCEDURE Get_Valid_Defaulting_Rules
(   p_attr_code                     IN  VARCHAR2
,   p_attr_id                       IN  NUMBER
,   p_line_rec                      IN  OE_AK_ORDER_LINES_V%ROWTYPE
, x_rules_start_index_tbl OUT NOCOPY OE_GLOBALS.NUMBER_TBL_Type

, x_rules_stop_index_tbl OUT NOCOPY OE_GLOBALS.NUMBER_TBL_Type

);

FUNCTION Validate_Defaulting_Condition
(   p_condition_id                  IN  NUMBER
,   p_line_rec                      IN  OE_AK_ORDER_LINES_V%ROWTYPE
) RETURN BOOLEAN;

END ONT_LINE_Def_Util;

 

/
