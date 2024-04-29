--------------------------------------------------------
--  DDL for Package Body BISVIEWER_PMF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BISVIEWER_PMF" as
/* $Header: BISRGPMB.pls 115.24 2002/11/19 18:30:34 kiprabha noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
-----------------------------------------------------------------------------------
--  13-Nov-2000    aleung    change Dimension/Dimension Level separator from '.' --
--                           to '+'. Replace instr(attribute2, '.') with         --
--                           instr(attribute2, '+') throughout the code          --
--  12/01/2001     dmarkman  org and time are not mandatory(could be NULL)       --
--                           changed query in  Get_Target_For_Level and          --
--                           in  Get_Target_For_Level                            --
--  04/10/2001     aleung    add scheduleReport and getTargetParm                --
--  04/26/2001     aleung    add procedure getTotalDimValue and function         --
--                           getTotalDimLevelName                                --
--  05/01/2001     aleung    modified scheduleReport (add form func bisschcf.jsp)--
-----------------------------------------------------------------------------------

 gvAll   constant        varchar2(10) := fnd_message.get_string('BIS', 'ALL');

 Function Get_Target
   (pMeasureShortName     Varchar2,
    pDimension1Level      Varchar2 default NULL,
    pDimension2Level      Varchar2 default NULL,
    pDimension3Level      Varchar2 default NULL,
    pDimension4Level      Varchar2 default NULL,
    pDimension5Level      Varchar2 default NULL,
    pDimension6Level      Varchar2 default NULL,
    pDimension7Level      Varchar2 default NULL,

    pDimension1           Varchar2 default NULL,
    pDimension2           Varchar2 default NULL,
    pDimension3           Varchar2 default NULL,
    pDimension4           Varchar2 default NULL,
    pDimension5           Varchar2 default NULL,
    pDimension6           Varchar2 default NULL,
    pDimension7           Varchar2 default NULL,

    pDimension1LevelValue Varchar2 default NULL,
    pDimension2LevelValue Varchar2 default NULL,
    pDimension3LevelValue Varchar2 default NULL,
    pDimension4LevelValue Varchar2 default NULL,
    pDimension5LevelValue Varchar2 default NULL,
    pDimension6LevelValue Varchar2 default NULL,
    pDimension7LevelValue Varchar2 default NULL,

    pPlanId               Varchar2)
	Return VARCHAR2 is

    vTarget               VARCHAR2(1000);

  l_return_Status             VARCHAR2(32000);
  l_target_level_rec          BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_target_rec                BIS_TARGET_PUB.TARGET_REC_TYPE;
  l_error_tbl                 BIS_UTILITIES_PUB.ERROR_TBL_TYPE;
  v_range1_low                varchar2(200);
  v_range1_high               varchar2(200);

  Begin

  l_target_level_rec.measure_short_name := pMeasureShortName;
  l_target_level_rec.dimension1_level_short_name := pDimension1Level;
  l_target_level_rec.dimension2_level_short_name := pDimension2Level;
  l_target_level_rec.dimension3_level_short_name := pDimension3Level;
  l_target_level_rec.dimension4_level_short_name := pDimension4Level;
  l_target_level_rec.dimension5_level_short_name := pDimension5Level;
  l_target_level_rec.dimension6_level_short_name := pDimension6Level;
  l_target_level_rec.dimension7_level_short_name := pDimension7Level;
  l_target_rec.plan_id := pPlanId;
  l_target_rec.dim1_level_value_id := pDimension1LevelValue;
  l_target_rec.dim2_level_value_id := pDimension2LevelValue;
  l_target_rec.dim3_level_value_id := pDimension3LevelValue;
  l_target_rec.dim4_level_value_id := pDimension4LevelValue;
  l_target_rec.dim5_level_value_id := pDimension5LevelValue;
  l_target_rec.dim6_level_value_id := pDimension6LevelValue;
  l_target_rec.dim7_level_value_id := pDimension7LevelValue;

  BIS_TARGET_PUB.RETRIEVE_TARGET_FROM_SHNMS
  (p_api_version      => 1.0
  ,p_target_level_rec => l_target_level_rec
  ,p_Target_Rec       => l_target_rec
  ,x_Target_Level_Rec => l_target_level_rec
  ,x_Target_Rec       => l_target_rec
  ,x_return_status    => l_return_status
  ,x_error_Tbl        => l_error_tbl
  );
  IF (l_return_Status = FND_API.G_RET_STS_ERROR) THEN
      return null;
  else
      vTarget := l_target_rec.target;
      v_range1_low := l_target_rec.range1_low;
      v_range1_high := l_target_rec.range1_high;
      if (l_target_rec.target_id is null) or (l_target_rec.target_id = FND_API.G_MISS_NUM) then
         return null;
      else
         if v_range1_low = FND_API.G_MISS_NUM then
            v_range1_low := null;
         end if;
         if v_range1_high = FND_API.G_MISS_NUM then
            v_range1_high := null;
         end if;

         return 'T_' || vTarget || '_' || v_range1_low || '_' || v_range1_high;
      end if;
  end if;

End Get_Target;

FUNCTION Get_Target_For_Level
( p_MEASURE_SHORT_NAME     VARCHAR2
--, p_ORG_LEVEL              VARCHAR2
--, p_TIME_LEVEL             VARCHAR2
, p_DIMENSION1_LEVEL       VARCHAR2
, p_DIMENSION2_LEVEL       VARCHAR2
, p_DIMENSION3_LEVEL       VARCHAR2
, p_DIMENSION4_LEVEL       VARCHAR2
, p_DIMENSION5_LEVEL       VARCHAR2
, p_DIMENSION6_LEVEL       VARCHAR2
, p_DIMENSION7_LEVEL       VARCHAR2
--, p_ORG_LEVEL_VALUE        VARCHAR2
--, p_TIME_LEVEL_VALUE       VARCHAR2
, p_DIMENSION1_LEVEL_VALUE VARCHAR2
, p_DIMENSION2_LEVEL_VALUE VARCHAR2
, p_DIMENSION3_LEVEL_VALUE VARCHAR2
, p_DIMENSION4_LEVEL_VALUE VARCHAR2
, p_DIMENSION5_LEVEL_VALUE VARCHAR2
, p_DIMENSION6_LEVEL_VALUE VARCHAR2
, p_DIMENSION7_LEVEL_VALUE VARCHAR2
, p_PLAN                   VARCHAR2
) RETURN VARCHAR2 IS

l_target_level NUMBER ;
l_target       VARCHAR2(1000) ;

--l_ORG_LEVEL_ID              NUMBER;
--l_TIME_LEVEL_ID             NUMBER;
l_DIMENSION1_LEVEL_ID       NUMBER;
l_DIMENSION2_LEVEL_ID       NUMBER;
l_DIMENSION3_LEVEL_ID       NUMBER;
l_DIMENSION4_LEVEL_ID       NUMBER;
l_DIMENSION5_LEVEL_ID       NUMBER;
l_DIMENSION6_LEVEL_ID       NUMBER;
l_DIMENSION7_LEVEL_ID       NUMBER;

MEASURE_SHORT_NAME  varchar2(1000):= 'none';
MEASURE_NAME  varchar2(1000):= 'none';

l_Measure_Rec               BIS_MEASURE_PUB.Measure_Rec_Type;
l_Target_Level_Rec          BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_Rstatus                   varchar2(1);
l_Error_Tbl                 BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

--    l_ORG_LEVEL_ID        := Get_level_ID ( p_ORG_LEVEL );
--    l_TIME_LEVEL_ID       := Get_level_ID ( p_TIME_LEVEL );
    l_DIMENSION1_LEVEL_ID := Get_level_ID ( p_DIMENSION1_LEVEL );
    l_DIMENSION2_LEVEL_ID := Get_level_ID ( p_DIMENSION2_LEVEL );
    l_DIMENSION3_LEVEL_ID := Get_level_ID ( p_DIMENSION3_LEVEL );
    l_DIMENSION4_LEVEL_ID := Get_level_ID ( p_DIMENSION4_LEVEL );
    l_DIMENSION5_LEVEL_ID := Get_level_ID ( p_DIMENSION5_LEVEL );
    l_DIMENSION6_LEVEL_ID := Get_level_ID ( p_DIMENSION6_LEVEL );
    l_DIMENSION7_LEVEL_ID := Get_level_ID ( p_DIMENSION7_LEVEL );

-- Debugging messages start: --------------------------------------------------
/*

   --htp.print('<!-- l1l_ORG_LEVEL_ID :' || l_ORG_LEVEL_ID||'-->');
   --htp.print('<!-- l1l_TIME_LEVEL_ID :' ||  l_TIME_LEVEL_ID||'-->');
   htp.print('<!-- l1l_DIMENSION1_LEVEL_ID :' ||  l_DIMENSION1_LEVEL_ID||'-->'  );
   htp.print('<!-- l1l_DIMENSION2_LEVEL_ID :' ||  l_DIMENSION2_LEVEL_ID ||'-->');
   htp.print('<!-- l1l_DIMENSION3_LEVEL_ID :' ||  l_DIMENSION3_LEVEL_ID||'-->' );
   htp.print('<!-- l1l_DIMENSION4_LEVEL_ID  :' ||  l_DIMENSION4_LEVEL_ID ||'-->' );
   htp.print('<!-- l1l_DIMENSION5_LEVEL_ID :' ||  l_DIMENSION5_LEVEL_ID||'-->' );
   htp.print('<!-- l1l_DIMENSION6_LEVEL_ID  :' ||  l_DIMENSION6_LEVEL_ID ||'-->' );
   htp.print('<!-- l1l_DIMENSION7_LEVEL_ID :' ||  l_DIMENSION7_LEVEL_ID||'-->' );
   htp.print('<!-- p_MEASURE_SHORT_NAME: '||p_MEASURE_SHORT_NAME||'-->');

--*/
-- Debugging messages end --------------------------------------------------


