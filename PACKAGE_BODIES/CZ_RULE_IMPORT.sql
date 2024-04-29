--------------------------------------------------------
--  DDL for Package Body CZ_RULE_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_RULE_IMPORT" AS
/* $Header: czruleib.pls 120.2.12010000.9 2010/06/07 13:10:11 pbondugu ship $  */
---------------------------------------------------------------------------------------
TYPE table_of_number  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE table_of_number_index_VC2  IS TABLE OF NUMBER INDEX BY VARCHAR2(15);
TYPE table_of_varchar IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
TYPE table_of_varchar_index_VC2 IS TABLE OF VARCHAR2(255) INDEX BY VARCHAR2(300);		--Bug8580853
TYPE table_of_rowid   IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
TYPE table_of_date    IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE table_of_clob    IS TABLE OF CLOB INDEX BY BINARY_INTEGER;
---------------------------------------------------------------------------------------

PROCEDURE report(p_message    IN VARCHAR2,
                 p_run_id     IN NUMBER,
                 p_caller     IN VARCHAR2,
                 p_statuscode IN NUMBER) IS
BEGIN
  INSERT INTO cz_db_logs (logtime, urgency, caller, statuscode, message, run_id)
  VALUES (SYSDATE, 1, p_caller, p_statuscode, p_message, p_run_id);
