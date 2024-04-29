--------------------------------------------------------
--  DDL for Package PQP_EXCEPTION_REPORT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EXCEPTION_REPORT_BK2" AUTHID CURRENT_USER as
/* $Header: pqexrapi.pkh 120.0.12010000.2 2008/08/05 13:56:48 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< update_exception_report_b >   ------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_exception_report_b
  (p_exception_report_name          in     varchar2
  ,p_legislation_code               in     varchar2
  ,p_business_group_id              in     number
  ,p_currency_code                  in     varchar2
  ,p_balance_type_id                in     number
  ,p_balance_dimension_id           in     number
  ,p_variance_type                  in     varchar2
  ,p_variance_value                 in     number
  ,p_comparison_type                in     varchar2
  ,p_comparison_value               in     number
  ,p_exception_report_id            in     number
  ,p_object_version_number          in     number
  ,p_output_format_type			in 	varchar2
  ,p_variance_operator				in 	varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------< update_exception_report_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_exception_report_a
  (p_exception_report_name          in     varchar2
  ,p_legislation_code               in     varchar2
  ,p_business_group_id              in     number
  ,p_currency_code                  in     varchar2
  ,p_balance_type_id                in     number
  ,p_balance_dimension_id           in     number
  ,p_variance_type                  in     varchar2
  ,p_variance_value                 in     number
  ,p_comparison_type                in     varchar2
  ,p_comparison_value               in     number
  ,p_exception_report_id            in     number
  ,p_object_version_number          in     number
  ,p_output_format_type			in 	varchar2
  ,p_variance_operator				in 	varchar2
  );
--
end pqp_exception_report_bk2;

/
