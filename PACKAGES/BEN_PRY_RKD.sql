--------------------------------------------------------
--  DDL for Package BEN_PRY_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRY_RKD" AUTHID CURRENT_USER as
/* $Header: bepryrhi.pkh 120.1.12010000.1 2008/07/29 12:56:29 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_prtt_rmt_aprvd_fr_pymt_id    in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_prtt_reimbmt_rqst_id_o       in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_apprvd_fr_pymt_num_o         in number
  ,p_adjmt_flag_o                 in varchar2
  ,p_aprvd_fr_pymt_amt_o          in number
  ,p_pymt_stat_cd_o               in varchar2
  ,p_pymt_stat_rsn_cd_o           in varchar2
  ,p_pymt_stat_ovrdn_rsn_cd_o     in varchar2
  ,p_pymt_stat_prr_to_ovrd_cd_o   in varchar2
  ,p_business_group_id_o          in number
  ,p_element_entry_value_id_o     in number
  ,p_pry_attribute_category_o     in varchar2
  ,p_pry_attribute1_o             in varchar2
  ,p_pry_attribute2_o             in varchar2
  ,p_pry_attribute3_o             in varchar2
  ,p_pry_attribute4_o             in varchar2
  ,p_pry_attribute5_o             in varchar2
  ,p_pry_attribute6_o             in varchar2
  ,p_pry_attribute7_o             in varchar2
  ,p_pry_attribute8_o             in varchar2
  ,p_pry_attribute9_o             in varchar2
  ,p_pry_attribute10_o            in varchar2
  ,p_pry_attribute11_o            in varchar2
  ,p_pry_attribute12_o            in varchar2
  ,p_pry_attribute13_o            in varchar2
  ,p_pry_attribute14_o            in varchar2
  ,p_pry_attribute15_o            in varchar2
  ,p_pry_attribute16_o            in varchar2
  ,p_pry_attribute17_o            in varchar2
  ,p_pry_attribute18_o            in varchar2
  ,p_pry_attribute19_o            in varchar2
  ,p_pry_attribute20_o            in varchar2
  ,p_pry_attribute21_o            in varchar2
  ,p_pry_attribute22_o            in varchar2
  ,p_pry_attribute23_o            in varchar2
  ,p_pry_attribute24_o            in varchar2
  ,p_pry_attribute25_o            in varchar2
  ,p_pry_attribute26_o            in varchar2
  ,p_pry_attribute27_o            in varchar2
  ,p_pry_attribute28_o            in varchar2
  ,p_pry_attribute29_o            in varchar2
  ,p_pry_attribute30_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end ben_pry_rkd;

/
