--------------------------------------------------------
--  DDL for Package PAY_PUC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PUC_RKD" AUTHID CURRENT_USER as
/* $Header: pypucrhi.pkh 120.0 2005/05/29 07:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_user_column_id               in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_user_table_id_o              in number
  ,p_formula_id_o                 in number
  ,p_user_column_name_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_puc_rkd;

 

/