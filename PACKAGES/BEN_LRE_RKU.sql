--------------------------------------------------------
--  DDL for Package BEN_LRE_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LRE_RKU" AUTHID CURRENT_USER as
/* $Header: belrerhi.pkh 120.0.12010000.1 2008/07/29 12:00:38 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ler_rqrs_enrt_ctfn_id          in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_excld_flag                     in varchar2
 ,p_ctfn_rqd_when_rl               in number
 ,p_ler_id                         in number
 ,p_pl_id                          in number
 ,p_oipl_id                        in number
 ,p_business_group_id              in number
 ,p_lre_attribute_category         in varchar2
 ,p_lre_attribute1                 in varchar2
 ,p_lre_attribute2                 in varchar2
 ,p_lre_attribute3                 in varchar2
 ,p_lre_attribute4                 in varchar2
 ,p_lre_attribute5                 in varchar2
 ,p_lre_attribute6                 in varchar2
 ,p_lre_attribute7                 in varchar2
 ,p_lre_attribute8                 in varchar2
 ,p_lre_attribute9                 in varchar2
 ,p_lre_attribute10                in varchar2
 ,p_lre_attribute11                in varchar2
 ,p_lre_attribute12                in varchar2
 ,p_lre_attribute13                in varchar2
 ,p_lre_attribute14                in varchar2
 ,p_lre_attribute15                in varchar2
 ,p_lre_attribute16                in varchar2
 ,p_lre_attribute17                in varchar2
 ,p_lre_attribute18                in varchar2
 ,p_lre_attribute19                in varchar2
 ,p_lre_attribute20                in varchar2
 ,p_lre_attribute21                in varchar2
 ,p_lre_attribute22                in varchar2
 ,p_lre_attribute23                in varchar2
 ,p_lre_attribute24                in varchar2
 ,p_lre_attribute25                in varchar2
 ,p_lre_attribute26                in varchar2
 ,p_lre_attribute27                in varchar2
 ,p_lre_attribute28                in varchar2
 ,p_lre_attribute29                in varchar2
 ,p_lre_attribute30                in varchar2
 ,p_susp_if_ctfn_not_prvd_flag    in varchar2
 ,p_ctfn_determine_cd              in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_excld_flag_o                   in varchar2
 ,p_ctfn_rqd_when_rl_o             in number
 ,p_ler_id_o                       in number
 ,p_pl_id_o                        in number
 ,p_oipl_id_o                      in number
 ,p_business_group_id_o            in number
 ,p_lre_attribute_category_o       in varchar2
 ,p_lre_attribute1_o               in varchar2
 ,p_lre_attribute2_o               in varchar2
 ,p_lre_attribute3_o               in varchar2
 ,p_lre_attribute4_o               in varchar2
 ,p_lre_attribute5_o               in varchar2
 ,p_lre_attribute6_o               in varchar2
 ,p_lre_attribute7_o               in varchar2
 ,p_lre_attribute8_o               in varchar2
 ,p_lre_attribute9_o               in varchar2
 ,p_lre_attribute10_o              in varchar2
 ,p_lre_attribute11_o              in varchar2
 ,p_lre_attribute12_o              in varchar2
 ,p_lre_attribute13_o              in varchar2
 ,p_lre_attribute14_o              in varchar2
 ,p_lre_attribute15_o              in varchar2
 ,p_lre_attribute16_o              in varchar2
 ,p_lre_attribute17_o              in varchar2
 ,p_lre_attribute18_o              in varchar2
 ,p_lre_attribute19_o              in varchar2
 ,p_lre_attribute20_o              in varchar2
 ,p_lre_attribute21_o              in varchar2
 ,p_lre_attribute22_o              in varchar2
 ,p_lre_attribute23_o              in varchar2
 ,p_lre_attribute24_o              in varchar2
 ,p_lre_attribute25_o              in varchar2
 ,p_lre_attribute26_o              in varchar2
 ,p_lre_attribute27_o              in varchar2
 ,p_lre_attribute28_o              in varchar2
 ,p_lre_attribute29_o              in varchar2
 ,p_lre_attribute30_o              in varchar2
 ,p_susp_if_ctfn_not_prvd_flag_o  in varchar2
 ,p_ctfn_determine_cd_o            in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lre_rku;

/
