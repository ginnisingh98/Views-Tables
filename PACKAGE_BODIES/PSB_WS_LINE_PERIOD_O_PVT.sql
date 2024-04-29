--------------------------------------------------------
--  DDL for Package Body PSB_WS_LINE_PERIOD_O_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_LINE_PERIOD_O_PVT" AS
/* $Header: PSBWLPOB.pls 115.5 2003/12/18 11:01:49 vbellur ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_WS_LINE_PERIOD_O_PVT';



/*==========================================================================+
 |                       PROCEDURE Update_Row                               |
 +==========================================================================*/

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
  p_service_package_id          IN      NUMBER,
  p_year_id                     IN      NUMBER,
  p_year_type                   IN      VARCHAR2,
  p_balance_type                IN      VARCHAR2,
  p_wal_id                      IN      NUMBER,
  --
  p_column_count                IN      NUMBER,
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
  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_period_amount       PSB_WS_ACCT1.g_prdamt_tbl_type;
  --
  l_return_status       VARCHAR2(1);
  l_distribute_flag     VARCHAR2(1);

  l_index               BINARY_INTEGER;
  --
BEGIN
  --
  --
  SAVEPOINT Update_Row_Pvt ;
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
  --

  -- Initialize the table
  FOR l_index in 1..PSB_WS_ACCT1.G_MAX_NUM_AMOUNTS LOOP
     l_period_amount(l_index) := NULL;
  END LOOP;


   l_period_amount(1)  :=   p_amount_P1;
   l_period_amount(2)  :=   p_amount_P2;
   l_period_amount(3)  :=   p_amount_P3;
   l_period_amount(4)  :=   p_amount_P4;
   l_period_amount(5)  :=   p_amount_P5;
   l_period_amount(6)  :=   p_amount_P6;
   l_period_amount(7)  :=   p_amount_P7;
   l_period_amount(8)  :=   p_amount_P8;
   l_period_amount(9)  :=   p_amount_P9;
   l_period_amount(10) :=   p_amount_P10;
   l_period_amount(11) :=   p_amount_P11;
   l_period_amount(12) :=   p_amount_P12;

   l_distribute_flag   := FND_API.G_TRUE;



 -- Added the following loop for Bug 3243919
   FOR l_index in 1..PSB_WS_ACCT1.G_MAX_NUM_AMOUNTS LOOP
      IF nvl(l_period_amount(l_index),0) <> 0 THEN
        l_distribute_flag := FND_API.G_FALSE;
      END IF;
   END LOOP;


   -- amount types can be B-Budget, A-Actuals, E- Estimate, F -FTE
   -- Update rows only for current and proposed years
   -- and only when amount type is not FTE
   IF p_balance_type = 'E'  THEN

      -- user enters a value for an year for which no row currently exists
      -- create row

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
	  -- Changed p_distribute_flag to l_distribute_flag for bug 3243919
	  p_distribute_flag             => l_distribute_flag,
	  p_worksheet_id                => p_worksheet_id,
	  p_account_line_id             => p_wal_id,
	  p_service_package_id          => p_service_package_id,
	  p_ytd_amount                  => p_ytd_amount,
	  --
	  p_period_amount               => l_period_amount
	  );

    END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;


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
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Update_Row_Pvt ;
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




END Update_Row;
/* ----------------------------------------------------------------------- */




/*==========================================================================+
 |                       PROCEDURE Delete_Row                               |
 +==========================================================================*/

PROCEDURE Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_wal_id                IN      NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --

  --
BEGIN
  --
  SAVEPOINT Delete_Row_Pvt ;
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
  --

  DELETE FROM PSB_WS_ACCOUNT_LINES
  WHERE account_line_id = p_wal_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND ;
  END IF;

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Delete_Row_Pvt ;
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
END Delete_Row;
/* ----------------------------------------------------------------------- */

END PSB_WS_LINE_PERIOD_O_PVT;

/
