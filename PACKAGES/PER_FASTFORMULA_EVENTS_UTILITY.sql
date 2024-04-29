--------------------------------------------------------
--  DDL for Package PER_FASTFORMULA_EVENTS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FASTFORMULA_EVENTS_UTILITY" AUTHID CURRENT_USER as
/* $Header: perffevt.pkh 120.1 2005/06/06 04:35:19 ssmukher noship $ */

-- Variables declaration--
-- Added by ssmukher for Employment Equity Report -----
   TYPE  date_tab is TABLE OF date
   index by BINARY_INTEGER;
--
-- ----------------------------------------------------------------------------
-- |------------------------< per_fastformula_event >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This package calls a fast formula repitiously, currently for each
--   assignment_start_date for each assignment for a person id.  It then totals
--   the number returned from the fast formula.
--   It is designed to be expandable, based on event type entered.
--
--
-- Prerequisites:
--   An event type (which with current coding must also exist as a Fast Formula
--   name), person_id, start date and end date must be passed into the package.
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_event_type                   Yes  varchar2 Decides which event to process
--                                                Must match a formula name.
--   p_business_group_id                 number   If this is entered the code
--                                                will look for the promotions
--                                                fast formula for this
--                                                business group first
--   p_person_id                    Yes  number   Person for whom the fast
--                                                formula returns are counted.
--   p_start_date                   Yes  varchar2 Date from which require data.
--   p_end_date                     Yes  varchar2 Date to which require data
--
   function per_fastformula_event(p_event_type        in varchar2,
                                  p_formula_type      in varchar2,
                                  p_business_group_id in number,
                                  p_person_id         in number,
                                  p_start_date        in date,
                                  p_end_date          in date)
   return number;
--
-- ----------------------------------------------------------------------------
-- |--< per_fastformula_event >---overload function to run for a single date--|
-- ----------------------------------------------------------------------------
--
   function per_fastformula_event(p_event_type        in varchar2,
                                  p_formula_type      in varchar2,
                                  p_business_group_id in number,
                                  p_person_id         in number,
                                  p_effective_date    in date)
   return number;
--
-- ----------------------------------------------------------------------------
-- !--------- Added by ssmukher for Employment Equity Report -----------------!
-- |--< per_fastformula_event >---overload function to return promotion dates-|
-- ----------------------------------------------------------------------------
--
   function per_fastformula_event(p_event_type        in varchar2,
                                  p_formula_type      in varchar2,
                                  p_business_group_id in number,
                                  p_person_id         in number,
                                  p_start_date        in date,
                                  p_end_date          in date,
                                  p_date_tab          out nocopy date_tab)
   return number;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_formula_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This package calls a gets the fast formula id,for the event type passed in,
--   first looking for this at business group level
--
--
-- Prerequisites:
--   An event type (which must be the same as the Fast Formula name)
--   and effective date must be passed into the package.
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_event_type                   Yes  varchar2 Decides formula id to look for
--                                                Must match a formula name.
--   p_business_group_id                 number   If this is entered the code
--                                                will look for the
--                                                fast formula for this
--                                                business group first
--   p_effective_date               Yes  date     Effective Date of formula
--
   function get_formula_id(p_event_type        in varchar2,
                           p_formula_type      in varchar2,
                           p_business_group_id in number,
                           p_effective_date    in date)
   return number;
   --
end per_fastformula_events_utility;

 

/
