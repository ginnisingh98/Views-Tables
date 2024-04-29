--------------------------------------------------------
--  DDL for Package BEN_ETC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ETC_RKI" AUTHID CURRENT_USER as
/* $Header: beetcrhi.pkh 120.0 2005/05/28 03:00:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_ttl_cvg_vol_prte_id       in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_excld_flag                     in varchar2
 ,p_no_mn_cvg_vol_amt_apls_flag    in varchar2
 ,p_no_mx_cvg_vol_amt_apls_flag    in varchar2
 ,p_ordr_num                       in number
 ,p_mn_cvg_vol_amt                 in number
 ,p_mx_cvg_vol_amt                 in number
 ,p_cvg_vol_det_cd                 in varchar2
 ,p_cvg_vol_det_rl                 in number
 ,p_eligy_prfl_id                  in number
 ,p_etc_attribute_category         in varchar2
 ,p_etc_attribute1                 in varchar2
 ,p_etc_attribute2                 in varchar2
 ,p_etc_attribute3                 in varchar2
 ,p_etc_attribute4                 in varchar2
 ,p_etc_attribute5                 in varchar2
 ,p_etc_attribute6                 in varchar2
 ,p_etc_attribute7                 in varchar2
 ,p_etc_attribute8                 in varchar2
 ,p_etc_attribute9                 in varchar2
 ,p_etc_attribute10                in varchar2
 ,p_etc_attribute11                in varchar2
 ,p_etc_attribute12                in varchar2
 ,p_etc_attribute13                in varchar2
 ,p_etc_attribute14                in varchar2
 ,p_etc_attribute15                in varchar2
 ,p_etc_attribute16                in varchar2
 ,p_etc_attribute17                in varchar2
 ,p_etc_attribute18                in varchar2
 ,p_etc_attribute19                in varchar2
 ,p_etc_attribute20                in varchar2
 ,p_etc_attribute21                in varchar2
 ,p_etc_attribute22                in varchar2
 ,p_etc_attribute23                in varchar2
 ,p_etc_attribute24                in varchar2
 ,p_etc_attribute25                in varchar2
 ,p_etc_attribute26                in varchar2
 ,p_etc_attribute27                in varchar2
 ,p_etc_attribute28                in varchar2
 ,p_etc_attribute29                in varchar2
 ,p_etc_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_etc_rki;

 

/
