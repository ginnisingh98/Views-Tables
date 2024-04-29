--------------------------------------------------------
--  DDL for Package OTA_CTT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CTT_RKD" AUTHID CURRENT_USER as
/* $Header: otcttrhi.pkh 120.0 2005/05/29 07:10:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_category_usage_id            in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_category_o                   in varchar2
  ,p_description_o                in varchar2
  );
--
end ota_ctt_rkd;

 

/
