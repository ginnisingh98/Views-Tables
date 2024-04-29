--------------------------------------------------------
--  DDL for Package Body ONT_PRICE_LIST_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_PRICE_LIST_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_PRICE_LIST_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_PRICE_LIST_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_PRICE_LIST_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_PRICE_LISTS_V';
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_PRICE_LISTS_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('FREIGHT_TERMS_CODE') THEN
  IF NVL(p_record.FREIGHT_TERMS_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.FREIGHT_TERMS_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PAYMENT_TERM_ID') THEN
  IF NVL(p_record.TERMS_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.TERMS_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PRICE_LIST_ID') THEN
  IF NVL(p_record.PRICE_LIST_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.PRICE_LIST_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('SHIPPING_METHOD_CODE') THEN
  IF NVL(p_record.SHIP_METHOD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.SHIP_METHOD_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('TRANSACTIONAL_CURR_CODE') THEN
  IF NVL(p_record.CURRENCY_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.CURRENCY_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_PRICE_LISTS_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('FREIGHT_TERMS_CODE') THEN
    IF NVL(p_record.FREIGHT_TERMS_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.FREIGHT_TERMS_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PAYMENT_TERM_ID') THEN
    IF NVL(p_record.TERMS_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.TERMS_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PRICE_LIST_ID') THEN
    IF NVL(p_record.PRICE_LIST_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.PRICE_LIST_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('SHIPPING_METHOD_CODE') THEN
    IF NVL(p_record.SHIP_METHOD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.SHIP_METHOD_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('TRANSACTIONAL_CURR_CODE') THEN
    IF NVL(p_record.CURRENCY_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.CURRENCY_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_PRICE_LIST_Cache
  IS  
  BEGIN  
  g_cached_record.PRICE_LIST_ID := null;
   END Clear_PRICE_LIST_Cache;
 
 
FUNCTION Sync_PRICE_LIST_Cache
(   p_PRICE_LIST_ID                 IN  NUMBER
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_PRICE_LISTS_V
  WHERE PRICE_LIST_ID  = p_PRICE_LIST_ID
  ;
BEGIN
 
IF (NVL(p_PRICE_LIST_ID,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.PRICE_LIST_ID,FND_API.G_MISS_NUM)  <>  p_PRICE_LIST_ID) 
THEN
  Clear_PRICE_LIST_Cache;
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
END Sync_PRICE_LIST_Cache;
 
 
END ONT_PRICE_LIST_Def_Util;

/
