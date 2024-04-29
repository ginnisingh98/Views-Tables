--------------------------------------------------------
--  DDL for Package Body ONT_TAX_EXEMPT_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_TAX_EXEMPT_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_TAX_EXEMPT_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_TAX_EXEMPT_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_TAX_EXEMPT_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_AK_TAX_EXEMPT_V';
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_TAX_EXEMPT_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('TAX_EXEMPT_FLAG') THEN
  IF NVL(p_record.TAX_EXEMPT_FLAG, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.TAX_EXEMPT_FLAG;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_TAX_EXEMPT_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('TAX_EXEMPT_FLAG') THEN
    IF NVL(p_record.TAX_EXEMPT_FLAG, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.TAX_EXEMPT_FLAG,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_TAX_EXEMPT_Cache
  IS  
  BEGIN  
  g_cached_record.TAX_EXEMPT_FLAG := null;
   END Clear_TAX_EXEMPT_Cache;
 
 
FUNCTION Sync_TAX_EXEMPT_Cache
(   p_TAX_EXEMPT_FLAG               IN  VARCHAR2
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_AK_TAX_EXEMPT_V
  WHERE TAX_EXEMPT_FLAG  = p_TAX_EXEMPT_FLAG
  ;
BEGIN
 
IF (NVL(p_TAX_EXEMPT_FLAG,FND_API.G_MISS_CHAR)  = FND_API.G_MISS_CHAR) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.TAX_EXEMPT_FLAG,FND_API.G_MISS_CHAR)  <>  p_TAX_EXEMPT_FLAG) 
THEN
  Clear_TAX_EXEMPT_Cache;
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
END Sync_TAX_EXEMPT_Cache;
 
 
END ONT_TAX_EXEMPT_Def_Util;

/
