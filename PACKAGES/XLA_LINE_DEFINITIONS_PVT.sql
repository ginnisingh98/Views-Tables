--------------------------------------------------------
--  DDL for Package XLA_LINE_DEFINITIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_LINE_DEFINITIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: xlaamjld.pkh 120.7 2005/07/06 20:55:33 eklau ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_line_definitions_pvt                                           |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Product Rules package                                          |
|                                                                       |
| HISTORY                                                               |
|    10-05-2004  W Chan       Created                                   |
|                                                                       |
+======================================================================*/

--======================================================================
--
-- Name: copy_line_definition_details
-- Description: Copies the details of an existing line definition into the
--              new one
--
--======================================================================
PROCEDURE copy_line_definition_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_old_line_defn_owner_code         IN VARCHAR2
  ,p_old_line_defn_code               IN VARCHAR2
  ,p_new_line_defn_owner_code         IN VARCHAR2
  ,p_new_line_defn_code               IN VARCHAR2
  ,p_old_accounting_coa_id            IN NUMBER
  ,p_new_accounting_coa_id            IN NUMBER);


--======================================================================
--
-- Name: line_definition_in_use
-- Description: Returns true if the line definition is in use by AAD
--
--======================================================================
FUNCTION line_definition_in_use
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_owner               IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;


--======================================================================
--
-- Name:  line_definition_is_locked
-- Description: Returns true if the line definition is not used by any
--              AAD that is locked
--
--======================================================================
FUNCTION line_definition_is_locked
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN;


FUNCTION line_definition_is_locked
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_owner               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                  IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag              IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;


--======================================================================
--
-- Name: delete_line_defn_details
-- Description: Deletes all details of the line definition
--
--======================================================================
PROCEDURE delete_line_defn_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2);


--======================================================================
--
-- Name: delete_line_defn_jlt_details
-- Description: Deletes all details of the line assignment
--
--======================================================================
PROCEDURE delete_line_defn_jlt_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2);


--======================================================================
--
-- Name: invalid_line_description
-- Description: Returns true if sources used in the description are invalid
--              Used in the lov for descriptions
--
--======================================================================
 FUNCTION invalid_line_description
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_description_type_code            IN VARCHAR2
  ,p_description_code                 IN VARCHAR2)
RETURN VARCHAR2;


--======================================================================
--
-- Name: invalid_seg_rule
-- Description: Returns true if sources used in the ADR are invalid
--              Used in the lov for descriptions
--
--======================================================================
FUNCTION invalid_segment_rule
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_segment_rule_appl_id             IN NUMBER DEFAULT NULL
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2)
RETURN VARCHAR2;


--======================================================================
--
-- Name: uncompile_aads
-- Description: Returns true if all product rules that as referenced the
--              line definition gets uncompiled
--
--======================================================================
FUNCTION uncompile_aads
  (p_amb_context_code                 IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                  IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag              IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;


--======================================================================
--
-- Name: invalid_line_analytical
-- Description: Returns true if sources used in the AC are invalid
--              Used in the lov for analytical criteria
--
--======================================================================
 FUNCTION invalid_line_analytical
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_ac_type_code                     IN VARCHAR2
  ,p_ac_code                          IN VARCHAR2)
RETURN VARCHAR2;


--======================================================================
--
-- Name: copy_line_assignment_details
-- Description: Copies the details of an existing line assignment into
--              a new one
--
--======================================================================
 PROCEDURE copy_line_assignment_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,p_old_accting_line_type_code       IN VARCHAR2
  ,p_old_accounting_line_code         IN VARCHAR2
  ,p_new_accting_line_type_code       IN VARCHAR2
  ,p_new_accounting_line_code         IN VARCHAR2
  ,p_include_ac_assignments           IN VARCHAR2
  ,p_include_adr_assignments          IN VARCHAR2
  ,p_mpa_option_code                  IN VARCHAR2);


--=============================================================================
--
-- Name: get_line_definition_info
-- Description: Validate the line definition
--
--=============================================================================
PROCEDURE get_line_definition_info
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,x_line_definition_owner            IN OUT NOCOPY VARCHAR2
  ,x_line_definition_name             IN OUT NOCOPY VARCHAR2);


--======================================================================
--
-- Name: validate_line_definition
-- Description: Validate the line definition.  This API DOES NOT clear
--              the error stack and DOES NOT insert the error to the
--              error table
--              This API is used if multiple journal line definition is
--              validated
--
--======================================================================
 FUNCTION validate_line_definition
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
 RETURN BOOLEAN;

--=============================================================================
--
-- Name: validate_jld
-- Description: Validate the joural lines definition. This API reset the error
--              stack and insert the errors to the error table.
--              This API is used if only one journal line definition is
--              validated
--
--=============================================================================
FUNCTION validate_jld
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN;

--======================================================================
--
-- Name: check_copy_line_definition
-- Description: Checks if the line definition can be copied into a new one
--
--======================================================================
FUNCTION check_copy_line_definition
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_old_line_defn_owner_code         IN VARCHAR2
  ,p_old_line_defn_code               IN VARCHAR2
  ,p_old_accounting_coa_id            IN NUMBER
  ,p_new_accounting_coa_id            IN NUMBER
  ,p_message                          IN OUT NOCOPY VARCHAR2
  ,p_token_1                          IN OUT NOCOPY VARCHAR2
  ,p_value_1                          IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

--======================================================================
--
-- Name: check_adr_has_loop
-- Description: Returns true if the ADR has an attached ADR which in
-- turn has another ADR attached
--
--======================================================================
FUNCTION check_adr_has_loop
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2)
RETURN BOOLEAN;

--======================================================================
--
-- Name: delete_mpa_jlt_details
-- Description: Deletes all details of the mpa line assignment.
--
--    Add for MPA project - 4262811
--
--======================================================================
PROCEDURE delete_mpa_jlt_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_line_definition_owner_code       IN VARCHAR2
  ,p_line_definition_code             IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,p_mpa_accounting_line_type_co      IN VARCHAR2
  ,p_mpa_accounting_line_code         IN VARCHAR2);

END xla_line_definitions_pvt;
 

/
