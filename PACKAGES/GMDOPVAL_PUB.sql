--------------------------------------------------------
--  DDL for Package GMDOPVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMDOPVAL_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPOPVS.pls 120.0 2005/05/25 18:41:15 appldev noship $ */

/* Error Return Code Constants: */

GMD_OPRN_EXISTS           CONSTANT INTEGER := -30; /* Duplicate Operation.*/
GMD_INV_OPRN_CLASS        CONSTANT INTEGER := -31; /*Operation class is not valid.*/
GMD_ACTV_INVALID          CONSTANT INTEGER := -32; /*Invalid Activity.*/
GMD_BAD_RESOURCE          CONSTANT INTEGER := -33; /*Invalid resource.*/
GMD_CMPNT_CLASS_ERR       CONSTANT INTEGER := -34; /*Invalid cost component class.*/
GMD_COST_ANALYSIS_ERR     CONSTANT INTEGER := -35; /*Invalid Cost analysis code.*/

/* Functions and Procedures*/

FUNCTION check_duplicate_oprn(poprn_no IN VARCHAR2,
                              poprn_vers IN NUMBER,
                              pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER;
FUNCTION check_oprn_class(poprn_class IN VARCHAR2, pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER;
FUNCTION check_activity(pactivity IN VARCHAR2, pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER;
FUNCTION check_resource(presource IN VARCHAR2, pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER;
FUNCTION check_cost_cmpnt_cls(pcost_cmpntcls_code IN VARCHAR2, pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER;
FUNCTION check_cost_analysis(pcost_analysis_code IN VARCHAR2, pcalledby_form IN VARCHAR2 DEFAULT 'F') RETURN NUMBER;
END;


 

/
