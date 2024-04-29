--------------------------------------------------------
--  DDL for Package GL_CHART_OF_ACCOUNTS_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CHART_OF_ACCOUNTS_API_PKG" AUTHID CURRENT_USER AS
/* $Header: gluvcoas.pls 120.0 2003/01/31 23:40:47 djogg ship $ */
--
-- Package
--   GL_CHART_OF_ACCOUNTS_API_PKG
-- Purpose
--   This package specification is used to validate the chart of accounts information
-- imported with iSpeed.
-- History
--   10.09.2000  O Monnier      Created.

--
-- EXCEPTIONS
--
  invalid_dml_mode              EXCEPTION;
  flexfield_not_supported       EXCEPTION;
  flexfield_must_exist          EXCEPTION;
  dynamic_inserts_not_allowed   EXCEPTION;
  multiflex_not_allowed         EXCEPTION;
  structure_name_not_unique     EXCEPTION;
  invalid_app_column_name       EXCEPTION;
  segment_num_not_unique        EXCEPTION;
  gl_segment_must_be_required   EXCEPTION;
  gl_segment_must_be_displayed  EXCEPTION;
  value_set_must_exist          EXCEPTION;
  gl_value_set_must_exist       EXCEPTION;
  invalid_value_set             EXCEPTION;
  gl_format_must_be_char        EXCEPTION;
  maximum_size_too_large        EXCEPTION;
  invalid_default_value         EXCEPTION;
  vset_security_not_enabled     EXCEPTION;
  display_size_too_large        EXCEPTION;
  invalid_date_default_type     EXCEPTION;
  invalid_time_default_type     EXCEPTION;
  invalid_seg_attribute_type    EXCEPTION;
  invalid_assignment_date_order EXCEPTION;
  global_qualifier_error        EXCEPTION;
  qualifier_not_unique          EXCEPTION;
  invalid_value_set_name        EXCEPTION;
  invalid_minimum_maximum       EXCEPTION;
  invalid_dependant_value       EXCEPTION;
  invalid_minimum_value         EXCEPTION;
  invalid_maximum_value         EXCEPTION;
  invalid_minormax_value        EXCEPTION;
  invalid_value                 EXCEPTION;
  invalid_compiled_value_attr1  EXCEPTION;
  invalid_compiled_value_attr2  EXCEPTION;
  invalid_compiled_value_attr3  EXCEPTION;
  invalid_val_attribute_type    EXCEPTION;
  value_meaning_not_unique      EXCEPTION;
  invalid_value_meaning         EXCEPTION;
  attribute_must_exist          EXCEPTION;
  required_attr_must_exist      EXCEPTION;
  invalid_low_high_range_code   EXCEPTION;
  sum_maximum_size_too_large    EXCEPTION;
  gl_segment_not_consecutive    EXCEPTION;
  gl_same_bal_acct_segment      EXCEPTION;
  invalid_application_id        EXCEPTION;
  invalid_structure_code        EXCEPTION;
  hierarchy_loop                EXCEPTION;
  invalid_parent                EXCEPTION;
  request_failed                EXCEPTION;

