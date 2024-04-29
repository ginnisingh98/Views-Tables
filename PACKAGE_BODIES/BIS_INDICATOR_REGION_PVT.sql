--------------------------------------------------------
--  DDL for Package Body BIS_INDICATOR_REGION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_INDICATOR_REGION_PVT" AS
/* $Header: BISVREGB.pls 115.31 2003/04/07 06:15:25 arhegde ship $ */
Procedure Create_User_Ind_Selection(
        p_api_version           IN NUMBER,
        p_Indicator_Region_Rec
          IN BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_ind_id NUMBER;
l_rowid       VARCHAR2(18);
l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

cursor c is
   select rowid from BIS_USER_IND_SELECTIONS
   where IND_SELECTION_ID = l_user_ind_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  select BIS_USER_IND_SELECTIONS_S.NEXTVAL into l_user_ind_id from dual;
  -- mdamle 01/15/2001 - Remove Org and add Dim6 and Dim7
  insert into BIS_USER_IND_SELECTIONS (
               IND_SELECTION_ID
              ,USER_ID
              ,TARGET_LEVEL_ID
              -- ,ORGANIZATION_ID
              -- ,ORG_LEVEL_VALUE
              ,LABEL
              ,PLUG_ID
              ,RESPONSIBILITY_ID
              ,DIMENSION1_LEVEL_VALUE
              ,DIMENSION2_LEVEL_VALUE
              ,DIMENSION3_LEVEL_VALUE
              ,DIMENSION4_LEVEL_VALUE
              ,DIMENSION5_LEVEL_VALUE
			  ,DIMENSION6_LEVEL_VALUE
			  ,DIMENSION7_LEVEL_VALUE
              ,PLAN_ID
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,LAST_UPDATE_LOGIN)
  values (
               l_user_ind_id
              ,p_Indicator_Region_Rec.USER_ID
              ,p_Indicator_Region_Rec.Target_Level_ID
              -- ,NULL
              -- ,p_Indicator_Region_Rec.Org_Level_Value_Id
              ,p_Indicator_Region_Rec.LABEL
              ,p_Indicator_Region_Rec.PLUG_ID
              ,DECODE(p_Indicator_Region_Rec.RESPONSIBILITY_ID,FND_API.G_MISS_NUM,NULL,
                      p_Indicator_Region_Rec.RESPONSIBILITY_ID)
              ,DECODE(p_Indicator_Region_Rec.DIM1_LEVEL_VALUE_ID,'+',NULL,'-',NULL,
                      p_Indicator_Region_Rec.DIM1_LEVEL_VALUE_ID)
              ,DECODE(p_Indicator_Region_Rec.DIM2_LEVEL_VALUE_ID,'+',NULL,'-',NULL,
                      p_Indicator_Region_Rec.DIM2_LEVEL_VALUE_ID)
              ,DECODE(p_Indicator_Region_Rec.DIM3_LEVEL_VALUE_ID,'+',NULL,'-',NULL,
                      p_Indicator_Region_Rec.DIM3_LEVEL_VALUE_ID)
              ,DECODE(p_Indicator_Region_Rec.DIM4_LEVEL_VALUE_ID,'+',NULL,'-',NULL,
                      p_Indicator_Region_Rec.DIM4_LEVEL_VALUE_ID)
              ,DECODE(p_Indicator_Region_Rec.DIM5_LEVEL_VALUE_ID,'+',NULL,'-',NULL,
                      p_Indicator_Region_Rec.DIM5_LEVEL_VALUE_ID)
              ,DECODE(p_Indicator_Region_Rec.DIM6_LEVEL_VALUE_ID,'+',NULL,'-',NULL,
                      p_Indicator_Region_Rec.DIM6_LEVEL_VALUE_ID)
              ,DECODE(p_Indicator_Region_Rec.DIM7_LEVEL_VALUE_ID,'+',NULL,'-',NULL,
                      p_Indicator_Region_Rec.DIM7_LEVEL_VALUE_ID)
              ,p_Indicator_Region_Rec.PLAN_ID
              ,sysdate
              ,FND_GLOBAL.USER_ID
              ,sysdate
              ,FND_GLOBAL.USER_ID
              ,FND_GLOBAL.LOGIN_ID);

  open c;
  fetch c into l_rowid;
  IF c%notfound then
    close c;
    raise NO_DATA_FOUND;
  END IF;
  IF c%isopen then close c; END IF;

  COMMIT;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  l_error_Tbl := x_error_Tbl;
  BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
  --rmohanty commented 3lines, on Unique constraint error, the Page broke
  --and user was not able to continue
  --htp.p('BIS_INDICATOR_REGION_PVT.Create_User_Ind_Selection: '
   --     ||SQLERRM);
 -- htp.para;
 -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_User_Ind_Selection;

-- *************************************************
Procedure Retrieve_User_Ind_Selections(
        p_api_version           IN NUMBER,
        p_user_id               IN NUMBER ,
        p_user_name             IN VARCHAR2 ,
        p_plug_id               IN NUMBER ,
        p_all_info              IN VARCHAR2 Default FND_API.G_TRUE,
        x_Indicator_Region_Tbl
          OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
cursor c_user_ind_selection is
   SELECT distinct a.ind_selection_id
     ,a.user_id
     ,a.target_level_id
     ,a.label
     ,a.plug_id
     ,a.dimension1_level_value
     ,a.dimension2_level_value
     ,a.dimension3_level_value
     ,a.dimension4_level_value
     ,a.dimension5_level_value
     ,a.dimension6_level_value
     ,a.dimension7_level_value
     ,a.responsibility_id
     ,a.plan_id
  FROM   bis_user_ind_selections  a
         ,fnd_user_resp_groups    b
         ,bis_indicators c
         ,bis_target_levels d
  WHERE a.user_id = p_user_id
  AND   a.plug_id = p_plug_id
  AND   a.user_id = b.user_id
  AND   b.start_date <= sysdate
  AND   NVL(b.end_date, sysdate) >= sysdate
  AND   d.target_level_id = a.target_level_id
  AND   d.indicator_id = c.indicator_id
  ORDER BY  a.ind_selection_id;

l_Indicator_Region_rec  BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type;
l_Target_level_rec      BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_Target_level_rec_p    BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_Org_level_value_Rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_dim1_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_dim2_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_dim3_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_dim4_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_dim5_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
-- mdamle 01/15/2001 - Add Dim6 and Dim7
l_dim6_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_dim7_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;

l_error_Tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
l_sob_level_id  NUMBER;
l_time_level_id NUMBER;
l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;

l_Org_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;


BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR c_userIndSelection in c_user_ind_selection LOOP

    l_Indicator_Region_Rec.ind_selection_id
      := c_userIndSelection.ind_selection_id;
    l_Indicator_Region_rec.user_id := p_user_id;
    l_Indicator_Region_rec.user_name := p_user_name;
    l_Indicator_Region_rec.plug_id := p_plug_id;
    l_Indicator_Region_Rec.Target_Level_ID
      := c_userIndSelection.target_level_id;
    l_Indicator_Region_Rec.Label := c_userIndSelection.label;
	-- mdamle 01/15/2001 - Use Dim6 and Dim7
    -- l_Indicator_Region_Rec.Org_Level_Value_Id
    --  := c_userIndSelection.Org_Level_Value;
    l_Indicator_Region_Rec.Dim1_Level_Value_ID
      := c_userIndSelection.dimension1_level_value;
    l_Indicator_Region_Rec.Dim2_Level_Value_ID
      := c_userIndSelection.dimension2_level_value;
    l_Indicator_Region_Rec.Dim3_Level_Value_ID
      := c_userIndSelection.dimension3_level_value;
    l_Indicator_Region_Rec.Dim4_Level_Value_ID
      := c_userIndSelection.dimension4_level_value;
    l_Indicator_Region_Rec.Dim5_Level_Value_ID
      := c_userIndSelection.dimension5_level_value;
	-- mdamle 01/15/2001 - Add Dim6 and Dim7
    l_Indicator_Region_Rec.Dim6_Level_Value_ID
      := c_userIndSelection.dimension6_level_value;
    l_Indicator_Region_Rec.Dim7_Level_Value_ID
      := c_userIndSelection.dimension7_level_value;

    l_Indicator_Region_Rec.Plan_ID
      := c_userIndSelection.Plan_ID;

    x_Indicator_Region_tbl(x_Indicator_Region_tbl.count+1)
      := l_Indicator_Region_Rec;

  END LOOP;

  IF p_all_info = FND_API.G_TRUE THEN

     FOR i in 1..x_Indicator_Region_tbl.count LOOP

         l_target_level_Rec.Target_level_ID :=
           x_Indicator_Region_Tbl(i).Target_Level_ID;

		 -- mdamle 01/15/2001 - Resequence Dimensions
		 IF (l_target_level_rec.org_level_id IS NOT NULL) AND
            (l_target_level_rec.time_level_id IS NOT NULL) THEN
	    l_target_level_rec_p := l_target_level_rec;
            BIS_UTILITIES_PVT.resequence_dim_levels(l_target_level_rec_p,
					'N',
                     l_target_level_Rec,
				     x_Error_tbl);
		 end if;

	 l_Target_level_rec_p := l_Target_level_rec;
         BIS_TARGET_LEVEL_PVT.Retrieve_Target_Level (
           p_api_version         => 1.0,
           p_Target_level_rec     => l_Target_level_rec_p,
           p_all_info            => FND_API.G_FALSE,
           x_Target_level_rec    => l_Target_level_rec,
           x_return_status       => x_return_status,
           x_error_Tbl           => x_error_Tbl
         );

		 -- mdamle 01/15/2001 - Resequence Dimensions
         l_target_level_rec_p := l_target_level_rec;
         BIS_UTILITIES_PVT.resequence_dim_levels(l_target_level_rec_p,
					'R',
                     l_target_level_Rec,
				     x_Error_tbl);

         x_Indicator_Region_Tbl(i).Target_Level_short_name
           := l_Target_level_rec.Target_Level_Short_Name;
         x_Indicator_Region_Tbl(i).Target_Level_name
           := l_Target_level_rec.Target_Level_Name;


		 -- mdamle 01/15/2001 - Use Dim6 and Dim7
/*
         l_Org_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Org_Level_id;
         l_Org_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).org_level_value_id;

         l_Org_Level_Value_Rec_p := l_Org_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.Org_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Org_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Org_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => x_error_Tbl
         );
         x_Indicator_Region_tbl(i).org_level_value_name
           := l_Org_Level_Value_Rec.Dimension_Level_Value_Name;


         IF l_Org_Level_Value_Rec.Dimension_Level_Short_Name = 'SET OF BOOKS'
         THEN
           BIS_TARGET_PVT.G_SET_OF_BOOK_ID :=
           TO_NUMBER(x_Indicator_Region_tbl(i).org_level_value_id);
         END IF;
*/

         l_Dim1_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension1_Level_id;
         l_Dim1_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim1_level_value_id;

        IF (l_Dim1_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
	l_Dim_Level_Value_Rec_p := l_Dim1_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim1_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim1_level_value_name
           := l_Dim1_Level_Value_Rec.Dimension_Level_Value_Name;
        END IF;

         l_Dim2_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension2_Level_id;
         l_Dim2_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim2_level_value_id;

        IF (l_Dim2_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
	 l_Dim_Level_Value_Rec_p := l_Dim2_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim2_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim2_level_value_name
           := l_Dim2_Level_Value_Rec.Dimension_Level_Value_Name;
        END IF;

         l_Dim3_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension3_Level_id;
         l_Dim3_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim3_level_value_id;

       IF (l_Dim3_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
         l_Dim_Level_Value_Rec_p := l_Dim3_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim3_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim3_level_value_name
           := l_Dim3_Level_Value_Rec.Dimension_Level_Value_Name;
       END IF;

         l_Dim4_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension4_Level_id;
         l_Dim4_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim4_level_value_id;

       IF (l_Dim4_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
         l_Dim_Level_Value_Rec_p := l_Dim4_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim4_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim4_level_value_name
           := l_Dim4_Level_Value_Rec.Dimension_Level_Value_Name;
       END IF;

         l_Dim5_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension5_Level_id;
         l_Dim5_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim5_level_value_id;

       IF (l_Dim5_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
         l_Dim_Level_Value_Rec_p := l_Dim5_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim5_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim5_level_value_name
           := l_Dim5_Level_Value_Rec.Dimension_Level_Value_Name;
       END IF;

         l_Dim6_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension6_Level_id;
         l_Dim6_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim6_level_value_id;

	   -- mdamle 01/15/2001 - Add Dim6 and Dim7
       IF (l_Dim6_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
         l_Dim_Level_Value_Rec_p := l_Dim6_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim6_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim6_level_value_name
           := l_Dim6_Level_Value_Rec.Dimension_Level_Value_Name;
       END IF;

         l_Dim7_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension7_Level_id;
         l_Dim7_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim7_level_value_id;

	   -- mdamle 01/15/2001 - Add Dim6 and Dim7
       IF (l_Dim7_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
         l_Dim_Level_Value_Rec_p := l_Dim7_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim7_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim7_level_value_name
           := l_Dim7_Level_Value_Rec.Dimension_Level_Value_Name;
       END IF;

       IF (x_Indicator_Region_Tbl(i).Plan_ID is NOT NULL) THEN
         SELECT short_name, name
         INTO x_Indicator_Region_Tbl(i).Plan_Short_Name
            , x_Indicator_Region_Tbl(i).Plan_Name
         FROM BISBV_BUSINESS_PLANS
         WHERE plan_id = x_Indicator_Region_Tbl(i).Plan_ID;
       END IF;

     END LOOP;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    htp.p('BIS_INDICATOR_REGION_PVT.Retrieve_User_Ind_Selections:'); htp.para;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    htp.p('BIS_INDICATOR_REGION_PVT.Retrieve_User_Ind_Selections:G_EXC_UNEXPECTED_ERROR'); htp.para;
    RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    htp.p('BIS_INDICATOR_REGION_PVT.Retrieve_User_Ind_Selections:OTHERS'); htp.para;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--

END Retrieve_User_Ind_Selections;

-- $$
Procedure Retrieve_User_Ind_Selections(
        p_api_version           IN NUMBER
      , p_all_info              IN VARCHAR2 Default FND_API.G_TRUE
      , p_Target_level_id       IN NUMBER
      , x_Indicator_Region_Tbl
          OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type
      , x_return_status	        OUT NOCOPY VARCHAR2
      , x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_Indicator_Region_rec  BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type;
  l_Target_level_rec      BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
  l_Target_level_rec_p    BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
  l_Org_level_value_Rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim1_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim2_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim3_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim4_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim5_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  -- mdamle 01/15/2001 - Add Dim6 and Dim7
  l_dim6_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim7_level_value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;

  l_error_Tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_Org_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;

  CURSOR c_user_ind_selection IS
    select * from bis_user_ind_selections
    where Target_Level_ID = p_target_level_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR c_userIndSelection in c_user_ind_selection LOOP

    l_Indicator_Region_Rec.ind_selection_id
      := c_userIndSelection.ind_selection_id;
    l_Indicator_Region_Rec.Target_Level_ID
      := c_userIndSelection.target_level_id;
    l_Indicator_Region_Rec.Label := c_userIndSelection.label;
	-- mdamle 01/15/2001 - Use Dim6 and Dim7
    -- l_Indicator_Region_Rec.Org_Level_Value_Id
    --  := c_userIndSelection.Org_Level_Value;
    l_Indicator_Region_Rec.Dim1_Level_Value_ID
      := c_userIndSelection.dimension1_level_value;
    l_Indicator_Region_Rec.Dim2_Level_Value_ID
      := c_userIndSelection.dimension2_level_value;
    l_Indicator_Region_Rec.Dim3_Level_Value_ID
      := c_userIndSelection.dimension3_level_value;
    l_Indicator_Region_Rec.Dim4_Level_Value_ID
      := c_userIndSelection.dimension4_level_value;
    l_Indicator_Region_Rec.Dim5_Level_Value_ID
      := c_userIndSelection.dimension5_level_value;
    -- mdamle 01/15/2001 - Add Dim6 and Dim7
    l_Indicator_Region_Rec.Dim6_Level_Value_ID
      := c_userIndSelection.dimension6_level_value;
    l_Indicator_Region_Rec.Dim7_Level_Value_ID
      := c_userIndSelection.dimension7_level_value;

    l_Indicator_Region_Rec.Plan_ID
      := c_userIndSelection.Plan_ID;

    x_Indicator_Region_tbl(x_Indicator_Region_tbl.count+1)
      := l_Indicator_Region_Rec;

  END LOOP;

  IF p_all_info = FND_API.G_TRUE THEN

     FOR i in 1..x_Indicator_Region_tbl.count LOOP

         l_target_level_Rec.Target_level_ID :=
           x_Indicator_Region_Tbl(i).Target_Level_ID;

		 -- mdamle 01/15/2001 - Resequence Dimensions
         IF (l_target_level_rec.org_level_id IS NOT NULL) AND
            (l_target_level_rec.time_level_id IS NOT NULL) THEN
	    l_target_level_rec_p := l_target_level_rec;
             BIS_UTILITIES_PVT.resequence_dim_levels(l_target_level_rec_p,
					'N',
                     l_target_level_Rec,
				     x_Error_tbl);
	     END IF;

         l_Target_level_rec_p := l_Target_level_rec;
         BIS_TARGET_LEVEL_PVT.Retrieve_Target_Level (
           p_api_version         => 1.0,
           p_Target_level_rec     => l_Target_level_rec_p,
           p_all_info            => FND_API.G_FALSE,
           x_Target_level_rec    => l_Target_level_rec,
           x_return_status       => x_return_status,
           x_error_Tbl           => x_error_Tbl
         );

		 -- mdamle 01/15/2001 - Resequence Dimensions
         l_target_level_rec_p := l_target_level_rec;
         BIS_UTILITIES_PVT.resequence_dim_levels(l_target_level_rec_p,
					'R',
                     l_target_level_Rec,
				     x_Error_tbl);

         x_Indicator_Region_Tbl(i).Target_Level_short_name
           := l_Target_level_rec.Target_Level_Short_Name;
         x_Indicator_Region_Tbl(i).Target_Level_name
           := l_Target_level_rec.Target_Level_Name;

		 -- mdamle 01/15/2001 - Use Dim6 and Dim7
		 /*
         l_Org_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Org_Level_id;
         l_Org_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).org_level_value_id;

         l_Org_Level_Value_Rec_p := l_Org_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.Org_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Org_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Org_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => x_error_Tbl
         );
         x_Indicator_Region_tbl(i).org_level_value_name
           := l_Org_Level_Value_Rec.Dimension_Level_Value_Name;
        */

         l_Dim1_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension1_Level_id;
         l_Dim1_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim1_level_value_id;

        IF (l_Dim1_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
	 l_Dim_Level_Value_Rec_p := l_Dim1_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim1_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim1_level_value_name
           := l_Dim1_Level_Value_Rec.Dimension_Level_Value_Name;
        END IF;

         l_Dim2_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension2_Level_id;
         l_Dim2_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim2_level_value_id;

        IF (l_Dim2_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
	 l_Dim_Level_Value_Rec_p := l_Dim2_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim2_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim2_level_value_name
           := l_Dim2_Level_Value_Rec.Dimension_Level_Value_Name;
        END IF;

         l_Dim3_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension3_Level_id;
         l_Dim3_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim3_level_value_id;

       IF (l_Dim3_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
         l_Dim_Level_Value_Rec_p := l_Dim3_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim3_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim3_level_value_name
           := l_Dim3_Level_Value_Rec.Dimension_Level_Value_Name;
       END IF;

         l_Dim4_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension4_Level_id;
         l_Dim4_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim4_level_value_id;

       IF (l_Dim4_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
         l_Dim_Level_Value_Rec_p := l_Dim4_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim4_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim4_level_value_name
           := l_Dim4_Level_Value_Rec.Dimension_Level_Value_Name;
       END IF;

         l_Dim5_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension5_Level_id;
         l_Dim5_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim5_level_value_id;

       IF (l_Dim5_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
         l_Dim_Level_Value_Rec_p := l_Dim5_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim5_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim5_level_value_name
           := l_Dim5_Level_Value_Rec.Dimension_Level_Value_Name;
       END IF;

       -- mdamle 01/15/2001 - Add Dim6 and Dim7
        l_Dim6_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension6_Level_id;
         l_Dim6_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim6_level_value_id;

       IF (l_Dim6_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
         l_Dim_Level_Value_Rec_p := l_Dim6_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim6_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim6_level_value_name
           := l_Dim6_Level_Value_Rec.Dimension_Level_Value_Name;
       END IF;

       -- mdamle 01/15/2001 - Add Dim6 and Dim7
        l_Dim7_Level_Value_Rec.Dimension_Level_ID
           := l_Target_level_Rec.Dimension7_Level_id;
         l_Dim7_Level_Value_Rec.Dimension_Level_Value_ID
           := x_Indicator_Region_tbl(i).dim7_level_value_id;

       IF (l_Dim7_Level_Value_Rec.Dimension_Level_Value_ID is NOT NULL) THEN
         l_Dim_Level_Value_Rec_p := l_Dim7_Level_Value_Rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
         ( p_api_version         => 1.0
          ,p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
          ,x_Dim_Level_Value_Rec => l_Dim7_Level_Value_Rec
          ,x_return_status       => x_return_status
          ,x_error_Tbl           => l_error_Tbl
         );
         x_Indicator_Region_tbl(i).dim7_level_value_name
           := l_Dim7_Level_Value_Rec.Dimension_Level_Value_Name;
       END IF;

       IF (x_Indicator_Region_Tbl(i).Plan_ID is NOT NULL) THEN
         SELECT name
         INTO x_Indicator_Region_Tbl(i).Plan_Name
         FROM BISBV_BUSINESS_PLANS
         WHERE plan_id = x_Indicator_Region_Tbl(i).Plan_ID;
       END IF;

     END LOOP;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
     RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_User_Ind_Selections;


Procedure Update_User_Ind_Selection(
        p_api_version           IN NUMBER,
        p_user_id               IN NUMBER Default BIS_UTILITIES_PUB.G_NULL_NUM,
        p_user_name             IN VARCHAR2 Default BIS_UTILITIES_PUB.G_NULL_CHAR,
        p_plug_id               IN NUMBER ,
        p_Indicator_Region_Rec
          IN BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_User_Ind_Selection;


Procedure Delete_User_Ind_Selections(
        p_api_version           IN NUMBER,
        p_user_id               IN NUMBER Default BIS_UTILITIES_PUB.G_NULL_NUM,
        p_user_name             IN VARCHAR2 Default BIS_UTILITIES_PUB.G_NULL_CHAR,
        p_plug_id               IN NUMBER,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM BIS_USER_IND_SELECTIONS
  WHERE user_id = p_user_id
  AND   plug_id = p_plug_id;

  COMMIT;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    htp.p('BIS_INDICATOR_REGION_PVT.Delete_User_Ind_Selections:G_EXC_ERROR'); htp.para;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    htp.p('BIS_INDICATOR_REGION_PVT.Delete_User_Ind_Selections:G_EXC_UNEXPECTED_ERROR'); htp.para;
    RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    htp.p('BIS_INDICATOR_REGION_PVT.Delete_User_Ind_Selections:OTHERS'); htp.para;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--

END Delete_User_Ind_Selections;

Procedure Retrieve_User_Labels(
        p_user_id             IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM,
        p_user_name           IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR,
        p_plug_id             IN NUMBER,
        x_label_tbl           OUT NOCOPY BIS_INDICATOR_REGION_PVT.User_Label_Tbl_Type,
        x_return_status	      OUT NOCOPY VARCHAR2
)
IS
i          NUMBER := 0;
l_user_id  NUMBER;
CURSOR cr_label IS
  SELECT DISTINCT uis.ind_selection_id
                , uis.label
  FROM bis_user_ind_selections uis
  WHERE uis.user_id = l_user_ID
  AND uis.plug_id = p_Plug_ID;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

--   IF BIS_UTILITIES_PUB.Value_Not_Missing(p_user_ID) THEN
   IF BIS_UTILITIES_PUB.Value_Not_Missing(p_user_ID) = FND_API.G_TRUE THEN
     l_User_ID := p_User_ID;
   ELSE
     SELECT user_id
     INTO l_user_id
     FROM fnd_user
     WHERE user_name = p_user_name;
   END IF;

   FOR crlabel IN cr_label LOOP
     i := i+1;
     x_label_tbl(i).Ind_Selection_ID := crlabel.Ind_Selection_ID;
     x_label_tbl(i).Plug_ID := p_plug_id;
     x_label_tbl(i).User_ID := l_user_id;
     x_label_tbl(i).Label := crlabel.label;
   END LOOP;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Retrieve_User_Labels;



Procedure Validate_User_Ind_Selection(
      p_api_version           IN NUMBER,
      p_event                 IN VARCHAR2,
      p_user_id               IN NUMBER,
      p_Indicator_Region_Rec  IN BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type,
      x_return_status	      OUT NOCOPY VARCHAR2
)
IS
e_InvalidRecordException EXCEPTION;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   Validate_Required_Fields(
    p_event                => p_event
   ,p_user_id              => p_user_id
   ,p_Indicator_Region_Rec => p_Indicator_Region_Rec
   ,x_return_status        => x_return_status);

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE e_InvalidRecordException;
   END IF;

   IF p_event = 'CREATE' THEN
      null;
   ELSIF p_event = 'UPDATE' THEN
      null;
   ELSIF p_event = 'RETRIEVE' THEN
      null;
   ELSIF p_event = 'DELETE' THEN
      null;
   ELSE
      RAISE e_InvalidEventException;
   END IF;

EXCEPTION
   when e_InvalidEventException OR e_InvalidRecordException then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Validate_User_Ind_Selection;


Procedure Validate_Required_Fields(
        p_event                IN VARCHAR2,
        p_user_id              IN NUMBER,
        p_Indicator_Region_Rec
          IN BIS_Indicator_Region_PUB.Indicator_Region_Rec_Type,
        x_return_status        OUT NOCOPY VARCHAR2
)
IS
e_MissingValuesException EXCEPTION;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_event NOT IN ( 'CREATE',
                       'UPDATE',
                       'RETRIEVE',
                       'DELETE')
   THEN
      RAISE e_InvalidEventException;
   END IF;

/*
   IF (NOT BIS_UTILITIES_PUB.Value_Not_Missing(
                             p_Indicator_Region_Rec.USER_ID)) OR
      (NOT BIS_UTILITIES_PUB.Value_Not_Missing(
                             p_Indicator_Region_Rec.PLUG_ID)) THEN
*/
   IF BIS_UTILITIES_PUB.Value_Not_Missing(p_Indicator_Region_Rec.USER_ID)
      = FND_API.G_FALSE
   OR BIS_UTILITIES_PUB.Value_Not_Missing(p_Indicator_Region_Rec.PLUG_ID)
      = FND_API.G_FALSE
   THEN

      RAISE e_MissingValuesException;

      -- Don't need to validate rest if retrieving or deleting
      IF p_event IN ('CREATE','UPDATE') THEN
/*
        IF (NOT BIS_UTILITIES_PUB.Value_Not_Missing(
                              p_Indicator_Region_Rec.Target_Level_ID)) OR
           (NOT BIS_UTILITIES_PUB.Value_Not_Missing(
                             p_Indicator_Region_Rec.org_level_value_id)) THEN
*/
        IF BIS_UTILITIES_PUB.Value_Not_Missing(
             p_Indicator_Region_Rec.Target_Level_ID) = FND_API.G_FALSE
  	    -- mdamle 01/15/2001 - Use Dim6 and Dim7
        -- OR BIS_UTILITIES_PUB.Value_Not_Missing(
        --     p_Indicator_Region_Rec.Org_Level_Value_ID) = FND_API.G_FALSE
        THEN
           RAISE e_MissingValuesException;
        END IF;
      END IF;
   END IF;

Exception
   when e_InvalidEventException then
      RAISE;
   when e_MissingValuesException then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Validate_Required_Fields;

END ;-- BIS_INDICATOR_REGION_PVT;

/
