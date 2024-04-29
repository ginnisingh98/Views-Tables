--------------------------------------------------------
--  DDL for Package PSB_WORKSHEET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WORKSHEET_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBPWCMS.pls 120.6 2005/11/14 11:50:56 viraghun ship $ */

/* ----------------------------------------------------------------------- */

  --    API name        : Create_WS_Line_Items
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WORKSHEET
  --    Parameters      :
  --    IN              : p_api_version         IN NUMBER    Required
  --                      p_init_msg_list       IN VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit              IN VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level    IN NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id        IN NUMBER    Required
  --                    .
  --    OUT  NOCOPY      : p_return_status       OUT  NOCOPY     VARCHAR2(1)
  --                    p_msg_count             OUT  NOCOPY     NUMBER
  --                    p_msg_data              OUT  NOCOPY     VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 07/07/1997 by Supriyo Ghosh
  --
  --    Notes           : Create Worksheet Account and Position Line Items
  --

PROCEDURE Create_WS_Line_Items
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

  --    API name        : Delete_WS_Line_Items
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WORKSHEET
  --    Parameters      :
  --    IN              : p_api_version         IN NUMBER    Required
  --                      p_init_msg_list       IN VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit              IN VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level    IN NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id        IN NUMBER    Required
  --                      p_global_worksheet    IN VARCHAR2  Optional
  --                            Default = FND_API.G_TRUE
  --                    .
  --    OUT  NOCOPY      : p_return_status       OUT  NOCOPY     VARCHAR2(1)
  --                    p_msg_count             OUT  NOCOPY     NUMBER
  --                    p_msg_data              OUT  NOCOPY     VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 07/07/1997 by Supriyo Ghosh
  --
  --    Notes           : Delete Worksheet Account and Position Line Items
  --

PROCEDURE Delete_WS_Line_Items
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_global_worksheet  IN   VARCHAR2 := FND_API.G_TRUE
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Worksheet
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WORKSHEET
  --    Parameters      :
  --    IN              : p_api_version                 IN NUMBER      Required
  --                      p_init_msg_list               IN VARCHAR2    Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                      IN VARCHAR2    Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level            IN NUMBER      Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_budget_group_id             IN NUMBER      Required
  --                      p_budget_calendar_id          IN NUMBER      Required
  --                      p_worksheet_type              IN VARCHAR2    Optional
  --                            Default = 'O'
  --                      p_name                        IN VARCHAR2    Required
  --                      p_description                 IN VARCHAR2    Required
  --                      p_ws_creation_complete        IN VARCHAR2    Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_stage_set_id                IN NUMBER      Required
  --                      p_current_stage_seq           IN NUMBER      Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_global_worksheet_id         IN NUMBER      Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_global_worksheet_flag       IN NUMBER      Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_global_worksheet_option     IN VARCHAR2    Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_local_copy_flag             IN VARCHAR2    Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_copy_of_worksheet_id        IN NUMBER      Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_freeze_flag                 IN VARCHAR2    Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_budget_by_position          IN VARCHAR2    Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_use_revised_element_rates   IN VARCHAR2    Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_num_proposed_years          IN NUMBER      Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_num_years_to_allocate       IN NUMBER      Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_rounding_factor             IN NUMBER      Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_gl_cutoff_period            IN DATE        Optional
  --                            Default = FND_API.G_MISS_DATE
  --                      p_budget_version_id           IN NUMBER      Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_gl_budget_set_id            IN NUMBER      Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_include_stat_balance        IN VARCHAR2    Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_include_trans_balance       IN VARCHAR2    Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_include_adj_period          IN VARCHAR2    Required
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_date_submitted              IN DATE        Optional
  --                            Default = FND_API.G_MISS_DATE
  --                      p_submitted_by                IN  NUMBER     Required
  --                            Default = FND_API.G_MISS_NUM
  --                      p_data_extract_id             IN  NUMBER     Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_parameter_set_id            IN  NUMBER     Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_constraint_set_id           IN  NUMBER     Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_allocrule_set_id            IN  NUMBER     Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_attribute1                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute2                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute3                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute4                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute5                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute6                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute7                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute8                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute9                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute10                 IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_context                     IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                    .
  --    OUT  NOCOPY      : p_return_status               OUT  NOCOPY VARCHAR2(1)
  --                    p_msg_count                     OUT  NOCOPY NUMBER
  --                    p_msg_data                      OUT  NOCOPY VARCHAR2(2000)
  --                    p_worksheet_id                  OUT  NOCOPY NUMBER
  --                    .
  --    Notes           : Create the Worksheet Header in PSB_WORKSHEETS
  --

