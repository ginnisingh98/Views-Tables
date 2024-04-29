--------------------------------------------------------
--  DDL for Package Body BSC_PMF_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PMF_UTILITIES_PVT" as
/* $Header: BSCVUTIB.pls 120.1 2005/10/25 01:11:39 kyadamak noship $ */

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_PMF_UTILITIES_PVT';

--: This function validates if the data set and dimension set associated to the
--: analysis option combination is valid or not.
--: Valid means that the measure and dimensions are available in the system.
--: It returns 1 in case it is valid. Otherwise returns 0.
function Validate_Analysis_Option(
 p_indicator		IN      number
 ,p_analysis_option0	IN	number
 ,p_analysis_option1	IN	number
 ,p_analysis_option2	IN	number
 ,p_series_id		IN	number
) return number is

TYPE Recdc_value                IS REF CURSOR;
dc_value                        Recdc_value;

l_sql				varchar2(5000);
l_short_name			varchar2(30);
l_source			varchar2(10);
l_num_dim_levels		number;
l_num_valid_dim_levels		number;

l_return_value			number;

begin

  -- Validate measure short name
  l_sql := 'select i.short_name, nvl(m.source, ''BSC'')'||
           ' from bsc_kpi_analysis_measures_b k, bsc_sys_datasets_b d, bsc_sys_measures m, bis_indicators i'||
           ' where k.indicator = :1 and k.analysis_option0 = :2 and'||
           ' k.analysis_option1 = :3 and k.analysis_option2 = :4 and'||
           ' k.series_id = :5 and k.dataset_id = d.dataset_id and'||
           ' d.measure_id1 = m.measure_id and m.short_name = i.short_name (+)';

  open dc_value for l_sql using p_indicator,p_analysis_option0,p_analysis_option1,p_analysis_option2,p_series_id;
    fetch dc_value into l_short_name, l_source;
  close dc_value;

  if l_source = 'PMF' then
    -- The measure is from PMF
    if l_short_name IS NULL then
      -- The measure short name does not exist in BIS_INDICATOR
      l_return_value := 0;
    else
      -- The measure is valid. We need to validate that all the dimensions levels
      -- associated to this measure in the corresponding dimension set are valid.

      -- Get the number of dimension levels for the dimension set
      l_sql := 'select count(1)'||
               ' from (select k.level_shortname'||
               ' from bsc_kpi_analysis_options_b a, bsc_kpi_dim_levels_vl k'||
               ' where a.indicator = :1 and a.analysis_group_id = 0 and'||
               ' a.option_id = :2 and a.parent_option_id = 0 and'||
               ' a.grandparent_option_id = 0 and a.indicator = k.indicator and'||
               ' a.dim_set_id = k.dim_set_id and k.level_source = ''PMF'')';
      open dc_value for l_sql using p_indicator,p_analysis_option0;
        fetch dc_value into l_num_dim_levels;
      close dc_value;

      -- Get the number of valid dimension levels forthe dimension set
      l_sql := 'select count(*)'||
               ' from (select k.level_shortname'||
               ' from bsc_kpi_analysis_options_b a, bsc_kpi_dim_levels_vl k,'||
               ' bisfv_dimension_levels dl, bisfv_performance_measures pm'||
               ' where a.indicator = :1 and a.analysis_group_id = 0 and'||
               ' a.option_id = :2 and a.parent_option_id = 0 and'||
               ' a.grandparent_option_id = 0 and a.indicator = k.indicator and'||
               ' a.dim_set_id = k.dim_set_id and k.level_source = ''PMF'' and'||
               ' k.level_shortname = dl.dimension_level_short_name and'||
               ' pm.measure_short_name = :3 and ('||
               ' dl.dimension_short_name = pm.dimension1_short_name or'||
               ' dl.dimension_short_name = pm.dimension2_short_name or'||
               ' dl.dimension_short_name = pm.dimension3_short_name or'||
               ' dl.dimension_short_name = pm.dimension4_short_name or'||
               ' dl.dimension_short_name = pm.dimension5_short_name or'||
               ' dl.dimension_short_name = pm.dimension6_short_name or'||
               ' dl.dimension_short_name = pm.dimension7_short_name))';
      open dc_value for l_sql using p_indicator,p_analysis_option0,l_short_name;
        fetch dc_value into l_num_valid_dim_levels;
      close dc_value;

      if l_num_dim_levels <> l_num_valid_dim_levels then
          l_return_value := 0;
      else
          l_return_value := 1;
      end if;

    end if;
  else
    -- The measure is a BSC measure, so it is ok
    l_return_value := 1;
  end if;

  return l_return_value;

EXCEPTION
  WHEN OTHERS THEN
    return -1;

end Validate_Analysis_Option;


/************************************************************************************
************************************************************************************/

end BSC_PMF_UTILITIES_PVT;

/
