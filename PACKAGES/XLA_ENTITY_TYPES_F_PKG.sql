--------------------------------------------------------
--  DDL for Package XLA_ENTITY_TYPES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ENTITY_TYPES_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathent.pkh 120.16 2004/09/24 21:51:52 wychan ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_entity_types                                                   |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_entity_types                          |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|    09/23/04 W Chan     Add API load_row and translate_row for FNDLOAD |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_enable_gapless_events_flag    IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_enable_gapless_events_flag    IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2);

PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_entity_code                      IN VARCHAR2
 ,x_enabled_flag                     IN VARCHAR2
 ,x_enable_gapless_events_flag    IN VARCHAR2
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2);

PROCEDURE add_language;

PROCEDURE load_row
(p_application_short_name             IN VARCHAR2
,p_entity_code                        IN VARCHAR2
,p_enabled_flag                       IN VARCHAR2
,p_enable_gapless_events_flag         IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2
,p_name                               IN VARCHAR2
,p_description                        IN VARCHAR2);

PROCEDURE translate_row
  (p_application_short_name           IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_description                      IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2);

END xla_entity_types_f_pkg;
 

/
