--------------------------------------------------------
--  DDL for Package IRC_IRF_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IRF_BUS" AUTHID CURRENT_USER as
/* $Header: irirfrhi.pkh 120.1 2008/04/16 07:34:00 vmummidi noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_source_criteria >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_source_criteria
  (p_source_criteria       in   irc_referral_info.source_criteria1%TYPE
  ,p_source_criteria_index in   number
  ,p_effective_date        in   date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_source_type >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_source_type
  (p_source_type       in   irc_referral_info.source_type%TYPE
  ,p_effective_date        in   date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_object >---------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_object
  (p_rec                   in   irc_irf_shd.g_rec_type
  ,p_effective_date        in   date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_party_id >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_party_id
  (p_party_id in irc_referral_info.object_id%TYPE
  ,p_effective_date in Date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_person_id >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_person_id
  (p_person_id in irc_referral_info.object_id%TYPE
  ,p_effective_date in Date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_assignment_id >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_assignment_id
  (p_assignment_id    in  irc_referral_info.object_id%type
  ,p_effective_date in Date
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
  (p_rec                   in irc_irf_shd.g_rec_type
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
  (p_rec                     in irc_irf_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  );
--
end irc_irf_bus;

/
