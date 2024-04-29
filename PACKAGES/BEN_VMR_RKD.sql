--------------------------------------------------------
--  DDL for Package BEN_VMR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VMR_RKD" AUTHID CURRENT_USER as
/* $Header: bevmrrhi.pkh 120.0.12010000.1 2008/07/29 13:07:26 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_vrbl_mtchg_rt_id               in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_end_date_o           in date
 ,p_effective_start_date_o         in date
 ,p_no_mx_pct_of_py_num_flag_o     in varchar2
 ,p_to_pct_val_o                   in number
 ,p_no_mx_amt_of_py_num_flag_o     in varchar2
 ,p_mx_pct_of_py_num_o             in number
 ,p_no_mx_mtch_amt_flag_o          in varchar2
 ,p_ordr_num_o                     in number
 ,p_pct_val_o                      in number
 ,p_mx_mtch_amt_o                  in number
 ,p_mx_amt_of_py_num_o             in number
 ,p_mn_mtch_amt_o                  in number
 ,p_mtchg_rt_calc_rl_o             in number
 ,p_cntnu_mtch_aftr_max_rl_fla_o  in varchar2
 ,p_from_pct_val_o                 in number
 ,p_vrbl_rt_prfl_id_o              in number
 ,p_business_group_id_o            in number
 ,p_vmr_attribute_category_o       in varchar2
 ,p_vmr_attribute1_o               in varchar2
 ,p_vmr_attribute2_o               in varchar2
 ,p_vmr_attribute3_o               in varchar2
 ,p_vmr_attribute4_o               in varchar2
 ,p_vmr_attribute5_o               in varchar2
 ,p_vmr_attribute6_o               in varchar2
 ,p_vmr_attribute7_o               in varchar2
 ,p_vmr_attribute8_o               in varchar2
 ,p_vmr_attribute9_o               in varchar2
 ,p_vmr_attribute10_o              in varchar2
 ,p_vmr_attribute11_o              in varchar2
 ,p_vmr_attribute12_o              in varchar2
 ,p_vmr_attribute13_o              in varchar2
 ,p_vmr_attribute14_o              in varchar2
 ,p_vmr_attribute15_o              in varchar2
 ,p_vmr_attribute16_o              in varchar2
 ,p_vmr_attribute17_o              in varchar2
 ,p_vmr_attribute18_o              in varchar2
 ,p_vmr_attribute19_o              in varchar2
 ,p_vmr_attribute20_o              in varchar2
 ,p_vmr_attribute21_o              in varchar2
 ,p_vmr_attribute22_o              in varchar2
 ,p_vmr_attribute23_o              in varchar2
 ,p_vmr_attribute24_o              in varchar2
 ,p_vmr_attribute25_o              in varchar2
 ,p_vmr_attribute26_o              in varchar2
 ,p_vmr_attribute27_o              in varchar2
 ,p_vmr_attribute28_o              in varchar2
 ,p_vmr_attribute29_o              in varchar2
 ,p_vmr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_vmr_rkd;

/
