--------------------------------------------------------
--  DDL for Package Body BIS_COMPUTED_ACTUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_COMPUTED_ACTUAL_PVT" AS
/* $Header: BISVCPAB.pls 115.48 2003/04/21 06:19:15 sugopal ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_COMPUTED_ACTUAL_PVT';
--

G_ERROR_CLAUSE VARCHAR2(30) := 'G_ERROR_CLAUSE';

c_region_in_params        VARCHAR2(20) := 'PREGIONCODE='; -- 2841680
c_and                     VARCHAR2(5) := '&';
c_region_in_webhtmlcall   VARCHAR2(40) := 'BISVIEWER.SHOWREPORT(';


TYPE Measure_Instance_DB_Obj_Rec IS RECORD
( Region_Code                ak_regions.region_code%TYPE
, Attribute_code             ak_region_items.attribute_code%TYPE
, Database_Object_name	     ak_regions.DATABASE_OBJECT_NAME%TYPE
, Database_Obj_Column_Name   ak_region_items.ATTRIBUTE4%TYPE
, Database_Obj_Column_Type   ak_region_items.ATTRIBUTE1%TYPE
, Column_Value               VARCHAR2(32000)
);

TYPE Measure_Instance_DB_Obj_Tbl IS TABLE OF Measure_Instance_DB_Obj_rec
  INDEX BY BINARY_INTEGER;


--

PROCEDURE Get_Object_Data_Source
( p_object_tbl            IN object_tbl_type
, x_database_object_name  OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Object_Attributes
( p_measure_short_name    IN VARCHAR2
, p_dim_level_value_Tbl   IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_object_tbl            IN object_tbl_type
, p_compare_region_item   IN VARCHAR2
, p_compare_region_code   IN VARCHAR2
, x_object_attribute_tbl  OUT NOCOPY object_attribute_tbl_type
, x_return_status         OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Obj_Attribute_Data_Source
( p_database_object         IN VARCHAR2
, p_object_attribute_tbl    IN object_attribute_tbl_type
, x_Measure_Inst_DB_Obj_tbl OUT NOCOPY Measure_Instance_DB_Obj_Tbl
, x_return_status           OUT NOCOPY VARCHAR2
);

PROCEDURE Get_dimension_level_values
( p_dim_level_value_Tbl     IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_Measure_Inst_DB_Obj_tbl IN Measure_Instance_DB_Obj_Tbl
, x_Measure_Inst_DB_Obj_tbl OUT NOCOPY Measure_Instance_DB_Obj_Tbl
, x_return_status           OUT NOCOPY VARCHAR2
);

PROCEDURE Build_Query_Statement
( p_Measure_Instance_Obj_tbl IN Measure_Instance_DB_Obj_Tbl
, p_measure_short_name       IN VARCHAR2
, p_compare_region_item   IN VARCHAR2
, p_compare_region_code   IN VARCHAR2
, x_select_clause            OUT NOCOPY VARCHAR2
, x_from_clause              OUT NOCOPY VARCHAR2
, x_where_clause             OUT NOCOPY VARCHAR2
, x_group_by_clause          OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
);

PROCEDURE Build_select_clause
( p_Measure_Instance_Obj_tbl IN Measure_Instance_DB_Obj_Tbl
, p_measure_short_name       IN VARCHAR2
, p_compare_region_item   IN VARCHAR2
, p_compare_region_code   IN VARCHAR2
, x_select_clause            OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
);

PROCEDURE Build_from_clause
( p_Measure_Instance_Obj_tbl IN Measure_Instance_DB_Obj_Tbl
, x_from_clause              OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
);

PROCEDURE Build_where_clause
( p_Measure_Instance_Obj_tbl IN Measure_Instance_DB_Obj_Tbl
, p_measure_short_name       IN VARCHAR2
, x_where_clause             OUT NOCOPY VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
);

PROCEDURE Build_group_by_clause
( p_Measure_Instance_Obj_tbl IN Measure_Instance_DB_Obj_Tbl
, p_measure_short_name       IN VARCHAR2
, x_group_by_clause          OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
);

PROCEDURE Execute_Query
( p_select_clause            IN VARCHAR2
, p_from_clause              IN VARCHAR2
, p_where_clause             IN VARCHAR2
, p_group_by_clause          IN VARCHAR2
, x_Actual_value             OUT NOCOPY NUMBER
, x_compare_value            OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
);

PROCEDURE Save_Report_URL
( p_measure_instance        IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl     IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, P_TIME_PARAMETER          IN BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
, P_PARAMETER               IN BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
, p_view_by_level	    IN VARCHAR2
, p_time_level_id           IN NUMBER
, p_time_level_value_id     IN VARCHAR2
, x_Rpt_Link                    OUT NOCOPY VARCHAR2
, x_return_status               OUT NOCOPY VARCHAR2
, x_error_msg                   OUT NOCOPY VARCHAR2
);


PROCEDURE Form_Actual_Rec
( p_Measure_Instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_actual_value          IN NUMBER
, p_compare_value          IN NUMBER
, x_Actual_Rec            OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status         OUT NOCOPY VARCHAR2
);

FUNCTION Get_Aggregate_Function
( p_Measure_Instance_Obj_rec IN Measure_Instance_DB_Obj_rec)
RETURN VARCHAR2;

FUNCTION get_time_period_name
(p_time_level_value_id IN VARCHAR2)
RETURN VARCHAR2;

--

PROCEDURE Get_dimension_level_value
( p_dim_level_value_Tbl        IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_dim_level_id               IN  VARCHAR2
, p_count                      IN  NUMBER
, x_dimension_level_value_id   OUT NOCOPY VARCHAR2
, x_dimension_level_value_NAME OUT NOCOPY VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
);

--

PROCEDURE get_Parameters_For_Actual
( p_Target_Level_Rec     	IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
 ,p_dim_level_value_tbl		IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
 ,p_dimension_number		IN NUMBER
 ,p_count			IN NUMBER
 ,p_Actual_Rec           	IN BIS_ACTUAL_PUB.Actual_Rec_Type
 ,p_time_level_id 		IN NUMBER
 ,p_Time_Level_short_name  	IN VARCHAR
 ,p_Time_Level_value_id    	IN VARCHAR
 ,P_TIME_PARAMETER_REC_TYPE	IN BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
 ,P_PARAMETER_TBL_TYPE   	IN BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
 ,X_PARAMETER_TBL_TYPE   	IN OUT NOCOPY BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
 ,X_TIME_PARAMETER_REC_TYPE	IN OUT NOCOPY BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
 ,x_time_level_id 		IN OUT NOCOPY NUMBER
 ,x_Time_Level_short_name  	IN OUT NOCOPY VARCHAR
 ,x_Time_Level_value_id    	IN OUT NOCOPY VARCHAR
 ,x_Actual_Rec           	IN OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
 ,x_count			IN OUT NOCOPY NUMBER
 ,x_return_status     		OUT NOCOPY VARCHAR2
) ;

--

PROCEDURE  print_report_url_params
(  p_measure_id               IN NUMBER
,  p_bplan_name               IN VARCHAR
,  p_region_code              IN VARCHAR
,  p_function_name            IN VARCHAR
,  p_viewby_level_short_name  IN VARCHAR
,  p_Parm1Level_short_name    IN VARCHAR
,  p_Parm1Value_name          IN VARCHAR
,  p_Parm2Level_short_name    IN VARCHAR
,  p_Parm2Value_name          IN VARCHAR
,  p_Parm3Level_short_name    IN VARCHAR
,  p_Parm3Value_name          IN VARCHAR
,  p_Parm4Level_short_name    IN VARCHAR
,  p_Parm4Value_name          IN VARCHAR
,  p_Parm5Level_short_name    IN VARCHAR
,  p_Parm5Value_name          IN VARCHAR
,  p_Parm6Level_short_name    IN VARCHAR
,  p_Parm6Value_name          IN VARCHAR
,  p_Parm7Level_short_name    IN VARCHAR
,  p_Parm7Value_name          IN VARCHAR
,  p_TimeParmLevel_short_name IN VARCHAR
,  p_TimeFromParmValue_name   IN VARCHAR
,  p_TimeToParmValue_name     IN VARCHAR
) ;

--

PROCEDURE print_Parameter_Table_Values
( P_PARAMETER_TBL_TYPE   	IN BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
 ,P_TIME_PARAMETER_REC_TYPE	IN BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
 ,p_view_by_lvl_sht_name	IN VARCHAR2
 ,p_actual_region_code		IN ak_regions.REGION_CODE%TYPE
 ,p_actual_region_item		IN ak_region_items.region_code%TYPE
 ,p_compare_region_item		IN ak_region_items.region_code%TYPE
 ,x_return_status     		OUT NOCOPY VARCHAR2
) ;

--

PROCEDURE print_to_log_dim_level_info
( p_dim_level_id	IN VARCHAR2,
  p_dim_level_value_id	IN VARCHAR2,
  p_dim_level_number	IN NUMBER,
  p_is_time_dim_level	IN BOOLEAN,
  p_is_total_dim_level	IN BOOLEAN
);

--

PROCEDURE get_view_by_level (
    p_Target_Level_Rec     	IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  , p_Time_Level_short_name   	IN VARCHAR2
  , P_PARAMETER_TBL_TYPE   	IN BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
  , x_view_by_level_short_name 	OUT NOCOPY VARCHAR2
  , x_return_status		OUT NOCOPY VARCHAR2
) ;

--


PROCEDURE Retrieve_Actual_from_PMV
( p_api_version           IN NUMBER
, p_all_info              IN VARCHAR2 Default FND_API.G_TRUE
, p_Measure_Instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Actual_Rec            OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status         OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_Measure_Inst_DB_Obj_tbl Measure_Instance_DB_Obj_Tbl;
  l_measure_short_name   bisbv_performance_measures.measure_short_name%type;
  l_Target_Level_Rec     BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
  l_target_level_rec_p   BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
  l_Measure_Instance     BIS_MEASURE_PUB.Measure_Instance_type;

  l_dim_level_value_tbl	 BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
  l_DimShortName         VARCHAR2(32000);
  l_DimLevelShortName    VARCHAR2(32000);

  l_DimLevelValueId      VARCHAR2(32000);
  l_DimLevelValueName    VARCHAR2(32000);

  l_actual_value         NUMBER;
  l_compare_value        NUMBER;

  l_Actual_Rec           BIS_ACTUAL_PUB.Actual_Rec_Type;
  l_actual_rec_p         BIS_ACTUAL_PUB.Actual_Rec_Type;
  l_return_status        VARCHAR2(32000);

  l_count                NUMBER := 1;
  l_count_p		 NUMBER := 1;
  l_time_level_id	 NUMBER;		-- 2164190
  l_time_level_id_p	 NUMBER;
  l_Time_Level_short_name VARCHAR2(30);		-- 2164190
  l_time_level_short_name_p VARCHAR2(30);
  l_Time_Level_value_id  VARCHAR2(80);		-- 2164190
  l_time_level_value_id_p  VARCHAR2(80);
  l_Rpt_Link		 VARCHAR2(32000);	-- 2164190
  l_return_status1       VARCHAR2(3000);	-- 2164190
  l_error_msg		 VARCHAR2(32000);	-- 2164190

  l_compare_region_appl_id ak_regions.REGION_APPLICATION_ID%TYPE;
  L_COMPARISION_SOURCE    VARCHAR2(300);
  L_ACTUAL_DATA_SOURCE    VARCHAR2(300);
  l_compare_region_code ak_regions.REGION_CODE%TYPE := BIS_UTILITIES_PUB.G_NULL_CHAR;
  l_compare_region_item ak_region_items.region_code%TYPE := BIS_UTILITIES_PUB.G_NULL_CHAR;

  l_actual_region_code ak_regions.REGION_CODE%TYPE := BIS_UTILITIES_PUB.G_NULL_CHAR;
  l_actual_region_item ak_region_items.region_code%TYPE := BIS_UTILITIES_PUB.G_NULL_CHAR;

  L_PARAMETER_TBL_TYPE   	BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE;
  l_parameter_tbl_type_p	BIS_PMV_ACTUAL_PVT.parameter_tbl_type;
  L_TIME_PARAMETER_REC_TYPE	BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE;
  l_time_parameter_rec_type_p	BIS_PMV_ACTUAL_PVT.time_parameter_rec_type;

  CURSOR cr_performance_measures(pi_measure_short_name  VARCHAR2) IS
     SELECT comparison_source, ACTUAL_DATA_SOURCE
      FROM bisbv_performance_measures
      WHERE measure_short_name = pi_measure_short_name;

  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(32000);

  l_print_text       VARCHAR2(32000);

  l_is_time_level       BOOLEAN := FALSE;
  l_is_total_level      BOOLEAN := TRUE;
  i 		     	number;

  l_view_by		 	VARCHAR2(80);
  l_first_non_time_not_all 	NUMBER := 0;
  l_first_non_time_but_total 	NUMBER := 0;
  level1_short_name		VARCHAR2(80);
  level2_short_name		VARCHAR2(80);
  level3_short_name		VARCHAR2(80);
  level4_short_name		VARCHAR2(80);
  level5_short_name		VARCHAR2(80);
  level6_short_name		VARCHAR2(80);
  level7_short_name		VARCHAR2(80);
  l_first_nonAll_level		NUMBER := 0;
  l_temp_1_nonAll_level		NUMBER := 0;
  l_first_nonAll_nonTime_Lvl	NUMBER := 0;
  l_temp_1_nonAll_nonTime_Lvl	NUMBER := 0;


BEGIN

  l_Measure_Instance := p_Measure_Instance;
  l_dim_level_value_tbl := p_dim_level_value_tbl;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing
    (l_Measure_Instance.target_level_ID) = FND_API.G_TRUE)
  AND (BIS_UTILITIES_PUB.Value_Not_Null
     (l_Measure_Instance.target_level_ID) = FND_API.G_TRUE))
  THEN
    l_Target_Level_Rec.target_level_ID := p_Measure_Instance.target_level_ID;
    l_target_level_rec_p := l_Target_Level_Rec;
    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version         => p_api_version
    , p_Target_Level_Rec    => l_target_level_rec_p
    , p_all_info            => FND_API.G_TRUE
    , x_Target_Level_Rec    => l_Target_Level_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
  END IF;


  l_actual_rec.target_Level_Id := p_measure_instance.Target_Level_ID;
  l_actual_rec.Target_Level_short_name := p_measure_instance.Target_Level_short_name;
  l_actual_rec.Target_Level_name := p_measure_instance.Target_Level_name;

  BIS_UTILITIES_PUB.put_line(p_text => ' ........... START: Dimension Level Values for this target ........... ' ) ;

  BIS_UTILITIES_PUB.put_line(p_text => ' Parameters for this actual are ' ) ;

  for i IN 1..7 loop

    l_count_p := l_count;
    l_actual_rec_p := l_actual_rec;
    l_time_level_id_p := l_time_level_id;
    l_time_level_short_name_p := l_Time_Level_short_name;
    l_time_level_value_id_p := l_Time_Level_value_id;
    l_time_parameter_rec_type_p := l_TIME_PARAMETER_REC_TYPE;
    l_parameter_tbl_type_p := L_PARAMETER_TBL_TYPE;

    get_Parameters_For_Actual
    ( p_Target_Level_Rec     	=> l_Target_Level_Rec
     ,p_dim_level_value_tbl	=> p_dim_level_value_tbl
     ,p_dimension_number	=> i
     ,p_count			=> l_count_p
     ,p_Actual_Rec           	=> l_actual_rec_p
     ,p_time_level_id 		=> l_time_level_id_p
     ,p_Time_Level_short_name  	=> l_time_level_short_name_p
     ,p_Time_Level_value_id    	=> l_time_level_value_id_p
     ,p_TIME_PARAMETER_REC_TYPE => l_time_parameter_rec_type_p
     ,P_PARAMETER_TBL_TYPE   	=> l_parameter_tbl_type_p
     ,X_PARAMETER_TBL_TYPE   	=> L_PARAMETER_TBL_TYPE
     ,X_TIME_PARAMETER_REC_TYPE	=> L_TIME_PARAMETER_REC_TYPE
     ,x_time_level_id 		=> l_time_level_id
     ,x_Time_Level_short_name  	=> l_Time_Level_short_name
     ,x_Time_Level_value_id    	=> l_Time_Level_value_id
     ,x_Actual_Rec           	=> l_actual_rec
     ,x_count			=> l_count
     ,x_return_status     	=> x_return_status
    );

  END loop;

  BIS_UTILITIES_PUB.put_line(p_text => ' time level short name is ... ' || l_Time_Level_short_name ) ;

  get_view_by_level (
    p_Target_Level_Rec     	=> l_Target_Level_Rec
  , p_Time_Level_short_name   	=> l_Time_Level_short_name  -- , P_TIME_PARAMETER_REC_TYPE 	=> l_TIME_PARAMETER_REC_TYPE
  , P_PARAMETER_TBL_TYPE 	=> L_PARAMETER_TBL_TYPE
  , x_view_by_level_short_name  => l_view_by
  , x_return_status		=> l_return_status
  ) ;

  BIS_UTILITIES_PUB.put_line(p_text => ' ........... END: Dimension Level Values for this target ........... ' ) ;


  OPEN cr_performance_measures(l_target_level_rec.measure_short_name);

  FETCH cr_performance_measures INTO L_COMPARISION_SOURCE, L_ACTUAL_DATA_SOURCE;

  IF cr_performance_measures%NOTFOUND THEN
     CLOSE cr_performance_measures;
  END IF;

  CLOSE cr_performance_measures;

  l_compare_region_item := SUBSTR(L_COMPARISION_SOURCE, (INSTR(L_COMPARISION_SOURCE,'.')+1));
  l_compare_region_code := SUBSTR(L_COMPARISION_SOURCE, 1, (INSTR(L_COMPARISION_SOURCE,'.')-1));

  l_actual_region_item := SUBSTR(L_ACTUAL_DATA_SOURCE, (INSTR(L_ACTUAL_DATA_SOURCE,'.')+1));
  l_actual_region_code := SUBSTR(L_ACTUAL_DATA_SOURCE, 1, (INSTR(L_ACTUAL_DATA_SOURCE,'.')-1));


  print_Parameter_Table_Values
  ( P_PARAMETER_TBL_TYPE   	=> L_PARAMETER_TBL_TYPE
   ,P_TIME_PARAMETER_REC_TYPE	=> L_TIME_PARAMETER_REC_TYPE
   ,p_view_by_lvl_sht_name	=> l_view_by
   ,p_actual_region_code	=> l_actual_region_code
   ,p_actual_region_item	=> l_actual_region_item
   ,p_compare_region_item	=> l_compare_region_item
   ,x_return_status     	=> x_return_status
  );


  Begin

    BIS_PMV_ACTUAL_PUB.GET_ACTUAL_VALUE
      (p_region_code               => l_actual_region_code
      ,p_function_name             => NULL
      ,p_user_id                   => NULL
      ,p_responsibility_id         => NULL
      ,p_time_parameter            => L_TIME_PARAMETER_REC_TYPE
      ,p_parameters                => L_PARAMETER_TBL_TYPE
      ,p_actual_attribute_code     => l_actual_region_item
      ,p_compareto_attribute_code  => l_compare_region_item
      ,x_actual_value              => l_actual_value
      ,x_compareto_value           => l_compare_value
      ,x_return_status             => x_return_status
      ,x_msg_count                 => l_msg_count
      ,x_msg_data                  => l_msg_data);

    IF x_return_status IN (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
        BIS_UTILITIES_PUB.put_line(p_text =>'Error IN retriving Actual value FROM PMV  '||sqlerrm);
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        BIS_UTILITIES_PUB.put_line(p_text =>'Error IN retriving Actual value FROM PMV  '||sqlerrm);
  End;


  BEGIN

      Save_Report_URL
      (
	  p_Measure_Instance  	=> 	l_Measure_Instance
        , p_dim_level_value_tbl	=> 	l_dim_level_value_tbl
        , P_TIME_PARAMETER      =>      L_TIME_PARAMETER_REC_TYPE
        , P_PARAMETER           =>      L_PARAMETER_TBL_TYPE
        , p_view_by_level	=>	l_view_by
        , p_time_level_id       =>      l_time_level_id
        , p_time_level_value_id =>      l_time_level_value_id
	, x_Rpt_Link		=> 	l_Rpt_Link
	, x_return_status	=>	l_return_status1
	, x_error_msg		=>	l_error_msg
	);

  EXCEPTION

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        BIS_UTILITIES_PUB.put_line(p_text =>'Error IN retriving Actual value FROM PMV  '||sqlerrm);

  End;



  l_actual_rec.Actual := to_number(l_actual_value);
  l_actual_rec.Comparison_actual_value := to_number(l_compare_value);
  l_actual_rec.Report_URL := l_Rpt_Link;


  BIS_UTILITIES_PUB.put_line(p_text => ' ........... START : Actual and report url ........... ' ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Actual Value : ' || l_actual_value );
  BIS_UTILITIES_PUB.put_line(p_text => ' Compare Value : ' || l_compare_value );
  BIS_UTILITIES_PUB.put_line(p_text => ' Report Link : ' || l_Rpt_Link );
  BIS_UTILITIES_PUB.put_line(p_text => ' ...........  END : Actual and report url ...........  ' ) ;


--  BIS_UTILITIES_PUB.put_line(p_text =>'Target Level Passed ' || l_actual_rec.target_Level_Id );

  x_actual_rec := l_actual_rec;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_actual_rec := NULL;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN retrieve computed actual: '||sqlerrm);

END Retrieve_Actual_from_PMV;



PROCEDURE get_view_by_level (
    p_Target_Level_Rec     	IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
  , p_Time_Level_short_name   	IN  VARCHAR2
  , P_PARAMETER_TBL_TYPE   	IN  BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
  , x_view_by_level_short_name 	OUT NOCOPY VARCHAR2
  , x_return_status		OUT NOCOPY VARCHAR2
) IS

  l_view_by	VARCHAR2(80);

BEGIN		-- BIS_UTILITIES_PUB.put_line(p_text => ' xxxxxxxx 0000 ' ) ;

  IF ( p_Time_Level_short_name IS NOT NULL ) THEN

    l_view_by := p_Time_Level_short_name ;

  ELSE
    IF (
        ( P_PARAMETER_TBL_TYPE.COUNT > 0 )  AND
        ( P_PARAMETER_TBL_TYPE.EXISTS(1) )
       ) THEN 		-- BIS_UTILITIES_PUB.put_line(p_text => ' xxxxxxxx 2222 ' ) ;


      l_view_by :=  SUBSTR
                      (
                        P_PARAMETER_TBL_TYPE(1).parameter_name,
                        (INSTR(P_PARAMETER_TBL_TYPE(1).parameter_name,'+')+1)
                      );
    END IF;
  END IF;	-- BIS_UTILITIES_PUB.put_line(p_text => ' xxxxxxxx 3333 ' ) ;

  x_view_by_level_short_name := l_view_by ;
  x_return_status := 'S' ;
  BIS_UTILITIES_PUB.put_line(p_text => ' The view by  level short name is : ' || x_view_by_level_short_name ) ;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := 'E' ;
    BIS_UTILITIES_PUB.put_line(p_text => ' The view by short name could not be found ' ) ;

END;




-- Derives the actual value for the specified set of dimension values
-- i.e. for a specific organization, time period, etc.
--
-- If information about dimension values are not required, set all_info
-- to FALSE.
--
PROCEDURE Retrieve_Computed_Actual
( p_api_version           IN NUMBER
, p_all_info              IN VARCHAR2 Default FND_API.G_TRUE
, p_Measure_Instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Actual_Rec            OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status         OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_object_tbl           object_tbl_type;
  l_object_attribute_tbl object_attribute_tbl_type ;
  l_Measure_Inst_DB_Obj_tbl Measure_Instance_DB_Obj_Tbl;
  l_measure_inst_db_obj_tbl_p Measure_Instance_DB_Obj_Tbl;
  l_database_object_name ak_regions.DATABASE_OBJECT_NAME%TYPE;
  l_measure_short_name   bisbv_performance_measures.measure_short_name%type;
  l_Target_Level_Rec     BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
  l_target_level_rec_p	 BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
  l_Measure_Instance     BIS_MEASURE_PUB.Measure_Instance_type;
  l_dim_level_value_tbl	 BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
  l_select_clause        VARCHAR2(32000);
  l_from_clause          VARCHAR2(32000);
  l_where_clause         VARCHAR2(32000);
  l_group_by_clause      VARCHAR2(32000);
  l_actual_value         NUMBER;
  l_compare_value         NUMBER;
  l_Actual_Rec           BIS_ACTUAL_PUB.Actual_Rec_Type;
  l_return_status        VARCHAR2(32000);

      l_compare_region_code ak_regions.REGION_CODE%TYPE := BIS_UTILITIES_PUB.G_NULL_CHAR;
      l_compare_region_appl_id ak_regions.REGION_APPLICATION_ID%TYPE;
      L_COMPARISION_SOURCE    VARCHAR2(300);
      l_compare_region_item ak_region_items.region_code%TYPE := BIS_UTILITIES_PUB.G_NULL_CHAR;


    CURSOR cr_performance_measures(pi_measure_short_name  VARCHAR2) IS
        SELECT comparison_source
          FROM bisbv_performance_measures
         WHERE measure_short_name = pi_measure_short_name;


BEGIN

--  BIS_UTILITIES_PUB.put_line(p_text =>'Computing actual value.');
  l_Measure_Instance := p_Measure_Instance;
  l_dim_level_value_tbl := p_dim_level_value_tbl;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing
    (l_Measure_Instance.target_level_ID) = FND_API.G_TRUE)
  AND (BIS_UTILITIES_PUB.Value_Not_Null
     (l_Measure_Instance.target_level_ID) = FND_API.G_TRUE))
  THEN
    l_Target_Level_Rec.target_level_ID := p_Measure_Instance.target_level_ID;
    l_target_level_rec_p := l_Target_Level_Rec;
    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version         => p_api_version
    , p_Target_Level_Rec    => l_target_level_rec_p
    , p_all_info            => FND_API.G_TRUE
    , x_Target_Level_Rec    => l_Target_Level_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
  END IF;

  For i IN 1..7 Loop
    IF (i=1) THEN
       l_dim_level_value_tbl(i).dimension_level_id := l_target_level_rec.dimension1_level_id;
    END IF;
    IF (i=2) THEN
       l_dim_level_value_tbl(i).dimension_level_id := l_target_level_rec.dimension2_level_id;
    END IF;
    IF (i=3) THEN
       l_dim_level_value_tbl(i).dimension_level_id := l_target_level_rec.dimension3_level_id;
    END IF;
    IF (i=4) THEN
       l_dim_level_value_tbl(i).dimension_level_id := l_target_level_rec.dimension4_level_id;
    END IF;
    IF (i=5) THEN
       l_dim_level_value_tbl(i).dimension_level_id := l_target_level_rec.dimension5_level_id;
    END IF;
    IF (i=6) THEN
       l_dim_level_value_tbl(i).dimension_level_id := l_target_level_rec.dimension6_level_id;
    END IF;
    IF (i=7) THEN
       l_dim_level_value_tbl(i).dimension_level_id := l_target_level_rec.dimension7_level_id;
    END IF;

 END loop;

  --BIS_UTILITIES_PUB.put_line(p_text =>'measure : '||l_Target_Level_Rec.measure_short_name);

  OPEN cr_performance_measures(l_target_level_rec.measure_short_name);
  FETCH cr_performance_measures INTO L_COMPARISION_SOURCE;
  IF cr_performance_measures%NOTFOUND THEN
     CLOSE cr_performance_measures;
  END IF;
     CLOSE cr_performance_measures;

  l_compare_region_item := SUBSTR(L_COMPARISION_SOURCE,
                          (INSTR(L_COMPARISION_SOURCE,'.')+1));
  l_compare_region_code := SUBSTR(L_COMPARISION_SOURCE, 1,
                          (INSTR(L_COMPARISION_SOURCE,'.')-1));


  -- Get related objects;
  --

  Get_Related_Objects
  ( p_measure_short_name => l_target_level_rec.measure_short_name
  , x_object_tbl         => l_object_tbl
  , x_return_status      => l_return_status
  );

  -- Get object data source;
  --
  Get_Object_Data_Source
  ( p_object_tbl            => l_object_tbl
  , x_database_object_name  => l_database_object_name
  , x_return_status         => l_return_status
  );

--  BIS_UTILITIES_PUB.put_line(p_text =>'data source: '||l_database_object_name);

  -- Get object attributes;
  --
  Get_Object_Attributes
  ( p_measure_short_name => l_target_level_rec.measure_short_name
  , p_dim_level_value_Tbl   => l_Dim_Level_Value_Tbl
  , p_object_tbl            => l_object_tbl
  , p_compare_region_item   => l_compare_region_item
  , p_compare_region_code   => l_compare_region_code
  , x_object_attribute_tbl  => l_object_attribute_tbl
  , x_return_status         => l_return_status
  );

  -- Get object attribute database columns;
  --
  Get_Obj_Attribute_Data_Source
  ( p_database_object         => l_database_object_name
  , p_object_attribute_tbl    => l_object_attribute_tbl
  , x_Measure_Inst_DB_Obj_tbl => l_Measure_Inst_DB_Obj_Tbl
  , x_return_status           => l_return_status
  );

  -- Get dimension level value
  --
  l_measure_inst_db_obj_tbl_p := l_Measure_Inst_DB_Obj_Tbl;
  Get_dimension_level_values
  ( p_dim_level_value_Tbl     => l_Dim_Level_Value_Tbl
  , p_Measure_Inst_DB_Obj_tbl => l_measure_inst_db_obj_tbl_p
  , x_Measure_Inst_DB_Obj_tbl => l_Measure_Inst_DB_Obj_Tbl
  , x_return_status           => l_return_status
  );

  -- build query statement;
  --
  Build_Query_Statement
  ( p_Measure_Instance_Obj_tbl => l_Measure_Inst_DB_Obj_Tbl
  , p_measure_short_name       => l_target_level_rec.measure_short_name
  , p_compare_region_item      => l_compare_region_item
  , p_compare_region_code      => l_compare_region_code
  , x_select_clause            => l_select_clause
  , x_from_clause              => l_from_clause
  , x_where_clause             => l_where_clause
  , x_group_by_clause          => l_group_by_clause
  , x_return_status            => l_return_status
  );
  -- BIS_UTILITIES_PUB.put_line(p_text =>'select_clause: '||l_select_clause);
  -- BIS_UTILITIES_PUB.put_line(p_text =>'from_clause: '||l_from_clause);
  -- BIS_UTILITIES_PUB.put_line(p_text =>'where_clause: '||l_where_clause);
  -- BIS_UTILITIES_PUB.put_line(p_text =>'group by_clause: '||l_group_by_clause);

  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    Execute_Query
    ( p_select_clause            => l_select_clause
    , p_from_clause              => l_from_clause
    , p_where_clause             => l_where_clause
    , p_group_by_clause          => l_group_by_clause
    , x_Actual_value             => l_Actual_value
    , x_compare_value            => l_compare_value
    , x_return_status            => l_return_status
    );
    BIS_UTILITIES_PUB.put_line(p_text =>'Finished executing query; status is: '||l_return_status );

    Form_Actual_Rec
    ( p_Measure_Instance      => l_Measure_Instance
    , p_dim_level_value_tbl   => l_dim_level_value_tbl
    , p_actual_value          => l_actual_value
    , p_compare_value         => l_compare_value
    , x_Actual_Rec            => l_Actual_Rec
    , x_return_status         => l_return_status
    );
  END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_actual_rec := NULL;
  END IF;

  x_actual_rec := l_actual_rec;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN retrieve computed actual: '||sqlerrm);

END Retrieve_Computed_Actual;

-- Code added for 1850860 starts here

    PROCEDURE Get_Related_Objects
    ( p_measure_short_name    IN VARCHAR2
    , x_object_tbl            OUT NOCOPY object_tbl_type
    , x_return_status         OUT NOCOPY VARCHAR2
    )
    IS

      l_object_tbl object_tbl_type;
      l_actual_region_code ak_regions.REGION_CODE%TYPE := BIS_UTILITIES_PUB.G_NULL_CHAR;
      l_actual_region_application_id ak_regions.REGION_APPLICATION_ID%TYPE;
      l_actual_data_source    VARCHAR2(300);
      l_actual_region_item ak_region_items.item_name%TYPE := BIS_UTILITIES_PUB.G_NULL_CHAR;

      CURSOR cr_performance_measures(pi_measure_short_name  VARCHAR2) IS
        SELECT actual_data_source
          FROM bisbv_performance_measures
         WHERE measure_short_name = pi_measure_short_name;

      CURSOR cr_region_items(pi_actual_region_item   ak_region_items.item_name%TYPE
                            ,pi_actual_region_code   ak_region_items.region_code%TYPE) IS
        SELECT region_application_id
        FROM   ak_region_items
        WHERE  attribute_code   = pi_actual_region_item
        AND    region_code = pi_actual_region_code;

      CURSOR cr_region_objects
             ( pi_region_code           ak_regions.REGION_CODE%TYPE
             , pi_region_application_id ak_regions.REGION_APPLICATION_ID%TYPE
             ) IS
        SELECT *
        FROM  ak_regions
        WHERE region_code = pi_region_code
        AND    region_application_id = pi_region_application_id
        ORDER BY CREATION_DATE asc;

    BEGIN


      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --  BIS_UTILITIES_PUB.put_line(p_text =>'get related obj. measure: '||p_measure_short_name);

      BIS_UTILITIES_PUB.put_line(p_text =>'Perforamance Measure short name  ' || p_measure_short_name);
      --  SELECT all objects which reference this measure;
      --
      OPEN cr_performance_measures(p_measure_short_name);
      FETCH cr_performance_measures INTO l_actual_data_source;
      CLOSE cr_performance_measures;

BIS_UTILITIES_PUB.put_line(p_text =>'Actual Data Source  ' || l_actual_data_source);
      l_actual_region_item := SUBSTR(l_actual_data_source, (INSTR(l_actual_data_source,'.')+1));
      l_actual_region_code := SUBSTR(l_actual_data_source, 1, (INSTR(l_actual_data_source,'.')-1));

      OPEN cr_region_items (l_actual_region_item, l_actual_region_code);
      FETCH cr_region_items INTO l_actual_region_application_id;
      CLOSE cr_region_items;

      OPEN cr_region_objects (l_actual_region_code, l_actual_region_application_id);
      FETCH cr_region_objects INTO l_object_tbl(l_object_tbl.COUNT+1);
          IF cr_region_objects%NOTFOUND THEN
            l_object_tbl.DELETE(l_object_tbl.COUNT);
          END IF;
      CLOSE cr_region_objects;

      IF l_object_tbl.COUNT < 1 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      x_object_tbl := l_object_tbl;
      -- BIS_UTILITIES_PUB.put_line(p_text =>'number of objects, status: '||x_object_tbl.count
      --                                    ||', '||x_return_status);

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Get_Related_Objects: '||sqlerrm);

    END Get_Related_Objects;

-- Code added for 1850860 ends here
/***
** Code commented for 1850860 starts here
***
PROCEDURE Get_Related_Objects
( p_measure_short_name    IN VARCHAR2
, x_object_tbl            OUT NOCOPY object_tbl_type
, x_return_status         OUT NOCOPY VARCHAR2
)
IS

  l_object_tbl object_tbl_type;
  l_region_code ak_regions.REGION_CODE%TYPE := FND_API.G_MISS_CHAR;
  l_region_application_id ak_regions.REGION_APPLICATION_ID%TYPE;

  CURSOR cr_region_objects
         ( p_region_code ak_regions.REGION_CODE%TYPE
         , p_region_application_id ak_regions.REGION_APPLICATION_ID%TYPE
         )
  IS
    SELECT *
    FROM ak_regions r
    WHERE r.region_code = p_region_code
    AND r.region_application_id = p_region_application_id
    ORDER BY CREATION_DATE asc;

  CURSOR cr_region_item IS
    SELECT region_code, region_application_id
    FROM ak_region_items i
    WHERE i.ATTRIBUTE1 = 'MEASURE'
    AND i.ATTRIBUTE2 = p_measure_short_name;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --  BIS_UTILITIES_PUB.put_line(p_text =>'get related obj. measure: '||p_measure_short_name);

  --  SELECT all objects which reference this measure;
  --
  FOR cr_item IN cr_region_item LOOP
    -- BIS_UTILITIES_PUB.put_line(p_text =>'Region code: '||cr_item.region_code);
    IF l_region_code <> cr_item.region_code THEN
      l_region_code := cr_item.region_code;
      l_region_application_id := cr_item.region_application_id;

      OPEN cr_region_objects(l_region_code,l_region_application_id);
      FETCH cr_region_objects INTO l_object_tbl(l_object_tbl.COUNT+1);
      IF cr_region_objects%NOTFOUND THEN
        l_object_tbl.DELETE(l_object_tbl.COUNT);
        CLOSE cr_region_objects;
      END IF;
      IF cr_region_objects%ISOPEN THEN CLOSE cr_region_objects; END IF;
    END IF;
  END LOOP;

  IF l_object_tbl.COUNT < 1 THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  x_object_tbl := l_object_tbl;
  -- BIS_UTILITIES_PUB.put_line(p_text =>'number of objects, status: '||x_object_tbl.count
  --                                    ||', '||x_return_status);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Get_Related_Objects: '||sqlerrm);

END Get_Related_Objects;
***
** Code commented by for 1850860 ends here
***/

