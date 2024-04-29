--------------------------------------------------------
--  DDL for Package Body PSB_WS_POS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_POS_PVT" AS
/* $Header: PSBPWCPB.pls 120.8.12010000.5 2010/02/22 11:48:45 rkotha ship $ */

  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'PSB_WS_POS_PVT';

/* ----------------------------------------------------------------------- */

FUNCTION Check_Allowed
( p_api_version               IN   NUMBER,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER,
  p_position_budget_group_id  IN   NUMBER
) RETURN VARCHAR2 IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Check_Allowed';
  l_api_version               CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  RETURN PSB_WS_POS1.Check_Allowed
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_worksheet_id => p_worksheet_id,
      p_position_budget_group_id => p_position_budget_group_id);


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     return FND_API.G_FALSE;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     return FND_API.G_FALSE;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     return FND_API.G_FALSE;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Check_Allowed;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Position_Lines
( p_api_version               IN   NUMBER,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_position_line_id          OUT  NOCOPY  NUMBER,
  p_worksheet_id              IN   NUMBER,
  p_position_id               IN   NUMBER,
  p_budget_group_id           IN   NUMBER,
  p_copy_of_position_line_id  IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Create_Position_Lines';
  l_api_version               CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Create_Position_Lines_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WS_POS1.Create_Position_Lines
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_position_line_id => p_position_line_id,
      p_worksheet_id => p_worksheet_id,
      p_position_id => p_position_id,
      p_budget_group_id => p_budget_group_id,
      p_copy_of_position_line_id => p_copy_of_position_line_id);


  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_Position_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_Position_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Create_Position_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Create_Position_Lines;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Position_Matrix
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_position_line_id  IN   NUMBER,
  p_freeze_flag       IN   VARCHAR2 := FND_API.G_FALSE,
  p_view_line_flag    IN   VARCHAR2 := FND_API.G_TRUE
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Create_Position_Matrix';
  l_api_version       CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Create_Position_Matrix_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WS_POS1.Create_Position_Matrix
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id,
      p_position_line_id => p_position_line_id,
      p_freeze_flag => p_freeze_flag,
      p_view_line_flag => p_view_line_flag);


  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_Position_Matrix_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_Position_Matrix_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Create_Position_Matrix_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Create_Position_Matrix;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_FTE_Lines
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_fte_line_id         OUT  NOCOPY  NUMBER,
  p_check_spfl_exists   IN   VARCHAR2 := FND_API.G_TRUE,
  p_recalculate_flag    IN   VARCHAR2 := FND_API.G_FALSE,
  p_worksheet_id        IN   NUMBER,
  p_flex_mapping_set_id IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_annual_fte          IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_start_stage_seq     IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER,
  p_end_stage_seq       IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_fte          IN   PSB_WS_ACCT1.g_prdamt_tbl_type
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_FTE_Lines';
  l_api_version         CONSTANT NUMBER         := 1.0;

  /*bug:5635570:start*/
  l_base_sp_flag        BOOLEAN := FALSE;
  l_lparam_flag         VARCHAR2(1) := FND_API.G_FALSE;
  l_fte_line_id         NUMBER;
  l_return_status   VARCHAR2(1);

  CURSOR c_Wfl IS
    SELECT pwfl.position_line_id,
	   pwfl.budget_year_id,
	   pwfl.service_package_id,
	   pwfl.stage_set_id,
	   pwfl.start_stage_seq,
	   pwfl.current_stage_seq,
	   pwfl.end_stage_seq,
	   psp.base_service_package
      FROM PSB_WS_FTE_LINES pwfl,
           psb_service_packages psp
     WHERE pwfl.fte_line_id = p_fte_line_id
       AND pwfl.service_package_id = psp.service_package_id
       AND psp.global_worksheet_id = p_worksheet_id;
  /*bug:5635570:end*/

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Create_FTE_Lines_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WS_POS1.Create_FTE_Lines
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_fte_line_id => p_fte_line_id,
      p_check_spfl_exists => p_check_spfl_exists,
      p_recalculate_flag => p_recalculate_flag,
      p_worksheet_id => p_worksheet_id,
      p_flex_mapping_set_id => p_flex_mapping_set_id,
      p_position_line_id => p_position_line_id,
      p_budget_year_id => p_budget_year_id,
      p_budget_group_id => p_budget_group_id,
      p_annual_fte => p_annual_fte,
      p_service_package_id => p_service_package_id,
      p_stage_set_id => p_stage_set_id,
      p_start_stage_seq => p_start_stage_seq,
      p_current_stage_seq => p_current_stage_seq,
      p_end_stage_seq => p_end_stage_seq,
      p_period_fte => p_period_fte);

