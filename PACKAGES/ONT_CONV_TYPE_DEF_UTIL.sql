--------------------------------------------------------
--  DDL for Package ONT_CONV_TYPE_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_CONV_TYPE_DEF_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_CONV_TYPE_Def_Util
--  
--  DESCRIPTION
--  
--      Spec of package ONT_CONV_TYPE_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
  g_cached_record          OE_AK_CONVERSION_TYPES_V%ROWTYPE;
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_CONVERSION_TYPES_V%ROWTYPE 
) RETURN VARCHAR2;
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_CONVERSION_TYPES_V%ROWTYPE 
) RETURN DATE;
 
FUNCTION Sync_CONV_TYPE_Cache
(   p_CONVERSION_TYPE_CODE          IN  VARCHAR2
) RETURN NUMBER;
 
 
END ONT_CONV_TYPE_Def_Util;

/
