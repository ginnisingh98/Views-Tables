--------------------------------------------------------
--  DDL for Package PQH_TXN_JOB_REQUIREMENTS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_TXN_JOB_REQUIREMENTS_BK2" AUTHID CURRENT_USER as
/* $Header: pqtjrapi.pkh 120.0 2005/05/29 02:48:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_TXN_JOB_REQUIREMENT_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_TXN_JOB_REQUIREMENT_b
  (p_effective_date               in     date
  ,p_txn_job_requirement_id       in     number
  ,p_object_version_number        in     number
  ,p_business_group_id            in     number
  ,p_analysis_criteria_id         in     number
  ,p_position_transaction_id      in     number
  ,p_job_requirement_id           in     number
  ,p_date_from                    in     date
  ,p_date_to                      in     date
  ,p_essential                    in     varchar2
  ,p_job_id                       in     number
  ,p_request_id                   in     number
  ,p_program_application_id       in     number
  ,p_program_id                   in     number
  ,p_program_update_date          in     date
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_comments                     in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_TXN_JOB_REQUIREMENT_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_TXN_JOB_REQUIREMENT_a
  (p_effective_date               in     date
  ,p_txn_job_requirement_id       in     number
  ,p_object_version_number        in     number
  ,p_business_group_id            in     number
  ,p_analysis_criteria_id         in     number
  ,p_position_transaction_id      in     number
  ,p_job_requirement_id           in     number
  ,p_date_from                    in     date
  ,p_date_to                      in     date
  ,p_essential                    in     varchar2
  ,p_job_id                       in     number
  ,p_request_id                   in     number
  ,p_program_application_id       in     number
  ,p_program_id                   in     number
  ,p_program_update_date          in     date
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_comments                     in     varchar2
  );
--
end PQH_TXN_JOB_REQUIREMENTS_BK2;

 

/
