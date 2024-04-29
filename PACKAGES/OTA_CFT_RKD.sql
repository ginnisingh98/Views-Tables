--------------------------------------------------------
--  DDL for Package OTA_CFT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CFT_RKD" AUTHID CURRENT_USER as
/* $Header: otcftrhi.pkh 120.0 2005/05/29 07:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_conference_server_id         in number
  ,p_language                     in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_cft_rkd;

 

/