/*bug:5635570:start*/

  for l_fte_rec IN c_wfl loop
      IF l_fte_rec.base_service_package = 'Y' THEN
        l_base_sp_flag := TRUE;
      END IF;
  end loop;

   IF l_base_sp_flag THEN
     l_lparam_flag := FND_API.G_FALSE;
   ELSE
     l_lparam_flag := FND_API.G_TRUE;
   END IF;
  /*bug:5635570:end*/

    PSB_WS_POS2.Calculate_Position_Cost
         (p_api_version => 1.0,
          p_return_status => l_return_status,
          p_worksheet_id => p_worksheet_id,
          p_position_line_id => p_position_line_id,
          p_budget_year_id => p_budget_year_id,
       /*Start bug:5635570*/
            p_lparam_flag => l_lparam_flag
       /*End bug:5635570*/
          );
 /*bug:5635570:end*/


  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_FTE_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_FTE_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Create_FTE_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Create_FTE_Lines;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_FTE_Lines
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER  := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_check_stages        IN   VARCHAR2 := FND_API.G_TRUE,
  p_worksheet_id        IN   NUMBER,
  p_fte_line_id         IN   NUMBER,
  p_service_package_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_fte          IN   PSB_WS_ACCT1.g_prdamt_tbl_type,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_FTE_Lines';
  l_api_version         CONSTANT NUMBER         := 1.0;

  /* Bug 4379636 Start */
  l_position_line_id    NUMBER;
  l_budget_year_id      NUMBER;
  l_service_package_id  NUMBER;
  l_stage_set_id        NUMBER;
  l_start_stage_seq     NUMBER;
  l_current_stage_seq   NUMBER;
  l_end_stage_seq       NUMBER;
  /*bug:5635570:start*/
  l_base_sp_flag        BOOLEAN := FALSE;
  l_lparam_flag         VARCHAR2(1) := FND_API.G_FALSE;
  /*bug:5635570:end*/

  CURSOR c_Wfl IS
    SELECT position_line_id,
	   budget_year_id,
	   service_package_id,
	   stage_set_id,
	   start_stage_seq,
	   current_stage_seq,
	   end_stage_seq
      FROM PSB_WS_FTE_LINES
     WHERE fte_line_id = p_fte_line_id;

  CURSOR l_annual_fte_csr IS
    SELECT annual_fte,
           psp.base_service_package --bug:5635570
      FROM PSB_WS_ACCOUNT_LINES pwal,
           PSB_SERVICE_PACKAGES psp --bug:5635570
     WHERE l_current_stage_seq BETWEEN start_stage_seq AND current_stage_seq
       AND pwal.stage_set_id       = l_stage_set_id
       AND pwal.service_package_id = l_service_package_id
       AND pwal.budget_year_id     = l_budget_year_id
       AND pwal.position_line_id   = l_position_line_id
       /*bug:5635570:start*/
       AND psp.global_worksheet_id = p_worksheet_id
       AND psp.service_package_id  = pwal.service_package_id;
       /*bug:5635570:end*/


  l_zero_fte_exists BOOLEAN := FALSE;
  l_return_status   VARCHAR2(1);

  /* Bug 4379636 End */

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Create_FTE_Lines_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  /* Bug 4379636 Start */
  FOR c_Wfl_Rec IN c_Wfl LOOP
    l_position_line_id   := c_Wfl_Rec.position_line_id;
    l_budget_year_id     := c_Wfl_Rec.budget_year_id;
    l_service_package_id := c_Wfl_Rec.service_package_id;
    l_stage_set_id       := c_Wfl_Rec.stage_set_id;
    l_start_stage_seq    := c_Wfl_Rec.start_stage_seq;
    l_current_stage_seq  := c_Wfl_Rec.current_stage_seq;
    l_end_stage_seq      := c_Wfl_Rec.end_stage_seq;
  END LOOP;

  FOR l_annual_fte_csr_rec IN l_annual_fte_csr
  LOOP

    IF nvl(l_annual_fte_csr_rec.annual_fte,0) = 0 THEN
      l_zero_fte_exists := TRUE;
      /*bug:5635570:start*/
      IF l_annual_fte_csr_rec.base_service_package = 'Y' THEN
        l_base_sp_flag := TRUE;
      END IF;
      /*bug:5635570:end*/
      EXIT;
    END IF;

  END LOOP;

  -- Call Private Function

  PSB_WS_POS1.Create_FTE_Lines
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_check_stages => p_check_stages,
      p_worksheet_id => p_worksheet_id,
      p_fte_line_id => p_fte_line_id,
      p_service_package_id => p_service_package_id,
      p_current_stage_seq => p_current_stage_seq,
      p_period_fte => p_period_fte,
      p_budget_group_id => p_budget_group_id);

  /*bug:5635570:start*/
   IF l_base_sp_flag THEN
     l_lparam_flag := FND_API.G_FALSE;
   ELSE
     l_lparam_flag := FND_API.G_TRUE;
   END IF;
  /*bug:5635570:end*/

    PSB_WS_POS2.Calculate_Position_Cost
         (p_api_version => 1.0,
          p_return_status => l_return_status,
          p_worksheet_id => p_worksheet_id,
          p_position_line_id => l_position_line_id,
          p_budget_year_id => l_budget_year_id,
       /*Start bug:5635570*/
            p_lparam_flag => FND_API.G_TRUE
       /*End bug:5635570*/
          );

  /* Bug 4379636 End */

  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_FTE_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_FTE_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Create_FTE_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Create_FTE_Lines;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Element_Lines
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER  := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_element_line_id     OUT  NOCOPY  NUMBER,
  p_check_spel_exists   IN   VARCHAR2 := FND_API.G_TRUE,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER,
  p_pay_element_id      IN   NUMBER,
  p_currency_code       IN   VARCHAR2,
  p_element_cost        IN   NUMBER,
  p_element_set_id      IN   NUMBER,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_start_stage_seq     IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER,
  p_end_stage_seq       IN   NUMBER := FND_API.G_MISS_NUM)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_Element_Lines';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Create_Element_Lines_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WS_POS1.Create_Element_Lines
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_element_line_id => p_element_line_id,
      p_check_spel_exists => p_check_spel_exists,
      p_position_line_id => p_position_line_id,
      p_budget_year_id => p_budget_year_id,
      p_pay_element_id => p_pay_element_id,
      p_currency_code => p_currency_code,
      p_element_cost => p_element_cost,
      p_element_set_id => p_element_set_id,
      p_service_package_id => p_service_package_id,
      p_stage_set_id => p_stage_set_id,
      p_start_stage_seq => p_start_stage_seq,
      p_current_stage_seq => p_current_stage_seq,
      p_end_stage_seq => p_end_stage_seq);

  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_Element_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_Element_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Create_Element_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Create_Element_Lines;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Element_Lines
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER  := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_check_stages        IN   VARCHAR2 := FND_API.G_TRUE,
  p_element_line_id     IN   NUMBER,
  p_service_package_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER := FND_API.G_MISS_NUM,
  p_element_cost        IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_Element_Lines';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Create_Element_Lines_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WS_POS1.Create_Element_Lines
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_check_stages => p_check_stages,
      p_element_line_id => p_element_line_id,
      p_service_package_id => p_service_package_id,
      p_current_stage_seq => p_current_stage_seq,
      p_element_cost => p_element_cost);


  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_Element_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_Element_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Create_Element_Lines_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Create_Element_Lines;

