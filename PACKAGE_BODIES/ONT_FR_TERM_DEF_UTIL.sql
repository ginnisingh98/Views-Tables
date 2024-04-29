--------------------------------------------------------
--  DDL for Package Body ONT_FR_TERM_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_FR_TERM_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_FR_TERM_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_FR_TERM_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_FR_TERM_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_AK_FREIGHT_TERMS_V';
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_FREIGHT_TERMS_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('FREIGHT_TERMS_CODE') THEN
  IF NVL(p_record.FREIGHT_TERMS_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.FREIGHT_TERMS_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_FREIGHT_TERMS_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('FREIGHT_TERMS_CODE') THEN
    IF NVL(p_record.FREIGHT_TERMS_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.FREIGHT_TERMS_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_FR_TERM_Cache
  IS  
  BEGIN  
  g_cached_record.FREIGHT_TERMS_CODE := null;
   END Clear_FR_TERM_Cache;
 
 
FUNCTION Sync_FR_TERM_Cache
(   p_FREIGHT_TERMS_CODE            IN  VARCHAR2
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_AK_FREIGHT_TERMS_V
  WHERE FREIGHT_TERMS_CODE  = p_FREIGHT_TERMS_CODE
  ;
BEGIN
 
IF (NVL(p_FREIGHT_TERMS_CODE,FND_API.G_MISS_CHAR)  = FND_API.G_MISS_CHAR) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.FREIGHT_TERMS_CODE,FND_API.G_MISS_CHAR)  <>  p_FREIGHT_TERMS_CODE) 
THEN
  Clear_FR_TERM_Cache;
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
END Sync_FR_TERM_Cache;
 
 
END ONT_FR_TERM_Def_Util;

/
