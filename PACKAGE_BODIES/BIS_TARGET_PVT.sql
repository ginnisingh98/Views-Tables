--------------------------------------------------------
--  DDL for Package Body BIS_TARGET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_TARGET_PVT" AS
/* $Header: BISVTARB.pls 120.1 2006/04/10 07:59:05 psomesul noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVTARB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for creating and managing Targets for the             |
REM |     Key Performance Framework.                                        |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 02-DEC-98 irchen Creation                            		    |
REM | 20-JAN-02 sashaik Added Retrieve_Org_level_value for 1740789	    |
REM | 10-JAN-2003 rchandra for bug 2715432 , changed OUT parameter          |
REM |                       x_Target_Level_Rec , x_Target_Rec to IN OUT     |
REM |                       in API RETRIEVE_TARGET_FROM_SHNMS               |
REM |                       and x_Target_Rec in API Value_ID_Conversion     |
REM | 15-JAN-2003 mahrao    for 2744792                                     |
REM |                       removed the BIS_UTILITIES_PUB.Value_Not_Missing |
REM |                       condition in Update_db_Target for owners and    |
REM |                       tolerance ranges as user might want to update   |
REM |                       them to NULL.                                   |
REM | 23-JAN-03 sugopal For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)              	            |
REM | 23-JUL-03 sashaik For bug 3064592: related to computing function id   |
REM |                     and setting targets dynamically.                  |
REM | 26-JUL-04 ankgoel Bug#3756093 Returned role_id for role_short_names in|
REM |                   retrieve_targets API                                |
REM | 13-JAN-05 vtulasi Bug#4102897 - Change in size of variables           |
REM | 21-MAR-05 ankagarw Bug#4235732 - changing count(*) to count(1)        |
REM | 10-APR-05 psomesul Bug#5140269 - PERFORMANCE ISSUE WITH TARGET OWNER  |
REM |              LOV IN PMF PAGES - replaced WF_ROLES with WF_ROLE_LOV_VL |
REM +=======================================================================+
*/

