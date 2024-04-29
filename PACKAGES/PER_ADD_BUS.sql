--------------------------------------------------------
--  DDL for Package PER_ADD_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ADD_BUS" AUTHID CURRENT_USER as
/* $Header: peaddrhi.pkh 120.0.12010000.1 2008/07/28 04:03:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |           Global Definitions - Internal Table Handler Use Only            |
-- ----------------------------------------------------------------------------
--
g_called_from_form     boolean := false;     -- Global flag set to true by forms
--                                              code calling the RH. If true,
--                                              flexfield validation is not
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
--   A Pl/Sql record structure.
--   effective_date.
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
  (p_rec               in out nocopy per_add_shd.g_rec_type
  ,p_effective_date    in date
  ,p_validate_county   in boolean default true
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
--   This private procedure is called from upd
--  110.10  07-Jan-2000 mmillmor         externalized procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--   effective_date.
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
  (p_rec                in out nocopy per_add_shd.g_rec_type
  ,p_effective_date     in date
  ,p_prflagval_override in boolean      default false
  ,p_validate_county    in boolean      default true
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
Procedure delete_validate(p_rec in out nocopy per_add_shd.g_rec_type);
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific address
--
--  Prerequisites:
--    The address identified by p_address_id already exists.
--
--  In Arguments:
--    p_address_id
--
--  Post Success:
--    If the address is found this function will return the address's business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the address does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_address_id              in number
  ) return varchar2;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_date_comb >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--
--    Validates date_to/date_from for a primary address so that it
--    does not overlap with the date range of another primary address.
--
--    Validates that the date range of a non-primary co-exists with the
--    date range of a primary address.
--
--    Validate that primary addresses are contiguous.
--
--    Validates that the address_type for an address (primary or non)
--    is unique for a person with the given date range.
--
--  Pre-conditions:
--    Format of p_date_from and p_date_to must be correct.
--
--  In Arguments:
--    p_address_id
--    p_address_type
--    p_primary_flag
--    p_date_from
--    p_date_to
--    p_person_id
--    p_object_version_number
--    p_party_id  -- HR/TCA merge
--
--  Post Success:
--    If no overlaps occur with either the address_type or primary flag then
--    processing continues.
--
--    If all non-primary addresses exist during the date range of one or
--    more contiguous primary addresses then processing continues.
--
--    If all primary addresses are contiguous then processing continues.
--
--  Post Failure:
--    If the date_to/date_from values cause a primary address to overlap
--    within the date range of another primary address for the same person,
--    or the address_type for either a primary or non-primary address is
--    not uniques within a given date range for a person then an application
--    error is raised and processing is terminated.
--
--    If an insert/update of a non-primary address is atempted where the
--    date range of the non-primary address does not co-exist with that of
--    a primary address then an application error is raised and processing
--    is terminated.
--
--    If an insert/update of a primary address causes the primary address
--    pattern to be non-contiguous then an application error is raised and
--    processing is terminated.
--
--  Access status:
--    Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_date_comb
  (p_address_id            in     per_addresses.address_id%TYPE
  ,p_address_type          in     per_addresses.address_type%TYPE
  ,p_date_from             in     per_addresses.date_from%TYPE
  ,p_date_to               in     per_addresses.date_to%TYPE
  ,p_person_id             in     per_addresses.person_id%TYPE
  ,p_primary_flag          in     per_addresses.primary_flag%TYPE
  ,p_object_version_number in     per_addresses.object_version_number%TYPE
  ,p_prflagval_override    in     boolean      default false
  ,p_party_id              in     per_addresses.party_id%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< set_called_from_form >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to set the global g_called_from_form which controls
--   the execution of the df data validation. When set the df validation is
--   bypassed.
--
-- Pre Conditions:
--   This is a public function
--
-- In Parameters:
--
-- Post Success:
--   The global variable is set.
--
-- Post Failure:
--   No failure condition exists.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure set_called_from_form
        ( p_flag    in boolean );
--
end per_add_bus;

/
