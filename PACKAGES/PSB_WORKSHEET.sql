--------------------------------------------------------
--  DDL for Package PSB_WORKSHEET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WORKSHEET" AUTHID CURRENT_USER AS
/* $Header: PSBVWCMS.pls 120.11 2005/11/14 11:52:27 viraghun ship $ */

/* ----------------------------------------------------------------------- */

  --    API name        : Check_Reentrant_Status
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 07/22/1997 by Supriyo Ghosh
  --
  --    Notes           : Check Reentrant Status
  --
  g_gl_cutoff_period    DATE;
  -- made the above variable public as part of bug fix 3469514.

  /* Bug 3458191 start */
  -- introduce the following variables to caching worksheet information
  g_ws_creation_flag           BOOLEAN := FALSE;
  g_worksheet_id               NUMBER;

  -- made the following variables public
  g_global_worksheet_id        NUMBER;
  g_allocrule_set_id           NUMBER;
  g_budget_calendar_id         NUMBER;
  g_rounding_factor            NUMBER;
  g_stage_set_id               NUMBER;
  g_flex_mapping_set_id        NUMBER;
  g_current_stage_seq          NUMBER;
  g_local_copy_flag            VARCHAR2(1);
  /* Bug 3458191 end */

  g_chart_of_accounts_id      NUMBER; -- Bug#4571412

  /* Bug 3543845 start */
  -- Introduced to improving performance for first time worksheet creation
  g_ws_first_time_creation_flag BOOLEAN := FALSE;
  g_ps_acct_pos_set_id          NUMBER;
  g_nps_acct_pos_set_id         NUMBER;


  -- Made the following variable public
  g_parameter_set_id           NUMBER;
  g_num_years_to_allocate      NUMBER;
  g_budget_by_position         VARCHAR2(1);
  g_root_budget_group_id       NUMBER;
  /* Bug 3543845 End */

PROCEDURE Check_Reentrant_Status
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_parameter_set_id    IN   NUMBER,
  p_constraint_set_id   IN   NUMBER,
  p_allocrule_set_id    IN   NUMBER,
  p_budget_calendar_id  IN   NUMBER,
  p_budget_group_id     IN   NUMBER,
  p_data_extract_id     IN   NUMBER,
  p_gl_budget_set_id    IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_WS_Line_Items
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_ACCT1, PSB_WS_ACCT2
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/16/1997 by Supriyo Ghosh
  --
  --    Notes           : Create Worksheet Account and Position Line Items
  --

PROCEDURE Create_WS_Line_Items
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Delete_WS_Line_Items
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 07/02/1997 by Supriyo Ghosh
  --
  --    Notes           : Delete Worksheet Account and Position Line Items
  --

PROCEDURE Delete_WS_Line_Items
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_global_worksheet  IN   VARCHAR2 := FND_API.G_TRUE
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Worksheet
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Modified 03/10/1998 by Supriyo Ghosh
  --                            Added p_use_revised_element_rates
  --                            Modified 09/08/1997 by Supriyo Ghosh
  --                            Modified 08/29/1997 by Kumaresh Sankar
  --                            Modified 06/24/1997 by Supriyo Ghosh
  --                            Created 05/16/1997 by Supriyo Ghosh
  --
  --    Notes           : Create Worksheet Header
  --

