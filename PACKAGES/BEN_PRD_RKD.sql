--------------------------------------------------------
--  DDL for Package BEN_PRD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRD_RKD" AUTHID CURRENT_USER as
/* $Header: beprdrhi.pkh 120.0.12010000.1 2008/07/29 12:53:58 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_paird_rt_id                    in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_use_parnt_ded_sched_flag_o     in varchar2
 ,p_asn_on_chc_of_parnt_flag_o     in varchar2
 ,p_use_parnt_prtl_mo_cd_flag_o    in varchar2
 ,p_alloc_sme_as_parnt_flag_o      in varchar2
 ,p_use_parnt_pymt_sched_flag_o    in varchar2
 ,p_no_cmbnd_mx_amt_dfnd_flag_o    in varchar2
 ,p_cmbnd_mx_amt_o                 in number
 ,p_cmbnd_mn_amt_o                 in number
 ,p_cmbnd_mx_pct_num_o             in number
 ,p_cmbnd_mn_pct_num_o             in number
 ,p_no_cmbnd_mn_amt_dfnd_flag_o    in varchar2
 ,p_no_cmbnd_mn_pct_dfnd_flag_o    in varchar2
 ,p_no_cmbnd_mx_pct_dfnd_flag_o    in varchar2
 ,p_parnt_acty_base_rt_id_o        in number
 ,p_chld_acty_base_rt_id_o         in number
 ,p_business_group_id_o            in number
 ,p_prd_attribute_category_o       in varchar2
 ,p_prd_attribute1_o               in varchar2
 ,p_prd_attribute2_o               in varchar2
 ,p_prd_attribute3_o               in varchar2
 ,p_prd_attribute4_o               in varchar2
 ,p_prd_attribute5_o               in varchar2
 ,p_prd_attribute6_o               in varchar2
 ,p_prd_attribute7_o               in varchar2
 ,p_prd_attribute8_o               in varchar2
 ,p_prd_attribute9_o               in varchar2
 ,p_prd_attribute10_o              in varchar2
 ,p_prd_attribute11_o              in varchar2
 ,p_prd_attribute12_o              in varchar2
 ,p_prd_attribute13_o              in varchar2
 ,p_prd_attribute14_o              in varchar2
 ,p_prd_attribute15_o              in varchar2
 ,p_prd_attribute16_o              in varchar2
 ,p_prd_attribute17_o              in varchar2
 ,p_prd_attribute18_o              in varchar2
 ,p_prd_attribute19_o              in varchar2
 ,p_prd_attribute20_o              in varchar2
 ,p_prd_attribute21_o              in varchar2
 ,p_prd_attribute22_o              in varchar2
 ,p_prd_attribute23_o              in varchar2
 ,p_prd_attribute24_o              in varchar2
 ,p_prd_attribute25_o              in varchar2
 ,p_prd_attribute26_o              in varchar2
 ,p_prd_attribute27_o              in varchar2
 ,p_prd_attribute28_o              in varchar2
 ,p_prd_attribute29_o              in varchar2
 ,p_prd_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_prd_rkd;

/
