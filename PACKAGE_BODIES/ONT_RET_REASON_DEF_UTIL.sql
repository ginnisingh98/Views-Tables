--------------------------------------------------------
--  DDL for Package Body ONT_RET_REASON_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_RET_REASON_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_RET_REASON_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_RET_REASON_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_RET_REASON_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_AK_RETURN_REASON_V';
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_RETURN_REASON_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('RETURN_REASON_CODE') THEN
  IF NVL(p_record.RETURN_REASON_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.RETURN_REASON_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_RETURN_REASON_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('RETURN_REASON_CODE') THEN
    IF NVL(p_record.RETURN_REASON_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.RETURN_REASON_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_RET_REASON_Cache
  IS  
  BEGIN  
  g_cached_record.RETURN_REASON_CODE := null;
   END Clear_RET_REASON_Cache;
 
 
FUNCTION Sync_RET_REASON_Cache
(   p_RETURN_REASON_CODE            IN  VARCHAR2
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_AK_RETURN_REASON_V
  WHERE RETURN_REASON_CODE  = p_RETURN_REASON_CODE
  ;
BEGIN
 
IF (NVL(p_RETURN_REASON_CODE,FND_API.G_MISS_CHAR)  = FND_API.G_MISS_CHAR) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.RETURN_REASON_CODE,FND_API.G_MISS_CHAR)  <>  p_RETURN_REASON_CODE) 
THEN
  Clear_RET_REASON_Cache;
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
END Sync_RET_REASON_Cache;
 
 
END ONT_RET_REASON_Def_Util;

/
