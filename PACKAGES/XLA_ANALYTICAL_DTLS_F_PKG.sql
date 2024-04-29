--------------------------------------------------------
--  DDL for Package XLA_ANALYTICAL_DTLS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ANALYTICAL_DTLS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathacd.pkh 120.1 2005/05/05 23:07:44 wychan ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_analytical_dtls                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_analytical_dtls                       |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/



PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_analytical_criterion_code        IN VARCHAR2
  ,x_analytical_criterion_type_co     IN VARCHAR2
  ,x_amb_context_code                 IN VARCHAR2
  ,x_analytical_detail_code           IN VARCHAR2
  ,x_grouping_order                   IN NUMBER
  ,x_data_type_code                   IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_analytical_criterion_code        IN VARCHAR2
  ,x_analytical_criterion_type_co     IN VARCHAR2
  ,x_amb_context_code                 IN VARCHAR2
  ,x_analytical_detail_code           IN VARCHAR2
  ,x_grouping_order                   IN NUMBER
  ,x_data_type_code                   IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2);

PROCEDURE update_row
 (x_analytical_criterion_code        IN VARCHAR2
 ,x_analytical_criterion_type_co     IN VARCHAR2
 ,x_amb_context_code                 IN VARCHAR2
 ,x_analytical_detail_code           IN VARCHAR2
 ,x_grouping_order                   IN NUMBER
 ,x_data_type_code                   IN VARCHAR2
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_analytical_criterion_code        IN VARCHAR2
  ,x_analytical_criterion_type_co     IN VARCHAR2
  ,x_amb_context_code                 IN VARCHAR2
  ,x_analytical_detail_code           IN VARCHAR2);

PROCEDURE add_language;

PROCEDURE translate_row
  (p_amb_context_code                 IN VARCHAR2
  ,p_analytical_criterion_code        IN VARCHAR2
  ,p_analytical_criterion_type_co     IN VARCHAR2
  ,p_analytical_detail_code           IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_description                      IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2);

END xla_analytical_dtls_f_pkg;
 

/
