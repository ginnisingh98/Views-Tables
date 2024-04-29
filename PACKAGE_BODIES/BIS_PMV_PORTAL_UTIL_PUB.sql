--------------------------------------------------------
--  DDL for Package Body BIS_PMV_PORTAL_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_PORTAL_UTIL_PUB" as
/* $Header: BISPPUTB.pls 120.3 2005/12/01 15:18:28 serao noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.28=120.3):~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVPARB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This is the Query Pkg. for PMV.				    |
REM |                                                                       |
REM | HISTORY                                                               |
REM | amkulkar, 04/06/2002, Initial Creation				    |
REM | nkishore, 12/26/2002, bug 2726787 - Java Api returns As of Date as    |
REM | 						ranking parameter
REM +=======================================================================+
*/

TYPE CHAR_TABLE IS TABLE OF VARCHAR2(150);

DIMENSION_GROUP CHAR_TABLE := CHAR_TABLE('ISC_DBI_PLAN_PERF_GROUP' );
RANK_PARAM CHAR_TABLE := CHAR_TABLE('ORGANIZATION+ORGANIZATION');


PROCEDURE GET_DIMENSION_GROUP ( pRegionCode In VARCHAR2
  ,xDimensionGroup  OUT NOCOPY VARCHAR2)
IS

 CURSOR getDimensionGroup IS
  SELECT attribute12
  FROM ak_regions
  WHERE region_code = pRegionCode;
BEGIN

  IF (getDimensionGroup%ISOPEN ) THEN
     CLOSE getDimensionGroup;
  END IF;
  OPEN getDimensionGroup;
  FETCH getDimensionGroup INTO xDimensionGroup;
  CLOSE getDimensionGroup;

  EXCEPTION
    WHEN OTHERS THEN
      IF (getDimensionGroup%ISOPEN ) THEN
         CLOSE getDimensionGroup;
      END IF;
      NULL;
END GET_DIMENSION_GROUP;


FUNCTION GET_DIM_GROUP_RANK (pDimensionGroup IN VARCHAR2 )
 RETURN VARCHAR2
 IS
 BEGIN

   IF pDimensionGroup IS NOT NULL THEN
     IF (DIMENSION_GROUP IS NOT NULL AND DIMENSION_GROUP.COUNT > 0) THEN
      FOR i IN DIMENSION_GROUP.FIRST..DIMENSION_GROUP.LAST LOOP
        IF (DIMENSION_GROUP(i)= pDimensionGroup) THEN
          IF (RANK_PARAM.EXISTS(i)) THEN
            RETURN  RANK_PARAM(i);
          END IF;
        END IF;
      END LOOP;
     END IF;
   END IF;

   RETURN NULL;

   EXCEPTION
    WHEN OTHERS THEN
      NULL;
 END GET_DIM_GROUP_RANK;


PROCEDURE GET_RANKING_AND_REGION_CODE( p_page_id            IN    VARCHAR2
,p_user_id            IN     VARCHAR2
,x_ranking_param      OUT    NOCOPY VARCHAR2
,x_region_code OUT NOCOPY VARCHAR2
,x_function_name OUT NOCOPY VARCHAR2
,x_lov_where OUT NOCOPY VARCHAR2
,x_return_Status      OUT    NOCOPY VARCHAR2
,x_msg_count          OUT    NOCOPY NUMBER
,x_msg_data           OUT    NOCOPY VARCHAR2
)
IS
  -- get the first pop down which is the first dimnsion other than time, time_comaprison_type
   CURSOR c_akitems(pRegionCode in varchar2) IS
   select nvl(attribute2, attribute_code), attribute4
   from ak_region_items
   where region_code = pRegionCode
   and display_sequence = (
      select min(display_sequence)
     from ak_region_items
     where region_code = pRegionCode
    and node_query_flag = 'Y'
    and  nvl( substr(attribute2, 1, instr(attribute2, '+')-1), attribute_code) NOT IN ('TIME', 'TIME_COMPARISON_TYPE', 'EDW_TIME_M', 'CURRENCY', 'FII_CURRENCIES','AS_OF_DATE')
    -- and nvl(attribute2, attribute_code) <> 'AS_OF_DATE'  (reverting the fix for 2726787)
    ); --BugFix 2726787, filtered As Of Date

   CURSOR c_func IS
   SELECT function_name
   FROM bis_user_Attributes
   where page_id = p_page_id
   and user_id=p_user_id;

   l_param_name         VARCHAR2(32000);
   lDimensionGroup VARCHAR2(150);

