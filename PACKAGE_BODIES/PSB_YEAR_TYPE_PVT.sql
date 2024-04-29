--------------------------------------------------------
--  DDL for Package Body PSB_YEAR_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_YEAR_TYPE_PVT" AS
/* $Header: PSBVYTPB.pls 120.2 2005/07/13 11:31:51 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_Year_Type_PVT';
  G_DBUG              VARCHAR2(1500);

/* ----------------------------------------------------------------------- */

PROCEDURE Check_Unique_Sequence
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_year_type_id        IN      NUMBER,
  p_year_type_seq       IN      NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique_Sequence';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_seq_count           NUMBER ;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Check_Unique_Sequence;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  SELECT count(*)
    INTO l_seq_count
    FROM psb_budget_year_types
   WHERE sequence_number      = p_year_type_seq
     AND ((p_year_type_id  IS NULL ) OR
	  ( budget_year_type_id <> p_year_type_id)) ;
  --
  if l_seq_count > 0 then
     FND_MESSAGE.Set_Name('PSB', 'PSB_DUP_YEAR_TYPE_SEQ');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  end if;
  --

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Check_Unique_Sequence;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Check_Unique_Sequence ;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Check_Unique_Sequence;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Check_Unique_Sequence;
--
--
PROCEDURE Check_Sequence
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_year_type           IN      VARCHAR2,
  p_year_type_seq       In      NUMBER) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Sequence';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_py_max              NUMBER;
  l_pp_min              NUMBER;
  l_cy_min              NUMBER;
  l_dummy               NUMBER;
--
 CURSOR ytp_csr IS
 SELECT max(decode(year_category_type, 'PY', sequence_number)),
	min(decode(year_category_type, 'PP', sequence_number)),
	min(decode(year_category_type, 'CY', sequence_number)),
	1
   FROM psb_budget_year_types
  GROUP BY 1 ;
--
BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Check_Sequence;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  open ytp_csr ;
  fetch ytp_csr into l_py_max, l_pp_min, l_cy_min, l_dummy ;
  close ytp_csr ;
  --
  if p_year_type = 'PY' then
     if p_year_type_seq > l_cy_min then
	FND_MESSAGE.Set_name ('PSB', 'PSB_PY_GREATER_THAN_CY');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
     end if;
     --
     if p_year_type_seq > l_pp_min then
	FND_MESSAGE.Set_name ('PSB', 'PSB_PY_GREATER_THAN_PP');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
     end if;
  end if;
  --
  --
  if p_year_type = 'CY' then
     if p_year_type_seq < l_py_max then
	FND_MESSAGE.Set_name ('PSB', 'PSB_PY_GREATER_THAN_CY');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
     end if;
     --
     if p_year_type_seq > l_pp_min then
	FND_MESSAGE.Set_name ('PSB', 'PSB_CY_GREATER_THAN_PP');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
     end if;
  end if;
  --
  --
  if p_year_type = 'PP' then
     if p_year_type_seq < l_cy_min then
	FND_MESSAGE.Set_name ('PSB', 'PSB_CY_GREATER_THAN_PP');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
     end if;
     --
     if p_year_type_seq < l_py_max then
	FND_MESSAGE.Set_name ('PSB', 'PSB_PY_GREATER_THAN_PP');
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
     end if;
  end if;
  --
  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Check_Sequence ;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Check_Sequence;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Check_Sequence;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Check_Sequence;
--
--
PROCEDURE Check_CY_Count
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_year_type_id        IN      NUMBER)
 IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_CY_Count';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_cy_count            NUMBER ;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Check_CY_Count;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  SELECT count(*)
    INTO l_cy_count
    FROM psb_budget_year_types
   WHERE year_category_type   = 'CY'
     AND ((p_year_type_id IS NULL) OR
	  (budget_year_type_id <> p_year_type_id));
  --
  if l_cy_count > 0 then
     FND_MESSAGE.Set_Name('PSB', 'PSB_DUP_CY_TYPE');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR ;
  end if;
  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Check_CY_Count;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Check_CY_Count;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Check_CY_Count;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Check_CY_Count;
