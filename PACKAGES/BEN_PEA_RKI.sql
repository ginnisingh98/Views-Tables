--------------------------------------------------------
--  DDL for Package BEN_PEA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PEA_RKI" AUTHID CURRENT_USER as
/* $Header: bepearhi.pkh 120.0 2005/05/28 10:31:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_prtt_enrt_actn_id              in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_cmpltd_dt                      in date
 ,p_due_dt                         in date
 ,p_rqd_flag                       in varchar2
 ,p_prtt_enrt_rslt_id              in number
 ,p_per_in_ler_id              in number
 ,p_actn_typ_id                    in number
 ,p_elig_cvrd_dpnt_id              in number
 ,p_pl_bnf_id                      in number
 ,p_business_group_id              in number
 ,p_pea_attribute_category         in varchar2
 ,p_pea_attribute1                 in varchar2
 ,p_pea_attribute2                 in varchar2
 ,p_pea_attribute3                 in varchar2
 ,p_pea_attribute4                 in varchar2
 ,p_pea_attribute5                 in varchar2
 ,p_pea_attribute6                 in varchar2
 ,p_pea_attribute7                 in varchar2
 ,p_pea_attribute8                 in varchar2
 ,p_pea_attribute9                 in varchar2
 ,p_pea_attribute10                in varchar2
 ,p_pea_attribute11                in varchar2
 ,p_pea_attribute12                in varchar2
 ,p_pea_attribute13                in varchar2
 ,p_pea_attribute14                in varchar2
 ,p_pea_attribute15                in varchar2
 ,p_pea_attribute16                in varchar2
 ,p_pea_attribute17                in varchar2
 ,p_pea_attribute18                in varchar2
 ,p_pea_attribute19                in varchar2
 ,p_pea_attribute20                in varchar2
 ,p_pea_attribute21                in varchar2
 ,p_pea_attribute22                in varchar2
 ,p_pea_attribute23                in varchar2
 ,p_pea_attribute24                in varchar2
 ,p_pea_attribute25                in varchar2
 ,p_pea_attribute26                in varchar2
 ,p_pea_attribute27                in varchar2
 ,p_pea_attribute28                in varchar2
 ,p_pea_attribute29                in varchar2
 ,p_pea_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pea_rki;

 

/
