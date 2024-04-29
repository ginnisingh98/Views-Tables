--------------------------------------------------------
--  DDL for Package PQP_EXR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_EXR_API" AUTHID CURRENT_USER as
/* $Header: pqexrapi.pkh 120.0.12010000.2 2008/08/05 13:56:48 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_exception_report >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_exception_report
  (p_validate                      in     boolean  default false
  ,p_exception_report_name          in     varchar2
  ,p_legislation_code               in     varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_currency_code                  in     varchar2 default null
  ,p_balance_type_id                in     number   default null
  ,p_balance_dimension_id           in     number   default null
  ,p_variance_type                  in     varchar2 default null
  ,p_variance_value                 in     number   default null
  ,p_comparison_type                in     varchar2 default null
  ,p_comparison_value               in     number   default null
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ,p_exception_report_id               out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_output_format_type			in 	varchar2
  ,p_variance_operator			in 	varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_exception_report >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_exception_report
  (p_validate                      in     boolean  default false
  ,p_exception_report_name          in     varchar2 default hr_api.g_varchar2
  ,p_legislation_code               in     varchar2 default hr_api.g_varchar2
  ,p_business_group_id              in     number   default hr_api.g_number
  ,p_currency_code                  in     varchar2 default hr_api.g_varchar2
  ,p_balance_type_id                in     number   default hr_api.g_number
  ,p_balance_dimension_id           in     number   default hr_api.g_number
  ,p_variance_type                  in     varchar2 default hr_api.g_varchar2
  ,p_variance_value                 in     number   default hr_api.g_number
  ,p_comparison_type                in     varchar2 default hr_api.g_varchar2
  ,p_comparison_value               in     number   default hr_api.g_number
  ,p_exception_report_id            in     number   default hr_api.g_number
  ,p_language_code                  in     varchar2  default hr_api.userenv_lang
  ,p_object_version_number          in     out nocopy number
  ,p_output_format_type	       	    in     varchar2 default hr_api.g_varchar2
  ,p_variance_operator	            in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_exception_report >--------------------------|
--
procedure delete_exception_report
  (p_validate                      in     boolean  default false
  ,p_exception_report_id           in     number
  ,p_object_version_number         in     number
  );
--
end pqp_exr_api;

/
