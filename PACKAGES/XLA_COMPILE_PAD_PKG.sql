--------------------------------------------------------
--  DDL for Package XLA_COMPILE_PAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_COMPILE_PAD_PKG" AUTHID CURRENT_USER AS
/* $Header: xlacpcmp.pkh 120.4 2003/04/30 14:42:10 kboussem ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_compile_pad_pkg                                                    |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a XLA private package, which contains all the APIs required    |
|     for compilation of Product Accounting definition                       |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     15-JUL-2002 K.Boussema    Created                                      |
|     19-MAR-2003 K.Boussema    Added amb_context_code column                |
|     27-MAR-2003 K.Boussema    changed package name xla_compile_pkg by      |
|                               xla_compile_pad_pkg, removed default null    |
|     22-APR-2003 K.Boussema    Included error messages                      |
+===========================================================================*/


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
| Compile                                                               |
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
| Public Function                                                      |
|                                                                       |
| get_compile_status                                                    |
|                                                                       |
| Return                                                                |
|             status                                                    |
|                                                                       |
+======================================================================*/
FUNCTION  get_compile_status( p_application_id         IN NUMBER
                            , p_product_rule_code      IN VARCHAR2
                            , p_product_rule_type_code IN VARCHAR2
                            , p_amb_context_code       IN VARCHAR2
                            )
RETURN VARCHAR2
;
/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| set_compile_status                                                    |
|                                                                       |
| Switch the compile flag                                               |
|                                                                       |
| Parameters                                                            |
|             1      p_application_id         NUMBER                    |
|             2      p_product_rule_code      VARCHAR2                  |
|             3      p_product_rule_type_code VARCHAR2                  |
|             4      p_compile_old            VARCHAR2 Old status       |
|             5      p_compile_old            VARCHAR2 New status       |
|                                                                       |
+======================================================================*/

PROCEDURE set_compile_status    (p_application_id               IN  NUMBER
                                ,p_product_rule_code            IN  VARCHAR2
                                ,p_product_rule_type_code       IN  VARCHAR2
                                ,p_amb_context_code             IN  VARCHAR2
                                ,p_status_old                   IN  VARCHAR2
                                ,p_status_new                   IN  VARCHAR2);
--
/*======================================================================+
|                                                                       |
| Public  function                                                      |
|                                                                       |
| compile                                                               |
|                                                                       |
| Run PAD compilation                                                   |
|                                                                       |
+======================================================================*/

FUNCTION Compile(  p_application_id            IN NUMBER
                 , p_product_rule_code         IN VARCHAR2
                 , p_product_rule_type_code    IN VARCHAR2
                 , p_product_rule_version      IN VARCHAR2 DEFAULT NULL
                 , p_amb_context_code          IN VARCHAR2 )
RETURN BOOLEAN
;
--
--
END xla_compile_pad_pkg; -- end of package spec
 

/