END;
---------------------------------------------------------------------------------------
PROCEDURE cnd_rules(p_api_version    IN NUMBER,
                    p_run_id         IN NUMBER,
                    p_maximum_errors IN PLS_INTEGER,
                    p_commit_size    IN PLS_INTEGER,
                    p_errors         IN OUT NOCOPY PLS_INTEGER,
                    x_return_status  IN OUT NOCOPY VARCHAR2,
                    x_msg_count      IN OUT NOCOPY NUMBER,
                    x_msg_data       IN OUT NOCOPY VARCHAR2) IS

  v_debug   NUMBER := 6000;

  CURSOR c_rec IS
    SELECT ROWID, devl_project_id, message, orig_sys_ref, rule_folder_id, rule_type,
           name, seeded_flag, deleted_flag, mutable_flag, disabled_flag, invalid_flag,
           presentation_flag, effective_usage_mask, seq_nbr, disposition,
           component_id, model_ref_expl_id, fsk_component_id, fsk_model_ref_expl_id,
           instantiation_scope,
           rule_class, class_seq,config_engine_type,accumulator_flag,top_level_constraint_flag  -- Bug9467066
      FROM cz_imp_rules
     WHERE run_id = p_run_id
       AND rec_status IS NULL
       AND disposition IS NULL;

  t_rowid                 table_of_rowid;
  t_devl_project_id       table_of_number;
  t_message               table_of_varchar;
  t_orig_sys_ref          table_of_varchar;
  t_rule_folder_id        table_of_number;
  t_rule_type             table_of_number;
  t_name                  table_of_varchar;
  t_seeded_flag           table_of_varchar;
  t_deleted_flag          table_of_varchar;
  t_mutable_flag          table_of_varchar;
  t_disabled_flag         table_of_varchar;
  t_invalid_flag          table_of_varchar;
  t_presentation_flag     table_of_varchar;
  t_effective_usage_mask  table_of_varchar;
  t_seq_nbr               table_of_number;
  t_disposition           table_of_varchar;
  t_component_id          table_of_number;
  t_model_ref_expl_id     table_of_number;
  t_fsk_component_id      table_of_varchar;
  t_fsk_model_ref_expl_id table_of_varchar;
  t_instantiation_scope   table_of_number;
  t_rule_class            table_of_number;       -- Bug9467066
  t_class_seq             table_of_number;       -- Bug9467066
  t_config_engine_type	  table_of_varchar;      -- Bug9467066
  t_accumulator_flag	    table_of_varchar;      -- Bug9467066
  t_top_level_constraint_flag	table_of_varchar;  -- Bug9467066

  validateModel    VARCHAR2(4000) :=
    'SELECT model_ref_expl_id ' ||
    '   FROM cz_rp_entries r, cz_model_ref_expls e ' ||
    '  WHERE r.deleted_flag = ''' || CZRI_FLAG_NOT_DELETED || ''' ' ||
    '    AND r.object_type = ''' || CZRI_REPOSITORY_PROJECT || ''' ' ||
    '    AND r.object_id = :1 ' ||
    '    AND e.deleted_flag = ''' || CZRI_FLAG_NOT_DELETED || ''' ' ||
    '    AND e.parent_expl_node_id IS NULL ' ||
    '    AND e.model_id = r.object_id';

  getRootFolderId  VARCHAR2(4000) :=
    'SELECT rule_folder_id ' ||
    '   FROM cz_rule_folders ' ||
    '  WHERE deleted_flag = ''' || CZRI_FLAG_NOT_DELETED || ''' ' ||
    '    AND object_type = ''' || CZRI_TYPE_RULE_FOLDER || ''' ' ||
    '    AND devl_project_id = :1 ' ||
    '    AND parent_rule_folder_id IS NULL';

  validateFolder   VARCHAR2(4000) :=
    'SELECT NULL ' ||
    '   FROM cz_rule_folders ' ||
    '  WHERE deleted_flag = ''' || CZRI_FLAG_NOT_DELETED || ''' ' ||
    '    AND object_type = ''' || CZRI_TYPE_RULE_FOLDER || ''' ' ||
    '    AND devl_project_id = :1 ' ||
    '    AND rule_folder_id = :2';

  h_ValidModel     table_of_number_index_VC2;
  h_InvalidModel   table_of_number_index_VC2;
  h_ValidFolder    table_of_number;
  h_RootFolder     table_of_number_index_VC2;
  h_NoSuchFolder   table_of_number;
  h_NoRootFolder   table_of_number_index_VC2;
  h_NameRootFolder table_of_varchar_index_VC2;		--Bug8580853
  v_null           NUMBER;
  v_root_folder_id NUMBER;
  v_root_expl_id   NUMBER;
  v_check_dup_name   VARCHAR2(4000);		--Bug8580853
---------------------------------------------------------------------------------------
  PROCEDURE update_table_data(p_upper_limit IN PLS_INTEGER) IS
  BEGIN

    FORALL i IN 1..p_upper_limit
      UPDATE cz_imp_rules SET
        message = t_message(i),
        seeded_flag = t_seeded_flag(i),
        deleted_flag = t_deleted_flag(i),
        rec_status = CZRI_RECSTATUS_CND,
        disposition = t_disposition(i),
        mutable_flag = t_mutable_flag(i),
        disabled_flag = t_disabled_flag(i),
        invalid_flag = t_invalid_flag(i),
        presentation_flag = t_presentation_flag(i),
        effective_usage_mask = t_effective_usage_mask(i),
        seq_nbr = t_seq_nbr(i),
        model_ref_expl_id = t_model_ref_expl_id(i),
        rule_folder_id = t_rule_folder_id(i),
        component_id = t_component_id(i),
        instantiation_scope = t_instantiation_scope(i),
        rule_class = t_rule_class(i),                              --Bug9467066
        class_seq = t_class_seq(i),                                --Bug9467066
        config_engine_type = t_config_engine_type(i),              --Bug9467066
        accumulator_flag = t_accumulator_flag(i),                  --Bug9467066
        top_level_constraint_flag = t_top_level_constraint_flag(i) --Bug9467066
      WHERE ROWID = t_rowid(i);
  END;
---------------------------------------------------------------------------------------
BEGIN

  OPEN c_rec;
  LOOP

    t_rowid.DELETE;
    t_devl_project_id.DELETE;
    t_message.DELETE;
    t_orig_sys_ref.DELETE;
    t_rule_folder_id.DELETE;
    t_rule_type.DELETE;
    t_name.DELETE;
    t_seeded_flag.DELETE;
    t_deleted_flag.DELETE;
    t_mutable_flag.DELETE;
    t_disabled_flag.DELETE;
    t_invalid_flag.DELETE;
    t_presentation_flag.DELETE;
    t_effective_usage_mask.DELETE;
    t_seq_nbr.DELETE;
    t_disposition.DELETE;
    t_component_id.DELETE;
    t_model_ref_expl_id.DELETE;
    t_fsk_component_id.DELETE;
    t_fsk_model_ref_expl_id.DELETE;
    t_instantiation_scope.DELETE;
    t_rule_class.DELETE;                     --Bug9467066
    t_class_seq.DELETE;                      --Bug9467066
    t_config_engine_type.DELETE;             --Bug9467066
    t_accumulator_flag.DELETE;               --Bug9467066
    t_top_level_constraint_flag.DELETE;      --Bug9467066
    FETCH c_rec BULK COLLECT INTO
      t_rowid, t_devl_project_id, t_message, t_orig_sys_ref, t_rule_folder_id, t_rule_type, t_name,
      t_seeded_flag, t_deleted_flag, t_mutable_flag, t_disabled_flag, t_invalid_flag, t_presentation_flag,
      t_effective_usage_mask, t_seq_nbr, t_disposition, t_component_id, t_model_ref_expl_id, t_fsk_component_id,
      t_fsk_model_ref_expl_id, t_instantiation_scope,t_rule_class, t_class_seq,t_config_engine_type,t_accumulator_flag,t_top_level_constraint_flag    --Bug9467066
    LIMIT p_commit_size;
    EXIT WHEN c_rec%NOTFOUND AND t_rowid.COUNT = 0;

    FOR i IN 1..t_rowid.COUNT LOOP

      t_message(i) := NULL;
      t_disposition(i) := CZRI_DISPOSITION_REJECT;

      IF(t_devl_project_id(i) IS NULL)THEN

        t_message(i) := cz_utils.get_text('CZRI_RLE_NULLMODELID');

      ELSIF(h_InvalidModel.EXISTS(t_devl_project_id(i)))THEN

        t_message(i) := cz_utils.get_text('CZRI_RLE_INVALIDMODEL');

      ELSIF(h_NoRootFolder.EXISTS(t_devl_project_id(i)))THEN

        t_message(i) := cz_utils.get_text('CZRI_RLE_NOROOTFOLDER');

      ELSIF(t_rule_folder_id(i) IS NOT NULL AND h_NoSuchFolder.EXISTS(t_rule_folder_id(i)))THEN

        t_message(i) := cz_utils.get_text('CZRI_RLE_NOSUCHFOLDER');

      ELSIF(t_orig_sys_ref(i) IS NULL)THEN

        t_message(i) := cz_utils.get_text('CZRI_RLE_NULLORIGSYSREF');

      ELSIF(t_rule_type(i) IS NULL)THEN

        t_message(i) := cz_utils.get_text('CZRI_RLE_NULLTYPE');

      ELSIF(t_rule_type(i) NOT IN (CZRI_TYPE_EXPRESSION_RULE, CZRI_TYPE_COMPANION_RULE))THEN

        t_message(i) := cz_utils.get_text('CZRI_RLE_INVALIDTYPE');

-- For the Phase I we do not implement resolution of component_id, model_ref_expl_id values for
-- CX rules using surrogate keys. Instead, we require direct population of the columns.
--
--    ELSIF(t_rule_type(i) = CZRI_TYPE_COMPANION_RULE AND t_fsk_component_id(i) IS NULL)THEN
--
--      t_message(i) := cz_utils.get_text('CZRI_RLE_NULLCOMPONENTID');
--
--    ELSIF(t_rule_type(i) = CZRI_TYPE_COMPANION_RULE AND t_fsk_model_ref_expl_id(i) IS NULL)THEN
--
--      t_message(i) := cz_utils.get_text('CZRI_RLE_NULLEXPLID');

-- If component_id is NULL, it will be populated automatically with the ps_node_id of the root
-- model node.
--
--    ELSIF(t_rule_type(i) = CZRI_TYPE_COMPANION_RULE AND t_component_id(i) IS NULL)THEN
--
--      t_message(i) := cz_utils.get_text('CZRI_RLE_NULLCOMPONENTID');

-- If model_ref_expl_id is NULL, it will be populated automatically with the model_ref_expl_id
-- of the root model node.
--
--    ELSIF(t_rule_type(i) = CZRI_TYPE_COMPANION_RULE AND t_model_ref_expl_id(i) IS NULL)THEN
--
--      t_message(i) := cz_utils.get_text('CZRI_RLE_NULLEXPLID');

      ELSIF(t_name(i) IS NULL)THEN

        t_message(i) := cz_utils.get_text('CZRI_RLE_NULLNAME');

      ELSIF(t_presentation_flag(i) IS NOT NULL AND t_presentation_flag(i) <> CZRI_FLAG_STATEMENT_RULE)THEN

        t_message(i) := cz_utils.get_text('CZRI_RLE_PRESENTFLAG');

      ELSE

        t_disposition(i) := CZRI_DISPOSITION_PASSED;
      END IF;

      IF(t_disposition(i) = CZRI_DISPOSITION_PASSED AND (NOT h_ValidModel.EXISTS(t_devl_project_id(i))))THEN

        BEGIN

          EXECUTE IMMEDIATE validateModel INTO v_root_expl_id USING t_devl_project_id(i);
          h_ValidModel(t_devl_project_id(i)) := v_root_expl_id;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            t_message(i) := cz_utils.get_text('CZRI_RLE_INVALIDMODEL');
            t_disposition(i) := CZRI_DISPOSITION_REJECT;
            h_InvalidModel(t_devl_project_id(i)) := 1;
        END;
      END IF;

      IF(t_disposition(i) = CZRI_DISPOSITION_PASSED)THEN
        IF(t_rule_folder_id(i) IS NULL)THEN
          IF(h_RootFolder.EXISTS(t_devl_project_id(i)))THEN

            t_rule_folder_id(i) := h_RootFolder(t_devl_project_id(i));

          ELSE

            BEGIN

              EXECUTE IMMEDIATE getRootFolderId INTO v_root_folder_id USING t_devl_project_id(i);
              t_rule_folder_id(i) := v_root_folder_id;
              h_RootFolder(t_devl_project_id(i)) := v_root_folder_id;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
               t_message(i) := cz_utils.get_text('CZRI_RLE_NOROOTFOLDER');
               t_disposition(i) := CZRI_DISPOSITION_REJECT;
               h_NoRootFolder(t_devl_project_id(i)) := 1;
            END;
          END IF;
        ELSE
          IF(NOT h_ValidFolder.EXISTS(t_rule_folder_id(i)))THEN

            BEGIN

              EXECUTE IMMEDIATE validateFolder INTO v_null USING t_devl_project_id(i), t_rule_folder_id(i);
              h_ValidFolder(t_rule_folder_id(i)) := v_root_folder_id;

            EXCEPTION
              WHEN NO_DATA_FOUND THEN
               t_message(i) := cz_utils.get_text('CZRI_RLE_NOSUCHFOLDER');
               t_disposition(i) := CZRI_DISPOSITION_REJECT;
               h_NoSuchFolder(t_rule_folder_id(i)) := 1;
            END;
          END IF;
        END IF;
      END IF;
      --Check for Duplicate names of rules Bug8580853
      IF(t_disposition(i) = CZRI_DISPOSITION_PASSED)THEN
        v_check_dup_name := t_devl_project_id(i) || '-' || t_rule_folder_id(i) ||'-' || t_name(i);		--Bug8580853
         IF(h_NameRootFolder.EXISTS(v_check_dup_name))THEN			--Bug8580853
            t_message(i) := cz_utils.get_text('CZRI_RLE_DUPNAME','DEVL_PROJ_ID',t_devl_project_id(i),'RULE_FOLDER_ID',t_rule_folder_id(i),'RULE_NAME',t_name(i));	--Bug8580853
            t_disposition(i) := CZRI_DISPOSITION_REJECT;
            FND_FILE.PUT_LINE(FND_FILE.LOG, t_message(i));
         ELSE
            h_NameRootFolder(v_check_dup_name):=1;
         END IF;
      END IF;

      IF(t_disposition(i) = CZRI_DISPOSITION_REJECT)THEN

        p_errors := p_errors + 1;

        IF(p_errors > CZRI_MAXIMUM_ERRORS)THEN

          --Update the already processed records here.

          update_table_data(i);
          COMMIT;
          RAISE CZRI_ERR_MAXIMUM_ERRORS;
        END IF;
      END IF;

      IF(t_disposition(i) = CZRI_DISPOSITION_PASSED)THEN

        --Validations passed, condition the record.
        --The seeded flag is unconditionally set to '0'.

        t_seeded_flag(i) := CZRI_FLAG_NOT_SEEDED;
        IF(t_instantiation_scope(i) IS NULL)THEN t_instantiation_scope(i) := CZRI_RULE_SCOPE_INSTANCE; END IF;
        IF(t_deleted_flag(i) IS NULL)THEN t_deleted_flag(i) := CZRI_FLAG_NOT_DELETED; END IF;
        IF(t_mutable_flag(i) IS NULL)THEN t_mutable_flag(i) := CZRI_FLAG_NOT_MUTABLE; END IF;
        IF(t_disabled_flag(i) IS NULL)THEN t_disabled_flag(i) := CZRI_FLAG_NOT_DISABLED; END IF;
        IF(t_invalid_flag(i) IS NULL)THEN t_invalid_flag(i) := CZRI_FLAG_NOT_INVALID; END IF;
        IF(t_presentation_flag(i) IS NULL)THEN t_presentation_flag(i) := CZRI_FLAG_STATEMENT_RULE; END IF;
        IF(t_effective_usage_mask(i) IS NULL)THEN t_effective_usage_mask(i) := CZRI_EFFECTIVE_USAGE; END IF;
        IF(t_seq_nbr(i) IS NULL)THEN t_seq_nbr(i) := CZRI_RULE_SEQ_NBR; END IF;
        IF(t_rule_type(i) = CZRI_TYPE_COMPANION_RULE AND t_model_ref_expl_id(i) IS NULL)THEN
          t_model_ref_expl_id(i) := h_ValidModel(t_devl_project_id(i));
        END IF;
        IF(t_rule_type(i) = CZRI_TYPE_COMPANION_RULE AND t_component_id(i) IS NULL)THEN
          t_component_id(i) := t_devl_project_id(i);
        END IF;
      END IF;
    END LOOP;

    --Update all the records from memory here.

    update_table_data(t_rowid.COUNT);
    COMMIT;
  END LOOP;

  CLOSE c_rec;
EXCEPTION
  WHEN CZRI_ERR_MAXIMUM_ERRORS THEN --maximum errors number exceeded.
    CLOSE c_rec;
    x_msg_data := cz_utils.get_text('CZRI_IMP_MAXIMUMERRORS', 'RUNID', p_run_id);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'cnd_rules', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_FATAL_ERROR;
  WHEN OTHERS THEN --unexpected errors occurred in the procedure.
    CLOSE c_rec;
    x_msg_data := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'cnd_rules', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_FATAL_ERROR;
END;
---------------------------------------------------------------------------------------
PROCEDURE krs_rules(p_api_version    IN NUMBER,
                    p_run_id         IN NUMBER,
                    p_maximum_errors IN PLS_INTEGER,
                    p_commit_size    IN PLS_INTEGER,
                    p_errors         IN OUT NOCOPY PLS_INTEGER,
                    x_return_status  IN OUT NOCOPY VARCHAR2,
                    x_msg_count      IN OUT NOCOPY NUMBER,
                    x_msg_data       IN OUT NOCOPY VARCHAR2) IS

  v_debug   NUMBER := 7000;
  v_error_flag            PLS_INTEGER;					--Bug8580853

  CURSOR c_rec IS
    SELECT ROWID, rule_id, name,rule_folder_id,devl_project_id, message, orig_sys_ref, rec_status, disposition,
           fsk_localized_text_1,fsk_localized_text_2, fsk_component_id, fsk_model_ref_expl_id, rule_type, reason_id, unsatisfied_msg_id,
           rule_class, class_seq,config_engine_type,accumulator_flag,top_level_constraint_flag                       --Bug9467066
      FROM cz_imp_rules
     WHERE run_id = p_run_id
       AND rec_status = CZRI_RECSTATUS_CND
       AND disposition = CZRI_DISPOSITION_PASSED
     ORDER BY devl_project_id, orig_sys_ref;

  CURSOR c_get_engine_type (cp_devl_project_id NUMBER) IS
  SELECT config_engine_type
  FROM   cz_devl_projects
  WHERE devl_project_id = cp_devl_project_id;


  t_rowid                 table_of_rowid;
  t_rule_id               table_of_number;
  t_name                  table_of_varchar;				--Bug8580853
  t_rule_folder_id        table_of_number;				--Bug8580853
  t_devl_project_id       table_of_number;
  t_message               table_of_varchar;
  t_orig_sys_ref          table_of_varchar;
  t_rec_status            table_of_varchar;
  t_disposition           table_of_varchar;
  t_fsk_localized_text_1  table_of_varchar;
  t_fsk_localized_text_2  table_of_varchar;				--Bug9068095
  t_fsk_component_id      table_of_varchar;
  t_fsk_model_ref_expl_id table_of_varchar;
  t_rule_type             table_of_number;
  t_reason_id             table_of_number;
  t_unsatisfied_msg_id    table_of_number;				--Bug9068095
  t_rule_class            table_of_number;        --Bug9467066
  t_class_seq             table_of_number;        --Bug9467066
  t_config_engine_type	  table_of_varchar;       --Bug9467066
  t_accumulator_flag       table_of_varchar;      --Bug9467066
  t_top_level_constraint_flag   table_of_varchar; --Bug9467066


  resolveRuleId     VARCHAR2(4000) :=
    'SELECT rule_id ' ||
    '   FROM cz_rules ' ||
    '  WHERE deleted_flag = ''' || CZRI_FLAG_NOT_DELETED || '''  ' ||
    '    AND devl_project_id =  :1 ' ||
    '    AND orig_sys_ref = :2';

  last_orig_sys_ref  cz_imp_rules.orig_sys_ref%TYPE;
  last_project_id    cz_imp_rules.devl_project_id%TYPE;

  last_id_allocated  NUMBER := NULL;
  next_id_to_use     NUMBER := 0;
  id_increment       NUMBER := CZRI_RULES_INC;

  t_intl_text_id     table_of_number;
  l_intl_text_id     table_of_number;
  v_translations     PLS_INTEGER;

  v_rule_class_chk  NUMBER         :=0;        --Bug9467066
  t_data_value      VARCHAR2(100)  := '';      --Bug9467066


---------------------------------------------------------------------------------------
  PROCEDURE update_table_data(p_upper_limit IN PLS_INTEGER) IS
  BEGIN

   FORALL i IN 1..p_upper_limit
      UPDATE cz_imp_rules SET
        rule_id = t_rule_id(i),
        reason_id = t_reason_id(i),
        unsatisfied_msg_id = t_unsatisfied_msg_id(i),
        message = t_message(i),
        rec_status = CZRI_RECSTATUS_KRS,
        disposition = t_disposition(i),
	config_engine_type = t_config_engine_type(i)
      WHERE ROWID = t_rowid(i);
  END;
---------------------------------------------------------------------------------------
FUNCTION next_rule_id RETURN NUMBER IS
  id_to_return      NUMBER;
BEGIN

  IF((last_id_allocated IS NULL) OR
     (next_id_to_use = (NVL(last_id_allocated, 0) + id_increment)))THEN

    SELECT cz_rules_s.NEXTVAL INTO last_id_allocated FROM dual;
    next_id_to_use := last_id_allocated;
  END IF;

  id_to_return := next_id_to_use;
  next_id_to_use := next_id_to_use + 1;
 RETURN id_to_return;
END;
---------------------------------------------------------------------------------------
BEGIN

  OPEN c_rec;
  LOOP

    t_rowid.DELETE;
    t_rule_id.DELETE;
    t_name.DELETE;							--Bug8580853
    t_rule_folder_id.DELETE;						--Bug8580853
    t_devl_project_id.DELETE;
    t_message.DELETE;
    t_orig_sys_ref.DELETE;
    t_rec_status.DELETE;
    t_disposition.DELETE;
    t_fsk_localized_text_1.DELETE;
    t_fsk_localized_text_2.DELETE;					--Bug9068095
    t_fsk_component_id.DELETE;
    t_fsk_model_ref_expl_id.DELETE;
    t_rule_type.DELETE;
    t_reason_id.DELETE;
    t_unsatisfied_msg_id.DELETE;					 --Bug9068095
    t_rule_class.DELETE;                   --Bug9467066
    t_class_seq.DELETE;                    --Bug9467066
    t_config_engine_type.DELETE;           --Bug9467066
    t_accumulator_flag.DELETE;             --Bug9467066
    t_top_level_constraint_flag.DELETE;    --Bug9467066

    FETCH c_rec BULK COLLECT INTO
      t_rowid, t_rule_id,t_name,t_rule_folder_id, t_devl_project_id, t_message, t_orig_sys_ref, t_rec_status, t_disposition,
      t_fsk_localized_text_1, t_fsk_localized_text_2, t_fsk_component_id, t_fsk_model_ref_expl_id, t_rule_type, t_reason_id, t_unsatisfied_msg_id,
      t_rule_class, t_class_seq, t_config_engine_type,t_accumulator_flag,t_top_level_constraint_flag      --Bug9467066
    LIMIT p_commit_size;
    EXIT WHEN c_rec%NOTFOUND AND t_rowid.COUNT = 0;

    FOR i IN 1..t_rowid.COUNT LOOP

      t_message(i) := NULL;

-- Bug9467066     Validating Config EngineType, Rule Class and Class Sequence combinations for FCE Rule Import

   IF (t_config_engine_type(i) IS NULL) THEN
     OPEN c_get_engine_type(t_devl_project_id(i));
     FETCH c_get_engine_type INTO t_config_engine_type(i);
     CLOSE c_get_engine_type;
   END IF;

   IF (t_config_engine_type(i) NOT IN ('F', 'L')) THEN
        t_message(i) := cz_utils.get_text('CZRI_CONFIG_ENGINE_INCORRECT');
        t_disposition(i) := CZRI_DISPOSITION_REJECT;

   ELSIF((t_config_engine_type(i)= 'L') AND ((t_rule_class(i) IS NOT NULL) OR (t_class_seq(i) IS NOT NULL))) THEN
        t_message(i) := cz_utils.get_text('CZRI_ENGTYP_RULCLSSSEQ_INVALD');
        t_disposition(i) := CZRI_DISPOSITION_REJECT;

   ELSIF (t_config_engine_type(i)='F' AND t_rule_class(i) IS NULL) THEN
        t_message(i) := cz_utils.get_text('CZRI_RULE_CLASS_INCORRECT');
        t_disposition(i) := CZRI_DISPOSITION_REJECT;

   ELSIF (t_config_engine_type(i)='F' AND t_rule_class(i) IS NULL AND t_class_seq(i) IS NOT NULL) THEN
          t_message(i) := cz_utils.get_text('CZRI_CLASS_SEQ_INCORRECT');
          t_disposition(i) := CZRI_DISPOSITION_REJECT;
   END IF;


-- Bug9467066     Validating Rule Class against Master data and Class Sequence combinations for FCE Rule Import
 IF (t_config_engine_type(i)='F'  AND t_rule_class(i) IS NOT NULL)THEN
   BEGIN

      BEGIN
        SELECT cz_rule_class_lkv.data_value
        INTO t_data_value
        FROM cz_rule_class_lkv
        WHERE cz_rule_class_lkv.data_value=t_rule_class(i);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         t_message(i) := cz_utils.get_text('CZRI_RULE_CLASS_INCORRECT');
         t_disposition(i) := CZRI_DISPOSITION_REJECT;
      END;


      IF((t_data_value='1')OR (t_data_value='2')) THEN
        IF(t_class_seq(i) IS NULL) THEN
           t_message(i) := cz_utils.get_text('CZRI_CLASS_SEQ_INCORRECT');
           t_disposition(i) := CZRI_DISPOSITION_REJECT;
	ELSE
	  BEGIN
            SELECT class_seq
            INTO v_rule_class_chk
            FROM cz_rules
            WHERE devl_project_id = t_devl_project_id(i)
            AND rule_class= t_rule_class(i)
	    AND class_seq = t_class_seq(i);

	     IF(v_rule_class_chk IS NOT NULL) then
               t_message(i) := cz_utils.get_text('CZRI_CLASS_SEQ_INCORRECT');
               t_disposition(i) := CZRI_DISPOSITION_REJECT;
	     END IF;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            -- Valid Case, No record found with same model id, rule class and class sequence. do nothing.
	    null;
	  WHEN TOO_MANY_ROWS THEN
             t_message(i) := cz_utils.get_text('CZRI_CLASS_SEQ_INCORRECT', 'MODELID', t_devl_project_id(i));
             t_disposition(i) := CZRI_DISPOSITION_REJECT;
          END;
        END IF;

      ELSIF(t_data_value='0' AND t_class_seq(i) IS NOT NULL ) THEN
          t_message(i) := cz_utils.get_text('CZRI_CLASS_SEQ_INCORRECT', 'MODELID', t_devl_project_id(i));
          t_disposition(i) := CZRI_DISPOSITION_REJECT;
      END IF;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
          t_message(i) := cz_utils.get_text('CZRI_CLASS_SEQ_INCORRECT', 'MODELID', t_devl_project_id(i));
          t_disposition(i) := CZRI_DISPOSITION_REJECT;

   WHEN TOO_MANY_ROWS THEN
          t_message(i) := cz_utils.get_text('CZRI_CLASS_SEQ_INCORRECT', 'MODELID', t_devl_project_id(i));
          t_disposition(i) := CZRI_DISPOSITION_REJECT;

   END;
 END IF;

      IF(last_orig_sys_ref IS NOT NULL AND
         last_orig_sys_ref = t_orig_sys_ref(i) AND
         last_project_id = t_devl_project_id(i))THEN

        --This is a duplicate record in the source data.

        t_message(i) := cz_utils.get_text('CZRI_RLE_DUPLICATE', 'MODELID', last_project_id);
        t_disposition(i) := CZRI_DISPOSITION_REJECT;
      END IF;

      IF(t_disposition(i) = CZRI_DISPOSITION_PASSED)THEN

        --Resolve rule_id for existing record or generate a new one for a new record.

        BEGIN
          EXECUTE IMMEDIATE resolveRuleId INTO t_rule_id(i)
                      USING t_devl_project_id(i), t_orig_sys_ref(i);

          t_disposition(i) := CZRI_DISPOSITION_MODIFY;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            t_disposition(i) := CZRI_DISPOSITION_INSERT;
            t_rule_id(i) := next_rule_id;
        END;
        BEGIN
          SELECT 1
	  INTO   v_error_flag
	  FROM   cz_rule_folders
	  WHERE  deleted_flag = CZRI_FLAG_NOT_DELETED
	  AND    devl_project_id = t_devl_project_id(i)
	  AND    name = t_name(i)
	  AND    rule_folder_id <> t_rule_id(i)
	  AND    parent_rule_folder_id = t_rule_folder_id(i);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_error_flag := 0;
          WHEN TOO_MANY_ROWS THEN
            v_error_flag := 1;
        END;
        -- Raise an error if similar rule name already exists in the project under a rule folder
        IF(v_error_flag = 1)THEN
          t_disposition(i) := CZRI_DISPOSITION_REJECT;
          t_message(i) := cz_utils.get_text('CZRI_DUPL_RULE_IN_FOLDER','DEVL_PROJ_ID',t_devl_project_id(i),'RULE_FOLDER_ID',t_rule_folder_id(i),'RULE_NAME',t_name(i)); --Bug8580853
          FND_FILE.PUT_LINE(FND_FILE.LOG, t_message(i));
        END IF;
        --Resolve unsatisfied_msg_id.					--Bug9068095

        IF(t_fsk_localized_text_2(i) IS NOT NULL)THEN

          SELECT intl_text_id BULK COLLECT INTO l_intl_text_id
            FROM cz_localized_texts
           WHERE deleted_flag = CZRI_FLAG_NOT_DELETED
             AND model_id = t_devl_project_id(i)
             AND orig_sys_ref = t_fsk_localized_text_2(i);

          IF(l_intl_text_id.COUNT > 0)THEN

            t_unsatisfied_msg_id(i) := l_intl_text_id(1);

            --All the records should have the same number of translations. Remember the number
            --of translations for the first record and compare all other records to it.

            IF(v_translations IS NULL)THEN

              v_translations := l_intl_text_id.COUNT;

            ELSIF(v_translations <> l_intl_text_id.COUNT)THEN

              t_message(i) := cz_utils.get_text('CZRI_RLE_TRANSLATIONS', 'ACTUAL', l_intl_text_id.COUNT, 'EXPECTED', v_translations);
              t_disposition(i) := CZRI_DISPOSITION_REJECT;
            END IF;
          ELSE
            t_message(i) := cz_utils.get_text('CZRI_RLE_NOUNSATISFIED');
            t_disposition(i) := CZRI_DISPOSITION_REJECT;
          END IF;
        END IF;

        --Resolve reason_id.

       IF(t_disposition(i) <> CZRI_DISPOSITION_REJECT)THEN

        IF(t_fsk_localized_text_1(i) IS NOT NULL)THEN

          SELECT intl_text_id BULK COLLECT INTO t_intl_text_id
            FROM cz_localized_texts
           WHERE deleted_flag = CZRI_FLAG_NOT_DELETED
             AND model_id = t_devl_project_id(i)
             AND orig_sys_ref = t_fsk_localized_text_1(i);

          IF(t_intl_text_id.COUNT > 0)THEN

            t_reason_id(i) := t_intl_text_id(1);

            --All the records should have the same number of translations. Remember the number
            --of translations for the first record and compare all other records to it.

            IF(v_translations IS NULL)THEN

              v_translations := t_intl_text_id.COUNT;

            ELSIF(v_translations <> t_intl_text_id.COUNT)THEN

              t_message(i) := cz_utils.get_text('CZRI_RLE_TRANSLATIONS', 'ACTUAL', t_intl_text_id.COUNT, 'EXPECTED', v_translations);
              t_disposition(i) := CZRI_DISPOSITION_REJECT;
            END IF;
          ELSE

            t_message(i) := cz_utils.get_text('CZRI_RLE_NOREASONID');
            t_disposition(i) := CZRI_DISPOSITION_REJECT;
          END IF;
        END IF;
       END IF;
      END IF;

      IF(t_disposition(i) <> CZRI_DISPOSITION_REJECT)THEN

        last_orig_sys_ref := t_orig_sys_ref(i);
        last_project_id := t_devl_project_id(i);
      END IF;

      IF(t_disposition(i) = CZRI_DISPOSITION_REJECT)THEN

        p_errors := p_errors + 1;

        IF(p_errors > CZRI_MAXIMUM_ERRORS)THEN

          --Update the already processed records here.

          update_table_data(i);
          COMMIT;
          RAISE CZRI_ERR_MAXIMUM_ERRORS;
        END IF;
      END IF;
    END LOOP;

    --Update all the records from memory here.

    update_table_data(t_rowid.COUNT);
    COMMIT;
  END LOOP;

  CLOSE c_rec;
EXCEPTION
  WHEN CZRI_ERR_MAXIMUM_ERRORS THEN --maximum errors number exceeded.
    CLOSE c_rec;
    x_msg_data := cz_utils.get_text('CZRI_IMP_MAXIMUMERRORS', 'RUNID', p_run_id);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'krs_rules', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_FATAL_ERROR;
  WHEN OTHERS THEN --unexpected errors occurred in the procedure.
    CLOSE c_rec;
    x_msg_data := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'krs_rules', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_FATAL_ERROR;
END;
---------------------------------------------------------------------------------------
PROCEDURE xfr_rules(p_api_version    IN NUMBER,
                    p_run_id         IN NUMBER,
                    p_maximum_errors IN PLS_INTEGER,
                    p_commit_size    IN PLS_INTEGER,
                    p_errors         IN OUT NOCOPY PLS_INTEGER,
                    x_return_status  IN OUT NOCOPY VARCHAR2,
                    x_msg_count      IN OUT NOCOPY NUMBER,
                    x_msg_data       IN OUT NOCOPY VARCHAR2) IS

  v_debug   NUMBER := 8000;

  --persistent_rule_id is taken care of by a trigger.

  CURSOR c_rec IS
    SELECT ROWID, rule_id, reason_id, rule_folder_id, devl_project_id, invalid_flag, desc_text,
           name, rule_type, expr_rule_type, component_id, model_ref_expl_id, reason_type,
           disabled_flag, orig_sys_ref, deleted_flag, security_mask, checkout_user, last_update_login,
           effective_usage_mask, seq_nbr, effective_from, effective_until, effectivity_set_id,
           unsatisfied_msg_id, unsatisfied_msg_source, signature_id, template_primitive_flag,
           presentation_flag, template_token, rule_text, notes, class_name, instantiation_scope,
           mutable_flag, seeded_flag, ui_def_id, ui_page_id, ui_page_element_id, rule_folder_type,
           disposition, message,
           rule_class, class_seq,config_engine_type,accumulator_flag,top_level_constraint_flag  --Bug9467066
      FROM cz_imp_rules
     WHERE run_id = p_run_id
       AND rec_status = CZRI_RECSTATUS_KRS
       AND disposition IN (CZRI_DISPOSITION_INSERT, CZRI_DISPOSITION_MODIFY);

    t_rowid                   table_of_rowid;
    t_rule_id                 table_of_number;
    t_reason_id               table_of_number;
    t_rule_folder_id          table_of_number;
    t_devl_project_id         table_of_number;
    t_invalid_flag            table_of_varchar;
    t_desc_text               table_of_varchar;
    t_name                    table_of_varchar;
    t_rule_type               table_of_number;
    t_expr_rule_type          table_of_number;
    t_component_id            table_of_number;
    t_model_ref_expl_id       table_of_number;
    t_reason_type             table_of_number;
    t_disabled_flag           table_of_varchar;
    t_orig_sys_ref            table_of_varchar;
    t_deleted_flag            table_of_varchar;
    t_security_mask           table_of_varchar;
    t_checkout_user           table_of_varchar;
    t_last_update_login       table_of_number;
    t_effective_usage_mask    table_of_varchar;
    t_seq_nbr                 table_of_number;
    t_effective_from          table_of_date;
    t_effective_until         table_of_date;
    t_effectivity_set_id      table_of_number;
    t_unsatisfied_msg_id      table_of_number;
    t_unsatisfied_msg_source  table_of_varchar;
    t_signature_id            table_of_number;
    t_template_primitive_flag table_of_varchar;
    t_presentation_flag       table_of_varchar;
    t_template_token          table_of_varchar;
    t_rule_text               table_of_clob;
    t_notes                   table_of_clob;
    t_class_name              table_of_varchar;
    t_instantiation_scope     table_of_number;
    t_mutable_flag            table_of_varchar;
    t_seeded_flag             table_of_varchar;
    t_ui_def_id               table_of_number;
    t_ui_page_id              table_of_number;
    t_ui_page_element_id      table_of_number;
    t_rule_folder_type        table_of_number;
    t_disposition             table_of_varchar;
    t_message                 table_of_varchar;
    t_rule_class              table_of_number;                --Bug9467066
    t_class_seq               table_of_number;                --Bug9467066
    t_config_engine_type      table_of_varchar;               --Bug9467066
    t_accumulator_flag	      table_of_varchar;               --Bug9467066
    t_top_level_constraint_flag  table_of_varchar;            --Bug9467066

---------------------------------------------------------------------------------------
  PROCEDURE update_table_data(p_upper_limit IN PLS_INTEGER) IS
  BEGIN

    --We updating rec_status to XFR, not OK, because the rules still have to be parsed.
    --When parsed successfully, the status will be changed to OK.

    FORALL i IN 1..p_upper_limit
      UPDATE cz_imp_rules SET
        message = t_message(i),
        rec_status = CZRI_RECSTATUS_XFR,
        disposition = t_disposition(i)
      WHERE ROWID = t_rowid(i);
  END;
---------------------------------------------------------------------------------------
  FUNCTION insert_online_data(p_upper_limit IN PLS_INTEGER) RETURN BOOLEAN IS

    t_rule_id                 table_of_number;
    t_reason_id               table_of_number;
    t_rule_folder_id          table_of_number;
    t_devl_project_id         table_of_number;
    t_invalid_flag            table_of_varchar;
    t_desc_text               table_of_varchar;
    t_name                    table_of_varchar;
    t_rule_type               table_of_number;
    t_expr_rule_type          table_of_number;
    t_component_id            table_of_number;
    t_model_ref_expl_id       table_of_number;
    t_reason_type             table_of_number;
    t_disabled_flag           table_of_varchar;
    t_orig_sys_ref            table_of_varchar;
    t_deleted_flag            table_of_varchar;
    t_security_mask           table_of_varchar;
    t_checkout_user           table_of_varchar;
    t_last_update_login       table_of_number;
    t_effective_usage_mask    table_of_varchar;
    t_seq_nbr                 table_of_number;
    t_effective_from          table_of_date;
    t_effective_until         table_of_date;
    t_effectivity_set_id      table_of_number;
    t_unsatisfied_msg_id      table_of_number;
    t_unsatisfied_msg_source  table_of_varchar;
    t_signature_id            table_of_number;
    t_template_primitive_flag table_of_varchar;
    t_presentation_flag       table_of_varchar;
    t_template_token          table_of_varchar;
    t_rule_text               table_of_clob;
    t_notes                   table_of_clob;
    t_class_name              table_of_varchar;
    t_instantiation_scope     table_of_number;
    t_mutable_flag            table_of_varchar;
    t_seeded_flag             table_of_varchar;
    t_ui_def_id               table_of_number;
    t_ui_page_id              table_of_number;
    t_ui_page_element_id      table_of_number;
    t_rule_folder_type        table_of_number;
    t_rule_class              table_of_number;        --Bug9467066
    t_class_seq               table_of_number;        --Bug9467066
    t_config_engine_type      table_of_varchar;       --Bug9467066
    t_accumulator_flag	      table_of_varchar;       --Bug9467066
    t_top_level_constraint_flag  table_of_varchar;    --Bug9467066

    v_index                   PLS_INTEGER := 1;
  BEGIN

    FOR i IN 1..p_upper_limit LOOP

      IF(xfr_rules.t_disposition(i) = CZRI_DISPOSITION_INSERT)THEN

        t_rule_id(v_index) := xfr_rules.t_rule_id(i);
        t_reason_id(v_index) := xfr_rules.t_reason_id(i);
        t_rule_folder_id(v_index) := xfr_rules.t_rule_folder_id(i);
        t_devl_project_id(v_index) := xfr_rules.t_devl_project_id(i);
        t_invalid_flag(v_index) := xfr_rules.t_invalid_flag(i);
        t_desc_text(v_index) := xfr_rules.t_desc_text(i);
        t_name(v_index) := xfr_rules.t_name(i);
        t_rule_type(v_index) := xfr_rules.t_rule_type(i);
        t_expr_rule_type(v_index) := xfr_rules.t_expr_rule_type(i);
        t_component_id(v_index) := xfr_rules.t_component_id(i);
        t_model_ref_expl_id(v_index) := xfr_rules.t_model_ref_expl_id(i);
        t_reason_type(v_index) := xfr_rules.t_reason_type(i);
        t_disabled_flag(v_index) := xfr_rules.t_disabled_flag(i);
        t_orig_sys_ref(v_index) := xfr_rules.t_orig_sys_ref(i);
        t_deleted_flag(v_index) := xfr_rules.t_deleted_flag(i);
        t_security_mask(v_index) := xfr_rules.t_security_mask(i);
        t_checkout_user(v_index) := xfr_rules.t_checkout_user(i);
        t_last_update_login(v_index) := xfr_rules.t_last_update_login(i);
        t_effective_usage_mask(v_index) := xfr_rules.t_effective_usage_mask(i);
        t_seq_nbr(v_index) := xfr_rules.t_seq_nbr(i);
        t_effective_from(v_index) := xfr_rules.t_effective_from(i);
        t_effective_until(v_index) := xfr_rules.t_effective_until(i);
        t_effectivity_set_id(v_index) := xfr_rules.t_effectivity_set_id(i);
        t_unsatisfied_msg_id(v_index) := xfr_rules.t_unsatisfied_msg_id(i);
        t_unsatisfied_msg_source(v_index) := xfr_rules.t_unsatisfied_msg_source(i);
        t_signature_id(v_index) := xfr_rules.t_signature_id(i);
        t_template_primitive_flag(v_index) := xfr_rules.t_template_primitive_flag(i);
        t_presentation_flag(v_index) := xfr_rules.t_presentation_flag(i);
        t_template_token(v_index) := xfr_rules.t_template_token(i);
        t_rule_text(v_index) := xfr_rules.t_rule_text(i);
        t_notes(v_index) := xfr_rules.t_notes(i);
        t_class_name(v_index) := xfr_rules.t_class_name(i);
        t_instantiation_scope(v_index) := xfr_rules.t_instantiation_scope(i);
        t_mutable_flag(v_index) := xfr_rules.t_mutable_flag(i);
        t_seeded_flag(v_index) := xfr_rules.t_seeded_flag(i);
        t_ui_def_id(v_index) := xfr_rules.t_ui_def_id(i);
        t_ui_page_id(v_index) := xfr_rules.t_ui_page_id(i);
        t_ui_page_element_id(v_index) := xfr_rules.t_ui_page_element_id(i);

        t_rule_class(v_index) := xfr_rules.t_rule_class(i);                                  -- Bug9467066
        t_class_seq(v_index) := xfr_rules.t_class_seq(i);                                     --Bug9467066
        t_config_engine_type(v_index) := xfr_rules.t_config_engine_type(i);                   --Bug9467066
        t_accumulator_flag(v_index) := xfr_rules.t_accumulator_flag(i);                       --Bug9467066
        t_top_level_constraint_flag(v_index) := xfr_rules.t_top_level_constraint_flag(i);     --Bug9467066

        v_index := v_index + 1;
      END IF;
    END LOOP;

    --FORALL i IN 1..t_rule_id.COUNT does not work in 8i because rule_text and noted are CLOB columns.

    FOR i IN 1..t_rule_id.COUNT LOOP

      INSERT INTO cz_rules
        (rule_id, reason_id, rule_folder_id, devl_project_id, invalid_flag, desc_text,
         name, rule_type, expr_rule_type, component_id, model_ref_expl_id, reason_type,
         disabled_flag, orig_sys_ref, deleted_flag, security_mask, checkout_user, last_update_login,
         effective_usage_mask, seq_nbr, effective_from, effective_until, effectivity_set_id,
         unsatisfied_msg_id, unsatisfied_msg_source, signature_id, template_primitive_flag,
         presentation_flag, template_token, rule_text, notes, class_name, instantiation_scope,
         mutable_flag, seeded_flag, ui_def_id, ui_page_id, ui_page_element_id, rule_folder_type,
         rule_class, class_seq,config_engine_type,accumulator_flag,top_level_constraint_flag)   --Bug9467066
      VALUES
        (t_rule_id(i), t_reason_id(i), t_rule_folder_id(i), t_devl_project_id(i), t_invalid_flag(i),
         t_desc_text(i), t_name(i), t_rule_type(i), t_expr_rule_type(i), t_component_id(i),
         t_model_ref_expl_id(i), t_reason_type(i), t_disabled_flag(i), t_orig_sys_ref(i), t_deleted_flag(i),
         t_security_mask(i), t_checkout_user(i), t_last_update_login(i), t_effective_usage_mask(i),
         t_seq_nbr(i), t_effective_from(i), t_effective_until(i), t_effectivity_set_id(i),
         t_unsatisfied_msg_id(i), t_unsatisfied_msg_source(i), t_signature_id(i), t_template_primitive_flag(i),
         t_presentation_flag(i), t_template_token(i), t_rule_text(i), t_notes(i), t_class_name(i),
         t_instantiation_scope(i), t_mutable_flag(i), t_seeded_flag(i), t_ui_def_id(i), t_ui_page_id(i),
         t_ui_page_element_id(i), t_rule_folder_type(i),
         t_rule_class(i), t_class_seq(i),t_config_engine_type(i),t_accumulator_flag(i),t_top_level_constraint_flag(i));    --Bug9467066
    END LOOP;

    FORALL i IN 1..t_rule_folder_id.COUNT
      INSERT INTO cz_rule_folders
        (rule_folder_id, parent_rule_folder_id, devl_project_id, desc_text, name, object_type, folder_type,
         disabled_flag, orig_sys_ref, deleted_flag, security_mask, checkout_user, last_update_login,
         effective_usage_mask, tree_seq, effective_from, effective_until, effectivity_set_id)
      VALUES
        (t_rule_id(i), t_rule_folder_id(i), t_devl_project_id(i), t_desc_text(i), t_name(i),
         DECODE(t_rule_type(i), CZRI_TYPE_COMPANION_RULE, CZRI_FOLDER_TYPE_CX, CZRI_FOLDER_TYPE_RULE),
         t_rule_folder_type(i), t_disabled_flag(i), t_orig_sys_ref(i), t_deleted_flag(i),
         t_security_mask(i), t_checkout_user(i), t_last_update_login(i), t_effective_usage_mask(i),
         t_seq_nbr(i), t_effective_from(i), t_effective_until(i), t_effectivity_set_id(i));

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END insert_online_data;
---------------------------------------------------------------------------------------
 FUNCTION update_online_data(p_upper_limit IN PLS_INTEGER) RETURN BOOLEAN IS

    t_rule_id                 table_of_number;
    t_reason_id               table_of_number;
    t_rule_folder_id          table_of_number;
    t_devl_project_id         table_of_number;
    t_invalid_flag            table_of_varchar;
    t_desc_text               table_of_varchar;
    t_name                    table_of_varchar;
    t_rule_type               table_of_number;
    t_expr_rule_type          table_of_number;
    t_component_id            table_of_number;
    t_model_ref_expl_id       table_of_number;
    t_reason_type             table_of_number;
    t_disabled_flag           table_of_varchar;
    t_orig_sys_ref            table_of_varchar;
    t_deleted_flag            table_of_varchar;
    t_security_mask           table_of_varchar;
    t_checkout_user           table_of_varchar;
    t_last_update_login       table_of_number;
    t_effective_usage_mask    table_of_varchar;
    t_seq_nbr                 table_of_number;
    t_effective_from          table_of_date;
    t_effective_until         table_of_date;
    t_effectivity_set_id      table_of_number;
    t_unsatisfied_msg_id      table_of_number;
    t_unsatisfied_msg_source  table_of_varchar;
    t_signature_id            table_of_number;
    t_template_primitive_flag table_of_varchar;
    t_presentation_flag       table_of_varchar;
    t_template_token          table_of_varchar;
    t_rule_text               table_of_clob;
    t_notes                   table_of_clob;
    t_class_name              table_of_varchar;
    t_instantiation_scope     table_of_number;
    t_mutable_flag            table_of_varchar;
    t_seeded_flag             table_of_varchar;
    t_ui_def_id               table_of_number;
    t_ui_page_id              table_of_number;
    t_ui_page_element_id      table_of_number;
    t_rule_folder_type        table_of_number;

    v_index                   PLS_INTEGER := 1;
    t_rule_class              table_of_number;        --Bug9467066
    t_class_seq               table_of_number;        --Bug9467066
    t_config_engine_type      table_of_varchar;       --Bug9467066
    t_accumulator_flag	      table_of_varchar;       --Bug9467066
    t_top_level_constraint_flag  table_of_varchar;    --Bug9467066
  BEGIN

    FOR i IN 1..p_upper_limit LOOP

      IF(xfr_rules.t_disposition(i) = CZRI_DISPOSITION_MODIFY)THEN

        t_rule_id(v_index) := xfr_rules.t_rule_id(i);
        t_reason_id(v_index) := xfr_rules.t_reason_id(i);
        t_rule_folder_id(v_index) := xfr_rules.t_rule_folder_id(i);
        t_devl_project_id(v_index) := xfr_rules.t_devl_project_id(i);
        t_invalid_flag(v_index) := xfr_rules.t_invalid_flag(i);
        t_desc_text(v_index) := xfr_rules.t_desc_text(i);
        t_name(v_index) := xfr_rules.t_name(i);
        t_rule_type(v_index) := xfr_rules.t_rule_type(i);
        t_expr_rule_type(v_index) := xfr_rules.t_expr_rule_type(i);
        t_component_id(v_index) := xfr_rules.t_component_id(i);
        t_model_ref_expl_id(v_index) := xfr_rules.t_model_ref_expl_id(i);
        t_reason_type(v_index) := xfr_rules.t_reason_type(i);
        t_disabled_flag(v_index) := xfr_rules.t_disabled_flag(i);
        t_orig_sys_ref(v_index) := xfr_rules.t_orig_sys_ref(i);
        t_deleted_flag(v_index) := xfr_rules.t_deleted_flag(i);
        t_security_mask(v_index) := xfr_rules.t_security_mask(i);
        t_checkout_user(v_index) := xfr_rules.t_checkout_user(i);
        t_last_update_login(v_index) := xfr_rules.t_last_update_login(i);
        t_effective_usage_mask(v_index) := xfr_rules.t_effective_usage_mask(i);
        t_seq_nbr(v_index) := xfr_rules.t_seq_nbr(i);
        t_effective_from(v_index) := xfr_rules.t_effective_from(i);
        t_effective_until(v_index) := xfr_rules.t_effective_until(i);
        t_effectivity_set_id(v_index) := xfr_rules.t_effectivity_set_id(i);
        t_unsatisfied_msg_id(v_index) := xfr_rules.t_unsatisfied_msg_id(i);
        t_unsatisfied_msg_source(v_index) := xfr_rules.t_unsatisfied_msg_source(i);
        t_signature_id(v_index) := xfr_rules.t_signature_id(i);
        t_template_primitive_flag(v_index) := xfr_rules.t_template_primitive_flag(i);
        t_presentation_flag(v_index) := xfr_rules.t_presentation_flag(i);
        t_template_token(v_index) := xfr_rules.t_template_token(i);
        t_rule_text(v_index) := xfr_rules.t_rule_text(i);
        t_notes(v_index) := xfr_rules.t_notes(i);
        t_class_name(v_index) := xfr_rules.t_class_name(i);
        t_instantiation_scope(v_index) := xfr_rules.t_instantiation_scope(i);
        t_mutable_flag(v_index) := xfr_rules.t_mutable_flag(i);
        t_seeded_flag(v_index) := xfr_rules.t_seeded_flag(i);
        t_ui_def_id(v_index) := xfr_rules.t_ui_def_id(i);
        t_ui_page_id(v_index) := xfr_rules.t_ui_page_id(i);
        t_ui_page_element_id(v_index) := xfr_rules.t_ui_page_element_id(i);
        t_rule_folder_type(v_index) :=xfr_rules.t_rule_folder_type(i);
        t_rule_class(v_index) := xfr_rules.t_rule_class(i);                                   --Bug9467066
        t_class_seq(v_index) := xfr_rules.t_class_seq(i);                                     --Bug9467066
        t_config_engine_type(v_index) := xfr_rules.t_config_engine_type(i);                   --Bug9467066
        t_accumulator_flag(v_index) := xfr_rules.t_accumulator_flag(i);                       --Bug9467066
        t_top_level_constraint_flag(v_index) := xfr_rules.t_top_level_constraint_flag(i);     --Bug9467066

        v_index := v_index + 1;
      END IF;
    END LOOP;

    --FORALL i IN 1..t_rule_id.COUNT does not work in 8i because rule_text and noted are CLOB columns.

    FOR i IN 1..t_rule_id.COUNT LOOP

      UPDATE cz_rules SET
        reason_id = t_reason_id(i),
        rule_folder_id = t_rule_folder_id(i),
        devl_project_id = t_devl_project_id(i),
        invalid_flag = t_invalid_flag(i),
        desc_text = t_desc_text(i),
        name = t_name(i),
        rule_type = t_rule_type(i),
        expr_rule_type = t_expr_rule_type(i),
        component_id = t_component_id(i),
        model_ref_expl_id = t_model_ref_expl_id(i),
        reason_type = t_reason_type(i),
        disabled_flag = t_disabled_flag(i),
        orig_sys_ref = t_orig_sys_ref(i),
        deleted_flag = t_deleted_flag(i),
        security_mask = t_security_mask(i),
        checkout_user = t_checkout_user(i),
        last_update_login = t_last_update_login(i),
        effective_usage_mask = t_effective_usage_mask(i),
        seq_nbr = t_seq_nbr(i),
        effective_from = t_effective_from(i),
        effective_until = t_effective_until(i),
        effectivity_set_id = t_effectivity_set_id(i),
        unsatisfied_msg_id = t_unsatisfied_msg_id(i),
        unsatisfied_msg_source = t_unsatisfied_msg_source(i),
        signature_id = t_signature_id(i),
        template_primitive_flag = t_template_primitive_flag(i),
        presentation_flag = t_presentation_flag(i),
        template_token = t_template_token(i),
        rule_text = t_rule_text(i),
        notes = t_notes(i),
        class_name = t_class_name(i),
        instantiation_scope = t_instantiation_scope(i),
        mutable_flag = t_mutable_flag(i),
        seeded_flag = t_seeded_flag(i),
        ui_def_id = t_ui_def_id(i),
        ui_page_id = t_ui_page_id(i),
        ui_page_element_id = t_ui_page_element_id(i),
        rule_folder_type = t_rule_folder_type(i),
        rule_class = t_rule_class(i),                                --Bug9467066
        class_seq = t_class_seq(i),                                  --Bug9467066
        config_engine_type = t_config_engine_type(i),                --Bug9467066
        accumulator_flag = t_accumulator_flag(i),                    --Bug9467066
        top_level_constraint_flag = t_top_level_constraint_flag(i)   --Bug9467066
      WHERE rule_id = t_rule_id(i);
    END LOOP;

    FORALL i IN 1..t_rule_id.COUNT
      UPDATE cz_rule_folders SET
        parent_rule_folder_id = t_rule_folder_id(i),
        desc_text = t_desc_text(i),
        name = t_name(i),
        folder_type = t_rule_folder_type(i),
        tree_seq = t_seq_nbr(i),
        disabled_flag = t_disabled_flag(i),
        deleted_flag = t_deleted_flag(i),
        security_mask = t_security_mask(i),
        checkout_user = t_checkout_user(i),
        last_update_login = t_last_update_login(i),
        effective_usage_mask = t_effective_usage_mask(i),
        effective_from = t_effective_from(i),
        effective_until = t_effective_until(i),
        effectivity_set_id = t_effectivity_set_id(i)
      WHERE rule_folder_id = t_rule_id(i)
        AND object_type = CZRI_FOLDER_TYPE_RULE;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END update_online_data;
---------------------------------------------------------------------------------------
BEGIN
  OPEN c_rec;
  LOOP

    t_rowid.DELETE;
    t_rule_id.DELETE;
    t_reason_id.DELETE;
    t_rule_folder_id.DELETE;
    t_devl_project_id.DELETE;
    t_invalid_flag.DELETE;
    t_desc_text.DELETE;
    t_name.DELETE;
    t_rule_type.DELETE;
    t_expr_rule_type.DELETE;
    t_component_id.DELETE;
    t_model_ref_expl_id.DELETE;
    t_reason_type.DELETE;
    t_disabled_flag.DELETE;
    t_orig_sys_ref.DELETE;
    t_deleted_flag.DELETE;
    t_security_mask.DELETE;
    t_checkout_user.DELETE;
    t_last_update_login.DELETE;
    t_effective_usage_mask.DELETE;
    t_seq_nbr.DELETE;
    t_effective_from.DELETE;
    t_effective_until.DELETE;
    t_effectivity_set_id.DELETE;
    t_unsatisfied_msg_id.DELETE;
    t_unsatisfied_msg_source.DELETE;
    t_signature_id.DELETE;
    t_template_primitive_flag.DELETE;
    t_presentation_flag.DELETE;
    t_template_token.DELETE;
    t_rule_text.DELETE;
    t_notes.DELETE;
    t_class_name.DELETE;
    t_instantiation_scope.DELETE;
    t_mutable_flag.DELETE;
    t_seeded_flag.DELETE;
    t_ui_def_id.DELETE;
    t_ui_page_id.DELETE;
    t_ui_page_element_id.DELETE;
    t_rule_folder_type.DELETE;
    t_disposition.DELETE;
    t_message.DELETE;
    t_rule_class.DELETE;                           --Bug9467066
    t_class_seq.DELETE;                            --Bug9467066
    t_accumulator_flag.DELETE;                     --Bug9467066
    t_top_level_constraint_flag.DELETE;            --Bug9467066
    t_config_engine_type.DELETE;                   --Bug9467066
    FETCH c_rec BULK COLLECT INTO
      t_rowid, t_rule_id, t_reason_id, t_rule_folder_id, t_devl_project_id, t_invalid_flag, t_desc_text, t_name,
      t_rule_type, t_expr_rule_type, t_component_id, t_model_ref_expl_id, t_reason_type, t_disabled_flag,
      t_orig_sys_ref, t_deleted_flag, t_security_mask, t_checkout_user, t_last_update_login, t_effective_usage_mask,
      t_seq_nbr, t_effective_from, t_effective_until, t_effectivity_set_id, t_unsatisfied_msg_id,
      t_unsatisfied_msg_source, t_signature_id, t_template_primitive_flag, t_presentation_flag, t_template_token,
      t_rule_text, t_notes, t_class_name, t_instantiation_scope, t_mutable_flag, t_seeded_flag, t_ui_def_id,
      t_ui_page_id, t_ui_page_element_id, t_rule_folder_type, t_disposition, t_message,
      t_rule_class, t_class_seq,t_config_engine_type, t_accumulator_flag, t_top_level_constraint_flag       --Bug9467066
    LIMIT p_commit_size;
    EXIT WHEN c_rec%NOTFOUND AND t_rowid.COUNT = 0;

    FOR i IN 1..t_rowid.COUNT LOOP

      t_message(i) := NULL;
    END LOOP;

    IF(NOT insert_online_data(t_rowid.COUNT))THEN
    --Bug9467066
  --  SELECT cz_devl_projects.config_engine_type
   --   INTO t_config_engine_type
   --   FROM cz_devl_projects,cz_imp_rules
   --  WHERE cz_imp_rules.devl_project_id = cz_devl_projects.devl_project_id
  --     AND cz_imp_rules.run_id = p_run_id;
       --Bug9467066
      FOR i IN 1..t_rowid.COUNT LOOP

        IF(t_disposition(i) = CZRI_DISPOSITION_INSERT)THEN

          BEGIN

            SAVEPOINT insert_rule_record;
            INSERT INTO cz_rules
              (rule_id, reason_id, rule_folder_id, devl_project_id, invalid_flag, desc_text,
               name, rule_type, expr_rule_type, component_id, model_ref_expl_id, reason_type,
               disabled_flag, orig_sys_ref, deleted_flag, security_mask, checkout_user, last_update_login,
               effective_usage_mask, seq_nbr, effective_from, effective_until, effectivity_set_id,
               unsatisfied_msg_id, unsatisfied_msg_source, signature_id, template_primitive_flag,
               presentation_flag, template_token, rule_text, notes, class_name, instantiation_scope,
               mutable_flag, seeded_flag, ui_def_id, ui_page_id, ui_page_element_id, rule_folder_type,
               rule_class, class_seq,config_engine_type,accumulator_flag, top_level_constraint_flag)   --Bug9467066
            VALUES
              (t_rule_id(i), t_reason_id(i), t_rule_folder_id(i), t_devl_project_id(i),
               t_invalid_flag(i), t_desc_text(i), t_name(i), t_rule_type(i), t_expr_rule_type(i),
               t_component_id(i), t_model_ref_expl_id(i), t_reason_type(i), t_disabled_flag(i),
               t_orig_sys_ref(i), t_deleted_flag(i), t_security_mask(i), t_checkout_user(i),
               t_last_update_login(i), t_effective_usage_mask(i), t_seq_nbr(i), t_effective_from(i),
               t_effective_until(i), t_effectivity_set_id(i), t_unsatisfied_msg_id(i),
               t_unsatisfied_msg_source(i), t_signature_id(i), t_template_primitive_flag(i),
               t_presentation_flag(i), t_template_token(i), t_rule_text(i), t_notes(i),
               t_class_name(i), t_instantiation_scope(i), t_mutable_flag(i), t_seeded_flag(i),
               t_ui_def_id(i), t_ui_page_id(i), t_ui_page_element_id(i), t_rule_folder_type(i),
               t_rule_class(i), t_class_seq(i),t_config_engine_type(i),t_accumulator_flag(i), t_top_level_constraint_flag(i));   --Bug9467066
             INSERT INTO cz_rule_folders
              (rule_folder_id, parent_rule_folder_id, devl_project_id, desc_text, name, object_type, folder_type,
               disabled_flag, orig_sys_ref, deleted_flag, security_mask, checkout_user, last_update_login,
               effective_usage_mask, tree_seq, effective_from, effective_until, effectivity_set_id)
            VALUES
              (t_rule_id(i), t_rule_folder_id(i), t_devl_project_id(i), t_desc_text(i), t_name(i),
               DECODE(t_rule_type(i), CZRI_TYPE_COMPANION_RULE, CZRI_FOLDER_TYPE_CX, CZRI_FOLDER_TYPE_RULE),
               t_rule_folder_type(i), t_disabled_flag(i), t_orig_sys_ref(i),
               t_deleted_flag(i), t_security_mask(i), t_checkout_user(i), t_last_update_login(i),
               t_effective_usage_mask(i), t_seq_nbr(i), t_effective_from(i), t_effective_until(i),
               t_effectivity_set_id(i));

          EXCEPTION
            WHEN OTHERS THEN
              t_message(i) := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
              t_disposition(i) := CZRI_DISPOSITION_REJECT;
              ROLLBACK TO insert_rule_record;
          END;
        END IF;

        IF(t_disposition(i) = CZRI_DISPOSITION_REJECT)THEN

          p_errors := p_errors + 1;

          IF(p_errors > CZRI_MAXIMUM_ERRORS)THEN

            --Update the already processed records here.

            update_table_data(i);
            COMMIT;
            RAISE CZRI_ERR_MAXIMUM_ERRORS;
          END IF;
        END IF;
      END LOOP;
    END IF;

    IF(NOT update_online_data(t_rowid.COUNT))THEN

      FOR i IN 1..t_rowid.COUNT LOOP

        IF(t_disposition(i) = CZRI_DISPOSITION_MODIFY)THEN

          BEGIN

            SAVEPOINT update_rule_record;

            UPDATE cz_rules SET
              reason_id = t_reason_id(i),
              rule_folder_id = t_rule_folder_id(i),
              devl_project_id = t_devl_project_id(i),
              invalid_flag = t_invalid_flag(i),
              desc_text = t_desc_text(i),
              name = t_name(i),
              rule_type = t_rule_type(i),
              expr_rule_type = t_expr_rule_type(i),
              component_id = t_component_id(i),
              model_ref_expl_id = t_model_ref_expl_id(i),
              reason_type = t_reason_type(i),
              disabled_flag = t_disabled_flag(i),
              orig_sys_ref = t_orig_sys_ref(i),
              deleted_flag = t_deleted_flag(i),
              security_mask = t_security_mask(i),
              checkout_user = t_checkout_user(i),
              last_update_login = t_last_update_login(i),
              effective_usage_mask = t_effective_usage_mask(i),
              seq_nbr = t_seq_nbr(i),
              effective_from = t_effective_from(i),
              effective_until = t_effective_until(i),
              effectivity_set_id = t_effectivity_set_id(i),
              unsatisfied_msg_id = t_unsatisfied_msg_id(i),
              unsatisfied_msg_source = t_unsatisfied_msg_source(i),
              signature_id = t_signature_id(i),
              template_primitive_flag = t_template_primitive_flag(i),
              presentation_flag = t_presentation_flag(i),
              template_token = t_template_token(i),
              rule_text = t_rule_text(i),
              notes = t_notes(i),
              class_name = t_class_name(i),
              instantiation_scope = t_instantiation_scope(i),
              mutable_flag = t_mutable_flag(i),
              seeded_flag = t_seeded_flag(i),
              ui_def_id = t_ui_def_id(i),
              ui_page_id = t_ui_page_id(i),
              ui_page_element_id = t_ui_page_element_id(i),
              rule_folder_type = t_rule_folder_type(i),
              rule_class = t_rule_class(i),                               --Bug9467066
              class_seq = t_class_seq(i),                                 --Bug9467066
              config_engine_type = t_config_engine_type(i),               --Bug9467066
              accumulator_flag = t_accumulator_flag(i),                   --Bug9467066
              top_level_constraint_flag = t_top_level_constraint_flag(i)  --Bug9467066
            WHERE rule_id = t_rule_id(i);

            UPDATE cz_rule_folders SET
              parent_rule_folder_id = t_rule_folder_id(i),
              desc_text = t_desc_text(i),
              name = t_name(i),
              folder_type = t_rule_folder_type(i),
              tree_seq = t_seq_nbr(i),
              disabled_flag = t_disabled_flag(i),
              deleted_flag = t_deleted_flag(i),
              security_mask = t_security_mask(i),
              checkout_user = t_checkout_user(i),
              last_update_login = t_last_update_login(i),
              effective_usage_mask = t_effective_usage_mask(i),
              effective_from = t_effective_from(i),
              effective_until = t_effective_until(i),
              effectivity_set_id = t_effectivity_set_id(i)
            WHERE rule_folder_id = t_rule_id(i)
              AND object_type = CZRI_FOLDER_TYPE_RULE;

          EXCEPTION
            WHEN OTHERS THEN
              t_message(i) := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
              t_disposition(i) := CZRI_DISPOSITION_REJECT;
              ROLLBACK TO update_rule_record;
          END;
        END IF;

        IF(t_disposition(i) = CZRI_DISPOSITION_REJECT)THEN

          p_errors := p_errors + 1;

          IF(p_errors > CZRI_MAXIMUM_ERRORS)THEN

            --Update the already processed records here.

            update_table_data(i);
            COMMIT;
            RAISE CZRI_ERR_MAXIMUM_ERRORS;
          END IF;
        END IF;
      END LOOP;
    END IF;

    update_table_data(t_rowid.COUNT);
    COMMIT;
  END LOOP;

  CLOSE c_rec;
EXCEPTION
  WHEN CZRI_ERR_MAXIMUM_ERRORS THEN --maximum errors number exceeded.
    CLOSE c_rec;
    x_msg_data := cz_utils.get_text('CZRI_IMP_MAXIMUMERRORS', 'RUNID', p_run_id);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'xfr_rules', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_FATAL_ERROR;
  WHEN OTHERS THEN --unexpected errors occurred in the procedure.
    CLOSE c_rec;
    x_msg_data := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'xfr_rules', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_FATAL_ERROR;
END;
---------------------------------------------------------------------------------------
PROCEDURE rpt_rules(p_api_version   IN NUMBER,
                    p_run_id        IN NUMBER,
                    x_return_status IN OUT NOCOPY VARCHAR2,
                    x_msg_count     IN OUT NOCOPY NUMBER,
                    x_msg_data      IN OUT NOCOPY VARCHAR2) IS

  v_debug   NUMBER := 9000;
BEGIN
  FOR c_stat IN (SELECT disposition, rec_status, COUNT(*) as records
                   FROM cz_imp_rules
                  WHERE run_id = p_run_id
                    AND rec_status IS NOT NULL
                    AND disposition IS NOT NULL
                  GROUP BY disposition, rec_status) LOOP

    INSERT INTO cz_xfr_run_results (run_id, imp_table, disposition, rec_status, records)
    VALUES (p_run_id, 'CZ_IMP_RULES', c_stat.disposition, c_stat.rec_status, c_stat.records);
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN --unexpected errors occurred in the procedure.
    x_msg_data := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'rpt_rules', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_REPORT_ERROR;
END;
---------------------------------------------------------------------------------------
PROCEDURE restat_rules(p_api_version   IN NUMBER,
                       p_run_id        IN NUMBER,
                       x_return_status IN OUT NOCOPY VARCHAR2,
                       x_msg_count     IN OUT NOCOPY NUMBER,
                       x_msg_data      IN OUT NOCOPY VARCHAR2) IS

  v_debug   NUMBER := 11000;
BEGIN

  DELETE FROM cz_xfr_run_results WHERE run_id = p_run_id;
  rpt_rules(p_api_version, p_run_id, x_return_status, x_msg_count, x_msg_data);
END;
---------------------------------------------------------------------------------------
PROCEDURE import_rules(p_api_version    IN NUMBER,
                       p_run_id         IN NUMBER,
                       p_maximum_errors IN PLS_INTEGER,
                       p_commit_size    IN PLS_INTEGER,
                       p_errors         IN OUT NOCOPY PLS_INTEGER,
                       x_return_status  IN OUT NOCOPY VARCHAR2,
                       x_msg_count      IN OUT NOCOPY NUMBER,
                       x_msg_data       IN OUT NOCOPY VARCHAR2) IS
BEGIN
  cnd_rules(p_api_version,
            p_run_id,
            p_maximum_errors,
            p_commit_size,
            p_errors,
            x_return_status,
            x_msg_count,
            x_msg_data);

  krs_rules(p_api_version,
            p_run_id,
            p_maximum_errors,
            p_commit_size,
            p_errors,
            x_return_status,
            x_msg_count,
            x_msg_data);

  xfr_rules(p_api_version,
            p_run_id,
            p_maximum_errors,
            p_commit_size,
            p_errors,
            x_return_status,
            x_msg_count,
            x_msg_data);

  rpt_rules(p_api_version,
            p_run_id,
            x_return_status,
            x_msg_count,
            x_msg_data);

EXCEPTION
  WHEN CZRI_ERR_REPORT_ERROR THEN
    RAISE CZRI_ERR_FATAL_ERROR;
  WHEN OTHERS THEN
    rpt_rules(p_api_version,
              p_run_id,
              x_return_status,
              x_msg_count,
              x_msg_data);
    RAISE;
END;
---------------------------------------------------------------------------------------
PROCEDURE cnd_localized_texts(p_api_version    IN NUMBER,
                              p_run_id         IN NUMBER,
                              p_maximum_errors IN PLS_INTEGER,
                              p_commit_size    IN PLS_INTEGER,
                              p_errors         IN OUT NOCOPY PLS_INTEGER,
                              x_return_status  IN OUT NOCOPY VARCHAR2,
                              x_msg_count      IN OUT NOCOPY NUMBER,
                              x_msg_data       IN OUT NOCOPY VARCHAR2) IS

  v_debug   NUMBER := 2000;

  CURSOR c_rec IS
    SELECT ROWID, model_id, message, orig_sys_ref, language, source_lang,
           seeded_flag, deleted_flag, disposition
      FROM cz_imp_localized_texts
     WHERE run_id = p_run_id
       AND rec_status IS NULL
       AND disposition IS NULL;

  t_rowid         table_of_rowid;
  t_model_id      table_of_number;
  t_message       table_of_varchar;
  t_orig_sys_ref  table_of_varchar;
  t_language      table_of_varchar;
  t_source_lang   table_of_varchar;
  t_seeded_flag   table_of_varchar;
  t_deleted_flag  table_of_varchar;
  t_disposition   table_of_varchar;

  validateModel   VARCHAR2(4000) :=
    'SELECT NULL ' ||
    '   FROM cz_rp_entries ' ||
    '  WHERE deleted_flag = ''' || CZRI_FLAG_NOT_DELETED || ''' ' ||
    '    AND object_type = ''' || CZRI_REPOSITORY_PROJECT || ''' ' ||
    '    AND object_id = :1';

  h_ValidModel    table_of_number_index_VC2;
  h_InvalidModel  table_of_number_index_VC2;
  v_null          NUMBER;

---------------------------------------------------------------------------------------
  PROCEDURE update_table_data(p_upper_limit IN PLS_INTEGER) IS
  BEGIN

    FORALL i IN 1..p_upper_limit
      UPDATE cz_imp_localized_texts SET
        message = t_message(i),
        seeded_flag = t_seeded_flag(i),
        deleted_flag = t_deleted_flag(i),
        rec_status = CZRI_RECSTATUS_CND,
        disposition = t_disposition(i)
      WHERE ROWID = t_rowid(i);
  END;
---------------------------------------------------------------------------------------
BEGIN

  OPEN c_rec;
  LOOP

    t_rowid.DELETE;
    t_model_id.DELETE;
    t_message.DELETE;
    t_orig_sys_ref.DELETE;
    t_language.DELETE;
    t_source_lang.DELETE;
    t_seeded_flag.DELETE;
    t_deleted_flag.DELETE;
    t_disposition.DELETE;

    FETCH c_rec BULK COLLECT INTO
      t_rowid, t_model_id, t_message, t_orig_sys_ref, t_language, t_source_lang, t_seeded_flag, t_deleted_flag,
      t_disposition
    LIMIT p_commit_size;
    EXIT WHEN c_rec%NOTFOUND AND t_rowid.COUNT = 0;

    FOR i IN 1..t_rowid.COUNT LOOP

      t_message(i) := NULL;
      t_disposition(i) := CZRI_DISPOSITION_REJECT;

      IF(t_model_id(i) IS NULL)THEN

        t_message(i) := cz_utils.get_text('CZRI_TXT_NULLMODELID');

      ELSIF(h_InvalidModel.EXISTS(t_model_id(i)))THEN

        t_message(i) := cz_utils.get_text('CZRI_TXT_INVALIDMODEL');

      ELSIF(t_orig_sys_ref(i) IS NULL)THEN

        t_message(i) := cz_utils.get_text('CZRI_TXT_NULLORIGSYSREF');

      ELSIF(t_language(i) IS NULL)THEN

        t_message(i) := cz_utils.get_text('CZRI_TXT_NULLLANGUAGE');

      ELSIF(t_source_lang(i) IS NULL)THEN

        t_message(i) := cz_utils.get_text('CZRI_TXT_NULLSOURCELANG');

      ELSE

        t_disposition(i) := CZRI_DISPOSITION_PASSED;
      END IF;

      IF(t_disposition(i) = CZRI_DISPOSITION_PASSED AND (NOT h_ValidModel.EXISTS(t_model_id(i))))THEN
        BEGIN

          EXECUTE IMMEDIATE validateModel INTO v_null USING t_model_id(i);
          h_ValidModel(t_model_id(i)) := 1;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            t_message(i) := cz_utils.get_text('CZRI_TXT_INVALIDMODEL');
            t_disposition(i) := CZRI_DISPOSITION_REJECT;
            h_InvalidModel(t_model_id(i)) := 1;
        END;
      END IF;

      IF(t_disposition(i) = CZRI_DISPOSITION_REJECT)THEN

        p_errors := p_errors + 1;

        IF(p_errors > CZRI_MAXIMUM_ERRORS)THEN

          --Update the already processed records here.

          update_table_data(i);
          COMMIT;
          RAISE CZRI_ERR_MAXIMUM_ERRORS;
        END IF;
      END IF;

      IF(t_disposition(i) = CZRI_DISPOSITION_PASSED)THEN

        --All the validations passed, condition the record.
        --The seeded flag is unconditionally set to '0'.

        t_seeded_flag(i) := CZRI_FLAG_NOT_SEEDED;
        IF(t_deleted_flag(i) IS NULL)THEN t_deleted_flag(i) := CZRI_FLAG_NOT_DELETED; END IF;
      END IF;
    END LOOP;

    --Update all the records from memory here.

    update_table_data(t_rowid.COUNT);
    COMMIT;
  END LOOP;

  CLOSE c_rec;
EXCEPTION
  WHEN CZRI_ERR_MAXIMUM_ERRORS THEN --maximum errors number exceeded.
    CLOSE c_rec;
    x_msg_data := cz_utils.get_text('CZRI_IMP_MAXIMUMERRORS', 'RUNID', p_run_id);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'cnd_localized_texts', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_FATAL_ERROR;
  WHEN OTHERS THEN --unexpected errors occurred in the procedure.
    CLOSE c_rec;
    x_msg_data := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'cnd_localized_texts', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_FATAL_ERROR;
END;
---------------------------------------------------------------------------------------
PROCEDURE krs_localized_texts(p_api_version    IN NUMBER,
                              p_run_id         IN NUMBER,
                              p_maximum_errors IN PLS_INTEGER,
                              p_commit_size    IN PLS_INTEGER,
                              p_errors         IN OUT NOCOPY PLS_INTEGER,
                              x_return_status  IN OUT NOCOPY VARCHAR2,
                              x_msg_count      IN OUT NOCOPY NUMBER,
                              x_msg_data       IN OUT NOCOPY VARCHAR2) IS

  v_debug   NUMBER := 3000;

  CURSOR c_rec IS
    SELECT ROWID, intl_text_id, model_id, message, orig_sys_ref, language, rec_status, disposition
      FROM cz_imp_localized_texts
     WHERE run_id = p_run_id
       AND rec_status = CZRI_RECSTATUS_CND
       AND disposition = CZRI_DISPOSITION_PASSED
     ORDER BY model_id, orig_sys_ref, language;

  t_rowid            table_of_rowid;
  t_intl_text_id     table_of_number;
  t_model_id         table_of_number;
  t_message          table_of_varchar;
  t_orig_sys_ref     table_of_varchar;
  t_language         table_of_varchar;
  t_rec_status       table_of_varchar;
  t_disposition      table_of_varchar;

  resolveIntlTextId  VARCHAR2(4000) :=
    'SELECT intl_text_id ' ||
    '   FROM cz_localized_texts ' ||
    '  WHERE deleted_flag = ''' || CZRI_FLAG_NOT_DELETED || '''  ' ||
    '    AND model_id = :1 ' ||
    '    AND language = :2 ' ||
    '    AND orig_sys_ref = :3';

  getIntlTextId  VARCHAR2(4000) :=
    'SELECT intl_text_id ' ||
    '   FROM cz_localized_texts ' ||
    '  WHERE deleted_flag = ''' || CZRI_FLAG_NOT_DELETED || '''  ' ||
    '    AND model_id = :1 ' ||
    '    AND orig_sys_ref = :2 ' ||
    '    AND ROWNUM = 1';

  last_orig_sys_ref  cz_imp_localized_texts.orig_sys_ref%TYPE;
  last_model_id      cz_imp_localized_texts.model_id%TYPE;
  last_language      cz_imp_localized_texts.language%TYPE;
  last_intl_text_id  cz_imp_localized_texts.intl_text_id%TYPE;

  last_id_allocated  NUMBER := NULL;
  next_id_to_use     NUMBER := 0;
  id_increment       NUMBER := CZRI_LOCALIZED_TEXTS_INC;
---------------------------------------------------------------------------------------
  PROCEDURE update_table_data(p_upper_limit IN PLS_INTEGER) IS
  BEGIN

    FORALL i IN 1..p_upper_limit
      UPDATE cz_imp_localized_texts SET
        intl_text_id = t_intl_text_id(i),
        message = t_message(i),
        rec_status = CZRI_RECSTATUS_KRS,
        disposition = t_disposition(i)
      WHERE ROWID = t_rowid(i);
  END;
---------------------------------------------------------------------------------------
FUNCTION next_intl_text_id RETURN NUMBER IS
  id_to_return      NUMBER;
BEGIN

  IF((last_id_allocated IS NULL) OR
     (next_id_to_use = (NVL(last_id_allocated, 0) + id_increment)))THEN

    SELECT cz_intl_texts_s.NEXTVAL INTO last_id_allocated FROM dual;
    next_id_to_use := last_id_allocated;
  END IF;

  id_to_return := next_id_to_use;
  next_id_to_use := next_id_to_use + 1;
 RETURN id_to_return;
END;
---------------------------------------------------------------------------------------
BEGIN

  OPEN c_rec;
  LOOP

    t_rowid.DELETE;
    t_intl_text_id.DELETE;
    t_model_id.DELETE;
    t_message.DELETE;
    t_orig_sys_ref.DELETE;
    t_language.DELETE;
    t_rec_status.DELETE;
    t_disposition.DELETE;

    FETCH c_rec BULK COLLECT INTO
      t_rowid, t_intl_text_id, t_model_id, t_message, t_orig_sys_ref, t_language, t_rec_status, t_disposition
    LIMIT p_commit_size;
    EXIT WHEN c_rec%NOTFOUND AND t_rowid.COUNT = 0;

    FOR i IN 1..t_rowid.COUNT LOOP

      t_message(i) := NULL;

      IF(last_orig_sys_ref IS NOT NULL AND
         last_orig_sys_ref = t_orig_sys_ref(i) AND
         last_model_id = t_model_id(i) AND
         last_language = t_language(i))THEN

        --This is a duplicate record in the source data.

        t_message(i) := cz_utils.get_text('CZRI_TXT_DUPLICATE', 'MODELID', last_model_id);
        t_disposition(i) := CZRI_DISPOSITION_REJECT;
      END IF;

      IF(t_disposition(i) = CZRI_DISPOSITION_PASSED)THEN

        --Resolve intl_text_id for existing record or generate a new one for a new record.

        BEGIN
          EXECUTE IMMEDIATE resolveIntlTextId INTO t_intl_text_id(i)
                      USING t_model_id(i), t_language(i), t_orig_sys_ref(i);

          t_disposition(i) := CZRI_DISPOSITION_MODIFY;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            t_disposition(i) := CZRI_DISPOSITION_INSERT;

            --Bug #4053091 - need to share intl_text_id between all the records with same orig_sys_ref.

            BEGIN
              EXECUTE IMMEDIATE getIntlTextId INTO t_intl_text_id(i)
                          USING t_model_id(i), t_orig_sys_ref(i);
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                IF(last_orig_sys_ref IS NOT NULL AND last_orig_sys_ref = t_orig_sys_ref(i) AND
                   last_model_id = t_model_id(i))THEN

                   t_intl_text_id(i) := last_intl_text_id;
                ELSE

                   t_intl_text_id(i) := next_intl_text_id;
                END IF;
            END;
        END;
      END IF;

      IF(t_disposition(i) <> CZRI_DISPOSITION_REJECT)THEN

        last_orig_sys_ref := t_orig_sys_ref(i);
        last_model_id := t_model_id(i);
        last_language := t_language(i);
        last_intl_text_id := t_intl_text_id(i);
      END IF;

      IF(t_disposition(i) = CZRI_DISPOSITION_REJECT)THEN

        p_errors := p_errors + 1;

        IF(p_errors > CZRI_MAXIMUM_ERRORS)THEN

          --Update the already processed records here.

          update_table_data(i);
          COMMIT;
          RAISE CZRI_ERR_MAXIMUM_ERRORS;
        END IF;
      END IF;
    END LOOP;

    --Update all the records from memory here.

    update_table_data(t_rowid.COUNT);
    COMMIT;
  END LOOP;

  CLOSE c_rec;
EXCEPTION
  WHEN CZRI_ERR_MAXIMUM_ERRORS THEN --maximum errors number exceeded.
    CLOSE c_rec;
    x_msg_data := cz_utils.get_text('CZRI_IMP_MAXIMUMERRORS', 'RUNID', p_run_id);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'krs_localized_texts', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_FATAL_ERROR;
  WHEN OTHERS THEN --unexpected errors occurred in the procedure.
    CLOSE c_rec;
    x_msg_data := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'krs_localized_texts', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_FATAL_ERROR;
END;
---------------------------------------------------------------------------------------
PROCEDURE xfr_localized_texts(p_api_version    IN NUMBER,
                              p_run_id         IN NUMBER,
                              p_maximum_errors IN PLS_INTEGER,
                              p_commit_size    IN PLS_INTEGER,
                              p_errors         IN OUT NOCOPY PLS_INTEGER,
                              x_return_status  IN OUT NOCOPY VARCHAR2,
                              x_msg_count      IN OUT NOCOPY NUMBER,
                              x_msg_data       IN OUT NOCOPY VARCHAR2) IS

  v_debug   NUMBER := 4000;

  --persistent_intl_text_id is taken care of by a trigger.

  CURSOR c_rec IS
    SELECT ROWID,last_update_login, locale_id, localized_str, intl_text_id, deleted_flag, security_mask,
           checkout_user, orig_sys_ref, language, source_lang, model_id, seeded_flag,
           disposition, message
      FROM cz_imp_localized_texts
     WHERE run_id = p_run_id
       AND rec_status = CZRI_RECSTATUS_KRS
       AND disposition IN (CZRI_DISPOSITION_INSERT, CZRI_DISPOSITION_MODIFY);

  t_rowid             table_of_rowid;
  t_last_update_login table_of_number;
  t_locale_id         table_of_number;
  t_localized_str     table_of_varchar;
  t_intl_text_id      table_of_number;
  t_deleted_flag      table_of_varchar;
  t_security_mask     table_of_varchar;
  t_checkout_user     table_of_varchar;
  t_orig_sys_ref      table_of_varchar;
  t_language          table_of_varchar;
  t_source_lang       table_of_varchar;
  t_model_id          table_of_number;
  t_seeded_flag       table_of_varchar;
  t_disposition       table_of_varchar;
  t_message           table_of_varchar;
---------------------------------------------------------------------------------------
  PROCEDURE update_table_data(p_upper_limit IN PLS_INTEGER) IS
  BEGIN

    --We updating rec_status to OK, not XFR, because, unlike the rules which still have
    --to be parsed, import of localized texts is done.

    FORALL i IN 1..p_upper_limit
      UPDATE cz_imp_localized_texts SET
        message = t_message(i),
        rec_status = CZRI_RECSTATUS_OK,
        disposition = t_disposition(i)
      WHERE ROWID = t_rowid(i);
  END;
---------------------------------------------------------------------------------------
 FUNCTION insert_online_data(p_upper_limit IN PLS_INTEGER) RETURN BOOLEAN IS

    t_last_update_login table_of_number;
    t_locale_id         table_of_number;
    t_localized_str     table_of_varchar;
    t_intl_text_id      table_of_number;
    t_deleted_flag      table_of_varchar;
    t_security_mask     table_of_varchar;
    t_checkout_user     table_of_varchar;
    t_orig_sys_ref      table_of_varchar;
    t_language          table_of_varchar;
    t_source_lang       table_of_varchar;
    t_model_id          table_of_number;
    t_seeded_flag       table_of_varchar;

    v_index             PLS_INTEGER := 1;
  BEGIN

    FOR i IN 1..p_upper_limit LOOP

      IF(t_disposition(i) = CZRI_DISPOSITION_INSERT)THEN

        t_last_update_login(v_index) := xfr_localized_texts.t_last_update_login(i);
        t_locale_id(v_index) := xfr_localized_texts.t_locale_id(i);
        t_localized_str(v_index) := xfr_localized_texts.t_localized_str(i);
        t_intl_text_id(v_index) := xfr_localized_texts.t_intl_text_id(i);
        t_deleted_flag(v_index) := xfr_localized_texts.t_deleted_flag(i);
        t_security_mask(v_index) := xfr_localized_texts.t_security_mask(i);
        t_checkout_user(v_index) := xfr_localized_texts.t_checkout_user(i);
        t_orig_sys_ref(v_index) := xfr_localized_texts.t_orig_sys_ref(i);
        t_language(v_index) := xfr_localized_texts.t_language(i);
        t_source_lang(v_index) := xfr_localized_texts.t_source_lang(i);
        t_model_id(v_index) := xfr_localized_texts.t_model_id(i);
        t_seeded_flag(v_index) := xfr_localized_texts.t_seeded_flag(i);

        v_index := v_index + 1;
      END IF;
    END LOOP;

    FORALL i IN 1..t_intl_text_id.COUNT
      INSERT INTO cz_localized_texts
        (last_update_login, locale_id, localized_str, intl_text_id, deleted_flag, security_mask,
         checkout_user, orig_sys_ref, language, source_lang, model_id, seeded_flag)
      VALUES
        (t_last_update_login(i), t_locale_id(i), t_localized_str(i), t_intl_text_id(i),
         t_deleted_flag(i), t_security_mask(i), t_checkout_user(i), t_orig_sys_ref(i),
         t_language(i), t_source_lang(i), t_model_id(i), t_seeded_flag(i));

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END;
---------------------------------------------------------------------------------------
 FUNCTION update_online_data(p_upper_limit IN PLS_INTEGER) RETURN BOOLEAN IS

    t_last_update_login table_of_number;
    t_locale_id         table_of_number;
    t_localized_str     table_of_varchar;
    t_intl_text_id      table_of_number;
    t_deleted_flag      table_of_varchar;
    t_security_mask     table_of_varchar;
    t_checkout_user     table_of_varchar;
    t_orig_sys_ref      table_of_varchar;
    t_language          table_of_varchar;
    t_source_lang       table_of_varchar;
    t_model_id          table_of_number;
    t_seeded_flag       table_of_varchar;

    v_index             PLS_INTEGER := 1;
  BEGIN

    FOR i IN 1..p_upper_limit LOOP

      IF(t_disposition(i) = CZRI_DISPOSITION_MODIFY)THEN

        t_last_update_login(v_index) := xfr_localized_texts.t_last_update_login(i);
        t_locale_id(v_index) := xfr_localized_texts.t_locale_id(i);
        t_localized_str(v_index) := xfr_localized_texts.t_localized_str(i);
        t_intl_text_id(v_index) := xfr_localized_texts.t_intl_text_id(i);
        t_deleted_flag(v_index) := xfr_localized_texts.t_deleted_flag(i);
        t_security_mask(v_index) := xfr_localized_texts.t_security_mask(i);
        t_checkout_user(v_index) := xfr_localized_texts.t_checkout_user(i);
        t_orig_sys_ref(v_index) := xfr_localized_texts.t_orig_sys_ref(i);
        t_language(v_index) := xfr_localized_texts.t_language(i);
        t_source_lang(v_index) := xfr_localized_texts.t_source_lang(i);
        t_model_id(v_index) := xfr_localized_texts.t_model_id(i);
        t_seeded_flag(v_index) := xfr_localized_texts.t_seeded_flag(i);

        v_index := v_index + 1;
      END IF;
    END LOOP;

    FORALL i IN 1..t_intl_text_id.COUNT
      UPDATE cz_localized_texts SET
        last_update_login = t_last_update_login(i),
        locale_id = t_locale_id(i),
        localized_str = t_localized_str(i),
        deleted_flag = t_deleted_flag(i),
        security_mask = t_security_mask(i),
        checkout_user = t_checkout_user(i),
        orig_sys_ref = t_orig_sys_ref(i),
        source_lang = t_source_lang(i),
        model_id = t_model_id(i),
        seeded_flag = t_seeded_flag(i)
      WHERE intl_text_id = t_intl_text_id(i)
        AND language = t_language(i);

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END;
---------------------------------------------------------------------------------------
BEGIN
  OPEN c_rec;
  LOOP

    t_rowid.DELETE;
    t_last_update_login.DELETE;
    t_locale_id.DELETE;
    t_localized_str.DELETE;
    t_intl_text_id.DELETE;
    t_deleted_flag.DELETE;
    t_security_mask.DELETE;
    t_checkout_user.DELETE;
    t_orig_sys_ref.DELETE;
    t_language.DELETE;
    t_source_lang.DELETE;
    t_model_id.DELETE;
    t_seeded_flag.DELETE;
    t_disposition.DELETE;
    t_message.DELETE;

    FETCH c_rec BULK COLLECT INTO
      t_rowid, t_last_update_login, t_locale_id, t_localized_str, t_intl_text_id, t_deleted_flag,
      t_security_mask, t_checkout_user, t_orig_sys_ref, t_language, t_source_lang, t_model_id,
      t_seeded_flag, t_disposition, t_message
    LIMIT p_commit_size;
    EXIT WHEN c_rec%NOTFOUND AND t_rowid.COUNT = 0;

    FOR i IN 1..t_rowid.COUNT LOOP

      t_message(i) := NULL;
    END LOOP;

    IF(NOT insert_online_data(t_rowid.COUNT))THEN

      FOR i IN 1..t_rowid.COUNT LOOP

        IF(t_disposition(i) = CZRI_DISPOSITION_INSERT)THEN

          BEGIN
            INSERT INTO cz_localized_texts
             (last_update_login, locale_id, localized_str, intl_text_id, deleted_flag, security_mask,
              checkout_user, orig_sys_ref, language, source_lang, model_id, seeded_flag)
            VALUES
             (t_last_update_login(i), t_locale_id(i), t_localized_str(i), t_intl_text_id(i),
              t_deleted_flag(i), t_security_mask(i), t_checkout_user(i), t_orig_sys_ref(i),
              t_language(i), t_source_lang(i), t_model_id(i), t_seeded_flag(i));

          EXCEPTION
            WHEN OTHERS THEN
              t_message(i) := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
              t_disposition(i) := CZRI_DISPOSITION_REJECT;
          END;
        END IF;

        IF(t_disposition(i) = CZRI_DISPOSITION_REJECT)THEN

          p_errors := p_errors + 1;

          IF(p_errors > CZRI_MAXIMUM_ERRORS)THEN

            --Update the already processed records here.

            update_table_data(i);
            COMMIT;
            RAISE CZRI_ERR_MAXIMUM_ERRORS;
          END IF;
        END IF;
      END LOOP;
    END IF;

    IF(NOT update_online_data(t_rowid.COUNT))THEN

      FOR i IN 1..t_rowid.COUNT LOOP

        IF(t_disposition(i) = CZRI_DISPOSITION_MODIFY)THEN

          BEGIN
            UPDATE cz_localized_texts SET
              last_update_login = t_last_update_login(i),
              locale_id = t_locale_id(i),
              localized_str = t_localized_str(i),
              deleted_flag = t_deleted_flag(i),
              security_mask = t_security_mask(i),
              checkout_user = t_checkout_user(i),
              orig_sys_ref = t_orig_sys_ref(i),
              source_lang = t_source_lang(i),
              model_id = t_model_id(i),
              seeded_flag = t_seeded_flag(i)
            WHERE intl_text_id = t_intl_text_id(i)
              AND language = t_language(i);

          EXCEPTION
            WHEN OTHERS THEN
              t_message(i) := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
              t_disposition(i) := CZRI_DISPOSITION_REJECT;
          END;
        END IF;

        IF(t_disposition(i) = CZRI_DISPOSITION_REJECT)THEN

          p_errors := p_errors + 1;

          IF(p_errors > CZRI_MAXIMUM_ERRORS)THEN

            --Update the already processed records here.

            update_table_data(i);
            COMMIT;
            RAISE CZRI_ERR_MAXIMUM_ERRORS;
          END IF;
        END IF;
      END LOOP;
    END IF;

    update_table_data(t_rowid.COUNT);
    COMMIT;
  END LOOP;

  CLOSE c_rec;
EXCEPTION
  WHEN CZRI_ERR_MAXIMUM_ERRORS THEN --maximum errors number exceeded.
    CLOSE c_rec;
    x_msg_data := cz_utils.get_text('CZRI_IMP_MAXIMUMERRORS', 'RUNID', p_run_id);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'xfr_localized_texts', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_FATAL_ERROR;
  WHEN OTHERS THEN --unexpected errors occurred in the procedure.
    CLOSE c_rec;
    x_msg_data := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'xfr_localized_texts', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_FATAL_ERROR;
END;
---------------------------------------------------------------------------------------
PROCEDURE rpt_localized_texts(p_api_version   IN NUMBER,
                              p_run_id        IN NUMBER,
                              x_return_status IN OUT NOCOPY VARCHAR2,
                              x_msg_count     IN OUT NOCOPY NUMBER,
                              x_msg_data      IN OUT NOCOPY VARCHAR2) IS

  v_debug   NUMBER := 5000;
BEGIN

  FOR c_stat IN (SELECT disposition, rec_status, COUNT(*) as records
                   FROM cz_imp_localized_texts
                  WHERE run_id = p_run_id
                    AND rec_status IS NOT NULL
                    AND disposition IS NOT NULL
                  GROUP BY disposition, rec_status) LOOP

    INSERT INTO cz_xfr_run_results (run_id, imp_table, disposition, rec_status, records)
    VALUES (p_run_id, 'CZ_IMP_LOCALIZED_TEXTS', c_stat.disposition, c_stat.rec_status, c_stat.records);
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN --unexpected errors occurred in the procedure.
    x_msg_data := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'rpt_localized_texts', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE CZRI_ERR_REPORT_ERROR;
END;
---------------------------------------------------------------------------------------
PROCEDURE restat_localized_texts(p_api_version   IN NUMBER,
                                 p_run_id        IN NUMBER,
                                 x_return_status IN OUT NOCOPY VARCHAR2,
                                 x_msg_count     IN OUT NOCOPY NUMBER,
                                 x_msg_data      IN OUT NOCOPY VARCHAR2) IS

  v_debug   NUMBER := 10000;
BEGIN

  DELETE FROM cz_xfr_run_results WHERE run_id = p_run_id;
  rpt_localized_texts(p_api_version, p_run_id, x_return_status, x_msg_count, x_msg_data);
END;
---------------------------------------------------------------------------------------
PROCEDURE import_localized_texts(p_api_version    IN NUMBER,
                                 p_run_id         IN NUMBER,
                                 p_maximum_errors IN PLS_INTEGER,
                                 p_commit_size    IN PLS_INTEGER,
                                 p_errors         IN OUT NOCOPY PLS_INTEGER,
                                 x_return_status  IN OUT NOCOPY VARCHAR2,
                                 x_msg_count      IN OUT NOCOPY NUMBER,
                                 x_msg_data       IN OUT NOCOPY VARCHAR2) IS
BEGIN

  cnd_localized_texts(p_api_version,
                      p_run_id,
                      p_maximum_errors,
                      p_commit_size,
                      p_errors,
                      x_return_status,
                      x_msg_count,
                      x_msg_data);

  krs_localized_texts(p_api_version,
                      p_run_id,
                      p_maximum_errors,
                      p_commit_size,
                      p_errors,
                      x_return_status,
                      x_msg_count,
                      x_msg_data);

  xfr_localized_texts(p_api_version,
                      p_run_id,
                      p_maximum_errors,
                      p_commit_size,
                      p_errors,
                      x_return_status,
                      x_msg_count,
                      x_msg_data);

  rpt_localized_texts(p_api_version,
                      p_run_id,
                      x_return_status,
                      x_msg_count,
                      x_msg_data);

EXCEPTION
  WHEN CZRI_ERR_REPORT_ERROR THEN
    RAISE CZRI_ERR_FATAL_ERROR;
  WHEN OTHERS THEN
    rpt_localized_texts(p_api_version,
                        p_run_id,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);
    RAISE;
END;
---------------------------------------------------------------------------------------
PROCEDURE refresh_statistics(p_api_version   IN NUMBER,
                             p_run_id        IN NUMBER,
                             x_return_status IN OUT NOCOPY VARCHAR2,
                             x_msg_count     IN OUT NOCOPY NUMBER,
                             x_msg_data      IN OUT NOCOPY VARCHAR2) IS

  v_debug   NUMBER := 12000;
BEGIN

  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  restat_localized_texts(p_api_version, p_run_id, x_return_status, x_msg_count, x_msg_data);
  restat_rules(p_api_version, p_run_id, x_return_status, x_msg_count, x_msg_data);

EXCEPTION
  WHEN CZRI_ERR_REPORT_ERROR THEN
    --All the logging has already been done.
    NULL;
  WHEN OTHERS THEN
    x_msg_data := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'refresh_statistics', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;
---------------------------------------------------------------------------------------
PROCEDURE rule_import(p_api_version    IN NUMBER,
                      p_run_id         IN OUT NOCOPY NUMBER,
                      p_maximum_errors IN PLS_INTEGER,
                      p_commit_size    IN PLS_INTEGER,
                      x_return_status  IN OUT NOCOPY VARCHAR2,
                      x_msg_count      IN OUT NOCOPY NUMBER,
                      x_msg_data       IN OUT NOCOPY VARCHAR2) IS

  v_errors         PLS_INTEGER;
  v_error_flag     PLS_INTEGER;
  v_null           PLS_INTEGER;
  v_api_version    NUMBER          := p_api_version;
  v_maximum_errors PLS_INTEGER     := p_maximum_errors;
  v_commit_size    PLS_INTEGER     := p_commit_size;
  v_debug          NUMBER          := 1000;
BEGIN

  --Initialize the FND message stack.

  FND_MSG_PUB.INITIALIZE;

  --Check for other active import sessions.

  BEGIN

    SELECT NULL INTO v_null FROM v$session WHERE module = CZRI_MODULE_NAME;
    RAISE CZRI_ERR_ACTIVE_SESSIONS;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      --Set the application module name.

      DBMS_APPLICATION_INFO.SET_MODULE(CZRI_MODULE_NAME,'');
  END;

  --Default the parameters.

  IF(v_api_version IS NULL OR v_api_version <= 0)THEN v_api_version := CZRI_API_VERSION; END IF;
  IF(v_maximum_errors IS NULL OR v_maximum_errors <= 0)THEN v_maximum_errors := CZRI_MAXIMUM_ERRORS; END IF;
  IF(v_commit_size IS NULL OR v_commit_size <= 0)THEN v_commit_size := CZRI_COMMIT_SIZE; END IF;

  --Initialize error counter and output parameters.

  v_errors := 0;
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --If necessary, generate a run_id and update the source records with this value.

  IF(p_run_id IS NULL)THEN

    SELECT cz_xfr_run_infos_s.NEXTVAL INTO p_run_id FROM DUAL;

    UPDATE cz_imp_rules SET run_id = p_run_id
     WHERE disposition IS NULL
       AND rec_status IS NULL
       AND run_id IS NULL;

    UPDATE cz_imp_localized_texts SET run_id = p_run_id
     WHERE disposition IS NULL
       AND rec_status IS NULL
       AND run_id IS NULL;

    COMMIT;
  END IF;

  BEGIN

    SELECT 1 INTO v_error_flag FROM DUAL WHERE EXISTS
      (SELECT NULL FROM cz_imp_rules WHERE run_id = p_run_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_error_flag := 0;
  END;

  --Raise an error if there is no data for the specified run_id.

  IF(v_error_flag = 0)THEN RAISE CZRI_ERR_RUNID_INCORRECT; END IF;

  --Create a control record for the current session.

  BEGIN

    SELECT NULL INTO v_null FROM cz_xfr_run_infos WHERE run_id = p_run_id;
    RAISE CZRI_ERR_RUNID_EXISTS;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

      INSERT INTO cz_xfr_run_infos (run_id, started, last_activity, completed)
      VALUES (p_run_id, SYSDATE, SYSDATE, '0');
  END;

  --Call the import procedures.

  import_localized_texts(v_api_version,
                         p_run_id,
                         v_maximum_errors,
                         v_commit_size,
                         v_errors,
                         x_return_status,
                         x_msg_count,
                         x_msg_data);

  import_rules(v_api_version,
               p_run_id,
               v_maximum_errors,
               v_commit_size,
               v_errors,
               x_return_status,
               x_msg_count,
               x_msg_data);

  --Update the control record for this session.

  UPDATE cz_xfr_run_infos SET
    last_activity = SYSDATE,
    completed = '1'
  WHERE run_id = p_run_id;

  --IF there were any errors, the return status will be 'Warning', not 'Success'.

  IF(v_errors > 0)THEN x_return_status := FND_API.G_RET_STS_ERROR; END IF;

  --If there were no successfully transferred rules, the return status will be 'Error'.

  BEGIN

    SELECT 1 INTO v_error_flag FROM DUAL WHERE EXISTS
      (SELECT NULL FROM cz_imp_rules
        WHERE run_id = p_run_id
          AND rec_status = CZRI_RECSTATUS_XFR
          AND disposition IN (CZRI_DISPOSITION_INSERT, CZRI_DISPOSITION_MODIFY));

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_error_flag := 0;
  END;

  IF(v_error_flag = 0)THEN RAISE CZRI_ERR_DATA_INCORRECT; END IF;

  --Reset the application module name.

  DBMS_APPLICATION_INFO.SET_MODULE('','');

EXCEPTION
  WHEN CZRI_ERR_ACTIVE_SESSIONS THEN
    x_msg_data := cz_utils.get_text('CZRI_IMP_ACTIVESESSION', 'RUNID', p_run_id);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'rule_import', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    DBMS_APPLICATION_INFO.SET_MODULE('','');
  WHEN CZRI_ERR_RUNID_EXISTS THEN
    x_msg_data := cz_utils.get_text('CZRI_IMP_RUNID_EXISTS', 'RUNID', p_run_id);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'rule_import', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    DBMS_APPLICATION_INFO.SET_MODULE('','');
  WHEN CZRI_ERR_RUNID_INCORRECT THEN
    x_msg_data := cz_utils.get_text('CZRI_ERR_RUNID_INCORRECT', 'RUNID', p_run_id);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'rule_import', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    DBMS_APPLICATION_INFO.SET_MODULE('','');
  WHEN CZRI_ERR_DATA_INCORRECT THEN
    x_msg_data := cz_utils.get_text('CZRI_ERR_DATA_INCORRECT', 'RUNID', p_run_id);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'rule_import', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    DBMS_APPLICATION_INFO.SET_MODULE('','');
  WHEN CZRI_ERR_FATAL_ERROR THEN
    --hard errors occurred in underlying procedures, already logged.
    DBMS_APPLICATION_INFO.SET_MODULE('','');
  WHEN OTHERS THEN
    --unexpected errors occurred in the procedure.
    x_msg_data := cz_utils.get_text('CZRI_IMP_SQLERROR', 'ERRORTEXT', SQLERRM);
    x_msg_count := 1;
    report(x_msg_data, p_run_id, 'rule_import', v_debug);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    DBMS_APPLICATION_INFO.SET_MODULE('','');
END;

-----------------------
--------------procedures for lock, unlock
PROCEDURE lock_models (p_api_version    IN NUMBER,
                p_run_id          IN NUMBER,
		    p_commit_flag     IN VARCHAR2,
                x_locked_entities OUT NOCOPY SYSTEM.CZ_NUMBER_TBL_TYPE,
                x_return_status   OUT NOCOPY VARCHAR2,
                x_msg_count       OUT NOCOPY NUMBER,
                x_msg_data        OUT NOCOPY VARCHAR2)
IS

l_locked_entities cz_security_pvt.number_type_tbl;
l_model_id_tbl  table_of_number;
rec_count       NUMBER;
MODEL_IS_LOCKED EXCEPTION;

BEGIN
   ----initialize FND stack
   FND_MSG_PUB.initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_data      := NULL;
   x_msg_count     := 0;
   x_locked_entities := SYSTEM.CZ_NUMBER_TBL_TYPE();

  IF (p_run_id IS NULL) THEN
     SELECT distinct devl_project_id
     BULK
     COLLECT
     INTO   l_model_id_tbl
     FROM   cz_imp_rules
     WHERE  rec_status IS NULL
     AND    disposition IS NULL
     AND    run_id IS NULL;
  ELSE
     SELECT distinct devl_project_id
     BULK
     COLLECT
     INTO   l_model_id_tbl
     FROM   cz_imp_rules
     WHERE  rec_status IS NULL
     AND    disposition IS NULL
     AND    run_id = p_run_id;
  END IF;

 IF (l_model_id_tbl.COUNT > 0) THEN
  FOR I IN l_model_id_tbl.FIRST..l_model_id_tbl.LAST
  LOOP
	cz_security_pvt.lock_model(1.0,
                               l_model_id_tbl(i),
                               FND_API.G_FALSE,
                               FND_API.G_FALSE,
                               FND_API.G_FALSE,
                               l_locked_entities,
                               x_return_status,
                               x_msg_count,
                               x_msg_data);

	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
   		  RAISE MODEL_IS_LOCKED;
      ELSE
          IF (l_locked_entities.COUNT > 0) THEN
              x_locked_entities.EXTEND(1);
              rec_count := x_locked_entities.COUNT;
              x_locked_entities(rec_count) := l_model_id_tbl(i);
          END IF;
       END IF;
   END LOOP;
 END IF;
 IF (p_commit_flag = FND_API.G_TRUE) THEN COMMIT; END IF;
EXCEPTION
WHEN MODEL_IS_LOCKED THEN
   fnd_msg_pub.count_and_get(FND_API.G_FALSE, x_msg_count, x_msg_data);
WHEN NO_DATA_FOUND THEN
   NULL;
WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   fnd_msg_pub.add_exc_msg('CZ_RULE_IMPORT', 'lock_models');
   fnd_msg_pub.count_and_get(FND_API.G_FALSE, x_msg_count, x_msg_data);
END lock_models;

END;

/
