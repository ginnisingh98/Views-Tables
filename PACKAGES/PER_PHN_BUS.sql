--------------------------------------------------------
--  DDL for Package PER_PHN_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PHN_BUS" AUTHID CURRENT_USER as
/* $Header: pephnrhi.pkh 120.0 2005/05/31 14:21:23 appldev noship $ */
--
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code  varchar2(150) default null;
g_phone_id         number        default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_date_from >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    DATE_FROM is mandatory
--    DATE_FROM must be less than DATE_TO
--
--  Pre-conditions :
--    Format for date_from and date_to must be correct
--
--  In Arguments :
--    p_phone_id
--    p_date_from
--    p_date_to
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_date_from
  (p_phone_id           in    per_phones.phone_id%TYPE
  ,p_date_from		in	per_phones.date_from%TYPE
  ,p_date_to		in	per_phones.date_to%TYPE
  ,p_object_version_number in per_phones.object_version_number%TYPE
    );
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_phone_type >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Validates that an phone type exists in table hr_lookups
--    where lookup_type is 'PHONE_TYPE' and enabled_flag is 'Y' and
--    effective_date is between the active dates (if they are not null).
--	Phone type is mandatory.
--    Phone number is mandatory.
--
--  Pre-conditions:
--    Effective_date must be valid.
--
--  In Arguments:
--    p_phone_id
--    p_phone_type
--    p_phone_number
--    p_effective_date
--    p_object_version_number
--
--  Post Success:
--    If a row does exist in hr_lookups for the given phone code then
--    processing continues.
--
--  Post Failure:
--    If a row does not exist in hr_lookups for the given phone code then
--    an application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_phone_type
  (p_phone_id               in per_phones.phone_id%TYPE
  ,p_phone_type             in per_phones.phone_type%TYPE
  ,p_phone_number           in per_phones.phone_number%TYPE
  ,p_effective_date         in date
  ,p_object_version_number  in per_phones.object_version_number%TYPE
  );
--
--  ---------------------------------------------------------------------------
--  |-------------------------<  chk_phone_type_limits  >---------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Only allow one primary home and one primary work per person at a given
--    time.
--
--  Pre-conditions:
--
--  In Arguments:
--    p_phone_id
--    p_date_from
--    p_date_to
--    p_phone_type
--    p_parent_id
--    p_parent_table
--    p_party_id    -- HR/TCA merge
--    p_object_version_number
--
--  Post Success:
--    Processing continues.
--
--  Post Failure:
--    An application error will be raised and processing is terminated.
--
--  Access Status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_phone_type_limits
  (p_phone_id               in per_phones.phone_id%TYPE
  ,p_date_from              in per_phones.date_from%TYPE
  ,p_date_to                in per_phones.date_to%TYPE
  ,p_phone_type             in per_phones.phone_type%TYPE
  ,p_parent_id              in per_phones.parent_id%TYPE
  ,p_parent_table           in per_phones.parent_table%TYPE
  ,p_party_id               in per_phones.party_id%TYPE -- HR/TCA merge
  ,p_object_version_number  in per_phones.object_version_number%TYPE);
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_parent_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    If PARENT_TABLE = 'PER_ALL_PEOPLE_F', verify that the value in PARENT_ID
--    is in the per_all_people_f table.  This is just a temporary solution which
--    will require re-thinking when new parent tables are added because we
--    probably dont want to hard code all these.
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_phone_id
--    p_parent_id
--    p_parent_table
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_parent_id
  (p_phone_id           in    per_phones.phone_id%TYPE
  ,p_parent_id	      in    per_phones.parent_id%TYPE
  ,p_parent_table	      in    per_phones.parent_table%TYPE
  ,p_object_version_number in per_phones.object_version_number%TYPE
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
Procedure insert_validate(p_rec in out nocopy per_phn_shd.g_rec_type
                         ,p_effective_date in date
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
Procedure update_validate(p_rec in per_phn_shd.g_rec_type
                          ,p_effective_date in date
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
Procedure delete_validate(p_rec in per_phn_shd.g_rec_type);
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< return_legislation_code >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure returns the business group id of the parent row.
--
-- Pre Conditions:
--   That the phone row has been created.
--
-- In Parameters:
--   Primary key for the phones table.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An error is raised.
--
-- Developer Implementation Notes:
--   This return_legislation_code function is slightly different from others in
--   that the cursor does a join on the parent table (in this case the parent
--   table is always PER_ALL_PEOPLE_F and retrieves the business_group_id from
--   there.
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
function return_legislation_code
  (p_phone_id              in number
  ) return varchar2;
--

function return_legislation_parent
  (p_parent_id		in number
  ,p_parent_table   	in varchar2
  ) return varchar2;

end per_phn_bus;

 

/
