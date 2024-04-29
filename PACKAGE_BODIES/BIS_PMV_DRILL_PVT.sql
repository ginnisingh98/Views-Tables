--------------------------------------------------------
--  DDL for Package Body BIS_PMV_DRILL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_DRILL_PVT" AS
/* $Header: BISVDRIB.pls 120.1 2006/02/13 02:48:56 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.90=120.1):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_PMV_DRILL_PVT                                       --
--                                                                        --
--  DESCRIPTION:  This package contains all the procedures used to        --
--                validate the Report Generator parameters.               --
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification                                    --
--  10/24/01   aleung     initial creation                                --
--  09/30/02   nkishore   Fix for 2594996                                 --
--  11/12/02   nkishore   Fix for 2616798 commented overRideViewBy        --
--  04/22/03   ansingh    BugFix#2887200  	                          --
--  06/07/03   gsanap     Added p_NextExtraViewBy to drilldown bug 3007145--
--  18-JUL-03 ansingh     Bug3056835: enable drill/pivot from webportlet  --
--  14-AUG-03 ansingh     Bug3024649: drilldown changes for related links --
--  19-AUG-03 nkishore    BugFix 3099789 add copy_time_params	    	  --
--  10/21/03   nbarik     Bug Fix 3201277 - Change in overRideViewBy      --
--  01/30/04   ksadagop   Bug Fix 3409904 - Added CustomView for drilldown--
--  02/19/04   nbarik     Bug Fix 3441967                                 --
--  03/31/04   nbarik     Bug Fix 3510716                                 --
--  06/04/04   ashgarg    Bug Fix 3665085                                 --
----------------------------------------------------------------------------

--Fix for 2594996
PROCEDURE overRideViewBy (
                           pFunctionName       in varchar2,
                          pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pTimeAttribute    IN VARCHAR2
) IS

    --nbarik - 10/21/03 - bug fix 3201277 - Added function name here
    cursor getViewBy (cpUserId varchar2, cpSessionId varchar2) is
    select session_value
    from   bis_user_attributes
    where  user_id = cpUserId
    and    session_id = cpSessionId
    and    function_name = pFunctionName
    and    attribute_name = 'VIEW_BY';

    --nbarik - 10/21/03 - bug fix 3201277
    /*
    cursor getTimeAttribute (cpUserId varchar2, cpSessionId varchar2) is
    select attribute_name
    from   bis_user_attributes
    where  user_id = cpUserId
    and    session_id = cpSessionId
    and    ( attribute_name like 'TIME%' or attribute_name like 'EDW_TIME_M%' );
    */

    lViewByValue      VARCHAR2(200);
    lViewByDimension  VARCHAR2(100);
    lTimeDimLevel     VARCHAR2(100);
    lTimeDimLevels    VARCHAR2(100);

BEGIN

   IF getViewBy%ISOPEN THEN
      close getViewBy;
   END IF;
   OPEN getViewBy(pUserId, pSessionId);
   FETCH getViewBy INTO lViewByValue;
   CLOSE getViewBy;

   IF (lViewByValue is not null) THEN
    lViewByDimension := substr(lViewByValue ,1,instr(lViewByValue ,'+')-1) ;

    IF (lViewByDimension = 'TIME' OR lViewByDimension = 'EDW_TIME_M') THEN
       /*
       IF getTimeAttribute%ISOPEN THEN
          close getTimeAttribute;
       END IF;

       OPEN  getTimeAttribute(pUserId, pSessionId);
       FETCH getTimeAttribute into lTimeDimLevel;
       CLOSE getTimeAttribute;
       */
       --nbarik - 10/21/03 - bug fix 3201277
       lTimeDimLevel := pTimeAttribute;
       IF ( lTimeDimLevel is not null ) THEN

          IF ( instr(lTimeDimLevel,'_FROM') > 1 ) THEN
            lTimeDimLevels := substr( lTimeDimLevel ,1,instr( lTimeDimLevel ,'_FROM')-1);
          ELSIF ( instr(lTimeDimLevel,'_TO') > 1 ) THEN
            lTimeDimLevels := substr( lTimeDimLevel ,1,instr( lTimeDimLevel ,'_TO')-1);
          END IF;

          DELETE FROM bis_user_attributes where session_id= pSessionId AND function_name= pFunctionName
          AND schedule_id is null
          AND user_id=pUserId
          AND attribute_name = 'VIEW_BY';

          INSERT INTO BIS_USER_ATTRIBUTES (user_id, function_name,
                                      session_id, attribute_name,
                                      session_value,
                                      dimension,
                                      creation_date, created_by,
                                      last_update_Date, last_updated_by)
                              VALUES (pUserId, pFunctionName,
                                      pSessionId, 'VIEW_BY' ,
                                      lTimeDimLevels,
                                      lViewByDimension,
                                      sysdate, -1, sysdate, -1);
       END IF;

    END IF;
   END IF;
   --End of Fix for 2594996

