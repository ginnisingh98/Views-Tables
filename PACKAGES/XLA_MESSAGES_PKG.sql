--------------------------------------------------------
--  DDL for Package XLA_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_MESSAGES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacmmsg.pkh 120.2 2003/02/22 19:25:56 svjoshi ship $ */
/*======================================================================+
|             Copyright (c) 1994-2001 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_messages_pkg                                                   |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Messages Package                                               |
|                                                                       |
| HISTORY                                                               |
|    07-Dec-94 P. Labrevois    Created                                  |
|    07-Feb-01                 Adapted for XLA                          |
|                                                                       |
+======================================================================*/

g_message_number                  NUMBER := NULL;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_message_prefixed                                                  |
|                                                                       |
| Return the message text associated with a message, prefixed with the  |                                                       |
| message number.                                                       |
|                                                                       |
+======================================================================*/
FUNCTION  get_message_prefixed
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_message                                                           |
|                                                                       |
| Return the message text associated with a message. The function can   |                                                       |
| accept up to 6 tokens.                                                |
|                                                                       |
+======================================================================*/
FUNCTION  get_message
RETURN VARCHAR2;

FUNCTION  get_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION  get_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION  get_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION  get_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION  get_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2
  ,p_token_4                      IN  VARCHAR2
  ,p_value_4                      IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION  get_message
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
  ,p_value_5                      IN  VARCHAR2)
RETURN VARCHAR2;

FUNCTION  get_message
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
  ,p_value_6                      IN  VARCHAR2)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| build_message                                                         |
|                                                                       |
| Build the message text. The function can accept up to 6 tokens.       |                                                       |
|                                                                       |
+======================================================================*/
PROCEDURE build_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2);

PROCEDURE build_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2);

PROCEDURE build_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2);

PROCEDURE build_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2);

PROCEDURE build_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2
  ,p_token_4                      IN  VARCHAR2
  ,p_value_4                      IN  VARCHAR2);

PROCEDURE build_message
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
  ,p_value_5                      IN  VARCHAR2);

PROCEDURE build_message
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
  ,p_value_6                      IN  VARCHAR2);

END xla_messages_pkg;
 

/
