--------------------------------------------------------
--  DDL for Package Body ONT_SALESREP_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_SALESREP_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_SALESREP_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_SALESREP_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_SALESREP_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_AK_SALESREPS_V';
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_SALESREPS_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('NAME') THEN
  IF NVL(p_record.NAME, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.NAME;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('SALESREP_ID') THEN
  IF NVL(p_record.SALESREP_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.SALESREP_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_SALESREPS_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('NAME') THEN
    IF NVL(p_record.NAME, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.NAME,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('SALESREP_ID') THEN
    IF NVL(p_record.SALESREP_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.SALESREP_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_SALESREP_Cache
  IS  
  BEGIN  
  g_cached_record.SALESREP_ID := null;
   END Clear_SALESREP_Cache;
 
 
FUNCTION Sync_SALESREP_Cache
(   p_SALESREP_ID                   IN  NUMBER
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_AK_SALESREPS_V
  WHERE SALESREP_ID  = p_SALESREP_ID
  ;
BEGIN
 
IF (NVL(p_SALESREP_ID,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.SALESREP_ID,FND_API.G_MISS_NUM)  <>  p_SALESREP_ID) 
THEN
  Clear_SALESREP_Cache;
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
END Sync_SALESREP_Cache;
 
 
END ONT_SALESREP_Def_Util;

/
