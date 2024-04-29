--------------------------------------------------------
--  DDL for Package BEN_CBR_QUALD_BNF_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CBR_QUALD_BNF_BK2" AUTHID CURRENT_USER as
/* $Header: becqbapi.pkh 120.0 2005/05/28 01:19:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_CBR_QUALD_BNF_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_CBR_QUALD_BNF_b
  (
   p_cbr_quald_bnf_id               in  number
  ,p_quald_bnf_flag                 in  varchar2
  ,p_cbr_elig_perd_strt_dt          in  date
  ,p_cbr_elig_perd_end_dt           in  date
  ,p_quald_bnf_person_id            in  number
  ,p_pgm_id                         in  number
  ,p_ptip_id                        in  number
  ,p_pl_typ_id                      in  number
  ,p_cvrd_emp_person_id             in  number
  ,p_cbr_inelg_rsn_cd               in  varchar2
  ,p_business_group_id              in  number
  ,p_cqb_attribute_category         in  varchar2
  ,p_cqb_attribute1                 in  varchar2
  ,p_cqb_attribute2                 in  varchar2
  ,p_cqb_attribute3                 in  varchar2
  ,p_cqb_attribute4                 in  varchar2
  ,p_cqb_attribute5                 in  varchar2
  ,p_cqb_attribute6                 in  varchar2
  ,p_cqb_attribute7                 in  varchar2
  ,p_cqb_attribute8                 in  varchar2
  ,p_cqb_attribute9                 in  varchar2
  ,p_cqb_attribute10                in  varchar2
  ,p_cqb_attribute11                in  varchar2
  ,p_cqb_attribute12                in  varchar2
  ,p_cqb_attribute13                in  varchar2
  ,p_cqb_attribute14                in  varchar2
  ,p_cqb_attribute15                in  varchar2
  ,p_cqb_attribute16                in  varchar2
  ,p_cqb_attribute17                in  varchar2
  ,p_cqb_attribute18                in  varchar2
  ,p_cqb_attribute19                in  varchar2
  ,p_cqb_attribute20                in  varchar2
  ,p_cqb_attribute21                in  varchar2
  ,p_cqb_attribute22                in  varchar2
  ,p_cqb_attribute23                in  varchar2
  ,p_cqb_attribute24                in  varchar2
  ,p_cqb_attribute25                in  varchar2
  ,p_cqb_attribute26                in  varchar2
  ,p_cqb_attribute27                in  varchar2
  ,p_cqb_attribute28                in  varchar2
  ,p_cqb_attribute29                in  varchar2
  ,p_cqb_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_CBR_QUALD_BNF_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_CBR_QUALD_BNF_a
  (
   p_cbr_quald_bnf_id               in  number
  ,p_quald_bnf_flag                 in  varchar2
  ,p_cbr_elig_perd_strt_dt          in  date
  ,p_cbr_elig_perd_end_dt           in  date
  ,p_quald_bnf_person_id            in  number
  ,p_pgm_id                         in  number
  ,p_ptip_id                        in  number
  ,p_pl_typ_id                      in  number
  ,p_cvrd_emp_person_id             in  number
  ,p_cbr_inelg_rsn_cd               in  varchar2
  ,p_business_group_id              in  number
  ,p_cqb_attribute_category         in  varchar2
  ,p_cqb_attribute1                 in  varchar2
  ,p_cqb_attribute2                 in  varchar2
  ,p_cqb_attribute3                 in  varchar2
  ,p_cqb_attribute4                 in  varchar2
  ,p_cqb_attribute5                 in  varchar2
  ,p_cqb_attribute6                 in  varchar2
  ,p_cqb_attribute7                 in  varchar2
  ,p_cqb_attribute8                 in  varchar2
  ,p_cqb_attribute9                 in  varchar2
  ,p_cqb_attribute10                in  varchar2
  ,p_cqb_attribute11                in  varchar2
  ,p_cqb_attribute12                in  varchar2
  ,p_cqb_attribute13                in  varchar2
  ,p_cqb_attribute14                in  varchar2
  ,p_cqb_attribute15                in  varchar2
  ,p_cqb_attribute16                in  varchar2
  ,p_cqb_attribute17                in  varchar2
  ,p_cqb_attribute18                in  varchar2
  ,p_cqb_attribute19                in  varchar2
  ,p_cqb_attribute20                in  varchar2
  ,p_cqb_attribute21                in  varchar2
  ,p_cqb_attribute22                in  varchar2
  ,p_cqb_attribute23                in  varchar2
  ,p_cqb_attribute24                in  varchar2
  ,p_cqb_attribute25                in  varchar2
  ,p_cqb_attribute26                in  varchar2
  ,p_cqb_attribute27                in  varchar2
  ,p_cqb_attribute28                in  varchar2
  ,p_cqb_attribute29                in  varchar2
  ,p_cqb_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_CBR_QUALD_BNF_bk2;

 

/
