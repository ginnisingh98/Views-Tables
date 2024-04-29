--------------------------------------------------------
--  DDL for Package BEN_WPT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WPT_RKI" AUTHID CURRENT_USER as
/* $Header: bewptrhi.pkh 120.0.12010000.1 2008/07/29 13:09:53 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_wv_prtn_rsn_ptip_id            in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_ptip_id                        in number
 ,p_dflt_flag                      in varchar2
 ,p_wv_prtn_rsn_cd                 in varchar2
 ,p_wpt_attribute_category         in varchar2
 ,p_wpt_attribute1                 in varchar2
 ,p_wpt_attribute2                 in varchar2
 ,p_wpt_attribute3                 in varchar2
 ,p_wpt_attribute4                 in varchar2
 ,p_wpt_attribute5                 in varchar2
 ,p_wpt_attribute6                 in varchar2
 ,p_wpt_attribute7                 in varchar2
 ,p_wpt_attribute8                 in varchar2
 ,p_wpt_attribute9                 in varchar2
 ,p_wpt_attribute10                in varchar2
 ,p_wpt_attribute11                in varchar2
 ,p_wpt_attribute12                in varchar2
 ,p_wpt_attribute13                in varchar2
 ,p_wpt_attribute14                in varchar2
 ,p_wpt_attribute15                in varchar2
 ,p_wpt_attribute16                in varchar2
 ,p_wpt_attribute17                in varchar2
 ,p_wpt_attribute18                in varchar2
 ,p_wpt_attribute19                in varchar2
 ,p_wpt_attribute20                in varchar2
 ,p_wpt_attribute21                in varchar2
 ,p_wpt_attribute22                in varchar2
 ,p_wpt_attribute23                in varchar2
 ,p_wpt_attribute24                in varchar2
 ,p_wpt_attribute25                in varchar2
 ,p_wpt_attribute26                in varchar2
 ,p_wpt_attribute27                in varchar2
 ,p_wpt_attribute28                in varchar2
 ,p_wpt_attribute29                in varchar2
 ,p_wpt_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_wpt_rki;

/
