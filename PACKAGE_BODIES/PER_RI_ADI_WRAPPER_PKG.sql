--------------------------------------------------------
--  DDL for Package Body PER_RI_ADI_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_ADI_WRAPPER_PKG" As
/* $Header: periwrap.pkb 120.0.12010000.2 2009/10/08 11:49:44 sravikum ship $ */
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
   p_description                  In Varchar2) Is


Cursor csr_value_set_info Is

Select format_type, maximum_size, number_precision,alphanumeric_allowed_flag,
               uppercase_only_flag, numeric_mode_enabled_flag,
               minimum_value, maximum_value
 From fnd_flex_value_sets
Where flex_value_set_name = p_flex_value_set_name ;

l_format_type               varchar2(1) ;
l_maximum_size              number(3);
l_number_precision          number(2);
l_alphanumeric_allowed_flag varchar2(1);
l_uppercase_only_flag       varchar2(1);
l_numeric_mode_enabled_flag varchar2(1);
l_minimum_value             varchar2(150);
l_maximum_value             varchar2(150);
l_storage_value             Varchar2(2000);
l_display_value             Varchar2(2000);
l_error_message             Varchar2(2000);
l_success                   Boolean;

Begin


  Open csr_value_set_info ;
  Fetch csr_value_set_info Into l_format_type,l_maximum_size,l_number_precision,l_alphanumeric_allowed_flag,
                                l_uppercase_only_flag,l_numeric_mode_enabled_flag,l_minimum_value,l_maximum_value;
  Close csr_value_set_info;


  fnd_flex_val_util.validate_value
                            ( p_value          => p_flex_value
                             ,p_is_displayed   => True
                             ,p_vset_name      => p_flex_value_set_name
                             ,p_vset_format    => l_format_type
                             ,p_max_length     => l_maximum_size
                             ,p_precision      => l_number_precision
                             ,p_alpha_allowed  => l_alphanumeric_allowed_flag
                             ,p_uppercase_only => l_uppercase_only_flag
                             ,p_zero_fill      => l_numeric_mode_enabled_flag
                             ,p_min_value      => l_minimum_value
                             ,p_max_value      => l_maximum_value
                             ,x_storage_value  => l_storage_value
                             ,x_display_value  => l_display_value
                             ,x_success        => l_success);

 If l_success Then


   fnd_flex_loader_apis.up_vset_value
                         ( p_upload_phase                 =>  p_upload_phase
                          ,p_upload_mode                  =>  p_upload_mode
                          ,p_custom_mode                  =>  'FORCE'
                          ,p_flex_value_set_name          =>  p_flex_value_set_name
                          ,p_parent_flex_value_low        =>  p_parent_flex_value_low
                          ,p_flex_value                   =>  l_storage_value
                          ,p_owner                        =>  fnd_load_util.owner_name(p_owner)
                          ,p_last_update_date             =>  p_last_update_date
                          ,p_enabled_flag                 =>  p_enabled_flag
                          ,p_summary_flag                 =>  p_summary_flag
                          ,p_start_date_active            =>  p_start_date_active
                          ,p_end_date_active              =>  p_end_date_active
                          ,p_parent_flex_value_high       =>  p_parent_flex_value_high
                          ,p_rollup_hierarchy_code        =>  p_rollup_hierarchy_code
                          ,p_hierarchy_level              =>  p_hierarchy_level
                          ,p_compiled_value_attributes    =>  p_compiled_value_attributes
                          ,p_value_category               =>  p_value_category
                          ,p_attribute1                   =>  p_attribute1
                          ,p_attribute2                   =>  p_attribute2
                          ,p_attribute3                   =>  p_attribute3
                          ,p_attribute4                   =>  p_attribute4
                          ,p_attribute5                   =>  p_attribute5
                          ,p_attribute6                   =>  p_attribute6
                          ,p_attribute7                   =>  p_attribute7
                          ,p_attribute8                   =>  p_attribute8
                          ,p_attribute9                   =>  p_attribute9
                          ,p_attribute10                  =>  p_attribute10
                          ,p_attribute11                  =>  p_attribute11
                          ,p_attribute12                  =>  p_attribute12
                          ,p_attribute13                  =>  p_attribute13
                          ,p_attribute14                  =>  p_attribute14
                          ,p_attribute15                  =>  p_attribute15
                          ,p_attribute16                  =>  p_attribute16
                          ,p_attribute17                  =>  p_attribute17
                          ,p_attribute18                  =>  p_attribute18
                          ,p_attribute19                  =>  p_attribute19
                          ,p_attribute20                  =>  p_attribute20
                          ,p_attribute21                  =>  p_attribute21
                          ,p_attribute22                  =>  p_attribute22
                          ,p_attribute23                  =>  p_attribute23
                          ,p_attribute24                  =>  p_attribute24
                          ,p_attribute25                  =>  p_attribute25
                          ,p_attribute26                  =>  p_attribute26
                          ,p_attribute27                  =>  p_attribute27
                          ,p_attribute28                  =>  p_attribute28
                          ,p_attribute29                  =>  p_attribute29
                          ,p_attribute30                  =>  p_attribute30
                          ,p_attribute31                  =>  p_attribute31
                          ,p_attribute32                  =>  p_attribute32
                          ,p_attribute33                  =>  p_attribute33
                          ,p_attribute34                  =>  p_attribute34
                          ,p_attribute35                  =>  p_attribute35
                          ,p_attribute36                  =>  p_attribute36
                          ,p_attribute37                  =>  p_attribute37
                          ,p_attribute38                  =>  p_attribute38
                          ,p_attribute39                  =>  p_attribute39
                          ,p_attribute40                  =>  p_attribute40
                          ,p_attribute41                  =>  p_attribute41
                          ,p_attribute42                  =>  p_attribute42
                          ,p_attribute43                  =>  p_attribute43
                          ,p_attribute44                  =>  p_attribute44
                          ,p_attribute45                  =>  p_attribute45
                          ,p_attribute46                  =>  p_attribute46
                          ,p_attribute47                  =>  p_attribute47
                          ,p_attribute48                  =>  p_attribute48
                          ,p_attribute49                  =>  p_attribute49
                          ,p_attribute50                  =>  p_attribute50
                          ,p_flex_value_meaning           =>  l_display_value
                          ,p_description                  =>  p_description
                          );
 End If;

