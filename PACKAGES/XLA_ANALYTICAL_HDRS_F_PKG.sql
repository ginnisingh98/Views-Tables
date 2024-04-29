--------------------------------------------------------
--  DDL for Package XLA_ANALYTICAL_HDRS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_ANALYTICAL_HDRS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlathach.pkh 120.1.12010000.2 2009/08/13 13:01:52 krsankar ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_analytical_hdrs                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_analytical_hdrs                       |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/

g_appl_short_name                     VARCHAR2(30) := NULL;

PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_analytical_criterion_code        IN VARCHAR2
  ,x_analytical_criterion_type_co     IN VARCHAR2
  ,x_amb_context_code                 IN VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_balancing_flag                   IN VARCHAR2
  ,x_display_order                    IN NUMBER
  ,x_enabled_flag                     IN VARCHAR2
  ,x_year_end_carry_forward_code      IN VARCHAR2
  ,x_display_in_inquiries_flag        IN VARCHAR2
  ,x_criterion_value_code             IN VARCHAR2
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
  ,x_application_id                   IN NUMBER
  ,x_balancing_flag                   IN VARCHAR2
  ,x_display_order                    IN NUMBER
  ,x_enabled_flag                     IN VARCHAR2
  ,x_year_end_carry_forward_code      IN VARCHAR2
  ,x_display_in_inquiries_flag        IN VARCHAR2
  ,x_criterion_value_code             IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2);

PROCEDURE update_row
 (x_analytical_criterion_code        IN VARCHAR2
 ,x_analytical_criterion_type_co     IN VARCHAR2
 ,x_amb_context_code                 IN VARCHAR2
 ,x_application_id                   IN NUMBER
 ,x_balancing_flag                   IN VARCHAR2
 ,x_display_order                    IN NUMBER
 ,x_enabled_flag                     IN VARCHAR2
 ,x_year_end_carry_forward_code      IN VARCHAR2
 ,x_display_in_inquiries_flag        IN VARCHAR2
 ,x_criterion_value_code             IN VARCHAR2
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_analytical_criterion_code        IN VARCHAR2
  ,x_analytical_criterion_type_co     IN VARCHAR2
  ,x_amb_context_code                 IN VARCHAR2);

PROCEDURE add_language;

PROCEDURE translate_row
  (p_amb_context_code                 IN VARCHAR2
  ,p_analytical_criterion_type_co     IN VARCHAR2
  ,p_analytical_criterion_code        IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_description                      IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2);

--================================================
-- Overloaded procedure to handle application
-- id to avoid deadlock while updating HDR ACs
--================================================
PROCEDURE translate_row
  (p_amb_context_code                 IN VARCHAR2
  ,p_analytical_criterion_type_co     IN VARCHAR2
  ,p_analytical_criterion_code        IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_description                      IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2
  ,p_application_short_name           IN VARCHAR2);

END xla_analytical_hdrs_f_pkg;

/
