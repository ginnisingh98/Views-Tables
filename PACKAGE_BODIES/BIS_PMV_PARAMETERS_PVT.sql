--------------------------------------------------------
--  DDL for Package Body BIS_PMV_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_PARAMETERS_PVT" as
/* $Header: BISVPARB.pls 120.5 2006/03/27 12:54:18 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.155=120.5):~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVPARB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This is the Query Pkg. for PMV.									                  |
REM |                                                                       |
REM | HISTORY                                                               |
REM | serao, 08/23/2002, bug 2514044 - get name value pairs from pUsrStrng  |
REM |                                  of the form : 						            |
REM |                                    pRegionCode=POA_DBI_POP_CA_STATUS& |
REM |                                    VIEW_BY=SUPPLIER+POA_SUPPLIERS		  |
REM |                                                      									|
REM | ansingh, 02/09/2002, bug 2537114 - In getLOVSQL() while constructing  |
REM |     						             where clause take care of the condition  |
REM |						                   org='All'. In getTimeLovSql() fixed upper|
REM |							                 comparision issue and query issue.  	    |
REM | ansingh, 7/11/2002 Bug 2577374 - PMV To handle the Unassigned values  |
REM | nbarik,  23/10/2002 Bug Fix 2616851,null check for mandatory parameter|
REM | ansingh, 11/11/2002 BugFix#2641735, LOV Performance Fix.              |
REM | nkishore,10/12/2002 Added copy_ses_to_def_parameters                  |
REM | ansingh, 01/23/2003 BugFix#2763217                                    |
REM | nbarik   03/17/2003 Bug Fix 2844149 - Added date format for to_date   |
REM | ansingh  04/22/2003 BugFix#2887200                                    |
REM | nbarik   05/05/2003 Bug Fix 2691199 - use p_where_clause              |
REM | nbarik   05/13/2003 Bug Fix 2955560 - add an enclosing parentheses    |
REM | kiprabha 05/22/2003 Enh 2885430  - DIMENSION VALUE    |
REM | rcmuthuk 06/16/2003 Bug Fix 2998426  - Prepend % for Time LOV Search  |
REM | nbarik   07/10/2003 Bug Fix 2999602 - Change Call to GET_COMPUTED_DATE|
REM | nkishore 07/30/2003 Bug Fix 3074842 - ins/del duplicate dim levels    |
REM | nkishore 08/11/2003 Bug Fix 3087383 - copy time from/to,sysdate in copy_form_func |
REM | nkishore, 19/08/2003, BugFix 3099789 add copy_time_params	    	    |
REM | nbarik    10/21/03  Bug Fix 3201277                                   |
REM | nkishore  12/19/03  Bug Fix 3314027                                   |
REM | ksadagop  01/20/04  Bug Fix 3351910 Added LOV Where clause-drillAcross|
REM | nkishore  12/19/03  Bug Fix 3411456                                   |
REM | nbarik    02/19/04  Bug Fix 3441967                                   |
REM | nkishore  02/25/04  Bug Fix 3464708                                   |
REM | ashgarg   10/21/04  Bug Fix 3878112                                   |
REM +=======================================================================+
*/

MAX_BIND_VARIABLE_COUNT NUMBER := 20;

/** Flattens the attrNameList for dimension and paramNumber into the xParameterTbl structure */
-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation - Added pLovWhereList
PROCEDURE addToList(
  pDImension IN VARCHAR2,
  pAttrNameList IN BISVIEWER.t_char,
  pLovWhereList IN BISVIEWER.t_char,

  pParamNumber In NUMBER,
  xParameterTbl IN OUT NOCOPY parameter_group_tbl_type
) IS
 lCount NUMBER;
 lParamGrpRec parameter_group_rec_type;
BEGIN

 IF (xParameterTbl IS NOT NULL) THEN
  lCOunt := xParameterTbl.COUNT;

  IF (pAttrNameList IS NOT NULL AND pAttrNameList.COUNT > 0) THEN

    FOR i IN pAttrNameList.FIRST..pAttrNameList.LAST LOOP
      lParamGrpRec.dimension := pDimension;
      lParamGrpRec.attribute_name := pAttrNameList(i);
      --jprabhud - Bug 	3625068
      IF (pLovWhereList IS NOT NULL AND pLovWhereList.COUNT > 0) THEN
        lParamGrpRec.lov_where := pLovWhereList(i);
      ELSE
        lParamGrpRec.lov_where := null;
      END IF;

      lParamGrpRec.parameter_number := pParamNumber;
      xParameterTbl(lCOunt+i) := lParamGrpRec; --i starts with 1, therefore count+i should suffice
    END LOOP;

  ELSE
      lParamGrpRec.dimension := NULL;
      lParamGrpRec.attribute_name := pDimension;
      lParamGrpRec.parameter_number := pParamNumber;
      xParameterTbl(lCOunt+1) := lParamGrpRec;
      lParamGrpRec.lov_where := NULL;
  END IF;

 END IF;
END addToList;

/* Proc to will group all the parameters into the parameter_group_tbl_type datastructure */
-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation - Added pLovWhereTbl
PROCEDURE getParameterGroupForLists(
  pAttribute2Tbl BISVIEWER.t_char
  ,pAttribCodeTbl BISVIEWER.t_char
  ,pDisplaySeqTbl BISVIEWER.t_num
  ,pLovWhereTbl BISVIEWER.t_char
  ,xParameterGroup IN OUT NOCOPY parameter_group_tbl_type
  ,xAsOfDateExists OUT NOCOPY BOOLEAN
  ,xTimeCompTypeExists OUT NOCOPY BOOLEAN
)IS
    lParamGrpRec parameter_group_rec_type;
    lAttrNameList BISVIEWER.t_char;
    lLovWhereList BISVIEWER.t_char;
    l_index BINARY_INTEGER := 1;
    l_grp_index BINARY_INTEGER := 1;
    lPrevDimension VARCHAR2(80);
    lDimension VARCHAR2(80);
    lPrevDisplaySequence NUMBER ;
BEGIN

   xTimeCompTypeExists := FALSE;
   xAsOfDateExists := FALSE;

   lPrevDimension := null;
   lDimension := null;
   -- get the latest count
   l_grp_index := xParameterGroup.COUNT+1;

   IF pAttribute2Tbl IS NOT NULL AND pAttribute2Tbl.COUNT >0 THEN
      FOR i IN pAttribute2Tbl.FIRST..pAttribute2Tbl.LAST LOOP

        lDimension := pAttribute2Tbl(i);
        lDimension := substr( lDimension ,1,instr(lDimension ,'+')-1 );

        IF (lDimension = 'TIME_COMPARISON_TYPE') THEN
          xTimeCompTypeExists := TRUE;
        END IF;

        IF (lDimension IS NULL) THEN

          --put the prev dimension stuff in
          IF (lPrevDimension IS NOT NULL) THEN

            addToList(
                pDImension => lPrevDimension,
                pAttrNameList => lAttrNameList,
                pLovWhereList => lLovWhereList,
                pParamNumber => l_grp_index,
                xParameterTbl => xParameterGroup
            );
            l_grp_index := l_grp_index+1;
          END IF;

            --reinitailise record for the next dimension
            lParamGrpRec.dimension := NULL;
            l_index := 1;
            lAttrNameList.DELETE;
            lLovWHereList.DELETE;

            --add this non-attr record
            lAttrNameList(l_index) := pAttribCodeTbl(i);
            lLovWhereList(l_index) := pLovWhereTbl(i);

            addToList(
                pDImension => pAttribCodeTbl(i),
                pAttrNameList => lAttrNameList,
                pLovWhereList => lLovWhereList,
                pParamNumber => l_grp_index,
                xParameterTbl => xParameterGroup
            );
            l_grp_index := l_grp_index+1;

            IF (pAttribCodeTbl(i) = 'AS_OF_DATE') THEN
              xAsOfDateExists := TRUE;
            END IF;

            --reinitailise record for the next dimension
            lParamGrpRec.dimension := NULL;
            l_index := 1;
            lAttrNameList.DELETE;
            lLovWhereList.DELETE;

            lPrevDimension := lDimension;
            lPrevDisplaySequence  := pDisplaySeqTbl(i);

        ELSIF (pDisplaySeqTbl (i) < 10000) THEN          --diff rules for less than 10000
          --store the display sequence
          lPrevDisplaySequence  := pDisplaySeqTbl(i);

          --if this is not a dimension or the current dimenion is not the prev dimension, then
          -- they do not belong to the same group
          -- if the prev dimension was a non-dimension, then it will go inside loop
          IF  NOT (lDimension = lPrevDimension) THEN

            IF (lPrevDimension IS NOT NULL) THEN
              -- new group

              addToList(
                pDImension => lPrevDimension,
                pAttrNameList => lAttrNameList,
                pLovWhereList => lLovWhereList,
                pParamNumber => l_grp_index,
                xParameterTbl => xParameterGroup
              );
              l_grp_index := l_grp_index+1;
            END IF;

            --reinitailise record for the next dimension
            lParamGrpRec.dimension := NULL;
            l_index := 1;
            lAttrNameList.DELETE;
            lLovWhereList.DELETE;

            --settings for the new record
            lAttrNameList(l_index) := pAttribute2Tbl(i);
            lLovWhereList(l_index) := pLovWhereTbl(i);
            l_index := l_index+1;
            lPrevDimension := lDimension;

          ELSE-- if dimension is not null and equal to prev dim
              --add the attribute name to the table for this dimension
              lAttrNameList(l_index) := pAttribute2Tbl(i);
              lLovWhereList(l_index) := pLovWhereTbl(i);
              l_index := l_index+1;
              lPrevDimension := lDimension;
          END IF;

        ELSE -- if disp seq >= 10000

          IF ( (lPrevDisplaySequence < 10000) OR                   --if prev Dimension < 10000
               (pDisplaySeqTbl(i) - lPrevDisplaySequence > 1) OR -- display seq is not conscutive after 10000
               NOT(lPrevDimension =lDimension) OR                     -- the dimensions are different even if they are consecutive
               (lPrevDisplaySequence IS NULL) --first variable has disp seq >10000
            )THEN

            -- then this is a new parameter, so save the previous dimension

            addToList(
                pDImension => lPrevDimension,
                pAttrNameList => lAttrNameList,
                pLovWhereList => lLovWhereList,
                pParamNumber => l_grp_index,
                xParameterTbl => xParameterGroup
              );
            l_grp_index := l_grp_index+1;

            --reinitailise record for the next dimension
            lParamGrpRec.dimension := NULL;
            l_index := 1;
            lAttrNameList.DELETE;
            lLovWhereList.DELETE;

            --settings for the new record
            lAttrNameList(l_index) := pAttribute2Tbl(i);
            lLovWhereList(l_index) := pLovWhereTbl(i);
            l_index := l_index+1;
            lPrevDimension := lDimension;
            lPrevDisplaySequence  := pDisplaySeqTbl(i);

          ELSIF (pDisplaySeqTbl(i) - lPrevDisplaySequence = 1 AND lPrevDimension=lDimension ) THEN
            -- add to the list of attributes
            lAttrNameList(l_index) := pAttribute2Tbl(i);
            lLovWhereList(l_index) := pLovWhereTbl(i);
            l_index := l_index+1;
            lPrevDimension := lDimension;
            lPrevDisplaySequence  := pDisplaySeqTbl(i);
          END IF;

        END IF; -- if disp seq

          -- the last element of this loop
          IF (i = pAttribute2Tbl.LAST ) THEN

            addToList(
                pDImension => lPrevDimension,
                pAttrNameList => lAttrNameList,
                pLovWhereList => lLovWhereList,
                pParamNumber => l_grp_index,
                xParameterTbl => xParameterGroup
              );
          END IF;

      END LOOP; -- nested attr code
   END IF; -- if nested attr code

END;

/* Proc to generate the xParameterGroup structure for the gievn region code*/
PROCEDURE getParameterGroupsForRegion(
  pRegionCode IN VARCHAR2,
  xParameterGroup OUT NOCOPY parameter_group_tbl_type,
  xTCTExists OUT NOCOPY BOOLEAN,
  xNestedRegion OUT NOCOPY VARCHAR2,
  xAsofDateExists OUT NOCOPY BOOLEAN
  ) IS
 /* Assumption: When there is a nested region, then for the shared dimensions, the parameters
    for grouping come from the nested region. Else they come from the default region
 */
    lNestedRegionCode VARCHAR2(80);
    lDimensionTable BISVIEWER.t_char;
    ldef_attr2_table BISVIEWER.t_char;
    ldef_attr_code_table BISVIEWER.t_char;
    ldef_disp_seq BISVIEWER.t_num;
    lLov_where_table BISVIEWER.t_char;

    lParamGrpRec parameter_group_rec_type;
    lAttrNameList BISVIEWER.t_char;
    lLovWhereList BISVIEWER.t_char;
    l_index BINARY_INTEGER := 1;
    l_grp_index BINARY_INTEGER := 1;
    lAsOfDateExists BOOLEAN;
    lTCTExists BOOLEAN;
    l_next_param_number NUMBER;
    --ashgarg Bug 3878112:  get Data Source
    lDataSource VARCHAR2(150);
    l_region_code VARCHAR2(30);

    cursor getNestedRegionCode (cpRegionCode varchar2) is
     SELECT nested_region_code
     FROM ak_region_items
     WHERE region_code = cpRegionCode
    AND nested_region_code IS NOT NULL;
   --ashgarg Bug 3878112:  get Data Source
    cursor getDataSource (cpRegionCode varchar2) is
    SELECT attribute10 FROM
    ak_regions where region_code = cpRegionCode;

    --first get the parameters that do not share dimensions/attribute code with the nested region
BEGIN

  --get the nested region
   if getNestedRegionCode%ISOPEN then
      close getNestedRegionCode;
   end if;
   open getNestedRegionCode(pRegionCode);
   fetch getNestedRegionCode INTO lNestedRegionCode;
   close getNestedRegionCode;
 --ashgarg Bug 3878112:  get Data Source
   if getDataSource%ISOPEN then
      close getDataSource;
   end if;
   open getDataSource(pRegionCode);
   fetch getDataSource INTO lDataSource;
   close getDataSource;

      xNestedRegion := lNestedRegionCode;



   /* As per discussion with Amod, all the parameters in the nested region need
      to be defined in the report region as well.  This is except for the AS_OF_DATE
      and the TIME_COMPARISON_TYPE parameters.  Amod suggested that the check for these 2 be dealt with
      seperately rather than adding them to the thr grouping here */
    -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
    --ashgarg Bug 3878112:  For bsc data source
     IF (lDataSource = 'BSC_DATA_SOURCE' ) THEN
        if (lNestedRegionCode <> null) then
              l_region_code := lNestedRegionCode;
        else
              l_region_code := pRegionCode;
        end if;
      END IF;

      if (l_region_code is null) then
         l_region_code := pRegionCode;
      end if;

      SELECT attribute2, attribute_code, display_sequence, attribute4
      BULK COLLECT INTO ldef_attr2_table, ldef_attr_code_table, lDef_disp_seq, lLov_where_table
      FROM ak_region_items
      WHERE region_code = l_region_code -- pRegionCode
      AND NODE_QUERY_FLAG = 'Y'
      ORDER BY DISPLAY_SEQUENCE;

  /* Debug */
  /*
   IF ldef_attr2_table IS NOT NULL AND ldef_attr2_table.COUNT >0 THEN
    FOR i In ldef_attr2_table.FIRST..ldef_attr2_table.LAST LOOP
        dbms_output.put_line(' default dim '||ldef_attr2_table(i) || ' disp seq '|| lDef_disp_seq(i));
    END LOOP;
   END IF;
   */
   /* Debug */

   --consolidate all the lists into the data struture

    IF (ldef_attr_code_table IS NOT NULL AND ldef_attr_code_table.COUNT > 0) THEN
      getParameterGroupForLists(
          pAttribute2Tbl => ldef_attr2_table
          ,pAttribCodeTbl => ldef_attr_code_table
          ,pDisplaySeqTbl => lDef_disp_seq
          , pLovWhereTbl => lLov_where_table
          ,xParameterGroup => xParameterGroup
          ,xAsOfDateExists => lAsOfDateExists
          ,xTimeCompTypeExists => lTCTExists
      );
    END IF;
    xTCTExists := lTCTExists;

    l_grp_index := xParameterGroup.COUNT+1;
    l_next_param_number := xParameterGroup(xParameterGroup.COUNT).parameter_number+1;

    --adding TCT and as-of-date explicitly to avoid an extra select for the nested region
    --add the as-of-date if it does not exist in the report region
    IF ( lNestedRegionCode IS NOT NULL AND NOT(lAsOfDateExists) ) THEN

      lAttrNameList.DELETE;
      lAttrNameList(1) := 'AS_OF_DATE';
      lLovWhereList.DELETE;
      --jprabhud - Bug 	3625068 - When drilling from KPI/RELATED/DRILL - if As of date is not present
      --in default FF defn or in Report metadata it comes here and fails as lLovWhereList is being deleted
      lLovWhereList(1) := null;

      addToList(
                pDImension => 'AS_OF_DATE',
                pAttrNameList => lAttrNameList,
                pLovWhereList => lLovWhereList,
                pParamNumber => l_next_param_number,
                xParameterTbl => xParameterGroup
      );
      lAsofDateExists := true;
      l_grp_index := l_grp_index+1;
      l_next_param_number := l_next_param_number+1;
    END IF;
    xAsofDateExists := lAsofDateExists;

/* aleung, 7/16/03, if TCT is not defined in report region, TCT is hardcoded to 'TIME_COMPARISON_TYPE+SEQUENTIAL' for bug 2965660
    --add the TCT if it does not exist in the report region
    IF (lNestedRegionCode IS NOT NULL AND NOT(lTCTExists)) THEN

      lAttrNameList.DELETE;
      lAttrNameList(1) := 'TIME_COMPARISON_TYPE+YEARLY';
      lAttrNameList(2) := 'TIME_COMPARISON_TYPE+SEQUENTIAL';
      lAttrNameList(3) := 'TIME_COMPARISON_TYPE+BUDGET';
      addToList(
                pDImension => 'TIME_COMPARISON_TYPE',
                pAttrNameList => lAttrNameList,
                pParamNumber => l_next_param_number,
                xParameterTbl => xParameterGroup
      );
      l_grp_index := l_grp_index+1;

    END IF;
*/

 /* Fix for bug 2739892 */
 /* Added Exception block */
 EXCEPTION
	WHEN OTHERS THEN
		null ;


END getParameterGroupsForRegion;

/* Returns those attribute_names which share the pParamNum by looking into the pParameterGroup
    in the reverse order.  When a diff param num is encouneterd, we have gone past this group
   */
PROCEDURE getPrevParamsWithParamNumber(
  pParamNumber IN NUMBER,
  pDimension IN VARCHAR2,
  pIndex In NUMBER,
  pParameterGroup IN parameter_group_tbl_type,
  xAttributeNameList OUT NOCOPY BISVIEWER.t_char
) IS
 lCount NUMBER := 1;
BEGIN

  -- no check being done on the dimension since this the parameter numbers should be unique.
  IF pParameterGroup IS NOT NULL AND pParameterGroup.COUNT >0 THEN
    lCount := xAttributeNameList.COUNT+1;

    FOR i IN REVERSE pParameterGroup.FIRST..pIndex LOOP
      IF (pParameterGroup(i).parameter_number = pParamNumber) THEN
        xAttributeNameList(lCount) := pParameterGroup(i).attribute_name;
        lCount := lCount+1;
      ELSE
        RETURN;
      END IF;
    END LOOP;

  END IF;
END getPrevParamsWithParamNumber;

/* Returns those attribute_names which share the pParamNum by looking into the pParameterGroup
  in the order.  When a diff param num is encouneterd, we have gone past this group
   */
PROCEDURE getLaterParamsWithParamNumber(
  pParamNumber IN NUMBER,
  pDimension IN VARCHAR2,
  pIndex In NUMBER,
  pParameterGroup IN parameter_group_tbl_type,
  xAttributeNameList IN OUT NOCOPY BISVIEWER.t_char
) IS
 lCount NUMBER := 1;
BEGIN

  -- no check being done on the dimension since this the parameter numbers should be unique.
  IF pParameterGroup IS NOT NULL AND pParameterGroup.COUNT >0 THEN
    lCount := xAttributeNameList.COUNT+1;

    FOR i IN pIndex..pParameterGroup.LAST LOOP
      IF (pParameterGroup(i).parameter_number = pParamNumber) THEN
        xAttributeNameList(lCount) := pParameterGroup(i).attribute_name;
        lCount := lCount+1;
      ELSE
        RETURN;
      END IF;
    END LOOP;

  END IF;
END getLaterParamsWithParamNumber;

/* Returns those attribute_names which share the pParamNum by looking into the pParameterGroup
  in the order.
   */
PROCEDURE getParametersWithParamNumber(
  pParamNumber IN NUMBER,
  pDimension IN VARCHAR2,
  pParameterGroup IN parameter_group_tbl_type,
  xAttributeNameList IN OUT NOCOPY BISVIEWER.t_char
) IS
 --lAttrNameList BISVIEWER.t_char;
 lCount NUMBER := 1;
BEGIN

  -- no check being done on the dimension since this the parameter numbers should be unique.
  IF pParameterGroup IS NOT NULL AND pParameterGroup.COUNT >0 THEN
    FOR i IN pParameterGroup.FIRST..pParameterGroup.LAST LOOP
      IF (pParameterGroup(i).parameter_number = pParamNumber) THEN
        xAttributeNameList(lCount) := pParameterGroup(i).attribute_name;
        lCount := lCount+1;
      END IF;
    END LOOP;
  END IF;
END getParametersWithParamNumber;

/* Given a attribute_name and dimension, return all posible attribute names this group could have */
PROCEDURE getAttrNamesInSameGroup (
 pAttributeName IN VARCHAR2,
 pDimension IN VARCHAR2,
 pParameterGroup IN parameter_group_tbl_type,
 xAttNameList OUT NOCOPY BISVIEWER.t_char
) IS
  lAttrNameList BISVIEWER.t_char;
  lAttributeName VARCHAR2(80) := pAttributeName;
BEGIN

  IF pParameterGroup IS NOT NULL AND pParameterGroup.COUNT > 0 THEN
    FOR i IN pParameterGroup.FIRST..pParameterGroup.LAST LOOP
      IF (pDimension IS NOT NULL) THEN

        IF (pDimension = 'TIME' OR pDimension='EDW_TIME_M') THEN

              --there will be a _To and _from which needs to vb eremoved
              IF(instr(lAttributeName,'_FROM',1,1) > 0 AND instr(lAttributeName,'+',1,1) > 0) then
                lAttributeName := substr(lAttributeName,1,instr(lAttributeName,'_FROM')-1);
              END IF;

              IF(instr(lAttributeName,'_TO',1,1) > 0 AND instr(lAttributeName,'+',1,1) > 0) then
                lAttributeName := substr(lAttributeName,1,instr(lAttributeName,'_TO')-1);
              END IF;

          END IF;
                --BugFix 3074842--Include Duplicate Dimension Levels--Attribute2+Attribute Code
        IF (pDimension =pParameterGroup(i).dimension AND
            (pParameterGroup(i).attribute_name = lAttributeName  OR
             pParameterGroup(i).attribute_name = substr(lAttributeName, 1, instr(lAttributeName, '+',-1)-1) )) THEN

          --return all the attribute names with that parameter number
          /*
          getParametersWithParamNumber(
            pParamNumber => pParameterGroup(i).parameter_number ,
            pDimension => pParameterGroup(i).dimension,
            pParameterGroup => pParameterGroup,
            xAttributeNameList => xAttNameList
          );*/
            getPrevParamsWithParamNumber(
              pParamNumber => pParameterGroup(i).parameter_number ,
              pDimension => pParameterGroup(i).dimension,
              pIndex => i,
              pParameterGroup => pParameterGroup,
              xAttributeNameList => xAttNameList
            ) ;
            getLaterParamsWithParamNumber(
              pParamNumber => pParameterGroup(i).parameter_number ,
              pDimension => pParameterGroup(i).dimension,
              pIndex => i+1,
              pParameterGroup => pParameterGroup,
              xAttributeNameList => xAttNameList
            ) ;
          RETURN;

        END IF; --pDimension=
      ELSE
        IF (lAttributeName = pParameterGroup(i).attribute_name) THEN

          lAttrNameList(1) := pParameterGroup(i).attribute_name;
          xAttNameList := lAttrNameList;
          RETURN;
        END IF;

      END IF; --pDimension is not null
    END LOOP;
  END IF;
END getAttrNamesInSameGroup ;

/* Retuns if this dimension is present in the pParameterGroup*/
FUNCTION IsdimensionInParamGrp(
 pDimension IN VARCHAR2,
 pParameterGroup IN parameter_group_tbl_type
) RETURN BOOLEAN
IS
BEGIN
  IF pParameterGroup IS NOT NULL AND pParameterGroup.COUNT > 0 THEN
    FOR i IN pParameterGroup.FIRST..pParameterGroup.LAST LOOP
      IF (pDimension =pParameterGroup(i).dimension) THEN
        RETURN TRUE;
      END IF;
    END LOOP;
  END IF;

  RETURN FALSE;

END IsdimensionInParamGrp ;

PROCEDURE bulkDeleteFromSession(
 pSessionId          in varchar2,
 pUserId             in varchar2,
 pFunctionName       in varchar2,
  pAttributeNameTbl IN BISVIEWER.t_char
) IS
BEGIN
	-- FIX FOR P1 2797318 : kiprabha
	-- DELETE ONLY IF SCHEDULE_ID IS NULL
  IF pAttributeNameTbl IS NOT NULL AND pAttributeNameTbl.COUNT >0 THEN
    FORALL i IN pAttributeNameTbl.FIRST..pAttributeNameTbl.LAST
      DELETE FROM bis_user_attributes
      WHERE function_name=pFunctionName
      AND session_id = pSessionId
      AND user_id = pUserId
      AND attribute_name = pAttributeNameTbl(i)
      AND schedule_id is null ;

  END IF;
END bulkDeleteFromSession;

PROCEDURE bulkInsertIntoSession(
 pSessionId          in varchar2,
 pUserId             in varchar2,
 pFunctionName       in varchar2,
  pAttributeNameTbl IN BISVIEWER.t_char,
  pDimensionTbl IN BISVIEWER.t_char,
  pSessionValueTbl IN BISVIEWER.t_char,
  pSessionDescTbl IN BISVIEWER.t_char,
  pPeriodDateTbl IN BISVIEWER.t_date
) IS
BEGIN
  IF pAttributeNameTbl IS NOT NULL AND pAttributeNameTbl.COUNT >0 THEN
     FORALL i IN pAttributeNameTbl.FIRST..pAttributeNameTbl.LAST
            insert into bis_user_attributes (USER_ID,
                                      FUNCTION_NAME,
                                      SESSION_ID,
                                      SESSION_VALUE,
                                      SESSION_DESCRIPTION,
                                      ATTRIBUTE_NAME,
                                      DIMENSION,
                                      PERIOD_DATE
                                      )VALUES (
                                        pUserId,
                                        pFunctionName,
                                        pSessionId,
                                        pSessionValueTbl(i),
                                        pSessionDescTbl(i),
                                        pAttributeNameTbl(i),
                                        pDimensionTbl(i),
                                        pPeriodDateTbl(i)
                                      );
   END IF;
END bulkInsertIntoSession;

PROCEDURE bulkDeleteFromPage(
 pPAgeId         in VARCHAR2,
 pUserId             in VARCHAR2,
 pFunctionName IN VARCHAR2,
  pAttributeNameTbl IN BISVIEWER.t_char
) IS
BEGIN
  IF pAttributeNameTbl IS NOT NULL AND pAttributeNameTbl.COUNT >0 THEN

    FORALL i IN pAttributeNameTbl.FIRST..pAttributeNameTbl.LAST
      DELETE FROM bis_user_attributes
      WHERE page_id = pPageId
      AND user_id = pUserId
      AND function_name = pFunctionName
      AND attribute_name = pAttributeNameTbl(i);

  END IF;
END bulkDeleteFromPage;

PROCEDURE getDeleteAtttrList(
 pAttrNameList IN BISVIEWER.t_char,
 pDimension IN VARCHAR2,
 xAttrNameList OUT NOCOPY BISVIEWER.t_char
) IS
l_index NUMBER := 1;
BEGIN
    IF (pAttrNameList IS NOT NULL AND pAttrNameList.COUNT > 0) THEN
      FOR i IN pAttrNameList.FIRST..pAttrNameList.LAST LOOP

          IF (pDimension IS NOT NULL) THEN

            xAttrNameList(l_index) := pAttrNameList(i);
            l_index := l_index+1;
            xAttrNameList(l_index) := pDimension||'_HIERARCHY';
            l_index := l_index+1;

            IF (pDimension = 'TIME' OR pDimension='EDW_TIME_M') THEN
              xAttrNameList(l_index) := pAttrNameList(i)||'_TO';
              l_index := l_index+1;
              xAttrNameList(l_index) := pAttrNameList(i)||'_FROM';
              l_index := l_index+1;
            END IF;

         ELSE
            xAttrNameList(l_index) := pAttrNameList(i);
            l_index := l_index+1;
         END IF;

       END LOOP;
    END IF;
END getDeleteAtttrList;

/* Procedure to delete those parameters from session that belong to the same grp and hence have the
  same attribute name as the  attribute name present in the attrNameList table.*/
PROCEDURE deletePageForGroup(
 pUserId             in varchar2,
 pFunctionName       in varchar2,
 pPageId             in varchar2,
 pAttrNameList IN BISVIEWER.t_char,
 pDimension IN VARCHAR2
) IS
lAttrNameList BISVIEWER.t_char;

BEGIN

  getDeleteAtttrList(
   pAttrNameList => pAttrNameList,
    pDimension =>  pDimension ,
   xAttrNameList => lAttrNameList
  );

    IF (lAttrNameList IS NOT NULL AND lAttrNameList.COUNT >0) THEN
          bulkDeleteFromPage(
              pPageId  => pPageId,
              pUserId     => pUserId,
              pFunctionName   => pFunctionName,
              pAttributeNameTbl => lAttrNameList
          ) ;
  END IF;

END deletePageForGroup;

/* Procedure to delete those parameters from session that belong to the same grp and hence have the
  same attribute name as the  attribute name present in the attrNameList table.*/
PROCEDURE deleteSessionForGroup(
 pSessionId          in varchar2,
 pUserId             in varchar2,
 pFunctionName       in varchar2,
 pAttrNameList IN BISVIEWER.t_char,
 pDimension IN VARCHAR2
) IS
lAttrNameList BISVIEWER.t_char;

BEGIN

  getDeleteAtttrList(
   pAttrNameList => pAttrNameList,
    pDimension =>  pDimension ,
   xAttrNameList => lAttrNameList
  );

    IF (lAttrNameList IS NOT NULL AND lAttrNameList.COUNT >0) THEN
            bulkDeleteFromSession(
               pSessionId  => pSessionId,
               pUserId     => pUserId,
               pFunctionName   => pFunctionName,
               pAttributeNameTbl => lAttrNameList
              ) ;
  END IF;


END deleteSessionForGroup;

/* This will sent the  parameters to be deleted and corresponding parameters to be inserted for the same group as
pAttributeNameTbl  being sent in. - these can then be deleted or inserted into session/page etc.*/
PROCEDURE getDeleteAndInsertTables(
  pUserId             in varchar2,
  pAttributeNameTbl IN BISVIEWER.t_char,
  pDimensionTbl IN BISVIEWER.t_char,
  pSessionValueTbl IN BISVIEWER.t_char,
  pSessionDescTbl IN BISVIEWER.t_char,
  pPeriodDateTbl IN BISVIEWER.t_date,
  pParameterGroup IN parameter_group_tbl_type,
  pIncludeViewBy IN BOOLEAN DEFAULT FALSE,
  pIncludeBusinessPlan IN BOOLEAN DEFAULT FALSE,
  pIncludePrevAsOfDate IN BOOLEAN DEFAULT FALSE,
  xAttrNameForInsert OUT NOCOPY BISVIEWER.t_char,
  xDimensionForInsert OUT NOCOPY BISVIEWER.t_char,
  xSessValueForInsert OUT NOCOPY BISVIEWER.t_char,
  xSessDescForInsert OUT NOCOPY BISVIEWER.t_char,
  xPeriodDateForInsert OUT NOCOPY BISVIEWER.t_date,
  xAttrNameForDelete OUT NOCOPY BISVIEWER.t_char
) IS
  lAttrNameList BISVIEWER.t_char;
  insert_index NUMBER :=1;

  delete_index NUMBER :=1;
BEGIN

  -- for each attribute in the list sent
  IF pAttributeNameTbl IS NOT NULL AND pAttributeNameTbl.COUNT >0 THEN
    FOR i IN pAttributeNameTbl.FIRST..pAttributeNameTbl.LAST LOOP

          --get the group of attribute_names for this group
         getAttrNamesInSameGroup (
             pAttributeName => pAttributeNameTbl(i),
             pDimension => pDimensionTbl(i),
             pParameterGroup => pParameterGroup,
             xAttNameList => lAttrNameList
         );

         --lAttrNameList is the list of the attribute names that fall in the same grp as pAttributeNameTbl(i)
         -- so if there is a group for this parameter, then delete this parameter
        -- if the attrName is _hierarchy, then this list will not be returned since there is no group for it
        IF (lAttrNameList IS NOT NULL AND lAttrNameList.COUNT >0) THEN

          	FOR j IN lAttrNameList.FIRST..lAttrNameList.LAST LOOP

    	  	      xAttrNameForDelete(delete_index) := lAttrNameList(j);
          		  delete_index:= delete_index+1;
    	  	      xAttrNameForDelete(delete_index) := lAttrNameList(j)||'_TO';
          	  	delete_index:= delete_index+1;
		            xAttrNameForDelete(delete_index) := lAttrNameList(j)||'_FROM';
      	      	delete_index:= delete_index+1;
        	  END LOOP;

              --this attribute does belong to the report, so add to the list of attributes that
              --needs to be added
            xAttrNameForInsert(insert_index) := pAttributeNameTbl(i) ;
            xDimensionForInsert(insert_index) := pDimensionTbl(i) ;
            xSessValueForInsert(insert_index) := pSessionValueTbl(i);
            xSessDescForInsert(insert_index) := pSessionDescTbl(i);
            xPeriodDateForInsert(insert_index) := pPeriodDateTbl(i);
            insert_index := insert_index+1;
      --nbarik - 07/17/03 - Bug Fix 2999602 - Added BIS_PREVIOUS_EFFECTIVE_START_DATE and BIS_PREVIOUS_EFFECTIVE_END_DATE
      ELSIF ((pAttributeNameTbl(i) = 'VIEW_BY' AND pIncludeViewBy) OR
              (pAttributeNameTbl(i) = 'BUSINESS_PLAN' AND pIncludeBusinessPlan) OR
              (pAttributeNameTbl(i) = 'BIS_P_ASOF_DATE' AND pIncludePrevAsOfDate) OR
              (pAttributeNameTbl(i) = 'BIS_CUR_REPORT_START_DATE' AND pIncludePrevAsOfDate) OR
              (pAttributeNameTbl(i) = 'BIS_PREV_REPORT_START_DATE' AND pIncludePrevAsOfDate) OR
              (pAttributeNameTbl(i) = 'BIS_PREVIOUS_EFFECTIVE_START_DATE' AND pIncludePrevAsOfDate) OR
              (pAttributeNameTbl(i) = 'BIS_PREVIOUS_EFFECTIVE_END_DATE' AND pIncludePrevAsOfDate)
            ) THEN

                xAttrNameForDelete(delete_index) := pAttributeNameTbl(i) ;
                delete_index := delete_index+1;

                xAttrNameForInsert(insert_index) := pAttributeNameTbl(i) ;
                xDimensionForInsert(insert_index) := pDimensionTbl(i) ;
                xSessValueForInsert(insert_index) := pSessionValueTbl(i);
                xSessDescForInsert(insert_index) := pSessionDescTbl(i);
                xPeriodDateForInsert(insert_index) := pPeriodDateTbl(i);
                insert_index := insert_index+1;

        ELSIF (substr(pAttributeNameTbl(i), length(pAttributeNameTbl(i))-length('_HIERARCHY')+1)  ='_HIERARCHY') THEN
        -- if it ends with _hierarchy, then check if the dimension belongs to this new report and add it to the list

          -- check if the dimension for this belongs to this report, then delete and add
            IF (IsdimensionInParamGrp (
                  pDimension => pDimensionTbl(i),
                  pParameterGroup => pParameterGroup )
            ) THEN
                xAttrNameForDelete(delete_index) := pAttributeNameTbl(i) ;
                delete_index := delete_index+1;

                xAttrNameForInsert(insert_index) := pAttributeNameTbl(i) ;
                xDimensionForInsert(insert_index) := pDimensionTbl(i) ;
                xSessValueForInsert(insert_index) := pSessionValueTbl(i);
                xSessDescForInsert(insert_index) := pSessionDescTbl(i);
                xPeriodDateForInsert(insert_index) := pPeriodDateTbl(i);
                insert_index := insert_index+1;

            END IF;
        END IF; -- if lattrNameList is NOt NULL

    END LOOP;

  END IF; --lattname is null
