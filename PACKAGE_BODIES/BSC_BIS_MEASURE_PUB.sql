--------------------------------------------------------
--  DDL for Package Body BSC_BIS_MEASURE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_MEASURE_PUB" AS
  /* $Header: BSCPBMSB.pls 120.15 2007/06/08 08:59:32 akoduri ship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BSCPBMSB.pls
---
---  DESCRIPTION
---     Package Body File for Measure transactions
---
---  NOTES
---
---  HISTORY
---
---  23-Apr-2003 mdamle     Created
---  14-JUN-2003 adrao      Added Granular Locking for measures.
---  07-JUL-2003 mdamle     Added Indicator Dimensions
---  24-JUL-2003 mdamle     Bug#3064436 - Fix in create measure when user selects
---                     existing datasource
---  01-Aug-2003 mdamle     Bug#3055812 - Trim display and internal name
---  18-Aug-2003 mdamle     Bug#3096594 - Added check for same cause and effect measure
---  21-Aug-2003 adrao      Modfied Delete_Measure to make Multiuser delete
---                         generic
--   21-AUG-2003 mahrao     Fix for granular locking to come up while upload of ldt
--   25-AUG-2003 mahrao     Added procedure Ret_Dataset_Fr_Meas_Shrt_Name and
--                          Order_Dimensions_For_Ldt
--   01-SEP-2003 PAJOHRI    Bug #3122612
--                          Updated the API so that whenever any measure is created/updated
--                          BSC_SYS_MEASURES.Type must be 0, for BSC type of measures
--   03-Sep-03   mdamle     Fixed Bug #3123734, 3123558 - Get measure col, isFormula
--   07-Sep-03   arhegde    bug# 3123901 Propogate error to outer layers.
--   11-Sep-03   mdamle     BSC_SYS_MEASURES.Type is different from BSC_DB_MEASURE_COLS.MEASURE_TYPE
--   26-Sep-03   adrao      Removed the logic to generate Duplicate Display Name for Measured
--                          for Bug #3163366
--   01-Oct-03   mdamle     Bug#3163261 - Don't remove beginning numbers from source column name
--   07-Oct-03   mdamle     Bug#3170184 - For BSC type measure, always use short name in PMF display name
--   21-Oct-03   PAJOHRI    Bug #3184408, added two procedures get_Next_Alias and get_Measure_Name
--                                        to get the new diplay name for BIS and BSC.
--   21-Oct-03   Adeulgao   fixed Bug#3237284, modified update_measure API
--   21-Nov-03   adrao      fixed Bug#3255382
--   27-Nov-03   adrao      fixed Modifed Update_Measure to move the FETCH CURSOR out the
--                          IF condition to check for %FOUND for cursor - Bug#3284277
--   28-NOV-03   adrao      Bug#3238554  - Modifed procedure Update_Measure and added
--                          condition to perform incremental changes. Also modified Get_Incr_Trigger
--                          to return a warning message, when Measure type is changed.
--   03-DEC-03   adrao      Bug#3292146 - Fixed Create_Measure, to handle Measure_id = -1, when
--                          default Datasource Values are selected.
--   04-DEC-03   adrao      Bug#3296451 - Fixed API Get_Incr_Trigger to return null when
--                          exception is raised.
--   06-JAN-04   PAJOHRI    Bug #3349897, modified procedure Update_Measure to get the previous
--                                        value of s_Color_Formula and function getColorFormula
--                                        to use s_Color_Formula original value.
--   24-FEB-04    KYADAMAK    Bug #3439942  space not allowed for PMF Measures
--   24-MAR-04   adrao      Bug#3528425 - passed Bsc_Measure_Group_Id to lower APIs
--   25-APR-04   arhegde    bug# 3546722 - removed NVL in update_measure call from load_measure API
--   08-APR-04   ankgoel    Modified for bug#3557236
--   13-APR-04   ppandey    Bug# 3530050- Dynamically generating unique measure col if not unique
--   11-MAY-04   kyadamak   Bug# 3616756 - Changed query to get KPIs affected while changing the color method
--   13-MAY-04   adrao      Added Exception after BIS_MEASURE_PUB.Create_Measure in Create_Measure API
--   24-MAY-04   adrao      Delete unwanted Measure Columns based on BSC_SYS_DATASETS_VL.MEASURE_ID2
--                          for Bug#3628113
--   25-MAY-04   PAJOHRI    Bug #3642186
--   05-JUL-04   ankgoel    Bug#3700439 Made changed for rollback issues
--   28-JUL-04   adrao      Bug#3798834 Made Aggr. Method change to render a Color warning
--                          instead of Structural changes warning
--   28-JUL-04   sawu       Modified create/update/translate api to populate WHO column info and p_owner
--   29-JUL-04   adrao      Bug#3781176 - removed dangling source columns, whenever a measure
--                          is updated with an alternative source column (datasource)
--   09-AUG-04   ashankar   Bug#3809014 Made chnages in Create_Measure,Update_Measure and get_Measure_Name
--                          procedures.
--   09-AUG-04   sawu       Added create_measure wrapper to handle default internal name
--   24-AUH-04   ashankar   Bug#3844190 While deleting the measure added source =BSC.
--   26-AUG-04   ankgoel    Bug#3856618 Error message picked from FND stack only if NULL
--   26-AUG-04   sawu       Bug#3813603: added Is_Unique_Measure_Display_Name()
--   30-AUG-04   ankgoel    Modified Order_Dimensions_For_Ldt for bug#3846068
--   01-SEP-04   sawu       Bug#3859267: added region, source/compare column app
--                          id to create/update api
--   06-SEP-04   kyadamak   modified get_measure_col()for bug#  3852463
--   23-SEP-04   adrao      modified gen_name_for_column() bug#3894955
--   18-OCT-04   adrao      Modified Create_Measure, Update_Measure signatures by added
--                          p_measure_col_help to the APIs for POSCO Bug#3817894
--   17-Nov-04   sawu       Bug#4015015: added api Is_Numeric_Column api
--   17-Dec-04   sawu       Bug#4045287: added Upload_Test, added p_custom_mode
--                          to Load_Measure() and Translate_Measure(). Overloaded
--                          Create_Measure() and Update_Measure().
--   27-Dec-04   rpenneru   Bug#4080204: added Func_Area_Short_name field to create_measure()
--                          and update_measure() methods
--   03-Feb-05   krishna    Bug#4080716 Modified get_measure_col_API compatiable to 8i
--   09-FEB-04 skchoudh    Enh#4141738 Added Functiona Area Combobox to MD
--   10-Feb-05  sawu        Bug#4157795: modified gen_name_for_column to trim leading underscore
--   21-Feb-05   rpenneru Enh#4059160, Add FA as property to Custom KPIs|
--   21-FEB-05  ankagarw    changed dataset name and description column length for enh.#3862703
--   05/22/05   akoduri    Enhancement#3865711 -- Obsolete Seeded Objects  --
--   03-MAY-05  akoduri  Enh #4268374 -- Weighted Average Measures        --
--   23-May-05   visuri   Bug#3994115 Added Get_Meas_With_Src_Col() and Get_Sing_Par_Meas_DS()
--   17-JUL-05   sawu     Bug#4482736: Added Get_Primary_Data_Source
--   20-Sep-05   akoduri  Bug#4613172: CDS type measures should not get populated into
--                                       bsc_db_measure_cols_tl
--   22-Sep-05   ashankar Bug#4605142:Modified the API Get_Incr_Truigger
--   21-oct-05   ashankar Bug#4630974 Modified the API Get_Incr_Trigger
--                        by moving the check for structural modifications
--                        before color changes
--   17-Nov-05   adrao    added API Is_Formula_Type() Bug#4617140
--   05-JAN-06   ppandey  Enh#4860106 - Handled structureal/non-structural formula change
--   12-JAN-06   ppandey      Bug #4938364 - Color Warning for BIS Measure (AG)
--   29-MAR-06   adrao    Bug#5071121 - added additional conditions when converting a report
--                        from single source to formula type in Update_Measure();
--    04-AUG-06    akoduri Enh#5416542 Cause  Effect Phase2
--    14-Feb-07    rkumar  Bug#5877454  increased the variable lengths to
--                         support larger kpi names
--    06-JUN-2007 akoduri Bug 5958688 Enable YTD as default at KPI
 ---===========================================================================

/*
***************************************************
  function remove_percent()
***************************************************
*/

function remove_percent(
  p_input in varchar2
) return number;

FUNCTION  gen_name_for_column(
    p_name          IN VARCHAR2
)RETURN VARCHAR2;

FUNCTION is_Valid_AlphaNum
(
    p_name IN VARCHAR2
) RETURN BOOLEAN;

FUNCTION getMeasureAutoGenKpis (
      p_dataset_id IN NUMBER
) RETURN VARCHAR2;


/******************* PAJOHRI ADDED Bug #3184408*************************/
FUNCTION get_Next_Alias
(
  p_Alias        IN   VARCHAR2
) RETURN VARCHAR2
IS
  l_alias     VARCHAR2(3);
  l_return    VARCHAR2(3);
  l_count     NUMBER;
BEGIN
  IF (p_Alias IS NULL) THEN
    l_return :=  'A';
  ELSE
    l_count := LENGTH(p_Alias);
    IF (l_count = 1) THEN
      l_return   := 'A0';
    ELSIF (l_count > 1) THEN
      l_alias     :=  SUBSTR(p_Alias, 2);
      l_count     :=  TO_NUMBER(l_alias)+1;
      l_return    :=  'A'||TO_CHAR(l_count);
    END IF;
  END IF;
  RETURN l_return;

END get_Next_Alias;

/************************************************************************/
FUNCTION Validate_Conditions
(    p_Bsc_source                     IN         VARCHAR2    -- BSC or PMF
  ,  p_Pmf_Old_source                 IN         VARCHAR2    -- OLTP, EDW (NULL means OLTP)
  ,  p_Bsc_Old_Source                 IN         VARCHAR2    -- BSC or PMF
) RETURN BOOLEAN IS
BEGIN
    IF ((p_Bsc_source = p_Bsc_Old_Source) AND (p_Bsc_source = c_PMF)) THEN
        IF (NVL(p_Pmf_Old_source, 'OLTP') = 'OLTP') THEN -- from PMD only OLTP types are created
            --raise exception
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
    ELSIF (p_Bsc_source = p_Bsc_Old_Source) THEN
        --raise exception
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END Validate_Conditions;
/************************************************************************/
PROCEDURE get_Measure_Name
(     p_dataset_id         IN         NUMBER      -- if NULL it means Create otherwise update
  ,   p_ui_flag            IN         VARCHAR2
  ,   p_dataset_source     IN         VARCHAR2    -- BSC or PMF
  ,   p_dataset_name       IN         VARCHAR2    -- passed measure name
  ,   x_measure_name       OUT NOCOPY VARCHAR2    -- trimmed output measure name
) IS
    l_Flag     BOOLEAN;
    l_Count    NUMBER;


    CURSOR c_Create_Measure IS
    SELECT DISTINCT BSC_MEAS.Source      Bsc_Source
        ,  BSC_DSET.Name                 Bsc_Name
        ,  BIS_TAR.Source                Bis_Source
        ,  BIS_IND.Indicator_Id          Bis_Ind_Id
        ,  BIS_IND.Actual_Data_Source    Bis_Act_Source
    FROM   BIS_INDICATORS                BIS_IND
        ,  BSC_SYS_MEASURES              BSC_MEAS
        ,  BSC_SYS_DATASETS_VL           BSC_DSET
        ,  BIS_TARGET_LEVELS             BIS_TAR
    WHERE  UPPER(TRIM(BSC_DSET.Name)) =  UPPER(x_measure_name)
    AND    BIS_IND.Indicator_Id       =  BIS_TAR.Indicator_Id(+)
    AND    BIS_IND.Short_Name         =  BSC_MEAS.Short_Name
    AND    BSC_MEAS.Measure_Id        =  BSC_DSET.Measure_Id1;

    CURSOR c_Update_Measure IS
    SELECT DISTINCT BSC_MEAS.Source      Bsc_Source
        ,  BSC_DSET.Name                 Bsc_Name
        ,  BIS_TAR.Source                Bis_Source
        ,  BIS_IND.Indicator_Id          Bis_Ind_Id
        ,  BIS_IND.Actual_Data_Source    Bis_Act_Source
    FROM   BIS_INDICATORS                BIS_IND
        ,  BSC_SYS_MEASURES              BSC_MEAS
        ,  BSC_SYS_DATASETS_VL           BSC_DSET
        ,  BIS_TARGET_LEVELS             BIS_TAR
    WHERE  UPPER(TRIM(BSC_DSET.Name)) =  UPPER(x_measure_name)
    AND    BIS_IND.Indicator_Id       =  BIS_TAR.Indicator_Id(+)
    AND    BIS_IND.Short_Name         =  BSC_MEAS.Short_Name
    AND    BSC_MEAS.Measure_Id        =  BSC_DSET.Measure_Id1
    AND    BSC_DSET.Dataset_Id       <>  p_dataset_id;

  BEGIN
--    x_measure_name  := TRIM(p_dataset_name);
    l_Flag          := FALSE;

     IF (p_dataset_id IS NULL) THEN -- called from update API
            IF(p_ui_flag = 'Y') THEN
              x_measure_name  := TRIM(p_dataset_name);
            ELSE
              x_measure_name := p_dataset_name;
            END IF;

            IF(p_dataset_source = c_BSC) THEN

               SELECT COUNT(0)
               INTO l_Count
               FROM BSC_SYS_DATASETS_VL
               WHERE UPPER(TRIM(Name)) =UPPER(x_measure_name)
               AND   Source = c_BSC;

               IF(l_Count>0) THEN
                   FND_MESSAGE.SET_NAME('BIS','BIS_MEASURE_NAME_UNIQUE');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;
            ELSE
                FOR cd IN c_Create_Measure LOOP
                     l_Flag  :=  BSC_BIS_MEASURE_PUB.Validate_Conditions
                                 (     p_Bsc_source      =>  p_dataset_source
                                   ,   p_Pmf_Old_source  =>  cd.Bis_Source
                                   ,   p_Bsc_Old_Source  =>  cd.Bsc_Source
                                 );
                    IF (NOT l_Flag) THEN
                        FND_MESSAGE.SET_NAME('BIS','BIS_MEASURE_NAME_UNIQUE');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END LOOP;
             END IF;
        ELSE -- called from create API
            x_measure_name  := TRIM(p_dataset_name);
            IF(p_dataset_source = c_BSC) THEN

               SELECT COUNT(0)
               INTO l_Count
               FROM BSC_SYS_DATASETS_VL
               WHERE UPPER(TRIM(Name)) =UPPER(x_measure_name)
               AND   Source = c_BSC
               AND   Dataset_id <> p_dataset_id;

               IF(l_Count>0) THEN
                   FND_MESSAGE.SET_NAME('BIS','BIS_MEASURE_NAME_UNIQUE');
                   FND_MSG_PUB.ADD;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;
            ELSE
                FOR cd IN c_Update_Measure LOOP
                      l_Flag  :=  BSC_BIS_MEASURE_PUB.Validate_Conditions
                                  (       p_Bsc_source      =>  p_dataset_source
                                      ,   p_Pmf_Old_source  =>  cd.Bis_Source
                                      ,   p_Bsc_Old_Source  =>  cd.Bsc_Source
                                  );
                    IF (NOT l_Flag) THEN
                        FND_MESSAGE.SET_NAME('BIS','BIS_MEASURE_NAME_UNIQUE');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
                END LOOP;
           END IF;
        END IF;

END get_Measure_Name;
/************************************************************************/