-- dmarkman 07/20/2000 do 'select' on BISBV_TARGET_LEVELS instead of BIS_TARGET_LEVELS, BIS_INDICATORS
-- dmarkman 12/01/2001 org and time are not mandatory(could be NULL)
--/*
begin
     SELECT TARGET_LEVEL_ID,MEASURE_SHORT_NAME,MEASURE_NAME
      INTO l_target_level,MEASURE_SHORT_NAME,MEASURE_NAME
      FROM BISBV_TARGET_LEVELS L
         , BISBV_PERFORMANCE_MEASURES M
     WHERE M.MEASURE_ID          = L.MEASURE_ID
       AND M.MEASURE_SHORT_NAME  = p_MEASURE_SHORT_NAME
	      --AND ((l_ORG_LEVEL_ID IS NOT NULL
            --AND L.ORG_LEVEL_ID  = l_ORG_LEVEL_ID)
            --OR (l_ORG_LEVEL_ID IS NULL))
	   --AND ((l_TIME_LEVEL_ID IS NOT NULL
            --AND L.TIME_LEVEL_ID = l_TIME_LEVEL_ID)
            --OR (l_TIME_LEVEL_ID  IS NULL))
       AND ((l_DIMENSION1_LEVEL_ID IS NOT NULL
            AND L.DIMENSION1_LEVEL_ID = l_DIMENSION1_LEVEL_ID)
            OR (l_DIMENSION1_LEVEL_ID IS NULL))
       AND ((l_DIMENSION2_LEVEL_ID IS NOT NULL
            AND L.DIMENSION2_LEVEL_ID = l_DIMENSION2_LEVEL_ID)
            OR (l_DIMENSION2_LEVEL_ID IS NULL))
       AND ((l_DIMENSION3_LEVEL_ID IS NOT NULL
            AND L.DIMENSION3_LEVEL_ID = l_DIMENSION3_LEVEL_ID)
            OR (l_DIMENSION3_LEVEL_ID IS NULL))
       AND ((l_DIMENSION4_LEVEL_ID IS NOT NULL
            AND L.DIMENSION4_LEVEL_ID = l_DIMENSION4_LEVEL_ID)
            OR (l_DIMENSION4_LEVEL_ID IS NULL))
       AND ((l_DIMENSION5_LEVEL_ID IS NOT NULL
            AND L.DIMENSION5_LEVEL_ID = l_DIMENSION5_LEVEL_ID)
            OR (l_DIMENSION5_LEVEL_ID IS NULL))
       AND ((l_DIMENSION6_LEVEL_ID IS NOT NULL
            AND L.DIMENSION6_LEVEL_ID = l_DIMENSION6_LEVEL_ID)
            OR (l_DIMENSION6_LEVEL_ID IS NULL))
       AND ((l_DIMENSION7_LEVEL_ID IS NOT NULL
            AND L.DIMENSION7_LEVEL_ID = l_DIMENSION7_LEVEL_ID)
            OR (l_DIMENSION7_LEVEL_ID IS NULL));

exception when others then
          --htp.print('<!-- Cannot retrieve target level!!! -->');
          --htp.p('<!--'||SQLCODE||'-->');
          --htp.p('<!--'||SQLERRM||'-->');
          return null;
end;
--*/
--htp.print(' Get_Target_For_Level  after query flag');

/*
     l_Measure_Rec.Measure_Short_Name := p_MEASURE_SHORT_NAME;
     BIS_MEASURE_PUB.Retrieve_Measure(p_api_version => 1.0,
                                      p_Measure_Rec => l_Measure_Rec,
                                      p_all_info => FND_API.G_FALSE,
                                      x_Measure_Rec => l_Measure_Rec,
                                      x_return_status => l_Rstatus,
                                      x_error_Tbl => l_Error_Tbl);

  if l_Rstatus = FND_API.G_RET_STS_ERROR then
     htp.print('error1');
  else
     htp.print('m id: '||l_Measure_Rec.Measure_ID);
     l_Target_Level_Rec.Measure_ID := l_Measure_Rec.Measure_ID;
     l_Target_Level_Rec.Org_Level_ID := l_ORG_LEVEL_ID;
     l_Target_Level_Rec.Time_Level_ID := l_TIME_LEVEL_ID;
     l_Target_Level_Rec.Dimension1_Level_ID := l_DIMENSION1_LEVEL_ID;
     l_Target_Level_Rec.Dimension2_Level_ID := l_DIMENSION2_LEVEL_ID;
     l_Target_Level_Rec.Dimension3_Level_ID := l_DIMENSION3_LEVEL_ID;
     l_Target_Level_Rec.Dimension4_Level_ID := l_DIMENSION4_LEVEL_ID;
     l_Target_Level_Rec.Dimension5_Level_ID := l_DIMENSION5_LEVEL_ID;

     BIS_TARGET_LEVEL_PUB.Retrieve_Target_Level(p_api_version => 1.0,
                                    p_Target_Level_Rec => l_Target_Level_Rec,
                                    p_all_info => FND_API.G_FALSE,
                                    x_Target_Level_Rec => l_Target_Level_Rec,
                                    x_return_status => l_Rstatus,
                                    x_error_Tbl => l_Error_Tbl);
     if l_Rstatus = FND_API.G_RET_STS_ERROR then
        htp.print('error2');
     else

     l_target_level := l_Target_Level_Rec.Target_Level_ID;
     MEASURE_SHORT_NAME := l_Measure_Rec.Measure_Short_Name;
     MEASURE_NAME := l_Measure_Rec.Measure_Name;
     end if;
 end if;
*/

