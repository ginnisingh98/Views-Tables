--------------------------------------------------------
--  DDL for Package OE_1019PC1018_BLKTHDR_BLAWSTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_1019PC1018_BLKTHDR_BLAWSTA" AUTHID CURRENT_USER AS 
 PROCEDURE Is_Valid
 ( 
   p_application_id        in    number,
   p_entity_short_name     in    varchar2,
   p_validation_entity_short_name in varchar2, 
   p_validation_tmplt_short_name  in varchar2,
   p_record_set_short_name        in varchar2,
   p_scope                        in varchar2,
 x_result out nocopy number
  );
END OE_1019PC1018_BLKTHDR_BLAWSTA;

/