END getDeleteAndInsertTables;

/* This will delete any parameters alreadyPresent for the same group as
pAttributeNameTbl  being sent in. - should use the getDeleteAndInsertTables later
and donly do the bulk delet and insert into session*/
PROCEDURE deleteAndInsertIntoSession(
  pSessionId          in varchar2,
  pUserId             in varchar2,
  pFunctionName       in varchar2,
  pAttributeNameTbl IN BISVIEWER.t_char,
  pDimensionTbl IN BISVIEWER.t_char,
  pSessionValueTbl IN BISVIEWER.t_char,
  pSessionDescTbl IN BISVIEWER.t_char,
  pPeriodDateTbl IN BISVIEWER.t_date,
  pParameterGroup IN parameter_group_tbl_type,
  pIncludeViewBy IN BOOLEAN DEFAULT FALSE,
  pIncludeBusinessPlan IN BOOLEAN DEFAULT FALSE,
  pIncludePrevAsOfDate IN BOOLEAN DEFAULT FALSE
) IS
  lAttrNameList BISVIEWER.t_char;
  insert_index NUMBER :=1;

  lAttrNameForInsert BISVIEWER.t_char;
  lDimensionForInsert BISVIEWER.t_char;
  lSessValueForInsert BISVIEWER.t_char;
  lSessDescForInsert BISVIEWER.t_char;
  lPeriodDateForInsert BISVIEWER.t_date;

  delete_index NUMBER :=1;
  lAttrNameForDelete BISVIEWER.t_char;
BEGIN

  -- for each attribute in the list sent
  IF pAttributeNameTbl IS NOT NULL AND pAttributeNameTbl.COUNT >0 THEN
    FOR i IN pAttributeNameTbl.FIRST..pAttributeNameTbl.LAST LOOP

          --get the group of attribute_names for this group
         getAttrNamesInSameGroup (
             pAttributeName => pAttributeNameTbl(i),
             pDimension => pDimensionTbl(i),
             pParameterGroup => pParameterGroup,
             xAttNameList => lAttrNameList
         );

         --lAttrNameList is the list of the attribute names that fall in the same grp as pAttributeNameTbl(i)
         -- so if there is a group for this parameter, then delete this parameter
        -- if the attrName is _hierarchy, then this list will not be returned since there is no group for it
        IF (lAttrNameList IS NOT NULL AND lAttrNameList.COUNT >0) THEN

          	FOR j IN lAttrNameList.FIRST..lAttrNameList.LAST LOOP
                      --BugFix 3074842
                      if(lAttrNameList(j) = substr(pAttributeNameTbl(i), 1, instr(pAttributeNameTbl(i), '+',-1)-1)) then
      	  	        lAttrNameForDelete(delete_index) := pAttributeNameTbl(i);
          		delete_index:= delete_index+1;
                      else
    	  	        lAttrNameForDelete(delete_index) := lAttrNameList(j);
          		  delete_index:= delete_index+1;
    	  	        lAttrNameForDelete(delete_index) := lAttrNameList(j)||'_TO';
          	  	  delete_index:= delete_index+1;
		        lAttrNameForDelete(delete_index) := lAttrNameList(j)||'_FROM';
      	      	          delete_index:= delete_index+1;
                     end if;
        	  END LOOP;

              --this attribute does belong to the report, so add to the list of attributes that
              --needs to be added
            lAttrNameForInsert(insert_index) := pAttributeNameTbl(i) ;
            lDimensionForInsert(insert_index) := pDimensionTbl(i) ;
            lSessValueForInsert(insert_index) := pSessionValueTbl(i);
            lSessDescForInsert(insert_index) := pSessionDescTbl(i);
            lPeriodDateForInsert(insert_index) := pPeriodDateTbl(i);
            insert_index := insert_index+1;
      -- nbarik - 07/17/03 - Bug Fix 2999602 - Added BIS_PREVIOUS_EFFECTIVE_START_DATE and BIS_PREVIOUS_EFFECTIVE_END_DATE
      ELSIF ((pAttributeNameTbl(i) = 'VIEW_BY' AND pIncludeViewBy) OR
              (pAttributeNameTbl(i) = 'BUSINESS_PLAN' AND pIncludeBusinessPlan) OR
              (pAttributeNameTbl(i) = 'BIS_P_ASOF_DATE' AND pIncludePrevAsOfDate) OR
              (pAttributeNameTbl(i) = 'BIS_CUR_REPORT_START_DATE' AND pIncludePrevAsOfDate) OR
              (pAttributeNameTbl(i) = 'BIS_PREV_REPORT_START_DATE' AND pIncludePrevAsOfDate) OR
              (pAttributeNameTbl(i) = 'BIS_PREVIOUS_EFFECTIVE_START_DATE' AND pIncludePrevAsOfDate) OR
              (pAttributeNameTbl(i) = 'BIS_PREVIOUS_EFFECTIVE_END_DATE' AND pIncludePrevAsOfDate)
            ) THEN

                lAttrNameForDelete(delete_index) := pAttributeNameTbl(i) ;
                delete_index := delete_index+1;

                lAttrNameForInsert(insert_index) := pAttributeNameTbl(i) ;
                lDimensionForInsert(insert_index) := pDimensionTbl(i) ;
                lSessValueForInsert(insert_index) := pSessionValueTbl(i);
                lSessDescForInsert(insert_index) := pSessionDescTbl(i);
                lPeriodDateForInsert(insert_index) := pPeriodDateTbl(i);
                insert_index := insert_index+1;

        ELSIF (substr(pAttributeNameTbl(i), length(pAttributeNameTbl(i))-length('_HIERARCHY')+1)  ='_HIERARCHY') THEN
        -- if it ends with _hierarchy, then check if the dimension belongs to this new report and add it to the list

          -- check if the dimension for this belongs to this report, then delete and add
            IF (IsdimensionInParamGrp (
                  pDimension => pDimensionTbl(i),
                  pParameterGroup => pParameterGroup )
            ) THEN
                lAttrNameForDelete(delete_index) := pAttributeNameTbl(i) ;
                delete_index := delete_index+1;

                lAttrNameForInsert(insert_index) := pAttributeNameTbl(i) ;
                lDimensionForInsert(insert_index) := pDimensionTbl(i) ;
                lSessValueForInsert(insert_index) := pSessionValueTbl(i);
                lSessDescForInsert(insert_index) := pSessionDescTbl(i);
                lPeriodDateForInsert(insert_index) := pPeriodDateTbl(i);
                insert_index := insert_index+1;

            END IF;
        END IF; -- if lattrNameList is NOt NULL

    END LOOP;

    IF (lAttrNameForDelete IS NOT NULL AND lAttrNameForDelete.COUNT >0)  THEN
        bulkDeleteFromSession(
         pSessionId  => pSessionId,
         pUserId     => pUserId,
         pFunctionName   => pFunctionName,
          pAttributeNameTbl => lAttrNameForDelete
        ) ;
    END IF;

    IF (lAttrNameForInsert IS NOT NULL AND lAttrNameForInsert.COUNT >0)  THEN

     --insert all the records now
      bulkInsertIntoSession(
         pSessionId     => pSessionId,
         pUserId        => pUserId,
         pFunctionName  => pFunctionName,
         pAttributeNameTbl => lAttrNameForInsert,
         pDimensionTbl => lDimensionForInsert,
         pSessionValueTbl => lSessValueForInsert,
         pSessionDescTbl => lSessDescForInsert,
         pPeriodDateTbl => lPeriodDateForInsert
      );

    END IF;

  END IF; --lattname is null
END deleteAndInsertIntoSession;

/** To override the existing session parameters from schedule */
PROCEDURE overRideFromSchedule(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pScheduleId         in varchar2 default null,
                          pRespId         in  varchar2 default null,
                          pParameterGroup IN parameter_group_tbl_type
) IS

CURSOR getScheduleParameters IS
  SELECT attribute_name, dimension, session_value, session_description, period_date
  FROM bis_user_attributes
  WHERE schedule_id=pScheduleId;

vAttributeCodeTable BISVIEWER.t_char;
vDimensionTable     BISVIEWER.t_char;
vSessionValueTable     BISVIEWER.t_char;
vSessionDescTable     BISVIEWER.t_char;
vPeriodDateTable     BISVIEWER.t_date;

BEGIN
     IF getScheduleParameters%ISOPEN THEN
        CLOSE getScheduleParameters;
     END IF;
     OPEN getScheduleParameters;
     FETCH getScheduleParameters BULK COLLECT INTO vAttributeCodeTable, vDimensionTable, vSessionValueTable, vSessionDescTable, vPeriodDateTable;
     CLOSE getScheduleParameters;

     deleteAndInsertIntoSession(
              pSessionId  => pSessionId,
              pUserId     => pUserId,
              pFunctionName   => pFunctionName,
              pAttributeNameTbl => vAttributeCodeTable,
              pDimensionTbl => vDimensionTable,
              pSessionValueTbl => vSessionValueTable,
              pSessionDescTbl => vSessionDescTable,
              pPeriodDateTbl => vPeriodDateTable,
              pParameterGroup => pParameterGroup,
              pIncludePrevAsOfDate => TRUE
     );

END overRideFromSchedule;

-- nbarik - 02/19/04 - BugFix 3441967 - Added x_IsPreFuncTCTExists and x_IsPreFuncCalcDatesExists
PROCEDURE overRideFromPreFunction(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pPreFunctionName         in varchar2 default null,
                          pRespId         in  varchar2 default null,
                          pParameterGroup IN parameter_group_tbl_type,
                          pTCTExists      in boolean default false
                         , x_IsPreFuncTCTExists OUT NOCOPY BOOLEAN
                         , x_IsPreFuncCalcDatesExists OUT NOCOPY BOOLEAN
) IS

CURSOR getPreFunctionParameters IS
  SELECT attribute_name, dimension, session_value, session_description, period_date
  FROM bis_user_attributes
  WHERE function_name =pPreFunctionName
  AND session_id = pSessionId
  AND user_id = pUserId;

vAttributeCodeTable BISVIEWER.t_char;
vDimensionTable     BISVIEWER.t_char;
vSessionValueTable     BISVIEWER.t_char;
vSessionDescTable     BISVIEWER.t_char;
vPeriodDateTable     BISVIEWER.t_date;

l_time_attr_2      varchar2(2000);
l_time_level_id	   VARCHAR2(2000);
l_time_level_value VARCHAR2(2000);

l_asof_date VARCHAR2(80);
l_prev_asof_date_desc varchar2(80);
l_curr_report_start_date_desc varchar2(80);
l_prev_report_start_date_desc varchar2(80);

l_prev_asof_Date		DATE;
l_curr_effective_start_date	DATE;
l_curr_effective_end_date	DATE;
l_curr_report_start_date	DATE;
l_prev_report_start_date	DATE;
-- nbarik - 07/17/03 - Bug Fix 2999602
l_prev_effective_start_date	DATE;
l_prev_effective_end_date	DATE;
l_prev_time_level_id	        VARCHAR2(2000);
l_prev_time_level_value         VARCHAR2(2000);

l_return_status		VARCHAR2(2000);
l_msg_count			NUMBER;
l_msg_data		    VARCHAR2(2000);

IsTimeDimensionInGroup BOOLEAN := FALSE;
-- nbarik - 02/19/04 - BugFix 3441967
l_IsPreFuncTCTExists          BOOLEAN := FALSE;
l_IsPreFuncCalcDatesExists    BOOLEAN := FALSE;
BEGIN

     IF getPreFunctionParameters%ISOPEN THEN
        CLOSE getPreFunctionParameters;
     END IF;
     OPEN getPreFunctionParameters;
     FETCH getPreFunctionParameters BULK COLLECT INTO vAttributeCodeTable, vDimensionTable, vSessionValueTable, vSessionDescTable, vPeriodDateTable;
     CLOSE getPreFunctionParameters;

     -- nbarik - 02/19/04 - BugFix 3441967
     IF vAttributeCodeTable IS NOT NULL AND vAttributeCodeTable.COUNT > 0 THEN
       FOR k IN vAttributeCodeTable.FIRST..vAttributeCodeTable.LAST LOOP
         IF vDimensionTable(k) = 'TIME_COMPARISON_TYPE' THEN
           l_IsPreFuncTCTExists := TRUE;
         END IF;
         IF vAttributeCodeTable(k) = 'BIS_P_ASOF_DATE' THEN -- Check for one parameter
           l_IsPreFuncCalcDatesExists := TRUE;
         END IF;
       END LOOP;
     END IF;
     x_IsPreFuncTCTExists := l_IsPreFuncTCTExists;
     x_IsPreFuncCalcDatesExists := l_IsPreFuncCalcDatesExists;

     --BugFix 3411456, pass pIncludeBusinessPlan as true
     deleteAndInsertIntoSession(
              pSessionId  => pSessionId,
              pUserId     => pUserId,
              pFunctionName   => pFunctionName,
              pAttributeNameTbl => vAttributeCodeTable,
              pDimensionTbl => vDimensionTable,
              pSessionValueTbl => vSessionValueTable,
              pSessionDescTbl => vSessionDescTable,
              pPeriodDateTbl => vPeriodDateTable,
              pParameterGroup => pParameterGroup,
              pIncludePrevAsOfDate => TRUE,
              pIncludeBusinessPlan => TRUE
     );

END overRideFromPreFunction;

PROCEDURE overRideFromPage(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pPageId         in varchar2 default null,
                          pRespId         in  varchar2 default null,
                          pParameterGroup IN parameter_group_tbl_type
) IS

CURSOR getPageParameters IS
  SELECT attribute_name, dimension, session_value, session_description, period_date
  FROM bis_user_attributes
  WHERE page_id =pPageId
  AND user_id = pUserId;

vAttributeCodeTable BISVIEWER.t_char;
vDimensionTable     BISVIEWER.t_char;
vSessionValueTable     BISVIEWER.t_char;
vSessionDescTable     BISVIEWER.t_char;
vPeriodDateTable     BISVIEWER.t_date;

BEGIN
     IF getPageParameters%ISOPEN THEN
        CLOSE getPageParameters;
     END IF;
     OPEN getPageParameters;
     FETCH getPageParameters BULK COLLECT INTO vAttributeCodeTable, vDimensionTable, vSessionValueTable, vSessionDescTable, vPeriodDateTable;
     CLOSE getPageParameters;

     deleteAndInsertIntoSession(
              pSessionId  => pSessionId,
              pUserId     => pUserId,
              pFunctionName   => pFunctionName,
              pAttributeNameTbl => vAttributeCodeTable,
              pDimensionTbl => vDimensionTable,
              pSessionValueTbl => vSessionValueTable,
              pSessionDescTbl => vSessionDescTable,
              pPeriodDateTbl => vPeriodDateTable,
              pParameterGroup => pParameterGroup,
              pIncludeViewBy => FALSE              ,
              pIncludePrevAsOfDate => TRUE
     );

END overRideFromPage;

PROCEDURE overRideFromSavedDefault(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                          pRespId         in  varchar2 default null,
                          pParameterGroup IN parameter_group_tbl_type
) IS

CURSOR getSavedDefaultParameters IS
  SELECT attribute_name, dimension, default_value, default_description, period_date
  FROM bis_user_attributes
  WHERE  function_name = pFunctionName
  AND    user_id = pUserId
  AND    session_id IS NULL
  AND    session_description = 'NULL';

vAttributeCodeTable BISVIEWER.t_char;
vDimensionTable     BISVIEWER.t_char;
vSessionValueTable     BISVIEWER.t_char;
vSessionDescTable     BISVIEWER.t_char;
vPeriodDateTable     BISVIEWER.t_date;

BEGIN
     IF getSavedDefaultParameters%ISOPEN THEN
        CLOSE getSavedDefaultParameters;
     END IF;
     OPEN getSavedDefaultParameters;
     FETCH getSavedDefaultParameters BULK COLLECT INTO vAttributeCodeTable, vDimensionTable, vSessionValueTable, vSessionDescTable, vPeriodDateTable;
     CLOSE getSavedDefaultParameters;
     deleteAndInsertIntoSession(
              pSessionId  => pSessionId,
              pUserId     => pUserId,
              pFunctionName   => pFunctionName,
              pAttributeNameTbl => vAttributeCodeTable,
              pDimensionTbl => vDimensionTable,
              pSessionValueTbl => vSessionValueTable,
              pSessionDescTbl => vSessionDescTable,
              pPeriodDateTbl => vPeriodDateTable,
              pParameterGroup => pParameterGroup,
              pIncludeViewBy => TRUE,
              pIncludeBusinessPlan => TRUE
     );

END overRideFromSavedDefault;


-- Procedure to get Name Value pairs of the form name=value1&name2=value2
PROCEDURE getNameValuePairs(pUrlString IN VARCHAR2,
                            xParameterName OUT NOCOPY BISVIEWER.t_char,
                            xParameterValue OUT NOCOPY BISVIEWER.t_char
                            )
IS
  index1                 number;
   index2                 number;
   index3                 number;
   index4                 number;
   index5                 number;
   l_length               number;
   l_count                number;
    l_param_name varchar2(2000);
    l_param_value varchar2(2000);

BEGIN

   IF (pUrlString IS NULL) THEN
     RETURN;
   END IF;

   l_length := length(pUrlString);
   index2 :=0;
   l_count :=0;
 LOOP
       index2 := index2 +1;
      -- if there is no more '&' or no '=', then exit
      --if (instr(pUrlString,'&',index2,1)=0 OR
      IF
          (instr(pUrlString,'=',index2,1) =0) THEN
          EXIT;
      end if;


      index3 := instr(pUrlString,'=',index2,1);
      index5 := instr(pURLString,'=',index3+1,1);
      if (index5 > 0) then
         index4 := instr(pURLString,'&',-(l_length-index5)-1,1);
      else
         index4 := l_length+1;
      end if;

      l_param_name := substr(pUrlString, index2, index3-index2);
      l_param_value := substr(pUrlString,index3+1,index4-index3-1);
      xParameterName(l_Count) := l_param_name;
      xParameterValue(l_Count) := l_param_value;
      l_count := l_count+1;

      if (index4 >= l_length ) THEN
         exit;
      end if;
      index2 := index4;
  END LOOP;

END getNameValuePairs;

-- procedure to get only the pParameters from the array
PROCEDURE processDefaultParameters(
   l_attr_code            In OUT NOCOPY BISVIEWER.t_char
  , l_attr_value           IN OUT NOCOPY BISVIEWER.t_char
) IS
BEGIN
  IF (l_attr_code IS NOT NULL AND l_attr_code.COUNT >0) THEN
    FOR i IN l_attr_code.FIRST..l_attr_code.LAST LOOP

      -- get only the pParameters
      IF NOT (l_attr_code(i) = 'pParameters' ) THEN
            l_attr_code.DELETE(i);
            l_attr_value.DELETE(i);
      END IF;

    END LOOP;
  END IF;

END processDefaultParameters;

-- Procedure to execute a dynamic function
PROCEDURE processDynamicAttributeValue (
  pPlSqlFunctionName IN VARCHAR2,
  xOutPut OUT NOCOPY VARCHAR2
) IS
l_Dynamic_sql_str VARCHAR2(3000);
BEGIN
 IF (pPlSqlFunctionName IS NOT NULL) THEN
     l_Dynamic_sql_str := 'BEGIN :1 :='||pPlSqlFunctionName||'(); END;';
     execute immediate l_dynamic_sql_str using OUT xOutPut;
 END IF;

  EXCEPTION
   WHEN OTHERS THEN
    NULL;

END processDynamicAttributeValue;


-- serao- 08/23/2002- bug 2514044 - will remove the non-report-parameters and process some others
PROCEDURE processFormFunctionParameters(
  pRegionCode       IN VARCHAR2
  ,pFunctionName      IN	VARCHAR2
  ,pUserId           IN	VARCHAR2
  ,pSessionId        IN  VARCHAR2
  ,pResponsibilityId in varchar2 default NULL
  , l_attr_code            In OUT NOCOPY BISVIEWER.t_char
  , l_attr_value           IN OUT NOCOPY BISVIEWER.t_char
 , x_save_by_id OUT NOCOPY BOOLEAN

) IS
 l_vieW_by VARCHAR2(80);
 l_attribute_name VARCHAR2(80);
BEGIN

  x_save_by_id := FALSE;
  IF (l_attr_code IS NOT NULL AND l_attr_code.COUNT >0) THEN

    FOR i IN l_attr_code.FIRST..l_attr_code.LAST LOOP

      -- ignore all the report parameters except pParamIds- beginning with p
      IF(substr(l_attr_code(i), 1, 1) = 'p' ) THEN
          --serao - 2747174 - get save_by_id from parameters
          IF (l_attr_code(i) = 'pParamIds' AND l_attr_value(i) ='Y') THEN
            x_save_by_id := TRUE;
          END IF;

            l_attr_code.DELETE(i);
            l_attr_value.DELETE(i);
      ELSIF(substr(l_attr_code(i), 1, 1) = '"' ) THEN

          -- strip the single quotes ard the key
         processDynamicAttributeValue( replace (l_attr_code(i), '"', null), l_attr_code(i));

         -- if this did not yieldanything, then delete this parameter
         IF (l_attr_code(i) IS NULL) THEN
            l_attr_code.DELETE(i);
            l_attr_value.DELETE(i);
         ELSE
           l_attr_code(i) := BIS_PMV_UTIL.getDimensionForAttribute(l_attr_code(i), pRegionCode);
         END IF;

      ELSIF (l_attr_code(i)='VIEW_BY') THEN

            BEGIN
                SELECT attribute_name INTO l_view_by
                FROM bis_user_attributes
                WHERE function_name=pFunctionName
                AND session_id=pSessionId
                AND user_id = pUserId
                AND attribute_name ='VIEW_BY';
            EXCEPTION
             WHEN NO_DATA_FOUND THEN
              NULL;
            END;

            --delete this rom the array if vieW_by was already added to this session
            IF (l_view_by = 'VIEW_BY') THEN
                  l_attr_code.DELETE(i);
                  l_attr_value.DELETE(i);
            END IF;

      --ELSE

        --l_attr_code(i) := BIS_PMV_UTIL.getDimensionForAttribute(l_attr_code(i), pRegionCode);

      END IF;

    END LOOP;
  END IF;
END processFormFunctionParameters;


-- serao- 08/23/2002- bug 2514044 - copy form function parameters not copied previously
--serao -10/10/2002 - since we will copy the form function prameters first instead of last
-- we now do not need the remaining param cursor and add parameters w/o checking if they
-- are already present.
PROCEDURE COPY_FORM_FUNCTION_PARAMETERS
(pRegionCode       IN VARCHAR2
,pFunctionName      IN	VARCHAR2
,pUserId           IN	VARCHAR2
,pSessionId        IN  VARCHAR2
,pResponsibilityId in varchar2 default NULL
,pNestedRegionCode in varchar2 default NULL
,pAsofdateExists   in boolean default NULL
,x_return_status   OUT	NOCOPY VARCHAR2
,x_msg_count	     OUT	NOCOPY NUMBER
,x_msg_data	       OUT	NOCOPY VARCHAR2
) IS
   l_param_code            BISVIEWER.t_char;
   l_param_value    BISVIEWER.t_char;
   l_attr_code            BISVIEWER.t_char;
   l_attr_value           BISVIEWER.t_char;
   lParameters            VARCHAR2(2000);
   lDefaultParameters     VARCHAR2(2000);
   l_dimension VARCHAR2(2000);
   l_savebyid             BOOLEAN := FALSE;
   l_view_by_exists BOOLEAN := FALSE;
   l_attr_2 VARCHAR2(2000);

   l_user_session_rec	BIS_PMV_SESSION_PVT.session_rec_type;
   l_parameter_rec     parameter_rec_type;
   l_time_parameter_rec time_parameter_rec_type;

   l_time_attr_2 varchar2(2000);
   l_time_from_description varchar2(2000) := BIS_PMV_DRILL_PVT.gvAll;
   l_time_to_description varchar2(2000) := BIS_PMV_DRILL_PVT.gvAll;
   l_time_exists boolean := false;
   l_element_id            varchar2(1000);

   --Bug Fix 3087383 added variables and get_as_of_date,get_nested_region sqls
   l_as_of_date            varchar2(1000);
   l_time_level_id         varchar2(250);
   l_time_level_Value      varchar2(250);
   l_start_date            date;
   l_end_date              date;
   l_time_comparison_type  varchar2(250);
   l_canonical_date_format varchar2(30) := 'DD/MM/RRRR';


 BEGIN

-- get the parameters for this form fucntion
   SELECT parameters INTO lParameters
   FROM fnd_form_functions
   WHERE function_name=pFunctionName;

-- get all the name-value pairs in the form function
   getNameValuePairs(pUrlString => lParameters,
                            xParameterName => l_param_code,
                            xParameterValue => l_param_value
                            );

 -- get only the pParameters variable
    processDefaultParameters(
         l_attr_code     => l_param_code
        , l_attr_value    => l_param_value
    ) ;


  IF (l_param_code IS NOT NULL AND l_param_code.COUNT >0) THEN
    -- get the value of the default parameters
    lDefaultParameters := l_param_value(l_param_value.FIRST);
  END IF;


--for each of the names, find if it a parameter and if it already present in bis_user_attributes
  IF (lDefaultParameters IS NOT NULL) THEN

     -- replace the ~, ^ and the @
     lDefaultParameters := replace (lDefaultParameters, '~', '&');
     lDefaultParameters := replace (lDefaultParameters, '@', '=');
     lDefaultParameters := replace (lDefaultParameters, '^', '+');

     --get name value pairs from default params
     getNameValuePairs(pUrlString => lDefaultParameters,
                            xParameterName => l_attr_code,
                            xParameterValue => l_attr_value
                            );

    --remove the report parameters etc.
    --serao - bug 2647174 - get the savebyid from pParameters values
    processFormFunctionParameters(
          pRegionCode
          ,pFunctionName
          ,pUserId
          ,pSessionId
          ,pResponsibilityId
          , l_attr_code
          , l_attr_value
          ,l_saveById
          );



    IF (l_attr_code IS NOT NULL AND l_attr_code.COUNT >0) THEN

      l_user_session_rec.user_id := pUserId;
      l_user_session_rec.session_id := pSessionId;
      l_user_session_rec.responsibility_id := pResponsibilityId;
      l_user_session_rec.region_code := pRegionCode;
      l_user_session_rec.function_name := pFunctionName;


      FOR i IN l_attr_code.FIRST..l_attr_code.LAST LOOP


        --reinitialise this
        l_element_id := null;
    	  l_attr_2 := null;

        --check if the value is a dynamic value
        IF(substr(l_attr_value(i), 1, 1) = '"' ) THEN

            -- strip the single quotes ard the key
           processDynamicAttributeValue( replace (l_attr_value(i), '"', null), l_attr_value(i));

        END IF;


        IF (l_attr_code(i) = 'VIEW_BY' ) THEN
                  --save the parameter
                  l_parameter_rec.parameter_name := l_attr_code(i);
                  l_parameter_rec.parameter_description := nvl(l_attr_value(i), BIS_PMV_DRILL_PVT.gvAll);
                  l_parameter_rec.parameter_value := null;
                  l_parameter_rec.hierarchy_flag := 'N';
                  l_parameter_rec.default_flag := 'N';
                  l_parameter_rec.dimension :=  substr(l_attr_code(i),1,instr(l_attr_code(i),'+')-1);

                  if l_savebyid then
                    l_parameter_rec.id_flag := 'Y';
                  else
                  l_parameter_rec.id_flag := 'N';
                end if;

                VALIDATE_AND_SAVE(p_user_session_rec => l_user_session_rec,
                                                       p_parameter_rec => l_parameter_rec,
                                                       x_return_status	=> x_return_status,
                                                       x_msg_count => x_msg_count,
                                                       x_msg_data => x_msg_data);

          ELSIF substr(l_attr_code(i),instr(l_attr_code(i),'_HIERARCHY')) = '_HIERARCHY' THEN

              l_attr_code(i) := BIS_PMV_UTIL.getDimensionForAttribute(l_attr_code(i), pRegionCode);
              l_dimension := substr(l_attr_code(i),1,instr(l_attr_code(i),'+')-1);
              l_element_id := BIS_PMV_UTIL.getHierarchyElementId(l_attr_value(i), l_dimension);

              -- If there is a hierarchy then only store it
      	      IF (l_element_id > 0) THEN
                   l_parameter_rec.parameter_name := l_attr_code(i);
                   l_parameter_rec.parameter_value := l_element_id;
                   l_parameter_rec.hierarchy_flag := 'Y';
                   l_parameter_rec.default_flag := 'N';
                   --store the hierarchy
                   VALIDATE_AND_SAVE(p_user_session_rec => l_user_session_rec,
                                                          p_parameter_rec => l_parameter_rec,
                                                          x_return_status => x_return_status,
                                                          x_msg_count => x_msg_count,
                                                          x_msg_data => x_msg_data);


              END IF; --element id

          ELSIF substr(l_attr_code(i),instr(l_attr_code(i),'_FROM')) = '_FROM' then

            			    l_attr_code(i) := BIS_PMV_UTIL.getDimensionForAttribute(l_attr_code(i), pRegionCode);
                      l_time_exists := true;

                      IF(instr(l_attr_code(i),'_FROM',1,1) > 0 AND instr(l_attr_code(i),'+',1,1) > 0) then
                          l_time_attr_2 := substr(l_attr_code(i),1,instr(l_attr_code(i),'_FROM')-1);
                      ELSE
                        l_time_attr_2 := l_attr_code(i);
                      END IF;

                      l_time_from_description := nvl(l_attr_value(i),BIS_PMV_DRILL_PVT.gvAll);

          ELSIF substr(l_attr_code(i),instr(l_attr_code(i),'_TO')) = '_TO' THEN

            			    l_attr_code(i) := BIS_PMV_UTIL.getDimensionForAttribute(l_attr_code(i), pRegionCode);

                      l_time_exists := true;

                      IF(instr(l_attr_code(i),'_TO',1,1) > 0 AND instr(l_attr_code(i),'+',1,1) > 0) THEN
                        l_time_attr_2 := substr(l_attr_code(i),1,instr(l_attr_code(i),'_TO')-1);
                      ELSE
                        l_time_attr_2 := l_attr_code(i);
                      END IF;

                      l_time_to_description := nvl(l_attr_value(i),BIS_PMV_DRILL_PVT.gvAll);
          --Bug Fix 3087383 copy time attr2, time exists as true
          ELSIF substr(l_attr_code(i),1, instr(l_attr_code(i),'+')-1) = 'TIME' then

   		      l_attr_code(i) := BIS_PMV_UTIL.getDimensionForAttribute(l_attr_code(i), pRegionCode);
                      l_time_exists := true;
                      l_time_attr_2 := l_attr_code(i);

          ELSE

                      l_attr_code(i) := BIS_PMV_UTIL.getDimensionForAttribute(l_attr_code(i), pRegionCode);

                      IF (l_attr_code(i) = 'AS_OF_DATE' ) THEN
                         l_as_of_date := l_attr_value(i);
                      ELSIF substr(l_attr_code(i),1, instr(l_attr_code(i),'+')-1) = 'TIME_COMPARISON_TYPE' then
                         l_time_comparison_type := l_attr_code(i);
                      END IF;

                     --save the parameter
                      l_parameter_rec.parameter_name := l_attr_code(i);
                      l_parameter_rec.parameter_description := nvl(l_attr_value(i), BIS_PMV_DRILL_PVT.gvAll);
                      l_parameter_rec.parameter_value := null;
                      l_parameter_rec.hierarchy_flag := 'N';
                      l_parameter_rec.default_flag := 'N';
                      l_parameter_rec.dimension :=  substr(l_attr_code(i),1,instr(l_attr_code(i),'+')-1);

                      if l_savebyid then
                        l_parameter_rec.id_flag := 'Y';
                      else
                      l_parameter_rec.id_flag := 'N';
                      end if;

                      VALIDATE_AND_SAVE(p_user_session_rec => l_user_session_rec,
                                                       p_parameter_rec => l_parameter_rec,
                                                       x_return_status	=> x_return_status,
                                                       x_msg_count => x_msg_count,
                                                       x_msg_data => x_msg_data);

        END IF; --lAttrCode=

      END LOOP;

      --Bug Fix 3087383, check if as of date is saved else save it with sysdate
      if pNestedRegionCode is not null then
        --Fix for computing save dates if as of date is passed
        if l_as_of_date is null then
           l_as_of_date := to_char(sysdate, l_canonical_date_format);
        end if;
           if (pAsofdateExists and (l_time_attr_2 is not null)) then
             COMPUTE_AND_SAVE_DATES(pTimeAttribute => l_time_attr_2,
                      pTimeComparisonType => l_time_comparison_type,
	              p_user_Session_rec  => l_user_session_rec,
                      x_time_level_id  => l_time_level_id,
		      x_time_level_value => l_time_level_value
              );
           end if;
        end if;

      --BugFix 3515051
      -- if there was a time attribute in all this, then store that too
      IF (l_time_exists and not ( (pNestedRegionCode is not null) and pAsofdateExists and (l_time_attr_2 is not null) )) THEN

           l_time_parameter_rec.parameter_name := l_time_attr_2;
           l_time_parameter_rec.dimension := substr(l_time_attr_2,1,instr(l_time_attr_2,'+')-1);

          --Bug Fix 3087383 populate time from, to using level id, value if its value is all and nested region is present
           if (l_time_from_description = BIS_PMV_DRILL_PVT.gvAll and (pNestedRegionCode is not null)
               and l_as_of_date is not null and l_savebyid ) then
             l_time_parameter_rec.from_description := l_time_level_id;
           elsif (l_time_from_description = BIS_PMV_DRILL_PVT.gvAll and (pNestedRegionCode is not null) and l_as_of_date is not null) then
             l_time_parameter_rec.from_description := l_time_level_value;
           else
             l_time_parameter_rec.from_description := l_time_from_description;
           end if;

           if (l_time_to_description = BIS_PMV_DRILL_PVT.gvAll and (pNestedRegionCode is not null)
               and l_as_of_date is not null and l_savebyid ) then
             l_time_parameter_rec.to_description := l_time_level_id;
           elsif (l_time_to_description = BIS_PMV_DRILL_PVT.gvAll and (pNestedRegionCode is not null)
               and l_as_of_date is not null) then
             l_time_parameter_rec.to_description := l_time_level_value;
           else
             l_time_parameter_rec.to_description := l_time_to_description;
           end if;

           l_time_parameter_rec.default_flag := 'N';

           if l_savebyid then
              l_time_parameter_rec.id_flag := 'Y';
           else
              l_time_parameter_rec.id_flag := 'N';
           end if;

           VALIDATE_AND_SAVE_TIME(p_user_session_rec => l_user_session_rec,
                                                         p_time_parameter_rec => l_time_parameter_rec,
                                                         x_return_status  => x_return_status,
                                                         x_msg_count => x_msg_count,
                                                         x_msg_data => x_msg_data);


      END IF; --time_exists
    END IF; --lAttrCode is not null
   END IF; --lDefaultParameters is not null

   --serao - commit should be issues by caller

   EXCEPTION
   WHEN OTHERS THEN
    ROLLBACK;
 END COPY_FORM_FUNCTION_PARAMETERS;

/* for this function for those default parameters that are missing only, will copy default parameters */
PROCEDURE COPY_REMAINING_DEF_PARAMETERS
(pFunctionName      IN	VARCHAR2
,pUserId            IN	VARCHAR2
,pSessionId         IN  VARCHAR2
,x_return_status    OUT	NOCOPY VARCHAR2
,x_msg_count	    OUT	NOCOPY NUMBER
,x_msg_data	    OUT	NOCOPY VARCHAR2
) IS

BEGIN

     INSERT INTO BIS_USER_ATTRIBUTES (USER_ID,
                                      FUNCTION_NAME,
                                      SESSION_ID,
                                      SESSION_VALUE,
                                      SESSION_DESCRIPTION,
                                      ATTRIBUTE_NAME,
                                      DIMENSION,
                                      PERIOD_DATE,
                                      OPERATOR)
     SELECT pUserId,
            pFunctionName,
            pSessionId,
            DEFAULT_VALUE,
            DEFAULT_DESCRIPTION,
            ATTRIBUTE_NAME,
            DIMENSION,
            PERIOD_DATE,
            OPERATOR
     FROM   BIS_USER_ATTRIBUTES
     WHERE  function_name = pFunctionName
     AND    user_id = pUserId
     AND    session_id IS NULL
     AND    session_description = 'NULL'
     AND nvl(substr(attribute_name,1,instr(attribute_name,'+')-1), attribute_name) NOT IN (
      SELECT nvl(substr(attribute_name,1,instr(attribute_name,'+')-1), attribute_name)
      FROM bis_user_attributes
      WHERE function_name=pFunctionName
      AND user_id=pUserId
      AND session_id= pSessionId
      AND schedule_id IS NULL
     );
END COPY_REMAINING_DEF_PARAMETERS;

--nkishore CustomizeUI Enhancement Copy Session to default parameters
PROCEDURE COPY_SES_TO_DEF_PARAMETERS
(pFunctionName      IN	VARCHAR2
,pUserId         	IN	VARCHAR2
,pSessionId         IN  VARCHAR2
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
)  IS
BEGIN

     DELETE BIS_USER_ATTRIBUTES
     WHERE session_id is null and
     function_name = pFunctionName
     AND user_id= pUserId;
     --BugFix 3464708
     INSERT INTO BIS_USER_ATTRIBUTES (USER_ID,
                                      FUNCTION_NAME,
                                      ATTRIBUTE_NAME,
                                      SESSION_DESCRIPTION,
                                      DEFAULT_VALUE,
                                      DEFAULT_DESCRIPTION,
                                      PERIOD_DATE,
                                      DIMENSION,
                                      OPERATOR)
     SELECT pUserId,
            pFunctionName,
            ATTRIBUTE_NAME,
            'NULL',
            SESSION_VALUE,
            SESSION_DESCRIPTION,
            PERIOD_DATE,
            DIMENSION,
            OPERATOR
     FROM   BIS_USER_ATTRIBUTES
     WHERE  session_id = pSessionId
     AND    function_name = pFunctionName
     AND    user_id = pUserId
     AND    schedule_id IS NULL;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count
                               , p_data => x_msg_data);

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
END COPY_SES_TO_DEF_PARAMETERS;