-- Debugging messages: --------------------------------------------------
/*
 htp.print('<!-- l_target_level: ' || l_target_level||'-->' );
 htp.print('<!-- MEASURE_SHORT_NAME: ' || MEASURE_SHORT_NAME||'-->' );
 htp.print('<!-- MEASURE_NAME: ' || MEASURE_NAME||'-->' );
--*/

    l_target := Get_Target_Value( l_TARGET_LEVEL
                                --, p_ORG_LEVEL_VALUE
                                --, p_TIME_LEVEL_VALUE
                                , p_DIMENSION1_LEVEL_VALUE
                                , p_DIMENSION2_LEVEL_VALUE
                                , p_DIMENSION3_LEVEL_VALUE
                                , p_DIMENSION4_LEVEL_VALUE
                                , p_DIMENSION5_LEVEL_VALUE
                                , p_DIMENSION6_LEVEL_VALUE
                                , p_DIMENSION7_LEVEL_VALUE
                                , p_PLAN
                                ) ;
    RETURN l_target ;

EXCEPTION

  WHEN OTHERS THEN
       RETURN NULL ;

END Get_Target_For_Level;

FUNCTION Get_Target_Value
( p_TARGET_LEVEL_ID        VARCHAR2
--, p_ORG_LEVEL_VALUE        VARCHAR2
--, p_TIME_LEVEL_VALUE       VARCHAR2
, p_DIMENSION1_LEVEL_VALUE VARCHAR2
, p_DIMENSION2_LEVEL_VALUE VARCHAR2
, p_DIMENSION3_LEVEL_VALUE VARCHAR2
, p_DIMENSION4_LEVEL_VALUE VARCHAR2
, p_DIMENSION5_LEVEL_VALUE VARCHAR2
, p_DIMENSION6_LEVEL_VALUE VARCHAR2
, p_DIMENSION7_LEVEL_VALUE VARCHAR2
, p_PLAN                   VARCHAR2
) RETURN VARCHAR2 IS

l_target    VARCHAR2(1000);
v_range1_low  VARCHAR2(1000);
v_range1_high VARCHAR2(1000);

vTargetRec     BIS_TARGET_PUB.Target_Rec_Type;
vRstatus       varchar2(1);
vErrorTbl      BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN


-- Debugging messages start: --------------------------------------------------
/*

htp.print('<!--  ACT p_TARGET_LEVEL_ID:' || p_TARGET_LEVEL_ID||'-->' );
--htp.print('<!--  ACT p_ORG_LEVEL_VALUE:' || p_ORG_LEVEL_VALUE||'-->'    );
--htp.print('<!--  ACT p_TIME_LEVEL_VALUE:' || p_TIME_LEVEL_VALUE||'-->'      );
htp.print('<!--  ACT p_DIMENSION1_LEVEL_VALUE:' || p_DIMENSION1_LEVEL_VALUE||'-->' );
htp.print('<!--  ACT p_DIMENSION2_LEVEL_VALUE:' || p_DIMENSION2_LEVEL_VALUE||'-->' );
htp.print('<!--  ACT p_DIMENSION3_LEVEL_VALUE:' || p_DIMENSION3_LEVEL_VALUE||'-->' );
htp.print('<!--  ACT p_DIMENSION4_LEVEL_VALUE:' || p_DIMENSION4_LEVEL_VALUE||'-->' );
htp.print('<!--  ACT p_DIMENSION5_LEVEL_VALUE:' || p_DIMENSION5_LEVEL_VALUE||'-->');
htp.print('<!--  ACT p_DIMENSION6_LEVEL_VALUE:' || p_DIMENSION6_LEVEL_VALUE||'-->' );
htp.print('<!--  ACT p_DIMENSION7_LEVEL_VALUE:' || p_DIMENSION7_LEVEL_VALUE||'-->');
htp.print('<!--  ACT p_PLAN:' || p_PLAN||'-->'                   );
--*/
-- Debugging messages end ----------------------------------------------------

-- dmarkman 07/20 do 'select' on BISBV_TARGETS instead of BIS_TRAGET_VALUES
-- dmarkman 12/01/2001 org and time are not mandatory(could be NULL)
 /*

   SELECT TARGET, range1_low, range1_high
    INTO l_target, v_range1_low, v_range1_high
    FROM BISBV_TARGETS
    WHERE TARGET_LEVEL_ID = P_TARGET_LEVEL_ID
    --AND (( P_ORG_LEVEL_VALUE IS NOT NULL
          --AND ORG_LEVEL_VALUE_ID = P_ORG_LEVEL_VALUE )
          --OR (P_ORG_LEVEL_VALUE IS NULL))
	--AND (( UPPER(TIME_LEVEL_VALUE_ID) IS NOT NULL
          --AND UPPER(TIME_LEVEL_VALUE_ID) = UPPER(p_TIME_LEVEL_VALUE) )
          --OR ( UPPER(TIME_LEVEL_VALUE_ID) IS NULL))
	AND ((p_DIMENSION1_LEVEL_VALUE IS NOT NULL
          AND DIM1_LEVEL_VALUE_ID = p_DIMENSION1_LEVEL_VALUE )
          OR (p_DIMENSION1_LEVEL_VALUE IS NULL))
    AND ((p_DIMENSION2_LEVEL_VALUE IS NOT NULL
          AND DIM2_LEVEL_VALUE_ID = p_DIMENSION2_LEVEL_VALUE )
          OR (p_DIMENSION2_LEVEL_VALUE IS NULL))
    AND ((p_DIMENSION3_LEVEL_VALUE IS NOT NULL
          AND DIM3_LEVEL_VALUE_ID = p_DIMENSION3_LEVEL_VALUE )
          OR (p_DIMENSION3_LEVEL_VALUE IS NULL))
    AND ((p_DIMENSION4_LEVEL_VALUE IS NOT NULL
          AND DIM4_LEVEL_VALUE_ID = p_DIMENSION4_LEVEL_VALUE )
          OR (p_DIMENSION4_LEVEL_VALUE IS NULL))
    AND ((p_DIMENSION5_LEVEL_VALUE IS NOT NULL
          AND DIM5_LEVEL_VALUE_ID = p_DIMENSION5_LEVEL_VALUE )
          OR (p_DIMENSION5_LEVEL_VALUE IS NULL))
    AND ((p_DIMENSION6_LEVEL_VALUE IS NOT NULL
          AND DIM6_LEVEL_VALUE_ID = p_DIMENSION6_LEVEL_VALUE )
          OR (p_DIMENSION6_LEVEL_VALUE IS NULL))
    AND ((p_DIMENSION7_LEVEL_VALUE IS NOT NULL
          AND DIM7_LEVEL_VALUE_ID = p_DIMENSION7_LEVEL_VALUE )
          OR (p_DIMENSION7_LEVEL_VALUE IS NULL))
    AND PLAN_ID = p_plan;

-- */
--/*
     -- aleung, 11/08/00, use API to access PMF table BISBV_TARGETS
     vTargetRec.Target_Level_ID := P_TARGET_LEVEL_ID;
     --vTargetRec.Org_level_value_id := P_ORG_LEVEL_VALUE;
     vTargetRec.Plan_ID := p_plan;
     --vTargetRec.Time_level_Value_id := p_TIME_LEVEL_VALUE;
     vTargetRec.Dim1_Level_Value_ID := p_DIMENSION1_LEVEL_VALUE;
     vTargetRec.Dim2_Level_Value_ID := p_DIMENSION2_LEVEL_VALUE;
     vTargetRec.Dim3_Level_Value_ID := p_DIMENSION3_LEVEL_VALUE;
     vTargetRec.Dim4_Level_Value_ID := p_DIMENSION4_LEVEL_VALUE;
     vTargetRec.Dim5_Level_Value_ID := p_DIMENSION5_LEVEL_VALUE;
     vTargetRec.Dim6_Level_Value_ID := p_DIMENSION6_LEVEL_VALUE;
     vTargetRec.Dim7_Level_Value_ID := p_DIMENSION7_LEVEL_VALUE;

     BIS_TARGET_PUB.Retrieve_Target(p_api_version => 1.0,
                                    p_Target_Rec => vTargetRec,
                                    p_all_info => FND_API.G_FALSE,
                                    x_Target_Rec => vTargetRec,
                                    x_return_status => vRstatus,
                                    x_error_Tbl => vErrorTbl);

     if vRstatus = FND_API.G_RET_STS_ERROR then
        return null;
     else
        l_target := vTargetRec.Target;
        v_range1_low := vTargetRec.Range1_low;
        v_range1_high := vTargetRec.Range1_high;
     end if;
--*/


 --htp.print('<!-- T_' || l_target || '_' || v_range1_low || '_' || v_range1_high||'-->');

