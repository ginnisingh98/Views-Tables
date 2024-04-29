--------------------------------------------------------
--  DDL for Package PAY_PUC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PUC_RKI" AUTHID CURRENT_USER as
/* $Header: pypucrhi.pkh 120.0 2005/05/29 07:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_user_column_id               in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_user_table_id                in number
  ,p_formula_id                   in number
  ,p_user_column_name             in varchar2
  ,p_object_version_number        in number
  );
end pay_puc_rki;

 

/
