--------------------------------------------------------
--  DDL for Package Body GL_CHART_OF_ACCOUNTS_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CHART_OF_ACCOUNTS_API_PKG" AS
/* $Header: gluvcoab.pls 120.2 2005/03/31 13:39:29 knag ship $ */
--
-- Package
--   GL_CHART_OF_ACCOUNTS_API_PKG
-- Purpose
--   This package is used to validate the chart of accounts information
-- imported with iSpeed.
-- History
--   10.09.2000  O Monnier      Created.

--
-- PRIVATE FUNCTIONS
--

  --
  -- Function
  --  has_loop
  -- Purpose
  --  "Borrowed" this from the JAHE project...test to see
  --  if any of test_value's ancestors are parent_value
  --
  -- History
  --   02.03.2001  M Marra      Created.
  --
  FUNCTION has_loop ( source          IN      VARCHAR2,
                      target          IN      VARCHAR2,
                      value_set_id    IN      NUMBER
  ) RETURN BOOLEAN IS
    CURSOR find_parent_cursor IS
       SELECT   parent_flex_value, range_attribute
       FROM  fnd_flex_value_norm_hierarchy
       WHERE flex_value_set_id = value_set_id
       AND   target BETWEEN  child_flex_value_low
                        AND  child_flex_value_high;
    parent find_parent_cursor%ROWTYPE;
  BEGIN
    OPEN find_parent_cursor;
    LOOP
     FETCH find_parent_cursor INTO parent;
     IF ( find_parent_cursor%NOTFOUND ) THEN
       CLOSE find_parent_cursor;
       RETURN(FALSE);
     ELSIF ( parent.parent_flex_value = source ) THEN
       CLOSE find_parent_cursor;
       RETURN(TRUE);
     ELSIF ( has_loop(source, parent.parent_flex_value, value_set_id) ) THEN
       CLOSE find_parent_cursor;
       RETURN(TRUE);
     END IF;
    END LOOP;
    CLOSE find_parent_cursor;
    RETURN(FALSE);
  END has_loop;


  --
  -- Function
  --   is_flexfield_supported
  -- Purpose
  --   Check if the flexfield is supported by the API
  --   Currently, only the GL Accounting flexfield is supported, but we may
  --   add some supports for other flexfields later.
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  FUNCTION is_flexfield_supported(v_application_id            IN NUMBER,
                                  v_id_flex_code              IN VARCHAR2) RETURN BOOLEAN
  IS
  BEGIN
    --
    -- Only the GL Accounting is supported by the API now.
    --
    IF (v_application_id = 101 AND v_id_flex_code = 'GL#') THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END;

--
-- PUBLIC FUNCTIONS
--

  --
  -- Procedure
  --   validate_structure
  -- Purpose
  --   Do the validation for the structure
  --   (FND_ID_FLEX_STRUCTURES table)
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_structure(v_application_id            IN NUMBER,
                               v_id_flex_code              IN VARCHAR2,
                               v_id_flex_num               IN NUMBER,
                               v_dynamic_inserts_allowed_f IN VARCHAR2,
                               v_operation                 IN VARCHAR2 DEFAULT 'DML_INSERT')
  IS
/* NOT NEEDED FOR THE CHART OF ACCOUNTS FLEXFIELD
   ONLY NEEDED FOR OTHER FLEXFIELDS
    v_dynamic_inserts_feasible_f   VARCHAR2(1);
    v_set_defining_column_name     VARCHAR2(30);

    -- Retrieve the flexfield information required for the validation from the structure.
    CURSOR c_flex IS
      SELECT dynamic_inserts_feasible_flag,
             set_defining_column_name
      FROM FND_ID_FLEXS
      WHERE application_id = v_application_id
        AND id_flex_code = v_id_flex_code;*/

  BEGIN
    --
    -- Check the mode.
    --
    IF (v_operation<> 'DML_INSERT' AND v_operation<> 'DML_UPDATE') THEN
      RAISE invalid_dml_mode;
    END IF;

    --
    -- Check if the flexfield is supported by the API
    --
    IF (NOT is_flexfield_supported(v_application_id => v_application_id,
                                   v_id_flex_code => v_id_flex_code))
    THEN
      RAISE flexfield_not_supported;
    END IF;

/* NOT NEEDED FOR THE CHART OF ACCOUNTS FLEXFIELD
   ONLY NEEDED FOR OTHER FLEXFIELDS
    --
    -- Retrieve the useful information for the validation logic from the flexfield.
    --
    OPEN c_flex;
    FETCH c_flex
    INTO v_dynamic_inserts_feasible_f,
         v_set_defining_column_name;

    --
    -- Check that the flexfield exists
    --
    IF c_flex%FOUND THEN
      CLOSE c_flex;
    ELSE
      CLOSE c_flex;
      RAISE flexfield_must_exist;
    END IF;

    --
    -- Check to see multiflex is allowed for this
    -- flexfield. Multiflex is not allowed for flexfields
    -- without a structure defining column and for
    -- flexfields using the set feature (hard coded here)
    -- Flag error if a new record is being created for
    -- these flexfields. The default 101 structure will be
    -- created on registering the flexfield.
    --
    IF (v_operation = 'DML_INSERT' AND ((v_set_defining_column_name IS NULL) OR
                                        (v_id_flex_code IN ('MSTK', 'MTLL', 'MICG', 'MDSP')))) THEN
      RAISE multiflex_not_allowed;
    END IF;

    --
    -- Check to see dynamic insert is allowed for this flexfield.
    --
    IF (v_dynamic_inserts_feasible_f = 'N' AND v_dynamic_inserts_allowed_f = 'Y') THEN
      RAISE dynamic_inserts_not_allowed;
    END IF;*/

    --
    -- **GL Accounting Flexfield specific validation**
    -- After inserting a new structure for the "GL Accounting Flexfield",
    -- we also need to insert some default rows into the FND_FLEX_WORKFLOW_PROCESSES table.
    --
    IF (v_application_id = 101 AND v_id_flex_code = 'GL#'
        AND v_id_flex_num <> 101 AND v_operation = 'DML_INSERT') THEN
      INSERT INTO FND_FLEX_WORKFLOW_PROCESSES(APPLICATION_ID,
                                              ID_FLEX_CODE,
                                              ID_FLEX_NUM,
                                              WF_ITEM_TYPE,
                                              WF_PROCESS_NAME,
                                              LAST_UPDATE_DATE,
                                              LAST_UPDATED_BY,
                                              CREATION_DATE,
                                              CREATED_BY,
                                              LAST_UPDATE_LOGIN)
      SELECT FS.APPLICATION_ID,
             FS.ID_FLEX_CODE,
             FS.ID_FLEX_NUM,
             FWP.WF_ITEM_TYPE,
             'DEFAULT_ACCOUNT_GENERATION',
             SYSDATE,
             FS.LAST_UPDATED_BY,
             SYSDATE,
             FS.CREATED_BY,
             FS.LAST_UPDATE_LOGIN
      FROM FND_FLEX_WORKFLOW_PROCESSES FWP,
           FND_ID_FLEX_STRUCTURES FS
      WHERE FWP.APPLICATION_ID = v_application_id
        AND FWP.ID_FLEX_CODE = v_id_flex_code
        AND FWP.ID_FLEX_NUM = 101
        AND FS.APPLICATION_ID = v_application_id
        AND FS.ID_FLEX_CODE = v_id_flex_code
        AND FS.ID_FLEX_NUM = v_id_flex_num
        AND NOT EXISTS (SELECT 'Row already exists'
                        FROM FND_FLEX_WORKFLOW_PROCESSES FWP2
                        WHERE FWP2.APPLICATION_ID = v_application_id
                          AND FWP2.ID_FLEX_CODE = v_id_flex_code
                          AND FWP2.ID_FLEX_NUM = v_id_flex_num
                          AND FWP2.WF_ITEM_TYPE = FWP.WF_ITEM_TYPE);
    END IF;

    --
    -- The structure has been validated successfully.
    --
    return;

  EXCEPTION
    WHEN invalid_dml_mode THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_structure');
      fnd_message.set_token('EVENT','INVALID_DML_MODE');
      app_exception.raise_exception;

    WHEN flexfield_not_supported THEN
      fnd_message.set_name('SQLGL','GL_API_COA_FLEX_NOT_SUPPORTED');
      app_exception.raise_exception;

