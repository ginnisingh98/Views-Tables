--------------------------------------------------------
--  DDL for Package Body BSC_BIS_WRAPPER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_WRAPPER_PUB" AS
/* $Header: BSCPBISB.pls 115.9 2003/02/12 14:26:12 adrao ship $ */

/************************************************************************************
  Get_Actual_Value by KPi
************************************************************************************/
FUNCTION Get_Actual_Value_By_Kpi(
    p_kpi_code 		IN NUMBER,
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2
) RETURN VARCHAR2 IS

    l_value VARCHAR2(2000);
    l_analysis_option0	NUMBER;
    l_analysis_option1	NUMBER;
    l_analysis_option2	NUMBER;
    l_series_id		NUMBER;

BEGIN
    l_value  := NULL;

    -- Get defaults
    BSC_BIS_WRAPPER_PVT.Get_AO_Defaults(
	    			p_kpi_code  => p_kpi_code,
	    			x_analysis_option0 => l_analysis_option0,
	    			x_analysis_option1 => l_analysis_option1,
	    			x_analysis_option2 => l_analysis_option2,
	    			x_series_id => l_series_id);


    l_value := BSC_BIS_WRAPPER_PVT.Get_Actual_Value(
				p_kpi_code => p_kpi_code,
        			p_analysis_option0 => l_analysis_option0,
        			p_analysis_option1 => l_analysis_option1,
        			p_analysis_option2 => l_analysis_option2,
				p_series_id => l_series_id,
        			p_user_id => p_user_id,
        			p_responsibility_id => p_responsibility_id);

   RETURN l_value ;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_value ;
END Get_Actual_Value_By_Kpi;


/************************************************************************************
  Get_Actual_Value by KPi Analysis option Comb
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

    l_value  VARCHAR2(2000);

    l_return_status VARCHAR2(2000);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32000);

BEGIN
    l_value  := NULL;

    l_value := BSC_BIS_WRAPPER_PVT.Get_Actual_Value(
				p_kpi_code => p_kpi_code,
        			p_analysis_option0 => p_analysis_option0,
        			p_analysis_option1 => p_analysis_option1,
        			p_analysis_option2 => p_analysis_option2,
				p_series_id => p_series_id,
        			p_user_id => p_user_id,
        			p_responsibility_id => p_responsibility_id);

   RETURN l_value ;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_value ;
END Get_Actual_Value;


/************************************************************************************
  Get_Current_Period by KPi
************************************************************************************/
FUNCTION Get_Current_Period_By_Kpi(
    p_kpi_code 		IN NUMBER
) RETURN VARCHAR2 IS

    l_value VARCHAR2(2000);
    l_analysis_option0	NUMBER;
    l_analysis_option1	NUMBER;
    l_analysis_option2	NUMBER;
    l_series_id		NUMBER;

BEGIN
    l_value  := NULL;

    -- Get defaults
    BSC_BIS_WRAPPER_PVT.Get_AO_Defaults(
	    			p_kpi_code  => p_kpi_code,
	    			x_analysis_option0 => l_analysis_option0,
	    			x_analysis_option1 => l_analysis_option1,
	    			x_analysis_option2 => l_analysis_option2,
	    			x_series_id => l_series_id);


    l_value := BSC_BIS_WRAPPER_PVT.Get_Current_Period(
				p_kpi_code => p_kpi_code,
        			p_analysis_option0 => l_analysis_option0,
        			p_analysis_option1 => l_analysis_option1,
        			p_analysis_option2 => l_analysis_option2,
				p_series_id => l_series_id);

   RETURN l_value ;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_value ;
END Get_Current_Period_By_Kpi;


/************************************************************************************
  Get_Current_Period by KPi Analysis option Comb
************************************************************************************/
FUNCTION Get_Current_Period(
    p_kpi_code 		IN NUMBER,
    p_analysis_option0	IN NUMBER,
    p_analysis_option1	IN NUMBER,
    p_analysis_option2	IN NUMBER,
    p_series_id		IN NUMBER
) RETURN VARCHAR2 IS

    l_value  VARCHAR2(2000);

