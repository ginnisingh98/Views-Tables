--------------------------------------------------------
--  DDL for Package BEN_PCG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCG_RKD" AUTHID CURRENT_USER as
/* $Header: bepcgrhi.pkh 120.0 2005/05/28 10:11:18 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_prtt_clm_gd_or_svc_typ_id      in number
 ,p_prtt_reimbmt_rqst_id_o         in number
 ,p_gd_or_svc_typ_id_o             in number
 ,p_business_group_id_o            in number
 ,p_pcg_attribute_category_o       in varchar2
 ,p_pcg_attribute1_o               in varchar2
 ,p_pcg_attribute2_o               in varchar2
 ,p_pcg_attribute3_o               in varchar2
 ,p_pcg_attribute4_o               in varchar2
 ,p_pcg_attribute5_o               in varchar2
 ,p_pcg_attribute6_o               in varchar2
 ,p_pcg_attribute7_o               in varchar2
 ,p_pcg_attribute8_o               in varchar2
 ,p_pcg_attribute9_o               in varchar2
 ,p_pcg_attribute10_o              in varchar2
 ,p_pcg_attribute11_o              in varchar2
 ,p_pcg_attribute12_o              in varchar2
 ,p_pcg_attribute13_o              in varchar2
 ,p_pcg_attribute14_o              in varchar2
 ,p_pcg_attribute15_o              in varchar2
 ,p_pcg_attribute16_o              in varchar2
 ,p_pcg_attribute17_o              in varchar2
 ,p_pcg_attribute18_o              in varchar2
 ,p_pcg_attribute19_o              in varchar2
 ,p_pcg_attribute20_o              in varchar2
 ,p_pcg_attribute21_o              in varchar2
 ,p_pcg_attribute22_o              in varchar2
 ,p_pcg_attribute23_o              in varchar2
 ,p_pcg_attribute24_o              in varchar2
 ,p_pcg_attribute25_o              in varchar2
 ,p_pcg_attribute26_o              in varchar2
 ,p_pcg_attribute27_o              in varchar2
 ,p_pcg_attribute28_o              in varchar2
 ,p_pcg_attribute29_o              in varchar2
 ,p_pcg_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_pl_gd_or_svc_id_o                  in number
  );
--
end ben_pcg_rkd;

 

/