PROCEDURE Get_Object_Data_Source
( p_object_tbl            IN object_tbl_type
, x_database_object_name  OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
)
IS

  l_database_object_name  VARCHAR2(32000) := BIS_UTILITIES_PUB.G_NULL_CHAR;
  l_numobjects            NUMBER := 0;

BEGIN

  -- pick out NOCOPY each object's data source object;
  -- IF there IS > 1 data source, THEN error;
  FOR i IN 1..p_object_tbl.COUNT LOOP
    IF p_object_tbl(i).DATABASE_OBJECT_NAME <> l_database_object_name THEN
      l_numobjects := l_numobjects+1;
    END IF;
    l_database_object_name := p_object_tbl(i).DATABASE_OBJECT_NAME;
  END LOOP;

  IF l_numobjects = 0 THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'AK IS not setup.');
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF l_numobjects > 1 THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'More than one data source found for this measure.');
    BIS_UTILITIES_PUB.put_line(p_text =>'The data source that will be used is: '||l_database_object_name);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  --BIS_UTILITIES_PUB.put_line(p_text =>'Object name, numObj: '||l_database_object_name||', '||l_numobjects);
  x_database_object_name := l_database_object_name;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Get_Object_Data_Source: '||sqlerrm);

END Get_Object_Data_Source;

