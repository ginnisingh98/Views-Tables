--------------------------------------------------------
--  DDL for Package Body BIS_PMV_PMF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_PMF_PVT" as
/* $Header: BISVPMPB.pls 120.2 2005/09/23 03:58:26 msaran noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.31=120.2):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_PMV_PMF_PVT
--                                                                        --
--  DESCRIPTION:  Target related APIs for PMV
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                --
--  10/17/00   amkulkar   Initial creation                                --
--  02/04/03   nkishore   BugFix 2762795                                  --
--  4/16/03    nkishore   Added pRespId to get_notify_rpt_url bug 2833251 --
--  6/27/03    rcmuthuk   Added p_UserId to get_notify_rpt_url bug 2810397--
--  12/19/03   nkishore   BugFix 3280466 for SONAR                        --
--  1/28/2004  nkishore   BugFix 3075441                                  --
--  5/20/2004  ksadagop   BugFix 3635714                                  --
--  5/26/2004  jprabhud   BugFix 3649405  for SONAR                       --
----------------------------------------------------------------------------
FUNCTION GET_TARGET
(pSource		IN      VARCHAR2
,pSessionId		IN	VARCHAR2
,pRegionCode		IN	VARCHAR2
,pFunctionName		IN	VARCHAR2
,pMeasureShortName 	IN	VARCHAR2	DEFAULT NULL
,pPlanId		IN	VARCHAR2	DEFAULT NULL
,pDimension1		IN	VARCHAR2	DEFAULT NULL
,pDim1Level		IN      VARCHAR2	DEFAULT NULL
,pDim1LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension2		IN	VARCHAR2	DEFAULT NULL
,pDim2Level		IN      VARCHAR2	DEFAULT NULL
,pDim2LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension3		IN	VARCHAR2	DEFAULT NULL
,pDim3Level		IN      VARCHAR2	DEFAULT NULL
,pDim3LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension4		IN	VARCHAR2	DEFAULT NULL
,pDim4Level		IN      VARCHAR2	DEFAULT NULL
,pDim4LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension5		IN	VARCHAR2	DEFAULT NULL
,pDim5Level		IN      VARCHAR2	DEFAULT NULL
,pDim5LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension6		IN	VARCHAR2	DEFAULT NULL
,pDim6Level		IN      VARCHAR2	DEFAULT NULL
,pDim6LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension7		IN	VARCHAR2	DEFAULT NULL
,pDim7Level		IN      VARCHAR2	DEFAULT NULL
,pDim7LevelValue	IN	VARCHAR2	DEFAULT NULL
)
RETURN VARCHAR2
IS
  vTarget               VARCHAR2(1000);
  l_return_Status             VARCHAR2(32000);
  l_target_level_rec          BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_target_rec              BIS_TARGET_PUB.TARGET_REC_TYPE;
  l_target_level_rec_p        BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_target_rec_p                BIS_TARGET_PUB.TARGET_REC_TYPE;
  l_error_tbl                 BIS_UTILITIES_PUB.ERROR_TBL_TYPE;
  v_range1_low                varchar2(200);
  v_range1_high               varchar2(200);
  l_target		      VARCHAR2(32000);
  l_target_url 		      VARCHAR2(32000);
  l_dim1_level_value_id         varchar2(32000);
  l_dim2_level_value_id         varchar2(32000);
  l_dim3_level_value_id         varchar2(32000);
  l_dim4_level_value_id         varchar2(32000);
  l_dim5_level_value_id         varchar2(32000);
  l_dim6_level_value_id         varchar2(32000);
  l_dim7_level_value_id         varchar2(32000);
  l_dimension1_level_short_name       varchar2(80);
  l_dimension2_level_short_name       varchar2(80);
  l_dimension3_level_short_name       varchar2(80);
  l_dimension4_level_short_name       varchar2(80);
  l_dimension5_level_short_name       varchar2(80);
  l_dimension6_level_short_name       varchar2(80);
  l_dimension7_level_short_name       varchar2(80);
BEGIN
  l_target_level_rec.measure_short_name := pMeasureShortName;
  l_dimension1_level_short_name := pDim1Level;
  l_dimension2_level_short_name := pDim2Level;
  l_dimension3_level_short_name := pDim3Level;
  l_dimension4_level_short_name := pDim4Level;
  l_dimension5_level_short_name := pDim5Level;
  l_dimension6_level_short_name := pDim6Level;
  l_dimension7_level_short_name := pDim7Level;
  l_target_rec.plan_id := pPlanId;
  if (upper(pDim1LevelValue) = 'ALL' OR
      pDim1LevelValue = '' OR
      (pDim1Level is not null and pDim1LevelValue is null))
  then
     l_dimension1_level_short_name := getTotalDimLevelName(pDimension1,pSource);
     l_dim1_level_value_id := getTotalDimValue(pSource,pDimension1
								,l_dimension1_level_short_name);
  else
     l_dim1_level_value_id := pDim1LevelValue;
  end if;
  if (upper(pDim2LevelValue) = 'ALL' OR
      pDim2LevelValue = '' OR
      (pDim2Level is not null and pDim2LevelValue is null))
  then
     l_dimension2_level_short_name := getTotalDimLevelName(pDimension2,pSource);
     l_dim2_level_value_id := getTotalDimValue(pSource,pDimension2
								,l_dimension2_level_short_name);
  else
     l_dim2_level_value_id := pDim2LevelValue;
  end if;
  if (upper(pDim3LevelValue) = 'ALL' OR
      pDim3LevelValue = '' OR
      (pDim3Level is not null and pDim3LevelValue is null))
  then
     l_dimension3_level_short_name := getTotalDimLevelName(pDimension3,pSource);
     l_dim3_level_value_id := getTotalDimValue(pSource,pDimension3
								,l_dimension3_level_short_name);
  else
     l_dim3_level_value_id := pDim3LevelValue;
  end if;
  if (upper(pDim4LevelValue) = 'ALL'  OR
      pDim4LevelValue = '' OR
      (pDim4Level is not null and pDim4LevelValue is null))
  then
     l_dimension4_level_short_name := getTotalDimLevelName(pDimension4,pSource);
     l_dim4_level_value_id := getTotalDimValue(pSource,pDimension4
								,l_dimension4_level_short_name);
  else
     l_dim4_level_value_id := pDim4LevelValue;
  end if;
  if (upper(pDim5LevelValue) = 'ALL'  OR
      pDim5LevelValue = '' OR
      (pDim5Level is not null and pDim5LevelValue is null))
  then
     l_dimension5_level_short_name := getTotalDimLevelName(pDimension5,pSource);
     l_dim5_level_value_id := getTotalDimValue(pSource,pDimension5
								,l_dimension5_level_short_name);
  else
     l_dim5_level_value_id := pDim5LevelValue;
  end if;
  if (upper(pDim6LevelValue) = 'ALL'  OR
      pDim6LevelValue = '' OR
      (pDim6Level is not null and pDim6LevelValue is null))
  then
     l_dimension6_level_short_name := getTotalDimLevelName(pDimension6,pSource);
     l_dim6_level_value_id := getTotalDimValue(pSource,pDimension6
								,l_dimension6_level_short_name);
  else
     l_dim6_level_value_id := pDim6LevelValue;
  end if;
  if (upper(pDim7LevelValue) = 'ALL'  OR
      pDim7LevelValue = '' OR
      (pDim7Level is not null and pDim7LevelValue is null))
  then
     l_dimension7_level_short_name := getTotalDimLevelName(pDimension7,pSource);
     l_dim7_level_value_id := getTotalDimValue(pSource,pDimension7
								,l_dimension7_level_short_name);
  else
     l_dim7_level_value_id := pDim7LevelValue;
  end if;

  l_target_rec.dim1_level_Value_id := l_dim1_level_Value_id;
  l_target_rec.dim2_level_Value_id := l_dim2_level_Value_id;
  l_target_rec.dim3_level_Value_id := l_dim3_level_Value_id;
  l_target_rec.dim4_level_Value_id := l_dim4_level_Value_id;
  l_target_rec.dim5_level_Value_id := l_dim5_level_Value_id;
  l_target_rec.dim6_level_Value_id := l_dim6_level_Value_id;
  l_target_rec.dim7_level_Value_id := l_dim7_level_Value_id;
  l_Target_level_Rec.dimension1_level_short_name := l_dimension1_level_short_name;
  l_Target_level_Rec.dimension2_level_short_name := l_dimension2_level_short_name;
  l_Target_level_Rec.dimension3_level_short_name := l_dimension3_level_short_name;
  l_Target_level_Rec.dimension4_level_short_name := l_dimension4_level_short_name;
  l_Target_level_Rec.dimension5_level_short_name := l_dimension5_level_short_name;
  l_Target_level_Rec.dimension6_level_short_name := l_dimension6_level_short_name;
  l_Target_level_Rec.dimension7_level_short_name := l_dimension7_level_short_name;
  l_target_level_rec_p := l_target_level_rec;
  l_target_rec_p := l_target_rec;
  --BugFix 2762795
  BIS_TARGET_PUB.RETRIEVE_TARGET_FROM_SHNMS
  (p_api_version      => 1.0
  ,p_target_level_rec => l_target_level_rec_p
  ,p_Target_Rec       => l_target_rec_p
  ,x_Target_Level_Rec => l_target_level_rec
  ,x_Target_Rec       => l_target_rec
  ,x_return_status    => l_return_status
  ,x_error_Tbl        => l_error_tbl
  );
  IF (l_return_Status = FND_API.G_RET_STS_ERROR) THEN
      vTarget := 'NONE';
      v_range1_high := 'NONE';
      v_range1_low := 'NONE';
  else
      vTarget := l_target_rec.target;
      v_range1_low := l_target_rec.range1_low;
      v_range1_high := l_target_rec.range1_high;
      if (l_target_rec.target_id is null) or (l_target_rec.target_id = FND_API.G_MISS_NUM) then
         vTarget := 'NONE';
	 v_range1_low := 'NONE';
         v_Range1_high := 'NONE';
      else
         if (v_range1_low = FND_API.G_MISS_NUM) or (v_range1_low is null) then
            v_range1_low := 'NONE';
         end if;
         if (v_range1_high = FND_API.G_MISS_NUM) or (v_range1_high is null)  then
            v_range1_high := 'NONE';
         end if;
      end if;
   END IF;

   l_Target_url :=  FND_WEB_CONFIG.trail_slash(FND_WEB_CONFIG.WEB_SERVER)||
                   'OA_HTML/bistared.jsp?dbc=' || FND_WEB_CONFIG.DATABASE_ID
                   ||'&sessionid='||pSessionId
                   ||'&RegionCode='||bis_pmv_util.encode(pRegionCode)
                   ||'&FunctionName='||bis_pmv_util.encode(pFunctionName)
                   ||'&SortInfo='||bis_pmv_util.encode('Sortcolumn2Asc')
                   ||'&Measure='||pMeasureShortName||'&PlanId='||pPlanId
		   ||'&Dim1Level='|| BIS_PMV_UTIL.encode(l_dimension1_level_short_name)
		   ||'&Dim2Level='|| BIS_PMV_UTIL.encode(l_dimension2_level_short_name)
		   ||'&Dim3Level='|| BIS_PMV_UTIL.encode(l_Dimension3_level_short_name)
		   ||'&Dim4Level='|| BIS_PMV_UTIL.encode(l_Dimension4_level_short_name)
		   ||'&Dim5Level='|| BIS_PMV_UTIL.encode(l_dimension5_level_short_name)
		   ||'&Dim6Level='|| BIS_PMV_UTIL.encode(l_Dimension6_level_short_name)
		   ||'&Dim7Level='|| BIS_PMV_UTIL.encode(l_dimension7_level_short_name)
		   ||'&Dim1LevelValue='||BIS_PMV_UTIL.encode(l_dim1_level_Value_id)
		   ||'&Dim2LevelValue='||BIS_PMV_UTIL.encode(l_dim2_level_Value_id)
		   ||'&Dim3LevelValue='||BIS_PMV_UTIL.encode(l_dim3_level_Value_id)
		   ||'&Dim4LevelValue='||BIS_PMV_UTIL.encode(l_dim4_level_value_id)
		   ||'&Dim5LevelValue='||BIS_PMV_UTIL.encode(l_dim5_level_value_id)
		   ||'&Dim6LevelValue='||BIS_PMV_UTIL.encode(l_dim6_level_value_id)
		   ||'&Dim7LevelValue='||BIS_PMV_UTIL.encode(l_dim7_level_value_id);
   l_target := l_target_url||'*'||vTarget||'**'||v_range1_low||'***'||v_range1_high;
   return l_target;
         --return 'T_' || vTarget || '_' || v_range1_low || '_' || v_range1_high;
END GET_TARGET;
FUNCTION getTotalDimValue
(pDimSource 		IN 	VARCHAR2,
 pDimension 		IN 	VARCHAR2 DEFAULT NULL,
 pDimensionLevel 	IN 	VARCHAR2
)
RETURN VARCHAR2
IS
   v_sql_stmnt     VARCHAR2(2000);
   v_table         varchar2(80);
   v_id_name       VARCHAR2(80):='ID';
   v_value_name    VARCHAR2(80):='VALUE';
   v_return_status VARCHAR2(2000);
   v_msg_count     NUMBER;
   v_msg_data      VARCHAR2(2000);
   vsql     varchar2(1000);
   type c1CurType     is ref cursor;
   c1                 c1CurType;
   vtotallevelvalue   varchar2(32000);
BEGIN
    BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING(
        p_DimLevelShortName => pDimensionLevel
        ,p_bis_source => pDimSource
        ,x_Select_String => v_sql_stmnt
        ,x_table_name=>     v_table
        ,x_id_name=>        v_id_name
        ,x_value_name=>     v_value_name
        ,x_return_status=>  v_return_status
        ,x_msg_count=>      v_msg_count
        ,x_msg_data=>       v_msg_data
        );

    /*if v_return_status = FND_API.G_RET_STS_ERROR then
        for i in 1..v_msg_count loop
          htp.print(fnd_msg_pub.get(p_msg_index=>i, p_encoded=>FND_API.G_FALSE));
		  htp.br;
        end loop;
    end if;*/

    vSql := 'select '||v_id_name||' from '||v_table;

    begin
        open c1 for vSql;
        loop
            exit when c1%notfound;
            fetch c1 into vTotalLevelValue;
        end loop;
    exception
    when others then
       null;
    end;
    RETURN (VTotalLevelValue);
