--------------------------------------------------------
--  DDL for Package Body PSB_PAY_ELEMENT_RATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_PAY_ELEMENT_RATES_PVT" AS
/* $Header: PSBVRTSB.pls 120.2 2005/07/13 11:29:25 shtripat ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_PAY_ELEMENT_RATES_PVT';

  TYPE g_elemrates_rec_type IS RECORD
     ( pay_element_rate_id    NUMBER,
       pay_element_id         NUMBER,
       pay_element_option_id  NUMBER,
       effective_start_date   DATE,
       effective_end_date     DATE,
       worksheet_id           NUMBER,
       element_value_type     VARCHAR2(2),
       element_value          NUMBER,
       pay_basis              VARCHAR2(15),
       formula_id             NUMBER,
       maximum_value          NUMBER,
       mid_value              NUMBER,
       minimum_value          NUMBER,
       currency_code          VARCHAR2(10),
       proper_subset          VARCHAR2(1) );

  TYPE g_elemrates_tbl_type IS TABLE OF g_elemrates_rec_type
    INDEX BY BINARY_INTEGER;

  g_element_rates      g_elemrates_tbl_type;
  g_num_element_rates  NUMBER;

/* ----------------------------------------------------------------------- */

PROCEDURE INSERT_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_PAY_ELEMENT_RATE_ID              in      NUMBER,
  P_PAY_ELEMENT_OPTION_ID            in      NUMBER,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_EFFECTIVE_START_DATE             in      DATE,
  P_EFFECTIVE_END_DATE               in      DATE,
  P_WORKSHEET_ID                     in      NUMBER,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_ELEMENT_VALUE                    in      NUMBER,
  P_PAY_BASIS                        in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_MAXIMUM_VALUE                    in      NUMBER,
  P_MID_VALUE                        in      NUMBER,
  P_MINIMUM_VALUE                    in      NUMBER,
  P_CURRENCY_CODE                    IN      VARCHAR2,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER,
  P_CREATED_BY                       in      NUMBER,
  P_CREATION_DATE                    in      DATE
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'INSERT_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;
  l_row_id              varchar2(40);
  --
  cursor c1 is
     select ROWID from psb_pay_element_rates
     where pay_element_rate_id = p_pay_element_rate_id ;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     INSERT_ROW_PVT;

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
  INSERT INTO psb_pay_element_rates
  (
  PAY_ELEMENT_RATE_ID         ,
  PAY_ELEMENT_ID              ,
  PAY_ELEMENT_OPTION_ID       ,
  EFFECTIVE_START_DATE        ,
  EFFECTIVE_END_DATE          ,
  WORKSHEET_ID                ,
  ELEMENT_VALUE_TYPE          ,
  ELEMENT_VALUE               ,
  PAY_BASIS               ,
  FORMULA_ID                  ,
  MAXIMUM_VALUE               ,
  MID_VALUE                   ,
  MINIMUM_VALUE               ,
  CURRENCY_CODE               ,
  LAST_UPDATE_DATE            ,
  LAST_UPDATED_BY             ,
  LAST_UPDATE_LOGIN           ,
  CREATED_BY                  ,
  CREATION_DATE
  )
  VALUES
  (
  P_PAY_ELEMENT_RATE_ID         ,
  P_PAY_ELEMENT_ID              ,
  P_PAY_ELEMENT_OPTION_ID       ,
  P_EFFECTIVE_START_DATE        ,
  P_EFFECTIVE_END_DATE          ,
  P_WORKSHEET_ID                ,
  P_ELEMENT_VALUE_TYPE          ,
  P_ELEMENT_VALUE               ,
  P_PAY_BASIS                   ,
  P_FORMULA_ID                  ,
  P_MAXIMUM_VALUE               ,
  P_MID_VALUE                   ,
  P_MINIMUM_VALUE               ,
  P_CURRENCY_CODE               ,
  P_LAST_UPDATE_DATE            ,
  P_LAST_UPDATED_BY             ,
  P_LAST_UPDATE_LOGIN           ,
  P_CREATED_BY                  ,
  P_CREATION_DATE
  );

  open c1;
  fetch c1 into l_row_id;
  if (c1%notfound) then
    close c1;
    raise no_data_found;
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

     rollback to INSERT_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to INSERT_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to INSERT_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END INSERT_ROW;

