--------------------------------------------------------
--  DDL for Package HR_MASS_MOVE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MASS_MOVE_API" AUTHID CURRENT_USER as
/* $Header: pemmvapi.pkh 120.0 2005/05/31 11:25:54 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< mass_move >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This batch process moves a group of positions from one organization
--   to another.
--   Some or all of the employee assignments may also move.  The applicant
--   assignments will be moved if they are not associated with a vacancy and
--   the position will no longer exist in the old organization.
--
-- Prerequisites:
--   The mass move detail records have been inserted into the following
--   tables:
--     PER_MASS_MOVES
--     PER_MM_POSITIONS
--     PER_MM_ASSIGNMENTS
--     PER_MM_VALID_GRADES
--     PER_MM_JOB_REQUIREMENTS
--
-- In Parameters:
--   Name                    Reqd Type     Description
--   p_validate              No   boolean  If true, the database remains
--                                         unchanged. If false a the database
--                                         will be changed.
--
--   p_mass_move_id          Yes  number   The identifier for the
--                                         mass move occurrence.
--
-- Post Success:
--   There are no out parameters.  All errors and warning messages
--   generated during this process and other processes that are called
--   by this process are written to the HR_API_BATCH_MESSAGE_LINES table.
--
-- Post Failure:
--   The batch process does not process the mass move occurrence.
--
-- Access Status:
--   Private.
--
procedure mass_move
  (p_validate                    in  boolean default false,
   p_mass_move_id                in  number
  );
--
end hr_mass_move_api;
--

 

/
