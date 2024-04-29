--------------------------------------------------------
--  DDL for Package PSB_WS_ACCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_ACCT_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBPWCAS.pls 120.5 2006/04/07 11:17:54 shtripat ship $ */

-- Bug#4571412
-- Introduced global variable to handle the CP
-- completion status conditionally.

-- Bug#4675858
-- No need of this packaged variable. The same will be done through
-- PSB_WS_ACCT1.g_soft_error_flag.
-- g_soft_error_flag VARCHAR2(1) := 'N';


/* ----------------------------------------------------------------------- */

  --    API name        : Check_CCID_Type
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_ACCT1
  --    Parameters      :
  --    IN              : p_api_version              IN  NUMBER    Required
  --                      p_init_msg_list            IN  VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level         IN  NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_flex_code                IN  NUMBER    Required
  --                      p_ccid                     IN  NUMBER    Required
  --                      p_budget_group_id          IN  NUMBER    Required
  --                    .
  --    OUT  NOCOPY      : p_return_status            OUT  NOCOPY VARCHAR2(1)
  --                    p_msg_count                  OUT  NOCOPY NUMBER
  --                    p_msg_data                   OUT  NOCOPY VARCHAR2(2000)
  --                    p_ccid_type                  OUT  NOCOPY VARCHAR2(30)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 03/09/1998 by Supriyo Ghosh
  --
  --    Notes           : Return the CCID Type for an Account; return values
  --                      are 'PERSONNEL_SERVICES', 'NON_PERSONNEL_SERVICES'
  --
  --      16-NOV-1998   Elvirtuc    moved call to concurrent manager here
  --                                Update balances and Create rollup



PROCEDURE Check_CCID_Type
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_ccid_type         OUT  NOCOPY  VARCHAR2,
  p_flex_code         IN   NUMBER,
  p_ccid              IN   NUMBER,
  p_budget_group_id   IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Account_Dist
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_ACCT1
  --    Parameters      :
  --    IN              : p_api_version              IN  NUMBER    Required
  --                      p_init_msg_list            IN  VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                   IN  VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level         IN  NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id             IN  NUMBER    Required
  --                      p_check_spal_exists        IN  VARCHAR2  Optional
  --                             Default = FND_API.G_TRUE
  --                      p_gl_cutoff_period         IN  DATE      Optional
  --                             Default = FND_API.G_MISS_DATE
  --                      p_allocrule_set_id         IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_budget_calendar_id       IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_rounding_factor          IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_stage_set_id             IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_budget_year_id           IN  NUMBER    Required
  --                      p_budget_group_id          IN  NUMBER    Required
  --                      p_ccid                     IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_flex_mapping_set_id      IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_map_accounts             IN  BOOLEAN   Optional
  --                             Default = FALSE
  --                      p_flex_code                IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_concatenated_segments    IN  VARCHAR2  Optional
  --                             Default = FND_API.G_MISS_CHAR
  --                      p_startdate_pp             IN  DATE      Optional
  --                             Default = FND_API.G_MISS_DATE
  --                      p_template_id              IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_currency_code            IN  VARCHAR2  Required
  --                      p_balance_type             IN  VARCHAR2  Required
  --                      p_ytd_amount               IN  NUMBER    Required
  --                      p_distribute_flag          IN  VARCHAR2  Optional
  --                             Default = FND_API.G_MISS_CHAR
  --                      p_annual_fte               IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_period_amount            IN  TABLE     Required
  --                      p_position_line_id         IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_element_set_id           IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_salary_account_line      IN  VARCHAR2  Optional
  --                             Default = FND_API.G_FALSE
  --                      p_service_package_id       IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_start_stage_seq          IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_current_stage_seq        IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_end_stage_seq            IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_copy_of_account_line_id  IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                    .
  --    OUT  NOCOPY      : p_return_status            OUT  NOCOPY VARCHAR2(1)
  --                    p_account_line_id            OUT  NOCOPY NUMBER
  --                    p_msg_count                  OUT  NOCOPY NUMBER
  --                    p_msg_data                   OUT  NOCOPY VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 06/15/1997 by Supriyo Ghosh
  --                            Changed 10/27/1997 by Supriyo Ghosh
  --                            Changed 01/07/1998 by Supriyo Ghosh
  --                            (Renamed p_position_id to p_position_line_id)
  --
  --    Notes           : Insert Worksheet Account Distributions for Account
  --                      and Position Lines
  --

