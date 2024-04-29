--------------------------------------------------------
--  DDL for Package Body BIS_CUSTOMIZATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_CUSTOMIZATIONS_PVT" AS
/* $Header: BISVCUSB.pls 120.1.12000000.2 2007/01/30 08:30:07 ankgoel ship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVCUSB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for seeding ak Customization Data at function level   |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 16-Dec-02 nkishore Creation                                           |
REM | 09-Apr-03 rcmuthuk Added deleteCustomView Enh:2897956                 |
REM | 05-Aug-03 rcmuthuk Added exception block for deleting rows            |
REM | 09-Aug-06 ankgoel  Bug#5412517 Del all customizations for a ak region |
REM | 12-Oct-06 ankgoel  Bug#5559016 Modified delete_region_customizations  |
REM |                    to delete from 2 BIS AK customization tables       |
REM +=======================================================================+
*/
--

-- creates rows in ak_customizations/tl
--
PROCEDURE Create_Customizations
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Customizations_Rec      IN  BIS_CUSTOMIZATIONS_PVT.customizations_type
, x_return_status    OUT NOCOPY VARCHAR2
)

IS
l_language  VARCHAR2(4);
cursor c_languages IS
SELECT language_code
FROM   fnd_languages
WHERE  installed_flag in ('I','B');

BEGIN
  insert into ak_customizations
	   ( CUSTOMIZATION_APPLICATION_ID,CUSTOMIZATION_CODE
	   , REGION_APPLICATION_ID, REGION_CODE
	   , VERTICALIZATION_ID, LOCALIZATION_CODE
	   , ORG_ID,SITE_ID,RESPONSIBILITY_ID
	   , WEB_USER_ID, DEFAULT_CUSTOMIZATION_FLAG
	   , CUSTOMIZATION_LEVEL_ID,CREATED_BY,CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,LAST_UPDATE_LOGIN
	   , START_DATE_ACTIVE,END_DATE_ACTIVE,REFERENCE_PATH
	   , FUNCTION_NAME,DEVELOPER_MODE)

  values( p_Customizations_Rec.CUSTOMIZATION_APPLICATION_ID ,p_Customizations_Rec.CUSTOMIZATION_CODE
        , p_Customizations_Rec.REGION_APPLICATION_ID,p_Customizations_Rec.REGION_CODE
	, p_Customizations_Rec.VERTICALIZATION_ID,p_Customizations_Rec.LOCALIZATION_CODE
	, p_Customizations_Rec.ORG_ID,p_Customizations_Rec.SITE_ID,p_Customizations_Rec.RESPONSIBILITY_ID
	, p_Customizations_Rec.WEB_USER_ID,p_Customizations_Rec.DEFAULT_CUSTOMIZATION_FLAG
	, p_Customizations_Rec.CUSTOMIZATION_LEVEL_ID,0,sysdate,0,sysdate,-1
	, p_Customizations_Rec.START_DATE_ACTIVE,p_Customizations_Rec.END_DATE_ACTIVE,p_Customizations_Rec.REFERENCE_PATH
	, p_Customizations_Rec.FUNCTION_NAME,p_Customizations_Rec.DEVELOPER_MODE);

  if c_languages%ISOPEN then
     close c_languages;
  end if;

  open c_languages;
  loop
    fetch c_languages into l_language;
    exit when c_languages%NOTFOUND;

    insert into ak_customizations_tl
       (CUSTOMIZATION_APPLICATION_ID,CUSTOMIZATION_CODE
	,REGION_APPLICATION_ID,REGION_CODE,NAME
        ,DESCRIPTION,LANGUAGE,SOURCE_LANG,CREATED_BY,CREATION_DATE
	,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN
        )
    values(p_Customizations_Rec.CUSTOMIZATION_APPLICATION_ID,p_Customizations_Rec.CUSTOMIZATION_CODE
	  ,p_Customizations_Rec.REGION_APPLICATION_ID,p_Customizations_Rec.REGION_CODE,p_Customizations_Rec.NAME
	  ,p_Customizations_Rec.DESCRIPTION,l_language,l_language,0,sysdate,0,sysdate,-1);

  end loop;

  if c_languages%ISOPEN then
     close c_languages;
  end if;

  if (p_commit = 'Y') then
    COMMIT;
  end if;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Create_Customizations;
--
--

PROCEDURE Update_Customizations
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Customizations_Rec      IN  BIS_CUSTOMIZATIONS_PVT.customizations_type
, x_return_status    OUT NOCOPY VARCHAR2
)

