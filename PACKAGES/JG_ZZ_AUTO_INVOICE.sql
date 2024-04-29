--------------------------------------------------------
--  DDL for Package JG_ZZ_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_AUTO_INVOICE" AUTHID CURRENT_USER as
/* $Header: jgzzrais.pls 120.3.12010000.2 2009/08/13 14:23:07 rsaini ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

FUNCTION put_error_message (p_app_short_name     IN VARCHAR2,
                            p_mssg_name          IN VARCHAR2,
                            p_interface_line_id  IN VARCHAR2,
                            p_invalid_value      IN VARCHAR2)
RETURN  BOOLEAN;

FUNCTION put_error_message (
                            p_interface_line_id  IN NUMBER,
                            p_message_text       IN VARCHAR2,
                            p_invalid_value      IN VARCHAR2)
RETURN  BOOLEAN;

FUNCTION put_error_message1 (
 	                             p_app_short_name     IN VARCHAR2,
 	                             p_mssg_name          IN VARCHAR2,
 	                             p_interface_line_ref IN VARCHAR2,
 	                             p_invalid_value      IN VARCHAR2)
RETURN BOOLEAN;

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
 |    30-JUL-99   Asada Mizuru  Created.                                      |
 |                                                                            |
 *----------------------------------------------------------------------------*/
  FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER;

END JG_ZZ_AUTO_INVOICE;

/
