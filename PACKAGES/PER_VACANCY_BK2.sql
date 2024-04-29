--------------------------------------------------------
--  DDL for Package PER_VACANCY_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VACANCY_BK2" AUTHID CURRENT_USER as
/* $Header: pevacapi.pkh 120.1.12000000.1 2007/01/22 04:59:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_vacancy_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_vacancy_b
( p_effective_date              in date
, P_VACANCY_ID                  in number
, P_OBJECT_VERSION_NUMBER       in number
, P_DATE_FROM                   in date
, P_POSITION_ID                 in number
, P_JOB_ID                      in number
, P_GRADE_ID                    in number
, P_ORGANIZATION_ID             in number
, P_PEOPLE_GROUP_ID             in number
, P_LOCATION_ID                 in number
, P_RECRUITER_ID                in number
, P_DATE_TO                     in date
, P_SECURITY_METHOD             in varchar2
, P_DESCRIPTION                 in varchar2
, P_NUMBER_OF_OPENINGS          in number
, P_STATUS                      in varchar2
, P_BUDGET_MEASUREMENT_TYPE     in varchar2
, P_BUDGET_MEASUREMENT_VALUE    in number
, P_VACANCY_CATEGORY            in varchar2
, P_MANAGER_ID                  in number
, P_PRIMARY_POSTING_ID          in number
, P_ASSESSMENT_ID               in number
, P_ATTRIBUTE_CATEGORY          in varchar2
, P_ATTRIBUTE1                  in varchar2
, P_ATTRIBUTE2                  in varchar2
, P_ATTRIBUTE3                  in varchar2
, P_ATTRIBUTE4                  in varchar2
, P_ATTRIBUTE5                  in varchar2
, P_ATTRIBUTE6                  in varchar2
, P_ATTRIBUTE7                  in varchar2
, P_ATTRIBUTE8                  in varchar2
, P_ATTRIBUTE9                  in varchar2
, P_ATTRIBUTE10                 in varchar2
, P_ATTRIBUTE11                 in varchar2
, P_ATTRIBUTE12                 in varchar2
, P_ATTRIBUTE13                 in varchar2
, P_ATTRIBUTE14                 in varchar2
, P_ATTRIBUTE15                 in varchar2
, P_ATTRIBUTE16                 in varchar2
, P_ATTRIBUTE17                 in varchar2
, P_ATTRIBUTE18                 in varchar2
, P_ATTRIBUTE19                 in varchar2
, P_ATTRIBUTE20                 in varchar2
, P_ATTRIBUTE21                 in varchar2
, P_ATTRIBUTE22                 in varchar2
, P_ATTRIBUTE23                 in varchar2
, P_ATTRIBUTE24                 in varchar2
, P_ATTRIBUTE25                 in varchar2
, P_ATTRIBUTE26                 in varchar2
, P_ATTRIBUTE27                 in varchar2
, P_ATTRIBUTE28                 in varchar2
, P_ATTRIBUTE29                 in varchar2
, P_ATTRIBUTE30                 in varchar2
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_vacancy_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_vacancy_a
( p_effective_date              in date
, P_VACANCY_ID                  in number
, P_OBJECT_VERSION_NUMBER       in number
, P_DATE_FROM                   in date
, P_POSITION_ID                 in number
, P_JOB_ID                      in number
, P_GRADE_ID                    in number
, P_ORGANIZATION_ID             in number
, P_PEOPLE_GROUP_ID             in number
, P_LOCATION_ID                 in number
, P_RECRUITER_ID                in number
, P_DATE_TO                     in date
, P_SECURITY_METHOD             in varchar2
, P_DESCRIPTION                 in varchar2
, P_NUMBER_OF_OPENINGS          in number
, P_STATUS                      in varchar2
, P_BUDGET_MEASUREMENT_TYPE     in varchar2
, P_BUDGET_MEASUREMENT_VALUE    in number
, P_VACANCY_CATEGORY            in varchar2
, P_MANAGER_ID                  in number
, P_PRIMARY_POSTING_ID          in number
, P_ASSESSMENT_ID               in number
, P_ATTRIBUTE_CATEGORY          in varchar2
, P_ATTRIBUTE1                  in varchar2
, P_ATTRIBUTE2                  in varchar2
, P_ATTRIBUTE3                  in varchar2
, P_ATTRIBUTE4                  in varchar2
, P_ATTRIBUTE5                  in varchar2
, P_ATTRIBUTE6                  in varchar2
, P_ATTRIBUTE7                  in varchar2
, P_ATTRIBUTE8                  in varchar2
, P_ATTRIBUTE9                  in varchar2
, P_ATTRIBUTE10                 in varchar2
, P_ATTRIBUTE11                 in varchar2
, P_ATTRIBUTE12                 in varchar2
, P_ATTRIBUTE13                 in varchar2
, P_ATTRIBUTE14                 in varchar2
, P_ATTRIBUTE15                 in varchar2
, P_ATTRIBUTE16                 in varchar2
, P_ATTRIBUTE17                 in varchar2
, P_ATTRIBUTE18                 in varchar2
, P_ATTRIBUTE19                 in varchar2
, P_ATTRIBUTE20                 in varchar2
, P_ATTRIBUTE21                 in varchar2
, P_ATTRIBUTE22                 in varchar2
, P_ATTRIBUTE23                 in varchar2
, P_ATTRIBUTE24                 in varchar2
, P_ATTRIBUTE25                 in varchar2
, P_ATTRIBUTE26                 in varchar2
, P_ATTRIBUTE27                 in varchar2
, P_ATTRIBUTE28                 in varchar2
, P_ATTRIBUTE29                 in varchar2
, P_ATTRIBUTE30                 in varchar2
, P_ASSIGNMENT_CHANGED          in boolean
,p_inv_pos_grade_warning        in boolean
,p_inv_job_grade_warning        in boolean
)
;
--
end PER_VACANCY_BK2;

 

/
