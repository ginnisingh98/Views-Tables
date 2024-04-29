--------------------------------------------------------
--  DDL for Package Body BIS_PMF_UTILITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_UTILITIES_PUB" AS
/* $Header: BISPPMUB.pls 115.4 99/10/11 15:03:52 porting sh $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPPMUB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for PMF utilities                                      |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 10-AUG-99 surao Creation                                              |
REM |                                                                       |
REM +=======================================================================+
*/
--
--
--
FUNCTION Get_LEVEL_ID
( p_Level_Short_Name IN VARCHAR2
)
RETURN NUMBER IS
--
l_level_id NUMBER;
--
BEGIN
  IF p_Level_Short_Name IS NULL THEN
    RETURN NULL;
  ELSE
    SELECT LEVEL_ID
    INTO l_level_id
    FROM BIS_LEVELS
    WHERE SHORT_NAME = p_Level_Short_Name;
    --
    RETURN l_level_id ;
  END IF ;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Get_Level_ID ;
--
--
FUNCTION Get_Target_For_Target_Level
( p_TARGET_LEVEL_SHORT_NAME IN VARCHAR2
, p_ORG_LEVEL_VALUE         IN VARCHAR2
, p_TIME_LEVEL_VALUE        IN VARCHAR2
, p_DIMENSION1_LEVEL_VALUE  IN VARCHAR2
, p_DIMENSION2_LEVEL_VALUE  IN VARCHAR2
, p_DIMENSION3_LEVEL_VALUE  IN VARCHAR2
, p_DIMENSION4_LEVEL_VALUE  IN VARCHAR2
, p_DIMENSION5_LEVEL_VALUE  IN VARCHAR2
, p_PLAN_NAME               IN VARCHAR2
)
RETURN NUMBER IS
--
l_target_level NUMBER;
l_target       NUMBER;
--
BEGIN
  SELECT TARGET_LEVEL_ID
  INTO l_target_level
  FROM BIS_TARGET_LEVELS L
  WHERE L.SHORT_NAME = p_TARGET_LEVEL_SHORT_NAME;
  --
  l_target := Get_Target_Value( l_target_level
                              , p_ORG_LEVEL_VALUE
                              , p_TIME_LEVEL_VALUE
                              , p_DIMENSION1_LEVEL_VALUE
                              , p_DIMENSION2_LEVEL_VALUE
                              , p_DIMENSION3_LEVEL_VALUE
                              , p_DIMENSION4_LEVEL_VALUE
                              , p_DIMENSION5_LEVEL_VALUE
                              , p_PLAN_NAME
                              ) ;
  RETURN l_target ;
--
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL ;
END Get_Target_For_Target_Level;
--
--
FUNCTION Get_Target_For_Level_ID
( p_MEASURE_SHORT_NAME     IN VARCHAR2
, p_ORG_LEVEL              IN NUMBER
, p_TIME_LEVEL             IN NUMBER
, p_DIMENSION1_LEVEL       IN NUMBER
, p_DIMENSION2_LEVEL       IN NUMBER
, p_DIMENSION3_LEVEL       IN NUMBER
, p_DIMENSION4_LEVEL       IN NUMBER
, p_DIMENSION5_LEVEL       IN NUMBER
, p_ORG_LEVEL_VALUE        IN VARCHAR2
, p_TIME_LEVEL_VALUE       IN VARCHAR2
, p_DIMENSION1_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION2_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION3_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION4_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION5_LEVEL_VALUE IN VARCHAR2
, p_PLAN_NAME              IN VARCHAR2
)
RETURN NUMBER IS
--
l_target_level NUMBER;
l_target       NUMBER;
--
BEGIN
  SELECT TARGET_LEVEL_ID
  INTO l_target_level
  FROM
    BIS_TARGET_LEVELS L
  , BIS_INDICATORS I
  WHERE I.INDICATOR_ID        = L.INDICATOR_ID
    AND I.SHORT_NAME          = p_MEASURE_SHORT_NAME
    AND L.ORG_LEVEL_ID        = p_ORG_LEVEL
    AND L.TIME_LEVEL_ID       = p_TIME_LEVEL
    AND ( ( p_DIMENSION1_LEVEL IS NOT NULL
            AND L.DIMENSION1_LEVEL_ID = p_DIMENSION1_LEVEL
          )
          OR
          ( p_DIMENSION1_LEVEL IS NULL
          )
        )
    AND ( ( p_DIMENSION2_LEVEL IS NOT NULL
            AND L.DIMENSION2_LEVEL_ID = p_DIMENSION2_LEVEL
          )
          OR
          ( p_DIMENSION2_LEVEL IS NULL
          )
        )
    AND ( ( p_DIMENSION3_LEVEL IS NOT NULL
            AND L.DIMENSION3_LEVEL_ID = p_DIMENSION3_LEVEL
          )
          OR
          ( p_DIMENSION3_LEVEL IS NULL
          )
        )
    AND ( ( p_DIMENSION4_LEVEL IS NOT NULL
            AND L.DIMENSION4_LEVEL_ID = p_DIMENSION4_LEVEL
          )
          OR
          ( p_DIMENSION4_LEVEL IS NULL
          )
        )
    AND ( ( p_DIMENSION5_LEVEL IS NOT NULL
            AND L.DIMENSION5_LEVEL_ID = p_DIMENSION5_LEVEL
          )
          OR
          ( p_DIMENSION5_LEVEL IS NULL
          )
        );
  --
  l_target := Get_Target_Value( l_TARGET_LEVEL
                              , p_ORG_LEVEL_VALUE
                              , p_TIME_LEVEL_VALUE
                              , p_DIMENSION1_LEVEL_VALUE
                              , p_DIMENSION2_LEVEL_VALUE
                              , p_DIMENSION3_LEVEL_VALUE
                              , p_DIMENSION4_LEVEL_VALUE
                              , p_DIMENSION5_LEVEL_VALUE
                              , p_PLAN_NAME
                              );
  RETURN l_target;
  --