/* This procedure is based on validate_and_save */
-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
PROCEDURE VALIDATE_PARAMETER
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_rec	IN	OUT NOCOPY parameter_rec_type
,x_valid OUT NOCOPY VARCHAR2
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) IS
BEGIN

  --As a part of the dbc project do not validate this special parameter
  if (substr(p_parameter_rec.parameter_name,1,length('TIME_COMPARISON_TYPE')) = 'TIME_COMPARISON_TYPE') then
     p_parameter_rec.parameter_name := p_parameter_rec.parameter_description;
     p_parameter_rec.parameter_value := p_parameter_Rec.parameter_description;
     x_valid := 'Y';
  elsif instr(p_parameter_rec.parameter_description, '^~]*') > 0 then
     x_valid := 'Y';
  --BugFix#2577374 -ansingh
  elsif (p_parameter_rec.parameter_value='-1') then
        p_parameter_rec.parameter_description := FND_MESSAGE.get_string('BIS','BIS_UNASSIGNED');
        x_valid := 'Y';
  elsif (upper(p_parameter_rec.parameter_description) = upper(FND_MESSAGE.get_string('BIS','BIS_UNASSIGNED'))) then
        p_parameter_rec.parameter_value := '-1';
        x_valid := 'Y';
  else
     VALIDATE_NONTIME_PARAMETER (p_user_session_rec => p_user_session_rec
                             ,p_parameter_rec => p_parameter_rec
                             ,x_valid => x_valid
                             ,x_return_status => x_return_status
                             ,x_msg_count => x_msg_count
                             ,x_msg_data => x_msg_data);
  end if;


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

END VALIDATE_PARAMETER;

PROCEDURE VALIDATE_AND_SAVE
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_rec	IN	OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) IS
  l_valid VARCHAR2(1);
BEGIN

-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
/*
  --As a part of the dbc project do not validate this special parameter
  if (substr(p_parameter_rec.parameter_name,1,length('TIME_COMPARISON_TYPE')) = 'TIME_COMPARISON_TYPE') then
     p_parameter_rec.parameter_name := p_parameter_rec.parameter_description;
     p_parameter_rec.parameter_value := p_parameter_Rec.parameter_description;
     l_valid := 'Y';
  elsif instr(p_parameter_rec.parameter_description, '^~]*') > 0 then
     l_valid := 'Y';
  --BugFix#2577374 -ansingh
  elsif (p_parameter_rec.parameter_value='-1') then
        p_parameter_rec.parameter_description := FND_MESSAGE.get_string('BIS','BIS_UNASSIGNED');
        l_valid := 'Y';
  elsif (upper(p_parameter_rec.parameter_description) = upper(FND_MESSAGE.get_string('BIS','BIS_UNASSIGNED'))) then
        p_parameter_rec.parameter_value := '-1';
        l_valid := 'Y';
  else
     VALIDATE_NONTIME_PARAMETER (p_user_session_rec => p_user_session_rec
                             ,p_parameter_rec => p_parameter_rec
                             ,x_valid => l_valid
                             ,x_return_status => x_return_status
                             ,x_msg_count => x_msg_count
                             ,x_msg_data => x_msg_data);
  end if;
 */

    VALIDATE_PARAMETER
    (p_user_session_rec	=> p_user_session_rec
    ,p_parameter_rec=> p_parameter_rec
    ,x_valid => l_valid
    ,x_return_status	=> x_return_status
    ,x_msg_count	=> x_msg_count
    ,x_msg_data	=> x_msg_data
    );

  IF l_valid = 'Y' THEN
     CREATE_PARAMETER (p_user_session_rec => p_user_session_rec
                      ,p_parameter_rec => p_parameter_rec
                      ,x_return_status => x_return_status
                      ,x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);
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
END VALIDATE_AND_SAVE;

PROCEDURE VALIDATE_AND_SAVE_TIME
(p_user_session_rec	  IN  BIS_PMV_SESSION_PVT.session_rec_type
,p_time_parameter_rec IN OUT NOCOPY BIS_PMV_PARAMETERS_PVT.time_parameter_rec_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) IS
  l_valid VARCHAR2(1);
  l_parameter_rec BIS_PMV_PARAMETERS_PVT.parameter_rec_type;

-- DIMENSION VALUE : kiprabha
l_from_index INTEGER ;
l_to_index INTEGER ;

BEGIN

	-- DIMENSION VALUE : begin
	-- kiprabha : 05/22/03
	-- Check to see if the time description has id and value encoded

	l_from_index:=instr(p_time_parameter_rec.from_description,'^~]*');
	l_to_index:=instr(p_time_parameter_rec.to_description,'^~]*');

	if l_from_index > 0 then
		p_time_parameter_rec.from_description :=
		substr(p_time_parameter_rec.from_description,
			l_from_index + 4) ;
	end if ;

	if l_to_index > 0 then
		p_time_parameter_rec.to_description :=
		substr(p_time_parameter_rec.to_description,
			l_to_index + 4) ;
	end if ;

	-- DIMENSION VALUE : end


  VALIDATE_TIME_PARAMETER (p_user_session_rec => p_user_session_rec
                          ,p_time_parameter_rec => p_time_parameter_rec
                          ,x_valid => l_valid
                          ,x_return_status => x_return_status
                          ,x_msg_count => x_msg_count
                          ,x_msg_data => x_msg_data);

  IF l_valid = 'Y' THEN
     l_parameter_rec.dimension := p_time_parameter_rec.dimension;
     l_parameter_rec.default_flag := p_time_parameter_rec.default_flag;

     l_parameter_rec.parameter_name := p_time_parameter_rec.parameter_name || '_FROM';
     l_parameter_rec.parameter_description := p_time_parameter_rec.from_description;
     l_parameter_rec.period_date := p_time_parameter_rec.from_period;
     l_parameter_Rec.parameter_Value := p_Time_parameter_rec.from_Value;
     --create the "from" record
     CREATE_PARAMETER (p_user_session_rec => p_user_session_rec
                      ,p_parameter_rec => l_parameter_rec
                      ,x_return_status => x_return_status
                      ,x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);

     l_parameter_rec.parameter_name := p_time_parameter_rec.parameter_name || '_TO';
     l_parameter_rec.parameter_description := p_time_parameter_rec.to_description;
     l_parameter_rec.period_date := p_time_parameter_rec.to_period;
     l_parameter_Rec.parameter_Value := p_Time_parameter_rec.to_Value;

     --create the "to" record
     CREATE_PARAMETER (p_user_session_rec => p_user_session_rec
                      ,p_parameter_rec => l_parameter_rec
                      ,x_return_status => x_return_status
                      ,x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);
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
END VALIDATE_AND_SAVE_TIME;

PROCEDURE VALIDATE_NONTIME_PARAMETER
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_rec	IN  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,x_valid		    OUT	NOCOPY VARCHAR2
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) IS

l_validated_result varchar2(1000);
--BugFix 3497180
l_rolling_dim      varchar2(250);

cursor c_rolling_dim is
select attribute17 from bis_ak_region_item_extension ext
    where ext.region_code=p_user_session_rec.region_code
    and attribute_code =
       ( select attribute_code from ak_region_items akItems
         where akItems.region_code= ext.region_code
         and nvl(akItems.attribute2, akItems.attribute_code) = p_parameter_rec.parameter_name);

BEGIN
   x_valid := 'Y';

 IF p_parameter_rec.hierarchy_flag = 'Y' THEN

    IF p_parameter_rec.parameter_value IS NULL THEN
       x_valid := 'N';
       RAISE FND_API.G_EXC_ERROR;
    END IF;

 ELSE
   --aleung, 7/17/02, validation through id instead of value
   IF p_parameter_rec.id_flag = 'Y' THEN
      p_parameter_rec.parameter_value := p_parameter_rec.parameter_description;
   END IF;

   IF p_parameter_rec.parameter_name <> 'VIEW_BY' AND p_parameter_rec.parameter_name <> 'BUSINESS_PLAN' THEN
      --Bug Fix 2616851 , Added trim so that blank can be checked
      -- Bug Fix 2728237, Added check for %
	/*
      IF nvl(trim(p_parameter_rec.parameter_description), g_all) = g_all AND p_parameter_rec.required_flag = 'Y' THEN
	*/
      IF ((nvl(trim(p_parameter_rec.parameter_description), g_all) = g_all) OR
      	  (nvl(trim(p_parameter_rec.parameter_description), '%') = '%'))
	AND p_parameter_rec.required_flag = 'Y' THEN
         x_valid := 'N';
         FND_MESSAGE.SET_NAME('BIS','MANDATORY_PARAM');
         --Need to add a message token later
         FND_MESSAGE.SET_TOKEN('PARAMETER_LABEL', p_parameter_rec.parameter_label);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      --BugFix 3497180, Fix for Rolling Dimension Validation
      IF c_rolling_dim%ISOPEN THEN
         CLOSE c_rolling_dim;
      END IF;
      OPEN c_rolling_dim;
      FETCH c_rolling_dim INTO l_rolling_dim;
      CLOSE c_rolling_dim;
      IF l_rolling_dim IS NOT NULL THEN
         p_parameter_rec.parameter_description := '~ROLLING_DIMENSION';
         if (instr(p_parameter_rec.parameter_value,'''')=1) then
            p_parameter_rec.parameter_value := substr(p_parameter_rec.parameter_value,2, length(p_parameter_rec.parameter_value)-2);
         end if;
      ELSE
        IF p_parameter_rec.parameter_description <> g_all THEN
         IF p_parameter_rec.dimension IS NOT NULL THEN
         --aleung, 7/17/02, validation through id instead of value
           IF p_parameter_rec.id_flag = 'Y' THEN
              GET_NONTIME_VALIDATED_ID (p_parameter_name => p_parameter_rec.parameter_name
                                     ,p_parameter_value => p_parameter_rec.parameter_value
                                     ,p_lov_where => p_parameter_rec.lov_where
                                     ,p_region_code => p_user_session_rec.region_code
                                     ,p_responsibility_id => p_user_session_rec.responsibility_id
                                     ,x_parameter_description => p_parameter_rec.parameter_description
                                     ,x_return_status => x_return_status
                                     ,x_msg_count => x_msg_count
                                     ,x_msg_data => x_msg_data);
              l_validated_result := p_parameter_rec.parameter_description;
             if (substr(p_parameter_rec.parameter_value,1,1) <> '''') then
                  p_parameter_rec.parameter_value := ''''|| p_parameter_rec.parameter_value
                                                   || '''';
              end if;
           ELSE
             GET_NONTIME_VALIDATED_VALUE (p_parameter_name => p_parameter_rec.parameter_name
                                     ,p_parameter_description => p_parameter_rec.parameter_description
                                     ,p_lov_where => p_parameter_rec.lov_where
                                     ,p_region_code => p_user_session_rec.region_code
                                     ,p_responsibility_id => p_user_session_rec.responsibility_id
                                     ,x_parameter_value => p_parameter_rec.parameter_value
                                     ,x_return_status => x_return_status
                                     ,x_msg_count => x_msg_count
                                     ,x_msg_data => x_msg_data);
             l_validated_result := p_parameter_rec.parameter_value;
           END IF; --end of id_flag
           --nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
           IF l_validated_result IS NULL THEN
             -- Check for Proxy User
             l_validated_result := GET_DELEGATION_VALIDATED_VALUE(
                                         pDelegationParam => p_parameter_rec.parameter_name
                                       , pRegionCode => p_user_session_rec.region_code
                                    );
         IF l_validated_result IS NULL THEN
            x_valid := 'N';
            FND_MESSAGE.SET_NAME('BIS','NOT_VALID');
            --Need to add a message token later
            FND_MESSAGE.SET_TOKEN('PARAMETER_LABEL', p_parameter_rec.parameter_label);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;
        ELSE
             p_parameter_rec.parameter_value := p_parameter_rec.parameter_description;
       END IF;
       ELSE
         p_parameter_rec.parameter_value := p_parameter_rec.parameter_description;
       END IF;
      END IF;
   ELSIF p_parameter_rec.parameter_name = 'VIEW_BY' THEN
      IF p_parameter_rec.parameter_description IS NULL THEN
         x_valid := 'N';
         FND_MESSAGE.SET_NAME('BIS','INVALID_VIEWBY');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         p_parameter_rec.parameter_value := p_parameter_rec.parameter_description;
      END IF;
   ELSIF p_parameter_rec.parameter_name = 'BUSINESS_PLAN' then
    --aleung, 7/17/02, validation through id instead of value
    IF p_parameter_rec.id_flag = 'Y' then
      BEGIN
	 SELECT name
         INTO   p_parameter_rec.parameter_description
         FROM   BISBV_BUSINESS_PLANS
         WHERE  plan_id = p_parameter_rec.parameter_value;
      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;
    ELSE
      BEGIN
         SELECT plan_id
         INTO   p_parameter_rec.parameter_value
         FROM   BISBV_BUSINESS_PLANS
         WHERE  name = p_parameter_rec.parameter_description;
      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;
    END IF; --end of id_flag
   END IF;

 END IF;
 --Bug Fix 2816953
 IF p_parameter_rec.parameter_description = g_all OR
    p_parameter_rec.parameter_value = g_all THEN
    p_parameter_rec.parameter_value := null;
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
END VALIDATE_NONTIME_PARAMETER;

-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
FUNCTION GET_DELEGATION_VALIDATED_VALUE(
  pDelegationParam IN VARCHAR2
, pRegionCode      IN VARCHAR2
) RETURN VARCHAR2
IS

CURSOR getDelegationParam IS
SELECT attribute14
FROM ak_regions
WHERE region_code = pRegionCode;

CURSOR getPrivileges(pAttributeCode VARCHAR2) IS
SELECT attribute24
FROM bis_ak_region_item_extension
WHERE region_code=pRegionCode AND attribute_code=pAttributeCode;

cursor c_level_values_view_name (cp_parameter_name varchar2, cp_region_code varchar2) is
       select vl.attribute15,  -- level view name
       substr(vl.attribute2, instr(vl.attribute2,'+')+1), -- dimension level
       nvl(r.region_object_type, 'OLTP') -- level type
       from   ak_region_items vl, ak_regions r
       where  nvl(vl.attribute2,vl.attribute_code) = rtrim(cp_parameter_name)
       and    vl.region_code  = rtrim(cp_region_code)
       and    vl.region_code = r.region_code;

l_validated_value VARCHAR2(200) := NULL;
l_delegation_param VARCHAR2(150);
l_privilege VARCHAR2(150);
l_attribute_code VARCHAR2(30);
l_roleIds_tbl BISVIEWER.t_char;
l_delegationIds_tbl BISVIEWER.t_char;
l_delegationValues_tbl BISVIEWER.t_char;
l_view_name  VARCHAR2(150);
l_dimension_level  VARCHAR2(150);
l_level_type  VARCHAR2(150);
l_sql_stmnt   VARCHAR2(2000);
l_id_name     VARCHAR2(200);
l_value_name  VARCHAR2(200);
l_return_status	VARCHAR2(2000);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
l_AsOfDate      DATE;
BEGIN
  IF getDelegationParam%ISOPEN THEN
    CLOSE getDelegationParam;
  END IF;
  OPEN getDelegationParam;
  FETCH getDelegationParam INTO l_delegation_param;
  CLOSE getDelegationParam;
  IF (pDelegationParam = l_delegation_param) THEN
    l_attribute_code := BIS_PMV_UTIL.getAttributeForDimension(l_delegation_param, pRegionCode);
    IF (l_attribute_code <> l_delegation_param) THEN
	  IF getPrivileges%ISOPEN THEN
	    CLOSE getPrivileges;
	  END IF;
	  OPEN getPrivileges(l_attribute_code);
	  FETCH getPrivileges INTO l_privilege;
	  CLOSE getPrivileges;
	  IF (l_privilege IS NOT NULL AND l_privilege <> '-1' AND length(trim(l_privilege)) > 0) THEN
	    -- Get Role Id's for Privileges
	    l_roleIds_tbl := BIS_PMV_UTIL.getRoleIds(l_privilege);
	    IF (l_roleIds_tbl IS NOT NULL AND l_roleIds_tbl.COUNT > 0) THEN
		  IF c_level_values_view_name%ISOPEN THEN
		    CLOSE c_level_values_view_name;
		  END IF;
          open c_level_values_view_name (l_delegation_param, pRegionCode);
          fetch c_level_values_view_name into l_view_name, l_dimension_level, l_level_type;
          close c_level_values_view_name;
          IF (l_view_name IS NULL) THEN
		    IF UPPER(l_level_type) = 'EDW' THEN
			  l_level_type := 'EDW';
			ELSE
			  l_level_type := 'OLTP';
		    END IF;
		    BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING(
		          p_DimLevelShortName => l_dimension_level
		        , p_bis_source => l_level_type
		        , x_Select_String => l_sql_stmnt
		        , x_table_name => l_view_name
		        , x_id_name => l_id_name
		        , x_value_name => l_value_name
		        , x_return_status => l_return_status
		        , x_msg_count => l_msg_count
		        , x_msg_data => l_msg_data
		      );
          END IF;

	      BIS_PMV_UTIL.getDelegations(
			    pRoleIdsTbl => l_roleIds_tbl
			  , pParamName  => l_delegation_param
			  , pParameterView => l_view_name
			  , pAsOfDate      => l_AsOfDate
			  , xDelegatorIdTbl  => l_delegationIds_tbl
			  , xDelegatorValueTbl => l_delegationValues_tbl
          );
          IF (l_delegationIds_tbl IS NOT NULL AND l_delegationIds_tbl.COUNT > 0) THEN
            l_validated_value := l_delegationIds_tbl(1);
          END IF;
	    END IF;
	  END IF;
    END IF;
  END IF;

  RETURN l_validated_value;
EXCEPTION
  WHEN OTHERS THEN
	  IF getDelegationParam%ISOPEN THEN
	    CLOSE getDelegationParam;
	  END IF;
  	  IF getPrivileges%ISOPEN THEN
	    CLOSE getPrivileges;
	  END IF;
	  IF c_level_values_view_name%ISOPEN THEN
	    CLOSE c_level_values_view_name;
	  END IF;

END GET_DELEGATION_VALIDATED_VALUE;

PROCEDURE VALIDATE_TIME_PARAMETER
(p_user_session_rec	    IN  BIS_PMV_SESSION_PVT.session_rec_type
,p_time_parameter_rec	    IN  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.time_parameter_rec_type
,x_valid		    OUT NOCOPY VARCHAR2
,x_return_status	    OUT NOCOPY VARCHAR2
,x_msg_count		    OUT NOCOPY NUMBER
,x_msg_data		    OUT NOCOPY VARCHAR2
) IS
  l_dummy_date      DATE;
  l_validate_from varchar2(2000);
  l_validate_to   varchar2(2000);
BEGIN
   x_valid := 'Y';
   IF ((nvl(p_time_parameter_rec.from_description, g_all) = g_all
        OR nvl(p_time_parameter_rec.to_description, g_all) = g_all)
      AND (p_time_parameter_rec.required_flag = 'Y')) THEN
         x_valid := 'N';
         FND_MESSAGE.SET_NAME('BIS','MANDATORY_PARAM');
         --Need to add a message token later
         FND_MESSAGE.SET_TOKEN('PARAMETER_LABEL', p_time_parameter_rec.parameter_label);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF nvl(p_time_parameter_rec.from_description, g_all) <> g_all THEN
       if p_time_parameter_rec.id_flag = 'Y' then
          p_time_parameter_rec.from_value := p_time_parameter_rec.from_description;
          GET_TIME_VALIDATED_ID (p_parameter_name => p_time_parameter_rec.parameter_name
                               ,p_parameter_value => p_time_parameter_rec.from_value
                               ,p_region_code => p_user_session_rec.region_code
                               ,p_org_name => p_time_parameter_rec.org_name
                               ,p_org_value => p_time_parameter_rec.org_value
                               ,p_responsibility_id => p_user_session_rec.responsibility_id
                               ,x_parameter_description => p_time_parameter_rec.from_description
                               ,x_start_date => p_time_parameter_rec.from_period
                               ,x_end_date => l_dummy_date
                               ,x_return_status => x_return_status
                               ,x_msg_count => x_msg_count
                               ,x_msg_data => x_msg_data);
         l_validate_from := p_time_parameter_rec.from_description;
       else
         GET_TIME_VALIDATED_VALUE (p_parameter_name => p_time_parameter_rec.parameter_name
                               ,p_parameter_description => p_time_parameter_rec.from_description
                               ,p_region_code => p_user_session_rec.region_code
                               ,p_org_name => p_time_parameter_rec.org_name
                               ,p_org_value => p_time_parameter_rec.org_value
                               ,p_responsibility_id => p_user_session_rec.responsibility_id
                               ,x_parameter_value => p_time_parameter_rec.from_value
                               ,x_start_date => p_time_parameter_rec.from_period
                               ,x_end_date => l_dummy_date
                               ,x_return_status => x_return_status
                               ,x_msg_count => x_msg_count
                               ,x_msg_data => x_msg_data);
         l_validate_from := p_time_parameter_rec.from_value;
      end if;

      IF l_validate_from IS NULL THEN
         x_valid := 'N';
         FND_MESSAGE.SET_NAME('BIS','NOT_VALID');
         --Need to add a message token later
         FND_MESSAGE.SET_TOKEN('PARAMETER_LABEL', p_time_parameter_rec.parameter_label);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   IF nvl(p_time_parameter_rec.to_description, g_all) <> g_all THEN
      if p_time_parameter_rec.id_flag = 'Y' then
         p_time_parameter_rec.to_value := p_time_parameter_rec.to_description;
         GET_TIME_VALIDATED_ID (p_parameter_name => p_time_parameter_rec.parameter_name
                               ,p_parameter_value => p_time_parameter_rec.to_value
                               ,p_region_code => p_user_session_rec.region_code
                               ,p_org_name => p_time_parameter_rec.org_name
                               ,p_org_value => p_time_parameter_rec.org_value
                               ,p_responsibility_id => p_user_session_rec.responsibility_id
                               ,x_parameter_description => p_time_parameter_rec.to_description
                               ,x_start_date => l_dummy_date
                               ,x_end_date => p_time_parameter_rec.to_period
                               ,x_return_status => x_return_status
                               ,x_msg_count => x_msg_count
                               ,x_msg_data => x_msg_data);
         l_validate_to := p_time_parameter_rec.to_description;
      else
         GET_TIME_VALIDATED_VALUE (p_parameter_name => p_time_parameter_rec.parameter_name
                               ,p_parameter_description => p_time_parameter_rec.to_description
                               ,p_region_code => p_user_session_rec.region_code
                               ,p_org_name => p_time_parameter_rec.org_name
                               ,p_org_value => p_time_parameter_rec.org_value
                               ,p_responsibility_id => p_user_session_rec.responsibility_id
                               ,x_parameter_value => p_time_parameter_rec.to_value
                               ,x_start_date => l_dummy_date
                               ,x_end_date => p_time_parameter_rec.to_period
                               ,x_return_status => x_return_status
                               ,x_msg_count => x_msg_count
                               ,x_msg_data => x_msg_data);
         l_validate_to := p_time_parameter_rec.to_value;
      end if;

      IF l_validate_to IS NULL THEN
         x_valid := 'N';
         FND_MESSAGE.SET_NAME('BIS','NOT_VALID');
         --Need to add a message token later
         FND_MESSAGE.SET_TOKEN('PARAMETER_LABEL', p_time_parameter_rec.parameter_label);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
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
END VALIDATE_TIME_PARAMETER;

PROCEDURE DECODE_ID_VALUE
(p_code   IN VARCHAR2
,p_index  IN NUMBER
,x_id    OUT NOCOPY VARCHAR2
,x_value OUT NOCOPY VARCHAR2) IS

BEGIN

  x_id := substr(p_code,1,p_index-1);
  x_value := substr(p_code,p_index+4); --length('^~]*')= 4

END DECODE_ID_VALUE;

PROCEDURE CREATE_PARAMETER
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_rec	IN	BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_Data         OUT NOCOPY VARCHAR2
) IS
  l_parameter_name VARCHAR2(32000) := p_parameter_rec.parameter_name;
  l_parameter_value VARCHAR2(32000) := p_parameter_rec.parameter_value;
  l_parameter_description VARCHAR2(32000) := p_parameter_rec.parameter_description;
  l_index number := 0;
  l_dimension VARCHAR2(80) := p_parameter_rec.dimension;

BEGIN

  l_index := instr(p_parameter_rec.parameter_description,'^~]*');
  IF l_index > 0 THEN
     DECODE_ID_VALUE
     (p_code => p_parameter_rec.parameter_description
     ,p_index => l_index
     ,x_id => l_parameter_value
     ,x_value => l_parameter_description);
     if l_parameter_value is not null then
        l_parameter_value := ''''||l_parameter_value||'''';
     end if;
  END IF;

  IF p_parameter_rec.hierarchy_flag = 'Y' THEN
     IF substr(l_parameter_name, length(l_parameter_name)-9) <> '_HIERARCHY' THEN
        l_parameter_name := substr(l_parameter_name,1,instr(l_parameter_name,'+')-1) || '_HIERARCHY';
     ELSE
        l_parameter_name := substr(l_parameter_name,1,instr(l_parameter_name,'+')-1);
     END IF;
  END IF;

  if l_dimension is null then
     l_index := instr(l_parameter_name,'+');
     IF l_index > 0 THEN
        l_dimension := substr(l_parameter_name,1,l_index-1);
     END IF;
  end if;

  IF p_parameter_rec.default_flag = 'Y' THEN

     INSERT INTO BIS_USER_ATTRIBUTES (user_id, function_name,
                                      attribute_name, session_description,
                                      default_value, default_description,
                                      period_date, dimension, operator,
                                      creation_date, created_by,
                                      last_update_Date, last_updated_by)
                              VALUES (p_user_session_rec.user_id, p_user_session_rec.function_name,
                                      l_parameter_name, 'NULL',
                                      l_parameter_value, l_parameter_description,
                                      p_parameter_rec.period_date, l_dimension,
                                      p_parameter_rec.operator,
                                      sysdate, -1, sysdate, -1);
  ELSE
    IF p_user_session_rec.page_id IS NULL OR p_user_session_rec.page_id = '' THEN
     INSERT INTO BIS_USER_ATTRIBUTES (user_id, function_name,
                                      session_id, attribute_name,
                                      session_value, session_description,
                                      period_date, dimension, operator,
                                      creation_date, created_by,
                                      last_update_Date, last_updated_by)
                              VALUES (p_user_session_rec.user_id, p_user_session_rec.function_name,
                                      p_user_session_rec.session_id, l_parameter_name,
                                      l_parameter_value, l_parameter_description,
                                      p_parameter_rec.period_date, l_dimension,
                                      p_parameter_rec.operator,
                                      sysdate, -1, sysdate, -1);
    ELSE

     INSERT INTO BIS_USER_ATTRIBUTES (user_id, page_id, attribute_name, function_name, session_id,
                                      session_value, session_description,
                                      period_date, dimension, operator,
                                      creation_date, created_by,
                                      last_update_Date, last_updated_by)
                              VALUES (p_user_session_rec.user_id, p_user_session_rec.page_id, l_parameter_name,
                                      p_user_session_rec.function_name, p_user_session_rec.session_id,
                                      l_parameter_value, l_parameter_description,
                                      p_parameter_rec.period_date, l_dimension,
                                      p_parameter_rec.operator,
                                      sysdate, -1, sysdate, -1);

    END IF;
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
END CREATE_PARAMETER;

PROCEDURE RETRIEVE_PARAMETER
(p_user_session_rec	IN  BIS_PMV_SESSION_PVT.Session_rec_type
,p_parameter_rec	IN  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
) IS
BEGIN
  IF p_parameter_rec.default_flag = 'Y' THEN
     SELECT default_description,
            default_value,
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
     AND    function_name = p_user_session_rec.function_name
     AND    user_id = p_user_session_rec.user_id
     AND    session_description = 'NULL'
     AND    session_id IS NULL;
  ELSE
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
     AND    function_name = p_user_session_rec.function_name
     AND    user_id = p_user_session_rec.user_id
     AND    session_id = p_user_session_rec.session_id
     AND    schedule_id IS NULL;
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
END RETRIEVE_PARAMETER;

PROCEDURE RETRIEVE_PAGE_PARAMETER
(p_parameter_rec	IN  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,p_schedule_id          IN  NUMBER
,p_user_session_rec	IN  BIS_PMV_SESSION_PVT.Session_rec_type
,p_page_dims            IN  BISVIEWER.t_char
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
) IS

l_page_dims BISVIEWER.t_char := p_page_dims;
BEGIN

  -- make sure there are max elements as they will be accessed
  IF l_page_dims IS NOT NULL AND l_page_dims.COUNT < MAX_BIND_VARIABLE_COUNT AND l_page_dims.COUNT>0   THEN
    FOR i IN l_page_dims.COUNT..MAX_BIND_VARIABLE_COUNT LOOP
      l_page_dims(i) := NULL;
    END LOOP;
  END IF;

 x_return_status := FND_API.G_RET_STS_SUCCESS;
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
  AND    user_id = p_user_session_rec.user_id
  AND    page_id = p_user_session_rec.page_id;
 EXCEPTION WHEN NO_DATA_FOUND THEN
  if (p_schedule_id is not null ) then
     if (l_page_dims is not null and l_page_dims.COUNT > 0 ) THEN
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
         AND    schedule_id = p_schedule_id
         AND    attribute_name not in (l_page_dims(1), l_page_dims(2), l_page_dims(3), l_page_dims(4),
                 l_page_dims(5), l_page_dims(6), l_page_dims(7), l_page_dims(8), l_page_dims(9),
                 l_page_dims(10), l_page_dims(11), l_page_dims(12), l_page_dims(13), l_page_dims(14),
                 l_page_dims(15), l_page_dims(16), l_page_dims(17), l_page_dims(18), l_page_dims(19),
                 l_page_dims(20));
    else
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
         AND    schedule_id = p_schedule_id;
    end if;
  else
     if (l_page_dims is not null and l_page_dims.COUNT > 0) then
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
         AND  user_id = p_user_session_Rec.user_id
         AND  session_id = p_user_session_Rec.session_id
         AND  function_name = p_user_session_rec.function_name
         AND    attribute_name not in (l_page_dims(1), l_page_dims(2), l_page_dims(3), l_page_dims(4),
                l_page_dims(5), l_page_dims(6), l_page_dims(7), l_page_dims(8), l_page_dims(9), l_page_dims(10),
                l_page_dims(11), l_page_dims(12), l_page_dims(13), l_page_dims(14), l_page_dims(15),
                l_page_dims(16), l_page_dims(17), l_page_dims(18), l_page_dims(19), l_page_dims(20));
    else
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
         AND  user_id = p_user_session_Rec.user_id
         AND  session_id = p_user_session_Rec.session_id
         AND  function_name = p_user_session_rec.function_name;
    end if;
  end if;
 END;
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
END RETRIEVE_PAGE_PARAMETER;

PROCEDURE RETRIEVE_KPI_PARAMETER
(p_parameter_rec	IN  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,p_user_session_rec	IN  BIS_PMV_SESSION_PVT.Session_rec_type
,p_user_dims        IN  BISVIEWER.t_char
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
) IS

  l_user_dims BISVIEWER.t_char := p_user_dims;

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- make sure there are max elements as they will be accessed
  IF l_user_dims IS NOT NULL AND l_user_dims.COUNT < MAX_BIND_VARIABLE_COUNT   THEN
    FOR i IN l_user_dims.COUNT .. MAX_BIND_VARIABLE_COUNT LOOP
      --l_page_dims.EXTEND;
      l_user_dims(i) := NULL;
    END LOOP;
  END IF;

  BEGIN
       SELECT session_description,
            session_value,
            period_date,
            dimension,
            operator
       INTO p_parameter_rec.parameter_description,
            p_parameter_rec.parameter_value,
            p_parameter_rec.period_date,
            p_parameter_rec.dimension,
            p_parameter_rec.operator
       FROM BIS_USER_ATTRIBUTES
       WHERE attribute_name = p_parameter_rec.parameter_name
       AND   user_id = p_user_session_Rec.user_id
       AND   session_id = p_user_session_Rec.session_id
       AND   function_name = p_user_session_rec.function_name;
 EXCEPTION WHEN NO_DATA_FOUND THEN
  if l_user_dims is not null then
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
     AND    user_id = p_user_session_rec.user_id
     AND    page_id = p_user_session_rec.page_id
         AND    attribute_name not in (l_user_dims(1), l_user_dims(2), l_user_dims(3), l_user_dims(4),
                l_user_dims(5), l_user_dims(6), l_user_dims(7), l_user_dims(8), l_user_dims(9),
                l_user_dims(10), l_user_dims(11), l_user_dims(12), l_user_dims(13), l_user_dims(14),
                l_user_dims(15), l_user_dims(16), l_user_dims(17), l_user_dims(18), l_user_dims(19), l_user_dims(20));
   else
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
     AND    user_id = p_user_session_rec.user_id
     AND    page_id = p_user_session_rec.page_id;
   end if;
  END;
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
END RETRIEVE_KPI_PARAMETER;

PROCEDURE RETRIEVE_SCHEDULE_PARAMETER
(p_parameter_rec	IN  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,p_schedule_id      IN  NUMBER
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
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
  AND    schedule_id = p_schedule_id;
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
END RETRIEVE_SCHEDULE_PARAMETER;

PROCEDURE DELETE_PARAMETER
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_name	IN	VARCHAR2
,p_schedule_option  IN  VARCHAR2
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		OUT	NOCOPY VARCHAR2
) IS
BEGIN
  IF p_schedule_option = 'NULL' THEN
    DELETE FROM BIS_USER_ATTRIBUTES
    WHERE  user_id = p_user_session_rec.user_id
    AND    session_id = p_user_session_rec.session_id
    AND    function_name = p_user_session_rec.function_name
    AND    attribute_name = p_parameter_name
    AND    schedule_id IS NULL;
  ELSIF p_schedule_option = 'NOT_NULL' THEN
    DELETE FROM BIS_USER_ATTRIBUTES
    WHERE  user_id = p_user_session_rec.user_id
    AND    session_id = p_user_session_rec.session_id
    AND    function_name = p_user_session_rec.function_name
    AND    attribute_name = p_parameter_name
    AND    schedule_id IS NOT NULL;
  ELSE
    DELETE FROM BIS_USER_ATTRIBUTES
    WHERE  user_id = p_user_session_rec.user_id
    AND    session_id = p_user_session_rec.session_id
    AND    function_name = p_user_session_rec.function_name
    AND    attribute_name = p_parameter_name;
  END IF;
 COMMIT;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END DELETE_PARAMETER;

PROCEDURE DELETE_SCHEDULE_PARAMETER
(p_parameter_name	IN	VARCHAR2
,p_schedule_id      IN  NUMBER
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
) IS
BEGIN
  DELETE FROM BIS_USER_ATTRIBUTES
  WHERE  attribute_name = p_parameter_name
  AND    schedule_id = p_schedule_id;
  COMMIT;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END DELETE_SCHEDULE_PARAMETER;

PROCEDURE CREATE_SESSION_PARAMETERS
(p_user_param_tbl	IN	BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		OUT	NOCOPY VARCHAR2
) IS

l_user_param_tbl	BIS_PMV_PARAMETERS_PVT.parameter_tbl_type;
l_lov_where  varchar2(2000);

/*
cursor lov_where_cursor (cpRegionCode varchar2, cpAttr2 varchar2) is
select attribute4
from ak_region_items
where region_code = cpRegionCode
and attribute2 = cpAttr2;
*/
BEGIN

  IF p_user_param_tbl.COUNT > 0 THEN
     l_useR_param_Tbl := p_user_param_Tbl;
     --FOR i in p_user_param_tbl.FIRST..p_user_param_tbl.LAST LOOP
  FOR i in 1..p_user_param_tbl.COUNT LOOP

  	IF (l_user_param_Tbl(i).parameter_name IS NOT NULL ) THEN
      IF (l_user_param_Tbl(i).parameter_description <> ROLLING_DIMENSION_DESCRIPTION
        --Bug Fix 2616851, Added this so that null check can be done for mandatory parameter
        OR (trim(l_user_param_Tbl(i).parameter_description) IS NULL AND l_user_param_Tbl(i).required_flag = 'Y') ) THEN
/*
                IF lov_where_cursor%ISOPEN THEN
                   close lov_where_cursor;
                END IF;
                open lov_where_cursor(p_user_session_rec.region_code, l_user_param_Tbl(i).parameter_name);
                fetch lov_where_cursor into l_lov_where;
                close lov_where_cursor;
*/
                IF (l_user_param_tbl(i).lov_where is not null and
                    instr(l_user_param_tbl(i).parameter_description, '^~]*') <= 0 and
                    l_user_param_tbl(i).parameter_description  <> g_all ) then
                   l_lov_where :=  GET_LOV_WHERE(p_parameter_tbl => l_user_param_Tbl,
                                                 p_where_clause => l_user_param_tbl(i).lov_where,
                                                 p_user_session_rec => p_user_session_rec);
                   l_user_param_tbl(i).lov_where := l_lov_where;
                END IF;

           	VALIDATE_AND_SAVE (p_user_session_rec => p_user_session_rec
           		  ,p_parameter_rec => l_user_param_tbl(i)
                          ,x_return_status => x_return_status
                          ,x_msg_count => x_msg_count
                          ,x_msg_Data => x_msg_data);
      ELSE

          -- save into the bis_user_atribute table directly

          CREATE_PARAMETER (p_user_session_rec	=> p_user_session_rec
                            ,p_parameter_rec	=> l_user_param_tbl(i)
                            ,x_return_status	=> x_return_status
                            ,x_msg_count => x_msg_count
                            ,x_msg_Data => x_msg_data
                          );
  	  END IF; -- if rolling dim

      IF (x_return_status is not null OR (x_return_status <> FND_API.G_RET_STS_SUCCESS))THEN
  	  	EXIT;
      END IF;

     END IF; -- if param name is not null
    END LOOP;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END CREATE_SESSION_PARAMETERS;

PROCEDURE RETRIEVE_PAGE_PARAMETERS
(p_schedule_id	    IN	NUMBER
,p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,x_user_param_tbl	OUT	NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) IS

 l_index NUMBER := 1;
 l_Dimension varchar2(2000);
 l_parameter_rec parameter_rec_type;
 l_page_dimensions varchar2(2000);

 CURSOR c_page_params_cursor IS
 SELECT attribute_name,
        session_description,
        session_value,
        period_date,
        dimension,
        operator
 FROM   BIS_USER_ATTRIBUTES
 WHERE  user_id = p_user_session_rec.user_id
 AND    page_id = p_user_session_rec.page_id;

 CURSOR c_sched_portlet_params_cursor IS
 SELECT attribute_name,
        session_description,
        session_value,
        period_date,
        dimension,
        operator
 FROM   BIS_USER_ATTRIBUTES
 WHERE  schedule_id = p_schedule_id
 AND    ((dimension IS NULL AND attribute_name not in (SELECT nvl(attribute_name,'-11')
                                                       FROM   BIS_USER_ATTRIBUTES
                                                       WHERE  page_id=p_user_session_rec.page_id
                                                       AND    user_id=p_user_session_rec.user_id))
      OR (dimension IS NOT NULL AND dimension not in (SELECT nvl(dimension,'-11')
                                                      FROM   BIS_USER_ATTRIBUTES
                                                      WHERE  page_id=p_user_session_rec.page_id
                                                      AND    user_id=p_user_session_rec.user_id)));

 CURSOR c_sess_portlet_params_cursor IS
 SELECT attribute_name,
        session_description,
        session_value,
        period_date,
        dimension,
        operator
 FROM   BIS_USER_ATTRIBUTES
 WHERE  user_id = p_user_session_rec.user_id
 AND    session_id = p_user_session_rec.session_id
 AND    function_name = p_user_session_rec.function_name
 AND    ((dimension IS NULL AND attribute_name not in (SELECT nvl(attribute_name,'-11')
                                                       FROM   BIS_USER_ATTRIBUTES
                                                       WHERE  page_id=p_user_session_rec.page_id
                                                       AND    user_id=p_user_session_rec.user_id))
      OR (dimension IS NOT NULL AND dimension not in (SELECT nvl(dimension, '-11')
                                                      FROM   BIS_USER_ATTRIBUTES
                                                      WHERE  page_id=p_user_session_rec.page_id
                                                      AND    user_id=p_user_session_rec.user_id)));

BEGIN

 FOR c_page_params_rec IN c_page_params_cursor LOOP
     l_parameter_rec.parameter_name := c_page_params_rec.attribute_name;
     l_parameter_rec.parameter_description := c_page_params_rec.session_description;
     l_parameter_rec.parameter_value := c_page_params_rec.session_value;
     l_parameter_rec.period_date := c_page_params_rec.period_date;
     l_parameter_rec.dimension := c_page_params_rec.dimension;
     l_parameter_rec.operator := c_page_params_rec.operator;
     x_user_param_tbl(l_index) := l_parameter_rec;
     l_index := l_index + 1;
 END LOOP;

 IF p_schedule_id IS NOT NULL THEN
    FOR c_sched_portlet_params_rec in c_sched_portlet_params_cursor LOOP
        l_parameter_rec.parameter_name := c_sched_portlet_params_rec.attribute_name;
        l_parameter_rec.parameter_description := c_sched_portlet_params_rec.session_description;
        l_parameter_rec.parameter_value := c_sched_portlet_params_rec.session_value;
        l_parameter_rec.period_date := c_sched_portlet_params_rec.period_date;
        l_parameter_rec.dimension := c_sched_portlet_params_rec.dimension;
        l_parameter_rec.operator := c_sched_portlet_params_rec.operator;
        x_user_param_tbl(l_index) := l_parameter_rec;
        l_index := l_index + 1;
    END LOOP;
 ELSE
    FOR c_sess_portlet_params_rec in c_sess_portlet_params_cursor LOOP
        l_parameter_rec.parameter_name := c_sess_portlet_params_rec.attribute_name;
        l_parameter_rec.parameter_description := c_sess_portlet_params_rec.session_description;
        l_parameter_rec.parameter_value := c_sess_portlet_params_rec.session_value;
        l_parameter_rec.period_date := c_sess_portlet_params_rec.period_date;
        l_parameter_rec.dimension := c_sess_portlet_params_rec.dimension;
        l_parameter_rec.operator := c_sess_portlet_params_rec.operator;
        x_user_param_tbl(l_index) := l_parameter_rec;
        l_index := l_index + 1;
    END LOOP;
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
END RETRIEVE_PAGE_PARAMETERS;

PROCEDURE RETRIEVE_KPI_PARAMETERS
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,x_user_param_tbl	OUT	NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) IS

 l_index NUMBER := 1;
 l_Dimension varchar2(2000);
 l_parameter_rec parameter_rec_type;
 l_user_dimensions varchar2(2000);

 CURSOR c_session_params_cursor IS
 SELECT attribute_name,
        session_description,
        session_value,
        period_date,
        dimension,
        operator
 FROM   BIS_USER_ATTRIBUTES
 WHERE  user_id = p_user_session_rec.user_id
 AND    session_id = p_user_session_rec.session_id
 AND    function_name = p_user_session_rec.function_name;

 CURSOR c_page_params_cursor IS
 SELECT attribute_name,
        session_description,
        session_value,
        period_date,
        dimension,
        operator
 FROM   BIS_USER_ATTRIBUTES
 WHERE  user_id = p_user_session_rec.user_id
 AND    page_id = p_user_session_rec.page_id
 AND    ((dimension IS NULL AND attribute_name not in (SELECT nvl(attribute_name, '-11')
                                                       FROM   BIS_USER_ATTRIBUTES
                                                       WHERE  user_id = p_user_session_rec.user_id
                                                       AND    session_id = p_user_session_rec.session_id
                                                       AND    function_name = p_user_session_rec.function_name))
      OR (dimension IS NOT NULL AND dimension not in (SELECT nvl(dimension,'-11')
                                                      FROM   BIS_USER_ATTRIBUTES
                                                      WHERE  user_id = p_user_session_rec.user_id
                                                      AND    session_id = p_user_session_rec.session_id
                                                      AND    function_name = p_user_session_rec.function_name)));

