--------------------------------------------------------
--  DDL for Package Body OE_1PC1018_BLKTHDR_BLINTAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_1PC1018_BLKTHDR_BLINTAP" AS 
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
 
 l_wf_item_type varchar2(8) :='OENH';
 l_wf_activity_name varchar2(30) :='INTERNAL_APPROVAL_PROCESS';
 l_wf_activity_status_code varchar2(8) :='COMPLETE';
 l_wf_activity_result_code varchar2(30) :='APPROVED';
   CURSOR C_VC  IS 
   SELECT count(*) 
   FROM wf_item_activity_statuses  w, wf_process_activities wpa
       ,OE_AK_BLANKET_HEADERS_V a 
   WHERE w.item_type     = l_wf_item_type
   AND w.process_activity = wpa.instance_id
   AND wpa.activity_name = l_wf_activity_name
   AND w.activity_status = l_wf_activity_status_code
   AND w.activity_result_code = l_wf_activity_result_code
   AND   w.item_key = a.HEADER_ID || ''
   AND a.ORDER_NUMBER = OE_HEADER_SECURITY.g_record.BLANKET_NUMBER
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
END OE_1PC1018_BLKTHDR_BLINTAP;

/
