--------------------------------------------------------
--  DDL for Package BEN_DPNT_ELIG_CRIT_VAL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPNT_ELIG_CRIT_VAL_BK2" AUTHID CURRENT_USER AS
/* $Header: beedvapi.pkh 120.0.12010000.4 2010/04/19 07:30:10 pvelvano noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_dpnt_eligy_crit_val_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_dpnt_eligy_crit_val_b
  (
   p_dpnt_eligy_crit_values_id         In  Number
  ,p_dpnt_cvg_eligy_prfl_id                In  Number
  ,p_eligy_criteria_dpnt_id            In  Number
  ,p_ordr_num                     In  Number
  ,p_number_value1                In  Number
  ,p_number_value2                In  Number
  ,p_char_value1                  In  Varchar2
  ,p_char_value2                  In  Varchar2
  ,p_date_value1                  In  Date
  ,p_date_value2                  In  Date
  ,p_excld_flag                   In  Varchar2
  ,p_business_group_id            In  Number
  ,p_edc_attribute_category       In  Varchar2
  ,p_edc_attribute1               In  Varchar2
  ,p_edc_attribute2               In  Varchar2
  ,p_edc_attribute3               In  Varchar2
  ,p_edc_attribute4               In  Varchar2
  ,p_edc_attribute5               In  Varchar2
  ,p_edc_attribute6               In  Varchar2
  ,p_edc_attribute7               In  Varchar2
  ,p_edc_attribute8               In  Varchar2
  ,p_edc_attribute9               In  Varchar2
  ,p_edc_attribute10              In  Varchar2
  ,p_edc_attribute11              In  Varchar2
  ,p_edc_attribute12              In  Varchar2
  ,p_edc_attribute13              In  Varchar2
  ,p_edc_attribute14              In  Varchar2
  ,p_edc_attribute15              In  Varchar2
  ,p_edc_attribute16              In  Varchar2
  ,p_edc_attribute17              In  Varchar2
  ,p_edc_attribute18              In  Varchar2
  ,p_edc_attribute19              In  Varchar2
  ,p_edc_attribute20              In  Varchar2
  ,p_edc_attribute21              In  Varchar2
  ,p_edc_attribute22              In  Varchar2
  ,p_edc_attribute23              In  Varchar2
  ,p_edc_attribute24              In  Varchar2
  ,p_edc_attribute25              In  Varchar2
  ,p_edc_attribute26              In  Varchar2
  ,p_edc_attribute27              In  Varchar2
  ,p_edc_attribute28              In  Varchar2
  ,p_edc_attribute29              In  Varchar2
  ,p_edc_attribute30              In  Varchar2
  ,p_object_version_number        In  Number
  ,p_effective_date               In  Date
  ,p_datetrack_mode               In  Varchar2
  ,p_char_value3                  In  Varchar2
  ,p_char_value4                  In  Varchar2
  ,p_number_value3                In  Number
  ,p_number_value4                In  Number
  ,p_date_value3                  In  Date
  ,p_date_value4                  In  Date
  );
  --
-- ----------------------------------------------------------------------------
-- |---------------------------< update_dpnt_eligy_crit_val_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_dpnt_eligy_crit_val_a
  (
   p_dpnt_eligy_crit_values_id         In  Number
  ,p_dpnt_cvg_eligy_prfl_id                In  Number
  ,p_eligy_criteria_dpnt_id            In  Number
  ,p_ordr_num                     In  Number
  ,p_effective_start_date         In  Date
  ,p_effective_end_date           In  Date
  ,p_number_value1                In  Number
  ,p_number_value2                In  Number
  ,p_char_value1                  In  Varchar2
  ,p_char_value2                  In  Varchar2
  ,p_date_value1                  In  Date
  ,p_date_value2                  In  Date
  ,p_excld_flag                   In  Varchar2
  ,p_business_group_id            In  Number
  ,p_edc_attribute_category       In  Varchar2
  ,p_edc_attribute1               In  Varchar2
  ,p_edc_attribute2               In  Varchar2
  ,p_edc_attribute3               In  Varchar2
  ,p_edc_attribute4               In  Varchar2
  ,p_edc_attribute5               In  Varchar2
  ,p_edc_attribute6               In  Varchar2
  ,p_edc_attribute7               In  Varchar2
  ,p_edc_attribute8               In  Varchar2
  ,p_edc_attribute9               In  Varchar2
  ,p_edc_attribute10              In  Varchar2
  ,p_edc_attribute11              In  Varchar2
  ,p_edc_attribute12              In  Varchar2
  ,p_edc_attribute13              In  Varchar2
  ,p_edc_attribute14              In  Varchar2
  ,p_edc_attribute15              In  Varchar2
  ,p_edc_attribute16              In  Varchar2
  ,p_edc_attribute17              In  Varchar2
  ,p_edc_attribute18              In  Varchar2
  ,p_edc_attribute19              In  Varchar2
  ,p_edc_attribute20              In  Varchar2
  ,p_edc_attribute21              In  Varchar2
  ,p_edc_attribute22              In  Varchar2
  ,p_edc_attribute23              In  Varchar2
  ,p_edc_attribute24              In  Varchar2
  ,p_edc_attribute25              In  Varchar2
  ,p_edc_attribute26              In  Varchar2
  ,p_edc_attribute27              In  Varchar2
  ,p_edc_attribute28              In  Varchar2
  ,p_edc_attribute29              In  Varchar2
  ,p_edc_attribute30              In  Varchar2
  ,p_object_version_number        In  Number
  ,p_effective_date               In  Date
  ,p_datetrack_mode               In  Varchar2
  ,p_char_value3                  In  Varchar2
  ,p_char_value4                  In  Varchar2
  ,p_number_value3                In  Number
  ,p_number_value4                In  Number
  ,p_date_value3                  In  Date
  ,p_date_value4                  In  Date
  );
--
end ben_dpnt_elig_crit_val_bk2;

/