BEGIN

 FOR c_session_params_rec in c_session_params_cursor LOOP
     l_parameter_rec.parameter_name := c_session_params_rec.attribute_name;
     l_parameter_rec.parameter_description := c_session_params_rec.session_description;
     l_parameter_rec.parameter_value := c_session_params_rec.session_value;
     l_parameter_rec.period_date := c_session_params_rec.period_date;
     l_parameter_rec.dimension := c_session_params_rec.dimension;
     l_parameter_rec.operator := c_session_params_rec.operator;
     x_user_param_tbl(l_index) := l_parameter_rec;
     l_index := l_index + 1;
 END LOOP;

 FOR c_page_params_rec IN c_page_params_cursor LOOP
     l_parameter_rec.parameter_name := c_page_params_rec.attribute_name;
     l_parameter_rec.parameter_description := c_page_params_rec.session_description;
     l_parameter_rec.parameter_value := c_page_params_rec.session_value;
     l_parameter_rec.period_date := c_page_params_rec.period_date;
     l_parameter_rec.dimension := c_page_params_rec.dimension;
     l_parameter_rec.operator := c_page_params_rec.operator;
     x_user_param_tbl(l_index) := l_parameter_rec;
     l_index := l_index + 1;
 END LOOP;

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
END RETRIEVE_KPI_PARAMETERS;

PROCEDURE RETRIEVE_PARAMLVL_PARAMETERS
(p_user_session_Rec     IN      BIS_PMV_SESSION_PVT.session_rec_type
,x_paramportlet_param_tbl       OUT  NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_tbl_Type
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
 l_parameter_rec parameter_rec_type;
 l_index NUMBER := 1;
 l_dimension varchar2(25) := 'TIME_COMPARISON_TYPE';
 lNullList BISVIEWER.t_char;
BEGIN
         l_parameter_rec.parameter_name := 'AS_OF_DATE';
         RETRIEVE_PAGE_PARAMETER (p_parameter_rec => l_parameter_rec
                             ,p_schedule_id => null
                             ,p_user_session_rec => p_user_session_rec
                             ,p_page_dims => lNullList
                             ,x_return_status => x_return_status
                             ,x_msg_count => x_msg_count
                             ,x_msg_data => x_msg_data);
          IF (x_return_status is null or x_return_status = FND_API.G_RET_STS_SUCCESS) then
              x_paramportlet_param_tbl(l_index) := l_parameter_rec;
              l_index := l_index + 1;
          end if;
          l_parameter_rec.parameter_name := 'BIS_P_ASOF_DATE';
          RETRIEVE_PAGE_PARAMETER (p_parameter_rec => l_parameter_rec
                              ,p_schedule_id => null
                              ,p_user_session_rec => p_user_session_rec
                              ,p_page_dims =>  lNullList
                              ,x_return_status => x_return_status
                              ,x_msg_count => x_msg_count
                              ,x_msg_data => x_msg_data);
           IF (x_return_status is null or x_return_status = FND_API.G_RET_STS_SUCCESS) then
               x_paramportlet_param_tbl(l_index) := l_parameter_rec;
               l_index := l_index + 1;
           end if;
          l_parameter_rec.parameter_name := 'BIS_CUR_REPORT_START_DATE';
          RETRIEVE_PAGE_PARAMETER (p_parameter_rec => l_parameter_rec
                              ,p_schedule_id => null
                              ,p_user_session_rec => p_user_session_rec
                              ,p_page_dims =>  lNullList
                              ,x_return_status => x_return_status
                              ,x_msg_count => x_msg_count
                              ,x_msg_data => x_msg_data);
           IF (x_return_status is null or x_return_status = FND_API.G_RET_STS_SUCCESS) then
               x_paramportlet_param_tbl(l_index) := l_parameter_rec;
               l_index := l_index + 1;
           end if;
          l_parameter_rec.parameter_name := 'BIS_PREV_REPORT_START_DATE';
          RETRIEVE_PAGE_PARAMETER (p_parameter_rec => l_parameter_rec
                              ,p_schedule_id => null
                              ,p_user_session_rec => p_user_session_rec
                              ,p_page_dims =>  lNullList
                              ,x_return_status => x_return_status
                              ,x_msg_count => x_msg_count
                              ,x_msg_data => x_msg_data);
           IF (x_return_status is null or x_return_status = FND_API.G_RET_STS_SUCCESS) then
               x_paramportlet_param_tbl(l_index) := l_parameter_rec;
               l_index := l_index + 1;
           end if;
          -- nbarik - 07/17/03 - Bug Fix 2999602 - Added BIS_PREVIOUS_EFFECTIVE_START_DATE and BIS_PREVIOUS_EFFECTIVE_END_DATE
          l_parameter_rec.parameter_name := 'BIS_PREVIOUS_EFFECTIVE_START_DATE';
          RETRIEVE_PAGE_PARAMETER (p_parameter_rec => l_parameter_rec
                              ,p_schedule_id => null
                              ,p_user_session_rec => p_user_session_rec
                              ,p_page_dims =>  lNullList
                              ,x_return_status => x_return_status
                              ,x_msg_count => x_msg_count
                              ,x_msg_data => x_msg_data);
           IF (x_return_status is null or x_return_status = FND_API.G_RET_STS_SUCCESS) then
               x_paramportlet_param_tbl(l_index) := l_parameter_rec;
               l_index := l_index + 1;
           end if;
          l_parameter_rec.parameter_name := 'BIS_PREVIOUS_EFFECTIVE_END_DATE';
          RETRIEVE_PAGE_PARAMETER (p_parameter_rec => l_parameter_rec
                              ,p_schedule_id => null
                              ,p_user_session_rec => p_user_session_rec
                              ,p_page_dims =>  lNullList
                              ,x_return_status => x_return_status
                              ,x_msg_count => x_msg_count
                              ,x_msg_data => x_msg_data);
           IF (x_return_status is null or x_return_status = FND_API.G_RET_STS_SUCCESS) then
               x_paramportlet_param_tbl(l_index) := l_parameter_rec;
               l_index := l_index + 1;
           end if;

         -- Also need to retrieve the TIME comparison type
        BEGIN
        SELECT attribute_name, session_description,
         session_value,
         period_date,
         dimension,
         operator
         INTO  l_parameter_rec.parameter_name,
               l_parameter_rec.parameter_description,
               l_parameter_rec.parameter_value,
               l_parameter_rec.period_date,
               l_parameter_rec.dimension,
               l_parameter_rec.operator
         FROM   BIS_USER_ATTRIBUTES
         WHERE  dimension = l_dimension
         AND    user_id = p_user_session_rec.user_id
         AND    page_id = p_user_session_rec.page_id;
         END;
         x_paramportlet_param_tbl(l_index) := l_parameter_rec;
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

PROCEDURE RETRIEVE_SCHEDULE_PARAMETERS
(p_schedule_id	    IN	NUMBER
,x_user_param_tbl	OUT	NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) IS

/*
 l_index NUMBER := 1;
 l_parameter_rec parameter_rec_type;
 CURSOR c_parameter_cursor IS
 SELECT attribute_name
 FROM   BIS_USER_ATTRIBUTES
 WHERE  schedule_id = p_schedule_id;
BEGIN
 FOR c_parameter_rec in c_parameter_cursor LOOP
     l_parameter_rec.parameter_name := c_parameter_rec.attribute_name;
     RETRIEVE_SCHEDULE_PARAMETER (p_parameter_rec => l_parameter_rec
                                 ,p_schedule_id	=> p_schedule_id
                                 ,x_return_status => x_return_status
                                 ,x_msg_count => x_msg_count
                                 ,x_msg_data	=> x_msg_data);
     x_user_param_tbl(l_index) := l_parameter_rec;
     l_index := l_index + 1;
 END LOOP;
*/

 l_index NUMBER := 1;
 l_parameter_rec parameter_rec_type;

 CURSOR c_schedule_params_cursor IS
 SELECT attribute_name,
        session_description,
        session_value,
        period_date,
        dimension,
        operator
 FROM   BIS_USER_ATTRIBUTES
 WHERE  schedule_id = p_schedule_id;

BEGIN

 FOR c_schedule_params_rec in c_schedule_params_cursor LOOP
     l_parameter_rec.parameter_name := c_schedule_params_rec.attribute_name;
     l_parameter_rec.parameter_description := c_schedule_params_rec.session_description;
     l_parameter_rec.parameter_value := c_schedule_params_rec.session_value;
     l_parameter_rec.period_date := c_schedule_params_rec.period_date;
     l_parameter_rec.dimension := c_schedule_params_rec.dimension;
     l_parameter_rec.operator := c_schedule_params_rec.operator;
     x_user_param_tbl(l_index) := l_parameter_rec;
     l_index := l_index + 1;
 END LOOP;

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
END RETRIEVE_SCHEDULE_PARAMETERS;

PROCEDURE RETRIEVE_SESSION_PARAMETERS
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,x_user_param_tbl	OUT	NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) IS

/*
 l_index NUMBER := 1;
 l_parameter_rec parameter_rec_type;
 CURSOR c_parameter_cursor IS
 SELECT attribute_name
 FROM   BIS_USER_ATTRIBUTES
 WHERE  user_id = p_user_session_rec.user_id
 AND    session_id = p_user_session_rec.session_id
 AND    function_name = p_user_session_rec.function_name;
BEGIN
 FOR c_parameter_rec in c_parameter_cursor LOOP
     l_parameter_rec.parameter_name := c_parameter_rec.attribute_name;
     l_parameter_rec.default_flag := 'N';
     RETRIEVE_PARAMETER (p_parameter_rec => l_parameter_rec
                        ,p_user_session_rec	=> p_user_session_rec
                        ,x_return_status => x_return_status
                        ,x_msg_count => x_msg_count
                        ,x_msg_data	=> x_msg_data);
     x_user_param_tbl(l_index) := l_parameter_rec;
     l_index := l_index + 1;
 END LOOP;
*/

 l_index NUMBER := 1;
 l_parameter_rec parameter_rec_type;

 CURSOR c_session_params_cursor IS
 SELECT attribute_name,
        session_description,
        session_value,
        period_date,
        dimension,
        operator
 FROM   BIS_USER_ATTRIBUTES
 WHERE  function_name = p_user_session_rec.function_name
 AND    user_id = p_user_session_rec.user_id
 AND    session_id = p_user_session_rec.session_id
 AND    schedule_id IS NULL;

BEGIN

 FOR c_session_params_rec in c_session_params_cursor LOOP
     l_parameter_rec.parameter_name := c_session_params_rec.attribute_name;
     l_parameter_rec.parameter_description := c_session_params_rec.session_description;
     l_parameter_rec.parameter_value := c_session_params_rec.session_value;
     l_parameter_rec.period_date := c_session_params_rec.period_date;
     l_parameter_rec.dimension := c_session_params_rec.dimension;
     l_parameter_rec.operator := c_session_params_rec.operator;
     x_user_param_tbl(l_index) := l_parameter_rec;
     l_index := l_index + 1;
 END LOOP;

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
END RETRIEVE_SESSION_PARAMETERS;

PROCEDURE RETRIEVE_DEFAULT_PARAMETERS
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,x_user_param_tbl	OUT	NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) IS

/*
 l_index NUMBER := 1;
 l_parameter_rec parameter_rec_type;
 CURSOR c_parameter_cursor IS
 SELECT attribute_name
 FROM   BIS_USER_ATTRIBUTES
 WHERE  user_id = p_user_session_rec.user_id
 AND    session_id = p_user_session_rec.session_id
 AND    function_name = p_user_session_rec.function_name;
BEGIN
 FOR c_parameter_rec in c_parameter_cursor LOOP
     l_parameter_rec.parameter_name := c_parameter_rec.attribute_name;
     l_parameter_rec.default_flag := 'Y';
     RETRIEVE_PARAMETER (p_parameter_rec => l_parameter_rec
                        ,p_user_session_rec	=> p_user_session_rec
                        ,x_return_status => x_return_status
                        ,x_msg_count => x_msg_count
                        ,x_msg_data	=> x_msg_data);
     x_user_param_tbl(l_index) := l_parameter_rec;
     l_index := l_index + 1;
 END LOOP;
*/

 l_index NUMBER := 1;
 l_parameter_rec parameter_rec_type;

 CURSOR c_default_params_cursor IS
 SELECT attribute_name,
        default_description,
        default_value,
        period_date,
        dimension,
        operator
 FROM   BIS_USER_ATTRIBUTES
 WHERE  function_name = p_user_session_rec.function_name
 AND    user_id = p_user_session_rec.user_id
 AND    session_description = 'NULL'
 AND    session_id IS NULL;

BEGIN

 FOR c_default_params_rec in c_default_params_cursor LOOP
     l_parameter_rec.parameter_name := c_default_params_rec.attribute_name;
     l_parameter_rec.parameter_description := c_default_params_rec.default_description;
     l_parameter_rec.parameter_value := c_default_params_rec.default_value;
     l_parameter_rec.period_date := c_default_params_rec.period_date;
     l_parameter_rec.dimension := c_default_params_rec.dimension;
     l_parameter_rec.operator := c_default_params_rec.operator;
     x_user_param_tbl(l_index) := l_parameter_rec;
     l_index := l_index + 1;
 END LOOP;

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
END RETRIEVE_DEFAULT_PARAMETERS;

PROCEDURE DELETE_SESSION_PARAMETERS
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,p_schedule_option      IN      VARCHAR2
,x_return_Status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		OUT	NOCOPY VARCHAR2
) IS
BEGIN
  IF p_schedule_option = 'NULL' THEN
    DELETE FROM BIS_USER_ATTRIBUTES
    WHERE  user_id = p_user_session_rec.user_id
    AND    session_id = p_user_session_rec.session_id
    AND    function_name = p_user_session_rec.function_name
    AND    schedule_id IS NULL;
  ELSIF p_schedule_option = 'NOT_NULL' THEN
    DELETE FROM BIS_USER_ATTRIBUTES
    WHERE  user_id = p_user_session_rec.user_id
    AND    session_id = p_user_session_rec.session_id
    AND    function_name = p_user_session_rec.function_name
    AND    schedule_id IS NOT NULL;
  ELSE
    DELETE FROM BIS_USER_ATTRIBUTES
    WHERE  user_id = p_user_session_rec.user_id
    AND    session_id = p_user_session_rec.session_id
    AND    function_name = p_user_session_rec.function_name;
  END IF;
  COMMIT;
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
END DELETE_SESSION_PARAMETERS;

PROCEDURE DELETE_PAGE_PARAMETERS
(p_user_session_rec     IN      BIS_PMV_SESSION_PVT.session_rec_type
,x_return_status        OUT     NOCOPY VARCHAR2
,x_msg_count            OUT     NOCOPY NUMBER
,x_msg_data             OUT     NOCOPY VARCHAR2
)
IS
BEGIN
	DELETE BIS_USER_ATTRIBUTES
        WHERE user_id = p_user_session_rec.user_id
        AND page_id = p_user_session_rec.page_id;
	COMMIT;
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

END DELETE_PAGE_PARAMETERS;

PROCEDURE DELETE_DEFAULT_PARAMETERS
(p_user_session_rec     IN      BIS_PMV_SESSION_PVT.session_rec_type
,x_return_status        OUT     NOCOPY VARCHAR2
,x_msg_count            OUT     NOCOPY NUMBER
,x_msg_data             OUT     NOCOPY VARCHAR2
)
IS
BEGIN
	DELETE BIS_USER_ATTRIBUTES
        WHERE session_id is null and
        function_name = p_user_session_rec.function_name
        AND user_id=p_user_session_rec.user_id;
	COMMIT;
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

END DELETE_DEFAULT_PARAMETERS;

PROCEDURE DELETE_SCHEDULE_PARAMETERS
(p_schedule_id      IN  NUMBER
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
) IS
BEGIN
  DELETE FROM BIS_USER_ATTRIBUTES
  WHERE  schedule_id = p_schedule_id;
  COMMIT;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END DELETE_SCHEDULE_PARAMETERS;

PROCEDURE GET_NONTIME_VALIDATED_VALUE
(p_parameter_name         in varchar2
,p_parameter_description       in varchar2
,p_lov_where              in varchar2 default null
,p_region_code            in varchar2
,p_responsibility_id        in varchar2
,x_parameter_value       out NOCOPY varchar2
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) IS

   type c1_cur_type is ref cursor;
   c1                      c1_cur_type;
   v_dimn_level_value_id   varchar2(32000);
   v_dimn_level_value      varchar2(32000);
   v_sql_stmnt             varchar2(32000);
   v_temp_id               varchar2(32000);
   v_last_id               varchar2(32000);

   v_bind_sql              varchar2(32000);
   v_bind_variables        varchar2(32000);
   v_bind_count            number;

   l_and_index            NUMBER;