PROCEDURE Get_Object_Attributes
( p_measure_short_name    IN VARCHAR2
, p_dim_level_value_Tbl   IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_object_tbl            IN object_tbl_type
, p_compare_region_item   IN VARCHAR2
, p_compare_region_code   IN VARCHAR2
, x_object_attribute_tbl  OUT NOCOPY object_attribute_tbl_type
, x_return_status         OUT NOCOPY VARCHAR2
)
IS

  l_object_attribute_tbl object_attribute_tbl_type ;
  l_dim_level_value_Tbl  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
  l_dimension_level_rec  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_dimension_level_rec_p  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

  CURSOR cr_attribute
         ( p_region_code           ak_regions.REGION_CODE%TYPE
         , p_region_application_id ak_regions.REGION_APPLICATION_ID%TYPE
         , p_dimension_level_short_name
             bisbv_dimension_levels.DIMENSION_LEVEL_SHORT_NAME%TYPE
         )
  IS
    SELECT *
    FROM ak_region_items
    WHERE REGION_CODE = p_region_code
    AND REGION_APPLICATION_ID = p_region_application_id
    AND ATTRIBUTE1 = 'DIMENSION LEVEL'
    AND get_dim_level_short_name(ATTRIBUTE2)
        = p_dimension_level_short_name;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_dim_level_value_Tbl := p_dim_level_value_Tbl;



  FOR i IN 1..l_dim_level_value_Tbl.COUNT LOOP
    IF (BIS_UTILITIES_PUB.Value_Missing
          (l_dim_level_value_Tbl(i).dimension_level_short_name)
          = FND_API.G_TRUE)
    OR (BIS_UTILITIES_PUB.Value_Null
          (l_dim_level_value_Tbl(i).dimension_level_short_name)
          = FND_API.G_TRUE)
    THEN
      l_Dimension_Level_Rec.Dimension_Level_id
        := l_dim_level_value_Tbl(i).Dimension_Level_id;

      BEGIN
        l_dimension_level_rec_p := l_Dimension_Level_Rec;
        BIS_DIMENSION_LEVEL_PVT.Retrieve_Dimension_Level
        ( p_api_version         => 1.0
        , p_Dimension_Level_Rec => l_dimension_level_rec_p
        , x_Dimension_Level_Rec => l_Dimension_Level_Rec
        , x_return_status       => x_return_status
        , x_error_Tbl           => l_error_tbl
        );
        l_dim_level_value_Tbl(i).Dimension_Level_short_name
          := l_Dimension_Level_Rec.Dimension_Level_short_name;
      EXCEPTION
        WHEN OTHERS THEN
        BIS_UTILITIES_PUB.put_line(p_text =>'Error IN retrieving dimension level');
        return;
      END;
    END IF;
  END LOOP;

  -- get the measure's object attribute
  --
-- BIS_UTILITIES_PUB.put_line(p_text =>'OutSide the Object For loop' );

  IF p_object_tbl.COUNT > 0 THEN

    BEGIN
      Select *
      INTO l_object_attribute_tbl(l_object_attribute_tbl.COUNT+1)
      FROM ak_region_items
      WHERE REGION_CODE = p_object_tbl(1).region_code
      AND REGION_APPLICATION_ID = p_object_tbl(1).region_application_id
      AND ATTRIBUTE1 = 'MEASURE'
      AND ATTRIBUTE2 = p_measure_short_name;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
    END;

--  BIS_UTILITIES_PUB.put_line(p_text =>'Compare Region : '|| p_compare_region_item);

    BEGIN
      Select *
      INTO l_object_attribute_tbl(l_object_attribute_tbl.COUNT+1)
      FROM ak_region_items
      WHERE REGION_CODE = p_object_tbl(1).region_code
      AND REGION_APPLICATION_ID = p_object_tbl(1).region_application_id
      AND ATTRIBUTE1 = 'MEASURE'
      AND ATTRIBUTE_CODE = p_compare_region_item;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         BIS_UTILITIES_PUB.put_line(p_text =>'No Comparison Data Source ');
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END;

  END IF;

--  BIS_UTILITIES_PUB.put_line(p_text =>'number of objects, status: '||p_object_tbl.count);

  -- SELECT each object's attributes that match the given dimension levels;
  --
  FOR i IN 1..p_object_tbl.COUNT LOOP

