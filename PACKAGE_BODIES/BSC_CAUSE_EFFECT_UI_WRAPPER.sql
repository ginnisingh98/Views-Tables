--------------------------------------------------------
--  DDL for Package Body BSC_CAUSE_EFFECT_UI_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_CAUSE_EFFECT_UI_WRAPPER" AS
/* $Header: BSCCAEWB.pls 115.11 2003/02/12 14:25:34 adrao ship $ */

G_PKG_NAME				varchar2(30) := 'BSC_CAUSE_EFFECT_UI_WRAPPER';

G_REPORT_NOT_DEFINED			varchar2(30) := 'REPORT_NOT_DEFINED';
G_USER_NOT_AUTHORIZED_REPORT		varchar2(30) := 'USER_NOT_AUTHORIZED_REPORT';
G_REPORT_LINK_DISABLED			varchar2(30) := 'REPORT_LINK_DISABLED';


/************************************************************************************
************************************************************************************/

PROCEDURE Apply_Cause_Effect_Rels(
  p_indicator		IN	NUMBER
 ,p_level		IN	VARCHAR2
 ,p_causes_lst		IN	VARCHAR2
 ,p_effects_lst		IN	VARCHAR2
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS

    l_Bsc_Cause_Effect_Rel_Rec	BSC_CAUSE_EFFECT_REL_PUB.Bsc_Cause_Effect_Rel_Rec;
    l_commit			VARCHAR2(10);

    l_causes_lst	VARCHAR2(32700);
    l_causes		t_array_of_varchar2;
    l_num_causes	NUMBER;

    l_effects_lst	VARCHAR2(32700);
    l_effects		t_array_of_varchar2;
    l_num_effects	NUMBER;

    l_invalid_indicators	VARCHAR2(32700);
    l_i				NUMBER;

    l_cause_indicator		NUMBER;
    l_effect_indicator		NUMBER;

BEGIN

  FND_MSG_PUB.Initialize;

  -- Get and array with the causes

  l_num_causes := 0;
  IF p_causes_lst IS NOT NULL THEN
      l_causes_lst := p_causes_lst;

      -- take off the trailing ;
      IF SUBSTR(l_causes_lst, -1, 1) = ';' THEN
          l_causes_lst := SUBSTR(l_causes_lst, 1, LENGTH(l_causes_lst)-1);
      END IF;

      l_num_causes := Decompose_Varchar2_List(l_causes_lst, l_causes, ';');
  END IF;


  -- Get and array with the effects
  l_num_effects := 0;
  IF p_effects_lst IS NOT NULL THEN
      l_effects_lst := p_effects_lst;

      -- take off the trailing ;
      IF SUBSTR(l_effects_lst, -1, 1) = ';' THEN
          l_effects_lst := SUBSTR(l_effects_lst, 1, LENGTH(l_effects_lst)-1);
      END IF;

      l_num_effects := Decompose_Varchar2_List(l_effects_lst, l_effects, ';');
  END IF;


  -- Import PMF measures into datasets if they do not exists
  IF p_level = 'DATASET' THEN
      FOR l_i IN 1..l_num_causes LOOP
          IF NOT Exists_Measure_Dataset(l_causes(l_i)) THEN
              BSC_PMF_UI_WRAPPER.Create_Measure(
                  p_short_name  =>  l_causes(l_i)
                 ,x_return_status => x_return_status
                 ,x_msg_count => x_msg_count
                 ,x_msg_data => x_msg_data);
          END IF;
      END LOOP;

      FOR l_i IN 1..l_num_effects LOOP
          IF NOT Exists_Measure_Dataset(l_effects(l_i)) THEN
              BSC_PMF_UI_WRAPPER.Create_Measure(
                  p_short_name  =>  l_effects(l_i)
                 ,x_return_status => x_return_status
                 ,x_msg_count => x_msg_count
                 ,x_msg_data => x_msg_data);
          END IF;
      END LOOP;
  END IF;


  -- Validate that there are no indicators used as cause and effect at the same time
  l_invalid_indicators := NULL;
  FOR l_i IN 1..l_num_effects LOOP
      IF  Item_Belong_To_Array_Varchar2(l_effects(l_i), l_causes, l_num_causes) THEN
          IF l_invalid_indicators IS NOT NULL THEN
              l_invalid_indicators := l_invalid_indicators||', ';
          END IF;
          l_invalid_indicators := l_invalid_indicators||Get_Indicator_Name(l_effects(l_i), p_level);
      END IF;
  END LOOP;


  IF l_invalid_indicators IS NOT NULL THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_CAE_USED_AT_SAME_TIME');
      FND_MESSAGE.SET_TOKEN('LIST', l_invalid_indicators);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Delete existing cause and effect relations for this indicator
  l_commit := FND_API.G_FALSE;
  BSC_CAUSE_EFFECT_REL_PUB.Delete_All_Cause_Effect_Rels(l_commit
                               ,p_indicator
                               ,p_level
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);


  -- Save causes
  FOR l_i IN 1..l_num_causes LOOP
      IF p_level = 'DATASET' THEN
          l_cause_indicator := Get_Dataset_Id(l_causes(l_i));
      ELSE
          l_cause_indicator := TO_NUMBER(l_causes(l_i));
      END IF;

      l_Bsc_Cause_Effect_Rel_Rec.Cause_Indicator := l_cause_indicator;
      l_Bsc_Cause_Effect_Rel_Rec.Cause_Level := p_level;
      l_Bsc_Cause_Effect_Rel_Rec.Effect_Indicator := p_indicator;
      l_Bsc_Cause_Effect_Rel_Rec.Effect_Level := p_level;

      BSC_CAUSE_EFFECT_REL_PUB.Create_Cause_Effect_Rel(l_commit
                               ,l_Bsc_Cause_Effect_Rel_Rec
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);
  END LOOP;


  --Save effects
  FOR l_i IN 1..l_num_effects LOOP
      IF p_level = 'DATASET' THEN
          l_effect_indicator := Get_Dataset_Id(l_effects(l_i));
      ELSE
          l_effect_indicator := TO_NUMBER(l_effects(l_i));
      END IF;

      l_Bsc_Cause_Effect_Rel_Rec.Cause_Indicator := p_indicator;
      l_Bsc_Cause_Effect_Rel_Rec.Cause_Level := p_level;
      l_Bsc_Cause_Effect_Rel_Rec.Effect_Indicator := l_effect_indicator;
      l_Bsc_Cause_Effect_Rel_Rec.Effect_Level := p_level;

      BSC_CAUSE_EFFECT_REL_PUB.Create_Cause_Effect_Rel(l_commit
                               ,l_Bsc_Cause_Effect_Rel_Rec
                               ,x_return_status
                               ,x_msg_count
                               ,x_msg_data);
  END LOOP;


  COMMIT;


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

END Apply_Cause_Effect_Rels;

/************************************************************************************
************************************************************************************/

FUNCTION Exists_Measure_Dataset(
	p_measure_short_name IN VARCHAR2
	) RETURN BOOLEAN IS
    l_count NUMBER := 0;
BEGIN
    SELECT count(*)
    INTO l_count
    FROM bsc_sys_datasets_b
    WHERE measure_id1 = (
       SELECT measure_id
       FROM bsc_sys_measures
       WHERE short_name = p_measure_short_name);

    IF l_count > 0 THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Exists_Measure_Dataset;

/************************************************************************************
************************************************************************************/

FUNCTION Get_Dataset_Id(
	p_measure_short_name IN VARCHAR2
	) RETURN NUMBER IS
    l_dataset_id NUMBER;
BEGIN
    SELECT dataset_id INTO l_dataset_id
    FROM bsc_sys_datasets_b
    WHERE measure_id1 = (
        SELECT measure_id
        FROM bsc_sys_measures
        WHERE short_name = p_measure_short_name);

    RETURN l_dataset_id;
END Get_Dataset_Id;

/************************************************************************************
************************************************************************************/

FUNCTION Decompose_Numeric_List(
	x_string IN VARCHAR2,
	x_number_array IN OUT NOCOPY t_array_of_number,
        x_separator IN VARCHAR2
	) RETURN NUMBER IS

    h_num_items NUMBER := 0;

    h_sub_string VARCHAR2(32700);
    h_position NUMBER;

BEGIN

    IF x_string IS NOT NULL THEN
        h_sub_string := x_string;
        h_position := INSTR(h_sub_string, x_separator);

        WHILE h_position <> 0 LOOP
            h_num_items := h_num_items + 1;
            x_number_array(h_num_items) := TO_NUMBER(RTRIM(LTRIM(SUBSTR(h_sub_string, 1, h_position - 1))));

            h_sub_string := SUBSTR(h_sub_string, h_position + 1);
            h_position := INSTR(h_sub_string, x_separator);
        END LOOP;

        h_num_items := h_num_items + 1;
        x_number_array(h_num_items) := TO_NUMBER(RTRIM(LTRIM(h_sub_string)));

    END IF;

    RETURN h_num_items;

END Decompose_Numeric_List;

/************************************************************************************
************************************************************************************/

FUNCTION Decompose_Varchar2_List(
	x_string IN VARCHAR2,
	x_array IN OUT NOCOPY t_array_of_varchar2,
        x_separator IN VARCHAR2
	) RETURN NUMBER IS

    h_num_items NUMBER := 0;

    h_sub_string VARCHAR2(32700);
    h_position NUMBER;

BEGIN

    IF x_string IS NOT NULL THEN
        h_sub_string := x_string;
        h_position := INSTR(h_sub_string, x_separator);

        WHILE h_position <> 0 LOOP
            h_num_items := h_num_items + 1;
            x_array(h_num_items) := RTRIM(LTRIM(SUBSTR(h_sub_string, 1, h_position - 1)));

            h_sub_string := SUBSTR(h_sub_string, h_position + 1);
            h_position := INSTR(h_sub_string, x_separator);
        END LOOP;

        h_num_items := h_num_items + 1;
        x_array(h_num_items) := RTRIM(LTRIM(h_sub_string));

    END IF;

    RETURN h_num_items;

END Decompose_Varchar2_List;

/************************************************************************************
************************************************************************************/

FUNCTION Item_Belong_To_Array_Number(
	x_item IN NUMBER,
	x_array IN t_array_of_number,
	x_num_items IN NUMBER
	) RETURN BOOLEAN IS

    h_i NUMBER;

BEGIN
    FOR h_i IN 1 .. x_num_items LOOP
        IF x_array(h_i) = x_item THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE;

END Item_Belong_To_Array_Number;

/************************************************************************************
************************************************************************************/

FUNCTION Item_Belong_To_Array_Varchar2(
	x_item IN VARCHAR2,
	x_array IN t_array_of_varchar2,
	x_num_items IN NUMBER
	) RETURN BOOLEAN IS

    h_i NUMBER;

BEGIN
    FOR h_i IN 1 .. x_num_items LOOP
        IF x_array(h_i) = x_item THEN
            RETURN TRUE;
        END IF;
    END LOOP;

    RETURN FALSE;

END Item_Belong_To_Array_Varchar2;

/************************************************************************************
************************************************************************************/

FUNCTION Get_Indicator_Name(
	p_indicator 	IN VARCHAR2,
	p_level		IN VARCHAR2
) RETURN VARCHAR2 IS

    l_sql	VARCHAR2(32000);
    TYPE CursorType IS REF CURSOR;
    l_cursor	CursorType;
    l_name 	VARCHAR2(200);

BEGIN
   l_name := NULL;

   IF p_level = 'KPI' THEN
       l_sql := 'SELECT name FROM bsc_kpis_vl WHERE indicator = :i';
   ELSE
       l_sql := 'SELECT name FROM bsc_sys_datasets_vl'||
                ' WHERE measure_id1 = (SELECT measure_id FROM bsc_sys_measures'||
                ' WHERE short_name = :i)';
   END IF;

   OPEN l_cursor FOR l_sql USING p_indicator;
   FETCH l_cursor INTO l_name;
   CLOSE l_cursor;

   RETURN l_name;

END Get_Indicator_Name;

/************************************************************************************
************************************************************************************/

PROCEDURE Get_Indicator_Link(
  p_user_id		IN 	NUMBER
 ,p_indicator		IN	NUMBER
 ,p_level		IN	VARCHAR2
 ,p_page_id		IN	VARCHAR2 DEFAULT NULL
 ,p_page_dim_params	IN	VARCHAR2 DEFAULT NULL
 ,p_page_time_param	IN	VARCHAR2 DEFAULT NULL
 ,p_view_by_param	IN	VARCHAR2 DEFAULT NULL
 ,x_indicator_link	OUT NOCOPY	VARCHAR2
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS

  l_measure_short_name 		VARCHAR2(30);

  l_measure_rec     	BIS_MEASURE_PUB.Measure_rec_type;
  x_measure_rec     	BIS_MEASURE_PUB.Measure_rec_type;
  l_region_code		VARCHAR2(240);
  l_function_name	VARCHAR2(240);

  l_page_time_param 	time_parameter_rec_type;
  l_page_dim_params	dim_parameter_tbl_type;

  l_error_tbl		BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_sql			VARCHAR2(32000);
  TYPE CursorType IS REF CURSOR;
  l_cursor		CursorType;

  l_function_url_param	VARCHAR2(32000);
  l_dim_url_params	VARCHAR2(32000);
  l_time_url_param	VARCHAR2(32000);
  l_viewby_url_param	VARCHAR2(32000);
  l_position		NUMBER;
  l_rep_dim		VARCHAR2(32000);
  l_rep_dimension	VARCHAR2(32000);
  l_rep_dimension_level	VARCHAR2(32000);
  l_index		NUMBER;
  l_ranking_parameter   VARCHAR2(32000);

BEGIN

  FND_MSG_PUB.Initialize;

  x_indicator_link := NULL;

  IF p_level = 'DATASET' THEN
      -- For now we suppose that id the measure is at dataset level, it is a PMF measure

      -- Get measure short name
      SELECT short_name INTO l_measure_short_name
      FROM bsc_sys_measures
      WHERE measure_id = (SELECT measure_id1 FROM bsc_sys_datasets_b WHERE dataset_id = p_indicator);

      -- Get the function name and region of the report of the measure
      l_measure_rec.Measure_Short_Name := l_measure_short_name;
      BIS_MEASURE_PUB.Retrieve_Measure(
          p_api_version   => 1.0
          , p_Measure_Rec   => l_measure_rec
          , p_all_info      => fnd_api.G_TRUE
          , x_Measure_Rec   => x_measure_rec
          , x_return_status => x_return_status
          , x_error_Tbl     => l_error_tbl);

      IF (NVL(x_measure_rec.Enable_Link, 'N') <> 'Y') THEN
          -- Link is disbled
          x_indicator_link := G_REPORT_LINK_DISABLED;
          RETURN;
      END IF;


      l_function_name := x_measure_rec.Function_Name;
      l_region_code := SUBSTR(x_measure_rec.Actual_Data_Source,1, (INSTR(x_measure_rec.Actual_Data_Source,'.',1,1)-1));

      IF l_function_name IS NULL THEN
          -- We need the function name to get the link of the measure
          x_indicator_link := G_REPORT_NOT_DEFINED;
          RETURN;
      END IF;

      -- Validate user has access to the report
      -- NOTE: There was an enhancement to PMV for this but they said that we need
      -- to code it because the only think we need to check is if the user has access to the function
      -- (fnd apis)
      --IF NOT BIS_GRAPH_REGION_HTML_FORMS.hasFunctionAccess(TO_CHAR(p_user_id), l_function_name) THEN
      IF NOT has_Function_Access(p_user_id, l_function_name) THEN
          x_indicator_link := G_USER_NOT_AUTHORIZED_REPORT;
          RETURN;
      END IF;

      IF p_page_id IS NOT NULL THEN
          -- If the page id is passed we used it and let the PMV api to handle the dimension parameters and
          -- time parameter
          l_time_url_param := NULL;
          l_dim_url_params := NULL;
      ELSE
          -- We set the report URL with the given dimension levels values

          -- Decompose page dimension parameters and time parameter
          Decompose_Page_Parameters(
              p_page_dim_params => p_page_dim_params
              , p_page_time_param => p_page_time_param
              , x_page_dim_parameters => l_page_dim_params
              , x_page_time_param => l_page_time_param);

          -- Get the dimension and dimension levels used in the report
          -- NOTE: There was an enhancement request to PMV for this. We were validating
          -- to set only the parameters that applies to the report, but they did not
          -- gave the API. So, We will pass all the dimension level parameters
          -- and hope that the PMV API handle the levels that does not apply to the report.
          -- (See previous version code to know how it was working)
          l_time_url_param := NULL;
          l_dim_url_params := NULL;


          IF p_page_time_param IS NOT NULL THEN
              l_time_url_param := l_page_time_param.dimension||'+'||
                                  l_page_time_param.dimension_level||'_FROM='||l_page_time_param.time_from||'&'||
                                  l_page_time_param.dimension||'+'||
                                  l_page_time_param.dimension_level||'_TO='||l_page_time_param.time_to;
          END IF;

          IF p_page_dim_params IS NOT NULL THEN
              FOR l_index IN 1..l_page_dim_params.COUNT LOOP
                  IF l_dim_url_params IS NOT NULL THEN
                      l_dim_url_params := l_dim_url_params||'&';
                  END IF;
                  l_dim_url_params := l_dim_url_params||l_page_dim_params(l_index).dimension||'+'||
                                      l_page_dim_params(l_index).dimension_level||'='||
                                      l_page_dim_params(l_index).dimension_level_value;
              END LOOP;
          END IF;
      END IF;

      -- Get possible dimension level used for view by in the report
      -- NOTE: There was a enhancement request to PMV for this. It was to validate that the view by
      -- parameter applis to the report. Because they are not giving the API we just pass the view by
      -- and hope that the report handle the situation when the view by is invalid.
      l_viewby_url_param := NULL;
      IF p_view_by_param IS NOT NULL THEN
          l_viewby_url_param := 'VIEW_BY='||p_view_by_param;
      ELSE
          IF p_page_id IS NOT NULL THEN
              -- Get the ranking parameter of the page
              BSC_PORTLET_UI_WRAPPER.Get_Ranking_Parameter(
                  p_page_id => p_page_id
                  ,p_user_id => p_user_id
                  ,x_ranking_param => l_ranking_parameter
                  ,x_return_status => x_return_status
                  ,x_msg_count => x_msg_count
                  ,x_msg_data => x_msg_data);

              IF l_ranking_parameter IS NOT NULL THEN
                  l_viewby_url_param := 'VIEW_BY='||l_ranking_parameter;
              END IF;
          END IF;

          IF l_viewby_url_param IS NULL THEN
              -- No view by was provided as parameter,
              -- No page id (no portlet context) or no ranking parameter
              -- We need to pass a view by. It will pass the first possible 'view by' of the report

              l_sql := 'SELECT attribute2'||
                       ' FROM ak_region_items'||
                       ' WHERE region_code = :1'||
                       ' AND attribute1 IN (''DIMENSION LEVEL'', ''DIM LEVEL SINGLE VALUE'','||
                       ' ''VIEW BY PARAMETER'')'||
                       ' ORDER BY display_sequence';
              OPEN l_cursor FOR l_sql USING l_region_code;
              FETCH l_cursor INTO l_rep_dim;
              IF l_cursor%FOUND THEN
                   l_viewby_url_param := 'VIEW_BY='||l_rep_dim;
              ELSE
                   -- I cannot do anything to get a view by parameter
                   l_viewby_url_param := 'VIEW_BY=';
              END IF;
              CLOSE l_cursor;
          END IF;
      END IF;

      l_function_url_param := 'pFunctionName='||l_function_name;

      -- Build the Report URL
      x_indicator_link := FND_WEB_CONFIG.PLSQL_AGENT||
                          'BISVIEWER_PUB.showReport?'||
                          'pUrlString='||bis_utilities_pub.encode(l_function_url_param);
      IF l_dim_url_params IS NOT NULL THEN
          x_indicator_link := x_indicator_link||bis_utilities_pub.encode('&'||l_dim_url_params);
      END IF;
      IF l_time_url_param IS NOT NULL THEN
          x_indicator_link := x_indicator_link||bis_utilities_pub.encode('&'||l_time_url_param);
      END IF;
      IF l_viewby_url_param IS NOT NULL THEN
          x_indicator_link := x_indicator_link||bis_utilities_pub.encode('&'||l_viewby_url_param);
      END IF;
      IF p_page_id IS NOT NULL THEN
          x_indicator_link := x_indicator_link||'&'||'pPageId='||p_page_id;
      END IF;
      -- Bug#2657344, need to pass in pUserId=<p_user_ud>
      IF p_user_id IS NOT NULL THEN
          x_indicator_link := x_indicator_link||'&'||'pUserId='||p_user_id;
      END IF;

  ELSE
    -- It is a KPI. This is implementation phase II
    NULL;
  END IF;

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

END Get_Indicator_Link;

/************************************************************************************
************************************************************************************/

PROCEDURE Decompose_Page_Parameters(
 p_page_dim_params 	 IN	VARCHAR2
 , p_page_time_param 	 IN	VARCHAR2
 , x_page_dim_parameters OUT NOCOPY	dim_parameter_tbl_type
 , x_page_time_param 	 OUT NOCOPY	time_parameter_rec_type
) IS

  l_num_dim_params	NUMBER;
  l_dim_params		t_array_of_varchar2;
  l_i			NUMBER;

  l_sub_string		VARCHAR2(32000);
  l_position		NUMBER;
  l_index		NUMBER;
  l_dim_parameter_rec	dim_parameter_rec_type;

BEGIN
    -- p_page_dim_params is : dim1+dimlevel1+dimlevelvalue1;dim2+dimlevel2+dimlevelvalue2;...

    IF p_page_dim_params IS NOT NULL THEN
        l_num_dim_params := Decompose_Varchar2_List(p_page_dim_params, l_dim_params, ';');

	l_index := 1;

        FOR l_i IN 1..l_num_dim_params LOOP
            -- dimension+dimlevel+dimlevelvalue must exist together
            l_sub_string := l_dim_params(l_i);
            l_position := INSTR(l_sub_string, '+');

            l_dim_parameter_rec.dimension := RTRIM(LTRIM(SUBSTR(l_sub_string, 1, l_position - 1)));

            l_sub_string := SUBSTR(l_sub_string, l_position + 1);
            l_position := INSTR(l_sub_string, '+');
            l_dim_parameter_rec.dimension_level := RTRIM(LTRIM(SUBSTR(l_sub_string, 1, l_position - 1)));

            l_sub_string := SUBSTR(l_sub_string, l_position + 1);
            l_position := INSTR(l_sub_string, '+');
            IF l_position <> 0 THEN
                l_dim_parameter_rec.dimension_level_value := RTRIM(LTRIM(SUBSTR(l_sub_string, 1, l_position - 1)));
            ELSE
                l_dim_parameter_rec.dimension_level_value := RTRIM(LTRIM(l_sub_string));
            END IF;

            x_page_dim_parameters(l_index) := l_dim_parameter_rec;
            l_index := l_index+1;

        END LOOP;
    END IF;

    IF p_page_time_param IS NOT NULL THEN
        -- p_page_time_param is like TIME+QUARTER+Q1-02+Q2-02

        l_sub_string := p_page_time_param;
        l_position := INSTR(l_sub_string, '+');
        x_page_time_param.dimension := RTRIM(LTRIM(SUBSTR(l_sub_string, 1, l_position - 1)));

        l_sub_string := SUBSTR(l_sub_string, l_position + 1);
        l_position := INSTR(l_sub_string, '+');
        x_page_time_param.dimension_level := RTRIM(LTRIM(SUBSTR(l_sub_string, 1, l_position - 1)));

        l_sub_string := SUBSTR(l_sub_string, l_position + 1);
        l_position := INSTR(l_sub_string, '+');
        x_page_time_param.time_from := RTRIM(LTRIM(SUBSTR(l_sub_string, 1, l_position - 1)));

        l_sub_string := SUBSTR(l_sub_string, l_position + 1);
        l_position := INSTR(l_sub_string, '+');
        x_page_time_param.time_to :=  RTRIM(LTRIM(l_sub_string));

     END IF;

END Decompose_Page_Parameters;

/************************************************************************************
************************************************************************************/

FUNCTION Get_Page_Dim_Param_Index(
 p_page_dim_params 	IN dim_parameter_tbl_type
 , p_dimension		IN VARCHAR2
 , p_dimension_level	IN VARCHAR2
) RETURN NUMBER IS

 l_index 	NUMBER;

BEGIN

    FOR l_index IN 1..p_page_dim_params.COUNT LOOP
        IF (p_page_dim_params(l_index).dimension = p_dimension) AND
           (p_page_dim_params(l_index).dimension_level = p_dimension_level) THEN
            RETURN l_index;
        END IF;
    END LOOP;

    l_index := 0;
    RETURN l_index;

END Get_Page_Dim_Param_Index;

/************************************************************************************
************************************************************************************/

FUNCTION has_Function_Access(
  p_user_id	IN NUMBER
  , p_function_name IN VARCHAR2
) RETURN BOOLEAN IS

  CURSOR c_function IS
      SELECT
          function_id
      FROM
          fnd_form_functions
      WHERE
          function_name = p_function_name;

  l_function_id		NUMBER;

  CURSOR c_menus IS
      SELECT
          a.menu_id
      FROM
          fnd_responsibility_vl a,
          fnd_user_resp_groups b
      WHERE
          b.user_id = p_user_id AND
          a.version = 'W' AND
          b.responsibility_id = a.responsibility_id AND
          b.start_date <= SYSDATE AND
          (b.end_date IS NULL OR b.end_date >= SYSDATE) AND
          a.start_date <= sysdate AND
          (a.end_date IS NULL OR a.end_date >= SYSDATE);

  l_menu_id	NUMBER;
  l_access	BOOLEAN := FALSE;

BEGIN
  -- Get the function id
  OPEN c_function;
  FETCH c_function INTO l_function_id;
  CLOSE c_function;

  IF l_function_id IS NULL THEN
      RETURN FALSE;
  END IF;


  OPEN c_menus;
  LOOP
      FETCH c_menus INTO l_menu_id;
      EXIT WHEN c_menus%NOTFOUND;

      l_access := fnd_function.is_function_on_menu(l_menu_id, l_function_id);
      IF l_access THEN
          CLOSE c_menus;
          RETURN l_access;
      END IF;

  END LOOP;
  CLOSE c_menus;

  RETURN l_access;

END has_Function_Access;

/************************************************************************************
************************************************************************************/

END BSC_CAUSE_EFFECT_UI_WRAPPER;

/