/* ----------------------------------------------------------------------- */

PROCEDURE Update_Annual_FTE
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER  := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_current_stage_seq   IN   NUMBER,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Annual_FTE';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Update_Annual_FTE_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WS_POS1.Update_Annual_FTE
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id,
      p_position_line_id => p_position_line_id,
      p_budget_year_id => p_budget_year_id,
      p_service_package_id => p_service_package_id,
      p_stage_set_id => p_stage_set_id,
      p_current_stage_seq => p_current_stage_seq,
      p_budget_group_id => p_budget_group_id);


  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Update_Annual_FTE_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Update_Annual_FTE_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Update_Annual_FTE_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Update_Annual_FTE;

/* ----------------------------------------------------------------------- */

PROCEDURE Redistribute_Follow_Salary
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_func_currency       IN   VARCHAR2 := FND_API.G_MISS_CHAR
) IS

  l_api_name             CONSTANT VARCHAR2(30)  := 'Redistribute_Follow_Salary';
  l_api_version          CONSTANT NUMBER        := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Redistribute_Follow_Salary_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WS_POS3.Redistribute_Follow_Salary
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id,
      p_position_line_id => p_position_line_id,
      p_budget_year_id => p_budget_year_id,
      p_service_package_id => p_service_package_id,
      p_stage_set_id => p_stage_set_id,
      p_func_currency => p_func_currency);


  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Redistribute_Follow_Salary_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Redistribute_Follow_Salary_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Redistribute_Follow_Salary_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Redistribute_Follow_Salary;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Element_Parameters
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_global_worksheet    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_business_group_id   IN   NUMBER := FND_API.G_MISS_NUM,
  p_func_currency       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_calendar_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_parameter_set_id    IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name            CONSTANT VARCHAR2(30) := 'Apply_Element_Parameters';
  l_api_version         CONSTANT NUMBER          := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Apply_Element_Parameters_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WS_POS3.Apply_Element_Parameters
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id,
      p_global_worksheet => p_global_worksheet,
      p_budget_group_id => p_budget_group_id,
      p_data_extract_id => p_data_extract_id,
      p_business_group_id => p_business_group_id,
      p_func_currency => p_func_currency,
      p_budget_calendar_id => p_budget_calendar_id,
      p_parameter_set_id => p_parameter_set_id);


  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Apply_Element_Parameters_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Apply_Element_Parameters_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Apply_Element_Parameters_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Apply_Element_Parameters;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Position_Parameters
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER  :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_global_worksheet    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_business_group_id   IN   NUMBER := FND_API.G_MISS_NUM,
  p_func_currency       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_calendar_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_parameter_set_id    IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Apply_Position_Parameters';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Apply_Position_Parameters_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WS_POS3.Apply_Position_Parameters
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id,
      p_global_worksheet => p_global_worksheet,
      p_budget_group_id => p_budget_group_id,
      p_data_extract_id => p_data_extract_id,
      p_business_group_id => p_business_group_id,
      p_func_currency => p_func_currency,
      p_budget_calendar_id => p_budget_calendar_id,
      p_parameter_set_id => p_parameter_set_id);


  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Apply_Position_Parameters_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Apply_Position_Parameters_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Apply_Position_Parameters_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Apply_Position_Parameters;

