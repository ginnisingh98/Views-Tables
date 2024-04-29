--------------------------------------------------------
--  DDL for Package PER_PMA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PMA_RKD" AUTHID CURRENT_USER as
/* $Header: pepmarhi.pkh 120.2.12010000.2 2009/10/23 13:49:47 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_appraisal_period_id          in number
  ,p_object_version_number_o      in number
  ,p_plan_id_o                    in number
  ,p_appraisal_template_id_o      in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_task_start_date_o            in date
  ,p_task_end_date_o              in date
  ,p_initiator_code_o             in varchar2
  ,p_appraisal_system_type_o      in varchar2
  ,p_appraisal_type_o             in varchar2
  ,p_appraisal_assmt_status_o     in varchar2
  ,p_auto_conc_process_o          in varchar2
  ,p_days_before_task_st_dt_o     in number
  ,p_participation_type_o          in varchar2
  ,p_questionnaire_template_id_o   in number
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  );
--
end per_pma_rkd;

/
