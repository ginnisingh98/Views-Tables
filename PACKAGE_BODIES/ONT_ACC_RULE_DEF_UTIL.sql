--------------------------------------------------------
--  DDL for Package Body ONT_ACC_RULE_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_ACC_RULE_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_ACC_RULE_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_ACC_RULE_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_ACC_RULE_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_AK_ACC_RULES_V';
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_ACC_RULES_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('ACCOUNTING_RULE_ID') THEN
  IF NVL(p_record.ACCOUNTING_RULE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.ACCOUNTING_RULE_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_ACC_RULES_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('ACCOUNTING_RULE_ID') THEN
    IF NVL(p_record.ACCOUNTING_RULE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.ACCOUNTING_RULE_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_ACC_RULE_Cache
  IS  
  BEGIN  
  g_cached_record.ACCOUNTING_RULE_ID := null;
   END Clear_ACC_RULE_Cache;
 
 
FUNCTION Sync_ACC_RULE_Cache
(   p_ACCOUNTING_RULE_ID            IN  NUMBER
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_AK_ACC_RULES_V
  WHERE ACCOUNTING_RULE_ID  = p_ACCOUNTING_RULE_ID
  ;
BEGIN
 
IF (NVL(p_ACCOUNTING_RULE_ID,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.ACCOUNTING_RULE_ID,FND_API.G_MISS_NUM)  <>  p_ACCOUNTING_RULE_ID) 
THEN
  Clear_ACC_RULE_Cache;
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
END Sync_ACC_RULE_Cache;
 
 
END ONT_ACC_RULE_Def_Util;

/
