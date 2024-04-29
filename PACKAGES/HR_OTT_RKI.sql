--------------------------------------------------------
--  DDL for Package HR_OTT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OTT_RKI" AUTHID CURRENT_USER as
/* $Header: hrottrhi.pkh 120.0 2005/05/31 01:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_option_type_id               in number
  ,p_option_name                  in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  );
end hr_ott_rki;

 

/
