--------------------------------------------------------
--  DDL for Package Body AR_CUSTOM_PARAMS_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CUSTOM_PARAMS_HOOK_PKG" AS
/*$Header: ARCUSPARB.pls 120.0.12010000.1 2010/03/02 07:01:10 appldev noship $*/

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
 *     populateCAOwnerAttributes                                             *
 * DESCRIPTION                                                               *
 *   This procedure is invoked from ar_cao_assign_pkg before calling the     *
 *   rules engine. The purpose of the procedure is to calculate the          *
 *   attribute columns. Attribute columns are treated as the param value     *
 *   based on which the custom param rules are evaluated.                    *
 *                                                                           *
 * SCOPE - PUBLIC                                                            *
 * ARGUMENTS - NONE                                                                 *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * NOTES -                                                                   *
 * MODIFICATION HISTORY -  23/02/2010 - Created by RVIRIYAL	     	           *
 *                                                                           *
 +===========================================================================*/

PROCEDURE populateCAOwnerAttributes AS
BEGIN
    IF PG_DEBUG IN ('Y', 'C') THEN
      log('AR_CUSTOM_PARAMS_HOOK_PKG.populateCAOwnerAttributes()+');
    END IF;
    /*
      User needs to write code here to populate Attribute columns
    */
    IF PG_DEBUG IN ('Y', 'C') THEN
      log('AR_CUSTOM_PARAMS_HOOK_PKG.populateCAOwnerAttributes()-');
    END IF;


END;

/*===========================================================================+
 * PROCEDURE                                                                 *
 *     populateContingencyAttributes                                         *
 * DESCRIPTION                                                               *
 *   This procedure is invoked from ar_revenue_management_pvt before calling *
 *   rules engine. The purpose of the procedure is to calculate the          *
 *   attribute columns. Attribute columns are treated as the param value     *
 *   based on which the custom param rules are evaluated.                    *
 *                                                                           *
 * SCOPE - PUBLIC                                                            *
 * ARGUMENTS - NONE                                                          *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * NOTES -                                                                   *
 * MODIFICATION HISTORY -  23/02/2010 - Created by RVIRIYAL	     	           *
 *                                                                           *
 +===========================================================================*/

PROCEDURE populateContingencyAttributes AS
BEGIN
    IF PG_DEBUG IN ('Y', 'C') THEN
      log('AR_CUSTOM_PARAMS_HOOK_PKG.populateContingencyAttributes()+');
    END IF;
    /*
      User needs to write code here to populate Attribute columns
    */
    IF PG_DEBUG IN ('Y', 'C') THEN
      log('AR_CUSTOM_PARAMS_HOOK_PKG.populateContingencyAttributes()-');
    END IF;

END;


END AR_CUSTOM_PARAMS_HOOK_PKG;

/
