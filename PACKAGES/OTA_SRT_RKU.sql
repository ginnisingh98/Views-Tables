--------------------------------------------------------
--  DDL for Package OTA_SRT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_SRT_RKU" AUTHID CURRENT_USER as
/* $Header: otsrtrhi.pkh 120.0 2005/05/29 07:33:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_supplied_resource_id         in number
  ,p_language                     in varchar2
  ,p_name                         in varchar2
  ,p_special_instruction          in varchar2
  ,p_source_lang                  in varchar2
  ,p_name_o                       in varchar2
  ,p_special_instruction_o        in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_srt_rku;

 

/