/* ----------------------------------------------------------------------- */

PROCEDURE Calculate_Position_Cost
( p_api_version           IN   NUMBER,
  p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status         OUT  NOCOPY  VARCHAR2,
  p_msg_count             OUT  NOCOPY  NUMBER,
  p_msg_data              OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_position_line_id      IN   NUMBER,
  p_recalculate_flag      IN   VARCHAR2 := FND_API.G_TRUE,
  p_root_budget_group_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_global_worksheet_id   IN   NUMBER := FND_API.G_MISS_NUM,
  p_assign_worksheet_id   IN   NUMBER := FND_API.G_MISS_NUM,
  p_worksheet_numyrs      IN   NUMBER := FND_API.G_MISS_NUM,
  p_rounding_factor       IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id    IN   NUMBER := FND_API.G_MISS_NUM,
  p_stage_set_id          IN   NUMBER := FND_API.G_MISS_NUM,
  p_start_stage_seq       IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq     IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_business_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id    IN   NUMBER := FND_API.G_MISS_NUM,
  p_func_currency         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_flex_mapping_set_id   IN   NUMBER := FND_API.G_MISS_NUM,
  p_flex_code             IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_id           IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_name         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_position_start_date   IN   DATE := FND_API.G_MISS_DATE,
  p_position_end_date     IN   DATE := FND_API.G_MISS_DATE
) IS

  l_api_name              CONSTANT VARCHAR2(30) := 'Calculate_Position_Cost';
  l_api_version           CONSTANT NUMBER       := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Calculate_Position_Cost_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WS_POS2.Calculate_Position_Cost
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id,
      p_position_line_id => p_position_line_id,
      p_recalculate_flag => p_recalculate_flag,
      p_root_budget_group_id => p_root_budget_group_id,
      p_global_worksheet_id => p_global_worksheet_id,
      p_assign_worksheet_id => p_assign_worksheet_id,
      p_worksheet_numyrs => p_worksheet_numyrs,
      p_rounding_factor => p_rounding_factor,
      p_service_package_id => p_service_package_id,
      p_stage_set_id => p_stage_set_id,
      p_start_stage_seq => p_start_stage_seq,
      p_current_stage_seq => p_current_stage_seq,
      p_data_extract_id => p_data_extract_id,
      p_business_group_id => p_business_group_id,
      p_budget_calendar_id => p_budget_calendar_id,
      p_func_currency => p_func_currency,
      p_flex_mapping_set_id => p_flex_mapping_set_id,
      p_flex_code => p_flex_code,
      p_position_id => p_position_id,
      p_position_name => p_position_name,
      p_position_start_date => p_position_start_date,
      p_position_end_date => p_position_end_date);


  /* Start bug #4167811 */
  -- Delete records from psb_ws_account_lines whose budget group is changed.
  -- Also delete the mappings for those account lines from psb_ws_lines.
  FOR rec_wal IN (SELECT count(*) record_count
                   FROM psb_ws_account_lines
                  WHERE position_line_id = p_position_line_id
                    AND budget_group_changed = 'Y')
  LOOP
    IF rec_wal.record_count > 0
    THEN
      DELETE FROM psb_ws_lines
       WHERE account_line_id IN (SELECT account_line_id
                                   FROM psb_ws_account_lines
                                  WHERE position_line_id = p_position_line_id
                                    AND budget_group_changed = 'Y');

      DELETE FROM psb_ws_account_lines
       WHERE position_line_id = p_position_line_id
         AND budget_group_changed = 'Y';

    END IF;
  END LOOP;
  /* End bug #4167811 */

  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Calculate_Position_Cost_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Calculate_Position_Cost_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Calculate_Position_Cost_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Calculate_Position_Cost;

/* ----------------------------------------------------------------------- */

PROCEDURE Revise_Position_Projections
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
--Bug:5753424:p_parameter_id receives parameter_set_id instead of parameter_id.
  p_parameter_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)     := 'Revise_Position_Projections';
  l_api_version       CONSTANT NUMBER           := 1.0;

  l_return_status     VARCHAR2(1);
  l_msg_data          VARCHAR2(2000);
  l_msg_count         NUMBER;
  l_validation_status VARCHAR2(1);

/*Bug:5753424: Start */
  CURSOR c_parameters IS
  SELECT pes.entity_set_id parameter_set_id
        ,pes.name          parameter_set_name
        ,pe.entity_id parameter_id
        ,pe.name      parameter_name
        ,pe.entity_subtype parameter_type
        ,pea.priority
  FROM   psb_entity_set pes
        ,psb_entity pe
        ,psb_entity_assignment pea
  WHERE  pes.entity_set_id = p_parameter_id
  AND    pes.entity_type = 'PARAMETER'
  AND    pe.entity_type='PARAMETER'
  AND    pe.entity_subtype='POSITION'
  AND    pea.entity_id = pe.entity_id
  AND    pea.entity_set_id = pes.entity_set_id
  ORDER  BY pea.priority asc;