END overRideViewBy;

/* Procedure to copy the same function parameters - overide from schedule and page only */
PROCEDURE copySameFunctionParameters(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pScheduleId         in varchar2 default null,
                          pPageId         in  varchar2 default null,
                          pRespId         in  varchar2 default null,
                          pParameterGroup IN BIS_PMV_PARAMETERS_PVT.parameter_group_tbl_type
                        )IS

BEGIN

 IF (pScheduleId IS NOT NULL) THEN
   BIS_PMV_PARAMETERS_PVT.overRideFromSchedule(
                           pSessionId          => pSessionId,
                           pUserId             =>pUserId,
                           pFunctionName       =>pFunctionName,
                           pRegionCode         => pRegionCode,
                           pScheduleId         => pScheduleId,
                          pRespId         =>pRespId,
                          pParameterGroup =>pParameterGroup
                        );
 END IF;

 IF (pPageId IS NOT NULL) THEN
   BIS_PMV_PARAMETERS_PVT.overRideFromPage(
                           pSessionId          => pSessionId,
                           pUserId             =>pUserId,
                           pFunctionName       =>pFunctionName,
                           pRegionCode         => pRegionCode,
                           pPageId         => pPageId,
                          pRespId         =>pRespId,
                          pParameterGroup =>pParameterGroup
                        );
 END IF;

END copySameFunctionParameters;


PROCEDURE copyGroupedParameters(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pPreFunctionName    in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pScheduleId         in varchar2 default null,
                          pPageId         in  varchar2 default null,
                          pRespId         in  varchar2 default null,
                          pParameterGroup IN BIS_PMV_PARAMETERS_PVT.parameter_group_tbl_type,
                          pTCTExists      in boolean default false,
                          pNestedRegionCode in varchar2 default null,
                          pAsofdateExists in boolean default false,
			  xTimeAttribute out NOCOPY varchar2
                        ) IS
    l_return_status   varchar2(32000);
    l_msg_count       NUMBER;
    l_msg_data        varchar2(32000);
    l_time_attribute  varchar2(2000);
    -- nbarik - 02/19/04 - BugFix 3441967
    l_IsPreFuncTCTExists          BOOLEAN := FALSE;
    l_IsPreFuncCalcDatesExists    BOOLEAN := FALSE;

BEGIN

if (pFunctionName = pPreFunctionName) THEN

  copySameFunctionParameters(pSessionId          => pSessionId,
                           pUserId             => pUserId,
                           pFunctionName       => pFunctionName,
                           pRegionCode         => pRegionCode,
                           pScheduleId         => pScheduleId,
                          pPageId         => pPageId,
                          pRespId         => pRespId,
                          pParameterGroup => pParameterGroup
                        );
