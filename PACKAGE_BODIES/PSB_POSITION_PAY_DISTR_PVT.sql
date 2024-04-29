--------------------------------------------------------
--  DDL for Package Body PSB_POSITION_PAY_DISTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_POSITION_PAY_DISTR_PVT" AS
/* $Header: PSBVPYDB.pls 120.7.12010000.3 2009/09/15 12:46:00 rkotha ship $ */
--
-- Global Variables
--

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_POSITION_PAY_DISTR_PVT';

  TYPE g_paydist_rec_type IS RECORD
     ( distribution_id               NUMBER,
       position_id                   NUMBER,
       data_extract_id               NUMBER,
       worksheet_id                  NUMBER,
       effective_start_date          DATE,
       effective_end_date            DATE,
       chart_of_accounts_id          NUMBER,
       code_combination_id           NUMBER,
       distribution_percent          NUMBER,
       global_default_flag           VARCHAR2(1),
       dist_default_rule_id          NUMBER,
       proper_subset                 VARCHAR2(1),
       project_id                    NUMBER,
       task_id                       NUMBER,
       award_id                      NUMBER,
       expenditure_type              VARCHAR2(30),
       expenditure_organization_id   NUMBER,
       --UTF8 changes for Bug No : 2615261
       description                   psb_position_pay_distributions.description%TYPE,
       delete_flag                   VARCHAR2(1));

  TYPE g_paydist_tbl_type IS TABLE OF g_paydist_rec_type
    INDEX BY BINARY_INTEGER;

  g_pay_dist                 g_paydist_tbl_type;
  g_num_pay_dist             NUMBER;

  TYPE TokNameArray IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;

  TYPE TokValArray IS TABLE OF VARCHAR2(1000)
    INDEX BY BINARY_INTEGER;

  -- Number of Message Tokens

  no_msg_tokens              NUMBER := 0;

  -- Message Token Name

  msg_tok_names              TokNameArray;

  -- Message Token Value

  msg_tok_val                TokValArray;

  G_DBUG              VARCHAR2(2000);

/* ----------------------------------------------------------------------- */

PROCEDURE message_token
( tokname  IN  VARCHAR2,
  tokval   IN  VARCHAR2
);

PROCEDURE add_message
( appname  IN  VARCHAR2,
  msgname  IN  VARCHAR2
);

--
-- Private Procedure Declarations
--
--

PROCEDURE Modify_WS_Distribution
( p_return_status                 OUT  NOCOPY     VARCHAR2,
  p_distribution_id               IN OUT  NOCOPY  NUMBER,
  p_position_id                   IN      NUMBER,
  p_data_extract_id               IN      NUMBER,
  p_worksheet_id                  IN      NUMBER := FND_API.G_MISS_NUM,
  p_effective_start_date          IN      DATE,
  p_effective_end_date            IN      DATE,
  p_chart_of_accounts_id          IN      NUMBER,
  p_code_combination_id           IN      NUMBER,
  p_distribution_percent          IN      NUMBER,
  p_global_default_flag           IN      VARCHAR2,
  p_distribution_default_rule_id  IN      NUMBER,
  p_rowid                         IN OUT  NOCOPY  VARCHAR2,
  p_project_id                    IN      NUMBER,
  p_task_id                       IN      NUMBER,
  p_award_id                      IN      NUMBER,
  p_expenditure_type              IN      VARCHAR2,
  p_expenditure_organization_id   IN      NUMBER,
  p_description                   IN      VARCHAR2 ,
  p_mode                          IN      VARCHAR2
);
-- Begin Table Handler Procedures
--

--
PROCEDURE INSERT_ROW
( p_api_version                      IN NUMBER,
  p_init_msg_list                    IN VARCHAR2 := fnd_api.g_false,
  p_commit                           IN VARCHAR2 := fnd_api.g_false,
  p_validation_level                 IN NUMBER := fnd_api.g_valid_level_full,
  p_return_status                    OUT  NOCOPY VARCHAR2,
  p_msg_count                        OUT  NOCOPY NUMBER,
  p_msg_data                         OUT  NOCOPY VARCHAR2,
  p_rowid                            IN  OUT  NOCOPY VARCHAR2,
  p_distribution_id                  IN NUMBER,
  p_position_id                      IN NUMBER,
  p_data_extract_id                  IN NUMBER,
  p_worksheet_id                     IN NUMBER := FND_API.G_MISS_NUM,
  p_effective_start_date             IN DATE,
  p_effective_end_date               IN DATE,
  p_chart_of_accounts_id             IN NUMBER,
  p_code_combination_id              IN NUMBER,
  p_distribution_percent             IN NUMBER,
  p_global_default_flag              IN VARCHAR2,
  p_distribution_default_rule_id     IN NUMBER,
  p_project_id                       IN NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                          IN NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                         IN NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type                 IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id      IN NUMBER:= FND_API.G_MISS_NUM,
  p_description                      IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_mode                             in varchar2 := 'R'
  ) is
    cursor C is select ROWID from PSB_POSITION_PAY_DISTRIBUTIONS
      where distribution_id = P_distribution_id;
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
--
l_api_name      CONSTANT VARCHAR2(30) := 'Insert_Row' ;
l_api_version   CONSTANT NUMBER := 1.0 ;
l_return_status VARCHAR2(1);
--
BEGIN
  --
  SAVEPOINT Insert_Row ;
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;
  --
  --
  P_LAST_UPDATE_DATE := SYSDATE;
  if(P_MODE = 'I') then
    P_LAST_UPDATED_BY := 1;
    P_LAST_UPDATE_LOGIN := 0;
  elsif (P_MODE = 'R') then
    P_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if P_LAST_UPDATED_BY is NULL then
      P_LAST_UPDATED_BY := -1;
    end if;
    P_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if P_LAST_UPDATE_LOGIN is NULL then
      P_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    FND_MSG_PUB.Add ;
    raise FND_API.G_EXC_ERROR;
  end if;
  --
   insert into PSB_POSITION_PAY_DISTRIBUTIONS(
    distribution_id      ,
    position_id          ,
    data_extract_id      ,
    worksheet_id         ,
    effective_start_date   ,
    effective_end_date  ,
    chart_of_accounts_id     ,
    code_combination_id ,
    distribution_percent     ,
    global_default_flag ,
    distribution_default_rule_id     ,
    project_id,
    task_id,
    award_id,
    expenditure_type,
    expenditure_organization_id,
    description,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  ) values (
    p_distribution_id      ,
    p_position_id        ,
    p_data_extract_id    ,
    decode(p_worksheet_id,FND_API.G_MISS_NUM,null,p_worksheet_id),
    p_effective_start_date   ,
    p_effective_end_date        ,
    p_chart_of_accounts_id     ,
    p_code_combination_id ,
    p_distribution_percent     ,
    p_global_default_flag ,
    p_distribution_default_rule_id     ,
    decode(p_project_id, FND_API.G_MISS_NUM, null, p_project_id),
    decode(p_task_id, FND_API.G_MISS_NUM, null, p_task_id),
    decode(p_award_id, FND_API.G_MISS_NUM, null, p_award_id),
    decode(p_expenditure_type, FND_API.G_MISS_CHAR, null, p_expenditure_type),
    decode(p_expenditure_organization_id, FND_API.G_MISS_NUM, null, p_expenditure_organization_id),
    decode(p_description, FND_API.G_MISS_CHAR, null, p_description),
    p_last_update_date,
    p_last_updated_by,
    p_last_update_date,
    p_last_updated_by,
    p_last_update_login
  );
  --
  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise FND_API.G_EXC_ERROR ;
    --raise no_data_found;
  end if;
  close c;
  --
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);
  --
EXCEPTION
   --
   when FND_API.G_EXC_ERROR then
     --
     rollback to INSERT_ROW ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to INSERT_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to INSERT_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
END INSERT_ROW;
--

PROCEDURE LOCK_ROW
( p_api_version                      IN NUMBER,
  p_init_msg_list                    IN VARCHAR2 := fnd_api.g_false,
  p_commit                           IN VARCHAR2 := fnd_api.g_false,
  p_validation_level                 IN NUMBER := fnd_api.g_valid_level_full,
  p_return_status                    OUT  NOCOPY VARCHAR2,
  p_msg_count                        OUT  NOCOPY NUMBER,
  p_msg_data                         OUT  NOCOPY VARCHAR2,
  p_row_locked                       OUT  NOCOPY VARCHAR2,
  p_distribution_id                  IN NUMBER,
  p_position_id                      IN NUMBER,
  p_data_extract_id                  IN NUMBER,
  p_worksheet_id                     IN NUMBER := FND_API.G_MISS_NUM,
  p_effective_start_date             IN DATE,
  p_effective_end_date               IN DATE,
  p_chart_of_accounts_id             IN NUMBER,
  p_code_combination_id              IN NUMBER,
  p_distribution_percent             IN NUMBER,
  p_global_default_flag              IN VARCHAR2,
  p_distribution_default_rule_id     IN NUMBER,
  p_project_id                       IN NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                          IN NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                         IN NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type                 IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id      IN NUMBER:= FND_API.G_MISS_NUM,
  p_description                      IN VARCHAR2:= FND_API.G_MISS_CHAR

) is
  cursor c1 is select
    distribution_id,
    position_id,
    data_extract_id,
    worksheet_id,
    effective_start_date,
    effective_end_date,
    chart_of_accounts_id,
    code_combination_id,
    distribution_percent,
    distribution_default_rule_id,
    global_default_flag,
    project_id,
    task_id,
    award_id,
    expenditure_type,
    expenditure_organization_id,
    description
   from PSB_POSITION_PAY_DISTRIBUTIONS
    where distribution_id = P_distribution_id
    for update of distribution_id nowait;
  tlinfo c1%rowtype;
