--------------------------------------------------------
--  DDL for Package PSB_WS_POS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_POS2" AUTHID CURRENT_USER AS
/* $Header: PSBVWP2S.pls 120.3.12010000.3 2009/08/17 14:30:17 rkotha ship $ */

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Worksheet_Positions
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/09/1997 by Supriyo Ghosh
  --
  --    Notes           : Create Worksheet Positions
  --

PROCEDURE Create_Worksheet_Positions
( p_return_status              OUT  NOCOPY  VARCHAR2,
  p_root_budget_group_id       IN   NUMBER,
  p_global_worksheet_id        IN   NUMBER,
  p_worksheet_id               IN   NUMBER,
  p_global_worksheet           IN   VARCHAR2,
  p_budget_group_id            IN   NUMBER,
  p_worksheet_numyrs           IN   NUMBER,
  p_rounding_factor            IN   NUMBER,
  p_service_package_id         IN   NUMBER,
  p_stage_set_id               IN   NUMBER,
  p_start_stage_seq            IN   NUMBER,
  p_current_stage_seq          IN   NUMBER,
  p_data_extract_id            IN   NUMBER,
  p_business_group_id          IN   NUMBER,
  p_budget_calendar_id         IN   NUMBER,
  p_parameter_set_id           IN   NUMBER,
  p_func_currency              IN   VARCHAR2,
  p_flex_mapping_set_id        IN   NUMBER,
  p_flex_code                  IN   NUMBER,
  p_apply_element_parameters   IN   VARCHAR2,
  p_apply_position_parameters  IN   VARCHAR2
);

/* ----------------------------------------------------------------------- */

  --    API name        : Calculate_Position_Cost
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 12/09/1997 by Supriyo Ghosh
  --
  --    Notes           : Calculate Position Cost
  --

PROCEDURE Calculate_Position_Cost
( p_api_version           IN   NUMBER,
  p_validation_level      IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_position_line_id      IN   NUMBER,
  p_recalculate_flag      IN   VARCHAR2 := FND_API.G_TRUE,
  p_root_budget_group_id  IN   NUMBER default null,
  p_global_worksheet_id   IN   NUMBER default null,
  p_assign_worksheet_id   IN   NUMBER default null,
  p_worksheet_numyrs      IN   NUMBER default null,
  p_rounding_factor       IN   NUMBER default null,
  p_service_package_id    IN   NUMBER default null,
  p_stage_set_id          IN   NUMBER default null,
  p_start_stage_seq       IN   NUMBER default null,
  p_current_stage_seq     IN   NUMBER default null,
  p_data_extract_id       IN   NUMBER default null,
  p_business_group_id     IN   NUMBER default null,
  p_budget_calendar_id    IN   NUMBER default null,
  p_func_currency         IN   VARCHAR2 default null,
  p_flex_mapping_set_id   IN   NUMBER default null,
  p_flex_code             IN   NUMBER default null,
  p_position_id           IN   NUMBER default null,
  p_position_name         IN   VARCHAR2 default null,
  p_position_start_date   IN   DATE default null,
  p_position_end_date     IN   DATE default null,
  p_budget_year_id        IN   NUMBER DEFAULT NULL, -- Bug 4379636
  p_lparam_flag           IN   VARCHAR2 := FND_API.G_FALSE  --bug:5635570

);

/* ----------------------------------------------------------------------- */

FUNCTION Get_Attribute_Value
( p_attribute_value_id  IN  NUMBER
) RETURN NUMBER;

END PSB_WS_POS2;

/