IS
l_custom_appl_id VARCHAR2(150);
l_custom_code    VARCHAR2(150);
l_reg_appl_id    VARCHAR2(150);
cursor getCustomizationProperty IS
SELECT customization_application_id, customization_code, region_application_id
FROM   ak_customizations
WHERE  region_code = p_Customizations_Rec.region_code
AND    function_name = p_Customizations_Rec.function_name;
BEGIN
  --BugFix 3500031
  IF getCustomizationProperty%ISOPEN THEN
    CLOSE getCustomizationProperty;
  END IF;
  OPEN getCustomizationProperty;
  FETCH getCustomizationProperty into l_custom_appl_id, l_custom_code, l_reg_appl_id;
  IF getCustomizationProperty%ISOPEN THEN
    CLOSE getCustomizationProperty;
  END IF;

  BEGIN
    deleteCustomView
    (  p_regionCode 	    => p_Customizations_Rec.region_code
     , p_customizationCode  => l_custom_code
     , p_regionAppId 	    => l_reg_appl_id
     , p_customizationAppId => l_custom_appl_id
     , x_return_status      => x_return_status
    );
  EXCEPTION
   when no_data_found then
	null;
  END;
   Create_Customizations(p_api_version, p_commit,p_Customizations_Rec,x_return_status);

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Update_Customizations;

PROCEDURE Create_Custom_Regions
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_Regions_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_regions_type
, x_return_status    OUT NOCOPY VARCHAR2
)

IS
l_rowid     VARCHAR2(100);
BEGIN

  ak_custom_regions_pkg.insert_row(
     X_ROWID => l_rowid
   , X_CUSTOMIZATION_APPLICATION_ID => p_Custom_Regions_Rec.CUSTOMIZATION_APPLICATION_ID
   , X_CUSTOMIZATION_CODE => p_Custom_Regions_Rec.CUSTOMIZATION_CODE
   , X_REGION_APPLICATION_ID => p_Custom_Regions_Rec.REGION_APPLICATION_ID
   , X_REGION_CODE => p_Custom_Regions_Rec.REGION_CODE
   , X_PROPERTY_NAME => p_Custom_Regions_Rec.PROPERTY_NAME
   , X_PROPERTY_VARCHAR2_VALUE => p_Custom_Regions_Rec.PROPERTY_VARCHAR2_VALUE
   , X_PROPERTY_NUMBER_VALUE => p_Custom_Regions_Rec.PROPERTY_NUMBER_VALUE
   , X_CRITERIA_JOIN_CONDITION => p_Custom_Regions_Rec.CRITERIA_JOIN_CONDITION
   , X_CREATED_BY => 0
   , X_CREATION_DATE => sysdate
   , X_LAST_UPDATED_BY => 0
   , X_LAST_UPDATE_DATE => sysdate
   , X_LAST_UPDATE_LOGIN => -1
  );
  if (p_commit = 'Y') then
    COMMIT;
  end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Create_Custom_Regions;
--
--
PROCEDURE Update_Custom_Regions
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_Regions_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_regions_type
, x_return_status    OUT NOCOPY VARCHAR2
)

IS
BEGIN
  --BugFix 3500031
/*
  BEGIN
  ak_custom_regions_pkg.delete_row(
     X_CUSTOMIZATION_APPLICATION_ID => p_Custom_Regions_Rec.customization_application_id
   , X_CUSTOMIZATION_CODE => p_Custom_Regions_Rec.customization_code
   , X_REGION_APPLICATION_ID => p_Custom_Regions_Rec.region_application_id
   , X_REGION_CODE => p_Custom_Regions_Rec.region_code
   , X_PROPERTY_NAME => p_Custom_Regions_Rec.property_name
   );
  EXCEPTION
   when no_data_found then
	null;
  END;
*/
   Create_Custom_Regions(p_api_version, p_commit,p_Custom_Regions_Rec,x_return_status);

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END Update_Custom_Regions;

PROCEDURE Create_Custom_Region_Items
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_Region_Items_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_region_items_type
, x_return_status    OUT NOCOPY VARCHAR2
)

IS
l_rowid  VARCHAR2(100);
BEGIN

  ak_custom_region_items_pkg.insert_row(
    X_ROWID =>l_rowid
   ,X_CUSTOMIZATION_APPLICATION_ID => p_Custom_Region_Items_Rec.CUSTOMIZATION_APPLICATION_ID
   ,X_CUSTOMIZATION_CODE => p_Custom_Region_Items_Rec.CUSTOMIZATION_CODE
   ,X_REGION_APPLICATION_ID => p_Custom_Region_Items_Rec.REGION_APPLICATION_ID
   ,X_REGION_CODE =>p_Custom_Region_Items_Rec.REGION_CODE
   ,X_ATTRIBUTE_APPLICATION_ID => p_Custom_Region_Items_Rec.ATTRIBUTE_APPLICATION_ID
   ,X_ATTRIBUTE_CODE => p_Custom_Region_Items_Rec.ATTRIBUTE_CODE
   ,X_PROPERTY_NAME => p_Custom_Region_Items_Rec.PROPERTY_NAME
   ,X_PROPERTY_VARCHAR2_VALUE => p_Custom_Region_Items_Rec.PROPERTY_VARCHAR2_VALUE
   ,X_PROPERTY_NUMBER_VALUE => p_Custom_Region_Items_Rec.PROPERTY_NUMBER_VALUE
   ,X_PROPERTY_DATE_VALUE => p_Custom_Region_Items_Rec.PROPERTY_DATE_VALUE
   ,X_CREATED_BY => 0
   ,X_CREATION_DATE => SYSDATE
   ,X_LAST_UPDATED_BY => 0
   ,X_LAST_UPDATE_DATE => SYSDATE
   ,X_LAST_UPDATE_LOGIN => -1
   );
  if (p_commit = 'Y') then
    COMMIT;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Create_Custom_Region_Items;
