--------------------------------------------------------
--  DDL for Package BEN_BRG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BRG_RKI" AUTHID CURRENT_USER as
/* $Header: bebrgrhi.pkh 120.0.12010000.1 2008/07/29 11:00:50 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_benfts_grp_rt_id               in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_vrbl_rt_prfl_id                in number
 ,p_benfts_grp_id                  in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_brg_attribute_category         in varchar2
 ,p_brg_attribute1                 in varchar2
 ,p_brg_attribute2                 in varchar2
 ,p_brg_attribute3                 in varchar2
 ,p_brg_attribute4                 in varchar2
 ,p_brg_attribute5                 in varchar2
 ,p_brg_attribute6                 in varchar2
 ,p_brg_attribute7                 in varchar2
 ,p_brg_attribute8                 in varchar2
 ,p_brg_attribute9                 in varchar2
 ,p_brg_attribute10                in varchar2
 ,p_brg_attribute11                in varchar2
 ,p_brg_attribute12                in varchar2
 ,p_brg_attribute13                in varchar2
 ,p_brg_attribute14                in varchar2
 ,p_brg_attribute15                in varchar2
 ,p_brg_attribute16                in varchar2
 ,p_brg_attribute17                in varchar2
 ,p_brg_attribute18                in varchar2
 ,p_brg_attribute19                in varchar2
 ,p_brg_attribute20                in varchar2
 ,p_brg_attribute21                in varchar2
 ,p_brg_attribute22                in varchar2
 ,p_brg_attribute23                in varchar2
 ,p_brg_attribute24                in varchar2
 ,p_brg_attribute25                in varchar2
 ,p_brg_attribute26                in varchar2
 ,p_brg_attribute27                in varchar2
 ,p_brg_attribute28                in varchar2
 ,p_brg_attribute29                in varchar2
 ,p_brg_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_brg_rki;

/
