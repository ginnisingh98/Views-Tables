--------------------------------------------------------
--  DDL for Package PER_RI_ADI_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_ADI_WRAPPER_PKG" AUTHID CURRENT_USER As
/* $Header: periwrap.pkh 120.0 2005/05/31 18:10:45 appldev noship $ */

procedure up_vset_value
  (p_upload_phase                 In Varchar2,
   p_upload_mode                  In Varchar2,
   p_custom_mode                  In Varchar2 Default Null,
   p_flex_value_set_name          In Varchar2,
   p_parent_flex_value_low        In Varchar2,
   p_flex_value                   In Varchar2,
   p_owner                        In Varchar2,
   p_last_update_date             In Varchar2 Default Null,
   p_enabled_flag                 In Varchar2,
   p_summary_flag                 In Varchar2,
   p_start_date_active            In Varchar2,
   p_end_date_active              In Varchar2,
   p_parent_flex_value_high       In Varchar2,
   p_rollup_hierarchy_code        In Varchar2,
   p_hierarchy_level              In Varchar2,
   p_compiled_value_attributes    In Varchar2,
   p_value_category               In Varchar2,
   p_attribute1                   In Varchar2,
   p_attribute2                   In Varchar2,
   p_attribute3                   In Varchar2,
   p_attribute4                   In Varchar2,
   p_attribute5                   In Varchar2,
   p_attribute6                   In Varchar2,
   p_attribute7                   In Varchar2,
   p_attribute8                   In Varchar2,
   p_attribute9                   In Varchar2,
   p_attribute10                  In Varchar2,
   p_attribute11                  In Varchar2,
   p_attribute12                  In Varchar2,
   p_attribute13                  In Varchar2,
   p_attribute14                  In Varchar2,
   p_attribute15                  In Varchar2,
   p_attribute16                  In Varchar2,
   p_attribute17                  In Varchar2,
   p_attribute18                  In Varchar2,
   p_attribute19                  In Varchar2,
   p_attribute20                  In Varchar2,
   p_attribute21                  In Varchar2,
   p_attribute22                  In Varchar2,
   p_attribute23                  In Varchar2,
   p_attribute24                  In Varchar2,
   p_attribute25                  In Varchar2,
   p_attribute26                  In Varchar2,
   p_attribute27                  In Varchar2,
   p_attribute28                  In Varchar2,
   p_attribute29                  In Varchar2,
   p_attribute30                  In Varchar2,
   p_attribute31                  In Varchar2,
   p_attribute32                  In Varchar2,
   p_attribute33                  In Varchar2,
   p_attribute34                  In Varchar2,
   p_attribute35                  In Varchar2,
   p_attribute36                  In Varchar2,
   p_attribute37                  In Varchar2,
   p_attribute38                  In Varchar2,
   p_attribute39                  In Varchar2,
   p_attribute40                  In Varchar2,
   p_attribute41                  In Varchar2,
   p_attribute42                  In Varchar2,
   p_attribute43                  In Varchar2,
   p_attribute44                  In Varchar2,
   p_attribute45                  In Varchar2,
   p_attribute46                  In Varchar2,
   p_attribute47                  In Varchar2,
   p_attribute48                  In Varchar2,
   p_attribute49                  In Varchar2,
   p_attribute50                  In Varchar2,
   p_flex_value_meaning           In Varchar2,
   p_description                  In Varchar2);

Procedure create_organization(p_batch_id                    In Number
                             ,p_data_pump_batch_line_id     In Number     Default Null
                             ,p_user_sequence               In Number     Default Null
                             ,p_link_value                  In Number     Default Null
                             ,p_effective_date              In Date
                             ,p_language_code               In Varchar2   Default Null
                             ,p_date_from                   In Date
                             ,p_name                        In Varchar2
                             ,p_date_to                     In Date       Default Null
                             ,p_internal_external_flag      In Varchar2   Default Null
                             ,p_internal_address_line       In Varchar2   Default Null
                             ,p_type                        In Varchar2   Default Null
                             ,p_attribute_category          In Varchar2   Default Null
                             ,p_attribute1                  In Varchar2   Default Null
                             ,p_attribute2                  In Varchar2   Default Null
                             ,p_attribute3                  In Varchar2   Default Null
                             ,p_attribute4                  In Varchar2   Default Null
                             ,p_attribute5                  In Varchar2   Default Null
                             ,p_attribute6                  In Varchar2   Default Null
                             ,p_attribute7                  In Varchar2   Default Null
                             ,p_attribute8                  In Varchar2   Default Null
                             ,p_attribute9                  In Varchar2   Default Null
                             ,p_attribute10                 In Varchar2   Default Null
                             ,p_attribute11                 In Varchar2   Default Null
                             ,p_attribute12                 In Varchar2   Default Null
                             ,p_attribute13                 In Varchar2   Default Null
                             ,p_attribute14                 In Varchar2   Default Null
                             ,p_attribute15                 In Varchar2   Default Null
                             ,p_attribute16                 In Varchar2   Default Null
                             ,p_attribute17                 In Varchar2   Default Null
                             ,p_attribute18                 In Varchar2   Default Null
                             ,p_attribute19                 In Varchar2   Default Null
                             ,p_attribute20                 In Varchar2   Default Null
                             ,p_org_user_key                In Varchar2   Default Null
                             ,p_location_code               In Varchar2   Default Null
                             ,p_org_classification1         In Varchar2   Default Null
                             ,p_org_classification2         In Varchar2   Default Null
                             ,p_org_classification3         In Varchar2   Default Null
                             ,p_org_classification4         In Varchar2   Default Null
                             ,p_org_classification5         In Varchar2   Default Null
                             );

end per_ri_adi_wrapper_pkg;

 

/
