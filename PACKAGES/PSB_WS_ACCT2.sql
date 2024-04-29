--------------------------------------------------------
--  DDL for Package PSB_WS_ACCT2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_ACCT2" AUTHID CURRENT_USER AS
/* $Header: PSBVWA2S.pls 120.5.12010000.3 2009/04/15 07:07:21 rkotha ship $ */

  TYPE g_defccid_rec_type IS RECORD
     ( budget_group_id     NUMBER,
       num_proposed_years  NUMBER,
       ccid                NUMBER,
       ccid_start_period   DATE,
       ccid_end_period     DATE );

  TYPE g_defccid_tbl_type IS TABLE OF g_defccid_rec_type
    INDEX BY BINARY_INTEGER;

  g_deferred_ccids         g_defccid_tbl_type;
  g_num_defccids           NUMBER;

  TYPE g_sortccid_rec_type IS RECORD
     ( budget_group_id     NUMBER,
       num_proposed_years  NUMBER,
       ccid                NUMBER,
       ccid_start_period   DATE,
       ccid_end_period     DATE );

  TYPE g_sortccid_tbl_type IS TABLE OF g_sortccid_rec_type
    INDEX BY BINARY_INTEGER;

  g_sorted_ccids           g_sortccid_tbl_type;
  g_num_sortccids          NUMBER;

  --bug 3704360.defined the following public variable.
  g_running_total          NUMBER;

  TYPE g_depccid_rec_type IS RECORD
      (ccid            NUMBER,
       dependent_ccid  NUMBER );

  TYPE g_depccid_tbl_type IS TABLE OF g_depccid_rec_type
    INDEX BY BINARY_INTEGER;

  g_dependent_ccids        g_depccid_tbl_type;
  g_num_depccids           NUMBER;
  /*Bug:5876100:start*/
  g_ugb_create_est_bal      VARCHAR2(1) := 'N';
  /*Bug:5876100:end*/

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Worksheet_Accounts
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/16/1997 by Supriyo Ghosh
  --                            Modified 06/25/1997 by Supriyo Ghosh
  --                            Modified 09/02/1997 by Supriyo Ghosh
  --                             Included 2 new Parameters for BC
  --
  --    Notes           : Create Worksheet Account Lines for Budget Group
  --                      after applying all Account Parameters specified
  --                      in the Parameter Set and distributing the Account
  --                      Lines using the Allocation Rules
  --

PROCEDURE Create_Worksheet_Accounts
( p_return_status              OUT  NOCOPY  VARCHAR2,
  p_worksheet_id               IN   NUMBER,
  p_rounding_factor            IN   NUMBER,
  p_stage_set_id               IN   NUMBER,
  p_service_package_id         IN   NUMBER,
  p_start_stage_seq            IN   NUMBER,
  p_allocrule_set_id           IN   NUMBER,
  p_budget_group_id            IN   NUMBER,
  p_flex_code                  IN   NUMBER,
  p_parameter_set_id           IN   NUMBER,
  p_budget_calendar_id         IN   NUMBER,
  p_gl_cutoff_period           IN   DATE,
  p_include_gl_commit_balance  IN   VARCHAR2,
  p_include_gl_oblig_balance   IN   VARCHAR2,
  p_include_gl_other_balance   IN   VARCHAR2,
  p_budget_version_id          IN   NUMBER,
  p_flex_mapping_set_id        IN   NUMBER,
  p_gl_budget_set_id           IN   NUMBER,
  p_set_of_books_id            IN   NUMBER,
  p_set_of_books_name          IN   VARCHAR2,
  p_func_currency              IN   VARCHAR2,
  p_budgetary_control          IN   VARCHAR2,
  p_incl_stat_bal              IN   VARCHAR2,
  p_incl_trans_bal             IN   VARCHAR2,
  p_incl_adj_period            IN   VARCHAR2,
  p_num_proposed_years         IN   NUMBER,
  p_num_years_to_allocate      IN   NUMBER,
  p_budget_by_position         IN   VARCHAR2,
  /* Bug No 4725091 */
  P_incl_gl_fwd_balance        IN   VARCHAR2
);

/* ----------------------------------------------------------------------- */

  --    API name        : Update_GL_Balances
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/20/1998 by Supriyo Ghosh
  --
  --    Notes           : Update CY GL Balances
  --

PROCEDURE Update_GL_Balances
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Revise_Account_Projections
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --
  --    Notes           : Revise Account Projections
  --

PROCEDURE Revise_Account_Projections
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_parameter_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Process_Deferred_CCIDs
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --
  --    Notes           : Process accounts that were deferred for processing
  --