/* ----------------------------------------------------------------------- */

PROCEDURE UPDATE_ROW
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  P_PAY_ELEMENT_RATE_ID              in      NUMBER,
  P_EFFECTIVE_START_DATE             in      DATE := FND_API.G_MISS_DATE,
  P_EFFECTIVE_END_DATE               in      DATE := FND_API.G_MISS_DATE,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_ELEMENT_VALUE                    in      NUMBER,
  P_PAY_BASIS                        in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_MAXIMUM_VALUE                    in      NUMBER,
  P_MID_VALUE                        in      NUMBER,
  P_MINIMUM_VALUE                    in      NUMBER,
  P_LAST_UPDATE_DATE                 in      DATE,
  P_LAST_UPDATED_BY                  in      NUMBER,
  P_LAST_UPDATE_LOGIN                in      NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'UPDATE_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     UPDATE_ROW_PVT;

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
  UPDATE psb_pay_element_rates SET
  EFFECTIVE_START_DATE         =  DECODE(P_EFFECTIVE_START_DATE, FND_API.G_MISS_DATE, EFFECTIVE_START_DATE, P_EFFECTIVE_START_DATE),
  EFFECTIVE_END_DATE           =  DECODE(P_EFFECTIVE_END_DATE, FND_API.G_MISS_DATE, EFFECTIVE_END_DATE, P_EFFECTIVE_END_DATE),
  ELEMENT_VALUE_TYPE           =  P_ELEMENT_VALUE_TYPE         ,
  ELEMENT_VALUE                =  P_ELEMENT_VALUE              ,
  PAY_BASIS                    =  P_PAY_BASIS                  ,
  FORMULA_ID                   =  P_FORMULA_ID                 ,
  MAXIMUM_VALUE                =  P_MAXIMUM_VALUE              ,
  MID_VALUE                    =  P_MID_VALUE                  ,
  MINIMUM_VALUE                =  P_MINIMUM_VALUE              ,
  LAST_UPDATE_DATE             =  P_LAST_UPDATE_DATE           ,
  LAST_UPDATED_BY              =  P_LAST_UPDATED_BY            ,
  LAST_UPDATE_LOGIN            =  P_LAST_UPDATE_LOGIN
  WHERE PAY_ELEMENT_RATE_ID = P_PAY_ELEMENT_RATE_ID;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
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

     rollback to UPDATE_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to UPDATE_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to UPDATE_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END UPDATE_ROW;

/* ----------------------------------------------------------------------- */

PROCEDURE DELETE_ROW
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  --
  P_PAY_ELEMENT_RATE_ID              in      NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'DELETE_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     DELETE_ROW_PVT;

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


  --Delete the record
  DELETE FROM psb_pay_element_rates
  WHERE pay_element_rate_id = p_pay_element_rate_id;


  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to DELETE_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to DELETE_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to DELETE_ROW_PVT;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
END DELETE_ROW;

/* ----------------------------------------------------------------------- */

