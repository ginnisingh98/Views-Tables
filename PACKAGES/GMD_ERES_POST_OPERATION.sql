--------------------------------------------------------
--  DDL for Package GMD_ERES_POST_OPERATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_ERES_POST_OPERATION" AUTHID CURRENT_USER AS
/* $Header: GMDPSOPS.pls 120.2 2005/10/07 02:43:07 srsriran noship $ */


PROCEDURE set_formula_status(p_formula_id IN NUMBER,
                             p_from_status IN VARCHAR2,
                             p_to_status IN VARCHAR2);

PROCEDURE set_formulation_spec_status(p_formulation_spec_id IN NUMBER,
                                      p_from_status IN VARCHAR2,
                                      p_to_status IN VARCHAR2);

PROCEDURE set_operation_status(p_oprn_id IN NUMBER,
                               p_from_status IN VARCHAR2,
                               p_to_status IN VARCHAR2);

PROCEDURE set_routing_status(p_routing_id IN NUMBER,
                             p_from_status IN VARCHAR2,
                             p_to_status IN VARCHAR2);

PROCEDURE set_recipe_status(p_recipe_id IN NUMBER,
                            p_from_status IN VARCHAR2,
                            p_to_status IN VARCHAR2,
                            p_create_validity IN NUMBER DEFAULT 0);

PROCEDURE set_validity_status(p_validity_rule_id IN NUMBER,
                              p_from_status IN VARCHAR2,
                              p_to_status IN VARCHAR2);

PROCEDURE set_auto_recipe_status(p_formula_id  IN NUMBER,
                                 p_orgn_id     IN NUMBER,
				 p_from_status IN VARCHAR2,
                                 p_to_status   IN VARCHAR2);
-- Bug number 4479101
PROCEDURE set_substitution_status(p_substitution_id IN NUMBER,
                                  p_from_status     IN VARCHAR2,
                                  p_to_status       IN VARCHAR2);

END GMD_ERES_POST_OPERATION;

 

/
