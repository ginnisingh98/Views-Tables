--------------------------------------------------------
--  DDL for Package BEN_PST_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PST_RKI" AUTHID CURRENT_USER as
/* $Header: bepstrhi.pkh 120.0.12010000.1 2008/07/29 12:57:38 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_pstn_rt_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_position_id                        in number
 ,p_vrbl_rt_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_pst_attribute_category         in varchar2
 ,p_pst_attribute1                 in varchar2
 ,p_pst_attribute2                 in varchar2
 ,p_pst_attribute3                 in varchar2
 ,p_pst_attribute4                 in varchar2
 ,p_pst_attribute5                 in varchar2
 ,p_pst_attribute6                 in varchar2
 ,p_pst_attribute7                 in varchar2
 ,p_pst_attribute8                 in varchar2
 ,p_pst_attribute9                 in varchar2
 ,p_pst_attribute10                in varchar2
 ,p_pst_attribute11                in varchar2
 ,p_pst_attribute12                in varchar2
 ,p_pst_attribute13                in varchar2
 ,p_pst_attribute14                in varchar2
 ,p_pst_attribute15                in varchar2
 ,p_pst_attribute16                in varchar2
 ,p_pst_attribute17                in varchar2
 ,p_pst_attribute18                in varchar2
 ,p_pst_attribute19                in varchar2
 ,p_pst_attribute20                in varchar2
 ,p_pst_attribute21                in varchar2
 ,p_pst_attribute22                in varchar2
 ,p_pst_attribute23                in varchar2
 ,p_pst_attribute24                in varchar2
 ,p_pst_attribute25                in varchar2
 ,p_pst_attribute26                in varchar2
 ,p_pst_attribute27                in varchar2
 ,p_pst_attribute28                in varchar2
 ,p_pst_attribute29                in varchar2
 ,p_pst_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pst_rki;

/