End  up_vset_value;

Procedure create_organization(p_batch_id                    Number
                             ,p_data_pump_batch_line_id     Number     Default Null
                             ,p_user_sequence               Number     Default Null
                             ,p_link_value                  Number     Default Null
                             ,p_effective_date              Date
                             ,p_language_code               Varchar2   Default Null
                             ,p_date_from                   Date
                             ,p_name                        Varchar2
                             ,p_date_to                     Date       Default Null
                             ,p_internal_external_flag      Varchar2   Default Null
                             ,p_internal_address_line       Varchar2   Default Null
                             ,p_type                        Varchar2   Default Null
                             ,p_attribute_category          Varchar2   Default Null
                             ,p_attribute1                  Varchar2   Default Null
                             ,p_attribute2                  Varchar2   Default Null
                             ,p_attribute3                  Varchar2   Default Null
                             ,p_attribute4                  Varchar2   Default Null
                             ,p_attribute5                  Varchar2   Default Null
                             ,p_attribute6                  Varchar2   Default Null
                             ,p_attribute7                  Varchar2   Default Null
                             ,p_attribute8                  Varchar2   Default Null
                             ,p_attribute9                  Varchar2   Default Null
                             ,p_attribute10                 Varchar2   Default Null
                             ,p_attribute11                 Varchar2   Default Null
                             ,p_attribute12                 Varchar2   Default Null
                             ,p_attribute13                 Varchar2   Default Null
                             ,p_attribute14                 Varchar2   Default Null
                             ,p_attribute15                 Varchar2   Default Null
                             ,p_attribute16                 Varchar2   Default Null
                             ,p_attribute17                 Varchar2   Default Null
                             ,p_attribute18                 Varchar2   Default Null
                             ,p_attribute19                 Varchar2   Default Null
                             ,p_attribute20                 Varchar2   Default Null
                             ,p_org_user_key                Varchar2   Default Null
                             ,p_location_code               Varchar2   Default Null
                             ,p_org_classification1         Varchar2   Default Null
                             ,p_org_classification2         Varchar2   Default Null
                             ,p_org_classification3         Varchar2   Default Null
                             ,p_org_classification4         Varchar2   Default Null
                             ,p_org_classification5         Varchar2   Default Null
                             ) Is

 Type org_class Is VARRAY(5) Of Varchar2(60) ;
 Type batch_line_ids Is Table of Number Index By Binary_Integer;

 l_org_class org_class := org_class(p_org_classification1,p_org_classification2,p_org_classification3,p_org_classification4,p_org_classification5);

 l_batch_line_id batch_line_ids;
 l_user_seq number;

