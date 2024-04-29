--------------------------------------------------------
--  DDL for Package Body ONT_D1_CREDIT_CARD_EXPIRATI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D1_CREDIT_CARD_EXPIRATI" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D1_CREDIT_CARD_EXPIRATI
--  
--  DESCRIPTION
--  
--      Body of package ONT_D1_CREDIT_CARD_EXPIRATI
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D1_CREDIT_CARD_EXPIRATI';
 
 
FUNCTION Get_Default_Value(p_header_rec IN  OE_AK_ORDER_HEADERS_V%ROWTYPE 
  ) RETURN DATE IS 
  l_return_value     DATE;
  l_rule_id         NUMBER;
BEGIN
 
    IF (p_header_rec.PAYMENT_TYPE_CODE = 'CREDIT_CARD'
        ) THEN
    l_rule_id := 126;
    l_return_value := OE_DEFAULT_PVT.Get_CC_Expiration_Date
                       (p_database_object_name => 'OE_AK_ORDER_HEADERS_V'
                       ,p_attribute_code => null);
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'CREDIT_CARD_EXPIRATION_DATE'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D1_CREDIT_CARD_EXPIRATI;

/
