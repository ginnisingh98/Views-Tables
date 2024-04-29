--------------------------------------------------------
--  DDL for Package PER_PTU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PTU_RKI" AUTHID CURRENT_USER as
/* $Header: pepturhi.pkh 120.0 2005/05/31 15:58:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert(
  p_person_type_usage_id         in number,
  p_person_id                    in number,
  p_person_type_id               in number,
  p_effective_start_date         in date,
  p_effective_end_date           in date,
  p_object_version_number        in number,
  p_request_id                   in number,
  p_program_application_id       in number,
  p_program_id                   in number,
  p_program_update_date          in date,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_attribute21                  in varchar2,
  p_attribute22                  in varchar2,
  p_attribute23                  in varchar2,
  p_attribute24                  in varchar2,
  p_attribute25                  in varchar2,
  p_attribute26                  in varchar2,
  p_attribute27                  in varchar2,
  p_attribute28                  in varchar2,
  p_attribute29                  in varchar2,
  p_attribute30                  in varchar2,
  p_effective_date		 in date,
  p_validation_start_date        in date,
  p_validation_end_date          in date
  );
end per_ptu_rki;

 

/
