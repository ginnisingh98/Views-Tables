--------------------------------------------------------
--  DDL for Package HRI_BPL_FAST_FORMULA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_FAST_FORMULA_UTIL" AUTHID CURRENT_USER AS
/* $Header: hribuffl.pkh 120.1.12000000.2 2007/04/12 12:08:17 smohapat noship $ */

TYPE formula_param_type IS TABLE OF VARCHAR2(240) INDEX BY VARCHAR2(30);

PROCEDURE run_formula
      (p_formula_id      IN NUMBER,
       p_input_tab       IN formula_param_type,
       p_output_tab      OUT NOCOPY formula_param_type);

FUNCTION fetch_bg_formula_id(p_formula_name       IN VARCHAR2,
                             p_business_group_id  IN NUMBER)
    RETURN NUMBER;

FUNCTION fetch_bg_formula_id(p_formula_name       IN VARCHAR2,
                             p_business_group_id  IN NUMBER,
                             p_formula_type_name  IN VARCHAR2)
    RETURN NUMBER;

FUNCTION fetch_setup_formula_id(p_formula_name  IN VARCHAR2)
    RETURN NUMBER;

FUNCTION fetch_seeded_formula_id(p_formula_name  IN VARCHAR2)
    RETURN NUMBER;

FUNCTION fetch_formula_id
   (p_formula_name        IN VARCHAR2,
    p_business_group_id   IN NUMBER,
    p_bg_formula_name     IN VARCHAR2 DEFAULT NULL,
    p_setup_formula_name  IN VARCHAR2 DEFAULT NULL,
    p_seeded_formula_name IN VARCHAR2 DEFAULT NULL,
    p_try_bg_formula      IN VARCHAR2 DEFAULT 'Y',
    p_try_setup_formula   IN VARCHAR2 DEFAULT 'Y',
    p_try_seeded_formula  IN VARCHAR2 DEFAULT 'Y')
      RETURN NUMBER;

END hri_bpl_fast_formula_util;

 

/
