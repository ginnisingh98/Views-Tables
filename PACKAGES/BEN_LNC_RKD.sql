--------------------------------------------------------
--  DDL for Package BEN_LNC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LNC_RKD" AUTHID CURRENT_USER as
/* $Header: belncrhi.pkh 120.0 2005/05/28 03:25:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ler_enrt_ctfn_id               in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_rqd_flag_o                     in varchar2
 ,p_enrt_ctfn_typ_cd_o             in varchar2
 ,p_ctfn_rqd_when_rl_o             in number
 ,p_ler_rqrs_enrt_ctfn_id_o        in number
 ,p_business_group_id_o            in number
 ,p_lnc_attribute_category_o       in varchar2
 ,p_lnc_attribute1_o               in varchar2
 ,p_lnc_attribute2_o               in varchar2
 ,p_lnc_attribute3_o               in varchar2
 ,p_lnc_attribute4_o               in varchar2
 ,p_lnc_attribute5_o               in varchar2
 ,p_lnc_attribute6_o               in varchar2
 ,p_lnc_attribute7_o               in varchar2
 ,p_lnc_attribute8_o               in varchar2
 ,p_lnc_attribute9_o               in varchar2
 ,p_lnc_attribute10_o              in varchar2
 ,p_lnc_attribute11_o              in varchar2
 ,p_lnc_attribute12_o              in varchar2
 ,p_lnc_attribute13_o              in varchar2
 ,p_lnc_attribute14_o              in varchar2
 ,p_lnc_attribute15_o              in varchar2
 ,p_lnc_attribute16_o              in varchar2
 ,p_lnc_attribute17_o              in varchar2
 ,p_lnc_attribute18_o              in varchar2
 ,p_lnc_attribute19_o              in varchar2
 ,p_lnc_attribute20_o              in varchar2
 ,p_lnc_attribute21_o              in varchar2
 ,p_lnc_attribute22_o              in varchar2
 ,p_lnc_attribute23_o              in varchar2
 ,p_lnc_attribute24_o              in varchar2
 ,p_lnc_attribute25_o              in varchar2
 ,p_lnc_attribute26_o              in varchar2
 ,p_lnc_attribute27_o              in varchar2
 ,p_lnc_attribute28_o              in varchar2
 ,p_lnc_attribute29_o              in varchar2
 ,p_lnc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lnc_rkd;

 

/
