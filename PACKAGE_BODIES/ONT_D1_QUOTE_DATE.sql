--------------------------------------------------------
--  DDL for Package Body ONT_D1_QUOTE_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D1_QUOTE_DATE" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D1_QUOTE_DATE
--  
--  DESCRIPTION
--  
--      Body of package ONT_D1_QUOTE_DATE
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D1_QUOTE_DATE';
 
 
FUNCTION Get_Default_Value(p_header_rec IN  OE_AK_ORDER_HEADERS_V%ROWTYPE 
  ) RETURN DATE IS 
  l_return_value     DATE;
  l_rule_id         NUMBER;
BEGIN
 
    IF (p_header_rec.TRANSACTION_PHASE_CODE = 'N'
        ) THEN
    l_rule_id := 502;
    l_return_value := ONT_Def_Util.Get_Expression_Value_Date
       (p_expression_string => 'sysdate');
    IF l_return_value IS NOT NULL THEN
       GOTO RETURN_VALUE;
  END IF;
  END IF;
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'QUOTE_DATE'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D1_QUOTE_DATE;

/
