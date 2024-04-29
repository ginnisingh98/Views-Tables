--------------------------------------------------------
--  DDL for Package BEN_EDB_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EDB_RKI" AUTHID CURRENT_USER as
/* $Header: beedbrhi.pkh 120.0 2005/05/28 01:56:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_elig_dsbld_prte_id             in number
 ,p_dsbld_cd                       in varchar2
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_eligy_prfl_id                  in number
 ,p_business_group_id              in number
 ,p_edb_attribute_category         in varchar2
 ,p_edb_attribute1                 in varchar2
 ,p_edb_attribute2                 in varchar2
 ,p_edb_attribute3                 in varchar2
 ,p_edb_attribute4                 in varchar2
 ,p_edb_attribute5                 in varchar2
 ,p_edb_attribute6                 in varchar2
 ,p_edb_attribute7                 in varchar2
 ,p_edb_attribute8                 in varchar2
 ,p_edb_attribute9                 in varchar2
 ,p_edb_attribute10                in varchar2
 ,p_edb_attribute11                in varchar2
 ,p_edb_attribute12                in varchar2
 ,p_edb_attribute13                in varchar2
 ,p_edb_attribute14                in varchar2
 ,p_edb_attribute15                in varchar2
 ,p_edb_attribute16                in varchar2
 ,p_edb_attribute17                in varchar2
 ,p_edb_attribute18                in varchar2
 ,p_edb_attribute19                in varchar2
 ,p_edb_attribute20                in varchar2
 ,p_edb_attribute21                in varchar2
 ,p_edb_attribute22                in varchar2
 ,p_edb_attribute23                in varchar2
 ,p_edb_attribute24                in varchar2
 ,p_edb_attribute25                in varchar2
 ,p_edb_attribute26                in varchar2
 ,p_edb_attribute27                in varchar2
 ,p_edb_attribute28                in varchar2
 ,p_edb_attribute29                in varchar2
 ,p_edb_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_criteria_score  in  number
 ,p_criteria_weight in number
  );
end ben_edb_rki;

 

/