PROCEDURE Create_Worksheet
( p_api_version                       IN   NUMBER,
  p_init_msg_list                     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status                     OUT  NOCOPY  VARCHAR2,
  p_msg_count                         OUT  NOCOPY  NUMBER,
  p_msg_data                          OUT  NOCOPY  VARCHAR2,
  p_budget_group_id                   IN   NUMBER,
  p_budget_calendar_id                IN   NUMBER,
  p_worksheet_type                    IN   VARCHAR2 := 'O',
  p_name                              IN   VARCHAR2,
  p_description                       IN   VARCHAR2,
  p_ws_creation_complete              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_stage_set_id                      IN   NUMBER,
  p_current_stage_seq                 IN   NUMBER := FND_API.G_MISS_NUM,
  p_global_worksheet_id               IN   NUMBER := FND_API.G_MISS_NUM,
  p_global_worksheet_flag             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_global_worksheet_option           IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_local_copy_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_copy_of_worksheet_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_freeze_flag                       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_by_position                IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_use_revised_element_rates         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_num_proposed_years                IN   NUMBER := FND_API.G_MISS_NUM,
  p_num_years_to_allocate             IN   NUMBER := FND_API.G_MISS_NUM,
  p_rounding_factor                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_gl_cutoff_period                  IN   DATE := FND_API.G_MISS_DATE,
  p_budget_version_id                 IN   NUMBER := FND_API.G_MISS_NUM,
  p_gl_budget_set_id                  IN   NUMBER := FND_API.G_MISS_NUM,
  p_include_stat_balance              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_trans_balance             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_adj_period                IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_data_extract_id                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_parameter_set_id                  IN   NUMBER := FND_API.G_MISS_NUM,
  p_constraint_set_id                 IN   NUMBER := FND_API.G_MISS_NUM,
  p_allocrule_set_id                  IN   NUMBER := FND_API.G_MISS_NUM,
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
  p_flex_mapping_set_id               IN   NUMBER := FND_API.G_MISS_NUM,
  p_include_gl_commit_balance         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_oblig_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_other_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_commit_balance        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_oblig_balance         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_budget_balance        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* For Bug 3157960, Added the federal_Ws_flag */
  p_federal_ws_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* bug no 4725091 */
  p_include_gl_forwd_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_worksheet_id                      OUT  NOCOPY  NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Update_Worksheet
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WORKSHEET
  --    Parameters      :
  --    IN              : p_api_version                 IN NUMBER      Required
  --                      p_init_msg_list               IN VARCHAR2    Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                      IN VARCHAR2    Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level            IN NUMBER      Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id                IN NUMBER      Required
  --                      p_worksheet_type              IN VARCHAR2    Optional
  --                             Default = FND_API.G_MISS_CHAR
  --                      p_description                 IN VARCHAR2    Optional
  --                             Default = FND_API.G_MISS_CHAR
  --                      p_ws_creation_complete        IN VARCHAR2    Optional
  --                             Default = FND_API.G_MISS_CHAR
  --                      p_global_worksheet_id         IN NUMBER      Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_current_stage_seq           IN NUMBER      Optional
  --                             Default = FND_API.G_MISS_NUM
  --                      p_local_copy_flag             IN VARCHAR2    Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_copy_of_worksheet_id        IN NUMBER      Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_freeze_flag                 IN VARCHAR2    Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_use_revised_element_rates   IN VARCHAR2    Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_date_submitted              IN DATE        Optional
  --                            Default = FND_API.G_MISS_DATE
  --                      p_submitted_by                IN  NUMBER     Required
  --                            Default = FND_API.G_MISS_NUM
  --                      p_attribute1                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute2                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute3                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute4                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute5                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute6                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute7                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute8                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute9                  IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_attribute10                 IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_context                     IN  VARCHAR2   Optional
  --                            Default = FND_API.G_MISS_CHAR
  /* For Bug No. 2312657 : Start */
  --                      p_gl_cutoff_period            IN DATE        Optional
  --                            Default = NULL
  --                      p_gl_budget_set_id            IN NUMBER      Optional
  --                            Default = NULL
  /* For Bug No. 2312657 : End */
  --                    .
  --    OUT  NOCOPY             : p_return_status               OUT  NOCOPY VARCHAR2(1)
  --                    p_msg_count                     OUT  NOCOPY NUMBER
  --                    p_msg_data                      OUT  NOCOPY VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0

  --                            Created 06/15/1997 by Supriyo Ghosh
  --                            Changed 06/15/1997 by Supriyo Ghosh
  --                              Added 2 Parameters : p_ws_creation_complete,
  --                                                   p_budget_version_id
  --
  --    Notes           : Update Worksheet Header
  --

PROCEDURE Update_Worksheet
( p_api_version                       IN   NUMBER,
  p_init_msg_list                     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status                     OUT  NOCOPY  VARCHAR2,
  p_msg_count                         OUT  NOCOPY  NUMBER,
  p_msg_data                          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                      IN   NUMBER,
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
  /* End bug # 3083970 */
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
  /* For Bug No. 3157960, added the federal_ws_flag */
  p_federal_ws_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* bug no 4725091 */
  p_include_gl_forwd_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR

  );

/* ----------------------------------------------------------------------- */

  --    API name        : Delete_Worksheet
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WORKSHEET
  --    Parameters      :
  --    IN              : p_api_version                 IN NUMBER      Required
  --                      p_init_msg_list               IN VARCHAR2    Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                      IN VARCHAR2    Optional
  --                            Default = FND_API.G_FALSE
  --                      p_worksheet_id                IN NUMBER      Required
  --                    .
  --    OUT  NOCOPY      : p_return_status               OUT  NOCOPY VARCHAR2(1)
  --                    p_msg_count                     OUT  NOCOPY NUMBER
  --                    p_msg_data                      OUT  NOCOPY VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 07/07/1997 by Supriyo Ghosh
  --
  --    Notes           : Delete Worksheet Header
  --

PROCEDURE Delete_Worksheet
( p_api_version    IN   NUMBER,
  p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit         IN   VARCHAR2 := FND_API.G_FALSE,
  p_return_status  OUT  NOCOPY  VARCHAR2,
  p_msg_count      OUT  NOCOPY  NUMBER,
  p_msg_data       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id   IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Apply_Constraints
  --    Type            : Public
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WORKSHEET
  --    Parameters      :
  --    IN              : p_api_version               IN  NUMBER    Required
  --                      p_init_msg_list             IN  VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                    IN  VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level          IN  NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id              IN  NUMBER    Required
  --                      p_budget_group_id           IN  NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_flex_code                 IN  NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_func_currency             IN  VARCHAR2  Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_global_worksheet_id       IN  NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_constraint_set_id         IN  NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_constraint_set_name       IN  VARCHAR2  Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_constraint_set_threshold  IN  NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_budget_calendar_id        IN  NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_data_extract_id           IN  NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_business_group_id         IN  NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_budget_by_position        IN  VARCHAR2  Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                    .
  --    OUT  NOCOPY     : p_return_status             OUT  NOCOPY VARCHAR2(1)
  --                    p_msg_count                   OUT  NOCOPY NUMBER
  --                    p_msg_data                    OUT  NOCOPY VARCHAR2(2000)
  --                    p_validation_status           OUT  NOCOPY VARCHAR2(1)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/06/1998 by Supriyo Ghosh
  --
  --    Notes           : Apply Constraints and log all Constraint
  --                      Validation Errors

PROCEDURE Apply_Constraints
( p_api_version               IN   NUMBER,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
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
  --    Type            : Public
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WORKSHEET
  --    Parameters      :
  --    IN              : p_api_version               IN  NUMBER    Required
  --                      p_init_msg_list             IN  VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level          IN  NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_data_extract_id           IN  NUMBER    Required
  --                      p_parameter_set_id          IN  NUMBER    Required
  --                      p_constraint_set_id         IN  NUMBER    Required
  --                    .
  --    OUT  NOCOPY             : p_return_status             OUT  NOCOPY VARCHAR2(1)
  --                    p_msg_count                   OUT  NOCOPY NUMBER
  --                    p_msg_data                    OUT  NOCOPY VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/01/1998 by Supriyo Ghosh
  --
  --    Notes           : Validate Entity Sets for a Data Extract

PROCEDURE Validate_Entity_Set
( p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level   IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status      OUT  NOCOPY  VARCHAR2,
  p_msg_count          OUT  NOCOPY  NUMBER,
  p_msg_data           OUT  NOCOPY  VARCHAR2,
  p_data_extract_id    IN   NUMBER,
  p_parameter_set_id   IN   NUMBER,
  p_constraint_set_id  IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Delete_WPL
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Parameters      :
  --    IN              : p_api_version               IN  NUMBER    Required
  --                      p_init_msg_list             IN  VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level          IN  NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id              IN  NUMBER    Required
  --                      p_position_line_id          IN  NUMBER    Required
  --                    .
  --    OUT  NOCOPY             : p_return_status             OUT  NOCOPY VARCHAR2(1)
  --                    p_msg_count                   OUT  NOCOPY NUMBER
  --                    p_msg_data                    OUT  NOCOPY VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 10/10/1999 by Supriyo Ghosh
  --
  --    Notes           : Delete Worksheet Position Line.
  --

PROCEDURE Delete_WPL
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_position_line_id  IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Worksheet_Line_Items_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  p_worksheet_id              IN       NUMBER
);

PROCEDURE Validate_Accounts_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  p_worksheet_id              IN       NUMBER
);

PROCEDURE Pre_Create_WS_Lines_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  p_worksheet_id              IN       NUMBER
);

PROCEDURE Create_Acct_Line_Items_CP
(
  errbuf                              OUT  NOCOPY      VARCHAR2  ,
  retcode                             OUT  NOCOPY      VARCHAR2  ,
  p_create_non_pos_line_items         IN       VARCHAR2  ,
  p_worksheet_id                      IN       NUMBER
);

PROCEDURE Create_Pos_Line_Items_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  p_create_positions          IN       VARCHAR2  ,
  p_worksheet_id              IN       NUMBER
);

PROCEDURE Apply_Acct_Constraints_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  p_apply_constraints         IN       VARCHAR2  ,
  p_worksheet_id              IN       NUMBER
);

PROCEDURE Apply_Pos_Constraints_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  p_apply_constraints         IN       VARCHAR2  ,
  p_worksheet_id              IN       NUMBER
);

PROCEDURE Apply_Elem_Constraints_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  p_apply_constraints         IN       VARCHAR2  ,
  p_worksheet_id              IN       NUMBER
);

PROCEDURE Post_Create_WS_Lines_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  p_worksheet_id              IN       NUMBER
);

/* ----------------------------------------------------------------------- */

END PSB_WORKSHEET_PVT;

 

/