--
l_api_name      CONSTANT VARCHAR2(30) := 'Lock_Row' ;
l_api_version   CONSTANT NUMBER := 1.0 ;
l_return_status VARCHAR2(1);
--
BEGIN
  --
  SAVEPOINT Lock_Row ;
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;
  --
  p_row_locked    := FND_API.G_TRUE ;
  --
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    fnd_msg_pub.add ;
    close c1;
    raise fnd_api.g_exc_error ;
  end if;
  close c1;
  --
  if ( (tlinfo.position_id = p_position_id)
      AND (tlinfo.distribution_id = p_distribution_id)
      AND (tlinfo.data_extract_id = p_data_extract_id)
      AND (tlinfo.effective_start_date  = p_effective_start_date)
      AND (tlinfo.chart_of_accounts_id = p_chart_of_accounts_id)
      AND (tlinfo.code_combination_id = p_code_combination_id)

      AND ((tlinfo.effective_end_date = p_effective_end_date)
	   OR ((tlinfo.effective_end_date is null)
	       AND (p_effective_end_date is null)))

 --     AND ((tlinfo.worksheet_id = p_worksheet_id)
 --          OR ((tlinfo.worksheet_id is null)
 --              AND (p_worksheet_id is null))

     -- do not test this due to ws specific

      AND (tlinfo.distribution_percent = p_distribution_percent)

      AND ((tlinfo.global_default_flag = p_global_default_flag)
	   OR ((tlinfo.global_default_flag  is null)
	       AND (p_global_default_flag  is null)))

      AND ((tlinfo.distribution_default_rule_id = p_distribution_default_rule_id)
	   OR ((tlinfo.distribution_default_rule_id is null)
	       AND (p_distribution_default_rule_id  is null)))

      AND ((tlinfo.project_id = p_project_id)
	   OR ((tlinfo.project_id is null)
	       AND (p_project_id is null))
	   OR ( (p_project_id = FND_API.G_MISS_NUM )))

      AND ((tlinfo.task_id = p_task_id)
	   OR ((tlinfo.task_id is null)
	      AND (p_task_id is null))
	   OR ( (p_task_id = FND_API.G_MISS_NUM )))

       AND ((tlinfo.award_id = p_award_id)
	   OR ((tlinfo.award_id is null)
	       AND (p_award_id is null))
	   OR ( (p_award_id = FND_API.G_MISS_NUM)))

       AND ((tlinfo.expenditure_type = p_expenditure_type)
	   OR ((tlinfo.expenditure_type is null)
	       AND (p_expenditure_type is null))
	   OR ((p_expenditure_type = FND_API.G_MISS_CHAR)))

	AND ((tlinfo.expenditure_organization_id = p_expenditure_organization_id)
	   OR ((tlinfo.expenditure_organization_id is null)
	       AND (p_expenditure_organization_id is null))
	   OR ((p_expenditure_organization_id = FND_API.G_MISS_NUM)))

	AND ((tlinfo.description = p_description)
	   OR ((tlinfo.description is null)
	       AND (p_description is null))
	   OR ( (p_description = FND_API.G_MISS_CHAR)))


  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error ;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

EXCEPTION
  when app_exception.record_lock_exception then
     --
     rollback to LOCK_ROW ;
     p_row_locked    := FND_API.G_FALSE ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
  when FND_API.G_EXC_ERROR then
     --
     rollback to LOCK_ROW ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to LOCK_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to LOCK_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
END LOCK_ROW;

--
PROCEDURE UPDATE_ROW (
  p_api_version                      IN NUMBER,
  p_init_msg_list                    IN VARCHAR2 := fnd_api.g_false,
  p_commit                           IN VARCHAR2 := fnd_api.g_false,
  p_validation_level                 IN NUMBER := fnd_api.g_valid_level_full,
  p_return_status                    OUT  NOCOPY VARCHAR2,
  p_msg_count                        OUT  NOCOPY NUMBER,
  p_msg_data                         OUT  NOCOPY VARCHAR2,
  p_distribution_id                  IN NUMBER,
  p_code_combination_id              IN NUMBER,
  p_effective_start_date             IN DATE := FND_API.G_MISS_DATE,
  p_effective_end_date               IN DATE := FND_API.G_MISS_DATE,
  p_distribution_percent             IN NUMBER,
  p_global_default_flag              IN VARCHAR2,
  p_distribution_default_rule_id     IN NUMBER,
  p_project_id                       IN NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                          IN NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                         IN NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type                 IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id      IN NUMBER:= FND_API.G_MISS_NUM,
  p_description                      IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_mode                             in varchar2 := 'R'

  ) is
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
--
l_api_name      CONSTANT VARCHAR2(30) := 'Update Row';
l_api_version   CONSTANT NUMBER := 1.0 ;
l_return_status VARCHAR2(1);
--
BEGIN
  --
  SAVEPOINT Update_Row ;
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  --
  P_LAST_UPDATE_DATE := SYSDATE;
  if(P_MODE = 'I') then
    P_LAST_UPDATED_BY := 1;
    P_LAST_UPDATE_LOGIN := 0;
  elsif (P_MODE = 'R') then
    P_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if P_LAST_UPDATED_BY is NULL then
      P_LAST_UPDATED_BY := -1;
    end if;
    P_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if P_LAST_UPDATE_LOGIN is NULL then
      P_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    FND_MSG_PUB.Add ;
    raise FND_API.G_EXC_ERROR ;
  end if;

  -- do the update of the record
  --
  update PSB_POSITION_PAY_DISTRIBUTIONS set
    code_combination_id = p_code_combination_id,
    effective_start_date = decode(p_effective_start_date, FND_API.G_MISS_DATE, effective_start_date, p_effective_start_date),
    effective_end_date = decode(p_effective_end_date, FND_API.G_MISS_DATE, effective_end_date, p_effective_end_date),
    distribution_percent = p_distribution_percent,
    global_default_flag = p_global_default_flag,
    distribution_default_rule_id = p_distribution_default_rule_id,
    project_id  = decode(p_project_id,FND_API.G_MISS_NUM,
		  project_id, p_project_id),
    task_id = decode(p_task_id,FND_API.G_MISS_NUM,
		  task_id, p_task_id),
    award_id = decode(p_award_id,FND_API.G_MISS_NUM,
		  award_id, p_award_id),
    expenditure_type  = decode(p_expenditure_type,
		  FND_API.G_MISS_CHAR, expenditure_type,
		  p_expenditure_type),
    expenditure_organization_id  = decode(p_expenditure_organization_id,
		  FND_API.G_MISS_NUM, expenditure_organization_id,
		  p_expenditure_organization_id),
    description  = decode(p_description,
		  FND_API.G_MISS_CHAR, description,
		  p_description),
    last_update_date = p_last_update_date,
    last_updated_by = p_last_updated_by,
    last_update_login = p_last_update_login
  where distribution_id = p_distribution_id;

  if (sql%notfound) then
    -- raise no_data_found;
    raise FND_API.G_EXC_ERROR ;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  --
  --
  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);
--
EXCEPTION

   when FND_API.G_EXC_ERROR then
     --
     rollback to Update_Row ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to Update_Row ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to Update_Row ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --

END UPDATE_ROW;
--
PROCEDURE ADD_ROW (
  p_api_version                      IN NUMBER,
  p_init_msg_list                    IN VARCHAR2 := fnd_api.g_false,
  p_commit                           IN VARCHAR2 := fnd_api.g_false,
  p_validation_level                 IN NUMBER := fnd_api.g_valid_level_full,
  p_return_status                    OUT  NOCOPY VARCHAR2,
  p_msg_count                        OUT  NOCOPY NUMBER,
  p_msg_data                         OUT  NOCOPY VARCHAR2,
  p_rowid                            IN OUT  NOCOPY VARCHAR2,
  p_distribution_id                  IN NUMBER,
  p_position_id                      IN NUMBER,
  p_data_extract_id                  IN NUMBER,
  p_worksheet_id                     IN NUMBER,
  p_effective_start_date             IN DATE,
  p_effective_end_date               IN DATE,
  p_chart_of_accounts_id             IN NUMBER,
  p_code_combination_id              IN NUMBER,
  p_distribution_percent             IN NUMBER,
  p_global_default_flag              IN VARCHAR2,
  p_distribution_default_rule_id     IN NUMBER,
  p_project_id                       IN NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                          IN NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                         IN NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type                 IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id      IN NUMBER:= FND_API.G_MISS_NUM,
  p_description                      IN VARCHAR2:= FND_API.G_MISS_CHAR,
  p_mode                             in varchar2 := 'R'


  ) is
  cursor c1 is select rowid from PSB_POSITION_PAY_DISTRIBUTIONS
     where position_id = p_position_id
  ;
  dummy c1%rowtype;
--
l_api_name    CONSTANT VARCHAR2(30) := 'Add Row' ;
l_api_version CONSTANT NUMBER := 1.0 ;
--
BEGIN
  --
  SAVEPOINT Add_Row ;
  --
  -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     p_api_version => p_api_version,
     p_init_msg_list => p_init_msg_list,
     p_commit => p_commit,
     p_validation_level => p_validation_level,
     p_return_status => p_return_status,
     p_msg_count => p_msg_count,
     p_msg_data => p_msg_data,
     p_rowid => p_rowid,
     p_distribution_id => p_distribution_id,
     p_position_id => p_position_id,
     p_data_extract_id => p_data_extract_id,
     p_worksheet_id => p_worksheet_id,
     p_effective_start_date => p_effective_start_date,
     p_effective_end_date => p_effective_end_date,
     p_chart_of_accounts_id => p_chart_of_accounts_id,
     p_code_combination_id => p_code_combination_id,
     p_distribution_percent => p_distribution_percent,
     p_global_default_flag => p_global_default_flag,
     p_distribution_default_rule_id => p_distribution_default_rule_id,
     p_project_id  => p_project_id,
     p_task_id => p_task_id,
     p_award_id  => p_award_id,
     p_expenditure_type  => p_expenditure_type,
     p_expenditure_organization_id  => p_expenditure_organization_id,
     p_description => p_description,
     p_mode => p_mode
     );
    --
    if FND_API.to_Boolean (p_commit) then
       commit work;
    end if;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			       p_data  => p_msg_data);

    return;
  END if;
  close c1;
  UPDATE_ROW (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_validation_level => p_validation_level,
   p_return_status => p_return_status,
   p_msg_count => p_msg_count,
   p_msg_data => p_msg_data,
   p_distribution_id => p_distribution_id,
   p_code_combination_id => p_code_combination_id,
   p_effective_start_date => p_effective_start_date,
   p_effective_end_date => p_effective_end_date,
   p_distribution_percent => p_distribution_percent,
   p_global_default_flag => p_global_default_flag,
   p_distribution_default_rule_id => p_distribution_default_rule_id,
   p_project_id  => p_project_id,
   p_task_id => p_task_id,
   p_award_id  => p_award_id,
   p_expenditure_type  => p_expenditure_type,
   p_expenditure_organization_id  => p_expenditure_organization_id,
   p_description => p_description,
   p_mode => p_mode
   );
  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

END ADD_ROW;
--
PROCEDURE DELETE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_distribution_id     in number
) is
--
l_api_name    CONSTANT VARCHAR2(30) := 'Delete Row' ;
l_api_version CONSTANT NUMBER := 1.0 ;

l_return_status        VARCHAR2(1);
--
BEGIN
  --
  SAVEPOINT Delete_Row ;
  --
  -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  --
  delete from PSB_POSITION_PAY_DISTRIBUTIONS
  where distribution_id = p_distribution_id;
  if (sql%notfound) THEN
   null;
  end if;

  -- Standard check of p_commit.
  --
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);
  --
EXCEPTION
   when FND_API.G_EXC_ERROR then
     --
     rollback to Delete_Row;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to Delete_Row;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to Delete_Row ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
END DELETE_ROW;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_Distributions
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_data_extract_id   IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30) := 'Delete_Distributions';
  l_api_version       CONSTANT NUMBER       := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Delete_Distributions_Pvt;


  -- Standard call to check for call compatibility

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

  delete from PSB_POSITION_PAY_DISTRIBUTIONS
   where data_extract_id = p_data_extract_id;


  -- Standard check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Delete_Distributions_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Delete_Distributions_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then
     rollback to Delete_Distributions_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Delete_Distributions;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_Distributions_Position
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_position_id       IN   NUMBER,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30) := 'Delete_Distributions_Position';
  l_api_version       CONSTANT NUMBER       := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Delete_Dist_Position_Pvt;


  -- Standard call to check for call compatibility

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

  DELETE from PSB_POSITION_PAY_DISTRIBUTIONS
   WHERE position_id = p_position_id
     /* Bug 4545909 Start */
     AND ((worksheet_id IS NULL AND p_worksheet_id IS NULL)
               OR worksheet_id = p_worksheet_id);
     /* Bug 4545909 End */


  -- Standard check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Delete_Dist_Position_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Delete_Dist_Position_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then
     rollback to Delete_Dist_Position_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Delete_Distributions_Position;

/* ----------------------------------------------------------------------- */

