--------------------------------------------------------
--  DDL for Package Body ONT_D1024_CREDIT_CARD_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D1024_CREDIT_CARD_NUMBER" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D1024_CREDIT_CARD_NUMBER
--  
--  DESCRIPTION
--  
--      Body of package ONT_D1024_CREDIT_CARD_NUMBER
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D1024_CREDIT_CARD_NUMBER';
 
 
FUNCTION Get_Default_Value(p_header_payment_rec IN  OE_AK_HEADER_PAYMENTS_V%ROWTYPE 
  ) RETURN VARCHAR2 IS 
  l_return_value    VARCHAR2(2000);
  l_rule_id         NUMBER;
BEGIN
 
    IF (p_header_payment_rec.PAYMENT_TYPE_CODE = 'CREDIT_CARD'
        ) THEN
    l_rule_id := 511;
    l_return_value := OE_Default_Pvt.Get_Credit_Card_Number
                       (p_database_object_name => 'OE_AK_HEADER_PAYMENTS_V'
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
         ( p_attribute_code => 'CREDIT_CARD_NUMBER'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D1024_CREDIT_CARD_NUMBER;

/
