--------------------------------------------------------
--  DDL for Package BSC_UPDATE_COLOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_UPDATE_COLOR" AUTHID CURRENT_USER AS
/* $Header: BSCDCOLS.pls 120.2 2007/06/14 17:42:42 nkishore ship $ */
--
-- Global Constants
--
GREEN 	CONSTANT NUMBER(11) := 24865;
YELLOW 	CONSTANT NUMBER(11) := 49919;
RED 	CONSTANT NUMBER(11) := 192;
GRAY 	CONSTANT NUMBER(11) := 8421504;

--
-- Procedures and Fuctions
--

/*===========================================================================+
|
|   Name:          Color_Indic_Dim_Combination
|
|   Description:   This function calculate the colors for the given KPI Measure.
|                  The color are stored in bsc_sys_kpi_colors table.
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Color_Indic_Dim_Combination(
        x_indic_code                IN NUMBER,
        x_kpi_measure_id            IN NUMBER,
        x_calc_color_flag           IN BOOLEAN,
        x_indic_pl_flag             IN BOOLEAN,
        x_indic_initiatives_flag    IN BOOLEAN,
        x_indic_precalculated_flag  IN BOOLEAN,
        x_tab_id                    IN NUMBER,
        x_dim_combination           IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_families              IN NUMBER,
        x_periodicity_id            IN NUMBER,
        x_comp_level_pk_col         IN VARCHAR2,
        x_dim_set_id                IN NUMBER,
        x_color_by_total            IN NUMBER,
        x_measure_formula           IN VARCHAR2,
        x_current_fy                IN NUMBER,
        x_aw_flag                   IN BOOLEAN -- AW_INTEGRATION: need this new parameter
        )
    RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Color_Indicator
|
|   Description:   This function calculate the colors for the given indicator.
|                  The coor are stored in bsc_sys_kpi_colors table.
|
|   Parameters:	   x_indic_code - indicator code
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Color_Indicator(
	x_indic_code IN NUMBER
	) RETURN BOOLEAN;


--LOCKING: new function
FUNCTION Color_Indicator_AT(
    x_indic_code IN NUMBER
    ) RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Create_Temp_Tab_Tables
|
|   Description:   This function creates some TAB temporal tables to be used
|                  by the coloring process of all indicators. These tables are
|                  BSC_TMP_TAB_DEF and BSC_TMP_TAB_COM
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Create_Temp_Tab_Tables RETURN BOOLEAN;

--LOCKING: new function
FUNCTION Create_Temp_Tab_Tables_AT RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Drop_Temp_Tab_Tables
|
|   Description:   This function drops some TAB temporal tables used
|                  by the coloring process of all indicators.
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Drop_Temp_Tab_Tables RETURN BOOLEAN;


/*===========================================================================+
|
|   Name:          Get_Condition_On_Color_Table
|
|   Description:   This function return in the parameter x_condition a condition
|                  on the table that is used the get the right records to calculate
|                  the color of the indicator.
|
|   Parameters:	   x_indic_code - indicator code
|	           x_dim_set_id - default dimension set
|		   x_table_name - table name used to calculate the colors
|                  x_dim_combination - dimension combination (dimension index within the family)
|                  x_dim_com_keys - dimension combination (key names)
|                                 - Arrays are from 0 to x_num_families - 1
|                  x_num_families - number of families of the list
|                  x_comp_level_pk_col - key name of comparison drill
|                  x_color_by_total - flag to indicate if the color is calculated with totals
|                                   - even if the indicator enters in comparison
|                  x_condition - to retunr the condition
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Condition_On_Color_Table(
	x_indic_code IN NUMBER,
        x_aw_flag IN BOOLEAN, -- AW_INTEGRATION: new parameter
        x_indic_pl_flag IN BOOLEAN,
        x_indic_precalculated_flag IN BOOLEAN,
        x_dim_set_id IN NUMBER,
        x_table_name IN VARCHAR2,
        x_dim_combination IN BSC_UPDATE_UTIL.t_array_of_number,
        x_dim_com_keys IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_families IN NUMBER,
        x_comp_level_pk_col IN VARCHAR2,
        x_color_by_total IN NUMBER,
        x_condition OUT NOCOPY VARCHAR2,
        x_bind_vars_values OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_bind_vars OUT NOCOPY NUMBER ,
        x_aw_limit_tbl IN OUT NOCOPY BIS_PMV_PAGE_PARAMETER_TBL --AW_INTEGRATION: new parameter
        ) RETURN BOOLEAN;

/*===========================================================================+
|
|   Name:          Get_Table_Used_To_Color
|
|   Description:   This function get the table used by the indicator in the
|                  given specification.
|
|   Parameters:	   x_indic_code - indicator code
|                  x_peridiocity - selected periodicity
|                  x_dim_set_id - selected dimension set
|                  x_comp_level_pk_col - pk column name of drill in comparison
|                                      - It's NULL if the indicator doesnt enter
|                                      - in comparison
|                  x_color_by_total - The color is calculated with totals
|                                   - even if the indicator enter in comparison
|                  x_selected_dim_keys - array with the selected drills.
|                                        This array is from 0 to x_num_selected_dim_keys - 1
|                  x_num_selected_dim_keys - number of selected drills
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return NULL. Otherwise return
|		   the table name.
|
|   Notes:
|
+============================================================================*/
FUNCTION Get_Table_Used_To_Color(
	x_indic_code IN NUMBER,
	x_periodicity_id IN NUMBER,
	x_dim_set_id IN NUMBER,
        x_comp_level_pk_col IN VARCHAR2,
        x_color_by_total IN NUMBER,
        x_selected_dim_keys IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_selected_dim_keys IN NUMBER,
        x_level_comb OUT NOCOPY VARCHAR2
	) RETURN VARCHAR2;


