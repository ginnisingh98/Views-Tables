--------------------------------------------------------
--  DDL for Package Body GME_TRANSFORM_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_TRANSFORM_BATCH" AS
/* $Header: GMEVTRFB.pls 120.4 2006/09/20 18:38:31 creddy noship $ */

/***********************************************************/
-- Oracle Process Manufacturing Process Execution APIs
--
-- File Name:   GMEVTRFB.pls
-- Contents:    Package body for GME data transformation
-- Description:
--   This package transforms GME data from 11.5.10 to
--   12.

/**********************************************************/

   PROCEDURE gme_migration (p_migration_run_id   IN              NUMBER,
                            p_commit             IN              VARCHAR2,
                            x_failure_count      OUT NOCOPY      NUMBER) IS
   BEGIN
      gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_procedure,
                   p_message_token       => 'GMA_MIGRATION_TABLE_STARTED',
                   p_table_name          => 'GME_PARAMETERS',
                   p_context             => 'PROFILES',
                   p_app_short_name      => 'GMA');
      create_gme_parameters(p_migration_run_id => p_migration_run_id,
                            x_exception_count  => x_failure_count);

      gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_procedure,
                   p_message_token       => 'GMA_MIGRATION_TABLE_STARTED',
                   p_table_name          => 'GME_BATCH_HEADER',
                   p_context             => 'UPDATE_LAB_IND',
                   p_app_short_name      => 'GMA');
      update_batch_header(p_migration_run_id => p_migration_run_id,
                          x_exception_count  => x_failure_count);

      gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_procedure,
                   p_message_token       => 'GMA_MIGRATION_TABLE_STARTED',
                   p_table_name          => 'WIP_ENTITIES',
                   p_context             => 'CREATE_WIP_ENTITY',
                   p_app_short_name      => 'GMA');
      update_wip_entities(p_migration_run_id => p_migration_run_id,
                          x_exception_count  => x_failure_count);


      gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_procedure,
                   p_message_token       => 'GMA_MIGRATION_TABLE_STARTED',
                   p_table_name          => 'GME_GANTT_DOCUMENT_FILTER',
                   p_context             => 'GANTT FILTERS',
                   p_app_short_name      => 'GMA');
      update_from_doc_no(p_migration_run_id);

      gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_procedure,
                   p_message_token       => 'GMA_MIGRATION_TABLE_STARTED',
                   p_table_name          => 'GME_RESOURCE_TXNS',
                   p_context             => 'REASON_ID',
                   p_app_short_name      => 'GMA');
      update_reason_id(p_migration_run_id);

      IF p_commit = 'Y' THEN
         COMMIT;
      END IF;
   END gme_migration;

   FUNCTION get_profile_value (v_profile_name IN VARCHAR2, v_appl_id IN NUMBER)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN fnd_profile.VALUE (v_profile_name);
   END get_profile_value;

   PROCEDURE create_gme_parameters(p_migration_run_id IN NUMBER,
                                   x_exception_count  OUT NOCOPY NUMBER) IS
      CURSOR get_plant_and_labs IS
         SELECT sy.organization_id, sy.orgn_code plant_code
           FROM sy_orgn_mst sy
          WHERE NOT EXISTS (SELECT 1
                            FROM   gme_parameters
                            WHERE  organization_id = sy.organization_id)
                AND sy.organization_id IS NOT NULL;

      CURSOR get_doc_numbering (v_doc_type IN VARCHAR2, v_plant_code IN VARCHAR2) IS
         SELECT assignment_type, last_assigned
           FROM sy_docs_seq
          WHERE orgn_code = v_plant_code AND doc_type = v_doc_type;

      l_fpo_assignment     NUMBER;
      l_batch_assignment   NUMBER;
      l_fpo_number         NUMBER;
      l_batch_number       NUMBER;
      l_count              NUMBER := 0;
   BEGIN
      FOR rec IN get_plant_and_labs LOOP
      	BEGIN
         OPEN get_doc_numbering ('FPO', rec.plant_code);
         FETCH get_doc_numbering INTO l_fpo_assignment, l_fpo_number;
         CLOSE get_doc_numbering;
         OPEN get_doc_numbering ('PROD', rec.plant_code);
         FETCH get_doc_numbering INTO l_batch_assignment, l_batch_number;
         CLOSE get_doc_numbering;

         INSERT INTO gme_parameters
                     (organization_id, auto_consume_supply_sub_only,
                      supply_subinventory, supply_locator_id,
                      yield_subinventory, yield_locator_id,
                      delete_material_ind,
                      validate_plan_dates_ind,
                      display_unconsumed_material,
                      step_controls_batch_sts_ind,
                      backflush_rsrc_usg_ind,
                      def_actual_rsrc_usg_ind,
                      calc_interim_rsrc_usg_ind,
                      allow_qty_below_min_ind,
                      display_non_work_days_ind,
                      check_shortages_ind,
                      copy_formula_text_ind,
                      copy_routing_text_ind,
                      create_high_level_resv_ind, create_move_orders_ind,
                      reservation_timefence, move_order_timefence,
                      batch_doc_numbering,
                      batch_no_last_assigned, fpo_doc_numbering,
                      fpo_no_last_assigned, created_by, creation_date,
                      last_updated_by, last_update_login, last_update_date
                     )
              VALUES (rec.organization_id,
                      0, -- AUTO_CONSUME_SUPPLY_SUB_ONLY,
                      NULL, -- SUPPLY_SUBINVENTORY
                      NULL, -- SUPPLY_LOCATOR_ID
                      NULL, -- YIELD_SUBINVETORY
                      NULL, --YIELD_LOCATOR_ID
                      NVL(get_profile_value ('GME_ALLOW_MATERIAL_DELETION', 553),1),
                      NVL(get_profile_value ('GME_VALIDATE_PLAN_DATES', 553),1), --VALIDATE_PLAN_DATES_IND
                      1, --DISPLAY_UNCONSUMED_MATERIAL
                      NVL(DECODE (get_profile_value ('GME_STEP_CONTROL', 553), 'N', 0, 'Y', 1, 0),0),--STEP_CONTROLS_BATCH_STS_IND
                      NVL(get_profile_value ('GME_BACKFLUSH_USAGE', 553),0), --BACKFLUSH_RSRC_USG_IND
                      NVL(get_profile_value ('PM$DEFAULT_ACTUAL_RESOURCE_USAGE', 550),1), --DEF_ACTUAL_RSRC_USG_IND
                      NVL(get_profile_value ('GME_CALC_INT_RSRC_USAGE', 553),0), --CALC_INTERIM_RSRC_USG_IND
                      NVL(get_profile_value ('GME_ALLOW_QTY_BELOW_CAP', 553),1), --ALLOW_QTY_BELOW_MIN_IND
                      NVL(get_profile_value ('GME_DISP_NON_WORKING_DAYS_IN_GANTT', 553),1), --DISPLAY_NON_WORK_DAYS_IND
                      NVL(get_profile_value ('PM$CHECK_INV_SAVE', 550),0), --CHECK_SHORTAGES_IND
                      NVL(get_profile_value ('PM_COPY_FM_TEXT', 550),1), --COPY_FORMULA_TEXT_IND
                      NVL(get_profile_value ('GME_COPY_ROUTING_TEXT', 553),1), --COPY_ROUTING_TEXT_IND
                      0, --CREATE_HIGH_LEVEL_RESV_IND
                      0, --CREATE_MOVE_ORDERS_IND
                      NULL, --RESERVATION_TIMEFENCE
                      NULL, --MOVE_ORDER_TIMEFENCE
                      l_batch_assignment, --BATCH_DOC_NUMBERING
                      l_batch_number, --BATCH_NO_LAST_ASSIGNED
                      l_fpo_assignment, --FPO_DOC_NUMBERING
                      l_fpo_number, --FPO_NO_LAST_ASSIGNED
                      -1, --created_by
                      SYSDATE, --creation_date
                      -1, --last_updated_by
                      NULL, --last_update_login
                      SYSDATE --last_updated_date
                     );
              l_count := l_count + 1;
              gma_common_logging.gma_migration_central_log(p_run_id         => p_migration_run_id,
                                                           p_log_level      => fnd_log.level_procedure,
                                                           p_message_token  => 'GME_CREATE_PARAMS_SUCCESS',
                                                           p_table_name     => 'GME_PARAMETERS',
                                                           p_context        => 'PROFILES',
                                                           p_token1         => 'ORG_CODE',
                                                           p_param1         => rec.plant_code,
                                                           p_app_short_name => 'GME');
        EXCEPTION
          WHEN OTHERS THEN
            x_exception_count := x_exception_count + 1;
            gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_unexpected,
                   p_message_token       => 'GMA_MIGRATION_DB_ERROR',
                   p_table_name          => 'GME_PARAMETERS',
                   p_context             => 'PROFILES',
                   p_db_error            => SQLERRM,
                   p_app_short_name      => 'GMA');
            gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_unexpected,
                   p_message_token       => 'GMA_MIGRATION_TABLE_FAIL',
                   p_table_name          => 'GME_PARAMETERS',
                   p_context             => 'PROFILES',
                   p_app_short_name      => 'GMA');
         END;
      END LOOP;
      gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_procedure,
                   p_message_token       => 'GMA_MIGRATION_TABLE_SUCCESS',
                   p_table_name          => 'GME_PARAMETERS',
                   p_context             => 'PROFILES',
                   p_param1              => l_count,
                   p_app_short_name      => 'GMA');
    EXCEPTION
      WHEN OTHERS THEN
        x_exception_count := x_exception_count + 1;
        gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_unexpected,
                   p_message_token       => 'GMA_MIGRATION_DB_ERROR',
                   p_table_name          => 'GME_PARAMETERS',
                   p_context             => 'PROFILES',
                   p_db_error            => SQLERRM,
                   p_app_short_name      => 'GMA');
        gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_unexpected,
                   p_message_token       => 'GMA_MIGRATION_TABLE_FAIL',
                   p_table_name          => 'GME_PARAMETERS',
                   p_context             => 'PROFILES',
                   p_app_short_name      => 'GMA');
   END create_gme_parameters;

   PROCEDURE update_batch_header(p_migration_run_id IN NUMBER,
                                 x_exception_count  OUT NOCOPY NUMBER) IS
   BEGIN
      UPDATE gme_batch_header h
         SET laboratory_ind = (SELECT DECODE (org.plant_ind, 1, 0, 2, 1)
                               FROM sy_orgn_mst org
                               WHERE org.orgn_code = h.plant_code),
             migrated_batch_ind = 'Y'
      WHERE  laboratory_ind IS NULL;
      gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_procedure,
                   p_message_token       => 'GMA_MIGRATION_TABLE_SUCCESS',
                   p_table_name          => 'GME_BATCH_HEADER',
                   p_context             => 'UPDATE_LAB_IND',
                   p_param1              => SQL%ROWCOUNT,
                   p_app_short_name      => 'GMA');
   EXCEPTION
     WHEN OTHERS THEN
       x_exception_count := x_exception_count + 1;
       gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_unexpected,
                   p_message_token       => 'GMA_MIGRATION_DB_ERROR',
                   p_table_name          => 'GME_BATCH_HEADER',
                   p_context             => 'UPDATE_LAB_IND',
                   p_db_error            => SQLERRM,
                   p_app_short_name      => 'GMA');
       gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_unexpected,
                   p_message_token       => 'GMA_MIGRATION_TABLE_FAIL',
                   p_table_name          => 'GME_BATCH_HEADER',
                   p_context             => 'UPDATE_LAB_IND',
                   p_app_short_name      => 'GMA');
   END update_batch_header;

   PROCEDURE update_wip_entities(p_migration_run_id IN NUMBER,
                                 x_exception_count  OUT NOCOPY NUMBER) IS
      l_wip_entity_id   NUMBER;
      l_batch_id        NUMBER;
      l_count           NUMBER;
      l_batch_prefix    VARCHAR2(80);
      l_fpo_prefix      VARCHAR2(80);
      CURSOR get_batches IS
         SELECT batch_no, b.organization_id, batch_type, v.inventory_item_id
           FROM gme_batch_header b, gmd_recipe_validity_rules v
          WHERE b.recipe_validity_rule_id = v.recipe_validity_rule_id(+)
                AND b.organization_id IS NOT NULL
                AND DECODE(batch_type, 0, l_batch_prefix, l_fpo_prefix)||batch_no
                             NOT IN (SELECT wip_entity_name
                                     FROM   wip_entities
                                     WHERE  organization_id = b.organization_id
                                            AND ((b.batch_type = 0 AND entity_type = 10)
                                                  OR (b.batch_type = 10 AND entity_type = 9)));

   BEGIN
      l_count := 0;
      l_batch_prefix := NVL(get_profile_value ('GME_BATCH_PREFIX', 553),'BATCH');
      l_fpo_prefix   := NVL(get_profile_value ('GME_FPO_PREFIX', 553),'FPO');
      FOR rec IN get_batches LOOP
      	BEGIN
         INSERT INTO wip_entities
                     (wip_entity_id, organization_id,
                      last_update_date, last_updated_by, creation_date,
                      created_by, last_update_login, request_id,
                      program_application_id, program_id,
                      program_update_date, wip_entity_name,
                      entity_type, description,
                      primary_item_id, gen_object_id
                     )
              VALUES (wip_entities_s.NEXTVAL,
                      rec.organization_id, --ORGANIZATION_ID
                      SYSDATE, --LAST_UPDATE_DATE
                      1, --LAST_UPDATED_BY,
                      SYSDATE, --CREATION_DATE,
                      1, --CREATED_BY,
                      1, ---LAST_UPDATE_LOGIN,
                      NULL, --REQUEST_ID,
                      NULL, --PROGRAM_APPLICATION_ID,
                      NULL, --PROGRAM_ID,
                      NULL, --PROGRAM_UPDATE_DATE,
                      DECODE (rec.batch_type, 0, l_batch_prefix, l_fpo_prefix)||rec.batch_no, --WIP_ENTITY_NAME,
                      DECODE (rec.batch_type, 0, 10, 10, 9), --ENTITY_TYPE,
                      NULL, --DESCRIPTION,
                      rec.inventory_item_id, --PRIMARY_ITEM_ID,
                      mtl_gen_object_id_s.NEXTVAL); --GEN_OBJECT_ID
          l_count := l_count + 1;
        EXCEPTION
          WHEN OTHERS THEN
            x_exception_count := x_exception_count + 1;
            gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_unexpected,
                   p_message_token       => 'GMA_MIGRATION_DB_ERROR',
                   p_table_name          => 'WIP_ENTITIES',
                   p_context             => 'CREATE_WIP_ENTITY',
                   p_db_error            => SQLERRM,
                   p_app_short_name      => 'GMA');
            gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_unexpected,
                   p_message_token       => 'GMA_MIGRATION_TABLE_FAIL',
                   p_table_name          => 'WIP_ENTITIES',
                   p_context             => 'CREATE_WIP_ENTITY',
                   p_app_short_name      => 'GMA');
        END;
      END LOOP;
      SELECT MAX (wip_entity_id)
        INTO l_wip_entity_id
        FROM wip_entities;

      SELECT MAX (batch_id)
        INTO l_batch_id
        FROM gme_batch_header;

      WHILE l_wip_entity_id < l_batch_id LOOP
         SELECT wip_entities_s.NEXTVAL
           INTO l_wip_entity_id
           FROM DUAL;
      END LOOP;
      gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_procedure,
                   p_message_token       => 'GMA_MIGRATION_TABLE_SUCCESS',
                   p_table_name          => 'WIP_ENTITIES',
                   p_context             => 'CREATE_WIP_ENTITY',
                   p_token1              => 'PARAM1',
                   p_param1              => l_count,
                   p_app_short_name      => 'GMA');
   EXCEPTION
     WHEN OTHERS THEN
       x_exception_count := x_exception_count + 1;
       gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_unexpected,
                   p_message_token       => 'GMA_MIGRATION_DB_ERROR',
                   p_table_name          => 'WIP_ENTITIES',
                   p_context             => 'CREATE_WIP_ENTITY',
                   p_db_error            => SQLERRM,
                   p_app_short_name      => 'GMA');
       gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_unexpected,
                   p_message_token       => 'GMA_MIGRATION_TABLE_FAIL',
                   p_table_name          => 'WIP_ENTITIES',
                   p_context             => 'CREATE_WIP_ENTITY',
                   p_app_short_name      => 'GMA',
                   p_db_error            => SQLERRM);
   END update_wip_entities;

   PROCEDURE update_from_doc_no(p_migration_run_id NUMBER) IS
   BEGIN
      UPDATE gme_gantt_document_filter
      SET from_doc_no = document_no;
      gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_procedure,
                   p_message_token       => 'GMA_MIGRATION_TABLE_SUCCESS',
                   p_table_name          => 'GME_GANTT_DOCUMENT_FILTER',
                   p_context             => 'GANTT FILTERS',
                   p_param1              => SQL%ROWCOUNT,
                   p_app_short_name      => 'GMA');
   END update_from_doc_no;

   PROCEDURE update_reason_id(p_migration_run_id NUMBER) IS
   BEGIN
      UPDATE gme_resource_txns t
      SET reason_id = (SELECT reason_id FROM sy_reas_cds_b WHERE reason_code = t.reason_code);
      gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_procedure,
                   p_message_token       => 'GMA_MIGRATION_TABLE_SUCCESS',
                   p_table_name          => 'GME_RESOURCE_TXNS',
                   p_context             => 'REASON_ID',
                   p_param1              => SQL%ROWCOUNT,
                   p_app_short_name      => 'GMA');
      UPDATE gme_resource_txns_mig t
      SET reason_id = (SELECT reason_id FROM sy_reas_cds_b WHERE reason_code = t.reason_code);
      gma_common_logging.gma_migration_central_log
                  (p_run_id              => p_migration_run_id,
                   p_log_level           => fnd_log.level_procedure,
                   p_message_token       => 'GMA_MIGRATION_TABLE_SUCCESS',
                   p_table_name          => 'GME_RESOURCE_TXNS_MIG',
                   p_context             => 'REASON_ID',
                   p_param1              => SQL%ROWCOUNT,
                   p_app_short_name      => 'GMA');
   END update_reason_id;
END gme_transform_batch;

/
