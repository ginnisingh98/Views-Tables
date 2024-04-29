--------------------------------------------------------
--  DDL for Package XLA_EVT_CLASS_ACCT_ATTRS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_EVT_CLASS_ACCT_ATTRS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatbaaa.pkh 120.1 2004/09/28 22:07:02 wychan noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_evt_class_acct_attrs                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_evt_class_acct_attrs                  |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/

PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_default_flag                     IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_default_flag                     IN VARCHAR2);

PROCEDURE update_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_assignment_owner_code            IN VARCHAR2
  ,x_default_flag                     IN VARCHAR2
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_attribute_code        IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2);

PROCEDURE load_row
(p_application_short_name           IN VARCHAR2
,p_event_class_code                 IN VARCHAR2
,p_accounting_attribute_code        IN VARCHAR2
,p_source_app_short_name            IN VARCHAR2
,p_source_type_code                 IN VARCHAR2
,p_source_code                      IN VARCHAR2
,p_assignment_owner_code            IN VARCHAR2
,p_default_flag                     IN VARCHAR2
,p_owner                            IN VARCHAR2
,p_last_update_date                 IN VARCHAR2);

END xla_evt_class_acct_attrs_f_pkg;
 

/
