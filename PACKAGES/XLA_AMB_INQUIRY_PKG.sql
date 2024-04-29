--------------------------------------------------------
--  DDL for Package XLA_AMB_INQUIRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AMB_INQUIRY_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaaminq.pkh 120.1 2003/05/29 17:30:10 wychan ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
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
| Global Paramters required for Inquiry Function                        |
|                                                                       |
+======================================================================*/

--
-- Inquire Account Flexfield
--
check_AF		NUMBER DEFAULT 0;

--
-- Inquire Segment Summary
--
check_SS		NUMBER DEFAULT 0;

--
-- Inquire Segment Details
--
check_SD		NUMBER DEFAULT 0;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_check_AF                                                          |
|                                                                       |
| Set the check_AF variable to 1                                        |
|                                                                       |
+======================================================================*/

PROCEDURE set_check_AF;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| unset_check_AF                                                        |
|                                                                       |
| Set the check_AF variable to 0                                        |
|                                                                       |
+======================================================================*/

PROCEDURE unset_check_AF;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_check_SS                                                          |
|                                                                       |
| Set the check_SS variable to 1                                        |
|                                                                       |
+======================================================================*/

PROCEDURE set_check_SS;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| unset_check_SS                                                        |
|                                                                       |
| Set the check_SS variable to 0                                        |
|                                                                       |
+======================================================================*/

PROCEDURE unset_check_SS;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_check_SD                                                          |
|                                                                       |
| Set the check_SD variable to 1                                        |
|                                                                       |
+======================================================================*/

PROCEDURE set_check_SD;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| unset_check_SD                                                        |
|                                                                       |
| Set the check_SD variable to 0                                        |
|                                                                       |
+======================================================================*/

PROCEDURE unset_check_SD;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| unset_check_all                                                       |
|                                                                       |
| Unset all check_XX variable                                           |
|                                                                       |
+======================================================================*/

PROCEDURE unset_check_all;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_check_summary                                                     |
|                                                                       |
| Set the summary level checking to 1 (AF and SS)                       |
|                                                                       |
+======================================================================*/

PROCEDURE set_check_summary;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_check_AF                                                          |
|                                                                       |
| Return the value of the check_AF variable                             |
|                                                                       |
+======================================================================*/

FUNCTION get_check_AF RETURN NUMBER;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_check_SS                                                          |
|                                                                       |
| Return the value of the check_SS variable                             |
|                                                                       |
+======================================================================*/

FUNCTION get_check_SS RETURN NUMBER;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_check_SD                                                          |
|                                                                       |
| Return the value of the check_SD variable                             |
|                                                                       |
+======================================================================*/

FUNCTION get_check_SD RETURN NUMBER;

END xla_amb_inquiry_pkg;
 

/