END;
Function getTotalDimLevelName
(pDimShortName IN VARCHAR2
,pSource      IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c_dims IS
  SELECT dimension_id
  FROM bis_dimensions
  WHERE short_name = pDimShortName;

  CURSOR c_dimlvls(p_dim_id IN NUMBER, p_search_string IN VARCHAR2) IS
  SELECT short_name
  FROM bis_levels
  where short_name like p_Search_string AND
  dimension_id= p_dim_id;
  l_dim_id NUMBER;
  l_search_string   VARCHAR2(32000);
  l_total_shortname  VARCHAR2(32000);
BEGIN
  OPEN c_dims;
  FETCH c_dims INTO l_dim_id;
  CLOSE c_dims;
  IF (pSource = 'EDW') THEN
      l_search_string := '%_A';
  ELSE
      l_search_string := 'TOTAL%';
  END IF;
  OPEN c_dimlvls(l_dim_id, l_search_string);
  FETCH c_dimlvls INTO l_total_shortname ;
  CLOSE c_dimlvls;
  RETURN l_total_shortname;
END;
PROCEDURE TOLERANCE_TEST
(p_target_value		IN	VARCHAR2
,p_actual_value		IN	VARCHAR2
,p_range1_high	        IN	VARCHAR2
,p_range1_low		IN	VARCHAR2
,x_tolerance		OUT	NOCOPY VARCHAR2
)
IS
	pToleranceFlag		VARCHAR2(32000);
	v_target_rec  BIS_TARGET_PUB.Target_Rec_Type;
        v_actual_rec  BIS_ACTUAL_PUB.Actual_Rec_Type;
        v_comparison_result varchar2(1000);
BEGIN
    pToleranceFlag :='ON';
    v_target_rec.Target := p_target_value;
    v_target_rec.Range1_high := p_range1_high ;
    v_target_rec.Range1_low := p_range1_low;
    v_actual_rec.Actual := p_actual_value;

    BIS_GENERIC_PLANNER_PVT.Compare_Values
    ( p_target_rec  => v_target_rec
    , p_actual_rec  => v_actual_rec
    , x_comparison_result  => v_comparison_result
    );

    if v_comparison_result <> BIS_GENERIC_PLANNER_PVT.G_COMP_RESULT_NORMAL then
       pToleranceFlag := 'OFF';
    end if;
    x_tolerance := pToleranceFlag;
END;

 --BugFix 3075441, add p_NlsLangCode
FUNCTION GET_NOTIFY_RPT_URL(
 p_measure_id                  IN   VARCHAR2
,p_region_code                 in   varchar2 default null
,p_function_name               in   varchar2 default null
,p_bplan_name                  IN   VARCHAR2 default null
,p_viewby_level_short_name     IN   VARCHAR2 default null
,p_Parm1Level_short_name  IN   VARCHAR2 default null
,p_Parm1Value_name  IN   VARCHAR2 default null
,p_Parm2Level_short_name  IN   VARCHAR2 default null
,p_Parm2Value_name  IN   VARCHAR2 default null
,p_Parm3Level_short_name  IN   VARCHAR2 default null
,p_Parm3Value_name  IN   VARCHAR2 default null
,p_Parm4Level_short_name  IN   VARCHAR2 default null
,p_Parm4Value_name  IN   VARCHAR2 default null
,p_Parm5Level_short_name  IN   VARCHAR2 default null
,p_Parm5Value_name  IN   VARCHAR2 default null
,p_Parm6Level_short_name  IN   VARCHAR2 default null
,p_Parm6Value_name  IN   VARCHAR2 default null
,p_Parm7Level_short_name  IN   VARCHAR2 default null
,p_Parm7Value_name  IN   VARCHAR2 default null
,p_Parm8Level_short_name  IN   VARCHAR2 default null
,p_Parm8Value_name  IN   VARCHAR2 default null
,p_Parm9Level_short_name  IN   VARCHAR2 default null
,p_Parm9Value_name  IN   VARCHAR2 default null
,p_Parm10Level_short_name IN   VARCHAR2 default null
,p_Parm10Value_name IN   VARCHAR2 default null
,p_Parm11Level_short_name IN   VARCHAR2 default null
,p_Parm11Value_name IN   VARCHAR2 default null
,p_Parm12Level_short_name IN   VARCHAR2 default null
,p_Parm12Value_name IN   VARCHAR2 default null
,p_Parm13Level_short_name IN   VARCHAR2 default null
,p_Parm13Value_name IN   VARCHAR2 default null
,p_TimeParmLevel_short_name in varchar2 default null
,p_TimeFromParmValue_name in varchar2 default null
,p_TimeToParmValue_name in varchar2 default null
,p_resp_id in varchar2 default null
,p_UserId IN VARCHAR2 default null
,p_NlsLangCode IN VARCHAR2 default null)
RETURN VARCHAR2
IS
   --jprabhud defaulted to NULL enhancement#2184054
   vURL varchar2(2000) := NULL;
   vFileId number := 0;
   vSessionId varchar2(32000);
   --vUserId varchar2(20) := 'Notification';  --Bug Fix 2165959
   --vRespId varchar2(10) := 'NULL';
   --jprabhud - 5/26/2004 - BugFix 3649405  for SONAR
   --vUserId varchar2(20) := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
   --vRespId varchar2(10) := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
   vUserId varchar2(20);
   vRespId varchar2(10);
   vNotifId varchar2 (32000);

   vParameter1          varchar2(100);
   vParameter2          varchar2(100);
   vParameter3          varchar2(100);
   vParameter4          varchar2(100);
   vParameter5          varchar2(100);
   vParameter6          varchar2(100);
   vParameter7          varchar2(100);
   vParameter8          varchar2(100);
   vParameter9          varchar2(100);
   vParameter10          varchar2(100);
   vParameter11          varchar2(100);
   vParameter12          varchar2(100);
   vParameter13          varchar2(100);
   vParameter14          varchar2(100);
   vParameter15          varchar2(100);

   vParm14Value_name    varchar2(100);
   vParm15Value_name    varchar2(100);

   vTimeParameter       VARCHAR2(100);
   vTimeFromParameter   VARCHAR2(100);
   vTimeToParameter     VARCHAR2(100);

   vReturnStatus        varchar2(2000);
   vMsgData             varchar2(2000);
   vMsgCount            number;

   vReportURL           varchar2(2000);
   vHTMLPieces          utl_http.html_pieces;


   --jprabhud added for enhancement#2184054
   l_err           varchar2(2000);
   l_return_status  varchar2(1) := FND_API.G_RET_STS_SUCCESS;

   l_nested_region_code varchar2(100);

   lAsOfDateValue varchar2(100);


   ---jprabhud added Cursor, also added VIEWBY PARAMETER in where clause for enhancement#2184054

   CURSOR c_dimlvl(p_search_string IN VARCHAR2, p_view_by_level IN VARCHAR2 ) IS
      select attribute2
      FROM ak_region_items ak
      where ak.region_code = p_region_code
      AND ak.attribute1 in (G_DIMENSION_LEVEL, G_DIM_LEVEL_SINGLE_VALUE,G_VIEWBY_PARAMETER)
      AND    substr(ak.attribute2, instr(ak.attribute2, '+')+1)
      = nvl(p_view_by_level, substr(ak.attribute2, instr(ak.attribute2, '+')+1))
      AND    substr(ak.attribute2, 1,instr(ak.attribute2, '+')-1)
      like nvl(p_search_string, substr(ak.attribute2, 1,instr(ak.attribute2, '+')-1))
      order by  display_sequence;
   --BugFix 3280466
   CURSOR get_nested_region IS
      select nested_region_code from ak_region_items
      where region_code = p_region_code
      and nested_region_code is not null;


BEGIN

  --jprabhud - 5/26/2004 - BugFix 3649405  for SONAR
  /*
  --BugFix 2833251 Added p_resp_id
  if (p_resp_id is not null) then
     vRespId := p_resp_id;
  end if;
  -- rcmuthuk BugFix:2810397 added p_UserId
  if (p_UserId is not null) then
     vUserId := p_UserId;
  end if;
  */

  --BugFix 3280466
  open get_nested_region;
  fetch get_nested_region into l_nested_region_code;
  close get_nested_region;


  if p_region_code is not null and p_function_name is not null then
  --jprabhud added BEGIN enhancement#2184054
  BEGIN
    IF ( p_parm1Level_short_name IS NOT NULL) THEN
    begin
     --BugFix 3280466 Changed all the sqls to also check from Nested Region
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter1
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm1Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm1Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm1Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm1Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm1Level_short_name);
    end;
    END IF;

    IF ( p_parm2Level_short_name IS NOT NULL) THEN
    begin

      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter2
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm2Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm2Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm2Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm2Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm2Level_short_name);
    end;

    END IF;

    IF ( p_parm3Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter3
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm3Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm3Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm3Value_name;
      END IF;

    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm3Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm3Level_short_name);
    end;

    END IF;

    IF ( p_parm4Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter4
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm4Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm4Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm4Value_name;
      END IF;
    exception
       --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm4Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm4Level_short_name);
    end;

    END IF;

    IF ( p_parm5Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter5
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm5Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm5Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm5Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm5Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm5Level_short_name);
    end;

    END IF;

    IF ( p_parm6Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter6
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm6Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm6Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm6Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm6Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm6Level_short_name);
    end;

    END IF;

    IF ( p_parm7Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter7
      from   ak_region_items_vl AK
      where  ak.region_code = p_region_code
      AND    substr(ak.attribute2, instr(ak.attribute2, '+')+1) = p_parm7Level_short_name
      AND    ak.node_query_flag = 'Y';
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm7Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm7Level_short_name);
    end;

    END IF;

    IF ( p_parm8Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter8
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm8Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm8Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm8Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm8Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm8Level_short_name);
    end;

    END IF;

    IF ( p_parm9Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter9
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm9Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm9Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm9Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm9Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm9Level_short_name);
    end;

    END IF;

    IF ( p_parm10Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter10
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm10Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm10Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm10Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm10Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm10Level_short_name);
    end;

    END IF;

    IF ( p_parm11Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter11
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm11Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm11Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm11Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm11Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm11Level_short_name);
    end;

    END IF;

    IF ( p_parm12Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter12
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm12Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm12Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm12Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm12Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm12Level_short_name);
    end;

    END IF;

    IF ( p_parm13Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter13
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm13Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm13Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm13Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm13Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm13Level_short_name);
    end;

    END IF;

   IF (p_bplan_name IS NOT NULL) THEN
      vParameter14:='BUSINESS_PLAN';
      vParm14Value_name:= p_bplan_name;
   END IF;
