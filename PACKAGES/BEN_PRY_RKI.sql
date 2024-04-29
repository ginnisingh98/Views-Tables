--------------------------------------------------------
--  DDL for Package BEN_PRY_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRY_RKI" AUTHID CURRENT_USER as
/* $Header: bepryrhi.pkh 120.1.12010000.1 2008/07/29 12:56:29 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_prtt_rmt_aprvd_fr_pymt_id    in number
  ,p_prtt_reimbmt_rqst_id         in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_apprvd_fr_pymt_num           in number
  ,p_adjmt_flag                   in varchar2
  ,p_aprvd_fr_pymt_amt            in number
  ,p_pymt_stat_cd                 in varchar2
  ,p_pymt_stat_rsn_cd             in varchar2
  ,p_pymt_stat_ovrdn_rsn_cd       in varchar2
  ,p_pymt_stat_prr_to_ovrd_cd     in varchar2
  ,p_business_group_id            in number
  ,p_element_entry_value_id       in number
  ,p_pry_attribute_category       in varchar2
  ,p_pry_attribute1               in varchar2
  ,p_pry_attribute2               in varchar2
  ,p_pry_attribute3               in varchar2
  ,p_pry_attribute4               in varchar2
  ,p_pry_attribute5               in varchar2
  ,p_pry_attribute6               in varchar2
  ,p_pry_attribute7               in varchar2
  ,p_pry_attribute8               in varchar2
  ,p_pry_attribute9               in varchar2
  ,p_pry_attribute10              in varchar2
  ,p_pry_attribute11              in varchar2
  ,p_pry_attribute12              in varchar2
  ,p_pry_attribute13              in varchar2
  ,p_pry_attribute14              in varchar2
  ,p_pry_attribute15              in varchar2
  ,p_pry_attribute16              in varchar2
  ,p_pry_attribute17              in varchar2
  ,p_pry_attribute18              in varchar2
  ,p_pry_attribute19              in varchar2
  ,p_pry_attribute20              in varchar2
  ,p_pry_attribute21              in varchar2
  ,p_pry_attribute22              in varchar2
  ,p_pry_attribute23              in varchar2
  ,p_pry_attribute24              in varchar2
  ,p_pry_attribute25              in varchar2
  ,p_pry_attribute26              in varchar2
  ,p_pry_attribute27              in varchar2
  ,p_pry_attribute28              in varchar2
  ,p_pry_attribute29              in varchar2
  ,p_pry_attribute30              in varchar2
  ,p_object_version_number        in number
  );
end ben_pry_rki;

/
