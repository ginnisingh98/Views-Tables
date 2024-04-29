--------------------------------------------------------
--  DDL for Package BEN_JRT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_JRT_RKI" AUTHID CURRENT_USER as
/* $Header: bejrtrhi.pkh 120.0 2005/05/28 03:14:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_job_rt_id                    in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_job_id                       in number
  ,p_excld_flag                   in varchar2
  ,p_business_group_id            in number
  ,p_vrbl_rt_prfl_id              in number
  ,p_object_version_number        in number
  ,p_ordr_num                     in number
  ,p_jrt_attribute_category       in varchar2
  ,p_jrt_attribute1               in varchar2
  ,p_jrt_attribute2               in varchar2
  ,p_jrt_attribute3               in varchar2
  ,p_jrt_attribute4               in varchar2
  ,p_jrt_attribute5               in varchar2
  ,p_jrt_attribute6               in varchar2
  ,p_jrt_attribute7               in varchar2
  ,p_jrt_attribute8               in varchar2
  ,p_jrt_attribute9               in varchar2
  ,p_jrt_attribute10              in varchar2
  ,p_jrt_attribute11              in varchar2
  ,p_jrt_attribute12              in varchar2
  ,p_jrt_attribute13              in varchar2
  ,p_jrt_attribute14              in varchar2
  ,p_jrt_attribute15              in varchar2
  ,p_jrt_attribute16              in varchar2
  ,p_jrt_attribute17              in varchar2
  ,p_jrt_attribute18              in varchar2
  ,p_jrt_attribute19              in varchar2
  ,p_jrt_attribute20              in varchar2
  ,p_jrt_attribute21              in varchar2
  ,p_jrt_attribute22              in varchar2
  ,p_jrt_attribute23              in varchar2
  ,p_jrt_attribute24              in varchar2
  ,p_jrt_attribute25              in varchar2
  ,p_jrt_attribute26              in varchar2
  ,p_jrt_attribute27              in varchar2
  ,p_jrt_attribute28              in varchar2
  ,p_jrt_attribute29              in varchar2
  ,p_jrt_attribute30              in varchar2
  );
end ben_jrt_rki;

 

/
