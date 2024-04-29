--------------------------------------------------------
--  DDL for Package Body BIS_CUSTOMIZATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_CUSTOMIZATION_PVT" AS
/* $Header: BISVCTMB.pls 120.1 2006/02/14 13:21:04 hengliu noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVCTMB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for seeding ak Customization Data at function level   |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 27-Apr-2005 kyadamak Creation                                         |
REM | 14-Feb-2005 hengliu  Added Delete_Custom_Region_Items                 |
REM +=======================================================================+
*/
--

PROCEDURE Create_Custom_Region_Items
( p_api_version              IN  NUMBER
, p_commit                   IN  VARCHAR2   := FND_API.G_FALSE
, p_Custom_Region_Items_Rec  IN  BIS_CUSTOMIZATION_PUB.custom_region_items_type
, x_return_status            OUT NOCOPY  VARCHAR2
, x_msg_count                OUT NOCOPY  NUMBER
, x_msg_data                 OUT NOCOPY  VARCHAR2
)

IS
l_rowid  VARCHAR2(100);
BEGIN

  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  AK_CUSTOM_REGION_ITEMS_PKG.INSERT_ROW
  ( X_ROWID                         =>  l_rowid
  , X_CUSTOMIZATION_APPLICATION_ID  =>  p_Custom_Region_Items_Rec.customization_application_id
  , X_CUSTOMIZATION_CODE            =>  p_Custom_Region_Items_Rec.customization_code
  , X_REGION_APPLICATION_ID         =>  p_Custom_Region_Items_Rec.region_application_id
  , X_REGION_CODE                   =>  p_Custom_Region_Items_Rec.region_code
  , X_ATTRIBUTE_APPLICATION_ID      =>  p_Custom_Region_Items_Rec.attribute_application_id
  , X_ATTRIBUTE_CODE                =>  p_Custom_Region_Items_Rec.attribute_code
  , X_PROPERTY_NAME                 =>  p_Custom_Region_Items_Rec.property_name
  , X_PROPERTY_VARCHAR2_VALUE       =>  p_Custom_Region_Items_Rec.property_varchar2_value
  , X_PROPERTY_NUMBER_VALUE         =>  p_Custom_Region_Items_Rec.property_number_value
  , X_PROPERTY_DATE_VALUE           =>  p_Custom_Region_Items_Rec.property_date_value
  , X_CREATED_BY                    =>  NVL(p_Custom_Region_Items_Rec.created_by,FND_GLOBAL.USER_ID)
  , X_CREATION_DATE                 =>  NVL(p_Custom_Region_Items_Rec.last_update_date,SYSDATE)
  , X_LAST_UPDATED_BY               =>  NVL(p_Custom_Region_Items_Rec.last_updated_by,FND_GLOBAL.USER_ID)
  , X_LAST_UPDATE_DATE              =>  NVL(p_Custom_Region_Items_Rec.last_update_date,SYSDATE)
  , X_LAST_UPDATE_LOGIN             =>  NVL(p_Custom_Region_Items_Rec.last_update_login,FND_GLOBAL.LOGIN_ID)
   );

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PVT.Create_Custom_Region_Items ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PVT.Create_Custom_Region_Items ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PVT.Create_Custom_Region_Items ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PVT.Create_Custom_Region_Items ';
    END IF;


END Create_Custom_Region_Items;
--
--
PROCEDURE Update_Custom_Region_Items
( p_api_version              IN  NUMBER
, p_commit                   IN  VARCHAR2   := FND_API.G_FALSE
, p_Custom_Region_Items_Rec  IN  BIS_CUSTOMIZATION_PUB.custom_Region_Items_type
, x_return_status            OUT NOCOPY  VARCHAR2
, x_msg_count                OUT NOCOPY  NUMBER
, x_msg_data                 OUT NOCOPY  VARCHAR2
)

