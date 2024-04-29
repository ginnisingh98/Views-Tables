--------------------------------------------------------
--  DDL for Package XLA_ANALYTICAL_HDRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ANALYTICAL_HDRS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamanc.pkh 120.4 2004/11/02 19:05:41 wychan ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_analytical_hdrs_pkg                                            |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Analytical Criteria package                                    |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_product_rule                                                |
|                                                                       |
| Returns true if all the product rules for the analytical criteria are |
| uncompiled                                                            |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_amb_context_code                 IN VARCHAR2
  ,p_analytical_criterion_code        IN VARCHAR2
  ,p_anal_criterion_type_code         IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                  IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag              IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

END xla_analytical_hdrs_pkg;
 

/
