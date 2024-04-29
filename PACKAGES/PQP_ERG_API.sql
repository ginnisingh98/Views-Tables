--------------------------------------------------------
--  DDL for Package PQP_ERG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ERG_API" AUTHID CURRENT_USER as
/* $Header: pqergapi.pkh 120.0 2005/05/29 01:45:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_exception_group >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_exception_group
  (p_validate                      in     boolean  default false
  ,p_exception_group_name          in     varchar2 default null
  ,p_exception_report_id           in     number
  ,p_legislation_code              in     varchar2 default null
  ,p_business_group_id             in     number   default null
  ,p_consolidation_set_id          in     number   default null
  ,p_payroll_id                    in     number   default null
  ,p_exception_group_id            out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_output_format                 in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_exception_group >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_exception_group
  (p_validate                      in     boolean  default false
  ,p_exception_group_id           in     number    default hr_api.g_number
  ,p_exception_group_name         in     varchar2  default hr_api.g_varchar2
  ,p_exception_report_id          in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2 default hr_api.g_varchar2
  ,p_business_group_id            in     number   default hr_api.g_number
  ,p_consolidation_set_id         in     number    default hr_api.g_number
  ,p_payroll_id                   in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_output_format                in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_exception_group >---------------------------|
--
procedure delete_exception_group
  (p_validate                      in     boolean  default false
  ,p_exception_group_id            in     number
  ,p_object_version_number         in     number
  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_exception_group >---------------------------|
--
procedure delete_exception_group
  (p_validate                      in     boolean  default false
  ,p_exception_group_name          in     varchar2
  ,p_business_group_id		   in	  number
  );
--
end pqp_erg_api;

 

/