--
--
PROCEDURE Check_Reference
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_year_type_id        IN      NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Reference';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_dummy               NUMBER ;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Check_Ref_Integrity;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  SELECT 1
    INTO l_dummy
    FROM dual
   WHERE NOT EXISTS
	 (SELECT 1
	    FROM psb_budget_periods
	   WHERE budget_year_type_id = p_year_type_id);
  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when NO_DATA_FOUND then

     FND_MESSAGE.Set_Name('PSB', 'PSB_CANNOT_DELETE_YTP');
     FND_MSG_PUB.Add;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_ERROR then

     rollback to Check_Ref_Integrity;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Check_Ref_Integrity;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Check_Ref_Integrity;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;


     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Check_Reference ;
--
--
PROCEDURE Check_Unique_Name
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_year_type_id        IN      NUMBER,
  p_name                IN      VARCHAR2
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique_Name';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_seq_count           NUMBER ;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Check_Unique_Name;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  SELECT count(*)
    INTO l_seq_count
    FROM psb_budget_year_types
   WHERE name      = p_name
     AND ((p_year_type_id  IS NULL ) OR
	  ( budget_year_type_id <> p_year_type_id)) ;
  --
  if l_seq_count > 0 then
     FND_MESSAGE.Set_Name('PSB', 'PSB_DUPLICATE_NAME');
     FND_MSG_PUB.Add;
     RAISE FND_API.G_EXC_ERROR;
  end if;
  --

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Check_Unique_Name;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Check_Unique_Name ;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Check_Unique_Name;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Check_Unique_Name;
--
--


/* ----------------------------------------------------------------------- */

  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for this routine. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

  FUNCTION get_debug RETURN VARCHAR2 IS

  BEGIN

    return(g_dbug);

  END get_debug;

/* ----------------------------------------------------------------------- */

procedure INSERT_ROW
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
--
  p_ROWID in OUT  NOCOPY VARCHAR2,
  p_BUDGET_YEAR_TYPE_ID in NUMBER,
  p_YEAR_CATEGORY_TYPE in VARCHAR2,
  p_SEQUENCE_NUMBER in NUMBER,
  p_NAME in VARCHAR2,
  p_DESCRIPTION in VARCHAR2,
  p_CREATION_DATE in DATE,
  p_CREATED_BY in NUMBER,
  p_LAST_UPDATE_DATE in DATE,
  p_LAST_UPDATED_BY in NUMBER,
  p_LAST_UPDATE_LOGIN in NUMBER
) is

  l_api_name            CONSTANT VARCHAR2(30)   := 'INSERT_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_seq_count           NUMBER ;

  cursor C is select ROWID from PSB_BUDGET_YEAR_TYPES
    where BUDGET_YEAR_TYPE_ID = p_BUDGET_YEAR_TYPE_ID
    ;
BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Check_Unique_Name;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  insert into PSB_BUDGET_YEAR_TYPES (
    BUDGET_YEAR_TYPE_ID,
    YEAR_CATEGORY_TYPE,
    NAME,
    SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    p_BUDGET_YEAR_TYPE_ID,
    p_YEAR_CATEGORY_TYPE,
    p_NAME,
    p_SEQUENCE_NUMBER,
    p_CREATION_DATE,
    p_CREATED_BY,
    p_LAST_UPDATE_DATE,
    p_LAST_UPDATED_BY,
    p_LAST_UPDATE_LOGIN
  );

  insert into PSB_BUDGET_YEAR_TYPES_TL (
    BUDGET_YEAR_TYPE_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    p_BUDGET_YEAR_TYPE_ID,
    p_NAME,
    p_DESCRIPTION,
    p_LAST_UPDATE_DATE,
    p_LAST_UPDATED_BY,
    p_LAST_UPDATE_LOGIN,
    p_CREATED_BY,
    p_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PSB_BUDGET_YEAR_TYPES_TL T
    where T.BUDGET_YEAR_TYPE_ID = p_BUDGET_YEAR_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into p_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Check_Unique_Name;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Check_Unique_Name ;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Check_Unique_Name;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

end INSERT_ROW;


procedure LOCK_ROW
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
--
  p_BUDGET_YEAR_TYPE_ID in NUMBER,
  p_YEAR_CATEGORY_TYPE in VARCHAR2,
  p_SEQUENCE_NUMBER in NUMBER,
  p_NAME in VARCHAR2,
  p_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      YEAR_CATEGORY_TYPE,
      SEQUENCE_NUMBER
    from PSB_BUDGET_YEAR_TYPES
    where BUDGET_YEAR_TYPE_ID = p_BUDGET_YEAR_TYPE_ID
    for update of BUDGET_YEAR_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PSB_BUDGET_YEAR_TYPES_TL
    where BUDGET_YEAR_TYPE_ID = p_BUDGET_YEAR_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of BUDGET_YEAR_TYPE_ID nowait;

  l_api_name            CONSTANT VARCHAR2(30)   := 'LOCK_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Check_Unique_Name;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.YEAR_CATEGORY_TYPE = p_YEAR_CATEGORY_TYPE)
      AND (recinfo.SEQUENCE_NUMBER = p_SEQUENCE_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = p_NAME)
	  AND (tlinfo.DESCRIPTION = p_DESCRIPTION)
      ) then
	null;
      else
	fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Check_Unique_Name;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Check_Unique_Name ;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Check_Unique_Name;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

