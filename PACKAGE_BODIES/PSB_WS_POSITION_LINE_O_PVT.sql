--------------------------------------------------------
--  DDL for Package Body PSB_WS_POSITION_LINE_O_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_POSITION_LINE_O_PVT" as
 /* $Header: PSBVPLOB.pls 120.2 2005/07/13 11:28:43 shtripat ship $ */


  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_WS_POSITION_LINE_O_PVT';


procedure UPDATE_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_POSITION_LINE_ID          IN       NUMBER,
  P_POSITION_ID               IN       NUMBER,
  P_DESCRIPTION               IN       VARCHAR2,
  P_ATTRIBUTE1                in       VARCHAR2,
  P_ATTRIBUTE2                in       VARCHAR2,
  P_ATTRIBUTE3                in       VARCHAR2,
  P_ATTRIBUTE4                in       VARCHAR2,
  P_ATTRIBUTE5                in       VARCHAR2,
  P_ATTRIBUTE6                in       VARCHAR2,
  P_ATTRIBUTE7                in       VARCHAR2,
  P_ATTRIBUTE8                in       VARCHAR2,
  P_ATTRIBUTE9                in       VARCHAR2,
  P_ATTRIBUTE10               in       VARCHAR2,
  P_CONTEXT                   in       VARCHAR2
) is
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
BEGIN
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
  update PSB_WS_POSITION_LINES set
    DESCRIPTION = P_DESCRIPTION,
    ATTRIBUTE1  = P_ATTRIBUTE1,
    ATTRIBUTE2  = P_ATTRIBUTE2,
    ATTRIBUTE3  = P_ATTRIBUTE3,
    ATTRIBUTE4  = P_ATTRIBUTE4,
    ATTRIBUTE5  = P_ATTRIBUTE5,
    ATTRIBUTE6  = P_ATTRIBUTE6,
    ATTRIBUTE7  = P_ATTRIBUTE7,
    ATTRIBUTE8  = P_ATTRIBUTE8,
    ATTRIBUTE9  = P_ATTRIBUTE9,
    ATTRIBUTE10 = P_ATTRIBUTE10,
    CONTEXT     = P_CONTEXT
  where POSITION_LINE_ID = P_POSITION_LINE_ID
    and POSITION_ID = P_POSITION_ID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
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

end PSB_WS_POSITION_LINE_O_PVT;

/
