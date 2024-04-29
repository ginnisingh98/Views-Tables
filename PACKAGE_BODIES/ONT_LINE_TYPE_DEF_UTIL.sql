--------------------------------------------------------
--  DDL for Package Body ONT_LINE_TYPE_DEF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_LINE_TYPE_DEF_UTIL" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_LINE_TYPE_Def_Util
--  
--  DESCRIPTION
--  
--      Body of package ONT_LINE_TYPE_Def_Util
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_LINE_TYPE_Def_Util';
 
 
  g_database_object_name varchar2(30) :='OE_AK_LINE_TYPES_V';
 
 
FUNCTION Get_Attr_Val_Varchar2
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_LINE_TYPES_V%ROWTYPE 
) RETURN VARCHAR2
IS
BEGIN
 
IF p_attr_code =('ACCOUNTING_CREDIT_METHOD_CODE') THEN
  IF NVL(p_record.ACCOUNTING_CREDIT_METHOD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ACCOUNTING_CREDIT_METHOD_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('ACCOUNTING_RULE_ID') THEN
  IF NVL(p_record.ACCOUNTING_RULE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.ACCOUNTING_RULE_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('AGREEMENT_TYPE_CODE') THEN
  IF NVL(p_record.AGREEMENT_TYPE_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.AGREEMENT_TYPE_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('DEMAND_CLASS_CODE') THEN
  IF NVL(p_record.DEMAND_CLASS_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.DEMAND_CLASS_CODE;
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
ELSIF p_attr_code =('INVOICING_CREDIT_METHOD_CODE') THEN
  IF NVL(p_record.INVOICING_CREDIT_METHOD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.INVOICING_CREDIT_METHOD_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('INVOICING_RULE_ID') THEN
  IF NVL(p_record.INVOICING_RULE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.INVOICING_RULE_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('LINE_TRXN_CATEGORY_CODE') THEN
  IF NVL(p_record.ORDER_CATEGORY_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.ORDER_CATEGORY_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('LINE_TYPE_ID') THEN
  IF NVL(p_record.LINE_TYPE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.LINE_TYPE_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('PRICE_LIST_ID') THEN
  IF NVL(p_record.PRICE_LIST_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.PRICE_LIST_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('SHIPMENT_PRIORITY_CODE') THEN
  IF NVL(p_record.SHIPMENT_PRIORITY_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.SHIPMENT_PRIORITY_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('SHIPPING_METHOD_CODE') THEN
  IF NVL(p_record.SHIPPING_METHOD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.SHIPPING_METHOD_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('SHIP_FROM_ORG_ID') THEN
  IF NVL(p_record.SHIP_FROM_ORG_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
  RETURN p_record.SHIP_FROM_ORG_ID;
  ELSE
  RETURN NULL; 
  END IF;
ELSIF p_attr_code =('SOURCE_TYPE_CODE') THEN
  IF NVL(p_record.SHIP_SOURCE_TYPE_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
  RETURN p_record.SHIP_SOURCE_TYPE_CODE;
  ELSE
  RETURN NULL; 
  END IF;
ELSE
RETURN NULL; 
END IF;
END  Get_Attr_Val_Varchar2;
 
 
FUNCTION Get_Attr_Val_Date
(   p_attr_code                     IN  VARCHAR2
,   p_record                        IN  OE_AK_LINE_TYPES_V%ROWTYPE 
) RETURN DATE
IS
BEGIN
 
IF p_attr_code =('ACCOUNTING_CREDIT_METHOD_CODE') THEN
    IF NVL(p_record.ACCOUNTING_CREDIT_METHOD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ACCOUNTING_CREDIT_METHOD_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('ACCOUNTING_RULE_ID') THEN
    IF NVL(p_record.ACCOUNTING_RULE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.ACCOUNTING_RULE_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('AGREEMENT_TYPE_CODE') THEN
    IF NVL(p_record.AGREEMENT_TYPE_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.AGREEMENT_TYPE_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('DEMAND_CLASS_CODE') THEN
    IF NVL(p_record.DEMAND_CLASS_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.DEMAND_CLASS_CODE,'RRRR/MM/DD HH24:MI:SS');
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
ELSIF p_attr_code =('INVOICING_CREDIT_METHOD_CODE') THEN
    IF NVL(p_record.INVOICING_CREDIT_METHOD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.INVOICING_CREDIT_METHOD_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('INVOICING_RULE_ID') THEN
    IF NVL(p_record.INVOICING_RULE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.INVOICING_RULE_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('LINE_TRXN_CATEGORY_CODE') THEN
    IF NVL(p_record.ORDER_CATEGORY_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.ORDER_CATEGORY_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('LINE_TYPE_ID') THEN
    IF NVL(p_record.LINE_TYPE_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.LINE_TYPE_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('PRICE_LIST_ID') THEN
    IF NVL(p_record.PRICE_LIST_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.PRICE_LIST_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('SHIPMENT_PRIORITY_CODE') THEN
    IF NVL(p_record.SHIPMENT_PRIORITY_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.SHIPMENT_PRIORITY_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('SHIPPING_METHOD_CODE') THEN
    IF NVL(p_record.SHIPPING_METHOD_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.SHIPPING_METHOD_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('SHIP_FROM_ORG_ID') THEN
    IF NVL(p_record.SHIP_FROM_ORG_ID, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
    RETURN to_date(p_record.SHIP_FROM_ORG_ID,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSIF p_attr_code =('SOURCE_TYPE_CODE') THEN
    IF NVL(p_record.SHIP_SOURCE_TYPE_CODE, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
    RETURN to_date(p_record.SHIP_SOURCE_TYPE_CODE,'RRRR/MM/DD HH24:MI:SS');
    ELSE
    RETURN NULL; 
    END IF;
ELSE
RETURN NULL; 
END IF;
 
END  Get_Attr_Val_Date;
 
 
  PROCEDURE Clear_LINE_TYPE_Cache
  IS  
  BEGIN  
  g_cached_record.LINE_TYPE_ID := null;
   END Clear_LINE_TYPE_Cache;
 
 
FUNCTION Sync_LINE_TYPE_Cache
(   p_LINE_TYPE_ID                  IN  NUMBER
 
 
) RETURN NUMBER
IS
CURSOR cache IS 
  SELECT * FROM   OE_AK_LINE_TYPES_V
  WHERE LINE_TYPE_ID  = p_LINE_TYPE_ID
  ;
BEGIN
 
IF (NVL(p_LINE_TYPE_ID,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM) 
THEN
  RETURN 0 ;
ELSIF (NVL(g_cached_record.LINE_TYPE_ID,FND_API.G_MISS_NUM)  <>  p_LINE_TYPE_ID) 
THEN
  Clear_LINE_TYPE_Cache;
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
END Sync_LINE_TYPE_Cache;
 
 
END ONT_LINE_TYPE_Def_Util;

/