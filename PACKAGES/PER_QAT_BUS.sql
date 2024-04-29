--------------------------------------------------------
--  DDL for Package PER_QAT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QAT_BUS" AUTHID CURRENT_USER as
/* $Header: peqatrhi.pkh 120.0 2005/05/31 16:07:16 appldev noship $ */
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
--    The primary key identified by p_qualification_id
--     already exists.
--
--  In Arguments:
--    p_qualification_id
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
  (p_qualification_id                     in number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_qual_overlap >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure checks that the qualification does not overlap for the
--   same person. The qualification is distinguished by business_group_id,
--   person_id, attendance_id, qualification_id,language and start date.
--   The start date must not overlap an identical qualification for the
--   same person.
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
--   p_language                  The current session language
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
                            p_party_id              in number default null,
                            p_language              in varchar2
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
  ,p_language                             in     varchar2
  ) RETURN varchar2;
--
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
--   For insert, your business rules should be executed from this procedure
--   and should ideally (unless really necessary) just be straight procedure
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_qat_shd.g_rec_type
  ,p_qualification_id             in number
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
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_qat_shd.g_rec_type
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
--   For delete, your business rules should be executed from this procedure
--   and should ideally (unless really necessary) just be straight procedure
--   or function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec              in per_qat_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_translation_globals >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure stores values required by validate_translations.
--
-- Prerequisites:
--   This procedure is called from from the MLS widget enabled forms.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--
-- Developer Implementation Notes:
--
-- Access Status:
--   MLS Widget enabled forms only just before calling validate_translation.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE set_translation_globals
  (p_qualification_type_id          in number
  ,p_person_id                      in number
  ,p_attendance_id                  in number
  ,p_business_group_id              in number
  ,p_object_version_number          in number
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_party_id                       in number
  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< validate_translation >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure performs the validation for the MLS widget.
--
-- Prerequisites:
--   This procedure is called from from the MLS widget.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--
-- Developer Implementation Notes:
--
-- Access Status:
--   MLS Widget Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure validate_translation
  (p_qualification_id               in number
  ,p_language                       in varchar2
  ,p_title                          in varchar2
  ,p_group_ranking                  in varchar2
  ,p_license_restrictions           in varchar2
  ,p_awarding_body                  in varchar2
  ,p_grade_attained                 in varchar2
  ,p_reimbursement_arrangements     in varchar2
  ,p_training_completed_units       in varchar2
  ,p_membership_category            in varchar2
  ,p_qualification_type_id          in number default null
  ,p_person_id                      in number default null
  ,p_attendance_id                  in number default null
  ,p_business_group_id              in number default null
  ,p_object_version_number          in number default null
  ,p_start_date                     in date   default null
  ,p_end_date                       in date   default null
  ,p_party_id                       in number default null
  );

end per_qat_bus;

 

/
