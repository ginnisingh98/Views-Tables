--------------------------------------------------------
--  DDL for Package BEN_DPC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DPC_RKI" AUTHID CURRENT_USER as
/* $Header: bedpcrhi.pkh 120.0 2005/05/28 01:39:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_dpnt_cvrd_anthr_pl_cvg_id      in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_cvg_det_dt_cd                  in varchar2
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_dpnt_cvg_eligy_prfl_id         in number
 ,p_pl_id                          in number
 ,p_dpc_attribute_category         in varchar2
 ,p_dpc_attribute1                 in varchar2
 ,p_dpc_attribute2                 in varchar2
 ,p_dpc_attribute3                 in varchar2
 ,p_dpc_attribute4                 in varchar2
 ,p_dpc_attribute5                 in varchar2
 ,p_dpc_attribute6                 in varchar2
 ,p_dpc_attribute7                 in varchar2
 ,p_dpc_attribute8                 in varchar2
 ,p_dpc_attribute9                 in varchar2
 ,p_dpc_attribute10                in varchar2
 ,p_dpc_attribute11                in varchar2
 ,p_dpc_attribute12                in varchar2
 ,p_dpc_attribute13                in varchar2
 ,p_dpc_attribute14                in varchar2
 ,p_dpc_attribute15                in varchar2
 ,p_dpc_attribute16                in varchar2
 ,p_dpc_attribute17                in varchar2
 ,p_dpc_attribute18                in varchar2
 ,p_dpc_attribute19                in varchar2
 ,p_dpc_attribute20                in varchar2
 ,p_dpc_attribute21                in varchar2
 ,p_dpc_attribute22                in varchar2
 ,p_dpc_attribute23                in varchar2
 ,p_dpc_attribute24                in varchar2
 ,p_dpc_attribute25                in varchar2
 ,p_dpc_attribute26                in varchar2
 ,p_dpc_attribute27                in varchar2
 ,p_dpc_attribute28                in varchar2
 ,p_dpc_attribute29                in varchar2
 ,p_dpc_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_dpc_rki;

 

/
