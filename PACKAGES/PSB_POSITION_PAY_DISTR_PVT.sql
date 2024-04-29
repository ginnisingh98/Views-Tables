--------------------------------------------------------
--  DDL for Package PSB_POSITION_PAY_DISTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_POSITION_PAY_DISTR_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVPYDS.pls 120.3.12010000.3 2009/09/15 12:29:48 rkotha ship $ */

PROCEDURE INSERT_ROW
( p_api_version                      IN NUMBER,
  p_init_msg_list                    IN VARCHAR2 := fnd_api.g_false,
  p_commit                           IN VARCHAR2 := fnd_api.g_false,
  p_validation_level                 IN NUMBER := fnd_api.g_valid_level_full,
  p_return_status                    OUT  NOCOPY VARCHAR2,
  p_msg_count                        OUT  NOCOPY NUMBER,
  p_msg_data                         OUT  NOCOPY VARCHAR2,
  p_rowid                            IN OUT  NOCOPY VARCHAR2,
  p_distribution_id                  IN NUMBER,
  p_position_id                      IN NUMBER,
  p_data_extract_id                  IN NUMBER,
  p_worksheet_id                     IN NUMBER := FND_API.G_MISS_NUM,
  p_effective_start_date             IN DATE,
  p_effective_end_date               IN DATE,
  p_chart_of_accounts_id             IN NUMBER,
  p_code_combination_id              IN NUMBER,
  p_distribution_percent             IN NUMBER,
  p_global_default_flag              IN VARCHAR2,
  p_distribution_default_rule_id     IN NUMBER,
  p_project_id                       IN NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                          IN NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                         IN NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type                 IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id      IN NUMBER:= FND_API.G_MISS_NUM,
  p_description                      IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_mode                             in varchar2 default 'R'
  );
--
--
--

PROCEDURE LOCK_ROW (
  p_api_version                      IN NUMBER,
  p_init_msg_list                    IN VARCHAR2 := fnd_api.g_false,
  p_commit                           IN VARCHAR2 := fnd_api.g_false,
  p_validation_level                 IN NUMBER := fnd_api.g_valid_level_full,
  p_return_status                    OUT  NOCOPY VARCHAR2,
  p_msg_count                        OUT  NOCOPY NUMBER,
  p_msg_data                         OUT  NOCOPY VARCHAR2,
  p_row_locked                       OUT  NOCOPY VARCHAR2,
  p_distribution_id                  IN NUMBER,
  p_position_id                      IN NUMBER,
  p_data_extract_id                  IN NUMBER,
  p_worksheet_id                     IN NUMBER := FND_API.G_MISS_NUM,
  p_effective_start_date             IN DATE,
  p_effective_end_date               IN DATE,
  p_chart_of_accounts_id             IN NUMBER,
  p_code_combination_id              IN NUMBER,
  p_distribution_percent             IN NUMBER,
  p_global_default_flag              IN VARCHAR2,
  p_distribution_default_rule_id     IN NUMBER,
  p_project_id                       IN NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                          IN NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                         IN NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type                 IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id      IN NUMBER:= FND_API.G_MISS_NUM,
  p_description                      IN VARCHAR2:= FND_API.G_MISS_CHAR
);

--
--
--
PROCEDURE UPDATE_ROW (
  p_api_version                      IN NUMBER,
  p_init_msg_list                    IN VARCHAR2 := fnd_api.g_false,
  p_commit                           IN VARCHAR2 := fnd_api.g_false,
  p_validation_level                 IN NUMBER := fnd_api.g_valid_level_full,
  p_return_status                    OUT  NOCOPY VARCHAR2,
  p_msg_count                        OUT  NOCOPY NUMBER,
  p_msg_data                         OUT  NOCOPY VARCHAR2,
  p_distribution_id                  IN NUMBER,
  p_code_combination_id              IN NUMBER,
  p_effective_start_date             IN DATE := FND_API.G_MISS_DATE,
  p_effective_end_date               IN DATE := FND_API.G_MISS_DATE,
  p_distribution_percent             IN NUMBER,
  p_global_default_flag              IN VARCHAR2,
  p_distribution_default_rule_id     IN NUMBER,
  p_project_id                       IN NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                          IN NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                         IN NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type                 IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id      IN NUMBER:= FND_API.G_MISS_NUM,
  p_description                      IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_mode                             in varchar2 default 'R'
  );
