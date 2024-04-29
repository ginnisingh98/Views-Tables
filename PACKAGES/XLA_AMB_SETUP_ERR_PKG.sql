--------------------------------------------------------
--  DDL for Package XLA_AMB_SETUP_ERR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_AMB_SETUP_ERR_PKG" AUTHID CURRENT_USER AS
-- $Header: xlaamerr.pkh 120.5 2005/06/28 20:10:19 dcshah ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_amb_setup_err_pkg                                                  |
|                                                                            |
| DESCRIPTION                                                                |
|     This is the specification of the package that handles errors for       |
|     accounting methods builder setups.                                     |
|                                                                            |
| HISTORY                                                                    |
|     12/10/2003      Dimple Shah       Created                              |
|                                                                            |
+===========================================================================*/

-------------------------------------------------------------------------------
-- declaring types
-------------------------------------------------------------------------------
TYPE t_array_error IS TABLE OF xla_amb_setup_errors%rowtype
INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- public routines
-------------------------------------------------------------------------------

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| Initialize                                                            |
|                                                                       |
| This routine is called in the beginning of the program                |
| to initialize the array                                               |
|                                                                       |
+======================================================================*/
PROCEDURE initialize
       (p_request_id              IN  NUMBER   DEFAULT NULL);

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| Stack_Error                                                           |
|                                                                       |
| This routine is called to stack the error into a plsql array          |
|                                                                       |
+======================================================================*/
PROCEDURE stack_error
       (p_message_name               IN  VARCHAR2
       ,p_message_type               IN  VARCHAR2
       ,p_message_category           IN  VARCHAR2
       ,p_category_sequence          IN  NUMBER
       ,p_application_id             IN  NUMBER
       ,p_amb_context_code           IN  VARCHAR2 DEFAULT NULL
       ,p_product_rule_type_code     IN  VARCHAR2 DEFAULT NULL
       ,p_product_rule_code          IN  VARCHAR2 DEFAULT NULL
       ,p_entity_code                IN  VARCHAR2 DEFAULT NULL
       ,p_event_class_code           IN  VARCHAR2 DEFAULT NULL
       ,p_event_type_code            IN  VARCHAR2 DEFAULT NULL
       ,p_line_definition_owner_code IN  VARCHAR2 DEFAULT NULL
       ,p_line_definition_code       IN  VARCHAR2 DEFAULT NULL
       ,p_accounting_line_type_code  IN  VARCHAR2 DEFAULT NULL
       ,p_accounting_line_code       IN  VARCHAR2 DEFAULT NULL
       ,p_description_type_code      IN  VARCHAR2 DEFAULT NULL
       ,p_description_code           IN  VARCHAR2 DEFAULT NULL
       ,p_anal_criterion_type_code   IN  VARCHAR2 DEFAULT NULL
       ,p_anal_criterion_code        IN  VARCHAR2 DEFAULT NULL
       ,p_segment_rule_type_code     IN  VARCHAR2 DEFAULT NULL
       ,p_segment_rule_code          IN  VARCHAR2 DEFAULT NULL
       ,p_mapping_set_code           IN  VARCHAR2 DEFAULT NULL
       ,p_source_application_id      IN  NUMBER   DEFAULT NULL
       ,p_source_type_code           IN  VARCHAR2 DEFAULT NULL
       ,p_source_code                IN  VARCHAR2 DEFAULT NULL
       ,p_extract_object_name        IN  VARCHAR2 DEFAULT NULL
       ,p_extract_object_type        IN  VARCHAR2 DEFAULT NULL
       ,p_accounting_source_code     IN  VARCHAR2 DEFAULT NULL
       ,p_accounting_group_code      IN  VARCHAR2 DEFAULT NULL
       ,p_extract_column_name        IN  VARCHAR2 DEFAULT NULL
       ,p_language                   IN  VARCHAR2 DEFAULT NULL
       ,p_mpa_acct_line_type_code    IN  VARCHAR2 DEFAULT NULL
       ,p_mpa_acct_line_code         IN  VARCHAR2 DEFAULT NULL                       );

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| Insert_Errors                                                         |
|                                                                       |
| This routine is called at the end of the program to insert all        |
| errors from the plsql array into the error table                      |
|                                                                       |
+======================================================================*/
PROCEDURE insert_errors;
END;
 

/