PROCEDURE Process_Deferred_CCIDs
( p_return_status          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id           IN   NUMBER,
  p_service_package_id     IN   NUMBER,
  p_sequence_number        IN   NUMBER,
  p_gl_cutoff_period       IN   DATE,
  p_allocrule_set_id       IN   NUMBER,
  p_rounding_factor        IN   NUMBER,
  p_stage_set_id           IN   NUMBER,
  p_flex_code              IN   NUMBER,
  p_flex_mapping_set_id    IN   NUMBER,
  p_func_currency          IN   VARCHAR2,
  p_num_years_to_allocate  IN   NUMBER,
  p_parameter_set_id       IN   NUMBER,
  p_budget_calendar_id     IN   NUMBER,
  p_budget_by_position     IN   VARCHAR2
);

/* ----------------------------------------------------------------------- */

  --    API name        : Apply_Account_Parameters
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/18/1997 by Supriyo Ghosh
  --                            Changed 10/28/1997 by Supriyo Ghosh
  --                              Added Parameters for Volume Inserts
  --                            Changed 11/14/1997 by Supriyo Ghosh
  --                              Added Parameters for Deferred Processing
  --
  --    Notes           : Apply Account Parameters for a specific CCID
  --

PROCEDURE Apply_Account_Parameters
( p_api_version            IN   NUMBER,
  p_validation_level       IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id           IN   NUMBER,
  p_service_package_id     IN   NUMBER,
  p_start_stage_seq        IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq      IN   NUMBER,
  p_rounding_factor        IN   NUMBER := FND_API.G_MISS_NUM,
  p_stage_set_id           IN   NUMBER,
  p_budget_group_id        IN   NUMBER,
  p_allocrule_set_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_gl_cutoff_period       IN   DATE := FND_API.G_MISS_DATE,
  p_flex_code              IN   NUMBER := FND_API.G_MISS_NUM,
  p_func_currency          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_flex_mapping_set_id    IN   NUMBER := FND_API.G_MISS_NUM,
  p_ccid                   IN   NUMBER,
  p_ccid_start_period      IN   DATE,
  p_ccid_end_period        IN   DATE,
  p_num_proposed_years     IN   NUMBER,
  p_num_years_to_allocate  IN   NUMBER := FND_API.G_MISS_NUM,
  p_parameter_set_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_by_position     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_defer_ccids            IN   VARCHAR2 := FND_API.G_TRUE
);

/* ----------------------------------------------------------------------- */

  --    API name        : Distribute_Account_Lines
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/18/1997 by Supriyo Ghosh
  --
  --    Notes           : Distribute Account Lines using Allocation Rules
  --

PROCEDURE Distribute_Account_Lines
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_flex_mapping_set_id   IN   NUMBER,
  p_budget_year_type_id   IN   NUMBER,
  p_allocrule_set_id      IN   NUMBER,
  p_budget_calendar_id    IN   NUMBER,
  p_currency_code         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ccid                  IN   NUMBER,
  p_ytd_amount            IN   NUMBER,
  p_allocation_type       IN   VARCHAR2,
/* Bug No 2342169 Start */
  p_rounding_factor       IN   NUMBER,
/* Bug No 2342169 End */
  p_effective_start_date  IN   DATE,
  p_effective_end_date    IN   DATE,
  p_budget_periods        IN   PSB_WS_ACCT1.g_budgetperiod_tbl_type,
  p_period_amount         OUT  NOCOPY  PSB_WS_ACCT1.g_prdamt_tbl_type
);

/* ----------------------------------------------------------------------- */

  --    API name        : Distribute_Account_Lines
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 07/11/1997 by SGhosh
  --                            Changed 10/28/1997 by Supriyo Ghosh
  --                              Added Parameters for Volume Inserts
  --
  --    Notes           : Redistribute YTD Amounts for Account Lines
  --

PROCEDURE Distribute_Account_Lines
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_current_stage_seq   IN   NUMBER,
  p_account_line_id     IN   NUMBER,
  p_rounding_factor     IN   NUMBER,
  p_old_ytd_amount      IN   NUMBER,
  p_new_ytd_amount      IN   NUMBER,
  -- Bug#3128597: Support prorated allocation during annual amount updation
  p_cy_ytd_amount       IN   NUMBER := NULL,
  -- Bug#3128597: End
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Rollup_Totals
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/18/1997 by Supriyo Ghosh
  --                            Modified 06/25/1997 by Supriyo Ghosh
  --
  --    Notes           : Create Summary Rollups for Worksheet Accounts
  --

PROCEDURE Create_Rollup_Totals
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_rounding_factor     IN   NUMBER := FND_API.G_MISS_NUM,
  p_stage_set_id        IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER := FND_API.G_MISS_NUM,
  p_set_of_books_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_flex_code           IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id  IN   NUMBER := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */

  --    API name        : Get_Debug
  --    Type            : Private
  --    Pre-reqs        : None

FUNCTION Get_Debug RETURN VARCHAR2;

/* ----------------------------------------------------------------------- */

END PSB_WS_ACCT2;

/
