--------------------------------------------------------
--  DDL for Package CST_ACCOUNTINGPERIOD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_ACCOUNTINGPERIOD_PUB" AUTHID CURRENT_USER AS
/* $Header: CSTPAPES.pls 120.1.12010000.2 2008/11/10 14:19:26 mpuranik ship $ */


  -- Start of comments
  -- API name        : Get_PendingTcount
  -- Type            : Public
  -- Pre-reqs        : None
  -- Function        : This procedure gets the number of pending transactions
  --                   outstanding for the given period. The existence of
  --                   pending transactions for which resolution is required
  --                   will prevent period close from continuing.
  --
  --                   Type of transaction                    Required?
  --                   -------------------                    -----------------
  --                   Unprocessed Material transactions      Yes
  --                   Uncosted Transactions                  Yes
  --                   Pending WIP costing transactions       Yes
  --                   Uncosted WSM transactions              Yes
  --                   Pending WSM interface transactions     Yes
  --                   Pending shipping delivery transactions depends on client
  --                   Unprocessed receiving transactions     No
  --                   Pending material transactions          No
  --                   Pending shop floor move transactions   No
  --                   Released EAM work orders               No
  -- Parameters      :
  --                   p_api_version          IN         NUMBER  Required
  --                   p_org_id               IN         INTEGER Required
  --                   p_closing_period       IN         INTEGER Required
  --                   p_sched_close_date     IN         DATE    Required
  --                   x_pend_receiving       OUT NOCOPY INTEGER
  --                   x_unproc_matl          OUT NOCOPY INTEGER
  --                   x_pend_matl            OUT NOCOPY INTEGER
  --                   x_uncost_matl          OUT NOCOPY INTEGER
  --                   x_pend_move            OUT NOCOPY INTEGER
  --                   x_pend_wip_cost        OUT NOCOPY INTEGER
  --                   x_uncost_wsm           OUT NOCOPY INTEGER
  --                   x_pending_wsm          OUT NOCOPY INTEGER
  --                   x_pending_ship         OUT NOCOPY INTEGER
  --                   x_released_work_orders OUT NOCOPY INTEGER
  --                   x_return_status        OUT NOCOPY VARCHAR2
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Get_PendingTcount(
    p_api_version          IN         NUMBER,
    p_org_id               IN         INTEGER,
    p_closing_period       IN         INTEGER,
    p_sched_close_date     IN         DATE,
    x_pend_receiving       OUT NOCOPY INTEGER,
    x_unproc_matl          OUT NOCOPY INTEGER,
    x_pend_matl            OUT NOCOPY INTEGER,
    x_uncost_matl          OUT NOCOPY INTEGER,
    x_pend_move            OUT NOCOPY INTEGER,
    x_pend_wip_cost        OUT NOCOPY INTEGER,
    x_uncost_wsm           OUT NOCOPY INTEGER,
    x_pending_wsm          OUT NOCOPY INTEGER,
    x_pending_ship         OUT NOCOPY INTEGER,
    /* LCM Project */
    x_pending_lcm          OUT NOCOPY INTEGER,
    x_released_work_orders OUT NOCOPY INTEGER,
    x_return_status        OUT NOCOPY VARCHAR2
  );

  -- Start of comments
  -- API name        : Open_Period
  -- Type            : Public
  -- Pre-reqs        : None
  -- Function        : Opens a 'future' period after verifying that the period
  --                   may be opened.
  -- Parameters      : p_api_version               IN         NUMBER   Required
  --                   p_org_id                    IN            NUMBER
  --                   p_user_id                   IN            NUMBER
  --                   p_login_id                  IN            NUMBER
  --                   p_acct_period_type          IN            VARCHAR2
  --                   p_org_period_set_name       IN            VARCHAR2
  --                   p_open_period_name          IN            VARCHAR2
  --                   p_open_period_year          IN            NUMBER
  --                   p_open_period_num           IN            NUMBER
  --                   x_last_scheduled_close_date IN OUT NOCOPY DATE
  --                   p_period_end_date           IN            DATE
  --                   x_prior_period_open         OUT NOCOPY    BOOLEAN
  --                   x_new_acct_period_id        IN OUT NOCOPY NUMBER
  --                   x_duplicate_open_period     OUT NOCOPY    BOOLEAN
  --                   x_commit_complete           OUT NOCOPY    BOOLEAN
  --                   x_return_status             OUT NOCOPY    VARCHAR2
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Open_Period(
    p_api_version               IN            NUMBER,
    p_org_id                    IN            NUMBER,
    p_user_id                   IN            NUMBER,
    p_login_id                  IN            NUMBER,
    p_acct_period_type          IN            VARCHAR2,
    p_org_period_set_name       IN            VARCHAR2,
    p_open_period_name          IN            VARCHAR2,
    p_open_period_year          IN            NUMBER,
    p_open_period_num           IN            NUMBER,
    x_last_scheduled_close_date IN OUT NOCOPY DATE,
    p_period_end_date           IN            DATE,
    x_prior_period_open         OUT NOCOPY    BOOLEAN,
    x_new_acct_period_id        IN OUT NOCOPY NUMBER,
    x_duplicate_open_period     OUT NOCOPY    BOOLEAN,
    x_commit_complete           OUT NOCOPY    BOOLEAN,
    x_return_status             OUT NOCOPY    VARCHAR2
  );

  -- Start of comments
  -- API name        : Verify_PeriodClose
  -- Type            : Public
  -- Pre-reqs        : None
  -- Function        : Checks that necessary conditions are met prior to
  --                   closing a period.
  -- Parameters      : p_api_version            IN         NUMBER   Required
  --                   p_org_id                 IN         NUMBER
  --                   p_closing_acct_period_id IN         NUMBER
  --                   p_closing_end_date       IN         DATE
  --                   x_open_period_exists     OUT NOCOPY BOOLEAN
  --                   x_proper_order           OUT NOCOPY BOOLEAN
  --                   x_end_date_is_past       OUT NOCOPY BOOLEAN
  --                   x_download_in_process    OUT NOCOPY BOOLEAN
  --                   x_prompt_to_reclose      OUT NOCOPY BOOLEAN
  --                   x_return_status          OUT NOCOPY VARCHAR2
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Verify_PeriodClose(
    p_api_version             IN         NUMBER,
    p_org_id                  IN         NUMBER,
    p_closing_acct_period_id  IN         NUMBER,
    p_closing_end_date        IN         DATE,
    x_open_period_exists      OUT NOCOPY BOOLEAN,
    x_proper_order            OUT NOCOPY BOOLEAN,
    x_end_date_is_past        OUT NOCOPY BOOLEAN,
    x_download_in_process     OUT NOCOPY BOOLEAN,
    x_prompt_to_reclose       OUT NOCOPY BOOLEAN,
    x_return_status           OUT NOCOPY VARCHAR2
  );

  -- Start of comments
  -- API name        : Close_Period
  -- Type            : Public
  -- Pre-reqs        : None
  -- Function        : Closes a period and transfers to GL.
  -- Parameters      : p_api_version            IN            NUMBER   Required
  --                   p_org_id                 IN            NUMBER
  --                   p_user_id                IN            NUMBER
  --                   p_login_id               IN            NUMBER
  --                   p_closing_acct_period_id IN            NUMBER
  --                   x_wip_failed             IN OUT NOCOPY BOOLEAN
  --                   x_close_failed           OUT NOCOPY    BOOLEAN
  --                   x_req_id                 IN OUT NOCOPY NUMBER
  --                   x_unprocessed_txn        OUT NOCOPY    BOOLEAN
  --                   x_rec_rpt_launch_failed  OUT NOCOPY    BOOLEAN
  --                   x_return_status          OUT NOCOPY    VARCHAR2
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Close_Period(
    p_api_version            IN            NUMBER,
    p_org_id                 IN            NUMBER,
    p_user_id                IN            NUMBER,
    p_login_id               IN            NUMBER,
    p_closing_acct_period_id IN            NUMBER,
    x_wip_failed             IN OUT NOCOPY BOOLEAN,
    x_close_failed           OUT NOCOPY    BOOLEAN,
    x_req_id                 IN OUT NOCOPY NUMBER,
    x_unprocessed_txns       OUT NOCOPY    BOOLEAN,
    x_rec_rpt_launch_failed  OUT NOCOPY    BOOLEAN,
    x_return_status          OUT NOCOPY    VARCHAR2
  );

  -- Start of comments
  -- API name        : Update_EndDate
  -- Type            : Public
  -- Pre-reqs        : None
  -- Function        : Updates the period end date in ORG_ACCT_PERIODS.
  --                   The start date of the following period is also changed
  --                   to ensure no gaps exist between periods.
  -- Parameters      : p_api_version            IN         NUMBER  Required
  --                   p_org_id                 IN         NUMBER  Required
  --                   p_new_end_date           IN         DATE    Required
  --                   p_changed_acct_period_id IN         NUMBER
  --                   p_user_id                IN         NUMBER
  --                   p_login_id               IN         NUMBER
  --                   x_period_order           OUT NOCOPY BOOLEAN
  --                   x_update_failed          OUT NOCOPY BOOLEAN
  --                   x_return_status          OUT NOCOPY VARCHAR2
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Update_EndDate(
    p_api_version            IN         NUMBER,
    p_org_id                 IN         NUMBER,
    p_new_end_date           IN         DATE,
    p_changed_acct_period_id IN         NUMBER,
    p_user_id                IN         NUMBER,
    p_login_id               IN         NUMBER,
    x_period_order           OUT NOCOPY BOOLEAN,
    x_update_failed          OUT NOCOPY BOOLEAN,
    x_return_status          OUT NOCOPY VARCHAR2
  );

  -- Start of comments
  -- API name        : Revert_PeriodStatus
  -- Type            : Public
  -- Pre-reqs        : None
  -- Function        : Change status of period from 'Open' to 'Future' by
  --                   deleting period row from ORG_ACCT_PERIODS.
  -- Parameters      : p_api_version     IN         NUMBER  Required
  --                   p_org_id          IN         NUMBER  Required
  --                   x_acct_period_id  IN         NUMBER  Required
  --                   x_revert_complete OUT NOCOPY BOOLEAN
  --                   x_return_status   OUT NOCOPY VARCHAR2
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Revert_PeriodStatus(
    p_api_version     IN         NUMBER,
    p_org_id          IN         NUMBER,
    x_acct_period_id  IN         NUMBER,
    x_revert_complete OUT NOCOPY BOOLEAN,
    x_return_status   OUT NOCOPY VARCHAR2
  );

  -- Start of comments
  -- API name        : Summarize_Period
  -- Type            : Public
  -- Pre-reqs        : None
  -- Function        : Summarizes accounting information for the given
  --                   period from MTL_TRANSACTION_ACCOUNTS into the table
  --                   CST_PERIOD_CLOSE_SUMMARY. If the period specified
  --                   has not yet been closed, the summary will be considered
  --                   a simulation, and data will be written to
  --                   CST_PERIOD_CLOSE_SUMMARY_TEMP instead.
  -- Parameters      : p_api_version     IN         NUMBER Required
  --                   p_org_id          IN         NUMBER Required
  --                   p_period_id       IN         NUMBER Required
  --                   p_to_date         IN         DATE
  --                   p_user_id         IN         NUMBER
  --                   p_login_id        IN         NUMBER
  --                   x_return_status   OUT NOCOPY VARCHAR2
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments
  PROCEDURE Summarize_Period(
    p_api_version     IN         NUMBER,
    p_org_id          IN         NUMBER,
    p_period_id       IN         NUMBER,
    p_to_date         IN         DATE,
    p_user_id         IN         NUMBER,
    p_login_id        IN         NUMBER,
    p_simulation      IN         NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_data        OUT NOCOPY VARCHAR2
  );

END CST_AccountingPeriod_PUB;

/
