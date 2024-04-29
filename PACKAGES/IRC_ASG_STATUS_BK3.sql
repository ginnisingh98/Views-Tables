--------------------------------------------------------
--  DDL for Package IRC_ASG_STATUS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ASG_STATUS_BK3" AUTHID CURRENT_USER as
/* $Header: iriasapi.pkh 120.2.12010000.2 2009/07/30 03:42:12 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_irc_asg_status_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_irc_asg_status_b
  (
    p_assignment_status_id      in  number
  , p_object_version_number     in  number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_irc_asg_status_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_irc_asg_status_a
  (
    p_assignment_status_id      in  number
  , p_object_version_number     in  number
  );
--
end IRC_ASG_STATUS_BK3;

/