--BIS_UTILITIES_PUB.put_line(p_text =>'Inside the Object For loop' );
    IF l_dim_level_value_Tbl.COUNT = 0  or ( i >=2 )
          THEN EXIT; END IF;
    -- BIS_UTILITIES_PUB.put_line(p_text =>'retrieving attr for obj: '||p_object_tbl(i).region_code);

    FOR j IN 1..l_dim_level_value_Tbl.COUNT LOOP
      --BIS_UTILITIES_PUB.put_line(p_text =>'dimension level value tbl count, j: '
      --||l_dim_level_value_Tbl.COUNT||', '||j);

      IF ((BIS_UTILITIES_PUB.Value_Not_Missing
          (l_dim_level_value_Tbl(j).dimension_level_short_name)
          = FND_API.G_TRUE)
      AND (BIS_UTILITIES_PUB.Value_Not_Null
          (l_dim_level_value_Tbl(j).dimension_level_short_name)
          = FND_API.G_TRUE))
      THEN
        OPEN cr_attribute
             ( p_object_tbl(i).region_code
             , p_object_tbl(i).region_application_id
             , l_dim_level_value_Tbl(j).dimension_level_short_name
             );
        FETCH cr_attribute
        INTO l_object_attribute_tbl(l_object_attribute_tbl.COUNT+1);
        IF cr_attribute%NOTFOUND THEN
          --BIS_UTILITIES_PUB.put_line(p_text =>'dimension level attribute not found: '
          --    ||l_dim_level_value_Tbl(j).dimension_level_short_name);
          CLOSE cr_attribute;
        ELSE
          l_dim_level_value_Tbl.DELETE(j);
          /*
          BIS_UTILITIES_PUB.put_line(p_text =>'attribute, col: '
          ||l_object_attribute_tbl(l_object_attribute_tbl.COUNT).ATTRIBUTE_CODE
          ||', '
          ||l_object_attribute_tbl(l_object_attribute_tbl.COUNT).ATTRIBUTE2);
          */
        END IF;
        IF cr_attribute%ISOPEN THEN CLOSE cr_attribute; END IF;
      END IF;
    END LOOP;
  END LOOP;

  IF l_object_attribute_tbl.COUNT <> p_dim_level_value_Tbl.COUNT THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  x_object_attribute_tbl := l_object_attribute_tbl;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Get_Object_Attributes: '||sqlerrm);

END Get_Object_Attributes;

PROCEDURE Get_Obj_Attribute_Data_Source
( p_database_object         IN VARCHAR2
, p_object_attribute_tbl    IN object_attribute_tbl_type
, x_Measure_Inst_DB_Obj_tbl OUT NOCOPY Measure_Instance_DB_Obj_Tbl
, x_return_status           OUT NOCOPY VARCHAR2
)
IS

  l_Measure_Inst_DB_Obj_tbl Measure_Instance_DB_Obj_Tbl;
  l_object_attribute_name   VARCHAR2(32000) := BIS_UTILITIES_PUB.G_NULL_CHAR;
  l_count                   NUMBER := 0;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- pick out NOCOPY each dimension level attribute's database column;
  -- IF there IS > 1 database column for each dimension level item,
  -- THEN error;
  --
  FOR i IN 1..p_object_attribute_tbl.COUNT LOOP
    l_count := l_Measure_Inst_DB_Obj_tbl.COUNT+1;
    l_Measure_Inst_DB_Obj_tbl(l_count).region_code
      := p_object_attribute_tbl(i).region_code;
    l_Measure_Inst_DB_Obj_tbl(l_count).attribute_code
      := p_object_attribute_tbl(i).attribute_code;
    l_Measure_Inst_DB_Obj_tbl(l_count).Database_Object_name
      := p_database_object;
    l_Measure_Inst_DB_Obj_tbl(l_count).Database_Obj_Column_Name
      := p_object_attribute_tbl(i).attribute3;
    l_Measure_Inst_DB_Obj_tbl(l_count).Database_Obj_Column_Type
      := get_dim_level_short_name(p_object_attribute_tbl(i).attribute2);
    /*
    BIS_UTILITIES_PUB.put_line(p_text =>'col name: '
          ||l_Measure_Inst_DB_Obj_tbl(l_count).Database_Obj_Column_Name
          ||', col type: '
          ||l_Measure_Inst_DB_Obj_tbl(l_count).Database_Obj_Column_Type);
    */
  END LOOP;

  x_Measure_Inst_DB_Obj_tbl := l_Measure_Inst_DB_Obj_tbl;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Get_Obj_Attribute_Data_Source: '||sqlerrm);

END Get_Obj_Attribute_Data_Source;


PROCEDURE Get_dimension_level_value
( p_dim_level_value_Tbl        IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_dim_level_id               IN  VARCHAR2
, p_count                      IN  NUMBER
, x_dimension_level_value_id   OUT NOCOPY VARCHAR2
, x_dimension_level_value_NAME OUT NOCOPY VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
)
IS

  l_dim_level_value_id     VARCHAR2(80) := NULL;
  l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_dim_level_value_rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim_level_value_rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN 1..p_dim_level_value_Tbl.COUNT LOOP

---    IF p_dim_level_value_Tbl(i).Dimension_level_Id = p_dim_level_id THEN

       l_dim_level_value_id := p_dim_level_value_Tbl(p_count).dimension_level_value_id;
       l_dim_level_value_rec :=  p_dim_level_value_Tbl(p_count);

       l_dim_level_value_rec.Dimension_Level_ID := p_dim_level_id;

       l_dim_level_value_rec_p := l_dim_level_value_rec;
       BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_To_Value
       ( p_api_version          => 1.0
       , p_dim_level_value_rec  => l_dim_level_value_rec_p
       , x_dim_level_value_rec  => l_dim_level_value_rec
       , x_return_status        => x_return_status
       , x_error_tbl            => l_error_tbl
       );

       x_dimension_level_value_id := l_dim_level_value_id;
       x_dimension_level_value_NAME := l_dim_level_value_rec.dimension_level_value_name;

       return ;

 --   END IF;

  END LOOP;

  x_dimension_level_value_id := l_dim_level_value_id;
  x_dimension_level_value_NAME := l_dim_level_value_rec.dimension_level_value_name;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Get_dimension_level_value Function: '||sqlerrm);

END Get_dimension_level_value;


PROCEDURE Get_dimension_level_values
( p_dim_level_value_Tbl     IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_Measure_Inst_DB_Obj_tbl IN Measure_Instance_DB_Obj_Tbl
, x_Measure_Inst_DB_Obj_tbl OUT NOCOPY Measure_Instance_DB_Obj_Tbl
, x_return_status           OUT NOCOPY VARCHAR2
)
IS

  l_Measure_Inst_DB_Obj_tbl Measure_Instance_DB_Obj_Tbl ;
  l_dim_level_value_Tbl  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
  l_dimension_level_rec  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_dimension_level_rec_p BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_time_dimension_level_tbl BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type;
  l_time_dimension_Rec        BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_is_time BOOLEAN := FALSE;

BEGIN
--  BIS_UTILITIES_PUB.put_line(p_text =>'Getting dimension level values');
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_Measure_Inst_DB_Obj_tbl := p_Measure_Inst_DB_Obj_tbl ;
  l_dim_level_value_Tbl := p_dim_level_value_Tbl;
  FOR i IN 1..p_dim_level_value_Tbl.COUNT LOOP
    -- Need more fixes here with total time issue fix
    IF p_dim_level_value_Tbl(i).Dimension_Level_Id IS not NULL THEN
       l_time_Dimension_Rec.dimension_short_name := BIS_UTILITIES_PVT.Get_Time_Dimension_Name
                                                (p_DimLevelId => p_dim_level_value_Tbl(i).Dimension_Level_Id);
    END IF;
  END LOOP;

  BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Levels
  ( p_api_version         => 1.0
  , p_Dimension_Rec       => l_time_Dimension_rec
  , x_Dimension_Level_tbl => l_time_Dimension_Level_tbl
  , x_return_status       => x_return_status
  , x_error_Tbl           => l_error_tbl
  );

--  BIS_UTILITIES_PUB.put_line(p_text =>'Number of time levels retrieved: '||l_time_Dimension_Level_tbl.count);

  FOR i IN 1..l_dim_level_value_Tbl.COUNT LOOP
    IF (BIS_UTILITIES_PUB.Value_Missing
          (l_dim_level_value_Tbl(i).dimension_level_short_name)
          = FND_API.G_TRUE)
    OR (BIS_UTILITIES_PUB.Value_Null
          (l_dim_level_value_Tbl(i).dimension_level_short_name)
          = FND_API.G_TRUE)
    THEN
      l_Dimension_Level_Rec.Dimension_Level_id
        := l_dim_level_value_Tbl(i).Dimension_Level_id;

      BEGIN
        l_dimension_level_rec_p := l_Dimension_Level_Rec;
        BIS_DIMENSION_LEVEL_PVT.Retrieve_Dimension_Level
        ( p_api_version         => 1.0
        , p_Dimension_Level_Rec => l_dimension_level_rec_p
        , x_Dimension_Level_Rec => l_Dimension_Level_Rec
        , x_return_status       => x_return_status
        , x_error_Tbl           => l_error_tbl
        );
        l_dim_level_value_Tbl(i).Dimension_Level_short_name
          := l_Dimension_Level_Rec.Dimension_Level_short_name;
      EXCEPTION
        WHEN OTHERS THEN
        BIS_UTILITIES_PUB.put_line(p_text =>'Error IN retrieving dimension level');
        return;
      END;
    END IF;
  END LOOP;

  -- for each dimension level value
  --   find matching ak attribute (by dimension level short_name)
  --   put into db_obj_tbl.column_value
  --
  FOR i IN 1..l_dim_level_value_Tbl.COUNT LOOP
    FOR j IN 1..l_Measure_Inst_DB_Obj_tbl.COUNT LOOP
      IF l_Measure_Inst_DB_Obj_tbl(j).Database_Obj_Column_Type
         = l_dim_level_value_Tbl(i).dimension_level_short_name
      THEN

        -- pick out NOCOPY time levels since they're processed differently
        --
        FOR k IN 1..l_time_Dimension_Level_tbl.COUNT LOOP

          IF l_dim_level_value_Tbl(i).Dimension_level_short_name
             = l_time_Dimension_Level_tbl(k).Dimension_level_short_name
          THEN
             l_is_time := TRUE;
             exit;
          END IF;
        END LOOP;

        IF l_is_time THEN
          l_Measure_Inst_DB_Obj_tbl(j).Column_value
            := get_time_period_name
               (l_dim_level_value_Tbl(i).dimension_level_value_id);
--          BIS_UTILITIES_PUB.put_line(p_text =>'Time period column value: '
--          ||l_Measure_Inst_DB_Obj_tbl(j).Column_value);
        ELSE
          l_Measure_Inst_DB_Obj_tbl(j).Column_value
            := l_dim_level_value_Tbl(i).dimension_level_value_id;
        END IF;

      END IF;
    END LOOP;
  END LOOP;
  /*
  FOR i IN 1..l_Measure_Inst_DB_Obj_tbl.COUNT LOOP
    IF l_Measure_Inst_DB_Obj_tbl(i).Database_Obj_Column_Name IS NOT NULL
    AND l_Measure_Inst_DB_Obj_tbl(i).Database_Obj_Column_Type IS NOT NULL
    AND l_Measure_Inst_DB_Obj_tbl(i).Column_value IS NULL
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

--      BIS_UTILITIES_PUB.put_line(p_text =>'measure inst object clolum '
--           ||l_Measure_Inst_DB_Obj_tbl(i).Database_Obj_Column_Name
--           ||' missing column value.'
--           );

    END IF;

--    BIS_UTILITIES_PUB.put_line(p_text =>'col name: '
--    ||l_Measure_Inst_DB_Obj_tbl(i).Database_Obj_Column_Name
--    ||', col type: '
--    ||l_Measure_Inst_DB_Obj_tbl(i).Database_Obj_Column_Type
--    ||', col value: '
--    ||l_Measure_Inst_DB_Obj_tbl(i).Column_value
--    );

  END LOOP;
  */
  x_Measure_Inst_DB_Obj_tbl := l_Measure_Inst_DB_Obj_tbl;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Get_dimension_level_values: '||sqlerrm);

END Get_dimension_level_values;


