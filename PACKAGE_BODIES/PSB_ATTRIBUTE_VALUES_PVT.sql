--------------------------------------------------------
--  DDL for Package Body PSB_ATTRIBUTE_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_ATTRIBUTE_VALUES_PVT" AS
 /* $Header: PSBVPAVB.pls 120.2 2005/07/13 11:27:45 shtripat ship $ */


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_ATTRIBUTE_VALUES_PVT';

procedure INSERT_ROW (
  p_api_version                 IN       NUMBER,
  p_init_msg_list               IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY      VARCHAR2,
  p_msg_count                   OUT  NOCOPY      NUMBER,
  p_msg_data                    OUT  NOCOPY      VARCHAR2,
  --
  P_ROWID                       in OUT  NOCOPY  VARCHAR2,
  --
  P_ATTRIBUTE_VALUE_ID          in      NUMBER,
  P_ATTRIBUTE_ID                in      NUMBER,
  P_ATTRIBUTE_VALUE             in      VARCHAR2,
  P_HR_VALUE_ID                 in      VARCHAR2,
  P_DESCRIPTION                 in      VARCHAR2,
  P_DATA_EXTRACT_ID             in      NUMBER,
  P_CONTEXT                     in      VARCHAR2,
  P_ATTRIBUTE1                  in      VARCHAR2,
  P_ATTRIBUTE2                  in      VARCHAR2,
  P_ATTRIBUTE3                  in      VARCHAR2,
  P_ATTRIBUTE4                  in      VARCHAR2,
  P_ATTRIBUTE5                  in      VARCHAR2,
  P_ATTRIBUTE6                  in      VARCHAR2,
  P_ATTRIBUTE7                  in      VARCHAR2,
  P_ATTRIBUTE8                  in      VARCHAR2,
  P_ATTRIBUTE9                  in      VARCHAR2,
  P_ATTRIBUTE10                 in      VARCHAR2,
  P_ATTRIBUTE11                 in      VARCHAR2,
  P_ATTRIBUTE12                 in      VARCHAR2,
  P_ATTRIBUTE13                 in      VARCHAR2,
  P_ATTRIBUTE14                 in      VARCHAR2,
  P_ATTRIBUTE15                 in      VARCHAR2,
  P_ATTRIBUTE16                 in      VARCHAR2,
  P_ATTRIBUTE17                 in      VARCHAR2,
  P_ATTRIBUTE18                 in      VARCHAR2,
  P_ATTRIBUTE19                 in      VARCHAR2,
  P_ATTRIBUTE20                 in      VARCHAR2,
  P_ATTRIBUTE21                 in      VARCHAR2,
  P_ATTRIBUTE22                 in      VARCHAR2,
  P_ATTRIBUTE23                 in      VARCHAR2,
  P_ATTRIBUTE24                 in      VARCHAR2,
  P_ATTRIBUTE25                 in      VARCHAR2,
  P_ATTRIBUTE26                 in      VARCHAR2,
  P_ATTRIBUTE27                 in      VARCHAR2,
  P_ATTRIBUTE28                 in      VARCHAR2,
  P_ATTRIBUTE29                 in      VARCHAR2,
  P_ATTRIBUTE30                 in      VARCHAR2,
  P_LAST_UPDATE_DATE            in      DATE,
  P_LAST_UPDATED_BY             in      NUMBER,
  P_LAST_UPDATE_LOGIN           in      NUMBER,
  P_CREATED_BY                  in      NUMBER,
  P_CREATION_DATE               in      DATE
) as
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
    cursor C is select ROWID from PSB_ATTRIBUTE_VALUES
      where ATTRIBUTE_VALUE_ID = P_ATTRIBUTE_VALUE_ID;

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
  --

  insert into PSB_ATTRIBUTE_VALUES (
  ATTRIBUTE_VALUE_ID        ,
  ATTRIBUTE_ID              ,
  ATTRIBUTE_VALUE           ,
  HR_VALUE_ID               ,
  DESCRIPTION               ,
  DATA_EXTRACT_ID           ,
  CONTEXT                   ,
  ATTRIBUTE1                ,
  ATTRIBUTE2                ,
  ATTRIBUTE3                ,
  ATTRIBUTE4                ,
  ATTRIBUTE5                ,
  ATTRIBUTE6                ,
  ATTRIBUTE7                ,
  ATTRIBUTE8                ,
  ATTRIBUTE9                ,
  ATTRIBUTE10               ,
  ATTRIBUTE11               ,
  ATTRIBUTE12               ,
  ATTRIBUTE13               ,
  ATTRIBUTE14               ,
  ATTRIBUTE15               ,
  ATTRIBUTE16               ,
  ATTRIBUTE17               ,
  ATTRIBUTE18               ,
  ATTRIBUTE19               ,
  ATTRIBUTE20               ,
  ATTRIBUTE21               ,
  ATTRIBUTE22               ,
  ATTRIBUTE23               ,
  ATTRIBUTE24               ,
  ATTRIBUTE25               ,
  ATTRIBUTE26               ,
  ATTRIBUTE27               ,
  ATTRIBUTE28               ,
  ATTRIBUTE29               ,
  ATTRIBUTE30               ,
  LAST_UPDATE_DATE          ,
  LAST_UPDATED_BY           ,
  LAST_UPDATE_LOGIN         ,
  CREATED_BY                ,
  CREATION_DATE
  ) values (
  P_ATTRIBUTE_VALUE_ID        ,
  P_ATTRIBUTE_ID              ,
  P_ATTRIBUTE_VALUE           ,
  P_HR_VALUE_ID               ,
  P_DESCRIPTION               ,
  P_DATA_EXTRACT_ID           ,
  P_CONTEXT                   ,
  P_ATTRIBUTE1                ,
  P_ATTRIBUTE2                ,
  P_ATTRIBUTE3                ,
  P_ATTRIBUTE4                ,
  P_ATTRIBUTE5                ,
  P_ATTRIBUTE6                ,
  P_ATTRIBUTE7                ,
  P_ATTRIBUTE8                ,
  P_ATTRIBUTE9                ,
  P_ATTRIBUTE10               ,
  P_ATTRIBUTE11               ,
  P_ATTRIBUTE12               ,
  P_ATTRIBUTE13               ,
  P_ATTRIBUTE14               ,
  P_ATTRIBUTE15               ,
  P_ATTRIBUTE16               ,
  P_ATTRIBUTE17               ,
  P_ATTRIBUTE18               ,
  P_ATTRIBUTE19               ,
  P_ATTRIBUTE20               ,
  P_ATTRIBUTE21               ,
  P_ATTRIBUTE22               ,
  P_ATTRIBUTE23               ,
  P_ATTRIBUTE24               ,
  P_ATTRIBUTE25               ,
  P_ATTRIBUTE26               ,
  P_ATTRIBUTE27               ,
  P_ATTRIBUTE28               ,
  P_ATTRIBUTE29               ,
  P_ATTRIBUTE30               ,
  P_LAST_UPDATE_DATE          ,
  P_LAST_UPDATED_BY           ,
  P_LAST_UPDATE_LOGIN         ,
  P_CREATED_BY                ,
  P_CREATION_DATE
  );

  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

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
END INSERT_ROW;

