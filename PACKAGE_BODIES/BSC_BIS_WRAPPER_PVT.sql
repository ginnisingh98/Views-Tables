--------------------------------------------------------
--  DDL for Package Body BSC_BIS_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_WRAPPER_PVT" AS
/* $Header: BSCVBISB.pls 120.0 2005/06/01 16:30:01 appldev noship $ */

/************************************************************************************
************************************************************************************/

FUNCTION is_measure_dbi(
  l_measure_shortname IN VARCHAR2
) RETURN BOOLEAN
IS
  l_region_code VARCHAR2(2000);
  l_func_name VARCHAR2(2000);
  l_param_region_code VARCHAR2(2000);

  CURSOR c_akitems IS
    SELECT nested_region_code FROM ak_region_items
    WHERE  region_code = l_region_code AND item_style = 'NESTED_REGION';
BEGIN
  bsc_jv_pmf.get_pmf_measure(
    p_measure_shortname => l_measure_shortname
   ,x_region_code => l_region_code
   ,x_function_name => l_func_name
  );

  IF l_region_code IS NULL THEN
    RETURN FALSE;
  END IF;

  OPEN c_akitems;
  FETCH c_akitems INTO l_param_region_code;
  CLOSE c_akitems;

  RETURN l_param_region_code IS NOT NULL;
EXCEPTION
  WHEN OTHERS THEN
    IF (c_akitems%ISOPEN) THEN
      CLOSE c_akitems;
    END IF;
END is_measure_dbi;

/************************************************************************************
************************************************************************************/

FUNCTION Get_Actual_Value(
    p_kpi_code 		IN NUMBER,
    p_analysis_option0	IN NUMBER,
    p_analysis_option1	IN NUMBER,
    p_analysis_option2	IN NUMBER,
    p_series_id		IN NUMBER,
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2
) RETURN VARCHAR2 IS

    l_value VARCHAR2(2000);

BEGIN
    l_value := NULL;

    SELECT actual_data INTO l_value
    FROM bsc_bis_measures_data
    WHERE user_id = p_user_id AND
          responsibility_id = p_responsibility_id AND
          indicator = p_kpi_code AND
          analysis_option0 = p_analysis_option0 AND
          analysis_option1 = p_analysis_option1 AND
          analysis_option2 = p_analysis_option2 AND
          series_id = p_series_id;

   RETURN l_value;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_value ;

END Get_Actual_Value;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Actual_Value_From_PMV(
    p_kpi_info_rec 		IN BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Type,
    p_user_id 			IN VARCHAR2,
    p_responsibility_id		IN VARCHAR2,
    p_dimension_levels		IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Tbl_Type,
    p_time_level_from		IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type,
    p_time_level_to           	IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type,
    p_time_comparison_type	IN VARCHAR2,
    p_viewby_level      	IN VARCHAR2,
    x_actual_value		OUT NOCOPY VARCHAR2,
    x_compareto_value  		OUT NOCOPY VARCHAR2,
    x_return_status 		OUT NOCOPY VARCHAR2,
    x_msg_count 		OUT NOCOPY NUMBER,
    x_msg_data 			OUT NOCOPY VARCHAR2
) IS
    -- Measure Info dimensions
    l_measure_id		NUMBER;
    l_measure_dimensions        BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Tbl_Type;

    -- parameters to get actual from pmv
    l_region_code		VARCHAR2(2000) := NULL;
    l_function_name		VARCHAR2(2000) := NULL;
    l_time_parameter            BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE;
    l_parameters                BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE;
    l_time_parameter_tmp            BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE;
    l_parameters_tmp                BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE;
    l_actual_attribute_code    	VARCHAR2(2000) := NULL;
    l_compareto_attribute_code  VARCHAR2(2000) := NULL;

    -- Others
    l_i 			NUMBER;
    l_j				NUMBER;
    l_dimensionX_short_name	VARCHAR2(2000);
    l_dimension_level           BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type;
    l_total_dimlevel_short_name VARCHAR2(2000);
    l_total_dimlevel_value_id   NUMBER;
    l_total_dimlevel_value_name VARCHAR2(2000);
    l_dim_level_index		NUMBER;
    l_act_tbl                   BIS_PMV_ACTUAL_PVT.ACTUAL_VALUE_TBL_TYPE;
    l_actual_value              NUMBER := NULL;
    l_compareto_value           NUMBER := NULL;
    l_sum_actual_value          NUMBER := NULL;
    l_sum_compareto_value       NUMBER := NULL;

BEGIN
    FND_MSG_PUB.initialize;

    x_actual_value := NULL;
    x_compareto_value := NULL;

    --dbms_output.put_line('Begin BSC_BIS_WRAPPER_PVT.Get_Actual_Value_From_PMV' );

    -- Get pmf measure info
    l_measure_id := p_kpi_info_rec.measure_id;
    l_function_name := p_kpi_info_rec.function_name;
    l_region_code := p_kpi_info_rec.region_code;
    l_actual_attribute_code := p_kpi_info_rec.actual_attribute_code;
    l_compareto_attribute_code := p_kpi_info_rec.compareto_attribute_code;
    l_measure_dimensions(1).dimension_short_name := p_kpi_info_rec.dim1_short_name;
    l_measure_dimensions(2).dimension_short_name := p_kpi_info_rec.dim2_short_name;
    l_measure_dimensions(3).dimension_short_name := p_kpi_info_rec.dim3_short_name;
    l_measure_dimensions(4).dimension_short_name := p_kpi_info_rec.dim4_short_name;
    l_measure_dimensions(5).dimension_short_name := p_kpi_info_rec.dim5_short_name;
    l_measure_dimensions(6).dimension_short_name := p_kpi_info_rec.dim6_short_name;
    l_measure_dimensions(7).dimension_short_name := p_kpi_info_rec.dim7_short_name;

    --dbms_output.put_line('*l_function_name='||l_function_name);
    --dbms_output.put_line('*l_region_code='||l_region_code);
    --dbms_output.put_line('*l_actual_attribute_code='||l_actual_attribute_code);
    --dbms_output.put_line('*l_compareto_attribute_code='||l_compareto_attribute_code);
    --dbms_output.put_line('*l_dimension1_short_name='||l_measure_dimensions(1).dimension_short_name);
    --dbms_output.put_line('*l_dimension2_short_name='||l_measure_dimensions(2).dimension_short_name);
    --dbms_output.put_line('*l_dimension3_short_name='||l_measure_dimensions(3).dimension_short_name);
    --dbms_output.put_line('*l_dimension4_short_name='||l_measure_dimensions(4).dimension_short_name);
    --dbms_output.put_line('*l_dimension5_short_name='||l_measure_dimensions(5).dimension_short_name);
    --dbms_output.put_line('*l_dimension6_short_name='||l_measure_dimensions(6).dimension_short_name);
    --dbms_output.put_line('*l_dimension7_short_name='||l_measure_dimensions(7).dimension_short_name);

    IF p_time_level_to.dimension_short_name IS NOT NULL THEN
        -- By design if p_time_level_to exists then p_time_level_from exists
        l_time_parameter.time_parameter_name :=  p_time_level_to.dimension_short_name||'+'||
                                                 p_time_level_to.level_short_name;
        l_time_parameter.time_from_id := p_time_level_from.level_value_id;
        l_time_parameter.time_from_value := p_time_level_from.level_value_name;
        l_time_parameter.time_to_id := p_time_level_to.level_value_id;
        l_time_parameter.time_to_value := p_time_level_to.level_value_name;

        --dbms_output.put_line('*l_time_parameter.time_parameter_name='||l_time_parameter.time_parameter_name);
        --dbms_output.put_line('*l_time_parameter.time_from_id='||l_time_parameter.time_from_id);
        --dbms_output.put_line('*l_time_parameter.time_from_value='||l_time_parameter.time_from_value);
        --dbms_output.put_line('*l_time_parameter.time_to_id='||l_time_parameter.time_to_id);
        --dbms_output.put_line('*l_time_parameter.time_to_value='||l_time_parameter.time_to_value);
    END IF;

    -- For dimensions other than TIME we use the default dimension level (or total dimension level)
    -- and pass 'All' as value.
    l_j := 1;
    FOR l_i IN 1 .. 7 LOOP
        l_dimensionX_short_name := l_measure_dimensions(l_i).dimension_short_name;
        IF (l_dimensionX_short_name IS NOT NULL) AND (NOT Is_Time_Dimension(l_dimensionX_short_name)) THEN
            l_dim_level_index := Get_Dimension_Level_Index(l_dimensionX_short_name, p_dimension_levels);
            IF l_dim_level_index = 0 THEN
                -- A dimension level was not specified for this dimension
                -- Then use the total dimension level
                Get_Total_DimLevel_Info(
                    p_dimension_short_name => l_dimensionX_short_name,
                    x_total_dimlevel_short_name => l_total_dimlevel_short_name,
                    x_total_dimlevel_value_id => l_total_dimlevel_value_id,
                    x_total_dimlevel_value_name => l_total_dimlevel_value_name
                );

                l_parameters(l_j).parameter_name := l_dimensionX_short_name||'+'||l_total_dimlevel_short_name;
                l_parameters(l_j).parameter_id := NULL; -- All
                l_parameters(l_j).parameter_value := NULL; -- All
            ELSE
                -- A dimension level was specified for this dimension
                l_dimension_level := p_dimension_levels(l_dim_level_index);
                l_parameters(l_j).parameter_name := l_dimensionX_short_name||'+'||l_dimension_level.level_short_name;
                l_parameters(l_j).parameter_id := l_dimension_level.level_value_id;
                l_parameters(l_j).parameter_value := l_dimension_level.level_value_name;
            END IF;

            --dbms_output.put_line('*l_parameters('||l_j||').parameter_name='||l_parameters(l_j).parameter_name);
            --dbms_output.put_line('*l_parameters('||l_j||').parameter_id='||l_parameters(l_j).parameter_id);
            --dbms_output.put_line('*l_parameters('||l_j||').parameter_value='||l_parameters(l_j).parameter_value);

            l_j := l_j + 1;
        END IF;
    END LOOP;

    IF p_time_comparison_type IS NULL THEN
        -- No need to retrieve compareto_value
        l_compareto_attribute_code := NULL;
    ELSE
        -- Need to retrieve compareto_value, for that reason it passes a new parameter to PMV
        l_parameters(l_j).parameter_name := p_time_comparison_type;
        l_parameters(l_j).parameter_id := p_time_comparison_type;
        l_parameters(l_j).parameter_value := p_time_comparison_type;

        --dbms_output.put_line('*l_parameters('||l_j||').parameter_name='||l_parameters(l_j).parameter_name);
        --dbms_output.put_line('*l_parameters('||l_j||').parameter_id='||l_parameters(l_j).parameter_id);
        --dbms_output.put_line('*l_parameters('||l_j||').parameter_value='||l_parameters(l_j).parameter_value);

        l_j := l_j + 1;
    END IF;

    --dbms_output.put_line(substr('*l_actual_attribute_code='||l_actual_attribute_code,1,255));
    --dbms_output.put_line(substr('*l_compareto_attribute_code='||l_compareto_attribute_code,1,255));
    --dbms_output.put_line(substr('*p_viewby_level='||p_viewby_level,1,255));

    -- Call the PMV API to get the actual, pass pageID as Null
    bis_pmv_actual_pub.get_actual_value(
        p_region_code               => l_region_code
       ,p_function_name             => l_function_name
       ,p_user_id                   => p_user_id
       ,p_responsibility_id         => p_responsibility_id
       ,p_time_parameter            => l_time_parameter
       ,p_parameters                => l_parameters
       ,p_param_ids                 => 'N'
       ,p_actual_attribute_code     => l_actual_attribute_code
       ,p_compareto_attribute_code  => l_compareto_attribute_code
       ,p_ranking_level             => p_viewby_level
       ,x_actual_value              => l_act_tbl
       ,x_return_status             => x_return_status
       ,x_msg_count                 => x_msg_count
       ,x_msg_data                  => x_msg_data
    );

    IF l_act_tbl.count > 0 THEN
        l_actual_value := l_act_tbl(1).actual_grandtotal_value;
        l_compareto_value := l_act_tbl(1).compareto_grandtotal_value;
    END IF;

    FOR i in 1..l_act_tbl.count LOOP
        IF l_sum_actual_value IS NULL AND l_act_tbl(i).actual_value IS NOT NULL THEN
            l_sum_actual_value := l_act_tbl(i).actual_value;
        ELSIF l_act_tbl(i).actual_value IS NOT NULL THEN
            l_sum_actual_value := l_sum_actual_value + l_act_tbl(i).actual_value;
        END IF;

        IF l_sum_compareto_value IS NULL AND l_act_tbl(i).compare_to_value IS NOT NULL THEN
            l_sum_compareto_value := l_act_tbl(i).compare_to_value;
        ELSIF l_act_tbl(i).compare_to_value IS NOT NULL THEN
            l_sum_compareto_value := l_sum_compareto_value + l_act_tbl(i).compare_to_value;
        END IF;
    END LOOP;

    IF l_actual_value IS NULL THEN
        l_actual_value := l_sum_actual_value;
    END IF;

    IF l_compareto_value IS NULL THEN
        l_compareto_value := l_sum_compareto_value;
    END IF;

    x_actual_value := l_actual_value;
    x_compareto_value := l_compareto_value;

    --dbms_output.put_line('End  BSC_BIS_WRAPPER_PVT.Get_Actual_Value_From_PMV' );

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
   --dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
END Get_Actual_Value_From_PMV;

/************************************************************************************
***********************************************************************************/

PROCEDURE Get_AO_Defaults(
    p_kpi_code 		IN NUMBER,
    x_analysis_option0	OUT NOCOPY NUMBER,
    x_analysis_option1	OUT NOCOPY NUMBER,
    x_analysis_option2	OUT NOCOPY NUMBER,
    x_series_id		OUT NOCOPY NUMBER
) IS

 h_num_ag NUMBER;

BEGIN
    -- Initialzie Variables
    x_analysis_option0 := 0;
    x_analysis_option1 := 0;
    x_analysis_option2 := 0;
    x_series_id := 0;

    -- Get Analysis Option Defaults
	SELECT DISTINCT DF.A0_DEFAULT,DF.A1_DEFAULT,DF.A2_DEFAULT,MS.SERIES_ID
	INTO x_analysis_option0,x_analysis_option1,x_analysis_option2,x_series_id
	FROM BSC_DB_COLOR_AO_DEFAULTS_V DF,
	     BSC_KPI_ANALYSIS_MEASURES_B MS
	WHERE
	DEFAULT_VALUE =1 AND
	DF.INDICATOR = MS.INDICATOR AND
	DF.A0_DEFAULT = MS.ANALYSIS_OPTION0 AND
	DF.A1_DEFAULT = MS.ANALYSIS_OPTION1 AND
	DF.A2_DEFAULT = MS.ANALYSIS_OPTION2 AND
	DF.INDICATOR =p_kpi_code;

     -- Print out NOCOPY
	--dbms_output.put_line('p_kpi_code=' || p_kpi_code);
	--dbms_output.put_line('x_analysis_option0=' || x_analysis_option0);
	--dbms_output.put_line('x_analysis_option1=' || x_analysis_option1);
	--dbms_output.put_line('x_analysis_option2=' || x_analysis_option2);
	--dbms_output.put_line('x_series_id=' || x_series_id);

END Get_AO_Defaults;

/************************************************************************************
************************************************************************************/

FUNCTION Get_Current_Period(
    p_kpi_code 		IN NUMBER,
    p_analysis_option0	IN NUMBER,
    p_analysis_option1	IN NUMBER,
    p_analysis_option2	IN NUMBER,
    p_series_id		IN NUMBER
) RETURN VARCHAR2 IS

    -- parameters to get current period info
    l_dim_source		VARCHAR2(2000);
    l_org_dim_level_short_name	VARCHAR2(2000);
    l_org_dim_level_value_id    VARCHAR2(2000);
    l_current_period_id		VARCHAR2(2000);
    l_current_period_name	VARCHAR2(2000);

    l_dimset_id			NUMBER;
    l_time_dimension_level      BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type;

    l_return_status               VARCHAR2(32000);
    l_msg_count                   VARCHAR2(32000);
    l_msg_data                    VARCHAR2(32000);

