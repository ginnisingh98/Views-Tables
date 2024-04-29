--------------------------------------------------------
--  DDL for Package BEN_PCT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCT_RKU" AUTHID CURRENT_USER as
/* $Header: bepctrhi.pkh 120.0 2005/05/28 10:18:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_pl_gd_r_svc_ctfn_id            in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_pl_gd_or_svc_id                in number
 ,p_pfd_flag                       in varchar2
 ,p_lack_ctfn_deny_rmbmt_flag      in varchar2
 ,p_rmbmt_ctfn_typ_cd              in varchar2
 ,p_lack_ctfn_deny_rmbmt_rl        in number
 ,p_pct_attribute_category         in varchar2
 ,p_pct_attribute1                 in varchar2
 ,p_pct_attribute2                 in varchar2
 ,p_pct_attribute3                 in varchar2
 ,p_pct_attribute4                 in varchar2
 ,p_pct_attribute5                 in varchar2
 ,p_pct_attribute6                 in varchar2
 ,p_pct_attribute7                 in varchar2
 ,p_pct_attribute8                 in varchar2
 ,p_pct_attribute9                 in varchar2
 ,p_pct_attribute10                in varchar2
 ,p_pct_attribute11                in varchar2
 ,p_pct_attribute12                in varchar2
 ,p_pct_attribute13                in varchar2
 ,p_pct_attribute14                in varchar2
 ,p_pct_attribute15                in varchar2
 ,p_pct_attribute16                in varchar2
 ,p_pct_attribute17                in varchar2
 ,p_pct_attribute18                in varchar2
 ,p_pct_attribute19                in varchar2
 ,p_pct_attribute20                in varchar2
 ,p_pct_attribute21                in varchar2
 ,p_pct_attribute22                in varchar2
 ,p_pct_attribute23                in varchar2
 ,p_pct_attribute24                in varchar2
 ,p_pct_attribute25                in varchar2
 ,p_pct_attribute26                in varchar2
 ,p_pct_attribute27                in varchar2
 ,p_pct_attribute28                in varchar2
 ,p_pct_attribute29                in varchar2
 ,p_pct_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_ctfn_rqd_when_rl               in number
 ,p_rqd_flag                       in varchar2
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_pl_gd_or_svc_id_o              in number
 ,p_pfd_flag_o                     in varchar2
 ,p_lack_ctfn_deny_rmbmt_flag_o    in varchar2
 ,p_rmbmt_ctfn_typ_cd_o            in varchar2
 ,p_lack_ctfn_deny_rmbmt_rl_o      in number
 ,p_pct_attribute_category_o       in varchar2
 ,p_pct_attribute1_o               in varchar2
 ,p_pct_attribute2_o               in varchar2
 ,p_pct_attribute3_o               in varchar2
 ,p_pct_attribute4_o               in varchar2
 ,p_pct_attribute5_o               in varchar2
 ,p_pct_attribute6_o               in varchar2
 ,p_pct_attribute7_o               in varchar2
 ,p_pct_attribute8_o               in varchar2
 ,p_pct_attribute9_o               in varchar2
 ,p_pct_attribute10_o              in varchar2
 ,p_pct_attribute11_o              in varchar2
 ,p_pct_attribute12_o              in varchar2
 ,p_pct_attribute13_o              in varchar2
 ,p_pct_attribute14_o              in varchar2
 ,p_pct_attribute15_o              in varchar2
 ,p_pct_attribute16_o              in varchar2
 ,p_pct_attribute17_o              in varchar2
 ,p_pct_attribute18_o              in varchar2
 ,p_pct_attribute19_o              in varchar2
 ,p_pct_attribute20_o              in varchar2
 ,p_pct_attribute21_o              in varchar2
 ,p_pct_attribute22_o              in varchar2
 ,p_pct_attribute23_o              in varchar2
 ,p_pct_attribute24_o              in varchar2
 ,p_pct_attribute25_o              in varchar2
 ,p_pct_attribute26_o              in varchar2
 ,p_pct_attribute27_o              in varchar2
 ,p_pct_attribute28_o              in varchar2
 ,p_pct_attribute29_o              in varchar2
 ,p_pct_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_ctfn_rqd_when_rl_o             in number
 ,p_rqd_flag_o                     in varchar2
  );
--
end ben_pct_rku;

 

/
