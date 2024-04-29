--------------------------------------------------------
--  DDL for Package PAY_PPM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPM_BUS" AUTHID CURRENT_USER as
/* $Header: pyppmrhi.pkh 120.0.12010000.2 2008/12/05 13:44:17 abanand ship $ */
--
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_external_account_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that external account id is valid
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_personal_payment_method_id
--    p_org_payment_method_id
--    p_external_account_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues
--
--  Post Failure:
--    If any of the following cases are true then
--    an application error will be raised and processing is terminated
--
--      a) If related payment type is magnetic tape and external account id is
--         null
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_external_account_id
(p_personal_payment_method_id    in
 pay_personal_payment_methods_f.personal_payment_method_id%TYPE
,p_org_payment_method_id         in
 pay_personal_payment_methods_f.org_payment_method_id%TYPE
,p_external_account_id           in number
,p_effective_date                in date
,p_object_version_number         in
 pay_personal_payment_methods_f.object_version_number%TYPE
);
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updatetable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   (business_group_id, personal_payment_method_id, assignment_id or
--    org_payment_method_id)
--   have been altered.
--
-- {End Of Comments}
Procedure check_non_updateable_args(p_rec in pay_ppm_shd.g_rec_type
                                   ,p_effective_date in date);
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_priority  >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that a priority is valid.
--
--  Pre-conditions:
--    Must be an integer
--
--  In Arguments:
--    p_priority
--    p_personal_payment_method_id
--    p_org_payment_method_id
--    p_assignment_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues
--
--  Post Failure:
--    If the priority is not valid ie:
--      a) it is null or
--      b) If the balance type related to the person's Personal Payment Method
--         is Remunerative and
--         PRIORITY is not an integer between 1 and 99 or
--      c) If the balance type related to the person's Personal Payment Method
--         is Non_Remunerative and
--         PRIORITY is not 1 or
--      d) If the balance type related to the person's Personal Payment Method
--         is Remunerative and
--         PRIORITY is not unique between VALIDATION_START_DATE and
--                                        VALIDATION_END_DATE
--    then an application error will be raised and processing is terminated
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_priority
(p_priority                      in
 pay_personal_payment_methods_f.priority%TYPE
,p_personal_payment_method_id    in
 pay_personal_payment_methods_f.personal_payment_method_id%TYPE
,p_org_payment_method_id         in
 pay_personal_payment_methods_f.org_payment_method_id%TYPE
,p_assignment_id                 in
 pay_personal_payment_methods_f.assignment_id%TYPE
,p_run_type_id                 in
 pay_personal_payment_methods_f.run_type_id%TYPE
,p_effective_date                in date
,p_object_version_number         in
 pay_personal_payment_methods_f.object_version_number%TYPE
,p_validation_start_date         in date
,p_validation_end_date           in date
);
--  ---------------------------------------------------------------------------
--  |---------------------<  chk_amount_percent  >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks that amount and percentage are valid.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_amount
--    p_percentage
--    p_personal_payment_method_id
--    p_org_payment_method_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    Processing continues
--
--  Post Failure:
--    If any of the following cases are true then
--    an application error will be raised and processing is terminated
--
--      a) the balance type related to the persons personal payment method is
--         non-remunerative and the amount is not null
--
--      b) the balance type related to the persons personal payment method is
--         non-remunerative and the percentage is not 100
--
--      c) the percentage is not null and the amount is not null
--
--      d) the percentage is null and the amount is null
--
--      e) the amount is less than 0
--
--      f) the percentage is not between 0 and 100
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_amount_percent
(p_amount                        in
 pay_personal_payment_methods_f.amount%TYPE
,p_percentage                    in
 pay_personal_payment_methods_f.percentage%TYPE
,p_personal_payment_method_id    in
 pay_personal_payment_methods_f.personal_payment_method_id%TYPE
,p_org_payment_method_id         in
 pay_personal_payment_methods_f.org_payment_method_id%TYPE
,p_effective_date                in  date
,p_object_version_number         in
 pay_personal_payment_methods_f.object_version_number%TYPE
);
--  ---------------------------------------------------------------------------
--  |-------------------<  chk_org_payment_method_id  >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the org_payment_method_id entered by carrying
--    out the following:
--	- check that the organisation payment method is valid for the
--	  related payment type
--    Note this is an insert only procedure.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_business_group_id
--    p_personal_payment_method_id
--    p_org_payment_method_id
--    p_assignment_id
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If the org_payment_method_id is valid then
--    processing continues
--
--  Post Failure:
--    If any of the following cases are true then
--    an application error will be raised and processing is terminated
--
--      a) the organization payment method is not valid for the related payment
--         type where the territory code matches the legislation of the business
--         group or where no territory code is specified (currently just
--         Cash) then
--
--  Access Status:
--    Internal Development Use Only.
--
procedure chk_org_payment_method_id
(p_business_group_id     in number
,p_org_payment_method_id in number
,p_effective_date        in date
);
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_defined_balance_id  >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--  This procedure checks that, if the personal payment method is a
--  garnishment, then both payee id and payee type have been entered.
--  Conversely, if the personal payment method is not a garnishment, the
--  procedure ensures that both payee id and payee type are null.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_org_payment_method_id
--    p_effective_date
--    p_object_version_number
--    p_payee_type
--    p_payee_id
--
--  Post Success:
--    If the personal payment method is a garnishment and both payee id and
--    payee type are not null, then processing continues.
--    If the personal payment method is not a garnishment and both payee id
--    and payee type are null, then processing continues.
--
--  Post Failure:
--    If any of the following cases are true then an application error will
--    be raised and processing terminated:
--
--      a) The personal payment method is a garnishment and either payee id
--         or payee type is null.
--
--      b) The personal payment method is not a garnishment and either payee
--	   id or payee type is not null.
--
--  Access Status:
--    Internal Development Use Only.
--
--  ---------------------------------------------------------------------------
procedure chk_defined_balance_id
(p_business_group_id          in number
,p_assignment_id              in number
,p_personal_payment_method_id in number
,p_org_payment_method_id      in number
,p_effective_date             in date
,p_object_version_number      in number
,p_payee_type                 in varchar2
,p_payee_id                   in number
);
--  ---------------------------------------------------------------------------
--  |-----------------<  return_effective_end_date >--------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the value of the proposed new effective_end_date
--    depending on the existence of future rows in
--    pay_personal_payment_methods_f which have the same priority
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--
--  Post Success:
--
--    If any rows exist on pay_personal_payment_methods_f in the future
--    that have the same priority, for the same assignment, as p_priority then
--
--    a) If the earliest future effective start date -1 is less than
--       p_validation_end_date then
--       p_validation_end_date must be reset to the earliest
--       future effective start date - 1
--
--    b) The earliest future effective start date -1 is not less than
--       p_validation_end_date then
--       p_validation_end_date remains the same
--
--    If no future rows exist on pay_personal_payment_methods_f in the future
--    that have the same priority as p_priority then
--    p_validation_end_date remains the same
--
--  Post Failure:
--
--  Access Status:
--    Internal Development Use Only.
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function return_effective_end_date
  (p_datetrack_mode               in      varchar2,
   p_effective_date               in      date,
   p_personal_payment_method_id   in      number,
   p_org_payment_method_id        in      number,
   p_assignment_id                in      number,
   p_run_type_id                  in      number    default null,
   p_priority                     in      number,
   p_business_group_id            in      number,
   p_payee_id                     in      number    default null,
   p_payee_type                   in      varchar2  default null,
   p_validation_start_date        in      date,
   p_validation_end_date          in      date)
  return date;
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
-- In Arguments:
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
--   For insert, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
	(p_rec 			 in pay_ppm_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date);
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
-- In Arguments:
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
--   For update, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
	(p_rec 			 in pay_ppm_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date);
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
-- In Arguments:
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
--   For delete, your business rules should be coded within this procedure and
--   should ideally (unless really necessary) just be straight procedure or
--   function calls. Try and avoid using conditional branching logic.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
	(p_rec 			 in pay_ppm_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date);
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific personal payment
--
--  Prerequisites:
--    The personal payment identified by p_personal_payment_method_id already exists.
--
--  In Arguments:
--    p_personal_payment_method_id
--
--  Post Success:
--    If the personal payment is found this function will return the personal payment's business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the personal payment does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_personal_payment_method_id    in number
  ) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   second last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in pay_ppm_shd.g_rec_type
  );
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Development Use Only.
--
-- ---------------------------------------------------------------------------
procedure chk_df
(p_rec in pay_ppm_shd.g_rec_type
);
--
end pay_ppm_bus;

/
