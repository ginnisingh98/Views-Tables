--------------------------------------------------------
--  DDL for Package JG_ZZ_INVOICE_CREATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_INVOICE_CREATE" AUTHID CURRENT_USER as
 /* $Header: jgzzrics.pls 115.1 2004/02/06 19:35:17 appradha ship $ */

/*----------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  				  |
 *----------------------------------------------------------------*/

FUNCTION put_error_message (
           p_header_id IN NUMBER
          ,p_line_id IN NUMBER
          ,p_message_text      IN VARCHAR2
          ,p_invalid_value     IN VARCHAR2) RETURN BOOLEAN;


FUNCTION put_error_message (p_app_short_name    IN VARCHAR2
                           ,p_msg_name         IN VARCHAR2
                           ,p_header_id IN NUMBER
                           ,p_line_id IN NUMBER
                           ,p_invalid_value     IN VARCHAR2) RETURN BOOLEAN;

FUNCTION validate_gdff (p_request_id  IN NUMBER) RETURN NUMBER;

END JG_ZZ_INVOICE_CREATE;

 

/
