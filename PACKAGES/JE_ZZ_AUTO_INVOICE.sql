--------------------------------------------------------
--  DDL for Package JE_ZZ_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_ZZ_AUTO_INVOICE" AUTHID CURRENT_USER as
/* $Header: jezzrais.pls 115.1 2002/03/15 16:02:25 pkm ship     $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | FUNCTION                                                                   |
 |    validate_gdff                                                           |
 |                                                                            |
 | DESCRIPTION                                                                |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   INPUT                                                                    |
 |      p_request_id            Number   -- Concurrent Request id             |
 |                                                                            |
 |   RETURNS                                                                  |
 |      0                       Number   -- Validations Failed                |
 |      1                       Number   -- Validation Succeeded              |
 |                                                                            |
 | HISTORY                                                                    |
 |    24 Jan 01  Tim Dexter        Created.                                   |
 *----------------------------------------------------------------------------*/
  FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER;

END JE_ZZ_AUTO_INVOICE;

 

/
