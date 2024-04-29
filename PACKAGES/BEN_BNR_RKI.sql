--------------------------------------------------------
--  DDL for Package BEN_BNR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BNR_RKI" AUTHID CURRENT_USER as
/* $Header: bebnrrhi.pkh 120.0 2005/05/28 00:46:11 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_rptg_grp_id                    in number
 ,p_name                           in varchar2
 ,p_business_group_id              in number
-- ,p_pgm_id                         in number
 ,p_rptg_prps_cd                   in varchar2
 ,p_rpg_desc                       in varchar2
 ,p_bnr_attribute_category         in varchar2
 ,p_bnr_attribute1                 in varchar2
 ,p_bnr_attribute2                 in varchar2
 ,p_bnr_attribute3                 in varchar2
 ,p_bnr_attribute4                 in varchar2
 ,p_bnr_attribute5                 in varchar2
 ,p_bnr_attribute6                 in varchar2
 ,p_bnr_attribute7                 in varchar2
 ,p_bnr_attribute8                 in varchar2
 ,p_bnr_attribute9                 in varchar2
 ,p_bnr_attribute10                in varchar2
 ,p_bnr_attribute11                in varchar2
 ,p_bnr_attribute12                in varchar2
 ,p_bnr_attribute13                in varchar2
 ,p_bnr_attribute14                in varchar2
 ,p_bnr_attribute15                in varchar2
 ,p_bnr_attribute16                in varchar2
 ,p_bnr_attribute17                in varchar2
 ,p_bnr_attribute18                in varchar2
 ,p_bnr_attribute19                in varchar2
 ,p_bnr_attribute20                in varchar2
 ,p_bnr_attribute21                in varchar2
 ,p_bnr_attribute22                in varchar2
 ,p_bnr_attribute23                in varchar2
 ,p_bnr_attribute24                in varchar2
 ,p_bnr_attribute25                in varchar2
 ,p_bnr_attribute26                in varchar2
 ,p_bnr_attribute27                in varchar2
 ,p_bnr_attribute28                in varchar2
 ,p_bnr_attribute29                in varchar2
 ,p_bnr_attribute30                in varchar2
 ,p_function_code                 in varchar2
 ,p_legislation_code              in varchar2
 ,p_object_version_number          in number
 ,p_ordr_num                       in number            --iRec
 ,p_effective_date                 in date
  );
end ben_bnr_rki;

 

/