EXCEPTION
  WHEN OTHERS THEN
--    DBMS_OUTPUT.PUT_LINE(SQLCODE||'  '||SQLERRM);
--    DBMS_OUTPUT.PUT_LINE('Measure short name = '||p_MEASURE_SHORT_NAME);
    RETURN NULL ;
END Get_Target_For_Level_ID;
--
--
FUNCTION Get_Target_For_Level
( p_MEASURE_SHORT_NAME     IN VARCHAR2
, p_ORG_LEVEL              IN VARCHAR2
, p_TIME_LEVEL             IN VARCHAR2
, p_DIMENSION1_LEVEL       IN VARCHAR2
, p_DIMENSION2_LEVEL       IN VARCHAR2
, p_DIMENSION3_LEVEL       IN VARCHAR2
, p_DIMENSION4_LEVEL       IN VARCHAR2
, p_DIMENSION5_LEVEL       IN VARCHAR2
, p_ORG_LEVEL_VALUE        IN VARCHAR2
, p_TIME_LEVEL_VALUE       IN VARCHAR2
, p_DIMENSION1_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION2_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION3_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION4_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION5_LEVEL_VALUE IN VARCHAR2
, p_PLAN_NAME              IN VARCHAR2
)
RETURN NUMBER IS
--
l_target_level        NUMBER;
l_target              NUMBER;
--
l_ORG_LEVEL_ID        NUMBER;
l_TIME_LEVEL_ID       NUMBER;
l_DIMENSION1_LEVEL_ID NUMBER;
l_DIMENSION2_LEVEL_ID NUMBER;
l_DIMENSION3_LEVEL_ID NUMBER;
l_DIMENSION4_LEVEL_ID NUMBER;
l_DIMENSION5_LEVEL_ID NUMBER;
--
BEGIN
  l_ORG_LEVEL_ID        := Get_level_ID ( p_ORG_LEVEL );
  l_TIME_LEVEL_ID       := Get_level_ID ( p_TIME_LEVEL );
  l_DIMENSION1_LEVEL_ID := Get_level_ID ( p_DIMENSION1_LEVEL );
  l_DIMENSION2_LEVEL_ID := Get_level_ID ( p_DIMENSION2_LEVEL );
  l_DIMENSION3_LEVEL_ID := Get_level_ID ( p_DIMENSION3_LEVEL );
  l_DIMENSION4_LEVEL_ID := Get_level_ID ( p_DIMENSION4_LEVEL );
  l_DIMENSION5_LEVEL_ID := Get_level_ID ( p_DIMENSION5_LEVEL );
  --
  SELECT TARGET_LEVEL_ID
  INTO l_target_level
  FROM
    BIS_TARGET_LEVELS L
  , BIS_INDICATORS I
  WHERE I.INDICATOR_ID        = L.INDICATOR_ID
    AND I.SHORT_NAME          = p_MEASURE_SHORT_NAME
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
  --
  l_target := Get_Target_Value( l_TARGET_LEVEL
                              , p_ORG_LEVEL_VALUE
                              , p_TIME_LEVEL_VALUE
                              , p_DIMENSION1_LEVEL_VALUE
                              , p_DIMENSION2_LEVEL_VALUE
                              , p_DIMENSION3_LEVEL_VALUE
                              , p_DIMENSION4_LEVEL_VALUE
                              , p_DIMENSION5_LEVEL_VALUE
                              , p_PLAN_NAME
                              );