--
--
--
PROCEDURE ADD_ROW (
  p_api_version                      IN NUMBER,
  p_init_msg_list                    IN VARCHAR2 := fnd_api.g_false,
  p_commit                           IN VARCHAR2 := fnd_api.g_false,
  p_validation_level                 IN NUMBER := fnd_api.g_valid_level_full,
  p_return_status                    OUT  NOCOPY VARCHAR2,
  p_msg_count                        OUT  NOCOPY NUMBER,
  p_msg_data                         OUT  NOCOPY VARCHAR2,
  p_rowid                            IN OUT  NOCOPY VARCHAR2,
  p_distribution_id                  IN NUMBER,
  p_position_id                      IN NUMBER,
  p_data_extract_id                  IN NUMBER,
  p_worksheet_id                     IN NUMBER,
  p_effective_start_date             IN DATE,
  p_effective_end_date               IN DATE,
  p_chart_of_accounts_id             IN NUMBER,
  p_code_combination_id              IN NUMBER,
  p_distribution_percent             IN NUMBER,
  p_global_default_flag              IN VARCHAR2,
  p_distribution_default_rule_id     IN NUMBER,
  p_project_id                       IN NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                          IN NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                         IN NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type                 IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id      IN NUMBER:= FND_API.G_MISS_NUM,
  p_description                      IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_mode                             in varchar2 default 'R'

  );
--
--
--
PROCEDURE DELETE_ROW (
  p_api_version         IN NUMBER,
  p_init_msg_list       IN VARCHAR2 := fnd_api.g_false,
  p_commit              IN VARCHAR2 := fnd_api.g_false,
  p_validation_level    IN NUMBER := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY VARCHAR2,
  p_msg_count           OUT  NOCOPY NUMBER,
  p_msg_data            OUT  NOCOPY VARCHAR2,
  p_distribution_id     IN NUMBER
);
--

PROCEDURE Delete_Distributions
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_data_extract_id   IN   NUMBER
);

PROCEDURE Delete_Distributions_Position
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_position_id       IN   NUMBER,
  p_worksheet_id      IN   NUMBER DEFAULT NULL  -- bug 4545909
);

--

PROCEDURE Modify_Distribution_WS
( p_api_version                   IN      NUMBER,
  p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                 OUT  NOCOPY     VARCHAR2,
  p_msg_count                     OUT  NOCOPY     NUMBER,
  p_msg_data                      OUT  NOCOPY     VARCHAR2,
  p_distribution_id               IN OUT  NOCOPY  NUMBER,
  p_worksheet_id                  IN      NUMBER := FND_API.G_MISS_NUM,
  p_position_id                   IN      NUMBER,
  p_data_extract_id               IN      NUMBER,
  p_effective_start_date          IN      DATE,
  p_effective_end_date            IN      DATE,
  p_modify_flag                   IN      VARCHAR2 := 'N',
  p_chart_of_accounts_id          IN      NUMBER,
  p_code_combination_id           IN      NUMBER,
  p_distribution_percent          IN      NUMBER,
  p_global_default_flag           IN      VARCHAR2,
  p_distribution_default_rule_id  IN      NUMBER,
  p_rowid                         IN OUT  NOCOPY  VARCHAR2,
  p_project_id                    IN      NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                       IN      NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                      IN      NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type              IN      VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id   IN      NUMBER:= FND_API.G_MISS_NUM,
  p_description                   IN      VARCHAR2:= FND_API.G_MISS_CHAR,
  p_budget_revision_pos_line_id   IN      NUMBER:= FND_API.G_MISS_NUM,
  p_mode                          IN      VARCHAR2 default 'R',
  p_ruleset_id                    IN      NUMBER := NULL
);

