--------------------------------------------------------
--  DDL for Package OTA_ADT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ADT_RKI" AUTHID CURRENT_USER as
/* $Header: otadtrhi.pkh 120.1 2005/07/11 07:32:22 pgupta noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_activity_id                  in number
  ,p_name                         in varchar2
  ,p_description                  in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  );
end ota_adt_rki;

 

/