end LOCK_ROW;


procedure UPDATE_ROW
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
--
  p_BUDGET_YEAR_TYPE_ID in NUMBER,
  p_YEAR_CATEGORY_TYPE in VARCHAR2,
  p_SEQUENCE_NUMBER in NUMBER,
  p_NAME in VARCHAR2,
  p_DESCRIPTION in VARCHAR2,
  p_LAST_UPDATE_DATE in DATE,
  p_LAST_UPDATED_BY in NUMBER,
  p_LAST_UPDATE_LOGIN in NUMBER
) is

  l_api_name            CONSTANT VARCHAR2(30)   := 'UPDATE_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_seq_count           NUMBER ;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Check_Unique_Name;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  update PSB_BUDGET_YEAR_TYPES set
    YEAR_CATEGORY_TYPE = p_YEAR_CATEGORY_TYPE,
    SEQUENCE_NUMBER = p_SEQUENCE_NUMBER,
    LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = p_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN
  where BUDGET_YEAR_TYPE_ID = p_BUDGET_YEAR_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PSB_BUDGET_YEAR_TYPES_TL set
    NAME = p_NAME,
    DESCRIPTION = p_DESCRIPTION,
    LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = p_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where BUDGET_YEAR_TYPE_ID = p_BUDGET_YEAR_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Check_Unique_Name;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Check_Unique_Name ;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Check_Unique_Name;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

end UPDATE_ROW;

procedure DELETE_ROW
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_BUDGET_YEAR_TYPE_ID in NUMBER
) is

  l_api_name            CONSTANT VARCHAR2(30)   := 'DELETE_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Check_Unique_Name;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  delete from PSB_BUDGET_YEAR_TYPES_TL
  where BUDGET_YEAR_TYPE_ID = p_BUDGET_YEAR_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PSB_BUDGET_YEAR_TYPES
  where BUDGET_YEAR_TYPE_ID = p_BUDGET_YEAR_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Check_Unique_Name;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Check_Unique_Name ;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Check_Unique_Name;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PSB_BUDGET_YEAR_TYPES_TL T
  where not exists
    (select NULL
    from PSB_BUDGET_YEAR_TYPES B
    where B.BUDGET_YEAR_TYPE_ID = T.BUDGET_YEAR_TYPE_ID
    );

  update PSB_BUDGET_YEAR_TYPES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from PSB_BUDGET_YEAR_TYPES_TL B
    where B.BUDGET_YEAR_TYPE_ID = T.BUDGET_YEAR_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.BUDGET_YEAR_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.BUDGET_YEAR_TYPE_ID,
      SUBT.LANGUAGE
    from PSB_BUDGET_YEAR_TYPES_TL SUBB, PSB_BUDGET_YEAR_TYPES_TL SUBT
    where SUBB.BUDGET_YEAR_TYPE_ID = SUBT.BUDGET_YEAR_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <>  SUBT.DESCRIPTION
  ));

  insert into PSB_BUDGET_YEAR_TYPES_TL (
    BUDGET_YEAR_TYPE_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.BUDGET_YEAR_TYPE_ID,
    B.NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PSB_BUDGET_YEAR_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PSB_BUDGET_YEAR_TYPES_TL T
    where T.BUDGET_YEAR_TYPE_ID = B.BUDGET_YEAR_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END PSB_Year_Type_PVT ;

/
