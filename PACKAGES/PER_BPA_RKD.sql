--------------------------------------------------------
--  DDL for Package PER_BPA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BPA_RKD" AUTHID CURRENT_USER as
/* $Header: pebparhi.pkh 120.0 2005/05/31 06:17:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_processed_assignment_id     in number,
  p_payroll_run_id_o             in number,
  p_assignment_id_o              in number,
  p_object_version_number_o      in number,
  p_bpa_attribute_category_o         in varchar2,
  p_bpa_attribute1_o                 in varchar2,
  p_bpa_attribute2_o                 in varchar2,
  p_bpa_attribute3_o                 in varchar2,
  p_bpa_attribute4_o                 in varchar2,
  p_bpa_attribute5_o                 in varchar2,
  p_bpa_attribute6_o                 in varchar2,
  p_bpa_attribute7_o                 in varchar2,
  p_bpa_attribute8_o                 in varchar2,
  p_bpa_attribute9_o                 in varchar2,
  p_bpa_attribute10_o                in varchar2,
  p_bpa_attribute11_o                in varchar2,
  p_bpa_attribute12_o                in varchar2,
  p_bpa_attribute13_o                in varchar2,
  p_bpa_attribute14_o                in varchar2,
  p_bpa_attribute15_o                in varchar2,
  p_bpa_attribute16_o                in varchar2,
  p_bpa_attribute17_o                in varchar2,
  p_bpa_attribute18_o                in varchar2,
  p_bpa_attribute19_o                in varchar2,
  p_bpa_attribute20_o                in varchar2,
  p_bpa_attribute21_o                in varchar2,
  p_bpa_attribute22_o                in varchar2,
  p_bpa_attribute23_o                in varchar2,
  p_bpa_attribute24_o                in varchar2,
  p_bpa_attribute25_o                in varchar2,
  p_bpa_attribute26_o                in varchar2,
  p_bpa_attribute27_o                in varchar2,
  p_bpa_attribute28_o                in varchar2,
  p_bpa_attribute29_o                in varchar2,
  p_bpa_attribute30_o                in varchar2
  );
--
end per_bpa_rkd;

 

/
