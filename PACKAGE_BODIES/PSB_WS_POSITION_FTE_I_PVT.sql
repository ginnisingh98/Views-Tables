--------------------------------------------------------
--  DDL for Package Body PSB_WS_POSITION_FTE_I_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_POSITION_FTE_I_PVT" AS
/* $Header: PSBWFTIB.pls 120.2 2005/07/13 11:34:23 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_WS_POSITION_FTE_I_PVT';

/*=======================================================================+
 |                       PROCEDURE Insert_Row                            |
 +=======================================================================*/

PROCEDURE Insert_Row
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  --
  p_return_status              OUT  NOCOPY      VARCHAR2,
  p_msg_count                  OUT  NOCOPY      NUMBER,
  p_msg_data                   OUT  NOCOPY      VARCHAR2,
  p_fte_line_id                OUT  NOCOPY      NUMBER,
  --
  p_worksheet_id                IN      NUMBER,
  p_position_line_id            IN      NUMBER,
  p_budget_year_id              IN      NUMBER,
  p_service_package_id          IN      NUMBER,
  p_stage_set_id                IN      NUMBER,
  p_current_stage_seq           IN      NUMBER,
  p_period_1                    IN      NUMBER,
  p_period_2                    IN      NUMBER,
  p_period_3                    IN      NUMBER,
  p_period_4                    IN      NUMBER,
  p_period_5                    IN      NUMBER,
  p_period_6                    IN      NUMBER,
  p_period_7                    IN      NUMBER,
  p_period_8                    IN      NUMBER,
  p_period_9                    IN      NUMBER,
  p_period_10                   IN      NUMBER,
  p_period_11                   IN      NUMBER,
  p_period_12                   IN      NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_return_status       VARCHAR2(1);
  --
  l_init_index          BINARY_INTEGER;
  l_period_fte          PSB_WS_ACCT1.g_prdamt_tbl_type;


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
  for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
    l_period_fte(l_init_index) := null;
  end loop;


  l_period_fte(1) := p_period_1;
  l_period_fte(2) := p_period_2;
  l_period_fte(3) := p_period_3;
  l_period_fte(4) := p_period_4;
  l_period_fte(5) := p_period_5;
  l_period_fte(6) := p_period_6;
  l_period_fte(7) := p_period_7;
  l_period_fte(8) := p_period_8;
  l_period_fte(9) := p_period_9;
  l_period_fte(10) := p_period_10;
  l_period_fte(11) := p_period_11;
  l_period_fte(12) := p_period_12;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  --

       PSB_WS_POS_PVT.Create_FTE_Lines
	(
	p_api_version                 => 1.0,
	p_init_msg_list               => FND_API.G_FALSE,
	p_commit                      => FND_API.G_FALSE,
	p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
	--
	p_return_status               => l_return_status,
	p_msg_count                   => p_msg_count,
	p_msg_data                    => p_msg_data,
	p_fte_line_id                 => p_fte_line_id,
	p_recalculate_flag            => FND_API.G_TRUE,
	--
	p_worksheet_id                => p_worksheet_id,
	p_position_line_id            => p_position_line_id,
	p_budget_year_id              => p_budget_year_id,
	p_service_package_id          => p_service_package_id,
	p_stage_set_id                => p_stage_set_id,
	p_current_stage_seq           => p_current_stage_seq,
	p_period_fte                  => l_period_fte
	);
      --
      IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
	fnd_message.set_name('PSB', 'WS_CREATE_FTE_FAILED_EXC');
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	fnd_message.set_name('PSB', 'WS_CREATE_FTE_FAILED_UNEXC');
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
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
END PSB_WS_POSITION_FTE_I_PVT;

/
