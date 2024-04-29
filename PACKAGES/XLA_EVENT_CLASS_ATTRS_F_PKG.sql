--------------------------------------------------------
--  DDL for Package XLA_EVENT_CLASS_ATTRS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_EVENT_CLASS_ATTRS_F_PKG" AUTHID CURRENT_USER AS
/* $Header: xlatbeca.pkh 120.10 2005/08/19 01:41:07 wychan ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_classes_attr_f_pkg                                             |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_classes_attr                          |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/

PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_class_group_code           IN VARCHAR2
  ,x_je_category_name                 IN VARCHAR2
  ,x_reporting_view_name              IN VARCHAR2
  ,x_allow_actuals_flag               IN VARCHAR2
  ,x_allow_budgets_flag               IN VARCHAR2
  ,x_allow_encumbrance_flag           IN VARCHAR2
  ,x_calculate_acctd_amts_flag        IN VARCHAR2
  ,x_calculate_g_l_amts_flag          IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE lock_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_class_group_code           IN VARCHAR2
  ,x_je_category_name                 IN VARCHAR2
  ,x_reporting_view_name              IN VARCHAR2
  ,x_allow_actuals_flag               IN VARCHAR2
  ,x_allow_budgets_flag               IN VARCHAR2
  ,x_allow_encumbrance_flag           IN VARCHAR2
  ,x_calculate_acctd_amts_flag        IN VARCHAR2
  ,x_calculate_g_l_amts_flag          IN VARCHAR2);

PROCEDURE update_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_class_group_code           IN VARCHAR2
  ,x_je_category_name                 IN VARCHAR2
  ,x_reporting_view_name              IN VARCHAR2
  ,x_allow_actuals_flag               IN VARCHAR2
  ,x_allow_budgets_flag               IN VARCHAR2
  ,x_allow_encumbrance_flag           IN VARCHAR2
  ,x_calculate_acctd_amts_flag        IN VARCHAR2
  ,x_calculate_g_l_amts_flag          IN VARCHAR2
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER);

PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2);

PROCEDURE load_row
(p_application_short_name             IN VARCHAR2
,p_entity_code                        IN VARCHAR2
,p_event_class_code                   IN VARCHAR2
,p_event_class_group_code             IN VARCHAR2
,p_je_category_key                    IN VARCHAR2
,p_reporting_view_name                IN VARCHAR2
,p_allow_actuals_flag                 IN VARCHAR2
,p_allow_budgets_flag                 IN VARCHAR2
,p_allow_encumbrance_flag             IN VARCHAR2
,p_calculate_acctd_amts_flag          IN VARCHAR2
,p_calculate_g_l_amts_flag            IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2);

/*
PROCEDURE load_row
(p_application_short_name             IN VARCHAR2
,p_entity_code                        IN VARCHAR2
,p_event_class_code                   IN VARCHAR2
,p_event_class_group_code             IN VARCHAR2
,p_je_category_name                   IN VARCHAR2
,p_reporting_view_name                IN VARCHAR2
,p_allow_actuals_flag                 IN VARCHAR2
,p_allow_budgets_flag                 IN VARCHAR2
,p_allow_encumbrance_flag             IN VARCHAR2
,p_calculate_acctd_amts_flag          IN VARCHAR2
,p_calculate_g_l_amts_flag            IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2);
*/

END xla_event_class_attrs_f_pkg;
 

/