PROCEDURE Modify_Distribution_WS
( p_api_version                   IN      NUMBER,
  p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                 OUT  NOCOPY     VARCHAR2,
  p_msg_count                     OUT  NOCOPY     NUMBER,
  p_msg_data                      OUT  NOCOPY     VARCHAR2,
  p_distribution_id               IN OUT  NOCOPY  NUMBER,
  p_worksheet_id                  IN      NUMBER := FND_API.G_MISS_NUM,
  p_position_id                   IN      NUMBER,
  p_data_extract_id               IN      NUMBER,
  p_effective_start_date          IN      DATE,
  p_effective_end_date            IN      DATE,
  p_modify_flag                   IN      VARCHAR2,
  p_chart_of_accounts_id          IN      NUMBER,
  p_code_combination_id           IN      NUMBER,
  p_distribution_percent          IN      NUMBER,
  p_global_default_flag           IN      VARCHAR2,
  p_distribution_default_rule_id  IN      NUMBER,
  p_rowid                         IN OUT  NOCOPY  VARCHAR2,
  p_project_id                    IN      NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                       IN      NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                      IN      NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type              IN      VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id   IN      NUMBER:= FND_API.G_MISS_NUM,
  p_description                   IN      VARCHAR2:= FND_API.G_MISS_CHAR,
  p_budget_revision_pos_line_id   IN      NUMBER:= FND_API.G_MISS_NUM,
  p_mode                          IN      VARCHAR2 := 'R',
  p_ruleset_id                    IN      NUMBER -- 1308558
) IS

  l_api_name                      CONSTANT VARCHAR2(30) := 'Modify_Distribution_WS';
  l_api_version                   CONSTANT NUMBER       := 1.0;

  l_budget_calendar_id            NUMBER;
  l_budget_group_id               NUMBER;

  l_name                          VARCHAR2(80);
  l_set_of_books_id               NUMBER;
  l_flex_code                     NUMBER;

  l_concat_segments               VARCHAR2(2000);
  l_ccid_valid                    VARCHAR2(1) := FND_API.G_FALSE;

  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(2000);

  l_out_ccid                      NUMBER;
  l_out_budget_group_id           NUMBER;
  l_rv_start_date                 DATE;
  l_rv_end_date                   DATE;
  l_return_status                 VARCHAR2(1);
  l_rev_budget_group_id           NUMBER;
  l_data_extract_id               NUMBER;

  cursor c_WS is
    select budget_calendar_id,
	   budget_group_id
      from PSB_WORKSHEETS_V
     where worksheet_id = p_worksheet_id;

  cursor c_BG is
    select name,
	   nvl(set_of_books_id, root_set_of_books_id) set_of_books_id,
	   nvl(chart_of_accounts_id, root_chart_of_accounts_id) flex_code
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = l_budget_group_id;

/* -- Commented out for Bug: 3325171
   -- since we are going to use the Start Date from the
   -- revision-level and not from the position-level

  cursor c_RV_pos is
    select effective_start_date
      from psb_positions
     where position_id = p_position_id;
*/

  cursor c_RV_rev is
    select effective_end_date,
           effective_start_date
      from psb_budget_revision_positions
     where budget_revision_pos_line_id = p_budget_revision_pos_line_id;

  cursor c_rev IS
	 SELECT budget_group_id
	   FROM psb_budget_revisions
	  WHERE budget_revision_id = p_worksheet_id;

  CURSOR c_data_extract is
	 SELECT set_of_books_id   ,
		position_id_flex_num
	 FROM   psb_data_extracts
	 WHERE  data_extract_id = l_data_extract_id ;
BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Modify_Distribution_WS_Pvt;


  -- Standard call to check for call compatibility

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

  if nvl(p_worksheet_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
    l_ccid_valid := FND_API.G_TRUE;
  else


  if p_budget_revision_pos_line_id   <> FND_API.G_MISS_NUM   then
     -- budget revision

     begin

        /* -- Commented out for Bug: 3325171
           -- since we are going to use the Start Date from the
           -- revision-level and not from the position-level

	for c_RV_pos_rec in c_RV_pos loop
	   l_rv_start_date := c_RV_pos_rec.effective_start_date;
	end loop;

        */

	for c_RV_rev_rec in c_RV_rev loop
           l_rv_start_date := c_RV_rev_rec.effective_start_date;
	   l_rv_end_date := c_RV_rev_rec.effective_end_date;
	end loop;

	FOR c_rev_rec in c_rev loop
	   l_rev_budget_group_id := c_rev_rec.budget_group_id;  -- get rev's bg
	END LOOP;


	 -- then find the data extract id; api will get the top level bg
	 l_data_extract_id := PSB_BUDGET_REVISIONS_PVT.Find_System_Data_Extract
			    (p_budget_group_id => l_rev_budget_group_id);

	for c_data_extract_rec in c_data_extract loop

	    l_set_of_books_id := c_data_extract_rec.set_of_books_id;

        -- Fix for Bug: 3325171 - start ...
        --  l_flex_code       := c_data_extract_rec.position_id_flex_num;

            select chart_of_accounts_id
            into l_flex_code
            from GL_SETS_OF_BOOKS
	    where set_of_books_id = l_set_of_books_id;

	    select name
	    into l_name
	    from PSB_BUDGET_GROUPS_V
	    where budget_group_id = l_rev_budget_group_id;

        -- Fix for Bug: 3325171 - ... end

	end loop;


	PSB_VALIDATE_ACCT_PVT.Validate_Account
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_parent_budget_group_id => l_rev_budget_group_id,
	    p_startdate_pp => l_rv_start_date,
	    p_enddate_cy => l_rv_end_date,
	    p_create_budget_account => FND_API.G_TRUE,
	    p_set_of_books_id => l_set_of_books_id,
	    p_flex_code => l_flex_code,
	    p_in_ccid => p_code_combination_id,
	    p_out_ccid => l_out_ccid,
	    p_budget_group_id => l_out_budget_group_id    );

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then

	   l_concat_segments := FND_FLEX_EXT.Get_Segs
			      (application_short_name => 'SQLGL',
			       key_flex_code => 'GL#',
			       structure_number => l_flex_code,
			       combination_id => p_code_combination_id);

	   message_token('CCID', l_concat_segments);
	   message_token('BUDGET_GROUP', l_name);
	   add_message('PSB', 'PSB_CCID_NOTIN_BUDGET_GROUP');

	   l_ccid_valid := FND_API.G_FALSE;

	 else
	   l_ccid_valid := FND_API.G_TRUE;
	 end if;

     end;  -- of rev

  else

  begin
    -- ws

    for c_WS_Rec in c_WS loop
      l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
      l_budget_group_id := c_WS_Rec.budget_group_id;
    end loop;

    for c_BG_Rec in c_BG loop
      l_name := c_BG_Rec.name;
      l_set_of_books_id := c_BG_Rec.set_of_books_id;
      l_flex_code := c_BG_Rec.flex_code;
    end loop;

    if l_budget_calendar_id <> nvl(PSB_WS_ACCT1.g_budget_calendar_id, FND_API.G_MISS_NUM) then
    begin

      PSB_WS_ACCT1.Cache_Budget_Calendar
	 (p_return_status => l_return_status,
	  p_budget_calendar_id => l_budget_calendar_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

    PSB_VALIDATE_ACCT_PVT.Validate_Account
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_msg_count => l_msg_count,
	p_msg_data => l_msg_data,
	p_parent_budget_group_id => l_budget_group_id,
	p_startdate_pp => PSB_WS_ACCT1.g_startdate_pp,
	p_enddate_cy => PSB_WS_ACCT1.g_enddate_cy,
	p_create_budget_account => FND_API.G_TRUE,
	p_set_of_books_id => l_set_of_books_id,
	p_flex_code => l_flex_code,
	p_in_ccid => p_code_combination_id,
	p_out_ccid => l_out_ccid,
	p_budget_group_id => l_out_budget_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    begin

      l_concat_segments := FND_FLEX_EXT.Get_Segs
			      (application_short_name => 'SQLGL',
			       key_flex_code => 'GL#',
			       structure_number => l_flex_code,
			       combination_id => p_code_combination_id);

      message_token('CCID', l_concat_segments);
      message_token('BUDGET_GROUP', l_name);
      add_message('PSB', 'PSB_CCID_NOTIN_BUDGET_GROUP');

      l_ccid_valid := FND_API.G_FALSE;

    end;
    else
      l_ccid_valid := FND_API.G_TRUE;
    end if;

  end;
  end if;
  end if;

  if FND_API.to_Boolean(l_ccid_valid) then
  begin

  -- 1308558. Mass Position Assignment Rules
  IF p_ruleset_id IS NULL THEN
    Modify_Distribution
	  (p_api_version => 1.0,
	   p_return_status => l_return_status,
	   p_msg_count => p_msg_count,
	   p_msg_data => p_msg_data,
	   p_distribution_id => p_distribution_id,
	   p_position_id => p_position_id,
	   p_data_extract_id => p_data_extract_id,
	   p_worksheet_id => p_worksheet_id,
	   p_effective_start_date => p_effective_start_date,
	   p_effective_end_date => p_effective_end_date,
	   p_chart_of_accounts_id => p_chart_of_accounts_id,
	   p_code_combination_id => p_code_combination_id,
	   p_distribution_percent => p_distribution_percent,
	   p_global_default_flag => p_global_default_flag,
	   p_distribution_default_rule_id => p_distribution_default_rule_id,
	   p_project_id  => p_project_id,
	   p_task_id => p_task_id,
	   p_award_id  => p_award_id,
	   p_expenditure_type  => p_expenditure_type,
	   p_expenditure_organization_id  => p_expenditure_organization_id,
	   p_description => p_description,
	   p_rowid => p_rowid,
	   p_mode => p_mode);

  ELSE

    Apply_Position_Pay_Distr
	  (p_api_version => 1.0,
	   x_return_status => l_return_status,
	   x_msg_count => p_msg_count,
	   x_msg_data => p_msg_data,
	   p_distribution_id => p_distribution_id,
	   p_position_id => p_position_id,
	   p_data_extract_id => p_data_extract_id,
	   p_worksheet_id => p_worksheet_id,
	   p_effective_start_date => p_effective_start_date,
	   p_effective_end_date => p_effective_end_date,
           p_modify_flag => p_modify_flag,
	   p_chart_of_accounts_id => p_chart_of_accounts_id,
	   p_code_combination_id => p_code_combination_id,
	   p_distribution_percent => p_distribution_percent,
	   p_global_default_flag => p_global_default_flag,
	   p_distribution_default_rule_id => p_distribution_default_rule_id,
	   p_project_id  => p_project_id,
	   p_task_id => p_task_id,
	   p_award_id  => p_award_id,
	   p_expenditure_type  => p_expenditure_type,
	   p_expenditure_organization_id  => p_expenditure_organization_id,
	   p_description => p_description,
	   p_rowid => p_rowid,
	   p_mode => p_mode);
 END IF;
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  -- Added for Bug: 3325171
  else
    raise FND_API.G_EXC_ERROR;
  end if;


  -- Standard check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Modify_Distribution_WS_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Modify_Distribution_WS_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then
     rollback to Modify_Distribution_WS_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Modify_Distribution_WS;

/* ----------------------------------------------------------------------- */

PROCEDURE Modify_Distribution
( p_api_version                   IN      NUMBER,
  p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                 OUT  NOCOPY     VARCHAR2,
  p_msg_count                     OUT  NOCOPY     NUMBER,
  p_msg_data                      OUT  NOCOPY     VARCHAR2,
  p_distribution_id               IN OUT  NOCOPY  NUMBER,
  p_position_id                   IN      NUMBER,
  p_data_extract_id               IN      NUMBER,
  p_worksheet_id                  IN      NUMBER := FND_API.G_MISS_NUM,
  p_effective_start_date          IN      DATE,
  p_effective_end_date            IN      DATE,
  p_chart_of_accounts_id          IN      NUMBER,
  p_code_combination_id           IN      NUMBER,
  p_distribution_percent          IN      NUMBER,
  p_global_default_flag           IN      VARCHAR2,
  p_distribution_default_rule_id  IN      NUMBER,
  p_rowid                         IN OUT  NOCOPY  VARCHAR2,
  p_project_id                    IN      NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                       IN      NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                      IN      NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type              IN      VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id   IN      NUMBER:= FND_API.G_MISS_NUM,
  p_description                   IN      VARCHAR2:= FND_API.G_MISS_CHAR,
  p_mode                          IN      VARCHAR2 := 'R'
) IS

  l_api_name                      CONSTANT VARCHAR2(30) := 'Modify_Distribution';
  l_api_version                   CONSTANT NUMBER       := 1.0;

  l_userid                        NUMBER;
  l_loginid                       NUMBER;

  l_init_index                    BINARY_INTEGER;
  l_dist_index                    BINARY_INTEGER;

  l_distribution_id               NUMBER;

  l_created_record                VARCHAR2(1) := FND_API.G_FALSE;
  l_updated_record                VARCHAR2(1);

  l_rowid                         VARCHAR2(100);

  l_return_status                 VARCHAR2(1);
  l_dis_overlap                   VARCHAR2(1):= FND_API.G_FALSE;

  cursor c_Seq is
    select psb_position_pay_distr_s.nextval DistID
      from dual;

  cursor c_Dist is
    select distribution_id,
	   position_id,
	   data_extract_id,
	   worksheet_id,
	   effective_start_date,
	   effective_end_date,
	   chart_of_accounts_id,
	   code_combination_id,
	   distribution_percent,
	   global_default_flag,
	   distribution_default_rule_id,
	   project_id,
	   task_id,
	   award_id,
	   expenditure_type,
	   expenditure_organization_id,
	   description
      from PSB_POSITION_PAY_DISTRIBUTIONS
     where (worksheet_id is null or worksheet_id = p_worksheet_id)
       and chart_of_accounts_id = p_chart_of_accounts_id
       and code_combination_id = p_code_combination_id
       and (((p_effective_end_date is not null)
	 and (((effective_start_date <= p_effective_end_date)
	   and (effective_end_date is null))
	   or ((effective_start_date between p_effective_start_date and p_effective_end_date)
	   or (effective_end_date between p_effective_start_date and p_effective_end_date)
	   or ((effective_start_date < p_effective_start_date)
	   and (effective_end_date > p_effective_end_date)))))
	or ((p_effective_end_date is null)
	and (nvl(effective_end_date, p_effective_start_date) >= p_effective_start_date)))
       and position_id = p_position_id;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Modify_Distribution_Pvt;


  -- Standard call to check for call compatibility

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

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  update PSB_POSITION_PAY_DISTRIBUTIONS
     set distribution_percent = decode(p_distribution_percent, null, distribution_percent, p_distribution_percent),
	 global_default_flag = decode(p_global_default_flag, null, global_default_flag, p_global_default_flag),
	 distribution_default_rule_id = decode(p_distribution_default_rule_id, null, distribution_default_rule_id, p_distribution_default_rule_id),
	 project_id = decode(p_project_id, null, project_id, FND_API.G_MISS_NUM, project_id, p_project_id),
	 task_id = decode(p_task_id, null, project_id, FND_API.G_MISS_NUM, task_id, p_task_id),
	 award_id = decode(p_award_id, null, award_id, FND_API.G_MISS_NUM, award_id, p_award_id),
	 expenditure_type = decode(p_expenditure_type, null, expenditure_type, FND_API.G_MISS_CHAR, expenditure_type, p_expenditure_type),
	 expenditure_organization_id = decode(p_expenditure_organization_id, null, expenditure_organization_id, FND_API.G_MISS_NUM, expenditure_organization_id, p_expenditure_organization_id),
	 description = decode(p_description, null, description, FND_API.G_MISS_CHAR, description, p_description),
-- Added for Bug: 3325171
	 effective_end_date = decode(p_effective_end_date, null, effective_end_date, FND_API.G_MISS_DATE, effective_end_date, p_effective_end_date),
	 last_update_date = sysdate,
	 last_updated_by = l_userid,
	 last_update_login = l_loginid
   where position_id = p_position_id
     and effective_start_date = p_effective_start_date
     and nvl(effective_end_date, FND_API.G_MISS_DATE) = nvl(p_effective_end_date, FND_API.G_MISS_DATE)
     and nvl(worksheet_id, FND_API.G_MISS_NUM) = nvl(p_worksheet_id, FND_API.G_MISS_NUM)
     and chart_of_accounts_id = p_chart_of_accounts_id
     and code_combination_id = p_code_combination_id;

  if SQL%NOTFOUND then
  begin

    for l_init_index in 1..g_pay_dist.Count loop
      g_pay_dist(l_init_index).distribution_id := null;
      g_pay_dist(l_init_index).position_id := null;
      g_pay_dist(l_init_index).data_extract_id := null;
      g_pay_dist(l_init_index).worksheet_id := null;
      g_pay_dist(l_init_index).effective_start_date := null;
      g_pay_dist(l_init_index).effective_end_date := null;
      g_pay_dist(l_init_index).chart_of_accounts_id := null;
      g_pay_dist(l_init_index).code_combination_id := null;
      g_pay_dist(l_init_index).distribution_percent := null;
      g_pay_dist(l_init_index).global_default_flag := null;
      g_pay_dist(l_init_index).dist_default_rule_id := null;
      g_pay_dist(l_init_index).project_id := null;
      g_pay_dist(l_init_index).task_id:= null;
      g_pay_dist(l_init_index).award_id:= null;
      g_pay_dist(l_init_index).expenditure_type:= null;
      g_pay_dist(l_init_index).expenditure_organization_id:= null;
      g_pay_dist(l_init_index).description:= null;
      g_pay_dist(l_init_index).delete_flag := null;
    end loop;

    g_num_pay_dist := 0;

    for c_Dist_Rec in c_Dist loop

      g_num_pay_dist := g_num_pay_dist + 1;

      g_pay_dist(g_num_pay_dist).distribution_id := c_Dist_Rec.distribution_id;
      g_pay_dist(g_num_pay_dist).position_id := c_Dist_Rec.position_id;
      g_pay_dist(g_num_pay_dist).data_extract_id := c_Dist_Rec.data_extract_id;
      g_pay_dist(g_num_pay_dist).worksheet_id := c_Dist_Rec.worksheet_id;
      g_pay_dist(g_num_pay_dist).effective_start_date := c_Dist_Rec.effective_start_date;
      g_pay_dist(g_num_pay_dist).effective_end_date := c_Dist_Rec.effective_end_date;
      g_pay_dist(g_num_pay_dist).chart_of_accounts_id := c_Dist_Rec.chart_of_accounts_id;
      g_pay_dist(g_num_pay_dist).code_combination_id := c_Dist_Rec.code_combination_id;
      g_pay_dist(g_num_pay_dist).distribution_percent := c_Dist_Rec.distribution_percent;
      g_pay_dist(g_num_pay_dist).global_default_flag := c_Dist_Rec.global_default_flag;
      g_pay_dist(g_num_pay_dist).dist_default_rule_id := c_Dist_Rec.distribution_default_rule_id;
      g_pay_dist(g_num_pay_dist).project_id := c_Dist_Rec.project_id;
      g_pay_dist(g_num_pay_dist).task_id:= c_Dist_Rec.task_id;
      g_pay_dist(g_num_pay_dist).award_id:= c_Dist_Rec.award_id;
      g_pay_dist(g_num_pay_dist).expenditure_type:= c_Dist_Rec.expenditure_type;
      g_pay_dist(g_num_pay_dist).expenditure_organization_id:=  c_Dist_Rec.expenditure_organization_id;
      g_pay_dist(g_num_pay_dist).description:= c_Dist_Rec.description;
      g_pay_dist(g_num_pay_dist).delete_flag := FND_API.G_TRUE;

      if g_pay_dist(g_num_pay_dist).worksheet_id = p_worksheet_id then
      begin

	if not FND_API.to_Boolean(l_dis_overlap) then
	  l_dis_overlap := FND_API.G_TRUE;
	end if;

      end;
      end if;

    end loop;

    if g_num_pay_dist = 0 then -- No matching records hence direct insert
    begin

      for c_Seq_Rec in c_Seq loop
	l_distribution_id := c_Seq_Rec.DistID;
      end loop;

      Insert_Row
	    (p_api_version => 1.0,
	     p_return_status => l_return_status,
	     p_msg_count => p_msg_count,
	     p_msg_data => p_msg_data,
	     p_rowid => l_rowid,
	     p_distribution_id => l_distribution_id,
	     p_position_id => p_position_id,
	     p_data_extract_id => p_data_extract_id,
	     p_worksheet_id => p_worksheet_id,
	     p_effective_start_date => p_effective_start_date,
	     p_effective_end_date => p_effective_end_date,
	     p_chart_of_accounts_id => p_chart_of_accounts_id,
	     p_code_combination_id => p_code_combination_id,
	     p_distribution_percent => p_distribution_percent,
	     p_global_default_flag => p_global_default_flag,
	     p_distribution_default_rule_id => p_distribution_default_rule_id,
	     p_project_id  => p_project_id,
	     p_task_id => p_task_id,
	     p_award_id  => p_award_id,
	     p_expenditure_type  => p_expenditure_type,
	     p_expenditure_organization_id  => p_expenditure_organization_id,
	     p_description => p_description,
	     p_mode => p_mode);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      p_rowid := l_rowid;
      p_distribution_id := l_distribution_id;

    end; -- No Matching Records hence Direct Insert
    else
    begin -- Matching Records Check for different overlaps

      for l_dist_index in 1..g_num_pay_dist loop

	l_updated_record := FND_API.G_FALSE;

	if (g_pay_dist(l_dist_index).effective_start_date = p_effective_start_date)  then
	begin

	  if nvl(g_pay_dist(l_dist_index).worksheet_id,FND_API.G_MISS_NUM) = nvl(p_worksheet_id,FND_API.G_MISS_NUM) then
	  begin

	    Update_Row
		(p_api_version => 1.0,
		 p_return_status => l_return_status,
		 p_msg_count => p_msg_count,
		 p_msg_data => p_msg_data,
		 p_distribution_id => g_pay_dist(l_dist_index).distribution_id,
		 p_code_combination_id => p_code_combination_id,
		 p_distribution_percent => p_distribution_percent,
		 p_effective_end_date => p_effective_end_date,
		 p_global_default_flag => p_global_default_flag,
		 p_distribution_default_rule_id => p_distribution_default_rule_id,
		 p_project_id  => p_project_id,
		 p_task_id => p_task_id,
		 p_award_id  => p_award_id,
		 p_expenditure_type  => p_expenditure_type,
		 p_expenditure_organization_id  => p_expenditure_organization_id,
		 p_description => p_description,
		 p_mode => p_mode);

	     if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	       raise FND_API.G_EXC_ERROR;
	     end if;

	     g_pay_dist(l_dist_index).delete_flag := FND_API.G_FALSE;

	  end;
	  elsif ((g_pay_dist(l_dist_index).worksheet_id is null) and (p_worksheet_id is not null) and
		 (not FND_API.to_Boolean(l_dis_overlap))) then
	  begin

	    for c_Seq_Rec in c_Seq loop
	      l_distribution_id := c_Seq_Rec.DistID;
	    end loop;

	    Insert_Row
		  (p_api_version => 1.0,
		   p_return_status => l_return_status,
		   p_msg_count => p_msg_count,
		   p_msg_data => p_msg_data,
		   p_rowid => l_rowid,
		   p_distribution_id => l_distribution_id,
		   p_position_id => p_position_id,
		   p_data_extract_id => p_data_extract_id,
		   p_worksheet_id => p_worksheet_id,
		   p_effective_start_date => p_effective_start_date,
		   p_effective_end_date => p_effective_end_date,
		   p_chart_of_accounts_id => p_chart_of_accounts_id,
		   p_code_combination_id => p_code_combination_id,
		   p_distribution_percent => p_distribution_percent,
		   p_global_default_flag => p_global_default_flag,
		   p_distribution_default_rule_id => p_distribution_default_rule_id,
		   p_project_id  => p_project_id,
		   p_task_id => p_task_id,
		   p_award_id  => p_award_id,
		   p_expenditure_type  => p_expenditure_type,
		   p_expenditure_organization_id  => p_expenditure_organization_id,
		   p_description => p_description,
		   p_mode => p_mode);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	    p_rowid := l_rowid;
	    p_distribution_id := l_distribution_id;

	  end;
	  end if;

	end;-- end of effective start date matches
	--effective dates overlap
	elsif (((g_pay_dist(l_dist_index).effective_start_date <= (p_effective_start_date - 1)) and
	       ((g_pay_dist(l_dist_index).effective_end_date is null) or
		(g_pay_dist(l_dist_index).effective_end_date > (p_effective_start_date - 1)))) or
	       ((g_pay_dist(l_dist_index).effective_start_date > p_effective_start_date) and
	       ((g_pay_dist(l_dist_index).effective_end_date is null) or
		(g_pay_dist(l_dist_index).effective_end_date > (p_effective_end_date + 1))))) then
	begin

	  if ((nvl(g_pay_dist(l_dist_index).worksheet_id, FND_API.G_MISS_NUM) = nvl(p_worksheet_id, FND_API.G_MISS_NUM))) then
	  begin
		--++ both either base or ws specific rec

	    if ((g_pay_dist(l_dist_index).effective_start_date < (p_effective_start_date - 1)) and
	       ((g_pay_dist(l_dist_index).effective_end_date is null) or
		(g_pay_dist(l_dist_index).effective_end_date > (p_effective_start_date - 1)))) then
	    begin

	      Update_Row
		  (p_api_version => 1.0,
		   p_return_status => l_return_status,
		   p_msg_count => p_msg_count,
		   p_msg_data => p_msg_data,
		   p_distribution_id => g_pay_dist(l_dist_index).distribution_id,
		   p_code_combination_id => g_pay_dist(l_dist_index).code_combination_id,
		   p_distribution_percent => g_pay_dist(l_dist_index).distribution_percent,
		   p_effective_end_date => p_effective_start_date - 1,
		   p_global_default_flag => g_pay_dist(l_dist_index).global_default_flag,
		   p_distribution_default_rule_id => g_pay_dist(l_dist_index).dist_default_rule_id,
		   p_project_id  => g_pay_dist(l_dist_index).project_id,
		   p_task_id => g_pay_dist(l_dist_index).task_id,
		   p_award_id  => g_pay_dist(l_dist_index).award_id,
		   p_expenditure_type  => g_pay_dist(l_dist_index).expenditure_type,
		   p_expenditure_organization_id  => g_pay_dist(l_dist_index).expenditure_organization_id,
		   p_description  => g_pay_dist(l_dist_index).description,
		   p_mode => p_mode);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      else
		l_updated_record := FND_API.G_TRUE;
	      end if;

	      g_pay_dist(l_dist_index).delete_flag := FND_API.G_FALSE;

	    end; --
	    elsif ((g_pay_dist(l_dist_index).effective_start_date > p_effective_start_date) and
		  ((p_effective_end_date is not null) and
		  ((g_pay_dist(l_dist_index).effective_end_date is null) or
		   (g_pay_dist(l_dist_index).effective_end_date > (p_effective_end_date + 1))))) then
	    begin

	      Update_Row
		    (p_api_version => 1.0,
		     p_return_status => l_return_status,
		     p_msg_count => p_msg_count,
		     p_msg_data => p_msg_data,
		     p_distribution_id => g_pay_dist(l_dist_index).distribution_id,
		     p_code_combination_id => g_pay_dist(l_dist_index).code_combination_id,
		     p_distribution_percent => g_pay_dist(l_dist_index).distribution_percent,
		     p_effective_start_date => p_effective_end_date + 1,
		     p_global_default_flag => g_pay_dist(l_dist_index).global_default_flag,
		     p_distribution_default_rule_id => g_pay_dist(l_dist_index).dist_default_rule_id,
		     p_project_id  => g_pay_dist(l_dist_index).project_id,
		     p_task_id => g_pay_dist(l_dist_index).task_id,
		     p_award_id  => g_pay_dist(l_dist_index).award_id,
		     p_expenditure_type => g_pay_dist(l_dist_index).expenditure_type,
		     p_expenditure_organization_id  => g_pay_dist(l_dist_index).expenditure_organization_id,
		     p_description  => g_pay_dist(l_dist_index).description,
		     p_mode => p_mode);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      else
		l_updated_record := FND_API.G_FALSE;
	      end if;

	      g_pay_dist(l_dist_index).delete_flag := FND_API.G_FALSE;

	    end;
	    end if; -- end start date test

	    if not FND_API.to_Boolean(l_created_record) then
	    begin

	      for c_Seq_Rec in c_Seq loop
		l_distribution_id := c_Seq_Rec.DistID;
	      end loop;

	      Insert_Row
		    (p_api_version => 1.0,
		     p_return_status => l_return_status,
		     p_msg_count => p_msg_count,
		     p_msg_data => p_msg_data,
		     p_rowid => l_rowid,
		     p_distribution_id => l_distribution_id,
		     p_position_id => p_position_id,
		     p_data_extract_id => p_data_extract_id,
		     p_worksheet_id => p_worksheet_id,
		     p_effective_start_date => p_effective_start_date,
		     p_effective_end_date => p_effective_end_date,
		     p_chart_of_accounts_id => p_chart_of_accounts_id,
		     p_code_combination_id => p_code_combination_id,
		     p_distribution_percent => p_distribution_percent,
		     p_global_default_flag => p_global_default_flag,
		     p_distribution_default_rule_id => p_distribution_default_rule_id,
		     p_project_id  => p_project_id,
		     p_task_id => p_task_id,
		     p_award_id  => p_award_id,
		     p_expenditure_type  => p_expenditure_type,
		     p_expenditure_organization_id  => p_expenditure_organization_id,
		     p_description => p_description,
		     p_mode => p_mode);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      else
		l_created_record := FND_API.G_TRUE;
	      end if;

	      p_rowid := l_rowid;
	      p_distribution_id := l_distribution_id;

	    end;
	    end if;

	    if p_effective_end_date is not null then
	    begin

	      if nvl(g_pay_dist(l_dist_index).effective_end_date, (p_effective_end_date + 1)) > (p_effective_end_date + 1) then
	      begin

		if FND_API.to_Boolean(l_updated_record) then
		begin

		  for c_Seq_Rec in c_Seq loop
		    l_distribution_id := c_Seq_Rec.DistID;
		  end loop;

		  Insert_Row
			(p_api_version => 1.0,
			 p_return_status => l_return_status,
			 p_msg_count => p_msg_count,
			 p_msg_data => p_msg_data,
			 p_rowid => l_rowid,
			 p_distribution_id => l_distribution_id,
			 p_position_id => g_pay_dist(l_dist_index).position_id,
			 p_data_extract_id => g_pay_dist(l_dist_index).data_extract_id,
			 p_worksheet_id => g_pay_dist(l_dist_index).worksheet_id,
			 p_effective_start_date => p_effective_end_date + 1,
			 p_effective_end_date => g_pay_dist(l_dist_index).effective_end_date,
			 p_chart_of_accounts_id => g_pay_dist(l_dist_index).chart_of_accounts_id,
			 p_code_combination_id => g_pay_dist(l_dist_index).code_combination_id,
			 p_distribution_percent => g_pay_dist(l_dist_index).distribution_percent,
			 p_global_default_flag => g_pay_dist(l_dist_index).global_default_flag,
			 p_distribution_default_rule_id => g_pay_dist(l_dist_index).dist_default_rule_id,
			 p_project_id  => g_pay_dist(l_dist_index).project_id,
			 p_task_id => g_pay_dist(l_dist_index).task_id,
			 p_award_id  => g_pay_dist(l_dist_index).award_id,
			 p_expenditure_type  => g_pay_dist(l_dist_index).expenditure_type,
			 p_expenditure_organization_id  => g_pay_dist(l_dist_index).expenditure_organization_id,
			 p_description  => g_pay_dist(l_dist_index).description,
			 p_mode => p_mode);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;

		  p_rowid := l_rowid;
		  p_distribution_id := l_distribution_id;

		end;
		else
		begin

		  Update_Row
			(p_api_version => 1.0,
			 p_return_status => l_return_status,
			 p_msg_count => p_msg_count,
			 p_msg_data => p_msg_data,
			 p_distribution_id => g_pay_dist(l_dist_index).distribution_id,
			 p_code_combination_id => g_pay_dist(l_dist_index).code_combination_id,
			 p_effective_start_date => p_effective_end_date + 1,
			 p_effective_end_date => g_pay_dist(l_dist_index).effective_end_date,
			 p_distribution_percent => g_pay_dist(l_dist_index).distribution_percent,
			 p_global_default_flag => g_pay_dist(l_dist_index).global_default_flag,
			 p_distribution_default_rule_id => g_pay_dist(l_dist_index).dist_default_rule_id,
			 p_project_id  => g_pay_dist(l_dist_index).project_id,
			 p_task_id => g_pay_dist(l_dist_index).task_id,
			 p_award_id  => g_pay_dist(l_dist_index).award_id,
			 p_expenditure_type  => g_pay_dist(l_dist_index).expenditure_type,
			 p_expenditure_organization_id  => g_pay_dist(l_dist_index).expenditure_organization_id,
			 p_description => g_pay_dist(l_dist_index).description,
			 p_mode => p_mode);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;

		  g_pay_dist(l_dist_index).delete_flag := FND_API.G_FALSE;

		end;
		end if;

	      end;
	      end if;

	    end;
	    end if;

	  end;
	  elsif ((g_pay_dist(l_dist_index).worksheet_id is null) and (p_worksheet_id is not null) and
		 (not FND_API.to_Boolean(l_dis_overlap))) then
	  begin

	    if ((g_pay_dist(l_dist_index).effective_start_date <= (p_effective_start_date - 1)) and
	       ((g_pay_dist(l_dist_index).effective_end_date is null) or
		(g_pay_dist(l_dist_index).effective_end_date > (p_effective_start_date - 1)))) then
	    begin

	      Modify_WS_Distribution
		   (p_return_status => l_return_status,
		    p_rowid         => p_rowid,
		    p_distribution_id => l_distribution_id,
		    p_position_id => p_position_id,
		    p_data_extract_id => p_data_extract_id,
		    p_worksheet_id => p_worksheet_id,
		    p_effective_start_date => g_pay_dist(l_dist_index).effective_start_date,
		    p_effective_end_date => p_effective_start_date -1,
		    p_chart_of_accounts_id => p_chart_of_accounts_id,
		    p_code_combination_id => p_code_combination_id,
		    p_distribution_percent => g_pay_dist(l_dist_index).distribution_percent,
		    p_global_default_flag => g_pay_dist(l_dist_index).global_default_flag,
		    p_distribution_default_rule_id => g_pay_dist(l_dist_index).dist_default_rule_id,
		    p_project_id  => g_pay_dist(l_dist_index).project_id,
		    p_task_id => g_pay_dist(l_dist_index).task_id,
		    p_award_id  => g_pay_dist(l_dist_index).award_id,
		    p_expenditure_type  => g_pay_dist(l_dist_index).expenditure_type,
		    p_expenditure_organization_id  => g_pay_dist(l_dist_index).expenditure_organization_id,
		    p_description => g_pay_dist(l_dist_index).description,
		    p_mode => p_mode);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	      p_rowid := l_rowid;
	      p_distribution_id := l_distribution_id;

	    end;
	    elsif ((g_pay_dist(l_dist_index).effective_start_date > p_effective_start_date) and
		  ((p_effective_end_date is not null) and
		  ((g_pay_dist(l_dist_index).effective_end_date is null) or
		   (g_pay_dist(l_dist_index).effective_end_date > (p_effective_end_date + 1))))) then
	    begin

	      Modify_WS_Distribution
		(p_return_status => l_return_status,
		 p_rowid         => p_rowid,
		 p_distribution_id => l_distribution_id,
		 p_position_id => p_position_id,
		 p_data_extract_id => p_data_extract_id,
		 p_worksheet_id => p_worksheet_id,
		 p_effective_start_date => p_effective_end_date + 1,
		 p_effective_end_date => g_pay_dist(l_dist_index).effective_end_date,
		 p_chart_of_accounts_id => p_chart_of_accounts_id,
		 p_code_combination_id => p_code_combination_id,
		 p_distribution_percent => g_pay_dist(l_dist_index).distribution_percent,
		 p_global_default_flag => g_pay_dist(l_dist_index).global_default_flag,
		 p_distribution_default_rule_id => g_pay_dist(l_dist_index).dist_default_rule_id,
		 p_project_id  => g_pay_dist(l_dist_index).project_id,
		 p_task_id => g_pay_dist(l_dist_index).task_id,
		 p_award_id  => g_pay_dist(l_dist_index).award_id,
		 p_expenditure_type  => g_pay_dist(l_dist_index).expenditure_type,
		 p_expenditure_organization_id  => g_pay_dist(l_dist_index).expenditure_organization_id,
		 p_description => g_pay_dist(l_dist_index).description,
		 p_mode => p_mode);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	      p_rowid := l_rowid;
	      p_distribution_id := l_distribution_id;

	    end;
	    end if;

	    if not FND_API.to_Boolean(l_created_record) then
	    begin

	      for c_Seq_Rec in c_Seq loop
		l_distribution_id := c_Seq_Rec.DistID;
	      end loop;

	      Insert_Row
		    (p_api_version => 1.0,
		     p_return_status => l_return_status,
		     p_msg_count => p_msg_count,
		     p_msg_data => p_msg_data,
		     p_rowid => l_rowid,
		     p_distribution_id => l_distribution_id,
		     p_position_id => p_position_id,
		     p_data_extract_id => p_data_extract_id,
		     p_worksheet_id => p_worksheet_id,
		     p_effective_start_date => p_effective_start_date,
		     p_effective_end_date => p_effective_end_date,
		     p_chart_of_accounts_id => p_chart_of_accounts_id,
		     p_code_combination_id => p_code_combination_id,
		     p_distribution_percent => p_distribution_percent,
		     p_global_default_flag => p_global_default_flag,
		     p_distribution_default_rule_id => p_distribution_default_rule_id,
		     p_project_id  => p_project_id,
		     p_task_id => p_task_id,
		     p_award_id  => p_award_id,
		     p_expenditure_type  => p_expenditure_type,
		     p_expenditure_organization_id  => p_expenditure_organization_id,
		     p_description => p_description,
		     p_mode => p_mode);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      else
		l_created_record := FND_API.G_TRUE;
	      end if;

	      p_rowid := l_rowid;
	      p_distribution_id := l_distribution_id;

	    end;
	    end if; -- end l_created_rec

	    if p_effective_end_date is not null then
	    begin

	      if nvl(g_pay_dist(l_dist_index).effective_end_date, (p_effective_end_date + 1)) > (p_effective_end_date + 1) then
	      begin

		Modify_WS_Distribution
		  (p_return_status => l_return_status,
		   p_rowid         => p_rowid,
		   p_distribution_id => l_distribution_id,
		   p_position_id => p_position_id,
		   p_data_extract_id => p_data_extract_id,
		   p_worksheet_id => p_worksheet_id,
		   p_effective_start_date => p_effective_end_date + 1,
		   p_effective_end_date => g_pay_dist(l_dist_index).effective_end_date,
		   p_chart_of_accounts_id => p_chart_of_accounts_id,
		   p_code_combination_id => p_code_combination_id,
		   p_distribution_percent => g_pay_dist(l_dist_index).distribution_percent,
		   p_global_default_flag => g_pay_dist(l_dist_index).global_default_flag,
		   p_distribution_default_rule_id => g_pay_dist(l_dist_index).dist_default_rule_id,
		   p_project_id  => g_pay_dist(l_dist_index).project_id,
		   p_task_id => g_pay_dist(l_dist_index).task_id,
		   p_award_id  => g_pay_dist(l_dist_index).award_id,
		   p_expenditure_type  => g_pay_dist(l_dist_index).expenditure_type,
		   p_expenditure_organization_id  => g_pay_dist(l_dist_index).expenditure_organization_id,
		   p_description => g_pay_dist(l_dist_index).description,
		   p_mode => p_mode);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

		p_rowid := l_rowid;
		p_distribution_id := l_distribution_id;

	      end;
	      end if;

	    end;
	    end if;

	  end; -- end effective date test
	  end if;

	end;
	end if;

      end loop;

    end;
    end if;

    for l_dist_index in 1..g_num_pay_dist loop

      if ((FND_API.to_Boolean(g_pay_dist(l_dist_index).delete_flag)) and (g_pay_dist(l_dist_index).worksheet_id is not null)) then
      begin

	Delete_Row
	      (p_api_version => 1.0,
	       p_return_status => l_return_status,
	       p_msg_count => p_msg_count,
	       p_msg_data => p_msg_data,
	       p_distribution_id => g_pay_dist(l_dist_index).distribution_id);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    end loop;

  end; -- SQL%NOTFOUND
  end if;

  -- Standard check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Modify_Distribution_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Modify_Distribution_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     rollback to Modify_Distribution_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Modify_Distribution;

-- +++

PROCEDURE Modify_WS_Distribution
( p_return_status                 OUT  NOCOPY     VARCHAR2,
  p_distribution_id               IN OUT  NOCOPY  NUMBER,
  p_position_id                   IN      NUMBER,
  p_data_extract_id               IN      NUMBER,
  p_worksheet_id                  IN      NUMBER := FND_API.G_MISS_NUM,
  p_effective_start_date          IN      DATE,
  p_effective_end_date            IN      DATE,
  p_chart_of_accounts_id          IN      NUMBER,
  p_code_combination_id           IN      NUMBER,
  p_distribution_percent          IN      NUMBER,
  p_global_default_flag           IN      VARCHAR2,
  p_distribution_default_rule_id  IN      NUMBER,
  p_rowid                         IN OUT  NOCOPY  VARCHAR2,
  p_project_id                    IN      NUMBER,
  p_task_id                       IN      NUMBER,
  p_award_id                      IN      NUMBER,
  p_expenditure_type              IN      VARCHAR2,
  p_expenditure_organization_id   IN      NUMBER,
  p_description                   IN      VARCHAR2 ,
  p_mode                          IN      VARCHAR2
) IS

  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);

  l_distribution_id         NUMBER;
  l_rowid                   VARCHAR2(100);
  l_distr_found             VARCHAR2(1) := FND_API.G_FALSE;

  cursor c_Seq is
    select psb_position_pay_distr_s.nextval DistID
      from dual;

  cursor c_overlap is
    select distribution_id
      from PSB_POSITION_PAY_DISTRIBUTIONS
     where chart_of_accounts_id = p_chart_of_accounts_id
       and worksheet_id = p_worksheet_id
       and code_combination_id = p_code_combination_id
       and (((p_effective_end_date is not null)
	 and (((effective_start_date <= p_effective_end_date)
	   and (effective_end_date is null))
	   or ((effective_start_date between p_effective_start_date and p_effective_end_date)
	   or (effective_end_date between p_effective_start_date and p_effective_end_date)
	   or ((effective_start_date < p_effective_start_date)
	   and (effective_end_date > p_effective_end_date)))))
	or ((p_effective_end_date is null)
	and (nvl(effective_end_date, p_effective_start_date) >= p_effective_start_date)))
       and position_id = p_position_id;

