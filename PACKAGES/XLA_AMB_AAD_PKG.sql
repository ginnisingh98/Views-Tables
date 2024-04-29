--------------------------------------------------------
--  DDL for Package XLA_AMB_AAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AMB_AAD_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamaad.pkh 120.3 2005/01/11 02:02:40 wychan noship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_amb_aad_pkg                                                    |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Application Accounting Definition Validations package          |
|                                                                       |
| HISTORY                                                               |
|    30-Dec-03 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Validate_and_compile_aad                                              |
|                                                                       |
| Validates and compiles the application accounting definition          |
|                                                                       |
+======================================================================*/

PROCEDURE validate_and_compile_aad
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2
  ,x_validation_status_code           IN OUT NOCOPY VARCHAR2
  ,x_compilation_status_code          IN OUT NOCOPY VARCHAR2
  ,x_hash_id                          IN OUT NOCOPY INTEGER);

END xla_amb_aad_pkg;
 

/
