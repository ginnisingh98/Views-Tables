--------------------------------------------------------
--  DDL for Package Body XLA_EXCEPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_EXCEPTIONS_PKG" AS
/* $Header: xlacmexc.pkb 120.6 2003/05/24 00:13:25 svjoshi ship $ */
/*======================================================================+
|             Copyright (c) 2000-2002 Oracle Corporation                |
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
|    02-Jan-95    P. Juvara      Created                                |
|    07-Feb-01    P. Labrevois   Adapted for XLA                        |
|    23-May-2003  Shishir Joshi  Removed message number from the message|
|                                name                                   |
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
| Misc Private                                                          |
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
| Private procedure                                                     |
|                                                                       |
| failure                                                               |
|                                                                       |
| Print the failure in the std trace.                                   |
|                                                                       |
+======================================================================*/
PROCEDURE failure

IS

BEGIN
xla_utility_pkg.trace('Failure                    = '
                ||   xla_environment_pkg.g_chr_newline
                ||   xla_exceptions_pkg.exception_text                  ,100);
NULL;
END;


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
| Raise exception                                                       |
|                                                                       |
| Rasise the standard exception.                                        |
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
| Public Procedure                                                      |
|                                                                       |
| raise_exceptions                                                      |
|                                                                       |
| Raise the standard exception                                          |
|                                                                       |
+======================================================================*/
PROCEDURE raise_exception

IS

BEGIN
app_exception.raise_exception
  (exception_text =>
      'XLA-'
   || xla_messages_pkg.g_message_number
   || ': '
   || SUBSTR(xla_exceptions_pkg.exception_text
            ,1,LEAST(512,LENGTH(xla_exceptions_pkg.exception_text))));
END raise_exception;


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
| Raise message                                                         |
|                                                                       |
| Build a message with do or up to 6 tokens, then raise the standard    |
| exception.                                                            |
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
| Public Procedure                                                      |
|                                                                       |
| raise_message                                                         |
|                                                                       |
| Raise the standard exception with a generic text associated. This     |
| procedure is usually called from the all the exceptions blocks.       |
|                                                                       |
+======================================================================*/
PROCEDURE raise_message
  (p_location			IN VARCHAR2
  ,p_msg_mode			IN VARCHAR2 DEFAULT C_STANDARD_MESSAGE)
IS
BEGIN
raise_message
  ('XLA'           , 'XLA_COMMON_ERROR'
  ,'LOCATION'      , p_location
  ,'ERROR'         , sqlerrm
  ,p_msg_mode);
END raise_message;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| raise_message                                                         |
|                                                                       |
| Set the message completed with the value for no token, then raise.    |
|                                                                       |
+======================================================================*/
PROCEDURE raise_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_msg_mode			  IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE)

IS

BEGIN
xla_exceptions_pkg.exception_text :=
   xla_messages_pkg.get_message
     (p_appli_s_name  => p_appli_s_name
     ,p_msg_name      => p_msg_name);

xla_messages_pkg.build_message
  (p_appli_s_name  => p_appli_s_name
  ,p_msg_name      => p_msg_name);

failure;

if (p_msg_mode = C_STANDARD_MESSAGE) then
  xla_exceptions_pkg.raise_exception;
else
  fnd_msg_pub.add;
end if;
END raise_message;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| raise_message                                                         |
|                                                                       |
| Set the message completed with the value for 2 token, then raise.     |
|                                                                       |
+======================================================================*/
PROCEDURE raise_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_msg_mode			  IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE)

IS

BEGIN
xla_exceptions_pkg.exception_text :=
   xla_messages_pkg.get_message
     (p_appli_s_name  => p_appli_s_name
     ,p_msg_name      => p_msg_name
     ,p_token_1       => p_token_1
     ,p_value_1       => p_value_1);

xla_messages_pkg.build_message
  (p_appli_s_name  => p_appli_s_name
  ,p_msg_name      => p_msg_name
  ,p_token_1       => p_token_1
  ,p_value_1       => p_value_1);