BEGIN

  for c_Overlap_Rec in c_Overlap loop
    l_distr_found := FND_API.G_TRUE;
  end loop;

  if not FND_API.to_Boolean(l_distr_found) then
  begin

    for c_Seq_Rec in c_Seq loop
      l_distribution_id := c_Seq_Rec.DistID;
    end loop;

    Insert_Row
	(p_api_version => 1.0,
	 p_return_status => l_return_status,
	 p_msg_count => l_msg_count,
	 p_msg_data => l_msg_data,
	 p_rowid => l_rowid,
	 p_distribution_id => l_distribution_id,
	 p_position_id => p_position_id,
	 p_data_extract_id => p_data_extract_id,
	 p_worksheet_id => p_worksheet_id,
	 p_effective_start_date => p_effective_start_date,
	 p_effective_end_date => p_effective_end_date,
	 p_chart_of_accounts_id => p_chart_of_accounts_id,
	 p_code_combination_id => p_code_combination_id,
	 p_distribution_percent => p_distribution_percent,
	 p_global_default_flag => p_global_default_flag,
	 p_distribution_default_rule_id => p_distribution_default_rule_id,
	 p_project_id  => p_project_id,
	 p_task_id => p_task_id,
	 p_award_id  => p_award_id,
	 p_expenditure_type  => p_expenditure_type,
	 p_expenditure_organization_id  => p_expenditure_organization_id,
	 p_description => p_description,
	 p_mode => p_mode  );

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    p_rowid := l_rowid;
    p_distribution_id := l_distribution_id;

  end;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Modify_WS_Distribution;

