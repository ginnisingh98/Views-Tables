--------------------------------------------------------
--  DDL for Package BEN_WPN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WPN_RKI" AUTHID CURRENT_USER as
/* $Header: bewpnrhi.pkh 120.0.12010000.1 2008/07/29 13:09:39 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_wv_prtn_rsn_pl_id              in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_pl_id                          in number
 ,p_dflt_flag                      in varchar2
 ,p_wv_prtn_rsn_cd                 in varchar2
 ,p_wpn_attribute_category         in varchar2
 ,p_wpn_attribute1                 in varchar2
 ,p_wpn_attribute2                 in varchar2
 ,p_wpn_attribute3                 in varchar2
 ,p_wpn_attribute4                 in varchar2
 ,p_wpn_attribute5                 in varchar2
 ,p_wpn_attribute6                 in varchar2
 ,p_wpn_attribute7                 in varchar2
 ,p_wpn_attribute8                 in varchar2
 ,p_wpn_attribute9                 in varchar2
 ,p_wpn_attribute10                in varchar2
 ,p_wpn_attribute11                in varchar2
 ,p_wpn_attribute12                in varchar2
 ,p_wpn_attribute13                in varchar2
 ,p_wpn_attribute14                in varchar2
 ,p_wpn_attribute15                in varchar2
 ,p_wpn_attribute16                in varchar2
 ,p_wpn_attribute17                in varchar2
 ,p_wpn_attribute18                in varchar2
 ,p_wpn_attribute19                in varchar2
 ,p_wpn_attribute20                in varchar2
 ,p_wpn_attribute21                in varchar2
 ,p_wpn_attribute22                in varchar2
 ,p_wpn_attribute23                in varchar2
 ,p_wpn_attribute24                in varchar2
 ,p_wpn_attribute25                in varchar2
 ,p_wpn_attribute26                in varchar2
 ,p_wpn_attribute27                in varchar2
 ,p_wpn_attribute28                in varchar2
 ,p_wpn_attribute29                in varchar2
 ,p_wpn_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_wpn_rki;

/
