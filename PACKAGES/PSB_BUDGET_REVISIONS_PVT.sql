--------------------------------------------------------
--  DDL for Package PSB_BUDGET_REVISIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_BUDGET_REVISIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVBRVS.pls 120.9.12010000.5 2009/04/29 11:40:27 rkotha ship $ */

  g_root_budget_group_id       NUMBER;
  g_set_of_books_id            NUMBER;
  g_set_of_books_name          VARCHAR2(30);
  g_business_group_id          NUMBER;
  g_flex_code                  NUMBER;
  g_flex_delimiter             VARCHAR2(1);
  g_func_currency              VARCHAR2(15);
  g_currency_code              VARCHAR2(15);
  g_budgetary_control          VARCHAR2(1);
  g_gl_journal_source          VARCHAR2(25) ;
  g_gl_journal_category        VARCHAR2(25) ;
  g_gl_budget_set_id           NUMBER;
  g_create_zero_bal            VARCHAR2(1);

  g_budget_group_name          VARCHAR2(80);

  g_budget_group_id            NUMBER;
  g_from_gl_period_name        VARCHAR2(15);
  g_to_gl_period_name          VARCHAR2(15);
  g_from_date                  DATE; -- Start date of the from gl period
  g_to_date                    DATE; -- End date of the to gl period
  g_effective_start_date       DATE;
  g_effective_end_date         DATE;
  g_budget_revision_type       VARCHAR2(1);
  g_permanent_revision         VARCHAR2(1);
  g_revise_by_position         VARCHAR2(1);
  g_balance_type               VARCHAR2(4);
  g_transaction_type           VARCHAR2(4);
  g_freeze_flag                VARCHAR2(1);

  g_global_revision            VARCHAR2(1);
  g_global_budget_revision_id  NUMBER;
  g_data_extract_id            NUMBER;
  g_position_exists            BOOLEAN := FALSE;
  g_position_mass_revision     BOOLEAN := FALSE;
  g_hr_budget_id               NUMBER;

  g_parameter_set_id           NUMBER;
  g_constraint_set_id          NUMBER;
  g_constraint_set_name        VARCHAR2(30);
  /* ForBug No : 1321519 Start */
  g_constraint_start_date      DATE;
  g_constraint_end_date        DATE;
  /* ForBug No : 1321519 End */
  g_constraint_threshold       NUMBER;
  g_base_line_revision         VARCHAR2(1);
  g_approval_orig_system       VARCHAR2(30);
  g_approval_override_by       NUMBER;

  -- Bug#4571412
  -- Introduced global variable to handle the CP
  -- completion status conditionally.
  g_soft_error_flag            VARCHAR2(1) := 'N';

  PROCEDURE Delete_Row
  ( p_api_version         IN    NUMBER,
    p_init_msg_list       IN    VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN    VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL,
    p_return_status       OUT  NOCOPY   VARCHAR2,
    p_msg_count           OUT  NOCOPY   NUMBER,
    p_msg_data            OUT  NOCOPY   VARCHAR2,
    p_budget_revision_id  IN    NUMBER);

  PROCEDURE Update_Baseline_Values
  ( p_api_version         IN    NUMBER,
    p_init_msg_list       IN    VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN    VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL,
    p_return_status       OUT  NOCOPY   VARCHAR2,
    p_msg_count           OUT  NOCOPY   NUMBER,
    p_msg_data            OUT  NOCOPY   VARCHAR2,
    p_budget_revision_id  IN    NUMBER);

  PROCEDURE Create_Budget_Revision
  ( p_api_version                    IN   NUMBER,
    p_init_msg_list                  IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                         IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level               IN   NUMBER  := FND_API.G_VALID_LEVEL_FULL,
    p_return_status                  OUT  NOCOPY  VARCHAR2,
    p_msg_count                      OUT  NOCOPY  NUMBER,
    p_msg_data                       OUT  NOCOPY  VARCHAR2,
    p_budget_revision_id          IN OUT  NOCOPY   NUMBER,
    p_budget_group_id                 IN   NUMBER  := FND_API.G_MISS_NUM,
    p_gl_budget_set_id                IN   NUMBER  := FND_API.G_MISS_NUM,
    p_hr_budget_id                    IN   NUMBER  := FND_API.G_MISS_NUM,
    p_justification                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_from_gl_period_name             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_to_gl_period_name               IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_currency_code                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_effective_start_date            IN   DATE := FND_API.G_MISS_DATE,
    p_effective_end_date              IN   DATE := FND_API.G_MISS_DATE,
    p_budget_revision_type            IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_transaction_type                IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_permanent_revision              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_revise_by_position              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_balance_type                    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_global_budget_revision          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_global_budget_revision_id       IN   NUMBER := FND_API.G_MISS_NUM,
    p_requestor                       IN   NUMBER := FND_API.G_MISS_NUM,
    p_parameter_set_id                IN   NUMBER := FND_API.G_MISS_NUM,
    p_constraint_set_id               IN   NUMBER := FND_API.G_MISS_NUM,
    p_submission_date                 IN   DATE := FND_API.G_MISS_DATE,
    p_submission_status               IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_approval_orig_system            IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_approval_override_by            IN   NUMBER := FND_API.G_MISS_NUM,
    p_freeze_flag                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_request_id                      IN   NUMBER := FND_API.G_MISS_NUM,
    p_base_line_revision              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute1                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute2                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute3                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute4                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute5                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute6                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute7                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute8                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute9                      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute10                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute11                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute12                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute13                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute14                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute15                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute16                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute17                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute18                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute19                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute20                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute21                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute22                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute23                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute24                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute25                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute26                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute27                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute28                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute29                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_attribute30                     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_context                         IN   VARCHAR2 := FND_API.G_MISS_CHAR);

  PROCEDURE Cache_Revision_Variables
  (p_return_status          OUT  NOCOPY   VARCHAR2,
   p_budget_revision_id     IN   NUMBER);

  PROCEDURE Create_Mass_Revision_Entries
  ( p_api_version         IN    NUMBER,
    p_init_msg_list       IN    VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN    VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN    NUMBER  := FND_API.G_VALID_LEVEL_FULL,
    p_return_status       OUT  NOCOPY   VARCHAR2,
    p_msg_count           OUT  NOCOPY   NUMBER,
    p_msg_data            OUT  NOCOPY   VARCHAR2,
    p_data_extract_id     IN      NUMBER,
    p_budget_revision_id  IN      NUMBER,
    p_parameter_id        IN      NUMBER := FND_API.G_MISS_NUM);

  PROCEDURE Create_Revision_Accounts
  ( p_api_version                     IN     NUMBER,
    p_init_msg_list                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                          IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level                IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_return_status                   OUT  NOCOPY    VARCHAR2,
    p_msg_count                       OUT  NOCOPY    NUMBER,
    p_msg_data                        OUT  NOCOPY    VARCHAR2,
    p_budget_revision_id              IN     NUMBER   := FND_API.G_MISS_NUM,
    p_budget_revision_acct_line_id    IN OUT  NOCOPY NUMBER,
    p_code_combination_id             IN     NUMBER,
    p_budget_group_id                 IN     NUMBER,
    p_position_id                     IN     NUMBER := FND_API.G_MISS_NUM,
    p_gl_period_name                  IN     VARCHAR2,
    p_gl_budget_version_id            IN     NUMBER := FND_API.G_MISS_NUM,
    p_currency_code                   IN     VARCHAR2,
    p_budget_balance                  IN     NUMBER,
    p_revision_type                   IN     VARCHAR2,
    p_revision_value_type             IN     VARCHAR2,
    p_revision_amount                 IN     NUMBER,
    p_funds_status_code               IN     VARCHAR2,
    p_funds_result_code               IN     VARCHAR2,
    p_funds_control_timestamp         IN     DATE,
    p_note_id                         IN     NUMBER,
    p_freeze_flag                     IN     VARCHAR2,
    p_view_line_flag                  IN     VARCHAR2,
    p_functional_transaction          IN     VARCHAR2 := NULL);

  PROCEDURE Create_Revision_Positions
  ( p_api_version                     IN     NUMBER,
    p_init_msg_list                   IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                          IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level                IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_return_status                   OUT  NOCOPY    VARCHAR2,
    p_msg_count                       OUT  NOCOPY    NUMBER,
    p_msg_data                        OUT  NOCOPY    VARCHAR2,
    p_budget_revision_id              IN     NUMBER ,
    p_budget_revision_pos_line_id     IN OUT  NOCOPY NUMBER,
    p_position_id                     IN     NUMBER,
    p_budget_group_id                 IN     NUMBER,
    p_effective_start_date            IN     DATE,
    p_effective_end_date              IN     DATE,
    p_revision_type                   IN     VARCHAR2,
    p_revision_value_type             IN     VARCHAR2,
    p_revision_value                  IN     NUMBER,
    p_note_id                         IN     NUMBER,
    p_freeze_flag                     IN     VARCHAR2,
    p_view_line_flag                  IN     VARCHAR2);

  PROCEDURE Budget_Revision_Funds_Check
  ( p_api_version            IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_return_status          OUT  NOCOPY  VARCHAR2,
    p_msg_count              OUT  NOCOPY  NUMBER,
    p_msg_data               OUT  NOCOPY  VARCHAR2,
    p_budget_revision_id     IN   NUMBER,
    p_funds_reserve_flag     IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    p_fund_check_failures    OUT  NOCOPY  NUMBER, -- bug#4341619
    --Bug#4310411
    p_called_from            IN           VARCHAR2 := 'PSBBGRVS');

  PROCEDURE Apply_Revision_Acct_Parameters
  ( p_api_version            IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_return_status          OUT  NOCOPY  VARCHAR2,
    p_parameter_id           IN   NUMBER,
    p_parameter_name         IN   VARCHAR2,
    p_compound_annually      IN   VARCHAR2,
    p_compound_factor        IN   NUMBER,
    p_original_budget        IN   NUMBER,
    p_current_budget         IN   NUMBER,
    p_revision_amount        OUT  NOCOPY  NUMBER);

  Function Find_System_Data_Extract
  ( p_budget_group_id  IN  NUMBER) RETURN NUMBER;

  -- Bug 3029168 added p_currency_code
  Function Find_Original_Budget_Balance
   (p_code_combination_id    IN      NUMBER,
    p_budget_group_id        IN      NUMBER,
    p_gl_period              IN      VARCHAR2,
    p_gl_budget_version_id   IN      NUMBER,
    p_set_of_books_id        IN      NUMBER := FND_API.G_MISS_NUM,
    p_end_gl_period          IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_currency_code          IN      VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  PROCEDURE Find_FTE
  ( p_api_version            IN      NUMBER,
    p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level       IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_return_status          OUT  NOCOPY     VARCHAR2,
    p_msg_count              OUT  NOCOPY     NUMBER,
    p_msg_data               OUT  NOCOPY     VARCHAR2,
    p_position_id            IN      NUMBER,
    p_hr_budget_id           IN      NUMBER,
    p_budget_revision_id     IN      NUMBER,
    p_revision_type          IN      VARCHAR2,
    p_revision_value_type    IN      VARCHAR2,
    p_revision_value         IN      NUMBER,
    p_effective_start_date   IN      DATE,
    p_effective_end_date     IN      DATE,
    p_original_fte           OUT  NOCOPY     NUMBER,
    p_current_fte            OUT  NOCOPY     NUMBER,
    p_revised_fte            OUT  NOCOPY     NUMBER);

PROCEDURE Calculate_Position_Cost
( p_api_version                 IN   NUMBER,
  p_init_msg_list               IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_msg_count                   OUT  NOCOPY  NUMBER,
  p_msg_data                    OUT  NOCOPY  VARCHAR2,
  p_return_status               OUT  NOCOPY  VARCHAR2,
  p_mass_revision               IN   BOOLEAN := FALSE,
  p_budget_revision_id          IN   NUMBER,
  p_position_id                 IN   NUMBER,
  p_revision_start_date         IN   DATE,
  p_revision_end_date           IN   DATE,
  p_parameter_id                IN   NUMBER DEFAULT NULL -- Bug#4675858
) ;

-- Bug 3029168 added p_event_type
PROCEDURE CREATE_BASE_BUDGET_REVISION
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_worksheet_id        IN      NUMBER,
  p_event_type          IN      VARCHAR2  DEFAULT 'BP');

