--------------------------------------------------------
--  DDL for Package BEN_EMS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EMS_RKI" AUTHID CURRENT_USER as
/* $Header: beemsrhi.pkh 120.0 2005/05/28 02:26:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_mrtl_stat_cvg_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_dpnt_cvg_eligy_prfl_id         in number
 ,p_mrtl_stat_cd                   in varchar2
 ,p_cvg_strt_cd                    in varchar2
 ,p_cvg_strt_rl                    in number
 ,p_cvg_thru_cd                    in varchar2
 ,p_cvg_thru_rl                    in number
 ,p_ems_attribute_category         in varchar2
 ,p_ems_attribute1                 in varchar2
 ,p_ems_attribute2                 in varchar2
 ,p_ems_attribute3                 in varchar2
 ,p_ems_attribute4                 in varchar2
 ,p_ems_attribute5                 in varchar2
 ,p_ems_attribute6                 in varchar2
 ,p_ems_attribute7                 in varchar2
 ,p_ems_attribute8                 in varchar2
 ,p_ems_attribute9                 in varchar2
 ,p_ems_attribute10                in varchar2
 ,p_ems_attribute11                in varchar2
 ,p_ems_attribute12                in varchar2
 ,p_ems_attribute13                in varchar2
 ,p_ems_attribute14                in varchar2
 ,p_ems_attribute15                in varchar2
 ,p_ems_attribute16                in varchar2
 ,p_ems_attribute17                in varchar2
 ,p_ems_attribute18                in varchar2
 ,p_ems_attribute19                in varchar2
 ,p_ems_attribute20                in varchar2
 ,p_ems_attribute21                in varchar2
 ,p_ems_attribute22                in varchar2
 ,p_ems_attribute23                in varchar2
 ,p_ems_attribute24                in varchar2
 ,p_ems_attribute25                in varchar2
 ,p_ems_attribute26                in varchar2
 ,p_ems_attribute27                in varchar2
 ,p_ems_attribute28                in varchar2
 ,p_ems_attribute29                in varchar2
 ,p_ems_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_ems_rki;

 

/
