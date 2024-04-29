--------------------------------------------------------
--  DDL for Package BEN_PON_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PON_RKI" AUTHID CURRENT_USER as
/* $Header: beponrhi.pkh 120.0 2005/05/28 10:56:38 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_pl_typ_opt_typ_id              in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_pl_typ_opt_typ_cd              in varchar2
 ,p_opt_id                         in number
 ,p_pl_typ_id                      in number
 ,p_business_group_id              in number
 ,p_legislation_code         in varchar2
 ,p_legislation_subgroup         in varchar2
 ,p_pon_attribute_category         in varchar2
 ,p_pon_attribute1                 in varchar2
 ,p_pon_attribute2                 in varchar2
 ,p_pon_attribute3                 in varchar2
 ,p_pon_attribute4                 in varchar2
 ,p_pon_attribute5                 in varchar2
 ,p_pon_attribute6                 in varchar2
 ,p_pon_attribute7                 in varchar2
 ,p_pon_attribute8                 in varchar2
 ,p_pon_attribute9                 in varchar2
 ,p_pon_attribute10                in varchar2
 ,p_pon_attribute11                in varchar2
 ,p_pon_attribute12                in varchar2
 ,p_pon_attribute13                in varchar2
 ,p_pon_attribute14                in varchar2
 ,p_pon_attribute15                in varchar2
 ,p_pon_attribute16                in varchar2
 ,p_pon_attribute17                in varchar2
 ,p_pon_attribute18                in varchar2
 ,p_pon_attribute19                in varchar2
 ,p_pon_attribute20                in varchar2
 ,p_pon_attribute21                in varchar2
 ,p_pon_attribute22                in varchar2
 ,p_pon_attribute23                in varchar2
 ,p_pon_attribute24                in varchar2
 ,p_pon_attribute25                in varchar2
 ,p_pon_attribute26                in varchar2
 ,p_pon_attribute27                in varchar2
 ,p_pon_attribute28                in varchar2
 ,p_pon_attribute29                in varchar2
 ,p_pon_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pon_rki;

 

/