BEGIN
    l_current_period_name := NULL;

    -- Get the dimension set
    Get_DimensionSet_Id(
        p_kpi_code => p_kpi_code,
        p_analysis_option0 => p_analysis_option0,
        p_analysis_option1 => p_analysis_option1,
        p_analysis_option2 => p_analysis_option2,
        p_series_id => p_series_id,
        x_dimset_id => l_dimset_id
    );

     --dbms_output.put_line('p_kpi_code=' || p_kpi_code);
     --dbms_output.put_line('Get_Current_Period x_analysis_option0=' || p_analysis_option0);
     --dbms_output.put_line('Get_Current_Period  x_analysis_option1=' || p_analysis_option1);
     --dbms_output.put_line('Get_Current_Period x_analysis_option2=' || p_analysis_option2);
     --dbms_output.put_line('Get_Current_Period x_dimset_id = ' || l_dimset_id);


    Get_Default_Time_Level(
        p_kpi_code => p_kpi_code,
        p_dimset_id => l_dimset_id,
        x_time_dimension_level => l_time_dimension_level
    );

    --dbms_output.put_line('p_kpi_code=' || p_kpi_code);
    --dbms_output.put_line('Get_Default_Time_Level=' || l_time_dimension_level.dimension_short_name);


    -- For now if Time dimension exist the color is calculated for the
    -- period corresponding to SYSDATE

    IF l_time_dimension_level.dimension_short_name IS NOT NULL THEN
        IF l_time_dimension_level.dimension_short_name = 'TIME' THEN
            -- OLTP
            l_dim_source := 'OLTP';
            l_org_dim_level_short_name := 'TOTAL_ORGANIZATIONS';
            l_org_dim_level_value_id := '-1';
        ELSE
            -- EDW
            l_dim_source := 'EDW';
            l_org_dim_level_short_name := NULL;
            l_org_dim_level_value_id := NULL;
        END IF;

 --dbms_output.put_line('l_dim_source=' || l_dim_source);
 --dbms_output.put_line('l_org_dim_level_short_name=' || l_org_dim_level_short_name);
 --dbms_output.put_line('l_org_dim_level_value_id=' || l_org_dim_level_value_id);


        Get_Period_Info(
            p_time_dim_level_short_name => l_time_dimension_level.level_short_name,
            p_source => l_dim_source,
            p_org_dim_level_short_name => l_org_dim_level_short_name,
            p_org_dim_level_value_id => l_org_dim_level_value_id,
            p_period_date => SYSDATE, --TO_DATE('04-15-2001','MM-DD-YYYY'),
            x_period_id => l_current_period_id,
            x_period_name => l_current_period_name,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data
        );
    END IF;
--if(l_current_period_name is null) then
--dbms_output.put_line('l_current_period_name is NULL= '|| l_current_period_name);
--else
--dbms_output.put_line('l_current_period_name = '|| l_current_period_name);
--end if;
    RETURN l_current_period_name;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_current_period_name;

END Get_Current_Period;

/************************************************************************************
************************************************************************************/

FUNCTION Get_DBI_Current_Period(
      p_time_dimension_level      IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type,
      p_as_of_date                IN VARCHAR2

) RETURN VARCHAR2 IS

    -- parameters to get current period info
    l_dim_source		VARCHAR2(2000);
    l_org_dim_level_short_name	VARCHAR2(2000);
    l_org_dim_level_value_id    VARCHAR2(2000);
    l_current_period_id		VARCHAR2(2000);
    l_current_period_name	VARCHAR2(2000);
    l_as_of_date_format		VARCHAR2(30) := 'DD-MON-RRRR';

    l_return_status               VARCHAR2(32000);
    l_msg_count                   VARCHAR2(32000);
    l_msg_data                    VARCHAR2(32000);

BEGIN
    l_current_period_name := NULL;

    IF p_time_dimension_level.dimension_short_name IS NOT NULL THEN
        IF p_time_dimension_level.dimension_short_name = 'TIME' THEN
            -- OLTP
            l_dim_source := 'OLTP';
            l_org_dim_level_short_name := 'TOTAL_ORGANIZATIONS';
            l_org_dim_level_value_id := '-1';
        ELSE
            -- EDW
            l_dim_source := 'EDW';
            l_org_dim_level_short_name := NULL;
            l_org_dim_level_value_id := NULL;
        END IF;

 --dbms_output.put_line('l_dim_source=' || l_dim_source);
 --dbms_output.put_line('l_org_dim_level_short_name=' || l_org_dim_level_short_name);
 --dbms_output.put_line('l_org_dim_level_value_id=' || l_org_dim_level_value_id);


        Get_Period_Info(
            p_time_dim_level_short_name => p_time_dimension_level.level_short_name,
            p_source => l_dim_source,
            p_org_dim_level_short_name => l_org_dim_level_short_name,
            p_org_dim_level_value_id => l_org_dim_level_value_id,
            p_period_date => TO_DATE(p_as_of_date,l_as_of_date_format),
            x_period_id => l_current_period_id,
            x_period_name => l_current_period_name,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data
        );
    END IF;
--if(l_current_period_name is null) then
--dbms_output.put_line('l_current_period_name is NULL= '|| l_current_period_name);
--else
--dbms_output.put_line('l_current_period_name = '|| l_current_period_name);
--end if;
    RETURN l_current_period_name;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_current_period_name;

END Get_DBI_Current_Period;

PROCEDURE Get_DataSet_Id (
    p_kpi_code 		IN NUMBER,
    p_analysis_option0 	IN NUMBER,
    p_analysis_option1 	IN NUMBER,
    p_analysis_option2 	IN NUMBER,
    p_series_id 	IN NUMBER,
    x_dataset_id	OUT NOCOPY NUMBER
) IS
BEGIN

    SELECT
        dataset_id
    INTO
        x_dataset_id
    FROM
        bsc_db_dataset_dim_sets_v
    WHERE
        indicator = p_kpi_code AND
        A0 = p_analysis_option0 AND
        A1 = p_analysis_option1 AND
        A2 = p_analysis_option2 AND
        series_id = p_series_id;

END Get_DataSet_Id;

/************************************************************************************
-- bug 2677766- Add x_format_id
************************************************************************************/

PROCEDURE Get_DataSet_Info (
    p_dataset_id		IN NUMBER,
    x_source			OUT NOCOPY VARCHAR2,
    x_measure_id1		OUT NOCOPY NUMBER,
    x_operation			OUT NOCOPY VARCHAR2,
    x_measure_id2		OUT NOCOPY NUMBER,
    x_color_method      	OUT NOCOPY NUMBER,
    x_measure_col1		OUT NOCOPY VARCHAR2,
    x_measure_operation1	OUT NOCOPY VARCHAR2,
    x_measure_short_name 	OUT NOCOPY VARCHAR2,
    x_measure_col2		OUT NOCOPY VARCHAR2,
    x_measure_operation2	OUT NOCOPY VARCHAR2,
    x_format_id			OUT NOCOPY NUMBER
) IS
BEGIN

    SELECT
        d.source,
        d.measure_id1,
        d.operation,
        d.measure_id2,
        d.color_method,
        m1.measure_col,
        m1.operation,
        m1.short_name,
        m2.measure_col,
        m2.operation,
	d.format_id
    INTO
        x_source,
        x_measure_id1,
        x_operation,
        x_measure_id2,
        x_color_method,
        x_measure_col1,
        x_measure_operation1,
        x_measure_short_name,
        x_measure_col2,
        x_measure_operation2,
	x_format_id
    FROM
        bsc_sys_datasets_b d,
        bsc_sys_measures m1,
        bsc_sys_measures m2
    WHERE
        d.dataset_id = p_dataset_id AND
        d.measure_id1 = m1.measure_id(+) AND
        d.measure_id2 = m2.measure_id(+);

END Get_DataSet_Info;

/************************************************************************************
************************************************************************************/

FUNCTION Get_Dimension_Short_Name(
    p_dimension_id IN NUMBER
) RETURN VARCHAR2 IS

    l_sql VARCHAR2(2000);
    l_short_name VARCHAR2(2000) := NULL;

BEGIN

    IF p_dimension_id IS NOT NULL THEN
        SELECT short_name INTO l_short_name
        FROM bis_dimensions
        WHERE dimension_id = p_dimension_id;
    END IF;

    RETURN l_short_name;

END Get_Dimension_Short_Name;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_DimensionSet_Id (
    p_kpi_code 		IN NUMBER,
    p_analysis_option0 	IN NUMBER,
    p_analysis_option1 	IN NUMBER,
    p_analysis_option2 	IN NUMBER,
    p_series_id 	IN NUMBER,
    x_dimset_id		OUT NOCOPY NUMBER
) IS
BEGIN

    SELECT
        dim_set_id
    INTO
        x_dimset_id
    FROM
        bsc_db_dataset_dim_sets_v
    WHERE
        indicator = p_kpi_code AND
        A0 = p_analysis_option0 AND
        A1 = p_analysis_option1 AND
        A2 = p_analysis_option2 AND
        series_id = p_series_id;

END Get_DimensionSet_Id;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Period_Info(
    p_time_dim_level_short_name IN VARCHAR2,
    p_source 			IN VARCHAR2,
    p_org_dim_level_short_name	IN VARCHAR2,
    p_org_dim_level_value_id	IN VARCHAR2,
    p_period_date		IN DATE DEFAULT SYSDATE,
    x_period_id 		OUT NOCOPY VARCHAR2,
    x_period_name		OUT NOCOPY VARCHAR2,
    x_return_status 		OUT NOCOPY VARCHAR2,
    x_msg_count 		OUT NOCOPY NUMBER,
    x_msg_data 			OUT NOCOPY VARCHAR2
) IS

    l_select_string VARCHAR2(32000);
    l_view_name VARCHAR2(2000);
    l_id_name VARCHAR2(2000);
    l_value_name VARCHAR2(2000);

    l_total_time_level_name VARCHAR2(2000);
    l_sql VARCHAR2(32000);

    l_curr_date	    VARCHAR2(2000);
    l_start_date    DATE;
    l_end_date	    DATE;
    l_time_lvl_dep_on_org    NUMBER(3);
    l_is_dep_on_org          BOOLEAN := FALSE;

    TYPE tcursor IS REF CURSOR;
    l_cursor	   tcursor;