--
--
-- queries database to retrieve the target from the database
-- updates the record with the changes sent in
PROCEDURE Update_db_Target
( p_Target_Rec    BIS_TARGET_PUB.Target_Rec_Type
, x_Target_Rec    IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
-- returns the record with the G_MISS_CHAR/G_MISS_NUM replaced
-- by null
PROCEDURE Create_db_Target
( p_Target_Rec IN  BIS_TARGET_PUB.Target_Rec_Type
, x_Target_Rec OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
);

-- returns the record with the G_MISS_CHAR/G_MISS_NUM replaced
-- by null
--
PROCEDURE SetNULL
( p_Dimension_Level_Rec    IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec    OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
);

--
PROCEDURE SetNULL
( p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
)
IS
BEGIN

  x_dimension_level_rec.Dimension_ID
    := BIS_UTILITIES_PUB.G_NULL_NUM;
  x_dimension_level_rec.Dimension_Short_Name
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.Dimension_Name
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.Dimension_Level_ID
    := BIS_UTILITIES_PUB.G_NULL_NUM;
  x_dimension_level_rec.Dimension_Level_Short_Name
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.Dimension_Level_Name
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.Description
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.Level_Values_View_Name
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.where_Clause
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.source
    := BIS_UTILITIES_PUB.G_NULL_CHAR;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE
    ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END SetNULL;
--   Defines one target for a specific set of dimension values for
--   one target level
PROCEDURE Create_Target
( p_api_version      IN  NUMBER
, p_is_dbimeasure    IN  NUMBER := 0 --added by gbhaloti #3148615
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Target_Rec BIS_TARGET_PUB.Target_Rec_Type;
l_count      NUMBER;
l_user_id    NUMBER;
l_login_id   NUMBER;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;

--
BEGIN
  --
l_target_rec := p_target_rec;

  -- dbms_output.put_line( ' Inside pvt : 11 ' );

  Validate_Target
  ( p_api_version      => p_api_version
  , p_is_dbimeasure    => p_is_dbimeasure --added by gbhaloti #3148615
  , p_validation_level => p_validation_level
  , p_Target_Rec       => p_Target_Rec
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_Tbl
  );
  --

  -- dbms_output.put_line( ' Inside pvt : 12 ' );

  IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --

  Create_db_Target
  ( p_Target_Rec => p_Target_Rec
  , x_Target_Rec => l_Target_Rec
  );

  -- dbms_output.put_line( ' Inside pvt : 13 ' );

  --
  -- validate that record does not exist already
  SELECT COUNT(1)
  INTO l_count
  FROM BISBV_TARGETS bisbv_targets
  WHERE bisbv_targets.TARGET_LEVEL_ID = l_Target_Rec.Target_Level_ID
   AND  bisbv_targets.PLAN_ID = l_Target_Rec.Plan_ID
   AND  NVL(bisbv_targets.ORG_LEVEL_VALUE_ID, 'Y')
        = NVL(l_Target_Rec.Org_Level_Value_ID, 'Y')
   AND  NVL(bisbv_targets.TIME_LEVEL_VALUE_ID, 'Y')
        = NVL(l_Target_Rec.Time_Level_Value_ID, 'Y')
   AND  NVL(bisbv_targets.DIM1_LEVEL_VALUE_ID, 'Y')
        = NVL(l_Target_Rec.Dim1_Level_Value_ID, 'Y')
   AND  NVL(bisbv_targets.DIM2_LEVEL_VALUE_ID, 'Y')
        = NVL(l_Target_Rec.Dim2_Level_Value_ID, 'Y')
   AND  NVL(bisbv_targets.DIM3_LEVEL_VALUE_ID, 'Y')
        = NVL(l_Target_Rec.Dim3_Level_Value_ID, 'Y')
   AND  NVL(bisbv_targets.DIM4_LEVEL_VALUE_ID, 'Y')
        = NVL(l_Target_Rec.Dim4_Level_Value_ID, 'Y')
   AND  NVL(bisbv_targets.DIM5_LEVEL_VALUE_ID, 'Y')
        = NVL(l_Target_Rec.Dim5_Level_Value_ID, 'Y')
   AND  NVL(bisbv_targets.DIM6_LEVEL_VALUE_ID, 'Y')
        = NVL(l_Target_Rec.Dim6_Level_Value_ID, 'Y')
   AND  NVL(bisbv_targets.DIM7_LEVEL_VALUE_ID, 'Y')
        = NVL(l_Target_Rec.Dim7_Level_Value_ID, 'Y');

  -- dbms_output.put_line( ' Inside pvt : 14 ' );

  --
  IF(l_count <> 0) THEN
    --added more params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_RECORD_EXISTS'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => 'BIS_TARGET_PVT.Create_Target'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- dbms_output.put_line( ' Inside pvt : 15 ' );

  --
  l_user_id := fnd_global.USER_ID;
  l_login_id := fnd_global.LOGIN_ID;
  --
  INSERT INTO bis_target_values
  ( TARGET_ID
  , TARGET_LEVEL_ID
  , PLAN_ID
  , ORG_LEVEL_VALUE
  , TIME_LEVEL_VALUE
  , DIMENSION1_LEVEL_VALUE
  , DIMENSION2_LEVEL_VALUE
  , DIMENSION3_LEVEL_VALUE
  , DIMENSION4_LEVEL_VALUE
  , DIMENSION5_LEVEL_VALUE
  , DIMENSION6_LEVEL_VALUE
  , DIMENSION7_LEVEL_VALUE
  , TARGET
  , RANGE1_LOW
  , RANGE1_HIGH
  , RANGE2_LOW
  , RANGE2_HIGH
  , RANGE3_LOW
  , RANGE3_HIGH
  , ROLE1_ID
  , ROLE1
  , ROLE2_ID
  , ROLE2
  , ROLE3_ID
  , ROLE3
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  )
  VALUES
  ( bis_target_values_s.NEXTVAL
  , l_Target_Rec.Target_Level_ID
  , l_Target_Rec.Plan_ID
  , l_Target_Rec.Org_Level_Value_ID
  , l_Target_Rec.Time_Level_Value_ID
  , l_Target_Rec.Dim1_Level_Value_ID
  , l_Target_Rec.Dim2_Level_Value_ID
  , l_Target_Rec.Dim3_Level_Value_ID
  , l_Target_Rec.Dim4_Level_Value_ID
  , l_Target_Rec.Dim5_Level_Value_ID
  , l_Target_Rec.Dim6_Level_Value_ID
  , l_Target_Rec.Dim7_Level_Value_ID
  , l_Target_Rec.Target
  , l_Target_Rec.Range1_low
  , l_Target_Rec.Range1_high
  , l_Target_Rec.Range2_low
  , l_Target_Rec.Range2_high
  , l_Target_Rec.Range3_low
  , l_Target_Rec.Range3_high
  , l_Target_Rec.Notify_Resp1_ID
  , l_Target_Rec.Notify_Resp1_Short_Name
  , l_Target_Rec.Notify_Resp2_ID
  , l_Target_Rec.Notify_Resp2_Short_Name
  , l_Target_Rec.Notify_Resp3_ID
  , l_Target_Rec.Notify_Resp3_Short_Name
  , SYSDATE
  , l_user_id
  , SYSDATE
  , l_user_id
  , l_login_id
  );

  -- dbms_output.put_line( ' Inside pvt : 16 ' );

--
 --added this
 if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

  -- dbms_output.put_line( ' Inside pvt : 17 ' );

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Create_Target:G_EXC_ERROR'); htp.para;
    END IF;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Create_Target:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Create_Target:OTHERS'); htp.para;
    END IF;
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Create_Target;
--
--
-- returns the record with the G_MISS_CHAR/G_MISS_NUM replaced
-- by null
PROCEDURE Create_db_Target
( p_Target_Rec IN  BIS_TARGET_PUB.Target_Rec_Type
, x_Target_Rec OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
)
IS
BEGIN
  x_Target_Rec := p_Target_Rec;
  x_Target_Rec.Target_Level_ID
   := BIS_UTILITIES_PVT.CheckMissNum(p_num => x_Target_Rec.Target_Level_ID);

  -- dbms_output.put_line( ' Inside pvt : 21 ' );

  x_Target_Rec.Plan_ID
   := BIS_UTILITIES_PVT.CheckMissNum(p_num => x_Target_Rec.Plan_ID);

  -- dbms_output.put_line( ' Inside pvt : 22 ' );

  x_Target_Rec.Org_Level_Value_ID
   := BIS_UTILITIES_PVT.CheckMissChar
      (p_char => x_Target_Rec.Org_Level_Value_ID);
  x_Target_Rec.Time_Level_Value_ID
   := BIS_UTILITIES_PVT.CheckMissChar
      (p_char => x_Target_Rec.Time_Level_Value_ID);
  x_Target_Rec.Dim1_Level_Value_ID
   := BIS_UTILITIES_PVT.CheckMissChar
      (p_char => x_Target_Rec.Dim1_Level_Value_ID);
  x_Target_Rec.Dim2_Level_Value_ID
   := BIS_UTILITIES_PVT.CheckMissChar
      (p_char => x_Target_Rec.Dim2_Level_Value_ID);
  x_Target_Rec.Dim3_Level_Value_ID
   := BIS_UTILITIES_PVT.CheckMissChar
      (p_char => x_Target_Rec.Dim3_Level_Value_ID);

  -- dbms_output.put_line( ' Inside pvt : 23' );

  x_Target_Rec.Dim4_Level_Value_ID
   := BIS_UTILITIES_PVT.CheckMissChar
      (p_char => x_Target_Rec.Dim4_Level_Value_ID);
  x_Target_Rec.Dim5_Level_Value_ID
   := BIS_UTILITIES_PVT.CheckMissChar
      (p_char => x_Target_Rec.Dim5_Level_Value_ID);
  x_Target_Rec.Dim6_Level_Value_ID
   := BIS_UTILITIES_PVT.CheckMissChar
      (p_char => x_Target_Rec.Dim6_Level_Value_ID);
  x_Target_Rec.Dim7_Level_Value_ID
   := BIS_UTILITIES_PVT.CheckMissChar
      (p_char => x_Target_Rec.Dim7_Level_Value_ID);
  x_Target_Rec.Target
   := BIS_UTILITIES_PVT.CheckMissNum(p_num => x_Target_Rec.Target);
  x_Target_Rec.Range1_low
   := BIS_UTILITIES_PVT.CheckMissNum(p_num => x_Target_Rec.Range1_low);
  x_Target_Rec.Range1_high
   := BIS_UTILITIES_PVT.CheckMissNum(p_num => x_Target_Rec.Range1_high);

  -- dbms_output.put_line( ' Inside pvt : 24 ' );

  x_Target_Rec.Range2_low
   := BIS_UTILITIES_PVT.CheckMissNum(p_num => x_Target_Rec.Range2_low);
  x_Target_Rec.Range2_high
   := BIS_UTILITIES_PVT.CheckMissNum(p_num => x_Target_Rec.Range2_high);
  x_Target_Rec.Range3_low
   := BIS_UTILITIES_PVT.CheckMissNum(p_num => x_Target_Rec.Range3_low);
  x_Target_Rec.Range3_high
   := BIS_UTILITIES_PVT.CheckMissNum(p_num => x_Target_Rec.Range3_high);
  x_Target_Rec.Notify_Resp1_ID
   := BIS_UTILITIES_PVT.CheckMissNum(p_num => x_Target_Rec.Notify_Resp1_ID);
  x_Target_Rec.Notify_Resp1_Short_Name
   := BIS_UTILITIES_PVT.CheckMissChar
      (p_char => x_Target_Rec.Notify_Resp1_Short_Name);
  x_Target_Rec.Notify_Resp2_ID
   := BIS_UTILITIES_PVT.CheckMissNum(p_num => x_Target_Rec.Notify_Resp2_ID);
  x_Target_Rec.Notify_Resp2_Short_Name
   := BIS_UTILITIES_PVT.CheckMissChar
      (p_char => x_Target_Rec.Notify_Resp2_Short_Name);
  x_Target_Rec.Notify_Resp3_ID
   := BIS_UTILITIES_PVT.CheckMissNum(p_num => x_Target_Rec.Notify_Resp3_ID);
  x_Target_Rec.Notify_Resp3_Short_Name
   := BIS_UTILITIES_PVT.CheckMissChar
      (p_char => x_Target_Rec.Notify_Resp3_Short_Name);

  -- dbms_output.put_line( ' Inside pvt : 25 ' );

END Create_db_Target;
--
-- retrieve information for all taRGEts of the given target level
-- if information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Targets
( p_api_version         IN  NUMBER
, p_Target_Level_Rec    IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_all_info            IN  VARCHAR2 := FND_API.G_TRUE
, x_Target_Tbl          OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
CURSOR c_all_targets(p_Target_Level_ID IN NUMBER) IS
SELECT *
FROM bisfv_targets bisfv_targets
WHERE bisfv_targets.TARGET_LEVEL_ID =  p_Target_Level_ID;
--
l_ind NUMBER := 0;
l_Target_Level_Rec BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  -- BIS_UTILITIES_PUB.put_line(p_text => ' ............................. ' );

  FOR cr IN c_all_targets
            (p_Target_Level_ID => p_Target_Level_Rec.TARGET_LEVEL_ID) LOOP
    l_ind := l_ind + 1;
    x_Target_Tbl(l_ind).Target_ID               := cr.Target_ID;
    x_Target_Tbl(l_ind).Target_Level_ID      := cr.Target_Level_ID;
    x_Target_Tbl(l_ind).Target_Level_Short_Name
                        := cr.Target_Level_Short_Name;
    x_Target_Tbl(l_ind).Target_Level_Name    := cr.Target_Level_Name;
    x_Target_Tbl(l_ind).Plan_ID                 := cr.Plan_ID;
    x_Target_Tbl(l_ind).Plan_Short_Name         := cr.Plan_Short_Name;
    x_Target_Tbl(l_ind).Plan_Name               := cr.Plan_Name;
    X_Target_Tbl(l_ind).Org_Level_Value_ID      := cr.Org_Level_Value_ID;
    X_Target_Tbl(l_ind).Time_Level_Value_ID     := cr.Time_Level_Value_ID;
    X_Target_Tbl(l_ind).Dim1_Level_Value_ID     := cr.Dim1_Level_Value_ID;
    x_Target_Tbl(l_ind).Dim2_Level_Value_ID     := cr.Dim2_Level_Value_ID;
    x_Target_Tbl(l_ind).Dim3_Level_Value_ID     := cr.Dim3_Level_Value_ID;
    x_Target_Tbl(l_ind).Dim4_Level_Value_ID     := cr.Dim4_Level_Value_ID;
    x_Target_Tbl(l_ind).Dim5_Level_Value_ID     := cr.Dim5_Level_Value_ID;
    x_Target_Tbl(l_ind).Dim6_Level_Value_ID     := cr.Dim6_Level_Value_ID;
    x_Target_Tbl(l_ind).Dim7_Level_Value_ID     := cr.Dim7_Level_Value_ID;
    x_Target_Tbl(l_ind).Target                  := cr.Target;
    x_Target_Tbl(l_ind).Range1_low              := cr.Range1_low;
    x_Target_Tbl(l_ind).Range1_high             := cr.Range1_high;
    x_Target_Tbl(l_ind).Range2_low              := cr.Range2_low;
    x_Target_Tbl(l_ind).Range2_high             := cr.Range2_high;
    x_Target_Tbl(l_ind).Range3_low              := cr.Range3_low;
    x_Target_Tbl(l_ind).Range3_high             := cr.Range3_high;
    x_Target_Tbl(l_ind).Notify_Resp1_ID         := NVL(cr.Notify_Resp1_ID, BIS_UTILITIES_PVT.get_role_id(cr.Notify_Resp1_Short_Name));
    x_Target_Tbl(l_ind).Notify_Resp1_Short_Name := cr.Notify_Resp1_Short_Name;
    x_Target_Tbl(l_ind).Notify_Resp1_Name       := cr.Notify_Resp1_Name;
    x_Target_Tbl(l_ind).Notify_Resp2_ID         := NVL(cr.Notify_Resp2_ID, BIS_UTILITIES_PVT.get_role_id(cr.Notify_Resp2_Short_Name));
    x_Target_Tbl(l_ind).Notify_Resp2_Short_Name := cr.Notify_Resp2_Short_Name;
    x_Target_Tbl(l_ind).Notify_Resp2_Name       := cr.Notify_Resp2_Name;
    x_Target_Tbl(l_ind).Notify_Resp3_ID         := NVL(cr.Notify_Resp3_ID, BIS_UTILITIES_PVT.get_role_id(cr.Notify_Resp3_Short_Name));
    x_Target_Tbl(l_ind).Notify_Resp3_Short_Name := cr.Notify_Resp3_Short_Name;
    x_Target_Tbl(l_ind).Notify_Resp3_Name       := cr.Notify_Resp3_Name;

    -- BIS_UTILITIES_PUB.put_line(p_text => ' Target id = ' || cr.Target_ID ) ;

    -- if numeric target is missing, get the computed target
    --
    IF ((BIS_UTILITIES_PUB.Value_Missing(x_Target_tbl(l_ind).Target)
      = FND_API.G_TRUE)
    OR (BIS_UTILITIES_PUB.Value_Null(x_Target_tbl(l_ind).Target)
      = FND_API.G_TRUE))
    THEN
      IF ((BIS_UTILITIES_PUB.Value_Missing
         (p_Target_Level_Rec.COMPUTING_FUNCTION_ID) = FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Null
         (p_Target_Level_Rec.COMPUTING_FUNCTION_ID) = FND_API.G_TRUE))
      THEN
        BIS_Target_Level_PVT.Retrieve_Target_Level
        ( p_api_version         => p_api_version
        , p_Target_Level_Rec    => p_Target_Level_Rec
        , p_all_info            => FND_API.G_FALSE
        , x_Target_Level_Rec    => l_Target_Level_Rec
        , x_return_status       => x_return_status
        , x_error_Tbl           => x_error_Tbl
        );
      ELSE
        l_target_level_rec := p_target_level_rec;
      END IF;

      -- only compute target if found computing fn id
      --
      IF ((BIS_UTILITIES_PUB.Value_Not_Missing
         (l_Target_Level_Rec.COMPUTING_FUNCTION_ID) = FND_API.G_TRUE)
      AND (BIS_UTILITIES_PUB.Value_Not_Null
         (l_Target_Level_Rec.COMPUTING_FUNCTION_ID) = FND_API.G_TRUE))
      THEN
        x_target_tbl(l_ind).target :=
          Get_Target
          ( p_computing_function_id => l_target_level_rec.computing_function_id
          , p_target_rec            => x_target_tbl(l_ind)
          );
      END IF;
    END IF;

  END LOOP;
  -- BIS_UTILITIES_PUB.put_line(p_text => ' ............................. ' );
  --

--added this check
if(l_ind = 0) then
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_TAR_LEVEL_ID'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Targets'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
end if;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Targets:G_EXC_ERROR'); htp.para;
    END IF;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Targets:G_EXC_UNEXPECTED_ERROR');
      htp.para;
    END IF;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Targets:OTHERS'); htp.para;
    END IF;
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Retrieve_Targets;
--
--
-- retrieve information for one target
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Target
( p_api_version   IN  NUMBER
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, p_all_info      IN  VARCHAR2 := FND_API.G_TRUE
, x_Target_Rec    IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_bisfv_targets_rec       bisfv_targets%ROWTYPE;
l_bisbv_target_levels_rec bisbv_target_levels%ROWTYPE;
l_Target_Level_Rec BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_plan_id NUMBER;
l_Business_Plan_Rec BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type;
l_org_level_value_id VARCHAR2(250);
l_time_level_value_id VARCHAR2(250);
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

l_Business_Plan_Rec_p BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type;
l_Target_Level_Rec_p BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
--
BEGIN

  x_target_Rec := p_target_rec;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Target_ID)
      = FND_API.G_TRUE
      AND p_Target_Rec.Target_ID IS NOT NULL
    ) THEN
    SELECT *
    INTO l_bisfv_targets_rec
    FROM bisfv_targets bisfv_targets
    WHERE bisfv_targets.TARGET_ID = p_Target_Rec.Target_ID;


  ELSIF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Target_Level_ID)
         = FND_API.G_TRUE
         AND p_Target_Rec.Target_Level_ID IS NOT NULL
       ) THEN
    SELECT *
    INTO l_bisbv_target_levels_rec
    FROM bisbv_target_levels bisbv_target_levels
    WHERE bisbv_target_levels.TARGET_LEVEL_ID
          = p_Target_Rec.Target_Level_ID;

    --
    --
    --Removed check for org and time


    IF(l_bisbv_target_levels_rec.DIMENSION1_LEVEL_ID IS NOT NULL) THEN
      IF( BIS_UTILITIES_PUB.Value_Missing
                            (p_Target_Rec.Dim1_Level_Value_ID)
          = FND_API.G_TRUE
          OR p_Target_Rec.Dim1_Level_Value_ID IS NULL
        ) THEN

         --added Error Msg--------
	 l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF( BIS_UTILITIES_PUB.Value_Not_Missing
                             (p_Target_Rec.Dim1_Level_Value_ID)
           = FND_API.G_TRUE
           AND p_Target_Rec.Dim1_Level_Value_ID IS NOT NULL
         ) THEN

           --added Error Msg--------
	   l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    IF(l_bisbv_target_levels_rec.DIMENSION2_LEVEL_ID IS NOT NULL) THEN
      IF( BIS_UTILITIES_PUB.Value_Missing
                            (p_Target_Rec.Dim2_Level_Value_ID)
          = FND_API.G_TRUE
          OR p_Target_Rec.Dim2_Level_Value_ID IS NULL
        ) THEN
         --added Error Msg--------
	 l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF( BIS_UTILITIES_PUB.Value_Not_Missing
                             (p_Target_Rec.Dim2_Level_Value_ID)
           = FND_API.G_TRUE
           AND p_Target_Rec.Dim2_Level_Value_ID IS NOT NULL
         ) THEN
          --added Error Msg--------
	  l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    IF(l_bisbv_target_levels_rec.DIMENSION3_LEVEL_ID IS NOT NULL) THEN
      IF( BIS_UTILITIES_PUB.Value_Missing
                            (p_Target_Rec.Dim3_Level_Value_ID)
          = FND_API.G_TRUE
          OR p_Target_Rec.Dim3_Level_Value_ID IS NULL
        ) THEN
         --added Error Msg--------
	 l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF( BIS_UTILITIES_PUB.Value_Not_Missing
                             (p_Target_Rec.Dim3_Level_Value_ID)
           = FND_API.G_TRUE
           AND p_Target_Rec.Dim3_Level_Value_ID IS NOT NULL
         )
         THEN
          --added Error Msg--------
	  l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
         RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    IF(l_bisbv_target_levels_rec.DIMENSION4_LEVEL_ID IS NOT NULL) THEN
      IF( BIS_UTILITIES_PUB.Value_Missing
                            (p_Target_Rec.Dim4_Level_Value_ID)
          = FND_API.G_TRUE
          OR p_Target_Rec.Dim4_Level_Value_ID IS NULL
        ) THEN
         --added Error Msg--------
	 l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF( BIS_UTILITIES_PUB.Value_Not_Missing
                             (p_Target_Rec.Dim4_Level_Value_ID)
           = FND_API.G_TRUE
           AND p_Target_Rec.Dim4_Level_Value_ID IS NOT NULL
         ) THEN
          --added Error Msg--------
	  l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    IF(l_bisbv_target_levels_rec.DIMENSION5_LEVEL_ID IS NOT NULL) THEN
      IF( BIS_UTILITIES_PUB.Value_Missing
                            (p_Target_Rec.Dim5_Level_Value_ID)
          = FND_API.G_TRUE
          OR p_Target_Rec.Dim5_Level_Value_ID IS NULL
        ) THEN
         --added Error Msg--------
	 l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF( BIS_UTILITIES_PUB.Value_Not_Missing
                             (p_Target_Rec.Dim5_Level_Value_ID)
           = FND_API.G_TRUE
           AND p_Target_Rec.Dim5_Level_Value_ID IS NOT NULL
         ) THEN
          --added Error Msg--------
	  l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    IF(l_bisbv_target_levels_rec.DIMENSION6_LEVEL_ID IS NOT NULL) THEN
      IF( BIS_UTILITIES_PUB.Value_Missing
                            (p_Target_Rec.Dim6_Level_Value_ID)
          = FND_API.G_TRUE
          OR p_Target_Rec.Dim6_Level_Value_ID IS NULL
        ) THEN
         --added Error Msg--------
	 l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF( BIS_UTILITIES_PUB.Value_Not_Missing
                             (p_Target_Rec.Dim6_Level_Value_ID)
           = FND_API.G_TRUE
           AND p_Target_Rec.Dim6_Level_Value_ID IS NOT NULL
         ) THEN
          --added Error Msg--------
	  l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
    --
    IF(l_bisbv_target_levels_rec.DIMENSION7_LEVEL_ID IS NOT NULL) THEN
      IF( BIS_UTILITIES_PUB.Value_Missing
                            (p_Target_Rec.Dim7_Level_Value_ID)
          = FND_API.G_TRUE
          OR p_Target_Rec.Dim7_Level_Value_ID IS NULL
        ) THEN
         --added Error Msg--------
	 l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF( BIS_UTILITIES_PUB.Value_Not_Missing
                             (p_Target_Rec.Dim7_Level_Value_ID)
           = FND_API.G_TRUE
           AND p_Target_Rec.Dim7_Level_Value_ID IS NOT NULL
         ) THEN
       --added Error Msg--------
       l_error_tbl := x_error_tbl;
         BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
        );
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --



    ---If Plan Id is not given, get Plan Id from Short name

     if (BIS_UTILITIES_PUB.Value_Missing(p_Target_Rec.Plan_ID)
                                          = FND_API.G_TRUE) then
        if (BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Plan_Short_Name)
                                          = FND_API.G_TRUE) then
             l_Business_Plan_Rec.Business_Plan_Short_Name := p_Target_Rec.Plan_Short_Name;
	     l_Business_Plan_Rec_p := l_Business_Plan_Rec;
             BIS_BUSINESS_PLAN_PVT.Value_ID_Conversion
             ( p_api_version       => p_api_version
             , p_Business_Plan_Rec => l_Business_Plan_Rec_p
             , x_Business_Plan_Rec => l_Business_Plan_Rec
             , x_return_status     => x_return_status
             , x_error_Tbl         => x_error_tbl
             );
             if(x_return_status = FND_API.G_RET_STS_SUCCESS) then
                l_plan_id := l_Business_Plan_Rec.Business_Plan_ID;
             end if;
        end if;
     else
        l_plan_id :=   p_Target_Rec.Plan_ID ;
     end if;

     if(BIS_UTILITIES_PUB.Value_Missing(p_Target_Rec.Org_Level_Value_ID) = FND_API.G_TRUE)
       then l_org_level_value_id := NULL;
     else
       l_org_level_value_id := p_Target_Rec.Org_Level_Value_ID;
     end if;


     if(BIS_UTILITIES_PUB.Value_Missing(p_Target_Rec.Time_Level_Value_ID) = FND_API.G_TRUE)
       then l_time_level_value_id := NULL;
     else
         l_time_level_value_id := p_Target_Rec.Time_Level_Value_ID;
     end if;
  --------------------------------------------



    SELECT *
    INTO l_bisfv_targets_rec
    FROM bisfv_targets bisfv_targets
    WHERE bisfv_targets.TARGET_LEVEL_ID  = p_Target_Rec.Target_Level_ID
     -- used to be  p_Target_Rec.Plan_ID
      AND bisfv_targets.PLAN_ID             = l_plan_id

     ---changed org and time logic
      AND (l_org_level_value_id IS NULL
         OR NVL(bisfv_targets.ORG_LEVEL_VALUE_ID,'T')   = NVL(l_org_level_value_id, 'T'))

      AND (l_time_level_value_id IS NULL
         OR NVL(bisfv_targets.TIME_LEVEL_VALUE_ID,'T')   = NVL(l_time_level_value_id, 'T'))

      AND NVL(bisfv_targets.DIM1_LEVEL_VALUE_ID, 'T')
          = DECODE( p_Target_Rec.Dim1_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(p_Target_Rec.Dim1_Level_Value_ID, 'T')
                  )
      AND NVL(bisfv_targets.DIM2_LEVEL_VALUE_ID, 'T')
          = DECODE( p_Target_Rec.Dim2_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(p_Target_Rec.Dim2_Level_Value_ID, 'T')
                  )
      AND NVL(bisfv_targets.DIM3_LEVEL_VALUE_ID, 'T')
          = DECODE( p_Target_Rec.Dim3_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(p_Target_Rec.Dim3_Level_Value_ID, 'T')
                  )
      AND NVL(bisfv_targets.DIM4_LEVEL_VALUE_ID, 'T')
          = DECODE( p_Target_Rec.Dim4_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(p_Target_Rec.Dim4_Level_Value_ID, 'T')
                  )
      AND NVL(bisfv_targets.DIM5_LEVEL_VALUE_ID, 'T')
          = DECODE( p_Target_Rec.Dim5_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(p_Target_Rec.Dim5_Level_Value_ID, 'T')
                  )
      AND NVL(bisfv_targets.DIM6_LEVEL_VALUE_ID, 'T')
          = DECODE( p_Target_Rec.Dim6_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(p_Target_Rec.Dim6_Level_Value_ID, 'T')
                  )
      AND NVL(bisfv_targets.DIM7_LEVEL_VALUE_ID, 'T')
          = DECODE( p_Target_Rec.Dim7_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(p_Target_Rec.Dim7_Level_Value_ID, 'T')
                  )
      ;
  END IF;
  --
  x_Target_Rec.Target_ID             := l_bisfv_targets_rec.Target_ID;
  x_Target_Rec.Target_Level_ID    := l_bisfv_targets_rec.Target_Level_ID;
  x_Target_Rec.Target_Level_Short_Name
                    := l_bisfv_targets_rec.Target_Level_Short_Name;
  x_Target_Rec.Target_Level_Name
                    := l_bisfv_targets_rec.Target_Level_Name;
  x_Target_Rec.Plan_ID               := l_bisfv_targets_rec.Plan_ID;
  x_Target_Rec.Plan_Short_Name       := l_bisfv_targets_rec.Plan_Short_Name;
  x_Target_Rec.Plan_Name             := l_bisfv_targets_rec.Plan_Name;
  x_Target_Rec.Org_Level_Value_ID
                    := l_bisfv_targets_rec.Org_Level_Value_ID;
  x_Target_Rec.Time_Level_Value_ID
                    := l_bisfv_targets_rec.Time_Level_Value_ID;
  x_Target_Rec.Dim1_Level_Value_ID
                    := l_bisfv_targets_rec.Dim1_Level_Value_ID;
  x_Target_Rec.Dim2_Level_Value_ID
                    := l_bisfv_targets_rec.Dim2_Level_Value_ID;
  x_Target_Rec.Dim3_Level_Value_ID
                    := l_bisfv_targets_rec.Dim3_Level_Value_ID;
  x_Target_Rec.Dim4_Level_Value_ID
                    := l_bisfv_targets_rec.Dim4_Level_Value_ID;
  x_Target_Rec.Dim5_Level_Value_ID
                    := l_bisfv_targets_rec.Dim5_Level_Value_ID;
  x_Target_Rec.Dim6_Level_Value_ID
                    := l_bisfv_targets_rec.Dim6_Level_Value_ID;
  x_Target_Rec.Dim7_Level_Value_ID
                    := l_bisfv_targets_rec.Dim7_Level_Value_ID;
  x_Target_Rec.Target                := l_bisfv_targets_rec.Target;
  x_Target_Rec.Range1_low            := l_bisfv_targets_rec.Range1_low;
  x_Target_Rec.Range1_high           := l_bisfv_targets_rec.Range1_high;
  x_Target_Rec.Range2_low            := l_bisfv_targets_rec.Range2_low;
  x_Target_Rec.Range2_high           := l_bisfv_targets_rec.Range2_high;
  x_Target_Rec.Range3_low            := l_bisfv_targets_rec.Range3_low;
  x_Target_Rec.Range3_high           := l_bisfv_targets_rec.Range3_high;
  x_Target_Rec.Notify_Resp1_ID       := NVL(l_bisfv_targets_rec.Notify_Resp1_ID, BIS_UTILITIES_PVT.get_role_id(l_bisfv_targets_rec.Notify_Resp1_Short_Name));
  x_Target_Rec.Notify_Resp1_Short_Name
                      := l_bisfv_targets_rec.Notify_Resp1_Short_Name;
  x_Target_Rec.Notify_Resp1_Name     := l_bisfv_targets_rec.Notify_Resp1_Name;
  x_Target_Rec.Notify_Resp2_ID       := NVL(l_bisfv_targets_rec.Notify_Resp2_ID, BIS_UTILITIES_PVT.get_role_id(l_bisfv_targets_rec.Notify_Resp2_Short_Name));
  x_Target_Rec.Notify_Resp2_Short_Name
                      := l_bisfv_targets_rec.Notify_Resp2_Short_Name;
  x_Target_Rec.Notify_Resp2_Name     := l_bisfv_targets_rec.Notify_Resp2_Name;
  x_Target_Rec.Notify_Resp3_ID       := NVL(l_bisfv_targets_rec.Notify_Resp3_ID, BIS_UTILITIES_PVT.get_role_id(l_bisfv_targets_rec.Notify_Resp3_Short_Name));
  x_Target_Rec.Notify_Resp3_Short_Name
                      := l_bisfv_targets_rec.Notify_Resp3_Short_Name;
  x_Target_Rec.Notify_Resp3_Name     := l_bisfv_targets_rec.Notify_Resp3_Name;

  -- if numeric target is missing, get the computed target
  --
  IF ((BIS_UTILITIES_PUB.Value_Missing(x_Target_Rec.Target) = FND_API.G_TRUE)
  OR (BIS_UTILITIES_PUB.Value_Null(x_Target_Rec.Target) = FND_API.G_TRUE))
  THEN
    IF ((BIS_UTILITIES_PUB.Value_Not_Missing
       (x_Target_Rec.target_level_ID) = FND_API.G_TRUE)
    AND (BIS_UTILITIES_PUB.Value_Not_Null
       (x_Target_Rec.target_level_ID) = FND_API.G_TRUE))
    THEN
      l_Target_Level_Rec.target_level_ID := x_Target_Rec.target_level_ID;
      l_Target_Level_Rec_p := l_Target_Level_Rec;
      BIS_Target_Level_PVT.Retrieve_Target_Level
      ( p_api_version         => p_api_version
      , p_Target_Level_Rec    => l_Target_Level_Rec_p
      , p_all_info            => FND_API.G_FALSE
      , x_Target_Level_Rec    => l_Target_Level_Rec
      , x_return_status       => x_return_status
      , x_error_Tbl           => x_error_Tbl
      );
    END IF;

    -- only compute target if found computing fn id
    --
    IF ((BIS_UTILITIES_PUB.Value_Not_Missing
       (l_Target_Level_Rec.COMPUTING_FUNCTION_ID) = FND_API.G_TRUE)
    AND (BIS_UTILITIES_PUB.Value_Not_Null
       (l_Target_Level_Rec.COMPUTING_FUNCTION_ID) = FND_API.G_TRUE))
    THEN
      x_target_rec.target :=
        Get_Target
        ( p_computing_function_id => l_target_level_rec.computing_function_id
        , p_target_rec            => x_target_rec
        );
    END IF;
  END IF;

