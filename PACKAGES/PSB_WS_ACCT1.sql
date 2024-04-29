--------------------------------------------------------
--  DDL for Package PSB_WS_ACCT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_ACCT1" AUTHID CURRENT_USER AS
/* $Header: PSBVWA1S.pls 120.8.12010000.3 2009/04/28 06:04:01 rkotha ship $ */

  cursor c_Distribute_WS (GlobalWSID NUMBER, BudgetGroupID NUMBER,
			  StartDate DATE, EndDate DATE) is
    select worksheet_id
      from PSB_WORKSHEETS
     where nvl(global_worksheet_id, worksheet_id) = GlobalWSID
       /*For Bug No : 2440100 Start*/
       and worksheet_type <> 'L'
       /*For Bug No : 2440100 End*/
       and budget_group_id in
	  (select budget_group_id
	     from PSB_BUDGET_GROUPS
	    where budget_group_type = 'R'
	      and effective_start_date <= StartDate
	      and (effective_end_date is null or effective_end_date >= EndDate)
	    start with budget_group_id = BudgetGroupID
	    connect by prior parent_budget_group_id = budget_group_id);

  TYPE g_budgetyear_rec_type IS RECORD
     ( budget_year_id       NUMBER,
       budget_year_type_id  NUMBER,
       year_type            VARCHAR2(10),
       year_name            VARCHAR2(15),
       start_date           DATE,
       end_date             DATE,
       num_budget_periods   NUMBER,
       last_period_index    NUMBER );

  TYPE g_budgetyear_tbl_type IS TABLE OF g_budgetyear_rec_type
      INDEX BY BINARY_INTEGER;

  g_budget_years         g_budgetyear_tbl_type;
  g_num_budget_years     NUMBER;

  TYPE g_budgetperiod_rec_type IS RECORD
     ( budget_period_id    NUMBER,
       budget_period_type  VARCHAR2(1),
       long_sequence_no    NUMBER,
       start_date          DATE,
       end_date            DATE,
       budget_year_id      NUMBER,
       num_calc_periods    NUMBER );

  TYPE g_budgetperiod_tbl_type IS TABLE OF g_budgetperiod_rec_type
      INDEX BY BINARY_INTEGER;

  g_budget_periods       g_budgetperiod_tbl_type;
  g_num_budget_periods   NUMBER;

  -- Bug#3126462: Support Percent type allocation rules for CY estimates
  -- Global variable to store number of periods in CY.
  g_cy_num_periods      NUMBER := 0 ;

  TYPE g_calcperiod_rec_type IS RECORD
     ( calc_period_id    NUMBER,
       calc_period_type  VARCHAR2(1),
       start_date        DATE,
       end_date          DATE,
       budget_period_id  NUMBER );

  TYPE g_calcperiod_tbl_type IS TABLE OF g_calcperiod_rec_type
      INDEX BY BINARY_INTEGER;

  g_calculation_periods  g_calcperiod_tbl_type;
  g_num_calc_periods     NUMBER;

  g_max_num_amounts      CONSTANT NUMBER := 60;
  g_checkpoint_save      CONSTANT NUMBER := 500;
  g_limit_bulk_numrows   CONSTANT NUMBER := 1000;

  TYPE g_prdamt_tbl_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

  TYPE g_ccid_rec_type IS RECORD
     ( ccid          NUMBER,
       start_date    DATE,
       end_date      DATE );

  TYPE g_ccid_tbl_type IS TABLE OF g_ccid_rec_type
      INDEX BY BINARY_INTEGER;

  g_account_set_id       NUMBER;
  g_ccids                g_ccid_tbl_type;
  g_num_ccids            NUMBER;

  TYPE SegNamArray IS TABLE OF VARCHAR2(9)
    INDEX BY BINARY_INTEGER;

  g_flex_code            NUMBER;
  g_seg_name             SegNamArray;
  g_num_segs             NUMBER;

  g_budget_calendar_id   NUMBER;
  g_startdate_pp         DATE;
  g_startdate_cy         DATE;
  g_enddate_cy           DATE;
  g_end_est_date         DATE;
  g_max_num_years        NUMBER;

  /*Bug:5929875:start*/
  g_gl_cutoff_period     DATE;
  g_allocrule_set_id     NUMBER;
  gl_budget_calendar_id  NUMBER;
  g_rounding_factor      NUMBER;
  g_stage_set_id         NUMBER;
  g_flex_mapping_set_id  NUMBER;

  g_global_worksheet_id  NUMBER;
  g_local_copy_flag      VARCHAR2(1);
  g_current_stage_seq    NUMBER;

  g_set_of_books_id      NUMBER;
  g_budget_group_id      NUMBER;

  g_root_budget_group_id NUMBER;

  TYPE g_bg_ccid_type IS RECORD
   (ccid              NUMBER,
    budget_group_id   NUMBER);


  TYPE g_bg_ccid_tbl_type IS TABLE OF g_bg_ccid_type INDEX BY BINARY_INTEGER;

  g_bg_ccid_tbl g_bg_ccid_tbl_type;

  /*Bug:5929875:end*/


