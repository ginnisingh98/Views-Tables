--------------------------------------------------------
--  DDL for Package PSB_WS_POS3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_POS3" AUTHID CURRENT_USER AS
/* $Header: PSBVWP3S.pls 120.4.12010000.3 2010/02/22 11:50:13 rkotha ship $ */

g_flex_code NUMBER ;  -- Bug#4675858

/*Bug:8935662:start*/
TYPE g_pos_sal_dist_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
g_pos_sal_dist_flag  g_pos_sal_dist_type;
/*Bug:8935662:end*/

/* ----------------------------------------------------------------------- */

  --    API name        : Apply_Element_Parameters
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/09/1997 by Supriyo Ghosh
  --
  --    Notes           : Apply all Element Parameters
  --

PROCEDURE Apply_Element_Parameters
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
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
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/09/1997 by Supriyo Ghosh
  --
  --    Notes           : Apply all Position Parameters
  --

PROCEDURE Apply_Position_Parameters
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
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

  --    API name        : Redistribute_Follow_Salary
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/09/1997 by Supriyo Ghosh
  --
  --    Notes           : Redistribute Follow Salary
  --

PROCEDURE Redistribute_Follow_Salary
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_func_currency       IN   VARCHAR2 := FND_API.G_MISS_CHAR
);

/* ----------------------------------------------------------------------- */

  --    API name        : Apply_Element_Constraints
  --    Type            : Private <Implementation>
  --    Pre-reqs        :
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/09/1997 by Supriyo Ghosh
  --
  --    Notes           : Apply Element Constraints and log all Constraint
  --                      Validation Errors

PROCEDURE Apply_Element_Constraints
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_budget_calendar_id    IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_constraint_set_id     IN   NUMBER,
  p_constraint_set_name   IN   VARCHAR2,
  p_constraint_threshold  IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Apply_Position_Constraints
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/09/1997 by Supriyo Ghosh
  --
  --    Notes           : Apply Position Constraints and log all Constraint
  --                      Validation Errors

PROCEDURE Apply_Position_Constraints
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_validation_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_budget_calendar_id    IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_business_group_id     IN   NUMBER,
  p_func_currency         IN   VARCHAR2,
  p_constraint_set_id     IN   NUMBER,
  p_constraint_set_name   IN   VARCHAR2,
  p_constraint_threshold  IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Process_ElemCons_Detailed
( p_return_status    OUT  NOCOPY  VARCHAR2,
  p_worksheet_id     IN   NUMBER,
  p_data_extract_id  IN   NUMBER,
  p_constraint_id    IN   NUMBER,
  p_start_date       IN   DATE,
  p_end_date         IN   DATE
);

PROCEDURE Process_ElemParam
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_worksheet_id       IN   NUMBER,
  p_parameter_id       IN   NUMBER,
  p_currency_code      IN   VARCHAR2,
  p_start_date         IN   DATE,
  p_end_date           IN   DATE,
  p_compound_annually  IN   VARCHAR2,
  p_compound_factor    IN   NUMBER
);

PROCEDURE Process_ElemParam_AutoInc
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_worksheet_id       IN   NUMBER,
  p_data_extract_id    IN   NUMBER,
  p_business_group_id  IN   NUMBER,
  p_parameter_id       IN   NUMBER,
  p_currency_code      IN   VARCHAR2,
  p_start_date         IN   DATE,
  p_end_date           IN   DATE,
  p_compound_factor    IN   NUMBER
);

PROCEDURE Process_PosParam_Detailed
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_event_type              IN   VARCHAR2,
  p_local_parameter         IN   VARCHAR2,
  p_global_worksheet_id     IN   NUMBER,
  p_worksheet_id            IN   NUMBER,
  p_global_worksheet        IN   VARCHAR2,
  p_data_extract_id         IN   NUMBER,
  p_business_group_id       IN   NUMBER,
  p_parameter_id            IN   NUMBER,
  p_parameter_start_date    IN   DATE,
  p_compound_annually       IN   VARCHAR2,
  p_compound_factor         IN   NUMBER := FND_API.G_MISS_NUM,
  p_parameter_autoinc_rule  IN   VARCHAR2,
  p_currency_code           IN   VARCHAR2,
  p_start_date              IN   DATE,
  p_end_date                IN   DATE,
  p_recalculate_flag        IN   BOOLEAN := FALSE
);

PROCEDURE Process_PosParam_AutoInc
( p_return_status         OUT  NOCOPY  VARCHAR2,
  --Bug No 3315330 Start
  x_msg_data              OUT  NOCOPY  VARCHAR2,
  x_msg_count             OUT  NOCOPY  NUMBER,
  --Bug No 3315330 End
  p_worksheet_id          IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_business_group_id     IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_parameter_id          IN   NUMBER,
  p_parameter_start_date  IN   DATE,
  p_currency_code         IN   VARCHAR2,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE
);

PROCEDURE Process_PosParam
( p_return_status        OUT  NOCOPY  VARCHAR2,
  --Bug No 3315330 Start
  x_msg_data             OUT  NOCOPY  VARCHAR2,
  x_msg_count            OUT  NOCOPY  NUMBER,
  --Bug No 3315330 End
  p_worksheet_id         IN   NUMBER,
  p_global_worksheet_id  IN   NUMBER,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_parameter_id         IN   NUMBER,
  p_currency_code        IN   VARCHAR2,
  p_start_date           IN   DATE,
  p_end_date             IN   DATE,
  p_compound_annually    IN   VARCHAR2,
  p_compound_factor      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Revise_Position_Projections
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 04/10/2000 by Supriyo Ghosh
  --
  --    Notes           : Revise Position Projections
  --

PROCEDURE Revise_Position_Projections
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  --Bug No 3315330 Start
  x_msg_data          OUT  NOCOPY  VARCHAR2,
  x_msg_count         OUT  NOCOPY  NUMBER,
  --Bug No 3315330 End
  p_worksheet_id      IN   NUMBER,
  p_parameter_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */
/* Bug No 2482305 Start */

PROCEDURE Revise_Element_Projections
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_parameter_id        IN   NUMBER,
  p_recalculate_flag    IN   BOOLEAN := TRUE
);

/* Bug No 2482305 End */
/* ----------------------------------------------------------------------- */

  --    API name        : Get_Debug
  --    Type            : Private
  --    Pre-reqs        : None

FUNCTION Get_Debug RETURN VARCHAR2;

/* ----------------------------------------------------------------------- */
  --    Global Name     : note_parameter_id
  --    Type            : Private
  --    Pre-reqs        : None
  --    Added for the Fix for Part II of Bug No 1584464

g_note_parameter_name   VARCHAR2(100);

/* ----------------------------------------------------------------------- */

END PSB_WS_POS3;

/
