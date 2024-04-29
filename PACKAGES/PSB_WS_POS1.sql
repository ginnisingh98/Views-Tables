--------------------------------------------------------
--  DDL for Package PSB_WS_POS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_POS1" AUTHID CURRENT_USER AS
/* $Header: PSBVWP1S.pls 120.5 2005/07/28 16:50:52 shtripat ship $ */

  TYPE g_poscalc_rec_type IS RECORD
     ( pay_element_id   NUMBER,
       element_type     VARCHAR2(1),
       element_set_id   NUMBER,
       element_cost     NUMBER,
       budget_year_id   NUMBER,
       period1_amount   NUMBER, period2_amount NUMBER, period3_amount NUMBER,
       period4_amount   NUMBER, period5_amount NUMBER, period6_amount NUMBER,
       period7_amount   NUMBER, period8_amount NUMBER, period9_amount NUMBER,
       period10_amount  NUMBER, period11_amount NUMBER, period12_amount NUMBER,
       period13_amount  NUMBER, period14_amount NUMBER, period15_amount NUMBER,
       period16_amount  NUMBER, period17_amount NUMBER, period18_amount NUMBER,
       period19_amount  NUMBER, period20_amount NUMBER, period21_amount NUMBER,
       period22_amount  NUMBER, period23_amount NUMBER, period24_amount NUMBER,
       period25_amount  NUMBER, period26_amount NUMBER, period27_amount NUMBER,
       period28_amount  NUMBER, period29_amount NUMBER, period30_amount NUMBER,
       period31_amount  NUMBER, period32_amount NUMBER, period33_amount NUMBER,
       period34_amount  NUMBER, period35_amount NUMBER, period36_amount NUMBER,
       period37_amount  NUMBER, period38_amount NUMBER, period39_amount NUMBER,
       period40_amount  NUMBER, period41_amount NUMBER, period42_amount NUMBER,
       period43_amount  NUMBER, period44_amount NUMBER, period45_amount NUMBER,
       period46_amount  NUMBER, period47_amount NUMBER, period48_amount NUMBER,
       period49_amount  NUMBER, period50_amount NUMBER, period51_amount NUMBER,
       period52_amount  NUMBER, period53_amount NUMBER, period54_amount NUMBER,
       period55_amount  NUMBER, period56_amount NUMBER, period57_amount NUMBER,
       period58_amount  NUMBER, period59_amount NUMBER, period60_amount NUMBER );

  TYPE g_poscalc_tbl_type IS TABLE OF g_poscalc_rec_type
      INDEX BY BINARY_INTEGER;

  g_pc_costs                   g_poscalc_tbl_type;
  g_num_pc_costs               NUMBER;

  TYPE g_posdist_rec_type IS RECORD
     ( ccid             NUMBER,
       element_type     VARCHAR2(1),
       element_set_id   NUMBER,
       budget_year_id   NUMBER,
       ytd_amount       NUMBER,
       period1_amount   NUMBER, period2_amount NUMBER, period3_amount NUMBER,
       period4_amount   NUMBER, period5_amount NUMBER, period6_amount NUMBER,
       period7_amount   NUMBER, period8_amount NUMBER, period9_amount NUMBER,
       period10_amount  NUMBER, period11_amount NUMBER, period12_amount NUMBER,
       period13_amount  NUMBER, period14_amount NUMBER, period15_amount NUMBER,
       period16_amount  NUMBER, period17_amount NUMBER, period18_amount NUMBER,
       period19_amount  NUMBER, period20_amount NUMBER, period21_amount NUMBER,
       period22_amount  NUMBER, period23_amount NUMBER, period24_amount NUMBER,
       period25_amount  NUMBER, period26_amount NUMBER, period27_amount NUMBER,
       period28_amount  NUMBER, period29_amount NUMBER, period30_amount NUMBER,
       period31_amount  NUMBER, period32_amount NUMBER, period33_amount NUMBER,
       period34_amount  NUMBER, period35_amount NUMBER, period36_amount NUMBER,
       period37_amount  NUMBER, period38_amount NUMBER, period39_amount NUMBER,
       period40_amount  NUMBER, period41_amount NUMBER, period42_amount NUMBER,
       period43_amount  NUMBER, period44_amount NUMBER, period45_amount NUMBER,
       period46_amount  NUMBER, period47_amount NUMBER, period48_amount NUMBER,
       period49_amount  NUMBER, period50_amount NUMBER, period51_amount NUMBER,
       period52_amount  NUMBER, period53_amount NUMBER, period54_amount NUMBER,
       period55_amount  NUMBER, period56_amount NUMBER, period57_amount NUMBER,
       period58_amount  NUMBER, period59_amount NUMBER, period60_amount NUMBER );

  TYPE g_posdist_tbl_type IS TABLE OF g_posdist_rec_type
      INDEX BY BINARY_INTEGER;

  g_pd_costs                   g_posdist_tbl_type;
  g_num_pd_costs               NUMBER;

  TYPE g_element_rec_type IS RECORD
     ( pay_element_id          NUMBER,
       element_name            VARCHAR2(30),
       processing_type         VARCHAR2(1),
       max_element_value_type  VARCHAR2(2),
       max_element_value       NUMBER,
       option_flag             VARCHAR2(1),
       overwrite_flag          VARCHAR2(1),
       salary_flag             VARCHAR2(1),
       salary_type             VARCHAR2(10),
       follow_salary           VARCHAR2(1),
       period_type             VARCHAR2(10),
       process_period_type     VARCHAR2(10) );

  TYPE g_element_tbl_type IS TABLE OF g_element_rec_type
      INDEX BY BINARY_INTEGER;

  g_elements                   g_element_tbl_type;
  g_num_elements               NUMBER;

  TYPE g_saldist_rec_type IS RECORD
     ( ccid        NUMBER,
       amount      NUMBER,
       percent     NUMBER,
       start_date  DATE,
       end_date    DATE );

  TYPE g_saldist_tbl_type IS TABLE OF g_saldist_rec_type
      INDEX BY BINARY_INTEGER;

  g_salary_dist                g_saldist_tbl_type;
  g_num_salary_dist            NUMBER;

  g_salary_budget_group_id     NUMBER;
  g_budget_group_numyrs        NUMBER;

  TYPE g_elemdist_rec_type IS RECORD
     ( account_line_id  NUMBER,
       ccid             NUMBER,
       ytd_amount       NUMBER,
       period1_amount NUMBER, period2_amount NUMBER, period3_amount NUMBER,
       period4_amount NUMBER, period5_amount NUMBER, period6_amount NUMBER,
       period7_amount NUMBER, period8_amount NUMBER, period9_amount NUMBER,
       period10_amount NUMBER, period11_amount NUMBER, period12_amount NUMBER,
       period13_amount NUMBER, period14_amount NUMBER, period15_amount NUMBER,
       period16_amount NUMBER, period17_amount NUMBER, period18_amount NUMBER,
       period19_amount NUMBER, period20_amount NUMBER, period21_amount NUMBER,
       period22_amount NUMBER, period23_amount NUMBER, period24_amount NUMBER,
       period25_amount NUMBER, period26_amount NUMBER, period27_amount NUMBER,
       period28_amount NUMBER, period29_amount NUMBER, period30_amount NUMBER,
       period31_amount NUMBER, period32_amount NUMBER, period33_amount NUMBER,
       period34_amount NUMBER, period35_amount NUMBER, period36_amount NUMBER,
       period37_amount NUMBER, period38_amount NUMBER, period39_amount NUMBER,
       period40_amount NUMBER, period41_amount NUMBER, period42_amount NUMBER,
       period43_amount NUMBER, period44_amount NUMBER, period45_amount NUMBER,
       period46_amount NUMBER, period47_amount NUMBER, period48_amount NUMBER,
       period49_amount NUMBER, period50_amount NUMBER, period51_amount NUMBER,
       period52_amount NUMBER, period53_amount NUMBER, period54_amount NUMBER,
       period55_amount NUMBER, period56_amount NUMBER, period57_amount NUMBER,
       period58_amount NUMBER, period59_amount NUMBER, period60_amount NUMBER,
       redist_flag      VARCHAR2(1) );

  TYPE g_elemdist_tbl_type IS TABLE OF g_elemdist_rec_type
    INDEX BY BINARY_INTEGER;

  g_element_dist               g_elemdist_tbl_type;
  g_num_element_dist           NUMBER;

  g_fte_id                     NUMBER;
  g_default_wklyhrs_id         NUMBER;

  -- Added for bug#3212814
  g_default_wklyhrs_vt_flag    VARCHAR2(1);

  g_adjdate_id                 NUMBER;
  g_hiredate_id                NUMBER;

  g_data_extract_id            NUMBER;
  g_business_group_id          NUMBER;
  g_attr_busgrp_id             NUMBER;

  g_fte                        NUMBER;
  g_default_weekly_hours       NUMBER;
  g_adjustment_date            DATE;
  g_hiredate                   DATE;

  g_global_worksheet_id        NUMBER;
  g_local_copy_flag            VARCHAR2(1);

  g_budget_calendar_id         NUMBER;
  g_budget_group_id            NUMBER;