BEGIN
    FND_MSG_PUB.initialize;

    l_curr_date := 'TO_DATE('''||TO_CHAR(p_period_date,'DD-MON-YYYY HH24:MI:SS')||''',''DD-MON-YYYY HH24:MI:SS'')';

    x_period_id := NULL;
    x_period_name := NULL;

    BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING (
        p_DimLevelShortName => p_time_dim_level_short_name
        ,p_bis_source => p_source
        ,x_Select_String => l_select_string
        ,x_table_name => l_view_name
        ,x_id_name => l_id_name
        ,x_value_name => l_value_name
        ,x_return_status => x_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data
    );

    --dbms_output.put_line('l_select_string' || l_select_string);
    --dbms_output.put_line('l_view_name' || l_view_name);
    --dbms_output.put_line('l_id_name' || l_id_name);
    --dbms_output.put_line('x_return_status' || x_return_status);
    --dbms_output.put_line('x_msg_count' || x_msg_count);
    --dbms_output.put_line('x_msg_data' || x_msg_data);

    IF x_msg_count > 0 THEN
    	RETURN;
    END IF;

    IF p_source = 'EDW' THEN
        l_total_time_level_name := 'EDW_TIME_A';
    ELSE
        l_total_time_level_name := 'TOTAL_TIME';
    END IF;

    -- For total time level there is only one record in the dimension view
    -- which is the one we want.

    IF (p_time_dim_level_short_name <> l_total_time_level_name) THEN

        l_sql := 'SELECT DISTINCT '||l_id_name||', '||l_value_name||', start_date, end_date'||
                 ' FROM '||l_view_name;

      -- No total time level
      -- In this case we compare l_curr_date with start_date and end_date
      -- to get the current period

      l_sql := l_sql||
               ' WHERE TRUNC('||l_curr_date||') BETWEEN '||
               ' NVL(start_date, TRUNC('||l_curr_date||')) AND NVL(end_date, TRUNC('||l_curr_date||'))';

      IF p_source = 'OLTP'  THEN --AND SUBSTR(p_time_dim_level_short_name, 1, 2) <> 'HR'
        --fix bug # 2372091, PMF API changes, BISVUTLB.pls
        -- For OLTP we need an additional condition on organization id

        l_time_lvl_dep_on_org := BIS_UTILITIES_PUB.is_time_dependent_on_org(p_time_lvl_short_name => p_time_dim_level_short_name);

        IF (p_time_dim_level_short_name IS NOT NULL AND l_time_lvl_dep_on_org = 1) THEN
           l_is_dep_on_org := TRUE;
        END IF;

        IF (l_is_dep_on_org) THEN  --fix bug # 2372091
            l_sql := l_sql||
                 ' AND ORGANIZATION_ID = '''||p_org_dim_level_value_id||''''||
                 ' AND NVL(ORGANIZATION_TYPE, ''%'') LIKE '''||p_org_dim_level_short_name||'''';
        END IF;


      ELSE
          -- Bug 1797680
          IF p_source = 'EDW' THEN
              -- In this case we need to filter out NOCOPY codes 0 and -1 which are special codes in EDW dimension tables
              l_sql := l_sql||
                       ' AND '||l_id_name||' NOT IN (''-1'', ''0'')';
          END IF;
      END IF;
      l_sql := l_sql||
               ' ORDER BY ABS(NVL(TRUNC(end_date), TRUNC('||l_curr_date||'))- NVL(TRUNC(start_date), TRUNC('||l_curr_date||')))';

  ELSE
      l_sql := 'SELECT DISTINCT '||l_id_name||', '||l_value_name||', '||l_curr_date||' AS start_date, '||l_curr_date||' AS end_date'||
               ' FROM '||l_view_name;

  END IF;

  --dbms_output.put_line(substr('Value of l_sql='||l_sql,1,255));

  -- Query is supposed to return just one record. However we take the first one.
  OPEN l_cursor FOR l_sql;
  -- Bug#2372091 FETCH l_cursor INTO x_period_id, x_period_name;
  FETCH l_cursor INTO x_period_id, x_period_name,l_start_date,l_end_date;
  CLOSE l_cursor;

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
END Get_Period_Info;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Kpi_Info(
    p_kpi_code 		IN NUMBER,
    p_analysis_option0 	IN NUMBER,
    p_analysis_option1 	IN NUMBER,
    p_analysis_option2 	IN NUMBER,
    p_series_id 	IN NUMBER,
    x_kpi_info_rec 	OUT NOCOPY BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Type
) IS

    l_kpi_info_rec BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Type;

    l_measure_id1		NUMBER;
    l_operation			VARCHAR2(2000);
    l_measure_id2		NUMBER;
    l_color_method      	NUMBER;
    l_measure_col1		VARCHAR2(2000);
    l_measure_operation1	VARCHAR2(2000);
    l_measure_col2		VARCHAR2(2000);
    l_measure_operation2	VARCHAR2(2000);

    l_return_status VARCHAR2(2000);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32000);

BEGIN

    l_kpi_info_rec.kpi_code := p_kpi_code;
    l_kpi_info_rec.analysis_option0 := p_analysis_option0;
    l_kpi_info_rec.analysis_option1 := p_analysis_option1;
    l_kpi_info_rec.analysis_option2 := p_analysis_option2;
    l_kpi_info_rec.series_id := p_series_id;

    -- Get dataset id
    Get_DataSet_Id(
        p_kpi_code => l_kpi_info_rec.kpi_code,
        p_analysis_option0 => l_kpi_info_rec.analysis_option0,
        p_analysis_option1 => l_kpi_info_rec.analysis_option1,
        p_analysis_option2 => l_kpi_info_rec.analysis_option2,
        p_series_id => l_kpi_info_rec.series_id,
        x_dataset_id => l_kpi_info_rec.dataset_id
    );

    --dbms_output.put_line('*l_kpi_info_rec.dataset_id='||l_kpi_info_rec.dataset_id);

    -- Get dataset info
    Get_DataSet_Info (
        p_dataset_id => l_kpi_info_rec.dataset_id,
        x_source => l_kpi_info_rec.dataset_source,
        x_measure_id1 => l_measure_id1,
        x_operation => l_operation,
        x_measure_id2 => l_measure_id2,
        x_color_method => l_color_method,
        x_measure_col1 => l_measure_col1,
        x_measure_operation1 => l_measure_operation1,
        x_measure_short_name => l_kpi_info_rec.measure_short_name,
        x_measure_col2 => l_measure_col2,
        x_measure_operation2 => l_measure_operation2,
	x_format_id  => l_kpi_info_rec.format_id
    );

    --dbms_output.put_line('*l_kpi_info_rec.dataset_source='||l_kpi_info_rec.dataset_source);
    --dbms_output.put_line('*l_kpi_info_rec.measure_short_name='||l_kpi_info_rec.measure_short_name);
    --dbms_output.put_line('*l_kpi_info_rec.format_id='||l_kpi_info_rec.format_id);

    IF l_kpi_info_rec.dataset_source = 'PMF' THEN
        IF is_measure_dbi(l_kpi_info_rec.measure_short_name) THEN
            l_kpi_info_rec.measure_dbi_flag := 'Y';
        ELSE
            l_kpi_info_rec.measure_dbi_flag := 'F';
        END IF;

        --dbms_output.put_line('*l_kpi_info_rec.measure_dbi_flag='||l_kpi_info_rec.measure_dbi_flag);

        -- Get pmf measure info
        Get_Pmf_Measure_Info(
            p_Measure_ShortName => l_kpi_info_rec.measure_short_name,
            x_measure_id => l_kpi_info_rec.measure_id,
            x_function_name => l_kpi_info_rec.function_name,
            x_region_code => l_kpi_info_rec.region_code,
            x_attribute_code => l_kpi_info_rec.actual_attribute_code,
            x_compareto_attribute_code => l_kpi_info_rec.compareto_attribute_code,
            x_dimension1_short_name => l_kpi_info_rec.dim1_short_name,
            x_dimension2_short_name => l_kpi_info_rec.dim2_short_name,
            x_dimension3_short_name => l_kpi_info_rec.dim3_short_name,
            x_dimension4_short_name => l_kpi_info_rec.dim4_short_name,
            x_dimension5_short_name => l_kpi_info_rec.dim5_short_name,
            x_dimension6_short_name => l_kpi_info_rec.dim6_short_name,
            x_dimension7_short_name => l_kpi_info_rec.dim7_short_name
        );

        --dbms_output.put_line('*l_kpi_info_rec.function_name='||l_kpi_info_rec.function_name);
        --dbms_output.put_line('*l_kpi_info_rec.region_code='||l_kpi_info_rec.region_code);
        --dbms_output.put_line('*l_kpi_info_rec.actual_attribute_code='||l_kpi_info_rec.actual_attribute_code);
        --dbms_output.put_line('*l_kpi_info_rec.compareto_attribute_code='||l_kpi_info_rec.compareto_attribute_code);
        --dbms_output.put_line('*l_kpi_info_rec.dimension1_short_name='||l_kpi_info_rec.dimension1_short_name);
        --dbms_output.put_line('*l_kpi_info_rec.dimension2_short_name='||l_kpi_info_rec.dimension2_short_name);
        --dbms_output.put_line('*l_kpi_info_rec.dimension3_short_name='||l_kpi_info_rec.dimension3_short_name);
        --dbms_output.put_line('*l_kpi_info_rec.dimension4_short_name='||l_kpi_info_rec.dimension4_short_name);
        --dbms_output.put_line('*l_kpi_info_rec.dimension5_short_name='||l_kpi_info_rec.dimension5_short_name);
        --dbms_output.put_line('*l_kpi_info_rec.dimension6_short_name='||l_kpi_info_rec.dimension6_short_name);
        --dbms_output.put_line('*l_kpi_info_rec.dimension7_short_name='||l_kpi_info_rec.dimension7_short_name);

        -- Get the dimension set
        Get_DimensionSet_Id(
            p_kpi_code => l_kpi_info_rec.kpi_code,
            p_analysis_option0 => l_kpi_info_rec.analysis_option0,
            p_analysis_option1 => l_kpi_info_rec.analysis_option1,
            p_analysis_option2 => l_kpi_info_rec.analysis_option2,
            p_series_id => l_kpi_info_rec.series_id,
            x_dimset_id => l_kpi_info_rec.dimset_id
        );

        --dbms_output.put_line('*l_kpi_info_rec.dimset_id='||l_kpi_info_rec.dimset_id);
    END IF;

    x_kpi_info_rec := l_kpi_info_rec;

END Get_Kpi_Info;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Pmf_Measure_Info (
    p_Measure_ShortName      	IN   VARCHAR2,
    x_measure_id 	     	OUT NOCOPY  NUMBER,
    x_function_name          	OUT NOCOPY  VARCHAR2,
    x_region_code            	OUT NOCOPY  VARCHAR2,
    x_attribute_code	     	OUT NOCOPY  VARCHAR2,
    x_compareto_attribute_code 	OUT NOCOPY  VARCHAR2,
    x_dimension1_short_name  	OUT NOCOPY  VARCHAR2,
    x_dimension2_short_name  	OUT NOCOPY  VARCHAR2,
    x_dimension3_short_name  	OUT NOCOPY  VARCHAR2,
    x_dimension4_short_name  	OUT NOCOPY  VARCHAR2,
    x_dimension5_short_name  	OUT NOCOPY  VARCHAR2,
    x_dimension6_short_name  	OUT NOCOPY  VARCHAR2,
    x_dimension7_short_name  	OUT NOCOPY  VARCHAR2
) IS

    l_return_status               VARCHAR2(32000);
    l_msg_count                   VARCHAR2(32000);
    l_msg_data                    VARCHAR2(32000);
    l_Measure_Short_Name          VARCHAR2(30);
    l_Measure_Name                bsc_sys_datasets_tl.name%TYPE;
    l_Description                 bsc_sys_datasets_tl.help%TYPE;
    l_Dimension1_ID               NUMBER;
    l_Dimension2_ID               NUMBER;
    l_Dimension3_ID               NUMBER;
    l_Dimension4_ID               NUMBER;
    l_Dimension5_ID               NUMBER;
    l_Dimension6_ID               NUMBER;
    l_Dimension7_ID               NUMBER;
    l_Unit_Of_Measure_Class       VARCHAR2(10);
    l_actual_data_source_type     VARCHAR2(30);
    l_actual_data_source          VARCHAR2(240);
    l_function_name               VARCHAR2(240);
    l_comparison_source           VARCHAR2(240);
    l_increase_in_measure         VARCHAR2(1);

    l_index NUMBER;
    l_region_code          VARCHAR2(240);

BEGIN

    BIS_PMF_DEFINER_WRAPPER_PVT.Retrieve_Performance_Measure(
        p_Measure_Short_Name =>  p_Measure_ShortName
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data  => l_msg_data
        ,x_Measure_ID => x_measure_id
        ,x_Measure_Short_Name => l_Measure_Short_Name
        ,x_Measure_Name => l_Measure_Name
        ,x_Description => l_Description
        ,x_Dimension1_ID => l_Dimension1_ID
        ,x_Dimension2_ID => l_Dimension2_ID
        ,x_Dimension3_ID => l_Dimension3_ID
        ,x_Dimension4_ID => l_Dimension4_ID
        ,x_Dimension5_ID => l_Dimension5_ID
        ,x_Dimension6_ID => l_Dimension6_ID
        ,x_Dimension7_ID => l_Dimension7_ID
        ,x_Unit_Of_Measure_Class  => l_Unit_Of_Measure_Class
        ,x_actual_data_source_type => l_actual_data_source_type
        ,x_actual_data_source => l_actual_data_source
        ,x_region_code =>  x_region_code
        ,x_attribute_code => x_attribute_code
        ,x_function_name => x_function_name
        ,x_comparison_source => l_comparison_source
        ,x_increase_in_measure => l_increase_in_measure
    );

    x_compareto_attribute_code := SUBSTR(l_comparison_source,(INSTR(l_comparison_source,'.',1,1)+1));

    x_dimension1_short_name := Get_Dimension_Short_Name(l_Dimension1_ID);
    x_dimension2_short_name := Get_Dimension_Short_Name(l_Dimension2_ID);
    x_dimension3_short_name := Get_Dimension_Short_Name(l_Dimension3_ID);
    x_dimension4_short_name := Get_Dimension_Short_Name(l_Dimension4_ID);
    x_dimension5_short_name := Get_Dimension_Short_Name(l_Dimension5_ID);
    x_dimension6_short_name := Get_Dimension_Short_Name(l_Dimension6_ID);
    x_dimension7_short_name := Get_Dimension_Short_Name(l_Dimension7_ID);

END Get_Pmf_Measure_Info;

/************************************************************************************
************************************************************************************/

FUNCTION Get_Target_Value(
    p_kpi_code 		IN NUMBER,
    p_analysis_option0	IN NUMBER,
    p_analysis_option1	IN NUMBER,
    p_analysis_option2	IN NUMBER,
    p_series_id		IN NUMBER,
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2
) RETURN VARCHAR2 IS

    l_value VARCHAR2(2000);

BEGIN
    l_value := NULL;

    SELECT budget_data INTO l_value
    FROM bsc_bis_measures_data
    WHERE user_id = p_user_id AND
          responsibility_id = p_responsibility_id AND
          indicator = p_kpi_code AND
          analysis_option0 = p_analysis_option0 AND
          analysis_option1 = p_analysis_option1 AND
          analysis_option2 = p_analysis_option2 AND
          series_id = p_series_id;

   RETURN l_value;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_value ;

END Get_Target_Value;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Target_Value_From_PMF(
    p_kpi_info_rec 		IN BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Type,
    p_user_id 			IN VARCHAR2,
    p_responsibility_id		IN VARCHAR2,
    p_dimension_levels		IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Tbl_Type,
    p_time_level		IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type,
    x_target_value		OUT NOCOPY VARCHAR2,
    x_return_status 		OUT NOCOPY VARCHAR2,
    x_msg_count 		OUT NOCOPY NUMBER,
    x_msg_data 			OUT NOCOPY VARCHAR2
) IS
    -- Measure Info
    l_measure_id 		NUMBER;
    l_measure_dimensions        BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Tbl_Type;

    l_region_code		VARCHAR2(2000) := NULL;
    l_function_name		VARCHAR2(2000) := NULL;
    l_actual_attribute_code    	VARCHAR2(2000) := NULL;
    l_compareto_attribute_code  VARCHAR2(2000) := NULL;

    -- Parameter to get target from pmf
    l_plan_id			NUMBER;
    l_target_level_rec 		BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
    l_target_rec 		BIS_TARGET_PUB.TARGET_REC_TYPE;
    l_target_level_rec_x 	BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
    l_target_rec_x 		BIS_TARGET_PUB.TARGET_REC_TYPE;
    l_error_tbl			BIS_UTILITIES_PUB.Error_Tbl_Type;

    -- Others
    l_i 			NUMBER;
    l_dimensionX_short_name	VARCHAR2(2000);
    l_dimension_level           BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type;
    l_total_dimlevel_short_name VARCHAR2(2000);
    l_total_dimlevel_value_id   NUMBER;
    l_total_dimlevel_value_name VARCHAR2(2000);
    l_dim_level_index		NUMBER;

BEGIN
    FND_MSG_PUB.initialize;

    x_target_value := NULL;

    --dbms_output.put_line('Begin  BSC_BIS_WRAPPER_PVT.Get_Target_Value_From_PMF' );

    -- Get pmf measure info
    l_measure_id := p_kpi_info_rec.measure_id;
    l_function_name := p_kpi_info_rec.function_name;
    l_region_code := p_kpi_info_rec.region_code;
    l_actual_attribute_code := p_kpi_info_rec.actual_attribute_code;
    l_compareto_attribute_code := p_kpi_info_rec.compareto_attribute_code;
    l_measure_dimensions(1).dimension_short_name := p_kpi_info_rec.dim1_short_name;
    l_measure_dimensions(2).dimension_short_name := p_kpi_info_rec.dim2_short_name;
    l_measure_dimensions(3).dimension_short_name := p_kpi_info_rec.dim3_short_name;
    l_measure_dimensions(4).dimension_short_name := p_kpi_info_rec.dim4_short_name;
    l_measure_dimensions(5).dimension_short_name := p_kpi_info_rec.dim5_short_name;
    l_measure_dimensions(6).dimension_short_name := p_kpi_info_rec.dim6_short_name;
    l_measure_dimensions(7).dimension_short_name := p_kpi_info_rec.dim7_short_name;

    --dbms_output.put_line('*l_function_name='||l_function_name);
    --dbms_output.put_line('*l_region_code='||l_region_code);
    --dbms_output.put_line('*l_actual_attribute_code='||l_actual_attribute_code);
    --dbms_output.put_line('*l_compareto_attribute_code='||l_compareto_attribute_code);
    --dbms_output.put_line('*l_measure_id='||l_measure_id);
    --dbms_output.put_line('*l_dimension1_short_name='||l_measure_dimensions(1).dimension_short_name);
    --dbms_output.put_line('*l_dimension2_short_name='||l_measure_dimensions(2).dimension_short_name);
    --dbms_output.put_line('*l_dimension3_short_name='||l_measure_dimensions(3).dimension_short_name);
    --dbms_output.put_line('*l_dimension4_short_name='||l_measure_dimensions(4).dimension_short_name);
    --dbms_output.put_line('*l_dimension5_short_name='||l_measure_dimensions(5).dimension_short_name);
    --dbms_output.put_line('*l_dimension6_short_name='||l_measure_dimensions(6).dimension_short_name);
    --dbms_output.put_line('*l_dimension7_short_name='||l_measure_dimensions(7).dimension_short_name);

    FOR l_i IN 1 .. 7 LOOP
        l_dimensionX_short_name := l_measure_dimensions(l_i).dimension_short_name;
        IF (l_dimensionX_short_name IS NOT NULL) THEN
            IF l_dimensionX_short_name = p_time_level.dimension_short_name THEN
                l_measure_dimensions(l_i).level_short_name := p_time_level.level_short_name;
	        l_measure_dimensions(l_i).level_value_id := p_time_level.level_value_id;
            ELSE
                l_dim_level_index := Get_Dimension_Level_Index(l_dimensionX_short_name, p_dimension_levels);
                IF l_dim_level_index = 0 THEN
                    -- A dimension level was not specified for this dimension
                    -- Then use the total dimension level
                    Get_Total_DimLevel_Info(
                        p_dimension_short_name => l_dimensionX_short_name,
                        x_total_dimlevel_short_name => l_total_dimlevel_short_name,
                        x_total_dimlevel_value_id => l_total_dimlevel_value_id,
                        x_total_dimlevel_value_name => l_total_dimlevel_value_name
                    );

                    l_measure_dimensions(l_i).level_short_name := l_total_dimlevel_short_name;
                    l_measure_dimensions(l_i).level_value_id := l_total_dimlevel_value_id;

                ELSE
                    l_dimension_level := p_dimension_levels(l_dim_level_index);
                    IF l_dimension_level.level_value_id IS NULL THEN
                        -- There is no an specific value for the dimension level
                        -- Then use the total dimension level
                        Get_Total_DimLevel_Info(
                            p_dimension_short_name => l_dimensionX_short_name,
                            x_total_dimlevel_short_name => l_total_dimlevel_short_name,
                            x_total_dimlevel_value_id => l_total_dimlevel_value_id,
                            x_total_dimlevel_value_name => l_total_dimlevel_value_name
                        );

                        l_measure_dimensions(l_i).level_short_name := l_total_dimlevel_short_name;
                        l_measure_dimensions(l_i).level_value_id := l_total_dimlevel_value_id;
                    ELSE
                        -- Exists an specific value for an specific level in the dimension
                        l_measure_dimensions(l_i).level_short_name := l_dimension_level.level_short_name;
                        l_measure_dimensions(l_i).level_value_id := l_dimension_level.level_value_id;
                    END IF;
                END IF;
            END IF;
        END IF;
    END LOOP;

    -- Set Target parameters:
    l_target_level_rec.dimension1_level_short_name := l_measure_dimensions(1).level_short_name;
    l_target_rec.dim1_level_value_id := l_measure_dimensions(1).level_value_id;
    l_target_level_rec.dimension2_level_short_name := l_measure_dimensions(2).level_short_name;
    l_target_rec.dim2_level_value_id := l_measure_dimensions(2).level_value_id;
    l_target_level_rec.dimension3_level_short_name := l_measure_dimensions(3).level_short_name;
    l_target_rec.dim3_level_value_id := l_measure_dimensions(3).level_value_id;
    l_target_level_rec.dimension4_level_short_name := l_measure_dimensions(4).level_short_name;
    l_target_rec.dim4_level_value_id := l_measure_dimensions(4).level_value_id;
    l_target_level_rec.dimension5_level_short_name := l_measure_dimensions(5).level_short_name;
    l_target_rec.dim5_level_value_id := l_measure_dimensions(5).level_value_id;
    l_target_level_rec.dimension6_level_short_name := l_measure_dimensions(6).level_short_name;
    l_target_rec.dim6_level_value_id := l_measure_dimensions(6).level_value_id;
    l_target_level_rec.dimension7_level_short_name := l_measure_dimensions(7).level_short_name;
    l_target_rec.dim7_level_value_id := l_measure_dimensions(7).level_value_id;

    --dbms_output.put_line('*l_target_level_rec.dimension1_level_short_name='||l_target_level_rec.dimension1_level_short_name);
    --dbms_output.put_line('*l_target_rec.dim1_level_value_id='||l_target_rec.dim1_level_value_id);
    --dbms_output.put_line('*l_target_level_rec.dimension2_level_short_name='||l_target_level_rec.dimension2_level_short_name);
    --dbms_output.put_line('*l_target_rec.dim2_level_value_id='||l_target_rec.dim2_level_value_id);
    --dbms_output.put_line('*l_target_level_rec.dimension3_level_short_name='||l_target_level_rec.dimension3_level_short_name);
    --dbms_output.put_line('*l_target_rec.dim3_level_value_id='||l_target_rec.dim3_level_value_id);
    --dbms_output.put_line('*l_target_level_rec.dimension4_level_short_name='||l_target_level_rec.dimension4_level_short_name);
    --dbms_output.put_line('*l_target_rec.dim4_level_value_id='||l_target_rec.dim4_level_value_id);
    --dbms_output.put_line('*l_target_level_rec.dimension5_level_short_name='||l_target_level_rec.dimension5_level_short_name);
    --dbms_output.put_line('*l_target_rec.dim5_level_value_id='||l_target_rec.dim5_level_value_id);
    --dbms_output.put_line('*l_target_level_rec.dimension6_level_short_name='||l_target_level_rec.dimension6_level_short_name);
    --dbms_output.put_line('*l_target_rec.dim6_level_value_id='||l_target_rec.dim6_level_value_id);
    --dbms_output.put_line('*l_target_level_rec.dimension7_level_short_name='||l_target_level_rec.dimension7_level_short_name);
    --dbms_output.put_line('*l_target_rec.dim7_level_value_id='||l_target_rec.dim7_level_value_id);

    -- Get the target for Standard Plan
    SELECT plan_id INTO l_plan_id
    FROM bisbv_business_plans
    WHERE short_name = 'STANDARD';

    --dbms_output.put_line('*l_plan_id='||l_plan_id);

    l_target_rec.plan_id := l_plan_id;

    -- Call the PMF API to get the target
    l_target_level_rec.measure_short_name := p_kpi_info_rec.measure_short_name;


    BIS_TARGET_PUB.RETRIEVE_TARGET_FROM_SHNMS (
        p_api_version       => 1.0
       ,p_target_level_rec => l_target_level_rec
       ,p_Target_Rec       => l_target_rec
       ,x_Target_Level_Rec => l_target_level_rec_x
       ,x_Target_Rec       => l_target_rec_x
       ,x_return_status    => x_return_status
       ,x_error_Tbl        => l_error_tbl
    );

    l_target_level_rec := l_target_level_rec_x;
    l_target_rec := l_target_rec_x;

    x_target_value := l_target_rec.target;

    --dbms_output.put_line('###########################');
    --dbms_output.put_line('l_target_level_rec.Measure_ID='||l_target_level_rec.Measure_ID);
    --dbms_output.put_line('l_target_level_rec.Measure_Short_Name='||l_target_level_rec.Measure_Short_Name);
    --dbms_output.put_line('l_target_level_rec.Measure_Name='||l_target_level_rec.Measure_Name);
    --dbms_output.put_line('l_target_level_rec.Target_Level_ID='||l_target_level_rec.Target_Level_ID);
    --dbms_output.put_line('l_target_level_rec.Target_Level_Short_Name='||l_target_level_rec.Target_Level_Short_Name);
    --dbms_output.put_line('l_target_level_rec.Target_Level_Name='||l_target_level_rec.Target_Level_Name);
    --dbms_output.put_line('l_target_level_rec.Description='||l_target_level_rec.Description);
    --dbms_output.put_line('l_target_level_rec.Org_Level_ID='||l_target_level_rec.Org_Level_ID);
    --dbms_output.put_line('l_target_level_rec.Org_Level_Short_Name='||l_target_level_rec.Org_Level_Short_Name);
    --dbms_output.put_line('l_target_level_rec.Org_Level_Name='||l_target_level_rec.Org_Level_Name);
    --dbms_output.put_line('l_target_level_rec.Time_Level_ID='||l_target_level_rec.Time_Level_ID);
    --dbms_output.put_line('l_target_level_rec.Time_Level_Short_Name='||l_target_level_rec.Time_Level_Short_Name);
    --dbms_output.put_line('l_target_level_rec.Time_Level_Name='||l_target_level_rec.Time_Level_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension1_Level_ID='||l_target_level_rec.Dimension1_Level_ID);
    --dbms_output.put_line('l_target_level_rec.Dimension1_Level_Short_Name='||l_target_level_rec.Dimension1_Level_Short_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension1_Level_Name='||l_target_level_rec.Dimension1_Level_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension2_Level_ID='||l_target_level_rec.Dimension2_Level_ID);
    --dbms_output.put_line('l_target_level_rec.Dimension2_Level_Short_Name='||l_target_level_rec.Dimension2_Level_Short_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension2_Level_Name='||l_target_level_rec.Dimension2_Level_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension3_Level_ID='||l_target_level_rec.Dimension3_Level_ID);
    --dbms_output.put_line('l_target_level_rec.Dimension3_Level_Short_Name='||l_target_level_rec.Dimension3_Level_Short_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension3_Level_Name='||l_target_level_rec.Dimension3_Level_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension4_Level_ID='||l_target_level_rec.Dimension4_Level_ID);
    --dbms_output.put_line('l_target_level_rec.Dimension4_Level_Short_Name='||l_target_level_rec.Dimension4_Level_Short_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension4_Level_Name='||l_target_level_rec.Dimension4_Level_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension5_Level_ID='||l_target_level_rec.Dimension5_Level_ID);
    --dbms_output.put_line('l_target_level_rec.Dimension5_Level_Short_Name='||l_target_level_rec.Dimension5_Level_Short_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension5_Level_Name='||l_target_level_rec.Dimension5_Level_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension6_Level_ID='||l_target_level_rec.Dimension6_Level_ID);
    --dbms_output.put_line('l_target_level_rec.Dimension6_Level_Short_Name='||l_target_level_rec.Dimension6_Level_Short_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension6_Level_Name='||l_target_level_rec.Dimension6_Level_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension7_Level_ID='||l_target_level_rec.Dimension7_Level_ID);
    --dbms_output.put_line('l_target_level_rec.Dimension7_Level_Short_Name='||l_target_level_rec.Dimension7_Level_Short_Name);
    --dbms_output.put_line('l_target_level_rec.Dimension7_Level_Name='||l_target_level_rec.Dimension7_Level_Name);
    --dbms_output.put_line('l_target_level_rec.Report_Function_ID='||l_target_level_rec.Report_Function_ID);
    --dbms_output.put_line('l_target_level_rec.Report_Function_Name='||l_target_level_rec.Report_Function_Name);
    --dbms_output.put_line('l_target_level_rec.Report_User_Function_Name='||l_target_level_rec.Report_User_Function_Name);
    --dbms_output.put_line('l_target_level_rec.Unit_Of_Measure='||l_target_level_rec.Unit_Of_Measure);
    --dbms_output.put_line('l_target_level_rec.Source='||l_target_level_rec.Source);
    --dbms_output.put_line('###########################');
    --dbms_output.put_line('l_target_rec.Target_ID='||l_target_rec.Target_ID);
    --dbms_output.put_line('l_target_rec.Target_Level_ID='||l_target_rec.Target_Level_ID);
    --dbms_output.put_line('l_target_rec.Target_Level_Short_Name='||l_target_rec.Target_Level_Short_Name);
    --dbms_output.put_line('l_target_rec.Target_Level_Name='||l_target_rec.Target_Level_Name);
    --dbms_output.put_line('l_target_rec.Plan_ID='||l_target_rec.Plan_ID);
    --dbms_output.put_line('l_target_rec.Plan_Short_Name='||l_target_rec.Plan_Short_Name);
    --dbms_output.put_line('l_target_rec.Plan_Name='||l_target_rec.Plan_Name);
    --dbms_output.put_line('l_target_rec.Org_level_value_id='||l_target_rec.Org_level_value_id);
    --dbms_output.put_line('l_target_rec.Org_level_value_name='||l_target_rec.Org_level_value_name);
    --dbms_output.put_line('l_target_rec.Time_level_Value_id='||l_target_rec.Time_level_Value_id);
    --dbms_output.put_line('l_target_rec.Time_level_Value_name='||l_target_rec.Time_level_Value_name);
    --dbms_output.put_line('l_target_rec.Dim1_Level_Value_ID='||l_target_rec.Dim1_Level_Value_ID);
    --dbms_output.put_line('l_target_rec.Dim1_Level_Value_Name='||l_target_rec.Dim1_Level_Value_Name);
    --dbms_output.put_line('l_target_rec.Dim2_Level_Value_ID='||l_target_rec.Dim2_Level_Value_ID);
    --dbms_output.put_line('l_target_rec.Dim2_Level_Value_Name='||l_target_rec.Dim2_Level_Value_Name);
    --dbms_output.put_line('l_target_rec.Dim3_Level_Value_ID='||l_target_rec.Dim3_Level_Value_ID);
    --dbms_output.put_line('l_target_rec.Dim3_Level_Value_Name='||l_target_rec.Dim3_Level_Value_Name);
    --dbms_output.put_line('l_target_rec.Dim4_Level_Value_ID='||l_target_rec.Dim4_Level_Value_ID);
    --dbms_output.put_line('l_target_rec.Dim4_Level_Value_Name='||l_target_rec.Dim4_Level_Value_Name);
    --dbms_output.put_line('l_target_rec.Dim5_Level_Value_ID='||l_target_rec.Dim5_Level_Value_ID);
    --dbms_output.put_line('l_target_rec.Dim5_Level_Value_Name='||l_target_rec.Dim5_Level_Value_Name);
    --dbms_output.put_line('l_target_rec.Dim6_Level_Value_ID='||l_target_rec.Dim6_Level_Value_ID);
    --dbms_output.put_line('l_target_rec.Dim6_Level_Value_Name='||l_target_rec.Dim6_Level_Value_Name);
    --dbms_output.put_line('l_target_rec.Dim7_Level_Value_ID='||l_target_rec.Dim7_Level_Value_ID);
    --dbms_output.put_line('l_target_rec.Dim7_Level_Value_Name='||l_target_rec.Dim7_Level_Value_Name);
    --dbms_output.put_line('l_target_rec.Target='||l_target_rec.Target);
    --dbms_output.put_line('l_target_rec.Range1_low='||l_target_rec.Range1_low);
    --dbms_output.put_line('l_target_rec.Range1_high='||l_target_rec.Range1_high);
    --dbms_output.put_line('l_target_rec.Range2_low='||l_target_rec.Range2_low);
    --dbms_output.put_line('l_target_rec.Range2_high='||l_target_rec.Range2_high);
    --dbms_output.put_line('l_target_rec.Range3_low='||l_target_rec.Range3_low);
    --dbms_output.put_line('l_target_rec.Range3_high='||l_target_rec.Range3_high);
    --dbms_output.put_line('############## ERRORS ##########');
    --FOR l_i IN 1 .. l_error_tbl.COUNT LOOP
    --   dbms_output.put_line('Error_Description='||l_error_tbl(l_i).Error_Description);
    --END LOOP;

    --dbms_output.put_line('End  BSC_BIS_WRAPPER_PVT.Get_Target_Value_From_PMF' );

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
END Get_Target_Value_From_PMF;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Total_DimLevel_Info(
    p_dimension_short_name IN VARCHAR2,
    x_total_dimlevel_short_name OUT NOCOPY VARCHAR2,
    x_total_dimlevel_value_id OUT NOCOPY NUMBER,
    x_total_dimlevel_value_name OUT NOCOPY VARCHAR2
) IS

    TYPE RefCurTyp IS REF CURSOR;
    cv RefCurTyp;

    l_sql VARCHAR2(32000);
    l_source VARCHAR2(2000);
    l_length NUMBER;

    l_select_string VARCHAR2(32000);
    l_view_name VARCHAR2(2000);
    l_id_name VARCHAR2(2000);
    l_value_name VARCHAR2(2000);

    l_return_status VARCHAR2(2000);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32000);

BEGIN
    IF p_dimension_short_name IS NULL THEN
        RETURN;
    END IF;

    l_sql := 'SELECT DISTINCT l.source'||
             ' FROM bis_levels l, bis_dimensions d'||
             ' WHERE d.dimension_id = l.dimension_id AND d.short_name = :1';

    OPEN cv FOR l_sql USING p_dimension_short_name;
    FETCH cv INTO l_source;
    IF cv%NOTFOUND THEN
        l_source := 'OLTP';
    END IF;
    CLOSE cv;

    IF (l_source = 'EDW') THEN
        l_length := length(p_dimension_short_name);
        x_total_dimlevel_short_name := substr(p_dimension_short_name,1,(l_length-1) );
        x_total_dimlevel_short_name := x_total_dimlevel_short_name||'A';
    END IF;
    IF (l_source = 'OLTP') THEN
        -- This is not always true
        -- x_total_dimlevel_short_name := 'TOTAL_'||p_dimension_short_name;

        -- The total dimension level starts with TOTAL
       l_sql := 'SELECT DISTINCT l.short_name'||
                ' FROM bis_levels l, bis_dimensions d'||
                ' WHERE d.dimension_id = l.dimension_id AND'||
                ' d.short_name = :1 AND l.short_name LIKE ''TOTAL%''';

       OPEN cv FOR l_sql USING p_dimension_short_name;
       FETCH cv INTO  x_total_dimlevel_short_name;
       CLOSE cv;
    END IF;

    BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING (
        p_DimLevelShortName => x_total_dimlevel_short_name
        ,p_bis_source => l_source
        ,x_Select_String => l_select_string
        ,x_table_name => l_view_name
        ,x_id_name => l_id_name
        ,x_value_name => l_value_name
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
    );

    IF l_msg_count > 0 THEN
    	RETURN;
    END IF;

    l_sql := 'SELECT DISTINCT '||l_id_name||', '||l_value_name||
             ' FROM '||l_view_name;

    -- Query is supposed to return just one record. However we take the first one.
    OPEN cv FOR l_sql;
    FETCH cv INTO x_total_dimlevel_value_id, x_total_dimlevel_value_name;
    CLOSE cv;