PROCEDURE Modify_Distribution
( p_api_version                   IN      NUMBER,
  p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                 OUT  NOCOPY     VARCHAR2,
  p_msg_count                     OUT  NOCOPY     NUMBER,
  p_msg_data                      OUT  NOCOPY     VARCHAR2,
  p_distribution_id               IN OUT  NOCOPY  NUMBER,
  p_position_id                   IN      NUMBER,
  p_data_extract_id               IN      NUMBER,
  p_worksheet_id                  IN      NUMBER := FND_API.G_MISS_NUM,
  p_effective_start_date          IN      DATE,
  p_effective_end_date            IN      DATE,
  p_chart_of_accounts_id          IN      NUMBER,
  p_code_combination_id           IN      NUMBER,
  p_distribution_percent          IN      NUMBER,
  p_global_default_flag           IN      VARCHAR2,
  p_distribution_default_rule_id  IN      NUMBER,
  p_rowid                         IN OUT  NOCOPY  VARCHAR2,
  p_project_id                    IN      NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                       IN      NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                      IN      NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type              IN      VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id   IN      NUMBER:= FND_API.G_MISS_NUM,
  p_description                   IN      VARCHAR2:= FND_API.G_MISS_CHAR,
  p_mode                          IN      VARCHAR2 default 'R'
);

PROCEDURE Modify_Extract_Distribution
( p_api_version                   IN      NUMBER,
  p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                 OUT  NOCOPY     VARCHAR2,
  p_msg_count                     OUT  NOCOPY     NUMBER,
  p_msg_data                      OUT  NOCOPY     VARCHAR2,
  p_position_id                   IN      NUMBER,
  p_data_extract_id               IN      NUMBER,
  p_chart_of_accounts_id          IN      NUMBER,
  p_distribution                  IN OUT  NOCOPY  PSB_HR_POPULATE_DATA_PVT.gl_distribution_tbl_type
);


/* Bug 1308558 Start */
-- This api is used for applying distribution default rules.

PROCEDURE Apply_Position_Pay_Distr
( p_api_version                   IN      NUMBER,
  p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT  NOCOPY     VARCHAR2,
  x_msg_count                     OUT  NOCOPY     NUMBER,
  x_msg_data                      OUT  NOCOPY     VARCHAR2,
  p_distribution_id               IN OUT  NOCOPY  NUMBER,
  p_position_id                   IN      NUMBER,
  p_data_extract_id               IN      NUMBER,
  p_worksheet_id                  IN      NUMBER,
  p_effective_start_date          IN      DATE,
  p_effective_end_date            IN      DATE,
  p_modify_flag                   IN      VARCHAR2,
  p_chart_of_accounts_id          IN      NUMBER,
  p_code_combination_id           IN      NUMBER,
  p_distribution_percent          IN      NUMBER,
  p_global_default_flag           IN      VARCHAR2,
  p_distribution_default_rule_id  IN      NUMBER,
  p_rowid                         IN OUT  NOCOPY  VARCHAR2,
  p_project_id                    IN      NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                       IN      NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                      IN      NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type              IN      VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id   IN      NUMBER:= FND_API.G_MISS_NUM,
  p_description                   IN      VARCHAR2:= FND_API.G_MISS_CHAR,
  p_mode                          IN      VARCHAR2 := 'R');

/* Bug 1308558 End */

/*Bug:5261798:start*/
-- This api is used for creating mirror copy of distribution records for a given WS/BR
-- when there are no WS/BR records exist in psb_position_pay_distributions table.

PROCEDURE CREATE_WS_POS_DISTR_FRMDE
 (p_api_version       IN          NUMBER,
  p_init_msg_list     IN          VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN          VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN          NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status    OUT  NOCOPY  VARCHAR2,
  p_msg_count        OUT  NOCOPY  NUMBER,
  p_msg_data         OUT  NOCOPY  VARCHAR2,
  p_position_id       IN          NUMBER,
  p_data_extract_id   IN          NUMBER,
  p_worksheet_id      IN          NUMBER,
  p_event_type        IN          VARCHAR2);
/*Bug:5261798:end*/

--
--
FUNCTION get_debug RETURN VARCHAR2;
--
END PSB_POSITION_PAY_DISTR_PVT ;

/
