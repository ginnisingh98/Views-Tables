--------------------------------------------------------
--  DDL for Package XLA_SOURCE_PARAMS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_SOURCE_PARAMS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathspm.pkh 120.0 2004/09/28 22:00:44 wychan noship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_source_params_f_pkg                                            |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_source_params                         |
|                                                                       |
| HISTORY                                                               |
|    09/27/04 W Chan     Created                                        |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_source_param_id                  IN NUMBER
  ,x_application_id                   IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_user_sequence                    IN NUMBER
  ,x_parameter_type_code              IN VARCHAR2
  ,x_constant_value                   IN VARCHAR2
  ,x_ref_source_application_id        IN NUMBER
  ,x_ref_source_type_code             IN VARCHAR2
  ,x_ref_source_code                  IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
 (x_source_param_id                  IN NUMBER
 ,x_application_id                   IN NUMBER
 ,x_source_type_code                 IN VARCHAR2
 ,x_source_code                      IN VARCHAR2
 ,x_user_sequence                    IN NUMBER
 ,x_parameter_type_code              IN VARCHAR2
 ,x_constant_value                   IN VARCHAR2
 ,x_ref_source_application_id        IN NUMBER
 ,x_ref_source_type_code             IN VARCHAR2
 ,x_ref_source_code                  IN VARCHAR2
);

PROCEDURE update_row
 (x_source_param_id                  IN NUMBER
 ,x_application_id                   IN NUMBER
 ,x_source_type_code                 IN VARCHAR2
 ,x_source_code                      IN VARCHAR2
 ,x_user_sequence                    IN NUMBER
 ,x_parameter_type_code              IN VARCHAR2
 ,x_constant_value                   IN VARCHAR2
 ,x_ref_source_application_id        IN NUMBER
 ,x_ref_source_type_code             IN VARCHAR2
 ,x_ref_source_code                  IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_source_param_id                   IN NUMBER);

PROCEDURE load_row
(p_application_short_name             IN VARCHAR2
,p_source_type_code                   IN VARCHAR2
,p_source_code                        IN VARCHAR2
,p_user_sequence                      IN VARCHAR2
,p_parameter_type_code                IN VARCHAR2
,p_constant_value                     IN VARCHAR2
,p_ref_source_app_short_name          IN VARCHAR2
,p_ref_source_type_code               IN VARCHAR2
,p_ref_source_code                    IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2);

END xla_source_params_f_pkg;
 

/
