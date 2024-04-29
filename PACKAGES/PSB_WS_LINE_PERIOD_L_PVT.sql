--------------------------------------------------------
--  DDL for Package PSB_WS_LINE_PERIOD_L_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_LINE_PERIOD_L_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWLPLS.pls 120.2 2005/07/13 11:35:05 shtripat ship $ */




PROCEDURE Lock_Row
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status              OUT  NOCOPY      VARCHAR2,
  p_msg_count                  OUT  NOCOPY      NUMBER,
  p_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_row_locked                   OUT  NOCOPY      VARCHAR2,
  --
  p_service_package_id          IN      NUMBER,
  --
  p_column_count                IN      NUMBER,
  --
  p_wal_id                      IN      NUMBER,
  p_year_type                   IN      VARCHAR2,
  p_balance_type                IN      VARCHAR2,
  --
  p_ytd_amount                  IN      NUMBER,
  p_amount_P1                   IN      NUMBER,
  p_amount_P2                   IN      NUMBER,
  p_amount_P3                   IN      NUMBER,
  p_amount_P4                   IN      NUMBER,
  p_amount_P5                   IN      NUMBER,
  p_amount_P6                   IN      NUMBER,
  p_amount_P7                   IN      NUMBER,
  p_amount_P8                   IN      NUMBER,
  p_amount_P9                   IN      NUMBER,
  p_amount_P10                  IN      NUMBER,
  p_amount_P11                  IN      NUMBER,
  p_amount_P12                  IN      NUMBER
 );


END PSB_WS_LINE_PERIOD_L_PVT;

 

/
