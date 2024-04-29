--------------------------------------------------------
--  DDL for Package BEN_CEP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CEP_RKI" AUTHID CURRENT_USER as
/* $Header: beceprhi.pkh 120.0 2005/05/28 01:00:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_prtn_elig_prfl_id              in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_mndtry_flag                    in varchar2
 ,p_prtn_elig_id                   in number
 ,p_eligy_prfl_id                  in number
 ,p_Elig_prfl_type_cd              in  varchar2
 ,p_cep_attribute_category         in varchar2
 ,p_cep_attribute1                 in varchar2
 ,p_cep_attribute2                 in varchar2
 ,p_cep_attribute3                 in varchar2
 ,p_cep_attribute4                 in varchar2
 ,p_cep_attribute5                 in varchar2
 ,p_cep_attribute6                 in varchar2
 ,p_cep_attribute7                 in varchar2
 ,p_cep_attribute8                 in varchar2
 ,p_cep_attribute9                 in varchar2
 ,p_cep_attribute10                in varchar2
 ,p_cep_attribute11                in varchar2
 ,p_cep_attribute12                in varchar2
 ,p_cep_attribute13                in varchar2
 ,p_cep_attribute14                in varchar2
 ,p_cep_attribute15                in varchar2
 ,p_cep_attribute16                in varchar2
 ,p_cep_attribute17                in varchar2
 ,p_cep_attribute18                in varchar2
 ,p_cep_attribute19                in varchar2
 ,p_cep_attribute20                in varchar2
 ,p_cep_attribute21                in varchar2
 ,p_cep_attribute22                in varchar2
 ,p_cep_attribute23                in varchar2
 ,p_cep_attribute24                in varchar2
 ,p_cep_attribute25                in varchar2
 ,p_cep_attribute26                in varchar2
 ,p_cep_attribute27                in varchar2
 ,p_cep_attribute28                in varchar2
 ,p_cep_attribute29                in varchar2
 ,p_cep_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_compute_score_flag               in varchar2
  );
end ben_CEP_rki;

 

/
