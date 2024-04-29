--------------------------------------------------------
--  DDL for Package PER_CANCEL_PLACEMENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CANCEL_PLACEMENT_BK1" AUTHID CURRENT_USER AS
/* $Header: pecplapi.pkh 120.1.12010000.1 2008/07/28 04:25:57 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< cancel_placement_b >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE cancel_placement_b
  (p_business_group_id IN NUMBER
  ,p_person_id         IN NUMBER
  ,p_effective_date    IN DATE);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< cancel_placement_a >-------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE cancel_placement_a
  (p_business_group_id   IN NUMBER
  ,p_person_id           IN NUMBER
  ,p_effective_date      IN DATE
  ,p_supervisor_warning  IN BOOLEAN
  ,p_recruiter_warning   IN BOOLEAN
  ,p_event_warning       IN BOOLEAN
  ,p_interview_warning   IN BOOLEAN
  ,p_review_warning      IN BOOLEAN
  ,p_vacancy_warning     IN BOOLEAN
  ,p_requisition_warning IN BOOLEAN
  ,p_budget_warning      IN BOOLEAN
  ,p_payment_warning     IN BOOLEAN);
--
END per_cancel_placement_bk1;

/
