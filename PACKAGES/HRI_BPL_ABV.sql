--------------------------------------------------------
--  DDL for Package HRI_BPL_ABV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_ABV" AUTHID CURRENT_USER AS
/* $Header: hribabv.pkh 115.8 2003/01/13 12:16:13 jtitmas noship $ */

/* Exceptions raised when there is a problem with a fast formula */
ff_not_compiled   EXCEPTION;   -- Raised when a fast formula is not compiled
ff_not_exist      EXCEPTION;   -- Raised when a fast formula does not exist

FUNCTION calc_abv(p_assignment_id     IN NUMBER,
                  p_business_group_id IN NUMBER,
                  p_budget_type       IN VARCHAR2,
                  p_effective_date    IN DATE,
                  p_primary_flag      IN VARCHAR2 := NULL,
                  p_run_formula       IN VARCHAR2 := NULL)
          RETURN NUMBER;

PROCEDURE raise_ff_not_exist(p_bgttyp IN VARCHAR2);

PROCEDURE raise_ff_not_compiled( p_formula_id  IN NUMBER);

PROCEDURE check_ff_name_compiled( p_formula_name     IN VARCHAR2);

PROCEDURE CheckFastFormulaCompiled(p_formula_id  IN NUMBER,
                                   p_bgttyp      IN VARCHAR2);

END hri_bpl_abv;

 

/
