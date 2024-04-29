--------------------------------------------------------
--  DDL for Package PSB_WS_POS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_POS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBPWCPS.pls 120.4.12010000.3 2009/04/10 11:38:04 rkotha ship $ */

/* ----------------------------------------------------------------------- */

  --    API name        : Check_Allowed
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_POS1
  --    Parameters      :
  --    IN              : p_api_version               IN   NUMBER    Required
  --                      p_init_msg_list             IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level          IN   NUMBER    Optional
  --                            Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id              IN   NUMBER    Required
  --                      p_position_budget_group_id  IN   NUMBER    Required
  --                    .
  --    OUT  NOCOPY      : p_msg_count                 OUT  NOCOPY  NUMBER
  --                    p_msg_data                    OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/04/1998 by Supriyo Ghosh
  --                    .
  --    Notes           : Check if Position Budget Group is within the Budget
  --                      Group Hierarchy for the Worksheet. This function
  --                      returns values FND_API.G_TRUE or FND_API.G_FALSE.
  --

FUNCTION Check_Allowed
( p_api_version               IN   NUMBER,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER,
  p_position_budget_group_id  IN   NUMBER
) RETURN VARCHAR2;

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Position_Lines
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_POS1
  --    Parameters      :
  --    IN              : p_api_version               IN   NUMBER    Required
  --                      p_init_msg_list             IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                    IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level          IN   NUMBER    Optional
  --                            Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id              IN   NUMBER    Required
  --                      p_position_id               IN   NUMBER    Required
  --                      p_budget_group_id           IN   NUMBER    Required
  --                      p_copy_of_position_line_id  IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                    .
  --    OUT  NOCOPY      : p_return_status             OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                   OUT  NOCOPY  NUMBER
  --                    p_msg_data                    OUT  NOCOPY  VARCHAR2(2000)
  --                    p_position_line_id            OUT  NOCOPY  NUMBER
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/04/1998 by Supriyo Ghosh
  --                    .
  --    Notes           : Create Position Instance for Global Worksheet and
  --                      also create the matrix between the Position instance
  --                      and the Global Worksheet
  --

