--------------------------------------------------------
--  DDL for Package BEN_PPL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PPL_BUS" AUTHID CURRENT_USER as
/* $Header: bepplrhi.pkh 120.0.12000000.1 2007/01/19 21:49:44 appldev noship $ */
--
--  ---------------------------------------------------------------------------
--  |--------------------------< chk_delete_allowed >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Check that a potential life event can be deleted.
--
--  Prerequisites:
--    The record must exist in the database.
--
--  In Arguments:
--  p_ptnl_ler_for_per_id
--  p_ptnl_ler_for_per_stat_cd
--  p_business_group_id
--  p_person_id
--  p_ler_id
--  p_lf_evt_ocrd_dt
--
--  Post Success:
--    If the value is not found this function will return true.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function chk_delete_allowed
  (p_ptnl_ler_for_per_id      in number,
   p_ptnl_ler_for_per_stat_cd in varchar2,
   p_business_group_id        in number,
   p_person_id                in number,
   p_ler_id                   in number,
   p_lf_evt_ocrd_dt           in date) return boolean;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_ptnl_ler_for_per_id already exists.
--
--  In Arguments:
--    p_ptnl_ler_for_per_id
--
--  Post Success:
--    If the value is found this function will return the values business
--    group legislation code.
--
--  Post Failure:
--    An error is raised if the value does not exist.
--
--  Access Status:
--    Internal Development Use Only.
--
function return_legislation_code
  (p_ptnl_ler_for_per_id in number) return varchar2;
--
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
Procedure insert_validate(p_rec in ben_ppl_shd.g_rec_type
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
Procedure update_validate(p_rec in ben_ppl_shd.g_rec_type
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
-- Prerequisites:
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ben_ppl_shd.g_rec_type
                         ,p_effective_date in date);
--
end ben_ppl_bus;

 

/
