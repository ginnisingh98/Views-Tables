--------------------------------------------------------
--  DDL for Package OTA_ENT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ENT_RKD" AUTHID CURRENT_USER as
/* $Header: otentrhi.pkh 120.0 2005/05/29 07:13:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_event_id                     in number
  ,p_language                     in varchar2
  ,p_title_o                      in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_ent_rkd;

 

/
