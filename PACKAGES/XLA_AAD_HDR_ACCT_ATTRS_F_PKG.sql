--------------------------------------------------------
--  DDL for Package XLA_AAD_HDR_ACCT_ATTRS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AAD_HDR_ACCT_ATTRS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatbhaa.pkh 120.0 2004/05/27 20:58:42 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_aad_hdr_acct_attrs_f_pkg                                       |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_aad_hdr_acct_attrs                    |
|                                                                       |
| HISTORY                                                               |
|   Manually created                                                    |
|                                                                       |
+======================================================================*/

PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_event_class_default_flag         IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_event_class_default_flag         IN VARCHAR2);

PROCEDURE update_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_event_class_default_flag         IN VARCHAR2
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2);

END xla_aad_hdr_acct_attrs_f_pkg;
 

/
