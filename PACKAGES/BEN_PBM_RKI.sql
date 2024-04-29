--------------------------------------------------------
--  DDL for Package BEN_PBM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PBM_RKI" AUTHID CURRENT_USER as
/* $Header: bepbmrhi.pkh 120.0 2005/05/28 10:06:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_pl_r_oipl_prem_by_mo_id        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_mnl_adj_flag                   in varchar2
 ,p_mo_num                         in number
 ,p_yr_num                         in number
 ,p_val                            in number
 ,p_uom                            in varchar2
 ,p_prtts_num                      in number
 ,p_actl_prem_id                   in number
 ,p_cost_allocation_keyflex_id    in number
 ,p_business_group_id              in number
 ,p_pbm_attribute_category         in varchar2
 ,p_pbm_attribute1                 in varchar2
 ,p_pbm_attribute2                 in varchar2
 ,p_pbm_attribute3                 in varchar2
 ,p_pbm_attribute4                 in varchar2
 ,p_pbm_attribute5                 in varchar2
 ,p_pbm_attribute6                 in varchar2
 ,p_pbm_attribute7                 in varchar2
 ,p_pbm_attribute8                 in varchar2
 ,p_pbm_attribute9                 in varchar2
 ,p_pbm_attribute10                in varchar2
 ,p_pbm_attribute11                in varchar2
 ,p_pbm_attribute12                in varchar2
 ,p_pbm_attribute13                in varchar2
 ,p_pbm_attribute14                in varchar2
 ,p_pbm_attribute15                in varchar2
 ,p_pbm_attribute16                in varchar2
 ,p_pbm_attribute17                in varchar2
 ,p_pbm_attribute18                in varchar2
 ,p_pbm_attribute19                in varchar2
 ,p_pbm_attribute20                in varchar2
 ,p_pbm_attribute21                in varchar2
 ,p_pbm_attribute22                in varchar2
 ,p_pbm_attribute23                in varchar2
 ,p_pbm_attribute24                in varchar2
 ,p_pbm_attribute25                in varchar2
 ,p_pbm_attribute26                in varchar2
 ,p_pbm_attribute27                in varchar2
 ,p_pbm_attribute28                in varchar2
 ,p_pbm_attribute29                in varchar2
 ,p_pbm_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_request_id			   in number
 ,p_program_id                     in number
 ,p_program_application_id         in number
 ,p_program_update_date           in date
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pbm_rki;

 

/