END Get_Total_DimLevel_Info;

/************************************************************************************
************************************************************************************/

FUNCTION Get_Dimension_Level_Index(
    p_dimension_short_name IN VARCHAR2
    ,p_dimension_levels    IN BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Tbl_Type
) RETURN NUMBER IS
    l_index		NUMBER := 0;
BEGIN

    IF p_dimension_short_name IS NULL THEN
        RETURN l_index;
    END IF;

    FOR l_index IN 1 .. p_dimension_levels.COUNT LOOP
        IF p_dimension_short_name = p_dimension_levels(l_index).dimension_short_name THEN
            RETURN l_index;
        END IF;
    END LOOP;

    l_index := 0;
    RETURN l_index;

END Get_Dimension_Level_Index;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Default_Time_Level(
    p_kpi_code 			IN NUMBER
    ,p_dimset_id 		IN NUMBER
    ,x_time_dimension_level 	OUT NOCOPY BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type
) IS

    TYPE RefCurTyp IS REF CURSOR;
    cv 		RefCurTyp;
    l_sql 	VARCHAR2(32000);
    l_dim_level	BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type;

BEGIN

    -- By design, the ViewBy dimension Level is define in the column BKL.DEFAULT_VALUE with the value 'C'
    -- The other Default Dimension Levels are define in the column BKL.DEFAULT_VALUE with the value 'LD'

    l_sql := 'SELECT BID.SHORT_NAME DIMENSION_SHORTNAME, '||
		'	BKL.LEVEL_SHORTNAME '||
		' FROM BSC_KPI_DIM_LEVELS_VL BKL,'||
		'     BIS_LEVELS BIL,'||
		'     BIS_DIMENSIONS BID'||
		' WHERE BKL.INDICATOR = :1 AND'||
		'   BKL.DIM_SET_ID = :2 AND'||
		'   BKL.LEVEL_SOURCE = ''PMF'' AND'||
		'   (BKL.DEFAULT_VALUE = ''C'' OR BKL.DEFAULT_VALUE = ''LD'' ) AND'||
		'   BKL.LEVEL_SHORTNAME = BIL.SHORT_NAME AND'||
		'   BIL.DIMENSION_ID = BID.DIMENSION_ID'||
		' ORDER BY DIMENSION_SHORTNAME, BKL.DIM_LEVEL_INDEX';

    OPEN cv FOR l_sql USING p_kpi_code, p_dimset_id;
    LOOP
        FETCH cv INTO l_dim_level.dimension_short_name, l_dim_level.level_short_name;
        EXIT WHEN cv%NOTFOUND;

        IF Is_Time_Dimension(l_dim_level.dimension_short_name) THEN
            x_time_dimension_level := l_dim_level;
            CLOSE cv;
            RETURN;
	END IF;
    END LOOP;
    CLOSE cv;

