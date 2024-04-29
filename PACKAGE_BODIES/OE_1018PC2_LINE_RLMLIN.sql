--------------------------------------------------------
--  DDL for Package Body OE_1018PC2_LINE_RLMLIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_1018PC2_LINE_RLMLIN" AS 
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
  WHERE   a.BLANKET_NUMBER =  OE_BLANKET_HEADER_SECURITY.g_record.ORDER_NUMBER
   AND   a.SOURCE_DOCUMENT_TYPE_ID = 5
;
 
   CURSOR C_RSC IS 
   SELECT count(*) 
   FROM OE_AK_ORDER_LINES_V a 
  WHERE   a.BLANKET_NUMBER =  OE_BLANKET_HEADER_SECURITY.g_record.ORDER_NUMBER
;
 
BEGIN 
   x_result := 0; 
   OPEN C_VC; 
   FETCH C_VC into l_valid_count; 
   CLOSE C_VC; 
   If (l_valid_count > 0)  then 
      If (p_scope = 'ALL')  then 
         OPEN C_RSC; 
         FETCH C_RSC into l_set_count; 
         CLOSE C_RSC; 
         If (l_valid_count = l_set_count) then 
            x_result := 1; 
         End If; 
      Else 
         x_result := 1; 
      End If; 
   End If; 
   Return; 
END Is_Valid;
END OE_1018PC2_LINE_RLMLIN;

/