/* Bug No 2354918 Start */
  g_cy_start_index      NUMBER := 0;
/* Bug No 2354918 End */

-- Bug#4675858
-- Introducing packaged global variable to change
-- "Revise Projections" CP if it holds TRUE value.
g_soft_error_flag        BOOLEAN := FALSE ;

/* ----------------------------------------------------------------------- */

  --    API name        : Cache_Budget_Calendar
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/16/1997 by Supriyo Ghosh
  --
  --    Notes           : Cache Budget Calendar
  --

PROCEDURE Cache_Budget_Calendar
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_budget_calendar_id  IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Get_Budget_Calendar_Info
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 26-MAR-1998 by Shailendra Rawat
  --
  --    Notes           : This API is a wrapper for Cache_Budget_Calendar API.
  --                      Created as PL/SQL 1.0 cannot use Cache_Budget_Calendar
  --                      API because it sets values in package variables.
  --                      This API will be basically used by Oracle*Reports.
  --

PROCEDURE Get_Budget_Calendar_Info
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_budget_calendar_id  IN   NUMBER,
  p_startdate_pp        OUT  NOCOPY  DATE,
  p_enddate_cy          OUT  NOCOPY  DATE
);

/* ----------------------------------------------------------------------- */

-- Map Account based on flex mapping set

FUNCTION Map_Account
( p_flex_mapping_set_id  IN  NUMBER,
  p_ccid                 IN  NUMBER,
  p_budget_year_type_id  IN  NUMBER
) RETURN NUMBER;

/* ----------------------------------------------------------------------- */

  --    API name        : Check_CCID_Type
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/16/1997 by Supriyo Ghosh
  --                    .
  --    Notes           : Return the CCID Type for an Account; return values
  --                      are 'PERSONNEL_SERVICES', 'NON_PERSONNEL_SERVICES'
  --

PROCEDURE Check_CCID_Type
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_ccid_type         OUT  NOCOPY  VARCHAR2,
  p_flex_code         IN   NUMBER,
  p_ccid              IN   NUMBER,
  p_budget_group_id   IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Find_CCIDs
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/16/1997 by Supriyo Ghosh
  --
  --    Notes           : Cache all CCIDs for specified Account Set
  --

