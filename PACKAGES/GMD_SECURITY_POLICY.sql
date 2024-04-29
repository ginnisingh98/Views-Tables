--------------------------------------------------------
--  DDL for Package GMD_SECURITY_POLICY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SECURITY_POLICY" AUTHID CURRENT_USER AS
/* $Header: GMDFSPPS.pls 120.0.12010000.1 2008/07/24 09:53:39 appldev ship $ */

    FUNCTION secure_formula_sel(
        obj_schema IN   VARCHAR2,
        obj_name   IN   VARCHAR2)
    RETURN VARCHAR2;

    FUNCTION secure_formula_ins(
        obj_schema IN   VARCHAR2,
        obj_name        VARCHAR2)
    RETURN VARCHAR2;

    FUNCTION secure_formula_upd(
        obj_schema IN   VARCHAR2,
        obj_name        VARCHAR2)
    RETURN VARCHAR2;

    -- Added 2 more dtl level func's
    FUNCTION secure_formula_dtl_ins(
        obj_schema IN   VARCHAR2,
        obj_name        VARCHAR2)
    RETURN VARCHAR2;


 /********************************************************************************
  * Name : secure_formula_dtl_sel
  *
  * Description: This predicate function used for selection from gmd_formula_dtl_sel
  *              table w.r.t. bug no 3344335
  **********************************************************************************/
    FUNCTION secure_formula_dtl_sel(
        obj_schema IN   VARCHAR2,
        obj_name        VARCHAR2)
    RETURN VARCHAR2;

    FUNCTION secure_recipe_sel(
        obj_schema IN   VARCHAR2,
        obj_name        VARCHAR2)
    RETURN VARCHAR2;
    END gmd_security_policy;


/
