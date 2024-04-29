--------------------------------------------------------
--  DDL for Package BEN_DCL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DCL_RKI" AUTHID CURRENT_USER as
/* $Header: bedclrhi.pkh 120.0 2005/05/28 01:32:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_dpnt_cvrd_othr_pl_rt_id      in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_cvg_det_dt_cd                  in varchar2
 ,p_business_group_id              in number
 ,p_vrbl_rt_prfl_id                  in number
 ,p_pl_id                          in number
 ,p_dcl_attribute_category         in varchar2
 ,p_dcl_attribute1                 in varchar2
 ,p_dcl_attribute2                 in varchar2
 ,p_dcl_attribute3                 in varchar2
 ,p_dcl_attribute4                 in varchar2
 ,p_dcl_attribute5                 in varchar2
 ,p_dcl_attribute6                 in varchar2
 ,p_dcl_attribute7                 in varchar2
 ,p_dcl_attribute8                 in varchar2
 ,p_dcl_attribute9                 in varchar2
 ,p_dcl_attribute10                in varchar2
 ,p_dcl_attribute11                in varchar2
 ,p_dcl_attribute12                in varchar2
 ,p_dcl_attribute13                in varchar2
 ,p_dcl_attribute14                in varchar2
 ,p_dcl_attribute15                in varchar2
 ,p_dcl_attribute16                in varchar2
 ,p_dcl_attribute17                in varchar2
 ,p_dcl_attribute18                in varchar2
 ,p_dcl_attribute19                in varchar2
 ,p_dcl_attribute20                in varchar2
 ,p_dcl_attribute21                in varchar2
 ,p_dcl_attribute22                in varchar2
 ,p_dcl_attribute23                in varchar2
 ,p_dcl_attribute24                in varchar2
 ,p_dcl_attribute25                in varchar2
 ,p_dcl_attribute26                in varchar2
 ,p_dcl_attribute27                in varchar2
 ,p_dcl_attribute28                in varchar2
 ,p_dcl_attribute29                in varchar2
 ,p_dcl_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_dcl_rki;

 

/