/* ----------------------------------------------------------------------- */

  --    API name        : Initialize_Calc
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Initializes global array for Position Costs
  --

PROCEDURE Initialize_Calc
( p_init_index  NUMBER := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */

  --    API name        : Initialize_Dist
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Initializes global array for Cost Distributions
  --

PROCEDURE Initialize_Dist;

/* ----------------------------------------------------------------------- */

  --    API name        : Initialize_Salary_Dist
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Initializes global array for Salary Distribution
  --

PROCEDURE Initialize_Salary_Dist;

/* ----------------------------------------------------------------------- */

  --    API name        : Initialize_Element_Dist
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Initializes global array for Redistributing Elements
  --                      following Salary
  --

PROCEDURE Initialize_Element_Dist;

/* ----------------------------------------------------------------------- */

  --    API name        : Check_Allowed
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 02/06/1998 by Supriyo Ghosh
  --
  --    Notes           : Check if Position Budget Group is within Budget Group
  --                      Hierarchy for the Worksheet
  --

FUNCTION Check_Allowed
( p_api_version               IN  NUMBER,
  p_validation_level          IN  NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_worksheet_id              IN  NUMBER,
  p_position_budget_group_id  IN  NUMBER
) RETURN VARCHAR2;

/* ----------------------------------------------------------------------- */

  --    API name        : Cache_Elements
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Cache Elements
  --

PROCEDURE Cache_Elements
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_data_extract_id    IN   NUMBER,
  p_business_group_id  IN   NUMBER,
  p_worksheet_id       IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Cache_Named_Attributes
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Cache Named Position Attributes
  --

PROCEDURE Cache_Named_Attributes
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_business_group_id  IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Cache_Named_Attribute_Values
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Cache Named Position Attribute Values
  --

PROCEDURE Cache_Named_Attribute_Values
( p_return_status    OUT  NOCOPY  VARCHAR2,
  p_worksheet_id     IN   NUMBER,
  p_data_extract_id  IN   NUMBER,
  p_position_id      IN   NUMBER,
  /* start bug 4104890 */
  p_local_parameter_flag     IN   VARCHAR2 := 'N'
  /* End bug 4104890 */
);

/* ----------------------------------------------------------------------- */

  --    API name        : HRMS_Factor
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Return conversion factor
  --

PROCEDURE HRMS_Factor
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_hrms_period_type    IN   VARCHAR2,
  p_budget_period_type  IN   VARCHAR2,
  p_position_name       IN   VARCHAR2,
  p_element_name        IN   VARCHAR2,
  p_start_date          IN   DATE,
  p_end_date            IN   DATE,
  p_factor              OUT  NOCOPY  NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Cache_Salary_Dist
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --                            Changed 04/29/1998 by Supriyo Ghosh
  --                                    Added p_position_name
  --                            Changed 04/17/2001 by Supriyo Ghosh
  --                                    Added p_worksheet_id
  --
  --    Notes           : Cache Salary Distribution
  --

PROCEDURE Cache_Salary_Dist
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_root_budget_group_id  IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_flex_code             IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_position_name         IN   VARCHAR2,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Position_Lines
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Create Position Instance for a specific
  --                      Global Worksheet or a local copy of Worksheet
  --

PROCEDURE Create_Position_Lines
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_position_line_id          OUT  NOCOPY  NUMBER,
  p_worksheet_id              IN   NUMBER,
  p_position_id               IN   NUMBER,
  p_budget_group_id           IN   NUMBER,
  p_copy_of_position_line_id  IN   NUMBER := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Position_Matrix
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Create Position Matrix
  --

PROCEDURE Create_Position_Matrix
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_position_line_id  IN   NUMBER,
  p_freeze_flag       IN   VARCHAR2 := FND_API.G_FALSE,
  p_view_line_flag    IN   VARCHAR2 := FND_API.G_TRUE
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_FTE_Lines
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Create Worksheet Position FTE Lines
  --

PROCEDURE Create_FTE_Lines
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_fte_line_id         OUT  NOCOPY  NUMBER,
  p_check_spfl_exists   IN   VARCHAR2 := FND_API.G_TRUE,
  p_recalculate_flag    IN   VARCHAR2 := FND_API.G_FALSE,
  p_worksheet_id        IN   NUMBER,
  p_flex_mapping_set_id IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_annual_fte          IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_start_stage_seq     IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER,
  p_end_stage_seq       IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_fte          IN   PSB_WS_ACCT1.g_prdamt_tbl_type
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_FTE_Lines
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Update Worksheet Position FTE Lines
  --

PROCEDURE Create_FTE_Lines
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_check_stages        IN   VARCHAR2 := FND_API.G_TRUE,
  p_worksheet_id        IN   NUMBER,
  p_fte_line_id         IN   NUMBER,
  p_service_package_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_fte          IN   PSB_WS_ACCT1.g_prdamt_tbl_type,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */
  --    API name        : Create_Element_Lines
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/09/1997 by Supriyo Ghosh
  --
  --    Notes           : Create Worksheet Element Lines
  --

PROCEDURE Create_Element_Lines
( p_api_version             IN   NUMBER,
  p_validation_level        IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status           OUT  NOCOPY  VARCHAR2,
  p_element_line_id         OUT  NOCOPY  NUMBER,
  p_check_spel_exists       IN   VARCHAR2 := FND_API.G_TRUE,
  p_position_line_id        IN   NUMBER,
  p_budget_year_id          IN   NUMBER,
  p_pay_element_id          IN   NUMBER,
  p_currency_code           IN   VARCHAR2,
  p_element_cost            IN   NUMBER,
  p_element_set_id          IN   NUMBER,
  p_service_package_id      IN   NUMBER,
  p_stage_set_id            IN   NUMBER,
  p_start_stage_seq         IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq       IN   NUMBER,
  p_end_stage_seq           IN   NUMBER := FND_API.G_MISS_NUM,
  p_functional_transaction  IN   VARCHAR2 := NULL
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Element_Lines
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 08/12/1998 by Supriyo Ghosh
  --
  --    Notes           : Update Worksheet Position Element Lines
  --

PROCEDURE Create_Element_Lines
( p_api_version             IN   NUMBER,
  p_validation_level        IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status           OUT  NOCOPY  VARCHAR2,
  p_check_stages            IN   VARCHAR2 := FND_API.G_TRUE,
  p_element_line_id         IN   NUMBER,
  p_service_package_id      IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq       IN   NUMBER := FND_API.G_MISS_NUM,
  p_element_cost            IN   NUMBER := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */

  --    API name        : Update_Annual_FTE
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/10/1997 by Supriyo Ghosh
  --
  --    Notes           : Compute Annualized FTE for Position Instance
  --

PROCEDURE Update_Annual_FTE
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_current_stage_seq   IN   NUMBER,
  p_budget_group_id     IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Distribute_Following_Elements
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/09/1997 by Supriyo Ghosh
  --
  --    Notes           : Distribute Following Elements
  --

PROCEDURE Distribute_Following_Elements
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_redistribute       IN   VARCHAR2 := FND_API.G_FALSE,
  p_pay_element_id     IN   NUMBER,
  p_data_extract_id    IN   NUMBER,
  p_flex_code          IN   NUMBER,
  p_business_group_id  IN   NUMBER,
  p_rounding_factor    IN   NUMBER,
  p_position_line_id   IN   NUMBER,
  p_position_id        IN   NUMBER,
  p_budget_year_id     IN   NUMBER,
  p_start_date         IN   DATE,
  p_end_date           IN   DATE
);

/* ----------------------------------------------------------------------- */

  --    API name        : Get_Debug
  --    Type            : Private
  --    Pre-reqs        : None

FUNCTION Get_Debug RETURN VARCHAR2;

/* ----------------------------------------------------------------------- */
/* Bug No 2278216 Start */

  TYPE g_prddist_rec_type IS RECORD
     ( ccid                     NUMBER,
       element_type             VARCHAR2(1),
       element_set_id           NUMBER,
       budget_year_id           NUMBER,
       period_start_date        DATE,
       period_end_date          DATE,
       percent                  NUMBER);

  TYPE g_prddist_tbl_type IS TABLE OF g_prddist_rec_type
      INDEX BY BINARY_INTEGER;

  g_periods                   g_prddist_tbl_type;
  g_num_periods               NUMBER;

/* ----------------------------------------------------------------------- */

PROCEDURE Initialize_Period_Dist;

/* ----------------------------------------------------------------------- */

PROCEDURE Distribute_Periods
( p_return_status            OUT  NOCOPY  VARCHAR2,
  p_ccid                     IN   NUMBER,
  p_element_type             IN   VARCHAR2,
  p_element_set_id           IN   NUMBER,
  p_budget_year_id           IN   NUMBER,
  p_dist_start_date          IN   DATE,
  p_dist_end_date            IN   DATE,
  p_start_date               IN   DATE,
  p_end_date                 IN   DATE,
  p_element_index            IN   NUMBER,
  p_dist_index               IN   NUMBER,
  p_percent                  IN   NUMBER
);

/* Bug No 2278216 End */
/* ----------------------------------------------------------------------- */

END PSB_WS_POS1;

 

/
