--------------------------------------------------------
--  DDL for Package Body BIS_DIM_LEVEL_VALUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DIM_LEVEL_VALUE_PVT" AS
/* $Header: BISVDMVB.pls 120.2 2005/11/02 17:43:27 jxyu noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVDMVB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing dimension level valuesfor the
REM |     Key Performance Framework.
REM |
REM |     This package should be maintaind by EDW once it gets integrated
REM |     with BIS.
REM |
REM | NOTES                                                                 |
REM | 01.23.02 sashaik Modified Is_Current_Time_Period and Is_Previous_Time_Period |
REM | 		       for bug 1740789			    		    |
REM | 22-OCT-02     mahrao   Fix for 2631537                                |
REM | 13-NOV-2002   mahrao   Fix for 2665526                                |
REM | 02-DEC-02     rchandra added check for org dependency in time
REM |                           dim levels for 2684911
REM | 10-DEC-02     rchandra changed the DimensionX_ID_to_Value to retrieve
REM |                         only one row if the dim lvl is org dep
REM | 26-JUN-03 RCHANDRA  do away with hard coded length for name and       |
REM |                      description for bug 2910316                      |
REM |                      for dimension and dimension levels               |
REM | 04-JUL-03 RCHANDRA  changed the  hard coded length for description    |
REM |                      for dimension level for bug 3033028              |
REM | 24-NOV-03 GRAMASAM  added a check for time dimension level for bug    |
REM |                       3255072                                         |
REM | 09-JAN-2004 rpenneru bug#3352065 modified Check for TIME DIMENSION    |
REM |        level method to BIS_UTILITIES_PVT.is_valid_time_dimension_level|
REM | 09-JAN-2004 ankgoel  bug#3001359 Modified to limit the dim level value|
REM |			   length to 240 characters			    |
REM | 19-OCT-2005 ppandey  Enh 4618419- SQL Literal Fix                   |
REM | 02-NOV-2005 jxyu     Fix bug#4711882                                  |
REM +=======================================================================+
*/

C_GL_COMPANY CONSTANT VARCHAR2(40) := 'GL COMPANY';
C_GL_SECONDARY_MEASURE CONSTANT VARCHAR2(40) := 'GL SECONDARY MEASURE';

--
--
Procedure Retrieve_Dim_Level_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  NULL;
END Retrieve_Dim_Level_Values;
--
--
PROCEDURE Get_Org_Dim_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_Responsibility_Tbl  IN  BIS_RESPONSIBILITY_PVT.Responsibility_Tbl_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_view_name   VARCHAR2(80);
l_short_name  VARCHAR2(30);
l_name        bis_levels_tl.name%TYPE;
l_cursor      INTEGER;
l_ind         NUMBER := 0;
l_id          VARCHAR2(250);
l_value       VARCHAR2(250);
l_select_stmt VARCHAR2(32000);
l_sql_result  INTEGER := 0;
l_resp_clause VARCHAR2(10000);
--
l_id1         DBMS_SQL.VARCHAR2_TABLE;
l_value1      DBMS_SQL.VARCHAR2_TABLE;
l_size        NUMBER := 100000;
l_retrieved   NUMBER;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT
    DIMENSION_LEVEL_SHORT_NAME
  , DIMENSION_LEVEL_NAME
  , LEVEL_VALUES_VIEW_NAME
  INTO
    l_short_name
  , l_name
  , l_view_name
  FROM BISBV_DIMENSION_LEVELS
  WHERE DIMENSION_LEVEL_ID = p_Dimension_Level_Rec.Dimension_Level_ID;
  --
  IF(l_short_name <> 'TOTAL_ORGANIZATIONS') THEN
    -- create the resps clause
    IF(p_Responsibility_Tbl.COUNT <> 0) THEN
      l_resp_clause := ' RESPONSIBILITY_ID IN ( ';
      FOR l_ind IN 1..p_Responsibility_Tbl.COUNT LOOP
        IF(l_ind = 1) THEN
          l_resp_clause
            := l_resp_clause
                 || ':b_resp' || l_ind;
        ELSE
          l_resp_clause
            := l_resp_clause
                 || ', '
                 || ':b_resp' || l_ind;
        END IF;
      END LOOP;
      l_resp_clause := l_resp_clause || ' ) ';
      l_resp_clause := l_resp_clause || ' OR RESPONSIBILITY_ID IS NULL ';
    END IF;

      IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
        DBMS_SQL.CLOSE_CURSOR(l_cursor);
      END IF;
      l_cursor := DBMS_SQL.OPEN_CURSOR;
      --
      IF(p_Responsibility_Tbl.COUNT <> 0) THEN
        l_select_stmt := 'SELECT DISTINCT'
                         || '  ID '
                         || ', VALUE '
                         || ' FROM '
                         || l_view_name
                         || ' WHERE '
                         || l_resp_clause
                         || ' ORDER BY VALUE';
      ELSE
        l_select_stmt := 'SELECT DISTINCT'
                         || '  ID '
                         || ', VALUE '
                         || ' FROM '
                         || l_view_name
                         || ' ORDER BY VALUE';
      END IF;
      DBMS_SQL.PARSE( c             => l_cursor
                    , statement     => l_select_stmt
                    , language_flag => DBMS_SQL.NATIVE
                    );
      FOR l_ind IN 1..p_Responsibility_Tbl.COUNT LOOP
        DBMS_SQL.BIND_VARIABLE
        ( l_cursor
        , ':b_resp' || TO_CHAR(l_ind)
        , p_Responsibility_Tbl(l_ind).Responsibility_ID
        );
      END LOOP;
      DBMS_SQL.DEFINE_ARRAY(l_cursor, 1, l_id1, l_size, 1);
      DBMS_SQL.DEFINE_ARRAY(l_cursor, 2, l_value1, l_size, 1);
      l_sql_result := DBMS_SQL.EXECUTE(l_cursor);
      --
      LOOP
        l_retrieved := DBMS_SQL.FETCH_ROWS(l_cursor);
        EXIT WHEN l_retrieved = 0;
        --
        DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_id1);
        DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_value1);
        --
        FOR l_ind1 IN 1..l_id1.COUNT LOOP
          l_ind := l_ind + 1;
          x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_ID
            := l_id1(l_ind1);
          x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_Name
            := l_value1(l_ind1);
          x_Dim_Level_Value_Tbl(l_ind).Dimension_level_ID
            := p_Dimension_Level_Rec.Dimension_Level_ID;
          x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Short_Name
            := l_short_name;
          x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Name
            := l_name;
        END LOOP;
        --
        EXIT WHEN l_retrieved < l_size;
      END LOOP;
      --
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
  ELSE
    l_ind := l_ind + 1;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_ID   := '-1';
    x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_Name := l_name;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_ID
      := p_Dimension_Level_Rec.Dimension_Level_ID;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Short_Name := l_short_name;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Name       := l_name;
  END IF;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Org_Dim_Values:NO_DATA_FOUND'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Org_Dim_Values:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Org_Dim_Values:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Org_Dim_Values:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Get_Org_Dim_Values;
