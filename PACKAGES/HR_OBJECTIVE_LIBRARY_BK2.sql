--------------------------------------------------------
--  DDL for Package HR_OBJECTIVE_LIBRARY_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OBJECTIVE_LIBRARY_BK2" AUTHID CURRENT_USER as
/* $Header: pepmlapi.pkh 120.5 2006/10/20 04:03:46 tpapired noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< Update_Library_Objective_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_library_objective_b
  (p_effective_date                in   date
  ,p_objective_id                  in   number
  ,p_objective_name                in   varchar2
  ,p_valid_from                    in   date
  ,p_valid_to                      in   date
  ,p_target_date             	   in   date
  ,p_next_review_date              in   date
  ,p_group_code             	   in   varchar2
  ,p_priority_code          	   in   varchar2
  ,p_appraise_flag                 in   varchar2
  ,p_weighting_percent             in   number
  ,p_measurement_style_code        in   varchar2
  ,p_measure_name                  in   varchar2
  ,p_target_value                  in   number
  ,p_uom_code       	           in   varchar2
  ,p_measure_type_code             in   varchar2
  ,p_measure_comments              in   varchar2
  ,p_eligibility_type_code         in   varchar2
  ,p_details                       in   varchar2
  ,p_success_criteria              in   varchar2
  ,p_comments                      in   varchar2
  ,p_attribute_category            in   varchar2
  ,p_attribute1                    in   varchar2
  ,p_attribute2                    in   varchar2
  ,p_attribute3                    in   varchar2
  ,p_attribute4                    in   varchar2
  ,p_attribute5                    in   varchar2
  ,p_attribute6                    in   varchar2
  ,p_attribute7                    in   varchar2
  ,p_attribute8                    in   varchar2
  ,p_attribute9                    in   varchar2
  ,p_attribute10                   in   varchar2
  ,p_attribute11                   in   varchar2
  ,p_attribute12                   in   varchar2
  ,p_attribute13                   in   varchar2
  ,p_attribute14                   in   varchar2
  ,p_attribute15                   in   varchar2
  ,p_attribute16                   in   varchar2
  ,p_attribute17                   in   varchar2
  ,p_attribute18                   in   varchar2
  ,p_attribute19                   in   varchar2
  ,p_attribute20                   in   varchar2
  ,p_attribute21                   in   varchar2
  ,p_attribute22                   in   varchar2
  ,p_attribute23                   in   varchar2
  ,p_attribute24                   in   varchar2
  ,p_attribute25                   in   varchar2
  ,p_attribute26                   in   varchar2
  ,p_attribute27                   in   varchar2
  ,p_attribute28                   in   varchar2
  ,p_attribute29                   in   varchar2
  ,p_attribute30                   in   varchar2
  ,p_object_version_number         in   number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------<  Update_Library_Objective_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure  update_library_objective_a
  (p_effective_date                in   date
  ,p_objective_id		   in   number
  ,p_objective_name                in   varchar2
  ,p_valid_from                    in   date
  ,p_valid_to                      in   date
  ,p_target_date             	   in   date
  ,p_next_review_date              in   date
  ,p_group_code             	   in   varchar2
  ,p_priority_code          	   in   varchar2
  ,p_appraise_flag                 in   varchar2
  ,p_weighting_percent             in   number
  ,p_measurement_style_code        in   varchar2
  ,p_measure_name                  in   varchar2
  ,p_target_value                  in   number
  ,p_uom_code       		   in   varchar2
  ,p_measure_type_code             in   varchar2
  ,p_measure_comments              in   varchar2
  ,p_eligibility_type_code         in   varchar2
  ,p_details                       in   varchar2
  ,p_success_criteria              in   varchar2
  ,p_comments                      in   varchar2
  ,p_attribute_category            in   varchar2
  ,p_attribute1                    in   varchar2
  ,p_attribute2                    in   varchar2
  ,p_attribute3                    in   varchar2
  ,p_attribute4                    in   varchar2
  ,p_attribute5                    in   varchar2
  ,p_attribute6                    in   varchar2
  ,p_attribute7                    in   varchar2
  ,p_attribute8                    in   varchar2
  ,p_attribute9                    in   varchar2
  ,p_attribute10                   in   varchar2
  ,p_attribute11                   in   varchar2
  ,p_attribute12                   in   varchar2
  ,p_attribute13                   in   varchar2
  ,p_attribute14                   in   varchar2
  ,p_attribute15                   in   varchar2
  ,p_attribute16                   in   varchar2
  ,p_attribute17                   in   varchar2
  ,p_attribute18                   in   varchar2
  ,p_attribute19                   in   varchar2
  ,p_attribute20                   in   varchar2
  ,p_attribute21                   in   varchar2
  ,p_attribute22                   in   varchar2
  ,p_attribute23                   in   varchar2
  ,p_attribute24                   in   varchar2
  ,p_attribute25                   in   varchar2
  ,p_attribute26                   in   varchar2
  ,p_attribute27                   in   varchar2
  ,p_attribute28                   in   varchar2
  ,p_attribute29                   in   varchar2
  ,p_attribute30                   in   varchar2
  ,p_object_version_number         in   number
  ,p_duplicate_name_warning        in   boolean
  ,p_weighting_over_100_warning    in   boolean
  ,p_weighting_appraisal_warning   in   boolean
  );
--
end HR_OBJECTIVE_LIBRARY_BK2;

 

/
