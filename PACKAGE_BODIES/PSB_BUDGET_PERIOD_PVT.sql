--------------------------------------------------------
--  DDL for Package Body PSB_BUDGET_PERIOD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_BUDGET_PERIOD_PVT" AS
/* $Header: PSBVPRDB.pls 120.2 2005/07/13 11:29:01 shtripat ship $ */
--
-- Global Variables
--

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_BUDGET_PERIOD_PVT';
  G_MONTH    CONSTANT VARCHAR2(1) := 'M' ;
  G_QTR      CONSTANT VARCHAR2(1) := 'Q' ;
  G_SEMI     CONSTANT VARCHAR2(1) := 'S' ;
  G_MONTH_NUM         NUMBER      := 1 ;
  G_QTR_NUM           NUMBER      := 2 ;
  G_SEMI_NUM          NUMBER      := 5 ;
  G_DBUG              VARCHAR2(2000);

/* ----------------------------------------------------------------------- */
--
-- Private Procedure Declarations
--
PROCEDURE Check_Duplicate_Year_Types
	(p_calendar_id          IN NUMBER,
	 p_curr_year_type       IN NUMBER,
	 p_budget_period_id     IN NUMBER,
	 p_return_status        OUT  NOCOPY VARCHAR2) ;
--
PROCEDURE Check_Used_In_WS
	(p_calendar_id          IN NUMBER,
	 p_return_status        OUT  NOCOPY VARCHAR2) ;
--
PROCEDURE Create_Periods(
  p_calendar_id         IN      NUMBER,
  p_year_id             IN      NUMBER,
  p_year_name           IN      VARCHAR2,
  p_start_date          IN      DATE,
  p_end_date            IN      DATE,
  p_budget_period_type  IN      VARCHAR2,
  p_calc_period_type    IN      VARCHAR2,
  p_return_status       OUT  NOCOPY     VARCHAR2  ,
  p_msg_count           OUT  NOCOPY     number,
  p_msg_data            OUT  NOCOPY     varchar2
);
--
PROCEDURE Create_New_Distr_Calc_Period(
  p_calendar_id         IN      NUMBER,
  p_year_id             IN      NUMBER,
  p_year_name           IN      VARCHAR2,
  p_start_date          IN      DATE,
  p_end_date            IN      DATE,
  p_budget_period_type  IN      VARCHAR2,
  p_calc_period_type    IN      VARCHAR2,
  p_update_dist         IN      VARCHAR2,
  p_update_calc         IN      VARCHAR2,
  p_return_status       OUT  NOCOPY     VARCHAR2  ,
  p_msg_count           OUT  NOCOPY     number,
  p_msg_data            OUT  NOCOPY     varchar2
);
--