ELSE

 --0) delete all the existing session parameters
  DELETE FROM bis_user_attributes
  WHERE function_name=pFunctionName
  AND user_id=pUserId
  AND session_id=pSessionId
  AND schedule_id IS NULL;

 --1) copy all the fnd form function default parameters
 BIS_PMV_PARAMETERS_PVT.COPY_FORM_FUNCTION_PARAMETERS
    (pRegionCode       => pRegionCode
    ,pFunctionName      => pFunctionName
    ,pUserId           => pUserId
    ,pSessionId        => pSessionId
    ,pResponsibilityId => pRespId
    ,pNestedRegionCode => pNestedRegionCode
    ,pAsofdateExists   => pAsofdateExists
    ,x_return_status   => l_return_status
    ,x_msg_count	     => l_msg_count
    ,x_msg_data	       => l_msg_data
    ) ;


   --2) use the saved default parameters
   BIS_PMV_PARAMETERS_PVT.overRideFromSavedDefault(
                           pSessionId          => pSessionId,
                           pUserId             =>pUserId,
                           pFunctionName       =>pFunctionName,
                           pRegionCode         => pRegionCode,
                          pRespId         =>pRespId,
                          pParameterGroup =>pParameterGroup
                        );

    -- 3) schedule or preFunction
 IF (pScheduleId IS NOT NULL) THEN
   BIS_PMV_PARAMETERS_PVT.overRideFromSchedule(
                           pSessionId          => pSessionId,
                           pUserId             =>pUserId,
                           pFunctionName       =>pFunctionName,
                           pRegionCode         => pRegionCode,
                           pScheduleId         => pScheduleId,
                          pRespId         =>pRespId,
                          pParameterGroup =>pParameterGroup

                        );
 ELSIF (pPreFunctionName IS NOT NULL) THEN
   -- nbarik - 02/19/04 - BugFix 3441967
   BIS_PMV_PARAMETERS_PVT.overRideFromPreFunction(
                           pSessionId          => pSessionId,
                           pUserId             =>pUserId,
                           pFunctionName       =>pFunctionName,
                           pRegionCode         => pRegionCode,
                           pPreFunctionName         => pPreFunctionName,
                          pRespId         =>pRespId,
                          pParameterGroup =>pParameterGroup,
                          pTCTExists => pTCTExists
                        , x_IsPreFuncTCTExists => l_IsPreFuncTCTExists
                        , x_IsPreFuncCalcDatesExists => l_IsPreFuncCalcDatesExists
                        );
 END IF;


 --4) page level
 IF (pPageId IS NOT NULL) THEN
   BIS_PMV_PARAMETERS_PVT.overRideFromPage(
                           pSessionId          => pSessionId,
                           pUserId             =>pUserId,
                           pFunctionName       =>pFunctionName,
                           pRegionCode         => pRegionCode,
                           pPageId         => pPageId,
                           pRespId         =>pRespId,
                           pParameterGroup =>pParameterGroup
                        );
 END IF;
--BugFix 3099789 add copy_time_params, Save Time Params here
    -- nbarik - 02/19/04 - BugFix 3441967
   BIS_PMV_PARAMETERS_PVT.COPY_TIME_PARAMS(
                           pSessionId          => pSessionId,
                           pUserId             =>pUserId,
                           pFunctionName       =>pFunctionName,
                           pRegionCode         => pRegionCode,
                          pRespId         =>pRespId,
                          pParameterGroup =>pParameterGroup,
                          pTCTExists => pTCTExists,
                          p_IsPreFuncTCTExists => l_IsPreFuncTCTExists,
                          p_IsPreFuncCalcDatesExists => l_IsPreFuncCalcDatesExists,
                          x_time_attribute => l_time_attribute
                        );
 --nbarik - 10/21/03 - bug fix 3201277 - Uncomment overRideViewBy call
 --5 ) override the view-by in case it is time --Fix for 2594996
 overRideViewBy (
                pFunctionName => pFunctionName,
               pSessionId  =>pSessionId,
               pUserId => pUserId,
               pTimeAttribute => l_time_attribute
              );

 -- DIMENSION VALUE EXTENSION - DRILL Bug 3230530 / Bug 3004363
 -- Return l_time_attribute to caller
 xTimeAttribute := l_time_attribute ;

END IF; --functionName =preFunctionName
COMMIT;