--
--
PROCEDURE Get_Org_Dim_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_Responsibility_ID   IN  NUMBER
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_view_name   VARCHAR2(80);
l_short_name  VARCHAR2(30);
l_name        bis_levels_tl.name%TYPE;
l_cursor      INTEGER;
l_ind         NUMBER := 0;
l_id          VARCHAR2(250);
l_value       VARCHAR2(250);
l_select_stmt VARCHAR2(2000);
l_sql_result  INTEGER := 0;
--
l_id1         DBMS_SQL.VARCHAR2_TABLE;
l_value1      DBMS_SQL.VARCHAR2_TABLE;
l_size        NUMBER := 100000;
l_retrieved   NUMBER;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT
    DIMENSION_LEVEL_SHORT_NAME
  , DIMENSION_LEVEL_NAME
  , LEVEL_VALUES_VIEW_NAME
  INTO
    l_short_name
  , l_name
  , l_view_name
  FROM BISBV_DIMENSION_LEVELS
  WHERE DIMENSION_LEVEL_ID = p_Dimension_Level_Rec.Dimension_Level_ID;
  --
  IF(l_short_name <> 'TOTAL_ORGANIZATIONS') THEN
      IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
        DBMS_SQL.CLOSE_CURSOR(l_cursor);
      END IF;
      l_cursor := DBMS_SQL.OPEN_CURSOR;
      --
      IF(p_Responsibility_ID IS NOT NULL) THEN
        l_select_stmt := 'SELECT '
                         || '  ID '
                         || ', VALUE '
                         || ' FROM '
                         || l_view_name
                         || ' WHERE '
                         || ' RESPONSIBILITY_ID = :p_Responsibility_ID '
                         || ' ORDER BY VALUE';
      ELSE
        l_select_stmt := 'SELECT DISTINCT'
                         || '  ID '
                         || ', VALUE '
                         || ' FROM '
                         || l_view_name
                         || ' ORDER BY VALUE';
      END IF;

      DBMS_SQL.PARSE( c             => l_cursor
                    , statement     => l_select_stmt
                    , language_flag => DBMS_SQL.NATIVE
                    );
      DBMS_SQL.DEFINE_ARRAY(l_cursor, 1, l_id1, l_size, 1);
      DBMS_SQL.DEFINE_ARRAY(l_cursor, 2, l_value1, l_size, 1);
      IF(p_Responsibility_ID IS NOT NULL) THEN
        DBMS_SQL.BIND_VARIABLE(l_cursor, ':p_Responsibility_ID', p_Responsibility_ID);
      END IF;

      l_sql_result := DBMS_SQL.EXECUTE(l_cursor);
      --
      LOOP
        l_retrieved := DBMS_SQL.FETCH_ROWS(l_cursor);
        EXIT WHEN l_retrieved = 0;
        --
        DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_id1);
        DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_value1);
        --
        FOR l_ind1 IN 1..l_id1.COUNT LOOP
          l_ind := l_ind + 1;
          x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_ID
            := l_id1(l_ind1);
          x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_Name
            := l_value1(l_ind1);
          x_Dim_Level_Value_Tbl(l_ind).Dimension_level_ID
            := p_Dimension_Level_Rec.Dimension_Level_ID;
          x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Short_Name
            := l_short_name;
          x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Name
            := l_name;
        END LOOP;
        --
        EXIT WHEN l_retrieved < l_size;
      END LOOP;
      --
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
  ELSE
    l_ind := l_ind + 1;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_ID   := '-1';
    x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_Name := l_name;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_ID
      := p_Dimension_Level_Rec.Dimension_Level_ID;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Short_Name := l_short_name;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Name       := l_name;
  END IF;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Org_Dim_Values:NO_DATA_FOUND'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Org_Dim_Values:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Org_Dim_Values:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Org_Dim_Values:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Get_Org_Dim_Values;
--
--
PROCEDURE Get_Org_Dim_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_view_name   VARCHAR2(80);
l_short_name  VARCHAR2(30);
l_name        bis_levels_tl.name%TYPE;
l_cursor      INTEGER;
l_ind         NUMBER := 0;
l_id          VARCHAR2(250);
l_value       VARCHAR2(250);
l_select_stmt VARCHAR2(2000);
l_sql_result  INTEGER := 0;
--
l_id1         DBMS_SQL.VARCHAR2_TABLE;
l_value1      DBMS_SQL.VARCHAR2_TABLE;
l_size        NUMBER := 100000;
l_retrieved   NUMBER;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT
    DIMENSION_LEVEL_SHORT_NAME
  , DIMENSION_LEVEL_NAME
  , LEVEL_VALUES_VIEW_NAME
  INTO
    l_short_name
  , l_name
  , l_view_name
  FROM BISBV_DIMENSION_LEVELS
  WHERE DIMENSION_LEVEL_ID = p_Dimension_Level_Rec.Dimension_Level_ID;
  --
  IF(l_short_name <> 'TOTAL_ORGANIZATIONS') THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    l_cursor := DBMS_SQL.OPEN_CURSOR;
    --
    l_select_stmt := 'SELECT DISTINCT'
                     || '  ID '
                     || ', VALUE '
                     || ' FROM '
                     || l_view_name
                     || ' ORDER BY VALUE';
    --
    DBMS_SQL.PARSE( c             => l_cursor
                  , statement     => l_select_stmt
                  , language_flag => DBMS_SQL.NATIVE
                  );
    DBMS_SQL.DEFINE_ARRAY(l_cursor, 1, l_id1, l_size, 1);
    DBMS_SQL.DEFINE_ARRAY(l_cursor, 2, l_value1, l_size, 1);
    l_sql_result := DBMS_SQL.EXECUTE(l_cursor);
    --
    LOOP
      l_retrieved := DBMS_SQL.FETCH_ROWS(l_cursor);
      EXIT WHEN l_retrieved = 0;
      --
      DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_id1);
      DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_value1);
      --
      FOR l_ind1 IN 1..l_id1.COUNT LOOP
        l_ind := l_ind + 1;
        x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_ID
          := l_id1(l_ind1);
        x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_Name
          := l_value1(l_ind1);
        x_Dim_Level_Value_Tbl(l_ind).Dimension_level_ID
          := p_Dimension_Level_Rec.Dimension_Level_ID;
        x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Short_Name
          := l_short_name;
        x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Name
          := l_name;
      END LOOP;
      --
      EXIT WHEN l_retrieved < l_size;
    END LOOP;
    --
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
  ELSE
    l_ind := l_ind + 1;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_ID   := '-1';
    x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_Name := l_name;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_ID
      := p_Dimension_Level_Rec.Dimension_Level_ID;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Short_Name := l_short_name;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Name       := l_name;
  END IF;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Org_Dim_Values:NO_DATA_FOUND'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Org_Dim_Values:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Org_Dim_Values:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Org_Dim_Values:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Org_Dim_Values;
