--------------------------------------------------------
--  DDL for Package BEN_RVC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RVC_RKU" AUTHID CURRENT_USER as
/* $Header: bervcrhi.pkh 120.0 2005/05/28 11:45:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_prtt_rt_val_ctfn_prvdd_id            in number
 ,p_enrt_ctfn_typ_cd               in varchar2
 ,p_enrt_ctfn_rqd_flag             in varchar2
 ,p_enrt_ctfn_recd_dt              in date
 ,p_enrt_ctfn_dnd_dt               in date
 ,p_prtt_rt_val_id                 in number
 ,p_business_group_id              in number
 ,p_rvc_attribute_category         in varchar2
 ,p_rvc_attribute1                 in varchar2
 ,p_rvc_attribute2                 in varchar2
 ,p_rvc_attribute3                 in varchar2
 ,p_rvc_attribute4                 in varchar2
 ,p_rvc_attribute5                 in varchar2
 ,p_rvc_attribute6                 in varchar2
 ,p_rvc_attribute7                 in varchar2
 ,p_rvc_attribute8                 in varchar2
 ,p_rvc_attribute9                 in varchar2
 ,p_rvc_attribute10                in varchar2
 ,p_rvc_attribute11                in varchar2
 ,p_rvc_attribute12                in varchar2
 ,p_rvc_attribute13                in varchar2
 ,p_rvc_attribute14                in varchar2
 ,p_rvc_attribute15                in varchar2
 ,p_rvc_attribute16                in varchar2
 ,p_rvc_attribute17                in varchar2
 ,p_rvc_attribute18                in varchar2
 ,p_rvc_attribute19                in varchar2
 ,p_rvc_attribute20                in varchar2
 ,p_rvc_attribute21                in varchar2
 ,p_rvc_attribute22                in varchar2
 ,p_rvc_attribute23                in varchar2
 ,p_rvc_attribute24                in varchar2
 ,p_rvc_attribute25                in varchar2
 ,p_rvc_attribute26                in varchar2
 ,p_rvc_attribute27                in varchar2
 ,p_rvc_attribute28                in varchar2
 ,p_rvc_attribute29                in varchar2
 ,p_rvc_attribute30                in varchar2
 ,p_request_id                     in number
 ,p_program_application_id         in number
 ,p_program_id                     in number
 ,p_program_update_date            in date
 ,p_object_version_number          in number
 ,p_effective_date                 in date
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
end ben_rvc_rku;

 

/