IS
BEGIN

  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  AK_CUSTOM_REGION_ITEMS_PKG.UPDATE_ROW
  ( X_CUSTOMIZATION_APPLICATION_ID  =>  p_Custom_Region_Items_Rec.customization_application_id
  , X_CUSTOMIZATION_CODE            =>  p_Custom_Region_Items_Rec.customization_code
  , X_REGION_APPLICATION_ID         =>  p_Custom_Region_Items_Rec.region_application_id
  , X_REGION_CODE                   =>  p_Custom_Region_Items_Rec.region_code
  , X_ATTRIBUTE_APPLICATION_ID      =>  p_Custom_Region_Items_Rec.attribute_application_id
  , X_ATTRIBUTE_CODE                =>  p_Custom_Region_Items_Rec.attribute_code
  , X_PROPERTY_NAME                 =>  p_Custom_Region_Items_Rec.property_name
  , X_PROPERTY_VARCHAR2_VALUE       =>  p_Custom_Region_Items_Rec.property_varchar2_value
  , X_PROPERTY_NUMBER_VALUE         =>  p_Custom_Region_Items_Rec.property_number_value
  , X_PROPERTY_DATE_VALUE           =>  p_Custom_Region_Items_Rec.property_date_value
  , X_LAST_UPDATED_BY               =>  NVL(p_Custom_Region_Items_Rec.last_updated_by,FND_GLOBAL.USER_ID)
  , X_LAST_UPDATE_DATE              =>  NVL(p_Custom_Region_Items_Rec.last_update_date,SYSDATE)
  , X_LAST_UPDATE_LOGIN             =>  NVL(p_Custom_Region_Items_Rec.last_update_login,FND_GLOBAL.LOGIN_ID)
  );

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PVT.Update_Custom_Region_items ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PVT.Update_Custom_Region_items ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PVT.Update_Custom_Region_items ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PVT.Update_Custom_Region_items ';
    END IF;


END Update_Custom_Region_Items;

PROCEDURE Delete_Custom_Region_Items
( p_api_version              IN   NUMBER
, p_commit                   IN   VARCHAR2 := FND_API.G_FALSE
, p_Custom_region_items_Rec  IN   BIS_CUSTOMIZATION_PUB.custom_region_items_type
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
) IS
BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  AK_CUSTOM_REGION_ITEMS_PKG.Delete_ROW
  ( X_CUSTOMIZATION_APPLICATION_ID  =>  p_Custom_Region_Items_Rec.customization_application_id
  , X_CUSTOMIZATION_CODE            =>  p_Custom_Region_Items_Rec.customization_code
  , X_REGION_APPLICATION_ID         =>  p_Custom_Region_Items_Rec.region_application_id
  , X_REGION_CODE                   =>  p_Custom_Region_Items_Rec.region_code
  , X_ATTRIBUTE_APPLICATION_ID      =>  p_Custom_Region_Items_Rec.attribute_application_id
  , X_ATTRIBUTE_CODE                =>  p_Custom_Region_Items_Rec.attribute_code
  , X_PROPERTY_NAME                 =>  p_Custom_Region_Items_Rec.property_name
  );

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PVT.Delete_Custom_Region_items ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PVT.Delete_Custom_Region_items ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PVT.Delete_Custom_Region_items ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PVT.Delete_Custom_Region_items ';
    END IF;

END Delete_Custom_Region_Items;

PROCEDURE Create_Customizations
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Customizations_Rec  IN  BIS_CUSTOMIZATION_PUB.customizations_type
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2)
IS

l_row_id              VARCHAR2(32000);
BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO ak_customizations (
     customization_application_id
    ,customization_code
    ,region_application_id
    ,region_code
    ,verticalization_id
    ,localization_code
    ,org_id
    ,site_id
    ,responsibility_id
    ,web_user_id
    ,default_customization_flag
    ,customization_level_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,start_date_active
    ,end_date_active
    ,reference_path
    ,function_name
    ,developer_mode
  ) VALUES (
     p_Customizations_Rec.customization_application_id
    ,p_Customizations_Rec.customization_code
    ,p_Customizations_Rec.region_application_id
    ,p_Customizations_Rec.region_code
    ,p_Customizations_Rec.verticalization_id
    ,p_Customizations_Rec.localization_code
    ,p_Customizations_Rec.org_id
    ,p_Customizations_Rec.site_id
    ,p_Customizations_Rec.responsibility_id
    ,p_Customizations_Rec.web_user_id
    ,p_Customizations_Rec.default_customization_flag
    ,p_Customizations_Rec.customization_level_id
    ,NVL(p_Customizations_Rec.created_by,FND_GLOBAL.USER_ID)
    ,NVL(p_Customizations_Rec.last_update_date,SYSDATE)
    ,NVL(p_Customizations_Rec.last_updated_by,FND_GLOBAL.USER_ID)
    ,NVL(p_Customizations_Rec.last_update_date,SYSDATE)
    ,NVL(p_Customizations_Rec.last_update_login,FND_GLOBAL.LOGIN_ID)
    ,NVL(p_Customizations_Rec.start_date_active,SYSDATE)
    ,p_Customizations_Rec.end_date_active
    ,p_Customizations_Rec.reference_path
    ,p_Customizations_Rec.function_name
    ,p_Customizations_Rec.developer_mode
    );


  INSERT INTO ak_customizations_tl (
     customization_application_id
    ,customization_code
    ,region_application_id
    ,region_code
    ,name
    ,description
    ,language
    ,source_lang
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
  ) SELECT
     p_Customizations_Rec.customization_application_id
    ,p_Customizations_Rec.customization_code
    ,p_Customizations_Rec.region_application_id
    ,p_Customizations_Rec.region_code
    ,p_Customizations_Rec.name
    ,p_Customizations_Rec.description
    ,L.language_code
    ,USERENV('LANG')
    ,NVL(p_Customizations_Rec.created_by,FND_GLOBAL.USER_ID)
    ,NVL(p_Customizations_Rec.last_update_date,SYSDATE)
    ,NVL(p_Customizations_Rec.last_updated_by,FND_GLOBAL.USER_ID)
    ,NVL(p_Customizations_Rec.last_update_date,SYSDATE)
    ,NVL(p_Customizations_Rec.last_update_login,FND_GLOBAL.LOGIN_ID)
  FROM fnd_languages L
  WHERE L.installed_flag IN ('I', 'B')
  AND   NOT EXISTS
  (SELECT NULL
  FROM ak_customizations_tl T
  WHERE T.customization_application_id = p_Customizations_Rec.customization_application_id
  AND   T.customization_code           = p_Customizations_Rec.customization_code
  AND   T.region_application_id        = p_Customizations_Rec.region_application_id
  AND   T.region_code                  = p_Customizations_Rec.region_code
  AND   T.language                     = L.language_code);

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;

    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Create_Customizations ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Create_Customizations ';
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Create_Customizations ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Create_Customizations ';
    END IF;