BEGIN

   getLovSql(p_parameter_name => p_parameter_name
            ,p_parameter_description => p_parameter_description
            ,p_sql_type => 'VALIDATE_VALUE'
            ,p_region_code => p_region_code
            ,p_responsibility_id => p_responsibility_id
            ,x_sql_statement => v_sql_stmnt
            ,x_bind_sql => v_bind_sql
            ,x_bind_variables => v_bind_variables
            ,x_bind_count => v_bind_count
            ,x_return_status => x_return_status
            ,x_msg_count => x_msg_count
            ,x_msg_data	=> x_msg_data);

   if p_lov_where is not null then
      --nbarik - 05/13/03 - Bug Fix 2955560 - put extra parenthesis for product teams where clause
      l_and_index := instr(upper(ltrim(p_lov_where)), 'AND');
      --v_sql_stmnt := replace(v_sql_stmnt, 'order by', p_lov_where||' order by');
      IF (l_and_index = 1) THEN -- put extra parenthesis after AND
        v_sql_stmnt := replace(v_sql_stmnt, 'order by', 'AND ('||substr(trim(p_lov_where), 4)||') order by');
      ELSE
        v_sql_stmnt := replace(v_sql_stmnt, 'order by', p_lov_where||' order by');
      END IF;
   end if;

   -- aleung, 08/22/01 - need the loop for multi-lov feature
   open c1 for v_sql_stmnt;
   loop
      fetch c1 into v_temp_id, v_dimn_level_value;
      exit when c1%notfound;
      if v_temp_id <> v_last_id or v_last_id is null then
         v_dimn_level_value_id := v_dimn_level_value_id ||','''||v_temp_id||'''';
      end if;
      v_last_id := v_temp_id;
   end loop;
   close c1;

   x_parameter_value := substr(v_dimn_level_value_id, 2);

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
END GET_NONTIME_VALIDATED_VALUE;

PROCEDURE GET_NONTIME_VALIDATED_ID
(p_parameter_name         in varchar2
,p_parameter_value        in varchar2
,p_lov_where              in varchar2 default null
,p_region_code            in varchar2
,p_responsibility_id      in varchar2
,x_parameter_description  out NOCOPY varchar2
,x_return_status	  OUT	NOCOPY VARCHAR2
,x_msg_count		  OUT	NOCOPY NUMBER
,x_msg_data		  OUT	NOCOPY VARCHAR2
) IS

/*
   type c1_cur_type is ref cursor;
   c1                      c1_cur_type;
*/

   v_id   		   varchar2(2000);
   v_sql_stmnt             varchar2(32000);

   v_bind_sql              varchar2(32000);
   v_bind_variables        varchar2(32000);
   v_bind_count            number;

   v_start_date date;
   v_end_date date;

BEGIN

   getLovSql(p_parameter_name => p_parameter_name
            ,p_parameter_description => p_parameter_value
            ,p_sql_type => 'VALIDATE_ID'
            ,p_region_code => p_region_code
            ,p_responsibility_id => p_responsibility_id
            ,x_sql_statement => v_sql_stmnt
            ,x_bind_sql => v_bind_sql
            ,x_bind_variables => v_bind_variables
            ,x_bind_count => v_bind_count
            ,x_return_status => x_return_status
            ,x_msg_count => x_msg_count
            ,x_msg_data	=> x_msg_data);

/*
   open c1 for v_sql_stmnt;
   loop
      fetch c1 into v_id, x_parameter_description;
      exit; --when c1%notfound;
   end loop;
   close c1;
*/

executeLovBindSQL
(p_bind_sql  => v_bind_sql
,p_bind_variables => v_bind_variables
,p_time_flag => 'N'
,x_parameter_id => v_id
,x_parameter_value => x_parameter_description
,x_start_date => v_start_date
,x_end_date => v_end_date
,x_return_status => x_return_status
,x_msg_count => x_msg_count
,x_msg_data => x_msg_data
);

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
END GET_NONTIME_VALIDATED_ID;

PROCEDURE GET_TIME_VALIDATED_VALUE
(p_parameter_name           IN  VARCHAR2
,p_parameter_description    in  varchar2
,p_region_code              in  varchar2
,p_org_name                 in  varchar2
,p_org_value                in  varchar2
,p_responsibility_id        in  varchar2
,x_parameter_value          out NOCOPY varchar2
,x_start_date               out NOCOPY date
,x_end_date                 out NOCOPY date
,x_return_status	    OUT	NOCOPY VARCHAR2
,x_msg_count		    OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) IS

/*
   type c1_cur_type is ref cursor;
   c1                      c1_cur_type;
*/
   v_value                 varchar2(2000);
   v_sql_stmnt             varchar2(32000);
   v_bind_sql              varchar2(32000);
   v_bind_variables        varchar2(32000);
   v_bind_count            number;

BEGIN
   getTimeLovSql(p_parameter_name => p_parameter_name
                ,p_parameter_description => p_parameter_description
                ,p_sql_type => 'VALIDATE_VALUE'
                ,p_region_code => p_region_code
                ,p_responsibility_id => p_responsibility_id
                ,p_org_name => p_org_name
                ,p_org_value => p_org_value
                ,x_sql_statement => v_sql_stmnt
                ,x_bind_sql => v_bind_sql
                ,x_bind_variables => v_bind_variables
                ,x_bind_count => v_bind_count
                ,x_return_status => x_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data	=> x_msg_data);

/*  aleung, 3/6/03, need to use dynamic cursor for binding
   open c1 for v_sql_stmnt;
   loop
      fetch c1 into x_parameter_value, v_value, x_start_date, x_end_date;
      exit;  --when c1%notfound;
      -- aleung, 3/2/01, obtain the first record instead of the last one
   end loop;
   close c1;
*/

executeLovBindSQL
(p_bind_sql  => v_bind_sql
,p_bind_variables => v_bind_variables
,p_time_flag => 'Y'
,x_parameter_id => x_parameter_value
,x_parameter_value => v_value
,x_start_date => x_start_date
,x_end_date => x_end_date
,x_return_status => x_return_status
,x_msg_count => x_msg_count
,x_msg_data => x_msg_data
);

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
END GET_TIME_VALIDATED_VALUE;

PROCEDURE GET_TIME_VALIDATED_ID
(p_parameter_name           IN  VARCHAR2
,p_parameter_value          in  varchar2
,p_region_code              in  varchar2
,p_org_name                 in  varchar2
,p_org_value                in  varchar2
,p_responsibility_id        in  varchar2
,x_parameter_description    out NOCOPY varchar2
,x_start_date               out NOCOPY date
,x_end_date                 out NOCOPY date
,x_return_status	    OUT	NOCOPY VARCHAR2
,x_msg_count		    OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) IS

/*
   type c1_cur_type is ref cursor;
   c1                      c1_cur_type;
*/

   v_id                    varchar2(2000);
   v_sql_stmnt             varchar2(32000);
   v_bind_sql              varchar2(32000);
   v_bind_variables        varchar2(32000);
   v_bind_count            number;

BEGIN

   getTimeLovSql(p_parameter_name => p_parameter_name
                ,p_parameter_description => p_parameter_value
                ,p_sql_type => 'VALIDATE_ID'
                ,p_region_code => p_region_code
                ,p_responsibility_id => p_responsibility_id
                ,p_org_name => p_org_name
                ,p_org_value => p_org_value
                ,x_sql_statement => v_sql_stmnt
                ,x_bind_sql => v_bind_sql
                ,x_bind_variables => v_bind_variables
                ,x_bind_count => v_bind_count
                ,x_return_status => x_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data => x_msg_data);

/* aleung, 3/6/03, need to use dynamic cursor for binding
   open c1 for v_sql_stmnt;
   loop
      fetch c1 into v_id, x_parameter_description, x_start_date, x_end_date;
      exit;  --when c1%notfound;
      -- aleung, 3/2/01, obtain the first record instead of the last one
   end loop;
   close c1;
*/

executeLovBindSQL
(p_bind_sql  => v_bind_sql
,p_bind_variables => v_bind_variables
,p_time_flag => 'Y'
,x_parameter_id => v_id
,x_parameter_value => x_parameter_description
,x_start_date => x_start_date
,x_end_date => x_end_date
,x_return_status => x_return_status
,x_msg_count => x_msg_count
,x_msg_data => x_msg_data
);

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
END GET_TIME_VALIDATED_ID;

PROCEDURE GET_TIME_INFO
(p_region_code            in  varchar2
,p_responsibility_id      in  varchar2
,p_parameter_name         in  varchar2
,p_mode                   in  varchar2
,p_date                   in  varchar2
,x_time_description       out NOCOPY varchar2
,x_time_id                out NOCOPY varchar2
,x_start_date             out NOCOPY date
,x_end_date               out NOCOPY date
,x_return_status          OUT NOCOPY VARCHAR2
,x_msg_count              OUT NOCOPY NUMBER
,x_msg_data               OUT NOCOPY VARCHAR2
) IS

   type c1_cur_type is ref cursor;
   c1                      c1_cur_type;
   v_sql_stmnt             varchar2(32000);
   v_bind_sql              varchar2(32000);
   v_bind_variables        varchar2(32000);
   v_bind_count            number;
   v_time_id               varchar2(80);
   v_start_date            date;
   v_end_date              date;
   v_date                  varchar2(100);
BEGIN

   getTimeLovSql(p_parameter_name => p_parameter_name
                ,p_parameter_description => null
                ,p_sql_type => p_mode
                ,p_date  => p_date
                ,p_region_code => p_region_code
                ,p_responsibility_id => p_responsibility_id
                ,p_org_name => null
                ,p_org_value => null
                ,x_sql_statement => v_sql_stmnt
                ,x_bind_sql => v_bind_sql
                ,x_bind_variables => v_bind_variables
                ,x_bind_count => v_bind_count
                ,x_return_status => x_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data     => x_msg_data);

   if p_date is null or length(p_date) = 0 then
      v_date := SYSDATE;
   else
      v_date := p_date;
   end if;

   open c1 for v_bind_sql using v_date;
   --open c1 for v_sql_stmnt;
   loop
      fetch c1 into x_time_id, x_time_description, x_start_date, x_end_date;
      exit;  --when c1%notfound;
      -- aleung, 3/2/01, obtain the first record instead of the last one
   end loop;
   close c1;

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
END GET_TIME_INFO;

PROCEDURE getLOVSQL
(p_parameter_name  in varchar2
,p_parameter_description       in varchar2
,p_sql_type               in varchar2 default null
,p_region_code            in varchar2
,p_responsibility_id        in varchar2
,x_sql_statement         out NOCOPY varchar2
,x_bind_sql              out NOCOPY varchar2
,x_bind_variables        out NOCOPY varchar2
,x_bind_count            out NOCOPY number
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) is

/*
cursor c_level_values_view_name (cp_parameter_name varchar2, cp_region_code varchar2) is
      select attribute15 level_values_view_name, substr(attribute2, 1, instr(attribute2, '+')-1) dimension ,substr(attribute2,instr(attribute2, '+')+1) dimension_level
      from   ak_region_items_vl
      where  nvl(attribute2,attribute_code) = rtrim(cp_parameter_name)
      and  region_code  = rtrim(cp_region_code);

	  ----GSANAP for EDW purposes 10/17/00
cursor c_edw_level_values_view_name (cp_parameter_name varchar2, cp_region_code varchar2) is
      select vl.attribute15 level_values_view_name, substr(vl.attribute2, instr(vl.attribute2, '+')+1) dimension_level
        from ak_region_items_vl vl, ak_regions r
       where nvl(vl.attribute2,vl.attribute_code) LIKE rtrim(cp_parameter_name)
         and vl.region_code  = rtrim(cp_region_code)
         and vl.region_code = r.region_code
         and lower(r.region_object_type) = 'edw' ;
*/

--aleung, 9/26/02, combine the 2 above cursors into 1
--ksadagop BugFix 3351910, added lov where clause
cursor c_level_values_view_name (cp_parameter_name varchar2, cp_region_code varchar2) is
       select vl.attribute15,  -- level view name
              substr(vl.attribute2, 1, instr(vl.attribute2,'+')-1), -- dimension
              substr(vl.attribute2, instr(vl.attribute2,'+')+1), -- dimension level
              nvl(r.region_object_type, 'OLTP'), -- level type
	          vl.attribute4  -- lov where clause
       from   ak_region_items vl, ak_regions r
       where  nvl(vl.attribute2,vl.attribute_code) = rtrim(cp_parameter_name)
       and    vl.region_code  = rtrim(cp_region_code)
       and    vl.region_code = r.region_code;

   v_edw_level_values_view_name  varchar2(2000) := null;
   vEdwDimensionLevel            varchar2(2000)  := null;

   v_level_values_view_name  varchar2(32000);
   v_sql_stmnt               varchar2(32000);
   v_bind_sql                varchar2(32000);
   v_bind_variables          varchar2(32000);
   v_bind_count              number := 0;
   vDimension                varchar2(32000);
   vDimensionLevel           varchar2(32000);
   vLevelType                varchar2(100);
   vLovWhereClause           varchar2(32000);

   v_table_name VARCHAR2(32000);
   v_id_name VARCHAR2(32000) := 'ID';
   v_value_name VARCHAR2(32000) := 'VALUE';
   v_return_status VARCHAR2(32000);
   v_msg_count NUMBER;
   v_msg_data VARCHAR2(32000);
    --bind variables introduced for performance fix 2641735 -ansingh.
    v_bindVar_1 varchar2(3);
    v_bindVar_2 varchar2(3);
    v_bindVar_3 varchar2(3);
    v_bindVar_4 varchar2(3);

	/* Bug Fix : 3044997 */
   	v_index1 number := 0 ;
   	v_index2 number := 0 ;
   	v_parameter_name varchar2(2000) ;

BEGIN

/*
   -- validate LOV value
   open c_level_values_view_name (p_parameter_name,p_region_code);
   fetch c_level_values_view_name into v_level_values_view_name, vDimension, vDimensionLevel;
   close c_level_values_view_name;

 ----GSANAP for EDW purposes 10/17/00
   open c_edw_level_values_view_name (p_parameter_name,p_region_code);
   fetch c_edw_level_values_view_name into v_edw_level_values_view_name, vEdwDimensionLevel;
   close c_edw_level_values_view_name;
*/

	/* Bug Fix : 3044997 */
--  Parameter Names of repeated dimension items are in the form A+B+C,A+B+D etc
--  Need to pass A+B to c_level_values_view_name
-- open c_level_values_view_name (p_parameter_name,p_region_code);
   v_parameter_name := p_parameter_name ;
   v_index1 := instr(p_parameter_name,'+') ;
   v_index2 := instr(p_parameter_name, '+', v_index1+1) ;
   if ((v_index2 > 0) AND (v_index2 > v_index1)) then
        v_parameter_name := substr(p_parameter_name,1,v_index2-1);
   end if ;

   --ksadagop BugFix 3351910, added lov where clause
   open c_level_values_view_name (v_parameter_name,p_region_code);
   fetch c_level_values_view_name into v_level_values_view_name, vDimension, vDimensionLevel, vLevelType, vLovWhereClause;
   close c_level_values_view_name;
   if upper(vLevelType) = 'EDW' then
      vLevelType := 'EDW';
   else
      vLevelType := 'OLTP';
   end if;

   if v_level_values_view_name is not null then
     v_sql_stmnt := 'select '||v_id_name||', '||v_value_name||' from '||v_level_values_view_name;
   else
     BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING(
        p_DimLevelShortName => vDimensionLevel
        ,p_bis_source => vLevelType
        ,x_Select_String => v_sql_stmnt
        ,x_table_name=>     v_table_name
        ,x_id_name=>        v_id_name
        ,x_value_name=>     v_value_name
        ,x_return_status=>  v_return_status
        ,x_msg_count=>      v_msg_count
        ,x_msg_data=>       v_msg_data
      );
   end if;

/*
   if vEdwDimensionLevel is not null then

--aleung, 4/16/2001, check to see if user has defined the LOV Table in AK
if v_edw_level_values_view_name is not null then
     v_sql_stmnt := 'select '||v_id_name||', '||v_value_name||' from '||
                     v_edw_level_values_view_name;
else
     BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING(
        p_DimLevelShortName => vEdwDimensionLevel
        ,p_bis_source => 'EDW'
        ,x_Select_String => v_sql_stmnt
        ,x_table_name=>     v_table_name
        ,x_id_name=>        v_id_name
        ,x_value_name=>     v_value_name
        ,x_return_status=>  v_return_status
        ,x_msg_count=>      v_msg_count
        ,x_msg_data=>       v_msg_data
      );
end if;

   else -- vEdwDimensionLevel is null

--aleung, 4/16/2001, check to see if user has defined the LOV Table in AK
if v_level_values_view_name is not null then
     v_sql_stmnt := 'select '||v_id_name||', '||v_value_name||' from '||
                     v_level_values_view_name;
else
       BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING(
         p_DimLevelShortName => vDimensionLevel
         ,p_bis_source => 'OLTP'
         ,x_Select_String => v_sql_stmnt
         ,x_table_name=>     v_table_name
         ,x_id_name=>        v_id_name
         ,x_value_name=>     v_value_name
         ,x_return_status=>  v_return_status
         ,x_msg_count=>      v_msg_count
         ,x_msg_data=>       v_msg_data
       );
end if;

    end if; -- end of constructing the select string
*/

 v_bind_sql := v_sql_stmnt;

 if v_return_status = FND_API.G_RET_STS_ERROR then
    for i in 1..v_msg_count loop
        htp.print(fnd_msg_pub.get(p_msg_index=>i, p_encoded=>FND_API.G_FALSE));
    end loop;
 end if;

if (upper(nvl(p_parameter_description, G_ALL)) <> upper(G_ALL) AND trim(p_parameter_description) <> '%')  then

if p_sql_type = 'VALIDATE_ID' then
  v_sql_stmnt := v_sql_stmnt || ' where ' || v_id_name || '=''' || p_parameter_description || '''';
  v_bind_count := v_bind_count + 1;
  v_bind_sql := v_bind_sql || ' where ' || v_id_name || '= :'||v_bind_count;
  v_bind_variables := v_bind_variables||'~'||p_parameter_description;
else
 if p_sql_type = 'LOV' then
    if instr(p_parameter_description,',,') > 0 then
       v_sql_stmnt := v_sql_stmnt || ' where lower('||v_value_name||') in ';
       v_bind_sql := v_bind_sql || ' where lower('||v_value_name||') in ';
    else
       v_sql_stmnt := v_sql_stmnt || ' where lower('||v_value_name||') like ';
       v_bind_sql := v_bind_sql || ' where lower('||v_value_name||') like ';
    end if;
 elsif instr(p_parameter_description,',,') > 0 then
    v_sql_stmnt := v_sql_stmnt || ' where '||v_value_name||' in ';
    v_bind_sql := v_bind_sql || ' where '||v_value_name||' in ';
/*
--BugFix#2537114 -Anoop Start
 elsif (upper(nvl(p_parameter_description, G_ALL)) = upper(G_ALL) OR trim(p_parameter_description) = '%')  then
	 v_sql_stmnt := v_sql_stmnt ||' where '||v_value_name||' like ';
	 v_bind_sql := v_bind_sql ||' where '||v_value_name||' like ';
--BugFix#2537114 -Anoop End
*/
 else
    v_sql_stmnt := v_sql_stmnt || ' where '||v_value_name||' = ';
    v_bind_sql := v_bind_sql || ' where '||v_value_name||' = ';
 end if;
/*
--     if p_parameter_description = G_ALL then
     if upper(nvl(p_parameter_description, G_ALL)) = upper(G_ALL) then
        v_sql_stmnt := v_sql_stmnt||'''%''';
        v_bind_count := v_bind_count + 1;
        v_bind_sql := v_bind_sql||':'||v_bind_count;
        v_bind_variables := v_bind_variables ||'~%';
     else
*/
        if p_sql_type = 'LOV' then
           if instr(p_parameter_description, ',,')>0 then
              v_sql_stmnt := v_sql_stmnt||'('''||replace(replace(replace(lower(p_parameter_description),'''',''''''),',,',''','''),''' ','''')||''')';
              v_bind_sql := v_bind_sql||'('''||replace(replace(replace(lower(p_parameter_description),'''',''''''),',,',''','''),'''','''')||''')';
           else
              v_sql_stmnt := v_sql_stmnt||''''||'%'||replace(lower(p_parameter_description),'''','''''')||'%''';
              v_bind_count := v_bind_count + 1;
              v_bind_sql := v_bind_sql||':'||v_bind_count;
              v_bind_variables := v_bind_variables||'~%'||lower(p_parameter_description)||'%';	--add % before the input  -ansingh
	  		  --bind variables introduced for performance fix 2641735 -ansingh.
              if (length(p_parameter_description) > 2) then
			      v_bindVar_1 := lower(SUBSTR(p_parameter_description, 1, 2));
			      v_bindVar_2 := upper(SUBSTR(p_parameter_description, 1, 2));
			      v_bindVar_3 := upper(SUBSTR(p_parameter_description, 1, 1)) || lower(SUBSTR(p_parameter_description, 2, 1));
			      v_bindVar_4 := lower(SUBSTR(p_parameter_description, 1, 1)) || upper(SUBSTR(p_parameter_description, 2, 1));
	              --bind sql
	  		      v_bind_sql := v_bind_sql || ' AND ( ';
			      for i in 1..4 loop
			          v_bind_count := v_bind_count + 1;
			          v_bind_sql := v_bind_sql || v_value_name || ' like :' || v_bind_count;
			          if (i<>4) then
			              v_bind_sql := v_bind_sql || ' OR ';
			          else
			              v_bind_sql := v_bind_sql || ' ) ';
			          end if;
			      end loop;
	              --bind variables
			      v_bind_variables := v_bind_variables||'~%'|| v_bindVar_1 || '%~%' || v_bindVar_2 || '%~%' || v_bindVar_3 || '%~%' || v_bindVar_4 || '%';   --add % before the input  -ansingh
              elsif (length(p_parameter_description) = 2) then
			      v_bindVar_1 := upper(SUBSTR(p_parameter_description, 1, 1)) || lower(SUBSTR(p_parameter_description, 2, 1));
			      v_bindVar_2 := lower(SUBSTR(p_parameter_description, 1, 1)) || upper(SUBSTR(p_parameter_description, 2, 1));
	              --bind sql
	  		      v_bind_sql := v_bind_sql || ' AND ( ';
			      for i in 1..2 loop
			          v_bind_count := v_bind_count + 1;
			          v_bind_sql := v_bind_sql || v_value_name || ' like :' || v_bind_count;
			          if (i<>2) then
			              v_bind_sql := v_bind_sql || ' OR ';
			          else
			              v_bind_sql := v_bind_sql || ' ) ';
			          end if;
			      end loop;
	              --bind variables
			      v_bind_variables := v_bind_variables||'~%'|| v_bindVar_1 || '%~%' || v_bindVar_2 || '%';			--add % before the input  -ansingh
              end if;
           end if;
        elsif instr(p_parameter_description, ',,')>0 then
           v_sql_stmnt := v_sql_stmnt||'('''||replace(replace(replace(p_parameter_description,'''',''''''),',,',''','''),''' ','''')||''')';
           v_bind_sql := v_bind_sql||'('''||replace(replace(replace(p_parameter_description,'''',''''''),',,',''','''),''' ','''')||''')';
        else
           v_sql_stmnt := v_sql_stmnt||''''||replace(p_parameter_description,'''','''''')||'''';
           v_bind_count := v_bind_count + 1;
           v_bind_sql := v_bind_sql||':'||v_bind_count;
           v_bind_variables := v_bind_variables||'~'||p_parameter_description;
        end if;
     --end if;
end if;
  --ksadagop BugFix 3351910, added lov where clause
  if (length(trim(vLovWhereClause)) > 0 and instr(trim(vLovWhereClause),'{') = 0) then
    v_sql_stmnt := v_sql_stmnt || ' ' || vLovWhereClause;
    v_bind_sql := v_bind_sql || ' ' || vLovWhereClause;
  end if;
else
  v_sql_stmnt := v_sql_stmnt || ' where 1=1 ';
  v_bind_sql := v_bind_sql || ' where 1=1 ';
end if; -- end of constructing the where clause

     --sess_id , aleung, 1/8/2001, remove dependency on responsibility id
     --assuming same organization dimension level value has same value id
     --for non-EDW reports
     if vLevelType = 'OLTP' and vDimension = 'ORGANIZATION' and p_responsibility_id <> 'NULL'
     and vDimensionLevel in ('LEGAL ENTITY','OPERATING UNIT','HR ORGANIZATION','ORGANIZATION','SET OF BOOKS',
     'BUSINESS GROUP','HRI_ORG_HRCY_BX','HRI_ORG_HRCYVRSN_BX','HRI_ORG_HR_HX','HRI_ORG_INHV_H','HRI_ORG_SSUP_H',
     'HRI_ORG_BGR_HX','HRI_ORG_HR_H','HRI_ORG_SRHL') then
          v_sql_stmnt := v_sql_stmnt || ' and responsibility_id = ' || '' || p_responsibility_id || '';
          v_bind_count := v_bind_count + 1;
          v_bind_sql := v_bind_sql || ' and responsibility_id = :'|| v_bind_count;
          v_bind_variables := v_bind_variables||'~'||p_responsibility_id;
     end if;

  if p_sql_type <> 'VALIDATE_ID' then
     v_sql_stmnt := v_sql_stmnt ||' order by '||v_value_name;
     v_bind_sql := v_bind_sql ||' order by '||v_value_name;
  end if;

     x_sql_statement := v_sql_stmnt;
     x_bind_sql := v_bind_sql;
     x_bind_variables := v_bind_variables;
     x_bind_count := v_bind_count;

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
END getLOVSQL;

PROCEDURE getTimeLovSql
(p_parameter_name in varchar2
,p_parameter_description in varchar2
,p_sql_type              in varchar2 default null
,p_date                  in varchar2 default null
,p_region_code           in varchar2
,p_responsibility_id       in varchar2
,p_org_name               in varchar2
,p_org_value               in varchar2
,x_sql_statement        out NOCOPY varchar2
,x_bind_sql             out NOCOPY varchar2
,x_bind_variables       out NOCOPY varchar2
,x_bind_count           out NOCOPY number
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
)is

/*
cursor c_level_values_view_name (cp_parameter_name varchar2, cp_region_code varchar2) is
      select attribute15 level_values_view_name, substr(attribute2,instr(attribute2, '+')+1) dimension_level
      from   ak_region_items_vl
      where  nvl(attribute2,attribute_code) = rtrim(cp_parameter_name)
      and  region_code  = rtrim(cp_region_code);

	    ----GSANAP for EDW purposes 10/17/00
      cursor c_edw_tmlvl_values_view_name (cp_parameter_name varchar2, cp_region_code varchar2) is
      select vl.attribute15 edw_level_values_view_name, substr(vl.attribute2, instr(vl.attribute2, '+')+1) dimension_level
        from ak_region_items_vl vl, ak_regions r
       where nvl(vl.attribute2,vl.attribute_code) LIKE rtrim(cp_parameter_name)
         and vl.region_code  = rtrim(cp_region_code)
         and vl.region_code = r.region_code
         and lower(r.region_object_type) = 'edw';
*/
      --aleung, 9/26/02, combine the above 2 cursors into 1
      cursor c_tmlvl_values_view_name (cp_parameter_name varchar2, cp_region_code varchar2) is
      select vl.attribute15, -- view name
             substr(vl.attribute2, instr(vl.attribute2, '+')+1), -- dimension level
             nvl(r.region_object_type, 'OLTP') -- level type
        from ak_region_items vl, ak_regions r
       where nvl(vl.attribute2,vl.attribute_code) = rtrim(cp_parameter_name)
         and vl.region_code  = rtrim(cp_region_code)
         and vl.region_code = r.region_code;

       cursor c_nested_region(cp_region_code varchar2) is
       select  nested_region_code
         from  ak_region_items
         where region_code = cp_region_code
         and   nested_region_code is not null;

   v_edw_tmlvl_values_view_name   varchar2(2000) := null;

   v_level_values_view_name   varchar2(2000);
   v_sql_stmnt                varchar2(32000);
   v_bind_sql                 varchar2(32000);
   v_bind_variables           varchar2(32000);
   v_bind_count               number := 0;
   vAttributeName             varchar2(2000);
   vOrgId                     varchar2(2000);

   vLevelType                 varchar2(100);
   vEdwDimensionLevel            varchar2(2000);
   vDimensionLevel               varchar2(2000);
   v_table_name VARCHAR2(2000);
   v_id_name VARCHAR2(2000) := 'ID';
   v_value_name VARCHAR2(2000) := 'VALUE';
   v_return_status VARCHAR2(2000);
   v_msg_count NUMBER;
   v_msg_data VARCHAR2(2000);

   v_date varchar2(100);
   l_nested_region_code varchar2(240);
   vDimension varchar2(2000);

BEGIN

 if p_date is null or length(p_date) = 0 then
    v_date := SYSDATE;
 else
    v_date := p_date;
 end if;

/*
   -- validate LOV value
   open c_level_values_view_name (p_parameter_name,p_region_code);
   fetch c_level_values_view_name into v_level_values_view_name, vDimensionLevel;
   close c_level_values_view_name;

----GSANAP 10/17/00 for EDW purposes
   open c_edw_tmlvl_values_view_name (p_parameter_name,p_region_code);
   fetch c_edw_tmlvl_values_view_name into v_edw_tmlvl_values_view_name, vEdwDimensionLevel;
   close c_edw_tmlvl_values_view_name;
*/
 if (p_region_code is null or length(p_region_code) = 0) then
    vDimension := substr(p_parameter_name ,1,instr(p_parameter_name ,'+')-1);
    if upper(vDimension) = 'EDW_TIME_M' then
        vEdwDimensionLevel := substr(p_parameter_name, instr(p_parameter_name, '+')+1);
    else
        vDimensionLevel := substr(p_parameter_name, instr(p_parameter_name, '+')+1);
    end if;
 else
   BEGIN
     open c_tmlvl_values_view_name (p_parameter_name,p_region_code);
     fetch c_tmlvl_values_view_name into v_level_values_view_name, vDimensionLevel, vLevelType;
     close c_tmlvl_values_view_name;
   EXCEPTION WHEN OTHERS THEN
     NULL;
   END;

   if(vDimensionLevel is null) then
     open c_nested_region(p_region_code);
     fetch c_nested_region into l_nested_region_code;
     close c_nested_region;
     if(l_nested_region_code is not null) then
       open c_tmlvl_values_view_name (p_parameter_name,l_nested_region_code);
       fetch c_tmlvl_values_view_name into v_level_values_view_name, vDimensionLevel, vLevelType;
       close c_tmlvl_values_view_name;
     end if;
   end if;


   if upper(vLevelType) = 'EDW' then
      v_edw_tmlvl_values_view_name := v_level_values_view_name;
      vEdwDimensionLevel := vDimensionLevel;
   end if;
 end if;

   if  vEdwDimensionLevel is not null then
--aleung, 4/16/2001, check to see if user has defined the LOV Table in AK
if v_edw_tmlvl_values_view_name is not null then
     v_sql_stmnt := 'select distinct '||v_id_name||', '||v_value_name;
     if rtrim(ltrim(vEdwDimensionLevel)) <> 'EDW_TIME_A' then
         v_sql_stmnt := v_sql_stmnt || ', start_date, end_date';
     end if;

--BugFix#2537114 this should be ' from ' and not 'from ' -Anoop
--     v_sql_stmnt := v_sql_stmnt || 'from '||v_edw_tmlvl_values_view_name;

     v_sql_stmnt := v_sql_stmnt || ' from '||v_edw_tmlvl_values_view_name;
     v_table_name := v_edw_tmlvl_values_view_name;
else
	 BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING(
         p_DimLevelShortName => vEdwDimensionLevel
         ,p_bis_source => 'EDW'
         ,x_Select_String => v_sql_stmnt
         ,x_table_name=>     v_table_name
         ,x_id_name=>        v_id_name
         ,x_value_name=>     v_value_name
         ,x_return_status=>  v_return_status
         ,x_msg_count=>      v_msg_count
         ,x_msg_data=>       v_msg_data
       );
      --end if;
      if v_return_status = FND_API.G_RET_STS_ERROR then
         for i in 1..v_msg_count loop
             htp.print(fnd_msg_pub.get(p_msg_index=>i, p_encoded=>FND_API.G_FALSE));
         end loop;
      end if;

      if rtrim(ltrim(vEdwDimensionLevel)) = 'EDW_TIME_A' then
         v_sql_stmnt := 'select distinct '||v_id_name||', '||v_value_name||' from '||v_table_name;
      end if;
end if;

 v_bind_sql := v_sql_stmnt;

 -- Change this to v_date - amkulkar
 if p_sql_type = 'GET_CURRENT' then
    v_sql_stmnt := v_sql_stmnt || ' where ''' ||v_date||''' between start_date and end_date ';
    v_bind_count := v_bind_count + 1;
    v_bind_sql := v_bind_sql || ' where :'||v_bind_count||' between start_date and end_date ';
    v_bind_variables := v_bind_variables||'~'||v_date;
 elsif p_sql_type = 'GET_PREVIOUS' then
    v_sql_stmnt := v_sql_stmnt || ' where end_date = (select max(end_date) from '
                               || v_table_name || ' where ''' ||v_date|| ''' > end_date) ';
    v_bind_count := v_bind_count + 1;
    v_bind_sql := v_bind_sql || ' where end_date = (select max(end_date) from '
                             || v_table_name || ' where :' ||v_bind_count|| ' > end_date) ';
    v_bind_variables := v_bind_variables||'~'||v_date;
 elsif p_sql_type = 'GET_NEXT' then
    v_sql_stmnt := v_sql_stmnt || ' where start_date = (select min(start_date) from '
                               || v_table_name || ' where ''' ||v_date|| ''' < start_date) ';
    v_bind_count := v_bind_count + 1;
    v_bind_sql := v_bind_sql || ' where start_date = (select min(start_date) from '
                             || v_table_name || ' where :' ||v_bind_count|| ' < start_date) ';
    v_bind_variables := v_bind_variables||'~'||v_date;
 else

  if (upper(nvl(p_parameter_description, G_ALL)) <> upper(G_ALL) AND trim(p_parameter_description) <> '%')  then
    if p_sql_type = 'VALIDATE_ID' then
      v_sql_stmnt := v_sql_stmnt || ' where ' || v_id_name || '=''' || p_parameter_description || '''';
      v_bind_count := v_bind_count + 1;
      v_bind_sql := v_bind_sql || ' where ' || v_id_name || '= :' || v_bind_count;
      v_bind_variables := v_bind_variables||'~'||p_parameter_description;
    else
      if p_sql_type = 'LOV' then
	 v_sql_stmnt := v_sql_stmnt ||' where lower('||v_value_name||') like ';
	 v_bind_sql := v_bind_sql ||' where lower('||v_value_name||') like ';
/*
      elsif p_parameter_description = G_ALL then
	 v_sql_stmnt := v_sql_stmnt ||' where '||v_value_name||' like ';
	 v_bind_sql := v_bind_sql ||' where '||v_value_name||' like ';
*/

      else
	 v_sql_stmnt := v_sql_stmnt ||' where '||v_value_name||' = ';
	 v_bind_sql := v_bind_sql ||' where '||v_value_name||' = ';
      end if;
/*
      if p_parameter_description = G_ALL then
         v_sql_stmnt := v_sql_stmnt||'''%''';
         v_bind_count := v_bind_count + 1;
         v_bind_sql := v_bind_sql||':'||v_bind_count;
         v_bind_variables := v_bind_variables || '~%';
      else
*/
         if p_sql_type = 'LOV' then
            v_sql_stmnt := v_sql_stmnt||'''%'||replace(lower(p_parameter_description),'''','''''')||'%''';
            v_bind_count := v_bind_count + 1;
            v_bind_sql := v_bind_sql||':'||v_bind_count;
            v_bind_variables := v_bind_variables||'~%'||lower(p_parameter_description)||'%'; --rcmuthuk: Prepend % before parameter
         else
            v_sql_stmnt := v_sql_stmnt||''''||replace(p_parameter_description,'''','''''')||'''';
            v_bind_count := v_bind_count + 1;
            v_bind_sql := v_bind_sql||':'||v_bind_count;
            v_bind_variables := v_bind_variables||'~'||p_parameter_description;
         end if;
      --end if;
     end if; -- end of validate_id
   end if; --end of if not all

      if rtrim(ltrim(vEdwDimensionLevel)) <> 'EDW_TIME_A' then
         v_sql_stmnt := v_sql_stmnt||' order by start_date';
         v_bind_sql := v_bind_sql||' order by start_date';
      end if;
 end if;

      x_sql_statement := v_sql_stmnt;
      x_bind_sql := v_bind_sql;
      x_bind_variables := v_bind_variables;
      x_bind_count := v_bind_count;

   else


--aleung, 4/16/2001, check to see if user has defined the LOV Table in AK
if v_level_values_view_name is not null then
     v_sql_stmnt := 'select '||v_id_name||', '||v_value_name||', start_date, end_date from '||
                     v_level_values_view_name;
     v_table_name := v_level_values_view_name;
else
       BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING(
         p_DimLevelShortName => vDimensionLevel
         ,p_bis_source => 'OLTP'
         ,x_Select_String => v_sql_stmnt
         ,x_table_name=>     v_table_name
         ,x_id_name=>        v_id_name
         ,x_value_name=>     v_value_name
         ,x_return_status=>  v_return_status
         ,x_msg_count=>      v_msg_count
         ,x_msg_data=>       v_msg_data
       );

       if v_return_status = FND_API.G_RET_STS_ERROR then
          for i in 1..v_msg_count loop
              htp.print(fnd_msg_pub.get(p_msg_index=>i, p_encoded=>FND_API.G_FALSE));
          end loop;
       end if;
end if;

 v_bind_sql := v_sql_stmnt;

 if p_sql_type = 'GET_CURRENT' then
    v_sql_stmnt := v_sql_stmnt || ' where ''' ||v_date||''' between start_date and end_date ';
    v_bind_count := v_bind_count + 1;
    v_bind_sql := v_bind_sql || ' where :'||v_bind_count||' between start_date and end_date ';
    v_bind_variables := v_bind_variables||'~'||v_date;
 elsif p_sql_type = 'GET_PREVIOUS' then
    v_sql_stmnt := v_sql_stmnt || ' where end_date = (select max(end_date) from '
                               || v_table_name || ' where ''' ||v_date|| ''' > end_date) ';
    v_bind_count := v_bind_count + 1;
    v_bind_sql := v_bind_sql || ' where end_date = (select max(end_date) from '
                             || v_table_name || ' where :' ||v_bind_count|| ' > end_date) ';
    v_bind_variables := v_bind_variables||'~'||v_date;
 elsif p_sql_type = 'GET_NEXT' then
    v_sql_stmnt := v_sql_stmnt || ' where start_date = (select min(start_date) from '
                               || v_table_name || ' where ''' ||v_date|| ''' < start_date) ';
    v_bind_count := v_bind_count + 1;
    v_bind_sql := v_bind_sql || ' where start_date = (select min(start_date) from '
                             || v_table_name || ' where :' ||v_bind_count|| ' < start_date) ';
    v_bind_variables := v_bind_variables||'~'||v_date;
 else
  if (upper(nvl(p_parameter_description, G_ALL)) <> upper(G_ALL) AND trim(p_parameter_description) <> '%')  then
    if p_sql_type = 'VALIDATE_ID' then
      v_sql_stmnt := v_sql_stmnt || ' where ' || v_id_name || '=''' || p_parameter_description || '''';
      v_bind_count := v_bind_count + 1;
      v_bind_sql := v_bind_sql || ' where ' || v_id_name || '= :' || v_bind_count;
      v_bind_variables := v_bind_variables||'~'||p_parameter_description;
    else
      if p_sql_type = 'LOV' then
	 v_sql_stmnt := v_sql_stmnt ||' where lower('||v_value_name||') like ';
	 v_bind_sql := v_bind_sql ||' where lower('||v_value_name||') like ';
/*
      elsif p_parameter_description = G_ALL then
	 v_sql_stmnt := v_sql_stmnt ||' where '||v_value_name||' like ';
	 v_bind_sql := v_bind_sql ||' where '||v_value_name||' like ';
*/
      else
	 v_sql_stmnt := v_sql_stmnt ||' where '||v_value_name||' = ';
	 v_bind_sql := v_bind_sql ||' where '||v_value_name||' = ';
      end if;

/*
      -- remove upper() to fix LOV error when value does not exist (aleung, 9/19/2000)
      -- if upper(p_parameter_description) = G_ALL then
      if p_parameter_description = G_ALL then
         v_sql_stmnt := v_sql_stmnt||'''%''';
         v_bind_count := v_bind_count + 1;
         v_bind_sql := v_bind_sql||':'||v_bind_count;
         v_bind_variables := v_bind_variables || '~%';
      else
*/
         if p_sql_type = 'LOV' then
            v_sql_stmnt := v_sql_stmnt||''''||replace(lower(p_parameter_description),'''','''''')||'%''';
            v_bind_count := v_bind_count + 1;
            v_bind_sql := v_bind_sql||':'||v_bind_count;
            v_bind_variables := v_bind_variables||'~'||lower(p_parameter_description)||'%';
         else
            v_sql_stmnt := v_sql_stmnt||''''||replace(p_parameter_description,'''','''''')||'''';
            v_bind_count := v_bind_count + 1;
            v_bind_sql := v_bind_sql||':'||v_bind_count;
            v_bind_variables := v_bind_variables||'~'||p_parameter_description;
         end if;
      --end if;
    end if; -- end of validate_id case
  else
     v_sql_stmnt := v_sql_stmnt || ' where 1=1 ';
     v_bind_sql := v_bind_sql || ' where 1=1 ';
  end if; -- end of if not all

  -- aleung, 5/11/01, no organization dependency for OLTP dimension level starts with HR
  if vDimensionLevel in ('MONTH','QUARTER','YEAR','TOTAL_TIME') then
  --and SUBSTR(vDimensionLevel, 1, 2) <> 'HR' and substr(vAttributeName,1,2) <> 'HR' then

      if upper(nvl(p_org_value, G_ALL)) <> upper(G_ALL) then
         vAttributeName := substr(p_org_name, instr(p_org_name, '+')+1);
         GET_NONTIME_VALIDATED_VALUE (p_parameter_name => p_org_name
                                     ,p_parameter_description => p_org_value
                                     ,p_region_code => p_Region_Code
                                     ,p_responsibility_id => p_responsibility_id
                                     ,x_parameter_value => vorgId
                                     ,x_return_status => x_return_status
                                     ,x_msg_count => x_msg_count
                                     ,x_msg_data => x_msg_data);
      else
         vAttributeName := 'TOTAL_ORGANIZATIONS';
         vOrgId := '''-1''';
      end if;

         if instr(vOrgId,''',''') > 0 then
            v_sql_stmnt := v_sql_stmnt || ' and organization_id in ('||vOrgId||')';
            v_bind_sql := v_bind_sql || ' and organization_id in ('||vOrgId||')';
         else
            v_sql_stmnt := v_sql_stmnt || ' and organization_id = '  || vOrgId;
            v_bind_count := v_bind_count + 1;
            v_bind_sql := v_bind_sql || ' and organization_id = :'  || v_bind_count;
            v_bind_variables := v_bind_variables || '~' || vOrgId;
         end if;
         v_sql_stmnt := v_sql_stmnt || '  and organization_type = ' || '''' || vAttributeName ||'''';
         v_bind_count := v_bind_count + 1;
         v_bind_sql := v_bind_sql || '  and organization_type = :' || v_bind_count;
         v_bind_variables := v_bind_variables || '~' || vAttributeName;
    end if;

    if p_sql_type <> 'VALIDATE_ID' then
      v_sql_stmnt := v_sql_stmnt||' order by start_date';
      v_bind_sql := v_bind_sql||' order by start_date';
    end if;

 end if;

      x_sql_statement := v_sql_stmnt;
      x_bind_sql := v_bind_sql;
      x_bind_variables := v_bind_variables;
      x_bind_count := v_bind_count;

   end if;

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
END getTimeLovSql;

procedure saveParameters
(pRegionCode       in varchar2,
 pFunctionName     in varchar2,
 pPageId           in Varchar2 default null,
 pSessionId        in Varchar2 default null,
 pUserId           in Varchar2 default null,
 pResponsibilityId in Varchar2 default null,
 pApplicationId    in varchar2 default null,
 pOrgParam         in number   default 0,
 pHierarchy1 in varchar2 default null,
 pHierarchy2 in varchar2 default null,
 pHierarchy3 in varchar2 default null,
 pHierarchy4 in varchar2 default null,
 pHierarchy5 in varchar2 default null,
 pHierarchy6 in varchar2 default null,
 pHierarchy7 in varchar2 default null,
 pHierarchy8 in varchar2 default null,
 pHierarchy9 in varchar2 default null,
 pHierarchy10 in varchar2 default null,
 pHierarchy11 in varchar2 default null,
 pHierarchy12 in varchar2 default null,
 pHierarchy13 in varchar2 default null,
 pHierarchy14 in varchar2 default null,
 pHierarchy15 in varchar2 default null,
 pParameter1       in varchar2 default null,
 pParameterValue1  in varchar2 default null,
 pParameter2       in varchar2 default null,
 pParameterValue2  in varchar2 default null,
 pParameter3       in varchar2 default null,
 pParameterValue3  in varchar2 default null,
 pParameter4       in varchar2 default null,
 pParameterValue4  in varchar2 default null,
 pParameter5       in varchar2 default null,
 pParameterValue5  in varchar2 default null,
 pParameter6       in varchar2 default null,
 pParameterValue6  in varchar2 default null,
 pParameter7       in varchar2 default null,
 pParameterValue7  in varchar2 default null,
 pParameter8       in varchar2 default null,
 pParameterValue8  in varchar2 default null,
 pParameter9       in varchar2 default null,
 pParameterValue9  in varchar2 default null,
 pParameter10      in varchar2 default null,
 pParameterValue10 in varchar2 default null,
 pParameter11      in varchar2 default null,
 pParameterValue11 in varchar2 default null,
 pParameter12      in varchar2 default null,
 pParameterValue12 in varchar2 default null,
 pParameter13      in varchar2 default null,
 pParameterValue13 in varchar2 default null,
 pParameter14      in varchar2 default null,
 pParameterValue14 in varchar2 default null,
 pParameter15      in varchar2 default null,
 pParameterValue15 in varchar2 default null,
 pTimeParameter    in varchar2 default null,
 pTimeFromParameter in varchar2 default null,
 pTimeToParameter  in varchar2 default null,
 pViewByValue      in  varchar2 default null,
 pAddToDefault     in varchar2 default null,
 pParameter1Name   in varchar2 default null,
 pParameter2Name   in varchar2 default null,
 pParameter3Name   in varchar2 default null,
 pParameter4Name   in varchar2 default null,
 pParameter5Name   in varchar2 default null,
 pParameter6Name   in varchar2 default null,
 pParameter7Name   in varchar2 default null,
 pParameter8Name   in varchar2 default null,
 pParameter9Name   in varchar2 default null,
 pParameter10Name   in varchar2 default null,
 pParameter11Name   in varchar2 default null,
 pParameter12Name   in varchar2 default null,
 pParameter13Name   in varchar2 default null,
 pParameter14Name   in varchar2 default null,
 pParameter15Name   in varchar2 default null,
 pTimeParamName	    in varchar2 default null,
 pParameterOperator1   in varchar2 default null,
 pParameterOperator2   in varchar2 default null,
 pParameterOperator3   in varchar2 default null,
 pParameterOperator4   in varchar2 default null,
 pParameterOperator5   in varchar2 default null,
 pParameterOperator6   in varchar2 default null,
 pParameterOperator7   in varchar2 default null,
 pParameterOperator8   in varchar2 default null,
 pParameterOperator9   in varchar2 default null,
 pParameterOperator10  in varchar2 default null,
 pParameterOperator11  in varchar2 default null,
 pParameterOperator12  in varchar2 default null,
 pParameterOperator13  in varchar2 default null,
 pParameterOperator14  in varchar2 default null,
 pParameterOperator15  in varchar2 default null,
 pRequired1 	       in varchar2 default null,
 pRequired2 	       in varchar2 default null,
 pRequired3 	       in varchar2 default null,
 pRequired4 	       in varchar2 default null,
 pRequired5 	       in varchar2 default null,
 pRequired6 	       in varchar2 default null,
 pRequired7 	       in varchar2 default null,
 pRequired8 	       in varchar2 default null,
 pRequired9 	       in varchar2 default null,
 pRequired10	       in varchar2 default null,
 pRequired11	       in varchar2 default null,
 pRequired12	       in varchar2 default null,
 pRequired13	       in varchar2 default null,
 pRequired14	       in varchar2 default null,
 pRequired15	       in varchar2 default null,
 pTimeRequired 	       in varchar2 default null,
 pLovWhere1 	       in varchar2 default null,
 pLovWhere2 	       in varchar2 default null,
 pLovWhere3 	       in varchar2 default null,
 pLovWhere4 	       in varchar2 default null,
 pLovWhere5 	       in varchar2 default null,
 pLovWhere6 	       in varchar2 default null,
 pLovWhere7 	       in varchar2 default null,
 pLovWhere8 	       in varchar2 default null,
 pLovWhere9 	       in varchar2 default null,
 pLovWhere10 	       in varchar2 default null,
 pLovWhere11 	       in varchar2 default null,
 pLovWhere12 	       in varchar2 default null,
 pLovWhere13 	       in varchar2 default null,
 pLovWhere14 	       in varchar2 default null,
 pLovWhere15 	       in varchar2 default null,
 pAsOfDateValue        in varchar2 default null,
 pAsOfDateMode         in varchar2 default null,
 pSaveByIds            in varchar2 default 'N',
 x_return_status    out NOCOPY VARCHAR2,
 x_msg_count	    out NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2
)
IS

	l_parameter_rec		BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE;
        l_parameter_Rec_tbl	BIS_PMV_PARAMETERS_PVT.parameter_tbl_type;
	l_user_Session_rec	BIS_PMV_SESSION_PVT.session_rec_type;
	l_time_parameter_rec 	BIS_PMV_PARAMETERS_PVT.TIME_PARAMETER_REC_TYPE;
	l_count			NUMBER;
        l_asof_Date             DATE;
	--l_Start_Date            DATE;
	--l_End_date              DATE;
        l_time_level_id         VARCHAR2(2000);
        l_time_level_value      VARCHAR2(2000);
        l_time_comparison_type  VARCHAR2(2000) := null;
        l_time_comp_const       VARCHAR2(200) := 'TIME_COMPARISON_TYPE';
        --l_current_report_start_date     date;
        --l_prev_report_start_Date       date;

        lAsOfDateValue varchar2(2000);
        l_date_format varchar2(30) := 'DD-MM-RRRR';
        l_canonical_date_format varchar2(30) := 'DD/MM/RRRR';

	/*-----BugFix#2887200 -ansingh-------*/
		l_prev_asof_Date										DATE;
		l_curr_effective_start_date					DATE;
		l_curr_effective_end_date						DATE;
		l_curr_report_Start_date						DATE;
		l_prev_report_Start_date						DATE;
		l_prev_effective_start_date						DATE;
		l_prev_effective_end_date						DATE;
                l_prev_time_level_id         VARCHAR2(2000);
                l_prev_time_level_value      VARCHAR2(2000);

BEGIN
	--First delete all the parameters for this session.
	FND_MSG_PUB.INITIALIZE;
	l_user_session_rec.function_name := pFunctionNAme;
        l_user_session_rec.region_code := pRegionCode;
        l_user_session_rec.page_id := pPageId;
	l_user_session_rec.session_id := pSessionId;
	l_user_Session_rec.user_id := pUserId;
	l_user_session_rec.responsibility_id := pResponsibilityId;

	IF (pAddToDefault = 'Y') THEN
           delete_default_parameters(
	   p_user_session_rec => l_user_session_rec,
	   x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
           x_return_status => x_return_status
           );
        ELSE
         IF pPageId IS NULL OR pPageId = '' THEN
	  delete_session_parameters(
	    p_user_session_rec => l_user_session_Rec,
	    p_schedule_option => 'NULL',
            x_msg_count => x_msg_count,
	    x_msg_data  => x_msg_data,
	    x_return_status => x_return_status
	    );
         ELSE
           delete_page_parameters(
	   p_user_session_rec => l_user_session_rec,
	   x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
           x_return_status => x_return_status
           );
         END IF;
        END IF;

	commit;


  if (pParameter1Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter1Name;
    l_parameter_rec.parameter_value := pParameterValue1;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue1;
  END IF;

	l_parameter_rec.parameter_name := pParameter1;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_rec.dimension := substr(pParameter1,1, instr(pParameter1,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_Rec.parameter_label :=  pParameter1Name;
        l_parameter_rec.operator := pParameterOperator1;
	l_parameter_rec.required_flag := pRequired1;
        l_parameter_rec.lov_where := pLovWhere1;
	l_parameter_rec.id_flag := pSaveByIds;
        l_parameter_rec_tbl(1) := l_parameter_rec;

  if (pParameter2Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter2Name;
    l_parameter_rec.parameter_value := pParameterValue2;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue2;
  END IF;

	l_parameter_rec.parameter_name := pParameter2;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_rec.dimension := substr(pParameter2,1, instr(pParameter2,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_Rec.parameter_label :=  pParameter2Name;
  l_parameter_rec.operator := pParameterOperator2;
	l_parameter_rec.required_flag := pRequired2;
        l_parameter_rec.lov_where := pLovWhere2;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(2) := l_parameter_rec;

  if (pParameter3Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter3Name;
    l_parameter_rec.parameter_value := pParameterValue3;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue3;
  END IF;

	l_parameter_rec.parameter_name := pParameter3;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_rec.dimension := substr(pParameter3,1, instr(pParameter3,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_Rec.parameter_label :=  pParameter3Name;
  l_parameter_rec.operator := pParameterOperator3;
	l_parameter_rec.required_flag := pRequired3;
        l_parameter_rec.lov_where := pLovWhere3;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(3) := l_parameter_rec;

  if (pParameter4Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter4Name;
    l_parameter_rec.parameter_value := pParameterValue4;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue4;
  END IF;

	l_parameter_rec.parameter_name := pParameter4;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_rec.dimension := substr(pParameter4,1, instr(pParameter4,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_Rec.parameter_label :=  pParameter4Name;
  l_parameter_rec.operator := pParameterOperator4;
	l_parameter_rec.required_flag := pRequired4;
        l_parameter_rec.lov_where := pLovWhere4;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(4) := l_parameter_rec;

  if (pParameter5Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter5Name;
    l_parameter_rec.parameter_value := pParameterValue5;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue5;
  END IF;

	l_parameter_rec.parameter_name := pParameter5;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_rec.dimension := substr(pParameter5,1, instr(pParameter5,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_Rec.parameter_label :=  pParameter5Name;
  l_parameter_rec.operator := pParameterOperator5;
	l_parameter_rec.required_flag := pRequired5;
        l_parameter_rec.lov_where := pLovWhere5;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(5) := l_parameter_rec;

  if (pParameter6Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter6Name;
    l_parameter_rec.parameter_value := pParameterValue6;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue6;
  END IF;

	l_parameter_rec.parameter_name := pParameter6;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_rec.dimension := substr(pParameter6,1, instr(pParameter6,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_Rec.parameter_label :=  pParameter6Name;
  l_parameter_rec.operator := pParameterOperator6;
	l_parameter_rec.required_flag := pRequired6;
        l_parameter_rec.lov_where := pLovWhere6;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(6) := l_parameter_rec;

  if (pParameter7Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter7Name;
    l_parameter_rec.parameter_value := pParameterValue7;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue7;
  END IF;
	l_parameter_rec.parameter_name := pParameter7;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_rec.dimension := substr(pParameter7,1, instr(pParameter7,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_Rec.parameter_label :=  pParameter7Name;
  l_parameter_rec.operator := pParameterOperator7;
	l_parameter_rec.required_flag := pRequired7;
        l_parameter_rec.lov_where := pLovWhere7;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(7) := l_parameter_rec;

  if (pParameter8Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter8Name;
    l_parameter_rec.parameter_value := pParameterValue8;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue8;
  END IF;

	l_parameter_rec.parameter_name := pParameter8;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_Rec.parameter_label :=  pParameter8Name;
	l_parameter_rec.dimension := substr(pParameter8,1, instr(pParameter8,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
  l_parameter_rec.operator := pParameterOperator8;
	l_parameter_rec.required_flag := pRequired8;
        l_parameter_rec.lov_where := pLovWhere8;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(8) := l_parameter_rec;

  if (pParameter9Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter9Name;
    l_parameter_rec.parameter_value := pParameterValue9;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue9;
  END IF;
	l_parameter_rec.parameter_name := pParameter9;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_rec.dimension := substr(pParameter9,1, instr(pParameter9,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_Rec.parameter_label :=  pParameter9Name;
  l_parameter_rec.operator := pParameterOperator9;
	l_parameter_rec.required_flag := pRequired9;
        l_parameter_rec.lov_where := pLovWhere9;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(9) := l_parameter_rec;

  if (pParameter10Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter10Name;
    l_parameter_rec.parameter_value := pParameterValue10;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue10;
  END IF;
	l_parameter_rec.parameter_name := pParameter10;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_rec.dimension := substr(pParameter10,1, instr(pParameter10,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_Rec.parameter_label :=  pParameter10Name;
  l_parameter_rec.operator := pParameterOperator10;
	l_parameter_rec.required_flag := pRequired10;
        l_parameter_rec.lov_where := pLovWhere10;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(10) := l_parameter_rec;

  if (pParameter11Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter11Name;
    l_parameter_rec.parameter_value := pParameterValue11;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue11;
  END IF;
	l_parameter_rec.parameter_name := pParameter11;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_Rec.parameter_label :=  pParameter11Name;
	l_parameter_rec.dimension := substr(pParameter11,1, instr(pParameter11,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
  l_parameter_rec.operator := pParameterOperator11;
	l_parameter_rec.required_flag := pRequired11;
        l_parameter_rec.lov_where := pLovWhere11;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(11) := l_parameter_rec;

  if (pParameter12Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter12Name;
    l_parameter_rec.parameter_value := pParameterValue12;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue12;
  END IF;
	l_parameter_rec.parameter_name := pParameter12;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_rec.dimension := substr(pParameter12,1, instr(pParameter12,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_Rec.parameter_label :=  pParameter12Name;
  l_parameter_rec.operator := pParameterOperator12;
	l_parameter_rec.required_flag := pRequired12;
        l_parameter_rec.lov_where := pLovWhere12;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(12) := l_parameter_rec;

  if (pParameter13Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter13Name;
    l_parameter_rec.parameter_value := pParameterValue13;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue13;
  END IF;
	l_parameter_rec.parameter_name := pParameter13;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_rec.dimension := substr(pParameter13,1, instr(pParameter13,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_Rec.parameter_label :=  pParameter13Name;
  l_parameter_rec.operator := pParameterOperator13;
	l_parameter_rec.required_flag := pRequired13;
        l_parameter_rec.lov_where := pLovWhere13;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(13) := l_parameter_rec;

  if (pParameter14Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter14Name;
    l_parameter_rec.parameter_value := pParameterValue14;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue14;
  END IF;
	l_parameter_rec.parameter_name := pParameter14;
	l_parameter_rec.dimension := substr(pParameter14,1, instr(pParameter14,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_Rec.parameter_label :=  pParameter14Name;
  l_parameter_rec.operator := pParameterOperator14;
	l_parameter_rec.required_flag := pRequired14;
        l_parameter_rec.lov_where := pLovWhere14;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(14) := l_parameter_rec;

  if (pParameter15Name = ROLLING_DIMENSION_DESCRIPTION) THEN
    l_parameter_rec.parameter_description := pParameter15Name;
    l_parameter_rec.parameter_value := pParameterValue15;
  ELSE
    l_parameter_rec.parameter_description := pParameterValue15;
  END IF;
	l_parameter_rec.parameter_name := pParameter15;
	l_parameter_rec.dimension := substr(pParameter15,1, instr(pParameter15,'+')-1);
        if(l_parameter_Rec.dimension = l_time_comp_const) THEN
           l_time_comparison_type := l_parameter_rec.parameter_description;
        end if;
	l_parameter_rec.default_flag	:=	pAddToDefault;
	l_parameter_Rec.parameter_label :=  pParameter15Name;
  l_parameter_rec.operator := pParameterOperator15;
	l_parameter_rec.required_flag := pRequired15;
        l_parameter_rec.lov_where := pLovWhere15;
	l_parameter_rec.id_flag := pSaveByIds;
  l_parameter_rec_tbl(15) := l_parameter_rec;

  l_count := 15;
	if (pHierarchy1 is not null) then
           l_Parameter_rec.parameter_name := pParameter1;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.parameter_value := pHierarchy1;
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.dimension := substr(pParameter1,1,instr(pParameter1,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue1;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy2 is not null) then
           l_Parameter_rec.parameter_name := pParameter2;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.parameter_value := pHierarchy2;
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.dimension := substr(pParameter2,1,instr(pParameter2,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue2;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;

	if (pHierarchy3 is not null) then
           l_Parameter_rec.parameter_name := pParameter3;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.parameter_value := pHierarchy3;
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.dimension := substr(pParameter3,1,instr(pParameter3,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue3;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy4 is not null) then
           l_Parameter_rec.parameter_name := pParameter4;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.parameter_value := pHierarchy4;
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.dimension := substr(pParameter4,1,instr(pParameter4,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue4;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy5 is not null) then
           l_Parameter_rec.parameter_name := pParameter5;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.parameter_value := pHierarchy5;
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.dimension := substr(pParameter5,1,instr(pParameter5,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue5;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy6 is not null) then
           l_Parameter_rec.parameter_name := pParameter6;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.parameter_value := pHierarchy6;
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.dimension := substr(pParameter6,1,instr(pParameter6,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue6;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy7 is not null) then
           l_Parameter_rec.parameter_name := pParameter7;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.parameter_value := pHierarchy7;
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.dimension := substr(pParameter7,1,instr(pParameter7,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue7;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy8 is not null) then
           l_Parameter_rec.parameter_name := pParameter8;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.parameter_value := pHierarchy8;
           l_parameter_rec.dimension := substr(pParameter8,1,instr(pParameter8,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue8;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy9 is not null) then
           l_Parameter_rec.parameter_name := pParameter9;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.parameter_value := pHierarchy9;
           l_parameter_rec.dimension := substr(pParameter9,1,instr(pParameter9,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue9;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy10 is not null) then
           l_Parameter_rec.parameter_name := pParameter10;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.parameter_value := pHierarchy10;
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.dimension := substr(pParameter10,1,instr(pParameter10,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue10;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy11 is not null) then
           l_Parameter_rec.parameter_name := pParameter11;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.parameter_value := pHierarchy11;
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.dimension := substr(pParameter11,1,instr(pParameter11,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue11;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy12 is not null) then
           l_Parameter_rec.parameter_name := pParameter12;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.parameter_value := pHierarchy12;
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.dimension := substr(pParameter12,1,instr(pParameter12,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue12;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy13 is not null) then
           l_Parameter_rec.parameter_name := pParameter13;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.parameter_value := pHierarchy13;
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.dimension := substr(pParameter13,1,instr(pParameter13,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue13;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy14 is not null) then
           l_Parameter_rec.parameter_name := pParameter14;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.parameter_value := pHierarchy14;
           l_parameter_rec.dimension := substr(pParameter14,1,instr(pParameter14,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue14;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pHierarchy15 is not null) then
           l_Parameter_rec.parameter_name := pParameter15;
           l_parameter_rec.hierarchy_flag := 'Y';
           l_parameter_rec.default_Flag := pAddToDefault;
           l_parameter_rec.parameter_value := pHierarchy15;
           l_parameter_rec.dimension := substr(pParameter15,1,instr(pParameter15,'+')-1);
           l_parameter_rec.parameter_description := pParameterValue15;
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if;
	if (pViewByValue is not null) then
	   l_parameter_rec.parameter_name := 'VIEW_BY';
           l_parameter_rec.parameter_description := pViewByValue;
           l_parameter_rec.default_Flag := pAddToDefault;
	   l_parameter_rec.hierarchy_flag := 'N';
	   l_count := l_count+1;
           l_parameter_rec_tbl(l_count) := l_parameter_rec;
	end if ;

      	create_Session_parameters(p_user_param_tbl => l_parameter_rec_tbl
				 ,p_user_session_rec => l_user_session_rec
				 ,x_return_Status => x_return_Status
				 ,x_msg_count => x_msg_count
				 ,x_msg_Data  => x_msg_Data);

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
    	  	RETURN;
        END IF;


        IF (pTimeFromParameter = 'DBC_TIME' or pAsOfDateValue is not null) then

           IF (pAsOfDateValue is null) then
              lAsOFDateValue := to_char(SYSDATE,'DD-MM-RRRR');
           ELSE
              lAsOFDateValue := pAsOfDateValue;
           END IF;

           l_parameter_rec.parameter_name := 'AS_OF_DATE';
           -- nbarik - 03/17/03 - Bug Fix 2844149 - Added date format for to_date.
           IF (pAsOfDateMode = 'NEXT') then
              --l_asof_date := to_date(lAsOfDateValue, l_date_format)+1;
              --l_parameter_rec.parameter_description := to_char(l_asof_date,'DD-MON-YYYY');
              --l_parameter_rec.parameter_value := to_char(l_asof_date,'DD-MON-YYYY');
              l_asof_date := to_date(lAsOfDateValue, l_canonical_date_format)+1;
              l_parameter_rec.parameter_description := to_char(l_asof_date,l_canonical_date_format);
              l_parameter_rec.parameter_value := to_char(l_asof_date,l_canonical_date_format);
              l_parameter_rec.period_date := l_asof_date;
           ELSIF (pAsOFDateMode = 'PREVIOUS') then
              --l_asof_date := to_date(lAsOfDateValue, l_date_format)-1;
              --l_parameter_rec.parameter_description := to_char(l_asof_Date,'DD-MON-YYYY');
              --l_parameter_rec.parameter_value := to_char(l_asof_date,'DD-MON-YYYY');
              l_asof_date := to_date(lAsOfDateValue, l_canonical_date_format)-1;
              l_parameter_rec.parameter_description := to_char(l_asof_Date,l_canonical_date_format);
              l_parameter_rec.parameter_value := to_char(l_asof_date,l_canonical_date_format);
              l_parameter_rec.period_date := l_asof_date;
           ELSIF (pAsOfDateMode = 'CURRENT'  or pAsOfDateMode is null) then
              --l_asof_Date := to_Date(lAsOfDateValue, l_date_format);
              --l_parameter_Rec.parameter_description := to_char(l_asof_date,'DD-MON-YYYY');
              --l_parameter_rec.parameter_value := to_char(l_asof_date,'DD-MON-YYYY');


              l_asof_Date := to_Date(lAsOfDateValue, l_canonical_date_format);
              l_parameter_rec.parameter_description := to_char(l_asof_Date,l_canonical_date_format);
              l_parameter_rec.parameter_value := to_char(l_asof_date,l_canonical_date_format);
              l_parameter_rec.period_date := l_asof_date;
           END IF;
           l_parameter_Rec.default_flag := 'N';
           l_parameter_rec.hierarchy_flag := 'N';
           CREATE_PARAMETER (p_user_session_rec => l_user_session_rec
                      ,p_parameter_rec => l_parameter_rec
                      ,x_return_status => x_return_status
                      ,x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
    	    	RETURN;
          END IF;
        END IF;

	IF (pTimeParameter IS NOT NULL) THEN
           IF (pTimeFromParameter = 'DBC_TIME') THEN
	/*-----BugFix#2887200 -ansingh-------*/
          --get all the date information.
	  BIS_PMV_TIME_LEVELS_PVT.GET_COMPUTED_DATES(
	    p_region_code									 => pregioncode,
	    p_resp_id											 => presponsibilityid,
	    p_time_comparison_type         => l_time_comparison_Type,
	    p_asof_date                    => to_char(l_Asof_date, 'DD/MM/YYYY'),
	    p_time_level                   => pTimeParameter,
	    x_prev_asof_Date               => l_prev_asof_Date,
	    x_curr_effective_start_date    => l_curr_effective_start_date,
	    x_curr_effective_end_date      => l_curr_effective_end_date,
	    x_curr_report_Start_date       => l_curr_report_Start_date,
	    x_prev_report_Start_date       => l_prev_report_Start_date,
	    x_time_level_id		   => l_time_level_id,
	    x_time_level_value		   => l_time_level_value,
            x_prev_effective_start_date	   => l_prev_effective_start_date,
            x_prev_effective_end_date	   => l_prev_effective_end_date,
	    x_prev_time_level_id	   => l_prev_time_level_id,
	    x_prev_time_level_value	   => l_prev_time_level_value,
	    x_return_status                => x_return_status,
	    x_msg_count                    => x_msg_count,
	    x_msg_Data                     => x_msg_Data
	  );
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
  	    RETURN;
          END IF;

          l_parameter_rec.dimension                     := substr(pTimeParameter, 1, instr(pTimeParameter,'+')-1);
          l_parameter_rec.default_flag                  := 'N';
          l_parameter_rec.parameter_name		:= pTimeParameter || '_FROM';
          l_parameter_rec.parameter_description         := l_time_level_Value;
          l_parameter_rec.period_date			:= l_curr_effective_start_date;
          l_parameter_Rec.parameter_Value		:= l_time_level_id;
          -- _FROM Record
                CREATE_PARAMETER (p_user_session_rec => l_user_session_rec
                                 ,p_parameter_rec => l_parameter_rec
                                 ,x_return_status => x_return_status
                                 ,x_msg_count => x_msg_count
                                 ,x_msg_data => x_msg_data);

                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            	  	RETURN;
                END IF;

	  l_parameter_rec.default_flag			:= 'N';
          l_parameter_rec.parameter_name		:= pTimeParameter || '_TO';
          l_parameter_rec.parameter_description         := l_time_level_Value;
          l_parameter_rec.period_date			:= l_curr_effective_end_date;
          l_parameter_Rec.parameter_Value		:= l_time_level_id;
          -- _TO Record
          CREATE_PARAMETER (p_user_session_rec => l_user_session_rec
                                 ,p_parameter_rec => l_parameter_rec
                                 ,x_return_status => x_return_status
                                 ,x_msg_count => x_msg_count
                                 ,x_msg_data => x_msg_data);

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            		RETURN;
          END IF;

          --BIS_P_ASOF_DATE Record
	  BIS_PMV_TIME_LEVELS_PVT.GET_TIME_PARAMETER_RECORD (
	    p_TimeParamterName => 'BIS_P_ASOF_DATE',
	    p_DateParameter    => l_prev_asof_Date,
	    x_parameterRecord  => l_parameter_rec,
	    x_Return_status    => x_return_Status,
	    x_msg_count        => x_msg_count,
	    x_msg_data         => x_msg_data
	  );

          CREATE_PARAMETER ( p_user_session_rec => l_user_session_rec,
             p_parameter_rec    => l_parameter_rec,
             x_return_status    => x_return_status,
             x_msg_count        => x_msg_count,
             x_msg_data         => x_msg_data
	  );
	  --BIS_CUR_REPORT_START_DATE Record
	  BIS_PMV_TIME_LEVELS_PVT.GET_TIME_PARAMETER_RECORD(
	    p_TimeParamterName => 'BIS_CUR_REPORT_START_DATE',
	    p_DateParameter    => l_curr_report_Start_date,
	    x_parameterRecord  => l_parameter_rec,
	    x_Return_status    => x_return_Status,
	    x_msg_count        => x_msg_count,
	    x_msg_data         => x_msg_data
	  );
          CREATE_PARAMETER ( p_user_session_rec => l_user_session_rec,
            p_parameter_rec    => l_parameter_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data
	  );
          --BIS_PREV_REPORT_START_DATE Record
	  BIS_PMV_TIME_LEVELS_PVT.GET_TIME_PARAMETER_RECORD(
	    p_TimeParamterName => 'BIS_PREV_REPORT_START_DATE',
	    p_DateParameter		 => l_prev_report_Start_date,
	    x_parameterRecord  => l_parameter_rec,
	    x_Return_status    => x_return_Status,
	    x_msg_count        => x_msg_count,
	    x_msg_data         => x_msg_data
	  );
          CREATE_PARAMETER ( p_user_session_rec => l_user_session_rec,
            p_parameter_rec    => l_parameter_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data
	  );
          --nbarik 07/10/03 - Bug Fix 2999602 - Add BIS_PREVIOUS_EFFECTIVE_START_DATE and BIS_PREVIOUS_EFFECTIVE_END_DATE
          --BIS_PREVIOUS_EFFECTIVE_START_DATE Record
	  l_parameter_rec.dimension   	          := NULL;
	  l_parameter_rec.default_flag		  := 'N';
	  l_parameter_rec.parameter_name	  := 'BIS_PREVIOUS_EFFECTIVE_START_DATE';
	  l_parameter_rec.parameter_value	  := l_prev_time_level_id;
	  l_parameter_rec.parameter_description   := l_prev_time_level_value;
          l_parameter_rec.period_date             := l_prev_effective_start_date;

          CREATE_PARAMETER ( p_user_session_rec => l_user_session_rec,
            p_parameter_rec    => l_parameter_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data
	  );
          --BIS_PREVIOUS_EFFECTIVE_END_DATE Record
	  l_parameter_rec.dimension   	          := NULL;
	  l_parameter_rec.default_flag		  := 'N';
	  l_parameter_rec.parameter_name	  := 'BIS_PREVIOUS_EFFECTIVE_END_DATE';
	  l_parameter_rec.parameter_value	  := l_prev_time_level_id;
	  l_parameter_rec.parameter_description   := l_prev_time_level_value;
          l_parameter_rec.period_date             := l_prev_effective_end_date;

          CREATE_PARAMETER ( p_user_session_rec => l_user_session_rec,
            p_parameter_rec    => l_parameter_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data
	  );

	/*-----BugFix#2887200 -ansingh-------*/

                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
            	  	RETURN;
                END IF;

           ELSE
		if pOrgParam = 1 then
                   l_time_parameter_rec.org_name := pParameter1;
                   l_time_parameter_rec.org_value := pParameterValue1;
		elsif pOrgParam = 2 then
                   l_time_parameter_rec.org_name := pParameter2;
                   l_time_parameter_rec.org_value := pParameterValue2;
		elsif pOrgParam = 3 then
                   l_time_parameter_rec.org_name := pParameter3;
                   l_time_parameter_rec.org_value := pParameterValue3;
		elsif pOrgParam = 4 then
                   l_time_parameter_rec.org_name := pParameter4;
                   l_time_parameter_rec.org_value := pParameterValue4;
		elsif pOrgParam = 5 then
                   l_time_parameter_rec.org_name := pParameter5;
                   l_time_parameter_rec.org_value := pParameterValue5;
		elsif pOrgParam = 6 then
                   l_time_parameter_rec.org_name := pParameter6;
                   l_time_parameter_rec.org_value := pParameterValue6;
		elsif pOrgParam = 7 then
                   l_time_parameter_rec.org_name := pParameter7;
                   l_time_parameter_rec.org_value := pParameterValue7;
		elsif pOrgParam = 8 then
                   l_time_parameter_rec.org_name := pParameter8;
                   l_time_parameter_rec.org_value := pParameterValue8;
		elsif pOrgParam = 9 then
                   l_time_parameter_rec.org_name := pParameter9;
                   l_time_parameter_rec.org_value := pParameterValue9;
		elsif pOrgParam = 10 then
                   l_time_parameter_rec.org_name := pParameter10;
                   l_time_parameter_rec.org_value := pParameterValue10;
		elsif pOrgParam = 11 then
                   l_time_parameter_rec.org_name := pParameter11;
                   l_time_parameter_rec.org_value := pParameterValue11;
		elsif pOrgParam = 12 then
                   l_time_parameter_rec.org_name := pParameter12;
                   l_time_parameter_rec.org_value := pParameterValue12;
		elsif pOrgParam = 13 then
                   l_time_parameter_rec.org_name := pParameter13;
                   l_time_parameter_rec.org_value := pParameterValue13;
		elsif pOrgParam = 14 then
                   l_time_parameter_rec.org_name := pParameter14;
                   l_time_parameter_rec.org_value := pParameterValue14;
		elsif pOrgParam = 15 then
                   l_time_parameter_rec.org_name := pParameter15;
                   l_time_parameter_rec.org_value := pParameterValue15;
                else
                   l_time_parameter_rec.org_value := G_ALL;
                end if;

                l_time_parameter_Rec.parameter_name := pTimeParameter;
                l_time_parameter_rec.from_description := pTimeFromParameter;
	        l_time_parameter_rec.to_Description := pTimeToParameter;
                l_time_parameter_rec.default_flag := pAddToDefault;
	        l_time_parameter_rec.dimension := substr(pTimeParameter,1, instr(pTimeParameter,'+')-1);
	        l_time_parameter_rec.required_flag := pTimeRequired;
                l_time_parameter_rec.parameter_label := pTimeParamName;
                l_time_parameter_rec.id_flag := pSaveByIds;
	        validate_and_save_Time(p_user_session_Rec => l_user_session_rec
                        				 ,p_time_parameter_rec => l_time_parameter_Rec
                        				 ,x_return_status => x_return_status
                      				 ,x_msg_count => x_msg_count
                    				 ,x_msg_data => x_msg_Data
                				 );
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
      	  	RETURN;
          END IF;
      END IF;
	END IF;
	COMMIT;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
END;

--jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS
PROCEDURE RETRIEVE_GRAPH_FILEID(p_user_id in varchar2,
                                p_schedule_id in varchar2,
                                p_attribute_name in varchar2,
                                p_function_name in varchar2,
                                x_graph_file_id out NOCOPY varchar2)
IS
cursor cGraphFileId is
select session_value from bis_user_attributes
    where user_id = p_user_id
    and schedule_id = p_schedule_id
    and attribute_name = p_attribute_name
    and function_name = p_function_name;

BEGIN
    if cGraphFileId%ISOPEN then
      CLOSE cGraphFileId;
    end if;

    OPEN cGraphFileId;
    LOOP
       FETCH cGraphFileId INTO x_graph_file_id ;
       if cGraphFileId%NOTFOUND then
            CLOSE cGraphFileId;
            RAISE NO_DATA_FOUND;
       end if;
       EXIT;
    END LOOP;
    CLOSE cGraphFileId;
EXCEPTION
WHEN NO_DATA_FOUND then
     x_graph_file_id := null;
WHEN  others then
     x_graph_file_id := null;
END RETRIEVE_GRAPH_FILEID;

--jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS
-- save the file id associated with the previous schedule, for the same plug,
-- for the new schedule id as the previous schedule gets deleted.
PROCEDURE SAVE_GRAPH_FILEID(p_user_id in varchar2,
                            p_schedule_id in varchar2,
                            p_attribute_name in varchar2,
                            p_function_name in varchar2,
                            p_graph_file_id in varchar2)
IS
BEGIN
   insert into bis_user_attributes
                  (user_id, function_name, attribute_name, session_value,
                   schedule_id,creation_date, created_by,
                   last_update_Date, last_updated_by)
                  VALUES
                  (p_user_id,p_function_name,p_attribute_name,p_graph_file_id,
                   p_schedule_id,sysdate,-1,sysdate,-1);
   commit;
END  SAVE_GRAPH_FILEID;

-- jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
-- x_context_values has the format PATH:value;URI:value
PROCEDURE RETRIEVE_CONTEXT_VALUES(p_user_id in varchar2,
                                  p_schedule_id in varchar2,
                                  p_attribute_name in varchar2,
                                  p_function_name in varchar2,
                                  x_context_values out NOCOPY varchar2)
IS
cursor cContextValues is
select session_value from bis_user_attributes
    where user_id = p_user_id
    and schedule_id = p_schedule_id
    and attribute_name = p_attribute_name
    and function_name = p_function_name;

BEGIN
    if cContextValues%ISOPEN then
      CLOSE cContextValues;
    end if;

    OPEN cContextValues;
    LOOP
       FETCH cContextValues INTO x_context_values ;
       if cContextValues%NOTFOUND then
            CLOSE cContextValues;
            RAISE NO_DATA_FOUND;
       end if;
       EXIT;
    END LOOP;
    CLOSE cContextValues;
EXCEPTION
WHEN NO_DATA_FOUND then
     x_context_values := null;
WHEN  others then
     x_context_values := null;
END RETRIEVE_CONTEXT_VALUES;


-- jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
-- p_context_values has the format PATH:value;URI:value
PROCEDURE SAVE_CONTEXT_VALUES(p_user_id in varchar2,
                              p_schedule_id in varchar2,
                              p_attribute_name in varchar2,
                              p_function_name in varchar2,
                              p_context_values in varchar2)
IS
BEGIN
   insert into bis_user_attributes
                  (user_id, function_name, attribute_name, session_value,
                   schedule_id,creation_date, created_by,
                   last_update_Date, last_updated_by)
                  VALUES
                  (p_user_id,p_function_name,p_attribute_name,p_context_values,
                   p_schedule_id,sysdate,-1,sysdate,-1);
   commit;
END  SAVE_CONTEXT_VALUES;



function GET_LOV_WHERE(p_parameter_tbl in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE,
                       p_where_clause in VARCHAR2,
                       p_user_session_rec IN BIS_PMV_SESSION_PVT.session_rec_type)
return varchar2 is
  l_lov_where varchar2(2000) := p_where_clause;
  l_index1 number := 1;
  l_index2 number := 1;
  l_count number := 0;
  l_attribute_code varchar2(2000);
  l_attribute2 varchar2(2000);
  l_parameter_name varchar2(2000);
  l_parameter_rec BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE;
  l_parameter_value varchar2(2000);
  l_parameter_description varchar2(2000);
  l_return_status varchar2(2000);
  l_msg_count number;
  l_msg_data varchar2(2000);
  l_index number;

begin
  loop
      /*
      --nbarik - 05/05/03 - Bug Fix 2691199 - Use p_where_clause here
      as l_lov_where will be changed after value replace and the index
      won't be correct

      l_index1 := instr(l_lov_where, '{', l_index1);
      l_index2 := instr(l_lov_where, '}', l_index1+1);
      */
      l_index1 := instr(p_where_clause, '{', l_index1);
      l_index2 := instr(p_where_clause, '}', l_index1+1);
      if l_index1 = 0 or l_index2 = 0 or l_count > 100 then
         exit;
      end if;
      --nbarik - 05/05/03 - Bug Fix 2691199 - Use p_where_clause
      --l_attribute_code := substr(l_lov_where, l_index1+1, l_index2-l_index1-1);
      l_attribute_code := substr(p_where_clause, l_index1+1, l_index2-l_index1-1);
      l_attribute2 := BIS_PMV_UTIL.getDimensionForAttribute(rtrim(ltrim(l_attribute_code)),p_user_session_rec.region_code);
      l_parameter_name := nvl(l_attribute2, l_attribute_code);

      if p_parameter_tbl.COUNT > 0 then
         for i in p_parameter_tbl.FIRST..p_parameter_tbl.LAST loop
           l_parameter_rec := p_parameter_tbl(i);
           if l_parameter_rec.parameter_name = l_parameter_name then

              IF l_parameter_rec.id_flag = 'Y' THEN
                 l_parameter_value := l_parameter_rec.parameter_description;
              ELSIF (instr(l_parameter_rec.parameter_description, '^~]*') > 0)
              then
                 l_index := INSTR(l_parameter_rec.parameter_description, '^~]*');
                 DECODE_ID_VALUE (
                p_code => l_parameter_rec.parameter_description
               ,p_index => l_index
               ,x_id => l_parameter_value
               ,x_value => l_parameter_description);
                IF INSTR(l_parameter_value, '''', 1)<>1 AND INSTR(l_parameter_value, '''', -1)<>
                         LENGTH(l_parameter_value) THEN
                 l_parameter_value := '''' || l_parameter_value || '''';
               END IF;
              ELSIF (l_parameter_rec.parameter_description=g_All) then
                l_parameter_value := l_parameter_rec.parameter_description;
              ELSE
                 GET_NONTIME_VALIDATED_VALUE (p_parameter_name => l_parameter_rec.parameter_name
                                     ,p_parameter_description => l_parameter_rec.parameter_description
                                     ,p_region_code => p_user_session_rec.region_code
                                     ,p_responsibility_id => p_user_session_rec.responsibility_id
                                     ,x_parameter_value => l_parameter_value
                                     ,x_return_status => l_return_status
                                     ,x_msg_count => l_msg_count
                                     ,x_msg_data => l_msg_data);
              END IF; --end of id_flag

              l_parameter_description := l_parameter_rec.parameter_description;
              exit;
           end if;
         end loop;
      end if;

      if l_attribute2 is not null then
          if (l_parameter_value = g_all) then
            l_parameter_value := ''''||upper(l_parameter_value) ||'''';
         end if;
         l_lov_where := replace(l_lov_where, '{'||l_attribute_code||'}',l_parameter_value);
      else
         l_lov_where := replace(l_lov_where, '{'||l_attribute_code||'}',l_parameter_description);
      end if;

      l_index1 := l_index2+1;
      l_count := l_count + 1;
  end loop;

  return l_lov_where;

end GET_LOV_WHERE;



/* serao - added pSessionId so that the as_of_date does not get over-ridden to
  sysdate */
PROCEDURE bulkInsertIntoPage(
 pSessionId IN VARCHAR2,
 pPageId          in VARCHAR2,
 pUserId             in VARCHAR2,
 pFunctionName IN VARCHAR2,
  pAttributeNameTbl IN BISVIEWER.t_char,
  pDimensionTbl IN BISVIEWER.t_char,
  pSessionValueTbl IN BISVIEWER.t_char,
  pSessionDescTbl IN BISVIEWER.t_char,
  pPeriodDateTbl IN BISVIEWER.t_date
) IS
BEGIN
  IF pAttributeNameTbl IS NOT NULL AND pAttributeNameTbl.COUNT >0 THEN
    FORALL i IN pAttributeNameTbl.FIRST..pAttributeNameTbl.LAST
           insert into bis_user_attributes (
				      SESSION_ID,
                                      USER_ID,
                                      FUNCTION_NAME,
                                      PAGE_ID,
                                      SESSION_VALUE,
                                      SESSION_DESCRIPTION,
                                      ATTRIBUTE_NAME,
                                      DIMENSION,
                                      PERIOD_DATE,
                                      LAST_UPDATE_DATE
                                      )VALUES (
					pSessionId,
                                        pUserId,
                                        pFunctionName,
                                        pPageId,
                                        pSessionValueTbl(i),
                                        pSessionDescTbl(i),
                                        pAttributeNameTbl(i),
                                        pDimensionTbl(i),
                                        pPeriodDateTbl(i),
                                        SYSDATE
                                      );
  END IF;
END bulkInsertIntoPage;

--nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
PROCEDURE VALIDATE_DRILL_PARAMETER
(p_user_param_tbl	IN	parameter_tbl_type
,p_user_param_rec   IN  parameter_rec_type
,p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,x_valid OUT NOCOPY VARCHAR2
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		OUT	NOCOPY VARCHAR2
) IS

l_user_param_tbl	parameter_tbl_type;
l_user_param_rec    parameter_rec_type;
l_lov_where  varchar2(2000);

BEGIN

     l_useR_param_Tbl := p_user_param_Tbl;
     l_user_param_rec := p_user_param_rec;
     	IF (l_user_param_rec.parameter_name IS NOT NULL ) THEN
         IF (l_user_param_rec.parameter_description <> ROLLING_DIMENSION_DESCRIPTION
         OR (trim(l_user_param_rec.parameter_description) IS NULL AND l_user_param_rec.required_flag = 'Y') ) THEN
                IF (l_user_param_rec.lov_where is not null and
                    instr(l_user_param_rec.parameter_description, '^~]*') <= 0 and
                    l_user_param_rec.parameter_description  <> g_all ) then
                   l_lov_where :=  GET_LOV_WHERE(p_parameter_tbl => l_user_param_Tbl,
                                                 p_where_clause => l_user_param_rec.lov_where,
                                                 p_user_session_rec => p_user_session_rec);
                   l_user_param_rec.lov_where := l_lov_where;
                END IF;


           	VALIDATE_PARAMETER(
                            p_user_session_rec => p_user_session_rec
                     	  , p_parameter_rec => l_user_param_rec
                          , x_valid => x_valid
                          , x_return_status => x_return_status
                          , x_msg_count => x_msg_count
                          , x_msg_Data => x_msg_data);
  	  END IF; -- if rolling dim

     END IF; -- if param name is not null

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
       ROLLBACK;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data);

END VALIDATE_DRILL_PARAMETER;

FUNCTION GET_PARAM_LOV_WHERE (
 pParamName IN VARCHAR2,
 pParamRegionGroup IN parameter_group_tbl_type
 ) RETURN VARCHAR2
 IS
 BEGIN

    IF pParamRegionGroup IS NOT NULL AND pParamRegionGroup.COUNT >0 THEN
    FOR i In pParamRegionGroup.FIRST..pParamRegionGroup.LAST LOOP
        IF (pParamRegionGroup(i).attribute_name = pParamName) THEN
          RETURN pParamRegionGroup(i).lov_where;
        END IF;
    END LOOP;
   END IF;

  RETURN NULL;
 END GET_PARAM_LOV_WHERE;

--nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
PROCEDURE GET_VALIDATED_DRILL_PARAMS (
  lAttributeCodeTable IN BISVIEWER.t_char,
  lDimensionTable     IN BISVIEWER.t_char,
  lSessionValueTable  IN BISVIEWER.t_char,
  lSessionDescTable   IN BISVIEWER.t_char,
  lPeriodDateTable    IN BISVIEWER.t_date,
  pParamRegionCode IN VARCHAR2,
  pParamFunctionName IN VARCHAR2,
  pParamRegionGroup IN parameter_group_tbl_type,
  pPageId IN  VARCHAR2,
  pUserId IN VARCHAR2,
  xAttributeCodeTable OUT NOCOPY BISVIEWER.t_char,
  xDimensionTable     OUT NOCOPY BISVIEWER.t_char,
  xSessionValueTable  OUT NOCOPY BISVIEWER.t_char,
  xSessionDescTable   OUT NOCOPY BISVIEWER.t_char,
  xPeriodDateTable    OUT NOCOPY BISVIEWER.t_date,
  x_DrillDefaultParameters OUT NOCOPY VARCHAR2
)
IS

 CURSOR getFunctionParams IS
 SELECT parameters
 FROM fnd_form_functions
 WHERE function_name = pParamFunctionName;
 /*
 CURSOR getPageParams IS
 SELECt attribute_name, session_value, session_description, dimension, period_date, operator
 FROM bis_user_attributes
 WHERE page_id = pPageId
 AND user_id = pUserId;
 */
 -- nbarik - 03/29/04 - Parameter Validation while navigating through related links
 CURSOR c_validation_parameters IS
 SELECT a.attribute2, c.attribute26
 FROM ak_region_items a, bis_ak_region_item_extension c
 WHERE a.region_code=pParamRegionCode AND a.attribute_code=c.attribute_code(+) AND a.region_code=c.region_code(+);

  lValidationAttrList BISVIEWER.t_char;
  lValidationReqList BISVIEWER.t_char;
  l_validation_req   VARCHAR2(30);
  l_parameter_rec		PARAMETER_REC_TYPE;
  l_parameter_Rec_tbl	parameter_tbl_type;
  l_user_Session_rec	BIS_PMV_SESSION_PVT.session_rec_type;
  lCount NUMBER := 1;
  lFunctionParams VARCHAR2(2000);
  lSaveById VARCHAR2(1);
  l_return_status VARCHAR2(2000);
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(2000);
  l_valid     VARCHAR2(1);
  l_PLSQLFunction VARCHAR2(200);
  l_function_result VARCHAR2(3000);
  l_attribute_code  VARCHAR2(150);
  l_default_value   VARCHAR2(2000);
  l_default_desc   VARCHAR2(2000);
  l_pParameters    VARCHAR2(2000);
BEGIN

 xAttributeCodeTable := lAttributeCodeTable;
 xDimensionTable := lDimensionTable;
 xSessionValueTable := lSessionValueTable;
 xSessionDescTable := lSessionDescTable;
 xPeriodDateTable := lPeriodDateTable;

   -- nbarik - 03/29/04 - Parameter Validation while navigating through related links
   IF c_validation_parameters%ISOPEN THEN
      CLOSE c_validation_parameters;
   END IF;
   OPEN c_validation_parameters;
   FETCH c_validation_parameters BULK COLLECT INTO lValidationAttrList, lValidationReqList;
   CLOSE c_validation_parameters;

   IF getFunctionParams%ISOPEN THEN
      CLOSE getFunctionParams ;
   END IF;
   OPEN getFunctionParams ;
   FETCH getFunctionParams  INTO lFunctionParams;
   CLOSE getFunctionParams ;

  l_PLSQLFunction := BIS_PMV_UTIL.getParameterValue(lFunctionParams, 'pPLSQLFunction');
  processDynamicAttributeValue(
      pPlSqlFunctionName => l_PLSQLFunction
    , xOutPut => l_function_result
  );
  --l_function_result := BIS_PMV_UTIL.getFunctionResult(l_PLSQLFunction);
  IF l_function_result IS NOT NULL THEN
    IF substr(l_function_result, 1, 1) = '&' THEN
      lFunctionParams := lFunctionParams || l_function_result;
    ELSE
      lFunctionParams := lFunctionParams || '&' || l_function_result;
    END IF;
  END IF;
  -- For report default parameters
  l_pParameters := BIS_PMV_UTIL.getParameterValue(lFunctionParams, 'pParameters');
  IF (l_pParameters IS NOT NULL) THEN
    lFunctionParams := replace (lFunctionParams, '~', '&');
    lFunctionParams := replace (lFunctionParams, '@', '=');
    lFunctionParams := replace (lFunctionParams, '^', '+');
  END IF;

  lsaveById  := BIS_PMV_UTIL.getParameterValue (lFunctionParams, 'pParamIds');
  IF lSaveById IS NULL THEN
    lSaveByid := 'N';
  END IF;

  IF lAttributeCodeTable IS NOT NULL AND lAttributeCodeTable.COUNT > 0 THEN
    FOR i IN lAttributeCodeTable.FIRST..lAttributeCodeTable.LAST LOOP
        l_parameter_rec.parameter_name := lAttributeCodeTable(i);
        l_parameter_rec.default_flag	:=	'N';
        l_parameter_rec.dimension := lDimensionTable(i);
        l_parameter_Rec.parameter_label :=  lAttributeCodeTable(i);
        --l_parameter_rec.operator := lOperatorlist(i);
        l_parameter_rec.required_flag := 'N'; --mandatory param validation will not happen
        l_parameter_rec.lov_where := GET_PARAM_LOV_WHERE (lAttributeCodeTable(i), pParamRegionGroup );
        l_parameter_rec.id_flag := lSaveById;
        l_parameter_rec.parameter_value := lSessionValueTable(i);
        IF (lSaveById = 'Y') THEN
          l_parameter_rec.parameter_description := lSessionValueTable(i); -- because in validate_nontime, desc used to validate
        ELSE
          l_parameter_rec.parameter_description := lSessionDescTable(i);
        END IF;

        l_parameter_rec_tbl(lCount) := l_parameter_rec;
        lCount := lCount +1;
    END LOOP;
  END IF;

  l_user_session_rec.function_name := pParamFunctionName;
  l_user_session_rec.region_code := pParamRegionCode;
  l_user_session_rec.page_id := pPageId;
  l_user_session_rec.session_id := icx_sec.getID(icx_sec.PV_SESSION_ID); -- can we call this without validate
  l_user_session_rec.responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
  l_user_Session_rec.user_id := pUserId;

  IF lAttributeCodeTable IS NOT NULL AND lAttributeCodeTable.COUNT > 0 THEN
    FOR i IN lAttributeCodeTable.FIRST..lAttributeCodeTable.LAST LOOP
      l_validation_req := 'N';
      IF lValidationAttrList IS NOT NULL AND lValidationAttrList.COUNT > 0 THEN
        FOR j IN lValidationAttrList.FIRST..lValidationAttrList.LAST LOOP
          IF (lAttributeCodeTable(i) = lValidationAttrList(j)) THEN
            l_validation_req := lValidationReqList(j);
            EXIT;
          END IF;
        END LOOP;
      END IF;
      l_valid := 'Y';
      IF (l_validation_req = 'Y') THEN
        VALIDATE_DRILL_PARAMETER(
            p_user_param_tbl => l_parameter_rec_tbl
          , p_user_param_rec => l_parameter_rec_tbl(i)
          , p_user_session_rec => l_user_Session_rec
          , x_valid => l_valid
          , x_return_status => l_return_status
          , x_msg_count => l_msg_count
          , x_msg_data => l_msg_data
        );
        IF l_valid <> 'Y' THEN
          -- Assign the value from form function
          l_attribute_code := BIS_PMV_UTIL.getAttributeForDimension(lAttributeCodeTable(i), pParamRegionCode);
          l_default_value := BIS_PMV_UTIL.getParameterValue(lFunctionParams, l_attribute_code);
          IF l_default_value IS NOT NULL THEN
		      IF (lSaveById = 'Y') THEN
	            GET_NONTIME_VALIDATED_ID (p_parameter_name => l_parameter_rec_tbl(i).parameter_name
	                                 ,p_parameter_value => l_default_value
	                                 ,p_lov_where => l_parameter_rec_tbl(i).lov_where
	                                 ,p_region_code => l_user_session_rec.region_code
	                                 ,p_responsibility_id => l_user_session_rec.responsibility_id
	                                 ,x_parameter_description => l_default_desc
	                                 ,x_return_status => l_return_status
	                                 ,x_msg_count => l_msg_count
	                                 ,x_msg_data => l_msg_data);
		      ELSE
	            l_default_desc := l_default_value;
	            GET_NONTIME_VALIDATED_VALUE (p_parameter_name => l_parameter_rec_tbl(i).parameter_name
	                                     ,p_parameter_description => l_default_desc
	                                     ,p_lov_where => l_parameter_rec_tbl(i).lov_where
	                                     ,p_region_code => l_user_session_rec.region_code
	                                     ,p_responsibility_id => l_user_session_rec.responsibility_id
	                                     ,x_parameter_value => l_default_value
	                                     ,x_return_status => l_return_status
	                                     ,x_msg_count => l_msg_count
	                                     ,x_msg_data => l_msg_data);
	          END IF;
	          IF (substr(l_default_value,1,1) <> '''') THEN
	            l_default_value := ''''|| l_default_value || '''';
	          END IF;
	          IF (x_DrillDefaultParameters IS NULL) THEN
	            x_DrillDefaultParameters := 'pDrillParamRegion=' || pParamRegionCode;
	          END IF;
			  x_DrillDefaultParameters := x_DrillDefaultParameters || '&pDrillParamName=' || BIS_PMV_UTIL.encode(lAttributeCodeTable(i)) ||
			                              '&pDrillPrevDesc=' || BIS_PMV_UTIL.encode(xSessionDescTable(i)) ||
			                               '&pDrillCurrentDesc=' || BIS_PMV_UTIL.encode(l_default_desc);
			  xSessionValueTable(i) := l_default_value;
			  xSessionDescTable(i) := l_default_desc;
          END IF;
          -- Assign the first value in the drop down - Not required
        END IF;
      END IF;
    END LOOP;
  END IF;

END GET_VALIDATED_DRILL_PARAMS;

PROCEDURE getPageParamFuncProps(
  pPageId IN VARCHAR2,
  pUserId IN VARCHAR2,
  xFunctionName OUT NOCOPY VARCHAR2,
  xRegionCode OUT NOCOPY VARCHAR2
)
IS
CURSOR getPageToFunctionName IS
SELECT function_name
FROM bis_user_attributes
WHERE page_id=pPageId
AND user_id = pUserId
AND function_name IS NOT NULL
AND rownum < 2;

BEGIN

 -- for the page 2 , get the function_name and hence the region for the pageTo
   IF getPageToFunctionName%ISOPEN then
      close getPageToFunctionName;
   END IF;
   OPEN getPageToFunctionName;
   FETCH getPageToFunctionName INTO xFunctionName;
   CLOSE getPageToFunctionName;

   IF (xFunctionName IS NOT NULL) THEN
      xRegionCode := BIS_PMV_UTIL.getReportRegion(xFunctionName);
   END IF;

END getPageParamFuncProps;

/* serao - 04/03- added sessionId to be inserted into page level records -
  mainly for the as_of_date so that it is not over-ridden by sysdate */
PROCEDURE copyParamtersBetweenPages(
  pSessionId IN VARCHAR2,
  pFromPageId IN VARCHAR2,
  pToPageId IN VARCHAR2,
  pUserId IN VARCHAR2,
  xParamRegionCode OUT NOCOPY VARCHAR2,
  xParamFunctionName OUT NOCOPY VARCHAR2,
  xParamGroup  OUT NOCOPY parameter_group_tbl_type,
  -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
  x_DrillDefaultParameters OUT NOCOPY VARCHAR2,
  x_return_status    OUT	NOCOPY VARCHAR2,
  x_msg_count	    OUT	NOCOPY NUMBER,
  x_msg_data	    OUT	NOCOPY VARCHAR2
) IS

CURSOR getPageFromParams IS
SELECT attribute_name, dimension, session_value, session_description, period_date
FROM bis_user_attributes
WHERE page_id = pFromPageId
AND user_id = pUserId;

vAttributeCodeTable BISVIEWER.t_char;
vDimensionTable     BISVIEWER.t_char;
vSessionValueTable     BISVIEWER.t_char;
vSessionDescTable     BISVIEWER.t_char;
vPeriodDateTable     BISVIEWER.t_date;

lAttributeCodeTable BISVIEWER.t_char;
lDimensionTable     BISVIEWER.t_char;
lSessionValueTable     BISVIEWER.t_char;
lSessionDescTable     BISVIEWER.t_char;
lPeriodDateTable     BISVIEWER.t_date;

  lAttrNameForInsert BISVIEWER.t_char;
  lDimensionForInsert BISVIEWER.t_char;
  lSessValueForInsert BISVIEWER.t_char;
  lSessDescForInsert BISVIEWER.t_char;
  lPeriodDateForInsert BISVIEWER.t_date;
  lAttrNameForDelete BISVIEWER.t_char;

lTCTExists boolean := false;
lNestedRegionCode VARCHAR2(250);
lAsofDateExists  boolean;
l_valid VARCHAR2(1);
BEGIN

   getPageParamFuncProps( pToPageId, pUserId, xParamFunctionName, xParamRegionCode);

    IF (xParamFunctionName IS NOT NULL AND xParamRegionCode IS NOT NULL ) THEN

        getParameterGroupsForRegion ( pRegionCode => xParamRegionCode,
                                      xParameterGroup =>  xParamGroup,
                                      xTCTExists => lTCTExists,
                                      xNestedRegion => lNestedRegionCode,
                                      xAsofDateExists => lAsofDateExists
                                     );

        -- get the attributes from the pageFrom
         IF getPageFromParams%ISOPEN then
            close getPageFromParams;
         END IF;
       OPEN getPageFromParams;
       FETCH getPageFromParams BULK COLLECT INTO vAttributeCodeTable, vDimensionTable, vSessionValueTable, vSessionDescTable, vPeriodDateTable;
       CLOSE getPageFromParams;

    --nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
	GET_VALIDATED_DRILL_PARAMS (
	  lAttributeCodeTable  => vAttributeCodeTable,
	  lDimensionTable      => vDimensionTable,
	  lSessionValueTable   => vSessionValueTable,
	  lSessionDescTable    => vSessionDescTable,
	  lPeriodDateTable     => vPeriodDateTable,
	  pParamRegionCode     => xParamRegionCode,
	  pParamFunctionName   => xParamFunctionName,
	  pParamRegionGroup    => xParamGroup,
	  pPageId              => pToPageId,
	  pUserId              => pUserId,
	  xAttributeCodeTable  => lAttributeCodeTable,
	  xDimensionTable      => lDimensionTable,
	  xSessionValueTable   => lSessionValueTable,
	  xSessionDescTable    => lSessionDescTable,
	  xPeriodDateTable     => lPeriodDateTable,
	  x_DrillDefaultParameters => x_DrillDefaultParameters
	);
        --get all the delete and  insert tables
        getDeleteAndInsertTables(
          pUserId             => pUserId,
          pAttributeNameTbl => lAttributeCodeTable,
          pDimensionTbl => lDimensionTable,
          pSessionValueTbl => lSessionValueTable,
          pSessionDescTbl => lSessionDescTable,
          pPeriodDateTbl=> lPeriodDateTable,
          pParameterGroup => xParamGroup,
          pIncludeViewBy => FALSE,
          pIncludeBusinessPlan => FALSE,
          pIncludePrevAsOfDate => TRUE,
          xAttrNameForInsert => lAttrNameForInsert,
          xDimensionForInsert => lDimensionForInsert,
          xSessValueForInsert => lSessValueForInsert,
          xSessDescForInsert => lSessDescForInsert,
          xPeriodDateForInsert => lPeriodDateForInsert,
          xAttrNameForDelete => lAttrNameForDelete
        ) ;

        --bulk delete and insert for the page
        IF (lAttrNameForDelete IS NOT NULL AND lAttrNameForDelete.COUNT > 0) THEN
          bulkDeleteFromPage(
           pPAgeId  => pToPageId  ,
           pUserId  => pUserId   ,
           pFunctionName => xParamFunctionName,
            pAttributeNameTbl => lAttrNameForDelete
           );
        END IF;

        IF (lAttrNameForInsert IS NOT NULL AND lAttrNameForInsert.COUNT > 0) THEN
          bulkInsertIntoPage(
           pSessionId => pSessionId,
           pPageId => pToPageId,
           pUserId  => pUserId,
           pFunctionName => xParamFunctionName,
           pAttributeNameTbl => lAttrNameForInsert,
           pDimensionTbl => lDimensionForInsert,
           pSessionValueTbl => lSessValueForInsert,
           pSessionDescTbl => lSessDescForInsert,
           pPeriodDateTbl => lPeriodDateForInsert
          );
        END IF;

      END IF; -- lRegionCode

   COMMIT;

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
END copyParamtersBetweenPages;

procedure executeLovBindSQL
(p_bind_sql  in varchar2
,p_bind_variables in varchar2
,p_time_flag      in varchar2
,x_parameter_id             out NOCOPY varchar2
,x_parameter_value          out NOCOPY varchar2
,x_start_date               out NOCOPY date
,x_end_date                 out NOCOPY date
,x_return_status	    OUT     NOCOPY VARCHAR2
,x_msg_count	    OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) is

l_bind_values BISVIEWER.t_char;

begin

   if (length(p_bind_variables) > 0) then
      BIS_PMV_UTIL.SETUP_BIND_VARIABLES(
      p_bind_variables => p_bind_variables,
      x_bind_var_tbl => l_bind_values);
   end if;

   if (l_bind_values.COUNT = 1) then
	if p_time_flag = 'Y' then
        execute immediate p_bind_sql into x_parameter_id, x_parameter_value, x_start_date, x_end_date using l_bind_values(1);
      else
        execute immediate p_bind_sql into x_parameter_id, x_parameter_value using l_bind_values(1);
      end if;
   elsif (l_bind_values.COUNT = 2) then
	if p_time_flag = 'Y' then
        execute immediate p_bind_sql into x_parameter_id, x_parameter_value, x_start_date, x_end_date using l_bind_values(1), l_bind_values(2);
      else
        execute immediate p_bind_sql into x_parameter_id, x_parameter_value using l_bind_values(1), l_bind_values(2);
      end if;
   elsif (l_bind_values.COUNT = 3) then
	if p_time_flag = 'Y' then
        execute immediate p_bind_sql into x_parameter_id, x_parameter_value, x_start_date, x_end_date using l_bind_values(1), l_bind_values(2), l_bind_values(3);
      else
        execute immediate p_bind_sql into x_parameter_id, x_parameter_value using l_bind_values(1), l_bind_values(2), l_bind_values(3);
      end if;
   else
     	executeLovDynamicSQL
 	(p_bind_sql  => p_bind_sql
	,p_bind_values => l_bind_values
	,p_time_flag => p_time_flag
	,x_parameter_id => x_parameter_id
	,x_parameter_value => x_parameter_value
	,x_start_date => x_start_date
	,x_end_date => x_end_date
	,x_return_status => x_return_status
	,x_msg_count => x_msg_count
	,x_msg_data => x_msg_data
	);
   end if;

EXCEPTION
WHEN OTHERS THEN
     	executeLovDynamicSQL
 	(p_bind_sql  => p_bind_sql
	,p_bind_values => l_bind_values
	,p_time_flag => p_time_flag
	,x_parameter_id => x_parameter_id
	,x_parameter_value => x_parameter_value
	,x_start_date => x_start_date
	,x_end_date => x_end_date
	,x_return_status => x_return_status
	,x_msg_count => x_msg_count
	,x_msg_data => x_msg_data
	);
END executeLovBindSQL;

procedure executeLovDynamicSQL
(p_bind_sql  in varchar2
,p_bind_values in BISVIEWER.t_char
,p_time_flag      in varchar2
,x_parameter_id             out NOCOPY varchar2
,x_parameter_value          out NOCOPY varchar2
,x_start_date               out NOCOPY date
,x_end_date                 out NOCOPY date
,x_return_status	    OUT     NOCOPY VARCHAR2
,x_msg_count	    OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
) is

l_bind_sql varchar2(2000);
l_bind_col varchar2(2000);
l_cursor integer;
ignore integer;

begin

   l_bind_sql := replace(p_bind_sql, ':', ':x');

   l_cursor := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor, l_bind_sql, DBMS_SQL.native);

   if (p_bind_values.COUNT > 0) then
    for i in p_bind_values.FIRST..p_bind_values.LAST loop
       l_bind_col := ':x'|| i;
       dbms_sql.bind_variable(l_cursor, l_bind_col, p_bind_values(i));
    end loop;
   end if;

   dbms_sql.define_column(l_cursor, 1, x_parameter_id, 2000);
   dbms_sql.define_column(l_cursor, 2, x_parameter_value, 2000);

   if p_time_flag = 'Y' then
      dbms_sql.define_column(l_cursor, 3, x_start_date);
      dbms_sql.define_column(l_cursor, 4, x_end_date);
   end if;

   ignore := dbms_sql.execute_and_fetch(l_cursor);

   dbms_sql.column_value (l_cursor, 1, x_parameter_id);
   dbms_sql.column_value (l_cursor, 2, x_parameter_value);

   if p_time_flag = 'Y' then
   	dbms_sql.column_value (l_cursor, 3, x_start_date);
   	dbms_sql.column_value (l_cursor, 4, x_end_date);
   end if;

   dbms_sql.close_cursor(l_cursor);

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
END executeLovDynamicSQL;

PROCEDURE copyParamsFromReportToPage(
  pFunctionName IN VARCHAR2,
  pSessionId IN VARCHAR2,
  pUserId IN VARCHAR2,
  pToPageId IN VARCHAR2,
  xParamRegionCode OUT NOCOPY VARCHAR2,
  xParamFunctionName OUT NOCOPY VARCHAR2,
  xParamGroup OUT NOCOPY parameter_group_tbl_type,
  x_DrillDefaultParameters OUT NOCOPY VARCHAR2,
  x_return_status    OUT	NOCOPY VARCHAR2,
  x_msg_count	    OUT	NOCOPY NUMBER,
  x_msg_data	    OUT	NOCOPY VARCHAR2
) IS


CURSOR getParamsFromReport IS
SELECT attribute_name, dimension, session_value, session_description, period_date
FROM bis_user_attributes
WHERE function_name = pFunctionName
AND session_id = pSessionId
AND user_id = pUserId
AND schedule_id IS NULL;

vAttributeCodeTable BISVIEWER.t_char;
vDimensionTable     BISVIEWER.t_char;
vSessionValueTable     BISVIEWER.t_char;
vSessionDescTable     BISVIEWER.t_char;
vPeriodDateTable     BISVIEWER.t_date;

lAttributeCodeTable BISVIEWER.t_char;
lDimensionTable     BISVIEWER.t_char;
lSessionValueTable     BISVIEWER.t_char;
lSessionDescTable     BISVIEWER.t_char;
lPeriodDateTable     BISVIEWER.t_date;

  lAttrNameForInsert BISVIEWER.t_char;
  lDimensionForInsert BISVIEWER.t_char;
  lSessValueForInsert BISVIEWER.t_char;
  lSessDescForInsert BISVIEWER.t_char;
  lPeriodDateForInsert BISVIEWER.t_date;
  lAttrNameForDelete BISVIEWER.t_char;

lTCTExists boolean := false;
lNestedRegionCode VARCHAR2(250);
lAsofDateExists  boolean;
l_valid VARCHAR2(1);
BEGIN

   getPageParamFuncProps( pToPageId, pUserId, xParamFunctionName, xParamRegionCode);

    IF (xParamFunctionName IS NOT NULL AND xParamRegionCode IS NOT NULL ) THEN
        getParameterGroupsForRegion ( pRegionCode => xParamRegionCode,
                                      xParameterGroup =>  xParamGroup,
                                      xTCTExists => lTCTExists,
                                      xNestedRegion => lNestedRegionCode,
                                      xAsofDateExists => lAsofDateExists);

       -- get the attributes from the pageFrom
       IF getParamsFromReport%ISOPEN then
            close getParamsFromReport;
       END IF;
       OPEN getParamsFromReport;
       FETCH getParamsFromReport BULK COLLECT INTO vAttributeCodeTable, vDimensionTable, vSessionValueTable, vSessionDescTable, vPeriodDateTable;
       CLOSE getParamsFromReport;

    --nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
	GET_VALIDATED_DRILL_PARAMS (
	  lAttributeCodeTable  => vAttributeCodeTable,
	  lDimensionTable      => vDimensionTable,
	  lSessionValueTable   => vSessionValueTable,
	  lSessionDescTable    => vSessionDescTable,
	  lPeriodDateTable     => vPeriodDateTable,
	  pParamRegionCode     => xParamRegionCode,
	  pParamFunctionName   => xParamFunctionName,
	  pParamRegionGroup    => xParamGroup,
	  pPageId              => pToPageId,
	  pUserId              => pUserId,
	  xAttributeCodeTable  => lAttributeCodeTable,
	  xDimensionTable      => lDimensionTable,
	  xSessionValueTable   => lSessionValueTable,
	  xSessionDescTable    => lSessionDescTable,
	  xPeriodDateTable     => lPeriodDateTable,
	  x_DrillDefaultParameters => x_DrillDefaultParameters
	);

        --get all the delete and  insert tables
        getDeleteAndInsertTables(
          pUserId             => pUserId,
          pAttributeNameTbl => lAttributeCodeTable,
          pDimensionTbl => lDimensionTable,
          pSessionValueTbl => lSessionValueTable,
          pSessionDescTbl => lSessionDescTable,
          pPeriodDateTbl=> lPeriodDateTable,
          pParameterGroup => xParamGroup,
          pIncludeViewBy => FALSE,
          pIncludeBusinessPlan => FALSE,
          pIncludePrevAsOfDate => TRUE,
          xAttrNameForInsert => lAttrNameForInsert,
          xDimensionForInsert => lDimensionForInsert,
          xSessValueForInsert => lSessValueForInsert,
          xSessDescForInsert => lSessDescForInsert,
          xPeriodDateForInsert => lPeriodDateForInsert,
          xAttrNameForDelete => lAttrNameForDelete
        ) ;

        --bulk delete and insert for the page
        IF (lAttrNameForDelete IS NOT NULL AND lAttrNameForDelete.COUNT > 0) THEN
          bulkDeleteFromPage(
           pPAgeId  => pToPageId  ,
           pUserId  => pUserId   ,
           pFunctionName => xParamFunctionName,
            pAttributeNameTbl => lAttrNameForDelete
           );
        END IF;

        IF (lAttrNameForInsert IS NOT NULL AND lAttrNameForInsert.COUNT > 0) THEN
          bulkInsertIntoPage(
           pSessionId => pSessionId,
           pPageId => pToPageId,
           pUserId  => pUserId,
           pFunctionName => xParamFunctionName,
           pAttributeNameTbl => lAttrNameForInsert,
           pDimensionTbl => lDimensionForInsert,
           pSessionValueTbl => lSessValueForInsert,
           pSessionDescTbl => lSessDescForInsert,
           pPeriodDateTbl => lPeriodDateForInsert
          );
        END IF;
      END IF; --lRegionCode

   COMMIT;
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

END copyParamsFromReportToPage;

PROCEDURE saveDateParams(
     p_user_Session_rec	BIS_PMV_SESSION_PVT.session_rec_type,
     pAsOfDate IN DATE ,
	   p_prev_asof_Date IN DATE ,
	   p_curr_effective_start_date IN DATE ,
	   p_curr_effective_end_date IN DATE ,
	   p_curr_report_Start_date  IN DATE ,
	   p_prev_report_Start_date IN DATE,
	   p_time_level_id	IN VARCHAR2,
	   p_time_level_value	IN VARCHAR2,
	   p_prev_effective_start_date	 IN DATE,
	   p_prev_effective_end_date	 IN DATE,
	   p_prev_time_level_id	   IN VARCHAR2,
	   p_prev_time_level_value IN VARCHAR2
) IS
  l_parameter_rec	BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE;
  l_date_format varchar2(30) := 'DD-MM-RRRR';
  l_asof_Date DATE;
  x_return_status		VARCHAR2(2000);
  x_msg_count			NUMBER;
  x_msg_data		    VARCHAR2(2000);
  l_canonical_date_format   varchar2(30) := 'DD/MM/RRRR';

BEGIN

    IF (pAsOfDate IS NOT NULL) THEN

        --serao - bug 3087341
        l_asof_Date := pAsOfDate;
        l_parameter_Rec.parameter_name := 'AS_OF_DATE';
        --l_parameter_Rec.parameter_description := to_char(l_asof_date,'DD-MON-YYYY');
        --l_parameter_rec.parameter_value := to_char(l_asof_date,'DD-MON-YYYY');

        l_parameter_Rec.parameter_description := to_char(l_asof_date,l_canonical_date_format);
        l_parameter_rec.parameter_value := to_char(l_asof_date,l_canonical_date_format);
        l_parameter_Rec.period_date := trunc(l_asof_Date);
        l_parameter_Rec.default_flag := 'N';
        l_parameter_rec.hierarchy_flag := 'N';

        CREATE_PARAMETER (p_user_session_rec => p_user_session_rec
                      ,p_parameter_rec => l_parameter_rec
                      ,x_return_status => x_return_status
                      ,x_msg_count => x_msg_count
                      ,x_msg_data => x_msg_data);

          --BIS_P_ASOF_DATE Record
          BIS_PMV_TIME_LEVELS_PVT.GET_TIME_PARAMETER_RECORD (
            p_TimeParamterName => 'BIS_P_ASOF_DATE',
            p_DateParameter    => p_prev_asof_Date,
            x_parameterRecord  => l_parameter_rec,
            x_Return_status    => x_return_Status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data
          );

          CREATE_PARAMETER ( p_user_session_rec => p_user_session_rec,
               p_parameter_rec    => l_parameter_rec,
               x_return_status    => x_return_status,
               x_msg_count        => x_msg_count,
               x_msg_data         => x_msg_data
          );

          --BIS_CUR_REPORT_START_DATE Record
          BIS_PMV_TIME_LEVELS_PVT.GET_TIME_PARAMETER_RECORD(
            p_TimeParamterName => 'BIS_CUR_REPORT_START_DATE',
            p_DateParameter    => p_curr_report_Start_date,
            x_parameterRecord  => l_parameter_rec,
            x_Return_status    => x_return_Status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data
          );

          CREATE_PARAMETER ( p_user_session_rec => p_user_session_rec,
            p_parameter_rec    => l_parameter_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data
          );

          --BIS_PREV_REPORT_START_DATE Record
          BIS_PMV_TIME_LEVELS_PVT.GET_TIME_PARAMETER_RECORD(
            p_TimeParamterName => 'BIS_PREV_REPORT_START_DATE',
            p_DateParameter		 => p_prev_report_Start_date,
            x_parameterRecord  => l_parameter_rec,
            x_Return_status    => x_return_Status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data
          );

          CREATE_PARAMETER ( p_user_session_rec => p_user_session_rec,
            p_parameter_rec    => l_parameter_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data
      	  );

    	  l_parameter_rec.dimension   	    := NULL;
        l_parameter_rec.default_flag		  := 'N';
    	  l_parameter_rec.parameter_name	  := 'BIS_PREVIOUS_EFFECTIVE_START_DATE';
        l_parameter_rec.parameter_value	  := p_prev_time_level_id;
    	  l_parameter_rec.parameter_description   := p_prev_time_level_value;
        l_parameter_rec.period_date             := p_prev_effective_start_date;

        CREATE_PARAMETER ( p_user_session_rec => p_user_session_rec,
            p_parameter_rec    => l_parameter_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data
    	  );

        --BIS_PREVIOUS_EFFECTIVE_END_DATE Record
        l_parameter_rec.dimension   	          := NULL;
        l_parameter_rec.default_flag		  := 'N';
        l_parameter_rec.parameter_name	  := 'BIS_PREVIOUS_EFFECTIVE_END_DATE';
        l_parameter_rec.parameter_value	  := p_prev_time_level_id;
        l_parameter_rec.parameter_description   := p_prev_time_level_value;
        l_parameter_rec.period_date             := p_prev_effective_end_date;

        CREATE_PARAMETER ( p_user_session_rec => p_user_session_rec,
            p_parameter_rec    => l_parameter_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data
        );

  END IF ; --pAsOfDate

END saveDateParams;

--BugFix 3308824
PROCEDURE SAVE_TIME_PARAMS(pTimeAttribute IN VARCHAR2,
    p_user_Session_rec	IN BIS_PMV_SESSION_PVT.session_rec_type,
    x_time_level_id IN  VARCHAR2,
    x_time_level_value IN VARCHAR2,
    x_start_date IN DATE,
    x_end_date IN DATE
)IS

l_return_status	VARCHAR2(2000);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(2000);
l_parameter_rec parameter_rec_type;
l_time_parameter_rec time_parameter_rec_type;

BEGIN

           l_time_parameter_rec.parameter_name := pTimeAttribute;
           l_time_parameter_rec.dimension := substr(pTimeAttribute,1,instr(pTimeAttribute,'+')-1);
           l_time_parameter_rec.from_description := x_time_level_id;
           l_time_parameter_rec.to_description := x_time_level_id;
           l_time_parameter_rec.default_flag := 'N';
           l_time_parameter_rec.id_flag := 'Y';
           --BugFix 3515051
           VALIDATE_AND_SAVE_TIME(p_user_session_rec => p_user_session_rec,
                                  p_time_parameter_rec => l_time_parameter_rec,
                                  x_return_status  => l_return_status,
                                  x_msg_count => l_msg_count,
                                  x_msg_data => l_msg_data);

/*
	     l_parameter_rec.dimension := l_time_parameter_rec.dimension;
	     l_parameter_rec.default_flag := l_time_parameter_rec.default_flag;

	     l_parameter_rec.parameter_name := l_time_parameter_rec.parameter_name || '_FROM';
	     l_parameter_rec.parameter_description := l_time_parameter_rec.from_description;
	     l_parameter_Rec.parameter_Value := l_Time_parameter_rec.from_description;
	     l_parameter_Rec.period_date := x_start_date;
	     --create the "from" record

	     CREATE_PARAMETER (p_user_session_rec => p_user_session_rec
        	              ,p_parameter_rec => l_parameter_rec
                	      ,x_return_status => l_return_status
	                      ,x_msg_count => l_msg_count
        	              ,x_msg_data => l_msg_data);

	     l_parameter_rec.parameter_name := l_time_parameter_rec.parameter_name || '_TO';
	     l_parameter_rec.parameter_description := l_time_parameter_rec.to_description;
	     l_parameter_Rec.parameter_Value := l_Time_parameter_rec.to_description;
	     l_parameter_Rec.period_date := x_end_date;

	     --create the "to" record
	     CREATE_PARAMETER (p_user_session_rec => p_user_session_rec
        	              ,p_parameter_rec => l_parameter_rec
                	      ,x_return_status => l_return_status
	                      ,x_msg_count => l_msg_count
        	              ,x_msg_data => l_msg_data);
*/
END SAVE_TIME_PARAMS;

PROCEDURE COMPUTE_AND_SAVE_DATES(
    pTimeAttribute IN VARCHAR2,
    pTimeComparisonType IN VARCHAR2,
    p_user_Session_rec	BIS_PMV_SESSION_PVT.session_rec_type,
    x_time_level_id OUT NOCOPY VARCHAR2,
    x_time_level_value OUT NOCOPY VARCHAR2
) IS
l_time_attr_2      varchar2(2000);
l_time_level_id	   VARCHAR2(2000);
l_time_level_value VARCHAR2(2000);

l_asof_date VARCHAR2(80);
l_prev_asof_date_desc varchar2(80);
l_curr_report_start_date_desc varchar2(80);
l_prev_report_start_date_desc varchar2(80);

l_prev_asof_Date		DATE;
l_curr_effective_start_date	DATE;
l_curr_effective_end_date	DATE;
l_curr_report_start_date	DATE;
l_prev_report_start_date	DATE;
-- nbarik - 07/17/03 - Bug Fix 2999602
l_prev_effective_start_date	DATE;
l_prev_effective_end_date	DATE;
l_prev_time_level_id	        VARCHAR2(2000);
l_prev_time_level_value         VARCHAR2(2000);

l_return_status		VARCHAR2(2000);
l_msg_count			NUMBER;
l_msg_data		    VARCHAR2(2000);
l_error    varchar2(1000);

BEGIN
	  BIS_PMV_TIME_LEVELS_PVT.GET_COMPUTED_DATES(
	    p_region_code		   => p_user_session_rec.region_code,
	    p_resp_id			   => p_user_session_rec.responsibility_id,
	    p_time_comparison_type         => pTimeComparisonType,
	    p_asof_date                    => NULL, --serao - bug 3087341
	    p_time_level                   => pTimeAttribute,
	    x_prev_asof_Date               => l_prev_asof_date,
	    x_curr_effective_start_date    => l_curr_effective_start_date,
	    x_curr_effective_end_date      => l_curr_effective_end_date,
	    x_curr_report_Start_date       => l_curr_report_start_date,
	    x_prev_report_Start_date       => l_prev_report_start_date,
	    x_time_level_id		           => l_time_level_id,
	    x_time_level_value		       => l_time_level_value,
            x_prev_effective_start_date	   => l_prev_effective_start_date,
            x_prev_effective_end_date	   => l_prev_effective_end_date,
	    x_prev_time_level_id	   => l_prev_time_level_id,
	    x_prev_time_level_value	   => l_prev_time_level_value,
	    x_return_status                => l_return_status,
	    x_msg_count                    => l_msg_count,
	    x_msg_Data                     => l_msg_Data
	  );
          x_time_level_id := l_time_level_id;
	  x_time_level_value := l_time_level_value;

	  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    RETURN;
	  END IF;

          saveDateParams(
	     p_user_Session_rec	=> p_user_Session_rec,
	     pAsOfDate => SYSDATE,
	     p_prev_asof_Date => l_prev_asof_date,
	     p_curr_effective_start_date =>  l_curr_effective_start_date,
	     p_curr_effective_end_date => l_curr_effective_end_date ,
	     p_curr_report_Start_date  => l_curr_report_start_date,
	     p_prev_report_Start_date => l_prev_report_start_date,
	     p_time_level_id	=> l_time_level_id,
	     p_time_level_value	=> l_time_level_value,
             p_prev_effective_start_date	=> l_prev_effective_start_date,
             p_prev_effective_end_date	=> l_prev_effective_end_date ,
	     p_prev_time_level_id		=> l_prev_time_level_id,
	     p_prev_time_level_value	=> l_prev_time_level_value
	   );

        --BugFix 3308824
	SAVE_TIME_PARAMS(pTimeAttribute => pTimeAttribute,
	    p_user_Session_rec	=> p_user_Session_rec,
	    x_time_level_id => l_time_level_id,
	    x_time_level_value => l_time_level_value,
	    x_start_date => l_curr_report_start_date,
	    x_end_date => l_curr_effective_end_date
	);


END COMPUTE_AND_SAVE_DATES;

--BugFix 3099789 Moved Time Saving logic from override preFunction to copy_time_params
-- nbarik - 02/19/04 - BugFix 3441967 - Added p_IsPreFuncTCTExists, p_IsPreFuncCalcDatesExists
PROCEDURE COPY_TIME_PARAMS(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pRespId         in  varchar2 default null,
                           pParameterGroup IN parameter_group_tbl_type,
                           pTCTExists      in boolean default false,
                           p_IsPreFuncTCTExists IN BOOLEAN DEFAULT TRUE,
                           p_IsPreFuncCalcDatesExists IN BOOLEAN DEFAULT TRUE,
                           x_time_attribute OUT NOCOPY VARCHAR2
)IS
CURSOR getFunctionParameters IS
  SELECT attribute_name, dimension, session_value, session_description, period_date
  FROM bis_user_attributes
  WHERE function_name =pFunctionName
  AND session_id = pSessionId
  AND user_id = pUserId
  AND (attribute_name ='AS_OF_DATE' OR dimension ='TIME');

vAttributeCodeTable BISVIEWER.t_char;
vDimensionTable     BISVIEWER.t_char;
vSessionValueTable     BISVIEWER.t_char;
vSessionDescTable     BISVIEWER.t_char;
vPeriodDateTable     BISVIEWER.t_date;

l_time_attr_2      varchar2(2000);
l_time_level_id	   VARCHAR2(2000);
l_time_level_value VARCHAR2(2000);

l_asof_date VARCHAR2(80);
l_prev_asof_date_desc varchar2(80);
l_curr_report_start_date_desc varchar2(80);
l_prev_report_start_date_desc varchar2(80);

l_prev_asof_Date		DATE;
l_curr_effective_start_date	DATE;
l_curr_effective_end_date	DATE;
l_curr_report_start_date	DATE;
l_prev_report_start_date	DATE;
-- nbarik - 07/17/03 - Bug Fix 2999602
l_prev_effective_start_date	DATE;
l_prev_effective_end_date	DATE;
l_prev_time_level_id	        VARCHAR2(2000);
l_prev_time_level_value         VARCHAR2(2000);

l_return_status		VARCHAR2(2000);
l_msg_count			NUMBER;
l_msg_data		    VARCHAR2(2000);

IsTimeDimensionInGroup BOOLEAN := FALSE;
l_count    number;
l_canonical_date_format   VARCHAR2(30) :='DD/MM/RRRR';
BEGIN
     IF getFunctionParameters%ISOPEN THEN
        CLOSE getFunctionParameters;
     END IF;
     OPEN getFunctionParameters;
     FETCH getFunctionParameters BULK COLLECT INTO vAttributeCodeTable, vDimensionTable, vSessionValueTable, vSessionDescTable, vPeriodDateTable;
     CLOSE getFunctionParameters;

      --nbarik - 10/21/03 - Bug Fix 3201277
      IF vAttributeCodeTable IS NOT NULL AND vAttributeCodeTable.COUNT > 0 THEN
       FOR k IN vAttributeCodeTable.FIRST..vAttributeCodeTable.LAST LOOP
         IF vDimensionTable(k) = 'TIME' THEN
           x_time_attribute := vAttributeCodeTable(k);
           EXIT;
         END IF;
       END LOOP;
     END IF;

     --serao - bug3093012- if there is no time, then there is no need to
     -- calculate the as_of_date related params
     IsTimeDimensionInGroup := IsdimensionInParamGrp( 'TIME', pParameterGroup);

     --aleung, 7/16/03, bug 2965660
     IF (pTCTExists <> true AND IsTimeDimensionInGroup) THEN

      IF vAttributeCodeTable IS NOT NULL AND vAttributeCodeTable.COUNT > 0 THEN
       FOR i IN vAttributeCodeTable.FIRST..vAttributeCodeTable.LAST LOOP
         IF vAttributeCodeTable(i) = 'AS_OF_DATE' THEN
            l_asof_date := vSessionValueTable(i);
         ELSIF substr(vAttributeCodeTable(i), length(vAttributeCodeTable(i))-length('_FROM')+1) = '_FROM' THEN
            l_time_attr_2 := substr(vAttributeCodeTable(i),1, length(vAttributeCodeTable(i))-length('_FROM'));
         END IF;
       END LOOP;
     END IF;

        --serao - added timeattr check for bug 3113428
	IF (l_asof_date IS NOT NULL AND l_time_attr_2 IS NOT NULL) THEN
	  --get all the date information.
          -- nbarik - 07/17/03 - Bug Fix 2999602

	  BIS_PMV_TIME_LEVELS_PVT.GET_COMPUTED_DATES(
	    p_region_code				   => pRegionCode,
	    p_resp_id					   => pRespId,
	    p_time_comparison_type         => 'TIME_COMPARISON_TYPE+SEQUENTIAL',
	    p_asof_date                    => l_asof_date,
	    p_time_level                   => l_time_attr_2,
	    x_prev_asof_Date               => l_prev_asof_date,
	    x_curr_effective_start_date    => l_curr_effective_start_date,
	    x_curr_effective_end_date      => l_curr_effective_end_date,
	    x_curr_report_Start_date       => l_curr_report_start_date,
	    x_prev_report_Start_date       => l_prev_report_start_date,
	    x_time_level_id		           => l_time_level_id,
	    x_time_level_value		       => l_time_level_value,
            x_prev_effective_start_date	   => l_prev_effective_start_date,
            x_prev_effective_end_date	   => l_prev_effective_end_date,
	    x_prev_time_level_id	   => l_prev_time_level_id,
	    x_prev_time_level_value	   => l_prev_time_level_value,
	    x_return_status                => l_return_status,
	    x_msg_count                    => l_msg_count,
	    x_msg_Data                     => l_msg_Data
	  );

	  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	    RETURN;
	  END IF;

    --l_prev_asof_date_desc := to_char(l_prev_asof_date,'DD-MON-YYYY');
    --l_curr_report_start_date_desc := to_char(l_curr_report_start_date,'DD-MON-YYYY');
    --l_prev_report_start_date_desc := to_char(l_prev_report_start_date,'DD-MON-YYYY');

    l_prev_asof_date_desc := to_char(l_prev_asof_date,l_canonical_date_format);
    l_curr_report_start_date_desc := to_char(l_curr_report_start_date,l_canonical_date_format);
    l_prev_report_start_date_desc := to_char(l_prev_report_start_date,l_canonical_date_format);


     IF vAttributeCodeTable IS NOT NULL AND vAttributeCodeTable.COUNT > 0 THEN

            l_count := vAttributeCodeTable.COUNT+1;
            vAttributeCodeTable(l_count) := 'BIS_P_ASOF_DATE';
            vSessionValueTable(l_count) := l_prev_asof_date_desc;
            vSessionDescTable(l_count) := l_prev_asof_date_desc;
            vPeriodDateTable(l_count) := l_prev_asof_date;
            vDimensionTable(l_count) := null;
            l_count := l_count + 1;

            vAttributeCodeTable(l_count) := 'BIS_CUR_REPORT_START_DATE';
            vSessionValueTable(l_count) := l_curr_report_start_date_desc;
            vSessionDescTable(l_count) := l_curr_report_start_date_desc;
            vPeriodDateTable(l_count) := l_curr_report_start_date;
            vDimensionTable(l_count) := null;
            l_count := l_count + 1;

            vAttributeCodeTable(l_count) := 'BIS_PREV_REPORT_START_DATE';
            vSessionValueTable(l_count) := l_prev_report_start_date_desc;
            vSessionDescTable(l_count) := l_prev_report_start_date_desc;
            vPeriodDateTable(l_count) := l_prev_report_start_date;
            vDimensionTable(l_count) := null;
            l_count := l_count + 1;

            vAttributeCodeTable(l_count) := 'BIS_PREVIOUS_EFFECTIVE_START_DATE';
            vSessionValueTable(l_count) := l_prev_time_level_id;
            vSessionDescTable(l_count) := l_prev_time_level_value;
            vPeriodDateTable(l_count) := l_prev_effective_start_date;
            vDimensionTable(l_count) := null;
            l_count := l_count + 1;

            vAttributeCodeTable(l_count) := 'BIS_PREVIOUS_EFFECTIVE_END_DATE';
            vSessionValueTable(l_count) := l_prev_time_level_id;
            vSessionDescTable(l_count) := l_prev_time_level_value;
            vPeriodDateTable(l_count) := l_prev_effective_end_date;
            vDimensionTable(l_count) := null;

      END IF;

    END IF; -- copy params only if the get_computed func was called , bug 3543057
     -- nbarik - 02/19/04 - Bug Fix 3441967
     /*The below condition will be true only when we are navigating from a report which don't
        have TCT defined to a report which has TCT defined. So in this case we don't want to
        calculate date related parameters again. Instead we will copy the TCT as SEQUENTIAL,
        since date parameters saved for previous report is based on SEQUENTIAL.
     */
     ELSIF (pTCTExists AND ( NOT p_IsPreFuncTCTExists ) AND p_IsPreFuncCalcDatesExists) THEN
       IF vAttributeCodeTable IS NOT NULL AND vAttributeCodeTable.COUNT > 0 THEN
         l_count := vAttributeCodeTable.COUNT+1;
         vAttributeCodeTable(l_count) := 'TIME_COMPARISON_TYPE+SEQUENTIAL';
         vSessionValueTable(l_count) := 'TIME_COMPARISON_TYPE+SEQUENTIAL';
         vSessionDescTable(l_count) := 'TIME_COMPARISON_TYPE+SEQUENTIAL';
         vPeriodDateTable(l_count) := null;
         vDimensionTable(l_count) := 'TIME_COMPARISON_TYPE';
       END IF;
     END IF;--!pTCTExists

     deleteAndInsertIntoSession(
              pSessionId  => pSessionId,
              pUserId     => pUserId,
              pFunctionName   => pFunctionName,
              pAttributeNameTbl => vAttributeCodeTable,
              pDimensionTbl => vDimensionTable,
              pSessionValueTbl => vSessionValueTable,
              pSessionDescTbl => vSessionDescTable,
              pPeriodDateTbl => vPeriodDateTable,
              pParameterGroup => pParameterGroup,
              pIncludePrevAsOfDate => TRUE
     );


END COPY_TIME_PARAMS;

--Pass as of date as Date 3094234
PROCEDURE UPDATE_COMPUTED_DATES(
            p_user_id                             IN NUMBER,
            p_page_id                            IN NUMBER,
	p_function_name                  IN VARCHAR2,
	p_time_comparison_type       IN VARCHAR2,
	p_asof_date                         IN DATE,
	p_time_level                         IN VARCHAR2,
	x_prev_asof_Date                 OUT NOCOPY DATE,
	x_curr_report_Start_date       OUT NOCOPY DATE,
	x_prev_report_Start_date       OUT NOCOPY DATE,
	x_curr_effective_start_date    OUT NOCOPY DATE,
	x_curr_effective_end_date      OUT NOCOPY DATE,
	x_time_level_id                     OUT NOCOPY VARCHAR2,
	x_time_level_value                OUT NOCOPY VARCHAR2,
            x_prev_effective_start_date    OUT NOCOPY DATE,
            x_prev_effective_end_date     OUT NOCOPY DATE,
            x_prev_time_level_id             OUT NOCOPY VARCHAR2,
            x_prev_time_level_value        OUT NOCOPY VARCHAR2,
	x_prev_asof_Date_char                 OUT NOCOPY VARCHAR2,
	x_curr_report_Start_date_char       OUT NOCOPY VARCHAR2,
	x_prev_report_Start_date_char       OUT NOCOPY VARCHAR2,
	x_curr_eff_start_date_char    OUT NOCOPY VARCHAR2,
	x_curr_eff_end_date_char      OUT NOCOPY VARCHAR2,
            x_prev_eff_start_date_char    OUT NOCOPY VARCHAR2,
            x_prev_eff_end_date_char     OUT NOCOPY VARCHAR2,
	x_return_status                   OUT NOCOPY VARCHAR2,
        p_plug_id                             IN NUMBER DEFAULT 0
	)
	IS

  l_RegionCode           varchar2(80);

  l_AsOfDate_Char                  varchar2(80);
  l_PrevAsOfDate_Char            varchar2(80);
  l_CurrReportStartDate_Char   varchar2(80);
  l_PrevReportStartDate_Char   varchar2(80);

  l_TimeLevelId              varchar2(2000);
  l_TimeLevelValue        varchar2(2000);
  l_PrevTimeLevelId       varchar2(2000);
  l_PrevTimeLevelValue  varchar2(2000);

  l_PrevAsOfDate            date;
  l_CurrReportStartDate   date;
  l_PrevReportStartDate   date;
  l_CurrEffStartDate         date;
  l_CurrEffEndDate          date;
  l_PrevEffStartDate        date;
  l_PrevEffEndDate         date;

  l_msg_count      number;
  l_msg_Data       varchar2(200);
  l_canonical_format varchar2(100) := 'DD/MM/YYYY';


	CURSOR getScheduleId (p_plug_id NUMBER, p_user_id NUMBER) IS
	 SELECT SCHEDULE_ID
	 FROM BIS_SCHEDULE_PREFERENCES
	 WHERE PLUG_ID = p_plug_id
	 AND USER_ID = p_user_id;

	 l_schedule_id NUMBER;

BEGIN

     l_RegionCode := BIS_PMV_UTIL.getReportRegion(p_function_name);
     l_AsOfDate_Char := to_char(p_asof_date,l_canonical_format);

     BIS_PMV_TIME_LEVELS_PVT.GET_COMPUTED_DATES (
	p_region_code => l_RegionCode,
	p_resp_id => null,
	p_time_comparison_type => p_time_comparison_type,
	p_asof_date => l_AsOfDate_Char,
	p_time_level  => p_time_level,
	x_prev_asof_Date => l_PrevAsOfDate,
	x_curr_effective_start_date => l_CurrEffStartDate,
	x_curr_effective_end_date => l_CurrEffEndDate,
	x_curr_report_Start_date => l_CurrReportStartDate,
	x_prev_report_Start_date => l_PrevReportStartDate,
	x_time_level_id => l_TimeLevelId,
	x_time_level_value => l_TimeLevelValue,
            x_prev_effective_start_date => l_PrevEffStartDate,
            x_prev_effective_end_date => l_PrevEffEndDate,
            x_prev_time_level_id => l_PrevTimeLevelId,
            x_prev_time_level_value => l_PrevTimeLevelValue,
	x_return_status => x_return_status,
	x_msg_count => l_msg_count,
	x_msg_Data => l_msg_data
	);


   l_PrevAsOfDate_Char := to_char(l_PrevAsOfDate, l_canonical_format);
   l_CurrReportStartDate_Char := to_char(l_CurrReportStartDate, l_canonical_format);
   l_PrevReportStartDate_Char := to_char(l_PrevReportStartDate, l_canonical_format);
   x_curr_eff_start_date_char := to_char(l_CurrEffStartDate, l_canonical_format);
   x_curr_eff_end_date_char := to_char(l_CurrEffEndDate, l_canonical_format);
   x_prev_eff_start_date_char := to_char(l_PrevEffStartDate, l_canonical_format);
   x_prev_eff_end_date_char := to_char(l_PrevEffEndDate, l_canonical_format);


	IF p_page_id IS NULL THEN
          --update bis_user_attributes for schedule_id -ansingh
		IF getScheduleId%ISOPEN THEN
			CLOSE getScheduleId;
		END IF;
		OPEN getScheduleId(p_plug_id, p_user_id);
			FETCH getScheduleId INTO l_schedule_id;
		CLOSE getScheduleId;


		UPDATE BIS_USER_ATTRIBUTES SET
		 session_value = DECODE(attribute_name, 'AS_OF_DATE', l_AsOfDate_Char, 'BIS_P_ASOF_DATE', l_PrevAsOfDate_Char,
		 'BIS_CUR_REPORT_START_DATE', l_CurrReportStartDate_Char, 'BIS_PREV_REPORT_START_DATE', l_PrevReportStartDate_Char,
		 'BIS_PREVIOUS_EFFECTIVE_START_DATE', l_PrevTimeLevelId, 'BIS_PREVIOUS_EFFECTIVE_END_DATE', l_PrevTimeLevelId,
		 p_time_level || '_FROM', l_TimeLevelId, p_time_level || '_TO', l_TimeLevelId),

		 session_description = DECODE(attribute_name, 'AS_OF_DATE', l_AsOfDate_Char, 'BIS_P_ASOF_DATE', l_PrevAsOfDate_Char,
		 'BIS_CUR_REPORT_START_DATE', l_CurrReportStartDate_Char, 'BIS_PREV_REPORT_START_DATE', l_PrevReportStartDate_Char,
		 'BIS_PREVIOUS_EFFECTIVE_START_DATE', l_PrevTimeLevelValue, 'BIS_PREVIOUS_EFFECTIVE_END_DATE', l_PrevTimeLevelValue,
		 p_time_level || '_FROM', l_TimeLevelValue, p_time_level || '_TO', l_TimeLevelValue),

		 period_date = DECODE(attribute_name, 'AS_OF_DATE', trunc(p_asof_date), 'BIS_P_ASOF_DATE', l_PrevAsOfDate,
		 'BIS_CUR_REPORT_START_DATE', l_CurrReportStartDate, 'BIS_PREV_REPORT_START_DATE', l_PrevReportStartDate,
		 'BIS_PREVIOUS_EFFECTIVE_START_DATE', l_PrevEffStartDate, 'BIS_PREVIOUS_EFFECTIVE_END_DATE', l_PrevEffEndDate,
		 p_time_level || '_FROM', l_CurrEffStartDate, p_time_level || '_TO', l_CurrEffEndDate),

		 last_update_date = sysdate,
		 last_updated_by = p_user_id
		WHERE schedule_id = l_schedule_id
		AND attribute_name IN ('AS_OF_DATE','BIS_P_ASOF_DATE','BIS_CUR_REPORT_START_DATE','BIS_PREV_REPORT_START_DATE',
		 'BIS_PREVIOUS_EFFECTIVE_START_DATE','BIS_PREVIOUS_EFFECTIVE_END_DATE',p_time_level || '_FROM', p_time_level || '_TO');
		COMMIT;

	ELSE
          --update bis_user_attributes for page_id -ansingh
		UPDATE BIS_USER_ATTRIBUTES SET
		 session_value = DECODE(attribute_name, 'AS_OF_DATE', l_AsOfDate_Char, 'BIS_P_ASOF_DATE', l_PrevAsOfDate_Char,
		 'BIS_CUR_REPORT_START_DATE', l_CurrReportStartDate_Char, 'BIS_PREV_REPORT_START_DATE', l_PrevReportStartDate_Char,
		 'BIS_PREVIOUS_EFFECTIVE_START_DATE', l_PrevTimeLevelId, 'BIS_PREVIOUS_EFFECTIVE_END_DATE', l_PrevTimeLevelId,
		 p_time_level || '_FROM', l_TimeLevelId, p_time_level || '_TO', l_TimeLevelId),

		 session_description = DECODE(attribute_name, 'AS_OF_DATE', l_AsOfDate_Char, 'BIS_P_ASOF_DATE', l_PrevAsOfDate_Char,
		 'BIS_CUR_REPORT_START_DATE', l_CurrReportStartDate_Char, 'BIS_PREV_REPORT_START_DATE', l_PrevReportStartDate_Char,
		 'BIS_PREVIOUS_EFFECTIVE_START_DATE', l_PrevTimeLevelValue, 'BIS_PREVIOUS_EFFECTIVE_END_DATE', l_PrevTimeLevelValue,
		 p_time_level || '_FROM', l_TimeLevelValue, p_time_level || '_TO', l_TimeLevelValue),

		 period_date = DECODE(attribute_name, 'AS_OF_DATE', trunc(p_asof_date), 'BIS_P_ASOF_DATE', l_PrevAsOfDate,
		 'BIS_CUR_REPORT_START_DATE', l_CurrReportStartDate, 'BIS_PREV_REPORT_START_DATE', l_PrevReportStartDate,
		 'BIS_PREVIOUS_EFFECTIVE_START_DATE', l_PrevEffStartDate, 'BIS_PREVIOUS_EFFECTIVE_END_DATE', l_PrevEffEndDate,
		 p_time_level || '_FROM', l_CurrEffStartDate, p_time_level || '_TO', l_CurrEffEndDate),

		 last_update_date = sysdate,
		 last_updated_by = p_user_id
		WHERE user_id = p_user_id
		AND page_id = p_page_id
		AND attribute_name IN ('AS_OF_DATE','BIS_P_ASOF_DATE','BIS_CUR_REPORT_START_DATE','BIS_PREV_REPORT_START_DATE',
		 'BIS_PREVIOUS_EFFECTIVE_START_DATE','BIS_PREVIOUS_EFFECTIVE_END_DATE',p_time_level || '_FROM', p_time_level || '_TO');
		COMMIT;

	END IF;


   x_prev_asof_Date :=  l_PrevAsOfDate;
   x_curr_report_Start_date := l_CurrReportStartDate;
   x_prev_report_Start_date := l_PrevReportStartDate;
   x_curr_effective_start_date := l_CurrEffStartDate;
   x_curr_effective_end_date := l_CurrEffEndDate;
   x_time_level_id := l_TimeLevelId;
   x_time_level_value := l_TimeLevelValue;
   x_prev_effective_start_date := l_PrevEffStartDate;
   x_prev_effective_end_date := l_PrevEffEndDate;
   x_prev_time_level_id := l_PrevTimeLevelId;
   x_prev_time_level_value := l_PrevTimeLevelValue;
   x_prev_asof_Date_char := l_PrevAsOfDate_Char;
   x_curr_report_Start_date_char := l_CurrReportStartDate_Char;
   x_prev_report_Start_date_char :=  l_PrevReportStartDate_Char;
   x_return_status := 'S';
EXCEPTION
WHEN others THEN
   rollback;
   x_return_status := 'E';
End UPDATE_COMPUTED_DATES;

END BIS_PMV_PARAMETERS_PVT;

/
