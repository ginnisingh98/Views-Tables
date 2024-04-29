--------------------------------------------------------
--  DDL for Package IRC_AGENCY_VACANCIES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_AGENCY_VACANCIES_BK1" AUTHID CURRENT_USER as
/* $Header: iriavapi.pkh 120.2 2008/02/21 14:08:33 viviswan noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_AGENCY_VACANCY_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_AGENCY_VACANCY_b
      (p_agency_vacancy_id          in number
      ,p_agency_id                  in number
      ,p_vacancy_id                 in number
      ,p_start_date                 in date
      ,p_end_date                   in date
      ,p_max_allowed_applicants     in number
      ,p_manage_applicants_allowed  in varchar2
      ,p_attribute_category         in varchar2
      ,p_attribute1                 in varchar2
      ,p_attribute2                 in varchar2
      ,p_attribute3                 in varchar2
      ,p_attribute4                 in varchar2
      ,p_attribute5                 in varchar2
      ,p_attribute6                 in varchar2
      ,p_attribute7                 in varchar2
      ,p_attribute8                 in varchar2
      ,p_attribute9                 in varchar2
      ,p_attribute10                in varchar2
      ,p_attribute11                in varchar2
      ,p_attribute12                in varchar2
      ,p_attribute13                in varchar2
      ,p_attribute14                in varchar2
      ,p_attribute15                in varchar2
      ,p_attribute16                in varchar2
      ,p_attribute17                in varchar2
      ,p_attribute18                in varchar2
      ,p_attribute19                in varchar2
      ,p_attribute20                in varchar2
      ,p_attribute21                in varchar2
      ,p_attribute22                in varchar2
      ,p_attribute23                in varchar2
      ,p_attribute24                in varchar2
      ,p_attribute25                in varchar2
      ,p_attribute26                in varchar2
      ,p_attribute27                in varchar2
      ,p_attribute28                in varchar2
      ,p_attribute29                in varchar2
      ,p_attribute30                in varchar2
      );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_AGENCY_VACANCY_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_AGENCY_VACANCY_a
      (p_agency_vacancy_id          in number
      ,p_agency_id                  in number
      ,p_vacancy_id                 in number
      ,p_start_date                 in date
      ,p_end_date                   in date
      ,p_max_allowed_applicants     in number
      ,p_manage_applicants_allowed  in varchar2
      ,p_attribute_category         in varchar2
      ,p_attribute1                 in varchar2
      ,p_attribute2                 in varchar2
      ,p_attribute3                 in varchar2
      ,p_attribute4                 in varchar2
      ,p_attribute5                 in varchar2
      ,p_attribute6                 in varchar2
      ,p_attribute7                 in varchar2
      ,p_attribute8                 in varchar2
      ,p_attribute9                 in varchar2
      ,p_attribute10                in varchar2
      ,p_attribute11                in varchar2
      ,p_attribute12                in varchar2
      ,p_attribute13                in varchar2
      ,p_attribute14                in varchar2
      ,p_attribute15                in varchar2
      ,p_attribute16                in varchar2
      ,p_attribute17                in varchar2
      ,p_attribute18                in varchar2
      ,p_attribute19                in varchar2
      ,p_attribute20                in varchar2
      ,p_attribute21                in varchar2
      ,p_attribute22                in varchar2
      ,p_attribute23                in varchar2
      ,p_attribute24                in varchar2
      ,p_attribute25                in varchar2
      ,p_attribute26                in varchar2
      ,p_attribute27                in varchar2
      ,p_attribute28                in varchar2
      ,p_attribute29                in varchar2
      ,p_attribute30                in varchar2
      ,p_object_version_number      in varchar2
      );
--
end IRC_AGENCY_VACANCIES_BK1;

/