PROCEDURE LOCK_ROW(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  --
  p_row_locked                  OUT  NOCOPY     VARCHAR2,
  --
  P_PAY_ELEMENT_RATE_ID              in      NUMBER,
  P_PAY_ELEMENT_OPTION_ID            in      NUMBER,
  P_PAY_ELEMENT_ID                   in      NUMBER,
  P_EFFECTIVE_START_DATE             in      DATE,
  P_EFFECTIVE_END_DATE               in      DATE,
  P_WORKSHEET_ID                     in      NUMBER,
  P_ELEMENT_VALUE_TYPE               in      VARCHAR2,
  P_ELEMENT_VALUE                    in      NUMBER,
  P_PAY_BASIS                        in      VARCHAR2,
  P_FORMULA_ID                       in      NUMBER,
  P_MAXIMUM_VALUE                    in      NUMBER,
  P_MID_VALUE                        in      NUMBER,
  P_MINIMUM_VALUE                    in      NUMBER,
  P_CURRENCY_CODE                    IN      VARCHAR2

  ) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'LOCK_ROW';
  l_api_version         CONSTANT NUMBER         := 1.0;
  --
  counter number;

  CURSOR C IS SELECT * FROM PSB_PAY_ELEMENT_RATES
  WHERE pay_element_rate_id = p_pay_element_rate_id
  FOR UPDATE of PAY_ELEMENT_RATE_Id NOWAIT;
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
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  p_row_locked    := FND_API.G_TRUE ;
  --
  OPEN C;
  --
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF
  (
	 (Recinfo.pay_element_rate_id =  p_pay_element_rate_id)
	 AND (Recinfo.pay_element_id = p_pay_element_id)
	 AND (Recinfo.effective_start_date = p_effective_start_date)

	 AND ( (Recinfo.pay_element_option_id = p_pay_element_option_id)
		 OR ( (Recinfo.pay_element_option_id IS NULL)
		       AND (p_pay_element_option_id IS NULL)))

	  AND ( (Recinfo.effective_end_date = p_effective_end_date)
		 OR ( (Recinfo.effective_end_date IS NULL)
		       AND (p_effective_end_date IS NULL)))

	  AND ( (Recinfo.worksheet_id =  p_worksheet_id)
		 OR ( (Recinfo.worksheet_id IS NULL)
		       AND (p_worksheet_id IS NULL)))

	  AND ( (Recinfo.element_value_type =  p_element_value_type)
		 OR ( (Recinfo.element_value_type IS NULL)
		       AND (p_element_value_type IS NULL)))

	  AND ( (Recinfo.element_value =  p_element_value)
		 OR ( (Recinfo.element_value IS NULL)
		       AND (p_element_value IS NULL)))

	  AND ( (Recinfo.pay_basis =  p_pay_basis)
		 OR ( (Recinfo.pay_basis IS NULL)
		       AND (p_pay_basis IS NULL)))

	  AND ( (Recinfo.formula_id =  p_formula_id)
		 OR ( (Recinfo.formula_id IS NULL)
		       AND (p_formula_id IS NULL)))

	  AND ( (Recinfo.maximum_value =  p_maximum_value)
		 OR ( (Recinfo.maximum_value IS NULL)
		       AND (p_maximum_value IS NULL)))

	  AND ( (Recinfo.mid_value =  p_mid_value)
		 OR ( (Recinfo.mid_value IS NULL)
		       AND (p_mid_value IS NULL)))

	  AND ( (Recinfo.minimum_value =  p_minimum_value)
		 OR ( (Recinfo.minimum_value IS NULL)
		       AND (p_minimum_value IS NULL)))

	  AND ( (Recinfo.currency_code = p_currency_code)
		 OR ( (Recinfo.currency_code IS NULL)
		       AND (p_currency_code IS NULL)))
   )

  THEN
    Null;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
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
  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_row_locked := FND_API.G_FALSE;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
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
END LOCK_ROW;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_Element_Rates
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30) := 'Delete_Element_Rates';
  l_api_version       CONSTANT NUMBER       := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Delete_Element_Rates_Pvt;


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

  delete from PSB_PAY_ELEMENT_RATES
   where worksheet_id = p_worksheet_id;


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
     rollback to Delete_Element_Rates_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Delete_Element_Rates_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then
     rollback to Delete_Element_Rates_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Delete_Element_Rates;

/* ----------------------------------------------------------------------- */

