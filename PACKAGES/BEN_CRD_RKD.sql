--------------------------------------------------------
--  DDL for Package BEN_CRD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CRD_RKD" AUTHID CURRENT_USER as
/* $Header: becrdrhi.pkh 120.0 2005/05/28 01:21:21 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_crt_ordr_cvrd_per_id           in number
 ,p_crt_ordr_id_o                  in number
 ,p_person_id_o                    in number
 ,p_business_group_id_o            in number
 ,p_crd_attribute_category_o       in varchar2
 ,p_crd_attribute1_o               in varchar2
 ,p_crd_attribute2_o               in varchar2
 ,p_crd_attribute3_o               in varchar2
 ,p_crd_attribute4_o               in varchar2
 ,p_crd_attribute5_o               in varchar2
 ,p_crd_attribute6_o               in varchar2
 ,p_crd_attribute7_o               in varchar2
 ,p_crd_attribute8_o               in varchar2
 ,p_crd_attribute9_o               in varchar2
 ,p_crd_attribute10_o              in varchar2
 ,p_crd_attribute11_o              in varchar2
 ,p_crd_attribute12_o              in varchar2
 ,p_crd_attribute13_o              in varchar2
 ,p_crd_attribute14_o              in varchar2
 ,p_crd_attribute15_o              in varchar2
 ,p_crd_attribute16_o              in varchar2
 ,p_crd_attribute17_o              in varchar2
 ,p_crd_attribute18_o              in varchar2
 ,p_crd_attribute19_o              in varchar2
 ,p_crd_attribute20_o              in varchar2
 ,p_crd_attribute21_o              in varchar2
 ,p_crd_attribute22_o              in varchar2
 ,p_crd_attribute23_o              in varchar2
 ,p_crd_attribute24_o              in varchar2
 ,p_crd_attribute25_o              in varchar2
 ,p_crd_attribute26_o              in varchar2
 ,p_crd_attribute27_o              in varchar2
 ,p_crd_attribute28_o              in varchar2
 ,p_crd_attribute29_o              in varchar2
 ,p_crd_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_crd_rkd;

 

/
