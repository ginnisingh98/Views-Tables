--------------------------------------------------------
--  DDL for Package BEN_PRTL_MO_RT_PRTN_VAL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTL_MO_RT_PRTN_VAL_BK2" AUTHID CURRENT_USER as
/* $Header: beppvapi.pkh 120.0 2005/05/28 11:01:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Prtl_Mo_Rt_Prtn_Val_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Prtl_Mo_Rt_Prtn_Val_b
  (
   p_prtl_mo_rt_prtn_val_id         in  number
  ,p_acty_base_rt_id                in  number
  ,p_rndg_rl                        in  number
  ,p_rndg_cd                        in  varchar2
  ,p_to_dy_mo_num                   in  number
  ,p_from_dy_mo_num                 in  number
  ,p_pct_val                        in  number
  ,p_strt_r_stp_cvg_cd              in  varchar2
  ,p_prtl_mo_prortn_rl              in  number
  ,p_actl_prem_id                   in  number
  ,p_cvg_amt_calc_mthd_id           in  number
  ,p_num_days_month                 in  number
  ,p_prorate_by_day_to_mon_flag     in  varchar2
  ,p_business_group_id              in  number
  ,p_pmrpv_attribute_category       in  varchar2
  ,p_pmrpv_attribute1               in  varchar2
  ,p_pmrpv_attribute2               in  varchar2
  ,p_pmrpv_attribute3               in  varchar2
  ,p_pmrpv_attribute4               in  varchar2
  ,p_pmrpv_attribute5               in  varchar2
  ,p_pmrpv_attribute6               in  varchar2
  ,p_pmrpv_attribute7               in  varchar2
  ,p_pmrpv_attribute8               in  varchar2
  ,p_pmrpv_attribute9               in  varchar2
  ,p_pmrpv_attribute10              in  varchar2
  ,p_pmrpv_attribute11              in  varchar2
  ,p_pmrpv_attribute12              in  varchar2
  ,p_pmrpv_attribute13              in  varchar2
  ,p_pmrpv_attribute14              in  varchar2
  ,p_pmrpv_attribute15              in  varchar2
  ,p_pmrpv_attribute16              in  varchar2
  ,p_pmrpv_attribute17              in  varchar2
  ,p_pmrpv_attribute18              in  varchar2
  ,p_pmrpv_attribute19              in  varchar2
  ,p_pmrpv_attribute20              in  varchar2
  ,p_pmrpv_attribute21              in  varchar2
  ,p_pmrpv_attribute22              in  varchar2
  ,p_pmrpv_attribute23              in  varchar2
  ,p_pmrpv_attribute24              in  varchar2
  ,p_pmrpv_attribute25              in  varchar2
  ,p_pmrpv_attribute26              in  varchar2
  ,p_pmrpv_attribute27              in  varchar2
  ,p_pmrpv_attribute28              in  varchar2
  ,p_pmrpv_attribute29              in  varchar2
  ,p_pmrpv_attribute30              in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_Prtl_Mo_Rt_Prtn_Val_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_Prtl_Mo_Rt_Prtn_Val_a
  (
   p_prtl_mo_rt_prtn_val_id         in  number
  ,p_effective_end_date             in  date
  ,p_effective_start_date           in  date
  ,p_acty_base_rt_id                in  number
  ,p_rndg_rl                        in  number
  ,p_rndg_cd                        in  varchar2
  ,p_to_dy_mo_num                   in  number
  ,p_from_dy_mo_num                 in  number
  ,p_pct_val                        in  number
  ,p_strt_r_stp_cvg_cd              in  varchar2
  ,p_prtl_mo_prortn_rl              in  number
  ,p_actl_prem_id                   in  number
  ,p_cvg_amt_calc_mthd_id           in  number
  ,p_num_days_month                 in  number
  ,p_prorate_by_day_to_mon_flag     in  varchar2
  ,p_business_group_id              in  number
  ,p_pmrpv_attribute_category       in  varchar2
  ,p_pmrpv_attribute1               in  varchar2
  ,p_pmrpv_attribute2               in  varchar2
  ,p_pmrpv_attribute3               in  varchar2
  ,p_pmrpv_attribute4               in  varchar2
  ,p_pmrpv_attribute5               in  varchar2
  ,p_pmrpv_attribute6               in  varchar2
  ,p_pmrpv_attribute7               in  varchar2
  ,p_pmrpv_attribute8               in  varchar2
  ,p_pmrpv_attribute9               in  varchar2
  ,p_pmrpv_attribute10              in  varchar2
  ,p_pmrpv_attribute11              in  varchar2
  ,p_pmrpv_attribute12              in  varchar2
  ,p_pmrpv_attribute13              in  varchar2
  ,p_pmrpv_attribute14              in  varchar2
  ,p_pmrpv_attribute15              in  varchar2
  ,p_pmrpv_attribute16              in  varchar2
  ,p_pmrpv_attribute17              in  varchar2
  ,p_pmrpv_attribute18              in  varchar2
  ,p_pmrpv_attribute19              in  varchar2
  ,p_pmrpv_attribute20              in  varchar2
  ,p_pmrpv_attribute21              in  varchar2
  ,p_pmrpv_attribute22              in  varchar2
  ,p_pmrpv_attribute23              in  varchar2
  ,p_pmrpv_attribute24              in  varchar2
  ,p_pmrpv_attribute25              in  varchar2
  ,p_pmrpv_attribute26              in  varchar2
  ,p_pmrpv_attribute27              in  varchar2
  ,p_pmrpv_attribute28              in  varchar2
  ,p_pmrpv_attribute29              in  varchar2
  ,p_pmrpv_attribute30              in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end ben_Prtl_Mo_Rt_Prtn_Val_bk2;

 

/
