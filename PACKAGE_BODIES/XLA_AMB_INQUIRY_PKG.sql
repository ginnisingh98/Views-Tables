--------------------------------------------------------
--  DDL for Package Body XLA_AMB_INQUIRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AMB_INQUIRY_PKG" AS
/* $Header: xlaaminq.pkb 120.1 2003/05/29 17:30:19 wychan ship $ */
/*======================================================================+
|               Copyrighuc) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_amb_inquiry_pkg                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA AMB Inquiry package                                            |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Wynne Chan     Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_check_AF                                                          |
|                                                                       |
| Set the check_AF variable to 1                                        |
|                                                                       |
+======================================================================*/

PROCEDURE set_check_AF
IS
BEGIN
  XLA_AMB_INQUIRY_PKG.check_AF := 1;
END;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| unset_check_AF                                                        |
|                                                                       |
| Set the check_AF variable to 0                                        |
|                                                                       |
+======================================================================*/

PROCEDURE unset_check_AF
IS
BEGIN
  XLA_AMB_INQUIRY_PKG.check_AF := 0;
END;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_check_SS                                                          |
|                                                                       |
| Set the check_SS variable to 1                                        |
|                                                                       |
+======================================================================*/

PROCEDURE set_check_SS
IS
BEGIN
  XLA_AMB_INQUIRY_PKG.check_SS := 1;
END;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| unset_check_SS                                                        |
|                                                                       |
| Set the check_SS variable to 0                                        |
|                                                                       |
+======================================================================*/

PROCEDURE unset_check_SS
IS
BEGIN
  XLA_AMB_INQUIRY_PKG.check_SS := 0;
END;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_check_SD                                                          |
|                                                                       |
| Set the check_SD variable to 1                                        |
|                                                                       |
+======================================================================*/

PROCEDURE set_check_SD
IS
BEGIN
  XLA_AMB_INQUIRY_PKG.check_SD := 1;
END;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| unset_check_SD                                                        |
|                                                                       |
| Set the check_SD variable to 0                                        |
|                                                                       |
+======================================================================*/

PROCEDURE unset_check_SD
IS
BEGIN
  XLA_AMB_INQUIRY_PKG.check_SD := 0;
END;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| unset_check_all                                                       |
|                                                                       |
| Unset all check_XX variable                                           |
|                                                                       |
+======================================================================*/

PROCEDURE unset_check_all
IS
BEGIN
  XLA_AMB_INQUIRY_PKG.check_AF := 0;
  XLA_AMB_INQUIRY_PKG.check_SS := 0;
  XLA_AMB_INQUIRY_PKG.check_SD := 0;
END;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_check_summary                                                     |
|                                                                       |
| Set the summary level checking to 1 (AF and SS)                       |
|                                                                       |
+======================================================================*/

PROCEDURE set_check_summary
IS
BEGIN
  XLA_AMB_INQUIRY_PKG.check_AF := 1;
  XLA_AMB_INQUIRY_PKG.check_SS := 1;
  XLA_AMB_INQUIRY_PKG.check_SD := 0;
END;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_check_AF                                                          |
|                                                                       |
| Return the value of the check_AF variable                             |
|                                                                       |
+======================================================================*/

FUNCTION get_check_AF RETURN NUMBER
IS
BEGIN
  RETURN XLA_AMB_INQUIRY_PKG.check_AF;
END;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_check_SS                                                          |
|                                                                       |
| Return the value of the check_SS variable                             |
|                                                                       |
+======================================================================*/

FUNCTION get_check_SS RETURN NUMBER
IS
BEGIN
  RETURN XLA_AMB_INQUIRY_PKG.check_SS;
END;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_check_SD                                                          |
|                                                                       |
| Return the value of the check_SD variable                             |
|                                                                       |
+======================================================================*/

FUNCTION get_check_SD RETURN NUMBER
IS
BEGIN
  RETURN XLA_AMB_INQUIRY_PKG.check_SD;
END;


END xla_amb_inquiry_pkg;

/
