--------------------------------------------------------
--  DDL for Package Body OE_1018PC1018_BLKTHDR_BLCLOSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_1018PC1018_BLKTHDR_BLCLOSE" AS 
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
  IF OE_BLANKET_HEADER_SECURITY.g_record.OPEN_FLAG = 'N'
  THEN 
  l_valid_count := 1; 
  END IF;
   If (l_valid_count > 0)  then 
      x_result := 1; 
   End If; 
   Return; 
END Is_Valid;
END OE_1018PC1018_BLKTHDR_BLCLOSE;

/