PROCEDURE Find_CCIDs
( p_return_status     OUT  NOCOPY  VARCHAR2,
  p_account_set_id    IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Account_Dist
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE, FND_FLEX_EXT
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/16/1997 by Supriyo Ghosh
  --                            Modified 06/25/1997 by Supriyo Ghosh
  --                            Modified 09/02/1997 by Supriyo Ghosh
  --                             Changed Rounding Factor Logic
  --                            Modified 10/28/1997 by Supriyo Ghosh
  --                             Added Parameters for Volume Inserts
  --
  --    Notes           : Insert Worksheet Account Distributions for Account
  --                      and Position Lines
  --

PROCEDURE Create_Account_Dist
( p_api_version              IN   NUMBER,
  p_validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_account_line_id          OUT  NOCOPY  NUMBER,
  p_worksheet_id             IN   NUMBER,
  p_check_spal_exists        IN   VARCHAR2 := FND_API.G_TRUE,
  p_gl_cutoff_period         IN   DATE := FND_API.G_MISS_DATE,
  p_allocrule_set_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_rounding_factor          IN   NUMBER := FND_API.G_MISS_NUM,
  p_stage_set_id             IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_year_id           IN   NUMBER,
  p_budget_group_id          IN   NUMBER,
  p_ccid                     IN   NUMBER := FND_API.G_MISS_NUM,
  p_flex_mapping_set_id      IN   NUMBER := FND_API.G_MISS_NUM,
  p_map_accounts             IN   BOOLEAN := FALSE,
  p_functional_transaction   IN   VARCHAR2 := NULL,
  p_flex_code                IN   NUMBER := FND_API.G_MISS_NUM,
  p_concatenated_segments    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_startdate_pp             IN   DATE := FND_API.G_MISS_DATE,
  p_template_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_currency_code            IN   VARCHAR2,
  p_balance_type             IN   VARCHAR2,
  p_ytd_amount               IN   NUMBER,
  p_distribute_flag          IN   VARCHAR2 := FND_API.G_FALSE,
  p_annual_fte               IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_amount            IN   g_prdamt_tbl_type,
  p_position_line_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_element_set_id           IN   NUMBER := FND_API.G_MISS_NUM,
  p_salary_account_line      IN   VARCHAR2 := FND_API.G_FALSE,
  p_service_package_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_start_stage_seq          IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq        IN   NUMBER := FND_API.G_MISS_NUM,
  p_end_stage_seq            IN   NUMBER := FND_API.G_MISS_NUM,
  p_copy_of_account_line_id  IN   NUMBER := FND_API.G_MISS_NUM,
  /* bug start 3996052 */
  p_update_cy_estimate       IN   VARCHAR2 := 'N'
  /* bug end 3996052 */
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Account_Dist
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE, FND_FLEX_EXT
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 07/09/1997 by Supriyo Ghosh
  --                            Modified 09/02/1997 by Supriyo Ghosh
  --                             Changed Rounding Factor Logic
  --
  --    Notes           : Modify Worksheet Account Distributions for Account
  --                      Lines
  --

PROCEDURE Create_Account_Dist
( p_api_version              IN   NUMBER,
  p_validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_worksheet_id             IN   NUMBER,
  p_distribute_flag          IN   VARCHAR2 := FND_API.G_FALSE,
  p_account_line_id          IN   NUMBER,
  p_check_stages             IN   VARCHAR2 := FND_API.G_TRUE,
  p_ytd_amount               IN   NUMBER := FND_API.G_MISS_NUM,
  p_annual_fte               IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_amount            IN   g_prdamt_tbl_type,
  p_budget_group_id          IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq        IN   NUMBER := FND_API.G_MISS_NUM,
  p_copy_of_account_line_id  IN   NUMBER := FND_API.G_MISS_NUM,
  /* start bug 4128196 */
  p_update_cy_estimate       IN   VARCHAR2 := 'N'
  /* end bug 4128196 */
);

/* ----------------------------------------------------------------------- */

  --    API name        : Copy_CY_Estimates
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE, FND_FLEX_EXT
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 08/26/1997 by Supriyo Ghosh
  --                            Modified 10/28/1997 by Supriyo Ghosh
  --                             Added Parameters for Volume Inserts
  --
  --    Notes           : Copy CY Estimates from Actuals
  --

PROCEDURE Copy_CY_Estimates
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_service_package_id  IN   NUMBER,
  p_rounding_factor     IN   NUMBER,
  p_start_stage_seq     IN   NUMBER,
  p_budget_group_id     IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_budget_year_id      IN   NUMBER,
  p_ccid                IN   NUMBER,
  p_currency_code       IN   VARCHAR2
);

/* ----------------------------------------------------------------------- */

  --    API name        : Update_YTD_Amount
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/18/1997 by Supriyo Ghosh
  --
  --    Notes           : Update YTD Amount for Account Line
  --

PROCEDURE Update_YTD_Amount
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_account_line_id   IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Flex_Info
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 07/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Get Flex Info
  --

PROCEDURE Flex_Info
( p_return_status  OUT  NOCOPY  VARCHAR2,
  p_flex_code      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Dsql_Execute
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 07/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Execute dynamic sql statement
  --

FUNCTION dsql_execute
( sql_statement  IN  VARCHAR2
) RETURN NUMBER;

/* ----------------------------------------------------------------------- */

  --    API name        : DSQL_Budget_Balance
  --    Type            : Private <Implementation>
  --                    .
  --    Version : Current version       1.1
  --                      Initial version       1.1
  --                            Created 05/24/1999 by Supriyo Ghosh
  --
  --    Notes           : Create dynamic sql for extracting GL Balances
  --

PROCEDURE DSQL_Budget_Balance
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_sql_statement      OUT  NOCOPY  VARCHAR2,
  p_set_of_books_id    IN   NUMBER,
  p_budgetary_control  IN   VARCHAR2,
  p_budget_version_id  IN   NUMBER,
  p_gl_budget_set_id   IN   NUMBER,
  p_incl_adj_period    IN   VARCHAR2,
  p_map_criteria       IN   VARCHAR2
);

/* ----------------------------------------------------------------------- */

  --    API name        : DSQL_Actual_Balance
  --    Type            : Private <Implementation>
  --                    .
  --    Version : Current version       1.1
  --                      Initial version       1.1
  --                            Created 05/24/1999 by Supriyo Ghosh
  --
  --    Notes           : Create dynamic sql for extracting GL Balances
  --

PROCEDURE DSQL_Actual_Balance
( p_return_status    OUT  NOCOPY  VARCHAR2,
  p_sql_statement    OUT  NOCOPY  VARCHAR2,
  p_set_of_books_id  IN   NUMBER,
  p_incl_adj_period  IN   VARCHAR2,
  p_map_criteria     IN   VARCHAR2
);

/* ----------------------------------------------------------------------- */

  --    API name        : DSQL_Encum_Balance
  --    Type            : Private <Implementation>
  --                    .
  --    Version : Current version       1.1
  --                      Initial version       1.1
  --                            Created 05/24/1999 by Supriyo Ghosh
  --
  --    Notes           : Create dynamic sql for extracting GL Balances
  --

PROCEDURE DSQL_Encum_Balance
( p_return_status              OUT  NOCOPY  VARCHAR2,
  p_sql_statement              OUT  NOCOPY  VARCHAR2,
  p_set_of_books_id            IN   NUMBER,
  p_incl_adj_period            IN   VARCHAR2,
  p_map_criteria               IN   VARCHAR2,
  p_include_gl_commit_balance  IN   VARCHAR2,
  p_include_gl_oblig_balance   IN   VARCHAR2,
  p_include_gl_other_balance   IN   VARCHAR2
);

/* ----------------------------------------------------------------------- */

  --    API name        : Apply_Account_Constraints
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 06/03/1997 by Supriyo Ghosh
  --
  --    Notes           : Apply Account Constraints and log all Constraint
  --                      Validation Errors

PROCEDURE Apply_Account_Constraints
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_validation_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_flex_mapping_set_id   IN   NUMBER,
  p_budget_group_id       IN   NUMBER,
  p_flex_code             IN   NUMBER,
  p_func_currency         IN   VARCHAR2,
  p_constraint_set_id     IN   NUMBER,
  p_constraint_set_name   IN   VARCHAR2,
  p_constraint_threshold  IN   NUMBER,
  p_budget_calendar_id    IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Note
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --    Created By      : On 03/20/2001 by Manish Goel
  --
  --    Notes           : Create a Note for Standard Budget Item in PSB_WS_ACCOUNT_LINE_NOTES
  --                      for the Bug No 1584464


  -- Bug#4571412
  -- Added parameters p_chart_of_accounts_id, p_budget_year, p_cc_id
  -- to explain newly created message if update statment for
  -- PSB_WS_ACCOUNT_LINE_NOTES fails.

PROCEDURE Create_Note
( p_return_status         OUT NOCOPY VARCHAR2,
  p_account_line_id       IN         NUMBER,
  p_note                  IN         VARCHAR2,
  p_chart_of_accounts_id  IN         NUMBER,
  p_budget_year           IN         VARCHAR2,
  p_cc_id                 IN         NUMBER,
  p_concatenated_segments IN         VARCHAR2
);

/* ----------------------------------------------------------------------- */

  --    API name        : Get_Debug
  --    Type            : Private
  --    Pre-reqs        : None

FUNCTION Get_Debug RETURN VARCHAR2;

/* ----------------------------------------------------------------------- */

END PSB_WS_ACCT1;

/
