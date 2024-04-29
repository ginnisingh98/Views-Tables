--------------------------------------------------------
--  DDL for Package JL_BR_AP_BALANCE_MAINTENANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AP_BALANCE_MAINTENANCE" AUTHID CURRENT_USER AS
/* $Header: jlbrpbms.pls 115.5 2003/04/01 18:34:43 rguerrer ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    JL_BR_AP_BAL_MAINTENANCE                               		      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |									      |
 | PARAMETERS                                                                 |
 |   INPUT                                                 		      |
 |                                                                            |
 |   OUTPUT                                                		      |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |    20-AUG-97  Aniz Buissa Junior       Created                             |
 *----------------------------------------------------------------------------*/
 PROCEDURE jl_br_ap_bal_maintenance(p_request_id 		NUMBER,
				    p_transfer_run_id 		NUMBER,
				    p_start_date 		DATE,
				    p_end_date   		DATE);


END JL_BR_AP_BALANCE_MAINTENANCE;

 

/
