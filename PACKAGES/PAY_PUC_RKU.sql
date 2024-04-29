--------------------------------------------------------
--  DDL for Package PAY_PUC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PUC_RKU" AUTHID CURRENT_USER as
/* $Header: pypucrhi.pkh 120.0 2005/05/29 07:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_user_column_id               in number
  ,p_formula_id                   in number
  ,p_user_column_name             in varchar2
  ,p_object_version_number        in number
  ,p_formula_warning              in boolean
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_user_table_id_o              in number
  ,p_formula_id_o                 in number
  ,p_user_column_name_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_puc_rku;

 

/