--
-- PUBLIC FUNCTIONS
--

  --
  -- Procedure
  --   validate_structure
  -- Purpose
  --   Do the validation for the structure
  --   (FND_ID_FLEX_STRUCTURES table).
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_structure(v_application_id            IN NUMBER,
                               v_id_flex_code              IN VARCHAR2,
                               v_id_flex_num               IN NUMBER,
                               v_dynamic_inserts_allowed_f IN VARCHAR2,
                               v_operation                 IN VARCHAR2 DEFAULT 'DML_INSERT');

  --
  -- Procedure
  --   validate_structure_tl
  -- Purpose
  --   Do the validation for the translated structure
  --   (FND_ID_FLEX_STRUCTURES_TL table).
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_structure_tl(v_application_id           IN NUMBER,
                                  v_id_flex_code             IN VARCHAR2,
                                  v_id_flex_num              IN NUMBER,
                                  v_language                 IN VARCHAR2,
                                  v_id_flex_structure_name   IN VARCHAR2,
                                  v_userenvlang              IN VARCHAR2);

  --
  -- Procedure
  --   validate_segment
  -- Purpose
  --   Do the validation for one particular segment of a structure
  --   (FND_ID_FLEX_SEGMENTS table).
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_segment(v_application_id           IN NUMBER,
                             v_id_flex_code             IN VARCHAR2,
                             v_id_flex_num              IN NUMBER,
                             v_application_column_name  IN VARCHAR2,
                             v_segment_name             IN VARCHAR2,
                             v_segment_num              IN NUMBER,
                             v_enabled_flag             IN VARCHAR2,
                             v_required_flag            IN VARCHAR2,
                             v_display_flag             IN VARCHAR2,
                             v_display_size             IN NUMBER,
                             v_security_enabled_flag    IN VARCHAR2,
                             v_flex_value_set_id        IN NUMBER,
                             v_default_type             IN VARCHAR2,
                             v_default_value            IN VARCHAR2);


  --
  -- Procedure
  --   validate_segment_tl
  -- Purpose
  --   Do the validation for one particular translated segment of a structure
  --   (FND_ID_FLEX_SEGMENTS_TL table).
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_segment_tl(v_application_id           IN NUMBER,
                                v_id_flex_code             IN VARCHAR2,
                                v_id_flex_num              IN NUMBER,
                                v_application_column_name  IN VARCHAR2,
                                v_language                 IN VARCHAR2);


  --
  -- Procedure
  --   validate_seg_attribute_value
  -- Purpose
  --   Do the validation for one particular segment attribute
  --   (FND_SEGMENT_ATTRIBUTE_VALUES table)
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_seg_attribute_value(v_application_id           IN NUMBER,
                                         v_id_flex_code             IN VARCHAR2,
                                         v_id_flex_num              IN NUMBER,
                                         v_application_column_name  IN VARCHAR2,
                                         v_segment_attribute_type   IN VARCHAR2,
                                         v_attribute_value          IN VARCHAR2);


  --
  -- Procedure
  --   validate_value_set
  -- Purpose
  --   Do the validation for one particular value set
  --   (FND_FLEX_VALUE_SETS table)
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_value_set(v_flex_value_set_id         IN NUMBER,
                               v_flex_value_set_name       IN VARCHAR2,
                               v_format_type               IN VARCHAR2,
                               v_maximum_size              IN NUMBER,
                               v_alphanumeric_allowed_flag IN VARCHAR2,
                               v_uppercase_only_flag       IN VARCHAR2,
                               v_numeric_mode_enabled_flag IN VARCHAR2,
                               v_dependant_default_value   IN VARCHAR2,
                               v_minimum_value             IN VARCHAR2,
                               v_maximum_value             IN VARCHAR2,
                               v_number_precision          IN NUMBER);


  --
  -- Procedure
  --   validate_validation_qualifier
  --   (FND_FLEX_VALIDATION_QUALIFIERS table)
  -- Purpose
  --   Do the validation for one particular validation qualifier
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_validation_qualifier(v_id_flex_application_id     IN NUMBER,
                                          v_id_flex_code               IN VARCHAR2,
                                          v_flex_value_set_id          IN NUMBER,
                                          v_segment_attribute_type     IN VARCHAR2,
                                          v_value_attribute_type       IN VARCHAR2);

  --
  -- Procedure
  --   validate_value
  --   (FND_FLEX_VALUES table)
  -- Purpose
  --   Do the validation for one particular value of a value set.
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_value(v_flex_value_id             IN NUMBER,
                           v_flex_value_set_id         IN NUMBER,
                           v_flex_value                IN VARCHAR2,
                           v_compiled_value_attributes IN VARCHAR2);


  --
  -- Procedure
  --   validate_value_tl
  --   (FND_FLEX_VALUES_TL table)
  -- Purpose
  --   Do the validation for one particular translated value of a value set.
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_value_tl(v_flex_value_id          IN NUMBER,
                              v_language               IN VARCHAR2,
                              v_flex_value_meaning     IN VARCHAR2,
                              v_userenvlang            IN VARCHAR2);


  --
  -- Procedure
  --   validate_final_structure
  -- Purpose
  --   Do the final validation when all the rows has been inserted in the
  --   database for one particular structure:
  --   Check that the structure has all the global and required qualifiers.
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_final_structure(v_application_id           IN NUMBER,
                                     v_id_flex_code             IN VARCHAR2,
                                     v_id_flex_num              IN NUMBER);


  --
  -- Procedure
  --   compile_key_flexfield
  -- Purpose
  --   Compile the key flexfield if needed.
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  FUNCTION compile_key_flexfield(v_application_id           IN NUMBER,
                                 v_id_flex_code             IN VARCHAR2,
                                 v_id_flex_structure_code   IN VARCHAR2) RETURN VARCHAR2;

  --
  -- Procedure
  --  validate_hierarchy
  -- Purpose
  --  Detect hierarchy loop in rows to be added to
  --  fnd_flex_value_norm_hierarchy
  -- History
  --   02.03.2001  M Marra      Created.
  --   03.08.2001  M Marra      Modified to work row by row
  --                            rather than validating the entire hierarchy
  --                            at once.  This reflects the repositioning of
  --                            FndFlexValueNormHierarchyEO to a composite
  --                            child of FndFlexValueEO.
  --
  procedure validate_hierarchy (
    p_parent        IN varchar2,
    p_child_low     IN varchar2,
    p_child_high    IN varchar2,
    p_value_set_id  IN number);

  --
  -- Function
  --   compile_hierarchy
  -- Purpose
  --   Compile hierarchy data from fnd_flex_value_norm_hierarchy.
  -- History
  --   02.03.2001  MMarra      Created.
  --
  FUNCTION compile_hierarchy (
    p_flex_value_set_id   IN   NUMBER
  ) RETURN VARCHAR2;

END GL_CHART_OF_ACCOUNTS_API_PKG;

 

/