END copyGroupedParameters;

 procedure copyParameters(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pPreFunctionName    in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pScheduleId         in varchar2 default null,
                        pPageId         in  varchar2 default null,
                        pRespId         in  varchar2 default null ) IS

    vOldDimension varchar2(1000);
    vAttributeCodeTable BISVIEWER.t_char;
    vDimensionTable     BISVIEWER.t_char;
    vDisplaySeqTable     BISVIEWER.t_char;

    cursor cParameters (cpRegionCode varchar2) is
    select nvl(attribute2,attribute_code) attribute_code, substr(attribute2,1,instr(attribute2,'+')-1) dimension
    from   ak_region_items_vl
    where  region_code = rtrim(cpRegionCode)
    and    node_query_flag = 'Y'
    order by display_sequence;

    cursor cPageLessParameters (cpRegionCode varchar2) is
    select nvl(attribute2,attribute_code) attribute_code, substr(attribute2,1,instr(attribute2,'+')-1) dimension
    from   ak_region_items_vl ak
    where  ak.region_code = rtrim(cpRegionCode)
    and    ak.node_query_flag = 'Y'
    AND nvl(substr(ak.attribute2,1,instr(ak.attribute2,'+')-1), ak.attribute_code) NOT IN (
        select DISTINCT nvl(substr(b.attribute_name,1,instr(b.attribute_name,'+')-1), attribute_code)
        from bis_user_attributes b
        where b.page_id=pPageId
        and b.user_id =pUserId
        )
    order by display_sequence;

    -- ashgarg Bug Fix: 3665085 Changed ak_region_items_vl to ak_region_items
    CURSOR cParametersWithNestedRegion (cpRegionCode varchar2, cpNestedRegionCode IN VARCHAR2) is
        SELECT nvl(attribute2,attribute_code) attribute_code, substr(attribute2,1,instr(attribute2,'+')-1) dimension, display_sequence
        FROM ak_region_items
        WHERE region_code=cpNestedRegionCode
        AND node_query_flag='Y'
      UNION
        SELECT nvl(attribute2,attribute_code) attribute_code, substr(attribute2,1,instr(attribute2,'+')-1) dimension, display_sequence
        FROM   ak_region_items
        WHERE  region_code = rtrim(cpRegionCode)
        AND    node_query_flag = 'Y'
        AND nvl(substr(attribute2,1,instr(attribute2,'+')-1), attribute_code) NOT IN (
        	SELECT DISTINCT nvl(substr(attribute2,1,instr(attribute2,'+')-1), attribute_code)
          FROM ak_region_items
          WHERE region_code =cpNestedRegionCode
        )
        ORDER BY display_sequence;

    CURSOR cPageLessWithNestedRegion (cpRegionCode varchar2, cpNestedRegionCode IN VARCHAR2) is
        SELECT nvl(attribute2,attribute_code) attribute_code, substr(attribute2,1,instr(attribute2,'+')-1) dimension, display_sequence
        from ak_region_items
        where region_code=cpNestedRegionCode
        and node_query_flag='Y'
        and nvl(substr(attribute2,1,instr(attribute2,'+')-1), attribute_code)  not in (
          SELECT DISTINCT nvl(substr(attribute_name ,1,instr(attribute_name ,'+')-1), attribute_code)
          FROM bis_user_attributes
          WHERE page_id=pPageId
          AND user_id=pUserId
        )
      UNION
      --2. default region w/o page, w/o nested
        SELECT nvl(attribute2,attribute_code) attribute_code, substr(attribute2,1,instr(attribute2,'+')-1) dimension, display_sequence
        FROM ak_region_items
        WHERE region_code= rtrim(cpRegionCode)
        AND node_query_flag='Y'
        AND nvl(substr(attribute2,1,instr(attribute2,'+')-1), attribute_code)  NOT IN (
            SELECT DISTINCT nvl( substr(attribute_name ,1,instr(attribute_name ,'+')-1), attribute_code)
            FROM bis_user_attributes
            WHERE page_id=pPageId
            AND 	user_id=pUserId
          UNION
            SELECT DISTINCT nvl( substr(attribute2,1,instr(attribute2,'+')-1), attribute_code)
            FROM ak_region_items
            WHERE region_code =cpNestedRegionCode
        )
        ORDER BY display_sequence;

    cursor getViewBy (cpUserId varchar2, cpSessionId varchar2) is
    select session_value
    from   bis_user_attributes
    where  user_id = cpUserId
    and    session_id = cpSessionId
    and    attribute_name = 'VIEW_BY';

    cursor getTimeAttribute (cpUserId varchar2, cpSessionId varchar2) is
    select attribute_name
    from   bis_user_attributes
    where  user_id = cpUserId
    and    session_id = cpSessionId
    and    ( attribute_name like 'TIME%' or attribute_name like 'EDW_TIME_M%' );


    l_return_status   varchar2(32000);
    l_msg_count       NUMBER;
    l_msg_data        varchar2(32000);
    lNestedRegionCode VARCHAR2(30);
    lViewByValue      VARCHAR2(200);
    lViewByDimension  VARCHAR2(100);
    lTimeDimLevel     VARCHAR2(100);
    lTimeDimLevels    VARCHAR2(100);

    cursor getNestedRegionCode (cpRegionCode varchar2) is
     SELECT nested_region_code
     FROM ak_region_items
     WHERE region_code = cpRegionCode
     AND nested_region_code IS NOT NULL;