--
--
PROCEDURE Get_DimensionX_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_view_name   VARCHAR2(80);
l_short_name  VARCHAR2(30);
l_name        bis_levels_tl.name%TYPE;
l_cursor      INTEGER;
l_ind         NUMBER := 0;
l_id          VARCHAR2(250);
l_value       VARCHAR2(250);
l_select_stmt VARCHAR2(2000);
l_sql_result  INTEGER := 0;
--
l_id1         DBMS_SQL.VARCHAR2_TABLE;
l_value1      DBMS_SQL.VARCHAR2_TABLE;
l_size        NUMBER := 100000;
l_retrieved   NUMBER;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT
    DIMENSION_LEVEL_SHORT_NAME
  , DIMENSION_LEVEL_NAME
  , LEVEL_VALUES_VIEW_NAME
  INTO
    l_short_name
  , l_name
  , l_view_name
  FROM BISBV_DIMENSION_LEVELS
  WHERE DIMENSION_LEVEL_ID = p_Dimension_Level_Rec.Dimension_Level_ID;
  --
  IF(SUBSTR(l_short_name, 1, 5) <> 'TOTAL') THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    l_cursor := DBMS_SQL.OPEN_CURSOR;
    --
    l_select_stmt := 'SELECT DISTINCT '
                     || '  ID '
                     || ', VALUE '
                     || ' FROM '
                     || l_view_name
                     || ' ORDER BY VALUE';
    --
--    htp.header(4, 'l_select_stmt = ' || l_select_stmt);
    DBMS_SQL.PARSE( c             => l_cursor
                  , statement     => l_select_stmt
                  , language_flag => DBMS_SQL.NATIVE
                  );
    DBMS_SQL.DEFINE_ARRAY(l_cursor, 1, l_id1, l_size, 1);
    DBMS_SQL.DEFINE_ARRAY(l_cursor, 2, l_value1, l_size, 1);
    l_sql_result := DBMS_SQL.EXECUTE(l_cursor);
    --
    LOOP
      l_retrieved := DBMS_SQL.FETCH_ROWS(l_cursor);
      EXIT WHEN l_retrieved = 0;
      --
      DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_id1);
      DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_value1);
      --
      FOR l_ind1 IN 1..l_id1.COUNT LOOP
        l_ind := l_ind + 1;
        x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_ID
          := l_id1(l_ind1);
        x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_Name
          := l_value1(l_ind1);
        x_Dim_Level_Value_Tbl(l_ind).Dimension_level_ID
          := p_Dimension_Level_Rec.Dimension_Level_ID;
        x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Short_Name
          := l_short_name;
        x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Name
          := l_name;
      END LOOP;
      --
      EXIT WHEN l_retrieved < l_size;
    END LOOP;
    --
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
  ELSE
    l_ind := l_ind + 1;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_ID   := '-1';
    x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_Name := l_name;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_ID
      := p_Dimension_Level_Rec.Dimension_Level_ID;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Short_Name := l_short_name;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Name       := l_name;
  END IF;

--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_DimensionX_Values:NO_DATA_FOUND'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_DimensionX_Values:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_DimensionX_Values:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_DimensionX_Values:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Get_DimensionX_Values;
--
--
PROCEDURE Get_Time_Dim_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_view_name   VARCHAR2(80);
l_short_name  VARCHAR2(30);
l_name        bis_levels_tl.name%TYPE;
l_cursor      INTEGER := NULL;
l_ind         NUMBER := 0;
l_period_set  VARCHAR2(250);
l_id          VARCHAR2(250) := NULL;
l_value       VARCHAR2(250) := NULL;
l_start_date  DATE;
l_select_stmt VARCHAR2(2000) := NULL;
l_sql_result  INTEGER := 0;
--
l_id1         DBMS_SQL.VARCHAR2_TABLE;
l_value1      DBMS_SQL.VARCHAR2_TABLE;
l_start_date1 DBMS_SQL.DATE_TABLE;
l_size        NUMBER := 100000;
l_retrieved   NUMBER;
l_Org_Dept    BOOLEAN;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT
    DIMENSION_LEVEL_SHORT_NAME
  , DIMENSION_LEVEL_NAME
  , LEVEL_VALUES_VIEW_NAME
  INTO
    l_short_name
  , l_name
  , l_view_name
  FROM BISBV_DIMENSION_LEVELS
  WHERE DIMENSION_LEVEL_ID = p_Dimension_Level_Rec.Dimension_Level_ID;
  --
  IF(l_short_name <> 'TOTAL_TIME') THEN
    IF (BIS_UTILITIES_PUB.is_time_dependent_on_org(p_time_lvl_short_name => l_short_name)
    = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN --2684911
        l_Org_Dept := TRUE;
        l_select_stmt := 'SELECT '
                       || '  ID '
                       || ', VALUE '
                       || ', START_DATE '
                       || ' FROM '
                       || l_view_name
                       || ' WHERE '
                       || ' ORGANIZATION_ID = :org_id'
                       || ' AND NVL(ORGANIZATION_TYPE, ''%'') LIKE :org_type '
                       || ' ORDER BY START_DATE';
    ELSE
      l_Org_Dept := FALSE;
      l_select_stmt := 'SELECT '
                       || '  ID '
                       || ', VALUE '
                       || ', START_DATE '
                       || ' FROM '
                       || l_view_name
                       || ' ORDER BY START_DATE';
    END IF;
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    l_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE( c             => l_cursor
                  , statement     => l_select_stmt
                  , language_flag => DBMS_SQL.NATIVE
                  );
    DBMS_SQL.DEFINE_ARRAY(l_cursor, 1, l_id1, l_size, 1);
    DBMS_SQL.DEFINE_ARRAY(l_cursor, 2, l_value1, l_size, 1);
    DBMS_SQL.DEFINE_ARRAY(l_cursor, 3, l_start_date1, l_size, 1);
    IF(l_Org_Dept) THEN
      DBMS_SQL.BIND_VARIABLE(l_cursor, ':org_id', p_Dim_Level_Value_Rec.Dimension_Level_Value_ID);
      DBMS_SQL.BIND_VARIABLE(l_cursor, ':org_type', p_Dim_Level_Value_Rec.Dimension_Level_Short_Name);
    END IF;
    l_sql_result := DBMS_SQL.EXECUTE(l_cursor);
    --
    LOOP
      l_retrieved := DBMS_SQL.FETCH_ROWS(l_cursor);
      EXIT WHEN l_retrieved = 0;
      --
      DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_id1);
      DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_value1);
      DBMS_SQL.COLUMN_VALUE(l_cursor, 3, l_start_date1);
      --
      FOR l_ind1 IN 1..l_id1.COUNT LOOP
        l_ind := l_ind + 1;
        x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_ID
          := l_id1(l_ind1);
        x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_Name
          := l_value1(l_ind1);
        x_Dim_Level_Value_Tbl(l_ind).Dimension_level_ID
          := p_Dimension_Level_Rec.Dimension_Level_ID;
        x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Short_Name
          := l_short_name;
        x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Name
          := l_name;
      END LOOP;
      --
      EXIT WHEN l_retrieved < l_size;
    END LOOP;
    --
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
  ELSE
    l_ind := l_ind + 1;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_ID   := '-1';
    x_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_Name := l_name;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_ID
      := p_Dimension_Level_Rec.Dimension_Level_ID;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Short_Name := l_short_name;
    x_Dim_Level_Value_Tbl(l_ind).Dimension_level_Name       := l_name;
  END IF;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Time_Dim_Values:NO_DATA_FOUND'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Time_Dim_Values:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Time_Dim_Values:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Time_Dim_Values:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Get_Time_Dim_Values;
