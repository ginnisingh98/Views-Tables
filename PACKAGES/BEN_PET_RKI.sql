--------------------------------------------------------
--  DDL for Package BEN_PET_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PET_RKI" AUTHID CURRENT_USER as
/* $Header: bepetrhi.pkh 120.0 2005/05/28 10:41:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_popl_enrt_typ_cycl_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_enrt_typ_cycl_cd               in varchar2
 ,p_pl_id                          in number
 ,p_pgm_id                         in number
 ,p_pet_attribute_category         in varchar2
 ,p_pet_attribute1                 in varchar2
 ,p_pet_attribute2                 in varchar2
 ,p_pet_attribute3                 in varchar2
 ,p_pet_attribute4                 in varchar2
 ,p_pet_attribute5                 in varchar2
 ,p_pet_attribute6                 in varchar2
 ,p_pet_attribute7                 in varchar2
 ,p_pet_attribute8                 in varchar2
 ,p_pet_attribute9                 in varchar2
 ,p_pet_attribute10                in varchar2
 ,p_pet_attribute11                in varchar2
 ,p_pet_attribute12                in varchar2
 ,p_pet_attribute13                in varchar2
 ,p_pet_attribute14                in varchar2
 ,p_pet_attribute15                in varchar2
 ,p_pet_attribute16                in varchar2
 ,p_pet_attribute17                in varchar2
 ,p_pet_attribute18                in varchar2
 ,p_pet_attribute19                in varchar2
 ,p_pet_attribute20                in varchar2
 ,p_pet_attribute21                in varchar2
 ,p_pet_attribute22                in varchar2
 ,p_pet_attribute23                in varchar2
 ,p_pet_attribute24                in varchar2
 ,p_pet_attribute25                in varchar2
 ,p_pet_attribute26                in varchar2
 ,p_pet_attribute27                in varchar2
 ,p_pet_attribute28                in varchar2
 ,p_pet_attribute29                in varchar2
 ,p_pet_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_pet_rki;

 

/
