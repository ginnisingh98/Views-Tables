--------------------------------------------------------
--  DDL for Package ONT_ARRIVAL_SET_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_ARRIVAL_SET_DEF_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_ARRIVAL_SET_Def_Util
--  
--  DESCRIPTION
--  
--      Spec of package ONT_ARRIVAL_SET_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
  g_cached_record          OE_AK_ARRIVAL_SETS_V%ROWTYPE;
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_ARRIVAL_SETS_V%ROWTYPE 
) RETURN VARCHAR2;
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_ARRIVAL_SETS_V%ROWTYPE 
) RETURN DATE;
 
FUNCTION Sync_ARRIVAL_SET_Cache
(   p_SET_ID                        IN  NUMBER
) RETURN NUMBER;
 
 
END ONT_ARRIVAL_SET_Def_Util;

/