procedure LOCK_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_lock_row                  OUT  NOCOPY      VARCHAR2,
  P_ROWID                     IN       VARCHAR2,
  --
  P_ATTRIBUTE_VALUE_ID          in      NUMBER,
  P_ATTRIBUTE_ID                in      NUMBER,
  P_ATTRIBUTE_VALUE             in      VARCHAR2,
  P_HR_VALUE_ID                 in      VARCHAR2,
  P_DESCRIPTION                 in      VARCHAR2,
  P_DATA_EXTRACT_ID             in      NUMBER,
  P_CONTEXT                     in      VARCHAR2,
  P_ATTRIBUTE1                  in      VARCHAR2,
  P_ATTRIBUTE2                  in      VARCHAR2,
  P_ATTRIBUTE3                  in      VARCHAR2,
  P_ATTRIBUTE4                  in      VARCHAR2,
  P_ATTRIBUTE5                  in      VARCHAR2,
  P_ATTRIBUTE6                  in      VARCHAR2,
  P_ATTRIBUTE7                  in      VARCHAR2,
  P_ATTRIBUTE8                  in      VARCHAR2,
  P_ATTRIBUTE9                  in      VARCHAR2,
  P_ATTRIBUTE10                 in      VARCHAR2,
  P_ATTRIBUTE11                 in      VARCHAR2,
  P_ATTRIBUTE12                 in      VARCHAR2,
  P_ATTRIBUTE13                 in      VARCHAR2,
  P_ATTRIBUTE14                 in      VARCHAR2,
  P_ATTRIBUTE15                 in      VARCHAR2,
  P_ATTRIBUTE16                 in      VARCHAR2,
  P_ATTRIBUTE17                 in      VARCHAR2,
  P_ATTRIBUTE18                 in      VARCHAR2,
  P_ATTRIBUTE19                 in      VARCHAR2,
  P_ATTRIBUTE20                 in      VARCHAR2,
  P_ATTRIBUTE21                 in      VARCHAR2,
  P_ATTRIBUTE22                 in      VARCHAR2,
  P_ATTRIBUTE23                 in      VARCHAR2,
  P_ATTRIBUTE24                 in      VARCHAR2,
  P_ATTRIBUTE25                 in      VARCHAR2,
  P_ATTRIBUTE26                 in      VARCHAR2,
  P_ATTRIBUTE27                 in      VARCHAR2,
  P_ATTRIBUTE28                 in      VARCHAR2,
  P_ATTRIBUTE29                 in      VARCHAR2,
  P_ATTRIBUTE30                 in      VARCHAR2
) as
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  Counter NUMBER;
  cursor c1 is select
    ATTRIBUTE_VALUE_ID        ,
    ATTRIBUTE_ID              ,
    ATTRIBUTE_VALUE           ,
    HR_VALUE_ID               ,
    DESCRIPTION               ,
    DATA_EXTRACT_ID           ,
    CONTEXT                   ,
    ATTRIBUTE1                ,
    ATTRIBUTE2                ,
    ATTRIBUTE3                ,
    ATTRIBUTE4                ,
    ATTRIBUTE5                ,
    ATTRIBUTE6                ,
    ATTRIBUTE7                ,
    ATTRIBUTE8                ,
    ATTRIBUTE9                ,
    ATTRIBUTE10               ,
    ATTRIBUTE11               ,
    ATTRIBUTE12               ,
    ATTRIBUTE13               ,
    ATTRIBUTE14               ,
    ATTRIBUTE15               ,
    ATTRIBUTE16               ,
    ATTRIBUTE17               ,
    ATTRIBUTE18               ,
    ATTRIBUTE19               ,
    ATTRIBUTE20               ,
    ATTRIBUTE21               ,
    ATTRIBUTE22               ,
    ATTRIBUTE23               ,
    ATTRIBUTE24               ,
    ATTRIBUTE25               ,
    ATTRIBUTE26               ,
    ATTRIBUTE27               ,
    ATTRIBUTE28               ,
    ATTRIBUTE29               ,
    ATTRIBUTE30
    from PSB_ATTRIBUTE_VALUES
    where ROWID = P_ROWID
    for update of ATTRIBUTE_VALUE_ID nowait;
  tlinfo c1%rowtype;

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
  --
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if (
      (tlinfo.ATTRIBUTE_VALUE_ID = P_ATTRIBUTE_VALUE_ID)
      AND (tlinfo.ATTRIBUTE_ID = P_ATTRIBUTE_ID)

      AND ((tlinfo.ATTRIBUTE_VALUE = P_ATTRIBUTE_VALUE)
	   OR ((tlinfo.ATTRIBUTE_VALUE is null)
	       AND (P_ATTRIBUTE_VALUE is null)))
      AND ((tlinfo.HR_VALUE_ID = P_HR_VALUE_ID)
	   OR ((tlinfo.HR_VALUE_ID is null)
	       AND (P_HR_VALUE_ID is null)))
      AND ((tlinfo.DESCRIPTION = P_DESCRIPTION)
	   OR ((tlinfo.DESCRIPTION is null)
	       AND (P_DESCRIPTION is null)))
      AND ((tlinfo.DATA_EXTRACT_ID = P_DATA_EXTRACT_ID)
	   OR ((tlinfo.DATA_EXTRACT_ID is null)
	       AND (P_DATA_EXTRACT_ID is null)))
      AND ((tlinfo.CONTEXT = P_CONTEXT)
	   OR ((tlinfo.CONTEXT is null)
	       AND (P_CONTEXT is null)))
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
      AND ((tlinfo.ATTRIBUTE11 = P_ATTRIBUTE11)
	   OR ((tlinfo.ATTRIBUTE11 is null)
	       AND (P_ATTRIBUTE11 is null)))
      AND ((tlinfo.ATTRIBUTE12 = P_ATTRIBUTE12)
	   OR ((tlinfo.ATTRIBUTE12 is null)
	       AND (P_ATTRIBUTE12 is null)))
      AND ((tlinfo.ATTRIBUTE13 = P_ATTRIBUTE13)
	   OR ((tlinfo.ATTRIBUTE13 is null)
	       AND (P_ATTRIBUTE13 is null)))
      AND ((tlinfo.ATTRIBUTE14 = P_ATTRIBUTE14)
	   OR ((tlinfo.ATTRIBUTE14 is null)
	       AND (P_ATTRIBUTE14 is null)))
      AND ((tlinfo.ATTRIBUTE15 = P_ATTRIBUTE15)
	   OR ((tlinfo.ATTRIBUTE15 is null)
	       AND (P_ATTRIBUTE15 is null)))
      AND ((tlinfo.ATTRIBUTE16 = P_ATTRIBUTE16)
	   OR ((tlinfo.ATTRIBUTE16 is null)
	       AND (P_ATTRIBUTE16 is null)))
      AND ((tlinfo.ATTRIBUTE17 = P_ATTRIBUTE17)
	   OR ((tlinfo.ATTRIBUTE17 is null)
	       AND (P_ATTRIBUTE17 is null)))
      AND ((tlinfo.ATTRIBUTE18 = P_ATTRIBUTE18)
	   OR ((tlinfo.ATTRIBUTE18 is null)
	       AND (P_ATTRIBUTE18 is null)))
      AND ((tlinfo.ATTRIBUTE19 = P_ATTRIBUTE19)
	   OR ((tlinfo.ATTRIBUTE19 is null)
	       AND (P_ATTRIBUTE19 is null)))
      AND ((tlinfo.ATTRIBUTE20 = P_ATTRIBUTE20)
	   OR ((tlinfo.ATTRIBUTE20 is null)
	       AND (P_ATTRIBUTE20 is null)))
      AND ((tlinfo.ATTRIBUTE21 = P_ATTRIBUTE21)
	   OR ((tlinfo.ATTRIBUTE21 is null)
	       AND (P_ATTRIBUTE21 is null)))
      AND ((tlinfo.ATTRIBUTE22 = P_ATTRIBUTE22)
	   OR ((tlinfo.ATTRIBUTE22 is null)
	       AND (P_ATTRIBUTE22 is null)))
      AND ((tlinfo.ATTRIBUTE23 = P_ATTRIBUTE23)
	   OR ((tlinfo.ATTRIBUTE23 is null)
	       AND (P_ATTRIBUTE23 is null)))
      AND ((tlinfo.ATTRIBUTE24 = P_ATTRIBUTE24)
	   OR ((tlinfo.ATTRIBUTE24 is null)
	       AND (P_ATTRIBUTE24 is null)))
      AND ((tlinfo.ATTRIBUTE25 = P_ATTRIBUTE25)
	   OR ((tlinfo.ATTRIBUTE25 is null)
	       AND (P_ATTRIBUTE25 is null)))
      AND ((tlinfo.ATTRIBUTE26 = P_ATTRIBUTE26)
	   OR ((tlinfo.ATTRIBUTE26 is null)
	       AND (P_ATTRIBUTE26 is null)))
      AND ((tlinfo.ATTRIBUTE27 = P_ATTRIBUTE27)
	   OR ((tlinfo.ATTRIBUTE27 is null)
	       AND (P_ATTRIBUTE27 is null)))
      AND ((tlinfo.ATTRIBUTE28 = P_ATTRIBUTE28)
	   OR ((tlinfo.ATTRIBUTE28 is null)
	       AND (P_ATTRIBUTE28 is null)))
      AND ((tlinfo.ATTRIBUTE29 = P_ATTRIBUTE29)
	   OR ((tlinfo.ATTRIBUTE29 is null)
	       AND (P_ATTRIBUTE29 is null)))
      AND ((tlinfo.ATTRIBUTE30 = P_ATTRIBUTE30)
	   OR ((tlinfo.ATTRIBUTE30 is null)
	       AND (P_ATTRIBUTE30 is null)))


  ) then
     p_lock_row  :=  FND_API.G_TRUE;
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
    p_lock_row  :=  FND_API.G_FALSE;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Lock_Row_Pvt ;
    p_lock_row  :=  FND_API.G_FALSE;
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
  --
