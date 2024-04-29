--------------------------------------------------------
--  DDL for Package PER_BPR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BPR_RKI" AUTHID CURRENT_USER as
/* $Header: pebprrhi.pkh 120.0 2005/05/31 06:20:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date   in  date,
  p_payroll_run_id               in number,
  p_payroll_id                   in number,
  p_business_group_id            in number,
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
  p_bpr_attribute30                  in varchar2
  );
end per_bpr_rki;

 

/
