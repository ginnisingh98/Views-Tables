--------------------------------------------------------
--  DDL for Package Body ONT_SHIP_METHOD_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_SHIP_METHOD_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_SHIP_METHOD_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_SHIP_METHOD_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_SHIP_METHOD_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_AK_SHIPPING_METHOD_V';
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_SHIPPING_METHOD_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('SHIPPING_METHOD_CODE') THEN
  IF NVL(p_record.SHIPPING_METHOD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.SHIPPING_METHOD_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_SHIPPING_METHOD_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('SHIPPING_METHOD_CODE') THEN
    IF NVL(p_record.SHIPPING_METHOD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.SHIPPING_METHOD_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_SHIP_METHOD_Cache
  IS  
  BEGIN  
  g_cached_record.SHIPPING_METHOD_CODE := null;
   END Clear_SHIP_METHOD_Cache;
 
 
FUNCTION Sync_SHIP_METHOD_Cache
(   p_SHIPPING_METHOD_CODE          IN  VARCHAR2
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_AK_SHIPPING_METHOD_V
  WHERE SHIPPING_METHOD_CODE  = p_SHIPPING_METHOD_CODE
  ;
BEGIN
 
IF (NVL(p_SHIPPING_METHOD_CODE,FND_API.G_MISS_CHAR)  = FND_API.G_MISS_CHAR) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.SHIPPING_METHOD_CODE,FND_API.G_MISS_CHAR)  <>  p_SHIPPING_METHOD_CODE) 
THEN
  Clear_SHIP_METHOD_Cache;
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
END Sync_SHIP_METHOD_Cache;
 
 
END ONT_SHIP_METHOD_Def_Util;

/