PROCEDURE Create_Worksheet
( p_api_version                       IN   NUMBER,
  p_validation_level                  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status                     OUT  NOCOPY  VARCHAR2,
  p_budget_group_id                   IN   NUMBER,
  p_budget_calendar_id                IN   NUMBER,
  p_worksheet_type                    IN   VARCHAR2,
  p_name                              IN   VARCHAR2,
  p_description                       IN   VARCHAR2,
  p_ws_creation_complete              IN   VARCHAR2,
  p_stage_set_id                      IN   NUMBER,
  p_current_stage_seq                 IN   NUMBER,
  p_global_worksheet_id               IN   NUMBER,
  p_global_worksheet_flag             IN   VARCHAR2,
  p_global_worksheet_option           IN   VARCHAR2,
  p_local_copy_flag                   IN   VARCHAR2,
  p_copy_of_worksheet_id              IN   NUMBER,
  p_freeze_flag                       IN   VARCHAR2,
  p_budget_by_position                IN   VARCHAR2,
  p_use_revised_element_rates         IN   VARCHAR2,
  p_num_proposed_years                IN   NUMBER,
  p_num_years_to_allocate             IN   NUMBER,
  p_rounding_factor                   IN   NUMBER,
  p_gl_cutoff_period                  IN   DATE,
  p_budget_version_id                 IN   NUMBER,
  p_gl_budget_set_id                  IN   NUMBER,
  p_include_stat_balance              IN   VARCHAR2,
  p_include_trans_balance             IN   VARCHAR2,
  p_include_adj_period                IN   VARCHAR2,
  p_data_extract_id                   IN   NUMBER,
  p_parameter_set_id                  IN   NUMBER,
  p_constraint_set_id                 IN   NUMBER,
  p_allocrule_set_id                  IN   NUMBER,
  p_date_submitted                    IN   DATE,
  p_submitted_by                      IN   NUMBER,
  p_attribute1                        IN   VARCHAR2,
  p_attribute2                        IN   VARCHAR2,
  p_attribute3                        IN   VARCHAR2,
  p_attribute4                        IN   VARCHAR2,
  p_attribute5                        IN   VARCHAR2,
  p_attribute6                        IN   VARCHAR2,
  p_attribute7                        IN   VARCHAR2,
  p_attribute8                        IN   VARCHAR2,
  p_attribute9                        IN   VARCHAR2,
  p_attribute10                       IN   VARCHAR2,
  p_context                           IN   VARCHAR2,
  p_create_non_pos_line_items         IN   VARCHAR2,
  p_apply_element_parameters          IN   VARCHAR2,
  p_apply_position_parameters         IN   VARCHAR2,
  p_create_positions                  IN   VARCHAR2,
  p_create_summary_totals             IN   VARCHAR2,
  p_apply_constraints                 IN   VARCHAR2,
  p_flex_mapping_set_id               IN   NUMBER,
  p_include_gl_commit_balance         IN   VARCHAR2,
  p_include_gl_oblig_balance          IN   VARCHAR2,
  p_include_gl_other_balance          IN   VARCHAR2,
  p_include_cbc_commit_balance        IN   VARCHAR2,
  p_include_cbc_oblig_balance         IN   VARCHAR2,
  p_include_cbc_budget_balance        IN   VARCHAR2,
  /* Included federal_ws_flag for Bug 3157960 */
  p_federal_ws_flag		      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* bug no 4725091 */
  p_include_gl_forwd_balance          IN   VARCHAR2,
  p_worksheet_id                      OUT  NOCOPY  NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Update_Worksheet
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Modified 03/10/1998 by Supriyo Ghosh
  --                            Added p_use_revised_element_rates
  --                            Modified 06/24/1997 by Supriyo Ghosh
  --                            Created 05/16/1997 by Supriyo Ghosh
  --
  --    Notes           : Update Worksheet Header
  --

PROCEDURE Update_Worksheet
( p_api_version                       IN   NUMBER,
  p_validation_level                  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status                     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                      IN   NUMBER := FND_API.G_MISS_NUM,
  p_worksheet_type                    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description                       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ws_creation_complete              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_global_worksheet_id               IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq                 IN   NUMBER := FND_API.G_MISS_NUM,
  p_local_copy_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_copy_of_worksheet_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_freeze_flag                       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_use_revised_element_rates         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* Bug # 3083970 */
  p_num_proposed_years                IN   NUMBER := FND_API.G_MISS_NUM,
  p_rounding_factor                   IN   NUMBER := FND_API.G_MISS_NUM,
  /* End bug */
  p_date_submitted                    IN   DATE := FND_API.G_MISS_DATE,
  p_submitted_by                      IN   NUMBER := FND_API.G_MISS_NUM,
  p_attribute1                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute2                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute3                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute4                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute5                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute6                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute7                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute8                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute9                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute10                       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_context                           IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_create_non_pos_line_items         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_apply_element_parameters          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_apply_position_parameters         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_create_positions                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_create_summary_totals             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_apply_constraints                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_commit_balance         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_oblig_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_other_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_commit_balance        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_oblig_balance         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_budget_balance        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* For Bug No. 2312657 : Start */
  p_gl_cutoff_period                  IN   DATE := NULL,
  p_gl_budget_set_id                  IN   NUMBER := NULL,
  /* For Bug No. 2312657 : End */
  /* Included federal_ws_flag for Bug 3157960 */
  p_federal_ws_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* bug no 4725091 */
  p_include_gl_forwd_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR
 );

/* ----------------------------------------------------------------------- */

  --    API name        : Delete_Worksheet
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 07/09/1997 by Supriyo Ghosh
  --
  --    Notes           : Delete Worksheet Header
  --

PROCEDURE Delete_Worksheet
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Delete_WAL
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 08/27/1997 by Supriyo Ghosh
  --
  --    Notes           : Delete Worksheet Account Line
  --

PROCEDURE Delete_WAL
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_account_line_id   IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Delete_WPL
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Delete Worksheet Position Line
  --

PROCEDURE Delete_WPL
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_position_line_id  IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Delete_WFL
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Delete Worksheet Position FTE Line
  --

PROCEDURE Delete_WFL
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_fte_line_id       IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Delete_WEL
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/08/1997 by Supriyo Ghosh
  --
  --    Notes           : Delete Worksheet Position Element Cost Line
  --

PROCEDURE Delete_WEL
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_element_line_id   IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Delete_Summary_Lines
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 11/13/1997 by Supriyo Ghosh
  --
  --    Notes           : Delete Worksheet Summary Account Lines
  --

PROCEDURE Delete_Summary_Lines
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Apply_Constraints
  --    Type            : Private
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/06/1998 by Supriyo Ghosh
  --
  --    Notes           : Apply Constraints and log all Constraint
  --                      Validation Errors

PROCEDURE Apply_Constraints
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_validation_status         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER,
  p_budget_group_id           IN   NUMBER := FND_API.G_MISS_NUM,
  p_flex_code                 IN   NUMBER := FND_API.G_MISS_NUM,
  p_func_currency             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_global_worksheet_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_constraint_set_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_constraint_set_name       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_constraint_set_threshold  IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id        IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id           IN   NUMBER := FND_API.G_MISS_NUM,
  p_business_group_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_by_position        IN   VARCHAR2 := FND_API.G_MISS_CHAR
);

/* ----------------------------------------------------------------------- */

  --    API name        : Validate_Entity_Set
  --    Type            : Private
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/01/1998 by Supriyo Ghosh
  --
  --    Notes           : Validate Entity Sets for a Data Extract

PROCEDURE Validate_Entity_Set
( p_api_version        IN   NUMBER,
  p_validation_level   IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status      OUT  NOCOPY  VARCHAR2,
  p_data_extract_id    IN   NUMBER,
  p_parameter_set_id   IN   NUMBER,
  p_constraint_set_id  IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Pre_Create_Line_Items
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Acct_Line_Items
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Pos_Line_Items
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Acct_Constraints
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Pos_Constraints
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Elem_Constraints
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Post_Create_Line_Items
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Get_Debug
  --    Type            : Private
  --    Pre-reqs        : None

FUNCTION Get_Debug RETURN VARCHAR2;

/* ----------------------------------------------------------------------- */

END PSB_WORKSHEET;

 

/