PROCEDURE Build_Query_Statement
( p_Measure_Instance_Obj_tbl IN Measure_Instance_DB_Obj_Tbl
, p_measure_short_name       IN VARCHAR2
, p_compare_region_item   IN VARCHAR2
, p_compare_region_code   IN VARCHAR2
, x_select_clause            OUT NOCOPY VARCHAR2
, x_from_clause              OUT NOCOPY VARCHAR2
, x_where_clause             OUT NOCOPY VARCHAR2
, x_group_by_clause          OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
)
IS

  l_select_clause     VARCHAR2(32000);
  l_from_clause       VARCHAR2(32000);
  l_where_clause      VARCHAR2(32000);
  l_group_by_clause   VARCHAR2(32000);
  l_return_status     VARCHAR2(32000);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  Build_select_clause
  ( p_Measure_Instance_Obj_tbl => p_Measure_Instance_Obj_tbl
  , p_measure_short_name       => p_measure_short_name
  , p_compare_region_item      => p_compare_region_item
  , p_compare_region_code      => p_compare_region_code
  , x_select_clause            => l_select_clause
  , x_return_status            => l_return_status
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_select_clause := G_ERROR_CLAUSE;
  END IF;

  Build_from_clause
  ( p_Measure_Instance_Obj_tbl => p_Measure_Instance_Obj_tbl
  , x_from_clause              => l_from_clause
  , x_return_status            => l_return_status
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_from_clause := G_ERROR_CLAUSE;
  END IF;

  Build_where_clause
  ( p_Measure_Instance_Obj_tbl => p_Measure_Instance_Obj_tbl
  , p_measure_short_name       => p_measure_short_name
  , x_where_clause             => l_where_clause
  , x_return_status            => l_return_status
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_where_clause := G_ERROR_CLAUSE;
  END IF;

  Build_group_by_clause
  ( p_Measure_Instance_Obj_tbl => p_Measure_Instance_Obj_tbl
  , p_measure_short_name       => p_measure_short_name
  , x_group_by_clause          => l_group_by_clause
  , x_return_status            => l_return_status
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_group_by_clause := G_ERROR_CLAUSE;
  END IF;

  IF l_select_clause = G_ERROR_CLAUSE
  OR l_from_clause = G_ERROR_CLAUSE
  OR l_where_clause = G_ERROR_CLAUSE
  OR l_group_by_clause = G_ERROR_CLAUSE
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

   BIS_UTILITIES_PUB.put_line(p_text =>'select: '  ||l_select_clause);
   BIS_UTILITIES_PUB.put_line(p_text =>'from: '    ||l_from_clause);
   BIS_UTILITIES_PUB.put_line(p_text =>'where: '   ||l_where_clause);
   BIS_UTILITIES_PUB.put_line(p_text =>'group by: '||l_group_by_clause);

  x_select_clause    := l_select_clause;
  x_from_clause      := l_from_clause;
  x_where_clause     := l_where_clause;
  x_group_by_clause  := l_group_by_clause;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Build_Query_Statement: '||sqlerrm);

END Build_Query_Statement;

PROCEDURE Build_select_clause
( p_Measure_Instance_Obj_tbl IN Measure_Instance_DB_Obj_Tbl
, p_measure_short_name       IN VARCHAR2
, p_compare_region_item   IN VARCHAR2
, p_compare_region_code   IN VARCHAR2
, x_select_clause            OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
)
IS

 l_select_clause VARCHAR2(32000) := NULL;
 l_actual_clause VARCHAR2(32000) := NULL;
 l_compare_clause VARCHAR2(32000) := NULL;
 l_function VARCHAR2(32000) := NULL;

BEGIN

--  BIS_UTILITIES_PUB.put_line(p_text =>'Inside Select PROCEDURE ');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN 1..p_Measure_Instance_Obj_tbl.COUNT LOOP

   BIS_UTILITIES_PUB.put_line(p_text =>'Inside the For Loop ');

    l_function := Get_Aggregate_Function( p_Measure_Instance_Obj_tbl(i));

    IF p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_type
      = p_measure_short_name
    THEN
   BIS_UTILITIES_PUB.put_line(p_text =>'Inside the First IF');
      IF l_function IS NOT NULL THEN
        l_actual_clause := l_function||'( '
          ||p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_Name
          ||' ) ';
      ELSE
        l_actual_clause := ' distinct '
          ||p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_Name;
      END IF;

    END IF;

    IF p_Measure_Instance_Obj_tbl(i).Attribute_code
      = p_compare_region_item
    THEN
   BIS_UTILITIES_PUB.put_line(p_text =>'Inside the second IF');
      IF l_function IS NOT NULL THEN
        l_compare_clause
          := l_function||'( '
          ||p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_Name
          ||' ) ';
      ELSE
        l_compare_clause := p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_Name;
      END IF;

    END IF;


  END LOOP;

  l_select_clause := ' SELECT  '|| l_actual_clause;

  IF l_actual_clause IS not NULL AND l_compare_clause IS not NULL
  THEN

    l_select_clause :=  l_select_clause || ' , ' || l_compare_clause ;

  ELSIF l_actual_clause IS not NULL AND l_compare_clause IS NULL
  THEN
    l_select_clause :=  l_select_clause || ' , ' || 'NULL'  ;

  END IF;

  x_select_clause := l_select_clause;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Build_select_clause: '||sqlerrm);

END Build_select_clause;

PROCEDURE Build_from_clause
( p_Measure_Instance_Obj_tbl IN Measure_Instance_DB_Obj_Tbl
, x_from_clause              OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
)
IS

 l_from_clause VARCHAR2(32000) := NULL;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_Measure_Instance_Obj_tbl.COUNT > 0 THEN
    l_from_clause := ' FROM '
                  ||p_Measure_Instance_Obj_tbl(1).database_object_name;
  ELSE
    x_return_status := FND_API.G_RET_STS_ERROR ;
  END IF;

  x_from_clause := l_from_clause;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Build_from_clause: '||sqlerrm);

END Build_from_clause;

PROCEDURE Build_where_clause
( p_Measure_Instance_Obj_tbl IN Measure_Instance_DB_Obj_Tbl
, p_measure_short_name       IN VARCHAR2
, x_where_clause             OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
)
IS

 l_where_clause VARCHAR2(32000) := NULL;
 l_count NUMBER := 0;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- constraint on dimension level values only
  -- measure column has the actual value
  --
  FOR i IN 1..p_Measure_Instance_Obj_tbl.COUNT LOOP
    IF p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_Name IS NOT NULL
    AND p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_type
      <> p_measure_short_name
    THEN
      l_count := l_count + 1;
      IF l_count = 1 THEN
        l_where_clause
          := p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_Name
          ||' = '
          ||''''||p_Measure_Instance_Obj_tbl(i).Column_Value||'''';
      ELSE
        l_where_clause
          := l_where_clause||' AND '
          ||p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_Name
          ||' = '
          ||''''||p_Measure_Instance_Obj_tbl(i).Column_Value||'''';
      END IF;
    END IF;
  END LOOP;

  IF l_where_clause IS NOT NULL THEN
    l_where_clause := ' WHERE '||l_where_clause;
  END IF;

  BIS_UTILITIES_PUB.put_line(p_text =>'WHERE clause: '||l_where_clause);
  x_where_clause := l_where_clause;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Build_where_clause: '||sqlerrm);

END Build_where_clause;

PROCEDURE Build_group_by_clause
( p_Measure_Instance_Obj_tbl IN Measure_Instance_DB_Obj_Tbl
, p_measure_short_name       IN VARCHAR2
, x_group_by_clause          OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
)
IS

 l_group_by_clause VARCHAR2(32000) := NULL;
 l_count NUMBER := 0;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN 1..p_Measure_Instance_Obj_tbl.COUNT LOOP
    IF p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_Name IS NOT NULL
    AND p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_type
      <> p_measure_short_name
    THEN
      l_count := l_count + 1;
      IF l_count = 1 THEN
        l_group_by_clause
          := p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_Name;
      ELSE
        l_group_by_clause
          := l_group_by_clause
          ||', '
          ||p_Measure_Instance_Obj_tbl(i).Database_Obj_Column_Name;
      END IF;
    END IF;
  END LOOP;

  IF l_group_by_clause IS NOT NULL THEN
    l_group_by_clause := ' group by '||l_group_by_clause;
  END IF;

  x_group_by_clause := l_group_by_clause;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Build_group_by_clause: '||sqlerrm);

END Build_group_by_clause;

PROCEDURE Execute_Query
( p_select_clause            IN VARCHAR2
, p_from_clause              IN VARCHAR2
, p_where_clause             IN VARCHAR2
, p_group_by_clause          IN VARCHAR2
, x_Actual_value             OUT NOCOPY NUMBER
, x_compare_value             OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
)
IS

    l_stmt         VARCHAR2(32000);
    l_actual_value NUMBER;
    l_compare_value NUMBER;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_stmt := p_select_clause||' '||p_from_clause||' '|| p_where_clause||' '||p_group_by_clause;

  BIS_UTILITIES_PUB.put_line(p_text =>'sql statement: '||substr(l_stmt,0,200));
  BIS_UTILITIES_PUB.put_line(p_text =>substr(l_stmt,200,200));
  BIS_UTILITIES_PUB.put_line(p_text =>substr(l_stmt,400));

  BEGIN
    EXECUTE IMMEDIATE l_stmt INTO l_actual_value, l_compare_value;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_actual_value := NULL;
      l_compare_value := NULL;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      BIS_UTILITIES_PUB.put_line(p_text =>'error with exec statement: '||sqlerrm);
  END;

  x_actual_value := l_actual_value;
  x_compare_value := l_compare_value;

  BIS_UTILITIES_PUB.put_line(p_text =>'Actual value computed: '||l_actual_value);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Execute_Query: '||sqlerrm);

END Execute_Query;

PROCEDURE Save_Report_URL
( p_measure_instance        IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl     IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, P_TIME_PARAMETER          IN BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
, P_PARAMETER               IN BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
, p_view_by_level	    IN VARCHAR2
, p_time_level_id           IN NUMBER
, p_time_level_value_id     IN VARCHAR2
, x_Rpt_Link		        OUT NOCOPY VARCHAR2
, x_return_status         	OUT NOCOPY VARCHAR2
, x_error_msg		  	OUT NOCOPY VARCHAR2
)  is


  l_return_status       VARCHAR2(32000);
  l_error_Tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_target_rec          BIS_TARGET_PUB.Target_rec_type;
  l_dim_level_value_rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_target_level_rec    BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;
  l_measure_rec         BIS_MEASURE_PUB.Measure_Rec_Type;
  l_measure_rec_p       BIS_MEASURE_PUB.Measure_Rec_Type;
  sp                    VARCHAR2(32);
  l_link                VARCHAR2(32000);
  l_time_level_id    	NUMBER;
  l_time_level_short_name VARCHAR2(32000);
  l_time_level_name  	VARCHAR2(32000);
  l_time_level_value  	VARCHAR2(32000);
  l_FROM                VARCHAR2(32000);
  l_to                  VARCHAR2(32000);
  l_dim_level_value_tbl BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
  l_dimlevel_short_name VARCHAR2(32000);
  l_select_String       VARCHAR2(32000);
  l_table_name          VARCHAR2(32000);
  l_value_name          VARCHAR2(32000);
  l_description         VARCHAR2(32000);
  l_id_name             VARCHAR2(32000);
  l_level_name          VARCHAR2(32000);
  l_msg_Count           NUMBER;
  l_msg_data            VARCHAR2(32000);

  l_Parm1Level_short_name  VARCHAR2(240);
  l_Parm1Value_name        VARCHAR2(240);
  l_Parm2Level_short_name  VARCHAR2(240);
  l_Parm2Value_name        VARCHAR2(240);
  l_Parm3Level_short_name  VARCHAR2(240);
  l_Parm3Value_name        VARCHAR2(240);
  l_Parm4Level_short_name  VARCHAR2(240);
  l_Parm4Value_name        VARCHAR2(240);
  l_Parm5Level_short_name  VARCHAR2(240);
  l_Parm5Value_name        VARCHAR2(240);
  l_Parm6Level_short_name  VARCHAR2(240);
  l_Parm6Value_name        VARCHAR2(240);
  l_Parm7Level_short_name  VARCHAR2(240);
  l_Parm7Value_name        VARCHAR2(240);
  l_param_count            NUMBER;

  l_save_report_URL 	   EXCEPTION;

  l_Org_Level_Value_ID 	   VARCHAR2(40);-- := '204';
  l_Org_Level_Short_name   VARCHAR2(40);
  l_Dim_Level_Value_Rec_oltp BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dimension_level_number   NUMBER;

  -- 2841680
  l_report_region_code  ak_regions.region_code%TYPE;  -- l_actual_region_code  VARCHAR2(32000);
  l_rpt_params          fnd_form_functions_vl.parameters%TYPE;
  l_error_msg           VARCHAR2(1000);


BEGIN

--BIS_UTILITIES_PUB.put_line(p_text =>'In Save Reprot' );
  l_measure_rec.measure_id := p_measure_instance.measure_id;

  l_measure_rec_p := l_measure_rec;
  BIS_MEASURE_PUB.Retrieve_Measure
  (  p_api_version          => 1.0
   , p_measure_rec  	    => l_measure_rec_p
   , x_measure_rec          => l_measure_rec
   , x_return_status        => l_return_status
   , x_error_tbl            => l_error_tbl
   );

  -- 2841680
  -- l_actual_region_code := SUBSTR(l_measure_rec.Actual_Data_Source, 1, (INSTR(l_measure_rec.Actual_Data_Source,'.')-1));

  --BIS_UTILITIES_PUB.put_line(p_text =>'Time Level Id ' || p_time_level_id);

  BIS_PMF_DATA_SOURCE_PUB.Retrieve_Target
  ( p_measure_instance     => p_measure_instance
  , p_dim_level_value_tbl  => p_dim_level_value_tbl
  , x_target_rec           => l_target_rec
  );


  BIS_TARGET_PVT.Retrieve_Org_level_value
  ( p_api_version          => 1.0
  , p_Target_Rec           => l_target_rec
  , x_Dim_Level_value_Rec  => l_Dim_Level_value_Rec_oltp
  , x_dimension_level_number => l_dimension_level_number
  , x_return_status        => x_return_status
  , x_error_Tbl            => l_error_Tbl
  );

  l_Org_Level_Value_ID := l_Dim_Level_value_Rec_oltp.Dimension_Level_Value_ID;
  l_Org_Level_Short_name := l_Dim_Level_value_Rec_oltp.Dimension_Level_short_name;

  -- BIS_UTILITIES_PUB.put_line(p_text =>' Test Org level value id is: ' || l_Org_Level_Value_ID ) ;
  -- BIS_UTILITIES_PUB.put_line(p_text =>' Test Org level short name is: ' || l_Org_Level_Short_name ) ;

  --  l_target_level_rec.target_level_id := l_target_rec.target_level_id;
  --  l_target_level_rec.measure_id := l_measure_rec.measure_id;


  -- BIS_UTILITIES_PUB.put_line(p_text =>'Time Level Id ' || p_time_level_id);

  l_time_level_short_name   :=
         SUBSTR(P_TIME_PARAMETER.time_parameter_name,
                 (INSTR(P_TIME_PARAMETER.time_parameter_name,'+')+1));

  l_time_level_value := P_TIME_PARAMETER.time_from_value;

  -- BIS_UTILITIES_PUB.put_line(p_text =>'Time Level value ' || l_time_level_value);


  IF  p_time_level_id IS not NULL THEN

      Begin

         BIS_PMF_GET_DIMLEVELS_PVT.Get_Dimlevel_Values_Data
         ( p_bis_dimlevel_id          => p_time_level_id
         , x_dimlevel_short_name      => l_dimlevel_short_name
         , x_select_String            => l_select_String
         , x_table_name               => l_table_name
         , x_value_name               => l_value_name
         , x_id_name                  => l_id_name
         , x_level_name               => l_level_name
         , x_description              => l_description
         , x_return_Status            => l_return_Status
         , x_msg_Count                => l_msg_Count
         , x_msg_data                 => l_msg_data
         );

      EXCEPTION

           WHEN OTHERS THEN
           x_error_msg := ' Error IN PROCEDURE BIS_COMPUTED_ACTUAL_PVT.Save_Report_URL: 100: ' || sqlerrm;

      END;


      IF l_time_level_value = 'All'
      THEN

        l_FROM := 'All';
        l_to   := 'All';

      ELSE

        BEGIN

          l_FROM := BIS_UTILITIES_PVT.GET_TIME_FROM
               (p_duration       => -10
               ,p_table_name     => l_table_name
               ,p_time           => l_time_level_value
               ,p_id             => p_time_level_value_id
               ,p_id_col_name    => l_id_name
               ,p_value_col_name => l_value_name
	       ,p_Org_Level_ID   => l_Org_Level_Value_ID
               ,p_Org_Level_Short_name => l_Org_Level_Short_name
	       ,p_time_level_id  => p_time_level_id
	       ,p_time_level_sh_name =>  l_dimlevel_short_name
	       );

         EXCEPTION

           WHEN OTHERS THEN
             x_error_msg := ' Error IN PROCEDURE BIS_COMPUTED_ACTUAL_PVT.Save_Report_URL: 200: ' || sqlerrm;

         END;

         BEGIN

           l_to := BIS_UTILITIES_PVT.GET_TIME_TO
             (p_duration         => 2
             ,p_table_name       => l_table_name
             ,p_time             => l_time_level_value
             ,p_id               => p_time_level_value_id
             ,p_id_col_name      => l_id_name
             ,p_value_col_name   => l_value_name
	     ,p_Org_Level_ID     => l_Org_Level_Value_ID
             ,p_Org_Level_Short_name => l_Org_Level_Short_name
	     ,p_time_level_id    => p_time_level_id
             ,p_time_level_sh_name =>  l_dimlevel_short_name
             );

          EXCEPTION

           WHEN OTHERS THEN
             x_error_msg := ' Error IN PROCEDURE BIS_COMPUTED_ACTUAL_PVT.Save_Report_URL: 300: ' || sqlerrm;

        END;

      END IF;

  END IF;


  -- BIS_UTILITIES_PUB.put_line(p_text =>'Time To IF no error ' || l_to);

  IF P_PARAMETER.exists(1) THEN
  l_Parm1Level_short_name :=
         SUBSTR(P_PARAMETER(1).parameter_name,
                 (INSTR(P_PARAMETER(1).parameter_name,'+')+1));
  l_Parm1Value_name       :=  P_PARAMETER(1).parameter_value;
  END IF;


  IF P_PARAMETER.exists(2) THEN
  l_Parm2Level_short_name :=
         SUBSTR(P_PARAMETER(2).parameter_name,
                 (INSTR(P_PARAMETER(2).parameter_name,'+')+1));
  l_Parm2Value_name       :=  P_PARAMETER(2).parameter_value;
  END IF;


  IF P_PARAMETER.exists(3) THEN
  l_Parm3Level_short_name :=
         SUBSTR(P_PARAMETER(3).parameter_name,
                 (INSTR(P_PARAMETER(3).parameter_name,'+')+1));
  l_Parm3Value_name       :=  P_PARAMETER(3).parameter_value;
  END IF;


  IF P_PARAMETER.exists(4) THEN
  l_Parm4Level_short_name :=
         SUBSTR(P_PARAMETER(4).parameter_name,
                 (INSTR(P_PARAMETER(4).parameter_name,'+')+1));
  l_Parm4Value_name       :=  P_PARAMETER(4).parameter_value;
  END IF;


  IF P_PARAMETER.exists(5) THEN
  l_Parm5Level_short_name :=
         SUBSTR(P_PARAMETER(5).parameter_name,
                 (INSTR(P_PARAMETER(5).parameter_name,'+')+1));
  l_Parm5Value_name       :=  P_PARAMETER(5).parameter_value;
  END IF;


  IF P_PARAMETER.exists(6) THEN
  l_Parm6Level_short_name :=
         SUBSTR(P_PARAMETER(6).parameter_name,
                 (INSTR(P_PARAMETER(6).parameter_name,'+')+1));
  l_Parm6Value_name       :=  P_PARAMETER(6).parameter_value;
  END IF;

  IF P_PARAMETER.exists(7) THEN
  l_Parm7Level_short_name :=
         SUBSTR(P_PARAMETER(7).parameter_name,
                 (INSTR(P_PARAMETER(7).parameter_name,'+')+1));
  l_Parm7Value_name       :=  P_PARAMETER(7).parameter_value;
  END IF;


  BIS_COMPUTED_ACTUAL_PVT.get_Region_Using_Function -- 2841680
  ( p_Function_name           => l_measure_rec.Function_Name
  , x_Region_code             => l_report_region_code
  , x_return_status           => l_return_status
  , x_error_msg               => l_error_msg
  );


  print_report_url_params
  (  p_measure_id               => p_measure_instance.measure_id
  ,  p_bplan_name               => l_target_rec.plan_name
  ,  p_region_code              => l_report_region_code -- 2841680
  ,  p_function_name            => l_measure_rec.Function_Name
  ,  p_viewby_level_short_name  => p_view_by_level
  ,  p_Parm1Level_short_name    => l_Parm1Level_short_name
  ,  p_Parm1Value_name          => l_Parm1Value_name
  ,  p_Parm2Level_short_name    => l_Parm2Level_short_name
  ,  p_Parm2Value_name          => l_Parm2Value_name
  ,  p_Parm3Level_short_name    => l_Parm3Level_short_name
  ,  p_Parm3Value_name          => l_Parm3Value_name
  ,  p_Parm4Level_short_name    => l_Parm4Level_short_name
  ,  p_Parm4Value_name          => l_Parm4Value_name
  ,  p_Parm5Level_short_name    => l_Parm5Level_short_name
  ,  p_Parm5Value_name          => l_Parm5Value_name
  ,  p_Parm6Level_short_name    => l_Parm6Level_short_name
  ,  p_Parm6Value_name          => l_Parm6Value_name
  ,  p_Parm7Level_short_name    => l_Parm7Level_short_name
  ,  p_Parm7Value_name          => l_Parm7Value_name
  ,  p_TimeParmLevel_short_name => l_time_level_short_name
  ,  p_TimeFromParmValue_name   => l_FROM
  ,  p_TimeToParmValue_name     => l_to
  );


  l_link := BISVIEWER.GET_NOTIFY_RPT_URL
            (  p_measure_id               => p_measure_instance.measure_id
            ,  p_bplan_name               => l_target_rec.plan_name
            ,  p_region_code              => l_report_region_code -- 2841680
            ,  p_function_name            => l_measure_rec.Function_Name
            ,  p_viewby_level_short_name  => p_view_by_level
            ,  p_Parm1Level_short_name    => l_Parm1Level_short_name
            ,  p_Parm1Value_name          => l_Parm1Value_name
            ,  p_Parm2Level_short_name    => l_Parm2Level_short_name
            ,  p_Parm2Value_name          => l_Parm2Value_name
            ,  p_Parm3Level_short_name    => l_Parm3Level_short_name
            ,  p_Parm3Value_name          => l_Parm3Value_name
            ,  p_Parm4Level_short_name    => l_Parm4Level_short_name
            ,  p_Parm4Value_name          => l_Parm4Value_name
            ,  p_Parm5Level_short_name    => l_Parm5Level_short_name
            ,  p_Parm5Value_name          => l_Parm5Value_name
            ,  p_Parm6Level_short_name    => l_Parm6Level_short_name
            ,  p_Parm6Value_name          => l_Parm6Value_name
            ,  p_Parm7Level_short_name    => l_Parm7Level_short_name
            ,  p_Parm7Value_name          => l_Parm7Value_name
            ,  p_Parm8Level_short_name    => NULL
            ,  p_Parm8Value_name          => NULL
            ,  p_Parm9Level_short_name    => NULL
            ,  p_Parm9Value_name          => NULL
            ,  p_Parm10Level_short_name   => NULL
            ,  p_Parm10Value_name         => NULL
            ,  p_Parm11Level_short_name   => NULL
            ,  p_Parm11Value_name         => NULL
            ,  p_Parm12Level_short_name   => NULL
            ,  p_Parm12Value_name         => NULL
            ,  p_Parm13Level_short_name   => NULL
            ,  p_Parm13Value_name         => NULL
            ,  p_TimeParmLevel_short_name => l_time_level_short_name
            ,  p_TimeFromParmValue_name   => l_FROM
            ,  p_TimeToParmValue_name     => l_to
            );


  x_Rpt_Link := l_link;


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN  -- 2841680
    x_error_msg := ' There is no region code in the parameters for this function name '
                      || nvl ( l_measure_rec.Function_Name, 'Null')
                      || '. There will be no report in this notification. ';
    x_return_status:= FND_API.G_RET_STS_ERROR;
    BIS_UTILITIES_PUB.put_line(p_text => x_error_msg  ) ;

  WHEN OTHERS THEN
    NULL;

END Save_Report_URL;


PROCEDURE get_Region_Using_Function -- 2841680
( p_Function_name           IN VARCHAR2
, x_Region_code             OUT NOCOPY VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_error_msg               OUT NOCOPY VARCHAR2
) IS
  l_num1         NUMBER;
  l_num2         NUMBER;
  l_report_region_code ak_regions.region_code %TYPE;
  l_params fnd_form_functions.parameters%TYPE;
  l_web_html_call fnd_form_functions.web_html_call%TYPE;

BEGIN

  SELECT parameters, web_html_call
  INTO l_params, l_web_html_call
  FROM fnd_form_functions
  WHERE function_name = p_Function_name -- 'PMIUSGVR' -- 'BIS_FIIFANB1' -- 'BIS_FIIGLEPS' -- 'BIS_REOPENED_BUGS_SSWA' -- 'BIS_FIIARDSO'
      AND
  	 ( upper(parameters) like '%'||c_region_in_params||'%' OR
  	   upper(web_html_call) like c_region_in_webhtmlcall||'%');


  IF ( UPPER(l_params) like '%'||c_region_in_params||'%' ) THEN

	l_num1 := INSTR ( UPPER ( l_params ) , c_region_in_params )  + length ( c_region_in_params ) ;
	l_num2 := INSTR ( SUBSTR ( l_params , l_num1+1 ) , c_and ) ;

	IF ( l_num2 = 0 ) THEN
	  x_Region_code := SUBSTR ( l_params , l_num1 , LENGTH(l_params) ) ;
	ELSE
	  x_Region_code := SUBSTR ( l_params , l_num1 , l_num2 ) ;
	END IF;

	-- dbms_output.put_line ( 'Region code 1 is ' || nvl(l_report_region_code, 'XXX1')) ;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

  ELSIF (UPPER(l_web_html_call) LIKE c_region_in_webhtmlcall||'%' ) THEN

    l_num1 := INSTR(l_web_html_call, '''' , 1, 1);
    l_num2 := INSTR(l_web_html_call, '''' , 1, 2);
    -- dbms_output.put_line ( ' num 1 = ' || l_num1 || ' num 2 = ' || l_num2 ) ;

    x_Region_code := SUBSTR ( l_web_html_call , l_num1 + 1 , ( l_num2 - l_num1 -1 ) ) ;
    -- dbms_output.put_line ( 'Region code 2 is ' || nvl(l_report_region_code , 'XXX2') ) ;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  ELSE

    x_return_status := FND_API.G_RET_STS_ERROR ;
    x_error_msg := 'A region code is not defined for this form function.';
    -- dbms_output.put_line ( 'Region code 3 is ' || nvl(l_report_region_code , 'XXX3') ) ;

  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    x_error_msg := 'A region code is not defined for this form function.';
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_error_msg := 'Unknown error in get_Region_Using_Function.';
END;


FUNCTION  Get_Aggregate_Function
( p_Measure_Instance_Obj_rec IN Measure_Instance_DB_Obj_rec )
RETURN VARCHAR2
IS

  l_function VARCHAR2(32000) := NULL;

BEGIN

  SELECT ATTRIBUTE9 into l_function
  FROM ak_region_items
  WHERE region_code = p_Measure_Instance_Obj_rec.region_code
  AND ATTRIBUTE_CODE = p_Measure_Instance_Obj_rec.attribute_code;

  BIS_UTILITIES_PUB.put_line(p_text =>'Aggregate function used to compute actual: '||l_function);
  return l_function;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Get_Aggregate_Function: '||sqlerrm);
END;

PROCEDURE Form_Actual_Rec
( p_Measure_Instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_actual_value          IN NUMBER
, p_compare_value          IN NUMBER
, x_Actual_Rec            OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status         OUT NOCOPY VARCHAR2
)
IS

  l_Actual_Rec   BIS_ACTUAL_PUB.Actual_Rec_Type;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --BIS_UTILITIES_PUB.put_line(p_text =>'in form actual rec');

  BIS_PMF_DATA_SOURCE_PVT.Form_Actual_rec
  ( p_measure_instance      => p_measure_instance
  , p_dim_level_value_tbl   => p_dim_level_value_tbl
  , x_actual_rec            => l_Actual_Rec
  );
  l_actual_rec.Actual := p_actual_value;
  l_actual_rec.Comparison_actual_value := p_compare_value;

--  BIS_UTILITIES_PUB.put_line(p_text =>'Compare Value ' || l_actual_rec.Comparison_actual_value);

  x_actual_rec := l_actual_rec ;

  --BIS_UTILITIES_PUB.put_line(p_text =>'END form actual rec.');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN Form_Actual_Rec: '||sqlerrm);

END Form_Actual_Rec;

PROCEDURE Validate_Computed_Actual
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
  l_error_tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
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

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
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
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => x_error_Tbl
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
  END;
*/
/*
  --
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Org_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => x_error_Tbl
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
  END;
*/
  --
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Dim1_Level_Value_ID
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
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
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
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
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
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
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
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
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
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
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
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
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
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
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
  END;
  --
  BEGIN
    BIS_ACTUAL_VALIDATE_PVT.Validate_Record
    ( p_api_version     => p_api_version
    , p_Actual_Rec      => p_Actual_Rec
    , x_return_status   => l_return_status
    , x_error_Tbl       => l_error_Tbl
    );
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
      l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
  END;
  --
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    RAISE;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;

  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Computed_Actual;

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
  -- BIS_UTILITIES_PUB.put_line(p_text =>'In PVT Validate_Required_Fields');

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Validate_Required_Fields;

PROCEDURE Value_ID_Conversion
( p_api_version     IN  NUMBER
, p_Actual_Rec IN   BIS_ACTUAL_PUB.Actual_Rec_Type
, x_Actual_Rec OUT NOCOPY  BIS_ACTUAL_PUB.Actual_Rec_Type
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Dim_Level_Value_Rec  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_dim_level_value_rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Dim_Level_Value_Rec2 BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_Target_Level_Rec     BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_target_level_rec_p   BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Actual_Rec           BIS_ACTUAL_PUB.Actual_Rec_Type;
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
    /*
    BIS_UTILITIES_PUB.put_line(p_text =>'in actual api. TL is:  '
    ||l_actual_rec.Target_Level_id||' - '
    ||l_actual_rec.Target_Level_short_name||' - '
    ||l_actual_rec.Target_Level_name);
    */
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
    /*
    BIS_UTILITIES_PUB.put_line(p_text =>'in actual api. Retrived TL is:  '
    ||l_target_level_rec.Target_Level_id||' - '
    ||l_target_level_rec.Target_Level_short_name||' - '
    ||l_target_level_rec.Target_Level_name);

    l_Actual_rec.Target_Level_id := l_Target_Level_rec.Target_Level_id;
    l_Actual_rec.Target_Level_short_name
      := l_Target_Level_rec.Target_Level_short_name;
    l_Actual_rec.Target_Level_name := l_Target_Level_rec.Target_Level_name;
    */

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      NULL;
      -- BIS_UTILITIES_PUB.put_line(p_text =>'in actual api. EXEC ERROR');

    WHEN OTHERS THEN
      NULL;
      -- BIS_UTILITIES_PUB.put_line(p_text =>'in actual api. OTHER');

  END;
  ELSE
    l_target_level_rec.Target_Level_ID := l_actual_rec.Target_Level_ID;

  END IF;

  BEGIN
    l_target_level_rec_p := l_Target_Level_rec;
    BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version             => p_api_version
    , p_Target_Level_rec        => l_target_level_rec_p
    , p_all_info                => FND_API.G_FALSE
    , x_Target_Level_rec        => l_Target_Level_rec
    , x_return_status           => x_return_status
    , x_error_Tbl               => x_error_Tbl
    );
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      BIS_UTILITIES_PUB.put_line(p_text =>'in actual api. EXEC ERROR');

    WHEN OTHERS THEN
      BIS_UTILITIES_PUB.put_line(p_text =>'in actual api. OTHER');

  END;

/*
  -- Convert org_level_value
  --
  IF BIS_UTILITIES_PUB.Value_Missing(l_actual_rec.Org_level_value_ID)
     = FND_API.G_TRUE
  OR  BIS_UTILITIES_PUB.Value_Null(l_actual_rec.Org_level_value_ID)
     = FND_API.G_TRUE
  THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'in actual api. Org level missing ');

  BEGIN
    l_Dim_Level_Value_Rec2.Dimension_Level_ID
      := l_target_level_rec.org_level_id;
    l_Dim_Level_Value_Rec2.Dimension_Level_Value_Name
      := l_actual_rec.org_level_value_name;

      BIS_DIM_LEVEL_VALUE_PVT.Org_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_Rec2
      , x_dim_level_value_rec     => l_dim_level_value_Rec2
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Org_level_value_ID
      := l_dim_level_value_Rec2.dimension_level_value_id;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      NULL;
  END;
  ELSE
    l_Dim_Level_Value_Rec2.Dimension_Level_Value_id
      := l_actual_rec.org_level_value_id;

  END IF;

  -- Convert time_level_value
  --
  IF BIS_UTILITIES_PUB.Value_Missing(l_actual_rec.Time_Level_value_ID)
     = FND_API.G_TRUE
  OR  BIS_UTILITIES_PUB.Value_Null(l_actual_rec.Time_Level_value_ID)
     = FND_API.G_TRUE
  THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.time_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_Name
      := l_actual_rec.time_level_value_name;

      BIS_DIM_LEVEL_VALUE_PVT.Time_Value_To_ID
      ( p_api_version             => p_api_version
      , p_Org_Level_Value_Rec     => l_dim_level_value_Rec2
      , p_dim_level_value_rec     => l_dim_level_value_Rec
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Time_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        NULL;
    END;
  END IF;
*/

  -- Convert dim1_level_value
  --
  IF BIS_UTILITIES_PUB.Value_Missing(l_actual_rec.Dim1_Level_value_ID)
     = FND_API.G_TRUE
  OR  BIS_UTILITIES_PUB.Value_Null(l_actual_rec.Dim1_Level_value_ID)
     = FND_API.G_TRUE
  THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension1_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim1_level_value_name;

      l_dim_level_value_rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim1_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        NULL;
    END;
  END IF;

  -- Convert dim2_level_value
  --
  IF BIS_UTILITIES_PUB.Value_Missing(l_actual_rec.Dim2_Level_value_ID)
     = FND_API.G_TRUE
  OR  BIS_UTILITIES_PUB.Value_Null(l_actual_rec.Dim2_Level_value_ID)
     = FND_API.G_TRUE
  THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension2_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim2_level_value_name;

      l_dim_level_value_rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim2_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        NULL;
    END;
  END IF;

  -- Convert dim3_level_value
  --
  IF BIS_UTILITIES_PUB.Value_Missing(l_actual_rec.Dim3_Level_value_ID)
     = FND_API.G_TRUE
  OR  BIS_UTILITIES_PUB.Value_Null(l_actual_rec.Dim3_Level_value_ID)
     = FND_API.G_TRUE
  THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension3_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim3_level_value_name;

      l_dim_level_value_rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim3_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        NULL;
    END;
  END IF;

  -- Convert dim4_level_value
  --
  IF BIS_UTILITIES_PUB.Value_Missing(l_actual_rec.Dim4_Level_value_ID)
     = FND_API.G_TRUE
  OR  BIS_UTILITIES_PUB.Value_Null(l_actual_rec.Dim4_Level_value_ID)
     = FND_API.G_TRUE
  THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension4_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim4_level_value_name;

      l_dim_level_value_rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim4_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        NULL;
    END;
  END IF;

  -- Convert dim5_level_value
  --
  IF BIS_UTILITIES_PUB.Value_Missing(l_actual_rec.Dim5_Level_value_ID)
     = FND_API.G_TRUE
  OR  BIS_UTILITIES_PUB.Value_Null(l_actual_rec.Dim5_Level_value_ID)
     = FND_API.G_TRUE
  THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension5_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim5_level_value_name;

      l_dim_level_value_rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim5_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        NULL;
    END;
  END IF;

  -- Convert dim6_level_value
  --
  IF BIS_UTILITIES_PUB.Value_Missing(l_actual_rec.Dim6_Level_value_ID)
     = FND_API.G_TRUE
  OR  BIS_UTILITIES_PUB.Value_Null(l_actual_rec.Dim6_Level_value_ID)
     = FND_API.G_TRUE
  THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension6_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim6_level_value_name;

      l_dim_level_value_rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim6_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        NULL;
    END;
  END IF;

  -- Convert dim7_level_value
  --
  IF BIS_UTILITIES_PUB.Value_Missing(l_actual_rec.Dim7_Level_value_ID)
     = FND_API.G_TRUE
  OR  BIS_UTILITIES_PUB.Value_Null(l_actual_rec.Dim7_Level_value_ID)
     = FND_API.G_TRUE
  THEN
    BEGIN
    l_Dim_Level_Value_Rec.Dimension_Level_ID
      := l_target_level_rec.Dimension7_level_id;
    l_Dim_Level_Value_Rec.Dimension_Level_Value_name
      := l_actual_rec.Dim7_level_value_name;

      l_dim_level_value_rec_p := l_dim_level_value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_Value_To_ID
      ( p_api_version             => p_api_version
      , p_dim_level_value_rec     => l_dim_level_value_rec_p
      , x_dim_level_value_rec     => l_dim_level_value_Rec
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );

    l_actual_rec.Dim7_level_value_ID
      := l_dim_level_value_Rec.dimension_level_value_id;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        NULL;
    END;
  END IF;

/*
  -- Convert responsibility
  --
  IF BIS_UTILITIES_PUB.Value_Missing(l_actual_rec.Responsibility_ID)
     = FND_API.G_TRUE
  OR  BIS_UTILITIES_PUB.Value_Null(l_actual_rec.Responsibility_ID)
     = FND_API.G_TRUE
  THEN
    BEGIN
      BIS_Responsibility_PVT.Value_ID_Conversion
      ( p_api_version               => p_api_version
      , p_Responsibility_Short_Name => l_actual_rec.Responsibility_Short_Name
      , p_Responsibility_Name       => l_actual_rec.Responsibility_Name
      , x_Responsibility_ID         => l_actual_rec.Responsibility_id
      , x_return_status             => x_return_status
      , x_error_Tbl                 => x_error_Tbl
      );
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        NULL;
    END;
  END IF;
*/

  x_Actual_Rec     := l_Actual_Rec;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Value_ID_Conversion;

FUNCTION  get_dim_level_short_name(p_attribute IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  return substr(p_attribute, instr(p_attribute,'+') + 1) ;
END get_dim_level_short_name;

FUNCTION get_time_period_name(p_time_level_value_id IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  --BIS_UTILITIES_PUB.put_line(p_text =>'time_period: '||substr( p_time_level_value_id
  --    , instr(p_time_level_value_id,'+')+1)) ;

  return substr( p_time_level_value_id
               , instr(p_time_level_value_id,'+')+1) ;
END get_time_period_name;

FUNCTION IS_TIME_DIMENSION_LEVEL
( p_DimLevelId        IN NUMBER  := NULL
 ,p_DimShortName      OUT NOCOPY VARCHAR2
 ,p_DimLevelShortName OUT NOCOPY VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
)
RETURN BOOLEAN
IS
  CURSOR c_dim_id IS
  SELECT DIMENSION_SHORT_NAME, DIMENSION_LEVEL_SHORT_NAME
  FROM  bisfv_dimension_levels
  WHERE DIMENSION_LEVEL_ID = p_DimLevelId ;

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;


     OPEN c_dim_id;
     FETCH c_dim_id INTO p_DimShortName, p_DimLevelShortName;
     CLOSE c_dim_id;

     IF p_DimShortName IN ('EDW_TIME_M', 'TIME')
     THEN
       RETURN TRUE;
     ELSE
       RETURN FALSE;
     END IF;
 EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'Error IN IS_TIME_DIMENSION_LEVEL Function: '||sqlerrm);

END IS_TIME_DIMENSION_LEVEL;

--

PROCEDURE get_Parameters_For_Actual
( p_Target_Level_Rec     	IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
 ,p_dim_level_value_tbl		IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
 ,p_dimension_number		IN NUMBER
 ,p_count			IN NUMBER
 ,p_Actual_Rec           	IN BIS_ACTUAL_PUB.Actual_Rec_Type
 ,p_time_level_id 		IN NUMBER
 ,p_Time_Level_short_name  	IN VARCHAR
 ,p_Time_Level_value_id    	IN VARCHAR
 ,P_TIME_PARAMETER_REC_TYPE	IN BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
 ,P_PARAMETER_TBL_TYPE   	IN BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
 ,X_PARAMETER_TBL_TYPE   	IN OUT NOCOPY BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
 ,X_TIME_PARAMETER_REC_TYPE	IN OUT NOCOPY BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
 ,x_time_level_id 		IN OUT NOCOPY NUMBER
 ,x_Time_Level_short_name  	IN OUT NOCOPY VARCHAR
 ,x_Time_Level_value_id    	IN OUT NOCOPY VARCHAR
 ,x_Actual_Rec           	IN OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
 ,x_count			IN OUT NOCOPY NUMBER
 ,x_return_status     		OUT NOCOPY VARCHAR2
)  is

  l_dim_level_id 		NUMBER;
  l_PARAMETER_TBL_TYPE   	BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE;
  l_TIME_PARAMETER_REC_TYPE	BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE;
  l_time_level_id	 	NUMBER;			-- 2164190
  l_Time_Level_short_name 	VARCHAR2(30);		-- 2164190
  l_Time_Level_value_id  	VARCHAR2(80);		-- 2164190
  l_Actual_Rec           	BIS_ACTUAL_PUB.Actual_Rec_Type;
  l_count			NUMBER;
  l_DimLevelValueId      	VARCHAR2(32000);
  l_DimLevelValueName    	VARCHAR2(32000);
  l_Actual_DimLevelValueId      VARCHAR2(32000);
  l_Actual_DimLevelValueName    VARCHAR2(32000);
  l_is_time_level        	BOOLEAN := FALSE;
  l_is_total_level         	BOOLEAN := TRUE;
  l_DimShortName         	VARCHAR2(32000);
  l_DimLevelShortName    	VARCHAR2(32000);
  l_Is_Rolling_Period_Level	VARCHAR2(80);

BEGIN

  l_PARAMETER_TBL_TYPE   	:= p_PARAMETER_TBL_TYPE;
  l_Actual_Rec           	:= p_Actual_Rec;
  l_count			:= p_count;
  l_TIME_PARAMETER_REC_TYPE	:= P_TIME_PARAMETER_REC_TYPE;

  l_time_level_id 		:= p_time_level_id;
  l_Time_Level_short_name  	:= p_Time_Level_short_name;
  l_Time_Level_value_id    	:= p_Time_Level_value_id ;


  IF p_dimension_number = 1 THEN
     l_dim_level_id := p_target_level_rec.dimension1_level_id;
  ELSIF p_dimension_number = 2 THEN
     l_dim_level_id := p_target_level_rec.dimension2_level_id;
  ELSIF p_dimension_number = 3 THEN
     l_dim_level_id := p_target_level_rec.dimension3_level_id;
  ELSIF p_dimension_number = 4 THEN
     l_dim_level_id := p_target_level_rec.dimension4_level_id;
  ELSIF p_dimension_number = 5 THEN
     l_dim_level_id := p_target_level_rec.dimension5_level_id;
  ELSIF p_dimension_number = 6 THEN
     l_dim_level_id := p_target_level_rec.dimension6_level_id;
  ELSIF p_dimension_number = 7 THEN
     l_dim_level_id := p_target_level_rec.dimension7_level_id;
  ELSE
     BIS_UTILITIES_PUB.put_line(p_text => ' Error IN get_Parameters_For_Actual 0100 : Dim level NUMBER should be 1 to 7 ' );
  END IF;


  IF  l_dim_level_id IS not NULL THEN

    -- IS_TIME_DIMENSION_LEVEL check whether it IS time level
    -- also return dimension short name AND dimension level short name

     l_is_time_level :=  IS_TIME_DIMENSION_LEVEL
                         ( p_DimLevelId		=> l_dim_level_id
                          ,p_DimShortName 	=> l_DimShortName     -- out NOCOPY
                          ,p_DimLevelShortName	=> l_DimLevelShortName -- out NOCOPY
                          ,x_return_status	=> x_return_status
                          );

     Get_dimension_level_value
                          ( p_dim_level_value_Tbl 	=> p_dim_level_value_Tbl
                          , p_dim_level_id 		=> l_dim_level_id
                          , p_count        		=> p_dimension_number
                          , x_dimension_level_value_id 	=>  l_DimLevelValueId
                          , x_dimension_level_value_NAME => l_DimLevelValueName
                          , x_return_status 		=> x_return_status
                          );

     l_is_total_level := BIS_UTILITIES_PVT.IS_TOTAL_DIMLEVEL
                         (
                           l_DimLevelShortName,
                           x_return_status
                         );

     l_Is_Rolling_Period_Level := BIS_UTILITIES_PVT.Is_Rolling_Period_Level(  		-- 2408906
                                    p_level_short_name => l_DimLevelShortName );

     BIS_UTILITIES_PUB.put_line(p_text => ' dim short name = ' || l_DimShortName ) ;
     BIS_UTILITIES_PUB.put_line(p_text => ' l_Is_Rolling_Period_Level = ' || l_Is_Rolling_Period_Level ) ;	-- 2408906

     print_to_log_dim_level_info
     			( p_dim_level_id	=> l_dim_level_id,
			  p_dim_level_value_id	=> l_DimLevelValueId,
		          p_dim_level_number	=> p_dimension_number,
		          p_is_time_dim_level   => l_is_time_level,
		          p_is_total_dim_level  => l_is_total_level
		        );


    IF ( l_is_time_level = TRUE ) THEN
      l_time_level_id := l_dim_level_id;
      l_Time_Level_short_name  := l_DimLevelShortName;
      l_Time_Level_value_id    := l_DimLevelValueId;

      /*
        BIS_UTILITIES_PUB.put_line(p_text => ' l_time_level_id = ' || l_time_level_id );
        BIS_UTILITIES_PUB.put_line(p_text => ' l_Time_Level_short_name ' || l_Time_Level_short_name );
        BIS_UTILITIES_PUB.put_line(p_text => ' l_Time_Level_value_id ' || l_Time_Level_value_id );
      */

    END IF;


    IF l_is_total_level  = FALSE  THEN

       IF l_is_time_level  = TRUE THEN

          L_TIME_PARAMETER_REC_TYPE.time_parameter_name := l_DimShortName || '+' || l_DimLevelShortName;
          L_TIME_PARAMETER_REC_TYPE.time_from_value := l_DimLevelValueName;
          L_TIME_PARAMETER_REC_TYPE.time_to_value := l_DimLevelValueName;

       ELSE

          L_PARAMETER_TBL_TYPE(l_count).parameter_name  := l_DimShortName || '+' || l_DimLevelShortName;
          L_PARAMETER_TBL_TYPE(l_count).parameter_value := l_DimLevelValueName;
          l_count := l_count + 1;

       END IF;

    END IF;

    l_Actual_DimLevelValueID  := l_DimLevelValueId;
    l_Actual_DimLevelValueName  := l_DimLevelValueName;

  ELSE
    l_Actual_DimLevelValueId  := NULL;
    l_Actual_DimLevelValueName  := NULL;

  END IF;


  IF p_dimension_number = 1 THEN
     l_actual_rec.Dim1_Level_Value_ID := l_Actual_DimLevelValueId;
     l_actual_rec.Dim1_Level_Value_Name := l_Actual_DimLevelValueName;
  ELSIF p_dimension_number = 2 THEN
     l_actual_rec.Dim2_Level_Value_ID := l_Actual_DimLevelValueId;
     l_actual_rec.Dim2_Level_Value_Name := l_Actual_DimLevelValueName;
  ELSIF p_dimension_number = 3 THEN
     l_actual_rec.Dim3_Level_Value_ID := l_Actual_DimLevelValueId;
     l_actual_rec.Dim3_Level_Value_Name := l_Actual_DimLevelValueName;
  ELSIF p_dimension_number = 4 THEN
     l_actual_rec.Dim4_Level_Value_ID := l_Actual_DimLevelValueId;
     l_actual_rec.Dim4_Level_Value_Name := l_Actual_DimLevelValueName;
  ELSIF p_dimension_number = 5 THEN
     l_actual_rec.Dim5_Level_Value_ID := l_Actual_DimLevelValueId;
     l_actual_rec.Dim5_Level_Value_Name := l_Actual_DimLevelValueName;
  ELSIF p_dimension_number = 6 THEN
     l_actual_rec.Dim6_Level_Value_ID := l_Actual_DimLevelValueId;
     l_actual_rec.Dim6_Level_Value_Name := l_Actual_DimLevelValueName;
  ELSIF p_dimension_number = 7 THEN
     l_actual_rec.Dim7_Level_Value_ID := l_Actual_DimLevelValueId;
     l_actual_rec.Dim7_Level_Value_Name := l_Actual_DimLevelValueName;
  ELSE
     BIS_UTILITIES_PUB.put_line(p_text => ' Error IN get_Parameters_For_Actual 0200 : Dim level NUMBER should be 1 to 7 ' );
  END IF;


  x_PARAMETER_TBL_TYPE   	:= l_PARAMETER_TBL_TYPE;
  x_TIME_PARAMETER_REC_TYPE	:= l_TIME_PARAMETER_REC_TYPE;
  x_Actual_Rec           	:= l_Actual_Rec;
  x_count			:= l_count;
  x_time_level_id 		:= l_time_level_id;
  x_Time_Level_short_name  	:= l_Time_Level_short_name;
  x_Time_Level_value_id    	:= l_Time_Level_value_id;


EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text => ' EXCEPTION IN get_Parameters_For_Actual 1000 ' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;

END get_Parameters_For_Actual;

--

PROCEDURE print_Parameter_Table_Values
( P_PARAMETER_TBL_TYPE   	IN BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
 ,P_TIME_PARAMETER_REC_TYPE	IN BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
 ,p_view_by_lvl_sht_name	IN VARCHAR2
 ,p_actual_region_code		IN ak_regions.REGION_CODE%TYPE
 ,p_actual_region_item		IN ak_region_items.region_code%TYPE
 ,p_compare_region_item		IN ak_region_items.region_code%TYPE
 ,x_return_status     		OUT NOCOPY VARCHAR2
) is

  l_print_text       VARCHAR2(32000);

BEGIN

  BIS_UTILITIES_PUB.put_line(p_text => ' ........... START : Contents of parameters table ...........  ');
  BIS_UTILITIES_PUB.put_line(p_text =>' Contents of Parameter Table for calculating Actual');

  FOR i IN 1..P_PARAMETER_TBL_TYPE.COUNT LOOP

    l_print_text :=  ' Dimension ' || i ;

    IF P_PARAMETER_TBL_TYPE.exists(i) THEN
      l_print_text := l_print_text || ' Dim short name + Level short name = ' || p_PARAMETER_TBL_TYPE(i).parameter_name;
      l_print_text := l_print_text || ' , Level value = '  || p_PARAMETER_TBL_TYPE(i).parameter_value;
    ELSE
      l_print_text := l_print_text || ' is not used ' ;
    END IF;

    BIS_UTILITIES_PUB.put_line(p_text =>l_print_text);

  END LOOP;

  BIS_UTILITIES_PUB.put_line(p_text => ' ........... END : Contents of parameters table ...........  ');

  BIS_UTILITIES_PUB.put_line(p_text => ' ........... START : Contents of time parameter record ...........  ');

  BIS_UTILITIES_PUB.put_line(p_text =>' Contents of Time Parameter Record for calculating Actual');

  l_print_text := ' Time Dimension Value IS ';

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing
              (p_TIME_PARAMETER_REC_TYPE.time_parameter_name) = FND_API.G_TRUE)
                    AND (BIS_UTILITIES_PUB.Value_Not_Null
              (p_TIME_PARAMETER_REC_TYPE.time_parameter_name) = FND_API.G_TRUE))
  THEN
        l_print_text := l_print_text ||  p_TIME_PARAMETER_REC_TYPE.time_parameter_name;
  ELSE
        l_print_text := l_print_text ||   ' Time parameter value is null. ' ;
  END IF;


  IF ((BIS_UTILITIES_PUB.Value_Not_Missing
              (p_TIME_PARAMETER_REC_TYPE.time_from_value) = FND_API.G_TRUE)
                    AND (BIS_UTILITIES_PUB.Value_Not_Null
              (p_TIME_PARAMETER_REC_TYPE.time_from_value) = FND_API.G_TRUE))
  THEN
        l_print_text := l_print_text || ' , Time From = ' ||  p_TIME_PARAMETER_REC_TYPE.time_from_value;
  ELSE
        l_print_text := l_print_text ||   ' Time From value is null. ' ;
  END IF;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing
              (p_TIME_PARAMETER_REC_TYPE.time_to_value) = FND_API.G_TRUE)
                    AND (BIS_UTILITIES_PUB.Value_Not_Null
              (p_TIME_PARAMETER_REC_TYPE.time_to_value) = FND_API.G_TRUE))
  THEN
        l_print_text := l_print_text || ' , Time To = ' ||  p_TIME_PARAMETER_REC_TYPE.time_to_value;
  ELSE
        l_print_text := l_print_text ||   ' Time To value is null. ' ;
  END IF;

  BIS_UTILITIES_PUB.put_line(p_text =>l_print_text);

  BIS_UTILITIES_PUB.put_line(p_text => ' ........... END : Contents of time parameter record ...........  ');


  BIS_UTILITIES_PUB.put_line(p_text => ' ........... START : Report view by level ........... ' ) ;

  IF (     ( BIS_UTILITIES_PUB.Value_Not_Missing ( p_view_by_lvl_sht_name ) = FND_API.G_TRUE )
       AND ( BIS_UTILITIES_PUB.Value_Not_Null ( p_view_by_lvl_sht_name ) = FND_API.G_TRUE )
     ) THEN
        l_print_text := ' View by parameter is : ' ||  p_TIME_PARAMETER_REC_TYPE.time_to_value;
  ELSE
        l_print_text := ' View by parameter is null. ' ;
  END IF;

  BIS_UTILITIES_PUB.put_line(p_text => ' ........... END : Report view by level ........... ' ) ;


  BIS_UTILITIES_PUB.put_line(p_text =>' Region Code : ' || p_actual_region_code);
  BIS_UTILITIES_PUB.put_line(p_text =>' p_actual_attribute_code : ' || p_actual_region_item);
  BIS_UTILITIES_PUB.put_line(p_text =>' p_compareto_attribute_code : ' || p_compare_region_item);


EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text => ' EXCEPTION IN print_Parameter_Table_Values 1000 ' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;

END print_Parameter_Table_Values;

--

PROCEDURE  print_report_url_params
(  p_measure_id               IN NUMBER
,  p_bplan_name               IN VARCHAR
,  p_region_code              IN VARCHAR
,  p_function_name            IN VARCHAR
,  p_viewby_level_short_name  IN VARCHAR
,  p_Parm1Level_short_name    IN VARCHAR
,  p_Parm1Value_name          IN VARCHAR
,  p_Parm2Level_short_name    IN VARCHAR
,  p_Parm2Value_name          IN VARCHAR
,  p_Parm3Level_short_name    IN VARCHAR
,  p_Parm3Value_name          IN VARCHAR
,  p_Parm4Level_short_name    IN VARCHAR
,  p_Parm4Value_name          IN VARCHAR
,  p_Parm5Level_short_name    IN VARCHAR
,  p_Parm5Value_name          IN VARCHAR
,  p_Parm6Level_short_name    IN VARCHAR
,  p_Parm6Value_name          IN VARCHAR
,  p_Parm7Level_short_name    IN VARCHAR
,  p_Parm7Value_name          IN VARCHAR
,  p_TimeParmLevel_short_name IN VARCHAR
,  p_TimeFromParmValue_name   IN VARCHAR
,  p_TimeToParmValue_name     IN VARCHAR
) IS

BEGIN

  BIS_UTILITIES_PUB.put_line(p_text => ' ........... START : Parameters for get report url ........... ' ) ;

  BIS_UTILITIES_PUB.put_line(p_text => ' Measure id : ' || p_measure_id ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Business plan name: ' || p_bplan_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Region code : ' || p_region_code ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Function code : ' || p_function_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' View by level short name : ' || p_viewby_level_short_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 1 Level short name : ' || p_Parm1Level_short_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 1 Level value name : ' || p_Parm1Value_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 2 Level short name : ' || p_Parm2Level_short_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 2 Level value name : ' || p_Parm2Value_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 3 Level short name : ' || p_Parm3Level_short_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 3 Level value name : ' || p_Parm3Value_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 4 Level short name : ' || p_Parm4Level_short_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 4 Level value name : ' || p_Parm4Value_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 5 Level short name : ' || p_Parm5Level_short_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 5 Level value name : ' || p_Parm5Value_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 6 Level short name : ' || p_Parm6Level_short_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 6 Level value name : ' || p_Parm6Value_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 7 Level short name : ' || p_Parm7Level_short_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Parameter 7 Level value name : ' || p_Parm7Value_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Time level short name : ' || p_TimeParmLevel_short_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Time from value name : ' || p_TimeFromParmValue_name ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Time to value name : ' || p_TimeToParmValue_name ) ;


  BIS_UTILITIES_PUB.put_line(p_text => ' ........... END : Parameters for get report url ........... ' ) ;

EXCEPTION

  WHEN OTHERS THEN

    BIS_UTILITIES_PUB.put_line(p_text => ' Error in printing report URL: ' || sqlerrm ) ;

END print_report_url_params;

----------

PROCEDURE print_to_log_dim_level_info
( p_dim_level_id	IN VARCHAR2,
  p_dim_level_value_id	IN VARCHAR2,
  p_dim_level_number	IN NUMBER,
  p_is_time_dim_level	IN BOOLEAN,
  p_is_total_dim_level	IN BOOLEAN
)
is

  l_text VARCHAR2(3000);

BEGIN

     l_text := ' i = ' || p_dim_level_number;

     IF (
          bis_utilities_pvt.value_not_null ( p_dim_level_id ) = FND_API.G_TRUE AND
          bis_utilities_pvt.value_not_missing ( p_dim_level_id ) = FND_API.G_TRUE
        ) THEN
            l_text := l_text || ' Level id = ' || p_dim_level_id ;
     ELSE
         l_text := l_text || ' Level id IS NULL/missing ' ;
     END IF;


     IF (
          bis_utilities_pvt.value_not_null ( p_dim_level_value_id ) = FND_API.G_TRUE AND
          bis_utilities_pvt.value_not_missing ( p_dim_level_value_id ) = FND_API.G_TRUE
        ) THEN
            l_text := l_text || ' , Level value ID = ' || p_dim_level_value_id ;
     ELSE
         l_text := l_text || ' , Dimension ' || p_dim_level_number || ' Level value id IS NULL/missing ' ;
     END IF;


     IF ( p_is_time_dim_level = TRUE ) THEN
       l_text := l_text || ' , Is Time dimension ' ;
     ELSE
       l_text := l_text || ' , Is NOT Time dimension ' ;
     END IF;


     IF ( p_is_total_dim_level = TRUE ) THEN
       l_text := l_text || ' , Is Total dimension ' ;
     ELSE
       l_text := l_text || ' , Is NOT Total dimension ' ;
     END IF;


     BIS_UTILITIES_PUB.put_line(p_text => l_text ) ;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text => ' EXCEPTION IN print_to_log_dim_level_info ' );
END print_to_log_dim_level_info;

--

END BIS_COMPUTED_ACTUAL_PVT;

/
