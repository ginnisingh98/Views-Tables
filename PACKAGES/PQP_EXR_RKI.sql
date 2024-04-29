--------------------------------------------------------
--  DDL for Package PQP_EXR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EXR_RKI" AUTHID CURRENT_USER as
/* $Header: pqexrrhi.pkh 120.1 2005/06/30 12:01:48 rpinjala noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_exception_report_id          in number
  ,p_exception_report_name        in varchar2
  ,p_legislation_code             in varchar2
  ,p_business_group_id            in number
  ,p_currency_code                in varchar2
  ,p_balance_type_id              in number
  ,p_balance_dimension_id         in number
  ,p_variance_type                in varchar2
  ,p_variance_value               in number
  ,p_comparison_type              in varchar2
  ,p_comparison_value             in number
  ,p_object_version_number        in number
  ,p_output_format_type		  in varchar2
  ,p_variance_operator		  in varchar2
  );
end pqp_exr_rki;

 

/
