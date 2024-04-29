--------------------------------------------------------
--  DDL for Package Body GCS_CONS_MONITOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GCS_CONS_MONITOR_PKG" AS
  /* $Header: gcscmb.pls 120.10 2007/03/22 12:45:55 vkosuri noship $ */

  --
  -- PRIVATE GLOBAL VARIABLES
  --

  -- The API name
  g_pkg_name CONSTANT VARCHAR2(30) := 'gcs.plsql.GCS_CONS_MONITOR_PKG';

  g_cal_period_end_date_attr    NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                         .attribute_id;
  g_cal_period_end_date_version NUMBER := gcs_utility_pkg.g_dimension_attr_info('CAL_PERIOD_ID-CAL_PERIOD_END_DATE')
                                         .version_id;
  g_entity_ledger_attr          NUMBER := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-LEDGER_ID')
                                         .attribute_id;
  g_entity_ledger_version       NUMBER := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-LEDGER_ID')
                                         .version_id;
  g_ledger_currency_attr        NUMBER := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-LEDGER_FUNCTIONAL_CRNCY_CODE')
                                         .attribute_id;
  g_ledger_currency_version     NUMBER := gcs_utility_pkg.g_dimension_attr_info('LEDGER_ID-LEDGER_FUNCTIONAL_CRNCY_CODE')
                                         .version_id;
  g_entity_type_attr            NUMBER := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE')
                                         .attribute_id;
  g_entity_type_version         NUMBER := gcs_utility_pkg.g_dimension_attr_info('ENTITY_ID-ENTITY_TYPE_CODE')
                                         .version_id;

  --
  -- PRIVATE PROCEDURES
  --

  CURSOR c_parent_entities(p_end_date DATE, p_hierarchy_id NUMBER, p_entity_id NUMBER) IS
    SELECT gcr.parent_entity_id
      FROM gcs_cons_relationships gcr
     START WITH child_entity_id       = p_entity_id
            AND dominant_parent_flag  = 'Y'
            AND gcr.hierarchy_id      = p_hierarchy_id
            AND p_end_date BETWEEN gcr.start_date AND
                NVL(gcr.end_date, p_end_date)
    CONNECT BY PRIOR parent_entity_id = child_entity_id
           AND dominant_parent_flag   = 'Y'
           AND gcr.hierarchy_id       = p_hierarchy_id
           AND p_end_date BETWEEN gcr.start_date AND
               NVL(gcr.end_date, p_end_date);

  PROCEDURE load_entity(p_entity_id         IN NUMBER,
                        p_hierarchy_id      IN NUMBER,
                        p_cal_period_id     IN NUMBER,
                        p_balance_type_code IN VARCHAR2,
                        p_end_date          IN DATE) IS

    -- Bugfix 5843592, Get the correct entity, depending upon the calendar period

    CURSOR c_child_count IS
      SELECT count(1)
        FROM gcs_cons_relationships gcr,
             fem_entities_attr fea,
             gcs_entities_attr gea
       WHERE gcr.hierarchy_id         = p_hierarchy_id
         AND gcr.parent_entity_id     = p_entity_id
         AND gcr.dominant_parent_flag = 'Y'
         AND gcr.child_entity_id      = fea.entity_id
         AND fea.attribute_id         = g_entity_type_attr
         AND fea.version_id           = g_entity_type_version
         AND fea.dim_attribute_varchar_member <> 'E'
         AND fea.entity_id            = gea.entity_id
         AND gea.data_type_code       = p_balance_type_code
         AND p_end_date BETWEEN gea.effective_start_date
	                          AND NVL(gea.effective_end_date, p_end_date )
         AND p_end_date BETWEEN gcr.start_date AND
             nvl(gcr.end_date, p_end_date);

    --  bug fix 4554149

    -- Bugfix 5843592, Get the correct source ledger Id, depending upon the calendar period

    CURSOR c_op_entities IS
      SELECT status_code
        FROM gcs_data_sub_dtls      gdsd,
             fem_entities_attr      fea,
             gcs_cons_relationships gcr,
             gcs_cal_period_maps_gt gcpmt,
             fem_ledgers_attr       fla,
             gcs_entity_cons_attrs  geca,
             gcs_entities_attr      gea
       WHERE gcr.child_entity_id    = gdsd.entity_id
         AND p_cal_period_id        = gcpmt.target_cal_period_id
         AND gdsd.cal_period_id     = gcpmt.source_cal_period_id
         AND gdsd.balance_type_code = p_balance_type_code
         AND gdsd.most_recent_flag  = 'Y'
         AND NVL(gdsd.currency_code, fla.dim_attribute_varchar_member) =
             geca.currency_code
         AND gea.entity_id          = gdsd.entity_id
         AND gea.data_type_code     = gdsd.balance_type_code
         AND p_end_date       BETWEEN gea.effective_start_date
                                      AND NVL(gea.effective_end_date, p_end_date )
         AND fla.ledger_id          = gea.ledger_id
         AND fla.attribute_id       = g_ledger_currency_attr
         AND fla.version_id         = g_ledger_currency_version
         AND geca.hierarchy_id      = gcr.hierarchy_id
         AND geca.entity_id         = gdsd.entity_id
         AND gcr.child_entity_id    = fea.entity_id
         AND gcr.hierarchy_id       = p_hierarchy_id
         AND gcr.parent_entity_id   = p_entity_id
         AND gcr.dominant_parent_flag = 'Y'
         AND fea.attribute_id       = g_entity_type_attr
         AND fea.version_id         = g_entity_type_version
         AND fea.dim_attribute_varchar_member = 'O'
         AND p_end_date       BETWEEN gcr.start_date AND NVL(gcr.end_date, p_end_date);
    -- end of bug fix 4554149

    CURSOR c_cons_entities IS
      SELECT gcds.status_code
        FROM gcs_cons_data_statuses gcds,
             fem_entities_attr      fea,
             gcs_cons_relationships gcr
       WHERE gcr.child_entity_id    = gcds.consolidation_entity_id
         AND gcds.cal_period_id     = p_cal_period_id
         AND gcds.balance_type_code = p_balance_type_code
         AND gcds.hierarchy_id      = p_hierarchy_id
         AND gcr.child_entity_id    = fea.entity_id
         AND gcr.hierarchy_id       = p_hierarchy_id
         AND gcr.parent_entity_id   = p_entity_id
         AND gcr.dominant_parent_flag = 'Y'
         AND fea.attribute_id       = g_entity_type_attr
         AND fea.version_id         = g_entity_type_version
         AND fea.dim_attribute_varchar_member = 'C'
         AND p_end_date between gcr.start_date AND
             NVL(gcr.end_date, p_end_date);

    l_op_status   VARCHAR2(30);
    l_cons_status VARCHAR2(30);
    l_status_code VARCHAR2(30) := 'NOT_STARTED';
    l_total_cnt   NUMBER(15) := 0;
    l_oper_cnt    NUMBER(15) := 0;
    l_undo_cnt    NUMBER(15) := 0;
    l_child_cnt   NUMBER(15) := 0;
    l_api_name    VARCHAR2(30) := 'load_entity';
  BEGIN
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_enter || ' p_entity_id = ' ||
                     p_entity_id || ' p_hierarchy_id = ' || p_hierarchy_id ||
                     ' p_cal_period_id = ' || p_cal_period_id ||
                     ' p_balance_type_code = ' || p_balance_type_code ||
                     ' p_end_date = ' || p_end_date || ' ' ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
    gcs_utility_pkg.populate_calendar_map_details(p_cal_period_id,
                                                  'N',
                                                  'N');

    -- count how many non-elim children this entity has
    OPEN c_child_count;
    FETCH c_child_count
      INTO l_child_cnt;
    CLOSE c_child_count;


    OPEN c_op_entities;
    LOOP
      FETCH c_op_entities
        INTO l_op_status;
      EXIT WHEN(c_op_entities%NOTFOUND);
      IF (l_op_status <> 'NOT_STARTED' ) THEN
        l_total_cnt := l_total_cnt + 1;
        l_oper_cnt  := l_oper_cnt + 1;
        IF (l_op_status = 'ERROR') THEN
          l_status_code := 'ERROR';
        ELSIF (l_op_status = 'WARNING' AND l_status_code <> 'ERROR') THEN
          l_status_code := 'WARNING';
        --Start Bugfix 5569620
        ELSIF (l_op_status = 'IMPACTED' AND l_status_code <> 'ERROR' AND l_status_code <> 'WARNING') THEN
          l_status_code := 'IMPACTED';
        --End Bugfix 5569620
        ELSIF (l_op_status = 'COMPLETED' AND l_status_code <> 'ERROR' AND
              l_status_code <> 'WARNING' AND l_status_code <> 'IMPACTED') THEN
          l_status_code := 'COMPLETED';
        --Start BugFix: 5647099
        ELSIF (l_op_status = 'UNDONE') THEN
          l_total_cnt   := l_total_cnt - 1;
          l_undo_cnt    := l_undo_cnt + 1;
        --End BugFix: 5647099
        END IF;
      END IF;
    END LOOP;
    CLOSE c_op_entities;

    OPEN c_cons_entities;
    LOOP
      FETCH c_cons_entities
        INTO l_cons_status;
      EXIT WHEN(c_cons_entities%NOTFOUND);
      IF (l_cons_status <> 'NOT_STARTED') THEN
        l_total_cnt := l_total_cnt + 1;
        IF (l_cons_status = 'ERROR') THEN
          l_status_code := 'ERROR';
        ELSIF (l_cons_status = 'WARNING' AND l_status_code <> 'ERROR') THEN
          l_status_code := 'WARNING';
        --Start Bugfix 5569620
        ELSIF (l_cons_status = 'IMPACTED' AND l_status_code <> 'ERROR'
               AND l_status_code <> 'WARNING') THEN
          l_status_code := 'IMPACTED';
        --End Bugfix 5569620
        --Start Bugfix 5668981
        ELSIF (l_cons_status = 'IN_PROGRESS' AND l_status_code <> 'ERROR'
               AND l_status_code <> 'WARNING' AND l_status_code <> 'IMPACTED') THEN
          l_status_code := 'IN_PROGRESS';
        ELSIF (l_cons_status = 'COMPLETED' AND l_status_code <> 'ERROR'
               AND l_status_code <> 'WARNING' AND l_status_code <> 'IMPACTED'
               AND l_status_code <> 'IN_PROGRESS') THEN
        --End Bugfix 5668981
          l_status_code := 'COMPLETED';
        END IF;
      END IF;
    END LOOP;
    CLOSE c_cons_entities;

    -- Start Bug fix : 5647099
    IF (l_oper_cnt = l_undo_cnt AND l_status_code <> 'NOT_STARTED'
        --Bug fix : 5668981
        AND l_oper_cnt <> 0) THEN
      l_status_code := 'NOT_STARTED';
    END IF;
    -- End Bug fix : 5647099


    IF (l_total_cnt < l_child_cnt  AND l_status_code <> 'NOT_STARTED') THEN
      l_status_code := 'IN_PROGRESS';
    END IF;

    MERGE INTO gcs_cons_data_statuses gcds
    USING (SELECT l_status_code status_code FROM dual) src
    ON (gcds.hierarchy_id            = p_hierarchy_id AND
        gcds.consolidation_entity_id = p_entity_id AND
        gcds.cal_period_id           = p_cal_period_id AND
        gcds.balance_type_code       = p_balance_type_code)
    WHEN MATCHED THEN
      UPDATE
         SET gcds.status_code      = src.status_code,
             gcds.last_update_date = sysdate,
             gcds.last_updated_by  = fnd_global.user_id
    WHEN NOT MATCHED THEN
      INSERT
        (gcds.hierarchy_id,
         gcds.consolidation_entity_id,
         gcds.cal_period_id,
         gcds.balance_type_code,
         gcds.status_code,
         gcds.created_by,
         gcds.creation_date,
         gcds.last_updated_by,
         gcds.last_update_date)
      VALUES
        (p_hierarchy_id,
         p_entity_id,
         p_cal_period_id,
         p_balance_type_code,
         src.status_code,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         sysdate);
  END load_entity;

  -- update the gcs_cons_data_statuses table for a newly added entity in the specified hierarchy
  -- from the start date
  -- it first insert into the gcs_cons_data_statuses table
  -- then update gcs_cons_data_statuses for the cal_period_id and balance_type_code not loaded with
  -- this entity
  PROCEDURE add_entity(p_entity_id    IN NUMBER,
                       p_hierarchy_id IN NUMBER,
                       p_start_date   IN DATE) IS



    --  bug fix 4554149
    CURSOR c_entity_period IS
      SELECT fcpa.cal_period_id,
             gdsd.balance_type_code
        FROM gcs_data_sub_dtls     gdsd,
             fem_cal_periods_attr  fcpa,
             fem_ledgers_attr      fla,
             gcs_entity_cons_attrs geca,
             fem_entities_attr     fea_cur
       WHERE gdsd.entity_id          = p_entity_id
         AND gdsd.cal_period_id      = fcpa.cal_period_id
         AND gdsd.most_recent_flag   = 'Y'
         AND fcpa.attribute_id       = g_cal_period_end_date_attr
         AND fcpa.version_id         = g_cal_period_end_date_version
         AND fcpa.date_assign_value >= p_start_date
         AND NVL(gdsd.currency_code, fla.dim_attribute_varchar_member) =
             geca.currency_code
         AND fea_cur.entity_id       = gdsd.entity_id
         AND fea_cur.attribute_id    = g_entity_ledger_attr
         AND fea_cur.version_id      = g_entity_ledger_version
         AND fla.ledger_id           = fea_cur.dim_attribute_numeric_member
         AND fla.attribute_id        = g_ledger_currency_attr
         AND fla.version_id          = g_ledger_currency_version
         AND geca.hierarchy_id       = p_hierarchy_id
         AND geca.entity_id          = gdsd.entity_id;
    -- end of bug fix 4554149

    cursor c_target_cal_period is
      select target_cal_period_id,
             fcpa.date_assign_value
        from gcs_cal_period_maps_gt gcpmt,
             fem_cal_periods_attr fcpa
       where gcpmt.target_cal_period_id = fcpa.cal_period_id
         and fcpa.attribute_id          = g_cal_period_end_date_attr
         and fcpa.version_id            = g_cal_period_end_date_version;

    l_date          date;
    l_cal_period_id number;
    l_bal_type_code varchar2(30);
    l_parent_id     number;
    l_api_name      VARCHAR2(30) := 'add_entity';

  BEGIN
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_enter || ' p_entity_id = ' ||
                     p_entity_id || ' p_hierarchy_id = ' || p_hierarchy_id || ' ' ||
                     ' p_start_date = ' || p_start_date || ' ' ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
    UPDATE gcs_cons_data_statuses gcds
       SET status_code      = 'IN_PROGRESS',
           last_update_date = sysdate,
           last_updated_by  = fnd_global.user_id
     WHERE hierarchy_id = p_hierarchy_id
       AND status_code in ('COMPLETED', 'WARNING', 'ERROR')
       AND consolidation_entity_id in
           (SELECT gcr.parent_entity_id
              FROM gcs_cons_relationships gcr
             START WITH child_entity_id       = p_entity_id
                    AND hierarchy_id          = p_hierarchy_id
                    AND dominant_parent_flag  = 'Y'
            CONNECT BY prior parent_entity_id = child_entity_id
                   AND hierarchy_id           = p_hierarchy_id
                   AND dominant_parent_flag   = 'Y')
       AND EXISTS
     (SELECT 1
              FROM fem_cal_periods_attr fcpa
             WHERE fcpa.cal_period_id = gcds.cal_period_id
               AND fcpa.attribute_id  = g_cal_period_end_date_attr
               AND fcpa.version_id    = g_cal_period_end_date_version
               AND fcpa.date_assign_value >= p_start_date);

    OPEN c_entity_period;
    LOOP
      FETCH c_entity_period
        INTO l_cal_period_id, l_bal_type_code;
      EXIT WHEN(c_entity_period%NOTFOUND);

      gcs_utility_pkg.populate_calendar_map_details(l_cal_period_id,
                                                    'Y',
                                                    'N');

      OPEN c_parent_entities(p_start_date, p_hierarchy_id, p_entity_id);
      LOOP
        FETCH c_parent_entities
          INTO l_parent_id;
        EXIT WHEN(c_parent_entities % NOTFOUND);

        OPEN c_target_cal_period;
        LOOP
          FETCH c_target_cal_period
            INTO l_cal_period_id, l_date;
          EXIT WHEN(c_target_cal_period%NOTFOUND);
          load_entity(l_parent_id,
                      p_hierarchy_id,
                      l_cal_period_id,
                      l_bal_type_code,
                      l_date);
        END LOOP;
        CLOSE c_target_cal_period;
      END LOOP;
      CLOSE c_parent_entities;
    END LOOP;
    CLOSE c_entity_period;

  END add_entity;

  --
  -- PUBLIC PROCEDURES
  --

  --
  -- Procedure
  --   lock_results
  -- Purpose
  --   lock/unlock consolidation results
  --   called from consolidation monitor UI
  -- Arguments
  --   p_runname          Consolidation run identifier
  --   p_entity_id          Consolidation entity identifier
  --   p_lock_flag    Y for lock and N for unlock
  --
  PROCEDURE lock_results(p_runname   IN VARCHAR2,
                         p_entity_id IN NUMBER,
                         p_lock_flag IN VARCHAR2,
                         x_errbuf    OUT NOCOPY VARCHAR2,
                         x_retcode   OUT NOCOPY VARCHAR2) IS
    CURSOR c_entities IS
      SELECT run_entity_id, status_code
        FROM gcs_cons_eng_runs
       WHERE NVL(associated_run_name, run_name) = p_runname
       START WITH run_entity_id = p_entity_id
              AND NVL(associated_run_name, run_name) = p_runname
      CONNECT BY PRIOR run_entity_id = parent_entity_id;

    gcs_cons_eng_invalid_status EXCEPTION;
    l_api_name VARCHAR2(30) := 'LOCK_RESULTS';
  BEGIN
    SAVEPOINT gcs_lock_results_start;

    FOR entity IN c_entities LOOP
      IF (entity.status_code <> 'COMPLETED') THEN
        RAISE gcs_cons_eng_invalid_status;
      END IF;

      UPDATE gcs_cons_eng_runs
         SET locked_flag = decode(p_lock_flag, 'Y', 'N', 'Y')
       WHERE NVL(associated_run_name, run_name) = p_runname
         AND run_entity_id                      = entity.run_entity_id;

    END LOOP;
  EXCEPTION
    WHEN gcs_cons_eng_invalid_status THEN
      ROLLBACK TO gcs_lock_results_start;
      fnd_message.set_name('GCS', 'GCS_CM_INVALID_STATUS');
      x_errbuf  := fnd_message.get;
      x_retcode := fnd_api.g_ret_sts_error;

      -- Write the appropriate information to the execution report
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || x_errbuf ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO gcs_lock_results_start;
      x_errbuf  := SQLCODE || SQLERRM;
      x_retcode := fnd_api.g_ret_sts_unexp_error;

      -- Write the appropriate information to the execution report
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || x_errbuf ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;
  END lock_results;

  --
  -- Procedure
  --   update_data_status
  -- Purpose
  --   Update the gcs_cons_data_statuses when a new hierarchy is created,
  --   or an entity is added/deleted, or new data submitted
  -- Arguments
  --   p_load_id          Data submission identifier
  --   p_cons_rel_id          Consolidation relationship identifier
  --   p_hierarchy_id   Hierarchy for which the logic must be performed
  --   p_transaction_type NEW, ACQ, or DIS
  --
  PROCEDURE update_data_status(p_load_id          IN NUMBER DEFAULT NULL,
                               p_cons_rel_id      IN NUMBER DEFAULT NULL,
                               p_hierarchy_id     IN NUMBER DEFAULT NULL,
                               p_transaction_type IN VARCHAR2 DEFAULT NULL) IS
    l_load_id          NUMBER := p_load_id;
    l_entity_id        NUMBER;
    l_hierarchy_id     NUMBER := p_hierarchy_id;
    l_transaction_type VARCHAR2(10) := p_transaction_type;
    l_start_date       DATE;
    l_end_date         DATE;
    l_date             DATE;
    l_cal_period_id    NUMBER;
    l_bal_type_code    VARCHAR2(30);
    l_child_id         NUMBER(15);
    l_parent_id_list   DBMS_SQL.number_table;
    l_parent_id        NUMBER;
    l_api_name         VARCHAR2(80) := 'update_data_status';

    -- bug fix 4554149
    -- Bugfix 5843592, Get the correct source ledger Id, depending upon the calendar period
    --                  and use gcs_entities_attr instead of fem_entities_attr

    CURSOR c_load_data(p_load_id NUMBER) IS
      SELECT DISTINCT ghb.hierarchy_id,
                      gdsd.entity_id,
                      fcpb.cal_period_id,
                      gdsd.balance_type_code,
                      fcpa.date_assign_value
        FROM gcs_data_sub_dtls      gdsd,
             fem_cal_periods_attr   fcpa,
             gcs_cal_period_maps_gt gcpmt,
             gcs_hierarchies_b      ghb,
             fem_cal_periods_b      fcpb,
             fem_ledgers_attr       fla,
             gcs_entity_cons_attrs  geca,
             gcs_entities_attr      gea,
             fem_cal_periods_attr   fcpa_curr
       WHERE gdsd.cal_period_id      = gcpmt.source_cal_period_id
         AND fcpb.cal_period_id      = fcpa.cal_period_id
         AND fcpb.cal_period_id      = gcpmt.target_cal_period_id
         AND fcpb.calendar_id        = ghb.calendar_id
         AND fcpb.dimension_group_id = ghb.dimension_group_id
         AND fcpa.attribute_id       = g_cal_period_end_date_attr
         AND fcpa.version_id         = g_cal_period_end_date_version
         AND gdsd.load_id            = p_load_id
         AND NVL(gdsd.currency_code, fla.dim_attribute_varchar_member) =
             geca.currency_code
         AND gea.entity_id           = gdsd.entity_id
         AND gea.data_type_code      = gdsd.balance_type_code
         AND fcpa_curr.cal_period_id = gdsd.cal_period_id
	       AND fcpa_curr.attribute_id  = g_cal_period_end_date_attr
	       AND fcpa_curr.version_id    = g_cal_period_end_date_version
	       AND fcpa_curr.date_assign_value BETWEEN gea.effective_start_date
	                        	                 AND NVL(gea.effective_end_date, fcpa_curr.date_assign_value )
         AND gea.ledger_id           = fla.ledger_id
         AND fla.attribute_id        = g_ledger_currency_attr
         AND fla.version_id          = g_ledger_currency_version
         AND geca.hierarchy_id       = ghb.hierarchy_id
         AND geca.entity_id          = gdsd.entity_id;

    -- end of bug fix 4554149

    CURSOR c_cons_rel_data(p_cons_rel_id NUMBER) IS
      SELECT gcr.child_entity_id,
             gcr.hierarchy_id,
             gcr.start_date,
             gcr.end_date
        FROM gcs_cons_relationships gcr
       WHERE cons_relationship_id = p_cons_rel_id;

    CURSOR c_child_id(p_hierarchy_id NUMBER) IS
      SELECT gcr.child_entity_id,
             gcr.start_date
        FROM gcs_cons_relationships gcr,
             fem_entities_attr fea
       WHERE gcr.hierarchy_id         = p_hierarchy_id
         AND gcr.dominant_parent_flag = 'Y'
         AND gcr.child_entity_id      = fea.entity_id
         AND fea.attribute_id         = g_entity_type_attr
         AND fea.version_id           = g_entity_type_version
         AND fea.dim_attribute_varchar_member = 'O';

    CURSOR c_parent_info(p_end_date DATE, p_hierarchy_id NUMBER, p_entity_id NUMBER) IS
      SELECT gcds.cal_period_id,
             gcds.balance_type_code,
             fcpa.date_assign_value
        FROM gcs_cons_data_statuses gcds,
             fem_cal_periods_attr fcpa
       WHERE hierarchy_id = p_hierarchy_id
         AND consolidation_entity_id = p_entity_id
         AND gcds.cal_period_id      = fcpa.cal_period_id
         AND fcpa.attribute_id       = g_cal_period_end_date_attr
         AND fcpa.version_id         = g_cal_period_end_date_version
         AND fcpa.date_assign_value  > p_end_date;

  BEGIN
    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_enter || ' p_load_id = ' ||
                     p_load_id || ', p_cons_rel_id = ' || p_cons_rel_id ||
                     ', p_hierarchy_id = ' || p_hierarchy_id ||
                     ', p_transaction_type = ' || p_transaction_type ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

    -- event raised from data submission
    -- loop through each parent of the newly loaded entity and scan its children's status
    IF (l_load_id IS NOT NULL) THEN

      --Explode into calendar period maps table gcs_cal_period_maps_gt
      SELECT cal_period_id
        INTO l_cal_period_id
        FROM gcs_data_sub_dtls
       WHERE load_id = l_load_id;

      gcs_utility_pkg.populate_calendar_map_details(l_cal_period_id,
                                                    'Y',
                                                    'N');

      OPEN c_load_data(l_load_id);
      LOOP
        FETCH c_load_data
          INTO l_hierarchy_id,
               l_child_id,
               l_cal_period_id,
               l_bal_type_code,
               l_date;
        EXIT WHEN(c_load_data%NOTFOUND);

        OPEN c_parent_entities(l_date, l_hierarchy_id, l_child_id);
        LOOP
          FETCH c_parent_entities
            INTO l_entity_id;

          EXIT WHEN(c_parent_entities % NOTFOUND);

          load_entity(l_entity_id,
                      l_hierarchy_id,
                      l_cal_period_id,
                      l_bal_type_code,
                      l_date);
        END LOOP;
        CLOSE c_parent_entities;
      END LOOP;
      CLOSE c_load_data;

      -- event raised from hierarchy change
    ELSE
      -- a newly create hierarchy
      -- loop through each leaf node in this hierarchy and update its recursive parents' status
      IF (l_transaction_type = 'NEW') THEN
        OPEN c_child_id(l_hierarchy_id);
        LOOP
          FETCH c_child_id
           INTO l_child_id,
                l_date;
          EXIT WHEN(c_child_id%NOTFOUND);
          add_entity(l_child_id, l_hierarchy_id, l_date);
        END LOOP;
        CLOSE c_child_id;

        -- add a new entity
        -- update its recursive parents' status
      ELSIF (l_transaction_type = 'ACQ') THEN
        open c_cons_rel_data(p_cons_rel_id);
        fetch c_cons_rel_data
          INTO l_entity_id,
               l_hierarchy_id,
               l_start_date,
               l_end_date;

        IF (c_cons_rel_data%FOUND) THEN
          add_entity(l_entity_id, l_hierarchy_id, l_start_date);
        END IF;
        close c_cons_rel_data;

        -- delete an entity
        -- loop through each parent of this entity and scan its children's status
      ELSIF (l_transaction_type = 'DIS') THEN
        open c_cons_rel_data(p_cons_rel_id);
        fetch c_cons_rel_data
          INTO l_child_id,
               l_hierarchy_id,
               l_start_date,
               l_end_date;

        IF (c_cons_rel_data%FOUND) THEN
          OPEN c_parent_entities(l_end_date, l_hierarchy_id, l_child_id);
          LOOP
            FETCH c_parent_entities
              INTO l_parent_id;
            EXIT WHEN(c_parent_entities % NOTFOUND);

            OPEN c_parent_info(l_end_date, l_hierarchy_id, l_parent_id);
            LOOP
              FETCH c_parent_info
                INTO l_cal_period_id,
                     l_bal_type_code,
                     l_date;
              EXIT WHEN(c_parent_info % NOTFOUND);
              load_entity(l_parent_id,
                          l_hierarchy_id,
                          l_cal_period_id,
                          l_bal_type_code,
                          l_date);
            END LOOP;
            CLOSE c_parent_info;
          END LOOP;
          CLOSE c_parent_entities;
        END IF;
        CLOSE c_cons_rel_data;
      END IF;
    END IF;

    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_success || ' ' ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || SQLERRM ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;

      RAISE;

  END update_data_status;

  --
  -- Procedure
  --   hierarchy_init
  -- Purpose
  --   Update the gcs_cons_data_status when a new hierarchy is created
  -- Arguments
  --   p_hierarchy_id   Hierarchy for which the logic must be performed
  --
  PROCEDURE hierarchy_init(x_errbuf       OUT NOCOPY VARCHAR2,
                           x_retcode      OUT NOCOPY VARCHAR2,
                           p_hierarchy_id NUMBER) IS

    CURSOR c_child_id IS
      SELECT gcr.child_entity_id,
             gcr.start_date
        FROM gcs_cons_relationships gcr,
             fem_entities_attr fea
       WHERE gcr.hierarchy_id         = p_hierarchy_id
         AND gcr.dominant_parent_flag = 'Y'
         AND gcr.child_entity_id      = fea.entity_id
         AND fea.attribute_id         = g_entity_type_attr
         AND fea.version_id           = g_entity_type_version
         AND fea.dim_attribute_varchar_member = 'O';

    l_date     DATE;
    l_child_id NUMBER;
    l_api_name VARCHAR2(80) := 'hierarchy_init';

  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                      g_pkg_name || '.' || l_api_name || ' ENTER : ' ||
                      ', p_hierarchy_id = ' || p_hierarchy_id ||
                      TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_enter ||
                     ', p_hierarchy_id = ' || p_hierarchy_id ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

    OPEN c_child_id;
    LOOP
      FETCH c_child_id
        INTO l_child_id, l_date;

      EXIT WHEN(c_child_id%NOTFOUND);
      add_entity(l_child_id, p_hierarchy_id, l_date);
    END LOOP;
    CLOSE c_child_id;

    x_retcode := fnd_api.g_ret_sts_success;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                      g_pkg_name || '.' || l_api_name || ' EXIT');
    FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_success || ' ' ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

    GCS_FEM_HIER_SYNC_PKG.synchronize_hierarchy(p_hierarchy_id => p_hierarchy_id,
                                                x_errbuf       => x_errbuf,
                                                x_retcode      => x_retcode);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      x_errbuf  := SQLERRM;
      x_retcode := '2';

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
                        g_pkg_name || '.' || l_api_name || ' ERROR : ' ||
                        x_errbuf);
      FND_FILE.NEW_LINE(FND_FILE.OUTPUT);

      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || SQLERRM ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;

  END hierarchy_init;

  --
  -- Procedure
  --   submit_update_data_status
  -- Purpose
  --   Submits update gcs_cons_data_statuses when a new hierarchy is created,
  --   or an entity is added/deleted, or new data submitted
  -- Arguments
  --   p_load_id          Data submission identifier
  --   p_cons_rel_id      Consolidation relationship identifier
  --   p_hierarchy_id     Hierarchy for which the logic must be performed
  --   p_transaction_type NEW, ACQ, or DIS
  PROCEDURE submit_update_data_status(x_errbuf  OUT NOCOPY VARCHAR2,
                                      x_retcode OUT NOCOPY VARCHAR2,
                                      p_load_id          IN NUMBER DEFAULT NULL,
                                      p_cons_rel_id      IN NUMBER DEFAULT NULL,
                                      p_hierarchy_id     IN NUMBER DEFAULT NULL,
                                      p_transaction_type IN VARCHAR2 DEFAULT NULL) IS

    l_api_name         VARCHAR2(80) := 'submit_update_data_status';
  BEGIN

    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_enter || ' p_load_id = ' ||
                     p_load_id || ', p_cons_rel_id = ' || p_cons_rel_id ||
                     ', p_hierarchy_id = ' || p_hierarchy_id ||
                     ', p_transaction_type = ' || p_transaction_type ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      g_pkg_name || '.' || l_api_name || ' ENTER : ' ||
                      ' p_load_id = ' || p_load_id || ', p_cons_rel_id = ' || p_cons_rel_id ||
                     ', p_hierarchy_id = ' || p_hierarchy_id ||
                     ', p_transaction_type = ' || p_transaction_type ||
                      TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    FND_FILE.NEW_LINE(FND_FILE.LOG);

    update_data_status(p_load_id          => p_load_id,
                       p_cons_rel_id      => p_cons_rel_id,
                       p_hierarchy_id     => p_hierarchy_id,
                       p_transaction_type => p_transaction_type);
    COMMIT;
    FND_FILE.PUT_LINE(FND_FILE.LOG,
                      g_pkg_name || '.' || l_api_name || ' EXIT : ' ||
                      TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

    IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
      fnd_log.STRING(fnd_log.level_procedure,
                     g_pkg_name || '.' || l_api_name,
                     gcs_utility_pkg.g_module_success || ' ' ||
                     TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      IF fnd_log.g_current_runtime_level <= fnd_log.level_error THEN
        fnd_log.STRING(fnd_log.level_error,
                       g_pkg_name || '.' || l_api_name,
                       gcs_utility_pkg.g_module_failure || ' ' || SQLERRM ||
                       TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
      END IF;

      RAISE;

  END submit_update_data_status;

END GCS_CONS_MONITOR_PKG;

/