/* NOT NEEDED FOR THE CHART OF ACCOUNTS FLEXFIELD
   ONLY NEEDED FOR OTHER FLEXFIELDS
    WHEN flexfield_must_exist THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_structure');
      fnd_message.set_token('EVENT','flexfield_must_exist');
      app_exception.raise_exception;

    WHEN multiflex_not_allowed THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_structure');
      fnd_message.set_token('EVENT','multiflex_not_allowed');
      app_exception.raise_exception;

    WHEN dynamic_inserts_not_allowed THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_structure');
      fnd_message.set_token('EVENT','dynamic_inserts_not_allowed');
      app_exception.raise_exception;*/

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_structure');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;

  END validate_structure;


  --
  -- Procedure
  --   validate_structure_tl
  -- Purpose
  --   Do the validation for the translated structure
  --   (FND_ID_FLEX_STRUCTURES_TL table)
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_structure_tl(v_application_id           IN NUMBER,
                                  v_id_flex_code             IN VARCHAR2,
                                  v_id_flex_num              IN NUMBER,
                                  v_language                 IN VARCHAR2,
                                  v_id_flex_structure_name   IN VARCHAR2,
                                  v_userenvlang              IN VARCHAR2)
  IS
    v_count          NUMBER;

  BEGIN
    --
    -- Check if the flexfield is supported by the API
    --
    IF (NOT is_flexfield_supported(v_application_id => v_application_id,
                                   v_id_flex_code => v_id_flex_code))
    THEN
      RAISE flexfield_not_supported;
    END IF;

    --
    -- Check that IdFlexStructureName is unique for a particular key flexfield if the language
    -- is userenv('LANG').
    --
    IF (v_userenvlang = v_language) THEN
      SELECT count(*)
      INTO   v_count
      FROM   FND_ID_FLEX_STRUCTURES_VL
      WHERE  application_id = v_application_id
        AND  id_flex_code = v_id_flex_code
        AND  id_flex_structure_name = v_id_flex_structure_name;

      IF (v_count > 1) THEN
        RAISE structure_name_not_unique;
      END IF;
    END IF;

    --
    -- The structure tl has been validated successfully.
    --
    return;

  EXCEPTION
    WHEN flexfield_not_supported THEN
      fnd_message.set_name('SQLGL','GL_API_COA_FLEX_NOT_SUPPORTED');
      app_exception.raise_exception;

    WHEN structure_name_not_unique THEN
      fnd_message.set_name('FND','FLEX-DUPLICATE STRUCTURE NAME');
      app_exception.raise_exception;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_structure_tl');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;

  END validate_structure_tl;


  --
  -- Procedure
  --   validate_segment
  -- Purpose
  --   Do the validation for one particular segment of a structure
  --   (FND_ID_FLEX_SEGMENTS table)
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
                             v_default_value            IN VARCHAR2)
  IS
    v_count                      NUMBER;
    v_industry_type              VARCHAR2(1);
    v_flex_value_set_name        VARCHAR2(60) := '';
    v_validation_type            VARCHAR2(1) := '';
    v_vset_security_enabled_flag VARCHAR2(1) := '';
    v_format_type                VARCHAR2(1) := '';
    v_maximum_size               NUMBER(3) := '';
    v_number_precision           NUMBER(3) := '';
    v_alphanumeric_allowed_flag  VARCHAR2(1) := '';
    v_uppercase_only_flag        VARCHAR2(1) := '';
    v_numeric_mode_enabled_flag  VARCHAR2(1) := '';
    v_minimum_value              VARCHAR2(150) := '';
    v_maximum_value              VARCHAR2(150) := '';
    v_storage_value              VARCHAR2(2000) := '';
    v_display_value              VARCHAR2(2000) := '';
    v_width                      NUMBER(15);
    v_column_type                VARCHAR2(1);
    v_defined                    BOOLEAN;
    -- v_check_format_type          VARCHAR2(1);

    -- Retrieve the value set information required for the validation from the value set id.
    CURSOR c_flex_value_set IS
      SELECT flex_value_set_name,
             validation_type,
             security_enabled_flag,
             format_type,
             maximum_size,
             number_precision,
             alphanumeric_allowed_flag,
             uppercase_only_flag,
             numeric_mode_enabled_flag,
             minimum_value,
             maximum_value
      FROM FND_FLEX_VALUE_SETS
      WHERE flex_value_set_id = v_flex_value_set_id;

    -- Validate the application_column_name
    CURSOR c_check_column_name IS
       SELECT c.width, c.column_type
         FROM FND_COLUMNS c,
              FND_TABLES t,
              FND_ID_FLEXS f
        WHERE c.application_id = t.application_id
          AND c.table_id = t.table_id
          AND c.column_name = v_application_column_name
          AND c.flexfield_usage_code = 'K'
          AND t.application_id = f.table_application_id
          AND t.table_name = f.application_table_name
          AND f.application_id = v_application_id
          AND f.id_flex_code = v_id_flex_code
          AND ( (v_industry_type = 'G'
                 AND v_id_flex_code = 'GLAT'
                 OR ((v_id_flex_code <> 'GLAT') and (c.column_name not like 'SEGMENT_ATTRIBUTE%')))
               OR NVL(v_industry_type, 'C') <> 'G');

  BEGIN
    --
    -- Check if the flexfield is supported by the API
    --
    IF (NOT is_flexfield_supported(v_application_id => v_application_id,
                                   v_id_flex_code => v_id_flex_code))
    THEN
      RAISE flexfield_not_supported;
    END IF;

    --
    -- Retrieve the industry type for the validation of the application_column_name
    --
    FND_PROFILE.GET_SPECIFIC(name_z => 'INDUSTRY',
                             val_z => v_industry_type,
                             defined_z => v_defined);

    IF NOT v_defined THEN

       BEGIN
         SELECT fpi.industry
         INTO v_industry_type
         FROM fnd_product_installations fpi
         WHERE fpi.application_id = v_application_id;
       EXCEPTION
         WHEN OTHERS THEN
           v_industry_type := 'N';
       END;

    END IF;

    --
    -- Retrieve the width of the application_column_name.
    --
    OPEN c_check_column_name;
    FETCH c_check_column_name
    INTO v_width, v_column_type;

    --
    -- Check that the application_column_name exists
    --
    IF c_check_column_name%FOUND THEN
      CLOSE c_check_column_name;
    ELSE
      CLOSE c_check_column_name;
      RAISE invalid_app_column_name;
    END IF;

    --
    -- Check that SegmentNum is unique for a particular structure
    --
    SELECT count(*)
    INTO   v_count
    FROM   FND_ID_FLEX_SEGMENTS
    WHERE  application_id = v_application_id
      AND  id_flex_code = v_id_flex_code
      AND  id_flex_num = v_id_flex_num
      AND  segment_num = v_segment_num;

    IF (v_count > 1) THEN
      RAISE segment_num_not_unique;
    END IF;

    --
    -- **GL Accounting Flexfield specific validation**
    -- The required check box must be checked for each segment
    --
    IF (v_application_id = 101 AND v_id_flex_code = 'GL#' AND v_required_flag <> 'Y') THEN
      RAISE gl_segment_must_be_required;
    END IF;

    --
    -- **GL Accounting Flexfield specific validation**
    -- The display check box must be checked for each segment
    --
    IF (v_application_id = 101 AND v_id_flex_code = 'GL#' AND v_display_flag <> 'Y') THEN
      RAISE gl_segment_must_be_displayed;
    END IF;


    IF (v_flex_value_set_id IS NOT NULL) THEN
    --
    -- VALIDATION CODE FOR WHEN A VALUE SET HAS BEEN ASSIGNED TO THE SEGMENT
    --

      --
      -- Retrieve the useful information for the validation logic from the assigned value set.
      --
      OPEN c_flex_value_set;
      FETCH c_flex_value_set
      INTO v_flex_value_set_name,
           v_validation_type,
           v_vset_security_enabled_flag,
           v_format_type,
           v_maximum_size,
           v_number_precision,
           v_alphanumeric_allowed_flag,
           v_uppercase_only_flag,
           v_numeric_mode_enabled_flag,
           v_minimum_value,
           v_maximum_value;

      --
      -- If a value set has been assigned to a segment, check that the value set exists
      -- and retrieve the value set information
      --
      IF c_flex_value_set%FOUND THEN
        CLOSE c_flex_value_set;
      ELSE
        CLOSE c_flex_value_set;
        RAISE value_set_must_exist;
      END IF;

      --
      -- If security is not enabled for the chosen value set, security cannot be enabled for
      -- the segment.
      --
      IF (v_vset_security_enabled_flag = 'N' AND v_security_enabled_flag = 'Y') THEN
        RAISE vset_security_not_enabled;
      END IF;

      --
      -- **PHASE I - Only independent value set are supported for phase I**
      -- The validation type of the value set must be "independent".
      --
      IF (v_validation_type <> 'I') THEN
        RAISE invalid_value_set;
      END IF;

      --
      -- **GL Accounting Flexfield specific validation**
      -- The format type of the value set must be "character".
      --
      IF (v_application_id = 101 AND v_id_flex_code = 'GL#' AND v_format_type <> 'C') THEN
        RAISE gl_format_must_be_char;
      END IF;

      --
      -- The default type of the default value can be 'D' only if the value set has a format
      -- type of 'D', 'X', or 'Y' or a format type of 'C' with a maximum size greater than 9
      --
      IF (v_default_type = 'D'
          AND v_format_type NOT IN ('D','X','Y')
          AND (v_format_type <> 'C' OR v_maximum_size < 9))
      THEN
        RAISE invalid_date_default_type;
      END IF;

      --
      -- The default type of the default value can be 'T' only if the value set has a format
      -- type of 'T', 'I', 'Y', or 'Z' or a format type of 'C' with a maximum size greater than 5
      --
      IF (v_default_type = 'T'
          AND v_format_type NOT IN ('T','I','Y','Z')
          AND (v_format_type <>'C' OR v_maximum_size < 5))
      THEN
        RAISE invalid_time_default_type;
      END IF;

      --
      -- The display size cannot exceeds the value set maximum size.
      --
      IF (v_maximum_size < v_display_size) THEN
        RAISE display_size_too_large;
      END IF;

      --
      -- The maximum size of the value set cannot be greater than the size of the segment column
      --
      IF (v_width < v_maximum_size) THEN
        RAISE maximum_size_too_large;
      END IF;

      --
      -- If the default type of the default value is "constant", the default value
      -- should be validated.
      --
      IF (v_default_type = 'C') THEN
        IF (NOT FND_FLEX_VAL_UTIL.IS_VALUE_VALID
  			  (p_value          => v_default_value,
  			   p_is_displayed   => TRUE,
  			   p_vset_name      => nvl(v_flex_value_set_name, 'FORM:FNDFFMIS'),
  			   p_vset_format    => nvl(v_format_type,'C'),
  			   p_max_length     => nvl(v_maximum_size, 150),
  			   p_precision      => nvl(v_number_precision, 0),
  			   p_alpha_allowed  => nvl(v_alphanumeric_allowed_flag, 'Y'),
  			   p_uppercase_only => nvl(v_uppercase_only_flag, 'N'),
  			   p_zero_fill      => nvl(v_numeric_mode_enabled_flag, 'N'),
  			   p_min_value      => v_minimum_value,
  			   p_max_value      => v_maximum_value,
  			   x_storage_value  => v_storage_value,
  			   x_display_value  => v_display_value)) THEN
           RAISE invalid_default_value;
        END IF;

        IF (v_default_value <> v_storage_value) THEN
          UPDATE FND_ID_FLEX_SEGMENTS
          SET default_value = v_storage_value
          WHERE application_id = v_application_id
            AND id_flex_code = v_id_flex_code
            AND id_flex_num = v_id_flex_num
            AND application_column_name = v_application_column_name;
        END IF;
      END IF;

    ELSE
    --
    -- VALIDATION CODE FOR WHEN NO VALUE SET HAS BEEN ASSIGNED TO THE SEGMENT
    --

      --
      -- **GL Accounting Flexfield specific validation**
      -- You must enter a value set in the value set field for each segment of
      -- the accounting flexfield.
      --
      IF (v_application_id = 101 AND v_id_flex_code = 'GL#') THEN
        RAISE gl_value_set_must_exist;
      END IF;