--
--
PROCEDURE Remove_Dup_Dim_Level_Values
( p_api_version         IN  NUMBER
, p_Dim_Level_Value_Tbl IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_unique              BOOLEAN;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  FOR l_ind IN 1..p_Dim_Level_Value_Tbl.COUNT LOOP
    l_unique := TRUE;
    --
    FOR l_ind1 IN 1..x_Dim_Level_Value_Tbl.COUNT LOOP
      IF( p_Dim_Level_Value_Tbl(l_ind).Dimension_Level_Value_ID
          = x_Dim_Level_Value_Tbl(l_ind1).Dimension_Level_Value_ID
        ) THEN
        l_unique := FALSE;
        EXIT;
      END IF;
    END LOOP;
    --
    IF(l_unique) THEN
      x_Dim_Level_Value_Tbl(x_Dim_Level_Value_Tbl.COUNT + 1)
        := p_Dim_Level_Value_Tbl(l_ind);
    END IF;
  END LOOP;
--
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Remove_Dup_Dim_Level_Values:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Remove_Dup_Dim_Level_Values:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Remove_Dup_Dim_Level_Values:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Remove_Dup_Dim_Level_Values;
--
--
PROCEDURE Get_Start_Date
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_start_period        IN  VARCHAR2
, x_start_date          OUT NOCOPY DATE
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_short_name      VARCHAR2(30);
l_view_name       VARCHAR2(30);
l_period_name     VARCHAR2(15);
l_period_set_name VARCHAR2(15);
l_cursor          INTEGER;
l_select_stmt     VARCHAR2(2000);
l_sql_result      INTEGER := 0;
l_start_date      DATE;
--
BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT
    DIMENSION_LEVEL_SHORT_NAME
  , LEVEL_VALUES_VIEW_NAME
  INTO
    l_short_name
  , l_view_name
  FROM BISBV_DIMENSION_LEVELS
  WHERE DIMENSION_LEVEL_ID = p_Dimension_Level_Rec.Dimension_Level_ID;
  --
  --
  IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
  END IF;
  l_cursor := DBMS_SQL.OPEN_CURSOR;
  --
  l_select_stmt := 'SELECT DISTINCT '
                   || '  START_DATE '
                   || ' FROM '
                   || l_view_name
                   || ' WHERE '
                   || ' ID = :p_start_period ';
  --
  DBMS_SQL.PARSE( c             => l_cursor
                , statement     => l_select_stmt
                , language_flag => DBMS_SQL.NATIVE
                );
  DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_start_date);
  DBMS_SQL.BIND_VARIABLE(l_cursor, ':p_start_period', p_start_period);
  l_sql_result := DBMS_SQL.EXECUTE_AND_FETCH(l_cursor, TRUE);
  --
  DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_start_date);
  --
  DBMS_SQL.CLOSE_CURSOR(l_cursor);
  --
  x_start_date := l_start_date;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Start_Date:NO_DATA_FOUND'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Start_Date:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Start_Date:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_Start_Date:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_Start_Date;
--
--
PROCEDURE Get_End_Date
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_end_period          IN  VARCHAR2
, x_end_date            OUT NOCOPY DATE
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_short_name      VARCHAR2(30);
l_view_name       VARCHAR2(30);
l_period_name     VARCHAR2(15);
l_period_set_name VARCHAR2(15);
l_cursor          INTEGER;
l_select_stmt     VARCHAR2(2000);
l_sql_result      INTEGER := 0;
l_end_date        DATE;
--
BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  --
  SELECT
    DIMENSION_LEVEL_SHORT_NAME
  , LEVEL_VALUES_VIEW_NAME
  INTO
    l_short_name
  , l_view_name
  FROM BISBV_DIMENSION_LEVELS
  WHERE DIMENSION_LEVEL_ID = p_Dimension_Level_Rec.Dimension_Level_ID;
  --
  --
  IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
  END IF;
  l_cursor := DBMS_SQL.OPEN_CURSOR;
  --
  l_select_stmt := 'SELECT DISTINCT '
                   || '  END_DATE '
                   || ' FROM '
                   || l_view_name
                   || ' WHERE '
                   || ' ID = :p_end_period ';
  --
  DBMS_SQL.PARSE( c             => l_cursor
                , statement     => l_select_stmt
                , language_flag => DBMS_SQL.NATIVE
                );
  DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_end_date);
  DBMS_SQL.BIND_VARIABLE(l_cursor, ':p_end_period', p_end_period);
  l_sql_result := DBMS_SQL.EXECUTE_AND_FETCH(l_cursor, TRUE);
  --
  DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_end_date);
  --
  DBMS_SQL.CLOSE_CURSOR(l_cursor);
  --
  x_end_date := l_end_date;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_End_Date:NO_DATA_FOUND'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_End_Date:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_End_Date:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
      DBMS_SQL.CLOSE_CURSOR(l_cursor);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Get_End_Date:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Get_End_Date;
--
--
PROCEDURE Org_ID_to_Value
( p_api_version         IN  NUMBER
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_view_name   VARCHAR2(80);
l_short_name  VARCHAR2(30);
l_name        bis_levels_tl.name%TYPE;
l_id          VARCHAR2(250);
l_value       VARCHAR2(250);
l_select_stmt VARCHAR2(2000);
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_Dim_Level_Value_Rec := p_Dim_Level_Value_Rec;
  --
  SELECT
    DIMENSION_LEVEL_SHORT_NAME
  , DIMENSION_LEVEL_NAME
  , LEVEL_VALUES_VIEW_NAME
  INTO
    l_short_name
  , l_name
  , l_view_name
  FROM BISBV_DIMENSION_LEVELS
  WHERE DIMENSION_LEVEL_ID = p_Dim_Level_Value_Rec.Dimension_Level_ID;
  --
  IF(l_short_name <> 'TOTAL_ORGANIZATIONS') THEN
    --
    l_select_stmt := 'SELECT DISTINCT '
                     || '  ID '
                     || ', VALUE '
                     || ' FROM '
                     || l_view_name
                     || ' WHERE ID = :1';
    --
    EXECUTE IMMEDIATE l_select_stmt INTO l_id, l_value USING p_Dim_Level_Value_Rec.Dimension_Level_Value_ID;
    IF (l_id IS NULL) THEN
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name  => 'BIS_INVALID_ORGANIZATION_ID'
      , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Org_ID_to_Value'
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_Dim_Level_Value_Rec.Dimension_Level_Value_Name := l_value;
    x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;
    --
  ELSIF(p_Dim_Level_Value_Rec.Dimension_Level_Value_ID <> '-1') THEN
    -- populate error table
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_INVALID_ORGANIZATION_ID'
    , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Org_ID_to_Value'
    );
    RAISE FND_API.G_EXC_ERROR;
    --
  ELSE
    -- populate record with name
    x_Dim_Level_Value_Rec.Dimension_Level_Value_Name := l_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;
  END IF;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Org_ID_to_Value:NO_DATA_FOUND'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Org_ID_to_Value:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Org_ID_to_Value:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Org_ID_to_Value:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Org_ID_to_Value;
