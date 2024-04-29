--------------------------------------------------------
--  DDL for Package HR_CANCEL_HIRE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CANCEL_HIRE_BK1" AUTHID CURRENT_USER as
/* $Header: pecahapi.pkh 120.1.12010000.2 2008/10/01 10:42:23 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< cancel_hire_b >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure cancel_hire_b
  (p_person_id                     in     number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< cancel_hire_a >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure cancel_hire_a
  (p_person_id                     in number
  ,p_effective_date                in date
  ,p_supervisor_warning            in boolean
  ,p_recruiter_warning             in boolean
  ,p_event_warning                 in boolean
  ,p_interview_warning             in boolean
  ,p_review_warning                in boolean
  ,p_vacancy_warning               in boolean
  ,p_requisition_warning           in boolean
  ,p_budget_warning                in boolean
  ,p_payment_warning               in boolean
  );
--
end hr_cancel_hire_bk1;

/
