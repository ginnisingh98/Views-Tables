--------------------------------------------------------
--  DDL for Package Body BSC_KPI_SERIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_SERIES_PUB" as
/* $Header: BSCPSERB.pls 120.1.12000000.2 2007/07/27 10:04:25 akoduri noship $ */


/************************************************************************************
--	API name 	: Check_Color_Props
--	Type		: Public
--      Sets the disable_color flag of bsc_kpi_measure_props depending on the
--      following conditions
--      1. apply_color_flag will be set to FALSE if Plan is disabled
--      2. disable_color will be set to FALSE if the color method is default KPI
--         based and disable_color was TRUE earlier (The current series should have
--         p_Default_Flag set to 1)
************************************************************************************/
PROCEDURE Check_Color_Props(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Option0      IN   NUMBER
 ,p_Analysis_Option1      IN   NUMBER
 ,p_Analysis_Option2      IN   NUMBER
 ,p_Series_Id             IN   NUMBER
 ,p_Budget_Flag           IN   NUMBER := 0
 ,p_Default_Flag          IN   NUMBER := 0
 ,p_Dataset_Id            IN   NUMBER := -1
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS

  l_kpi_measure_props_rec bsc_kpi_measure_props_pub.kpi_measure_props_rec;
  l_kpi_measure_id bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE;
  l_A0_Def         bsc_kpi_analysis_measures_b.analysis_option0%TYPE;
  l_A1_Def         bsc_kpi_analysis_measures_b.analysis_option0%TYPE;
  l_A2_Def         bsc_kpi_analysis_measures_b.analysis_option0%TYPE;
  l_Source         bsc_sys_datasets_vl.source%TYPE := 'BSC';

  CURSOR c_kpi_measure_id IS
  SELECT
    km.kpi_measure_id
  FROM
    bsc_kpi_analysis_measures_b km
  WHERE km.indicator    = p_Indicator AND
    km.analysis_option0 = p_Analysis_Option0 AND
    km.analysis_option1 = p_Analysis_Option1 AND
    km.analysis_option2 = p_Analysis_Option2 AND
    km.series_id        = p_Series_Id ;

  CURSOR c_Default_AO_Comb IS
  SELECT
    a0_default, a1_default, a2_default
  FROM
    bsc_db_color_ao_defaults_v
  WHERE
    indicator = p_Indicator;

  CURSOR c_Source IS
  SELECT
    source
  FROM
    bsc_sys_datasets_vl
  WHERE
    dataset_id = p_Dataset_Id;

BEGIN

  SAVEPOINT  Check_Color_Props_PUB;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  OPEN c_kpi_measure_id;
  FETCH c_kpi_measure_id INTO l_kpi_measure_id;
  CLOSE c_kpi_measure_id;

  BSC_KPI_MEASURE_PROPS_PUB.Retrieve_Kpi_Measure_Props (
     p_objective_id    =>  p_Indicator
    , p_kpi_measure_id  =>  l_kpi_measure_id
    , x_kpi_measure_rec =>  l_kpi_measure_props_rec
    , x_return_status   =>  x_return_status
    , x_msg_count       =>  x_msg_count
    , x_msg_data        =>  x_msg_data
  ) ;
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN c_Default_AO_Comb;
  FETCH c_Default_AO_Comb INTO l_A0_Def, l_A1_Def, l_A2_Def;
  CLOSE c_Default_AO_Comb;

  OPEN c_Source;
  FETCH c_Source INTO l_Source;
  CLOSE c_Source;

  IF p_Budget_Flag = 0 THEN
    l_kpi_measure_props_rec.apply_color_flag := 0;
  ELSE
    l_kpi_measure_props_rec.apply_color_flag := 1;
  END IF;

  IF (l_A0_Def = p_Analysis_Option0 AND l_A1_Def = p_Analysis_Option1
           AND l_A2_Def = p_Analysis_Option2 AND p_Default_Flag = 1
           AND l_kpi_measure_props_rec.disable_color = 'T' AND l_Source <> 'PMF') THEN
    l_kpi_measure_props_rec.disable_color := 'F';
  END IF;

  BSC_KPI_MEASURE_PROPS_PUB.Update_Kpi_Measure_Props (
      p_Commit          =>  FND_API.G_FALSE
    , p_kpi_measure_rec =>  l_kpi_measure_props_rec
    , p_cascade_shared  =>  FALSE
    , x_return_status   =>  x_return_status
    , x_msg_count       =>  x_msg_count
    , x_msg_data        =>  x_msg_data
  ) ;
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.To_Boolean(p_Commit) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Check_Color_Props_PUB;
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Check_Color_Props_PUB;
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO Check_Color_Props_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Check_Color_Props ';
    ELSE
        x_msg_data      :=  SQLERRM||'BSC_KPI_SERIES_PUB.Check_Color_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO Check_Color_Props_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Check_Color_Props ';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_KPI_SERIES_PUB.Check_Color_Props ';
    END IF;
END Check_Color_Props;

/************************************************************************************
--	API name 	: Save_Default_Calculation
--	Type		: Public
--      Sets the default calculation at the kpi level
--      populates the default_calculation of bsc_kpi_measure_props
************************************************************************************/
PROCEDURE Save_Default_Calculation(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Option0      IN   NUMBER
 ,p_Analysis_Option1      IN   NUMBER
 ,p_Analysis_Option2      IN   NUMBER
 ,p_Series_Id             IN   NUMBER
 ,p_default_calculation   IN   NUMBER := NULL
 ,p_casacade_shared       IN   VARCHAR2 := FND_API.G_TRUE
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS

  l_kpi_measure_props_rec bsc_kpi_measure_props_pub.kpi_measure_props_rec;
  l_kpi_measure_id bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE;
  l_color_rollup_type bsc_kpis_b.color_rollup_type%TYPE;

  CURSOR c_kpi_measure_id IS
  SELECT
    km.kpi_measure_id
  FROM
    bsc_kpi_analysis_measures_b km
  WHERE km.indicator    = p_Indicator AND
    km.analysis_option0 = p_Analysis_Option0 AND
    km.analysis_option1 = p_Analysis_Option1 AND
    km.analysis_option2 = p_Analysis_Option2 AND
    km.series_id        = p_Series_Id ;

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

  SAVEPOINT  Save_Default_Calculation_PUB;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  OPEN c_kpi_measure_id;
  FETCH c_kpi_measure_id INTO l_kpi_measure_id;
  CLOSE c_kpi_measure_id;

  BSC_KPI_MEASURE_PROPS_PUB.Retrieve_Kpi_Measure_Props (
     p_objective_id    =>  p_Indicator
    , p_kpi_measure_id  =>  l_kpi_measure_id
    , x_kpi_measure_rec =>  l_kpi_measure_props_rec
    , x_return_status   =>  x_return_status
    , x_msg_count       =>  x_msg_count
    , x_msg_data        =>  x_msg_data
  ) ;
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF NOT BSC_COPY_INDICATOR_PUB.Is_Numeric_Field_Equal(l_kpi_measure_props_rec.default_calculation, p_default_calculation) THEN
    l_kpi_measure_props_rec.default_calculation := p_default_calculation;

    BSC_KPI_MEASURE_PROPS_PUB.Update_Kpi_Measure_Props (
        p_Commit          =>  FND_API.G_FALSE
      , p_kpi_measure_rec =>  l_kpi_measure_props_rec
      , p_cascade_shared  =>  FALSE
      , x_return_status   =>  x_return_status
      , x_msg_count       =>  x_msg_count
      , x_msg_data        =>  x_msg_data
    ) ;
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_color_rollup_type := BSC_COLOR_CALC_UTIL.Get_Obj_Color_Rollup_Type(p_Indicator);
    IF l_color_rollup_type <> BSC_COLOR_CALC_UTIL.DEFAULT_KPI OR
       (l_color_rollup_type = BSC_COLOR_CALC_UTIL.DEFAULT_KPI AND
         BSC_COLOR_CALC_UTIL.Get_Default_Kpi_Measure_Id(p_Indicator) = l_kpi_measure_id)THEN
       BSC_DESIGNER_PVT.ActionFlag_Change (
          x_indicator => p_Indicator
         ,x_newflag   => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
       );
    END IF;

    IF p_casacade_shared = FND_API.G_TRUE THEN
      FOR cd IN c_shared_objs LOOP
        Save_Default_Calculation(
          p_commit              =>  FND_API.G_FALSE
         ,p_Indicator           =>  cd.Indicator
         ,p_Analysis_Option0    =>  p_Analysis_Option0
         ,p_Analysis_Option1    =>  p_Analysis_Option1
         ,p_Analysis_Option2    =>  p_Analysis_Option2
         ,p_Series_Id           =>  p_Series_Id
         ,p_default_calculation =>  p_default_calculation
         ,p_casacade_shared     =>  FND_API.G_FALSE
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END LOOP;
    END IF;

    IF FND_API.To_Boolean(p_Commit) THEN
      COMMIT;
    END IF;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Save_Default_Calculation_PUB;
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Save_Default_Calculation_PUB;
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO Save_Default_Calculation_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Save_Default_Calculation ';
    ELSE
        x_msg_data      :=  SQLERRM||'BSC_KPI_SERIES_PUB.Save_Default_Calculation ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO Save_Default_Calculation_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Save_Default_Calculation ';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_KPI_SERIES_PUB.Save_Default_Calculation ';
    END IF;
END Save_Default_Calculation;

/************************************************************************************
--	API name 	: Check_Series_Default_Props
--	Type		: Public
--	Function	: Validates whether the default analysis option combination
--			  has atleast one series set as default
************************************************************************************/

PROCEDURE Check_Series_Default_Props(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS

l_AnaOpt0_Default bsc_kpi_analysis_groups.default_value%TYPE := 0;
l_AnaOpt1_Default bsc_kpi_analysis_groups.default_value%TYPE := 0;
l_AnaOpt2_Default bsc_kpi_analysis_groups.default_value%TYPE := 0;
l_First_Series_Id bsc_kpi_analysis_measures_b.series_id%TYPE := 0;

CURSOR c_Preselected_Series(p_Analysis_Option0 NUMBER,p_Analysis_Option1 NUMBER,p_Analysis_Option2 NUMBER) IS
SELECT
  series_id
FROM
  bsc_kpi_analysis_measures_b
WHERE
  indicator = p_Indicator AND
  analysis_option0 = p_Analysis_Option0 AND
  analysis_option1 = p_Analysis_Option1 AND
  analysis_option2 = p_Analysis_Option2 AND
  default_value = 1;

BEGIN
  SAVEPOINT  Check_Series_Default_Props_PUB;
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

  OPEN c_Preselected_Series (l_AnaOpt0_Default,l_AnaOpt1_Default,l_AnaOpt2_Default);
  FETCH c_Preselected_Series INTO l_First_Series_Id;
    UPDATE
      bsc_kpi_analysis_measures_b
    SET
      default_value = 0
    WHERE indicator = p_Indicator AND
      analysis_option0 = l_AnaOpt0_Default AND
      analysis_option1 = l_AnaOpt1_Default AND
      analysis_option2 = l_AnaOpt2_Default AND
      series_id <> l_First_Series_Id;

    UPDATE
      bsc_kpi_analysis_measures_b
    SET
      default_value = 1
    WHERE indicator = p_Indicator AND
      analysis_option0 = l_AnaOpt0_Default AND
      analysis_option1 = l_AnaOpt1_Default AND
      analysis_option2 = l_AnaOpt2_Default AND
      series_id = l_First_Series_Id;
  CLOSE c_Preselected_Series;

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
	ROLLBACK TO Check_Series_Default_Props_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_OBJ_ANALYSIS_OPTIONS_PUB.Check_Series_Default_Props ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_OBJ_ANALYSIS_OPTIONS_PUB.Check_Series_Default_Props ';
        END IF;
END Check_Series_Default_Props;

/************************************************************************************
--	API name 	: Update_Color_Structure_Flags
--	Type		: Private
************************************************************************************/
PROCEDURE Update_Color_Structure_Flags (
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator         IN   NUMBER
 ,p_Action_Flag       IN   NUMBER := 3
 ,x_return_status     OUT NOCOPY   VARCHAR2
 ,x_msg_count         OUT NOCOPY   NUMBER
 ,x_msg_data          OUT NOCOPY   VARCHAR2
) IS

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

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_Action_Flag = 7 THEN
     BSC_DESIGNER_PVT.ActionFlag_Change (
       x_indicator => p_Indicator
      ,x_newflag   => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
     );
     FOR cd IN c_shared_objs LOOP
       BSC_DESIGNER_PVT.ActionFlag_Change (
          x_indicator => cd.indicator
         ,x_newflag   => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
       );
     END LOOP;
  END IF;

  IF p_Action_Flag = 3 THEN
     BSC_DESIGNER_PVT.ActionFlag_Change (
       x_indicator => p_Indicator
      ,x_newflag   => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure
     );
     FOR cd IN c_shared_objs LOOP
       BSC_DESIGNER_PVT.ActionFlag_Change (
          x_indicator => cd.indicator
         ,x_newflag   => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure
       );
     END LOOP;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Update_Color_Structure_Flags ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_SERIES_PUB.Update_Color_Structure_Flags ';
        END IF;
END Update_Color_Structure_Flags;

/************************************************************************************
--	API name 	: Get_Series_Actual_Color
--	Type		: Private
************************************************************************************/
FUNCTION Get_Series_Color (
  p_Color_Values          IN   FND_TABLE_OF_NUMBER := NULL
 ,p_Get_Actual_Color      IN   VARCHAR2 := FND_API.G_TRUE
) RETURN NUMBER IS

l_Color_Value  bsc_kpi_analysis_measures_b.series_color%TYPE := 0;
l_bm_id        bsc_sys_benchmarks_b.bm_id%TYPE;
i              NUMBER := 0;
found          BOOLEAN := FALSE;
BEGIN

  WHILE (NOT found AND i < p_Color_Values.COUNT) LOOP
     l_bm_id := p_Color_Values(i);
     IF (FND_API.To_Boolean( p_Get_Actual_Color) AND l_bm_id = 0) THEN
       l_Color_Value := p_Color_Values(i + 1);
       found := TRUE;
     END IF;
     IF (NOT FND_API.To_Boolean( p_Get_Actual_Color) AND l_bm_id = 0) THEN
       l_Color_Value := p_Color_Values(i + 1);
       found := TRUE;
     END IF;
     i := i + 2;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    RETURN l_Color_Value;
END Get_Series_Color;

/************************************************************************************
--	API name 	: Create_Analysis_Measure_UI
--	Type		: Public
--	Procedure	:
--      1. Creates an analysis measure entry in bsc_kpi_analysis_measures table
--	2. Populates the series color properties into bsc_kpi_series_colors
--      3. Also sets the color enable/disable properties
************************************************************************************/
PROCEDURE Create_Analysis_Measure_UI(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Option0      IN   NUMBER
 ,p_Analysis_Option1      IN   NUMBER
 ,p_Analysis_Option2      IN   NUMBER
 ,p_Series_Id             IN   NUMBER
 ,p_Axis                  IN   NUMBER := 0
 ,p_Series_Type           IN   NUMBER := 0
 ,p_Bm_Flag               IN   NUMBER := 0
 ,p_Budget_Flag           IN   NUMBER := 0
 ,p_Default_Flag          IN   NUMBER := 0
 ,p_Stack_Series_Id       IN   NUMBER := NULL
 ,p_Series_Name           IN   VARCHAR2
 ,p_Series_Help           IN   VARCHAR2
 ,p_dataset_Id            IN   NUMBER := -1
 ,p_Color_Values          IN   FND_TABLE_OF_NUMBER := NULL
 ,p_default_calculation   IN   NUMBER := NULL
 ,p_time_stamp            IN   VARCHAR2 := NULL
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS
  l_Anal_Opt_Rec          BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
  l_Bsc_Kpi_Entity_Rec    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
  l_Count                 NUMBER := 0;
  l_old_default_kpi    bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE;

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
   x_return_status := FND_API.G_RET_STS_SUCCESS;

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
   (      p_Kpi_Id            =>  p_Indicator
     ,   p_time_stamp         =>  p_time_stamp
     ,   p_Full_Lock_Flag     =>  NULL
     ,   x_return_status      =>  x_return_status
     ,   x_msg_count          =>  x_msg_count
     ,   x_msg_data           =>  x_msg_data
   );
   IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_Anal_Opt_Rec.Bsc_Kpi_Id := p_Indicator;
   l_Anal_Opt_Rec.Bsc_Option_Group0 := p_Analysis_Option0;
   l_Anal_Opt_Rec.Bsc_Option_Group1 := p_Analysis_Option1;
   l_Anal_Opt_Rec.Bsc_Option_Group2 := p_Analysis_Option2;
   l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := p_Series_Id;
   l_Anal_Opt_Rec.Bsc_Dataset_Id := p_dataset_Id;
   l_Anal_Opt_Rec.Bsc_Dataset_Axis := p_Axis;
   l_Anal_Opt_Rec.Bsc_Dataset_Series_Type := p_Series_Type;
   l_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag := p_Bm_Flag;
   l_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag := p_Budget_Flag;
   l_Anal_Opt_Rec.Bsc_Dataset_Default_Value := p_Default_Flag;
   l_Anal_Opt_Rec.Bsc_Measure_Long_Name := p_Series_Name;
   l_Anal_Opt_Rec.Bsc_Measure_Help := p_Series_Help;
   l_Anal_Opt_Rec.Bsc_Dataset_Stack_Series_Id  := p_Stack_Series_Id;
   l_Anal_Opt_Rec.Bsc_Dataset_Series_Color  := Get_Series_Color (p_Color_Values, FND_API.G_TRUE);
   l_Anal_Opt_Rec.Bsc_Dataset_Bm_Color  := Get_Series_Color (p_Color_Values, FND_API.G_TRUE);

   BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Measures(
       p_commit        =>    FND_API.G_FALSE
      ,p_Anal_Opt_Rec  =>    l_Anal_Opt_Rec
      ,x_return_status =>    x_return_status
      ,x_msg_count     =>    x_msg_count
      ,x_msg_data      =>    x_msg_data
   );
   IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   --Populate bsc_kpi_series_colors table
   IF p_Color_Values IS NOT NULL THEN
     --Populate bsc_kpi_series_colors table
     Populate_Kpi_Series_Colors (
       p_commit        =>    FND_API.G_FALSE
      ,p_Anal_Opt_Rec  =>    l_Anal_Opt_Rec
      ,p_Color_Values  =>    p_Color_Values
      ,x_return_status =>    x_return_status
      ,x_msg_count     =>    x_msg_count
      ,x_msg_data      =>    x_msg_data
     );
     IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

   Check_Color_Props(
     p_commit           =>  FND_API.G_FALSE
    ,p_Indicator        =>  p_Indicator
    ,p_Analysis_Option0 =>  p_Analysis_Option0
    ,p_Analysis_Option1 =>  p_Analysis_Option1
    ,p_Analysis_Option2 =>  p_Analysis_Option2
    ,p_Series_Id        =>  p_Series_Id
    ,p_Budget_Flag      =>  p_Budget_Flag
    ,p_Default_Flag     =>  p_Default_Flag
    ,p_Dataset_Id       =>  p_Dataset_Id
    ,x_return_status    =>  x_return_status
    ,x_msg_count        =>  x_msg_count
    ,x_msg_data         =>  x_msg_data
   );
   IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   FOR cd in c_shared_objs LOOP
     l_Anal_Opt_Rec.Bsc_Kpi_Id := cd.indicator;
     BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Measures(
         p_commit        =>    FND_API.G_FALSE
        ,p_Anal_Opt_Rec  =>    l_Anal_Opt_Rec
        ,x_return_status =>    x_return_status
        ,x_msg_count     =>    x_msg_count
        ,x_msg_data      =>    x_msg_data
     );
     IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --Populate bsc_kpi_series_colors table
     IF p_Color_Values IS NOT NULL THEN
       --Populate bsc_kpi_series_colors table
       Populate_Kpi_Series_Colors (
         p_commit        =>    FND_API.G_FALSE
        ,p_Anal_Opt_Rec  =>    l_Anal_Opt_Rec
        ,p_Color_Values  =>    p_Color_Values
        ,x_return_status =>    x_return_status
        ,x_msg_count     =>    x_msg_count
        ,x_msg_data      =>    x_msg_data
       );
       IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;

     Check_Color_Props(
       p_commit           =>  FND_API.G_FALSE
      ,p_Indicator        =>  cd.indicator
      ,p_Analysis_Option0 =>  p_Analysis_Option0
      ,p_Analysis_Option1 =>  p_Analysis_Option1
      ,p_Analysis_Option2 =>  p_Analysis_Option2
      ,p_Series_Id        =>  p_Series_Id
      ,p_Budget_Flag      =>  p_Budget_Flag
      ,p_Default_Flag     =>  p_Default_Flag
      ,p_Dataset_Id       =>  p_Dataset_Id
      ,x_return_status    =>  x_return_status
      ,x_msg_count        =>  x_msg_count
      ,x_msg_data         =>  x_msg_data
     );
     IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END LOOP;

  Save_Default_Calculation(
    p_commit              =>  FND_API.G_FALSE
   ,p_Indicator           =>  p_Indicator
   ,p_Analysis_Option0    =>  p_Analysis_Option0
   ,p_Analysis_Option1    =>  p_Analysis_Option1
   ,p_Analysis_Option2    =>  p_Analysis_Option2
   ,p_Series_Id           =>  p_Series_Id
   ,p_default_calculation =>  p_default_calculation
   ,x_return_status       =>  x_return_status
   ,x_msg_count           =>  x_msg_count
   ,x_msg_data            =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
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
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Create_Analysis_Measure_UI ';
        ELSE
            x_msg_data      :=  SQLERRM||'BSC_KPI_SERIES_PUB.Create_Analysis_Measure_UI ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Create_Analysis_Measure_UI ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_SERIES_PUB.Create_Analysis_Measure_UI ';
        END IF;
END Create_Analysis_Measure_UI;

/************************************************************************************
--	API name 	: Update_Analysis_Measure_UI
--	Type		: Public
--	Procedure	:
--      1. Updates the properties in bsc_kpi_analysis_measures tables
--         If the user maps the series to a BIS measure then the bis measure import
--         API will be called
--	2. Updates the series color properties
--      3. Also checks for the color enable/disable properties
************************************************************************************/
PROCEDURE Update_Analysis_Measure_UI(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Option0      IN   NUMBER
 ,p_Analysis_Option1      IN   NUMBER
 ,p_Analysis_Option2      IN   NUMBER
 ,p_Series_Id             IN   NUMBER
 ,p_Axis                  IN   NUMBER := 0
 ,p_Series_Type           IN   NUMBER := 0
 ,p_Bm_Flag               IN   NUMBER := 0
 ,p_Budget_Flag           IN   NUMBER := 0
 ,p_Default_Flag          IN   NUMBER := 0
 ,p_Stack_Series_Id       IN   NUMBER := NULL
 ,p_Series_Name           IN   VARCHAR2
 ,p_Series_Help           IN   VARCHAR2
 ,p_dataset_Id            IN   NUMBER := -1
 ,p_Color_Values          IN   FND_TABLE_OF_NUMBER := NULL
 ,p_default_calculation   IN   NUMBER := NULL
 ,p_time_stamp            IN   VARCHAR2 := NULL
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS
  l_Anal_Opt_Rec          BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
  l_Bsc_Kpi_Entity_Rec    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
  l_Count                 NUMBER := 0;
  l_Measure_Source     bsc_sys_datasets_vl.source%TYPE;
  l_DimSet_Id          bsc_kpi_analysis_options_b.dim_set_id%TYPE := 0;
  l_Option_Name        bsc_kpi_analysis_options_vl.name%TYPE;
  l_old_default_kpi    bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE;

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
   x_return_status := FND_API.G_RET_STS_SUCCESS;

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
   (      p_Kpi_Id            =>  p_Indicator
     ,   p_time_stamp         =>  p_time_stamp
     ,   p_Full_Lock_Flag     =>  NULL
     ,   x_return_status      =>  x_return_status
     ,   x_msg_count          =>  x_msg_count
     ,   x_msg_data           =>  x_msg_data
   );
   IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  l_Measure_Source := bsc_Oaf_Views_Pvt.Get_Dataset_Source(x_Dataset_Id => p_DataSet_Id);
  l_old_default_kpi := BSC_COLOR_CALC_UTIL.Get_Default_Kpi_Measure_Id(p_Indicator);

  IF l_Measure_Source = 'PMF' THEN
    SELECT
      dim_set_id
    INTO
      l_DimSet_Id
    FROM
      bsc_db_dataset_dim_sets_v v
    WHERE
      v.indicator = p_indicator AND
      v.A0 = p_Analysis_Option0 AND
      v.A1 = p_Analysis_Option1 AND
      v.A2 = p_Analysis_Option2;

    SELECT
      name
    INTO
      l_Option_Name
    FROM
      bsc_kpi_analysis_options_vl
    WHERE
      indicator = p_Indicator AND
      analysis_group_id = 0 AND
      option_id = p_Analysis_Option0;

    BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options -- This will cascade to the shared
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_kpi_id                =>  p_Indicator
        ,   p_data_source           =>  l_Measure_Source
        ,   p_analysis_group_id     =>  0
        ,   p_analysis_option_id0   =>  p_Analysis_Option0
        ,   p_analysis_option_id1   =>  p_Analysis_Option1
        ,   p_analysis_option_id2   =>  p_Analysis_Option2
        ,   p_series_id             =>  0
        ,   p_data_set_id           =>  p_DataSet_Id
        ,   p_dim_set_id            =>  l_DimSet_Id
        ,   p_option0_Name          =>  l_Option_Name
        ,   p_option1_Name          =>  NULL
        ,   p_option2_Name          =>  NULL
        ,   p_measure_short_name    =>  NULL
        ,   p_dim_obj_short_names   =>  NULL
        ,   p_default_short_names   =>  NULL
        ,   p_view_by_name          =>  NULL
        ,   p_measure_name          =>  p_Series_Name
        ,   p_measure_help          =>  p_Series_Help
        ,   p_default_value         =>  p_Default_Flag
        ,   p_time_stamp            =>  NULL
        ,   p_update_ana_opt        =>  TRUE
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 ELSE
   l_Anal_Opt_Rec.Bsc_Kpi_Id := p_Indicator;
   l_Anal_Opt_Rec.Bsc_Option_Group0 := p_Analysis_Option0;
   l_Anal_Opt_Rec.Bsc_Option_Group1 := p_Analysis_Option1;
   l_Anal_Opt_Rec.Bsc_Option_Group2 := p_Analysis_Option2;
   l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := p_Series_Id;
   l_Anal_Opt_Rec.Bsc_Dataset_Id := p_dataset_Id;
   l_Anal_Opt_Rec.Bsc_Dataset_Axis := p_Axis;
   l_Anal_Opt_Rec.Bsc_Dataset_Series_Type := p_Series_Type;
   l_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag := p_Bm_Flag;
   l_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag := p_Budget_Flag;
   l_Anal_Opt_Rec.Bsc_Dataset_Default_Value := p_Default_Flag;
   l_Anal_Opt_Rec.Bsc_Measure_Long_Name := p_Series_Name;
   l_Anal_Opt_Rec.Bsc_Measure_Help := p_Series_Help;
   l_Anal_Opt_Rec.Bsc_Dataset_Stack_Series_Id  := p_Stack_Series_Id;
   l_Anal_Opt_Rec.Bsc_Change_Action_Flag := FND_API.G_FALSE;

   BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Measures(
       p_commit        =>    FND_API.G_FALSE
      ,p_Anal_Opt_Rec  =>    l_Anal_Opt_Rec
      ,x_return_status =>    x_return_status
      ,x_msg_count     =>    x_msg_count
      ,x_msg_data      =>    x_msg_data
   );
   IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   IF p_Color_Values IS NOT NULL THEN
      --Populate bsc_kpi_series_colors table
      Populate_Kpi_Series_Colors (
        p_commit        =>    FND_API.G_FALSE
       ,p_Anal_Opt_Rec  =>    l_Anal_Opt_Rec
       ,p_Color_Values  =>    p_Color_Values
       ,x_return_status =>    x_return_status
       ,x_msg_count     =>    x_msg_count
       ,x_msg_data      =>    x_msg_data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

    FOR cd in c_shared_objs LOOP
      l_Anal_Opt_Rec.Bsc_Kpi_Id := cd.indicator;
      BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Measures(
          p_commit        =>    FND_API.G_FALSE
         ,p_Anal_Opt_Rec  =>    l_Anal_Opt_Rec
         ,x_return_status =>    x_return_status
         ,x_msg_count     =>    x_msg_count
         ,x_msg_data      =>    x_msg_data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF p_Color_Values IS NOT NULL THEN
         --Populate bsc_kpi_series_colors table
         Populate_Kpi_Series_Colors (
           p_commit        =>    FND_API.G_FALSE
          ,p_Anal_Opt_Rec  =>    l_Anal_Opt_Rec
          ,p_Color_Values  =>    p_Color_Values
          ,x_return_status =>    x_return_status
          ,x_msg_count     =>    x_msg_count
          ,x_msg_data      =>    x_msg_data
         );
         IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
    END LOOP;
  END IF;

  Save_Default_Calculation(
    p_commit              =>  FND_API.G_FALSE
   ,p_Indicator           =>  p_Indicator
   ,p_Analysis_Option0    =>  p_Analysis_Option0
   ,p_Analysis_Option1    =>  p_Analysis_Option1
   ,p_Analysis_Option2    =>  p_Analysis_Option2
   ,p_Series_Id           =>  p_Series_Id
   ,p_default_calculation =>  p_default_calculation
   ,x_return_status       =>  x_return_status
   ,x_msg_count           =>  x_msg_count
   ,x_msg_data            =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- This API should be called for both BIS and non-BIS type measures
  Check_Color_Props(
    p_commit           =>  FND_API.G_FALSE
   ,p_Indicator        =>  p_Indicator
   ,p_Analysis_Option0 =>  p_Analysis_Option0
   ,p_Analysis_Option1 =>  p_Analysis_Option1
   ,p_Analysis_Option2 =>  p_Analysis_Option2
   ,p_Series_Id        =>  p_Series_Id
   ,p_Budget_Flag      =>  p_Budget_Flag
   ,p_Default_Flag     =>  p_Default_Flag
   ,p_Dataset_Id       =>  p_Dataset_Id
   ,x_return_status    =>  x_return_status
   ,x_msg_count        =>  x_msg_count
   ,x_msg_data         =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FOR cd in c_shared_objs LOOP
    Check_Color_Props(
       p_commit           =>  FND_API.G_FALSE
      ,p_Indicator        =>  cd.indicator
      ,p_Analysis_Option0 =>  p_Analysis_Option0
      ,p_Analysis_Option1 =>  p_Analysis_Option1
      ,p_Analysis_Option2 =>  p_Analysis_Option2
      ,p_Series_Id        =>  p_Series_Id
      ,p_Budget_Flag      =>  p_Budget_Flag
      ,p_Default_Flag     =>  p_Default_Flag
      ,p_Dataset_Id       =>  p_Dataset_Id
      ,x_return_status    =>  x_return_status
      ,x_msg_count        =>  x_msg_count
      ,x_msg_data         =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
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
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Update_Analysis_Measure_UI ';
        ELSE
            x_msg_data      :=  SQLERRM||'BSC_KPI_SERIES_PUB.Update_Analysis_Measure_UI ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Update_Analysis_Measure_UI ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_SERIES_PUB.Update_Analysis_Measure_UI ';
        END IF;
END Update_Analysis_Measure_UI;

/************************************************************************************
--	API name 	: Delete_Analysis_Measure_UI
--	Type		: Public
--	Procedure	:
--      1. Deltes the entries from  bsc_kpi_analysis_measures tables
--	2. Deletes the series color properties
************************************************************************************/
PROCEDURE Delete_Analysis_Measure_UI(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Option0      IN   NUMBER
 ,p_Analysis_Option1      IN   NUMBER
 ,p_Analysis_Option2      IN   NUMBER
 ,p_Series_Id             IN   NUMBER
 ,p_time_stamp            IN   VARCHAR2 := NULL
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS
  l_Anal_Opt_Rec          BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
  l_Bsc_Kpi_Entity_Rec    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
  l_Count                 NUMBER := 0;
  l_old_default_kpi       bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE;
  l_kpi_measure_id        bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE;
  l_Reset_Default         BOOLEAN := FALSE;

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
   x_return_status := FND_API.G_RET_STS_SUCCESS;

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
   (      p_Kpi_Id            =>  p_Indicator
     ,   p_time_stamp         =>  p_time_stamp
     ,   p_Full_Lock_Flag     =>  NULL
     ,   x_return_status      =>  x_return_status
     ,   x_msg_count          =>  x_msg_count
     ,   x_msg_data           =>  x_msg_data
   );
   IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   SELECT
     kpi_measure_id
   INTO
     l_kpi_measure_id
   FROM
     bsc_kpi_analysis_measures_b
   WHERE
     indicator = p_Indicator AND
     analysis_option0 = p_Analysis_Option0 AND
     analysis_option1 = p_Analysis_Option1 AND
     analysis_option2 = p_Analysis_Option2 AND
     series_id        = p_Series_Id;


   l_Anal_Opt_Rec.Bsc_Kpi_Id := p_Indicator;
   l_Anal_Opt_Rec.Bsc_Option_Group0 := p_Analysis_Option0;
   l_Anal_Opt_Rec.Bsc_Option_Group1 := p_Analysis_Option1;
   l_Anal_Opt_Rec.Bsc_Option_Group2 := p_Analysis_Option2;
   l_Anal_Opt_Rec.Bsc_Dataset_Series_Id := p_Series_Id;

   IF l_kpi_measure_id = BSC_COLOR_CALC_UTIL.Get_Default_Kpi_Measure_Id(p_Indicator) THEN
     l_Reset_Default := TRUE;
   END IF;

   BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Measures(
       p_commit        =>    FND_API.G_FALSE
      ,p_Anal_Opt_Rec  =>    l_Anal_Opt_Rec
      ,x_return_status =>    x_return_status
      ,x_msg_count     =>    x_msg_count
      ,x_msg_data      =>    x_msg_data
   );
   IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Delete_Kpi_Series_Colors(
       p_commit        =>    FND_API.G_FALSE
      ,p_Anal_Opt_Rec  =>    l_Anal_Opt_Rec
      ,x_return_status =>    x_return_status
      ,x_msg_count     =>    x_msg_count
      ,x_msg_data      =>    x_msg_data
   );
   IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF l_Reset_Default THEN
     Check_Series_Default_Props (
        p_commit        =>    FND_API.G_FALSE
       ,p_Indicator     =>    p_Indicator
       ,x_return_status =>    x_return_status
       ,x_msg_count     =>    x_msg_count
       ,x_msg_data      =>    x_msg_data
     );
     IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;

  FOR cd in c_shared_objs LOOP
    l_Anal_Opt_Rec.Bsc_Kpi_Id := cd.indicator;
    BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Measures(
        p_commit        =>    FND_API.G_FALSE
       ,p_Anal_Opt_Rec  =>    l_Anal_Opt_Rec
       ,x_return_status =>    x_return_status
       ,x_msg_count     =>    x_msg_count
       ,x_msg_data      =>    x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    Delete_Kpi_Series_Colors(
        p_commit        =>    FND_API.G_FALSE
       ,p_Anal_Opt_Rec  =>    l_Anal_Opt_Rec
       ,x_return_status =>    x_return_status
       ,x_msg_count     =>    x_msg_count
       ,x_msg_data      =>    x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

     IF l_Reset_Default THEN
       Check_Series_Default_Props (
          p_commit        =>    FND_API.G_FALSE
         ,p_Indicator     =>    cd.Indicator
         ,x_return_status =>    x_return_status
         ,x_msg_count     =>    x_msg_count
         ,x_msg_data      =>    x_msg_data
       );
       IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     END IF;

  END LOOP;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
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
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Delete_Analysis_Measure_UI ';
        ELSE
            x_msg_data      :=  SQLERRM||'BSC_KPI_SERIES_PUB.Delete_Analysis_Measure_UI ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Delete_Analysis_Measure_UI ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_SERIES_PUB.Delete_Analysis_Measure_UI ';
        END IF;
END Delete_Analysis_Measure_UI;

/************************************************************************************
--	API name 	: Populate_Kpi_Series_Colors
--	Type		: Private
--      Function:
--      Deletes the old entries from bsc_kpi_series_colors and creates new entries using
--      p_Color_Values
************************************************************************************/

PROCEDURE Populate_Kpi_Series_Colors(
  p_commit          IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Anal_Opt_Rec    IN   BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,p_Color_Values    IN   FND_TABLE_OF_NUMBER
 ,x_return_status   OUT NOCOPY   VARCHAR2
 ,x_msg_count       OUT NOCOPY   NUMBER
 ,x_msg_data        OUT NOCOPY   VARCHAR2
) IS
  i                NUMBER;
  l_bm_id  bsc_kpi_series_colors.bm_id%TYPE;
  l_bm_color  bsc_kpi_series_colors.color%TYPE;
BEGIN

  SAVEPOINT Pop_Kpi_Series_PUB;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM bsc_kpi_series_colors
  WHERE indicator   =  p_Anal_Opt_Rec.Bsc_Kpi_Id AND
  analysis_option0  =  p_Anal_Opt_Rec.Bsc_Option_Group0 AND
  analysis_option1  =  p_Anal_Opt_Rec.Bsc_Option_Group1 AND
  analysis_option2  =  p_Anal_Opt_Rec.Bsc_Option_Group2 AND
  series_id =  p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;
  i := 1;
  WHILE (i <p_Color_Values.COUNT) LOOP
     l_bm_id := p_Color_Values(i);
     l_bm_color := p_Color_Values(i + 1);

     INSERT INTO bsc_kpi_series_colors (indicator
                                       ,analysis_option0
                                       ,analysis_option1
                                       ,analysis_option2
                                       ,series_id
                                       ,bm_id
                                       ,color
                                      )
                                VALUES( p_Anal_Opt_Rec.Bsc_Kpi_Id
                                       ,p_Anal_Opt_Rec.Bsc_Option_Group0
                                       ,p_Anal_Opt_Rec.Bsc_Option_Group1
                                       ,p_Anal_Opt_Rec.Bsc_Option_Group2
                                       ,p_Anal_Opt_Rec.Bsc_Dataset_Series_Id
                                       ,l_bm_id
                                       ,l_bm_color
                                       );
     i := i + 2;
  END LOOP;


  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Pop_Kpi_Series_PUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Pop_Kpi_Series_PUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO Pop_Kpi_Series_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Populate_Kpi_Series_Colors ';
        ELSE
            x_msg_data      :=  SQLERRM||'BSC_KPI_SERIES_PUB.Populate_Kpi_Series_Colors ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO Pop_Kpi_Series_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Populate_Kpi_Series_Colors ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_SERIES_PUB.Populate_Kpi_Series_Colors ';
        END IF;
END Populate_Kpi_Series_Colors;

/************************************************************************************
--	API name 	: Delete_Kpi_Series_Colors
--	Type		: Private
--      Function:
--      Deletes the entries from bsc_kpi_series_colors
************************************************************************************/

PROCEDURE Delete_Kpi_Series_Colors(
  p_commit          IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Anal_Opt_Rec    IN   BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
 ,x_return_status   OUT NOCOPY   VARCHAR2
 ,x_msg_count       OUT NOCOPY   NUMBER
 ,x_msg_data        OUT NOCOPY   VARCHAR2
) IS
BEGIN

  SAVEPOINT Delete_Kpi_SeriesColor_PUB;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM bsc_kpi_series_colors
  WHERE indicator   =  p_Anal_Opt_Rec.Bsc_Kpi_Id AND
  analysis_option0  =  p_Anal_Opt_Rec.Bsc_Option_Group0 AND
  analysis_option1  =  p_Anal_Opt_Rec.Bsc_Option_Group1 AND
  analysis_option2  =  p_Anal_Opt_Rec.Bsc_Option_Group2 AND
  series_id =  p_Anal_Opt_Rec.Bsc_Dataset_Series_Id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Delete_Kpi_SeriesColor_PUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Delete_Kpi_SeriesColor_PUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO Delete_Kpi_SeriesColor_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Delete_Kpi_Series_Colors ';
        ELSE
            x_msg_data      :=  SQLERRM||'BSC_KPI_SERIES_PUB.Delete_Kpi_Series_Colors ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO Delete_Kpi_SeriesColor_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Delete_Kpi_Series_Colors ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_SERIES_PUB.Delete_Kpi_Series_Colors ';
        END IF;

END Delete_Kpi_Series_Colors;

/************************************************************************************
--	API name 	: Check_DimSet_DataSet_Exists
--	Type		: Private
--	Function	: This is a helper API used in determining strucutural changes
************************************************************************************/

FUNCTION Check_DimSet_DataSet_Exists(
  p_newdim_Dataset_map    IN  Bsc_Dim_DataSet_Table
 ,p_dim_set_id            IN  NUMBER
 ,p_dataset_id            IN  NUMBER
) RETURN NUMBER IS

 l_Count NUMBER := 0;
 l_newdim_Dataset_map    Bsc_Dim_DataSet_Table;
 i NUMBER;
BEGIN

  FOR i IN p_newdim_Dataset_map.FIRST..p_newdim_Dataset_map.LAST LOOP
    IF (p_newdim_Dataset_map.EXISTS(i) AND p_newdim_Dataset_map(i).dim_set_id = p_dim_set_id
      AND p_newdim_Dataset_map(i).dataset_id = p_dataset_id) THEN
      RETURN p_newdim_Dataset_map(i).rec_count;
    END IF;
  END LOOP;

  RETURN l_Count;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END Check_DimSet_DataSet_Exists;

/************************************************************************************
--	API name 	: Check_Structure_Change
--	Type		: Public
--	Function	: This API will check for  structural changes
--      Parameters      :
--
--      p_Analysis_Option0,p_Analysis_Option1,p_Analysis_Option2 is the current
--                           analysis option combination
--      p_Series_Id       -  series_id if called from Update Series and as -1 if called
--                           define series
--      p_New_Dataset_Map -  The new dataset set ids mapped for the current analysis
--                           option combination
--      p_Delete_Mode     -  Set to 1 when a series is deleted from the HGridw
************************************************************************************/

PROCEDURE Check_Series_Structure_Change (
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_Indicator             IN   NUMBER
 ,p_Analysis_Option0      IN   NUMBER
 ,p_Analysis_Option1      IN   NUMBER
 ,p_Analysis_Option2      IN   NUMBER
 ,p_Series_Id             IN   NUMBER
 ,p_New_Dataset_Map       IN   FND_TABLE_OF_NUMBER
 ,p_Delete_Mode           IN   NUMBER := 0
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS

  l_Structure_Change  BOOLEAN := FALSE;
  l_Count           NUMBER := 0;

  l_All_Comb_Map_Old Bsc_Dim_Dataset_Table;
  l_All_Comb_Map_New Bsc_Dim_Dataset_Table;
  l_AO_Comb_Map  Bsc_Dim_Dataset_Table;

  l_Series_DataSet_Id bsc_kpi_analysis_measures_b.dataset_id%TYPE;
  l_Series_DimSet_Id bsc_kpi_analysis_options_b.dim_set_id%TYPE;
  l_Combination_Cnt NUMBER;
  l_Found BOOLEAN;
  i NUMBER;
  j NUMBER;

  l_Current_DimSet bsc_kpi_analysis_options_b.dim_set_id%TYPE;

  CURSOR c_dimset_dataset_map  IS
  SELECT
    db.dim_set_id, db.dataset_id, count(1)
  FROM
    bsc_db_dataset_dim_sets_v db,
    bsc_sys_datasets_vl ds
  WHERE
    ds.source = 'BSC' AND
    db.indicator =  p_indicator AND db.dataset_id = ds.dataset_id
  GROUP BY db.dim_set_id, db.dataset_id
  ORDER by db.dim_set_id, db.dataset_id;

  CURSOR c_AO_Comb  IS
  SELECT
    db.dim_set_id, db.dataset_id, count(1)
  FROM
    bsc_db_dataset_dim_sets_v db,
    bsc_sys_datasets_vl ds
  WHERE
    ds.source = 'BSC' AND
    db.indicator =  p_indicator AND
    db.dataset_id = ds.dataset_id AND
    db.A0 = p_Analysis_Option0 AND
    db.A1 = p_Analysis_Option1 AND
    db.A2 = p_Analysis_Option2
  GROUP BY db.dim_set_id, db.dataset_id
  ORDER BY db.dim_set_id, db.dataset_id;

  CURSOR c_AO_Comb_Series  IS
  SELECT
    db.dim_set_id, db.dataset_id
  FROM
    bsc_db_dataset_dim_sets_v db,
    bsc_sys_datasets_vl ds
  WHERE
    ds.source = 'BSC' AND
    db.indicator =  p_indicator AND
    db.dataset_id = ds.dataset_id AND
    db.A0 = p_Analysis_Option0 AND
    db.A1 = p_Analysis_Option1 AND
    db.A2 = p_Analysis_Option2 AND
    db.series_id = p_Series_Id
  ORDER BY db.dim_set_id, db.dataset_id;

  CURSOR c_Dim_Set IS
  SELECT DISTINCT
    dim_set_id
  FROM
    bsc_db_dataset_dim_sets_v
  WHERE
    indicator = p_Indicator AND
    A0 = p_Analysis_Option0 AND
    A1 = p_Analysis_Option1 AND
    A2 = p_Analysis_Option2;


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

  FND_MSG_PUB.Initialize;

  OPEN c_Dim_Set;
  FETCH c_Dim_Set INTO  l_Current_DimSet;
  CLOSE c_Dim_Set;

  OPEN c_dimset_dataset_map;
  FETCH c_dimset_dataset_map BULK COLLECT INTO l_All_Comb_Map_Old;
  CLOSE c_dimset_dataset_map;

  OPEN c_dimset_dataset_map;
  FETCH c_dimset_dataset_map BULK COLLECT INTO l_All_Comb_Map_New;
  CLOSE c_dimset_dataset_map;


  IF p_Series_Id IS NULL THEN
    OPEN c_AO_Comb;
    FETCH c_AO_Comb  BULK COLLECT INTO l_AO_Comb_Map;
    CLOSE c_AO_Comb;

    FOR i in 1..l_AO_Comb_Map.COUNT LOOP
     l_Combination_Cnt := Check_DimSet_DataSet_Exists (
                        l_All_Comb_Map_New,
                        l_AO_Comb_Map(i).Dim_Set_Id,
                        l_AO_Comb_Map(i).DataSet_Id
                      );
      IF l_Combination_Cnt = 1 THEN

        FOR j IN l_All_Comb_Map_New.FIRST..l_All_Comb_Map_New.LAST LOOP
          IF (l_All_Comb_Map_New.EXISTS(j) AND
              l_All_Comb_Map_New(j).dim_set_id =  l_AO_Comb_Map(i).Dim_Set_Id AND
              l_All_Comb_Map_New(j).dataset_id = l_AO_Comb_Map(i).DataSet_Id) THEN
            l_All_Comb_Map_New.DELETE(j);
            EXIT;
          END IF;
        END LOOP;

      END IF;
    END LOOP;
  ELSE
    OPEN c_AO_Comb_Series;
    FETCH c_AO_Comb_Series INTO l_Series_DimSet_Id,l_Series_DataSet_Id;
    CLOSE c_AO_Comb_Series;
    l_Combination_Cnt := Check_DimSet_DataSet_Exists (
                      l_All_Comb_Map_New,
                      l_Series_DimSet_Id,
                      l_Series_DataSet_Id
                    );
    IF l_Combination_Cnt = 1 THEN
      FOR j in 1..l_All_Comb_Map_New.COUNT LOOP
        IF (l_All_Comb_Map_New(j).dim_set_id =  l_Series_DimSet_Id AND
            l_All_Comb_Map_New(j).dataset_id = l_Series_DataSet_Id) THEN

          l_All_Comb_Map_New.DELETE(j);


          EXIT;
        END IF;
      END LOOP;
    END IF;
  END IF;



  IF p_Delete_Mode = 0 THEN
    FOR i in 1..p_new_dataset_map.COUNT LOOP
      l_Combination_Cnt := Check_DimSet_DataSet_Exists (
                        l_All_Comb_Map_New,
                        l_Current_DimSet,
                        p_new_dataset_map(i)
                      );
      IF l_Combination_Cnt = 0 THEN
        l_All_Comb_Map_New.EXTEND;
        j := l_All_Comb_Map_New.LAST;
        l_All_Comb_Map_New(j).dataset_id := p_new_dataset_map(i);
        l_All_Comb_Map_New(j).dim_set_id := l_Current_DimSet;
        l_All_Comb_Map_New(j).rec_count := 1;
      END IF;
    END LOOP;
  END IF;


  FOR i IN l_All_Comb_Map_New.FIRST..l_All_Comb_Map_New.LAST LOOP
    l_Found := FALSE;
    IF l_All_Comb_Map_New.EXISTS(i) THEN

      FOR j IN l_All_Comb_Map_Old.FIRST..l_All_Comb_Map_Old.LAST LOOP
        IF (l_All_Comb_Map_New(i).dim_set_id = l_All_Comb_Map_Old(j).dim_set_id AND
            l_All_Comb_Map_New(i).dataset_id = l_All_Comb_Map_Old(j).dataset_id) THEN
          l_Found := TRUE;
        END IF;
      END LOOP;

      IF l_Found = FALSE AND l_All_Comb_Map_New(i).dim_set_id IS NOT NULL
         AND l_All_Comb_Map_New(i).dataset_id IS NOT NULL THEN
        l_Structure_Change := TRUE;
        EXIT;
      END IF;
    END IF;
  END LOOP;



  IF NOT l_Structure_Change THEN
    FOR i IN l_All_Comb_Map_Old.FIRST..l_All_Comb_Map_Old.LAST LOOP
      l_Found := FALSE;
      FOR j IN l_All_Comb_Map_New.FIRST..l_All_Comb_Map_New.LAST LOOP
        IF (l_All_Comb_Map_New.EXISTS(j) AND
            l_All_Comb_Map_Old(i).dim_set_id = l_All_Comb_Map_New(j).dim_set_id AND
            l_All_Comb_Map_Old(i).dataset_id = l_All_Comb_Map_New(j).dataset_id) THEN
          l_Found := TRUE;
        END IF;
      END LOOP;

      IF l_Found = FALSE AND l_All_Comb_Map_Old(i).dim_set_id IS NOT NULL
         AND l_All_Comb_Map_Old(i).dataset_id IS NOT NULL THEN
        l_Structure_Change := TRUE;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  IF l_Structure_Change THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_PMD_KPI_STRUCT_INVALID');
    FND_MESSAGE.SET_TOKEN('INDICATORS', BSC_BIS_LOCKS_PVT.Get_Kpi_Name(p_Indicator));
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
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
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Check_Series_Structure_Change ';
        ELSE
            x_msg_data      :=  SQLERRM||'BSC_KPI_SERIES_PUB.Check_Series_Structure_Change ';
        END IF;
END Check_Series_Structure_Change;

/************************************************************************************
--	API name 	: Update_Kpi_Time_Stamp
--	Type		: Public
************************************************************************************/

PROCEDURE Update_Kpi_Time_Stamp(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Indicator           IN      NUMBER
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) IS

  l_Bsc_Kpi_Entity_Rec    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

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

   SAVEPOINT ObjKpiTimeStampPUB;

   l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_Indicator;
   BSC_KPI_PUB.Update_Kpi_Time_Stamp(
     p_commit             =>  FND_API.G_FALSE
    ,p_Bsc_Kpi_Entity_Rec =>  l_Bsc_Kpi_Entity_Rec
    ,x_return_status      =>  x_return_status
    ,x_msg_count          =>  x_msg_count
    ,x_msg_data           =>  x_msg_data
   );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
    BSC_DESIGNER_PVT.Deflt_Update_AOPTS ( x_indicator => l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);

   FOR cd in c_shared_objs LOOP
     l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := cd.indicator;
     BSC_KPI_PUB.Update_Kpi_Time_Stamp(
       p_commit             =>  FND_API.G_FALSE
      ,p_Bsc_Kpi_Entity_Rec =>  l_Bsc_Kpi_Entity_Rec
      ,x_return_status      =>  x_return_status
      ,x_msg_count          =>  x_msg_count
      ,x_msg_data           =>  x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     BSC_DESIGNER_PVT.Deflt_Update_AOPTS ( x_indicator => cd.indicator );
  END LOOP;

   IF fnd_api.to_boolean(p_commit) THEN
     COMMIT;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO ObjKpiTimeStampPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        ROLLBACK TO ObjKpiTimeStampPUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Update_Kpi_Time_Stamp ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_KPI_SERIES_PUB.Update_Kpi_Time_Stamp ';
        END IF;
END Update_Kpi_Time_Stamp;

END BSC_KPI_SERIES_PUB;

/
