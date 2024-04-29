--------------------------------------------------------
--  DDL for Package BEN_PBC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PBC_RKI" AUTHID CURRENT_USER as
/* $Header: bepbcrhi.pkh 120.0 2005/05/28 10:04:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_pl_bnf_ctfn_prvdd_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_bnf_ctfn_typ_cd                in varchar2
 ,p_bnf_ctfn_recd_dt               in date
 ,p_bnf_ctfn_rqd_flag              in varchar2
 ,p_pl_bnf_id                      in number
 ,p_prtt_enrt_actn_id              in number
 ,p_business_group_id              in number
 ,p_pbc_attribute_category         in varchar2
 ,p_pbc_attribute1                 in varchar2
 ,p_pbc_attribute2                 in varchar2
 ,p_pbc_attribute3                 in varchar2
 ,p_pbc_attribute4                 in varchar2
 ,p_pbc_attribute5                 in varchar2
 ,p_pbc_attribute6                 in varchar2
 ,p_pbc_attribute7                 in varchar2
 ,p_pbc_attribute8                 in varchar2
 ,p_pbc_attribute9                 in varchar2
 ,p_pbc_attribute10                in varchar2
 ,p_pbc_attribute11                in varchar2
 ,p_pbc_attribute12                in varchar2
 ,p_pbc_attribute13                in varchar2
 ,p_pbc_attribute14                in varchar2
 ,p_pbc_attribute15                in varchar2
 ,p_pbc_attribute16                in varchar2
 ,p_pbc_attribute17                in varchar2
 ,p_pbc_attribute18                in varchar2
 ,p_pbc_attribute19                in varchar2
 ,p_pbc_attribute20                in varchar2
 ,p_pbc_attribute21                in varchar2
 ,p_pbc_attribute22                in varchar2
 ,p_pbc_attribute23                in varchar2
 ,p_pbc_attribute24                in varchar2
 ,p_pbc_attribute25                in varchar2
 ,p_pbc_attribute26                in varchar2
 ,p_pbc_attribute27                in varchar2
 ,p_pbc_attribute28                in varchar2
 ,p_pbc_attribute29                in varchar2
 ,p_pbc_attribute30                in varchar2
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pbc_rki;

 

/
