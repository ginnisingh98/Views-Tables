--------------------------------------------------------
--  DDL for Package BEN_ETP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ETP_RKD" AUTHID CURRENT_USER as
/* $Header: beetprhi.pkh 120.0 2005/05/28 03:02:36 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_ELIG_TTL_PRTT_PRTE_id          in number
 ,p_datetrack_mode                 in varchar2
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_effective_start_date_o         in date
 ,p_effective_end_date_o           in date
 ,p_business_group_id_o            in number
 ,p_excld_flag_o                   in varchar2
 ,p_no_mn_prtt_num_apls_flag_o     in varchar2
 ,p_no_mx_prtt_num_apls_flag_o     in varchar2
 ,p_ordr_num_o                     in number
 ,p_mn_prtt_num_o                  in number
 ,p_mx_prtt_num_o                  in number
 ,p_prtt_det_cd_o                  in varchar2
 ,p_prtt_det_rl_o                  in number
 ,p_eligy_prfl_id_o                in number
 ,p_etp_attribute_category_o       in varchar2
 ,p_etp_attribute1_o               in varchar2
 ,p_etp_attribute2_o               in varchar2
 ,p_etp_attribute3_o               in varchar2
 ,p_etp_attribute4_o               in varchar2
 ,p_etp_attribute5_o               in varchar2
 ,p_etp_attribute6_o               in varchar2
 ,p_etp_attribute7_o               in varchar2
 ,p_etp_attribute8_o               in varchar2
 ,p_etp_attribute9_o               in varchar2
 ,p_etp_attribute10_o              in varchar2
 ,p_etp_attribute11_o              in varchar2
 ,p_etp_attribute12_o              in varchar2
 ,p_etp_attribute13_o              in varchar2
 ,p_etp_attribute14_o              in varchar2
 ,p_etp_attribute15_o              in varchar2
 ,p_etp_attribute16_o              in varchar2
 ,p_etp_attribute17_o              in varchar2
 ,p_etp_attribute18_o              in varchar2
 ,p_etp_attribute19_o              in varchar2
 ,p_etp_attribute20_o              in varchar2
 ,p_etp_attribute21_o              in varchar2
 ,p_etp_attribute22_o              in varchar2
 ,p_etp_attribute23_o              in varchar2
 ,p_etp_attribute24_o              in varchar2
 ,p_etp_attribute25_o              in varchar2
 ,p_etp_attribute26_o              in varchar2
 ,p_etp_attribute27_o              in varchar2
 ,p_etp_attribute28_o              in varchar2
 ,p_etp_attribute29_o              in varchar2
 ,p_etp_attribute30_o              in varchar2
 ,p_object_version_number_o        in number
  );
--
end ben_etp_rkd;

 

/
