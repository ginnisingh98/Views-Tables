--------------------------------------------------------
--  DDL for Package Body CZ_CX_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_CX_UTIL_PVT" AS
/* $Header: czvcxub.pls 120.1 2006/04/27 11:41:32 skudryav ship $  */

FC_OUTPUT      CONSTANT VARCHAR2(1) := '5';
FC_AUTOCONFIG  CONSTANT VARCHAR2(1) := '6';
CX_OUTPUT      CONSTANT VARCHAR2(2) := '31';
CX_AUTOCONFIG  CONSTANT VARCHAR2(2) := '32';

DEFAULT_INCREMENT  NUMBER := 20;
m_rule_id          NUMBER := 0; -- next available seq no allocated
m_last_rule_id     NUMBER := 0; -- last seq no in allocated block
m_increment        NUMBER := DEFAULT_INCREMENT;

--------------------------------------------------------------------------------
FUNCTION get_next_rule_id RETURN NUMBER
IS
BEGIN
  IF (m_rule_id = 0 OR m_rule_id = m_last_rule_id) THEN
    IF (m_rule_id = 0) THEN
      BEGIN
        SELECT NVL(cz_utils.conv_num(value), DEFAULT_INCREMENT) INTO m_increment
        FROM CZ_DB_SETTINGS
        WHERE section_name = 'SCHEMA' AND setting_id = 'OracleSequenceIncr';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;

    SELECT cz_rules_s.NEXTVAL INTO m_rule_id FROM DUAL;
    m_last_rule_id := m_rule_id + m_increment - 1;
  ELSE
    m_rule_id := m_rule_id + 1;
  END IF;

  RETURN m_rule_id;
END get_next_rule_id;

--------------------------------------------------------------------------------
-- Converting old functional companion data to configurator extension foramt.
-- Returns return_status 1 if the conversion process is successful, 0 otherwise.
-- The tasks performed here are as follows.
-- 1. transform old fc recs to new cx rule data: cz_func_comp_specs => cz_rules
-- 2. update cz_rule_folders's id and type: func_comp_id, FNC => rule_id, CXT
-- 3. convert old ui fc data to new cx form
--    cz_ui_nodes: func_comp_id => cx_command_name
--    cz_ui_node_props: old value_str type (5,6) => new value_str type (31,32)
-- Note: event binding expression trees are created by Java program after
-- the above three tasks are finished. At the end of migration process, old fc
-- recs will be logically deleted by the same java program.
--
PROCEDURE convert_fc_by_model(p_model_id IN NUMBER
                             ,p_deep_migration_flag IN VARCHAR2
                             ,x_num_fc_processed OUT NOCOPY NUMBER
                             ,x_return_status OUT NOCOPY VARCHAR2
                             ,x_msg_data  OUT NOCOPY VARCHAR2
                             )
IS
  TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  model_tbl               number_tbl_type;
  fc_tbl                  number_tbl_type;
  seq_tbl                 number_tbl_type;
  fc2rule_map             number_tbl_type;
  deluinodes_ids_tbl      number_tbl_type;
  deluinodes_uidefids_tbl number_tbl_type;

  l_fc_count INTEGER := 0;
  l_rule_id  NUMBER;
  l_dummy    NUMBER;
  l_stat     NUMBER := 0;

  l_command_name  VARCHAR2(255);
  l_value_str     cz_ui_node_props.value_str%TYPE;

  no_source_model_exc  EXCEPTION;
  no_ui_fc_exc         EXCEPTION;