return 'T_' || l_target || '_' || v_range1_low || '_' || v_range1_high;

EXCEPTION

  When others then
       return NULL;

end Get_Target_Value;


FUNCTION Get_LEVEL_ID ( p_Level_Short_Name IN VARCHAR2 ) RETURN NUMBER IS
l_level_id NUMBER ;
l_Level_Rec  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
l_Rstatus    varchar2(1);
l_Error_Tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;

Begin
    If p_Level_Short_Name IS NULL Then
          Return NULL ;
    Else

-- Debugging messages:  --------------------------------------------------
--	htp.br;
--	htp.print('FUNCTION Get_LEVEL_ID p_Level_Short_Name: ' || p_Level_Short_Name);
--	htp.br;

    /*
          Select LEVEL_ID
            Into l_level_id
         From BIS_LEVELS
           Where short_name = p_Level_Short_Name ;
--    */
--/*
    -- aleung, 11/08/00, use API to access PMF table BIS_LEVELS
    l_Level_Rec.Dimension_Level_Short_Name := p_Level_Short_Name;
/*
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level(p_api_version => 1.0,
                                                     p_Dimension_Level_Rec => l_Level_Rec,
                                                     x_Dimension_Level_Rec => l_Level_Rec,
                                                     x_return_status => l_Rstatus,
                                                     x_error_Tbl => l_Error_Tbl); */

    BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion(p_api_version => 1.0,
                                                p_Dimension_Level_Rec => l_Level_Rec,
                                                x_Dimension_Level_Rec => l_Level_Rec,
                                                x_return_status => l_Rstatus,
                                                x_error_Tbl => l_Error_Tbl);

   if l_Rstatus = FND_API.G_RET_STS_ERROR then
      return null;
   else
      l_level_id := l_Level_Rec.Dimension_Level_ID;
   end if;
--*/

--	   htp.print('l_level_id : ' || l_level_id);

	   Return l_level_id ;
    End If ;
EXCEPTION
   When Others Then
      Return NULL ;

End Get_Level_ID ;


procedure toleranceTest(pTargetLowHigh in varchar2,
                          pValue in varchar2,
					      pTarget out NOCOPY number,
						  pToleranceFlag out NOCOPY varchar2)

 -- pTargetLowHigh like 'T_100_20_30'

  is

    v_TargetLowHigh VARCHAR2(1000) := pTargetLowHigh;
    v_target   number;
	v_range_low number;
	v_range_high number;

    v_brake1 number;
	v_brake2 number;
	v_brake3 number;

	v_comparison_result varchar2(1000);
	v_target_rec  BIS_TARGET_PUB.Target_Rec_Type;
    v_actual_rec  BIS_ACTUAL_PUB.Actual_Rec_Type;

  begin

    pToleranceFlag :='ON';

    v_brake1 := instr(v_TargetLowHigh,'_',1,1);
    v_brake2 := instr(v_TargetLowHigh,'_',1,2);
    v_brake3 := instr(v_TargetLowHigh,'_',1,3);

    v_target     := nvl(substr(v_TargetLowHigh,v_brake1+1,v_brake2-v_brake1-1),0);
    v_range_low  := substr(v_TargetLowHigh,v_brake2+1,v_brake3-v_brake2-1);
    v_range_high := substr(v_TargetLowHigh,v_brake3+1);

    pTarget := v_target;

    v_target_rec.Target := v_target;
    v_target_rec.Range1_high := v_range_high ;
    v_target_rec.Range1_low := v_range_low;
    v_actual_rec.Actual := pValue;

    BIS_GENERIC_PLANNER_PVT.Compare_Values
    ( p_target_rec  => v_target_rec
    , p_actual_rec  => v_actual_rec
    , x_comparison_result  => v_comparison_result
    );

    if v_comparison_result <> BIS_GENERIC_PLANNER_PVT.G_COMP_RESULT_NORMAL then
       pToleranceFlag := 'OFF';
    end if;

  end toleranceTest;

  Function Schedule_Alert_Link
   (pMeasureShortName     Varchar2,
    pOrgLevel             Varchar2,
    pTimeLevel            Varchar2,
    pDimension1Level      Varchar2 default NULL,
    pDimension2Level      Varchar2 default NULL,
    pDimension3Level      Varchar2 default NULL,
    pDimension4Level      Varchar2 default NULL,
    pDimension5Level      Varchar2 default NULL,
    pDimension1           Varchar2 default NULL,
    pDimension2           Varchar2 default NULL,
    pDimension3           Varchar2 default NULL,
    pDimension4           Varchar2 default NULL,
    pDimension5           Varchar2 default NULL,
    pOrgLevelValue        Varchar2 ,
    pTimeLevelValue       Varchar2 ,
    pDimension1LevelValue Varchar2 default NULL,
    pDimension2LevelValue Varchar2 default NULL,
    pDimension3LevelValue Varchar2 default NULL,
    pDimension4LevelValue Varchar2 default NULL,
    pDimension5LevelValue Varchar2 default NULL,
    pPlanId               Varchar2)
	Return VARCHAR2 is

    vDimension1Level      Varchar2(80) := pDimension1Level;
    vDimension2Level      Varchar2(80) := pDimension2Level;
    vDimension3Level      Varchar2(80) := pDimension3Level;
    vDimension4Level      Varchar2(80) := pDimension4Level;
    vDimension5Level      Varchar2(80) := pDimension5Level;

    vDimension1LevelValue Varchar2(80) := pDimension1LevelValue ;
    vDimension2LevelValue Varchar2(80) := pDimension2LevelValue ;
    vDimension3LevelValue Varchar2(80) := pDimension3LevelValue ;
    vDimension4LevelValue Varchar2(80) := pDimension4LevelValue ; --minleung
    vDimension5LevelValue Varchar2(80) := pDimension5LevelValue ;


    vGeoLevel             Varchar2(80);
    vGeoLevelValue        Varchar2(80);
    vCountryCode          Varchar2(80);
    vAreaCode             Varchar2(80);

    vTimeLevelValue       Varchar2(80) := pTimeLevelValue;
	v_schedule_alert_URL VARCHAR2(32000);

  Begin
    if pDimension1 is not null then
       if pDimension1LevelValue = gvAll  then
              vDimension1Level := 'TOTAL ' || pDimension1;
              vDimension1LevelValue := '-1';
       end if;
    else
        vDimension1Level := NULL;
        vDimension1LevelValue := NULL;
    end if;

    if pDimension2 is not null then
       if pDimension2LevelValue = gvAll then
         vDimension2Level := 'TOTAL ' || pDimension2 ;
              vDimension2LevelValue := '-1';
       end if;
    else
        vDimension2Level := NULL;
        vDimension2LevelValue := NULL;
    end if;

    if pDimension3 is not null then
       if pDimension3LevelValue = gvAll then
         vDimension3Level := 'TOTAL ' || pDimension3;
              vDimension3LevelValue := '-1';
       end if;
    else
        vDimension3Level := NULL;
        vDimension3LevelValue := NULL;
    end if;

    if pDimension4 is not null then
       if pDimension4LevelValue = gvAll then
         vDimension4Level := 'TOTAL ' || pDimension4;
              vDimension4LevelValue := '-1';
       end if;
    else
        vDimension4Level := NULL;
        vDimension4LevelValue := NULL;
    end if;

    if pDimension5 is not null then
       if pDimension5LevelValue = gvAll  then
         vDimension5Level := 'TOTAL ' || pDimension5;
              vDimension5LevelValue := '-1';
       end if;
    else
        vDimension5Level := NULL;
        vDimension5LevelValue := NULL;
    end if;


    if (pDimension1 = 'GEOGRAPHY' or pDimension2 = 'GEOGRAPHY' or pDimension3 = 'GEOGRAPHY' or
                   pDimension4 = 'GEOGRAPHY' or pDimension5 = 'GEOGRAPHY')  then

        if pDimension1 = 'GEOGRAPHY' then
          vGeoLevel      := vDimension1Level;
          vGeoLevelValue := vDimension1LevelValue;
        elsif pDimension2 = 'GEOGRAPHY' then
          vGeoLevel      := vDimension2Level;
          vGeoLevelValue := vDimension2LevelValue;
        elsif pDimension3 = 'GEOGRAPHY' then
          vGeoLevel      := vDimension3Level;
          vGeoLevelValue := vDimension3LevelValue;
        elsif pDimension4 = 'GEOGRAPHY' then
          vGeoLevel      := vDimension4Level;
          vGeoLevelValue := vDimension4LevelValue;
        elsif pDimension5 = 'GEOGRAPHY' then
          vGeoLevel      := vDimension5Level;
          vGeoLevelValue := vDimension5LevelValue;
        end if;

        if vGeoLevel = 'COUNTRY'  then


              select bth.parent_territory_code
              into vAreaCode
              from bis_territory_hierarchies_v bth
              where bth.parent_territory_type = 'AREA'
               and bth.child_territory_type = 'COUNTRY'
               and bth.child_territory_code = vGeoLevelValue;

             vGeoLevelValue := vAreaCode ||'+' || vGeoLevelValue;

        elsif vGeoLevel = 'REGION'    /* Region */ then

              select bth.parent_territory_code
              into vCountryCode
              from bis_territory_hierarchies_v bth
              where bth.parent_territory_type = 'COUNTRY'
               and bth.child_territory_type = 'REGION'
               and bth.child_territory_code = vGeoLevelValue;

              select bth.parent_territory_name
              into vAreaCode
              from bis_territory_hierarchies_v bth
              where bth.parent_territory_type = 'AREA'
               and bth.child_territory_type = 'COUNTRY'
               and bth.child_territory_code = vCountryCode;

            vGeoLevelValue := vAreaCode ||'+' || vCountryCode || '+' || vGeoLevelValue;
        end if;

        if pDimension1 = 'GEOGRAPHY' then
          vDimension1LevelValue := vGeoLevelValue;
        elsif pDimension2 = 'GEOGRAPHY' then
          vDimension2LevelValue := vGeoLevelValue;
        elsif pDimension3 = 'GEOGRAPHY' then
          vDimension3LevelValue := vGeoLevelValue;
        elsif pDimension4 = 'GEOGRAPHY' then
          vDimension4LevelValue := vGeoLevelValue;
        elsif pDimension5 = 'GEOGRAPHY' then
          vDimension5LevelValue := vGeoLevelValue;
        end if;

    end if;

   v_schedule_alert_URL  :=  Schedule_Alert_URL
                    (pMeasureShortName,
                     pOrgLevel,
                     pTimeLevel,
                     vDimension1Level ,
                     vDimension2Level ,
                     vDimension3Level ,
                     vDimension4Level ,
                     vDimension5Level ,
                     pOrgLevelValue   ,
                     vTimeLevelValue  ,
                     vDimension1LevelValue ,
                     vDimension2LevelValue ,
                     vDimension3LevelValue ,
                     vDimension4LevelValue ,
                     vDimension5LevelValue ,
                     pPlanId  );