/*
   IF (p_viewby_level_short_name IS NOT NULL) THEN

      vParameter15 := 'VIEW_BY';
    begin
      Select attribute2
      into   vParm15Value_name
      from   ak_region_items_vl AK
      where  ak.region_code = p_region_code
      AND    substr(ak.attribute2, instr(ak.attribute2, '+')+1) = p_viewby_level_short_name
      AND    ak.attribute1 in ('DIMENSION LEVEL', 'DIM LEVEL SINGLE VALUE');
    exception
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_viewby_level_short_name ||' does not match the level short name defined in AK.');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_viewby_level_short_name);
    end;

   END IF;
*/

   --jprabhud enhancement#2184054*/
   IF (p_viewby_level_short_name IS NOT NULL) THEN
   begin
     if c_dimlvl%ISOPEN then
        CLOSE c_dimlvl;
     end if;
     vParameter15 := 'VIEW_BY';
     if(BIS_UTILITIES_PVT.is_total_dimlevel(p_viewby_level_short_name,l_err)  = FALSE)
     then
        OPEN c_dimlvl(NULL, p_viewby_level_short_name);
        FETCH c_dimlvl INTO vParm15Value_name ;
        if c_dimlvl%NOTFOUND then
            CLOSE c_dimlvl;
            RAISE NO_DATA_FOUND;
        end if;
        CLOSE c_dimlvl;
    else
        if(p_TimeParmLevel_short_name IS NOT NULL)
        then
           OPEN c_dimlvl('%TIME%', NULL);
           LOOP
           FETCH c_dimlvl INTO vParm15Value_name ;
           if c_dimlvl%NOTFOUND then
               CLOSE c_dimlvl;
               RAISE NO_DATA_FOUND;
           end if;
           EXIT WHEN BIS_UTILITIES_PVT.is_total_dimlevel(substr(vParm15Value_name,
                     instr(vParm15Value_name, '+')+1),l_err) = FALSE;
           END LOOP;
           CLOSE c_dimlvl;
        else
           OPEN c_dimlvl(NULL, NULL);
           LOOP
           FETCH c_dimlvl INTO vParm15Value_name ;
           if c_dimlvl%NOTFOUND then
               CLOSE c_dimlvl;
               RAISE NO_DATA_FOUND;
           end if;
           EXIT WHEN BIS_UTILITIES_PVT.is_total_dimlevel(substr(vParm15Value_name,
                     instr(vParm15Value_name, '+')+1),l_err) = FALSE;
           END LOOP;
           CLOSE c_dimlvl;
        end if;
    end if;
    EXCEPTION
    --jprabhud added l_return_status enhancement#2184054
    WHEN NO_DATA_FOUND then
        l_return_status := FND_API.G_RET_STS_ERROR;
        htp.print(p_viewby_level_short_name ||' does not match the level short name defined in AK .');
    WHEN  others then
        l_return_status := FND_API.G_RET_STS_ERROR;
        htp.print('cannot obtain correct info for level short name: '||p_viewby_level_short_name);
