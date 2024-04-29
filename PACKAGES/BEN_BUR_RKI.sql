--------------------------------------------------------
--  DDL for Package BEN_BUR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BUR_RKI" AUTHID CURRENT_USER as
/* $Header: beburrhi.pkh 120.0.12010000.1 2008/07/29 11:02:11 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_brgng_unit_rt_id               in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_vrbl_rt_prfl_id                in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_brgng_unit_cd                  in varchar2
 ,p_business_group_id              in number
 ,p_bur_attribute_category         in varchar2
 ,p_bur_attribute1                 in varchar2
 ,p_bur_attribute2                 in varchar2
 ,p_bur_attribute3                 in varchar2
 ,p_bur_attribute4                 in varchar2
 ,p_bur_attribute5                 in varchar2
 ,p_bur_attribute6                 in varchar2
 ,p_bur_attribute7                 in varchar2
 ,p_bur_attribute8                 in varchar2
 ,p_bur_attribute9                 in varchar2
 ,p_bur_attribute10                in varchar2
 ,p_bur_attribute11                in varchar2
 ,p_bur_attribute12                in varchar2
 ,p_bur_attribute13                in varchar2
 ,p_bur_attribute14                in varchar2
 ,p_bur_attribute15                in varchar2
 ,p_bur_attribute16                in varchar2
 ,p_bur_attribute17                in varchar2
 ,p_bur_attribute18                in varchar2
 ,p_bur_attribute19                in varchar2
 ,p_bur_attribute20                in varchar2
 ,p_bur_attribute21                in varchar2
 ,p_bur_attribute22                in varchar2
 ,p_bur_attribute23                in varchar2
 ,p_bur_attribute24                in varchar2
 ,p_bur_attribute25                in varchar2
 ,p_bur_attribute26                in varchar2
 ,p_bur_attribute27                in varchar2
 ,p_bur_attribute28                in varchar2
 ,p_bur_attribute29                in varchar2
 ,p_bur_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_bur_rki;

/
