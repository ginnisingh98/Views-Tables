--------------------------------------------------------
--  DDL for Package BEN_PDP_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PDP_BUS" AUTHID CURRENT_USER as
/* $Header: bepdprhi.pkh 120.3 2005/11/18 04:28:44 vborkar noship $ */
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_elig_cvrd_dpnt_id already exists.
--
--  In Arguments:
--    p_elig_cvrd_dpnt_id
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
  (p_elig_cvrd_dpnt_id in number) return varchar2;
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
Procedure insert_validate
	(p_rec 			 in ben_pdp_shd.g_rec_type,
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
	(p_rec 			 in ben_pdp_shd.g_rec_type,
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
Procedure delete_validate
	(p_rec 			 in ben_pdp_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date);
--
-- ---------------------------------------------------------------------------
-- |------------------------< crt_ordr_warning >----------------------------|
-- ---------------------------------------------------------------------------
-- Procedure used to create warning messages for crt_ordrs.
--
-- Description
--   This procedure is used to create warning messages for persons
--   not designated as covered dependents but reqired to be covered
--   under court orders.
--
-- Pre Conditions
--   None.
--
-- In Parameters
--   prtt_enrt_rslt_id PK of record being inserted or updated.
--   effective_date effective date
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error handled by procedure
--
-- Access Status
--   Internal table handler use only.
--
procedure crt_ordr_warning
          (p_prtt_enrt_rslt_id       in number
           ,p_effective_date         in date
           ,p_business_group_id      in number);
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< crt_ordr_warning_ss >----------------------------|
-- ---------------------------------------------------------------------------
-- Function is called from SS to check court order(s) for a dependent.
--
Function  crt_ordr_warning_ss
          (p_prtt_enrt_rslt_id   in number
					,p_enrt_cvg_strt_dt    in date
					,p_enrt_cvg_thru_dt    in date
					,p_person_id           in number
					,p_dpnt_person_id      in number
					,p_pl_id               in number
					,p_pl_typ_id           in number
          ,p_effective_date      in date
					,p_per_in_ler_id       in number
          ,p_business_group_id   in number)
Return VARCHAR2;
--
end ben_pdp_bus;

 

/