PROCEDURE Apply_Constraints
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_validation_status         OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id        IN   NUMBER,
  p_constraint_set_id         IN   NUMBER);

PROCEDURE Delete_Revision_Accounts
( p_api_version                     IN      NUMBER,
  p_init_msg_list                   IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                          IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                   OUT  NOCOPY     VARCHAR2,
  p_msg_count                       OUT  NOCOPY     NUMBER,
  p_msg_data                        OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id              IN      NUMBER,
  p_budget_revision_acct_line_id    IN      NUMBER);

PROCEDURE Delete_Revision_Positions
( p_api_version                     IN      NUMBER,
  p_init_msg_list                   IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                          IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                   OUT  NOCOPY     VARCHAR2,
  p_msg_count                       OUT  NOCOPY     NUMBER,
  p_msg_data                        OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id              IN      NUMBER,
  p_budget_revision_pos_line_id     IN      NUMBER);

Function Get_GL_Balance
(p_revision_type         IN    VARCHAR2,
 p_balance_type          IN    VARCHAR2,
 p_set_of_books_id       IN    NUMBER,
 p_xbc_enabled_flag      IN    VARCHAR2,
 p_gl_period_name        IN    VARCHAR2,
 p_gl_budget_version_id  IN    NUMBER,
 p_currency_code         IN    VARCHAR2,
 p_code_combination_id   IN    NUMBER) RETURN NUMBER;

