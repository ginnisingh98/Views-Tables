--------------------------------------------------------
--  DDL for Package BEN_MTR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MTR_RKD" AUTHID CURRENT_USER as
/* $Header: bemtrrhi.pkh 120.0 2005/05/28 03:40:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_mtchg_rt_id                    in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_acty_base_rt_id_o              in number
 ,p_comp_lvl_fctr_id_o             in number
 ,p_ordr_num_o                     in number
 ,p_from_pct_val_o                 in number
 ,p_to_pct_val_o                   in number
 ,p_pct_val_o                      in number
 ,p_mx_amt_of_py_num_o             in number
 ,p_mx_pct_of_py_num_o             in number
 ,p_mx_mtch_amt_o                  in number
 ,p_mn_mtch_amt_o                  in number
 ,p_mtchg_rt_calc_rl_o             in number
 ,p_no_mx_mtch_amt_flag_o          in varchar2
 ,p_no_mx_pct_of_py_num_flag_o     in varchar2
 ,p_cntnu_mtch_aftr_mx_rl_flag_o   in varchar2
 ,p_no_mx_amt_of_py_num_flag_o     in varchar2
 ,p_business_group_id_o            in number
 ,p_mtr_attribute_category_o       in varchar2
 ,p_mtr_attribute1_o               in varchar2
 ,p_mtr_attribute2_o               in varchar2
 ,p_mtr_attribute3_o               in varchar2
 ,p_mtr_attribute4_o               in varchar2
 ,p_mtr_attribute5_o               in varchar2
 ,p_mtr_attribute6_o               in varchar2
 ,p_mtr_attribute7_o               in varchar2
 ,p_mtr_attribute8_o               in varchar2
 ,p_mtr_attribute9_o               in varchar2
 ,p_mtr_attribute10_o              in varchar2
 ,p_mtr_attribute11_o              in varchar2
 ,p_mtr_attribute12_o              in varchar2
 ,p_mtr_attribute13_o              in varchar2
 ,p_mtr_attribute14_o              in varchar2
 ,p_mtr_attribute15_o              in varchar2
 ,p_mtr_attribute16_o              in varchar2
 ,p_mtr_attribute17_o              in varchar2
 ,p_mtr_attribute18_o              in varchar2
 ,p_mtr_attribute19_o              in varchar2
 ,p_mtr_attribute20_o              in varchar2
 ,p_mtr_attribute21_o              in varchar2
 ,p_mtr_attribute22_o              in varchar2
 ,p_mtr_attribute23_o              in varchar2
 ,p_mtr_attribute24_o              in varchar2
 ,p_mtr_attribute25_o              in varchar2
 ,p_mtr_attribute26_o              in varchar2
 ,p_mtr_attribute27_o              in varchar2
 ,p_mtr_attribute28_o              in varchar2
 ,p_mtr_attribute29_o              in varchar2
 ,p_mtr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_mtr_rkd;

 

/