end;
END IF;

   IF (p_TimeParmLevel_short_name IS NOT NULL) THEN

      IF (p_TimeFromparmValue_name IS NOT NULL) THEN
      begin
          Select nvl(attribute2,attribute_code)
          into   vTimeParameter
          from   ak_region_items_vl AK
          where  ak.region_code = p_region_code
          AND    substr(ak.attribute2, instr(ak.attribute2, '+')+1) = p_TimeparmLevel_short_name
          AND    ak.attribute1 in ('DIMENSION LEVEL', 'DIM LEVEL SINGLE VALUE', 'HIDE VIEW BY DIMENSION');
      exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_TimeparmLevel_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_TimeparmLevel_short_name);
      end;

          vTimeFromParameter := p_TimeFromparmValue_name;
     END IF;

     IF (p_TimetoparmValue_name IS NOT NULL) THEN
          vTimeToParameter := p_TimeToparmValue_name;
     END IF;
     --BugFix 3280466
     IF (lAsOfDateValue is not null and l_nested_region_code is not null ) THEN
          vTimeFromParameter := 'DBC_TIME';
          vTimeToParameter := 'DBC_TIME';
     END IF;
   END IF;

   --Create an entry in FND_LOBs and get the corresponding file id
   vFileId := BIS_SAVE_REPORT.createEntry('BIS Notification', 'text/html', null, null);

   --jprabhud - 5/26/2004 - BugFix 3649405  for SONAR
   --select 'Notice_'||bis_notification_id_s.nextval into vSessionId from dual;
   select bis_notification_id_s.nextval into vNotifId from dual;
   vSessionId := 'Notice_'|| vNotifId;

   --BugFix 2833251 Added p_resp_id
    if (p_resp_id is not null) then
      vRespId := p_resp_id;
    else
      begin
        vRespId := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
      exception
        when others then
          vRespId := vNotifId;
      end;
    end if;
    -- rcmuthuk BugFix:2810397 added p_UserId
    if (p_UserId is not null) then
      vUserId := p_UserId;
    else
      begin
        vUserId := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
      exception
        when others then
           vUserId := vNotifId;
      end;
    end if;

   BIS_PMV_PARAMETERS_PVT.saveParameters
   (pRegionCode       => p_region_code,
    pFunctionName     => p_function_name,
    pSessionId        => vSessionId,
    pUserId           => vUserId,
    pResponsibilityId => vRespId,
    pParameter1       => vParameter1,
    pParameterValue1  => p_Parm1Value_name,
    pParameter2       => vParameter2,
    pParameterValue2  => p_Parm2Value_name,
    pParameter3       => vParameter3,
    pParameterValue3  => p_Parm3Value_name,
    pParameter4       => vParameter4,
    pParameterValue4  => p_Parm4Value_name,
    pParameter5       => vParameter5,
    pParameterValue5  => p_Parm5Value_name,
    pParameter6       => vParameter6,
    pParameterValue6  => p_Parm6Value_name,
    pParameter7       => vParameter7,
    pParameterValue7  => p_Parm7Value_name,
    pParameter8       => vParameter8,
    pParameterValue8  => p_Parm8Value_name,
    pParameter9       => vParameter9,
    pParameterValue9  => p_Parm9Value_name,
    pParameter10      => vParameter10,
    pParameterValue10 => p_Parm10Value_name,
    pParameter11      => vParameter11,
    pParameterValue11 => p_Parm11Value_name,
    pParameter12      => vParameter12,
    pParameterValue12 => p_Parm12Value_name,
    pParameter13      => vParameter13,
    pParameterValue13 => p_Parm13Value_name,
    pParameter14      => vParameter14,
    pParameterValue14 => vParm14Value_name,
    pTimeParameter    => vTimeParameter,
    pTimeFromParameter=> vTimeFromParameter,
    pTimeToParameter  => vTimeToParameter,
    pViewByValue      => vParm15Value_name,
    pAddToDefault     => 'N',
    pAsOfDateValue    => lAsOfDateValue,
    pAsOfDateMode     => 'CURRENT',
    x_return_status   => vReturnStatus,
    x_msg_count	      => vMsgCount,
    x_msg_data        => vMsgData
    );


   --jprabhud added enhancement#2184054
    if(l_return_status <> FND_API.G_RET_STS_ERROR) then
       l_return_status := nvl(vReturnStatus,FND_API.G_RET_STS_SUCCESS);
    end if;


/*
    vReportURL := FND_WEB_CONFIG.trail_slash(FND_WEB_CONFIG.PLSQL_AGENT)
                || 'bisviewer.showReport?pRegionCode='||p_region_code||'&pFunctionName='||p_function_name
                ||'&pSessionId='||vSessionId||'&pUserId='||vUserId||'&pResponsibilityId='||vRespId
                ||'&pFileId='||vFileId||'&pFirstTime=0&pMode=SONAR';
*/
    --jprabhud added enhancement#2184054
    if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
       vReportURL := FND_WEB_CONFIG.trail_slash(FND_WEB_CONFIG.WEB_SERVER)||
                    'OA_HTML/bisviewm.jsp?dbc=' || FND_WEB_CONFIG.DATABASE_ID
                  ||'&regionCode='||BIS_PMV_UTIL.encode(p_region_code)||'&functionName='||BIS_PMV_UTIL.encode(p_function_name)
                  ||'&pSessionId='||vSessionId||'&pUserId='||vUserId||'&pResponsibilityId='||vRespId
                  ||'&fileId='||vFileId||'&pFirstTime=0&pMode=SONAR&nlsLangCode='||p_NlsLangCode;

       vHTMLPieces := utl_http.request_pieces(url        => vReportURL,
                                           max_pieces => 32000);
       --ksadagop BugFix#3635714
       --msaran:4589071 - eliminate mod_plsql
--       vURL := fnd_Web_config.trail_slash(fnd_web_Config.gfm_Agent)||'bis_save_report.retrieve_for_php?file_id='||icx_call.encrypt(vFileId);
       vURL := fnd_Web_config.trail_slash(fnd_web_Config.jsp_agent)||'bissched.jsp?pStream=Y&file_id='||icx_call.encrypt(vFileId);
    else
       vURL := NULL;
    end if;

  --jprabhud added exception block enhancement#2184054
  EXCEPTION WHEN OTHERS THEN
     vURL := NULL;
  END;

  end if;

  RETURN vURL;
END GET_NOTIFY_RPT_URL;


PROCEDURE GET_NOTIFY_RPT_RUN_URL(
 p_measure_id                  IN   VARCHAR2
,p_region_code                 in   varchar2 default null
,p_function_name               in   varchar2 default null
,p_bplan_name                  IN   VARCHAR2 default null
,p_viewby_level_short_name     IN   VARCHAR2 default null
,p_Parm1Level_short_name  IN   VARCHAR2 default null
,p_Parm1Value_name  IN   VARCHAR2 default null
,p_Parm2Level_short_name  IN   VARCHAR2 default null
,p_Parm2Value_name  IN   VARCHAR2 default null
,p_Parm3Level_short_name  IN   VARCHAR2 default null
,p_Parm3Value_name  IN   VARCHAR2 default null
,p_Parm4Level_short_name  IN   VARCHAR2 default null
,p_Parm4Value_name  IN   VARCHAR2 default null
,p_Parm5Level_short_name  IN   VARCHAR2 default null
,p_Parm5Value_name  IN   VARCHAR2 default null
,p_Parm6Level_short_name  IN   VARCHAR2 default null
,p_Parm6Value_name  IN   VARCHAR2 default null
,p_Parm7Level_short_name  IN   VARCHAR2 default null
,p_Parm7Value_name  IN   VARCHAR2 default null
,p_Parm8Level_short_name  IN   VARCHAR2 default null
,p_Parm8Value_name  IN   VARCHAR2 default null
,p_Parm9Level_short_name  IN   VARCHAR2 default null
,p_Parm9Value_name  IN   VARCHAR2 default null
,p_Parm10Level_short_name IN   VARCHAR2 default null
,p_Parm10Value_name IN   VARCHAR2 default null
,p_Parm11Level_short_name IN   VARCHAR2 default null
,p_Parm11Value_name IN   VARCHAR2 default null
,p_Parm12Level_short_name IN   VARCHAR2 default null
,p_Parm12Value_name IN   VARCHAR2 default null
,p_Parm13Level_short_name IN   VARCHAR2 default null
,p_Parm13Value_name IN   VARCHAR2 default null
,p_TimeParmLevel_short_name in varchar2 default null
,p_TimeFromParmValue_name in varchar2 default null
,p_TimeToParmValue_name in varchar2 default null
,p_resp_id in varchar2 default null
,p_UserId IN VARCHAR2 default null
,p_NlsLangCode IN VARCHAR2 default null
--msaran:4415814 - added out params from fileId and reportURL
,vFileId OUT NOCOPY NUMBER
,vReportURL OUT NOCOPY VARCHAR2
)
IS
   --jprabhud defaulted to NULL enhancement#2184054
   vURL varchar2(2000) := NULL;