FUNCTION Get_Rounded_Amount
( p_currency_code             IN       VARCHAR2,
  p_amount                    IN       NUMBER
)  RETURN NUMBER;

PROCEDURE Mass_Budget_Revision_CP
( errbuf                      OUT  NOCOPY     VARCHAR2,
  retcode                     OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id        IN      NUMBER);

PROCEDURE Revision_Funds_Check_CP
( errbuf                      OUT  NOCOPY     VARCHAR2,
  retcode                     OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id        IN      NUMBER);

PROCEDURE Revise_Projections_CP
( errbuf                OUT  NOCOPY  VARCHAR2,
  retcode               OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id  IN   NUMBER,
  p_parameter_id        IN   NUMBER,
/*Bug:5753424: Added p_param_type to pass the Type of parameters to be processed*/
  p_param_type          IN   VARCHAR2 := 'No Param Set'
  );

PROCEDURE Delete_Budget_Revision_CP
( errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  p_from_budget_revision_id   IN       NUMBER,
  p_to_budget_revision_id     IN       NUMBER,
  p_submission_status         IN       VARCHAR2);


/* Budget Revison Rules Enhancement Start */

PROCEDURE Apply_Revision_Rules
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_validation_status         OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id        IN   NUMBER
);

PROCEDURE Apply_Detail_Revision_Rules
(
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_rule_validation_status      OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id          IN      NUMBER,
  p_rule_id                     IN      NUMBER,
  p_rule_type                   IN      VARCHAR2,
  p_apply_account_set_flag      IN      VARCHAR2,
  p_balance_account_set_flag    IN      VARCHAR2,
  p_segment_name                IN      VARCHAR2,
  p_application_column_name     IN      VARCHAR2,
  p_chart_of_accounts_id        IN      NUMBER
);

