--------------------------------------------------------
--  DDL for Package CEP_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CEP_STANDARD" AUTHID CURRENT_USER AS
/* $Header: ceseutls.pls 120.10.12010000.2 2008/08/10 14:28:08 csutaria ship $ */
/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                           |
 |    debug             - Display text message if in debug mode               |
 |    enable_debug      - Enable run time debugging                           |
 |    disable_debug     - Disable run time debugging                          |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    Generate standard debug information sending it to dbms_output so that   |
 |    the client tool can log it for the user.                                |
 |                                                                            |
 | REQUIRES                                                                   |
 |    line_of_text           The line of text that will be displayed.         |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |    26 Mar 93  Nigel Smith      Created                                     |
 |    28 Jul 99  K Adams          Added option to either send it to a file or |
 |				  dbms_output. 				      |
 |                                If debug path and file name are passed,     |
 |                                it writes to the path/file_name instead     |
 |                                of dbms_output.                             |
 |                                                                            |
 *----------------------------------------------------------------------------*/
--
G_patch_level 	VARCHAR2(30) := '11.5.CE.J';
G_debug Varchar2(1) := 'N' ; -- Bug 7125240

FUNCTION return_patch_level RETURN VARCHAR2;

procedure debug( line in varchar2 ) ;
procedure enable_debug( path_name in varchar2 default NULL,
			file_name in varchar2 default NULL);
procedure disable_debug( display_debug in varchar2 );
--

FUNCTION Get_Window_Session_Title(p_org_id number default NULL,
				 p_legal_entity_id number default NULL) RETURN VARCHAR2;
--
function get_effective_date(p_bank_account_id NUMBER,
			p_trx_code VARCHAR2,
			p_receipt_date DATE)  RETURN DATE;

/**
 * PROCEDURE debug_msg_stack
 *
 * DESCRIPTION
 *     Show debug messages on message stack.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_msg_count                    Message count in message stack.
 *     p_msg_data                     Message data if message count is 1.
 *
 * MODIFICATION HISTORY
 *
 *   15-SEP-2004    Xin Wang            Created.
 *
 */
PROCEDURE debug_msg_stack(p_msg_count   IN NUMBER,
                          p_msg_data    IN VARCHAR2);


  /*=======================================================================+
   | PUBLIC PRECEDURE sql_error                                            |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This procedure sets the error message and raise an exception        |
   |   for unhandled sql errors.                                           |
   |   Called by other routines.                                           |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_routine                                                         |
   |     p_errcode                                                         |
   |     p_errmsg                                                          |
   +=======================================================================*/
   PROCEDURE sql_error(p_routine    IN VARCHAR2,
                       p_errcode    IN NUMBER,
                       p_errmsg     IN VARCHAR2);


  /*=======================================================================+
   | PUBLIC PRECEDURE get_umx_predicate                                    |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This procedure return where clause predicate generated from UMX API |
   |   to apply BA access security or BAT security                         |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_object_name: CEBAT, CEBAC                                                         |
   +=======================================================================*/
  FUNCTION get_umx_predicate(p_object_name   IN VARCHAR2) RETURN VARCHAR2;

  /*=======================================================================+
   | PUBLIC PRECEDURE check_ba_security	                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   This function checks if user has access to the input LE based on    |
   |   Bank account Access or Bank Account Transfer security defined in UMX|
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_le_id: Legal Entity ID 					   |
   |     p_security_mode: CEBAT, CEBAC                                       |
   |   OUT:								   |
   |	 1: if user has access					           |
   |     0: otherwise 							   |
   +=======================================================================*/
  FUNCTION check_ba_security ( p_le_id 	NUMBER,
			       p_security_mode	VARCHAR2) RETURN NUMBER;

  FUNCTION get_conversion_rate ( p_ledger_id 	NUMBER,
			       p_currency_code	VARCHAR2,
			       p_exchange_date  DATE,
			       p_exchange_rate_type  VARCHAR2) RETURN NUMBER;

  PROCEDURE init_security;

  PROCEDURE init_security_baui;

END CEP_STANDARD;

/