/*end bug:5753424*/

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Revise_Pos_Projections_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

       /*start bug:5753424: Procedure level logging*/
      if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Position_Projections',
        'BEGIN Revise_Position_Projections');
        fnd_file.put_line(fnd_file.LOG,'BEGIN Revise_Position_Projections');
       end if;
       /*end bug:5753424:end procedure level log*/


  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Enforce Concurrency Control

  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_concurrency_class => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Call Private Function

/*Bug:5753424 start: Revise_Position_Projections api is called for
  all the position parameters in the parameter set. */

 FOR c_parameter_rec IN c_parameters LOOP
 --end bug:5753424

       /*start bug:5753424: statement level logging*/
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Position_Projections',
        'Before call to PSB_WS_POS3.Revise_Position_Projections with parameter id as:'||c_parameter_rec.parameter_id);
        fnd_file.put_line(fnd_file.LOG,'Before call to PSB_WS_POS3.Revise_Position_Projections with parameter id as:'||c_parameter_rec.parameter_id);
       end if;
       /*end bug:5753424:end statement level log*/

  PSB_WS_POS3.Revise_Position_Projections
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => l_return_status,
      x_msg_data      => l_msg_data,
      x_msg_count     => l_msg_count,
      p_worksheet_id  => p_worksheet_id,
--bug:5753424: modified the values passed for p_parameter_id.
      p_parameter_id  => c_parameter_rec.parameter_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

       /*start bug:5753424: statement level logging*/
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Position_Projections',
        'Inside Exception due to call - PSB_WS_POS3.Revise_Position_Projections for parameter_id:'||c_parameter_rec.parameter_id);
        fnd_file.put_line(fnd_file.LOG,'Inside Exception due to call - PSB_WS_POS3.Revise_Position_Projections for parameter_id:'||c_parameter_rec.parameter_id);
       end if;
       /*end bug:5753424:end statement level log*/

  --bug:5753424:start

    FND_MESSAGE.SET_NAME('PSB','PSB_LPS_FAILURE_MSG');
    FND_MESSAGE.SET_TOKEN('LOCAL_PARAM_SET',c_parameter_rec.parameter_set_name);
    FND_MESSAGE.SET_TOKEN('LOCAL_PARAM',    c_parameter_rec.parameter_name);
    FND_MESSAGE.SET_TOKEN('ERROR_TRAPPED',  l_msg_data);
    FND_MSG_PUB.ADD;

  --bug:5753424:end

    raise FND_API.G_EXC_ERROR;
  end if;

--start bug:5753424
  END LOOP;
--end bug:5753424

  PSB_WS_ACCT2.Create_Rollup_Totals
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_WORKSHEET.Apply_Constraints
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_validation_status => l_validation_status,
      p_worksheet_id => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_concurrency_class => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   end if;


  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);

       /*start bug:5753424: Procedure level logging*/
      if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Position_Projections',
        'END Revise_Position_Projections');
        fnd_file.put_line(fnd_file.LOG,'END Revise_Position_Projections');
       end if;
       /*end bug:5753424:end procedure level log*/

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Revise_Position_Projections;

