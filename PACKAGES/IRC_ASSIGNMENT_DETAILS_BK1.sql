--------------------------------------------------------
--  DDL for Package IRC_ASSIGNMENT_DETAILS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ASSIGNMENT_DETAILS_BK1" AUTHID CURRENT_USER as
/* $Header: iriadapi.pkh 120.5.12010000.3 2010/05/18 14:44:03 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_assignment_details_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_assignment_details_b
  (p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_attempt_id                    in     number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_assignment_details_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_assignment_details_a
  (p_effective_date                in     date
  ,p_assignment_details_id         in     number
  ,p_assignment_id                 in     number
  ,p_attempt_id                    in     number
  ,p_details_version               in     number
  ,p_latest_details                in     varchar2
  ,p_effective_start_date          in     date
  ,p_effective_end_date            in     date
  ,p_object_version_number         in     number
  ,p_qualified                     in     varchar2
  ,p_considered                    in     varchar2
  );
--
end irc_assignment_details_bk1;

/
