--------------------------------------------------------
--  DDL for Package CN_MARK_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_MARK_EVENTS_PKG" AUTHID CURRENT_USER AS
  -- $Header: cnevents.pls 120.2.12010000.5 2009/05/02 17:46:23 rnagired ship $

  --
  -- Package Body Name
  --   cn_mark_events
  -- Purpose
  --
  -- History
  --
  --  07/12/1998  Richard Jin Created
  TYPE srp_period_date_rec_type IS RECORD(
    salesrep_id NUMBER(15)
  , period_id   NUMBER(15)
  , start_date  DATE
  , end_date    DATE
  );

  TYPE srp_period_date_tbl_type IS TABLE OF srp_period_date_rec_type
    INDEX BY BINARY_INTEGER;

    --+
    -- Name
    --   Mark_event_trx
    -- Purpose
    -- History
    --+
    --   07/12/98   Richard Jin   Created
  -- NOTES
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
  );

  PROCEDURE mark_notify(
    p_salesrep_id     IN NUMBER    --required
  , p_period_id       IN NUMBER    --required
  , p_start_date      IN DATE      --optional
  , p_end_date        IN DATE      --optional
  , p_quota_id        IN NUMBER    --optional
  , p_revert_to_state IN VARCHAR2  --required
  , p_event_log_id    IN NUMBER
  , p_org_id          IN NUMBER    --required
  );

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
  , p_role_id            IN            NUMBER DEFAULT NULL
  , x_action_link_id     OUT NOCOPY    NUMBER
  , p_org_id             IN            NUMBER
  );

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
  );

  PROCEDURE mark_event_cls_rule(
    p_event_name     IN VARCHAR2
  , p_object_name    IN VARCHAR2
  , p_object_id      IN NUMBER
  , p_start_date     IN DATE
  , p_start_date_old IN DATE
  , p_end_date       IN DATE
  , p_end_date_old   IN DATE
  , p_org_id         IN NUMBER
  );

  PROCEDURE mark_event_trx(
    x_event_name              IN VARCHAR2
  , x_object_name             IN VARCHAR2
  , x_object_id               IN NUMBER
  , x_processed_period_id_old IN NUMBER
  , x_processed_period_id_new IN NUMBER
  , x_rollup_period_id_old    IN NUMBER
  , x_rollup_period_id_new    IN NUMBER
  , p_org_id                  IN NUMBER
  );

  FUNCTION check_rev_hier(x_header_hierarchy_id NUMBER, p_org_id NUMBER)
    RETURN NUMBER;

  FUNCTION check_cls_hier(x_header_hierarchy_id NUMBER, p_org_id NUMBER)
    RETURN NUMBER;

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
  );

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
  );

  -- Start of Comments
  -- name        : mark_event_quota
  -- Type        : None
  -- Pre-reqs    : None.
  -- Usage  : Procedure to Mark the Quota Event
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
  PROCEDURE mark_event_quota(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  );

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
  );

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
  PROCEDURE mark_event_rt_quota(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  );

  --
  -- Procedure Name
  --  mark_event_role_plans
  -- Purpose
  --   Insert affected salesrep information into cn_event_log and cn_notify_log files
  --   for recalculation purpose. Called be cn_role_plans_t trigger.
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
  );

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
  );

  -- Procedure Name
  --  mark_event_srp_roles
  -- Purpose
  --   Insert affected salesrep information into cn_event_log and cn_notify_log files
  --   for recalculation purpose. Called be cn_srp_rolens_t trigger.
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
  );

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
  );

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
  );

  --
  -- Start Of Comments
  -- Purpose:
  --   This procedure marks all Sales Reps for Calculation
  --   whenever there is a change in Rate Tiers (Commission Rates).
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
  );

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
  );

  PROCEDURE mark_event_int_num_change(x_cal_per_int_type_id NUMBER, x_interval_number NUMBER);

  -- Start of Comments
  -- name        : mark_event_comp_plan
  -- Type        : None
  -- Pre-reqs    : None.
  -- Usage  : Procedure to Mark the Comp Plan  Event
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
  PROCEDURE mark_event_comp_plan(
    p_event_name     VARCHAR2
  , p_object_name    VARCHAR2
  , p_object_id      NUMBER
  , p_start_date     DATE
  , p_start_date_old DATE
  , p_end_date       DATE
  , p_end_date_old   DATE
  , p_org_id         NUMBER
  );

  -- Procedure Name
  --   mark_event_srp_quotas
  -- Purpose
  --   mark events when cn_srp_quota_assigns is updated
  -- History
  --   09/20/99    Kai Chen    Created
  --
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
  );

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
  );

  -- Procedure Name
  --   mark_event_srp_rate_assigns
  -- Purpose
  --   mark events when cn_srp_rate_assigns is updated
  -- History
  --   09/20/99    Kai Chen    Created
  --
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
  );

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
  );

  -- Procedure Name
  --   mark_event_srp_period_quota
  -- Purpose
  --   mark events when cn_srp_period_quotas is updated
  -- History
  --   23/Oct/08    jVenki (venjayar)    Created
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
  );

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
  );

  PROCEDURE mark_notify_team(
    p_team_id           IN NUMBER
  , p_team_event_name   IN VARCHAR2
  , p_team_name         IN VARCHAR2
  , p_start_date_active IN DATE
  , p_end_date_active   IN DATE
  , p_event_log_id      IN NUMBER
  , p_org_id            IN NUMBER
  );
END cn_mark_events_pkg;

/
