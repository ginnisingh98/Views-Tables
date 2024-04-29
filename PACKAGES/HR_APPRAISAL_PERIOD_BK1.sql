--------------------------------------------------------
--  DDL for Package HR_APPRAISAL_PERIOD_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPRAISAL_PERIOD_BK1" AUTHID CURRENT_USER as
/* $Header: pepmaapi.pkh 120.7.12010000.3 2010/02/22 06:38:33 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_appraisal_period_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_appraisal_period_b
  (p_effective_date               in     date
  ,p_plan_id                       in     number
  ,p_appraisal_template_id         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_task_start_date               in     date
  ,p_task_end_date                 in     date
  ,p_initiator_code                in     varchar2
  ,p_appraisal_system_type         in     varchar2
  ,p_appraisal_type                in     varchar2
  ,p_appraisal_assmt_status        in     varchar2
  ,p_auto_conc_process             in     varchar2
  ,p_days_before_task_st_dt        in     number
  ,p_participation_type            in     varchar2
  ,p_questionnaire_template_id     in     number
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
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_appraisal_period_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_appraisal_period_a
  (p_effective_date                in     date
  ,p_plan_id                       in     number
  ,p_appraisal_template_id         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_task_start_date               in     date
  ,p_task_end_date                 in     date
  ,p_initiator_code                in     varchar2
  ,p_appraisal_system_type         in     varchar2
  ,p_appraisal_type                in     varchar2
  ,p_appraisal_assmt_status        in     varchar2
  ,p_auto_conc_process             in     varchar2
  ,p_days_before_task_st_dt        in     number
  ,p_participation_type            in     varchar2
  ,p_questionnaire_template_id     in     number
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
  ,p_appraisal_period_id           in     number
  ,p_object_version_number         in     number
  );
--
end hr_appraisal_period_bk1;

/