END Create_Customizations;
--
--

PROCEDURE Update_Customizations
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Customizations_Rec  IN  BIS_CUSTOMIZATION_PUB.customizations_type
, x_return_status       OUT NOCOPY  VARCHAR2
, x_msg_count           OUT NOCOPY  NUMBER
, x_msg_data            OUT NOCOPY  VARCHAR2
)
IS
BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  UPDATE ak_customizations SET
     customization_application_id  =  p_Customizations_Rec.customization_application_id
    ,customization_code            =  p_Customizations_Rec.customization_code
    ,region_application_id         =  p_Customizations_Rec.region_application_id
    ,region_code                   =  p_Customizations_Rec.region_code
    ,verticalization_id            =  p_Customizations_Rec.verticalization_id
    ,localization_code             =  p_Customizations_Rec.localization_code
    ,org_id                        =  p_Customizations_Rec.org_id
    ,site_id                       =  p_Customizations_Rec.site_id
    ,responsibility_id             =  p_Customizations_Rec.responsibility_id
    ,web_user_id                   =  p_Customizations_Rec.web_user_id
    ,default_customization_flag    =  p_Customizations_Rec.default_customization_flag
    ,customization_level_id        =  p_Customizations_Rec.customization_level_id
    ,last_updated_by               =  NVL(p_Customizations_Rec.last_updated_by,FND_GLOBAL.USER_ID)
    ,last_update_date              =  NVL(p_Customizations_Rec.last_update_date,SYSDATE)
    ,last_update_login             =  NVL(p_Customizations_Rec.last_update_login,FND_GLOBAL.LOGIN_ID)
    ,start_date_active             =  p_Customizations_Rec.start_date_active
    ,end_date_active               =  p_Customizations_Rec.end_date_active
    ,reference_path                =  p_Customizations_Rec.reference_path
    ,function_name                 =  p_Customizations_Rec.function_name
    ,developer_mode                =  p_Customizations_Rec.developer_mode
  WHERE customization_application_id = p_Customizations_Rec.customization_application_id
  AND   customization_code           = p_Customizations_Rec.customization_code
  AND   region_application_id        = p_Customizations_Rec.region_application_id
  AND   region_code                  = p_Customizations_Rec.region_code;

  UPDATE AK_CUSTOMIZATIONS_TL SET
     name               =  p_Customizations_Rec.name
    ,description        =  p_Customizations_Rec.description
    ,last_updated_by    =  NVL(p_Customizations_Rec.last_updated_by,FND_GLOBAL.USER_ID)
    ,last_update_date   =  NVL(p_Customizations_Rec.last_update_date,SYSDATE)
    ,last_update_login  =  NVL(p_Customizations_Rec.last_update_login,FND_GLOBAL.LOGIN_ID)
    ,source_lang        =  USERENV('LANG')
  WHERE customization_application_id =  p_Customizations_Rec.customization_application_id
  AND   customization_code           =  p_Customizations_Rec.customization_code
  AND   region_application_id        =  p_Customizations_Rec.region_application_id
  AND   region_code                  =  p_Customizations_Rec.region_code
  AND   USERENV('LANG')              IN (language, source_lang);

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Update_Customizations ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Update_Customizations ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Update_Customizations ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Update_Customizations ';
    END IF;

END Update_Customizations;

END BIS_CUSTOMIZATION_PVT;

/