BEGIN

  x_return_Status := FND_API.G_RET_STS_SUCCESS;

    --First get the function_name for this pagE_id
    IF (c_func%ISOPEN ) THEN
       CLOSE c_func;
    END IF;

    OPEN c_func;
    FETCH c_func INTO x_function_name;
    CLOSE c_func;

    --Get the region code
    x_region_code := BIS_PMV_UTIL.getReportRegion(x_function_name);

    -- dimension group changes
    GET_DIMENSION_GROUP (x_region_code, lDimensionGroup);
    IF lDImensionGroup IS NOT NULL THEN
      x_ranking_param := GET_DIM_GROUP_RANK (lDimensionGroup);
    END IF;

    IF (x_Ranking_param IS NULL ) THEN
        OPEN c_akitems(x_region_code);
        FETCH c_akitems INTO x_ranking_param, x_lov_where;
        CLOSE c_akitems;
    END IF;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);

END GET_RANKING_AND_REGION_CODE;


PROCEDURE GET_RANKING_PARAMETER(
 p_page_id            IN    VARCHAR2
,p_user_id            IN    VARCHAR2
,x_ranking_param      OUT    NOCOPY VARCHAR2
,x_return_Status      OUT    NOCOPY VARCHAR2
,x_msg_count          OUT    NOCOPY NUMBER
,x_msg_data           OUT    NOCOPY VARCHAR2
)
IS

   l_region_code        VARCHAR2(30);
   l_function_name      VARCHAR2(32000);
   l_param_name         VARCHAR2(32000);
   l_lov_where VARCHAR2(150);
BEGIN
  GET_RANKING_AND_REGION_CODE( p_page_id     => p_page_id,
                               p_useR_id     => p_user_id
                                      ,x_ranking_param    => x_ranking_param
                                      ,x_region_code => l_region_code
                                      ,x_function_name => l_function_name
                                      ,x_lov_where => l_lov_where
                                      ,x_return_Status   => x_return_status
                                      ,x_msg_count       => x_msg_count
                                      ,x_msg_data        => x_msg_data
                              );

END;

PROCEDURE GET_TIME_LEVEL_LABEL
(p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,x_time_level_label  OUT    NOCOPY VARCHAR2
,x_return_Status     OUT    NOCOPY VARCHAR2
,x_msg_count         OUT    NOCOPY NUMBER
,x_msg_data          OUT    NOCOPY VARCHAR2
)
IS
  CURSOR c_time IS
  SELECT attribute_name FROM
  bis_user_attributes
  WHERE page_id = p_page_id and
  user_id = p_user_id and
  attribute_name like '%_FROM' and
  dimension in ('TIME','EDW_TIME_M');
  l_time_level_label   varchar2(2000);
  l_time_param_name    varchar2(2000);
BEGIN
  IF (c_time%ISOPEN) THEN
     close c_time;
  END IF;
  OPEN c_time;
  FETCH c_time INTO l_time_param_name;
  CLOSE c_time;
  l_time_level_label := UPPER(BIS_PMV_QUERY_PVT.getParameterAcronym('BIS_TIME_LEVEL_VALUES', l_time_param_name));
  x_time_level_label := l_time_level_label;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END;

