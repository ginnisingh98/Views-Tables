--------------------------------------------------------
--  DDL for Package OTA_ONT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ONT_RKU" AUTHID CURRENT_USER as
/* $Header: otontrhi.pkh 120.0 2005/05/29 07:30:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_offering_id                  in number
  ,p_language                     in varchar2
  ,p_offering_name                in varchar2
  ,p_description                  in varchar2
  ,p_source_lang                  in varchar2
  ,p_offering_name_o              in varchar2
  ,p_description_o                in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end ota_ont_rku;

 

/
