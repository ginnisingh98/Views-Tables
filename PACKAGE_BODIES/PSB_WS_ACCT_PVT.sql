--------------------------------------------------------
--  DDL for Package Body PSB_WS_ACCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_ACCT_PVT" AS
/* $Header: PSBPWCAB.pls 120.6.12010000.3 2009/04/10 10:38:03 rkotha ship $ */

  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'PSB_WS_ACCT_PVT';

/* ----------------------------------------------------------------------- */

PROCEDURE Check_CCID_Type
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER  := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_ccid_type         OUT  NOCOPY  VARCHAR2,
  p_flex_code         IN   NUMBER,
  p_ccid              IN   NUMBER,
  p_budget_group_id   IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Check_CCID_Type';
  l_api_version       CONSTANT NUMBER         := 1.0;

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

  PSB_WS_ACCT1.Check_CCID_Type
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_ccid_type => p_ccid_type,
      p_flex_code => p_flex_code,
      p_ccid => p_ccid,
      p_budget_group_id => p_budget_group_id);


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Check_CCID_Type;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Account_Dist
( p_api_version              IN   NUMBER,
  p_init_msg_list            IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                   IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level         IN   NUMBER  := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_account_line_id          OUT  NOCOPY  NUMBER,
  p_msg_count                OUT  NOCOPY  NUMBER,
  p_msg_data                 OUT  NOCOPY  VARCHAR2,
  p_worksheet_id             IN   NUMBER,
  p_check_spal_exists        IN   VARCHAR2 := FND_API.G_TRUE,
  p_gl_cutoff_period         IN   DATE := FND_API.G_MISS_DATE,
  p_allocrule_set_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_rounding_factor          IN   NUMBER := FND_API.G_MISS_NUM,
  p_stage_set_id             IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_year_id           IN   NUMBER,
  p_budget_group_id          IN   NUMBER,
  p_ccid                     IN   NUMBER := FND_API.G_MISS_NUM,
  p_flex_mapping_set_id      IN   NUMBER := FND_API.G_MISS_NUM,
  p_map_accounts             IN   BOOLEAN := FALSE,
  p_flex_code                IN   NUMBER := FND_API.G_MISS_NUM,
  p_concatenated_segments    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_startdate_pp             IN   DATE := FND_API.G_MISS_DATE,
  p_template_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_currency_code            IN   VARCHAR2,
  p_balance_type             IN   VARCHAR2,
  p_ytd_amount               IN   NUMBER,
  p_distribute_flag          IN   VARCHAR2 := FND_API.G_FALSE,
  p_annual_fte               IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_amount            IN   PSB_WS_ACCT1.g_prdamt_tbl_type,
  p_position_line_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_element_set_id           IN   NUMBER := FND_API.G_MISS_NUM,
  p_salary_account_line      IN   VARCHAR2 := FND_API.G_FALSE,
  p_service_package_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_start_stage_seq          IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq        IN   NUMBER := FND_API.G_MISS_NUM,
  p_end_stage_seq            IN   NUMBER := FND_API.G_MISS_NUM,
  p_copy_of_account_line_id  IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name                 CONSTANT VARCHAR2(30)   := 'Create_Account_Dist';
  l_api_version              CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Create_Account_Dist_Pvt;


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

  PSB_WS_ACCT1.Create_Account_Dist
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_account_line_id => p_account_line_id,
      p_worksheet_id => p_worksheet_id,
      p_check_spal_exists => p_check_spal_exists,
      p_gl_cutoff_period => p_gl_cutoff_period,
      p_allocrule_set_id => p_allocrule_set_id,
      p_budget_calendar_id => p_budget_calendar_id,
      p_rounding_factor => p_rounding_factor,
      p_stage_set_id => p_stage_set_id,
      p_budget_year_id => p_budget_year_id,
      p_budget_group_id => p_budget_group_id,
      p_ccid => p_ccid,
      p_flex_mapping_set_id => p_flex_mapping_set_id,
      p_map_accounts => p_map_accounts,
      p_flex_code => p_flex_code,
      p_concatenated_segments => p_concatenated_segments,
      p_startdate_pp => p_startdate_pp,
      p_template_id => p_template_id,
      p_currency_code => p_currency_code,
      p_balance_type => p_balance_type,
      p_ytd_amount => p_ytd_amount,
      p_distribute_flag => p_distribute_flag,
      p_annual_fte => p_annual_fte,
      p_period_amount => p_period_amount,
      p_position_line_id => p_position_line_id,
      p_element_set_id => p_element_set_id,
      p_salary_account_line => p_salary_account_line,
      p_service_package_id => p_service_package_id,
      p_start_stage_seq => p_start_stage_seq,
      p_current_stage_seq => p_current_stage_seq,
      p_end_stage_seq => p_end_stage_seq,
      p_copy_of_account_line_id => p_copy_of_account_line_id
      );

  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_Account_Dist_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_Account_Dist_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Create_Account_Dist_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Create_Account_Dist;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Account_Dist
