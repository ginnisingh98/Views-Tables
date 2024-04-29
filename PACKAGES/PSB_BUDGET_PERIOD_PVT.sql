--------------------------------------------------------
--  DDL for Package PSB_BUDGET_PERIOD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_BUDGET_PERIOD_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVPRDS.pls 120.2 2005/07/13 11:29:07 shtripat ship $ */

PROCEDURE INSERT_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_rowid               in OUT  NOCOPY varchar2,
  p_budget_period_id    in number,
  p_budget_calendar_id  in number,
  p_description                 in varchar2,
  p_start_date          in date,
  p_end_date            in date,
  p_name                in varchar2,
  p_budget_year_type_id in number,
  p_parent_budget_period_id in number,
  p_budget_period_type in varchar2,
  p_period_distribution_type in varchar2,
  p_calculation_period_type in varchar2,
  p_attribute1  in varchar2,
  p_attribute2  in varchar2,
  p_attribute3  in varchar2,
  p_attribute4  in varchar2,
  p_attribute5  in varchar2,
  p_attribute6  in varchar2,
  p_attribute7  in varchar2,
  p_attribute8  in varchar2,
  p_attribute9  in varchar2,
  p_attribute10 in varchar2,
  p_context     in varchar2,
  p_mode        in varchar2 default 'R',
  p_requery    OUT  NOCOPY varchar2
  );
--
--
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
  p_budget_period_id    in number,
  p_budget_calendar_id  in number,
  p_description                 in varchar2,
  p_start_date          in date,
  p_end_date            in date,
  p_name                in varchar2,
  p_budget_year_type_id in number,
  p_parent_budget_period_id in number,
  p_budget_period_type in varchar2,
  p_period_distribution_type in varchar2,
  p_calculation_period_type in varchar2,
  p_attribute1  in varchar2,
  p_attribute2  in varchar2,
  p_attribute3  in varchar2,
  p_attribute4  in varchar2,
  p_attribute5  in varchar2,
  p_attribute6  in varchar2,
  p_attribute7  in varchar2,
  p_attribute8  in varchar2,
  p_attribute9  in varchar2,
  p_attribute10 in varchar2,
  p_context     in varchar2
);
--
--
--
PROCEDURE UPDATE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_budget_period_id    in number,
  p_budget_calendar_id  in number,
  p_description         in varchar2,
  p_start_date          in date,
  p_end_date            in date,
  p_name                in varchar2,
  p_budget_year_type_id in number,
  p_parent_budget_period_id  in number,
  p_budget_period_type       in varchar2,
  p_period_distribution_type in varchar2,
  p_calculation_period_type  in varchar2,
  p_attribute1  in varchar2,
  p_attribute2  in varchar2,
  p_attribute3  in varchar2,
  p_attribute4  in varchar2,
  p_attribute5  in varchar2,
  p_attribute6  in varchar2,
  p_attribute7  in varchar2,
  p_attribute8  in varchar2,
  p_attribute9  in varchar2,
  p_attribute10 in varchar2,
  p_context     in varchar2,
  p_mode        in varchar2 default 'R',
  p_requery    OUT  NOCOPY varchar2
  );
--
--
--
PROCEDURE ADD_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_rowid               in OUT  NOCOPY varchar2,
  p_budget_period_id    in number,
  p_budget_calendar_id  in number,
  p_description         in varchar2,
  p_start_date          in date,
  p_end_date            in date,
  p_name                in varchar2,
  p_budget_year_type_id in number,
  p_parent_budget_period_id  in number,
  p_budget_period_type       in varchar2,
  p_period_distribution_type in varchar2,
  p_calculation_period_type  in varchar2,
  p_attribute1  in varchar2,
  p_attribute2  in varchar2,
  p_attribute3  in varchar2,
  p_attribute4  in varchar2,
  p_attribute5  in varchar2,
  p_attribute6  in varchar2,
  p_attribute7  in varchar2,
  p_attribute8  in varchar2,
  p_attribute9  in varchar2,
  p_attribute10 in varchar2,
  p_context     in varchar2,
  p_mode        in varchar2 default 'R',
  p_requery    OUT  NOCOPY varchar2
  );
--
--
--
PROCEDURE DELETE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_budget_period_id    in number
);
--
--
--
--
PROCEDURE Copy_Years_In_Calendar(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_source_cal_id       IN      NUMBER,
  p_target_cal_id       IN      NUMBER,
  p_shift_flag          IN      VARCHAR2);
--
--
PROCEDURE Check_Consecutive_Year_Types(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_calendar_id         IN      NUMBER,
  p_curr_year_type      IN      NUMBER,
  p_curr_start_date     IN      DATE,
  p_curr_end_date       IN      DATE,
  p_mode_type           IN      VARCHAR2
);
--
--
FUNCTION get_debug RETURN VARCHAR2;
--
END PSB_BUDGET_PERIOD_PVT ;

 

/
