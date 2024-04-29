--------------------------------------------------------
--  DDL for Package XLA_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_PROFILES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacmpro.pkh 120.1 2003/02/22 19:01:10 svjoshi ship $ */
/*======================================================================+
|             Copyright (c) 2000-2001 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_profiles_pkg                                                   |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Profiles Package                                               |
|                                                                       |
|    Profile options handling.                                          |
|                                                                       |
| HISTORY                                                               |
|    01-Jan-97 P. Labrevois    Created                                  |
|    08-Feb-01 P. Labrevois    Created for XLA                          |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_value                                                             |
|                                                                       |
| Get a profile option value                                            |
|                                                                       |
+======================================================================*/
FUNCTION  get_value
  (p_profile                      IN  VARCHAR2)
RETURN VARCHAR2;

END xla_profiles_pkg;
 

/
