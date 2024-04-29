--------------------------------------------------------
--  DDL for Package Body GMD_ERES_POST_OPERATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ERES_POST_OPERATION" AS
/* $Header: GMDPSOPB.pls 120.2 2005/10/07 02:43:41 srsriran noship $ */

/*======================================================================
--  PROCEDURE :
--   set_formula_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the formula status
--    to a given status based on the status of the signature.
--   (This is called as a POST-OP API from the approval workflow
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_formula_status (100, 400, 700);
--
--===================================================================== */
PROCEDURE set_formula_status(p_formula_id IN NUMBER,
                             p_from_status IN VARCHAR2,
                             p_to_status IN VARCHAR2) IS
  l_signature_status	VARCHAR2(40);
  l_pending_status	gmd_status.status_code%TYPE;
  l_rework_status	gmd_status.status_code%TYPE;
BEGIN
  l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;
  GMD_ERES_UTILS.set_formula_status (p_formula_id => p_formula_id
                                    ,p_from_status => p_from_status
                                    ,p_to_status => p_to_status
                                    ,p_signature_status => l_signature_status);
END set_formula_status;

/*======================================================================
--  PROCEDURE :
--   set_formulation_spec_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the formulation spec status
--    to a given status based on the status of the signature.
--   (This is called as a POST-OP API from the approval workflow
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_formulation_spec_status (100, 400, 700);
--
--===================================================================== */
PROCEDURE set_formulation_spec_status(p_formulation_spec_id IN NUMBER,
                             	      p_from_status IN VARCHAR2,
                             	      p_to_status IN VARCHAR2) IS
  l_signature_status	VARCHAR2(40);
  l_pending_status	gmd_status.status_code%TYPE;
  l_rework_status	gmd_status.status_code%TYPE;
BEGIN
  l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;
  GMD_ERES_UTILS.set_formulation_spec_status (p_formulation_spec_id => p_formulation_spec_id
                                             ,p_from_status => p_from_status
                                             ,p_to_status => p_to_status
                                             ,p_signature_status => l_signature_status);
END set_formulation_spec_status;

/*======================================================================
--  PROCEDURE :
--   set_operation_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the operation status
--    to a given status based on the status of the signature.
--   (This is called as a POST-OP API from the approval workflow
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_operation_status (100, 400, 700);
--
--===================================================================== */
PROCEDURE set_operation_status(p_oprn_id IN NUMBER,
                               p_from_status IN VARCHAR2,
                               p_to_status IN VARCHAR2) IS
  l_signature_status	VARCHAR2(40);
  l_pending_status	gmd_status.status_code%TYPE;
  l_rework_status	gmd_status.status_code%TYPE;
BEGIN
  l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;
  GMD_ERES_UTILS.set_operation_status (p_oprn_id => p_oprn_id
                                      ,p_from_status => p_from_status
                                      ,p_to_status => p_to_status
                                      ,p_signature_status => l_signature_status);
END set_operation_status;

/*======================================================================
--  PROCEDURE :
--   set_routing_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the routing status
--    to a given status based on the status of the signature.
--   (This is called as a POST-OP API from the approval workflow
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_routing_status (100, 400, 700);
--
--===================================================================== */
PROCEDURE set_routing_status(p_routing_id IN NUMBER,
                             p_from_status IN VARCHAR2,
                             p_to_status IN VARCHAR2) IS
  l_signature_status	VARCHAR2(40);
  l_pending_status	gmd_status.status_code%TYPE;
  l_rework_status	gmd_status.status_code%TYPE;
BEGIN
  l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;
  GMD_ERES_UTILS.set_routing_status   (p_routing_id => p_routing_id
                                      ,p_from_status => p_from_status
                                      ,p_to_status => p_to_status
                                      ,p_signature_status => l_signature_status);
END set_routing_status;

/*======================================================================
--  PROCEDURE :
--   set_recipe_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the recipe status
--    to a given status based on the status of the signature.
--   (This is called as a POST-OP API from the approval workflow
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_recipe_status (100, 400, 700);
--
--===================================================================== */
PROCEDURE set_recipe_status(p_recipe_id IN NUMBER,
                            p_from_status IN VARCHAR2,
                            p_to_status IN VARCHAR2,
                            p_create_validity IN NUMBER) IS
  l_signature_status	VARCHAR2(40);
  l_pending_status	gmd_status.status_code%TYPE;
  l_rework_status	gmd_status.status_code%TYPE;
BEGIN
  l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;
  GMD_ERES_UTILS.set_recipe_status    (p_recipe_id => p_recipe_id
                                      ,p_from_status => p_from_status
                                      ,p_to_status => p_to_status
                                      ,p_signature_status => l_signature_status
                                      ,p_create_validity => p_create_validity);
END set_recipe_status;

/*======================================================================
--  PROCEDURE :
--   set_validity_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the validity status
--    to a given status based on the status of the signature.
--   (This is called as a POST-OP API from the approval workflow
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_validity_status (100, 400, 700);
--
--===================================================================== */
PROCEDURE set_validity_status(p_validity_rule_id IN NUMBER,
                              p_from_status IN VARCHAR2,
                              p_to_status IN VARCHAR2) IS
  l_signature_status	VARCHAR2(40);
  l_pending_status	gmd_status.status_code%TYPE;
  l_rework_status	gmd_status.status_code%TYPE;
BEGIN
  l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;
  GMD_ERES_UTILS.set_validity_status  (p_validity_rule_id => p_validity_rule_id
                                      ,p_from_status => p_from_status
                                      ,p_to_status => p_to_status
                                      ,p_signature_status => l_signature_status);
END set_validity_status;

/*======================================================================
--  PROCEDURE :
--   set_auto_recipe_status
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for setting the formula status
--    to a given status based on the status of the signature.
--   (This is called as a POST-OP API from the approval workflow
--  REQUIREMENTS
--
--  SYNOPSIS:
--    set_formula_status (100, 400, 700);
-- kkillams 01-DEC-2004 set_auto_recipe_status procedure signature is changed  w.r.t. 4004501
--===================================================================== */
PROCEDURE set_auto_recipe_status(p_formula_id  IN NUMBER,
				 p_orgn_id     IN NUMBER,
                                 p_from_status IN VARCHAR2,
                                 p_to_status   IN VARCHAR2) IS
  l_signature_status	VARCHAR2(40);
  l_pending_status	gmd_status.status_code%TYPE;
  l_rework_status	gmd_status.status_code%TYPE;
BEGIN
  l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;
  GMD_ERES_UTILS.set_auto_recipe_status (p_formula_id       => p_formula_id
                                        ,p_orgn_id          => p_orgn_id
                                        ,p_from_status      => p_from_status
                                        ,p_to_status        => p_to_status
                                        ,p_signature_status => l_signature_status);
END set_auto_recipe_status;

-- Bug number 4479101
PROCEDURE set_substitution_status(p_substitution_id IN NUMBER,
                                  p_from_status IN VARCHAR2,
                                  p_to_status IN VARCHAR2)
IS
  l_signature_status	VARCHAR2(40);
BEGIN
  l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;
  GMD_ERES_UTILS.set_substitution_status (P_substitution_id  => P_substitution_id
	                                 ,p_from_status      => p_from_status
	                                 ,p_to_status        => p_to_status
	                                 ,p_signature_status => l_signature_status);
END set_substitution_status;

END GMD_ERES_POST_OPERATION;

/