/*===========================================================================+
 |                   PROCEDURE Apply_Element_Parameters_CP                   |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Apply
-- Element Parameters'
--
PROCEDURE Apply_Element_Parameters_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_worksheet_id              IN       NUMBER
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Apply_Element_Parameters_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;

BEGIN

  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version             => 1.0,
      p_return_status           => l_return_status,
      p_concurrency_class       => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id   =>  p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_WS_POS_PVT.Apply_Element_Parameters
     (p_api_version             => 1.0,
      p_init_msg_list           => FND_API.G_TRUE,
      p_return_status           => l_return_status,
      p_msg_count               => l_msg_count,
      p_msg_data                => l_msg_data,
      p_worksheet_id            => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  --Calling Release_Concurrency_Control

  PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version             => 1.0,
      p_return_status           => l_return_status,
      p_concurrency_class       => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id   =>  p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

  COMMIT WORK;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    --

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
    (p_api_version => 1.0,
     p_return_status => l_return_status,
     p_concurrency_class => 'WORKSHEET_CREATION',
     p_concurrency_entity_name => 'WORKSHEET',
     p_concurrency_entity_id => p_worksheet_id);


    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
    (p_api_version => 1.0,
     p_return_status => l_return_status,
     p_concurrency_class => 'WORKSHEET_CREATION',
     p_concurrency_entity_name => 'WORKSHEET',
     p_concurrency_entity_id => p_worksheet_id);

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;
  --
  WHEN OTHERS THEN

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
    (p_api_version => 1.0,
     p_return_status => l_return_status,
     p_concurrency_class => 'WORKSHEET_CREATION',
     p_concurrency_entity_name => 'WORKSHEET',
     p_concurrency_entity_id => p_worksheet_id);

    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    --
    retcode := 2 ;
    COMMIT WORK ;
    --
END Apply_Element_Parameters_CP;

/*===========================================================================+
 |                   PROCEDURE Validate_Positions_CP                         |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Validate
-- Positions'
--
PROCEDURE Validate_Positions_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_worksheet_id              IN       NUMBER
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Validate_Positions_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  l_validation_status       VARCHAR2(1);
  l_rep_req_id              NUMBER;
  l_reqid                   NUMBER;

BEGIN

  PSB_POSITIONS_PVT.Position_WS_Validation
    (p_api_version          => 1.0,
     p_return_status        => l_return_status,
     p_msg_count            => l_msg_count,
     p_msg_data             => l_msg_data,
     p_worksheet_id         => p_worksheet_id,
     p_validation_status    => l_validation_status
    );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  if l_validation_status <> FND_API.G_RET_STS_SUCCESS THEN
    -- submit concurrent request for error report
    -- waiting for correction to error messages report
    --
    l_reqid  := FND_GLOBAL.CONC_REQUEST_ID;

    l_rep_req_id := Fnd_Request.Submit_Request
		       (application   => 'PSB'                          ,
			program       => 'PSBRPERR'                     ,
			description   => 'Position Worksheet Exception Report',
			start_time    =>  NULL                          ,
			sub_request   =>  FALSE                         ,
			argument1     =>  'POSITION_WORKSHEET_EXCEPTION',
			argument2     =>  p_worksheet_id,
			argument3     =>  l_reqid
		      );
    --
    if l_rep_req_id = 0 then
    --
    fnd_message.set_name('PSB', 'PSB_FAIL_TO_SUBMIT_REQUEST');
    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
    --
    end if;

    fnd_message.set_name('PSB', 'PSB_POSITION_WS_EXCEPTION');
    FND_MSG_PUB.Add;

    raise FND_API.G_EXC_ERROR;

  end if;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

  COMMIT WORK;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;
  --
  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    --
    retcode := 2 ;
    COMMIT WORK ;
    --
END Validate_Positions_CP;

/* ---------------------------------------------------------------------------------- */
--
-- This is the execution file for the concurrent program 'Revise_Position_Projections_CP'
--
PROCEDURE Revise_Position_Projections_CP
(
  errbuf          OUT  NOCOPY  VARCHAR2,
  retcode         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id  IN   NUMBER,
  p_parameter_id  IN   NUMBER
) IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Revise_Position_Projections_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_msg_index_out           NUMBER;
  --
  l_set_cp_status           BOOLEAN        := FALSE ;  -- Bug#4675858
  --
BEGIN

  PSB_WS_POS_PVT.Revise_Position_Projections
     (p_api_version => 1.0,
      p_init_msg_list => FND_API.G_TRUE,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_worksheet_id => p_worksheet_id,
      p_parameter_id => p_parameter_id);

  -- Bug#4675858 Start
  -- Set CP status to warning if flag is true.
  IF ( PSB_WS_ACCT1.g_soft_error_flag )
  THEN
    --
    l_set_cp_status
      := FND_CONCURRENT.Set_Completion_Status
         ( status  => 'WARNING'
         , message => NULL
         ) ;
    --
    -- Reset the variable as it has to be checked
    -- by many packages.
    --
    PSB_WS_ACCT1.g_soft_error_flag := FALSE ;
    --
  END IF ;
  -- Bug#4675858 End

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;
  --
  COMMIT WORK;
  --
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;

  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    --
    retcode := 2 ;
    COMMIT WORK ;
    --

END Revise_Position_Projections_CP;

/* ----------------------------------------------------------------------- */
/* Bug No 2482305 Start */

PROCEDURE Revise_Element_Projections_CP
(
  errbuf          OUT  NOCOPY  VARCHAR2,
  retcode         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id  IN   NUMBER,
  p_parameter_id  IN   NUMBER
) IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Revise_Element_Projections_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_msg_index_out           NUMBER;
  --
  l_set_cp_status           BOOLEAN        := FALSE ;  -- Bug#4675858
  --
BEGIN

  PSB_WS_POS_PVT.Revise_Element_Projections
     (p_api_version     => 1.0,
      p_init_msg_list   => FND_API.G_TRUE,
      p_return_status   => l_return_status,
      p_msg_count       => l_msg_count,
      p_msg_data        => l_msg_data,
      p_worksheet_id    => p_worksheet_id,
      p_parameter_id    => p_parameter_id);

  -- Bug#4675858 Start
  -- Set CP status to warning if flag is true.
  IF ( PSB_WS_ACCT1.g_soft_error_flag )
  THEN
    --
    l_set_cp_status
      := FND_CONCURRENT.Set_Completion_Status
         ( status  => 'WARNING'
         , message => NULL
         ) ;
    --
    -- Reset the variable as it has to be checked
    -- by many packages.
    --
    PSB_WS_ACCT1.g_soft_error_flag := FALSE ;
    --
  END IF ;
  -- Bug#4675858 End

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;
  --
  COMMIT WORK;
  --
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;

  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    --
    retcode := 2 ;
    COMMIT WORK ;
    --

END Revise_Element_Projections_CP;

/* ----------------------------------------------------------------------- */