begin

--delete all the paramete rs for this session for this report only if this is not a recursive drill into the same
-- report, else will lose the data
--jprabhud added the OR clause for enhancement #2442162
IF (pFunctionName <> pPreFunctionName OR pPreFunctionName IS NULL) THEN
  DELETE FROM bis_user_attributes
  WHERE function_name=pFunctionName
  AND user_id=pUserId
  AND session_id=pSessionId
  AND schedule_id IS NULL;
END IF;

-- get the nested region code
   if getNestedRegionCode%ISOPEN then
      close getNestedRegionCode;
   end if;
   open getNestedRegionCode(pRegionCode);
   fetch getNestedRegionCode INTO lNestedRegionCode;
   close getNestedRegionCode;

 IF pPageId is not null then
   -- elete the page parameters
  DELETE FROM bis_user_attributes where session_id= pSessionId AND function_name= pFunctionName
  AND schedule_id is null
  AND user_id=pUserId
  AND attribute_name in
   (SELECT attribute_name from bis_user_attributes where user_id=pUserId and page_id=pPageId);

  -- copy the page level parameters
       insert into bis_user_attributes (USER_ID,
                                      FUNCTION_NAME,
                                      SESSION_ID,
                                      SESSION_VALUE,
                                      SESSION_DESCRIPTION,
                                      ATTRIBUTE_NAME,
                                      DIMENSION,
                                      PERIOD_DATE)
          SELECT  pUserId,
              pFunctionName,
              pSessionId,
              SESSION_VALUE,
              SESSION_DESCRIPTION,
              ATTRIBUTE_NAME,
              DIMENSION,
              PERIOD_DATE
          FROM    bis_user_attributes
          where   user_id = pUserId
          AND page_id = pPageId;

END IF;

 IF (pFunctionName = pPreFunctionName ) THEN

   --If sched if is null, the rest of the procedure only copies the params from the preFunction
   -- tothe function which is not needed for self drilling
  IF (pScheduleId IS NULL) THEN
    RETURN;
  ELSE
    DELETE FROM bis_user_attributes where session_id= pSessionId AND function_name= pFunctionName
    and schedule_id is null AND user_id=pUserId
    AND attribute_name in
     (SELECT attribute_name from bis_user_attributes where schedule_id=pSCheduleId);

    -- for time from
    DELETE FROM bis_user_attributes where session_id= pSessionId AND function_name= pFunctionName
    and schedule_id is null AND user_id=pUserId
    AND attribute_name in
     (SELECT attribute_name||'_FROM' from bis_user_attributes where schedule_id=pSCheduleId);

    -- for time to
    DELETE FROM bis_user_attributes where session_id= pSessionId AND function_name= pFunctionName
    and schedule_id is null AND user_id=pUserId
    AND attribute_name in
     (SELECT attribute_name||'_TO' from bis_user_attributes where schedule_id=pSCheduleId);

  END IF;

 END IF;

 IF lNestedRegionCode IS NOT NULL THEN

   IF pPageId IS NOT null THEN

     if cPageLessWithNestedRegion%ISOPEN then
        close cPageLessWithNestedRegion;
     end if;
     open cPageLessWithNestedRegion(pRegionCode, lNestedRegionCode);
     fetch cPageLessWithNestedRegion bulk collect into vAttributeCodeTable, vDimensionTable, vDisplaySeqTable;
     close cPageLessWithNestedRegion;
   ELSE

     if cParametersWithNestedRegion%ISOPEN then
        close cParametersWithNestedRegion;
     end if;
     open cParametersWithNestedRegion(pRegionCode, lNestedRegionCode);
     fetch cParametersWithNestedRegion bulk collect into vAttributeCodeTable, vDimensionTable, vDisplaySeqTable;
     close cParametersWithNestedRegion;
   END IF; -- pageId

 ELSE

   IF pPageId is not null then
     if cPageLessParameters%ISOPEN then
        close cPageLessParameters;
     end if;
     open cPageLessParameters(pRegionCode);
     fetch cPageLessParameters bulk collect into vAttributeCodeTable, vDimensionTable;
     close cPageLessParameters;
   else
     -- get parameters
     if cParameters%ISOPEN then
        close cParameters;
     end if;
     open cParameters(pRegionCode);
     fetch cParameters bulk collect into vAttributeCodeTable, vDimensionTable;
     close cParameters;
   end if; -- pageId
 END IF; -- if no nested region


