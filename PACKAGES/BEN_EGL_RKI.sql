--------------------------------------------------------
--  DDL for Package BEN_EGL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EGL_RKI" as

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
     p_eligy_criteria_id              in  number
    ,p_name                           in  varchar2
    ,p_short_code                     in  varchar2
    ,p_description                    in  varchar2
    ,p_criteria_type		      in  varchar2
    ,p_crit_col1_val_type_cd	      in  varchar2
    ,p_crit_col1_datatype	      in  varchar2
    ,p_col1_lookup_type		      in  varchar2
    ,p_col1_value_set_id              in  number
    ,p_access_table_name1             in  varchar2
    ,p_access_column_name1	      in  varchar2
    ,p_time_entry_access_tab_nam1     in  varchar2
    ,p_time_entry_access_col_nam1     in  varchar2
    ,p_crit_col2_val_type_cd	      in  varchar2
    ,p_crit_col2_datatype	      in  varchar2
    ,p_col2_lookup_type		      in  varchar2
    ,p_col2_value_set_id              in  number
    ,p_access_table_name2	      in  varchar2
    ,p_access_column_name2	      in  varchar2
    ,p_time_entry_access_tab_nam2     in  varchar2
    ,p_time_entry_access_col_nam2     in  varchar2
    ,p_access_calc_rule		      in  number
    ,p_allow_range_validation_flg     in  varchar2
    ,p_user_defined_flag              in  varchar2
    ,p_business_group_id 	      in  number
    ,p_legislation_code 	      in  varchar2
    ,p_egl_attribute_category         in  varchar2
    ,p_egl_attribute1                 in  varchar2
    ,p_egl_attribute2                 in  varchar2
    ,p_egl_attribute3                 in  varchar2
    ,p_egl_attribute4                 in  varchar2
    ,p_egl_attribute5                 in  varchar2
    ,p_egl_attribute6                 in  varchar2
    ,p_egl_attribute7                 in  varchar2
    ,p_egl_attribute8                 in  varchar2
    ,p_egl_attribute9                 in  varchar2
    ,p_egl_attribute10                in  varchar2
    ,p_egl_attribute11                in  varchar2
    ,p_egl_attribute12                in  varchar2
    ,p_egl_attribute13                in  varchar2
    ,p_egl_attribute14                in  varchar2
    ,p_egl_attribute15                in  varchar2
    ,p_egl_attribute16                in  varchar2
    ,p_egl_attribute17                in  varchar2
    ,p_egl_attribute18                in  varchar2
    ,p_egl_attribute19                in  varchar2
    ,p_egl_attribute20                in  varchar2
    ,p_egl_attribute21                in  varchar2
    ,p_egl_attribute22                in  varchar2
    ,p_egl_attribute23                in  varchar2
    ,p_egl_attribute24                in  varchar2
    ,p_egl_attribute25                in  varchar2
    ,p_egl_attribute26                in  varchar2
    ,p_egl_attribute27                in  varchar2
    ,p_egl_attribute28                in  varchar2
    ,p_egl_attribute29                in  varchar2
    ,p_egl_attribute30                in  varchar2
    ,p_object_version_number          in  number
    ,p_effective_date                 in  date
    ,p_Allow_range_validation_flag2   in  Varchar2
    ,p_Access_calc_rule2              in  Number
    ,p_Time_access_calc_rule1         in  Number
    ,p_Time_access_calc_rule2         in  Number
  );
end ben_egl_rki;

 

/
