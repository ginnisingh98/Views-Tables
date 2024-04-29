--------------------------------------------------------
--  DDL for Package Body BIS_PMV_PARAMETERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_PARAMETERS_PUB" as
/* $Header: BISPPARB.pls 120.3 2006/05/11 18:09:25 serao noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.9=120.3):~PROD:~PATH:~FILE

PROCEDURE RETRIEVE_PAGE_PARAMETER
(p_page_session_rec     IN  BIS_PMV_PARAMETERS_PUB.page_session_rec_type
,p_parameter_rec        IN  OUT NOCOPY BIS_PMV_PARAMETERS_PUB.parameter_rec_type
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
) IS
BEGIN
  SELECT session_description,
         session_value,
         period_date,
         dimension,
         operator
  INTO   p_parameter_rec.parameter_description,
         p_parameter_rec.parameter_value,
         p_parameter_rec.period_date,
         p_parameter_rec.dimension,
         p_parameter_rec.operator
  FROM   BIS_USER_ATTRIBUTES
  WHERE  attribute_name = p_parameter_rec.parameter_name
  AND    user_id = p_page_session_rec.user_id
  AND    page_id = p_page_session_rec.page_id;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
END RETRIEVE_PAGE_PARAMETER;

PROCEDURE RETRIEVE_PAGE_PARAMETERS
(p_page_session_rec     IN  BIS_PMV_PARAMETERS_PUB.page_session_rec_type
,x_page_param_tbl       OUT NOCOPY BIS_PMV_PARAMETERS_PUB.parameter_tbl_type
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
) IS
 l_index NUMBER := 1;
 l_parameter_rec BIS_PMV_PARAMETERS_PUB.parameter_rec_type;
 CURSOR c_parameter_cursor IS
 SELECT attribute_name,
        session_description,
        session_value,
        period_date,
        dimension,
        operator
 FROM   BIS_USER_ATTRIBUTES
 WHERE  user_id = p_page_session_rec.user_id
 AND    page_id = p_page_session_rec.page_id
 AND   dimension <>  'TIME_COMPARISON_TYPE'
 AND   attribute_name <> 'AS_OF_DATE';
BEGIN
 FOR c_parameter_rec in c_parameter_cursor LOOP
     l_parameter_rec.parameter_name := c_parameter_rec.attribute_name;
     l_parameter_rec.parameter_description := c_parameter_rec.session_description;
     l_parameter_rec.parameter_value := c_parameter_rec.session_value;
     l_parameter_rec.period_date := c_parameter_rec.period_date;
     l_parameter_rec.dimension := c_parameter_rec.dimension;
     l_parameter_rec.operator := c_parameter_rec.operator;
     x_page_param_tbl(l_index) := l_parameter_rec;
     l_index := l_index + 1;
 END LOOP;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
END RETRIEVE_PAGE_PARAMETERS;
FUNCTION INITIALIZE_QUERY_TYPE
RETURN BIS_QUERY_ATTRIBUTES
IS
  l_query_attributes BIS_QUERY_ATTRIBUTES := BIS_QUERY_ATTRIBUTES(null,null,null,null);
BEGIN
  RETURN l_query_attributes;
END;

FUNCTION INITIALIZE_BIS_BUCKET_REC
RETURN BIS_BUCKET_REC
IS
  l_bucket_rec BIS_BUCKET_REC := BIS_BUCKET_REC(null,null,null, null);
BEGIN
  RETURN l_bucket_rec;
END;

/* nbarik - 05/11/06 - Bug Fix 4881596
--
-- This is a public API which will be called by product teams to clear
-- user level personalization
--
*/
PROCEDURE CLEAR_USER_PERSONALIZATION (
	p_function_name			IN  VARCHAR2
,	p_region_code           IN  VARCHAR2
, 	p_region_application_id IN 	NUMBER
,	x_return_status	    	OUT NOCOPY VARCHAR2
,	x_msg_count		    	OUT NOCOPY NUMBER
,	x_msg_data	        	OUT NOCOPY VARCHAR2
) IS

 CURSOR c_custom_code_cursor IS
 SELECT customview.customization_code, customview.customization_application_id
 FROM ak_customizations customView, bis_ak_custom_regions bookmark
 WHERE customView.region_code=p_region_code AND
 customView.region_application_id=p_region_application_id AND
 customView.customization_code=bookmark.customization_code AND
 customView.customization_application_id=bookmark.customization_application_id AND
 customView.region_code=bookmark.region_code AND
 customView.region_application_id=bookmark.region_application_id AND
 customView.function_name=p_function_name AND
 customView.customization_level_id=30 AND
 bookmark.property_name='BOOKMARK_URL';

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF c_custom_code_cursor%ISOPEN THEN
    CLOSE c_custom_code_cursor;
  END IF;
  FOR cr IN c_custom_code_cursor LOOP
  	-- delete region items customization
    delete from AK_CUSTOM_REGION_ITEMS
    where CUSTOMIZATION_APPLICATION_ID = cr.customization_application_id
    and   CUSTOMIZATION_CODE           = cr.customization_code
    and   REGION_APPLICATION_ID        = p_region_application_id
    and   REGION_CODE                  = p_region_code;

	IF SQL%NOTFOUND THEN
	  NULL;
	END IF;

	delete from AK_CUSTOM_REGION_ITEMS_TL
	where CUSTOMIZATION_APPLICATION_ID = cr.customization_application_id
	and   CUSTOMIZATION_CODE           = cr.customization_code
	and   REGION_APPLICATION_ID        = p_region_application_id
	and   REGION_CODE                  = p_region_code;

	IF SQL%NOTFOUND THEN
	  NULL;
	END IF;

  	-- delete region customization
    delete from AK_CUSTOM_REGIONS
    where CUSTOMIZATION_APPLICATION_ID = cr.customization_application_id
    and   CUSTOMIZATION_CODE           = cr.customization_code
    and   REGION_APPLICATION_ID        = p_region_application_id
    and   REGION_CODE                  = p_region_code;

	IF SQL%NOTFOUND THEN
	  NULL;
	END IF;

	delete from AK_CUSTOM_REGIONS_TL
	where CUSTOMIZATION_APPLICATION_ID = cr.customization_application_id
	and   CUSTOMIZATION_CODE           = cr.customization_code
	and   REGION_APPLICATION_ID        = p_region_application_id
	and   REGION_CODE                  = p_region_code;

	IF SQL%NOTFOUND THEN
	  NULL;
	END IF;

  	-- delete customization
  	AK_CUSTOMIZATIONS_PKG.DELETE_ROW (
		X_CUSTOMIZATION_APPLICATION_ID	=> cr.customization_application_id
	,	X_CUSTOMIZATION_CODE           	=> cr.customization_code
	, 	X_REGION_APPLICATION_ID        	=> p_region_application_id
	,	X_REGION_CODE                  	=> p_region_code
  	);

	IF SQL%NOTFOUND THEN
	  NULL;
	END IF;

  	-- delete bis region customization
    delete from BIS_AK_CUSTOM_REGIONS
    where CUSTOMIZATION_APPLICATION_ID = cr.customization_application_id
    and   CUSTOMIZATION_CODE           = cr.customization_code
    and   REGION_APPLICATION_ID        = p_region_application_id
    and   REGION_CODE                  = p_region_code
  	and   PROPERTY_NAME			       = 'BOOKMARK_URL';

	IF SQL%NOTFOUND THEN
	  NULL;
	END IF;

  END LOOP;
  IF c_custom_code_cursor%ISOPEN THEN
    CLOSE c_custom_code_cursor;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF c_custom_code_cursor%ISOPEN THEN
	    CLOSE c_custom_code_cursor;
	  END IF;
      FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF c_custom_code_cursor%ISOPEN THEN
	    CLOSE c_custom_code_cursor;
	  END IF;
      FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF c_custom_code_cursor%ISOPEN THEN
	    CLOSE c_custom_code_cursor;
	  END IF;
      FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END CLEAR_USER_PERSONALIZATION;

END BIS_PMV_PARAMETERS_PUB;

/
