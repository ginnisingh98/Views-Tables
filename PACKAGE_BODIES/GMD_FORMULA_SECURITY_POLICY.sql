--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_SECURITY_POLICY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_SECURITY_POLICY" AS
/* $Header: GMDFSPLB.pls 120.1 2005/09/14 05:05:21 kshukla noship $ */

  PROCEDURE formula_activate_upd (
    active_formula_ind IN	varchar2  )
	IS

        l_active_formula_ind varchar2(1);

	begin
          l_active_formula_ind := active_formula_ind;
		update gmd_vpd_security
		set active_formula_ind = l_active_formula_ind;
          commit;
	end;

  PROCEDURE add_formula_hdr_sel IS
  BEGIN
 	dbms_rls.add_policy (
		'gmd',
		'fm_form_mst_b',
		'gmd_formula_hdr_sel',
    		'apps',
    		'gmd_security_policy.secure_formula_sel',
		'select',
		TRUE,
		TRUE);
  END;
  PROCEDURE add_formula_hdr_ins IS
  BEGIN
 	dbms_rls.add_policy (
		'gmd',
		'fm_form_mst_b',
		'gmd_formula_hdr_ins',
    		'apps',
    		'gmd_security_policy.secure_formula_ins',
		'insert',
		TRUE,
		TRUE);
  END;
  PROCEDURE add_formula_hdr_upd IS
  BEGIN
 	dbms_rls.add_policy (
		'gmd',
		'fm_form_mst_b',
		'gmd_formula_hdr_upd',
    		'apps',
    		'gmd_security_policy.secure_formula_upd',
		'update',
		TRUE,
		TRUE);
  END;

PROCEDURE add_formula_dtl_sel IS
/****************************************************************************************************
 Change History
 Who       When         What
 kkillams  16-FEB-04    Predicate function has been replaced gmd_security_policy.secure_formula_sel with
                        gmd_security_policy.secure_formula_dtl_sel w.r.t. bug 3344335.
 ******************************************************************************************************/
    begin
 	dbms_rls.add_policy (
		'gmd',
		'fm_matl_dtl',
		'gmd_formula_dtl_sel',
    		'apps',
    		'gmd_security_policy.secure_formula_dtl_sel',
		'select',
		TRUE,
		TRUE);
    end;


  PROCEDURE add_formula_dtl_ins IS
    begin
 	dbms_rls.add_policy (
		'gmd',
		'fm_matl_dtl',
		'gmd_formula_dtl_ins',
    		'apps',
    		'gmd_security_policy.secure_formula_dtl_ins',
		'insert',
		TRUE,
		TRUE);
    end;

/****************************************************************************************************
 Change History
 Who       When         What
 kkillams  30-MAR-04    Predicate function has been replaced gmd_security_policy.secure_formula_dtl_upd with
                        gmd_security_policy.secure_formula_dtl_ins w.r.t. bug 3344335.
 ******************************************************************************************************/
PROCEDURE add_formula_dtl_upd IS
    begin
 	dbms_rls.add_policy (
		'gmd',
		'fm_matl_dtl',
		'gmd_formula_dtl_upd',
    		'apps',
    		'gmd_security_policy.secure_formula_dtl_ins',
		'update',
		TRUE,
		TRUE);
    end;


PROCEDURE drop_formula_hdr_sel IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'fm_form_mst_b',
		'gmd_formula_hdr_sel');
    end;

PROCEDURE drop_formula_hdr_ins IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'fm_form_mst_b',
		'gmd_formula_hdr_ins');
    end;

PROCEDURE drop_formula_hdr_upd IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'fm_form_mst_b',
		'gmd_formula_hdr_upd');
    end;

PROCEDURE drop_formula_dtl_sel IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'fm_matl_dtl',
		'gmd_formula_dtl_sel');
    end;

