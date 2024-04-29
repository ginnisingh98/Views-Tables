--------------------------------------------------------
--  DDL for Package PER_BPA_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BPA_RKI" AUTHID CURRENT_USER as
/* $Header: pebparhi.pkh 120.0 2005/05/31 06:17:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date,
  p_processed_assignment_id      in number,
  p_payroll_run_id               in number,
  p_assignment_id                in number,
  p_object_version_number        in number,
  p_bpa_attribute_category           in varchar2,
  p_bpa_attribute1                   in varchar2,
  p_bpa_attribute2                   in varchar2,
  p_bpa_attribute3                   in varchar2,
  p_bpa_attribute4                   in varchar2,
  p_bpa_attribute5                   in varchar2,
  p_bpa_attribute6                   in varchar2,
  p_bpa_attribute7                   in varchar2,
  p_bpa_attribute8                   in varchar2,
  p_bpa_attribute9                   in varchar2,
  p_bpa_attribute10                  in varchar2,
  p_bpa_attribute11                  in varchar2,
  p_bpa_attribute12                  in varchar2,
  p_bpa_attribute13                  in varchar2,
  p_bpa_attribute14                  in varchar2,
  p_bpa_attribute15                  in varchar2,
  p_bpa_attribute16                  in varchar2,
  p_bpa_attribute17                  in varchar2,
  p_bpa_attribute18                  in varchar2,
  p_bpa_attribute19                  in varchar2,
  p_bpa_attribute20                  in varchar2,
  p_bpa_attribute21                  in varchar2,
  p_bpa_attribute22                  in varchar2,
  p_bpa_attribute23                  in varchar2,
  p_bpa_attribute24                  in varchar2,
  p_bpa_attribute25                  in varchar2,
  p_bpa_attribute26                  in varchar2,
  p_bpa_attribute27                  in varchar2,
  p_bpa_attribute28                  in varchar2,
  p_bpa_attribute29                  in varchar2,
  p_bpa_attribute30                  in varchar2
  );
end per_bpa_rki;

 

/