-----------------------------------------------------------------------
-- comment out ScheduleAkert link

-- upgrade text format (aleung 8/22/2000)
	RETURN '<A HREF=' || v_schedule_alert_URL || ' TARGET= >' || '<span class=OraGlobalButtonText>'
                       || fnd_message.get_string('BIS', 'SCHEDULE_ALERT') || '</span> </A>';

--commnet out  ScheduleAkert link */

------------------------------------------------------------------------

 --RETURN NULL;

End Schedule_Alert_Link;

FUNCTION Schedule_Alert_URL
( p_MEASURE_SHORT_NAME     VARCHAR2
, p_ORG_LEVEL              VARCHAR2
, p_TIME_LEVEL             VARCHAR2
, p_DIMENSION1_LEVEL       VARCHAR2
, p_DIMENSION2_LEVEL       VARCHAR2
, p_DIMENSION3_LEVEL       VARCHAR2
, p_DIMENSION4_LEVEL       VARCHAR2
, p_DIMENSION5_LEVEL       VARCHAR2
, p_ORG_LEVEL_VALUE        VARCHAR2
, p_TIME_LEVEL_VALUE       VARCHAR2
, p_DIMENSION1_LEVEL_VALUE VARCHAR2
, p_DIMENSION2_LEVEL_VALUE VARCHAR2
, p_DIMENSION3_LEVEL_VALUE VARCHAR2
, p_DIMENSION4_LEVEL_VALUE VARCHAR2
, p_DIMENSION5_LEVEL_VALUE VARCHAR2
, p_PLAN                   VARCHAR2
) RETURN VARCHAR2 IS

l_ORG_LEVEL_ID              NUMBER;
l_TIME_LEVEL_ID             NUMBER;
l_DIMENSION1_LEVEL_ID       NUMBER;
l_DIMENSION2_LEVEL_ID       NUMBER;
l_DIMENSION3_LEVEL_ID       NUMBER;
l_DIMENSION4_LEVEL_ID       NUMBER;
l_DIMENSION5_LEVEL_ID       NUMBER;

l_target_level_id NUMBER;
v_schedule_alert_URL VARCHAR2(32000);
v_meas_id NUMBER;

BEGIN

    l_ORG_LEVEL_ID        := Get_level_ID ( p_ORG_LEVEL );
    l_TIME_LEVEL_ID       := Get_level_ID ( p_TIME_LEVEL );
    l_DIMENSION1_LEVEL_ID := Get_level_ID ( p_DIMENSION1_LEVEL );
    l_DIMENSION2_LEVEL_ID := Get_level_ID ( p_DIMENSION2_LEVEL );
    l_DIMENSION3_LEVEL_ID := Get_level_ID ( p_DIMENSION3_LEVEL );
    l_DIMENSION4_LEVEL_ID := Get_level_ID ( p_DIMENSION4_LEVEL );
    l_DIMENSION5_LEVEL_ID := Get_level_ID ( p_DIMENSION5_LEVEL );


     SELECT distinct TARGET_LEVEL_ID, L.MEASURE_ID
      INTO l_target_level_id, v_meas_id
      FROM BISBV_TARGET_LEVELS L
         , BISBV_PERFORMANCE_MEASURES M
     WHERE M.MEASURE_ID          = L.MEASURE_ID
       AND M.MEASURE_SHORT_NAME  = p_MEASURE_SHORT_NAME
       AND L.ORG_LEVEL_ID        = l_ORG_LEVEL_ID
       AND L.TIME_LEVEL_ID       = l_TIME_LEVEL_ID
       AND ((l_DIMENSION1_LEVEL_ID IS NOT NULL
            AND L.DIMENSION1_LEVEL_ID = l_DIMENSION1_LEVEL_ID)
            OR (l_DIMENSION1_LEVEL_ID IS NULL))
       AND ((l_DIMENSION2_LEVEL_ID IS NOT NULL
            AND L.DIMENSION2_LEVEL_ID = l_DIMENSION2_LEVEL_ID)
            OR (l_DIMENSION2_LEVEL_ID IS NULL))
       AND ((l_DIMENSION3_LEVEL_ID IS NOT NULL
            AND L.DIMENSION3_LEVEL_ID = l_DIMENSION3_LEVEL_ID)
            OR (l_DIMENSION3_LEVEL_ID IS NULL))
       AND ((l_DIMENSION4_LEVEL_ID IS NOT NULL
            AND L.DIMENSION4_LEVEL_ID = l_DIMENSION4_LEVEL_ID)
            OR (l_DIMENSION4_LEVEL_ID IS NULL))
       AND ((l_DIMENSION5_LEVEL_ID IS NOT NULL
            AND L.DIMENSION5_LEVEL_ID = l_DIMENSION5_LEVEL_ID)
            OR (l_DIMENSION5_LEVEL_ID IS NULL));


