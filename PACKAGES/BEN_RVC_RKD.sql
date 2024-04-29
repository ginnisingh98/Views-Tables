--------------------------------------------------------
--  DDL for Package BEN_RVC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RVC_RKD" AUTHID CURRENT_USER as
/* $Header: bervcrhi.pkh 120.0 2005/05/28 11:45:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_prtt_rt_val_ctfn_prvdd_id            in number
 ,p_enrt_ctfn_typ_cd_o             in varchar2
 ,p_enrt_ctfn_rqd_flag_o           in varchar2
 ,p_enrt_ctfn_recd_dt_o            in date
 ,p_enrt_ctfn_dnd_dt_o             in date
 ,p_prtt_rt_val_id_o               in number
 ,p_business_group_id_o            in number
 ,p_rvc_attribute_category_o       in varchar2
 ,p_rvc_attribute1_o               in varchar2
 ,p_rvc_attribute2_o               in varchar2
 ,p_rvc_attribute3_o               in varchar2
 ,p_rvc_attribute4_o               in varchar2
 ,p_rvc_attribute5_o               in varchar2
 ,p_rvc_attribute6_o               in varchar2
 ,p_rvc_attribute7_o               in varchar2
 ,p_rvc_attribute8_o               in varchar2
 ,p_rvc_attribute9_o               in varchar2
 ,p_rvc_attribute10_o              in varchar2
 ,p_rvc_attribute11_o              in varchar2
 ,p_rvc_attribute12_o              in varchar2
 ,p_rvc_attribute13_o              in varchar2
 ,p_rvc_attribute14_o              in varchar2
 ,p_rvc_attribute15_o              in varchar2
 ,p_rvc_attribute16_o              in varchar2
 ,p_rvc_attribute17_o              in varchar2
 ,p_rvc_attribute18_o              in varchar2
 ,p_rvc_attribute19_o              in varchar2
 ,p_rvc_attribute20_o              in varchar2
 ,p_rvc_attribute21_o              in varchar2
 ,p_rvc_attribute22_o              in varchar2
 ,p_rvc_attribute23_o              in varchar2
 ,p_rvc_attribute24_o              in varchar2
 ,p_rvc_attribute25_o              in varchar2
 ,p_rvc_attribute26_o              in varchar2
 ,p_rvc_attribute27_o              in varchar2
 ,p_rvc_attribute28_o              in varchar2
 ,p_rvc_attribute29_o              in varchar2
 ,p_rvc_attribute30_o              in varchar2
 ,p_request_id_o                   in number
 ,p_program_application_id_o       in number
 ,p_program_id_o                   in number
 ,p_program_update_date_o          in date
 ,p_object_version_number_o        in number
  );
--
end ben_rvc_rkd;

 

/