PROCEDURE Process_Balance_Rule
(
  p_return_status               OUT  NOCOPY             VARCHAR2,
  p_apply_cr                    IN  OUT  NOCOPY         NUMBER,
  p_apply_dr                    IN  OUT  NOCOPY         NUMBER,
  p_balance_cr                  IN  OUT  NOCOPY         NUMBER,
  p_balance_dr                  IN  OUT  NOCOPY         NUMBER,
  p_seg_apply_cr                IN  OUT  NOCOPY         fnd_flex_ext.SegmentArray,
  p_seg_apply_dr                IN  OUT  NOCOPY         fnd_flex_ext.SegmentArray,
  p_seg_balance_cr              IN  OUT  NOCOPY         fnd_flex_ext.SegmentArray,
  p_seg_balance_dr              IN  OUT  NOCOPY         fnd_flex_ext.SegmentArray,
  p_budget_revision_id          IN              NUMBER,
  p_rule_id                     IN              NUMBER,
  p_apply_account_set_flag      IN              VARCHAR2,
  p_balance_account_set_flag    IN              VARCHAR2,
  p_segment_name                IN              VARCHAR2,
  p_application_column_name     IN              VARCHAR2,
  p_ccid                        IN              NUMBER,
  p_apply_balance_flag          IN              VARCHAR2
);