BEGIN
    l_value  := NULL;

    l_value := BSC_BIS_WRAPPER_PVT.Get_Current_Period(
				p_kpi_code => p_kpi_code,
        			p_analysis_option0 => p_analysis_option0,
        			p_analysis_option1 => p_analysis_option1,
        			p_analysis_option2 => p_analysis_option2,
				p_series_id => p_series_id);

   RETURN l_value ;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_value ;
END Get_Current_Period;

/************************************************************************************
  Get_Current_Period by KPi Analysis option Comb
************************************************************************************/
FUNCTION Get_DBI_Current_Period(
   p_dimension_short_name IN VARCHAR2,
   p_level_short_name IN VARCHAR2,
   p_as_of_date IN VARCHAR2

) RETURN VARCHAR2 IS

    l_value  VARCHAR2(2000);
    l_time_dimension_level      BSC_BIS_WRAPPER_PUB.Dim_level_Rec_Type;

BEGIN
    l_value  := NULL;
    l_time_dimension_level.dimension_short_name := p_dimension_short_name;
    l_time_dimension_level.level_short_name := p_level_short_name;


    l_value := BSC_BIS_WRAPPER_PVT.Get_DBI_Current_Period(
                 p_time_dimension_level =>   l_time_dimension_level,
                 p_as_of_date => p_as_of_date
			   );

   RETURN l_value ;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_value ;
END Get_DBI_Current_Period;

/************************************************************************************
  Get_Target _Value by KPi
************************************************************************************/
FUNCTION Get_Target_Value_By_Kpi(
    p_kpi_code 		IN NUMBER,
    p_user_id 		IN VARCHAR2,
    p_responsibility_id	IN VARCHAR2
) RETURN VARCHAR2 IS

    l_value VARCHAR2(100);
    l_analysis_option0	NUMBER;
    l_analysis_option1	NUMBER;
    l_analysis_option2	NUMBER;
    l_series_id		NUMBER;

BEGIN
    l_value  := NULL;

    -- Get defaults
    BSC_BIS_WRAPPER_PVT.Get_AO_Defaults(
	    			p_kpi_code  => p_kpi_code,
	    			x_analysis_option0 => l_analysis_option0,
	    			x_analysis_option1 => l_analysis_option1,
	    			x_analysis_option2 => l_analysis_option2,
	    			x_series_id => l_series_id);

    l_value := BSC_BIS_WRAPPER_PVT.Get_Target_Value(
				p_kpi_code => p_kpi_code,
        			p_analysis_option0 => l_analysis_option0,
        			p_analysis_option1 => l_analysis_option1,
        			p_analysis_option2 => l_analysis_option2,
				p_series_id => l_series_id,
        			p_user_id => p_user_id,
        			p_responsibility_id => p_responsibility_id);

    RETURN l_value ;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_value ;
END Get_Target_Value_By_Kpi;


/************************************************************************************
  Get target Value by KPi Analysis option Comb
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

    l_value  VARCHAR2(2000);

BEGIN
    l_value  := NULL;

    l_value := BSC_BIS_WRAPPER_PVT.Get_Target_Value(
				p_kpi_code => p_kpi_code,
        			p_analysis_option0 => p_analysis_option0,
        			p_analysis_option1 => p_analysis_option1,
        			p_analysis_option2 => p_analysis_option2,
				p_series_id => p_series_id,
        			p_user_id => p_user_id,
        			p_responsibility_id => p_responsibility_id);

   RETURN l_value ;
EXCEPTION
    WHEN OTHERS THEN
        RETURN l_value ;
END Get_Target_Value;


/************************************************************************************
    Populate bsc_bis_measures_data for the given tab
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
BEGIN

    BSC_BIS_WRAPPER_PVT.Populate_Measure_Data(
        p_tab_id => p_tab_id,
        p_page_id => p_page_id,
        p_user_id => p_user_id,
        p_responsibility_id => p_responsibility_id,
        p_caching_key => p_caching_key,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
    );

END Populate_Measure_Data;

/************************************************************************************
************************************************************************************/

END BSC_BIS_WRAPPER_PUB;

/
