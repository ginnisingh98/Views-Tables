--------------------------------------------------------
--  DDL for Package Body ONT_D2_LATEST_ACCEPTABLE_DA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_D2_LATEST_ACCEPTABLE_DA" AS
/* $Header: OEXDFWKB.pls 115.0 29-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      ONT_D2_LATEST_ACCEPTABLE_DA
--  
--  DESCRIPTION
--  
--      Body of package ONT_D2_LATEST_ACCEPTABLE_DA
--  
--  NOTES
--  
--  HISTORY
--  
--  29-AUG-13 Created
--  
 
--  Global constant holding the package name
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'ONT_D2_LATEST_ACCEPTABLE_DA';
 
 
FUNCTION Get_Default_Value(p_line_rec IN  OE_AK_ORDER_LINES_V%ROWTYPE 
  ) RETURN DATE IS 
  l_return_value     DATE;
  l_rule_id         NUMBER;
BEGIN
 
  <<RETURN_VALUE>>
  RETURN l_return_value;
 
EXCEPTION
WHEN OTHERS THEN
         ONT_Def_Util.Add_Invalid_Rule_Message
         ( p_attribute_code => 'LATEST_ACCEPTABLE_DATE'
         , p_rule_id => l_rule_id
         );
         RETURN NULL;
END Get_Default_Value;
END ONT_D2_LATEST_ACCEPTABLE_DA;

/