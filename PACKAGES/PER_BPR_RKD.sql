--------------------------------------------------------
--  DDL for Package PER_BPR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BPR_RKD" AUTHID CURRENT_USER as
/* $Header: pebprrhi.pkh 120.0 2005/05/31 06:20:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_payroll_run_id               in number,
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
end per_bpr_rkd;

 

/
