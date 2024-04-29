--------------------------------------------------------
--  DDL for Package HR_PERSONAL_SCORECARD_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSONAL_SCORECARD_BK2" AUTHID CURRENT_USER as
/* $Header: pepmsapi.pkh 120.5 2006/10/24 15:51:09 tpapired noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_scorecard_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_scorecard_b
  (p_effective_date                in     date
  ,p_scorecard_id                  in     number
  ,p_object_version_number         in     number
  ,p_scorecard_name                in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_plan_id                       in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_status_code                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_scorecard_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_scorecard_a
  (p_effective_date                in     date
  ,p_scorecard_id                  in     number
  ,p_object_version_number         in     number
  ,p_scorecard_name                in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_plan_id                       in     number
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_status_code                   in     varchar2
  ,p_duplicate_name_warning        in     boolean
  );
--
end hr_personal_scorecard_bk2;

 

/
