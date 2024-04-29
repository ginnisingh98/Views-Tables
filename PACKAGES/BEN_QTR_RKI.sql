--------------------------------------------------------
--  DDL for Package BEN_QTR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_QTR_RKI" AUTHID CURRENT_USER as
/* $Header: beqtrrhi.pkh 120.0.12010000.1 2008/07/29 12:59:57 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_qual_titl_rt_id           in number
 ,p_effective_start_date           in date
 ,p_effective_end_date             in date
 ,p_business_group_id              in number
 ,p_vrbl_rt_prfl_id                  in number
 ,p_ordr_num                       in number
 ,p_excld_flag                     in varchar2
 ,p_qualification_type_id          in number
 ,p_title                          in varchar2
 ,p_qtr_attribute_category         in varchar2
 ,p_qtr_attribute1                 in varchar2
 ,p_qtr_attribute2                 in varchar2
 ,p_qtr_attribute3                 in varchar2
 ,p_qtr_attribute4                 in varchar2
 ,p_qtr_attribute5                 in varchar2
 ,p_qtr_attribute6                 in varchar2
 ,p_qtr_attribute7                 in varchar2
 ,p_qtr_attribute8                 in varchar2
 ,p_qtr_attribute9                 in varchar2
 ,p_qtr_attribute10                in varchar2
 ,p_qtr_attribute11                in varchar2
 ,p_qtr_attribute12                in varchar2
 ,p_qtr_attribute13                in varchar2
 ,p_qtr_attribute14                in varchar2
 ,p_qtr_attribute15                in varchar2
 ,p_qtr_attribute16                in varchar2
 ,p_qtr_attribute17                in varchar2
 ,p_qtr_attribute18                in varchar2
 ,p_qtr_attribute19                in varchar2
 ,p_qtr_attribute20                in varchar2
 ,p_qtr_attribute21                in varchar2
 ,p_qtr_attribute22                in varchar2
 ,p_qtr_attribute23                in varchar2
 ,p_qtr_attribute24                in varchar2
 ,p_qtr_attribute25                in varchar2
 ,p_qtr_attribute26                in varchar2
 ,p_qtr_attribute27                in varchar2
 ,p_qtr_attribute28                in varchar2
 ,p_qtr_attribute29                in varchar2
 ,p_qtr_attribute30                in varchar2
 ,p_object_version_number          in number
 ,p_effective_date                 in date
 ,p_validation_start_date          in date
 ,p_validation_end_date            in date
  );
end ben_qtr_rki;

/
