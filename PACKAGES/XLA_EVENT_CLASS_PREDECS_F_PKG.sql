--------------------------------------------------------
--  DDL for Package XLA_EVENT_CLASS_PREDECS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_EVENT_CLASS_PREDECS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatbecp.pkh 120.1 2005/04/20 20:19:50 dcshah noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_event_class_predecs_f_pkg                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_event_class_predecs                        |
|                                                                       |
| HISTORY                                                               |
|   Manually created                                                    |
|                                                                       |
+======================================================================*/

PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_event_class_code                 IN VARCHAR2
  ,x_prior_event_class_code           IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_event_class_code                 IN VARCHAR2
  ,x_prior_event_class_code           IN VARCHAR2);

PROCEDURE lock_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_event_class_code                 IN VARCHAR2
  ,x_prior_event_class_code           IN VARCHAR2);

PROCEDURE load_row
  (p_application_short_name           IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_prior_event_class_code           IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2);

END xla_event_class_predecs_f_pkg;
 

/
