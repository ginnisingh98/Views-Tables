--------------------------------------------------------
--  DDL for Package PAY_ETT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ETT_RKI" AUTHID CURRENT_USER as
/* $Header: pyettrhi.pkh 120.0 2005/05/29 04:44:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_element_type_id              in number
  ,p_element_name                 in varchar2
  ,p_reporting_name               in varchar2
  ,p_description                  in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  );
end pay_ett_rki;

 

/
