--------------------------------------------------------
--  DDL for Package Body ONT_SOLD_TO_SU_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_SOLD_TO_SU_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_SOLD_TO_SU_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_SOLD_TO_SU_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_SOLD_TO_SU_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_AK_SOLD_TO_SITE_USES_V';
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_SOLD_TO_SITE_USES_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('CONTACT_ID') THEN
  IF NVL(p_record.CONTACT_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.CONTACT_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('FOB_POINT_CODE') THEN
  IF NVL(p_record.FOB_POINT_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.FOB_POINT_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('FREIGHT_TERMS_CODE') THEN
  IF NVL(p_record.FREIGHT_TERMS_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.FREIGHT_TERMS_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ORDER_TYPE_ID') THEN
  IF NVL(p_record.ORDER_TYPE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.ORDER_TYPE_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('OVER_SHIPMENT_TOLERANCE') THEN
  IF NVL(p_record.OVER_SHIPMENT_TOLERANCE, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.OVER_SHIPMENT_TOLERANCE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PAYMENT_TERM_ID') THEN
  IF NVL(p_record.PAYMENT_TERM_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.PAYMENT_TERM_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PRICE_LIST_ID') THEN
  IF NVL(p_record.PRICE_LIST_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.PRICE_LIST_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('SALESREP_ID') THEN
  IF NVL(p_record.SALESREP_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.SALESREP_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('SHIPPING_METHOD_CODE') THEN
  IF NVL(p_record.SHIPPING_METHOD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.SHIPPING_METHOD_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('SOLD_TO_SITE_USE_ID') THEN
  IF NVL(p_record.SOLD_TO_SITE_USE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.SOLD_TO_SITE_USE_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('UNDER_SHIPMENT_TOLERANCE') THEN
  IF NVL(p_record.UNDER_SHIPMENT_TOLERANCE, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.UNDER_SHIPMENT_TOLERANCE;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_SOLD_TO_SITE_USES_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('CONTACT_ID') THEN
    IF NVL(p_record.CONTACT_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.CONTACT_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('FOB_POINT_CODE') THEN
    IF NVL(p_record.FOB_POINT_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.FOB_POINT_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('FREIGHT_TERMS_CODE') THEN
    IF NVL(p_record.FREIGHT_TERMS_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.FREIGHT_TERMS_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ORDER_TYPE_ID') THEN
    IF NVL(p_record.ORDER_TYPE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.ORDER_TYPE_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('OVER_SHIPMENT_TOLERANCE') THEN
    IF NVL(p_record.OVER_SHIPMENT_TOLERANCE, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.OVER_SHIPMENT_TOLERANCE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PAYMENT_TERM_ID') THEN
    IF NVL(p_record.PAYMENT_TERM_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.PAYMENT_TERM_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PRICE_LIST_ID') THEN
    IF NVL(p_record.PRICE_LIST_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.PRICE_LIST_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('SALESREP_ID') THEN
    IF NVL(p_record.SALESREP_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.SALESREP_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('SHIPPING_METHOD_CODE') THEN
    IF NVL(p_record.SHIPPING_METHOD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.SHIPPING_METHOD_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('SOLD_TO_SITE_USE_ID') THEN
    IF NVL(p_record.SOLD_TO_SITE_USE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.SOLD_TO_SITE_USE_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('UNDER_SHIPMENT_TOLERANCE') THEN
    IF NVL(p_record.UNDER_SHIPMENT_TOLERANCE, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.UNDER_SHIPMENT_TOLERANCE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_SOLD_TO_SU_Cache
  IS  
  BEGIN  
  g_cached_record.SOLD_TO_SITE_USE_ID := null;
   END Clear_SOLD_TO_SU_Cache;
 
 
FUNCTION Sync_SOLD_TO_SU_Cache
(   p_SOLD_TO_SITE_USE_ID           IN  NUMBER
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_AK_SOLD_TO_SITE_USES_V
  WHERE SOLD_TO_SITE_USE_ID  = p_SOLD_TO_SITE_USE_ID
  ;
BEGIN
 
IF (NVL(p_SOLD_TO_SITE_USE_ID,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.SOLD_TO_SITE_USE_ID,FND_API.G_MISS_NUM)  <>  p_SOLD_TO_SITE_USE_ID) 
THEN
  Clear_SOLD_TO_SU_Cache;
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
END Sync_SOLD_TO_SU_Cache;
 
 
END ONT_SOLD_TO_SU_Def_Util;

/
