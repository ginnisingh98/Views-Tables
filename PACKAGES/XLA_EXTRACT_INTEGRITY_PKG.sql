--------------------------------------------------------
--  DDL for Package XLA_EXTRACT_INTEGRITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_EXTRACT_INTEGRITY_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaamext.pkh 120.4 2005/05/04 12:22:15 ksvenkat ship $ */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_extract_integrity_pkg                                              |
|                                                                            |
| DESCRIPTION                                                                |
|     This is the specification of the package that validates that the       |
|     extract is valid for an event class and creates sources and            |
|     source assignments for the event class                                 |
|                                                                            |
| HISTORY                                                                    |
|     12/16/2003      Dimple Shah       Created                              |
|                                                                            |
+===========================================================================*/

-------------------------------------------------------------------------------
-- public routines
-------------------------------------------------------------------------------

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Check_extract_integrity                                               |
|                                                                       |
| This routine is called by the Create and Assign Sources program       |
| to do all validations for an event class                              |
|                                                                       |
+======================================================================*/
FUNCTION Check_extract_integrity
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2
          ,p_processing_mode             IN  VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Validate_extract_objects                                              |
|                                                                       |
| This routine is called to validate the extract objects                |
|                                                                       |
+======================================================================*/
FUNCTION Validate_extract_objects
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2   DEFAULT NULL
          ,p_event_class_code            IN  VARCHAR2   DEFAULT NULL
          ,p_amb_context_code            IN  VARCHAR2   DEFAULT NULL
          ,p_product_rule_type_code      IN  VARCHAR2   DEFAULT NULL
          ,p_product_rule_code           IN  VARCHAR2   DEFAULT NULL)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Validate_sources                                                      |
|                                                                       |
| This routine is called to insert all sources for an event class into  |
| a global temporary table before calling validate_sources_with_extract |
|                                                                       |
+======================================================================*/
FUNCTION Validate_sources
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Validate_sources_with_extract                                         |
|                                                                       |
| This routine is called to validate the sources with extract objects   |
|                                                                       |
+======================================================================*/
FUNCTION Validate_sources_with_extract
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2
          ,p_amb_context_code            IN  VARCHAR2   DEFAULT NULL
          ,p_product_rule_type_code      IN  VARCHAR2   DEFAULT NULL
          ,p_product_rule_code           IN  VARCHAR2   DEFAULT NULL)
RETURN BOOLEAN;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| Set_extract_object_owner                                              |
|                                                                       |
| This routine is called to get the owner for extract objects and       |
| store it in a GT table                                                |
|                                                                       |
+======================================================================*/
PROCEDURE Set_extract_object_owner
          (p_application_id              IN  NUMBER
          ,p_amb_context_code            IN  VARCHAR2   DEFAULT NULL
          ,p_product_rule_type_code      IN  VARCHAR2   DEFAULT NULL
          ,p_product_rule_code           IN  VARCHAR2   DEFAULT NULL
          ,p_entity_code                 IN  VARCHAR2   DEFAULT NULL
          ,p_event_class_code            IN  VARCHAR2   DEFAULT NULL);

END xla_extract_integrity_pkg;
 

/
