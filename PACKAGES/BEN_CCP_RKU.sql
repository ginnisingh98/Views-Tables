--------------------------------------------------------
--  DDL for Package BEN_CCP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CCP_RKU" AUTHID CURRENT_USER as
/* $Header: beccprhi.pkh 120.0 2005/05/28 00:58:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_cvrd_dpnt_ctfn_prvdd_id        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_dpnt_dsgn_ctfn_typ_cd          in varchar2
 ,p_dpnt_dsgn_ctfn_rqd_flag        in varchar2
 ,p_dpnt_dsgn_ctfn_recd_dt         in date
 ,p_elig_cvrd_dpnt_id              in number
 ,p_prtt_enrt_actn_id              in number
 ,p_business_group_id              in number
 ,p_ccp_attribute_category         in varchar2
 ,p_ccp_attribute1                 in varchar2
 ,p_ccp_attribute2                 in varchar2
 ,p_ccp_attribute3                 in varchar2
 ,p_ccp_attribute4                 in varchar2
 ,p_ccp_attribute5                 in varchar2
 ,p_ccp_attribute6                 in varchar2
 ,p_ccp_attribute7                 in varchar2
 ,p_ccp_attribute8                 in varchar2
 ,p_ccp_attribute9                 in varchar2
 ,p_ccp_attribute10                in varchar2
 ,p_ccp_attribute11                in varchar2
 ,p_ccp_attribute12                in varchar2
 ,p_ccp_attribute13                in varchar2
 ,p_ccp_attribute14                in varchar2
 ,p_ccp_attribute15                in varchar2
 ,p_ccp_attribute16                in varchar2
 ,p_ccp_attribute17                in varchar2
 ,p_ccp_attribute18                in varchar2
 ,p_ccp_attribute19                in varchar2
 ,p_ccp_attribute20                in varchar2
 ,p_ccp_attribute21                in varchar2
 ,p_ccp_attribute22                in varchar2
 ,p_ccp_attribute23                in varchar2
 ,p_ccp_attribute24                in varchar2
 ,p_ccp_attribute25                in varchar2
 ,p_ccp_attribute26                in varchar2
 ,p_ccp_attribute27                in varchar2
 ,p_ccp_attribute28                in varchar2
 ,p_ccp_attribute29                in varchar2
 ,p_ccp_attribute30                in varchar2
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_dpnt_dsgn_ctfn_typ_cd_o        in varchar2
 ,p_dpnt_dsgn_ctfn_rqd_flag_o      in varchar2
 ,p_dpnt_dsgn_ctfn_recd_dt_o       in date
 ,p_elig_cvrd_dpnt_id_o            in number
 ,p_prtt_enrt_actn_id_o            in number
 ,p_business_group_id_o            in number
 ,p_ccp_attribute_category_o       in varchar2
 ,p_ccp_attribute1_o               in varchar2
 ,p_ccp_attribute2_o               in varchar2
 ,p_ccp_attribute3_o               in varchar2
 ,p_ccp_attribute4_o               in varchar2
 ,p_ccp_attribute5_o               in varchar2
 ,p_ccp_attribute6_o               in varchar2
 ,p_ccp_attribute7_o               in varchar2
 ,p_ccp_attribute8_o               in varchar2
 ,p_ccp_attribute9_o               in varchar2
 ,p_ccp_attribute10_o              in varchar2
 ,p_ccp_attribute11_o              in varchar2
 ,p_ccp_attribute12_o              in varchar2
 ,p_ccp_attribute13_o              in varchar2
 ,p_ccp_attribute14_o              in varchar2
 ,p_ccp_attribute15_o              in varchar2
 ,p_ccp_attribute16_o              in varchar2
 ,p_ccp_attribute17_o              in varchar2
 ,p_ccp_attribute18_o              in varchar2
 ,p_ccp_attribute19_o              in varchar2
 ,p_ccp_attribute20_o              in varchar2
 ,p_ccp_attribute21_o              in varchar2
 ,p_ccp_attribute22_o              in varchar2
 ,p_ccp_attribute23_o              in varchar2
 ,p_ccp_attribute24_o              in varchar2
 ,p_ccp_attribute25_o              in varchar2
 ,p_ccp_attribute26_o              in varchar2
 ,p_ccp_attribute27_o              in varchar2
 ,p_ccp_attribute28_o              in varchar2
 ,p_ccp_attribute29_o              in varchar2
 ,p_ccp_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_ccp_rku;

 

/