failure;

if (p_msg_mode = C_STANDARD_MESSAGE) then
  xla_exceptions_pkg.raise_exception;
else
  fnd_msg_pub.add;
end if;
END raise_message;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| raise_message                                                         |
|                                                                       |
| Set the message completed with the value for 2 token, then raise.     |
|                                                                       |
+======================================================================*/
PROCEDURE raise_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_msg_mode			  IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE)

IS

BEGIN
xla_exceptions_pkg.exception_text :=
   xla_messages_pkg.get_message
     (p_appli_s_name  => p_appli_s_name
     ,p_msg_name      => p_msg_name
     ,p_token_1       => p_token_1
     ,p_value_1       => p_value_1
     ,p_token_2       => p_token_2
     ,p_value_2       => p_value_2);

xla_messages_pkg.build_message
  (p_appli_s_name  => p_appli_s_name
  ,p_msg_name      => p_msg_name
  ,p_token_1       => p_token_1
  ,p_value_1       => p_value_1
  ,p_token_2       => p_token_2
  ,p_value_2       => p_value_2);

failure;

if (p_msg_mode = C_STANDARD_MESSAGE) then
  xla_exceptions_pkg.raise_exception;
else
  fnd_msg_pub.add;
end if;
END raise_message;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| raise_message                                                         |
|                                                                       |
| Set the message completed with the value for 3 token, then raise.     |
|                                                                       |
+======================================================================*/
PROCEDURE raise_message
  (p_appli_s_name                 IN  VARCHAR2
  ,p_msg_name                     IN  VARCHAR2
  ,p_token_1                      IN  VARCHAR2
  ,p_value_1                      IN  VARCHAR2
  ,p_token_2                      IN  VARCHAR2
  ,p_value_2                      IN  VARCHAR2
  ,p_token_3                      IN  VARCHAR2
  ,p_value_3                      IN  VARCHAR2
  ,p_msg_mode			  IN VARCHAR2 DEFAULT C_STANDARD_MESSAGE)

IS

BEGIN
xla_exceptions_pkg.exception_text :=
   xla_messages_pkg.get_message
     (p_appli_s_name  => p_appli_s_name
     ,p_msg_name      => p_msg_name
     ,p_token_1       => p_token_1
     ,p_value_1       => p_value_1
     ,p_token_2       => p_token_2
     ,p_value_2       => p_value_2
     ,p_token_3       => p_token_3
     ,p_value_3       => p_value_3);

xla_messages_pkg.build_message
  (p_appli_s_name  => p_appli_s_name
  ,p_msg_name      => p_msg_name
  ,p_token_1       => p_token_1
  ,p_value_1       => p_value_1
  ,p_token_2       => p_token_2
  ,p_value_2       => p_value_2
  ,p_token_3       => p_token_3
  ,p_value_3       => p_value_3);

failure;

if (p_msg_mode = C_STANDARD_MESSAGE) then
  xla_exceptions_pkg.raise_exception;
else
  fnd_msg_pub.add;
end if;
END raise_message;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| raise_message                                                         |
|                                                                       |
| Set the message completed with the value for 4 token, then raise.     |
|                                                                       |
+======================================================================*/
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
  ,p_msg_mode			  IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE)

IS

BEGIN
xla_exceptions_pkg.exception_text :=
   xla_messages_pkg.get_message
     (p_appli_s_name  => p_appli_s_name
     ,p_msg_name      => p_msg_name
     ,p_token_1       => p_token_1
     ,p_value_1       => p_value_1
     ,p_token_2       => p_token_2
     ,p_value_2       => p_value_2
     ,p_token_3       => p_token_3
     ,p_value_3       => p_value_3
     ,p_token_4       => p_token_4
     ,p_value_4       => p_value_4);