--+++

PROCEDURE Modify_Extract_Distribution
( p_api_version                   IN      NUMBER,
  p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status                 OUT  NOCOPY     VARCHAR2,
  p_msg_count                     OUT  NOCOPY     NUMBER,
  p_msg_data                      OUT  NOCOPY     VARCHAR2,
  p_position_id                   IN      NUMBER,
  p_data_extract_id               IN      NUMBER,
  p_chart_of_accounts_id          IN      NUMBER,
  p_distribution                  IN OUT  NOCOPY  PSB_HR_POPULATE_DATA_PVT.gl_distribution_tbl_type
) IS

  Cursor C_Distributions is
    Select distribution_id,
	   code_combination_id,
	   project_id,
	   task_id,
	   award_id,
	   expenditure_type,
	   expenditure_organization_id,
	   distribution_percent,
	   effective_start_date,
	   effective_end_date,
	   chart_of_accounts_id,
	   global_default_flag,
	   distribution_default_rule_id,
	   rowid
      from psb_position_pay_distributions
     where position_id = p_position_id
       and worksheet_id is null;

  cursor c_Seq is
    select psb_position_pay_distr_s.nextval DistID
      from dual;

  l_distribution_id               NUMBER;
  del_flag                        VARCHAR2(1);
  l_return_status                 VARCHAR2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(2000);
  l_rowid                         VARCHAR2(100);

  l_api_name                      CONSTANT VARCHAR2(30) := 'Modify_Extract_Distribution';
  l_api_version                   CONSTANT NUMBER       := 1.0;


BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Modify_Extract_Dist_Pvt;


  -- Standard call to check for call compatibility

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

  for C_Distribution_Rec in C_Distributions
  Loop
      del_flag := 'Y';
      for j in 1..p_distribution.count
      Loop
	 if (C_Distribution_Rec.code_combination_id is null) then
	    if ((C_Distribution_Rec.project_id = p_distribution(j).project_id) and
	       (C_Distribution_Rec.award_id = p_distribution(j).award_id) and
	       (C_Distribution_Rec.task_id = p_distribution(j).task_id) and
	       (C_Distribution_Rec.expenditure_type = p_distribution(j).expenditure_type) and
	       (C_Distribution_Rec.expenditure_organization_id = p_distribution(j).expenditure_org_id) and
	     (C_Distribution_Rec.effective_start_date = p_distribution(j).effective_start_date) ) then
	       del_flag := 'N';
	       p_distribution(j).exist_flag := 'Y';
	   end if;
	 else
	 if ((C_Distribution_Rec.code_combination_id = p_distribution(j).ccid) and
	     (C_Distribution_Rec.effective_start_date = p_distribution(j).effective_start_date) ) then
	    p_distribution(j).exist_flag := 'Y';
	    del_flag := 'N';
	 end if;
	 end if;

	 if ((del_flag = 'N') and (p_distribution(j).exist_flag = 'Y')) then
	    Update_Row
	    (p_api_version => 1.0,
	     p_return_status => l_return_status,
	     p_msg_count => p_msg_count,
	     p_msg_data => p_msg_data,
	     p_distribution_id =>  C_Distribution_Rec.distribution_id,
             /* Bug#2869982 Start */
	     p_code_combination_id   => p_distribution(j).ccid,
	     --p_code_combination_id => C_Distribution_Rec.code_combination_id,
             /* Bug#2869982 End */
	     p_distribution_percent => p_distribution(j).distr_percent,
	     p_effective_end_date => p_distribution(j).effective_end_date,
	     p_global_default_flag => C_Distribution_Rec.global_default_flag,
	     p_distribution_default_rule_id =>  C_Distribution_Rec.distribution_default_rule_id,
	     p_project_id  => p_distribution(j).project_id,
	     p_task_id => p_distribution(j).task_id,
	     p_award_id  => p_distribution(j).award_id,
	     p_expenditure_type  => p_distribution(j).expenditure_type,
	     p_expenditure_organization_id  => p_distribution(j).expenditure_org_id,
	     p_description => p_distribution(j).description,
	     p_mode => 'R');

	 if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	 end if;
	end if;
      End Loop;

      if (del_flag = 'Y') then
	  DELETE_ROW (
		  p_api_version         => 1.0,
		  p_init_msg_list       => fnd_api.g_false,
		  p_commit              => p_commit,
		  p_validation_level    => fnd_api.g_valid_level_full,
		  p_return_status       => l_return_status,
		  p_msg_count           => l_msg_count,
		  p_msg_data            => l_msg_data,
		  p_distribution_id     => C_Distribution_Rec.distribution_id);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;
      end if;
  End Loop;

  for j in 1..p_distribution.count
  Loop
    if (p_distribution(j).exist_flag <> 'Y') then
    /* Insert new distribution */
    for c_Seq_Rec in c_Seq loop
      l_distribution_id := c_Seq_Rec.DistID;
    end loop;

    Insert_Row
	  (p_api_version => 1.0,
	   p_return_status => l_return_status,
	   p_msg_count => p_msg_count,
	   p_msg_data => p_msg_data,
	   p_rowid => l_rowid,
	   p_distribution_id => l_distribution_id,
	   p_position_id => p_position_id,
	   p_data_extract_id => p_data_extract_id,
	   p_effective_start_date => p_distribution(j).effective_start_date,
	   p_effective_end_date => p_distribution(j).effective_end_date,
	   p_chart_of_accounts_id => p_chart_of_accounts_id,
	   p_code_combination_id => p_distribution(j).ccid,
	   p_distribution_percent => p_distribution(j).distr_percent,
	   p_global_default_flag => null,
	   p_distribution_default_rule_id => null,
	   p_project_id  => p_distribution(j).project_id,
	   p_task_id => p_distribution(j).task_id,
	   p_award_id  => p_distribution(j).award_id,
	   p_expenditure_type  => p_distribution(j).expenditure_type,
	   p_expenditure_organization_id  => p_distribution(j).expenditure_org_id,
	   p_description => p_distribution(j).description,
	   p_mode => 'R');

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    end if;
  End Loop;

  -- Standard check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Modify_Extract_Dist_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Modify_Extract_Dist_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then
     rollback to Modify_Extract_Dist_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Modify_Extract_Distribution;

/* ------------------------------------------------------------------------- */
-- Add Token and Value to the Message Token array

PROCEDURE message_token(tokname IN VARCHAR2,
			tokval  IN VARCHAR2) IS

BEGIN

  if no_msg_tokens is null then
    no_msg_tokens := 1;
  else
    no_msg_tokens := no_msg_tokens + 1;
  end if;

  msg_tok_names(no_msg_tokens) := tokname;
  msg_tok_val(no_msg_tokens) := tokval;

END message_token;

/* ----------------------------------------------------------------------- */

-- Define a Message Token with a Value and set the Message Name

-- Calls FND_MESSAGE server package to set the Message Stack. This message is
-- retrieved by the calling program.

PROCEDURE add_message(appname IN VARCHAR2,
		      msgname IN VARCHAR2) IS

  i  BINARY_INTEGER;

BEGIN

  if ((appname is not null) and
      (msgname is not null)) then

    FND_MESSAGE.SET_NAME(appname, msgname);

    if no_msg_tokens is not null then
      for i in 1..no_msg_tokens loop
	FND_MESSAGE.SET_TOKEN(msg_tok_names(i), msg_tok_val(i));
      end loop;
    end if;

    FND_MSG_PUB.Add;

  end if;

  -- Clear Message Token stack

  no_msg_tokens := 0;

END add_message;

/* ----------------------------------------------------------------------- */

  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for Funds Checker. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

  FUNCTION get_debug RETURN VARCHAR2 IS

  BEGIN

    return(g_dbug);

  END get_debug;

/* ----------------------------------------------------------------------- */

/* ----------------------------------------------------------------------- */
/* Bug 1308558 Start */
-- Mass position assignment rules enhancement
-- This api is used for applying default rule account distributions to various
-- positions

 PROCEDURE Apply_Position_Pay_Distr
( p_api_version                   IN      NUMBER,
  p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level              IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT  NOCOPY     VARCHAR2,
  x_msg_count                     OUT  NOCOPY     NUMBER,
  x_msg_data                      OUT  NOCOPY     VARCHAR2,
  p_distribution_id               IN OUT  NOCOPY  NUMBER,
  p_position_id                   IN      NUMBER,
  p_data_extract_id               IN      NUMBER,
  p_worksheet_id                  IN      NUMBER,
  p_effective_start_date          IN      DATE,
  p_effective_end_date            IN      DATE,
  p_modify_flag                   IN      VARCHAR2,
  p_chart_of_accounts_id          IN      NUMBER,
  p_code_combination_id           IN      NUMBER,
  p_distribution_percent          IN      NUMBER,
  p_global_default_flag           IN      VARCHAR2,
  p_distribution_default_rule_id  IN      NUMBER,
  p_rowid                         IN OUT  NOCOPY  VARCHAR2,
  p_project_id                    IN      NUMBER:= FND_API.G_MISS_NUM,
  p_task_id                       IN      NUMBER:= FND_API.G_MISS_NUM,
  p_award_id                      IN      NUMBER:= FND_API.G_MISS_NUM,
  p_expenditure_type              IN      VARCHAR2:= FND_API.G_MISS_CHAR,
  p_expenditure_organization_id   IN      NUMBER:= FND_API.G_MISS_NUM,
  p_description                   IN      VARCHAR2:= FND_API.G_MISS_CHAR,
  p_mode                          IN      VARCHAR2 := 'R'
) IS

  l_api_name                      CONSTANT VARCHAR2(30) := 'Apply_Position_Pay_Distr';
  l_api_version                   CONSTANT NUMBER       := 1.0;

  l_userid                        NUMBER;
  l_loginid                       NUMBER;

  l_init_index                    BINARY_INTEGER;
  l_dist_index                    BINARY_INTEGER;

  l_distribution_id               NUMBER;

  l_created_record                VARCHAR2(1) := FND_API.G_FALSE;
  l_updated_record                VARCHAR2(1);

  l_rowid                         VARCHAR2(100);

  l_return_status                 VARCHAR2(1);
  l_dis_overlap                   VARCHAR2(1):= FND_API.G_FALSE;
  l_dist_percent_sum              NUMBER;
  l_distribution_percent          NUMBER;
  l_ccid_exists                   BOOLEAN:=FALSE;

  CURSOR c_Seq IS
    SELECT psb_position_pay_distr_s.NEXTVAL DistID
      FROM dual;

  CURSOR c_Dist IS
    SELECT distribution_id,
	   position_id,
	   data_extract_id,
	   worksheet_id,
	   effective_start_date,
	   effective_end_date,
	   chart_of_accounts_id,
	   code_combination_id,
	   distribution_percent,
	   global_default_flag,
	   distribution_default_rule_id,
	   project_id,
	   task_id,
	   award_id,
	   expenditure_type,
	   expenditure_organization_id,
	   description
      FROM PSB_POSITION_PAY_DISTRIBUTIONS
     WHERE
          /* Bug 4545909 Start */
         ((worksheet_id IS NULL AND NOT EXISTS (
           SELECT 1 FROM psb_position_pay_distributions
            WHERE worksheet_id = p_worksheet_id
              AND position_id  = p_position_id))
               OR worksheet_id = p_worksheet_id
               OR (worksheet_id IS NULL AND p_worksheet_id IS NULL))
          /* Bug 4545909 End */
       AND chart_of_accounts_id = p_chart_of_accounts_id
       AND code_combination_id = p_code_combination_id
       AND (((p_effective_end_date IS NOT NULL)
       AND (((effective_start_date <= p_effective_end_date)
       AND (effective_end_date IS NULL))
        OR ((effective_start_date BETWEEN p_effective_start_date AND p_effective_end_date)
        OR (effective_end_date BETWEEN p_effective_start_date AND p_effective_end_date)
        OR ((effective_start_date < p_effective_start_date)
       AND (effective_end_date > p_effective_end_date)))))
	OR ((p_effective_end_date IS NULL)
       AND (NVL(effective_end_date, p_effective_start_date) >= p_effective_start_date)))
       AND position_id = p_position_id;

  /* Bug 4545909 Start */
  l_de_exists BOOLEAN := FALSE;
  CURSOR l_exists IS
    SELECT 1
      FROM PSB_POSITION_PAY_DISTRIBUTIONS
     WHERE data_extract_id = p_data_extract_id
       AND position_id     = p_position_id and worksheet_id IS NULL;
  /* Bug 4545909 End */

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT  Apply_Position_Pay_Distr;


  -- Standard call to check for call compatibility

  IF NOT FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  l_userid  := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;


  FOR l_init_index IN 1..g_pay_dist.COUNT LOOP
    g_pay_dist(l_init_index).distribution_id      := NULL;
    g_pay_dist(l_init_index).position_id          := NULL;
    g_pay_dist(l_init_index).data_extract_id      := NULL;
    g_pay_dist(l_init_index).worksheet_id         := NULL;
    g_pay_dist(l_init_index).effective_start_date := NULL;
    g_pay_dist(l_init_index).effective_end_date   := NULL;
    g_pay_dist(l_init_index).chart_of_accounts_id := NULL;
    g_pay_dist(l_init_index).code_combination_id  := NULL;
    g_pay_dist(l_init_index).distribution_percent := NULL;
    g_pay_dist(l_init_index).global_default_flag  := NULL;
    g_pay_dist(l_init_index).dist_default_rule_id := NULL;
    g_pay_dist(l_init_index).project_id           := NULL;
    g_pay_dist(l_init_index).task_id              := NULL;
    g_pay_dist(l_init_index).award_id             := NULL;
    g_pay_dist(l_init_index).expenditure_type     := NULL;
    g_pay_dist(l_init_index).expenditure_organization_id:= NULL;
    g_pay_dist(l_init_index).description          := NULL;
    g_pay_dist(l_init_index).delete_flag          := NULL;
  END LOOP;

  g_num_pay_dist := 0;

  FOR c_Dist_Rec IN c_Dist LOOP

    g_num_pay_dist := g_num_pay_dist + 1;

    g_pay_dist(g_num_pay_dist).distribution_id := c_Dist_Rec.distribution_id;
    g_pay_dist(g_num_pay_dist).position_id := c_Dist_Rec.position_id;
    g_pay_dist(g_num_pay_dist).data_extract_id := c_Dist_Rec.data_extract_id;
    g_pay_dist(g_num_pay_dist).worksheet_id := c_Dist_Rec.worksheet_id;
    g_pay_dist(g_num_pay_dist).effective_start_date := c_Dist_Rec.effective_start_date;
    g_pay_dist(g_num_pay_dist).effective_end_date := c_Dist_Rec.effective_end_date;
    g_pay_dist(g_num_pay_dist).chart_of_accounts_id := c_Dist_Rec.chart_of_accounts_id;
    g_pay_dist(g_num_pay_dist).code_combination_id := c_Dist_Rec.code_combination_id;
    g_pay_dist(g_num_pay_dist).distribution_percent := c_Dist_Rec.distribution_percent;
    g_pay_dist(g_num_pay_dist).global_default_flag := c_Dist_Rec.global_default_flag;
    g_pay_dist(g_num_pay_dist).dist_default_rule_id := c_Dist_Rec.distribution_default_rule_id;
    g_pay_dist(g_num_pay_dist).project_id := c_Dist_Rec.project_id;
    g_pay_dist(g_num_pay_dist).task_id:= c_Dist_Rec.task_id;
    g_pay_dist(g_num_pay_dist).award_id:= c_Dist_Rec.award_id;
    g_pay_dist(g_num_pay_dist).expenditure_type:= c_Dist_Rec.expenditure_type;
    g_pay_dist(g_num_pay_dist).expenditure_organization_id:=  c_Dist_Rec.expenditure_organization_id;
    g_pay_dist(g_num_pay_dist).description:= c_Dist_Rec.description;
    g_pay_dist(g_num_pay_dist).delete_flag := FND_API.G_TRUE;

  END LOOP;

  FOR l_exists_rec in l_exists
  LOOP
    l_de_exists := TRUE;
  END LOOP;

  -- the following code processes overwrite default rule
  IF p_modify_flag = 'Y' THEN

    FOR c_Seq_Rec IN c_Seq LOOP
      l_distribution_id := c_Seq_Rec.DistID;
    END LOOP;

    -- Bug 4545909. The following IF clause is added
    -- first insert_row call create worksheet level record
    -- second insert_row call create extract level record
    IF l_de_exists THEN
    Insert_Row
	    (p_api_version => 1.0,
	     p_return_status => l_return_status,
	     p_msg_count => x_msg_count,
	     p_msg_data => x_msg_data,
	     p_rowid => l_rowid,
	     p_distribution_id => l_distribution_id,
	     p_position_id => p_position_id,
	     p_data_extract_id => p_data_extract_id,
	     p_worksheet_id => p_worksheet_id,
	     p_effective_start_date => p_effective_start_date,
	     p_effective_end_date => p_effective_end_date,
	     p_chart_of_accounts_id => p_chart_of_accounts_id,
	     p_code_combination_id => p_code_combination_id,
	     p_distribution_percent => p_distribution_percent,
	     p_global_default_flag => p_global_default_flag,
	     p_distribution_default_rule_id => p_distribution_default_rule_id,
	     p_project_id  => p_project_id,
	     p_task_id => p_task_id,
	     p_award_id  => p_award_id,
	     p_expenditure_type  => p_expenditure_type,
	     p_expenditure_organization_id  => p_expenditure_organization_id,
	     p_description => p_description,
	     p_mode => p_mode);
    ELSE
    Insert_Row
	    (p_api_version => 1.0,
	     p_return_status => l_return_status,
	     p_msg_count => x_msg_count,
	     p_msg_data => x_msg_data,
	     p_rowid => l_rowid,
	     p_distribution_id => l_distribution_id,
	     p_position_id => p_position_id,
	     p_data_extract_id => p_data_extract_id,
	     p_worksheet_id => NULL,
	     p_effective_start_date => p_effective_start_date,
	     p_effective_end_date => p_effective_end_date,
	     p_chart_of_accounts_id => p_chart_of_accounts_id,
	     p_code_combination_id => p_code_combination_id,
	     p_distribution_percent => p_distribution_percent,
	     p_global_default_flag => p_global_default_flag,
	     p_distribution_default_rule_id => p_distribution_default_rule_id,
	     p_project_id  => p_project_id,
	     p_task_id => p_task_id,
	     p_award_id  => p_award_id,
	     p_expenditure_type  => p_expenditure_type,
	     p_expenditure_organization_id  => p_expenditure_organization_id,
	     p_description => p_description,
	     p_mode => p_mode);

    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    p_rowid := l_rowid;
    p_distribution_id := l_distribution_id;


  ELSE
    -- the following code processes non-overwrite default rule

    l_dist_percent_sum := PSB_POSITIONS_PVT.g_distr_percent_total;


    IF l_dist_percent_sum < 100 THEN

      l_distribution_percent
             := (100 - l_dist_percent_sum) * p_distribution_percent/100 ;

      FOR l_dist_index IN 1..g_num_pay_dist LOOP

      IF g_pay_dist(l_dist_index).code_combination_id = p_code_combination_id THEN

        Update_Row
		(p_api_version => 1.0,
		 p_return_status => l_return_status,
		 p_msg_count => x_msg_count,
		 p_msg_data => x_msg_data,
		 p_distribution_id => g_pay_dist(l_dist_index).distribution_id,
		 p_code_combination_id => p_code_combination_id,
		 p_distribution_percent =>
                   g_pay_dist(l_dist_index).distribution_percent + l_distribution_percent,
		 p_effective_end_date => p_effective_end_date,
		 p_global_default_flag => p_global_default_flag,
		 p_distribution_default_rule_id => p_distribution_default_rule_id,
		 p_project_id  => p_project_id,
		 p_task_id => p_task_id,
		 p_award_id  => p_award_id,
		 p_expenditure_type  => p_expenditure_type,
		 p_expenditure_organization_id  => p_expenditure_organization_id,
		 p_description => p_description,
		 p_mode => p_mode);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
          l_ccid_exists :=  TRUE;

      END IF;
      END LOOP;

      IF l_ccid_exists  = FALSE THEN

      FOR c_Seq_Rec IN c_Seq LOOP
        l_distribution_id := c_Seq_Rec.DistID;
      END LOOP;

        Insert_Row
            (p_api_version => 1.0,
             p_return_status => l_return_status,
             p_msg_count => x_msg_count,
             p_msg_data => x_msg_data,
	     p_rowid => l_rowid,
             p_distribution_id => l_distribution_id,
             p_position_id => p_position_id,
             p_data_extract_id => p_data_extract_id,
             p_worksheet_id => p_worksheet_id,
             p_effective_start_date => p_effective_start_date,
             p_effective_end_date => p_effective_end_date,
             p_chart_of_accounts_id => p_chart_of_accounts_id,
             p_code_combination_id => p_code_combination_id,
             p_distribution_percent => l_distribution_percent,
             p_global_default_flag => p_global_default_flag,
             p_distribution_default_rule_id => p_distribution_default_rule_id,
             p_project_id  => p_project_id,
             p_task_id => p_task_id,
             p_award_id  => p_award_id,
             p_expenditure_type  => p_expenditure_type,
             p_expenditure_organization_id  => p_expenditure_organization_id,
             p_description => p_description,
             p_mode => p_mode);
      END IF;
  END IF;
  END IF;

  -- Standard check of p_commit

  IF FND_API.to_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;


  -- Initialize API return status to success

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
			     p_data  => x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Apply_Position_Pay_Distr;
     x_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Apply_Position_Pay_Distr;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO Apply_Position_Pay_Distr;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);