PROCEDURE Create_Account_Dist
( p_api_version              IN   NUMBER,
  p_init_msg_list            IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                   IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level         IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_account_line_id          OUT  NOCOPY  NUMBER,
  p_msg_count                OUT  NOCOPY  NUMBER,
  p_msg_data                 OUT  NOCOPY  VARCHAR2,
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
  p_flex_code                IN   NUMBER := FND_API.G_MISS_NUM,
  p_concatenated_segments    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_startdate_pp             IN   DATE := FND_API.G_MISS_DATE,
  p_template_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_currency_code            IN   VARCHAR2,
  p_balance_type             IN   VARCHAR2,
  p_ytd_amount               IN   NUMBER,
  p_distribute_flag          IN   VARCHAR2 := FND_API.G_FALSE,
  p_annual_fte               IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_amount            IN   PSB_WS_ACCT1.g_prdamt_tbl_type,
  p_position_line_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_element_set_id           IN   NUMBER := FND_API.G_MISS_NUM,
  p_salary_account_line      IN   VARCHAR2 := FND_API.G_FALSE,
  p_service_package_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_start_stage_seq          IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq        IN   NUMBER := FND_API.G_MISS_NUM,
  p_end_stage_seq            IN   NUMBER := FND_API.G_MISS_NUM,
  p_copy_of_account_line_id  IN   NUMBER := FND_API.G_MISS_NUM
  /*For Bug No : 2440100 Start*/
  -- Bug#4502045
  --p_create_mrc_transaction   IN   BOOLEAN := TRUE
  /*For Bug No : 2440100 End*/
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Account_Dist
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_ACCT1
  --    Parameters      :
  --    IN              : p_api_version              IN  NUMBER    Required
  --                      p_init_msg_list            IN  VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                   IN  VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level         IN  NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id             IN  NUMBER    Required
  --                      p_distribute_flag          IN  VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_account_line_id          IN  NUMBER    Required
  --                      p_check_stages             IN  VARCHAR2  Optional
  --                            Default = FND_API.G_TRUE
  --                      p_ytd_amount               IN  NUMBER    Required
  --                      p_annual_fte               IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_period_amount            IN  TABLE     Required
  --                      p_budget_group_id          IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_service_package_id       IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_current_stage_seq        IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_copy_of_account_line_id  IN  NUMBER    Optional
  --                             Default = FND_API.G_MISS_NUM
  --                    .
  --    OUT  NOCOPY      : p_return_status            OUT  NOCOPY VARCHAR2(1)
  --                    p_msg_count                  OUT  NOCOPY NUMBER
  --                    p_msg_data                   OUT  NOCOPY VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 06/15/1997 by Supriyo Ghosh
  --
  --    Notes           : Modify Worksheet Account Distributions for Account
  --                      and Position Lines
  --

PROCEDURE Create_Account_Dist
( p_api_version              IN   NUMBER,
  p_init_msg_list            IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                   IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level         IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_msg_count                OUT  NOCOPY  NUMBER,
  p_msg_data                 OUT  NOCOPY  VARCHAR2,
  p_worksheet_id             IN   NUMBER,
  p_distribute_flag          IN   VARCHAR2 := FND_API.G_FALSE,
  p_account_line_id          IN   NUMBER,
  p_check_stages             IN   VARCHAR2 := FND_API.G_TRUE,
  p_ytd_amount               IN   NUMBER,
  p_annual_fte               IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_amount            IN   PSB_WS_ACCT1.g_prdamt_tbl_type,
  p_budget_group_id          IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq        IN   NUMBER := FND_API.G_MISS_NUM,
  p_copy_of_account_line_id  IN   NUMBER := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */

  --    API name        : Revise_Account_Projections
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_ACCT2
  --    Parameters      :
  --    IN              : p_api_version            IN   NUMBER    Required
  --                      p_init_msg_list          IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                 IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level       IN   NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id           IN   NUMBER    Required
  --                      p_parameter_id           IN   NUMBER    Required
  --                    .
  --    OUT  NOCOPY      : p_return_status          OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                OUT  NOCOPY  NUMBER
  --                    p_msg_data                 OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 02/12/2000 by Supriyo Ghosh
  --

PROCEDURE Revise_Account_Projections
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_parameter_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Update_GL_Balances
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_ACCT2
  --    Parameters      :
  --    IN              : p_api_version            IN   NUMBER    Required
  --                      p_init_msg_list          IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                 IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level       IN   NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id           IN   NUMBER    Required
  --                    .
  --    OUT  NOCOPY      : p_return_status          OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                OUT  NOCOPY  NUMBER
  --                    p_msg_data                 OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/20/1998 by Supriyo Ghosh
  --
  --    Notes           : Update CY GL Balances
  --

PROCEDURE Update_GL_Balances
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Rollup_Totals
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_ACCT2
  --    Parameters      :
  --    IN              : p_api_version         IN NUMBER       Required
  --                      p_init_msg_list       IN VARCHAR2     Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit              IN VARCHAR2     Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level    IN NUMBER       Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id        IN NUMBER       Required
  --                      p_rounding_factor     IN NUMBER       Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_stage_set_id        IN NUMBER       Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_current_stage_seq   IN NUMBER       Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_set_of_books_id     IN NUMBER       Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_flex_code           IN NUMBER       Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_budget_group_id     IN NUMBER       Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_budget_calendar_id  IN NUMBER       Optional
  --                             Default = FND_API.G_MISS_NUM
  --                    .
  --    OUT  NOCOPY      : p_return_status       OUT  NOCOPY     VARCHAR2(1)
  --                    p_msg_count             OUT  NOCOPY     NUMBER
  --                    p_msg_data              OUT  NOCOPY     VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 06/15/1997 by Supriyo Ghosh
  --
  --    Notes           : Create Summary Rollups for Worksheet Accounts
  --

PROCEDURE Create_Rollup_Totals
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
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

PROCEDURE Update_GL_Balances_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  p_worksheet_id              IN       NUMBER   := FND_API.G_MISS_NUM
);

PROCEDURE Create_Rollup_Totals_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  p_create_summary_totals     IN       VARCHAR2,
  p_worksheet_id              IN       NUMBER   := FND_API.G_MISS_NUM
);

PROCEDURE Revise_Account_Projections_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  p_worksheet_id              IN       NUMBER,
  p_parameter_id              IN       NUMBER
);


END PSB_WS_ACCT_PVT;

 

/
