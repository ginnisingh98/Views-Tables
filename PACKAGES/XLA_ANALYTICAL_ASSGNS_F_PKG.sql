--------------------------------------------------------
--  DDL for Package XLA_ANALYTICAL_ASSGNS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ANALYTICAL_ASSGNS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatbanc.pkh 120.4 2003/04/03 22:06:11 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_analytical_assgns_f_pkg                                        |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_analytical_assgns                     |
|                                                                       |
| HISTORY                                                               |
|   Manually created                                                    |
|                                                                       |
+======================================================================*/

PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_analytical_assignment_id         IN OUT NOCOPY NUMBER
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_anal_criterion_type_code          IN VARCHAR2
  ,x_analytical_criterion_code         IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_analytical_assignment_id         IN NUMBER
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_anal_criterion_type_code          IN VARCHAR2
  ,x_analytical_criterion_code         IN VARCHAR2);

PROCEDURE update_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_analytical_assignment_id         IN NUMBER
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_anal_criterion_type_code          IN VARCHAR2
  ,x_analytical_criterion_code         IN VARCHAR2
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_analytical_assignment_id         IN NUMBER);

END xla_analytical_assgns_f_pkg;
 

/
