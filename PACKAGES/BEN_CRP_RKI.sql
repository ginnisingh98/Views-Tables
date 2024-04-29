--------------------------------------------------------
--  DDL for Package BEN_CRP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CRP_RKI" AUTHID CURRENT_USER as
/* $Header: becrprhi.pkh 120.0 2005/05/28 01:22:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_cbr_per_in_ler_id              in number
 ,p_init_evt_flag                  in varchar2
 ,p_cnt_num                        in number
 ,p_per_in_ler_id                  in number
 ,p_cbr_quald_bnf_id               in number
 ,p_prvs_elig_perd_end_dt          in date
 ,p_business_group_id              in number
 ,p_crp_attribute_category         in varchar2
 ,p_crp_attribute1                 in varchar2
 ,p_crp_attribute2                 in varchar2
 ,p_crp_attribute3                 in varchar2
 ,p_crp_attribute4                 in varchar2
 ,p_crp_attribute5                 in varchar2
 ,p_crp_attribute6                 in varchar2
 ,p_crp_attribute7                 in varchar2
 ,p_crp_attribute8                 in varchar2
 ,p_crp_attribute9                 in varchar2
 ,p_crp_attribute10                in varchar2
 ,p_crp_attribute11                in varchar2
 ,p_crp_attribute12                in varchar2
 ,p_crp_attribute13                in varchar2
 ,p_crp_attribute14                in varchar2
 ,p_crp_attribute15                in varchar2
 ,p_crp_attribute16                in varchar2
 ,p_crp_attribute17                in varchar2
 ,p_crp_attribute18                in varchar2
 ,p_crp_attribute19                in varchar2
 ,p_crp_attribute20                in varchar2
 ,p_crp_attribute21                in varchar2
 ,p_crp_attribute22                in varchar2
 ,p_crp_attribute23                in varchar2
 ,p_crp_attribute24                in varchar2
 ,p_crp_attribute25                in varchar2
 ,p_crp_attribute26                in varchar2
 ,p_crp_attribute27                in varchar2
 ,p_crp_attribute28                in varchar2
 ,p_crp_attribute29                in varchar2
 ,p_crp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_crp_rki;

 

/