if vAttributeCodeTable.COUNT > 0 then
 vAttributeCodeTable(vAttributeCodeTable.COUNT+1) := 'BIS_P_ASOF_DATE';
 for i in vAttributeCodeTable.FIRST..vAttributeCodeTable.LAST loop

    if pScheduleId is null then
       insert into bis_user_attributes (USER_ID,
                                      FUNCTION_NAME,
                                      SESSION_ID,
                                      SESSION_VALUE,
                                      SESSION_DESCRIPTION,
                                      ATTRIBUTE_NAME,
                                      DIMENSION,
                                      PERIOD_DATE)
        select  USER_ID,
              pFunctionName,
              SESSION_ID,
              SESSION_VALUE,
              SESSION_DESCRIPTION,
              ATTRIBUTE_NAME,
              DIMENSION,
              PERIOD_DATE
        from    bis_user_attributes
        where   function_name = pPreFunctionName
        and     attribute_name in (vAttributeCodeTable(i),
                                   vAttributeCodeTable(i)||'_FROM',
                                 vAttributeCodeTable(i)||'_TO')
        and     session_id = pSessionId
        and     user_id = pUserId;
    else
       insert into bis_user_attributes (USER_ID,
                                      FUNCTION_NAME,
                                      SESSION_ID,
                                      SESSION_VALUE,
                                      SESSION_DESCRIPTION,
                                      ATTRIBUTE_NAME,
                                      DIMENSION,
                                      PERIOD_DATE)
        select  pUserId,
              pFunctionName,
              pSessionId,
              SESSION_VALUE,
              SESSION_DESCRIPTION,
              ATTRIBUTE_NAME,
              DIMENSION,
              PERIOD_DATE
        from    bis_user_attributes
        where   schedule_id = pScheduleId
        and     attribute_name in (vAttributeCodeTable(i),
                                 vAttributeCodeTable(i)||'_FROM',
                                 vAttributeCodeTable(i)||'_TO');

    end if;
    if vAttributeCodeTable(i) <> 'BIS_P_ASOF_DATE' then
    if vDimensionTable(i) = vOldDimension then
       goto endLoop;
    else
     if pScheduleId is null then
       insert into bis_user_attributes (USER_ID,
                                      FUNCTION_NAME,
                                      SESSION_ID,
                                      SESSION_VALUE,
                                      SESSION_DESCRIPTION,
                                      ATTRIBUTE_NAME,
                                      DIMENSION,
                                      PERIOD_DATE)
        select  USER_ID,
              pFunctionName,
              SESSION_ID,
              SESSION_VALUE,
              SESSION_DESCRIPTION,
              ATTRIBUTE_NAME,
              DIMENSION,
              PERIOD_DATE
        from    bis_user_attributes
        where   function_name = pPreFunctionName
        and     attribute_name = vDimensionTable(i)||'_HIERARCHY'
        and     session_id = pSessionId
        and     user_id = pUserId;
     else
       -- if drilling into itself, there is a possibility that this parameter has not been
       --deleted from the current session
       --IF (pFunctionName == pPreFunctionName) THEN
         DELETE FROM bis_user_attributes
         WHERE session_id =pSessionId
         AND function_name = pFunctionName
         AND schedule_id IS NULL
         AND user_id=pUserId
         AND attribute_name = vDimensionTable(i)||'_HIERARCHY';
       --END IF;

       insert into bis_user_attributes (USER_ID,
                                      FUNCTION_NAME,
                                      SESSION_ID,
                                      SESSION_VALUE,
                                      SESSION_DESCRIPTION,
                                      ATTRIBUTE_NAME,
                                      DIMENSION,
                                      PERIOD_DATE)
        select  pUserId,
              pFunctionName,
              pSessionId,
              SESSION_VALUE,
              SESSION_DESCRIPTION,
              ATTRIBUTE_NAME,
              DIMENSION,
              PERIOD_DATE
        from    bis_user_attributes
        where   schedule_id = pScheduleId
        and     attribute_name = vDimensionTable(i)||'_HIERARCHY';

     end if;
    end if;
     vOldDimension := vDimensionTable(i);
    end if;
     <<endLoop>>
     null;
 end loop;
