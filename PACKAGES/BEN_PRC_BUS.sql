--------------------------------------------------------
--  DDL for Package BEN_PRC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRC_BUS" AUTHID CURRENT_USER as
/* $Header: beprcrhi.pkh 120.3.12010000.1 2008/07/29 12:53:36 appldev ship $ */
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------

/*

procedure chk_prtt_reimbmt_stat_apprvd
             (p_prtt_reimbmt_rqst_id        in number,
              p_prtt_reimbmt_rqst_stat_cd   in out nocopy  varchar2,
              p_stat_rsn_cd                 in out nocopy  varchar2,
              p_effective_date              in date
             ) ;




procedure chk_incrd_dt(
                      p_prtt_reimbmt_rqst_id  in number,
                      p_pl_id                 in number,
                      p_submitter_person_id   in number,
                      p_incrd_from_dt         in date,
                      p_incrd_to_dt           in date,
                      p_effective_date        in date,
                      p_business_group_id     in number,
                      p_object_version_number in number,
                      p_rqst_amt              in number,
                      p_prtt_reimbmt_rqst_stat_cd   in out nocopy  varchar2,
                      p_stat_rsn_cd                 in out nocopy  varchar2
                     ) ;

*/
--
--  Description:
--    Return the legislation code for a specific primary key value
--
--  Prerequisites:
--    The primary key identified by p_prtt_reimbmt_rqst_id already exists.
--
--  In Arguments:
--    p_prtt_reimbmt_rqst_id
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
  (p_prtt_reimbmt_rqst_id in number) return varchar2;
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
	(p_rec 			 in out nocopy ben_prc_shd.g_rec_type,
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
	(p_rec 			 in out nocopy ben_prc_shd.g_rec_type,
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
	(p_rec 			 in ben_prc_shd.g_rec_type,
	 p_effective_date	 in date,
	 p_datetrack_mode	 in varchar2,
	 p_validation_start_date in date,
	 p_validation_end_date	 in date);



function get_year_balance (
              p_person_id            in   number
             ,p_pgm_id               in   number
             ,p_pl_id                in   number
             ,p_business_group_id    in   number
             ,p_per_in_ler_id        in   number
             ,p_prtt_enrt_rslt_id    in   number
             ,p_effective_date       in   date
             ,p_exp_incurd_dt        in   date
              ) return number  ;
--
end ben_prc_bus;

/
