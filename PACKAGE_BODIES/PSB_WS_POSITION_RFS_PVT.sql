--------------------------------------------------------
--  DDL for Package Body PSB_WS_POSITION_RFS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_POSITION_RFS_PVT" AS
/* $Header: PSBWPRSB.pls 120.2.12010000.3 2009/04/27 14:36:56 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_WS_POSITION_RFS_PVT';

/*=======================================================================+
 |                       PROCEDURE Redistribute Follow Salary            |
 +=======================================================================*/

PROCEDURE Redistribute_Follow_Salary
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
  p_service_package_id          IN      NUMBER,
  p_stage_set_id                IN      NUMBER
) IS

  l_api_name            VARCHAR2(30)    := 'Redistribute_Follow_Salary';
  l_return_status       VARCHAR2(1)     := '';

 Begin

       PSB_WS_POS_PVT.Redistribute_Follow_Salary
	(
	p_api_version                 => 1.0,
	p_init_msg_list               => FND_API.G_FALSE,
	p_commit                      => FND_API.G_FALSE,
	p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
	p_return_status               => l_return_status,
	p_msg_count                   => p_msg_count,
	p_msg_data                    => p_msg_data,
	--
	p_worksheet_id                => p_worksheet_id,
	p_position_line_id            => p_position_line_id,
	p_service_package_id          => p_service_package_id,
	p_stage_set_id                => p_stage_set_id
	);
      --
      p_return_status := l_return_status;

      IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;

END Redistribute_Follow_Salary;
/*-------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE Delete_Pos_Service_Package                    |
 +===========================================================================*/
--
-- The API deletes a service package related information for a position. This
-- API is called from 'Modify Position Worksheet' Form Module.
--
PROCEDURE Delete_Pos_Service_Package
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_worksheet_id              IN       NUMBER   ,
  p_position_line_id          IN       NUMBER   , --bug:6650871
  p_service_package_id        IN       NUMBER
)
IS
  --
  l_api_name         CONSTANT VARCHAR2(30) := 'Delete_Pos_Service_Package';
  l_api_version      CONSTANT NUMBER       :=  1.0 ;
  --
  l_return_status    VARCHAR2(1) ;
  l_msg_count        NUMBER ;
  l_msg_data         VARCHAR2(2000) ;
  --
BEGIN
  --
  SAVEPOINT Delete_Pos_Service_Package_Pvt ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --
  IF FND_API.To_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  --
  -- Delete service package related position information.
  --

  DELETE psb_ws_fte_lines
  WHERE  service_package_id = p_service_package_id
  AND    position_line_id   = p_position_line_id; --bug:6650871

  DELETE psb_ws_element_lines
  WHERE  service_package_id = p_service_package_id
  AND    position_line_id   = p_position_line_id; --bug:6650871

  --
  -- Delete service package related account information.
  --

  DELETE psb_ws_lines
  WHERE  account_line_id IN
	 (
	   SELECT account_line_id
	   FROM   psb_ws_account_lines
	   WHERE  service_package_id = p_service_package_id
           AND    position_line_id   = p_position_line_id   --bug:6650871
	  ) ;

  DELETE psb_ws_account_lines
  WHERE  service_package_id = p_service_package_id
  AND    position_line_id   = p_position_line_id; --bug:6650871

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END IF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Delete_Pos_Service_Package_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Delete_Pos_Service_Package_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Delete_Pos_Service_Package_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name );
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
     --
END Delete_Pos_Service_Package ;
/*---------------------------------------------------------------------------*/


END PSB_WS_POSITION_RFS_PVT;

/