--   vFileId number := 0;
   vSessionId varchar2(32000);
   --vUserId varchar2(20) := 'Notification';  --Bug Fix 2165959
   --vRespId varchar2(10) := 'NULL';
   --jprabhud - 5/26/2004 - BugFix 3649405  for SONAR
   --vUserId varchar2(20) := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
   --vRespId varchar2(10) := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
   vUserId varchar2(20);
   vRespId varchar2(10);
   vNotifId varchar2 (32000);

   vParameter1          varchar2(100);
   vParameter2          varchar2(100);
   vParameter3          varchar2(100);
   vParameter4          varchar2(100);
   vParameter5          varchar2(100);
   vParameter6          varchar2(100);
   vParameter7          varchar2(100);
   vParameter8          varchar2(100);
   vParameter9          varchar2(100);
   vParameter10          varchar2(100);
   vParameter11          varchar2(100);
   vParameter12          varchar2(100);
   vParameter13          varchar2(100);
   vParameter14          varchar2(100);
   vParameter15          varchar2(100);

   vParm14Value_name    varchar2(100);
   vParm15Value_name    varchar2(100);

   vTimeParameter       VARCHAR2(100);
   vTimeFromParameter   VARCHAR2(100);
   vTimeToParameter     VARCHAR2(100);

   vReturnStatus        varchar2(2000);
   vMsgData             varchar2(2000);
   vMsgCount            number;

--   vReportURL           varchar2(2000);
--   vHTMLPieces          utl_http.html_pieces;


   --jprabhud added for enhancement#2184054
   l_err           varchar2(2000);
   l_return_status  varchar2(1) := FND_API.G_RET_STS_SUCCESS;

   l_nested_region_code varchar2(100);

   lAsOfDateValue varchar2(100);


   ---jprabhud added Cursor, also added VIEWBY PARAMETER in where clause for enhancement#2184054

   CURSOR c_dimlvl(p_search_string IN VARCHAR2, p_view_by_level IN VARCHAR2 ) IS
      select attribute2
      FROM ak_region_items ak
      where ak.region_code = p_region_code
      AND ak.attribute1 in (G_DIMENSION_LEVEL, G_DIM_LEVEL_SINGLE_VALUE,G_VIEWBY_PARAMETER)
      AND    substr(ak.attribute2, instr(ak.attribute2, '+')+1)
      = nvl(p_view_by_level, substr(ak.attribute2, instr(ak.attribute2, '+')+1))
      AND    substr(ak.attribute2, 1,instr(ak.attribute2, '+')-1)
      like nvl(p_search_string, substr(ak.attribute2, 1,instr(ak.attribute2, '+')-1))
      order by  display_sequence;
   --BugFix 3280466
   CURSOR get_nested_region IS
      select nested_region_code from ak_region_items
      where region_code = p_region_code
      and nested_region_code is not null;


BEGIN

  vFileId := 0;

  --jprabhud - 5/26/2004 - BugFix 3649405  for SONAR
  /*
  --BugFix 2833251 Added p_resp_id
  if (p_resp_id is not null) then
     vRespId := p_resp_id;
  end if;
  -- rcmuthuk BugFix:2810397 added p_UserId
  if (p_UserId is not null) then
     vUserId := p_UserId;
  end if;
  */

  --BugFix 3280466
  open get_nested_region;
  fetch get_nested_region into l_nested_region_code;
  close get_nested_region;


  if p_region_code is not null and p_function_name is not null then
  --jprabhud added BEGIN enhancement#2184054
  BEGIN
    IF ( p_parm1Level_short_name IS NOT NULL) THEN
    begin
     --BugFix 3280466 Changed all the sqls to also check from Nested Region
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter1
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm1Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm1Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm1Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm1Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm1Level_short_name);
    end;
    END IF;

    IF ( p_parm2Level_short_name IS NOT NULL) THEN
    begin

      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter2
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm2Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm2Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm2Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm2Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm2Level_short_name);
    end;

    END IF;

    IF ( p_parm3Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter3
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm3Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm3Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm3Value_name;
      END IF;

    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm3Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm3Level_short_name);
    end;

    END IF;

    IF ( p_parm4Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter4
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm4Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm4Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm4Value_name;
      END IF;
    exception
       --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm4Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm4Level_short_name);
    end;

    END IF;

    IF ( p_parm5Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter5
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm5Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm5Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm5Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm5Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm5Level_short_name);
    end;

    END IF;

    IF ( p_parm6Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter6
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm6Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm6Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm6Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm6Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm6Level_short_name);
    end;

    END IF;

    IF ( p_parm7Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter7
      from   ak_region_items_vl AK
      where  ak.region_code = p_region_code
      AND    substr(ak.attribute2, instr(ak.attribute2, '+')+1) = p_parm7Level_short_name
      AND    ak.node_query_flag = 'Y';
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm7Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm7Level_short_name);
    end;

    END IF;

    IF ( p_parm8Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter8
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm8Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm8Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm8Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm8Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm8Level_short_name);
    end;

    END IF;

    IF ( p_parm9Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter9
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm9Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm9Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm9Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm9Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm9Level_short_name);
    end;

    END IF;

    IF ( p_parm10Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter10
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm10Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm10Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm10Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm10Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm10Level_short_name);
    end;

    END IF;

    IF ( p_parm11Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter11
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm11Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm11Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm11Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm11Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm11Level_short_name);
    end;

    END IF;

    IF ( p_parm12Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter12
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm12Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm12Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm12Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm12Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm12Level_short_name);
    end;

    END IF;

    IF ( p_parm13Level_short_name IS NOT NULL) THEN
    begin
      select DISTINCT nvl(attribute2,attribute_code)
      into   vParameter13
      from   ak_region_items_vl AK
      where  ak.region_code in ( p_region_code, l_nested_region_code)
      AND    nvl(substr(ak.attribute2, instr(ak.attribute2, '+')+1), attribute_code) = p_parm13Level_short_name
      AND    ak.node_query_flag = 'Y';
      IF ( p_parm13Level_short_name ='AS_OF_DATE') THEN
        lAsOfDateValue := p_Parm13Value_name;
      END IF;
    exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_parm13Level_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_parm13Level_short_name);
    end;

    END IF;

   IF (p_bplan_name IS NOT NULL) THEN
      vParameter14:='BUSINESS_PLAN';
      vParm14Value_name:= p_bplan_name;
   END IF;
/*
   IF (p_viewby_level_short_name IS NOT NULL) THEN

      vParameter15 := 'VIEW_BY';
    begin
      Select attribute2
      into   vParm15Value_name
      from   ak_region_items_vl AK
      where  ak.region_code = p_region_code
      AND    substr(ak.attribute2, instr(ak.attribute2, '+')+1) = p_viewby_level_short_name
      AND    ak.attribute1 in ('DIMENSION LEVEL', 'DIM LEVEL SINGLE VALUE');
    exception
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_viewby_level_short_name ||' does not match the level short name defined in AK.');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_viewby_level_short_name);
    end;

   END IF;
*/

   --jprabhud enhancement#2184054*/
   IF (p_viewby_level_short_name IS NOT NULL) THEN
   begin
     if c_dimlvl%ISOPEN then
        CLOSE c_dimlvl;
     end if;
     vParameter15 := 'VIEW_BY';
     if(BIS_UTILITIES_PVT.is_total_dimlevel(p_viewby_level_short_name,l_err)  = FALSE)
     then
        OPEN c_dimlvl(NULL, p_viewby_level_short_name);
        FETCH c_dimlvl INTO vParm15Value_name ;
        if c_dimlvl%NOTFOUND then
            CLOSE c_dimlvl;
            RAISE NO_DATA_FOUND;
        end if;
        CLOSE c_dimlvl;
    else
        if(p_TimeParmLevel_short_name IS NOT NULL)
        then
           OPEN c_dimlvl('%TIME%', NULL);
           LOOP
           FETCH c_dimlvl INTO vParm15Value_name ;
           if c_dimlvl%NOTFOUND then
               CLOSE c_dimlvl;
               RAISE NO_DATA_FOUND;
           end if;
           EXIT WHEN BIS_UTILITIES_PVT.is_total_dimlevel(substr(vParm15Value_name,
                     instr(vParm15Value_name, '+')+1),l_err) = FALSE;
           END LOOP;
           CLOSE c_dimlvl;
        else
           OPEN c_dimlvl(NULL, NULL);
           LOOP
           FETCH c_dimlvl INTO vParm15Value_name ;
           if c_dimlvl%NOTFOUND then
               CLOSE c_dimlvl;
               RAISE NO_DATA_FOUND;
           end if;
           EXIT WHEN BIS_UTILITIES_PVT.is_total_dimlevel(substr(vParm15Value_name,
                     instr(vParm15Value_name, '+')+1),l_err) = FALSE;
           END LOOP;
           CLOSE c_dimlvl;
        end if;
    end if;
    EXCEPTION
    --jprabhud added l_return_status enhancement#2184054
    WHEN NO_DATA_FOUND then
        l_return_status := FND_API.G_RET_STS_ERROR;
        htp.print(p_viewby_level_short_name ||' does not match the level short name defined in AK .');
    WHEN  others then
        l_return_status := FND_API.G_RET_STS_ERROR;
        htp.print('cannot obtain correct info for level short name: '||p_viewby_level_short_name);
