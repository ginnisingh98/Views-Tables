--------------------------------------------------------
--  DDL for Package HR_PERSON_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_INTERNAL" AUTHID CURRENT_USER as
/* $Header: peperbsi.pkh 120.0.12010000.1 2008/07/28 05:13:12 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< product_installed >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Checks whether the specified product is installed or not.
-- Returns status and oracle_id also.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_application_short_name        Yes  varchar2 Application short name
--
-- Out parameters:
--   Name                           Type      Description
--  p_status                        varchar2  Set to the status of the
--                                            installation.
--  p_yes_no                        varchar2  Set to Y if the product is
--                                            installed otherwsie N.
--  p_oracle_username               varchar2  user name.
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
PROCEDURE product_installed (p_application_short_name IN varchar2
                            ,p_status          OUT NOCOPY varchar2
                            ,p_yes_no          OUT NOCOPY varchar2
			    ,p_oracle_username OUT NOCOPY varchar2);
--
-- ----------------------------------------------------------------------------
-- |------------------------< weak_predel_validation >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- Weak pre-delete validation executed when called the delete_person API
-- from Delete Person form.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_person_id                     yes  number   ID of the person.
--  p_effective_date                yes  date     session date.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
PROCEDURE weak_predel_validation (p_person_id    IN number
 		                 ,p_effective_date IN date);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< strong_predel_validation >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- Strong pre-delete validation executed when called from the Enter Person
-- and Applicant Quick Entry forms.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_person_id                     yes  number   ID of the person.
--  p_effective_date                yes  date     session date.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
PROCEDURE strong_predel_validation (p_person_id    IN number
				   ,p_effective_date IN date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_contact >------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- Is this contact a contact for anybody else? If so then do nothing.
-- If not then check if this person has ever been an employee or
-- applicant. If they have not then check whether they have any extra
-- info entered for them (other than default info). If they have not
-- then delete this contact also. Otherwise do nothing.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_person_id                     yes  number   ID of the person.
--  p_contact_person_id             yes  number   Contact in this relationship
--                                                - the person who the check
--                                                is performed against.
--  p_contact_relationship_id       yes  number   Relationship which is
--                                                currently being considered
--                                                for this contact.
--  p_effective_date                yes  date     session date.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
PROCEDURE check_contact(p_person_id  IN number
                       ,p_contact_person_id IN number
                       ,p_contact_relationship_id IN number
                       ,p_effective_date IN date) ;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_org_manager >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- If the person is a manager for organization then the organization
-- information manager info will be nullified for those organizations.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_person_id                     yes  number   ID of the person.
--  p_effective_date                yes  date     session date.
--
-- Out parameters:
--   Name                           Type     Description
--  p_person_org_manager_warning   varchar2  Warning message to indicate
--                                           that the person is manager
--                                           for one or more organizations.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure delete_org_manager(p_person_id in number
                            ,p_effective_date in date
                            ,p_person_org_manager_warning out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< people_default_deletes >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- Delete people who only have default information entered for them.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_person_id                     yes  number   ID of the person.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
PROCEDURE people_default_deletes(p_person_id IN number);
--
-- ----------------------------------------------------------------------------
-- |---------------------< applicant_default_deletes >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- Delete applicants who only have default information entered for them.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_person_id                     yes  number   ID of the person.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
PROCEDURE applicant_default_deletes (p_person_id IN number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_person >------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- Delete a person completely from the HR database. Deletes from all tables
-- referencing this person n HR database.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_person_id                     yes  number   ID of the person.
--  p_effective_date                  yes  date     session date.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
PROCEDURE delete_person (p_person_id      IN number
   	                ,p_effective_date IN date);
--
end hr_person_internal;

/
