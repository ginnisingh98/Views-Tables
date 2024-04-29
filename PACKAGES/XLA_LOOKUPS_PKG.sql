--------------------------------------------------------
--  DDL for Package XLA_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_LOOKUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacmlkp.pkh 120.2 2003/03/18 00:38:05 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_lookup_pkg                                                     |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Lookups Package                                                |
|                                                                       |
| HISTORY                                                               |
|    07-Dec-95 P. Labrevois    Created                                  |
|    08-Feb-01                 Converted to XLA                         |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_meaning                                                           |
|                                                                       |
| Get the meaning for an lookup type and lookup code.                   |
|                                                                       |
+======================================================================*/
FUNCTION  get_meaning
  (p_lookup_type                  IN  VARCHAR2
  ,p_lookup_code                  IN  VARCHAR2)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_lookuptype_meaning                                                |
|                                                                       |
| Get the meaning for an lookup type                                    |
|                                                                       |
+======================================================================*/
FUNCTION  get_lookuptype_meaning
  (p_view_application_id          IN  NUMBER
  ,p_lookup_type                  IN  VARCHAR2)
RETURN VARCHAR2;


END xla_lookups_pkg;
 

/