PROCEDURE Revise_Element_Projections
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  --Bug:5753424:p_parameter_id receives parameter_set_id instead of parameter_id.
  p_parameter_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)     := 'Revise_Element_Projections';
  l_api_version       CONSTANT NUMBER           := 1.0;

  l_return_status     VARCHAR2(1);
  l_validation_status VARCHAR2(1);

/*Bug:5753424: Start */
  CURSOR c_parameters IS
  SELECT pes.entity_set_id parameter_set_id
        ,pes.name          parameter_set_name
        ,pe.entity_id parameter_id
        ,pe.name      parameter_name
        ,pe.entity_subtype parameter_type
        ,pea.priority
  FROM   psb_entity_set pes
        ,psb_entity pe
        ,psb_entity_assignment pea
  WHERE  pes.entity_set_id = p_parameter_id
  AND    pes.entity_type = 'PARAMETER'
  AND    pe.entity_type='PARAMETER'
  AND    pe.entity_subtype='ELEMENT'
  AND    pea.entity_id = pe.entity_id
  AND    pea.entity_set_id = pes.entity_set_id
  ORDER  BY pea.priority asc;

/*end bug:5753424*/

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

     if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Element_Projections',
        'BEGIN PSB_WS_POS_PVT.Revise_Element_Projections' );
      fnd_file.put_line(fnd_file.LOG,'BEGIN PSB_WS_POS_PVT.Revise_Element_Projections' );
     end if;

  -- Initialize message list if p_init_msg_list is set to TRUE

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Enforce Concurrency Control

  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_concurrency_class => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Call Private Function

/*Bug:5753424 start: Revise_Element_Projections api is called for
  all the element parameters in the parameter set. */

 FOR c_parameter_rec IN c_parameters LOOP

      /*start bug:5753424: Statement level logging*/
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Element_Projections',
        'Before call to PSB_WS_POS3.Revise_Element_Projections with p_parameter_id:'||c_parameter_rec.parameter_id );
        fnd_file.put_line(fnd_file.LOG,'Before call to PSB_WS_POS3.Revise_Element_Projections with p_parameter_id:'||c_parameter_rec.parameter_id);
       end if;

 --end bug:5753424

  PSB_WS_POS3.Revise_Element_Projections
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id,
--bug:5753424: modified the values passed for p_parameter_id.
      p_parameter_id => c_parameter_rec.parameter_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

  --bug:5753424:start

      /*start bug:5753424: Statement level logging*/
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Element_Projections',
        'Exception raised by PSB_WS_POS3.Revise_Element_Projections for parameter_id:'||c_parameter_rec.parameter_id);
        fnd_file.put_line(fnd_file.LOG,'Exception raised by PSB_WS_POS3.Revise_Element_Projections for parameter_id:'||c_parameter_rec.parameter_id);
       end if;
       /*end bug:5753424:end statement level log*/

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);

    FND_MESSAGE.SET_NAME('PSB','PSB_LPS_FAILURE_MSG');
    FND_MESSAGE.SET_TOKEN('LOCAL_PARAM_SET',c_parameter_rec.parameter_set_name);
    FND_MESSAGE.SET_TOKEN('LOCAL_PARAM',    c_parameter_rec.parameter_name);
    FND_MESSAGE.SET_TOKEN('ERROR_TRAPPED',  p_msg_data);
    FND_MSG_PUB.ADD;

  --bug:5753424:end

    raise FND_API.G_EXC_ERROR;
  end if;

--start bug:5753424
  END LOOP;
--end bug:5753424

  PSB_WS_ACCT2.Create_Rollup_Totals
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_WORKSHEET.Apply_Constraints
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_validation_status => l_validation_status,
      p_worksheet_id => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_concurrency_class => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   end if;


  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);

      if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Element_Projections',
        'END PSB_WS_POS_PVT.Revise_Element_Projections' );
     end if;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Revise_Element_Projections;

/* Bug No 2482305 End */
/* ----------------------------------------------------------------------- */

/* Bug: 5753424: Start */

