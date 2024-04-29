--------------------------------------------------------
--  DDL for Package XLA_CMP_STRING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_CMP_STRING_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpstr.pkh 120.3 2004/09/22 18:14:14 sasingha ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_cmp_string_pkg                                                     |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the logic required   |
|     to handle the text gcreated by the compiler                            |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-JUL-2002 K.Boussema    Created                                      |
|     19-APR-2003 K.Boussema    Included Error messages                      |
|     21-Sep-2004 S.Singhania   Replaced long varchar variables with CLOB    |
|                               Added routine replace_token to handle REPLACE|
|                                 in CLOB variables.                         |
+===========================================================================*/
--
--+==========================================================================+
--|                                                                          |
--| Private global Type                                                      |
--|                                                                          |
--+==========================================================================+
--
--
TYPE VARCHAR2S    IS TABLE OF VARCHAR2(256)     INDEX BY BINARY_INTEGER;
--
--
--+==========================================================================+
--|                                                                          |
--| Private global variables                                                 |
--|                                                                          |
--+==========================================================================+
--
--
g_null_varchar2s      DBMS_SQL.VARCHAR2S;
--

--
--+==========================================================================+
--| PRIVATE procedures and functions                                         |
--|    CreateString                                                          |
--|    transforms CLOB lines (length > 255) into a list of lines not         |
--|    exceeding 255 characters                                              |
--|                                                                          |
--|                                                                          |
--+==========================================================================+

PROCEDURE CreateString( p_package_text  IN  CLOB
                      , p_array_string  OUT NOCOPY DBMS_SQL.VARCHAR2S)
;

--
--+==========================================================================+
--|                                                                          |
--| PUBLIC Procedure                                                         |
--|                                                                          |
--+==========================================================================+
--

FUNCTION  ConcatTwoStrings (
                   p_array_string_1           IN DBMS_SQL.VARCHAR2S
                  ,p_array_string_2           IN DBMS_SQL.VARCHAR2S
)
RETURN DBMS_SQL.VARCHAR2S
;

--
--+==========================================================================+
--|                                                                          |
--| PUBLIC Procedure                                                         |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE AddNewLine(
                    p_array_string  IN OUT NOCOPY DBMS_SQL.VARCHAR2S
                   )
;
--
--
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC Procedure                                                         |
--|                                                                          |
--+==========================================================================+
--
PROCEDURE truncate_lines(p_package_text IN OUT NOCOPY CLOB)
;
--
--+==========================================================================+
--|                                                                          |
--| PUBLIC Procedure                                                         |
--|                                                                          |
--+==========================================================================+
--
FUNCTION replace_token
       (p_original_text             IN  CLOB
       ,p_token                     IN  VARCHAR2
       ,p_replacement_text          IN  CLOB)
RETURN CLOB;
--
END xla_cmp_string_pkg; -- end of package spec
 

/
