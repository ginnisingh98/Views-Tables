--------------------------------------------------------
--  DDL for Package Body ONT_PACK_INST_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_PACK_INST_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_PACK_INST_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_PACK_INST_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_PACK_INST_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_AK_PACK_INST_V';
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_PACK_INST_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('PACKING_INSTRUCTIONS') THEN
  IF NVL(p_record.PACKING_INSTRUCTIONS, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.PACKING_INSTRUCTIONS;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_PACK_INST_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('PACKING_INSTRUCTIONS') THEN
    IF NVL(p_record.PACKING_INSTRUCTIONS, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.PACKING_INSTRUCTIONS,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_PACK_INST_Cache
  IS  
  BEGIN  
  g_cached_record.PACKING_INSTRUCTIONS := null;
   END Clear_PACK_INST_Cache;
 
 
FUNCTION Sync_PACK_INST_Cache
(   p_PACKING_INSTRUCTIONS          IN  VARCHAR2
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_AK_PACK_INST_V
  WHERE PACKING_INSTRUCTIONS  = p_PACKING_INSTRUCTIONS
  ;
BEGIN
 
IF (NVL(p_PACKING_INSTRUCTIONS,FND_API.G_MISS_CHAR)  = FND_API.G_MISS_CHAR) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.PACKING_INSTRUCTIONS,FND_API.G_MISS_CHAR)  <>  p_PACKING_INSTRUCTIONS) 
THEN
  Clear_PACK_INST_Cache;
  Open cache;
  FETCH cache into g_cached_record;
  IF cache%NOTFOUND THEN
    RETURN 0;
  END IF;
  Close cache;
  RETURN 1 ;
END IF;
 
  RETURN 1 ;
EXCEPTION
  WHEN OTHERS THEN 
  RETURN 0 ;
END Sync_PACK_INST_Cache;
 
 
END ONT_PACK_INST_Def_Util;

/
