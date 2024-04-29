--------------------------------------------------------
--  DDL for Package AR_CMGT_PARAMS_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_PARAMS_HOOK_PKG" AUTHID CURRENT_USER AS
/*$Header: ARCMGPARS.pls 120.0.12010000.1 2010/03/02 09:20:21 appldev noship $*/


/*===========================================================================+
 * PROCEDURE                                                                 *
 *     get_ocm_custom_param_value()                                               *
 * DESCRIPTION                                                               *
 *   This procedure is invoked from Credit Management Workflow Engine before *
 * invoking the rules engine to retrive the value for a customer parameter.  *
 * This method is invoked for each of the custom parameter under Rule Object *
 * Name OCM_CREDIT_ANALYST_ASSGN and retrive its value. Value retrived is the*
 * out parameter for this procedure. Once the parameter value is retrived    *
 * in the calling Credit Management Workflow Engine,custom parameter and its *
 * values are set in the Rules Engine to evaluate the rules.                 *
 *                                                                           *
 * SCOPE - PUBLIC                                                            *
 * ARGUMENTS                                                                 *
 *              IN  : p_credit_request_id                                    *
 *              IN  : p_custom_param_name                                    *
 *              OUT : p_custom_param_value                                   *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * NOTES -                                                                   *
 * MODIFICATION HISTORY -  23/02/2010 - Created by RVIRIYAL	     	           *
 *                                                                           *
 +===========================================================================*/
 PROCEDURE get_ocm_custom_param_value ( P_CREDIT_REQUEST_ID    IN  NUMBER
                                       ,P_CUSTOM_PARAM_NAME    IN  VARCHAR2
                                       ,P_CUSTOM_PARAM_VALUE   OUT NOCOPY VARCHAR2);

END AR_CMGT_PARAMS_HOOK_PKG;

/