END Get_Default_Time_Level;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Default_Dimension_Levels(
    p_kpi_code 			IN NUMBER,
    p_dimset_id 		IN NUMBER,
    p_page_parameters		IN BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type,
    x_default_dimension_levels 	OUT NOCOPY BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Tbl_Type,
    x_default_time_level_from 	OUT NOCOPY BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type,
    x_default_time_level_to 	OUT NOCOPY BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type
) IS

    TYPE RefCurTyp IS REF CURSOR;
    cv RefCurTyp;
    l_sql 			VARCHAR2(32000);
    i				NUMBER := 1;

    l_default_dimension_levels 	BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Tbl_Type;
    l_default_time_level_from 	BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type;
    l_default_time_level_to 	BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type;

    l_dimension_short_name	VARCHAR2(2000);
    l_level_short_name		VARCHAR2(2000);
    l_default_flag		NUMBER;

    l_page_parameter_name	VARCHAR2(32000);
    l_page_parameter      	BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Type;
    l_dimension_level		BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type;
    l_dimension_level_index	NUMBER;

    -- parameters to get current period info
    l_dim_source		VARCHAR2(2000);
    l_org_dim_level_short_name	VARCHAR2(2000);
    l_org_dim_level_value_id    VARCHAR2(2000);
    l_current_period_id		VARCHAR2(2000);
    l_current_period_name	VARCHAR2(2000);

    l_return_status VARCHAR2(2000);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32000);

BEGIN

    -- By design, the ViewBy dimension Level is define in the column BKL.DEFAULT_VALUE with the value 'C'
    -- The other Default Dimension Levels are define in the column BKL.DEFAULT_VALUE with the value 'LD'

    --dbms_OUTPUT.PUT_LINE('Begin BSC_BIS_WRAPPER_PVT.Get_Default_Dimension_Levels' );

    l_sql := 'SELECT BID.SHORT_NAME DIMENSION_SHORTNAME, '||
		'	BKL.LEVEL_SHORTNAME, '||
		'       DECODE(BKL.DEFAULT_VALUE,''C'', 1, ''LD'', 1, 0)  DEFAULT_FLAG '||
		' FROM BSC_KPI_DIM_LEVELS_VL BKL,'||
		'     BIS_LEVELS BIL,'||
		'     BIS_DIMENSIONS BID'||
		' WHERE BKL.INDICATOR = :1 AND'||
		'   BKL.DIM_SET_ID = :2 AND'||
		'   BKL.LEVEL_SOURCE = ''PMF'' AND'||
		'   BKL.LEVEL_SHORTNAME = BIL.SHORT_NAME AND'||
		'   BIL.DIMENSION_ID = BID.DIMENSION_ID';

    OPEN cv FOR l_sql USING p_kpi_code, p_dimset_id;
    LOOP
        FETCH cv INTO l_dimension_short_name, l_level_short_name, l_default_flag;
        EXIT WHEN cv%NOTFOUND;

        --dbms_output.put_line('-* l_dimension_short_name='||l_dimension_short_name);
        --dbms_output.put_line('-* l_level_short_name='||l_level_short_name);
        --dbms_output.put_line('-* l_default_flag='||l_default_flag);

        l_page_parameter_name := l_dimension_short_name||'+'||l_level_short_name;
        IF Is_Time_Dimension(l_dimension_short_name) THEN
            l_page_parameter_name := l_page_parameter_name||'_FROM';
        END IF;

        Get_Page_Parameter(
            p_page_parameters => p_page_parameters,
            p_page_parameter_name => l_page_parameter_name,
            x_page_parameter => l_page_parameter
        );

        IF l_page_parameter.parameter_name IS NULL THEN
            IF l_default_flag = 1 THEN
                -- There is no page parameter for this dimension level and the dimension level
                -- is the default dimension level.
                -- So we need to add this parameter, but we need to check that no other
                -- dimension level of the same dimension has been assigned before.
                -- The only case is when another dimension level of the same dimension exists
                -- in the page parameters.
                l_dimension_level_index := Get_Dimension_Level_Index(l_dimension_short_name,
                                                                     l_default_dimension_levels);

                IF l_dimension_level_index = 0 THEN
                    -- The dimension level has not been assigned before
                    l_dimension_level.dimension_short_name := l_dimension_short_name;
                    l_dimension_level.level_short_name := l_level_short_name;
                    l_dimension_level.level_value_id := NULL;
                    l_dimension_level.level_value_name := NULL;

                    IF Is_Time_Dimension(l_dimension_short_name) THEN
                        l_default_time_level_from := l_dimension_level;
                        l_default_time_level_to := l_dimension_level;
                    ELSE
                        l_default_dimension_levels(i) := l_dimension_level;
                        i := i + 1;
                    END IF;
                END IF;
            END IF;
        ELSE
            -- The dimension level is used by the kpi and also is a page parameter
            -- It needs to use that dimension level with the specific value
            IF Is_Time_Dimension(l_dimension_short_name) THEN
                -- l_page_parameter contains the time _FROM parameter
                l_default_time_level_from.dimension_short_name := l_dimension_short_name;
                l_default_time_level_from.level_short_name := l_level_short_name;
                l_default_time_level_from.level_value_id := l_page_parameter.value_id;
                l_default_time_level_from.level_value_name := l_page_parameter.value_name;

                -- If exists the time_from parameter must exist time_to parameter
                l_page_parameter_name := l_dimension_short_name||'+'||l_level_short_name||'_TO';
                Get_Page_Parameter(
                    p_page_parameters => p_page_parameters,
                    p_page_parameter_name => l_page_parameter_name,
                    x_page_parameter => l_page_parameter
                );

                l_default_time_level_to.dimension_short_name := l_dimension_short_name;
                l_default_time_level_to.level_short_name := l_level_short_name;
                l_default_time_level_to.level_value_id := l_page_parameter.value_id;
                l_default_time_level_to.level_value_name := l_page_parameter.value_name;
            ELSE
                l_dimension_level.dimension_short_name := l_dimension_short_name;
                l_dimension_level.level_short_name := l_level_short_name;
                l_dimension_level.level_value_id := l_page_parameter.value_id;
                l_dimension_level.level_value_name := l_page_parameter.value_name;

                -- If already exists, it needs to overwrite it. If not then add it.
                l_dimension_level_index := Get_Dimension_Level_Index(l_dimension_short_name,
                                                                     l_default_dimension_levels);
                IF l_dimension_level_index = 0 THEN
                    l_default_dimension_levels(i) := l_dimension_level;
                    i := i + 1;
                ELSE
                    l_default_dimension_levels(l_dimension_level_index) := l_dimension_level;
                END IF;
            END IF;
        END IF;

    END LOOP;
    CLOSE cv;

    -- If the time level exists, and there is no value specified by a page parameter
    -- then we need to set it with the current period
    IF (l_default_time_level_from.dimension_short_name IS NOT NULL) AND
       (l_default_time_level_from.level_value_id IS NULL) THEN
        IF l_default_time_level_from.dimension_short_name = 'TIME' THEN
            -- OLTP
            l_dim_source := 'OLTP';
            l_org_dim_level_short_name := 'TOTAL_ORGANIZATIONS';
            l_org_dim_level_value_id := '-1';
        ELSE
            -- EDW
            l_dim_source := 'EDW';
            l_org_dim_level_short_name := NULL;
            l_org_dim_level_value_id := NULL;
        END IF;

        Get_Period_Info(
            p_time_dim_level_short_name => l_default_time_level_from.level_short_name,
            p_source => l_dim_source,
            p_org_dim_level_short_name => l_org_dim_level_short_name,
            p_org_dim_level_value_id => l_org_dim_level_value_id,
            p_period_date => SYSDATE, --TO_DATE('04-15-2001','MM-DD-YYYY'),
            x_period_id => l_current_period_id,
            x_period_name => l_current_period_name,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data
        );

        l_default_time_level_from.level_value_id := l_current_period_id;
        l_default_time_level_from.level_value_name := l_current_period_name;
        l_default_time_level_to.level_value_id := l_current_period_id;
        l_default_time_level_to.level_value_name := l_current_period_name;
    END IF;


    x_default_dimension_levels := l_default_dimension_levels;
    x_default_time_level_from := l_default_time_level_from;
    x_default_time_level_to  := l_default_time_level_to;

    -- dbms_output.put_line('End BSC_BIS_WRAPPER_PVT.Get_Default_Dimension_Levels');
    --FOR i IN 1..x_default_dimension_levels.COUNT LOOP
    --    dbms_output.put_line('x_default_dimension_levels(i).dimension_short_name='||x_default_dimension_levels(i).dimension_short_name);
    --    dbms_output.put_line('x_default_dimension_levels(i).level_short_name='||x_default_dimension_levels(i).level_short_name);
    --    dbms_output.put_line('x_default_dimension_levels(i).level_value_id='||x_default_dimension_levels(i).level_value_id);
    --    dbms_output.put_line('x_default_dimension_levels(i).level_value_name='||x_default_dimension_levels(i).level_value_nane);
    --END LOOP;
    --dbms_output.put_line('x_default_time_level_from.dimension_short_name='||x_default_time_level_from.dimension_short_name);
    --dbms_output.put_line('x_default_time_level_from.level_short_name='||x_default_time_level_from.level_short_name);
    --dbms_output.put_line('x_default_time_level_from.level_value_id='||x_default_time_level_from.level_value_id);
    --dbms_output.put_line('x_default_time_level_from.level_value_name='||x_default_time_level_from.level_value_name);
    --dbms_output.put_line('x_default_time_level_to.dimension_short_name='||x_default_time_level_to.dimension_short_name);
    --dbms_output.put_line('x_default_time_level_to.level_short_name='||x_default_time_level_to.level_short_name);
    --dbms_output.put_line('x_default_time_level_to.level_value_id='||x_default_time_level_to.level_value_id);
    --dbms_output.put_line('x_default_time_level_to.level_value_name='||x_default_time_level_to.level_value_name);

END Get_Default_Dimension_Levels;

/************************************************************************************
************************************************************************************/

FUNCTION Is_Time_Dimension(
    p_dimension_short_name IN VARCHAR2
) RETURN BOOLEAN IS

BEGIN

    IF (p_dimension_short_name = 'TIME') OR (p_dimension_short_name = 'EDW_TIME_M') THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Is_Time_Dimension;

/************************************************************************************
************************************************************************************/

PROCEDURE Populate_Measure_Data(
    p_tab_id		IN NUMBER,
    p_page_id		IN VARCHAR2,
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2,
    p_caching_key	IN VARCHAR2,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count 	OUT NOCOPY NUMBER,
    x_msg_data 		OUT NOCOPY VARCHAR2
) IS

    TYPE tCursor IS REF CURSOR;

    cv 			tCursor;
    l_sql 		VARCHAR2(32000);

    cv_caching 		tCursor;
    l_caching_sql 	VARCHAR2(32000);
    l_insert_sql	VARCHAR2(32000);
    l_update_sql        VARCHAR2(32000);

    l_kpi_code 		NUMBER;
    l_analysis_option0	NUMBER;
    l_analysis_option1	NUMBER;
    l_analysis_option2	NUMBER;
    l_series_id		NUMBER;

    l_kpi_info_rec	BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Type;
    l_kpi_info_tbl	BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Tbl_Type;

    l_caching_key       VARCHAR2(200);
    i			NUMBER := 1;

    l_return_status VARCHAR2(2000);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32000);

    l_db_user_id	NUMBER;
    l_sysdate		DATE := SYSDATE;

    l_page_parameters	BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type;

