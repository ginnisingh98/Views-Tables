--------------------------------------------------------
--  DDL for Package Body FEM_CHECK_BR_DIS_MBRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_CHECK_BR_DIS_MBRS_PKG" AS
 /* $Header: fem_chk_dis_mbrs.plb 120.3.12010000.3 2009/10/01 18:35:03 ghall ship $ */

-------------------------------------------------------------------------------
-- PRIVATE VARIABLES
-------------------------------------------------------------------------------

pv_report_row_counter    NUMBER;

-------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
-------------------------------------------------------------------------------

PROCEDURE Find_Root_Rules (
  p_rule_type       IN  VARCHAR2,
  p_ledger_id       IN  NUMBER,
  p_effective_date  IN  DATE,
  p_folder_id       IN  NUMBER,
  p_object_id       IN  NUMBER,
  p_global_vs_id    IN  NUMBER);

PROCEDURE Validate_Root_Rule (
  p_obj_def_id            IN  NUMBER,
  p_parent_report_row_id  IN  NUMBER,
  p_effective_date        IN  DATE,
  p_global_vs_id          IN  NUMBER,
  p_param_dim_id          IN  NUMBER,
  p_stack_level           IN  NUMBER DEFAULT 0,
  x_all_rules_are_valid   OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Rule_Wrapper (
  p_obj_def_id    IN  NUMBER,
  p_global_vs_id  IN  NUMBER,
  p_param_dim_id  IN  NUMBER,
  x_this_is_valid OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Mapping (
  p_obj_def_id    IN  NUMBER,
  p_global_vs_id  IN  NUMBER,
  p_param_dim_id  IN  NUMBER,
  x_this_is_valid OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Dim_Component (
  p_obj_def_id    IN  NUMBER,
  p_global_vs_id  IN  NUMBER,
  p_param_dim_id  IN  NUMBER,
  x_this_is_valid OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Data_Component (
  p_obj_def_id    IN  NUMBER,
  p_global_vs_id  IN  NUMBER,
  p_param_dim_id  IN  NUMBER,
  x_this_is_valid OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Statistic (
  p_obj_def_id    IN  NUMBER,
  p_global_vs_id  IN  NUMBER,
  p_param_dim_id  IN  NUMBER,
  x_this_is_valid OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Hierarchy (
  p_obj_def_id    IN  NUMBER,
  p_global_vs_id  IN  NUMBER,
  p_param_dim_id  IN  NUMBER,
  x_this_is_valid OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Factor_Table (
  p_obj_def_id    IN  NUMBER,
  p_global_vs_id  IN  NUMBER,
  p_param_dim_id  IN  NUMBER,
  x_this_is_valid OUT NOCOPY VARCHAR2);

PROCEDURE Get_Put_Messages;

PROCEDURE Populate_Dim_Info;

-------------------------------------------------------------------------------
-- PRIVATE BODIES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Find_Root_Rules
--
-- DESCRIPTION
--   The procedure needs to find the set of root rules that needs
--   to be checked for disabled dimension members.  If the Rule Name
--   parameter is specified and the rule given is a rule set,
--   this procedure will need to flatten the rule set to determine the
--   list of rules to validate.  If a rule set is not specified,
--   then the list of root rules will be based on the other runtime
--   parameters such as Ledger and Folder.
--
-------------------------------------------------------------------------------
PROCEDURE Find_Root_Rules (
  p_rule_type       IN  VARCHAR2,
  p_ledger_id       IN  NUMBER,
  p_effective_date  IN  DATE,
  p_folder_id       IN  NUMBER,
  p_object_id       IN  NUMBER,
  p_global_vs_id    IN  NUMBER)
-------------------------------------------------------------------------------
IS
--
  C_MODULE    CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_dis_mbr_pkg.find_root_rules';
--
  v_return_status       VARCHAR2(1);
  v_msg_count           NUMBER;
  v_msg_data            VARCHAR2(4000);
  v_rule_type           FEM_OBJECT_TYPES_B.object_type_code%TYPE;
  v_folder_id           NUMBER;
  v_global_vs_id        NUMBER;
  v_obj_name            FEM_OBJECT_CATALOG_VL.object_name%TYPE;
  v_is_rule_set         VARCHAR2(1);
  v_ds_io_def_id        NUMBER;
  v_obj_def_id          NUMBER;
  v_err_code            NUMBER;
--
  -- Get all root rules as limited by the runtime parameters.
  CURSOR c_all_root_rules IS
    SELECT object_id
    FROM fem_object_catalog_b
    WHERE object_type_code = p_rule_type
    AND local_vs_combo_id = p_global_vs_id
    AND folder_id = Nvl(p_folder_id, folder_id)
    AND object_id = Nvl(p_object_id, object_id);
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
  FEM_ENGINES_PKG.TECH_MESSAGE(
    p_severity => FND_LOG.level_procedure,
    p_module   => C_MODULE,
    p_msg_text => 'Begin Procedure');
  END IF;

  -- Initinalize var:
  v_is_rule_set := 'N';

  -- If p_object_id is given,
  --   Make sure it is either a rule or rule set of the type p_rule_type.
  --   Make sure its Global Value Set Combination corresponds to the
  --     Ledger parameter.
  --   Make sure its Folder corresponds to the Folder parameter (if specified)
  IF (p_object_id IS NOT NULL) THEN
    SELECT Decode(object_type_code, 'RULE_SET',
                  (SELECT rs.rule_set_object_type_code
                   FROM fem_object_definition_b od, fem_rule_sets rs
                   WHERE rs.rule_set_obj_def_id = od.object_definition_id
                   AND od.object_id = p_object_id),
                  object_type_code) rule_type,
           local_vs_combo_id, folder_id, object_name,
           Decode(object_type_code, 'RULE_SET', 'Y', 'N')
    INTO v_rule_type, v_global_vs_id, v_folder_id, v_obj_name, v_is_rule_set
    FROM fem_object_catalog_vl
    WHERE object_id = p_object_id;

    IF (v_global_vs_id <> p_global_vs_id) THEN
      IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_unexpected,
          p_module   => C_MODULE,
          p_msg_text => 'UNEXP ERROR: For rule name ('
                      || v_obj_name||'), its GVSC ('
                      || v_global_vs_id||') does not match the'
                      ||' GVSC for ledger.');
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (v_folder_id <> Nvl(p_folder_id, v_folder_id)) THEN
      IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_unexpected,
          p_module   => C_MODULE,
          p_msg_text => 'UNEXP ERROR: For rule name ('
                      || v_obj_name||'), its folder id ('
                      || v_folder_id||') does not match the'
                      ||' parameter folder id.');
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (v_rule_type <> p_rule_type) THEN
      IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_unexpected,
          p_module   => C_MODULE,
          p_msg_text => 'UNEXP ERROR: For rule name ('
                      || v_obj_name||'), its rule type ('
                      || v_rule_type||') does not match the'
                      ||' parameter rule type.');
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF; -- IF (p_object_id IS NOT NULL)

  -- Get a non-production dataset if one exists.
  -- If not, get a production one.  If none exist, raise unexp error.
  BEGIN
    SELECT io.dataset_io_obj_def_id
    INTO v_ds_io_def_id
    FROM fem_datasets_attr dsa, fem_dim_attributes_b dma,
         fem_datasets_b d, fem_ds_input_output_defs io
    WHERE io.output_dataset_code = d.dataset_code
    AND dsa.DATASET_CODE = io.output_dataset_code
    AND dma.attribute_id = dsa.attribute_id
    AND dma.attribute_varchar_label = 'PRODUCTION_FLAG'
    AND rownum = 1
    ORDER BY dsa.dim_attribute_varchar_member;
  EXCEPTION
    WHEN no_data_found THEN
      -- This message will be caught by the top calling routine and
      -- displayed in the conc program UI.
      FEM_ENGINES_PKG.Put_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_MISSING_DATASET_GROUP');

      IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.Tech_Message(
          p_severity => FND_LOG.level_unexpected,
          p_module   => C_MODULE,
          p_app_name => 'FEM',
          p_msg_name => 'FEM_MISSING_DATASET_GROUP');
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'v_ds_io_def_id = '||v_ds_io_def_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'v_is_ruleset = '||v_is_rule_set);
  END IF;

  -- If rule type is ruleset, flatten the ruleset into FEM_RULESET_PROCESS_DATA
  -- then copy it to FEM_BR_ROOT_RULES_GT before cleaning it back up.
  IF (v_is_rule_set = 'Y') THEN
    -- Flatten the ruleset
    FEM_RULE_SET_MANAGER.FEM_Preprocess_RuleSet_PVT(
      p_api_version                  => 1.0,
      x_return_status                => v_return_status,
      x_msg_count                    => v_msg_count,
      x_msg_data                     => v_msg_data,
      p_Orig_RuleSet_Object_ID       => p_object_id,
      p_DS_IO_Def_ID                 => v_ds_io_def_id,
      p_Rule_Effective_Date          => FND_DATE.Date_To_Canonical(p_effective_date),
      p_Output_Period_ID             => NULL,
      p_Ledger_ID                    => p_ledger_id,
      p_Continue_Process_On_Err_Flg  => 'Y',
      p_Execution_Mode               => 'E');

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'FEM_RULE_SET_MANAGER.FEM_Preprocess_RuleSet_PVT'
                    ||' returned with status: '||v_return_status);
    END IF;

    IF v_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Move valid flattened rule versions from the
    --   FEM_RULESET_PROCESS_DATA table to the FEM_BR_ROOT_RULES_GT table.
    INSERT INTO fem_br_root_rules_gt(object_definition_id)
      SELECT child_obj_def_id
      FROM fem_ruleset_process_data
      WHERE rule_set_obj_id = p_object_id;

    -- Clean up the FEM_RULESET_PROCESS_DATA table
    FEM_RULE_SET_MANAGER.FEM_DeleteFlatRuleList_PVT(
      p_api_version                  => 1.0,
      x_return_status                => v_return_status,
      x_msg_count                    => v_msg_count,
      x_msg_data                     => v_msg_data,
      p_RuleSet_Object_ID            => p_object_id);

    IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_unexpected,
          p_module   => C_MODULE,
          p_msg_text => 'INTERNAL ERROR: Call to'
                      ||' FEM_RULE_SET_MANAGER.FEM_DeleteFlatRuleList_PVT'
                      ||' failed with return status: '||v_return_status);
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  ELSE  -- ELSIF (v_is_ruleset = 'N')
    -- If ruleset is not provided, find all rules limited by the
    -- Rule Type, Ledger and Folder parameters.
    FOR all_root_rules IN c_all_root_rules LOOP
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'all_root_rules.object_id = '||all_root_rules.object_id);
      END IF;

      -- Validate each rule
      FEM_RULE_SET_MANAGER.Validate_Rule_Public(
        p_api_version           => 1.0,
        x_return_status         => v_return_status,
        x_msg_count             => v_msg_count,
        x_msg_data              => v_msg_data,
        p_Rule_Object_ID        => all_root_rules.object_id,
        p_DS_IO_Def_ID          => v_ds_io_def_id,
        p_Rule_Effective_Date   => FND_DATE.Date_To_Canonical(p_effective_date),
        p_Reference_Period_ID   => NULL,
        p_Ledger_ID             => p_ledger_id);

      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'FEM_RULE_SET_MANAGER.Validate_Rule_Public'
                      ||' returned with status: '||v_return_status);
      END IF;

      -- If rule is valid, get its version info
      IF v_return_status = FND_API.G_RET_STS_SUCCESS THEN
        FEM_RULE_SET_MANAGER.Get_ValidDefinition_Pub(
          p_Object_ID             => all_root_rules.object_id,
          p_Rule_Effective_Date   => FND_DATE.Date_To_Canonical(p_effective_date),
          x_Object_Definition_ID  => v_obj_def_id,
          x_Err_Code              => v_err_code,
          x_Err_Msg               => v_msg_data);

        IF (v_err_code = 0) THEN
          INSERT INTO fem_br_root_rules_gt(object_definition_id)
            VALUES(v_obj_def_id);
        ELSE
          -- If the rule passed validation, this routine should never error.
          -- If it does, raise unexp error.
          IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => FND_LOG.level_unexpected,
              p_module   => C_MODULE,
              p_msg_text => 'UNEXPECTED ERROR: Call to'
                          ||' FEM_RULE_SET_MANAGER.Get_ValidDefinition_Pub'
                          ||' failed with x_err_msg: '||v_msg_data);
          END IF;

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      ELSIF v_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

    END LOOP;  -- c_all_root_rules

  END IF; -- IF (v_is_ruleset = 'Y')

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END Find_Root_Rules;
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Validate_Root_Rule
--
-- DESCRIPTION
--   Given a rule version, this procedure will do a recursive traversal
--   through the rule dependency structure so that it and all of its
--   referenced rules are validated.  In the process, it will populate
--   the reporting tables either directly or through calls to the
--   individual rule type validation routines.
--
-------------------------------------------------------------------------------
PROCEDURE Validate_Root_Rule (
  p_obj_def_id            IN  NUMBER,
  p_parent_report_row_id  IN  NUMBER,
  p_effective_date        IN  DATE,
  p_global_vs_id          IN  NUMBER,
  p_param_dim_id          IN  NUMBER,
  p_stack_level           IN  NUMBER DEFAULT 0,
  x_all_rules_are_valid   OUT NOCOPY VARCHAR2)
