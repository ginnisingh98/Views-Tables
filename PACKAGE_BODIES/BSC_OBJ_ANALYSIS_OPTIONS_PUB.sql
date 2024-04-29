--------------------------------------------------------
--  DDL for Package Body BSC_OBJ_ANALYSIS_OPTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_OBJ_ANALYSIS_OPTIONS_PUB" AS
/* $Header: BSCPOAOB.pls 120.2.12000000.2 2007/07/27 09:48:46 akoduri noship $ */


/************************************************************************************
--	API name 	: Check_UserLevel_Values
--	Type		: Private
--	Function	:
--	This API is used to set the user level values . This will be called whenever
--      the default is changed.
--
************************************************************************************/

PROCEDURE Check_UserLevel_Values (
  p_commit              IN VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator           IN NUMBER
 ,p_cascade_shared      IN BOOLEAN := FALSE
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
)IS

  l_AnaOpt0_Default bsc_kpi_analysis_groups.default_value%TYPE := 0;
  l_AnaOpt1_Default bsc_kpi_analysis_groups.default_value%TYPE := 0;
  l_AnaOpt2_Default bsc_kpi_analysis_groups.default_value%TYPE := 0;

  l_AO1_Parent_Id bsc_kpi_analysis_options_b.parent_option_id%TYPE := 0;
  l_AO1_GrandParent_Id bsc_kpi_analysis_options_b.grandparent_option_id%TYPE := 0;
  l_AO2_Parent_Id bsc_kpi_analysis_options_b.parent_option_id%TYPE := 0;
  l_AO2_GrandParent_Id bsc_kpi_analysis_options_b.grandparent_option_id%TYPE := 0;
  l_Max_Group_Id  NUMBER := 0;
  l_Parent_Group_Id bsc_kpi_analysis_groups.analysis_group_id%TYPE;
  l_GrandParent_Group_Id bsc_kpi_analysis_groups.analysis_group_id%TYPE;


  CURSOR c_shared_objs IS
  SELECT
    indicator
  FROM
    bsc_kpis_b
  WHERE
    source_indicator = p_Indicator AND
    prototype_flag <> 2 AND
    share_flag = 2;

BEGIN
  SAVEPOINT  Check_UserLevel_Values_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  SELECT
    a0_default,a1_default,a2_default
  INTO
    l_AnaOpt0_Default, l_AnaOpt1_Default, l_AnaOpt2_Default
  FROM
    bsc_db_color_ao_defaults_v
  WHERE
    indicator = p_Indicator;

  SELECT
    MAX(analysis_group_id)
  INTO
    l_Max_Group_Id
  FROM
    bsc_kpi_analysis_groups
  WHERE
    indicator = p_Indicator;

  IF l_Max_Group_Id >= 1 THEN
    Get_Parent_GrandParent_Ids(
      p_Indicator             =>  p_Indicator
     ,p_Analysis_Group_Id     =>  1
     ,p_Parent_Id             =>  l_AnaOpt0_Default
     ,p_GrandParent_Id        =>  0
     ,p_Independent_Par_Id    =>  0
     ,x_Parent_Id             =>  l_AO1_Parent_Id
     ,x_GrandParent_Id        =>  l_AO1_GrandParent_Id
     ,x_Parent_Group_Id       =>  l_Parent_Group_Id
     ,x_GrandParent_Group_Id  =>  l_GrandParent_Group_Id
    );
  END IF;

  IF l_Max_Group_Id = 2 THEN
    Get_Parent_GrandParent_Ids(
      p_Indicator             =>  p_Indicator
     ,p_Analysis_Group_Id     =>  2
     ,p_Parent_Id             =>  l_AnaOpt1_Default
     ,p_GrandParent_Id        =>  l_AnaOpt0_Default
     ,p_Independent_Par_Id    =>  0
     ,x_Parent_Id             =>  l_AO2_Parent_Id
     ,x_GrandParent_Id        =>  l_AO2_GrandParent_Id
     ,x_Parent_Group_Id       =>  l_Parent_Group_Id
     ,x_GrandParent_Group_Id  =>  l_GrandParent_Group_Id
    );
  END IF;

  UPDATE bsc_kpi_analysis_options_b
  SET
     user_level0 = 2
    ,user_level1 = 2
  WHERE indicator = p_Indicator;

  UPDATE bsc_kpi_analysis_options_b
  SET
     user_level0 = 1
    ,user_level1 = 1
  WHERE
    indicator = p_Indicator AND
    ((analysis_group_id = 0 AND option_id = l_AnaOpt0_Default) OR
     (analysis_group_id = 1 AND option_id = l_AnaOpt1_Default AND parent_option_id = l_AO1_Parent_Id) OR
     (analysis_group_id = 2 AND option_id = l_AnaOpt2_Default AND parent_option_id = l_AO2_Parent_Id AND grandparent_option_id = l_AO2_GrandParent_Id));


  IF p_cascade_shared THEN
    FOR cd in c_shared_objs LOOP
      UPDATE bsc_kpi_analysis_options_b
      SET
         user_level0 = 2
        ,user_level1 = 2
      WHERE indicator = cd.Indicator;

      UPDATE bsc_kpi_analysis_options_b
      SET
         user_level0 = 1
        ,user_level1 = 1
      WHERE
        indicator = cd.Indicator AND
        ((analysis_group_id = 0 AND option_id = l_AnaOpt0_Default) OR
         (analysis_group_id = 1 AND option_id = l_AnaOpt1_Default AND parent_option_id = l_AO1_Parent_Id) OR
         (analysis_group_id = 2 AND option_id = l_AnaOpt2_Default AND parent_option_id = l_AO2_Parent_Id AND grandparent_option_id = l_AO2_GrandParent_Id));

    END LOOP;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK TO Check_UserLevel_Values_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Check_UserLevel_Values ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Check_UserLevel_Values ';
        END IF;
END Check_UserLevel_Values;

/************************************************************************************
--	API name 	: Update_Change_DimSet
--	Type		: Private
--	Function	:
--	This API sets the change_dim_set flag of bsc_kpi_analysis_groups
--      If the current analysis group has this flag set to 1 , the flag corresponding
--      to other analysis groups will be reset to 0
--      change_dim_set decides , from which group the dimension set should be
--      picked up in the current analysis_option combination
--      If none of the analysis groups has this flag set to 0, then
--      dimension set 0 will be used.
************************************************************************************/
PROCEDURE Update_Change_DimSet (
  p_commit              IN  VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator           IN  NUMBER
 ,p_Analysis_Group_Id   IN  NUMBER
 ,p_Change_Dim_Set      IN  NUMBER
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
)IS

BEGIN
  SAVEPOINT  Update_Change_DimSet_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  UPDATE
    bsc_kpi_analysis_groups
  SET
    change_dim_set = p_Change_Dim_Set
  WHERE
    indicator = p_Indicator AND
    analysis_group_id = p_Analysis_Group_Id;

  IF p_Change_Dim_Set = 1 THEN
    UPDATE
      bsc_kpi_analysis_groups
    SET
      change_dim_set = 0
    WHERE
      indicator = p_Indicator AND
      analysis_group_id <> p_Analysis_Group_Id;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK TO Update_Change_DimSet_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Update_Change_DimSet ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Update_Change_DimSet ';
        END IF;
END Update_Change_DimSet;


/************************************************************************************
--	API name 	: Update_Default_Flag_Val
--	Type		: Private
--	Function	:
--      Updates the bsc_kpi_analysis_groups with the current option id
--	Also Cascade the dependent default value of the related groups i.e
--         (bsc_kpi_analysis_groups dependency_flag = 1)
--	1. When child is set as the default make its parent as the default for
--	   the parent analysis group
--	2. When parent is set as the default, reset the default in child group to 0

************************************************************************************/