--
  RETURN l_target ;
EXCEPTION
  WHEN OTHERS THEN
--    DBMS_OUTPUT.PUT_LINE(SQLCODE||'  '||SQLERRM);
--    DBMS_OUTPUT.PUT_LINE('Measure short name = '||p_MEASURE_SHORT_NAME);
    RETURN NULL ;
END Get_Target_For_Level;
--
--
FUNCTION Get_Target_Value
( p_TARGET_LEVEL_ID        IN NUMBER
, p_ORG_LEVEL_VALUE        IN VARCHAR2
, p_TIME_LEVEL_VALUE       IN VARCHAR2
, p_DIMENSION1_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION2_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION3_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION4_LEVEL_VALUE IN VARCHAR2
, p_DIMENSION5_LEVEL_VALUE IN VARCHAR2
, p_PLAN_NAME              IN VARCHAR2
)
RETURN NUMBER IS
--
l_target NUMBER;
l_plan_id NUMBER;
--
BEGIN
  SELECT PLAN_ID
    INTO l_plan_id
    FROM BIS_BUSINESS_PLANS_VL
   WHERE NAME = p_PLAN_NAME ;

  SELECT TARGET
    INTO l_target
    FROM BIS_TARGET_VALUES
   WHERE TARGET_LEVEL_ID = P_TARGET_LEVEL_ID
     AND PLAN_ID         = l_plan_id
     AND ORG_LEVEL_VALUE = P_ORG_LEVEL_VALUE
     AND UPPER(TIME_LEVEL_VALUE) = UPPER(p_TIME_LEVEL_VALUE)
     AND ((p_DIMENSION1_LEVEL_VALUE IS NOT NULL
       AND DIMENSION1_LEVEL_VALUE = p_DIMENSION1_LEVEL_VALUE )
       OR (p_DIMENSION1_LEVEL_VALUE IS NULL))
     AND ((p_DIMENSION2_LEVEL_VALUE IS NOT NULL
       AND DIMENSION2_LEVEL_VALUE = p_DIMENSION2_LEVEL_VALUE )
       OR (p_DIMENSION2_LEVEL_VALUE IS NULL))
     AND ((p_DIMENSION3_LEVEL_VALUE IS NOT NULL
       AND DIMENSION3_LEVEL_VALUE = p_DIMENSION3_LEVEL_VALUE )
       OR (p_DIMENSION3_LEVEL_VALUE IS NULL))
     AND ((p_DIMENSION4_LEVEL_VALUE IS NOT NULL
       AND DIMENSION4_LEVEL_VALUE = p_DIMENSION4_LEVEL_VALUE )
       OR (p_DIMENSION4_LEVEL_VALUE IS NULL))
     AND ((p_DIMENSION5_LEVEL_VALUE IS NOT NULL
       AND DIMENSION5_LEVEL_VALUE = p_DIMENSION5_LEVEL_VALUE )
       OR (p_DIMENSION5_LEVEL_VALUE IS NULL)) ;
  --
  RETURN l_target;
--
EXCEPTION
  WHEN OTHERS THEN
--    DBMS_OUTPUT.PUT_LINE(SQLCODE||'  '||SQLERRM);
--    DBMS_OUTPUT.PUT_LINE('p_TIME_LEVEL_VALUE = '||p_TIME_LEVEL_VALUE);
--    DBMS_OUTPUT.PUT_LINE('p_ORG_LEVEL_VALUE = '||p_ORG_LEVEL_VALUE);
--    DBMS_OUTPUT.PUT_LINE('p_DIMENSION1_LEVEL_VALUE = '
--                          ||p_DIMENSION1_LEVEL_VALUE);
    RETURN NULL;
END Get_Target_Value;
--
--
END BIS_PMF_UTILITIES_PUB;

/