END LOCK_ROW;

procedure UPDATE_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_ATTRIBUTE_VALUE_ID          in      NUMBER,
  P_ATTRIBUTE_ID                in      NUMBER,
  P_ATTRIBUTE_VALUE             in      VARCHAR2,
  P_HR_VALUE_ID                 in      VARCHAR2,
  P_DESCRIPTION                 in      VARCHAR2,
  P_DATA_EXTRACT_ID             in      NUMBER,
  P_CONTEXT                     in      VARCHAR2,
  P_ATTRIBUTE1                  in      VARCHAR2,
  P_ATTRIBUTE2                  in      VARCHAR2,
  P_ATTRIBUTE3                  in      VARCHAR2,
  P_ATTRIBUTE4                  in      VARCHAR2,
  P_ATTRIBUTE5                  in      VARCHAR2,
  P_ATTRIBUTE6                  in      VARCHAR2,
  P_ATTRIBUTE7                  in      VARCHAR2,
  P_ATTRIBUTE8                  in      VARCHAR2,
  P_ATTRIBUTE9                  in      VARCHAR2,
  P_ATTRIBUTE10                 in      VARCHAR2,
  P_ATTRIBUTE11                 in      VARCHAR2,
  P_ATTRIBUTE12                 in      VARCHAR2,
  P_ATTRIBUTE13                 in      VARCHAR2,
  P_ATTRIBUTE14                 in      VARCHAR2,
  P_ATTRIBUTE15                 in      VARCHAR2,
  P_ATTRIBUTE16                 in      VARCHAR2,
  P_ATTRIBUTE17                 in      VARCHAR2,
  P_ATTRIBUTE18                 in      VARCHAR2,
  P_ATTRIBUTE19                 in      VARCHAR2,
  P_ATTRIBUTE20                 in      VARCHAR2,
  P_ATTRIBUTE21                 in      VARCHAR2,
  P_ATTRIBUTE22                 in      VARCHAR2,
  P_ATTRIBUTE23                 in      VARCHAR2,
  P_ATTRIBUTE24                 in      VARCHAR2,
  P_ATTRIBUTE25                 in      VARCHAR2,
  P_ATTRIBUTE26                 in      VARCHAR2,
  P_ATTRIBUTE27                 in      VARCHAR2,
  P_ATTRIBUTE28                 in      VARCHAR2,
  P_ATTRIBUTE29                 in      VARCHAR2,
  P_ATTRIBUTE30                 in      VARCHAR2,
  P_LAST_UPDATE_DATE            in      DATE,
  P_LAST_UPDATED_BY             in      NUMBER,
  P_LAST_UPDATE_LOGIN           in      NUMBER
) as
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
  update PSB_ATTRIBUTE_VALUES set
  ATTRIBUTE_VALUE_ID   =    P_ATTRIBUTE_VALUE_ID,
  ATTRIBUTE_ID         =    P_ATTRIBUTE_ID,
  ATTRIBUTE_VALUE      =    P_ATTRIBUTE_VALUE,
  HR_VALUE_ID          =    P_HR_VALUE_ID,
  DESCRIPTION          =    P_DESCRIPTION,
  DATA_EXTRACT_ID      =    P_DATA_EXTRACT_ID,
  CONTEXT              =    P_CONTEXT,
  ATTRIBUTE1           =    P_ATTRIBUTE1,
  ATTRIBUTE2           =    P_ATTRIBUTE2,
  ATTRIBUTE3           =    P_ATTRIBUTE3,
  ATTRIBUTE4           =    P_ATTRIBUTE4,
  ATTRIBUTE5           =    P_ATTRIBUTE5,
  ATTRIBUTE6           =    P_ATTRIBUTE6,
  ATTRIBUTE7           =    P_ATTRIBUTE7,
  ATTRIBUTE8           =    P_ATTRIBUTE8,
  ATTRIBUTE9           =    P_ATTRIBUTE9,
  ATTRIBUTE10          =    P_ATTRIBUTE10,
  ATTRIBUTE11          =    P_ATTRIBUTE11,
  ATTRIBUTE12          =    P_ATTRIBUTE12,
  ATTRIBUTE13          =    P_ATTRIBUTE13,
  ATTRIBUTE14          =    P_ATTRIBUTE14,
  ATTRIBUTE15          =    P_ATTRIBUTE15,
  ATTRIBUTE16          =    P_ATTRIBUTE16,
  ATTRIBUTE17          =    P_ATTRIBUTE17,
  ATTRIBUTE18          =    P_ATTRIBUTE18,
  ATTRIBUTE19          =    P_ATTRIBUTE19,
  ATTRIBUTE20          =    P_ATTRIBUTE20,
  ATTRIBUTE21          =    P_ATTRIBUTE21,
  ATTRIBUTE22          =    P_ATTRIBUTE22,
  ATTRIBUTE23          =    P_ATTRIBUTE23,
  ATTRIBUTE24          =    P_ATTRIBUTE24,
  ATTRIBUTE25          =    P_ATTRIBUTE25,
  ATTRIBUTE26          =    P_ATTRIBUTE26,
  ATTRIBUTE27          =    P_ATTRIBUTE27,
  ATTRIBUTE28          =    P_ATTRIBUTE28,
  ATTRIBUTE29          =    P_ATTRIBUTE29,
  ATTRIBUTE30          =    P_ATTRIBUTE30,
  LAST_UPDATE_DATE     =    P_LAST_UPDATE_DATE,
  LAST_UPDATED_BY      =    P_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN    =    P_LAST_UPDATE_LOGIN
  where ATTRIBUTE_VALUE_ID = P_ATTRIBUTE_VALUE_ID;

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
END UPDATE_ROW;

