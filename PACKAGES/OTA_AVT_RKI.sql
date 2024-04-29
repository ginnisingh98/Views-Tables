--------------------------------------------------------
--  DDL for Package OTA_AVT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_AVT_RKI" AUTHID CURRENT_USER as
/* $Header: otavtrhi.pkh 120.0 2005/05/29 07:02:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_activity_version_id          in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_version_name                 in varchar2
  ,p_description                  in varchar2
  ,p_intended_audience            in varchar2
  ,p_objectives                   in varchar2
  ,p_keywords                     in varchar2
  );
end ota_avt_rki;

 

/
