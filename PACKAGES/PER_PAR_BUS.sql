--------------------------------------------------------
--  DDL for Package PER_PAR_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PAR_BUS" AUTHID CURRENT_USER as
/* $Header: peparrhi.pkh 120.1 2007/06/20 07:48:33 rapandi ship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_ procedures >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
-- Description:
--   Following chk procedures externalized for use with web pages
--   so body for details
--
-- Access Status:
--   HR Development USe only
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_participation_in_id >--------------------|
-- ----------------------------------------------------------------------------
procedure chk_participation_in_id
(p_participation_in_table    in
	per_participants.participation_in_table%TYPE
,p_participation_in_column   in
	per_participants.participation_in_column%TYPE
,p_participation_in_id       in
	per_participants.participation_in_id%TYPE
,p_business_group_id         in
	per_participants.business_group_id%TYPE
);
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_person_id >------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_person_id
(p_participant_id            in      per_participants.participant_id%TYPE
,p_object_version_number     in      per_participants.object_version_number%TYPE
,p_person_id                 in      per_participants.person_id%TYPE
,p_business_group_id         in      per_participants.business_group_id%TYPE
,p_participation_in_table    in
	per_participants.participation_in_table%TYPE
,p_participation_in_column   in
	per_participants.participation_in_column%TYPE
,p_participation_in_id       in      per_participants.participation_in_id%TYPE
,p_effective_date            in      date
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
Procedure insert_validate(p_rec in per_par_shd.g_rec_type
			  ,p_effective_date in date);
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
Procedure update_validate(p_rec in per_par_shd.g_rec_type
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
Procedure delete_validate(p_rec in per_par_shd.g_rec_type);
--
-- ----------------------------------------------------------------------------
-- |----------------------< return_legislation_code >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function gets the legislation code
--
-- Pre Conditions:
--   This private procedure will be called from the user hook procedures.
--
-- In Parameters:
--   the primary key of the table (per_participants)
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If the legislation code is not found then it errors out
--
-- Developer Implementation Notes:
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
--
Function return_legislation_code (
         p_participant_id        in   number)
         return  varchar2;
--
--
end per_par_bus;

/