procedure DELETE_ROW (
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  P_ATTRIBUTE_VALUE_ID in NUMBER ) as
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
BEGIN
  --
  SAVEPOINT Delete_Row_Pvt ;
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
  delete from PSB_ATTRIBUTE_VALUES
  where ATTRIBUTE_VALUE_ID = P_ATTRIBUTE_VALUE_ID;
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

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Delete_Row_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Delete_Row_Pvt ;
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
END DELETE_ROW;


PROCEDURE Check_References
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY      VARCHAR2,
  p_msg_count                 OUT  NOCOPY      NUMBER,
  p_msg_data                  OUT  NOCOPY      VARCHAR2,
  --
  p_ATTRIBUTE_ID              IN       NUMBER,
  p_ATTRIBUTE_VALUE_ID        IN       NUMBER,
  p_Return_Value              IN OUT  NOCOPY   VARCHAR2
)
AS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_References';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_tmp VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM psb_position_assignments
    WHERE attribute_id = p_attribute_Id
    AND attribute_value_id = p_attribute_value_id;

BEGIN
  --
  SAVEPOINT Check_References_Pvt ;
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

  -- Checking the Psb_set_relations table for references.
  OPEN c;
  FETCH c INTO l_tmp;
  --
  -- p_Return_Value tells whether references exist or not.
  IF l_tmp IS NULL THEN
    p_Return_Value := 'FALSE';
  ELSE
    p_Return_Value := 'TRUE';
  END IF;

  CLOSE c;
  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
			      p_data  => p_msg_data );

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Check_References_Pvt ;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Check_References_Pvt ;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
				p_data  => p_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Check_References_Pvt ;
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
END Check_References;


end PSB_ATTRIBUTE_VALUES_PVT;

/