/*===========================================================================+
|
|   Name:          Insert_Tab_Combinations
|
|   Description:   This function insert into temporal table BSC_TMP_TAB_COM
|                  the different combinations of dimensions for the given tab.
|
|   Returns: 	   If any error ocurrs, this function add the error message
|		   to the error stack and return FALSE. Otherwise return
|		   TRUE
|
|   Notes:
|
+============================================================================*/
FUNCTION Insert_Tab_Combinations(
	x_tab_id IN NUMBER,
        x_num_dimensions_by_family IN BSC_UPDATE_UTIL.t_array_of_number,
        x_max_family_index IN NUMBER
	) RETURN BOOLEAN;

/*===========================================================================+
|
|   Name:          get_KPI_property_value
|
|   Description:   This function return the property vaue for a given kpi and
|                  property_code
|
|   Returns: 	   It return the property value
|   Notes:
|
+============================================================================*/
FUNCTION  Get_KPI_Property_Value(x_indicator number,
                            x_property_code varchar2,
			    x_default_value number ) RETURN NUMBER;


TYPE t_objective_color_rec IS RECORD (
  tab_id                  bsc_tabs_b.tab_id%TYPE,
  objective_id            bsc_kpis_b.indicator%TYPE,
  obj_pl_flag             BOOLEAN,
  obj_initiatives_flag    BOOLEAN,
  obj_precalculated_flag  BOOLEAN,
  periodicity_id          bsc_kpis_b.periodicity_id%TYPE,
  current_fy              NUMBER,
  aw_flag                 BOOLEAN,
  sim_flag                BOOLEAN
);

--BugFix 6110361
TYPE t_key_rec IS RECORD (
  dimvalues               VARCHAR2(100),
  period                  NUMBER,
  vreal                   NUMBER,
  vprev                   NUMBER,
  trend                   NUMBER
);

TYPE t_key_tbl_type IS TABLE OF t_key_rec INDEX BY BINARY_INTEGER;

END BSC_UPDATE_COLOR;

/