-- Begin Table Handler Procedures
--
PROCEDURE INSERT_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_rowid               IN  OUT  NOCOPY varchar2,
  p_budget_period_id    in number,
  p_budget_calendar_id  in number,
  p_description         in varchar2,
  p_start_date          in date,
  p_end_date            in date,
  p_name                in varchar2,
  p_budget_year_type_id in number,
  p_parent_budget_period_id in number,
  p_budget_period_type in varchar2,
  p_period_distribution_type in varchar2,
  p_calculation_period_type in varchar2,
  p_attribute1  in varchar2,
  p_attribute2  in varchar2,
  p_attribute3  in varchar2,
  p_attribute4  in varchar2,
  p_attribute5  in varchar2,
  p_attribute6  in varchar2,
  p_attribute7  in varchar2,
  p_attribute8  in varchar2,
  p_attribute9  in varchar2,
  p_attribute10 in varchar2,
  p_context     in varchar2,
  p_mode        in varchar2,
  p_requery    OUT  NOCOPY varchar2
  ) is
    cursor C is select ROWID from PSB_BUDGET_PERIODS
      where BUDGET_PERIOD_ID = P_BUDGET_PERIOD_ID;
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
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  Check_Used_In_WS
	(p_calendar_id          => p_budget_calendar_id,
	 p_return_status        => l_return_status);

  IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
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
  Check_Consecutive_Year_Types  (
      p_api_version              => 1.0,
      p_init_msg_list            => fnd_api.g_false,
      p_commit                   => fnd_api.g_false,
      p_validation_level         => fnd_api.g_valid_level_full,
      p_return_status            => p_return_status,
      p_msg_count                => p_msg_count,
      p_msg_data                 => p_msg_data,
      p_calendar_id              => p_budget_calendar_id,
      p_curr_year_type           => p_budget_year_type_id,
      p_curr_start_date          => p_start_date,
      p_curr_end_date            => p_end_date,
      p_mode_type                => 'A'
       );
  --
  if    l_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR ;
  elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  end if;
  --
  Check_Duplicate_Year_Types
	(p_calendar_id          => p_budget_calendar_id,
	 p_curr_year_type       => p_budget_year_type_id,
	 p_budget_period_id     => p_budget_period_id,
	 p_return_status        => l_return_status);
  --
  if    l_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR ;
  elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  end if;
  --
  insert into PSB_BUDGET_PERIODS (
    budget_period_id,
    budget_calendar_id,
    description,
    start_date,
    end_date,
    name,
    budget_year_type_id,
    parent_budget_period_id,
    budget_period_type,
    period_distribution_type,
    calculation_period_type,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    context,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  ) values (
    p_budget_period_id,
    p_budget_calendar_id,
    p_description,
    p_start_date,
    p_end_date,
    p_name,
    p_budget_year_type_id,
    p_parent_budget_period_id,
    p_budget_period_type,
    p_period_distribution_type,
    p_calculation_period_type,
    p_attribute1,
    p_attribute2,
    p_attribute3,
    p_attribute4,
    p_attribute5,
    p_attribute6,
    p_attribute7,
    p_attribute8,
    p_attribute9,
    p_attribute10,
    p_context,
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
  -- create periods and calc --
  if (p_budget_period_type = 'Y')  THEN
      Create_Periods(
	       p_calendar_id         => p_budget_calendar_id ,
	       p_year_id             => p_budget_period_id,
	       p_year_name           => p_name,
	       p_start_date          => p_start_date,
	       p_end_date            => p_end_date,
	       p_budget_period_type  => p_period_distribution_type,
	       p_calc_period_type    => p_calculation_period_type,
	       p_return_status       => l_return_status,
	       p_msg_count           => p_msg_count,
	       p_msg_data            => p_msg_data
	       );
       if    l_return_status = FND_API.G_RET_STS_ERROR then
	       RAISE FND_API.G_EXC_ERROR ;
       elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       end if;
  --+ set requery so form can do execute query when create period button not
  --+ selected....
       p_requery := 'Y' ;
  end if;

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
PROCEDURE LOCK_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number   := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_row_locked          OUT  NOCOPY varchar2,
  p_budget_period_id    in number,
  p_budget_calendar_id  in number,
  p_description         in varchar2,
  p_start_date          in date,
  p_end_date            in date,
  p_name                in varchar2,
  p_budget_year_type_id in number,
  p_parent_budget_period_id  in number,
  p_budget_period_type       in varchar2,
  p_period_distribution_type in varchar2,
  p_calculation_period_type  in varchar2,
  p_attribute1  in varchar2,
  p_attribute2  in varchar2,
  p_attribute3  in varchar2,
  p_attribute4  in varchar2,
  p_attribute5  in varchar2,
  p_attribute6  in varchar2,
  p_attribute7  in varchar2,
  p_attribute8  in varchar2,
  p_attribute9  in varchar2,
  p_attribute10 in varchar2,
  p_context     in varchar2

) is
  cursor c1 is select
      budget_calendar_id,
      description,
      start_date,
      end_date,
      name,
      budget_year_type_id,
      parent_budget_period_id,
      budget_period_type,
      period_distribution_type,
      calculation_period_type,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      context
    from PSB_BUDGET_PERIODS
    where BUDGET_PERIOD_ID = P_BUDGET_PERIOD_ID
    for update of BUDGET_PERIOD_ID nowait;
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
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
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
  if ( (tlinfo.BUDGET_CALENDAR_ID = P_BUDGET_CALENDAR_ID)
      AND (tlinfo.NAME = P_NAME)
      AND (tlinfo.START_DATE = P_START_DATE)
      AND (tlinfo.END_DATE = P_END_DATE)
      AND ((tlinfo.DESCRIPTION = P_DESCRIPTION)
	   OR ((tlinfo.DESCRIPTION is null)
	      AND (P_DESCRIPTION is null)))
      AND ((tlinfo.BUDGET_YEAR_TYPE_ID = P_BUDGET_YEAR_TYPE_ID)
	   OR ((tlinfo.BUDGET_YEAR_TYPE_ID is null)
	       AND (P_BUDGET_YEAR_TYPE_ID is null)))
      AND ((tlinfo.PARENT_BUDGET_PERIOD_ID = P_PARENT_BUDGET_PERIOD_ID)
	   OR ((tlinfo.PARENT_BUDGET_PERIOD_ID is null)
	       AND (P_PARENT_BUDGET_PERIOD_ID is null)))
      AND (tlinfo.BUDGET_PERIOD_TYPE = P_BUDGET_PERIOD_TYPE)
      AND ((tlinfo.PERIOD_DISTRIBUTION_TYPE = P_PERIOD_DISTRIBUTION_TYPE)
	   OR ((tlinfo.PERIOD_DISTRIBUTION_TYPE is null)
	       AND (P_PERIOD_DISTRIBUTION_TYPE is null)))
      AND ((tlinfo.CALCULATION_PERIOD_TYPE = P_CALCULATION_PERIOD_TYPE)
	   OR ((tlinfo.CALCULATION_PERIOD_TYPE is null)
	       AND (P_CALCULATION_PERIOD_TYPE is null)))
      AND ((tlinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
	   OR ((tlinfo.ATTRIBUTE1 is null)
	       AND (P_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
	   OR ((tlinfo.ATTRIBUTE2 is null)
	       AND (P_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
	   OR ((tlinfo.ATTRIBUTE3 is null)
	       AND (P_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
	   OR ((tlinfo.ATTRIBUTE4 is null)
	       AND (P_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
	   OR ((tlinfo.ATTRIBUTE5 is null)
	       AND (P_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
	   OR ((tlinfo.ATTRIBUTE6 is null)
	       AND (P_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
	   OR ((tlinfo.ATTRIBUTE7 is null)
	       AND (P_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
	   OR ((tlinfo.ATTRIBUTE8 is null)
	       AND (P_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
	   OR ((tlinfo.ATTRIBUTE9 is null)
	       AND (P_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
	   OR ((tlinfo.ATTRIBUTE10 is null)
	       AND (P_ATTRIBUTE10 is null)))
      AND ((tlinfo.CONTEXT = P_CONTEXT)
	   OR ((tlinfo.CONTEXT is null)
	       AND (P_CONTEXT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error ;
  end if;

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
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number   := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_budget_period_id    in number,
  p_budget_calendar_id  in number,
  p_description         in varchar2,
  p_start_date          in date,
  p_end_date            in date,
  p_name                in varchar2,
  p_budget_year_type_id      in number,
  p_parent_budget_period_id  in number,
  p_budget_period_type       in varchar2,
  p_period_distribution_type in varchar2,
  p_calculation_period_type  in varchar2,
  p_attribute1  in varchar2,
  p_attribute2  in varchar2,
  p_attribute3  in varchar2,
  p_attribute4  in varchar2,
  p_attribute5  in varchar2,
  p_attribute6  in varchar2,
  p_attribute7  in varchar2,
  p_attribute8  in varchar2,
  p_attribute9  in varchar2,
  p_attribute10 in varchar2,
  p_context     in varchar2,
  p_mode        in varchar2,
  p_requery    OUT  NOCOPY varchar2
  ) is
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
--
l_api_name      CONSTANT VARCHAR2(30) := 'Update Row';
l_api_version   CONSTANT NUMBER := 1.0 ;
l_return_status VARCHAR2(1);
l_update_dist   VARCHAR2(1) := 'N';
l_update_calc   VARCHAR2(1) := 'N';
l_pd_dist_type  VARCHAR2(10);
l_pd_calc_type VARCHAR2(10);
--
BEGIN
  --
  SAVEPOINT Update_Row ;
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  --
  Check_Used_In_WS
	(p_calendar_id          => p_budget_calendar_id,
	 p_return_status        => l_return_status);

  IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

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

  --
  -- get original value of distribution type and calc type to determine
  -- whether to re-create them
  --
  select period_distribution_type,calculation_period_type
    into  l_pd_dist_type, l_pd_calc_type
    from  psb_budget_periods
   where  budget_period_id = p_budget_period_id;

  if sql%notfound then
	raise FND_API.G_EXC_ERROR;
  end if;

  if l_pd_dist_type <> p_period_distribution_type then
	l_update_dist := 'Y';
  end if;

  if l_pd_calc_type <> p_calculation_period_type then
	l_update_calc := 'Y';
  end if;

  -- do the update of the record
  --
  update PSB_BUDGET_PERIODS set
    budget_calendar_id = p_budget_calendar_id,
    name = p_name,
    start_date = p_start_date,
    end_date = p_end_date,
    description = p_description,
    budget_year_type_id = p_budget_year_type_id,
    parent_budget_period_id = p_parent_budget_period_id,
    budget_period_type = p_budget_period_type,
    period_distribution_type = p_period_distribution_type,
    calculation_period_type = p_calculation_period_type,
    attribute1 = p_attribute1,
    attribute2 = p_attribute2,
    attribute3 = p_attribute3,
    attribute4 = p_attribute4,
    attribute5 = p_attribute5,
    attribute6 = p_attribute6,
    attribute7 = p_attribute7,
    attribute8 = p_attribute8,
    attribute9 = p_attribute9,
    attribute10 = p_attribute10,
    context = p_context,
    last_update_date = p_last_update_date,
    last_updated_by = p_last_updated_by,
    last_update_login = p_last_update_login
  where BUDGET_PERIOD_ID = P_BUDGET_PERIOD_ID
  ;
  if (sql%notfound) then
    -- raise no_data_found;
    raise FND_API.G_EXC_ERROR ;
  end if;

  -- create new periods or calcs
  Create_New_Distr_Calc_Period(
	       p_calendar_id         => p_budget_calendar_id ,
	       p_year_id             => p_budget_period_id,
	       p_year_name           => p_name,
	       p_start_date          => p_start_date,
	       p_end_date            => p_end_date,
	       p_budget_period_type  => p_period_distribution_type,
	       p_calc_period_type    => p_calculation_period_type,
	       p_update_dist         => l_update_dist,
	       p_update_calc         => l_update_calc,
	       p_return_status       => l_return_status,
	       p_msg_count           => p_msg_count,
	       p_msg_data            => p_msg_data
	       );
  IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;

  IF l_update_dist = 'Y' THEN
     p_requery := 'Y' ;
  END IF ;

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
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_rowid               in OUT  NOCOPY varchar2,
  p_budget_period_id    in number,
  p_budget_calendar_id  in number,
  p_description         in varchar2,
  p_start_date          in date,
  p_end_date            in date,
  p_name                in varchar2,
  p_budget_year_type_id in number,
  p_parent_budget_period_id  in number,
  p_budget_period_type       in varchar2,
  p_period_distribution_type in varchar2,
  p_calculation_period_type  in varchar2,
  p_attribute1  in varchar2,
  p_attribute2  in varchar2,
  p_attribute3  in varchar2,
  p_attribute4  in varchar2,
  p_attribute5  in varchar2,
  p_attribute6  in varchar2,
  p_attribute7  in varchar2,
  p_attribute8  in varchar2,
  p_attribute9  in varchar2,
  p_attribute10 in varchar2,
  p_context     in varchar2,
  p_mode        in varchar2,
  p_requery    OUT  NOCOPY varchar2
  ) is
  cursor c1 is select rowid from PSB_BUDGET_PERIODS
     where BUDGET_PERIOD_ID = P_BUDGET_PERIOD_ID
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
     p_api_version,
     p_init_msg_list,
     p_commit,
     p_validation_level,
     p_return_status,
     p_msg_count,
     p_msg_data,
     p_rowid,
     p_budget_period_id,
     p_budget_calendar_id,
     p_description,
     p_start_date,
     p_end_date,
     p_name,
     p_budget_year_type_id,
     p_parent_budget_period_id,
     p_budget_period_type,
     p_period_distribution_type,
     p_calculation_period_type,
     p_attribute1,
     p_attribute2,
     p_attribute3,
     p_attribute4,
     p_attribute5,
     p_attribute6,
     p_attribute7,
     p_attribute8,
     p_attribute9,
     p_attribute10,
     p_context,
     p_mode,
     p_requery    );
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
   p_api_version,
   p_init_msg_list,
   p_commit,
   p_validation_level,
   p_return_status,
   p_msg_count,
   p_msg_data,
   p_budget_period_id,
   p_budget_calendar_id,
   p_description,
   p_start_date,
   p_end_date,
   p_name,
   p_budget_year_type_id,
   p_parent_budget_period_id,
   p_budget_period_type,
   p_period_distribution_type,
   p_calculation_period_type,
   p_attribute1,
   p_attribute2,
   p_attribute3,
   p_attribute4,
   p_attribute5,
   p_attribute6,
   p_attribute7,
   p_attribute8,
   p_attribute9,
   p_attribute10,
   p_context,
   p_mode,
   p_requery );
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
  p_budget_period_id    in number
) is
--
l_api_name    CONSTANT VARCHAR2(30) := 'Delete Row' ;
l_api_version CONSTANT NUMBER := 1.0 ;
l_budget_calendar_id   NUMBER;
l_start_date           DATE;
l_end_date             DATE;
l_budget_year_type_id NUMBER;
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
  -- check first if calendar not used in worksheet
  select budget_calendar_id,start_date,end_date,budget_year_type_id
	 into l_budget_calendar_id,l_start_date,l_end_date,l_budget_year_type_id
    FROM psb_budget_periods
   WHERE budget_period_id = p_budget_period_id;

  --
  Check_Used_In_WS
	(p_calendar_id          => l_budget_calendar_id,
	 p_return_status                => l_return_status);

  IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --
  delete from PSB_BUDGET_PERIODS
  where parent_budget_period_id = p_budget_period_id;
  if (sql%notfound) THEN
   null;
  end if;

  delete from PSB_BUDGET_PERIODS
  where BUDGET_PERIOD_ID = P_BUDGET_PERIOD_ID;
  if (sql%notfound) then
    -- raise no_data_found;
    raise FND_API.G_EXC_ERROR ;
  end if;
  --
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
--
-- End of Table Handler Procedures
--
PROCEDURE Check_Duplicate_Year_Types
	(p_calendar_id          IN NUMBER,
	 p_curr_year_type       IN NUMBER,
	 p_budget_period_id     IN NUMBER,
	 p_return_status        OUT  NOCOPY VARCHAR2) IS
--
 l_type_count   NUMBER ;
--
BEGIN
 --
 SELECT count(*)
   INTO l_type_count
   FROM PSB_BUDGET_PERIODS
  WHERE budget_calendar_id  = p_calendar_id
    AND budget_year_type_id = p_curr_year_type
    AND budget_period_id   <> p_budget_period_id ;
 --
 IF l_type_count > 0 THEN
    FND_MESSAGE.SET_NAME('PSB', 'PSB_DUP_YEAR_TYPE_IN_CAL');
    FND_MSG_PUB.Add ;
    RAISE FND_API.G_EXC_ERROR ;
 END IF;
 --
 p_return_status := FND_API.G_RET_STS_SUCCESS ;
 --
EXCEPTION
   --
   when FND_API.G_EXC_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_ERROR;
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
END Check_Duplicate_Year_Types;
--
PROCEDURE Check_Consecutive_Year_Types(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_calendar_id         IN      NUMBER,
  p_curr_year_type      IN      NUMBER,
  p_curr_start_date     IN      DATE,
  p_curr_end_date       IN      DATE,
  p_mode_type           IN      VARCHAR2
  ) IS
  --
  l_api_name            CONSTANT VARCHAR2(30) := 'Check_Consecutive_Years' ;
  l_api_version         CONSTANT NUMBER := 1.0 ;
  l_return_status       VARCHAR2(1);
  l_prior_year_seq      NUMBER ;
  l_next_year_seq       NUMBER ;
  l_prior_seq           NUMBER ;
  l_next_seq            NUMBER ;
  l_prior_end_date      DATE;
  l_next_start_date     DATE;
  --
  CURSOR prior_year_csr IS
  SELECT max(b.sequence_number), end_date
    FROM psb_budget_periods a,
	 psb_budget_year_types b,
	 psb_budget_year_types c
   WHERE a.budget_year_type_id = b.budget_year_type_id
     AND b.sequence_number     < c.sequence_number
     AND c.budget_year_type_id = p_curr_year_type
     AND a.budget_calendar_id  = p_calendar_id
   GROUP BY end_date
   ORDER BY end_date DESC;
  --
  CURSOR next_year_csr IS
  SELECT min(b.sequence_number), start_date
    FROM psb_budget_periods a,
	 psb_budget_year_types b,
	 psb_budget_year_types c
   WHERE a.budget_year_type_id = b.budget_year_type_id
     AND b.sequence_number     > c.sequence_number
     AND c.budget_year_type_id = p_curr_year_type
     AND a.budget_calendar_id  = p_calendar_id
   GROUP BY start_date ;
  --
  CURSOR prior_type_csr IS
  SELECT max(a.sequence_number)
    FROM psb_budget_year_types a,
	 psb_budget_year_types b
   WHERE a.sequence_number < b.sequence_number
     AND b.budget_year_type_id = p_curr_year_type;
  --
  CURSOR next_type_csr IS
  SELECT min(a.sequence_number)
    FROM psb_budget_year_types a,
	 psb_budget_year_types b
   WHERE a.sequence_number > b.sequence_number
     AND b.budget_year_type_id = p_curr_year_type;
  --
BEGIN
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN prior_year_csr ;
  FETCH prior_year_csr INTO l_prior_year_seq, l_prior_end_date ;
  IF prior_year_csr%NOTFOUND THEN
     IF (p_mode_type = 'A') THEN
	l_prior_end_date := p_curr_start_date - 1 ;
     ELSE
	l_prior_end_date := p_curr_start_date + 1 ;
     END IF;
  END IF;
  CLOSE prior_year_csr ;
  --
  OPEN next_year_csr ;
  FETCH next_year_csr INTO l_next_year_seq, l_next_start_date ;
  IF next_year_csr%NOTFOUND THEN
     IF (p_mode_type = 'A')  THEN
	 l_next_start_date := p_curr_end_date + 1 ;
     ELSE
	 l_next_start_date := p_curr_end_date - 1 ;
     END IF;
  END IF;
  CLOSE next_year_csr ;
  --
  OPEN prior_type_csr ;
  FETCH prior_type_csr INTO l_prior_seq ;
  CLOSE prior_type_csr ;
  --
  OPEN next_type_csr ;
  FETCH next_type_csr INTO l_next_seq ;
  CLOSE next_type_csr ;
  --
  IF (p_mode_type = 'A') THEN
    IF (p_curr_start_date <> l_prior_end_date + 1  ) OR
       (p_curr_end_date   <> l_next_start_date - 1 ) THEN
	FND_MESSAGE.SET_NAME('PSB', 'PSB_YEAR_DATE_MUST_BE_CONSEC');
	FND_MSG_PUB.Add ;
	RAISE FND_API.G_EXC_ERROR ;
    ELSE
       IF ((l_prior_year_seq  is not null and
	    l_prior_seq is not null) and
	    l_prior_year_seq <> l_prior_seq ) OR
	  ((l_next_year_seq  is not null and
	     l_next_seq is not null) and
	     l_next_year_seq <> l_next_seq ) THEN
		FND_MESSAGE.SET_NAME('PSB', 'PSB_YEAR_TYPE_MUST_BE_CONSEC');
		FND_MSG_PUB.Add ;
		RAISE FND_API.G_EXC_ERROR ;
	END IF ;
    END IF;
  END IF;
  --
  IF (p_mode_type = 'D') THEN
    IF (p_curr_start_date  = l_prior_end_date + 1 )  AND
       (p_curr_end_date    = l_next_start_date - 1 ) THEN
       FND_MESSAGE.SET_NAME('PSB', 'PSB_CANNOT_DELETE_YEAR');
       FND_MSG_PUB.Add ;
       RAISE FND_API.G_EXC_ERROR ;
    END IF;
  END IF;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);
  --
  --
EXCEPTION
   --
   when FND_API.G_EXC_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
     --
END Check_Consecutive_Year_Types ;
--
PROCEDURE Create_Child_Periods
 (p_calendar_id   IN NUMBER,
  p_parent_id     IN NUMBER,
  p_parent_name   IN VARCHAR2,
  p_start_date    IN DATE,
  p_end_date      IN DATE,
  p_child_type    IN VARCHAR2,
  p_period_type   IN VARCHAR2,
  p_return_status OUT  NOCOPY VARCHAR2,
  p_msg_count     OUT  NOCOPY NUMBER,
  p_msg_data      OUT  NOCOPY VARCHAR2
  ) IS
  --
  l_start_date       DATE;
  l_end_date         DATE;
  l_lstart_date      DATE;
  l_short_name       VARCHAR2(30);
  l_counter          NUMBER;
  l_budget_period_id NUMBER;
  l_return_status    VARCHAR2(1);
  l_rowid            VARCHAR2(100);
  l_requery          VARCHAR2(1);
  --
BEGIN
  --
  l_start_date := p_start_date ;
  l_end_date   := p_start_date ;
  l_counter    := 1 ;
  --
  WHILE l_end_date < p_end_date LOOP
    --
    -- The end date of the child period is calculated by
    -- 1) Find the Start Date of the last month
    --    For example if type is QTR then add 2 months to the
    --    start date to determine start date of last month
    -- 2) End Date is End Date of the last month
    --
    IF p_child_type = G_MONTH THEN
       l_lstart_date := l_start_date ;
    ELSIF p_child_type = G_QTR THEN
       l_lstart_date := ADD_MONTHS(l_start_date, G_QTR_NUM);
    ELSIF p_child_type = G_SEMI THEN
       l_lstart_date := ADD_MONTHS(l_start_date, G_SEMI_NUM) ;
    END IF;
    --
    l_end_date := LAST_DAY(l_lstart_date) ;
    l_short_name := substr(p_parent_name, 1, 10)||'-'||to_char(l_counter);
    --
    SELECT psb_budget_periods_s.nextval
      INTO l_budget_period_id
      FROM dual;
    --
    --
    INSERT_ROW (
      p_api_version              => 1.0,
      p_init_msg_list            => fnd_api.g_false,
      p_commit                   => fnd_api.g_false,
      p_validation_level         => fnd_api.g_valid_level_full,
      p_return_status            => l_return_status,
      p_msg_count                => p_msg_count,
      p_msg_data                 => p_msg_data,
      p_rowid                    => l_rowid,
      p_budget_period_id         => l_budget_period_id,
      p_budget_calendar_id       => p_calendar_id,
      p_description              => l_short_name,
      p_start_date               => l_start_date,
      p_end_date                 => l_end_date ,
      p_name                     => l_short_name,
      p_budget_year_type_id      => null,
      p_parent_budget_period_id  => p_parent_id,
      p_budget_period_type       => p_period_type,
      p_period_distribution_type => null,
      p_calculation_period_type  => null,
      p_attribute1               => null,
      p_attribute2               => null,
      p_attribute3               => null,
      p_attribute4               => null,
      p_attribute5               => null,
      p_attribute6               => null,
      p_attribute7               => null,
      p_attribute8               => null,
      p_attribute9               => null,
      p_attribute10              => null,
      p_context                  => null,
      p_mode                     => 'R',
      p_requery                  => l_requery
      );
    --
    IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
    --p_requery := 'N';
    l_start_date := l_end_date + 1 ;
    l_counter    := l_counter + 1 ;
    --
  END LOOP;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
EXCEPTION

   when FND_API.G_EXC_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_ERROR;
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
END Create_Child_Periods ;
--
PROCEDURE Create_Budget_Periods
 (p_calendar_id        IN NUMBER,
  p_year_id            IN NUMBER,
  p_year_name          IN VARCHAR2,
  p_start_date         IN DATE,
  p_end_date           IN DATE,
  p_budget_period_type IN VARCHAR2,
  p_period_record_type IN VARCHAR2,
  p_return_status      OUT  NOCOPY VARCHAR2,
  p_msg_count          OUT  NOCOPY NUMBER,
  p_msg_data           OUT  NOCOPY VARCHAR2) IS
  --
  l_return_status VARCHAR2(1);
  --
BEGIN
  --
     Create_Child_Periods (p_calendar_id   => p_calendar_id,
			   p_parent_id     => p_year_id,
			   p_parent_name   => p_year_name,
			   p_start_date    => p_start_date,
			   p_end_date      => p_end_date,
			   p_child_type    => p_budget_period_type,
			   p_period_type   => p_period_record_type,
			   p_return_status => l_return_status,
			   p_msg_count     => p_msg_count,
			   p_msg_data      => p_msg_data);
     --
      IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR ;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
      END IF;
  --
EXCEPTION

   when FND_API.G_EXC_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_ERROR;
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
END Create_Budget_Periods ;
--
PROCEDURE Create_New_Distr_Calc_Period(
  p_calendar_id         IN      NUMBER,
  p_year_id             IN      NUMBER,
  p_year_name           IN      VARCHAR2,
  p_start_date          IN      DATE,
  p_end_date            IN      DATE,
  p_budget_period_type  IN      VARCHAR2,
  p_calc_period_type    IN      VARCHAR2,
  p_update_dist         IN      VARCHAR2,
  p_update_calc         IN      VARCHAR2,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2
) IS
--
  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_Periods';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_return_status       VARCHAR2(1);
--
BEGIN

  -- Initialize API return status to success

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  --  delete existing budget periods and create new ones

  IF (p_update_dist  = 'Y') THEN

  -- delete old distribution lines

       delete from psb_budget_periods where
	  budget_calendar_id = p_calendar_id
	  AND parent_budget_period_id = p_year_id
	  AND budget_period_type = 'P';
       if sql%notfound then
	  null;
       end if;

  -- create new budget periods only if distribution type <> 'Y'

    IF p_budget_period_type <> 'Y' THEN

	  Create_Budget_Periods(
			p_calendar_id        => p_calendar_id,
			p_year_id            => p_year_id,
			p_year_name          => p_year_name,
			p_start_date         => p_start_date,
			p_end_date           => p_end_date,
			p_budget_period_type => p_budget_period_type,
			p_period_record_type => 'P',
			p_return_status      => l_return_status,
			p_msg_count          => p_msg_count,
			p_msg_data           => p_msg_data);
	   IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
		 RAISE FND_API.G_EXC_ERROR ;
	   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	   END IF;

    END IF;

  END IF;

  --
  -- delete current calc records and create new ones

  IF (p_update_calc = 'Y') THEN

       delete from psb_budget_periods where
	  budget_calendar_id = p_calendar_id
	  AND parent_budget_period_id = p_year_id
	  AND budget_period_type = 'C' ;
       if sql%notfound then
	  null;
       end if;

   -- create new calc only if calc type is M/S/Q
      IF (p_calc_period_type = 'M'  OR
	  p_calc_period_type = 'S'  OR
	  p_calc_period_type = 'Q'  )
      THEN
	 Create_Budget_Periods(
			p_calendar_id        => p_calendar_id,
			p_year_id            => p_year_id,
			p_year_name          => p_year_name,
			p_start_date         => p_start_date,
			p_end_date           => p_end_date,
			p_budget_period_type => p_calc_period_type,
			p_period_record_type => 'C',
			p_return_status      => l_return_status,
			p_msg_count          => p_msg_count,
			p_msg_data           => p_msg_data);
	  IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR ;
	  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	  END IF;

      END IF;

  END IF;

  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
EXCEPTION

   when FND_API.G_EXC_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_ERROR;
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
END Create_New_Distr_Calc_Period;
----
PROCEDURE Create_Periods(
  p_calendar_id         IN      NUMBER,
  p_year_id             IN      NUMBER,
  p_year_name           IN      VARCHAR2,
  p_start_date          IN      DATE,
  p_end_date            IN      DATE,
  p_budget_period_type  IN      VARCHAR2,
  p_calc_period_type    IN      VARCHAR2,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2
) IS
--
  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_Periods';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_return_status       VARCHAR2(1);
--
BEGIN

  -- Initialize API return status to success

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF p_budget_period_type <> 'Y' THEN

       Create_Budget_Periods(
			p_calendar_id        => p_calendar_id,
			p_year_id            => p_year_id,
			p_year_name          => p_year_name,
			p_start_date         => p_start_date,
			p_end_date           => p_end_date,
			p_budget_period_type => p_budget_period_type,
			p_period_record_type => 'P',
			p_return_status      => l_return_status,
			p_msg_count          => p_msg_count,
			p_msg_data           => p_msg_data);
	IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR ;
	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	END IF;
  END IF;

  --
  IF (p_calc_period_type = 'M' OR
      p_calc_period_type = 'S' OR
      p_calc_period_type = 'Q' )
     THEN

       Create_Budget_Periods(
			p_calendar_id        => p_calendar_id,
			p_year_id            => p_year_id,
			p_year_name          => p_year_name,
			p_start_date         => p_start_date,
			p_end_date           => p_end_date,
			p_budget_period_type => p_calc_period_type,
			p_period_record_type => 'C',
			p_return_status      => l_return_status,
			p_msg_count          => p_msg_count,
			p_msg_data           => p_msg_data);

     IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
	   RAISE FND_API.G_EXC_ERROR ;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
     END IF;

  END IF;

  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
EXCEPTION

   when FND_API.G_EXC_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_ERROR;
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
END Create_Periods ;
--
PROCEDURE Copy_Years_In_Calendar(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_source_cal_id       IN      NUMBER,
  p_target_cal_id       IN      NUMBER,
  p_shift_flag          IN      VARCHAR2) IS
--
CURSOR cal_years_csr IS
	 SELECT a.budget_calendar_id,
		a.description,
		a.start_date,
		a.end_date,
		a.name,
		a.budget_year_type_id,
		a.parent_budget_period_id,
		a.budget_period_type,
		a.period_distribution_type,
		a.calculation_period_type,
		a.attribute1,
		a.attribute2,
		a.attribute3,
		a.attribute4,
		a.attribute5,
		a.attribute6,
		a.attribute7,
		a.attribute8,
		a.attribute9,
		a.attribute10,
		a.context,
		b.year_category_type
	   FROM psb_budget_periods    a,
		psb_budget_year_types b
	  WHERE budget_calendar_id    = p_source_cal_id
	    AND a.budget_year_type_id = b.budget_year_type_id
	  ORDER BY start_date;
--
  l_prev_year_type_id   NUMBER ;
CURSOR prev_type_csr IS
       SELECT a.year_category_type,a.budget_year_type_id
	 FROM psb_budget_year_types a,
	      psb_budget_year_types b
	WHERE a.sequence_number < b.sequence_number
	  AND b.budget_year_type_id =   l_prev_year_type_id
	ORDER BY a.sequence_number DESC;
--
  l_api_name            CONSTANT VARCHAR2(30)   := 'Copy_Years_In_Calendar';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_first_rec           BOOLEAN := TRUE ;
  l_skip_first_rec      BOOLEAN := FALSE ;
  l_year_id             NUMBER ;
  l_year_type_id        NUMBER ;
  l_return_status       VARCHAR2(1);
  l_rowid               VARCHAR2(100);
  l_requery             VARCHAR2(1);
  l_calc_type           VARCHAR2(10);
  l_year_type           VARCHAR2(10);
--
BEGIN
  -- Standard Start of API savepoint

  SAVEPOINT     Copy_Years_In_Calendar;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  l_return_status := FND_API.G_RET_STS_SUCCESS;
  --

  FOR cal_years_rec IN cal_years_csr LOOP
   --
   -- If Shifting the calendar then need to move the years. For first
   -- year record, use immediate previous year type data, if found;
   -- otherwise, ignore the year record.
   --
   IF (l_first_rec AND p_shift_flag = 'Y') THEN
     l_first_rec := FALSE ;
     l_prev_year_type_id := cal_years_rec.budget_year_type_id ;

     OPEN prev_type_csr;
     FETCH  prev_type_csr into l_year_type, l_year_type_id;

     IF prev_type_csr%NOTFOUND THEN
	l_skip_first_rec := TRUE;
     ELSE
	l_skip_first_rec := FALSE;
     END IF;

     CLOSE prev_type_csr;
   END IF;

   IF l_skip_first_rec AND p_shift_flag = 'Y' THEN
      l_skip_first_rec := FALSE ;
      -- disregard first year to be shifted
   ELSE
      --
      SELECT psb_budget_periods_s.nextval
	INTO l_year_id
	FROM dual;
      --
      IF p_shift_flag = 'N' THEN
	 l_year_type_id := cal_years_rec.budget_year_type_id ;
	 l_year_type    := cal_years_rec.year_category_type ;
      END IF ;
      --
      IF l_year_type = 'PY' THEN
	 l_calc_type := NULL ;
      ELSE
	 l_calc_type := cal_years_rec.calculation_period_type ;
      END IF ;
      --
      INSERT_ROW (
      p_api_version              => 1.0,
      p_init_msg_list            => fnd_api.g_false,
      p_commit                   => fnd_api.g_false,
      p_validation_level         => fnd_api.g_valid_level_full,
      p_return_status            => l_return_status,
      p_msg_count                => p_msg_count,
      p_msg_data                 => p_msg_data,
      p_rowid                    => l_rowid,
      p_budget_period_id         => l_year_id,
      p_budget_calendar_id       => p_target_cal_id,
      p_description              => cal_years_rec.name,
      p_start_date               => cal_years_rec.start_date,
      p_end_date                 => cal_years_rec.end_date ,
      p_name                     => cal_years_rec.name,
      p_budget_year_type_id      => l_year_type_id,
      p_parent_budget_period_id  => null,
      p_budget_period_type       => 'Y',
      p_period_distribution_type => cal_years_rec.period_distribution_type,
      p_calculation_period_type  => l_calc_type,
      p_attribute1               => cal_years_rec.attribute1,
      p_attribute2               => cal_years_rec.attribute2,
      p_attribute3               => cal_years_rec.attribute3,
      p_attribute4               => cal_years_rec.attribute4,
      p_attribute5               => cal_years_rec.attribute5,
      p_attribute6               => cal_years_rec.attribute6,
      p_attribute7               => cal_years_rec.attribute7,
      p_attribute8               => cal_years_rec.attribute8,
      p_attribute9               => cal_years_rec.attribute9,
      p_attribute10              => cal_years_rec.attribute10,
      p_context                  => cal_years_rec.context,
      p_mode                     => 'R' ,
      p_requery                  => l_requery
      );
      --
      --
   END IF;
   --
   l_first_rec      := FALSE ;
   l_skip_first_rec := FALSE ;
   l_year_type_id := cal_years_rec.budget_year_type_id ;
   l_year_type    := cal_years_rec.year_category_type ;
   --
  END LOOP;
  --
  -- When copying calendar the period names of the target periods must
  -- same as the source. Since the Insert_Row creates it with default
  -- names we are updating it with source names
  --
  UPDATE psb_budget_periods a
     SET (name, description) =
			      (SELECT name, description
				 FROM psb_budget_periods b
				WHERE budget_calendar_id = p_source_cal_id
				  AND budget_period_type = 'P'
				  AND b.start_date       = a.start_date)
   WHERE a.budget_calendar_id = p_target_cal_id
     AND a.budget_period_type = 'P' ;
  --
  --
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
EXCEPTION

   when FND_API.G_EXC_ERROR then
     --
     rollback to Copy_Years_In_Calendar;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to Copy_Years_In_Calendar;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to Copy_Years_In_Calendar ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
END Copy_Years_In_Calendar;
--
--

PROCEDURE Check_Used_In_WS
	(p_calendar_id          IN NUMBER,
	 p_return_status        OUT  NOCOPY VARCHAR2) IS
--
 l_type_count   NUMBER ;
--
BEGIN
 --
 SELECT count(*)
   INTO l_type_count
   FROM PSB_WORKSHEETS
  WHERE budget_calendar_id  = p_calendar_id;
 --
 IF l_type_count > 0 THEN
    FND_MESSAGE.SET_NAME('PSB', 'PSB_CALENDAR_USED_IN_WORKSHEET');
    FND_MSG_PUB.Add ;
    RAISE FND_API.G_EXC_ERROR ;
 END IF;
 --
 p_return_status := FND_API.G_RET_STS_SUCCESS ;
 --
EXCEPTION
   --
   when FND_API.G_EXC_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_ERROR;
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
END Check_Used_In_WS;

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

END PSB_BUDGET_PERIOD_PVT ;

/
