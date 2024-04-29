--------------------------------------------------------
--  DDL for Package AR_CUSTOM_PARAMS_HOOK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CUSTOM_PARAMS_HOOK_PKG" AUTHID CURRENT_USER AS
/*$Header: ARCUSPARS.pls 120.0.12010000.1 2010/03/02 07:00:57 appldev noship $*/



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
 * ARGUMENTS - NONE                                                          *
 *                                                                           *
 * RETURNS      NONE                    				                             *
 * NOTES -                                                                   *
 * MODIFICATION HISTORY -  23/02/2010 - Created by RVIRIYAL	     	           *
 *                                                                           *
 +===========================================================================*/

PROCEDURE populateCAOwnerAttributes;

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

PROCEDURE populateContingencyAttributes;

END AR_CUSTOM_PARAMS_HOOK_PKG;

/
