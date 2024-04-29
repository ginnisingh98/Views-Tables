--------------------------------------------------------
--  DDL for Package Body OE_7PC2_LINE_EXTLINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_7PC2_LINE_EXTLINE" AS 
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
 
   CURSOR C_VC  IS 
   SELECT count(*) 
   FROM OE_AK_ORDER_LINES_V a 
   WHERE a.LINE_ID =  OE_LINE_SCREDIT_SECURITY.g_record.LINE_ID
   AND   a.SOURCE_TYPE_CODE = 'EXTERNAL'
;
 
 
BEGIN 
   x_result := 0; 
   OPEN C_VC; 
   FETCH C_VC into l_valid_count; 
   CLOSE C_VC; 
   If (l_valid_count > 0)  then 
      x_result := 1; 
   End If; 
   Return; 
END Is_Valid;
END OE_7PC2_LINE_EXTLINE;

/