( p_api_version              IN   NUMBER,
  p_init_msg_list            IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                   IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level         IN   NUMBER  := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_msg_count                OUT  NOCOPY  NUMBER,
  p_msg_data                 OUT  NOCOPY  VARCHAR2,
  p_worksheet_id             IN   NUMBER,
  p_distribute_flag          IN   VARCHAR2 := FND_API.G_FALSE,
  p_account_line_id          IN   NUMBER,
  p_check_stages             IN   VARCHAR2 := FND_API.G_TRUE,
  p_ytd_amount               IN   NUMBER,
  p_annual_fte               IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_amount            IN   PSB_WS_ACCT1.g_prdamt_tbl_type,
  p_budget_group_id          IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq        IN   NUMBER := FND_API.G_MISS_NUM,
  p_copy_of_account_line_id  IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name                 CONSTANT VARCHAR2(30)   := 'Create_Account_Dist';
  l_api_version              CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Create_Account_Dist_Pvt;


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

  PSB_WS_ACCT1.Create_Account_Dist
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id,
      p_distribute_flag => p_distribute_flag,
      p_account_line_id => p_account_line_id,
      p_check_stages => p_check_stages,
      p_ytd_amount => p_ytd_amount,
      p_annual_fte => p_annual_fte,
      p_period_amount => p_period_amount,
      p_budget_group_id => p_budget_group_id,
      p_service_package_id => p_service_package_id,
      p_current_stage_seq => p_current_stage_seq,
      p_copy_of_account_line_id => p_copy_of_account_line_id);


  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_Account_Dist_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_Account_Dist_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Create_Account_Dist_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Create_Account_Dist;

/* ----------------------------------------------------------------------- */

PROCEDURE Revise_Account_Projections
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_parameter_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)     := 'Revise_Account_Projections';
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
  AND    pe.entity_subtype='ACCOUNT'
  AND    pea.entity_id = pe.entity_id
  AND    pea.entity_set_id = pes.entity_set_id
  ORDER  BY pea.priority asc;

/*end bug:5753424*/
BEGIN

     /*start bug:5753424: procedure level logging*/
    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'PSB/LOCAL_PARAM_SET/PSBPWCAB/Revise_Account_Projections',
      'BEGIN Revise_Account_Projections');
        fnd_file.put_line(fnd_file.LOG,'BEGIN Revise_Account_Projections');
     end if;
     /*end bug:5753424:end procedure level log*/

  -- Standard Start of API savepoint

  SAVEPOINT  Revise_Account_Projections_Pvt;


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
/*Bug:5753424 start: Revise_Account_Projections api is called for
  all the account parameters in the parameter set. */

 FOR c_parameter_rec IN c_parameters LOOP
 --end bug:5753424

     /*start bug:5753424: statement level logging*/
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
      'PSB/LOCAL_PARAM_SET/PSBPWCAB/Revise_Account_Projections',
      'Before call to PSB_WS_ACCT2.Revise_Account_Projections for parameter_id:'||c_parameter_rec.parameter_id);
        fnd_file.put_line(fnd_file.LOG,'Before call to PSB_WS_ACCT2.Revise_Account_Projections for parameter_id:'||c_parameter_rec.parameter_id);
     end if;
     /*end bug:5753424:end statement level log*/

  PSB_WS_ACCT2.Revise_Account_Projections
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id,
/*bug:5753424: modified the values passed for p_parameter_id.
      parameter_set_id value is passed to p_parameter_id*/
      p_parameter_id => c_parameter_rec.parameter_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

  /*bug:5753424:start*/

     /*start bug:5753424: statement level logging*/
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
      'PSB/LOCAL_PARAM_SET/PSBPWCAB/Revise_Account_Projections',
      'Exception due to call-PSB_WS_ACCT2.Revise_Account_Projections for parameter_id:'||c_parameter_rec.parameter_id);
        fnd_file.put_line(fnd_file.LOG,'Exception due to call-PSB_WS_ACCT2.Revise_Account_Projections for parameter_id:'||c_parameter_rec.parameter_id);
     end if;
     /*end bug:5753424:end statement level log*/

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);

    FND_MESSAGE.SET_NAME('PSB','PSB_LPS_FAILURE_MSG');
    FND_MESSAGE.SET_TOKEN('LOCAL_PARAM_SET',c_parameter_rec.parameter_set_name);
    FND_MESSAGE.SET_TOKEN('LOCAL_PARAM',    c_parameter_rec.parameter_name);
    FND_MESSAGE.SET_TOKEN('ERROR_TRAPPED',  p_msg_data);
    FND_MSG_PUB.ADD;

  /*bug:5753424:end*/

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

      /*start bug:5753424: procedure level logging*/
    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'PSB/LOCAL_PARAM_SET/PSBPWCAB/Revise_Account_Projections',
      'END Revise_Account_Projections');
      fnd_file.put_line(fnd_file.LOG,'END Revise_Account_Projections');
     end if;
     /*end bug:5753424:end procedure level log*/

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Revise_Account_Projections_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Revise_Account_Projections_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Revise_Account_Projections_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Revise_Account_Projections;