-------------------------------------------------------------------------------
IS
--
  C_MODULE    CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_dis_mbr_pkg.validate_root_rule';
--
  v_module    FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_dis_mbr_pkg.validate_root_rule.'||p_stack_level;
  v_curr_report_id        NUMBER;
  v_ref_obj_def_id        NUMBER;
  v_err_code              NUMBER;
  v_msg_data              VARCHAR2(4000);
  v_ref_rule_is_valid     VARCHAR2(1);
  v_all_ref_rules_valid   VARCHAR2(1);
  v_this_rule_is_valid    VARCHAR2(1);
--
  -- Bug 6972946: Ignore any objects left in the Object Dependencies table
  -- if they no longer exists as objects (to prevent unexpected errors).
  CURSOR c_ref_rules(cv_obj_def_id NUMBER) IS
    SELECT required_object_id
    FROM fem_object_dependencies d
    WHERE object_definition_id = cv_obj_def_id
    AND EXISTS (
      SELECT null
      FROM fem_object_catalog_b c
      WHERE c.object_id = d.required_object_id);
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => v_module,
      p_msg_text => 'Begin Procedure: '||p_stack_level);
  END IF;
--
  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => v_module,
      p_msg_text => 'p_obj_def_id = '||p_obj_def_id
                  ||'; p_parent_report_row_id = '||p_parent_report_row_id);
  END IF;
--

  -- Initialize var:
  v_all_ref_rules_valid := 'Y';

  -- Get a unique report row ID for this current rule
  v_curr_report_id := Get_Unique_Report_Row();

  -- Loop through all rules referenced by this current rule
  -- and recursively check those rules for disabled members.
  FOR ref_rules IN c_ref_rules(p_obj_def_id) LOOP
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => v_module,
        p_msg_text => 'ref_rules.required_object_id = '
                    ||ref_rules.required_object_id);
    END IF;

    -- First get the obj def id of the referenced rule
    FEM_RULE_SET_MANAGER.Get_ValidDefinition_Pub(
      p_Object_ID             => ref_rules.required_object_id,
      p_Rule_Effective_Date   => FND_DATE.Date_To_Canonical(p_effective_date),
      x_Object_Definition_ID  => v_ref_obj_def_id,
      x_Err_Code              => v_err_code,
      x_Err_Msg               => v_msg_data);

    IF (v_err_code <> 0) THEN
      -- If the rule passed validation, this routine should never error.
      -- If it does, raise unexp error.
      IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_unexpected,
          p_module   => v_module,
          p_msg_text => 'UNEXPECTED ERROR: Call to'
                      ||' FEM_RULE_SET_MANAGER.Get_ValidDefinition_Pub'
                      ||' failed with x_err_msg: '||v_msg_data);
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Now recurse on the referenced rule
    Validate_Root_Rule(p_obj_def_id           => v_ref_obj_def_id,
                       p_parent_report_row_id => v_curr_report_id,
                       p_effective_date       => p_effective_date,
                       p_global_vs_id         => p_global_vs_id,
                       p_param_dim_id         => p_param_dim_id,
                       p_stack_level          => p_stack_level+1,
                       x_all_rules_are_valid  => v_ref_rule_is_valid);

    IF (v_ref_rule_is_valid = 'N') THEN
      v_all_ref_rules_valid := 'N';
    END IF;
  END LOOP; -- FOR ref_rules IN c_ref_rules LOOP

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => v_module,
      p_msg_text => 'v_all_ref_rules_valid = '||v_all_ref_rules_valid);
  END IF;

  -- Call the validation wrapper routine that in turn calls the
  -- validation procedure that corresopnds to the rule type.
  Validate_Rule_Wrapper(
    p_obj_def_id     => p_obj_def_id,
    p_global_vs_id   => p_global_vs_id,
    p_param_dim_id   => p_param_dim_id,
    x_this_is_valid  => v_this_rule_is_valid);

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => v_module,
      p_msg_text => 'v_this_rule_is_valid = '||v_this_rule_is_valid);
  END IF;

  -- If the current rule is invalid or any of the referenced rules are invalid,
  -- 1. Insert the current rule into FEM_BR_DIS_MBR_CONTEXTS
  --    without the actual context information to simply serve as
  --    the parent row for the rows that either contain the context
  --    information or referenced rules that are invalid.
  -- 2. If the current rule is invalid,
  --    insert the context information into FEM_BR_DIS_MBR_CONTEXTS
  --    from FEM_BR_DISABLED_MBRS_GT.
  IF (v_this_rule_is_valid = 'N' OR v_all_ref_rules_valid = 'N') THEN

    INSERT INTO fem_br_dis_mbr_contexts
     (request_id, report_row_id, parent_report_row_id,
      object_id, object_name, object_type_code, object_type_name,
      folder_id, folder_name, object_definition_id, object_definition_name,
      effective_start_date, effective_end_date,
      creation_date, created_by,
      last_updated_by, last_update_date, last_update_login)
    SELECT
      FND_GLOBAL.Conc_Request_ID, v_curr_report_id, p_parent_report_row_id,
      c.object_id, c.object_name, c.object_type_code, t.object_type_name,
      c.folder_id, f.folder_name, d.object_definition_id, d.display_name,
      d.effective_start_date, d.effective_end_date,
      sysdate, FND_GLOBAL.User_ID,
      FND_GLOBAL.User_ID, sysdate, FND_GLOBAL.Login_ID
    FROM fem_object_definition_vl d, fem_object_catalog_vl c,
         fem_object_types_vl t, fem_folders_vl f
    WHERE d.object_definition_id = p_obj_def_id
    AND d.object_id = c.object_id
    AND c.object_type_code = t.object_type_code
    AND c.folder_id = f.folder_id;

    IF (v_this_rule_is_valid = 'N') THEN
      -- When inserting into FEM_BR_DIS_MBR_CONTEXTS, get the translated
      -- context meaning and value set name.  The dimension member names
      -- will need to be filled in the Report_Invalid_Rules procedure
      -- after this procedure returns so we can populate all member names for
      -- a given dimension at a time.  Otherwise, we would have to populate
      -- the member names row by row here.

      INSERT INTO fem_br_dis_mbr_contexts
       (request_id, report_row_id, parent_report_row_id,
        object_id, object_name, object_type_code, object_type_name,
        folder_id, folder_name, object_definition_id, object_definition_name,
        effective_start_date, effective_end_date,
        context, dimension_id, dimension_name,
        dimension_member, value_set_id, value_set_name,
        creation_date, created_by,
        last_updated_by, last_update_date, last_update_login)
      SELECT FND_GLOBAL.Conc_Request_ID,
        FEM_CHECK_BR_DIS_MBRS_PKG.Get_Unique_Report_Row(), v_curr_report_id,
        c.object_id, c.object_name, c.object_type_code, t.object_type_name,
        c.folder_id, f.folder_name, d.object_definition_id, d.display_name,
        d.effective_start_date, d.effective_end_date,
        l.meaning context, b.dimension_id, dim.dimension_name,
        b.dimension_member, b.value_set_id, v.value_set_name,
        sysdate, FND_GLOBAL.User_ID,
        FND_GLOBAL.User_ID, sysdate, FND_GLOBAL.Login_ID
      FROM fem_br_disabled_mbrs_gt b, FEM_LOOKUPS l, fem_value_sets_vl v,
           fem_object_definition_vl d, fem_object_catalog_vl c,
           fem_object_types_vl t, fem_folders_vl f, fem_dimensions_vl dim
      WHERE b.object_definition_id = p_obj_def_id
      AND b.object_definition_id = d.object_definition_id
      AND d.object_id = c.object_id
      AND c.object_type_code = t.object_type_code
      AND c.folder_id = f.folder_id
      AND b.context_code = l.lookup_code
      AND l.lookup_type = 'FEM_DISABLED_MEMBER_CONTEXT'
      AND b.dimension_id = dim.dimension_id
      AND b.value_set_id = v.value_set_id(+);
    END IF;

     x_all_rules_are_valid := 'N';
  ELSE
     x_all_rules_are_valid := 'Y';
  END IF; -- IF (v_this_rule_is_valid = 'N' OR v_all_ref_rules_valid = 'N')

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => v_module,
      p_msg_text => 'x_all_rules_are_valid = '||x_all_rules_are_valid);
  END IF;
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
  FEM_ENGINES_PKG.TECH_MESSAGE(
    p_severity => FND_LOG.level_procedure,
    p_module   => v_module,
    p_msg_text => 'End Procedure: '||p_stack_level);
  END IF;
--
END Validate_Root_Rule;

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Validate_Rule_Wrapper
--
-- DESCRIPTION
--   Wrapper routine that calls the individual validation routines specific
--   to each rule type.  Before it validates a rule, it first checks to
--   see if it the rule has been validated before.  If yes, then just
--   return the results from the previous run.  After a call to a
--   validation routine, it inserts a row in FEM_BR_VALID_STATUS_GT
--   to record the validation result for the rule being checked.
--
-------------------------------------------------------------------------------
PROCEDURE Validate_Rule_Wrapper (
  p_obj_def_id    IN  NUMBER,
  p_global_vs_id  IN  NUMBER,
  p_param_dim_id  IN  NUMBER,
  x_this_is_valid OUT NOCOPY VARCHAR2)
-------------------------------------------------------------------------------
IS
--
  C_MODULE                CONSTANT FND_LOG_MESSAGES.module%TYPE :=
   'fem.plsql.fem_check_disabled_mbrs_pkg.validate_rule_wrapper';
