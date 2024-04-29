--------------------------------------------------------
--  DDL for Package OTA_LPT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LPT_RKI" AUTHID CURRENT_USER as
/* $Header: otlptrhi.pkh 120.0 2005/05/29 07:24:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_learning_path_id             in number
  ,p_language                     in varchar2
  ,p_name                         in varchar2
  ,p_description                  in varchar2
  ,p_objectives                   in varchar2
  ,p_purpose                      in varchar2
  ,p_keywords                     in varchar2
  ,p_source_lang                  in varchar2
  );
end ota_lpt_rki;

 

/