/*===========================================================================+
 |                   PROCEDURE Revise_Elem_Pos_Projections_CP                   |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Revise
-- Element and Position Projections'
--
PROCEDURE Revise_Elem_Pos_Projections_CP
(
  errbuf              OUT  NOCOPY  VARCHAR2,
  retcode             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_parameter_set_id  IN   NUMBER
) IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Revise_Elem_Pos_Projections_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_msg_index_out           NUMBER;
  --
  l_set_cp_status           BOOLEAN        := FALSE ;  -- Bug#4675858
  --
  l_element_param_exists    VARCHAR2(1) := 'N';
  l_position_param_exists   VARCHAR2(1) := 'N';

  l_init_msg_lst            VARCHAR2(1) := FND_API.G_TRUE; --bug:8935662

  CURSOR c_ele_param_exists IS
  SELECT 'Y'
  FROM   psb_entity_set pes
        ,psb_entity pe
        ,psb_entity_assignment pea
  WHERE  pes.entity_set_id = p_parameter_set_id
  AND    pes.entity_type = 'PARAMETER'
  AND    pe.entity_type='PARAMETER'
  AND    pe.entity_subtype='ELEMENT'
  AND    pea.entity_id = pe.entity_id
  AND    pea.entity_set_id = pes.entity_set_id;

  CURSOR c_pos_param_exists IS
  SELECT 'Y'
  FROM   psb_entity_set pes
        ,psb_entity pe
        ,psb_entity_assignment pea
  WHERE  pes.entity_set_id = p_parameter_set_id
  AND    pes.entity_type = 'PARAMETER'
  AND    pe.entity_type='PARAMETER'
  AND    pe.entity_subtype='POSITION'
  AND    pea.entity_id = pe.entity_id
  AND    pea.entity_set_id = pes.entity_set_id;

BEGIN

  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Elem_Pos_Projections_CP',
        'BEGIN PSB_WS_POS_PVT.Revise_Elem_Pos_Projections_CP' );
  end if;

FOR c_ele_param_rec IN c_ele_param_exists LOOP
   l_element_param_exists := 'Y';
END LOOP;

FOR c_pos_param_rec IN c_pos_param_exists LOOP
   l_position_param_exists := 'Y';
END LOOP;

IF l_element_param_exists = 'Y' THEN

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Elem_Pos_Projections_CP',
        'Before call to Revise Element Proj with parameter_set_id:'||p_parameter_set_id );
        fnd_file.put_line(fnd_file.LOG,'Before call to Revise Element Proj with parameter_set_id:'||p_parameter_set_id );
  end if;

  PSB_WS_POS_PVT.Revise_Element_Projections
     (p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_TRUE,
      p_return_status       => l_return_status,
      p_msg_count           => l_msg_count,
      p_msg_data            => l_msg_data,
      p_worksheet_id        => p_worksheet_id,
      p_parameter_id        => p_parameter_set_id);

  -- Bug#4675858 Start
  -- Set CP status to warning if flag is true.
  IF ( PSB_WS_ACCT1.g_soft_error_flag )
  THEN
    --
    l_set_cp_status
      := FND_CONCURRENT.Set_Completion_Status
         ( status  => 'WARNING'
         , message => NULL
         ) ;
    --
    -- Reset the variable as it has to be checked
    -- by many packages.
    --
    PSB_WS_ACCT1.g_soft_error_flag := FALSE ;
    --
  END IF ;
  -- Bug#4675858 End

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

END IF;

/*bug:8935662:start*/
IF l_element_param_exists = 'Y' AND l_position_param_exists = 'Y' THEN
  l_init_msg_lst := FND_API.G_FALSE;
ELSIF l_element_param_exists = 'N' AND l_position_param_exists = 'Y' THEN
  l_init_msg_lst := FND_API.G_TRUE;
END IF;
/*bug:8935662:end*/

IF l_position_param_exists = 'Y' THEN

  l_return_status  := NULL;
  l_msg_count      := NULL;
  l_msg_data       := NULL;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Elem_Pos_Projections_CP',
        'Before call to Revise_Position_Projections with parameter_set_id:'||p_parameter_set_id );
    end if;

  PSB_WS_POS_PVT.Revise_Position_Projections
  (p_api_version => 1.0,
   p_init_msg_list => l_init_msg_lst,   --bug:8935662:modified
   p_return_status => l_return_status,
   p_msg_count => l_msg_count,
   p_msg_data => l_msg_data,
   p_worksheet_id => p_worksheet_id,
   p_parameter_id => p_parameter_set_id
  ) ;

  -- Bug#4675858 Start
  -- Set CP status to warning if flag is true.
  IF ( PSB_WS_ACCT1.g_soft_error_flag )
  THEN
    --
    l_set_cp_status
      := FND_CONCURRENT.Set_Completion_Status
         ( status  => 'WARNING'
         , message => NULL
         ) ;
    --
    -- Reset the variable as it has to be checked
    -- by many packages.
    --
    PSB_WS_ACCT1.g_soft_error_flag := FALSE ;
    --
  END IF ;
  -- Bug#4675858 End

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

END IF;

  /*bug:8935662:start*/
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

  if l_msg_count = 0 then

    PSB_MESSAGE_S.Print_Success;
    retcode := 0 ;
  elsif l_msg_count > 0 then
    FND_MESSAGE.Set_Name('PSB', 'PSB_PROGRAM_WARNING_HEADER');
    l_msg_data := FND_Message.Get;
    fnd_file.put_line(fnd_file.LOG,l_msg_data);

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_FALSE );

    retcode := 1;
  end if;
  /*bug:8935662:end*/
  --
  COMMIT WORK;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Elem_Pos_Projections_CP',
        'Commit Executed in PSB_WS_POS_PVT.Revise_Elem_Pos_Projections_CP' );
    end if;
  --
    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'PSB/LOCAL_PARAM_SET/PSBPWCPB/Revise_Elem_Pos_Projections_CP',
        'END PSB_WS_POS_PVT.Revise_Elem_Pos_Projections_CP' );
  end if;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    --COMMIT WORK ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    --COMMIT WORK ;

  WHEN OTHERS THEN

    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    --
    retcode := 2 ;
    --COMMIT WORK ;
    --
END Revise_Elem_Pos_Projections_CP;

/* Bug: 5753424: End */


END PSB_WS_POS_PVT;

/