/************************************************************************/
-- wrapper of Create_Measure that takes in p_default_short_name parameter
/************************************************************************/
procedure Create_Measure(
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE
  ,x_dataset_id                     OUT NOCOPY NUMBER
  ,p_dataset_source                 IN VARCHAR2
  ,p_dataset_name                   IN VARCHAR2
  ,p_dataset_help                   IN VARCHAR2 := NULL
  ,p_dataset_measure_id1            IN NUMBER   := NULL
  ,p_dataset_operation              IN VARCHAR2 := NULL
  ,p_dataset_measure_id2            IN NUMBER   := NULL
  ,p_dataset_format_id              IN NUMBER   := NULL
  ,p_dataset_color_method           IN NUMBER   := NULL
  ,p_dataset_autoscale_flag         IN NUMBER   := NULL
  ,p_dataset_projection_flag        IN NUMBER   := NULL
  ,p_measure_short_name             IN VARCHAR2
  ,p_region_app_id                  IN Ak_Region_Items.REGION_APPLICATION_ID%Type    := -1
  ,p_source_column_app_id           IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_compare_column_app_id          IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_measure_act_data_src_type      IN VARCHAR2 := NULL
  ,p_measure_act_data_src           IN VARCHAR2 := NULL
  ,p_measure_comparison_source      IN VARCHAR2 := NULL
  ,p_measure_operation              IN VARCHAR2 := c_SUM
  ,p_measure_uom_class              IN VARCHAR2 := NULL
  ,p_measure_increase_in_measure    IN VARCHAR2 := NULL
  ,p_measure_random_style           IN NUMBER   := NULL
  ,p_measure_min_act_value          IN NUMBER   := NULL
  ,p_measure_max_act_value          IN NUMBER   := NULL
  ,p_measure_min_bud_value          IN NUMBER   := NULL
  ,p_measure_max_bud_value          IN NUMBER   := NULL
  ,p_measure_app_id                 IN NUMBER   := NULL
  ,p_measure_col                    IN VARCHAR2 := NULL
  ,p_measure_col_help               IN VARCHAR2 := NULL
  ,p_measure_group_id               IN NUMBER   := NULL
  ,p_measure_projection_id          IN NUMBER   := NULL
  ,p_measure_type                   IN NUMBER   := NULL
  ,p_measure_apply_rollup           IN VARCHAR2 := NULL
  ,p_measure_function_name          IN VARCHAR2 := NULL
  ,p_measure_enable_link            IN VARCHAR2 := NULL
  ,p_measure_obsolete               IN VARCHAR2 := FND_API.G_FALSE
  ,p_type                           IN VARCHAR2 := NULL -- This is used for weighted kpis,This can take values CDS_SCORE,CDS_PERF or Null
  ,p_measure_is_validate            IN VARCHAR2 := FND_API.G_TRUE -- ankgoel: bug#3557236
  ,p_dimension1_id                  IN NUMBER
  ,p_dimension2_id                  IN NUMBER
  ,p_dimension3_id                  IN NUMBER
  ,p_dimension4_id                  IN NUMBER
  ,p_dimension5_id                  IN NUMBER
  ,p_dimension6_id                  IN NUMBER
  ,p_dimension7_id                  IN NUMBER
  ,p_y_axis_title                   IN VARCHAR2 := NULL
  ,p_owner                          IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  ,p_ui_flag                        IN VARCHAR2
  ,p_is_default_short_name          IN VARCHAR2
  ,p_func_area_short_name           IN VARCHAR2 := NULL
  ,x_return_status                  OUT NOCOPY VARCHAR2
  ,x_msg_count                      OUT NOCOPY NUMBER
  ,x_msg_data                       OUT NOCOPY VARCHAR2
) is
l_measure_short_name    BIS_INDICATORS.short_name%TYPE;
l_temp_var              BIS_INDICATORS.short_name%TYPE;
l_alias                 VARCHAR2(5);
l_flag                  BOOLEAN;
l_count                 NUMBER;
begin
  SAVEPOINT SP_CREATE_MEASURE;

  x_return_status        :=  FND_API.G_RET_STS_SUCCESS;
  fnd_msg_pub.initialize;

  l_measure_short_name := p_measure_short_name;
  IF (UPPER(p_is_default_short_name) = 'T') THEN
    --check for unqiue short name, if not unique, provide a unique one
    l_flag              :=  TRUE;
    l_alias             :=  NULL;
    l_temp_var          :=  l_measure_short_name;
    WHILE (l_flag) LOOP
      SELECT count(1) INTO l_count
      FROM   BIS_INDICATORS
      WHERE  UPPER(TRIM(Short_Name)) = UPPER(TRIM(l_temp_var));
      IF (l_count = 0) THEN
        l_flag               :=  FALSE;
        l_measure_short_name :=  l_temp_var;
      END IF;
      l_alias         :=  BSC_BIS_MEASURE_PUB.get_Next_Alias(l_alias);
      l_temp_var      :=  l_measure_short_name||l_alias;
    END LOOP;
  END IF;

  --dispatch create_measure
  BSC_BIS_MEASURE_PUB.Create_Measure(
   p_commit                         => p_commit
  ,x_dataset_id                     => x_dataset_id
  ,p_dataset_source                 => p_dataset_source
  ,p_dataset_name                   => p_dataset_name
  ,p_dataset_help                   => p_dataset_help
  ,p_dataset_measure_id1            => p_dataset_measure_id1
  ,p_dataset_operation              => p_dataset_operation
  ,p_dataset_measure_id2            => p_dataset_measure_id2
  ,p_dataset_format_id              => p_dataset_format_id
  ,p_dataset_color_method           => p_dataset_color_method
  ,p_dataset_autoscale_flag         => p_dataset_autoscale_flag
  ,p_dataset_projection_flag        => p_dataset_projection_flag
  ,p_measure_short_name             => l_measure_short_name
  ,p_region_app_id                  => p_region_app_id
  ,p_source_column_app_id           => p_source_column_app_id
  ,p_compare_column_app_id          => p_compare_column_app_id
  ,p_measure_act_data_src_type      => p_measure_act_data_src_type
  ,p_measure_act_data_src           => p_measure_act_data_src
  ,p_measure_comparison_source      => p_measure_comparison_source
  ,p_measure_operation              => p_measure_operation
  ,p_measure_uom_class              => p_measure_uom_class
  ,p_measure_increase_in_measure    => p_measure_increase_in_measure
  ,p_measure_random_style           => p_measure_random_style
  ,p_measure_min_act_value          => p_measure_min_act_value
  ,p_measure_max_act_value          => p_measure_max_act_value
  ,p_measure_min_bud_value          => p_measure_min_bud_value
  ,p_measure_max_bud_value          => p_measure_max_bud_value
  ,p_measure_app_id                 => p_measure_app_id
  ,p_measure_col                    => p_measure_col
  ,p_measure_col_help               => p_measure_col_help
  ,p_measure_group_id               => p_measure_group_id
  ,p_measure_projection_id          => p_measure_projection_id
  ,p_measure_type                   => p_measure_type
  ,p_measure_apply_rollup           => p_measure_apply_rollup
  ,p_measure_function_name          => p_measure_function_name
  ,p_measure_enable_link            => p_measure_enable_link
  ,p_measure_obsolete               => p_measure_obsolete
  ,p_type                           => p_type
  ,p_measure_is_validate            => p_measure_is_validate
  ,p_dimension1_id                  => p_dimension1_id
  ,p_dimension2_id                  => p_dimension2_id
  ,p_dimension3_id                  => p_dimension3_id
  ,p_dimension4_id                  => p_dimension4_id
  ,p_dimension5_id                  => p_dimension5_id
  ,p_dimension6_id                  => p_dimension6_id
  ,p_dimension7_id                  => p_dimension7_id
  ,p_y_axis_title                   => p_y_axis_title
  ,p_owner                          => p_owner
  ,p_ui_flag                        => p_ui_flag
  ,p_last_update_date               => sysdate
  ,p_func_area_short_name           => p_func_area_short_name
  ,x_return_status                  => x_return_status
  ,x_msg_count                      => x_msg_count
  ,x_msg_data                       => x_msg_data
  );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (   p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_CREATE_MEASURE;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (   p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_CREATE_MEASURE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_MEASURE_PUB.Create_Measure ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_MEASURE_PUB.Create_Measure ';
    END IF;
    ROLLBACK TO SP_CREATE_MEASURE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_MEASURE_PUB.Create_Measure ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_MEASURE_PUB.Create_Measure ';
    END IF;
    ROLLBACK TO SP_CREATE_MEASURE;
end Create_Measure;
/************************End Create_Measure wrapper****************************/


procedure Create_Measure(
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE
  ,x_dataset_id                     OUT NOCOPY NUMBER
  ,p_dataset_source                 IN VARCHAR2
  ,p_dataset_name                   IN VARCHAR2
  ,p_dataset_help                   IN VARCHAR2 := NULL
  ,p_dataset_measure_id1            IN NUMBER   := NULL
  ,p_dataset_operation              IN VARCHAR2 := NULL
  ,p_dataset_measure_id2            IN NUMBER   := NULL
  ,p_dataset_format_id              IN NUMBER   := NULL
  ,p_dataset_color_method           IN NUMBER   := NULL
  ,p_dataset_autoscale_flag         IN NUMBER   := NULL
  ,p_dataset_projection_flag        IN NUMBER   := NULL
  ,p_measure_short_name             IN VARCHAR2
  ,p_region_app_id                  IN Ak_Region_Items.REGION_APPLICATION_ID%Type    := -1
  ,p_source_column_app_id           IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_compare_column_app_id          IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_measure_act_data_src_type      IN VARCHAR2 := NULL
  ,p_measure_act_data_src           IN VARCHAR2 := NULL
  ,p_measure_comparison_source      IN VARCHAR2 := NULL
  ,p_measure_operation              IN VARCHAR2 := c_SUM
  ,p_measure_uom_class              IN VARCHAR2 := NULL
  ,p_measure_increase_in_measure    IN VARCHAR2 := NULL
  ,p_measure_random_style           IN NUMBER   := NULL
  ,p_measure_min_act_value          IN NUMBER   := NULL
  ,p_measure_max_act_value          IN NUMBER   := NULL
  ,p_measure_min_bud_value          IN NUMBER   := NULL
  ,p_measure_max_bud_value          IN NUMBER   := NULL
  ,p_measure_app_id                 IN NUMBER   := NULL
  ,p_measure_col                    IN VARCHAR2 := NULL
  ,p_measure_col_help               IN VARCHAR2 := NULL
  ,p_measure_group_id               IN NUMBER   := NULL
  ,p_measure_projection_id          IN NUMBER   := NULL
  ,p_measure_type                   IN NUMBER   := NULL
  ,p_measure_apply_rollup           IN VARCHAR2 := NULL
  ,p_measure_function_name          IN VARCHAR2 := NULL
  ,p_measure_enable_link            IN VARCHAR2 := NULL
  ,p_measure_obsolete               IN VARCHAR2 := FND_API.G_FALSE
  ,p_type                           IN VARCHAR2 := NULL -- This is used for weighted kpis,This can take values CDS_SCORE,CDS_PERF or Null
  ,p_measure_is_validate            IN VARCHAR2 := FND_API.G_TRUE -- ankgoel: bug#3557236
  ,p_dimension1_id                  IN NUMBER
  ,p_dimension2_id                  IN NUMBER
  ,p_dimension3_id                  IN NUMBER
  ,p_dimension4_id                  IN NUMBER
  ,p_dimension5_id                  IN NUMBER
  ,p_dimension6_id                  IN NUMBER
  ,p_dimension7_id                  IN NUMBER
  ,p_y_axis_title                   IN VARCHAR2 := NULL
  ,p_owner                          IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  ,p_ui_flag                        IN VARCHAR2
  ,p_func_area_short_name           IN VARCHAR2 := NULL
  ,x_return_status                  OUT NOCOPY VARCHAR2
  ,x_msg_count                      OUT NOCOPY NUMBER
  ,x_msg_data                       OUT NOCOPY VARCHAR2
) is
begin
  SAVEPOINT SP_CREATE_MEASURE;

  x_return_status        :=  FND_API.G_RET_STS_SUCCESS;
  fnd_msg_pub.initialize;

  --dispatch create_measure
  BSC_BIS_MEASURE_PUB.Create_Measure(
   p_commit                         => p_commit
  ,x_dataset_id                     => x_dataset_id
  ,p_dataset_source                 => p_dataset_source
  ,p_dataset_name                   => p_dataset_name
  ,p_dataset_help                   => p_dataset_help
  ,p_dataset_measure_id1            => p_dataset_measure_id1
  ,p_dataset_operation              => p_dataset_operation
  ,p_dataset_measure_id2            => p_dataset_measure_id2
  ,p_dataset_format_id              => p_dataset_format_id
  ,p_dataset_color_method           => p_dataset_color_method
  ,p_dataset_autoscale_flag         => p_dataset_autoscale_flag
  ,p_dataset_projection_flag        => p_dataset_projection_flag
  ,p_measure_short_name             => p_measure_short_name
  ,p_region_app_id                  => p_region_app_id
  ,p_source_column_app_id           => p_source_column_app_id
  ,p_compare_column_app_id          => p_compare_column_app_id
  ,p_measure_act_data_src_type      => p_measure_act_data_src_type
  ,p_measure_act_data_src           => p_measure_act_data_src
  ,p_measure_comparison_source      => p_measure_comparison_source
  ,p_measure_operation              => p_measure_operation
  ,p_measure_uom_class              => p_measure_uom_class
  ,p_measure_increase_in_measure    => p_measure_increase_in_measure
  ,p_measure_random_style           => p_measure_random_style
  ,p_measure_min_act_value          => p_measure_min_act_value
  ,p_measure_max_act_value          => p_measure_max_act_value
  ,p_measure_min_bud_value          => p_measure_min_bud_value
  ,p_measure_max_bud_value          => p_measure_max_bud_value
  ,p_measure_app_id                 => p_measure_app_id
  ,p_measure_col                    => p_measure_col
  ,p_measure_col_help               => p_measure_col_help
  ,p_measure_group_id               => p_measure_group_id
  ,p_measure_projection_id          => p_measure_projection_id
  ,p_measure_type                   => p_measure_type
  ,p_measure_apply_rollup           => p_measure_apply_rollup
  ,p_measure_function_name          => p_measure_function_name
  ,p_measure_enable_link            => p_measure_enable_link
  ,p_measure_obsolete               => p_measure_obsolete
  ,p_type                           => p_type
  ,p_measure_is_validate            => p_measure_is_validate
  ,p_dimension1_id                  => p_dimension1_id
  ,p_dimension2_id                  => p_dimension2_id
  ,p_dimension3_id                  => p_dimension3_id
  ,p_dimension4_id                  => p_dimension4_id
  ,p_dimension5_id                  => p_dimension5_id
  ,p_dimension6_id                  => p_dimension6_id
  ,p_dimension7_id                  => p_dimension7_id
  ,p_y_axis_title                   => p_y_axis_title
  ,p_owner                          => p_owner
  ,p_ui_flag                        => p_ui_flag
  ,p_last_update_date               => sysdate
  ,p_func_area_short_name           => p_func_area_short_name
  ,x_return_status                  => x_return_status
  ,x_msg_count                      => x_msg_count
  ,x_msg_data                       => x_msg_data
  );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (   p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_CREATE_MEASURE;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (   p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_CREATE_MEASURE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_MEASURE_PUB.Create_Measure ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_MEASURE_PUB.Create_Measure ';
    END IF;
    ROLLBACK TO SP_CREATE_MEASURE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_MEASURE_PUB.Create_Measure ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_MEASURE_PUB.Create_Measure ';
    END IF;
    ROLLBACK TO SP_CREATE_MEASURE;
end CREATE_MEASURE;

--Bug#4045278: Wrapper for Create_Measure that takes in last_update_date
procedure Create_Measure(
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE
  ,x_dataset_id                     OUT NOCOPY NUMBER
  ,p_dataset_source                 IN VARCHAR2
  ,p_dataset_name                   IN VARCHAR2
  ,p_dataset_help                   IN VARCHAR2 := NULL
  ,p_dataset_measure_id1            IN NUMBER   := NULL
  ,p_dataset_operation              IN VARCHAR2 := NULL
  ,p_dataset_measure_id2            IN NUMBER   := NULL
  ,p_dataset_format_id              IN NUMBER   := NULL
  ,p_dataset_color_method           IN NUMBER   := NULL
  ,p_dataset_autoscale_flag         IN NUMBER   := NULL
  ,p_dataset_projection_flag        IN NUMBER   := NULL
  ,p_measure_short_name             IN VARCHAR2
  ,p_region_app_id                  IN Ak_Region_Items.REGION_APPLICATION_ID%Type    := -1
  ,p_source_column_app_id           IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_compare_column_app_id          IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_measure_act_data_src_type      IN VARCHAR2 := NULL
  ,p_measure_act_data_src           IN VARCHAR2 := NULL
  ,p_measure_comparison_source      IN VARCHAR2 := NULL
  ,p_measure_operation              IN VARCHAR2 := c_SUM
  ,p_measure_uom_class              IN VARCHAR2 := NULL
  ,p_measure_increase_in_measure    IN VARCHAR2 := NULL
  ,p_measure_random_style           IN NUMBER   := NULL
  ,p_measure_min_act_value          IN NUMBER   := NULL
  ,p_measure_max_act_value          IN NUMBER   := NULL
  ,p_measure_min_bud_value          IN NUMBER   := NULL
  ,p_measure_max_bud_value          IN NUMBER   := NULL
  ,p_measure_app_id                 IN NUMBER   := NULL
  ,p_measure_col                    IN VARCHAR2 := NULL
  ,p_measure_col_help               IN VARCHAR2 := NULL
  ,p_measure_group_id               IN NUMBER   := NULL
  ,p_measure_projection_id          IN NUMBER   := NULL
  ,p_measure_type                   IN NUMBER   := NULL
  ,p_measure_apply_rollup           IN VARCHAR2 := NULL
  ,p_measure_function_name          IN VARCHAR2 := NULL
  ,p_measure_enable_link            IN VARCHAR2 := NULL
  ,p_measure_obsolete               IN VARCHAR2 := FND_API.G_FALSE
  ,p_type                           IN VARCHAR2 := NULL -- This is used for weighted kpis,This can take values CDS_SCORE,CDS_PERF or Null
  ,p_measure_is_validate            IN VARCHAR2 := FND_API.G_TRUE -- ankgoel: bug#3557236
  ,p_dimension1_id                  IN NUMBER
  ,p_dimension2_id                  IN NUMBER
  ,p_dimension3_id                  IN NUMBER
  ,p_dimension4_id                  IN NUMBER
  ,p_dimension5_id                  IN NUMBER
  ,p_dimension6_id                  IN NUMBER
  ,p_dimension7_id                  IN NUMBER
  ,p_y_axis_title                   IN VARCHAR2 := NULL
  ,p_owner                          IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  ,p_ui_flag                        IN VARCHAR2 := c_UI_FLAG
  ,p_last_update_date               IN BIS_INDICATORS.LAST_UPDATE_DATE%TYPE
  ,p_func_area_short_name           IN VARCHAR2 := NULL
  ,x_return_status                  OUT NOCOPY VARCHAR2
  ,x_msg_count                      OUT NOCOPY NUMBER
  ,x_msg_data                       OUT NOCOPY VARCHAR2
) is

    l_Dataset_Rec           BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
    l_measure_rec           BIS_MEASURE_PUB.Measure_rec_type;
    l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_Measure_Col_Help      VARCHAR2(150);
    l_count                 NUMBER;
    l_last_update_date      BIS_INDICATORS.LAST_UPDATE_DATE%TYPE;
begin
    SAVEPOINT SP_CREATE_MEASURE;

    x_return_status        :=  FND_API.G_RET_STS_SUCCESS;
    fnd_msg_pub.initialize;

    l_Dataset_Rec.Bsc_Source := p_dataset_source;
    l_Dataset_Rec.Bsc_Dataset_Help := p_dataset_help;
    l_Dataset_Rec.Bsc_Measure_Id := p_dataset_measure_id1;
    l_Dataset_Rec.Bsc_Measure_Id2 := p_dataset_measure_id2;
    l_Dataset_Rec.Bsc_Dataset_Format_Id := p_dataset_format_id;
    l_Dataset_Rec.Bsc_Dataset_Color_Method := p_dataset_color_method;
    l_Dataset_Rec.Bsc_Dataset_Autoscale_Flag := p_dataset_autoscale_flag;
    l_Dataset_Rec.Bsc_Dataset_Projection_Flag := p_dataset_projection_flag;
    l_Dataset_Rec.Bsc_Dataset_Operation := p_dataset_operation;
    l_Dataset_Rec.Bsc_Measure_Long_Name := l_Dataset_Rec.Bsc_Dataset_Name;
    IF (l_Dataset_Rec.Bsc_Source = c_BSC) THEN
        l_Dataset_Rec.Bsc_Meas_Type := 0;
    END IF;
    l_Dataset_Rec.Bsc_Measure_Projection_Id := p_measure_projection_id;
    l_Dataset_Rec.Bsc_y_axis_Title := p_y_axis_title;

    l_Dataset_Rec.Bsc_Measure_Random_Style  := p_measure_random_style;
    l_Dataset_Rec.Bsc_Measure_Max_Act_Value := p_measure_max_act_value;
    l_Dataset_Rec.Bsc_Measure_Max_Bud_Value := p_measure_max_bud_value;
    l_Dataset_Rec.Bsc_Measure_Min_Act_Value := p_measure_min_act_value;
    l_Dataset_Rec.Bsc_Measure_Min_Bud_Value := p_measure_min_bud_value;

    --sawu: populate WHO column
    l_last_update_date := nvl(p_last_update_date, sysdate);

    l_Dataset_Rec.Bsc_Dataset_Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
    l_Dataset_Rec.Bsc_Dataset_Last_Update_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
    l_Dataset_Rec.Bsc_Dataset_Last_Update_Login := fnd_global.LOGIN_ID;
    l_Dataset_Rec.Bsc_Dataset_Creation_Date := l_last_update_date;
    l_Dataset_Rec.Bsc_Dataset_Last_Update_Date := l_last_update_date;

    l_Dataset_Rec.Bsc_Measure_Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
    l_Dataset_Rec.Bsc_Measure_Last_Update_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
    l_Dataset_Rec.Bsc_Measure_Last_Update_Login := fnd_global.LOGIN_ID;
    l_Dataset_Rec.Bsc_Measure_Creation_Date := l_last_update_date;
    l_Dataset_Rec.Bsc_Measure_Last_Update_Date := l_last_update_date;

        -- We dont need to lock here, since the data_source has
        -- not been created yet.
    IF (p_measure_short_name IS NOT NULL) THEN

        l_Dataset_Rec.Bsc_Measure_Short_Name    := UPPER(TRIM(p_measure_short_name));

        IF (NOT is_Valid_AlphaNum(l_Dataset_Rec.Bsc_Measure_Short_Name)) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_ALPHA_NUM_REQUIRED');
            FND_MESSAGE.SET_TOKEN('VALUE',  l_Dataset_Rec.Bsc_Measure_Short_Name);
            FND_MESSAGE.SET_TOKEN('NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_BUILDER', 'MEASURE_SHORT_NAME'), TRUE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        SELECT COUNT(Short_Name) INTO l_count
        FROM   BIS_INDICATORS
        WHERE  UPPER(TRIM(Short_Name)) = l_Dataset_Rec.Bsc_Measure_Short_Name;
        IF (l_count > 0) THEN
          FND_MESSAGE.SET_NAME('BIS','BIS_MEASURE_SHORT_NAME_UNIQUE');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;


    /******************* PAJOHRI ADDED Bug #3184408*************************/
    BSC_BIS_MEASURE_PUB.get_Measure_Name
    (       p_dataset_id        =>    NULL
        ,   p_ui_flag           =>    p_ui_flag
        ,   p_dataset_source    =>    p_dataset_source
        ,   p_dataset_name      =>    p_dataset_name
        ,   x_measure_name      =>    l_measure_rec.Measure_Name
    );
    l_Dataset_Rec.Bsc_Dataset_Name  := l_measure_rec.Measure_Name;
    /******************************************/

    if p_measure_col is null then
    -- mdamle 09/03/2003 - get measure col

        l_Dataset_Rec.Bsc_Measure_Col := get_measure_col(l_Dataset_Rec.Bsc_Dataset_Name, p_dataset_source, NULL,l_Dataset_Rec.Bsc_Measure_Short_Name);
    else
        l_Dataset_Rec.Bsc_Measure_Col := p_measure_col;
    end if;

    -- Bug#3817894; SUBSTR is used since BSC_DB_MEASURE_COLS_TL.HELP is of VARCHAR2(150) type.
    IF p_Measure_Col_Help IS NULL THEN
       -- SUBSTR does not work with pseudo-translated chars. We would pass NULL then.
       BEGIN
          IF (p_Dataset_Help IS NOT NULL) THEN
              l_Dataset_Rec.Bsc_Measure_Col_Help := SUBSTR(p_Dataset_Help, 1, 150);
          ELSE
              l_Dataset_Rec.Bsc_Measure_Col_Help := SUBSTR(l_Dataset_Rec.Bsc_Measure_Col, 1, 150);
          END IF;
       EXCEPTION
         WHEN OTHERS THEN
            l_Dataset_Rec.Bsc_Measure_Col_Help := SUBSTR(l_Dataset_Rec.Bsc_Measure_Col, 1, 150);
       END;
    ELSE
       l_Dataset_Rec.Bsc_Measure_Col_Help := p_Measure_Col_Help;
    END IF;

    if p_measure_operation is null then
        l_Dataset_Rec.Bsc_Measure_Operation := c_SUM;
    else
        l_Dataset_Rec.Bsc_Measure_Operation := p_measure_operation;
    end if;

    -- 1.) Need to place this line after l_Dataset_Rec.Bsc_Measure_Col is set
    -- 2.) Need to place this line after l_Dataset_Rec.Bsc_Measure_Operation is set
    l_Dataset_Rec.Bsc_Measure_color_formula := getColorFormula(l_Dataset_Rec, p_measure_apply_rollup);

    if (l_Dataset_Rec.Bsc_Measure_operation = c_AVGL_CODE) then
        l_Dataset_Rec.Bsc_Measure_operation := 'AVG';
    end if;

    -- Insert the Dataset and Measure Record
    -- When DataSource (measure_id1) is passed as -1 from the UI then Bug #3292146
    SELECT COUNT(Measure_Id)
    INTO   l_count
    FROM   BSC_SYS_MEASURES
    WHERE  Measure_Id  = -1
    AND    Measure_Col = l_Dataset_Rec.Bsc_Measure_Col;

    if  (l_Dataset_Rec.Bsc_Measure_id = -1) and (l_count = 0) then
       l_Dataset_Rec.Bsc_Measure_id := NULL;
    end if;

    if (l_Dataset_Rec.Bsc_Measure_id is null) then

        -- Insert into BSC tables

        BSC_DATASETS_PUB.Create_Measures(
             p_commit => p_commit
            ,p_Dataset_Rec => l_Dataset_Rec
            ,x_Dataset_Id => x_Dataset_Id
            ,x_return_status => x_return_status
            ,x_msg_count => x_msg_count
            ,x_msg_data => x_msg_data);
    IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
          --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at BSC_DATASETS_PUB.Create_Measures');
          RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    else
         -- START Granular Locking
         -- you need to lock both the Datasources (1 and 2), since
         -- you would not want someone to delete it whenever
         -- it is being assigned to the datasets/
         -- Lock the first Data Source
        if (l_Dataset_Rec.Bsc_Measure_Id is not null) then
            BSC_BIS_LOCKS_PUB.LOCK_DATASOURCE(
                p_measure_id      =>  l_Dataset_Rec.Bsc_Measure_Id
               ,p_time_stamp      =>  NULL
               ,x_return_status   =>  x_return_status
               ,x_msg_count       =>  x_msg_count
               ,x_msg_data        =>  x_msg_data
            ) ;

            if ((x_return_status  =  FND_API.G_RET_STS_ERROR)  or (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) then
               raise  FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;
        end if;

         -- Lock the second Data Source
        if (l_Dataset_Rec.Bsc_Measure_Id2 is not null) then
            BSC_BIS_LOCKS_PUB.LOCK_DATASOURCE(
                p_measure_id      =>  l_Dataset_Rec.Bsc_Measure_Id2
               ,p_time_stamp      =>  NULL
               ,x_return_status   =>  x_return_status
               ,x_msg_count       =>  x_msg_count
               ,x_msg_data        =>  x_msg_data
            ) ;
            if ((x_return_status  =  FND_API.G_RET_STS_ERROR)  or (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) then
               raise  FND_API.G_EXC_UNEXPECTED_ERROR;
            end if;
        end if;

         -- END Granular Locking


        -- Now, create the dataset.
        BSC_DATASETS_PUB.Create_Dataset(
             p_commit => FND_API.G_FALSE
            ,p_Dataset_Rec => l_Dataset_Rec
            ,x_Dataset_Id => x_Dataset_Id
            ,x_return_status => x_return_status
            ,x_msg_count => x_msg_count
            ,x_msg_data => x_msg_data);
    IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
          --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at BSC_DATASETS_PUB.Create_Dataset');
          RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- POSCO Bug#3817894
        -- Update the measure column if a different source column
        -- has been chosen from the LOV and

        IF (NOT isFormula(l_Dataset_Rec.Bsc_Measure_Col) AND l_Dataset_Rec.Bsc_Source = c_BSC) THEN
            BSC_DB_MEASURE_COLS_PKG.Update_Measure_Column_Help (
               p_Measure_Col    => l_Dataset_Rec.Bsc_Measure_Col
             , p_Help           => l_Dataset_Rec.Bsc_Measure_Col_Help
             , x_Return_Status  => x_return_status
             , x_Msg_Count      => x_msg_count
             , x_Msg_Data       => x_msg_data
           );
           IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
              RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

    -- START Granular Locking

        -- Change the time stamp of the Current Datasource (1)
        IF (l_Dataset_Rec.Bsc_Measure_Id is not null) THEN
           BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASOURCE(
              p_measure_id      =>  l_Dataset_Rec.Bsc_Measure_Id
             ,p_lud             =>  l_Dataset_Rec.Bsc_Dataset_Last_Update_Date
             ,x_return_status   =>  x_return_status
             ,x_msg_count       =>  x_msg_count
             ,x_msg_data        =>  x_msg_data
           ) ;

           IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

        -- Change the time stamp of the Current Datasource (2)
        IF (l_Dataset_Rec.Bsc_Measure_Id2 is not null) THEN
           BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASOURCE(
              p_measure_id      =>  l_Dataset_Rec.Bsc_Measure_Id2
             ,p_lud             =>  l_Dataset_Rec.Bsc_Dataset_Last_Update_Date
             ,x_return_status   =>  x_return_status
             ,x_msg_count       =>  x_msg_count
             ,x_msg_data        =>  x_msg_data
           ) ;

           IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

         -- END Granular Locking

    end if;

    l_Dataset_Rec.Bsc_dataset_id := x_dataset_id;

    -- Insert into PMF tables
    l_measure_rec.Dataset_id := x_dataset_id;

    if l_Dataset_Rec.Bsc_Measure_Short_Name is null then
        l_Dataset_Rec.Bsc_Measure_Short_Name := c_PMD || x_Dataset_id;
    end if;

    l_measure_rec.Measure_Short_Name := l_Dataset_Rec.Bsc_Measure_Short_Name;

    -- mdamle 10/07/2003 - Bug#3170184 - For BSC type measure, always use short name in PMF display name
    -- PAJOHRI Commented
    /*if (l_Dataset_Rec.Bsc_Source = c_BSC) then
        l_measure_rec.Measure_Name := l_measure_rec.Measure_Short_Name;
    else
        l_measure_rec.Measure_Name := l_Dataset_Rec.Bsc_Dataset_Name;
    end if;*/
    l_measure_rec.Description := p_dataset_help;
    l_measure_rec.Unit_Of_Measure_Class := p_measure_uom_class;
    l_measure_rec.actual_data_source_type := p_measure_act_data_src_type ;
    l_measure_rec.actual_data_source := p_measure_act_data_src;
    l_measure_rec.comparison_source := p_measure_comparison_source;
    l_measure_rec.increase_in_measure := p_measure_increase_in_measure;
    l_measure_rec.function_name := p_measure_function_name;
    l_measure_rec.enable_link := p_measure_enable_link;
    l_measure_rec.obsolete    := p_measure_obsolete;
    l_measure_rec.measure_type:= p_type;
    l_measure_rec.is_validate := p_measure_is_validate;

    --sawu: 9/1/04: populates region_app_id and attribute_code_app_id for ak_region_items also
    l_measure_rec.Region_App_Id         := p_region_app_id;
    l_measure_rec.Source_Column_App_Id  := p_source_column_app_id;
    l_measure_rec.Compare_Column_App_Id := p_compare_column_app_id;

    if (p_measure_app_id is null) then
            l_measure_rec.Application_Id := 271;
    else
            l_measure_rec.Application_Id := p_measure_app_id;
    end if;

    -- mdamle 07/07/2003 - Added indicator dimensions
    l_Measure_rec.Dimension1_Id := p_Dimension1_id;
    l_Measure_rec.Dimension2_Id := p_Dimension2_id;
    l_Measure_rec.Dimension3_Id := p_Dimension3_id;
    l_Measure_rec.Dimension4_Id := p_Dimension4_id;
    l_Measure_rec.Dimension5_Id := p_Dimension5_id;
    l_Measure_rec.Dimension6_Id := p_Dimension6_id;
    l_Measure_rec.Dimension7_Id := p_Dimension7_id;

    --sawu: populate WHO column
    l_Measure_rec.Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
    l_Measure_rec.Creation_Date := l_last_update_date;
    l_Measure_rec.Last_Updated_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
    l_Measure_rec.Last_Update_Login := fnd_global.LOGIN_ID;
    l_Measure_rec.Last_Update_Date := l_last_update_date;

    -- rpenneru 12/20/2004 - Add Functional Area short name
    l_Measure_rec.Func_Area_Short_Name := p_func_area_short_name;

    BIS_MEASURE_PUB.Create_Measure(
                     p_api_version   => 1.0
                        ,p_commit        => p_commit
                        ,p_Measure_Rec   => l_measure_rec
                        ,p_owner         => p_owner
                        ,x_return_status => x_return_status
                        ,x_error_tbl     => l_error_tbl);

    IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
        IF (l_error_tbl.COUNT > 0) THEN
            x_msg_data  :=  l_error_tbl(l_error_tbl.COUNT).Error_Description;
            IF(INSTR(x_msg_data, ' ')  =  0 ) THEN
                FND_MESSAGE.SET_NAME('BIS',x_msg_data);
                FND_MSG_PUB.ADD;
                x_msg_data  :=  NULL;
            END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    BSC_UTILITY.Add_To_Fnd_Msg_Stack(
             p_error_tbl       => l_error_tbl
            ,x_return_status   => x_return_status
            ,x_msg_count       => x_msg_count
            ,x_msg_data        => x_msg_data);

    -- visuri removed l_Dataset_Rec.Bsc_Measure_id is null from if condition for bug 3284190
    -- Bug#3817894 - Pass the source column values
    -- Aditya Rao relaxed creation of Measure Columns
--    if (not isFormula(l_Dataset_Rec.Bsc_Measure_Col) and l_Dataset_Rec.Bsc_Source = c_BSC) then
    IF NOT (isFormula(l_Dataset_Rec.Bsc_Measure_Col) OR l_Dataset_Rec.Bsc_Source = c_CDS) THEN
        bsc_db_measure_cols_pkg.insert_row(
             l_Dataset_Rec.Bsc_Measure_Col
            ,p_measure_group_id
            ,l_Dataset_Rec.Bsc_Measure_Projection_Id
            ,p_Measure_Type
            ,l_Dataset_Rec.Bsc_Measure_Col_Help);
    end if;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (   p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_CREATE_MEASURE;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (   p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_CREATE_MEASURE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_MEASURE_PUB.Create_Measure ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_MEASURE_PUB.Create_Measure ';
    END IF;
    ROLLBACK TO SP_CREATE_MEASURE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_MEASURE_PUB.Create_Measure ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_MEASURE_PUB.Create_Measure ';
    END IF;
    ROLLBACK TO SP_CREATE_MEASURE;
end CREATE_MEASURE;


procedure Update_Measure(
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE
  ,p_dataset_id                     IN NUMBER
  ,p_dataset_source                 IN VARCHAR2
  ,p_dataset_name                   IN VARCHAR2
  ,p_dataset_help                   IN VARCHAR2 := NULL
  ,p_dataset_measure_id1            IN NUMBER   := NULL
  ,p_dataset_operation              IN VARCHAR2 := NULL
  ,p_dataset_measure_id2            IN NUMBER   := NULL
  ,p_dataset_format_id              IN NUMBER   := NULL
  ,p_dataset_color_method           IN NUMBER   := NULL
  ,p_dataset_autoscale_flag         IN NUMBER   := NULL
  ,p_dataset_projection_flag        IN NUMBER   := NULL
  ,p_measure_short_name             IN VARCHAR2
  ,p_region_app_id                  IN Ak_Region_Items.REGION_APPLICATION_ID%Type    := -1
  ,p_source_column_app_id           IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_compare_column_app_id          IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_measure_act_data_src_type      IN VARCHAR2 := NULL
  ,p_measure_act_data_src           IN VARCHAR2 := NULL
  ,p_measure_comparison_source      IN VARCHAR2 := NULL
  ,p_measure_operation              IN VARCHAR2 := c_SUM
  ,p_measure_uom_class              IN VARCHAR2 := NULL
  ,p_measure_increase_in_measure    IN VARCHAR2 := NULL
  ,p_measure_random_style           IN NUMBER   := NULL
  ,p_measure_min_act_value          IN NUMBER   := NULL
  ,p_measure_max_act_value          IN NUMBER   := NULL
  ,p_measure_min_bud_value          IN NUMBER   := NULL
  ,p_measure_max_bud_value          IN NUMBER   := NULL
  ,p_measure_app_id                 IN NUMBER   := NULL
  ,p_measure_col                    IN VARCHAR2 := NULL
  ,p_measure_col_help               IN VARCHAR2 := NULL
  ,p_measure_group_id               IN NUMBER   := NULL
  ,p_measure_projection_id          IN NUMBER   := NULL
  ,p_measure_type                   IN NUMBER   := NULL
  ,p_measure_apply_rollup           IN VARCHAR2 := NULL
  ,p_measure_function_name          IN VARCHAR2 := NULL
  ,p_measure_enable_link            IN VARCHAR2 := NULL
  ,p_measure_obsolete               IN VARCHAR2 := FND_API.G_FALSE
  ,p_type                           IN VARCHAR2 := NULL -- This is used for weighted kpis,This can take values CDS_SCORE,CDS_PERF or Null
  ,p_measure_is_validate            IN VARCHAR2 := FND_API.G_TRUE -- ankgoel: bug#3557236
  ,p_time_stamp                     IN VARCHAR2 := NULL    -- Added for Granular Locking
  ,p_dimension1_id                  IN NUMBER
  ,p_dimension2_id                  IN NUMBER
  ,p_dimension3_id                  IN NUMBER
  ,p_dimension4_id                  IN NUMBER
  ,p_dimension5_id                  IN NUMBER
  ,p_dimension6_id                  IN NUMBER
  ,p_dimension7_id                  IN NUMBER
  ,p_y_axis_title                   IN VARCHAR2 := NULL
  ,p_owner                          IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  ,p_ui_flag                        IN VARCHAR2
  ,p_func_area_short_name           IN VARCHAR2 := NULL
  ,x_return_status                  OUT NOCOPY VARCHAR2
  ,x_msg_count                      OUT NOCOPY NUMBER
  ,x_msg_data                       OUT NOCOPY VARCHAR2
) is
begin
    SAVEPOINT SP_UPDATE_MEASURE;
    x_return_status        :=  FND_API.G_RET_STS_SUCCESS;
    fnd_msg_pub.initialize;

    Update_Measure(
       p_commit                         => p_commit
      ,p_dataset_id                     => p_dataset_id
      ,p_dataset_source                 => p_dataset_source
      ,p_dataset_name                   => p_dataset_name
      ,p_dataset_help                   => p_dataset_help
      ,p_dataset_measure_id1            => p_dataset_measure_id1
      ,p_dataset_operation              => p_dataset_operation
      ,p_dataset_measure_id2            => p_dataset_measure_id2
      ,p_dataset_format_id              => p_dataset_format_id
      ,p_dataset_color_method           => p_dataset_color_method
      ,p_dataset_autoscale_flag         => p_dataset_autoscale_flag
      ,p_dataset_projection_flag        => p_dataset_projection_flag
      ,p_measure_short_name             => p_measure_short_name
      ,p_region_app_id                  => p_region_app_id
      ,p_source_column_app_id           => p_source_column_app_id
      ,p_compare_column_app_id          => p_compare_column_app_id
      ,p_measure_act_data_src_type      => p_measure_act_data_src_type
      ,p_measure_act_data_src           => p_measure_act_data_src
      ,p_measure_comparison_source      => p_measure_comparison_source
      ,p_measure_operation              => p_measure_operation
      ,p_measure_uom_class              => p_measure_uom_class
      ,p_measure_increase_in_measure    => p_measure_increase_in_measure
      ,p_measure_random_style           => p_measure_random_style
      ,p_measure_min_act_value          => p_measure_min_act_value
      ,p_measure_max_act_value          => p_measure_max_act_value
      ,p_measure_min_bud_value          => p_measure_min_bud_value
      ,p_measure_max_bud_value          => p_measure_max_bud_value
      ,p_measure_app_id                 => p_measure_app_id
      ,p_measure_col                    => p_measure_col
      ,p_measure_col_help               => p_measure_col_help
      ,p_measure_group_id               => p_measure_group_id
      ,p_measure_projection_id          => p_measure_projection_id
      ,p_measure_type                   => p_measure_type
      ,p_measure_apply_rollup           => p_measure_apply_rollup
      ,p_measure_function_name          => p_measure_function_name
      ,p_measure_enable_link            => p_measure_enable_link
      ,p_measure_obsolete               => p_measure_obsolete
      ,p_type                           => p_type
      ,p_measure_is_validate            => p_measure_is_validate
      ,p_time_stamp                     => p_time_stamp
      ,p_dimension1_id                  => p_dimension1_id
      ,p_dimension2_id                  => p_dimension2_id
      ,p_dimension3_id                  => p_dimension3_id
      ,p_dimension4_id                  => p_dimension4_id
      ,p_dimension5_id                  => p_dimension5_id
      ,p_dimension6_id                  => p_dimension6_id
      ,p_dimension7_id                  => p_dimension7_id
      ,p_y_axis_title                   => p_y_axis_title
      ,p_owner                          => p_owner
      ,p_ui_flag                        => p_ui_flag
      ,p_last_update_date               => sysdate
      ,p_func_area_short_name           => p_func_area_short_name
      ,x_return_status                  => x_return_status
      ,x_msg_count                      => x_msg_count
      ,x_msg_data                       => x_msg_data
   );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (   p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_UPDATE_MEASURE;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (   p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_UPDATE_MEASURE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_MEASURE_PUB.Update_measure ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_MEASURE_PUB.Update_measure ';
    END IF;
    ROLLBACK TO SP_UPDATE_MEASURE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_MEASURE_PUB.Update_measure ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_MEASURE_PUB.Update_measure ';
    END IF;
    ROLLBACK TO SP_UPDATE_MEASURE;
end Update_measure;

--Bug#4045278: Wrapper for Update_Measure that takes in last_update_date

FUNCTION Is_MeasureCol_In_Formula (
    p_measureCol IN VARCHAR2,
    p_formula IN VARCHAR2
    ) return boolean
IS
 l_start number;
 l_length number;

BEGIN
l_start := INSTR(p_formula, p_measureCol);
l_length := LENGTH(p_measureCol);

IF (l_start>0) THEN

  IF  ((l_start = 1 ) AND INSTR('+-/*()',SUBSTR(p_formula,(l_length+1),1))>0) THEN
  /*The Formula p_formula starts with measure col p_measureCol. It is of the form X+Y where X=p_measureCol
  One character after the source Column X in the formula should be an operator of type +-/*()
  */
   RETURN TRUE;
  ELSIF ((INSTR('+-/*()',SUBSTR(p_formula,l_start-1,1))>0) AND ((INSTR('+-/*()',SUBSTR(p_formula,l_start+l_length,1))>0)OR(LENGTH(p_formula)=l_start+l_length-1))) THEN
  /*The Formula p_formula either ends with measure col p_measureCol or has p_measureCol in it.
  It is of the form Y+X where X=p_measureCol or A+X+B where X=p_measureCol.

  If it is of type Y+X then 1 character before the Measure Column X should be an operator of type +-/*()
  If it is of type A+X+Y then the 1 character before the Measure Column X and one character after the
  measure column X should be an operator of type +-/*()
  */
  RETURN TRUE;
  END IF;
END IF;

RETURN FALSE;

END Is_MeasureCol_In_Formula;


FUNCTION Is_Src_Col_In_Formulas(
p_Source_Col IN VARCHAR2
) RETURN BOOLEAN IS

CURSOR c_All_Formula IS
  SELECT MEASURE_COL
  FROM BSC_SYS_MEASURES;

BEGIN

  FOR cd in c_All_Formula LOOP
    IF (isFormula(cd.MEASURE_COL) AND Is_MeasureCol_In_Formula(p_Source_Col,cd.MEASURE_COL) ) THEN
      RETURN TRUE;
    END IF;
  END LOOP;

  RETURN FALSE;
END Is_Src_Col_In_Formulas;

PROCEDURE Update_Single_To_Formula(
  p_commit         IN VARCHAR2 := FND_API.G_FALSE
 ,p_Dataset_Rec    IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,p_Dataset_Rec_db IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_msg_count      OUT NOCOPY NUMBER
 ,x_msg_data       OUT NOCOPY VARCHAR2

) IS
  l_kpi_flag              number := -1;
  l_indicator_table       BSC_NUM_LIST;
  l_Dataset_Rec           BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;

  CURSOR indicators_cursor is
  SELECT distinct indicator
  FROM   bsc_kpi_analysis_measures_b
  WHERE  dataset_id = l_Dataset_Rec.Bsc_Dataset_Id;

BEGIN
    l_Dataset_Rec := p_Dataset_Rec;
  SAVEPOINT SP_UPD_TO_FORMULA;

  l_Dataset_Rec.Bsc_Measure_Id := BSC_DIMENSION_LEVELS_PVT.Get_Next_Value( 'BSC_SYS_MEASURES'
                         ,'measure_id');
  if l_Dataset_Rec.Bsc_Measure_Col IS NULL then
    l_Dataset_Rec.Bsc_Measure_Col := p_Dataset_Rec_db.Bsc_Measure_Col;
  end if;
  if l_Dataset_Rec.Bsc_Measure_Operation IS NULL then
    l_Dataset_Rec.Bsc_Measure_Operation := p_Dataset_Rec_db.Bsc_Measure_Operation;
  end if;

  if l_Dataset_Rec.Bsc_Meas_Type IS NULL then
    l_Dataset_Rec.Bsc_Meas_Type := p_Dataset_Rec_db.Bsc_Meas_Type;
  end if;

  if l_Dataset_Rec.Bsc_Measure_Min_Act_Value IS NULL then
    l_Dataset_Rec.Bsc_Measure_Min_Act_Value := p_Dataset_Rec_db.Bsc_Measure_Min_Act_Value;
  end if;

  if l_Dataset_Rec.Bsc_Measure_Max_Act_Value IS NULL then
    l_Dataset_Rec.Bsc_Measure_Max_Act_Value := p_Dataset_Rec_db.Bsc_Measure_Max_Act_Value;
  end if;

  if l_Dataset_Rec.Bsc_Measure_Min_Bud_Value IS NULL then
    l_Dataset_Rec.Bsc_Measure_Min_Bud_Value := p_Dataset_Rec_db.Bsc_Measure_Min_Bud_Value;
  end if;

  if l_Dataset_Rec.Bsc_Measure_Max_Bud_Value IS NULL then
    l_Dataset_Rec.Bsc_Measure_Max_Bud_Value := p_Dataset_Rec_db.Bsc_Measure_Max_Bud_Value;
  end if;

  if l_Dataset_Rec.Bsc_Measure_Random_Style IS NULL then
    l_Dataset_Rec.Bsc_Measure_Random_Style := p_Dataset_Rec_db.Bsc_Measure_Random_Style;
  end if;

  if l_Dataset_Rec.Bsc_Measure_Short_Name IS NULL then
    l_Dataset_Rec.Bsc_Measure_Short_Name := p_Dataset_Rec_db.Bsc_Measure_Short_Name;
  end if;

  if l_Dataset_Rec.Bsc_Source IS NULL then
    l_Dataset_Rec.Bsc_Source := p_Dataset_Rec_db.Bsc_Source;
  end if;

  if l_Dataset_Rec.Bsc_Measure_color_formula IS NULL then
    l_Dataset_Rec.Bsc_Measure_color_formula := p_Dataset_Rec_db.Bsc_Measure_color_formula;
  end if;

  if l_Dataset_Rec.Bsc_Measure_Created_By  IS NULL then
    l_Dataset_Rec.Bsc_Measure_Created_By := p_Dataset_Rec_db.Bsc_Measure_Created_By;
  end if;

  if l_Dataset_Rec.Bsc_Measure_Last_Update_By is null then
    l_Dataset_Rec.Bsc_Measure_Last_Update_By := fnd_global.USER_ID;
  end if;

  if l_Dataset_Rec.Bsc_Measure_Last_Update_Login is null then
    l_Dataset_Rec.Bsc_Measure_Last_Update_Login := fnd_global.LOGIN_ID;
  end if;


  BSC_DATASETS_PVT.Create_Measures(
     p_commit
    ,l_Dataset_Rec
    ,x_return_status
    ,x_msg_count
    ,x_msg_data);


  IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
      --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at BSC_DATASETS_PUB.Create_Measures');
      RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Need to update Dataset Info with the new Measure Id generated

  BSC_DATASETS_PUB.Update_Dataset(
     p_commit => p_commit
    ,p_Dataset_Rec => l_Dataset_Rec
    ,p_update_dset_calc => false
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data => x_msg_data);

  IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
    --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at BSC_DATASETS_PUB.Update_Measures');
    RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*Checking for Structural changes in indicators*/
  l_kpi_flag := BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure;
  open indicators_cursor;
  fetch indicators_cursor bulk collect into l_indicator_table;
  if indicators_cursor%ISOPEN THEN
    CLOSE indicators_cursor;
  end if;
  for i in 1..l_indicator_table.count loop
      BSC_DESIGNER_PVT.ActionFlag_Change(l_indicator_table(i), l_kpi_flag);
  end loop;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    IF(indicators_cursor%ISOPEN) THEN
           CLOSE indicators_cursor;
    END IF;

    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (   p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_UPD_TO_FORMULA;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN

    IF(indicators_cursor%ISOPEN) THEN
        CLOSE indicators_cursor;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_MEASURE_PUB.Upd_Sing_To_Formula ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_MEASURE_PUB.Upd_Sing_To_Formula ';
    END IF;

    ROLLBACK TO SP_UPD_TO_FORMULA;
END Update_Single_To_Formula;


procedure Update_Measure(
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE
  ,p_dataset_id                     IN NUMBER
  ,p_dataset_source                 IN VARCHAR2
  ,p_dataset_name                   IN VARCHAR2
  ,p_dataset_help                   IN VARCHAR2 := NULL
  ,p_dataset_measure_id1            IN NUMBER   := NULL
  ,p_dataset_operation              IN VARCHAR2 := NULL
  ,p_dataset_measure_id2            IN NUMBER   := NULL
  ,p_dataset_format_id              IN NUMBER   := NULL
  ,p_dataset_color_method           IN NUMBER   := NULL
  ,p_dataset_autoscale_flag         IN NUMBER   := NULL
  ,p_dataset_projection_flag        IN NUMBER   := NULL
  ,p_measure_short_name             IN VARCHAR2
  ,p_region_app_id                  IN Ak_Region_Items.REGION_APPLICATION_ID%Type    := -1
  ,p_source_column_app_id           IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_compare_column_app_id          IN Ak_Region_Items.ATTRIBUTE_APPLICATION_ID%Type := -1
  ,p_measure_act_data_src_type      IN VARCHAR2 := NULL
  ,p_measure_act_data_src           IN VARCHAR2 := NULL
  ,p_measure_comparison_source      IN VARCHAR2 := NULL
  ,p_measure_operation              IN VARCHAR2 := c_SUM
  ,p_measure_uom_class              IN VARCHAR2 := NULL
  ,p_measure_increase_in_measure    IN VARCHAR2 := NULL
  ,p_measure_random_style           IN NUMBER   := NULL
  ,p_measure_min_act_value          IN NUMBER   := NULL
  ,p_measure_max_act_value          IN NUMBER   := NULL
  ,p_measure_min_bud_value          IN NUMBER   := NULL
  ,p_measure_max_bud_value          IN NUMBER   := NULL
  ,p_measure_app_id                 IN NUMBER   := NULL
  ,p_measure_col                    IN VARCHAR2 := NULL
  ,p_measure_col_help               IN VARCHAR2 := NULL
  ,p_measure_group_id               IN NUMBER   := NULL
  ,p_measure_projection_id          IN NUMBER   := NULL
  ,p_measure_type                   IN NUMBER   := NULL
  ,p_measure_apply_rollup           IN VARCHAR2 := NULL
  ,p_measure_function_name          IN VARCHAR2 := NULL
  ,p_measure_enable_link            IN VARCHAR2 := NULL
  ,p_measure_obsolete               IN VARCHAR2 := FND_API.G_FALSE
  ,p_type                           IN VARCHAR2 := NULL -- This is used for weighted kpis,This can take values CDS_SCORE,CDS_PERF or Null
  ,p_measure_is_validate            IN VARCHAR2 := FND_API.G_TRUE -- ankgoel: bug#3557236
  ,p_time_stamp                     IN VARCHAR2 := NULL    -- Added for Granular Locking
  ,p_dimension1_id                  IN NUMBER
  ,p_dimension2_id                  IN NUMBER
  ,p_dimension3_id                  IN NUMBER
  ,p_dimension4_id                  IN NUMBER
  ,p_dimension5_id                  IN NUMBER
  ,p_dimension6_id                  IN NUMBER
  ,p_dimension7_id                  IN NUMBER
  ,p_y_axis_title                   IN VARCHAR2 := NULL
  ,p_owner                          IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  ,p_ui_flag                        IN VARCHAR2
  ,p_last_update_date               IN BIS_INDICATORS.LAST_UPDATE_DATE%TYPE
  ,p_func_area_short_name           IN VARCHAR2 := NULL
  ,x_return_status                  OUT NOCOPY VARCHAR2
  ,x_msg_count                      OUT NOCOPY NUMBER
  ,x_msg_data                       OUT NOCOPY VARCHAR2
) is

    l_Dataset_Rec           BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
    l_Dataset_Rec_db        BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
    l_measure_rec           BIS_MEASURE_PUB.Measure_rec_type;
    l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_measure_col_help      VARCHAR2(150);
    l_old_measure_id        NUMBER;
    l_count                 NUMBER;

    l_measure_group_id      BSC_DB_MEASURE_COLS_TL.Measure_Group_Id%TYPE;
    l_projection_id         BSC_DB_MEASURE_COLS_TL.Projection_Id%TYPE;
    l_measure_type          BSC_DB_MEASURE_COLS_TL.Measure_Type%TYPE;

    l_Del_Dataset_Rec       BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
    l_Delete_Source         BOOLEAN;
    l_Dataset_Name          BSC_SYS_DATASETS_VL.Name%TYPE;
    l_Same_Name             BOOLEAN := FALSE;

    l_last_update_date      BIS_INDICATORS.LAST_UPDATE_DATE%TYPE;

    -- Added for Bug#4617140
    l_Old_Measure_Col       BSC_SYS_MEASURES.MEASURE_COL%TYPE;
    l_Old_Measure_Id1       BSC_SYS_DATASETS_B.MEASURE_ID1%TYPE;
    l_Old_Measure_Id2       BSC_SYS_DATASETS_B.MEASURE_ID2%TYPE;
    l_Is_Converted_To_Formula_Type BOOLEAN;
    l_Report_Objectives     VARCHAR2(2000);

    CURSOR  c_measure_col_cur( c_measure_col_name VARCHAR2 ) IS
    SELECT  measure_group_id
         ,  projection_id
         ,  measure_type
         ,  help
    FROM    bsc_db_measure_cols_vl
    WHERE   measure_col = c_measure_col_name;

    CURSOR  c_Bsc_Measure_Color_Formula IS
    SELECT  s_Color_Formula
          , Measure_Col
    FROM    BSC_SYS_MEASURES
    WHERE   Measure_Id = l_Dataset_Rec.Bsc_Measure_Id;

    CURSOR  c_Dataset_Measures IS
    SELECT  MEASURE_ID1
          , MEASURE_ID2
    FROM    BSC_SYS_DATASETS_B
    WHERE   DATASET_ID = p_dataset_id;

    CURSOR c_Bsc_Dataset_Name IS
    SELECT NAME
    FROM   BSC_SYS_DATASETS_VL
    WHERE  DATASET_ID = p_dataset_id;

    CURSOR c_Bis_Measure_Name IS
    SELECT NAME
    FROM   BIS_INDICATORS_VL
    WHERE  DATASET_ID = p_dataset_id;

    CURSOR c_Intial_Formula_Content IS
    SELECT D.MEASURE_ID1, D.MEASURE_ID2, M.MEASURE_COL
    FROM   BSC_SYS_DATASETS_B D, BSC_SYS_MEASURES M
    WHERE  D.DATASET_ID = p_Dataset_ID
    AND    M.MEASURE_ID = D.MEASURE_ID1;

begin
    SAVEPOINT SP_UPDATE_MEASURE;
    x_return_status        :=  FND_API.G_RET_STS_SUCCESS;
    fnd_msg_pub.initialize;

    l_Dataset_Rec.Bsc_dataset_id := p_dataset_id;
    l_Dataset_Rec.Bsc_Source := p_dataset_source;
    l_Dataset_Rec.Bsc_Dataset_Help := p_dataset_help;
    l_Dataset_Rec.Bsc_Measure_Id := p_dataset_measure_id1;
    l_Dataset_Rec.Bsc_Measure_Id2 := p_dataset_measure_id2;
    l_Dataset_Rec.Bsc_Dataset_Format_Id := p_dataset_format_id;
    l_Dataset_Rec.Bsc_Dataset_Color_Method := p_dataset_color_method;
    l_Dataset_Rec.Bsc_Dataset_Autoscale_Flag := p_dataset_autoscale_flag;
    l_Dataset_Rec.Bsc_Dataset_Projection_Flag := p_dataset_projection_flag;
    l_Dataset_Rec.Bsc_Dataset_Operation := p_dataset_operation;
    l_Dataset_Rec.Bsc_y_axis_Title := p_y_axis_title;

    --sawu: populate WHO column
    l_last_update_date := nvl(p_last_update_date, sysdate);

    l_Dataset_Rec.Bsc_Dataset_Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
    l_Dataset_Rec.Bsc_Dataset_Last_Update_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
    l_Dataset_Rec.Bsc_Dataset_Last_Update_Login := fnd_global.LOGIN_ID;
    l_Dataset_Rec.Bsc_Dataset_Last_Update_Date := l_last_update_date;

    l_Dataset_Rec.Bsc_Measure_Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
    l_Dataset_Rec.Bsc_Measure_Last_Update_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
    l_Dataset_Rec.Bsc_Measure_Last_Update_Login := fnd_global.LOGIN_ID;
    l_Dataset_Rec.Bsc_Measure_Last_Update_Date := l_last_update_date;

    if p_measure_short_name is null then
        l_Dataset_Rec.Bsc_Measure_Short_Name := c_PMD || p_Dataset_id;
    else
        if(p_dataset_source = c_BSC) then
        l_Dataset_Rec.Bsc_Measure_Short_Name := trim(p_measure_short_name);
        else
            l_Dataset_Rec.Bsc_Measure_Short_Name := p_measure_short_name;
        end if;
    end if;

    /****************************************************************
      We need to Check if the display name was changed by the user.
      If yes then only call the uniqueness check of measure display names.
    *****************************************************************/
    IF(l_Dataset_Rec.Bsc_Source = c_PMF) THEN
       FOR cd_Bis_Name IN c_Bis_Measure_Name LOOP
          l_Dataset_Name := cd_Bis_Name.Name;
          IF(l_Dataset_Name= p_dataset_name) THEN
             l_Same_Name := TRUE;
          END IF;
       END LOOP;
    ELSE
        FOR cd_Bsc_Name IN c_Bsc_Dataset_Name LOOP
             l_Dataset_Name := cd_Bsc_Name.Name;
             IF(l_Dataset_Name= p_dataset_name) THEN
               l_Same_Name := TRUE;
             END IF;
        END LOOP;
    END IF;

    IF(NOT l_Same_Name) THEN
       BSC_BIS_MEASURE_PUB.get_Measure_Name
        (       p_dataset_id        =>    NVL(l_Dataset_Rec.Bsc_dataset_id, -1)
            ,   p_ui_flag           =>    p_ui_flag
            ,   p_dataset_source    =>    p_dataset_source
            ,   p_dataset_name      =>    p_dataset_name
            ,   x_measure_name      =>    l_measure_rec.Measure_Name
        );
    ELSE
        l_measure_rec.Measure_Name := p_dataset_name;
    END IF;

    l_Dataset_Rec.Bsc_Dataset_Name  := l_measure_rec.Measure_Name;
    /******************************************/
    l_Dataset_Rec.Bsc_Measure_Long_Name := l_Dataset_Rec.Bsc_Dataset_Name;

    l_Dataset_Rec.Bsc_Measure_Projection_Id := p_measure_projection_id;

    -- added for Bug#3238554, to ensure that the value is passed to lower APIs.
    l_Dataset_Rec.Bsc_Measure_Type          := p_measure_type;

    -- added for Bug#3528425 - ensure Bsc_Measure_Group_Id is passed to lower APIs
    l_Dataset_Rec.Bsc_Measure_Group_Id := p_measure_group_id;

    l_Dataset_Rec.Bsc_Measure_Random_Style := p_measure_random_style;
    l_Dataset_Rec.Bsc_Measure_Max_Act_Value := p_measure_max_act_value;
    l_Dataset_Rec.Bsc_Measure_Max_Bud_Value := p_measure_max_bud_value;
    l_Dataset_Rec.Bsc_Measure_Min_Act_Value := p_measure_min_act_value;
    l_Dataset_Rec.Bsc_Measure_Min_Bud_Value := p_measure_min_bud_value;

    if p_measure_operation is null then
        l_Dataset_Rec.Bsc_Measure_Operation := c_SUM;
    else
        l_Dataset_Rec.Bsc_Measure_Operation := p_measure_operation;
    end if;

    -- 1.) Need to place this line after l_Dataset_Rec.Bsc_Measure_Col is set
    -- 2.) Need to place this line after l_Dataset_Rec.Bsc_Measure_Operation is set
    IF ( c_Bsc_Measure_Color_Formula%ISOPEN) THEN
        CLOSE c_Bsc_Measure_Color_Formula;
    END IF;
    OPEN  c_Bsc_Measure_Color_Formula;
      FETCH c_Bsc_Measure_Color_Formula
      INTO l_Dataset_Rec.Bsc_Measure_color_formula
          ,l_Dataset_Rec.Bsc_Measure_Col;
    CLOSE c_Bsc_Measure_Color_Formula;
    l_Dataset_Rec.Bsc_Measure_color_formula := getColorFormula(l_Dataset_Rec, p_measure_apply_rollup);

    IF (p_measure_col IS NOT NULL) THEN
        l_Dataset_Rec.Bsc_Measure_Col := p_measure_col;
    END IF;

    if (l_Dataset_Rec.Bsc_Measure_operation = c_AVGL_CODE) then
        l_Dataset_Rec.Bsc_Measure_operation := 'AVG';
    end if;


    -- ADRAO: Added for Bug#4617140
    FOR cIFC IN c_Intial_Formula_Content LOOP
        l_Old_Measure_Col := cIFC.MEASURE_COL;
        l_Old_Measure_Id1 := cIFC.MEASURE_ID1;
        l_Old_Measure_Id2 := cIFC.MEASURE_ID2;
    END LOOP;

    l_Is_Converted_To_Formula_Type := FALSE;

    IF((NOT isFormula(l_Old_Measure_Col)) AND (l_Old_Measure_Id2 IS NULL) AND (p_Dataset_Source = 'BSC')) THEN
        IF(isFormula(p_Measure_Col) OR (p_Dataset_Measure_Id2 IS NOT NULL)) THEN
            l_Is_Converted_To_Formula_Type := TRUE;
        END IF;
    END IF;

    IF (l_Is_Converted_To_Formula_Type) THEN
        l_Report_Objectives := Get_Report_Objectives(p_Dataset_Id);
        IF (l_Report_Objectives IS NOT NULL) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_KPI_NON_FORMULA_FOR_AGRPT');
            FND_MESSAGE.SET_TOKEN('OBJECTIVES',  l_Report_Objectives);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF ;

    -- START Granular Locking
    --DBMS_OUTPUT.PUT_LINE('calling BSC_BIS_LOCKS_PUB.LOCK_UPDATE_MEASURE');
    BSC_BIS_LOCKS_PUB.LOCK_UPDATE_MEASURE(
       p_dataset_id      =>  l_Dataset_Rec.Bsc_dataset_id
      ,p_time_stamp      =>  p_time_stamp
      ,x_return_status   =>  x_return_status
      ,x_msg_count       =>  x_msg_count
      ,x_msg_data        =>  x_msg_data
    ) ;

    -- The APIs should check for return status ...
    -- Raising an unexpected error.
    IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at BSC_BIS_LOCKS_PUB.LOCK_UPDATE_MEASURE');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- END Granular Locking

    -- Fix for Bug#3781176
    /*
     The following logic ensures that no dangling entries in bsc_sys_measures
     remains within the system. When one Measure (bsc_sys_datasets_b) has its datasource
     changed, then we need to delete it during update and ensure that it is not orphened
     i.e its achieved using the Delete_Measures from the Private datasets package (BSC_DATASETS_PVT)
    */

    l_Delete_Source := FALSE;

    FOR cDM IN c_Dataset_Measures LOOP
      l_Del_Dataset_Rec.Bsc_Measure_Id  := cDM.MEASURE_ID1;
      l_Del_Dataset_Rec.Bsc_Measure_Id2 := cDM.MEASURE_ID2;
    END LOOP;

    -- we need to execute this only if whats coming from UI is different as in the DB.
    IF (l_Del_Dataset_Rec.Bsc_Measure_Id IS NOT NULL) THEN
       IF((l_Del_Dataset_Rec.Bsc_Measure_Id = NVL(p_Dataset_Measure_Id1, l_Del_Dataset_Rec.Bsc_Measure_Id))) THEN
         l_Del_Dataset_Rec.Bsc_Measure_Id := NULL;
       END IF;

       IF (l_Del_Dataset_Rec.Bsc_Measure_Id2 IS NOT NULL) THEN
          IF((l_Del_Dataset_Rec.Bsc_Measure_Id2 = NVL(p_Dataset_Measure_Id2, l_Del_Dataset_Rec.Bsc_Measure_Id2))) THEN
             l_Del_Dataset_Rec.Bsc_Measure_Id2 := NULL;
          END IF;
       END IF;

       IF (l_Del_Dataset_Rec.Bsc_Measure_Id IS NOT NULL) THEN
           l_Delete_Source := TRUE;
       ELSE
          IF (l_Del_Dataset_Rec.Bsc_Measure_Id2 IS NOT NULL) THEN
             -- We cannot pass NULL for measure_id1 in the lower APIS
             -- and p_Dataset_Measure_Id1 can never be null (otherwise lower API will raise an exception)
             l_Del_Dataset_Rec.Bsc_Measure_Id := p_Dataset_Measure_Id1;
             l_Delete_Source := TRUE;
          END IF;
       END IF;
    END IF;

    /*
    Should check if present change is from Single Source Column to Formula based measure then
    a new Measure Record should be inserted in bsc_sys_measures
    */


    BSC_DATASETS_PUB.Retrieve_Measures(
         p_commit => p_commit
        ,p_Dataset_Rec => l_Dataset_Rec
        ,x_Dataset_Rec => l_Dataset_Rec_db
        ,x_return_status => x_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data
    );

    IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- added an additional condition 'Is_Src_Col_In_Formulas' for Bug#5071121
    IF  ((NOT isFormula(l_Dataset_Rec_db.Bsc_Measure_Col)) AND
         (isFormula(l_Dataset_Rec.Bsc_Measure_Col)) AND
          Is_Src_Col_In_Formulas(l_Dataset_Rec_db.Bsc_Measure_Col)) THEN
    /*Create a new entry in BSC_SYS_MEASURES if a Single Source Column is being changed to a Formula
    of A+B type while the source column is being used in other Formula. Then associate this new Measure Id
    as the Measure Id1 of the dataset*/
    BSC_BIS_MEASURE_PUB.Update_Single_To_Formula(
        p_commit => p_commit
       ,p_Dataset_Rec => l_Dataset_Rec
       ,p_Dataset_Rec_db => l_Dataset_Rec_db
       ,x_return_status => x_return_status
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data
        );
         IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;


    ELSE

    -- Update the Dataset and Measure Record
    --DBMS_OUTPUT.PUT_LINE('calling BSC_DATASETS_PUB.Update_Measures <'||x_msg_data||'>');
    BSC_DATASETS_PUB.Update_Measures(
       p_commit => p_commit
      ,p_Dataset_Rec => l_Dataset_Rec
      ,p_update_dset_calc => false
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data);

    IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at BSC_DATASETS_PUB.Update_Measures');
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    END IF;

    -- Fix for Bug#3781176
    -- Delete the source columns that may no more be used and are dangling
    -- This is called after update, since the API checks if the passed measure_id is being used or not.
    IF (l_Delete_Source = TRUE) THEN
       -- this API deletes only the source columns (bsc_sys_measures) and not the actual measure itself.
       BSC_DATASETS_PVT.Delete_Measures(
          p_commit         => p_commit
         ,p_Dataset_Rec    => l_Del_Dataset_Rec
         ,x_return_status  => x_return_status
         ,x_msg_count      => x_msg_count
         ,x_msg_data       => x_msg_data
       );
       IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    -- relaxed update condition for DB columns for all types of measures
    -- Enhancement Bug#4239216
        IF ( c_measure_col_cur%ISOPEN) THEN
          CLOSE c_measure_col_cur;
        END IF;

        OPEN c_measure_col_cur(l_Dataset_Rec.Bsc_Measure_Col);

        -- Moved the fetch cursor before the IF condition to ensure that
        -- the IF condition is satisified when the cursor has rows.
        -- fixed for Bug#3284277

        FETCH c_measure_col_cur
        INTO  l_measure_group_id, l_projection_id, l_measure_type, l_measure_col_help;

        if (c_measure_col_cur%FOUND) then

            -- when changing the measure from formula to single col
            -- measure group id, projection id and measure type is passed null
            -- retrieving from the BSC_DB_MEASURE_C0LS_VL
            -- Bug#3237284

            -- Bug#3817894: Update the Measure columns
            IF ((p_Measure_Col_Help IS NOT NULL) AND (p_Measure_Col_Help <> l_Measure_Col_Help)) THEN
               l_Measure_Col_Help := p_Measure_Col_Help;
            END IF;

             --DBMS_OUTPUT.PUT_LINE('calling bsc_db_measure_cols_pkg.update_row');
             BSC_DB_MEASURE_COLS_PKG.Update_Row
             (     x_Measure_Col       =>  l_Dataset_Rec.Bsc_Measure_Col
                ,  x_Measure_Group_Id  =>  NVL(p_measure_group_id,                     l_measure_group_id)
                ,  x_Projection_Id     =>  NVL(l_Dataset_Rec.Bsc_Measure_Projection_Id,l_projection_id)
                ,  x_Measure_Type      =>  NVL(p_Measure_Type,                         l_measure_type)
                ,  x_Help              =>  NVL(l_measure_col_help, l_Dataset_Rec.Bsc_Measure_Col)
              );
             IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
                    --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at bsc_db_measure_cols_pkg.update_row');
                 RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
        else
              IF NOT (isFormula(l_Dataset_Rec.Bsc_Measure_Col) OR l_Dataset_Rec.Bsc_Source = c_CDS) THEN
                  --DBMS_OUTPUT.PUT_LINE('calling bsc_db_measure_cols_pkg.insert_row');
                  bsc_db_measure_cols_pkg.insert_row(
                       l_Dataset_Rec.Bsc_Measure_Col
                      ,p_measure_group_id
                      ,l_Dataset_Rec.Bsc_Measure_Projection_Id
                      ,p_Measure_Type
                      ,l_measure_col_help);
                    IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
                      --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at bsc_db_measure_cols_pkg.insert_row');
                      RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
          end if;
        end if;

        -- close the cursor c_measure_col_cur  - Bug#3237284
        CLOSE c_measure_col_cur;


    -- Update PMF tables
    begin
        select  pm.measure_id
        into    l_Measure_Rec.Measure_Id
        from bisbv_performance_measures pm
        where dataset_id = p_dataset_id;
    exception
        when no_data_found then l_Measure_Rec.Measure_Id := null;
    end;

    --- mdamle 07/07/2003 - Added indicator dimensions
    l_Measure_rec.Dimension1_Id := p_Dimension1_id;
    l_Measure_rec.Dimension2_Id := p_Dimension2_id;
    l_Measure_rec.Dimension3_Id := p_Dimension3_id;
    l_Measure_rec.Dimension4_Id := p_Dimension4_id;
    l_Measure_rec.Dimension5_Id := p_Dimension5_id;
    l_Measure_rec.Dimension6_Id := p_Dimension6_id;
    l_Measure_rec.Dimension7_Id := p_Dimension7_id;

    l_measure_rec.Dataset_id := p_dataset_id;
    l_measure_rec.Measure_Short_Name := l_Dataset_Rec.Bsc_Measure_Short_Name;

    l_measure_rec.Description := p_dataset_help;
    l_measure_rec.Unit_Of_Measure_Class := p_measure_uom_class;
    l_measure_rec.actual_data_source_type := p_measure_act_data_src_type ;
    l_measure_rec.actual_data_source := p_measure_act_data_src;
    l_measure_rec.comparison_source := p_measure_comparison_source;
    l_measure_rec.increase_in_measure := p_measure_increase_in_measure;
    l_measure_rec.function_name := p_measure_function_name;
    l_measure_rec.enable_link := p_measure_enable_link;
    l_measure_rec.obsolete  := p_measure_obsolete;
    l_measure_rec.measure_type  := p_type;
    l_measure_rec.is_validate := p_measure_is_validate;

    --sawu: 9/1/04: populates region_app_id and attribute_code_app_id for ak_region_items also
    l_measure_rec.Region_App_Id         := p_region_app_id;
    l_measure_rec.Source_Column_App_Id  := p_source_column_app_id;
    l_measure_rec.Compare_Column_App_Id := p_compare_column_app_id;

    --sawu: populate WHO column
    l_measure_rec.Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
    l_measure_rec.Last_Updated_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
    l_measure_rec.Last_Update_Login := fnd_global.LOGIN_ID;
    l_measure_rec.Last_Update_Date := l_last_update_date;

    --rpenneru: 12/22/04 Populate Functional Area Short name
    l_measure_rec.Func_Area_Short_Name := p_func_area_short_name;

    if (p_measure_app_id is null) then
        l_measure_rec.Application_Id := 271;
    else
        l_measure_rec.Application_Id := p_measure_app_id;
    end if;
    if (l_Measure_Rec.Measure_id is not null) then
        --DBMS_OUTPUT.PUT_LINE('calling BIS_MEASURE_PUB.Update_Measure');
        BIS_MEASURE_PUB.Update_Measure(
             p_api_version   => 1.0
                     ,p_commit        => p_commit
                 ,p_Measure_Rec   => l_measure_rec
                 ,p_owner         => p_owner
                 ,x_return_status => x_return_status
                     ,x_error_tbl     => l_error_tbl);
        IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
            IF (l_error_tbl.COUNT > 0) THEN
                x_msg_data  :=  l_error_tbl(l_error_tbl.COUNT).Error_Description;
                IF(INSTR(x_msg_data, ' ')  =  0 ) THEN
                    FND_MESSAGE.SET_NAME('BIS',x_msg_data);
                    FND_MSG_PUB.ADD;
                    x_msg_data  :=  NULL;
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at BIS_MEASURE_PUB.Update_Measure');
            RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    else
        -- Normally, PMF measure should always exist once BSC measure was created.
        -- Code should not reach here under normal circumstances.
        --DBMS_OUTPUT.PUT_LINE('calling BIS_MEASURE_PUB.Create_Measure');
        BIS_MEASURE_PUB.Create_Measure(
             p_api_version   => 1.0
                        ,p_commit        => p_commit
                        ,p_Measure_Rec   => l_measure_rec
                        ,p_owner         => p_owner
                        ,x_return_status => x_return_status
                        ,x_error_tbl     => l_error_tbl);
        IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
            IF (l_error_tbl.COUNT > 0) THEN
                x_msg_data  :=  l_error_tbl(l_error_tbl.COUNT).Error_Description;
                IF(INSTR(x_msg_data, ' ')  =  0 ) THEN
                    FND_MESSAGE.SET_NAME('BIS',x_msg_data);
                    FND_MSG_PUB.ADD;
                    x_msg_data  :=  NULL;
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at BIS_MEASURE_PUB.Create_Measure');
            RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    end if;

    -- At this point, the Measures would have been updated.
    -- need to change the TimeStamps.

    -- START Granular Locking


    -- Change the time stamp of the Current Dataset (Measure)
    IF (l_Dataset_Rec.Bsc_dataset_id is not null) THEN
       --DBMS_OUTPUT.PUT_LINE('calling BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASET');
       BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASET(
          p_dataset_id      =>  l_Dataset_Rec.Bsc_dataset_id
         ,p_lud             =>  l_Dataset_Rec.Bsc_Dataset_Last_Update_Date
         ,x_return_status   =>  x_return_status
         ,x_msg_count       =>  x_msg_count
         ,x_msg_data        =>  x_msg_data
       ) ;

       IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
         --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASET');
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;
    -- Change the time stamp of the Current Datasource (1)
    IF (l_Dataset_Rec.Bsc_Measure_Id is not null) THEN
       --DBMS_OUTPUT.PUT_LINE('calling BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASOURCE');
       BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASOURCE(
          p_measure_id      =>  l_Dataset_Rec.Bsc_Measure_Id
         ,p_lud             =>  l_Dataset_Rec.Bsc_Dataset_Last_Update_Date
         ,x_return_status   =>  x_return_status
         ,x_msg_count       =>  x_msg_count
         ,x_msg_data        =>  x_msg_data
       ) ;

       IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
         --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASOURCE');
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;
    -- Change the time stamp of the Current Datasource (2)
    IF (l_Dataset_Rec.Bsc_Measure_Id2 is not null) THEN
       --DBMS_OUTPUT.PUT_LINE('calling BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASOURCE');
       BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASOURCE(
          p_measure_id      =>  l_Dataset_Rec.Bsc_Measure_Id2
         ,p_lud             =>  l_Dataset_Rec.Bsc_Dataset_Last_Update_Date
         ,x_return_status   =>  x_return_status
         ,x_msg_count       =>  x_msg_count
         ,x_msg_data        =>  x_msg_data
       ) ;
       IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
          --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASOURCE');
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;
    -- END Granular Locking

    --DBMS_OUTPUT.PUT_LINE('calling BSC_UTILITY.Add_To_Fnd_Msg_Stack');
    BSC_UTILITY.Add_To_Fnd_Msg_Stack(
         p_error_tbl       => l_error_tbl
         ,x_return_status   => x_return_status
         ,x_msg_count       => x_msg_count
         ,x_msg_data        => x_msg_data);
    IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
      --DBMS_OUTPUT.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.BSC_BIS_MEASURE_PUB Failed: at BSC_UTILITY.Add_To_Fnd_Msg_Stack');
      RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF ( c_measure_col_cur%ISOPEN) THEN
      CLOSE c_measure_col_cur;
    END IF;
    IF ( c_Bsc_Measure_Color_Formula%ISOPEN) THEN
        CLOSE c_Bsc_Measure_Color_Formula;
    END IF;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (   p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_UPDATE_MEASURE;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF ( c_measure_col_cur%ISOPEN) THEN
      CLOSE c_measure_col_cur;
    END IF;
    IF ( c_Bsc_Measure_Color_Formula%ISOPEN) THEN
        CLOSE c_Bsc_Measure_Color_Formula;
    END IF;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      (   p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_UPDATE_MEASURE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    IF ( c_measure_col_cur%ISOPEN) THEN
      CLOSE c_measure_col_cur;
    END IF;
    IF ( c_Bsc_Measure_Color_Formula%ISOPEN) THEN
        CLOSE c_Bsc_Measure_Color_Formula;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_MEASURE_PUB.Update_measure ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_MEASURE_PUB.Update_measure ';
    END IF;
    ROLLBACK TO SP_UPDATE_MEASURE;
  WHEN OTHERS THEN
    IF ( c_measure_col_cur%ISOPEN) THEN
      CLOSE c_measure_col_cur;
    END IF;
    IF ( c_Bsc_Measure_Color_Formula%ISOPEN) THEN
        CLOSE c_Bsc_Measure_Color_Formula;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_MEASURE_PUB.Update_measure ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_MEASURE_PUB.Update_measure ';
    END IF;
    ROLLBACK TO SP_UPDATE_MEASURE;
end Update_measure;


procedure Delete_measure(
   p_commit                     IN VARCHAR2 := FND_API.G_FALSE
  ,p_dataset_id             IN NUMBER
  ,p_time_stamp                   IN         VARCHAR2   := NULL    -- Added for Granular Locking
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
) is

l_Dataset_Rec       BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
l_Measure_Rec       BIS_MEASURE_PUB.Measure_Rec_Type;
l_error_tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;
l_count         number;
l_Meas_Extn_Rec BIS_OBJECT_EXTENSIONS_PUB.Measure_Extension_Type;

begin
    fnd_msg_pub.initialize;

    l_Dataset_Rec.Bsc_dataset_id := p_dataset_id;

    -- START : Granular Locking Needs do come on the top.- Fixed by ADRAO
    BSC_BIS_LOCKS_PUB.LOCK_DELETE_MEASURE(
       p_dataset_id      =>  l_Dataset_Rec.Bsc_dataset_id
      ,p_time_stamp      =>  p_time_stamp
      ,x_return_status   =>  x_return_status
      ,x_msg_count       =>  x_msg_count
      ,x_msg_data        =>  x_msg_data
    ) ;
   -- Get the Measure Short Name
   SELECT short_name INTO l_Meas_Extn_Rec.Measure_Short_Name FROM bis_indicators WHERE dataset_id = p_dataset_id;


    -- Added measure_id2 to be passed to lower APIs Bug#3628113
    select measure_id1, measure_id2, pm.measure_id
    into l_Dataset_Rec.Bsc_Measure_Id, l_Dataset_Rec.Bsc_Measure_Id2, l_Measure_Rec.Measure_Id
    from bsc_sys_datasets_B d, bisbv_performance_measures pm
    where d.dataset_id = p_dataset_id
    and d.dataset_id = pm.dataset_id (+);


    -- The APIs should check for return status ...
    -- Raising an unexpected error.
    IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
        --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_SET_PUB.CREATE_DIM_SET Failed: at BSC_DIMENSION_SETS_PUB.Create_Bsc_Kpi_Dim_Sets_Tl');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- END : Granular Locking

    BSC_DATASETS_PUB.Delete_Measures(
         p_commit => p_commit
        ,p_Dataset_Rec => l_Dataset_Rec
        ,x_return_status => x_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data);

    IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS) OR (x_return_status IS NULL) ) THEN
    -- Delete from PMF tables
      IF (l_Measure_Rec.Measure_Id IS NOT NULL) THEN
        BIS_MEASURE_PUB.Delete_Measure(
         p_api_version => 1.0
        ,p_commit => p_commit
        ,p_Measure_Rec => l_Measure_Rec
        ,x_return_status => x_return_status
        ,x_error_Tbl => l_error_tbl);

        BSC_UTILITY.Add_To_Fnd_Msg_Stack(
         p_error_tbl       => l_error_tbl
        ,x_return_status   => x_return_status
        ,x_msg_count       => x_msg_count
        ,x_msg_data        => x_msg_data);
      END IF;
    END IF;
    -- Checks if the Functional Area exists
     SELECT
         COUNT(1) INTO l_count
     FROM
        BIS_MEASURES_EXTENSION_VL
     WHERE
        MEASURE_SHORT_NAME = l_Meas_Extn_Rec.Measure_Short_Name;
    -- If Functional Area Exists then removes that
      IF (l_count > 0) THEN
        BIS_OBJECT_EXTENSIONS_PUB.Delete_Measure_Extension(
          p_Api_Version   =>1.0
         ,p_Commit        => p_commit
         ,p_Meas_Extn_Rec => l_Meas_Extn_Rec
         ,x_Return_Status => x_Return_Status
         ,x_Msg_Count     => x_Msg_Count
         ,x_Msg_Data      => x_Msg_Data
       );
     END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := SQLERRM;
    end if;
end delete_measure;


/************************************************************************************
--	API name 	: Cascade_Disable_Calculation
--	Type		: Private
************************************************************************************/
PROCEDURE Cascade_Disable_Calculation(
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE
 ,p_dataset_id            IN   NUMBER
 ,p_disabled_calculation  IN   NUMBER
 ,x_return_status         OUT NOCOPY   VARCHAR2
 ,x_msg_count             OUT NOCOPY   NUMBER
 ,x_msg_data              OUT NOCOPY   VARCHAR2
) IS

  l_kpi_measure_props_rec bsc_kpi_measure_props_pub.kpi_measure_props_rec;
  l_kpi_measure_id bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE;

  CURSOR c_kpis IS
  SELECT
    km.indicator,
    km.analysis_option0,
    km.analysis_option1,
    km.analysis_option2,
    km.series_id
  FROM
    bsc_kpi_analysis_measures_b km,
    bsc_kpi_measure_props kp
  WHERE
    kp.indicator = km.indicator AND
    kp.kpi_measure_id = km.kpi_measure_id AND
    km.dataset_id = p_dataset_id AND
    kp.default_calculation IS NOT NULL AND
    kp.default_calculation = p_disabled_calculation;

BEGIN

  SAVEPOINT  Cascade_Disable_Calc_PUB;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  FOR cd IN c_kpis LOOP
    BSC_KPI_SERIES_PUB.Save_Default_Calculation(
      p_commit              =>  FND_API.G_FALSE
     ,p_Indicator           =>  cd.indicator
     ,p_Analysis_Option0    =>  cd.analysis_option0
     ,p_Analysis_Option1    =>  cd.analysis_option1
     ,p_Analysis_Option2    =>  cd.analysis_option2
     ,p_Series_Id           =>  cd.series_id
     ,p_default_calculation =>  NULL
     ,x_return_status       =>  x_return_status
     ,x_msg_count           =>  x_msg_count
     ,x_msg_data            =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;

  IF FND_API.To_Boolean(p_Commit) THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Cascade_Disable_Calc_PUB;
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Cascade_Disable_Calc_PUB;
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO Cascade_Disable_Calc_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Cascade_Disable_Calculation ';
    ELSE
        x_msg_data      :=  SQLERRM||'BSC_KPI_SERIES_PUB.Cascade_Disable_Calculation ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO Cascade_Disable_Calc_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' ->BSC_KPI_SERIES_PUB.Cascade_Disable_Calculation ';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_KPI_SERIES_PUB.Cascade_Disable_Calculation ';
    END IF;
END Cascade_Disable_Calculation;

procedure Apply_Dataset_Calc(
   p_commit                     IN VARCHAR2 := FND_API.G_FALSE
  ,p_dataset_id             IN NUMBER
  ,p_disabled_calc_table        IN BSC_NUM_LIST
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count              OUT NOCOPY NUMBER
  ,x_msg_data               OUT NOCOPY VARCHAR2
) is

l_Dataset_Rec       BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
begin

    fnd_msg_pub.initialize;

    l_Dataset_Rec.Bsc_Dataset_Id:= p_dataset_id;

    -- Disabled Calculations
    BSC_DATASETS_PUB.Delete_Dataset_Calc(
         p_commit => p_commit
        ,p_Dataset_Rec => l_Dataset_Rec
        ,x_return_status => x_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data);

    if p_disabled_calc_table is not null then
        for i in 1..p_disabled_calc_table.count loop
            l_Dataset_Rec.Bsc_Disabled_Calc_Id := p_disabled_calc_table(i);
            BSC_DATASETS_PVT.Create_Dataset_Calc(
                 p_commit => p_commit
                ,p_Dataset_Rec => l_Dataset_Rec
                ,x_return_status => x_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data => x_msg_data);

            Cascade_Disable_Calculation(
              p_commit               =>  FND_API.G_FALSE
             ,p_dataset_id           =>  p_dataset_id
             ,p_disabled_calculation =>  p_disabled_calc_table(i)
             ,x_return_status        =>  x_return_status
             ,x_msg_count            =>  x_msg_count
             ,x_msg_data             =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        end loop;
    end if;

    -- Change the time stamp of the Current Dataset (Measure)
    IF (p_dataset_id is not null) THEN
       BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASET(
          p_dataset_id      =>  p_dataset_id
         ,x_return_status   =>  x_return_status
         ,x_msg_count       =>  x_msg_count
         ,x_msg_data        =>  x_msg_data
       ) ;

       IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
           --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_SET_PUB.CREATE_DIM_SET Failed: at BSC_DIMENSION_SETS_PUB.Create_Bsc_Kpi_Dim_Sets_Tl');
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := SQLERRM;
    end if;
end Apply_Dataset_Calc;


PROCEDURE Apply_Cause_Effect_Rels(
  p_commit                  IN VARCHAR2 := FND_API.G_FALSE
 ,p_dataset_id              IN NUMBER
 ,p_causes_table            IN BSC_NUM_LIST
 ,p_effects_table           IN BSC_NUM_LIST
 ,x_return_status           OUT NOCOPY VARCHAR2
 ,x_msg_count               OUT NOCOPY NUMBER
 ,x_msg_data                OUT NOCOPY VARCHAR2
) is

l_Bsc_Cause_Effect_Rel_Rec  BSC_CAUSE_EFFECT_REL_PUB.Bsc_Cause_Effect_Rel_Rec;
l_measure_names     varchar2(32000);
l_name          bsc_sys_datasets_tl.name%TYPE;
l_max_count     number := 1500;
l_temp_dataset_id   NUMBER;
l_found             BOOLEAN;
CURSOR c_cause_list
IS
SELECT
  cause_indicator
FROM
  bsc_kpi_cause_effect_rels
WHERE
  effect_level = 'DATASET'
  AND effect_indicator = p_dataset_id;

CURSOR c_effect_list
IS
SELECT
  effect_indicator
FROM
  bsc_kpi_cause_effect_rels
WHERE
  cause_level = 'DATASET'
  AND cause_indicator = p_dataset_id;

begin

    fnd_msg_pub.initialize;

    -- mdamle 08/18/2003 - Check for same cause and effect measure
    if p_causes_table is not null and p_effects_table is not null then
        for i in 1..p_causes_table.count loop
            for j in 1..p_effects_table.count loop
            if p_effects_table(j) = p_causes_table(i) then
                select name into l_name
                from bsc_sys_datasets_vl
                where dataset_id =  p_causes_table(i);

                if (l_measure_names is null) then
                    l_measure_names := l_name;
                else
                        if(length(l_measure_names || ', ' || l_name) < l_max_count) then
                            l_measure_names := l_measure_names || ', ' || l_name;
                        end if;
                end if;
            end if;
        end loop;
    end loop;

        if l_measure_names is not null then
            FND_MESSAGE.SET_NAME('BSC','BSC_CAE_USED_AT_SAME_TIME');
        FND_MESSAGE.SET_TOKEN('LIST', l_measure_names);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
        end if;
    end if;

    OPEN  c_cause_list ;
    LOOP
      FETCH c_cause_list INTO l_temp_dataset_id;
      EXIT WHEN c_cause_list%NOTFOUND;
      IF p_causes_table IS NOT NULL THEN
          l_found := FALSE;
          FOR i IN 1..p_causes_table.COUNT LOOP
            IF(l_temp_dataset_id = p_causes_table(i)) THEN
              l_found := TRUE;
            END IF;
          END LOOP;
          IF NOT l_found THEN
              BIS_CUSTOM_CAUSE_EFFECT_PVT.Delete_Custom_Cause_Effect_Rel(
	          p_commit             => p_commit
	        , p_Cause_DataSetId    => l_temp_dataset_id
	        , p_Effect_DataSetId   => p_dataset_id
	        , x_return_status      => x_return_status
	        , x_msg_count          => x_msg_count
	        , x_msg_data           => x_msg_data
	      );
          END IF;
      END IF;
    END LOOP;
    CLOSE c_cause_list;


    OPEN  c_effect_list ;
    LOOP
      FETCH c_effect_list INTO l_temp_dataset_id;
      EXIT WHEN c_effect_list%NOTFOUND;
      IF p_effects_table IS NOT NULL THEN
          l_found := FALSE;
          FOR i IN 1..p_effects_table.COUNT LOOP
            IF(l_temp_dataset_id = p_effects_table(i)) THEN
              l_found := TRUE;
            END IF;
          END LOOP;
          IF NOT l_found THEN
            --Delete Customizations
              BIS_CUSTOM_CAUSE_EFFECT_PVT.Delete_Custom_Cause_Effect_Rel(
	          p_commit             => p_commit
	        , p_Cause_DataSetId    => p_dataset_id
	        , p_Effect_DataSetId   => l_temp_dataset_id
	        , x_return_status      => x_return_status
	        , x_msg_count          => x_msg_count
	        , x_msg_data           => x_msg_data
	      );
          END IF;
      END IF;
    END LOOP;
    CLOSE c_effect_list;

    BSC_CAUSE_EFFECT_REL_PUB.Delete_All_Cause_Effect_Rels(
         p_commit => p_commit
        ,p_indicator => p_dataset_id
        ,p_level => BSC_BIS_MEASURE_PUB.c_LEVEL
        ,x_return_status => x_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data);

    if p_causes_table is not null then
        for i in 1..p_causes_table.count loop
            l_Bsc_Cause_Effect_Rel_Rec.Cause_Indicator := p_causes_table(i);
            l_Bsc_Cause_Effect_Rel_Rec.Cause_Level := BSC_BIS_MEASURE_PUB.c_LEVEL;
            l_Bsc_Cause_Effect_Rel_Rec.Effect_Indicator := p_dataset_id;
            l_Bsc_Cause_Effect_Rel_Rec.Effect_Level := BSC_BIS_MEASURE_PUB.c_LEVEL;

            BSC_CAUSE_EFFECT_REL_PUB.Create_Cause_Effect_Rel(
                 p_commit => p_commit
                            ,p_Bsc_Cause_Effect_Rel_Rec => l_Bsc_Cause_Effect_Rel_Rec
                ,x_return_status => x_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data => x_msg_data);

        end loop;
    end if;


    if p_effects_table is not null then
        for i in 1..p_effects_table.count loop
            l_Bsc_Cause_Effect_Rel_Rec.Cause_Indicator := p_dataset_id;
            l_Bsc_Cause_Effect_Rel_Rec.Cause_Level := BSC_BIS_MEASURE_PUB.c_LEVEL;
            l_Bsc_Cause_Effect_Rel_Rec.Effect_Indicator := p_effects_table(i);
            l_Bsc_Cause_Effect_Rel_Rec.Effect_Level := BSC_BIS_MEASURE_PUB.c_LEVEL;

            BSC_CAUSE_EFFECT_REL_PUB.Create_Cause_Effect_Rel(
                 p_commit => p_commit
                            ,p_Bsc_Cause_Effect_Rel_Rec => l_Bsc_Cause_Effect_Rel_Rec
                ,x_return_status => x_return_status
                ,x_msg_count => x_msg_count
                ,x_msg_data => x_msg_data);

        end loop;
    end if;

    -- Change the time stamp of the Current Dataset (Measure)
    IF (p_dataset_id is not null) THEN
       BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASET(
          p_dataset_id      =>  p_dataset_id
         ,x_return_status   =>  x_return_status
         ,x_msg_count       =>  x_msg_count
         ,x_msg_data        =>  x_msg_data
       ) ;

       IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
           --DBMS_OUTPUT.PUT_LINE('BSC_BIS_DIM_SET_PUB.CREATE_DIM_SET Failed: at BSC_DIMENSION_SETS_PUB.Create_Bsc_Kpi_Dim_Sets_Tl');
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := SQLERRM;
    end if;
end Apply_Cause_Effect_Rels;



function getColorFormula(
     p_Dataset_Rec  IN  BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
    ,p_Measure_Apply_Rollup IN VARCHAR2) return varchar2
is
l_column_name           varchar2(30);
l_color_formula         varchar2(4000) := NULL;
begin
    if (p_Measure_apply_rollup is not null and p_Measure_apply_rollup = 'Y') then

        if (BSC_APPS.Get_Property_Value(p_dataset_rec.Bsc_Measure_color_formula, c_FORMULA_SOURCE) is null) then
            select BSC_INTERNAL_COLUMN_S.nextval into l_column_name from dual;
            l_column_name := c_INTERNAL_COLUMN_NAME || l_column_name;
            l_color_formula := BSC_APPS.Set_Property_Value(NULL, c_FORMULA_SOURCE, l_column_name);
        ELSE
            l_color_formula := SUBSTR(p_dataset_rec.Bsc_Measure_color_formula, 0, (INSTR(p_dataset_rec.Bsc_Measure_color_formula, '&')-1));
        END IF;
    else
        if (p_Dataset_Rec.Bsc_Measure_operation = c_AVGL_CODE) and isFormula(p_Dataset_Rec.Bsc_Measure_Col) then
            -- Do not allow this condition
                FND_MESSAGE.SET_NAME('BSC','BSC_AVGLOWESTLEVEL_ERR_TXT');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        end if;
    end if;

    -- Insert pAvgL=...
    if (p_Dataset_Rec.Bsc_Measure_operation = c_AVGL_CODE) then
        l_color_formula := BSC_APPS.Set_Property_Value(l_color_formula, c_AVGL, 'Y');
    else
        l_color_formula := BSC_APPS.Set_Property_Value(l_color_formula, c_AVGL, 'N');
    end if;

    return l_color_formula;

end getColorFormula;

--
-- 16-JUN-2003 Ravi added for Assign Dimension to KPI enh
--

FUNCTION GET_AO_NAME
(
        p_indicator     in  NUMBER
    ,   p_a0            in  NUMBER
    ,   p_a1            in  NUMBER
    ,   p_a2            in  NUMBER
    ,   p_group_id      in  NUMBER
) RETURN VARCHAR2 IS
    l_group_id      NUMBER;

    h_ag_count      NUMBER;
    l_anal_name     bsc_kpi_analysis_options_tl.name%TYPE := NULL; -- changed for bug 3165012
    h_ag1_depend    NUMBER;
    h_ag2_depend    NUMBER;
    h_ag_depend     NUMBER;
BEGIN
    l_group_id := p_group_id;

    SELECT  MAX( ANALYSIS_GROUP_ID)
    INTO    h_ag_count
    FROM    BSC_KPI_ANALYSIS_GROUPS
    WHERE   INDICATOR   =   p_indicator;

    IF (l_group_id= 0) THEN

        SELECT  NAME INTO l_anal_name
        FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
        WHERE   ANALYSIS_GROUP_ID =0
        AND     OPTION_ID = p_a0
        AND     INDICATOR = p_indicator;
    ELSIF(l_group_id =1 AND h_ag_count >0) THEN
        SELECT  DEPENDENCY_FLAG INTO h_ag_depend
        FROM    BSC_KPI_ANALYSIS_GROUPS
        WHERE   ANALYSIS_GROUP_ID =1
        AND     INDICATOR   =   p_indicator;

        IF h_ag_depend = 0 THEN
            SELECT  NAME INTO l_anal_name
            FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
            WHERE   ANALYSIS_GROUP_ID = 1
            AND     OPTION_ID   =   p_a1
            AND     INDICATOR   =   p_indicator;
        ELSE

            BEGIN
                SELECT  NAME INTO l_anal_name
                FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
                WHERE   ANALYSIS_GROUP_ID =1
                AND     OPTION_ID         = p_a1
                AND     PARENT_OPTION_ID  = p_a0
                AND     INDICATOR         = p_indicator;

            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
        END IF;
    ELSIF((l_group_id =2 AND h_ag_count >1)) THEN

        SELECT  DEPENDENCY_FLAG
        INTO    h_ag1_depend
        FROM    BSC_KPI_ANALYSIS_GROUPS
        WHERE   ANALYSIS_GROUP_ID =1
        AND     INDICATOR   =   p_indicator;

        SELECT  DEPENDENCY_FLAG
        INTO    h_ag2_depend
        FROM    BSC_KPI_ANALYSIS_GROUPS
        WHERE   ANALYSIS_GROUP_ID = 2
        AND     INDICATOR   =   p_indicator;

        IF h_ag2_depend = 0 THEN

            SELECT  NAME
            INTO    l_anal_name
            FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
            WHERE   ANALYSIS_GROUP_ID =2
            AND     OPTION_ID=p_a2
            AND     INDICATOR=p_indicator;
        ELSE
            IF h_ag2_depend = 1 AND h_ag1_depend = 0 THEN
                BEGIN
                    SELECT  NAME
                    INTO    l_anal_name
                    FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
                    WHERE   ANALYSIS_GROUP_ID   =   2
                    AND     OPTION_ID           =   p_a2
                    AND     PARENT_OPTION_ID    =   p_a1
                    AND     INDICATOR           =   p_indicator;
            EXCEPTION
                WHEN OTHERS
                    THEN NULL;
            END;
        ELSE
            BEGIN
                SELECT  NAME
                INTO    l_anal_name
                FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
                WHERE   ANALYSIS_GROUP_ID     = 2
                AND     OPTION_ID             = p_a2
                AND     PARENT_OPTION_ID      = p_a1
                AND     GRANDPARENT_OPTION_ID = p_a0
                AND     INDICATOR             = p_indicator;
            EXCEPTION
                WHEN OTHERS THEN
                   NULL;
            END;
        END IF;
    END IF;
END IF;
RETURN l_anal_name;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END GET_AO_NAME;


--
-- 16-JUN-2003 Ravi added for Assign Dimension to KPI enh
--

FUNCTION GET_SERIES_COUNT
(
        p_indicator     IN  NUMBER
    ,   p_a0            IN  NUMBER
    ,   p_a1            IN  NUMBER
    ,   p_a2            IN  NUMBER
) RETURN NUMBER IS

    l_count   NUMBER    :=  0;

    CURSOR c_SeriesCount IS
    SELECT COUNT(SERIES_ID)
    FROM   BSC_KPI_ANALYSIS_MEASURES_VL
    WHERE  INDICATOR     = p_indicator
    AND    ANALYSIS_OPTION0 = p_a0
    AND    ANALYSIS_OPTION1 = p_a1
    AND    ANALYSIS_OPTION2 = p_a2;
BEGIN
    IF (c_SeriesCount%ISOPEN)THEN
        CLOSE c_SeriesCount;
    END IF;

    OPEN    c_SeriesCount;
    FETCH   c_SeriesCount INTO l_count;
    CLOSE   c_SeriesCount;

    RETURN l_count;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END GET_SERIES_COUNT;

--=============================================================================
Procedure Load_Measure
( p_commit IN VARCHAR2 := FND_API.G_FALSE
, p_Measure_Rec IN BIS_MEASURE_PUB.Measure_Rec_Type
 ,p_Dataset_Rec IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
, p_owner IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_custom_mode IN VARCHAR2 := NULL
, p_application_short_name IN VARCHAR2
, p_Org_Dimension_Short_Name IN VARCHAR2
, p_Time_Dimension_Short_Name IN VARCHAR2
, p_measure_group_name IN VARCHAR2
, p_measure_apply_rollup IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
) IS

  --l_msg VARCHAR2(3000);
  l_measure_group_id NUMBER;
  l_measure_rec_p BIS_MEASURE_PUB.Measure_Rec_Type;
  l_measure_rec BIS_MEASURE_PUB.Measure_Rec_Type;
  l_Dataset_Rec BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
  l_Application_rec_p BIS_Application_PVT.Application_Rec_Type;
  l_Application_rec  BIS_Application_PVT.Application_Rec_Type;
  l_dataset_id NUMBER;
  l_measure_id1 NUMBER;
  l_measure_id2 NUMBER;
  l_return_status VARCHAR(10);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_org_dimension_id NUMBER;
  l_time_dimension_id NUMBER;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_measure_rec_new BIS_MEASURE_PUB.Measure_Rec_Type;
  l_dataset_rec_db BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
  l_dataset_rec_db1 BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
  l_measure_rec_db BIS_MEASURE_PUB.Measure_Rec_Type;
  l_time_stamp VARCHAR2(200);

  l_upload_test  BOOLEAN := FALSE;
  l_is_create    BOOLEAN := TRUE;
BEGIN
  fnd_msg_pub.initialize;
/*
  l_msg := 'The Performance Measure ' || p_measure_rec.measure_name ;
  l_msg := l_msg || ' could not be created/updated.';
*/
  l_measure_rec := p_measure_rec;
  l_dataset_rec := p_Dataset_Rec;

-- Incorporating the BISPMFLD.lct code changes here

-- First, check if the measure already exists.
-- Below code is to move changes already done in BISPMFLD.lct
-- into Load_Measure procedure
-- No changes are as such done to already existing code (BISPMFLD.lct 115.37)

  BIS_MEASURE_PUB.Retrieve_measure(
     p_api_version => 1.0
    ,p_Measure_Rec => l_measure_rec
    ,x_Measure_Rec => l_measure_rec_db
    ,x_return_status => x_return_status
    ,x_error_Tbl => l_error_Tbl
  );
  IF (l_measure_rec_db.dataset_id IS NOT NULL) THEN
    l_dataset_rec.Bsc_Dataset_Id := l_measure_rec_db.dataset_id;
    BSC_DATASETS_PUB.Retrieve_Dataset(
       p_commit => p_commit
      ,p_Dataset_Rec => l_dataset_rec
      ,x_Dataset_Rec => l_dataset_rec_db
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
    );
    l_dataset_id := l_dataset_rec.Bsc_Dataset_Id;
  ELSE
    l_dataset_id := NULL;
  END IF;

-- Get the application details here

  l_Application_rec_p.Application_Short_Name := p_Application_Short_Name;

  BIS_APPLICATION_PVT.Value_Id_conversion
    ( p_api_version       => 1.0
    , p_application_Rec   => l_Application_rec_p
    , x_application_Rec   => l_Application_rec
    , x_return_status     => l_return_status
    , x_error_Tbl         => l_error_tbl
  );


-- BIS_MEASURE_PUB.Measure_Value_Id_Conversion and
-- BIS_MEASURE_PUB.Dimension_Value_ID_Conversion are not called from Load_Measure
-- as they will be called where BIS_MEASURE_PUB.Create_Measure is called from
-- BSC_BIS_MEASURE_PUB.Create_Measure is called.

-- Give a call to BIS_MEASURE_PUB.Dimension_Value_ID_Conversion so that
-- we have dimension ids populated.
-- These Ids are used in giving a call to BIS_MEASURE_PVT.IS_OLD_DATA_MODEL

--
  BSC_BIS_MEASURE_PUB.Order_Dimensions_For_Ldt(
     p_Measure_Rec => l_measure_rec
    ,p_Org_Dimension_Short_Name => p_Org_Dimension_Short_Name
    ,p_Time_Dimension_Short_Name => p_Time_Dimension_Short_Name
    ,x_Measure_Rec => l_measure_rec_new
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data => x_msg_data
  );

-- Call to BIS_MEASURE_PVT.Measure_Value_ID_Conversion is used to check
-- if the measure should be created/updated during the upload of measure

  IF (BIS_UTILITIES_PUB.Value_Missing
         (p_Measure_Rec.Measure_id) = FND_API.G_TRUE
    OR BIS_UTILITIES_PUB.Value_NULL(p_Measure_Rec.Measure_id)
                                    = FND_API.G_TRUE) THEN
      BIS_MEASURE_PVT.Measure_Value_ID_Conversion
      ( p_api_version   => 1.0
      , p_Measure_Rec   => l_Measure_Rec_new
      , x_Measure_Rec   => l_Measure_Rec
      , x_return_status => x_return_status
      , x_error_Tbl     => l_error_tbl
     );
  END IF;

  --bug#4045278: perform upload test before any data is changed in the system
  IF ((x_return_status <> FND_API.G_RET_STS_SUCCESS) AND
      (l_dataset_id IS NULL)) THEN
    l_is_create := TRUE;
  ELSE
    l_is_create := FALSE;
    --bug#4045278: data versioning
    l_upload_test := BSC_BIS_MEASURE_PUB.Upload_Test(
                          p_measure_short_name => p_Measure_Rec.Measure_Short_Name
                         ,p_nls_mode           => null
                         ,p_file_lub           => BIS_UTILITIES_PUB.Get_Owner_Id(p_owner)
                         ,p_file_lud           => p_Measure_Rec.Last_Update_Date
                         ,p_custom_mode        => p_custom_mode
                     );

    --if upload_test result is false, does not allow update of this record, throw exception
    IF (l_upload_test = FALSE) THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_MEA_UPLOAD_TEST_FAILED');
      FND_MESSAGE.SET_TOKEN('SHORT_NAME', p_Measure_Rec.Measure_Short_Name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  --bug#4045278: moved this portion to here so that we allow modifying measure_group tables if upload_test passed:
  -- No CRUD is available for this.
  -- That's why direct SELECT statement is used.
  -- This logic has been moved from lct to here
  IF p_measure_group_name IS NOT NULL THEN
    BEGIN
      SELECT min(measure_group_id) into l_measure_group_id
      FROM   bsc_db_measure_groups_vl
      WHERE  help = p_measure_group_name;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_measure_group_id := null;
    END;

    IF l_measure_group_id IS NULL THEN
    -- Create group
      bsc_db_measure_groups_pkg.insert_row(
         x_measure_group_id => l_measure_group_id
        ,x_help => p_measure_group_name);
    END IF;
  ELSE
    l_measure_group_id := -1;
  END IF;

-- Two conditions are used
-- one for PMF and the other for BSC
  IF (l_is_create) THEN
    -- call create measure

    BSC_BIS_MEASURE_PUB.Create_Measure(
       p_commit => FND_API.G_FALSE
      ,x_dataset_id => l_dataset_id
      ,p_dataset_source => nvl(l_dataset_rec.Bsc_Source, 'PMF')
      ,p_dataset_name => l_dataset_rec.Bsc_Dataset_Name
      ,p_dataset_help => l_dataset_rec.Bsc_Dataset_Help
      ,p_dataset_measure_id1 => NULL
      ,p_dataset_operation => l_dataset_rec.Bsc_Dataset_Operation
      ,p_dataset_measure_id2 => NULL
      ,p_dataset_format_id => l_dataset_rec.Bsc_Dataset_Format_Id
      ,p_dataset_color_method   => l_dataset_rec.Bsc_Dataset_Color_Method
      ,p_dataset_autoscale_flag => l_dataset_rec.Bsc_Dataset_Autoscale_Flag
      ,p_dataset_projection_flag => l_dataset_rec.Bsc_Dataset_Projection_Flag
      ,p_measure_short_name => l_measure_rec.Measure_Short_Name
      ,p_measure_act_data_src_type  => l_measure_rec.Actual_Data_Source_Type
      ,p_measure_act_data_src => l_measure_rec.Actual_Data_Source
      ,p_measure_comparison_source => l_measure_rec.Comparison_Source
      ,p_measure_operation => l_dataset_rec.Bsc_Measure_Operation
      ,p_measure_uom_class => l_measure_rec.Unit_Of_Measure_Class
      ,p_measure_increase_in_measure => l_measure_rec.Increase_In_Measure
      ,p_measure_random_style => l_dataset_rec.Bsc_Measure_Random_Style
      ,p_measure_min_act_value => l_dataset_rec.Bsc_Measure_Min_Act_Value
      ,p_measure_max_act_value => l_dataset_rec.Bsc_Measure_Max_Act_Value
      ,p_measure_min_bud_value => l_dataset_rec.Bsc_Measure_Min_Bud_Value
      ,p_measure_max_bud_value => l_dataset_rec.Bsc_Measure_Max_Bud_Value
      ,p_measure_app_id => l_Application_rec.Application_id
      ,p_measure_col => l_dataset_rec.Bsc_Measure_Col
      ,p_measure_group_id => l_dataset_rec.Bsc_Measure_Group_Id
      ,p_measure_projection_id => l_dataset_rec.Bsc_Measure_Projection_Id
      ,p_measure_type => l_dataset_rec.Bsc_Measure_Type
      ,p_measure_apply_rollup   => p_measure_apply_rollup
      ,p_measure_function_name => l_measure_rec.Function_Name
      ,p_measure_enable_link => l_measure_rec.Enable_Link
      ,p_measure_obsolete => l_measure_rec.Obsolete
      ,p_type => l_measure_rec.Measure_Type
      ,p_measure_is_validate => l_measure_rec.is_validate -- ankgoel: bug#3557236
      ,p_dimension1_id => l_measure_rec.Dimension1_id
      ,p_dimension2_id => l_measure_rec.Dimension2_id
      ,p_dimension3_id => l_measure_rec.Dimension3_id
      ,p_dimension4_id => l_measure_rec.Dimension4_id
      ,p_dimension5_id => l_measure_rec.Dimension5_id
      ,p_dimension6_id => l_measure_rec.Dimension6_id
      ,p_dimension7_id => l_measure_rec.Dimension7_id
      ,p_y_axis_title => l_dataset_rec.Bsc_Y_Axis_Title
      ,p_owner => p_owner
      ,p_ui_flag => c_UI_FLAG
      ,p_last_update_date => p_measure_rec.Last_Update_Date
      ,p_func_area_short_name => l_measure_rec.Func_Area_Short_Name
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
    );
  ELSE
    -- Get the time stamp using the dataset id so that it can be passed back
    -- to the update API
    -- Use the db record that is retrieved before for this.

    l_time_stamp := BSC_BIS_LOCKS_PUB.GET_TIME_STAMP_DATASET(
                      p_dataset_id => l_dataset_rec.bsc_dataset_id);
    -- Use BSC_DATASETS_PUB.Retrieve_Measures to get the measure details
    -- Previously l_dataset_rec has got all properties related to datasets
    -- Now measures properties are populated.

    BSC_DATASETS_PUB.Retrieve_Measures(
       p_commit => p_commit
      ,p_Dataset_Rec => l_Dataset_Rec_db
      ,x_Dataset_Rec => l_Dataset_Rec_db1
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
    );

    -- Use NVL to fill up DB values in case values coming from
    -- ldt are NULL

-- Retrieve the DB record and apply changes to that
-- These changes are to be applied to BIS record as well as BSC record.

-- Call the Update API

    BSC_BIS_MEASURE_PUB.Update_Measure(
       p_commit => FND_API.G_FALSE
      ,p_dataset_id => l_dataset_id
      ,p_dataset_source => NVL(l_dataset_rec.Bsc_Source, 'PMF') -- :SOURCE
      ,p_dataset_name => NVL(l_dataset_rec.Bsc_Dataset_Name, l_dataset_rec_db.Bsc_Dataset_Name)
      ,p_dataset_help => NVL(l_dataset_rec.Bsc_Dataset_Help, l_dataset_rec_db.Bsc_Dataset_Help)
      ,p_dataset_measure_id1 => NVL(l_measure_id1, l_dataset_rec_db.Bsc_Measure_Id)
      ,p_dataset_operation => NVL(l_dataset_rec.Bsc_Dataset_Operation, l_dataset_rec_db.Bsc_Dataset_Operation)
      ,p_dataset_measure_id2 => NVL(l_measure_id2, l_dataset_rec_db.Bsc_Measure_Id2)
      ,p_dataset_format_id => NVL(l_dataset_rec.Bsc_Dataset_Format_Id, l_dataset_rec_db.Bsc_Dataset_Format_Id)
      ,p_dataset_color_method   => NVL(l_dataset_rec.Bsc_Dataset_Color_Method,  l_dataset_rec_db.Bsc_Dataset_Color_Method)
      ,p_dataset_autoscale_flag => NVL(l_dataset_rec.Bsc_Dataset_Autoscale_Flag, l_dataset_rec_db.Bsc_Dataset_Autoscale_Flag)
      ,p_dataset_projection_flag => NVL(l_dataset_rec.Bsc_Dataset_Projection_Flag, l_dataset_rec_db.Bsc_Dataset_Projection_Flag)
      ,p_measure_short_name => l_measure_rec.Measure_Short_Name
      ,p_measure_act_data_src_type  => l_measure_rec.Actual_Data_Source_Type
      ,p_measure_act_data_src => l_measure_rec.Actual_Data_Source
      ,p_measure_comparison_source => l_measure_rec.Comparison_Source
      ,p_measure_operation => NVL(l_dataset_rec.Bsc_Measure_Operation, l_dataset_rec_db1.Bsc_Measure_Operation)
      ,p_measure_uom_class => l_measure_rec.Unit_Of_Measure_Class
      ,p_measure_increase_in_measure => l_measure_rec.Increase_In_Measure
      ,p_measure_random_style => NVL(l_dataset_rec.Bsc_Measure_Random_Style, l_dataset_rec_db1.Bsc_Measure_Random_Style)
      ,p_measure_min_act_value => NVL(l_dataset_rec.Bsc_Measure_Min_Act_Value, l_dataset_rec_db1.Bsc_Measure_Min_Act_Value)
      ,p_measure_max_act_value => NVL(l_dataset_rec.Bsc_Measure_Max_Act_Value, l_dataset_rec_db1.Bsc_Measure_Max_Act_Value)
      ,p_measure_min_bud_value => NVL(l_dataset_rec.Bsc_Measure_Min_Bud_Value, l_dataset_rec_db1.Bsc_Measure_Min_Bud_Value)
      ,p_measure_max_bud_value => NVL(l_dataset_rec.Bsc_Measure_Max_Bud_Value, l_dataset_rec_db1.Bsc_Measure_Max_Bud_Value)
      ,p_measure_app_id => l_Application_rec.Application_id
      ,p_measure_col => NVL(l_dataset_rec.Bsc_Measure_Col, l_dataset_rec_db1.Bsc_Measure_Col)
      ,p_measure_group_id => NVL(l_dataset_rec.Bsc_Measure_Group_Id, -1)
      ,p_measure_projection_id => NVL(l_dataset_rec.Bsc_Measure_Projection_Id, 3)
      ,p_measure_type => NVL(l_dataset_rec.Bsc_Measure_Type, l_dataset_rec_db1.Bsc_Measure_Type)
      ,p_measure_apply_rollup   => p_measure_apply_rollup
      ,p_measure_function_name => l_measure_rec.Function_Name
      ,p_measure_enable_link => l_measure_rec.Enable_Link
      ,p_measure_obsolete => l_measure_rec.Obsolete
      ,p_type => l_measure_rec.Measure_Type
      ,p_measure_is_validate => l_measure_rec.is_validate -- ankgoel: bug#3557236
      ,p_time_stamp => l_time_stamp
      ,p_dimension1_id => l_measure_rec.Dimension1_id
      ,p_dimension2_id => l_measure_rec.Dimension2_id
      ,p_dimension3_id => l_measure_rec.Dimension3_id
      ,p_dimension4_id => l_measure_rec.Dimension4_id
      ,p_dimension5_id => l_measure_rec.Dimension5_id
      ,p_dimension6_id => l_measure_rec.Dimension6_id
      ,p_dimension7_id => l_measure_rec.Dimension7_id
      ,p_y_axis_title => NVL(l_dataset_rec.Bsc_Y_Axis_Title, l_dataset_rec_db.Bsc_Y_Axis_Title)
      ,p_owner => p_owner
      ,p_ui_flag => c_UI_FLAG
      ,p_last_update_date => p_measure_rec.Last_Update_Date
      ,p_func_area_short_name => l_measure_rec.Func_Area_Short_Name
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
    );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
--    BIS_UTILITIES_PUB.put_line(p_text =>l_msg);
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF(x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                                ,p_count  =>      x_msg_count
                                ,p_data   =>      x_msg_data);
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_ERROR THEN
--      BIS_UTILITIES_PUB.put_line(p_text =>l_msg);
      x_return_status := FND_API.G_RET_STS_ERROR ;
    IF(x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                                ,p_count  =>      x_msg_count
                                ,p_data   =>      x_msg_data);
    END IF;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--      BIS_UTILITIES_PUB.put_line(p_text =>l_msg);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF(x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                                ,p_count  =>      x_msg_count
                                ,p_data   =>      x_msg_data);
    END IF;
    RAISE;
  WHEN others THEN
--      BIS_UTILITIES_PUB.put_line(p_text =>l_msg);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF(x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                                ,p_count  =>      x_msg_count
                                ,p_data   =>      x_msg_data);
    END IF;
    RAISE;
END Load_Measure;
--=============================================================================
PROCEDURE Translate_Measure
(p_commit IN VARCHAR2 := FND_API.G_FALSE
,p_owner IN VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_custom_mode IN VARCHAR2 := NULL
, p_Measure_Rec IN BIS_MEASURE_PUB.Measure_Rec_Type
, p_Dataset_Rec IN BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
)
IS

l_dataset_rec BSC_DATASETS_PUB.Bsc_Dataset_Rec_Type;
l_measure_rec BIS_MEASURE_PUB.Measure_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_Dataset_Id NUMBER;
l_upload_test       BOOLEAN  := FALSE;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Initialize;

  --bug#4045278: data versioning
  l_upload_test := BSC_BIS_MEASURE_PUB.Upload_Test(
                        p_measure_short_name => p_Measure_Rec.Measure_Short_Name
                       ,p_nls_mode           => 'NLS'
                       ,p_file_lub           => BIS_UTILITIES_PUB.Get_Owner_Id(p_owner)
                       ,p_file_lud           => p_Measure_Rec.Last_Update_Date
                       ,p_custom_mode        => p_custom_mode
                   );

  --if upload_test result is false, does not allow update of this record, throw exception
  IF (l_upload_test = FALSE) THEN
    FND_MESSAGE.SET_NAME('BIS','BIS_MEA_UPLOAD_TEST_FAILED');
    FND_MESSAGE.SET_TOKEN('SHORT_NAME', p_Measure_Rec.Measure_Short_Name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_dataset_rec := p_Dataset_Rec;
  l_measure_rec := p_Measure_Rec;

  BSC_BIS_MEASURE_PUB.Ret_Dataset_Fr_Meas_Shrt_Name(
     p_Measure_Short_Name => p_dataset_rec.Bsc_Measure_Short_Name
    ,x_Dataset_Id => l_Dataset_Id
  );

  l_dataset_rec.Bsc_Dataset_Id := l_Dataset_Id;

  --sawu: populate WHO column
  l_dataset_rec.Bsc_Dataset_Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_dataset_rec.Bsc_Dataset_Last_Update_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_dataset_rec.Bsc_Dataset_Last_Update_Login := fnd_global.LOGIN_ID;

  l_dataset_rec.Bsc_Measure_Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_dataset_rec.Bsc_Measure_Last_Update_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_dataset_rec.Bsc_Measure_Last_Update_Login := fnd_global.LOGIN_ID;

  l_measure_rec.Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_measure_rec.Last_Updated_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_measure_rec.Last_Update_Login := fnd_global.LOGIN_ID;

  BSC_DATASETS_PUB.Translate_Measure(
     p_commit => FND_API.G_FALSE
    ,p_measure_rec => l_measure_rec
    ,p_Dataset_Rec => l_Dataset_Rec
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data => x_msg_data
  );

  BIS_MEASURE_PVT.Translate_measure
  ( p_api_version       => 1.0  -- this is not of significance anymore
  , p_commit            => p_commit
  , p_Measure_Rec       => l_Measure_Rec
  , p_owner             => p_owner
  , x_return_status     => x_return_status
  , x_error_Tbl         => l_error_Tbl
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                              ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                              ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                              ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                              ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    RAISE;

END Translate_Measure;
--=============================================================================
--=============================================================================
PROCEDURE Order_Dimensions_For_Ldt(
  p_Measure_Rec IN BIS_MEASURE_PUB.Measure_Rec_Type
 ,p_Org_Dimension_Short_Name IN VARCHAR2
 ,p_Time_Dimension_Short_Name IN VARCHAR2
 ,x_Measure_Rec OUT NOCOPY BIS_MEASURE_PUB.Measure_Rec_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
) IS
  l_measure_rec BIS_MEASURE_PUB.Measure_Rec_Type;
  l_measure_rec_new BIS_MEASURE_PUB.Measure_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_org_dimension_id NUMBER;
  l_time_dimension_id NUMBER;
  l_flag  VARCHAR2(10);
BEGIN

  BIS_Measure_PVT.Dimension_Value_ID_Conversion
    ( p_api_version   => 1.0
    , p_Measure_Rec   => p_measure_rec
    , x_Measure_Rec   => l_Measure_Rec
    , x_return_status => x_return_status
    , x_error_Tbl     => l_error_Tbl
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (BIS_UTILITIES_PUB.Value_Not_Missing
    (p_Org_Dimension_Short_Name) = FND_API.G_TRUE
  AND BIS_UTILITIES_PUB.Value_Not_NULL(p_Org_Dimension_Short_Name)
                                    = FND_API.G_TRUE) THEN
       BIS_DIMENSION_PVT.Value_ID_Conversion
       ( p_api_version => 1.0
       , p_Dimension_Short_Name => p_Org_Dimension_Short_Name
       , p_Dimension_Name => FND_API.G_MISS_CHAR
       , x_Dimension_ID => l_Org_Dimension_ID
       , x_return_status => x_return_status
       , x_error_Tbl => l_error_Tbl
       );

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;

  END IF;

  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_Time_Dimension_Short_Name) = FND_API.G_TRUE
        AND BIS_UTILITIES_PUB.Value_Not_NULL(p_Time_Dimension_Short_Name)
                                  = FND_API.G_TRUE) THEN
     BIS_DIMENSION_PVT.Value_ID_Conversion
     ( p_api_version => 1.0
     , p_Dimension_Short_Name => p_Time_Dimension_Short_Name
     , p_Dimension_Name => FND_API.G_MISS_CHAR
     , x_Dimension_ID => l_Time_Dimension_ID
     , x_return_status => x_return_status
     , x_error_Tbl => l_error_Tbl
     );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
       RAISE FND_API.G_EXC_ERROR;
     END IF;

  END IF;

  l_measure_rec_new := l_measure_rec; -- added later

  IF (BIS_MEASURE_PVT.IS_OLD_DATA_MODEL(
         l_Measure_Rec
    ,l_Org_Dimension_ID
    ,l_Time_Dimension_ID)) THEN

     l_flag := FND_API.G_FALSE;
     IF((l_flag = FND_API.G_FALSE) AND (BIS_UTILITIES_PVT.Value_Missing_Or_Null(l_measure_rec.Dimension1_ID) = FND_API.G_TRUE)) THEN
       l_measure_rec_new.Dimension1_ID := l_Org_Dimension_ID;
       l_measure_rec_new.Dimension1_Short_Name := p_Org_Dimension_Short_Name;
       l_measure_rec_new.Dimension1_Name := NULL; -- Retrieve Org dimension name later

       l_measure_rec_new.Dimension2_ID := l_Time_Dimension_ID;
       l_measure_rec_new.Dimension2_Short_Name := p_Time_Dimension_Short_Name;
       l_measure_rec_new.Dimension2_Name := NULL; -- Retrieve Time dimension name later
       l_flag := FND_API.G_TRUE;
     END IF;
     IF((l_flag = FND_API.G_FALSE) AND (BIS_UTILITIES_PVT.Value_Missing_Or_Null(l_measure_rec.Dimension2_ID) = FND_API.G_TRUE)) THEN
       l_measure_rec_new.Dimension2_ID := l_Org_Dimension_ID;
       l_measure_rec_new.Dimension2_Short_Name := p_Org_Dimension_Short_Name;
       l_measure_rec_new.Dimension2_Name := NULL; -- Retrieve Org dimension name later

       l_measure_rec_new.Dimension3_ID := l_Time_Dimension_ID;
       l_measure_rec_new.Dimension3_Short_Name := p_Time_Dimension_Short_Name;
       l_measure_rec_new.Dimension3_Name := NULL; -- Retrieve Time dimension name later
       l_flag := FND_API.G_TRUE;
     END IF;
     IF((l_flag = FND_API.G_FALSE) AND (BIS_UTILITIES_PVT.Value_Missing_Or_Null(l_measure_rec.Dimension3_ID) = FND_API.G_TRUE)) THEN
       l_measure_rec_new.Dimension3_ID := l_Org_Dimension_ID;
       l_measure_rec_new.Dimension3_Short_Name := p_Org_Dimension_Short_Name;
       l_measure_rec_new.Dimension3_Name := NULL; -- Retrieve Org dimension name later

       l_measure_rec_new.Dimension4_ID := l_Time_Dimension_ID;
       l_measure_rec_new.Dimension4_Short_Name := p_Time_Dimension_Short_Name;
       l_measure_rec_new.Dimension4_Name := NULL; -- Retrieve Time dimension name later
       l_flag := FND_API.G_TRUE;
     END IF;
     IF((l_flag = FND_API.G_FALSE) AND (BIS_UTILITIES_PVT.Value_Missing_Or_Null(l_measure_rec.Dimension4_ID) = FND_API.G_TRUE)) THEN
       l_measure_rec_new.Dimension4_ID := l_Org_Dimension_ID;
       l_measure_rec_new.Dimension4_Short_Name := p_Org_Dimension_Short_Name;
       l_measure_rec_new.Dimension4_Name := NULL; -- Retrieve Org dimension name later

       l_measure_rec_new.Dimension5_ID := l_Time_Dimension_ID;
       l_measure_rec_new.Dimension5_Short_Name := p_Time_Dimension_Short_Name;
       l_measure_rec_new.Dimension5_Name := NULL; -- Retrieve Time dimension name later
       l_flag := FND_API.G_TRUE;
     END IF;
     IF((l_flag = FND_API.G_FALSE) AND (BIS_UTILITIES_PVT.Value_Missing_Or_Null(l_measure_rec.Dimension5_ID) = FND_API.G_TRUE)) THEN
       l_measure_rec_new.Dimension5_ID := l_Org_Dimension_ID;
       l_measure_rec_new.Dimension5_Short_Name := p_Org_Dimension_Short_Name;
       l_measure_rec_new.Dimension5_Name := NULL; -- Retrieve Org dimension name later

       l_measure_rec_new.Dimension6_ID := l_Time_Dimension_ID;
       l_measure_rec_new.Dimension6_Short_Name := p_Time_Dimension_Short_Name;
       l_measure_rec_new.Dimension6_Name := NULL; -- Retrieve Time dimension name later
       l_flag := FND_API.G_TRUE;
     END IF;
     IF((l_flag = FND_API.G_FALSE) AND (BIS_UTILITIES_PVT.Value_Missing_Or_Null(l_measure_rec.Dimension6_ID) = FND_API.G_TRUE)) THEN
       l_measure_rec_new.Dimension6_ID := l_Org_Dimension_ID;
       l_measure_rec_new.Dimension6_Short_Name := p_Org_Dimension_Short_Name;
       l_measure_rec_new.Dimension6_Name := NULL; -- Retrieve Org dimension name later

       l_measure_rec_new.Dimension7_ID := l_Time_Dimension_ID;
       l_measure_rec_new.Dimension7_Short_Name := p_Time_Dimension_Short_Name;
       l_measure_rec_new.Dimension7_Name := NULL; -- Retrieve Time dimension name later
       l_flag := FND_API.G_TRUE;
     END IF;

  END IF;
  x_measure_rec := l_measure_rec_new;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                              ,p_data  => x_msg_data);
    RAISE;
END Order_Dimensions_For_Ldt;
--=============================================================================
--
-- Get the dataset_id from measure short name so that the same
-- can be used while updating the measure name and description
-- in the BSC system while uploading of the ldt.
--=============================================================================
PROCEDURE Ret_Dataset_Fr_Meas_Shrt_Name(
   p_Measure_Short_Name IN VARCHAR2
  ,x_Dataset_Id OUT NOCOPY NUMBER
) IS

CURSOR c_dataset_id (cp_measure_short_name VARCHAR2)IS
  SELECT dataset_id
  FROM   bis_indicators
  WHERE  short_name = cp_measure_short_name;

BEGIN

  IF (c_dataset_id%ISOPEN) THEN
    CLOSE c_dataset_id;
  END IF;

  OPEN c_dataset_id(cp_measure_short_name => p_Measure_Short_Name);
  FETCH c_dataset_id INTO x_Dataset_Id;
  CLOSE c_dataset_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_dataset_id%ISOPEN) THEN
      CLOSE c_dataset_id;
    END IF;
END Ret_Dataset_Fr_Meas_Shrt_Name;

--=============================================================================

-- mdamle 09/03/03 - Get measure col
function get_measure_col(
   p_dataset_name IN VARCHAR2
  ,p_source       IN VARCHAR2
  ,p_measure_id   IN NUMBER
  ,p_short_name   IN VARCHAR2
) return VARCHAR2 is
l_measure_col       bsc_sys_datasets_tl.name%TYPE;
l_flag              BOOLEAN := FALSE;
l_alias             VARCHAR2(30);
l_temp_var          VARCHAR2(30);
l_count             NUMBER;
l_is_mes_exist      BOOLEAN := FALSE;
l_count_col         NUMBER;
l_mes_short_name    BSC_SYS_MEASURES.SHORT_NAME%TYPE;
BEGIN

          l_measure_col := gen_name_for_column(p_dataset_name);

          IF(l_measure_col is null) THEN
             IF(p_short_name is null ) THEN
                 l_mes_short_name :=   bsc_utility.Get_Default_Internal_Name(bsc_utility.c_BSC_MEASURE);
             ELSE
                 l_mes_short_name :=  p_short_name;
             END IF;
             l_measure_col := gen_name_for_column(l_mes_short_name);

          END IF;

          l_temp_var := substr(l_measure_col, 1, 30);

          l_flag              :=  TRUE;
          l_alias             :=  NULL;

          WHILE (l_flag) LOOP
          l_is_mes_exist := FALSE;
            IF (p_measure_id IS NULL) THEN
              SELECT COUNT(1) INTO l_count
                    FROM BSC_SYS_MEASURES
              WHERE  UPPER(measure_col) = UPPER(l_temp_var);

              SELECT COUNT(1) INTO l_count_col
                    FROM BSC_DB_MEASURE_COLS_TL
              WHERE  UPPER(measure_col) = UPPER(l_temp_var);

            ELSE
              SELECT COUNT(1) INTO l_count
                FROM   bsc_sys_measures
                    WHERE UPPER(measure_col) = UPPER(l_temp_var)
                AND    measure_id <> p_measure_id;

                SELECT COUNT(1) INTO l_count_col
                    FROM  BSC_DB_MEASURE_COLS_TL
                WHERE  UPPER(measure_col) = UPPER(l_temp_var);
            END IF;

            IF(l_count_col > 0 OR l_count > 0) THEN
                l_is_mes_exist := TRUE;
            END IF;

            IF (NOT l_is_mes_exist) THEN
              l_flag      :=  FALSE;
              l_measure_col  :=  l_temp_var;
            END IF;
            BEGIN
              l_alias     :=  BSC_BIS_MEASURE_PUB.get_Next_Alias(l_alias);
            EXCEPTION
              WHEN OTHERS THEN
                l_measure_col := substr(l_measure_col, 1, 30);
            END;
            l_temp_var  :=  SUBSTR(l_temp_var, 1, 27)||l_alias;
          END LOOP;

    return l_measure_col;
EXCEPTION
    when others then return null;

END get_measure_col;

-- mdamle 09/03/03 - Is Formula
function isFormula
(p_measure_col  IN VARCHAR2) return boolean is
BEGIN

    if (instr(p_measure_col, '/') > 0) or
        (instr(p_measure_col, '(') > 0) or
        (instr(p_measure_col, ')') > 0) or
        (instr(p_measure_col, '+') > 0) or
        (instr(p_measure_col, '-') > 0) or
        (instr(p_measure_col, '*') > 0) or
        (instr(p_measure_col, ',') > 0) or
        (instr(p_measure_col, ' ') > 0) then
        return true;
    else
        return false;
    end if;

END isFormula;

/*
***************************************************
  procedure Get_Incr_Trigger()


  checks if the measure properties have been changed
  which will result in Strucutral changes to the KPIs

***************************************************
*/

procedure Get_Incr_Trigger(
   p_commit                         in varchar2 := fnd_api.g_false
  ,p_dataset_id                     in number
  ,p_measure_projection_id          in number   := -1
  ,p_measure_type                   in number   := -1
  ,p_is_ytd_enabled                 in varchar2 := null
  ,p_is_qtd_enabled                 in varchar2 := null
  ,p_is_xtd_enabled                 in varchar2 := null
  ,p_rollup_calc                    in varchar2 := null
  ,p_formula                        in varchar2 := null
  ,p_Measure_Group_Id               IN VARCHAR2
  ,p_Check_Autogen_Only             IN VARCHAR2 := null
  ,x_return_status                  out nocopy  varchar2
  ,x_msg_count                      out nocopy  number
  ,x_msg_data                       out nocopy  varchar2
) is
  l_proj_id          number;
  l_measure_type     number;
  l_count            number;
  l_is_ytd_enabled   varchar2(3);
  l_is_qtd_enabled   varchar2(3);
  l_is_xtd_enabled   varchar2(3);
  l_rollup_calc      varchar2(5);
  l_formula          varchar2(320);
  l_kpis             varchar2(4000);
  l_measure_group_id NUMBER;

  CURSOR c_Meas_Grp IS
  SELECT  measure_group_id
  FROM    bsc_sys_datasets_vl d
        , bsc_sys_measures m
        , bsc_db_measure_cols_vl db
  WHERE  d.dataset_id = p_dataset_id
  AND    m.measure_id = d.measure_id1
  AND    m.measure_col =db.measure_col;

begin

  fnd_msg_pub.Initialize;

  if bsc_utility.isBscInProductionMode then
      select count(c.projection_id)
      into l_count
      from   bsc_sys_datasets_vl d, bsc_sys_measures m, bsc_db_measure_cols_vl c
      where  m.measure_id = d.measure_id1
      and    c.measure_col = m.measure_col
      and    d.dataset_id = p_dataset_id;

      -- incase the measure has a formula defined, we cannot have projection_id defined.
      -- hence the check is required.

      if(l_count <> 0) then
          select c.projection_id, c.measure_type
          into   l_proj_id, l_measure_type
          from   bsc_sys_datasets_vl d, bsc_sys_measures m, bsc_db_measure_cols_vl c
          where  m.measure_id = d.measure_id1
          and    c.measure_col = m.measure_col
          and    d.dataset_id = p_dataset_id;
      end if;

      if(p_is_ytd_enabled is not null) then
         select decode(count(disabled_calc_id), 1, 'N', 0, 'Y', 'N') isDisabled
         into   l_is_ytd_enabled
         from   bsc_sys_dataset_calc
         where  dataset_id = p_dataset_id
         and    disabled_calc_id = c_YTD_CODE;
      end if;

      if(p_is_qtd_enabled is not null) then
         select decode(count(disabled_calc_id), 1, 'N', 0, 'Y', 'N') isDisabled
         into   l_is_qtd_enabled
         from   bsc_sys_dataset_calc
         where  dataset_id = p_dataset_id
         and    disabled_calc_id = c_QTD_CODE;
      end if;

      -- needed for XTD Enhancement
      if(p_is_xtd_enabled is not null) then
         select decode(count(disabled_calc_id), 1, 'N', 0, 'Y', 'N') isDisabled
         into   l_is_xtd_enabled
         from   bsc_sys_dataset_calc
         where  dataset_id = p_dataset_id
         and    disabled_calc_id = c_XTD_CODE;
      end if;

      if(p_rollup_calc is not null) then
         select decode(nvl(BSC_APPS.Get_Property_Value(m.S_COLOR_FORMULA, 'pAvgL'), 'N'), 'Y', 'AVL', m.operation)  rollup
         into   l_rollup_calc
         from   bsc_sys_datasets_vl d, bsc_sys_measures m
         where  m.measure_id = d.measure_id1
         and    d.dataset_id = p_dataset_id ;
      end if;

      if(p_formula is not null) then
         select m.measure_col formula
         into   l_formula
         from   bsc_sys_datasets_vl d, bsc_sys_measures m
         where  m.measure_id = d.measure_id1
         and    d.dataset_id = p_dataset_id ;
      end if;

      IF(p_Measure_Group_Id IS NOT NULL) THEN
       FOR cd IN c_Meas_Grp LOOP
           l_measure_group_id := cd.measure_group_id;
       END LOOP;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_Check_Autogen_Only = 'Y') THEN
        l_kpis  := getMeasureAutoGenKpis(p_dataset_id);
      ELSE
        l_kpis  := getMeasureKpis(p_dataset_id);
      END IF;

      if (l_kpis is not null) then
          -- Provide a structural changes warning first
          if((upper(p_is_xtd_enabled) <> l_is_xtd_enabled) and (p_is_xtd_enabled is not null)) then -- l_is_xtd_enabled is always caps.
            fnd_message.set_name('BSC','BSC_PMD_KPI_STRUCT_INVALID');
            fnd_message.set_token('INDICATORS', l_kpis);
            fnd_msg_pub.ADD;
         -- raise fnd_api.g_exc_error;
          end if;

          if((upper(p_formula) <> upper(l_formula)) and (p_formula is not null)) then
            IF (BSC_DATASETS_PVT.Is_Structure_change(upper(p_formula), upper(l_formula))) THEN
              fnd_message.set_name('BSC','BSC_PMD_KPI_STRUCT_INVALID');
              fnd_message.set_token('INDICATORS', l_kpis);
              fnd_msg_pub.ADD;
              raise fnd_api.g_exc_error;
            ELSE
              fnd_message.set_name('BIS','BIS_PMD_KPI_NONSTRUCT_INVALID');
              fnd_message.set_token('OBJECTIVES', l_kpis);
              fnd_msg_pub.ADD;
              raise fnd_api.g_exc_error;
            END IF;
          end if;

          IF((p_Measure_Group_Id IS NOT NULL ) AND (l_measure_group_id IS NOT NULL)) THEN
            IF(p_Measure_Group_Id <> l_measure_group_id) THEN
              FND_MESSAGE.SET_NAME('BSC','BSC_PMD_KPI_STRUCT_INVALID');
              FND_MESSAGE.SET_TOKEN('INDICATORS', l_kpis);
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END IF;

          if ((l_measure_type <> p_measure_type) and (p_measure_type <> -1)) then
            fnd_message.set_name('BSC','BSC_PMD_KPI_COLOR_INVALID');
            fnd_message.set_token('INDICATORS', l_kpis);
            fnd_msg_pub.ADD;
            raise fnd_api.g_exc_error;
          end if;

          -- color changes is a sub-set change for structural changes, hence comes next

          -- Fixed for bug#3798834
          if((upper(p_rollup_calc) <> upper(l_rollup_calc)) and (p_rollup_calc is not null)) then
            fnd_message.set_name('BSC','BSC_PMD_KPI_COLOR_INVALID');
            fnd_message.set_token('INDICATORS', l_kpis);
            fnd_msg_pub.ADD;
            raise fnd_api.g_exc_error;
          end if;


          if ((l_proj_id <> p_measure_projection_id) and (p_measure_projection_id <> -1)) then
            fnd_message.set_name('BSC','BSC_PMD_KPI_COLOR_INVALID');
            fnd_message.set_token('INDICATORS', l_kpis);
            fnd_msg_pub.ADD;
            raise fnd_api.g_exc_error;
          end if;

          -- l_is_ytd_enabled is always caps.
          if((upper(p_is_ytd_enabled) <> l_is_ytd_enabled) and (p_is_ytd_enabled is not null)) then
            fnd_message.set_name('BSC','BSC_PMD_KPI_COLOR_INVALID');
            fnd_message.set_token('INDICATORS', l_kpis);
            fnd_msg_pub.ADD;
            raise fnd_api.g_exc_error;
          end if;

          -- l_is_qtd_enabled is always caps.
          if((upper(p_is_qtd_enabled) <> l_is_qtd_enabled) and (p_is_qtd_enabled is not null)) then
            fnd_message.set_name('BSC','BSC_PMD_KPI_COLOR_INVALID');
            fnd_message.set_token('INDICATORS', l_kpis);
            fnd_msg_pub.ADD;
            raise fnd_api.g_exc_error;
          end if;
      END IF;-- END L_KPIS IS NOT NULL
  END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

        if (x_msg_data is null) then
            fnd_msg_pub.count_and_get
            (      p_encoded   =>  fnd_api.g_false
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        end if;

  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

    -- fixed for Bug#3296451
    x_msg_data := null;

end Get_Incr_Trigger;



/*
***************************************************
  function getReturnMessage()
***************************************************
*/

function getReturnMessage (
       p_dataset_id in number
     , p_message    in varchar2
)
return varchar2 is
   l_return varchar2(4000);
   l_message varchar2(2000);
   l_temp varchar2(4000);

   l_length  number;
begin


   l_temp    := bsc_bis_measure_pub.getMeasureKpis(p_dataset_id => p_dataset_id);
   l_message := bsc_apps.get_message(p_message);
   l_length  := nvl(0, length(l_message));


   if((nvl(0, length(l_temp)) + l_length) > c_MAX_MSG_LENGTH) then
      l_temp := substr(l_temp, 1, (c_MAX_MSG_LENGTH - l_length - 3));  -- accomodate the colon
   end if;

   l_return := null;

   if (l_temp is not null) then
      l_return := l_message || l_temp;
   end if;

   return l_return;
exception
  when others then
  return null;
end getReturnMessage;


/*
***************************************************
  function getMeasureKpis()
***************************************************
*/

function getMeasureKpis (
      p_dataset_id in number
) return varchar2 is

   l_return       varchar2(32000);
   l_isFirst      boolean := true;

   cursor indicators_cursor is
   select k.name || ' [' || k.indicator || '] ' name
   from    bsc_kpis_vl k
   where  indicator in
              (
                select distinct indicator
                from bsc_kpi_analysis_measures_b d
                where dataset_id = p_dataset_id
              )
   and k.share_flag <> 2;
begin

    l_return := null;

    for cd in indicators_cursor loop
      if(l_isFirst = true) then
        l_return := l_return || cd.name;
        l_isFirst := false;
      else
        l_return := l_return ||', '||cd.name;
      end if;
    end loop;

    return l_return;

exception
    when others then return null;

END getMeasureKpis;


/*
***************************************************
  function getMeasureAutoGenKpis()
***************************************************
*/

FUNCTION getMeasureAutoGenKpis (
      p_dataset_id IN NUMBER
) RETURN VARCHAR2 IS

   l_return       VARCHAR2(32000);
   l_isFirst      BOOLEAN := TRUE;

   CURSOR indicators_cursor IS
   SELECT k.name || ' [' || k.indicator || '] ' name
   FROM    bsc_kpis_vl k
   WHERE  indicator IN
              (
                SELECT DISTINCT d.indicator
                FROM bsc_kpi_analysis_measures_b d,
                     bsc_kpis_b kpi
                WHERE d.dataset_id = p_dataset_id
                AND d.indicator = kpi.indicator
                AND   kpi.short_name IS NOT NULL
              )
   AND k.share_flag <> 2;
BEGIN

    l_return := NULL;

    FOR cd in indicators_cursor LOOP
      IF(l_isFirst = TRUE) THEN
        l_return := l_return || cd.name;
        l_isFirst := FALSE;
      ELSE
        l_return := l_return ||', '||cd.name;
      END IF;
    END LOOP;

    RETURN l_return;

EXCEPTION
    WHEN others THEN RETURN NULL;

END getMeasureAutoGenKpis;

/*
***************************************************
  procedure get_Color_Change_Trigger()
***************************************************
*/

procedure get_Color_Change_Trigger(
  p_kpi_id              in      varchar2
 ,p_dataset_data        in      varchar2
 ,p_m1_accept           in      varchar2
 ,p_m1_marg             in      varchar2
 ,p_m2_accept           in      varchar2
 ,p_m2_marg             in      varchar2
 ,p_m3_upr_accept       in      varchar2
 ,p_m3_upr_marg         in      varchar2
 ,p_m3_lwr_accept       in      varchar2
 ,p_m3_lwr_marg         in      varchar2
 ,x_return_status       out nocopy     varchar2
 ,x_msg_count           out nocopy     number
 ,x_msg_data            out nocopy     varchar2
) is

    l_Bsc_Tab_Entity_Rec            BSC_SCORECARD_PUB.Bsc_Tab_Entity_Rec;

    type dataset_method_data is RECORD(
      dataset_id            number
     ,color_method          number
     ,dataset_data          varchar2(50)
    );

    type dataset_method_data_tbl is table OF dataset_method_data
      index by BINARY_INTEGER;

    l_dataset_list                  varchar2(5000);

    cursor c_Indicators_Cursor is
      SELECT DISTINCT B.NAME||'['||B.INDICATOR||']' NAME
      FROM   BSC_KPI_ANALYSIS_MEASURES_B A,
             BSC_KPIS_VL B,
             BSC_DB_COLOR_KPI_DEFAULTS_V D
      WHERE  INSTR(L_DATASET_LIST, ','||A.DATASET_ID||',') > 0
      AND    D.DATASET_ID = A.DATASET_ID
      AND    A.INDICATOR =B.INDICATOR
      AND    B.INDICATOR =D.INDICATOR
      AND    B.PROTOTYPE_FLAG <> 2
      AND    B.SHARE_FLAG   <> 2;

    cursor  c_Dataset_Color is
      select B.DATASET_ID DATASET_ID, C.COLOR_METHOD COLOR_METHOD
      from   BSC_OAF_ANALYSYS_OPT_COMB_V A,
             BSC_KPI_ANALYSIS_MEASURES_VL B,
             BSC_SYS_DATASETS_VL C
      where  A.INDICATOR        = B.INDICATOR
      and    A.SERIES_ID        = B.SERIES_ID
      and    A.ANALYSIS_OPTION0 = B.ANALYSIS_OPTION0
      and    A.ANALYSIS_OPTION1 = B.ANALYSIS_OPTION1
      and    A.ANALYSIS_OPTION2 = B.ANALYSIS_OPTION2
      and    B.DATASET_ID       = C.DATASET_ID
      and    A.INDICATOR        = p_kpi_id
      order  by B.DATASET_ID;

    l_sql                           varchar2(2000);
    l_dataset_data                  varchar2(5000);
    l_dataset_dummy                 varchar2(100);
    l_indicators                    varchar2(32000);
    l_kpi_name                      varchar2(80);
    l_commit                        varchar2(10);
    l_isFirst                       boolean := true;

    l_dataset_id                    number;
    l_color_method                  number;
    l_pos                           number;
    l_dt_data_cnt                   number;
    l_dt_data_length                number;

    l_m1_accept                     number;
    l_m1_marg                       number;
    l_m2_accept                     number;
    l_m2_marg                       number;
    l_m3_upr_accept                 number;
    l_m3_upr_marg                   number;
    l_m3_lwr_accept                 number;
    l_m3_lwr_marg                   number;

    l2_m1_accept                    number;
    l2_m1_marg                      number;
    l2_m2_accept                    number;
    l2_m2_marg                      number;
    l2_m3_upr_accept                number;
    l2_m3_upr_marg                  number;
    l2_m3_lwr_accept                number;
    l2_m3_lwr_marg                  number;

    dt_data                         dataset_method_data_tbl;

begin


  -- set the proper values for the color tolerance levels.
  fnd_msg_pub.Initialize;


  if bsc_utility.isBscInProductionMode then
      l_m1_accept := remove_percent(p_m1_accept);
      l_m1_marg := remove_percent(p_m1_marg);
      l_m2_accept := remove_percent(p_m2_accept);
      l_m2_marg := remove_percent(p_m2_marg);
      l_m3_upr_accept := remove_percent(p_m3_upr_accept);
      l_m3_upr_marg := remove_percent(p_m3_upr_marg);
      l_m3_lwr_accept := remove_percent(p_m3_lwr_accept);
      l_m3_lwr_marg := remove_percent(p_m3_lwr_marg);

      l_dataset_data := p_dataset_data;
      l_dt_data_cnt := 0;

      --dbms_output.put_line('       l_dataset_data             ' || l_dataset_data);

      while length(l_dataset_data) > 0 loop
        l_pos := instr(l_dataset_data, ';');

        if l_pos > 0 then
          l_dataset_dummy := ltrim(rtrim(substr(l_dataset_data, 1, l_pos - 1)));
          l_dataset_data := substr(l_dataset_data, l_pos + 1, length(l_dataset_data));
        else
          l_dataset_dummy := ltrim(rtrim(l_dataset_data));
          l_dataset_data := '';
        end if;

        if length(l_dataset_dummy) > 0 then
          l_dt_data_cnt := l_dt_data_cnt + 1;
          dt_data(l_dt_data_cnt).dataset_data := l_dataset_dummy;
        end if;
      end loop;

      for i in 1..dt_data.count loop
        l_dt_data_length := length(dt_data(i).dataset_data);
        l_pos := instr(dt_data(i).dataset_data, ',');
        dt_data(i).dataset_id := substr(dt_data(i).dataset_data, 1, l_pos - 1);
        dt_data(i).color_method := substr(dt_data(i).dataset_data, l_pos + 1, l_dt_data_length);
      end loop;

      for cr in c_Dataset_Color loop
          l_dataset_id    :=  cr.DATASET_ID;
          l_color_method  :=  cr.COLOR_METHOD;
          --  loop over TABLE type to determine if method has changed.
          for i in 1..dt_data.count loop

            if ((l_dataset_id = dt_data(i).dataset_id) and (l_dataset_id <> -1)) then
              -- if datasets are the same.
              if (l_color_method <> dt_data(i).color_method) then
                -- if color methods are not the same.
                l_dataset_list := l_dataset_list || ',' || l_dataset_id ;
             end if;
           end if;
          end loop; -- end 1..dt_data.count loop
      end loop; -- end c_Dataset_Color

      l_dataset_list := l_dataset_list || ',';
      --dbms_output.put_line('       LAST - l_dataset_list           ' || l_dataset_list);

      for cd in c_Indicators_Cursor loop -- this cursor uses l_dataset_list
        if(l_isFirst = true) then
          l_indicators := l_indicators || cd.name;
          l_isFirst := false;
        else
          l_indicators := l_indicators ||' , '||cd.name;
       end if;
      end loop;

      -- determine if there's been a change in color triggers

      select a.property_value, b.property_Value, c.property_value,
             d.property_value, e.property_Value, f.property_value,
             g.property_value, h.property_Value
        into l2_m1_accept, l2_m1_marg, l2_m2_accept,
             l2_m2_marg, l2_m3_upr_accept, l2_m3_upr_marg,
             l2_m3_lwr_accept, l2_m3_lwr_marg
        from bsc_kpi_properties a, bsc_kpi_properties b, bsc_kpi_properties c,
             bsc_kpi_properties d, bsc_kpi_properties e, bsc_kpi_properties f,
             bsc_kpi_properties g, bsc_kpi_properties h
       where a.property_code like 'COL_M1_LEVEL1'
         and b.property_code like 'COL_M1_LEVEL2'
         and c.property_code like 'COL_M2_LEVEL1'
         and d.property_code like 'COL_M2_LEVEL2'
         and e.property_code like 'COL_M3_LEVEL1'
         and f.property_code like 'COL_M3_LEVEL2'
         and g.property_code like 'COL_M3_LEVEL3'
         and h.property_code like 'COL_M3_LEVEL4'
         and a.indicator = p_kpi_id
         and b.indicator = p_kpi_id
         and c.indicator = p_kpi_id
         and d.indicator = p_kpi_id
         and e.indicator = p_kpi_id
         and f.indicator = p_kpi_id
         and g.indicator = p_kpi_id
         and h.indicator = p_kpi_id;


      -- if there is a color trigger change, then notify the current indicator

      if (l2_m1_accept <> l_m1_accept) or (l2_m1_marg <> l_m1_marg) or
         (l2_m2_accept <> l_m2_accept) or (l2_m2_marg <> l_m2_marg) or
         (l2_m3_upr_accept <> l_m3_upr_accept) or (l2_m3_upr_marg <> l_m3_upr_marg) or
         (l2_m3_lwr_accept <> l_m3_lwr_accept) or (l2_m3_lwr_marg <> l_m3_lwr_marg) then


         select name || '[' || indicator || ']'
         into   l_kpi_name
         from   bsc_kpis_vl
         where  indicator = p_kpi_id;

         if ((instr(l_indicators, l_kpi_name) = 0) or (l_indicators is null)) then
            if(l_isFirst = true) then
              l_indicators := l_kpi_name;
            else
              l_indicators := l_indicators || ', ' || l_kpi_name;
            end if;
         end if;
      end if;

      x_msg_data := null;

      if (l_indicators is not null) then
         fnd_message.set_name('BSC','BSC_PMD_KPI_COLOR_INVALID');
         fnd_message.set_token('INDICATORS', l_indicators);
         fnd_msg_pub.ADD;
         raise fnd_api.g_exc_error;
      end if;

  end if; -- end isBscInProductionMode

exception
   when fnd_api.g_exc_error then
        if (x_msg_data is null) then
            fnd_msg_pub.count_and_get
            (      p_encoded   =>  fnd_api.g_false
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        end if;


  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

    x_msg_data := x_msg_data || sqlerrm;

end get_Color_Change_Trigger;

/*
***************************************************
  function remove_percent()
***************************************************
*/

function remove_percent(
  p_input in varchar2
) return number is
begin
    if (substr(p_input, LENGTH(p_input), 1) = '%') then
      return substr(p_input, 1, length(p_input)-1);
    else
      return p_input;
    end if;

exception when others then
    return -999; -- fixed Bug#3255382
end remove_percent;

/*******************************************************************************
  Return 'T' if measure exists with given display name and source type,
  return 'F' otherwise.
  Parameters:
    p_display_name     :=  measure display name
    p_source_type      :=  either BSC_BIS_MEASURE_PUB.c_BSC or
                           BSC_BIS_MEASURE_PUB.c_PMF
*******************************************************************************/
FUNCTION Is_Unique_Measure_Display_Name(
  p_dataset_id       NUMBER
 ,p_display_name     VARCHAR2
 ,p_source_type      VARCHAR2
) RETURN VARCHAR2 IS
l_display_name       BIS_INDICATORS_TL.NAME%TYPE;
BEGIN
  BSC_BIS_MEASURE_PUB.get_Measure_Name
  (   p_dataset_id        =>    p_dataset_id
     ,p_ui_flag           =>    'Y'
     ,p_dataset_source    =>    p_source_type
     ,p_dataset_name      =>    p_display_name
     ,x_measure_name      =>    l_display_name
  );
  RETURN 'T';
EXCEPTION
  WHEN OTHERS THEN RETURN 'F';
END Is_Unique_Measure_Display_Name;

FUNCTION  gen_name_for_column(
    p_name          IN VARCHAR2
)RETURN VARCHAR2 IS

l_asc           number;
l_measure_col   bsc_sys_datasets_tl.name%TYPE;
l_char          varchar2(1);
l_alias         VARCHAR2(30);
l_StartingWithInvalidType       BOOLEAN; --invalid type => numeric and underscore

BEGIN
        -- Valid values - numbers/alphabets/underscore

    l_StartingWithInvalidType := TRUE;

    for i in 1..length(p_name) loop
        begin
            l_char := substr(p_name, i, 1);
        exception
            when others then
                l_char := ' ';/* comsuming this exception as substr() will throw exception for NLS charactes and whole procedure is not being executed */
        end;

        l_asc := ascii(l_char);
        If ((l_asc >= 48 And l_asc <= 57)) or
            (l_asc >= 65 And l_asc <= 90) or
            (l_asc >= 97 And l_asc <= 122) or
            (l_asc = 95) Then

            -- added for Bug#3894955 and bug#4157795
            IF (l_StartingWithInvalidType AND (l_asc < 48 OR l_asc > 57) AND (l_asc <> 95)) THEN
              l_StartingWithInvalidType := FALSE;
            END IF;

            IF (NOT l_StartingWithInvalidType) THEN
               l_measure_col := l_measure_col || l_char;
            END IF;

        end if;
    end loop;

    RETURN l_measure_col;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_measure_col;
END gen_name_for_column;

FUNCTION is_Valid_AlphaNum
(
    p_name IN VARCHAR2
) RETURN BOOLEAN
IS
    l_SQL_Ident VARCHAR2(30);
BEGIN
    IF (p_name IS NULL) THEN
        RETURN FALSE;
    END IF;
    l_SQL_Ident :=  UPPER(p_name);
    IF (REPLACE(TRANSLATE(l_SQL_Ident, '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_',
                                       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'), 'X', '') IS NOT NULL) THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END is_Valid_AlphaNum;

/*
 * Return 'T' if specified column name in table is 'NUMBER',
 * return 'F' otherwise
 */
FUNCTION Is_Numeric_Column(
  p_table_name      IN VARCHAR2
 ,p_column_name     IN VARCHAR2
) RETURN VARCHAR2
IS
  l_ret_val   VARCHAR2(1) := 'F';
  l_data_type USER_TAB_COLUMNS.DATA_TYPE%TYPE;
BEGIN
  SELECT data_type INTO l_data_type
  FROM user_tab_columns
  WHERE table_name = p_table_name
  AND column_name = p_column_name;

  IF (l_data_type = 'NUMBER') THEN
    l_ret_val := 'T';
  END IF;

  RETURN l_ret_val;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'F';
END Is_Numeric_Column;


--=============================================================================
-- Wrapper for fnd_load_util.upload_test() that test whether a record should
-- be updated based on Last_Update_Date.
-- p_Measure_Short_Name:  measure short name to be checked
-- p_NLS_Mode:            NLS_MODE for upload
-- p_file_lub:            last_update_by id from ldt file
-- p_file_lud:            last_update_date from ldt file
-- p_custom_mode:         'FORCE' or none
--=============================================================================
FUNCTION Upload_Test (
   p_measure_short_name   IN VARCHAR2
  ,p_nls_mode             IN VARCHAR2
  ,p_file_lub             IN NUMBER
  ,p_file_lud             IN DATE
  ,p_custom_mode          IN VARCHAR2
) RETURN BOOLEAN
IS
  CURSOR mea_cur (cp_measure_short_name VARCHAR2) IS
    SELECT last_updated_by, last_update_date
    FROM   bis_indicators_vl
    WHERE  short_name = cp_measure_short_name;

  CURSOR mea_tl_cur (cp_measure_short_name VARCHAR2) IS
    SELECT tl.last_updated_by, tl.last_update_date
    FROM bis_indicators b, bis_indicators_tl tl
    WHERE b.INDICATOR_ID = tl.indicator_id
    AND b.short_name = cp_measure_short_name
    AND tl.LANGUAGE = userenv('LANG');

  l_db_lub      BIS_INDICATORS.LAST_UPDATED_BY%TYPE;
  l_db_lud      BIS_INDICATORS.LAST_UPDATE_DATE%TYPE;
BEGIN

  IF (mea_cur%ISOPEN) THEN
    CLOSE mea_cur;
  END IF;
  IF (mea_tl_cur%ISOPEN) THEN
    CLOSE mea_tl_cur;
  END IF;

  IF (p_nls_mode = 'NLS') THEN
    OPEN mea_tl_cur(cp_measure_short_name => p_measure_short_name);
    FETCH mea_tl_cur INTO l_db_lub, l_db_lud;
    CLOSE mea_tl_cur;
  ELSE
    OPEN mea_cur(cp_measure_short_name => p_measure_short_name);
    FETCH mea_cur INTO l_db_lub, l_db_lud;
    CLOSE mea_cur;
  END IF;

  RETURN fnd_load_util.upload_test(p_file_lub, p_file_lud, l_db_lub, l_db_lud, p_custom_mode);

EXCEPTION
  WHEN OTHERS THEN
    IF (mea_cur%ISOPEN) THEN
      CLOSE mea_cur;
    END IF;
    IF (mea_tl_cur%ISOPEN) THEN
      CLOSE mea_tl_cur;
    END IF;
    RETURN FALSE;
END Upload_Test;


FUNCTION Get_Meas_With_Src_Col(
  p_measure_col IN VARCHAR2
) RETURN VARCHAR2 IS
  l_Flag BOOLEAN;
  l_temp VARCHAR2(250);
  l_measure_ids VARCHAR2(250);
  l_measure_id VARCHAR2(30);

  CURSOR c_chk_col_in_formula(p_measure_col VARCHAR2) IS
    SELECT measure_id,measure_col
    FROM bsc_sys_measures
    WHERE measure_col like '%'||p_measure_col||'%';


    CURSOR c_chk_measid_in_measure(p_measure_id VARCHAR2) IS
    SELECT name
    FROM bsc_sys_datasets_vl
    WHERE measure_id1 = p_measure_id
    OR measure_id2 = p_measure_id;

BEGIN
  l_Flag := FALSE;
  l_temp := NULL;
  l_measure_ids := NULL;


  FOR cd in c_chk_col_in_formula(p_measure_col) LOOP
    --for every formula retrieved checking if the measure column is a part of the formula.
    l_Flag := BSC_BIS_MEASURE_PUB.Is_MeasureCol_In_Formula(p_measure_col,cd.measure_col);

    IF (l_Flag) THEN

      IF (cd.measure_id) IS NOT NULL THEN
          FOR ccd in c_chk_measid_in_measure(cd.measure_id) LOOP
              --ccd.name need to make a comma separated list of these
            IF (l_temp IS NULL) THEN
              l_temp := ccd.name;
            ELSE
              l_temp := l_temp ||','|| ccd.name ;
            END IF;
          END LOOP;
      END IF;
    END IF;
  END LOOP;

  RETURN l_temp;

END Get_Meas_With_Src_Col;





FUNCTION Get_Sing_Par_Meas_DS (
p_measure_id IN VARCHAR2
) RETURN VARCHAR2
IS
l_count      NUMBER;
l_dataset_id VARCHAR2(250);

BEGIN

l_count := 0;
l_dataset_id := NULL;

SELECT COUNT(1) into l_count
FROM BSC_SYS_DATASETS_B
WHERE MEASURE_ID1 =TO_NUMBER(p_measure_id)
AND MEASURE_ID2 IS NULL;

IF  (l_count=1) THEN
  SELECT DATASET_ID INTO l_dataset_id
  FROM BSC_SYS_DATASETS_B
  WHERE MEASURE_ID1 = TO_NUMBER(p_measure_id)
  AND MEASURE_ID2 IS NULL;

END IF;

RETURN l_dataset_id;

END Get_Sing_Par_Meas_DS;

--Return primary data source (i.e. region_code portion of actual_data_source) of the indicator
FUNCTION Get_Primary_Data_Source (
  p_indicator_id    IN BIS_INDICATORS.INDICATOR_ID%TYPE
) RETURN BIS_INDICATORS.ACTUAL_DATA_SOURCE%TYPE
IS
  l_retval  BIS_INDICATORS.ACTUAL_DATA_SOURCE%TYPE;
BEGIN
  SELECT substr(actual_data_source, 1, instr(actual_data_source, '.') -1) INTO l_retval
  FROM bis_indicators
  WHERE indicator_id = p_indicator_id;
  RETURN l_retval;
EXCEPTION
  WHEN OTHERS THEN
    RETURN l_retval;
END Get_Primary_Data_Source;


-- added for Bug#4617140
FUNCTION Is_Formula_Type (p_measure_col  IN VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
    IF (instr(p_measure_col, '/') > 0) or
        (instr(p_measure_col, '(') > 0) or
        (instr(p_measure_col, ')') > 0) or
        (instr(p_measure_col, '+') > 0) or
        (instr(p_measure_col, '-') > 0) or
        (instr(p_measure_col, '*') > 0) or
        (instr(p_measure_col, ',') > 0) or
        (instr(p_measure_col, ' ') > 0) then
        RETURN FND_API.G_TRUE;
    ELSE
        RETURN FND_API.G_FALSE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Formula_Type;

-- added for Bug#4617140
FUNCTION Get_Report_Objectives (
    p_Dataset_Id IN NUMBER
) RETURN VARCHAR2 IS
    l_Objective_Names VARCHAR2(32000);

    CURSOR c_Get_Obj_Names IS
        SELECT
         OB.NAME
        FROM
         BSC_KPIS_VL                 OB,
         BSC_KPI_ANALYSIS_MEASURES_B AM,
         BSC_SYS_DATASETS_B          ME
        WHERE
         ME.DATASET_ID = p_Dataset_Id  AND
         AM.DATASET_ID = ME.DATASET_ID AND
         OB.INDICATOR  = AM.INDICATOR  AND
         OB.SHORT_NAME                 IS NOT NULL;
BEGIN
    FOR c_GON IN c_Get_Obj_Names LOOP
        IF (l_Objective_Names IS NULL) THEN
            l_Objective_Names := c_GON.NAME;
        ELSE
            l_Objective_Names := l_Objective_Names || ', ' || c_GON.NAME;
        END IF;
    END LOOP;


    RETURN l_Objective_Names;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Report_Objectives;

end BSC_BIS_MEASURE_PUB;

/
