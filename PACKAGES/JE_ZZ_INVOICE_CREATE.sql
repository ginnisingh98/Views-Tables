--------------------------------------------------------
--  DDL for Package JE_ZZ_INVOICE_CREATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_ZZ_INVOICE_CREATE" AUTHID CURRENT_USER as
/* $Header: jezzrics.pls 120.0 2004/10/26 01:36:19 shnaraya ship $ */

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
 |    24 Jan 04 Shyamala        Created.                                      |
 *----------------------------------------------------------------------------*/
  FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER;

END JE_ZZ_INVOICE_CREATE;

 

/
