--------------------------------------------------------
--  DDL for Package Body BIS_ACTUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_ACTUAL_PVT" AS
/* $Header: BISVACVB.pls 115.19 2003/01/27 13:34:17 mahrao ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_ACTUAL_PVT';
--
G_ACTION_INSERT CONSTANT VARCHAR2(10) := 'INSERT';
G_ACTION_UPDATE CONSTANT VARCHAR2(10) := 'UPDATE';

FUNCTION Level_Value_Null_ID_Not_Null(  -- 2730145
  p_level_value      IN VARCHAR2
, p_level_id         IN NUMBER
)
RETURN VARCHAR2;

-- Retrieves the KPIs users have selected to monitor on the personal homepage
-- or in the summary report.  This should be called before calling Post_Actual.
PROCEDURE Retrieve_User_Selections
(  p_api_version                  IN NUMBER
  ,p_all_info                     IN  VARCHAR2   := FND_API.G_TRUE
  ,p_Target_Level_Rec
     IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Indicator_Region_Tbl
     OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
i                      NUMBER := 0;
l_Target_Level_id   NUMBER;
l_target_level_Rec     BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Indicator_Region_Rec BIS_INDICATOR_REGION_PUB.Indicator_Region_rec_Type;

CURSOR cr_user_selections IS
  SELECT DISTINCT TARGET_LEVEL_ID
                 ,ORGANIZATION_ID
                 ,RESPONSIBILITY_ID
                 ,DIMENSION1_LEVEL_VALUE
                 ,DIMENSION2_LEVEL_VALUE
                 ,DIMENSION3_LEVEL_VALUE
                 ,DIMENSION4_LEVEL_VALUE
                 ,DIMENSION5_LEVEL_VALUE
  FROM bis_user_ind_selections
  WHERE TARGET_LEVEL_ID = l_Target_Level_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
  IF BIS_UTILITIES_PUB.Value_Missing (p_Target_Level_Rec.Target_Level_ID)
     = FND_API.G_TRUE
  THEN

    BIS_TARGET_LEVEL_PUB.Retrieve_Target_Level
    ( p_api_version         => 1.0
    , p_Target_Level_Rec    => p_Target_Level_Rec
    , p_all_info            => FND_API.G_FALSE
    , x_Target_Level_Rec    => l_Target_level_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_tbl
    );

    l_Target_Level_id := l_Target_level_Rec.Target_Level_id;
  ELSE
    l_Target_Level_id := p_Target_Level_Rec.Target_Level_ID;
  END IF;

  FOR cr IN cr_user_selections LOOP

    i := i + 1;
    l_Indicator_Region_Rec.Target_Level_ID  := cr.target_level_id;
    l_Indicator_Region_Rec.Organization_ID     := cr.Organization_ID;
    l_Indicator_Region_Rec.responsibility_id   := cr.responsibility_id;
    l_Indicator_Region_Rec.Dim1_Level_Value_ID := cr.dimension1_level_value;
    l_Indicator_Region_Rec.Dim2_Level_Value_ID := cr.dimension2_level_value;
    l_Indicator_Region_Rec.Dim3_Level_Value_ID := cr.dimension3_level_value;
    l_Indicator_Region_Rec.Dim4_Level_Value_ID := cr.dimension4_level_value;
    l_Indicator_Region_Rec.Dim5_Level_Value_ID := cr.dimension5_level_value;

    x_Indicator_Region_Tbl(i) := l_Indicator_Region_Rec;

  END LOOP;
*/

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Retrieve_User_Selections;


-- Retrieves all the records in bis_user_ind_selections for the
-- given target_level

