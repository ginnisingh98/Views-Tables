--------------------------------------------------------
--  DDL for Package PER_CTR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CTR_BUS" AUTHID CURRENT_USER as
/* $Header: pectrrhi.pkh 120.2 2007/02/19 11:58:34 ssutar ship $ */
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
Procedure insert_validate(p_rec in per_ctr_shd.g_rec_type,
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
Procedure update_validate(p_rec in per_ctr_shd.g_rec_type
                         ,p_effective_date in date);
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
Procedure delete_validate(p_rec in per_ctr_shd.g_rec_type);
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific contact relationship
--
--  Prerequisites:
--    The contact relationship identified by p_contact_relationship_id already exists.
--
--  In Arguments:
--    p_contact_relationship_id
--
--  Post Success:
--    If the contact relationship id is found this function will return the  contact's business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the contact does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_contact_relationship_id   in number
  ) return varchar2;
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_sequence_number >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--    Validates that the sequence number for all relationships between two people
--    are the same and that this sequence number is unique for that person_id. ie
--    the person with the contact does not have the same sequence number for a
--    relationship with any other person. It also validates that the sequence
--    number can only be updated from null.
--
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_contact_relationship_id
--    p_sequence_number
--    p_contact_person_id
--    p_person_id
--    p_object_version_number
--
-- Post Success:
--    Processing continues if the sequence number matches the sequence number
--    for any other relationship between these two people and does not match
--    a sequence number for a relationship between the person a different contact.
--    Also continues if updating the sequence number from null.
--
--
-- Post Failure:
--    An Application Error is raised and processing is terminated if the sequence
--    number is not the same as an existing sequence number for a relationship
--    between these two people, or if the sequence number already exists for
--    a relationship between the person and a different contact. Processing is
--    also terminated if an update is attempted where the sequence number is not
--    null.
--
--
-- Access Status:
--    Internal Development use only.
------------------------------------------------------------------------------
procedure chk_sequence_number(p_contact_relationship_id in number,
			      p_sequence_number in number,
			      p_contact_person_id in number,
	                      p_person_id in number,
			      p_object_version_number in number);
--
end per_ctr_bus;

/