end;
END IF;

   IF (p_TimeParmLevel_short_name IS NOT NULL) THEN

      IF (p_TimeFromparmValue_name IS NOT NULL) THEN
      begin
          Select nvl(attribute2,attribute_code)
          into   vTimeParameter
          from   ak_region_items_vl AK
          where  ak.region_code = p_region_code
          AND    substr(ak.attribute2, instr(ak.attribute2, '+')+1) = p_TimeparmLevel_short_name
          AND    ak.attribute1 in ('DIMENSION LEVEL', 'DIM LEVEL SINGLE VALUE', 'HIDE VIEW BY DIMENSION');
      exception
        --jprabhud added l_return_status for enhancement#2184054
        when NO_DATA_FOUND then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print(p_TimeparmLevel_short_name ||' does not match the level short name defined in AK .');
        when others then
            l_return_status := FND_API.G_RET_STS_ERROR;
            htp.print('cannot obtain correct info for level short name: '||p_TimeparmLevel_short_name);
      end;

          vTimeFromParameter := p_TimeFromparmValue_name;
     END IF;

     IF (p_TimetoparmValue_name IS NOT NULL) THEN
          vTimeToParameter := p_TimeToparmValue_name;
     END IF;
     --BugFix 3280466
     IF (lAsOfDateValue is not null and l_nested_region_code is not null ) THEN
          vTimeFromParameter := 'DBC_TIME';
          vTimeToParameter := 'DBC_TIME';
     END IF;
   END IF;

   --Create an entry in FND_LOBs and get the corresponding file id
   vFileId := BIS_SAVE_REPORT.createEntry('BIS Notification', 'text/html', null, null);

   --jprabhud - 5/26/2004 - BugFix 3649405  for SONAR
   --select 'Notice_'||bis_notification_id_s.nextval into vSessionId from dual;
   select bis_notification_id_s.nextval into vNotifId from dual;
   vSessionId := 'Notice_'|| vNotifId;

   --BugFix 2833251 Added p_resp_id
    if (p_resp_id is not null) then
      vRespId := p_resp_id;
    else
      begin
        vRespId := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
      exception
        when others then
          vRespId := vNotifId;
      end;
    end if;
    -- rcmuthuk BugFix:2810397 added p_UserId
    if (p_UserId is not null) then
      vUserId := p_UserId;
    else
      begin
        vUserId := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
      exception
        when others then
           vUserId := vNotifId;
      end;
    end if;

   BIS_PMV_PARAMETERS_PVT.saveParameters
   (pRegionCode       => p_region_code,
    pFunctionName     => p_function_name,
    pSessionId        => vSessionId,
    pUserId           => vUserId,
    pResponsibilityId => vRespId,
    pParameter1       => vParameter1,
    pParameterValue1  => p_Parm1Value_name,
    pParameter2       => vParameter2,
    pParameterValue2  => p_Parm2Value_name,
    pParameter3       => vParameter3,
    pParameterValue3  => p_Parm3Value_name,
    pParameter4       => vParameter4,
    pParameterValue4  => p_Parm4Value_name,
    pParameter5       => vParameter5,
    pParameterValue5  => p_Parm5Value_name,
    pParameter6       => vParameter6,
    pParameterValue6  => p_Parm6Value_name,
    pParameter7       => vParameter7,
    pParameterValue7  => p_Parm7Value_name,
    pParameter8       => vParameter8,
    pParameterValue8  => p_Parm8Value_name,
    pParameter9       => vParameter9,
    pParameterValue9  => p_Parm9Value_name,
    pParameter10      => vParameter10,
    pParameterValue10 => p_Parm10Value_name,
    pParameter11      => vParameter11,
    pParameterValue11 => p_Parm11Value_name,
    pParameter12      => vParameter12,
    pParameterValue12 => p_Parm12Value_name,
    pParameter13      => vParameter13,
    pParameterValue13 => p_Parm13Value_name,
    pParameter14      => vParameter14,
    pParameterValue14 => vParm14Value_name,
    pTimeParameter    => vTimeParameter,
    pTimeFromParameter=> vTimeFromParameter,
    pTimeToParameter  => vTimeToParameter,
    pViewByValue      => vParm15Value_name,
    pAddToDefault     => 'N',
    pAsOfDateValue    => lAsOfDateValue,
    pAsOfDateMode     => 'CURRENT',
    x_return_status   => vReturnStatus,
    x_msg_count	      => vMsgCount,
    x_msg_data        => vMsgData
    );

   --jprabhud added enhancement#2184054
    if(l_return_status <> FND_API.G_RET_STS_ERROR) then
       l_return_status := nvl(vReturnStatus,FND_API.G_RET_STS_SUCCESS);
    end if;


    --jprabhud added enhancement#2184054
    if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
       vReportURL := FND_WEB_CONFIG.trail_slash(FND_WEB_CONFIG.WEB_SERVER)||
                    'OA_HTML/bisviewm.jsp?dbc=' || FND_WEB_CONFIG.DATABASE_ID
                  ||'&regionCode='||BIS_PMV_UTIL.encode(p_region_code)||'&functionName='||BIS_PMV_UTIL.encode(p_function_name)
                  ||'&pSessionId='||vSessionId||'&pUserId='||vUserId||'&pResponsibilityId='||vRespId
                  ||'&fileId='||vFileId||'&pFirstTime=0&pMode=SONAR&nlsLangCode='||p_NlsLangCode;

    else
      vReportURL := NULL;
    end if;

  --jprabhud added exception block enhancement#2184054
  EXCEPTION WHEN OTHERS THEN
     vReportURL := NULL;
  END;

  end if;

END GET_NOTIFY_RPT_RUN_URL;



--serao -02/10/02 - added for performance of the get_targe, to be owned by the pmf team later
PROCEDURE GET_TARGET_RANGE
(pSource		IN      VARCHAR2
,pSessionId		IN	VARCHAR2
,pRegionCode		IN	VARCHAR2
,pFunctionName		IN	VARCHAR2
,pMeasureShortName 	IN	VARCHAR2	DEFAULT NULL
,pPlanId		IN	VARCHAR2	DEFAULT NULL
,pTarget_level_id IN NUMBER DEFAULT NULL
,pDimension1		IN	VARCHAR2	DEFAULT NULL
,pDim1Level		IN      VARCHAR2	DEFAULT NULL
,pDim1LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension2		IN	VARCHAR2	DEFAULT NULL
,pDim2Level		IN      VARCHAR2	DEFAULT NULL
,pDim2LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension3		IN	VARCHAR2	DEFAULT NULL
,pDim3Level		IN      VARCHAR2	DEFAULT NULL
,pDim3LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension4		IN	VARCHAR2	DEFAULT NULL
,pDim4Level		IN      VARCHAR2	DEFAULT NULL
,pDim4LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension5		IN	VARCHAR2	DEFAULT NULL
,pDim5Level		IN      VARCHAR2	DEFAULT NULL
,pDim5LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension6		IN	VARCHAR2	DEFAULT NULL
,pDim6Level		IN      VARCHAR2	DEFAULT NULL
,pDim6LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension7		IN	VARCHAR2	DEFAULT NULL
,pDim7Level		IN      VARCHAR2	DEFAULT NULL
,pDim7LevelValue	IN	VARCHAR2	DEFAULT NULL
,xTarget OUT NOCOPY VARCHAR2
,x_Range1_low OUT NOCOPY VARCHAR2
,x_Range1_high OUT NOCOPY VARCHAR2
) IS

  l_return_Status             VARCHAR2(32000);
  l_target_level_rec          BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_target_rec                BIS_TARGET_PUB.TARGET_REC_TYPE;
  l_target_rec_p              BIS_TARGET_PUB.TARGET_REC_TYPE;
  l_error_tbl                 BIS_UTILITIES_PUB.ERROR_TBL_TYPE;
  l_range1_low                varchar2(200);
  l_range1_high               varchar2(200);
  l_target		      VARCHAR2(32000);

-- pvt retrieve------------------------------