BEGIN
  -- verify input model is a source model
  BEGIN
    SELECT 1 INTO l_dummy FROM cz_rp_entries
    WHERE object_id = p_model_id AND object_type = 'PRJ' AND deleted_flag = '0';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE no_source_model_exc;
  END;
  l_stat := 1;

  UPDATE cz_func_comp_specs
  SET rule_folder_type = NULL
  WHERE rule_folder_type IS NOT NULL AND deleted_flag = '0';
  l_stat := 2;

  -- get all child models if necessary
  -- flag value depends on value_set cz_yes_no setting
  IF (upper(p_deep_migration_flag) = 'YES') THEN
    SELECT DISTINCT component_id
    BULK COLLECT INTO model_tbl
    FROM cz_model_ref_expls
    WHERE model_id = p_model_id AND ps_node_type = 263
    AND deleted_flag = '0';
  END IF;
  l_stat := 3;

  model_tbl(model_tbl.COUNT + 1) := p_model_id;

  FOR i IN model_tbl.FIRST .. model_tbl.LAST LOOP
    SELECT rule_folder_id, tree_seq
    BULK COLLECT INTO fc_tbl, seq_tbl
    FROM cz_rule_folders
    WHERE devl_project_id = model_tbl(i)
    AND object_type = 'FNC' AND deleted_flag = '0';
    l_stat := 3.1;

    IF (fc_tbl.COUNT > 0 ) THEN
      FOR j IN fc_tbl.FIRST .. fc_tbl.LAST LOOP
        l_rule_id := get_next_rule_id;
        UPDATE cz_func_comp_specs
        SET rule_folder_type = l_rule_id
        WHERE func_comp_id = fc_tbl(j);
        l_stat := 3.2;

        UPDATE cz_rule_folders
        SET rule_folder_id = l_rule_id, object_type = 'CXT'
        WHERE rule_folder_id = fc_tbl(j) AND object_type = 'FNC';
        l_stat := 3.3;

        INSERT INTO cz_rules(rule_id
                            ,persistent_rule_id
                            ,rule_type
                            ,seq_nbr
                            ,invalid_flag
                            ,disabled_flag
                            ,mutable_flag
                            ,effective_usage_mask
                            ,effective_from
                            ,effective_until
                            ,instantiation_scope
                            ,class_name
                            ,devl_project_id
                            ,component_id
                            ,model_ref_expl_id
                            ,rule_folder_id
                            ,name
                            ,desc_text
                            )
        SELECT l_rule_id
              ,l_rule_id
              ,300
              ,seq_tbl(j)
              ,'0'
              ,'0'
              ,'0'
              ,'0000000000000000'
              ,cz_utils.EPOCH_BEGIN
              ,cz_utils.EPOCH_END
              ,1
              ,program_string
              ,devl_project_id
              ,component_id
              ,model_ref_expl_id
              ,rule_folder_id
              ,name
              ,desc_text
        FROM cz_func_comp_specs
        WHERE func_comp_id = fc_tbl(j);

        l_fc_count := l_fc_count + 1;
        l_stat := 3.4;
      END LOOP;
    END IF;
  END LOOP;
  l_stat := 4;

  -- convert fc data in ui subschema if there exists any
  -- build fc to rule id lookup map
  FOR fc_rec IN (SELECT func_comp_id, rule_folder_type
                 FROM cz_func_comp_specs
                 WHERE deleted_flag = '0'
                 AND rule_folder_type IS NOT NULL) LOOP
    fc2rule_map(fc_rec.func_comp_id) := fc_rec.rule_folder_type;
  END LOOP;
  l_stat := 5;

  -- convert fc to cx
  FOR i IN model_tbl.FIRST .. model_tbl.LAST LOOP
    FOR ui_rec IN (SELECT def.ui_def_id, node.ui_node_id,
                          node.func_comp_id, prop.value_str
                   FROM cz_ui_defs def, cz_ui_nodes node, cz_ui_node_props prop
                   WHERE def.devl_project_id = model_tbl(i)
                   AND def.deleted_flag = '0'
                   AND def.ui_def_id = node.ui_def_id
                   AND node.deleted_flag = '0'
                   AND node.func_comp_id IS NOT NULL
                   AND node.ui_def_id = prop.ui_def_id
                   AND node.ui_node_id = prop.ui_node_id
                   AND prop.key_str = 'ActionType'
                   AND prop.value_str IN (FC_OUTPUT, FC_AUTOCONFIG)
                   AND prop.deleted_flag = '0'
                   AND node.parent_id <> (SELECT ui_node_id FROM CZ_UI_NODES
                                           WHERE ui_def_id=def.ui_def_id AND
                                                 name='Limbo' AND
                                                 deleted_flag='0')
    ) LOOP
      l_stat := 5.1;
      IF (NOT fc2rule_map.EXISTS(ui_rec.func_comp_id)) THEN

        -- collect those UI nodes ( buttons ) which have a references to unexisting Functional Companions
        deluinodes_ids_tbl(deluinodes_ids_tbl.COUNT+1) := ui_rec.ui_node_id;
        deluinodes_uidefids_tbl(deluinodes_uidefids_tbl.COUNT+1) := ui_rec.ui_def_id;

      END IF;

      IF (ui_rec.value_str = FC_OUTPUT) THEN
        l_command_name := fc2rule_map(ui_rec.func_comp_id) || '_GO';
        l_value_str := CX_OUTPUT;              -- GO = generateOutput
      ELSE
        l_command_name := fc2rule_map(ui_rec.func_comp_id) || '_AC';
        l_value_str := CX_AUTOCONFIG;          -- AC = autoconfig
      END IF;

      UPDATE cz_ui_nodes
      SET cx_command_name = l_command_name, func_comp_id = NULL
      WHERE ui_node_id = ui_rec.ui_node_id;
      l_stat := 5.2;

      UPDATE cz_ui_node_props
      SET value_str = l_value_str
      WHERE ui_def_id = ui_rec.ui_def_id
      AND ui_node_id = ui_rec.ui_node_id
      AND key_str = 'ActionType';
      l_stat := 5.3;
    END LOOP;
  END LOOP;
  l_stat := 6;

  IF deluinodes_ids_tbl.COUNT > 0 THEN
    -- collect those UI nodes ( buttons ) which have a references to unexisting Functional Companions
    FORALL k IN deluinodes_ids_tbl.First..deluinodes_ids_tbl.Last
      UPDATE CZ_UI_NODES
         SET deleted_flag='1'
       WHERE ui_def_id=deluinodes_uidefids_tbl(k) AND ui_node_id=deluinodes_ids_tbl(k);

    FORALL k IN deluinodes_ids_tbl.First..deluinodes_ids_tbl.Last
      UPDATE CZ_UI_NODE_PROPS
         SET deleted_flag='1'
       WHERE ui_def_id=deluinodes_uidefids_tbl(k) AND ui_node_id=deluinodes_ids_tbl(k);
  END IF;

  x_num_fc_processed := l_fc_count;
  x_return_status := 1;
EXCEPTION
  WHEN no_source_model_exc THEN
    x_return_status := 0;
    x_msg_data := 'Error in cz_cx_util_pvt.convert_fc_by_model: the model with '
                  || 'id ' || p_model_id || ' is not a source model.';
  WHEN no_ui_fc_exc THEN
    x_return_status := 0;
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := 0;
    x_msg_data := 'Error in cz_cx_util_pvt.convert_fc_by_model, stat=' || l_stat
                  || ': ' || SQLERRM;
END convert_fc_by_model;

--------------------------------------------------------------------------------

END cz_cx_util_pvt;

/
