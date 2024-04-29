--------------------------------------------------------
--  DDL for Package BEN_PCS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCS_RKI" AUTHID CURRENT_USER as
/* $Header: bepcsrhi.pkh 120.0 2005/05/28 10:17:00 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_prtt_enrt_ctfn_prvdd_id        in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_enrt_ctfn_rqd_flag             in varchar2
 ,p_enrt_ctfn_typ_cd               in varchar2
 ,p_enrt_ctfn_recd_dt              in date
 ,p_enrt_ctfn_dnd_dt               in date
 ,p_enrt_r_bnft_ctfn_cd            in varchar2
 ,p_prtt_enrt_rslt_id              in number
 ,p_prtt_enrt_actn_id              in number
 ,p_business_group_id              in number
 ,p_pcs_attribute_category         in varchar2
 ,p_pcs_attribute1                 in varchar2
 ,p_pcs_attribute2                 in varchar2
 ,p_pcs_attribute3                 in varchar2
 ,p_pcs_attribute4                 in varchar2
 ,p_pcs_attribute5                 in varchar2
 ,p_pcs_attribute6                 in varchar2
 ,p_pcs_attribute7                 in varchar2
 ,p_pcs_attribute8                 in varchar2
 ,p_pcs_attribute9                 in varchar2
 ,p_pcs_attribute10                in varchar2
 ,p_pcs_attribute11                in varchar2
 ,p_pcs_attribute12                in varchar2
 ,p_pcs_attribute13                in varchar2
 ,p_pcs_attribute14                in varchar2
 ,p_pcs_attribute15                in varchar2
 ,p_pcs_attribute16                in varchar2
 ,p_pcs_attribute17                in varchar2
 ,p_pcs_attribute18                in varchar2
 ,p_pcs_attribute19                in varchar2
 ,p_pcs_attribute20                in varchar2
 ,p_pcs_attribute21                in varchar2
 ,p_pcs_attribute22                in varchar2
 ,p_pcs_attribute23                in varchar2
 ,p_pcs_attribute24                in varchar2
 ,p_pcs_attribute25                in varchar2
 ,p_pcs_attribute26                in varchar2
 ,p_pcs_attribute27                in varchar2
 ,p_pcs_attribute28                in varchar2
 ,p_pcs_attribute29                in varchar2
 ,p_pcs_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pcs_rki;

 

/
