--------------------------------------------------------
--  DDL for Package BEN_RCL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RCL_RKI" AUTHID CURRENT_USER as
/* $Header: berclrhi.pkh 120.0 2005/05/28 11:35:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_rltd_per_chg_cs_ler_id         in number
 ,p_name                           in varchar2
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_old_val                        in varchar2
 ,p_new_val                        in varchar2
 ,p_whatif_lbl_txt                 in varchar2
 ,p_rule_overrides_flag                 in varchar2
 ,p_source_column                  in varchar2
 ,p_source_table                   in varchar2
 ,p_rltd_per_chg_cs_ler_rl         in number
 ,p_business_group_id              in number
 ,p_rcl_attribute_category         in varchar2
 ,p_rcl_attribute1                 in varchar2
 ,p_rcl_attribute2                 in varchar2
 ,p_rcl_attribute3                 in varchar2
 ,p_rcl_attribute4                 in varchar2
 ,p_rcl_attribute5                 in varchar2
 ,p_rcl_attribute6                 in varchar2
 ,p_rcl_attribute7                 in varchar2
 ,p_rcl_attribute8                 in varchar2
 ,p_rcl_attribute9                 in varchar2
 ,p_rcl_attribute10                in varchar2
 ,p_rcl_attribute11                in varchar2
 ,p_rcl_attribute12                in varchar2
 ,p_rcl_attribute13                in varchar2
 ,p_rcl_attribute14                in varchar2
 ,p_rcl_attribute15                in varchar2
 ,p_rcl_attribute16                in varchar2
 ,p_rcl_attribute17                in varchar2
 ,p_rcl_attribute18                in varchar2
 ,p_rcl_attribute19                in varchar2
 ,p_rcl_attribute20                in varchar2
 ,p_rcl_attribute21                in varchar2
 ,p_rcl_attribute22                in varchar2
 ,p_rcl_attribute23                in varchar2
 ,p_rcl_attribute24                in varchar2
 ,p_rcl_attribute25                in varchar2
 ,p_rcl_attribute26                in varchar2
 ,p_rcl_attribute27                in varchar2
 ,p_rcl_attribute28                in varchar2
 ,p_rcl_attribute29                in varchar2
 ,p_rcl_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_rcl_rki;

 

/