PROCEDURE Retrieve_tl_selections
(  p_Target_Level_Rec
            IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Indicator_Region_Tbl
            OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
i                      NUMBER := 0;
l_Target_Level_id      NUMBER;
l_Indicator_Region_Rec BIS_INDICATOR_REGION_PUB.Indicator_Region_rec_Type;

CURSOR cr_tl_selections IS
  SELECT  distinct TARGET_LEVEL_ID
                 ,PLAN_ID
                 ,DIMENSION1_LEVEL_VALUE
                 ,DIMENSION2_LEVEL_VALUE
                 ,DIMENSION3_LEVEL_VALUE
                 ,DIMENSION4_LEVEL_VALUE
                 ,DIMENSION5_LEVEL_VALUE
                 ,DIMENSION6_LEVEL_VALUE
                 ,DIMENSION7_LEVEL_VALUE
  FROM bis_user_ind_selections
  WHERE TARGET_LEVEL_ID = l_Target_Level_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_Target_Level_id := p_Target_level_Rec.Target_Level_id;

  BIS_UTILITIES_PUB.put_line(p_text => 'Target Level Id to get User_ind_sel : '
                                     || l_Target_Level_id);

  FOR cr IN cr_tl_selections LOOP

    i := i + 1;

    l_Indicator_Region_Rec.Target_Level_ID     := cr.target_level_id;
    l_Indicator_Region_Rec.Plan_ID             := cr.plan_id; -- cr.dimension1_level_value;
    l_Indicator_Region_Rec.Dim1_Level_Value_ID := cr.dimension1_level_value;
    l_Indicator_Region_Rec.Dim2_Level_Value_ID := cr.dimension2_level_value;
    l_Indicator_Region_Rec.Dim3_Level_Value_ID := cr.dimension3_level_value;
    l_Indicator_Region_Rec.Dim4_Level_Value_ID := cr.dimension4_level_value;
    l_Indicator_Region_Rec.Dim5_Level_Value_ID := cr.dimension5_level_value;
    l_Indicator_Region_Rec.Dim6_Level_Value_ID := cr.dimension6_level_value;
    l_Indicator_Region_Rec.Dim7_Level_Value_ID := cr.dimension7_level_value;

    x_Indicator_Region_Tbl(i) := l_Indicator_Region_Rec;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Retrieve_tl_selections;


-- Posts actual value into BIS table.
PROCEDURE Post_Actual
(  p_api_version       IN NUMBER
  ,p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
  ,p_commit            IN VARCHAR2   Default FND_API.G_FALSE
  ,p_Actual_Rec        IN BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_target_level_id      NUMBER;
l_organization_id      NUMBER;
l_organization_ID_char VARCHAR2(250);
l_time_level_Value     VARCHAR2(250);
l_actual_rec           BIS_ACTUAL_PUB.Actual_Rec_Type;
l_actual_id            NUMBER;
l_action               VARCHAR2(10);
l_Return_Status        VARCHAR2(1);
e_invalidActualException EXCEPTION;
l_error_tbl            BIS_UTILITIES_PUB.Error_Tbl_Type;

CURSOR cr_actual IS
  SELECT ACTUAL_ID
--  SELECT creation_date, last_update_date
  FROM BIS_ACTUAL_VALUES
  WHERE TARGET_LEVEL_ID  = l_actual_rec.Target_level_id
  AND NVL(DIMENSION1_LEVEL_VALUE,'-999')
     =NVL(l_actual_rec.DIM1_LEVEL_VALUE_ID,'-999')
  AND NVL(DIMENSION2_LEVEL_VALUE,'-999')
     =NVL(l_actual_rec.DIM2_LEVEL_VALUE_ID,'-999')
  AND NVL(DIMENSION3_LEVEL_VALUE,'-999')
     =NVL(l_actual_rec.DIM3_LEVEL_VALUE_ID,'-999')
  AND NVL(DIMENSION4_LEVEL_VALUE,'-999')
     =NVL(l_actual_rec.DIM4_LEVEL_VALUE_ID,'-999')
  AND NVL(DIMENSION5_LEVEL_VALUE,'-999')
     =NVL(l_actual_rec.DIM5_LEVEL_VALUE_ID,'-999')
  AND NVL(DIMENSION6_LEVEL_VALUE,'-999')
     =NVL(l_actual_rec.DIM6_LEVEL_VALUE_ID,'-999')
  AND NVL(DIMENSION7_LEVEL_VALUE,'-999')
     =NVL(l_actual_rec.DIM7_LEVEL_VALUE_ID,'-999')
  ORDER BY CREATION_DATE
  FOR UPDATE;

--l_create_date DATE;
--l_update_date DATE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- dbms_output.put_line('In PVT Post_Actual');

  l_actual_rec := p_actual_rec;
  Validate_Actual
  ( p_api_version       => p_api_version
  , p_validation_level  => p_validation_level
  , p_Actual_Rec        => l_Actual_Rec
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- $$
  /*IF BIS_UTILITIES_PUB.Value_Missing(l_actual_rec.Time_Level_Value_ID)
     = FND_API.G_TRUE
  OR  BIS_UTILITIES_PUB.Value_Null(l_actual_rec.Time_Level_Value_ID)
     = FND_API.G_TRUE
  THEN

    -- get the period_name for the current date
    --
    -- What's up with this???
    BIS_UTIL.Get_Time_Level_Value
    ( p_date             => SYSDATE
    , p_Target_Level_ID  => l_Actual_Rec .target_level_id
    , p_Organization_ID  => l_Actual_Rec.Org_Level_Value_ID
    , x_Time_Level_Value => l_actual_rec.Time_Level_Value_ID
    , x_Return_Status    => x_Return_Status
    );
-- dbms_output.put_line('ACT pvt Get time level Value Status: '||x_return_status);

    IF l_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
*/
  -- check if previous record exist and set action flag
  --
  OPEN cr_actual;
  FETCH cr_actual INTO l_actual_id;
--  FETCH cr_actual INTO l_create_date, l_update_date;
  IF cr_actual%FOUND THEN
    l_action := G_ACTION_UPDATE;
  ELSE
    l_action := G_ACTION_INSERT;
  END IF;

  IF l_action = G_ACTION_UPDATE  THEN
--  AND l_actual_rec.Time_Level_Value_ID IS NOT NULL THEN

    UPDATE bis_actual_values
    SET TARGET_LEVEL_ID = l_actual_rec.target_level_id
    --, ORG_LEVEL_VALUE = l_actual_rec.Org_Level_Value_ID
    --, TIME_LEVEL_VALUE = l_actual_rec.Time_Level_Value_ID
    , DIMENSION1_LEVEL_VALUE = l_actual_rec.Dim1_Level_Value_ID
    , DIMENSION2_LEVEL_VALUE = l_actual_rec.Dim2_Level_Value_ID
    , DIMENSION3_LEVEL_VALUE = l_actual_rec.Dim3_Level_Value_ID
    , DIMENSION4_LEVEL_VALUE = l_actual_rec.Dim4_Level_Value_ID
    , DIMENSION5_LEVEL_VALUE = l_actual_rec.Dim5_Level_Value_ID
    , DIMENSION6_LEVEL_VALUE = l_actual_rec.Dim6_Level_Value_ID
    , DIMENSION7_LEVEL_VALUE = l_actual_rec.Dim7_Level_Value_ID
    , ACTUAL_VALUE      = l_actual_rec.actual
    , COMPARISON_ACTUAL_VALUE      = l_actual_rec.comparison_actual_value  --  1850860
    , REPORT_URL        = l_actual_rec.report_url  --  1850860
    , LAST_UPDATE_DATE  = SYSDATE
    , LAST_UPDATED_BY   = FND_GLOBAL.USER_ID
    , LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
    WHERE CURRENT OF cr_actual;

    COMMIT;
    IF cr_actual%ISOPEN THEN CLOSE cr_actual; END IF;

--    l_update_date := SYSDATE;

  ELSIF l_action = G_ACTION_INSERT  THEN
--  AND l_actual_rec.Time_Level_Value_ID IS NOT NULL THEN

    IF cr_actual%ISOPEN THEN CLOSE cr_actual; END IF;
    INSERT INTO bis_actual_values
    ( ACTUAL_ID
    , TARGET_LEVEL_ID
    --, ORG_LEVEL_VALUE
    --, TIME_LEVEL_VALUE
    , DIMENSION1_LEVEL_VALUE
    , DIMENSION2_LEVEL_VALUE
    , DIMENSION3_LEVEL_VALUE
    , DIMENSION4_LEVEL_VALUE
    , DIMENSION5_LEVEL_VALUE
    , DIMENSION6_LEVEL_VALUE
    , DIMENSION7_LEVEL_VALUE
    , ACTUAL_VALUE
    , COMPARISON_ACTUAL_VALUE  --  1850860
    , REPORT_URL               --  1850860
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    )
    VALUES
    ( BIS_ACTUAL_VALUES_S.NEXTVAL
    , l_actual_rec.target_level_id
    --, l_actual_rec.Org_Level_Value_ID
    --, l_actual_rec.Time_Level_Value_ID
    , l_actual_rec.Dim1_Level_Value_ID
    , l_actual_rec.Dim2_Level_Value_ID
    , l_actual_rec.Dim3_Level_Value_ID
    , l_actual_rec.Dim4_Level_Value_ID
    , l_actual_rec.Dim5_Level_Value_ID
    , l_actual_rec.Dim6_Level_Value_ID
    , l_actual_rec.Dim7_Level_Value_ID
    , l_actual_rec.actual
    , l_actual_rec.comparison_actual_value  --  1850860
    , l_actual_rec.report_url               --  1850860
    , SYSDATE
    , FND_GLOBAL.USER_ID
    , SYSDATE
    , FND_GLOBAL.USER_ID
    , FND_GLOBAL.LOGIN_ID
    );

    COMMIT;

--    l_update_date := SYSDATE;
--    l_create_date := SYSDATE;

  ELSE
    IF cr_actual%ISOPEN THEN CLOSE cr_actual; END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

--  dbms_output.put_line('action: '||l_action
--                      ||'.  Time Val: '||SUBSTR(l_time_level_value,1,20)
--                      ||'-- Org Val: '||SUBSTR(l_organization_id_char,1,5)
--                      ||'-- Create date: '||l_create_date
--                      ||'-- Update date: '||l_update_date);

--commented out NOCOPY RAISE
EXCEPTION
  WHEN NO_DATA_FOUND OR e_invalidActualException THEN
      IF cr_actual%ISOPEN THEN CLOSE cr_actual; END IF;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      IF cr_actual%ISOPEN THEN CLOSE cr_actual; END IF;
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      IF cr_actual%ISOPEN THEN CLOSE cr_actual; END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      IF cr_actual%ISOPEN THEN CLOSE cr_actual; END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
    	l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Measure'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Post_Actual;

-- Retrieves actual value for the specified set of dimension values
-- i.e. for a specific organization, time period, etc.
--
-- If information about dimension values are not required, set all_info
-- to FALSE.
--
PROCEDURE Retrieve_Actual
(  p_api_version                  IN NUMBER
  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Actual_Rec                   IN BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_Actual_Rec                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_Actual_Rec BIS_ACTUAL_PUB.Actual_Rec_Type;
l_Target_Level_Rec BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_Target_Level_Rec_p BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;


CURSOR cr_bv_actual (p_actual_rec BIS_ACTUAL_PUB.ACTUAL_Rec_Type) IS
  SELECT
    actual_id
  , target_level_id
  --, org_level_value
  --, time_level_value
  , dimension1_level_value
  , dimension2_level_value
  , dimension3_level_value
  , dimension4_level_value
  , dimension5_level_value
  , dimension6_level_value
  , dimension7_level_value
  , actual_value
  , comparison_actual_value      --  1850860
  , report_url                   --  1850860
  FROM   bisbv_actuals acts
  WHERE  acts.target_level_id    = p_actual_rec.target_level_id
  --AND    acts.org_level_value    = p_actual_rec.org_level_value_id
  --AND    acts.time_level_value   = p_actual_rec.time_level_value_id
  AND NVL(acts.dimension1_level_value, 'NULL')
    = NVL(p_actual_rec.dim1_level_value_id, 'NULL')
  AND NVL(acts.dimension2_level_value, 'NULL')
    = NVL(p_actual_rec.dim2_level_value_id, 'NULL')
  AND NVL(acts.dimension3_level_value, 'NULL')
    = NVL(p_actual_rec.dim3_level_value_id, 'NULL')
  AND NVL(acts.dimension4_level_value, 'NULL')
    = NVL(p_actual_rec.dim4_level_value_id, 'NULL')
  AND NVL(acts.dimension5_level_value, 'NULL')
    = NVL(p_actual_rec.dim5_level_value_id, 'NULL')
  AND NVL(acts.dimension6_level_value, 'NULL')
    = NVL(p_actual_rec.dim6_level_value_id, 'NULL')
  AND NVL(acts.dimension7_level_value, 'NULL')
    = NVL(p_actual_rec.dim7_level_value_id, 'NULL')
  ORDER BY LAST_UPDATE_DATE DESC;

CURSOR cr_fv_actual (p_actual_rec BIS_ACTUAL_PUB.ACTUAL_Rec_Type) IS
  SELECT
    actual_id
  , target_level_id
  , target_level_short_name
  , target_level_name
  --, org_level_value
  --, time_level_value
  , dimension1_level_value
  , dimension2_level_value
  , dimension3_level_value
  , dimension4_level_value
  , dimension5_level_value
  , dimension6_level_value
  , dimension7_level_value
  , actual_value
  , comparison_actual_value      --  1850860
  , report_url                   --  1850860
  FROM   bisfv_actuals acts
  WHERE  acts.target_level_id    = p_actual_rec.target_level_id
  --AND    acts.org_level_value    = p_actual_rec.org_level_value_id
  --AND    acts.time_level_value   = p_actual_rec.time_level_value_id
  AND NVL(acts.dimension1_level_value, 'NULL')
    = NVL(p_actual_rec.dim1_level_value_id, 'NULL')
  AND NVL(acts.dimension2_level_value, 'NULL')
    = NVL(p_actual_rec.dim2_level_value_id, 'NULL')
  AND NVL(acts.dimension3_level_value, 'NULL')
    = NVL(p_actual_rec.dim3_level_value_id, 'NULL')
  AND NVL(acts.dimension4_level_value, 'NULL')
    = NVL(p_actual_rec.dim4_level_value_id, 'NULL')
  AND NVL(acts.dimension5_level_value, 'NULL')
    = NVL(p_actual_rec.dim5_level_value_id, 'NULL')
  AND NVL(acts.dimension6_level_value, 'NULL')
    = NVL(p_actual_rec.dim6_level_value_id, 'NULL')
  AND NVL(acts.dimension7_level_value, 'NULL')
    = NVL(p_actual_rec.dim7_level_value_id, 'NULL')
  ORDER BY LAST_UPDATE_DATE DESC;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Actual_Rec := p_Actual_Rec;

  IF ((BIS_UTILITIES_PUB.Value_Missing
    (l_Actual_Rec.target_level_ID) = FND_API.G_TRUE)
  AND (BIS_UTILITIES_PUB.Value_Null
     (l_Actual_Rec.target_level_ID) = FND_API.G_TRUE))
  THEN
    l_Target_Level_Rec.target_level_ID := p_Actual_Rec.target_level_ID;
    l_Target_Level_Rec_p := l_Target_Level_Rec;
		BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version         => p_api_version
    , p_Target_Level_Rec    => l_Target_Level_Rec_p
    , p_all_info            => FND_API.G_FALSE
    , x_Target_Level_Rec    => l_Target_Level_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
    l_actual_rec.target_level_ID := l_Target_Level_Rec.target_level_ID;

   END IF;

  -- if actual already posted in BIS_ACTUAL_VALUES, then return actual value;
  --
  IF p_all_info = FND_API.G_TRUE THEN
    OPEN cr_bv_actual(p_actual_rec);
    FETCH cr_bv_actual
    INTO
        l_actual_rec.actual_id
      , l_actual_rec.Target_Level_ID
      --, l_actual_rec.Org_Level_value_ID
      --, l_actual_rec.Time_Level_Value_ID
      , l_actual_rec.Dim1_Level_Value_ID
      , l_actual_rec.Dim2_Level_Value_ID
      , l_actual_rec.Dim3_Level_Value_ID
      , l_actual_rec.Dim4_Level_Value_ID
      , l_actual_rec.Dim5_Level_Value_ID
      , l_actual_rec.Dim6_Level_Value_ID
      , l_actual_rec.Dim7_Level_Value_ID
      , l_actual_rec.Actual
      , l_actual_rec.Comparison_Actual_Value  --  1850860
      , l_actual_rec.Report_Url;  --  1850860
    IF cr_bv_actual%NOTFOUND THEN
      CLOSE cr_bv_actual;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_TARGET_LEVEL_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Actual'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;

    END IF;
    IF cr_bv_actual%ISOPEN THEN CLOSE cr_bv_actual; END IF;
  ELSE
    OPEN cr_fv_actual(p_actual_rec);
    FETCH cr_fv_actual
    INTO
        l_actual_rec.actual_id
      , l_actual_rec.Target_Level_ID
      , l_actual_rec.Target_Level_Name
      , l_actual_rec.Target_Level_Short_Name
      --, l_actual_rec.Org_Level_value_ID
      --, l_actual_rec.Time_Level_Value_ID
      , l_actual_rec.Dim1_Level_Value_ID
      , l_actual_rec.Dim2_Level_Value_ID
      , l_actual_rec.Dim3_Level_Value_ID
      , l_actual_rec.Dim4_Level_Value_ID
      , l_actual_rec.Dim5_Level_Value_ID
      , l_actual_rec.Dim6_Level_Value_ID
      , l_actual_rec.Dim7_Level_Value_ID
      , l_actual_rec.Actual
      , l_actual_rec.Comparison_Actual_Value  --  1850860
      , l_actual_rec.Report_Url;  --  1850860
    IF cr_fv_actual%NOTFOUND THEN

      CLOSE cr_fv_actual;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_TARGET_LEVEL_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Actual'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF cr_fv_actual%ISOPEN THEN CLOSE cr_fv_actual; END IF;
  END IF;

  x_actual_rec := l_actual_rec;



EXCEPTION
  --WHEN OTHERS THEN
    --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --added this whole section
    --commented RAISE
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     IF cr_bv_actual%ISOPEN THEN CLOSE cr_bv_actual; END IF;
     IF cr_fv_actual%ISOPEN THEN CLOSE cr_fv_actual; END IF;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     IF cr_bv_actual%ISOPEN THEN CLOSE cr_bv_actual; END IF;
     IF cr_fv_actual%ISOPEN THEN CLOSE cr_fv_actual; END IF;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF cr_bv_actual%ISOPEN THEN CLOSE cr_bv_actual; END IF;
      IF cr_fv_actual%ISOPEN THEN CLOSE cr_fv_actual; END IF;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF cr_bv_actual%ISOPEN THEN CLOSE cr_bv_actual; END IF;
      IF cr_fv_actual%ISOPEN THEN CLOSE cr_fv_actual; END IF;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Actual'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Retrieve_Actual;

-- Retrieves all actual values for the specified Indicator Level
-- i.e. all organizations, all time periods, etc.
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Actuals
(  p_api_version                  IN NUMBER
  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Target_Level_Rec IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Actual_Tbl                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Tbl_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- dbms_output.put_line('In PVT Retrieve_Actuals');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Retrieve_Actuals;


-- Retrieves the most current actual value for the specified set
-- of dimension values. (time level value not necessary.)
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Latest_Actual
(  p_api_version                  IN NUMBER
  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Actual_Rec                   IN BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_Actual_Rec                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- dbms_output.put_line('In PVT Retrieve_Latest_Actual');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Retrieve_Latest_Actual;


-- Retrieves the most current actual values for the specified Indicator Level
-- i.e. for all organizations, etc. (time level value not necessary.)
-- If information about dimension values are not required, set all_info
-- to FALSE.
PROCEDURE Retrieve_Latest_Actuals
(  p_api_version                  IN NUMBER
  ,p_all_info                     IN VARCHAR2 Default FND_API.G_TRUE
  ,p_Target_Level_Rec IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  ,x_Actual_Tbl                   OUT NOCOPY BIS_ACTUAL_PUB.Actual_Tbl_Type
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_error_Tbl                    OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- dbms_output.put_line('In PVT Retrieve_Latest_Actuals');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Retrieve_Latest_Actuals;

PROCEDURE Validate_Actual
(  p_api_version          IN NUMBER
 , p_validation_level     IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
 , p_Actual_Rec           IN BIS_ACTUAL_PUB.Actual_Rec_Type
 , x_return_status        OUT NOCOPY VARCHAR2
 , x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_return_status   VARCHAR2(10);
l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error_Tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error     VARCHAR2(10) := FND_API.G_FALSE;
--
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Target_Level_ID
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => x_error_Tbl
    );
    --
  -- dbms_output.put_line('In PVT Actual 1');

 -- EXCEPTION
   -- WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 1 Exception');
      --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
     	 l_error_tbl_p := x_error_Tbl;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;

  END;
  --
/* Don't need to validate time
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Time_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
--  EXCEPTION
  --  WHEN FND_API.G_EXC_ERROR THEN
     --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => x_error_Tbl
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
*/
  --
  /*BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Org_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
  -- dbms_output.put_line('In PVT Actual 2');

    --
 -- EXCEPTION
  --  WHEN FND_API.G_EXC_ERROR THEN
   --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => x_error_Tbl
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;*/
  --
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Dim1_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  -- dbms_output.put_line('In PVT Actual 3');


 -- EXCEPTION
  --  WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 3 Exception');
 --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
     	 l_error_tbl_p := x_error_Tbl;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
  --
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Dim2_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  -- dbms_output.put_line('In PVT Actual 4');

 -- EXCEPTION
  --  WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 4 Exception');
      --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
     	 l_error_tbl_p := x_error_Tbl;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
  --
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Dim3_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  -- dbms_output.put_line('In PVT Actual 5');

 -- EXCEPTION
  --  WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 5 Exception');
      --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
     	 l_error_tbl_p := x_error_Tbl;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
  --
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Dim4_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  -- dbms_output.put_line('In PVT Actual 6');

 -- EXCEPTION
  --  WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 6 Exception');
       --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
     	 l_error_tbl_p := x_error_Tbl;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
  --
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Dim5_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  -- dbms_output.put_line('In PVT Actual 7');

--  EXCEPTION
 --   WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 7 Exception');
      --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
     	 l_error_tbl_p := x_error_Tbl;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
  --
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Dim6_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  -- dbms_output.put_line('In PVT Actual 7');

 -- EXCEPTION
  --  WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 7 Exception');
     --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
     	 l_error_tbl_p := x_error_Tbl;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
  --
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Dim7_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  -- dbms_output.put_line('In PVT Actual 7');

--  EXCEPTION
  --  WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 7 Exception');
     --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
     	 l_error_tbl_p := x_error_Tbl;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
  --
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Actual_Value
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  -- dbms_output.put_line('In PVT Actual 8');

 -- EXCEPTION
   -- WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 8 Exception');
      --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
     	 l_error_tbl_p := x_error_Tbl;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
  --
/*-- Validate the Comaprison Actual Value --  1850860
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Comparison_Actual_Value
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  -- dbms_output.put_line('In PVT Actual 8');

 -- EXCEPTION
   -- WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 8 Exception');
      --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
        BIS_UTILITIES_PVT.concatenateErrorTables

      ( p_error_Tbl1 => x_error_Tbl
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
--    --  1850860

-- Validate the Report URL --  1850860
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Report_Url
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  -- dbms_output.put_line('In PVT Report URL');

 -- EXCEPTION
   -- WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Report URL Exception');
      --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
        BIS_UTILITIES_PVT.concatenateErrorTables

      ( p_error_Tbl1 => x_error_Tbl
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
--    --  1850860                                                                        */
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Record
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  -- dbms_output.put_line('In PVT Actual 9');

--  EXCEPTION
   -- WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 9 Exception');
     --added this
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       l_error := FND_API.G_TRUE;
       x_return_status:= FND_API.G_RET_STS_ERROR;
     	 l_error_tbl_p := x_error_Tbl;
        BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
     END IF;
  END;
  --

  --added this check
 if (l_error = FND_API.G_TRUE) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

--commented out NOCOPY RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 10 Exception');
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  -- dbms_output.put_line('In PVT Actual 11 Exception');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;

  WHEN OTHERS THEN
  -- dbms_output.put_line('In PVT Actual 12 Exception');
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
 	  l_error_tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Actual;

PROCEDURE Validate_Required_Fields
( p_api_version          IN NUMBER
, p_validation_level     IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
, p_Actual_Rec           IN BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- dbms_output.put_line('In PVT Validate_Required_Fields');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Validate_Required_Fields;


PROCEDURE Validate_Dimension_Values
( p_api_version          IN NUMBER
, p_validation_level     IN NUMBER Default FND_API.G_VALID_LEVEL_FULL
, p_Actual_Rec           IN BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- dbms_output.put_line('In PVT Validate_Dimension_Values');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Validate_Dimension_Values;

PROCEDURE Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Actual_Rec IN   BIS_ACTUAL_PUB.Actual_Rec_Type
, x_Actual_Rec OUT NOCOPY  BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Dim_Level_Value_Rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec2  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Target_Level_Rec      BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Target_Level_Rec_p    BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Actual_Rec            BIS_ACTUAL_PUB.Actual_Rec_Type;
BEGIN

  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  l_Actual_Rec     := p_Actual_Rec;

  -- convert Target Level
  --
  IF BIS_UTILITIES_PUB.Value_Missing(l_actual_rec.Target_Level_ID)
     = FND_API.G_TRUE
  OR  BIS_UTILITIES_PUB.Value_Null(l_actual_rec.Target_Level_ID)
     = FND_API.G_TRUE
  THEN
  BEGIN


    BIS_Target_Level_PVT.Value_ID_Conversion
    ( p_api_version             => p_api_version
    , p_Target_Level_short_name => l_actual_rec.Target_Level_short_name
    , p_Target_Level_name       => l_actual_rec.Target_Level_name
    , x_Target_Level_id         => l_actual_rec.Target_Level_id
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );

    l_Target_Level_rec.Target_Level_id := l_actual_rec.Target_Level_id;
    l_Target_Level_rec.Target_Level_short_name
      := l_actual_rec.Target_Level_short_name;
    l_Target_Level_rec.Target_Level_name := l_actual_rec.Target_Level_name;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      NULL;
      -- dbms_output.put_line('in actual api. EXEC ERROR');

    WHEN OTHERS THEN
      NULL;
      -- dbms_output.put_line('in actual api. OTHER');

  END;
  ELSE
    l_target_level_rec.Target_Level_ID := l_actual_rec.Target_Level_ID;

  END IF;

  BEGIN
    l_Target_Level_rec_p := l_Target_Level_rec;
		BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version             => p_api_version
    , p_Target_Level_rec        => l_Target_Level_rec_p
    , p_all_info                => FND_API.G_FALSE
    , x_Target_Level_rec        => l_Target_Level_rec
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      NULL;
      -- dbms_output.put_line('in actual api. EXEC ERROR');

    WHEN OTHERS THEN
      NULL;
      -- dbms_output.put_line('in actual api. OTHER');

  END;



  -- Convert dim1_level_value
  --
  IF (
       Level_Value_Null_ID_Not_Null(
         p_level_value => l_actual_rec.Dim1_Level_value_ID
       , p_level_id    => l_target_level_rec.Dimension1_level_id)
	        = FND_API.G_TRUE
	 ) THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension1_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim1_level_value_name;
      l_dim_level_value_Rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_Rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim1_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  END IF;

  -- Convert dim2_level_value
  --
  IF (
       Level_Value_Null_ID_Not_Null(
         p_level_value => l_actual_rec.Dim2_Level_value_ID
       , p_level_id    => l_target_level_rec.Dimension2_level_id)
	        = FND_API.G_TRUE
	 ) THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension2_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim2_level_value_name;

      l_dim_level_value_Rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_Rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim2_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  END IF;

  -- Convert dim3_level_value
  --
  IF (
       Level_Value_Null_ID_Not_Null(
         p_level_value => l_actual_rec.Dim3_Level_value_ID
       , p_level_id    => l_target_level_rec.Dimension3_level_id)
	        = FND_API.G_TRUE
	 ) THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension3_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim3_level_value_name;

      l_dim_level_value_Rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_Rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim3_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  END IF;

  -- Convert dim4_level_value
  --
  IF (
       Level_Value_Null_ID_Not_Null(
         p_level_value => l_actual_rec.Dim4_Level_value_ID
       , p_level_id    => l_target_level_rec.Dimension4_level_id)
	        = FND_API.G_TRUE
	 ) THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension4_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim4_level_value_name;

			l_dim_level_value_Rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_Rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim4_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  END IF;

  -- Convert dim5_level_value
  --
  IF (
       Level_Value_Null_ID_Not_Null(
         p_level_value => l_actual_rec.Dim5_Level_value_ID
       , p_level_id    => l_target_level_rec.Dimension5_level_id)
	        = FND_API.G_TRUE
	 ) THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension5_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim5_level_value_name;

      l_dim_level_value_Rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_Rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim5_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  END IF;

  -- Convert dim6_level_value
  --
  IF (
       Level_Value_Null_ID_Not_Null(
         p_level_value => l_actual_rec.Dim6_Level_value_ID
       , p_level_id    => l_target_level_rec.Dimension6_level_id)
	        = FND_API.G_TRUE
	 ) THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension6_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim6_level_value_name;

      l_dim_level_value_Rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_Rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim6_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  END IF;

  -- Convert dim7_level_value
  --
  IF (
       Level_Value_Null_ID_Not_Null(
         p_level_value => l_actual_rec.Dim7_Level_value_ID
       , p_level_id    => l_target_level_rec.Dimension7_level_id)
	        = FND_API.G_TRUE
	 ) THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension7_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim7_level_value_name;

      l_dim_level_value_Rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_Rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim7_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  END IF;

  x_Actual_Rec     := l_Actual_Rec;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Value_ID_Conversion;




FUNCTION Level_Value_Null_ID_Not_Null(  -- 2730145
  p_level_value      IN VARCHAR2
, p_level_id         IN NUMBER
)
RETURN VARCHAR2
IS
BEGIN

  IF (
      (
	BIS_UTILITIES_PVT.Value_Missing_Or_Null
        (p_value => p_level_value ) = FND_API.G_TRUE
      )
	  AND
      (
        BIS_UTILITIES_PVT.Value_Not_Missing_Not_Null
        (p_value => p_level_id ) = FND_API.G_TRUE
      )
     ) THEN
	RETURN FND_API.G_TRUE;
  ELSE
    RETURN FND_API.G_FALSE;
  END IF;
END Level_Value_Null_ID_Not_Null;



END BIS_ACTUAL_PVT;

/
