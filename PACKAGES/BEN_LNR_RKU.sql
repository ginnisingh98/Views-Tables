--------------------------------------------------------
--  DDL for Package BEN_LNR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LNR_RKU" AUTHID CURRENT_USER as
/* $Header: belnrrhi.pkh 120.0 2005/05/28 03:26:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_ler_chg_pl_nip_rl_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_formula_id            in number
 ,p_ordr_to_aply_num               in number
 ,p_ler_chg_pl_nip_enrt_id         in number
 ,p_lnr_attribute_category         in varchar2
 ,p_lnr_attribute1                 in varchar2
 ,p_lnr_attribute2                 in varchar2
 ,p_lnr_attribute3                 in varchar2
 ,p_lnr_attribute4                 in varchar2
 ,p_lnr_attribute5                 in varchar2
 ,p_lnr_attribute6                 in varchar2
 ,p_lnr_attribute7                 in varchar2
 ,p_lnr_attribute8                 in varchar2
 ,p_lnr_attribute9                 in varchar2
 ,p_lnr_attribute10                in varchar2
 ,p_lnr_attribute11                in varchar2
 ,p_lnr_attribute12                in varchar2
 ,p_lnr_attribute13                in varchar2
 ,p_lnr_attribute14                in varchar2
 ,p_lnr_attribute15                in varchar2
 ,p_lnr_attribute16                in varchar2
 ,p_lnr_attribute17                in varchar2
 ,p_lnr_attribute18                in varchar2
 ,p_lnr_attribute19                in varchar2
 ,p_lnr_attribute20                in varchar2
 ,p_lnr_attribute21                in varchar2
 ,p_lnr_attribute22                in varchar2
 ,p_lnr_attribute23                in varchar2
 ,p_lnr_attribute24                in varchar2
 ,p_lnr_attribute25                in varchar2
 ,p_lnr_attribute26                in varchar2
 ,p_lnr_attribute27                in varchar2
 ,p_lnr_attribute28                in varchar2
 ,p_lnr_attribute29                in varchar2
 ,p_lnr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_formula_id_o          in number
 ,p_ordr_to_aply_num_o             in number
 ,p_ler_chg_pl_nip_enrt_id_o       in number
 ,p_lnr_attribute_category_o       in varchar2
 ,p_lnr_attribute1_o               in varchar2
 ,p_lnr_attribute2_o               in varchar2
 ,p_lnr_attribute3_o               in varchar2
 ,p_lnr_attribute4_o               in varchar2
 ,p_lnr_attribute5_o               in varchar2
 ,p_lnr_attribute6_o               in varchar2
 ,p_lnr_attribute7_o               in varchar2
 ,p_lnr_attribute8_o               in varchar2
 ,p_lnr_attribute9_o               in varchar2
 ,p_lnr_attribute10_o              in varchar2
 ,p_lnr_attribute11_o              in varchar2
 ,p_lnr_attribute12_o              in varchar2
 ,p_lnr_attribute13_o              in varchar2
 ,p_lnr_attribute14_o              in varchar2
 ,p_lnr_attribute15_o              in varchar2
 ,p_lnr_attribute16_o              in varchar2
 ,p_lnr_attribute17_o              in varchar2
 ,p_lnr_attribute18_o              in varchar2
 ,p_lnr_attribute19_o              in varchar2
 ,p_lnr_attribute20_o              in varchar2
 ,p_lnr_attribute21_o              in varchar2
 ,p_lnr_attribute22_o              in varchar2
 ,p_lnr_attribute23_o              in varchar2
 ,p_lnr_attribute24_o              in varchar2
 ,p_lnr_attribute25_o              in varchar2
 ,p_lnr_attribute26_o              in varchar2
 ,p_lnr_attribute27_o              in varchar2
 ,p_lnr_attribute28_o              in varchar2
 ,p_lnr_attribute29_o              in varchar2
 ,p_lnr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_lnr_rku;

 

/
