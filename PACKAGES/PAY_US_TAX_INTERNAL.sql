--------------------------------------------------------
--  DDL for Package PAY_US_TAX_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAX_INTERNAL" AUTHID CURRENT_USER AS
/* $Header: pytaxbsi.pkh 120.1.12010000.1 2008/07/27 23:43:57 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< maintain_tax_percentage >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure can be used to maintain the percentage coverage for each
--   location. The routine will update all necessary element entries.
--
-- Prerequisites: None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  number   The ID of the assignment
--   p_effective_date               Yes  date     The effective date of change
--   p_state_code                   Yes  varchar2
--   p_county_code                  Yes  varchar2
--   p_city_code                    Yes  varchar2
--   p_percentage                   No   number   New percentage for location
--   p_calculate_pct                No   boolean
--   p_datetrack_mode               Yes  varchar2
--   p_effective_start_date         Yes  date     The start date of the element
--   p_effective_end_date           Yes  date     The end date of the element
--
-- Post Success:
--   Processing continues.  The effective_start_date and effective_end_date
--   set.
--
-- Post Failure:
--   No changes will be made and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
   procedure maintain_tax_percentage
      (
       p_assignment_id          in     number,
       p_effective_date         in     date,
       p_state_code             in     varchar2,
       p_county_code            in     varchar2,
       p_city_code              in     varchar2,
       p_percentage             in     number  default 0,
       p_calculate_pct          in     boolean default true,
       p_datetrack_mode         in     varchar2,
       p_effective_start_date   in out nocopy date,
       p_effective_end_date     in out nocopy date
      );

-- ----------------------------------------------------------------------------
-- |-----------------------------< maintain_wc >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure can be used to create as well as update the workers
--   compensation element entry for the assignment of a federal tax record.
--   It calls the element entries api to insert and update the element entry
--   record.
--
--  Note : For every change in the federal tax record, we will be changing
--         the worker's comp element entry.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_emp_fed_tax_rule_id          Yes  number   The ID of the federal tax
--                                                rule for which the workers
--                                                comp element element entry
--                                                is to be created/modified.
--   p_effective_start_date         Yes  date     The start date of the
--                                                element entry.
--   p_effective_end_date           Yes  date     The end date of the element
--                                                entry.
--   p_effective_date               Yes  date     effective date of the change
--   p_datetrack_mode               Yes  varchar2
--
-- Post Success:
--   Processing continues.  No OUT parameters are set.
--
-- Post Failure:
--   The workers comp entry will not be changed and an error will be raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure maintain_wc
(
   p_emp_fed_tax_rule_id            in     number
  ,p_effective_start_date           in     date
  ,p_effective_end_date             in     date
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
 );

-- ----------------------------------------------------------------------------
-- |------------------------< delete_fed_tax_rule >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API will delete the federal tax rule for an assignment.  In the
--   process, it will delete the workers compensation element entry, the
--   state, county and city tax rules, and the tax percentage element
--   entries.
--
--   Once the federal tax rule is created for an assignment, it should exist
--   as long as the assignment exists.  It should only be deleted when the
--   assignment is being deleted.
--
-- Prerequisites:
--
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_delete_mode        Yes  varchar2 Datetrack mode.
--   p_assignment_id                Yes  number   assignment of rules to delete
--   p_delete_routine               No   varchar2 Name of the routine that is
--                                                calling this process.  Should
--                                                be set to 'ASSIGNMENT' to show
--                                                that the assignment is being
--                                                deleted.
--
-- Post Success:
--   When the federal tax rule has been deleted, the following OUT parameters
--   are set.
--
--   Name                                Type     Description
--   p_effective_start_date              date     Effective Start Date of Record
--   p_effective_end_date                date     Effective End Date of Record
--   p_object_version_number             number   OVN of record
--
-- Post Failure:
--   The tax rules will not be deleted, and an error will be raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_fed_tax_rule
  (p_effective_date                 in     date
  ,p_datetrack_delete_mode          in     varchar2
  ,p_assignment_id                  in     number
  ,p_delete_routine                 in     varchar2     default null
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  ,p_object_version_number             out nocopy number
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< address_change >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates new tax rule records when a person changes their primary
--   address.  Tax percentage records are also created.
--
--   In two cases, this API will complete successfully, but not create any new
--   tax rules.  If no federal tax rule exists, the tax defaulting criteria
--   has not been met, so no tax rules will be created.  If the tax rules for
--   the state, county and city of the new address already existed for the
--   person's assignment, they will not be recreated.
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  date     Effective date of address
--                                                change (Date_from value).
--   p_person_id                    No   number   ID of person whose address
--                                                has changed.
--                                                (Primary entry method.)
--   p_assignment_id                No   number   ID of an assignment of person
--                                                whose addesss has changed.
--                                                (An alternate entry method.)
--
-- Post Success:
--   Processing continues.  No OUT parameters are set.
--
-- Post Failure:
--   The tax rules will not be created and an error will be raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure address_change
    (p_effective_date               In      date
    ,p_person_id                    In      number     default null
    ,p_assignment_id                In      number     default null
  );

-- ----------------------------------------------------------------------------
-- |-----------------------< create_default_tax_rules >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API will check whether a given assignment meets the tax defaulting
--   criteria.  If it does, the API will create default tax records for the
--   assignment.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  date     Session Date.
--   p_assignment_id                Yes  number   ID of ASG of new tax records
--
-- Post Success:
--   When default tax records are created for an assignment, the following
--   OUT parameters are set:
--
--   Name                                Type     Description
--   p_emp_fed_tax_rule_id               number   PK of federal tax record
--   p_fed_object_version_number         number   OVN of federal tax record
--   p_fed_effective_start_date          date     Effective Start Date of
--                                                the federal tax Record
--   p_fed_effective_end_date            date     Effective End Date of
--                                                the federal tax Record
--
-- Post Failure:
--   The tax records are not created, and an error will be raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_default_tax_rules
  (p_effective_date                 in      date
  ,p_assignment_id                  in      number
  ,p_emp_fed_tax_rule_id                out nocopy number
  ,p_fed_object_version_number          out nocopy number
  ,p_fed_effective_start_date           out nocopy date
  ,p_fed_effective_end_date             out nocopy date
  );

-- ----------------------------------------------------------------------------
-- |----------------------< maintain_us_employee_taxes >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  This procedure can be called for a wide variety of situations that affect
--  US employee taxes.  It is a central api for handling changes to the tax
--  rules and percentages that occur as a result of changes to either the
--  person or the assignment.  It can be called for all of the following cases:
--
--   A change to the assignment so that it meets the tax defaulting criteria,
--   Providing a person's primary residence to meet the tax defaulting criteria,
--   Changes to the assignment location,
--   Changes to the primary residence address,
--   Termination of the assignment,
--   Purging of the assignment
--
--
-- How to call this procedure:
-- ===========================
-- From an assignment API
--      p_effective_date               Required
--      p_datetrack_mode               Required
--      p_assignment_id                Required
--      p_location_id                  Provide only if it has changed
--      p_address_id                   NULL
--      p_delete_routine               'ASSIGNMENT' if using datetrack delete
--                                      mode of ZAP or DELETE, otherwise NULL
--
-- From an address API
--      p_effective_date               Required - Use the date_from column
--                                      of the changed address record
--      p_datetrack_mode               NULL
--      p_assignment_id                NULL
--      p_location_id                  NULL
--      p_address_id                   Required
--      p_delete_routine               NULL
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type      Description
--   p_effective_date               Yes  date      Session Date.
--   p_datetrack_mode               Yes  varchar2  Datetrack mode.
--   p_assignment_id                No   number    Pass this parameter only if
--                                                 the tax change is related to
--                                                 an assignment change.
--   p_location_id                  No   number    If the assignment change
--                                                 includes a change in the work
--                                                 location, pass in the new
--                                                 location id.
--   p_address_id                   No   number    Pass this parameter if the
--                                                 tax change is related to a
--                                                 change to the person's
--                                                 primary residence address.
--   p_delete_routine               No   varchar2  Set this parameter to
--                                                 'ASSIGNMENT' only if the
--                                                 assignment is being
--                                                 terminated or purged.
--
-- Post Success:
--   Processing continues.  No OUT parameters are set.
--
-- Post Failure:
--   No data is created or updated and an error will be raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure maintain_us_employee_taxes
(  p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2  default null
  ,p_assignment_id                  in  number    default null
  ,p_location_id                    in  number    default null
  ,p_address_id                     in  number    default null
  ,p_delete_routine                 in  varchar2  default null
 );

-- ----------------------------------------------------------------------------
-- |---------------------------< location_change >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API will make all of the necessary changes to the taxes of an
--   assignment when the location of that assignment changes.
--   The federal tax rule sui state will be updated to the new location, as
--   will the workers compensation element entry.  The existing tax
--   percentage records will be updated to reflect the change in location.
--   If tax rules for the new location's state, county or city did not
--   already exist for this assignment, they will be created along with new
--   tax percentage records.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2
--   p_assignment_id                Yes  number   ID of assignment whose
--                                                location changed
--   p_location_id                  Yes  number   ID of new location
--
-- Post Success:
--   The taxes will be updated for the new location.  Any new tax rules and
--   percentage records will be created.
--
-- Post Failure:
--   The tax rules will not be created and an error will be raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure location_change
    (p_effective_date               In      date
    ,p_datetrack_mode               In      varchar2
    ,p_assignment_id                In      number
    ,p_location_id                  In      number
    );

-- ----------------------------------------------------------------------------
-- |-------------------------< move_tax_default_date >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API will move the tax defaulting date for all tax records related
--   to the assignment.  This is necessary when an assignment change before the
--   tax defaulting date meets the defaulting criteria, or when a person's
--   hire date changes.
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2
--   p_assignment_id                Yes  number   ID of assignment whose
--                                                location changed
--   p_new_location_id              No   number   ID of new location
--   p_new_hire_date                No   date     new hire date from change
--                                                to the person's record
--
-- Post Success:
--   Processing continues.  No OUT parameters are set.
--
-- Post Failure:
--   Tax records are not updated and an error will be raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure move_tax_default_date
    (p_effective_date               In      date
    ,p_datetrack_mode               In      varchar2
    ,p_assignment_id                In      number
    ,p_new_location_id              In      number     default null
    ,p_new_hire_date                In      date       default null
  );

--
End pay_us_tax_internal;

/