BEGIN
    FND_MSG_PUB.initialize;

    -- Get the database user id
    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    l_db_user_id := BSC_APPS.fnd_global_user_id;

    --dbms_output.put_line('*l_db_user_id='||l_db_user_id);

    --Delete from BSC_BIS_MEASURES_DATA kpis that belong to the given tab, which has
    --been deleted, has been changed or user has not access.

    DELETE FROM
        bsc_bis_measures_data m
    WHERE
        m.user_id = p_user_id AND
        m.responsibility_id = p_responsibility_id AND
        m.indicator IN (
            SELECT
                tk.indicator
            FROM
                bsc_tab_indicators tk
            WHERE
                tk.tab_id = p_tab_id
        ) AND (
        m.indicator NOT IN (
            SELECT
                a.indicator
            FROM
                bsc_user_kpi_access a
            WHERE
                a.responsibility_id = p_responsibility_id
        ) OR
        m.indicator = (
            SELECT
                k.indicator
            FROM
                bsc_kpis_b k
            WHERE
                k.indicator = m.indicator AND (
                k.prototype_flag = 2 OR
                k.last_update_date > m.last_update_date)
        ));

    --dbms_output.put_line('*after delete');

    -- Populate BSC_BIS_MEASURES_DATA for the default analysis combination
    -- of each kpi which user has access and belongs to the given tab.

    l_sql :=  'SELECT tk.indicator'||
              ' FROM bsc_tab_indicators tk, bsc_user_kpi_access ka'||
              ' WHERE tk.tab_id = :1 AND tk.indicator = ka.indicator AND ka.responsibility_id = :2';

    l_caching_sql := 'SELECT caching_key'||
                     ' FROM bsc_bis_measures_data'||
                     ' WHERE user_id = :1 AND responsibility_id = :2 AND indicator = :3 AND'||
                     ' analysis_option0 = :4 AND analysis_option1 = :5 AND analysis_option2 = :6 AND'||
                     ' series_id = :7';

    l_update_sql := 'UPDATE bsc_bis_measures_data'||
                    ' SET actual_data = :a, budget_data = :b, caching_key = :c,'||
                    ' last_updated_by = :d, last_update_date = :e'||
                    ' WHERE user_id = :f AND responsibility_id = :g AND indicator = :h AND'||
                    ' analysis_option0 = :i AND analysis_option1 = :j AND analysis_option2 = :k AND'||
                    ' series_id = :l';

    l_insert_sql := 'INSERT INTO bsc_bis_measures_data (user_id, responsibility_id, indicator,'||
                    ' analysis_option0, analysis_option1, analysis_option2, series_id,'||
                    ' caching_key, actual_data, budget_data, created_by, creation_date,'||
                    ' last_updated_by, last_update_date, last_update_login)'||
                    ' VALUES (:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n, :o)';

    -- Get page parameters
    IF p_page_id IS NOT NULL THEN
        Get_Page_Parameters(
            p_user_id => p_user_id,
            p_page_id => p_page_id,
            x_page_parameters => l_page_parameters,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data
        );
    END IF;

    OPEN cv FOR l_sql USING p_tab_id, p_responsibility_id;
    LOOP
        FETCH cv INTO l_kpi_code;
        EXIT WHEN cv%NOTFOUND;

        --dbms_output.put_line('*l_kpi_code='||l_kpi_code);

        -- Get the default analysis option combination
        BSC_BIS_WRAPPER_PVT.Get_AO_Defaults(
	    			p_kpi_code  => l_kpi_code,
	    			x_analysis_option0 => l_analysis_option0,
	    			x_analysis_option1 => l_analysis_option1,
	    			x_analysis_option2 => l_analysis_option2,
	    			x_series_id => l_series_id);

        --dbms_output.put_line('*l_analysis_option0='||l_analysis_option0);
        --dbms_output.put_line('*l_analysis_option1='||l_analysis_option1);
        --dbms_output.put_line('*l_analysis_option2='||l_analysis_option2);
        --dbms_output.put_line('*l_series_id='||l_series_id);


        IF (l_kpi_code IS NOT NULL) AND (l_analysis_option0 IS NOT NULL) AND
           (l_analysis_option1 IS NOT NULL) AND (l_analysis_option2 IS NOT NULL) AND
           (l_series_id IS NOT NULL) THEN

            -- Get the caching key
            l_caching_key := NULL;
            OPEN cv_caching FOR l_caching_sql USING p_user_id, p_responsibility_id, l_kpi_code,
                l_analysis_option0, l_analysis_option1, l_analysis_option2, l_series_id;
            FETCH cv_caching INTO l_caching_key;
            IF cv_caching%FOUND THEN
                --dbms_output.put_line('*l_caching_key='||l_caching_key);

                -- The record exists --> Calculate data and update if caching key is different
                IF (l_caching_key IS NULL) OR (l_caching_key <> p_caching_key) THEN
                    Get_Kpi_Info(
                        p_kpi_code => l_kpi_code,
	    		p_analysis_option0 => l_analysis_option0,
	    		p_analysis_option1 => l_analysis_option1,
	    		p_analysis_option2 => l_analysis_option2,
	    		p_series_id => l_series_id,
                        x_kpi_info_rec	=> l_kpi_info_rec
                    );

                    l_kpi_info_rec.insert_update_flag := 'U';

                    l_kpi_info_tbl(i) := l_kpi_info_rec;
                    i := i + 1;

                END IF;
            ELSE
                -- The record does not exists --> Calculate data and Insert
                    Get_Kpi_Info(
                        p_kpi_code => l_kpi_code,
	    		p_analysis_option0 => l_analysis_option0,
	    		p_analysis_option1 => l_analysis_option1,
	    		p_analysis_option2 => l_analysis_option2,
	    		p_series_id => l_series_id,
                        x_kpi_info_rec	=> l_kpi_info_rec
                    );

                l_kpi_info_rec.insert_update_flag := 'I';

                l_kpi_info_tbl(i) := l_kpi_info_rec;
                i := i + 1;

            END IF;
            CLOSE cv_caching;
        END IF;
    END LOOP;
    CLOSE cv;

    -- Calculate Kpis Data
    Get_Kpis_Data_From_PMF_PMV(
	p_user_id => p_user_id,
    	p_responsibility_id => p_responsibility_id,
        p_page_parameters => l_page_parameters,
        p_page_id => p_page_id,
        p_kpi_info_tbl => l_kpi_info_tbl,
	x_return_status	=> l_return_status,
	x_msg_count => l_msg_count,
	x_msg_data => l_msg_data
    );

    -- Insert/Update
    FOR i IN 1..l_kpi_info_tbl.COUNT LOOP
        IF l_kpi_info_tbl(i).insert_update_flag = 'U' THEN
            -- Update actual and target in BSC_BIS_MEASURES_DATA
            EXECUTE IMMEDIATE l_update_sql USING l_kpi_info_tbl(i).actual_value,
                   l_kpi_info_tbl(i).target_value, p_caching_key, l_db_user_id,
                   l_sysdate, p_user_id, p_responsibility_id, l_kpi_info_tbl(i).kpi_code,
                   l_kpi_info_tbl(i).analysis_option0, l_kpi_info_tbl(i).analysis_option1,
                   l_kpi_info_tbl(i).analysis_option2, l_kpi_info_tbl(i).series_id;

            --dbms_output.put_line('*update executed');
        ELSE
            -- Insert actual and target in BSC_BIS_MEASURES_DATA
            EXECUTE IMMEDIATE l_insert_sql USING p_user_id, p_responsibility_id,
                 l_kpi_info_tbl(i).kpi_code, l_kpi_info_tbl(i).analysis_option0,
                 l_kpi_info_tbl(i).analysis_option1, l_kpi_info_tbl(i).analysis_option2,
                 l_kpi_info_tbl(i).series_id, p_caching_key,
                 l_kpi_info_tbl(i).actual_value, l_kpi_info_tbl(i).target_value,
                 l_db_user_id, l_sysdate, l_db_user_id, l_sysdate, l_db_user_id;

            --dbms_output.put_line('*insert executed');
        END IF;

        --dbms_output.put_line('--------------------------------------------');
        --dbms_output.put_line('l_kpi_info_tbl('||i||').kpi_code='||l_kpi_info_tbl(i).kpi_code);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').analysis_option0='||l_kpi_info_tbl(i).analysis_option0);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').analysis_option1='||l_kpi_info_tbl(i).analysis_option1);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').analysis_option2='||l_kpi_info_tbl(i).analysis_option2);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').series_id='||l_kpi_info_tbl(i).series_id);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dataset_id='||l_kpi_info_tbl(i).dataset_id);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dataset_source='||l_kpi_info_tbl(i).dataset_source);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').measure_short_name='||l_kpi_info_tbl(i).measure_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').measure_dbi_flag='||l_kpi_info_tbl(i).measure_dbi_flag);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').measure_id='||l_kpi_info_tbl(i).measure_id);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').region_code='||l_kpi_info_tbl(i).region_code);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').function_name='||l_kpi_info_tbl(i).function_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').actual_attribute_code='||l_kpi_info_tbl(i).actual_attribute_code);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').compareto_attribute_code='||l_kpi_info_tbl(i).compareto_attribute_code);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').format_id='||l_kpi_info_tbl(i).format_id);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dimset_id='||l_kpi_info_tbl(i).dimset_id);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim1_short_name='||l_kpi_info_tbl(i).dim1_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim2_short_name='||l_kpi_info_tbl(i).dim2_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim3_short_name='||l_kpi_info_tbl(i).dim3_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim4_short_name='||l_kpi_info_tbl(i).dim4_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim5_short_name='||l_kpi_info_tbl(i).dim5_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim6_short_name='||l_kpi_info_tbl(i).dim6_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim7_short_name='||l_kpi_info_tbl(i).dim7_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').actual_value='||l_kpi_info_tbl(i).actual_value);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').target_value='||l_kpi_info_tbl(i).target_value);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').insert_update_flag='||l_kpi_info_tbl(i).insert_update_flag);
    END LOOP;

    COMMIT;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                                  ,p_data   =>      x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
        --dbms_output.put_line('*sqlerrm='||sqlerrm);
END Populate_Measure_Data;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Page_Parameters(
    p_user_id 		IN VARCHAR2,
    p_page_id 		IN VARCHAR2,
    x_page_parameters 	OUT NOCOPY BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count 	OUT NOCOPY NUMBER,
    x_msg_data 		OUT NOCOPY VARCHAR2
) IS

    l_page_session_rec	BIS_PMV_PARAMETERS_PUB.page_session_rec_type;
    l_page_param_tbl 	BIS_PMV_PARAMETERS_PUB.parameter_tbl_type;
    i 			NUMBER;

    TYPE CursorType IS REF CURSOR;
    l_cursor	CursorType;
    l_sql		VARCHAR2(32000);

    l_parameter_name	VARCHAR2(32000);
    l_parameter_value	VARCHAR2(32000);
    l_parameter_description VARCHAR2(32000);

    l_dimension	 	VARCHAR2(100) := 'TIME_COMPARISON_TYPE';
    l_attribute_name 	VARCHAR2(100) := 'AS_OF_DATE';