PROCEDURE drop_formula_dtl_ins IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'fm_matl_dtl',
		'gmd_formula_dtl_ins');
    end;

    PROCEDURE drop_formula_dtl_upd IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'fm_matl_dtl',
		'gmd_formula_dtl_upd');
    end;
    PROCEDURE add_recipe_sel IS
    /****************************************************************************************************
     Change History
     Who       When         What
     kkillams  02-MAR-04    Predicate function has been replaced gmd_security_policy.secure_formula_sel with
                            gmd_security_policy.secure_formula_dtl_sel w.r.t. bug 3344335.
    ******************************************************************************************************/
    BEGIN
 	dbms_rls.add_policy (
		'gmd',
		'gmd_recipes_b',
		'gmd_recipe_sel',
    		'apps',
                'gmd_security_policy.secure_formula_dtl_sel',
		'select',
		TRUE,
		TRUE);
    END;
    PROCEDURE add_recipe_ins IS
    /****************************************************************************************************
     Change History
     Who       When         What
     kkillams  02-MAR-04    Predicate function has been replaced gmd_security_policy.secure_formula_sel with
                            gmd_security_policy.secure_formula_dtl_sel w.r.t. bug 3344335.
    ******************************************************************************************************/
    BEGIN
 	dbms_rls.add_policy (
		'gmd',
		'gmd_recipes_b',
		'gmd_recipe_ins',
    		'apps',
    		'gmd_security_policy.secure_formula_dtl_sel',
		'insert',
		TRUE,
		TRUE);
    END;
   PROCEDURE add_recipe_upd IS
   /****************************************************************************************************
    Change History
    Who       When         What
    kkillams  02-MAR-04    Predicate function has been replaced gmd_security_policy.secure_formula_sel with
                           gmd_security_policy.secure_formula_dtl_sel w.r.t. bug 3344335.
    ******************************************************************************************************/
    BEGIN
 	dbms_rls.add_policy (
		'gmd',
		'gmd_recipes_b',
		'gmd_recipe_upd',
    		'apps',
    		'gmd_security_policy.secure_formula_dtl_sel',
		'update',
		TRUE,
		TRUE);
   END;


  PROCEDURE add_recipe_step_sel IS
  BEGIN
 	dbms_rls.add_policy (
		'gmd',
		'gmd_recipe_step_materials',
		'gmd_recipe_step_sel',
    		'apps',
    		'gmd_security_policy.secure_recipe_sel',
		'select',
		TRUE,
		TRUE);
  END;
  PROCEDURE add_recipe_step_ins IS
/****************************************************************************************************
 Change History
 Who       When         What
 kkillams  16-FEB-04    Predicate function has been replaced gmd_security_policy.secure_recipe_ins with
                        gmd_security_policy.secure_recipe_sel w.r.t. bug 3344335.
 ******************************************************************************************************/
  BEGIN
 	dbms_rls.add_policy (
		'gmd',
		'gmd_recipe_step_materials',
		'gmd_recipe_step_ins',
    		'apps',
    		'gmd_security_policy.secure_recipe_sel',
		'insert',
		TRUE,
		TRUE);
  END;
  PROCEDURE add_recipe_step_upd IS
  BEGIN
 	dbms_rls.add_policy (
		'gmd',
		'gmd_recipe_step_materials',
		'gmd_recipe_step_upd',
    		'apps',
    		'gmd_security_policy.secure_recipe_sel',
		'update',
		TRUE,
		TRUE);
  END;
  PROCEDURE add_recipe_vr_sel IS
  BEGIN
 	dbms_rls.add_policy (
		'gmd',
		'gmd_recipe_validity_rules',
		'gmd_recipe_vr_sel',
    		'apps',
    		'gmd_security_policy.secure_recipe_sel',
		'select',
		TRUE,
		TRUE);
  END;
  PROCEDURE add_recipe_vr_ins IS
/****************************************************************************************************
 Change History
 Who       When         What
 kkillams  09-MAR-04    Predicate function has been replaced gmd_security_policy.secure_recipe_upd with
                        gmd_security_policy.secure_recipe_sel w.r.t. bug 3344335.
 ******************************************************************************************************/
  BEGIN
 	dbms_rls.add_policy (
		'gmd',
		'gmd_recipe_validity_rules',
		'gmd_recipe_vr_ins',
    		'apps',
    		'gmd_security_policy.secure_recipe_sel',
		'insert',
		TRUE,
		TRUE);
  END;
  PROCEDURE add_recipe_vr_upd IS
  BEGIN
 	dbms_rls.add_policy (
		'gmd',
		'gmd_recipe_validity_rules',
		'gmd_recipe_vr_upd',
    		'apps',
    		'gmd_security_policy.secure_recipe_sel',
		'update',
		TRUE,
		TRUE);
  END;
PROCEDURE drop_recipe_sel IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'gmd_recipes_b',
		'gmd_recipe_sel');
    end;

PROCEDURE drop_recipe_ins IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'gmd_recipes_b',
		'gmd_recipe_ins');
    end;

PROCEDURE drop_recipe_upd IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'gmd_recipes_b',
		'gmd_recipe_upd');
    end;

PROCEDURE drop_recipe_step_sel IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'gmd_recipe_step_materials',
		'gmd_recipe_step_sel');
    end;

PROCEDURE drop_recipe_step_ins IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'gmd_recipe_step_materials',
		'gmd_recipe_step_ins');
    end;

PROCEDURE drop_recipe_step_upd IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'gmd_recipe_step_materials',
		'gmd_recipe_step_upd');
    end;

PROCEDURE drop_recipe_vr_sel IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'gmd_recipe_validity_rules',
		'gmd_recipe_vr_sel');
    end;

PROCEDURE drop_recipe_vr_ins IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'gmd_recipe_validity_rules',
		'gmd_recipe_vr_ins');
    end;

PROCEDURE drop_recipe_vr_upd IS
    begin
 	dbms_rls.drop_policy (
		'gmd',
		'gmd_recipe_validity_rules',
		'gmd_recipe_vr_upd');
    end;
END gmd_formula_security_policy;


/
