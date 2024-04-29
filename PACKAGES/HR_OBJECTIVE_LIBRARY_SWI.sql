--------------------------------------------------------
--  DDL for Package HR_OBJECTIVE_LIBRARY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OBJECTIVE_LIBRARY_SWI" AUTHID CURRENT_USER As
/* $Header: pepmlswi.pkh 120.1.12010000.1 2008/07/28 05:22:26 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_library_objective >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_objective_library_api.create_library_objective
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_library_objective
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_objective_name               in     varchar2
  ,p_valid_from                   in     date      default null
  ,p_valid_to                     in     date      default null
  ,p_target_date                  in     date      default null
  ,p_next_review_date             in     date      default null
  ,p_group_code                   in     varchar2  default null
  ,p_priority_code                in     varchar2  default null
  ,p_appraise_flag                in     varchar2  default 'Y'
  ,p_weighting_percent            in     number    default null
  ,p_measurement_style_code       in     varchar2  default 'N_M'
  ,p_measure_name                 in     varchar2  default null
  ,p_target_value                 in     number    default null
  ,p_uom_code                     in     varchar2  default null
  ,p_measure_type_code            in     varchar2  default null
  ,p_measure_comments             in     varchar2  default null
  ,p_eligibility_type_code        in     varchar2  default 'N_P'
  ,p_details                      in     varchar2  default null
  ,p_success_criteria             in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_objective_id                 in out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_library_objective >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_objective_library_api.delete_library_objective
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_library_objective
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_objective_id                 in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_library_objective >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_objective_library_api.update_library_objective
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_library_objective
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_objective_id                 in     number
  ,p_objective_name               in     varchar2  default hr_api.g_varchar2
  ,p_valid_from                   in     date      default hr_api.g_date
  ,p_valid_to                     in     date      default hr_api.g_date
  ,p_target_date                  in     date      default hr_api.g_date
  ,p_next_review_date             in     date      default hr_api.g_date
  ,p_group_code                   in     varchar2  default hr_api.g_varchar2
  ,p_priority_code                in     varchar2  default hr_api.g_varchar2
  ,p_appraise_flag                in     varchar2  default hr_api.g_varchar2
  ,p_weighting_percent            in     number    default hr_api.g_number
  ,p_measurement_style_code       in     varchar2  default hr_api.g_varchar2
  ,p_measure_name                 in     varchar2  default hr_api.g_varchar2
  ,p_target_value                 in     number    default hr_api.g_number
  ,p_uom_code                     in     varchar2  default hr_api.g_varchar2
  ,p_measure_type_code            in     varchar2  default hr_api.g_varchar2
  ,p_measure_comments             in     varchar2  default hr_api.g_varchar2
  ,p_eligibility_type_code        in     varchar2  default hr_api.g_varchar2
  ,p_details                      in     varchar2  default hr_api.g_varchar2
  ,p_success_criteria             in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_eligy_profile >-------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  number  Commit or Rollback.
--   p_name                         Yes  varchar2
--   p_elig_pstn_flag               No   varchar2
--   p_elig_grd_flag                No   varchar2
--   p_elig_org_unit_flag           No   varchar2
--   p_elig_job_flag                No   varchar2
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_profile
 (p_validate            in    number    default hr_api.g_false_num
 ,p_name                in    varchar2  default null
 ,p_bnft_cagr_prtn_cd   in    varchar2  default null
 ,p_stat_cd             in    varchar2  default null
 ,p_asmt_to_use_cd      in    varchar2  default null
 ,p_eligy_prfl_id       in out nocopy number
 ,p_elig_grd_flag       in    varchar2  default 'N'
 ,p_elig_org_unit_flag  in    varchar2  default 'N'
 ,p_elig_job_flag       in    varchar2  default 'N'
 ,p_elig_pstn_flag      in    varchar2  default 'N'
 ,p_object_version_number out nocopy number
 ,p_business_group_id   in    number
 ,p_effective_date      in    date
 ,p_effective_start_date  out nocopy date
 ,p_effective_end_date    out nocopy date
 ,p_return_status         out nocopy varchar2
 );

-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_profile >-------------------------|
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


procedure update_eligy_profile
 ( p_validate             in    number  default hr_api.g_false_num
  ,p_effective_date       in    date
  ,p_business_group_id    in    number
  ,p_name                 in     varchar2  default null
  ,p_bnft_cagr_prtn_cd     in    varchar2  default null
  ,p_stat_cd               in    varchar2  default null
  ,p_asmt_to_use_cd        in    varchar2  default null
  ,p_elig_grd_flag         in    varchar2  default 'N'
  ,p_elig_org_unit_flag    in    varchar2  default 'N'
  ,p_elig_job_flag         in    varchar2  default 'N'
  ,p_elig_pstn_flag        in    varchar2  default 'N'
  ,p_eligy_prfl_id         in   number
  ,p_object_version_number in out nocopy number
  ,p_effective_start_date   out nocopy date
  ,p_effective_end_date     out nocopy date
  ,p_datetrack_mode   in varchar2
  ,p_return_status          out nocopy varchar2
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_eligy_object >-------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  number  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_object
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_obj_id                    in out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number
  ,p_table_name                     in  varchar2
  ,p_column_name                    in  varchar2
  ,p_column_value                   in  varchar2
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_eligy_object >-------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  number  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_object
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_obj_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_table_name                     in  varchar2  default hr_api.g_varchar2
  ,p_column_name                    in  varchar2  default hr_api.g_varchar2
  ,p_column_value                   in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_eligy_object >-------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  number  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_object
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_obj_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_elig_obj_elig_prfl >----------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_elig_obj_elig_prfl
  (p_validate                   in    number default hr_api.g_false_num
  ,p_elig_obj_elig_prfl_id      in out nocopy number
  ,p_effective_start_date         out nocopy date
  ,p_effective_end_date           out nocopy date
  ,p_business_group_id          in    number    default null
  ,p_elig_obj_id                in    number    default null
  ,p_elig_prfl_id               in    number    default null
  ,p_object_version_number        out nocopy number
  ,p_effective_date             in    date
 );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_elig_obj_elig_prfl >----------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_elig_obj_elig_prfl
  (p_validate                       in number default hr_api.g_false_num
  ,p_elig_obj_elig_prfl_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_elig_obj_id                    in  number    default hr_api.g_number
  ,p_elig_prfl_id                   in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_elig_obj_elig_prfl >----------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  number   Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_elig_obj_elig_prfl
  (p_validate                       in number default hr_api.g_false_num
  ,p_elig_obj_elig_prfl_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_grade >------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_grade
 (p_validate                     in    number default hr_api.g_false_num
 ,p_elig_grd_prte_id              in out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_grade_id                     in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_grade >------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_grade
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_grd_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_grade_id                       in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_grade >--------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_grade
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_grd_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_org >--------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_org
 (p_validate                     in    number default hr_api.g_false_num
 ,p_elig_org_unit_prte_id         in out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_organization_id              in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_eligy_org >--------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_org
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_org_unit_prte_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_org >--------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_org
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_org_unit_prte_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_eligy_positon >------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_position
 (p_validate                     in     number default hr_api.g_false_num
 ,p_elig_pstn_prte_id             in  out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_position_id                  in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_position >------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_position
  (p_validate                       in   number default hr_api.g_false_num
  ,p_elig_pstn_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_position_id                    in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_eligy_position >-----------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_position
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_pstn_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_job >------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_eligy_job
 (p_validate                     in    number default hr_api.g_false_num
 ,p_elig_job_prte_id              in out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_job_id                       in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_job >------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_eligy_job
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_job_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_job_id                       in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_job >--------------------------|
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
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_eligy_job
  (p_validate                       in  number default hr_api.g_false_num
  ,p_elig_job_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--


 end hr_objective_library_swi;

/
