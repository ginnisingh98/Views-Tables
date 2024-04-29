--------------------------------------------------------
--  DDL for Package BEN_PRTT_RMT_APRVD_PYMT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRTT_RMT_APRVD_PYMT_BK1" AUTHID CURRENT_USER as
/* $Header: bepryapi.pkh 120.1 2005/12/19 12:19:35 kmahendr noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_prtt_rmt_aprvd_pymt_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_prtt_rmt_aprvd_pymt_b
  (
   p_prtt_reimbmt_rqst_id           in  number
  ,p_apprvd_fr_pymt_num             in  number
  ,p_adjmt_flag                     in  varchar2
  ,p_aprvd_fr_pymt_amt              in  number
  ,p_pymt_stat_cd                   in  varchar2
  ,p_pymt_stat_rsn_cd               in  varchar2
  ,p_pymt_stat_ovrdn_rsn_cd         in  varchar2
  ,p_pymt_stat_prr_to_ovrd_cd       in  varchar2
  ,p_business_group_id              in  number
  ,p_element_entry_value_id         in  number
  ,p_pry_attribute_category         in  varchar2
  ,p_pry_attribute1                 in  varchar2
  ,p_pry_attribute2                 in  varchar2
  ,p_pry_attribute3                 in  varchar2
  ,p_pry_attribute4                 in  varchar2
  ,p_pry_attribute5                 in  varchar2
  ,p_pry_attribute6                 in  varchar2
  ,p_pry_attribute7                 in  varchar2
  ,p_pry_attribute8                 in  varchar2
  ,p_pry_attribute9                 in  varchar2
  ,p_pry_attribute10                in  varchar2
  ,p_pry_attribute11                in  varchar2
  ,p_pry_attribute12                in  varchar2
  ,p_pry_attribute13                in  varchar2
  ,p_pry_attribute14                in  varchar2
  ,p_pry_attribute15                in  varchar2
  ,p_pry_attribute16                in  varchar2
  ,p_pry_attribute17                in  varchar2
  ,p_pry_attribute18                in  varchar2
  ,p_pry_attribute19                in  varchar2
  ,p_pry_attribute20                in  varchar2
  ,p_pry_attribute21                in  varchar2
  ,p_pry_attribute22                in  varchar2
  ,p_pry_attribute23                in  varchar2
  ,p_pry_attribute24                in  varchar2
  ,p_pry_attribute25                in  varchar2
  ,p_pry_attribute26                in  varchar2
  ,p_pry_attribute27                in  varchar2
  ,p_pry_attribute28                in  varchar2
  ,p_pry_attribute29                in  varchar2
  ,p_pry_attribute30                in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_prtt_rmt_aprvd_pymt_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_prtt_rmt_aprvd_pymt_a
  (
   p_prtt_rmt_aprvd_fr_pymt_id      in  number
  ,p_prtt_reimbmt_rqst_id           in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_apprvd_fr_pymt_num             in  number
  ,p_adjmt_flag                     in  varchar2
  ,p_aprvd_fr_pymt_amt              in  number
  ,p_pymt_stat_cd                   in  varchar2
  ,p_pymt_stat_rsn_cd               in  varchar2
  ,p_pymt_stat_ovrdn_rsn_cd         in  varchar2
  ,p_pymt_stat_prr_to_ovrd_cd       in  varchar2
  ,p_business_group_id              in  number
  ,p_element_entry_value_id         in  number
  ,p_pry_attribute_category         in  varchar2
  ,p_pry_attribute1                 in  varchar2
  ,p_pry_attribute2                 in  varchar2
  ,p_pry_attribute3                 in  varchar2
  ,p_pry_attribute4                 in  varchar2
  ,p_pry_attribute5                 in  varchar2
  ,p_pry_attribute6                 in  varchar2
  ,p_pry_attribute7                 in  varchar2
  ,p_pry_attribute8                 in  varchar2
  ,p_pry_attribute9                 in  varchar2
  ,p_pry_attribute10                in  varchar2
  ,p_pry_attribute11                in  varchar2
  ,p_pry_attribute12                in  varchar2
  ,p_pry_attribute13                in  varchar2
  ,p_pry_attribute14                in  varchar2
  ,p_pry_attribute15                in  varchar2
  ,p_pry_attribute16                in  varchar2
  ,p_pry_attribute17                in  varchar2
  ,p_pry_attribute18                in  varchar2
  ,p_pry_attribute19                in  varchar2
  ,p_pry_attribute20                in  varchar2
  ,p_pry_attribute21                in  varchar2
  ,p_pry_attribute22                in  varchar2
  ,p_pry_attribute23                in  varchar2
  ,p_pry_attribute24                in  varchar2
  ,p_pry_attribute25                in  varchar2
  ,p_pry_attribute26                in  varchar2
  ,p_pry_attribute27                in  varchar2
  ,p_pry_attribute28                in  varchar2
  ,p_pry_attribute29                in  varchar2
  ,p_pry_attribute30                in  varchar2
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ben_prtt_rmt_aprvd_pymt_bk1;

 

/
