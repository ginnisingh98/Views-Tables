--------------------------------------------------------
--  DDL for Package OTA_CFT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CFT_RKU" AUTHID CURRENT_USER as
/* $Header: otcftrhi.pkh 120.0 2005/05/29 07:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_conference_server_id         in number
  ,p_language                     in varchar2
  ,p_name                         in varchar2
  ,p_description                  in varchar2
  ,p_source_lang                  in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_cft_rku;

 

/
