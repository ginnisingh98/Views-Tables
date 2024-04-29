--------------------------------------------------------
--  DDL for Package IRC_PARTY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PARTY_BK3" AUTHID CURRENT_USER as
/* $Header: irhzpapi.pkh 120.15.12010000.5 2010/04/16 14:57:54 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< registered_user_application_b >----------------|
-- ----------------------------------------------------------------------------
--
procedure registered_user_application_b
  (
    p_effective_date            IN     date
   ,p_person_id                 IN     number
   ,p_applicant_number          IN     varchar2
   ,p_application_received_date IN     date
   ,p_vacancy_id                IN     number
   ,p_posting_content_id        IN     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< registered_user_application_a >----------------|
-- ----------------------------------------------------------------------------
--
procedure registered_user_application_a
  (
    p_effective_date            IN     date
   ,p_person_id                 IN     number
   ,p_applicant_number          IN     varchar2
   ,p_application_received_date IN     date
   ,p_vacancy_id                IN     number
   ,p_posting_content_id        IN     number
   ,p_assignment_id             IN     number
   ,p_asg_object_version_number IN     number
  );
--
end IRC_PARTY_BK3;

/
