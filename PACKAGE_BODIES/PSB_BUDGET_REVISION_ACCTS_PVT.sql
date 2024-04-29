--------------------------------------------------------
--  DDL for Package Body PSB_BUDGET_REVISION_ACCTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_BUDGET_REVISION_ACCTS_PVT" AS
/* $Header: PSBBACCB.pls 115.7 2002/11/18 10:56:58 msuram ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_BUDGET_REVISION_ACCTS_PVT';


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
  p_budget_revision_id              IN      NUMBER   := FND_API.G_MISS_NUM,
  p_budget_revision_acct_line_id IN OUT  NOCOPY  NUMBER,
  p_code_combination_id             IN      NUMBER,
  p_budget_group_id                 IN      NUMBER,
  p_gl_period_name                  IN      VARCHAR2,
  p_gl_budget_version_id            IN      NUMBER := FND_API.G_MISS_NUM,
  p_currency_code                   IN      VARCHAR2,
  p_budget_balance                  IN      NUMBER,
  p_revision_type                   IN      VARCHAR2,
  p_revision_value_type             IN      VARCHAR2,
  p_revision_amount                 IN      NUMBER,
  p_funds_status_code               IN      VARCHAR2,
  p_funds_result_code               IN      VARCHAR2,
  p_funds_control_timestamp         IN      DATE,
  p_note_id                         IN      NUMBER,
  p_freeze_flag                     IN      VARCHAR2,
  p_view_line_flag                  IN      VARCHAR2)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_return_status VARCHAR2(1);
  --
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

    PSB_BUDGET_REVISIONS_PVT.Create_Revision_Accounts
     ( p_api_version                     => 1.0,
       p_init_msg_list                   => FND_API.G_FALSE,
       p_commit                          => FND_API.G_FALSE,
       p_validation_level                => FND_API.G_VALID_LEVEL_FULL,
       p_return_status                   => p_return_status,
       p_msg_count                       => p_msg_count,
       p_msg_data                        => p_msg_data,
       p_budget_revision_id              => p_budget_revision_id,
       p_budget_revision_acct_line_id    => p_budget_revision_acct_line_id,
       p_code_combination_id             => p_code_combination_id,
       p_budget_group_id                 => p_budget_group_id,
       p_gl_period_name                  => p_gl_period_name,
       p_gl_budget_version_id            => p_gl_budget_version_id,
       p_currency_code                   => p_currency_code,
       p_budget_balance                  => p_budget_balance,
       p_revision_type                   => p_revision_type,
       p_revision_value_type             => p_revision_value_type,
       p_revision_amount                 => p_revision_amount,
       p_note_id                         => p_note_id,
       p_funds_control_timestamp         => p_funds_control_timestamp,
       p_funds_status_code               => p_funds_status_code,
       p_funds_result_code               => p_funds_result_code,
       p_freeze_flag                     => p_freeze_flag,
       p_view_line_flag                  => p_view_line_flag);



      --
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     fnd_message.set_name('PSB', 'BR_CREATE_ACCT_FAILED_EXC');
     RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     fnd_message.set_name('PSB', 'BR_CREATE_ACCT_FAILED_UNEXC');
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
  p_budget_revision_id              IN      NUMBER   := FND_API.G_MISS_NUM,
  p_budget_revision_acct_line_id IN OUT  NOCOPY  NUMBER,
  p_code_combination_id             IN      NUMBER,
  p_budget_group_id                 IN      NUMBER,
  p_gl_period_name                  IN      VARCHAR2,
  p_gl_budget_version_id            IN      NUMBER := FND_API.G_MISS_NUM,
  p_currency_code                   IN      VARCHAR2,
  p_budget_balance                  IN      NUMBER,
  p_revision_type                   IN      VARCHAR2,
  p_revision_value_type             IN      VARCHAR2,
  p_revision_amount                 IN      NUMBER,
  p_funds_status_code               IN      VARCHAR2,
  p_funds_result_code               IN      VARCHAR2,
  p_funds_control_timestamp         IN      DATE,
  p_note_id                         IN      NUMBER,
  p_freeze_flag                     IN      VARCHAR2,
  p_view_line_flag                  IN      VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_return_status       VARCHAR2(1);

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


  PSB_BUDGET_REVISIONS_PVT.Create_Revision_Accounts
     ( p_api_version                     => 1.0,
       p_init_msg_list                   => FND_API.G_FALSE,
       p_commit                          => FND_API.G_FALSE,
       p_validation_level                => FND_API.G_VALID_LEVEL_FULL,
       p_return_status                   => p_return_status,
       p_msg_count                       => p_msg_count,
       p_msg_data                        => p_msg_data,
       p_budget_revision_id              => p_budget_revision_id,
       p_budget_revision_acct_line_id => p_budget_revision_acct_line_id,
       p_code_combination_id             => p_code_combination_id,
       p_budget_group_id                 => p_budget_group_id,
       p_gl_period_name                  => p_gl_period_name,
       p_gl_budget_version_id            => p_gl_budget_version_id,
       p_currency_code                   => p_currency_code,
       p_budget_balance                  => p_budget_balance,
       p_revision_type                   => p_revision_type,
       p_revision_value_type             => p_revision_value_type,
       p_revision_amount                 => p_revision_amount,
       p_note_id                         => p_note_id,
       p_funds_control_timestamp         => p_funds_control_timestamp,
       p_funds_status_code               => p_funds_status_code,
       p_funds_result_code             => p_funds_result_code,
       p_freeze_flag                     => p_freeze_flag,
       p_view_line_flag                  => p_view_line_flag);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
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

END PSB_BUDGET_REVISION_ACCTS_PVT;

/
