--------------------------------------------------------
--  DDL for Package BEN_ESR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ESR_RKI" AUTHID CURRENT_USER as
/* $Header: beesrrhi.pkh 120.0 2005/05/28 02:58:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ee_stat_rt_id                  in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_vrbl_rt_prfl_id                in number
 ,p_assignment_status_type_id      in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_business_group_id              in number
 ,p_esr_attribute_category         in varchar2
 ,p_esr_attribute1                 in varchar2
 ,p_esr_attribute2                 in varchar2
 ,p_esr_attribute3                 in varchar2
 ,p_esr_attribute4                 in varchar2
 ,p_esr_attribute5                 in varchar2
 ,p_esr_attribute6                 in varchar2
 ,p_esr_attribute7                 in varchar2
 ,p_esr_attribute8                 in varchar2
 ,p_esr_attribute9                 in varchar2
 ,p_esr_attribute10                in varchar2
 ,p_esr_attribute11                in varchar2
 ,p_esr_attribute12                in varchar2
 ,p_esr_attribute13                in varchar2
 ,p_esr_attribute14                in varchar2
 ,p_esr_attribute15                in varchar2
 ,p_esr_attribute16                in varchar2
 ,p_esr_attribute17                in varchar2
 ,p_esr_attribute18                in varchar2
 ,p_esr_attribute19                in varchar2
 ,p_esr_attribute20                in varchar2
 ,p_esr_attribute21                in varchar2
 ,p_esr_attribute22                in varchar2
 ,p_esr_attribute23                in varchar2
 ,p_esr_attribute24                in varchar2
 ,p_esr_attribute25                in varchar2
 ,p_esr_attribute26                in varchar2
 ,p_esr_attribute27                in varchar2
 ,p_esr_attribute28                in varchar2
 ,p_esr_attribute29                in varchar2
 ,p_esr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_esr_rki;

 

/
