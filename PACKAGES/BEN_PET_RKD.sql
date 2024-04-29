--------------------------------------------------------
--  DDL for Package BEN_PET_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PET_RKD" AUTHID CURRENT_USER as
/* $Header: bepetrhi.pkh 120.0 2005/05/28 10:41:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_popl_enrt_typ_cycl_id          in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_enrt_typ_cycl_cd_o             in varchar2
 ,p_pl_id_o                        in number
 ,p_pgm_id_o                       in number
 ,p_pet_attribute_category_o       in varchar2
 ,p_pet_attribute1_o               in varchar2
 ,p_pet_attribute2_o               in varchar2
 ,p_pet_attribute3_o               in varchar2
 ,p_pet_attribute4_o               in varchar2
 ,p_pet_attribute5_o               in varchar2
 ,p_pet_attribute6_o               in varchar2
 ,p_pet_attribute7_o               in varchar2
 ,p_pet_attribute8_o               in varchar2
 ,p_pet_attribute9_o               in varchar2
 ,p_pet_attribute10_o              in varchar2
 ,p_pet_attribute11_o              in varchar2
 ,p_pet_attribute12_o              in varchar2
 ,p_pet_attribute13_o              in varchar2
 ,p_pet_attribute14_o              in varchar2
 ,p_pet_attribute15_o              in varchar2
 ,p_pet_attribute16_o              in varchar2
 ,p_pet_attribute17_o              in varchar2
 ,p_pet_attribute18_o              in varchar2
 ,p_pet_attribute19_o              in varchar2
 ,p_pet_attribute20_o              in varchar2
 ,p_pet_attribute21_o              in varchar2
 ,p_pet_attribute22_o              in varchar2
 ,p_pet_attribute23_o              in varchar2
 ,p_pet_attribute24_o              in varchar2
 ,p_pet_attribute25_o              in varchar2
 ,p_pet_attribute26_o              in varchar2
 ,p_pet_attribute27_o              in varchar2
 ,p_pet_attribute28_o              in varchar2
 ,p_pet_attribute29_o              in varchar2
 ,p_pet_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pet_rkd;

 

/