--------------------------------------------------------
--  DDL for Package BEN_ERP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ERP_RKD" AUTHID CURRENT_USER as
/* $Header: beerprhi.pkh 120.0 2005/05/28 02:53:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_enrt_perd_for_pl_id            in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_enrt_cvg_strt_dt_cd_o          in varchar2
 ,p_enrt_cvg_strt_dt_rl_o          in number
 ,p_enrt_cvg_end_dt_cd_o           in varchar2
 ,p_enrt_cvg_end_dt_rl_o           in number
 ,p_rt_strt_dt_cd_o                in varchar2
 ,p_rt_strt_dt_rl_o                in number
 ,p_rt_end_dt_cd_o                 in varchar2
 ,p_rt_end_dt_rl_o                 in number
 ,p_enrt_perd_id_o                 in number
 ,p_pl_id_o                        in number
 ,p_lee_rsn_id_o                   in number
 ,p_business_group_id_o            in number
 ,p_erp_attribute_category_o       in varchar2
 ,p_erp_attribute1_o               in varchar2
 ,p_erp_attribute2_o               in varchar2
 ,p_erp_attribute3_o               in varchar2
 ,p_erp_attribute4_o               in varchar2
 ,p_erp_attribute5_o               in varchar2
 ,p_erp_attribute6_o               in varchar2
 ,p_erp_attribute7_o               in varchar2
 ,p_erp_attribute8_o               in varchar2
 ,p_erp_attribute9_o               in varchar2
 ,p_erp_attribute10_o              in varchar2
 ,p_erp_attribute11_o              in varchar2
 ,p_erp_attribute12_o              in varchar2
 ,p_erp_attribute13_o              in varchar2
 ,p_erp_attribute14_o              in varchar2
 ,p_erp_attribute15_o              in varchar2
 ,p_erp_attribute16_o              in varchar2
 ,p_erp_attribute17_o              in varchar2
 ,p_erp_attribute18_o              in varchar2
 ,p_erp_attribute19_o              in varchar2
 ,p_erp_attribute20_o              in varchar2
 ,p_erp_attribute21_o              in varchar2
 ,p_erp_attribute22_o              in varchar2
 ,p_erp_attribute23_o              in varchar2
 ,p_erp_attribute24_o              in varchar2
 ,p_erp_attribute25_o              in varchar2
 ,p_erp_attribute26_o              in varchar2
 ,p_erp_attribute27_o              in varchar2
 ,p_erp_attribute28_o              in varchar2
 ,p_erp_attribute29_o              in varchar2
 ,p_erp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_erp_rkd;

 

/
