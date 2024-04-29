--------------------------------------------------------
--  DDL for Package Body XLA_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_MESSAGES_PKG" AS
/* $Header: xlacmmsg.pkb 120.3 2003/02/25 01:28:02 sasingha ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
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
|    07-Dec-95 P. Labrevois    Created                                  |
|    07-Feb-01                 Adapted for XLA                          |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
| build_message                                                         |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/


/*======================================================================+
|                                                                       |
| build_message                                                         |
|                                                                       |
| Build the message, to token is passed.                                |
|                                                                       |
+======================================================================*/
PROCEDURE build_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2)

IS

BEGIN
fnd_message.set_name
  (p_appli_s_name
  ,p_msg_name);

--
-- Store the message number in a global
--
g_message_number := fnd_message.get_number
  (p_appli_s_name
  ,p_msg_name);
END build_message;


/*======================================================================+
|                                                                       |
| build_message                                                         |
|                                                                       |
| Build the message, completed with the value for 1 token               |
|                                                                       |
+======================================================================*/
PROCEDURE build_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2)

IS

BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name);

fnd_message.set_token
  (p_token_1
  ,p_value_1);
END build_message;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| build_message                                                         |
|                                                                       |
| Build the message, completed with the value for 2 token               |
|                                                                       |
+======================================================================*/
PROCEDURE build_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2)

IS

BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name
  ,p_token_1
  ,p_value_1);

fnd_message.set_token
  (p_token_2
  ,p_value_2);
END build_message;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| build_message                                                         |
|                                                                       |
| Build the message, completed with the value for 3 token               |
|                                                                       |
+======================================================================*/
PROCEDURE build_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2)

IS

BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name
  ,p_token_1
  ,p_value_1
  ,p_token_2
  ,p_value_2);

fnd_message.set_token
  (p_token_3
  ,p_value_3);
END build_message;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| build_message                                                         |
|                                                                       |
| Build the message, completed with the value for 4 token               |
|                                                                       |
+======================================================================*/
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
  ,p_value_4                      IN  VARCHAR2)

IS

BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name
  ,p_token_1
  ,p_value_1
  ,p_token_2
  ,p_value_2
  ,p_token_3
  ,p_value_3);

fnd_message.set_token
  (p_token_4
  ,p_value_4);
END build_message;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| build_message                                                         |
|                                                                       |
| Build the message, completed with the value for 5 token               |
|                                                                       |
+======================================================================*/
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
  ,p_value_5                      IN  VARCHAR2)

IS

BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name
  ,p_token_1
  ,p_value_1
  ,p_token_2
  ,p_value_2
  ,p_token_3
  ,p_value_3
  ,p_token_4
  ,p_value_4);

fnd_message.set_token
  (p_token_5
  ,p_value_5);
END build_message;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| build_message                                                         |
|                                                                       |
| Build the message, completed with the value for 6 token               |
|                                                                       |
+======================================================================*/
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
  ,p_value_6                      IN  VARCHAR2)

IS

BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name
  ,p_token_1
  ,p_value_1
  ,p_token_2
  ,p_value_2
  ,p_token_3
  ,p_value_3
  ,p_token_4
  ,p_value_4
  ,p_token_5
  ,p_value_5);

fnd_message.set_token
  (p_token_6
  ,p_value_6);
END build_message;


/*======================================================================+
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
| get_message_prefixed                                                  |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_message_prefixed                                                  |
|                                                                       |
| Return the message from the message stack, prefixed with the message  |
| number.                                                               |
+======================================================================*/
FUNCTION  get_message_prefixed
RETURN VARCHAR2

IS

BEGIN
IF xla_environment_pkg.g_release_name IN ('11.5','12.0') THEN
   IF g_message_number IS NULL THEN
      RETURN SUBSTR(fnd_message.get,1,2000);
   ELSE
      RETURN SUBSTR('XLA-'
               ||   TO_CHAR(g_message_number)
               ||   xla_environment_pkg.g_chr_newline
               ||   xla_environment_pkg.g_chr_newline
               ||   fnd_message.get
               ||   xla_environment_pkg.g_chr_newline,1,2000);
   END IF;
ELSE
   RETURN SUBSTR(fnd_message.get,1,241);
END IF;
END get_message_prefixed;


/*======================================================================+
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
| get_message                                                           |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
+======================================================================*/


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_message                                                           |
|                                                                       |
| Return the message from the message stack.                            |
+======================================================================*/
FUNCTION  get_message
RETURN VARCHAR2

IS

BEGIN
IF xla_environment_pkg.g_release_name IN ('11.5','12.0') THEN
   RETURN SUBSTR(fnd_message.get,1,2000);
ELSE
   RETURN SUBSTR(fnd_message.get,1,241);
END IF;
END get_message;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_message                                                           |
|                                                                       |
| Return the message not associated with any token.                     |
|                                                                       |
+======================================================================*/
FUNCTION  get_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2)
RETURN VARCHAR2

IS

BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name);

RETURN get_message;
END get_message;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_message                                                           |
|                                                                       |
| Return the message completed with the value for 1 token.              |
|                                                                       |
+======================================================================*/
FUNCTION  get_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2)
RETURN VARCHAR2

IS
BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name
  ,p_token_1
  ,p_value_1);

RETURN get_message;
END get_message;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_message                                                           |
|                                                                       |
| Return the message completed with the value for 2 token.              |
|                                                                       |
+======================================================================*/
FUNCTION  get_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2)
RETURN VARCHAR2

IS
BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name
  ,p_token_1
  ,p_value_1
  ,p_token_2
  ,p_value_2);

RETURN get_message;
END get_message;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_message                                                           |
|                                                                       |
| Return the message completed with the value for 3 token.              |
|                                                                       |
+======================================================================*/
FUNCTION  get_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2)
RETURN VARCHAR2

IS
BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name
  ,p_token_1
  ,p_value_1
  ,p_token_2
  ,p_value_2
  ,p_token_3
  ,p_value_3);

RETURN get_message;
END get_message;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_message                                                           |
|                                                                       |
| Return the message completed with the value for 4 token.              |
|                                                                       |
+======================================================================*/
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
RETURN VARCHAR2

IS
BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name
  ,p_token_1
  ,p_value_1
  ,p_token_2
  ,p_value_2
  ,p_token_3
  ,p_value_3
  ,p_token_4
  ,p_value_4);

RETURN get_message;
END get_message;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_message                                                           |
|                                                                       |
| Return the message completed with the value for 5 token.              |
|                                                                       |
+======================================================================*/
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
RETURN VARCHAR2

IS
BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name
  ,p_token_1
  ,p_value_1
  ,p_token_2
  ,p_value_2
  ,p_token_3
  ,p_value_3
  ,p_token_4
  ,p_value_4
  ,p_token_5
  ,p_value_5);

RETURN get_message;
END get_message;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_message                                                           |
|                                                                       |
| Return the message completed with the value for 6 token.              |
|                                                                       |
+======================================================================*/
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
RETURN VARCHAR2

IS
BEGIN
build_message
  (p_appli_s_name
  ,p_msg_name
  ,p_token_1
  ,p_value_1
  ,p_token_2
  ,p_value_2
  ,p_token_3
  ,p_value_3
  ,p_token_4
  ,p_value_4
  ,p_token_5
  ,p_value_5
  ,p_token_6
  ,p_value_6);

RETURN get_message;
END get_message;


END xla_messages_pkg;

/
