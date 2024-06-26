--------------------------------------------------------
--  DDL for Package BEN_WYP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WYP_RKI" AUTHID CURRENT_USER as
/* $Header: bewyprhi.pkh 120.0 2005/05/28 12:21:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_wthn_yr_perd_id                in number
 ,p_strt_day                       in number
 ,p_end_day                        in number
 ,p_strt_mo                        in number
 ,p_end_mo                         in number
 ,p_tm_uom                         in varchar2
 ,p_yr_perd_id                     in number
 ,p_business_group_id              in number
 ,p_wyp_attribute_category         in varchar2
 ,p_wyp_attribute1                 in varchar2
 ,p_wyp_attribute2                 in varchar2
 ,p_wyp_attribute3                 in varchar2
 ,p_wyp_attribute4                 in varchar2
 ,p_wyp_attribute5                 in varchar2
 ,p_wyp_attribute6                 in varchar2
 ,p_wyp_attribute7                 in varchar2
 ,p_wyp_attribute8                 in varchar2
 ,p_wyp_attribute9                 in varchar2
 ,p_wyp_attribute10                in varchar2
 ,p_wyp_attribute11                in varchar2
 ,p_wyp_attribute12                in varchar2
 ,p_wyp_attribute13                in varchar2
 ,p_wyp_attribute14                in varchar2
 ,p_wyp_attribute15                in varchar2
 ,p_wyp_attribute16                in varchar2
 ,p_wyp_attribute17                in varchar2
 ,p_wyp_attribute18                in varchar2
 ,p_wyp_attribute19                in varchar2
 ,p_wyp_attribute20                in varchar2
 ,p_wyp_attribute21                in varchar2
 ,p_wyp_attribute22                in varchar2
 ,p_wyp_attribute23                in varchar2
 ,p_wyp_attribute24                in varchar2
 ,p_wyp_attribute25                in varchar2
 ,p_wyp_attribute26                in varchar2
 ,p_wyp_attribute27                in varchar2
 ,p_wyp_attribute28                in varchar2
 ,p_wyp_attribute29                in varchar2
 ,p_wyp_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
  );
end ben_wyp_rki;

 

/