END Apply_Position_Pay_Distr;

/* Bug 1308558 End */

/* ----------------------------------------------------------------------- */

/*Bug:5261798:start*/
PROCEDURE CREATE_WS_POS_DISTR_FRMDE(p_api_version       IN          NUMBER,
                                    p_init_msg_list     IN          VARCHAR2 := FND_API.G_FALSE,
                                    p_commit            IN          VARCHAR2 := FND_API.G_FALSE,
                                    p_validation_level  IN          NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                    p_return_status    OUT  NOCOPY  VARCHAR2,
                                    p_msg_count        OUT  NOCOPY  NUMBER,
                                    p_msg_data         OUT  NOCOPY  VARCHAR2,
                                    p_position_id       IN          NUMBER,
                                    p_data_extract_id   IN          NUMBER,
                                    p_worksheet_id      IN          NUMBER,
                                    p_event_type        IN          VARCHAR2) IS


  l_api_name                      CONSTANT VARCHAR2(30) := 'Create_WS_Records';
  l_api_version                   CONSTANT NUMBER       := 1.0;

   l_return_status varchar2(1);
   l_msg_count  number;
   l_msg_data   varchar2(2000);
   l_distribution_id NUMBER ;
   l_row_id      VARCHAR2(18);

  cursor c_Seq is
  select psb_position_pay_distr_s.nextval DistID
    from dual;

   CURSOR c_paydist_csr IS
   select distribution_id,
          worksheet_id,
          position_id,
          data_extract_id,
          effective_start_date,
          effective_end_date,
          chart_of_accounts_id,
          code_combination_id,
          distribution_percent,
          global_default_flag,
          distribution_default_rule_id,
          project_id,
          task_id,
          award_id,
          expenditure_type,
          expenditure_organization_id,
          description
    from  psb_position_pay_distributions ppd
   where  position_id = p_position_id
     and  data_extract_id = p_data_extract_id
     and  worksheet_id is null
     and  not exists
      (select 1 from psb_position_pay_distributions ppd1
       where ppd1.position_id = ppd.position_id
        and  ppd1.data_extract_id = ppd.data_extract_id
        and  ppd1.worksheet_id = p_worksheet_id);

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     CREATE_WS_POS_DISTR_FRMDE_PVT;


  -- Standard call to check for call compatibility

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

 IF p_event_type = 'WS' then

  for l_paydist_rec in c_paydist_csr loop

   MODIFY_DISTRIBUTION_WS (
       p_api_version              => 1.0,
       p_init_msg_list            => FND_API.G_TRUE,
       p_commit                   => NULL,
       p_validation_level         => NULL,
       p_return_status            => l_return_status,
       p_msg_count                => l_msg_count,
       p_msg_data                 => l_msg_data,
       p_rowid                    => l_row_id,
       p_distribution_id          => l_paydist_rec.distribution_id,
       p_worksheet_id             => p_worksheet_id,
       p_position_id              => l_paydist_rec.position_id,
       p_data_extract_id 	  => l_paydist_rec.data_extract_id,
       p_effective_start_date     => l_paydist_rec.effective_start_date,
       p_effective_end_date       => l_paydist_rec.effective_end_date,
       p_chart_of_accounts_id     => l_paydist_rec.chart_of_accounts_id,
       p_code_combination_id      => l_paydist_rec.code_combination_id,
       p_distribution_percent     => l_paydist_rec.distribution_percent,
       p_global_default_flag      => l_paydist_rec.global_default_flag,
       p_distribution_default_rule_id => l_paydist_rec.distribution_default_rule_id,
       p_budget_revision_pos_line_id => null,
       p_mode 	                  => 'R'
    );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
     raise FND_API.G_EXC_ERROR;
  end if;

  end loop;

 elsif p_event_type = 'BR' then

  for l_paydist_rec in c_paydist_csr loop

      FOR c_Seq_Rec IN c_Seq LOOP
        l_distribution_id := c_Seq_Rec.DistID;
      END LOOP;

         Insert_Row
 	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_rowid => l_row_id,
	    p_distribution_id => l_distribution_id,
	    p_position_id => p_position_id,
	    p_data_extract_id => p_data_extract_id,
	    p_worksheet_id => p_worksheet_id,
	    p_effective_start_date => l_paydist_rec.effective_start_date,
	    p_effective_end_date => l_paydist_rec.effective_end_date,
	    p_chart_of_accounts_id => l_paydist_rec.chart_of_accounts_id,
	    p_code_combination_id => l_paydist_rec.code_combination_id,
	    p_distribution_percent => l_paydist_rec.distribution_percent,
	    p_global_default_flag => l_paydist_rec.global_default_flag,
	    p_distribution_default_rule_id => l_paydist_rec.distribution_default_rule_id,
	    p_project_id  => l_paydist_rec.project_id,
	    p_task_id => l_paydist_rec.task_id,
	    p_award_id  => l_paydist_rec.award_id,
	    p_expenditure_type  => l_paydist_rec.expenditure_type,
	    p_expenditure_organization_id  => l_paydist_rec.expenditure_organization_id,
	    p_description  => l_paydist_rec.description,
	    p_mode => 'R');

	 if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	 end if;

  end loop;

 end if;

  -- Standard check of p_commit

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to CREATE_WS_POS_DISTR_FRMDE_PVT;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to CREATE_WS_POS_DISTR_FRMDE_PVT;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     rollback to CREATE_WS_POS_DISTR_FRMDE_PVT;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END;
/*Bug:5261798:end*/

END PSB_POSITION_PAY_DISTR_PVT ;

/