PROCEDURE Update_Default_Flag_Value(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Anal_Opt_Rec          IN   BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS

  CURSOR c_dependency_flag(p_ana_grp_id NUMBER) IS
  SELECT
    dependency_flag
  FROM
    bsc_kpi_analysis_groups
  WHERE indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id
  AND analysis_group_id = p_ana_grp_id;

  l_Dependency01       bsc_kpi_analysis_groups.dependency_flag%TYPE := 0;
  l_Dependency12       bsc_kpi_analysis_groups.dependency_flag%TYPE := 0;

  l_Temp_Ana_Grp_Id    bsc_kpi_analysis_options_b.analysis_group_id%TYPE;
  l_Temp_Ana_Option_Id bsc_kpi_analysis_options_b.option_id%TYPE;

BEGIN

  SAVEPOINT  Update_Default_Flag_Val_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  --Only if the default value is modified
  UPDATE
    bsc_kpi_analysis_groups
  SET
    default_value = p_Anal_Opt_Rec.Bsc_Analysis_Option_Id
  WHERE
    indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id AND
    analysis_group_id = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id;


  OPEN c_dependency_flag(1);
  FETCH c_dependency_flag INTO l_Dependency01;
  CLOSE c_dependency_flag;

  OPEN c_dependency_flag(2);
  FETCH c_dependency_flag INTO l_Dependency12;
  CLOSE c_dependency_flag;

  IF ( l_Dependency01 = 1) THEN
    CASE p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
      WHEN 0 THEN
        l_Temp_Ana_Grp_Id := 1;
        l_Temp_Ana_Option_Id := 0;
      WHEN 1 THEN
        l_Temp_Ana_Grp_Id := 0;
        l_Temp_Ana_Option_Id := p_Anal_Opt_Rec.Bsc_Parent_Option_Id;--l_Parent_Option_Id;
      WHEN 2 THEN
        l_Temp_Ana_Grp_Id := 0;
        l_Temp_Ana_Option_Id := p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;--l_GrandParent_Opt_Id;
    END CASE;

    UPDATE
      bsc_kpi_analysis_groups
    SET
      default_value = l_Temp_Ana_Option_Id
    WHERE
      indicator         = p_Anal_Opt_Rec.Bsc_Kpi_Id AND
      analysis_group_id = l_Temp_Ana_Grp_Id;
  END IF;

  IF ( l_Dependency12 = 1) THEN
     CASE p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
       WHEN 0 THEN
         l_Temp_Ana_Grp_Id := 2;
         l_Temp_Ana_Option_Id := 0;
       WHEN 1 THEN
         l_Temp_Ana_Grp_Id := 2;
         l_Temp_Ana_Option_Id := 0;
       WHEN 2 THEN
         l_Temp_Ana_Grp_Id := 1;
         l_Temp_Ana_Option_Id := p_Anal_Opt_Rec.Bsc_Parent_Option_Id;
     END CASE;

     UPDATE
       bsc_kpi_analysis_groups
     SET
       default_value = l_Temp_Ana_Option_Id
     WHERE
       indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id AND
       analysis_group_id = l_Temp_Ana_Grp_Id;
  END IF;


  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;
EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK TO Update_Default_Flag_Val_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Update_Default_Flag_Val ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Update_Default_Flag_Val ';
        END IF;
END Update_Default_Flag_Value;


/************************************************************************************
--	API name 	: Check_YTD_Apply
--	Type		: Private
--	Function	:
--
************************************************************************************/
PROCEDURE Check_YTD_Apply(
  p_commit         IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator      IN   NUMBER
 ,x_return_status  OUT NOCOPY   VARCHAR2
 ,x_msg_count      OUT NOCOPY   NUMBER
 ,x_msg_data       OUT NOCOPY   VARCHAR2
) IS

   l_YTD_Value bsc_kpi_calculations.default_Value%TYPE;
   l_AO0_Default bsc_kpi_analysis_groups.default_value%TYPE;
   l_AO1_Default bsc_kpi_analysis_groups.default_value%TYPE;
   l_AO2_Default bsc_kpi_analysis_groups.default_value%TYPE;
   l_Count NUMBER := 0;
   CURSOR c_YTD_Value IS
   SELECT
     default_value
   FROM
     bsc_kpi_calculations
   WHERE
     indicator = p_Indicator AND
     calculation_id = 2; -- YTD Default Value

   CURSOR c_Is_YTD_Valid(p_AO0 NUMBER,p_AO1 NUMBER, p_AO2 NUMBER) IS
   SELECT
     COUNT(1)
   FROM
     bsc_kpi_analysis_measures_b km,
     bsc_sys_dataset_calc bd
   WHERE
     km.indicator = p_Indicator AND
     km.dataset_id = bd.dataset_id AND
     km.analysis_option0 = p_AO0 AND
     km.analysis_option1 = p_AO1 AND
     km.analysis_option2 = p_AO2 AND
     bd.disabled_calc_id = 2;


BEGIN
  SAVEPOINT  Check_YTD_Apply_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;


  OPEN c_YTD_Value;
  FETCH c_YTD_Value INTO l_YTD_Value;
  CLOSE c_YTD_Value;

  --If user didnt enable Color By Calulation based on YTD then no need to validate it
  IF l_YTD_Value = 0 THEN
    RETURN;
  END IF;

  SELECT
    a0_default,a1_default,a2_default
  INTO
    l_AO0_Default, l_AO1_Default, l_AO2_Default
  FROM
    bsc_db_color_ao_defaults_v
  WHERE
    indicator = p_Indicator;

  OPEN c_Is_YTD_Valid(l_AO0_Default, l_AO1_Default, l_AO2_Default);
  FETCH c_Is_YTD_Valid INTO l_Count;
  IF l_Count > 0 THEN
    -- If YTD calculation is disabled at the measure level then disable it for the new default kpi
      UPDATE
        bsc_kpi_calculations
      SET
        default_value = 0,
        user_level0 = 1,
        user_level1 = 1
      WHERE indicator = p_Indicator;

      IF BSC_COLOR_CALC_UTIL.Get_Obj_Color_Rollup_Type(p_Indicator) = BSC_COLOR_CALC_UTIL.DEFAULT_KPI THEN
         BSC_DESIGNER_PVT.ActionFlag_Change (
            x_indicator => p_Indicator
           ,x_newflag   => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
         );
      END IF;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;
EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK TO Check_YTD_Apply_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Val_If_YTD_Apply ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Val_If_YTD_Apply ';
        END IF;
END Check_YTD_Apply;


/************************************************************************************
--	API name 	: Check_Default_Props
--	Type		: Private
--	Function	:
--      1. Cascades the default flag change
--      2. Checks if atleast one series is selected as the default
--      3. Performs the validations required for color by kpi
--      4. If YTD is enabled, it checks whether this calculation holds good
--         for the current default combination
--      5. Marks the objective for color recalculation if the coloring is default
--         kpi based
************************************************************************************/
PROCEDURE Check_Default_Props(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Anal_Opt_Rec          IN   BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,p_cascade_shared        BOOLEAN := FALSE
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
)IS


  l_Old_Default_Value  bsc_kpi_analysis_groups.default_value%TYPE;
  l_commit             VARCHAR2(1) := FND_API.G_FALSE;
  l_Anal_Opt_Rec       BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
  l_Series_Id          bsc_kpi_analysis_measures_b.series_id%TYPE := 0;
  l_Budget_Flag        bsc_kpi_analysis_measures_b.budget_flag%TYPE := 1;
  CURSOR c_Old_Default_Value IS
  SELECT
    default_value
  FROM
    bsc_kpi_analysis_groups
  WHERE indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id
  AND analysis_group_id = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id;

  CURSOR c_Default_Series_Id (p_AO0 NUMBER, p_AO1 NUMBER, p_AO2 NUMBER) IS
  SELECT
    series_id,budget_flag
  FROM
    bsc_kpi_analysis_Measures_b
  WHERE
    analysis_option0 = p_AO0 AND
    analysis_option1 = p_AO1 AND
    analysis_option2 = p_AO2 AND
    default_value = 1;


  CURSOR c_shared_objs IS
  SELECT
    indicator
  FROM
    bsc_kpis_b
  WHERE
    source_indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id AND
    prototype_flag <> 2 AND
    share_flag = 2;

BEGIN
  SAVEPOINT  Check_Default_Props_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN  c_Old_Default_Value;
  FETCH c_Old_Default_Value INTO l_Old_Default_Value;
  CLOSE c_Old_Default_Value;

  l_Anal_Opt_Rec := p_Anal_Opt_Rec;
  -- No need to cascade any changes. This is not the default
  IF  p_Anal_Opt_Rec.Bsc_Option_Default_Value = 0 OR l_Old_Default_Value =  p_Anal_Opt_Rec.Bsc_Analysis_Option_Id THEN
    RETURN;
  END IF;

  Update_Default_Flag_Value (
     p_commit             =>  l_commit
    ,p_Anal_Opt_Rec       =>  p_Anal_Opt_Rec
    ,x_return_status      =>  x_return_status
    ,x_msg_count          =>  x_msg_count
    ,x_msg_data           =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_KPI_SERIES_PUB.Check_Series_Default_Props(
     p_commit             =>  l_commit
    ,p_Indicator          =>  p_Anal_Opt_Rec.Bsc_Kpi_Id
    ,x_return_status      =>  x_return_status
    ,x_msg_count          =>  x_msg_count
    ,x_msg_data           =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN c_Default_Series_Id(p_Anal_Opt_Rec.Bsc_Option_Group0, p_Anal_Opt_Rec.Bsc_Option_Group1, p_Anal_Opt_Rec.Bsc_Option_Group2);
  FETCH c_Default_Series_Id INTO l_Series_Id, l_Budget_Flag;
  CLOSE c_Default_Series_Id;


  BSC_KPI_SERIES_PUB.Check_Color_Props(
    p_commit           =>  FND_API.G_FALSE
   ,p_Indicator        =>  p_Anal_Opt_Rec.Bsc_Kpi_Id
   ,p_Analysis_Option0 =>  p_Anal_Opt_Rec.Bsc_Option_Group0
   ,p_Analysis_Option1 =>  p_Anal_Opt_Rec.Bsc_Option_Group1
   ,p_Analysis_Option2 =>  p_Anal_Opt_Rec.Bsc_Option_Group2
   ,p_Series_Id        =>  l_Series_Id
   ,p_Budget_Flag      =>  l_Budget_Flag
   ,p_Default_Flag     =>  1
   ,p_Dataset_Id       =>  p_Anal_Opt_Rec.Bsc_Dataset_Id
   ,x_return_status    =>  x_return_status
   ,x_msg_count        =>  x_msg_count
   ,x_msg_data         =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Validate_Calculations
  Check_YTD_Apply(
    p_commit             =>  l_commit
   ,p_Indicator          =>  p_Anal_Opt_Rec.Bsc_Kpi_Id
   ,x_return_status      =>  x_return_status
   ,x_msg_count          =>  x_msg_count
   ,x_msg_data           =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check Color Change
  IF BSC_COLOR_CALC_UTIL.Get_Obj_Color_Rollup_Type(p_Anal_Opt_Rec.Bsc_Kpi_Id) = BSC_COLOR_CALC_UTIL.DEFAULT_KPI THEN
     BSC_DESIGNER_PVT.ActionFlag_Change (
        x_indicator => p_Anal_Opt_Rec.Bsc_Kpi_Id
       ,x_newflag   => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
     );
  END IF;

  IF p_cascade_shared THEN -- cascade to shared

    FOR cd in c_shared_objs LOOP
       l_Anal_Opt_Rec.Bsc_Kpi_Id := cd.Indicator;
       Update_Default_Flag_Value (
          p_commit             =>  l_commit
         ,p_Anal_Opt_Rec       =>  l_Anal_Opt_Rec
         ,x_return_status      =>  x_return_status
         ,x_msg_count          =>  x_msg_count
         ,x_msg_data           =>  x_msg_data
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       BSC_KPI_SERIES_PUB.Check_Series_Default_Props(
          p_commit             =>  l_commit
         ,p_Indicator          =>  l_Anal_Opt_Rec.Bsc_Kpi_Id
         ,x_return_status      =>  x_return_status
         ,x_msg_count          =>  x_msg_count
         ,x_msg_data           =>  x_msg_data
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       Check_YTD_Apply(
         p_commit             =>  l_commit
        ,p_Indicator          =>  l_Anal_Opt_Rec.Bsc_Kpi_Id
        ,x_return_status      =>  x_return_status
        ,x_msg_count          =>  x_msg_count
        ,x_msg_data           =>  x_msg_data
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       BSC_KPI_SERIES_PUB.Check_Color_Props(
         p_commit           =>  FND_API.G_FALSE
        ,p_Indicator        =>  l_Anal_Opt_Rec.Bsc_Kpi_Id
        ,p_Analysis_Option0 =>  l_Anal_Opt_Rec.Bsc_Option_Group0
        ,p_Analysis_Option1 =>  l_Anal_Opt_Rec.Bsc_Option_Group1
        ,p_Analysis_Option2 =>  l_Anal_Opt_Rec.Bsc_Option_Group2
        ,p_Series_Id        =>  0
        ,p_Budget_Flag      =>  1
        ,p_Default_Flag     =>  1
        ,p_Dataset_Id       =>  l_Anal_Opt_Rec.Bsc_Dataset_Id
        ,x_return_status    =>  x_return_status
        ,x_msg_count        =>  x_msg_count
        ,x_msg_data         =>  x_msg_data
       );

       IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF BSC_COLOR_CALC_UTIL.Get_Obj_Color_Rollup_Type(l_Anal_Opt_Rec.Bsc_Kpi_Id) = BSC_COLOR_CALC_UTIL.DEFAULT_KPI THEN
          BSC_DESIGNER_PVT.ActionFlag_Change (
             x_indicator => l_Anal_Opt_Rec.Bsc_Kpi_Id
            ,x_newflag   => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
          );
      END IF;
    END LOOP;

  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Check_Default_Props_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
	ROLLBACK TO Check_Default_Props_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Check_Default_Props ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Check_Default_Props ';
        END IF;
END Check_Default_Props;

/************************************************************************************
--	API name 	: Is_Analysis_Drill
--	Type		: Private
--	Function	:
--      Verifies whether the current analysis group has change_dim_set flag checked
--      or not
************************************************************************************/

FUNCTION Is_Analysis_Drill (
  p_Indicator         IN NUMBER
 ,p_Analysis_Group_Id IN NUMBER
) RETURN VARCHAR2 IS
  l_ana_drill bsc_kpi_analysis_groups.change_dim_set%TYPE := 0;
  CURSOR c_Ana_Drill IS
  SELECT
    NVL(change_dim_set,0)
  FROM
    bsc_kpi_analysis_groups
  WHERE
    indicator = p_Indicator AND
    analysis_group_id = p_Analysis_Group_Id;
BEGIN

  OPEN c_Ana_Drill;
  FETCH c_Ana_Drill INTO l_ana_drill;
  CLOSE c_Ana_Drill;

  IF l_ana_drill = 1 THEN
    RETURN FND_API.G_TRUE;
  END IF;
  RETURN FND_API.G_FALSE;

EXCEPTION
   WHEN OTHERS THEN
     RETURN FND_API.G_FALSE;
END Is_Analysis_Drill;

/************************************************************************************
--	API name 	: Get_Analysis_Option_Default
--	Type		: Public
--	Function	: Function which returns the default analysis option id
--                        for a given analysis group of an indicator
************************************************************************************/
FUNCTION Get_Analysis_Option_Default (
  p_Indicator         IN NUMBER
 ,p_Analysis_Group_Id IN NUMBER
) RETURN NUMBER
IS
  l_Default_Option_Id bsc_kpi_analysis_groups.default_value%TYPE := 0;
  CURSOR c_Default_Option IS
  SELECT
    default_value
  FROM
    bsc_kpi_analysis_groups
  WHERE
    indicator = p_Indicator AND
    analysis_group_id = p_Analysis_Group_Id ;
BEGIN

  OPEN c_Default_Option;
  FETCH c_Default_Option INTO  l_Default_Option_Id;
  CLOSE c_Default_Option;

  RETURN l_Default_Option_Id;

EXCEPTION
   WHEN OTHERS THEN
     RETURN l_Default_Option_Id;
END Get_Analysis_Option_Default;

/************************************************************************************
--	API name 	: Get_Parent_GrandParent_Ids
--	Type		: Private
--	Function	:
--	This API takes as input the parent,grandparent analysis option ids that are
--      received from UI and finds out the corresponding entry in
--      bsc_kpi_analysis_options
--      This is specially required when the groups are having an independent
--      relationship. (In case of independent relationship the parent id will be
--      stored as zero)
--      This API takes care of all the possible combinations between groups
--      Dependent-Dependent
--      Dependent-Independent
--      Independent-Dependent
--      Independent-Independent
--
--      Parameters:
--      p_Analysis_Group_Id - The current level of the analysis option
--      p_Parent_Id, p_GrandParent_Id - The parent and grandparent analysis option ids
--         in the HGrid hierarchy
--      p_Independent_Par_Id - This indicates what the caller API expects in place
--         of parent id when there is an independent relationship.
--      x_Parent_Id,x_GrandParent_Id  - Returns the parent and grandparent ids
--         maintained in bsc_kpi_analysis_options table
--      x_Parent_Group_Id,x_GrandParent_Group_Id - Also returns the parent and
--         grand parent group ids.
************************************************************************************/

PROCEDURE  Get_Parent_GrandParent_Ids(
  p_Indicator             IN NUMBER
 ,p_Analysis_Group_Id     IN NUMBER
 ,p_Parent_Id             IN NUMBER
 ,p_GrandParent_Id        IN NUMBER
 ,p_Independent_Par_Id    IN NUMBER := 0
 ,x_Parent_Id             OUT NOCOPY NUMBER
 ,x_GrandParent_Id        OUT NOCOPY NUMBER
 ,x_Parent_Group_Id       OUT NOCOPY NUMBER
 ,x_GrandParent_Group_Id  OUT NOCOPY NUMBER
) IS

  l_Dependency01 bsc_kpi_analysis_groups.dependency_flag%TYPE := 0;
  l_Dependency12 bsc_kpi_analysis_groups.dependency_flag%TYPE := 0;

  CURSOR c_dependency_flag(p_group_id NUMBER) IS
  SELECT
    ag.dependency_flag
  FROM
  bsc_kpi_analysis_groups ag
  WHERe
    ag.indicator = p_Indicator AND
    ag.analysis_group_id = p_group_id;

BEGIN

  x_Parent_Id := p_Parent_Id;
  x_GrandParent_Id := p_GrandParent_Id;
  x_Parent_Group_Id := -1;
  x_GrandParent_Group_Id := -1;

  OPEN c_dependency_flag(1);
  FETCH c_dependency_flag INTO l_Dependency01;
  CLOSE c_dependency_flag;

  OPEN c_dependency_flag(2);
  FETCH c_dependency_flag INTO l_Dependency12;
  CLOSE c_dependency_flag;


  CASE p_Analysis_Group_Id
    WHEN 0 THEN
      NULL;
    WHEN 1 THEN
      x_Parent_Group_Id := 0;
      IF l_Dependency01 = 0 THEN
         x_Parent_Id := p_Independent_Par_Id;
         x_Parent_Group_Id := p_Independent_Par_Id;
       END IF;
    WHEN 2 THEN
      x_GrandParent_Group_Id := 0;
      x_Parent_Group_Id := 1;
      IF l_Dependency12 = 0 THEN
        x_GrandParent_Id := p_Independent_Par_Id;
        x_GrandParent_Group_Id := p_Independent_Par_Id;
        x_Parent_Id := p_Independent_Par_Id;
        x_Parent_Group_Id := p_Independent_Par_Id;
      ELSIF l_Dependency01 = 0 THEN
        x_GrandParent_Id := p_Independent_Par_Id;
        x_GrandParent_Group_Id := p_Independent_Par_Id;
      END IF;
  END CASE;


EXCEPTION
    WHEN OTHERS THEN
      NULL;
END Get_Parent_GrandParent_Ids;

/************************************************************************************
--	API name 	: Get_Current_Dim_DataSet_Map
--	Type		: Private
************************************************************************************/

PROCEDURE Get_Current_Dim_DataSet_Map (
  p_Indicator           IN NUMBER
 ,x_dim_Dataset_map  OUT NOCOPY BSC_KPI_SERIES_PUB.Bsc_Dim_Dataset_Table
) IS
BEGIN
 SELECT DISTINCT
     dim.dim_set_id, dim.dataset_id,0
   BULK COLLECT INTO
     x_dim_Dataset_map
   FROM
     bsc_db_dataset_dim_sets_v dim,
     bsc_sys_datasets_b ds
   WHERE
     dim.indicator = p_Indicator AND
     dim.dataset_id = ds.dataset_id AND
     ds.source = 'BSC'
   ORDER BY
     dim_set_id, dataset_id;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Get_Current_Dim_DataSet_Map;
/************************************************************************************
--	API name 	: Check_Strucural_Flag_Change
--	Type		: Private
************************************************************************************/

PROCEDURE Check_Strucural_Flag_Change(
  p_commit              IN VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator           IN NUMBER
 ,p_olddim_Dataset_map  IN BSC_KPI_SERIES_PUB.Bsc_Dim_Dataset_Table
 ,p_cascade_shared      BOOLEAN := FALSE
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
) IS

  l_newdim_Dataset_map BSC_KPI_SERIES_PUB.Bsc_Dim_Dataset_Table;
  isStructureChange BOOLEAN;

  CURSOR c_shared_objs IS
  SELECT
    indicator
  FROM
    bsc_kpis_b
  WHERE
    source_indicator = p_Indicator AND
    prototype_flag <> 2 AND
    share_flag = 2;
BEGIN
   Get_Current_Dim_DataSet_Map (
     p_Indicator           =>  p_Indicator
    ,x_dim_Dataset_map  =>  l_newdim_Dataset_map
   );

   IF p_olddim_Dataset_map.COUNT <>  l_newdim_Dataset_map.COUNT THEN
     isStructureChange := TRUE;
   ELSE
     FOR i in 1..p_olddim_Dataset_map.COUNT LOOP
       IF (p_olddim_Dataset_map(i).dim_set_id <> l_newdim_Dataset_map(i).dim_set_id OR
         p_olddim_Dataset_map(i).dataset_id <> l_newdim_Dataset_map(i).dataset_id) THEN
           isStructureChange := TRUE;
       END IF;
     END LOOP;
   END IF;

   IF isStructureChange THEN
     BSC_DESIGNER_PVT.ActionFlag_Change(p_Indicator , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
     IF p_cascade_shared THEN
       FOR cd IN c_shared_objs LOOP
         BSC_DESIGNER_PVT.ActionFlag_Change(cd.indicator , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
       END LOOP;
     END IF;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Update_Analayis_Option_PUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
	ROLLBACK TO Update_Analayis_Option_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Check_Strucural_Flag_Change ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Check_Strucural_Flag_Change ';
        END IF;
END Check_Strucural_Flag_Change;

/************************************************************************************
--	API name 	: Update_Analysis_Option_UI
--	Type		: Public
--	Function	:
--	1. Validates and cascades the default flag updation
--      2. Imports the measure as well as the dimensions incase of bis measure
--         Incase of bsc measure calls the analysis measure and analysis option
--         Update APIs to cascade the changes
--      3. Updates the change_dim_set property
--      4. Checks for the list button validation if the current analysis group
--         has the change_dim_set property set
--      5. Refreshes the bsc_kpi_defaults tables with the current defaults
--      6. Checks for structural changes and updates the prototype_flag accordingly
************************************************************************************/

PROCEDURE Update_Analysis_Option_UI(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Group_Id     IN   NUMBER := 0
 ,p_Option_Id             IN   NUMBER := 0
 ,p_Parent_Option_Id      IN   NUMBER := 0
 ,p_GrandParent_Option_Id IN   NUMBER := 0
 ,p_Dependency_Flag       IN   NUMBER := 0
 ,p_DataSet_Id            IN   NUMBER := NULL
 ,p_DimSet_Id             IN   NUMBER := 0
 ,p_Default_Flag          IN   NUMBER := 0
 ,p_Option_Name           IN   VARCHAR2
 ,p_Option_Help           IN   VARCHAR2
 ,p_Change_Dim_Set        IN   NUMBER := 0
 ,p_default_calculation   IN   NUMBER := NULL
 ,p_Create_Flow           IN   VARCHAR2 := FND_API.G_FALSE
 ,p_time_stamp            IN   VARCHAR2 := NULL
 ,p_olddim_Dataset_map    IN   BSC_KPI_SERIES_PUB.Bsc_Dim_Dataset_Table := NULL
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS
  l_AO0                bsc_kpi_analysis_measures_b.analysis_option0%TYPE;
  l_AO1                bsc_kpi_analysis_measures_b.analysis_option1%TYPE;
  l_AO2                bsc_kpi_analysis_measures_b.analysis_option2%TYPE;

  l_Bsc_Kpi_Entity_Rec BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
  l_Bsc_AnaOpt_Rec   BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
  l_Count NUMBER := 0;
  l_DimSet_Id          bsc_kpi_analysis_options_b.dim_set_id%TYPE := 0;
  l_Measure_Source     bsc_sys_datasets_vl.source%TYPE;
  l_commit             VARCHAR2(2) := FND_API.G_FALSE;

  l_config_type        bsc_kpis_b.config_type%TYPE;
  l_indicator_type     bsc_kpis_b.indicator_type%TYPE;

  l_old_DimSet_id      bsc_kpi_analysis_options_b.dim_set_id%TYPE;
  l_old_data_set_id    bsc_kpi_analysis_measures_b.dataset_id%TYPE;

  l_temp_Parent_Id     NUMBER := NULL;
  l_temp_GrandParent_Id     NUMBER := NULL;
  l_Parent_Group_Id      bsc_kpi_analysis_groups.analysis_group_id%TYPE := 0;
  l_GrandParent_Group_Id bsc_kpi_analysis_groups.analysis_group_id%TYPE := 0;

  l_olddim_Dataset_map BSC_KPI_SERIES_PUB.Bsc_Dim_Dataset_Table;
  l_newdim_Dataset_map BSC_KPI_SERIES_PUB.Bsc_Dim_Dataset_Table;
  isStructureChange    BOOLEAN := FALSE;
  i NUMBER;


  CURSOR  c_old_data_set_id(p_AO0 VARCHAR2, p_AO1 VARCHAR2, p_AO2 VARCHAR2) IS
  SELECT
    dataset_id
  FROM
    BSC_KPI_ANALYSIS_MEASURES_B
  WHERE   indicator        = p_Indicator
    AND     analysis_option0 = p_AO0
    AND     analysis_option1 = p_AO1
    AND     analysis_option2 = p_AO2;

  CURSOR
    c_old_dim_set_id IS
  SELECT
    dim_set_id
  FROM
    bsc_kpi_analysis_options_b
  WHERE analysis_group_id = p_Analysis_Group_Id
    AND option_id = p_Option_Id
    AND parent_option_id = p_Parent_Option_Id
    AND grandparent_option_id = p_GrandParent_Option_Id;

  CURSOR c_shared_objs IS
  SELECT
    indicator
  FROM
    bsc_kpis_b
  WHERE
    source_indicator = p_Indicator AND
    prototype_flag <> 2 AND
    share_flag = 2;

BEGIN
  SAVEPOINT Update_Analayis_Option_PUB;
  -- Check that the indicator id passed is Valid
  IF NOT FND_API.To_Boolean(p_Create_Flow) THEN
    IF p_Indicator IS NOT NULL THEN
      l_Count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       , p_Indicator);
      IF l_Count = 0 THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
        FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Indicator);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Indicator);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    BSC_BIS_LOCKS_PUB.LOCK_KPI
    (      p_Kpi_Id             =>  p_Indicator
       ,   p_time_stamp         =>  p_time_stamp
       ,   p_Full_Lock_Flag     =>  NULL
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  SELECT indicator_type,config_type
  INTO l_indicator_type,l_config_type
  FROM bsc_kpis_b
  WHERE indicator = p_Indicator;

  IF NOT FND_API.To_Boolean(p_Create_Flow) THEN
    Get_Current_Dim_DataSet_Map (
      p_Indicator           =>  p_Indicator
     ,x_dim_Dataset_map  =>  l_olddim_Dataset_map
    );
  ELSE
    l_olddim_Dataset_map := p_olddim_Dataset_map;
  END IF;


  CASE p_Analysis_Group_Id
    WHEN 0 THEN
      l_AO0 := p_Option_Id;
      l_AO1 := 0;
      l_AO2 := 0;
    WHEN 1 THEN
      l_AO0 := p_Parent_Option_Id;
      l_AO1 := p_Option_Id;
      l_AO2 := 0;
    WHEN 2 THEN
      l_AO0 := p_GrandParent_Option_Id;
      l_AO1 := p_Parent_Option_Id;
      l_AO2 := p_Option_Id;
  END CASE;

  l_Bsc_AnaOpt_Rec.Bsc_Kpi_Id := p_Indicator;
  l_Bsc_AnaOpt_Rec.Bsc_Analysis_Group_Id   := p_Analysis_Group_Id;
  l_Bsc_AnaOpt_Rec.Bsc_Analysis_Option_Id  := p_Option_Id;
  l_Bsc_AnaOpt_Rec.Bsc_Parent_Option_Id := p_Parent_Option_Id;
  l_Bsc_AnaOpt_Rec.Bsc_Grandparent_Option_Id := p_GrandParent_Option_Id;
  l_Bsc_AnaOpt_Rec.Bsc_Dataset_Id := p_DataSet_Id;
  l_Bsc_AnaOpt_Rec.Bsc_Option_Default_Value := p_Default_Flag;
  l_Bsc_AnaOpt_Rec.Bsc_Option_Group0 := l_AO0;
  l_Bsc_AnaOpt_Rec.Bsc_Option_Group1 := l_AO1;
  l_Bsc_AnaOpt_Rec.Bsc_Option_Group2 := l_AO2;
  l_Bsc_AnaOpt_Rec.Bsc_Dim_Set_Id := p_DimSet_Id;
  l_Bsc_AnaOpt_Rec.Bsc_Option_Name := p_Option_Name;
  l_Bsc_AnaOpt_Rec.Bsc_Option_Help := p_Option_Help;

  Check_Default_Props(
     p_commit          =>  l_commit
    ,p_Anal_Opt_Rec    =>  l_Bsc_AnaOpt_Rec
    ,p_cascade_shared  =>  TRUE
    ,x_return_status   =>  x_return_status
    ,x_msg_count       =>  x_msg_count
    ,x_msg_data        =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF l_indicator_type <> 10 AND p_DataSet_Id IS NOT NULL THEN
    BSC_KPI_SERIES_PUB.Save_Default_Calculation(
      p_commit              =>  FND_API.G_FALSE
     ,p_Indicator           =>  p_Indicator
     ,p_Analysis_Option0    =>  l_AO0
     ,p_Analysis_Option1    =>  l_AO1
     ,p_Analysis_Option2    =>  l_AO2
     ,p_Series_Id           =>  0
     ,p_default_calculation =>  p_default_calculation
     ,x_return_status       =>  x_return_status
     ,x_msg_count           =>  x_msg_count
     ,x_msg_data            =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


  l_Measure_Source := bsc_Oaf_Views_Pvt.Get_Dataset_Source(x_Dataset_Id => p_DataSet_Id);

  IF l_Measure_Source = 'PMF' THEN
    IF FND_API.To_Boolean(p_Create_Flow) THEN
      l_DimSet_Id := NULL;
    ELSE
      l_DimSet_Id := p_DimSet_Id;
    END IF;
    BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options -- This will cascade to the shared
    (       p_commit                =>  l_commit
        ,   p_kpi_id                =>  p_Indicator
        ,   p_data_source           =>  l_Measure_Source
        ,   p_analysis_group_id     =>  p_Analysis_Group_Id
        ,   p_analysis_option_id0   =>  p_Option_Id
        ,   p_analysis_option_id1   =>  p_Parent_Option_Id
        ,   p_analysis_option_id2   =>  p_GrandParent_Option_Id
        ,   p_series_id             =>  0
        ,   p_data_set_id           =>  p_DataSet_Id
        ,   p_dim_set_id            =>  l_DimSet_Id
        ,   p_option0_Name          =>  p_Option_Name
        ,   p_option1_Name          =>  NULL
        ,   p_option2_Name          =>  NULL
        ,   p_measure_short_name    =>  NULL
        ,   p_dim_obj_short_names   =>  NULL
        ,   p_default_short_names   =>  NULL
        ,   p_view_by_name          =>  NULL
        ,   p_measure_name          =>  p_Option_Name
        ,   p_measure_help          =>  p_Option_Help
        ,   p_default_value         =>  NULL
        ,   p_time_stamp            =>  NULL
        ,   p_update_ana_opt        =>  TRUE
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSE --For BSC Measures

    OPEN    c_old_dim_set_id ;
    FETCH   c_old_dim_set_id INTO l_old_DimSet_id;
    CLOSE   c_old_dim_set_id;

    OPEN    c_old_data_set_id(l_AO0, l_AO1, l_AO2);
    FETCH   c_old_data_set_id INTO l_old_data_set_id;
    CLOSE   c_old_data_set_id;

    Get_Parent_GrandParent_Ids(
      p_Indicator      =>   p_Indicator
     ,p_Analysis_Group_Id  =>   p_Analysis_Group_Id
     ,p_Parent_Id      =>   l_Bsc_AnaOpt_Rec.Bsc_Parent_Option_Id
     ,p_GrandParent_Id =>   l_Bsc_AnaOpt_Rec.Bsc_Grandparent_Option_Id
     ,p_Independent_Par_Id => 0
     ,x_Parent_Id      =>   l_temp_Parent_Id
     ,x_GrandParent_Id =>   l_temp_GrandParent_Id
     ,x_Parent_Group_Id       => l_Parent_Group_Id
     ,x_GrandParent_Group_Id  => l_GrandParent_Group_Id
    );


    l_Bsc_AnaOpt_Rec.Bsc_Parent_Option_Id := l_temp_Parent_Id;
    l_Bsc_AnaOpt_Rec.Bsc_Grandparent_Option_Id := l_temp_GrandParent_Id;

    IF l_indicator_type <> 10 THEN
       -- For multibar dataset_id will not be updated at option level. They will
       --be updated at series level
     IF p_DataSet_Id IS NOT NULL THEN
         Bsc_Analysis_Option_Pvt.Update_Analysis_Measures (
             p_commit          =>   l_commit
            ,p_Anal_Opt_Rec    =>   l_Bsc_AnaOpt_Rec
            ,x_return_status   =>   x_return_status
            ,x_msg_count       =>   x_msg_count
            ,x_msg_data        =>   x_Msg_Data
          );
          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    	      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      END IF;
    END IF;
    Bsc_Analysis_Option_Pvt.Update_Analysis_Options (
      p_commit          =>   l_commit
     ,p_Anal_Opt_Rec    =>   l_Bsc_AnaOpt_Rec
     ,p_data_source     =>   l_Measure_Source
     ,x_return_status   =>   x_return_status
     ,x_msg_count       =>   x_msg_count
     ,x_msg_data        =>   x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    FOR cd in c_shared_objs LOOP
      l_Bsc_AnaOpt_Rec.Bsc_Kpi_Id := cd.Indicator;
      IF l_indicator_type <> 10 THEN
        IF p_DataSet_Id IS NOT NULL THEN
           Bsc_Analysis_Option_Pvt.Update_Analysis_Measures (
  	      p_commit          =>   l_commit
              ,p_Anal_Opt_Rec   =>   l_Bsc_AnaOpt_Rec
              ,x_return_status  =>   x_return_status
              ,x_msg_count      =>   x_msg_count
              ,x_msg_data       =>   x_Msg_Data
            );
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     	      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    	  END IF;
        END IF;
      END IF;
      Bsc_Analysis_Option_Pvt.Update_Analysis_Options (
        p_commit          =>   l_commit
       ,p_Anal_Opt_Rec    =>   l_Bsc_AnaOpt_Rec
       ,p_data_source     =>   l_Measure_Source
       ,x_return_status   =>   x_return_status
       ,x_msg_count       =>   x_msg_count
       ,x_msg_data        =>   x_Msg_Data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END LOOP;

    IF FND_API.To_Boolean(p_Create_Flow) THEN
        BSC_DESIGNER_PVT.Deflt_Update_SN_FM_CM(x_indicator => p_Indicator);
    END IF;

    IF ( Get_Analysis_Option_Default( p_Indicator => p_Indicator, p_Analysis_Group_Id => p_Analysis_Group_Id) = p_Option_Id AND
      FND_API.To_Boolean(Is_Analysis_Drill ( p_Indicator => p_Indicator, p_Analysis_Group_Id => p_Analysis_Group_Id))) THEN
        BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button (
          p_Kpi_Id         =>  p_Indicator
         ,p_Dim_Level_Id   =>  NULL
         ,x_return_status  =>  x_return_status
         ,x_msg_count      =>  x_msg_count
         ,x_msg_data       =>  x_msg_data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
  END IF;

  Update_Change_DimSet (
    p_commit              =>  FND_API.G_FALSE
   ,p_Indicator           =>  p_Indicator
   ,p_Analysis_Group_Id   =>  p_Analysis_Group_Id
   ,p_Change_Dim_Set      =>  p_Change_Dim_Set
   ,x_return_status       =>  x_return_status
   ,x_msg_count           =>  x_msg_count
   ,x_msg_data            =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  Check_UserLevel_Values(
     p_commit             =>  l_commit
    ,p_Indicator          =>  p_Indicator
    ,p_cascade_shared     =>  TRUE
    ,x_return_status      =>  x_return_status
    ,x_msg_count          =>  x_msg_count
    ,x_msg_data           =>  x_msg_data
   );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Check_Strucural_Flag_Change (
     p_commit             =>  l_commit
    ,p_Indicator          =>  p_Indicator
    ,p_olddim_Dataset_map =>  l_olddim_Dataset_map
    ,p_cascade_shared     =>  TRUE
    ,x_return_status      =>  x_return_status
    ,x_msg_count          =>  x_msg_count
    ,x_msg_data           =>  x_msg_data
   );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Update TimeStamp
   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Indicator;
   BSC_KPI_PUB.Update_Kpi_Time_Stamp(
     p_commit             =>  l_commit
    ,p_Bsc_Kpi_Entity_Rec =>  l_Bsc_Kpi_Entity_Rec
    ,x_return_status      =>  x_return_status
    ,x_msg_count          =>  x_msg_count
    ,x_msg_data           =>  x_msg_data
   );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   FOR cd IN c_shared_objs LOOP
     l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := cd.Indicator;
     Update_Change_DimSet (
       p_commit              =>  FND_API.G_FALSE
      ,p_Indicator           =>  cd.Indicator
      ,p_Analysis_Group_Id   =>  p_Analysis_Group_Id
      ,p_Change_Dim_Set      =>  p_Change_Dim_Set
      ,x_return_status       =>  x_return_status
      ,x_msg_count           =>  x_msg_count
      ,x_msg_data            =>  x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     BSC_KPI_PUB.Update_Kpi_Time_Stamp(
       p_commit             =>  l_commit
      ,p_Bsc_Kpi_Entity_Rec =>  l_Bsc_Kpi_Entity_Rec
      ,x_return_status      =>  x_return_status
      ,x_msg_count          =>  x_msg_count
      ,x_msg_data           =>  x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END LOOP;

  BSC_DESIGNER_PVT.Deflt_Update_AOPTS ( x_indicator => p_Indicator);
  FOR cd in c_shared_objs LOOP
    BSC_DESIGNER_PVT.Deflt_Update_AOPTS ( x_indicator => cd.indicator );
  END LOOP;

  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Update_Analayis_Option_PUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
	ROLLBACK TO Update_Analayis_Option_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Update_Analysis_Option_UI ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Update_Analysis_Option_UI ';
        END IF;
END Update_Analysis_Option_UI;

/************************************************************************************
--	API name 	: Delete_Mind_Options
--	Type		: Private
--      Deletes entries from bsc_kpi_analysis_options. This API also cascades the
--      deletes the child analysis options.
************************************************************************************/

PROCEDURE Delete_Mind_Options(
  p_commit              IN VARCHAR2 := FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN Bsc_Analysis_Option_Pub.Bsc_Option_Rec_Type
 ,p_Dependency01        IN NUMBER
 ,p_Dependency12        IN NUMBER
 ,p_Initial_Group_Id    IN NUMBER
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
) IS
 l_Ana_Opt_Count NUMBER := 0;
 l_DeleteChildren BOOLEAN := FALSE;
 l_Deletegrandchildren BOOLEAN := FALSE;
 l_Next_Group_Id bsc_kpi_analysis_groups.analysis_group_id%TYPE;
 l_Grandchild_Group_Id  bsc_kpi_analysis_groups.analysis_group_id%TYPE;
 l_criteria VARCHAR2(2000);
 l_sql VARCHAR2(2000);

 l_Anal_Opt_Rec Bsc_Analysis_Option_Pub.Bsc_Option_Rec_Type;
 l_Par_Opt_Rec Bsc_Analysis_Option_Pub.Bsc_Option_Rec_Type;
 l_commit  VARCHAR2(2) := FND_API.G_FALSE;
 CURSOR c_Ana_Opt_Count IS
 SELECT
   COUNT(1)
 FROM
   bsc_kpi_analysis_options_b
 WHERE indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id AND
 analysis_group_id = p_Anal_Opt_Rec.Bsc_Analysis_Group_Id;

 CURSOR c_Child_Options IS
 SELECT
   option_id
 FROM
   bsc_kpi_analysis_options_b
 WHERE
   indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id AND
   analysis_group_id = 1 AND
   parent_option_id = l_Anal_Opt_Rec.Bsc_Analysis_Option_Id;

BEGIN
  SAVEPOINT  Delete_Mind_Options_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  l_Anal_Opt_Rec := p_Anal_Opt_Rec;
  l_Par_Opt_Rec := p_Anal_Opt_Rec;
  l_criteria := ' WHERE indicator = '||l_Anal_Opt_Rec.Bsc_Kpi_Id;
  l_criteria := l_criteria || ' AND analysis_group_id = '|| l_Anal_Opt_Rec.Bsc_Analysis_Group_Id;
  IF l_Anal_Opt_Rec.Bsc_Analysis_Option_Id <> -1 THEN
    l_criteria := l_criteria || ' AND option_id = '||  l_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
  END IF;

  IF l_Anal_Opt_Rec.Bsc_Parent_Option_Id <> -1 THEN
    l_criteria := l_criteria || ' AND parent_option_id = '||   l_Anal_Opt_Rec.Bsc_Parent_Option_Id;
    IF l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id <> -1 THEN
      l_criteria := l_criteria || ' AND grandparent_option_id = '||   l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;
    END IF;
  END IF;

  l_sql := 'DELETE FROM bsc_kpi_analysis_options_b ' || l_criteria;
  BSC_APPS.Execute_Immediate(l_sql);

  l_sql := 'DELETE FROM bsc_kpi_analysis_options_tl ' || l_criteria;
  BSC_APPS.Execute_Immediate(l_sql);

  OPEN c_Ana_Opt_Count;
  FETCH c_Ana_Opt_Count INTO l_Ana_Opt_Count;
  CLOSE c_Ana_Opt_Count;


  /*Delete the child analysis options recursively if the following conditions satisty
  1. If the current analysis group has a dependent relationship with the child group
     then delete the children
  2. If the current analysis option is the last analysis option in that particular
     group , the children should be deleted even if it is an independent relationship*/
  IF (l_Anal_Opt_Rec.Bsc_Analysis_Group_Id = 0 AND (p_Dependency01 = 1 OR  l_Ana_Opt_Count = 0) ) THEN
    l_Next_Group_Id := 1;
    l_DeleteChildren := TRUE;
    IF ( p_Dependency01 = 1 AND p_Dependency12 = 1) THEN
      l_GrandChild_Group_Id := 2;
      l_DeleteGrandChildren := TRUE;
    END IF;

  END IF;

  IF (l_Anal_Opt_Rec.Bsc_Analysis_Group_Id = 1 AND ((p_Dependency12 = 1 AND p_Initial_Group_Id = 1) OR l_Ana_Opt_Count = 0) ) THEN
    l_Next_Group_Id := 2;
    l_DeleteChildren := TRUE;
  END IF;

  IF l_DeleteGrandChildren THEN
    FOR cd in c_Child_Options LOOP
       l_Par_Opt_Rec.Bsc_Analysis_Group_Id := l_GrandChild_Group_Id;
       l_Par_Opt_Rec.Bsc_Grandparent_Option_Id := l_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
       l_Par_Opt_Rec.Bsc_Parent_Option_Id := cd.Option_Id;
       l_Par_Opt_Rec.Bsc_Analysis_Option_Id := -1;

       Delete_Mind_Options (
        p_commit            =>  l_commit
       ,p_Anal_Opt_Rec      =>  l_Par_Opt_Rec
       ,p_Dependency01      =>  p_Dependency01
       ,p_Dependency12      =>  p_Dependency12
       ,p_Initial_Group_Id  =>  p_Initial_Group_Id
       ,x_return_status     =>  x_return_status
       ,x_msg_count         =>  x_msg_count
       ,x_msg_data          =>  x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
  END IF;

  IF l_DeleteChildren = TRUE THEN
     l_Anal_Opt_Rec.Bsc_Analysis_Group_Id := l_Next_Group_Id;
     l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id := l_Anal_Opt_Rec.Bsc_Parent_Option_Id;
     l_Anal_Opt_Rec.Bsc_Parent_Option_Id := l_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
     l_Anal_Opt_Rec.Bsc_Analysis_Option_Id := -1;

     Delete_Mind_Options (
      p_commit            =>  l_commit
     ,p_Anal_Opt_Rec      =>  l_Anal_Opt_Rec
     ,p_Dependency01      =>  p_Dependency01
     ,p_Dependency12      =>  p_Dependency12
     ,p_Initial_Group_Id  =>  p_Initial_Group_Id
     ,x_return_status     =>  x_return_status
     ,x_msg_count         =>  x_msg_count
     ,x_msg_data          =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK TO Delete_Mind_Options_PVT;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' ->BSC_OBJ_ANALYSIS_OPTIONS_PUB.Delete_Mind_Options ';
  ELSE
      x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Delete_Mind_Options ';
  END IF;
END Delete_Mind_Options;

/************************************************************************************
--	API name 	: Delete_Mind_Data
--	Type		: Private
************************************************************************************/


PROCEDURE Delete_Mind_Data(
  p_commit              IN VARCHAR2 := FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN Bsc_Analysis_Option_Pub.Bsc_Option_Rec_Type
 ,p_Parent_Group_Id       IN NUMBER
 ,p_Grandparent_Group_Id  IN NUMBER
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
) IS

  TYPE cursor_type IS REF CURSOR;
  c_NumOptions cursor_type;
  l_NumOptions NUMBER := 0;
  l_criteria VARCHAR2(2000);
  l_sql VARCHAR2(2000);
  l_Anal_Opt_Rec Bsc_Analysis_Option_Pub.Bsc_Option_Rec_Type;
  l_commit  VARCHAR2(2) := FND_API.G_FALSE;
  --l_Initial_Kpi_Meas   FND_TABLE_OF_NUMBER;
BEGIN

  SAVEPOINT  Delete_Mind_Data_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  l_Anal_Opt_Rec := p_Anal_Opt_Rec;


  l_sql := 'SELECT COUNT(1) FROM bsc_kpi_analysis_options_b WHERE indicator = ' || l_Anal_Opt_Rec.Bsc_Kpi_Id ;
  l_sql := l_sql || ' AND analysis_group_id = ' || l_Anal_Opt_Rec.Bsc_Analysis_Group_Id;

  IF p_Parent_Group_Id <> -1 THEN
    l_sql := l_sql || ' AND parent_option_id = '|| l_Anal_Opt_Rec.Bsc_Parent_Option_Id;
    IF p_Grandparent_Group_Id <> -1 THEN
      l_sql := l_sql || ' AND grandparent_option_id= ' || l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;
    END IF;
  END IF;


  OPEN c_NumOptions FOR l_sql;
  FETCH c_NumOptions INTO l_NumOptions;
  CLOSE c_NumOptions;

  IF l_NumOptions < 1 THEN
    RETURN ;
  END IF;


  l_criteria := ' WHERE indicator = '|| l_Anal_Opt_Rec.Bsc_Kpi_Id;
  IF l_Anal_Opt_Rec.Bsc_Analysis_Option_Id <> -1 THEN
    l_criteria := l_criteria || ' AND analysis_option'|| l_Anal_Opt_Rec.Bsc_Analysis_Group_Id || ' = '|| l_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
  END IF;
  IF p_Parent_Group_Id <> -1 THEN
    l_criteria := l_criteria || ' AND analysis_option'|| p_Parent_Group_Id || ' = '|| l_Anal_Opt_Rec.Bsc_Parent_Option_Id;
    IF p_Grandparent_Group_Id <> -1 THEN
      l_criteria := l_criteria || ' AND analysis_option'|| p_Grandparent_Group_Id || ' = '|| l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;
    END IF;
  END IF;

  l_sql := 'DELETE FROM bsc_kpi_analysis_measures_b  ' || l_criteria;
  BSC_APPS.Execute_Immediate(l_sql);

  l_sql := 'DELETE FROM bsc_kpi_analysis_measures_tl  ' || l_criteria;
  BSC_APPS.Execute_Immediate(l_sql);

  BSC_ANALYSIS_OPTION_PUB.Cascade_Deletion_Color_Props (
     p_commit           =>  p_commit
    ,p_Anal_Opt_Rec     =>  p_Anal_Opt_Rec
    ,x_return_status    =>  x_return_status
    ,x_msg_count        =>  x_msg_count
    ,x_msg_data         =>  x_msg_data
   ) ;

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_sql := 'DELETE FROM bsc_kpi_subtitles_tl ' || l_criteria;
  BSC_APPS.Execute_Immediate(l_sql);

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;
EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK TO Delete_Mind_Data_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Delete_Mind_Data ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Delete_Mind_Data ';
        END IF;
END Delete_Mind_Data;

/************************************************************************************
--	API name 	: Renumerate_Options
--	Type		: Private
--      If an analysis option is deleted then the other analysis options must be
--      resequenced depending on the position of the analysis option
--      Also the analysis measures using the resequenced analysis options have
--      to be updated.
************************************************************************************/


PROCEDURE Renumerate_Options(
  p_commit              IN VARCHAR2 := FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN Bsc_Analysis_Option_Pub.Bsc_Option_Rec_Type
 ,p_Parent_Group_Id       IN NUMBER
 ,p_Grandparent_Group_Id  IN NUMBER
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
) IS
l_criteria_grandparent VARCHAR2(2000);
l_criteria_measures VARCHAR2(2000);
l_criteria_options VARCHAR2(2000);
l_criteria_parent VARCHAR2(2000);

l_cur_index NUMBER := 0;
l_max_groups NUMBER := 0;
l_option_id bsc_kpi_analysis_options_b.option_id%TYPE;
l_options_sql VARCHAR2(2000);
l_sql VARCHAR2(2000);

TYPE CursorType IS REF CURSOR;
c_option	CursorType;

CURSOR c_Max_Groups IS
SELECT
  MAX(analysis_group_id)
FROM
  bsc_kpi_analysis_groups
WHERE
  indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id;

BEGIN
  SAVEPOINT  Renumerate_Options_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_criteria_options := ' WHERE indicator = '|| p_Anal_Opt_Rec.Bsc_Kpi_Id;
  l_criteria_options := l_criteria_options || ' AND analysis_group_id = ' || p_Anal_Opt_Rec.Bsc_Analysis_Group_Id;
  IF p_Parent_Group_Id <> -1 THEN
    l_criteria_options := l_criteria_options || ' AND parent_option_id=' || p_Anal_Opt_Rec.Bsc_Parent_Option_Id;
    IF p_Grandparent_Group_Id <> -1 THEN
      l_criteria_options := l_criteria_options || ' AND grandparent_option_id='|| p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;
    END IF;
  END IF;

  l_options_sql := 'SELECT option_id FROM bsc_kpi_analysis_options_b ';
  l_options_sql := l_options_sql || l_criteria_options || ' ORDER BY option_id';

  OPEN c_option FOR l_options_sql;
    LOOP
      FETCH c_option INTO l_option_id;
      EXIT WHEN c_option%NOTFOUND;
      l_criteria_measures := ' WHERE indicator = '|| p_Anal_Opt_Rec.Bsc_Kpi_Id ;
      l_criteria_measures := l_criteria_measures ||' AND analysis_option' || p_Anal_Opt_Rec.Bsc_Analysis_Group_Id || ' = ' || l_option_id;

      IF p_Parent_Group_Id <> -1 THEN
        l_criteria_measures := l_criteria_measures || ' AND analysis_option' || p_Parent_Group_Id || ' = ' || p_Anal_Opt_Rec.Bsc_Parent_Option_Id;
        IF p_Grandparent_Group_Id <> -1 THEN
           l_criteria_measures := l_criteria_measures || ' AND analysis_option' ||  p_Grandparent_Group_Id || ' = ' || p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id;
        END IF;
      END IF;

      IF l_option_id <> l_cur_index THEN
        l_sql := 'UPDATE bsc_kpi_analysis_measures_b SET analysis_option'|| p_Anal_Opt_Rec.Bsc_Analysis_Group_Id || '=' || l_cur_index;
        l_sql := l_sql || l_criteria_measures;
        BSC_APPS.Execute_Immediate(l_sql);

        l_sql := 'UPDATE bsc_kpi_analysis_measures_tl SET analysis_option'|| p_Anal_Opt_Rec.Bsc_Analysis_Group_Id || '=' || l_cur_index;
        l_sql := l_sql || l_criteria_measures;
        BSC_APPS.Execute_Immediate(l_sql);

        l_sql := 'UPDATE bsc_kpi_subtitles_tl SET analysis_option'|| p_Anal_Opt_Rec.Bsc_Analysis_Group_Id || '=' || l_cur_index;
        l_sql := l_sql || l_criteria_measures;
        BSC_APPS.Execute_Immediate(l_sql);

        l_sql := 'UPDATE bsc_kpi_analysis_options_b SET option_id='|| l_cur_index;
        l_sql := l_sql || l_criteria_options || ' AND option_id = ' || l_option_id;
        BSC_APPS.Execute_Immediate(l_sql);

        l_sql := 'UPDATE bsc_kpi_analysis_options_tl SET option_id='|| l_cur_index;
        l_sql := l_sql || l_criteria_options || ' AND option_id = ' || l_option_id;
        BSC_APPS.Execute_Immediate(l_sql);

        OPEN c_Max_Groups;
        FETCH c_Max_Groups INTO l_max_groups;
        CLOSE c_Max_Groups;

        IF (p_Anal_Opt_Rec.Bsc_Analysis_Group_Id + 1 <= l_max_groups) THEN

          l_criteria_parent := ' WHERE indicator = '|| p_Anal_Opt_Rec.Bsc_Kpi_Id;
          l_criteria_parent := l_criteria_parent || ' AND analysis_group_id = ' || (p_Anal_Opt_Rec.Bsc_Analysis_Group_Id + 1) ||' AND parent_option_id = ' || l_option_id;

          l_sql := 'UPDATE bsc_kpi_analysis_options_b SET parent_option_id = '|| l_cur_index ;
          l_sql := l_sql || l_criteria_parent;
          BSC_APPS.Execute_Immediate(l_sql);

          l_sql := 'UPDATE bsc_kpi_analysis_options_tl SET parent_option_id = '|| l_cur_index ;
          l_sql := l_sql || l_criteria_parent;
          BSC_APPS.Execute_Immediate(l_sql);

       END IF;

       IF (p_Anal_Opt_Rec.Bsc_Analysis_Group_Id + 2 <= l_max_groups) THEN

          l_criteria_parent := ' WHERE indicator = '|| p_Anal_Opt_Rec.Bsc_Kpi_Id;
          l_criteria_parent := l_criteria_parent || ' AND analysis_group_id = ' || (p_Anal_Opt_Rec.Bsc_Analysis_Group_Id + 1) ||' AND grandparent_option_id = ' || l_option_id;

          l_sql := 'UPDATE bsc_kpi_analysis_options_b SET grandparent_option_id = '|| l_cur_index ;
          l_sql := l_sql || l_criteria_parent;
          BSC_APPS.Execute_Immediate(l_sql);

          l_sql := 'UPDATE bsc_kpi_analysis_options_tl SET grandparent_option_id = '|| l_cur_index ;
          l_sql := l_sql || l_criteria_parent;
          BSC_APPS.Execute_Immediate(l_sql);
       END IF;
     END IF;
     l_cur_index := l_cur_index + 1;
   end loop;
  close c_option;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK TO Renumerate_Options_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Renumerate_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Renumerate_Options ';
        END IF;
END Renumerate_Options;

/************************************************************************************
--	API name 	: Update_Analysis_Opt_Count
--	Type		: Private
************************************************************************************/

PROCEDURE Update_Analysis_Opt_Count (
  p_commit             IN VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator          IN NUMBER
 ,x_return_status      OUT NOCOPY VARCHAR2
 ,x_msg_count          OUT NOCOPY NUMBER
 ,x_msg_data           OUT NOCOPY VARCHAR2
) IS

  l_Count NUMBER := 0;
  l_Max_Grp_Id NUMBER := -1;

  CURSOR c_ana_opt_cnt(p_Analysis_Group_Id NUMBER) IS
  SELECT MAX(option_id)
  FROM
    bsc_kpi_analysis_options_b
  WHERE
    indicator = p_Indicator AND
    analysis_group_id = p_Analysis_Group_Id;

  CURSOR c_max_grp_id IS
  SELECT max(analysis_group_id)
  FROM
    bsc_kpi_analysis_groups
  WHERE
    indicator = p_Indicator;

BEGIN

  SAVEPOINT  Update_Ana_Opt_Count_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  OPEN c_max_grp_id;
  FETCH c_max_grp_id INTO l_Max_Grp_Id;
  CLOSE c_max_grp_id;

  FOR i in 0..l_Max_Grp_Id LOOP
    OPEN c_ana_opt_cnt(i);
    FETCH c_ana_opt_cnt INTO l_Count;
    CLOSE c_ana_opt_cnt;

    IF l_Count IS NULL THEN
      l_Count := 0;
    ELSE
      l_Count := l_Count + 1;
    END IF;

    UPDATE
      bsc_kpi_analysis_groups
    SET
      num_of_options = l_Count
    WHERE
      indicator = p_Indicator
      AND analysis_group_id = i;

  END LOOP;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;
EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK TO Update_Ana_Opt_Count_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Update_Analysis_Opt_Count ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Update_Analysis_Opt_Count ';
        END IF;
END Update_Analysis_Opt_Count;

/************************************************************************************
--	API name 	: Get_Dependency
--	Type		: Private
************************************************************************************/
FUNCTION Get_Dependency (
  p_Indicator         IN NUMBER
 ,p_Analysis_Group_Id IN NUMBER
) RETURN NUMBER IS

  CURSOR c_Is_Dependent IS
  SELECT
    dependency_flag
  FROM
    bsc_kpi_analysis_groups
  WHERE
    indicator = p_Indicator AND
    analysis_group_id = p_Analysis_Group_Id;

  l_Dependent bsc_kpi_analysis_groups.dependency_flag%TYPE := 0;
BEGIN

  OPEN c_Is_Dependent;
  FETCH c_Is_Dependent INTO l_Dependent;
  CLOSE c_Is_Dependent;

  RETURN l_Dependent;
EXCEPTION
    WHEN OTHERS THEN
      RETURN l_Dependent;
END Get_Dependency;

/************************************************************************************
--	API name 	: Delete_Analysis_Option_Wrap
--	Type		: Private
************************************************************************************/


PROCEDURE Delete_Analysis_Option_Wrap (
  p_commit              IN VARCHAR2 := FND_API.G_FALSE
 ,p_Anal_Opt_Rec        IN Bsc_Analysis_Option_Pub.Bsc_Option_Rec_Type
 ,p_cascade_shared      BOOLEAN := FALSE
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_msg_count           OUT NOCOPY NUMBER
 ,x_msg_data            OUT NOCOPY VARCHAR2
) IS

  l_Dependency01  bsc_kpi_analysis_groups.dependency_flag%TYPE := -1;
  l_Dependency12  bsc_kpi_analysis_groups.dependency_flag%TYPE := -1;

  l_Parent_Id            bsc_kpi_analysis_options_b.parent_option_id%TYPE := 0;
  l_GrandParent_Id       bsc_kpi_analysis_options_b.grandparent_option_id%TYPE := 0;
  l_Parent_Group_Id      bsc_kpi_analysis_groups.analysis_group_id%TYPE := 0;
  l_GrandParent_Group_Id bsc_kpi_analysis_groups.analysis_group_id%TYPE := 0;

  l_Bsc_Anal_Opt_Rec    Bsc_Analysis_Option_Pub.Bsc_Option_Rec_Type;

  l_commit       VARCHAR2(2) := FND_API.G_FALSE;

  CURSOR c_shared_objs IS
  SELECT
    indicator
  FROM
    bsc_kpis_b
  WHERE
    source_indicator = p_Anal_Opt_Rec.Bsc_Kpi_Id AND
    prototype_flag <> 2 AND
    share_flag = 2;

BEGIN
  SAVEPOINT BscObjDeleteAnaOptWrap;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  l_Bsc_Anal_Opt_Rec := p_Anal_Opt_Rec;
  l_Dependency01 := Get_Dependency(p_Anal_Opt_Rec.Bsc_Kpi_Id, 1);
  l_Dependency12 := Get_Dependency(p_Anal_Opt_Rec.Bsc_Kpi_Id, 2);

  Get_Parent_GrandParent_Ids(
    p_Indicator             => p_Anal_Opt_Rec.Bsc_Kpi_Id
   ,p_Analysis_Group_Id     => p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
   ,p_Parent_Id             => p_Anal_Opt_Rec.Bsc_Parent_Option_Id
   ,p_GrandParent_Id        => p_Anal_Opt_Rec.Bsc_Grandparent_Option_Id
   ,p_Independent_Par_Id    => -1
   ,x_Parent_Id             => l_Parent_Id
   ,x_GrandParent_Id        => l_GrandParent_Id
   ,x_Parent_Group_Id       => l_Parent_Group_Id
   ,x_GrandParent_Group_Id  => l_GrandParent_Group_Id
  );

  l_Bsc_Anal_Opt_Rec.Bsc_Parent_Option_Id      := l_Parent_Id;
  l_Bsc_Anal_Opt_Rec.Bsc_Grandparent_Option_Id := l_GrandParent_Id;

  Delete_Mind_Options (
     p_commit            =>  l_commit
    ,p_Anal_Opt_Rec      =>  l_Bsc_Anal_Opt_Rec
    ,p_Dependency01      =>  l_Dependency01
    ,p_Dependency12      =>  l_Dependency12
    ,p_Initial_Group_Id  =>  p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
    ,x_return_status     =>  x_return_status
    ,x_msg_count         =>  x_msg_count
    ,x_msg_data          =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  Delete_Mind_Data (
     p_commit            =>  l_commit
    ,p_Anal_Opt_Rec      =>  l_Bsc_Anal_Opt_Rec
    ,p_Parent_Group_Id   =>  l_Parent_Group_Id
    ,p_Grandparent_Group_Id =>  l_GrandParent_Group_Id
    ,x_return_status     =>  x_return_status
    ,x_msg_count         =>  x_msg_count
    ,x_msg_data          =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  Renumerate_Options (
     p_commit            =>  l_commit
    ,p_Anal_Opt_Rec      =>  l_Bsc_Anal_Opt_Rec
    ,p_Parent_Group_Id   =>  l_Parent_Group_Id
    ,p_Grandparent_Group_Id =>  l_GrandParent_Group_Id
    ,x_return_status     =>  x_return_status
    ,x_msg_count         =>  x_msg_count
    ,x_msg_data          =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  Update_Analysis_Opt_Count (
     p_commit            =>  l_commit
    ,p_Indicator         =>  p_Anal_Opt_Rec.Bsc_Kpi_Id
    ,x_return_status     =>  x_return_status
    ,x_msg_count         =>  x_msg_count
    ,x_msg_data          =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF p_cascade_shared THEN
   FOR cd in c_shared_objs LOOP
     l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id := cd.Indicator;
     Delete_Mind_Options (
        p_commit            =>  l_commit
       ,p_Anal_Opt_Rec      =>  l_Bsc_Anal_Opt_Rec
       ,p_Dependency01      =>  l_Dependency01
       ,p_Dependency12      =>  l_Dependency12
       ,p_Initial_Group_Id  =>  p_Anal_Opt_Rec.Bsc_Analysis_Group_Id
       ,x_return_status     =>  x_return_status
       ,x_msg_count         =>  x_msg_count
       ,x_msg_data          =>  x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     Delete_Mind_Data (
        p_commit            =>  l_commit
       ,p_Anal_Opt_Rec      =>  l_Bsc_Anal_Opt_Rec
       ,p_Parent_Group_Id   =>  l_Parent_Group_Id
       ,p_Grandparent_Group_Id =>  l_GrandParent_Group_Id
       ,x_return_status     =>  x_return_status
       ,x_msg_count         =>  x_msg_count
       ,x_msg_data          =>  x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     Renumerate_Options (
        p_commit            =>  l_commit
       ,p_Anal_Opt_Rec      =>  l_Bsc_Anal_Opt_Rec
       ,p_Parent_Group_Id   =>  l_Parent_Group_Id
       ,p_Grandparent_Group_Id =>  l_GrandParent_Group_Id
       ,x_return_status     =>  x_return_status
       ,x_msg_count         =>  x_msg_count
       ,x_msg_data          =>  x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     Update_Analysis_Opt_Count (
        p_commit            =>  l_commit
       ,p_Indicator         =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
      ,x_return_status     =>  x_return_status
      ,x_msg_count         =>  x_msg_count
      ,x_msg_data          =>  x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END LOOP;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BscObjDeleteAnaOptWrap;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
	ROLLBACK TO BscObjDeleteAnaOptWrap;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Delete_Analysis_Option_Wrap ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Delete_Analysis_Option_Wrap ';
        END IF;
END Delete_Analysis_Option_Wrap;

/************************************************************************************
--	API name 	: Reset_Group_Defaults
--	Type		: Public
************************************************************************************/
PROCEDURE Reset_Group_Defaults (
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator         IN NUMBER
 ,p_Analysis_Group_Id IN NUMBER
 ,p_Option_Id         IN NUMBER
 ,x_return_status     OUT NOCOPY   VARCHAR2
 ,x_msg_count         OUT NOCOPY   NUMBER
 ,x_msg_data          OUT NOCOPY   VARCHAR2
) IS

 l_Reset_Child_Defaults BOOLEAN := FALSE;
 l_new_Default   bsc_kpi_analysis_groups.default_value%TYPE := 0;
 l_Dependency01  bsc_kpi_analysis_groups.dependency_flag%TYPE := -1;
 l_Dependency12  bsc_kpi_analysis_groups.dependency_flag%TYPE := -1;

BEGIN
  SAVEPOINT  Reset_Group_Defaults_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  l_Dependency01 := Get_Dependency(p_Indicator,1);
  l_Dependency12 := Get_Dependency(p_Indicator,2);

  l_new_Default := Get_Analysis_Option_Default(p_Indicator, p_Analysis_Group_Id);

  IF l_new_Default >= p_Option_Id THEN
    IF l_new_Default = p_Option_Id THEN
      l_Reset_Child_Defaults := TRUE;
      l_new_Default := 0;
    ELSE
      l_new_Default := l_new_Default - 1;
      IF l_new_Default < 0 THEN
        l_new_Default := 0;
      END IF;
    END IF;
    UPDATE
      bsc_kpi_analysis_groups
    SET
      default_value = l_new_Default
    WHERE
      indicator = p_Indicator
      AND analysis_Group_Id = p_Analysis_Group_Id;
   IF l_Reset_Child_Defaults = TRUE THEN
      CASE p_Analysis_Group_Id
         WHEN 0 THEN
          IF l_Dependency01 = 1 THEN
            UPDATE
              bsc_kpi_analysis_groups
	     SET
	       default_value = 0
	     WHERE
	       indicator = p_Indicator
	       AND analysis_Group_Id = 1;
          END IF;
          IF l_Dependency12 = 1 THEN
            UPDATE
              bsc_kpi_analysis_groups
	     SET
	       default_value = 0
	     WHERE
	       indicator = p_Indicator
	       AND analysis_Group_Id = 2;
          END IF;
        WHEN 1 THEN
          IF l_Dependency12 = 1 THEN
            UPDATE
              bsc_kpi_analysis_groups
	     SET
	       default_value = 0
	     WHERE
	       indicator = p_Indicator
	       AND analysis_Group_Id = 2;
          END IF;
        WHEN 2 THEN
          NULL;
      END CASE;
    END IF;
 END IF;

 IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT;
 END IF;

EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK TO Reset_Group_Defaults_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Reset_Group_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Reset_Group_Defaults ';
        END IF;
END Reset_Group_Defaults;

/************************************************************************************
--	API name 	: Remove_Empty_Groups
--	Type		: Public
************************************************************************************/
PROCEDURE Remove_Empty_Groups (
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator         IN NUMBER
 ,p_Analysis_Group_Id IN NUMBER
 ,p_Option_Id         IN   NUMBER := 0
 ,p_Parent_Option_Id  IN   NUMBER := 0
 ,p_Initial_Options   IN NUMBER
 ,x_return_status     OUT NOCOPY   VARCHAR2
 ,x_msg_count         OUT NOCOPY   NUMBER
 ,x_msg_data          OUT NOCOPY   VARCHAR2
) IS

l_Max_Groups NUMBER := 0;
l_Cur_Group NUMBER := 0;
l_Num_Of_Options NUMBER := 0;

l_Dependency01  bsc_kpi_analysis_groups.dependency_flag%TYPE := -1;
l_Dependency12  bsc_kpi_analysis_groups.dependency_flag%TYPE := -1;

l_Is_Dependent BOOLEAN := FALSE;
l_Change_Dim_Set bsc_kpi_analysis_groups.change_dim_set%TYPE := 0;

CURSOR c_Max_Groups IS
SELECT
  MAX(analysis_group_id)
FROM
  bsc_kpi_analysis_groups
WHERE
  indicator = p_Indicator;

CURSOR c_Num_Options(p_Group_Id NUMBER) IS
SELECT
  COUNT(1)
FROM
  bsc_kpi_analysis_options_b
WHERE
  indicator = p_Indicator AND
  analysis_group_id = p_Group_Id;

BEGIN
  SAVEPOINT  Remove_Empty_Groups_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  l_Dependency01 := Get_Dependency(p_Indicator,1);
  l_Dependency12 := Get_Dependency(p_Indicator,2);

  OPEN c_Max_Groups;
  FETCH c_Max_Groups INTO l_Max_Groups;
  CLOSE c_Max_Groups;

  l_Cur_Group := p_Analysis_Group_Id;

  WHILE l_Cur_Group <= l_Max_Groups LOOP
    l_Num_Of_Options := 0;
    OPEN c_Num_Options(l_Cur_Group);
    FETCH c_Num_Options INTO l_Num_Of_Options;
    CLOSE c_Num_Options;

    IF (l_Num_Of_Options = 0) THEN
        SELECT
          change_dim_set
        INTO
          l_Change_Dim_Set
        FROM
          bsc_kpi_analysis_groups
        WHERE
	  indicator = p_Indicator AND
	  analysis_group_id = l_Cur_Group;

        DELETE FROM
	  bsc_kpi_analysis_groups
	WHERE
	  indicator = p_Indicator AND
	  analysis_group_id = l_Cur_Group;

        IF l_Change_Dim_Set = 1 THEN
          UPDATE
            bsc_kpi_analysis_groups
          SET
            change_dim_set = 1
          WHERE
	    indicator = p_Indicator AND
	    analysis_group_id = 0;
        END IF;
    END IF;
    l_Cur_Group := l_Cur_Group + 1;
  END LOOP;

 IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT;
 END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Remove_Empty_Groups_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
	ROLLBACK TO Remove_Empty_Groups_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Remove_Empty_Groups ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Remove_Empty_Groups ';
        END IF;
END Remove_Empty_Groups;

/************************************************************************************
--	API name 	: Delete_Analysis_Option_UI
--	Type		: Public
--      Function:
--      1. Deletes the analysis option and also the corresponding childrent
--      2. Deletes the analysis measures corresponding to these analysis options
--      3. Removes imported dimension set incase of bis measure
--      4. Checks for structural change and changes the prototype_flag
--      5. Resets the default kpi incase the default is deleted
--      6. Refreshes the entries in bsc_kpi_defaults tables
************************************************************************************/
PROCEDURE Delete_Analysis_Option_UI(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Group_Id     IN   NUMBER := 0
 ,p_Option_Id             IN   NUMBER := 0
 ,p_Parent_Option_Id      IN   NUMBER := 0
 ,p_GrandParent_Option_Id IN   NUMBER := 0
 ,p_time_stamp            IN   VARCHAR2 := NULL
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS
  l_Bsc_Kpi_Entity_Rec BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
  l_Count NUMBER := 0;

  l_Bsc_AnaOpt_Rec  Bsc_Analysis_Option_Pub.Bsc_Option_Rec_Type;
  l_Initial_Options NUMBER := 0;
  l_Reset_Child_Defaults BOOLEAN := FALSE;
  l_new_Default   bsc_kpi_analysis_groups.default_value%TYPE := 0;
  l_commit   VARCHAR2(2) := FND_API.G_FALSE;
  l_olddim_set_ids  FND_TABLE_OF_NUMBER;
  l_newdim_set_ids  FND_TABLE_OF_NUMBER;
  l_Removed_Dim_Set_Ids  FND_TABLE_OF_NUMBER;

  l_olddim_Dataset_map BSC_KPI_SERIES_PUB.Bsc_Dim_Dataset_Table;

  i NUMBER;
  CURSOR c_Shared_Objs IS
  SELECT
    indicator
  FROM
   bsc_kpis_b
  WHERE
    source_indicator = p_Indicator AND
    prototype_flag <> 2 AND
    share_flag = 2;

  CURSOR c_imported_dims IS
  SELECT
   kpi_dim.dim_set_id
  FROM
   bsc_kpis_b kpi,
   bsc_kpi_dim_groups kpi_dim,
   bsc_sys_dim_groups_vl sys_dim,
   bsc_kpi_analysis_options_b kpi_opt
  WHERE
   kpi.indicator = p_Indicator AND
   kpi.short_name IS NULL AND
   kpi_dim.indicator = kpi.indicator AND
   sys_dim.dim_group_id = kpi_dim.dim_group_id AND
   kpi_opt.indicator = kpi.indicator AND
   kpi_opt.dim_set_id = kpi_dim.dim_set_id AND
   bsc_bis_dimension_pub.get_dimension_source(sys_dim.short_name) = BSC_UTILITY.c_PMF;

BEGIN
  SAVEPOINT Delete_Analysis_Opt_UI_PVT;
  -- Check that the indicator id passed is Valid
  IF p_Indicator IS NOT NULL THEN
    l_Count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                     ,'indicator'
                                                     , p_Indicator);
    IF l_Count = 0 THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Indicator);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Indicator);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  BSC_BIS_LOCKS_PUB.LOCK_KPI
  (      p_Kpi_Id             =>  p_Indicator
     ,   p_time_stamp         =>  p_time_stamp
     ,   p_Full_Lock_Flag     =>  NULL
     ,   x_return_status      =>  x_return_status
     ,   x_msg_count          =>  x_msg_count
     ,   x_msg_data           =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_Bsc_AnaOpt_Rec.Bsc_Kpi_Id := p_Indicator;
  l_Bsc_AnaOpt_Rec.Bsc_Analysis_Group_Id   := p_Analysis_Group_Id;
  l_Bsc_AnaOpt_Rec.Bsc_Analysis_Option_Id  := p_Option_Id;
  l_Bsc_AnaOpt_Rec.Bsc_Parent_Option_Id := p_Parent_Option_Id;
  l_Bsc_AnaOpt_Rec.Bsc_Grandparent_Option_Id := p_GrandParent_Option_Id;
  l_Bsc_AnaOpt_Rec.Bsc_Dataset_Series_Id := 0;
  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Indicator;

  Get_Current_Dim_DataSet_Map (
    p_Indicator           =>  p_Indicator
   ,x_dim_Dataset_map  =>  l_olddim_Dataset_map
  );

  CASE p_Analysis_Group_Id
    WHEN 0 THEN
      l_Bsc_AnaOpt_Rec.Bsc_Option_Group0 :=  p_Option_Id;
      l_Bsc_AnaOpt_Rec.Bsc_Option_Group1 :=  0;
      l_Bsc_AnaOpt_Rec.Bsc_Option_Group2 :=  0;
    WHEN 1 THEN
      l_Bsc_AnaOpt_Rec.Bsc_Option_Group0 :=  p_Parent_Option_Id;
      l_Bsc_AnaOpt_Rec.Bsc_Option_Group1 :=  p_Option_Id;
      l_Bsc_AnaOpt_Rec.Bsc_Option_Group2 :=  0;
    WHEN 2 THEN
      l_Bsc_AnaOpt_Rec.Bsc_Option_Group0 :=  p_GrandParent_Option_Id;
      l_Bsc_AnaOpt_Rec.Bsc_Option_Group1 :=  p_Parent_Option_Id;
      l_Bsc_AnaOpt_Rec.Bsc_Option_Group2 :=  p_Option_Id;
  END CASE;

  OPEN  c_imported_dims;
  FETCH c_imported_dims  BULK COLLECT INTO  l_olddim_set_ids;
  CLOSE c_imported_dims;

  l_Initial_Options :=  BSC_ANALYSIS_OPTION_PUB.Get_Num_Analysis_options(p_Indicator,p_Analysis_Group_Id);

  Delete_Analysis_Option_Wrap (
     p_commit             =>  p_commit
    ,p_Anal_Opt_Rec       =>  l_Bsc_AnaOpt_Rec
    ,p_cascade_shared     =>  TRUE
    ,x_return_status      =>  x_return_status
    ,x_msg_count          =>  x_msg_count
    ,x_msg_data           =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN  c_imported_dims;
  FETCH c_imported_dims BULK COLLECT INTO  l_newdim_set_ids;
  CLOSE c_imported_dims;

  SELECT column_value dim_set_id
  BULK COLLECT
  INTO l_Removed_Dim_Set_Ids
  FROM
  (SELECT
    t.column_value
  FROM
    TABLE(CAST(l_olddim_set_ids AS FND_TABLE_OF_NUMBER)) t
  MINUS
  SELECT
    t.column_value
  FROM
    TABLE(CAST(l_newdim_set_ids AS FND_TABLE_OF_NUMBER)) t );

  FOR i in 1..l_Removed_Dim_Set_Ids.COUNT LOOP
    BSC_BIS_KPI_MEAS_PUB.Remove_Unused_PMF_Dimenison
    (       p_commit        =>   FND_API.G_FALSE
        ,   p_Kpi_Id        =>   p_Indicator
        ,   p_dim_set_id    =>   l_Removed_Dim_Set_Ids(i)
        ,   x_return_status =>   x_return_status
        ,   x_msg_count     =>   x_msg_count
        ,   x_msg_data      =>   x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Set
    (       p_commit         =>  FND_API.G_FALSE
        ,   p_kpi_id         =>  p_Indicator
        ,   p_dim_set_id     =>  l_Removed_Dim_Set_Ids(i)
        ,   x_return_status  =>  x_return_status
        ,   x_msg_count      =>  x_msg_count
        ,   x_msg_data       =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;


  BSC_KPI_SERIES_PUB.Check_Series_Default_Props (
     p_commit             =>  l_commit
    ,p_Indicator          =>  p_Indicator
    ,x_return_status      =>  x_return_status
    ,x_msg_count          =>  x_msg_count
    ,x_msg_data           =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  Reset_Group_Defaults (
    p_commit             =>  l_commit
   ,p_Indicator          =>  p_Indicator
   ,p_Analysis_Group_Id  =>  p_Analysis_Group_Id
   ,p_Option_Id          =>  p_Option_Id
   ,x_return_status      =>  x_return_status
   ,x_msg_count          =>  x_msg_count
   ,x_msg_data           =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  Remove_Empty_Groups (
    p_commit             =>  l_commit
   ,p_Indicator          =>  p_Indicator
   ,p_Analysis_Group_Id  =>  p_Analysis_Group_Id
   ,p_Option_Id          =>  p_Option_Id
   ,p_Parent_Option_Id   =>  p_Parent_Option_Id
   ,p_Initial_Options    =>  l_Initial_Options
   ,x_return_status      =>  x_return_status
   ,x_msg_count          =>  x_msg_count
   ,x_msg_data           =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  Check_UserLevel_Values(
    p_commit             =>  l_commit
   ,p_Indicator          =>  p_Indicator
   ,p_cascade_shared     =>  TRUE
   ,x_return_status      =>  x_return_status
   ,x_msg_count          =>  x_msg_count
   ,x_msg_data           =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   Check_Strucural_Flag_Change (
     p_commit             =>  l_commit
    ,p_Indicator          =>  p_Indicator
    ,p_olddim_Dataset_map =>  l_olddim_Dataset_map
    ,x_return_status      =>  x_return_status
    ,x_msg_count          =>  x_msg_count
    ,x_msg_data           =>  x_msg_data
   );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Indicator;
  BSC_KPI_PUB.Update_Kpi_Time_Stamp(
    p_commit             =>  p_commit
   ,p_Bsc_Kpi_Entity_Rec =>  l_Bsc_Kpi_Entity_Rec
   ,x_return_status      =>  x_return_status
   ,x_msg_count          =>  x_msg_count
   ,x_msg_data           =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_DESIGNER_PVT.Deflt_RefreshKpi(l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);

  FOR cd IN c_Shared_Objs LOOP
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := cd.Indicator;
    FOR i in 1..l_Removed_Dim_Set_Ids.COUNT LOOP
      BSC_BIS_KPI_MEAS_PUB.Remove_Unused_PMF_Dimenison
      (       p_commit        =>   FND_API.G_FALSE
          ,   p_Kpi_Id        =>   cd.Indicator
          ,   p_dim_set_id    =>   l_Removed_Dim_Set_Ids(i)
          ,   x_return_status =>   x_return_status
          ,   x_msg_count     =>   x_msg_count
          ,   x_msg_data      =>   x_msg_data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Set
      (       p_commit         =>  FND_API.G_FALSE
          ,   p_kpi_id         =>  cd.Indicator
          ,   p_dim_set_id     =>  l_Removed_Dim_Set_Ids(i)
          ,   x_return_status  =>  x_return_status
          ,   x_msg_count      =>  x_msg_count
          ,   x_msg_data       =>  x_msg_data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END LOOP;
    BSC_KPI_SERIES_PUB.Check_Series_Default_Props(
       p_commit             =>  l_commit
      ,p_Indicator          =>  cd.Indicator
      ,x_return_status      =>  x_return_status
      ,x_msg_count          =>  x_msg_count
      ,x_msg_data           =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Reset_Group_Defaults (
      p_commit             =>  l_commit
     ,p_Indicator          =>  cd.Indicator
     ,p_Analysis_Group_Id  =>  p_Analysis_Group_Id
     ,p_Option_Id          =>  p_Option_Id
     ,x_return_status      =>  x_return_status
     ,x_msg_count          =>  x_msg_count
     ,x_msg_data           =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Remove_Empty_Groups (
      p_commit             =>  l_commit
     ,p_Indicator          =>  cd.Indicator
     ,p_Analysis_Group_Id  =>  p_Analysis_Group_Id
     ,p_Option_Id          =>  p_Option_Id
     ,p_Parent_Option_Id   =>  p_Parent_Option_Id
     ,p_Initial_Options    =>  l_Initial_Options
     ,x_return_status      =>  x_return_status
     ,x_msg_count          =>  x_msg_count
     ,x_msg_data           =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Check_UserLevel_Values(
      p_commit             =>  l_commit
     ,p_Indicator          =>  cd.Indicator
     ,p_cascade_shared     =>  TRUE
     ,x_return_status      =>  x_return_status
     ,x_msg_count          =>  x_msg_count
     ,x_msg_data           =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := cd.Indicator;
    BSC_KPI_PUB.Update_Kpi_Time_Stamp(
      p_commit             =>  p_commit
     ,p_Bsc_Kpi_Entity_Rec =>  l_Bsc_Kpi_Entity_Rec
     ,x_return_status      =>  x_return_status
     ,x_msg_count          =>  x_msg_count
     ,x_msg_data           =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   BSC_DESIGNER_PVT.Deflt_RefreshKpi(l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);

 END LOOP;

   IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_Analysis_Opt_UI_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
	ROLLBACK TO Delete_Analysis_Opt_UI_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Delete_Analysis_Option_UI ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Delete_Analysis_Option_UI ';
        END IF;

END Delete_Analysis_Option_UI;

/************************************************************************************
--	API name 	: Create_Analysis_Group
--	Type		: Public
************************************************************************************/

PROCEDURE Create_Analysis_Group (
  p_commit             IN VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator          IN NUMBER
 ,p_Analysis_Group_Id  IN NUMBER
 ,p_Num_Of_Options     IN NUMBER
 ,p_Dependency_Flag    IN NUMBER
 ,p_Parent_Analysis_Id IN NUMBER
 ,p_Change_Dim_Set     IN NUMBER
 ,p_Default_Value      IN NUMBER
 ,p_Short_Name         IN NUMBER
 ,x_return_status      OUT NOCOPY VARCHAR2
 ,x_msg_count          OUT NOCOPY NUMBER
 ,x_msg_data           OUT NOCOPY VARCHAR2
) IS
BEGIN

  SAVEPOINT  Create_Analysis_Group_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  INSERT INTO bsc_kpi_analysis_groups (
    indicator,
    analysis_group_id,
    num_of_options,
    dependency_flag,
    parent_analysis_id,
    change_dim_set,
    default_value,
    short_name
  ) VALUES(
    p_Indicator
   ,p_Analysis_Group_Id
   ,p_Num_Of_Options
   ,p_Dependency_Flag
   ,p_Parent_Analysis_Id
   ,p_Change_Dim_Set
   ,p_Default_Value
   ,p_Short_Name
  );

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO Create_Analysis_Group_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Create_Analysis_Group ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Create_Analysis_Group ';
        END IF;
END Create_Analysis_Group;

/************************************************************************************
--	API name 	: Generate_Analysis_Meas_Combs
--	Type		: Public
--	Function	:
--	This API generates entries in bsc_kpi_analysis_measures by taking into
--      consideration the dependency relationships between groups
--      This is specially required when the groups have an independent relationship
--
************************************************************************************/

PROCEDURE Generate_Analysis_Meas_Combs (
  p_commit            IN VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator         IN NUMBER
 ,p_Analysis_Option0  IN NUMBER
 ,p_Analysis_Option1  IN NUMBER
 ,p_Analysis_Option2  IN NUMBER
 ,p_Dependency_01     IN NUMBER
 ,p_Dependency_12     IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS

 TYPE ana_opt_type IS REF CURSOR;
 c_ana_opt_type ana_opt_type;
 l_Count  NUMBER := 0;
 l_Sql VARCHAR2(2000);
 l_ana_option_id bsc_kpi_analysis_options_b.option_id%TYPE;
 l_commit VARCHAR2(2) := FND_API.G_FALSE;
 l_Anal_Opt_Rec Bsc_Analysis_Option_Pub.Bsc_Option_Rec_Type;
 l_Generated_Row_Count NUMBER := 0;

 CURSOR c_Exists_Ana_Opt IS
 SELECT
   COUNT(1)
 FROM
    bsc_kpi_analysis_measures_b
 WHERE
   indicator = p_Indicator AND
   analysis_option0 = p_Analysis_Option0 AND
   analysis_option1 = p_Analysis_Option1 AND
   analysis_option2 = p_Analysis_Option2;

BEGIN
   SAVEPOINT  Generate_Ana_Meas_Combs_PVT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;


  l_sql := 'SELECT option_id FROM bsc_kpi_analysis_options_b WHERE indicator = :1 ';

  IF p_Analysis_Option0 = -1 THEN -- Permute with Group0 Analysis Options

    l_sql := l_sql || ' AND analysis_group_id = 0';
    OPEN c_ana_opt_type FOR l_sql USING p_Indicator;
    LOOP
     FETCH c_ana_opt_type INTO l_ana_option_id;
     EXIT WHEN c_ana_opt_type%notfound;
       Generate_Analysis_Meas_Combs (
         p_commit            =>  l_commit
        ,p_Indicator         =>  p_Indicator
        ,p_Analysis_Option0  =>  l_ana_option_id
        ,p_Analysis_Option1  =>  p_Analysis_Option1
        ,p_Analysis_Option2  =>  p_Analysis_Option2
        ,p_Dependency_01     =>  p_Dependency_01
        ,p_Dependency_12     =>  p_Dependency_12
        ,x_return_status     =>  x_return_status
        ,x_msg_count         =>  x_msg_count
        ,x_msg_data          =>  x_msg_data
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END LOOP;

  ELSIF p_Analysis_Option1 = -1 THEN -- Permute with Group1 Analysis Options

    l_sql := l_sql || ' AND analysis_group_id = 1';
    OPEN c_ana_opt_type FOR l_sql USING p_Indicator;
    IF ( p_Dependency_01 = 1) THEN
      l_sql := l_sql || ' AND parent_option_id = :2';
      CLOSE c_ana_opt_type;
      OPEN c_ana_opt_type FOR l_sql USING p_Indicator,p_Analysis_Option0;
    END IF;
    LOOP
      FETCH c_ana_opt_type INTO l_ana_option_id;
      EXIT WHEN c_ana_opt_type%notfound;
        l_Generated_Row_Count := l_Generated_Row_Count + 1;
        Generate_Analysis_Meas_Combs (
          p_commit            =>  l_commit
         ,p_Indicator         =>  p_Indicator
         ,p_Analysis_Option0  =>  p_Analysis_Option0
         ,p_Analysis_Option1  =>  l_ana_option_id
         ,p_Analysis_Option2  =>  p_Analysis_Option2
         ,p_Dependency_01     =>  p_Dependency_01
         ,p_Dependency_12     =>  p_Dependency_12
         ,x_return_status     =>  x_return_status
         ,x_msg_count         =>  x_msg_count
         ,x_msg_data          =>  x_msg_data
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END LOOP;
    IF l_Generated_Row_Count = 0 THEN -- Generate atleast with 0
      Generate_Analysis_Meas_Combs (
        p_commit            =>  l_commit
       ,p_Indicator         =>  p_Indicator
       ,p_Analysis_Option0  =>  p_Analysis_Option0
       ,p_Analysis_Option1  =>  0
       ,p_Analysis_Option2  =>  p_Analysis_Option2
       ,p_Dependency_01     =>  p_Dependency_01
       ,p_Dependency_12     =>  p_Dependency_12
       ,x_return_status     =>  x_return_status
       ,x_msg_count         =>  x_msg_count
       ,x_msg_data          =>  x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;

  ELSIF p_Analysis_Option2 = -1 THEN -- Permute with Group2 Analysis Options

    l_sql := l_sql || ' AND analysis_group_id = 2';
    OPEN c_ana_opt_type FOR l_sql USING p_Indicator;
    IF ( p_Dependency_12 = 1) THEN
      l_sql := l_sql || ' AND parent_option_id = :2';
      IF ( p_Dependency_01 = 1) THEN
         l_sql := l_sql || ' AND grandparent_option_id = :3';
         CLOSE c_ana_opt_type;
         OPEN c_ana_opt_type FOR l_sql USING p_Indicator,p_Analysis_Option1,p_Analysis_Option0;
      ELSE
        CLOSE c_ana_opt_type;
        OPEN c_ana_opt_type FOR l_sql USING p_Indicator,p_Analysis_Option1;
      END IF;
    END IF;

    LOOP
     FETCH c_ana_opt_type INTO l_ana_option_id;
     EXIT WHEN c_ana_opt_type%notfound;
       l_Generated_Row_Count := l_Generated_Row_Count + 1;

       Generate_Analysis_Meas_Combs (
         p_commit            =>  l_commit
        ,p_Indicator         =>  p_Indicator
        ,p_Analysis_Option0  =>  p_Analysis_Option0
        ,p_Analysis_Option1  =>  p_Analysis_Option1
        ,p_Analysis_Option2  =>  l_ana_option_id
        ,p_Dependency_01     =>  p_Dependency_01
        ,p_Dependency_12     =>  p_Dependency_12
        ,x_return_status     =>  x_return_status
        ,x_msg_count         =>  x_msg_count
        ,x_msg_data          =>  x_msg_data
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END LOOP;
    IF l_Generated_Row_Count = 0 THEN
      Generate_Analysis_Meas_Combs (
        p_commit            =>  l_commit
       ,p_Indicator         =>  p_Indicator
       ,p_Analysis_Option0  =>  p_Analysis_Option0
       ,p_Analysis_Option1  =>  p_Analysis_Option1
       ,p_Analysis_Option2  =>  0
       ,p_Dependency_01     =>  p_Dependency_01
       ,p_Dependency_12     =>  p_Dependency_12
       ,x_return_status     =>  x_return_status
       ,x_msg_count         =>  x_msg_count
       ,x_msg_data          =>  x_msg_data
      );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

 ELSE

     OPEN c_Exists_Ana_Opt;
     FETCH c_Exists_Ana_Opt INTO l_Count;
     CLOSE c_Exists_Ana_Opt;

     IF l_Count = 0 THEN
       l_Anal_Opt_Rec.Bsc_Kpi_Id :=  p_Indicator;
       l_Anal_Opt_Rec.Bsc_Option_Group0 :=  p_Analysis_Option0;
       l_Anal_Opt_Rec.Bsc_Option_Group1 :=  p_Analysis_Option1;
       l_Anal_Opt_Rec.Bsc_Option_Group2 :=  p_Analysis_Option2;
       l_Anal_Opt_Rec.Bsc_Dataset_Series_Id :=  0;
       l_Anal_Opt_Rec.Bsc_Dataset_Id :=  -1;
       l_Anal_Opt_Rec.Bsc_Dataset_Axis :=  1;
       l_Anal_Opt_Rec.Bsc_Dataset_Series_Type :=  1;
       l_Anal_Opt_Rec.Bsc_Dataset_Stack_Series_Id :=  NULL;
       l_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag :=  1;
       l_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag :=  1;
       l_Anal_Opt_Rec.Bsc_Dataset_Default_Value :=  1;
       l_Anal_Opt_Rec.Bsc_Dataset_Series_Color :=  10053171;
       l_Anal_Opt_Rec.Bsc_Dataset_Bm_Color :=  10053171;
       l_Anal_Opt_Rec.Bsc_Measure_Long_Name :=  fnd_message.get_string('BSC','BSC_NEW_SERIES') || ' 0';
       l_Anal_Opt_Rec.Bsc_Measure_Help := fnd_message.get_string('BSC','BSC_NEW_SERIES') || ' 0';
       l_Anal_Opt_Rec.Bsc_Measure_Prototype_Flag := 7;

       Bsc_Analysis_Option_Pub.Create_Analysis_Measures(
         p_commit          =>  l_commit
        ,p_Anal_Opt_Rec    =>  l_Anal_Opt_Rec
        ,x_return_status   =>  x_return_status
        ,x_msg_count       =>  x_msg_count
        ,x_msg_data        =>  x_msg_data
       );
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

    END IF;
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END IF;

 IF FND_API.To_Boolean( p_commit ) THEN
   COMMIT;
 END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Generate_Ana_Meas_Combs_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        ROLLBACK TO Generate_Ana_Meas_Combs_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Generate_Analysis_Meas_Combs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Generate_Analysis_Meas_Combs ';
        END IF;
END Generate_Analysis_Meas_Combs;

/************************************************************************************
--	API name 	: Populate_Analysis_Meas_Combs
--	Type		: Public
--	Function	:
--
************************************************************************************/
PROCEDURE Populate_Analysis_Meas_Combs(
  p_commit             IN VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator          IN NUMBER
 ,p_Analysis_Group_Id  IN NUMBER
 ,p_Option_Id          IN NUMBER
 ,p_Parent_Option_Id   IN NUMBER
 ,p_Grandparent_Option_Id  IN NUMBER
 ,p_Dependency_Flag    IN NUMBER
 ,p_DataSet_Id         IN NUMBER := -1
 ,x_return_status      OUT NOCOPY VARCHAR2
 ,x_msg_count          OUT NOCOPY NUMBER
 ,x_msg_data           OUT NOCOPY VARCHAR2
)IS
 l_Analysis_Opt0 bsc_kpi_analysis_measures_b.Analysis_Option0%TYPE := 0;
 l_Analysis_Opt1 bsc_kpi_analysis_measures_b.Analysis_Option1%TYPE := 0;
 l_Analysis_Opt2 bsc_kpi_analysis_measures_b.Analysis_Option2%TYPE := 0;

 l_Dependency_01 bsc_kpi_analysis_groups.dependency_flag%TYPE := -1;
 l_Dependency_12 bsc_kpi_analysis_groups.dependency_flag%TYPE := -1;
 l_commit  VARCHAR2(2) := FND_API.G_FALSE;

 CURSOR c_dep_flag(p_Ana_Grp_Id VARCHAR2) IS
 SELECT dependency_flag
 FROM
   bsc_kpi_analysis_groups
 WHERE
   indicator = p_Indicator AND
   analysis_group_id = p_Ana_Grp_Id;

BEGIN

  SAVEPOINT  Populate_Ana_Meas_Combs_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_dep_flag(1);
  FETCH c_dep_flag INTO l_Dependency_01;
  CLOSE c_dep_flag;

  OPEN c_dep_flag(2);
  FETCH c_dep_flag INTO l_Dependency_12;
  CLOSE c_dep_flag;

  CASE p_Analysis_Group_Id
    WHEN 0 THEN
      l_Analysis_Opt0 := p_Option_Id;
      IF l_Dependency_01 = 1 THEN
        l_Analysis_Opt1 := 0;
      END IF;
      IF l_Dependency_12 = 1 THEN
        l_Analysis_Opt2 := 0;
      END IF;

      IF l_Dependency_01 = 0 THEN
        l_Analysis_Opt1 := -1;
        l_Analysis_Opt2 := -1;
      ELSIF l_Dependency_12 = 0 THEN
        l_Analysis_Opt2 := -1;
      END IF;
   WHEN 1 THEN
      l_Dependency_01 := p_Dependency_Flag;
      l_Analysis_Opt0 := p_Parent_Option_Id;
      IF l_Dependency_12 = 1 THEN
        l_Analysis_Opt2 := 0;
      END IF;
      IF l_Dependency_01 = 0 THEN
        l_Analysis_Opt0 := -1;
      END IF;
      IF l_Dependency_12 = 0 THEN
        l_Analysis_Opt2 := -1;
      END IF;
      l_Analysis_Opt1 := p_Option_Id;
    WHEN 2 THEN
      l_Dependency_12 := p_Dependency_Flag;
      l_Analysis_Opt0 := p_Grandparent_Option_Id;
      l_Analysis_Opt1 := p_Parent_Option_Id;
      IF l_Dependency_12 = 0 THEN
        l_Analysis_Opt0 := -1;
        l_Analysis_Opt1 := -1;
      ELSIF l_Dependency_01 = 0 THEN
        l_Analysis_Opt0 := -1;
      END IF;

      l_Analysis_Opt2 := p_Option_Id;
  END CASE;

  Generate_Analysis_Meas_Combs (
    p_commit            =>  l_commit
   ,p_Indicator         =>  p_Indicator
   ,p_Analysis_Option0  =>  l_Analysis_Opt0
   ,p_Analysis_Option1  =>  l_Analysis_Opt1
   ,p_Analysis_Option2  =>  l_Analysis_Opt2
   ,p_Dependency_01     =>  l_Dependency_01
   ,p_Dependency_12     =>  l_Dependency_12
   ,x_return_status     =>  x_return_status
   ,x_msg_count         =>  x_msg_count
   ,x_msg_data          =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Populate_Ana_Meas_Combs_PVT;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        ROLLBACK TO Populate_Ana_Meas_Combs_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Populate_Analysis_Meas_Combs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Populate_Analysis_Meas_Combs ';
        END IF;
END Populate_Analysis_Meas_Combs;

/************************************************************************************
--	API name 	: Create_Analayis_Option
--	Type		: Public
--	Function	:
--	1. Creates the analysis group incase of this analysis option being the first
--         in this group
--      2. Generates all the necessary combinations of analysis measures depending
--         on the relationship between the groups
--      3. Calls the update analysis option API to set all the properties
************************************************************************************/

PROCEDURE Create_Analysis_Option_UI(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Group_Id     IN   NUMBER := 0
 ,p_Option_Id             IN   NUMBER := 0
 ,p_Parent_Option_Id      IN   NUMBER := 0
 ,p_GrandParent_Option_Id IN   NUMBER := 0
 ,p_Dependency_Flag       IN   NUMBER := 0
 ,p_DataSet_Id            IN   NUMBER := -1
 ,p_DimSet_Id             IN   NUMBER := 0
 ,p_Default_Flag          IN   NUMBER := 0
 ,p_Option_Name           IN   VARCHAR2
 ,p_Option_Help           IN   VARCHAR2
 ,p_Change_Dim_Set        IN   NUMBER := 0
 ,p_default_calculation   IN   NUMBER := NULL
 ,p_time_stamp            IN   VARCHAR2 := NULL
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS

  l_Count NUMBER := 0;
  l_Parent_Analysis_Id  bsc_kpi_analysis_groups.parent_analysis_id%TYPE := 0;
  l_Parent_Option_Id    bsc_kpi_analysis_options_b.parent_option_id%TYPE;
  l_GrandParent_Option_Id bsc_kpi_analysis_options_b.grandparent_option_id%TYPE;
  l_Anal_Opt_Rec        BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
  l_Create_Group        BOOLEAN := FALSE;
  l_commit              VARCHAR2(2) := FND_API.G_FALSE;
  l_Measure_Source     bsc_sys_datasets_vl.source%TYPE := 'BSC';

  l_temp_Parent_Id          NUMBER := NULL;
  l_temp_GrandParent_Id     NUMBER := NULL;
  l_Parent_Group_Id      bsc_kpi_analysis_groups.analysis_group_id%TYPE := 0;
  l_GrandParent_Group_Id bsc_kpi_analysis_groups.analysis_group_id%TYPE := 0;
  l_olddim_Dataset_map   BSC_KPI_SERIES_PUB.Bsc_Dim_Dataset_Table;
  CURSOR c_shared_objs IS
  SELECT
    indicator
  FROM
    bsc_kpis_b
  WHERE
    source_indicator = p_Indicator AND
    prototype_flag <> 2 AND
    share_flag = 2;


BEGIN
  SAVEPOINT Create_Analayis_OptionObjPUB;
  -- Check that the indicator id passed is Valid
  IF p_Indicator IS NOT NULL THEN
    l_Count := BSC_DIMENSION_LEVELS_PVT.Validate_Value( 'BSC_KPIS_B'
                                                       ,'indicator'
                                                       , p_Indicator);
    IF l_Count = 0 THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_KPI_ID');
      FND_MESSAGE.SET_TOKEN('BSC_KPI', p_Indicator);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('BSC','BSC_NO_KPI_ID_ENTERED');
    FND_MESSAGE.SET_TOKEN('BSC_KPI',p_Indicator);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_Anal_Opt_Rec.Bsc_Kpi_Id := p_Indicator;
  l_Anal_Opt_Rec.Bsc_Analysis_Group_Id := p_Analysis_Group_Id;
  l_Anal_Opt_Rec.Bsc_Analysis_Option_Id := p_Option_Id ;
  l_Anal_Opt_Rec.Bsc_Parent_Option_Id := p_Parent_Option_Id;
  l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id := p_GrandParent_Option_Id;
  l_Anal_Opt_Rec.Bsc_Dataset_Id := p_DataSet_Id;
  l_Anal_Opt_Rec.Bsc_Dim_Set_Id := p_DimSet_Id;
  l_Anal_Opt_Rec.Bsc_Option_Name := p_Option_Name;
  l_Anal_Opt_Rec.Bsc_Option_Help := p_Option_Help;
  l_Anal_Opt_Rec.Bsc_Option_Default_Value := p_Default_Flag;

  SELECT DISTINCT
    dim.dim_set_id, dim.dataset_id,0
  BULK COLLECT INTO
    l_olddim_Dataset_map
  FROM
    bsc_db_dataset_dim_sets_v dim,
    bsc_sys_datasets_b ds
  WHERE
    dim.indicator = p_Indicator AND
    dim.dataset_id = ds.dataset_id AND
    ds.source = 'BSC'
  ORDER BY
    dim_set_id, dataset_id;

  /* Check Lock on Indicator */
  IF p_Analysis_Group_Id IS NOT NULL THEN
    SELECT COUNT(1) INTO l_Count
    FROM bsc_kpi_analysis_groups
    WHERE indicator = p_Indicator AND
    analysis_group_id = p_Analysis_Group_Id;

    IF l_Count = 0 THEN
      -- Add Analysis Group if not there
      IF(p_Dependency_Flag = 1) THEN
        l_Parent_Analysis_Id := p_Analysis_Group_Id - 1;
      END IF;
      Create_Analysis_Group (
          p_Indicator           =>   p_Indicator
        , p_Analysis_Group_Id   =>   p_Analysis_Group_Id
        , p_Num_Of_Options      =>   0
        , p_Dependency_Flag     =>   p_Dependency_Flag
        , p_Parent_Analysis_Id  =>   l_Parent_Analysis_Id
        , p_Change_Dim_Set      =>   NULL
        , p_Default_Value       =>   0
        , p_Short_Name          =>   NULL
        , x_return_status       =>   x_return_status
        , x_msg_count           =>   x_msg_count
        , x_msg_data            =>   x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_Create_Group := TRUE;
    END IF;
  END IF;


  Get_Parent_GrandParent_Ids(
    p_Indicator      =>   p_Indicator
   ,p_Analysis_Group_Id  =>   p_Analysis_Group_Id
   ,p_Parent_Id      =>   l_Anal_Opt_Rec.Bsc_Parent_Option_Id
   ,p_GrandParent_Id =>   l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id
   ,p_Independent_Par_Id => 0
   ,x_Parent_Id      =>   l_temp_Parent_Id
   ,x_GrandParent_Id =>   l_temp_GrandParent_Id
   ,x_Parent_Group_Id       => l_Parent_Group_Id
   ,x_GrandParent_Group_Id  => l_GrandParent_Group_Id
  );

  l_Anal_Opt_Rec.Bsc_Parent_Option_Id := l_temp_Parent_Id;
  l_Anal_Opt_Rec.Bsc_Grandparent_Option_Id := l_temp_GrandParent_Id;

  IF p_Dataset_id IS NOT NULL THEN
    SELECT source
    INTO l_measure_source
    FROM bsc_sys_datasets_vl
    WHERE dataset_id = p_Dataset_id;
  END IF;
  --IF l_measure_source = 'BSC' THEN
    Bsc_Analysis_Option_Pvt.Create_Analysis_Options (
      p_commit          =>  l_commit
     ,p_Anal_Opt_Rec    =>  l_Anal_Opt_Rec
     ,x_return_status   =>  x_return_status
     ,x_msg_count       =>  x_msg_count
     ,x_msg_data        =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Populate Measures
    Populate_Analysis_Meas_Combs(
      p_commit             =>  l_commit
     ,p_Indicator          =>  p_Indicator
     ,p_Analysis_Group_Id  =>  p_Analysis_Group_Id
     ,p_Option_Id          =>  p_Option_Id
     ,p_Parent_Option_Id   =>  p_Parent_Option_Id
     ,p_Grandparent_Option_Id  =>  p_Grandparent_Option_Id
     ,p_Dependency_Flag    =>  p_Dependency_Flag
     ,p_DataSet_Id         =>  -1
     ,x_return_status      =>  x_return_status
     ,x_msg_count          =>  x_msg_count
     ,x_msg_data           =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  --END IF;

   -- Update Groups Table Data
  Update_Analysis_Opt_Count (
    p_Indicator          =>  p_Indicator
   ,x_return_status      =>  x_return_status
   ,x_msg_count          =>  x_msg_count
   ,x_msg_data           =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FOR cd in c_shared_objs LOOP
    l_Anal_Opt_Rec.Bsc_Kpi_Id := cd.Indicator;
    IF l_Create_Group THEN
      Create_Analysis_Group (
        p_Indicator           =>   cd.Indicator
      , p_Analysis_Group_Id   =>   p_Analysis_Group_Id
      , p_Num_Of_Options      =>   0
      , p_Dependency_Flag     =>   p_Dependency_Flag
      , p_Parent_Analysis_Id  =>   l_Parent_Analysis_Id
      , p_Change_Dim_Set      =>   NULL
      , p_Default_Value       =>   0
      , p_Short_Name          =>   NULL
      , x_return_status       =>   x_return_status
      , x_msg_count           =>   x_msg_count
      , x_msg_data            =>   x_msg_data
     );
    END IF;
    l_Anal_Opt_Rec.Bsc_Kpi_Id := cd.Indicator;

    Bsc_Analysis_Option_Pvt.Create_Analysis_Options (
      p_commit          =>  l_commit
     ,p_Anal_Opt_Rec    =>  l_Anal_Opt_Rec
     ,x_return_status   =>  x_return_status
     ,x_msg_count       =>  x_msg_count
     ,x_msg_data        =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Populate Measures
    Populate_Analysis_Meas_Combs(
      p_commit             =>  l_commit
     ,p_Indicator          =>  cd.Indicator
     ,p_Analysis_Group_Id  =>  p_Analysis_Group_Id
     ,p_Option_Id          =>  p_Option_Id
     ,p_Parent_Option_Id   =>  p_Parent_Option_Id
     ,p_Grandparent_Option_Id  =>  p_Grandparent_Option_Id
     ,p_Dependency_Flag    =>  p_Dependency_Flag
     ,p_DataSet_Id         =>  -1
     ,x_return_status      =>  x_return_status
     ,x_msg_count          =>  x_msg_count
     ,x_msg_data           =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

     -- Update Groups Table Data
    Update_Analysis_Opt_Count (
      p_Indicator          =>  cd.indicator
     ,x_return_status      =>  x_return_status
     ,x_msg_count          =>  x_msg_count
     ,x_msg_data           =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;
  Update_Analysis_Option_UI(
     p_Indicator          =>  p_Indicator
    ,p_Analysis_Group_Id  =>  p_Analysis_Group_Id
    ,p_Option_Id          =>  p_Option_Id
    ,p_Parent_Option_Id   =>  p_Parent_Option_Id
    ,p_Grandparent_Option_Id  =>  p_Grandparent_Option_Id
    ,p_Dependency_Flag    =>  p_Dependency_Flag
    ,p_DataSet_Id         =>  p_DataSet_Id
    ,p_DimSet_Id          =>  p_DimSet_Id
    ,p_Default_Flag       =>  p_Default_Flag
    ,p_Option_Name        =>  p_Option_Name
    ,p_Option_Help        =>  p_Option_Help
    ,p_Change_Dim_Set     =>  p_Change_Dim_Set
    ,p_default_calculation=>  p_default_calculation
    ,p_Create_Flow        =>  FND_API.G_TRUE
    ,p_time_stamp         =>  p_time_stamp
    ,p_olddim_Dataset_map =>  l_olddim_Dataset_map
    ,x_return_status      =>  x_return_status
    ,x_msg_count          =>  x_msg_count
    ,x_msg_data           =>  x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Create_Analayis_OptionObjPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        ROLLBACK TO Create_Analayis_OptionObjPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Create_Analayis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Create_Analayis_Option ';
        END IF;
END Create_Analysis_Option_UI;

/************************************************************************************
--	API name 	: Val_Delete_Analysis_Option
--	Type		: Public
--	Function	:
--	1. Validates that there is atleast one analysis option in the objective
--      2. Validates that the parent analysis option is not deleted when there
--         the child group is dependent and it has more than one analysis option
--      3. Validates that none of the kpis that will be deleted by this analysis
--         option deletion have weight > 0
************************************************************************************/

PROCEDURE Val_Delete_Analysis_Option(
  p_Indicator             IN   NUMBER
 ,p_Analysis_Group_Id     IN   NUMBER := 0
 ,p_Option_Id             IN   NUMBER := 0
 ,p_Parent_Option_Id      IN   NUMBER := 0
 ,p_GrandParent_Option_Id IN   NUMBER := 0
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS

  l_Grp_Count NUMBER := 0;
  l_Next_Grp_Count NUMBER := 0;
  l_Total_Groups NUMBER := 0;
  l_Dependency01 bsc_kpi_analysis_groups.dependency_flag%TYPE := -1;
  l_Dependency12 bsc_kpi_analysis_groups.dependency_flag%TYPE := -1;
  l_IsDependent BOOLEAN := FALSE;

  TYPE c_ref_cursor IS REF CURSOR;
  c_Weighted_Kpi    c_ref_cursor;
  c_kpi_full_name   c_ref_cursor;
  c_NumOptions      c_ref_cursor;
  l_kpi_measure_id  bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE := NULL;
  l_kpi_full_name   VARCHAR2(1024) := NULL;
  l_NumOptions NUMBER := 0;
  l_criteria VARCHAR2(2000);
  l_sql VARCHAR2(2000);
  l_Parent_Id            bsc_kpi_analysis_options_b.parent_option_id%TYPE := 0;
  l_GrandParent_Id       bsc_kpi_analysis_options_b.grandparent_option_id%TYPE := 0;
  l_Parent_Group_Id      bsc_kpi_analysis_groups.analysis_group_id%TYPE := 0;
  l_GrandParent_Group_Id bsc_kpi_analysis_groups.analysis_group_id%TYPE := 0;

  CURSOR c_Grp_Cnt(p_Ana_Grp NUMBER) IS
  SELECT
    num_of_options
  FROM
    bsc_kpi_analysis_groups
  WHERE
    indicator = p_Indicator AND
    Analysis_Group_Id = p_Ana_Grp;

  CURSOR c_Num_Groups IS
  SELECT
    MAX(analysis_group_id)
  FROM
    bsc_kpi_analysis_groups
  WHERE
    indicator = p_Indicator;
BEGIN

  FND_MSG_PUB.Initialize;

  OPEN c_Grp_Cnt(p_Analysis_Group_Id);
  FETCH c_Grp_Cnt INTO l_Grp_Count;
  CLOSE c_Grp_Cnt;

  IF p_Analysis_Group_Id = 0 AND p_Option_Id = 0 AND l_Grp_Count = 1 THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_D_AG_AT_LEAST_ONE_AO');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_Dependency01 := Get_Dependency(p_Indicator,1);
  l_Dependency12 := Get_Dependency(p_Indicator,2);

  IF (p_Analysis_Group_Id = 1 AND l_Dependency01 = 1) THEN
    l_IsDependent := TRUE;
  ELSIF (p_Analysis_Group_Id = 2 AND (l_Dependency01 = 1  OR l_Dependency12 = 1 )) THEN
    l_IsDependent := TRUE;
  END IF;

  OPEN c_Num_Groups;
  FETCH c_Num_Groups INTO l_Total_Groups;
  CLOSE c_Num_Groups;

  IF p_Analysis_Group_Id < l_Total_Groups THEN
    OPEN c_Grp_Cnt(p_Analysis_Group_Id + 1);
    FETCH c_Grp_Cnt INTO l_Next_Grp_Count;
    CLOSE c_Grp_Cnt;

    IF (l_Next_Grp_Count > 1 AND p_Option_Id = 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_D_NOT_DELETE_AG_DEPEN');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  Get_Parent_GrandParent_Ids(
    p_Indicator             => p_Indicator
   ,p_Analysis_Group_Id     => p_Analysis_Group_Id
   ,p_Parent_Id             => p_Parent_Option_Id
   ,p_GrandParent_Id        => p_GrandParent_Option_Id
   ,p_Independent_Par_Id    => -1
   ,x_Parent_Id             => l_Parent_Id
   ,x_GrandParent_Id        => l_GrandParent_Id
   ,x_Parent_Group_Id       => l_Parent_Group_Id
   ,x_GrandParent_Group_Id  => l_GrandParent_Group_Id
  );

  l_sql := 'SELECT COUNT(1) FROM bsc_kpi_analysis_options_b WHERE indicator = ' || p_Indicator ;
  l_sql := l_sql || ' AND analysis_group_id = ' || p_Analysis_Group_Id;

  IF l_Parent_Group_Id <> -1 THEN
    l_sql := l_sql || ' AND parent_option_id = '|| l_Parent_Id;
    IF l_GrandParent_Group_Id <> -1 THEN
      l_sql := l_sql || ' AND grandparent_option_id= ' || l_GrandParent_Id;
    END IF;
  END IF;


  OPEN c_NumOptions FOR l_sql;
  FETCH c_NumOptions INTO l_NumOptions;
  CLOSE c_NumOptions;

  IF l_NumOptions > 1 THEN
    l_criteria := ' WHERE indicator = '|| p_Indicator;
    IF p_Option_Id <> -1 THEN
      l_criteria := l_criteria || ' AND analysis_option'|| p_Analysis_Group_Id || ' = '|| p_Option_Id;
    END IF;
    IF l_Parent_Group_Id <> -1 THEN
      l_criteria := l_criteria || ' AND analysis_option'|| l_Parent_Group_Id || ' = '|| l_Parent_Id;
      IF l_GrandParent_Group_Id <> -1 THEN
        l_criteria := l_criteria || ' AND analysis_option'|| l_GrandParent_Group_Id || ' = '|| l_GrandParent_Id;
      END IF;
    END IF;
    l_sql := 'SELECT kpi_measure_id FROM bsc_kpi_measure_weights WHERE indicator = ' || p_Indicator;
    l_sql := l_sql || ' AND weight > 0 INTERSECT SELECT kpi_measure_id FROM bsc_kpi_analysis_measures_b ';
    l_sql := l_sql || l_criteria;

    OPEN c_Weighted_Kpi FOR l_sql;
    FETCH c_Weighted_Kpi INTO l_kpi_measure_id;
    CLOSE c_Weighted_Kpi;

    IF l_kpi_measure_id IS NOT NULL THEN
      l_sql := ' SELECT full_name FROM bsc_oaf_analysys_opt_comb_v '|| l_criteria;
      OPEN c_kpi_full_name FOR l_sql;
      FETCH c_kpi_full_name INTO l_kpi_full_name;
      CLOSE c_kpi_full_name;

      IF l_kpi_full_name IS NOT NULL THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_KPI_WEIGHT_ZERO ');
        FND_MESSAGE.SET_TOKEN('KPI_NAME', l_kpi_full_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Validate_Delete_Analysis_Option ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Validate_Delete_Analysis_Option ';
        END IF;
END Val_Delete_Analysis_Option;

/************************************************************************************
--	API name 	: Get_Next_Option_Id
--	Type		: Public
************************************************************************************/

PROCEDURE Get_Next_Option_Id (
  p_Indicator            IN NUMBER
 ,p_Analysis_Group_Id   IN NUMBER
 ,p_Parent_Option_Id    IN NUMBER
 ,p_Grandparent_Option_Id  IN NUMBER
 ,x_Option_Id           OUT NOCOPY NUMBER
)  IS
  l_Dependency01 bsc_kpi_analysis_groups.dependency_flag%TYPE;
  l_Dependency12 bsc_kpi_analysis_groups.dependency_flag%TYPE;
  l_Parent_Id      bsc_kpi_analysis_options_b.parent_option_id%TYPE := 0;
  l_GrandParent_Id bsc_kpi_analysis_options_b.grandparent_option_id%TYPE := 0;
  l_Next_Option_Id bsc_kpi_analysis_options_b.option_id%TYPE := NULL;
  l_Parent_Group_Id      bsc_kpi_analysis_groups.analysis_group_id%TYPE := 0;
  l_GrandParent_Group_Id bsc_kpi_analysis_groups.analysis_group_id%TYPE := 0;

  CURSOR c_Next_Opt_Id(p_Parent NUMBER, p_GrandParent NUMBER) IS
  SELECT
    MAX(option_id) AS MAX
  FROM
    bsc_kpi_analysis_options_b
  WHERE
    indicator =  p_Indicator
    AND analysis_group_id = p_Analysis_Group_Id
    AND parent_option_id = p_Parent
    AND grandparent_option_id = p_GrandParent
  GROUP BY
    indicator,analysis_group_id,parent_option_id,grandparent_option_id;

BEGIN

  l_Dependency01 := Get_Dependency(p_Indicator,1);
  l_Dependency12 := Get_Dependency(p_Indicator,2);
  Get_Parent_GrandParent_Ids(
    p_Indicator      =>   p_Indicator
   ,p_Analysis_Group_Id  =>   p_Analysis_Group_Id
   ,p_Parent_Id      =>   p_Parent_Option_Id
   ,p_GrandParent_Id =>   p_Grandparent_Option_Id
   ,p_Independent_Par_Id => 0
   ,x_Parent_Id      =>   l_Parent_Id
   ,x_GrandParent_Id =>   l_GrandParent_Id
   ,x_Parent_Group_Id       => l_Parent_Group_Id
   ,x_GrandParent_Group_Id  => l_GrandParent_Group_Id
  );


  OPEN c_Next_Opt_Id(l_Parent_Id, l_GrandParent_Id);
  FETCH c_Next_Opt_Id INTO l_Next_Option_Id;
  CLOSE c_Next_Opt_Id;

  IF l_Next_Option_Id IS NULL THEN
    l_Next_Option_Id := 0;
  ELSE
    l_Next_Option_Id := l_Next_Option_Id + 1;
  END IF;


  x_Option_Id := l_Next_Option_Id;

EXCEPTION
    WHEN OTHERS THEN
      x_Option_Id :=  NULL;
END Get_Next_Option_Id;

/************************************************************************************
--	API name 	: Get_DataSetId_For_AO_Comb
--	Type		: Public
************************************************************************************/

FUNCTION Get_DataSetId_For_AO_Comb (
   p_Indicator              IN  NUMBER
  ,p_Analayis_Group_Id      IN  NUMBER
  ,p_Option_Id              IN  NUMBER
  ,p_Parent_Option_Id       IN  NUMBER
  ,p_GrandParent_Option_Id  IN  NUMBER
) RETURN NUMBER IS
   CURSOR c_Indicator_Type IS
   SELECT
     indicator_type
   FROM
     bsc_kpis_b
   WHERE indicator = p_Indicator;

   CURSOR c_dataset_id(p_AO0 NUMBER , p_AO1 NUMBER, p_AO2 NUMBER) IS
   SELECT
     dataset_id
   FROM
     bsc_kpi_analysis_measures_b
   WHERE
     indicator = p_Indicator AND
     analysis_option0 = p_AO0 AND
     analysis_option1 = p_AO1 AND
     analysis_option2 = p_AO2 AND
     series_id = 0;

   l_Indicator_Type bsc_kpis_b.indicator_type%TYPE;
   l_Is_Leaf_Node   VARCHAR2(1);
   l_Next_Group_Id  NUMBER;
   l_AO0 bsc_kpi_analysis_measures_b.analysis_option0%TYPE := 0;
   l_AO1 bsc_kpi_analysis_measures_b.analysis_option1%TYPE := 0;
   l_AO2 bsc_kpi_analysis_measures_b.analysis_option2%TYPE := 0;
   l_dataset_id   bsc_sys_datasets_b.dataset_id%TYPE;
--   l_source       bsc_sys_datasets_b.source%TYPE;

BEGIN
    OPEN c_Indicator_Type;
    FETCH c_Indicator_Type INTO l_Indicator_Type;
    CLOSE c_Indicator_Type;

    --For MultiBar Series will always be defined in Update of Series
    IF l_Indicator_Type = 10THEN
        RETURN NULL;
    END IF;

    CASE p_Analayis_Group_Id
       WHEN 0 THEN
          l_AO0 := p_Option_Id;
       WHEN 1 THEN
          l_AO1 := p_Option_Id;
          l_AO0 := p_Parent_Option_Id;
       WHEN 2 THEN
          l_AO2 := p_Option_Id;
          l_AO1 := p_Parent_Option_Id;
          l_AO0 := p_GrandParent_Option_Id;
    END CASE;

    IF (p_Analayis_Group_Id = 0 OR p_Analayis_Group_Id = 1) THEN
        l_Next_Group_Id := p_Analayis_Group_Id + 1;
        IF (Is_Analayis_Option_Valid(p_Indicator, l_AO0, l_AO1, l_AO2, l_Next_Group_Id) = 'Y') THEN
          RETURN NULL;
        END IF;
    END IF;


    OPEN c_dataset_id(l_AO0, l_AO1, l_AO2) ;
    FETCH c_dataset_id INTO l_dataset_id;--,l_source;
    CLOSE c_dataset_id;


    RETURN l_dataset_id;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Get_DataSetId_For_AO_Comb;

/************************************************************************************
--	API name 	: Check_Indicator_Plan
--	Type		: Private
--	Function	:
--
************************************************************************************/
FUNCTION Check_Indicator_Plan (
  p_Indicator  IN NUMBER
) RETURN VARCHAR2 IS
CURSOR c_Ind_BenchMark_Grp IS
SELECT
  bk.bm_group_id
FROM
  bsc_kpis_b bk, bsc_sys_bm_groups bg,bsc_sys_benchmarks_b be
WHERE
  bk.bm_group_id = bg.bm_group_id AND
  be.bm_id = bg.bm_id AND
  be.data_type = 1 AND
  bk.indicator = p_Indicator;

BEGIN
  OPEN c_Ind_BenchMark_Grp;
  IF c_Ind_BenchMark_Grp%ROWCOUNT > 0 THEN
    RETURN FND_API.G_TRUE;
  END IF;

  RETURN FND_API.G_FALSE;
EXCEPTION
WHEN OTHERS THEN
   RETURN FND_API.G_FALSE;
END Check_Indicator_Plan;

/************************************************************************************
--	API name 	: Check_Series_Default_Plan
--	Type		: Private
--	Function	:
--
************************************************************************************/
FUNCTION Check_Series_Default_Plan (
  p_Indicator  IN NUMBER
) RETURN VARCHAR2 IS
l_AO0_Default bsc_kpi_analysis_groups.default_value%TYPE;
l_AO1_Default bsc_kpi_analysis_groups.default_value%TYPE;
l_AO2_Default bsc_kpi_analysis_groups.default_value%TYPE;
CURSOR c_Series_Default_Plan(p_AO0 NUMBER, p_AO1 NUMBER, p_AO2 NUMBER) IS
SELECT
  COUNT(1)
FROM
  bsc_kpi_analysis_measures_b
WHERE
  indicator = p_indicator AND
  analysis_option0 = p_AO0 AND
  analysis_option1 = p_AO1 AND
  analysis_option2 = p_AO2 AND
  default_value = 1 AND
  budget_flag = 1;

BEGIN
  SELECT
    a0_default,a1_default,a2_default
  INTO
    l_AO0_Default, l_AO1_Default, l_AO2_Default
  FROM
    bsc_db_color_ao_defaults_v
  WHERE
    indicator = p_Indicator;

  OPEN c_Series_Default_Plan(l_AO0_Default,l_AO1_Default,l_AO2_Default);
  IF c_Series_Default_Plan%ROWCOUNT > 0 THEN
    RETURN FND_API.G_TRUE;
  END IF;

  RETURN FND_API.G_FALSE;
EXCEPTION
WHEN OTHERS THEN
   RETURN FND_API.G_FALSE;
END Check_Series_Default_Plan;

/************************************************************************************
--	API name 	: Set_Apply_Color
--	Type		: Private
--	Function	: Checks whether the indicator has plan defined or not
--			  Also checks whether series default has plan defined in
--                        case of multibar indicator. This will mark a color
--                        change for the indicator
************************************************************************************/
PROCEDURE Set_Apply_Color (
  p_commit          IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator       IN   NUMBER
 ,x_return_status   OUT NOCOPY   VARCHAR2
 ,x_msg_count       OUT NOCOPY   NUMBER
 ,x_msg_data        OUT NOCOPY   VARCHAR2
) IS
CURSOR c_Kpi_Info IS
SELECT
  indicator_type,config_type
FROM
  bsc_kpis_b
WHERE
  indicator = p_Indicator;

CURSOR c_All_KPIs IS
SELECT
  indicator
FROM
  bsc_kpis_b
WHERE
  indicator = p_Indicator OR
  (source_indicator = p_Indicator AND prototype_flag <> 2);
l_indicator_type bsc_kpis_b.indicator_type%TYPE;
l_config_type bsc_kpis_b.config_type%TYPE;
l_apply_color bsc_kpis_b.apply_color_flag%TYPE;
BEGIN
  SAVEPOINT Set_Apply_Color_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  -- As of now there is place where plan benchmark can be disabled
  -- So this may always return true
  IF FND_API.To_Boolean(Check_Indicator_Plan(p_Indicator)) THEN
    OPEN c_Kpi_Info;
    FETCH c_Kpi_Info INTO l_indicator_type,l_config_type;
    CLOSE c_Kpi_Info;
    l_apply_color := 1;
    IF l_indicator_type = 10 THEN
        IF NOT FND_API.TO_Boolean(Check_Series_Default_Plan(p_Indicator)) THEN
          l_apply_color := 0;
        END IF;
    ELSIF l_config_type = 7 THEN
      /*Not Needed For Now*/
      NULL;
    END IF;
  END IF;
    FOR cd in c_All_KPIs LOOP
      UPDATE bsc_kpis_b
      SET apply_color_flag = l_apply_color
      WHERE indicator = cd.indicator;

      BSC_DESIGNER_PVT.ActionFlag_Change (
        x_indicator => cd.indicator
       ,x_newflag   => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
      );
    END LOOP;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK TO Set_Apply_Color_PVT;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Set_Apply_Color';
  ELSE
      x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Set_Apply_Color ';
  END IF;
END Set_Apply_Color;

/************************************************************************************
--	API name 	: Get_Analysis_Option_Name
--	Type		: Public
--	Function	: This API is used in HGrid VO Queries
************************************************************************************/

FUNCTION Get_Analysis_Option_Name(
  p_Indicator        NUMBER,
  p_Analysis_Option0 NUMBER,
  p_Analysis_Option1 NUMBER,
  p_Analysis_Option2 NUMBER,
  p_Group_Id         NUMBER
) RETURN VARCHAR2
IS
  l_Name bsc_kpi_analysis_options_vl.Name%TYPE;
  l_Count NUMBER := 0;
  l_Dependency01 bsc_kpi_analysis_groups.dependency_flag%TYPE := 0;
  l_Dependency12 bsc_kpi_analysis_groups.dependency_flag%TYPE := 0;
  l_option_id NUMBER := 0;
  l_parent_id NUMBER := 0;
  l_grandparent_id NUMBER := 0;

  CURSOR c_dependency_flag(p_group_id NUMBER) IS
  SELECT
    ag.dependency_flag
  FROM
  bsc_kpi_analysis_groups ag
  WHERe
    ag.indicator = p_Indicator AND
    ag.analysis_group_id = p_group_id;

  CURSOR c_Name(l_option_id NUMBER,l_parent_id NUMBER, l_grandParentId NUMBER) IS
  SELECT
    name
  FROM
    bsc_kpi_analysis_options_vl  o
  WHERE
    o.indicator             = p_Indicator AND
    o.analysis_group_id     = p_Group_Id AND
    o.option_id             = l_option_id AND
    o.parent_option_id      = l_parent_id AND
    o.grandparent_option_id = l_grandParentId;

BEGIN

  OPEN c_dependency_flag(1);
  FETCH c_dependency_flag INTO l_Dependency01;
  CLOSE c_dependency_flag;

  OPEN c_dependency_flag(2);
  FETCH c_dependency_flag INTO l_Dependency12;
  CLOSE c_dependency_flag;

  CASE p_Group_Id
    WHEN 0 THEN
      l_option_id := p_Analysis_Option0;
    WHEN 1 THEN
      l_option_id := p_Analysis_Option1;
      IF l_Dependency01 = 1 THEN
        l_parent_id := p_Analysis_Option0;
      END IF;
    WHEN 2 THEN
      l_option_id := p_Analysis_Option2;
      IF l_Dependency12 = 1 THEN
        l_parent_id := p_Analysis_Option1;
        IF l_Dependency01 = 1 THEN
          l_grandparent_id := p_Analysis_Option0;
        END IF;
      END IF;
  END CASE;

  OPEN c_Name(l_Option_Id, l_parent_id, l_grandparent_id) ;
  FETCH c_Name INTO l_Name;
  CLOSE c_Name;

  RETURN l_Name;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Analysis_Option_Name;

/************************************************************************************
--	API name 	: Is_Analayis_Option_Valid
--	Type		: Public
--	Function	: This API is used in HGrid VO Queries
************************************************************************************/

FUNCTION Is_Analayis_Option_Valid(
  p_Indicator        NUMBER,
  p_Analysis_Option0 NUMBER,
  p_Analysis_Option1 NUMBER,
  p_Analysis_Option2 NUMBER,
  p_Group_Id         NUMBER
) RETURN VARCHAR2
IS
  l_Count NUMBER := 0;
  l_Dependency01 bsc_kpi_analysis_groups.dependency_flag%TYPE := 0;
  l_Dependency12 bsc_kpi_analysis_groups.dependency_flag%TYPE := 0;
  l_option_id NUMBER := 0;
  l_parent_id NUMBER := 0;
  l_grandparent_id NUMBER := 0;

  CURSOR c_dependency_flag(p_group_id NUMBER) IS
  SELECT
    ag.dependency_flag
  FROM
  bsc_kpi_analysis_groups ag
  WHERe
    ag.indicator = p_Indicator AND
    ag.analysis_group_id = p_group_id;

  CURSOR c_AO_Count(l_option_id NUMBER,l_parent_id NUMBER, l_grandParentId NUMBER) IS
  SELECT
    COUNT(1)
  FROM
    bsc_kpi_analysis_options_vl  o
  WHERE
    o.indicator             = p_Indicator AND
    o.analysis_group_id     = p_Group_Id AND
    o.option_id             = l_option_id AND
    o.parent_option_id      = l_parent_id AND
    o.grandparent_option_id = l_grandParentId;

BEGIN

  OPEN c_dependency_flag(1);
  FETCH c_dependency_flag INTO l_Dependency01;
  CLOSE c_dependency_flag;

  OPEN c_dependency_flag(2);
  FETCH c_dependency_flag INTO l_Dependency12;
  CLOSE c_dependency_flag;

  CASE p_Group_Id
    WHEN 0 THEN
      l_option_id := p_Analysis_Option0;
    WHEN 1 THEN
      l_option_id := p_Analysis_Option1;
      IF l_Dependency01 = 1 THEN
        l_parent_id := p_Analysis_Option0;
      END IF;
    WHEN 2 THEN
      l_option_id := p_Analysis_Option2;
      IF l_Dependency12 = 1 THEN
        l_parent_id := p_Analysis_Option1;
        IF l_Dependency01 = 1 THEN
          l_grandparent_id := p_Analysis_Option0;
        END IF;
      END IF;
  END CASE;

  OPEN c_AO_Count(l_Option_Id, l_parent_id, l_grandparent_id) ;
  FETCH c_AO_Count INTO l_Count;
  CLOSE c_AO_Count;

  IF l_Count > 0 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Y';
END Is_Analayis_Option_Valid;

/************************************************************************************
--	API name 	: Get_Parent_Id
--	Type		: Public
--	Function	: This API is used in HGrid VO Queries
************************************************************************************/

FUNCTION Get_Parent_Id (
  p_Indicator        NUMBER,
  p_Analysis_GroupId NUMBER,
  p_Option_Id        NUMBER,
  p_Parent_Id        NUMBER
)RETURN NUMBER IS
l_dependency NUMBER;
BEGIN
  IF p_Analysis_GroupId <> 0 THEN
    l_dependency := Get_Dependency(p_Indicator,p_Analysis_GroupId);
    IF l_dependency = 0 THEN
      RETURN 0;
    ELSE
      RETURN p_Parent_Id;
    END IF;
  END IF;
  RETURN 0;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END Get_Parent_Id;

/************************************************************************************
--	API name 	: Get_Grand_Parent_Id
--	Type		: Public
--	Function	: This API is used in HGrid VO 	queries
************************************************************************************/

FUNCTION Get_Grand_Parent_Id (
  p_Indicator        NUMBER,
  p_Analysis_GroupId NUMBER,
  p_Option_Id        NUMBER,
  p_GrandParent_Id   NUMBER
)RETURN NUMBER IS
  l_dependency01 NUMBER;
  l_dependency12 NUMBER;

BEGIN
  IF p_Analysis_GroupId = 2 THEN
    l_dependency01 := Get_Dependency(p_Indicator, 1);
    l_dependency12 := Get_Dependency(p_Indicator, 2);
    IF l_dependency01 = 1 AND l_dependency12 = 1 THEN
      RETURN p_GrandParent_Id;
    END IF;
  END IF;

  RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END Get_Grand_Parent_Id;


/************************************************************************************
--	API name 	: Get_Dim_Set_Id
--	Type		: Private
--	Function	: Returns the dimension set that will be used for a given
--                        analysis option combination
--      If there is no dimension set associated at a particular level then it
--      will return null (In which case zeroeth dimension set will be taken into
--      consideration by IViewer as well as GDB
************************************************************************************/

FUNCTION Get_Dim_Set_Id(
  p_Indicator             IN  NUMBER
 ,p_Analysis_Option0      IN  NUMBER := 0
 ,p_Analysis_Option1      IN  NUMBER := 0
 ,p_Analysis_Option2      IN  NUMBER := 0
 ,p_Dim_Set_Group         IN  NUMBER := 0
) RETURN NUMBER IS

  l_DimSet_Id    bsc_kpi_analysis_options_b.dim_set_id%TYPE := NULL;
  l_Option_Id    bsc_kpi_analysis_options_b.option_id%TYPE := 0;
  l_Parent_Id    bsc_kpi_analysis_options_b.option_id%TYPE := 0;
  l_GrandParent_Id    bsc_kpi_analysis_options_b.option_id%TYPE := 0;

  CURSOR c_Dim_Set_ID(p_Analysis_Group_Id NUMBER,
         p_Option_Id NUMBER, p_Parent_Id NUMBER, p_GrandParentId NUMBER) IS
  SELECT
    dim_set_id
  FROM
    bsc_kpi_analysis_options_b
  WHERE
    indicator = p_Indicator AND
    analysis_group_id = p_Analysis_Group_Id AND
    option_id = p_Option_Id AND
    parent_option_id = p_Parent_Id AND
    grandparent_option_id = p_GrandParentId;

BEGIN

  CASE p_Dim_Set_Group
    WHEN 0 THEN
      l_Option_Id := p_Analysis_Option0;
    WHEN 1 THEN
      l_Option_Id := p_Analysis_Option1;
      l_Parent_Id := p_Analysis_Option0;
    WHEN 2 THEN
      l_Option_Id := p_Analysis_Option2;
      l_Parent_Id := p_Analysis_Option1;
      l_GrandParent_Id := p_Analysis_Option0;
  END CASE;

  OPEN c_Dim_Set_ID(p_Dim_Set_Group, l_Option_Id, l_Parent_Id, l_GrandParent_Id);
  FETCH c_Dim_Set_ID INTO l_DimSet_Id;
  CLOSE c_Dim_Set_ID;

  IF l_DimSet_Id IS  NULL THEN
    l_DimSet_Id := Get_Dim_Set_Id (
                     p_Indicator         =>  p_Indicator
                    ,p_Analysis_Option0  =>  p_Analysis_Option0
                    ,p_Analysis_Option1  =>  p_Analysis_Option1
                    ,p_Analysis_Option2  =>  p_Analysis_Option2
                    ,p_Dim_Set_Group     =>  p_Dim_Set_Group - 1
                    );
  END IF;
  RETURN l_DimSet_Id;
EXCEPTION
 WHEN OTHERS THEN
   RETURN 0;
END Get_Dim_Set_Id ;

/************************************************************************************
--	API name 	: Get_Kpi_Property
--	Type		: Public
************************************************************************************/

FUNCTION Get_Kpi_Property (
   p_Indicator              IN  NUMBER
  ,p_Analayis_Group_Id      IN  NUMBER
  ,p_Option_Id              IN  NUMBER
  ,p_Parent_Option_Id       IN  NUMBER
  ,p_GrandParent_Option_Id  IN  NUMBER
  ,p_Property_Name          IN  VARCHAR2
) RETURN NUMBER IS
   CURSOR c_Indicator_Type IS
   SELECT
     indicator_type
   FROM
     bsc_kpis_b
   WHERE indicator = p_Indicator;

   CURSOR c_kpi_measure_id(p_AO0 NUMBER , p_AO1 NUMBER, p_AO2 NUMBER) IS
   SELECT
     kpi_measure_id
   FROM
     bsc_kpi_analysis_measures_b
   WHERE
     indicator = p_Indicator AND
     analysis_option0 = p_AO0 AND
     analysis_option1 = p_AO1 AND
     analysis_option2 = p_AO2 AND
     series_id = 0;

   l_Indicator_Type bsc_kpis_b.indicator_type%TYPE;
   l_Next_Group_Id  NUMBER;
   l_AO0 bsc_kpi_analysis_measures_b.analysis_option0%TYPE := 0;
   l_AO1 bsc_kpi_analysis_measures_b.analysis_option1%TYPE := 0;
   l_AO2 bsc_kpi_analysis_measures_b.analysis_option2%TYPE := 0;
   l_kpi_measure_id   bsc_sys_datasets_b.dataset_id%TYPE;
   l_Property_Value   NUMBER;

BEGIN
    OPEN c_Indicator_Type;
    FETCH c_Indicator_Type INTO l_Indicator_Type;
    CLOSE c_Indicator_Type;

    --For MultiBar Series will always be defined in Update of Series
    IF l_Indicator_Type = 10 THEN
        RETURN NULL;
    END IF;

    CASE p_Analayis_Group_Id
       WHEN 0 THEN
          l_AO0 := p_Option_Id;
       WHEN 1 THEN
          l_AO1 := p_Option_Id;
          l_AO0 := p_Parent_Option_Id;
       WHEN 2 THEN
          l_AO2 := p_Option_Id;
          l_AO1 := p_Parent_Option_Id;
          l_AO0 := p_GrandParent_Option_Id;
    END CASE;

    IF (p_Analayis_Group_Id = 0 OR p_Analayis_Group_Id = 1) THEN
        l_Next_Group_Id := p_Analayis_Group_Id + 1;
        IF (Is_Analayis_Option_Valid(p_Indicator, l_AO0, l_AO1, l_AO2, l_Next_Group_Id) = 'Y') THEN
          RETURN NULL;
        END IF;
    END IF;


    OPEN c_kpi_measure_id(l_AO0, l_AO1, l_AO2) ;
    FETCH c_kpi_measure_id INTO l_kpi_measure_id;
    CLOSE c_kpi_measure_id;

    IF l_kpi_measure_id IS NOT NULL THEN
      IF p_Property_Name = 'DATASET_ID' THEN
        SELECT
          dataset_id
        INTO
          l_Property_Value
        FROM
          bsc_kpi_analysis_measures_b
        WHERE
          indicator = p_Indicator
          AND kpi_measure_id = l_kpi_measure_id;
      ELSIF p_Property_Name = 'DEFAULT_CALCULATION' THEN
        SELECT
          default_calculation
        INTO
          l_Property_Value
        FROM
          bsc_kpi_measure_props
        WHERE
          indicator = p_Indicator
          AND kpi_measure_id = l_kpi_measure_id;
      END IF;
    END IF;

    RETURN l_Property_Value;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Get_Kpi_Property;

END BSC_OBJ_ANALYSIS_OPTIONS_PUB;

/
