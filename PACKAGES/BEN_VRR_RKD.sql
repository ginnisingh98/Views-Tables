--------------------------------------------------------
--  DDL for Package BEN_VRR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_VRR_RKD" AUTHID CURRENT_USER as
/* $Header: bevrrrhi.pkh 120.0.12010000.1 2008/07/29 13:08:42 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_vrbl_rt_rl_id                  in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_drvbl_fctr_apls_flag_o         in varchar2
 ,p_rt_trtmt_cd_o                  in varchar2
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_formula_id_o                   in number
 ,p_acty_base_rt_id_o              in number
 ,p_ordr_to_aply_num_o             in number
 ,p_vrr_attribute_category_o       in varchar2
 ,p_vrr_attribute1_o               in varchar2
 ,p_vrr_attribute2_o               in varchar2
 ,p_vrr_attribute3_o               in varchar2
 ,p_vrr_attribute4_o               in varchar2
 ,p_vrr_attribute5_o               in varchar2
 ,p_vrr_attribute6_o               in varchar2
 ,p_vrr_attribute7_o               in varchar2
 ,p_vrr_attribute8_o               in varchar2
 ,p_vrr_attribute9_o               in varchar2
 ,p_vrr_attribute10_o              in varchar2
 ,p_vrr_attribute11_o              in varchar2
 ,p_vrr_attribute12_o              in varchar2
 ,p_vrr_attribute13_o              in varchar2
 ,p_vrr_attribute14_o              in varchar2
 ,p_vrr_attribute15_o              in varchar2
 ,p_vrr_attribute16_o              in varchar2
 ,p_vrr_attribute17_o              in varchar2
 ,p_vrr_attribute18_o              in varchar2
 ,p_vrr_attribute19_o              in varchar2
 ,p_vrr_attribute20_o              in varchar2
 ,p_vrr_attribute21_o              in varchar2
 ,p_vrr_attribute22_o              in varchar2
 ,p_vrr_attribute23_o              in varchar2
 ,p_vrr_attribute24_o              in varchar2
 ,p_vrr_attribute25_o              in varchar2
 ,p_vrr_attribute26_o              in varchar2
 ,p_vrr_attribute27_o              in varchar2
 ,p_vrr_attribute28_o              in varchar2
 ,p_vrr_attribute29_o              in varchar2
 ,p_vrr_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_vrr_rkd;

/
