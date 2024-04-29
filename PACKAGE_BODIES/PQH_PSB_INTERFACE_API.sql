--------------------------------------------------------
--  DDL for Package Body PQH_PSB_INTERFACE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PSB_INTERFACE_API" AS
/* $Header: pqhpqps.pkb 115.6 2002/12/06 18:06:37 rpasapul noship $ */

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
 ) is
 begin
    pqh_budget_versions_api.create_budget_version
      (p_validate                 => p_validate,
       p_budget_version_id        => p_budget_version_id,
       p_budget_id                => p_budget_id,
       p_version_number           => p_version_number,
       p_date_from                => p_date_from,
       p_date_to                  => p_date_to,
       p_transfered_to_gl_flag    => p_transfered_to_gl_flag,
       p_gl_status	          => p_gl_status,
       p_xfer_to_other_apps_cd    => p_xfer_to_other_apps_cd,
       p_object_version_number    => p_object_version_number,
       p_budget_unit1_value       => p_budget_unit1_value,
       p_budget_unit2_value       => p_budget_unit2_value,
       p_budget_unit3_value       => p_budget_unit3_value,
       p_budget_unit1_available   => p_budget_unit1_available,
       p_budget_unit2_available   => p_budget_unit2_available,
       p_budget_unit3_available   => p_budget_unit3_available,
       p_effective_date           => p_effective_date
      );
exception when others then
p_budget_version_id 	:= null;
p_object_version_number := null;
raise;
 end create_budget_version;
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
  ) is
  l_object_version_number number := p_object_version_number;
begin
    pqh_budget_versions_api.update_budget_version
      (p_validate                 => p_validate,
       p_budget_version_id        => p_budget_version_id,
       p_budget_id                => p_budget_id,
       p_version_number           => p_version_number,
       p_date_from                => p_date_from,
       p_date_to                  => p_date_to,
       p_transfered_to_gl_flag    => p_transfered_to_gl_flag,
       p_gl_status	          => p_gl_status,
       p_xfer_to_other_apps_cd    => p_xfer_to_other_apps_cd,
       p_object_version_number    => p_object_version_number,
       p_budget_unit1_value       => p_budget_unit1_value,
       p_budget_unit2_value       => p_budget_unit2_value,
       p_budget_unit3_value       => p_budget_unit3_value,
       p_budget_unit1_available   => p_budget_unit1_available,
       p_budget_unit2_available   => p_budget_unit2_available,
       p_budget_unit3_available   => p_budget_unit3_available,
       p_effective_date           => p_effective_date
      );
exception when others then
p_object_version_number := l_object_version_number;
raise;
end update_budget_version;
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
 ) is
begin
    pqh_budget_elements_api.create_budget_element
      (p_validate 		 => p_validate,
       p_budget_element_id 	 => p_budget_element_id,
       p_budget_set_id 		 => p_budget_set_id,
       p_element_type_id 	 => p_element_type_id,
       p_distribution_percentage => p_distribution_percentage,
       p_object_version_number   => p_object_version_number
      );
exception when others then
p_budget_element_id := null;
p_object_version_number := null;
raise;
end create_budget_element;
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
  ) is
  l_object_version_number number := p_object_version_number;
begin
    pqh_budget_elements_api.update_budget_element
      (p_validate 		 => p_validate,
       p_budget_element_id 	 => p_budget_element_id,
       p_budget_set_id 		 => p_budget_set_id,
       p_element_type_id 	 => p_element_type_id,
       p_distribution_percentage => p_distribution_percentage,
       p_object_version_number   => p_object_version_number
      );
exception when others then
p_object_version_number := l_object_version_number;
raise;
end update_budget_element;
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
 ) is
