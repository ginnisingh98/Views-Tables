--------------------------------------------------------
--  DDL for Package PAY_IE_SB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_SB_API" AUTHID CURRENT_USER as
/* $Header: pyisbapi.pkh 120.0 2005/05/29 06:01:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_IE_SB_DETAILS >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd    Type     Description
    -----------------------         ----    ----     -----------
--  p_validate                      N       IN      default false
--  p_effective_date                Y       IN
--  p_assignment_id                 Y       IN
--  p_absence_start_date            Y       IN
--  p_absence_end_date              Y       IN
--  p_benefit_amount                Y       IN
--  p_benefit_type                  Y       IN
--  p_calculation_option            Y       IN
--  p_reduced_tax_credit            N       IN      default null
--  p_reduced_standard_cutoff       N       IN      default null
--  p_incident_id                   N       IN      default null
--  p_social_benefit_id             Y       OUT
--  p_object_version_number         Y       OUT
--  p_effective_start_date          Y       OUT
--  p_effective_end_date            Y       OUT
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--   ----                           ----     -----------
--  p_social_benefit_id             out     number
--  p_object_version_number         out     number
--  p_effective_start_date          out     date
--  p_effective_end_date            out     date
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_ie_sb_details
  (p_validate                       in      boolean     default false
  ,p_effective_date                 in      date
  ,p_assignment_id                  in      number
  ,p_absence_start_date             in      date
  ,p_absence_end_date               in      date
  ,p_benefit_amount                 in      number
  ,p_benefit_type                   in      varchar2
  ,p_calculation_option             in      varchar2
  ,p_reduced_tax_credit             in      number      default null
  ,p_reduced_standard_cutoff        in      number      default null
  ,p_incident_id                    in      number      default null
  ,p_social_benefit_id              out     nocopy number
  ,p_object_version_number          out     nocopy number
  ,p_effective_start_date           out     nocopy date
  ,p_effective_end_date             out     nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_IE_SB_DETAILS >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd    Type     Description
    -----------------------         ----    ----     -----------
--  p_validate                      N       IN      default false
--  p_effective_date                Y       IN
--  p_datetrack_update_mode         Y       IN
--  p_absence_start_date            Y       IN
--  p_absence_end_date              Y       IN
--  p_benefit_amount                Y       IN
--  p_benefit_type                  Y       IN
--  p_calculation_option            Y       IN
--  p_reduced_tax_credit            N       IN      default null
--  p_reduced_standard_cutoff       N       IN      default null
--  p_incident_id                   N       IN      default null
--  p_social_benefit_id             Y       IN
--  p_object_version_number         Y       IN OUT
--  p_effective_start_date          Y       OUT
--  p_effective_end_date            Y       OUT
--
--
-- Post Success:
--
--
--  Name                            Type    Description
--  ----                            ----    -----------
--  p_object_version_number         IN OUT  number
--  p_effective_start_date          OUT     date
--  p_effective_end_date            OUT     date
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_ie_sb_details
  (p_validate                       in      boolean     default false
  ,p_effective_date                 in      date
  ,p_datetrack_update_mode          in      varchar2
  ,p_absence_start_date             in      date        default hr_api.g_date
  ,p_absence_end_date               in      date        default hr_api.g_date
  ,p_benefit_amount                 in      number      default hr_api.g_number
  ,p_benefit_type                   in      varchar2    default hr_api.g_varchar2
  ,p_calculation_option             in      varchar2    default hr_api.g_varchar2
  ,p_reduced_tax_credit             in      number      default hr_api.g_number
  ,p_reduced_standard_cutoff        in      number      default hr_api.g_number
  ,p_incident_id                    in      number      default hr_api.g_number
  ,p_social_benefit_id              in      number
  ,p_object_version_number          in out  nocopy number
  ,p_effective_start_date           out     nocopy date
  ,p_effective_end_date             out     nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< DELETE_IE_SB_DETAILS >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This process deletes Social Benefits details.
--
--
-- Prerequisites: pay_isb_del.del row handler for pay_ie_social_benefits_f table.
--
--
-- In Parameters:
--   Name                          Type    Reqd   Description
-- ------------------------------  ------- ------ ------------
-- P_VALIDATE                      IN      N      Default false
-- P_EFFECTIVE_DATE                IN      Y
-- P_DATETRACK_DELETE_MODE         IN      Y
-- P_SOCIAL_BENEFIT_ID             IN      Y
-- P_OBJECT_VERSION_NUMBER         IN OUT
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--  ------------------------------  -------  -------------------
--  P_OBJECT_VERSION_NUMBER         IN OUT
--  P_EFFECTIVE_START_DATE          OUT
--  P_EFFECTIVE_END_DATE            OUT
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}--
procedure delete_ie_sb_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_social_benefit_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date          out    nocopy date
  ,p_effective_end_date            out    nocopy date
  );
--

end pay_ie_sb_api;

 

/
