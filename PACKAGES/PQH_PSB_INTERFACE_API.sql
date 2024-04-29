--------------------------------------------------------
--  DDL for Package PQH_PSB_INTERFACE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PSB_INTERFACE_API" AUTHID CURRENT_USER AS
/* $Header: pqhpqps.pkh 115.3 2002/12/06 18:06:39 rpasapul noship $ */

-- ----------------------------------------------------------------------------
-- |------------------------< create_budget_version >------------------------|
-- ----------------------------------------------------------------------------
procedure create_budget_version
(
   p_validate                       in  boolean   default false
  ,p_budget_version_id              out nocopy number
  ,p_budget_id                      in  number    default null
  ,p_version_number                 in  number    default null
  ,p_date_from                      in  date      default null
  ,p_date_to                        in  date      default null
  ,p_transfered_to_gl_flag          in  varchar2  default null
  ,p_gl_status                      in  varchar2  default null
  ,p_xfer_to_other_apps_cd          in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_budget_unit1_available         in  number    default null
  ,p_budget_unit2_available         in  number    default null
  ,p_budget_unit3_available         in  number    default null
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_budget_version >------------------------|
-- ----------------------------------------------------------------------------
procedure update_budget_version
  (
   p_validate                       in  boolean   default false
  ,p_budget_version_id              in  number
  ,p_budget_id                      in  number    default hr_api.g_number
  ,p_version_number                 in  number    default hr_api.g_number
  ,p_date_from                      in  date      default hr_api.g_date
  ,p_date_to                        in  date      default hr_api.g_date
  ,p_transfered_to_gl_flag          in  varchar2  default hr_api.g_varchar2
  ,p_gl_status                      in  varchar2  default hr_api.g_varchar2
  ,p_xfer_to_other_apps_cd          in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in  out nocopy number
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_budget_unit1_available         in  number    default hr_api.g_number
  ,p_budget_unit2_available         in  number    default hr_api.g_number
  ,p_budget_unit3_available         in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  );
-- ----------------------------------------------------------------------------
-- |------------------------< create_budget_element >------------------------|
-- ----------------------------------------------------------------------------
procedure create_budget_element
(
   p_validate                       in  boolean   default false
  ,p_budget_element_id              out nocopy number
  ,p_budget_set_id                  in  number    default null
  ,p_element_type_id                in  number    default null
  ,p_distribution_percentage        in  number    default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_budget_element >------------------------|
-- ----------------------------------------------------------------------------
procedure update_budget_element
  (
   p_validate                       in  boolean   default false
  ,p_budget_element_id              in  number
  ,p_budget_set_id                  in  number    default hr_api.g_number
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_distribution_percentage        in  number    default hr_api.g_number
  ,p_object_version_number          in  out nocopy number
  );
-- ----------------------------------------------------------------------------
-- |------------------------< create_budget_fund_src >------------------------|
-- ----------------------------------------------------------------------------
procedure create_budget_fund_src
(
   p_validate                       in  boolean   default false
  ,p_budget_fund_src_id             out nocopy number
  ,p_budget_element_id              in  number    default null
  ,p_cost_allocation_keyflex_id     in  number    default null
  ,p_project_id                     in  number    default null
  ,p_award_id                       in  number    default null
  ,p_task_id                        in  number    default null
  ,p_expenditure_type               in  varchar2  default null
  ,p_organization_id                in  number    default null
  ,p_distribution_percentage        in  number    default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_budget_fund_src >------------------------|
-- ----------------------------------------------------------------------------
procedure update_budget_fund_src
  (
   p_validate                       in  boolean   default false
  ,p_budget_fund_src_id             in  number
  ,p_budget_element_id              in  number    default hr_api.g_number
  ,p_cost_allocation_keyflex_id     in  number    default hr_api.g_number
  ,p_project_id                     in  number    default hr_api.g_number
  ,p_award_id                       in  number    default hr_api.g_number
  ,p_task_id                        in  number    default hr_api.g_number
  ,p_expenditure_type               in  varchar2  default hr_api.g_varchar2
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_distribution_percentage        in  number    default hr_api.g_number
  ,p_object_version_number          in  out nocopy number
  );
-- ----------------------------------------------------------------------------
-- |------------------------< create_budget_period >------------------------|
-- ----------------------------------------------------------------------------
procedure create_budget_period
(
   p_validate                       in  boolean   default false
  ,p_budget_period_id               out nocopy number
  ,p_budget_detail_id               in  number    default null
  ,p_start_time_period_id           in  number    default null
  ,p_end_time_period_id             in  number    default null
  ,p_budget_unit1_percent           in  number    default null
  ,p_budget_unit2_percent           in  number    default null
  ,p_budget_unit3_percent           in  number    default null
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_budget_unit1_value_type_cd     in  varchar2  default null
  ,p_budget_unit2_value_type_cd     in  varchar2  default null
  ,p_budget_unit3_value_type_cd     in  varchar2  default null
  ,p_budget_unit1_available         in  number    default null
  ,p_budget_unit2_available         in  number    default null
  ,p_budget_unit3_available         in  number    default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_budget_period >------------------------|
-- ----------------------------------------------------------------------------
procedure update_budget_period
  (
   p_validate                       in  boolean   default false
  ,p_budget_period_id               in  number
  ,p_budget_detail_id               in  number    default hr_api.g_number
  ,p_start_time_period_id           in  number    default hr_api.g_number
  ,p_end_time_period_id             in  number    default hr_api.g_number
  ,p_budget_unit1_percent           in  number    default hr_api.g_number
  ,p_budget_unit2_percent           in  number    default hr_api.g_number
  ,p_budget_unit3_percent           in  number    default hr_api.g_number
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_budget_unit1_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit2_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit3_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit1_available         in  number    default hr_api.g_number
  ,p_budget_unit2_available         in  number    default hr_api.g_number
  ,p_budget_unit3_available         in  number    default hr_api.g_number
  ,p_object_version_number          in  out nocopy number
  );
-- ----------------------------------------------------------------------------
-- |------------------------< create_budget_set >------------------------|
-- ----------------------------------------------------------------------------
procedure create_budget_set
(
   p_validate                       in  boolean   default false
  ,p_budget_set_id                  out nocopy number
  ,p_dflt_budget_set_id             in  number    default null
  ,p_budget_period_id               in  number    default null
  ,p_budget_unit1_percent           in  number    default null
  ,p_budget_unit2_percent           in  number    default null
  ,p_budget_unit3_percent           in  number    default null
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_budget_unit1_available         in  number    default null
  ,p_budget_unit2_available         in  number    default null
  ,p_budget_unit3_available         in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default null
  ,p_budget_unit2_value_type_cd     in  varchar2  default null
  ,p_budget_unit3_value_type_cd     in  varchar2  default null
  ,p_effective_date                 in  date
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_budget_set >------------------------|
-- ----------------------------------------------------------------------------
procedure update_budget_set
  (
   p_validate                       in  boolean   default false
  ,p_budget_set_id                  in  number
  ,p_dflt_budget_set_id             in  number    default hr_api.g_number
  ,p_budget_period_id               in  number    default hr_api.g_number
  ,p_budget_unit1_percent           in  number    default hr_api.g_number
  ,p_budget_unit2_percent           in  number    default hr_api.g_number
  ,p_budget_unit3_percent           in  number    default hr_api.g_number
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_budget_unit1_available         in  number    default hr_api.g_number
  ,p_budget_unit2_available         in  number    default hr_api.g_number
  ,p_budget_unit3_available         in  number    default hr_api.g_number
  ,p_object_version_number          in  out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit2_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit3_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  );
-- ----------------------------------------------------------------------------
-- |------------------------< create_budget_detail >------------------------|
-- ----------------------------------------------------------------------------
procedure create_budget_detail
(
   p_validate                       in  boolean   default false
  ,p_budget_detail_id               out nocopy number
  ,p_organization_id                in  number    default null
  ,p_job_id                         in  number    default null
  ,p_position_id                    in  number    default null
  ,p_grade_id                       in  number    default null
  ,p_budget_version_id              in  number    default null
  ,p_budget_unit1_percent           in  number    default null
  ,p_budget_unit1_value_type_cd     in  varchar2  default null
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit1_available         in  number    default null
  ,p_budget_unit2_percent           in  number    default null
  ,p_budget_unit2_value_type_cd     in  varchar2  default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit2_available         in  number    default null
  ,p_budget_unit3_percent           in  number    default null
  ,p_budget_unit3_value_type_cd     in  varchar2  default null
  ,p_budget_unit3_value             in  number    default null
  ,p_budget_unit3_available         in  number    default null
  ,p_gl_status                      in  varchar2  default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_budget_detail >------------------------|
-- ----------------------------------------------------------------------------
procedure update_budget_detail
  (
   p_validate                       in  boolean   default false
  ,p_budget_detail_id               in  number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_job_id                         in  number    default hr_api.g_number
  ,p_position_id                    in  number    default hr_api.g_number
  ,p_grade_id                       in  number    default hr_api.g_number
  ,p_budget_version_id              in  number    default hr_api.g_number
  ,p_budget_unit1_percent           in  number    default hr_api.g_number
  ,p_budget_unit1_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit1_available         in  number    default hr_api.g_number
  ,p_budget_unit2_percent           in  number    default hr_api.g_number
  ,p_budget_unit2_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit2_available         in  number    default hr_api.g_number
  ,p_budget_unit3_percent           in  number    default hr_api.g_number
  ,p_budget_unit3_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_budget_unit3_available         in  number    default hr_api.g_number
  ,p_gl_status                      in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in  out nocopy number
  );
--  ---------------------------------------------------------------------------
--  |-----------------<   POSITION_CONTROL_ENABLED    >---------------------|
--  ---------------------------------------------------------------------------
function position_control_enabled(p_organization_id 	number  default null,
                                  p_effective_date 	in date default sysdate,
                                  p_assignment_id 	number  default null
                                 )RETURN VARCHAR2;
-- ---------------------------------------------------------------------------
-- |---------------------< create_app_api_hook_call >-------------------------|
-- ---------------------------------------------------------------------------
procedure create_app_api_hook_call
  (p_validate                     in     boolean  default false,
   p_effective_date               in     date,
   p_api_hook_id                  in     number,
   p_api_hook_call_type           in     varchar2,
   p_sequence                     in     number,
   p_application_id               in     number,
   p_app_install_status           in     varchar2,
   p_enabled_flag                 in     varchar2  default 'N',
   p_call_package                 in     varchar2  default null,
   p_call_procedure               in     varchar2  default null,
   p_api_hook_call_id             out nocopy    number,
   p_object_version_number        out nocopy    number
);
END PQH_PSB_INTERFACE_API;

 

/