PROCEDURE Create_Position_Lines
( p_api_version               IN   NUMBER,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_position_line_id          OUT  NOCOPY  NUMBER,
  p_worksheet_id              IN   NUMBER,
  p_position_id               IN   NUMBER,
  p_budget_group_id           IN   NUMBER,
  p_copy_of_position_line_id  IN   NUMBER := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Position_Matrix
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_POS1
  --    Parameters      :
  --    IN              : p_api_version               IN   NUMBER    Required
  --                      p_init_msg_list             IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                    IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level          IN   NUMBER    Optional
  --                            Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id              IN   NUMBER    Required
  --                      p_position_line_id          IN   NUMBER    Required
  --                      p_freeze_flag               IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_view_line_flag            IN   VARCHAR2  Optional
  --                            Default = FND_API.G_TRUE
  --                    .
  --    OUT  NOCOPY      : p_return_status             OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                   OUT  NOCOPY  NUMBER
  --                    p_msg_data                    OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/04/1998 by Supriyo Ghosh
  --                    .
  --    Notes           : Create Position Matrix relationship between the
  --                      Position instance and the Global Worksheet
  --

PROCEDURE Create_Position_Matrix
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_position_line_id  IN   NUMBER,
  p_freeze_flag       IN   VARCHAR2 := FND_API.G_FALSE,
  p_view_line_flag    IN   VARCHAR2 := FND_API.G_TRUE
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_FTE_Lines
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_POS1
  --    Parameters      :
  --    IN              : p_api_version               IN   NUMBER    Required
  --                      p_init_msg_list             IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                    IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level          IN   NUMBER    Optional
  --                            Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_check_spfl_exists         IN   VARCHAR2  Optional
  --                            Default = FND_API.G_TRUE
  --                      p_recalculate_flag          IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_worksheet_id              IN   NUMBER    Required
  --                      p_flex_mapping_set_id       IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_position_line_id          IN   NUMBER    Required
  --                      p_budget_year_id            IN   NUMBER    Required
  --                      p_budget_group_id           IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_annual_fte                IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_service_package_id        IN   NUMBER    Required
  --                      p_stage_set_id              IN   NUMBER    Required
  --                      p_start_stage_seq           IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_current_stage_seq         IN   NUMBER    Required
  --                      p_end_stage_seq             IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_period_fte                IN   TABLE     Required
  --                    .
  --    OUT  NOCOPY      : p_return_status             OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                   OUT  NOCOPY  NUMBER
  --                    p_msg_data                    OUT  NOCOPY  VARCHAR2(2000)
  --                    p_fte_line_id                 OUT  NOCOPY  NUMBER
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/04/1998 by Supriyo Ghosh
  --                    .
  --    Notes           : Create Worksheet Position FTE Line
  --

PROCEDURE Create_FTE_Lines
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
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
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_POS1
  --    Parameters      :
  --    IN              : p_api_version              IN   NUMBER    Required
  --                      p_init_msg_list            IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                   IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level         IN   NUMBER    Optional
  --                            Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_check_stages             IN   VARCHAR2  Optional
  --                            Default = FND_API.G_TRUE
  --                      p_worksheet_id             IN   NUMBER    Required
  --                      p_fte_line_id              IN   NUMBER    Required
  --                      p_service_package_id       IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_current_stage_seq        IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_period_fte               IN   TABLE     Required
  --                      p_budget_group_id          IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                    .
  --    OUT  NOCOPY      : p_return_status            OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                  OUT  NOCOPY  NUMBER
  --                    p_msg_data                   OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/04/1998 by Supriyo Ghosh
  --
  --    Notes           : Update Worksheet Position FTE Line
  --

PROCEDURE Create_FTE_Lines
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
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
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_POS1
  --    Parameters      :
  --    IN              : p_api_version              IN   NUMBER    Required
  --                      p_init_msg_list            IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                   IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level         IN   NUMBER    Optional
  --                            Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_check_spel_exists        IN   VARCHAR2  Optional
  --                            Default = FND_API.G_TRUE
  --                      p_position_line_id         IN   NUMBER    Required
  --                      p_budget_year_id           IN   NUMBER    Required
  --                      p_pay_element_id           IN   NUMBER    Required
  --                      p_currency_code            IN   VARCHAR2  Required
  --                      p_element_cost             IN   NUMBER    Required
  --                      p_element_set_id           IN   NUMBER    Required
  --                      p_service_package_id       IN   NUMBER    Required
  --                      p_stage_set_id             IN   NUMBER    Required
  --                      p_start_stage_seq          IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_current_stage_seq        IN   NUMBER    Required
  --                      p_end_stage_seq            IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                    .
  --    OUT  NOCOPY             : p_return_status            OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                  OUT  NOCOPY  NUMBER
  --                    p_msg_data                   OUT  NOCOPY  VARCHAR2(2000)
  --                    p_element_line_id            OUT  NOCOPY  NUMBER
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/04/1998 by Supriyo Ghosh
  --
  --    Notes           : Create Position Element Cost Line
  --

PROCEDURE Create_Element_Lines
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_element_line_id     OUT  NOCOPY  NUMBER,
  p_check_spel_exists   IN   VARCHAR2 := FND_API.G_TRUE,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER,
  p_pay_element_id      IN   NUMBER,
  p_currency_code       IN   VARCHAR2,
  p_element_cost        IN   NUMBER,
  p_element_set_id      IN   NUMBER,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_start_stage_seq     IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER,
  p_end_stage_seq       IN   NUMBER := FND_API.G_MISS_NUM);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Element_Lines
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_POS1
  --    Parameters      :
  --    IN              : p_api_version              IN   NUMBER    Required
  --                      p_init_msg_list            IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                   IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level         IN   NUMBER    Optional
  --                            Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_check_stages             IN   VARCHAR2  Optional
  --                            Default = FND_API.G_TRUE
  --                      p_element_line_id          IN   NUMBER    Required
  --                      p_service_package_id       IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_current_stage_seq        IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_element_cost             IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                    .
  --    OUT  NOCOPY      : p_return_status            OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                  OUT  NOCOPY  NUMBER
  --                    p_msg_data                   OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 08/12/1998 by Supriyo Ghosh
  --
  --    Notes           : Update Worksheet Position Element Line
  --

