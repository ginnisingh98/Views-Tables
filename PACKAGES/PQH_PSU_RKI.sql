--------------------------------------------------------
--  DDL for Package PQH_PSU_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PSU_RKI" AUTHID CURRENT_USER as
/* $Header: pqpsurhi.pkh 120.0 2005/05/29 02:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_emp_stat_situation_id        in number
  ,p_statutory_situation_id       in number
  ,p_person_id                    in number
  ,p_provisional_start_date       in date
  ,p_provisional_end_date         in date
  ,p_actual_start_date            in date
  ,p_actual_end_date              in date
  ,p_approval_flag                in varchar2
  ,p_comments                     in varchar2
  ,p_contact_person_id            in number
  ,p_contact_relationship         in varchar2
  ,p_external_organization_id     in number
  ,p_renewal_flag                 in varchar2
  ,p_renew_stat_situation_id      in number
  ,p_seconded_career_id           in number
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_attribute21                  in varchar2
  ,p_attribute22                  in varchar2
  ,p_attribute23                  in varchar2
  ,p_attribute24                  in varchar2
  ,p_attribute25                  in varchar2
  ,p_attribute26                  in varchar2
  ,p_attribute27                  in varchar2
  ,p_attribute28                  in varchar2
  ,p_attribute29                  in varchar2
  ,p_attribute30                  in varchar2
  ,p_object_version_number        in number
  );
end pqh_psu_rki;

 

/
