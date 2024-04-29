--------------------------------------------------------
--  DDL for Package Body PSB_WS_LINE_PERIOD_I_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_LINE_PERIOD_I_PVT" AS
/* $Header: PSBWLPIB.pls 120.2 2005/07/13 11:34:49 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_WS_LINE_PERIOD_I_PVT';



/*=======================================================================+
 |                       PROCEDURE Insert_Row                            |
 +=======================================================================*/

PROCEDURE Insert_Row
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
  p_budget_group_id             IN      NUMBER,
  p_service_package_id          IN      NUMBER,
  p_flex_code                   IN      NUMBER,
  p_concatenated_segments       IN      VARCHAR2,
  p_currency_code               IN      VARCHAR2,
  p_column_count                IN      NUMBER,
  --
  p_year_id                     IN      NUMBER,
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
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_return_status VARCHAR2(1);
  --
  l_period_amount       PSB_WS_ACCT1.g_prdamt_tbl_type;
  l_index               BINARY_INTEGER;
  l_account_line_id     NUMBER;

  --

BEGIN
  --
  SAVEPOINT Insert_Row_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  --

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;



  -- Initialize the table
  FOR l_index in 1..PSB_WS_ACCT1.G_MAX_NUM_AMOUNTS LOOP
     l_period_amount(l_index) := NULL;
  END LOOP;

  --
  -- process only for displayed columns

    -- amount types can be B-Budget, A-Actuals, E- Estimate, F -FTE
    -- Create new rows only for current and proposed years
    -- and only when amount type is not FTE
    IF p_year_type IN ('PP','CY') and p_balance_type <> 'F'  THEN


      PSB_WS_ACCT_PVT.Create_Account_Dist
      (
	p_api_version                 => 1.0,
	p_init_msg_list               => FND_API.G_FALSE,
	p_commit                      => FND_API.G_FALSE,
	p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
	p_return_status               => l_return_status,
	p_msg_count                   => p_msg_count,
	p_msg_data                    => p_msg_data,
	--
	p_account_line_id             => l_account_line_id,
	--
	p_worksheet_id                => p_worksheet_id,
	p_map_accounts                => TRUE,
	p_budget_year_id              => p_year_id,
	p_budget_group_id             => p_budget_group_id,
	p_flex_code                   => p_flex_code,
	p_concatenated_segments       => p_concatenated_segments,
	p_currency_code               => p_currency_code,
	p_balance_type                => p_balance_type,
	p_ytd_amount                  => p_ytd_amount,
	p_distribute_flag             => FND_API.G_FALSE,
	p_period_amount               => l_period_amount,
	p_service_package_id          => p_service_package_id

      );
       --
       IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR ;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       END IF;
       --

     END IF;



  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Insert_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
     --
END Insert_Row;
/*-------------------------------------------------------------------------*/


END PSB_WS_LINE_PERIOD_I_PVT;

/
