--------------------------------------------------------
--  DDL for Package PER_PRT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PRT_BUS" AUTHID CURRENT_USER as
/* $Header: peprtrhi.pkh 120.1 2006/02/13 14:11:14 vbala noship $ */
--
-- ----------------------------------------------------------------------------
-- cascade delete rquires objective record structure
-- ----------------------------------------------------------------------------
--
-- flemonni start of changes 10-Aug-98
-- modifications to implement cascade delete logic
--
  TYPE r_objpr_rec
  IS RECORD
    ( performance_rating_id	NUMBER
    , object_version_number	NUMBER
    );
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |---------------------------< Get_PR_Data >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Retrieves the performance rating and object version number of the
--   given objective_id
--
-- Pre Conditions:
--   This procedure is called from the per_objectives api
--
-- In Parameters:
--   An objective id
--
-- Post Success:
--   a performance rating and object version number are returned
--
-- Post Failure:
--   no values are returned
--
-- Developer Implementation Notes:
--
-- Access Status:
--   HR Development Use only
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
FUNCTION Get_PR_Data
  ( p_objective_id	IN per_objectives.objective_id%TYPE
  )
RETURN r_objpr_rec;
-- ----------------------------------------------------------------------------
-- row handler chk_ procedures externalized and modified to ensure
-- correct behaviour (api_updating)
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_appraisal_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
-- comments in package body
--
-- Access Status:
--   HR Development Use Only
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_appraisal_id
  ( p_appraisal_id 	in per_performance_ratings.appraisal_id%TYPE
  , p_performance_rating_id	in
			per_performance_ratings.performance_rating_id%TYPE
  ,p_object_version_number	in
 			per_performance_ratings.object_version_number%TYPE
);
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_objective_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
-- comments in package body
--
-- Access Status:
--   HR Development Use Only
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_objective_id
  ( p_objective_id 		in per_performance_ratings.objective_id%TYPE
  , p_appraisal_id		in per_performance_ratings.appraisal_id%TYPE
  , p_performance_rating_id	in
			per_performance_ratings.performance_rating_id%TYPE
  ,p_object_version_number	in
 			per_performance_ratings.object_version_number%TYPE
);
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_performance_level_id >-------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
-- comments in package body
--
-- Access Status:
--   HR Development Use Only
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_performance_level_id
  ( p_performance_rating_id	in
  	per_performance_ratings.performance_rating_id%TYPE
  , p_performance_level_id 	in
        per_performance_ratings.performance_level_id%TYPE
  , p_appraisal_id		in
        per_performance_ratings.appraisal_id%TYPE
  ,p_object_version_number	in
        per_performance_ratings.object_version_number%TYPE);
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
--   A Pl/Sql record structure.
--   The effective date.
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
Procedure insert_validate(p_rec in per_prt_shd.g_rec_type, p_effective_date in date);
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
--   A Pl/Sql record structure.
--   The effective date.
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
Procedure update_validate(p_rec in per_prt_shd.g_rec_type, p_effective_date in date);
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
Procedure delete_validate(p_rec in per_prt_shd.g_rec_type);
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
--   the primary key of the table (per_performance_ratings)
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
         p_performance_rating_id        in   number)
         return  varchar2;
--
--
end per_prt_bus;

 

/