/* ----------------------------------------------------------------------- */

PROCEDURE Update_GL_Balances
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)     := 'Update_GL_Balances';
  l_api_version       CONSTANT NUMBER           := 1.0;
  l_return_status     VARCHAR2(1);

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Update_GL_Balances_Pvt;


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

  PSB_WS_ACCT2.Update_GL_Balances
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id);

  /* Bug 5172988 Start */
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

  PSB_WS_ACCT2.Create_Rollup_Totals
     (p_api_version   => 1.0,
      p_return_status => l_return_status,
      p_worksheet_id  => p_worksheet_id);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;
  /* Bug 5172988 End */

  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Update_GL_Balances_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Update_GL_Balances_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Update_GL_Balances_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Update_GL_Balances;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Rollup_Totals
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER  :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_rounding_factor     IN   NUMBER := FND_API.G_MISS_NUM,
  p_stage_set_id        IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER := FND_API.G_MISS_NUM,
  p_set_of_books_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_flex_code           IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id  IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_Rollup_Totals';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Create_Rollup_Totals_Pvt;


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

  PSB_WS_ACCT2.Create_Rollup_Totals
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id,
      p_rounding_factor => p_rounding_factor,
      p_stage_set_id => p_stage_set_id,
      p_current_stage_seq => p_current_stage_seq,
      p_set_of_books_id => p_set_of_books_id,
      p_flex_code => p_flex_code,
      p_budget_group_id => p_budget_group_id,
      p_budget_calendar_id => p_budget_calendar_id);


  -- Standard Check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_Rollup_Totals_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_Rollup_Totals_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);


   when OTHERS then
     rollback to Create_Rollup_Totals_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Create_Rollup_Totals;

