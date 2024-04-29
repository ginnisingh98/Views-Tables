--------------------------------------------------------
--  DDL for Package XLA_EXCEPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_EXCEPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacmexc.pkh 120.2 2003/04/07 18:37:55 wychan ship $ */
/*======================================================================+
|             Copyright (c) 1995-2001 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_exceptions_pkg                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Exceptions Package                                             |
|                                                                       |
| HISTORY                                                               |
|    02-Jan-95 P. Juvara       Created                                  |
|    08-Feb-01 P. Labrevois    Adapted for XLA                          |
|                                                                       |
+======================================================================*/


/*======================================================================+
|                                                                       |
| Constants                                                             |
|                                                                       |
+======================================================================*/
C_STANDARD_MESSAGE		VARCHAR2(1) := 'S';
C_OA_MESSAGE			VARCHAR2(1) := 'O';

/*======================================================================+
|                                                                       |
| Variables                                                             |
|                                                                       |
+======================================================================*/
exception_text                  VARCHAR2(2000);


/*======================================================================+
|                                                                       |
| Exceptions                                                            |
|                                                                       |
+======================================================================*/
application_exception           EXCEPTION;
resource_busy                   EXCEPTION;
too_many_rows                   EXCEPTION;

PRAGMA exception_init(application_exception, -20001);
PRAGMA exception_init(resource_busy        , -00054);
PRAGMA exception_init(too_many_rows        , -01422);


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| raise_exception                                                       |
|                                                                       |
| Raise the standard exception.                                         |
|                                                                       |
+======================================================================*/
PROCEDURE raise_exception;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| raise_message                                                         |
|                                                                       |
| Raise the standard exception with a generic text associated. This     |
| procedure is usually called from the all the exceptions blocks.       |
|                                                                       |
+======================================================================*/
PROCEDURE raise_message
  (p_location                     IN  VARCHAR2
  ,p_msg_mode                     IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| raise_message                                                         |
|                                                                       |
| Raise an exception with a message text. The function can accpt up to  |
| 6 tokens.                                                             |
|                                                                       |
+======================================================================*/
PROCEDURE raise_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_msg_mode                     IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE);

PROCEDURE raise_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_msg_mode                     IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE);

PROCEDURE raise_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_msg_mode                     IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE);

PROCEDURE raise_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2
  ,p_msg_mode                     IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE);

PROCEDURE raise_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2
  ,p_token_4                      IN  VARCHAR2
  ,p_value_4                      IN  VARCHAR2
  ,p_msg_mode                     IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE);

PROCEDURE raise_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2
  ,p_token_4                      IN  VARCHAR2
  ,p_value_4                      IN  VARCHAR2
  ,p_token_5                      IN  VARCHAR2
  ,p_value_5                      IN  VARCHAR2
  ,p_msg_mode                     IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE);

PROCEDURE raise_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2
  ,p_token_4                      IN  VARCHAR2
  ,p_value_4                      IN  VARCHAR2
  ,p_token_5                      IN  VARCHAR2
  ,p_value_5                      IN  VARCHAR2
  ,p_token_6                      IN  VARCHAR2
  ,p_value_6                      IN  VARCHAR2
  ,p_msg_mode                     IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE);

END xla_exceptions_pkg ;
 

/
