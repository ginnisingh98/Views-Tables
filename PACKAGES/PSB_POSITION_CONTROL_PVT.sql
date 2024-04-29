--------------------------------------------------------
--  DDL for Package PSB_POSITION_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_POSITION_CONTROL_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVWPCS.pls 120.3 2005/07/13 11:31:20 shtripat ship $ */

/* ----------------------------------------------------------------------- */
g_checkpoint_save    CONSTANT NUMBER := 100;
g_limit_bulk_numrows CONSTANT NUMBER := 100;

PROCEDURE Convert_Organization_Attr_CP
( errbuf               OUT  NOCOPY  VARCHAR2,
  retcode              OUT  NOCOPY  VARCHAR2,
  p_business_group_id  IN   NUMBER,
  p_attribute_id       IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Upload_Worksheet_CP
( errbuf                 OUT  NOCOPY  VARCHAR2,
  retcode                OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_hr_budget_id         IN   NUMBER,
  p_from_budget_year_id  IN   NUMBER,
  p_to_budget_year_id    IN   NUMBER,
  p_run_mode             IN   VARCHAR2
);

/* ----------------------------------------------------------------------- */

PROCEDURE Upload_Budget_HRMS
( p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_msg_count            OUT  NOCOPY  NUMBER,
  p_msg_data             OUT  NOCOPY  VARCHAR2,
  p_event_type           IN   VARCHAR2,
  p_source_id            IN   NUMBER,
  p_hr_budget_id         IN   NUMBER,
  p_from_budget_year_id  IN   NUMBER,
  p_to_budget_year_id    IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Modify_Position_Accounts
( p_api_version           IN   NUMBER,
  p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status         OUT  NOCOPY  VARCHAR2,
  p_msg_count             OUT  NOCOPY  NUMBER,
  p_msg_data              OUT  NOCOPY  VARCHAR2,
  p_position_id           IN   NUMBER,
  p_hr_budget_id          IN   NUMBER,
  p_budget_revision_id    IN   NUMBER,
  p_budget_group_id       IN   NUMBER,
  p_base_line_version     IN   VARCHAR2,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE,
  p_code_combination_id   IN   NUMBER,
  p_currency_code         IN   VARCHAR2,
  p_amount                IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Modify_Position_Costs
( p_api_version           IN   NUMBER,
  p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status         OUT  NOCOPY  VARCHAR2,
  p_msg_count             OUT  NOCOPY  NUMBER,
  p_msg_data              OUT  NOCOPY  VARCHAR2,
  p_position_id           IN   NUMBER,
  p_hr_budget_id          IN   NUMBER,
  p_pay_element_id        IN   NUMBER,
  p_budget_revision_id    IN   NUMBER,
  p_base_line_version     IN   VARCHAR2,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE,
  p_currency_code         IN   VARCHAR2,
  p_element_cost          IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Modify_Position_FTE
( p_api_version           IN   NUMBER,
  p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status         OUT  NOCOPY  VARCHAR2,
  p_msg_count             OUT  NOCOPY  NUMBER,
  p_msg_data              OUT  NOCOPY  VARCHAR2,
  p_position_id           IN   NUMBER,
  p_hr_budget_id          IN   NUMBER,
  p_budget_revision_id    IN   NUMBER,
  p_base_line_version     IN   VARCHAR2,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE,
  p_fte                   IN   NUMBER
);

/* ----------------------------------------------------------------------- */

PROCEDURE Validate_Position_Budget
( p_return_status  OUT  NOCOPY  VARCHAR2,
  --p_msg_count      OUT  NOCOPY  NUMBER,
  --p_msg_data       OUT  NOCOPY  VARCHAR2,
  p_event_type     IN   VARCHAR2,
  p_source_id      IN   NUMBER);

/* ----------------------------------------------------------------------- */

PROCEDURE Upload_Element
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_source_data_extract_id  IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER,
  p_pay_element_id          IN   NUMBER
);

/* ----------------------------------------------------------------------- */
/* Bug No 2579818 Start */

PROCEDURE Upload_Attribute_Values
( p_return_status               OUT  NOCOPY  VARCHAR2,
  p_source_data_extract_id      IN   NUMBER,
  p_source_business_group_id    IN   NUMBER,
  p_target_data_extract_id      IN   NUMBER
);

/* Bug No 2579818 End */
/* ----------------------------------------------------------------------- */

END PSB_POSITION_CONTROL_PVT;

 

/
