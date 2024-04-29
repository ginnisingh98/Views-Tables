--------------------------------------------------------
--  DDL for Package BEN_BRC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BRC_RKD" AUTHID CURRENT_USER as
/* $Header: bebrcrhi.pkh 120.0.12010000.1 2008/07/29 10:59:53 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_bnft_rstrn_ctfn_id             in number
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
 ,p_pl_id_o                        in number
 ,p_business_group_id_o            in number
 ,p_brc_attribute_category_o       in varchar2
 ,p_brc_attribute1_o               in varchar2
 ,p_brc_attribute2_o               in varchar2
 ,p_brc_attribute3_o               in varchar2
 ,p_brc_attribute4_o               in varchar2
 ,p_brc_attribute5_o               in varchar2
 ,p_brc_attribute6_o               in varchar2
 ,p_brc_attribute7_o               in varchar2
 ,p_brc_attribute8_o               in varchar2
 ,p_brc_attribute9_o               in varchar2
 ,p_brc_attribute10_o              in varchar2
 ,p_brc_attribute11_o              in varchar2
 ,p_brc_attribute12_o              in varchar2
 ,p_brc_attribute13_o              in varchar2
 ,p_brc_attribute14_o              in varchar2
 ,p_brc_attribute15_o              in varchar2
 ,p_brc_attribute16_o              in varchar2
 ,p_brc_attribute17_o              in varchar2
 ,p_brc_attribute18_o              in varchar2
 ,p_brc_attribute19_o              in varchar2
 ,p_brc_attribute20_o              in varchar2
 ,p_brc_attribute21_o              in varchar2
 ,p_brc_attribute22_o              in varchar2
 ,p_brc_attribute23_o              in varchar2
 ,p_brc_attribute24_o              in varchar2
 ,p_brc_attribute25_o              in varchar2
 ,p_brc_attribute26_o              in varchar2
 ,p_brc_attribute27_o              in varchar2
 ,p_brc_attribute28_o              in varchar2
 ,p_brc_attribute29_o              in varchar2
 ,p_brc_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_brc_rkd;

/