end if;


-- only copy those default parameters which were not copied from the driver function
-- if drilling into the same report, should have all the reqd attributes.
IF (pFunctionName <> pPreFunctionName  OR pPreFunctionName IS NULL) THEN
 -- First copy the default parameters for this report.
  BIS_PMV_PARAMETERS_PVT.COPY_REMAINING_DEF_PARAMETERS
  (pFunctionName     => pFunctionName
  ,pUserId           => pUserId
  ,pSessionId        => pSessionId
  ,x_return_status   => l_return_status
  ,x_msg_count       => l_msg_count
  ,x_msg_data        => l_msg_data
  );

  -- serao- 08/23/2002- bug 2514044 - copy form function parameters
  BIS_PMV_PARAMETERS_PVT.COPY_FORM_FUNCTION_PARAMETERS
                                        (pRegionCode => pRegionCode
                                        ,pFunctionName => pFunctionName
                                        ,pUserId => pUserId
                                        ,pSessionId => pSessionId
                                        ,pResponsibilityId =>  nvl(pRespId, icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID))
                                        ,x_return_status=>l_return_status
                                        ,x_msg_count=> l_msg_count
                                        ,x_msg_data=>l_msg_data
                                          );
   --Fix for 2594996
   IF getViewBy%ISOPEN THEN
      close getViewBy;
   END IF;
   OPEN getViewBy(pUserId, pSessionId);
   FETCH getViewBy INTO lViewByValue;
   CLOSE getViewBy;
   IF (lViewByValue is not null) THEN
    lViewByDimension := substr(lViewByValue ,1,instr(lViewByValue ,'+')-1) ;
    IF (lViewByDimension = 'TIME' OR lViewByDimension = 'EDW_TIME_M') THEN
       IF getTimeAttribute%ISOPEN THEN
          close getTimeAttribute;
       END IF;
       OPEN  getTimeAttribute(pUserId, pSessionId);
       FETCH getTimeAttribute into lTimeDimLevel;
       CLOSE getTimeAttribute;
       IF ( lTimeDimLevel is not null ) THEN
          IF ( instr(lTimeDimLevel,'_FROM') > 1 ) THEN
            lTimeDimLevels := substr( lTimeDimLevel ,1,instr( lTimeDimLevel ,'_FROM')-1);
          ELSIF ( instr(lTimeDimLevel,'_TO') > 1 ) THEN
            lTimeDimLevels := substr( lTimeDimLevel ,1,instr( lTimeDimLevel ,'_TO')-1);
          END IF;

          DELETE FROM bis_user_attributes where session_id= pSessionId AND function_name= pFunctionName
          AND schedule_id is null
          AND user_id=pUserId
          AND attribute_name = 'VIEW_BY';

          INSERT INTO BIS_USER_ATTRIBUTES (user_id, function_name,
                                      session_id, attribute_name,
                                      session_value,
                                      dimension,
                                      creation_date, created_by,
                                      last_update_Date, last_updated_by)
                              VALUES (pUserId, pFunctionName,
                                      pSessionId, 'VIEW_BY' ,
                                      lTimeDimLevels,
                                      lViewByDimension,
                                      sysdate, -1, sysdate, -1);
       END IF;
    END IF;
   END IF;
   --End of Fix for 2594996

END IF;


commit;

exception when others then
    IF getViewBy%ISOPEN THEN
      close getViewBy;
   END IF;
   IF getTimeAttribute%ISOPEN THEN
       close getTimeAttribute;
   END IF;
end copyParameters;

END BIS_PMV_DRILL_PVT;

/
