--------------------------------------------------------
--  DDL for Package Body ONT_D2_SHIP_TOLERANCE_BELOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D2_SHIP_TOLERANCE_BELOW" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D2_SHIP_TOLERANCE_BELOW
--  
--  DESCRIPTION
--  
--      Body of package ONT_D2_SHIP_TOLERANCE_BELOW
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D2_SHIP_TOLERANCE_BELOW';
 
 
FUNCTION Get_Default_Value(p_line_rec IN  OE_AK_ORDER_LINES_V%ROWTYPE 
  ) RETURN NUMBER IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    IF (p_line_rec.LINE_CATEGORY_CODE = 'RETURN'
        ) THEN
    l_rule_id := 110;
    IF ONT_ITEM_SHIPTO_Def_Util.Sync_ITEM_SHIPTO_Cache
    (p_CUSTOMER_ID => p_line_rec.SHIP_TO_ORG_ID
    ,p_INTERNAL_ITEM_ID => p_line_rec.INVENTORY_ITEM_ID
    ) = 1 THEN
    l_return_value := ONT_ITEM_SHIPTO_Def_Util.g_cached_record.UNDER_RETURN_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 111;
    IF ONT_ITEM_BILLTO_Def_Util.Sync_ITEM_BILLTO_Cache
    (p_CUSTOMER_ID => p_line_rec.INVOICE_TO_ORG_ID
    ,p_INTERNAL_ITEM_ID => p_line_rec.INVENTORY_ITEM_ID
    ) = 1 THEN
    l_return_value := ONT_ITEM_BILLTO_Def_Util.g_cached_record.UNDER_RETURN_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 112;
    IF ONT_TOL_CUST_ITEM_Def_Util.Sync_TOL_CUST_ITEM_Cache
    (p_CUSTOMER_ID => p_line_rec.SOLD_TO_ORG_ID
    ,p_INTERNAL_ITEM_ID => p_line_rec.INVENTORY_ITEM_ID
    ) = 1 THEN
    l_return_value := ONT_TOL_CUST_ITEM_Def_Util.g_cached_record.UNDER_RETURN_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 215;
    IF ONT_SHIP_TO_ORG_Def_Util.Sync_SHIP_TO_ORG_Cache
    (p_ORGANIZATION_ID => p_line_rec.SHIP_TO_ORG_ID
    ) = 1 THEN
    l_return_value := ONT_SHIP_TO_ORG_Def_Util.g_cached_record.UNDER_RETURN_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 216;
    IF ONT_INV_ORG_Def_Util.Sync_INV_ORG_Cache
    (p_ORGANIZATION_ID => p_line_rec.INVOICE_TO_ORG_ID
    ) = 1 THEN
    l_return_value := ONT_INV_ORG_Def_Util.g_cached_record.UNDER_RETURN_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 217;
    IF ONT_SOLD_TO_ORG_Def_Util.Sync_SOLD_TO_ORG_Cache
    (p_ORGANIZATION_ID => p_line_rec.SOLD_TO_ORG_ID
    ,p_ORG_ID => p_line_rec.ORG_ID
    ) = 1 THEN
    l_return_value := ONT_SOLD_TO_ORG_Def_Util.g_cached_record.UNDER_RETURN_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 113;
    IF ONT_ITEM_Def_Util.Sync_ITEM_Cache
    (p_INVENTORY_ITEM_ID => p_line_rec.INVENTORY_ITEM_ID
    ,p_ORGANIZATION_ID => REPLACE(nvl(p_line_rec.SHIP_FROM_ORG_ID,FND_API.G_MISS_NUM),FND_API.G_MISS_NUM,OE_SYS_Parameters.Value('MASTER_ORGANIZATION_ID'))
    ) = 1 THEN
    l_return_value := ONT_ITEM_Def_Util.g_cached_record.UNDER_RETURN_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 58;
    l_return_value := fnd_number.canonical_to_number
      (FND_PROFILE.VALUE('OM_UNDER_RETURN_TOLERANCE')); 
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
  END IF;
 
    l_rule_id := 114;
    IF ONT_ITEM_SHIPTO_Def_Util.Sync_ITEM_SHIPTO_Cache
    (p_CUSTOMER_ID => p_line_rec.SHIP_TO_ORG_ID
    ,p_INTERNAL_ITEM_ID => p_line_rec.INVENTORY_ITEM_ID
    ) = 1 THEN
    l_return_value := ONT_ITEM_SHIPTO_Def_Util.g_cached_record.UNDER_SHIPMENT_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 115;
    IF ONT_ITEM_BILLTO_Def_Util.Sync_ITEM_BILLTO_Cache
    (p_CUSTOMER_ID => p_line_rec.INVOICE_TO_ORG_ID
    ,p_INTERNAL_ITEM_ID => p_line_rec.INVENTORY_ITEM_ID
    ) = 1 THEN
    l_return_value := ONT_ITEM_BILLTO_Def_Util.g_cached_record.UNDER_SHIPMENT_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 116;
    IF ONT_TOL_CUST_ITEM_Def_Util.Sync_TOL_CUST_ITEM_Cache
    (p_CUSTOMER_ID => p_line_rec.SOLD_TO_ORG_ID
    ,p_INTERNAL_ITEM_ID => p_line_rec.INVENTORY_ITEM_ID
    ) = 1 THEN
    l_return_value := ONT_TOL_CUST_ITEM_Def_Util.g_cached_record.UNDER_SHIPMENT_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 218;
    IF ONT_SHIP_TO_ORG_Def_Util.Sync_SHIP_TO_ORG_Cache
    (p_ORGANIZATION_ID => p_line_rec.SHIP_TO_ORG_ID
    ) = 1 THEN
    l_return_value := ONT_SHIP_TO_ORG_Def_Util.g_cached_record.UNDER_SHIPMENT_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 219;
    IF ONT_INV_ORG_Def_Util.Sync_INV_ORG_Cache
    (p_ORGANIZATION_ID => p_line_rec.INVOICE_TO_ORG_ID
    ) = 1 THEN
    l_return_value := ONT_INV_ORG_Def_Util.g_cached_record.UNDER_SHIPMENT_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 220;
    IF ONT_SOLD_TO_ORG_Def_Util.Sync_SOLD_TO_ORG_Cache
    (p_ORGANIZATION_ID => p_line_rec.SOLD_TO_ORG_ID
    ,p_ORG_ID => p_line_rec.ORG_ID
    ) = 1 THEN
    l_return_value := ONT_SOLD_TO_ORG_Def_Util.g_cached_record.UNDER_SHIPMENT_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 96;
    IF ONT_ITEM_Def_Util.Sync_ITEM_Cache
    (p_INVENTORY_ITEM_ID => p_line_rec.INVENTORY_ITEM_ID
    ,p_ORGANIZATION_ID => REPLACE(nvl(p_line_rec.SHIP_FROM_ORG_ID,FND_API.G_MISS_NUM),FND_API.G_MISS_NUM,OE_SYS_Parameters.Value('MASTER_ORGANIZATION_ID'))
    ) = 1 THEN
    l_return_value := ONT_ITEM_Def_Util.g_cached_record.UNDER_SHIPMENT_TOLERANCE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 59;
    l_return_value := fnd_number.canonical_to_number
      (FND_PROFILE.VALUE('OM_UNDER_SHIPMENT_TOLERANCE')); 
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'SHIP_TOLERANCE_BELOW'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D2_SHIP_TOLERANCE_BELOW;

/