begin
    pqh_budget_fund_srcs_api.create_budget_fund_src
      (p_validate                       =>  p_validate,
       p_budget_fund_src_id             =>  p_budget_fund_src_id ,
       p_budget_element_id              =>  p_budget_element_id,
       p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id,
       p_project_id      	        =>  p_project_id,
       p_award_id        	        =>  p_award_id,
       p_task_id         	        =>  p_task_id,
       p_expenditure_type	        =>  p_expenditure_type,
       p_organization_id	        =>  p_organization_id,
       p_distribution_percentage        =>  p_distribution_percentage,
       p_object_version_number          =>  p_object_version_number
      );
exception when others then
p_budget_fund_src_id := null;
p_object_version_number := null;
raise;
end create_budget_fund_src;
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
  ) is
  l_object_version_number number := p_object_version_number;
begin
    pqh_budget_fund_srcs_api.update_budget_fund_src
      (p_validate                       =>  p_validate,
       p_budget_fund_src_id             =>  p_budget_fund_src_id ,
       p_budget_element_id              =>  p_budget_element_id,
       p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id,
       p_project_id      	        =>  p_project_id,
       p_award_id        	        =>  p_award_id,
       p_task_id         	        =>  p_task_id,
       p_expenditure_type	        =>  p_expenditure_type,
       p_organization_id	        =>  p_organization_id,
       p_distribution_percentage        =>  p_distribution_percentage,
       p_object_version_number          =>  p_object_version_number
      );
exception when others then
p_object_version_number := l_object_version_number;
raise;
end update_budget_fund_src;
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
 ) is
begin
    pqh_budget_periods_api.create_budget_period
      (p_validate 			=> p_validate,
       p_budget_period_id 		=> p_budget_period_id,
       p_budget_detail_id 		=> p_budget_detail_id,
       p_start_time_period_id 		=> p_start_time_period_id,
       p_end_time_period_id 		=> p_end_time_period_id,
       p_budget_unit1_percent           => p_budget_unit1_percent,
       p_budget_unit2_percent           => p_budget_unit2_percent,
       p_budget_unit3_percent       	=> p_budget_unit3_percent,
       p_budget_unit1_value 		=> p_budget_unit1_value,
       p_budget_unit2_value 		=> p_budget_unit2_value,
       p_budget_unit3_value 		=> p_budget_unit3_value,
       p_budget_unit1_value_type_cd 	=> p_budget_unit1_value_type_cd,
       p_budget_unit2_value_type_cd 	=> p_budget_unit2_value_type_cd,
       p_budget_unit3_value_type_cd 	=> p_budget_unit3_value_type_cd,
       p_budget_unit1_available         => p_budget_unit1_available,
       p_budget_unit2_available         => p_budget_unit2_available,
       p_budget_unit3_available         => p_budget_unit3_available,
       p_object_version_number 		=> p_object_version_number
      );
exception when others then
p_budget_period_id := null;
p_object_version_number := null;
raise;
end create_budget_period;
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
  ) is
  l_object_version_number number := p_object_version_number;
begin
    pqh_budget_periods_api.update_budget_period
      (p_validate 			=> p_validate,
       p_budget_period_id 		=> p_budget_period_id,
       p_budget_detail_id 		=> p_budget_detail_id,
       p_start_time_period_id 		=> p_start_time_period_id,
       p_end_time_period_id 		=> p_end_time_period_id,
       p_budget_unit1_percent           => p_budget_unit1_percent,
       p_budget_unit2_percent           => p_budget_unit2_percent,
       p_budget_unit3_percent       	=> p_budget_unit3_percent,
       p_budget_unit1_value 		=> p_budget_unit1_value,
       p_budget_unit2_value 		=> p_budget_unit2_value,
       p_budget_unit3_value 		=> p_budget_unit3_value,
       p_budget_unit1_value_type_cd 	=> p_budget_unit1_value_type_cd,
       p_budget_unit2_value_type_cd 	=> p_budget_unit2_value_type_cd,
       p_budget_unit3_value_type_cd 	=> p_budget_unit3_value_type_cd,
       p_budget_unit1_available         => p_budget_unit1_available,
       p_budget_unit2_available         => p_budget_unit2_available,
       p_budget_unit3_available         => p_budget_unit3_available,
       p_object_version_number 		=> p_object_version_number
      );