--------------------------------------------------------------
/* commnet out ScheduleAlert URL

 BIS_PMF_ALERT_REG_PVT.BuildAlertRegistrationURL
    ( p_measure_id         => v_meas_id
	, p_target_level_id    => l_target_level_id
    , p_plan_id	           => p_plan
    , p_parameter1levelId  => l_ORG_LEVEL_ID
    , p_parameter1ValueId  => p_ORG_LEVEL_VALUE
    , p_parameter2levelId  => l_TIME_LEVEL_ID
    , p_parameter2ValueId  => p_TIME_LEVEL_VALUE
    , p_parameter3levelId  => l_DIMENSION1_LEVEL_ID
    , p_parameter3ValueId  => p_DIMENSION1_LEVEL_VALUE
    , p_parameter4levelId  => l_DIMENSION2_LEVEL_ID
    , p_parameter4ValueId  => p_DIMENSION2_LEVEL_VALUE
    , p_parameter5levelId  => l_DIMENSION3_LEVEL_ID
    , p_parameter5ValueId  => p_DIMENSION3_LEVEL_VALUE
    , p_parameter6levelId  => l_DIMENSION4_LEVEL_ID
    , p_parameter6ValueId  => p_DIMENSION4_LEVEL_VALUE
    , p_parameter7levelId  => l_DIMENSION5_LEVEL_ID
    , p_parameter7ValueId  => p_DIMENSION5_LEVEL_VALUE
    , p_viewByLevelId      => l_TIME_LEVEL_ID
    , x_alert_url          => v_schedule_alert_URL
    );

--comment out ScheduleAlert URL */
-----------------------------------------------------------

RETURN v_schedule_alert_URL;


EXCEPTION

  WHEN OTHERS THEN

       RETURN NULL;

END Schedule_Alert_URL;


procedure scheduleReports(
    pRegionCode         in  varchar2,
	pFunctionName       in  varchar2,
    pUserId             in  varchar2,
    pSessionId          in  varchar2,
    pResponsibilityId   in  varchar2,
    pReportTitle        in  varchar2 default NULL,
	pApplicationId      in  varchar2 default NULL,
    pParmPrint          in  varchar2 default NULL,
    pRequestType        in  varchar2 default 'R',
    pPlugId             in  varchar2 default NULL,
    pGraphType          in  varchar2 default NULL
    )
is
vScheduleURL varchar2(5000);
--l_customize_URL varchar2(32000);
l_customize_id   pls_integer;
l_fn_Responsibility_id number;
l_application_id number;
l_user_id        number;
l_rowid          varchar2(1000);

l_form_func_name  varchar2(1000) := 'BIS_SCHEDULE_PAGE';
l_form_func_call  varchar2(1000) := 'bissched.jsp';

vParams  varchar2(2000);

CURSOR cFndResp (pRespId in varchar2) is
select application_id
from fnd_responsibility
where responsibility_id=pRespId;

begin
      l_user_id := pUserId;

  l_fn_responsibility_id := nvl(pResponsibilityId, icx_sec.getid(ICX_SEC.PV_RESPONSIBILITY_ID));
  if pApplicationId is null then
     if cFNDResp%ISOPEN then
        CLOSE cFNDResp;
     end if;
     OPEN cFNDResp(l_fn_responsibility_id);
     FETCH cFNDResp INTO l_application_id;
     CLOSE cFNDResp;
  else
     l_application_id := pApplicationId;
  end if;

/*
      begin
           select application_id into l_application_id
           from fnd_responsibility
           where responsibility_id=l_fn_responsibility_id;
      end;

if pRequestType <> 'R' then
   l_form_func_name := 'BIS_SCHEDULE_CONFIRM_PAGE';
   l_form_func_call := 'bisschcf.jsp';
end if;
*/

      begin
           select function_id
           into l_customize_id
           from fnd_form_functions
           where function_name = l_form_func_name;
      exception
           when no_data_found then
              l_customize_id := null;
      end;

      if l_customize_id is null then
         begin
             select FND_FORM_FUNCTIONS_S.NEXTVAL into l_customize_id from dual;

--aleung, 5/14/01, for gsi1av envrionment, their fnd_form_functions_pkg.insert_row has more parameters

      fnd_form_functions_pkg.INSERT_ROW(
       X_ROWID                  => l_rowid,
       X_FUNCTION_ID            => l_customize_id,
       X_WEB_HOST_NAME          => null,
       X_WEB_AGENT_NAME         => null,
       X_WEB_HTML_CALL          => l_form_func_call,
       X_WEB_ENCRYPT_PARAMETERS => null,
       X_WEB_SECURED            => null,
       X_WEB_ICON               => null,
       X_OBJECT_ID              => null,
       X_REGION_APPLICATION_ID  => null,
       X_REGION_CODE            => null,
       X_FUNCTION_NAME          => l_form_func_name,
       X_APPLICATION_ID         => l_application_id,
       X_FORM_ID                => null,
       X_PARAMETERS             => null,
       X_TYPE                   => 'JSP',
       X_USER_FUNCTION_NAME     => 'BIS SCHEDULE',
       X_DESCRIPTION            => null,
       X_CREATION_DATE          => sysdate,
       X_CREATED_BY             => l_user_id,
       X_LAST_UPDATE_DATE       => sysdate,
       X_LAST_UPDATED_BY        => l_user_id,
       X_LAST_UPDATE_LOGIN      => l_user_id);

/*
             fnd_form_functions_pkg.insert_row (l_rowid,
                               l_customize_id, null,null,
                                l_form_func_call,
                                null,null,null,l_form_func_name,
                                l_application_id,null,null,'JSP','BIS SCHEDULE',
                                null,sysdate,l_user_id,sysdate,l_user_id,l_user_id);
*/

         exception
         when others then
           null;
         end;
      end if;

