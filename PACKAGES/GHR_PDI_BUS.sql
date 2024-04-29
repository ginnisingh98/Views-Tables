--------------------------------------------------------
--  DDL for Package GHR_PDI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDI_BUS" AUTHID CURRENT_USER as
/* $Header: ghpdirhi.pkh 120.0 2005/05/29 03:28:37 appldev noship $ */

--
-----------------------------<chk_date_to>-----------------------------
--
Procedure chk_date_to(p_position_description_id IN
                      ghr_position_descriptions.position_description_id%TYPE,
		      p_date_from IN DATE,
                      p_date_to IN DATE);

--
-----------------------------<chk_flsa>----------------------------------
--
Procedure chk_flsa(p_position_description_id IN
                                ghr_position_descriptions.position_description_id%TYPE,
		   p_flsa IN ghr_position_descriptions.flsa%TYPE,
		   p_effective_date IN DATE,
		   p_object_version_number IN number);
--
-----------------------------<chk_category>----------------------------------
--
Procedure chk_category(p_position_description_id IN
                                ghr_position_descriptions.position_description_id%TYPE,
		   p_category IN ghr_position_descriptions.category%TYPE,
		   p_effective_date IN DATE,
		   p_object_version_number IN number);
--
-----------------------------<chk_financial_statement>-------------------
--

Procedure chk_financial_statement(p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
				  p_financial_statement IN 										ghr_position_descriptions.financial_statement%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number);



--
-------------------------------< chk_subject_to_ia_action>---------------------
--

Procedure chk_subject_to_ia_action (p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
				  p_sub_to_ia_action IN 											ghr_position_descriptions.subject_to_ia_action %TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number);

--
---------------------------------<chk_position_status>---------------------------
--

Procedure chk_position_status 	(p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
				  p_position_status IN 								    ghr_position_descriptions.position_status%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number);

--
-----------------------------------<chk_position_is>---------------------------------
--

Procedure chk_position_is (p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
			  p_position_is IN ghr_position_descriptions.position_is%TYPE,
			  p_effective_date IN date,
			  p_object_version_number IN number);

--
----------------------------------<chk_position_sensitivity>---------------------------
--

Procedure chk_position_sensitivity(p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
				  p_position_sensitivity IN 										ghr_position_descriptions.position_sensitivity%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number);

--
-----------------------------------<chk_competitive_level>----------------------------
--

Procedure chk_competitive_level(p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
				  p_competitive_level IN ghr_position_descriptions.competitive_level%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number);

--
------------------------------------<chk_career_ladder>--------------------------------
--

Procedure chk_career_ladder(p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
			     p_career_ladder IN ghr_position_descriptions.career_ladder%TYPE,
			     p_effective_date IN date,
			     p_object_version_number IN number);

--
------------------------------------<chk_routing_group_id>---------------------------------
--

Procedure chk_routing_group_id(p_position_description_id	IN
					ghr_position_descriptions.position_description_id%TYPE,
				  p_routing_group_id IN 											ghr_position_descriptions.routing_group_id%TYPE,
				  p_effective_date IN date,
				  p_object_version_number IN number);

--
-------------------------------------<chk_non_updateable_args>-------------------------------
--


Procedure chk_non_updateable_args(p_rec IN ghr_pdi_shd.g_rec_type);


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
Procedure insert_validate(p_rec in ghr_pdi_shd.g_rec_type);
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
Procedure update_validate(p_rec in ghr_pdi_shd.g_rec_type);
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
Procedure delete_validate(p_rec in ghr_pdi_shd.g_rec_type);
--
end ghr_pdi_bus;

 

/
