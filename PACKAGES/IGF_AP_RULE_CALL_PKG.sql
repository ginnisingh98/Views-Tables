--------------------------------------------------------
--  DDL for Package IGF_AP_RULE_CALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_RULE_CALL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP11S.pls 120.1 2005/09/08 14:27:35 appldev noship $ */

/* Declaration of package variables */
 pv_item_code VARCHAR2(10);

  /* This function is a wrapper to call the rule validation and to
     get the output subsequently.
   */
    Function Rule_Call (
      p_rule_number 		        IN NUMBER   ,
      p_person_id		        IN NUMBER   ,
      p_base_id			        IN NUMBER   ,
      p_param_6                         IN VARCHAR2 DEFAULT NULL,
      p_param_7                         IN VARCHAR2 DEFAULT NULL,
      p_param_8                         IN VARCHAR2 DEFAULT NULL,
      p_param_9                         IN VARCHAR2 DEFAULT NULL,
      p_param_10                        IN VARCHAR2 DEFAULT NULL,
      p_param_11                        IN VARCHAR2 DEFAULT NULL
     )
      RETURN VARCHAR2;

   /* This function returns the value of the parameter to form
      an sql statement for the rule to work */

END IGF_AP_RULE_CALL_PKG; -- Package Specification IGF_AP_RULE_CALL_PKG

 

/
