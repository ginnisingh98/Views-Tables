--------------------------------------------------------
--  DDL for Package PAY_ROM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ROM_BUS" AUTHID CURRENT_USER as
/* $Header: pyromrhi.pkh 120.0 2005/05/29 08:24:02 appldev noship $ */
--
-- ---------------------------------------------------------------------------
-- |----------------------< set_security_group_id >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
--  Description:
--    Sets the security_group_id in CLIENT_INFO for the appropriate business
--    group context.
--    It is only valid to call this procedure when the primary key
--    is within a buisiness group context.
--
--  Prerequisites:
--    The primary key identified by p_run_type_org_method_id
--     already exists.
--
--  In Arguments:
--    p_run_type_org_method_id
--
--
--  Post Success:
--    The security_group_id will be set in CLIENT_INFO.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--    An error is also raised when the primary key data is outside
--    of a buisiness group context.
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
procedure set_security_group_id
  (p_run_type_org_method_id               in number
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
--    The primary key identified by p_run_type_org_method_id
--     already exists.
--
--  In Arguments:
--    p_run_type_org_method_id
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
  (p_run_type_org_method_id               in     number
  ) RETURN varchar2;
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_run_type_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the run_type_id enterend by carrying out
--    the following:
--      - check that the run_type_id exists
--      - check that the following rules apply:
--
--    Mode     Run Type     Available Components             Resulting method
--    ------   -----------  -------------------------------  ---------------
--    USER     USER         USER, STARTUP, GENERIC           USER
--    USER     STARTUP      USER, STARTUP, GENERIC           USER
--    USER     GENERIC      USER, STARTUP, GENERIC           USER
--    STARTUP  USER         This mode cannot access USER     Error
--                          run types
--    STARTUP  STARTUP      STARTUP, GENERIC                 STARTUP
--    STARTUP  GENERIC      STARTUP, GENERIC                 STARTUP
--    GENERIC  USER         This mode cannot access USER     Error
--                          run types
--    GENERIC  STARTUP      This mode cannot access STARTUP  Error
--                          run types
--    GENERIC  GENERIC      GENERIC                          GENERIC
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_run_type_org_method_id
--    p_run_type_id
--    p_effective_date
--    p_business_group_id
--    p_legislation_code
--
--  Post Success:
--    If the run_type_id is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) run_type_id does not exist
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_run_type_id
  (p_run_type_org_method_id in number
  ,p_run_type_id            in number
  ,p_effective_date         in date
  ,p_business_group_id      in number
  ,p_legislation_code       in varchar2);
--
--  ---------------------------------------------------------------------------
--  |---------------------< chk_org_payment_method_id >-----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the org_payment_method_id entered by carrying out
--    the following:
--      - check that the org_payment_method_id exists
--      - check that the following rules apply:
--
--    Mode     Org Pay. Method   Available Components           Resulting usage
--    ------   ---------------   -----------------------------  ---------------
--    USER     USER              USER, STARTUP, GENERIC         USER
--    STARTUP  USER              This mode cannot access USER   Error
--    GENERIC  USER              This mode cannot access USER   Error
--
--    NB. Only USER defined organization payment methods exist.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_run_type_org_method_id
--    p_org_payment_method_id
--    p_effective_date
--    p_business_group_id
--
--  Post Success:
--    If the org_payment_method_id is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) org_payment_method_id does not exist
--     b) Either STARTUP or GENERIC mode is used.
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_org_payment_method_id
  (p_run_type_org_method_id in number
  ,p_org_payment_method_id  in number
  ,p_effective_date         in date
  ,p_business_group_id      in number);
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_priority  >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the priority enterend by carrying out the
--    following:
--      - check that the priority is unique for a particular run_type/
--        org_payment_method combination
--      - check that the priority is between 1 and 99
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_run_type_org_method_id
--    p_org_payment_method_id
--    p_run_type_id
--    p_priority
--    p_business_group_id
--    p_legislation_code
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success:
--    If the priority is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) it is not unique
--     b) it is not between 1 and 99
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_priority
  (p_run_type_org_method_id in number
  ,p_org_payment_method_id  in number
  ,p_run_type_id            in number
  ,p_priority               in number
  ,p_business_group_id      in number
  ,p_legislation_code       in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date);
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  chk_amount_percent  >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the amount and percent enterend by carrying out
--    the following:
--      - check amount is >0
--      - check that only one of amount and percent are null
--      - if amount is not null check it has the correct money format
--      - if percent is not null check it has the correct format with 2 decimal
--        places
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_percent
--    p_amount
--    p_org_payment_method_id
--
--  Post Success:
--    If amount and percent are valid then processing continues
--
--  Post Failure:
--    If either percent or amount are invalid then an application error will be
--    raised and processing is terminated:
--
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_percent_amount
  (p_percent               in number
  ,p_amount                in number
  ,p_org_payment_method_id in number);
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_bg_leg_code >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Checks the validity of the business_group_id and legislation code entered
--    by enforcing the following:
--
--    Mode            Business Group ID      Legislation Code
--    -------------   --------------------   ------------------------------
--    USER            NOT NULL               NULL
--    STARTUP         NULL                   NOT NULL
--    GENERIC         NULL                   NULL
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    p_business_group_id
--    p_legislation_code
--
--  Post Success:
--    If the combination is valid then processing continues
--
--  Post Failure:
--    If any of the following cases are true then an application error will be
--    raised and processing is terminated:
--
--     a) Combination of business_group_id and legislation_code is anything other
--     than detailed above.
--
--  Access Status:
--   Internal Row Handler Use Only.
--
--  ---------------------------------------------------------------------------
PROCEDURE chk_bg_leg_code
  (p_business_group_id     in number
  ,p_legislation_code      in varchar2);
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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_rom_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_rom_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                   in pay_rom_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  );
--
end pay_rom_bus;

 

/
