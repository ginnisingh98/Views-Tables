--------------------------------------------------------
--  DDL for Package BEN_PRM_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRM_RKI" AUTHID CURRENT_USER as
/* $Header: beprmrhi.pkh 120.0 2005/05/28 11:10:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_prtt_prem_by_mo_id             in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_mnl_adj_flag                   in varchar2
 ,p_mo_num                         in number
 ,p_yr_num                         in number
 ,p_antcpd_prtt_cntr_uom           in varchar2
 ,p_antcpd_prtt_cntr_val           in number
 ,p_val                            in number
 ,p_cr_val                         in number
 ,p_cr_mnl_adj_flag                in varchar2
 ,p_alctd_val_flag                 in varchar2
 ,p_uom                            in varchar2
 ,p_prtt_prem_id                   in number
 ,p_cost_allocation_keyflex_id     in number
 ,p_business_group_id              in number
 ,p_prm_attribute_category         in varchar2
 ,p_prm_attribute1                 in varchar2
 ,p_prm_attribute2                 in varchar2
 ,p_prm_attribute3                 in varchar2
 ,p_prm_attribute4                 in varchar2
 ,p_prm_attribute5                 in varchar2
 ,p_prm_attribute6                 in varchar2
 ,p_prm_attribute7                 in varchar2
 ,p_prm_attribute8                 in varchar2
 ,p_prm_attribute9                 in varchar2
 ,p_prm_attribute10                in varchar2
 ,p_prm_attribute11                in varchar2
 ,p_prm_attribute12                in varchar2
 ,p_prm_attribute13                in varchar2
 ,p_prm_attribute14                in varchar2
 ,p_prm_attribute15                in varchar2
 ,p_prm_attribute16                in varchar2
 ,p_prm_attribute17                in varchar2
 ,p_prm_attribute18                in varchar2
 ,p_prm_attribute19                in varchar2
 ,p_prm_attribute20                in varchar2
 ,p_prm_attribute21                in varchar2
 ,p_prm_attribute22                in varchar2
 ,p_prm_attribute23                in varchar2
 ,p_prm_attribute24                in varchar2
 ,p_prm_attribute25                in varchar2
 ,p_prm_attribute26                in varchar2
 ,p_prm_attribute27                in varchar2
 ,p_prm_attribute28                in varchar2
 ,p_prm_attribute29                in varchar2
 ,p_prm_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_prm_rki;

 

/
