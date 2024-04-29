--------------------------------------------------------
--  DDL for Package JL_BR_INSCRIPTION_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_INSCRIPTION_NUMBER" AUTHID CURRENT_USER as
/* $Header: jlbrsics.pls 120.2.12010000.1 2008/07/31 04:23:33 appldev ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    validate_inscription_number              			      	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |									      |
 | PARAMETERS                                                                 |
 |   INPUT                                                 		      |
 |      p_inscription_type      VARCHAR2   -- Inscription Type: CPF   = '1'   |
 |						                CGC   = '2'   |
 |								Other = '3'   |
 |      p_inscription_number    VARCHAR2   -- Inscription Number              |
 |      p_inscription_branch    VARCHAR2   -- Inscription Branch              |
 |      p_inscription_digit     VARCHAR2   -- Inscription Digit               |
 |									      |
 |   OUTPUT                                                		      |
 |      p_errbuf          	VARCHAR2 -- Error lookup code  	              |
 |					    (Lookup type = 		      |
 |					        'JLBR_INSCRIPTION_NUM_ERRORS')|
 |      p_retcode         	NUMBER   -- Return Code:		      |
 |					    0 = Validation Succeds            |
 |				           -1 = Validation Fails	      |
 |                                                                            |
 | HISTORY                                                                    |
 |      15-OCT-97   Marcia Toriyama    Created                                |
 *----------------------------------------------------------------------------*/
PROCEDURE validate_inscription_number (
 		        p_inscription_type      	IN     VARCHAR2,
                        p_inscription_number    	IN     VARCHAR2,
                        p_inscription_branch    	IN     VARCHAR2,
 		        p_inscription_digit     	IN     VARCHAR2,
			p_errbuf			IN OUT NOCOPY	VARCHAR2,
			p_retcode			IN OUT NOCOPY	NUMBER   );

END JL_BR_INSCRIPTION_NUMBER;

/
