--------------------------------------------------------
--  DDL for Package BEN_BRC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BRC_RKU" AUTHID CURRENT_USER as
/* $Header: bebrcrhi.pkh 120.0.12010000.1 2008/07/29 10:59:53 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_bnft_rstrn_ctfn_id             in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_rqd_flag                       in varchar2
 ,p_enrt_ctfn_typ_cd               in varchar2
 ,p_ctfn_rqd_when_rl               in number
 ,p_pl_id                          in number
 ,p_business_group_id              in number
 ,p_brc_attribute_category         in varchar2
 ,p_brc_attribute1                 in varchar2
 ,p_brc_attribute2                 in varchar2
 ,p_brc_attribute3                 in varchar2
 ,p_brc_attribute4                 in varchar2
 ,p_brc_attribute5                 in varchar2
 ,p_brc_attribute6                 in varchar2
 ,p_brc_attribute7                 in varchar2
 ,p_brc_attribute8                 in varchar2
 ,p_brc_attribute9                 in varchar2
 ,p_brc_attribute10                in varchar2
 ,p_brc_attribute11                in varchar2
 ,p_brc_attribute12                in varchar2
 ,p_brc_attribute13                in varchar2
 ,p_brc_attribute14                in varchar2
 ,p_brc_attribute15                in varchar2
 ,p_brc_attribute16                in varchar2
 ,p_brc_attribute17                in varchar2
 ,p_brc_attribute18                in varchar2
 ,p_brc_attribute19                in varchar2
 ,p_brc_attribute20                in varchar2
 ,p_brc_attribute21                in varchar2
 ,p_brc_attribute22                in varchar2
 ,p_brc_attribute23                in varchar2
 ,p_brc_attribute24                in varchar2
 ,p_brc_attribute25                in varchar2
 ,p_brc_attribute26                in varchar2
 ,p_brc_attribute27                in varchar2
 ,p_brc_attribute28                in varchar2
 ,p_brc_attribute29                in varchar2
 ,p_brc_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
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
end ben_brc_rku;

/
