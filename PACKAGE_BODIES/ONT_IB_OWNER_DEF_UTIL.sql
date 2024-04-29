--------------------------------------------------------
--  DDL for Package Body ONT_IB_OWNER_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_IB_OWNER_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_IB_OWNER_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_IB_OWNER_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_IB_OWNER_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_AK_IB_OWNER_V';
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_IB_OWNER_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('IB_OWNER') THEN
  IF NVL(p_record.IB_OWNER, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.IB_OWNER;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_IB_OWNER_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('IB_OWNER') THEN
    IF NVL(p_record.IB_OWNER, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.IB_OWNER,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_IB_OWNER_Cache
  IS  
  BEGIN  
  g_cached_record.IB_OWNER := null;
   END Clear_IB_OWNER_Cache;
 
 
FUNCTION Sync_IB_OWNER_Cache
(   p_IB_OWNER                      IN  VARCHAR2
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_AK_IB_OWNER_V
  WHERE IB_OWNER  = p_IB_OWNER
  ;
BEGIN
 
IF (NVL(p_IB_OWNER,FND_API.G_MISS_CHAR)  = FND_API.G_MISS_CHAR) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.IB_OWNER,FND_API.G_MISS_CHAR)  <>  p_IB_OWNER) 
THEN
  Clear_IB_OWNER_Cache;
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
END Sync_IB_OWNER_Cache;
 
 
END ONT_IB_OWNER_Def_Util;

/
