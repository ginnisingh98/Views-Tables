--------------------------------------------------------
--  DDL for Package PSB_WS_LINE_YEAR_O_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_LINE_YEAR_O_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWLYOS.pls 120.3 2005/09/23 08:39:56 shtripat ship $ */

-- Bug#4571412.
-- Added p_year_name_C1..12 parameters to
-- pass Budget Year name to Create_Notes API.

PROCEDURE Update_Row
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status              OUT  NOCOPY      VARCHAR2,
  p_msg_count                  OUT  NOCOPY      NUMBER,
  p_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_worksheet_id                IN      NUMBER,
  p_position_line_id            IN      NUMBER,
  p_element_set_id              IN      NUMBER,
  p_salary_account_line         IN      VARCHAR2,
  p_budget_group_id             IN      NUMBER,
  p_service_package_id          IN      NUMBER,
  p_flex_code                   IN      NUMBER,
  p_concatenated_segments       IN      VARCHAR2,
  p_currency_code               IN      VARCHAR2,
  p_note                        IN      VARCHAR2 DEFAULT NULL,
  p_sbi_year_option_year_id     IN      NUMBER   DEFAULT NULL,
  p_column_count                IN      NUMBER,
  --
  p_wal_id_C1                   IN      NUMBER,
  p_year_id_C1                  IN      NUMBER,
  p_year_name_C1                IN      VARCHAR2,
  p_balance_type_C1             IN      VARCHAR2,
  p_ytd_amount_C1               IN      NUMBER,
  p_wal_id_C2                   IN      NUMBER,
  p_year_id_C2                  IN      NUMBER,
  p_year_name_C2                IN      VARCHAR2,
  p_balance_type_C2             IN      VARCHAR2,
  p_ytd_amount_C2               IN      NUMBER,
  p_wal_id_C3                   IN      NUMBER,
  p_year_id_C3                  IN      NUMBER,
  p_year_name_C3                IN      VARCHAR2,
  p_balance_type_C3             IN      VARCHAR2,
  p_ytd_amount_C3               IN      NUMBER,
  p_wal_id_C4                   IN      NUMBER,
  p_year_id_C4                  IN      NUMBER,
  p_year_name_C4                IN      VARCHAR2,
  p_balance_type_C4             IN      VARCHAR2,
  p_ytd_amount_C4               IN      NUMBER,
  p_wal_id_C5                   IN      NUMBER,
  p_year_id_C5                  IN      NUMBER,
  p_year_name_C5                IN      VARCHAR2,
  p_balance_type_C5             IN      VARCHAR2,
  p_ytd_amount_C5               IN      NUMBER,
  p_wal_id_C6                   IN      NUMBER,
  p_year_id_C6                  IN      NUMBER,
  p_year_name_C6                IN      VARCHAR2,
  p_balance_type_C6             IN      VARCHAR2,
  p_ytd_amount_C6               IN      NUMBER,
  p_wal_id_C7                   IN      NUMBER,
  p_year_id_C7                  IN      NUMBER,
  p_year_name_C7                IN      VARCHAR2,
  p_balance_type_C7             IN      VARCHAR2,
  p_ytd_amount_C7               IN      NUMBER,
  p_wal_id_C8                   IN      NUMBER,
  p_year_id_C8                  IN      NUMBER,
  p_year_name_C8                IN      VARCHAR2,
  p_balance_type_C8             IN      VARCHAR2,
  p_ytd_amount_C8               IN      NUMBER,
  p_wal_id_C9                   IN      NUMBER,
  p_year_id_C9                  IN      NUMBER,
  p_year_name_C9                IN      VARCHAR2,
  p_balance_type_C9             IN      VARCHAR2,
  p_ytd_amount_C9               IN      NUMBER,
  p_wal_id_C10                  IN      NUMBER,
  p_year_id_C10                 IN      NUMBER,
  p_year_name_C10               IN      VARCHAR2,
  p_balance_type_C10            IN      VARCHAR2,
  p_ytd_amount_C10              IN      NUMBER,
  p_wal_id_C11                  IN      NUMBER,
  p_year_id_C11                 IN      NUMBER,
  p_year_name_C11               IN      VARCHAR2,
  p_balance_type_C11            IN      VARCHAR2,
  p_ytd_amount_C11              IN      NUMBER,
  p_wal_id_C12                  IN      NUMBER,
  p_year_id_C12                 IN      NUMBER,
  p_year_name_C12               IN      VARCHAR2,
  p_balance_type_C12            IN      VARCHAR2,
  p_ytd_amount_C12              IN      NUMBER
);

END PSB_WS_LINE_YEAR_O_PVT;

 

/