/*
      vScheduleURL := 'OracleApps.RF?F='||icx_call.encrypt2(l_application_id||'*'||l_fn_responsibility_id||'*'||icx_sec.g_security_group_id||'*'||l_customize_id||'**]',
                                                               icx_sec.getID(icx_sec.PV_SESSION_ID))
                                           ||'&P='||icx_call.encrypt2('regionCode='||bis_pmv_util.encode(pRegionCode)
                                           ||'&functionName='||bis_pmv_util.encode(pFunctionName)
                                           ||'&parmPrint='||bis_pmv_util.encode(pParmPrint)
                                           ||'&requestType='||pRequestType
                                           ||'&plugId='||pPlugId
                                           ||'&reportTitle='||bis_pmv_util.encode(pReportTitle)
                                           ||'&graphType='||pGraphType,icx_sec.getID(icx_sec.PV_SESSION_ID));
*/

    /*fnd_profile.get(name=>'APPS_SERVLET_AGENT',
                    val => vScheduleURL);
    vScheduleURL := FND_WEB_CONFIG.trail_slash(vScheduleURL)||
                   'bissched.jsp?dbc=' || FND_WEB_CONFIG.DATABASE_ID
                   ||'&sessionid='||icx_call.encrypt3(icx_sec.getID(icx_sec.PV_SESSION_ID))
                   ||'&responsibilityId='||pResponsibilityId
                   ||'&regionCode='||bis_pmv_util.encode(pRegionCode)
                   ||'&functionName='||bis_pmv_util.encode(pFunctionName)
                   ||'&parmPrint='||bis_pmv_util.encode(pParmPrint)
                   ||'&requestType='||pRequestType
                   ||'&plugId='||pPlugId
                   ||'&graphType='||pGraphType;*/

--    owa_util.redirect_url(vScheduleURL);

  -- mdamle 11/01/2002 - Added encode
  vParams := 'regionCode='|| pRegionCode
           ||'&functionName='||pFunctionName
           ||'&parmPrint='||bis_pmv_util.encode(pParmPrint)
           ||'&requestType='||pRequestType
           ||'&plugId='||pPlugId
           ||'&reportTitle='||pReportTitle
           ||'&graphType='||pGraphType;

  OracleApps.runFunction(c_function_id => l_customize_id
                        ,n_session_id => icx_sec.getID(icx_sec.PV_SESSION_ID)
                        ,c_parameters => vParams
                        ,p_resp_appl_id => l_application_id
                        ,p_responsibility_id => l_fn_responsibility_id
                        ,p_Security_group_id => icx_sec.g_Security_group_id
                        );

end scheduleReports;

Function Schedule_Reports_Link
   (pRegionCode           Varchar2,
	pFunctionName         Varchar2,
	pApplicationId        Varchar2 default NULL,
    pOrgLevel             Varchar2,
    pTimeLevel            Varchar2,
    pDimension1Level      Varchar2 default NULL,
    pDimension2Level      Varchar2 default NULL,
    pDimension3Level      Varchar2 default NULL,
    pDimension4Level      Varchar2 default NULL,
    pDimension5Level      Varchar2 default NULL,
    pDimension1           Varchar2 default NULL,
    pDimension2           Varchar2 default NULL,
    pDimension3           Varchar2 default NULL,
    pDimension4           Varchar2 default NULL,
    pDimension5           Varchar2 default NULL,
    pOrgLevelValue        Varchar2 ,
    pTimeLevelValue       Varchar2 ,
    pDimension1LevelValue Varchar2 default NULL,
    pDimension2LevelValue Varchar2 default NULL,
    pDimension3LevelValue Varchar2 default NULL,
    pDimension4LevelValue Varchar2 default NULL,
    pDimension5LevelValue Varchar2 default NULL,
    pPlanId               Varchar2,
	pViewByLevel          Varchar2)

	Return VARCHAR2 is

    vDimension1Level      Varchar2(80) := pDimension1Level;
    vDimension2Level      Varchar2(80) := pDimension2Level;
    vDimension3Level      Varchar2(80) := pDimension3Level;
    vDimension4Level      Varchar2(80) := pDimension4Level;
    vDimension5Level      Varchar2(80) := pDimension5Level;

    vDimension1LevelValue Varchar2(80) := pDimension1LevelValue ;
    vDimension2LevelValue Varchar2(80) := pDimension2LevelValue ;
    vDimension3LevelValue Varchar2(80) := pDimension3LevelValue ;
    vDimension4LevelValue Varchar2(80) := pDimension4LevelValue ;
    vDimension5LevelValue Varchar2(80) := pDimension5LevelValue ;


    vGeoLevel             Varchar2(80);
    vGeoLevelValue        Varchar2(80);
    vCountryCode          Varchar2(80);
    vAreaCode             Varchar2(80);

    vTimeLevelValue       Varchar2(80) := pTimeLevelValue;

	v_schedule_report_URL VARCHAR2(32000);

    l_ORG_LEVEL_ID              NUMBER;
    l_TIME_LEVEL_ID             NUMBER;
    l_DIMENSION1_LEVEL_ID       NUMBER;
    l_DIMENSION2_LEVEL_ID       NUMBER;
    l_DIMENSION3_LEVEL_ID       NUMBER;
    l_DIMENSION4_LEVEL_ID       NUMBER;
    l_DIMENSION5_LEVEL_ID       NUMBER;
	l_VIEWBY_LEVEL_ID           NUMBER;

  Begin

--htp.print ('I Value : ' || pDimension1LevelValue || pDimension1);

    if pDimension1 is not null then
       if pDimension1LevelValue = gvAll  then
              vDimension1Level := 'TOTAL ' || pDimension1;
              vDimension1LevelValue := '-1';
       end if;
    else
        vDimension1Level := NULL;
        vDimension1LevelValue := NULL;
    end if;

    if pDimension2 is not null then
       if pDimension2LevelValue = gvAll then
         vDimension2Level := 'TOTAL ' || pDimension2 ;
              vDimension2LevelValue := '-1';
       end if;
    else
        vDimension2Level := NULL;
        vDimension2LevelValue := NULL;
    end if;

    if pDimension3 is not null then
       if pDimension3LevelValue = gvAll then
         vDimension3Level := 'TOTAL ' || pDimension3;
              vDimension3LevelValue := '-1';
       end if;
    else
        vDimension3Level := NULL;
        vDimension3LevelValue := NULL;
    end if;

    if pDimension4 is not null then
       if pDimension4LevelValue = gvAll then
         vDimension4Level := 'TOTAL ' || pDimension4;
              vDimension4LevelValue := '-1';
       end if;
    else
        vDimension4Level := NULL;
        vDimension4LevelValue := NULL;
    end if;

    if pDimension5 is not null then
       if pDimension5LevelValue = gvAll  then
         vDimension5Level := 'TOTAL ' || pDimension5;
              vDimension5LevelValue := '-1';
       end if;
    else
        vDimension5Level := NULL;
        vDimension5LevelValue := NULL;
    end if;


    if (pDimension1 = 'GEOGRAPHY' or pDimension2 = 'GEOGRAPHY' or pDimension3 = 'GEOGRAPHY' or
                   pDimension4 = 'GEOGRAPHY' or pDimension5 = 'GEOGRAPHY')  then

        if pDimension1 = 'GEOGRAPHY' then
          vGeoLevel      := vDimension1Level;
          vGeoLevelValue := vDimension1LevelValue;
        elsif pDimension2 = 'GEOGRAPHY' then
          vGeoLevel      := vDimension2Level;
          vGeoLevelValue := vDimension2LevelValue;
        elsif pDimension3 = 'GEOGRAPHY' then
          vGeoLevel      := vDimension3Level;
          vGeoLevelValue := vDimension3LevelValue;
        elsif pDimension4 = 'GEOGRAPHY' then
          vGeoLevel      := vDimension4Level;
          vGeoLevelValue := vDimension4LevelValue;
        elsif pDimension5 = 'GEOGRAPHY' then
          vGeoLevel      := vDimension5Level;
          vGeoLevelValue := vDimension5LevelValue;
        end if;

        if vGeoLevel = 'COUNTRY'  then


              select bth.parent_territory_code
              into vAreaCode
              from bis_territory_hierarchies_v bth
              where bth.parent_territory_type = 'AREA'
               and bth.child_territory_type = 'COUNTRY'
               and bth.child_territory_code = vGeoLevelValue;

             vGeoLevelValue := vAreaCode ||'+' || vGeoLevelValue;

        elsif vGeoLevel = 'REGION'    /* Region */ then

              select bth.parent_territory_code
              into vCountryCode
              from bis_territory_hierarchies_v bth
              where bth.parent_territory_type = 'COUNTRY'
               and bth.child_territory_type = 'REGION'
               and bth.child_territory_code = vGeoLevelValue;

              select bth.parent_territory_name
              into vAreaCode
              from bis_territory_hierarchies_v bth
              where bth.parent_territory_type = 'AREA'
               and bth.child_territory_type = 'COUNTRY'
               and bth.child_territory_code = vCountryCode;

            vGeoLevelValue := vAreaCode ||'+' || vCountryCode || '+' || vGeoLevelValue;
        end if;

        if pDimension1 = 'GEOGRAPHY' then
          vDimension1LevelValue := vGeoLevelValue;
        elsif pDimension2 = 'GEOGRAPHY' then
          vDimension2LevelValue := vGeoLevelValue;
        elsif pDimension3 = 'GEOGRAPHY' then
          vDimension3LevelValue := vGeoLevelValue;
        elsif pDimension4 = 'GEOGRAPHY' then
          vDimension4LevelValue := vGeoLevelValue;
        elsif pDimension5 = 'GEOGRAPHY' then
          vDimension5LevelValue := vGeoLevelValue;
        end if;

    end if;

	l_ORG_LEVEL_ID        := Get_level_ID ( pOrgLevel );
    l_TIME_LEVEL_ID       := Get_level_ID ( pTimeLevel );
    l_DIMENSION1_LEVEL_ID := Get_level_ID ( pDimension1Level );
    l_DIMENSION2_LEVEL_ID := Get_level_ID ( pDimension2Level );
    l_DIMENSION3_LEVEL_ID := Get_level_ID ( pDimension3Level );
    l_DIMENSION4_LEVEL_ID := Get_level_ID ( pDimension4Level );
    l_DIMENSION5_LEVEL_ID := Get_level_ID ( pDimension5Level );
    l_VIEWBY_LEVEL_ID     := Get_level_ID ( pViewByLevel );

