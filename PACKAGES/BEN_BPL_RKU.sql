--------------------------------------------------------
--  DDL for Package BEN_BPL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BPL_RKU" AUTHID CURRENT_USER as
/* $Header: bebplrhi.pkh 120.0.12010000.1 2008/07/29 10:58:50 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (
  p_bnft_prvdd_ldgr_id             in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_prtt_ro_of_unusd_amt_flag      in varchar2
 ,p_frftd_val                      in number
 ,p_prvdd_val                      in number
 ,p_used_val                       in number
 ,p_bnft_prvdr_pool_id             in number
 ,p_acty_base_rt_id                in number
 ,p_per_in_ler_id                in number
 ,p_prtt_enrt_rslt_id              in number
 ,p_business_group_id              in number
 ,p_bpl_attribute_category         in varchar2
 ,p_bpl_attribute1                 in varchar2
 ,p_bpl_attribute2                 in varchar2
 ,p_bpl_attribute3                 in varchar2
 ,p_bpl_attribute4                 in varchar2
 ,p_bpl_attribute5                 in varchar2
 ,p_bpl_attribute6                 in varchar2
 ,p_bpl_attribute7                 in varchar2
 ,p_bpl_attribute8                 in varchar2
 ,p_bpl_attribute9                 in varchar2
 ,p_bpl_attribute10                in varchar2
 ,p_bpl_attribute11                in varchar2
 ,p_bpl_attribute12                in varchar2
 ,p_bpl_attribute13                in varchar2
 ,p_bpl_attribute14                in varchar2
 ,p_bpl_attribute15                in varchar2
 ,p_bpl_attribute16                in varchar2
 ,p_bpl_attribute17                in varchar2
 ,p_bpl_attribute18                in varchar2
 ,p_bpl_attribute19                in varchar2
 ,p_bpl_attribute20                in varchar2
 ,p_bpl_attribute21                in varchar2
 ,p_bpl_attribute22                in varchar2
 ,p_bpl_attribute23                in varchar2
 ,p_bpl_attribute24                in varchar2
 ,p_bpl_attribute25                in varchar2
 ,p_bpl_attribute26                in varchar2
 ,p_bpl_attribute27                in varchar2
 ,p_bpl_attribute28                in varchar2
 ,p_bpl_attribute29                in varchar2
 ,p_bpl_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_cash_recd_val                  in number
 ,p_rld_up_val                     in number,
  p_acty_ref_perd_cd              in   varchar2,
  p_cmcd_frftd_val                in   number,
  p_cmcd_prvdd_val                in   number,
  p_cmcd_rld_up_val               in   number,
  p_cmcd_used_val                 in   number,
  p_cmcd_cash_recd_val            in   number,
  p_cmcd_ref_perd_cd              in   varchar2,
  p_ann_frftd_val                 in   number,
  p_ann_prvdd_val                 in   number,
  p_ann_rld_up_val                in   number,
  p_ann_used_val                  in   number,
  p_ann_cash_recd_val             in   number
 ,p_effective_date                 in date
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_prtt_ro_of_unusd_amt_flag_o    in varchar2
 ,p_frftd_val_o                    in number
 ,p_prvdd_val_o                    in number
 ,p_used_val_o                     in number
 ,p_bnft_prvdr_pool_id_o           in number
 ,p_acty_base_rt_id_o              in number
 ,p_per_in_ler_id_o              in number
 ,p_prtt_enrt_rslt_id_o            in number
 ,p_business_group_id_o            in number
 ,p_bpl_attribute_category_o       in varchar2
 ,p_bpl_attribute1_o               in varchar2
 ,p_bpl_attribute2_o               in varchar2
 ,p_bpl_attribute3_o               in varchar2
 ,p_bpl_attribute4_o               in varchar2
 ,p_bpl_attribute5_o               in varchar2
 ,p_bpl_attribute6_o               in varchar2
 ,p_bpl_attribute7_o               in varchar2
 ,p_bpl_attribute8_o               in varchar2
 ,p_bpl_attribute9_o               in varchar2
 ,p_bpl_attribute10_o              in varchar2
 ,p_bpl_attribute11_o              in varchar2
 ,p_bpl_attribute12_o              in varchar2
 ,p_bpl_attribute13_o              in varchar2
 ,p_bpl_attribute14_o              in varchar2
 ,p_bpl_attribute15_o              in varchar2
 ,p_bpl_attribute16_o              in varchar2
 ,p_bpl_attribute17_o              in varchar2
 ,p_bpl_attribute18_o              in varchar2
 ,p_bpl_attribute19_o              in varchar2
 ,p_bpl_attribute20_o              in varchar2
 ,p_bpl_attribute21_o              in varchar2
 ,p_bpl_attribute22_o              in varchar2
 ,p_bpl_attribute23_o              in varchar2
 ,p_bpl_attribute24_o              in varchar2
 ,p_bpl_attribute25_o              in varchar2
 ,p_bpl_attribute26_o              in varchar2
 ,p_bpl_attribute27_o              in varchar2
 ,p_bpl_attribute28_o              in varchar2
 ,p_bpl_attribute29_o              in varchar2
 ,p_bpl_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
 ,p_cash_recd_val_o                in number
 ,p_rld_up_val_o                    in number,
  p_acty_ref_perd_cd_o              in   varchar2,
  p_cmcd_frftd_val_o                in   number,
  p_cmcd_prvdd_val_o                in   number,
  p_cmcd_rld_up_val_o               in   number,
  p_cmcd_used_val_o                 in   number,
  p_cmcd_cash_recd_val_o            in   number,
  p_cmcd_ref_perd_cd_o              in   varchar2,
  p_ann_frftd_val_o                 in   number,
  p_ann_prvdd_val_o                 in   number,
  p_ann_rld_up_val_o                in   number,
  p_ann_used_val_o                  in   number,
  p_ann_cash_recd_val_o             in   number
  );
--
end ben_bpl_rku;

/
