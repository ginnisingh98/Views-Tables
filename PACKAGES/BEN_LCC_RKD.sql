--------------------------------------------------------
--  DDL for Package BEN_LCC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LCC_RKD" AUTHID CURRENT_USER as
/* $Header: belccrhi.pkh 120.0 2005/05/28 03:17:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ler_chg_dpnt_cvg_ctfn_id       in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_dpnt_cvg_ctfn_typ_cd_o         in varchar2
 ,p_rlshp_typ_cd_o		   in varchar2
 ,p_ctfn_rqd_when_rl_o  	   in number
 ,p_lack_ctfn_sspnd_enrt_flag_o	   in varchar2
 ,p_rqd_flag_o			   in varchar2
 ,p_ler_chg_dpnt_cvg_id_o          in number
 ,p_business_group_id_o            in number
 ,p_lcc_attribute_category_o       in varchar2
 ,p_lcc_attribute1_o               in varchar2
 ,p_lcc_attribute2_o               in varchar2
 ,p_lcc_attribute3_o               in varchar2
 ,p_lcc_attribute4_o               in varchar2
 ,p_lcc_attribute5_o               in varchar2
 ,p_lcc_attribute6_o               in varchar2
 ,p_lcc_attribute7_o               in varchar2
 ,p_lcc_attribute8_o               in varchar2
 ,p_lcc_attribute9_o               in varchar2
 ,p_lcc_attribute10_o              in varchar2
 ,p_lcc_attribute11_o              in varchar2
 ,p_lcc_attribute12_o              in varchar2
 ,p_lcc_attribute13_o              in varchar2
 ,p_lcc_attribute14_o              in varchar2
 ,p_lcc_attribute15_o              in varchar2
 ,p_lcc_attribute16_o              in varchar2
 ,p_lcc_attribute17_o              in varchar2
 ,p_lcc_attribute18_o              in varchar2
 ,p_lcc_attribute19_o              in varchar2
 ,p_lcc_attribute20_o              in varchar2
 ,p_lcc_attribute21_o              in varchar2
 ,p_lcc_attribute22_o              in varchar2
 ,p_lcc_attribute23_o              in varchar2
 ,p_lcc_attribute24_o              in varchar2
 ,p_lcc_attribute25_o              in varchar2
 ,p_lcc_attribute26_o              in varchar2
 ,p_lcc_attribute27_o              in varchar2
 ,p_lcc_attribute28_o              in varchar2
 ,p_lcc_attribute29_o              in varchar2
 ,p_lcc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lcc_rkd;

 

/