--
--
PROCEDURE Org_Value_to_ID
( p_api_version         IN  NUMBER
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_view_name   VARCHAR2(80);
l_short_name  VARCHAR2(30);
l_name        bis_levels_tl.name%TYPE;
l_id          VARCHAR2(80);
l_value       VARCHAR2(250);
l_select_stmt VARCHAR2(2000);
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_Dim_Level_Value_Rec := p_Dim_Level_Value_Rec;
  --
  SELECT
    DIMENSION_LEVEL_SHORT_NAME
  , DIMENSION_LEVEL_NAME
  , LEVEL_VALUES_VIEW_NAME
  INTO
    l_short_name
  , l_name
  , l_view_name
  FROM BISBV_DIMENSION_LEVELS
  WHERE DIMENSION_LEVEL_ID = p_Dim_Level_Value_Rec.Dimension_Level_ID;
  --
  IF(l_short_name <> 'TOTAL_ORGANIZATIONS') THEN
    --
    l_select_stmt := 'SELECT DISTINCT '
                     || '  ID '
                     || ', VALUE '
                     || ' FROM '
                     || l_view_name
                     || ' WHERE VALUE = :1 ';
    --
    EXECUTE IMMEDIATE l_select_stmt INTO l_id, l_value USING p_Dim_Level_Value_Rec.Dimension_Level_Value_Name;

    IF (l_id IS NULL) THEN
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name  => 'BIS_INVALID_ORGANIZATION_VALUE'
      , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Org_Value_to_ID'
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    x_Dim_Level_Value_Rec.Dimension_Level_Value_ID   := l_id;
    x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;
    --
  ELSIF(p_Dim_Level_Value_Rec.Dimension_Level_Value_Name <> l_name) THEN
    -- populate error table
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_INVALID_ORGANIZATION_VALUE'
    , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Org_Value_to_ID'
    );
    RAISE FND_API.G_EXC_ERROR;
    --
  ELSE
    -- populate record with id
    x_Dim_Level_Value_Rec.Dimension_Level_Value_ID   := '-1';
    x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;
  END IF;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Org_Value_to_ID:NO_DATA_FOUND'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Org_Value_to_ID:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Org_Value_to_ID:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Org_Value_to_ID:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Org_Value_to_ID;