--
--commented RAISE
EXCEPTION
  --added NO DATA FOUND
   WHEN NO_DATA_FOUND THEN
       --added this error message

      l_error_tbl := x_error_tbl;
       BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_TARGET_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
      x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Target:G_EXC_ERROR'); htp.para;
    END IF;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Target:G_EXC_UNEXPECTED_ERROR');
      htp.para;
    END IF;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Target:OTHERS'); htp.para;
    END IF;
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Retrieve_Target;
--
--
-- retrieves the owners for one target
-- If information about dimension values are not required, set all_info
-- to FALSE.
--
PROCEDURE Retrieve_Target_Owners
( p_api_version       IN  NUMBER
, p_Target_Rec        IN  BIS_TARGET_PUB.Target_Rec_Type
, p_all_info          IN  VARCHAR2 := FND_API.G_TRUE
, x_Target_Owners_Rec OUT NOCOPY BIS_TARGET_PUB.Target_Owners_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_Target_owners_rec BIS_TARGET_PUB.Target_Owners_Rec_Type;
  l_target_rec        BIS_TARGET_PUB.Target_Rec_Type;
  l_error_Tbl_p       BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_Target_Rec_p      BIS_TARGET_PUB.Target_Rec_Type;

BEGIN

  l_target_rec := p_target_rec;
  l_target_owners_rec := x_target_owners_rec;

  l_Target_Rec_p := l_Target_Rec;
  BIS_TARGET_PVT.Retrieve_Target
  ( p_api_version      => 1.0
  , p_Target_Rec       => l_Target_Rec_p
  , p_all_info         => p_all_info
  , x_Target_rec       => l_Target_rec
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_Tbl
  );

  l_target_owners_rec.Range1_Owner_ID := l_target_rec.Notify_Resp1_ID;
  l_target_owners_rec.Range1_Owner_Short_Name
    := l_target_rec.Notify_Resp1_Short_Name;
  l_target_owners_rec.Range1_Owner_Name := l_target_rec.Notify_Resp1_Name;

  l_target_owners_rec.Range2_Owner_ID := l_target_rec.Notify_Resp2_ID;
  l_target_owners_rec.Range2_Owner_Short_Name
    := l_target_rec.Notify_Resp2_Short_Name;
  l_target_owners_rec.Range2_Owner_Name := l_target_rec.Notify_Resp2_Name;

  l_target_owners_rec.Range3_Owner_ID := l_target_rec.Notify_Resp3_ID;
  l_target_owners_rec.Range3_Owner_Short_Name
    := l_target_rec.Notify_Resp3_Short_Name;
  l_target_owners_rec.Range3_Owner_Name := l_target_rec.Notify_Resp3_Name;

  x_target_owners_rec := l_target_owners_rec;

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Target_owners:G_EXC_ERROR');
      htp.para;
    END IF;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Target_owners:G_EXC_UNEXPECTED_ERROR');
      htp.para;
    END IF;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Target_owners:OTHERS'); htp.para;
    END IF;
  --  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Target_Owners;
--
-- Modifies one target for a specific set of dimension values for
-- one target level
PROCEDURE Update_Target
( p_api_version      IN  NUMBER
, p_is_dbimeasure    IN  NUMBER := 0 --gbhaloti #3148615
, p_commit           IN  VARCHAR2 := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Target_Rec BIS_TARGET_PUB.Target_Rec_Type;
l_target_id  NUMBER;
l_user_id    NUMBER;
l_login_id   NUMBER;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;

l_Target_Rec_p BIS_TARGET_PUB.Target_Rec_Type;

--
BEGIN
  --
  -- need to validate if record exists in db for update
  --
  -- get the ID if its not given in the record
  GetID
  ( p_api_version      => p_api_version
  , p_Target_Rec       => p_Target_Rec
  , x_Target_Rec       => l_Target_Rec
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_Tbl
  );
  -- retrieve record from database and apply changes
  l_Target_Rec_p := l_Target_Rec;
  Update_db_Target
  ( p_Target_Rec    => l_Target_Rec_p
  , x_Target_Rec    => l_Target_Rec
  , x_return_status => x_return_status
  , x_error_Tbl     => x_error_Tbl
  );
  --

  Validate_Target
  ( p_api_version      => p_api_version
  , p_is_dbimeasure    => p_is_dbimeasure
  , p_validation_level => p_validation_level
  , p_Target_Rec       => l_Target_Rec
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_Tbl
  );
  --
  IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  BEGIN

    SELECT bisbv_targets.TARGET_ID
    INTO l_target_id
    FROM BISBV_TARGETS bisbv_targets
    WHERE bisbv_targets.TARGET_LEVEL_ID = l_Target_Rec.Target_Level_ID
     AND  bisbv_targets.PLAN_ID = l_Target_Rec.Plan_ID
     AND  NVL(bisbv_targets.ORG_LEVEL_VALUE_ID, 'Y')
          = NVL(l_Target_Rec.Org_Level_Value_ID, 'Y')
     AND  NVL(bisbv_targets.TIME_LEVEL_VALUE_ID, 'Y')
          = NVL(l_Target_Rec.Time_Level_Value_ID, 'Y')
     AND  NVL(bisbv_targets.DIM1_LEVEL_VALUE_ID, 'Y')
          = NVL(l_Target_Rec.Dim1_Level_Value_ID, 'Y')
     AND  NVL(bisbv_targets.DIM2_LEVEL_VALUE_ID, 'Y')
          = NVL(l_Target_Rec.Dim2_Level_Value_ID, 'Y')
     AND  NVL(bisbv_targets.DIM3_LEVEL_VALUE_ID, 'Y')
          = NVL(l_Target_Rec.Dim3_Level_Value_ID, 'Y')
     AND  NVL(bisbv_targets.DIM4_LEVEL_VALUE_ID, 'Y')
          = NVL(l_Target_Rec.Dim4_Level_Value_ID, 'Y')
     AND  NVL(bisbv_targets.DIM5_LEVEL_VALUE_ID, 'Y')
          = NVL(l_Target_Rec.Dim5_Level_Value_ID, 'Y')
     AND  NVL(bisbv_targets.DIM6_LEVEL_VALUE_ID, 'Y')
          = NVL(l_Target_Rec.Dim6_Level_Value_ID, 'Y')
     AND  NVL(bisbv_targets.DIM7_LEVEL_VALUE_ID, 'Y')
          = NVL(l_Target_Rec.Dim7_Level_Value_ID, 'Y');

    --

    IF(l_target_id <> l_Target_Rec.Target_ID) THEN
      --added more params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name  => 'BIS_UNIQUE_INDEX_VIOLATION'
       , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
       , p_error_proc_name => 'BIS_TARGET_PVT.Update_Target'
       , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
       , p_error_table       => l_error_tbl
       , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN

     -- Added this err message
     l_error_tbl := x_error_tbl;
     BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name  => 'BIS_INVALID_TARGET_VALUE'
       , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
       , p_error_proc_name => 'BIS_TARGET_PVT.Update_Target'
       , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
       , p_error_table       => l_error_tbl
       , x_error_table       => x_error_tbl
      );
      --NULL;
      RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN

      RAISE;
  END;
  --
  l_user_id := fnd_global.USER_ID;
  l_login_id := fnd_global.LOGIN_ID;
  --

  UPDATE BIS_TARGET_VALUES SET
    TARGET                 = l_Target_Rec.TARGET
  , TARGET_LEVEL_ID        = l_Target_Rec.TARGET_LEVEL_ID
  , PLAN_ID                = l_Target_Rec.PLAN_ID
  , ORG_LEVEL_VALUE        = l_Target_Rec.ORG_LEVEL_VALUE_ID
  , TIME_LEVEL_VALUE       = l_Target_Rec.TIME_LEVEL_VALUE_ID
  , DIMENSION1_LEVEL_VALUE = l_Target_Rec.DIM1_LEVEL_VALUE_ID
  , DIMENSION2_LEVEL_VALUE = l_Target_Rec.DIM2_LEVEL_VALUE_ID
  , DIMENSION3_LEVEL_VALUE = l_Target_Rec.DIM3_LEVEL_VALUE_ID
  , DIMENSION4_LEVEL_VALUE = l_Target_Rec.DIM4_LEVEL_VALUE_ID
  , DIMENSION5_LEVEL_VALUE = l_Target_Rec.DIM5_LEVEL_VALUE_ID
  , DIMENSION6_LEVEL_VALUE = l_Target_Rec.DIM6_LEVEL_VALUE_ID
  , DIMENSION7_LEVEL_VALUE = l_Target_Rec.DIM7_LEVEL_VALUE_ID
  , RANGE1_LOW             = l_Target_Rec.RANGE1_LOW
  , RANGE1_HIGH            = l_Target_Rec.RANGE1_HIGH
  , RANGE2_LOW             = l_Target_Rec.RANGE2_LOW
  , RANGE2_HIGH            = l_Target_Rec.RANGE2_HIGH
  , RANGE3_LOW             = l_Target_Rec.RANGE3_LOW
  , RANGE3_HIGH            = l_Target_Rec.RANGE3_HIGH
  , ROLE1_ID               = l_Target_Rec.NOTIFY_RESP1_ID
  , ROLE1                  = l_Target_Rec.NOTIFY_RESP1_SHORT_NAME
  , ROLE2_ID               = l_Target_Rec.NOTIFY_RESP2_ID
  , ROLE2                  = l_Target_Rec.NOTIFY_RESP2_SHORT_NAME
  , ROLE3_ID               = l_Target_Rec.NOTIFY_RESP3_ID
  , ROLE3                  = l_Target_Rec.NOTIFY_RESP3_SHORT_NAME
  , LAST_UPDATE_DATE       = SYSDATE
  , LAST_UPDATED_BY        = l_user_id
  , LAST_UPDATE_LOGIN      = l_login_id
  WHERE TARGET_ID = l_Target_Rec.TARGET_ID;
--

--added this
  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;
--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Update_Target:G_EXC_ERROR'); htp.para;
    END IF;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Update_Target:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Update_Target:OTHERS'); htp.para;
    END IF;
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Update_Target;
--
--
-- returns the record with the Target_ID populated
PROCEDURE GetID
( p_api_version   IN  NUMBER
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, x_Target_Rec    OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error_Tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_Target_Rec := p_Target_Rec;
  IF( BIS_UTILITIES_PUB.Value_Missing(x_Target_Rec.TARGET_ID)
      = FND_API.G_TRUE
      OR x_Target_Rec.TARGET_ID IS NULL
    ) THEN
    SELECT TARGET_ID
    INTO x_Target_Rec.TARGET_ID
    FROM BISBV_TARGETS BISBV_TARGETS
    WHERE BISBV_TARGETS.TARGET_LEVEL_ID  = x_Target_Rec.Target_Level_ID
      AND BISBV_TARGETS.PLAN_ID             = x_Target_Rec.Plan_ID
      AND NVL(BISBV_TARGETS.ORG_LEVEL_VALUE_ID, 'T')
          = DECODE( x_Target_Rec.Org_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(x_Target_Rec.Org_Level_Value_ID, 'T')
                  )
      AND NVL(BISBV_TARGETS.TIME_LEVEL_VALUE_ID, 'T')
          = DECODE( x_Target_Rec.Time_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(x_Target_Rec.Time_Level_Value_ID, 'T')
                  )
      AND NVL(BISBV_TARGETS.DIM1_LEVEL_VALUE_ID, 'T')
          = DECODE( x_Target_Rec.Dim1_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(x_Target_Rec.Dim1_Level_Value_ID, 'T')
                  )
      AND NVL(BISBV_TARGETS.DIM2_LEVEL_VALUE_ID, 'T')
          = DECODE( x_Target_Rec.Dim2_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(x_Target_Rec.Dim2_Level_Value_ID, 'T')
                  )
      AND NVL(BISBV_TARGETS.DIM3_LEVEL_VALUE_ID, 'T')
          = DECODE( x_Target_Rec.Dim3_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(x_Target_Rec.Dim3_Level_Value_ID, 'T')
                  )
      AND NVL(BISBV_TARGETS.DIM4_LEVEL_VALUE_ID, 'T')
          = DECODE( x_Target_Rec.Dim4_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(x_Target_Rec.Dim4_Level_Value_ID, 'T')
                  )
      AND NVL(BISBV_TARGETS.DIM5_LEVEL_VALUE_ID, 'T')
          = DECODE( x_Target_Rec.Dim5_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(x_Target_Rec.Dim5_Level_Value_ID, 'T')
                  )
      AND NVL(BISBV_TARGETS.DIM6_LEVEL_VALUE_ID, 'T')
          = DECODE( x_Target_Rec.Dim6_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(x_Target_Rec.Dim6_Level_Value_ID, 'T')
                  )
      AND NVL(BISBV_TARGETS.DIM7_LEVEL_VALUE_ID, 'T')
          = DECODE( x_Target_Rec.Dim7_Level_Value_ID
                  , FND_API.G_MISS_CHAR
                  , 'T'
                  , NVL(x_Target_Rec.Dim7_Level_Value_ID, 'T')
                  )
      ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
--
--commented RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --added more params and changed the message
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_INVALID_TARGET_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name => 'BIS_TARGET_PVT.GetID'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.GetID:NO_DATA_FOUND'); htp.para;
    END IF;
   -- RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.GetID:G_EXC_ERROR'); htp.para;
    END IF;
  --  RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.GetID:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
  --  RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.GetID:OTHERS'); htp.para;
    END IF;
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END GetID;
--
--
-- Deletes one target for a specific set of dimension values for
-- one target level
PROCEDURE Delete_Target
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2 := FND_API.G_FALSE
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Target_Rec      BIS_TARGET_PUB.Target_Rec_Type;
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error_Tbl_p     BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  -- validate if record can be deleted (no children etc.)
  -- get the ID if its not given in the record
  GetID
  ( p_api_version      => p_api_version
  , p_Target_Rec       => p_Target_Rec
  , x_Target_Rec       => l_Target_Rec
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_Tbl
  );
  --
  IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  DELETE FROM BIS_TARGET_VALUES
  WHERE TARGET_ID = l_Target_Rec.TARGET_ID;

  if SQL%NOTFOUND then
     RAISE NO_DATA_FOUND;
  end if;
--
--commented RAISE
EXCEPTION
  --added this
   WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --added more params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name  => 'BIS_INVALID_TARGET_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name => 'BIS_TARGET_PVT.Delete_Target'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Delete_Target:G_EXC_ERROR'); htp.para;
    END IF;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Delete_Target:G_EXC_UNEXPECTED_ERROR'); htp.para;
    END IF;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Delete_Target:OTHERS'); htp.para;
    END IF;
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Delete_Target;
--
--
-- Validates target record
PROCEDURE Validate_Target
( p_api_version      IN  NUMBER
, p_is_dbimeasure    IN  NUMBER := 0 --added by gbhaloti #3148615
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_return_status   VARCHAR2(10);
l_error_Tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error_Tbl_p     BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error     VARCHAR2(10) := FND_API.G_FALSE;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  -- htp.header(5,'in validate target '||p_target_rec.target_level_id||'<BR>');
  BEGIN

    -- dbms_output.put_line( ' Inside pvt : 41 ' || l_error );

    BIS_TARGET_VALIDATE_PVT.Validate_Target_Level_ID
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => x_error_Tbl
    );
    -- htp.header(5,'target level: '||l_return_status||'<BR>');
    --

        -- dbms_output.put_line( ' Inside pvt : 42 '  || l_error );

  --EXCEPTION
    --WHEN FND_API.G_EXC_ERROR THEN
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
       l_error_Tbl_p := x_error_Tbl;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;

    -- dbms_output.put_line( ' Inside pvt : 43 '  || l_error );

  END;
  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Plan_ID
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );

   IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;

  -- dbms_output.put_line( ' Inside pvt : 44 ' || l_error  );

  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Dim1_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;


  -- dbms_output.put_line( ' Inside pvt : 45 '  || l_error );

  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Dim2_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --

  --EXCEPTION
   -- WHEN FND_API.G_EXC_ERROR THEN
    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
      END IF;
  END;

  -- dbms_output.put_line( ' Inside pvt : 46 '  || l_error );

  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Dim3_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --

  --EXCEPTION
   -- WHEN FND_API.G_EXC_ERROR THEN
    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;

  -- dbms_output.put_line( ' Inside pvt : 46.1 '  || l_error );

  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Dim4_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --

  --EXCEPTION
    --WHEN FND_API.G_EXC_ERROR THEN
    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;


  -- dbms_output.put_line( ' Inside pvt : 46.2 '  || l_error );


  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Dim5_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --

 -- EXCEPTION
   -- WHEN FND_API.G_EXC_ERROR THEN
    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;


  -- dbms_output.put_line( ' Inside pvt : 46.3 '  || l_error );



  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Dim6_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --

  --EXCEPTION
    --WHEN FND_API.G_EXC_ERROR THEN
    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;

  -- dbms_output.put_line( ' Inside pvt : 46.4 '  || l_error );


  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Dim7_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --

 -- EXCEPTION
   -- WHEN FND_API.G_EXC_ERROR THEN
    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Target_Value
    ( p_api_version     => p_api_version
    , p_is_dbimeasure   => p_is_dbimeasure --added by gbhaloti #3148615
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );

    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;

  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Range1_Low
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --

    IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;
  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Range1_High
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --

   IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;
  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Range2_Low
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
   IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
     l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;
  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Range2_High
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --

   IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;

  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Range3_Low
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
   IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;
  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Range3_High
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
   IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
     l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;
  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Notify_Resp1_ID
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
   IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
     l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;
  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Notify_Resp1
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
   IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;
  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Notify_Resp2_ID
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --

   IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;
  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Notify_Resp2
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --

   IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;
  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Notify_Resp3_ID
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --

--  EXCEPTION
  --  WHEN FND_API.G_EXC_ERROR THEN
   IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
     l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;
  --
  BEGIN
    BIS_TARGET_VALIDATE_PVT.Validate_Notify_Resp3
    ( p_api_version     => p_api_version
    , p_Target_Rec      => p_Target_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
   IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
     l_error := FND_API.G_TRUE;
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    END IF;
  END;

  -- dbms_output.put_line( ' Inside pvt : 49 '  || l_error );

  --added this check
 if (l_error = FND_API.G_TRUE) then
    RAISE FND_API.G_EXC_ERROR;
  end if;
  --

  -- dbms_output.put_line( ' Inside pvt : 49.9 ' || l_error  );

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Validate_Target:G_EXC_ERROR'); htp.para;
    END IF;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Validate_Target:G_EXC_UNEXPECTED_ERROR');
      htp.para;
    END IF;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Validate_Target:OTHERS'); htp.para;
    END IF;
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Target;
--
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version   IN  NUMBER
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, x_Target_Rec    IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_Tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status:= FND_API.G_RET_STS_SUCCESS;
  x_Target_Rec := p_Target_Rec;
--
--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Value_ID_Conversion:G_EXC_ERROR'); htp.para;
    END IF;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Value_ID_Conversion:G_EXC_UNEXPECTED_ERROR');
      htp.para;
    END IF;
  --  RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Value_ID_Conversion:OTHERS'); htp.para;
    END IF;
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Value_ID_Conversion;
--
--
PROCEDURE Update_db_Target
( p_Target_Rec    BIS_TARGET_PUB.Target_Rec_Type
, x_Target_Rec    IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_Target_Rec    BIS_TARGET_PUB.Target_Rec_Type;
l_return_status VARCHAR2(10);
l_error_Tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  -- retrieve record from db
  BIS_TARGET_PVT.Retrieve_Target
  ( p_api_version   => 1.0
  , p_Target_Rec    => p_Target_Rec
  , x_Target_Rec    => l_Target_Rec
  , x_return_status => l_return_status
  , x_error_Tbl     => x_error_Tbl
  );
  -- apply changes
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Target_Level_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Target_Rec.Target_Level_ID := p_Target_Rec.Target_Level_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Plan_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Target_Rec.Plan_ID := p_Target_Rec.Plan_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Org_Level_Value_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Target_Rec.Org_Level_Value_ID := p_Target_Rec.Org_Level_Value_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Time_Level_Value_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Target_Rec.Time_Level_Value_ID := p_Target_Rec.Time_Level_Value_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Dim1_Level_Value_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Target_Rec.Dim1_Level_Value_ID := p_Target_Rec.Dim1_Level_Value_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Dim2_Level_Value_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Target_Rec.Dim2_Level_Value_ID := p_Target_Rec.Dim2_Level_Value_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Dim3_Level_Value_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Target_Rec.Dim3_Level_Value_ID := p_Target_Rec.Dim3_Level_Value_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Dim4_Level_Value_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Target_Rec.Dim4_Level_Value_ID := p_Target_Rec.Dim4_Level_Value_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Dim5_Level_Value_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Target_Rec.Dim5_Level_Value_ID := p_Target_Rec.Dim5_Level_Value_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Dim6_Level_Value_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Target_Rec.Dim6_Level_Value_ID := p_Target_Rec.Dim6_Level_Value_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Dim7_Level_Value_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Target_Rec.Dim7_Level_Value_ID := p_Target_Rec.Dim7_Level_Value_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Target)
      = FND_API.G_TRUE
    ) THEN
    l_Target_Rec.Target := p_Target_Rec.Target;
  END IF;
  --
  l_Target_Rec.Range1_low := p_Target_Rec.Range1_low;
  l_Target_Rec.Range1_high := p_Target_Rec.Range1_high;
  l_Target_Rec.Range2_low := p_Target_Rec.Range2_low;
  l_Target_Rec.Range2_high := p_Target_Rec.Range2_high;
  l_Target_Rec.Range3_low := p_Target_Rec.Range3_low;
  l_Target_Rec.Range3_high := p_Target_Rec.Range3_high;
  l_Target_Rec.Notify_Resp1_ID := p_Target_Rec.Notify_Resp1_ID;
  l_Target_Rec.Notify_Resp1_Short_Name := p_Target_Rec.Notify_Resp1_Short_Name;
  l_Target_Rec.Notify_Resp2_ID := p_Target_Rec.Notify_Resp2_ID;
  l_Target_Rec.Notify_Resp2_Short_Name := p_Target_Rec.Notify_Resp2_Short_Name;
  l_Target_Rec.Notify_Resp3_ID := p_Target_Rec.Notify_Resp3_ID;
  l_Target_Rec.Notify_Resp3_Short_Name := p_Target_Rec.Notify_Resp3_Short_Name;
  --
--added this
x_Target_Rec := l_Target_Rec;
--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Update_db_Target:G_EXC_ERROR'); htp.para;
    END IF;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Update_db_Target:G_EXC_UNEXPECTED_ERROR');
      htp.para;
    END IF;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Update_db_Target:OTHERS'); htp.para;
    END IF;
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Update_db_Target;
--
--
PROCEDURE Retrieve_Last_Update_Date
( p_api_version      IN  NUMBER
, p_Target_Rec       IN  BIS_TARGET_PUB.Target_Rec_Type
, x_last_update_date OUT NOCOPY DATE
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Rec.Target_ID)
      = FND_API.G_TRUE
      AND p_Target_Rec.Target_ID IS NOT NULL
    ) THEN
    SELECT NVL(LAST_UPDATE_DATE, CREATION_DATE)
    INTO x_last_update_date
    FROM BIS_TARGET_VALUES bis_target_values
    WHERE bis_target_values.TARGET_ID = p_Target_Rec.Target_ID;
  ELSE
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --

