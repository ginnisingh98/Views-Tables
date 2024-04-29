--------------------------------------------------------
--  DDL for Package BEN_PYD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PYD_RKD" AUTHID CURRENT_USER as
/* $Header: bepydrhi.pkh 120.0.12010000.1 2008/07/29 12:59:01 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ptip_dpnt_cvg_ctfn_id          in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_ptip_id_o                      in number
 ,p_pfd_flag_o                     in varchar2
 ,p_lack_ctfn_sspnd_enrt_flag_o    in varchar2
 ,p_ctfn_rqd_when_rl_o             in number
 ,p_dpnt_cvg_ctfn_typ_cd_o         in varchar2
 ,p_rlshp_typ_cd_o                 in varchar2
 ,p_rqd_flag_o                     in varchar2
 ,p_pyd_attribute_category_o       in varchar2
 ,p_pyd_attribute1_o               in varchar2
 ,p_pyd_attribute2_o               in varchar2
 ,p_pyd_attribute3_o               in varchar2
 ,p_pyd_attribute4_o               in varchar2
 ,p_pyd_attribute5_o               in varchar2
 ,p_pyd_attribute6_o               in varchar2
 ,p_pyd_attribute7_o               in varchar2
 ,p_pyd_attribute8_o               in varchar2
 ,p_pyd_attribute9_o               in varchar2
 ,p_pyd_attribute10_o              in varchar2
 ,p_pyd_attribute11_o              in varchar2
 ,p_pyd_attribute12_o              in varchar2
 ,p_pyd_attribute13_o              in varchar2
 ,p_pyd_attribute14_o              in varchar2
 ,p_pyd_attribute15_o              in varchar2
 ,p_pyd_attribute16_o              in varchar2
 ,p_pyd_attribute17_o              in varchar2
 ,p_pyd_attribute18_o              in varchar2
 ,p_pyd_attribute19_o              in varchar2
 ,p_pyd_attribute20_o              in varchar2
 ,p_pyd_attribute21_o              in varchar2
 ,p_pyd_attribute22_o              in varchar2
 ,p_pyd_attribute23_o              in varchar2
 ,p_pyd_attribute24_o              in varchar2
 ,p_pyd_attribute25_o              in varchar2
 ,p_pyd_attribute26_o              in varchar2
 ,p_pyd_attribute27_o              in varchar2
 ,p_pyd_attribute28_o              in varchar2
 ,p_pyd_attribute29_o              in varchar2
 ,p_pyd_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_pyd_rkd;

/
