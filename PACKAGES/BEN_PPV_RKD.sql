--------------------------------------------------------
--  DDL for Package BEN_PPV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PPV_RKD" AUTHID CURRENT_USER as
/* $Header: beppvrhi.pkh 120.0.12010000.1 2008/07/29 12:52:49 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_prtl_mo_rt_prtn_val_id         in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_end_date_o           in date
 ,p_effective_start_date_o         in date
 ,p_business_group_id_o            in number
 ,p_rndg_cd_o                      in varchar2
 ,p_to_dy_mo_num_o                 in number
 ,p_from_dy_mo_num_o               in number
 ,p_pct_val_o                      in number
 ,p_acty_base_rt_id_o              in number
 ,p_strt_r_stp_cvg_cd_o            in varchar2
 ,p_rndg_rl_o                      in number
 ,p_prtl_mo_prortn_rl_o            in number
 ,p_actl_prem_id_o                 in number
 ,p_cvg_amt_calc_mthd_id_o         in number
 ,p_num_days_month_o               in number
 ,p_prorate_by_day_to_mon_flag_o   in varchar2
 ,p_pmrpv_attribute_category_o     in varchar2
 ,p_pmrpv_attribute1_o             in varchar2
 ,p_pmrpv_attribute2_o             in varchar2
 ,p_pmrpv_attribute3_o             in varchar2
 ,p_pmrpv_attribute4_o             in varchar2
 ,p_pmrpv_attribute5_o             in varchar2
 ,p_pmrpv_attribute6_o             in varchar2
 ,p_pmrpv_attribute7_o             in varchar2
 ,p_pmrpv_attribute8_o             in varchar2
 ,p_pmrpv_attribute9_o             in varchar2
 ,p_pmrpv_attribute10_o            in varchar2
 ,p_pmrpv_attribute11_o            in varchar2
 ,p_pmrpv_attribute12_o            in varchar2
 ,p_pmrpv_attribute13_o            in varchar2
 ,p_pmrpv_attribute14_o            in varchar2
 ,p_pmrpv_attribute15_o            in varchar2
 ,p_pmrpv_attribute16_o            in varchar2
 ,p_pmrpv_attribute17_o            in varchar2
 ,p_pmrpv_attribute18_o            in varchar2
 ,p_pmrpv_attribute19_o            in varchar2
 ,p_pmrpv_attribute20_o            in varchar2
 ,p_pmrpv_attribute21_o            in varchar2
 ,p_pmrpv_attribute22_o            in varchar2
 ,p_pmrpv_attribute23_o            in varchar2
 ,p_pmrpv_attribute24_o            in varchar2
 ,p_pmrpv_attribute25_o            in varchar2
 ,p_pmrpv_attribute26_o            in varchar2
 ,p_pmrpv_attribute27_o            in varchar2
 ,p_pmrpv_attribute28_o            in varchar2
 ,p_pmrpv_attribute29_o            in varchar2
 ,p_pmrpv_attribute30_o            in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_ppv_rkd;

/
