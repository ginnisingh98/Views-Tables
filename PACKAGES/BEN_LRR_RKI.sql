--------------------------------------------------------
--  DDL for Package BEN_LRR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LRR_RKI" AUTHID CURRENT_USER as
/* $Header: belrrrhi.pkh 120.0 2005/05/28 03:37:03 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_lee_rsn_rl_id                  in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_formula_id            in number
 ,p_ordr_to_aply_num               in number
 ,p_lee_rsn_id                     in number
 ,p_lrr_attribute_category         in varchar2
 ,p_lrr_attribute1                 in varchar2
 ,p_lrr_attribute2                 in varchar2
 ,p_lrr_attribute3                 in varchar2
 ,p_lrr_attribute4                 in varchar2
 ,p_lrr_attribute5                 in varchar2
 ,p_lrr_attribute6                 in varchar2
 ,p_lrr_attribute7                 in varchar2
 ,p_lrr_attribute8                 in varchar2
 ,p_lrr_attribute9                 in varchar2
 ,p_lrr_attribute10                in varchar2
 ,p_lrr_attribute11                in varchar2
 ,p_lrr_attribute12                in varchar2
 ,p_lrr_attribute13                in varchar2
 ,p_lrr_attribute14                in varchar2
 ,p_lrr_attribute15                in varchar2
 ,p_lrr_attribute16                in varchar2
 ,p_lrr_attribute17                in varchar2
 ,p_lrr_attribute18                in varchar2
 ,p_lrr_attribute19                in varchar2
 ,p_lrr_attribute20                in varchar2
 ,p_lrr_attribute21                in varchar2
 ,p_lrr_attribute22                in varchar2
 ,p_lrr_attribute23                in varchar2
 ,p_lrr_attribute24                in varchar2
 ,p_lrr_attribute25                in varchar2
 ,p_lrr_attribute26                in varchar2
 ,p_lrr_attribute27                in varchar2
 ,p_lrr_attribute28                in varchar2
 ,p_lrr_attribute29                in varchar2
 ,p_lrr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_lrr_rki;

 

/