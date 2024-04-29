--------------------------------------------------------
--  DDL for Package Body CN_MARK_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_MARK_EVENTS_PKG" AS
  -- $Header: cneventb.pls 120.7.12010000.7 2009/07/14 06:15:14 rnagaraj ship $

  -- forward declaration
  PROCEDURE mark_subsequent_periods(
    p_salesrep_id     IN NUMBER
  , p_period_id       IN NUMBER
  , p_start_date      IN DATE
  , p_end_date        IN DATE
  , p_quota_id        IN NUMBER
  , p_revert_to_state IN VARCHAR2
  , p_event_log_id    IN NUMBER
  , p_org_id          IN NUMBER
  );

  --
  -- Name
  --   log_event
  -- Purpose
  --   This should be the first call in mark_event_*.  This procedure will make an
  --   entry in cn_event_log and return event_log_id which will be used in mark_notify.
  --   This procedure should be called once for each event.
  -- History
  --
  --   07/12/98   Richard Jin   Created
  PROCEDURE log_event(
    p_event_name     IN            VARCHAR2
  , p_object_name    IN            VARCHAR2
  , p_object_id      IN            NUMBER
  , p_start_date     IN            DATE
  , p_start_date_old IN            DATE
  , p_end_date       IN            DATE
  , p_end_date_old   IN            DATE
  , x_event_log_id   OUT NOCOPY    NUMBER
  , p_org_id         IN            NUMBER
  ) IS
  BEGIN
    INSERT INTO cn_event_log_all(
                 event_log_id
               , event_name
               , object_name
               , object_id
               , start_date
               , start_date_old
               , end_date
               , end_date_old
               , user_id
               , event_log_date
               , status
               , creation_date
               , created_by
               , last_update_date
               , last_update_login
               , last_updated_by
               , org_id
               )
         VALUES (
                 cn_event_log_s.NEXTVAL
               , p_event_name
               , p_object_name
               , p_object_id
               , p_start_date
               , p_start_date_old
               , p_end_date
               , p_end_date_old
               , fnd_global.user_id
               , SYSDATE
               , NULL
               , SYSDATE
               , fnd_global.user_id
               , SYSDATE
               , fnd_global.login_id
               , fnd_global.user_id
               , p_org_id
               )
         RETURNING event_log_id INTO x_event_log_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(fnd_log.level_unexpected, 'cn.plsql.cn_mark_events_pkg.log_event.exception'
        , SQLERRM);
      END IF;

      RAISE;
  END log_event;

  --
  -- Name
  --   mark_notify_real
  -- Purpose
  --
  -- History
  --
  --   07/12/98   Richard Jin   Created
  PROCEDURE mark_notify_real(
    p_salesrep_id     IN NUMBER
  , p_period_id       IN NUMBER
  , p_start_date      IN DATE
  , p_end_date        IN DATE
  , p_quota_id        IN NUMBER
  , p_revert_to_state IN VARCHAR2
  , p_event_log_id    IN NUMBER
  , p_mode            IN VARCHAR2
  , p_org_id          IN NUMBER
  ) IS
    -- for marking CALC event
    CURSOR l_chk_calc_lower_events_csr IS
      SELECT 1
        FROM cn_notify_log_all
       WHERE period_id = p_period_id
         AND org_id = p_org_id
         AND (salesrep_id = p_salesrep_id OR salesrep_id = -1000)
         AND status = 'INCOMPLETE'
         AND (revert_state IN('COL', 'CLS', 'ROLL') OR(revert_state = 'CALC' AND quota_id IS NULL));

    -- clku, bug 2769655, do not check for 'COL' anymore, need to mark event
    -- even if there are -1000 'COL' records in notify log
    CURSOR l_chk_lower_events_csr(l_revert_state VARCHAR2, l_start_date DATE, l_end_date DATE) IS
      SELECT 1
        FROM cn_notify_log_all
       WHERE period_id = p_period_id
         AND org_id = p_org_id
         AND (salesrep_id = p_salesrep_id OR salesrep_id = -1000)
         AND status = 'INCOMPLETE'
         AND (
                 (l_revert_state = 'POP' AND revert_state IN('CLS', 'ROLL'))
              OR (l_revert_state = 'ROLL' AND revert_state IN('CLS'))
             )
         AND l_start_date BETWEEN start_date AND end_date
         AND l_end_date BETWEEN start_date AND end_date;

    -- if there is already a 'CALC' or 'POP' entry for the same quota_id don't mark.
    CURSOR l_check_calc_quota_entry_csr IS
      SELECT 1
        FROM cn_notify_log_all
       WHERE salesrep_id = p_salesrep_id
         AND org_id = p_org_id
         AND period_id = p_period_id
         AND revert_state IN('CALC', 'POP')
         AND status = 'INCOMPLETE'
         AND quota_id = p_quota_id;

    -- for marking POP event
    CURSOR l_pop_quota_entry_csr IS
      SELECT notify_log_id
           , start_date
           , end_date
        FROM cn_notify_log_all
       WHERE salesrep_id = p_salesrep_id
         AND org_id = p_org_id
         AND period_id = p_period_id
         AND revert_state = p_revert_to_state
         AND status = 'INCOMPLETE'
         AND quota_id = p_quota_id;

    CURSOR l_roll_entry_csr IS
      SELECT notify_log_id
           , start_date
           , end_date
        FROM cn_notify_log_all
       WHERE (salesrep_id = -1000 OR salesrep_id = p_salesrep_id)
         AND org_id = p_org_id
         AND period_id = p_period_id
         AND revert_state = p_revert_to_state
         AND status = 'INCOMPLETE';

    CURSOR l_roll_all_entry_csr IS
      SELECT notify_log_id
           , start_date
           , end_date
        FROM cn_notify_log_all
       WHERE salesrep_id = -1000
         AND org_id = p_org_id
         AND period_id = p_period_id
         AND revert_state = p_revert_to_state
         AND status = 'INCOMPLETE';

    CURSOR l_cls_all_entry_csr IS
      SELECT notify_log_id
           , start_date
           , end_date
        FROM cn_notify_log_all
       WHERE salesrep_id = -1000
         AND org_id = p_org_id
         AND period_id = p_period_id
         AND revert_state = p_revert_to_state
         AND status = 'INCOMPLETE';

    CURSOR l_col_all_entry_csr IS
      SELECT notify_log_id
           , start_date
           , end_date
        FROM cn_notify_log_all
       WHERE salesrep_id = -1000
         AND org_id = p_org_id
         AND period_id = p_period_id
         AND revert_state = p_revert_to_state
         AND status = 'INCOMPLETE';

    CURSOR l_get_period_dates_csr IS
      SELECT start_date
           , end_date
        FROM cn_period_statuses_all
       WHERE period_id = p_period_id AND org_id = p_org_id;

    l_counter       NUMBER;
    l_start_date    DATE;
    l_end_date      DATE;
    l_notify_log_id NUMBER(15);
    l_insert_flag   BOOLEAN;
    l_update_flag   BOOLEAN;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_notify_real.begin'
      , 'Beginning of mark_notify_real ...'
      );
    END IF;

    l_insert_flag  := FALSE;
    l_update_flag  := FALSE;

    IF p_revert_to_state = 'CALC' THEN
      -- scannane, bug 7154503, Notify log table update
      -- rnagaraj, bug 8568515 l_insert_flag  := TRUE;

      OPEN l_chk_calc_lower_events_csr;
      FETCH l_chk_calc_lower_events_csr INTO l_counter;

      -- if no lower event in 'CLS', 'ROLL',
      -- or 'CALC' with null quota_id is found, try to mark it
      IF l_chk_calc_lower_events_csr%NOTFOUND THEN
        CLOSE l_chk_calc_lower_events_csr;

        -- get start_date, end_date
        OPEN l_get_period_dates_csr;
        FETCH l_get_period_dates_csr INTO l_start_date, l_end_date;
        CLOSE l_get_period_dates_csr;

        IF p_quota_id IS NULL THEN
          l_insert_flag  := TRUE;
        ELSIF p_quota_id IS NOT NULL THEN
          -- if there is already a 'CALC' or 'POP' entry for the same quota_id don't mark.
          --    because a 'POP' will ensure the quota be recalculated regardless of date range
          --    on that 'POP' entry
          OPEN l_check_calc_quota_entry_csr;
          FETCH l_check_calc_quota_entry_csr INTO l_counter;

          -- if 'CALC' with quota_id is not found, then mark it
          IF l_check_calc_quota_entry_csr%NOTFOUND THEN
            l_insert_flag  := TRUE;
          END IF;

          CLOSE l_check_calc_quota_entry_csr;
        END IF;
      ELSE
        CLOSE l_chk_calc_lower_events_csr;
      END IF;
    ELSIF p_revert_to_state = 'POP' THEN
      OPEN l_chk_lower_events_csr(p_revert_to_state, p_start_date, p_end_date);
      FETCH l_chk_lower_events_csr INTO l_counter;

      -- if no lower event 'COL', 'CLS', 'ROLL' with larger or equal date range is found, try to mark it
      IF l_chk_lower_events_csr%NOTFOUND THEN
        OPEN l_pop_quota_entry_csr;
        FETCH l_pop_quota_entry_csr INTO l_notify_log_id, l_start_date, l_end_date;

        IF l_pop_quota_entry_csr%FOUND THEN
          -- if an entry with quota_id exists, then only do update if needed
          l_update_flag  := TRUE;
        ELSE   -- if no pop_quota entry is found
          l_insert_flag  := TRUE;
        END IF;

        CLOSE l_pop_quota_entry_csr;
      END IF;

      CLOSE l_chk_lower_events_csr;
    ELSIF p_revert_to_state = 'ROLL' THEN
      OPEN l_chk_lower_events_csr(p_revert_to_state, p_start_date, p_end_date);
      FETCH l_chk_lower_events_csr INTO l_counter;

      -- if no lower event 'COL' 'CLS' with larger or equal date range is found, try to mark it
      IF l_chk_lower_events_csr%NOTFOUND THEN
        cn_message_pkg.DEBUG(' no lower event try to mark it ');

        IF p_salesrep_id = -1000 THEN
          OPEN l_roll_all_entry_csr;
          FETCH l_roll_all_entry_csr INTO l_notify_log_id, l_start_date, l_end_date;

          IF l_roll_all_entry_csr%FOUND THEN
            l_update_flag  := TRUE;
          ELSE
            l_insert_flag  := TRUE;
          END IF;

          CLOSE l_roll_all_entry_csr;
        ELSE   -- p_salesrep_id is not -1000
          OPEN l_roll_entry_csr;
          FETCH l_roll_entry_csr INTO l_notify_log_id, l_start_date, l_end_date;

          IF l_roll_entry_csr%FOUND THEN
            l_update_flag  := TRUE;
          ELSE
            l_insert_flag  := TRUE;
          END IF;

          CLOSE l_roll_entry_csr;
        END IF;
      END IF;

      CLOSE l_chk_lower_events_csr;
    ELSIF p_revert_to_state = 'CLS' THEN
      OPEN l_chk_lower_events_csr(p_revert_to_state, p_start_date, p_end_date);
      FETCH l_chk_lower_events_csr INTO l_counter;

      -- if no lower event 'COL' with larger or equal date range is found, try to mark it
      IF l_chk_lower_events_csr%NOTFOUND THEN
        OPEN l_cls_all_entry_csr;
        FETCH l_cls_all_entry_csr INTO l_notify_log_id, l_start_date, l_end_date;

        IF l_cls_all_entry_csr%FOUND THEN
          l_update_flag  := TRUE;
        ELSE
          l_insert_flag  := TRUE;
        END IF;

        CLOSE l_cls_all_entry_csr;
      END IF;

      CLOSE l_chk_lower_events_csr;
    ELSIF p_revert_to_state = 'COL' THEN
      OPEN l_col_all_entry_csr;
      FETCH l_col_all_entry_csr INTO l_notify_log_id, l_start_date, l_end_date;

      IF l_col_all_entry_csr%FOUND THEN
        l_update_flag  := TRUE;
      ELSE
        l_insert_flag  := TRUE;
      END IF;

      CLOSE l_col_all_entry_csr;
    END IF;

    IF l_insert_flag THEN
      INSERT INTO cn_notify_log_all
                  (
                   notify_log_id
                 , salesrep_id
                 , period_id
                 , start_date
                 , end_date
                 , quota_id
                 , revert_state
                 , event_log_id
                 , notify_log_date
                 , status
                 , revert_sequence
                 , creation_date
                 , created_by
                 , last_update_date
                 , last_update_login
                 , last_updated_by
                 , org_id
                  )
           VALUES (
                   cn_notify_log_s.NEXTVAL
                 , p_salesrep_id
                 , p_period_id
                 , NVL(p_start_date, l_start_date)
                 , NVL(p_end_date, l_end_date)
                 , p_quota_id
                 , p_revert_to_state
                 , p_event_log_id
                 , SYSDATE
                 , 'INCOMPLETE'
                 , DECODE(p_revert_to_state, 'COL', 4, 'CLS', 6, 'ROLL', 8, 'POP', 10, 'CALC', 12)
                 , SYSDATE
                 , fnd_global.user_id
                 , SYSDATE
                 , fnd_global.login_id
                 , fnd_global.user_id
                 , p_org_id
                  );
    END IF;

    IF l_update_flag THEN
      IF l_start_date > p_start_date THEN
        IF l_end_date < p_end_date THEN
          UPDATE cn_notify_log_all
             SET start_date = p_start_date
               , end_date = p_end_date
           WHERE notify_log_id = l_notify_log_id;
        ELSE
          UPDATE cn_notify_log
             SET start_date = p_start_date
           WHERE notify_log_id = l_notify_log_id;
        END IF;
      ELSIF l_end_date < p_end_date THEN
        UPDATE cn_notify_log
           SET end_date = p_end_date
         WHERE notify_log_id = l_notify_log_id;
      END IF;
    END IF;

    IF l_update_flag OR l_insert_flag THEN
      -- delete higher event entries with date range within date range for the current event
      IF p_revert_to_state = 'COL' OR p_revert_to_state = 'CLS' OR p_revert_to_state = 'ROLL' THEN
        IF p_salesrep_id = -1000 THEN
          DELETE      cn_notify_log_all
                WHERE period_id = p_period_id
                  AND org_id = p_org_id
                  AND status = 'INCOMPLETE'
                  AND (
                          (
                               p_revert_to_state = 'ROLL'
                           AND revert_state = 'POP'
                           AND start_date BETWEEN p_start_date AND p_end_date
                           AND end_date BETWEEN p_start_date AND p_end_date
                          )
                       OR (
                               p_revert_to_state = 'CLS'
                           AND revert_state IN('POP', 'ROLL')
                           AND start_date BETWEEN p_start_date AND p_end_date
                           AND end_date BETWEEN p_start_date AND p_end_date
                          )
                       OR (
                               p_revert_to_state = 'COL'
                           AND revert_state IN('POP', 'ROLL', 'CLS')
                           AND start_date BETWEEN p_start_date AND p_end_date
                           AND end_date BETWEEN p_start_date AND p_end_date
                          )
                       OR revert_state = 'CALC'
                      )
                  AND action IS NULL
                  AND action_link_id IS NULL;
        ELSE
          -- only 'ROLL', p_slearep_id <> -1000 comes here
          DELETE      cn_notify_log_all
                WHERE period_id = p_period_id
                  AND org_id = p_org_id
                  AND salesrep_id = p_salesrep_id
                  AND status = 'INCOMPLETE'
                  AND (
                          (
                               revert_state = 'POP'
                           AND start_date BETWEEN p_start_date AND p_end_date
                           AND end_date BETWEEN p_start_date AND p_end_date
                          )
                       OR revert_state = 'CALC'
                      )
                  AND action IS NULL
                  AND action_link_id IS NULL;
        END IF;
      ELSIF p_revert_to_state = 'CALC' AND p_quota_id IS NULL THEN
        IF p_salesrep_id = -1000 THEN
          -- delete 'CALC' with null quota for particular salesreps
          --  and 'CALC' with quota_id
          DELETE      cn_notify_log_all
                WHERE period_id = p_period_id
                  AND org_id = p_org_id
                  AND salesrep_id <> -1000
                  AND revert_state = p_revert_to_state
                  AND status = 'INCOMPLETE'
                  AND action IS NULL
                  AND action_link_id IS NULL;
        ELSE
          --  delete 'CALC' with quota_id
          NULL;
        END IF;
      ELSIF p_revert_to_state = 'POP' THEN
        -- delete 'CALC' entries with the same quota_id
        -- since a 'POP' entry ensures that the salesrep be picked up.
        DELETE      cn_notify_log_all
              WHERE period_id = p_period_id
                AND org_id = p_org_id
                AND salesrep_id = p_salesrep_id
                AND revert_state = 'CALC'
                AND quota_id = p_quota_id
                AND status = 'INCOMPLETE'
                AND action IS NULL
                AND action_link_id IS NULL;
      END IF;

      IF p_mode = 'SUBSEQUENT' THEN
        mark_subsequent_periods(
          p_salesrep_id
        , p_period_id
        , p_start_date
        , p_end_date
        , p_quota_id
        , p_revert_to_state
        , p_event_log_id
        , p_org_id
        );
      END IF;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_notify_real.end'
      , 'End of mark_notify_real.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_chk_lower_events_csr%ISOPEN THEN
        CLOSE l_chk_lower_events_csr;
      END IF;

      IF l_chk_calc_lower_events_csr%ISOPEN THEN
        CLOSE l_chk_calc_lower_events_csr;
      END IF;

      IF l_check_calc_quota_entry_csr%ISOPEN THEN
        CLOSE l_check_calc_quota_entry_csr;
      END IF;

      IF l_pop_quota_entry_csr%ISOPEN THEN
        CLOSE l_pop_quota_entry_csr;
      END IF;

      IF l_roll_entry_csr%ISOPEN THEN
        CLOSE l_roll_entry_csr;
      END IF;

      IF l_roll_all_entry_csr%ISOPEN THEN
        CLOSE l_roll_all_entry_csr;
      END IF;

      IF l_cls_all_entry_csr%ISOPEN THEN
        CLOSE l_cls_all_entry_csr;
      END IF;

      IF l_col_all_entry_csr%ISOPEN THEN
        CLOSE l_col_all_entry_csr;
      END IF;

      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_notify_real.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_notify_real;

  --
  -- Name
  --   mark_subsequent_periods
  -- Purpose
  --
  -- History
  --
  --   07/12/98   Richard Jin   Created
  PROCEDURE mark_subsequent_periods(
    p_salesrep_id     IN NUMBER
  ,   --required
    p_period_id       IN NUMBER
  ,   --required
    p_start_date      IN DATE
  ,   --optional
    p_end_date        IN DATE
  ,   --optional
    p_quota_id        IN NUMBER
  ,   --optional
    p_revert_to_state IN VARCHAR2
  ,   --required
    p_event_log_id    IN NUMBER
  , p_org_id          IN NUMBER
  ) IS   --required
    CURSOR l_all_srp_periods_csr IS
      -- 1). for salesrep_id = -1000 /period_id
      SELECT DISTINCT cpit2.cal_period_id
                 FROM cn_cal_per_int_types_all cpit1, cn_cal_per_int_types_all cpit2
                WHERE cpit1.cal_period_id = p_period_id
                  AND cpit1.org_id = p_org_id
                  AND cpit2.interval_type_id = cpit1.interval_type_id
                  AND cpit2.interval_number = cpit1.interval_number
                  AND cpit2.org_id = p_org_id
                  AND cpit2.cal_period_id > p_period_id;

    CURSOR l_single_srp_periods_csr IS
      -- 2). for salesrep_id/ period_id
      SELECT DISTINCT cpit2.cal_period_id
                 FROM cn_cal_per_int_types_all cpit2
                WHERE (cpit2.interval_type_id, cpit2.interval_number) IN(
                        SELECT interval_type_id
                             , interval_number
                          FROM cn_cal_per_int_types_all
                         WHERE cal_period_id = p_period_id
                           AND interval_type_id IN(
                                 SELECT DISTINCT q.interval_type_id
                                            FROM cn_quotas_all q
                                           WHERE q.quota_id IN(
                                                   SELECT quota_id
                                                     FROM cn_srp_quota_assigns_all
                                                    WHERE srp_plan_assign_id IN(
                                                            SELECT srp_plan_assign_id
                                                              FROM cn_srp_plan_assigns_all
                                                             WHERE salesrep_id = p_salesrep_id
                                                               AND org_id = p_org_id))
                                             AND (
                                                     q.incremental_type = 'N'
                                                  OR (
                                                          q.incremental_type = 'Y'
                                                      AND EXISTS(
                                                            SELECT 1
                                                              FROM cn_calc_formulas_all
                                                             WHERE calc_formula_id =
                                                                                   q.calc_formula_id
                                                               AND org_id = p_org_id
                                                               AND trx_group_code = 'GROUP')
                                                     )
                                                 ))
                           AND org_id = p_org_id)
                  AND cpit2.cal_period_id > p_period_id
                  AND cpit2.org_id = p_org_id
                  AND EXISTS(
                        SELECT 1
                          FROM cn_srp_intel_periods_all
                         WHERE salesrep_id = p_salesrep_id
                           AND period_id = cpit2.cal_period_id
                           AND org_id = p_org_id
                           AND processing_status_code <> 'CLEAN');

    CURSOR l_single_srp_pe_periods_csr IS
      -- 3). for salesrep_id/ period_id /quota_id
      SELECT cpit2.cal_period_id
        FROM cn_cal_per_int_types_all cpit2
       WHERE (cpit2.interval_type_id, cpit2.interval_number, cpit2.org_id) =
               (SELECT cpit1.interval_type_id
                     , cpit1.interval_number
                     , cpit1.org_id
                  FROM cn_cal_per_int_types_all cpit1
                 WHERE cpit1.cal_period_id = p_period_id
                   AND cpit1.org_id = p_org_id
                   AND cpit1.interval_type_id =
                         (SELECT interval_type_id
                            FROM cn_quotas_all pe
                           WHERE pe.quota_id = p_quota_id
                             AND (
                                     pe.incremental_type = 'N'
                                  OR (
                                          pe.incremental_type = 'Y'
                                      AND EXISTS(
                                            SELECT 1
                                              FROM cn_calc_formulas_all fm
                                             WHERE fm.calc_formula_id = pe.calc_formula_id
                                               AND fm.org_id = pe.org_id
                                               AND fm.trx_group_code = 'GROUP')
                                     )
                                 )))
         AND cpit2.cal_period_id > p_period_id
         AND EXISTS(
               SELECT 1
                 FROM cn_srp_intel_periods_all intel
                WHERE intel.salesrep_id = p_salesrep_id
                  AND intel.org_id = p_org_id
                  AND intel.period_id = cpit2.cal_period_id
                  AND intel.processing_status_code <> 'CLEAN');

    l_revert_to_state VARCHAR2(30);
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_subsequent_periods.begin'
      , 'Beginning of mark_subsequent_periods ...'
      );
    END IF;

    -- subsequent period will always be marked as 'CALC'
    l_revert_to_state  := 'CALC';

    IF p_salesrep_id = -1000 THEN
      FOR l_period IN l_all_srp_periods_csr LOOP
        mark_notify_real(
          p_salesrep_id                => p_salesrep_id
        , p_period_id                  => l_period.cal_period_id
        , p_start_date                 => NULL
        , p_end_date                   => NULL
        , p_quota_id                   => p_quota_id
        , p_revert_to_state            => l_revert_to_state
        , p_event_log_id               => p_event_log_id
        , p_mode                       => 'NEW'
        ,   -- p_mode
          p_org_id                     => p_org_id
        );
      END LOOP;
    ELSE
      IF p_quota_id IS NULL THEN
        FOR l_period IN l_single_srp_periods_csr LOOP
          mark_notify_real(
            p_salesrep_id                => p_salesrep_id
          , p_period_id                  => l_period.cal_period_id
          , p_start_date                 => NULL
          , p_end_date                   => NULL
          , p_quota_id                   => p_quota_id
          , p_revert_to_state            => l_revert_to_state
          , p_event_log_id               => p_event_log_id
          , p_mode                       => 'NEW'
          ,   -- p_mode
            p_org_id                     => p_org_id
          );
        END LOOP;
      ELSE
        FOR l_period IN l_single_srp_pe_periods_csr LOOP
          mark_notify_real(
            p_salesrep_id                => p_salesrep_id
          , p_period_id                  => l_period.cal_period_id
          , p_start_date                 => NULL
          , p_end_date                   => NULL
          , p_quota_id                   => p_quota_id
          , p_revert_to_state            => l_revert_to_state
          , p_event_log_id               => p_event_log_id
          , p_mode                       => 'NEW'
          ,   -- p_mode
            p_org_id                     => p_org_id
          );
        END LOOP;
      END IF;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_subsequent_periods.end'
      , 'End of mark_subsequent_periods.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_subsequent_periods.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_subsequent_periods;

  --
  -- Name
  --   mark_notify
  -- Purpose
  --
  -- History
  --
  --   07/12/98   Richard Jin   Created
  PROCEDURE mark_notify(
    p_salesrep_id     IN NUMBER
  ,   --required
    p_period_id       IN NUMBER
  ,   --required
    p_start_date      IN DATE
  ,   --optional
    p_end_date        IN DATE
  ,   --optional
    p_quota_id        IN NUMBER
  ,   --optional
    p_revert_to_state IN VARCHAR2
  ,   --required
    p_event_log_id    IN NUMBER
  , p_org_id          IN NUMBER
  ) IS   --required
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    mark_notify_real(
      p_salesrep_id
    , p_period_id
    , p_start_date
    , p_end_date
    , p_quota_id
    , p_revert_to_state
    , p_event_log_id
    , 'SUBSEQUENT'
    ,   -- p_mode
      p_org_id
    );
  END mark_notify;

  --
  -- Name
  --   mark_notify
  -- Purpose
  --
  -- History
  --
  --   07/12/98   Richard Jin   Created
  PROCEDURE mark_notify(
    p_salesrep_id     IN NUMBER
  ,   --required
    p_period_id       IN NUMBER
  ,   --required
    p_start_date      IN DATE
  ,   --optional
    p_end_date        IN DATE
  ,   --optional
    p_quota_id        IN NUMBER
  ,   --optional
    p_revert_to_state IN VARCHAR2
  ,   --required
    p_event_log_id    IN NUMBER
  ,   --required
    p_mode            IN VARCHAR2
  , p_org_id          IN NUMBER
  ) IS
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    mark_notify_real(
      p_salesrep_id
    , p_period_id
    , p_start_date
    , p_end_date
    , p_quota_id
    , p_revert_to_state
    , p_event_log_id
    , p_mode
    , p_org_id
    );
  END mark_notify;

  --
  -- Name
  --   log_event
  -- Purpose
  --   This should be the first call in mark_event_*.  This procedure will make an
  --   entry in cn_event_log and return event_log_id which will be used in mark_notify.
  --   This procedure should be called once for each event.
  -- History
  --
  --   07/12/98   Richard Jin   Created
  PROCEDURE mark_notify_salesreps(
    p_salesrep_id        IN            NUMBER
  , p_period_id          IN            NUMBER
  , p_start_date         IN            DATE
  , p_end_date           IN            DATE
  , p_revert_to_state    IN            VARCHAR2
  , p_event_log_id       IN            NUMBER
  , p_comp_group_id      IN            NUMBER
  , p_action             IN            VARCHAR2
  , p_action_link_id     IN            NUMBER
  , p_base_salesrep_id   IN            NUMBER
  , p_base_comp_group_id IN            NUMBER
  , p_role_id            IN            NUMBER
  , x_action_link_id     OUT NOCOPY    NUMBER
  , p_org_id             IN            NUMBER
  ) IS
    l_notify_log_id NUMBER;
    l_counter       NUMBER;
    l_counter2      NUMBER;
    l_insert_flag   BOOLEAN := FALSE;

    -- if no action/action_link_id is provided
    -- check lower event or 'CALC' with no quota_id
    CURSOR l_chk_calc_lower_events_csr IS
      SELECT 1
        FROM cn_notify_log_all
       WHERE period_id = p_period_id
         AND org_id = p_org_id
         AND (salesrep_id = p_salesrep_id OR salesrep_id = -1000)
         AND status = 'INCOMPLETE'
         AND (revert_state IN('COL', 'CLS', 'ROLL') OR(revert_state = 'CALC' AND quota_id IS NULL));

    CURSOR l_existence_check_csr IS
      SELECT 1
        FROM cn_notify_log_all
       WHERE period_id = p_period_id
         AND org_id = p_org_id
         AND salesrep_id = p_salesrep_id
         AND status = 'INCOMPLETE'
         AND start_date = p_start_date
         AND end_date = p_end_date
         AND revert_state = p_revert_to_state
         AND (p_comp_group_id IS NULL OR comp_group_id = p_comp_group_id)
         AND NVL(action, 'DEFAULT') = NVL(p_action, 'DEFAULT')
         AND NVL(action_link_id, -999999) = NVL(p_action_link_id, -999999)
         AND NVL(base_salesrep_id, -999999) = NVL(p_base_salesrep_id, -999999)
         AND NVL(base_comp_group_id, -999999) = NVL(p_base_comp_group_id, -999999)
         AND NVL(role_id, -999999) = NVL(p_role_id, -999999);
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_notify_salesreps.begin'
      , 'Beginning of mark_notify_salesreps...'
      );
    END IF;

    IF p_revert_to_state = 'NCALC' THEN
      -- no need to do any comparison, just insert
      l_insert_flag  := TRUE;
    ELSE
      IF p_action IS NOT NULL OR p_action_link_id IS NOT NULL THEN
        -- in this case, start_date, end_date is useful info.
        -- check the existence of identical incomplete entry
        OPEN l_existence_check_csr;
        FETCH l_existence_check_csr INTO l_counter;

        IF l_existence_check_csr%NOTFOUND THEN
          l_insert_flag  := TRUE;
        END IF;

        CLOSE l_existence_check_csr;
      ELSE
        -- no action, no action_link_id
        -- if there is already a lower event entry
        --   or a 'CALC' with null quota_id entry, then do nothing
        -- else do the following
        OPEN l_chk_calc_lower_events_csr;
        FETCH l_chk_calc_lower_events_csr INTO l_counter;

        OPEN l_existence_check_csr;
        FETCH l_existence_check_csr INTO l_counter2;

        IF l_chk_calc_lower_events_csr%NOTFOUND THEN
          IF l_existence_check_csr%NOTFOUND THEN
            -- clku change team
            l_insert_flag  := TRUE;
          END IF;
        END IF;

        CLOSE l_chk_calc_lower_events_csr;

        CLOSE l_existence_check_csr;
      END IF;
    END IF;

    IF l_insert_flag THEN
      SELECT cn_notify_log_s.NEXTVAL
        INTO l_notify_log_id
        FROM DUAL;

      -- insert into cn_notify_log
      INSERT INTO cn_notify_log_all
                  (
                   notify_log_id
                 , salesrep_id
                 , period_id
                 , start_date
                 , end_date
                 , revert_state
                 , event_log_id
                 , comp_group_id
                 , action
                 , action_link_id
                 , base_salesrep_id
                 , base_comp_group_id
                 , role_id
                 , notify_log_date
                 , status
                 , revert_sequence
                 , creation_date
                 , created_by
                 , last_update_date
                 , last_update_login
                 , last_updated_by
                 , org_id
                  )
           VALUES (
                   l_notify_log_id
                 , p_salesrep_id
                 , p_period_id
                 , p_start_date
                 , p_end_date
                 , p_revert_to_state
                 , p_event_log_id
                 , p_comp_group_id
                 , p_action
                 , p_action_link_id
                 , p_base_salesrep_id
                 , p_base_comp_group_id
                 , p_role_id
                 , SYSDATE
                 , 'INCOMPLETE'
                 , DECODE(p_revert_to_state, 'COL', 4, 'CLS', 6, 'ROLL', 8, 'POP', 10, 'CALC', 12)
                 , SYSDATE
                 , fnd_global.user_id
                 , SYSDATE
                 , fnd_global.login_id
                 , fnd_global.user_id
                 , p_org_id
                  );

      x_action_link_id  := l_notify_log_id;

      -- need to mark subsequent periods when not 'NCALC'
      IF p_revert_to_state <> 'NCALC' THEN
        -- delete all 'CALC' entry with not null quota_id
        DELETE      cn_notify_log_all
              WHERE salesrep_id = p_salesrep_id
                AND org_id = p_org_id
                AND period_id = p_period_id
                AND revert_state = p_revert_to_state
                AND status = 'INCOMPLETE'
                AND quota_id IS NOT NULL;

        mark_subsequent_periods(
          p_salesrep_id
        , p_period_id
        , p_start_date
        , p_end_date
        , NULL
        , p_revert_to_state
        , p_event_log_id
        , p_org_id
        );
      END IF;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_notify_salesreps.end'
      , 'End of mark_notify_salesreps.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_notify_salesreps.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_notify_salesreps;

  PROCEDURE mark_notify_dates(
    p_start_date         DATE
  , p_end_date           DATE
  , p_revert_to_state    VARCHAR2
  , p_event_log_id       NUMBER
  , p_org_id          IN NUMBER
  ) IS
    l_start_period_id NUMBER(15);
    l_end_period_id   NUMBER(15);

    CURSOR l_date_periods_csr IS
      SELECT   acc.period_id
             , DECODE(acc.period_id, l_start_period_id, p_start_date, acc.start_date) start_date
             , DECODE(acc.period_id, l_end_period_id, NVL(p_end_date, acc.end_date), acc.end_date)
                                                                                           end_date
          FROM cn_acc_period_statuses_v acc
         WHERE acc.period_id BETWEEN l_start_period_id AND l_end_period_id
           AND acc.period_status = 'O'
           AND acc.org_id = p_org_id
      ORDER BY acc.period_id DESC;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_notify_dates.begin'
      , 'Beginning of mark_notify_dates ...'
      );
    END IF;

    l_start_period_id  := cn_api.get_acc_period_id(p_start_date, p_org_id);
    l_end_period_id    := cn_api.get_acc_period_id(p_end_date, p_org_id);

    FOR l_per IN l_date_periods_csr LOOP
      IF l_date_periods_csr%ROWCOUNT = 1 THEN
        -- it's the last period, need to mark subsequent periods
        mark_notify(
          p_salesrep_id                => -1000
        , p_period_id                  => l_per.period_id
        , p_start_date                 => l_per.start_date
        , p_end_date                   => l_per.end_date
        , p_quota_id                   => NULL
        , p_revert_to_state            => p_revert_to_state
        , p_event_log_id               => p_event_log_id
        , p_mode                       => 'SUBSEQUENT'
        , p_org_id                     => p_org_id
        );
      ELSE
        mark_notify(
          p_salesrep_id                => -1000
        , p_period_id                  => l_per.period_id
        , p_start_date                 => l_per.start_date
        , p_end_date                   => l_per.end_date
        , p_quota_id                   => NULL
        , p_revert_to_state            => p_revert_to_state
        , p_event_log_id               => p_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );
      END IF;
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_notify_dates.end'
      , 'End of mark_notify_dates.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_notify_dates.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_notify_dates;

  -- overloaded for changes in cn_repositories;
  FUNCTION get_period(p_date DATE, p_period_set_id NUMBER, p_period_type_id NUMBER, p_org_id NUMBER)
    RETURN NUMBER IS
    CURSOR l_date_period_csr IS
      SELECT period_id
        FROM cn_period_statuses_all
       WHERE period_set_id = p_period_set_id
         AND period_type_id = p_period_type_id
         AND p_date BETWEEN start_date AND end_date
         AND org_id = p_org_id;

    CURSOR l_null_date_period_csr IS
      SELECT MAX(period_id)
        FROM cn_period_statuses_all
       WHERE period_set_id = p_period_set_id
         AND period_type_id = p_period_type_id
         AND period_status = 'O'
         AND org_id = p_org_id;

    l_period_id NUMBER(15);
  BEGIN
    IF p_date IS NOT NULL THEN
      OPEN l_date_period_csr;
      FETCH l_date_period_csr INTO l_period_id;
      CLOSE l_date_period_csr;

      RETURN l_period_id;
    ELSE
      OPEN l_null_date_period_csr;
      FETCH l_null_date_period_csr INTO l_period_id;
      CLOSE l_null_date_period_csr;

      RETURN l_period_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF l_date_period_csr%ISOPEN THEN
        CLOSE l_date_period_csr;
      END IF;

      IF l_null_date_period_csr%ISOPEN THEN
        CLOSE l_null_date_period_csr;
      END IF;

      RAISE;
  END get_period;

  PROCEDURE mark_notify_dates(
    p_start_date      DATE
  , p_end_date        DATE
  , p_revert_to_state VARCHAR2
  , p_event_log_id    NUMBER
  , p_period_set_id   NUMBER
  , p_period_type_id  NUMBER
  , p_org_id          NUMBER
  ) IS
    l_start_period_id NUMBER(15);
    l_end_period_id   NUMBER(15);

    CURSOR l_date_periods_csr IS
      SELECT   acc.period_id
             , DECODE(acc.period_id, l_start_period_id, p_start_date, acc.start_date) start_date
             , DECODE(acc.period_id, l_end_period_id, NVL(p_end_date, acc.end_date), acc.end_date)
                                                                                           end_date
          FROM cn_period_statuses_all acc
         WHERE acc.period_set_id = p_period_set_id
           AND acc.period_type_id = p_period_type_id
           AND acc.period_id BETWEEN l_start_period_id AND l_end_period_id
           AND acc.period_status = 'O'
           AND acc.org_id = p_org_id
      ORDER BY acc.period_id DESC;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_notify_dates.begin'
      , 'Beginning of mark_notify_dates ...'
      );
    END IF;

    l_start_period_id  := get_period(p_start_date, p_period_set_id, p_period_type_id, p_org_id);
    l_end_period_id    := get_period(p_end_date, p_period_set_id, p_period_type_id, p_org_id);

    FOR l_per IN l_date_periods_csr LOOP
      IF l_date_periods_csr%ROWCOUNT = 1 THEN
        -- it's the last period, need to mark subsequent periods
        mark_notify(
          p_salesrep_id                => -1000
        , p_period_id                  => l_per.period_id
        , p_start_date                 => l_per.start_date
        , p_end_date                   => l_per.end_date
        , p_quota_id                   => NULL
        , p_revert_to_state            => p_revert_to_state
        , p_event_log_id               => p_event_log_id
        , p_mode                       => 'SUBSEQUENT'
        , p_org_id                     => p_org_id
        );
      ELSE
        mark_notify(
          p_salesrep_id                => -1000
        , p_period_id                  => l_per.period_id
        , p_start_date                 => l_per.start_date
        , p_end_date                   => l_per.end_date
        , p_quota_id                   => NULL
        , p_revert_to_state            => p_revert_to_state
        , p_event_log_id               => p_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );
      END IF;
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_notify_dates.end'
      , 'End of mark_notify_dates.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_notify_dates.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_notify_dates;

  --
  -- Name
  --   Mark_event_sys_para
  -- Purpose
  -- History
  --
  --   07/12/98   Richard Jin   Created
  -- NOTES
  -- Change System Parameters
  -- List of events:
  -- 1).CHANGE_SYS_PARA_RC: Change the revenue hierarchy used in the system. All open
  --    periods will be affected. Revert to 'ROLL'
  -- 2).CHANGE_SYS_PARA_SRP: .change the managerial flag
  --    used in the system. All open periods will be affected. Revert to 'CLS'.
  -- 3).Other change in system parameter will not affect calculation.
  --   o Revenue Classes Hierarchy
  --   o managerial Rollup
  PROCEDURE mark_event_sys_para(
    p_event_name     IN VARCHAR2
  , p_object_name    IN VARCHAR2
  , p_object_id      IN NUMBER
  , p_object_id_old  IN NUMBER
  , p_period_set_id  IN NUMBER
  , p_period_type_id IN NUMBER
  , p_start_date     IN DATE
  , p_start_date_old IN DATE
  , p_end_date       IN DATE
  , p_end_date_old   IN DATE
  , p_org_id         IN NUMBER
  ) IS
    CURSOR l_rollup_flag_periods_csr IS
      SELECT period_id, start_date, end_date
        FROM cn_period_statuses_all
       WHERE period_set_id = p_period_set_id
         AND period_type_id = p_period_type_id
         AND period_status = 'O'
         AND org_id = p_org_id;

    -- p_object_id --> head_hierarchy_id
    CURSOR l_rc_hiers_csr(l_header_id NUMBER) IS
      SELECT dim.start_date, dim.end_date
        FROM cn_dim_hierarchies_all dim
       WHERE dim.header_dim_hierarchy_id = l_header_id AND org_id = p_org_id;

    l_event_log_id NUMBER(15);
    dummy          NUMBER;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_sys_para.begin'
      , 'Beginning of mark_event_sys_para ...'
      );
    END IF;

    log_event(
      p_event_name
    , p_object_name
    , p_object_id
    , p_start_date
    , p_start_date_old
    , p_end_date
    , p_end_date_old
    , l_event_log_id
    , p_org_id
    );

    IF (p_event_name = 'CHANGE_SYS_PARA_RC') THEN
      FOR l_hier IN l_rc_hiers_csr(p_object_id) LOOP
        mark_notify_dates(
          l_hier.start_date
        , l_hier.end_date
        , 'ROLL'
        , l_event_log_id
        , p_period_set_id
        , p_period_type_id
        , p_org_id
        );
      END LOOP;

      FOR l_hier IN l_rc_hiers_csr(p_object_id_old) LOOP
        mark_notify_dates(
          l_hier.start_date
        , l_hier.end_date
        , 'ROLL'
        , l_event_log_id
        , p_period_set_id
        , p_period_type_id
        , p_org_id
        );
      END LOOP;
    ELSIF(p_event_name = 'CHANGE_SYS_PARA_SRP') THEN
      FOR l_per IN l_rollup_flag_periods_csr LOOP
        mark_notify(
          p_salesrep_id                => -1000
        , p_period_id                  => l_per.period_id
        , p_start_date                 => l_per.start_date
        , p_end_date                   => l_per.end_date
        , p_quota_id                   => NULL
        , p_revert_to_state            => 'CLS'
        , p_event_log_id               => l_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_sys_para.end'
      , 'End of mark_event_sys_para.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_sys_para.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_sys_para;

  --
  -- Name
  --   Mark_event_cls_rule
  -- Purpose
  -- History
  --
  --   07/12/98   Richard Jin   Created
  -- NOTES
  --
  -- Change Classification Rules
  -- List of events:
  -- 1). CHANGE_CLS_RULES: This means the changes inside a ruleset, i.e. change rules
  --     hierarchy, change rule attributes, delete a existing ruleset. All transactions
  --     classified using this ruleset should be re-classified. Revert to 'COL'.
  -- 2). CHANGE_CLS_RULES_DATE: only change effective periods of a ruleset. No other
  --     changes. For example, old one effective from Jan-98 to Mar-98 and new one
  --     effective from Feb-98 to May-98. The periods affected are Jan-98 , April-98
  --     and May-98. All affected periods need to be re-classified. Revert to 'COL'.
  --
  --   o Insert/Delete/Update a ruleset
  --   o Update effective periods of a ruleset
  --   o Insert/Delete/Update rules in s ruleset
  PROCEDURE mark_event_cls_rule(
    p_event_name     IN VARCHAR2
  , p_object_name    IN VARCHAR2
  , p_object_id      IN NUMBER
  , p_start_date     IN DATE
  , p_start_date_old IN DATE
  , p_end_date       IN DATE
  , p_end_date_old   IN DATE
  , p_org_id         IN NUMBER
  ) IS
    l_event_log_id   NUMBER(15);
    l_date_range_tbl cn_api.date_range_tbl_type;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_cls_rule.begin'
      , 'Beginning of mark_event_cls_rule ...'
      );
    END IF;

    log_event(
      p_event_name
    , p_object_name
    , p_object_id
    , p_start_date
    , p_start_date_old
    , p_end_date
    , p_end_date_old
    , l_event_log_id
    , p_org_id
    );

    IF (p_event_name = 'CHANGE_CLS_RULES') THEN
      mark_notify_dates(p_start_date_old, p_end_date_old, 'COL', l_event_log_id, p_org_id);
    ELSIF(p_event_name = 'CHANGE_CLS_RULES_DATE') THEN
      cn_api.get_date_range_diff(p_start_date, p_end_date, p_start_date_old, p_end_date_old
      , l_date_range_tbl);

      FOR l_ctr IN 1 .. l_date_range_tbl.COUNT LOOP
        mark_notify_dates(
          l_date_range_tbl(l_ctr).start_date
        , l_date_range_tbl(l_ctr).end_date
        , 'COL'
        , l_event_log_id
        , p_org_id
        );
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_cls_rule.end'
      , 'End of mark_event_cls_rule.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_cls_rule.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_cls_rule;

  FUNCTION check_rev_hier(x_header_hierarchy_id NUMBER, p_org_id NUMBER)
    RETURN NUMBER IS
    x_count NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO x_count
      FROM cn_repositories_all
     WHERE rev_class_hierarchy_id = x_header_hierarchy_id AND org_id = p_org_id;

    IF x_count = 1 THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END check_rev_hier;

  FUNCTION check_cls_hier(x_header_hierarchy_id NUMBER, p_org_id NUMBER)
    RETURN NUMBER IS
    x_count NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO x_count
      FROM DUAL
     WHERE EXISTS(SELECT 1
                    FROM cn_attribute_rules_all
                   WHERE dimension_hierarchy_id = x_header_hierarchy_id AND org_id = p_org_id);

    IF x_count >= 1 THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END check_cls_hier;

  --
  -- Name
  --   Mark_event_rc_hier
  -- Purpose
  -- History
  --
  --   07/12/98   Richard Jin   Created
  -- NOTES
  --
  -- Change Revenue Class Hierarchy
  -- Revenue Class hierarchy refers to the hierarchy defined in system parameter forms.
  -- This canbe determined by query:
  --    select count(*)
  --      from cn_repositories
  --      where rev_class_hierarchy_id = x_header_hierarchy_id;
  --  If count(*)=1, this head hierarchy is used as revenune class hierarchy and any
  --  change in this hierarchy should be marked.
  --
  -- List of events:
  -- 1). CHANGE_RC_HIER: This includes adding or deleting a node or a root in revenue
  --     class hierarchy. All transactions need to be re-populated, revert to 'ROLL'.
  -- 2). CHANGE_RC_HIER_PERIOD: .change the effective periods of an interval. All
  --     affected transactions should be re-populated, revert to 'ROLL'.
  -- Change of the name of revenue class hierarchy has no impact on calculation.
  --   o Insert/Delete/Update an interval
  --   o Insert/Delete a header hierarchy
  --   o Insert/Delete/Update hierarchy edges/roots
  PROCEDURE mark_event_rc_hier(
    p_event_name        IN VARCHAR2
  , p_object_name       IN VARCHAR2
  , p_dim_hierarchy_id  IN NUMBER
  , p_head_hierarchy_id IN NUMBER
  , p_start_date        IN DATE
  , p_start_date_old    IN DATE
  , p_end_date          IN DATE
  , p_end_date_old      IN DATE
  , p_org_id            IN NUMBER
  ) IS
    l_event_log_id   NUMBER(15);
    l_date_range_tbl cn_api.date_range_tbl_type;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') = 'Y' THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_procedure
        , 'cn.plsql.cn_mark_events_pkg.mark_event_rc_hier.begin'
        , 'Beginning of mark_event_rc_hier ...'
        );
      END IF;

      log_event(
        p_event_name
      , p_object_name
      , p_dim_hierarchy_id
      , p_start_date
      , p_start_date_old
      , p_end_date
      , p_end_date_old
      , l_event_log_id
      , p_org_id
      );

      IF (p_event_name = 'CHANGE_RC_HIER') OR(p_event_name = 'CHANGE_RC_HIER_DELETE') THEN
        mark_notify_dates(p_start_date_old, p_end_date_old, 'ROLL', l_event_log_id, p_org_id);
      ELSIF(p_event_name = 'CHANGE_RC_HIER_DATE') THEN
        cn_api.get_date_range_diff(p_start_date, p_end_date, p_start_date_old, p_end_date_old
        , l_date_range_tbl);

        FOR l_ctr IN 1 .. l_date_range_tbl.COUNT LOOP
          mark_notify_dates(
            l_date_range_tbl(l_ctr).start_date
          , l_date_range_tbl(l_ctr).end_date
          , 'ROLL'
          , l_event_log_id
          , p_org_id
          );
        END LOOP;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_procedure
        , 'cn.plsql.cn_mark_events_pkg.mark_event_rc_hier.end'
        , 'End of mark_event_rc_hier.'
        );
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_rc_hier.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_rc_hier;

  -- Name
  --   Mark_event_cls_hier
  -- Purpose
  -- History
  --
  --   07/12/98   Richard Jin   Created
  -- NOTES
  --
  -- Change Hierarchy Used in Classification
  -- To determine whether a header hierarchy is used in classification, use the
  -- following query:
  --   select count(*)
  --     from cn_attribute_rules
  --    where dimension_hierarchy_id = x_header_hierarchy_id;
  -- if count(*) >=1, this header hierarchy is used in classification. Any changes in
  -- this hierarchy will affect classification. All affected periods will be
  -- re-classified
  -- List of events:
  -- 1). CHANGE_CLS_HIER: This includes adding or deleting a node or a root in
  --     hierarchy. All transactions need to be re-classified, revert to 'CLS'.
  -- 2). CHANGE_CLS_HIER_PERIOD: change the effective periods of an interval. All
  --     affected transactions should be re-classified, revert to 'CLS'.
  -- 3). CHANGE_CLS_HIER_DELETE: change the effective periods of an interval. All
  --     affected transactions should be re-classified, revert to 'CLS'.
  -- 4). CHANGE_CLS_HIER_INSERT: don't need to mark since the changes will be caught
  --     later at edges level when constructing the hierarchy.
  --
  --   o Insert/Delete/Update an interval
  --   o Insert/Delete a header hierarchy
  --   o Insert/Delete/Update hierarchy edges/roots
  PROCEDURE mark_event_cls_hier(
    p_event_name        IN VARCHAR2
  , p_object_name       IN VARCHAR2
  , p_dim_hierarchy_id  IN NUMBER
  , p_head_hierarchy_id IN NUMBER
  , p_start_date        IN DATE
  , p_start_date_old    IN DATE
  , p_end_date          IN DATE
  , p_end_date_old      IN DATE
  , p_org_id            IN NUMBER
  ) IS
    l_event_log_id        NUMBER(15);

    CURSOR l_ruleset_dates_csr IS
      SELECT start_date
           , end_date
        FROM cn_rulesets_all
       WHERE ruleset_status = 'GENERATED'
         AND ruleset_id IN(SELECT DISTINCT ruleset_id
                                      FROM cn_attribute_rules_all
                                     WHERE dimension_hierarchy_id = p_head_hierarchy_id
                                       AND org_id = p_org_id);

    l_date_range_diff_tbl cn_api.date_range_tbl_type;
    l_date_range_over_tbl cn_api.date_range_tbl_type;
    l_date_range_null_tbl cn_api.date_range_tbl_type;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') = 'Y' THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_procedure
        , 'cn.plsql.cn_mark_events_pkg.mark_event_cls_hier.begin'
        , 'Beginning of mark_event_cls_hier ...'
        );
      END IF;

      log_event(
        p_event_name
      , p_object_name
      , p_dim_hierarchy_id
      , p_start_date
      , p_start_date_old
      , p_end_date
      , p_end_date_old
      , l_event_log_id
      , p_org_id
      );

      IF (p_event_name = 'CHANGE_CLS_HIER') OR(p_event_name = 'CHANGE_CLS_HIER_DELETE') THEN
        FOR l_set IN l_ruleset_dates_csr LOOP
          cn_api.get_date_range_overlap(
            p_start_date_old
          , p_end_date_old
          , l_set.start_date
          , l_set.end_date
          , p_org_id
          , l_date_range_over_tbl
          );

          FOR l_ctr IN 1 .. l_date_range_over_tbl.COUNT LOOP
            mark_notify_dates(
              l_date_range_over_tbl(l_ctr).start_date
            , l_date_range_over_tbl(l_ctr).end_date
            , 'COL'
            , l_event_log_id
            , p_org_id
            );
          END LOOP;

          l_date_range_over_tbl  := l_date_range_null_tbl;
        END LOOP;
      ELSIF(p_event_name = 'CHANGE_CLS_HIER_DATE') THEN
        -- first get the date diff before comparing with rulesets date range
        cn_api.get_date_range_diff(p_start_date, p_end_date, p_start_date_old, p_end_date_old
        , l_date_range_diff_tbl);

        -- then get the overlap
        FOR l_diff_ctr IN 1 .. l_date_range_diff_tbl.COUNT LOOP
          FOR l_set IN l_ruleset_dates_csr LOOP
            cn_api.get_date_range_overlap(
              l_date_range_diff_tbl(l_diff_ctr).start_date
            , l_date_range_diff_tbl(l_diff_ctr).end_date
            , l_set.start_date
            , l_set.end_date
            , p_org_id
            , l_date_range_over_tbl
            );

            FOR l_over_ctr IN 1 .. l_date_range_over_tbl.COUNT LOOP
              mark_notify_dates(
                l_date_range_over_tbl(l_over_ctr).start_date
              , l_date_range_over_tbl(l_over_ctr).end_date
              , 'COL'
              , l_event_log_id
              , p_org_id
              );
            END LOOP;

            l_date_range_over_tbl  := l_date_range_null_tbl;
          END LOOP;
        END LOOP;

        l_date_range_diff_tbl  := l_date_range_null_tbl;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_procedure
        , 'cn.plsql.cn_mark_events_pkg.mark_event_cls_hier.end'
        , 'End of mark_event_cls_hier.'
        );
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_cls_hier.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_cls_hier;

  PROCEDURE mark_event_trx(
    x_event_name              IN VARCHAR2
  , x_object_name             IN VARCHAR2
  , x_object_id               IN NUMBER
  , x_processed_period_id_old IN NUMBER
  , x_processed_period_id_new IN NUMBER
  , x_rollup_period_id_old    IN NUMBER
  , x_rollup_period_id_new    IN NUMBER
  , p_org_id                  IN NUMBER
  ) IS
  BEGIN
    NULL;
  END mark_event_trx;

  -- Mark Event Quota
  -- Description Creates the Notify log and mark the event for Plan Element.
  -- Plan Element Has different event Names, all will do the same kind of job
  -- except the revent to state and the Event Name.
  -- Some cases the event name must be same.

  -- CASE 1: whenever there IS a change IN the CN_QUOTAS,it marks the
  --         It marks the all the Salesrep under that quotas.
  --
  -- CASE 2: whenever there is a change in the start date and the end date
  --         of CN_QUOTAS, it marks the specific salesreps in that period
  --         for that quotas.
  --         called from trigger
  --
  -- Case 3: whenever there is a change in the CN_QUOTA_RULES only on revenue
  --         class id it marks all the record for that rules and quotas.
  --         called from trigger
  --
  -- Case 4: whenever there is a Insert/Delete in CN_QUOTA_RULES, it marks
  --         all the record for that quotas.
  --         called from trigger
  --
  -- Case 5  whenever there is a change in the start date and end date of
  --         CN_QUOTA_RULE_UPLIFTS, it marks the  affected period records
  --         for that quota.
  --         called from trigger
  --
  -- Case 6: whenever there is insert/delete the cn_quota_rule_uplifts
  --         it marks the affected salesrep for that quotas.
  --         called from trigger
  PROCEDURE mark_event_quota(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    l_event_log_id       NUMBER;
    l_date_range_rec_tbl cn_api.date_range_tbl_type;
    l_start_period_id    NUMBER(15);
    l_end_period_id      NUMBER(15);
    l_start_date         DATE;
    l_end_date           DATE;

    CURSOR affected_srp_period_curs(
      l_start_period_id NUMBER
    , l_end_period_id   NUMBER
    , l_start_date      DATE
    , l_end_date        DATE
    ) IS
      -- modified by rjin 11/10/1999 add distinct
      SELECT DISTINCT spq.salesrep_id
                    , spq.period_id
                    , spq.quota_id
                    , DECODE(acc.period_id, l_start_period_id, l_start_date, acc.start_date)
                                                                                         start_date
                    , DECODE(
                        acc.period_id
                      , l_end_period_id, NVL(l_end_date, acc.end_date)
                      , acc.end_date
                      ) end_date
                 FROM cn_srp_period_quotas_all spq
                    , cn_srp_intel_periods_all sip
                    , cn_period_statuses_all acc
                WHERE spq.quota_id = p_object_id
                  AND spq.period_id BETWEEN l_start_period_id AND l_end_period_id
                  AND sip.salesrep_id = spq.salesrep_id
                  AND sip.period_id = spq.period_id
                  AND sip.org_id = spq.org_id
                  AND sip.processing_status_code <> 'CLEAN'
                  AND acc.period_id = spq.period_id
                  AND acc.org_id = spq.org_id
                  AND acc.period_status IN('O', 'F');

    CURSOR l_quota_dates_csr IS
      SELECT start_date
           , end_date
        FROM cn_quotas_all
       WHERE quota_id = p_object_id;

    --clku
    CURSOR l_pe_cursor(l_salesrep_id NUMBER, l_period_id NUMBER, l_quota_id NUMBER) IS
      SELECT quota_id
        FROM cn_srp_period_quotas_all
       WHERE salesrep_id = l_salesrep_id AND period_id = l_period_id AND quota_id = l_quota_id;

    temp_quota_id        cn_quotas.quota_id%TYPE;
    l_return_status      VARCHAR2(50);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    dependent_pe_tbl     cn_calc_sql_exps_pvt.num_tbl_type;
  BEGIN
    -- Log the Event for the Quota changes or any changes in the
    -- Plan Element.
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_quota.begin'
      , 'Beginning of mark_event_quota ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name                 => p_event_name
    , p_object_name                => p_object_name
    , p_object_id                  => p_object_id
    , p_start_date                 => p_start_date
    , p_start_date_old             => p_start_date_old
    , p_end_date                   => p_end_date
    , p_end_date_old               => p_end_date_old
    , x_event_log_id               => l_event_log_id
    , p_org_id                     => p_org_id
    );

    -- clku, move get_parent_plan_elts outside the period/salesrep loop
    IF (p_object_id IS NOT NULL) THEN
      cn_calc_sql_exps_pvt.get_parent_plan_elts(
        p_api_version                => 1.0
      , p_node_type                  => 'P'
      , p_init_msg_list              => 'T'
      , p_node_id                    => p_object_id
      , x_plan_elt_id_tbl            => dependent_pe_tbl
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      );
    END IF;

    -- Check the Event Name
    IF p_event_name = 'CHANGE_QUOTA_CALC' THEN
      -- 1. Update in Quotas
      OPEN l_quota_dates_csr;
      FETCH l_quota_dates_csr INTO l_start_date, l_end_date;
      CLOSE l_quota_dates_csr;

      l_start_period_id  := cn_api.get_acc_period_id(l_start_date, p_org_id);
      l_end_period_id    := cn_api.get_acc_period_id(l_end_date, p_org_id);

      FOR affected_recs IN affected_srp_period_curs(l_start_period_id, l_end_period_id
                          , l_start_date, l_end_date) LOOP
        -- modified by rjin 11/10/1999
        -- since all affected period (including subsequent periods)
        -- are garaunteed to be marked, so we only need to mark 'NEW'
        cn_mark_events_pkg.mark_notify(
          p_salesrep_id                => affected_recs.salesrep_id
        , p_period_id                  => affected_recs.period_id
        , p_start_date                 => NULL
        , p_end_date                   => NULL
        , p_quota_id                   => affected_recs.quota_id
        , p_revert_to_state            => 'CALC'
        , p_event_log_id               => l_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(affected_recs.salesrep_id, affected_recs.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => affected_recs.salesrep_id
              , p_period_id                  => affected_recs.period_id
              , p_start_date                 => NULL
              , p_end_date                   => NULL
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'CALC'
              , p_event_log_id               => l_event_log_id
              , p_mode                       => 'NEW'
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    ELSIF p_event_name = 'CHANGE_QUOTA_DATE' THEN
      cn_api.get_date_range_diff(
        a_start_date                 => p_start_date
      , a_end_date                   => p_end_date
      , b_start_date                 => p_start_date_old
      , b_end_date                   => p_end_date_old
      , x_date_range_tbl             => l_date_range_rec_tbl
      );

      FOR i IN 1 .. l_date_range_rec_tbl.COUNT LOOP
        l_start_period_id  :=
                             cn_api.get_acc_period_id(l_date_range_rec_tbl(i).start_date, p_org_id);
        l_end_period_id    := cn_api.get_acc_period_id(l_date_range_rec_tbl(i).end_date, p_org_id);

        FOR affected_period_recs IN affected_srp_period_curs(
                                     l_start_period_id
                                   , l_end_period_id
                                   , l_date_range_rec_tbl(i).start_date
                                   , l_date_range_rec_tbl(i).end_date
                                   ) LOOP
          cn_mark_events_pkg.mark_notify(
            p_salesrep_id                => affected_period_recs.salesrep_id
          , p_period_id                  => affected_period_recs.period_id
          , p_start_date                 => affected_period_recs.start_date
          , p_end_date                   => affected_period_recs.end_date
          , p_quota_id                   => NULL
          , p_revert_to_state            => 'ROLL'
          , p_event_log_id               => l_event_log_id
          , p_org_id                     => p_org_id
          );
        END LOOP;
      END LOOP;
    ELSIF p_event_name IN('CHANGE_QUOTA_ROLL', 'CHANGE_PE_DIRECT_INDIRECT') THEN
      --
      -- Changes in Quota Rules INSERT/UPDATE/DELETE
      --
      OPEN l_quota_dates_csr;
      FETCH l_quota_dates_csr INTO l_start_date, l_end_date;
      CLOSE l_quota_dates_csr;

      l_start_period_id  := cn_api.get_acc_period_id(l_start_date, p_org_id);
      l_end_period_id    := cn_api.get_acc_period_id(l_end_date, p_org_id);

      FOR affected_recs IN affected_srp_period_curs(l_start_period_id, l_end_period_id
                          , l_start_date, l_end_date) LOOP
        -- modified by rjin 11/10/1999
        -- since all affected period (including subsequent periods)
        -- are garaunteed to be marked, so we only need to mark 'NEW'
        cn_mark_events_pkg.mark_notify(
          p_salesrep_id                => affected_recs.salesrep_id
        , p_period_id                  => affected_recs.period_id
        , p_start_date                 => affected_recs.start_date
        , p_end_date                   => affected_recs.end_date
        , p_quota_id                   => NULL
        , p_revert_to_state            => 'ROLL'
        , p_event_log_id               => l_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );
      END LOOP;
    ELSIF p_event_name = 'CHANGE_QUOTA_POP' THEN
      --
      -- 1. Insert/Delete in Rule Uplifts
      --
      l_start_period_id  := cn_api.get_acc_period_id(p_start_date_old, p_org_id);
      l_end_period_id    := cn_api.get_acc_period_id(p_end_date_old, p_org_id);

      FOR affected_recs IN affected_srp_period_curs(l_start_period_id, l_end_period_id
                          , p_start_date_old, p_end_date_old) LOOP
        cn_mark_events_pkg.mark_notify(
          p_salesrep_id                => affected_recs.salesrep_id
        , p_period_id                  => affected_recs.period_id
        , p_start_date                 => affected_recs.start_date
        , p_end_date                   => affected_recs.end_date
        , p_quota_id                   => affected_recs.quota_id
        , p_revert_to_state            => 'POP'
        , p_event_log_id               => l_event_log_id
        , p_org_id                     => p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(affected_recs.salesrep_id, affected_recs.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => affected_recs.salesrep_id
              , p_period_id                  => affected_recs.period_id
              , p_start_date                 => affected_recs.start_date
              , p_end_date                   => affected_recs.end_date
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'POP'
              , p_event_log_id               => l_event_log_id
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    ELSIF p_event_name = 'CHANGE_QUOTA_UPLIFT_DATE' THEN
      --
      -- Update Uplift Start Date and End Date
      --
      cn_api.get_date_range_diff(
        a_start_date                 => p_start_date
      , a_end_date                   => p_end_date
      , b_start_date                 => p_start_date_old
      , b_end_date                   => p_end_date_old
      , x_date_range_tbl             => l_date_range_rec_tbl
      );

      FOR i IN 1 .. l_date_range_rec_tbl.COUNT LOOP
        l_start_period_id  :=
                             cn_api.get_acc_period_id(l_date_range_rec_tbl(i).start_date, p_org_id);
        l_end_period_id    := cn_api.get_acc_period_id(l_date_range_rec_tbl(i).end_date, p_org_id);

        FOR affected_period_recs IN affected_srp_period_curs(
                                     l_start_period_id
                                   , l_end_period_id
                                   , l_date_range_rec_tbl(i).start_date
                                   , l_date_range_rec_tbl(i).end_date
                                   ) LOOP
          cn_mark_events_pkg.mark_notify(
            p_salesrep_id                => affected_period_recs.salesrep_id
          , p_period_id                  => affected_period_recs.period_id
          , p_start_date                 => affected_period_recs.start_date
          , p_end_date                   => affected_period_recs.end_date
          , p_quota_id                   => affected_period_recs.quota_id
          , p_revert_to_state            => 'POP'
          , p_event_log_id               => l_event_log_id
          , p_org_id                     => p_org_id
          );

          IF (dependent_pe_tbl.COUNT > 0) THEN
            FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
              OPEN l_pe_cursor(affected_period_recs.salesrep_id, affected_period_recs.period_id, dependent_pe_tbl(i));
              FETCH l_pe_cursor INTO temp_quota_id;

              IF l_pe_cursor%FOUND THEN
                cn_mark_events_pkg.mark_notify(
                  p_salesrep_id                => affected_period_recs.salesrep_id
                , p_period_id                  => affected_period_recs.period_id
                , p_start_date                 => affected_period_recs.start_date
                , p_end_date                   => affected_period_recs.end_date
                , p_quota_id                   => dependent_pe_tbl(i)
                , p_revert_to_state            => 'POP'
                , p_event_log_id               => l_event_log_id
                , p_org_id                     => p_org_id
                );
              END IF;

              CLOSE l_pe_cursor;
            END LOOP;
          END IF;   -- If (dependent_pe_tbl.count > 0)
        END LOOP;
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_quota.end'
      , 'End of mark_event_quota.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_quota.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_quota;

  -- Start of Comments
  -- name        : mark_event_rt_quota
  -- Type        : None
  -- Pre-reqs    : None.
  -- Usage  : Procedure to Mark the cn_rt_quota_asgn
  -- Parameters  :
  -- IN          :  p_event_name        IN VARCHAR2
  --                p_object_name       IN VARCHAR2
  --                p_object_id         IN NUMBER
  --                p_start_date        IN DATE
  --                p_start_Date_old    IN DATE
  --                p_end_date          IN DATE
  --                p_end_date_old      IN DATE
  --
  -- Version     : Current version   1.0
  --               Initial version   1.0
  --
  -- Case 7: whenever there is a change in the start date and end date of
  --         CN_RT_QUOTA_ASGNS, it marks the  affected period records
  --         for that quota.
  --         called from trigger
  --
  -- Case 8: whenever there is insert/delete the cn_rt_quota_asgns
  --         it marks the affected salesrep for that quotas.
  --         called from trigger
  --
  PROCEDURE mark_event_rt_quota(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    l_event_log_id       NUMBER;
    l_date_range_rec_tbl cn_api.date_range_tbl_type;
    l_start_period_id    NUMBER(15);
    l_end_period_id      NUMBER(15);

    CURSOR affected_srp_period_curs(l_start_period_id NUMBER, l_end_period_id NUMBER) IS
      -- modified by rjin 11/10/1999 add distinct
      SELECT DISTINCT spq.salesrep_id
                    , spq.period_id
                    , spq.quota_id
                 FROM cn_srp_period_quotas_all spq
                    , cn_srp_intel_periods_all sip
                    , cn_period_statuses_all acc
                WHERE spq.quota_id = p_object_id
                  AND spq.period_id BETWEEN l_start_period_id AND l_end_period_id
                  AND sip.salesrep_id = spq.salesrep_id
                  AND sip.period_id = spq.period_id
                  AND sip.org_id = spq.org_id
                  AND sip.processing_status_code <> 'CLEAN'
                  AND acc.period_id = spq.period_id
                  AND acc.org_id = spq.org_id
                  AND acc.period_status IN('O', 'F');

    CURSOR l_quota_dates_csr IS
      SELECT start_date
           , end_date
        FROM cn_quotas_all
       WHERE quota_id = p_object_id;

    CURSOR l_pe_cursor(l_salesrep_id NUMBER, l_period_id NUMBER, l_quota_id NUMBER) IS
      SELECT quota_id
        FROM cn_srp_period_quotas_all
       WHERE salesrep_id = l_salesrep_id AND period_id = l_period_id AND quota_id = l_quota_id;

    temp_quota_id        cn_quotas.quota_id%TYPE;
    l_return_status      VARCHAR2(50);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    dependent_pe_tbl     cn_calc_sql_exps_pvt.num_tbl_type;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_rt_quota.begin'
      , 'Beginning of mark_event_rt_quota ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name                 => p_event_name
    , p_object_name                => p_object_name
    , p_object_id                  => p_object_id
    , p_start_date                 => p_start_date
    , p_start_date_old             => p_start_date_old
    , p_end_date                   => p_end_date
    , p_end_date_old               => p_end_date_old
    , x_event_log_id               => l_event_log_id
    , p_org_id                     => p_org_id
    );

    -- clku, move get_parent_plan_elts outside the period/salesrep loop
    IF (p_object_id IS NOT NULL) THEN
      cn_calc_sql_exps_pvt.get_parent_plan_elts(
        p_api_version                => 1.0
      , p_node_type                  => 'P'
      , p_init_msg_list              => 'T'
      , p_node_id                    => p_object_id
      , x_plan_elt_id_tbl            => dependent_pe_tbl
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      );
    END IF;

    --
    -- Check the Event Name
    --
    IF p_event_name = 'CHANGE_QUOTA_CALC' THEN
      -- 1. update cn_trx_factors.event_factor
      l_start_period_id  := cn_api.get_acc_period_id(p_start_date_old, p_org_id);
      l_end_period_id    := cn_api.get_acc_period_id(p_end_date_old, p_org_id);

      FOR affected_recs IN affected_srp_period_curs(l_start_period_id, l_end_period_id) LOOP
        cn_mark_events_pkg.mark_notify(
          p_salesrep_id                => affected_recs.salesrep_id
        , p_period_id                  => affected_recs.period_id
        , p_start_date                 => NULL
        , p_end_date                   => NULL
        , p_quota_id                   => affected_recs.quota_id
        , p_revert_to_state            => 'CALC'
        , p_event_log_id               => l_event_log_id
        , p_org_id                     => p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(affected_recs.salesrep_id, affected_recs.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => affected_recs.salesrep_id
              , p_period_id                  => affected_recs.period_id
              , p_start_date                 => NULL
              , p_end_date                   => NULL
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'CALC'
              , p_event_log_id               => l_event_log_id
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    ELSIF p_event_name = 'CHANGE_QUOTA_RT_DATE' THEN
      --
      -- Update rt_quota Assigns Start Date, End Date
      --
      cn_api.get_date_range_diff(
        a_start_date                 => p_start_date
      , a_end_date                   => p_end_date
      , b_start_date                 => p_start_date_old
      , b_end_date                   => p_end_date_old
      , x_date_range_tbl             => l_date_range_rec_tbl
      );

      FOR i IN 1 .. l_date_range_rec_tbl.COUNT LOOP
        l_start_period_id  :=
                             cn_api.get_acc_period_id(l_date_range_rec_tbl(i).start_date, p_org_id);
        l_end_period_id    := cn_api.get_acc_period_id(l_date_range_rec_tbl(i).end_date, p_org_id);

        FOR affected_period_recs IN affected_srp_period_curs(l_start_period_id, l_end_period_id) LOOP
          cn_mark_events_pkg.mark_notify(
            p_salesrep_id                => affected_period_recs.salesrep_id
          , p_period_id                  => affected_period_recs.period_id
          , p_start_date                 => NULL
          , p_end_date                   => NULL
          , p_quota_id                   => affected_period_recs.quota_id
          , p_revert_to_state            => 'CALC'
          , p_event_log_id               => l_event_log_id
          , p_org_id                     => p_org_id
          );

          IF (dependent_pe_tbl.COUNT > 0) THEN
            FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
              OPEN l_pe_cursor(affected_period_recs.salesrep_id, affected_period_recs.period_id, dependent_pe_tbl(i));
              FETCH l_pe_cursor INTO temp_quota_id;

              IF l_pe_cursor%FOUND THEN
                cn_mark_events_pkg.mark_notify(
                  p_salesrep_id                => affected_period_recs.salesrep_id
                , p_period_id                  => affected_period_recs.period_id
                , p_start_date                 => NULL
                , p_end_date                   => NULL
                , p_quota_id                   => dependent_pe_tbl(i)
                , p_revert_to_state            => 'CALC'
                , p_event_log_id               => l_event_log_id
                , p_org_id                     => p_org_id
                );
              END IF;

              CLOSE l_pe_cursor;
            END LOOP;
          END IF;   -- If (dependent_pe_tbl.count > 0)
        END LOOP;
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_rt_quota.end'
      , 'End of mark_event_rt_quota.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_rt_quota.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_rt_quota;

  -- Start of Comments
  -- name        : mark_event_trx_factor
  -- Type        : None
  -- Pre-reqs    : None.
  -- Usage  : Procedure to Mark the cn_trx_factors Event
  -- Parameters  :
  -- IN          :  p_event_name        IN VARCHAR2
  --                p_object_name       IN VARCHAR2
  --                p_object_id         IN NUMBER
  --                p_start_date        IN DATE
  --                p_start_Date_old    IN DATE
  --                p_end_date          IN DATE
  --                p_end_date_old      IN DATE
  --
  -- Version     : Current version   1.0
  --               Initial version   1.0
  -- Case 9: whenever there is update in the cn_trx_factors
  --         it marks the affected salesrep for that quotas.
  --         called from trigger
  --
  PROCEDURE mark_event_trx_factor(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    l_event_log_id    NUMBER;
    l_start_period_id NUMBER(15);
    l_end_period_id   NUMBER(15);
    l_start_date      DATE;
    l_end_date        DATE;

    CURSOR affected_srp_period_curs(
      l_start_period_id NUMBER
    , l_end_period_id   NUMBER
    , l_start_date      DATE
    , l_end_date        DATE
    ) IS
      -- modified by rjin 11/10/1999 add distinct
      SELECT DISTINCT spq.salesrep_id
                    , spq.period_id
                    , spq.quota_id
                    , DECODE(acc.period_id, l_start_period_id, l_start_date, acc.start_date)
                                                                                         start_date
                    , DECODE(
                        acc.period_id
                      , l_end_period_id, NVL(l_end_date, acc.end_date)
                      , acc.end_date
                      ) end_date
                 FROM cn_srp_period_quotas_all spq
                    , cn_srp_intel_periods_all sip
                    , cn_period_statuses_all acc
                WHERE spq.quota_id = p_object_id
                  AND spq.period_id BETWEEN l_start_period_id AND l_end_period_id
                  AND sip.salesrep_id = spq.salesrep_id
                  AND sip.period_id = spq.period_id
                  AND sip.org_id = spq.org_id
                  AND sip.processing_status_code <> 'CLEAN'
                  AND acc.period_id = spq.period_id
                  AND acc.org_id = spq.org_id
                  AND acc.period_status IN('O', 'F');

    CURSOR l_quota_dates_csr IS
      SELECT start_date
           , end_date
        FROM cn_quotas_all
       WHERE quota_id = p_object_id;

    CURSOR l_pe_cursor(l_salesrep_id NUMBER, l_period_id NUMBER, l_quota_id NUMBER) IS
      SELECT quota_id
        FROM cn_srp_period_quotas_all
       WHERE salesrep_id = l_salesrep_id AND period_id = l_period_id AND quota_id = l_quota_id;

    temp_quota_id     cn_quotas.quota_id%TYPE;
    l_return_status   VARCHAR2(50);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    dependent_pe_tbl  cn_calc_sql_exps_pvt.num_tbl_type;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_trx_factor.begin'
      , 'Beginning of mark_event_trx_factor ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name                 => p_event_name
    , p_object_name                => p_object_name
    , p_object_id                  => p_object_id
    , p_start_date                 => p_start_date
    , p_start_date_old             => p_start_date_old
    , p_end_date                   => p_end_date
    , p_end_date_old               => p_end_date_old
    , x_event_log_id               => l_event_log_id
    , p_org_id                     => p_org_id
    );

    --
    -- Check the Event Name
    --
    IF p_event_name = 'CHANGE_QUOTA_POP' THEN
      -- 1. update cn_trx_factors.event_factor
      OPEN l_quota_dates_csr;
      FETCH l_quota_dates_csr INTO l_start_date, l_end_date;
      CLOSE l_quota_dates_csr;

      l_start_period_id  := cn_api.get_acc_period_id(l_start_date, p_org_id);
      l_end_period_id    := cn_api.get_acc_period_id(l_end_date, p_org_id);

      -- clku, move get_parent_plan_elts outside the period/salesrep loop
      IF (p_object_id IS NOT NULL) THEN
        cn_calc_sql_exps_pvt.get_parent_plan_elts(
          p_api_version                => 1.0
        , p_node_type                  => 'P'
        , p_init_msg_list              => 'T'
        , p_node_id                    => p_object_id
        , x_plan_elt_id_tbl            => dependent_pe_tbl
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        );
      END IF;

      FOR affected_recs IN affected_srp_period_curs(l_start_period_id, l_end_period_id
                          , l_start_date, l_end_date) LOOP
        -- modified by rjin 11/10/1999
        -- since all affected period (including subsequent periods)
        -- are garaunteed to be marked, so we only need to mark 'NEW'
        cn_mark_events_pkg.mark_notify(
          p_salesrep_id                => affected_recs.salesrep_id
        , p_period_id                  => affected_recs.period_id
        , p_start_date                 => affected_recs.start_date
        , p_end_date                   => affected_recs.end_date
        , p_quota_id                   => affected_recs.quota_id
        , p_revert_to_state            => 'POP'
        , p_event_log_id               => l_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(affected_recs.salesrep_id, affected_recs.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => affected_recs.salesrep_id
              , p_period_id                  => affected_recs.period_id
              , p_start_date                 => affected_recs.start_date
              , p_end_date                   => affected_recs.end_date
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'POP'
              , p_event_log_id               => l_event_log_id
              , p_mode                       => 'NEW'
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_trx_factor.end'
      , 'End of mark_event_trx_factor.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_trx_factor.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_trx_factor;

  --
  -- Procedure Name
  --  mark_event_role_plans
  -- Purpose
  --   Insert affected salesrep information into cn_event_log and cn_notify_log
  --   for recalculation purpose.
  --   Calls log_event, mark_notify.
  --   Called by cn_role_plans_t trigger.
  -- History
  --   09/13/99    Harlen Chen    Created
  PROCEDURE mark_event_role_plans(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    l_role_id         cn_role_plans.role_id%TYPE;
    l_event_log_id    NUMBER;
    l_start_period_id NUMBER(15);
    l_end_period_id   NUMBER(15);
    l_date_range_tbl  cn_api.date_range_tbl_type;

    CURSOR affected_srp_period(l_s_date DATE, l_e_date DATE) IS
      -- for CHANGE_SRP_ROLE_PLAN
      -- use the start_date/end_date info to restrict the periods affected.

      -- clku perf fix for bug 3628870, removed the hintsto avoid FTS
      SELECT sr.salesrep_id salesrep_id
           , acc.period_id period_id
           , DECODE(acc.period_id, l_start_period_id, l_s_date, acc.start_date) start_date
           , DECODE(acc.period_id, l_end_period_id, NVL(l_e_date, acc.end_date), acc.end_date)
                                                                                           end_date
        FROM cn_srp_roles sr, cn_srp_intel_periods intel, cn_period_statuses acc
       WHERE sr.role_id = l_role_id
         AND sr.org_id = p_org_id
         AND acc.period_id BETWEEN l_start_period_id AND l_end_period_id
         AND acc.period_status = 'O'
         AND acc.org_id = p_org_id
         AND intel.salesrep_id = sr.salesrep_id
         AND intel.period_id = acc.period_id
         AND intel.org_id = p_org_id
         AND intel.processing_status_code <> 'CLEAN';
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_role_plans.begin'
      , 'Beginning of mark_event_role_plans ...'
      );
    END IF;

    l_role_id  := p_object_id;
    cn_mark_events_pkg.log_event(
      p_event_name
    , p_object_name
    , p_object_id
    , p_start_date
    , p_start_date_old
    , p_end_date
    , p_end_date_old
    , l_event_log_id
    , p_org_id
    );

    IF p_event_name = 'CHANGE_SRP_ROLE_PLAN' THEN
      l_start_period_id  := cn_api.get_acc_period_id(p_start_date_old, p_org_id);
      l_end_period_id    := cn_api.get_acc_period_id(p_end_date_old, p_org_id);

      FOR l_rec IN affected_srp_period(p_start_date_old, p_end_date_old) LOOP
        -- For ROLL events, pass in start_date/end_date, pass null to p_quota_id
        cn_mark_events_pkg.mark_notify(
          l_rec.salesrep_id
        , l_rec.period_id
        , l_rec.start_date
        , l_rec.end_date
        , NULL
        ,   -- p_quota_id
          'ROLL'
        , l_event_log_id
        , p_org_id
        );
      END LOOP;
    ELSIF p_event_name = 'CHANGE_SRP_ROLE_PLAN_DATE' THEN
      cn_api.get_date_range_diff(p_start_date, p_end_date, p_start_date_old, p_end_date_old
      , l_date_range_tbl);

      FOR l_ctr IN 1 .. l_date_range_tbl.COUNT LOOP
        --bug fix 6890504 raj
        l_start_period_id  :=
                         cn_api.get_acc_period_id(l_date_range_tbl(l_ctr).start_date - 1, p_org_id);
        l_end_period_id    := cn_api.get_acc_period_id(l_date_range_tbl(l_ctr).end_date, p_org_id);

        FOR l_rec IN affected_srp_period(l_date_range_tbl(l_ctr).start_date - 1
                    , l_date_range_tbl(l_ctr).end_date) LOOP
          -- ROLL events : pass in start_date/end_date, pass null to p_quota_id
          cn_mark_events_pkg.mark_notify(
            l_rec.salesrep_id
          , l_rec.period_id
          , l_rec.start_date
          , l_rec.end_date
          , NULL
          ,   -- p_quota_id
            'ROLL'
          , l_event_log_id
          , p_org_id
          );
        END LOOP;
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_role_plans.end'
      , 'End of mark_event_role_plans.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_role_plans.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_role_plans;

  --
  -- Procedure Name
  --  mark_event_srp_paygroup
  -- Purpose
  --   Insert affected salesrep information into cn_event_log and cn_notify_log files
  --   for recalculation purpose. Called from cn_paygroup_pub
  -- History
  --   01/24/03 clku created
  PROCEDURE mark_event_srp_pay_group(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_srp_object_id  NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    l_salesrep_id     cn_salesreps.salesrep_id%TYPE;
    l_pay_group_id    cn_pay_groups.pay_group_id%TYPE;
    l_event_log_id    NUMBER;
    l_start_period_id NUMBER(15);
    l_end_period_id   NUMBER(15);
    l_date_range_tbl  cn_api.date_range_tbl_type;

    CURSOR affected_srp_period(l_s_date DATE, l_e_date DATE) IS
      -- for CHANGE_SRP_ROLE_PLAN
      -- use the start_date/end_date info to restrict the periods affected.
      -- clku, perf fix for bug 3628870, removed hints to avoid FTS
      SELECT intel.salesrep_id salesrep_id
           , acc.period_id period_id
           , DECODE(acc.period_id, l_start_period_id, l_s_date, acc.start_date) start_date
           , DECODE(acc.period_id, l_end_period_id, NVL(l_e_date, acc.end_date), acc.end_date)
                                                                                           end_date
        FROM cn_period_statuses_all acc, cn_srp_intel_periods_all intel
       WHERE acc.period_id BETWEEN l_start_period_id AND l_end_period_id
         AND acc.org_id = p_org_id
         AND acc.period_status = 'O'
         AND intel.salesrep_id = l_salesrep_id
         AND intel.period_id = acc.period_id
         AND intel.org_id = acc.org_id
         AND intel.processing_status_code <> 'CLEAN';
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_pay_group.begin'
      , 'Beginning of mark_event_spr_pay_group ...'
      );
    END IF;

    l_pay_group_id  := p_object_id;
    l_salesrep_id   := p_srp_object_id;
    cn_mark_events_pkg.log_event(
      p_event_name
    , p_object_name
    , p_object_id
    , p_start_date
    , p_start_date_old
    , p_end_date
    , p_end_date_old
    , l_event_log_id
    , p_org_id
    );

    IF p_event_name = 'CHANGE_SRP_PAY_GROUP' THEN
      l_start_period_id  := cn_api.get_acc_period_id(p_start_date_old, p_org_id);
      l_end_period_id    := cn_api.get_acc_period_id(p_end_date_old, p_org_id);

      FOR l_rec IN affected_srp_period(p_start_date_old, p_end_date_old) LOOP
        -- For ROLL events, pass in start_date/end_date, pass null to p_quota_id
        cn_mark_events_pkg.mark_notify(
          l_rec.salesrep_id
        , l_rec.period_id
        , l_rec.start_date
        , l_rec.end_date
        , NULL
        ,   -- p_quota_id
          'ROLL'
        , l_event_log_id
        , p_org_id
        );
      END LOOP;
    ELSIF p_event_name = 'CHANGE_SRP_PAY_GROUP_DATE' THEN
      cn_api.get_date_range_diff(p_start_date, p_end_date, p_start_date_old, p_end_date_old
      , l_date_range_tbl);

      FOR l_ctr IN 1 .. l_date_range_tbl.COUNT LOOP
        l_start_period_id  :=
                         cn_api.get_acc_period_id(l_date_range_tbl(l_ctr).start_date - 1, p_org_id);
        l_end_period_id    := cn_api.get_acc_period_id(l_date_range_tbl(l_ctr).end_date, p_org_id);

        FOR l_rec IN affected_srp_period(l_date_range_tbl(l_ctr).start_date - 1
                    , l_date_range_tbl(l_ctr).end_date) LOOP
          -- ROLL events : pass in start_date/end_date, pass null to p_quota_id
          cn_mark_events_pkg.mark_notify(
            l_rec.salesrep_id
          , l_rec.period_id
          , l_rec.start_date
          , l_rec.end_date
          , NULL
          ,   -- p_quota_id
            'ROLL'
          , l_event_log_id
          , p_org_id
          );
        END LOOP;
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_pay_group.end'
      , 'End of mark_event_srp_pay_group.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_pay_group.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_srp_pay_group;

  --
  -- Procedure Name
  --  mark_event_srp_roles
  -- Purpose
  --   Insert affected salesrep information into cn_event_log and cn_notify_log
  --   for recalculation purpose.
  --   Calls log_event, mark_notify.
  --   Called by cn_srp_rolens_t trigger.
  -- History
  --   09/20/99    Harlen Chen    Created
  PROCEDURE mark_event_srp_roles(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    l_salesrep_id     cn_srp_roles.salesrep_id%TYPE;
    l_event_log_id    NUMBER;
    l_start_period_id NUMBER(15);
    l_end_period_id   NUMBER(15);
    l_date_range_tbl  cn_api.date_range_tbl_type;

    CURSOR affected_srp_period(l_s_date DATE, l_e_date DATE) IS
      -- for CHANGE_SRP_ROLE_PLAN
      -- use the start_date/end_date info to restrict the periods affected.
      SELECT l_salesrep_id salesrep_id
           , acc.period_id period_id
           , DECODE(acc.period_id, l_start_period_id, l_s_date, acc.start_date) start_date
           , DECODE(acc.period_id, l_end_period_id, NVL(l_e_date, acc.end_date), acc.end_date)
                                                                                           end_date
        FROM cn_period_statuses_all acc, cn_srp_intel_periods_all intel
       WHERE acc.org_id = p_org_id
         AND acc.period_id BETWEEN l_start_period_id AND l_end_period_id
         AND acc.period_status = 'O'
         AND intel.salesrep_id = l_salesrep_id
         AND intel.period_id = acc.period_id
         AND intel.org_id = acc.org_id
         AND intel.processing_status_code <> 'CLEAN';
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_roles.begin'
      , 'Beginning of mark_event_srp_roles ...'
      );
    END IF;

    l_salesrep_id  := p_object_id;
    cn_mark_events_pkg.log_event(
      p_event_name
    , p_object_name
    , p_object_id
    , p_start_date
    , p_start_date_old
    , p_end_date
    , p_end_date_old
    , l_event_log_id
    , p_org_id
    );

    IF p_event_name = 'CHANGE_SRP_ROLE_PLAN' THEN
      l_start_period_id  := cn_api.get_acc_period_id(p_start_date_old, p_org_id);
      l_end_period_id    := cn_api.get_acc_period_id(p_end_date_old, p_org_id);

      FOR l_rec IN affected_srp_period(p_start_date_old, p_end_date_old) LOOP
        -- For ROLL events, pass in start_date/end_date, pass null to p_quota_id

        -- modified by rjin 11/10/1999
        -- since all affected period (including subsequent periods)
        -- are garaunteed to be marked, so we only need to mark 'NEW'
        mark_notify(
          p_salesrep_id                => l_rec.salesrep_id
        , p_period_id                  => l_rec.period_id
        , p_start_date                 => l_rec.start_date
        , p_end_date                   => l_rec.end_date
        , p_quota_id                   => NULL
        , p_revert_to_state            => 'ROLL'
        , p_event_log_id               => l_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );
      END LOOP;
    ELSIF p_event_name = 'CHANGE_SRP_ROLE_PLAN_DATE' THEN
      cn_api.get_date_range_diff(p_start_date, p_end_date, p_start_date_old, p_end_date_old
      , l_date_range_tbl);

      FOR l_ctr IN 1 .. l_date_range_tbl.COUNT LOOP
        l_start_period_id  :=
                             cn_api.get_acc_period_id(l_date_range_tbl(l_ctr).start_date, p_org_id);
        l_end_period_id    := cn_api.get_acc_period_id(l_date_range_tbl(l_ctr).end_date, p_org_id);

        FOR l_rec IN affected_srp_period(l_date_range_tbl(l_ctr).start_date
                    , l_date_range_tbl(l_ctr).end_date) LOOP
          -- ROLL events : pass in start_date/end_date, pass null to p_quota_id
          cn_mark_events_pkg.mark_notify(
            l_rec.salesrep_id
          , l_rec.period_id
          , l_rec.start_date
          , l_rec.end_date
          , NULL
          ,   -- p_quota_id
            'ROLL'
          , l_event_log_id
          , p_org_id
          );
        END LOOP;
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_roles.end'
      , 'End of mark_event_srp_roles.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_roles.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_srp_roles;

  --
  --Start Of Comments
  --Purpose
  --This procedure marks all Sales Reps for Calculation
  --whenever there is a change in Formula_Status is modified
  -- Called from cn_calc_formulas_t1 Trigger
  -- This trigger fires when formula_status is updated
  -- COMPLETE.
  --     Event Fired is CHANGE_FORMULA
  -- History
  -- 09/19/99  ( Venkata) chalam Krishnan   Created
  --End of Comments
  PROCEDURE mark_event_formula(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    CURSOR affected_srp_period_quotas IS
      -- modified by rjin 11/10/1999 add distinct
      SELECT DISTINCT spq.salesrep_id
                    , spq.period_id
                    , spq.quota_id
                 FROM cn_quotas_all cq, cn_srp_period_quotas_all spq
                    , cn_srp_intel_periods_all intel
                WHERE cq.calc_formula_id = p_object_id
                  AND cq.org_id = p_org_id
                  AND spq.quota_id = cq.quota_id
                  AND intel.salesrep_id = spq.salesrep_id
                  AND intel.period_id = spq.period_id
                  AND intel.org_id = spq.org_id
                  AND intel.processing_status_code <> 'CLEAN'
             ORDER BY spq.quota_id;

    CURSOR l_pe_cursor(l_salesrep_id NUMBER, l_period_id NUMBER, l_quota_id NUMBER) IS
      SELECT quota_id
        FROM cn_srp_period_quotas_all
       WHERE salesrep_id = l_salesrep_id AND period_id = l_period_id AND quota_id = l_quota_id;

    temp_quota_id     cn_quotas.quota_id%TYPE;
    l_return_status   VARCHAR2(50);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    dependent_pe_tbl  cn_calc_sql_exps_pvt.num_tbl_type;
    l_latest_quota_id NUMBER                            := 0;
    l_event_log_id    NUMBER;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_formula.begin'
      , 'Beginning of mark_event_formula ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name                 => p_event_name
    , p_object_name                => p_object_name
    , p_object_id                  => p_object_id
    , p_start_date                 => p_start_date
    , p_start_date_old             => p_start_date_old
    , p_end_date                   => p_end_date
    , p_end_date_old               => p_end_date_old
    , x_event_log_id               => l_event_log_id
    , p_org_id                     => p_org_id
    );

    IF (p_event_name = 'CHANGE_FORMULA') THEN
      FOR srp_quota IN affected_srp_period_quotas LOOP
        IF l_latest_quota_id <> srp_quota.quota_id THEN
          cn_calc_sql_exps_pvt.get_parent_plan_elts(
            p_api_version                => 1.0
          , p_node_type                  => 'P'
          , p_init_msg_list              => 'T'
          , p_node_id                    => srp_quota.quota_id
          , x_plan_elt_id_tbl            => dependent_pe_tbl
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );
          l_latest_quota_id  := srp_quota.quota_id;
        END IF;

        -- modified by rjin 11/10/1999
        -- since all affected period (including subsequent periods)
        -- are garaunteed to be marked, so we only need to mark 'NEW'
        mark_notify(
          p_salesrep_id                => srp_quota.salesrep_id
        , p_period_id                  => srp_quota.period_id
        , p_start_date                 => NULL
        , p_end_date                   => NULL
        , p_quota_id                   => srp_quota.quota_id
        , p_revert_to_state            => 'CALC'
        , p_event_log_id               => l_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(srp_quota.salesrep_id, srp_quota.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => srp_quota.salesrep_id
              , p_period_id                  => srp_quota.period_id
              , p_start_date                 => NULL
              , p_end_date                   => NULL
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'CALC'
              , p_event_log_id               => l_event_log_id
              , p_mode                       => 'NEW'
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_formula.end'
      , 'End of mark_event_formula.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_formula.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_formula;

  --
  --Start Of Comments
  --Purpose
  --This procedure marks all Sales Reps for Calculation
  --whenever there is a change in Rate Dim Tiers
  --1. Insert Rate Dim Tiers
  --   Event Fired is CHANGE_RT_INS_DEL
  --2. Update Rate Dim Tiers
  --   Event Fired is CHANGE_RT_TIER
  --3. Delete Rate Dim Tiers
  --   Event fired is CHANGE_RT_INS_DEL
  --History
  --09/19/99 ( Venkata ) chalam Krishnan   Created
  --End of Comments
  PROCEDURE mark_event_rate_table(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    CURSOR affected_srp_period_quotas IS
      SELECT DISTINCT spq.salesrep_id
                    , spq.period_id
                    , spq.quota_id
                 FROM cn_srp_period_quotas_all spq, cn_srp_intel_periods_all intel
                WHERE spq.quota_id IN(
                        SELECT rt_assign.quota_id
                          FROM cn_rate_sch_dims_all rt, cn_rt_quota_asgns_all rt_assign
                         WHERE rt.rate_dimension_id = p_object_id
                           AND rt_assign.rate_schedule_id = rt.rate_schedule_id)
                  AND intel.salesrep_id = spq.salesrep_id
                  AND intel.period_id = spq.period_id
                  AND intel.org_id = spq.org_id
                  AND intel.processing_status_code <> 'CLEAN'
             ORDER BY spq.quota_id;

    l_event_log_id    NUMBER;

    CURSOR l_pe_cursor(l_salesrep_id NUMBER, l_period_id NUMBER, l_quota_id NUMBER) IS
      SELECT quota_id
        FROM cn_srp_period_quotas_all
       WHERE salesrep_id = l_salesrep_id AND period_id = l_period_id AND quota_id = l_quota_id;

    temp_quota_id     cn_quotas.quota_id%TYPE;
    l_return_status   VARCHAR2(50);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    dependent_pe_tbl  cn_calc_sql_exps_pvt.num_tbl_type;
    l_latest_quota_id NUMBER                            := 0;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_rate_table.begin'
      , 'Beginning of mark_event_rate_table ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name                 => p_event_name
    , p_object_name                => p_object_name
    , p_object_id                  => p_object_id
    , p_start_date                 => p_start_date
    , p_start_date_old             => p_start_date_old
    , p_end_date                   => p_end_date
    , p_end_date_old               => p_end_date_old
    , x_event_log_id               => l_event_log_id
    , p_org_id                     => p_org_id
    );

    IF (p_event_name IN('CHANGE_RT_TIER', 'CHANGE_RT_TIER_INS_DEL')) THEN
      FOR srp_quota IN affected_srp_period_quotas LOOP
        IF l_latest_quota_id <> srp_quota.quota_id THEN
          cn_calc_sql_exps_pvt.get_parent_plan_elts(
            p_api_version                => 1.0
          , p_node_type                  => 'P'
          , p_init_msg_list              => 'T'
          , p_node_id                    => srp_quota.quota_id
          , x_plan_elt_id_tbl            => dependent_pe_tbl
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );
          l_latest_quota_id  := srp_quota.quota_id;
        END IF;

        -- modified by rjin 11/10/1999
        -- since all affected period (including subsequent periods)
        -- are garaunteed to be marked, so we only need to mark 'NEW'
        mark_notify(
          p_salesrep_id                => srp_quota.salesrep_id
        , p_period_id                  => srp_quota.period_id
        , p_start_date                 => NULL
        , p_end_date                   => NULL
        , p_quota_id                   => srp_quota.quota_id
        , p_revert_to_state            => 'CALC'
        , p_event_log_id               => l_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(srp_quota.salesrep_id, srp_quota.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => srp_quota.salesrep_id
              , p_period_id                  => srp_quota.period_id
              , p_start_date                 => NULL
              , p_end_date                   => NULL
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'CALC'
              , p_event_log_id               => l_event_log_id
              , p_mode                       => 'NEW'
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_rate_table.end'
      , 'End of mark_event_rate_table.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_rate_table.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_rate_table;

  --
  -- Start Of Comments
  -- Purpose:
  --   This procedure marks all Sales Reps for Calculation
  --    whenever there is a change in Rate Tiers (Commission Rates).
  --
  -- 1. Insert Rate Dim Tiers
  --    Event Fired is CHANGE_RT_INS_DEL
  -- 2. Update Rate Dim Tiers
  --    Event Fired is CHANGE_RT_TIER
  -- 3. Delete Rate Dim Tiers
  --    Event fired is CHANGE_RT_INS_DEL
  --
  -- History
  --   29/08/08 (venjayar) jVenki Created
  --
  -- End of Comments
  PROCEDURE mark_event_rate_tier_table(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_dep_object_id  NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    CURSOR affected_srp_period_quotas IS
      SELECT DISTINCT spq.salesrep_id
           , spq.period_id
           , spq.quota_id
        FROM cn_srp_period_quotas spq, cn_srp_intel_periods intel
       WHERE spq.quota_id IN(
               SELECT rt_assign.quota_id
                 FROM cn_rt_quota_asgns rt_assign
                WHERE rt_assign.rate_schedule_id = p_dep_object_id)
         AND intel.salesrep_id = spq.salesrep_id
         AND intel.period_id = spq.period_id
         AND intel.processing_status_code <> 'CLEAN'
        ORDER BY spq.quota_id;

    l_event_log_id    NUMBER;

    CURSOR l_pe_cursor(l_salesrep_id NUMBER, l_period_id NUMBER, l_quota_id NUMBER) IS
      SELECT quota_id
        FROM cn_srp_period_quotas
       WHERE salesrep_id = l_salesrep_id AND period_id = l_period_id AND quota_id = l_quota_id;

    temp_quota_id     cn_quotas.quota_id%TYPE;
    l_return_status   VARCHAR2(50);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    dependent_pe_tbl  cn_calc_sql_exps_pvt.num_tbl_type;
    l_latest_quota_id NUMBER                            := 0;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_rate_tier_table.begin'
      , 'Beginning of mark_event_rate_tier_table...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name                 => p_event_name
    , p_object_name                => p_object_name
    , p_object_id                  => p_object_id
    , p_start_date                 => p_start_date
    , p_start_date_old             => p_start_date_old
    , p_end_date                   => p_end_date
    , p_end_date_old               => p_end_date_old
    , x_event_log_id               => l_event_log_id
    , p_org_id                     => p_org_id
    );

    IF (p_event_name IN('CHANGE_RT_TIER', 'CHANGE_RT_TIER_INS_DEL')) THEN
      FOR srp_quota IN affected_srp_period_quotas LOOP
        IF l_latest_quota_id <> srp_quota.quota_id THEN
          cn_calc_sql_exps_pvt.get_parent_plan_elts(
            p_api_version                => 1.0
          , p_node_type                  => 'P'
          , p_init_msg_list              => 'T'
          , p_node_id                    => srp_quota.quota_id
          , x_plan_elt_id_tbl            => dependent_pe_tbl
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );
          l_latest_quota_id  := srp_quota.quota_id;
        END IF;

        -- since all affected period (including subsequent periods)
        -- are garaunteed to be marked, so we only need to mark 'NEW'
        mark_notify(
          p_salesrep_id                => srp_quota.salesrep_id
        , p_period_id                  => srp_quota.period_id
        , p_start_date                 => NULL
        , p_end_date                   => NULL
        , p_quota_id                   => srp_quota.quota_id
        , p_revert_to_state            => 'CALC'
        , p_event_log_id               => l_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(srp_quota.salesrep_id, srp_quota.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => srp_quota.salesrep_id
              , p_period_id                  => srp_quota.period_id
              , p_start_date                 => NULL
              , p_end_date                   => NULL
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'CALC'
              , p_event_log_id               => l_event_log_id
              , p_mode                       => 'NEW'
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_rate_tier_table.end'
      , 'End of mark_event_rate_tier_table.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_rate_tier_table.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_rate_tier_table;


  -- Purpose
  --   the auxiliary procedure for mark_event_interval_number
  -- History
  --   created on 9/27/1999 by ymao
  PROCEDURE mark_notify_interval_number(
    p_event_name       VARCHAR2
  , p_interval_type_id NUMBER
  , p_period_id        NUMBER
  , p_start_date       DATE
  , p_end_date         DATE
  , p_event_log_id     NUMBER
  , p_org_id           NUMBER
  ) IS
    CURSOR affected_srp_period_quotas IS
      SELECT DISTINCT spq.salesrep_id
                    , spq.period_id
                    , spq.quota_id
                 FROM cn_quotas_all q, cn_srp_period_quotas_all spq, cn_srp_intel_periods_all intel
                WHERE q.interval_type_id = p_interval_type_id
                  AND q.org_id = p_org_id
                  AND p_end_date >= q.start_date
                  AND (q.end_date IS NULL OR p_start_date <= q.end_date)
                  AND spq.quota_id = q.quota_id
                  AND spq.period_id = p_period_id
                  AND intel.salesrep_id = spq.salesrep_id
                  AND intel.period_id = p_period_id
                  AND intel.org_id = spq.org_id
                  AND intel.processing_status_code <> 'CLEAN'
             ORDER BY spq.quota_id;

    CURSOR l_pe_cursor(l_salesrep_id NUMBER, l_period_id NUMBER, l_quota_id NUMBER) IS
      SELECT quota_id
        FROM cn_srp_period_quotas_all
       WHERE salesrep_id = l_salesrep_id AND period_id = l_period_id AND quota_id = l_quota_id;

    temp_quota_id     cn_quotas.quota_id%TYPE;
    l_return_status   VARCHAR2(50);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    dependent_pe_tbl  cn_calc_sql_exps_pvt.num_tbl_type;
    l_latest_quota_id NUMBER                            := 0;
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_notify_interval_number.begin'
      , 'Beginning of mark_notify_interval_number ...'
      );
    END IF;

    IF (p_event_name = 'CHANGE_PERIOD_INTERVAL_NUMBER') THEN
      FOR srp_quota IN affected_srp_period_quotas LOOP
        IF l_latest_quota_id <> srp_quota.quota_id THEN
          cn_calc_sql_exps_pvt.get_parent_plan_elts(
            p_api_version                => 1.0
          , p_node_type                  => 'P'
          , p_init_msg_list              => 'T'
          , p_node_id                    => srp_quota.quota_id
          , x_plan_elt_id_tbl            => dependent_pe_tbl
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );
          l_latest_quota_id  := srp_quota.quota_id;
        END IF;

        -- modified by rjin 11/10/1999
        -- since all affected period (including subsequent periods)
        -- are garaunteed to be marked, so we only need to mark 'NEW'
        mark_notify(
          p_salesrep_id                => srp_quota.salesrep_id
        , p_period_id                  => srp_quota.period_id
        , p_start_date                 => p_start_date
        ,   --NULL,
          p_end_date                   => p_end_date
        ,   --NULL,
          p_quota_id                   => srp_quota.quota_id
        , p_revert_to_state            => 'CALC'
        , p_event_log_id               => p_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(srp_quota.salesrep_id, srp_quota.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => srp_quota.salesrep_id
              , p_period_id                  => srp_quota.period_id
              , p_start_date                 => p_start_date
              , p_end_date                   => p_end_date
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'CALC'
              , p_event_log_id               => p_event_log_id
              , p_mode                       => 'NEW'
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_notify_interval_number.end'
      , 'End of mark_notify_interval_number.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_notify_interval_number.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_notify_interval_number;

  -- Purpose
  --   Upon the change of any interval number, mark all the sales reps that might be affected
  --   in terms of calculation
  -- History
  --   created on 9/27/99 by ymao
  PROCEDURE mark_event_interval_number(
    p_event_name          VARCHAR2
  , p_object_name         VARCHAR2
  , p_object_id           NUMBER
  , p_start_date          DATE
  , p_start_date_old      DATE
  , p_end_date            DATE
  , p_end_date_old        DATE
  , p_interval_type_id    NUMBER
  , p_old_interval_number NUMBER
  , p_new_interval_number NUMBER
  , p_org_id              NUMBER
  ) IS
    l_event_log_id NUMBER(15);

    CURSOR affected_periods IS
      SELECT cpit.cal_period_id
           , ps.start_date
           , ps.end_date
        FROM cn_cal_per_int_types_all cpit, cn_period_statuses_all ps
       WHERE (
                 cpit.interval_number = p_old_interval_number
              OR cpit.interval_number = p_new_interval_number
             )
         AND cpit.interval_type_id = p_interval_type_id
         AND cpit.org_id = p_org_id
         AND ps.period_id = cpit.cal_period_id
         AND ps.org_id = cpit.org_id;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_interval_number.begin'
      , 'Beginning of mark_event_interval_number ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name
    , p_object_name
    , p_object_id
    , p_start_date
    , p_start_date_old
    , p_end_date
    , p_end_date_old
    , l_event_log_id
    , p_org_id
    );

    -- get all the periods which are affected and call mark_event_interval_number for all of them
    FOR affected_period IN affected_periods LOOP
      mark_notify_interval_number(
        p_event_name
      , p_interval_type_id
      , affected_period.cal_period_id
      , affected_period.start_date
      , affected_period.end_date
      , l_event_log_id
      , p_org_id
      );
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_interval_number.end'
      , 'End of mark_event_interval_number.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_interval_number.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_interval_number;

  PROCEDURE mark_event_int_num_change(x_cal_per_int_type_id NUMBER, x_interval_number NUMBER) IS
    CURSOR c IS
      SELECT        cal_period_id
                  , interval_number
                  , interval_type_id
                  , org_id
               FROM cn_cal_per_int_types_all
              WHERE cal_per_int_type_id = x_cal_per_int_type_id
      FOR UPDATE OF cal_per_int_type_id NOWAIT;

    rec           c%ROWTYPE;

    CURSOR NAME(p_org_id NUMBER) IS
      SELECT NAME
        FROM cn_interval_types_all_tl
       WHERE interval_type_id = rec.interval_type_id AND org_id = p_org_id;

    l_object_name VARCHAR2(80);

    CURSOR dates(p_org_id NUMBER) IS
      SELECT start_date
           , end_date
        FROM cn_period_statuses_all
       WHERE period_id = rec.cal_period_id AND org_id = p_org_id;

    l_start_date  DATE;
    l_end_date    DATE;
  BEGIN
    OPEN c;
    FETCH c INTO rec;
    CLOSE c;

    -- mark the "CHANGE_PERIOD_INTERVAL_NUMBER" event for intelligent calculation
    IF (rec.interval_number <> x_interval_number AND fnd_profile.VALUE('CN_MARK_EVENTS') = 'Y') THEN
      -- get the object name which is the name of the interval type here.
      OPEN NAME(rec.org_id);
      FETCH NAME INTO l_object_name;
      CLOSE NAME;

      -- get the start_date and end_date of the corresponding period
      OPEN dates(rec.org_id);
      FETCH dates INTO l_start_date, l_end_date;
      CLOSE dates;

      cn_mark_events_pkg.mark_event_interval_number(
        'CHANGE_PERIOD_INTERVAL_NUMBER'
      , l_object_name
      , rec.interval_type_id
      , NULL
      , l_start_date
      , NULL
      , l_end_date
      , rec.interval_type_id
      , rec.interval_number
      , x_interval_number
      , rec.org_id
      );
    END IF;
  END mark_event_int_num_change;

  PROCEDURE mark_event_comp_plan(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    l_event_log_id    NUMBER;
    l_start_period_id NUMBER;
    l_end_period_id   NUMBER;

    -- 1. update cn_comp_plans
    -- 2. insert/delete cn_quota_assigns
    --
    -- bug 37709654, added hints suggested by perf team to reduce buffer gets
    CURSOR affected_srp_curs(l_start_period_id NUMBER, l_end_period_id NUMBER) IS
      SELECT          /*+ LEADING(SPA) */
             DISTINCT spa.salesrep_id
                    , acc.period_id
                    , acc.start_date
                    , acc.end_date
                 FROM cn_srp_plan_assigns_all spa
                    , cn_srp_intel_periods_all intel
                    , cn_period_statuses_all acc
                WHERE spa.comp_plan_id = p_object_id   -- comp_plan_id
                  AND acc.period_id BETWEEN l_start_period_id AND l_end_period_id
                  AND acc.org_id = spa.org_id
                  AND (
                          (
                               spa.start_date < acc.start_date
                           AND (spa.end_date IS NULL OR acc.start_date <= spa.end_date)
                          )
                       OR (spa.start_date BETWEEN acc.start_date AND acc.end_date)
                      )
                  AND EXISTS(
                        SELECT 1
                          FROM cn_srp_period_quotas_all spq
                         WHERE spa.srp_plan_assign_id = spq.srp_plan_assign_id
                           AND spq.period_id = acc.period_id)
                  AND intel.salesrep_id = spa.salesrep_id
                  AND intel.period_id = acc.period_id
                  AND intel.org_id = spa.org_id
                  AND acc.period_status IN('O', 'F')
                  AND intel.processing_status_code <> 'CLEAN';
  BEGIN
    --
    -- Log the Event for the  comp plan events  or any changes in the
    -- plan Assigns
    --
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_comp_plan.begin'
      , 'Beginning of mark_event_comp_plan ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name                 => p_event_name
    , p_object_name                => p_object_name
    , p_object_id                  => p_object_id
    , p_start_date                 => p_start_date
    , p_start_date_old             => p_start_date_old
    , p_end_date                   => p_end_date
    , p_end_date_old               => p_end_date_old
    , x_event_log_id               => l_event_log_id
    , p_org_id                     => p_org_id
    );
    l_start_period_id  := cn_api.get_acc_period_id(p_start_date_old, p_org_id);
    l_end_period_id    := cn_api.get_acc_period_id(p_end_date_old, p_org_id);

    IF p_event_name = 'CHANGE_COMP_PLAN' OR p_event_name = 'CHANGE_COMP_PLAN_OVERLAP' THEN
      FOR affected_recs IN affected_srp_curs(l_start_period_id, l_end_period_id) LOOP
        cn_mark_events_pkg.mark_notify(
          p_salesrep_id                => affected_recs.salesrep_id
        , p_period_id                  => affected_recs.period_id
        , p_start_date                 => affected_recs.start_date
        , p_end_date                   => affected_recs.end_date
        , p_quota_id                   => NULL
        , p_revert_to_state            => 'ROLL'
        , p_event_log_id               => l_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_comp_plan.end'
      , 'End of mark_event_comp_plan.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_comp_plan.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_comp_plan;

  --
  -- Procedure Name
  --   mark_event_srp_quotas
  -- Purpose
  --   mark events when cn_srp_quota_assigns is updated
  -- History
  --   09/20/99    Kai Chen    Created
  PROCEDURE mark_event_srp_quotas(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_srp_object_id  NUMBER
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    -- x_srp_object_id --> p_srp_quota_assign_id
    -- clku, perf fix 3628870, use cn_srp_period_quotas instead of cn_srp_period_quotas_v
    -- to remove MJC
    CURSOR affected_srp_period_quotas IS
      SELECT   spq.salesrep_id
             , spq.period_id
             , spq.quota_id
          FROM cn_srp_period_quotas_all spq, cn_srp_intel_periods intel
         WHERE spq.srp_quota_assign_id = p_srp_object_id   -- p_srp_quota_assign_id
           AND intel.salesrep_id = spq.salesrep_id
           AND intel.period_id = spq.period_id
           AND intel.org_id = spq.org_id
      -- scannane, bug 7154503, Notify log table update
      -- rnagaraj, bug 8568515
      AND intel.processing_status_code <> 'CLEAN'
      ORDER BY spq.quota_id;

    l_event_log_id    NUMBER(15);

    CURSOR l_pe_cursor(l_salesrep_id NUMBER, l_period_id NUMBER, l_quota_id NUMBER) IS
      SELECT quota_id
        FROM cn_srp_period_quotas_all
       WHERE salesrep_id = l_salesrep_id AND period_id = l_period_id AND quota_id = l_quota_id;

    temp_quota_id     cn_quotas.quota_id%TYPE;
    l_return_status   VARCHAR2(50);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    dependent_pe_tbl  cn_calc_sql_exps_pvt.num_tbl_type;
    l_latest_quota_id NUMBER                            := 0;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_quotas.begin'
      , 'Beginning of mark_event_srp_quotas ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name
    , p_object_name
    , p_object_id
    , p_start_date
    , p_start_date_old
    , p_end_date
    , p_end_date_old
    , l_event_log_id
    , p_org_id
    );

    IF p_event_name = 'CHANGE_SRP_QUOTA_CALC' THEN
      FOR srp_quota IN affected_srp_period_quotas LOOP
        IF l_latest_quota_id <> srp_quota.quota_id THEN
          cn_calc_sql_exps_pvt.get_parent_plan_elts(
            p_api_version                => 1.0
          , p_node_type                  => 'P'
          , p_init_msg_list              => 'T'
          , p_node_id                    => srp_quota.quota_id
          , x_plan_elt_id_tbl            => dependent_pe_tbl
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );
          l_latest_quota_id  := srp_quota.quota_id;
        END IF;

        -- modified by rjin 11/10/1999
        -- since all affected period (including subsequent periods)
        -- are garaunteed to be marked, so we only need to mark 'NEW'
        cn_mark_events_pkg.mark_notify(
          p_salesrep_id                => srp_quota.salesrep_id
        , p_period_id                  => srp_quota.period_id
        , p_start_date                 => NULL
        , p_end_date                   => NULL
        , p_quota_id                   => srp_quota.quota_id
        , p_revert_to_state            => 'CALC'
        , p_event_log_id               => l_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(srp_quota.salesrep_id, srp_quota.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => srp_quota.salesrep_id
              , p_period_id                  => srp_quota.period_id
              , p_start_date                 => NULL
              , p_end_date                   => NULL
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'CALC'
              , p_event_log_id               => l_event_log_id
              , p_mode                       => 'NEW'
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_quotas.end'
      , 'End of mark_event_srp_quotas.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_quotas.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_srp_quotas;

  -- Procedure Name
  --   mark_event_srp_uplifts
  -- Purpose
  --   mark events when cn_srp_rule_uplifts is updated
  -- History
  --   09/20/99    Kai Chen    Created
  PROCEDURE mark_event_srp_uplifts(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_srp_object_id  NUMBER
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    -- x_srp_object_id --> p_srp_quota_rule_id
    CURSOR affected_srp_period_quotas(
      l_start_period_id NUMBER
    , l_end_period_id   NUMBER
    , l_s_date          DATE
    , l_e_date          DATE
    ) IS
      SELECT   spq.salesrep_id
             , spq.period_id
             , spq.quota_id
             , DECODE(acc.period_id, l_start_period_id, l_s_date, acc.start_date) start_date
             , DECODE(acc.period_id, l_end_period_id, NVL(l_e_date, acc.end_date), acc.end_date)
                                                                                           end_date
          FROM cn_srp_quota_rules_all rule
             , cn_srp_period_quotas_all spq
             , cn_period_statuses_all acc
             , cn_srp_intel_periods_all intel
         WHERE rule.srp_quota_rule_id = p_srp_object_id   --p_srp_quota_rule_id
           AND spq.srp_plan_assign_id = rule.srp_plan_assign_id
           AND spq.srp_quota_assign_id = rule.srp_quota_assign_id
           AND acc.period_id = spq.period_id
           AND (acc.period_id BETWEEN l_start_period_id AND l_end_period_id)
           AND acc.period_status = 'O'
           AND acc.org_id = spq.org_id
           AND intel.salesrep_id = spq.salesrep_id
           AND intel.period_id = spq.period_id
           AND intel.org_id = spq.org_id
           AND intel.processing_status_code <> 'CLEAN'
      ORDER BY spq.quota_id;

    l_event_log_id         NUMBER(15);
    l_temp_start_date      DATE;
    l_temp_end_date        DATE;
    l_temp_start_period_id NUMBER(15);
    l_temp_end_period_id   NUMBER(15);

    CURSOR l_pe_cursor(l_salesrep_id NUMBER, l_period_id NUMBER, l_quota_id NUMBER) IS
      SELECT quota_id
        FROM cn_srp_period_quotas_all
       WHERE salesrep_id = l_salesrep_id AND period_id = l_period_id AND quota_id = l_quota_id;

    temp_quota_id          cn_quotas.quota_id%TYPE;
    l_return_status        VARCHAR2(50);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    dependent_pe_tbl       cn_calc_sql_exps_pvt.num_tbl_type;
    l_latest_quota_id      NUMBER                            := 0;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_uplifts.begin'
      , 'Beginning of mark_event_srp_uplifts ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name
    , p_object_name
    , p_object_id
    , p_start_date
    , p_start_date_old
    , p_end_date
    , p_end_date_old
    , l_event_log_id
    , p_org_id
    );
    l_temp_start_period_id  := cn_api.get_acc_period_id(p_start_date_old, p_org_id);
    l_temp_end_period_id    := cn_api.get_acc_period_id(p_end_date_old, p_org_id);

    IF p_event_name = 'CHANGE_SRP_QUOTA_POP' THEN
      FOR srp_quota IN affected_srp_period_quotas(
                        l_temp_start_period_id
                      , l_temp_end_period_id
                      , p_start_date_old
                      , p_end_date_old
                      ) LOOP
        IF l_latest_quota_id <> srp_quota.quota_id THEN
          cn_calc_sql_exps_pvt.get_parent_plan_elts(
            p_api_version                => 1.0
          , p_node_type                  => 'P'
          , p_init_msg_list              => 'T'
          , p_node_id                    => srp_quota.quota_id
          , x_plan_elt_id_tbl            => dependent_pe_tbl
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );
          l_latest_quota_id  := srp_quota.quota_id;
        END IF;

        cn_mark_events_pkg.mark_notify(
          srp_quota.salesrep_id
        , srp_quota.period_id
        , srp_quota.start_date
        , srp_quota.end_date
        , srp_quota.quota_id
        , 'POP'
        , l_event_log_id
        , p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(srp_quota.salesrep_id, srp_quota.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => srp_quota.salesrep_id
              , p_period_id                  => srp_quota.period_id
              , p_start_date                 => srp_quota.start_date
              , p_end_date                   => srp_quota.end_date
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'POP'
              , p_event_log_id               => l_event_log_id
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_uplifts.end'
      , 'End of mark_event_srp_uplifts.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_uplifts.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_srp_uplifts;

  -- Procedure Name
  --   mark_event_srp_rate_assigns
  -- Purpose
  --   mark events when cn_srp_rate_assigns is updated
  -- History
  --   09/20/99    Kai Chen    Created
  PROCEDURE mark_event_srp_rate_assigns(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_srp_object_id  NUMBER
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    -- x_srp_object_id --> p_srp_quota_assign_id
    CURSOR affected_srp_period_quotas(l_srp_start_period_id NUMBER, l_srp_end_period_id NUMBER) IS
      SELECT   spq.salesrep_id
             , spq.period_id
             , spq.quota_id
          FROM cn_srp_period_quotas_all spq
             , cn_period_statuses_all acc
             , cn_srp_intel_periods_all intel
         WHERE spq.srp_quota_assign_id = p_srp_object_id
           AND acc.period_id = spq.period_id
           AND acc.org_id = spq.org_id
           AND (acc.period_id BETWEEN l_srp_start_period_id AND l_srp_end_period_id)
           AND acc.period_status = 'O'
           AND intel.salesrep_id = spq.salesrep_id
           AND intel.period_id = spq.period_id
           AND intel.org_id = spq.org_id
           AND intel.processing_status_code <> 'CLEAN'
      ORDER BY spq.quota_id;

    -- very similiar to the mark_event_srp_rule_uplift when figuring out
    -- the affected srp/period/quota
    -- only difference is that this time we go to cn_rt_quota_asgns to
    -- get the start_date/ end_date
    l_event_log_id         NUMBER(15);
    l_temp_start_date      DATE;
    l_temp_end_date        DATE;
    l_temp_start_period_id NUMBER(15);
    l_temp_end_period_id   NUMBER(15);
    l_srp_start_period_id  NUMBER(15);
    l_srp_end_period_id    NUMBER(15);

    CURSOR l_pe_cursor(l_salesrep_id NUMBER, l_period_id NUMBER, l_quota_id NUMBER) IS
      SELECT quota_id
        FROM cn_srp_period_quotas_all
       WHERE salesrep_id = l_salesrep_id AND period_id = l_period_id AND quota_id = l_quota_id;

    temp_quota_id          cn_quotas.quota_id%TYPE;
    l_return_status        VARCHAR2(50);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    dependent_pe_tbl       cn_calc_sql_exps_pvt.num_tbl_type;
    l_latest_quota_id      NUMBER                            := 0;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_rate_assigns.begin'
      , 'Beginning of mark_event_srp_rate_assigns ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name
    , p_object_name
    , p_object_id
    , p_start_date
    , p_start_date_old
    , p_end_date
    , p_end_date_old
    , l_event_log_id
    , p_org_id
    );
    l_srp_start_period_id  := cn_api.get_acc_period_id(p_start_date_old, p_org_id);
    l_srp_end_period_id    := cn_api.get_acc_period_id(p_end_date_old, p_org_id);

    IF p_event_name = 'CHANGE_SRP_QUOTA_CALC' THEN
      FOR srp_quota IN affected_srp_period_quotas(l_srp_start_period_id, l_srp_end_period_id) LOOP
        IF l_latest_quota_id <> srp_quota.quota_id THEN
          cn_calc_sql_exps_pvt.get_parent_plan_elts(
            p_api_version                => 1.0
          , p_node_type                  => 'P'
          , p_init_msg_list              => 'T'
          , p_node_id                    => srp_quota.quota_id
          , x_plan_elt_id_tbl            => dependent_pe_tbl
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );
          l_latest_quota_id  := srp_quota.quota_id;
        END IF;

        cn_mark_events_pkg.mark_notify(
          srp_quota.salesrep_id
        , srp_quota.period_id
        , NULL
        , NULL
        , srp_quota.quota_id
        , 'CALC'
        , l_event_log_id
        , p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(srp_quota.salesrep_id, srp_quota.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => srp_quota.salesrep_id
              , p_period_id                  => srp_quota.period_id
              , p_start_date                 => NULL
              , p_end_date                   => NULL
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'CALC'
              , p_event_log_id               => l_event_log_id
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_rate_assigns.end'
      , 'End of mark_event_srp_rate_assigns.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_rate_assigns.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_srp_rate_assigns;

  -- Procedure Name
  --   mark_event_srp_period_quota
  -- Purpose
  --   mark events when cn_srp_period_quotas is updated
  -- History
  --   09/20/99    Kai Chen    Created
  PROCEDURE mark_event_srp_period_quota(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_srp_object_id  NUMBER
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    -- p_srp_object_id --> srp_period_quota_Id
    CURSOR affected_srp_period_quotas IS
      SELECT   spq.salesrep_id
             , spq.period_id
             , spq.quota_id
          FROM cn_srp_period_quotas_all spq, cn_srp_intel_periods_all intel
         WHERE spq.srp_period_quota_id = p_srp_object_id   -- p_srp_period_quota_id
           AND intel.salesrep_id = spq.salesrep_id
           AND intel.period_id = spq.period_id
           AND intel.org_id = spq.org_id
       -- scannane, bug 7154503, Notify log table update
       -- rnagaraj, bug 8568515
       AND intel.processing_status_code <> 'CLEAN'
      ORDER BY spq.quota_id;

    l_event_log_id    NUMBER(15);

    CURSOR l_pe_cursor(l_salesrep_id NUMBER, l_period_id NUMBER, l_quota_id NUMBER) IS
      SELECT quota_id
        FROM cn_srp_period_quotas_all
       WHERE salesrep_id = l_salesrep_id AND period_id = l_period_id AND quota_id = l_quota_id;

    temp_quota_id     cn_quotas.quota_id%TYPE;
    l_return_status   VARCHAR2(50);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    dependent_pe_tbl  cn_calc_sql_exps_pvt.num_tbl_type;
    l_latest_quota_id NUMBER                            := 0;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_period_quota.begin'
      , 'Beginning of mark_event_srp_period_quota ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name
    , p_object_name
    , p_object_id
    , p_start_date
    , p_start_date_old
    , p_end_date
    , p_end_date_old
    , l_event_log_id
    , p_org_id
    );

    IF p_event_name = 'CHANGE_SRP_QUOTA_CALC' THEN
      FOR srp_quota IN affected_srp_period_quotas LOOP
        IF l_latest_quota_id <> srp_quota.quota_id THEN
          cn_calc_sql_exps_pvt.get_parent_plan_elts(
            p_api_version                => 1.0
          , p_node_type                  => 'P'
          , p_init_msg_list              => 'T'
          , p_node_id                    => srp_quota.quota_id
          , x_plan_elt_id_tbl            => dependent_pe_tbl
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );
        END IF;

        cn_mark_events_pkg.mark_notify(
          srp_quota.salesrep_id
        , srp_quota.period_id
        , NULL
        , NULL
        , srp_quota.quota_id
        , 'CALC'
        , l_event_log_id
        , p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(srp_quota.salesrep_id, srp_quota.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => srp_quota.salesrep_id
              , p_period_id                  => srp_quota.period_id
              , p_start_date                 => NULL
              , p_end_date                   => NULL
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'CALC'
              , p_event_log_id               => l_event_log_id
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_period_quota.end'
      , 'End of mark_event_srp_period_quota.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_period_quota.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_srp_period_quota;

  -- Procedure Name
  --   mark_event_srp_period_quota
  -- Purpose
  --   mark events when cn_srp_period_quotas is updated
  -- History
  --   23/Oct/08  venjayar   Created
  PROCEDURE mark_event_srp_period_quota(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_srp_object_id  NUMBER
  , p_object_id      NUMBER
  , p_period_id      NUMBER
  , p_quota_id       NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    l_return_status   VARCHAR2(50);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_event_log_id    NUMBER(15);
    dependent_pe_tbl  cn_calc_sql_exps_pvt.num_tbl_type;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_period_quota.begin'
      , 'Beginning of mark_event_srp_period_quota ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name
    , p_object_name
    , p_object_id
    , p_start_date
    , p_start_date_old
    , p_end_date
    , p_end_date_old
    , l_event_log_id
    , p_org_id
    );

    IF p_event_name = 'CHANGE_SRP_QUOTA_CALC' THEN
      cn_calc_sql_exps_pvt.get_parent_plan_elts(
        p_api_version                => 1.0
      , p_node_type                  => 'P'
      , p_init_msg_list              => 'T'
      , p_node_id                    => p_quota_id
      , x_plan_elt_id_tbl            => dependent_pe_tbl
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      );

      cn_mark_events_pkg.mark_notify(
        p_salesrep_id       =>  p_object_id
      , p_period_id         =>  p_period_id
      , p_start_date        =>  NULL
      , p_end_date          =>  NULL
      , p_quota_id          =>  p_quota_id
      , p_revert_to_state   =>  'CALC'
      , p_event_log_id      =>  l_event_log_id
      , p_org_id            =>  p_org_id
      );

      -- We have to raise Notification Events even for the Dependent Plan Elements
      -- which are affected because of this change and it should be
      -- done only if the Dependent PE is valid for the Resource in that Period.
      -- In order to do that check, we have to validate against
      -- CN_SRP_PERIOD_QUOTAS_ALL. But since this code is executed as part of
      -- Trigger on the same table, we will run into ORA 04091 - Mutating Trigger.
      --
      -- Either we have to change the entire architecture of moving away from
      -- trigger and have table handlers and fire the events from there. Though
      -- it is a good approach.. its not possible to do such a big change now.
      --
      -- Since this code is executed as part of EO, we can surely expect that
      -- the trigger is always called for a single row only and thus even
      -- a statement level trigger will work and we wont run in Mutating Trigger
      -- Issue. But we wont be able to use :NEW and :OLD.
      --
      -- Thinking more about.. a Plan Element can be dependent on other PE's only
      -- if the Plan Elements are part of the same Compensation Plan. Thus, we
      -- be sure that the Dependent Plan Elements has to be part of the Same
      -- Compensation Plan and thus it is valid for the Resource. So temporarily
      -- removed the check. If this conclusion is wrong, then the code has to be
      -- implemented as ONE ROW LEVEL TRIGGER which will capture the Dependent PE's
      -- and another STATEMENT LEVEL TRIGGER which will do the validation and
      -- notify Dependent PE's.
      --
      IF (dependent_pe_tbl.COUNT > 0) THEN
        FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
          cn_mark_events_pkg.mark_notify(
            p_salesrep_id                => p_object_id
          , p_period_id                  => p_period_id
          , p_start_date                 => NULL
          , p_end_date                   => NULL
          , p_quota_id                   => dependent_pe_tbl(i)
          , p_revert_to_state            => 'CALC'
          , p_event_log_id               => l_event_log_id
          , p_org_id                     => p_org_id
          );
        END LOOP;
      END IF;   -- If (dependent_pe_tbl.count > 0)
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_period_quota.end'
      , 'End of mark_event_srp_period_quota.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_period_quota.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_srp_period_quota;


  -- Procedure Name
  --   mark_event_srp_payee_assign
  -- Purpose
  --   mark events when cn_srp_payee_assigns is inserted, updated and deleted
  -- History
  --   09/20/99    Kai Chen    Created
  PROCEDURE mark_event_srp_payee_assign(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_srp_object_id  NUMBER
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  ) IS
    -- p_object_id --> p_srp_quota_assign_id

    -- CHANGE_SRP_QUOTA_POP
    -- need to use the start_date/end_date info to restrict affected periods
    CURSOR affected_srp_period_quotas(
      l_start_period_id NUMBER
    , l_end_period_id   NUMBER
    , l_s_date          DATE
    , l_e_date          DATE
    ) IS
      SELECT   spq.salesrep_id
             , spq.period_id
             , spq.quota_id
             , DECODE(acc.period_id, l_start_period_id, l_s_date, acc.start_date) start_date
             , DECODE(acc.period_id, l_end_period_id, NVL(l_e_date, acc.end_date), acc.end_date)
                                                                                           end_date
          FROM cn_srp_period_quotas_all spq
             , cn_period_statuses_all acc
             , cn_srp_intel_periods_all intel
         WHERE spq.srp_quota_assign_id = p_srp_object_id   -- p_srp_quota_assign_id
           AND acc.period_id = spq.period_id
           AND acc.org_id = spq.org_id
           AND (acc.period_id BETWEEN l_start_period_id AND l_end_period_id)
           AND acc.period_status = 'O'
           AND intel.salesrep_id = spq.salesrep_id
           AND intel.period_id = spq.period_id
           AND intel.processing_status_code <> 'CLEAN'
           AND intel.org_id = spq.org_id
      ORDER BY spq.quota_id;

    l_event_log_id         NUMBER(15);
    l_temp_start_period_id NUMBER(15);
    l_temp_end_period_id   NUMBER(15);
    l_date_range_tbl       cn_api.date_range_tbl_type;

    CURSOR l_pe_cursor(l_salesrep_id NUMBER, l_period_id NUMBER, l_quota_id NUMBER) IS
      SELECT quota_id
        FROM cn_srp_period_quotas_all
       WHERE salesrep_id = l_salesrep_id AND period_id = l_period_id AND quota_id = l_quota_id;

    temp_quota_id          cn_quotas.quota_id%TYPE;
    l_return_status        VARCHAR2(50);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    dependent_pe_tbl       cn_calc_sql_exps_pvt.num_tbl_type;
    l_latest_quota_id      NUMBER                            := 0;
  BEGIN
    IF fnd_profile.VALUE('CN_MARK_EVENTS') <> 'Y' THEN
      RETURN;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_payee_assigns.begin'
      , 'Beginning of mark_event_srp_payee_assigns ...'
      );
    END IF;

    cn_mark_events_pkg.log_event(
      p_event_name
    , p_object_name
    , p_object_id
    , p_start_date
    , p_start_date_old
    , p_end_date
    , p_end_date_old
    , l_event_log_id
    , p_org_id
    );

    IF p_event_name = 'CHANGE_SRP_QUOTA_POP' THEN
      l_temp_start_period_id  := cn_api.get_acc_period_id(p_start_date_old, p_org_id);
      l_temp_end_period_id    := cn_api.get_acc_period_id(p_end_date_old, p_org_id);

      FOR srp_quota IN affected_srp_period_quotas(
                        l_temp_start_period_id
                      , l_temp_end_period_id
                      , p_start_date_old
                      , p_end_date_old
                      ) LOOP
        IF l_latest_quota_id <> srp_quota.quota_id THEN
          cn_calc_sql_exps_pvt.get_parent_plan_elts(
            p_api_version                => 1.0
          , p_node_type                  => 'P'
          , p_init_msg_list              => 'T'
          , p_node_id                    => srp_quota.quota_id
          , x_plan_elt_id_tbl            => dependent_pe_tbl
          , x_return_status              => l_return_status
          , x_msg_count                  => l_msg_count
          , x_msg_data                   => l_msg_data
          );
          l_latest_quota_id  := srp_quota.quota_id;
        END IF;

        -- modified by rjin 11/10/1999
        -- since change payee assign doesn't affect subsequent period
        -- so we only need to mark 'NEW'
        mark_notify(
          p_salesrep_id                => srp_quota.salesrep_id
        , p_period_id                  => srp_quota.period_id
        , p_start_date                 => srp_quota.start_date
        ,   --NULL,
          p_end_date                   => srp_quota.end_date
        ,   --NULL,
          p_quota_id                   => srp_quota.quota_id
        , p_revert_to_state            => 'POP'
        , p_event_log_id               => l_event_log_id
        , p_mode                       => 'NEW'
        , p_org_id                     => p_org_id
        );

        IF (dependent_pe_tbl.COUNT > 0) THEN
          FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
            OPEN l_pe_cursor(srp_quota.salesrep_id, srp_quota.period_id, dependent_pe_tbl(i));
            FETCH l_pe_cursor INTO temp_quota_id;

            IF l_pe_cursor%FOUND THEN
              cn_mark_events_pkg.mark_notify(
                p_salesrep_id                => srp_quota.salesrep_id
              , p_period_id                  => srp_quota.period_id
              , p_start_date                 => srp_quota.start_date
              , p_end_date                   => srp_quota.end_date
              , p_quota_id                   => dependent_pe_tbl(i)
              , p_revert_to_state            => 'POP'
              , p_event_log_id               => l_event_log_id
              , p_mode                       => 'NEW'
              , p_org_id                     => p_org_id
              );
            END IF;

            CLOSE l_pe_cursor;
          END LOOP;
        END IF;   -- If (dependent_pe_tbl.count > 0)
      END LOOP;
    ELSIF p_event_name = 'CHANGE_SRP_QUOTA_PAYEE_DATE' THEN
      cn_api.get_date_range_diff(p_start_date, p_end_date, p_start_date_old, p_end_date_old
      , l_date_range_tbl);

      FOR l_ctr IN 1 .. l_date_range_tbl.COUNT LOOP
        l_temp_start_period_id  :=
                             cn_api.get_acc_period_id(l_date_range_tbl(l_ctr).start_date, p_org_id);
        l_temp_end_period_id    :=
                               cn_api.get_acc_period_id(l_date_range_tbl(l_ctr).end_date, p_org_id);

        FOR srp_quota IN affected_srp_period_quotas(
                          l_temp_start_period_id
                        , l_temp_end_period_id
                        , l_date_range_tbl(l_ctr).start_date
                        , l_date_range_tbl(l_ctr).end_date
                        ) LOOP
          IF l_latest_quota_id <> srp_quota.quota_id THEN
            cn_calc_sql_exps_pvt.get_parent_plan_elts(
              p_api_version                => 1.0
            , p_node_type                  => 'P'
            , p_init_msg_list              => 'T'
            , p_node_id                    => srp_quota.quota_id
            , x_plan_elt_id_tbl            => dependent_pe_tbl
            , x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            );
            l_latest_quota_id  := srp_quota.quota_id;
          END IF;

          -- modified by rjin 11/10/1999
          -- since change payee assign doesn't affect subsequent period
          -- so we only need to mark 'NEW'
          mark_notify(
            p_salesrep_id                => srp_quota.salesrep_id
          , p_period_id                  => srp_quota.period_id
          , p_start_date                 => srp_quota.start_date
          ,   --NULL,
            p_end_date                   => srp_quota.end_date
          ,   --NULL,
            p_quota_id                   => srp_quota.quota_id
          , p_revert_to_state            => 'POP'
          , p_event_log_id               => l_event_log_id
          , p_mode                       => 'NEW'
          , p_org_id                     => p_org_id
          );

          IF (dependent_pe_tbl.COUNT > 0) THEN
            FOR i IN 0 ..(dependent_pe_tbl.COUNT - 1) LOOP
              OPEN l_pe_cursor(srp_quota.salesrep_id, srp_quota.period_id, dependent_pe_tbl(i));
              FETCH l_pe_cursor INTO temp_quota_id;

              IF l_pe_cursor%FOUND THEN
                cn_mark_events_pkg.mark_notify(
                  p_salesrep_id                => srp_quota.salesrep_id
                , p_period_id                  => srp_quota.period_id
                , p_start_date                 => srp_quota.start_date
                , p_end_date                   => srp_quota.end_date
                , p_quota_id                   => dependent_pe_tbl(i)
                , p_revert_to_state            => 'POP'
                , p_event_log_id               => l_event_log_id
                , p_mode                       => 'NEW'
                , p_org_id                     => p_org_id
                );
              END IF;

              CLOSE l_pe_cursor;
            END LOOP;
          END IF;   -- If (dependent_pe_tbl.count > 0)
        END LOOP;
      END LOOP;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_pay_assign.end'
      , 'End of mark_event_srp_payee_assign.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_event_srp_payee_assign.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_event_srp_payee_assign;

  -- mark all the reps in a single team
  PROCEDURE mark_notify_team(
    p_team_id           IN NUMBER
  , p_team_event_name   IN VARCHAR2
  , p_team_name         IN VARCHAR2
  , p_start_date_active IN DATE
  , p_end_date_active   IN DATE
  , p_event_log_id      IN NUMBER
  , p_org_id            IN NUMBER
  ) IS
    l_event_log_id      NUMBER;
    l_action_link_id    NUMBER;
    t_team_name         cn_comp_teams.NAME%TYPE;
    t_start_date_active cn_comp_teams.start_date_active%TYPE;
    t_end_date_active   cn_comp_teams.end_date_active%TYPE;
    l_revert_state      VARCHAR2(30);
    l_action            VARCHAR2(30);

    -- get all the reps in this team
    CURSOR c_all_members IS
      SELECT salesrep_id
        FROM cn_srp_comp_teams_v
       WHERE comp_team_id = p_team_id AND org_id = p_org_id;

    -- get team info
    CURSOR c_team_info(p_team_id NUMBER) IS
      SELECT NAME
           , start_date_active
           , end_date_active
        FROM cn_comp_teams
       WHERE comp_team_id = p_team_id;

    -- cursor to find all periods in the date range for each srp
    CURSOR periods(
      p_salesrep_id  NUMBER
    , p_start_date   DATE
    , p_end_date     DATE
    , p_action       VARCHAR2
    , p_revert_state VARCHAR2
    ) IS
      SELECT p.period_id
           , GREATEST(p_start_date, p.start_date) start_date
           , DECODE(p_end_date, NULL, p.end_date, LEAST(p_end_date, p.end_date)) end_date
        FROM cn_srp_intel_periods_all p
       WHERE p.salesrep_id = p_salesrep_id
         AND p.org_id = p_org_id
         AND (p_end_date IS NULL OR p.start_date <= p_end_date)
         AND (p.end_date >= p_start_date);
  BEGIN
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_notify_team.begin'
      , 'Beginning of mark_notify_team ...'
      );
    END IF;

    IF p_team_name IS NULL THEN
      OPEN c_team_info(p_team_id);
      FETCH c_team_info INTO t_team_name, t_start_date_active, t_end_date_active;
      IF (c_team_info%NOTFOUND) THEN
        CLOSE c_team_info;
        RETURN;
      END IF;

      CLOSE c_team_info;
    ELSE
      t_team_name          := p_team_name;
      t_start_date_active  := p_start_date_active;
      t_end_date_active    := p_end_date_active;
    END IF;

    IF p_event_log_id IS NULL THEN
      cn_mark_events_pkg.log_event(
        p_event_name                 => p_team_event_name
      , p_object_name                => t_team_name
      , p_object_id                  => p_team_id
      , p_start_date                 => t_start_date_active
      , p_start_date_old             => NULL
      , p_end_date                   => t_end_date_active
      , p_end_date_old               => NULL
      , x_event_log_id               => l_event_log_id
      , p_org_id                     => p_org_id
      );
    ELSE
      l_event_log_id  := p_event_log_id;
    END IF;

    IF p_team_event_name = 'CHANGE_TEAM_ADD_REP' THEN
      l_revert_state  := 'POP';
      l_action        := NULL;
    ELSE
      l_revert_state  := 'CALC';
      l_action        := 'DELETE_TEAM_MEMB';
    END IF;

    FOR c_mem_rec IN c_all_members LOOP
      FOR prd IN periods(
                  c_mem_rec.salesrep_id
                , t_start_date_active
                , t_end_date_active
                , l_action
                , l_revert_state
                ) LOOP
        cn_mark_events_pkg.mark_notify_salesreps(
          p_salesrep_id                => c_mem_rec.salesrep_id
        , p_comp_group_id              => NULL
        , p_period_id                  => prd.period_id
        , p_start_date                 => prd.start_date
        , p_end_date                   => prd.end_date
        , p_revert_to_state            => l_revert_state
        , p_action                     => l_action
        , p_action_link_id             => NULL
        , p_base_salesrep_id           => NULL
        , p_base_comp_group_id         => NULL
        , p_event_log_id               => l_event_log_id
        , x_action_link_id             => l_action_link_id
        , p_org_id                     => p_org_id
        );
      END LOOP;
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING(
        fnd_log.level_procedure
      , 'cn.plsql.cn_mark_events_pkg.mark_notify_team.end'
      , 'End of mark_notify_team.'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING(
          fnd_log.level_unexpected
        , 'cn.plsql.cn_mark_events_pkg.mark_notify_team.exception'
        , SQLERRM
        );
      END IF;

      RAISE;
  END mark_notify_team;
END cn_mark_events_pkg;

/
