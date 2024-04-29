--------------------------------------------------------
--  DDL for Package ONT_HEADER_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_HEADER_DEF_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXRHDRS.pls 120.0 2005/05/31 23:02:23 appldev noship $ */

g_cached_record          OE_AK_ORDER_HEADERS_V%ROWTYPE;
g_attr_rules_cache       ONT_DEF_UTIL.Attr_Def_Rule_Tbl_Type;

FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
) RETURN VARCHAR2;

FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
) RETURN DATE;

FUNCTION Sync_HEADER_Cache
(   p_HEADER_ID                     IN  NUMBER
) RETURN NUMBER;

FUNCTION Get_Foreign_Attr_Val_Varchar2
(   p_foreign_attr_code             IN  VARCHAR2
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
,   p_foreign_database_object_name  IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION Get_Foreign_Attr_Val_Date
(   p_foreign_attr_code             IN  VARCHAR2
,   p_record                        IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
,   p_foreign_database_object_name  IN  VARCHAR2
) RETURN DATE;

PROCEDURE Clear_HEADER_Cache;

PROCEDURE Get_Valid_Defaulting_Rules
(   p_attr_code                     IN  VARCHAR2
,   p_attr_id                       IN  NUMBER
,   p_header_rec                    IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
, x_rules_start_index_tbl OUT NOCOPY OE_GLOBALS.NUMBER_TBL_Type

, x_rules_stop_index_tbl OUT NOCOPY OE_GLOBALS.NUMBER_TBL_Type

);

FUNCTION Validate_Defaulting_Condition
(   p_condition_id                  IN  NUMBER
,   p_header_rec                    IN  OE_AK_ORDER_HEADERS_V%ROWTYPE
) RETURN BOOLEAN;

END ONT_HEADER_Def_Util;

 

/