BEGIN

    FND_MSG_PUB.Initialize;

    l_page_session_rec.user_id := p_user_id;
    l_page_session_rec.page_id := p_page_id;

    BIS_PMV_PARAMETERS_PUB.RETRIEVE_PAGE_PARAMETERS(
      p_page_session_rec => l_page_session_rec
     ,x_page_param_tbl => l_page_param_tbl
     ,x_return_status => x_return_status
     ,x_msg_count => x_msg_count
     ,x_msg_data => x_msg_data);

    FOR i IN 1..l_page_param_tbl.COUNT LOOP
        x_page_parameters(i).parameter_name := l_page_param_tbl(i).parameter_name;
        x_page_parameters(i).value_id := RTRIM(LTRIM(l_page_param_tbl(i).parameter_value, ''''), '''');
        x_page_parameters(i).value_name := l_page_param_tbl(i).parameter_description;
    END LOOP;

    -- This is a workaround to get TIME_COMPARISON_PARAMETER. There is a open bug#2609475
    -- to PMV in order to include it in the BIS_PMV_PARAMETERS_PUB.RETRIEVE_PAGE_PARAMETERS
    i := x_page_parameters.COUNT + 1;
    l_sql := 'SELECT attribute_name, session_value, session_description'||
             ' FROM bis_user_attributes'||
             ' WHERE user_id = :1 AND page_id = :2 AND dimension = :3';
    OPEN l_cursor FOR l_sql USING p_user_id, p_page_id, l_dimension;
    FETCH l_cursor INTO l_parameter_name, l_parameter_value, l_parameter_description;
    IF l_cursor%FOUND THEN
        x_page_parameters(i).parameter_name := l_parameter_name;
        x_page_parameters(i).value_id := RTRIM(LTRIM(l_parameter_value, ''''), '''');
        x_page_parameters(i).value_name := l_parameter_description;
    END IF;
    CLOSE l_cursor;

    -- bug 2666292
    i := x_page_parameters.COUNT + 1;
    l_sql := 'SELECT attribute_name, session_value, session_description'||
             ' FROM bis_user_attributes'||
             ' WHERE user_id = :1 AND page_id = :2 AND attribute_name = :3';
    OPEN l_cursor FOR l_sql USING p_user_id, p_page_id, l_attribute_name;
    FETCH l_cursor INTO l_parameter_name, l_parameter_value, l_parameter_description;
    IF l_cursor%FOUND THEN
        x_page_parameters(i).parameter_name := l_parameter_name;
        x_page_parameters(i).value_id := RTRIM(LTRIM(l_parameter_value, ''''), '''');
        x_page_parameters(i).value_name := l_parameter_description;
    END IF;

    CLOSE l_cursor;
    -- FOR i IN 1..x_page_parameters.COUNT LOOP
    --     dbms_output.put_line('*x_page_parameters.parameter_name='||x_page_parameters(i).parameter_name);
    --     dbms_output.put_line('*x_page_parameters.value_id='||x_page_parameters(i).value_id);
    --     dbms_output.put_line('*x_page_parameters.value_name='||x_page_parameters(i).value_name);
    -- END LOOP;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

END Get_Page_Parameters;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Page_Parameter(
    p_page_parameters 	  IN BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type,
    p_page_parameter_name IN VARCHAR2,
    x_page_parameter      OUT NOCOPY BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Type
) IS
    i NUMBER;
BEGIN

    FOR i IN 1..p_page_parameters.COUNT LOOP
        IF p_page_parameters(i).parameter_name = p_page_parameter_name THEN
            x_page_parameter := p_page_parameters(i);
        END IF;
    END LOOP;

END Get_Page_Parameter;

/************************************************************************************
************************************************************************************/

FUNCTION Get_Time_Comparison_Parameter(
    p_page_parameters IN BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type
) RETURN VARCHAR2 IS
    i 	NUMBER;
BEGIN
    FOR i IN 1..p_page_parameters.COUNT LOOP
        IF INSTR(p_page_parameters(i).parameter_name, 'TIME_COMPARISON_TYPE+') > 0 THEN
            RETURN p_page_parameters(i).parameter_name;
        END IF;
    END LOOP;

    RETURN NULL;

END Get_Time_Comparison_Parameter;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Kpis_Data_From_PMF_PMV(
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2,
    p_page_parameters   IN BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type,
    p_page_id		IN VARCHAR2,
    p_kpi_info_tbl      IN OUT NOCOPY BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Tbl_Type,
    x_return_status 	OUT NOCOPY VARCHAR2,
    x_msg_count 	OUT NOCOPY NUMBER,
    x_msg_data 		OUT NOCOPY VARCHAR2
) IS

    i			NUMBER;
    j			NUMBER;
    k			NUMBER;
    l_ak_regions	BSC_BIS_WRAPPER_PUB.t_array_of_varchar2;
    l_num_ak_regions	NUMBER := 0;

    l_return_status VARCHAR2(2000);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32000);

    l_viewby_level  		VARCHAR2(200);
    l_default_dimension_levels 	BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Tbl_Type;
    l_default_time_level_from   BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type;
    l_default_time_level_to     BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type;
    l_time_comparison_type      VARCHAR2(32000);

    l_actual_value		VARCHAR2(2000);
    l_target_value		VARCHAR2(2000);
    l_compareto_value		VARCHAR2(2000);

    l_time_parameter            BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE;
    l_parameters                BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE;
    l_measure_attribute_codes   BIS_PMV_ACTUAL_PVT.MEASURE_ATTR_CODES_TYPE;
    l_ranking_level		VARCHAR2(200);
    l_measure_tbl 		BIS_PMV_ACTUAL_PVT.ACTUAL_VALUE_TBL_TYPE;

    l_fnd_miss_num  		NUMBER  := 9.99E125;

    l_sum_actual_value          NUMBER := NULL;
    l_total_actual_value        NUMBER := NULL;
    l_f_actual_value		VARCHAR2(200) := NULL;

BEGIN

    FND_MSG_PUB.initialize;

    FOR i IN 1..p_kpi_info_tbl.COUNT LOOP
        --dbms_output.put_line('--------------------------------------------------------');
        --dbms_output.put_line('*p_kpi_info_tbl(i).kpi_code='||p_kpi_info_tbl(i).kpi_code);

        IF p_kpi_info_tbl(i).dataset_source = 'PMF' THEN
            IF (p_page_id IS NOT NULL) AND (p_page_parameters.COUNT > 0) AND
               (p_kpi_info_tbl(i).measure_dbi_flag = 'Y') THEN
                -- We come from a DBI portal page with page parameter portlet
                -- We can use better method to calculate the actuals
                -- in one PMV API call.

                -- Add the AK region of the measure to the array of AK Regions
                -- The actual for those AK region will be calculated later.

                IF p_kpi_info_tbl(i).region_code IS NOT NULL THEN
                    IF NOT Item_Belong_To_Array_Varchar2(p_kpi_info_tbl(i).region_code, l_ak_regions, l_num_ak_regions) THEN
                        l_num_ak_regions := l_num_ak_regions + 1;
                        l_ak_regions(l_num_ak_regions) := p_kpi_info_tbl(i).region_code;
                    END IF;
                END IF;

            ELSE
                -- We do not come from a portal page or the portal page
                -- does not have page parameters or the measure is not dbi.
                -- We ned to calculate the data of the Kpi one by one
                -- because every Kpi has different defaults and view by
                -- and they are not going to be overwritten.

	        l_return_status := NULL;
	        l_msg_count := NULL;
	        l_msg_data := NULL;

                Get_Kpi_view_by(
                    p_kpi_code => p_kpi_info_tbl(i).kpi_code,
                    p_dimset_id => p_kpi_info_tbl(i).dimset_id,
                    p_page_parameters => p_page_parameters,
                    x_viewby_level => l_viewby_level,
                    x_return_status => l_return_status,
                    x_msg_count => l_msg_count,
                    x_msg_data => l_msg_data
                );

                --dbms_output.put_line('*l_viewby_level='||l_viewby_level);

	        -- Get the default dimension levels of the dimension set
	        -- Also overwrite the dimension levels according to the page level parameters if they exists
	        Get_Default_Dimension_Levels(
	            p_kpi_code => p_kpi_info_tbl(i).kpi_code,
	            p_dimset_id => p_kpi_info_tbl(i).dimset_id,
	            p_page_parameters => p_page_parameters,
	            x_default_dimension_levels => l_default_dimension_levels,
	            x_default_time_level_from => l_default_time_level_from,
	            x_default_time_level_to => l_default_time_level_to
	        );

		l_time_comparison_type := Get_Time_Comparison_Parameter(p_page_parameters);
	        --dbms_output.put_line('*l_time_comparison_type='||l_time_comparison_type);

                -- Get actual and compareto value from PMV
                --dbms_output.put_line('*CALL TO PMV API (One by one)');
        	Get_Actual_Value_From_PMV(
	            p_kpi_info_rec => p_kpi_info_tbl(i),
	            p_user_id => p_user_id,
	            p_responsibility_id => p_responsibility_id,
	            p_dimension_levels => l_default_dimension_levels,
	            p_time_level_from => l_default_time_level_from,
	            p_time_level_to => l_default_time_level_to,
	            p_time_comparison_type => l_time_comparison_type,
                    p_viewby_level => l_viewby_level,
        	    x_actual_value => l_actual_value,
	            x_compareto_value => l_compareto_value,
	            x_return_status => l_return_status,
	            x_msg_count => l_msg_count,
	            x_msg_data => l_msg_data
	        );

	        --dbms_output.put_line('*l_actual_value='||l_actual_value);
	        --dbms_output.put_line('*l_compareto_value='||l_compareto_value);
	        --dbms_output.put_line('*l_return_status='||l_return_status);
	        --dbms_output.put_line('*l_msg_count='||l_msg_count);
	        --dbms_output.put_line('*l_msg_data='||l_msg_data);

	        IF l_time_comparison_type IS NULL THEN
        	    -- Bring the target from PMF
	            l_return_status := NULL;
	            l_msg_count := NULL;
	            l_msg_data := NULL;

	            Get_Target_Value_From_PMF(
	                p_kpi_info_rec => p_kpi_info_tbl(i),
        	        p_user_id => p_user_id,
	                p_responsibility_id => p_responsibility_id,
        	        p_dimension_levels => l_default_dimension_levels,
	                p_time_level => l_default_time_level_to,
        	        x_target_value => l_target_value,
	                x_return_status => l_return_status,
        	        x_msg_count => l_msg_count,
	                x_msg_data => l_msg_data
        	    );

	            --dbms_output.put_line('*l_target_value='||l_target_value);
        	    --dbms_output.put_line('*l_return_status='||l_return_status);
	            --dbms_output.put_line('*l_msg_count='||l_msg_count);
	            --dbms_output.put_line('*l_msg_data='||l_msg_data);
        	ELSE
	            -- Target is the compareto value
	            l_target_value := l_compareto_value;
	        END IF;   -- if time is comparison

                -- Bug#2655393 For target value is None, PMF return l_fnd_miss_num
                IF (l_target_value = l_fnd_miss_num ) THEN
                       l_target_value := NULL;
                END IF;

   	        --bug 2677766
	        IF p_kpi_info_tbl(i).format_id <= 2 THEN   --%
		    IF l_actual_value IS NOT NULL THEN
		        l_actual_value := l_actual_value/100;
		    END IF;
		    IF l_target_value IS NOT NULL THEN
		        l_target_value := l_target_value/100;
		    END IF;
	        END IF;

                -- Store actual and target in p_kpi_info_tbl
                p_kpi_info_tbl(i).actual_value := l_actual_value;
                p_kpi_info_tbl(i).target_value := l_target_value;

            END IF;
        END IF;
    END LOOP;

    -- Calculate Kpi data of measures sharing same AK region
    IF l_ak_regions.COUNT > 0 THEN
        -- Get ranking parameter
        BIS_PMV_PORTAL_UTIL_PUB.Get_Ranking_Parameter(
 	  p_page_id => p_page_id
          ,p_user_id => p_user_id
	  ,x_ranking_param => l_ranking_level
	  ,x_return_Status => l_return_status
	  ,x_msg_count => l_msg_count
	  ,x_msg_data => l_msg_data
        );
        --dbms_output.put_line('*l_ranking_level='||l_ranking_level);
    END IF;

    FOR j IN 1..l_ak_regions.COUNT LOOP
        --dbms_output.put_line('------------------------------------');
        --dbms_output.put_line('*l_ak_regions(j)='||l_ak_regions(j));

        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;

        -- Init the array of measure attribute codes
        l_measure_attribute_codes.DELETE;
        k := 1;
        FOR i IN 1..p_kpi_info_tbl.COUNT LOOP
            IF (p_kpi_info_tbl(i).dataset_source = 'PMF') AND (p_kpi_info_tbl(i).measure_dbi_flag = 'Y') AND
               (p_kpi_info_tbl(i).region_code = l_ak_regions(j)) THEN

                IF p_kpi_info_tbl(i).actual_attribute_code IS NOT NULL THEN
                    l_measure_attribute_codes(k) := p_kpi_info_tbl(i).actual_attribute_code;
                    k := k + 1;
                END IF;

                IF p_kpi_info_tbl(i).compareto_attribute_code IS NOT NULL THEN
                    l_measure_attribute_codes(k) := p_kpi_info_tbl(i).compareto_attribute_code;
                    k := k + 1;
                END IF;
            END IF;
        END LOOP;

        -- p_funtion_name is not requiered to be passed.
        -- The logic assures that: there is a page_id, we come from a DBI page
        -- with page parameters.
        -- No need to pass time parameter
        -- No need to pass parameter

        IF l_measure_attribute_codes.COUNT > 0 THEN
            --dbms_output.put_line('*CALL TO PMV API (several measures)');

            BIS_PMV_ACTUAL_PUB.Get_Actual_Value(
                p_region_code => l_ak_regions(j)
               ,p_user_id => p_user_id
               ,p_page_id => p_page_id
               ,p_responsibility_id => p_responsibility_id
               ,p_time_parameter => l_time_parameter
               ,p_parameters => l_parameters
               ,p_measure_attribute_codes => l_measure_attribute_codes
               ,p_ranking_level => l_ranking_level
               ,x_measure_tbl => l_measure_tbl
               ,x_return_status => l_return_status
               ,x_msg_count => l_msg_count
               ,x_msg_data => l_msg_data
            );

            -- Get the grand total per each measure_attribute_code
            -- and stored in the proper place in p_kpi_info_tbl
            FOR k IN 1..l_measure_attribute_codes.COUNT LOOP
                l_total_actual_value := NULL;
                l_sum_actual_value := NULL;

                FOR m IN 1..l_measure_tbl.COUNT LOOP
                    IF l_measure_tbl(m).measure_attribute_code = l_measure_attribute_codes(k) THEN
                        l_total_actual_value := l_measure_tbl(m).actual_grandtotal_value;
                        IF l_total_actual_value IS NULL THEN
                            -- No grand total then we need to calculated
                            IF l_sum_actual_value IS NULL AND l_measure_tbl(m).actual_value IS NOT NULL THEN
                                l_sum_actual_value := l_measure_tbl(m).actual_value;
                            ELSIF l_measure_tbl(m).actual_value IS NOT NULL THEN
                                l_sum_actual_value := l_sum_actual_value + l_measure_tbl(m).actual_value;
                            END IF;
                        ELSE
                            -- Grand total exist, then we can exit the loop for this
                            -- measure attribute code
                            EXIT;
                        END IF;
                    END IF;
                END LOOP;

                IF l_total_actual_value IS NULL THEN
                    l_total_actual_value := l_sum_actual_value;
                END IF;

                l_actual_value := l_total_actual_value;

                -- Bug#2655393 For target value is None, PMF return l_fnd_miss_num
                IF (l_actual_value = l_fnd_miss_num ) THEN
                    l_actual_value := NULL;
                END IF;

                -- Stored the actual in the proper kpis in p_kpi_info_tbl
                FOR i IN 1..p_kpi_info_tbl.COUNT LOOP
                    IF (p_kpi_info_tbl(i).dataset_source = 'PMF') AND
                       (p_kpi_info_tbl(i).measure_dbi_flag = 'Y') AND
                       (p_kpi_info_tbl(i).region_code = l_ak_regions(j)) THEN

                        l_f_actual_value := l_actual_value;

                        IF p_kpi_info_tbl(i).format_id <= 2 THEN   --%
		            IF l_f_actual_value IS NOT NULL THEN
		                l_f_actual_value := l_f_actual_value/100;
		            END IF;
	                END IF;

                        IF p_kpi_info_tbl(i).actual_attribute_code = l_measure_attribute_codes(k) THEN
                            p_kpi_info_tbl(i).actual_value := l_f_actual_value;
                        END IF;

                        IF p_kpi_info_tbl(i).compareto_attribute_code = l_measure_attribute_codes(k) THEN
                            p_kpi_info_tbl(i).target_value := l_f_actual_value;
                        END IF;
                    END IF;
                END LOOP;
            END LOOP;
        END IF;
    END LOOP;

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
END Get_Kpis_Data_From_PMF_PMV;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Kpi_view_by(
    p_kpi_code 			IN NUMBER,
    p_dimset_id  		IN VARCHAR2,
    p_page_parameters		IN BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Tbl_Type,
    x_viewby_level      	OUT NOCOPY VARCHAR2,
    x_return_status 		OUT NOCOPY VARCHAR2,
    x_msg_count 		OUT NOCOPY NUMBER,
    x_msg_data 			OUT NOCOPY VARCHAR2
) IS

    TYPE RefCurTyp IS REF CURSOR;
    cv 			RefCurTyp;

    l_sql 		VARCHAR2(32000);
    l_level_view_by	BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type;

    l_dimension_short_name	VARCHAR2(2000);
    l_level_short_name		VARCHAR2(2000);
    l_page_parameter_name	VARCHAR2(32000);
    l_page_parameter      	BSC_BIS_WRAPPER_PUB.Page_Parameter_Rec_Type;

BEGIN
    x_viewby_level := NULL;

    -- Get the defualt view by of the Kpi
    l_sql := 'SELECT BID.SHORT_NAME DIMENSION_SHORTNAME, '||
		'	BKL.LEVEL_SHORTNAME '||
		' FROM BSC_KPI_DIM_LEVELS_VL BKL,'||
		'     BIS_LEVELS BIL,'||
		'     BIS_DIMENSIONS BID'||
		' WHERE BKL.INDICATOR = :1 AND'||
		'   BKL.DIM_SET_ID = :2 AND'||
		'   BKL.LEVEL_SOURCE = ''PMF'' AND'||
		'   (BKL.DEFAULT_VALUE = ''C'') AND'||
		'   BKL.LEVEL_SHORTNAME = BIL.SHORT_NAME AND'||
		'   BIL.DIMENSION_ID = BID.DIMENSION_ID'||
		' ORDER BY DIMENSION_SHORTNAME, BKL.DIM_LEVEL_INDEX';

    l_level_view_by.dimension_short_name := NULL;
    l_level_view_by.level_short_name := NULL;

    OPEN cv FOR l_sql USING p_kpi_code, p_dimset_id;
    FETCH cv INTO l_level_view_by.dimension_short_name, l_level_view_by.level_short_name;
    IF cv%NOTFOUND THEN
        l_level_view_by.dimension_short_name := NULL;
        l_level_view_by.level_short_name := NULL;
    END IF;
    CLOSE cv;

    IF l_level_view_by.dimension_short_name IS NOT NULL THEN
        -- Get other dimensions levels used in the Kpi with the same dimension of the view by level
        -- The view by level can be overwritten by one of them if the page parameters match
        -- with one of them.
        l_sql := 'SELECT BID.SHORT_NAME DIMENSION_SHORTNAME, '||
	    	 '	BKL.LEVEL_SHORTNAME'||
		 ' FROM BSC_KPI_DIM_LEVELS_VL BKL,'||
		 '     BIS_LEVELS BIL,'||
		 '     BIS_DIMENSIONS BID'||
		 ' WHERE BKL.INDICATOR = :1 AND'||
		 '   BKL.DIM_SET_ID = :2 AND'||
		 '   BKL.LEVEL_SOURCE = ''PMF'' AND'||
		 '   BKL.LEVEL_SHORTNAME = BIL.SHORT_NAME AND'||
		 '   BIL.DIMENSION_ID = BID.DIMENSION_ID AND'||
                 '   BID.SHORT_NAME = :3';

        OPEN cv FOR l_sql USING p_kpi_code, p_dimset_id, l_level_view_by.dimension_short_name;
        LOOP
            FETCH cv INTO l_dimension_short_name, l_level_short_name;
            EXIT WHEN cv%NOTFOUND;

            l_page_parameter_name := l_dimension_short_name||'+'||l_level_short_name;
            IF Is_Time_Dimension(l_dimension_short_name) THEN
                l_page_parameter_name := l_page_parameter_name||'_FROM';
            END IF;

            Get_Page_Parameter(
                p_page_parameters => p_page_parameters,
                p_page_parameter_name => l_page_parameter_name,
                x_page_parameter => l_page_parameter
            );

            IF l_page_parameter.parameter_name IS NOT NULL THEN
                -- The dimension level is used by the kpi and also is a page parameter
                -- also is of the same dimension f the defualt view by of the kpi.
                -- It will overwrite the default view by of the kpi.
                l_level_view_by.dimension_short_name := l_dimension_short_name;
                l_level_view_by.level_short_name := l_level_short_name;
            END IF;
        END LOOP;
        CLOSE cv;
    END IF;

    x_viewby_level := l_level_view_by.dimension_short_name || '+' || l_level_view_by.level_short_name;
    --dbms_output.put_line('*x_viewby_level='||x_viewby_level);

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
END Get_Kpi_view_by;

/************************************************************************************
***********************************************************************************/

PROCEDURE get_bsc_format_id(
  p_measure_shortname IN VARCHAR2
 ,x_bsc_format_id     OUT NOCOPY NUMBER
)
IS
  l_return_status               VARCHAR2(32000);
  l_msg_count                   VARCHAR2(32000);
  l_msg_data                    VARCHAR2(32000);
  l_measure_name                bsc_sys_datasets_tl.name%TYPE;
  l_measure_id                  NUMBER;
  l_description                 bsc_sys_datasets_tl.help%TYPE;
  l_dimension1_id               NUMBER;
  l_dimension2_id               NUMBER;
  l_dimension3_id               NUMBER;
  l_dimension4_id               NUMBER;
  l_dimension5_id               NUMBER;
  l_dimension6_id               NUMBER;
  l_dimension7_id               NUMBER;
  l_unit_of_measure_class       VARCHAR2(10);
  l_actual_data_source_type     VARCHAR2(30);
  l_actual_data_source          VARCHAR2(240);
  l_comparison_source           VARCHAR2(240);
  l_increase_in_measure         VARCHAR2(1);
  l_region_code                 VARCHAR2(240);
  l_attribute_code              VARCHAR2(240);
  l_function_name               VARCHAR2(240);
  l_measure_short_name          VARCHAR2(240);
  l_display_format              VARCHAR2(240);
  l_display_type                VARCHAR2(240);

  CURSOR c_akitems IS
    SELECT attribute7, attribute14 FROM ak_region_items
    WHERE region_code = l_region_code AND attribute_code = l_attribute_code;
BEGIN
  BIS_PMF_DEFINER_WRAPPER_PVT.retrieve_performance_measure(
    p_measure_short_name => p_measure_shortname
   ,x_return_status => l_return_status
   ,x_msg_count => l_msg_count
   ,x_msg_data  => l_msg_data
   ,x_measure_id => l_measure_id
   ,x_measure_short_name => l_measure_short_name
   ,x_measure_name => l_measure_name
   ,x_description => l_description
   ,x_dimension1_id => l_dimension1_id
   ,x_dimension2_id => l_dimension2_id
   ,x_dimension3_id => l_dimension3_id
   ,x_dimension4_id => l_dimension4_id
   ,x_dimension5_id => l_dimension5_id
   ,x_dimension6_id => l_dimension6_id
   ,x_dimension7_id => l_dimension7_id
   ,x_unit_of_measure_class  => l_unit_of_measure_class
   ,x_actual_data_source_type => l_actual_data_source_type
   ,x_actual_data_source => l_actual_data_source
   ,x_region_code =>  l_region_code
   ,x_attribute_code => l_attribute_code
   ,x_function_name => l_function_name
   ,x_comparison_source => l_comparison_source
   ,x_increase_in_measure => l_increase_in_measure
  );

  IF l_region_code IS NOT NULL AND l_attribute_code IS NOT NULL THEN
    OPEN c_akitems;
    FETCH c_akitems INTO l_display_format, l_display_type;
    CLOSE c_akitems;

    get_bsc_format_id(
      p_display_format => l_display_format
     ,p_display_type => l_display_type
     ,x_bsc_format_id => x_bsc_format_id
    );
  ELSE
    x_bsc_format_id := NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_akitems%ISOPEN) THEN
      CLOSE c_akitems;
    END IF;
END get_bsc_format_id;

/*
  FORMAT_ID NAME       FORMAT
  --------- ---------- ---------------
          0 FmtPercent #,##0%
          1 FmtPercen1 #,##0.0%
          2 FmtPercen2 #,##0.00%
          5 FmtNumber  #,###,##0
          6 FmtNumber1 #,###,##0.0
          7 FmtNumber2 #,###,##0.00
          8 FmtNumber3 #,###,##0.000
*/

/************************************************************************************
***********************************************************************************/

PROCEDURE get_bsc_format_id(
  p_display_type    IN VARCHAR2
 ,p_display_format  IN VARCHAR2
 ,x_bsc_format_id   OUT NOCOPY NUMBER
)
IS
  l_num_decimal_places  NUMBER;
BEGIN
  IF p_display_format IS NULL THEN
    IF p_display_type = 'IP' THEN
      x_bsc_format_id := 0;
    ELSIF p_display_type = 'FP' THEN
      x_bsc_format_id := 1;
    ELSE
      x_bsc_format_id := 5;
    END IF;
  ELSIF p_display_type = 'IP' OR p_display_type = 'FP' THEN
    l_num_decimal_places := get_num_decimal_places(p_display_format);

    IF l_num_decimal_places = 0 THEN
      x_bsc_format_id := 0;
    ELSIF l_num_decimal_places = 1 THEN
      x_bsc_format_id := 1;
    ELSE
      x_bsc_format_id := 2;
    END IF;
  ELSE
    l_num_decimal_places := get_num_decimal_places(p_display_format);

    IF l_num_decimal_places = 0 THEN
      x_bsc_format_id := 5;
    ELSIF l_num_decimal_places = 1 THEN
      x_bsc_format_id := 6;
    ELSIF l_num_decimal_places = 2 THEN
      x_bsc_format_id := 7;
    ELSE
      x_bsc_format_id := 8;
    END IF;
  END IF;
END;

/************************************************************************************
***********************************************************************************/

FUNCTION get_num_decimal_places(
  p_display_format  IN VARCHAR2
) RETURN NUMBER
IS
  l_display_format  VARCHAR2(200);
  l_fraction_part   VARCHAR2(100);
  l_position        NUMBER;
BEGIN
  l_display_format := trim(replace(p_display_format, 'D', '.'));
  l_position := instr(l_display_format, '.');

  IF (l_position > 0) THEN
    l_fraction_part := substr(l_display_format, l_position + 1);

    IF l_fraction_part IS NOT NULL THEN
      RETURN length(l_fraction_part);
    ELSE
      RETURN 0;
    END IF;
  ELSE
    RETURN 0;
  END IF;
END get_num_decimal_places;

/************************************************************************************
***********************************************************************************/

FUNCTION Item_Belong_To_Array_Varchar2(
    p_item IN VARCHAR2,
    p_array IN BSC_BIS_WRAPPER_PUB.t_array_of_varchar2,
    p_num_items IN NUMBER
) RETURN BOOLEAN IS

    h_i NUMBER;

BEGIN
    FOR h_i IN 1 .. p_num_items LOOP
        IF p_array(h_i) = p_item THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE;

END Item_Belong_To_Array_Varchar2;

/************************************************************************************
/ This API is used in Enh 3579794, for saving actual and buget(compareTo)
/ actual and budget values are obtained using BIS JAVA APIS.
************************************************************************************/
PROCEDURE Post_Measure_Data(
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2,
    p_caching_key	IN VARCHAR2,
    p_kpi_info_tbl	IN BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Tbl_Type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count 	OUT NOCOPY NUMBER,
    x_msg_data 		OUT NOCOPY VARCHAR2
) IS

    TYPE tCursor IS REF CURSOR;

    cv 			tCursor;
    l_sql 		VARCHAR2(32000);

    cv_caching 		tCursor;
    l_caching_sql 	VARCHAR2(32000);
    l_insert_sql	VARCHAR2(32000);
    l_update_sql        VARCHAR2(32000);

    l_caching_key       VARCHAR2(200);
    i			NUMBER := 1;

    l_return_status VARCHAR2(2000);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32000);

    l_db_user_id	NUMBER;
    l_sysdate		DATE := SYSDATE;

BEGIN
    FND_MSG_PUB.initialize;

    -- Get the database user id
    -- Ref: bug#3482442 In corner cases this query can return more than one
    -- row and it will fail. AUDSID is not PK. After meeting with
    -- Vinod and Kris and Venu, we should use FNG_GLOBAL.user_id
    l_db_user_id := BSC_APPS.fnd_global_user_id;

    --dbms_output.put_line('*l_db_user_id='||l_db_user_id);

    -- Populate BSC_BIS_MEASURES_DATA for the default analysis combination
    -- of each kpi which user has access and belongs to the given tab.

    l_sql :=  'SELECT tk.indicator'||
              ' FROM bsc_tab_indicators tk, bsc_user_kpi_access ka'||
              ' WHERE tk.tab_id = :1 AND tk.indicator = ka.indicator AND ka.responsibility_id = :2';

    l_caching_sql := 'SELECT caching_key'||
                     ' FROM bsc_bis_measures_data'||
                     ' WHERE user_id = :1 AND responsibility_id = :2 AND indicator = :3 AND'||
                     ' analysis_option0 = :4 AND analysis_option1 = :5 AND analysis_option2 = :6 AND'||
                     ' series_id = :7';

    l_update_sql := 'UPDATE bsc_bis_measures_data'||
                    ' SET actual_data = :a, budget_data = :b, caching_key = :c,'||
                    ' last_updated_by = :d, last_update_date = :e'||
                    ' WHERE user_id = :f AND responsibility_id = :g AND indicator = :h AND'||
                    ' analysis_option0 = :i AND analysis_option1 = :j AND analysis_option2 = :k AND'||
                    ' series_id = :l';

    l_insert_sql := 'INSERT INTO bsc_bis_measures_data (user_id, responsibility_id, indicator,'||
                    ' analysis_option0, analysis_option1, analysis_option2, series_id,'||
                    ' caching_key, actual_data, budget_data, created_by, creation_date,'||
                    ' last_updated_by, last_update_date, last_update_login)'||
                    ' VALUES (:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m, :n, :o)';

    -- Insert/Update
    FOR i IN 1..p_kpi_info_tbl.COUNT LOOP

       IF (p_kpi_info_tbl(i).kpi_code IS NOT NULL) AND (p_kpi_info_tbl(i).analysis_option0 IS NOT NULL) AND
           (p_kpi_info_tbl(i).analysis_option1 IS NOT NULL) AND (p_kpi_info_tbl(i).analysis_option2 IS NOT NULL) AND
           (p_kpi_info_tbl(i).series_id IS NOT NULL) THEN

               --Delete from BSC_BIS_MEASURES_DATA kpis that belong to the given tab, which has
               --been deleted, has been changed or user has not access.

                DELETE FROM
                    bsc_bis_measures_data m
                WHERE
                    m.user_id = p_user_id AND
                    m.responsibility_id = p_responsibility_id AND
                    m.indicator = p_kpi_info_tbl(i).kpi_code
                    AND (
                    m.indicator NOT IN (
                            SELECT
                            a.indicator
                        FROM
                            bsc_user_kpi_access a
                        WHERE
                            a.responsibility_id = p_responsibility_id
                    ) OR
                    m.indicator = (
                        SELECT
                            k.indicator
                        FROM
                            bsc_kpis_b k
                        WHERE
                            k.indicator = m.indicator AND (
                            k.prototype_flag = 2 OR
                            k.last_update_date > m.last_update_date)
                    ));

            --dbms_output.put_line('*after delete');

            -- Get the caching key
            l_caching_key := NULL;
            OPEN cv_caching FOR l_caching_sql USING p_user_id, p_responsibility_id, p_kpi_info_tbl(i).kpi_code,
                	p_kpi_info_tbl(i).analysis_option0, p_kpi_info_tbl(i).analysis_option1,
                   	p_kpi_info_tbl(i).analysis_option2, p_kpi_info_tbl(i).series_id;
            FETCH cv_caching INTO l_caching_key;
         	IF cv_caching%FOUND THEN
                	--dbms_output.put_line('*l_caching_key='||l_caching_key);
                	-- The record exists --> Calculate data and update if caching key is different
	        	-- Update actual and target in BSC_BIS_MEASURES_DATA
            		EXECUTE IMMEDIATE l_update_sql USING p_kpi_info_tbl(i).actual_value,
                   	p_kpi_info_tbl(i).target_value, p_caching_key, l_db_user_id,
                   	l_sysdate, p_user_id, p_responsibility_id, p_kpi_info_tbl(i).kpi_code,
                   	p_kpi_info_tbl(i).analysis_option0, p_kpi_info_tbl(i).analysis_option1,
                   	p_kpi_info_tbl(i).analysis_option2, p_kpi_info_tbl(i).series_id;

            		--dbms_output.put_line('*update executed');

         	ELSE
                	-- The record does not exists --> Calculate data and Insert
            		-- Insert actual and target in BSC_BIS_MEASURES_DATA
            		EXECUTE IMMEDIATE l_insert_sql USING p_user_id, p_responsibility_id,
                 	p_kpi_info_tbl(i).kpi_code, p_kpi_info_tbl(i).analysis_option0,
                 	p_kpi_info_tbl(i).analysis_option1, p_kpi_info_tbl(i).analysis_option2,
                 	p_kpi_info_tbl(i).series_id, p_caching_key,
                 	p_kpi_info_tbl(i).actual_value, p_kpi_info_tbl(i).target_value,
                 	l_db_user_id, l_sysdate, l_db_user_id, l_sysdate, l_db_user_id;

            		--dbms_output.put_line('*insert executed');

         	END IF;
         	CLOSE cv_caching;
        END IF;

        --dbms_output.put_line('--------------------------------------------');
        --dbms_output.put_line('l_kpi_info_tbl('||i||').kpi_code='||l_kpi_info_tbl(i).kpi_code);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').analysis_option0='||l_kpi_info_tbl(i).analysis_option0);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').analysis_option1='||l_kpi_info_tbl(i).analysis_option1);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').analysis_option2='||l_kpi_info_tbl(i).analysis_option2);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').series_id='||l_kpi_info_tbl(i).series_id);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dataset_id='||l_kpi_info_tbl(i).dataset_id);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dataset_source='||l_kpi_info_tbl(i).dataset_source);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').measure_short_name='||l_kpi_info_tbl(i).measure_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').measure_dbi_flag='||l_kpi_info_tbl(i).measure_dbi_flag);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').measure_id='||l_kpi_info_tbl(i).measure_id);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').region_code='||l_kpi_info_tbl(i).region_code);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').function_name='||l_kpi_info_tbl(i).function_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').actual_attribute_code='||l_kpi_info_tbl(i).actual_attribute_code);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').compareto_attribute_code='||l_kpi_info_tbl(i).compareto_attribute_code);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').format_id='||l_kpi_info_tbl(i).format_id);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dimset_id='||l_kpi_info_tbl(i).dimset_id);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim1_short_name='||l_kpi_info_tbl(i).dim1_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim2_short_name='||l_kpi_info_tbl(i).dim2_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim3_short_name='||l_kpi_info_tbl(i).dim3_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim4_short_name='||l_kpi_info_tbl(i).dim4_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim5_short_name='||l_kpi_info_tbl(i).dim5_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim6_short_name='||l_kpi_info_tbl(i).dim6_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').dim7_short_name='||l_kpi_info_tbl(i).dim7_short_name);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').actual_value='||l_kpi_info_tbl(i).actual_value);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').target_value='||l_kpi_info_tbl(i).target_value);
        --dbms_output.put_line('l_kpi_info_tbl('||i||').insert_update_flag='||l_kpi_info_tbl(i).insert_update_flag);
    END LOOP;

    COMMIT;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                                  ,p_data   =>      x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
        --dbms_output.put_line('*sqlerrm='||sqlerrm);
