--------------------------------------------------------
--  DDL for Package BEN_ECF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ECF_RKD" AUTHID CURRENT_USER as
/* $Header: beecfrhi.pkh 120.0 2005/05/28 01:50:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_enrt_ctfn_id                   in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_enrt_ctfn_typ_cd_o             in varchar2
 ,p_ctfn_rqd_when_rl_o             in number
 ,p_rqd_flag_o                     in varchar2
 ,p_pl_id_o                        in number
 ,p_business_group_id_o            in number
 ,p_ecf_attribute_category_o       in varchar2
 ,p_ecf_attribute1_o               in varchar2
 ,p_ecf_attribute2_o               in varchar2
 ,p_ecf_attribute3_o               in varchar2
 ,p_ecf_attribute4_o               in varchar2
 ,p_ecf_attribute5_o               in varchar2
 ,p_ecf_attribute6_o               in varchar2
 ,p_ecf_attribute7_o               in varchar2
 ,p_ecf_attribute8_o               in varchar2
 ,p_ecf_attribute9_o               in varchar2
 ,p_ecf_attribute10_o              in varchar2
 ,p_ecf_attribute11_o              in varchar2
 ,p_ecf_attribute12_o              in varchar2
 ,p_ecf_attribute13_o              in varchar2
 ,p_ecf_attribute14_o              in varchar2
 ,p_ecf_attribute15_o              in varchar2
 ,p_ecf_attribute16_o              in varchar2
 ,p_ecf_attribute17_o              in varchar2
 ,p_ecf_attribute18_o              in varchar2
 ,p_ecf_attribute19_o              in varchar2
 ,p_ecf_attribute20_o              in varchar2
 ,p_ecf_attribute21_o              in varchar2
 ,p_ecf_attribute22_o              in varchar2
 ,p_ecf_attribute23_o              in varchar2
 ,p_ecf_attribute24_o              in varchar2
 ,p_ecf_attribute25_o              in varchar2
 ,p_ecf_attribute26_o              in varchar2
 ,p_ecf_attribute27_o              in varchar2
 ,p_ecf_attribute28_o              in varchar2
 ,p_ecf_attribute29_o              in varchar2
 ,p_ecf_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_oipl_id_o                      in number
  );
--
end ben_ecf_rkd;

 

/
