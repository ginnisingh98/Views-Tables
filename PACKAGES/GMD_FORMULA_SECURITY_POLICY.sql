--------------------------------------------------------
--  DDL for Package GMD_FORMULA_SECURITY_POLICY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FORMULA_SECURITY_POLICY" AUTHID CURRENT_USER AS
/* $Header: GMDFSPLS.pls 115.9 2004/03/26 08:41:46 kkillams noship $ */

	PROCEDURE formula_activate_upd (
	active_formula_ind in	varchar2  );

  	PROCEDURE add_formula_hdr_sel;
	PROCEDURE add_formula_hdr_ins;
	PROCEDURE add_formula_hdr_upd;
	PROCEDURE add_formula_dtl_sel;
	PROCEDURE add_formula_dtl_ins;
	PROCEDURE add_formula_dtl_upd;

	PROCEDURE drop_formula_hdr_sel;
	PROCEDURE drop_formula_hdr_ins;
	PROCEDURE drop_formula_hdr_upd;
	PROCEDURE drop_formula_dtl_sel;
	PROCEDURE drop_formula_dtl_ins;
	PROCEDURE drop_formula_dtl_upd;

	PROCEDURE add_recipe_sel;
	PROCEDURE add_recipe_ins;
	PROCEDURE add_recipe_upd;
	PROCEDURE drop_recipe_sel;
	PROCEDURE drop_recipe_ins;
	PROCEDURE drop_recipe_upd;

	PROCEDURE add_recipe_vr_sel;
	PROCEDURE add_recipe_vr_ins;
	PROCEDURE add_recipe_vr_upd;
	PROCEDURE drop_recipe_vr_sel;
	PROCEDURE drop_recipe_vr_ins;
	PROCEDURE drop_recipe_vr_upd;


	PROCEDURE add_recipe_step_sel;
	PROCEDURE add_recipe_step_ins;
	PROCEDURE add_recipe_step_upd;
	PROCEDURE drop_recipe_step_sel;
	PROCEDURE drop_recipe_step_ins;
	PROCEDURE drop_recipe_step_upd;

END;


 

/