--commented RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     --added this message
     l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_TARGET_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Last_Update_Date'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Last_Update_Date:NO_DATA_FOUND');
      htp.para;
    END IF;
    --RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Last_Update_Date:G_EXC_ERROR');
      htp.para;
    END IF;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p
      ('BIS_TARGET_PVT.Retrieve_Last_Update_Date:G_EXC_UNEXPECTED_ERROR');
      htp.para;
    END IF;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Last_Update_Date:OTHERS'); htp.para;
    END IF;
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Retrieve_Last_Update_Date;
--
--
PROCEDURE Lock_Record
( p_api_version   IN  NUMBER
, p_Target_Rec    IN  BIS_TARGET_PUB.Target_Rec_Type
, p_timestamp     IN  VARCHAR  := NULL
, x_result        OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_form_date        DATE;
l_last_update_date DATE;
l_Target_Rec       BIS_TARGET_PUB.Target_Rec_Type;
l_error_Tbl_p      BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  l_Target_Rec.Target_ID := p_Target_Rec.Target_ID;
  BIS_TARGET_PVT.Retrieve_Last_Update_Date
                 ( p_api_version      => 1.0
                 , p_Target_Rec       => l_Target_Rec
                 , x_last_update_date => l_last_update_date
                 , x_return_status    => x_return_status
                 , x_error_Tbl        => x_error_Tbl
                 );
  IF(p_timestamp IS NOT NULL) THEN
    l_form_date := TO_DATE(p_timestamp, BIS_UTILITIES_PVT.G_DATE_FORMAT);
    IF(l_form_date = l_last_update_date) THEN
      x_result := FND_API.G_TRUE;
    ELSE
      x_result := FND_API.G_FALSE;
    END IF;
  ELSE
    x_result := FND_API.G_FALSE;
  END IF;
  --

--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    x_result := FND_API.G_FALSE;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Lock_Record:G_EXC_ERROR'); htp.para;
    END IF;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    x_result := FND_API.G_FALSE;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Lock_Record:G_EXC_UNEXPECTED_ERROR');
      htp.para;
    END IF;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    x_result := FND_API.G_FALSE;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Lock_Record:OTHERS'); htp.para;
    END IF;
  --  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Lock_Record;
--
--
PROCEDURE Retrieve_Measure_Dim_Values
( p_api_version         IN  NUMBER
, p_Target_Level_Rec    IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_User_ID             IN  NUMBER   := NULL
, p_User_Name           IN  VARCHAR2 := NULL
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_ind2                 NUMBER;
l_user_id              NUMBER(15);
l_Target_Level_Rec     BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_Dimension_Level_Rec  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
l_Measure_Security_Tbl BIS_MEASURE_SECURITY_PUB.Measure_Security_Tbl_Type;
l_Responsibility_Tbl   BIS_RESPONSIBILITY_PVT.Responsibility_Tbl_Type;
l_Dim_Level_Value_Tbl  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
l_error_tbl            BIS_UTILITIES_PUB.Error_Tbl_Type;

--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF(p_User_ID IS NULL AND p_User_Name IS NOT NULL) THEN
    SELECT user_id
    INTO l_user_id
    FROM FND_USER
    WHERE user_name = p_User_Name;
  ELSE
    l_user_id := p_User_ID;
  END IF;
  --
  BIS_TARGET_LEVEL_PUB.Retrieve_Target_Level
  ( p_api_version      => 1.0
  , p_Target_Level_Rec => p_Target_Level_Rec
  , p_all_info         => FND_API.G_FALSE
  , x_Target_Level_Rec => l_Target_Level_Rec
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_Tbl
  );
  --
  BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level
  ( p_api_version         => 1.0
  , p_Dimension_Level_Rec => p_Dimension_Level_Rec
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );
  --
    BIS_DIM_LEVEL_VALUE_PVT.Get_DimensionX_Values
    ( p_api_version         => 1.0
    , p_Dimension_Level_Rec => l_Dimension_Level_Rec
    , x_Dim_Level_Value_Tbl => x_Dim_Level_Value_Tbl
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
    --
    -- populate error table if there are no rows in the out NOCOPY table
    IF(x_Dim_Level_Value_Tbl.COUNT = 0) THEN
      --added more params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name  => 'BIS_NO_DIMX_ACCESS'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name => 'BIS_TARGET_PVT.Retrieve_Measure_Dim_Values'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
    END IF;

--commented RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Measure_Dim_Values:NO_DATA_FOUND');
      htp.para;
    END IF;
  --  RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Measure_Dim_Values:G_EXC_ERROR');
      htp.para;
    END IF;
  --  RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p
     ('BIS_TARGET_PVT.Retrieve_Measure_Dim_Values:G_EXC_UNEXPECTED_ERROR');
      htp.para;

    END IF;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.Retrieve_Measure_Dim_Values:OTHERS'); htp.para;
    END IF;
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Retrieve_Measure_Dim_Values;
--
--
PROCEDURE GetQueryStatement
( p_Select_clause   IN  VARCHAR2
, p_from_clause     IN  VARCHAR2
, p_where_clause    IN  VARCHAR2
, p_order_by_clause IN  VARCHAR2
, x_query_statement OUT NOCOPY VARCHAR2
)
IS
BEGIN
  x_query_statement := p_select_clause
                       || p_from_clause
                       || p_where_clause
                       || p_order_by_clause;
--
--commented RAISE
EXCEPTION
  WHEN OTHERS THEN
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.GetQueryStatement'); htp.para;
    END IF;
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GetQueryStatement;
--
--

PROCEDURE GetViewNames
( p_target_level_id IN  VARCHAR2
, x_org_view_name  OUT NOCOPY VARCHAR2
, x_time_view_name  OUT NOCOPY VARCHAR2
, x_dim1_view_name  OUT NOCOPY VARCHAR2
, x_dim2_view_name  OUT NOCOPY VARCHAR2
, x_dim3_view_name  OUT NOCOPY VARCHAR2
, x_dim4_view_name  OUT NOCOPY VARCHAR2
, x_dim5_view_name  OUT NOCOPY VARCHAR2
, x_dim6_view_name  OUT NOCOPY VARCHAR2
, x_dim7_view_name  OUT NOCOPY VARCHAR2
)
IS
--
l_bisbv_target_levels BISBV_TARGET_LEVELS%ROWTYPE;
--
BEGIN
  -- retrieve the target level record
  SELECT *
  INTO l_bisbv_target_levels
  FROM BISBV_TARGET_LEVELS
  WHERE TARGET_LEVEL_ID = TO_NUMBER(p_target_level_id);
  --
  -- retrieve the Org level view name
  IF(l_bisbv_target_levels.ORG_LEVEL_ID IS NOT NULL) THEN
    SELECT bisbv_dimension_levels.LEVEL_VALUES_VIEW_NAME
    INTO x_org_view_name
    FROM
      BISBV_DIMENSION_LEVELS bisbv_dimension_levels
    WHERE bisbv_dimension_levels.DIMENSION_LEVEL_ID
          = l_bisbv_target_levels.ORG_LEVEL_ID;
  END IF;
  --
  -- retrieve the Time level view name
  IF(l_bisbv_target_levels.TIME_LEVEL_ID IS NOT NULL) THEN
    SELECT bisbv_dimension_levels.LEVEL_VALUES_VIEW_NAME
    INTO x_time_view_name
    FROM
      BISBV_DIMENSION_LEVELS bisbv_dimension_levels
    WHERE bisbv_dimension_levels.DIMENSION_LEVEL_ID
          = l_bisbv_target_levels.TIME_LEVEL_ID;
  END IF;
  --
  -- retrieve the dim1 level view name
  IF(l_bisbv_target_levels.DIMENSION1_LEVEL_ID IS NOT NULL) THEN
    SELECT bisbv_dimension_levels.LEVEL_VALUES_VIEW_NAME
    INTO x_dim1_view_name
    FROM
      BISBV_DIMENSION_LEVELS bisbv_dimension_levels
    WHERE bisbv_dimension_levels.DIMENSION_LEVEL_ID
          = l_bisbv_target_levels.DIMENSION1_LEVEL_ID;
  END IF;
  --
  -- retrieve the dim2 level view name
  IF(l_bisbv_target_levels.DIMENSION2_LEVEL_ID IS NOT NULL) THEN
    SELECT bisbv_dimension_levels.LEVEL_VALUES_VIEW_NAME
    INTO x_dim2_view_name
    FROM
      BISBV_DIMENSION_LEVELS bisbv_dimension_levels
    WHERE bisbv_dimension_levels.DIMENSION_LEVEL_ID
          = l_bisbv_target_levels.DIMENSION2_LEVEL_ID;
  END IF;
  --
  -- retrieve the dim3 level view name
  IF(l_bisbv_target_levels.DIMENSION3_LEVEL_ID IS NOT NULL) THEN
    SELECT bisbv_dimension_levels.LEVEL_VALUES_VIEW_NAME
    INTO x_dim3_view_name
    FROM
      BISBV_DIMENSION_LEVELS bisbv_dimension_levels
    WHERE bisbv_dimension_levels.DIMENSION_LEVEL_ID
          = l_bisbv_target_levels.DIMENSION3_LEVEL_ID;
  END IF;
  --
  -- retrieve the dim4 level view name
  IF(l_bisbv_target_levels.DIMENSION4_LEVEL_ID IS NOT NULL) THEN
    SELECT bisbv_dimension_levels.LEVEL_VALUES_VIEW_NAME
    INTO x_dim4_view_name
    FROM
      BISBV_DIMENSION_LEVELS bisbv_dimension_levels
    WHERE bisbv_dimension_levels.DIMENSION_LEVEL_ID
          = l_bisbv_target_levels.DIMENSION4_LEVEL_ID;
  END IF;
  --
  -- retrieve the dim5 level view name
  IF(l_bisbv_target_levels.DIMENSION5_LEVEL_ID IS NOT NULL) THEN
    SELECT bisbv_dimension_levels.LEVEL_VALUES_VIEW_NAME
    INTO x_dim5_view_name
    FROM
      BISBV_DIMENSION_LEVELS bisbv_dimension_levels
    WHERE bisbv_dimension_levels.DIMENSION_LEVEL_ID
          = l_bisbv_target_levels.DIMENSION5_LEVEL_ID;
  END IF;
  -- retrieve the dim6 level view name
  IF(l_bisbv_target_levels.DIMENSION6_LEVEL_ID IS NOT NULL) THEN
    SELECT bisbv_dimension_levels.LEVEL_VALUES_VIEW_NAME
    INTO x_dim6_view_name
    FROM
      BISBV_DIMENSION_LEVELS bisbv_dimension_levels
    WHERE bisbv_dimension_levels.DIMENSION_LEVEL_ID
          = l_bisbv_target_levels.DIMENSION6_LEVEL_ID;
  END IF;
  -- retrieve the dim7 level view name
  IF(l_bisbv_target_levels.DIMENSION7_LEVEL_ID IS NOT NULL) THEN
    SELECT bisbv_dimension_levels.LEVEL_VALUES_VIEW_NAME
    INTO x_dim7_view_name
    FROM
      BISBV_DIMENSION_LEVELS bisbv_dimension_levels
    WHERE bisbv_dimension_levels.DIMENSION_LEVEL_ID
          = l_bisbv_target_levels.DIMENSION7_LEVEL_ID;
  END IF;
--
--
--commented RAISE
EXCEPTION
  WHEN OTHERS THEN
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.GetViewNames'); htp.para;
    END IF;
  --  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GetViewNames;
--
--
FUNCTION GetComputingUserFunctionName
( p_computing_function_id IN NUMBER
)
RETURN VARCHAR2
IS
--
l_user_function_name VARCHAR2(1000);
--
BEGIN
  IF(p_computing_function_id IS NULL) THEN
    l_user_function_name := NULL;
  ELSE
    BEGIN
      SELECT fnd_form_functions_tl.USER_FUNCTION_NAME
      INTO l_user_function_name
      FROM FND_FORM_FUNCTIONS_TL fnd_form_functions_tl
      WHERE fnd_form_functions_tl.FUNCTION_ID = p_computing_function_id
        AND fnd_form_functions_tl.LANGUAGE    = USERENV('LANG');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_user_function_name := NULL;
    END;
  END IF;
  --
  RETURN l_user_function_name;
--

--commented RAISE
EXCEPTION
  WHEN OTHERS THEN
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.GetComputingUserFunctionName:OTHERS');
      htp.para;
    END IF;
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GetComputingUserFunctionName;
--
--
FUNCTION GetNotifyResponsibilityName
( p_responsibility_short_name IN VARCHAR2
)
RETURN VARCHAR2
IS
--
l_resp_name VARCHAR2(1000);
--
BEGIN
  IF(p_responsibility_short_name IS NULL) THEN
    l_resp_name := NULL;
  ELSE
    SELECT wf_roles.DISPLAY_NAME
    INTO l_resp_name
    FROM WF_ROLE_LOV_VL wf_roles
    WHERE wf_roles.NAME = p_responsibility_short_name;
  END IF;
  --
  RETURN l_resp_name;
--

--commented RAISE
EXCEPTION
  WHEN OTHERS THEN
    IF(BIS_UTILITIES_PVT.G_DEBUG_FLAG = 1) THEN
      htp.p('BIS_TARGET_PVT.GetNotifyResponsibilityName:OTHERS');
      htp.para;
    END IF;
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GetNotifyResponsibilityName;
--
--
FUNCTION GetSetOfBookID
RETURN VARCHAR2
IS
BEGIN

  Return BIS_TARGET_PVT.G_SET_OF_BOOK_ID;

END GetSetOfBookID;
--
--
FUNCTION Get_Target
( p_computing_function_id  IN NUMBER
, p_target_rec             IN BIS_TARGET_PUB.Target_Rec_Type
)
RETURN NUMBER
IS
  l_target                     NUMBER;
  l_computed_target_short_name FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;
  l_target_level_short_name    VARCHAR2(32000);
  l_target_level_name          VARCHAR2(32000);
  l_plan_short_name            VARCHAR2(32000);
  l_plan_name                  VARCHAR2(32000);
  l_Org_Level_Value_name       VARCHAR2(32000);
  l_Time_Level_Value_name      VARCHAR2(32000);
  l_Dim1_Level_Value_name      VARCHAR2(32000);
  l_Dim2_Level_Value_name      VARCHAR2(32000);
  l_Dim3_Level_Value_name      VARCHAR2(32000);
  l_Dim4_Level_Value_name      VARCHAR2(32000);
  l_Dim5_Level_Value_name      VARCHAR2(32000);
  l_Dim6_Level_Value_name      VARCHAR2(32000);
  l_Dim7_Level_Value_name      VARCHAR2(32000);
  l_Org_Level_Value_id         VARCHAR2(32000);
  l_Time_Level_Value_id        VARCHAR2(32000);
  l_Dim1_Level_Value_id        VARCHAR2(32000);
  l_Dim2_Level_Value_id        VARCHAR2(32000);
  l_Dim3_Level_Value_id        VARCHAR2(32000);
  l_Dim4_Level_Value_id        VARCHAR2(32000);
  l_Dim5_Level_Value_id        VARCHAR2(32000);
  l_Dim6_Level_Value_id        VARCHAR2(32000);
  l_Dim7_Level_Value_id        VARCHAR2(32000);

  l_cursor      INTEGER;
  l_stmt        VARCHAR2(32000);
  l_sql_result  INTEGER := 0;

BEGIN

  Select FUNCTION_NAME
  into l_computed_target_short_name
  from fnd_form_functions_vl
  where function_id = p_computing_function_id;

  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.target_level_short_name
  , l_target_level_short_name
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.target_level_name
  , l_target_level_name
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.plan_short_name
  , l_plan_short_name
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.plan_name
  , l_plan_name
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Org_Level_Value_ID
  , l_Org_Level_Value_ID
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Org_Level_Value_name
  , l_Org_Level_Value_name
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Time_Level_Value_ID
  , l_Time_Level_Value_ID
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Time_Level_Value_name
  , l_Time_Level_Value_name
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim1_Level_Value_ID
  , l_Dim1_Level_Value_ID
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim1_Level_Value_name
  , l_Dim1_Level_Value_name
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim2_Level_Value_ID
  , l_Dim2_Level_Value_ID
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim2_Level_Value_name
  , l_Dim2_Level_Value_name
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim3_Level_Value_ID
  , l_Dim3_Level_Value_ID
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim3_Level_Value_name
  , l_Dim3_Level_Value_name
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim4_Level_Value_ID
  , l_Dim4_Level_Value_ID
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim4_Level_Value_name
  , l_Dim4_Level_Value_name
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim5_Level_Value_ID
  , l_Dim5_Level_Value_ID
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim5_Level_Value_name
  , l_Dim5_Level_Value_name
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim6_Level_Value_ID
  , l_Dim6_Level_Value_ID
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim6_Level_Value_name
  , l_Dim6_Level_Value_name
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim7_Level_Value_ID
  , l_Dim7_Level_Value_ID
  );
  BIS_UTILITIES_PVT.Replace_String
  ( p_target_rec.Dim7_Level_Value_name
  , l_Dim7_Level_Value_name
  );

  l_stmt :=
    'Declare '||
    '  l_target_rec BIS_TARGET_PUB.Target_Rec_Type; '||
    'Begin '||
    '  l_target_rec.Target_ID := ' || -- p_target_rec.Target_id||';'||
             nvl( to_char(p_target_rec.Target_id) , 'null') || ' ; ' ||
    '  l_target_rec.Target_Level_ID := '||p_target_rec.Target_Level_ID||';'||
    '  l_target_rec.Target_Level_Short_Name := '
         ||l_target_level_short_name||';'||
    '  l_target_rec.Target_Level_Name := '||l_Target_Level_Name||';'||
    '  l_target_rec.Plan_ID := '||p_target_rec.Plan_ID||';'||
    '  l_target_rec.Plan_Short_Name := '||l_Plan_Short_Name||';'||
    '  l_target_rec.Plan_Name := '||l_Plan_Name||';'||
    '  l_target_rec.Org_Level_Value_ID := '||l_Org_Level_Value_ID||';'||
    '  l_target_rec.Org_Level_Value_Name := '||l_Org_Level_Value_Name||';'||
    '  l_target_rec.Time_Level_Value_ID := '||l_Time_Level_Value_ID||';'||
    '  l_target_rec.Time_Level_Value_Name := '||l_Time_Level_Value_Name||';'||
    '  l_target_rec.Dim1_Level_Value_ID := '||l_Dim1_Level_Value_ID||';'||
    '  l_target_rec.Dim1_Level_Value_Name := '||l_Dim1_Level_Value_Name||';'||
    '  l_target_rec.Dim2_Level_Value_ID := '||l_Dim2_Level_Value_ID||';'||
    '  l_target_rec.Dim2_Level_Value_Name := '||l_Dim2_Level_Value_Name||';'||
    '  l_target_rec.Dim3_Level_Value_ID := '||l_Dim3_Level_Value_ID||';'||
    '  l_target_rec.Dim3_Level_Value_Name := '||l_Dim3_Level_Value_Name||';'||
    '  l_target_rec.Dim4_Level_Value_ID := '||l_Dim4_Level_Value_ID||';'||
    '  l_target_rec.Dim4_Level_Value_Name := '||l_Dim4_Level_Value_Name||';'||
    '  l_target_rec.Dim5_Level_Value_ID := '||l_Dim5_Level_Value_ID||';'||
    '  l_target_rec.Dim5_Level_Value_Name := '||l_Dim5_Level_Value_Name||';'||
    '  l_target_rec.Dim6_Level_Value_ID := '||l_Dim6_Level_Value_ID||';'||
    '  l_target_rec.Dim6_Level_Value_Name := '||l_Dim6_Level_Value_Name||';'||
    '  l_target_rec.Dim7_Level_Value_ID := '||l_Dim7_Level_Value_ID||';'||
    '  l_target_rec.Dim7_Level_Value_Name := '||l_Dim7_Level_Value_Name||';'||
    '  :l_target := '||l_computed_target_short_name||
    '                  ( l_target_rec ); '||
    'End; ' ;

  l_cursor := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE( c             => l_cursor
                , statement     => l_stmt
                , language_flag => DBMS_SQL.NATIVE
                );
  DBMS_SQL.BIND_VARIABLE(l_cursor, ':l_target', l_target);
  l_sql_result := DBMS_SQL.EXECUTE(l_cursor);
  DBMS_SQL.VARIABLE_VALUE(l_cursor, ':l_target', l_target);

  IF(DBMS_SQL.IS_OPEN(l_cursor)) THEN
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
  END IF;

  RETURN l_target;

--commented RAISE
EXCEPTION
   WHEN OTHERS THEN
     -- htp.header(5,'Exception in Get Target');
     htp.p(SQLERRM);
    -- RAISE;

END Get_Target;
--
--
FUNCTION Get_Target
( p_computing_function_id  IN NUMBER
, p_target_level_id        IN NUMBER
)
RETURN NUMBER
IS
  l_target                 NUMBER;
  l_target_rec             BIS_TARGET_PUB.Target_Rec_Type;
BEGIN

  l_target_rec.target_level_id := p_target_level_id;
  l_target := Get_Target
            ( p_computing_function_id  => p_computing_function_id
            , p_target_rec             => l_target_rec
            );
  RETURN l_target;

END Get_Target;
--
--
FUNCTION getValue
( p_id             VARCHAR2
, p_value_id_table BIS_LOV_PVT.Value_Id_Table
)
return varchar2
IS
BEGIN
  -- SHOULD USE BINARY SEARCH AS IDs ARE SORTED. BEING LAZY
--  dbms_output.put_line('input id = '||p_id);
  for i in 1 .. p_value_id_table.count loop
--    dbms_output.put_line('testing id '||p_value_id_table(i).id);
    if (p_id = p_value_id_table(i).id) then
--      dbms_output.put_line('returning '||p_value_id_table(i).value);
      return p_value_id_table(i).value;
      exit;
    end if;
  end loop;
  return null;
END getValue;

PROCEDURE RetrieveValues
( p_view_name      IN  VARCHAR2
, p_where_clause   IN  VARCHAR2
, x_value_id_table OUT NOCOPY BIS_LOV_PVT.Value_Id_Table
)
IS
l_query VARCHAR2(32000);
l_sql_result          INTEGER := 0;

l_size                     NUMBER := 100000;
l_retrieved                NUMBER;
l_cursor              INTEGER;
l_level_value     DBMS_SQL.VARCHAR2_TABLE;
l_level_id        DBMS_SQL.VARCHAR2_TABLE;
l_rec             BIS_LOV_PVT.Value_Id_record;
BEGIN
  l_query := 'select distinct id, value from '||p_view_name||' '||p_where_clause || ' order by id';
--dbms_output.put_line(l_query);

  l_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE( c             => l_cursor
                , statement     => l_query
                , language_flag => DBMS_SQL.NATIVE
                );
  DBMS_SQL.DEFINE_ARRAY(l_cursor, 1, l_level_id, l_size, 1);
  DBMS_SQL.DEFINE_ARRAY(l_cursor, 2, l_level_value, l_size, 1);
  l_sql_result := DBMS_SQL.EXECUTE(l_cursor);
  LOOP
    l_retrieved := DBMS_SQL.FETCH_ROWS(l_cursor);
    EXIT WHEN l_retrieved = 0;
    -- retrieve the values into vars
    DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_level_id);
    DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_level_value);
    --
    FOR l_ind1 IN 1..l_level_id.COUNT LOOP
      l_rec.id := l_level_id(l_ind1);
      l_rec.value := l_level_value(l_ind1);
      x_value_id_table(x_value_id_table.count+1) := l_rec;
