--------------------------------------------------------
--  DDL for Package XLA_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_SOURCES_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamdss.pkh 120.15 2006/01/09 14:24:17 vkasina ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_sources_pkg                                                    |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Sources Package                                                |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| source_in_use                                                         |
|                                                                       |
| Returns true if the source is being used                              |
|                                                                       |
+======================================================================*/
FUNCTION source_in_use
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_source_msg                       OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| source_is_locked                                                      |
|                                                                       |
| Returns true if the source is being used by a locked product rule     |
|                                                                       |
+======================================================================*/
FUNCTION source_is_locked
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_prod_rule                                                   |
|                                                                       |
| Wrapper for uncompile_definitions                                     |
| Provided for backward-compatibility, to be obsoleted                  |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_prod_rule
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type                IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Sets status of assigned application accounting definitions and        |
| journal lines definitions to uncompiled                               |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_definitions
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                  IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag              IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_derived_source_details                                         |
|                                                                       |
| Deletes details of the derived source when derived source is deleted  |
|                                                                       |
+======================================================================*/
PROCEDURE delete_derived_source_details
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| derived_source_is_invalid                                             |
|                                                                       |
| Returns true if the derived source has seeded sources not belonging   |
| to the event class or entity                                          |
|                                                                       |
+======================================================================*/
FUNCTION derived_source_is_invalid
  (p_application_id                           IN NUMBER
  ,p_derived_source_code                      IN VARCHAR2
  ,p_derived_source_type_code                 IN VARCHAR2
  ,p_entity_code                              IN VARCHAR2
  ,p_event_class_code                         IN VARCHAR2
  ,p_level                                    IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION derived_source_is_invalid
  (p_application_id                           IN NUMBER
  ,p_derived_source_code                      IN VARCHAR2
  ,p_derived_source_type_code                 IN VARCHAR2
  ,p_event_class_code                         IN VARCHAR2
  ,p_level                                    IN VARCHAR2)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| source_in_use_by_tab                                                  |
|                                                                       |
| Returns true if the source is being used by transaction account type  |
|                                                                       |
+======================================================================*/
FUNCTION source_in_use_by_tab
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| source_is_locked_by_tab                                               |
|                                                                       |
| Returns true if the source is being used by a locked product rule     |
|                                                                       |
+======================================================================*/
FUNCTION source_is_locked_by_tab
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_tran_acct_def                                               |
|                                                                       |
| Sets status of the assigned transaction account definition            |
| to uncompiled                                                         |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_tran_acct_def
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_trx_acct_def                     IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def_type                IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| source_in_use_by_tad                                                  |
|                                                                       |
| Returns true if the source is being used by a transaction account     |
| definition                                                            |
|                                                                       |
+======================================================================*/
FUNCTION source_in_use_by_tad
  (p_application_id                   IN NUMBER
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_account_type_code                IN VARCHAR2)
RETURN VARCHAR2;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_derived_source_level                                              |
|                                                                       |
| Gets the level of derived source if the source belongs to the event   |
| class                                                                 |
|                                                                       |
+======================================================================*/
FUNCTION get_derived_source_level
  (p_application_id                   IN NUMBER
  ,p_derived_source_type_code         IN VARCHAR2
  ,p_derived_source_code              IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2)
RETURN VARCHAR2;

END xla_sources_pkg;
 

/
