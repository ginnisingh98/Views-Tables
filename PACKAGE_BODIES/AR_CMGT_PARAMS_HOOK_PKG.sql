--------------------------------------------------------
--  DDL for Package Body AR_CMGT_PARAMS_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_PARAMS_HOOK_PKG" AS
/*$Header: ARCMGPARB.pls 120.0.12010000.1 2010/03/02 09:20:39 appldev noship $*/

 PG_DEBUG  VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     LOG()                                                                 *
 * DESCRIPTION                                                               *
 *   Writes the message to debug log.                                        *
 * SCOPE - LOCAL                                                             *
 * ARGUMENTS                                                                 *
 *              IN  : p_msg - Message                                        *
 *              OUT : NONE                                                   *
 * RETURNS      NONE                     				                             *
 * ALGORITHM                                                                 *
 *                                                                           *
 * NOTES -                                                                   *
 *                                                                           *
 * MODIFICATION HISTORY -  23/02/2010 - Created by RVIRIYAL	     	           *
 *                                                                           *
 +===========================================================================*/
  PROCEDURE log(p_msg IN VARCHAR2) IS
  BEGIN
    arp_standard.debug('ARCUSPARB' || p_msg || ' : ' || TO_CHAR(SYSDATE,'DD/MM/YY hh:mi:ss'));
  END log;

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
                                       ,P_CUSTOM_PARAM_VALUE   OUT NOCOPY VARCHAR2) IS
  BEGIN
    IF PG_DEBUG IN ('Y', 'C') THEN
      log('AR_CUSTOM_PARAMS_HOOK_PKG.get_ocm_custom_param_value()+');
      log('P_CREDIT_REQUEST_ID : '||P_CREDIT_REQUEST_ID);
      log('P_CUSTOM_PARAM_NAME : '||P_CUSTOM_PARAM_NAME);
    END IF;

      /**
       * Code to retrive the custom param value for a given param name and
       * credit Request Id that needs to be written by the user. Param Value
       * retrived should be set in to the OUT variable  P_CUSTOM_PARAM_VALUE
       * START of the code to retrive the values
      **/





      /**
       *  END of the code to retrive the values.By this point, custom parameter
       *  value is retrived and set as the OUT parameter P_CUSTOM_PARAM_VALUE.
      **/
    IF PG_DEBUG IN ('Y', 'C') THEN
      log('P_CUSTOM_PARAM_VALUE : '||P_CUSTOM_PARAM_VALUE);
      log('AR_CUSTOM_PARAMS_HOOK_PKG.get_ocm_custom_param_value()-');

    END IF;

  END;


END AR_CMGT_PARAMS_HOOK_PKG;

/
