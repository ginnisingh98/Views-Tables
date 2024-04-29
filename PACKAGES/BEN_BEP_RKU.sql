--------------------------------------------------------
--  DDL for Package BEN_BEP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BEP_RKU" AUTHID CURRENT_USER as
/* $Header: bebeprhi.pkh 120.0.12010000.1 2008/07/29 10:55:42 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_elig_obj_elig_prfl_id        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_elig_obj_id                  in number
  ,p_elig_prfl_id                 in number
  ,p_mndtry_flag                  in varchar2
  ,p_business_group_id            in number
  ,p_bep_attribute_category       in varchar2
  ,p_bep_attribute1               in varchar2
  ,p_bep_attribute2               in varchar2
  ,p_bep_attribute3               in varchar2
  ,p_bep_attribute4               in varchar2
  ,p_bep_attribute5               in varchar2
  ,p_bep_attribute6               in varchar2
  ,p_bep_attribute7               in varchar2
  ,p_bep_attribute8               in varchar2
  ,p_bep_attribute9               in varchar2
  ,p_bep_attribute10              in varchar2
  ,p_bep_attribute11              in varchar2
  ,p_bep_attribute12              in varchar2
  ,p_bep_attribute13              in varchar2
  ,p_bep_attribute14              in varchar2
  ,p_bep_attribute15              in varchar2
  ,p_bep_attribute16              in varchar2
  ,p_bep_attribute17              in varchar2
  ,p_bep_attribute18              in varchar2
  ,p_bep_attribute19              in varchar2
  ,p_bep_attribute20              in varchar2
  ,p_object_version_number        in number
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_elig_obj_id_o                in number
  ,p_elig_prfl_id_o               in number
  ,p_mndtry_flag_o                in varchar2
  ,p_business_group_id_o          in number
  ,p_bep_attribute_category_o     in varchar2
  ,p_bep_attribute1_o             in varchar2
  ,p_bep_attribute2_o             in varchar2
  ,p_bep_attribute3_o             in varchar2
  ,p_bep_attribute4_o             in varchar2
  ,p_bep_attribute5_o             in varchar2
  ,p_bep_attribute6_o             in varchar2
  ,p_bep_attribute7_o             in varchar2
  ,p_bep_attribute8_o             in varchar2
  ,p_bep_attribute9_o             in varchar2
  ,p_bep_attribute10_o            in varchar2
  ,p_bep_attribute11_o            in varchar2
  ,p_bep_attribute12_o            in varchar2
  ,p_bep_attribute13_o            in varchar2
  ,p_bep_attribute14_o            in varchar2
  ,p_bep_attribute15_o            in varchar2
  ,p_bep_attribute16_o            in varchar2
  ,p_bep_attribute17_o            in varchar2
  ,p_bep_attribute18_o            in varchar2
  ,p_bep_attribute19_o            in varchar2
  ,p_bep_attribute20_o            in varchar2
  ,p_object_version_number_o      in number
  );
--
end ben_bep_rku;

/