PROCEDURE Create_Element_Lines
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_check_stages        IN   VARCHAR2 := FND_API.G_TRUE,
  p_element_line_id     IN   NUMBER,
  p_service_package_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER := FND_API.G_MISS_NUM,
  p_element_cost        IN   NUMBER := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */

  --    API name        : Update_Annual_FTE
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_POS1
  --    Parameters      :
  --    IN              : p_api_version              IN   NUMBER    Required
  --                      p_init_msg_list            IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                   IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level         IN   NUMBER    Optional
  --                            Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id             IN   NUMBER    Required
  --                      p_position_line_id         IN   NUMBER    Required
  --                      p_budget_year_id           IN   NUMBER    Required
  --                      p_service_package_id       IN   NUMBER    Required
  --                      p_stage_set_id             IN   NUMBER    Required
  --                      p_current_stage_seq        IN   NUMBER    Required
  --                      p_budget_group_id          IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                    .
  --    OUT  NOCOPY             : p_return_status            OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                  OUT  NOCOPY  NUMBER
  --                    p_msg_data                   OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 03/09/1998 by Supriyo Ghosh
  --
  --    Notes           : Update Annual FTE for a position instance
  --

PROCEDURE Update_Annual_FTE
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_current_stage_seq   IN   NUMBER,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */

  --    API name        : Redistribute_Follow_Salary
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_POS1
  --    Parameters      :
  --    IN              : p_api_version          IN   NUMBER    Required
  --                      p_init_msg_list        IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit               IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level     IN   NUMBER    Optional
  --                            Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id         IN   NUMBER    Required
  --                      p_position_line_id     IN   NUMBER    Required
  --                      p_budget_year_id       IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_service_package_id   IN   NUMBER    Required
  --                      p_stage_set_id         IN   NUMBER    Required
  --                      p_func_currency        IN   VARCHAR2  Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                    .
  --    OUT  NOCOPY      : p_return_status        OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count              OUT  NOCOPY  NUMBER
  --                    p_msg_data               OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/04/1998 by Supriyo Ghosh
  --
  --    Notes           : Redistribute Follow Salary
  --

PROCEDURE Redistribute_Follow_Salary
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_func_currency       IN   VARCHAR2 := FND_API.G_MISS_CHAR
);

/* ----------------------------------------------------------------------- */

  --    API name        : Apply_Element_Parameters
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_POS1
  --    Parameters      :
  --    IN              : p_api_version            IN   NUMBER    Required
  --                      p_init_msg_list          IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                 IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level       IN   NUMBER    Optional
  --                            Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id           IN   NUMBER    Required
  --                      p_global_worksheet       IN   VARCHAR2  Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_budget_group_id        IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_data_extract_id        IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_business_group_id      IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_func_currency          IN   VARCHAR2  Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_budget_calendar_id     IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_parameter_set_id       IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                    .
  --    OUT  NOCOPY      : p_return_status          OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                OUT  NOCOPY  NUMBER
  --                    p_msg_data                 OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/04/1998 by Supriyo Ghosh
  --
  --    Notes           : Apply Element Parameters (AutoIncrement
  --                      and non-AutoIncrement)
  --

PROCEDURE Apply_Element_Parameters
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_global_worksheet    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_business_group_id   IN   NUMBER := FND_API.G_MISS_NUM,
  p_func_currency       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_calendar_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_parameter_set_id    IN   NUMBER := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */

  --    API name        : Apply_Position_Parameters
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_POS1
  --    Parameters      :
  --    IN              : p_api_version           IN   NUMBER    Required
  --                      p_init_msg_list         IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level      IN   NUMBER    Optional
  --                            Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id          IN   NUMBER    Required
  --                      p_global_worksheet      IN   VARCHAR2  Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_budget_group_id       IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_data_extract_id       IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_business_group_id     IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_func_currency          IN  VARCHAR2  Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_budget_calendar_id    IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_parameter_set_id      IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                    .
  --    OUT  NOCOPY      : p_return_status         OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count               OUT  NOCOPY  NUMBER
  --                    p_msg_data                OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/04/1998 by Supriyo Ghosh
  --
  --    Notes           : Apply Position Parameters (AutoIncrement
  --                      and non-AutoIncrement)
  --

PROCEDURE Apply_Position_Parameters
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_global_worksheet    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_business_group_id   IN   NUMBER := FND_API.G_MISS_NUM,
  p_func_currency       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_calendar_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_parameter_set_id    IN   NUMBER := FND_API.G_MISS_NUM
);

