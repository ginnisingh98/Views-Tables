--------------------------------------------------------
--  DDL for Package PER_QUA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QUA_BUS" AUTHID CURRENT_USER as
/* $Header: pequarhi.pkh 120.0.12010000.1 2008/07/28 05:32:25 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_security_group_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- Set the security_group_id in CLIENT_INFO for the qualification's business
-- group context.
--
-- Prerequisites:
--   None,
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_qualification_id             Yes  Number   Qualification to use for
--                                                deriving the security group
--                                                context.
--
-- Post Success:
--   The security_group_id will be set in CLIENT_INFO.
--
-- Post Failure:
--   An error is raised if the qualification_id does not exist.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
procedure set_security_group_id
  (
   p_qualification_id in per_qualifications.qualification_id%TYPE
  ,p_associated_column1 in varchar2 default null
  );
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
--    The primary key identified by p_qualification_id
--     already exists.
--
--  In Arguments:
--    p_qualification_id
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
  (p_qualification_id                     in     number
  ) RETURN varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_awarded_date >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the awarded date is after the start date and
--   later than or equal to the end date.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id         PK
--   p_awarded_date             status of qualification
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_awarded_date (p_qualification_id      in number,
		            p_awarded_date          in date,
			    p_start_date            in date,
		            p_object_version_number in number);

Procedure chk_awarded_date (p_qualification_id           in number,
                            p_awarded_date               in date,
                            p_start_date                 in date,
                            p_end_date                   in date,
                            p_projected_completion_date  in date,
                            p_object_version_number      in number);

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_fee >------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the fee value is correct. If the fee has been
--   entered then the fee currency must lso be entered, likewise if the fee is
--   blank then the fee currency must also be blank.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id         PK
--   p_fee	                value of fee to take qualification
--   p_fee_currency             currency of fee
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_fee (p_qualification_id      in number,
		   p_fee                   in number,
		   p_fee_currency          in varchar2,
		   p_object_version_number in number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_start_date >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the start date and end date are valid values.
--   The end_date must be after the start_date. The start and end dates must
--   bound all subjects taken and be within the dates of the establishment
--   attendance.
--
-- Bug: 1664055 Starts here.
--   This procedure also checks that the start date is greater than the Date of
--   Birth of the person if date of birth is not null. The start date can be
--   provided only if date of birth is not null.
--
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id         PK
--   p_attendance_id		id of establishment attendance
--   p_start_date               start date of qualification
--   p_end_date                 end date of qualification
--   p_object_version_number    object version number
--   p_effective_date           Effective date
--   p_person_id                id of the person
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_start_date (p_qualification_id      in number,
		          p_attendance_id         in number,
		          p_start_date            in date,
		          p_end_date              in date,
		          p_object_version_number in number,
-- Bug: 1664055 Starts here.
		          p_effective_date        in date,
		          p_person_id    	  in number);
-- Bug: 1664055 Ends here.
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_projected_completion_date--------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the projected completion date is after the
--   start date of the qualification.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id          PK
--   p_start_date                start date of qualification
--   p_projected_completion_date projected completion date.
--   p_object_version_number     object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_projected_completion_date
    (p_qualification_id          in number,
     p_start_date                in date,
     p_projected_completion_date in date,
     p_object_version_number     in number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_qual_overlap >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the qualification does not overlap for the
--   same person. The qualification is distinguished by business_group_id,
--   person_id, attendance_id, qualification_id and start date. The start date
--   must not overlap an identical qualification for the same person.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_qualification_id          PK
--   p_qualification_type_id     id of related qualification type
--   p_person_id                 id of person
--   p_attendance_id             id of related establishment attendance
--   p_business_group_id         id of business group
--   p_start_date                start date of qualification
--   p_end_date                  end date of qualification
--   p_title                     title of course taken
--   p_object_version_number     object version number
--   p_party_id                  id of party -- HR/TCA merge
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_qual_overlap (p_qualification_id      in number,
                            p_qualification_type_id in number,
                            p_person_id             in number,
                            p_attendance_id         in number,
                            p_business_group_id     in number,
                            p_start_date            in date,
                            p_end_date              in date,
                            p_title                 in varchar2,
                            p_object_version_number in number,
                            p_party_id              in number default null
                           );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec            in out nocopy per_qua_shd.g_rec_type,
			  p_effective_date in date);
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
-- Pre Conditions:
--   This private procedure is called from upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec            in out nocopy per_qua_shd.g_rec_type,
			  p_effective_date in date);
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
-- Pre Conditions:
--   This private procedure is called from del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_qua_shd .g_rec_type);
--
end per_qua_bus;

/
