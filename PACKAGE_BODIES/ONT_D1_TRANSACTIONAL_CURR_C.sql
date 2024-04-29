--------------------------------------------------------
--  DDL for Package Body ONT_D1_TRANSACTIONAL_CURR_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D1_TRANSACTIONAL_CURR_C" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D1_TRANSACTIONAL_CURR_C
--  
--  DESCRIPTION
--  
--      Body of package ONT_D1_TRANSACTIONAL_CURR_C
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D1_TRANSACTIONAL_CURR_C';
 
 
FUNCTION Get_Default_Value(p_header_rec IN  OE_AK_ORDER_HEADERS_V%ROWTYPE 
  ) RETURN VARCHAR2 IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    l_rule_id := 208;
    IF ONT_PRICE_LIST_Def_Util.Sync_PRICE_LIST_Cache
    (p_PRICE_LIST_ID => p_header_rec.PRICE_LIST_ID
    ) = 1 THEN
    l_return_value := ONT_PRICE_LIST_Def_Util.g_cached_record.CURRENCY_CODE;
    END IF;
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
    l_rule_id := 1;
    l_return_value := OE_DEFAULT_PVT.Get_SOB_Currency_Code
                       (p_database_object_name => null
                       ,p_attribute_code => null);
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'TRANSACTIONAL_CURR_CODE'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D1_TRANSACTIONAL_CURR_C;

/