PROCEDURE Modify_Element_Rates
( p_api_version            IN   NUMBER,
  p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status          OUT  NOCOPY  VARCHAR2,
  p_msg_count              OUT  NOCOPY  NUMBER,
  p_msg_data               OUT  NOCOPY  VARCHAR2,
  p_pay_element_id         IN   NUMBER,
  p_pay_element_option_id  IN   NUMBER,
  p_effective_start_date   IN   DATE,
  p_effective_end_date     IN   DATE,
  p_worksheet_id           IN   NUMBER,
  p_element_value_type     IN   VARCHAR2,
  p_element_value          IN   NUMBER,
  p_pay_basis              IN   VARCHAR2,
  p_formula_id             IN   NUMBER,
  p_maximum_value          IN   NUMBER,
  p_mid_value              IN   NUMBER,
  p_minimum_value          IN   NUMBER,
  p_currency_code          IN   VARCHAR2
) IS

  l_api_name               CONSTANT VARCHAR2(30) := 'Modify_Element_Rates';
  l_api_version            CONSTANT NUMBER       := 1.0;

  cursor c_Seq is
    select psb_pay_element_rates_s.nextval RateID
      from dual;

  cursor c_Rates is
    select pay_element_rate_id,
	   pay_element_id,
	   pay_element_option_id,
	   effective_start_date,
	   effective_end_date,
	   worksheet_id,
	   element_value_type,
	   element_value,
	   pay_basis,
	   formula_id,
	   maximum_value,
	   mid_value,
	   minimum_value,
	   currency_code
      from PSB_PAY_ELEMENT_RATES
     where nvl(pay_element_option_id, FND_API.G_MISS_NUM) = nvl(p_pay_element_option_id, FND_API.G_MISS_NUM)
       and nvl(worksheet_id, FND_API.G_MISS_NUM) = nvl(p_worksheet_id, FND_API.G_MISS_NUM)
       and nvl(currency_code, FND_API.G_MISS_CHAR) = nvl(p_currency_code, FND_API.G_MISS_CHAR)
       and ((((p_effective_end_date is not null)
	and ((effective_start_date <= p_effective_end_date)
	 and (effective_end_date is null))
	 or ((effective_start_date between p_effective_start_date and p_effective_end_date)
	  or (effective_end_date between p_effective_start_date and p_effective_end_date)
	 or ((effective_start_date < p_effective_start_date)
	 and (effective_end_date > p_effective_end_date)))))
       or ((p_effective_end_date is null)
       and (nvl(effective_end_date, p_effective_start_date) >= p_effective_start_date)))
       and pay_element_id = p_pay_element_id;

  l_userid                 NUMBER;
  l_loginid                NUMBER;

  l_init_index             BINARY_INTEGER;
  l_rate_index             BINARY_INTEGER;

  l_pay_element_rate_id    NUMBER;

  l_created_record         VARCHAR2(1) := FND_API.G_FALSE;
  l_updated_record         VARCHAR2(1);

  l_return_status          VARCHAR2(1);

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Modify_Element_Rates_Pvt;


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

  for l_init_index in 1..g_element_rates.Count loop
    g_element_rates(l_init_index).pay_element_rate_id := null;
    g_element_rates(l_init_index).pay_element_id := null;
    g_element_rates(l_init_index).pay_element_option_id := null;
    g_element_rates(l_init_index).effective_start_date := null;
    g_element_rates(l_init_index).effective_end_date := null;
    g_element_rates(l_init_index).worksheet_id := null;
    g_element_rates(l_init_index).element_value_type := null;
    g_element_rates(l_init_index).element_value := null;
    g_element_rates(l_init_index).pay_basis := null;
    g_element_rates(l_init_index).formula_id := null;
    g_element_rates(l_init_index).maximum_value := null;
    g_element_rates(l_init_index).mid_value := null;
    g_element_rates(l_init_index).minimum_value := null;
    g_element_rates(l_init_index).currency_code := null;
    g_element_rates(l_init_index).proper_subset := null;
  end loop;

  g_num_element_rates := 0;

  for c_Rates_Rec in c_Rates loop
    g_num_element_rates := g_num_element_rates + 1;

    g_element_rates(g_num_element_rates).pay_element_rate_id := c_Rates_Rec.pay_element_rate_id;
    g_element_rates(g_num_element_rates).pay_element_id := c_Rates_Rec.pay_element_id;
    g_element_rates(g_num_element_rates).pay_element_option_id := c_Rates_Rec.pay_element_option_id;
    g_element_rates(g_num_element_rates).effective_start_date := c_Rates_Rec.effective_start_date;
    g_element_rates(g_num_element_rates).effective_end_date := c_Rates_Rec.effective_end_date;
    g_element_rates(g_num_element_rates).worksheet_id := c_Rates_Rec.worksheet_id;
    g_element_rates(g_num_element_rates).element_value_type := c_Rates_Rec.element_value_type;
    g_element_rates(g_num_element_rates).element_value := c_Rates_Rec.element_value;
    g_element_rates(g_num_element_rates).pay_basis := c_Rates_Rec.pay_basis;
    g_element_rates(g_num_element_rates).formula_id := c_Rates_Rec.formula_id;
    g_element_rates(g_num_element_rates).maximum_value := c_Rates_Rec.maximum_value;
    g_element_rates(g_num_element_rates).mid_value := c_Rates_Rec.mid_value;
    g_element_rates(g_num_element_rates).minimum_value := c_Rates_Rec.minimum_value;
    g_element_rates(g_num_element_rates).currency_code := c_Rates_Rec.currency_code;

    if (((p_effective_end_date is not null) and
	 (c_Rates_Rec.effective_start_date between p_effective_start_date and p_effective_end_date) and
	 (c_Rates_Rec.effective_end_date between p_effective_start_date and p_effective_end_date)) or
	((p_effective_end_date is null) and
	 (c_Rates_Rec.effective_start_date >= p_effective_start_date))) then
      g_element_rates(g_num_element_rates).proper_subset := FND_API.G_TRUE;
    else
      g_element_rates(g_num_element_rates).proper_subset := FND_API.G_FALSE;
    end if;

  end loop;

  if g_num_element_rates = 0 then
  begin

    for c_Seq_Rec in c_Seq loop
      l_pay_element_rate_id := c_Seq_Rec.RateID;
    end loop;

    Insert_Row
	  (p_api_version => 1.0,
	   p_return_status => l_return_status,
	   p_msg_count => p_msg_count,
	   p_msg_data => p_msg_data,
	   p_pay_element_rate_id => l_pay_element_rate_id,
	   p_pay_element_option_id => p_pay_element_option_id,
	   p_pay_element_id => p_pay_element_id,
	   p_effective_start_date => p_effective_start_date,
	   p_effective_end_date => p_effective_end_date,
	   p_worksheet_id => p_worksheet_id,
	   p_element_value_type => p_element_value_type,
	   p_element_value => p_element_value,
	   p_pay_basis => p_pay_basis,
	   p_formula_id => p_formula_id,
	   p_maximum_value => p_maximum_value,
	   p_mid_value => p_mid_value,
	   p_minimum_value => p_minimum_value,
	   p_currency_code => p_currency_code,
	   p_last_update_date => sysdate,
	   p_last_updated_by => l_userid,
	   p_last_update_login => l_loginid,
	   p_created_by => l_userid,
	   p_creation_date => sysdate);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  else
  begin

    for l_rate_index in 1..g_num_element_rates loop

      l_updated_record := FND_API.G_FALSE;

      if ((g_num_element_rates = 1) and
	  (g_element_rates(l_rate_index).effective_start_date = p_effective_start_date)) then
      begin

	Update_Row
	      (p_api_version => 1.0,
	       p_return_status => l_return_status,
	       p_msg_count => p_msg_count,
	       p_msg_data => p_msg_data,
	       p_pay_element_rate_id => g_element_rates(l_rate_index).pay_element_rate_id,
	       p_effective_end_date => p_effective_end_date,
	       p_element_value_type => p_element_value_type,
	       p_element_value => p_element_value,
	       p_pay_basis => p_pay_basis,
	       p_formula_id => p_formula_id,
	       p_maximum_value => p_maximum_value,
	       p_mid_value => p_mid_value,
	       p_minimum_value => p_minimum_value,
	       p_last_update_date => sysdate,
	       p_last_updated_by => l_userid,
	       p_last_update_login => l_loginid);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      else
      begin

	if ((g_element_rates(l_rate_index).effective_start_date < (p_effective_start_date - 1)) and
	   ((g_element_rates(l_rate_index).effective_end_date is null) or
	    (g_element_rates(l_rate_index).effective_end_date > (p_effective_start_date - 1)))) then
	begin

	  Update_Row
		(p_api_version => 1.0,
		 p_return_status => l_return_status,
		 p_msg_count => p_msg_count,
		 p_msg_data => p_msg_data,
		 p_pay_element_rate_id => g_element_rates(l_rate_index).pay_element_rate_id,
		 p_effective_end_date => p_effective_start_date - 1,
		 p_element_value_type => g_element_rates(l_rate_index).element_value_type,
		 p_element_value => g_element_rates(l_rate_index).element_value,
		 p_pay_basis => g_element_rates(l_rate_index).pay_basis,
		 p_formula_id => g_element_rates(l_rate_index).formula_id,
		 p_maximum_value => g_element_rates(l_rate_index).maximum_value,
		 p_mid_value => g_element_rates(l_rate_index).mid_value,
		 p_minimum_value => g_element_rates(l_rate_index).minimum_value,
		 p_last_update_date => sysdate,
		 p_last_updated_by => l_userid,
		 p_last_update_login => l_loginid);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  else
	    l_updated_record := FND_API.G_TRUE;
	  end if;

	end;
	elsif ((g_element_rates(l_rate_index).effective_start_date > p_effective_start_date) and
	      ((p_effective_end_date is not null) and
	      ((g_element_rates(l_rate_index).effective_end_date is null) or
	       (g_element_rates(l_rate_index).effective_end_date > (p_effective_end_date + 1))))) then
	begin

	  Update_Row
		(p_api_version => 1.0,
		 p_return_status => l_return_status,
		 p_msg_count => p_msg_count,
		 p_msg_data => p_msg_data,
		 p_pay_element_rate_id => g_element_rates(l_rate_index).pay_element_rate_id,
		 p_effective_start_date => p_effective_end_date + 1,
		 p_element_value_type => g_element_rates(l_rate_index).element_value_type,
		 p_element_value => g_element_rates(l_rate_index).element_value,
		 p_pay_basis => g_element_rates(l_rate_index).pay_basis,
		 p_formula_id => g_element_rates(l_rate_index).formula_id,
		 p_maximum_value => g_element_rates(l_rate_index).maximum_value,
		 p_mid_value => g_element_rates(l_rate_index).mid_value,
		 p_minimum_value => g_element_rates(l_rate_index).minimum_value,
		 p_last_update_date => sysdate,
		 p_last_updated_by => l_userid,
		 p_last_update_login => l_loginid);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  else
	    l_updated_record := FND_API.G_TRUE;
	  end if;

	end;
	end if;

	if not FND_API.to_Boolean(l_created_record) then
	begin

	  for c_Seq_Rec in c_Seq loop
	    l_pay_element_rate_id := c_Seq_Rec.RateID;
	  end loop;

	  Insert_Row
		(p_api_version => 1.0,
		 p_return_status => l_return_status,
		 p_msg_count => p_msg_count,
		 p_msg_data => p_msg_data,
		 p_pay_element_rate_id => l_pay_element_rate_id,
		 p_pay_element_option_id => p_pay_element_option_id,
		 p_pay_element_id => p_pay_element_id,
		 p_effective_start_date => p_effective_start_date,
		 p_effective_end_date => p_effective_end_date,
		 p_worksheet_id => p_worksheet_id,
		 p_element_value_type => p_element_value_type,
		 p_element_value => p_element_value,
		 p_pay_basis => p_pay_basis,
		 p_formula_id => p_formula_id,
		 p_maximum_value => p_maximum_value,
		 p_mid_value => p_mid_value,
		 p_minimum_value => p_minimum_value,
		 p_currency_code => p_currency_code,
		 p_last_update_date => sysdate,
		 p_last_updated_by => l_userid,
		 p_last_update_login => l_loginid,
		 p_created_by => l_userid,
		 p_creation_date => sysdate);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  else
	    l_created_record := FND_API.G_TRUE;
	  end if;

	end;
	end if;

	if p_effective_end_date is not null then
	begin

	  if nvl(g_element_rates(l_rate_index).effective_end_date, (p_effective_end_date + 1)) > (p_effective_end_date + 1) then
	  begin

	    if FND_API.to_Boolean(l_updated_record) then
	    begin

	      for c_Seq_Rec in c_Seq loop
		l_pay_element_rate_id := c_Seq_Rec.RateID;
	      end loop;

	      Insert_Row
		    (p_api_version => 1.0,
		     p_return_status => l_return_status,
		     p_msg_count => p_msg_count,
		     p_msg_data => p_msg_data,
		     p_pay_element_rate_id => l_pay_element_rate_id,
		     p_pay_element_option_id => g_element_rates(l_rate_index).pay_element_option_id,
		     p_pay_element_id => g_element_rates(l_rate_index).pay_element_id,
		     p_effective_start_date => p_effective_end_date + 1,
		     p_effective_end_date => g_element_rates(l_rate_index).effective_end_date,
		     p_worksheet_id => g_element_rates(l_rate_index).worksheet_id,
		     p_element_value_type => g_element_rates(l_rate_index).element_value_type,
		     p_element_value => g_element_rates(l_rate_index).element_value,
		     p_pay_basis => g_element_rates(l_rate_index).pay_basis,
		     p_formula_id => g_element_rates(l_rate_index).formula_id,
		     p_maximum_value => g_element_rates(l_rate_index).maximum_value,
		     p_mid_value => g_element_rates(l_rate_index).mid_value,
		     p_minimum_value => g_element_rates(l_rate_index).minimum_value,
		     p_currency_code => g_element_rates(l_rate_index).currency_code,
		     p_last_update_date => sysdate,
		     p_last_updated_by => l_userid,
		     p_last_update_login => l_loginid,
		     p_created_by => l_userid,
		     p_creation_date => sysdate);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	    end;
	    else
	    begin

	      Update_Row
		    (p_api_version => 1.0,
		     p_return_status => l_return_status,
		     p_msg_count => p_msg_count,
		     p_msg_data => p_msg_data,
		     p_pay_element_rate_id => g_element_rates(l_rate_index).pay_element_rate_id,
		     p_effective_start_date => p_effective_end_date + 1,
		     p_effective_end_date => g_element_rates(l_rate_index).effective_end_date,
		     p_element_value_type => g_element_rates(l_rate_index).element_value_type,
		     p_element_value => g_element_rates(l_rate_index).element_value,
		     p_pay_basis => g_element_rates(l_rate_index).pay_basis,
		     p_formula_id => g_element_rates(l_rate_index).formula_id,
		     p_maximum_value => g_element_rates(l_rate_index).maximum_value,
		     p_mid_value => g_element_rates(l_rate_index).mid_value,
		     p_minimum_value => g_element_rates(l_rate_index).minimum_value,
		     p_last_update_date => sysdate,
		     p_last_updated_by => l_userid,
		     p_last_update_login => l_loginid);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	    end;
	    end if;

	  end;
	  end if;

	end;
	end if;

      end;
      end if;

    end loop;

  end;
  end if;

  if FND_API.to_Boolean(l_created_record) then
  begin

    for l_rate_index in 1..g_num_element_rates loop

      if FND_API.to_Boolean(g_element_rates(l_rate_index).proper_subset) then
      begin

	Delete_Row
	      (p_api_version => 1.0,
	       p_return_status => l_return_status,
	       p_msg_count => p_msg_count,
	       p_msg_data => p_msg_data,
	       p_pay_element_rate_id => g_element_rates(l_rate_index).pay_element_rate_id);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    end loop;

  end;
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
     rollback to Modify_Element_Rates_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Modify_Element_Rates_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then
     rollback to Modify_Element_Rates_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Modify_Element_Rates;

