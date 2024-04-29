--------------------------------------------------------
--  DDL for Package PER_INC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_INC_BUS" AUTHID CURRENT_USER as
/* $Header: peincrhi.pkh 120.0 2005/05/31 10:08:42 appldev noship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--
--  Prerequisites:
--    The primary key identified by p_incident_id
--     already exists.
--
--  In Arguments:
--    p_incident_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure set_security_group_id
  (p_incident_id                          in number
  );
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_incident_id
--     already exists.
--
--  In Arguments:
--    p_incident_id
--
--
--  Post Success:
--    The business group's legislation code will be returned.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
FUNCTION return_legislation_code
  (p_incident_id                          in     number
  ) RETURN varchar2;
--
--
-- ---------------------------------------------------------------------------
-- |----------------------< get_osha_case_number >---------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Returns the generated next OSHA case number
--
--  Prerequisites:
--    The table PER_US_OSHA_NUMBERS must have been populated with values.
--
--  In Arguments:
--    p_date            (incident_date)
--    p_bg_id           (business_group_id)
--
--
--  Post Success:
--    Generated next OSHA case number will be returned.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
Function get_osha_case_number
  (p_date          in   date
  ,p_bg_id         in   number
  ) RETURN varchar2;
--
-- ---------------------------------------------------------------------------
-- |---------------------< chk_incident_reference >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Validates incident_reference is not null and is unique
--
--  Prerequisites:
--
--  In Arguments:
--    p_incident_id
--    p_incident_reference
--    p_object_version_number
--
--  Post Success:
--    processing continues
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Public access.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
PROCEDURE chk_incident_reference
  (p_incident_id             in     per_work_incidents.incident_id%TYPE
  ,p_incident_reference      in     per_work_incidents.incident_reference%TYPE
  ,p_object_version_number   in     per_work_incidents.object_version_number%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For insert, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_inc_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For update, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_inc_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Prerequisites:
--   This private procedure is called from del procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicity coded.
--
-- Developer Implementation Notes:
--   For delete, your business rules should be executed from this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
--
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in per_inc_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_incident_reference >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the incident_reference for the supplied incident_id
--   (surrogate_key)
--
-- {End Of Comments}
--
Function GET_INCIDENT_REFERENCE (p_incident_id in  number) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_person_reported_date_time >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Performs cross attribute vatidation on person_reported_by, report_date,
--   report_time.
--
-- {End Of Comments}
--
--
procedure chk_person_reported_date_time
  (p_incident_id           in    per_work_incidents.incident_id%TYPE
  ,p_incident_date         in    per_work_incidents.incident_date%TYPE
  ,p_incident_time         in    per_work_incidents.incident_time%TYPE
  ,p_person_reported_by    in    per_work_incidents.person_reported_by%TYPE
  ,p_report_date           in    per_work_incidents.report_date%TYPE
  ,p_report_time           in    per_work_incidents.report_time%TYPE
  ,p_business_group_id     in    per_all_people_f.business_group_id%TYPE
  ,p_object_version_number in    per_work_incidents.object_version_number%TYPE);
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_notified_hsrep_and_date >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Performs cross attribute vatidation on notified_hsrep_id, notified_hsrep_date.
--
-- {End Of Comments}
--
--
procedure chk_notified_hsrep_and_date
  (p_incident_id           in    per_work_incidents.incident_id%TYPE
  ,p_incident_date         in    per_work_incidents.incident_date%TYPE
  ,p_notified_hsrep_id     in    per_work_incidents.notified_hsrep_id%TYPE
  ,p_notified_hsrep_date   in    per_work_incidents.notified_hsrep_date%TYPE
  ,p_business_group_id     in    per_all_people_f.business_group_id%TYPE
  ,p_object_version_number in    per_work_incidents.object_version_number%TYPE);
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_notified_rep_org_date >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Performs cross attribute vatidation on notified_rep_org_id, notified_rep_id
--   and notified_rep_date.
--
-- {End Of Comments}
--
--
procedure chk_notified_rep_org_date
  (p_incident_id           in    per_work_incidents.incident_id%TYPE
  ,p_incident_date         in    per_work_incidents.incident_date%TYPE
  ,p_notified_rep_org_id   in    per_work_incidents.notified_rep_org_id%TYPE
  ,p_notified_rep_id       in    per_work_incidents.notified_rep_id%TYPE
  ,p_notified_rep_date     in    per_work_incidents.notified_rep_date%TYPE
  ,p_business_group_id     in    per_all_people_f.business_group_id%TYPE
  ,p_object_version_number in    per_work_incidents.object_version_number%TYPE);
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_osha_numbers >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure inserts a row into per_us_osha_numbers table, with
-- next_value = 1, for each US Business Group, for the year starting
-- from 1900 until the EOT (4712).
--
-- {End Of Comments}
--
--
procedure create_osha_numbers
    (p_number_of_workers in number default 1,
     p_current_worker    in number default 1);
end per_inc_bus;

 

/
