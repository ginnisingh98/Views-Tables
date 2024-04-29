--------------------------------------------------------
--  DDL for Package BEN_WLR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WLR_RKI" AUTHID CURRENT_USER as
/* $Header: bewlrrhi.pkh 120.0.12010000.1 2008/07/29 13:09:25 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_wk_loc_rt_id                   in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_vrbl_rt_prfl_id                in number
 ,p_location_id                    in number
 ,p_excld_flag                     in varchar2
 ,p_ordr_num                       in number
 ,p_wlr_attribute_category         in varchar2
 ,p_wlr_attribute1                 in varchar2
 ,p_wlr_attribute2                 in varchar2
 ,p_wlr_attribute3                 in varchar2
 ,p_wlr_attribute4                 in varchar2
 ,p_wlr_attribute5                 in varchar2
 ,p_wlr_attribute6                 in varchar2
 ,p_wlr_attribute7                 in varchar2
 ,p_wlr_attribute8                 in varchar2
 ,p_wlr_attribute9                 in varchar2
 ,p_wlr_attribute10                in varchar2
 ,p_wlr_attribute11                in varchar2
 ,p_wlr_attribute12                in varchar2
 ,p_wlr_attribute13                in varchar2
 ,p_wlr_attribute14                in varchar2
 ,p_wlr_attribute15                in varchar2
 ,p_wlr_attribute16                in varchar2
 ,p_wlr_attribute17                in varchar2
 ,p_wlr_attribute18                in varchar2
 ,p_wlr_attribute19                in varchar2
 ,p_wlr_attribute20                in varchar2
 ,p_wlr_attribute21                in varchar2
 ,p_wlr_attribute22                in varchar2
 ,p_wlr_attribute23                in varchar2
 ,p_wlr_attribute24                in varchar2
 ,p_wlr_attribute25                in varchar2
 ,p_wlr_attribute26                in varchar2
 ,p_wlr_attribute27                in varchar2
 ,p_wlr_attribute28                in varchar2
 ,p_wlr_attribute29                in varchar2
 ,p_wlr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_wlr_rki;

/
