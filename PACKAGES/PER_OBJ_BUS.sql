--------------------------------------------------------
--  DDL for Package PER_OBJ_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_OBJ_BUS" AUTHID CURRENT_USER as
/* $Header: peobjrhi.pkh 120.4.12010000.1 2008/07/28 05:04:18 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code      varchar2(150) default null;
g_objective_id          number        default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< Externalized chk_ procedures >------------------|
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |------------------------< chk_appraisal >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body:  must always be checked api_updating or not
--
-- ACCESS STATUS
--  Internal HR Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure chk_appraisal
(p_appraisal_id		     in      per_objectives.appraisal_id%TYPE
,p_business_group_id	     in	     per_objectives.business_group_id%TYPE
);
-- ----------------------------------------------------------------------------
-- |------------------------< chk_owned_by_person >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of Comments}
-- see body:  must always be checked api_updating or not
--
-- ACCESS STATUS
--  Internal HR Development Use Only
--
-- {End of Comments}
-- ----------------------------------------------------------------------------
procedure chk_owned_by_person
(p_owning_person_id          in      per_objectives.owning_person_id%TYPE
,p_business_group_id	     in	     per_objectives.business_group_id%TYPE
,p_appraisal_id		     in	     per_objectives.appraisal_id%TYPE
,p_effective_date	     in	     date
);
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
Procedure insert_validate(p_rec in per_obj_shd.g_rec_type
			 ,p_effective_date in date
                         ,p_weighting_over_100_warning   out nocopy boolean
                         ,p_weighting_appraisal_warning  out nocopy boolean
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
Procedure update_validate(p_rec in per_obj_shd.g_rec_type
			 ,p_effective_date in date
                         ,p_weighting_over_100_warning   out nocopy boolean
                         ,p_weighting_appraisal_warning  out nocopy boolean
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
Procedure delete_validate(p_rec in per_obj_shd.g_rec_type);
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< return_legislation_code >-------------------------|
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
--   the primary key of the table (per_objectives)
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
-- ----------------------------------------------------------------------------
--
function return_legislation_code
  (p_objective_id               in per_objectives.objective_id%TYPE
  ) return varchar2;
--
end per_obj_bus;

/
