--------------------------------------------------------
--  DDL for Package BEN_BEP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BEP_RKI" AUTHID CURRENT_USER as
/* $Header: bebeprhi.pkh 120.0.12010000.1 2008/07/29 10:55:42 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
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
  );
end ben_bep_rki;

/
