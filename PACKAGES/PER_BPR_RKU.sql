--------------------------------------------------------
--  DDL for Package PER_BPR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BPR_RKU" AUTHID CURRENT_USER as
/* $Header: pebprrhi.pkh 120.0 2005/05/31 06:20:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date   in  date,
  p_payroll_run_id               in number,
  p_payroll_identifier           in varchar2,
  p_period_start_date            in date,
  p_period_end_date              in date,
  p_processing_date              in date,
  p_object_version_number        in number,
  p_bpr_attribute_category           in varchar2,
  p_bpr_attribute1                   in varchar2,
  p_bpr_attribute2                   in varchar2,
  p_bpr_attribute3                   in varchar2,
  p_bpr_attribute4                   in varchar2,
  p_bpr_attribute5                   in varchar2,
  p_bpr_attribute6                   in varchar2,
  p_bpr_attribute7                   in varchar2,
  p_bpr_attribute8                   in varchar2,
  p_bpr_attribute9                   in varchar2,
  p_bpr_attribute10                  in varchar2,
  p_bpr_attribute11                  in varchar2,
  p_bpr_attribute12                  in varchar2,
  p_bpr_attribute13                  in varchar2,
  p_bpr_attribute14                  in varchar2,
  p_bpr_attribute15                  in varchar2,
  p_bpr_attribute16                  in varchar2,
  p_bpr_attribute17                  in varchar2,
  p_bpr_attribute18                  in varchar2,
  p_bpr_attribute19                  in varchar2,
  p_bpr_attribute20                  in varchar2,
  p_bpr_attribute21                  in varchar2,
  p_bpr_attribute22                  in varchar2,
  p_bpr_attribute23                  in varchar2,
  p_bpr_attribute24                  in varchar2,
  p_bpr_attribute25                  in varchar2,
  p_bpr_attribute26                  in varchar2,
  p_bpr_attribute27                  in varchar2,
  p_bpr_attribute28                  in varchar2,
  p_bpr_attribute29                  in varchar2,
  p_bpr_attribute30                  in varchar2,
  p_payroll_id_o                 in number,
  p_business_group_id_o          in number,
  p_payroll_identifier_o         in varchar2,
  p_period_start_date_o          in date,
  p_period_end_date_o            in date,
  p_processing_date_o            in date,
  p_object_version_number_o      in number,
  p_bpr_attribute_category_o         in varchar2,
  p_bpr_attribute1_o                 in varchar2,
  p_bpr_attribute2_o                 in varchar2,
  p_bpr_attribute3_o                 in varchar2,
  p_bpr_attribute4_o                 in varchar2,
  p_bpr_attribute5_o                 in varchar2,
  p_bpr_attribute6_o                 in varchar2,
  p_bpr_attribute7_o                 in varchar2,
  p_bpr_attribute8_o                 in varchar2,
  p_bpr_attribute9_o                 in varchar2,
  p_bpr_attribute10_o                in varchar2,
  p_bpr_attribute11_o                in varchar2,
  p_bpr_attribute12_o                in varchar2,
  p_bpr_attribute13_o                in varchar2,
  p_bpr_attribute14_o                in varchar2,
  p_bpr_attribute15_o                in varchar2,
  p_bpr_attribute16_o                in varchar2,
  p_bpr_attribute17_o                in varchar2,
  p_bpr_attribute18_o                in varchar2,
  p_bpr_attribute19_o                in varchar2,
  p_bpr_attribute20_o                in varchar2,
  p_bpr_attribute21_o                in varchar2,
  p_bpr_attribute22_o                in varchar2,
  p_bpr_attribute23_o                in varchar2,
  p_bpr_attribute24_o                in varchar2,
  p_bpr_attribute25_o                in varchar2,
  p_bpr_attribute26_o                in varchar2,
  p_bpr_attribute27_o                in varchar2,
  p_bpr_attribute28_o                in varchar2,
  p_bpr_attribute29_o                in varchar2,
  p_bpr_attribute30_o                in varchar2
  );
--
end per_bpr_rku;

 

/
