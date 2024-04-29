--------------------------------------------------------
--  DDL for Package Body PSB_WS_LINE_PERIOD_L_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_LINE_PERIOD_L_PVT" AS
/* $Header: PSBWLPLB.pls 120.2 2005/07/13 11:35:00 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_WS_LINE_PERIOD_L_PVT';



/*==========================================================================+
 |                       PROCEDURE Lock_Row                                 |
 +==========================================================================*/

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
  p_row_locked                 OUT  NOCOPY      VARCHAR2,
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
 )
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  --

  Counter NUMBER;
  CURSOR C IS
       SELECT account_line_id
       FROM   psb_ws_account_lines
       WHERE  account_line_id  = p_wal_id
       FOR UPDATE of ytd_amount NOWAIT;
  Recinfo C%ROWTYPE;

BEGIN
  --
  SAVEPOINT Lock_Row_Pvt ;
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
  p_row_locked := FND_API.G_TRUE;
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
   -- amount types can be B-Budget, A-Actuals, E- Estimate, F -FTE
   -- Create new rows only for current and proposed years
   -- and only when amount type is not FTE
   IF  p_balance_type = 'E'  THEN

     OPEN C;
     --
     FETCH C INTO Recinfo;
     IF (C%NOTFOUND) then
       CLOSE C;
       FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR ;
     END IF;
     CLOSE C;

     -- Check for amount change removed for performance reasons

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

  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
    ROLLBACK TO Lock_Row_Pvt ;
    p_row_locked := FND_API.G_FALSE;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );


  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
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
END Lock_Row;
/* ----------------------------------------------------------------------- */

END PSB_WS_LINE_PERIOD_L_PVT;

/