exception when others then
p_object_version_number := l_object_version_number;
raise;
end update_budget_period;
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
 ) is
begin
    pqh_budget_sets_api.create_budget_set
      (p_validate 			=> p_validate,
       p_budget_set_id 			=> p_budget_set_id,
       p_dflt_budget_set_id 		=> p_dflt_budget_set_id,
       p_budget_period_id 		=> p_budget_period_id,
       p_budget_unit1_percent           => p_budget_unit1_percent,
       p_budget_unit2_percent           => p_budget_unit2_percent,
       p_budget_unit3_percent       	=> p_budget_unit3_percent,
       p_budget_unit1_value 		=> p_budget_unit1_value,
       p_budget_unit2_value 		=> p_budget_unit2_value,
       p_budget_unit3_value 		=> p_budget_unit3_value,
       p_budget_unit1_available         => p_budget_unit1_available,
       p_budget_unit2_available         => p_budget_unit2_available,
       p_budget_unit3_available         => p_budget_unit3_available,
       p_budget_unit1_value_type_cd 	=> p_budget_unit1_value_type_cd,
       p_budget_unit2_value_type_cd 	=> p_budget_unit2_value_type_cd,
       p_budget_unit3_value_type_cd 	=> p_budget_unit3_value_type_cd,
       p_object_version_number 		=> p_object_version_number,
       p_effective_date 		=> p_effective_date
      );
exception when others then
p_budget_set_id := null;
p_object_version_number := null;
raise;
end create_budget_set;
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
  ) is
  l_object_version_number number := p_object_version_number;
begin
    pqh_budget_sets_api.update_budget_set
      (p_validate 			=> p_validate,
       p_budget_set_id 			=> p_budget_set_id,
       p_dflt_budget_set_id 		=> p_dflt_budget_set_id,
       p_budget_period_id 		=> p_budget_period_id,
       p_budget_unit1_percent           => p_budget_unit1_percent,
       p_budget_unit2_percent           => p_budget_unit2_percent,
       p_budget_unit3_percent       	=> p_budget_unit3_percent,
       p_budget_unit1_value 		=> p_budget_unit1_value,
       p_budget_unit2_value 		=> p_budget_unit2_value,
       p_budget_unit3_value 		=> p_budget_unit3_value,
       p_budget_unit1_available         => p_budget_unit1_available,
       p_budget_unit2_available         => p_budget_unit2_available,
       p_budget_unit3_available         => p_budget_unit3_available,
       p_budget_unit1_value_type_cd 	=> p_budget_unit1_value_type_cd,
       p_budget_unit2_value_type_cd 	=> p_budget_unit2_value_type_cd,
       p_budget_unit3_value_type_cd 	=> p_budget_unit3_value_type_cd,
       p_object_version_number 		=> p_object_version_number,
       p_effective_date 		=> p_effective_date
      );
exception when others then
p_object_version_number := l_object_version_number;
raise;
end update_budget_set;
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
 ) is
begin
    pqh_budget_details_api.create_budget_detail
      (p_validate 			=> p_validate,
       p_budget_detail_id 		=> p_budget_detail_id,
       p_organization_id 		=> p_organization_id,
       p_job_id 			=> p_job_id,
       p_position_id 			=> p_position_id,
       p_grade_id			=> p_grade_id,
       p_budget_version_id 		=> p_budget_version_id,
       p_budget_unit1_percent		=> p_budget_unit1_percent,
       p_budget_unit1_value_type_cd 	=> p_budget_unit1_value_type_cd,
       p_budget_unit1_value 		=> p_budget_unit1_value,
       p_budget_unit1_available		=> p_budget_unit1_available,
       p_budget_unit2_percent		=> p_budget_unit2_percent,
       p_budget_unit2_value_type_cd 	=> p_budget_unit2_value_type_cd,
       p_budget_unit2_value 		=> p_budget_unit2_value,
       p_budget_unit2_available		=> p_budget_unit2_available,
       p_budget_unit3_percent		=> p_budget_unit3_percent,
       p_budget_unit3_value_type_cd 	=> p_budget_unit3_value_type_cd,
       p_budget_unit3_value 		=> p_budget_unit3_value,
       p_budget_unit3_available		=> p_budget_unit3_available,
       p_gl_status			=> p_gl_status,
       p_object_version_number 		=> p_object_version_number
      );
