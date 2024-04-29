--------------------------------------------------------
--  DDL for Package Body OE_2PC2_LINE_RCVED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_2PC2_LINE_RCVED" AS 
 PROCEDURE Is_Valid
 ( 
   p_application_id        in    number,
   p_entity_short_name     in    varchar2,
   p_validation_entity_short_name in varchar2, 
   p_validation_tmplt_short_name  in varchar2,
   p_record_set_short_name        in varchar2,
   p_scope                        in varchar2,
 x_result out nocopy number
  )
 IS 
   l_valid_count NUMBER := 0; 
   l_set_count   NUMBER := 0; 
 
 
 
BEGIN 
   x_result := 0; 
  IF OE_LINE_SECURITY.g_record.SHIPPED_QUANTITY <> 0
   AND   OE_LINE_SECURITY.g_record.LINE_CATEGORY_CODE = 'RETURN'
   AND   OE_LINE_SECURITY.g_record.SHIPPED_QUANTITY IS NOT NULL 
  THEN 
  l_valid_count := 1; 
  END IF;
   If (l_valid_count > 0)  then 
      x_result := 1; 
   End If; 
   Return; 
END Is_Valid;
END OE_2PC2_LINE_RCVED;

/