/*-------------------------------------------------------------------------*/



/*==========================================================================+
 |                     PROCEDURE  Check_Date_Range_Overlap                  |
 +==========================================================================*/
--
-- This API checks for overlapping date ranges in 'PSB_PAY_ELEMENT_RATES'
-- table.
--
PROCEDURE Check_Date_Range_Overlap
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_pay_element_id            IN       NUMBER,
  p_pay_element_option_id     IN       NUMBER,
  p_overlap_found_flag        OUT  NOCOPY      VARCHAR2
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Date_Range_Overlap';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_count_end_dates     NUMBER ;
  l_count               NUMBER ;
  --
BEGIN
  --
  SAVEPOINT Check_Date_Range_Overlap_Pvt ;
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
  p_return_status      := FND_API.G_RET_STS_SUCCESS ;
  p_overlap_found_flag := FND_API.G_FALSE ;
  --

  --
  -- Only one date rannge can be end-dates.
  --
  SELECT count(*) INTO l_count_end_dates
  FROM   psb_pay_element_rates
  WHERE  pay_element_id = p_pay_element_id
  AND    (
	   p_pay_element_option_id IS NULL
	   OR
	   pay_element_option_id = p_pay_element_option_id
	 )
  AND    effective_end_date IS NULL ;

  IF l_count_end_dates > 1 THEN
    p_overlap_found_flag := FND_API.G_TRUE ;
    FND_MESSAGE.Set_Name('PSB', 'PSB_MANY_OPEN_ENDED_DATES');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;


  FOR l_rates_rec IN
  (
    SELECT pay_element_rate_id, effective_start_date
    FROM   psb_pay_element_rates
    WHERE  pay_element_id = p_pay_element_id
    AND    (
	     p_pay_element_option_id IS NULL
	     OR
	     pay_element_option_id = p_pay_element_option_id
	   )
  )
  LOOP
    --

    SELECT count(*) INTO l_count
    FROM   psb_pay_element_rates
    WHERE  pay_element_id = p_pay_element_id
    AND    (
	     p_pay_element_option_id IS NULL
	     OR
	     pay_element_option_id = p_pay_element_option_id
	   )
    AND    pay_element_rate_id <> l_rates_rec.pay_element_rate_id
    AND    (
	      (
		effective_end_date IS NULL AND
		l_rates_rec.effective_start_date >= effective_start_date
	      )
	      OR
	      (
		l_rates_rec.effective_start_date
		BETWEEN effective_start_date AND effective_end_date
	      )
	   ) ;

    IF l_count > 0 THEN
      p_overlap_found_flag := FND_API.G_TRUE ;
      FND_MESSAGE.Set_Name('PSB', 'PSB_DUP_DATE_RANGE');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR ;
    END IF ;
    --
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
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Check_Date_Range_Overlap_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Check_Date_Range_Overlap_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Check_Date_Range_Overlap_Pvt ;
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
END Check_Date_Range_Overlap;
/*-------------------------------------------------------------------------*/


END PSB_PAY_ELEMENT_RATES_PVT;

/
