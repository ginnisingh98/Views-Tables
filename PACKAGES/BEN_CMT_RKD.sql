--------------------------------------------------------
--  DDL for Package BEN_CMT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CMT_RKD" AUTHID CURRENT_USER as
/* $Header: becmtrhi.pkh 120.0 2005/05/28 01:08:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_cm_dlvry_mthd_typ_id           in number
 ,p_cm_dlvry_mthd_typ_cd_o         in varchar2
 ,p_business_group_id_o            in number
 ,p_cm_typ_id_o                    in number
 ,p_cmt_attribute1_o               in varchar2
 ,p_cmt_attribute10_o              in varchar2
 ,p_cmt_attribute11_o              in varchar2
 ,p_cmt_attribute12_o              in varchar2
 ,p_cmt_attribute13_o              in varchar2
 ,p_cmt_attribute14_o              in varchar2
 ,p_cmt_attribute15_o              in varchar2
 ,p_cmt_attribute16_o              in varchar2
 ,p_cmt_attribute17_o              in varchar2
 ,p_cmt_attribute18_o              in varchar2
 ,p_cmt_attribute19_o              in varchar2
 ,p_cmt_attribute2_o               in varchar2
 ,p_cmt_attribute20_o              in varchar2
 ,p_cmt_attribute21_o              in varchar2
 ,p_cmt_attribute22_o              in varchar2
 ,p_cmt_attribute23_o              in varchar2
 ,p_cmt_attribute24_o              in varchar2
 ,p_cmt_attribute25_o              in varchar2
 ,p_cmt_attribute26_o              in varchar2
 ,p_cmt_attribute27_o              in varchar2
 ,p_cmt_attribute28_o              in varchar2
 ,p_cmt_attribute29_o              in varchar2
 ,p_cmt_attribute3_o               in varchar2
 ,p_cmt_attribute30_o              in varchar2
 ,p_rqd_flag_o                     in varchar2
 ,p_cmt_attribute_category_o       in varchar2
 ,p_cmt_attribute4_o               in varchar2
 ,p_cmt_attribute5_o               in varchar2
 ,p_cmt_attribute6_o               in varchar2
 ,p_cmt_attribute7_o               in varchar2
 ,p_cmt_attribute8_o               in varchar2
 ,p_cmt_attribute9_o               in varchar2
 ,p_dflt_flag_o                    in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_cmt_rkd;

 

/