Begin


If p_data_pump_batch_line_id Is Not Null Then

     l_batch_line_id(1)   := substr(p_data_pump_batch_line_id,0,instr(p_data_pump_batch_line_id,'X',1,1)-1);
     l_batch_line_id(2)   := substr(p_data_pump_batch_line_id,instr(p_data_pump_batch_line_id,'X',1,1)+1,instr(p_data_pump_batch_line_id,'X',1,2)-instr(p_data_pump_batch_line_id,'X',1,1)-1);
     l_batch_line_id(3)   := substr(p_data_pump_batch_line_id,instr(p_data_pump_batch_line_id,'X',1,2)+1,instr(p_data_pump_batch_line_id,'X',1,3)-instr(p_data_pump_batch_line_id,'X',1,2)-1);
     l_batch_line_id(4)   := substr(p_data_pump_batch_line_id,instr(p_data_pump_batch_line_id,'X',1,3)+1,instr(p_data_pump_batch_line_id,'X',1,4)-instr(p_data_pump_batch_line_id,'X',1,3)-1);
     l_batch_line_id(5)   := substr(p_data_pump_batch_line_id,instr(p_data_pump_batch_line_id,'X',1,4)+1,instr(p_data_pump_batch_line_id,'X',1,5)-instr(p_data_pump_batch_line_id,'X',1,4)-1);

End If;


hrdpp_create_organization.insert_batch_lines(p_batch_id                   => p_batch_id
                                            ,p_data_pump_batch_line_id    => p_data_pump_batch_line_id
                                            ,p_user_sequence              => p_user_sequence
                                            ,p_link_value                 => p_link_value
                                            ,p_effective_date             => p_effective_date
                                            ,p_language_code              => p_language_code
                                            ,p_date_from                  => p_date_from
                                            ,p_name                       => p_name
                                            ,p_date_to                    => p_date_to
                                            ,p_internal_external_flag     => p_internal_external_flag
                                            ,p_internal_address_line      => p_internal_address_line
                                            ,p_type                       => p_type
                                            ,p_attribute_category         => p_attribute_category
                                            ,p_attribute1                 => p_attribute1
                                            ,p_attribute2                 => p_attribute2
                                            ,p_attribute3                 => p_attribute3
                                            ,p_attribute4                 => p_attribute4
                                            ,p_attribute5                 => p_attribute5
                                            ,p_attribute6                 => p_attribute6
                                            ,p_attribute7                 => p_attribute7
                                            ,p_attribute8                 => p_attribute8
                                            ,p_attribute9                 => p_attribute9
                                            ,p_attribute10                => p_attribute10
                                            ,p_attribute11                => p_attribute11
                                            ,p_attribute12                => p_attribute12
                                            ,p_attribute13                => p_attribute13
                                            ,p_attribute14                => p_attribute14
                                            ,p_attribute15                => p_attribute15
                                            ,p_attribute16                => p_attribute16
                                            ,p_attribute17                => p_attribute17
                                            ,p_attribute18                => p_attribute18
                                            ,p_attribute19                => p_attribute19
                                            ,p_attribute20                => p_attribute20
                                            ,p_org_user_key               => p_org_user_key
                                            ,p_location_code              => p_location_code
                                            );

l_user_seq :=p_user_sequence+10; -- For the user sequence to be in sequence.bug 8996171
 For x in 1..5 Loop

   If l_org_class(x) Is Not Null Then

        hrdpp_create_org_classificatio.insert_batch_lines(
                                                     p_batch_id                   => p_batch_id
                                                    ,p_data_pump_batch_line_id    => p_data_pump_batch_line_id
                                                    ,p_user_sequence              => l_user_seq
                                                    ,p_link_value                 => p_link_value
                                                    ,p_effective_date             => p_effective_date
                                                    ,p_org_classif_code           => l_org_class(x)
                                                    ,p_organization_name          => p_name
                                                    ,p_language_code              => p_language_code
                                                    );

    End If;

 End Loop;


End create_organization;

End per_ri_adi_wrapper_pkg;

/