--
--
PROCEDURE Time_ID_to_Value
( p_api_version         IN  NUMBER
, p_Org_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_view_name   VARCHAR2(80);
l_short_name  VARCHAR2(30);
l_name        bis_levels_tl.name%TYPE;
l_period_set  VARCHAR2(250);
l_value       VARCHAR2(250);
l_select_stmt VARCHAR2(2000);
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_Dim_Level_Value_Rec := p_Dim_Level_Value_Rec;
  --
  SELECT
    DIMENSION_LEVEL_SHORT_NAME
  , DIMENSION_LEVEL_NAME
  , LEVEL_VALUES_VIEW_NAME
  INTO
    l_short_name
  , l_name
  , l_view_name
  FROM BISBV_DIMENSION_LEVELS
  WHERE DIMENSION_LEVEL_ID = p_Dim_Level_Value_Rec.Dimension_Level_ID;
  --
  IF(l_short_name <> 'TOTAL_TIME') THEN
    --
    IF (BIS_UTILITIES_PUB.is_time_dependent_on_org(p_time_lvl_short_name => l_short_name)
    = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN --2684911
        l_select_stmt := 'SELECT '
                       || '  PERIOD_SET_NAME '
                       || ', PERIOD_NAME '
                       || ' FROM '
                       || l_view_name
                       || ' WHERE '
                       || ' ORGANIZATION_ID = :1 '
                       || ' AND NVL(ORGANIZATION_TYPE, ''%'') LIKE :2 '
                       || ' AND '
                       || ' PERIOD_SET_NAME || ''+'' || PERIOD_NAME = :3 ';
        EXECUTE IMMEDIATE l_select_stmt INTO l_period_set, l_value
          USING p_Org_Level_Value_Rec.Dimension_Level_Value_ID
              , p_Org_Level_Value_Rec.Dimension_Level_Short_Name
     	      , p_Dim_Level_Value_Rec.Dimension_Level_Value_ID;
    ELSE
      l_select_stmt := 'SELECT '
                       || '  PERIOD_SET_NAME '
                       || ', PERIOD_NAME '
                       || ' FROM '
                       || l_view_name
                       || ' WHERE '
                       || ' PERIOD_SET_NAME || ''+'' || PERIOD_NAME = :1';
      EXECUTE IMMEDIATE l_select_stmt INTO l_period_set, l_value
        USING p_Dim_Level_Value_Rec.Dimension_Level_Value_ID;
    END IF;

    IF l_period_set IS NULL THEN
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name  => 'BIS_INVALID_TIME_ID'
      , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Time_ID_to_Value'
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    x_Dim_Level_Value_Rec.Dimension_Level_Value_Name := l_value;
    x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;
    --
  ELSIF(p_Dim_Level_Value_Rec.Dimension_Level_Value_ID <> '-1') THEN
    -- populate error table
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_INVALID_TIME_ID'
    , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Time_ID_to_Value'
    );
    RAISE FND_API.G_EXC_ERROR;
    --
  ELSE
    -- populate record with name
    x_Dim_Level_Value_Rec.Dimension_Level_Value_Name := l_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;
  END IF;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Time_ID_to_Value:NO_DATA_FOUND'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Time_ID_to_Value:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Time_ID_to_Value:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Time_ID_to_Value:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Time_ID_to_Value;
--
--
PROCEDURE Time_Value_to_ID
( p_api_version         IN  NUMBER
, p_Org_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_view_name   VARCHAR2(80);
l_short_name  VARCHAR2(30);
l_name        bis_levels_tl.name%TYPE;
l_id          VARCHAR2(80);
l_value       VARCHAR2(250);
l_select_stmt VARCHAR2(2000);
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_Dim_Level_Value_Rec := p_Dim_Level_Value_Rec;
  --
  SELECT
    DIMENSION_LEVEL_SHORT_NAME
  , DIMENSION_LEVEL_NAME
  , LEVEL_VALUES_VIEW_NAME
  INTO
    l_short_name
  , l_name
  , l_view_name
  FROM BISBV_DIMENSION_LEVELS
  WHERE DIMENSION_LEVEL_ID = p_Dim_Level_Value_Rec.Dimension_Level_ID;
  --
  IF(l_short_name <> 'TOTAL_TIME') THEN
    --
    IF (BIS_UTILITIES_PUB.is_time_dependent_on_org(p_time_lvl_short_name => l_short_name)
    = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN --2684911
        l_select_stmt := 'SELECT '
                       || '  ID '
                       || ', VALUE '
                       || ' FROM '
                       || l_view_name
                       || ' WHERE '
                       || ' ORGANIZATION_ID = :1 '
                       || ' AND NVL(ORGANIZATION_TYPE, ''%'') LIKE :2 '
                       || ' AND '
                       || ' VALUE = :3 ';
        EXECUTE IMMEDIATE l_select_stmt INTO l_id, l_value
          USING p_Org_Level_Value_Rec.Dimension_Level_Value_ID
              , p_Org_Level_Value_Rec.Dimension_Level_Short_Name
  	      , p_Dim_Level_Value_Rec.Dimension_Level_Value_Name;
    ELSE
      l_select_stmt := 'SELECT '
                       || '  ID '
                       || ', VALUE '
                       || ' FROM '
                       || l_view_name
                       || ' WHERE '
                       || ' VALUE = :1 '
                       || ' AND rownum < 2 '; -- take the first row
      EXECUTE IMMEDIATE l_select_stmt INTO l_id, l_value
        USING p_Dim_Level_Value_Rec.Dimension_Level_Value_Name;
    END IF;
    --
    --
    IF(l_id IS NULL) THEN
      -- populate error table
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name  => 'BIS_INVALID_TIME_VALUE'
      , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Time_Value_to_ID'
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    --
    x_Dim_Level_Value_Rec.Dimension_Level_Value_Name := l_value;
    x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;
    --
  ELSIF(p_Dim_Level_Value_Rec.Dimension_Level_Value_Name <> l_name) THEN
    -- populate error table
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_INVALID_TIME_VALUE'
    , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.Time_Value_to_ID'
    );
    RAISE FND_API.G_EXC_ERROR;
    --
  ELSE
    -- populate record with name
    x_Dim_Level_Value_Rec.Dimension_Level_Value_ID   := '-1';
    x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;
  END IF;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Time_Value_to_ID:NO_DATA_FOUND'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Time_Value_to_ID:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Time_Value_to_ID:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.Time_Value_to_ID:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Time_Value_to_ID;
--
--
PROCEDURE DimensionX_ID_to_Value
( p_api_version         IN  NUMBER
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, p_set_of_books_id     IN  VARCHAR2 := NULL
, x_Dim_Level_Value_Rec IN OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_view_name   VARCHAR2(80);
l_short_name  VARCHAR2(30);
l_name        bis_levels_tl.name%TYPE;
l_cursor      INTEGER;
l_id          VARCHAR2(250);
l_value       VARCHAR2(2000);
l_select_stmt VARCHAR2(2000);
l_sql_result  INTEGER := 0;
l_description bis_levels_tl.description%TYPE;
l_id_name VARCHAR(2000);
l_value_name VARCHAR(2000);
l_msg_count NUMBER;
l_msg_data VARCHAR(32000);
l_start_date DATE;
l_end_date   DATE;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_Dim_Level_Value_Rec := p_Dim_Level_Value_Rec;
  --

  BIS_PMF_GET_DIMLEVELS_PVT.Get_DimLevel_Values_Data
  (
    p_bis_dimlevel_id => p_Dim_Level_Value_Rec.Dimension_Level_ID
   ,x_dimlevel_short_name => l_short_name
   ,x_select_String =>  l_select_stmt
   ,x_table_name => l_view_name
   ,x_value_name => l_value_name
   ,x_id_name =>  l_id_name
   ,x_level_name => l_name
   ,x_description => l_description
   ,x_return_status =>  x_return_status
   ,x_msg_count => l_msg_count
   ,x_msg_data  =>  l_msg_data
  );
  if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
     BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_INVALID_DIM_LEVEL_ID'
    , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.DimensionX_ID_to_Value'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
      RAISE FND_API.G_EXC_ERROR;
  end if;

  --------------------

  IF(SUBSTR(l_short_name, 1, 5) <> 'TOTAL') THEN

    IF ( UPPER ( l_view_name ) = 'DUAL') then -- 2408906

      x_Dim_Level_Value_Rec.Dimension_Level_Value_Name := BIS_UTILITIES_PVT.GET_FND_MESSAGE( 'BIS_ALL_VALUE_ROLLING' ) ; -- 'All';
      x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
      x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;

    ELSE
      l_select_stmt := l_select_stmt || ' WHERE ' ||l_id_name ||' = :1';
  --2699983
      l_select_stmt := l_select_stmt || ' AND ROWNUM < 2 ';

      IF ( (p_Dim_Level_Value_Rec.Dimension_Level_Short_Name IN  (C_GL_COMPANY, C_GL_SECONDARY_MEASURE)) AND
           (p_set_of_books_id IS NOT NULL)
         ) THEN
        l_select_stmt := l_select_stmt || ' AND SET_OF_BOOKS_ID = :2';
        EXECUTE IMMEDIATE l_select_stmt INTO l_id, l_value USING p_Dim_Level_Value_Rec.Dimension_Level_Value_Id, p_set_of_books_id;
      ELSIF(BIS_UTILITIES_PVT.is_valid_time_dimension_level(p_Dim_Level_Value_Rec.Dimension_Level_ID, x_return_status) = TRUE) THEN
	    	EXECUTE IMMEDIATE l_select_stmt INTO l_id, l_value, l_start_date, l_end_date USING p_Dim_Level_Value_Rec.Dimension_Level_Value_Id;
      ELSE
        EXECUTE IMMEDIATE l_select_stmt INTO l_id, l_value USING p_Dim_Level_Value_Rec.Dimension_Level_Value_Id;
      END IF;

    IF (l_id IS NULL) THEN
        BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name  => 'BIS_INVALID_DIM_LEVEL_VALUE_ID'
        , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.DimensionX_ID_to_Value'
        , p_token1          => 'DIM_LEVEL_NAME'
        , p_value1          => l_name
        , p_error_table       => x_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      x_Dim_Level_Value_Rec.Dimension_Level_Value_Name := SUBSTRB(l_value,1,240);
      x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
      x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;
      --

    END IF;

  ELSIF(p_Dim_Level_Value_Rec.Dimension_Level_Value_ID <> '-1') THEN
    -- populate error table
    --added last two params
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_INVALID_DIM_LEVEL_VALUE_ID'
    , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.DimensionX_ID_to_Value'
    , p_token1          => 'DIM_LEVEL_NAME'
    , p_value1          => l_name
     , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
    --
  ELSE
    -- populate record with name
    x_Dim_Level_Value_Rec.Dimension_Level_Value_Name := l_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;
  END IF;
--
--commented out NOCOPY RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value:NO_DATA_FOUND'); htp.para;
    END IF;
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value:G_EXC_ERROR'); htp.para;
    END IF;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value:OTHERS'); htp.para;
    END IF;
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END DimensionX_ID_to_Value;
--
--
PROCEDURE DimensionX_Value_to_ID
( p_api_version         IN  NUMBER
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_view_name   VARCHAR2(80);
l_short_name  VARCHAR2(30);
l_name        bis_levels_tl.name%TYPE;
l_cursor      INTEGER;
l_id          VARCHAR2(80);
l_value       VARCHAR2(250);
l_select_stmt VARCHAR2(2000);
l_sql_result  INTEGER := 0;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_Dim_Level_Value_Rec := p_Dim_Level_Value_Rec;
  --
  SELECT
    DIMENSION_LEVEL_SHORT_NAME
  , DIMENSION_LEVEL_NAME
  , LEVEL_VALUES_VIEW_NAME
  INTO
    l_short_name
  , l_name
  , l_view_name
  FROM BISBV_DIMENSION_LEVELS
  WHERE DIMENSION_LEVEL_ID = p_Dim_Level_Value_Rec.Dimension_Level_ID;
  --
  IF(SUBSTR(l_short_name, 1, 5) <> 'TOTAL') THEN
     l_select_stmt := 'SELECT DISTINCT ID, VALUE FROM '|| l_view_name
                     || ' WHERE Value = :1';

     EXECUTE IMMEDIATE l_select_stmt INTO l_id, l_value USING p_Dim_Level_Value_Rec.Dimension_Level_Value_Name;
    IF (l_id IS NULL) THEN
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name  => 'BIS_INVALID_DIM_LEVEL_VALUE_NAME'
      , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.DimensionX_Value_to_ID'
      , p_token1          => 'DIM_LEVEL_NAME'
      , p_value1          => l_name
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_Dim_Level_Value_Rec.Dimension_Level_Value_ID   := l_id;
    x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;
    --
  ELSIF(p_Dim_Level_Value_Rec.Dimension_Level_Value_Name <> l_name) THEN
    -- populate error table
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_INVALID_DIM_LEVEL_VALUE_NAME'
    , p_error_proc_name => 'BIS_TARGET_VALIDATE_PVT.DimensionX_Value_to_ID'
    , p_token1          => 'DIM_LEVEL_NAME'
    , p_value1          => l_name
    );
    RAISE FND_API.G_EXC_ERROR;
    --
  ELSE
    -- populate record with name
    x_Dim_Level_Value_Rec.Dimension_Level_Value_ID   := '-1';
    x_Dim_Level_Value_Rec.Dimension_Level_Short_Name := l_short_name;
    x_Dim_Level_Value_Rec.Dimension_Level_Name       := l_name;
  END IF;
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_to_ID:NO_DATA_FOUND'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_to_ID:G_EXC_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_to_ID:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_to_ID:OTHERS'); htp.para;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END DimensionX_Value_to_ID;

--
Function Is_Current_Time_Period
( p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, p_Org_Level_ID        IN  VARCHAR2
, p_Org_Level_Short_name IN   VARCHAR2
, x_current_time_id     OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS

  l_sql VARCHAR2(32000);
  l_time_id  VARCHAR2(32000) := NULL;
  l_dimension_level_rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

  l_view_name   VARCHAR2(80);
  l_short_name  VARCHAR2(30);
  l_name        bis_levels_tl.name%TYPE;
  l_cursor      INTEGER;
  l_id          VARCHAR2(250);
  l_value       VARCHAR2(250);
  l_select_stmt VARCHAR2(2000);
  l_sql_result  INTEGER := 0;
  l_description bis_levels_tl.description%TYPE;
  l_return_status VARCHAR2(240);
  l_id_name     VARCHAR(2000);
  l_value_name  VARCHAR(2000);
  l_msg_count   NUMBER;
  l_msg_data    VARCHAR(32000);

  l_level_id    NUMBER        ; -- :=11, 99 on bis115dv -- 1740789 -- sashaik
  l_level_short_name  VARCHAR2(60)  ;
  l_source      VARCHAR2(30);

  l_star	VARCHAR2(2) := '*';
  TYPE tcursor 	IS REF CURSOR;
  l1_cursor	tcursor;

  l_Org_Level_Id	VARCHAR2(50) := null; -- 'XXX' ;
  l_Org_Level_Short_name VARCHAR2(50) := null; -- 'XXX' ;


BEGIN

  BIS_UTILITIES_PUB.put_line(p_text =>'..... in  Is_Current_Time_Period');


  BIS_PMF_GET_DIMLEVELS_PVT.Get_DimLevel_Values_Data
  (
    p_bis_dimlevel_id  	=> p_Dim_Level_Value_Rec.Dimension_Level_ID
   ,x_dimlevel_short_name => l_short_name
   ,x_select_String 	=> l_select_stmt
   ,x_table_name 	=> l_view_name
   ,x_value_name 	=> l_value_name
   ,x_id_name 		=> l_id_name
   ,x_level_name 	=> l_name
   ,x_description 	=> l_description
   ,x_return_status 	=> l_return_status
   ,x_msg_count 	=> l_msg_count
   ,x_msg_data  	=> l_msg_data
  );


  l_level_id   := p_Dim_Level_Value_Rec.Dimension_Level_ID;

  l_source := bis_utilities_pvt.GET_SOURCE_FROM_DIM_LEVEL
                (
                   p_DimLevelId         => l_level_id
                 , p_DimLevelShortName  => l_level_short_name  -- l_level_name
                );

  BIS_UTILITIES_PUB.put_line(p_text =>' Source is '|| l_source );


  if ( l_source = 'OLTP' ) then
      bis_utilities_pvt.Get_Org_Info_Based_On_Source
      ( p_source		=> l_source,
        p_org_level_id	 	=> p_org_level_id,
        p_org_level_short_name 	=> p_org_level_short_name,
        x_org_level_id	 	=> l_org_level_id,
        x_org_level_short_name 	=> l_org_level_short_name
      );


     if ( l_org_level_id is not null ) then
       BIS_UTILITIES_PUB.put_line(p_text => ' org level id = ' || l_org_level_id ) ;
     else
       BIS_UTILITIES_PUB.put_line(p_text => ' org level id = ' || l_org_level_id ) ;
     end if;

  elsif ( l_source = 'EDW') then
        l_org_level_id	 	:= p_org_level_id;
        l_org_level_short_name 	:= p_org_level_short_name;

  elsif ( l_source <> 'EDW') then
       BIS_UTILITIES_PUB.put_line(p_text => ' ERROR: Is_Current_Time_Period : source can be only either OLTP or EDW ' );
  end if;


  bis_utilities_pvt.Get_Time_Level_Value_ID_Minus
  ( p_source		=> l_source,
    p_view_name		=> l_view_name,
    p_id_name     	=> l_id_name,
    p_org_level_id	=> l_org_level_id,
    p_org_level_short_name => l_org_level_short_name,
    p_sysdate_less	=> 0,
    x_time_id		=> l_time_id
  );

  x_current_time_id := l_time_id;

  if  ( bis_utilities_pub.value_not_missing ( l_time_id ) = FND_API.G_TRUE )
    and ( bis_utilities_pub.value_not_null ( l_time_id ) = FND_API.G_TRUE )
  then
    BIS_UTILITIES_PUB.put_line(p_text => ' time id is ' || l_time_id );
  else
    BIS_UTILITIES_PUB.put_line(p_text => ' time id is NULL ' );
  end if;

  IF l_time_id = p_Dim_Level_Value_Rec.dimension_level_value_id THEN
    BIS_UTILITIES_PUB.put_line(p_text =>' is_current_time_period: This time level value id is in current period ');
    RETURN true;
  ELSE
    BIS_UTILITIES_PUB.put_line(p_text =>' is_current_time_period: This time level value id is not in current period ');
    RETURN false;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'exception at Is_Current_Time_Period 0500: '||sqlerrm);

END Is_Current_Time_Period;


--
--

Function Is_Previous_Time_Period
( p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, p_Org_Level_ID        IN  VARCHAR2
, p_Org_Level_Short_name IN   VARCHAR2
, x_Previous_time_id    OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS

  l_sql              VARCHAR2(32000);
  l_time_id          VARCHAR2(32000) := NULL;
  l_dimension_level_rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_error_Tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;
  --l_period_set_name  VARCHAR2(32000);

  l_view_name   VARCHAR2(80);
  l_short_name  VARCHAR2(30);
  l_name        bis_levels_tl.name%TYPE;
  l_cursor      INTEGER;
  l_id          VARCHAR2(250);
  l_value       VARCHAR2(250);
  l_select_stmt VARCHAR2(2000);
  l_sql_result  INTEGER := 0;
  l_description bis_levels_tl.description%TYPE;
  l_return_status VARCHAR2(240);
  l_id_name     VARCHAR(2000);
  l_value_name  VARCHAR(2000);
  l_msg_count   NUMBER;
  l_msg_data    VARCHAR(32000);

  l_start_date  date;
  l_end_date    date;

  l_level_id    NUMBER        ; -- :=11, 99 on bis115dv -- 1740789 -- sashaik
  l_level_short_name  VARCHAR2(60)  ;
  l_source      VARCHAR2(30);

  l_star	VARCHAR2(2) := '*';
  TYPE tcursor 	IS REF CURSOR;
  l1_cursor	tcursor;
  l_Org_Level_Id	VARCHAR2(50) := null; -- 'XXX' ;
  l_Org_Level_Short_name VARCHAR2(50) := null; -- 'XXX' ;
  l_text	VARCHAR2(3000) := null;


BEGIN


  l_text := '..... in  Is_Previous_Time_Period.';

  BIS_PMF_GET_DIMLEVELS_PVT.Get_DimLevel_Values_Data
  (
    p_bis_dimlevel_id => p_Dim_Level_Value_Rec.Dimension_Level_ID
   ,x_dimlevel_short_name => l_short_name
   ,x_select_String =>  l_select_stmt
   ,x_table_name => l_view_name
   ,x_value_name => l_value_name
   ,x_id_name =>  l_id_name
   ,x_level_name => l_name
   ,x_description => l_description
   ,x_return_status =>  l_return_status
   ,x_msg_count => l_msg_count
   ,x_msg_data  =>  l_msg_data
  );

  l_level_id   := p_Dim_Level_Value_Rec.Dimension_Level_ID;

  l_source := bis_utilities_pvt.GET_SOURCE_FROM_DIM_LEVEL
                (
                   p_DimLevelId         => l_level_id
                 , p_DimLevelShortName  => l_level_short_name  -- l_level_name
                );

  l_text := l_text || ' Source is '|| l_source;


  if ( l_source = 'OLTP' ) then
      bis_utilities_pvt.Get_Org_Info_Based_On_Source
      ( p_source		=> l_source,
        p_org_level_id	 	=> p_org_level_id,
        p_org_level_short_name 	=> p_org_level_short_name,
        x_org_level_id	 	=> l_org_level_id,
        x_org_level_short_name 	=> l_org_level_short_name
      );
  elsif ( l_source = 'EDW') then
        l_org_level_id	 	:= p_org_level_id;
        l_org_level_short_name 	:= p_org_level_short_name;

  elsif ( l_source <> 'EDW') then
       l_text := l_text || ' ERROR: Is_Current_Time_Period : source can be only either OLTP or EDW ';
  end if;


  bis_utilities_pvt.Get_Time_Level_Value_ID_Minus
  ( p_source		=> l_source,
    p_view_name		=> l_view_name,
    p_id_name     	=> l_id_name,
    p_org_level_id	=> l_org_level_id,
    p_org_level_short_name => l_org_level_short_name,
    p_sysdate_less	=> 0,
    x_time_id		=> l_time_id
  );


  bis_utilities_pvt.Get_Start_End_Dates
  ( p_source		=> l_source,
    p_view_name		=> l_view_name,
    p_id_col_name     	=> l_id_name,
    p_id_value_name     => l_time_id,
    p_org_level_id	=> l_org_level_id,
    p_org_level_short_name => l_org_level_short_name,
    x_start_date	=> l_start_date,
    x_end_date		=> l_end_date
  );


  l_time_id := NULL;


  bis_utilities_pvt.Get_Time_Level_Value_ID_Date
  ( p_source		 	=> l_source,
    p_view_name			=> l_view_name,
    p_id_name     	 	=> l_id_name,
    p_org_level_id	 	=> l_org_level_id,
    p_org_level_short_name 	=> l_org_level_short_name,
    p_target_date		=> l_start_date - 1,
    x_time_id		 	=> l_time_id
  );


  x_Previous_time_id := l_time_id;

  l_text := l_text || ' input time level value id = ' || p_Dim_Level_Value_Rec.Dimension_Level_value_ID ;

  l_text := l_text ||  ' ..... out NOCOPY of Is_Previous_Time_Period.';

  if  ( bis_utilities_pub.value_not_missing ( l_time_id ) = FND_API.G_TRUE )
    and ( bis_utilities_pub.value_not_null ( l_time_id ) = FND_API.G_TRUE )
  then
    l_text := l_text || ' previous time id is ' || l_time_id ;
  else
    l_text := l_text || ' previous time id is NULL ' ;
  end if;


  BIS_UTILITIES_PUB.put_line(p_text => l_text ) ;


  IF l_time_id = p_Dim_Level_Value_Rec.Dimension_Level_value_ID  THEN
    BIS_UTILITIES_PUB.put_line(p_text =>' This time level value id is in previous period ');
    RETURN true;
  ELSE
    BIS_UTILITIES_PUB.put_line(p_text =>' This time level value id is not in previous period ');
    RETURN false;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'exception at Is_Previous_Time_Period: 0500 '||sqlerrm);

END Is_Previous_Time_Period;

--
--

END BIS_DIM_LEVEL_VALUE_PVT;

/