-- added user_id for bug 4752246
PROCEDURE GET_TIME_LABEL_FROM_SESSION
(p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
,p_user_id IN VARCHAR2
,x_time_level_label  OUT    NOCOPY VARCHAR2
,x_return_Status     OUT    NOCOPY VARCHAR2
,x_msg_count         OUT    NOCOPY NUMBER
,x_msg_data          OUT    NOCOPY VARCHAR2
)
IS
  CURSOR c_time IS
  SELECT attribute_name FROM
  bis_user_attributes
  WHERE session_id = p_session_id and
  function_name = p_function_name and
  user_id = p_user_id and
  attribute_name like '%_FROM' and
  dimension in ('TIME','EDW_TIME_M');
  l_time_level_label   varchar2(2000);
  l_time_param_name    varchar2(2000);
BEGIN
  IF (c_time%ISOPEN) THEN
     close c_time;
  END IF;
  OPEN c_time;
  FETCH c_time INTO l_time_param_name;
  CLOSE c_time;
  l_time_level_label := UPPER(BIS_PMV_QUERY_PVT.getParameterAcronym('BIS_TIME_LEVEL_VALUES', l_time_param_name));
  x_time_level_label := l_time_level_label;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END GET_TIME_LABEL_FROM_SESSION;


--creating a wrap ard the procedure since the getDyanamicLabel call in java expects a function
FUNCTION getTimeLevelLabel (
p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
) RETURN VARCHAR2
IS
 lLabel VARCHAR2(2000);
 l_return_status VARCHAR2(80);
 l_msg_data VARCHAR2(80);
 l_msg_count NUMBER;
BEGIN
  if (p_page_id IS NOT NULL) THEN
    GET_TIME_LEVEL_LABEL(p_page_id => p_page_id
      ,p_user_id =>p_user_id
      ,x_time_level_label => lLabel
      ,x_return_Status => l_return_status
      ,x_msg_count => l_msg_count
      ,x_msg_data  => l_msg_data
    );
  ELSE
    GET_TIME_LABEL_FROM_SESSION(
      p_session_id => p_session_id
      ,p_function_name => p_function_name
      ,p_user_id => p_user_id
      ,x_time_level_label => lLabel
      ,x_return_Status => l_return_status
      ,x_msg_count => l_msg_count
      ,x_msg_data  => l_msg_data
  );
  END IF;
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    lLabel := '';
  END IF;

  RETURN lLabel ;
END getTimeLevelLabel;

--This pvt funnction added to handle exceptins thrown by the fii api
FUNCTION get_asOfDate_Label (
  pAsOfDate IN DATE
) RETURN VARCHAR2 IS
lASOfDateLabel VARCHAR2(80);
lASOfDateLabel_function VARCHAR2(2000);
BEGIN
  --lASOfDateLabel := FII_TIME_API.day_left_in_qtr(pAsOfDate);
  lASOfDateLabel_function := 'begin :1 := FII_TIME_API.day_left_in_qtr(:2); end;';
  execute immediate lASOfDateLabel_function  using OUT lasofdateLabel , IN pAsOfDate ;
  RETURN lASOfDateLabel;
  EXCEPTION
    WHEN OTHERS THEN
     lASOfDateLabel :='';
END get_asOfDate_Label;

PROCEDURE getAsOfDateAndLabel(
  pAsOfDate IN VARCHAR2,
  xAsOfDate OUT NOCOPY VARCHAR2,
  xAsOfDateLabel OUT NOCOPY VARCHAR2
) IS
 lDate DATE;
 --l_date_format varchar2(2000) := 'Mon dd,yyyy';
BEGIN

  IF (pAsOfDate IS NULL) THEN
    SELECT TRUNC(SYSDATE, 'DD') INTO lDate FROM dual;
    --xAsOfDate := TO_CHAR(lDate, l_date_format);
    xAsOfDate := TO_CHAR(lDate);
    xASOfDateLabel := get_asOfDate_Label(lDate);
  ELSE
    xAsOfDate := pAsOfDate;
    --xASOfDateLabel := get_asOfDate_Label(to_date(xAsOfDate,l_date_format));
    xASOfDateLabel := get_asOfDate_Label(xAsOfDate);
  END IF;

 EXCEPTION
    WHEN OTHERS THEN
     xAsOfDate := pAsOfDate;
     xAsOfDateLabel := '';