/* ----------------------------------------------------------------------- */
/*===========================================================================+
 |                   PROCEDURE Update_GL_Balances_CP                         |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Update_GL_Balances_CP'
-- which runs 'Update GL Balances' program through the
-- Standard Report Submissions.
--
PROCEDURE Update_GL_Balances_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  p_worksheet_id              IN       NUMBER := FND_API.G_MISS_NUM
)
IS
  --
   l_api_name       CONSTANT VARCHAR2(30)   := 'Update_GL_Balances_CP';
   l_api_version    CONSTANT NUMBER         :=  1.0 ;
   --
   l_error_api_name          VARCHAR2(2000);
   l_return_status           VARCHAR2(1) ;
   l_msg_count               NUMBER ;
   l_msg_data                VARCHAR2(2000) ;
   l_msg_index_out           NUMBER;
   --
BEGIN
  --
   PSB_CONCURRENCY_CONTROL_PUB.Enforce_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_concurrency_class => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   end if;

   PSB_WS_ACCT_PVT.Update_GL_Balances
     (p_api_version => 1.0,
      p_init_msg_list => FND_API.G_TRUE,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_worksheet_id => p_worksheet_id);


   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

  --
   PSB_CONCURRENCY_CONTROL_PUB.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_concurrency_class => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
     raise FND_API.G_EXC_ERROR;
   end if;
   --
   PSB_MESSAGE_S.Print_Success;
   retcode := 0 ;
   --
   COMMIT WORK;
   --

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_CONCURRENCY_CONTROL_PUB.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
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
     PSB_CONCURRENCY_CONTROL_PUB.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_concurrency_class => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

     PSB_CONCURRENCY_CONTROL_PUB.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
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
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
END Update_GL_Balances_CP ;


/*===========================================================================+
 |                   PROCEDURE Create_Rollup_Totals_CP                      |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Create_Rollup_Totals_CP'
-- which runs 'Create Rollup Totals' program through the
-- Standard Report Submissions.
--
PROCEDURE Create_Rollup_Totals_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  p_create_summary_totals     IN       VARCHAR2  ,
  p_worksheet_id              IN       NUMBER := FND_API.G_MISS_NUM
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Create_Rollup_Totals_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
BEGIN

  IF p_create_summary_totals = 'Y' THEN

   PSB_CONCURRENCY_CONTROL_PUB.Enforce_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_concurrency_class => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   end if;

  PSB_WS_ACCT_PVT.Create_Rollup_Totals
     (p_api_version => 1.0,
      p_init_msg_list => FND_API.G_TRUE,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_worksheet_id => p_worksheet_id);


  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --

   PSB_CONCURRENCY_CONTROL_PUB.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_concurrency_class => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
   end if;

  ELSE

    NULL;

  END IF;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;
  --
  COMMIT WORK;
  --
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

   PSB_CONCURRENCY_CONTROL_PUB.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_concurrency_class => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   PSB_CONCURRENCY_CONTROL_PUB.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_concurrency_class => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;

  WHEN OTHERS THEN

   PSB_CONCURRENCY_CONTROL_PUB.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_concurrency_class => 'WORKSHEET_CREATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

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

END Create_Rollup_Totals_CP ;

/* ---------------------------------------------------------------------------------- */
--
-- This is the execution file for the concurrent program 'Revise_Account_Projections_CP'
--
PROCEDURE Revise_Account_Projections_CP
(
  errbuf          OUT  NOCOPY  VARCHAR2,
  retcode         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id  IN   NUMBER,
  p_parameter_id  IN   NUMBER
) IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Revise_Account_Projections_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_msg_index_out           NUMBER;
  --
  l_set_CP_status           BOOLEAN := FALSE; -- Bug#4571412
BEGIN

     /*start bug:5753424: procedure level logging*/
    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'PSB/LOCAL_PARAM_SET/PSBPWCAB/Revise_Account_Projections_CP',
      'BEGIN Revise_Account_Projections_CP');
      fnd_file.put_line(fnd_file.LOG,'BEGIN Revise_Account_Projections_CP');
     end if;
     /*end bug:5753424:end procedure level log*/

  PSB_WS_ACCT_PVT.Revise_Account_Projections
     (p_api_version => 1.0,
      p_init_msg_list => FND_API.G_TRUE,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_worksheet_id => p_worksheet_id,
      p_parameter_id => p_parameter_id);

  -- Bug#4675858
  -- Set the CP status to warning if
  -- Note updation had some problems.
  IF ( PSB_WS_ACCT1.g_soft_error_flag ) THEN
    --
    l_set_CP_status
      := FND_CONCURRENT.Set_Completion_Status
         (status  => 'WARNING',
          message => NULL
         );
    --
    -- Reset the variable as it has to be checked in
    -- other packages also.
    PSB_WS_ACCT1.g_soft_error_flag := FALSE ;
    --
  END IF;

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;
  --
  COMMIT WORK;
  --
     /*start bug:5753424: procedure level logging*/
    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'PSB/LOCAL_PARAM_SET/PSBPWCAB/Revise_Account_Projections_CP',
      'END Revise_Account_Projections_CP');
      fnd_file.put_line(fnd_file.LOG,'END Revise_Account_Projections_CP');
     end if;
     /*end bug:5753424:end procedure level log*/

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

END Revise_Account_Projections_CP;

/* ----------------------------------------------------------------------- */

END PSB_WS_ACCT_PVT;

/