PROCEDURE Process_Perm_Temp_Rule
(
  p_return_status               OUT  NOCOPY  VARCHAR2,
  p_rule_validation_status      OUT  NOCOPY  VARCHAR2,
  p_budget_revision_id          IN   NUMBER,
  p_rule_id                     IN   NUMBER,
  p_rule_type                   IN   VARCHAR2,
  p_apply_account_set_flag      IN   VARCHAR2,
  p_ccid                        IN   VARCHAR2,
  p_apply_balance_flag          IN   VARCHAR2
);

/* Budget Revison Rules Enhancement End */

/* Bug No 1808330 Start */

PROCEDURE Create_Note
( p_return_status               OUT  NOCOPY  VARCHAR2,
  p_account_line_id             IN   NUMBER,
  p_position_line_id            IN   NUMBER,
  p_note                        IN   VARCHAR2,
  p_flex_code                   IN   NUMBER,  -- Bug#4571412
  p_cc_id                       IN   NUMBER   DEFAULT NULL -- Bug#4675858
);

/* Bug No 1808330 End */

/* bug no 3439168 */
PROCEDURE set_position_update_flag
(
  x_return_status               OUT  NOCOPY VARCHAR2, -- Bug#4460150
  p_position_id                 IN          NUMBER
);
/* bug no 3439168 */

/* Bug#5726358 Start*/

PROCEDURE Lock_Revision_Accounts
( p_api_version                  IN      NUMBER,
  p_init_msg_list                IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                       IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level             IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                OUT  NOCOPY  VARCHAR2,
  p_msg_count                    OUT  NOCOPY  NUMBER,
  p_msg_data                     OUT  NOCOPY  VARCHAR2,
  p_lock_row                     OUT  NOCOPY  VARCHAR2,    --bug:7162585
  p_row_id                       IN      ROWID,
  p_budget_revision_id           IN      NUMBER ,
  p_budget_revision_acct_line_id IN OUT NOCOPY  NUMBER,
  p_code_combination_id          IN      NUMBER,
  p_budget_group_id              IN      NUMBER,

  p_gl_period_name               IN      VARCHAR2,
  p_gl_budget_version_id         IN      NUMBER := FND_API.G_MISS_NUM,
  p_currency_code                IN      VARCHAR2,
  p_budget_balance               IN      NUMBER,
  p_revision_type                IN      VARCHAR2,
  p_revision_value_type          IN      VARCHAR2,
  p_revision_amount              IN      NUMBER,
  p_funds_status_code            IN      VARCHAR2,
  p_funds_result_code            IN      VARCHAR2,
  p_funds_control_timestamp      IN      DATE,
  p_note_id                      IN      NUMBER,
  p_freeze_flag                  IN      VARCHAR2,
  p_actual_balance               IN      NUMBER,
  p_account_type                 IN      VARCHAR2,
  p_encumbrance_balance          IN      NUMBER,
  p_last_update_date             IN      DATE,
  p_last_updated_by              IN      NUMBER,
  p_last_update_login            IN      NUMBER,
  p_created_by                   IN      NUMBER,
  p_creation_date                IN      DATE);

/* Bug#5726358 End*/