--
--
PROCEDURE Update_Custom_Region_Items
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_Region_Items_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_Region_Items_type
, x_return_status    OUT NOCOPY VARCHAR2
)

IS
BEGIN
  --BugFix 3500031
/*
   BEGIN
   ak_custom_region_items_pkg.delete_row(
     X_CUSTOMIZATION_APPLICATION_ID => p_Custom_Region_Items_Rec.customization_application_id
    ,X_CUSTOMIZATION_CODE => p_Custom_Region_Items_Rec.customization_code
    ,X_REGION_APPLICATION_ID => p_Custom_Region_Items_Rec.region_application_id
    ,X_REGION_CODE => p_Custom_Region_Items_Rec.region_code
    ,X_ATTRIBUTE_APPLICATION_ID => p_Custom_Region_Items_Rec.attribute_application_id
    ,X_ATTRIBUTE_CODE => p_Custom_Region_Items_Rec.attribute_code
    ,X_PROPERTY_NAME => p_Custom_Region_Items_Rec.property_name
   );
   EXCEPTION
   when no_data_found then
	null;
   END;
*/
   Create_Custom_Region_items(p_api_version, p_commit,p_Custom_Region_Items_Rec,x_return_status);

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END Update_Custom_Region_items;


-- rcmuthuk deleteCustomView Enh:2897956

PROCEDURE deleteCustomView
( p_regionCode 	      IN VARCHAR2
, p_customizationCode   IN VARCHAR2
, p_regionAppId 	    	IN NUMBER
, p_customizationAppId 	IN NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
)
IS
BEGIN

 IF (p_customizationCode is not null AND p_regionCode is not null) THEN
      DELETE FROM ak_customizations WHERE region_code = p_regionCode AND region_application_id = p_regionAppId AND customization_code = p_customizationCode AND customization_application_id = p_customizationAppId;
	  DELETE FROM ak_customizations_tl WHERE region_code = p_regionCode AND region_application_id = p_regionAppId AND customization_code = p_customizationCode AND customization_application_id = p_customizationAppId;
	  DELETE FROM ak_custom_regions WHERE region_code = p_regionCode AND region_application_id = p_regionAppId AND customization_code = p_customizationCode AND customization_application_id = p_customizationAppId;
	  DELETE FROM ak_custom_regions_tl WHERE region_code = p_regionCode AND region_application_id = p_regionAppId AND customization_code = p_customizationCode AND customization_application_id = p_customizationAppId;
	  DELETE FROM ak_custom_region_items WHERE region_code = p_regionCode AND region_application_id = p_regionAppId AND customization_code = p_customizationCode AND customization_application_id = p_customizationAppId;
  	  DELETE FROM ak_custom_region_items_tl WHERE region_code = p_regionCode AND region_application_id = p_regionAppId AND customization_code = p_customizationCode AND customization_application_id = p_customizationAppId;
 END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END deleteCustomView;

-- Delete all customizations for a ak region
PROCEDURE delete_region_customizations
( p_region_code            IN VARCHAR2
, p_region_application_id  IN NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
)
IS
BEGIN

  DELETE FROM ak_custom_region_items_tl
    WHERE region_code = p_region_code
    AND   region_application_id = p_region_application_id;
  DELETE FROM ak_custom_region_items
    WHERE region_code = p_region_code
    AND   region_application_id = p_region_application_id;
  DELETE FROM ak_custom_regions_tl
    WHERE region_code = p_region_code
    AND   region_application_id = p_region_application_id;
  DELETE FROM ak_custom_regions
    WHERE region_code = p_region_code
    AND   region_application_id = p_region_application_id;
  DELETE FROM ak_customizations_tl
    WHERE region_code = p_region_code
    AND   region_application_id = p_region_application_id;
  DELETE FROM ak_customizations
    WHERE region_code = p_region_code
    AND   region_application_id = p_region_application_id;
  DELETE FROM bis_ak_custom_region_items
    WHERE region_code = p_region_code
    AND   region_application_id = p_region_application_id;
  DELETE FROM bis_ak_custom_regions
    WHERE region_code = p_region_code
    AND   region_application_id = p_region_application_id;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                             , p_count   => x_msg_count
                             , p_data    => x_msg_data);
    IF (x_msg_data IS NULL) THEN
        x_msg_data := 'BIS_CUSTOMIZATIONS_PVT.delete_region_customizations: ' || SQLERRM;
    END IF;
END delete_region_customizations;

END BIS_CUSTOMIZATIONS_PVT;

/
