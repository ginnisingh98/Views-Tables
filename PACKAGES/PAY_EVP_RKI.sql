--------------------------------------------------------
--  DDL for Package PAY_EVP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVP_RKI" AUTHID CURRENT_USER as
/* $Header: pyevprhi.pkh 120.0 2005/05/29 04:48:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_event_procedure_id           in number
  ,p_dated_table_id               in number
  ,p_procedure_name               in varchar2
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_column_name                  in varchar2
  ,p_object_version_number        in number
  );
end pay_evp_rki;

 

/