/* ----------------------------------------------------------------------- */

  --    API name        : Calculate_Position_Cost
  --    Type            : Private <Interface>
  --    Pre-reqs        : FND_API, FND_MESSAGE, PSB_WS_POS2
  --    Parameters      :
  --    IN              : p_api_version           IN   NUMBER    Required
  --                      p_init_msg_list         IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_commit                IN   VARCHAR2  Optional
  --                            Default = FND_API.G_FALSE
  --                      p_validation_level      IN   NUMBER    Optional
  --                            Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_worksheet_id          IN   NUMBER    Required
  --                      p_position_line_id      IN   NUMBER    Required
  --                      p_recalculate_flag      IN   VARCHAR2  Optional
  --                            Default = FND_API.G_MISS_TRUE
  --                      p_root_budget_group_id  IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_global_worksheet_id   IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_assign_worksheet_id   IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_worksheet_numyrs      IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_rounding_factor       IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_service_package_id    IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_stage_set_id          IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_start_stage_seq       IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_current_stage_seq     IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_data_extract_id       IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_business_group_id     IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_budget_calendar_id    IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_func_currency         IN   VARCHAR2  Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_flex_code             IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_position_id           IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_NUM
  --                      p_position_name         IN   NUMBER    Optional
  --                            Default = FND_API.G_MISS_CHAR
  --                      p_position_start_date   IN   DATE      Optional
  --                            Default = FND_API.G_MISS_DATE
  --                      p_position_end_date     IN   DATE      Optional
  --                            Default = FND_API.G_MISS_DATE
  --                    .
  --    OUT  NOCOPY      :p_return_status         OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count               OUT  NOCOPY  NUMBER
  --                    p_msg_data                OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 01/04/1998 by Supriyo Ghosh
  --
  --    Notes           : Calculate Position Cost for a Position Instance.
  --                      If p_recalculate_flag is set to FND_API.G_TRUE,
  --                      this process recalculates the Position Costs for the
  --                      Position Instance
  --

PROCEDURE Calculate_Position_Cost
( p_api_version           IN   NUMBER,
  p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status         OUT  NOCOPY  VARCHAR2,
  p_msg_count             OUT  NOCOPY  NUMBER,
  p_msg_data              OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_position_line_id      IN   NUMBER,
  p_recalculate_flag      IN   VARCHAR2 := FND_API.G_TRUE,
  p_root_budget_group_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_global_worksheet_id   IN   NUMBER := FND_API.G_MISS_NUM,
  p_assign_worksheet_id   IN   NUMBER := FND_API.G_MISS_NUM,
  p_worksheet_numyrs      IN   NUMBER := FND_API.G_MISS_NUM,
  p_rounding_factor       IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id    IN   NUMBER := FND_API.G_MISS_NUM,
  p_stage_set_id          IN   NUMBER := FND_API.G_MISS_NUM,
  p_start_stage_seq       IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq     IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_business_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id    IN   NUMBER := FND_API.G_MISS_NUM,
  p_func_currency         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_flex_mapping_set_id   IN   NUMBER := FND_API.G_MISS_NUM,
  p_flex_code             IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_id           IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_name         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_position_start_date   IN   DATE := FND_API.G_MISS_DATE,
  p_position_end_date     IN   DATE := FND_API.G_MISS_DATE
);

/* ----------------------------------------------------------------------- */

  --    API name        : Revise_Position_Projections
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
  --                            Created 04/10/2000 by Supriyo Ghosh
  --

PROCEDURE Revise_Position_Projections
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

PROCEDURE Apply_Element_Parameters_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_worksheet_id              IN      NUMBER
);

PROCEDURE Validate_Positions_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_worksheet_id              IN      NUMBER
);

PROCEDURE Revise_Position_Projections_CP
(
  errbuf                      OUT  NOCOPY     VARCHAR2,
  retcode                     OUT  NOCOPY     VARCHAR2,
  p_worksheet_id              IN      NUMBER,
  p_parameter_id              IN      NUMBER
);

/* ----------------------------------------------------------------------- */
/* Bug No 2482305 Start */

PROCEDURE Revise_Element_Projections_CP
(
  errbuf          OUT  NOCOPY  VARCHAR2,
  retcode         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id  IN   NUMBER,
  p_parameter_id  IN   NUMBER
);

PROCEDURE Revise_Element_Projections
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_parameter_id      IN   NUMBER
);

/* Bug No 2482305 End */
/* ----------------------------------------------------------------------- */

/* ----------------------------------------------------------------------- */
/* Bug No 5753424 Start */

PROCEDURE Revise_Elem_Pos_Projections_CP
(
  errbuf              OUT  NOCOPY  VARCHAR2,
  retcode             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_parameter_set_id  IN   NUMBER
);

/* Bug No 5753424 End */
/* ----------------------------------------------------------------------- */

END PSB_WS_POS_PVT;

/
