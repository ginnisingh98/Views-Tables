--------------------------------------------------------
--  DDL for Package BEN_CQR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CQR_RKI" AUTHID CURRENT_USER as
/* $Header: becqrrhi.pkh 120.0 2005/05/28 01:20:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_cbr_quald_bnf_rt_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_quald_bnf_flag                 in varchar2
 ,p_ordr_num                       in number
 ,p_vrbl_rt_prfl_id                  in number
 ,p_pgm_id                         in number
 ,p_ptip_id                        in number
 ,p_business_group_id              in number
 ,p_cqr_attribute_category         in varchar2
 ,p_cqr_attribute1                 in varchar2
 ,p_cqr_attribute2                 in varchar2
 ,p_cqr_attribute3                 in varchar2
 ,p_cqr_attribute4                 in varchar2
 ,p_cqr_attribute5                 in varchar2
 ,p_cqr_attribute6                 in varchar2
 ,p_cqr_attribute7                 in varchar2
 ,p_cqr_attribute8                 in varchar2
 ,p_cqr_attribute9                 in varchar2
 ,p_cqr_attribute10                in varchar2
 ,p_cqr_attribute11                in varchar2
 ,p_cqr_attribute12                in varchar2
 ,p_cqr_attribute13                in varchar2
 ,p_cqr_attribute14                in varchar2
 ,p_cqr_attribute15                in varchar2
 ,p_cqr_attribute16                in varchar2
 ,p_cqr_attribute17                in varchar2
 ,p_cqr_attribute18                in varchar2
 ,p_cqr_attribute19                in varchar2
 ,p_cqr_attribute20                in varchar2
 ,p_cqr_attribute21                in varchar2
 ,p_cqr_attribute22                in varchar2
 ,p_cqr_attribute23                in varchar2
 ,p_cqr_attribute24                in varchar2
 ,p_cqr_attribute25                in varchar2
 ,p_cqr_attribute26                in varchar2
 ,p_cqr_attribute27                in varchar2
 ,p_cqr_attribute28                in varchar2
 ,p_cqr_attribute29                in varchar2
 ,p_cqr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_cqr_rki;

 

/
