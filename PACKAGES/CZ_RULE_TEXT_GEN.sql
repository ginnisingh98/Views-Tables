--------------------------------------------------------
--  DDL for Package CZ_RULE_TEXT_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_RULE_TEXT_GEN" AUTHID CURRENT_USER AS
/* $Header: czruletxts.pls 120.0 2007/04/14 06:30:53 jhanda ship $ */




---------------------------------------------------------------------------------------
/*
 * Public API for Model Conversion.
 * @param p_devl_project_id
 *		       This is the model id for model for which the rule text needs to be generated
 * @param p_rule_id
 *		       This is the rule id for rule for which the rule text needs to be generated
 */

PROCEDURE parse_rules(p_devl_project_id IN NUMBER, p_rule_id IN NUMBER DEFAULT NULL) ;
---------------------------------------------------------------------------------------

END;

/
