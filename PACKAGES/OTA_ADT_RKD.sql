--------------------------------------------------------
--  DDL for Package OTA_ADT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ADT_RKD" AUTHID CURRENT_USER as
/* $Header: otadtrhi.pkh 120.1 2005/07/11 07:32:22 pgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_activity_id                  in number
  ,p_language                     in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_adt_rkd;

 

/
