--------------------------------------------------------
--  DDL for Package BEN_WCN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WCN_RKU" AUTHID CURRENT_USER as
/* $Header: bewcnrhi.pkh 120.0.12010000.1 2008/07/29 13:08:57 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_wv_prtn_rsn_ctfn_pl_id         in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_pfd_flag                       in varchar2
 ,p_lack_ctfn_sspnd_wvr_flag       in varchar2
 ,p_rqd_flag                       in varchar2
 ,p_ctfn_rqd_when_rl               in number
 ,p_wv_prtn_ctfn_typ_cd            in varchar2
 ,p_wv_prtn_rsn_pl_id              in number
 ,p_business_group_id              in number
 ,p_wcn_attribute_category         in varchar2
 ,p_wcn_attribute1                 in varchar2
 ,p_wcn_attribute2                 in varchar2
 ,p_wcn_attribute3                 in varchar2
 ,p_wcn_attribute4                 in varchar2
 ,p_wcn_attribute5                 in varchar2
 ,p_wcn_attribute6                 in varchar2
 ,p_wcn_attribute7                 in varchar2
 ,p_wcn_attribute8                 in varchar2
 ,p_wcn_attribute9                 in varchar2
 ,p_wcn_attribute10                in varchar2
 ,p_wcn_attribute11                in varchar2
 ,p_wcn_attribute12                in varchar2
 ,p_wcn_attribute13                in varchar2
 ,p_wcn_attribute14                in varchar2
 ,p_wcn_attribute15                in varchar2
 ,p_wcn_attribute16                in varchar2
 ,p_wcn_attribute17                in varchar2
 ,p_wcn_attribute18                in varchar2
 ,p_wcn_attribute19                in varchar2
 ,p_wcn_attribute20                in varchar2
 ,p_wcn_attribute21                in varchar2
 ,p_wcn_attribute22                in varchar2
 ,p_wcn_attribute23                in varchar2
 ,p_wcn_attribute24                in varchar2
 ,p_wcn_attribute25                in varchar2
 ,p_wcn_attribute26                in varchar2
 ,p_wcn_attribute27                in varchar2
 ,p_wcn_attribute28                in varchar2
 ,p_wcn_attribute29                in varchar2
 ,p_wcn_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_pfd_flag_o                     in varchar2
 ,p_lack_ctfn_sspnd_wvr_flag_o     in varchar2
 ,p_rqd_flag_o                     in varchar2
 ,p_ctfn_rqd_when_rl_o             in number
 ,p_wv_prtn_ctfn_typ_cd_o          in varchar2
 ,p_wv_prtn_rsn_pl_id_o            in number
 ,p_business_group_id_o            in number
 ,p_wcn_attribute_category_o       in varchar2
 ,p_wcn_attribute1_o               in varchar2
 ,p_wcn_attribute2_o               in varchar2
 ,p_wcn_attribute3_o               in varchar2
 ,p_wcn_attribute4_o               in varchar2
 ,p_wcn_attribute5_o               in varchar2
 ,p_wcn_attribute6_o               in varchar2
 ,p_wcn_attribute7_o               in varchar2
 ,p_wcn_attribute8_o               in varchar2
 ,p_wcn_attribute9_o               in varchar2
 ,p_wcn_attribute10_o              in varchar2
 ,p_wcn_attribute11_o              in varchar2
 ,p_wcn_attribute12_o              in varchar2
 ,p_wcn_attribute13_o              in varchar2
 ,p_wcn_attribute14_o              in varchar2
 ,p_wcn_attribute15_o              in varchar2
 ,p_wcn_attribute16_o              in varchar2
 ,p_wcn_attribute17_o              in varchar2
 ,p_wcn_attribute18_o              in varchar2
 ,p_wcn_attribute19_o              in varchar2
 ,p_wcn_attribute20_o              in varchar2
 ,p_wcn_attribute21_o              in varchar2
 ,p_wcn_attribute22_o              in varchar2
 ,p_wcn_attribute23_o              in varchar2
 ,p_wcn_attribute24_o              in varchar2
 ,p_wcn_attribute25_o              in varchar2
 ,p_wcn_attribute26_o              in varchar2
 ,p_wcn_attribute27_o              in varchar2
 ,p_wcn_attribute28_o              in varchar2
 ,p_wcn_attribute29_o              in varchar2
 ,p_wcn_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_wcn_rku;

/