END getAsOfDateAndLabel;


--KPI Portlet Pesonalization -ansingh
PROCEDURE GET_RANK_LEVEL_SHRT_NAME
(  p_region_code					IN  VARCHAR2,
	 x_rank_level_shrt_name	OUT NOCOPY VARCHAR2,
	 x_return_status        OUT NOCOPY VARCHAR2,
	 x_msg_count            OUT NOCOPY NUMBER,
	 x_msg_data             OUT NOCOPY VARCHAR2
) IS

l_dimension_group VARCHAR2(150);

CURSOR c_RnkLvlShrtName (pRegionCode IN VARCHAR2) IS
	SELECT nvl(attribute2, attribute_code)
	FROM ak_region_items
	WHERE region_code = pRegionCode
	AND display_sequence = (
		SELECT min(display_sequence)
		FROM ak_region_items
		WHERE region_code = pRegionCode
		AND NVL(substr(attribute2, 1, instr(attribute2, '+')-1), attribute_code)
		NOT IN ('TIME', 'TIME_COMPARISON_TYPE', 'EDW_TIME_M', 'AS_OF_DATE')
	);


BEGIN

    GET_DIMENSION_GROUP (p_region_code, l_dimension_group);
    IF l_dimension_group IS NOT NULL THEN
        x_rank_level_shrt_name := GET_DIM_GROUP_RANK (l_dimension_group);
    END IF;

    IF (x_rank_level_shrt_name IS NULL) THEN
        OPEN c_RnkLvlShrtName(p_region_code);
        FETCH c_RnkLvlShrtName INTO x_rank_level_shrt_name;
        CLOSE c_RnkLvlShrtName;
    END IF;

		x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);

END GET_RANK_LEVEL_SHRT_NAME;





