--------------------------------------------------------
--  DDL for Package JL_BR_AR_BALANCE_MAINTENANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_BALANCE_MAINTENANCE" AUTHID CURRENT_USER AS
/* $Header: jlbrrbms.pls 115.3 2003/04/01 18:34:25 rguerrer ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    JL_BR_AR_BAL_MAINTENANCE                               		      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |									      |
 | PARAMETERS                                                                 |
 |   INPUT                                                 		      |
 |     p_posting_control_id	Number -- Posting Control Id                  |
 |                                                                            |
 |   OUTPUT                                                		      |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |    28-AUG-97  Aniz Buissa Junior       Created                             |
 *----------------------------------------------------------------------------*/
 PROCEDURE jl_br_ar_bal_maintenance (
				      par_posting_control_id	IN NUMBER
						);

END JL_BR_AR_BALANCE_MAINTENANCE;

 

/