/* NOT NEEDED FOR THE CHART OF ACCOUNTS FLEXFIELD
   ONLY NEEDED FOR OTHER FLEXFIELDS
      --
      -- If the default type of the default value is "constant", the default value
      -- should be validated.
      --
      IF (v_default_type = 'C') THEN

        --
        -- Validate for the application column
        --
        IF (v_column_type = 'V') THEN
          v_format_type := 'C';
        ELSE
          v_format_type := v_column_type;
        END IF;
        v_maximum_size := v_width;

        IF (NOT FND_FLEX_VAL_UTIL.IS_VALUE_VALID
	          (p_value          => v_default_value,
			   p_is_displayed   => TRUE,
  			   p_vset_name      => nvl(v_flex_value_set_name, 'FORM:FNDFFMIS'),
  			   p_vset_format    => nvl(v_format_type,'C'),
  			   p_max_length     => nvl(v_maximum_size, 150),
  			   p_precision      => nvl(v_number_precision, 0),
  			   p_alpha_allowed  => nvl(v_alphanumeric_allowed_flag, 'Y'),
  			   p_uppercase_only => nvl(v_uppercase_only_flag, 'N'),
  			   p_zero_fill      => nvl(v_numeric_mode_enabled_flag, 'N'),
  			   p_min_value      => v_minimum_value,
  			   p_max_value      => v_maximum_value,
  			   x_storage_value  => v_storage_value,
  			   x_display_value  => v_display_value)) THEN
          RAISE invalid_default_value;
        END IF;

        v_format_type := null;
        v_maximum_size := null;
      END IF;

      --
      -- When no value set has been assigned to the segment,
      -- the display size cannot exceeds the application column size.
      --
      IF (v_width < v_display_size) THEN
        RAISE display_size_too_large;
      END IF;*/

    END IF;

    --
    -- The segment has been validated successfully.
    --
    return;

  EXCEPTION
    WHEN flexfield_not_supported THEN
      fnd_message.set_name('SQLGL','GL_API_COA_FLEX_NOT_SUPPORTED');
      app_exception.raise_exception;

    WHEN invalid_app_column_name THEN
      fnd_message.set_name('SQLGL','GL_API_COA_APP_COL_NAME_INV');
      fnd_message.set_token('APPCOLNAME',v_application_column_name);
      app_exception.raise_exception;

    WHEN segment_num_not_unique THEN
      fnd_message.set_name('SQLGL','GL_API_COA_SEG_NUM_NOT_UNIQUE');
      app_exception.raise_exception;

    WHEN value_set_must_exist THEN
      fnd_message.set_name('FND','FLEX-VALUE SET NOT FOUND');
      fnd_message.set_token('SEGMENT',v_segment_name);
      app_exception.raise_exception;

    WHEN gl_segment_must_be_required THEN
      fnd_message.set_name('SQLGL','GL_API_COA_SEG_MUST_BE_REQ');
      app_exception.raise_exception;

    WHEN gl_segment_must_be_displayed THEN
      fnd_message.set_name('SQLGL','GL_API_COA_SEG_MUST_BE_DIS');
      app_exception.raise_exception;

    WHEN invalid_value_set THEN
      fnd_message.set_name('SQLGL','GL_API_COA_VSET_NOT_SUPPORTED');
      app_exception.raise_exception;

    WHEN gl_format_must_be_char THEN
      fnd_message.set_name('SQLGL','GL_API_COA_MUST_BE_CHAR');
      app_exception.raise_exception;

    WHEN display_size_too_large THEN
      fnd_message.set_name('SQLGL','GL_API_COA_DIS_SIZE_TOO_LARGE');
      fnd_message.set_token('MAXSIZE',v_maximum_size);
      app_exception.raise_exception;

    WHEN maximum_size_too_large THEN
      fnd_message.set_name('SQLGL','GL_API_COA_MAX_SIZE_TOO_LARGE');
      fnd_message.set_token('VSETNAME',v_flex_value_set_name);
      fnd_message.set_token('COLSIZE',v_width);
      app_exception.raise_exception;

    WHEN invalid_default_value THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INVALID_DEF_VAL');
      fnd_message.set_token('DEFVAL',v_default_value);
      app_exception.raise_exception;

    WHEN vset_security_not_enabled THEN
      fnd_message.set_name('SQLGL','GL_API_COA_NO_VSET_SECURITY');
      fnd_message.set_token('VSETNAME',v_flex_value_set_name);
      app_exception.raise_exception;

    WHEN invalid_date_default_type THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INV_DATE_DEF_TYPE');
      fnd_message.set_token('VSETNAME',v_flex_value_set_name);
      app_exception.raise_exception;

    WHEN invalid_time_default_type THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INV_TIME_DEF_TYPE');
      fnd_message.set_token('VSETNAME',v_flex_value_set_name);
      app_exception.raise_exception;

    WHEN gl_value_set_must_exist THEN
      fnd_message.set_name('SQLGL','GL_API_COA_VAL_SET_REQUIRED');
      app_exception.raise_exception;

   WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_segment');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;

  END validate_segment;


  --
  -- Procedure
  --   validate_segment_tl
  -- Purpose
  --   Do the validation for one particular translated segment of a structure
  --   (FND_ID_FLEX_SEGMENTS_TL table)
  --   NO VALIDATION CODE IS NEEDED NOW.
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_segment_tl(v_application_id           IN NUMBER,
                                v_id_flex_code             IN VARCHAR2,
                                v_id_flex_num              IN NUMBER,
                                v_application_column_name  IN VARCHAR2,
                                v_language                 IN VARCHAR2)
  IS

  BEGIN
    --
    -- Check if the flexfield is supported by the API
    --
    IF (NOT is_flexfield_supported(v_application_id => v_application_id,
                                   v_id_flex_code => v_id_flex_code))
    THEN
      RAISE flexfield_not_supported;
    END IF;

    --
    -- The segment tl has been validated successfully.
    --
    return;

  EXCEPTION
    WHEN flexfield_not_supported THEN
      fnd_message.set_name('SQLGL','GL_API_COA_FLEX_NOT_SUPPORTED');
      app_exception.raise_exception;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_segment_tl');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;

  END validate_segment_tl;


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
                                         v_attribute_value          IN VARCHAR2)
  IS
    v_global_flag                 VARCHAR2(1);
    v_unique_flag                 VARCHAR2(1);
    v_segment_prompt              VARCHAR2(50);
    v_count                       NUMBER;

    -- Retrieve the attribute type information required for the validation.
    CURSOR c_check_seg_attribute_type IS
      SELECT global_flag,
             unique_flag,
             segment_prompt
      FROM FND_SEGMENT_ATTRIBUTE_TYPES
      WHERE application_id = v_application_id
        AND id_flex_code = v_id_flex_code
        AND segment_attribute_type = v_segment_attribute_type;

  BEGIN
    --
    -- Check if the flexfield is supported by the API
    --
    IF (NOT is_flexfield_supported(v_application_id => v_application_id,
                                   v_id_flex_code => v_id_flex_code))
    THEN
      RAISE flexfield_not_supported;
    END IF;

    --
    -- The segment attribute type must exist in the attribute type table
    --
    OPEN c_check_seg_attribute_type;
    FETCH c_check_seg_attribute_type
    INTO v_global_flag,
         v_unique_flag,
         v_segment_prompt;

    IF c_check_seg_attribute_type%FOUND THEN
      CLOSE c_check_seg_attribute_type;
    ELSE
      CLOSE c_check_seg_attribute_type;
      RAISE invalid_seg_attribute_type;
    END IF;

    --
    -- The global qualifiers should apply to all segments
    --
    IF (v_attribute_value = 'N' AND v_global_flag = 'Y') THEN
      RAISE global_qualifier_error;
    END IF;

    --
    -- A unique qualifier should not be assigned to more than one segment in the structure
    --
    IF (v_attribute_value = 'Y' AND v_unique_flag = 'Y') THEN
      SELECT count(*)
      INTO   v_count
      FROM   FND_SEGMENT_ATTRIBUTE_VALUES
      WHERE  application_id = v_application_id
        AND  id_flex_code = v_id_flex_code
        AND  id_flex_num = v_id_flex_num
        AND  segment_attribute_type = v_segment_attribute_type
        AND  attribute_value = 'Y';

      IF (v_count > 1) THEN
        RAISE qualifier_not_unique;
      END IF;

    END IF;

    --
    -- The segment attribute value has been validated successfully.
    --
    return;

  EXCEPTION
    WHEN flexfield_not_supported THEN
      fnd_message.set_name('SQLGL','GL_API_COA_FLEX_NOT_SUPPORTED');
      app_exception.raise_exception;

    WHEN invalid_seg_attribute_type THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INVALID_ATTR_TYPE');
      app_exception.raise_exception;

    WHEN global_qualifier_error THEN
      fnd_message.set_name('SQLGL','GL_API_COA_GLOB_QUAL_NOT_YES');
      fnd_message.set_token('QUAL',v_segment_prompt);
      app_exception.raise_exception;

    WHEN qualifier_not_unique THEN
      fnd_message.set_name('SQLGL','GL_API_COA_QUAL_NOT_UNIQUE');
      fnd_message.set_token('QUAL',v_segment_prompt);
      app_exception.raise_exception;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_seg_attribute_value');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;

  END validate_seg_attribute_value;

  --
  -- Procedure
  --   validate_value_set
  --   (FND_FLEX_VALUE_SETS table)
  -- Purpose
  --   Do the validation for one particular value set
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
                               v_number_precision          IN NUMBER)
  IS
    v_storage_value              VARCHAR2(2000) := '';
    v_display_value              VARCHAR2(2000) := '';
    v_is_minimum_value_valid     BOOLEAN := TRUE;
    v_is_maximum_value_valid     BOOLEAN := TRUE;

  BEGIN

    --
    -- The value set name cannot start with '$FLEX$.'
    --
    IF (v_flex_value_set_name like '$FLEX$.%') THEN
      RAISE invalid_value_set_name;
    END IF;

    --
    -- The minimum value must be less than the maximum value.
    --
    IF (v_minimum_value > v_maximum_value) THEN
      RAISE invalid_minimum_maximum;
    END IF;

    --
    -- If they are defined, the Minimum Value, the Maximum Value, and the
    -- Dependant Default Value must be validated by calling
    -- FND_FLEX_VAL_UTIL.is_value_valid.
    --
    IF (v_dependant_default_value IS NOT NULL) THEN
      IF (NOT FND_FLEX_VAL_UTIL.IS_VALUE_VALID
  			  (p_value          => v_dependant_default_value,
  			   p_is_displayed   => TRUE,
  			   p_vset_name      => v_flex_value_set_name,
  			   p_vset_format    => v_format_type,
  			   p_max_length     => v_maximum_size,
  			   p_precision      => v_number_precision,
  			   p_alpha_allowed  => v_alphanumeric_allowed_flag,
  			   p_uppercase_only => v_uppercase_only_flag,
  			   p_zero_fill      => v_numeric_mode_enabled_flag,
  			   p_min_value      => v_minimum_value,
  			   p_max_value      => v_maximum_value,
  			   x_storage_value  => v_storage_value,
  			   x_display_value  => v_display_value)) THEN
        RAISE invalid_dependant_value;
      END IF;

      IF (v_dependant_default_value <> v_storage_value) THEN
        UPDATE FND_FLEX_VALUE_SETS
        SET dependant_default_value = v_storage_value
        WHERE flex_value_set_id = v_flex_value_set_id;
      END IF;
    END IF;

    IF (v_minimum_value IS NOT NULL) THEN
      IF (NOT FND_FLEX_VAL_UTIL.IS_VALUE_VALID
  			  (p_value          => v_minimum_value,
  			   p_is_displayed   => TRUE,
  			   p_vset_name      => v_flex_value_set_name,
  			   p_vset_format    => v_format_type,
  			   p_max_length     => v_maximum_size,
  			   p_precision      => v_number_precision,
  			   p_alpha_allowed  => v_alphanumeric_allowed_flag,
  			   p_uppercase_only => v_uppercase_only_flag,
  			   p_zero_fill      => v_numeric_mode_enabled_flag,
  			   p_min_value      => v_minimum_value,
  			   p_max_value      => v_maximum_value,
  			   x_storage_value  => v_storage_value,
  			   x_display_value  => v_display_value)) THEN
        v_is_minimum_value_valid := FALSE;
      END IF;

      IF (v_minimum_value <> v_storage_value) THEN
        UPDATE FND_FLEX_VALUE_SETS
        SET minimum_value = v_storage_value
        WHERE flex_value_set_id = v_flex_value_set_id;
      END IF;
     END IF;

    IF (v_maximum_value IS NOT NULL) THEN
      IF (NOT FND_FLEX_VAL_UTIL.IS_VALUE_VALID
  			  (p_value          => v_maximum_value,
  			   p_is_displayed   => TRUE,
  			   p_vset_name      => v_flex_value_set_name,
  			   p_vset_format    => v_format_type,
  			   p_max_length     => v_maximum_size,
  			   p_precision      => v_number_precision,
  			   p_alpha_allowed  => v_alphanumeric_allowed_flag,
  			   p_uppercase_only => v_uppercase_only_flag,
  			   p_zero_fill      => v_numeric_mode_enabled_flag,
  			   p_min_value      => v_minimum_value,
  			   p_max_value      => v_maximum_value,
  			   x_storage_value  => v_storage_value,
  			   x_display_value  => v_display_value)) THEN
        v_is_maximum_value_valid := FALSE;
      END IF;

      IF (v_maximum_value <> v_storage_value) THEN
        UPDATE FND_FLEX_VALUE_SETS
        SET maximum_value = v_storage_value
        WHERE flex_value_set_id = v_flex_value_set_id;
      END IF;
    END IF;

    IF (NOT v_is_minimum_value_valid) THEN
      IF (NOT v_is_maximum_value_valid) THEN
        -- In this case, we do not know whether minimum value is invalid,
        -- maximum value is invalid, or both.
        -- (For example, if maximum value is invalid, then in some cases, the validation of
        -- minimum value (FND_FLEX_VAL_UTIL.IS_VALUE_VALID) is going to failed since we are
        -- passing the maximum value argument. In this case, we should not display mimimum value
        -- invalid
        RAISE invalid_minormax_value;
      ELSE
        -- We know that the minimum value is invalid.
        RAISE invalid_minimum_value;
      END IF;
    END IF;

    IF (NOT v_is_maximum_value_valid) THEN
      -- We know that the maximum value is invalid.
      RAISE invalid_maximum_value;
    END IF;

    --
    -- The value set has been validated successfully.
    --
    return;

  EXCEPTION
    WHEN invalid_value_set_name THEN
      fnd_message.set_name('FND','FLEX-VALUE SET RESERVED WORD');
      app_exception.raise_exception;

    WHEN invalid_minimum_maximum THEN
      fnd_message.set_name('SQLGL','GL_API_COA_MIN_GREATER_MAX');
      app_exception.raise_exception;

    WHEN invalid_dependant_value THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INVALID_DEP_DEF_VAL');
      fnd_message.set_token('DEFVAL',v_dependant_default_value);
      app_exception.raise_exception;

    WHEN invalid_minimum_value THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INVALID_MIN_VAL');
      fnd_message.set_token('MINVAL',v_minimum_value);
      app_exception.raise_exception;

    WHEN invalid_maximum_value THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INVALID_MAX_VAL');
      fnd_message.set_token('MAXVAL',v_maximum_value);
      app_exception.raise_exception;

    WHEN invalid_minormax_value THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INV_MINORMAX_VAL');
      fnd_message.set_token('MINVAL',v_minimum_value);
      fnd_message.set_token('MAXVAL',v_maximum_value);
      app_exception.raise_exception;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_value_set');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;

  END validate_value_set;


  --
  -- Procedure
  --   validate_validation_qualifier
  -- Purpose
  --   Do the validation for one particular validation qualifier
  --   (FND_FLEX_VALIDATION_QUALIFIERS table)
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_validation_qualifier(v_id_flex_application_id     IN NUMBER,
                                          v_id_flex_code               IN VARCHAR2,
                                          v_flex_value_set_id          IN NUMBER,
                                          v_segment_attribute_type     IN VARCHAR2,
                                          v_value_attribute_type       IN VARCHAR2)
  IS
    v_check_val_attribute_type   VARCHAR2(10);
    v_value_attribute_type_err   VARCHAR2(30);
    v_assignment_date            DATE;
    v_assignment_date_err        DATE;

    -- Cursor used to check that the value attribute type exist in the value attribute type
    -- table.
    CURSOR c_check_val_attribute_type IS
      SELECT 'Exists'
      FROM FND_VALUE_ATTRIBUTE_TYPES
      WHERE application_id = v_id_flex_application_id
        AND id_flex_code = v_id_flex_code
        AND segment_attribute_type = v_segment_attribute_type
        AND value_attribute_type = v_value_attribute_type;

    -- Cursor to check if the assignment dates for the GL Accounting
    -- Flexfield qualifiers are in the right order.
    CURSOR c_check_date_detail_budgeting IS
      SELECT value_attribute_type, assignment_date
      FROM FND_FLEX_VALIDATION_QUALIFIERS
      WHERE id_flex_application_id = v_id_flex_application_id
        AND id_flex_code = v_id_flex_code
        AND flex_value_set_id = v_flex_value_set_id
        AND value_attribute_type IN ('DETAIL_POSTING_ALLOWED',
                                     'GL_ACCOUNT_TYPE',
                                     'GL_CONTROL_ACCOUNT',
                                     'RECONCILIATION FLAG')
        AND assignment_date < v_assignment_date;

    CURSOR c_check_date_detail_posting IS
      SELECT value_attribute_type, assignment_date
      FROM FND_FLEX_VALIDATION_QUALIFIERS
      WHERE id_flex_application_id = v_id_flex_application_id
        AND id_flex_code = v_id_flex_code
        AND flex_value_set_id = v_flex_value_set_id
        AND ((value_attribute_type  = 'DETAIL_BUDGETING_ALLOWED'
              AND assignment_date > v_assignment_date)
            OR
             (value_attribute_type IN ('GL_ACCOUNT_TYPE',
                                       'GL_CONTROL_ACCOUNT',
                                       'RECONCILIATION FLAG')
              AND assignment_date < v_assignment_date));

    CURSOR c_check_date_account IS
      SELECT value_attribute_type, assignment_date
      FROM FND_FLEX_VALIDATION_QUALIFIERS
      WHERE id_flex_application_id = v_id_flex_application_id
        AND id_flex_code = v_id_flex_code
        AND flex_value_set_id = v_flex_value_set_id
        AND ((value_attribute_type IN ('DETAIL_BUDGETING_ALLOWED',
                                       'DETAIL_POSTING_ALLOWED')
              AND assignment_date > v_assignment_date)
            OR
             (value_attribute_type IN ('GL_CONTROL_ACCOUNT',
                                       'RECONCILIATION FLAG')
              AND assignment_date < v_assignment_date));

    CURSOR c_check_date_control IS
      SELECT value_attribute_type, assignment_date
      FROM FND_FLEX_VALIDATION_QUALIFIERS
      WHERE id_flex_application_id = v_id_flex_application_id
        AND id_flex_code = v_id_flex_code
        AND flex_value_set_id = v_flex_value_set_id
        AND value_attribute_type IN ('DETAIL_BUDGETING_ALLOWED',
                                     'DETAIL_POSTING_ALLOWED',
                                     'GL_ACCOUNT_TYPE')
        AND assignment_date > v_assignment_date;


    CURSOR c_check_date_reconcilition IS
      SELECT value_attribute_type, assignment_date
      FROM FND_FLEX_VALIDATION_QUALIFIERS
      WHERE id_flex_application_id = v_id_flex_application_id
        AND id_flex_code = v_id_flex_code
        AND flex_value_set_id = v_flex_value_set_id
        AND value_attribute_type IN ('DETAIL_BUDGETING_ALLOWED',
                                     'DETAIL_POSTING_ALLOWED',
                                     'GL_ACCOUNT_TYPE')
        AND assignment_date > v_assignment_date;

  BEGIN
    --
    -- Check if the flexfield is supported by the API
    --
    IF (NOT is_flexfield_supported(v_application_id => v_id_flex_application_id,
                                   v_id_flex_code => v_id_flex_code))
    THEN
      RAISE flexfield_not_supported;
    END IF;

    --
    -- The value attribute type must exist in the attribute type table.
    --
    OPEN c_check_val_attribute_type;
    FETCH c_check_val_attribute_type
    INTO v_check_val_attribute_type;

    IF c_check_val_attribute_type%FOUND THEN
      CLOSE c_check_val_attribute_type;
    ELSE
      CLOSE c_check_val_attribute_type;
      RAISE invalid_val_attribute_type;
    END IF;

    --
    -- **GL Accounting Flexfield specific validation**
    -- The flexfield qualifier assignment dates must be in the following chronological
    -- order(if they exists):
    -- DETAIL_BUDGETING_ALLOWED, DETAIL_POSTING_ALLOWED, and GL_ACCOUNT_TYPE
    -- GL_CONTROL_ACCOUNT and RECONCILIATION FLAG after.
    SELECT assignment_date
    INTO v_assignment_date
    FROM FND_FLEX_VALIDATION_QUALIFIERS
    WHERE id_flex_application_id = v_id_flex_application_id
      AND id_flex_code = v_id_flex_code
      AND flex_value_set_id = v_flex_value_set_id
      AND segment_attribute_type = v_segment_attribute_type
      AND value_attribute_type = v_value_attribute_type;

    IF (v_value_attribute_type = 'DETAIL_BUDGETING_ALLOWED') THEN
      OPEN c_check_date_detail_budgeting;
      FETCH c_check_date_detail_budgeting
      INTO v_value_attribute_type_err, v_assignment_date_err;

      IF c_check_date_detail_budgeting%NOTFOUND THEN
        CLOSE c_check_date_detail_budgeting;
      ELSE
        CLOSE c_check_date_detail_budgeting;
        RAISE invalid_assignment_date_order;
      END IF;
    END IF;

    IF (v_value_attribute_type = 'DETAIL_POSTING_ALLOWED') THEN
      OPEN c_check_date_detail_posting;
      FETCH c_check_date_detail_posting
      INTO v_value_attribute_type_err, v_assignment_date_err;

      IF c_check_date_detail_posting%NOTFOUND THEN
        CLOSE c_check_date_detail_posting;
      ELSE
        CLOSE c_check_date_detail_posting;
        RAISE invalid_assignment_date_order;
      END IF;
    END IF;

    IF (v_value_attribute_type = 'GL_ACCOUNT_TYPE') THEN
      OPEN c_check_date_account;
      FETCH c_check_date_account
      INTO v_value_attribute_type_err, v_assignment_date_err;

      IF c_check_date_account%NOTFOUND THEN
        CLOSE c_check_date_account;
      ELSE
        CLOSE c_check_date_account;
        RAISE invalid_assignment_date_order;
      END IF;
    END IF;

    IF (v_value_attribute_type = 'GL_CONTROL_ACCOUNT') THEN
      OPEN c_check_date_control;
      FETCH c_check_date_control
      INTO v_value_attribute_type_err, v_assignment_date_err;

      IF c_check_date_control%NOTFOUND THEN
        CLOSE c_check_date_control;
      ELSE
        CLOSE c_check_date_control;
        RAISE invalid_assignment_date_order;
      END IF;
    END IF;

    IF (v_value_attribute_type = 'RECONCILIATION FLAG') THEN
      OPEN c_check_date_reconcilition;
      FETCH c_check_date_reconcilition
      INTO v_value_attribute_type_err, v_assignment_date_err;

      IF c_check_date_reconcilition%NOTFOUND THEN
        CLOSE c_check_date_reconcilition;
      ELSE
        CLOSE c_check_date_reconcilition;
        RAISE invalid_assignment_date_order;
      END IF;
    END IF;

    --
    -- The validation qualifier has been validated successfully.
    --
    return;

  EXCEPTION
    WHEN flexfield_not_supported THEN
      fnd_message.set_name('SQLGL','GL_API_COA_FLEX_NOT_SUPPORTED');
      app_exception.raise_exception;

    WHEN invalid_val_attribute_type THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INV_VAL_ATTR_TYPE');
      app_exception.raise_exception;

    WHEN invalid_assignment_date_order THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INVALID_DATE_ORDER');

      IF (v_assignment_date_err < v_assignment_date) THEN
        fnd_message.set_token('VALATTR1',v_value_attribute_type);
        fnd_message.set_token('VALATTR2',v_value_attribute_type_err);
      ELSE
        fnd_message.set_token('VALATTR1',v_value_attribute_type_err);
        fnd_message.set_token('VALATTR2',v_value_attribute_type);
      END IF;

      app_exception.raise_exception;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_validation_qualifier');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;

  END validate_validation_qualifier;


  --
  -- Procedure
  --   validate_value
  -- Purpose
  --   Do the validation for one particular value of a value set.
  --   (FND_ID_FLEX_VALUES table)
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_value(v_flex_value_id             IN NUMBER,
                           v_flex_value_set_id         IN NUMBER,
                           v_flex_value                IN VARCHAR2,
                           v_compiled_value_attributes IN VARCHAR2)
  IS
    v_flex_value_set_name          VARCHAR2(60);
    v_validation_type              VARCHAR2(1);
    v_vset_security_enabled_flag   VARCHAR2(1);
    v_format_type                  VARCHAR2(1);
    v_maximum_size                 NUMBER(3);
    v_number_precision             NUMBER(2);
    v_alphanumeric_allowed_flag    VARCHAR2(1);
    v_uppercase_only_flag          VARCHAR2(1);
    v_numeric_mode_enabled_flag    VARCHAR2(1);
    v_minimum_value                VARCHAR2(150);
    v_maximum_value                VARCHAR2(150);
    v_storage_value                VARCHAR2(2000) := '';
    v_display_value                VARCHAR2(2000) := '';
    v_count                        NUMBER;
    v_required_flag                VARCHAR2(1);
    v_lookup_type                  VARCHAR2(30);
    v_value_attribute_type         VARCHAR2(30);
    v_compiled_value_attribute_c   VARCHAR2(30);
    v_compiled_value_attribute_l   NUMBER;
    i                              NUMBER := 0;
    j                              NUMBER;
    v_compiled_value_attribute_s   VARCHAR2(2000);
    v_count_value_attribute_types  NUMBER;

    -- Retrieve the value set information required for the validation from the value set id.
    CURSOR c_flex_value_set IS
      SELECT flex_value_set_name,
             validation_type,
             security_enabled_flag,
             format_type,
             maximum_size,
             number_precision,
             alphanumeric_allowed_flag,
             uppercase_only_flag,
             numeric_mode_enabled_flag,
             minimum_value,
             maximum_value
      FROM FND_FLEX_VALUE_SETS
      WHERE flex_value_set_id = v_flex_value_set_id;

    -- Retrieve the value attribute type information required for the validation.
    CURSOR c_value_attribute_type IS
      SELECT vat.required_flag AS required_flag,
             vat.lookup_type AS lookup_type,
             vat.value_attribute_type AS value_attribute_type
      FROM FND_VALUE_ATTRIBUTE_TYPES vat,
           FND_FLEX_VALIDATION_QUALIFIERS fvq
      WHERE fvq.flex_value_set_id = v_flex_value_set_id
        AND vat.id_flex_code = fvq.id_flex_code
        AND vat.application_id = fvq.id_flex_application_id
        AND vat.segment_attribute_type = fvq.segment_attribute_type
        AND vat.value_attribute_type = fvq.value_attribute_type
      ORDER BY fvq.assignment_date, fvq.value_attribute_type;

    -- Hold the cursor values
    v_cursor_attribute_type       c_value_attribute_type%ROWTYPE;

    -- Validate the value attribute.
    CURSOR c_check_value_attribute(v_character      VARCHAR2,
                                   v_required_flag  VARCHAR2,
                                   v_lookup_type    VARCHAR2) IS
      SELECT v_character
      FROM dual
      WHERE v_character IN (SELECT lookup_code
                            FROM FND_LOOKUPS
                            WHERE lookup_type = v_lookup_type)
        OR (v_character = ' ' AND v_required_flag = 'N' );

  BEGIN
    --
    -- The flexfield value must be formatted properly.
    --
    OPEN c_flex_value_set;
    FETCH c_flex_value_set
    INTO v_flex_value_set_name,
         v_validation_type,
         v_vset_security_enabled_flag,
         v_format_type,
         v_maximum_size,
         v_number_precision,
         v_alphanumeric_allowed_flag,
         v_uppercase_only_flag,
         v_numeric_mode_enabled_flag,
         v_minimum_value,
         v_maximum_value;

    IF c_flex_value_set%FOUND THEN
      CLOSE c_flex_value_set;
    ELSE
      CLOSE c_flex_value_set;
      RAISE value_set_must_exist;
    END IF;

    --
    -- The value should be validated.
    --
    IF (NOT FND_FLEX_VAL_UTIL.IS_VALUE_VALID
			  (p_value          => v_flex_value,
			   p_is_displayed   => TRUE,
			   p_vset_name      => v_flex_value_set_name,
			   p_vset_format    => v_format_type,
			   p_max_length     => v_maximum_size,
			   p_precision      => v_number_precision,
			   p_alpha_allowed  => v_alphanumeric_allowed_flag,
			   p_uppercase_only => v_uppercase_only_flag,
			   p_zero_fill      => v_numeric_mode_enabled_flag,
			   p_min_value      => v_minimum_value,
			   p_max_value      => v_maximum_value,
			   x_storage_value  => v_storage_value,
			   x_display_value  => v_display_value)) THEN
      RAISE invalid_value;
    END IF;

    IF (v_flex_value <> v_storage_value) THEN
      UPDATE FND_FLEX_VALUES
      SET flex_value = v_storage_value
      WHERE flex_value_id = v_flex_value_id;
    END IF;

    --
    -- The compiled value attributes must be formatted properly:
    --
    -- Added by ABHJOSHI on 03/31/05
    -- Retrieve the count of the value attribute types required for the validation.

    SELECT COUNT(*) INTO v_count_value_attribute_types
    FROM FND_VALUE_ATTRIBUTE_TYPES vat,
         FND_FLEX_VALIDATION_QUALIFIERS fvq
    WHERE fvq.flex_value_set_id = v_flex_value_set_id
      AND vat.id_flex_code = fvq.id_flex_code
      AND vat.application_id = fvq.id_flex_application_id
      AND vat.segment_attribute_type = fvq.segment_attribute_type
      AND vat.value_attribute_type = fvq.value_attribute_type;

    --
    -- 1. Each individual attribute value must be in the lookup table
    --    or can be ' ' if it is not a required attribute.
    --    Each individual attribute value can also be null (Added on 03/05/01).
    --
    --    Added by ABHJOSHI on 03/31/05
    --    Handling of the multi-character individual attribute value.
    --

    v_compiled_value_attribute_s
        := v_compiled_value_attributes||FND_GLOBAL.newline;

    FOR v_cursor_attribute_type IN c_value_attribute_type LOOP

      -- Count the number of attributes
      i := i + 1;

      -- Retrieve the attribute type information for the attribute
      v_required_flag := v_cursor_attribute_type.required_flag;
      v_lookup_type := v_cursor_attribute_type.lookup_type;
      v_value_attribute_type := v_cursor_attribute_type.value_attribute_type;

      -- Retrieve the individual attribute value from the compiled attribute value
      -- Each individual attribute value can be null.
      -- Consequtive <Enter> character (ASCII value 10) means a NULL value.
      -- Added by ABHJOSHI on 03/31/05
      --
      IF (substrb(v_compiled_value_attribute_s,1,1) = FND_GLOBAL.newline) THEN
          v_compiled_value_attribute_c := NULL;
      ELSE
          v_compiled_value_attribute_c
              := substrb(v_compiled_value_attribute_s
                        ,1
                        ,instrb(v_compiled_value_attribute_s,FND_GLOBAL.newline,1)-1);
      END IF;

      -- Each individual attribute value can be null.
      IF (v_compiled_value_attribute_c IS NOT NULL) THEN

        -- Check if the individual attribute value is valid
        OPEN c_check_value_attribute(v_compiled_value_attribute_c,
                                     v_required_flag,
                                     v_lookup_type);
        FETCH c_check_value_attribute
        INTO v_compiled_value_attribute_c;

        IF c_check_value_attribute%FOUND THEN
          CLOSE c_check_value_attribute;
        ELSE
          CLOSE c_check_value_attribute;
          RAISE invalid_compiled_value_attr1;
        END IF;

      END IF;

      -- Individual attribute value should not contain
      -- <Enter> character (ASCII value 10)
      -- Otherwise will be treated as separate values
      v_compiled_value_attribute_s
          := substrb(v_compiled_value_attribute_s
                    ,instrb(v_compiled_value_attribute_s,FND_GLOBAL.newline,1)+1);

    END LOOP;

    --
    -- 2. Each individual attribute must be separated from other
    -- attributes with an <Enter> character (ASCII value 10).
    --    Each individual attribute value can also be null (Added on 03/05/01).
    --
    --    Added by ABHJOSHI on 03/31/05
    --    This check has been modified alongwith the handling of the
    --    multi-character individual attribute value (code section 1),
    --    hence this code section has been removed and exception
    --    invalid_compiled_value_attr2 is no longer used.

    --
    -- 3. Check that there is not more attribute values
    -- than needed (Modified by ABHJOSHI on 03/31/05).
    --
    IF (v_compiled_value_attribute_s IS NOT NULL) OR
       (v_count_value_attribute_types > i) THEN

      RAISE invalid_compiled_value_attr3;
    END IF;

    --
    -- The value has been validated successfully.
    --
    return;

  EXCEPTION
    WHEN value_set_must_exist THEN
      fnd_message.set_name('SQLGL','GL_API_COA_NO_VSET_FOUND');
      fnd_message.set_token('VSET',v_flex_value_set_name);
      app_exception.raise_exception;

    WHEN invalid_value THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INVALID_VAL');
      app_exception.raise_exception;

    WHEN invalid_compiled_value_attr1 THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INVALID_COMP_ATTR1');
      fnd_message.set_token('NUM',i);
      fnd_message.set_token('VALATTRTYPE',v_value_attribute_type);
      app_exception.raise_exception;

    WHEN invalid_compiled_value_attr3 THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INVALID_COMP_ATTR3');
      app_exception.raise_exception;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_value');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;

  END validate_value;


  --
  -- Procedure
  --   validate_value_tl
  -- Purpose
  --   Do the validation for one particular translated value of a value set.
  --   (FND_ID_FLEX_VALUES_TL table)
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_value_tl(v_flex_value_id          IN NUMBER,
                              v_language               IN VARCHAR2,
                              v_flex_value_meaning     IN VARCHAR2,
                              v_userenvlang            IN VARCHAR2)
  IS
    v_flex_value_set_id          NUMBER(15);
    v_flex_value_set_name        VARCHAR2(60);
    v_validation_type            VARCHAR2(1);
    v_vset_security_enabled_flag VARCHAR2(1);
    v_format_type                VARCHAR2(1);
    v_maximum_size               NUMBER(3);
    v_number_precision           NUMBER(2);
    v_alphanumeric_allowed_flag  VARCHAR2(1);
    v_uppercase_only_flag        VARCHAR2(1);
    v_numeric_mode_enabled_flag  VARCHAR2(1);
    v_minimum_value              VARCHAR2(150);
    v_maximum_value              VARCHAR2(150);
    v_storage_value              VARCHAR2(2000);
    v_display_value              VARCHAR2(2000);
    v_parent_flex_value_low      VARCHAR2(60);
    v_count                      NUMBER;

   -- Retrieve the value set information required for the validation from the value set id.
    CURSOR c_flex_value_set IS
      SELECT vs.flex_value_set_id,
             vs.flex_value_set_name,
             vs.validation_type,
             vs.security_enabled_flag,
             vs.format_type,
             vs.maximum_size,
             vs.number_precision,
             vs.alphanumeric_allowed_flag,
             vs.uppercase_only_flag,
             vs.numeric_mode_enabled_flag,
             vs.minimum_value,
             vs.maximum_value
      FROM   FND_FLEX_VALUE_SETS vs,
             FND_FLEX_VALUES v
      WHERE  v.flex_value_id = v_flex_value_id
        AND  v.flex_value_set_id = vs.flex_value_set_id;

  BEGIN
    --
    -- Retrieve the environment language.
    --
    IF (v_userenvlang = v_language) THEN
      --
      -- Retrieve the value set information
      --
      OPEN c_flex_value_set;
      FETCH c_flex_value_set
      INTO v_flex_value_set_id,
           v_flex_value_set_name,
           v_validation_type,
           v_vset_security_enabled_flag,
           v_format_type,
           v_maximum_size,
           v_number_precision,
           v_alphanumeric_allowed_flag,
           v_uppercase_only_flag,
           v_numeric_mode_enabled_flag,
           v_minimum_value,
           v_maximum_value;

      IF c_flex_value_set%FOUND THEN
        CLOSE c_flex_value_set;
      ELSE
        CLOSE c_flex_value_set;
        RAISE value_set_must_exist;
      END IF;

      --
      -- Check that flexfield value meaning is unique for the value set if the language
      -- is userenv('LANG').
      --
      SELECT parent_flex_value_low
      INTO v_parent_flex_value_low
      FROM FND_FLEX_VALUES
      WHERE flex_value_id = v_flex_value_id;

      SELECT count(*)
      INTO   v_count
      FROM   FND_FLEX_VALUES_VL
      WHERE  flex_value_set_id = v_flex_value_set_id
        AND  flex_value_meaning = v_flex_value_meaning
        AND ((v_parent_flex_value_low IS null) OR
             (parent_flex_value_low =
              v_parent_flex_value_low));

      IF (v_count > 1) THEN
        RAISE value_meaning_not_unique;
      END IF;

      --
      -- The flexfield value meaning must be formatted properly for the value set
      -- if the language is userenv('LANG').
      --
      IF (NOT FND_FLEX_VAL_UTIL.IS_VALUE_VALID
  			  (p_value          => v_flex_value_meaning,
  			   p_is_displayed   => TRUE,
  			   p_vset_name      => v_flex_value_set_name,
  			   p_vset_format    => v_format_type,
  			   p_max_length     => v_maximum_size,
  			   p_precision      => v_number_precision,
  			   p_alpha_allowed  => v_alphanumeric_allowed_flag,
  			   p_uppercase_only => v_uppercase_only_flag,
  			   p_zero_fill      => v_numeric_mode_enabled_flag,
  			   p_min_value      => v_minimum_value,
  			   p_max_value      => v_maximum_value,
  			   x_storage_value  => v_storage_value,
  			   x_display_value  => v_display_value)) THEN
        RAISE invalid_value_meaning;
      END IF;

      IF (v_flex_value_meaning <> v_storage_value) THEN
        UPDATE FND_FLEX_VALUES_TL
        SET flex_value_meaning = v_storage_value
        WHERE flex_value_id = v_flex_value_id
          AND language = v_language;
      END IF;

    END IF;

    --
    -- The value tl has been validated successfully.
    --
    return;

  EXCEPTION
    WHEN value_meaning_not_unique THEN
      fnd_message.set_name('SQLGL','GL_API_COA_VALUE_TL_NOT_UNIQ');
      app_exception.raise_exception;

    WHEN value_set_must_exist THEN
      fnd_message.set_name('SQLGL','GL_API_COA_NO_VSET_FOUND');
      fnd_message.set_token('VSET',v_flex_value_set_name);
      app_exception.raise_exception;

    WHEN invalid_value_meaning THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INVALID_VAL_TL');
      app_exception.raise_exception;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_value_tl');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;

  END validate_value_tl;


  --
  -- Procedure
  --   validate_final_structure
  -- Purpose
  --   Do the final validation for one particular structure:
  --     Check that the structure has all the global and required qualifiers.
  --     Check the range code Low and High.
  --     Check that the total of value set maximum sizes + the number of segment separators
  --     does not add up to more than 240
  --     **GL Accounting Flexfield specific validation**
  --       The accounting flexfield requires consecutive segment numbers beginning with 1.
  --       There must be two different segments for the balancing segment and the
  --       natural account segment.
  --
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  PROCEDURE validate_final_structure(v_application_id           IN NUMBER,
                                     v_id_flex_code             IN VARCHAR2,
                                     v_id_flex_num              IN NUMBER)
  IS
    v_freeze_flex_definition_flag          VARCHAR2(1);
    v_segment_prompt                       VARCHAR2(50);
    v_segment_num                          NUMBER(4);
    v_range_code                           VARCHAR2(1);
    v_range_code_min_high_seg_num          NUMBER(4);
    v_range_code_min_low_seg_num           NUMBER(4);
    v_range_code_max_high_seg_num          NUMBER(4);
    v_range_code_max_low_seg_num           NUMBER(4);
    v_max                                  NUMBER(3);
    v_count                                NUMBER(3);

    -- Retrieve the flexfield structure information required.
    CURSOR c_id_flex_structure IS
      SELECT freeze_flex_definition_flag
      FROM FND_ID_FLEX_STRUCTURES
      WHERE application_id = v_application_id
        AND id_flex_code = v_id_flex_code
        AND id_flex_num = v_id_flex_num;

    -- Check if any segment qualifiers is missing.
    CURSOR c_check_qualifiers
    IS
    SELECT sat.segment_prompt,
           fs.segment_num
    FROM FND_ID_FLEX_SEGMENTS fs,
         FND_SEGMENT_ATTRIBUTE_TYPES sat
    WHERE fs.application_id = v_application_id
      AND fs.id_flex_code = v_id_flex_code
      AND fs.id_flex_num = v_id_flex_num
      AND sat.application_id = v_application_id
      AND sat.id_flex_code = v_id_flex_code
      AND NOT EXISTS (SELECT 'Exist'
                      FROM FND_SEGMENT_ATTRIBUTE_VALUES sav
                      WHERE sav.application_id = v_application_id
                        AND sav.id_flex_code = v_id_flex_code
                        AND sav.id_flex_num = v_id_flex_num
                        AND sav.application_column_name = fs.application_column_name
                        AND sav.segment_attribute_type = sat.segment_attribute_type);

    -- Check if all required segment qualifiers are defined.
    CURSOR c_check_required_qualifiers
    IS
      SELECT sat.segment_prompt
      FROM FND_ID_FLEX_STRUCTURES ft,
           FND_SEGMENT_ATTRIBUTE_TYPES sat
      WHERE ft.application_id = v_application_id
        AND ft.id_flex_code = v_id_flex_code
        AND ft.id_flex_num = v_id_flex_num
        AND sat.application_id = v_application_id
        AND sat.id_flex_code = v_id_flex_code
        AND sat.required_flag = 'Y'
        AND NOT EXISTS (SELECT 'Exist'
                        FROM FND_SEGMENT_ATTRIBUTE_VALUES sav,
                             FND_ID_FLEX_SEGMENTS fs
                        WHERE sav.application_id = v_application_id
                          AND sav.id_flex_code = v_id_flex_code
                          AND sav.id_flex_num = v_id_flex_num
                          AND sav.segment_attribute_type = sat.segment_attribute_type
                          AND sav.attribute_value = 'Y'
                          AND fs.application_id = v_application_id
                          AND fs.id_flex_code = v_id_flex_code
                          AND fs.id_flex_num = v_id_flex_num
                          AND fs.application_column_name = sav.application_column_name
                          AND fs.enabled_flag = 'Y');

    -- Retrieve the range code information
    CURSOR c_check_range_code
    IS
      SELECT fs.segment_num, fs.range_code
      FROM FND_ID_FLEX_SEGMENTS fs
      WHERE fs.application_id = v_application_id
        AND fs.id_flex_code = v_id_flex_code
        AND fs.id_flex_num = v_id_flex_num
        AND fs.range_code IN ('L','H')
        AND fs.enabled_flag = 'Y';

    -- Variable to loop on c_check_range_code
    v_check_range_code            c_check_range_code%ROWTYPE;

    -- Check if the balancing segment and the natural account segment are the same.
    CURSOR c_check_balancing_and_account
    IS
      SELECT fs.segment_num
      FROM FND_ID_FLEX_SEGMENTS fs
      WHERE fs.application_id = v_application_id
        AND fs.id_flex_code = v_id_flex_code
        AND fs.id_flex_num = v_id_flex_num
        AND fs.application_column_name IN (SELECT sav1.application_column_name
                                           FROM FND_SEGMENT_ATTRIBUTE_VALUES sav1,
                                                FND_SEGMENT_ATTRIBUTE_VALUES sav2
                                           WHERE sav1.application_id = v_application_id
                                             AND sav1.id_flex_code = v_id_flex_code
                                             AND sav1.id_flex_num = v_id_flex_num
                                             AND sav1.segment_attribute_type = 'GL_ACCOUNT'
                                             AND sav1.attribute_value = 'Y'
                                             AND sav1.application_column_name = sav2.application_column_name
                                             AND sav2.application_id = v_application_id
                                             AND sav2.id_flex_code = v_id_flex_code
                                             AND sav2.id_flex_num = v_id_flex_num
                                             AND sav2.segment_attribute_type = 'GL_BALANCING'
                                             AND sav2.attribute_value = 'Y');

  BEGIN
    --
    -- Retrieve the flexfield structure information.
    --
    OPEN c_id_flex_structure;
    FETCH c_id_flex_structure
    INTO v_freeze_flex_definition_flag;

    --
    -- Check that the flexfield structure exists
    --
    IF c_id_flex_structure%FOUND THEN
      CLOSE c_id_flex_structure;
    ELSE
      CLOSE c_id_flex_structure;
      return;
    END IF;

    --
    -- Check if the flexfield is supported by the API
    --
    IF (NOT is_flexfield_supported(v_application_id => v_application_id,
                                   v_id_flex_code => v_id_flex_code))
    THEN
      RAISE flexfield_not_supported;
    END IF;

    --
    -- The total of value set maximum sizes + the number of segment separators
    -- should not add up to more than 240.
    --
    SELECT NVL((sum(fv.maximum_size) + count(fs.application_column_name) - 1),0)
    INTO v_count
    FROM FND_ID_FLEX_SEGMENTS fs,
         FND_FLEX_VALUE_SETS fv
    WHERE fs.application_id = v_application_id
      AND fs.id_flex_code = v_id_flex_code
      AND fs.id_flex_num = v_id_flex_num
      AND fv.flex_value_set_id (+) = fs.flex_value_set_id;

    IF (v_count > 240) THEN
      RAISE sum_maximum_size_too_large;
    END IF;

    --
    -- Check if there is a row for each segment for each qualifier.
    --
    OPEN c_check_qualifiers;
    FETCH c_check_qualifiers
    INTO v_segment_prompt, v_segment_num;

    IF c_check_qualifiers%NOTFOUND THEN
      CLOSE c_check_qualifiers;
    ELSE
      CLOSE c_check_qualifiers;
      RAISE attribute_must_exist;
    END IF;

    --
    -- **GL Accounting Flexfield specific validation**
    --
    IF (v_application_id = 101 AND v_id_flex_code = 'GL#') THEN

      --
      -- **GL Accounting Flexfield specific validation**
      -- The accounting flexfield requires consecutive segment numbers beginning with 1.
      --
      SELECT max(segment_num),count(segment_num)
      INTO v_max,v_count
      FROM FND_ID_FLEX_SEGMENTS
      WHERE application_id = v_application_id
        AND id_flex_code = v_id_flex_code
        AND id_flex_num = v_id_flex_num;

      IF (v_max <> v_count) THEN
        RAISE gl_segment_not_consecutive;
      END IF;

      --
      -- **GL Accounting Flexfield specific validation**
      -- There must be two different segments for the balancing segment and the
      -- natural account segment.
      --
      OPEN c_check_balancing_and_account;
      FETCH c_check_balancing_and_account
      INTO v_segment_num;

      IF c_check_balancing_and_account%NOTFOUND THEN
        CLOSE c_check_balancing_and_account;
      ELSE
        CLOSE c_check_balancing_and_account;
        RAISE gl_same_bal_acct_segment;
      END IF;

    END IF;

    --
    -- ** Frozen structure validation **
    --
    IF (v_freeze_flex_definition_flag = 'Y') THEN

      --
      -- ** Frozen structure validation **
      -- Check for the required qualifiers
      -- We do not consider disabled segments.
      --
      OPEN c_check_required_qualifiers;
      FETCH c_check_required_qualifiers
      INTO v_segment_prompt;

      IF c_check_required_qualifiers%NOTFOUND THEN
        CLOSE c_check_required_qualifiers;
      ELSE
        CLOSE c_check_required_qualifiers;
        RAISE required_attr_must_exist;
      END IF;

      --
      -- ** Frozen structure validation **
      -- If you choose Low for one segment, you must also choose High for another segment in
      -- that structure (and vice versa). Furthermore, segments with a range type of Low must
      -- appear before segments with a range type of High.
      --
      FOR v_check_range_code IN c_check_range_code LOOP
        v_segment_num := v_check_range_code.segment_num;
        v_range_code := v_check_range_code.range_code;

        IF (v_range_code = 'L') THEN
          SELECT NVL(min(segment_num),-1000)
          INTO v_range_code_min_high_seg_num
          FROM FND_ID_FLEX_SEGMENTS fs
          WHERE fs.application_id = v_application_id
            AND fs.id_flex_code = v_id_flex_code
            AND fs.id_flex_num = v_id_flex_num
            AND fs.segment_num > v_segment_num
            AND fs.enabled_flag = 'Y'
            AND fs.range_code = 'H';

          SELECT NVL(min(segment_num),1000)
          INTO v_range_code_min_low_seg_num
          FROM FND_ID_FLEX_SEGMENTS fs
          WHERE fs.application_id = v_application_id
            AND fs.id_flex_code = v_id_flex_code
            AND fs.id_flex_num = v_id_flex_num
            AND fs.segment_num > v_segment_num
            AND fs.enabled_flag = 'Y'
            AND fs.range_code = 'L';

          IF (v_range_code_min_high_seg_num < v_segment_num
              OR v_range_code_min_low_seg_num < v_range_code_min_high_seg_num) THEN
            RAISE invalid_low_high_range_code;
          END IF;

        ELSE IF (v_range_code = 'H') THEN
          SELECT NVL(max(segment_num),1000)
          INTO v_range_code_max_low_seg_num
          FROM FND_ID_FLEX_SEGMENTS fs
          WHERE fs.application_id = v_application_id
            AND fs.id_flex_code = v_id_flex_code
            AND fs.id_flex_num = v_id_flex_num
            AND fs.segment_num < v_segment_num
            AND fs.enabled_flag = 'Y'
            AND fs.range_code = 'L';

          SELECT NVL(max(segment_num),-1000)
          INTO v_range_code_max_high_seg_num
          FROM FND_ID_FLEX_SEGMENTS fs
          WHERE fs.application_id = v_application_id
            AND fs.id_flex_code = v_id_flex_code
            AND fs.id_flex_num = v_id_flex_num
            AND fs.segment_num < v_segment_num
            AND fs.enabled_flag = 'Y'
            AND fs.range_code = 'H';

          IF (v_range_code_max_low_seg_num > v_segment_num
              OR v_range_code_max_high_seg_num > v_range_code_max_low_seg_num) THEN
            RAISE invalid_low_high_range_code;
          END IF;

          END IF;
        END IF;
      END LOOP;
    END IF;

    --
    -- After inserting or updating a new segment for the flexfield,
    -- we also need to insert into the FND_FLEX_VALIDATION_QUALIFIERS table,
    -- if this has not already been done.
    --
    INSERT INTO fnd_flex_validation_qualifiers( flex_value_set_id,
                                                id_flex_application_id,
                                                id_flex_code,
                                                segment_attribute_type,
                                                value_attribute_type,
                                                assignment_date )
    SELECT seg.flex_value_set_id,
           v_application_id,
           v_id_flex_code,
           sav.segment_attribute_type,
           vat.value_attribute_type,
           sysdate
    FROM fnd_segment_attribute_values sav,
         fnd_value_attribute_types vat,
         fnd_id_flex_segments seg
    WHERE seg.application_id = v_application_id
      AND seg.id_flex_code = v_id_flex_code
      AND seg.id_flex_num = v_id_flex_num
      AND seg.flex_value_set_id IS NOT NULL
      AND seg.enabled_flag = 'Y'
      AND sav.application_id = v_application_id
      AND sav.id_flex_code = v_id_flex_code
      AND sav.id_flex_num = v_id_flex_num
      AND sav.application_column_name = seg.application_column_name
      AND sav.attribute_value = 'Y'
      AND sav.application_id = vat.application_id
      AND sav.id_flex_code = vat.id_flex_code
      AND sav.segment_attribute_type = vat.segment_attribute_type
      AND NOT EXISTS
         (SELECT NULL
          FROM fnd_flex_validation_qualifiers q
          WHERE q.flex_value_set_id = seg.flex_value_set_id
          AND q.id_flex_application_id = v_application_id
          AND q.id_flex_code = v_id_flex_code
          AND q.segment_attribute_type = sav.segment_attribute_type
          AND q.value_attribute_type = vat.value_attribute_type);

    --
    -- The final validation for the structure is successful.
    --
    return;

  EXCEPTION
    WHEN flexfield_not_supported THEN
      fnd_message.set_name('SQLGL','GL_API_COA_FLEX_NOT_SUPPORTED');
      app_exception.raise_exception;

    WHEN attribute_must_exist THEN
      fnd_message.set_name('SQLGL','GL_API_COA_QUAL_MUST_EXIST');
      fnd_message.set_token('QUAL',v_segment_prompt);
      fnd_message.set_token('SEG',v_segment_num);
      app_exception.raise_exception;

    WHEN sum_maximum_size_too_large THEN
      fnd_message.set_name('SQLGL','GL_API_COA_SUM_MAXSIZE_TOO_LAR');
      fnd_message.set_token('SUM',v_count);
      app_exception.raise_exception;

    WHEN invalid_low_high_range_code THEN
      fnd_message.set_name('SQLGL','GL_API_COA_INVALID_RANGE_CODE');
      app_exception.raise_exception;

    WHEN gl_segment_not_consecutive THEN
      fnd_message.set_name('SQLGL','GL_API_COA_SEG_NOT_CONS');
      app_exception.raise_exception;

    WHEN gl_same_bal_acct_segment THEN
      fnd_message.set_name('SQLGL','GL_API_COA_SAME_BAL_ACCT_SEG');
      app_exception.raise_exception;

    WHEN required_attr_must_exist THEN
      fnd_message.set_name('SQLGL','GL_API_COA_UNIQUE_QUAL_ERR');
      fnd_message.set_token('QUAL',v_segment_prompt);
      app_exception.raise_exception;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_final_structure');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;

  END validate_final_structure;


  --
  -- Procedure
  --   compile_key_flexfield
  -- Purpose
  --   Compile the key flexfield.
  -- History
  --   10.09.2000  O Monnier      Created.
  --
  FUNCTION compile_key_flexfield(v_application_id           IN NUMBER,
                                 v_id_flex_code             IN VARCHAR2,
                                 v_id_flex_structure_code   IN VARCHAR2) RETURN VARCHAR2
  IS
    v_application_short_name    VARCHAR2(50);
    v_id_flex_num               NUMBER(15);
    v_structure_view_name       VARCHAR2(30);
    v_count                     NUMBER;
    v_set_flag                  VARCHAR(1) := 'N';
    ret                         VARCHAR2(500) := '';
    request_id                  NUMBER := -1;
    request_id2                 NUMBER := -1;
    request_id3                 NUMBER := -1;

    -- Retrieve the application short name.
    CURSOR c_application_short_name IS
      SELECT application_short_name
      FROM FND_APPLICATION
      WHERE application_id = v_application_id;

    -- Retrieve the flexfield structure information required.
    CURSOR c_id_flex_structure IS
      SELECT id_flex_num,
             structure_view_name
      FROM FND_ID_FLEX_STRUCTURES
      WHERE application_id = v_application_id
        AND id_flex_code = v_id_flex_code
        AND id_flex_structure_code = v_id_flex_structure_code;

  BEGIN
    --
    -- Retrieve the flexfield structure information.
    --
    OPEN c_id_flex_structure;
    FETCH c_id_flex_structure
    INTO v_id_flex_num,
         v_structure_view_name;

    --
    -- Check that the flexfield structure exists
    --
    IF c_id_flex_structure%FOUND THEN
      CLOSE c_id_flex_structure;
    ELSE
      CLOSE c_id_flex_structure;
      RETURN ('The structure does not exist');
    END IF;

    --
    -- Retrieve the application_short_name.
    --
    OPEN c_application_short_name;
    FETCH c_application_short_name
    INTO v_application_short_name;

    --
    -- Check that the application_short_name exists.
    --
    IF c_application_short_name%FOUND THEN
      CLOSE c_application_short_name;
    ELSE
      CLOSE c_application_short_name;
      RAISE invalid_application_id;
    END IF;

    --
    -- Compile the Flexfield
    --
    request_id :=  FND_REQUEST.SUBMIT_REQUEST(
                    'FND',
                    'FDFCMPK',
                    '',
                    '',
                    FALSE,
                    'K',
                    v_application_short_name,
                    v_id_flex_code,
                    v_id_flex_num);

    IF (request_id = 0) THEN
      RAISE request_failed;
    END IF;

    ret := ret||'**Request id 1**'||to_char(request_id);

    --
    -- Generate the view only if the application owning the
    -- flexfield is installed at the site.
    --
    SELECT count(*)
    INTO v_count
    FROM fnd_product_installations
    WHERE application_id = v_application_id;

    IF (v_count = 0) THEN
      return (ret);
    END IF;

/* NOT NEEDED FOR THE CHART OF ACCOUNTS FLEXFIELD
   ONLY NEEDED FOR OTHER FLEXFIELDS
    --
    -- Check to see if this flexfield uses set numbers
    -- (hardcoded), if so set the set_flag to 'Y'.
    --
    IF (v_id_flex_code IN ('MSTK', 'MTLL','MICG', 'MDSP')) THEN
      v_set_flag := 'Y';
    END IF;*/

    --
    -- Create the structure view only if a structure
    -- view name has been given.
    --
    IF (v_structure_view_name IS NOT NULL) THEN
      request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                      'FND',
                      'FDFVGN',
                      '',
                      '',
                      FALSE,
                      '1',
                      to_char(v_application_id),
                      v_id_flex_code,
                      to_char(v_id_flex_num),
                      v_structure_view_name,
                      v_set_flag,
                      chr(0),
                      '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '',
                      '', '', '', '', '', '', '', '', '', '');

      IF (request_id2 = 0) THEN
        RAISE request_failed;
      END IF;

      ret := ret||'**Request id 2**'||to_char(request_id2);

    END IF;

    --
    -- Submit request for code combination view.
    --
    request_id3 := FND_REQUEST.SUBMIT_REQUEST(
                  'FND',
                  'FDFVGN',
                  '',
                  '',
                  FALSE,
                  '2',
                  to_char(v_application_id),
                  v_id_flex_code,
                  '',
                  v_set_flag,
                  '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '');

    IF (request_id3 = 0) THEN
      RAISE request_failed;
    END IF;

    ret := ret||'**Request id 3**'||to_char(request_id3);

    --
    -- The compilation of the flexfield is successful.
    --
    RETURN(ret);

  EXCEPTION
    WHEN invalid_application_id THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.compile_key_flexfield');
      fnd_message.set_token('EVENT','INVALID_APPLICATION_ID');
      app_exception.raise_exception;

    WHEN request_failed THEN
      fnd_message.set_name('SQLGL','GL_API_COA_FLEX_COMPILE_ERR');
      fnd_message.set_token('STRUCTURECODE',v_id_flex_structure_code);
      app_exception.raise_exception;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.compile_key_flexfield');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;

  END compile_key_flexfield;


  --
  -- Procedure
  --  validate_hierarchy
  -- Purpose
  --  Detect hierarchy loop in rows to be added to
  --  fnd_flex_value_norm_hierarchy
  -- History
  --   02.03.2001  M Marra      Created.
  --   03.08.2001  M Marra      Modified to work row by row rather than
  --                            validating the entire hierarchy at once.
  --                            This reflects the repositioning of
  --                            FndFlexValueNormHierarchyEO as a composite
  --                            child of FndFlexValueEO.
  --
  procedure validate_hierarchy (
    p_parent        IN varchar2,
    p_child_low     IN varchar2,
    p_child_high    IN varchar2,
    p_value_set_id  IN number
  ) is

    --is the p_parent a parent value?
    cursor parent_value_cursor is
      select 'x'
      from fnd_flex_values
      where flex_value_set_id = p_value_set_id
      and   flex_value        = p_parent
      and   summary_flag      = 'Y';

    --find all flex values in a given range
    cursor child_values_cursor is
     SELECT flex_value
     FROM fnd_flex_values
     WHERE flex_value_set_id = p_value_set_id
     AND   flex_value BETWEEN p_child_low AND p_child_high
     ORDER by flex_value;

   dum Varchar2(1);

  BEGIN

    -- **************************************************************
    -- We check if the parent falls into the child range before
    -- this procedure is called, so here we go straight to the
    -- verification of the parent value and child range values
    -- **************************************************************

    -- The parent
    Open parent_value_cursor;
    Fetch parent_value_cursor Into dum;
    if parent_value_cursor%NOTFOUND then
      Close parent_value_cursor;
      raise invalid_parent;
    end if;
    Close parent_value_cursor;

    -- The child range
    For c in child_values_cursor Loop

      if has_loop( c.flex_value, p_parent, p_value_set_id ) then
          RAISE hierarchy_loop;
      end if;

    End Loop;

  EXCEPTION
    WHEN invalid_parent then
      fnd_message.set_name('SQLGL','GL_API_COA_INVALID_HIER_PARENT');
      fnd_message.set_token('PARENT_VALUE', p_parent);
      app_exception.raise_exception;

    WHEN hierarchy_loop then
      fnd_message.set_name('SQLGL','GL_API_COA_HIERARCHY_LOOP');
      fnd_message.set_token('PARENT_VALUE', p_parent);
      fnd_message.set_token('CHILD_LOW',    p_child_low);
      fnd_message.set_token('CHILD_HIGH',   p_child_high);
      app_exception.raise_exception;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.validate_hierarchy');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;
  END validate_hierarchy;

  --
  -- Procedure
  --   compile_hierarchy
  -- Purpose
  --   Compile hierarchy data from fnd_flex_value_norm_hierarchy.
  -- History
  --   02.03.2001  MMarra      Created.
  --
  FUNCTION compile_hierarchy (
    p_flex_value_set_id   IN   NUMBER
  ) RETURN VARCHAR2 IS

    request_id                  NUMBER := -1;

    -- In case we need the value set name
    cursor vset_name_cursor is
      select flex_value_set_name
      from fnd_flex_value_sets
      where flex_value_set_id = p_flex_value_set_id;
    vset_name varchar2(100);

  BEGIN

    --
    -- FOR TESTING PURPOSE ( finspeed, SYSADMIN - System Administrator)
    -- NEEDS TO BE REMOVED
    --
    FND_PROFILE.put('USER_ID', 0 );
    FND_PROFILE.put('RESP_ID', 20420);
    FND_PROFILE.put('RESP_APPL_ID', 1);

    --
    -- Compile
    --
    request_id :=  FND_REQUEST.SUBMIT_REQUEST(
                    'FND',
                    'FDFCHY',
                    '',
                    '',
                    FALSE,
                    to_char(p_flex_value_set_id),
                    chr(0), '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '',
                    '', '', '', '', '', '', '', '', '', '');

    IF (request_id = 0) THEN
      Open vset_name_cursor;
      Fetch vset_name_cursor Into vset_name;
      Close vset_name_cursor;
      RAISE request_failed;
    END IF;

    --
    -- The compilation is successful.
    --
    RETURN('**Request id** '||to_char(request_id));

  EXCEPTION
    WHEN request_failed THEN
/* There was a mismatch in error message called here (GL_API_COA_HIER_COMPILE_ERR) and error message defined (GL_API_COA_HIER_COMPILE_ERROR). Same corrected */
      fnd_message.set_name('SQLGL','GL_API_COA_HIER_COMPILE_ERROR');
      fnd_message.set_token('VALUE_SET_NAME',vset_name);
      app_exception.raise_exception;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE','GL_CHART_OF_ACCOUNTS_API_PKG.compile_hierarchy');
      fnd_message.set_token('EVENT','OTHERS');
      app_exception.raise_exception;

  END compile_hierarchy;

END GL_CHART_OF_ACCOUNTS_API_PKG;

/
