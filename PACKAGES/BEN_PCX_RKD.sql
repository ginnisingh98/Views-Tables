--------------------------------------------------------
--  DDL for Package BEN_PCX_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PCX_RKD" AUTHID CURRENT_USER as
/* $Header: bepcxrhi.pkh 120.0 2005/05/28 10:21:31 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_pl_bnf_ctfn_id                 in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_pl_id_o                        in number
 ,p_bnf_ctfn_typ_cd_o              in varchar2
 ,p_lack_ctfn_sspnd_enrt_flag_o    in varchar2
 ,p_pfd_flag_o                     in varchar2
 ,p_rqd_flag_o                     in varchar2
 ,p_ctfn_rqd_when_rl_o             in number
 ,p_bnf_typ_cd_o                   in varchar2
 ,p_rlshp_typ_cd_o                 in varchar2
 ,p_object_version_number_o        in number
 ,p_business_group_id_o            in number
 ,p_pcx_attribute_category_o       in varchar2
 ,p_pcx_attribute1_o               in varchar2
 ,p_pcx_attribute2_o               in varchar2
 ,p_pcx_attribute3_o               in varchar2
 ,p_pcx_attribute4_o               in varchar2
 ,p_pcx_attribute5_o               in varchar2
 ,p_pcx_attribute6_o               in varchar2
 ,p_pcx_attribute7_o               in varchar2
 ,p_pcx_attribute8_o               in varchar2
 ,p_pcx_attribute9_o               in varchar2
 ,p_pcx_attribute10_o              in varchar2
 ,p_pcx_attribute11_o              in varchar2
 ,p_pcx_attribute12_o              in varchar2
 ,p_pcx_attribute13_o              in varchar2
 ,p_pcx_attribute14_o              in varchar2
 ,p_pcx_attribute15_o              in varchar2
 ,p_pcx_attribute16_o              in varchar2
 ,p_pcx_attribute17_o              in varchar2
 ,p_pcx_attribute18_o              in varchar2
 ,p_pcx_attribute19_o              in varchar2
 ,p_pcx_attribute20_o              in varchar2
 ,p_pcx_attribute21_o              in varchar2
 ,p_pcx_attribute22_o              in varchar2
 ,p_pcx_attribute23_o              in varchar2
 ,p_pcx_attribute24_o              in varchar2
 ,p_pcx_attribute25_o              in varchar2
 ,p_pcx_attribute26_o              in varchar2
 ,p_pcx_attribute27_o              in varchar2
 ,p_pcx_attribute28_o              in varchar2
 ,p_pcx_attribute29_o              in varchar2
 ,p_pcx_attribute30_o              in varchar2
  );
--
end ben_pcx_rkd;

 

/
