--------------------------------------------------------
--  DDL for Package GMF_PERIODCLOSE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_PERIODCLOSE_PUB" AUTHID CURRENT_USER AS
/* $Header: GMFPIAPS.pls 120.2 2005/12/22 16:17:15 umoogala noship $ */


  -- Start of comments
  -- API name        : Get_PendingTxnCount
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
  --                   Pending shipping delivery transactions Yes
  --                   Unprocessed receiving transactions     No
  --                   Pending material transactions          No
  --
  -- Parameters      :
  --                   p_api_version          IN         NUMBER  Required
  --                   p_org_id               IN         INTEGER Required
  --                   p_closing_period       IN         INTEGER Required
  --                   p_sched_close_date     IN         DATE    Required
  --                   x_pend_receiving       OUT NOCOPY INTEGER
  --                   x_unproc_matl          OUT NOCOPY INTEGER
  --                   x_pend_matl            OUT NOCOPY INTEGER
  --                   x_pending_ship         OUT NOCOPY INTEGER
  --                   x_return_status        OUT NOCOPY VARCHAR2
  -- Version         : Current version 1.0
  --                   Initial version 1.0
  -- End of comments

  PROCEDURE Get_PendingTxnCount(
    p_api_version          IN         NUMBER,
    p_org_id               IN         INTEGER,
    p_closing_period       IN         INTEGER,
    p_sched_close_date     IN         DATE,
    x_pend_receiving       OUT NOCOPY INTEGER,
    x_unproc_matl          OUT NOCOPY INTEGER,
    x_pend_matl            OUT NOCOPY INTEGER,
    x_pending_ship         OUT NOCOPY INTEGER,
    x_return_status        OUT NOCOPY VARCHAR2
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
    x_prompt_to_reclose       OUT NOCOPY    BOOLEAN,
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
  --                   p_period_close_date      IN            DATE
  --                   p_schedule_close_date    IN            DATE
  --                   p_closing_rowid          IN            VARCHAR2
  --                   x_wip_failed             IN OUT NOCOPY BOOLEAN
  --                   x_close_failed           OUT NOCOPY    BOOLEAN
  --                   x_download_failed        OUT NOCOPY    BOOLEAN
  --                   x_req_id                 IN OUT NOCOPY NUMBER
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
    p_period_close_date      IN            DATE,
    p_schedule_close_date    IN            DATE,
    x_close_failed           OUT NOCOPY    BOOLEAN,
    x_return_status          OUT NOCOPY    VARCHAR2,
    x_req_id                 OUT NOCOPY    NUMBER
  );

  PROCEDURE get_prev_inv_period_status(
    p_legal_entity_id        IN            VARCHAR2,
    p_cost_type_id           IN            VARCHAR2,
    p_period_end_date        IN            DATE,
    x_close_status           OUT NOCOPY    BOOLEAN,
    x_inv_period_year        OUT NOCOPY    NUMBER,
    x_inv_period_num         OUT NOCOPY    NUMBER,
    x_return_status          OUT NOCOPY    VARCHAR2,
    x_errbuf                 OUT NOCOPY    VARCHAR2
  );

END GMF_PeriodClose_PUB;


 

/