-- This should actually be in the pmv portal pub package
PROCEDURE get_rank_level_and_num_values(
  p_page_id            IN    VARCHAR2
  ,p_user_id            IN VARCHAR2
  ,p_responsibility_id IN VARCHAR2
  ,x_ranking_param OUT NOCOPY VARCHAR2
  ,x_number_values      OUT    NOCOPY NUMBER
  ,x_return_Status      OUT    NOCOPY VARCHAR2
  ,x_msg_count          OUT    NOCOPY NUMBER
  ,x_msg_data           OUT    NOCOPY VARCHAR2
) IS
l_return_status VARCHAR2(80);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_region_code VARCHAR2(30);
l_function_name fnd_form_functions.function_name%TYPE;
l_parameter_rec	BIS_PMV_PARAMETERS_PVT.parameter_rec_type;
l_user_session_rec BIS_PMV_SESSION_PVT.SESSION_REC_TYPE;
v_lov_sql_stmt VARCHAR2(32000);
v_bind_sql  VARCHAR2(32000);
v_bind_variables VARCHAR2(32000);
v_bind_count NUMBER;
l_lov_where VARCHAR2(150);
BEGIN

 -- get the rank level
  GET_RANKING_AND_REGION_CODE( p_page_id     => p_page_id
                               ,p_user_id    => p_user_id
                                      ,x_ranking_param    => x_ranking_param
                                      ,x_region_code => l_region_code
                                      , x_function_name => l_function_name
                                      , x_lov_where => l_lov_where
                                      ,x_return_Status   => x_return_status
                                      ,x_msg_count       => x_msg_count
                                      ,x_msg_data        => x_msg_data
                              );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RETURN;
  END IF;
  /* PMF team no longer needs the number of values for that dimension level . Commenting this code
     out
  l_user_session_rec.function_name := l_function_name;
  l_user_session_rec.region_code := l_region_code;
  l_user_session_rec.page_id := p_page_id;
  l_user_session_rec.user_id := p_user_id;
  l_user_session_rec.responsibility_id := p_responsibility_id;

  l_parameter_rec.parameter_name := x_ranking_param;
  BIS_PMV_PARAMETERS_PVT.RETRIEVE_PAGE_PARAMETER(p_parameter_rec	=> l_parameter_rec
                                                ,p_schedule_id => NULL
                                                ,p_user_session_rec	=> l_user_session_rec
                                                ,p_page_dims  => NULL
                                                ,x_return_status	=> l_return_status
                                                ,x_msg_count		=> l_msg_count
                                                ,x_msg_data	        => l_msg_data );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RETURN;
  END IF;

 -- replace with all so that the query picks up all the values,
 -- restricted only by the lov where clause
   l_parameter_rec.parameter_description := BIS_PMV_PARAMETERS_PVT.G_ALL;
 -- get the lov sql for this level
 IF (x_ranking_param = 'TIME' OR x_ranking_param = 'EDW_TIME') THEN
    BIS_PMV_PARAMETERS_PVT.getTimeLovSql(p_parameter_name => x_ranking_param
                                        ,p_parameter_description => l_parameter_rec.parameter_description
                                        ,p_region_code           => l_region_code
                                        ,p_responsibility_id     => l_user_session_rec.responsibility_id
                                        ,p_org_name              => NULL
                                        ,p_org_value             => NULL
                                        ,x_sql_statement        => v_lov_sql_stmt
                                        ,x_bind_sql             => v_bind_sql
                                        ,x_bind_variables       => v_bind_variables
                                        ,x_bind_count           => v_bind_count
                                        ,x_return_status	=> l_return_status
                                        ,x_msg_count		=> l_msg_count
                                        ,x_msg_data		=> l_msg_data
    );
 ELSE
    BIS_PMV_PARAMETERS_PVT.getLovSql(p_parameter_name => x_ranking_param
                            ,p_parameter_description => l_parameter_rec.parameter_description
                            ,p_sql_type => NULL
                            ,p_region_code => l_region_code
                            ,p_responsibility_id => l_user_session_rec.responsibility_id
                            ,x_sql_statement => v_lov_sql_stmt
                            ,x_bind_sql             => v_bind_sql
                            ,x_bind_variables       => v_bind_variables
                            ,x_bind_count           => v_bind_count
                            ,x_return_status => l_return_status
                            ,x_msg_count => l_msg_count
                            ,x_msg_data	=> l_msg_data);
 END IF;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RETURN;
  END IF;

  BIS_PMV_QUERY_PVT.substitute_lov_where (
    pUserSession_rec => l_user_session_rec,
    pSchedule_id => NULL,
    pSource => NULL,
    x_lov_where => l_lov_where,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data
  ) ;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RETURN;
  END IF;

  -- remove the order by from the lov_sql_stmt and append the lov where to it
    v_lov_sql_stmt := substr( v_lov_sql_stmt, 1, instr (v_lov_sql_stmt, 'order by')-1);
    v_lov_sql_stmt :=     v_lov_sql_stmt || ' '||l_lov_where;

  -- run the sql and obtain the count
  execute immediate 'SELECT count(*) FROM ('||v_lov_sql_stmt||') ' INTO x_number_values;*/
EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);

END get_rank_level_and_num_values;

-- jprabhud - 04/23/04 - Bug 3573468
PROCEDURE clean_portlets
(
	 p_user_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
	,p_page_id in NUMBER DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
	,p_page_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
        ,p_function_name in VARCHAR2 DEFAULT NULL-- jprabhud - 04/23/04 - Bug 3573468
	,x_return_status  OUT NOCOPY VARCHAR2
	,x_msg_count   OUT NOCOPY NUMBER
	,x_msg_data    OUT NOCOPY VARCHAR2
)
IS
BEGIN

     BIS_PMV_PORTAL_UTIL_PVT.clean_portlets
     (   p_user_name => p_user_name
	,p_page_id => p_page_id
	,p_page_name => p_page_name
	,x_return_status  => x_return_status
	,x_msg_count  => x_msg_count
	,x_msg_data   => x_msg_data
	,p_function_name => p_function_name
     );


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data) ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data) ;
  WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);

END clean_portlets ;

END BIS_PMV_PORTAL_UTIL_PUB;

/
