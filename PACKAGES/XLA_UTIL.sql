--------------------------------------------------------
--  DDL for Package XLA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_UTIL" AUTHID CURRENT_USER AS
/* $Header: xlautil.pkh 120.0 2003/11/22 02:29:33 weshen noship $ */

PROCEDURE enable_debug;
PROCEDURE enable_debug(buffer_size	NUMBER);
PROCEDURE enable_debug(path_name in varchar2,
                       file_name in varchar2 default 'DEFAULT');
PROCEDURE disable_debug;
PROCEDURE debug(text	IN VARCHAR2);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_query_context                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Sets the query context in a package variable. The query context can be  |
 |   retreived using the function get_query_context. The get_query_context   |
 |   function is a SQL function that can be used in SQL as well.             |
 |                                                                           |
 |   This procedure is typically used with get_query_context. XLA uses this  |
 |   function to set and get contexts within the View Accounting Lines and   |
 |   Drilldown product views. XLA uses these functions to access the view    |
 |   based on product transaction class(group). This approach is used to     |
 |   improve performance when accessing union views.                         |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |   none                                                                    |
 |                                                                           |
 | ARGUMENTS                                                     	     |
 |   IN   p_context      -- Varchar2(100); E.g AR_TRANSACTION                |
 |                                                                           |
 | USAGE NOTES:                                                              |
 |   Begin                                                                   |
 |     XLA_UTIL.set_query_context('AR_TRANSACTION');                         |
 |   End;                                                                    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     14-Apr-99  Mahesh Sabapathy    Created                                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE set_query_context (
        p_context               IN      VARCHAR2);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_query_context                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Gets the query context set using set_query_context.                     |
 |   get_query_context function is designed to be used as a SQL function.    |
 |                                                                           |
 |   This procedure should be used with set_query_context. XLA uses this     |
 |   function to get contexts within the View Accounting Lines and           |
 |   Drilldown product views. XLA uses these functions to access the view    |
 |   based on product transaction class(group). This approach is used to     |
 |   improve performance when accessing union views.                         |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |   none                                                                    |
 |                                                                           |
 | ARGUMENTS                                                     	     |
 |   none                                                                    |
 |                                                                           |
 | USAGE NOTES:                                                              |
 |   Begin                                                                   |
 |     x := XLA_UTIL.get_query_context;                         	     |
 |   End;                                                                    |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     14-Apr-99  Mahesh Sabapathy    Created                                |
 |                                                                           |
 +===========================================================================*/
FUNCTION get_query_context RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES( get_query_context, WNDS, WNPS );




/*===========================================================================+
 | PROCEDURE                                                                  |
 |    get_function_id                                                         |
 |                                                                            |
 | DESCRIPTION                                                                |
 |   Gets the function_id of function p_function_name from the data base.     |
 | Its a wrapper over  FND_FUNCTION.GET_FUNCTION_ID.It is used                |
 | to check the existence of any function at the data base.  	  	      |
 |                                                                            |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                     |
 |   FND_FUNCTION.GET_FUNCTION_ID                                             |
 |                                                                            |
 | ARGUMENTS                                                                  |
 |  IN  p_function_name VARCHAR2                                              |
 |                                                                            |
 | USAGE NOTES:                                                               |
 |   Begin                                                                    |
 |     x := XLA_UTIL.get_function_id(l_function_name)                         |
 |   End;                                                                     |
 |                                                                            |
 | MODIFICATION HISTORY                                                       |
 |     14-Jun-03  Lokesh Gandhi     Created  Bug 2969915                      |
 +===========================================================================*/

FUNCTION get_function_id(p_function_name in varchar2
                       )  RETURN NUMBER;



END XLA_UTIL;

 

/