l_bisfv_targets_rec       bisfv_targets%ROWTYPE;
l_bisbv_target_levels_rec bisbv_target_levels%ROWTYPE;
l_plan_id NUMBER;
l_Business_Plan_Rec BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type;
l_Business_Plan_Rec_p BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type;
l_org_level_value_id VARCHAR2(250);
l_time_level_value_id VARCHAR2(250);

----------------
lcomputing_function_id NUMBER;
lTarget VARCHAR2(1000);

BEGIN

  l_target_rec.plan_id := pPlanId;
  l_target_rec.target_level_id := pTarget_level_id;
  -- the calculation using the short name has been done in order_dimensions
  l_target_rec.dim1_level_Value_id := pDim1LevelValue;
  l_target_rec.dim2_level_Value_id := pDim2LevelValue;
  l_target_rec.dim3_level_Value_id := pDim3LevelValue;
  l_target_rec.dim4_level_Value_id := pDim4LevelValue;
  l_target_rec.dim5_level_Value_id := pDim5LevelValue;
  l_target_rec.dim6_level_Value_id := pDim6LevelValue;
  l_target_rec.dim7_level_Value_id := pDim7LevelValue;

---- from retrieve_target_pub----------------------
  -- do value - id conversions
  l_target_rec_p := l_target_rec;
  --BugFix 2762795
  BIS_TARGET_PVT.Value_ID_Conversion
                 ( p_api_version   => 1.0
                 , p_Target_Rec    => l_Target_Rec_p
                 , x_Target_Rec    => l_Target_Rec
                 , x_return_status => l_return_status
                 , x_error_Tbl     => l_error_Tbl
                 );


 --Resequence the dimensions. This is for backward compatibility for product teams
   l_target_rec_p := l_target_rec;
   BIS_UTILITIES_PVT.resequence_dim_level_values
                 (l_target_rec_p
		  ,'N'
		 ,l_target_rec
		 ,l_Error_tbl
		);

-- from retrieve_target_pvt---------------------------------------------

  IF( BIS_UTILITIES_PUB.Value_Not_Missing(l_Target_Rec.Target_ID)
      = FND_API.G_TRUE
      AND l_Target_Rec.Target_ID IS NOT NULL
    ) THEN
    SELECT *
    INTO l_bisfv_targets_rec
    FROM bisfv_targets bisfv_targets
    WHERE bisfv_targets.TARGET_ID = l_Target_Rec.Target_ID;


  ELSIF( BIS_UTILITIES_PUB.Value_Not_Missing(l_Target_Rec.Target_Level_ID)
         = FND_API.G_TRUE
         AND l_Target_Rec.Target_Level_ID IS NOT NULL
       ) THEN
    SELECT *
    INTO l_bisbv_target_levels_rec
    FROM bisbv_target_levels bisbv_target_levels
    WHERE bisbv_target_levels.TARGET_LEVEL_ID
          = l_Target_Rec.Target_Level_ID;

     ---If Plan Id is not given, get Plan Id from Short name

     if (BIS_UTILITIES_PUB.Value_Missing(l_Target_Rec.Plan_ID)
                                          = FND_API.G_TRUE) then
        if (BIS_UTILITIES_PUB.Value_Not_Missing(l_Target_Rec.Plan_Short_Name)
                                          = FND_API.G_TRUE) then
             l_Business_Plan_Rec.Business_Plan_Short_Name := l_Target_Rec.Plan_Short_Name;
             l_Business_Plan_Rec_p := l_Business_Plan_Rec;
             -- BugFix 2762795
             BIS_BUSINESS_PLAN_PVT.Value_ID_Conversion
             ( p_api_version       => 1.0
             , p_Business_Plan_Rec => l_Business_Plan_Rec_p
             , x_Business_Plan_Rec => l_Business_Plan_Rec
             , x_return_status     => l_return_status
             , x_error_Tbl         => l_error_tbl
             );
             if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
                l_plan_id := l_Business_Plan_Rec.Business_Plan_ID;
             end if;
        end if;
     else
        l_plan_id :=   l_Target_Rec.Plan_ID ;
     end if;

     if(BIS_UTILITIES_PUB.Value_Missing(l_Target_Rec.Org_Level_Value_ID) = FND_API.G_TRUE)
       then l_org_level_value_id := NULL;
     else
       l_org_level_value_id := l_Target_Rec.Org_Level_Value_ID;
     end if;


     if(BIS_UTILITIES_PUB.Value_Missing(l_Target_Rec.Time_Level_Value_ID) = FND_API.G_TRUE)
       then l_time_level_value_id := NULL;
     else
         l_time_level_value_id := l_Target_Rec.Time_Level_Value_ID;
     end if;
    --------------------------------------------

    SELECT *
    INTO l_bisfv_targets_rec
    FROM bisfv_targets bisfv_targets
    WHERE bisfv_targets.TARGET_LEVEL_ID  = pTarget_Level_ID
     -- used to be  p_Target_Rec.Plan_ID
      AND bisfv_targets.PLAN_ID             = l_plan_id

     ---changed org and time logic
      AND (l_org_level_value_id IS NULL
         OR NVL(bisfv_targets.ORG_LEVEL_VALUE_ID,'T')   = NVL(l_org_level_value_id, 'T'))

      AND (l_time_level_value_id IS NULL
         OR NVL(bisfv_targets.TIME_LEVEL_VALUE_ID,'T')   = NVL(l_time_level_value_id, 'T'))

      AND NVL(bisfv_targets.DIM1_LEVEL_VALUE_ID, 'T')
          = DECODE( l_Target_Rec.Dim1_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(l_Target_Rec.Dim1_Level_Value_ID, 'T')
                  )
      AND NVL(bisfv_targets.DIM2_LEVEL_VALUE_ID, 'T')
          = DECODE( l_Target_Rec.Dim2_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(l_Target_Rec.Dim2_Level_Value_ID, 'T')
                  )
      AND NVL(bisfv_targets.DIM3_LEVEL_VALUE_ID, 'T')
          = DECODE( l_Target_Rec.Dim3_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(l_Target_Rec.Dim3_Level_Value_ID, 'T')
                  )
      AND NVL(bisfv_targets.DIM4_LEVEL_VALUE_ID, 'T')
          = DECODE( l_Target_Rec.Dim4_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(l_Target_Rec.Dim4_Level_Value_ID, 'T')
                  )
      AND NVL(bisfv_targets.DIM5_LEVEL_VALUE_ID, 'T')
          = DECODE( l_Target_Rec.Dim5_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(l_Target_Rec.Dim5_Level_Value_ID, 'T')
                  )
      AND NVL(bisfv_targets.DIM6_LEVEL_VALUE_ID, 'T')
          = DECODE( l_Target_Rec.Dim6_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(l_Target_Rec.Dim6_Level_Value_ID, 'T')
                  )
      AND NVL(bisfv_targets.DIM7_LEVEL_VALUE_ID, 'T')
          = DECODE( l_Target_Rec.Dim7_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(l_Target_Rec.Dim7_Level_Value_ID, 'T')
                  )
      ;
  END IF;
   -----------------------------------------------------------------
  lTarget := l_bisfv_targets_rec.target;

  IF ((BIS_UTILITIES_PUB.Value_Missing(l_bisfv_targets_rec.Target) = FND_API.G_TRUE)
  OR (BIS_UTILITIES_PUB.Value_Null(l_bisfv_targets_rec.Target) = FND_API.G_TRUE))
  THEN
    IF ((BIS_UTILITIES_PUB.Value_Not_Missing
       (l_bisfv_targets_rec.target_level_ID) = FND_API.G_TRUE)
    AND (BIS_UTILITIES_PUB.Value_Not_Null
       (l_bisfv_targets_rec.target_level_ID) = FND_API.G_TRUE))
    THEN
      Select
	 COMPUTING_FUNCTION_ID
    into
  	lComputing_Function_Id
    from   bisbv_target_levels
    where target_level_ID =l_bisfv_targets_rec.Target_Level_ID;

    END IF;

    -- only compute target if found computing fn id
    --
    IF ((BIS_UTILITIES_PUB.Value_Not_Missing
       (l_Target_Level_Rec.COMPUTING_FUNCTION_ID) = FND_API.G_TRUE)
    AND (BIS_UTILITIES_PUB.Value_Not_Null
       (l_Target_Level_Rec.COMPUTING_FUNCTION_ID) = FND_API.G_TRUE))
    THEN
	  l_Target_Rec.Target_ID             := l_bisfv_targets_rec.Target_ID;
	  l_Target_Rec.Target_Level_ID    := l_bisfv_targets_rec.Target_Level_ID;
	  l_Target_Rec.Target_Level_Short_Name
                    := l_bisfv_targets_rec.Target_Level_Short_Name;
	  l_Target_Rec.Target_Level_Name
                    := l_bisfv_targets_rec.Target_Level_Name;
	  l_Target_Rec.Plan_ID               := l_bisfv_targets_rec.Plan_ID;
	  l_Target_Rec.Plan_Short_Name       := l_bisfv_targets_rec.Plan_Short_Name;
	  l_Target_Rec.Plan_Name             := l_bisfv_targets_rec.Plan_Name;
	  l_Target_Rec.Org_Level_Value_ID
                    := l_bisfv_targets_rec.Org_Level_Value_ID;
	  l_Target_Rec.Time_Level_Value_ID
                    := l_bisfv_targets_rec.Time_Level_Value_ID;
	  l_Target_Rec.Dim1_Level_Value_ID
                    := l_bisfv_targets_rec.Dim1_Level_Value_ID;
	  l_Target_Rec.Dim2_Level_Value_ID
                    := l_bisfv_targets_rec.Dim2_Level_Value_ID;
	  l_Target_Rec.Dim3_Level_Value_ID
                    := l_bisfv_targets_rec.Dim3_Level_Value_ID;
	  l_Target_Rec.Dim4_Level_Value_ID
                    := l_bisfv_targets_rec.Dim4_Level_Value_ID;
	  l_Target_Rec.Dim5_Level_Value_ID
                    := l_bisfv_targets_rec.Dim5_Level_Value_ID;
	  l_Target_Rec.Dim6_Level_Value_ID
                    := l_bisfv_targets_rec.Dim6_Level_Value_ID;
	  l_Target_Rec.Dim7_Level_Value_ID
                    := l_bisfv_targets_rec.Dim7_Level_Value_ID;
	  l_Target_Rec.Target                := l_bisfv_targets_rec.Target;
	  l_Target_Rec.Range1_low            := l_bisfv_targets_rec.Range1_low;
	  l_Target_Rec.Range1_high           := l_bisfv_targets_rec.Range1_high;
	  l_Target_Rec.Range2_low            := l_bisfv_targets_rec.Range2_low;
	  l_Target_Rec.Range2_high           := l_bisfv_targets_rec.Range2_high;
	  l_Target_Rec.Range3_low            := l_bisfv_targets_rec.Range3_low;
	  l_Target_Rec.Range3_high           := l_bisfv_targets_rec.Range3_high;
	  l_Target_Rec.Notify_Resp1_ID       := l_bisfv_targets_rec.Notify_Resp1_ID;
	  l_Target_Rec.Notify_Resp1_Short_Name
                      := l_bisfv_targets_rec.Notify_Resp1_Short_Name;
	  l_Target_Rec.Notify_Resp1_Name     := l_bisfv_targets_rec.Notify_Resp1_Name;
	  l_Target_Rec.Notify_Resp2_ID       := l_bisfv_targets_rec.Notify_Resp2_ID;
	  l_Target_Rec.Notify_Resp2_Short_Name
                      := l_bisfv_targets_rec.Notify_Resp2_Short_Name;
	  l_Target_Rec.Notify_Resp2_Name     := l_bisfv_targets_rec.Notify_Resp2_Name;
	  l_Target_Rec.Notify_Resp3_ID       := l_bisfv_targets_rec.Notify_Resp3_ID;
	  l_Target_Rec.Notify_Resp3_Short_Name
        	              := l_bisfv_targets_rec.Notify_Resp3_Short_Name;
	  l_Target_Rec.Notify_Resp3_Name     := l_bisfv_targets_rec.Notify_Resp3_Name;

      lTarget :=
        BIS_TARGET_PVT.Get_Target
        ( p_computing_function_id => lcomputing_function_id
        , p_target_rec            => l_target_rec
        );
    END IF;
  END IF;


	xTarget := lTarget;
      x_range1_low := l_bisfv_targets_rec.Range1_low;
      x_range1_high := l_bisfv_targets_rec.Range1_high;
      if (l_bisfv_targets_rec.Target_ID is null) or (l_bisfv_targets_rec.Target_ID = FND_API.G_MISS_NUM) then
         xTarget := 'NONE';
	   x_range1_low := 'NONE';
         x_Range1_high := 'NONE';
      else
         if (x_range1_low = FND_API.G_MISS_NUM) or (x_range1_low is null) then
            x_range1_low := 'NONE';
         end if;
         if (x_range1_high = FND_API.G_MISS_NUM) or (x_range1_high is null)  then
            x_range1_high := 'NONE';
         end if;
      end if;

