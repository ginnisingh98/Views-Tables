--------------------------------------------------------
--  DDL for Package ONT_HEADER_PAYMENT_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_HEADER_PAYMENT_DEF_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_HEADER_PAYMENT_Def_Util
--  
--  DESCRIPTION
--  
--      Spec of package ONT_HEADER_PAYMENT_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
  g_cached_record          OE_AK_HEADER_PAYMENTS_V%ROWTYPE;
  g_attr_rules_cache         ONT_DEF_UTIL.Attr_Def_Rule_Tbl_Type;
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE 
) RETURN VARCHAR2;
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE 
) RETURN DATE;
 
FUNCTION Sync_HEADER_PAYMENT_Cache
(   p_PAYMENT_NUMBER                IN  NUMBER
,   p_HEADER_ID                     IN  NUMBER
,   p_LINE_ID                       IN  NUMBER
) RETURN NUMBER;
 
 
FUNCTION Get_Foreign_Attr_Val_Varchar2
(   p_foreign_attr_code             IN  VARCHAR2
,   p_record                        IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE 
,   p_foreign_database_object_name  IN  VARCHAR2
) RETURN VARCHAR2;
 
FUNCTION Get_Foreign_Attr_Val_Date
(   p_foreign_attr_code             IN  VARCHAR2
,   p_record                        IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE 
,   p_foreign_database_object_name  IN  VARCHAR2
) RETURN DATE;
 
PROCEDURE Clear_HEADER_PAYMENT_Cache;
 
PROCEDURE Get_Valid_Defaulting_Rules
(   p_attr_code                     IN  VARCHAR2
,   p_attr_id                       IN  NUMBER
,   p_header_payment_rec            IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE
,   x_rules_start_index_tbl         OUT OE_GLOBALS.NUMBER_TBL_Type
,   x_rules_stop_index_tbl          OUT OE_GLOBALS.NUMBER_TBL_Type
);
 
FUNCTION Validate_Defaulting_Condition
(   p_condition_id                  IN  NUMBER
,   p_header_payment_rec            IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE 
) RETURN BOOLEAN;
 
END ONT_HEADER_PAYMENT_Def_Util;

/