/*Bug:7162585:start*/
PROCEDURE Lock_Budget_Revision (
          p_api_version                  NUMBER,
          p_init_msg_list                VARCHAR2 := FND_API.G_FALSE,
          p_commit                       VARCHAR2 := FND_API.G_FALSE,
          p_validation_level             NUMBER,
          p_return_status                OUT  NOCOPY  VARCHAR2,
          p_msg_count                    OUT  NOCOPY  NUMBER,
          p_msg_data                     OUT  NOCOPY  VARCHAR2,
          p_lock_row                     OUT  NOCOPY  VARCHAR2,
          P_ROWID                        ROWID,
          P_BUDGET_REVISION_ID           NUMBER,
          P_JUSTIFICATION                VARCHAR2,
          P_BUDGET_GROUP_ID              NUMBER,
          P_GL_BUDGET_SET_ID             NUMBER,
          P_HR_BUDGET_ID                 NUMBER,
          P_CONSTRAINT_SET_ID            NUMBER,
          P_BUDGET_REVISION_TYPE         VARCHAR2,
          P_FROM_GL_PERIOD_NAME          VARCHAR2,
          P_TO_GL_PERIOD_NAME            VARCHAR2,
          P_EFFECTIVE_START_DATE         DATE,
          P_EFFECTIVE_END_DATE           DATE,
          P_TRANSACTION_TYPE             VARCHAR2,
          P_CURRENCY_CODE                VARCHAR2,
          P_PERMANENT_REVISION           VARCHAR2,
          P_REVISE_BY_POSITION           VARCHAR2,
          P_BALANCE_TYPE                 VARCHAR2,
          P_PARAMETER_SET_ID             NUMBER,
          P_REQUESTOR                    NUMBER,
          P_SUBMISSION_DATE              DATE,
          P_SUBMISSION_STATUS            VARCHAR2,
          P_FREEZE_FLAG                  VARCHAR2,
          P_APPROVAL_ORIG_SYSTEM         VARCHAR2,
          P_APPROVAL_OVERRIDE_BY         NUMBER,
          P_BASE_LINE_REVISION           VARCHAR2,
          P_GLOBAL_BUDGET_REVISION       VARCHAR2,
          P_GLOBAL_BUDGET_REVISION_ID    NUMBER,
          P_LAST_UPDATE_DATE             DATE,
          P_LAST_UPDATED_BY              NUMBER,
          P_LAST_UPDATE_LOGIN            NUMBER,
          P_CREATED_BY                   NUMBER,
          P_CREATION_DATE                DATE,
          P_ATTRIBUTE1                   VARCHAR2,
          P_ATTRIBUTE2                   VARCHAR2,
          P_ATTRIBUTE3                   VARCHAR2,
          P_ATTRIBUTE4                   VARCHAR2,
          P_ATTRIBUTE5                   VARCHAR2,
          P_ATTRIBUTE6                   VARCHAR2,
          P_ATTRIBUTE7                   VARCHAR2,
          P_ATTRIBUTE8                   VARCHAR2,
          P_ATTRIBUTE9                   VARCHAR2,
          P_ATTRIBUTE10                  VARCHAR2,
          P_ATTRIBUTE11                  VARCHAR2,
          P_ATTRIBUTE12                  VARCHAR2,
          P_ATTRIBUTE13                  VARCHAR2,
          P_ATTRIBUTE14                  VARCHAR2,
          P_ATTRIBUTE15                  VARCHAR2,
          P_ATTRIBUTE16                  VARCHAR2,
          P_ATTRIBUTE17                  VARCHAR2,
          P_ATTRIBUTE18                  VARCHAR2,
          P_ATTRIBUTE19                  VARCHAR2,
          P_ATTRIBUTE20                  VARCHAR2,
          P_ATTRIBUTE21                  VARCHAR2,
          P_ATTRIBUTE22                  VARCHAR2,
          P_ATTRIBUTE23                  VARCHAR2,
          P_ATTRIBUTE24                  VARCHAR2,
          P_ATTRIBUTE25                  VARCHAR2,
          P_ATTRIBUTE26                  VARCHAR2,
          P_ATTRIBUTE27                  VARCHAR2,
          P_ATTRIBUTE28                  VARCHAR2,
          P_ATTRIBUTE29                  VARCHAR2,
          P_ATTRIBUTE30                  VARCHAR2,
          P_CONTEXT                      VARCHAR2
    );
/*Bug:7162585:end*/


END PSB_BUDGET_REVISIONS_PVT;

/