--
  v_rule_type             FEM_OBJECT_TYPES_B.object_type_code%TYPE;
  v_this_rule_is_valid    VARCHAR2(1);
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;
--
  -- First check if this rule has been validated previously.
  -- If yes, then just return the previous results.
  BEGIN
    SELECT valid_flag
    INTO x_this_is_valid
    FROM fem_br_valid_status_gt
    WHERE object_definition_id = p_obj_def_id;
  EXCEPTION
    WHEN others THEN NULL;
  END;

  IF (x_this_is_valid IS NOT NULL) THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      -- Add this to make debug log more readable
      SELECT oc.object_type_code
      INTO v_rule_type
      FROM fem_object_catalog_b oc, fem_object_definition_b od
      WHERE oc.object_id = od.object_id
      AND od.object_definition_id = p_obj_def_id;

      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,

        p_msg_text => 'p_obj_def_id = '||p_obj_def_id
                  ||'; v_rule_type = '||v_rule_type);
    END IF;

    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure: RETURN: x_this_is_valid = '
                     ||x_this_is_valid);
    END IF;

    RETURN;
  END IF;

  -- Get rule type of current rule
  SELECT oc.object_type_code
  INTO v_rule_type
  FROM fem_object_catalog_b oc, fem_object_definition_b od
  WHERE oc.object_id = od.object_id
  AND od.object_definition_id = p_obj_def_id;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'v_rule_type = '||v_rule_type);
  END IF;

  -- Call the validation procedure that corresopnds to the rule type.
  IF (v_rule_type = 'MAPPING_RULE') THEN
    Validate_Mapping(
      p_obj_def_id     => p_obj_def_id,
      p_global_vs_id   => p_global_vs_id,
      p_param_dim_id   => p_param_dim_id,
      x_this_is_valid  => v_this_rule_is_valid);

  ELSIF (v_rule_type = 'CONDITION_DIMENSION_COMPONENT') THEN
    Validate_Dim_Component(
      p_obj_def_id     => p_obj_def_id,
      p_global_vs_id   => p_global_vs_id,
      p_param_dim_id   => p_param_dim_id,
      x_this_is_valid  => v_this_rule_is_valid);

  ELSIF (v_rule_type = 'CONDITION_DATA_COMPONENT') THEN
    Validate_Data_Component(
      p_obj_def_id     => p_obj_def_id,
      p_global_vs_id   => p_global_vs_id,
      p_param_dim_id   => p_param_dim_id,
      x_this_is_valid  => v_this_rule_is_valid);

  ELSIF (v_rule_type = 'STAT_LOOKUP') THEN
    Validate_Statistic(
      p_obj_def_id     => p_obj_def_id,
      p_global_vs_id   => p_global_vs_id,
      p_param_dim_id   => p_param_dim_id,
      x_this_is_valid  => v_this_rule_is_valid);

  ELSIF (v_rule_type = 'HIERARCHY') THEN
    Validate_Hierarchy(
      p_obj_def_id     => p_obj_def_id,
      p_global_vs_id   => p_global_vs_id,
      p_param_dim_id   => p_param_dim_id,
      x_this_is_valid  => v_this_rule_is_valid);

  ELSIF (v_rule_type IN ('FACTOR_TABLE')) THEN
    Validate_Factor_Table(
      p_obj_def_id     => p_obj_def_id,
      p_global_vs_id   => p_global_vs_id,
      p_param_dim_id   => p_param_dim_id,
      x_this_is_valid  => v_this_rule_is_valid);

  ELSIF (v_rule_type IN ('CONDITION','CONDITION_MAPPING')) THEN
    -- The condition rule itself does not reference any dimension members
    -- and so there is no need to call its validation procedure.
    v_this_rule_is_valid := 'Y';

  ELSE
    -- Unsupported rule type - raise unexpected error
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'This rule type is not supported: '||v_rule_type);
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF; -- IF (v_rule_type = 'MAPPING_RULE') THEN

  -- Insert validation status into FEM_BR_VALID_STATUS_GT
  INSERT INTO fem_br_valid_status_gt (object_definition_id, valid_flag)
  VALUES (p_obj_def_id, v_this_rule_is_valid);

  x_this_is_valid := v_this_rule_is_valid;
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure: x_this_is_valid = '||x_this_is_valid);
  END IF;
--
END Validate_Rule_Wrapper;



-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Validate_Mapping
--
-- DESCRIPTION
--   Validates the Mapping Rule asociated with given object definition id.
--   Optionally a value set or dimension id can be provided, which further
--   restricts the scope of the search to asceratin if the rule references and
--   disabled members.
--   If the rule references any disabled members, x_this_is_valid will return
--   'N' and the identifying information for each disabled member found will
--   be logged in the global temporary table fem_br_disabled_mbrs_gt. If it
--   does not reference any disabled members, x_this_is_valid will return 'Y'.
--
-------------------------------------------------------------------------------
PROCEDURE Validate_Mapping (
  p_obj_def_id    IN  NUMBER,
  p_global_vs_id  IN  NUMBER,
  p_param_dim_id  IN  NUMBER,
  x_this_is_valid OUT NOCOPY VARCHAR2)
-------------------------------------------------------------------------------
IS
--
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_disabled_mbrs_pkg.validate_mapping';

  v_member_table    FEM_TAB_COLUMNS_B.TABLE_NAME%TYPE;
  v_member_column   FEM_TAB_COLUMNS_B.COLUMN_NAME%TYPE;
  v_value_set_id    FEM_GLOBAL_VS_COMBO_DEFS.VALUE_SET_ID%TYPE;
  v_dim_id          FEM_TAB_COLUMNS_B.DIMENSION_ID%TYPE;
  v_func_cd         FEM_ALLOC_BR_DIMENSIONS.FUNCTION_CD%TYPE;
  v_datatype        FEM_XDIM_DIMENSIONS.MEMBER_DATA_TYPE_CODE%TYPE;
  v_value_set_flag  VARCHAR2(1);
  v_val_stmt        VARCHAR2(100);
  v_insert_stmt     VARCHAR2(1000);
  C_CONTEXT         FEM_BR_DISABLED_MBRS_GT.context_code%TYPE;

  --there can be multiple column/table/dimension combinations for each
  --object definition id.  This ensures that each is checked for
  --disabled members.
  cursor c_credit_debit (p_obj_def_id IN NUMBER, function_code IN VARCHAR2,
			 p_param_dim_id IN NUMBER) IS
    SELECT c.dimension_id, d.alloc_dim_col_name, d.post_to_balances_flag
    FROM fem_alloc_br_formula f, fem_alloc_br_dimensions d,
         fem_tab_columns_b c, fem_xdim_dimensions x
    WHERE f.object_definition_id = p_obj_def_id
    AND f.function_cd = function_code
    AND f.enable_flg = 'Y'
    AND f.table_name = c.table_name
    AND f.object_definition_id = d.object_definition_id
    AND f.function_cd = d.function_cd
    AND d.post_to_balances_flag = 'N'
    AND d.alloc_dim_usage_code = 'VALUE'
    AND d.alloc_dim_col_name = c.column_name
    AND c.dimension_id = nvl(p_param_dim_id, c.dimension_id)
    AND c.dimension_id = x.dimension_id
    AND x.hier_editor_managed_flag = 'Y'
    UNION ALL
    SELECT c.dimension_id, d.alloc_dim_col_name, d.post_to_balances_flag
    FROM fem_alloc_br_formula f, fem_alloc_br_dimensions d,
         fem_tab_columns_b c, fem_xdim_dimensions x
    WHERE f.object_definition_id = p_obj_def_id
    AND f.function_cd = function_code
    AND f.enable_flg = 'Y'
    AND f.post_to_ledger_flg = 'Y'
    AND c.table_name = 'FEM_BALANCES'
    AND f.object_definition_id = d.object_definition_id
    AND f.function_cd = d.function_cd
    AND d.post_to_balances_flag = 'Y'
    AND d.alloc_dim_usage_code = 'VALUE'
    AND d.alloc_dim_col_name = c.column_name
    AND c.dimension_id = nvl(p_param_dim_id, c.dimension_id)
    AND c.dimension_id = x.dimension_id
    AND x.hier_editor_managed_flag = 'Y';

  --need to get each of the contexts associated with the obj_def_id
  cursor c_get_context (p_obj_def_id IN NUMBER) IS
    SELECT f.function_cd, f.function_seq
    FROM fem_alloc_br_formula f
    WHERE ((f.function_cd = 'CREDIT' and f.enable_flg = 'Y')
    OR (f.function_cd = 'DEBIT' and f.enable_flg = 'Y')
    OR (f.function_cd = 'MACRO'))
    AND f.object_definition_id = p_obj_def_id;

BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_obj_def_id is ' || p_obj_def_id);

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_param_dim_id is ' || p_param_dim_id);

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_global_vs_id is ' || p_global_vs_id);

  END IF;

  --loop through all of the contexts associated with the obj_def id
  FOR context_string IN c_get_context(p_obj_def_id) LOOP
    v_func_cd := context_string.function_cd;


    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
	p_severity => FND_LOG.level_statement,
	p_module   => C_MODULE,
	p_msg_text => 'the context code is := '
	|| v_func_cd);
    END IF;


    --check each if it references a disabled member
    IF (v_func_cd = 'MACRO') THEN
      C_CONTEXT := 'MAP_ACCRUAL';
      SELECT dimension_id
      INTO v_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'ACCRUAL_BASIS';

      IF (v_dim_id = p_param_dim_id OR p_param_dim_id is null) THEN
	SELECT member_b_table_name, member_col, value_set_required_flag
	INTO v_member_table, v_member_column, v_value_set_flag
	FROM fem_xdim_dimensions
	WHERE dimension_id = v_dim_id;

	IF (v_value_set_flag = 'Y' AND p_global_vs_id is not null) THEN
	  SELECT value_set_id
	  INTO v_value_set_id
	  FROM fem_global_vs_combo_defs
	  WHERE GLOBAL_VS_COMBO_ID = p_global_vs_id
	  AND dimension_id = v_dim_id;
	  v_val_stmt := 'and value_set_id = ' || v_value_set_id;
	ELSE
	  v_val_stmt := '';
	  v_value_set_id := NULL;
	END IF;

      v_insert_stmt :=
      'INSERT INTO fem_br_disabled_mbrs_gt (object_definition_id,
      dimension_id, dimension_member, value_set_id, context_code)
      SELECT ' || p_obj_def_id || ',' || v_dim_id || ', value, '
      || nvl(to_char(v_value_set_id), 'NULL') || ', ''' || C_CONTEXT ||
      ''' FROM FEM_ALLOC_BR_FORMULA
      WHERE object_definition_id = :obj_def
      AND function_seq = :func_seq
      AND value IN
	(SELECT ' || v_member_column ||
	' FROM ' || v_member_table ||
	' WHERE enabled_flag = ''N'' ' || v_val_stmt || ')';

      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	FEM_ENGINES_PKG.TECH_MESSAGE(
	  p_severity => FND_LOG.level_statement,
	  p_module   => C_MODULE,
	  p_msg_text => 'dynamic SQL statement is := ' || v_insert_stmt);
      END IF;

      EXECUTE IMMEDIATE v_insert_stmt USING p_obj_def_id,
              context_string.function_seq;

      --if a disabled member is found it will be inserted into the table
      IF(SQL%ROWCOUNT > 0) THEN
	x_this_is_valid := 'N';
      END IF;
     END IF;
    ELSE
      --else v_func_cd = credit or debit
      IF (v_func_cd = 'CREDIT') THEN
	C_CONTEXT := 'MAP_CREDIT';
      ELSE
	C_CONTEXT := 'MAP_DEBIT';
      END IF;

      FOR data_row IN c_credit_debit(p_obj_def_id, v_func_cd,
                                                   p_param_dim_id) LOOP
	v_dim_id   := data_row.dimension_id;

	IF (v_dim_id = p_param_dim_id OR p_param_dim_id is null) THEN
	  SELECT member_b_table_name, member_col, value_set_required_flag,
                 member_data_type_code
	  INTO v_member_table, v_member_column, v_value_set_flag, v_datatype
	  FROM fem_xdim_dimensions
	  WHERE dimension_id = v_dim_id;

	  IF (v_value_set_flag = 'Y' AND p_global_vs_id is not null) THEN
	    SELECT value_set_id
	    INTO v_value_set_id
	    FROM fem_global_vs_combo_defs
	    WHERE GLOBAL_VS_COMBO_ID = p_global_vs_id
	    AND dimension_id = v_dim_id;
	    v_val_stmt := 'and value_set_id = ' || v_value_set_id;
	  ELSE
	    v_val_stmt := '';
	    v_value_set_id := NULL;
	  END IF;

          --the v_datatype found in fem_xdim_dimensions decides whether
          --dimension_value or dimension_value_char is used
	  v_insert_stmt :=
          'INSERT INTO fem_br_disabled_mbrs_gt (object_definition_id,
          dimension_id, dimension_member, value_set_id, context_code)
          SELECT ' || p_obj_def_id || ',' || v_dim_id || ', ';

          IF (v_datatype = 'NUMBER') THEN
	    v_insert_stmt := v_insert_stmt || 'dimension_value, ';
          ELSE
	    v_insert_stmt := v_insert_stmt || 'dimension_value_char, ';
          END IF;

          v_insert_stmt := v_insert_stmt
          || nvl(to_char(v_value_set_id), 'NULL') || ', ''' || C_CONTEXT ||
          ''' FROM FEM_ALLOC_BR_DIMENSIONS
          WHERE object_definition_id = :obj_def_id
          AND function_seq = :func_seq
          AND alloc_dim_col_name = :dim_col_name
          AND post_to_balances_flag = :post_to_bal_flag
          AND ';

         IF (v_datatype = 'NUMBER') THEN
	   v_insert_stmt := v_insert_stmt || 'dimension_value ';
         ELSE
	   v_insert_stmt := v_insert_stmt || 'dimension_value_char ';
         END IF;

         v_insert_stmt := v_insert_stmt ||
         'IN (SELECT ' || v_member_column || ' FROM ' ||
         v_member_table || ' WHERE enabled_flag = ''N'' ' || v_val_stmt || ')';

         IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	   FEM_ENGINES_PKG.TECH_MESSAGE(
	     p_severity => FND_LOG.level_statement,
	     p_module   => C_MODULE,
	     p_msg_text => 'dynamic SQL statement is := ' || v_insert_stmt);
         END IF;

         EXECUTE IMMEDIATE v_insert_stmt USING p_obj_def_id,
                context_string.function_seq, data_row.alloc_dim_col_name,
                data_row.post_to_balances_flag;

         --if a disabled member is found it will be inserted into the table
         IF(SQL%ROWCOUNT > 0) THEN
	   x_this_is_valid := 'N';
         END IF;
       END IF;
      END LOOP;
    END IF;
  END LOOP;
  IF (x_this_is_valid is null) THEN
    x_this_is_valid := 'Y';
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure; x_this_is_valid: ' || x_this_is_valid);
  END IF;
--
END Validate_Mapping;
-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Validate_Dim_Component
--
-- DESCRIPTION
--   Validates the Dimension Component asociated with given object definition
--   id. Optionally a value set or dimension id can be provided, which further
--   restricts the scope of the search to asceratin if the rule references and
--   disabled members.
--   If the rule references any disabled members, x_this_is_valid will return
--   'N' and the identifying information for each disabled member found will
--   be logged in the global temporary table fem_br_disabled_mbrs_gt. If it
--   does not reference any disabled members, x_this_is_valid will return 'Y'.
--
-------------------------------------------------------------------------------
PROCEDURE Validate_Dim_Component (
p_obj_def_id    IN  NUMBER,
p_global_vs_id  IN  NUMBER,
p_param_dim_id  IN  NUMBER,
x_this_is_valid OUT NOCOPY VARCHAR2)
-------------------------------------------------------------------------------
IS
--
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_disabled_mbrs_pkg.validate_dim_component';

  v_member_table    FEM_TAB_COLUMNS_B.TABLE_NAME%TYPE;
  v_member_column   FEM_TAB_COLUMNS_B.COLUMN_NAME%TYPE;
  v_column_name     FEM_XDIM_DIMENSIONS.MEMBER_COL%TYPE;
  v_table_name      FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%TYPE;
  v_value_set_id    FEM_GLOBAL_VS_COMBO_DEFS.VALUE_SET_ID%TYPE;
  v_dim_id          FEM_TAB_COLUMNS_B.DIMENSION_ID%TYPE;
  v_criteria_seq	FEM_COND_DIM_CMP_DTL.CRITERIA_SEQUENCE%TYPE;
  v_value_set_flag  VARCHAR2(1);
  v_context_flag    VARCHAR2(1);
  v_val_stmt        VARCHAR2(100);
  v_insert_stmt     VARCHAR2(1000);
  C_CONTEXT         FEM_BR_DISABLED_MBRS_GT.context_code%TYPE;

  --for each object definition id there can be several attributes referenced
  --all need to be checked to see if they reference disabled members.
  cursor c_attr_dim (p_obj_def_id IN NUMBER, p_param_dim_id IN NUMBER) IS
    SELECT a.attribute_dimension_id, d.criteria_sequence
    FROM fem_dim_attributes_b a, fem_cond_dim_components c,
         fem_cond_dim_cmp_dtl d, fem_xdim_dimensions x
    WHERE a.dimension_id = c.dim_id
    AND a.attribute_dimension_id = x.dimension_id
    AND x.hier_editor_managed_flag = 'Y'
    AND a.attribute_varchar_label = d.dim_attr_varchar_label
    AND c.cond_dim_cmp_obj_def_id = d.cond_dim_cmp_obj_def_id
    AND c.cond_dim_cmp_obj_def_id = p_obj_def_id
    AND c.dim_id = nvl(p_param_dim_id, c.dim_id);

BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_obj_def_id is ' || p_obj_def_id);

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_param_dim_id is ' || p_param_dim_id);

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_global_vs_id is ' || p_global_vs_id);

  END IF;

  --get the context, dimension id
  SELECT dim_comp_type, dim_id
  INTO v_context_flag, v_dim_id
  FROM fem_cond_dim_components
  WHERE cond_dim_cmp_obj_def_id = p_obj_def_id;

  --We dont check for hierarchies. If its a hier, return valid.
  IF (v_context_flag = 'H') THEN
    x_this_is_valid := 'Y';
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
	p_severity => FND_LOG.level_statement,
	p_module   => C_MODULE,
	p_msg_text => 'context is hierarchy, x_this_is_valid is returning
			with value of ' || x_this_is_valid);
    END IF;
    RETURN;
  END IF;
  IF (v_context_flag = 'V') THEN
    C_CONTEXT := 'DIM_VALUE';

    IF (v_dim_id = p_param_dim_id OR p_param_dim_id is null) THEN
      SELECT member_b_table_name, member_col, value_set_required_flag
      INTO v_member_table, v_member_column, v_value_set_flag
      FROM fem_xdim_dimensions
      WHERE dimension_id = v_dim_id;

      IF (v_value_set_flag = 'Y' AND p_global_vs_id is not null) THEN
	 SELECT value_set_id
	 INTO v_value_set_id
	 FROM fem_global_vs_combo_defs
	 WHERE GLOBAL_VS_COMBO_ID = p_global_vs_id
	 AND dimension_id = v_dim_id;
	 v_val_stmt := 'and value_set_id = ' || v_value_set_id;
      ELSE
	  v_val_stmt := '';
	  v_value_set_id := NULL;
      END IF;

    ELSE
      x_this_is_valid := 'Y';
      RETURN;
    END IF;
    v_insert_stmt :=
    'INSERT INTO fem_br_disabled_mbrs_gt (object_definition_id,
    dimension_id, dimension_member, value_set_id, context_code)
    SELECT ' || p_obj_def_id || ',' || v_dim_id || ', value, '
    || nvl(to_char(v_value_set_id), 'NULL') || ', ''' || C_CONTEXT ||
    ''' FROM FEM_COND_DIM_COMPONENTS
    WHERE cond_dim_cmp_obj_def_id = :obj_def_id
    AND value IN
      (SELECT to_char(' || v_member_column ||
      ') FROM ' || v_member_table ||
      ' WHERE enabled_flag = ''N'' ' || v_val_stmt || ') ';

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
	p_severity => FND_LOG.level_statement,
	p_module   => C_MODULE,
	p_msg_text => 'dynamic SQL statement for context('
		      || C_CONTEXT || ') is := ' || v_insert_stmt);
    END IF;
    EXECUTE IMMEDIATE v_insert_stmt USING p_obj_def_id;

    --if a disabled member is found it will be inserted into the table
    IF(SQL%ROWCOUNT > 0) THEN
      x_this_is_valid := 'N';
    END IF;


  ELSE
    IF (v_context_flag = 'A') THEN
      C_CONTEXT := 'DIM_ATTR';
      FOR attr_row IN c_attr_dim(p_obj_def_id, p_param_dim_id) LOOP
	v_dim_id   := attr_row.attribute_dimension_id;
	v_criteria_seq := attr_row.criteria_sequence;

	IF (v_dim_id = p_param_dim_id OR p_param_dim_id is null) THEN
	  SELECT member_b_table_name, member_col, value_set_required_flag
	  INTO v_member_table, v_member_column, v_value_set_flag
	  FROM fem_xdim_dimensions
	  WHERE dimension_id = v_dim_id;

	  IF (v_value_set_flag = 'Y' AND p_global_vs_id is not null) THEN
	    SELECT value_set_id
	    INTO v_value_set_id
	    FROM fem_global_vs_combo_defs
	    WHERE GLOBAL_VS_COMBO_ID = p_global_vs_id
	    AND dimension_id = v_dim_id;
	    v_val_stmt := 'and value_set_id = ' || v_value_set_id;
	  ELSE
	    v_val_stmt := '';
	    v_value_set_id := NULL;
	  END IF;

	  v_insert_stmt :=
	  'INSERT INTO fem_br_disabled_mbrs_gt (object_definition_id,
	  dimension_id, dimension_member, value_set_id, context_code)
	  SELECT ' || p_obj_def_id || ',' || v_dim_id ||
		 ', dim_attr_value,' || nvl(to_char(v_value_set_id), 'NULL')                      || ', ''' || C_CONTEXT ||
	  ''' FROM FEM_COND_DIM_CMP_DTL
	  WHERE cond_dim_cmp_obj_def_id = :obj_def_id
	  AND criteria_sequence =  :criteria_seq
	  AND dim_attr_value IN
		   (SELECT to_char(' || v_member_column ||
		   ') FROM ' || v_member_table ||
		   ' WHERE enabled_flag = ''N'' ' || v_val_stmt || ') ';

	  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	    FEM_ENGINES_PKG.TECH_MESSAGE(
	      p_severity => FND_LOG.level_statement,
	      p_module   => C_MODULE,
	      p_msg_text => 'dynamic SQL statement for context('
			  || C_CONTEXT || ') is := ' || v_insert_stmt);
	  END IF;
	END IF;

        IF (v_insert_stmt is not NULL) THEN
	  EXECUTE IMMEDIATE v_insert_stmt USING p_obj_def_id, v_criteria_seq;
        END IF;

        --if a disabled member is found it will be inserted into the table
        IF(SQL%ROWCOUNT > 0) THEN
	  x_this_is_valid := 'N';
        END IF;
      END LOOP;
    END IF;
  END IF;

  IF (x_this_is_valid is null) THEN
    x_this_is_valid := 'Y';
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure; x_this_is_valid: ' || x_this_is_valid);
  END IF;
--
END Validate_Dim_Component;
-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Validate_Data_Component
--
-- DESCRIPTION
--   Validates the Data Component asociated with given object definition
--   id. Optionally a value set or dimension id can be provided, which further
--   restricts the scope of the search to asceratin if the rule references and
--   disabled members.
--   If the rule references any disabled members, x_this_is_valid will return
--   'N' and the identifying information for each disabled member found will
--   be logged in the global temporary table fem_br_disabled_mbrs_gt. If it
--   does not reference any disabled members, x_this_is_valid will return 'Y'.
--
-------------------------------------------------------------------------------
PROCEDURE Validate_Data_Component (
p_obj_def_id    IN  NUMBER,
p_global_vs_id  IN  NUMBER,
p_param_dim_id  IN  NUMBER,
x_this_is_valid OUT NOCOPY VARCHAR2)
-------------------------------------------------------------------------------
IS
--
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_disabled_mbrs_pkg.validate_data_component';

  v_member_table    FEM_TAB_COLUMNS_B.TABLE_NAME%TYPE;
  v_member_column   FEM_TAB_COLUMNS_B.COLUMN_NAME%TYPE;
  v_column_name     FEM_XDIM_DIMENSIONS.MEMBER_COL%TYPE;
  v_table_name      FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%TYPE;
  v_sequence        FEM_COND_DATA_CMP_STEPS.STEP_SEQUENCE%TYPE;
  v_criteria_seq	FEM_COND_DATA_CMP_ST_DTL.CRITERIA_SEQUENCE%TYPE;
  v_value_set_id    FEM_GLOBAL_VS_COMBO_DEFS.VALUE_SET_ID%TYPE;
  v_dim_id          FEM_TAB_COLUMNS_B.DIMENSION_ID%TYPE;
  v_value_set_flag  VARCHAR2(1);
  v_val_stmt        VARCHAR2(100);
  v_insert_stmt     VARCHAR2(1000);
  C_CONTEXT         CONSTANT FEM_BR_DISABLED_MBRS_GT.context_code%TYPE
			      := 'DATA_VALUE';

  --there can be multiple column/table/dimension combinations for each
  --object definition id.  This ensures that each is checked for
  --disabled members.
  --  Note: hier_editor_managed_flag denotes if a dimension is managed by DHM
  cursor c_objdef (p_obj_def_id IN NUMBER, p_param_dim_id IN NUMBER) IS
    SELECT A.column_name, A.table_name, A.step_sequence, B.dimension_id,
	   D.criteria_sequence
    FROM fem_cond_data_cmp_steps A, fem_tab_columns_b B,
	 fem_cond_data_cmp_st_dtl D, fem_xdim_dimensions X
    WHERE A.column_name = B.column_name
    AND A.table_name = B.table_name
    AND A.cond_data_cmp_obj_def_id = p_obj_def_id
    AND B.dimension_id = X.dimension_id
    AND X.hier_editor_managed_flag = 'Y'
    AND D.cond_data_cmp_obj_def_id = p_obj_def_id
    AND B.dimension_id = nvl(p_param_dim_id, B.dimension_id);

BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_obj_def_id is ' || p_obj_def_id);

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_param_dim_id is ' || p_param_dim_id);

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_global_vs_id is ' || p_global_vs_id);
  END IF;

  --check each if it references a disabled member
  FOR data_row IN c_objdef(p_obj_def_id, p_param_dim_id) LOOP
    v_column_name := data_row.column_name;
    v_table_name := data_row.table_name;
    v_sequence := data_row.step_sequence;
    v_dim_id   := data_row.dimension_id;
    v_criteria_seq := data_row.criteria_sequence;

    IF (v_dim_id = p_param_dim_id OR p_param_dim_id is null) THEN
      SELECT member_b_table_name, member_col, value_set_required_flag
      INTO v_member_table, v_member_column, v_value_set_flag
      FROM fem_xdim_dimensions
      WHERE dimension_id = v_dim_id;

      IF (v_value_set_flag = 'Y' AND p_global_vs_id is not null) THEN
        SELECT value_set_id
	INTO v_value_set_id
	FROM fem_global_vs_combo_defs
        WHERE GLOBAL_VS_COMBO_ID = p_global_vs_id
        AND dimension_id = v_dim_id;
        v_val_stmt := 'and value_set_id = ' || v_value_set_id;
      ELSE
	v_val_stmt := '';
        v_value_set_id := NULL;
      END IF;

      v_insert_stmt :=
      'INSERT INTO fem_br_disabled_mbrs_gt (object_definition_id,
      dimension_id, dimension_member, value_set_id, context_code)
      SELECT ' || p_obj_def_id || ',' || v_dim_id || ', value, '
      || nvl(to_char(v_value_set_id), 'NULL') || ', ''' || C_CONTEXT ||
      ''' FROM FEM_COND_DATA_CMP_ST_DTL
      WHERE step_sequence = :seq
      AND   table_name = :tab_name
      AND   criteria_sequence = :c_seq
      AND   cond_data_cmp_obj_def_id = :obj_def_id
      AND   value IN
	     (SELECT to_char(' || v_member_column ||
	     ') FROM ' || v_member_table ||
	     ' WHERE enabled_flag = ''N'' ' || v_val_stmt || ') ';

      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
	  p_severity => FND_LOG.level_statement,
	  p_module   => C_MODULE,
	  p_msg_text => 'dynamic SQL statement is := ' || v_insert_stmt);
      END IF;

      EXECUTE IMMEDIATE v_insert_stmt USING v_sequence,v_table_name,
	    v_criteria_seq, p_obj_def_id;

      --if a disabled member is found it will be inserted into the table
      IF(SQL%ROWCOUNT > 0) THEN
        x_this_is_valid := 'N';
      END IF;
    END IF;
  END LOOP;
  IF (x_this_is_valid is null) THEN
    x_this_is_valid := 'Y';
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
    p_severity => FND_LOG.level_procedure,
    p_module   => C_MODULE,
    p_msg_text => 'End Procedure; x_this_is_valid: ' || x_this_is_valid);
  END IF;
--
END Validate_Data_Component;
-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Validate_Statistic
--
-- DESCRIPTION
--   Validates the Statistic Rule asociated with given object definition id.
--   Optionally a value set or dimension id can be provided, which further
--   restricts the scope of the search to asceratin if the rule references and
--   disabled members.
--   If the rule references any disabled members, x_this_is_valid will return
--   'N' and the identifying information for each disabled member found will
--   be logged in the global temporary table fem_br_disabled_mbrs_gt. If it
--   does not reference any disabled members, x_this_is_valid will return 'Y'.
--
-------------------------------------------------------------------------------
PROCEDURE Validate_Statistic (
p_obj_def_id    IN  NUMBER,
p_global_vs_id  IN  NUMBER,
p_param_dim_id  IN  NUMBER,
x_this_is_valid OUT NOCOPY VARCHAR2)
-------------------------------------------------------------------------------
IS
--
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_disabled_mbrs_pkg.validate_statistic';

  v_member_table    FEM_TAB_COLUMNS_B.TABLE_NAME%TYPE;
  v_member_column   FEM_TAB_COLUMNS_B.COLUMN_NAME%TYPE;
  v_column_name     FEM_XDIM_DIMENSIONS.MEMBER_COL%TYPE;
  v_table_name      FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%TYPE;
  v_value_set_id    FEM_GLOBAL_VS_COMBO_DEFS.VALUE_SET_ID%TYPE;
  v_dim_id          FEM_TAB_COLUMNS_B.DIMENSION_ID%TYPE;
  v_value_set_flag  VARCHAR2(1);
  v_val_stmt        VARCHAR2(100);
  v_insert_stmt     VARCHAR2(1000);
  C_CONTEXT         CONSTANT FEM_BR_DISABLED_MBRS_GT.context_code%TYPE
			      := 'STATS_VALUE';

  --there can be multiple column/table/dimension combinations for each
  --object definition id.  This ensures that each is checked for
  --disabled members.
  cursor c_objdef (p_obj_def_id IN NUMBER, p_param_dim_id IN NUMBER) IS
    SELECT C.column_name, C.table_name, C.dimension_id
    FROM fem_stat_lookups A, fem_stat_lookup_rel B, fem_tab_columns_b C,
         fem_xdim_dimensions X
    WHERE A.stat_lookup_obj_def_id = p_obj_def_id
    AND A.stat_lookup_obj_def_id = B.stat_lookup_obj_def_id
    AND A.stat_lookup_table = C.table_name
    AND B.stat_lookup_tbl_col = C.column_name
    AND C.dimension_id = X.dimension_id
    AND X.hier_editor_managed_flag = 'Y'
    AND C.dimension_id = nvl(p_param_dim_id, C.dimension_id);

BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_obj_def_id is ' || p_obj_def_id);

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_param_dim_id is ' || p_param_dim_id);

   FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_global_vs_id is ' || p_global_vs_id);

  END IF;

  --check each if it references a disabled member
  FOR data_row IN c_objdef(p_obj_def_id, p_param_dim_id) LOOP
    v_column_name := data_row.column_name;
    v_table_name := data_row.table_name;
    v_dim_id   := data_row.dimension_id;

    IF (v_dim_id = p_param_dim_id OR p_param_dim_id is null) THEN
      SELECT member_b_table_name, member_col, value_set_required_flag
      INTO v_member_table, v_member_column, v_value_set_flag
      FROM fem_xdim_dimensions
      WHERE dimension_id = v_dim_id;

      IF (v_value_set_flag = 'Y' AND p_global_vs_id is not null) THEN
        SELECT value_set_id
        INTO v_value_set_id
        FROM fem_global_vs_combo_defs
        WHERE GLOBAL_VS_COMBO_ID = p_global_vs_id
        AND dimension_id = v_dim_id;
        v_val_stmt := 'and value_set_id = ' || v_value_set_id;
      ELSE
        v_val_stmt := '';
        v_value_set_id := NULL;
      END IF;


      v_insert_stmt :=
      'INSERT INTO fem_br_disabled_mbrs_gt (object_definition_id,
      dimension_id, dimension_member, value_set_id, context_code)
      SELECT ' || p_obj_def_id || ',' || v_dim_id || ', value, '
      || nvl(to_char(v_value_set_id), 'NULL') || ', ''' || C_CONTEXT ||
      ''' FROM FEM_STAT_LOOKUP_REL
      WHERE stat_lookup_obj_def_id = :obj_def_id
      AND stat_lookup_tbl_col = :column_name
      AND value IN
             (SELECT to_char(' || v_member_column ||
             ') FROM ' || v_member_table ||
             ' WHERE enabled_flag = ''N'' ' || v_val_stmt || ') ';

      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
	  p_severity => FND_LOG.level_statement,
	  p_module   => C_MODULE,
	  p_msg_text => 'dynamic SQL statement is := ' || v_insert_stmt);
      END IF;

      EXECUTE IMMEDIATE v_insert_stmt USING p_obj_def_id, v_column_name;

      --if a disabled member is found it will be inserted into the table
      IF(SQL%ROWCOUNT > 0) THEN
        x_this_is_valid := 'N';
      END IF;
    END IF;
  END LOOP;
  IF (x_this_is_valid is null) THEN
    x_this_is_valid := 'Y';
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure; x_this_is_valid: ' || x_this_is_valid);
  END IF;
--
END Validate_Statistic;
-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Validate_Hierarchy
--
-- DESCRIPTION
--   Validates the Hierarchy asociated with given object definition id.
--   Optionally a value set or dimension id can be provided, which further
--   restricts the scope of the search to asceratin if the rule references and
--   disabled members.
--   If the rule references any disabled members, x_this_is_valid will return
--   'N' and the identifying information for each disabled member found will
--   be logged in the global temporary table fem_br_disabled_mbrs_gt. If it
--   does not reference any disabled members, x_this_is_valid will return 'Y'.
--
-------------------------------------------------------------------------------
PROCEDURE Validate_Hierarchy (
p_obj_def_id    IN  NUMBER,
p_global_vs_id  IN  NUMBER,
p_param_dim_id  IN  NUMBER,
x_this_is_valid OUT NOCOPY VARCHAR2)
-------------------------------------------------------------------------------
IS
--
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_disabled_mbrs_pkg.validate_hierarchy';

  v_member_table      FEM_TAB_COLUMNS_B.TABLE_NAME%TYPE;
  v_member_column     FEM_TAB_COLUMNS_B.COLUMN_NAME%TYPE;
  v_value_set_id      FEM_GLOBAL_VS_COMBO_DEFS.VALUE_SET_ID%TYPE;
  v_dim_id            FEM_TAB_COLUMNS_B.DIMENSION_ID%TYPE;
  v_hier_table_name   FEM_XDIM_DIMENSIONS.HIERARCHY_TABLE_NAME%TYPE;
  v_hier_flattened    FEM_HIER_DEFINITIONS.
			  FLATTENED_ROWS_COMPLETION_CODE%TYPE;
  v_hier_obj_id       FEM_HIERARCHIES.HIERARCHY_OBJ_ID%TYPE;
  v_hier_obj_name     FEM_OBJECT_CATALOG_VL.OBJECT_NAME%TYPE;
  v_hier_obj_def_name FEM_OBJECT_DEFINITION_VL.DISPLAY_NAME%TYPE;
  v_mbr_disp_cd_col   FEM_XDIM_DIMENSIONS.MEMBER_DISPLAY_CODE_COL%TYPE;
  v_value_set_name    FEM_VALUE_SETS_VL.VALUE_SET_NAME%TYPE;
  v_parent_disp_cd    FEM_XDIM_DIMENSIONS.MEMBER_DISPLAY_CODE_COL%TYPE;
  v_parent_name       FEM_OBJECT_CATALOG_VL.OBJECT_NAME%TYPE;
  v_child_disp_cd     FEM_XDIM_DIMENSIONS.MEMBER_DISPLAY_CODE_COL%TYPE;
  v_child_name        FEM_OBJECT_CATALOG_VL.OBJECT_NAME%TYPE;
  v_mbr_vl_tab_name   FEM_XDIM_DIMENSIONS.MEMBER_VL_OBJECT_NAME%TYPE;
  v_member_name_col   FEM_XDIM_DIMENSIONS.MEMBER_NAME_COL%TYPE;
  v_value_set_flag    VARCHAR2(1);
  v_flat_flag         VARCHAR2(1);
  v_insert_stmt       VARCHAR2(18000);
  C_CONTEXT           FEM_BR_DISABLED_MBRS_GT.context_code%TYPE;


BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_obj_def_id is ' || p_obj_def_id);

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_param_dim_id is ' || p_param_dim_id);

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'p_global_vs_id is ' || p_global_vs_id);
  END IF;

  --get dimension id and information for fem_br_dis_mbr_hier table
  SELECT h.dimension_id, h.hierarchy_obj_id, a.object_name, od.display_name,
         h.flattened_rows_flag
  INTO v_dim_id, v_hier_obj_id, v_hier_obj_name, v_hier_obj_def_name,
       v_flat_flag
  FROM fem_hier_definitions d, fem_object_definition_b o,
       fem_object_definition_vl od,
       fem_object_catalog_b c, fem_hierarchies h, fem_object_catalog_vl a
  WHERE d.hierarchy_obj_def_id = p_obj_def_id
  AND d.hierarchy_obj_def_id = o.object_definition_id
  AND o.object_definition_id = od.object_definition_id
  AND o.object_id = c.object_id
  AND c.object_id = h.hierarchy_obj_id
  AND a.object_id = c.object_id;

  --get the member table and columns
  IF (v_dim_id = p_param_dim_id OR p_param_dim_id is null) THEN
    SELECT member_b_table_name, member_col, value_set_required_flag,
    hierarchy_table_name, member_display_code_col, member_vl_object_name,
    member_name_col
    INTO v_member_table, v_member_column, v_value_set_flag,
    v_hier_table_name, v_mbr_disp_cd_col, v_mbr_vl_tab_name,
    v_member_name_col
    FROM fem_xdim_dimensions
    WHERE dimension_id = v_dim_id;

    IF (v_value_set_flag = 'Y' AND p_global_vs_id is not null) THEN
      SELECT d.value_set_id, s.value_set_name
      INTO v_value_set_id, v_value_set_name
      FROM fem_global_vs_combo_defs d, fem_value_sets_vl s
      WHERE d.GLOBAL_VS_COMBO_ID = p_global_vs_id
      AND d.dimension_id = v_dim_id
      AND d.value_set_id = s.value_set_id;
    ELSE
      v_value_set_name := NULL;
      v_value_set_id := NULL;
    END IF;

  ELSE
    x_this_is_valid := 'Y';
    RETURN;
  END IF;

  SELECT flattened_rows_completion_code
  INTO v_hier_flattened
  FROM fem_hier_definitions
  WHERE hierarchy_obj_def_id = p_obj_def_id;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'v_hier_flattened is := ' || v_hier_flattened);
  END IF;

  --whether or not the hier is flattened doesnt effect the first part of
  --the dynamic insert stmt.
  v_insert_stmt := 'INSERT INTO fem_br_dis_mbr_hier
  (request_id, hierarchy_object_id, hierarchy_object_name,
  hierarchy_obj_def_name, creation_date, created_by, last_updated_by,
  last_update_date, last_update_login, parent_value_set_name,
  child_value_set_name, parent_value_set_id, child_value_set_id,
  disabled_flag, hierarchy_obj_def_id, parent_member_id, child_member_id,
  parent_display_code, child_display_code, parent_name, child_name)
  SELECT FND_GLOBAL.conc_request_id, ' || v_hier_obj_id || ', ''' ||
  v_hier_obj_name || ''', ''' || v_hier_obj_def_name
  || ''', SYSDATE, FND_GLOBAL.user_id, FND_GLOBAL.user_id, SYSDATE,
  FND_GLOBAL.login_id, ''' || v_value_set_name || ''', ''' ||
  v_value_set_name || ''',' || nvl(to_char(v_value_set_id), 'NULL')
  || ',' || nvl(to_char(v_value_set_id), 'NULL') || ',';

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'dynamic SQL statement is := ' || v_insert_stmt);
  END IF;

  IF (v_hier_flattened = 'COMPLETED' AND v_flat_flag = 'Y') THEN
    --flattened
    v_insert_stmt := v_insert_stmt ||
	' ''N'', h.hierarchy_obj_def_id, h.parent_id, h.child_id, p.'
	|| v_mbr_disp_cd_col || ', c.' || v_mbr_disp_cd_col || ', p.'
	|| v_member_name_col || ', c.' || v_member_name_col ||
	' FROM ' || v_hier_table_name || ' h, ' || v_mbr_vl_tab_name
	|| ' p, ' || v_mbr_vl_tab_name || ' c' ||
	' WHERE h.hierarchy_obj_def_id = :obj_def_id' ||
	' AND parent_id = p.' || v_member_column ||
	' AND child_id = c.' || v_member_column ||
	' AND h.single_depth_flag = ''Y''
	AND h.child_id IN
	  (SELECT parent_id
	  FROM ' || v_hier_table_name ||
	  ' WHERE hierarchy_obj_def_id = :obj_def_id' ||
	  ' AND child_id IN
		    (SELECT ' || v_member_column ||
		     ' FROM ' || v_member_table ||
		     ' WHERE enabled_flag = ''N'')
          UNION ALL
          SELECT child_id
          FROM  ' || v_hier_table_name ||
	  ' WHERE hierarchy_obj_def_id = :obj_def_id' ||
	  ' AND child_id IN
		    (SELECT ' || v_member_column ||
		     ' FROM ' || v_member_table ||
		     ' WHERE enabled_flag = ''N''))';


    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
	p_severity => FND_LOG.level_statement,
	p_module   => C_MODULE,
	p_msg_text => 'flattened insert dynamic SQL statement is := '
		      || v_insert_stmt);
    END IF;

    EXECUTE IMMEDIATE v_insert_stmt USING p_obj_def_id, p_obj_def_id,
                                          p_obj_def_id;

    --need to set valid here because the update that follows will
    --wipe out rowcount
    --if any rows have been inserted, then it is invalid
    IF (SQL%ROWCOUNT > 0) THEN
      x_this_is_valid := 'N';
    ELSE
      x_this_is_valid := 'Y';
    END IF;

    --for all the members that have been inserted, those that are invalid
    --need to be marked.
    --the other members are used to show the path from root to disabled
    --member
    v_insert_stmt :=
    'UPDATE fem_br_dis_mbr_hier
    SET disabled_flag = ''Y''
    WHERE hierarchy_obj_def_id = :obj_def_id' ||
    ' AND child_member_id IN
      (SELECT ' || v_member_column ||
      ' FROM ' || v_member_table ||
      ' WHERE enabled_flag = ''N'')';

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
	p_severity => FND_LOG.level_statement,
	p_module   => C_MODULE,
	p_msg_text => 'update dynamic SQL statement is := ' || v_insert_stmt);
    END IF;

    EXECUTE IMMEDIATE v_insert_stmt USING p_obj_def_id;
  ELSE
    --the hierarchy is NOT flattened
    v_insert_stmt := v_insert_stmt ||
	    ' ''Y'', h.hierarchy_obj_def_id, h.parent_id, h.child_id, p.'
	    || v_mbr_disp_cd_col || ', c.' || v_mbr_disp_cd_col || ', p.'
	    || v_member_name_col || ', c.' || v_member_name_col ||
	    ' FROM ' || v_hier_table_name || ' h, ' || v_mbr_vl_tab_name
	    || ' p, ' || v_mbr_vl_tab_name || ' c' ||
	    ' WHERE h.hierarchy_obj_def_id = :obj_def_id' ||
	    ' AND parent_id = p.' || v_member_column ||
	    ' AND child_id = c.' || v_member_column ||
	    ' AND h.child_id IN
		(SELECT ' || v_member_column ||
		' FROM ' || v_member_table ||
		' WHERE enabled_flag = ''N'')';


    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
	p_severity => FND_LOG.level_statement,
	p_module   => C_MODULE,
	p_msg_text => 'unflattened insert dynamic SQL statement is := '
		      || v_insert_stmt);
    END IF;
    EXECUTE IMMEDIATE v_insert_stmt USING p_obj_def_id;

    --need to set valid here because the update in the unflattened case
    --wipes out rowcount
    --if any rows have been inserted, then it is invalid
    IF (SQL%ROWCOUNT > 0) THEN
      x_this_is_valid := 'N';
    ELSE
      x_this_is_valid := 'Y';
    END IF;
  END IF;

  --if there are disabled members, insert them in the dis_mbrs_gt
  IF (x_this_is_valid = 'N') THEN
      v_insert_stmt :=
      'INSERT INTO fem_br_disabled_mbrs_gt
		   (object_definition_id, context_code)
      VALUES (' || to_char(p_obj_def_id) || ', ''HIERARCHY'')';

      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
	FEM_ENGINES_PKG.TECH_MESSAGE(
	  p_severity => FND_LOG.level_statement,
	  p_module   => C_MODULE,
	  p_msg_text => 'dis mbrs insert dynamic SQL statement is := '
			|| v_insert_stmt);
      END IF;

      EXECUTE IMMEDIATE v_insert_stmt;
  END IF;


  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure; x_this_is_valid: ' || x_this_is_valid);
    END IF;
--
END Validate_Hierarchy;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Validate_Factor_Table
--
-- DESCRIPTION
--   Validates the Factor Table asociated with given object definition id.
--   Optionally a value set or dimension id can be provided, which further
--   restricts the scope of the search to asceratin if the rule references and
--   disabled members.
--   If the rule references any disabled members, x_this_is_valid will return
--   'N' and the identifying information for each disabled member found will
--   be logged in the global temporary table fem_br_disabled_mbrs_gt. If it
--   does not reference any disabled members, x_this_is_valid will return 'Y'.
--
-------------------------------------------------------------------------------
PROCEDURE Validate_Factor_Table (
p_obj_def_id    IN  NUMBER,
p_global_vs_id  IN  NUMBER,
p_param_dim_id  IN  NUMBER,
x_this_is_valid OUT NOCOPY VARCHAR2)
-------------------------------------------------------------------------------
IS
--
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_disabled_mbrs_pkg.validate_factor_table';

  v_member_table    FEM_TAB_COLUMNS_B.TABLE_NAME%TYPE;
  v_member_column   FEM_TAB_COLUMNS_B.COLUMN_NAME%TYPE;
  v_value_set_id    FEM_GLOBAL_VS_COMBO_DEFS.VALUE_SET_ID%TYPE;
  v_value_set_flag  VARCHAR2(1);
  v_val_stmt        VARCHAR2(100);
  v_insert_stmt     VARCHAR2(1000);
  C_CONTEXT         CONSTANT FEM_BR_DISABLED_MBRS_GT.context_code%TYPE
                    := 'DIM_VALUE';

  -- Dimensions referenced by a Factor Table rule.
  CURSOR c_dims (p_obj_def_id IN NUMBER, p_param_dim_id IN NUMBER) IS
    SELECT DISTINCT dimension_id
    FROM fem_factor_table_dims
    WHERE object_definition_id = p_obj_def_id
    AND dimension_id = nvl(p_param_dim_id, dimension_id);

BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module  => C_MODULE,
      p_msg_text => 'Begin Procedure');

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module  => C_MODULE,
      p_msg_text => 'p_obj_def_id is ' || p_obj_def_id);

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module  => C_MODULE,
      p_msg_text => 'p_param_dim_id is ' || p_param_dim_id);

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module  => C_MODULE,
      p_msg_text => 'p_global_vs_id is ' || p_global_vs_id);
  END IF;

  -- For each dimension, check if disabled members are referenced
  FOR dim IN c_dims(p_obj_def_id, p_param_dim_id) LOOP

    SELECT member_b_table_name, member_col, value_set_required_flag
    INTO v_member_table, v_member_column, v_value_set_flag
    FROM fem_xdim_dimensions
    WHERE dimension_id = dim.dimension_id;

    IF (v_value_set_flag = 'Y' AND p_global_vs_id is not null) THEN
      SELECT value_set_id
      INTO v_value_set_id
      FROM fem_global_vs_combo_defs
      WHERE GLOBAL_VS_COMBO_ID = p_global_vs_id
      AND dimension_id = dim.dimension_id;

      v_val_stmt := 'and value_set_id = ' || v_value_set_id;
    ELSE
      v_val_stmt := '';
      v_value_set_id := NULL;
    END IF;

    v_insert_stmt :=
        'INSERT INTO fem_br_disabled_mbrs_gt(object_definition_id,'
     || ' dimension_id, dimension_member, value_set_id, context_code)'
     ||' SELECT D.object_definition_id, D.dimension_id, F.dim_member, '
     ||  nvl(to_char(v_value_set_id), 'NULL') || ', ''' || C_CONTEXT ||''''
     ||' FROM fem_factor_table_dims D, fem_factor_table_fctrs F'
     ||' WHERE D.object_definition_id = :obj_def_id'
     ||' AND D.dimension_id = :dim_id'
     ||' AND D.object_definition_id = F.object_definition_id'
     ||' AND D.level_num = F.level_num'
     ||' AND F.dim_member IN '
     || ' (SELECT to_char(' || v_member_column || ')'
     ||  ' FROM ' || v_member_table
     ||  ' WHERE enabled_flag = ''N'' ' || v_val_stmt || ')';

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module  => C_MODULE,
        p_msg_text => 'dynamic SQL statement is := ' || v_insert_stmt);
    END IF;

    EXECUTE IMMEDIATE v_insert_stmt USING p_obj_def_id, dim.dimension_id;

    --if a disabled member is found it will be inserted into the table
    IF(SQL%ROWCOUNT > 0) THEN
      x_this_is_valid := 'N';
    END IF;

  END LOOP;

  IF (x_this_is_valid IS NULL) THEN
   x_this_is_valid := 'Y';
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
   FEM_ENGINES_PKG.TECH_MESSAGE(
    p_severity => FND_LOG.level_procedure,
    p_module  => C_MODULE,
    p_msg_text => 'End Procedure; x_this_is_valid: ' || x_this_is_valid);
  END IF;
--
END Validate_Factor_Table;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--  Get_Put_Messages
--
-- DESCRIPTION
--  Checks the FND Message stack and posts any messages from the stack
--  into the concurrent program log.
--
-------------------------------------------------------------------------------
PROCEDURE Get_Put_Messages
-------------------------------------------------------------------------------
IS
--
  C_MODULE    CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_dis_mbr_pkg.get_put_messages';
  v_msg_count   NUMBER;
  v_msg_data    VARCHAR2(4000);
  v_msg_out     NUMBER;
  v_message     VARCHAR2(4000);
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                            p_count   => v_msg_count,
                            p_data    => v_msg_data);

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'Message count is '||to_char(v_msg_count));
  END IF;

  -- If there is only one message, it would be returned in v_msg_data
  -- so just decode and output it.
  -- Otherwise, loop through the message stack to get each message.
  IF (v_msg_count = 1) THEN
    FND_MESSAGE.Set_Encoded(v_msg_data);
    v_message := FND_MESSAGE.Get;

    FEM_ENGINES_PKG.User_Message(p_msg_text => v_message);

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Message is '||v_message);
    END IF;

  ELSIF (v_msg_count > 1) THEN
    FOR i IN 1..v_msg_count LOOP
      FND_MSG_PUB.Get(
        p_msg_index     => i,
        p_encoded       => FND_API.G_FALSE,
        p_data          => v_message,
        p_msg_index_out => v_msg_out);

      FEM_ENGINES_PKG.User_Message(p_msg_text => v_message);

      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'Message is '||v_message);
      END IF;
    END LOOP;
  END IF;  -- IF (v_msg_count = 1)

  FND_MSG_PUB.Initialize;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END Get_Put_Messages;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--  Populate_Dim_Info
--
-- DESCRIPTION
--  Populates the following columns in FEM_BR_DIS_MBR_CONTEXTS:
--    DIMENSION_MEMBER_DC, DIMENSION_MEMBER_NAME
--
-------------------------------------------------------------------------------
PROCEDURE Populate_Dim_Info
-------------------------------------------------------------------------------
IS
--
  C_MODULE    CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_dis_mbr_pkg.populate_dim_info';
--
  v_sql     VARCHAR2(18000);
--
  CURSOR c_dims(p_request_id NUMBER) IS
    SELECT dimension_id, member_data_type_code, member_vl_object_name,
           member_col, member_display_code_col, member_name_col,
           value_set_required_flag
    FROM fem_xdim_dimensions
    WHERE dimension_id IN (
      SELECT dimension_id
      FROM fem_br_dis_mbr_contexts
      WHERE request_id = p_request_id);
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Populate the dimension_member_dc, dimension_member_name columns
  -- in FEM_BR_DIS_MBR_CONTEXTS, one dimension at a time.
  -- The assumption here is that only those where where DIMENSION_ID column
  -- IS NOT NULL would there be a need to populate the dimension names.
  FOR dims IN c_dims(FND_GLOBAL.Conc_Request_ID) LOOP
    v_sql := 'UPDATE fem_br_dis_mbr_contexts c'
          ||' SET (dimension_member_dc, dimension_member_name) = ('
          ||   'SELECT '||dims.member_display_code_col
          ||         ','||dims.member_name_col
          ||  ' FROM '||dims.member_vl_object_name||' d';

    IF (dims.member_data_type_code = 'VARCHAR') THEN
      v_sql := v_sql||' WHERE d.'||dims.member_col||' = c.dimension_member';
    ELSE
      v_sql := v_sql||' WHERE to_char(d.'||dims.member_col
                    ||') = c.dimension_member';
    END IF;

    IF (dims.value_set_required_flag = 'Y') THEN
      v_sql := v_sql||' AND d.value_set_id = c.value_set_id';
    END IF;

    v_sql := v_sql||')'
          ||' WHERE dimension_id = :dim_id'
          ||' AND request_id = :req_id';

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'v_sql = '||v_sql);
    END IF;

    EXECUTE IMMEDIATE v_sql
      USING dims.dimension_id, FND_GLOBAL.Conc_Request_ID;

  END LOOP;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
END Populate_Dim_Info;
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- PUBLIC BODIES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- FUNCTION
--   Get_Unique_Report_Row
--
-- DESCRIPTION
--   The function simply returns a unique report row identifier,
--   using a private package variable as a counter.
--
-------------------------------------------------------------------------------
FUNCTION Get_Unique_Report_Row RETURN NUMBER
-------------------------------------------------------------------------------
IS
--
  C_MODULE    CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_dis_mbr_pkg.get_unique_report_row';
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
  FEM_ENGINES_PKG.TECH_MESSAGE(
    p_severity => FND_LOG.level_procedure,
    p_module   => C_MODULE,
    p_msg_text => 'Begin Procedure');
  END IF;
--
  IF (pv_report_row_counter IS NULL) THEN
    pv_report_row_counter := 1;
  ELSE
    pv_report_row_counter := pv_report_row_counter + 1;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'pv_report_row_counter = '||pv_report_row_counter);
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

  RETURN pv_report_row_counter;
--
END Get_Unique_Report_Row;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--
-- PROCEDURE
--   Report_Invalid_Rules
--
-- DESCRIPTION
--   This is the entrance to the reporting program and is invoked
--   by the concurrent manager for the executable FEM_CHECK_BRDIS_MBRS.
--   It will make calls to other procedures in the
--   FEM_CHECK_BR_DIS_MBRS_PKG to check the root rules
--   for Disabled Members and report on the results.
--
-------------------------------------------------------------------------------
PROCEDURE Report_Invalid_Rules (
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  p_rule_type       IN  VARCHAR2,
  p_ledger_id       IN  NUMBER,
  p_effective_date  IN  VARCHAR2,
  p_folder_id       IN  NUMBER,
  p_object_id       IN  NUMBER,
  p_dim_id          IN  NUMBER,
  p_request_name    IN  VARCHAR2)
-------------------------------------------------------------------------------
IS
--
  C_MODULE      CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_br_dis_mbrs_pkg.report_invalid_rules';
--
  l_effective_date       DATE;
  v_return_status        VARCHAR2(1);
  v_msg_count            NUMBER;
  v_msg_data             VARCHAR2(4000);
  v_global_vs_id         NUMBER;
  v_num_root_rules       NUMBER;
  v_num_rules_invalid    NUMBER;
  v_all_rules_are_valid  VARCHAR2(1);
  v_request_name         FEM_BR_DIS_MBR_REQUESTS.request_name%TYPE;
  v_request_date         DATE;
--
  -- Get all root rules to be checked for disabled members
  CURSOR c_root_rules IS
  SELECT object_definition_id
  FROM fem_br_root_rules_gt;
--
BEGIN
--
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Log procedure param values
  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_rule_type = '||p_rule_type);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_ledger_id = '||p_ledger_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_effective_date = '||p_effective_date);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_folder_id = '||p_folder_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_object_id = '||p_object_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_dim_id = '||p_dim_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_request_name = '||p_request_name);
  END IF; -- IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL

  -- Convert effective date from VARCHAR2 to DATE
  l_effective_date := FND_DATE.Canonical_To_Date(p_effective_date);

  -- Get GVSC for ledger
  v_global_vs_id := FEM_DIMENSION_UTIL_PKG.Global_VS_Combo_ID(
                      p_api_version    => 1.0,
                      x_return_status  => v_return_status,
                      x_msg_count      => v_msg_count,
                      x_msg_data       => v_msg_data,
                      p_ledger_id      => p_ledger_id);

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'v_global_vs_id = '||v_global_vs_id);
  END IF;

  IF v_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'INTERNAL ERROR: Call to'
                    ||' FEM_DIMENSION_UTIL_PKG.Global_VS_Combo_ID'
                    ||' failed with return status: '||v_return_status);
    END IF;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Find the set of root rules that needs to be checked for
  -- disabled dimension members and place them in FEM_BR_ROOT_RULES_GT.
  Find_Root_Rules(p_rule_type       => p_rule_type,
                  p_ledger_id       => p_ledger_id,
                  p_effective_date  => l_effective_date,
                  p_folder_id       => p_folder_id,
                  p_object_id       => p_object_id,
                  p_global_vs_id    => v_global_vs_id);

  -- Initialize vars
  v_num_rules_invalid := 0;

  -- Loop through each root rule and validate it.
  FOR root_rules IN c_root_rules LOOP
    Validate_Root_Rule(
      p_obj_def_id            => root_rules.object_definition_id,
      p_parent_report_row_id  => NULL,
      p_effective_date        => l_effective_date,
      p_global_vs_id          => v_global_vs_id,
      p_param_dim_id          => p_dim_id,
      x_all_rules_are_valid   => v_all_rules_are_valid);

    -- If any of the root root rules are invalid, record that fact.
    IF v_all_rules_are_valid = 'N' THEN
      v_num_rules_invalid := v_num_rules_invalid + 1;
    END IF;

    v_num_root_rules := c_root_rules%ROWCOUNT;
  END LOOP;

  -- If at least one root rule was invalid,
  -- 1. Finish populating denormalized dimension information in
  --    FEM_BR_DIS_MBR_CONTEXTS
  -- 2. Populate FEM_BR_DIS_MBR_REQUESTS
  IF (v_num_rules_invalid > 0) THEN
    -- First, populate missing dimension info in FEM_BR_DIS_MBR_CONTEXTS
    Populate_Dim_Info;

    -- Put request date into var for consistency
    v_request_date := sysdate;

    IF p_request_name IS NULL THEN
      v_request_name := FND_GLOBAL.User_Name || ' '
                     || FND_DATE.Date_To_DisplayDT(v_request_date);
    ELSE
      v_request_name := p_request_name;
    END IF;

    INSERT INTO fem_br_dis_mbr_requests(
      request_id, request_date, request_name,
      object_type_code, object_type_name,
      ledger_id, ledger_name,
      effective_date, object_id, object_name,
      folder_id, folder_name,
      dimension_id, dimension_name,
      creation_date, created_by,
      last_updated_by, last_update_date, last_update_login)
    VALUES(
      FND_GLOBAL.Conc_Request_Id, v_request_date, v_request_name,
      p_rule_type, (SELECT object_type_name
                    FROM fem_object_types_vl
                    WHERE object_type_code = p_rule_type),
      p_ledger_id, (SELECT ledger_name
                    FROM fem_ledgers_vl
                    WHERE ledger_id = p_ledger_id),
      l_effective_date, p_object_id, (SELECT object_name
                                      FROM fem_object_catalog_vl
                                      WHERE object_id = p_object_id),
      p_folder_id, (SELECT folder_name
                    FROM fem_folders_vl
                    WHERE folder_id = p_folder_id),
      p_dim_id, (SELECT dimension_name
                 FROM fem_dimensions_vl
                 WHERE dimension_id = p_dim_id),
      v_request_date, FND_GLOBAL.User_ID,
      FND_GLOBAL.User_ID, v_request_date, FND_GLOBAL.Login_ID);
  END IF; -- IF (v_num_rules_invalid > 0)

  -- If there are any messages on the stack, post them to concurrent log.
  Get_Put_Messages;

  -- Post some summary statistics on number of root rules processed
  -- and invalid.
  FEM_ENGINES_PKG.USER_MESSAGE(
    p_app_name =>'FEM',
    p_msg_name => 'FEM_BR_DIS_MBR_NUM_ROOT_RULES',
    p_token1   => 'NUM',
    p_value1   => v_num_root_rules);

  FEM_ENGINES_PKG.USER_MESSAGE(
    p_app_name =>'FEM',
    p_msg_name => 'FEM_BR_DIS_MBR_NUM_INVALID',
    p_token1   => 'NUM',
    p_value1   => v_num_rules_invalid);

  COMMIT;

  -- Set concurrent status to success (0)
  retcode := 0;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'retcode = '||retcode);
  END IF;
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;
--
EXCEPTION
--
  WHEN others THEN
  -- Set concurrent status to error (2)
  retcode := 2;

  -- If there are any messages on the stack, post them to concurrent log.
  Get_Put_Messages;

  IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_unexpected,
      p_module   => C_MODULE,
      p_msg_text => 'Unexpected error: '||SQLERRM);
  END IF;

  -- Log the Oracle error message to the stack.
  FEM_ENGINES_PKG.USER_MESSAGE(
    p_app_name =>'FEM',
    p_msg_name => 'FEM_UNEXPECTED_ERROR',
    p_token1   => 'ERR_MSG',
    p_value1   => SQLERRM);

  ROLLBACK;
--
END Report_Invalid_Rules;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
PROCEDURE Purge_Report_Data(errbuf OUT NOCOPY VARCHAR2,
                            retcode OUT NOCOPY VARCHAR2,
                            p_execution_start_date IN VARCHAR2,
                            p_execution_end_date IN VARCHAR2,
                            p_request_id IN NUMBER) IS

  C_MODULE      CONSTANT FND_LOG_MESSAGES.module%TYPE :=
    'fem.plsql.fem_check_br_dis_mbrs_pkg.purge_report_data';
  l_start_date DATE;
  l_end_date   DATE;

BEGIN

  SAVEPOINT Purge_Report_Data;
  retcode := 0;

  l_start_date := fnd_date.canonical_to_date(p_execution_start_date);
  l_end_date := fnd_date.canonical_to_date(p_execution_end_date);

  --If request id is provided, ignore the other params and delete
  --the specific request from all the three tables.

  IF(p_request_id is not null) THEN

    DELETE FROM FEM_BR_DIS_MBR_CONTEXTS WHERE REQUEST_ID = p_request_id;
    DELETE FROM FEM_BR_DIS_MBR_HIER WHERE REQUEST_ID = p_request_id;
    DELETE FROM FEM_BR_DIS_MBR_REQUESTS WHERE REQUEST_ID = p_request_id;


  ELSIF(l_start_date IS NOT NULL AND l_end_date IS NOT NULL) THEN

    DELETE FROM FEM_BR_DIS_MBR_CONTEXTS WHERE REQUEST_ID IN (SELECT REQUEST_ID FROM
      FEM_BR_DIS_MBR_REQUESTS WHERE REQUEST_DATE BETWEEN l_start_date AND
      l_end_date);

    DELETE FROM FEM_BR_DIS_MBR_HIER WHERE REQUEST_ID IN (SELECT REQUEST_ID FROM
      FEM_BR_DIS_MBR_REQUESTS WHERE REQUEST_DATE BETWEEN l_start_date AND
      l_end_date);

    DELETE FROM FEM_BR_DIS_MBR_REQUESTS WHERE REQUEST_DATE BETWEEN l_start_date AND
      l_end_date;

  ELSIF(l_start_date IS NOT NULL AND l_end_date IS NULL) THEN

    DELETE FROM FEM_BR_DIS_MBR_CONTEXTS WHERE REQUEST_ID IN (SELECT REQUEST_ID FROM
      FEM_BR_DIS_MBR_REQUESTS WHERE REQUEST_DATE > l_start_date);

    DELETE FROM FEM_BR_DIS_MBR_HIER WHERE REQUEST_ID IN (SELECT REQUEST_ID FROM
      FEM_BR_DIS_MBR_REQUESTS WHERE REQUEST_DATE > l_start_date);

    DELETE FROM FEM_BR_DIS_MBR_REQUESTS WHERE REQUEST_DATE > l_start_date;

  ELSIF(l_start_date IS NULL AND l_end_date IS NOT NULL) THEN

    DELETE FROM FEM_BR_DIS_MBR_CONTEXTS WHERE REQUEST_ID IN (SELECT REQUEST_ID FROM
      FEM_BR_DIS_MBR_REQUESTS WHERE REQUEST_DATE < l_end_date);

    DELETE FROM FEM_BR_DIS_MBR_HIER WHERE REQUEST_ID IN (SELECT REQUEST_ID FROM
      FEM_BR_DIS_MBR_REQUESTS WHERE REQUEST_DATE < l_end_date);

    DELETE FROM FEM_BR_DIS_MBR_REQUESTS WHERE REQUEST_DATE < l_end_date;

  ELSE -- Delete all :-(

    DELETE FROM FEM_BR_DIS_MBR_CONTEXTS;
    DELETE FROM FEM_BR_DIS_MBR_HIER;
    DELETE FROM FEM_BR_DIS_MBR_REQUESTS;

  END IF;

  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      --
      ROLLBACK TO Purge_Report_Data;
      --

      retcode := 2;
      fem_engines_pkg.tech_message (p_severity => FND_LOG.level_unexpected
                                   ,p_module   => C_MODULE
                                   ,p_msg_text => 'EXCEPTION in Purge_Report_Data: ' || sqlerrm);
      fnd_file.put_line(fnd_file.log, 'EXCEPTION in Purge_Report_Data: ' || sqlerrm);

END Purge_Report_Data;
------------------------------------------------------------------------------


END FEM_CHECK_BR_DIS_MBRS_PKG;

/
