--------------------------------------------------------
--  DDL for Package BEN_LRC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LRC_RKI" AUTHID CURRENT_USER as
/* $Header: belrcrhi.pkh 120.0 2005/05/28 03:33:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_ler_rltd_per_cs_ler_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_ler_rltd_per_cs_chg_rl         in number
 ,p_ler_id                         in number
 ,p_rltd_per_chg_cs_ler_id         in number
 ,p_business_group_id              in number
 ,p_lrc_attribute_category         in varchar2
 ,p_lrc_attribute1                 in varchar2
 ,p_lrc_attribute2                 in varchar2
 ,p_lrc_attribute3                 in varchar2
 ,p_lrc_attribute4                 in varchar2
 ,p_lrc_attribute5                 in varchar2
 ,p_lrc_attribute6                 in varchar2
 ,p_lrc_attribute7                 in varchar2
 ,p_lrc_attribute8                 in varchar2
 ,p_lrc_attribute9                 in varchar2
 ,p_lrc_attribute10                in varchar2
 ,p_lrc_attribute11                in varchar2
 ,p_lrc_attribute12                in varchar2
 ,p_lrc_attribute13                in varchar2
 ,p_lrc_attribute14                in varchar2
 ,p_lrc_attribute15                in varchar2
 ,p_lrc_attribute16                in varchar2
 ,p_lrc_attribute17                in varchar2
 ,p_lrc_attribute18                in varchar2
 ,p_lrc_attribute19                in varchar2
 ,p_lrc_attribute20                in varchar2
 ,p_lrc_attribute21                in varchar2
 ,p_lrc_attribute22                in varchar2
 ,p_lrc_attribute23                in varchar2
 ,p_lrc_attribute24                in varchar2
 ,p_lrc_attribute25                in varchar2
 ,p_lrc_attribute26                in varchar2
 ,p_lrc_attribute27                in varchar2
 ,p_lrc_attribute28                in varchar2
 ,p_lrc_attribute29                in varchar2
 ,p_lrc_attribute30                in varchar2
 ,p_chg_mandatory_cd                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_lrc_rki;

 

/
