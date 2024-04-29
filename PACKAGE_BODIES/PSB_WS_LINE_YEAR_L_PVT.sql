--------------------------------------------------------
--  DDL for Package Body PSB_WS_LINE_YEAR_L_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_LINE_YEAR_L_PVT" AS
/* $Header: PSBWLYLB.pls 120.2 2005/07/13 11:35:22 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_WS_LINE_YEAR_L_PVT';




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
  p_row_locked                 OUT  NOCOPY      VARCHAR2,
  --
  p_service_package_id          IN      NUMBER,
  --
  p_column_count                IN      NUMBER,
  --
  p_wal_id_C1                   IN      NUMBER,
  p_balance_type_C1             IN      VARCHAR2,
  p_ytd_amount_C1               IN      NUMBER,
  p_wal_id_C2                   IN      NUMBER,
  p_balance_type_C2             IN      VARCHAR2,
  p_ytd_amount_C2               IN      NUMBER,
  p_wal_id_C3                   IN      NUMBER,
  p_balance_type_C3             IN      VARCHAR2,
  p_ytd_amount_C3               IN      NUMBER,
  p_wal_id_C4                   IN      NUMBER,
  p_balance_type_C4             IN      VARCHAR2,
  p_ytd_amount_C4               IN      NUMBER,
  p_wal_id_C5                   IN      NUMBER,
  p_balance_type_C5             IN      VARCHAR2,
  p_ytd_amount_C5               IN      NUMBER,
  p_wal_id_C6                   IN      NUMBER,
  p_balance_type_C6             IN      VARCHAR2,
  p_ytd_amount_C6               IN      NUMBER,
  p_wal_id_C7                   IN      NUMBER,
  p_balance_type_C7             IN      VARCHAR2,
  p_ytd_amount_C7               IN      NUMBER,
  p_wal_id_C8                   IN      NUMBER,
  p_balance_type_C8             IN      VARCHAR2,
  p_ytd_amount_C8               IN      NUMBER,
  p_wal_id_C9                   IN      NUMBER,
  p_balance_type_C9             IN      VARCHAR2,
  p_ytd_amount_C9               IN      NUMBER,
  p_wal_id_C10                  IN      NUMBER,
  p_balance_type_C10            IN      VARCHAR2,
  p_ytd_amount_C10              IN      NUMBER,
  p_wal_id_C11                  IN      NUMBER,
  p_balance_type_C11            IN      VARCHAR2,
  p_ytd_amount_C11              IN      NUMBER,
  p_wal_id_C12                  IN      NUMBER,
  p_balance_type_C12            IN      VARCHAR2,
  p_ytd_amount_C12              IN      NUMBER

 )
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_wal_id              NUMBER;
  l_year_type           VARCHAR2(2);
  l_balance_type        VARCHAR2(1);
  l_ytd_amount              NUMBER;

  Counter NUMBER;
  CURSOR C IS
       SELECT ytd_amount,account_line_id
       FROM   psb_ws_account_lines
       WHERE  account_line_id = l_wal_id
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
  p_row_locked  := FND_API.G_TRUE;
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  FOR i in 1..p_column_count LOOP
    IF i = 1 THEN
      l_wal_id         :=   p_wal_id_C1;
      l_balance_type   :=   p_balance_type_C1;
      l_ytd_amount     :=   p_ytd_amount_C1;
    ELSIF i =2 THEN
      l_wal_id         :=   p_wal_id_C2;
      l_balance_type   :=   p_balance_type_C2;
      l_ytd_amount     :=   p_ytd_amount_C2;
    ELSIF i =3 THEN
      l_wal_id         :=   p_wal_id_C3;
      l_balance_type   :=   p_balance_type_C3;
      l_ytd_amount     :=   p_ytd_amount_C3;
    ELSIF i =4 THEN
      l_wal_id         :=   p_wal_id_C4;
      l_balance_type   :=   p_balance_type_C4;
      l_ytd_amount     :=   p_ytd_amount_C4;
    ELSIF i =5 THEN
      l_wal_id         :=   p_wal_id_C5;
      l_balance_type   :=   p_balance_type_C5;
      l_ytd_amount     :=   p_ytd_amount_C5;
    ELSIF i =6 THEN
      l_wal_id         :=   p_wal_id_C6;
      l_balance_type   :=   p_balance_type_C6;
      l_ytd_amount     :=   p_ytd_amount_C6;
    ELSIF i =7 THEN
      l_wal_id         :=   p_wal_id_C7;
      l_balance_type   :=   p_balance_type_C7;
      l_ytd_amount     :=   p_ytd_amount_C7;
    ELSIF i =8 THEN
      l_wal_id         :=   p_wal_id_C8;
      l_balance_type   :=   p_balance_type_C8;
      l_ytd_amount     :=   p_ytd_amount_C8;
    ELSIF i =9 THEN
      l_wal_id         :=   p_wal_id_C9;
      l_balance_type   :=   p_balance_type_C9;
      l_ytd_amount     :=   p_ytd_amount_C9;
    ELSIF i =10 THEN
      l_wal_id         :=   p_wal_id_C10;
      l_balance_type   :=   p_balance_type_C10;
      l_ytd_amount     :=   p_ytd_amount_C10;
    ELSIF i =11 THEN
      l_wal_id         :=   p_wal_id_C11;
      l_balance_type   :=   p_balance_type_C11;
      l_ytd_amount     :=   p_ytd_amount_C11;
    ELSIF i =12 THEN
      l_wal_id         :=   p_wal_id_C12;
      l_balance_type   :=   p_balance_type_C12;
      l_ytd_amount     :=   p_ytd_amount_C12;
    END IF;


   -- amount types can be B-Budget, A-Actuals, E- Estimate, F -FTE
   -- Lock rows only for estimates
   IF  l_balance_type = 'E' and nvl(l_wal_id,0) <> 0   THEN

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
     --Check for Amount change removed for performance reasons


    END IF;

  END LOOP;
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


END PSB_WS_LINE_YEAR_L_PVT;

/
