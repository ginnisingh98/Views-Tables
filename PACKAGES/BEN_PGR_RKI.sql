--------------------------------------------------------
--  DDL for Package BEN_PGR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGR_RKI" AUTHID CURRENT_USER as
/* $Header: bepgrrhi.pkh 120.0.12010000.1 2008/07/29 12:49:35 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ppl_grp_rt_id                  in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_vrbl_rt_prfl_id                in number
 ,p_people_group_id                in number
 ,p_business_group_id              in number
 ,p_pgr_attribute_category         in varchar2
 ,p_pgr_attribute1                 in varchar2
 ,p_pgr_attribute2                 in varchar2
 ,p_pgr_attribute3                 in varchar2
 ,p_pgr_attribute4                 in varchar2
 ,p_pgr_attribute5                 in varchar2
 ,p_pgr_attribute6                 in varchar2
 ,p_pgr_attribute7                 in varchar2
 ,p_pgr_attribute8                 in varchar2
 ,p_pgr_attribute9                 in varchar2
 ,p_pgr_attribute10                in varchar2
 ,p_pgr_attribute11                in varchar2
 ,p_pgr_attribute12                in varchar2
 ,p_pgr_attribute13                in varchar2
 ,p_pgr_attribute14                in varchar2
 ,p_pgr_attribute15                in varchar2
 ,p_pgr_attribute16                in varchar2
 ,p_pgr_attribute17                in varchar2
 ,p_pgr_attribute18                in varchar2
 ,p_pgr_attribute19                in varchar2
 ,p_pgr_attribute20                in varchar2
 ,p_pgr_attribute21                in varchar2
 ,p_pgr_attribute22                in varchar2
 ,p_pgr_attribute23                in varchar2
 ,p_pgr_attribute24                in varchar2
 ,p_pgr_attribute25                in varchar2
 ,p_pgr_attribute26                in varchar2
 ,p_pgr_attribute27                in varchar2
 ,p_pgr_attribute28                in varchar2
 ,p_pgr_attribute29                in varchar2
 ,p_pgr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pgr_rki;

/
