--------------------------------------------------------
--  DDL for Package OTA_CTT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CTT_RKI" AUTHID CURRENT_USER as
/* $Header: otcttrhi.pkh 120.0 2005/05/29 07:10:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_category_usage_id            in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_category                     in varchar2
  ,p_description                  in varchar2
  );
end ota_ctt_rki;

 

/
