--------------------------------------------------------
--  DDL for Package BEN_QIG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_QIG_RKD" AUTHID CURRENT_USER as
/* $Header: beqigrhi.pkh 120.0.12010000.1 2008/07/29 12:59:43 appldev ship $ */
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
  ,p_qua_in_gr_rt_id                    in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_quar_in_grade_cd_o           in varchar2
  ,p_excld_flag_o                 in varchar2
  ,p_business_group_id_o          in number
  ,p_vrbl_rt_prfl_id_o            in number
  ,p_object_version_number_o      in number
  ,p_ordr_num_o                   in number
  ,p_qig_attribute_category_o     in varchar2
  ,p_qig_attribute1_o             in varchar2
  ,p_qig_attribute2_o             in varchar2
  ,p_qig_attribute3_o             in varchar2
  ,p_qig_attribute4_o             in varchar2
  ,p_qig_attribute5_o             in varchar2
  ,p_qig_attribute6_o             in varchar2
  ,p_qig_attribute7_o             in varchar2
  ,p_qig_attribute8_o             in varchar2
  ,p_qig_attribute9_o             in varchar2
  ,p_qig_attribute10_o            in varchar2
  ,p_qig_attribute11_o            in varchar2
  ,p_qig_attribute12_o            in varchar2
  ,p_qig_attribute13_o            in varchar2
  ,p_qig_attribute14_o            in varchar2
  ,p_qig_attribute15_o            in varchar2
  ,p_qig_attribute16_o            in varchar2
  ,p_qig_attribute17_o            in varchar2
  ,p_qig_attribute18_o            in varchar2
  ,p_qig_attribute19_o            in varchar2
  ,p_qig_attribute20_o            in varchar2
  ,p_qig_attribute21_o            in varchar2
  ,p_qig_attribute22_o            in varchar2
  ,p_qig_attribute23_o            in varchar2
  ,p_qig_attribute24_o            in varchar2
  ,p_qig_attribute25_o            in varchar2
  ,p_qig_attribute26_o            in varchar2
  ,p_qig_attribute27_o            in varchar2
  ,p_qig_attribute28_o            in varchar2
  ,p_qig_attribute29_o            in varchar2
  ,p_qig_attribute30_o            in varchar2
  );
--
end ben_qig_rkd;

/
