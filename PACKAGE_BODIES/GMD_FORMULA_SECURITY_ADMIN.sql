--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_SECURITY_ADMIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_SECURITY_ADMIN" AS
/* $Header: GMDFSADB.pls 115.18 2003/03/18 16:45:28 txdaniel noship $ */


PROCEDURE add_formula_security IS
    begin
 	gmd_formula_security_policy.add_formula_hdr_sel;
	gmd_formula_security_policy.add_formula_hdr_ins;
	gmd_formula_security_policy.add_formula_hdr_upd;
	gmd_formula_security_policy.add_formula_dtl_sel;
	gmd_formula_security_policy.add_formula_dtl_ins;
	gmd_formula_security_policy.add_formula_dtl_upd;
	gmd_formula_security_policy.add_recipe_sel;
	gmd_formula_security_policy.add_recipe_ins;
	gmd_formula_security_policy.add_recipe_upd;
	-- gmd_formula_security_policy.add_recipe_vr_sel;
	gmd_formula_security_policy.add_recipe_vr_ins;
	gmd_formula_security_policy.add_recipe_vr_upd;
	gmd_formula_security_policy.add_recipe_step_sel;
	gmd_formula_security_policy.add_recipe_step_ins;
	gmd_formula_security_policy.add_recipe_step_upd;

        /* BEGIN BUG#2736082 V. Ajay Kumar */
        /* Removed the reference to apps */
	   gmd_formula_security_policy.formula_activate_upd ('Y');
	/* END BUG#2736082 */
	commit;
    end;


PROCEDURE drop_formula_security IS
    begin
 	gmd_formula_security_policy.drop_formula_hdr_sel;
	gmd_formula_security_policy.drop_formula_hdr_ins;
	gmd_formula_security_policy.drop_formula_hdr_upd;
	gmd_formula_security_policy.drop_formula_dtl_sel;
	gmd_formula_security_policy.drop_formula_dtl_ins;
	gmd_formula_security_policy.drop_formula_dtl_upd;
	gmd_formula_security_policy.drop_recipe_sel;
	gmd_formula_security_policy.drop_recipe_ins;
	gmd_formula_security_policy.drop_recipe_upd;
	-- gmd_formula_security_policy.drop_recipe_vr_sel;
	gmd_formula_security_policy.drop_recipe_vr_ins;
	gmd_formula_security_policy.drop_recipe_vr_upd;
	gmd_formula_security_policy.drop_recipe_step_sel;
	gmd_formula_security_policy.drop_recipe_step_ins;
	gmd_formula_security_policy.drop_recipe_step_upd;

	/* BEGIN BUG#2736082 V. Ajay Kumar */
        /* Removed the reference to apps */
	gmd_formula_security_policy.formula_activate_upd ('N');
	/* END BUG#2736082 */
	commit;
    end;


END gmd_formula_security_admin;



/
