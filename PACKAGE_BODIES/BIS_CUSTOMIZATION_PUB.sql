--------------------------------------------------------
--  DDL for Package Body BIS_CUSTOMIZATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_CUSTOMIZATION_PUB" AS
/* $Header: BISPCSTB.pls 120.1 2006/02/14 13:28:13 hengliu noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.1=120.1):~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPCSTB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for creating ak Customization Data at function level   |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 27-Apr-2005 kyadamak Creation                                         |
REM | 14-Feb-2006 hengliu  Added Delete_Custom_Region_Items                 |
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

BEGIN

  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  BIS_CUSTOMIZATION_PVT.Create_Custom_Region_Items
  ( p_api_version              =>  p_api_version
  , p_commit                   =>  p_commit
  , p_Custom_Region_Items_Rec  =>  p_Custom_Region_Items_Rec
  , x_return_status            =>  x_return_status
  , x_msg_count                =>  x_msg_count
  , x_msg_data                 =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
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
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Create_Custom_Region_Items ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Create_Custom_Region_Items ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Create_Custom_Region_Items ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Create_Custom_Region_Items ';
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

  BIS_CUSTOMIZATION_PVT.Update_Custom_Region_Items
  ( p_api_version              =>  p_api_version
  , p_commit                   =>  p_commit
  , p_Custom_Region_Items_Rec  =>  p_Custom_Region_Items_Rec
  , x_return_status            =>  x_return_status
  , x_msg_count                =>  x_msg_count
  , x_msg_data                 =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
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
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Update_Custom_Region_items ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Update_Custom_Region_items ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Update_Custom_Region_items ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Update_Custom_Region_items ';
    END IF;

END Update_Custom_Region_Items;

PROCEDURE Create_Custom_Region_Items_UI
( p_api_version                   IN  NUMBER
, p_commit                        IN  VARCHAR2   := FND_API.G_FALSE
, p_customization_application_id  IN  NUMBER
, p_customization_code            IN  VARCHAR2
, p_region_application_id         IN  NUMBER
, p_region_code                   IN  VARCHAR2
, p_attribute_application_id      IN  NUMBER
, p_attribute_code                IN  VARCHAR2
, p_property_name                 IN  VARCHAR2
, p_property_varchar2_value       IN  VARCHAR2
, p_property_number_value         IN  NUMBER
, p_property_date_value           IN  DATE
, x_return_status                 OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
)IS

l_custom_region_items_rec      BIS_CUSTOMIZATION_PUB.custom_region_items_type;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_custom_region_items_rec.customization_application_id  :=  p_customization_application_id;
  l_custom_region_items_rec.customization_code            :=  p_customization_code;
  l_custom_region_items_rec.region_application_id         :=  p_region_application_id;
  l_custom_region_items_rec.region_code                   :=  p_region_code;
  l_custom_region_items_rec.attribute_application_id      :=  p_attribute_application_id;
  l_custom_region_items_rec.attribute_code                :=  p_attribute_code;
  l_custom_region_items_rec.property_name                 :=  p_property_name;
  l_custom_region_items_rec.property_varchar2_value       :=  p_property_varchar2_value;
  l_custom_region_items_rec.property_number_value         :=  p_property_number_value;
  l_custom_region_items_rec.property_date_value           :=  p_property_date_value;


  BIS_CUSTOMIZATION_PUB.Create_Custom_Region_Items
  ( p_api_version              =>  p_api_version
  , p_commit                   =>  p_commit
  , p_Custom_Region_Items_Rec  =>  l_custom_region_items_rec
  , x_return_status            =>  x_return_status
  , x_msg_count                =>  x_msg_count
  , x_msg_data                 =>  x_msg_data
  );
  IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
    FND_MESSAGE.SET_NAME('BIS','BIS_CUSTOMIZATION_FAIL');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Create_Custom_region_items_UI ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Create_Custom_region_items_UI ';
    END IF;


END Create_Custom_Region_Items_UI;
--
-- updates rows into ak_custom_region_items and tl tables
--
PROCEDURE Update_Custom_Region_Items_UI
( p_api_version                   IN  NUMBER
, p_commit                        IN  VARCHAR2   := FND_API.G_FALSE
, p_customization_application_id  IN  NUMBER
, p_customization_code            IN  VARCHAR2
, p_region_application_id         IN  NUMBER
, p_region_code                   IN  VARCHAR2
, p_attribute_application_id      IN  NUMBER
, p_attribute_code                IN  VARCHAR2
, p_property_name                 IN  VARCHAR2
, p_property_varchar2_value       IN  VARCHAR2
, p_property_number_value         IN  NUMBER
, p_property_date_value           IN  DATE
, x_return_status                 OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
)IS

l_custom_region_items_rec      BIS_CUSTOMIZATION_PUB.custom_region_items_type;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_custom_region_items_rec.customization_application_id  :=  p_customization_application_id;
  l_custom_region_items_rec.customization_code            :=  p_customization_code;
  l_custom_region_items_rec.region_application_id         :=  p_region_application_id;
  l_custom_region_items_rec.region_code                   :=  p_region_code;
  l_custom_region_items_rec.attribute_application_id      :=  p_attribute_application_id;
  l_custom_region_items_rec.attribute_code                :=  p_attribute_code;
  l_custom_region_items_rec.property_name                 :=  p_property_name;
  l_custom_region_items_rec.property_varchar2_value       :=  p_property_varchar2_value;
  l_custom_region_items_rec.property_number_value         :=  p_property_number_value;
  l_custom_region_items_rec.property_date_value           :=  p_property_date_value;


  BIS_CUSTOMIZATION_PUB.Update_Custom_Region_Items
  ( p_api_version              =>  p_api_version
  , p_commit                   =>  p_commit
  , p_Custom_Region_Items_Rec  =>  l_custom_region_items_rec
  , x_return_status            =>  x_return_status
  , x_msg_count                =>  x_msg_count
  , x_msg_data                 =>  x_msg_data
  );
  IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
    FND_MESSAGE.SET_NAME('BSC','BIS_CUSTOMIZATION_FAIL');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Update_Custom_region_items_UI ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Update_Custom_region_items_UI ';
    END IF;

END Update_Custom_region_items_UI;

PROCEDURE Delete_Custom_Region_Items
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

  BIS_CUSTOMIZATION_PVT.Delete_Custom_Region_Items
  ( p_api_version              =>  p_api_version
  , p_commit                   =>  p_commit
  , p_Custom_Region_Items_Rec  =>  p_Custom_Region_Items_Rec
  , x_return_status            =>  x_return_status
  , x_msg_count                =>  x_msg_count
  , x_msg_data                 =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
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
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Delete_Custom_Region_items ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Delete_Custom_Region_items ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Delete_Custom_Region_items ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Delete_Custom_Region_items ';
    END IF;

END Delete_Custom_Region_Items;

PROCEDURE Delete_Custom_Region_Items_UI
( p_api_version                   IN  NUMBER
, p_commit                        IN  VARCHAR2   := FND_API.G_FALSE
, p_customization_application_id  IN  NUMBER
, p_customization_code            IN  VARCHAR2
, p_region_application_id         IN  NUMBER
, p_region_code                   IN  VARCHAR2
, p_attribute_application_id      IN  NUMBER
, p_attribute_code                IN  VARCHAR2
, p_property_name                 IN  VARCHAR2
, x_return_status                 OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
) IS
  l_custom_region_items_rec       BIS_CUSTOMIZATION_PUB.custom_region_items_type;
BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  l_custom_region_items_rec.customization_application_id := p_customization_application_id;
  l_custom_region_items_rec.customization_code := p_customization_code;
  l_custom_region_items_rec.region_application_id := p_region_application_id;
  l_custom_region_items_rec.region_code := p_region_code;
  l_custom_region_items_rec.attribute_application_id := p_attribute_application_id;
  l_custom_region_items_rec.attribute_code := p_attribute_code;
  l_custom_region_items_rec.property_name := p_property_name;

  BIS_CUSTOMIZATION_PVT.delete_custom_region_items
  ( p_api_version               => p_api_version
  , p_commit                    => p_commit
  , p_custom_region_items_rec   => l_custom_region_items_rec
  , x_return_status             => x_return_status
  , x_msg_count                 => x_msg_count
  , x_msg_data                  => x_msg_data);

  IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
    FND_MESSAGE.SET_NAME('BSC','BIS_CUSTOMIZATION_FAIL');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Delete_Custom_region_items_UI ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Delete_Custom_region_items_UI ';
    END IF;

END Delete_Custom_Region_Items_UI;

PROCEDURE Create_Customizations
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Customizations_Rec  IN  BIS_CUSTOMIZATION_PUB.customizations_type
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2)
IS

BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  BIS_CUSTOMIZATION_PVT.Create_Customizations
  ( p_api_version         =>  p_api_version
  , p_commit              =>  p_commit
  , p_Customizations_Rec  =>  p_Customizations_Rec
  , x_return_status       =>  x_return_status
  , x_msg_count           =>  x_msg_count
  , x_msg_data            =>  x_msg_data
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
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


  BIS_CUSTOMIZATION_PVT.Update_Customizations
  ( p_api_version         =>  p_api_version
  , p_commit              =>  p_commit
  , p_Customizations_Rec  =>  p_Customizations_Rec
  , x_return_status       =>  x_return_status
  , x_msg_count           =>  x_msg_count
  , x_msg_data            =>  x_msg_data
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
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


PROCEDURE Create_Customizations_UI
( p_api_version                   IN  NUMBER
, p_commit                        IN  VARCHAR2  := FND_API.G_FALSE
, p_customization_application_id  IN  NUMBER
, p_customization_code            IN  VARCHAR2
, p_region_application_id         IN  NUMBER
, p_region_code                   IN  VARCHAR2
, p_verticalization_id            IN  VARCHAR2
, p_localization_code             IN  VARCHAR2
, p_org_id                        IN  NUMBER
, p_site_id                       IN  NUMBER
, p_responsibility_id             IN  NUMBER
, p_web_user_id                   IN  NUMBER
, p_default_customization_flag    IN  VARCHAR2
, p_customization_level_id        IN  NUMBER
, p_start_date_active             IN  DATE
, p_end_date_active               IN  DATE
, p_reference_path                IN  VARCHAR2
, p_function_name                 IN  VARCHAR2
, p_developer_mode                IN  VARCHAR2
, p_name                          IN  VARCHAR2
, p_description                   IN  VARCHAR2
, x_return_status                 OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
  l_customizations_rec    BIS_CUSTOMIZATION_PUB.customizations_type;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_customizations_rec.customization_application_id  :=  p_customization_application_id;
  l_customizations_rec.customization_code            :=  p_customization_code;
  l_customizations_rec.region_application_id         :=  p_region_application_id;
  l_customizations_rec.region_code                   :=  p_region_code;
  l_customizations_rec.verticalization_id            :=  p_verticalization_id;
  l_customizations_rec.localization_code             :=  p_localization_code;
  l_customizations_rec.org_id                        :=  p_org_id;
  l_customizations_rec.site_id                       :=  p_site_id;
  l_customizations_rec.responsibility_id             :=  p_responsibility_id;
  l_customizations_rec.web_user_id                   :=  p_web_user_id;
  l_customizations_rec.default_customization_flag    :=  p_default_customization_flag;
  l_customizations_rec.customization_level_id        :=  p_customization_level_id;
  l_customizations_rec.start_date_active             :=  p_start_date_active;
  l_customizations_rec.end_date_active               :=  p_end_date_active;
  l_customizations_rec.reference_path                :=  p_reference_path;
  l_customizations_rec.function_name                 :=  p_function_name;
  l_customizations_rec.developer_mode                :=  p_developer_mode;
  l_customizations_rec.name                          :=  p_name;
  l_customizations_rec.description                   :=  p_description;

  BIS_CUSTOMIZATION_PUB.Create_Customizations
  ( p_api_version         =>  p_api_version
  , p_commit              =>  p_commit
  , p_Customizations_Rec  =>  l_customizations_rec
  , x_return_status       =>  x_return_status
  , x_msg_count           =>  x_msg_count
  , x_msg_data            =>  x_msg_data
  );

  IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
    FND_MESSAGE.SET_NAME('BSC','BIS_CUSTOMIZATION_FAIL');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Create_Customizations_UI ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Create_Customizations_UI ';
    END IF;

END Create_Customizations_UI;

PROCEDURE Update_Customizations_UI
( p_api_version                   IN  NUMBER
, p_commit                        IN  VARCHAR2  := FND_API.G_FALSE
, p_customization_application_id  IN  NUMBER
, p_customization_code            IN  VARCHAR2
, p_region_application_id         IN  NUMBER
, p_region_code                   IN  VARCHAR2
, p_verticalization_id            IN  VARCHAR2
, p_localization_code             IN  VARCHAR2
, p_org_id                        IN  NUMBER
, p_site_id                       IN  NUMBER
, p_responsibility_id             IN  NUMBER
, p_web_user_id                   IN  NUMBER
, p_default_customization_flag    IN  VARCHAR2
, p_customization_level_id        IN  NUMBER
, p_start_date_active             IN  DATE
, p_end_date_active               IN  DATE
, p_reference_path                IN  VARCHAR2
, p_function_name                 IN  VARCHAR2
, p_developer_mode                IN  VARCHAR2
, p_name                          IN  VARCHAR2
, p_description                   IN  VARCHAR2
, x_return_status                 OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
  l_customizations_rec    BIS_CUSTOMIZATION_PUB.customizations_type;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_customizations_rec.customization_application_id  :=  p_customization_application_id;
  l_customizations_rec.customization_code            :=  p_customization_code;
  l_customizations_rec.region_application_id         :=  p_region_application_id;
  l_customizations_rec.region_code                   :=  p_region_code;
  l_customizations_rec.verticalization_id            :=  p_verticalization_id;
  l_customizations_rec.localization_code             :=  p_localization_code;
  l_customizations_rec.org_id                        :=  p_org_id;
  l_customizations_rec.site_id                       :=  p_site_id;
  l_customizations_rec.responsibility_id             :=  p_responsibility_id;
  l_customizations_rec.web_user_id                   :=  p_web_user_id;
  l_customizations_rec.default_customization_flag    :=  p_default_customization_flag;
  l_customizations_rec.customization_level_id        :=  p_customization_level_id;
  l_customizations_rec.start_date_active             :=  p_start_date_active;
  l_customizations_rec.end_date_active               :=  p_end_date_active;
  l_customizations_rec.reference_path                :=  p_reference_path;
  l_customizations_rec.function_name                 :=  p_function_name;
  l_customizations_rec.developer_mode                :=  p_developer_mode;
  l_customizations_rec.name                          :=  p_name;
  l_customizations_rec.description                   :=  p_description;

  BIS_CUSTOMIZATION_PUB.Update_Customizations
  ( p_api_version         =>  p_api_version
  , p_commit              =>  p_commit
  , p_Customizations_Rec  =>  l_customizations_rec
  , x_return_status       =>  x_return_status
  , x_msg_count           =>  x_msg_count
  , x_msg_data            =>  x_msg_data
  );

  IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
    FND_MESSAGE.SET_NAME('BSC','BIS_CUSTOMIZATION_FAIL');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_CUSTOMIZATION_PUB.Update_Customizations_UI ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_CUSTOMIZATION_PUB.Update_Customizations_UI ';
    END IF;

END Update_Customizations_UI;


END BIS_CUSTOMIZATION_PUB;

/