-----------------------------------------------------------
/* comment out 'ScheduleReport'

	BIS_PMF_ALERT_REG_PVT.BuildScheduleReportURL
    ( p_RegionCode         => pRegionCode
	, p_FunctionName       => pFunctionName
	, p_ApplicationId      => pApplicationId
    , p_plan_id	           => pPlanId
    , p_parameter1levelId  => l_ORG_LEVEL_ID
    , p_parameter1ValueId  => pOrgLevelValue
    , p_parameter2levelId  => l_TIME_LEVEL_ID
    , p_parameter2ValueId  => pTimeLevelValue
    , p_parameter3levelId  => l_DIMENSION1_LEVEL_ID
    , p_parameter3ValueId  => pDimension1LevelValue
    , p_parameter4levelId  => l_DIMENSION2_LEVEL_ID
    , p_parameter4ValueId  => pDimension2LevelValue
    , p_parameter5levelId  => l_DIMENSION3_LEVEL_ID
    , p_parameter5ValueId  => pDimension3LevelValue
    , p_parameter6levelId  => l_DIMENSION4_LEVEL_ID
    , p_parameter6ValueId  => pDimension4LevelValue
    , p_parameter7levelId  => l_DIMENSION5_LEVEL_ID
    , p_parameter7ValueId  => pDimension5LevelValue
    , p_viewByLevelId      => l_VIEWBY_LEVEL_ID
	-- , p_returnPageUrl    => 'http://www.yahoo.com'
    , x_alert_url => v_schedule_report_URL
   );

--comment out ScheduleReports */
------------------------------------------------------

	RETURN v_schedule_report_URL;

  End Schedule_Reports_Link;

   function  getTargetParm(Display in varchar2,
                           Measure in varchar2,
                           PlanId in varchar2,
                           Dim1Level in varchar2 default null,
                           Dim2Level in varchar2 default null,
                           Dim3Level in varchar2 default null,
                           Dim4Level in varchar2 default null,
                           Dim5Level in varchar2 default null,
                           Dim6Level in varchar2 default null,
                           Dim7Level in varchar2 default null,
                           Dim1LevelValue in varchar2 default null,
                           Dim2LevelValue in varchar2 default null,
                           Dim3LevelValue in varchar2 default null,
                           Dim4LevelValue in varchar2 default null,
                           Dim5LevelValue in varchar2 default null,
                           Dim6LevelValue in varchar2 default null,
                           Dim7LevelValue in varchar2 default null) return varchar2 is
   vTargetParm varchar2(2000);

begin
   vTargetParm := Display||'TARGET&Measure='||bis_pmv_util.encode(Measure)
                            ||'&PlanId='||bis_pmv_util.encode(PlanId)
                            ||'&Dim1Level='||bis_pmv_util.encode(Dim1Level)
                            ||'&Dim2Level='||bis_pmv_util.encode(Dim2Level)
                            ||'&Dim3Level='||bis_pmv_util.encode(Dim3Level)
                            ||'&Dim4Level='||bis_pmv_util.encode(Dim4Level)
                            ||'&Dim5Level='||bis_pmv_util.encode(Dim5Level)
                            ||'&Dim6Level='||bis_pmv_util.encode(Dim6Level)
                            ||'&Dim7Level='||bis_pmv_util.encode(Dim7Level)
                            ||'&Dim1LevelValue='||bis_pmv_util.encode(Dim1LevelValue)
                            ||'&Dim2LevelValue='||bis_pmv_util.encode(Dim2LevelValue)
                            ||'&Dim3LevelValue='||bis_pmv_util.encode(Dim3LevelValue)
                            ||'&Dim4LevelValue='||bis_pmv_util.encode(Dim4LevelValue)
                            ||'&Dim5LevelValue='||bis_pmv_util.encode(Dim5LevelValue)
                            ||'&Dim6LevelValue='||bis_pmv_util.encode(Dim6LevelValue)
                            ||'&Dim7LevelValue='||bis_pmv_util.encode(Dim7LevelValue);
   return vTargetParm;
end getTargetParm;

procedure getTotalDimValue(pDimSource in varchar2,
                           pDimension in varchar2 default null,
                           pDimensionLevel in out NOCOPY varchar2,
                           pDimensionLevelValue out NOCOPY varchar2) is

   vTotalLevel      varchar2(80);
   vTotalLevelValue varchar2(80) := '-1';
--/*
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
--*/
begin
/*
    vTotalLevel := bis_utilities_pvt.Get_Total_DimLevel_Name(p_dim_short_name =>pDimension,
                                                             p_DimLevelName =>pDimensionLevel);
*/
    vTotalLevel := getTotalDimLevelName(pDimShortName => pDimension,
                                        pSource => pDimSource);
/*
    if pDimSource = 'EDW' then
       vTotalLevelValue := '1';
    end if;
*/
 --/*
    BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING(
        p_DimLevelShortName => vTotalLevel
        ,p_bis_source => pDimSource
        ,x_Select_String => v_sql_stmnt
        ,x_table_name=>     v_table
        ,x_id_name=>        v_id_name
        ,x_value_name=>     v_value_name
        ,x_return_status=>  v_return_status
        ,x_msg_count=>      v_msg_count
        ,x_msg_data=>       v_msg_data
        );

    if v_return_status = FND_API.G_RET_STS_ERROR then
        for i in 1..v_msg_count loop
          htp.print(fnd_msg_pub.get(p_msg_index=>i, p_encoded=>FND_API.G_FALSE));
		  htp.br;
        end loop;
    end if;

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
--*/

    pDimensionLevel := vTotalLevel;
    pDimensionLevelValue := vTotalLevelValue;

end getTotalDimValue;

Function getTotalDimLevelName(pDimShortName IN VARCHAR2
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

end bisviewer_pmf;

/