EXCEPTION
	WHEN OTHERS THEN
		xTarget := 'NONE';
		x_range1_low := 'NONE';
            x_Range1_high := 'NONE';
END GET_TARGET_RANGE;


--serao -02/10/02 - added for performance of the get_target
FUNCTION GET_TARGET_NEW
(pSource		IN      VARCHAR2
,pSessionId		IN	VARCHAR2
,pRegionCode		IN	VARCHAR2
,pFunctionName		IN	VARCHAR2
,pMeasureShortName 	IN	VARCHAR2	DEFAULT NULL
,pPlanId		IN	VARCHAR2	DEFAULT NULL
,pTarget_level_id IN NUMBER DEFAULT NULL
,pDimension1		IN	VARCHAR2	DEFAULT NULL
,pDim1Level		IN      VARCHAR2	DEFAULT NULL
,pDim1LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension2		IN	VARCHAR2	DEFAULT NULL
,pDim2Level		IN      VARCHAR2	DEFAULT NULL
,pDim2LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension3		IN	VARCHAR2	DEFAULT NULL
,pDim3Level		IN      VARCHAR2	DEFAULT NULL
,pDim3LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension4		IN	VARCHAR2	DEFAULT NULL
,pDim4Level		IN      VARCHAR2	DEFAULT NULL
,pDim4LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension5		IN	VARCHAR2	DEFAULT NULL
,pDim5Level		IN      VARCHAR2	DEFAULT NULL
,pDim5LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension6		IN	VARCHAR2	DEFAULT NULL
,pDim6Level		IN      VARCHAR2	DEFAULT NULL
,pDim6LevelValue	IN	VARCHAR2	DEFAULT NULL
,pDimension7		IN	VARCHAR2	DEFAULT NULL
,pDim7Level		IN      VARCHAR2	DEFAULT NULL
,pDim7LevelValue	IN	VARCHAR2	DEFAULT NULL
) RETURN VARCHAR2
IS
  l_target_url 		      VARCHAR2(32000);
  lTarget VARCHAR2(2000);
  l_range1_low                varchar2(200);
  l_range1_high               varchar2(200);

BEGIN
  get_target_range(
	 pSource
	,pSessionId
	,pRegionCode
	,pFunctionName
	,pMeasureShortName
	,pPlanId
	,pTarget_level_id
	,pDimension1
	,pDim1Level
	,pDim1LevelValue
	,pDimension2
	,pDim2Level
	,pDim2LevelValue
	,pDimension3
	,pDim3Level
	,pDim3LevelValue
	,pDimension4
	,pDim4Level
	,pDim4LevelValue
	,pDimension5
	,pDim5Level
	,pDim5LevelValue
	,pDimension6
	,pDim6Level
	,pDim6LevelValue
	,pDimension7
	,pDim7Level
	,pDim7LevelValue
	,lTarget
	,l_range1_low
	,l_range1_high  );

  l_Target_url :=  FND_WEB_CONFIG.trail_slash(FND_WEB_CONFIG.WEB_SERVER)||
                   'OA_HTML/bistared.jsp?dbc=' || FND_WEB_CONFIG.DATABASE_ID
                   ||'&sessionid='||pSessionId
                   ||'&RegionCode='||bis_pmv_util.encode(pRegionCode)
                   ||'&FunctionName='||bis_pmv_util.encode(pFunctionName)
                   ||'&SortInfo='||bis_pmv_util.encode('Sortcolumn2Asc')
                   ||'&Measure='||pMeasureShortName||'&PlanId='||pPlanId
		   ||'&Dim1Level='|| BIS_PMV_UTIL.encode(pDim1Level)
		   ||'&Dim2Level='|| BIS_PMV_UTIL.encode(pDim2Level)
		   ||'&Dim3Level='|| BIS_PMV_UTIL.encode(pDim3Level)
		   ||'&Dim4Level='|| BIS_PMV_UTIL.encode(pDim4Level)
		   ||'&Dim5Level='|| BIS_PMV_UTIL.encode(pDim5Level)
		   ||'&Dim6Level='|| BIS_PMV_UTIL.encode(pDim6Level)
		   ||'&Dim7Level='|| BIS_PMV_UTIL.encode(pDim7Level)
		   ||'&Dim1LevelValue='||BIS_PMV_UTIL.encode(pDim1LevelValue)
		   ||'&Dim2LevelValue='||BIS_PMV_UTIL.encode(pDim2LevelValue)
		   ||'&Dim3LevelValue='||BIS_PMV_UTIL.encode(pDim3LevelValue)
		   ||'&Dim4LevelValue='||BIS_PMV_UTIL.encode(pDim4LevelValue)
		   ||'&Dim5LevelValue='||BIS_PMV_UTIL.encode(pDim5LevelValue)
		   ||'&Dim6LevelValue='||BIS_PMV_UTIL.encode(pDim6LevelValue)
		   ||'&Dim7LevelValue='||BIS_PMV_UTIL.encode(pDim7LevelValue);
   l_target_url := l_target_url||'*'||lTarget||'**'||l_range1_low||'***'||l_Range1_high;
   return l_target_url;

END GET_TARGET_NEW;

END BIS_PMV_PMF_PVT;

/
