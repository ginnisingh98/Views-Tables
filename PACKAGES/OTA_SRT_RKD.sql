--------------------------------------------------------
--  DDL for Package OTA_SRT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_SRT_RKD" AUTHID CURRENT_USER as
/* $Header: otsrtrhi.pkh 120.0 2005/05/29 07:33:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_supplied_resource_id         in number
  ,p_language                     in varchar2
  ,p_name_o                       in varchar2
  ,p_special_instruction_o        in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_srt_rkd;

 

/
