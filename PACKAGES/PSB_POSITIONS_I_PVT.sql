--------------------------------------------------------
--  DDL for Package PSB_POSITIONS_I_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_POSITIONS_I_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWPOIS.pls 120.2 2005/07/13 11:36:39 shtripat ship $ */

-- View Functions

PROCEDURE Initialize_View ( p_worksheet_id IN NUMBER,
			    p_start_date   IN DATE,
			    p_end_date     IN DATE,
			    p_select_date  IN DATE := fnd_api.g_miss_date);

PROCEDURE Define_Worksheet_Values (
	    p_api_version        in number,
	    p_init_msg_list      in varchar2 := fnd_api.g_false,
	    p_commit             in varchar2 := fnd_api.g_false,
	    p_validation_level   in number := fnd_api.g_valid_level_full,
	    p_return_status      OUT  NOCOPY varchar2,
	    p_msg_count          OUT  NOCOPY number,
	    p_msg_data           OUT  NOCOPY varchar2,
	    p_worksheet_id       in number,
	    p_position_id        in number,
	    p_pos_effective_start_date in date := FND_API.G_MISS_DATE,
	    p_pos_effective_end_date   in date := FND_API.G_MISS_DATE,
	    p_budget_source             in varchar2:= FND_API.G_MISS_CHAR,
	    p_out_worksheet_id    OUT  NOCOPY number,
	    p_out_start_date      OUT  NOCOPY date,
	    p_out_end_date        OUT  NOCOPY date);

 -- modify_assignment used for insert/modify assignments

 PROCEDURE Modify_Assignment (
  p_api_version           in number,
  p_init_msg_list         in varchar2 := fnd_api.g_false,
  p_commit                in varchar2 := fnd_api.g_false,
  p_validation_level      in number   := fnd_api.g_valid_level_full,
  p_return_status         OUT  NOCOPY varchar2,
  p_msg_count             OUT  NOCOPY number,
  p_msg_data              OUT  NOCOPY varchar2,
  p_position_assignment_id  in OUT  NOCOPY  number,
  p_data_extract_id       in number,
  p_worksheet_id          in number,
  p_position_id           in number,
  p_assignment_type       in varchar2,
  p_attribute_id          in number,
  p_attribute_value_id    in number,
  p_attribute_value       in varchar2,
  p_pay_element_id        in number,
  p_pay_element_option_id in number,
  p_effective_start_date  in date,
  p_effective_end_date    in date,
  p_element_value_type    in varchar2,
  p_element_value         in number,
  p_currency_code         in varchar2,
  p_pay_basis             in varchar2,
  p_employee_id           in number,
  p_primary_employee_flag in varchar2,
  p_global_default_flag   in varchar2,
  p_assignment_default_rule_id in number,
  p_modify_flag           in varchar2,
  p_rowid                 in OUT  NOCOPY varchar2,
  p_mode                  in varchar2 default 'R'
 );


PROCEDURE Create_Default_Assignments(
  p_api_version          in   number,
  p_init_msg_list        in   varchar2 := FND_API.G_FALSE,
  p_commit               in   varchar2 := FND_API.G_FALSE,
  p_validation_level     in   number   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status        OUT  NOCOPY  varchar2,
  p_msg_count            OUT  NOCOPY  number,
  p_msg_data             OUT  NOCOPY  varchar2,
  p_worksheet_id         in   number   := FND_API.G_MISS_NUM,
  p_data_extract_id      in   number,
  p_position_id          in   number   := FND_API.G_MISS_NUM,
  p_position_start_date  in   date     := FND_API.G_MISS_DATE,
  p_position_end_date    in   date     := FND_API.G_MISS_DATE);

FUNCTION Get_Select_Date RETURN DATE;
     pragma RESTRICT_REFERENCES  ( Get_SELECT_DATE, WNDS, WNPS );

FUNCTION Check_Allowed
( p_api_version               IN   NUMBER,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER,
  p_position_budget_group_id  IN   NUMBER
) RETURN VARCHAR2;


FUNCTION Rev_Check_Allowed
( p_api_version               IN   NUMBER,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_startdate_pp              IN   DATE,
  p_enddate_cy                IN   DATE,
  p_worksheet_id              IN   NUMBER,
  p_position_budget_group_id  IN   NUMBER
) RETURN VARCHAR2;

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
  p_chart_of_accounts_id          IN      NUMBER,
  p_code_combination_id           IN      NUMBER,
  p_distribution_percent          IN      NUMBER,
  p_global_default_flag           IN      VARCHAR2,
  p_distribution_default_rule_id  IN      NUMBER,
  p_rowid                         IN OUT  NOCOPY  VARCHAR2,
  p_budget_revision_pos_line_id   IN      NUMBER:= FND_API.G_MISS_NUM,
  p_mode                          IN      VARCHAR2 default 'R'
);

PROCEDURE DELETE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_distribution_id     in number
);
--

PROCEDURE LOCK_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number   := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_row_locked          OUT  NOCOPY varchar2,
  p_distribution_id      in number,
  p_position_id          in number,
  p_data_extract_id      in number,
  p_effective_start_date   in date,
  p_effective_end_date  in date,
  p_chart_of_accounts_id     in number,
  p_code_combination_id in number,
  p_distribution_percent     in number,
  p_global_default_flag in varchar2,
  p_distribution_default_rule_id     in number
);

--
---
END PSB_POSITIONS_I_PVT ;

 

/