exception when others then
p_budget_detail_id := null;
p_object_version_number := null;
raise;
end create_budget_detail;
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
  ) is
  l_object_version_number number := p_object_version_number;
begin
    pqh_budget_details_api.update_budget_detail
      (p_validate 			=> p_validate,
       p_budget_detail_id 		=> p_budget_detail_id,
       p_organization_id 		=> p_organization_id,
       p_job_id 			=> p_job_id,
       p_position_id 			=> p_position_id,
       p_grade_id			=> p_grade_id,
       p_budget_version_id 		=> p_budget_version_id,
       p_budget_unit1_percent		=> p_budget_unit1_percent,
       p_budget_unit1_value_type_cd 	=> p_budget_unit1_value_type_cd,
       p_budget_unit1_value 		=> p_budget_unit1_value,
       p_budget_unit1_available		=> p_budget_unit1_available,
       p_budget_unit2_percent		=> p_budget_unit2_percent,
       p_budget_unit2_value_type_cd 	=> p_budget_unit2_value_type_cd,
       p_budget_unit2_value 		=> p_budget_unit2_value,
       p_budget_unit2_available		=> p_budget_unit2_available,
       p_budget_unit3_percent		=> p_budget_unit3_percent,
       p_budget_unit3_value_type_cd 	=> p_budget_unit3_value_type_cd,
       p_budget_unit3_value 		=> p_budget_unit3_value,
       p_budget_unit3_available		=> p_budget_unit3_available,
       p_gl_status			=> p_gl_status,
       p_object_version_number 		=> p_object_version_number
      );
exception when others then
p_object_version_number := l_object_version_number;
raise;
end update_budget_detail;
--  ---------------------------------------------------------------------------
--  |-----------------<   POSITION_CONTROL_ENABLED    >---------------------|
--  ---------------------------------------------------------------------------
function position_control_enabled(p_organization_id 	number  default null,
                                  p_effective_date 	in date default sysdate,
                                  p_assignment_id 	number  default null
                                 )RETURN VARCHAR2 is
l_pc_enabled	VARCHAR2(1);
begin
    l_pc_enabled := pqh_psf_bus.position_control_enabled
      		      (p_organization_id 	=> p_organization_id,
       		       p_effective_date 	=> p_effective_date,
       		       p_assignment_id		=> p_assignment_id
      		      );
    return l_pc_enabled;
end position_control_enabled;
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
) is
begin
    hr_app_api_hook_call_internal.create_app_api_hook_call
      (p_validate                     => p_validate,
       p_effective_date               => p_effective_date,
       p_api_hook_id                  => p_api_hook_id,
       p_api_hook_call_type           => p_api_hook_call_type,
       p_sequence                     => p_sequence,
       p_application_id               => p_application_id,
       p_app_install_status           => p_app_install_status,
       p_enabled_flag                 => p_enabled_flag,
       p_call_package                 => p_call_package,
       p_call_procedure               => p_call_procedure,
       p_api_hook_call_id             => p_api_hook_call_id,
       p_object_version_number        => p_object_version_number
      );
exception when others then
p_api_hook_call_id := null;
p_object_version_number := null;
raise;
end create_app_api_hook_call;
END PQH_PSB_INTERFACE_API;

/