--      dbms_output.put_line(l_rec.id||'     '||l_rec.value);
    END LOOP;
    --
    EXIT WHEN l_retrieved < l_size;
  END LOOP;
END RetrieveValues;

Function getDate(p_query VARCHAR2)
return DATE
IS
l_cursor   INTEGER;
l_date     DATE;
l_dummy    INTEGER;
BEGIN
  l_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE( c             => l_cursor
                , statement     => p_query
                , language_flag => DBMS_SQL.NATIVE
                );

  dbms_sql.define_column(l_cursor, 1, l_date);
  l_dummy := DBMS_SQL.EXECUTE(l_cursor);

  loop
    if (dbms_sql.fetch_rows(l_cursor) = 0) then
      exit;
    end if;

    dbms_sql.column_value(l_cursor, 1, l_date);
  end loop;

  return l_date;
END getDate;

Function getStartDate
( p_view_name IN VARCHAR2
, p_time_from IN  VARCHAR2
)
return DATE
IS
l_query    VARCHAR2(32000);
BEGIN
  l_query := 'select start_date from '|| p_view_name;
  l_query := l_query || ' where id like ''' ||p_time_from||'''';

  return getDate(l_query);
END getStartDate;

Function getEndDate
( p_view_name IN VARCHAR2
, p_time_to   IN  VARCHAR2
)
return DATE
IS
l_query    VARCHAR2(32000);
BEGIN
  l_query := 'select end_date from '|| p_view_name;
  l_query := l_query || ' where id like ''' ||p_time_to||'''';

  return getDate(l_query);
END getEndDate;

-- Retrieves the time level values for the given target
--
PROCEDURE Retrieve_Time_level_value
( p_api_version         IN  NUMBER
, p_Target_Rec          IN  BIS_Target_PUB.Target_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_dimension_level_number OUT NOCOPY NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_dimension_level_number   NUMBER;
  l_target_level_rec    BIS_Target_Level_PUB.Target_Level_rec_Type;
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim_level_value_tbl BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;


  CURSOR cr_tar_dim_value(p_target_id NUMBER) IS
    select
      dim1_level_value_id,
      dim2_level_value_id,
      dim3_level_value_id,
      dim4_level_value_id,
      dim5_level_value_id,
      dim6_level_value_id,
      dim7_level_value_id
    from bisbv_targets
    where target_id = p_target_id;

BEGIN

  --BIS_UTILITIES_PUB.put_line(p_text =>'in Retrieve_Time_level_value. target level: '
  --||p_Target_Rec.target_level_id
  --||', target id: '||p_Target_Rec.target_id
  --);

  l_target_level_rec.target_level_id := p_Target_Rec.target_level_id;

  BIS_TARGET_LEVEL_PVT.Retrieve_Time_level
  ( p_api_version         => 1.0
  , p_Target_Level_Rec    => l_Target_Level_Rec
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_dimension_level_number => l_dimension_level_number
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

 -- Following change is to get the Level info if there is no value too

 x_Dim_Level_Value_Rec.Dimension_Level_id := l_Dimension_Level_Rec.Dimension_Level_id;
 x_Dim_Level_Value_Rec.Dimension_Level_short_name := l_Dimension_Level_Rec.Dimension_Level_short_name;
 x_Dim_Level_Value_Rec.Dimension_Level_name := l_Dimension_Level_Rec.Dimension_Level_name;

 x_dimension_level_number := l_dimension_level_number;

  --BIS_UTILITIES_PUB.put_line(p_text =>'retrieved time level: '||l_Dimension_Level_Rec.Dimension_Level_id
  --||', time level number: '||l_dimension_level_number);

  IF (BIS_UTILITIES_PVT.Value_Not_Missing(p_Target_Rec.target_id)
      = FND_API.G_TRUE)
  AND (BIS_UTILITIES_PVT.Value_Not_Null(p_Target_Rec.target_id)
      = FND_API.G_TRUE)
  THEN
    OPEN cr_tar_dim_value(p_Target_Rec.target_id);
    FETCH cr_tar_dim_value INTO
      l_dim_level_value_tbl(1).dimension_level_value_id,
      l_dim_level_value_tbl(2).dimension_level_value_id,
      l_dim_level_value_tbl(3).dimension_level_value_id,
      l_dim_level_value_tbl(4).dimension_level_value_id,
      l_dim_level_value_tbl(5).dimension_level_value_id,
      l_dim_level_value_tbl(6).dimension_level_value_id,
      l_dim_level_value_tbl(7).dimension_level_value_id;

      --added this
      if cr_tar_dim_value%NOTFOUND then
        --added this message
	l_error_tbl := x_error_tbl;
        BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_TARGET_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Time_Level_Value'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
       );
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
      end if;
    CLOSE cr_tar_dim_value;

  END IF;

  FOR i IN 1..l_dim_level_value_tbl.COUNT LOOP
    --BIS_UTILITIES_PUB.put_line(p_text =>'i: '||i);
    IF i = l_dimension_level_number THEN
      --BIS_UTILITIES_PUB.put_line(p_text =>'got period: '
      --||l_Dim_Level_Value_tbl(i).Dimension_Level_Value_id);

      l_Dim_Level_Value_tbl(i).Dimension_Level_id
        := l_Dimension_Level_Rec.Dimension_Level_id;
      l_Dim_Level_Value_tbl(i).Dimension_Level_short_name
        := l_Dimension_Level_Rec.Dimension_Level_short_name;
      l_Dim_Level_Value_tbl(i).Dimension_Level_name
        := l_Dimension_Level_Rec.Dimension_Level_name;
      x_Dim_Level_Value_Rec := l_Dim_Level_Value_tbl(i);
      x_dimension_level_number := l_dimension_level_number;
      EXIT;
    END IF;
  END LOOP;

EXCEPTION
  --added this
  WHEN FND_API.G_EXC_ERROR THEN
      BIS_UTILITIES_PUB.put_line(p_text =>'Error 1 while getting time level value: '||SQLERRM);
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF cr_tar_dim_value%ISOPEN THEN CLOSE cr_tar_dim_value; END IF;
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Error 2 while getting time level value: '||SQLERRM);
    IF cr_tar_dim_value%ISOPEN THEN CLOSE cr_tar_dim_value; END IF;
     x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
     l_error_Tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
END Retrieve_Time_level_value;

-- Retrieves the time level for the given target level
--
PROCEDURE Retrieve_Time_level_value
( p_api_version            IN  NUMBER
, p_Target_id              IN  NUMBER
, x_Dim_Level_Value_ID     OUT NOCOPY VARCHAR2
, x_Dim_Level_Value_name   OUT NOCOPY VARCHAR2
, x_dimension_level_number OUT NOCOPY NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
)
IS

  l_Target_Rec             BIS_Target_PUB.Target_Rec_Type;
  l_Dim_Level_Value_Rec    BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dimension_level_number NUMBER;
  l_error_Tbl              BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_return_status          VARCHAR2(32000);

BEGIN

  l_Target_Rec.Target_id := p_Target_id;

  Retrieve_Time_level_value
  ( p_api_version             => 1.0
  , p_Target_Rec              => l_Target_Rec
  , x_Dim_Level_Value_Rec     => l_Dim_Level_Value_Rec
  , x_dimension_level_number  => l_dimension_level_number
  , x_return_status           => x_return_status
  , x_error_Tbl               => l_error_Tbl
  );

  x_Dim_Level_Value_ID     := l_Dim_Level_Value_Rec.dimension_Level_Value_ID;
  x_Dim_Level_Value_name   := l_Dim_Level_Value_Rec.dimension_Level_Value_name;
  x_dimension_level_number := l_dimension_level_number;

END Retrieve_Time_level_value;


--
-- Retrieves the Org level values for the given target
--

PROCEDURE Retrieve_Org_level_value
( p_api_version         IN  NUMBER
, p_Target_Rec          IN  BIS_Target_PUB.Target_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_dimension_level_number OUT NOCOPY NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_dimension_level_number   NUMBER;
  l_target_level_rec    BIS_Target_Level_PUB.Target_Level_rec_Type;
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim_level_value_tbl BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
  l_error_Tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;


BEGIN


  l_target_level_rec.target_level_id := p_Target_Rec.target_level_id;

  -- BIS_UTILITIES_PUB.put_line(p_text =>' Target level id inside Retrieve_Org_level_value = ' || l_target_level_rec.target_level_id ) ;

  BIS_TARGET_LEVEL_PVT.Retrieve_Org_level
  ( p_api_version         => 1.0
  , p_Target_Level_Rec    => l_Target_Level_Rec
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_dimension_level_number => l_dimension_level_number
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );


 -- Following change is to get the Level info if there is no value too

 -- BIS_UTILITIES_PUB.put_line(p_text => ' inside bisvtarb l_Dimension_Level_Rec.DIMENSION_ID = ' || l_Dimension_Level_Rec.DIMENSION_ID ) ;

 x_Dim_Level_Value_Rec.Dimension_Level_id := l_Dimension_Level_Rec.Dimension_Level_id;
 x_Dim_Level_Value_Rec.Dimension_Level_short_name := l_Dimension_Level_Rec.Dimension_Level_short_name;
 x_Dim_Level_Value_Rec.Dimension_Level_name := l_Dimension_Level_Rec.Dimension_Level_name;

 x_dimension_level_number := l_dimension_level_number;

 l_dim_level_value_tbl(1).dimension_level_value_id := p_target_rec.dim1_level_value_id;
 l_dim_level_value_tbl(2).dimension_level_value_id := p_target_rec.dim2_level_value_id;
 l_dim_level_value_tbl(3).dimension_level_value_id := p_target_rec.dim3_level_value_id;
 l_dim_level_value_tbl(4).dimension_level_value_id := p_target_rec.dim4_level_value_id;
 l_dim_level_value_tbl(5).dimension_level_value_id := p_target_rec.dim5_level_value_id;
 l_dim_level_value_tbl(6).dimension_level_value_id := p_target_rec.dim6_level_value_id;
 l_dim_level_value_tbl(7).dimension_level_value_id := p_target_rec.dim7_level_value_id;


  FOR i IN 1..7 loop 			-- l_dim_level_value_tbl.COUNT LOOP
						    --BIS_UTILITIES_PUB.put_line(p_text =>'i: '||i);
    IF i = l_dimension_level_number THEN
						    --BIS_UTILITIES_PUB.put_line(p_text =>'got period: '
						      --||l_Dim_Level_Value_tbl(i).Dimension_Level_Value_id);

      l_Dim_Level_Value_tbl(i).Dimension_Level_id
        := l_Dimension_Level_Rec.Dimension_Level_id;
      l_Dim_Level_Value_tbl(i).Dimension_Level_short_name
        := l_Dimension_Level_Rec.Dimension_Level_short_name;
      l_Dim_Level_Value_tbl(i).Dimension_Level_name
        := l_Dimension_Level_Rec.Dimension_Level_name;
      x_Dim_Level_Value_Rec := l_Dim_Level_Value_tbl(i);
      x_dimension_level_number := l_dimension_level_number;

      EXIT;

    END IF;
  END LOOP;

EXCEPTION

  --added this
  WHEN FND_API.G_EXC_ERROR THEN

      BIS_UTILITIES_PUB.put_line(p_text =>'Error 1 while getting Org level value: '||SQLERRM);
      x_return_status := FND_API.G_RET_STS_ERROR;


  WHEN OTHERS THEN
     BIS_UTILITIES_PUB.put_line(p_text =>'Error 2 while getting Org level value: '||SQLERRM);
     x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

     l_error_Tbl_p := x_error_Tbl;
     BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );

END Retrieve_Org_level_value;



-- New Procedure to return TargetLevel given the DimensionLevel ShortNames in any sequence
-- and the Measure Short Name

PROCEDURE Retrieve_Target_From_ShNms
( p_api_version      IN  NUMBER
, p_target_level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_Target_Rec      IN BIS_TARGET_PUB.TARGET_REC_TYPE
, x_Target_Level_Rec IN OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Target_Rec       IN OUT NOCOPY BIS_TARGET_PUB.TARGET_REC_TYPE
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Target_Level_Rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_measure_rec		      BIS_MEASURE_PUB.MEASURE_REC_TYPE;
l_measure_rec_p               BIS_MEASURE_PUB.MEASURE_REC_TYPE;
l_dim_level_rec               BIS_DIMENSION_LEVEL_PUB.DIMENSION_LEVEL_REC_TYPE;
l_dim_level_value_rec       BIS_DIM_lEVEL_VALUE_PUB.DIM_LEVEL_VALUE_REC_TYPE;
l_target_level_id             NUMBER;
l_error_tbl		      BIS_UTILITIES_PUB.Error_Tbl_Type;
l_target_rec_p                BIS_TARGET_PUB.TARGET_REC_TYPE;
l_dim_level_rec_p             BIS_DIMENSION_LEVEL_PUB.DIMENSION_LEVEL_REC_TYPE;
l_dim_level_value_rec_p       BIS_DIM_lEVEL_VALUE_PUB.DIM_LEVEL_VALUE_REC_TYPE;

l_dim1_id	   	      NUMBER;
l_dim2_id		      NUMBER;
l_dim3_id		      NUMBER;
l_dim4_id		      NUMBER;
l_dim5_id		      NUMBER;
l_dim6_id		      NUMBER;
l_dim7_id		      NUMBER;
l_dim1_level_id               NUMBER;
l_dim2_level_id               NUMBER;
l_dim3_level_id               NUMBER;
l_dim4_level_id               NUMBER;
l_dim5_level_id               NUMBER;
l_dim6_level_id               NUMBER;
l_dim7_level_id               NUMBER;
l_dim1_level_value_id       VARCHAR2(32000);
l_dim2_level_value_id       VARCHAR2(32000);
l_dim3_level_value_id       VARCHAR2(32000);
l_dim4_level_value_id       VARCHAR2(32000);
l_dim5_level_value_id       VARCHAR2(32000);
l_dim6_level_value_id       VARCHAR2(32000);
l_dim7_level_value_id       VARCHAR2(32000);

l_dim1_level_short_name       VARCHAR2(32000);
l_dim2_level_short_name       VARCHAR2(32000);
l_dim3_level_short_name       VARCHAR2(32000);
l_dim4_level_short_name       VARCHAR2(32000);
l_dim5_level_short_name       VARCHAR2(32000);
l_dim6_level_short_name       VARCHAR2(32000);
l_dim7_level_short_name       VARCHAR2(32000);

l_dim1_level_name       VARCHAR2(32000);
l_dim2_level_name       VARCHAR2(32000);
l_dim3_level_name       VARCHAR2(32000);
l_dim4_level_name       VARCHAR2(32000);
l_dim5_level_name       VARCHAR2(32000);
l_dim6_level_name       VARCHAR2(32000);
l_dim7_level_name       VARCHAR2(32000);


CURSOR c_dim_lvl(p_dim_level_short_name in varchar2) IS
SELECT level_id , NVL(BIS_DIMENSION_LEVEL_PUB.GET_CUSTOMIZED_NAME(level_id),name)
FROM bis_levels_vl
WHERE short_name=p_dim_level_short_name;

BEGIN
  IF (p_target_level_rec.measure_short_name IS NOT NULL
   AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.measure_short_name) = FND_API.G_TRUE) THEN
     l_measure_rec.measure_short_name := p_target_level_rec.measure_short_name;
  END IF;
  IF (p_target_level_rec.measure_id IS NOT NULL
    AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.measure_id) = FND_API.G_TRUE) THEN
     l_measure_rec.measure_id := p_target_level_rec.measure_id;
  END IF;
  --Populate the measure record with all the relevant values
  l_measure_rec_p := l_measure_rec;
  BIS_MEASURE_PUB.RETRIEVE_MEASURE( p_api_version => p_api_version
			           ,p_measure_rec => l_measure_rec_p
			           ,p_all_info  =>FND_API.G_TRUE
				   ,x_measure_rec => l_measure_rec
                                   ,x_return_status => x_return_status
                                   ,x_error_tbl     => x_error_tbl
				   );

  IF (p_target_level_rec.dimension1_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension1_level_short_name) = FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension1_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension1_level_id,x_target_level_rec.dimension1_level_name;
     CLOSE c_dim_lvl;
  END IF;
  IF (p_target_level_rec.dimension2_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension2_level_short_name)= FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension2_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension2_level_id,x_target_level_rec.dimension2_level_name;
     CLOSE c_dim_lvl;
  END IF;
  IF (p_target_level_rec.dimension3_level_short_name IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension3_level_short_name)= FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension3_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension3_level_id,x_target_level_rec.dimension3_level_name;
     CLOSE c_dim_lvl;
  END IF;
  IF (p_target_level_rec.dimension4_level_short_name IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension4_level_short_name)= FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension4_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension4_level_id,x_target_level_rec.dimension4_level_name;
     CLOSE c_dim_lvl;
  END IF;
  IF (p_target_level_rec.dimension5_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension5_level_short_name)= FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension5_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension5_level_id,x_target_level_rec.dimension5_level_name;
     CLOSE c_dim_lvl;
  END IF;
  IF (p_target_level_rec.dimension6_level_short_name IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension6_level_short_name)= FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension6_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension6_level_id,x_target_level_rec.dimension6_level_name;
     CLOSE c_dim_lvl;
  END IF;
  IF (p_target_level_rec.dimension7_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension7_level_short_name)= FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension7_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension7_level_id,x_target_level_rec.dimension7_level_name;
     CLOSE c_dim_lvl;
  END IF;
  x_target_level_rec.measure_name := l_measure_rec.measure_name;
  x_target_level_Rec.measure_id := l_measure_rec.measure_id;

  --also return to UOM
  x_target_level_rec.Unit_Of_Measure := l_measure_rec.Unit_Of_Measure_Class;

  --Get the dimension ids for all the dimension level ids. This will be later used to
  --sequence the dimension levels
  IF (x_target_level_rec.dimension1_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension1_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension1_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
								   );
    l_dim1_id := BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (x_target_level_rec.dimension2_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension2_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension2_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                     		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
						   );
    l_dim2_id :=  BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (x_target_level_rec.dimension3_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension3_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension3_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                     		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
						   );
    l_dim3_id := BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (x_target_level_rec.dimension4_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension4_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension4_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                     		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
						   );
    l_dim4_id := BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (x_target_level_rec.dimension5_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension5_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension5_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                     		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
						   );
    l_dim5_id := BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (x_target_level_rec.dimension6_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension6_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension6_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                     		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
						   );
    l_dim6_id := BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (x_target_level_rec.dimension7_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension7_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension7_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                     		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
						   );
    l_dim7_id := BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (l_measure_rec.dimension1_id = l_dim1_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension1_level_id;
      l_dim1_level_value_id := p_target_rec.dim1_level_value_id;
      l_dim1_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension1_level_name;
  ELSIF (l_measure_rec.dimension2_id = l_dim1_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension1_level_id;
      l_dim2_level_value_id := p_target_rec.dim1_level_value_id;
      l_dim2_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension1_level_name;
  ELSIF (l_measure_rec.dimension3_id = l_dim1_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension1_level_id;
      l_dim3_level_value_id := p_target_rec.dim1_level_value_id;
      l_dim3_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension1_level_name;
  ELSIF (l_measure_rec.dimension4_id = l_dim1_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension1_level_id;
      l_dim4_level_value_id := p_target_rec.dim1_level_value_id;
      l_dim4_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension1_level_name;
  ELSIF (l_measure_rec.dimension5_id = l_dim1_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension1_level_id;
      l_dim5_level_value_id := p_target_rec.dim1_level_value_id;
      l_dim5_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension1_level_name;
  ELSIF (l_measure_rec.dimension6_id = l_dim1_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension1_level_id;
      l_dim6_level_value_id := p_target_rec.dim1_level_value_id;
      l_dim6_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension1_level_name;
  ELSIF (l_measure_rec.dimension7_id = l_dim1_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension1_level_id;
      l_dim7_level_value_id := p_target_rec.dim1_level_value_id;
      l_dim7_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension1_level_name;
  END IF;
  IF (l_measure_rec.dimension1_id = l_dim2_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension2_level_id;
      l_dim1_level_value_id := p_target_rec.dim2_level_value_id;
      l_dim1_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension2_level_name;
  ELSIF (l_measure_rec.dimension2_id = l_dim2_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension2_level_id;
      l_dim2_level_value_id := p_target_rec.dim2_level_value_id;
      l_dim2_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension2_level_name;
  ELSIF (l_measure_rec.dimension3_id = l_dim2_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension2_level_id;
      l_dim3_level_value_id := p_target_rec.dim2_level_value_id;
      l_dim3_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension2_level_name;
  ELSIF (l_measure_rec.dimension4_id = l_dim2_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension2_level_id;
      l_dim4_level_value_id := p_target_rec.dim2_level_value_id;
      l_dim4_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension2_level_name;
  ELSIF (l_measure_rec.dimension5_id = l_dim2_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension2_level_id;
      l_dim5_level_value_id := p_target_rec.dim2_level_value_id;
      l_dim5_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension2_level_name;
  ELSIF (l_measure_rec.dimension6_id = l_dim2_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension2_level_id;
      l_dim6_level_value_id := p_target_rec.dim2_level_value_id;
      l_dim6_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension2_level_name;
  ELSIF (l_measure_rec.dimension7_id = l_dim2_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension2_level_id;
      l_dim7_level_value_id := p_target_rec.dim2_level_value_id;
      l_dim7_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension2_level_name;
  END IF;
  IF (l_measure_rec.dimension1_id = l_dim3_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension3_level_id;
      l_dim1_level_value_id := p_target_rec.dim3_level_value_id;
      l_dim1_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension3_level_name;
  ELSIF (l_measure_rec.dimension2_id = l_dim3_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension3_level_id;
      l_dim2_level_value_id := p_target_rec.dim3_level_value_id;
      l_dim2_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension3_level_name;
  ELSIF (l_measure_rec.dimension3_id = l_dim3_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension3_level_id;
      l_dim3_level_value_id := p_target_rec.dim3_level_value_id;
      l_dim3_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension3_level_name;
  ELSIF (l_measure_rec.dimension4_id = l_dim3_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension3_level_id;
      l_dim4_level_value_id := p_target_rec.dim3_level_value_id;
      l_dim4_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension3_level_name;
  ELSIF (l_measure_rec.dimension5_id = l_dim3_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension3_level_id;
      l_dim5_level_value_id := p_target_rec.dim3_level_value_id;
      l_dim5_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension3_level_name;
  ELSIF (l_measure_rec.dimension6_id = l_dim3_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension3_level_id;
      l_dim6_level_value_id := p_target_rec.dim3_level_value_id;
      l_dim6_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension3_level_name;
  ELSIF (l_measure_rec.dimension7_id = l_dim3_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension3_level_id;
      l_dim7_level_value_id := p_target_rec.dim3_level_value_id;
      l_dim7_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension3_level_name;
  END IF;
  IF (l_measure_rec.dimension1_id = l_dim4_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension4_level_id;
      l_dim1_level_value_id := p_target_rec.dim4_level_value_id;
      l_dim1_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension4_level_name;
  ELSIF (l_measure_rec.dimension2_id = l_dim4_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension4_level_id;
      l_dim2_level_value_id := p_target_rec.dim4_level_value_id;
      l_dim2_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension4_level_name;
  ELSIF (l_measure_rec.dimension3_id = l_dim4_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension4_level_id;
      l_dim3_level_value_id := p_target_rec.dim4_level_value_id;
      l_dim3_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension4_level_name;
  ELSIF (l_measure_rec.dimension4_id = l_dim4_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension4_level_id;
      l_dim4_level_value_id := p_target_rec.dim4_level_value_id;
      l_dim4_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension4_level_name;
  ELSIF (l_measure_rec.dimension5_id = l_dim4_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension4_level_id;
      l_dim5_level_value_id := p_target_rec.dim4_level_value_id;
      l_dim5_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension4_level_name;
  ELSIF (l_measure_rec.dimension6_id = l_dim4_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension4_level_id;
      l_dim6_level_value_id := p_target_rec.dim4_level_value_id;
      l_dim6_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension4_level_name;
  ELSIF (l_measure_rec.dimension7_id = l_dim4_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension4_level_id;
      l_dim7_level_value_id := p_target_rec.dim4_level_value_id;
      l_dim7_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension4_level_name;
  END IF;
  IF (l_measure_rec.dimension1_id = l_dim5_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension5_level_id;
      l_dim1_level_value_id := p_target_rec.dim5_level_value_id;
      l_dim1_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension5_level_name;
  ELSIF (l_measure_rec.dimension2_id = l_dim5_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension5_level_id;
      l_dim2_level_value_id := p_target_rec.dim5_level_value_id;
      l_dim2_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension5_level_name;
  ELSIF (l_measure_rec.dimension3_id = l_dim5_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension5_level_id;
      l_dim3_level_value_id := p_target_rec.dim5_level_value_id;
      l_dim3_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension5_level_name;
  ELSIF (l_measure_rec.dimension4_id = l_dim5_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension5_level_id;
      l_dim4_level_value_id := p_target_rec.dim5_level_value_id;
      l_dim4_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension5_level_name;
  ELSIF (l_measure_rec.dimension5_id = l_dim5_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension5_level_id;
      l_dim5_level_value_id := p_target_rec.dim5_level_value_id;
      l_dim5_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension5_level_name;
  ELSIF (l_measure_rec.dimension6_id = l_dim5_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension5_level_id;
      l_dim6_level_value_id := p_target_rec.dim5_level_value_id;
      l_dim6_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension5_level_name;
  ELSIF (l_measure_rec.dimension7_id = l_dim5_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension5_level_id;
      l_dim7_level_value_id := p_target_rec.dim5_level_value_id;
      l_dim7_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension5_level_name;
  END IF;
  IF (l_measure_rec.dimension1_id = l_dim6_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension6_level_id;
      l_dim1_level_value_id := p_target_rec.dim6_level_value_id;
      l_dim1_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension6_level_name;
  ELSIF (l_measure_rec.dimension2_id = l_dim6_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension6_level_id;
      l_dim2_level_value_id := p_target_rec.dim6_level_value_id;
      l_dim2_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension6_level_name;
  ELSIF (l_measure_rec.dimension3_id = l_dim6_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension6_level_id;
      l_dim3_level_value_id := p_target_rec.dim6_level_value_id;
      l_dim3_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension6_level_name;
  ELSIF (l_measure_rec.dimension4_id = l_dim6_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension6_level_id;
      l_dim4_level_value_id := p_target_rec.dim6_level_value_id;
      l_dim4_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension6_level_name;
  ELSIF (l_measure_rec.dimension5_id = l_dim6_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension6_level_id;
      l_dim5_level_value_id := p_target_rec.dim6_level_value_id;
      l_dim5_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension6_level_name;
  ELSIF (l_measure_rec.dimension6_id = l_dim6_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension6_level_id;
      l_dim6_level_value_id := p_target_rec.dim6_level_value_id;
      l_dim6_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension6_level_name;
  ELSIF (l_measure_rec.dimension7_id = l_dim6_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension6_level_id;
      l_dim7_level_value_id := p_target_rec.dim6_level_value_id;
      l_dim7_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension6_level_name;
  END IF;
  IF (l_measure_rec.dimension1_id = l_dim7_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension7_level_id;
      l_dim1_level_value_id := p_target_rec.dim7_level_value_id;
      l_dim1_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension7_level_name;
  ELSIF (l_measure_rec.dimension2_id = l_dim7_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension7_level_id;
      l_dim2_level_value_id := p_target_rec.dim7_level_value_id;
      l_dim2_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension7_level_name;
  ELSIF (l_measure_rec.dimension3_id = l_dim7_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension7_level_id;
      l_dim3_level_value_id := p_target_rec.dim7_level_value_id;
      l_dim3_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension7_level_name;
  ELSIF (l_measure_rec.dimension4_id = l_dim7_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension7_level_id;
      l_dim4_level_value_id := p_target_rec.dim7_level_value_id;
      l_dim4_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension7_level_name;
  ELSIF (l_measure_rec.dimension5_id = l_dim7_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension7_level_id;
      l_dim5_level_value_id := p_target_rec.dim7_level_value_id;
      l_dim5_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension7_level_name;
  ELSIF (l_measure_rec.dimension6_id = l_dim7_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension7_level_id;
      l_dim6_level_value_id := p_target_rec.dim7_level_value_id;
      l_dim6_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension7_level_name;
  ELSIF (l_measure_rec.dimension7_id = l_dim7_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension7_level_id;
      l_dim7_level_value_id := p_target_rec.dim7_level_value_id;
      l_dim7_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension7_level_name;
  END IF;

  x_Target_Level_Rec.Measure_ID := l_Measure_Rec.Measure_ID;
  x_Target_Level_Rec.Dimension1_Level_ID := NVL(l_DIM1_LEVEL_ID,FND_API.G_MISS_NUM);
  x_Target_Level_Rec.Dimension2_Level_ID := NVL(l_DIM2_LEVEL_ID,FND_API.G_MISS_NUM);
  x_Target_Level_Rec.Dimension3_Level_ID := NVL(l_DIM3_LEVEL_ID,FND_API.G_MISS_NUM);
  x_Target_Level_Rec.Dimension4_Level_ID := NVL(l_DIM4_LEVEL_ID,FND_API.G_MISS_NUM);
  x_Target_Level_Rec.Dimension5_Level_ID := NVL(l_DIM5_LEVEL_ID,FND_API.G_MISS_NUM);
  x_Target_Level_Rec.Dimension6_Level_ID := NVL(l_DIM6_LEVEL_ID,FND_API.G_MISS_NUM);
  x_Target_Level_Rec.Dimension7_Level_ID := NVL(l_DIM7_LEVEL_ID,FND_API.G_MISS_NUM);
  l_target_level_id := BIS_TARGET_LEVEL_PVT.Get_Level_Id_From_Dimlevels(x_target_level_rec);
  x_Target_Level_Rec.Target_Level_Id := l_target_level_id;
  x_Target_Level_Rec.Dimension1_Level_Short_Name := NVL(l_DIM1_LEVEL_SHORT_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension2_Level_Short_Name := NVL(l_DIM2_LEVEL_SHORT_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension3_Level_Short_Name := NVL(l_DIM3_LEVEL_SHORT_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension4_Level_Short_Name := NVL(l_DIM4_LEVEL_SHORT_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension5_Level_Short_Name := NVL(l_DIM5_LEVEL_SHORT_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension6_Level_Short_Name := NVL(l_DIM6_LEVEL_SHORT_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension7_Level_Short_Name := NVL(l_DIM7_LEVEL_SHORT_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension1_Level_Name := NVL(l_DIM1_LEVEL_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension2_Level_Name := NVL(l_DIM2_LEVEL_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension3_Level_Name := NVL(l_DIM3_LEVEL_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension4_Level_Name := NVL(l_DIM4_LEVEL_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension5_Level_Name := NVL(l_DIM5_LEVEL_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension6_Level_Name := NVL(l_DIM6_LEVEL_NAME,FND_API.G_MISS_CHAR);
  x_Target_Level_Rec.Dimension7_Level_Name := NVL(l_DIM7_LEVEL_NAME,FND_API.G_MISS_CHAR);


  --On to the Targets Stuff
  x_target_rec.target_level_id := l_target_level_id;
  x_target_rec.plan_id         := p_target_rec.plan_id;
  x_target_rec.dim1_level_Value_id := l_dim1_level_value_id;
  x_target_rec.dim2_level_Value_id := l_dim2_level_value_id;
  x_target_rec.dim3_level_Value_id := l_dim3_level_value_id;
  x_target_rec.dim4_level_Value_id := l_dim4_level_value_id;
  x_target_rec.dim5_level_Value_id := l_dim5_level_value_id;
  x_target_rec.dim6_level_Value_id := l_dim6_level_value_id;
  x_target_rec.dim7_level_Value_id := l_dim7_level_value_id;

  l_target_rec_p := x_target_rec;
  BIS_TARGET_PUB.Retrieve_Target(p_api_version => 1.0,
                                  p_Target_Rec => l_target_rec_p,
                                  p_all_info => FND_API.G_TRUE,
                                  x_Target_Rec => x_target_rec,
                                  x_return_status => x_return_status,
                                  x_error_Tbl => x_error_tbl);

   --Dim Level Value Names

   IF (x_target_level_rec.dimension1_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension1_level_id)= FND_API.G_TRUE
      AND
      x_target_rec.dim1_level_value_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_rec.dim1_level_value_id)= FND_API.G_TRUE) THEN

      l_dim_level_value_rec.Dimension_level_id := x_target_level_rec.dimension1_level_id;
      l_dim_level_value_rec.Dimension_level_value_id := x_target_rec.dim1_level_value_id;
      l_dim_level_value_rec_p := l_dim_level_value_rec;
      BIS_DIM_LEVEL_VALUE_PVT.DIMENSIONX_ID_TO_VALUE
                          (p_api_version => 1.0
		          ,p_dim_level_value_rec => l_dim_level_value_rec_p
			  ,x_dim_level_value_rec => l_dim_level_value_rec
			  ,x_return_status => x_return_status
		          ,x_error_tbl => x_error_tbl
			  );
      x_target_rec.dim1_level_value_name := l_dim_level_value_rec.Dimension_level_value_name;
   END IF;

   IF (x_target_level_rec.dimension2_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension2_level_id)= FND_API.G_TRUE
      AND
      x_target_rec.dim2_level_value_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_rec.dim2_level_value_id)= FND_API.G_TRUE) THEN

      l_dim_level_value_rec.Dimension_level_id := x_target_level_rec.dimension2_level_id;
      l_dim_level_value_rec.Dimension_level_value_id := x_target_rec.dim2_level_value_id;
      l_dim_level_value_rec_p := l_dim_level_value_rec;
      BIS_DIM_LEVEL_VALUE_PVT.DIMENSIONX_ID_TO_VALUE
                          (p_api_version => 1.0
		          ,p_dim_level_value_rec => l_dim_level_value_rec_p
			  ,x_dim_level_value_rec => l_dim_level_value_rec
			  ,x_return_status => x_return_status
		          ,x_error_tbl => x_error_tbl
			  );
      x_target_rec.dim2_level_value_name := l_dim_level_value_rec.Dimension_level_value_name;
   END IF;

   IF (x_target_level_rec.dimension3_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension3_level_id)= FND_API.G_TRUE
      AND
      x_target_rec.dim3_level_value_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_rec.dim3_level_value_id)= FND_API.G_TRUE) THEN

      l_dim_level_value_rec.Dimension_level_id := x_target_level_rec.dimension3_level_id;
      l_dim_level_value_rec.Dimension_level_value_id := x_target_rec.dim3_level_value_id;
      l_dim_level_value_rec_p := l_dim_level_value_rec;
      BIS_DIM_LEVEL_VALUE_PVT.DIMENSIONX_ID_TO_VALUE
                          (p_api_version => 1.0
		          ,p_dim_level_value_rec => l_dim_level_value_rec_p
			  ,x_dim_level_value_rec => l_dim_level_value_rec
			  ,x_return_status => x_return_status
		          ,x_error_tbl => x_error_tbl
			  );
      x_target_rec.dim3_level_value_name := l_dim_level_value_rec.Dimension_level_value_name;
   END IF;

   IF (x_target_level_rec.dimension4_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension4_level_id)= FND_API.G_TRUE
      AND
      x_target_rec.dim4_level_value_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_rec.dim4_level_value_id)= FND_API.G_TRUE) THEN

      l_dim_level_value_rec.Dimension_level_id := x_target_level_rec.dimension4_level_id;
      l_dim_level_value_rec.Dimension_level_value_id := x_target_rec.dim4_level_value_id;
      l_dim_level_value_rec_p := l_dim_level_value_rec;
      BIS_DIM_LEVEL_VALUE_PVT.DIMENSIONX_ID_TO_VALUE
                          (p_api_version => 1.0
		          ,p_dim_level_value_rec => l_dim_level_value_rec_p
			  ,x_dim_level_value_rec => l_dim_level_value_rec
			  ,x_return_status => x_return_status
		          ,x_error_tbl => x_error_tbl
			  );
      x_target_rec.dim4_level_value_name := l_dim_level_value_rec.Dimension_level_value_name;
   END IF;

   IF (x_target_level_rec.dimension5_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension5_level_id)= FND_API.G_TRUE
      AND
      x_target_rec.dim5_level_value_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_rec.dim5_level_value_id)= FND_API.G_TRUE) THEN

      l_dim_level_value_rec.Dimension_level_id := x_target_level_rec.dimension5_level_id;
      l_dim_level_value_rec.Dimension_level_value_id := x_target_rec.dim5_level_value_id;
      l_dim_level_value_rec_p := l_dim_level_value_rec;
      BIS_DIM_LEVEL_VALUE_PVT.DIMENSIONX_ID_TO_VALUE
                          (p_api_version => 1.0
		          ,p_dim_level_value_rec => l_dim_level_value_rec_p
			  ,x_dim_level_value_rec => l_dim_level_value_rec
			  ,x_return_status => x_return_status
		          ,x_error_tbl => x_error_tbl
			  );
      x_target_rec.dim5_level_value_name := l_dim_level_value_rec.Dimension_level_value_name;
   END IF;

   IF (x_target_level_rec.dimension6_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension6_level_id)= FND_API.G_TRUE
      AND
      x_target_rec.dim6_level_value_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_rec.dim6_level_value_id)= FND_API.G_TRUE) THEN

      l_dim_level_value_rec.Dimension_level_id := x_target_level_rec.dimension6_level_id;
      l_dim_level_value_rec.Dimension_level_value_id := x_target_rec.dim6_level_value_id;
      l_dim_level_value_rec_p := l_dim_level_value_rec;
      BIS_DIM_LEVEL_VALUE_PVT.DIMENSIONX_ID_TO_VALUE
                          (p_api_version => 1.0
		          ,p_dim_level_value_rec => l_dim_level_value_rec_p
			  ,x_dim_level_value_rec => l_dim_level_value_rec
			  ,x_return_status => x_return_status
		          ,x_error_tbl => x_error_tbl
			  );
      x_target_rec.dim6_level_value_name := l_dim_level_value_rec.Dimension_level_value_name;
   END IF;

   IF (x_target_level_rec.dimension7_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension7_level_id)= FND_API.G_TRUE
      AND
      x_target_rec.dim7_level_value_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_rec.dim7_level_value_id)= FND_API.G_TRUE) THEN

      l_dim_level_value_rec.Dimension_level_id := x_target_level_rec.dimension7_level_id;
      l_dim_level_value_rec.Dimension_level_value_id := x_target_rec.dim7_level_value_id;
      l_dim_level_value_rec_p := l_dim_level_value_rec;
      BIS_DIM_LEVEL_VALUE_PVT.DIMENSIONX_ID_TO_VALUE
                          (p_api_version => 1.0
		          ,p_dim_level_value_rec => l_dim_level_value_rec_p
			  ,x_dim_level_value_rec => l_dim_level_value_rec
			  ,x_return_status => x_return_status
		          ,x_error_tbl => x_error_tbl
			  );
      x_target_rec.dim7_level_value_name := l_dim_level_value_rec.Dimension_level_value_name;
   END IF;


EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --Added last two parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Create_Target_Level'
    , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Target_From_ShNms;

--
-- Package Initialization
--   Initialize globle variable
--
BEGIN
  G_SET_OF_BOOK_ID := NULL;

END BIS_TARGET_PVT;

/
