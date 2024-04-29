--------------------------------------------------------
--  DDL for Package OTA_CHT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHT_RKD" AUTHID CURRENT_USER as
/* $Header: otchtrhi.pkh 120.1 2005/12/08 11:27 cmora noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_chat_id                      in number
  ,p_language                     in varchar2
  ,p_name_o                       in varchar2
  ,p_description_o                in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_cht_rkd;

 

/
