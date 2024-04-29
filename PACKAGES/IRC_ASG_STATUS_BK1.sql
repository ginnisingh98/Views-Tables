--------------------------------------------------------
--  DDL for Package IRC_ASG_STATUS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ASG_STATUS_BK1" AUTHID CURRENT_USER as
/* $Header: iriasapi.pkh 120.2.12010000.2 2009/07/30 03:42:12 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_irc_asg_status_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_irc_asg_status_b
  (
    p_assignment_id             in  number
  , p_assignment_status_type_id in  number
  , p_status_change_reason      in  varchar2
  , p_status_change_date        in  date
  , p_status_change_comments    in  varchar2
  , p_status_change_by             in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_irc_asg_status_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_irc_asg_status_a
  (
    p_assignment_id             in  number
  , p_assignment_status_type_id in  number
  , p_status_change_reason      in  varchar2
  , p_assignment_status_id      in  number
  , p_object_version_number     in  number
  , p_status_change_date        in  date
  , p_status_change_comments    in  varchar2
  , p_status_change_by             in  varchar2
  );
--
end IRC_ASG_STATUS_BK1;

/
