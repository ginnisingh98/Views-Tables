--------------------------------------------------------
--  DDL for Package GHR_PDC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDC_BUS" AUTHID CURRENT_USER as
/* $Header: ghpdcrhi.pkh 120.0.12010000.4 2009/05/27 06:33:20 utokachi noship $ */
--
PROCEDURE CHK_GRADE_LEVEL(p_pd_classification_id IN
					ghr_pd_classifications.pd_classification_id%TYPE,
				  p_grade_level IN ghr_pd_classifications.grade_level%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number);

PROCEDURE CHK_PAY_PLAN(p_pd_classification_id IN
					ghr_pd_classifications.pd_classification_id%TYPE,
				  p_pay_plan IN ghr_pd_classifications.pay_plan%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number);

PROCEDURE CHK_OCCUPATIONAL_CODE(p_pd_classification_id IN
					ghr_pd_classifications.pd_classification_id%TYPE,
				  p_occupational_code IN 												ghr_pd_classifications.occupational_code%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number);

PROCEDURE CHK_CLASS_GRADE_BY(p_pd_classification_id IN
					ghr_pd_classifications.pd_classification_id%TYPE,
				  p_class_grade_by IN ghr_pd_classifications.class_grade_by%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number);

PROCEDURE CHK_NON_UPDATEABLE_ARGS(p_rec IN ghr_pdc_shd.g_rec_type);




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
Procedure insert_validate(p_rec in ghr_pdc_shd.g_rec_type);
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
Procedure update_validate(p_rec in ghr_pdc_shd.g_rec_type);
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
Procedure delete_validate(p_rec in ghr_pdc_shd.g_rec_type);
--
end ghr_pdc_bus;

/