xla_messages_pkg.build_message
  (p_appli_s_name  => p_appli_s_name
  ,p_msg_name      => p_msg_name
  ,p_token_1       => p_token_1
  ,p_value_1       => p_value_1
  ,p_token_2       => p_token_2
  ,p_value_2       => p_value_2
  ,p_token_3       => p_token_3
  ,p_value_3       => p_value_3
  ,p_token_4       => p_token_4
  ,p_value_4       => p_value_4);

failure;

if (p_msg_mode = C_STANDARD_MESSAGE) then
  xla_exceptions_pkg.raise_exception;
else
  fnd_msg_pub.add;
end if;
END raise_message;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| raise_message                                                         |
|                                                                       |
| Set the message completed with the value for 6 token, then raise.     |
|                                                                       |
+======================================================================*/
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
  ,p_msg_mode			  IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE)

IS

BEGIN
xla_exceptions_pkg.exception_text :=
   xla_messages_pkg.get_message
     (p_appli_s_name  => p_appli_s_name
     ,p_msg_name      => p_msg_name
     ,p_token_1       => p_token_1
     ,p_value_1       => p_value_1
     ,p_token_2       => p_token_2
     ,p_value_2       => p_value_2
     ,p_token_3       => p_token_3
     ,p_value_3       => p_value_3
     ,p_token_4       => p_token_4
     ,p_value_4       => p_value_4
     ,p_token_5       => p_token_5
     ,p_value_5       => p_value_5);

xla_messages_pkg.build_message
  (p_appli_s_name  => p_appli_s_name
  ,p_msg_name      => p_msg_name
  ,p_token_1       => p_token_1
  ,p_value_1       => p_value_1
  ,p_token_2       => p_token_2
  ,p_value_2       => p_value_2
  ,p_token_3       => p_token_3
  ,p_value_3       => p_value_3
  ,p_token_4       => p_token_4
  ,p_value_4       => p_value_4
  ,p_token_5       => p_token_5
  ,p_value_5       => p_value_5);

failure;

if (p_msg_mode = C_STANDARD_MESSAGE) then
  xla_exceptions_pkg.raise_exception;
else
  fnd_msg_pub.add;
end if;
END raise_message;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| raise_message                                                         |
|                                                                       |
| Set the message completed with the value for 6 token, then raise.     |
|                                                                       |
+======================================================================*/
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
  ,p_msg_mode			  IN  VARCHAR2 DEFAULT C_STANDARD_MESSAGE)

IS

BEGIN
xla_exceptions_pkg.exception_text :=
   xla_messages_pkg.get_message
     (p_appli_s_name  => p_appli_s_name
     ,p_msg_name      => p_msg_name
     ,p_token_1       => p_token_1
     ,p_value_1       => p_value_1
     ,p_token_2       => p_token_2
     ,p_value_2       => p_value_2
     ,p_token_3       => p_token_3
     ,p_value_3       => p_value_3
     ,p_token_4       => p_token_4
     ,p_value_4       => p_value_4
     ,p_token_5       => p_token_5
     ,p_value_5       => p_value_5
     ,p_token_6       => p_token_6
     ,p_value_6       => p_value_6);

xla_messages_pkg.build_message
  (p_appli_s_name  => p_appli_s_name
  ,p_msg_name      => p_msg_name
  ,p_token_1       => p_token_1
  ,p_value_1       => p_value_1
  ,p_token_2       => p_token_2
  ,p_value_2       => p_value_2
  ,p_token_3       => p_token_3
  ,p_value_3       => p_value_3
  ,p_token_4       => p_token_4
  ,p_value_4       => p_value_4
  ,p_token_5       => p_token_5
  ,p_value_5       => p_value_5
  ,p_token_6       => p_token_6
  ,p_value_6       => p_value_6);

failure;

if (p_msg_mode = C_STANDARD_MESSAGE) then
  xla_exceptions_pkg.raise_exception;
else
  fnd_msg_pub.add;
end if;
END raise_message;


END xla_exceptions_pkg;

/