END Post_Measure_Data;

/************************************************************************************
/ Wrapper API is used in Enh 3579794, for saving actual and buget(compareTo)
/ actual and budget values are obtained using BIS JAVA APIS.
************************************************************************************/
PROCEDURE Populate_Measure_Data(
    p_user_id 		    IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2,
    p_caching_key	    IN VARCHAR2,
    p_kpi_code 			IN NUMBER,
    p_analysis_option0	IN NUMBER,
    p_analysis_option1	IN NUMBER,
    p_analysis_option2	IN NUMBER,
    p_series_id			IN NUMBER,
    p_actual_value      IN VARCHAR2,
    p_target_value      IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count 	OUT NOCOPY NUMBER,
    x_msg_data 		OUT NOCOPY VARCHAR2
) IS

    l_return_status VARCHAR2(2000);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32000);
    l_kpi_info_tbl  BSC_BIS_WRAPPER_PUB.Kpi_Info_Rec_Tbl_Type;

BEGIN
    FND_MSG_PUB.initialize;

    l_kpi_info_tbl(1).KPI_CODE := p_kpi_code;
    l_kpi_info_tbl(1).ANALYSIS_OPTION0 := p_analysis_option0;
    l_kpi_info_tbl(1).ANALYSIS_OPTION1 := p_analysis_option1;
    l_kpi_info_tbl(1).ANALYSIS_OPTION2 := p_analysis_option2;
    l_kpi_info_tbl(1).SERIES_ID := p_series_id;
    l_kpi_info_tbl(1).ACTUAL_VALUE := p_actual_value;
    l_kpi_info_tbl(1).TARGET_VALUE := p_target_value;

    Post_Measure_Data(p_user_id,
                      p_responsibility_id,
                      p_caching_key,
                      l_kpi_info_tbl,
                      x_return_status,
                      x_msg_count,
                      x_msg_data);
    COMMIT;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                                  ,p_data   =>      x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                                  ,p_data     =>      x_msg_data);
        --dbms_output.put_line('*sqlerrm='||sqlerrm);
END Populate_Measure_Data;

END BSC_BIS_WRAPPER_PVT;

/
