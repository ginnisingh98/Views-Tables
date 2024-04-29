--------------------------------------------------------
--  DDL for Package PQP_EXR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EXR_RKD" AUTHID CURRENT_USER as
/* $Header: pqexrrhi.pkh 120.1 2005/06/30 12:01:48 rpinjala noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_exception_report_id          in number
  ,p_exception_report_name_o      in varchar2
  ,p_legislation_code_o           in varchar2
  ,p_business_group_id_o          in number
  ,p_currency_code_o              in varchar2
  ,p_balance_type_id_o            in number
  ,p_balance_dimension_id_o       in number
  ,p_variance_type_o              in varchar2
  ,p_variance_value_o             in number
  ,p_comparison_type_o            in varchar2
  ,p_comparison_value_o           in number
  ,p_object_version_number_o      in number
    );
--
end pqp_exr_rkd;

 

/
