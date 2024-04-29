--------------------------------------------------------
--  DDL for Package Body ONT_LAT_SCH_LIMIT_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_LAT_SCH_LIMIT_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_LAT_SCH_LIMIT_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_LAT_SCH_LIMIT_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_LAT_SCH_LIMIT_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_AK_LAT_SCH_LIMIT_V';
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_LAT_SCH_LIMIT_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('LATEST_SCHEDULE_LIMIT') THEN
  IF NVL(p_record.LATEST_SCHEDULE_LIMIT, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.LATEST_SCHEDULE_LIMIT;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_LAT_SCH_LIMIT_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('LATEST_SCHEDULE_LIMIT') THEN
    IF NVL(p_record.LATEST_SCHEDULE_LIMIT, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.LATEST_SCHEDULE_LIMIT,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_LAT_SCH_LIMIT_Cache
  IS  
  BEGIN  
  g_cached_record.LATEST_SCHEDULE_LIMIT := null;
   END Clear_LAT_SCH_LIMIT_Cache;
 
 
FUNCTION Sync_LAT_SCH_LIMIT_Cache
(   p_LATEST_SCHEDULE_LIMIT         IN  NUMBER
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_AK_LAT_SCH_LIMIT_V
  WHERE LATEST_SCHEDULE_LIMIT  = p_LATEST_SCHEDULE_LIMIT
  ;
BEGIN
 
IF (NVL(p_LATEST_SCHEDULE_LIMIT,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.LATEST_SCHEDULE_LIMIT,FND_API.G_MISS_NUM)  <>  p_LATEST_SCHEDULE_LIMIT) 
THEN
  Clear_LAT_SCH_LIMIT_Cache;
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
END Sync_LAT_SCH_LIMIT_Cache;
 
 
END ONT_LAT_SCH_LIMIT_Def_Util;

/
