--------------------------------------------------------
--  DDL for Package Body BIS_INDICATOR_REGION_UI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_INDICATOR_REGION_UI_PVT" as
/* $Header: BISVRUIB.pls 120.5 2006/01/17 06:38:17 visuri noship $ */
G_HELP        VARCHAR2(32000) := 'BISPM';
g_user_id     integer;
g_session_id  number;
g_var1        VARCHAR2(32000) := NULL;
g_var2        integer;
e_noactual    EXCEPTION;
e_norange     EXCEPTION;
-- meastmon 05/10/2001
e_notimevalue EXCEPTION;
e_notimevalue1 EXCEPTION;

--===========================================================
-- private constants and functions
-- juwang bug#2184804
--===========================================================
--============================================================
G_PKG_NAME  CONSTANT VARCHAR2(30):='BIS_PORTLET_PMREGION';
c_NULL      CONSTANT pls_integer := -9999;
c_key_menu  CONSTANT VARCHAR2(30):= 'pMeasureDefinition=';
c_key_target_level  CONSTANT VARCHAR2(50):= 'pTargetLevelShortName';
c_key_plan  CONSTANT VARCHAR2(50):= 'pPlanShortName';
c_key_dv_id1 CONSTANT VARCHAR2(50):= 'pDimensionLevel1ValueId';
c_key_dv_id2 CONSTANT VARCHAR2(50):= 'pDimensionLevel2ValueId';
c_key_dv_id3 CONSTANT VARCHAR2(50):= 'pDimensionLevel3ValueId';
c_key_dv_id4 CONSTANT VARCHAR2(50):= 'pDimensionLevel4ValueId';
c_key_dv_id5 CONSTANT VARCHAR2(50):= 'pDimensionLevel5ValueId';
c_key_dv_id6 CONSTANT VARCHAR2(50):= 'pDimensionLevel6ValueId';
c_key_dv_id7 CONSTANT VARCHAR2(50):= 'pDimensionLevel7ValueId';
c_key_status CONSTANT VARCHAR2(50):= 'pStatus';
c_key_value CONSTANT VARCHAR2(50):= 'pValue';
c_key_change CONSTANT VARCHAR2(50):= 'pChange';
c_key_arrow CONSTANT VARCHAR2(50):= 'pArrow';

c_arrow_type_green_up CONSTANT NUMBER := 1;
c_arrow_type_green_down CONSTANT NUMBER := 2;
c_arrow_type_red_up CONSTANT NUMBER := 3;
c_arrow_type_red_down CONSTANT NUMBER := 4;
c_arrow_type_black_up CONSTANT NUMBER := 5;
c_arrow_type_black_down CONSTANT NUMBER := 6;

c_down_green CONSTANT VARCHAR2(200) := '"/OA_MEDIA/bischdog.gif"';
c_down_red   CONSTANT VARCHAR2(200):= '"/OA_MEDIA/bischdob.gif"';
c_down_black CONSTANT VARCHAR2(200):= '"/OA_MEDIA/bischdon.gif"';
c_up_green   CONSTANT VARCHAR2(200) := '"/OA_MEDIA/bischupg.gif"';
c_up_red     CONSTANT VARCHAR2(200):= '"/OA_MEDIA/bischupb.gif"';
c_up_black   CONSTANT VARCHAR2(200):= '"/OA_MEDIA/bischupn.gif"';

c_caret  CONSTANT VARCHAR2(1) := '^';
c_eq  CONSTANT VARCHAR2(1) := '=';
c_squote  CONSTANT VARCHAR2(2) := '''';

c_fmt CONSTANT VARCHAR2(10) := '990D99';

c_longfmt CONSTANT VARCHAR2(30) := '999G990D99';
c_long_nod_fmt CONSTANT VARCHAR2(10) := '999G990';
c_I CONSTANT VARCHAR2(1) := 'I';
c_F CONSTANT VARCHAR2(1) := 'F';
c_K CONSTANT VARCHAR2(1) := 'K';
c_M CONSTANT VARCHAR2(1) := 'M';
c_B CONSTANT VARCHAR2(1) := 'B';
c_T CONSTANT VARCHAR2(1) := 'T';
-- !!! NLS Issue
c_thousand CONSTANT NUMBER := 1000;
c_million CONSTANT NUMBER := 1000000;
c_billion CONSTANT NUMBER := 1000000000;
c_trillion CONSTANT NUMBER := 1000000000000;


--============================================================
PROCEDURE get_ak_display_format(
  p_region_code IN VARCHAR2
 ,p_attribute_code IN VARCHAR2
 ,x_display_format OUT NOCOPY VARCHAR2
 ,x_display_type OUT NOCOPY VARCHAR2
);


--============================================================
PROCEDURE get_region_code(
  p_measure_id IN NUMBER
 ,x_region_code OUT NOCOPY VARCHAR2
 ,x_attribute_code OUT NOCOPY VARCHAR2 );


--===========================================================
FUNCTION getFormatValue(
  p_val IN NUMBER
  ) RETURN VARCHAR2;


--=============================================================
FUNCTION getFormatValue(
  p_val IN NUMBER
 ,p_format_mask IN VARCHAR2
  ) RETURN VARCHAR2;


--===========================================================
FUNCTION getFormatMask(
  p_val IN NUMBER
 ,p_show_decimal IN BOOLEAN
  ) RETURN VARCHAR2;


--============================================================
FUNCTION getBillionValue(
  p_val IN NUMBER
  ) RETURN VARCHAR2;


--============================================================
FUNCTION getBillionFormatMask(
  p_val IN NUMBER
  ) RETURN VARCHAR2;


--============================================================
PROCEDURE draw_portlet_header(
  p_status_lbl IN VARCHAR2
 ,p_measure_lbl IN VARCHAR2
 ,p_value_lbl IN VARCHAR2
 ,p_change_lbl IN VARCHAR2);



--===========================================================
FUNCTION get_row_style(
  p_row_style IN VARCHAR2
) RETURN VARCHAR2;



--============================================================
PROCEDURE draw_portlet_footer;


--============================================================
PROCEDURE draw_status(
  p_status_lbl IN VARCHAR2
 ,p_row_style IN VARCHAR2
 ,p_actual_val IN NUMBER
 ,p_target_val IN NUMBER
 ,p_range1_low_pcnt IN NUMBER
 ,p_range1_high_pcnt IN NUMBER
);

--============================================================
PROCEDURE draw_status(
  p_status_lbl IN VARCHAR2
 ,p_status IN NUMBER
 ,p_row_style IN VARCHAR2);

--============================================================
PROCEDURE draw_measure_name(
  p_actual_url IN VARCHAR2
 ,p_label IN VARCHAR2
 ,p_measure_lbl IN VARCHAR2
 ,p_row_style IN VARCHAR2);

--============================================================
PROCEDURE draw_actual(
  p_value_lbl IN VARCHAR2
 ,p_formatted_actual IN VARCHAR2
 ,p_row_style IN VARCHAR2);


--============================================================
PROCEDURE draw_change(
  p_change_lbl IN VARCHAR2
 ,p_change IN VARCHAR2
 ,p_img IN VARCHAR2
 ,p_arrow_alt_text IN VARCHAR2
 ,p_row_style IN VARCHAR2
);


--===========================================================
FUNCTION is_authroized(
  p_cur_user_id IN PLS_INTEGER
 ,p_target_level_id IN PLS_INTEGER
) RETURN BOOLEAN;


--===========================================================
PROCEDURE get_actual(
  p_target_rec IN BIS_TARGET_PUB.Target_Rec_Type
 ,x_actual_url OUT NOCOPY VARCHAR2
 ,x_actual_value OUT NOCOPY NUMBER
 ,x_comparison_actual_value OUT NOCOPY NUMBER
 ,x_err OUT NOCOPY VARCHAR2
);



--============================================================
PROCEDURE get_target(
  p_target_in IN  BIS_TARGET_PUB.Target_Rec_Type
 ,x_target OUT NOCOPY NUMBER
 ,x_range1_low OUT NOCOPY NUMBER
 ,x_range1_high OUT NOCOPY NUMBER
 ,x_range2_low OUT NOCOPY NUMBER
 ,x_range2_high OUT NOCOPY NUMBER
 ,x_range3_low OUT NOCOPY NUMBER
 ,x_range3_high OUT NOCOPY NUMBER
 ,x_err OUT NOCOPY VARCHAR2
);


--===========================================================
PROCEDURE get_time_dim_index(
  p_ind_selection_id IN NUMBER
 ,x_target_rec IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
 ,x_err OUT NOCOPY VARCHAR2
) ;

--=============================================================
PROCEDURE assign_time_level_value_id
(
  p_is_rolling_level    IN NUMBER,
  p_current_period_id IN VARCHAR,
  p_time_dim_idx  IN NUMBER,
  p_target_rec    IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
) ;


--===========================================================
PROCEDURE get_change(
  p_actual_value IN NUMBER
 ,p_comp_actual_value IN NUMBER
 ,p_comp_source IN VARCHAR2
 ,p_good_bad IN VARCHAR2
 ,p_improve_msg  IN VARCHAR2
 ,p_worse_msg  IN VARCHAR2
 ,x_change OUT NOCOPY NUMBER
 ,x_img OUT NOCOPY VARCHAR2
 ,x_arrow_alt_text IN OUT NOCOPY VARCHAR2
 ,x_err OUT NOCOPY VARCHAR2
) ;


--===========================================================
-- end of private functions/procedures declarations.
--============================================================

--============================================================
-- end of juwang change
--============================================================

-- meastmon 05/10/2001 Get current period id and name for the given
-- target level id and time level id
PROCEDURE getCurrentPeriodInfo(
    p_ind_selection_id IN NUMBER,
    p_target_level_id IN NUMBER,
    p_time_dimension_level_id IN NUMBER,
    x_current_period_id OUT NOCOPY VARCHAR2,
    x_current_period_name OUT NOCOPY VARCHAR2
    ) IS

  CURSOR c_source IS
    SELECT source
    FROM  bis_target_levels
    WHERE target_level_id = p_target_level_id;

  CURSOR c_org_dimension_index IS
    SELECT x.sequence_no,
           decode(x.sequence_no,
                  1, z.dimension1_level_id,
                  2, z.dimension2_level_id,
                  3, z.dimension3_level_id,
                  4, z.dimension4_level_id,
                  5, z.dimension5_level_id,
                  6, z.dimension6_level_id,
                  7, z.dimension7_level_id,
                  NULL) org_dimension_level_id
    FROM   bis_indicator_dimensions x, bis_dimensions y, bis_target_levels z
    WHERE  x.dimension_id = y.dimension_id AND
           y.short_name = BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_target_level_id,NULL) AND
           x.indicator_id = z.indicator_id AND
           z.target_level_id = p_target_level_id;

  CURSOR c_dimension_level_value(dimension_index NUMBER) IS
    SELECT decode(dimension_index,
                  1, dimension1_level_value,
                  2, dimension2_level_value,
                  3, dimension3_level_value,
                  4, dimension4_level_value,
                  5, dimension5_level_value,
                  6, dimension6_level_value,
                  7, dimension7_level_value,
                  NULL) dimension_level_value
    FROM bis_user_ind_selections
    WHERE ind_selection_id = p_ind_selection_id;

  CURSOR c_org_level_name (org_level_id NUMBER) IS
    SELECT short_name
    FROM bis_levels
    WHERE level_id = org_level_id;


  l_source                  VARCHAR2(30);
  l_time_dimension_name     VARCHAR2(500);
  l_total_time_level_name   VARCHAR2(500);

  l_view_name               VARCHAR2(800);
  l_short_name              VARCHAR2(30);
  l_name                    VARCHAR2(800);
  l_id                      VARCHAR2(250);
  l_value                   VARCHAR2(2500);
  l_select_stmt             VARCHAR2(2000);
  l_sql_result              INTEGER := 0;
  l_description             bis_levels_tl.description%TYPE;
  l_return_status           VARCHAR2(240);
  l_id_name                 VARCHAR(2000);
  l_value_name              VARCHAR(2000);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR(32000);

  l_sql                     VARCHAR2(32000);
  l_org_dimension_index     NUMBER;
  l_org_dimension_level_id  NUMBER;
  l_org_dimension_value     VARCHAR2(800);
  l_org_level_name          VARCHAR2(500);

  l_start_date        DATE;
  l_end_date        DATE;

  TYPE tcursor IS REF CURSOR;
  l_cursor        tcursor;
  l_time_lvl_dep_on_org    NUMBER(3);  --2684911

BEGIN
  BIS_PMF_GET_DIMLEVELS_PVT.Get_DimLevel_Values_Data(
        p_bis_dimlevel_id => p_time_dimension_level_id,
        x_dimlevel_short_name => l_short_name,
        x_select_String =>  l_select_stmt,
        x_table_name => l_view_name,
        x_value_name => l_value_name,
        x_id_name =>  l_id_name,
        x_level_name => l_name,
        x_description => l_description,
        x_return_status =>  l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data  =>  l_msg_data);

  l_time_dimension_name := BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_target_level_id, NULL);
  l_total_time_level_name := BIS_UTILITIES_PVT.GET_TOTAL_DIMLEVEL_NAME_TL(l_time_dimension_name, p_target_level_id, NULL);
  l_time_lvl_dep_on_org := BIS_UTILITIES_PUB.is_time_dependent_on_org(p_time_lvl_short_name => l_short_name) ; --2684911

  OPEN c_source;
  FETCH c_source INTO l_source;
  CLOSE c_source;

  -- For total time level there is only one record in the dimension view
  -- which is the one we want.

  IF (l_short_name <> l_total_time_level_name) THEN
      l_sql := 'SELECT DISTINCT '||l_id_name||', '||l_value_name||', start_date, end_date'||
               ' FROM '||l_view_name;

      -- No total time level
      -- In this case we compare sysdate with start_date and end_date
      -- to get the current period

      l_sql := l_sql||
               ' WHERE TRUNC(SYSDATE) BETWEEN '||
               ' NVL(start_date, TRUNC(SYSDATE)) and NVL(end_date, TRUNC(SYSDATE))';

      IF l_source = 'OLTP' AND l_time_lvl_dep_on_org = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG THEN --2684911
        -- For OLTP we need an additional condition on organization id
        -- if the time level is not one of HR
        OPEN c_org_dimension_index;
        FETCH c_org_dimension_index INTO l_org_dimension_index, l_org_dimension_level_id;
        CLOSE c_org_dimension_index;

        OPEN c_org_level_name(l_org_dimension_level_id);
        FETCH c_org_level_name INTO l_org_level_name;
        CLOSE c_org_level_name;

        OPEN c_dimension_level_value(l_org_dimension_index);
        FETCH c_dimension_level_value INTO l_org_dimension_value;
        CLOSE c_dimension_level_value;

        l_sql := l_sql||
                 ' AND ORGANIZATION_ID = '''||l_org_dimension_value||''''||
                 ' AND NVL(ORGANIZATION_TYPE, ''%'') LIKE '''||l_org_level_name||'''';

      ELSE
        IF l_source = 'EDW' THEN
          -- In this case we need to filter out NOCOPY codes 0 and -1 which are special codes in EDW dimension tables
          l_sql := l_sql||
                 ' AND '||l_id_name||' NOT IN (''-1'', ''0'')';

          IF (l_time_lvl_dep_on_org = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN --2684911
            OPEN c_org_dimension_index;
            FETCH c_org_dimension_index INTO l_org_dimension_index, l_org_dimension_level_id;
            CLOSE c_org_dimension_index;

            OPEN c_org_level_name(l_org_dimension_level_id);
            FETCH c_org_level_name INTO l_org_level_name;
            CLOSE c_org_level_name;

            OPEN c_dimension_level_value(l_org_dimension_index);
            FETCH c_dimension_level_value INTO l_org_dimension_value;
            CLOSE c_dimension_level_value;

            l_sql := l_sql||
                ' AND ORGANIZATION_ID = '''||l_org_dimension_value||''''||
                ' AND NVL(ORGANIZATION_TYPE, ''%'') LIKE '''||l_org_level_name||'''';
          END IF;

        END IF;
      END IF;

      l_sql := l_sql||
               ' ORDER BY ABS(NVL(TRUNC(end_date), TRUNC(SYSDATE))- NVL(TRUNC(start_date), TRUNC(SYSDATE)))';

  ELSE
      l_sql := 'SELECT DISTINCT '||l_id_name||', '||l_value_name||', SYSDATE AS start_date, SYSDATE AS end_date'||
               ' FROM '||l_view_name;
  END IF;

  -- Query is supposed to return just one record. However we take the first one.
  OPEN l_cursor FOR l_sql;
  FETCH l_cursor INTO x_current_period_id, x_current_period_name, l_start_date, l_end_date;
  CLOSE l_cursor;

EXCEPTION
  WHEN OTHERS THEN
    x_current_period_id := NULL;
    x_current_period_name := NULL;
    NULL;

END getCurrentPeriodInfo;


-- meastmon 05/14/2001 Get next period id and name for the given
-- target level id and time level id
PROCEDURE getNextPeriodInfo(
    p_ind_selection_id IN NUMBER,
    p_target_level_id IN NUMBER,
    p_time_dimension_level_id IN NUMBER,
    p_current_period_id IN VARCHAR2,
    p_current_period_name IN VARCHAR2,
    x_next_period_id OUT NOCOPY VARCHAR2,
    x_next_period_name OUT NOCOPY VARCHAR2
    ) IS

  e_no_next_period EXCEPTION;

  CURSOR c_source IS
    SELECT source
    FROM  bis_target_levels
    WHERE target_level_id = p_target_level_id;

  CURSOR c_org_dimension_index IS
    SELECT x.sequence_no,
           decode(x.sequence_no,
                  1, z.dimension1_level_id,
                  2, z.dimension2_level_id,
                  3, z.dimension3_level_id,
                  4, z.dimension4_level_id,
                  5, z.dimension5_level_id,
                  6, z.dimension6_level_id,
                  7, z.dimension7_level_id,
                  NULL) org_dimension_level_id
    FROM   bis_indicator_dimensions x, bis_dimensions y, bis_target_levels z
    WHERE  x.dimension_id = y.dimension_id AND
           y.short_name = BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_target_level_id,NULL) AND
           x.indicator_id = z.indicator_id AND
           z.target_level_id = p_target_level_id;

  CURSOR c_dimension_level_value(dimension_index NUMBER) IS
    SELECT decode(dimension_index,
                  1, dimension1_level_value,
                  2, dimension2_level_value,
                  3, dimension3_level_value,
                  4, dimension4_level_value,
                  5, dimension5_level_value,
                  6, dimension6_level_value,
                  7, dimension7_level_value,
                  NULL) dimension_level_value
    FROM bis_user_ind_selections
    WHERE ind_selection_id = p_ind_selection_id;

  CURSOR c_org_level_name (org_level_id NUMBER) IS
    SELECT short_name
    FROM bis_levels
    WHERE level_id = org_level_id;

  l_source                  VARCHAR2(30);
  l_time_dimension_name     VARCHAR2(500);
  l_total_time_level_name   VARCHAR2(500);

  l_view_name               VARCHAR2(800);
  l_short_name              VARCHAR2(300);
  l_name                    VARCHAR2(800);
  l_id                      VARCHAR2(250);
  l_value                   VARCHAR2(2500);
  l_select_stmt             VARCHAR2(2000);
  l_sql_result              INTEGER := 0;
  l_description             bis_levels_tl.description%TYPE;
  l_return_status           VARCHAR2(240);
  l_id_name                 VARCHAR(2000);
  l_value_name              VARCHAR(2000);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR(32000);

  l_sql                     VARCHAR2(32000);
  l_sql_aux                 VARCHAR2(32000);
  l_org_dimension_index     NUMBER;
  l_org_dimension_level_id  NUMBER;
  l_org_dimension_value     VARCHAR2(800);
  l_org_level_name          VARCHAR2(500);

  l_next_period_date        VARCHAR2(200);

  l_start_date        DATE;
  l_end_date        DATE;

  TYPE tcursor IS REF CURSOR;
  l_cursor        tcursor;

  l_time_lvl_dep_on_org    NUMBER(3);  --2684911

BEGIN
  BIS_PMF_GET_DIMLEVELS_PVT.Get_DimLevel_Values_Data(
        p_bis_dimlevel_id => p_time_dimension_level_id,
        x_dimlevel_short_name => l_short_name,
        x_select_String =>  l_select_stmt,
        x_table_name => l_view_name,
        x_value_name => l_value_name,
        x_id_name =>  l_id_name,
        x_level_name => l_name,
        x_description => l_description,
        x_return_status =>  l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data  =>  l_msg_data);

  l_time_dimension_name := BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_target_level_id, NULL);
  l_total_time_level_name := BIS_UTILITIES_PVT.GET_TOTAL_DIMLEVEL_NAME_TL(l_time_dimension_name, p_target_level_id, NULL);

  OPEN c_source;
  FETCH c_source INTO l_source;
  CLOSE c_source;

  l_time_lvl_dep_on_org := BIS_UTILITIES_PUB.is_time_dependent_on_org(p_time_lvl_short_name => l_short_name) ; --2684911

  -- For total time level there is only one record in the dimension view
  -- which is the one we want.

  IF (l_short_name <> l_total_time_level_name) THEN
      l_sql := 'SELECT DISTINCT '||l_id_name||', '||l_value_name||', start_date, end_date'||
               ' FROM '||l_view_name;

      -- No total time level
      -- In this case we get the end date of the current period and look for
      -- the period containing the next day

      IF l_source = 'OLTP' AND
         l_time_lvl_dep_on_org = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG THEN --2684911
        -- For OLTP we need an additional condition on organization id
        -- if the time level is not one of HR
        OPEN c_org_dimension_index;
        FETCH c_org_dimension_index INTO l_org_dimension_index, l_org_dimension_level_id;
        CLOSE c_org_dimension_index;

        OPEN c_org_level_name(l_org_dimension_level_id);
        FETCH c_org_level_name INTO l_org_level_name;
        CLOSE c_org_level_name;

        OPEN c_dimension_level_value(l_org_dimension_index);
        FETCH c_dimension_level_value INTO l_org_dimension_value;
        CLOSE c_dimension_level_value;


          l_sql_aux := 'SELECT TO_CHAR(end_date + 1, ''MM-DD-YYYY'')'||
                     ' FROM '||l_view_name||
                     ' WHERE '||l_id_name||' = :1 '||
                     ' AND ORGANIZATION_ID = :2 ' ||
                     ' AND NVL(ORGANIZATION_TYPE, ''%'') LIKE :3 ';
          EXECUTE IMMEDIATE l_sql_aux INTO l_next_period_date USING p_current_period_id, l_org_dimension_value, l_org_level_name;

          l_sql := l_sql||
                 ' WHERE TRUNC(TO_DATE('''||l_next_period_date||''', ''MM-DD-YYYY'')) BETWEEN '||
                 ' NVL(start_date, TRUNC(TO_DATE('''||l_next_period_date||''', ''MM-DD-YYYY''))) AND '||
                 ' NVL(end_date, TRUNC(TO_DATE('''||l_next_period_date||''', ''MM-DD-YYYY'')))'||
                 ' AND ORGANIZATION_ID = '''||l_org_dimension_value||''''||
                 ' AND NVL(ORGANIZATION_TYPE, ''%'') LIKE '''||l_org_level_name||'''';
      ELSE
        l_sql_aux := 'SELECT TO_CHAR(end_date + 1, ''MM-DD-YYYY'')'||
                     ' FROM '||l_view_name||
                     ' WHERE '||l_id_name||' = : 1';
        EXECUTE IMMEDIATE l_sql_aux INTO l_next_period_date USING p_current_period_id;

        l_sql := l_sql||
                 ' WHERE TRUNC(TO_DATE('''||l_next_period_date||''', ''MM-DD-YYYY'')) BETWEEN '||
                 ' NVL(start_date, TRUNC(TO_DATE('''||l_next_period_date||''', ''MM-DD-YYYY''))) AND '||
                 ' NVL(end_date, TRUNC(TO_DATE('''||l_next_period_date||''', ''MM-DD-YYYY'')))';

        IF l_source = 'EDW' THEN
          -- In this case we need to filter out NOCOPY codes 0 and -1 which are special codes in EDW dimension tables
          l_sql := l_sql||
                 ' AND '||l_id_name||' NOT IN (''-1'', ''0'')';
          IF (l_time_lvl_dep_on_org = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN --2684911

            OPEN c_org_dimension_index;
            FETCH c_org_dimension_index INTO l_org_dimension_index, l_org_dimension_level_id;
            CLOSE c_org_dimension_index;

            OPEN c_org_level_name(l_org_dimension_level_id);
            FETCH c_org_level_name INTO l_org_level_name;
            CLOSE c_org_level_name;

            OPEN c_dimension_level_value(l_org_dimension_index);
            FETCH c_dimension_level_value INTO l_org_dimension_value;
            CLOSE c_dimension_level_value;

             l_sql := l_sql||
                 ' AND ORGANIZATION_ID = '''||l_org_dimension_value||''''||
                 ' AND NVL(ORGANIZATION_TYPE, ''%'') LIKE '''||l_org_level_name||'''';
          END IF;

        END IF;
      END IF;

      l_sql := l_sql||
               ' ORDER BY ABS(NVL(TRUNC(end_date), TRUNC(SYSDATE))- NVL(TRUNC(start_date), TRUNC(SYSDATE)))';
  ELSE
      l_sql := 'SELECT DISTINCT '||l_id_name||', '||l_value_name||' SYSDATE AS start_date, SYSDATE AS end_date'||
               ' FROM '||l_view_name;
  END IF;

   -- Query is supposed to return just one record. However we take the first one.
  BEGIN
      OPEN l_cursor FOR l_sql;
      FETCH l_cursor INTO x_next_period_id,  x_next_period_name, l_start_date, l_end_date;
      CLOSE l_cursor;
  EXCEPTION
    WHEN OTHERS THEN
      x_next_period_id := NULL;
      x_next_period_name := NULL;
  END;

  IF x_next_period_id IS NULL THEN
    RAISE e_no_next_period;
  END IF;


EXCEPTION
  WHEN e_no_next_period THEN
    x_next_period_id := p_current_period_id;
    x_next_period_name := p_current_period_name;

  WHEN OTHERS THEN
    NULL;

END getNextPeriodInfo;


FUNCTION getTargetURL(
    p_session_id IN pls_integer,
    p_ind_selection_id IN NUMBER,
    p_target_level_id IN NUMBER,
    p_time_dimension_index IN NUMBER,
    p_time_dimension_level_id IN NUMBER,
    p_current_period_id IN VARCHAR2,
    p_current_period_name IN VARCHAR2,
    p_plan_id IN NUMBER
    ) RETURN VARCHAR2 IS

    CURSOR c_measure IS
        SELECT i.short_name
        FROM bis_indicators i, bis_target_levels t
        WHERE i.indicator_id = t.indicator_id AND
              t.target_level_id = p_target_level_id;

    CURSOR c_dim_level(dimension_index NUMBER) IS
    SELECT short_name
    FROM bis_levels
    WHERE level_id = (
          SELECT decode(dimension_index,
                 1, dimension1_level_id,
                 2, dimension2_level_id,
                 3, dimension3_level_id,
                 4, dimension4_level_id,
                 5, dimension5_level_id,
                 6, dimension6_level_id,
                 7, dimension7_level_id,
                 NULL)
          FROM bis_target_levels
          WHERE target_level_id = p_target_level_id);

    CURSOR c_dim_level_value(dimension_index NUMBER) IS
    SELECT decode(dimension_index,
                  1, dimension1_level_value,
                  2, dimension2_level_value,
                  3, dimension3_level_value,
                  4, dimension4_level_value,
                  5, dimension5_level_value,
                  6, dimension6_level_value,
                  7, dimension7_level_value,
                  NULL) dimension_level_value
    FROM bis_user_ind_selections
    WHERE ind_selection_id = p_ind_selection_id;

    l_measure             VARCHAR2(50);
    l_targeturl           VARCHAR2(2000);

    l_url                 VARCHAR2(2000) := NULL;
    l_dim_levels          VARCHAR2(2000) := NULL;
    l_dim_level_values    VARCHAR2(2000) := NULL;
    l_dim_level           VARCHAR2(500) := NULL;
    l_dim_level_value     VARCHAR2(800) := NULL;
    l_next_period_id      VARCHAR2(32000) := NULL;
    l_next_period_name    VARCHAR2(32000) := NULL;


BEGIN
    l_targeturl := FND_WEB_CONFIG.WEB_SERVER||'OA_HTML/';

    OPEN c_measure;
    FETCH c_measure INTO l_measure;
    CLOSE c_measure;

    l_url := l_targeturl||'bistared.jsp'||
             '?dbc='||FND_WEB_CONFIG.DATABASE_ID||
             '&sessionid='||icx_call.encrypt3(p_session_id)||
             '&RegionCode='||
             '&FunctionName='||
             '&SortInfo='||BIS_UTILITIES_PUB.encode('SortyaxisAsc')||
             '&pageSource='||BIS_UTILITIES_PUB.encode('PMRegion')||
             '&Measure='||BIS_UTILITIES_PUB.encode(l_measure)||
             '&PlanId='||p_plan_id;

    FOR l_i IN 1..7 LOOP
        l_dim_level := NULL;
        OPEN c_dim_level(l_i);
        FETCH c_dim_level INTO l_dim_level;
        CLOSE c_dim_level;

        l_dim_level_value:= NULL;
        OPEN c_dim_level_value(l_i);
        FETCH c_dim_level_value INTO l_dim_level_value;
        CLOSE c_dim_level_value;

        IF l_dim_level IS NOT NULL THEN
          l_dim_levels := l_dim_levels||
                          '&Dim'||l_i||'Level='||BIS_UTILITIES_PUB.encode(l_dim_level);

          IF l_i = p_time_dimension_index THEN
            -- get next period value id
            getNextPeriodInfo(p_ind_selection_id,
                              p_target_level_id,
                              p_time_dimension_level_id,
                              p_current_period_id,
                              p_current_period_name,
                              l_next_period_id,
                              l_next_period_name);
            IF l_next_period_id IS NOT NULL THEN
                l_dim_level_values := l_dim_level_values||
                                      '&Dim'||l_i||'LevelValue='||BIS_UTILITIES_PUB.encode(l_next_period_id);
            ELSE
                l_dim_level_values := l_dim_level_values||
                                      '&Dim'||l_i||'LevelValue=';
            END IF;

          ELSE
            l_dim_level_values := l_dim_level_values||
                                  '&Dim'||l_i||'LevelValue='||BIS_UTILITIES_PUB.encode(l_dim_level_value);
          END IF;
        ELSE
          l_dim_levels := l_dim_levels||
                          '&Dim'||l_i||'Level=';

          l_dim_level_values := l_dim_level_values||
                                '&Dim'||l_i||'LevelValue=';
        END IF;
    END LOOP;

    l_url := l_url||l_dim_levels||l_dim_level_values;

    RETURN l_url;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END getTargetURL;



-- *****************************************************
--   PROCEDURE THAT DISPLAYS THE PLUG AND ACTUALS
-- *****************************************************
procedure display( p_session_id in pls_integer default NULL
                 , p_plug_id    in pls_integer default NULL
                 , p_display_name  varchar2 default NULL
                 , p_delete in varchar2 default 'N')
is

l_target_rec          BIS_TARGET_PUB.Target_Rec_Type;
l_row_style  VARCHAR2(100);

-- data variables
l_actual_value        NUMBER;
l_comparison_actual_value  NUMBER;
l_target              NUMBER:= NULL;
l_range1_low          NUMBER:= NULL;
l_range1_high         NUMBER:= NULL;
l_range2_low          NUMBER:= NULL;
l_range2_high         NUMBER:= NULL;
l_range3_low          NUMBER:= NULL;
l_range3_high         NUMBER:= NULL;

l_format_actual   VARCHAR2(1000);
l_actual_url      VARCHAR2(32000) ;

l_change          NUMBER(20,2);
l_img             VARCHAR2(2000);
l_good_bad        VARCHAR2(2000);
l_arrow_alt_text  VARCHAR2(2000);

-- debugging variables
l_err VARCHAR2(32000);
l_err2 VARCHAR2(32000);



-- labels
l_none_lbl        VARCHAR2(200);
l_na_lbl          VARCHAR2(200) ;
l_un_auth         FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE; -- VARCHAR2(200); 2829397

-- header labels
l_status_lbl      VARCHAR2(2000);
l_measure_lbl     VARCHAR2(2000);
l_value_lbl       VARCHAR2(2000);
l_change_lbl      VARCHAR2(2000);
l_perc_lbl        VARCHAR2(2000);


l_in_range_lbl    VARCHAR2(2000);
l_out_range_lbl   VARCHAR2(2000);
l_improve_msg     VARCHAR2(2000);
l_worse_msg       VARCHAR2(2000);


 -- ========================================
 -- cusor declarations
 -- ========================================
 CURSOR c_selections IS
   SELECT distinct a.ind_selection_id
          ,a.label
          ,a.target_level_id
          ,a.dimension1_level_value
          ,a.dimension2_level_value
          ,a.dimension3_level_value
          ,a.dimension4_level_value
          ,a.dimension5_level_value
          ,a.dimension6_level_value
          ,a.dimension7_level_value
          ,a.plan_id
          ,c.increase_in_measure
          ,c.comparison_source
          ,c.indicator_id
  FROM   bis_user_ind_selections  a
         ,fnd_user_resp_groups    b
         ,bis_indicators c
         ,bisbv_target_levels d
  WHERE a.user_id = g_user_id
  AND   a.plug_id = p_plug_id
  AND   a.user_id = b.user_id
  AND   b.start_date <= sysdate
  AND   (b.end_date is null or b.end_date >= sysdate)
  AND   d.target_level_id = a.target_level_id
  AND   d.measure_id = c.indicator_id
  ORDER BY  a.ind_selection_id;



BEGIN
 IF (ICX_SEC.validatePlugSession(p_plug_id,p_session_id)) THEN
    g_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'',p_session_id);

  IF p_delete = 'Y' THEN

    BEGIN
      delete from bis_user_ind_selections
      where user_id = g_user_id
      and   plug_id = p_plug_id;
    EXCEPTION
      WHEN OTHERS THEN
        htp.p('Error: '||SQLERRM);
    END;
  ELSE

  -- =======================
  -- loading messages
  -- =======================
  l_none_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_NONE');
  l_na_lbl := (BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_NA_LBL'));
  l_un_auth := BIS_UTILITIES_PVT.Get_FND_Message('BIS_UNAUTHORIZED');

  -- header labels
  l_status_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_STATUS');
  l_measure_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_NAME');
  l_value_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_VALUE_LBL');
  l_change_lbl := (BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_CHANGE'));
  l_perc_lbl := (BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_PERC_LBL'));

  -- msgs
  l_in_range_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_WITHIN_RANGE');
  l_out_range_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_OUTSIDE_RANGE');
  l_worse_msg := BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_CHANGE_WORSE');
  l_improve_msg := BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_CHANGE_IMPROVE');


  -- =======================
  -- Begin Main block
  -- =======================
  -- Banner
  htp.p('<table width="100%" border="0" cellspacing="0" cellpadding="0">');
  htp.p('<tr><td>');


  -- meastmon 09/07/2001 Fix bug#1980577. Workaround Do not encrypt plug_id
  icx_plug_utilities.plugbanner(p_display_name,
                   'OA_HTML/OA.jsp?page=/oracle/apps/bis/pmf/pmportlet/pages/BISPMFSETINDICATORS&retainAM=Y&oapc=3&Z='||p_plug_id
                    , 'FNDINDIC.gif');


  htp.p('</td></tr>');
  htp.p('</table>');

  draw_portlet_header(l_status_lbl
  ,l_measure_lbl
  ,l_value_lbl
  ,l_change_lbl);


  --Performance measures

  -- Begin fetching rows from the table BIS_USER_IND_SELECTIONS
  --
  l_row_style := 'Band';

  FOR csel in c_selections LOOP
    htp.p('              <tr> ');
    l_target_rec.target_level_id      := csel.target_level_id;
    l_target_rec.plan_id              := csel.plan_id;

    l_target_rec.dim1_level_value_id  := csel.dimension1_level_value;
    l_target_rec.dim2_level_value_id  := csel.dimension2_level_value;
    l_target_rec.dim3_level_value_id  := csel.dimension3_level_value;
    l_target_rec.dim4_level_value_id  := csel.dimension4_level_value;
    l_target_rec.dim5_level_value_id  := csel.dimension5_level_value;
    l_target_rec.dim6_level_value_id  := csel.dimension6_level_value;
    l_target_rec.dim7_level_value_id  := csel.dimension7_level_value;
    l_good_bad := csel.increase_in_measure; -- 1850860


   -- This is to display one row in white and the next in yellow
    l_row_style := get_row_style(l_row_style);

    -- meastmon 05/09/2001 This block encloses logic to get target, actual
    -- for this user selection
    BEGIN

      get_time_dim_index(
       p_ind_selection_id => csel.ind_selection_id
      ,x_target_rec => l_target_rec
      ,x_err => l_err
      ) ;

      get_actual
      (  p_target_rec => l_target_rec
        ,x_actual_url => l_actual_url
  ,x_actual_value => l_actual_value
  ,x_comparison_actual_value => l_comparison_actual_value
  ,x_err => l_err2
      );
      -- retriving target


      get_target
      ( p_target_in  => l_target_rec
       ,x_target  => l_target
       ,x_range1_low  => l_range1_low
       ,x_range1_high  => l_range1_high
       ,x_range2_low  => l_range2_low
       ,x_range2_high  => l_range2_high
       ,x_range3_low  => l_range3_low
       ,x_range3_high => l_range3_high
       ,x_err => l_err2
      );



      --=============================================================
      -- rendering now
      --=============================================================
      -- draw status, measure name and actual


       -- Now paint the actual if exists in the appropriate color
      IF  l_actual_value IS NULL THEN
      --Paint the Label
  draw_status(l_status_lbl, 0, l_row_style);
        draw_measure_name(l_actual_url, csel.label, l_measure_lbl,l_row_style);
      draw_actual(l_value_lbl, l_none_lbl, l_row_style);
  draw_change(l_change_lbl,l_na_lbl,null,null,l_row_style);

      ELSE

        l_format_actual := getAKFormatValue( p_measure_id =>csel.indicator_id
                                           , p_val =>l_actual_value);

  get_change(
     p_actual_value => l_actual_value
    ,p_comp_actual_value  => l_comparison_actual_value
    ,p_comp_source  => csel.comparison_source
    ,p_good_bad  => l_good_bad
    ,p_improve_msg => l_improve_msg
    ,p_worse_msg => l_worse_msg
    ,x_change => l_change
    ,x_img => l_img
    ,x_arrow_alt_text => l_arrow_alt_text
    ,x_err => l_err2
   );

  draw_status(
     p_status_lbl => l_status_lbl
    ,p_row_style  => l_row_style
    ,p_actual_val => l_actual_value
    ,p_target_val => l_target
    ,p_range1_low_pcnt  => l_range1_low
    ,p_range1_high_pcnt => l_range1_high
    );

        draw_measure_name( l_actual_url
                         , csel.label -- || l_target_rec.target_level_id
                         , l_measure_lbl
                         , l_row_style);

  draw_actual(l_value_lbl, l_format_actual, l_row_style);
  IF ( l_change IS NULL) THEN
          draw_change(l_change_lbl,l_na_lbl,null,null,l_row_style);
  ELSE
    draw_change(l_change_lbl,
    TO_CHAR(l_change)||l_perc_lbl,l_img,l_arrow_alt_text,l_row_style);
  END IF;
      END IF;  -- (l_actual_value IS NULL)
      htp.p('              </tr> ');


    EXCEPTION
    WHEN e_notimevalue THEN
      draw_status(l_status_lbl, 0, l_row_style);
      draw_measure_name(l_err, csel.label, l_measure_lbl,l_row_style);
      draw_actual(l_value_lbl, l_none_lbl, l_row_style);
      draw_change(l_change_lbl,l_na_lbl,null,null,l_row_style);

    WHEN OTHERS THEN
      draw_status(l_status_lbl, 0, l_row_style);
      draw_measure_name(l_err2, csel.label, l_measure_lbl,l_row_style);
      --draw_measure_name(SQLERRM, csel.label, l_measure_lbl,l_row_style);
      draw_actual(l_value_lbl, l_none_lbl, l_row_style);
      draw_change(l_change_lbl,l_na_lbl,null,null,l_row_style);


    END; -- end of block containing the c_notimelevels cursor

    htp.p('              </tr>');

  END LOOP; -- end of c_selections loop
  draw_portlet_footer;

 END IF; -- Main block: p_delete = 'Y'

END IF;  -- icx_sec.validatePlugSession

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  WHEN OTHERS THEN
    htp.p(SQLERRM);
END DISPLAY;

-- ************************************************************
--   Show Demo URL for Portlal
-- ************************************************************

PROCEDURE show_cust_demo_url(
  p_plug_id IN PLS_INTEGER
 ,p_session_id IN PLS_INTEGER
 ,x_string OUT NOCOPY VARCHAR2
)
IS
  l_url VARCHAR2(10000);
  l_url_lbl VARCHAR2(10000);
  l_servlet_agent VARCHAR2(5000) := NULL;
  l_string   VARCHAR2(32000);
BEGIN

  IF ( NOT BIS_PMF_PORTLET_UTIL.is_demo_on ) THEN  -- demo not on
    x_string := NULL;
    RETURN;
  END IF;

  -- demo is on
  l_url_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_PMF_ENTER_PT_DATA');

  l_servlet_agent := FND_WEB_CONFIG.JSP_AGENT;   -- 'http://serv:port/OA_HTML/'
  IF ( l_servlet_agent IS NULL ) THEN   -- 'APPS_SERVLET_AGENT' is null
     l_servlet_agent := FND_WEB_CONFIG.WEB_SERVER || 'OA_HTML/';
  END IF;

-- juwang
  l_url := l_servlet_agent ||
         'bisptdta.jsp?dbc=' || FND_WEB_CONFIG.database_id() || -- 2454902
   '&pPlugId=' || p_plug_id ||
   '&sessionid=' || p_session_id;

  l_string := l_string ||'<table>';
  l_string := l_string ||'<tr><td align="LEFT"><a href="' || l_url ||'">' || l_url_lbl||'</a></td></tr>';
  l_string := l_string ||'</table>';

  x_string := l_string;


 -- juwang

EXCEPTION
  WHEN OTHERS THEN
    RETURN ;

END show_cust_demo_url;


-- *********************************************
-- Procedure to choose the Indicator levels
-- 19-SEP-00 gsanap    Modified SetIndicators procedure to fix
--                     Bug 1404224 which was the Banner on Customize pg.
--                     was not displaying properly
-- *********************************************
procedure setIndicators (
  Z in pls_integer   default NULL
, p_selections_tbl   Selected_Values_Tbl_Type
, p_back_url        IN VARCHAR2
, p_reference_path  IN VARCHAR2
, x_string           out NOCOPY VARCHAR2
)
is
 l_count                 number;
 l_resp_id               number;
 l_initialize            varchar2(32000);
 r_initialize            varchar2(32000);
 l_nbsp                  varchar2(32000);
 l_title                 varchar2(32000);
 l_tarlevel_lbl          varchar2(32000);
 l_select_tarlevel       varchar2(32000);
 l_dup_tarlevel          varchar2(32000);
 l_resp_counter          number;
 l_prompt_length         number;
 l_instruction           varchar2(32000);
 l_plug_id               pls_integer;
 l_plug_id1               pls_integer;--comment
--
l_line_length            pls_integer;
l_line                   varchar2(32000);
l_point1                 pls_integer;
l_length                 pls_integer;
l_nextcount              pls_integer;
l_lastcount              pls_integer;
l_occurence              pls_integer;
l_ind_level_name         varchar2(32000);
l_ind_level_id           pls_integer;
l_current_user_id       PLS_INTEGER;
l_user_id               PLS_INTEGER;
l_owner_user_id         PLS_INTEGER;
--
l_loc                    pls_integer;
l_value                  varchar2(32000);
l_text                   varchar2(32000);
l_msg_count              number;
l_msg_data               varchar2(32000);
l_return_status          varchar2(32000);
l_indicators_tbl         BIS_TARGET_LEVEL_PUB.Target_Level_Tbl_Type;
l_displaylabels_tbl      Selected_Values_Tbl_Type;
l_selections_tbl         BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
l_temp_tbl               no_duplicates_tbl_Type;
l_unique                 BOOLEAN;
l_cnt                    pls_integer;
l_error_tbl              BIS_UTILITIES_PUB.Error_Tbl_Type;

-- Fix for ADA buttons
l_button_str             varchar2(32000);
l_button_tbl             BIS_UTILITIES_PVT.HTML_Button_Tbl_Type;
l_string                 VARCHAR2(32000);
l_demo_string            VARCHAR(32000);
l_append_string          VARCHAR2(1000);
l_swan_enabled           BOOLEAN;
l_button_edge            VARCHAR2(100);

BEGIN

-- meastmon 09/07/2001 Fix bug#1980577. Workaround Do not encrypt plug_id
l_plug_id := Z;

l_swan_enabled := BIS_UTILITIES_PVT.checkSWANEnabled();


--if icx_sec.validateSession  then
--  if ICX_SEC.validatePlugSession(l_plug_id) then

     --g_user_id := icx_sec.getID(icx_sec.PV_USER_ID, '', icx_sec.g_session_id); --2751984
     l_current_user_id := icx_sec.getID(icx_sec.PV_USER_ID, '', icx_sec.g_session_id); --2751984

     l_nbsp := '&'||'nbsp;';
     l_initialize := '                                ';

  -- Get all the message strings from the database
 fnd_message.set_name('BIS','BIS_SELECT_TARLEVEL');
 l_select_tarlevel := icx_util.replace_quotes(fnd_message.get);
  --changed from BIS_DUP_TARLEVEL to BIS_DUP_TARLEVELS
 fnd_message.set_name('BIS','BIS_DUP_TARLEVELS');
 l_dup_tarlevel := icx_util.replace_quotes(fnd_message.get);

  -- Create a dummy value in the indicators table to send it
  -- to the next proc because one of parameters is a plsql table
  -- which cannot be nullable
  --   l_displaylabels_tbl(1) := '';


  IF ((p_reference_path IS NOT NULL) AND (NOT BIS_PMF_PORTLET_UTIL.has_customized_rows(l_plug_id, l_current_user_id, l_owner_user_id) )) THEN
      l_user_id := l_owner_user_id;
    ELSE
      l_user_id := l_current_user_id;
  END IF;

  -- ********************************************
  -- Get all the Indicator Levels for this user
  -- ********************************************
  BIS_TARGET_LEVEL_PUB.Retrieve_User_Target_Levels
  ( p_api_version         => 1.0
  , p_all_info            => FND_API.G_FALSE
  , p_user_id             => l_current_user_id
  , x_Target_Level_Tbl    => l_indicators_tbl
  , x_return_status       => l_return_status
  , x_Error_Tbl           => l_error_tbl
  );

 -- Get all the previously selected Indicator levels from
 -- bis_user_ind_selections table.
 BIS_INDICATOR_REGION_PUB.Retrieve_User_Ind_Selections
  ( p_api_version          => 1.0
  , p_user_id              => l_user_id
  , p_all_info             => FND_API.G_TRUE
  , p_plug_id              => l_plug_id
  , x_Indicator_Region_Tbl => l_selections_tbl
  , x_return_status        => l_return_status
  , x_Error_Tbl            => l_error_tbl
  );

--  /***********  For DEBUGGING **************
--  htp.p('g_user_id '||g_user_id||'<BR>');
--  htp.p('g_plug_id '||l_plug_id||'<BR>');
--  for i in 1 .. l_indicators_tbl.COUNT loop
--  htp.p('l_indicators_tbl(i).target_level_name: '||
--         l_indicators_tbl(i).target_level_name||'<BR>');
--  end loop;
--  ************************************************/




  -- Remove the duplicates from the l_selections_tbl
  IF (l_selections_tbl.COUNT <> 0) THEN
     FOR i in 1 .. l_selections_tbl.COUNT LOOP
       l_unique := TRUE;
       FOR j in 1 .. l_temp_tbl.COUNT LOOP
          if l_selections_tbl(i).target_level_id = l_temp_tbl(j).id then
            l_unique := FALSE;
          end if;
       END LOOP;
       if (l_unique AND
        BIS_PMF_PORTLET_UTIL.is_authorized(
        p_cur_user_id => g_user_id
       ,p_target_level_id => l_selections_tbl(i).target_level_id) ) THEN
         l_cnt := l_temp_tbl.COUNT + 1;
         l_temp_tbl(l_cnt).id := l_selections_tbl(i).target_level_id;
         l_temp_tbl(l_cnt).name := l_selections_tbl(i).target_level_name;
       end if;
     END LOOP;
  END IF;


---------------------------------------------------------------------------
-- 19-SEP-00 gsanap    Modified this part to use putStyle and remove icon_show
--                     Bug 1404224 which was the Banner on Customize pg.
--                     was not displaying properly
---------------------------------------------------------------------------
 l_string := l_string ||'<body>';
 l_string := l_string || '<LINK HREF="/OA_HTML/bisportal.css" type="text/css" rel="stylesheet">';


 -- Print out NOCOPY the instructions for this page
 fnd_message.set_name('BIS','BIS_PLUG_INSTRUCTION1');
 l_instruction := bis_utilities_pvt.escape_html_input(icx_util.replace_quotes(fnd_message.get));
 l_string := l_string ||'<BR>';
 l_string := l_string ||'<table width="100%" border=0 cellspacing=0 cellpadding=0>';
 l_string := l_string ||'<tr><td width=5%></td><td width=90%>';
 l_string := l_string ||l_instruction||'</td><td width=5%></td></tr>';
 l_string := l_string ||'</table>';
 l_string := l_string ||'<BR>';

 l_string := l_string ||'<SCRIPT LANGUAGE="JavaScript">';


  -- Function to move the selected target levels to the favorites box
  --meastmon 06/25/2001. Validate that user have seleted a target level before
  --clicking add button
  l_string := l_string || 'function addTo() {';
  l_string := l_string || '    var temp=document.DefaultFormName.B.selectedIndex;';
  l_string := l_string || '    if (temp < 0)';
  l_string := l_string || '      selectTo();';
  l_string := l_string || '    else {';
  l_string := l_string || '      var totext=document.DefaultFormName.B[temp].text;';
  l_string := l_string || '      var tovalue=document.DefaultFormName.B[temp].value;';
  l_string := l_string || '      var end=document.DefaultFormName.C.length;';
  l_string := l_string || '      if (end > 0) {';
  l_string := l_string || '        if (document.DefaultFormName.C.options[end-1].value =="") { ';
  l_string := l_string || '          end = end - 1;';
  l_string := l_string || '        }';
  l_string := l_string || '        for (var i=0;i<end;i++) {';
  l_string := l_string || '          if (tovalue == document.DefaultFormName.C[i].value)';
  l_string := l_string || '            var check = 0;';
  l_string := l_string || '        }';
  l_string := l_string || '        if (check == 0) {';
  l_string := l_string || '          alert("'||l_dup_tarlevel||'");';
  l_string := l_string || '        }';
  l_string := l_string || '        else {';
  l_string := l_string || '          document.DefaultFormName.C.options[end] = new Option(totext,tovalue);';
  l_string := l_string || '          document.DefaultFormName.C.selectedIndex = end;';
  l_string := l_string || '        }';
  l_string := l_string || '      }';
  l_string := l_string || '      else {';
  l_string := l_string || '        document.DefaultFormName.C.options[end] = new Option(totext,tovalue);';
  l_string := l_string || '        document.DefaultFormName.C.selectedIndex = end;';
  l_string := l_string || '      }';
  l_string := l_string || '    }';
  l_string := l_string || '  }';


  l_string := l_string || 'function selectTo() {';
  l_string := l_string || '     alert("'||l_select_tarlevel||'")';
  l_string := l_string || '     }';


   -- Function to move selections upwards in the favorites box
   -- meastmon 06/25/2001 Fix bug#1835495.
  l_string := l_string ||'function upTo() {';
  l_string := l_string ||'     var temp = document.DefaultFormName.C.selectedIndex;';
  l_string := l_string ||'     if (temp < 0)';
  l_string := l_string ||'        selectTo();';
  l_string := l_string ||'     else {';
  l_string := l_string ||'       if (temp > 0) { ';
  l_string := l_string ||'         var text = document.DefaultFormName.C[temp-1].text;';
  l_string := l_string ||'         var val = document.DefaultFormName.C.options[temp-1].value;';
  l_string := l_string ||'         var totext = document.DefaultFormName.C[temp].text;';
  l_string := l_string ||'         var toval = document.DefaultFormName.C.options[temp].value;';
  l_string := l_string ||'         document.DefaultFormName.C[temp-1].text = totext;';
  l_string := l_string ||'         document.DefaultFormName.C.options[temp-1].value = toval;';
  l_string := l_string ||'         document.DefaultFormName.C[temp].text = text;';
  l_string := l_string ||'         document.DefaultFormName.C.options[temp].value = val;';
  l_string := l_string ||'         document.DefaultFormName.C.selectedIndex = temp-1;';
  l_string := l_string ||'       }';
  l_string := l_string ||'     }';

  l_string := l_string ||'   }';

  -- Function to move selections downwards in the favorites box
  -- meastmon 06/25/2001 Fix bug#1835495.
  l_string := l_string ||'function downTo() {';
  l_string := l_string ||'     var temp = document.DefaultFormName.C.selectedIndex;';
  l_string := l_string ||'     var end = document.DefaultFormName.C.length;';

  l_string := l_string ||'     if (temp < 0)';
  l_string := l_string ||'        selectTo();';
  l_string := l_string ||'     else {';
  l_string := l_string ||'       if (document.DefaultFormName.C.options[end-1].value == "")';
  l_string := l_string ||'         end = end - 1;';

  l_string := l_string ||'       if (temp < (end-1)) {';
  l_string := l_string ||'         var text = document.DefaultFormName.C[temp+1].text;';
  l_string := l_string ||'         var val = document.DefaultFormName.C.options[temp+1].value;';
  l_string := l_string ||'         var totext = document.DefaultFormName.C[temp].text;';
  l_string := l_string ||'         var toval = document.DefaultFormName.C.options[temp].value;';

  l_string := l_string ||'         document.DefaultFormName.C[temp+1].text = totext;';
  l_string := l_string ||'         document.DefaultFormName.C.options[temp+1].value = toval;';
  l_string := l_string ||'         document.DefaultFormName.C[temp].text = text;';
  l_string := l_string ||'         document.DefaultFormName.C.options[temp].value = val;';
  l_string := l_string ||'         document.DefaultFormName.C.selectedIndex = temp+1;';
  l_string := l_string ||'       }';
  l_string := l_string ||'     }';

  l_string := l_string ||'   }';


-- Function to delete entries in the favorites box
  l_string := l_string ||'function deleteTo() {';
  l_string := l_string ||' var temp=document.DefaultFormName.C.selectedIndex;';
  l_string := l_string ||'   if (temp < 0)';
  l_string := l_string ||'     selectTo();';
  l_string := l_string ||'   else {';
  l_string := l_string ||'     document.DefaultFormName.C.options[temp] = null;';
  l_string := l_string ||'     }';

  l_string := l_string ||'  }';

  l_string := l_string ||'function open_new_browser() {';
  l_string := l_string ||'    var attributes = "resizable=yes,scrollbars=yes,toolbar=no,width="+x+",height="+ y;';
  l_string := l_string ||'    var new_browser = window.open(url, "new_browser", attributes);';
  l_string := l_string ||'    if (new_browser != null) {';
  l_string := l_string ||'        if (new_browser.opener == null)';
  l_string := l_string ||'            new_browser.opener = self;';
  l_string := l_string ||'        window.name = ''Oraclefavoritesroot'';';
  l_string := l_string ||'        new_browser.location.href = url;';
  l_string := l_string ||'        }';
  l_string := l_string ||'    }';


 --  Function to save the favorites
  l_string := l_string ||'function savefavorites() {';
  l_string := l_string ||'   var end=document.DefaultFormName.C.length;';
  l_string := l_string ||'   for (var i=0; i<end; i++) {';
  l_string := l_string ||'     if (document.DefaultFormName.C.options[i].value != "") {';
  l_string := l_string || '      var e = document.DefaultFormName.C.options[i].value; ';
  l_string := l_string ||'       document.DefaultFormName.p_selections_tbl[i].value = e + "*" + document.DefaultFormName.C.options[i].text;';
  l_string := l_string ||'       document.DefaultFormName.submit();';
  l_string := l_string ||'       }';
  l_string := l_string ||'       }';
  l_string := l_string ||'   }';

-- Function to reset everything on the page
  l_string := l_string ||'function resetfavorites() {';
  l_string := l_string ||'loadFrom();';
  l_string := l_string ||'loadTo();';
  l_string := l_string ||'     }';

  l_string := l_string ||'</SCRIPT>';

  l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.Z.value='||Z||';';
  l_string := l_string ||'</SCRIPT>';
  l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.p_back_url.value='''||p_back_url||''';';
  l_string := l_string ||'</SCRIPT>';
  l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.p_reference_path.value='''||p_reference_path||''';';
  l_string := l_string ||'</SCRIPT>';
  l_string := l_string ||'<INPUT TYPE="hidden" NAME="p_indlevel" VALUE="">';
  l_string := l_string ||'<INPUT TYPE="hidden" NAME="p_ind_level_id" VALUE="">';
  l_string := l_string ||'<INPUT TYPE="hidden" NAME="p_displaylabels_tbl" VALUE="">';

  -- Create hidden values to grab selected indicator levels into

  l_string := l_string ||'<CENTER>';
  l_string := l_string ||'<table width="100%" border=0 cellspacing=0 cellpadding=0>';--main
  l_string := l_string ||'<tr><td align=center>';
  l_string := l_string ||'<table width="10%" border=0 cellspacing=0 cellpadding=0>';--cell

  IF(l_swan_enabled)THEN
    l_string := l_string ||'<tr><td nowrap="YES" class="x49">';
    l_string := l_string ||BIS_UTILITIES_PVT.getPrompt('BIS_AVAILABLE_MEASURES')||': ';
    l_string := l_string ||'</td><td nowrap="YES" class="x49">';
    l_string := l_string ||BIS_UTILITIES_PVT.getPrompt('BIS_SELECTED_MEASURES')||': ';
  ELSE
    l_string := l_string ||'<tr><td nowrap="YES">';
    l_string := l_string ||BIS_UTILITIES_PVT.getPrompt('BIS_AVAILABLE_MEASURES')||': ';
    l_string := l_string ||'</td><td nowrap="YES">';
    l_string := l_string ||BIS_UTILITIES_PVT.getPrompt('BIS_SELECTED_MEASURES')||': ';
  END IF;
  l_string := l_string ||'</td></tr>';
  l_string := l_string ||'<tr><td>';
  l_string := l_string ||'<table border=0 cellspacing=0 cellpadding=0><tr><td>'; -- full menu cell
  l_string := l_string ||'<select name="B" size=10>';

  IF (l_indicators_tbl.COUNT = 0) THEN
    l_string := l_string ||'<OPTION VALUE=>             ';
  ELSE
    for i in l_indicators_tbl.FIRST .. l_indicators_tbl.COUNT loop
  -- mdamle 01/12/2001 - Change display text of Performance Measure list
      -- changed l_indicators_tbl(i).target_level_name to getPerformanceMeasureName()
      l_string := l_string ||'<OPTION VALUE='||bis_utilities_pvt.escape_html_input(l_indicators_tbl(i).target_level_id)||'>'||bis_utilities_pvt.escape_html_input(getPerformanceMeasureName(l_indicators_tbl(i).target_level_id));
    end loop;
  END IF;

  l_string := l_string ||'</SELECT>';

  l_string := l_string ||'</td><td align="left">';
  l_string := l_string ||'<table><tr><td>'; --add
  l_string := l_string ||'<A HREF="javascript:addTo();';
  l_string := l_string ||        '" onMouseOver="window.status=''';
  l_string := l_string ||        BIS_UTILITIES_PVT.getPrompt('BIS_ADD');

  IF(l_swan_enabled)THEN
   l_string := l_string ||        ''';return true"><image src="/OA_MEDIA/BISMOVE.gif" alt="';
  ELSE
   l_string := l_string ||        ''';return true"><image src="/OA_MEDIA/FNDRTARW.gif" alt="';
  END IF;

  l_string := l_string ||        ICX_UTIL.replace_alt_quotes(BIS_UTILITIES_PVT.getPrompt('BIS_ADD'))||'" BORDER="0"></A>';
  l_string := l_string ||'</td></tr></table>'; -- add
  l_string := l_string ||'</td></tr></table>'; -- full menu cell
  l_string := l_string ||'</td><td>';
  --favorite cell
  l_string := l_string ||'<table border=0 cellspacing=0 cellpadding=0><tr><td>';
  l_string := l_string ||'<select name="C" size=10>';



  if (TRIM(p_selections_tbl(1)) is NULL) then
    -- If first time to this page, get the data from database
    IF (l_temp_tbl.COUNT = 0) THEN
      l_string := l_string ||'<OPTION VALUE=>             ';
    ELSE
       for i in l_temp_tbl.FIRST .. l_temp_tbl.COUNT loop
        -- mdamle 01/12/2001 - Change display text of Performance Measure list
          -- changed l_temp_tbl(i).name to getPerformanceMeasureName()
         l_string := l_string ||'<OPTION VALUE='||bis_utilities_pvt.escape_html_input(l_temp_tbl(i).id)||'>'||bis_utilities_pvt.escape_html_input(getPerformanceMeasureName(l_temp_tbl(i).id));
       end loop;
    END IF;
  else

    -- If coming back from the next page,get data from plsql table
    for i in p_selections_tbl.FIRST .. p_selections_tbl.COUNT loop

      l_loc := instr(p_selections_tbl(i),'*',1,1);
      l_value := substr (p_selections_tbl(i),1,l_loc - 1);
      l_text := substr (p_selections_tbl(i),l_loc + 1);
      l_string := l_string ||'<OPTION VALUE='||bis_utilities_pvt.escape_html_input(l_value)||'>'||bis_utilities_pvt.escape_html_input(l_text);
      exit when p_selections_tbl(i) is NULL;
    end LOOP;

  end if;

  l_string := l_string ||'</SELECT>';
  l_string := l_string ||'</td><td align="left">';

  -- up and down
  l_string := l_string ||'<table><tr><td align="left" valign="bottom">';
  l_string := l_string ||'<A HREF="javascript:upTo()" onMouseOver="window.status=''';
  --l_string := l_string ||     ICX_UTIL.replace_onMouseOver_quotes(BIS_UTILITIES_PVT.getPrompt('BIS_UP'));
  l_string := l_string ||     BIS_UTILITIES_PVT.getPrompt('BIS_UP');
  IF(l_swan_enabled)THEN
   l_string := l_string ||     ''';return true"><image src="/OA_MEDIA/BISMOVUP.gif" alt="';
  ELSE
    l_string := l_string ||     ''';return true"><image src="/OA_MEDIA/FNDUPARW.gif" alt="';
  END IF;
  l_string := l_string ||     BIS_UTILITIES_PVT.getPrompt('BIS_UP')||'" BORDER="0"></A>';
  l_string := l_string ||'</td></tr><tr><td align="left" valign="top">';
  l_string := l_string ||'<A HREF="javascript:downTo()" onMouseOver="window.status=''';
  l_string := l_string ||     BIS_UTILITIES_PVT.getPrompt('BIS_DOWN');
  IF(l_swan_enabled)THEN
   l_string := l_string ||     ''';return true"><image src="/OA_MEDIA/BISMOVDN.gif" alt="';
  ELSE
   l_string := l_string ||     ''';return true"><image src="/OA_MEDIA/FNDDNARW.gif" alt="';
  END IF;
  l_string := l_string ||     ICX_UTIL.replace_alt_quotes(BIS_UTILITIES_PVT.getPrompt('BIS_DOWN'))||'" BORDER="0"></A>';
  l_string := l_string ||'</td></tr></table>'; --up and down
  l_string := l_string ||'</td></tr></table>'; --favorite cell
  l_string := l_string ||'</td></tr>';
  l_string := l_string ||'<tr><td></td><td>';

  --buttons
  l_string := l_string ||'<table><tr>';
  l_string := l_string ||'<td><BR></td>';
  l_string := l_string ||'<td><BR></td><td>';

  IF(l_swan_enabled)THEN
   l_button_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
  ELSE
   l_button_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
  END IF;

  --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
  l_button_tbl(1).left_edge  := l_button_edge;
  l_button_tbl(1).right_edge := l_button_edge;
  l_button_tbl(1).disabled := FND_API.G_FALSE;
  l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_DELETE');
  l_button_tbl(1).href := 'Javascript:deleteTo()';

  BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
  l_string := l_string ||l_button_str;

  l_string := l_string ||'</td></tr></table>';
  l_string := l_string ||'</td></tr>';

  l_string := l_string ||'<!--   ********     Buttons Row   ********* -->';
  l_string := l_string ||'<tr><td colspan="2"><BR></td></tr>';
  l_string := l_string ||'<tr><td colspan="2">';
  l_string := l_string ||'<table width="100%"><tr><td width=50% align="right">'; -- ok

  --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.

  l_button_tbl(1).left_edge  := l_button_edge;
  l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
  l_button_tbl(1).disabled := FND_API.G_FALSE;
  l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_CONTINUE');
  l_button_tbl(1).href := 'Javascript:savefavorites()';
  BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
  l_string := l_string ||l_button_str;
  l_string := l_string ||'</td><td align="left" width="50%">';

  --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
  l_button_tbl(1).left_edge  := BIS_UTILITIES_PVT.G_FLAT_EDGE;
  l_button_tbl(1).right_edge := l_button_edge;
  l_button_tbl(1).disabled := FND_API.G_FALSE;
  l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL');

  IF (p_back_url IS NULL) THEN
    l_button_tbl(1).href := BIS_REPORT_UTIL_PVT.Get_Home_URL;
  ELSE
    l_button_tbl(1).href := p_back_url;
  END IF;

  BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
  l_string := l_string ||l_button_str;
  l_string := l_string ||'</td></tr></table>';
  l_string := l_string ||'</td></tr>';


  l_string := l_string ||'</table>'; --cell
  l_string := l_string ||'</td></tr>';
  l_string := l_string ||'</table>'; --main
  l_string := l_string ||'<SCRIPT LANGUAGE="JavaScript">';
  l_string := l_string ||'document.DefaultFormName.B.focus();';
  l_string := l_string ||'</SCRIPT>';
  l_string := l_string ||'</CENTER>';

  --need to add demo in portals


  IF (p_reference_path IS NOT NULL) THEN
    show_cust_demo_url(l_plug_id, icx_sec.g_session_id, l_demo_string);
    IF (l_demo_string IS NOT NULL) THEN
      l_string := l_string || l_demo_string;
    END IF;
  END IF;

  l_string := l_string ||'</BODY>';
  l_string := l_string ||'</HTML>';
--  end if;
--end if;

x_string := l_string;

exception
    when others then
      x_string := SQLERRM;

end setIndicators;



-- ************************************************************
--   Show the Dimensions Page
-- ************************************************************
procedure showDimensions
( Z                      in pls_integer
, p_indlevel             in varchar2 default NULL
, p_ind_level_id         in pls_integer  default NULL
, p_displaylabels_tbl    in Selected_Values_Tbl_Type
, p_selections_tbl       in Selected_Values_Tbl_Type
, p_back_url             in VARCHAR2
, p_reference_path       IN VARCHAR2
, x_str_object            out nocopy CLOB
)
is
l_counter                 pls_integer := 150;
l_cnt                     pls_integer;
l_plug_id                 pls_integer;
l_length                  pls_integer;
l_initialize              varchar2(32000);
l_nbsp                    varchar2(32000);
l_title                   varchar2(32000);
l_choose_dim_value        varchar2(32000);
l_enter_displabel         varchar2(32000);
l_select_displabel        varchar2(32000);
l_dup_displabel           varchar2(32000);
l_dup_combo               varchar2(32000);
l_resp_counter             number;
l_prompt_length            number;
l_instruction              varchar2(32000);
l_blank                    varchar2(32000);
l_msg_count                number;
l_msg_data                 varchar2(32000);
l_return_status            varchar2(32000);
l_loc                      pls_integer;
l_value                    varchar2(32000);
l_text                     varchar2(32000);
l_ind_level_name           varchar2(32000);
l_ind_level_id             pls_integer;
l_indicators_tbl           BIS_TARGET_LEVEL_PUB.Target_Level_Tbl_Type;
l_labels_tbl               BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
l_orgs_tbl                 no_duplicates_tbl_Type;
l_dim1_tbl                 no_duplicates_tbl_Type;
l_dim2_tbl                 no_duplicates_tbl_Type;
l_dim3_tbl                 no_duplicates_tbl_Type;
l_dim4_tbl                 no_duplicates_tbl_Type;
l_dim5_tbl                 no_duplicates_tbl_Type;
-- mdamle 01/15/2001 - Use Dim6 and Dim7
l_dim6_tbl                 no_duplicates_tbl_Type;
l_dim7_tbl                 no_duplicates_tbl_Type;

l_d0_tbl                   no_duplicates_tbl_Type;
l_d1_tbl                   no_duplicates_tbl_Type;
l_d2_tbl                   no_duplicates_tbl_Type;
l_d3_tbl                   no_duplicates_tbl_Type;
l_d4_tbl                   no_duplicates_tbl_Type;
l_d5_tbl                   no_duplicates_tbl_Type;
l_d6_tbl                   no_duplicates_tbl_Type;
l_d7_tbl                   no_duplicates_tbl_Type;
l_current_user_id          PLS_INTEGER;
l_user_id                  PLS_INTEGER;
l_owner_user_id            PLS_INTEGER;
l_Time_Seq_Num              number;
--
l_Org_Seq_Num              number;
l_Org_Level_ID             number;


l_Org_Level_Value_ID       varchar2(80); -- number;

l_Org_Level_Short_Name     varchar2(240);
l_Org_Level_Name           bis_levels_tl.name%TYPE;

d0                         varchar2(32000);
d1                         varchar2(32000);
l_link                     varchar2(32000);
l_error_tbl                BIS_UTILITIES_PUB.Error_Tbl_Type;
l_clear                    VARCHAR2(32000);
l_sobString                VARCHAR2(32000);
l_elements                 BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;

-- Grab the incoming indicator level id into a local var for use later
v_ind_level_id                pls_integer := p_ind_level_id;

cursor plan_cur is
 SELECT plan_id,short_name,name
 FROM BISBV_BUSINESS_PLANS
 ORDER BY name;

-- mdamle 01/15/2001 - Use Dim6 and Dim7
-- added short_names and additional levels
cursor bisfv_target_levels_cur(p_tarid in pls_integer) is
 SELECT TARGET_LEVEL_ID,
        TARGET_LEVEL_NAME,
    -- mdamle 01/15/2001 - Use Dim6 and Dim7
        -- ORG_LEVEL_ID,
        -- ORG_LEVEL_SHORT_NAME,
        -- ORG_LEVEL_NAME,
        DIMENSION1_LEVEL_ID,
    DIMENSION1_LEVEL_SHORT_NAME,
        DIMENSION1_LEVEL_NAME,
        DIMENSION2_LEVEL_ID,
    DIMENSION2_LEVEL_SHORT_NAME,
        DIMENSION2_LEVEL_NAME,
        DIMENSION3_LEVEL_ID,
    DIMENSION3_LEVEL_SHORT_NAME,
        DIMENSION3_LEVEL_NAME,
        DIMENSION4_LEVEL_ID,
    DIMENSION4_LEVEL_SHORT_NAME,
        DIMENSION4_LEVEL_NAME,
        DIMENSION5_LEVEL_ID,
    DIMENSION5_LEVEL_SHORT_NAME,
        DIMENSION5_LEVEL_NAME,
        DIMENSION6_LEVEL_ID,
    DIMENSION6_LEVEL_SHORT_NAME,
        DIMENSION6_LEVEL_NAME,
        DIMENSION7_LEVEL_ID,
    DIMENSION7_LEVEL_SHORT_NAME,
        DIMENSION7_LEVEL_NAME
 FROM BISFV_TARGET_LEVELS
 WHERE TARGET_LEVEL_ID = p_tarid;

l_button_str             varchar2(32000);
l_button_tbl             BIS_UTILITIES_PVT.HTML_Button_Tbl_Type;
--Bug 1797465
l_dim0_lbl               VARCHAR2(1000);
l_dim1_lbl               VARCHAR2(1000);
l_dim2_lbl               VARCHAR2(1000);
l_dim3_lbl               VARCHAR2(1000);
l_dim4_lbl               VARCHAR2(1000);
l_dim5_lbl               VARCHAR2(1000);
l_dim6_lbl               VARCHAR2(1000);
l_dim7_lbl               VARCHAR2(1000);
l_string                 VARCHAR2(32000);
l_string1                VARCHAR2(32000);
l_lov_string             VARCHAR2(32000);
l_str_object             CLOB;
l_un_auth                VARCHAR2(200);
l_access                 VARCHAR2(200);
l_append_string          VARCHAR2(1000);
l_swan_enabled           BOOLEAN;
l_button_edge            VARCHAR2(100);

BEGIN


l_plug_id := Z;
l_swan_enabled := BIS_UTILITIES_PVT.checkSWANEnabled();
--l_plug_id := icx_call.decrypt2(Z);

--if icx_sec.validateSession  then
-- if ICX_SEC.validatePlugSession(l_plug_id) then

   --g_user_id := ICX_SEC.getID(ICX_SEC.PV_USER_ID, '', icx_sec.g_session_id); --2751984
 l_current_user_id := ICX_SEC.getID(ICX_SEC.PV_USER_ID, '', icx_sec.g_session_id); --2751984


 l_initialize := '                                  ';
 l_blank    := '';

   -- Set the message strings from the database
  fnd_message.set_name('BIS','BIS_ENTER_DISPLAY_LABEL');
   l_enter_displabel := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_SELECT_DISPLAY_LABEL');
   l_select_displabel := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_DUP_DISPLAY_LABEL');
   l_dup_displabel := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_DUP_COMBO');
   l_dup_combo := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_CHOOSE_DIM_VALUE');
   l_choose_dim_value := icx_util.replace_quotes(fnd_message.get);

  l_un_auth := BIS_UTILITIES_PVT.Get_FND_Message('BIS_UNAUTHORIZED');


  IF ((p_reference_path IS NOT NULL) AND (NOT BIS_PMF_PORTLET_UTIL.has_customized_rows(l_plug_id, l_current_user_id, l_owner_user_id) )) THEN
      l_user_id := l_owner_user_id;
    ELSE
      l_user_id := l_current_user_id;
  END IF;

   -- ******************************************************
   -- Call the procedure that paints the LOV javascript function
   -- ******************************************************
   BIS_LOV_PUB.lovjscript(x_string => l_lov_string);

   IF(l_str_object IS NULL) THEN
     WF_NOTIFICATION.NewClob(l_str_object, l_lov_string);
   ELSE
     WF_NOTIFICATION.WriteToClob(l_str_object,l_lov_string);
   END IF;

   -- Get all the previously selected labels from
   -- selections box.

   BIS_INDICATOR_REGION_PUB.Retrieve_User_Ind_Selections
   ( p_api_version          => 1.0
   , p_user_id              => l_user_id
   , p_all_info             => FND_API.G_TRUE
   , p_plug_id              => l_plug_id
   , x_Indicator_Region_Tbl => l_labels_tbl
   , x_return_status        => l_return_status
   , x_Error_Tbl            => l_error_tbl
   );

   l_string := '<body>';
   l_string := l_string || '<LINK HREF="/OA_HTML/bisportal.css" type="text/css" rel="stylesheet">';
    -- Print out NOCOPY the instructions for this page
   fnd_message.set_name('BIS','BIS_PLUG_INSTRUCTION2');
   l_instruction := bis_utilities_pvt.escape_html_input(icx_util.replace_quotes(fnd_message.get));
   l_string := l_string ||'<BR>';
   l_string := l_string ||'<table width="100%" border=0 cellspacing=0 cellpadding=0>';
   l_string := l_string ||'<tr><td width=5%></td><td width=90% class="x0">'||l_instruction||'</td><td width=5%></td></tr>';
   l_string := l_string ||'</table>';
   l_string := l_string ||'<BR>';

   l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">';

   l_string := l_string ||'function selectTo() {';
   l_string := l_string ||'       alert("'||l_select_displabel||'")';
   l_string := l_string ||'       }';


   -- Function to move the new display label to the favorites box
   l_string := l_string ||'function addTo() {';
   l_string := l_string ||'if (document.DefaultFormName.label.value == ""){';
   l_string := l_string ||'     alert ("'||l_enter_displabel||'");';
   l_string := l_string ||'     document.DefaultFormName.label.focus();';
   l_string := l_string ||'     }';
   l_string := l_string ||'  else {';
   l_string := l_string ||'     var ind_tmp  = document.DefaultFormName.p_indlevel.selectedIndex;';
   l_string := l_string ||'     var ind    =   document.DefaultFormName.p_indlevel[ind_tmp].value;';
   --l_string := l_string ||'  // Do some checks before grabbing the dimension level values';
   --l_string := l_string ||'  // For dimension0';
   l_string := l_string ||'     if (document.DefaultFormName.dim0_level_id.value != "") {';
   l_string := l_string ||'        var d0_tmp = document.DefaultFormName.dim0.selectedIndex;';
   l_string := l_string ||'        var d0_end = document.DefaultFormName.dim0.length;';
   l_string := l_string ||'        if ((document.DefaultFormName.dim0[d0_tmp].text == "'||l_blank||'") '||c_OR||' (document.DefaultFormName.dim0[d0_tmp].text == "'||c_choose||'"))  {';
   l_string := l_string ||'           d0 = "+";';
   l_string := l_string ||'           document.DefaultFormName.dim0.focus();';
   l_string := l_string ||'           return FALSE;';
   l_string := l_string ||'           }';
   l_string := l_string ||'        else';
   l_string := l_string ||'           var d0 =  document.DefaultFormName.dim0[d0_tmp].value;';
   l_string := l_string ||'        }';
   l_string := l_string ||'     else';
   l_string := l_string ||'        {d0 = "-";}';

   --l_string := l_string ||'     // For dimension1';
   l_string := l_string ||'     if (document.DefaultFormName.dim1_level_id.value != "") {';
   l_string := l_string ||'        var d1_tmp = document.DefaultFormName.dim1.selectedIndex;';
   l_string := l_string ||'        var d1_end = document.DefaultFormName.dim1.length;';
   l_string := l_string ||'        if ((document.DefaultFormName.dim1[d1_tmp].text == "'||l_blank||'") '||c_OR||' (document.DefaultFormName.dim1[d1_tmp].text == "'||c_choose||'"))  {';
   l_string := l_string ||'           d1 = "+";';
   l_string := l_string ||'           alert("'||l_choose_dim_value||'");';
   l_string := l_string ||'           document.DefaultFormName.dim1.focus();';
   l_string := l_string ||'           return FALSE;';
   l_string := l_string ||'           }';
   l_string := l_string ||'        else';
   l_string := l_string ||'           var d1 =  document.DefaultFormName.dim1[d1_tmp].value;';
   l_string := l_string ||'        }';
   l_string := l_string ||'     else';
   l_string := l_string ||'        {d1 = "-";}';

   --l_string := l_string ||'     // For dimension2';
   l_string := l_string ||'     if (document.DefaultFormName.dim2_level_id.value != "") {';
   l_string := l_string ||'        var d2_tmp = document.DefaultFormName.dim2.selectedIndex;';
   l_string := l_string ||'        var d2_end = document.DefaultFormName.dim2.length;';
   l_string := l_string ||'        if ((document.DefaultFormName.dim2[d2_tmp].text == "'||l_blank||'") '||c_OR||' (document.DefaultFormName.dim2[d2_tmp].text == "'||c_choose||'"))  {';
   l_string := l_string ||'           d2 = "+";';
   l_string := l_string ||'           alert("'||l_choose_dim_value||'");';
   l_string := l_string ||'           document.DefaultFormName.dim2.focus();';
   l_string := l_string ||'           return FALSE;';
   l_string := l_string ||'           }';
   l_string := l_string ||'        else';
   l_string := l_string ||'           var d2 =  document.DefaultFormName.dim2[d2_tmp].value;';
   l_string := l_string ||'        }';
   l_string := l_string ||'     else';
   l_string := l_string ||'        {d2 = "-";}';

   --l_string := l_string ||'     // For dimension3';
   l_string := l_string ||'     if (document.DefaultFormName.dim3_level_id.value != "") {';
   l_string := l_string ||'        var d3_tmp = document.DefaultFormName.dim3.selectedIndex;';
   l_string := l_string ||'        var d3_end = document.DefaultFormName.dim3.length;';
   l_string := l_string ||'        if ((document.DefaultFormName.dim3[d3_tmp].text == "'||l_blank||'") '||c_OR||' (document.DefaultFormName.dim3[d3_tmp].text == "'||c_choose||'"))  {';
   l_string := l_string ||'           d3 = "+";';
   l_string := l_string ||'           alert("'||l_choose_dim_value||'");';
   l_string := l_string ||'           document.DefaultFormName.dim3.focus();';
   l_string := l_string ||'           return FALSE;';
   l_string := l_string ||'           }';
   l_string := l_string ||'        else';
   l_string := l_string ||'           var d3 =  document.DefaultFormName.dim3[d3_tmp].value;';
   l_string := l_string ||'        }';
   l_string := l_string ||'     else';
   l_string := l_string ||'        {d3 = "-";}';

   --l_string := l_string ||'     // For dimension4';
   l_string := l_string ||'     if (document.DefaultFormName.dim4_level_id.value != "") {';
   l_string := l_string ||'        var d4_tmp = document.DefaultFormName.dim4.selectedIndex;';
   l_string := l_string ||'        var d4_end = document.DefaultFormName.dim4.length;';
   l_string := l_string ||'        if ((document.DefaultFormName.dim4[d4_tmp].text == "'||l_blank||'") '||c_OR||' (document.DefaultFormName.dim4[d4_tmp].text == "'||c_choose||'"))  {';

   l_string := l_string ||'d4 = "+";';
   l_string := l_string ||'           alert("'||l_choose_dim_value||'");';
   l_string := l_string ||'           document.DefaultFormName.dim4.focus();';
   l_string := l_string ||'           return FALSE;';
   l_string := l_string ||'           }';
   l_string := l_string ||'        else';
   l_string := l_string ||'           var d4 =  document.DefaultFormName.dim4[d4_tmp].value;';
   l_string := l_string ||'        }';
   l_string := l_string ||'     else';
   l_string := l_string ||'        {d4 = "-";}';

   --l_string := l_string ||'     // For dimension5';
   l_string := l_string ||'     if (document.DefaultFormName.dim5_level_id.value != "") {';
   l_string := l_string ||'        var d5_tmp = document.DefaultFormName.dim5.selectedIndex;';
   l_string := l_string ||'        var d5_end = document.DefaultFormName.dim5.length;';
   l_string := l_string ||'        if ((document.DefaultFormName.dim5[d5_tmp].text == "'||l_blank||'") '||c_OR||' (document.DefaultFormName.dim5[d5_tmp].text == "'||c_choose||'"))  {';
   l_string := l_string ||'           d5 = "+";';
   l_string := l_string ||'           alert("'||l_choose_dim_value||'");';
   l_string := l_string ||'           document.DefaultFormName.dim5.focus();';
   l_string := l_string ||'           return FALSE;';
   l_string := l_string ||'           }';
   l_string := l_string ||'        else';
   l_string := l_string ||'           var d5 =  document.DefaultFormName.dim5[d5_tmp].value;';
   l_string := l_string ||'        }';
   l_string := l_string ||'     else';
   l_string := l_string ||'        {d5 = "-";}';

   --l_string := l_string ||' // mdamle 01/15/2001 - Use Dim6 and Dim7';
   --l_string := l_string ||'     // For dimension6';
   l_string := l_string ||'     if (document.DefaultFormName.dim6_level_id.value != "") {';
   l_string := l_string ||'        var d6_tmp = document.DefaultFormName.dim6.selectedIndex;';
   l_string := l_string ||'        var d6_end = document.DefaultFormName.dim6.length;';
   l_string := l_string ||'        if ((document.DefaultFormName.dim6[d6_tmp].text == "'||l_blank||'") '||c_OR||' (document.DefaultFormName.dim6[d6_tmp].text == "'||c_choose||'"))  {';
   l_string := l_string ||'           d6 = "+";';
   l_string := l_string ||'           alert("'||l_choose_dim_value||'");';
   l_string := l_string ||'           document.DefaultFormName.dim6.focus();';
   l_string := l_string ||'           return FALSE;';
   l_string := l_string ||'           }';
   l_string := l_string ||'        else';
   l_string := l_string ||'           var d6 =  document.DefaultFormName.dim6[d6_tmp].value;';
   l_string := l_string ||'        }';
   l_string := l_string ||'     else';
   l_string := l_string ||'        {d6 = "-";}';

   --l_string := l_string ||' // mdamle 01/15/2001 - Use Dim6 and Dim7';
   --l_string := l_string ||'     // For dimension7';
   l_string := l_string ||'     if (document.DefaultFormName.dim7_level_id.value != "") {';
   l_string := l_string ||'        var d7_tmp = document.DefaultFormName.dim7.selectedIndex;';
   l_string := l_string ||'        var d7_end = document.DefaultFormName.dim7.length;';
   l_string := l_string ||'        if ((document.DefaultFormName.dim7[d7_tmp].text == "'||l_blank||'") '||c_OR||' (document.DefaultFormName.dim7[d7_tmp].text == "'||c_choose||'"))  {';
   l_string := l_string ||'           d7 = "+";';
   l_string := l_string ||'           alert("'||l_choose_dim_value||'");';
   l_string := l_string ||'           document.DefaultFormName.dim7.focus();';
   l_string := l_string ||'           return FALSE;';
   l_string := l_string ||'           }';
   l_string := l_string ||'        else';
   l_string := l_string ||'           var d7 =  document.DefaultFormName.dim7[d7_tmp].value;';
   l_string := l_string ||'        }';
   l_string := l_string ||'     else';
   l_string := l_string ||'        {d7 = "-";}';

   --l_string := l_string ||'     // For Plan';
   l_string := l_string ||'      var plan_tmp = document.DefaultFormName.plan.selectedIndex;';
   l_string := l_string ||'      var plan     = document.DefaultFormName.plan[plan_tmp].value;';

   l_string := l_string ||'     var totext=document.DefaultFormName.label.value;';
   l_string := l_string ||'if (document.DefaultFormName.orgDimension.value == "1")';
   l_string := l_string ||'  d1 = d0;';
   l_string := l_string ||'if (document.DefaultFormName.orgDimension.value == "2")';
   l_string := l_string ||'  d2 = d0;';
   l_string := l_string ||'if (document.DefaultFormName.orgDimension.value == "3")';
   l_string := l_string ||'  d3 = d0;';
   l_string := l_string ||'if (document.DefaultFormName.orgDimension.value == "4")';
   l_string := l_string ||'  d4 = d0;';
   l_string := l_string ||'if (document.DefaultFormName.orgDimension.value == "5")';
   l_string := l_string ||'  d5 = d0;';
   l_string := l_string ||'if (document.DefaultFormName.orgDimension.value == "6")';
   l_string := l_string ||'  d6 = d0;';
   l_string := l_string ||'if (document.DefaultFormName.orgDimension.value == "7")';
   l_string := l_string ||'   d7 = d0;';

   --l_string := l_string ||'// mdamle 01/15/2001 - Add d6 and d7';
   l_string := l_string ||' var tovalue= ind + "*" + d0 + "*" + d1 + "*" + d2 + "*" + d3 + "*" + d4 + "*" + d5 + "*" + d6 + "*" + d7 + "*" + plan;';
   l_string := l_string ||'     var end=document.DefaultFormName.C.length;';


   l_string := l_string ||'   var duplicated_val = 0;';
   l_string := l_string ||'   var duplicated_txt = 0;';
   l_string := l_string ||'   if (end > 0) {';
   l_string := l_string ||'     if (document.DefaultFormName.C.options[end-1].value =="") {';
   l_string := l_string ||'       end = end - 1;';
   l_string := l_string ||'     }';

   l_string := l_string ||'     for (var i=0;i<end;i++){';
   l_string := l_string ||'     var cvar = document.DefaultFormName.C[i].value;';

   l_string := l_string ||'     if (tovalue == cvar.substr(0, cvar.length -2 )) {';
   l_string := l_string ||'       duplicated_val = 1;';
   l_string := l_string ||'     }';
   l_string := l_string ||'     if (totext == document.DefaultFormName.C[i].text) {';
   l_string := l_string ||'       duplicated_txt = 1;';
   l_string := l_string ||'     }';
   l_string := l_string ||'   }  ';
   l_string := l_string ||'   if (duplicated_val == 1) {';
   l_string := l_string ||'     alert("'||l_dup_combo||'");';
   l_string := l_string ||'   } else if (duplicated_txt == 1) {';
   l_string := l_string ||'     alert("'||l_dup_displabel||'");';
   l_string := l_string ||'   }';

   l_string := l_string ||' }';
   l_string := l_string ||' if ( (duplicated_val == 0) && (duplicated_txt == 0) ) {';
   l_string := l_string ||'   document.DefaultFormName.C.options[end] = new Option(totext,tovalue+"*Y");';
   l_string := l_string ||'   document.DefaultFormName.C.selectedIndex = end;';
   l_string := l_string ||' }';


   l_string := l_string ||'}';
   l_string := l_string ||'}';


   WF_NOTIFICATION.WriteToClob(l_str_object,l_string);

     -- Function to move selections upwards
     -- meastmon 06/25/2001 Fix bug#1835495.
   l_string := 'function upTo() {';
   l_string := l_string ||'       var temp = document.DefaultFormName.C.selectedIndex;';
   l_string := l_string ||'       if (temp < 0)';
   l_string := l_string ||'          selectTo();';
   l_string := l_string ||'       else {';
   l_string := l_string ||'         if (temp > 0) {';
   l_string := l_string ||'           var text = document.DefaultFormName.C[temp-1].text;';
   l_string := l_string ||'           var val = document.DefaultFormName.C.options[temp-1].value;';
   l_string := l_string ||'           var totext = document.DefaultFormName.C[temp].text;';
   l_string := l_string ||'           var toval = document.DefaultFormName.C.options[temp].value;';

   l_string := l_string ||'           document.DefaultFormName.C[temp-1].text = totext;';
   l_string := l_string ||'           document.DefaultFormName.C.options[temp-1].value = toval;';
   l_string := l_string ||'           document.DefaultFormName.C[temp].text = text;';
   l_string := l_string ||'           document.DefaultFormName.C.options[temp].value = val;';
   l_string := l_string ||'           document.DefaultFormName.C.selectedIndex = temp-1;';
   l_string := l_string ||'         }';
   l_string := l_string ||'       }';

   l_string := l_string ||'     }';


   -- Function to move selections downwards
   -- meastmon 06/25/2001 Fix bug#1835495.
   l_string := l_string ||'function downTo() {';
   l_string := l_string ||'     var temp = document.DefaultFormName.C.selectedIndex;';
   l_string := l_string ||'     var end = document.DefaultFormName.C.length;';

   l_string := l_string ||'     if (temp < 0)';
   l_string := l_string ||'        selectTo();';
   l_string := l_string ||'     else {';
   l_string := l_string ||'       if (document.DefaultFormName.C.options[end-1].value == "")';
   l_string := l_string ||'         end = end - 1;';

   l_string := l_string ||'       if (temp < (end-1)) {';
   l_string := l_string ||'         var text = document.DefaultFormName.C[temp+1].text;';
   l_string := l_string ||'         var val = document.DefaultFormName.C.options[temp+1].value;';
   l_string := l_string ||'         var totext = document.DefaultFormName.C[temp].text;';
   l_string := l_string ||'         var toval = document.DefaultFormName.C.options[temp].value;';

   l_string := l_string ||'         document.DefaultFormName.C[temp+1].text = totext;';
   l_string := l_string ||'         document.DefaultFormName.C.options[temp+1].value = toval;';
   l_string := l_string ||'         document.DefaultFormName.C[temp].text = text;';
   l_string := l_string ||'         document.DefaultFormName.C.options[temp].value = val;';
   l_string := l_string ||'         document.DefaultFormName.C.selectedIndex = temp+1;';
   l_string := l_string ||'       }';
   l_string := l_string ||'     }';

   l_string := l_string ||'   }';


   l_string := l_string ||'function deleteTo() {';
   l_string := l_string ||'  var temp=document.DefaultFormName.C.selectedIndex;';
   l_string := l_string ||'   if (temp < 0)';
   l_string := l_string ||'     selectTo();';
   l_string := l_string ||'   else {';
   l_string := l_string ||'     if (confirm("'||BIS_UTILITIES_PVT.getPrompt('BIS_DELETE')||'" + " " + document.DefaultFormName.C.options[temp].text + "?"))';
   l_string := l_string ||'     document.DefaultFormName.C.options[temp] = null;';
   l_string := l_string ||'     };';
   l_string := l_string ||'  }';

   l_string := l_string ||'function open_new_browser(url,x,y){';
   l_string := l_string ||'    var attributes = "resizable=yes,scrollbars=yes,toolbar=no,width="+x+",height="+ y;';
   l_string := l_string ||'    var new_browser = window.open(url, "new_browser", attributes);';
   l_string := l_string ||'    if (new_browser != null) {';
   l_string := l_string ||'        if (new_browser.opener == null)';
   l_string := l_string ||'            new_browser.opener = self;';
   l_string := l_string ||'        window.name = ''favorite'';';
   l_string := l_string ||'        new_browser.location.href = url;';
   l_string := l_string ||'        }';
   l_string := l_string ||'    }';

   -- Function to Edit the Label
   -- meastmon 09/25/2001 Fix bug#1993005 There can be spaces in the dim level value id.
   -- We need to use escape() to encode the U parameter.
   l_string := l_string ||'function editTo() {';
   l_string := l_string ||'   var temp=document.DefaultFormName.C.selectedIndex;';
   l_string := l_string ||'   if (temp<0) {';
   l_string := l_string ||'      alert("'||l_select_displabel||'");';
   l_string := l_string ||'     }';
   l_string := l_string ||'   else {';
   l_string := l_string ||'    var cval = document.DefaultFormName.C[temp].value;';
   l_string := l_string ||' var c_access = cval.substr(cval.length-1, 1);';
   l_string := l_string ||' if (c_access == "N") {';
   l_string := l_string ||'  alert("'||l_un_auth||'.");';
   l_string := l_string ||' } else {';

   l_string := l_string ||' var url = getEditURL();';
   l_string := l_string ||' var today = new Date();';
   l_string := l_string ||' var expire = new Date();';
   l_string := l_string ||' expire.setTime(today.getTime() + 3600000*24);';
   l_string := l_string ||' document.cookie = "U="+escape(cval)+ ";expires="+expire.toGMTString();';
   l_string := l_string ||' document.cookie = "Z="+'||Z||'+ ";expires="+expire.toGMTString();';

   l_string := l_string ||' open_new_browser(url,600,450);';
   l_string := l_string ||'    }';
   l_string := l_string ||'  }';
   l_string := l_string ||'  }';

   --  Function to save the selected labels
   l_string := l_string ||' function savedimensions() {';
   l_string := l_string ||'   var end=document.DefaultFormName.C.length;';

   l_string := l_string ||'   for (var i=0; i<end; i++) { ';
   l_string := l_string ||'     if (document.DefaultFormName.C.options[i].value != "") {';
   l_string := l_string ||'     document.DefaultFormName.OK.value = "Y";';

   l_string := l_string ||' var sval = document.DefaultFormName.C.options[i].value;';
   l_string := l_string ||' var tval = sval.substr(0, sval.length-2);';
   l_string := l_string ||' document.DefaultFormName.p_displaylabels_tbl[i].value= tval + "*" + document.DefaultFormName.C.options[i].text;';
   l_string := l_string ||' }';
   l_string := l_string ||' }';
   l_string := l_string ||'     document.DefaultFormName.submit();';
   l_string := l_string ||'   }';

   l_string := l_string ||' function doCancel() {';
   l_string := l_string ||' document.DefaultFormName.DoCancel.value = "Y";';
   l_string := l_string ||' document.DefaultFormName.submit();';
   l_string := l_string ||' }';

   -- Function to set the indicator level and recreate the page
   l_string := l_string ||'function setIndlevel() {';
   l_string := l_string ||'   var end=document.DefaultFormName.C.length;';
   l_string := l_string ||'   for (var i=0;i < end;i++)';
   l_string := l_string ||'      if (document.DefaultFormName.C.options[i].value != "")';
   l_string := l_string ||'      document.DefaultFormName.p_displaylabels_tbl[i].value = document.DefaultFormName.C.options[i].value + "*" + document.DefaultFormName.C.options[i].text;';
   l_string := l_string ||'   var tmp = document.DefaultFormName.p_indlevel.selectedIndex;';
   l_string := l_string ||'   document.DefaultFormName.p_ind_level_id.value = document.DefaultFormName.p_indlevel[tmp].value;';

   l_string := l_string ||'   document.DefaultFormName.DoIndSubmit.value = "Y";';
   l_string := l_string ||'   document.DefaultFormName.submit();';
   l_string := l_string ||' }';

     -- Get string to clear dim1-5 in case they are related to the org
     --
   l_elements(1) := 'plan';
   l_elements(2) := 'dim0';
   l_elements(3) := 'label';
   l_elements(4) := 'C';

   clearSelect
   ( p_formName     => 'dimensions'
   , p_elementTable => l_elements
   , x_clearString  => l_clear
   );



   for i in p_selections_tbl.FIRST .. p_selections_tbl.COUNT loop
     if (p_selections_tbl(i) is NULL) then
       EXIT;
     end if;
     l_loc := instr(p_selections_tbl(i),'*',1,1);
     l_value := substr (p_selections_tbl(i),1,l_loc - 1);
     l_text := substr (p_selections_tbl(i),l_loc + 1);
     if v_ind_level_id is NULL then
        v_ind_level_id := TO_NUMBER(l_value);
     end if;
     for c_recs in bisfv_target_levels_cur(v_ind_level_id) loop
       l_dim1_lbl := c_recs.Dimension1_Level_Name;
       l_dim2_lbl := c_recs.Dimension2_Level_Name;
       l_dim3_lbl := c_recs.Dimension3_Level_Name;
       l_dim4_lbl := c_recs.Dimension4_Level_Name;
       l_dim5_lbl := c_recs.Dimension5_Level_Name;
       l_dim6_lbl := c_recs.Dimension6_Level_Name;
       l_dim7_lbl := c_recs.Dimension7_Level_Name;
       l_Org_Seq_Num := getOrgSeqNum(v_ind_level_id);

       if l_Org_Seq_Num = 1 then
             l_dim0_lbl := c_recs.Dimension1_Level_Name;
       elsif l_Org_Seq_Num = 2 then
             l_dim0_lbl := c_recs.Dimension2_Level_Name;
       elsif l_Org_Seq_Num = 3 then
               l_dim0_lbl := c_recs.Dimension3_Level_Name;
       elsif l_Org_Seq_Num = 4 then
               l_dim0_lbl := c_recs.Dimension4_Level_Name;
       elsif l_Org_Seq_Num = 5 then
               l_dim0_lbl := c_recs.Dimension5_Level_Name;
       elsif l_Org_Seq_Num = 6 then
               l_dim0_lbl := c_recs.Dimension6_Level_Name;
       elsif l_Org_Seq_Num = 7 then
               l_dim0_lbl := c_recs.Dimension7_Level_Name;
       end if;
     end loop;
   end loop;


   l_string := l_string ||'function setdim0() {';
   l_string := l_string ||'  var end = document.DefaultFormName.dim0.length;';
   l_string := l_string ||'  var temp = document.DefaultFormName.dim0.selectedIndex;';
   l_string := l_string ||'  if (document.DefaultFormName.dim0[temp].text == "'||c_choose||'") {';
   l_string := l_string ||'     var ind_tmp  = document.DefaultFormName.p_indlevel.selectedIndex;';
   l_string := l_string ||'     var ind    =   document.DefaultFormName.p_indlevel[ind_tmp].value;';
   l_string := l_string ||'     var dim_lvl_id = document.DefaultFormName.dim0_level_id.value;';
   l_string := l_string ||'     var c_qry = "'||l_user_id||c_asterisk||'" + ind + "'||c_asterisk||'" + dim_lvl_id;';
   l_string := l_string ||'     var c_jsfuncname = "getdim0";';
   l_string := l_string ||'     document.DefaultFormName.dim0.selectedIndex = 0;';
   --l_string := l_string ||'//modified for bug#2318543';
   l_string := l_string ||'       getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim0_lbl)||'");';
   l_string := l_string ||'     }';
   l_string := l_string ||' }';

   SetSetOfBookVar
   ( p_user_id     => l_user_id
   , p_formName    => 'DefaultFormName'
   , p_index       => 'dim0_index'
   , x_sobString   => l_sobString
   );

   l_string := l_string ||'function setdim1() {';
   --l_string := l_string ||'// alert("setdim1");';
   l_string := l_string ||'  var end = document.DefaultFormName.dim1.length;';
   l_string := l_string ||'  var temp = document.DefaultFormName.dim1.selectedIndex;';
   l_string := l_string ||'  if (document.DefaultFormName.dim1[temp].text == "'||c_choose||'") {';
   l_string := l_string ||'     var ind_tmp  = document.DefaultFormName.p_indlevel.selectedIndex;';
   l_string := l_string ||'     var ind    =   document.DefaultFormName.p_indlevel[ind_tmp].value;';
   l_string := l_string ||'     var dim_lvl_id = document.DefaultFormName.dim1_level_id.value;';

   --l_string := l_string ||'// mdamle 01/15/2001 - Moved conditional code into l_sobString';
   l_string := l_string ||'      '||l_sobString||'';

   l_string := l_string ||'      var c_jsfuncname = "getdim1";';
   l_string := l_string ||'      document.DefaultFormName.dim1.selectedIndex = 0;';

   --l_string := l_string ||'    //modified for bug#2318543';
   l_string := l_string ||'      getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim1_lbl)||'");';
   l_string := l_string ||'      }';
   l_string := l_string ||'  }';
   l_string := l_string ||'function setdim2() {';
   --l_string := l_string ||'// alert("setdim2");';
   l_string := l_string ||'   var end = document.DefaultFormName.dim2.length;';
   l_string := l_string ||'   var temp = document.DefaultFormName.dim2.selectedIndex;';
   l_string := l_string ||'   if (document.DefaultFormName.dim2[temp].text == "'||c_choose||'") {';
   l_string := l_string ||'      var ind_tmp  = document.DefaultFormName.p_indlevel.selectedIndex;';
   l_string := l_string ||'      var ind    =   document.DefaultFormName.p_indlevel[ind_tmp].value;';
   l_string := l_string ||'      var dim_lvl_id = document.DefaultFormName.dim2_level_id.value;';

   --l_string := l_string ||'// mdamle 01/15/2001 - Moved conditional code into l_sobString';
   l_string := l_string ||'      '||l_sobString||'';

   l_string := l_string ||'      var c_jsfuncname = "getdim2";';
   l_string := l_string ||'      document.DefaultFormName.dim2.selectedIndex = 0;';
   l_string := l_string ||'      getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim2_lbl)||'");';
   l_string := l_string ||'      }';
   l_string := l_string ||'  }';



   l_string := l_string ||'function setdim3() {';
   --l_string := l_string ||'// alert("setdim3");';
   l_string := l_string ||'   var end = document.DefaultFormName.dim3.length;';
   l_string := l_string ||'   var temp = document.DefaultFormName.dim3.selectedIndex;';
   l_string := l_string ||'   if (document.DefaultFormName.dim3[temp].text == "'||c_choose||'") {';
   l_string := l_string ||'      var ind_tmp  = document.DefaultFormName.p_indlevel.selectedIndex;';
   l_string := l_string ||'      var ind    =   document.DefaultFormName.p_indlevel[ind_tmp].value;';
   l_string := l_string ||'      var dim_lvl_id = document.DefaultFormName.dim3_level_id.value;';

   --l_string := l_string ||'// mdamle 01/15/2001 - Moved conditional code into l_sobString';
   l_string := l_string ||'      '||l_sobString||'';

   l_string := l_string ||'      var c_jsfuncname = "getdim3";';
   l_string := l_string ||'      document.DefaultFormName.dim3.selectedIndex = 0;';
   l_string := l_string ||'      getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim3_lbl)||'");';
   l_string := l_string ||'      }';
   l_string := l_string ||'  }';



   l_string := l_string ||'function setdim4() {';
   --l_string := l_string ||'// alert("setdim4");';
   l_string := l_string ||'   var end = document.DefaultFormName.dim4.length;';
   l_string := l_string ||'   var temp = document.DefaultFormName.dim4.selectedIndex;';
   l_string := l_string ||'   if (document.DefaultFormName.dim4[temp].text == "'||c_choose||'") {';
   l_string := l_string ||'      var ind_tmp  = document.DefaultFormName.p_indlevel.selectedIndex;';
   l_string := l_string ||'      var ind    =   document.DefaultFormName.p_indlevel[ind_tmp].value;';
   l_string := l_string ||'      var dim_lvl_id = document.DefaultFormName.dim4_level_id.value;';

   --l_string := l_string ||'// mdamle 01/15/2001 - Moved conditional code into l_sobString';
   l_string := l_string ||'      '||l_sobString||'';

   l_string := l_string ||'      var c_jsfuncname = "getdim4";';
   l_string := l_string ||'      document.DefaultFormName.dim4.selectedIndex = 0;';
   l_string := l_string ||'      getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim4_lbl)||'");';
   l_string := l_string ||'      }';
   l_string := l_string ||'  }';

   WF_NOTIFICATION.WriteToClob(l_str_object,l_string);



   l_string1 := '  function setdim5() {';
   --l_string1 := l_string1 ||'// alert("setdim5");';
   l_string1 := l_string1 ||'    var end = document.DefaultFormName.dim5.length;';
   l_string1 := l_string1 ||'    var temp = document.DefaultFormName.dim5.selectedIndex;';
   l_string1 := l_string1 ||'    if (document.DefaultFormName.dim5[temp].text == "'||c_choose||'") {';
   l_string1 := l_string1 ||'       var ind_tmp  = document.DefaultFormName.p_indlevel.selectedIndex;';
   l_string1 := l_string1 ||'       var ind    =   document.DefaultFormName.p_indlevel[ind_tmp].value;';
   l_string1 := l_string1 ||'       var dim_lvl_id = document.DefaultFormName.dim5_level_id.value;';

   --l_string1 := l_string1 ||' // mdamle 01/15/2001 - Moved conditional code into l_sobString';
   l_string1 := l_string1 ||'       '||l_sobString||'';

   l_string1 := l_string1 ||'       var c_jsfuncname = "getdim5";';
   l_string1 := l_string1 ||'       document.DefaultFormName.dim5.selectedIndex = 0;';
   l_string1 := l_string1 ||'       getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim5_lbl)||'");';
   l_string1 := l_string1 ||'       }';
   l_string1 := l_string1 ||'   }';

   -- mdamle 01/15/2001 - Use Dim6 and Dim7
   l_string1 := l_string1 ||'function setdim6() {';
   --l_string1 := l_string1 ||'// alert("setdim6");';
   l_string1 := l_string1 ||'         var end = document.DefaultFormName.dim6.length;';
   l_string1 := l_string1 ||'    var temp = document.DefaultFormName.dim6.selectedIndex;';
   l_string1 := l_string1 ||'    if (document.DefaultFormName.dim6[temp].text == "'||c_choose||'") {';
   l_string1 := l_string1 ||'       var ind_tmp  = document.DefaultFormName.p_indlevel.selectedIndex;';
   l_string1 := l_string1 ||'       var ind    =   document.DefaultFormName.p_indlevel[ind_tmp].value;';
   l_string1 := l_string1 ||'       var dim_lvl_id = document.DefaultFormName.dim6_level_id.value;';

   --l_string1 := l_string1 ||' // mdamle 01/15/2001 - Moved conditional code into l_sobString';
   l_string1 := l_string1 ||'       '||l_sobString||'';

   l_string1 := l_string1 ||'       var c_jsfuncname = "getdim6";';
   l_string1 := l_string1 ||'       document.DefaultFormName.dim6.selectedIndex = 0;';
   l_string1 := l_string1 ||'       getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim6_lbl)||'");';
   l_string1 := l_string1 ||'       }';
   l_string1 := l_string1 ||'   }';

   l_string1 := l_string1 ||'function setdim7() {';
   --l_string1 := l_string1 ||'// alert("setdim7");';
   l_string1 := l_string1 ||'   var end = document.DefaultFormName.dim7.length;';
   l_string1 := l_string1 ||'    var temp = document.DefaultFormName.dim7.selectedIndex;';
   l_string1 := l_string1 ||'    if (document.DefaultFormName.dim7[temp].text == "'||c_choose||'") {';
   l_string1 := l_string1 ||'       var ind_tmp  = document.DefaultFormName.p_indlevel.selectedIndex;';
   l_string1 := l_string1 ||'       var ind    =   document.DefaultFormName.p_indlevel[ind_tmp].value;';
   l_string1 := l_string1 ||'       var dim_lvl_id = document.DefaultFormName.dim7_level_id.value;';

   --l_string1 := l_string1 ||' // mdamle 01/15/2001 - Moved conditional code into l_sobString';
   l_string1 := l_string1 ||'       '||l_sobString||'';

   l_string1 := l_string1 ||'       var c_jsfuncname = "getdim7";';
   l_string1 := l_string1 ||'       document.DefaultFormName.dim7.selectedIndex = 0;';
   l_string1 := l_string1 ||'       getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||',"'||bis_utilities_pub.encode(l_dim7_lbl)||'");';
   l_string1 := l_string1 ||'       }';
   l_string1 := l_string1 ||'   }';


   l_string1 := l_string1 ||'</SCRIPT>';
   l_string1 := l_string1 ||'<!-- End of Javascript -->';


   -- ***************
   l_string1 := l_string1 ||'<!-- Paint the dummy form to grab the display labels -->';
    -- Dummy form to send selected labels to a procedure that inserts the
    -- display labels and dimlvl valss into the  BIS_USER_IND_SELECTIONS table

   l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="W" VALUE="">';

   l_string1 := l_string1 ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.Z.value='||Z||';';
   l_string1 := l_string1 ||'</SCRIPT>';
   l_string1 := l_string1 ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.p_back_url.value='''||p_back_url||''';';
   l_string1 := l_string1 ||'</SCRIPT>';
   l_string1 := l_string1 ||'<SCRIPT LANGUAGE="Javascript">document.DefaultFormName.p_reference_path.value='''||p_reference_path||''';';
   l_string1 := l_string1 ||'</SCRIPT>';

   l_string1 := l_string1 ||'<!-- Close the dummy form to grab the display labels -->';

   -- **************

   -- *************
   l_string1 := l_string1 ||'<!-- Begin Layout of boxes -->';
   l_string1 := l_string1 ||'<CENTER>';
   l_string1 := l_string1 ||'<!-- Begin Main table  -->';
    -- main
   l_string1 := l_string1 ||'<table width="100%" border=0 cellspacing=0 cellpadding=0>';
   l_string1 := l_string1 ||'<!-- Row 1 Main table  -->';
   l_string1 := l_string1 ||'<TR>';
   l_string1 := l_string1 ||'<td align="CENTER">';
   l_string1 := l_string1 ||'<!-- Begin Cell table to center all items except the ok-cancel buttons  -->';
   l_string1 := l_string1 ||'<table width="75%" border=0 cellspacing=0 cellpadding=0>';
   l_string1 := l_string1 ||'<!-- Begin Row 1 of cell table -->';
    -- Row one of Cell table
   l_string1 := l_string1 ||'<TR>';
   l_string1 := l_string1 ||'<td align="LEFT" valign="TOP">';
   l_string1 := l_string1 ||'<!-- Open table for left set of boxes -->';
     -- target level and dimensions boxes table
   l_string1 := l_string1 ||'<table border=0 cellspacing=0 cellpadding=0>';
   l_string1 := l_string1 ||'<TR>';

   IF(l_swan_enabled)THEN
    l_append_string := '<TD ALIGN="LEFT" class="x49">';
   ELSE
    l_append_string := '<TD ALIGN="LEFT">';
   END IF;


   l_string1 := l_string1 || l_append_string ||bis_utilities_pvt.escape_html(c_tarlevel)||'</TD>';
   l_string1 := l_string1 ||'</TR>';
   l_string1 := l_string1 ||'<!-- Row 2 Open for left side table -->';
   l_string1 := l_string1 ||'<TR>';
   l_string1 := l_string1 ||'<td align="LEFT" valign="TOP">';
     -- **********


     -- **********
     -- Open a form for indicator levels

   l_string1 := l_string1 ||'<!-- Open form to grab target levels for onchange event of tar level poplist -->';

      -- Create hidden values to grab selected labels into
   for i in 1 .. c_counter LOOP
     l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="p_displaylabels_tbl1" VALUE="">';
   end loop;


   l_string1 := l_string1 ||'<SCRIPT LANGUAGE="Javascript">';
   for i in p_selections_tbl.FIRST .. p_selections_tbl.COUNT loop
     if (p_selections_tbl(i) is NULL) then
       EXIT;
     end if;
     l_string1 := l_string1 ||'document.DefaultFormName.p_selections_tbl['||i||'-1].value='''||p_selections_tbl(i)||''';';
   end loop;
   l_string1 := l_string1 ||'</SCRIPT>';

   l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="Z1" VALUE="'||Z||'">';
   l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="p_back_url1" VALUE='||p_back_url||'>';
   l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="p_reference_path1" VALUE='||p_reference_path||'>';
   l_string1 := l_string1 ||'<SELECT NAME="p_indlevel" onChange="setIndlevel()">';

   for i in p_selections_tbl.FIRST .. p_selections_tbl.COUNT loop

     if (p_selections_tbl(i) is NULL) then
        EXIT;
     end if;
     l_loc := instr(p_selections_tbl(i),'*',1,1);
     l_value := substr (p_selections_tbl(i),1,l_loc - 1);
     l_text := substr (p_selections_tbl(i),l_loc + 1);
     if v_ind_level_id is NULL then
       v_ind_level_id := TO_NUMBER(l_value);
     end if;

     if l_value = TO_CHAR(v_ind_level_id) then
       l_string1 := l_string1 ||'<OPTION SELECTED VALUE='||bis_utilities_pvt.escape_html_input(l_value)||'>'||bis_utilities_pvt.escape_html_input(l_text);
     else
       l_string1 := l_string1 ||'<OPTION VALUE='||bis_utilities_pvt.escape_html_input(l_value)||'>'||bis_utilities_pvt.escape_html_input(l_text);
     end if;
   end loop;
   l_string1 := l_string1 ||'</SELECT>';

       -- Form close for indicator levels selection

   l_string1 := l_string1 ||'<!-- Close form for target levels poplist -->';
   l_string1 := l_string1 ||'</td>';
   l_string1 := l_string1 ||'</TR>';
   l_string1 := l_string1 ||'<TR>';

   l_string1 := l_string1 ||l_append_string||bis_utilities_pvt.escape_html(c_dim_and_plan)||'</TD>';
   l_string1 := l_string1 ||'</TR>';
   l_string1 := l_string1 ||'<!-- Open row for embedded dimensions boxes table -->';
   l_string1 := l_string1 ||'<TR>';
   l_string1 := l_string1 ||'<td align="LEFT" valign="TOP">';

   l_string1 := l_string1 ||'<!-- open table containing wireframe -->';
   -- target level and dimensions boxes table
   l_string1 := l_string1 ||'<table border=0 cellspacing=0 cellpadding=0>';
   l_string1 := l_string1 ||'<TR>';
   l_string1 := l_string1 ||'<td height=1 bgcolor=#000000 colspan=5>'||
          '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>';
   l_string1 := l_string1 ||'</TR>';
   l_string1 := l_string1 ||'<TR>';
   l_string1 := l_string1 ||'<!-- Begin left edge of wireframe and left separator -->';
   l_string1 := l_string1 ||'<td width=1 class="C_WIRE_FRAME_COLOR">'||
         '<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>';
   l_string1 := l_string1 ||'<td width=5></td>';


    -- ************************************
    -- Print out NOCOPY the main form

   l_string1 := l_string1 ||'<!-- Begin main form to display and grab the labels -->';

    -- Grab the individual dim_level_values chosen previously for
    -- this target_level_id, to populate respective dimension level poplists
   if (l_labels_tbl.COUNT <> 0) THEN
       l_cnt := 1;
       for i in l_labels_tbl.FIRST .. l_labels_tbl.COUNT LOOP
         if (l_labels_tbl(i).target_level_id = v_ind_level_id) THEN
       -- mdamle 01/15/2001 - Use Dim6 and Dim7

           --IF (l_labels_tbl(i).org_level_value_ID is NOT NULL) THEN
           --  l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).org_level_value_ID;
           --  l_orgs_tbl(l_cnt).name := l_labels_tbl(i).org_level_value_name;
           --END IF;

           -- mdamle 01/15/2001 - Use Dim6 and Dim7
           -- Get the Dimension No. for Org
       l_Org_Seq_Num := getOrgSeqNum(v_ind_level_id);

           IF (l_labels_tbl(i).dim1_level_value_id is NOT NULL) THEN
            l_dim1_tbl(l_cnt).id   := l_labels_tbl(i).dim1_level_value_id;
            l_dim1_tbl(l_cnt).name := l_labels_tbl(i).dim1_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 1 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim1_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim1_level_value_name;
      end if;
           END IF;
           IF (l_labels_tbl(i).dim2_level_value_id is NOT NULL) THEN
            l_dim2_tbl(l_cnt).id   := l_labels_tbl(i).dim2_level_value_id;
            l_dim2_tbl(l_cnt).name := l_labels_tbl(i).dim2_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 2 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim2_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim2_level_value_name;
      end if;
           END IF;
           IF (l_labels_tbl(i).dim3_level_value_id is NOT NULL) THEN
            l_dim3_tbl(l_cnt).id   := l_labels_tbl(i).dim3_level_value_id;
            l_dim3_tbl(l_cnt).name := l_labels_tbl(i).dim3_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 3 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim3_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim3_level_value_name;
      end if;
           END IF;
           IF (l_labels_tbl(i).dim4_level_value_id is NOT NULL) THEN
            l_dim4_tbl(l_cnt).id   := l_labels_tbl(i).dim4_level_value_id;
            l_dim4_tbl(l_cnt).name := l_labels_tbl(i).dim4_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 4 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim4_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim4_level_value_name;
      end if;
           END IF;
           IF (l_labels_tbl(i).dim5_level_value_id is NOT NULL) THEN
            l_dim5_tbl(l_cnt).id   := l_labels_tbl(i).dim5_level_value_id;
            l_dim5_tbl(l_cnt).name := l_labels_tbl(i).dim5_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 5 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim5_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim5_level_value_name;
      end if;
           END IF;
         -- mdamle 01/15/2001 - Use Dim6 and Dim7
           IF (l_labels_tbl(i).dim6_level_value_id is NOT NULL) THEN
            l_dim6_tbl(l_cnt).id   := l_labels_tbl(i).dim6_level_value_id;
            l_dim6_tbl(l_cnt).name := l_labels_tbl(i).dim6_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 6 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim6_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim6_level_value_name;
      end if;
           END IF;
       IF (l_labels_tbl(i).dim7_level_value_id is NOT NULL) THEN
            l_dim7_tbl(l_cnt).id   := l_labels_tbl(i).dim7_level_value_id;
            l_dim7_tbl(l_cnt).name := l_labels_tbl(i).dim7_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 7 then
             l_orgs_tbl(l_cnt).id   := l_labels_tbl(i).dim7_level_value_id;
             l_orgs_tbl(l_cnt).name := l_labels_tbl(i).dim7_level_value_name;
      end if;
           END IF;

       l_cnt := l_cnt + 1;
         END IF;
       END LOOP;
    END IF; -- if l_labels_tbl is not empty

   --Begin cell containing the embedded table of poplists
   l_string1 := l_string1 ||'<td align="CENTER">';

   l_string1 := l_string1 ||'<!-- Begin embedded table inside the wireframe containing the poplists -->';
    -- table containing the dimension_level names,boxes

   WF_NOTIFICATION.WriteToClob(l_str_object,l_string1);

   l_string1 := '<TABLE >';



    for c_recs in bisfv_target_levels_cur(v_ind_level_id) loop

     -- *************************************************************
     -- Start painting the dimension levels poplists
     -- If no dimension level for this ind level, put a hidden value
     -- to user later

      -- ******************************
      -- Dimension0 for Organization

      -- meastmon 05/11/2001
      l_Time_Seq_Num := getTimeSeqNum(v_ind_level_id);
      l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="timeDimension" VALUE='||l_Time_Seq_Num||'>';

      -- mdamle 01/15/2001 - Use Dim6 and Dim7
      -- Get the Dimension No. for Org
      l_Org_Seq_Num := getOrgSeqNum(v_ind_level_id);
      l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="orgDimension" VALUE='||l_Org_Seq_Num||'>';

    -- mdamle 01/15/2001 - Use Dim6 and Dim7
    if l_Org_Seq_Num = 1 then
       l_Org_Level_ID := c_recs.Dimension1_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension1_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension1_level_Name;
    end if;
    if l_Org_Seq_Num = 2 then
       l_Org_Level_ID := c_recs.Dimension2_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension2_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension2_level_Name;
    end if;
    if l_Org_Seq_Num = 3 then
       l_Org_Level_ID := c_recs.Dimension3_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension3_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension3_level_Name;
    end if;
    if l_Org_Seq_Num = 4 then
       l_Org_Level_ID := c_recs.Dimension4_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension4_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension4_level_Name;
    end if;
    if l_Org_Seq_Num = 5 then
       l_Org_Level_ID := c_recs.Dimension5_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension5_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension5_level_Name;
    end if;
    if l_Org_Seq_Num = 6 then
       l_Org_Level_ID := c_recs.Dimension6_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension6_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension6_level_Name;
    end if;
    if l_Org_Seq_Num = 7 then
       l_Org_Level_ID := c_recs.Dimension7_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension7_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension7_level_Name;
    end if;

      if (l_Org_Level_ID is NULL) then
        l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim0_level_id" VALUE='||l_blank||'>';
       -- mdamle 01/15/2001
        l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="set_sob" VALUE="FALSE">';
      elsif (l_Org_Level_Short_Name='TOTAL_ORGANIZATIONS') then
        l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim0_level_id" VALUE='||l_Org_Level_ID||'>';
        l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="set_sob" VALUE="FALSE">';
        l_string1 := l_string1 ||'<TR>';
        l_string1 := l_string1 ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(l_Org_Level_Name)||'</TD>';
        l_string1 := l_string1 ||'<td align="left">';
        l_string1 := l_string1 ||'<SELECT NAME="dim0">';
        l_string1 := l_string1 ||'<OPTION SELECTED VALUE="-1"'||'>'||bis_utilities_pvt.escape_html_input(LOWER(l_Org_Level_Short_Name));
        l_string1 := l_string1 ||'</SELECT>';
      else
        -- Print out NOCOPY label and input box for dimension0
        l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim0_level_id" VALUE='||l_Org_Level_ID||'>';

        -- Set flag to True if we need to pass the related sob info
        -- along
        --
        if (l_Org_Level_Short_Name='SET OF BOOKS') then
          l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="set_sob" VALUE="TRUE">';
        else
          l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="set_sob" VALUE="FALSE">';
        end if;

        l_string1 := l_string1 ||'<TR>';
        l_string1 := l_string1 ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(l_Org_Level_Name)||'</TD>';
        l_string1 := l_string1 ||'<td align="left">';
        l_string1 := l_string1 ||'<SELECT NAME="dim0" onchange="setdim0()">';
        l_string1 := l_string1 ||'<OPTION SELECTED VALUE="">'||bis_utilities_pvt.escape_html_input(l_blank);

        if (l_orgs_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_orgs_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d0_tbl);
          for i in 1 ..l_d0_tbl.COUNT LOOP
             exit when (l_d0_tbl(i).id is NULL);
             l_string1 := l_string1 ||'<OPTION VALUE='||bis_utilities_pvt.escape_html_input(l_d0_tbl(i).id)||'>'||bis_utilities_pvt.escape_html_input(l_d0_tbl(i).name);
          end loop;
        end if;
        l_string1 := l_string1 ||'<OPTION VALUE=>'||c_choose;
        l_string1 := l_string1 ||'</SELECT>';
        l_string1 := l_string1 ||'</td>';
        l_string1 := l_string1 ||'</TR>';
      end if;


      -- ***********************************
      -- Dimension1
    -- mdamle 01/15/2001 - Use Dim6 and Dim7
      -- meastmon 05/11/2001
      -- Dont show time dimension level
      if (c_recs.Dimension1_Level_ID is NULL) or (l_Org_Seq_Num = 1) or (l_Time_Seq_Num = 1) then
        if (l_Org_Seq_Num = 1) or (l_Time_Seq_Num = 1) then
          l_string1 := l_string1 || '<INPUT TYPE="hidden" NAME="dim1_level_id" VALUE=>';
        else
          l_string1 := l_string1 ||  '<INPUT TYPE="hidden" NAME="dim1_level_id" VALUE='||c_recs.Dimension1_Level_ID||'>';
        end if;
      else
      -- Print out NOCOPY label and input box for dimension1
        l_string1 :=  l_string1 || '<INPUT TYPE="hidden" NAME="dim1_level_id" VALUE='||c_recs.Dimension1_Level_ID||'>';
        l_string1 := l_string1 ||'<TR>';
        l_string1 := l_string1 ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension1_Level_Name)||'</TD>';
        l_string1 := l_string1 ||'<td align="left">';
        l_string1 := l_string1 ||'<SELECT NAME="dim1" onchange="setdim1()">';
        l_string1 := l_string1 ||'<OPTION SELECTED VALUE="">'||bis_utilities_pvt.escape_html_input(l_blank);


       if (l_dim1_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim1_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d1_tbl);
          for i in 1 ..l_d1_tbl.COUNT LOOP
             exit when (l_d1_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
            l_string1 := l_string1 ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_d1_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d1_tbl(i).name);
          end loop;
       end if;
       l_string1 := l_string1 ||'<OPTION VALUE=>'||c_choose;
       l_string1 := l_string1 ||'</SELECT>';
       l_string1 := l_string1 ||'</td>';
       l_string1 := l_string1 ||'</TR>';
      end if;

      -- *******************************************
      -- Dimension2
    -- mdamle 01/15/2001 - Use Dim6 and Dim
      -- meastmon 05/11/2001
      -- Dont show time dimension level
     if (c_recs.Dimension2_Level_ID is NULL) or (l_Org_Seq_Num = 2) or (l_Time_Seq_Num = 2) then
       if (l_Org_Seq_Num = 2) or (l_Time_Seq_Num = 2) then
         l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim2_level_id" VALUE=>';
       else
         l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim2_level_id" VALUE='||c_recs.Dimension2_Level_ID||'>';
       end if;
     else     -- Print out NOCOPY label and input box for dimension2
       l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim2_level_id" VALUE='||c_recs.Dimension2_Level_ID||'>';
       l_string1 := l_string1 ||'<TR>';
       l_string1 := l_string1 ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension2_Level_Name)||'</TD>';
       l_string1 := l_string1 ||'<td align="left">';
       l_string1 := l_string1 ||'<SELECT NAME="dim2" onchange="setdim2()">';
       l_string1 := l_string1 ||'<OPTION SELECTED VALUE="">'||bis_utilities_pvt.escape_html_input(l_blank);

       if (l_dim2_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim2_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d2_tbl);
          for i in 1 ..l_d2_tbl.COUNT LOOP
             exit when (l_d2_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             l_string1 := l_string1 ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_d2_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d2_tbl(i).name);
          end loop;
       end if;
       l_string1 := l_string1 ||'<OPTION VALUE=>'||c_choose;
       l_string1 := l_string1 ||'</SELECT>';
       l_string1 := l_string1 ||'</td>';
       l_string1 := l_string1 ||'</TR>';
      end if;

      -- *****************************************
      -- Dimension3
    -- mdamle 01/15/2001 - Use Dim6 and Dim
      -- meastmon 05/11/2001
      -- Dont show time dimension level
      if (c_recs.Dimension3_Level_ID is NULL) or (l_Org_Seq_Num = 3) or (l_Time_Seq_Num = 3) then
        if (l_Org_Seq_Num = 3) or (l_Time_Seq_Num = 3) then
          l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim3_level_id" VALUE=>';
        else
          l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim3_level_id" VALUE='||c_recs.Dimension3_Level_ID||'>';
        end if;
      else       -- Print out NOCOPY label and input box for dimension3
        l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim3_level_id" VALUE='||c_recs.Dimension3_Level_ID||'>';
        l_string1 := l_string1 ||'<TR>';
        l_string1 := l_string1 ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension3_Level_Name)||'</TD>';
        l_string1 := l_string1 ||'<td align="left">';
        l_string1 := l_string1 ||'<SELECT NAME="dim3" onchange="setdim3()">';
        l_string1 := l_string1 ||'<OPTION SELECTED VALUE="">'||bis_utilities_pvt.escape_html_input(l_blank);

      if (l_dim3_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim3_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d3_tbl);
          for i in 1 ..l_d3_tbl.COUNT LOOP
             exit when (l_d3_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
             l_string1 := l_string1 ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_d3_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d3_tbl(i).name);
          end loop;
       end if;
        l_string1 := l_string1 ||'<OPTION VALUE=>'||c_choose;
        l_string1 := l_string1 ||'</SELECT>';
        l_string1 := l_string1 ||'</td>';
        l_string1 := l_string1 ||'</TR>';
       end if;

      -- *****************************************
      -- Dimension4
    -- mdamle 01/15/2001 - Use Dim6 and Dim
      -- meastmon 05/11/2001
      -- Dont show time dimension level
      if (c_recs.Dimension4_Level_ID is NULL) or (l_Org_Seq_Num = 4) or (l_Time_Seq_Num = 4) then
        if (l_Org_Seq_Num = 4) or (l_Time_Seq_Num = 4) then
          l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim4_level_id" VALUE=>';
         else
           l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim4_level_id" VALUE='||c_recs.Dimension4_Level_ID||'>';
        end if;
      else       -- Print out NOCOPY label and input box for dimension4
       l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim4_level_id" VALUE='||c_recs.Dimension4_Level_ID||'>';
       l_string1 := l_string1 ||'<TR>';
       l_string1 := l_string1 ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension4_Level_Name)||'</TD>';
       l_string1 := l_string1 ||'<td align="left">';
       l_string1 := l_string1 ||'<SELECT NAME="dim4" onchange="setdim4()">';
       l_string1 := l_string1 ||'<OPTION SELECTED VALUE="">'||bis_utilities_pvt.escape_html_input(l_blank);
       if (l_dim4_tbl.COUNT <> 0) THEN
         removeDuplicates(p_original_tbl => l_dim4_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d4_tbl);
          for i in 1 ..l_d4_tbl.COUNT LOOP
             exit when (l_d4_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
            l_string1 := l_string1 ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_d4_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d4_tbl(i).name);
          end loop;
       end if;
       l_string1 := l_string1 ||'<OPTION VALUE=>'||c_choose;
       l_string1 := l_string1 ||'</SELECT>';
       l_string1 := l_string1 ||'</td>';
       l_string1 := l_string1 ||'</TR>';
      end if;

      -- ****************************************
      -- Dimension5
    -- mdamle 01/15/2001 - Use Dim6 and Dim
      -- meastmon 05/11/2001
      -- Dont show time dimension level
      if (c_recs.Dimension5_Level_ID is NULL) or (l_Org_Seq_Num = 5) or (l_Time_Seq_Num = 5) then
        if (l_Org_Seq_Num = 5) or (l_Time_Seq_Num = 5) then
          l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim5_level_id" VALUE=>';
        else
          l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim5_level_id" VALUE='||c_recs.Dimension5_Level_ID||'>';
        end if;
      else
       -- Print out NOCOPY label and input box for dimension5
       l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim5_level_id" VALUE='||c_recs.Dimension5_Level_ID||'>';
       l_string1 := l_string1 ||'<TR>';
       l_string1 := l_string1 ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension5_Level_Name)||'</TD>';
       l_string1 := l_string1 ||'<td align="left">';
       l_string1 := l_string1 ||'<SELECT NAME="dim5" onchange="setdim5()">';
       l_string1 := l_string1 ||'<OPTION SELECTED VALUE="">'||bis_utilities_pvt.escape_html_input(l_blank);
       if (l_dim5_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim5_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d5_tbl);
          for i in 1 ..l_d5_tbl.COUNT LOOP
             exit when (l_d5_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
           l_string1 := l_string1 ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_d5_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d5_tbl(i).name);
          end loop;
       end if;
       l_string1 := l_string1 ||'<OPTION VALUE=>'||c_choose;
       l_string1 := l_string1 ||'</SELECT>';
       l_string1 := l_string1 ||'</td>';
       l_string1 := l_string1 ||'</TR>';
      end if;

      -- ****************************************
      -- Dimension6
    -- mdamle 01/15/2001 - Use Dim6 and Dim
      -- meastmon 05/11/2001
      -- Dont show time dimension level
      if (c_recs.Dimension6_Level_ID is NULL) or (l_Org_Seq_Num = 6) or (l_Time_Seq_Num = 6) then
        if (l_Org_Seq_Num = 6) or (l_Time_Seq_Num = 6) then
          l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim6_level_id" VALUE=>';
        else
          l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim6_level_id" VALUE='||c_recs.Dimension6_Level_ID||'>';
        end if;
      else
       -- Print out NOCOPY label and input box for dimension6
       l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim6_level_id" VALUE='||c_recs.Dimension6_Level_ID||'>';
       l_string1 := l_string1 ||'<TR>';
       l_string1 := l_string1 ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension6_Level_Name)||'</TD>';
       l_string1 := l_string1 ||'<td align="left">';
       l_string1 := l_string1 ||'<SELECT NAME="dim6" onchange="setdim6()">';
       l_string1 := l_string1 ||'<OPTION SELECTED VALUE="">'||bis_utilities_pvt.escape_html_input(l_blank);
       if (l_dim6_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim6_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d6_tbl);
          for i in 1 ..l_d6_tbl.COUNT LOOP
             exit when (l_d6_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
               l_string1 := l_string1 ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_d6_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d6_tbl(i).name);
          end loop;
       end if;
       l_string1 := l_string1 ||'<OPTION VALUE=>'||c_choose;
       l_string1 := l_string1 ||'</SELECT>';
       l_string1 := l_string1 ||'</td>';
       l_string1 := l_string1 ||'</TR>';
      end if;

      -- ****************************************
      -- Dimension7
    -- mdamle 01/15/2001 - Use Dim6 and Dim
      -- meastmon 05/11/2001
      -- Dont show time dimension level
      if (c_recs.Dimension7_Level_ID is NULL) or (l_Org_Seq_Num = 7) or (l_Time_Seq_Num = 7) then
        if (l_Org_Seq_Num = 7) or (l_Time_Seq_Num = 7) then
          l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim7_level_id" VALUE=>';
        else
          l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim7_level_id" VALUE='||c_recs.Dimension7_Level_ID||'>';
        end if;
      else
       -- Print out NOCOPY label and input box for dimension7
       l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="dim7_level_id" VALUE='||c_recs.Dimension7_Level_ID||'>';
       l_string1 := l_string1 ||'<TR>';
       l_string1 := l_string1 ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension7_Level_Name)||'</TD>';
       l_string1 := l_string1 ||'<td align="left">';
       l_string1 := l_string1 ||'<SELECT NAME="dim7" onchange="setdim7()">';
       l_string1 := l_string1 ||'<OPTION SELECTED VALUE="">'||bis_utilities_pvt.escape_html_input(l_blank);
       if (l_dim7_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim7_tbl,
                           p_value        => NULL,
                           x_unique_tbl   => l_d7_tbl);
          for i in 1 ..l_d7_tbl.COUNT LOOP
             exit when (l_d7_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
            l_string1 := l_string1 ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_d7_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d7_tbl(i).name);
          end loop;
       end if;
       l_string1 := l_string1 ||'<OPTION VALUE=>'||c_choose;
       l_string1 := l_string1 ||'</SELECT>';
       l_string1 := l_string1 ||'</td>';
       l_string1 := l_string1 ||'</TR>';
       end if;
     end loop; -- end of loop of c_recs cursor

     l_string1 := l_string1 ||'<!-- Row open for Business Plan poplist -->';

     -- Have a poplist for the Business Plan
     l_string1 := l_string1 ||'<TR>';
     l_string1 := l_string1 ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_plan)||'</TD>';
     l_string1 := l_string1 ||'<td align="left">';
     l_string1 := l_string1 ||'<SELECT NAME="plan">';
     for pl in plan_cur loop
       l_string1 := l_string1 ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(pl.plan_id)||'">'||bis_utilities_pvt.escape_html_input(pl.name);
     end loop;
     l_string1 := l_string1 ||'</SELECT>';
     l_string1 := l_string1 ||'</td>';
     l_string1 := l_string1 ||'</TR>';
     l_string1 := l_string1 ||'<TR>';

     l_string1 := l_string1 ||'<!-- Horizontal line separating the poplists and the display label box -->';
     l_string1 := l_string1 ||'<td height=1 colspan=2 class="C_SEPARATOR_LINE" nowrap="YES">'||'<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>';
     l_string1 := l_string1 ||'</TR>';
     l_string1 := l_string1 ||'<TR>';
     l_string1 := l_string1 ||'<td align="left" colspan=2>';
     l_string1 := l_string1 || c_displabel;
     l_string1 := l_string1 || '</td>';
     l_string1 := l_string1 ||'</TR>';
     l_string1 := l_string1 ||'<TR>';
     l_string1 := l_string1 ||'<td colspan=2 valign="TOP" nowrap="YES">';
     l_string1 := l_string1 ||'<INPUT TYPE="text" NAME="label" SIZE="41" MAXLENGTH="40">';
     l_string1 := l_string1 ||'</td>';
     l_string1 := l_string1 ||'</TR>';

     l_string1 := l_string1 ||'<!-- Close embedded table containing the dim level poplists -->';
     -- close embedded table containing dim labels and input boxes
     l_string1 := l_string1 ||'</TABLE>';
     -- close cell with dim labels and input boxes
     l_string1 := l_string1 ||'</td>';
     l_string1 := l_string1 ||'<!-- Put the right side separator and right edge of wire frame box -->';
     l_string1 := l_string1 ||'<td width=5></td>';
     l_string1 := l_string1 ||'<td width=1 class="C_WIRE_FRAME_COLOR">'||'<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>';
     l_string1 := l_string1 ||'</TR>';
     l_string1 := l_string1 ||'<TR>';
     l_string1 := l_string1 ||'<!-- Put the bottom edge of wireframe box -->';
     l_string1 := l_string1 ||'<td height=1 class="C_WIRE_FRAME_COLOR" colspan=5>'||'<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>';
     l_string1 := l_string1 ||'</TR>';
     l_string1 := l_string1 ||'<!-- Close wireframe table -->';
     l_string1 := l_string1 ||'</TABLE>';
     l_string1 := l_string1 ||'</td>';
     l_string1 := l_string1 ||'</TR>';
     l_string1 := l_string1 ||'<TR>';
     l_string1 := l_string1 || '<td height=5></td>';
     l_string1 := l_string1 ||'</TR>';
     l_string1 := l_string1 ||'<TR>';
     l_string1 := l_string1 ||'<td align="CENTER" valign="TOP">';
     l_string1 := l_string1 ||'<table border=0 cellspacing=0 cellpadding=0 width=50%>';
     l_string1 := l_string1 ||'<TR>';
     -- cell containing the add button
     l_string1 := l_string1 ||'<td align="CENTER" valign="TOP">';

     WF_NOTIFICATION.WriteToClob(l_str_object,l_string1);

     --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
     --icx_plug_utilities.buttonBoth(c_display_homepage,'Javascript:addTo()');
     IF(l_swan_enabled)THEN
      l_button_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
     ELSE
      l_button_edge := BIS_UTILITIES_PVT.G_ROUND_EDGE;
     END IF;
     l_button_tbl(1).left_edge := l_button_edge;
     l_button_tbl(1).right_edge := l_button_edge;
     l_button_tbl(1).disabled := FND_API.G_FALSE;
     l_button_tbl(1).label := c_display_homepage;
     l_button_tbl(1).href := 'Javascript:addTo()';
     BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
     l_string1 := l_button_str;

     l_string1 := l_string1 ||'</td>';
     l_string1 := l_string1 ||'</TR>';
     l_string1 := l_string1 ||'</TABLE>';
     l_string1 := l_string1 ||'</td>';
     l_string1 := l_string1 ||'</TR>';
     l_string1 := l_string1 ||'<!-- Close left side table containing the dimension poplists -->';
     l_string1 := l_string1 ||'</TABLE>';
     l_string1 := l_string1 ||'</td>';

     -- **********************************************************************
     -- Put a separator to move the dimensions and selected boxes  apart
     l_string1 := l_string1 ||'<td><BR></td>';

     l_string1 := l_string1 ||'<!-- Open cell for Display labels box -->';
     -- open cell for right side box
     l_string1 := l_string1 ||'<td align="RIGHT" valign="TOP">';
     l_string1 := l_string1 ||'<table border=0 cellspacing=0 cellpadding=0 width=90%>';
     l_string1 := l_string1 ||'<TR>';
     IF(l_swan_enabled)THEN
       l_string1 := l_string1 || '<TD ALIGN="LEFT" class="x49" NOWRAP>'||bis_utilities_pvt.escape_html(c_tarlevels_homepage) ||'</TD>';
     ELSE
       l_string1 := l_string1 || '<TD ALIGN="LEFT" NOWRAP>'||bis_utilities_pvt.escape_html(c_tarlevels_homepage) ||'</TD>';
     END IF;
     l_string1 := l_string1 || '<TD><BR></TD>';
     l_string1 := l_string1 || '</TR>';
     l_string1 := l_string1 || '<TR>';
     l_string1 := l_string1 || '<td valign="TOP">';
     l_string1 := l_string1 ||'<SELECT NAME="C" SIZE=20>';
       -- If first time to this page, get favorites from database
     if (p_ind_level_id is NULL) then
       if (l_labels_tbl.COUNT = 0) THEN
         l_string1 := l_string1 ||'<OPTION VALUE=>'||l_initialize;
        else
          for i in l_labels_tbl.FIRST .. l_labels_tbl.COUNT loop
           -- mdamle 01/15/2001 - Use Dim6 and Dim7
           -- mdamle 01/15/2001 - Use Dim6 and Dim7
             l_Org_level_value_id := null;

           --meastmon 06/07/2001 - Bug.
           -- l_Org_Seq_Num should be initialized within the loop, because every loop
           -- it is a different target.
             l_Org_Seq_Num := getOrgSeqNum(l_labels_tbl(i).target_level_id);

              if l_Org_Seq_Num = 1 then
                     l_Org_Level_Value_ID := l_labels_tbl(i).dim1_level_value_id;
              end if;
              if l_Org_Seq_Num = 2 then
                     l_Org_Level_Value_ID := l_labels_tbl(i).dim2_level_value_id;
              end if;
              if l_Org_Seq_Num = 3 then
                     l_Org_Level_Value_ID := l_labels_tbl(i).dim3_level_value_id;
              end if;
              if l_Org_Seq_Num = 4 then
                       l_Org_Level_Value_ID := l_labels_tbl(i).dim4_level_value_id;
              end if;
              if l_Org_Seq_Num = 5 then
                       l_Org_Level_Value_ID := l_labels_tbl(i).dim5_level_value_id;
              end if;
              if l_Org_Seq_Num = 6 then
                       l_Org_Level_Value_ID := l_labels_tbl(i).dim6_level_value_id;
              end if;
              if l_Org_Seq_Num = 7 then
                       l_Org_Level_Value_ID := l_labels_tbl(i).dim7_level_value_id;
              end if;

             --meastmon 06/08/2001
             -- Dont need to put time level value id
             l_Time_Seq_Num := getTimeSeqNum(l_labels_tbl(i).target_level_id);

            --  mdamle 01/15/2001 - Replace plus in data with c_hash
             -- The browser converts plus into space - and incorrect data is passed through
            l_link := l_labels_tbl(i).target_level_id||
                    '*'||NVL(l_org_level_value_id,'+1');
            IF l_Time_Seq_Num = 1 THEN
                l_link := l_link||'*+1';
            ELSE
                l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM1_LEVEL_VALUE_ID,'+1');
            END IF;
            IF l_Time_Seq_Num = 2 THEN
                l_link := l_link||'*+1';
            ELSE
                l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM2_LEVEL_VALUE_ID,'+1');
            END IF;
            IF l_Time_Seq_Num = 3 THEN
                l_link := l_link||'*+1';
            ELSE
                l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM3_LEVEL_VALUE_ID,'+1');
            END IF;
            IF l_Time_Seq_Num = 4 THEN
                l_link := l_link||'*+1';
            ELSE
                l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM4_LEVEL_VALUE_ID,'+1');
            END IF;
            IF l_Time_Seq_Num = 5 THEN
                l_link := l_link||'*+1';
            ELSE
                l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM5_LEVEL_VALUE_ID,'+1');
            END IF;
            IF l_Time_Seq_Num = 6 THEN
                l_link := l_link||'*+1';
            ELSE
                l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM6_LEVEL_VALUE_ID,'+1');
            END IF;
            IF l_Time_Seq_Num = 7 THEN
                l_link := l_link||'*+1';
            ELSE
                l_link := l_link||'*'||NVL(l_labels_tbl(i).DIM7_LEVEL_VALUE_ID,'+1');
            END IF;
            l_link := l_link||'*'||NVL(l_labels_tbl(i).PLAN_ID,'+1');

            IF (BIS_PMF_PORTLET_UTIL.is_authorized(
                  p_cur_user_id => g_user_id
                 ,p_target_level_id => l_labels_tbl(i).target_level_id) ) THEN
               l_access := '*Y';
             ELSE
                             l_access := '*N';
             END IF;

       -- mdamle 01/15/2001 - Added quotes around the VALUE
           l_string1 := l_string1 ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(REPLACE(REPLACE(l_link,'+1',c_minus),'+',c_at))||bis_utilities_pvt.escape_html_input(l_access)||'">';
           l_string1 := l_string1 ||bis_utilities_pvt.escape_html_input(l_labels_tbl(i).label);

           end LOOP;
          end if; -- if l_labels_tbl is empty

        else
          -- Else get the favorites stored in the plsql table
          for i in  1 .. p_displaylabels_tbl.COUNT LOOP
             l_loc := instr(p_displaylabels_tbl(i),'*',-1,1);
             l_value := substr (p_displaylabels_tbl(i),1,l_loc - 1);
             l_text := substr (p_displaylabels_tbl(i),l_loc + 1);


             IF ( (instr(l_value, '*Y', -1, 1 ) = 0) AND (instr(l_value, '*N', -1, 1 ) = 0)) THEN
                  l_value := l_value || '*Y';  -- first time added
             END IF;
             -- mdamle 01/15/2001 - Added quotes around the VALUE
             l_string1 := l_string1 ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_value)||'">'||bis_utilities_pvt.escape_html_input(l_text);
             exit when p_displaylabels_tbl(i) is NULL;
           end LOOP;
        end if;    -- endif for checking if p_ind_level_id is null or not

      l_string1 := l_string1 ||'</SELECT>';
      l_string1 := l_string1 ||'</td>';
      l_string1 := l_string1 ||'<!-- Open cell for up down buttons -->';
      l_string1 := l_string1 ||'<td align="LEFT">';  -- open cell for up down buttons
      l_string1 := l_string1 ||'<TABLE >';
      l_string1 := l_string1 ||'<tr><td align="left" valign="bottom">';

      IF(l_swan_enabled)THEN
       l_string1 := l_string1 ||'<A HREF="javascript:upTo()" onMouseOver="window.status='''||BIS_UTILITIES_PVT.getPrompt('BIS_UP')||''';return true"><image src="/OA_MEDIA/BISMOVUP.gif" alt="';
      ELSE
       l_string1 := l_string1 ||'<A HREF="javascript:upTo()" onMouseOver="window.status='''||BIS_UTILITIES_PVT.getPrompt('BIS_UP')||''';return true"><image src="/OA_MEDIA/FNDUPARW.gif" alt="';
      END IF;

      l_string1 := l_string1 ||icx_util.replace_alt_quotes(BIS_UTILITIES_PVT.getPrompt('BIS_UP'))||'" BORDER="0"></A>';
      l_string1 := l_string1 ||'</td></tr>';
      l_string1 := l_string1 ||'<tr><td align="left" valign="top">';
      IF(l_swan_enabled)THEN
       l_string1 := l_string1 ||'<A HREF="javascript:downTo()" onMouseOver="window.status='''||BIS_UTILITIES_PVT.getPrompt('BIS_DOWN')||''';return true"><image src="/OA_MEDIA/BISMOVDN.gif" alt="';
      ELSE
       l_string1 := l_string1 ||'<A HREF="javascript:downTo()" onMouseOver="window.status='''||BIS_UTILITIES_PVT.getPrompt('BIS_DOWN')||''';return true"><image src="/OA_MEDIA/FNDDNARW.gif" alt="';
      END IF;
      l_string1 := l_string1 ||icx_util.replace_alt_quotes(BIS_UTILITIES_PVT.getPrompt('BIS_DOWN'))||'" BORDER="0"></A>';
      l_string1 := l_string1 ||'</td></tr>';
      l_string1 := l_string1 ||'</TABLE>';
      l_string1 := l_string1 ||'</td>';
      l_string1 := l_string1 || '</TR>';
      l_string1 := l_string1 || '<!-- Open third row with edit-delete buttons for right side box -->';
      l_string1 := l_string1 || '<TR>';
      l_string1 := l_string1 || '<td align="CENTER" valign="TOP">';
      l_string1 := l_string1 || '<!-- Open embedded table having buttons -->';
      l_string1 := l_string1 ||'<TABLE>';
      l_string1 := l_string1 ||'<tr><td align="right" nowrap="Yes">';

      --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
      --icx_plug_utilities.buttonBoth(
      --                   BIS_UTILITIES_PVT.getPrompt('BIS_EDIT')
      --                  ,'Javascript:editTo()');
      l_button_tbl(1).left_edge := l_button_edge;
      l_button_tbl(1).right_edge := l_button_edge;
      l_button_tbl(1).disabled := FND_API.G_FALSE;
      l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_EDIT');
      l_button_tbl(1).href := 'Javascript:editTo()';
      BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
      l_string1 := l_string1 ||l_button_str;

      l_string1 := l_string1 ||'</td>';
      l_string1 := l_string1 ||'<td align="left" nowrap="Yes">';

      --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
      --icx_plug_utilities.buttonBoth(
      --                   BIS_UTILITIES_PVT.getPrompt('BIS_DELETE')
      --                   ,'Javascript:deleteTo()');
      l_button_tbl(1).left_edge := l_button_edge;
      l_button_tbl(1).right_edge := l_button_edge;
      l_button_tbl(1).disabled := FND_API.G_FALSE;
      l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_DELETE');
      l_button_tbl(1).href := 'Javascript:deleteTo()';
      BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
      l_string1 := l_string1 ||l_button_str;
      l_string1 := l_string1 ||'</td></tr>';
      l_string1 := l_string1 ||'</TABLE>';
      l_string1 := l_string1 ||'</td>';
      l_string1 := l_string1 ||'<td><BR></td>';
      l_string1 := l_string1 || '</TR>';
      l_string1 := l_string1 ||'</TABLE>';
      l_string1 := l_string1 ||'</td>';  -- close right side cell containing favorites and arrow buttons
      l_string1 := l_string1 ||'<!-- Close row for cell table containing the boxes -->';
      l_string1 := l_string1 || '</TR>';
      l_string1 := l_string1 || '<TR>';
      l_string1 := l_string1 || '<td colspan=2><BR></td>';
      l_string1 := l_string1 || '</TR>';
      l_string1 := l_string1 || '<TR>';
      l_string1 := l_string1 || '<td height=1 colspan=3 bgcolor=#000000>'||'<IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>';
      l_string1 := l_string1 || '</TR>';

      l_string1 := l_string1 ||'<!-- Close cell table containing the boxes -->';
      l_string1 := l_string1 ||'</TABLE>';
      l_string1 := l_string1 || '</td>';
      l_string1 := l_string1 ||'<!-- Close row 1 of main -->';
      l_string1 := l_string1 || '</TR>';
      l_string1 := l_string1 || '<TR>';
      l_string1 := l_string1 || '<td><BR></td>';
      l_string1 := l_string1 || '</TR>';

      l_string1 := l_string1 || '<!-- Open row with table containing the ok and cancel buttons -->';
      l_string1 := l_string1 || '<TR>';
      l_string1 := l_string1 || '<td align="CENTER">';
      --meastmon 06/20/2001. Added valign attribute
      l_string1 := l_string1 ||'<table width="100%"><tr><td width=50% align="right" valign="top">'; -- ok

      --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
      --icx_plug_utilities.buttonLeft(BIS_UTILITIES_PVT.getPrompt('BIS_OK'),
      --                             'Javascript:savedimensions()');
      l_button_tbl(1).left_edge := l_button_edge;
      l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
      l_button_tbl(1).disabled := FND_API.G_FALSE;
      l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_OK');
      l_button_tbl(1).href := 'Javascript:savedimensions()';
      BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
      l_string1 := l_string1 ||l_button_str;

      l_string1 := l_string1 ||'<!-- Close Main form to save the display lables -->';
      --meastmon 06/20/2001. Added valign attribute
      l_string1 := l_string1 ||'</td><td align="left" valign="top" width="50%">';
      l_string1 := l_string1 ||'<!-- Open form to do work of going to prev page  -->';

      l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="Z2" VALUE="'||Z||'">';
      l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="p_back_url2" VALUE="'||p_back_url||'">';
      l_string1 := l_string1 ||'<INPUT TYPE="hidden" NAME="p_reference_path2" VALUE="'||p_reference_path||'">';

      --meastmon 06/20/2001. This should not be here

      l_string1 := l_string1 ||'<!-- Close form to do work of going to prev page  -->';
      --l_string1 := l_string1 ||'</FORM>';

      --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
      --icx_plug_utilities.buttonRight(BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL'),
      --                              'Javascript:document.actionback.submit()');
      l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
      l_button_tbl(1).right_edge := l_button_edge;
      l_button_tbl(1).disabled := FND_API.G_FALSE;
      l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL');
      l_button_tbl(1).href := 'Javascript:doCancel()';
      --l_button_tbl(1).href := 'Javascript:document.actionback.submit()';
      BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
      l_string1 := l_string1 ||l_button_str;
      l_string1 := l_string1 ||'</td></tr>';
      l_string1 := l_string1 ||'</table>';
      l_string1 := l_string1 ||'</td>';
      l_string1 := l_string1 || '</TR>';
      l_string1 := l_string1 ||'<!-- Close Main Table -->';
      l_string1 := l_string1 ||'</TABLE>';
      l_string1 := l_string1 ||'</CENTER>';
      l_string1 := l_string1 ||'</BODY>';
      l_string1 := l_string1 ||'</HTML>';

      WF_NOTIFICATION.WriteToClob(l_str_object,l_string1);

      x_str_object := l_str_object;
-- end if; -- icx_validatePlugsession
--end if; -- icx_validateSession

exception
  when others then --htp.p(SQLERRM);
    --x_string1 := SQLERRM;
    --x_string2 := NULL;
    WF_NOTIFICATION.NewClob(l_str_object,SQLERRM);
    x_str_object := l_str_object;


end showDimensions;


-- ********************************************************
-- Procedure that allows Editing/renaming of indicators
-- *********************************************************

procedure editDimensions( U   in    varchar2
                         ,Z   in    pls_integer
                         ,x_string  out nocopy varchar2)
is
  V                      varchar2(32000);
  l_cnt                  pls_integer;
  l_plug_id              pls_integer;
  l_choose_dim_value     varchar2(32000);
  l_enter_displabel      varchar2(32000);
  l_select_displabel     varchar2(32000);
  l_dup_displabel        varchar2(32000);
  l_dup_combo            varchar2(32000);
  l_title                varchar2(32000);
  l_blank                varchar2(32000);
  l_initialize           varchar2(32000);
  l_length               pls_integer;
  l_indlevel_id          pls_integer;
  l_d0                   varchar2(32000);
  l_d1                   varchar2(32000);
  l_d2                   varchar2(32000);
  l_d3                   varchar2(32000);
  l_d4                   varchar2(32000);
  l_d5                   varchar2(32000);
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_d6                   varchar2(32000);
  l_d7                   varchar2(32000);

  l_plan                 varchar2(32000);
  l_plan1                 varchar2(32000);
  l_plan_name            varchar2(32000);
  l_indlevel_name        varchar2(32000);
  l_orgname              varchar2(32000);
  l_label                varchar2(32000);
  l_point1               pls_integer;
  l_point2               pls_integer;
  l_point3               pls_integer;
  l_point4               pls_integer;
  l_point5               pls_integer;
  l_point6               pls_integer;
  l_point7               pls_integer;
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_point8               pls_integer;
  l_point9               pls_integer;
  l_point10              pls_integer;

  l_point12              pls_integer;
  l_point23              pls_integer;
  l_message              varchar2(32000);
  l_message1             varchar2(32000);

  l_current_user_id          PLS_INTEGER;
  l_user_id                  PLS_INTEGER;
  l_owner_user_id            PLS_INTEGER;
--
  l_msg_count              number;
  l_msg_data               varchar2(32000);
  l_return_status          varchar2(32000);
  l_indicators_tbl         BIS_TARGET_LEVEL_PUB.Target_Level_Tbl_Type;
  l_dim0_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim1_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim2_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim3_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim4_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim5_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_dim6_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_dim7_level_value_rec   BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;

  l_favorites_tbl          BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;
  l_orgs_tbl               no_duplicates_tbl_Type;
  l_dim1_tbl               no_duplicates_tbl_Type;
  l_dim2_tbl               no_duplicates_tbl_Type;
  l_dim3_tbl               no_duplicates_tbl_Type;
  l_dim4_tbl               no_duplicates_tbl_Type;
  l_dim5_tbl               no_duplicates_tbl_Type;
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_dim6_tbl               no_duplicates_tbl_Type;
  l_dim7_tbl               no_duplicates_tbl_Type;

  l_d0_tbl                 no_duplicates_tbl_Type;
  l_d1_tbl                 no_duplicates_tbl_Type;
  l_d2_tbl                 no_duplicates_tbl_Type;
  l_d3_tbl                 no_duplicates_tbl_Type;
  l_d4_tbl                 no_duplicates_tbl_Type;
  l_d5_tbl                 no_duplicates_tbl_Type;
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_d6_tbl                 no_duplicates_tbl_Type;
  l_d7_tbl                 no_duplicates_tbl_Type;

  l_d0_name                varchar2(32000);
  l_d1_name                varchar2(32000);
  l_d2_name                varchar2(32000);
  l_d3_name                varchar2(32000);
  l_d4_name                varchar2(32000);
  l_d5_name                varchar2(32000);

  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_d6_name                varchar2(32000);
  l_d7_name                varchar2(32000);

  -- meastmon 05/11/2001
  l_Time_Seq_Num              number;
  --
  l_Org_Seq_Num              number;
  l_Org_Level_Value_ID       number;
  l_Org_Level_Short_Name     varchar2(240);
  l_Org_Level_Name           bis_levels_tl.name%TYPE;

  l_error_tbl              BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_clear                  VARCHAR2(32000);
  l_sobString              VARCHAR2(32000);
  l_sob_level_id           NUMBER;
  l_org_level_id           NUMBER;
  l_elements               BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;

  -- meastmon 06/20/2001
  -- Fix for ADA buttons
  l_button_str             varchar2(32000);
  l_button_tbl             BIS_UTILITIES_PVT.HTML_Button_Tbl_Type;
  l_set_of_books_id        VARCHAR2(200);

  l_dim_level_value_rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_string                 VARCHAR2(32000);
  l_lovstring              VARCHAR2(32000);



CURSOR plan_cur is
 SELECT plan_id,short_name,name
 FROM BISBV_BUSINESS_PLANS
 ORDER BY name;

-- mdamle 01/15/2001 - Use Dim6 and Dim7
cursor bisfv_target_levels_cur(p_tarid in pls_integer) is
 SELECT TARGET_LEVEL_ID,
        TARGET_LEVEL_NAME,
    -- mdamle 01/15/2001 - Use Dim6 and Dim7
        -- ORG_LEVEL_ID,
        -- ORG_LEVEL_SHORT_NAME,
        -- ORG_LEVEL_NAME,
        DIMENSION1_LEVEL_ID,
    DIMENSION1_LEVEL_SHORT_NAME,
        DIMENSION1_LEVEL_NAME,
        DIMENSION2_LEVEL_ID,
    DIMENSION2_LEVEL_SHORT_NAME,
        DIMENSION2_LEVEL_NAME,
        DIMENSION3_LEVEL_ID,
    DIMENSION3_LEVEL_SHORT_NAME,
        DIMENSION3_LEVEL_NAME,
        DIMENSION4_LEVEL_ID,
    DIMENSION4_LEVEL_SHORT_NAME,
        DIMENSION4_LEVEL_NAME,
        DIMENSION5_LEVEL_ID,
    DIMENSION5_LEVEL_SHORT_NAME,
        DIMENSION5_LEVEL_NAME,
        DIMENSION6_LEVEL_ID,
    DIMENSION6_LEVEL_SHORT_NAME,
        DIMENSION6_LEVEL_NAME,
        DIMENSION7_LEVEL_ID,
    DIMENSION7_LEVEL_SHORT_NAME,
        DIMENSION7_LEVEL_NAME
 FROM BISFV_TARGET_LEVELS
 WHERE TARGET_LEVEL_ID = p_tarid;

 l_append_string          VARCHAR2(1000);
 l_swan_enabled           BOOLEAN;
 l_button_edge            VARCHAR2(100);

BEGIN

-- meastmon 09/07/2001 Fix bug#1980577. Workaround Do not encrypt plug_id
l_plug_id := Z;
l_swan_enabled := BIS_UTILITIES_PVT.checkSWANEnabled();

--l_plug_id := icx_call.decrypt2(Z);

--if icx_sec.validateSession  then
-- if ICX_SEC.validatePlugSession(l_plug_id) then

    --g_user_id    := icx_sec.getID(icx_sec.PV_USER_ID, '', icx_sec.g_session_id); --2751984
    l_user_id    := icx_sec.getID(icx_sec.PV_USER_ID, '', icx_sec.g_session_id); --2751984
    l_blank      := '';
    l_message    := 'Please enter a display label';
    l_initialize := '1234567891234567890';


    -- Replace the plus signs from the string
    -- mdamle 01/15/2001 -
  -- 1) Replace @ with plus (actual data plus)
  -- 2) Using c_hash instead of c_plus everywhere bec. data could contain c_plus
    V := REPLACE(U, c_at, c_plus);
    V := REPLACE(V,' ',c_hash);


  -- Set the message strings from the database
  fnd_message.set_name('BIS','BIS_ENTER_DISPLABEL');
   l_enter_displabel := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_SELECT_DISPLABEL');
   l_select_displabel := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_DUP_DISPLABEL');
   l_dup_displabel := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_DUP_COMBO');
   l_dup_combo := icx_util.replace_quotes(fnd_message.get);
  fnd_message.set_name('BIS','BIS_CHOOSE_DIM_VALUE');
   l_choose_dim_value := icx_util.replace_quotes(fnd_message.get);

  -- Unpack the one element that was selected for edit from the Favorites box
  -- to obtain individual dim_level_value id's
    l_length := length(V);
    l_point1 := instr(V,'*',1,1);
    l_point2 := instr(V,'*',1,2);
    l_point3 := instr(V,'*',1,3);
    l_point4 := instr(V,'*',1,4);
    l_point5 := instr(V,'*',1,5);
    l_point6 := instr(V,'*',1,6);
    l_point7 := instr(V,'*',1,7);
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_point8 := instr(V,'*',1,8);
  l_point9 := instr(V,'*',1,9);
  l_point10 := instr(V,'*',1,10);

    l_indlevel_id := substr(V,1,l_point1-1);

  -- mdamle 01/15/2001 - Use Dim6 and Dim7
    l_d0 := substr(V,l_point1+1,l_point2 - l_point1 - 1);
    l_d1 := substr(V,l_point2+1,l_point3 - l_point2 - 1);
    l_d2 := substr(V,l_point3+1,l_point4 - l_point3 - 1);
    l_d3 := substr(V,l_point4+1,l_point5 - l_point4 - 1);
    l_d4 := substr(V,l_point5+1,l_point6 - l_point5 - 1);
    l_d5 := substr(V,l_point6+1,l_point7 - l_point6 - 1);
    l_d6 := substr(V,l_point7+1,l_point8 - l_point7 - 1);
    l_d7 := substr(V,l_point8+1,l_point9 - l_point8 - 1);
    --l_plan := substr(V,l_point9+1);
    l_plan := substr(V,l_point9+1,l_point10 - l_point9 - 1);

    g_var1 := l_d0;

  -- ************** Debug stuff ****************************
  -- htp.p(l_indlevel_id||'*'||l_d0||'*'||l_d1||'*'||l_d2||'*'||
  --       l_d3||'*'||l_d4||'*'||l_d5||'*'||l_plan);
  -- htp.p('<BR>*****************************************************<BR>');

  -- Get all the previously selected labels from
  -- selections table.
  BIS_INDICATOR_REGION_PUB.Retrieve_User_Ind_Selections
  ( p_api_version          => 1.0
  , p_user_id              => l_user_id
  , p_all_info             => FND_API.G_TRUE
  , p_plug_id              => l_plug_id
  , x_Indicator_Region_Tbl => l_favorites_tbl
  , x_return_status        => l_return_status
  , x_Error_Tbl           => l_error_tbl
  );

 -- Grab the Target level Name for this target level id
 -- to paint at the top of the page
 -- mdamle 01/15/2001 - Use getPerformanceMeasureName() instead
 --  SELECT target_level_name
 --  INTO l_indlevel_name
 --  FROM BISBV_TARGET_LEVELS
 --  WHERE TARGET_LEVEL_ID = l_indlevel_id;
 l_indlevel_name := getPerformanceMeasureName(l_indlevel_id);

 -- Set the set of books id for GL dimension levels
 --
   SELECT level_id
   INTO l_sob_level_id
   FROM BIS_LEVELS
   WHERE SHORT_NAME = 'SET OF BOOKS';

   -- mdamle 01/15/2001 - Use Dim6 and Dim7
   l_org_level_id := getOrgLevelID(l_indlevel_id);

   IF l_sob_level_id = l_org_level_ID
   THEN
     BIS_TARGET_PVT.G_SET_OF_BOOK_ID := TO_NUMBER(g_var1);
   END IF;

  -- Grab the individual dim_level_values chosen previously for
  -- this target_level_id, to populate respective poplists
    if (l_favorites_tbl.COUNT <> 0) THEN
       l_cnt := 1;
       for i in l_favorites_tbl.FIRST .. l_favorites_tbl.COUNT LOOP
         if (l_favorites_tbl(i).target_level_id = l_indlevel_id) THEN
       -- mdamle 01/15/2001 - Use Dim6 and Dim7
           -- mdamle 01/15/2001 - Use Dim6 and Dim7
           -- Get the Dimension No. for Org
       l_Org_Seq_Num := getOrgSeqNum(l_indlevel_id);

           IF (l_favorites_tbl(i).dim1_level_value_id is NOT NULL) THEN
            l_dim1_tbl(l_cnt).id   := l_favorites_tbl(i).dim1_level_value_id;
            l_dim1_tbl(l_cnt).name := l_favorites_tbl(i).dim1_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 1 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim1_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim1_level_value_name;
      end if;
           END IF;
           IF (l_favorites_tbl(i).dim2_level_value_id is NOT NULL) THEN
            l_dim2_tbl(l_cnt).id   := l_favorites_tbl(i).dim2_level_value_id;
            l_dim2_tbl(l_cnt).name := l_favorites_tbl(i).dim2_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 2 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim2_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim2_level_value_name;
      end if;
           END IF;
           IF (l_favorites_tbl(i).dim3_level_value_id is NOT NULL) THEN
            l_dim3_tbl(l_cnt).id   := l_favorites_tbl(i).dim3_level_value_id;
            l_dim3_tbl(l_cnt).name := l_favorites_tbl(i).dim3_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 3 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim3_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim3_level_value_name;
      end if;
           END IF;
           IF (l_favorites_tbl(i).dim4_level_value_id is NOT NULL) THEN
            l_dim4_tbl(l_cnt).id   := l_favorites_tbl(i).dim4_level_value_id;
            l_dim4_tbl(l_cnt).name := l_favorites_tbl(i).dim4_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 4 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim4_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim4_level_value_name;
      end if;
           END IF;
           IF (l_favorites_tbl(i).dim5_level_value_id is NOT NULL) THEN
            l_dim5_tbl(l_cnt).id   := l_favorites_tbl(i).dim5_level_value_id;
            l_dim5_tbl(l_cnt).name := l_favorites_tbl(i).dim5_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 5 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim5_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim5_level_value_name;
      end if;
           END IF;
           -- mdamle 01/15/2001 - Use Dim6 and Dim7
           IF (l_favorites_tbl(i).dim6_level_value_id is NOT NULL) THEN
            l_dim6_tbl(l_cnt).id   := l_favorites_tbl(i).dim6_level_value_id;
            l_dim6_tbl(l_cnt).name := l_favorites_tbl(i).dim6_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 6 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim6_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim6_level_value_name;
      end if;
           END IF;
           IF (l_favorites_tbl(i).dim7_level_value_id is NOT NULL) THEN
            l_dim7_tbl(l_cnt).id   := l_favorites_tbl(i).dim7_level_value_id;
            l_dim7_tbl(l_cnt).name := l_favorites_tbl(i).dim7_level_value_name;
      -- mdamle 01/15/2001 Use Dim6 and Dim7
      if l_Org_Seq_Num = 7 then
             l_orgs_tbl(l_cnt).id   := l_favorites_tbl(i).dim7_level_value_id;
             l_orgs_tbl(l_cnt).name := l_favorites_tbl(i).dim7_level_value_name;
      end if;
           END IF;
          l_cnt := l_cnt + 1;
         END IF;
       END LOOP;
    END IF; -- if l_favorites_tbl is empty



    l_string := l_string ||'<HTML>';

    -- *********************************************************
    -- Call the procedure that paints the LOV javascript function
    BIS_LOV_PUB.editlovjscript(x_string => l_lovstring);

    l_string := l_string || l_lovstring;
    l_string := l_string ||'<body>';
    l_string := l_string || '<LINK HREF="/OA_HTML/bisportal.css" type="text/css" rel="stylesheet">';

    l_string := l_string ||'<SCRIPT LANGUAGE="Javascript">';
    l_string := l_string ||'function saveRename() {';
    l_string := l_string ||'  var temp = opener.document.DefaultFormName.C.selectedIndex;';
    l_string := l_string ||'var end  = opener.document.DefaultFormName.C.length;';
    l_string := l_string ||'  if (document.editDimensions.label.value == "") {';
    l_string := l_string ||'    alert ("'||l_enter_displabel||'");';
    l_string := l_string ||'    document.editDimensions.label.focus();';
    l_string := l_string ||'    }';
    l_string := l_string ||'  else {';
    l_string := l_string ||'    var ind  =  document.editDimensions.ind.value;';
    l_string := l_string ||'    var g_var1 = "'||l_d0||'";';

    --l_string := l_string ||'   // Do some checks before grabbing the dimension level values';
    --l_string := l_string ||'   // For dimension0';
    l_string := l_string ||'      if (document.editDimensions.dim0_level_id.value != "") {';
    l_string := l_string ||'         var d0_tmp = document.editDimensions.dim0.selectedIndex;';
    l_string := l_string ||'         var d0_end = document.editDimensions.dim0.length;';
    l_string := l_string ||'         if ((document.editDimensions.dim0[d0_tmp].text == "'||l_blank||'") '||c_OR;
    l_string := l_string ||             ' (document.editDimensions.dim0[d0_tmp].text == "'||c_choose||'"))   {';
    l_string := l_string ||'            d0 = "+";';
    l_string := l_string ||'            alert("'||l_choose_dim_value||'");';
    l_string := l_string ||'            document.editDimensions.dim0.focus();';
    l_string := l_string ||'            return FALSE;';
    l_string := l_string ||'            }';
    l_string := l_string ||'         else ';
    l_string := l_string ||'            var d0 =  document.editDimensions.dim0[d0_tmp].value;';
    l_string := l_string ||'         }';
    l_string := l_string ||'      else ';
    l_string := l_string ||'         {d0 = "-";}';


    --l_string := l_string ||'      // For dimension1';
    l_string := l_string ||'      if (document.editDimensions.dim1_level_id.value != "") {';
    l_string := l_string ||'         var d1_tmp = document.editDimensions.dim1.selectedIndex;';
    l_string := l_string ||'         var d1_end = document.editDimensions.dim1.length;';
    --l_string := l_string ||'   // mdamle 01/15/2001 - Changed the check |||r to Dim0 check';
    --l_string := l_string ||'         // if (d1_tmp == 0 '||c_OR||' d1_tmp == d1_end - 1){';
    l_string := l_string ||'         if ((document.editDimensions.dim1[d1_tmp].text == "'||l_blank||'") '||c_OR;
    l_string := l_string ||'             (document.editDimensions.dim1[d1_tmp].text == "'||c_choose||'"))  {';
    l_string := l_string ||'            d1 = "+";';
    l_string := l_string ||'            alert("'||l_choose_dim_value||'");';
    l_string := l_string ||'            document.editDimensions.dim1.focus();';
    l_string := l_string ||'            return FALSE;';
    l_string := l_string ||'            }';
    l_string := l_string ||'         else ';
    l_string := l_string ||'            var d1 =  document.editDimensions.dim1[d1_tmp].value;';
    l_string := l_string ||'         }';
    l_string := l_string ||'      else ';
    l_string := l_string ||'         {d1 = "-";}';


    --l_string := l_string ||'      // For dimension2';
    l_string := l_string ||'      if (document.editDimensions.dim2_level_id.value != "") {';
    l_string := l_string ||'         var d2_tmp = document.editDimensions.dim2.selectedIndex;';
    l_string := l_string ||'         var d2_end = document.editDimensions.dim2.length;';
    --l_string := l_string ||'   // mdamle 02/25/2002 - Changed the check |||r to Dim0 check';
    l_string := l_string ||'         if ((document.editDimensions.dim2[d2_tmp].text == "'||l_blank||'") '||c_OR;
    l_string := l_string ||'             (document.editDimensions.dim2[d2_tmp].text == "'||c_choose||'"))  {';
    l_string := l_string ||'            d2 = "+";';
    l_string := l_string ||'            alert("'||l_choose_dim_value||'");';
    l_string := l_string ||'            document.editDimensions.dim2.focus();';
    l_string := l_string ||'            return FALSE;';
    l_string := l_string ||'            }';
    l_string := l_string ||'         else ';
    l_string := l_string ||'            var d2 =  document.editDimensions.dim2[d2_tmp].value;';
    l_string := l_string ||'         }';
    l_string := l_string ||'      else';
    l_string := l_string ||'         {d2 = "-";}';


    --l_string := l_string ||'      // For dimension3';
    l_string := l_string ||'      if (document.editDimensions.dim3_level_id.value != "") {';
    l_string := l_string ||'         var d3_tmp = document.editDimensions.dim3.selectedIndex;';
    l_string := l_string ||'         var d3_end = document.editDimensions.dim3.length;';
    --l_string := l_string ||'   // mdamle 03/35/3003 - Changed the check |||r to Dim0 check';
    --l_string := l_string ||'         // if (d3_tmp == 0 '||c_OR||' d3_tmp == d3_end - 3){';
    l_string := l_string ||'         if ((document.editDimensions.dim3[d3_tmp].text == "'||l_blank||'") '||c_OR;
    l_string := l_string ||'             (document.editDimensions.dim3[d3_tmp].text == "'||c_choose||'"))  {';
    l_string := l_string ||'            d3 = "+";';
    l_string := l_string ||'            alert("'||l_choose_dim_value||'");';
    l_string := l_string ||'            document.editDimensions.dim3.focus();';
    l_string := l_string ||'            return FALSE;';
    l_string := l_string ||'            }';
    l_string := l_string ||'         else ';
    l_string := l_string ||'            var d3 =  document.editDimensions.dim3[d3_tmp].value;';
    l_string := l_string ||'         }';
    l_string := l_string ||'      else';
    l_string := l_string ||'         {d3 = "-";}';


    --l_string := l_string ||'      // For dimension4';
    l_string := l_string ||'      if (document.editDimensions.dim4_level_id.value != "") {';
    l_string := l_string ||'         var d4_tmp = document.editDimensions.dim4.selectedIndex;';
    l_string := l_string ||'         var d4_end = document.editDimensions.dim4.length;';
    --l_string := l_string ||'   // mdamle 04/45/4004 - Changed the check |||r to Dim0 check';
    --l_string := l_string ||'         // if (d4_tmp == 0 '||c_OR||' d4_tmp == d4_end - 4){';
    l_string := l_string ||'         if ((document.editDimensions.dim4[d4_tmp].text == "'||l_blank||'") '||c_OR;
    l_string := l_string ||'             (document.editDimensions.dim4[d4_tmp].text == "'||c_choose||'"))  {';
    l_string := l_string ||'            d4 = "+";';
    l_string := l_string ||'            alert("'||l_choose_dim_value||'");';
    l_string := l_string ||'            document.editDimensions.dim4.focus();';
    l_string := l_string ||'            return FALSE;';
    l_string := l_string ||'            }';
    l_string := l_string ||'         else';
    l_string := l_string ||'            var d4 =  document.editDimensions.dim4[d4_tmp].value;';
    l_string := l_string ||'         }';
    l_string := l_string ||'      else';
    l_string := l_string ||'         {d4 = "-";}';


    --l_string := l_string ||'      // For dimension5';
    l_string := l_string ||'      if (document.editDimensions.dim5_level_id.value != "") {';
    l_string := l_string ||'         var d5_tmp = document.editDimensions.dim5.selectedIndex;';
    l_string := l_string ||'         var d5_end = document.editDimensions.dim5.length;';
    --l_string := l_string ||'   // mdamle 05/55/5005 - Changed the check |||r to Dim0 check';
    --l_string := l_string ||'         // if (d5_tmp == 0 '||c_OR||' d5_tmp == d5_end - 5){';
    l_string := l_string ||'         if ((document.editDimensions.dim5[d5_tmp].text == "'||l_blank||'") '||c_OR;
    l_string := l_string ||'             (document.editDimensions.dim5[d5_tmp].text == "'||c_choose||'"))  {';
    l_string := l_string ||'            d5 = "+";';
    l_string := l_string ||'            alert("'||l_choose_dim_value||'");';
    l_string := l_string ||'            document.editDimensions.dim5.focus();';
    l_string := l_string ||'            return FALSE;';
    l_string := l_string ||'            }';
    l_string := l_string ||'         else ';
    l_string := l_string ||'            var d5 =  document.editDimensions.dim5[d5_tmp].value;';
    l_string := l_string ||'         }';
    l_string := l_string ||'       else';
    l_string := l_string ||'         {d5 = "-";}';

    --l_string := l_string ||'  // mdamle 01/15/2001 - Use Dim6 and Dim7';
    ---l_string := l_string ||'      // For dimension6';
    l_string := l_string ||'      if (document.editDimensions.dim6_level_id.value != "") {';
    l_string := l_string ||'         var d6_tmp = document.editDimensions.dim6.selectedIndex;';
    l_string := l_string ||'         var d6_end = document.editDimensions.dim6.length;';
    --l_string := l_string ||'   // mdamle 06/66/6006 - Changed the check |||r to Dim0 check';
    --l_string := l_string ||'         // if (d6_tmp == 0 '||c_OR||' d6_tmp == d6_end - 6){';
    l_string := l_string ||'         if ((document.editDimensions.dim6[d6_tmp].text == "'||l_blank||'") '||c_OR;
    l_string := l_string ||'             (document.editDimensions.dim6[d6_tmp].text == "'||c_choose||'"))  {';
    l_string := l_string ||'            d6 = "+";';
    l_string := l_string ||'            alert("'||l_choose_dim_value||'");';
    l_string := l_string ||'            document.editDimensions.dim6.focus();';
    l_string := l_string ||'            return FALSE;';
    l_string := l_string ||'            }';
    l_string := l_string ||'         else';
    l_string := l_string ||'            var d6 =  document.editDimensions.dim6[d6_tmp].value;';
    l_string := l_string ||'         }';
    l_string := l_string ||'       else';
    l_string := l_string ||'         {d6 = "-";}';

    --l_string := l_string ||'  // mdamle 01/15/2001 - Use Dim6 and Dim7';
    --l_string := l_string ||'      // For dimension7';
    l_string := l_string ||'      if (document.editDimensions.dim7_level_id.value != "") {';
    l_string := l_string ||'         var d7_tmp = document.editDimensions.dim7.selectedIndex;';
    l_string := l_string ||'         var d7_end = document.editDimensions.dim7.length;';
    --l_string := l_string ||'   // mdamle 07/77/7007 - Changed the check |||r to Dim0 check';
    --l_string := l_string ||'         // if (d7_tmp == 0 '||c_OR||' d7_tmp == d7_end - 7){';
    l_string := l_string ||'         if ((document.editDimensions.dim7[d7_tmp].text == "'||l_blank||'") '||c_OR;
    l_string := l_string ||'             (document.editDimensions.dim7[d7_tmp].text == "'||c_choose||'"))  {';
    l_string := l_string ||'            d7 = "+";';
    l_string := l_string ||'            alert("'||l_choose_dim_value||'");';
    l_string := l_string ||'            document.editDimensions.dim7.focus();';
    l_string := l_string ||'            return FALSE;';
    l_string := l_string ||'            }';
    l_string := l_string ||'         else ';
    l_string := l_string ||'            var d7 =  document.editDimensions.dim7[d7_tmp].value;';
    l_string := l_string ||'         }';
    l_string := l_string ||'       else ';
    l_string := l_string ||'         {d7 = "-";}';

    --l_string := l_string ||'      // For Plan';
    l_string := l_string ||'       var plan_tmp = document.editDimensions.plan.selectedIndex;';
    l_string := l_string ||'       var plan     = document.editDimensions.plan[plan_tmp].value;';


    l_string := l_string ||'    var totext=document.editDimensions.label.value;';

    --l_string := l_string ||'// mdamle 01/15/2001 - Use Dim6 and Dim7';
    --l_string := l_string ||'// Put Org dimension value in the correct dimension';
    l_string := l_string ||'if (document.editDimensions.orgDimension.value == "1")';
    l_string := l_string ||'   d1 = d0;';
    l_string := l_string ||'if (document.editDimensions.orgDimension.value == "2")';
    l_string := l_string ||'   d2 = d0;';
    l_string := l_string ||'if (document.editDimensions.orgDimension.value == "3")';
    l_string := l_string ||'   d3 = d0;';
    l_string := l_string ||'if (document.editDimensions.orgDimension.value == "4")';
    l_string := l_string ||'   d4 = d0;';
    l_string := l_string ||'if (document.editDimensions.orgDimension.value == "5")';
    l_string := l_string ||'   d5 = d0;';
    l_string := l_string ||'if (document.editDimensions.orgDimension.value == "6")';
    l_string := l_string ||'   d6 = d0;';
    l_string := l_string ||'if (document.editDimensions.orgDimension.value == "7")';
    l_string := l_string ||'   d7 = d0;';

    --l_string := l_string ||'// mdamle 01/15/2001 - Add d6 and d7';
    l_string := l_string ||'    var tovalue= ind + "*" + d0 + "*" + d1 + "*" + d2 + "*" + d3 + "*" + d4 + "*" + d5 + "*" + d6 + "*" + d7 + "*" + plan;';

    --l_string := l_string ||'    // Now go through the contents of right side box to see if';
    --l_string := l_string ||'    // this exists already';


    --start
    l_string := l_string ||'       var duplicatedComb = 0;';
    l_string := l_string ||'       var duplicatedText = 0;';
    l_string := l_string ||'       for (var i=0;i<end;i++){';
    l_string := l_string ||'         if (i != temp) {';
    l_string := l_string ||'           var cval = opener.document.DefaultFormName.C[i].value;';
    l_string := l_string ||'           if (tovalue == cval.substr(0, cval.length-2)) {';
    l_string := l_string ||'             duplicatedComb = 1;';
    l_string := l_string ||'           }';
    l_string := l_string ||'           if (totext == opener.document.DefaultFormName.C[i].text) {';
    l_string := l_string ||'             duplicatedText = 1;';
    l_string := l_string ||'           }';
    l_string := l_string ||'         }';
    l_string := l_string ||'       }';
    l_string := l_string ||'       if (duplicatedComb == 1){';
    l_string := l_string ||'         alert("'||l_dup_combo||'");';
    l_string := l_string ||'       } else if (duplicatedText == 1) {';
    l_string := l_string ||'         alert("'||l_dup_displabel||'");';
    --end

    l_string := l_string ||'       }';
    l_string := l_string ||'     else {';
    l_string := l_string ||'       opener.document.DefaultFormName.C.options[temp].text  = totext;';
    l_string := l_string ||'       opener.document.DefaultFormName.C.options[temp].value = tovalue+"*Y";';

    l_string := l_string ||'       window.close();';
    l_string := l_string ||'       }';
    l_string := l_string ||'    }'; -- //  to check if  editDimensions.value is null or not';
    l_string := l_string ||'  }';

    l_string := l_string ||'function open_new_browser(url,x,y){';
    l_string := l_string ||'    var attributes = "resizable=yes,scrollbars=yes,toolbar=no,width="+x+",height="+y;';
    l_string := l_string ||'    var new_browser = window.open(url, "new_browser", attributes);';
    l_string := l_string ||'    if (new_browser != null) {';
    l_string := l_string ||'        if (new_browser.opener == null)';
    l_string := l_string ||'            new_browser.opener = self;';
    l_string := l_string ||'        new_browser.name = ''editLOVValues'';';
    l_string := l_string ||'        new_browser.location.href = url;';
    l_string := l_string ||'        }';
    l_string := l_string ||'    }';

    l_string := l_string ||'function loadName() {';
    l_string := l_string ||'   var temp=opener.document.DefaultFormName.C.selectedIndex;';
    l_string := l_string ||'   document.editDimensions.label.value = opener.document.DefaultFormName.C.options[temp].text;';
    l_string := l_string ||'  }';

    -- Get string to clear dim1-5 in case they are related to the org
    --
    l_elements(1) := 'plan';
    l_elements(2) := 'dim0';
    l_elements(3) := 'label';



    clearSelect
    ( p_formName     => 'editDimensions'
    , p_elementTable => l_elements
    , x_clearString  => l_clear
    );



-- meastmon 06/26/2001 Dont clear other dimensions
    l_string := l_string ||'function setdim0() {';
    l_string := l_string ||'    var end = document.editDimensions.dim0.length;';
    l_string := l_string ||'    var temp = document.editDimensions.dim0.selectedIndex;';
    l_string := l_string ||'    if (document.editDimensions.dim0[temp].text == "'||c_choose||'") {';
    l_string := l_string ||'       var ind  =  document.editDimensions.ind.value;';
    l_string := l_string ||'       var dim_lvl_id = document.editDimensions.dim0_level_id.value;';
    l_string := l_string ||'       var c_qry = "'||l_user_id||c_asterisk||'" + ind + "'||c_asterisk||'" + dim_lvl_id;';
    l_string := l_string ||'       var c_jsfuncname = "getdim0";';
    l_string := l_string ||'       document.editDimensions.dim0.selectedIndex = 0;';
    l_string := l_string ||'       getLOV(''bis_intermediate_lov_pvt.dim_level_values_query''';
    l_string := l_string ||'             ,c_qry,c_jsfuncname,'||Z||');';
    l_string := l_string ||'       }';
    l_string := l_string ||'   }';



     SetSetOfBookVar
     ( p_user_id     => l_user_id
     , p_formName    => 'editDimensions'
     , p_index       => 'dim0_index'
     , x_sobString   => l_sobString
     );

    l_string := l_string ||'function setdim1() {';
    --l_string := l_string ||'// alert("dim0 = "+dim0_id);';
    l_string := l_string ||'         var end = document.editDimensions.dim1.length;';
    l_string := l_string ||'         var temp = document.editDimensions.dim1.selectedIndex;';
    l_string := l_string ||'          if (document.editDimensions.dim1[temp].text == "'||c_choose||'") {';
    l_string := l_string ||'       var ind  =  document.editDimensions.ind.value;';
    l_string := l_string ||'       var dim_lvl_id = document.editDimensions.dim1_level_id.value;';

    --l_string := l_string ||' // mdamle 01/15/2001 - Moved conditional code into l_sobString';
    l_string := l_string ||'       '||l_sobString;

    l_string := l_string ||'       var c_jsfuncname = "getdim1";';
    l_string := l_string ||'       document.editDimensions.dim1.selectedIndex = 0;';
    l_string := l_string ||'       getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');';
    l_string := l_string ||'       }';
    l_string := l_string ||'   }';


    l_string := l_string ||'function setdim2() {';
    --l_string := l_string ||'// alert("dim0 = "+dim0_id);';
    l_string := l_string ||'    var end = document.editDimensions.dim2.length;';
    l_string := l_string ||'    var temp = document.editDimensions.dim2.selectedIndex;';
    l_string := l_string ||'    if (document.editDimensions.dim2[temp].text == "'||c_choose||'") {';
    l_string := l_string ||'       var ind  =  document.editDimensions.ind.value;';
    l_string := l_string ||'       var dim_lvl_id = document.editDimensions.dim2_level_id.value;';

    --l_string := l_string ||' // mdamle 01/15/2001 - Moved conditional code into l_sobString';
    l_string := l_string ||'       '||l_sobString;

    l_string := l_string ||'       var c_jsfuncname = "getdim2";';
    l_string := l_string ||'       document.editDimensions.dim2.selectedIndex = 0;';
    l_string := l_string ||'       getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');';
    l_string := l_string ||'       }';
    l_string := l_string ||'   }';


    l_string := l_string ||'function setdim3() {';
    --l_string := l_string ||'// alert("dim0 = "+dim0_id);';
    l_string := l_string ||'     var end = document.editDimensions.dim3.length;';
    l_string := l_string ||'    var temp = document.editDimensions.dim3.selectedIndex;';
    l_string := l_string ||'    if (document.editDimensions.dim3[temp].text == "'||c_choose||'") {';
    l_string := l_string ||'       var ind  =  document.editDimensions.ind.value;';
    l_string := l_string ||'       var dim_lvl_id = document.editDimensions.dim3_level_id.value;';

    --l_string := l_string ||' // mdamle 01/15/2001 - Moved conditional code into l_sobString';
    l_string := l_string ||'       '||l_sobString;

    l_string := l_string ||'       var c_jsfuncname = "getdim3";';
    l_string := l_string ||'       document.editDimensions.dim3.selectedIndex = 0;';
    l_string := l_string ||'       getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');';
    l_string := l_string ||'       }';
    l_string := l_string ||'   }';


    l_string := l_string ||'function setdim4() {';
    --l_string := l_string ||'// alert("dim0 = "+dim0_id);';
    l_string := l_string ||'    var end = document.editDimensions.dim4.length;';
    l_string := l_string ||'    var temp = document.editDimensions.dim4.selectedIndex;';
    l_string := l_string ||'    if (document.editDimensions.dim4[temp].text == "'||c_choose||'") {';
    l_string := l_string ||'       var ind  =  document.editDimensions.ind.value;';
    l_string := l_string ||'       var dim_lvl_id = document.editDimensions.dim4_level_id.value;';

    --l_string := l_string ||' // mdamle 01/15/2001 - Moved conditional code into l_sobString';
    l_string := l_string ||'       '||l_sobString;

    l_string := l_string ||'       var c_jsfuncname = "getdim4";';
    l_string := l_string ||'       document.editDimensions.dim4.selectedIndex = 0;';
    l_string := l_string ||'       getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');';
    l_string := l_string ||'       }';
    l_string := l_string ||'   }';


    l_string := l_string ||'function setdim5() {';
    --l_string := l_string ||'// alert("dim0 = "+dim0_id);';
    l_string := l_string ||'    var end = document.editDimensions.dim5.length;';
    l_string := l_string ||'    var temp = document.editDimensions.dim5.selectedIndex;';
    l_string := l_string ||'    if (document.editDimensions.dim5[temp].text == "'||c_choose||'") {';
    l_string := l_string ||'       var ind  =  document.editDimensions.ind.value;';
    l_string := l_string ||'       var dim_lvl_id = document.editDimensions.dim5_level_id.value;';

    --l_string := l_string ||' // mdamle 01/15/2001 - Moved conditional code into l_sobString';
    l_string := l_string ||'       '||l_sobString;

    l_string := l_string ||'       var c_jsfuncname = "getdim5";';
    l_string := l_string ||'       document.editDimensions.dim5.selectedIndex = 0;';
    l_string := l_string ||'       getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');';
    l_string := l_string ||'       }';
    l_string := l_string ||'   }';


    -- mdamle - 01/15/2001 - Use Dim6 and Dim7
    l_string := l_string ||'function setdim6() {';
    --l_string := l_string ||'// alert("dim0 = "+dim0_id);';
    l_string := l_string ||'    var end = document.editDimensions.dim6.length;';
    l_string := l_string ||'    var temp = document.editDimensions.dim6.selectedIndex;';
    l_string := l_string ||'    if (document.editDimensions.dim6[temp].text == "'||c_choose||'") {';
    l_string := l_string ||'       var ind  =  document.editDimensions.ind.value;';
    l_string := l_string ||'       var dim_lvl_id = document.editDimensions.dim6_level_id.value;';

    --l_string := l_string ||' // mdamle 01/15/2001 - Moved conditional code into l_sobString';
    l_string := l_string ||'       '||l_sobString;

    l_string := l_string ||'       var c_jsfuncname = "getdim6";';
    l_string := l_string ||'       document.editDimensions.dim6.selectedIndex = 0;';
    l_string := l_string ||'       getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');';
    l_string := l_string ||'       }';
    l_string := l_string ||'   }';


     -- mdamle - 01/15/2001 - Use Dim6 and Dim7
     l_string := l_string ||'function setdim7() {';
     --l_string := l_string ||'// alert("dim0 = "+dim0_id);';
     l_string := l_string ||'         var end = document.editDimensions.dim7.length;';
     l_string := l_string ||'   var temp = document.editDimensions.dim7.selectedIndex;';
     l_string := l_string ||'   if (document.editDimensions.dim7[temp].text == "'||c_choose||'") {';
     l_string := l_string ||'       var ind  =  document.editDimensions.ind.value;';
     l_string := l_string ||'       var dim_lvl_id = document.editDimensions.dim7_level_id.value;';

     --l_string := l_string ||' // mdamle 01/15/2001 - Moved conditional code into l_sobString';
     l_string := l_string ||'       '||l_sobString;

     l_string := l_string ||'       var c_jsfuncname = "getdim7";';
     l_string := l_string ||'       document.editDimensions.dim7.selectedIndex = 0;';
     l_string := l_string ||'       getLOV(''bis_intermediate_lov_pvt.dim_level_values_query'',c_qry,c_jsfuncname,'||Z||');';
     l_string := l_string ||'       }';
     l_string := l_string ||'   }';

    l_string := l_string ||'</SCRIPT>';
    l_string := l_string ||'<!-- Open form for this window -->';
    l_string := l_string ||'</FORM>'; --WORKAROUND
    l_string := l_string ||'<FORM ACTION="javascript:saveRename()" METHOD="POST" name="editDimensions">';
    l_string := l_string ||'<CENTER>';
    l_string := l_string ||'<!-- Open table -->';
    l_string := l_string ||'<table border=0 cellspacing=0 cellpadding=0 width=100%>'; -- main
    l_string := l_string ||'<INPUT TYPE="hidden" NAME="ind" VALUE="'||l_indlevel_id||'">';
    l_string := l_string ||'<!-- Open first row for this table -->';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td align="CENTER">';
    l_string := l_string ||'<TABLE >';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<TD ALIGN="RIGHT">'||bis_utilities_pvt.escape_html(c_tarlevel) ||'</TD>';
    l_string := l_string ||'<TD ALIGN="LEFT"><B>'||bis_utilities_pvt.escape_html(l_indlevel_name)||'</B></TD>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'</TABLE>';
    l_string := l_string ||'</td>';
    l_string := l_string ||'</TR>';

    l_string := l_string ||'<!-- Open second row for this table -->';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<TD><BR></TD>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td align="CENTER">';
    l_string := l_string ||'<table border=0 cellspacing=0 cellpadding=0>';
    l_string := l_string ||'<!-- Open row containing the string dimensions -->';
    l_string := l_string ||'<TR>';

    IF(l_swan_enabled)THEN
     l_append_string := '<TD ALIGN="LEFT" class="x49" >';
    ELSE
     l_append_string := '<TD ALIGN="LEFT">';
    END IF;

    l_string := l_string ||l_append_string||bis_utilities_pvt.escape_html(c_dim_and_plan)||'</TD>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'<!-- Open row for wireframe box table -->';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td align="LEFT" valign="TOP">';
    l_string := l_string ||'<!-- open table containing wireframe -->';
    l_string := l_string ||'<table border=0 cellspacing=0 cellpadding=0>';

    l_string := l_string ||'<!-- Top edge of wireframe box -->';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td height=1 class="C_WIRE_FRAME_COLOR" colspan=5><IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<!-- Begin left edge of wireframe and left separator -->';
    l_string := l_string ||'<td width=1 class="C_WIRE_FRAME_COLOR"><IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>';
    l_string := l_string ||'<td width=5></td>';

    l_string := l_string ||'<!-- Begin cell having embedded table with dimension boxes -->';
    l_string := l_string ||'<td align="center" nowrap="yes">';
    l_string := l_string ||'<table border=0 cellspacing=0 cellpadding=0>';

    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td height=5></td>';
    l_string := l_string ||'</TR>';

    l_string := l_string ||'<!-- Begin one more cell to center dimension boxes inside the wireframe -->';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td align="center" nowrap="yes">';
    l_string := l_string ||'<table border=0 cellspacing=0 cellpadding=0>';

   -- ****************************************************************
   --  Table containing the dimension names,boxes



    for c_recs in bisfv_target_levels_cur(l_indlevel_id) LOOP

      -- ******************************
      -- Dimension0 for Organization

      -- meastmon 06/07/2001
      l_Time_Seq_Num := getTimeSeqNum(l_indlevel_id);
      l_string := l_string ||'<INPUT TYPE="hidden" NAME="timeDimension" VALUE="'||l_Time_Seq_Num||'">';

      -- mdamle 01/15/2001 - Use Dim6 and Dim7
      -- Get the Dimension No. for Org
      l_Org_Seq_Num := getOrgSeqNum(l_indlevel_id);
      l_string := l_string ||'<INPUT TYPE="hidden" NAME="orgDimension" VALUE="'||l_Org_Seq_Num||'">';

    -- mdamle 01/15/2001 - Use Dim6 and Dim7
    if l_Org_Seq_Num = 1 then
       l_Org_Level_ID := c_recs.Dimension1_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension1_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension1_level_Name;
    end if;
    if l_Org_Seq_Num = 2 then
       l_Org_Level_ID := c_recs.Dimension2_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension2_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension2_level_Name;
    end if;
    if l_Org_Seq_Num = 3 then
       l_Org_Level_ID := c_recs.Dimension3_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension3_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension3_level_Name;
    end if;
    if l_Org_Seq_Num = 4 then
       l_Org_Level_ID := c_recs.Dimension4_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension4_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension4_level_Name;
    end if;
    if l_Org_Seq_Num = 5 then
       l_Org_Level_ID := c_recs.Dimension5_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension5_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension5_level_Name;
    end if;
    if l_Org_Seq_Num = 6 then
       l_Org_Level_ID := c_recs.Dimension6_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension6_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension6_level_Name;
    end if;
    if l_Org_Seq_Num = 7 then
       l_Org_Level_ID := c_recs.Dimension7_level_id;
     l_Org_Level_Short_Name := c_recs.Dimension7_level_Short_name;
     l_Org_Level_Name := c_recs.Dimension7_level_Name;
    end if;

    if (l_Org_Level_ID is NULL) then
      l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim0_level_id" VALUE="'||l_blank||'">';

      -- meastmon 06/07/2001
      l_string := l_string ||'<INPUT TYPE="hidden" NAME="set_sob" VALUE="FALSE">';

    elsif (l_Org_Level_Short_Name='TOTAL_ORGANIZATIONS') then
      l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim0_level_id" VALUE="'||l_Org_Level_ID||'">';
      -- meastmon 06/07/2001
      l_string := l_string ||'<INPUT TYPE="hidden" NAME="set_sob" VALUE="FALSE">';
      l_string := l_string ||'<TR>';
      l_string := l_string ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(l_Org_Level_Name)||'</TD>';
      l_string := l_string ||'<td align="left" nowrap="YES">';
      l_string := l_string ||'<SELECT NAME="dim0">';
      l_string := l_string ||'<OPTION SELECTED VALUE=-1>'||bis_utilities_pvt.escape_html_input(LOWER(l_Org_Level_Short_Name));
      l_string := l_string ||'</SELECT>';
    else
       -- Print out NOCOPY label and input box for dimension0
      l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim0_level_id" VALUE="'||l_Org_Level_ID||'">';

      -- Set flag to True if we need to pass the related sob info
      -- along
      --
      if (l_Org_Level_Short_Name='SET OF BOOKS') then
        l_string := l_string ||'<INPUT TYPE="hidden" NAME="set_sob" VALUE="TRUE">';
      else
        l_string := l_string ||'<INPUT TYPE="hidden" NAME="set_sob" VALUE="FALSE">';
      end if;

      l_string := l_string ||'<TR>';
      l_string := l_string ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(l_Org_Level_Name)||'</TD>';
      l_string := l_string ||'<td align="left">';
      l_string := l_string ||'<SELECT NAME="dim0" onchange="setdim0()">';
      l_string := l_string ||'<OPTION>';

      if (l_d0 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
        l_d0 := REPLACE(l_d0, c_hash, ' ');
        IF (l_Org_Level_Short_Name='SET OF BOOKS') THEN -- 2665526
            l_set_of_books_id := l_d0;
        ELSE
          l_set_of_books_id := NULL;
        END IF;
         l_dim0_level_value_rec.Dimension_Level_ID := l_Org_Level_ID;
         l_dim0_level_value_rec.Dimension_level_Value_ID := l_d0;
         -- meastmon 09/17/2001 Org_Id_To_Value does not work for EDW Dimensions
         -- Instead use DimensionX_ID_to_Value.
         l_dim_level_value_rec_p := l_dim0_level_value_rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim_level_value_rec_p,
           x_Dim_Level_Value_rec       => l_dim0_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );

        l_string := l_string ||'<OPTION SELECTED VALUE='||bis_utilities_pvt.escape_html_input(l_dim0_level_value_rec.Dimension_level_Value_ID)||'>'||l_dim0_level_value_rec.Dimension_level_Value_Name;




        end if;
        if (l_orgs_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_orgs_tbl,
                           p_value        => l_d0,
                           x_unique_tbl   => l_d0_tbl);
          for i in 1 ..l_d0_tbl.COUNT LOOP
             exit when (l_d0_tbl(i).id is NULL);
             l_string := l_string ||'<OPTION VALUE='||bis_utilities_pvt.escape_html_input(l_d0_tbl(i).name)||'>'||bis_utilities_pvt.escape_html_input(l_d0_tbl(i).name);
          end loop;
        end if;
       l_string := l_string ||'<OPTION>'||c_choose;
       l_string := l_string ||'</SELECT>';
       l_string := l_string ||'</td>';
       l_string := l_string ||'</TR>';
      end if;

      -- ***********************************
      -- Dimension1
    -- mdamle 01/15/2001 - Use Dim6 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level
      if (c_recs.Dimension1_Level_ID is NULL) or (l_Org_Seq_Num = 1) or (l_Time_Seq_Num = 1) then
       if (l_Org_Seq_Num = 1) or (l_Time_Seq_Num = 1) then
         l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim1_level_id" VALUE="">';
         else
         l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim1_level_id" VALUE="'||c_recs.Dimension1_Level_ID||'">';
     end if;
      else
      -- Print out NOCOPY label and input box for dimension1
       l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim1_level_id" VALUE="'||c_recs.Dimension1_Level_ID||'">';
       l_string := l_string ||'<TR>';
       l_string := l_string ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension1_Level_Name) ||'</TD>';
       l_string := l_string ||'<td align="LEFT" nowrap="YES">';
       l_string := l_string ||'<SELECT NAME="dim1" onchange="setdim1()">';
       l_string := l_string ||'<OPTION>';

        if (l_d1 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
          l_d1 := REPLACE(l_d1, c_hash, ' ');

         l_dim1_level_value_rec.Dimension_level_ID:=c_recs.Dimension1_Level_ID;
         l_dim1_level_value_rec.Dimension_level_Value_ID := l_d1;
         l_dim1_level_value_rec.dimension_Level_short_name := c_recs.dimension1_Level_short_name;
         l_dim_level_value_rec_p := l_dim1_level_value_rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim_level_value_rec_p,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim1_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );

         l_string := l_string ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_dim1_level_value_rec.Dimension_level_Value_ID)||'">'||bis_utilities_pvt.escape_html_input(l_dim1_level_value_rec.Dimension_level_Value_Name);
        end if;

       if (l_dim1_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim1_tbl,
                           p_value        => l_d1,
                           x_unique_tbl   => l_d1_tbl);
          for i in 1 ..l_d1_tbl.COUNT LOOP
             exit when (l_d1_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
            l_string := l_string ||'<OPTION VALUE="'||bis_utilities_pvt.escape_html_input(l_d1_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d1_tbl(i).name);
          end loop;
       end if;
       l_string := l_string ||'<OPTION>'||c_choose;
       l_string := l_string ||'</SELECT>';
       l_string := l_string ||'</td>';
       l_string := l_string ||'</TR>';
      end if;

      -- Dimension2
      -- *******************************************
    -- mdamle 02/25/2002 - Use Dim6 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level



      if (c_recs.Dimension2_Level_ID is NULL) or (l_Org_Seq_Num = 2) or (l_Time_Seq_Num = 2) then

       if (l_Org_Seq_Num = 2) or (l_Time_Seq_Num = 2) then
      l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim2_level_id" VALUE="">';
         else
          l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim2_level_id" VALUE="'||c_recs.Dimension2_Level_ID||'">';
     end if;
      else      -- Print out NOCOPY label and input box for dimension2
       l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim2_level_id" VALUE="'||c_recs.Dimension2_Level_ID||'">';
       l_string := l_string ||'<TR>';
       l_string := l_string ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension2_Level_Name) ||'</TD>';
       l_string := l_string ||'<td align="LEFT" nowrap="YES">';
       l_string := l_string ||'<SELECT NAME="dim2" onchange="setdim2()">';
       l_string := l_string ||'<OPTION>';

       if (l_d2 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
        l_d2 := REPLACE(l_d2, c_hash, ' ');

         l_dim2_level_value_rec.Dimension_level_ID:=c_recs.Dimension2_Level_ID;
         l_dim2_level_value_rec.Dimension_level_Value_ID := l_d2;
         l_dim2_level_value_rec.dimension_Level_short_name := c_recs.dimension2_Level_short_name;

         l_dim_level_value_rec_p := l_dim2_level_value_rec;



         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim_level_value_rec_p,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim2_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );


        l_string := l_string ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_dim2_level_value_rec.Dimension_level_Value_ID)||'">'||bis_utilities_pvt.escape_html_input(l_dim2_level_value_rec.Dimension_level_Value_Name);
        end if;

       if (l_dim2_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim2_tbl,
                           p_value        => l_d2,
                           x_unique_tbl   => l_d2_tbl);
          for i in 1 ..l_d2_tbl.COUNT LOOP
             exit when (l_d2_tbl(i).id is NULL);
             l_string := l_string ||'<OPTION VALUE="'||bis_utilities_pvt.escape_html_input(l_d2_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d2_tbl(i).name);
          end loop;
       end if;
       l_string := l_string ||'<OPTION>'||c_choose;
       l_string := l_string ||'</SELECT>';
       l_string := l_string ||'</td>';
       l_string := l_string ||'</TR>';
      end if;

      -- Dimension3
      -- *****************************************
    -- mdamle 03/35/3003 - Use Dim6 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level
      if (c_recs.Dimension3_Level_ID is NULL) or (l_Org_Seq_Num = 3) or (l_Time_Seq_Num = 3) then
        if (l_Org_Seq_Num = 3) or (l_Time_Seq_Num = 3) then
          l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim3_level_id" VALUE="">';
        else
          l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim3_level_id" VALUE="'||c_recs.Dimension3_Level_ID||'">';
        end if;
      else       -- Print out NOCOPY label and input box for dimension3
        l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim3_level_id" VALUE="'||c_recs.Dimension3_Level_ID||'">';
        l_string := l_string ||'<TR>';
        l_string := l_string ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension3_Level_Name) ||'</TD>';
        l_string := l_string ||'<td align="LEFT" nowrap="YES">';
        l_string := l_string ||'<SELECT NAME="dim3" onchange="setdim3()">';
        l_string := l_string ||'<OPTION>';

        if (l_d3 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
        l_d3 := REPLACE(l_d3, c_hash, ' ');

         l_dim3_level_value_rec.Dimension_level_ID:=c_recs.Dimension3_Level_ID;
         l_dim3_level_value_rec.Dimension_level_Value_ID := l_d3;
         l_dim3_level_value_rec.dimension_Level_short_name := c_recs.dimension3_Level_short_name;
         l_dim_level_value_rec_p := l_dim3_level_value_rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim_level_value_rec_p,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim3_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );

        l_string := l_string ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_dim3_level_value_rec.Dimension_level_Value_ID)||'">'||bis_utilities_pvt.escape_html_input(l_dim3_level_value_rec.Dimension_level_Value_Name);
        end if;

        if (l_dim3_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim3_tbl,
                           p_value        => l_d3,
                           x_unique_tbl   => l_d3_tbl);
          for i in 1 ..l_d3_tbl.COUNT LOOP
             exit when (l_d3_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE
            l_string := l_string ||'<OPTION VALUE="'||bis_utilities_pvt.escape_html_input(l_d3_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d3_tbl(i).name);
          end loop;
        end if;
        l_string := l_string ||'<OPTION>'||c_choose;
        l_string := l_string ||'</SELECT>';
        l_string := l_string ||'</td>';
        l_string := l_string ||'</TR>';
       end if;

      -- Dimension4
      -- ****************************************
    -- mdamle 04/45/4004 - Use Dim6 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level
      if (c_recs.Dimension4_Level_ID is NULL) or (l_Org_Seq_Num = 4) or (l_Time_Seq_Num = 4) then
       if (l_Org_Seq_Num = 4) or (l_Time_Seq_Num = 4) then
      l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim4_level_id" VALUE="">';
         else
          l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim4_level_id" VALUE="'||c_recs.Dimension4_Level_ID||'">';
     end if;
      else
       -- Print out NOCOPY label and input box for dimension4
       l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim4_level_id" VALUE="'||c_recs.Dimension4_Level_ID||'">';
       l_string := l_string ||'<TR>';
       l_string := l_string ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension4_Level_Name) ||'</TD>';
       l_string := l_string ||'<td align="LEFT" nowrap="YES">';
       l_string := l_string ||'<SELECT NAME="dim4" onchange="setdim4()">';
       l_string := l_string ||'<OPTION>';

       if (l_d4 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
       l_d4 := REPLACE(l_d4, c_hash, ' ');

         l_dim4_level_value_rec.Dimension_level_ID:=c_recs.Dimension4_Level_ID;
         l_dim4_level_value_rec.Dimension_level_Value_ID := l_d4;
         l_dim4_level_value_rec.dimension_Level_short_name := c_recs.dimension4_Level_short_name;
         l_dim_level_value_rec_p := l_dim4_level_value_rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim_level_value_rec_p,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim4_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );
       l_string := l_string ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_dim4_level_value_rec.Dimension_level_Value_ID)||'">'||bis_utilities_pvt.escape_html_input(l_dim4_level_value_rec.Dimension_level_Value_Name);
        end if;

       if (l_dim4_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim4_tbl,
                           p_value        => l_d4,
                           x_unique_tbl   => l_d4_tbl);
          for i in 1 ..l_d4_tbl.COUNT LOOP
             exit when (l_d4_tbl(i).id is NULL);
       -- mdamle - 01/15/2001 - Add quotes around VALUE

             l_string := l_string ||'<OPTION VALUE="'||bis_utilities_pvt.escape_html_input(l_d4_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d4_tbl(i).name);
          end loop;
       end if;
       l_string := l_string ||'<OPTION>'||c_choose;
       l_string := l_string ||'</SELECT>';
       l_string := l_string ||'</td>';
       l_string := l_string ||'</TR>';
      end if;



      -- Dimension5
      -- ***************************************
    -- mdamle 05/55/5005 - Use Dim6 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level
      if (c_recs.Dimension5_Level_ID is NULL) or (l_Org_Seq_Num = 5) or (l_Time_Seq_Num = 5) then
        if (l_Org_Seq_Num = 5) or (l_Time_Seq_Num = 5) then
          l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim5_level_id" VALUE="">';
        else
          l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim5_level_id" VALUE="'||c_recs.Dimension5_Level_ID||'">';
        end if;
      else
       -- Print out NOCOPY label and input box for dimension5
       l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim5_level_id" VALUE="'||c_recs.Dimension5_Level_ID||'">';
       l_string := l_string ||'<TR>';
       l_string := l_string ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension5_Level_Name) ||'</TD>';
       l_string := l_string ||'<td align="LEFT" nowrap="YES">';
       l_string := l_string ||'<SELECT NAME="dim5" onchange="setdim5()">';
       l_string := l_string ||'<OPTION>';
       if (l_d5 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
       l_d5 := REPLACE(l_d5, c_hash, ' ');

         l_dim5_level_value_rec.Dimension_level_ID:=c_recs.Dimension5_Level_ID;
         l_dim5_level_value_rec.Dimension_level_Value_ID := l_d5;
         l_dim5_level_value_rec.dimension_Level_short_name := c_recs.dimension5_Level_short_name;
         l_dim_level_value_rec_p := l_dim5_level_value_rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim_level_value_rec_p,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim5_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );

       l_string := l_string ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_dim5_level_value_rec.Dimension_level_Value_ID)||'">'||bis_utilities_pvt.escape_html_input(l_dim5_level_value_rec.Dimension_level_Value_Name);
        end if;

       if (l_dim5_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim5_tbl,
                           x_unique_tbl   => l_d5_tbl);
          for i in 1 ..l_d5_tbl.COUNT LOOP
             exit when (l_d5_tbl(i).id is NULL);
             -- mdamle - 01/15/2001 - Add quotes around VALUE
             l_string := l_string ||'<OPTION VALUE="'||bis_utilities_pvt.escape_html_input(l_d5_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d5_tbl(i).name);
          end loop;
       end if;
       l_string := l_string ||'<OPTION>'||c_choose;
       l_string := l_string ||'</SELECT>';
       l_string := l_string ||'</td>';
       l_string := l_string ||'</TR>';
      end if;



      -- mdamle 01/15/2001 - Use Dim6 and Dim7
      -- Dimension6
      -- ***************************************
    -- mdamle 06/66/6006 - Use Dim6 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level



      if (c_recs.Dimension6_Level_ID is NULL) or (l_Org_Seq_Num = 6) or (l_Time_Seq_Num = 6) then

        if (l_Org_Seq_Num = 6) or (l_Time_Seq_Num = 6) then
          l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim6_level_id" VALUE="">';
        else
           l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim6_level_id" VALUE="'||c_recs.Dimension6_Level_ID||'">';
        end if;
      else       -- Print out NOCOPY label and input box for dimension6
       l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim6_level_id" VALUE="'||c_recs.Dimension6_Level_ID||'">';
       l_string := l_string ||'<TR>';
       l_string := l_string ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension6_Level_Name) ||'</TD>';
       l_string := l_string ||'<td align="LEFT" nowrap="YES">';
       l_string := l_string ||'<SELECT NAME="dim6" onchange="setdim6()">';
       l_string := l_string ||'<OPTION>';

       if (l_d6 <> c_hash) then
       -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
       l_d6 := REPLACE(l_d6, c_hash, ' ');

       l_dim6_level_value_rec.Dimension_level_ID:=c_recs.Dimension6_Level_ID;
       l_dim6_level_value_rec.Dimension_level_Value_ID := l_d6;
       l_dim6_level_value_rec.dimension_Level_short_name := c_recs.dimension6_Level_short_name;
       l_dim_level_value_rec_p := l_dim6_level_value_rec;
       BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
         p_api_version               => 1.0,
         p_Dim_Level_Value_Rec       => l_dim_level_value_rec_p,
         p_set_of_books_id           => l_set_of_books_id,
         x_Dim_Level_Value_rec       => l_dim6_level_value_rec,
         x_Return_Status             => l_return_status,
         x_error_Tbl                 => l_error_tbl
        );




       l_string := l_string ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_dim6_level_value_rec.Dimension_level_Value_ID)||'">'||bis_utilities_pvt.escape_html_input(l_dim6_level_value_rec.Dimension_level_Value_Name);
        end if;

       if (l_dim6_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim6_tbl,
                           x_unique_tbl   => l_d6_tbl);
          for i in 1 ..l_d6_tbl.COUNT LOOP
             exit when (l_d6_tbl(i).id is NULL);
          -- mdamle - 01/15/2001 - Add quotes around VALUE
             l_string := l_string ||'<OPTION VALUE="'||bis_utilities_pvt.escape_html_input(l_d6_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d6_tbl(i).name);
          end loop;
       end if;
       l_string := l_string ||'<OPTION>'||c_choose;
       l_string := l_string ||'</SELECT>';
       l_string := l_string ||'</td>';
       l_string := l_string ||'</TR>';
      end if;



      -- mdamle 01/15/2001 - Use Dim6 and Dim7
      -- Dimension7
      -- ***************************************
    -- mdamle 07/77/7007 - Use Dim7 and Dim7
      -- meastmon 06/07/2001
      -- Dont show time dimension level



      if (c_recs.Dimension7_Level_ID is NULL) or (l_Org_Seq_Num = 7) or (l_Time_Seq_Num = 7) then

        if (l_Org_Seq_Num = 7) or (l_Time_Seq_Num = 7) then
          l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim7_level_id" VALUE="">';
        else
          l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim7_level_id" VALUE="'||c_recs.Dimension7_Level_ID||'">';
        end if;
      else       -- Print out NOCOPY label and input box for dimension7
        l_string := l_string ||'<INPUT TYPE="hidden" NAME="dim7_level_id" VALUE="'||c_recs.Dimension7_Level_ID||'">';
        l_string := l_string ||'<TR>';
        l_string := l_string ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_recs.Dimension7_Level_Name) ||'</TD>';
        l_string := l_string ||'<td align="LEFT" nowrap="YES">';
        l_string := l_string ||'<SELECT NAME="dim7" onchange="setdim7()">';
        l_string := l_string ||'<OPTION>';

       if (l_d7 <> c_hash) then
        -- mdamle 01/15/2001 - Replace c_hash with ' ' icase data was changed
       l_d7 := REPLACE(l_d7, c_hash, ' ');



         l_dim7_level_value_rec.Dimension_level_ID:=c_recs.Dimension7_Level_ID;
         l_dim7_level_value_rec.Dimension_level_Value_ID := l_d7;
         l_dim7_level_value_rec.dimension_Level_short_name := c_recs.dimension7_Level_short_name;
         l_dim_level_value_rec_p := l_dim7_level_value_rec;
         BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value(
           p_api_version               => 1.0,
           p_Dim_Level_Value_Rec       => l_dim_level_value_rec_p,
           p_set_of_books_id           => l_set_of_books_id,
           x_Dim_Level_Value_rec       => l_dim7_level_value_rec,
           x_Return_Status             => l_return_status,
           x_error_Tbl                 => l_error_tbl
          );

         l_string := l_string ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(l_dim7_level_value_rec.Dimension_level_Value_ID)||'">'||bis_utilities_pvt.escape_html_input(l_dim7_level_value_rec.Dimension_level_Value_Name);
        end if;

       if (l_dim7_tbl.COUNT <> 0) THEN
          removeDuplicates(p_original_tbl => l_dim7_tbl,
                           x_unique_tbl   => l_d7_tbl);
          for i in 1 ..l_d7_tbl.COUNT LOOP
             exit when (l_d7_tbl(i).id is NULL);
             -- mdamle - 01/15/2001 - Add quotes around VALUE
             l_string := l_string ||'<OPTION VALUE="'||bis_utilities_pvt.escape_html_input(l_d7_tbl(i).id)||'">'||bis_utilities_pvt.escape_html_input(l_d7_tbl(i).name);
          end loop;
       end if;
       l_string := l_string ||'<OPTION>'||c_choose;
       l_string := l_string ||'</SELECT>';
       l_string := l_string ||'</td>';
       l_string := l_string ||'</TR>';
      end if;

     exit;
  end loop;     -- end of   c_recs looop
   -- ***********************************************


    -- Have a poplist for the Business Plan
     l_string := l_string ||'<!-- Row open for Business Plan poplist -->';
     l_string := l_string ||'<TR>';
     l_string := l_string ||'<TD ALIGN="RIGHT" class="x8" NOWRAP>'||bis_utilities_pvt.escape_html(c_plan)||'</TD>';
     l_string := l_string ||'<td align="left">';
     l_string := l_string ||'<SELECT NAME="plan">';




     for pl in plan_cur loop
      if pl.plan_id = TO_NUMBER(l_plan) then
        l_string := l_string ||'<OPTION SELECTED VALUE="'||bis_utilities_pvt.escape_html_input(pl.plan_id) ||'">'||bis_utilities_pvt.escape_html_input(pl.name);
      else
        l_string := l_string ||'<OPTION VALUE="'||bis_utilities_pvt.escape_html_input(pl.plan_id) ||'">'||bis_utilities_pvt.escape_html_input(pl.name);
      end if;
     end loop;

    l_string := l_string ||'</SELECT>';
    l_string := l_string ||'</td>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'</TABLE>';
    l_string := l_string ||'</td>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'<!-- end of row containing one more cell to center poplists -->';
    l_string := l_string ||'<!-- row open with horizontal line separator -->';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td height=1 class="C_SEPARATOR_LINE"><IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td height=5></td>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'<!-- row open for display label string  -->';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td align="left">';
    l_string := l_string ||c_displabel;
    l_string := l_string ||'</td>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td align="left" valign="TOP" nowrap="YES">';
    l_string := l_string ||'<INPUT TYPE="label" NAME="label" SIZE="41" MAXLENGTH="40">';
    l_string := l_string ||'</td>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td height=5></td>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'<!-- Close embedded table containing the dim level poplists etc -->';
    l_string := l_string ||'</TABLE>';
    l_string := l_string ||'</td>';  -- close cell with dim labels and input boxes
    l_string := l_string ||'<!-- Put the right side separator and right edge of wire frame box -->';
    l_string := l_string ||'<td width=5></td>';
    l_string := l_string ||'<td width=1 class="C_WIRE_FRAME_COLOR"><IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<!-- Put the bottom edge of wireframe box -->';
    l_string := l_string ||'<td height=1 class="C_WIRE_FRAME_COLOR" colspan=5><IMG SRC="/OA_MEDIA/FNDINVDT.gif" height=1 width=1></td>';
    l_string := l_string ||'</TR>';

    l_string := l_string ||'<!-- close table wireframe box -->';
    l_string := l_string ||'</TABLE>';
    l_string := l_string ||'</td>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'</TABLE>';
    l_string := l_string ||'</td>';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td><BR></td>';
    l_string := l_string ||'<!-- Open last row containing the ok and cancel buttons -->';
    l_string := l_string ||'<TR>';
    l_string := l_string ||'<td align="center" colspan=2>';
    l_string := l_string ||'<table width="100%"><tr>';
    l_string := l_string ||'<td align="right" width="50%">';

    --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
    --icx_plug_utilities.buttonLeft
    --  (BIS_UTILITIES_PVT.getPrompt('BIS_OK'),'javascript:saveRename()');
    IF(l_swan_enabled)THEN
     l_button_edge:=BIS_UTILITIES_PVT.G_FLAT_EDGE;
    ELSE
     l_button_edge:=BIS_UTILITIES_PVT.G_ROUND_EDGE;
    END IF;

    l_button_tbl(1).left_edge := l_button_edge;
    l_button_tbl(1).right_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
    l_button_tbl(1).disabled := FND_API.G_FALSE;
    l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_OK');
    l_button_tbl(1).href := 'javascript:saveRename()';
    BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
    l_string := l_string ||l_button_str;
    l_string := l_string ||'</td><td align="left" width="50%">';

    --meastmon ICX Button is not ADA Complaint. ICX is not going to fix that.
    --icx_plug_utilities.buttonRight
    -- (BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL'),'javascript:window.close()');
    l_button_tbl(1).left_edge := BIS_UTILITIES_PVT.G_FLAT_EDGE;
    l_button_tbl(1).right_edge := l_button_edge;
    l_button_tbl(1).disabled := FND_API.G_FALSE;
    l_button_tbl(1).label := BIS_UTILITIES_PVT.getPrompt('BIS_CANCEL');
    l_button_tbl(1).href := 'javascript:window.close()';
    BIS_UTILITIES_PVT.GetButtonString(l_button_tbl, l_button_str);
    l_string := l_string || l_button_str;
    l_string := l_string ||'</td></tr></table>';
    l_string := l_string ||'</td>';
    l_string := l_string ||'<!-- Close last row containing the ok and cancel buttons -->';
    l_string := l_string ||'</TR>';
    l_string := l_string ||'</TABLE>';
    l_string := l_string ||'</CENTER>';
    l_string := l_string ||'<!-- close form for this page -->';
    l_string := l_string ||'</FORM>';
    l_string := l_string ||'<SCRIPT LANGUAGE="JavaScript">loadName();</SCRIPT>';
    l_string := l_string ||'</BODY>';
    l_string := l_string ||'</HTML>';



 --end if;    -- icx_validate session
--end if; -- icx_sec.validateSession

    x_string := l_string;

exception
    when others then
        --htp.p(SQLERRM);
      x_string :=  SQLERRM;

end editDimensions;



-- *****************************************************
--  Procedure inserts all the selected values
-- *****************************************************
procedure strDimensions(
 W                      in varchar2 DEFAULT NULL
,Z                      in pls_integer
,p_displaylabels_tbl    in Selected_Values_Tbl_Type
,p_back_url             in VARCHAR2
,p_reference_path       in VARCHAR2)

is
  l_plug_id                 pls_integer;
  l_line                    varchar2(32000);
  l_line_length             pls_integer;
  l_point1                  pls_integer;
  l_point2                  pls_integer;
  l_point3                  pls_integer;
  l_point4                  pls_integer;
  l_point5                  pls_integer;
  l_point6                  pls_integer;
  l_point7                  pls_integer;
  l_point8                  pls_integer;
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_point9                  pls_integer;
  l_point10                 pls_integer;

  l_indlevel_id             pls_integer;
  l_d0                      varchar2(32000);
  l_d1                      varchar2(32000);
  l_d2                      varchar2(32000);
  l_d3                      varchar2(32000);
  l_d4                      varchar2(32000);
  l_d5                      varchar2(32000);
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_d6                      varchar2(32000);
  l_d7                      varchar2(32000);

  l_plan                    varchar2(32000);
  l_length                  pls_integer;
  l_display_label           varchar2(32000);
  l_error_tbl               BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_return_status           varchar2(32000);
  l_indicator_region_values BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type;
  l_plan_idnum              pls_integer;

begin



-- meastmon 09/07/2001 Fix bug#1980577. Workaround Do not encrypt plug_id
--l_plug_id := icx_call.decrypt2(Z);
l_plug_id := Z;
--if icx_sec.validateSession  then
-- if ICX_SEC.validatePlugSession(l_plug_id) then
  g_user_id := icx_sec.getID(ICX_SEC.PV_USER_ID, '', icx_sec.g_session_id); --2751984

  -- Deleting the old rows of this userid and plugid from the selections table
   BIS_INDICATOR_REGION_PUB.Delete_User_Ind_Selections(
        p_api_version    => 1.0,
        p_user_id        => g_user_id,
        p_plug_id        => l_plug_id,
        x_return_status  => l_return_status,
        x_error_Tbl      => l_error_tbl);


  -- Read the contents of the plsql table of favorite display labels
  for i in 1 .. p_displaylabels_tbl.COUNT LOOP
     EXIT when p_displaylabels_tbl(i) is NULL;
     -- Unpack an item  from the Favorites box
     -- to obtain individual dim_level_value id's

    l_point1 := instr(p_displaylabels_tbl(i),'*',1,1);
    l_point2 := instr(p_displaylabels_tbl(i),'*',1,2);
    l_point3 := instr(p_displaylabels_tbl(i),'*',1,3);
    l_point4 := instr(p_displaylabels_tbl(i),'*',1,4);
    l_point5 := instr(p_displaylabels_tbl(i),'*',1,5);
    l_point6 := instr(p_displaylabels_tbl(i),'*',1,6);
    l_point7 := instr(p_displaylabels_tbl(i),'*',1,7);
    l_point8 := instr(p_displaylabels_tbl(i),'*',1,8);
    -- mdamle 01/15/2001 - Use Dim6 and Dim7
    l_point9 := instr(p_displaylabels_tbl(i),'*',1,9);
    l_point10 := instr(p_displaylabels_tbl(i),'*',1,10);

    l_indlevel_id := substr(p_displaylabels_tbl(i),1,l_point1-1);

    -- mdamle 01/15/2001 - Use Dim6 and Dim7
  -- d0 contains the org value for backward compatibility
  -- Replace @ with plus (actual data contains plus)

    l_d0 := substr(p_displaylabels_tbl(i),l_point1+1,l_point2 - l_point1 - 1);
    l_d1 := REPLACE(substr(p_displaylabels_tbl(i),l_point2+1,l_point3 - l_point2 - 1), c_at, c_plus) ;
    l_d2 := REPLACE(substr(p_displaylabels_tbl(i),l_point3+1,l_point4 - l_point3 - 1), c_at, c_plus);
    l_d3 := REPLACE(substr(p_displaylabels_tbl(i),l_point4+1,l_point5 - l_point4 - 1), c_at, c_plus);
    l_d4 := REPLACE(substr(p_displaylabels_tbl(i),l_point5+1,l_point6 - l_point5 - 1), c_at, c_plus);
    l_d5 := REPLACE(substr(p_displaylabels_tbl(i),l_point6+1,l_point7 - l_point6 - 1), c_at, c_plus);
    l_d6 := REPLACE(substr(p_displaylabels_tbl(i),l_point7+1,l_point8 - l_point7 - 1), c_at, c_plus);
    l_d7 := REPLACE(substr(p_displaylabels_tbl(i),l_point8+1,l_point9 - l_point8 - 1), c_at, c_plus);

    -- mdamle 01/15/2001 - Use Dim6 and Dim7
    -- l_plan := substr(p_displaylabels_tbl(i),l_point7+1,l_point8-l_point7-1);
    -- l_display_label := substr(p_displaylabels_tbl(i),l_point8+1);
    l_plan := substr(p_displaylabels_tbl(i),l_point9+1,l_point10-l_point9-1);
    l_display_label := substr(p_displaylabels_tbl(i),l_point10+1);


  --
  -- ****************************** Debug stuff ***************
   -- htp.p('p_display_label_tbl '||p_displaylabels_tbl(i)||'<BR>');
   -- htp.p('<BR>'||l_indlevel_id||'*'||l_d0||'*'||l_d1||'*'||l_d2||'*'
   --      ||l_d3||'*'||l_d4||
   --      '*'||l_d5||'*'||l_plan||'*'||l_display_label||'<BR>');
  -- ***********************************************************

  -- Transfer the values to the fields in the record
  l_indicator_region_values.USER_ID             :=  g_user_id;
  l_indicator_region_values.TARGET_LEVEL_ID     :=  l_indlevel_id;
  -- mdamle 01/15/2001 - Don't pass in the Org_level_value_id anymore
  -- l_indicator_region_values.ORG_LEVEL_VALUE_id  :=  l_d0;
  l_indicator_region_values.LABEL               :=  l_display_label;
  l_indicator_region_values.PLUG_ID             :=  l_plug_id;
  l_indicator_region_values.DIM1_LEVEL_VALUE_ID :=  l_d1;
  l_indicator_region_values.DIM2_LEVEL_VALUE_ID :=  l_d2;
  l_indicator_region_values.DIM3_LEVEL_VALUE_ID :=  l_d3;
  l_indicator_region_values.DIM4_LEVEL_VALUE_ID :=  l_d4;
  l_indicator_region_values.DIM5_LEVEL_VALUE_ID :=  l_d5;
  -- mdamle 01/15/2001 - Use Dim6 and Dim7
  l_indicator_region_values.DIM6_LEVEL_VALUE_ID :=  l_d6;
  l_indicator_region_values.DIM7_LEVEL_VALUE_ID :=  l_d7;

  l_indicator_region_values.PLAN_ID             :=  l_plan;

    BIS_INDICATOR_REGION_PUB.Create_User_Ind_Selection(
        p_api_version          => 1.0,
        p_Indicator_Region_Rec => l_indicator_region_values,
        x_return_status        => l_return_status,
        x_error_Tbl            => l_error_tbl);

  -- ********* Debug stuff ********************
-- htp.p('respid :'||l_resp_id);
-- htp.p('tarid  :'||l_tar_id);
-- htp.p('orgid  :'||l_org_id);
-- htp.p('disp   :'||l_disp);
  -- *******************************************

   end loop;  --  loop  for the input plsql table

  IF (p_reference_path IS NOT NULL) THEN
    UPDATE icx_portlet_customizations
    SET caching_key = TO_CHAR(NVL(caching_key, 0) + 1)
    WHERE reference_path = p_reference_path;
    COMMIT;
  END IF;

   --icx_plug_utilities.gotoMainMenu; -- Go back to the main page

-- end if;  -- icx_validate_session
--end if; -- icx_sec.validateSession
 exception
   when others then NULL;

end strDimensions;

-- ****************************************************************
--  Removes the duplicates from a plsql table
-- ****************************************************************
procedure removeDuplicates(
 p_original_tbl         in  no_duplicates_tbl_Type
,p_value                in  varchar2  default NULL
,x_unique_tbl           out NOCOPY no_duplicates_tbl_Type
)
is
l_temp_tbl             no_duplicates_tbl_Type;
l_cnt                  pls_integer;
l_unique               BOOLEAN;

begin
 -- Remove the duplicates from the l_selections_tbl
 IF p_value is NOT NULL THEN
  FOR i in 1 .. p_original_tbl.COUNT LOOP
    IF (p_value <> p_original_tbl(i).id) THEN
     l_unique := TRUE;
     FOR j in 1 .. l_temp_tbl.COUNT LOOP
        if p_original_tbl(i).id = l_temp_tbl(j).id then
          l_unique := FALSE;
        end if;
     END LOOP;
     if (l_unique) then
       l_cnt := l_temp_tbl.COUNT + 1;
       l_temp_tbl(l_cnt).id := p_original_tbl(i).id;
       l_temp_tbl(l_cnt).name := p_original_tbl(i).name;
     end if;
   END IF;
  END LOOP;
   x_unique_tbl := l_temp_tbl;  -- Transfer the uniques out NOCOPY
 ELSE             -- if p_value is null
  FOR i in 1 .. p_original_tbl.COUNT LOOP
     l_unique := TRUE;
     FOR j in 1 .. l_temp_tbl.COUNT LOOP
        if p_original_tbl(i).id = l_temp_tbl(j).id then
          l_unique := FALSE;
        end if;
     END LOOP;
     if (l_unique) then
       l_cnt := l_temp_tbl.COUNT + 1;
       l_temp_tbl(l_cnt).id := p_original_tbl(i).id;
       l_temp_tbl(l_cnt).name := p_original_tbl(i).name;
     end if;
  END LOOP;
   x_unique_tbl := l_temp_tbl;  -- Transfer the uniques out NOCOPY
 END IF;     -- To check if the extra parameter p_value is null or not

exception
   when others then htp.p(SQLERRM);

end removeDuplicates;

PROCEDURE clearSelect(
  p_formName     IN VARCHAR2
, p_elementTable IN BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_clearString  OUT NOCOPY VARCHAR2
)
IS
l_clear       VARCHAR2(32000);
l_conditions  VARCHAR2(32000);
l_and         VARCHAR2(10) := '&&';
BEGIN

  FOR i IN 1..p_elementTable.count LOOP
    IF i = 1 THEN
       l_conditions := '
          (document.'||p_formName||'.elements[i].name != document.'
          ||p_formName||'.'||p_elementTable(i)||'.name)';
    ELSE
       l_conditions := l_conditions||'
          '||l_and||'
          (document.'||p_formName||'.elements[i].name != document.'
          ||p_formName||'.'||p_elementTable(i)||'.name)';
    END IF;
  END LOOP;


  l_clear :=
  'var k = 0;
   var s = new String("select");

   for (var i=0; i<document.'||p_formName||'.elements.length; i++) {
     var x = document.'||p_formName||'.elements[i].type;
     var t = x.substring(0,6);

     if (t == s) {
       if ('||l_conditions||')
          {
          for (var j=1;j<document.'||p_formName||'.elements[i].length-1;j++) {
            x = document.'||p_formName||'.elements[i].options[j] = null;
          }
       }
     }
   }';

  x_clearString := l_clear;

EXCEPTION
  WHEN OTHERS THEN
    htp.p(SQLERRM);

END clearSelect;

PROCEDURE SetSetOfBookVar(
  p_user_id      IN integer
, p_formName     IN VARCHAR2
, p_index        IN VARCHAR2
, x_sobString    OUT NOCOPY VARCHAR2
)
IS
l_sobString VARCHAR2(32000);
BEGIN

  l_sobString :=
'    if (document.'||p_formName||'.set_sob.value == "TRUE")
      {

         var dim0_level_id = document.'||p_formName||'.dim0_level_id.value;
         var dim0_index = document.'||p_formName||'.dim0.selectedIndex;
         var dim0_id = document.'||p_formName||'.dim0.options[dim0_index].value;
         var dim0_g_var = "BIS_TARGET_PVT.G_SET_OF_BOOK_ID";
         var c_qry = "'||p_user_id||c_asterisk||'" + ind + "'||c_asterisk
                        ||'" + dim_lvl_id + "'||c_asterisk
                        ||'" + dim0_g_var + "'||c_asterisk
                        ||'" + dim0_level_id + "'||c_asterisk
                        ||'" + dim0_id;

      }
    else
      {
       var dim0_id="";


       var c_qry = "'||p_user_id||c_asterisk||'" + ind + "'||c_asterisk
                        ||'" + dim_lvl_id + "'||c_asterisk
                        ||c_asterisk
                        ||c_asterisk ||'";


      }';

  x_sobString := l_sobString;

EXCEPTION
  WHEN OTHERS THEN
    htp.p(SQLERRM);
END SetSetOfBookVar;

-- mdamle 01/12/2001 Get Performance Measure + Dim Level info
function getPerformanceMeasureName(
  p_target_level_id  IN number
) return varchar2 IS
l_perf_meas_name         bis_indicators_tl.name%TYPE;
Begin
   begin
  select measure_name || ' (' || DIMENSION1_LEVEL_NAME || decode(DIMENSION2_LEVEL_NAME, '', '', ' - ' || DIMENSION2_LEVEL_NAME)
  || decode(DIMENSION3_LEVEL_NAME, '', '', ' - ' || DIMENSION3_LEVEL_NAME) || decode(DIMENSION4_LEVEL_NAME, '', '', ' - ' || DIMENSION4_LEVEL_NAME)
  || decode(DIMENSION5_LEVEL_NAME, '', '', ' - ' || DIMENSION5_LEVEL_NAME) || decode(DIMENSION6_LEVEL_NAME, '', '', ' - ' || DIMENSION6_LEVEL_NAME)
  || decode(DIMENSION7_LEVEL_NAME, '', '', ' - ' || DIMENSION7_LEVEL_NAME) || ')'
                                     into l_perf_meas_name
  from bisfv_target_levels tl
        Where tl.target_level_id = p_target_level_id;
    exception
      when others then
      l_perf_meas_name := '';
  end;

  return l_perf_meas_name;

end getPerformanceMeasureName;

-- mdamle 01/15/2001 - Get the Dimension sequence for the Org dimension
function getOrgSeqNum(
  p_target_level_id  IN number
) return number IS
l_OrgSeqNum        number;
Begin
           begin
             SELECT x.sequence_no into l_OrgSeqNum
             FROM   bis_indicator_dimensions x, bis_dimensions y, bis_target_levels z
             WHERE  x.dimension_id = y.dimension_id
             AND    y.short_name like BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME_TL(p_target_level_id,NULL)
             AND    x.indicator_id = z.indicator_id
             AND    z.target_level_id = p_target_level_id;
           exception
              when others then
               l_OrgSeqNum := 0;
           end;

  return l_OrgSeqNum;

end getOrgSeqNum;

-- mdamle 01/15/2001 - Get the Dimension sequence for the Time dimension
function getTimeSeqNum(
  p_target_level_id  IN number
) return number IS
l_TimeSeqNum         number;
Begin
           begin
             SELECT x.sequence_no into l_TimeSeqNum
             FROM   bis_indicator_dimensions x, bis_dimensions y, bis_target_levels z
             WHERE  x.dimension_id = y.dimension_id
             AND    y.short_name like BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_target_level_id,NULL)
             AND    x.indicator_id = z.indicator_id
             AND    z.target_level_id = p_target_level_id ;
           exception
              when others then
               l_TimeSeqNum := 0;
           end;

  return l_TimeSeqNum;

end getTimeSeqNum;

function getOrgLevelID(
  p_target_level_id  IN number
) return number IS
l_OrgSeqNum               number;
l_OrgLevelValueID         number;
l_dimension1_level_id     number;
l_dimension2_level_id     number;
l_dimension3_level_id     number;
l_dimension4_level_id     number;
l_dimension5_level_id     number;
l_dimension6_level_id     number;
l_dimension7_level_id     number;
Begin
  l_OrgSeqNum := getOrgSeqNum(p_target_level_id);

  if l_OrgSeqNum > 0 then
     begin
        SELECT dimension1_level_id, dimension2_level_id, dimension3_level_id,
           dimension1_level_id, dimension5_level_id, dimension6_level_id,
         dimension7_level_id
        INTO l_dimension1_level_id, l_dimension2_level_id, l_dimension3_level_id,
           l_dimension4_level_id, l_dimension5_level_id, l_dimension6_level_id,
         l_dimension7_level_id
        FROM BIS_TARGET_LEVELS
        WHERE target_level_id = p_target_level_id;
     exception
        when others then
          l_OrgLevelValueID := null;
     end;
     if l_OrgLevelValueID is not null then
        if l_OrgSeqNum = 1 then
           l_OrgLevelValueID := l_dimension1_level_id;
        end if;
        if l_OrgSeqNum = 2 then
           l_OrgLevelValueID := l_dimension2_level_id;
        end if;
        if l_OrgSeqNum = 3 then
           l_OrgLevelValueID := l_dimension3_level_id;
        end if;
        if l_OrgSeqNum = 4 then
           l_OrgLevelValueID := l_dimension4_level_id;
        end if;
        if l_OrgSeqNum = 5 then
           l_OrgLevelValueID := l_dimension5_level_id;
        end if;
        if l_OrgSeqNum = 6 then
           l_OrgLevelValueID := l_dimension6_level_id;
        end if;
        if l_OrgSeqNum = 7 then
           l_OrgLevelValueID := l_dimension7_level_id;
        end if;
     end if;
  end if;
  return l_OrgLevelValueID;

end getOrgLevelID;

-- sbuenits 02/16/2001
PROCEDURE pmr_content (
   p_target_level_id          IN       NUMBER,
   p_org_level_value          IN       VARCHAR2,
   p_dimension1_level_value   IN       VARCHAR2,
   p_dimension2_level_value   IN       VARCHAR2,
   p_dimension3_level_value   IN       VARCHAR2,
   p_dimension4_level_value   IN       VARCHAR2,
   p_dimension5_level_value   IN       VARCHAR2,
   p_dimension6_level_value   IN       VARCHAR2,
   p_dimension7_level_value   IN       VARCHAR2,
   p_plan_id                  IN       NUMBER,
   actual_id                  OUT NOCOPY      NUMBER,
   actual                     OUT NOCOPY      NUMBER,
   target_id                  OUT NOCOPY      NUMBER,
   target                     OUT NOCOPY      NUMBER,
   range1_high                OUT NOCOPY      NUMBER,
   range1_low                 OUT NOCOPY      NUMBER,
   range2_high                OUT NOCOPY      NUMBER,
   range2_low                 OUT NOCOPY      NUMBER,
   role1_id                   OUT NOCOPY      NUMBER,
   role2_id                   OUT NOCOPY      NUMBER,
   time_level_value_id        OUT NOCOPY      VARCHAR2,
   status                     OUT NOCOPY      VARCHAR2,
   is_in_range                OUT NOCOPY      VARCHAR2
)
 IS
   dummy             PLS_INTEGER;
   return_status     VARCHAR2(255);
   token             VARCHAR2(1)                    := '';
   rec_bis_target    bis_target_pub.target_rec_type;

   CURSOR cur_notimelvl (p_tarid IN PLS_INTEGER)
   IS
      SELECT tlv.target_level_id
        FROM bisbv_target_levels tlv, bis_levels blv
       WHERE tlv.target_level_id = p_tarid
         AND (
                   tlv.dimension1_level_id = blv.level_id
                OR tlv.dimension2_level_id = blv.level_id
                OR tlv.dimension3_level_id = blv.level_id
                OR tlv.dimension4_level_id = blv.level_id
                OR tlv.dimension5_level_id = blv.level_id
                OR tlv.dimension6_level_id = blv.level_id
                OR tlv.dimension7_level_id = blv.level_id
             )
         AND blv.short_name = 'TOTAL_TIME';

   CURSOR cur_actual
   IS
      SELECT actual_id,
             actual_value
        FROM bisbv_actuals acts
       WHERE acts.target_level_id = p_target_level_id
         AND NVL (acts.dimension1_level_value, '1') =
                NVL (p_dimension1_level_value, '1')
         AND NVL (acts.dimension2_level_value, '1') =
                NVL (p_dimension2_level_value, '1')
         AND NVL (acts.dimension3_level_value, '1') =
                NVL (p_dimension3_level_value, '1')
         AND NVL (acts.dimension4_level_value, '1') =
                NVL (p_dimension4_level_value, '1')
         AND NVL (acts.dimension5_level_value, '1') =
                NVL (p_dimension5_level_value, '1')
         AND NVL (acts.dimension6_level_value, '1') =
                NVL (p_dimension6_level_value, '1')
         AND NVL (acts.dimension7_level_value, '1') =
                NVL (p_dimension7_level_value, '1');

   rec_actual        cur_actual%ROWTYPE;

   CURSOR cur_target
   IS
      SELECT target,
             target_id,
             NVL (range1_low, 0) range1_low,
             NVL (range1_high, 0) range1_high,
             range2_low,
             range2_high,
             range3_low,
             range3_high,
             notify_resp1_id,
             notify_resp2_id,
             notify_resp3_id
        FROM bisbv_targets tars
       WHERE tars.target_level_id = p_target_level_id
         AND tars.plan_id = p_plan_id
         AND NVL (tars.dim1_level_value_id, '1') =
                NVL (p_dimension1_level_value, '1')
         AND NVL (tars.dim2_level_value_id, '1') =
                NVL (p_dimension2_level_value, '1')
         AND NVL (tars.dim3_level_value_id, '1') =
                NVL (p_dimension3_level_value, '1')
         AND NVL (tars.dim4_level_value_id, '1') =
                NVL (p_dimension4_level_value, '1')
         AND NVL (tars.dim5_level_value_id, '1') =
                NVL (p_dimension5_level_value, '1')
         AND NVL (tars.dim6_level_value_id, '1') =
                NVL (p_dimension6_level_value, '1')
         AND NVL (tars.dim7_level_value_id, '1') =
                NVL (p_dimension7_level_value, '1');

   rec_target        cur_target%ROWTYPE;

   CURSOR cur_compute_tar
   IS
      SELECT computing_function_id
        FROM bisbv_target_levels
       WHERE target_level_id = p_target_level_id;

   rec_compute_tar   cur_compute_tar%ROWTYPE;
BEGIN
   OPEN cur_notimelvl (p_target_level_id);
   FETCH cur_notimelvl INTO dummy;

   IF cur_notimelvl%FOUND
   THEN
      -- This Target Level id refers to Total Time and so just check
      -- the range(timelevel is -1) and no need to worry about the
      -- current period
      rec_bis_target.time_level_value_id := '-1';
   end if;

   CLOSE cur_notimelvl;


         OPEN cur_target;
         FETCH cur_target INTO rec_target;

         IF cur_target%FOUND
         THEN
            IF rec_target.target IS NULL
            THEN
               OPEN cur_compute_tar;
               FETCH cur_compute_tar INTO rec_compute_tar;
               CLOSE cur_compute_tar;
               -- exception handling required for invocation below
               rec_bis_target.target_level_id := p_target_level_id;
               rec_bis_target.plan_id := p_plan_id;
               rec_bis_target.org_level_value_id := p_org_level_value;
               rec_bis_target.dim1_level_value_id := p_dimension1_level_value;
               rec_bis_target.dim2_level_value_id := p_dimension2_level_value;
               rec_bis_target.dim3_level_value_id := p_dimension3_level_value;
               rec_bis_target.dim4_level_value_id := p_dimension4_level_value;
               rec_bis_target.dim5_level_value_id := p_dimension5_level_value;
               rec_bis_target.dim6_level_value_id := p_dimension6_level_value;
               rec_bis_target.dim7_level_value_id := p_dimension7_level_value;

               BEGIN
                  rec_target.target :=
                     NVL (
                        bis_target_pvt.get_target (
                           rec_compute_tar.computing_function_id,
                           rec_bis_target
                        ),
                        0
                     );
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     -- DBMS_OUTPUT.put_line (
                     --   'Error ' || TO_CHAR (SQLCODE) || ': ' || SQLERRM
                    -- );
                    --  RAISE;
                   NULL;
               END;
            END IF;   --end if target is null

         CLOSE cur_target;

OPEN cur_actual;
      FETCH cur_actual INTO rec_actual;

      IF cur_actual%FOUND
      THEN

            IF    (rec_actual.actual_value <
                     rec_target.target * (1 - 0.01 * rec_target.range1_low))
               OR (rec_actual.actual_value >
                     rec_target.target * (1 + 0.01 * rec_target.range1_high))
            THEN
               token := '*';
            END IF;   -- end comparison

         END IF;   -- end cur_actual%FOUND
 CLOSE cur_actual;

      END IF;   --end cur_target%FOUND



   actual_id := rec_actual.actual_id;
   actual := rec_actual.actual_value;
   target_id := rec_target.target_id;
   target := rec_target.target;
   range1_high := rec_target.range1_high;
   range1_low := rec_target.range1_low;
   range2_high := rec_target.range2_high;
   range2_low := rec_target.range2_low;
   role1_id := rec_target.notify_resp1_id;
   role2_id := rec_target.notify_resp2_id;
   time_level_value_id := rec_bis_target.time_level_value_id;
   is_in_range := token;
END pmr_content;

function region_content (
   p_target_level_id          IN       NUMBER,
   p_org_level_value          IN       VARCHAR2,
   p_dimension1_level_value   IN       VARCHAR2,
   p_dimension2_level_value   IN       VARCHAR2,
   p_dimension3_level_value   IN       VARCHAR2,
   p_dimension4_level_value   IN       VARCHAR2,
   p_dimension5_level_value   IN       VARCHAR2,
   p_dimension6_level_value   IN       VARCHAR2,
   p_dimension7_level_value   IN       VARCHAR2,
   p_plan_id                  IN       NUMBER,
   separator                  IN       VARCHAR2
  ) return VARCHAR2
is

   x_actual_id                        NUMBER := 0;
   x_actual                           NUMBER := 0;
   x_target_id                        NUMBER := 0;
   x_target                           NUMBER := 0;
   x_range1_high                      NUMBER := 0;
   x_range1_low                       NUMBER := 0;
   x_range2_high                      NUMBER := 0;
   x_range2_low                       NUMBER := 0;
   x_role1_id                         NUMBER := 0;
   x_role2_id                         NUMBER := 0;
   x_time_level_value_id              VARCHAR2(250) := '';
   x_status                           VARCHAR2(255) := '';
   x_is_in_range                      VARCHAR2(1) := '';

begin

   pmr_content(p_target_level_id, p_org_level_value, p_dimension1_level_value
       ,p_dimension2_level_value, p_dimension3_level_value,
   p_dimension4_level_value,
   p_dimension5_level_value,
   p_dimension6_level_value,
   p_dimension7_level_value,
   p_plan_id                ,
   x_actual_id ,
   x_actual    ,
   x_target_id,
   x_target,
   x_range1_high,
   x_range1_low,
   x_range2_high,
   x_range2_low,
   x_role1_id,
   x_role2_id,
   x_time_level_value_id,
   x_status,
   x_is_in_range);

return x_is_in_range ||NVL(x_actual,0) ||separator|| x_target_id;
end region_content;

-- ******************************************************************
--rmohanty
PROCEDURE build_html_banner    ------------------ VERSION 1 (definition of)
( title                 IN  VARCHAR2,
  help_target           IN  VARCHAR2
  )
  is
     nls_language_code    varchar2(2000);
     icx_report_images    varchar2(2000);
     HTML_banner          varchar2(32000);
begin
   nls_language_code := Get_NLS_Language;
   icx_report_images := Get_Images_Server;

   --- --- --- This part used to call the ICX banner builder.
---   icx_plug_utilities.toolbar(
---             p_text => title
---           , p_disp_help => 'Y'
---           , p_disp_exit => 'Y'
---           );
  --- --- ---
   Build_HTML_Banner (icx_report_images      -------------- VERSION 5 (call to)
          , help_target
          , nls_language_code
          , title
          , ''
          , FALSE
          , FALSE
          , HTML_Banner
          );
     htp.p(HTML_Banner);

end Build_HTML_Banner;

PROCEDURE build_html_banner  ------------- VERSION 2 (definition of)
( rdf_filename  IN  VARCHAR2,
  title         IN  VARCHAR2,
  menu_link     IN  VARCHAR2,
  HTML_Banner   OUT NOCOPY VARCHAR2
)
is
begin
  Build_HTML_Banner( rdf_filename  ----------------- VERSION 4 (call to)
                   , title
                   , menu_link
                   , FALSE
                   , FALSE
                   , HTML_Banner
                   );
end Build_HTML_Banner;

PROCEDURE Build_HTML_Banner
  (icx_report_images     IN  VARCHAR2,  ------- VERSION 3 (defintion of)
   more_info_directory   IN  VARCHAR2,
   nls_language_code     IN  VARCHAR2,
   title                 IN  VARCHAR2,
   menu_link             IN  VARCHAR2,
   HTML_Banner           OUT NOCOPY VARCHAR2)
is
begin

  Build_HTML_Banner( icx_report_images      ------ VERSION 5 (call to)
                   , more_info_directory
                   , nls_language_code
                   , title
                   , menu_link
                   , FALSE
                   , FALSE
                   , HTML_Banner
                   );

end Build_HTML_Banner;

PROCEDURE build_html_banner                   -------- VERSION 4 (definition of)
( rdf_filename          IN  VARCHAR2,
  title           IN  VARCHAR2,
  menu_link           IN  VARCHAR2,
  related_reports_exist IN  BOOLEAN,
  parameter_page        IN  BOOLEAN,
  HTML_Banner           OUT NOCOPY VARCHAR2
)
is
icx_report_images    varchar2(2000);
more_info_directory  varchar2(2000);
nls_language_code    varchar2(2000);
begin

  icx_report_images := Get_Images_Server;
  nls_language_code := Get_NLS_Language;

  Build_HTML_Banner( icx_report_images             ------------ VERSION 5 (call to)
                   , rdf_filename
                   , nls_language_code
                   , title
                   , menu_link
                   , related_reports_exist
                   , parameter_page
                   , HTML_Banner
                   );

end Build_HTML_Banner;

PROCEDURE build_html_banner   ------------ VERSION 5 (definition of)
  (icx_report_images     IN  VARCHAR2,
   more_info_directory   IN  VARCHAR2,
   nls_language_code     IN  VARCHAR2,
   title           IN  VARCHAR2,
   menu_link           IN  VARCHAR2,
   related_reports_exist IN  BOOLEAN,
   parameter_page        IN  BOOLEAN,
   HTML_Banner           OUT NOCOPY VARCHAR2
   )

  IS
      Related_Alt           VARCHAR2(80);
      Menu_Alt              VARCHAR2(80);
      Home_Alt              VARCHAR2(80);
      Help_Alt              VARCHAR2(80);

   Return_Alt             VARCHAR2(1000);
   Parameters_Alt         VARCHAR2(1000);
   NewMenu_Alt            VARCHAR2(80);
   NewHelp_Alt            VARCHAR2(80);
   Return_Description     VARCHAR2(1000);
   Parameters_Description VARCHAR2(1000);
   NewMenu_Description    VARCHAR2(80);
   NewHelp_Description    VARCHAR2(80);

   Related_Description   VARCHAR2(80);
   Home_Description      VARCHAR2(80);
   Menu_Description      VARCHAR2(80);
   Help_Description      VARCHAR2(80);
   Image_Directory       VARCHAR2(250);
   Home_page             VARCHAR2(2000);
   Menu_Padding          NUMBER(5);
   Home_URL              VARCHAR2(200);
   Plsql_Agent           VARCHAR2(100);
   Host_File             VARCHAR2(80);
   l_profile             VARCHAR2(2000);
   l_section_header      VARCHAR2(1000);

   l_css                 VARCHAR2(1000);
   CSSDirectory          VARCHAR2(1000);
   l_HTML_HEADER         VARCHAR2(2000);
   l_HTML_body           VARCHAR2(2000);
   l_ampersand           VARCHAR2(20):='&nbsp;';

   Parampage_Alt   VARCHAR2(32000);
   Parampage_Description VARCHAR2(32000);
BEGIN

     Get_Translated_Icon_Text ('RELATED', Related_Alt, Related_Description);
     Get_Translated_Icon_Text ('MENU', Menu_Alt, Menu_Description);
     Get_Translated_Icon_Text ('HOME', Home_Alt, Home_Description);
     Get_Translated_Icon_Text ('HELP', Help_Alt, Help_Description);
     Get_Translated_Icon_Text ('PARAMPAGE', Parampage_Alt, Parampage_Description);

     Get_Translated_Icon_Text ('RETURNTOPORTAL', Return_Alt, Return_Description);
     Get_Translated_Icon_Text ('PARAMETERS', Parameters_Alt, Parameters_Description);
     Get_Translated_Icon_Text ('NEWHELP', NewHelp_Alt, NewHelp_Description);
     Get_Translated_Icon_Text ('NEWMENU', NewMenu_Alt, NewMenu_Description);

     -- mdamle 05/31/2001 - New ICX Profile for OA_HTML, OA_MEDIA
     -- l_css := FND_PROFILE.value('ICX_OA_HTML');
     --added '/' here , otherwise the style sheet was not getting picked
     -- CSSDirectory  := '/' || FND_WEB_CONFIG.TRAIL_SLASH(l_css);
     CSSDirectory  :=BIS_REPORT_UTIL_PVT.get_html_server;

     -- mdamle 05/31/2001 - New ICX Profile for OA_HTML, OA_MEDIA
     -- Image_Directory :=  FND_WEB_CONFIG.TRAIL_SLASH(ICX_REPORT_IMAGES);
     Image_Directory := BIS_REPORT_UTIL_PVT.get_Images_Server;

     Home_URL := BIS_REPORT_UTIL_PVT.Get_Home_URL;
     l_section_header := FND_MESSAGE.GET_STRING('BIS','BIS_SPECIFY_PARAMS');

      l_HTML_Header :=
    '<head>
       <!- Banner by BISVRUTB.pls V 5 ->
       <title>' || bis_utilities_pvt.escape_html(title) || '</title>
  <LINK REL="stylesheet" HREF="'
  ||CSSDirectory
  ||'bismarli.css">
   <SCRIPT LANGUAGE="JavaScript">'
   ||
   icx_admin_sig.help_win_syntax(
               more_info_directory
               , NULL
               , 'BIS')
   ||
   '
   </SCRIPT>
   </HEAD>
  ';

    l_HTML_Body := '<body bgColor="#ffffff" link="#663300" vlink="#996633" alink="#FF6600" text="#000000">';

  HTML_Banner := l_HTML_Header||l_HTML_Body ;


     IF (Parameter_Page) THEN
        HTML_Banner := HTML_Banner ||
'<form method=post action="_action_">
<input name="hidden_run_parameters" type=hidden value="_hidden_">
<CENTEnR><P>
';
     END IF;

     HTML_Banner := HTML_Banner ||
    '<!- Banner V 5 part 2 ->
     <table border=0 cellspacing=0 cellpadding=0 width=100%>
     <tr><td rowspan=2 valign=bottom width=371>
     <table border=0 cellspacing=0 cellpadding=0 width=100%>
     <tr align=left><td height=30><img src=' || Image_Directory || 'bisorcl.gif border=no height=23
width=141></a></td>
     <tr align=left> <td valign=bottom><img src=' || Image_Directory || 'biscollg.gif border=no></a></td></td></tr>
     </table>
     </td>';

     IF (NOT Parameter_page) AND (Related_Reports_Exist)
     THEN
    menu_padding := 1050;
     ELSE
    menu_padding := 1000;
     END IF;

     IF (NOT Parameter_Page) AND (Related_Reports_Exist) THEN
        Menu_Padding := 50;
     ELSE
        Menu_Padding := 1000;
     END IF;

     IF (NOT Parameter_Page) THEN
         Menu_Padding := 50;
     ELSE
        Menu_Padding := 1000;
     END IF;

   IF (NOT Parameter_Page)
     AND (Related_Reports_Exist)
   Then menu_padding := 50;
   END IF;

-- MENU

    HTML_Banner := HTML_Banner ||
      '<td colspan=2 rowspan=2 valign=bottom align=right>
      <table border=0 cellpadding=0 align=right cellspacing=4>
        <tr valign=bottom>
          <td width=60 align=center><a href='||menu_link||'Oraclemypage.home onMouseOver="window.status=''' || ICX_UTIL.replace_onMouseOver_quotes(return_description) || '''; return true">
<img alt='||ICX_UTIL.replace_alt_quotes(Return_Alt)||' src='||Image_Directory||'bisrtrnp.gif width=32 border=0 height=32></a></td>

        </tr>
        <tr align=center valign=top>
          <td width=60><a href='||menu_link||'Oraclemypage.home onMouseOver="window.status=''' || ICX_UTIL.replace_onMouseOver_quotes(return_description) || '''; return true">
<span class="OraGlobalButtonText">'||return_description||'</span></a></td>

        </tr></table>
    </td>
    </tr></table>
   </table>';

    HTML_Banner := HTML_Banner ||
'<table Border=0 cellpadding=0 cellspacing=0 width=100%>
  <tbody>
  <tr><td bgcolor=#ffffff colspan=3 height=1><img height=1 src='||Image_Directory||'bisspace.gif width=1></td>
  </tr>
  <tr>
    <td bgcolor=#31659c colspan=2 height=21><img border=0 height=21 src='||Image_Directory||'bisspace.gif width=1></td>
    <td bgcolor=#31659c  height=21><font face="Arial, Helvetica, sans-serif" size="4" color="#ffffff">'||l_ampersand||'</font></td>
    <td background='||Image_Directory||'bisrhshd.gif height=21 width=5><img border=0 height=1
src='||Image_Directory||'bisspace.gif width=1></td>
  </tr>
  <tr>
    <td bgcolor=#31659c height=16 width=9><img border=0 height=1 src='||Image_Directory||'bisspace.gif width=9></td>
    <td bgcolor=#31659c height=16 width=5><img border=0 height=1 src='||Image_Directory||'bisspace.gif width=5></td>
    <td background='||Image_Directory||'bisbot.gif width=1000><img align=top height=16
src='||Image_Directory||'bistopar.gif width=26></td>
    <td align=left valign=top width=5><img height=8 src='||Image_Directory||'bisrend.gif width=8></td>
  </tr>
  <tr>
    <td align=left background='||Image_Directory||'bisbot.gif height=8 valign=top width=9><img height=8
src='||Image_Directory||'bislend.gif width=10></td>
    <td background='||Image_Directory||'bisbot.gif height=8 width=5><img border=0 height=1
src='||Image_Directory||'bisspace.gif width=1></td>
    <td align=left valign=top width=1000><img height=8 src='||Image_Directory||'bisarchc.gif width=9></td>
    <td width=5></td>
  </tr>
  </tbody>
</table>';


   IF (NOT Parameter_Page) THEN
    HTML_Banner := HTML_Banner ||
'<table width=100% border=0 cellspacing=0 cellpadding=15>
<tr><td><table width=100% border=0 cellspacing=0 cellpadding=0>
        <tr><td class="OraHeader"><font face="Arial, Helvetica, sans-serif" size="5" color="#336699">'||bis_utilities_pvt.escape_html(title)||'</font></td></tr>
        <tr bgcolor="#CCCC99"><td height=1><img src='||Image_Directory||'bisspace.gif width=1 height=1></td></tr>
        </table>
</td></tr>
</table>';

   ELSE
    HTML_Banner := HTML_Banner ||
'<table width=100% border=0 cellspacing=0 cellpadding=15>
<tr><td><table width=100% border=0 cellspacing=0 cellpadding=0>
        <tr><td class="OraHeader"><font face="Arial, Helvetica, sans-serif" size="5" color="#336699">'||bis_utilities_pvt.escape_html(title)||'</font></td></tr>
        <tr bgcolor="#CCCC99"><td height=1><img src='||Image_Directory||'bisspace.gif width=1 height=1></td></tr>
        <tr><td><font face="Arial, Helvetica, sans-serif" size="2">'||bis_utilities_pvt.escape_html(l_section_header)||'</font></td></tr>
        </table>
</td></tr>
</table>';
   END IF;

END Build_HTML_Banner;


PROCEDURE Get_Translated_Icon_Text (Icon_Code        IN  VARCHAR2,
                                     Icon_Meaning     OUT NOCOPY VARCHAR2,
                                     Icon_Description OUT NOCOPY VARCHAR2) IS
 BEGIN

      SELECT meaning,
             description
      INTO   Icon_Meaning,
             Icon_Description
      FROM   FND_LOOKUPS
      WHERE  lookup_code = Icon_Code
      AND    lookup_type = 'HTML_NAVIGATION_ICONS';

 EXCEPTION
      WHEN NO_DATA_FOUND THEN
           Icon_Meaning     := Icon_Code;
           Icon_Description := Icon_Code;
      WHEN OTHERS THEN
           Icon_Meaning     := Icon_Code;
           Icon_Description := Icon_Code;
 END;

FUNCTION Get_Images_Server RETURN VARCHAR2 IS
   l_Icx_Report_Images  VARCHAR2(240);
   result     boolean;
BEGIN
  -- mdamle 05/31/01 - New Profile for OA_HTML, OA_MEDIA
  -- l_Icx_Report_Images := FND_PROFILE.value('ICX_REPORT_IMAGES');

  if icx_sec.g_oa_media is null then
    result := icx_sec.validateSession;
  end if;

  if instr(icx_sec.g_oa_media, 'http:') > 0 then
    l_Icx_Report_Images := FND_WEB_CONFIG.TRAIL_SLASH(icx_sec.g_oa_media);
  else
    l_Icx_Report_Images := FND_WEB_CONFIG.WEB_SERVER ||   FND_WEB_CONFIG.TRAIL_SLASH(icx_sec.g_oa_media);
  end if;

        RETURN(l_Icx_Report_Images);
END;


FUNCTION Get_NLS_Language RETURN VARCHAR2 IS
  NLS_LANGUAGE_CODE    VARCHAR2(4);
BEGIN

  SELECT l.language_code
  INTO   NLS_LANGUAGE_CODE
  FROM   fnd_languages l,
         nls_session_parameters p
  WHERE  p.parameter = 'NLS_LANGUAGE'
  AND    p.value = l.nls_language;

  RETURN (NLS_LANGUAGE_CODE);

END Get_NLS_Language;

PROCEDURE Get_Image_file_structure (icx_report_images IN  VARCHAR2,
                                    nls_language_code IN  VARCHAR2,
                                    report_image      OUT NOCOPY VARCHAR2) IS
BEGIN

  REPORT_IMAGE   := ICX_REPORT_IMAGES || '/' || NLS_LANGUAGE_CODE || '/bisrelrp.gif' ;

END Get_Image_file_structure;

PROCEDURE build_html_banner  --------------------  VERSION 6
( title                 IN  VARCHAR2,
  help_target           IN  VARCHAR2,
  icon_show             IN  BOOLEAN
  )
  is
     nls_language_code    varchar2(2000);
     icx_report_images    varchar2(2000);
     HTML_banner          varchar2(32000);
begin
   nls_language_code := Get_NLS_Language;
   icx_report_images := Get_Images_Server;

   htp.p('<SCRIPT LANGUAGE="JavaScript">');
   ---
    icx_admin_sig.help_win_script(help_target||'TOP', NULL , 'BIS');
   --- HACK TO circumvent target slection withing a help file:
   --- icx_admin_sig.help_win_script('/OA_DOC/' || help_target ||'?', nls_language_code, 'BIS');
   htp.p('</SCRIPT>');

   --- --- --- This part used to call the ICX banner builder.
---   icx_plug_utilities.toolbar(
---             p_text => title
---           , p_disp_help => 'Y'
---           , p_disp_exit => 'Y'
---           );
  --- --- ---
   Build_HTML_Banner (icx_report_images ----------- VERSION 8 (call to )
          , '"javascript:help_window()"'
          , nls_language_code
          , title
          , ''
          , FALSE
          , FALSE
              , icon_show
          , HTML_Banner
          );
     htp.p(HTML_Banner);

end Build_HTML_Banner;

PROCEDURE Build_HTML_Banner
( rdf_filename  IN  VARCHAR2,
  title         IN  VARCHAR2,
  menu_link     IN  VARCHAR2,
  icon_show     IN  BOOLEAN,
  HTML_Banner   OUT NOCOPY VARCHAR2
)
is
begin
  Build_HTML_Banner( rdf_filename
                   , title
                   , menu_link
                   , FALSE
                   , FALSE
                   , icon_show
                   , HTML_Banner
                   );
end Build_HTML_Banner;

PROCEDURE build_html_banner    ---------- VERSION 8 (definition of)
  (icx_report_images     IN  VARCHAR2,
   more_info_directory   IN  VARCHAR2,
   nls_language_code     IN  VARCHAR2,
   title                 IN  VARCHAR2,
   menu_link             IN  VARCHAR2,
   related_reports_exist IN  BOOLEAN,
   parameter_page        IN  BOOLEAN,
   icon_show             IN  BOOLEAN,
   HTML_Banner           OUT NOCOPY VARCHAR2
   )
  IS

   Return_Alt             VARCHAR2(1000);
   Parameters_Alt         VARCHAR2(1000);
   NewMenu_Alt            VARCHAR2(80);
   NewHelp_Alt            VARCHAR2(80);
   Return_Description     VARCHAR2(1000);
   Parameters_Description VARCHAR2(1000);
   NewMenu_Description    VARCHAR2(80);
   NewHelp_Description    VARCHAR2(80);

   Related_Alt           VARCHAR2(80);
   Menu_Alt              VARCHAR2(80);
   Home_Alt              VARCHAR2(80);
   Help_Alt              VARCHAR2(80);
   Related_Description   VARCHAR2(80);
   Home_Description      VARCHAR2(80);
   Menu_Description      VARCHAR2(80);
   Help_Description      VARCHAR2(80);
   Image_Directory       VARCHAR2(250);
   Home_page             VARCHAR2(2000);
   Menu_Padding          NUMBER(5);
   Home_URL              VARCHAR2(200);
   Plsql_Agent           VARCHAR2(100);
   Host_File             VARCHAR2(80);
   l_profile             VARCHAR2(2000);
   l_ampersand         VARCHAR2(20):='&nbsp;';

BEGIN

     Get_Translated_Icon_Text ('RELATED', Related_Alt, Related_Description);
     Get_Translated_Icon_Text ('MENU', Menu_Alt, Menu_Description);
     Get_Translated_Icon_Text ('HOME', Home_Alt, Home_Description);
     Get_Translated_Icon_Text ('HELP', Help_Alt, Help_Description);

     Get_Translated_Icon_Text ('RETURNTOPORTAL', Return_Alt, Return_Description);
     Get_Translated_Icon_Text ('PARAMETERS', Parameters_Alt, Parameters_Description);
     Get_Translated_Icon_Text ('NEWHELP', NewHelp_Alt, NewHelp_Description);
     Get_Translated_Icon_Text ('NEWMENU', NewMenu_Alt, NewMenu_Description);


     Image_Directory :=  FND_WEB_CONFIG.TRAIL_SLASH(ICX_REPORT_IMAGES);
     Home_URL := BIS_REPORT_UTIL_PVT.Get_Home_URL;

     HTML_Banner := '';

     IF (Parameter_Page) THEN
        HTML_Banner := HTML_Banner ||
'<form method=post action="_action_">
<input name="hidden_run_parameters" type=hidden value="_hidden_">
<CENTER><P>
';
     END IF;

     HTML_Banner := HTML_Banner ||
     '<table border=0 cellspacing=0 cellpadding=0 width=100%>'||
     '<tr><td rowspan=2 valign=bottom width=371>'||
     '<table border=0 cellspacing=0 cellpadding=0 width=100%>'||
     '<tr align=left><td height=30><img src=' || Image_Directory || 'bisorcl.gif border=no height=23
width=141></a></td>'||
     '<tr align=left> <td valign=bottom><img src=' || Image_Directory || 'biscollg.gif border=no></a></td></td></tr>'||
     '</table>'||
     '</td>';

     IF (NOT Parameter_Page) AND (Related_Reports_Exist) THEN
        Menu_Padding := 50;
     ELSE
        Menu_Padding := 1000;
     END IF;
-- MENU


    HTML_Banner := HTML_Banner || '<font face="Arial, Helvetica, sans-serif" size="5" color="#336699">'||bis_utilities_pvt.escape_html(title)||' </font>' ||
    '<table width=100% border=0 cellspacing=0 cellpadding=15>'||
    '<tr><td>'||
      '<table width=100% border=0 cellspacing=0 cellpadding=0>'||
        '<tr bgcolor="#CCCC99">'||
         '<td height=1><img src='||Image_Directory||'bisspace.gif width=1 height=1></td></tr>'||
      '</table>'||
      '</td></tr></table>';

    HTML_Banner := HTML_Banner ||
      '<tr>'||
      '<td colspan=2 rowspan=2 valign=bottom align=right>' ||
      '<table border=0 cellpadding=0 align=right cellspacing=4>' ||
        '<tr valign=bottom>' ;
    HTML_Banner := HTML_Banner ||
          '<td width=60 align=center> <a href='||menu_Link||'Oraclemypage.home onMouseOver="window.status=''' || ICX_UTIL.replace_onMouseOver_quotes(Return_Description) || '''; return true">';
    HTML_Banner := HTML_Banner ||
'<img alt='||ICX_UTIL.replace_alt_quotes(Return_Alt)||' src='||Image_Directory||'bisrtrnp.gif width=32 border=0 height="32"></a></td>';

    HTML_Banner := HTML_Banner ||
          '<td width=60 align=center>'||
          '<a href=' || menu_Link || 'OracleNavigate.Responsibility onMouseOver="window.status=''' ||
ICX_UTIL.replace_onMouseOver_quotes(NewMenu_Description) || '''; return true"><img alt='||ICX_UTIL.replace_alt_quotes(NewMenu_Alt)||' src='||Image_Directory||'bisnmenu.gif
width="32" border=0 height=32></a></td>'; --          '<td width=60 align=center>'||

   HTML_Banner := HTML_Banner ||
          '<td width=60 align=center valign=bottom><a href="javascript:help_window()",  onMouseOver="window.status=''' || ICX_UTIL.replace_onMouseOver_quotes(NewHelp_Description) || '''; return true">';
   HTML_Banner := HTML_Banner ||
'<img alt='||ICX_UTIL.replace_alt_quotes(NewHelp_Alt)||' src='||Image_Directory||'bisnhelp.gif border=0  width =32 height=32></a></td>'||
        '</tr>';

   HTML_Banner := HTML_Banner ||
        '<tr align=center valign=top>'||
          '<td width=60><a href='||menu_Link||'Oraclemypage.home onMouseOver="window.status=''' || ICX_UTIL.replace_onMouseOver_quotes(Return_Description) || '''; return true">'||
    '<font size="2" face="Arial, Helvetica, sans-serif">Return to Portal</font></a></td>';

    HTML_Banner := HTML_Banner ||
      '<td width=60>'||
      '<a href=' || menu_Link || 'OracleNavigate.Responsibility onMouseOver="window.status=''' || ICX_UTIL.replace_onMouseOver_quotes(NewMenu_Description) || '''; return true"><font face="Arial, Helvetica, sans-serif" size="2">Menu</font></a></td>';

    HTML_Banner := HTML_Banner ||
          '<td width=60><a href="javascript:help_window()",  onMouseOver="window.status=''' || ICX_UTIL.replace_onMouseOver_quotes(NewHelp_Description) || '''; return true"><font face="Arial, Helvetica, sans-serif" size="2">Help</font></a></td>'||
        '</tr></table>'||
       '</td>'||
       '</tr></table>'||
    '</td></tr>'||
   '</table>';

    HTML_Banner := HTML_Banner ||
'<table Border=0 cellpadding=0 cellspacing=0 width=100%>'||
  '<tbody>'||
  '<tr><td bgcolor=#ffffff colspan=3 height=1><img height=1 src='||Image_Directory||'bisspace.gif width=1></td>'||
  '</tr>'||
  '<tr>';

    HTML_Banner := HTML_Banner ||
    '<td bgcolor=#31659c colspan=2 height=21><img border=0 height=21 src='||Image_Directory||'bisspace.gif width=1></td>'||
    '<td bgcolor=#31659c  height=21><font face="Arial, Helvetica, sans-serif" size="4" color="#ffffff">'||l_ampersand||'</font></td>';

    HTML_Banner := HTML_Banner ||
    '<td background='||Image_Directory||'bisrhshd.gif height=21 width=5><img border=0 height=1
src='||Image_Directory||'bisspace.gif width=1></td>'||
  '</tr>';

    HTML_Banner := HTML_Banner ||
  '<tr>'||
    '<td bgcolor=#31659c height=16 width=9><img border=0 height=1 src='||Image_Directory||'bisspace.gif width=9></td>'||
    '<td bgcolor=#31659c height=16 width=5><img border=0 height=1 src='||Image_Directory||'bisspace.gif width=5></td>';

    HTML_Banner := HTML_Banner ||
    '<td background='||Image_Directory||'bisbot.gif width=1000><img align=top height=16
src='||Image_Directory||'bistopar.gif width=26></td>'||
    '<td align=left valign=top width=5><img height=8 src='||Image_Directory||'bisrend.gif width=8></td>'||
  '</tr>';

    HTML_Banner := HTML_Banner ||
  '<tr>'||
    '<td align=left background='||Image_Directory||'bisbot.gif height=8 valign=top width=9><img height=8
src='||Image_Directory||'bislend.gif width=10></td>'||
    '<td background='||Image_Directory||'bisbot.gif height=8 width=5><img border=0 height=1
src='||Image_Directory||'bisspace.gif width=1></td>';

    HTML_Banner := HTML_Banner ||
    '<td align=left valign=top width=1000><img height=8 src='||Image_Directory||'bisarchc.gif width=9></td>'||
    '<td width=5></td>'||
  '</tr>'||
  '</tbody>'||
'</table>';

    HTML_Banner := HTML_Banner||'<br>'|| l_ampersand||l_ampersand||l_ampersand||l_ampersand||'<font face="Arial, Helvetica, sans-serif" size="5" color="#336699">'||bis_utilities_pvt.escape_html(title)||' </font>' ||
    '<table width=100% border=0 cellspacing=0 cellpadding=0>'||
    '<tr><td>';

    HTML_Banner := HTML_Banner ||
      '<table width=100% border=0 cellspacing=0 cellpadding=0>'||
        '<tr bgcolor="#CCCC99">'||
         '<td height=1><img src='||Image_Directory||'bisspace.gif width=1 height=1></td></tr>'||
      '</table>'||
      '</td></tr></table>';

END Build_HTML_Banner;


PROCEDURE build_html_banner   ---- VERSION 9 (definition of)
( rdf_filename          IN  VARCHAR2,
  title           IN  VARCHAR2,
  menu_link           IN  VARCHAR2,
  related_reports_exist IN  BOOLEAN,
  parameter_page        IN  BOOLEAN,
  icon_show             IN  BOOLEAN,
  HTML_Banner           OUT NOCOPY VARCHAR2
)
is
icx_report_images    varchar2(2000);
more_info_directory  varchar2(2000);
nls_language_code    varchar2(2000);
begin

  icx_report_images := Get_Images_Server;
  nls_language_code := Get_NLS_Language;

  Build_HTML_Banner( icx_report_images     -------- VERSION 8 (Call to)
                   , 'javascript:help_window()'
                   , nls_language_code
                   , title
                   , menu_link
                   , related_reports_exist
                   , parameter_page
                   , icon_show
                   , HTML_Banner
                   );

end Build_HTML_Banner;

PROCEDURE build_html_banner           ---------VERSION 10 (definition of)
  (icx_report_images     IN  VARCHAR2,
   more_info_directory   IN  VARCHAR2,
   nls_language_code     IN  VARCHAR2,
   title                 IN  VARCHAR2,
   menu_link             IN  VARCHAR2,
   icon_show             IN BOOLEAN,
   HTML_Banner           OUT NOCOPY VARCHAR2)
is
begin

  Build_HTML_Banner( icx_report_images    ----        VERSION 8 (call TO)
                   , more_info_directory
                   , nls_language_code
                   , title
                   , menu_link
                   , FALSE
                   , FALSE
                   , icon_show
                   , HTML_Banner
                   );

end Build_HTML_Banner;



-- End of overlapping procedures
-- rchandra 2157402
  PROCEDURE getAKRegionItemLongLabel (akRegionItemData     IN  VARCHAR2,
                                      longlabel            OUT NOCOPY VARCHAR2) AS
  l_region_code   VARCHAR2(1000);
  l_region_item   VARCHAR2(1000);
  l_akRegionItemData   VARCHAR2(2000);
  CURSOR c_label(cp_regn_code VARCHAR2,
                 cp_regn_item VARCHAR2) IS
    SELECT attribute_label_long FROM ak_region_items_vl WHERE
    region_code = cp_regn_code
    AND attribute_code = cp_regn_item;
  BEGIN
   l_akRegionItemData := TRIM(akRegionItemData);
   l_region_code := substr(l_akRegionItemData,1,instr(l_akRegionItemData,'.')-1);
   l_region_item := substr(l_akRegionItemData,instr(l_akRegionItemData,'.')+1);
   OPEN c_label(l_region_code,l_region_item);
   FETCH c_label INTO longlabel;
   CLOSE  c_label;
  EXCEPTION
    WHEN OTHERS THEN
      IF  c_label%ISOPEN THEN
          CLOSE  c_label;
      END IF;
  END getAKRegionItemLongLabel;
-- rchandra 2157402


--rmohanty

--===========================================================
-- start of change by juwang
-- 15-JAN-02 juwang  bug#2184804
--===========================================================
--============================================================
--    PROCEDURE
--      use_current_period
--
--    PURPOSE
--      If in bis_actuals_values, the actual does
--      not exist for the current period, use the period
--      that has the latest last update date
--    PARAMETERS
--
--    HISTORY
--       08JAN-2002 juwang Created for bug#2173745
--=============================================================
FUNCTION use_current_period(
  p_target_rec IN BIS_TARGET_PUB.Target_Rec_Type
 ,p_time_dimension_index IN NUMBER
 ,p_current_period_id IN VARCHAR2
 ,x_last_period_id OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
  ldv1 VARCHAR2(80);
  ldv2 VARCHAR2(80);
  ldv3 VARCHAR2(80);
  ldv4 VARCHAR2(80);
  ldv5 VARCHAR2(80);
  ldv6 VARCHAR2(80);
  ldv7 VARCHAR2(80);
  l_use_cur_period BOOLEAN := FALSE;
  l_first_rec BOOLEAN := TRUE;


       CURSOR c_actual_value IS
         SELECT
           DIMENSION1_LEVEL_VALUE
          ,DIMENSION2_LEVEL_VALUE
          ,DIMENSION3_LEVEL_VALUE
          ,DIMENSION4_LEVEL_VALUE
          ,DIMENSION5_LEVEL_VALUE
          ,DIMENSION6_LEVEL_VALUE
          ,DIMENSION7_LEVEL_VALUE
        FROM   bisbv_actuals acts
        WHERE  acts.target_level_id    = p_target_rec.target_level_id
        AND DECODE(p_time_dimension_index,
             1, 'NILL', NVL(acts.dimension1_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
             1, 'NILL', NVL(p_target_rec.dim1_level_value_id, 'NILL'))
        AND DECODE(p_time_dimension_index,
             2, 'NILL', NVL(acts.dimension2_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
                 2, 'NILL', NVL(p_target_rec.dim2_level_value_id, 'NILL'))
        AND DECODE(p_time_dimension_index,
             3, 'NILL', NVL(acts.dimension3_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
             3, 'NILL', NVL(p_target_rec.dim3_level_value_id, 'NILL'))
        AND DECODE(p_time_dimension_index,
             4, 'NILL', NVL(acts.dimension4_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
             4, 'NILL', NVL(p_target_rec.dim4_level_value_id, 'NILL'))
        AND DECODE(p_time_dimension_index,
             5, 'NILL', NVL(acts.dimension5_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
             5, 'NILL', NVL(p_target_rec.dim5_level_value_id, 'NILL'))
        AND DECODE(p_time_dimension_index,
             6, 'NILL', NVL(acts.dimension6_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
             6, 'NILL', NVL(p_target_rec.dim6_level_value_id, 'NILL'))
        AND DECODE(p_time_dimension_index,
             7, 'NILL', NVL(acts.dimension7_level_value, 'NILL'))
          = DECODE(p_time_dimension_index,
             7, 'NILL', NVL(p_target_rec.dim7_level_value_id, 'NILL'))
        ORDER BY acts.LAST_UPDATE_DATE DESC;
BEGIN

  OPEN c_actual_value;
  LOOP
    FETCH c_actual_value INTO ldv1, ldv2, ldv3, ldv4, ldv5, ldv6, ldv7;
    EXIT WHEN c_actual_value%NOTFOUND;

    IF ( l_first_rec ) THEN  -- remember the latest period
      IF     ( p_time_dimension_index = 1 ) THEN
        x_last_period_id := ldv1;
      ELSIF  ( p_time_dimension_index = 2 ) THEN
        x_last_period_id := ldv2;
      ELSIF  ( p_time_dimension_index = 3 ) THEN
        x_last_period_id := ldv3;
      ELSIF  ( p_time_dimension_index = 4 ) THEN
        x_last_period_id := ldv4;
      ELSIF  ( p_time_dimension_index = 5 ) THEN
        x_last_period_id := ldv5;
      ELSIF  ( p_time_dimension_index = 6 ) THEN
        x_last_period_id := ldv6;
      ELSIF  ( p_time_dimension_index = 7 ) THEN
        x_last_period_id := ldv7;
      END IF;

    END IF;  -- ( l_first_rec )
    l_first_rec := FALSE;

    -- check if the given period exists in actuals table
    IF    ( p_time_dimension_index = 1 ) THEN
      IF ( ldv1 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    ELSIF ( p_time_dimension_index = 2 ) THEN
      IF ( ldv2 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    ELSIF  ( p_time_dimension_index = 3 ) THEN
      IF ( ldv3 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    ELSIF  ( p_time_dimension_index = 4 ) THEN
      IF ( ldv4 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    ELSIF  ( p_time_dimension_index = 5 ) THEN
      IF ( ldv5 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    ELSIF  ( p_time_dimension_index = 6 ) THEN
      IF ( ldv6 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    ELSIF  ( p_time_dimension_index = 7 ) THEN
      IF ( ldv6 = p_current_period_id ) THEN
        l_use_cur_period := TRUE;
        EXIT;
      END IF;
    END IF;
  END LOOP;
  CLOSE c_actual_value;


  -- No row at all, should remain
  IF ( l_first_rec ) THEN
    l_use_cur_period := TRUE;
  END IF;
  RETURN l_use_cur_period;

EXCEPTION
  WHEN OTHERS THEN

    IF c_actual_value%ISOPEN THEN
      CLOSE c_actual_value;
    END IF;
    RETURN TRUE;

END use_current_period;





--============================================================
--    PROCEDURE
--       getAKFormatValue
--
--    PURPOSE
--       Tasks include
--         1. Find the format for this measure in AK
--         2. Format the p_val according to the AK display format and
--            display format type.
--         3. Only when both of the above info are null, use default
--            format.
--    PARAMETERS
--
--    HISTORY
--       09-JAN-2002 juwang Created.
--=============================================================

FUNCTION getAKFormatValue(
  p_measure_id IN NUMBER
 ,p_val IN NUMBER
  ) RETURN VARCHAR2
IS
  l_region_code VARCHAR2(30);
  l_attribute_code VARCHAR2(30);
  l_display_format VARCHAR2(150) := NULL;
  l_display_type VARCHAR2(150)  := NULL;
  l_format_mask VARCHAR2(1000);
  l_km_val NUMBER;
  l_result VARCHAR2(1000);

BEGIN
  IF ( p_val IS NULL) THEN  -- should not go here
    RETURN BIS_UTILITIES_PVT.Get_FND_Message('BIS_NONE');
  END IF;

  get_region_code( p_measure_id => p_measure_id
                  ,x_region_code => l_region_code
                  ,x_attribute_code  => l_attribute_code);

  get_ak_display_format( p_region_code => l_region_code
                        ,p_attribute_code => l_attribute_code
                        ,x_display_format => l_display_format
                        ,x_display_type => l_display_type );

  IF ( l_display_type IS NULL )  THEN
    RETURN getFormatValue(p_val);
  END IF;

  -- display type is not null

  IF ( l_display_type = c_I ) THEN   -- Integer
    RETURN getFormatValue(p_val => p_val,
          p_format_mask => NVL(l_display_format, getFormatMask(p_val, FALSE)));


  ELSIF ( l_display_type = c_F ) THEN -- Float
    RETURN getFormatValue(p_val => p_val,
          p_format_mask => NVL(l_display_format, getFormatMask(p_val, TRUE)));


  ELSIF ( l_display_type = c_K ) THEN -- thousand
    l_km_val := (p_val/c_thousand);
    l_result := getFormatValue(
        p_val => l_km_val
       ,p_format_mask => NVL(l_display_format,
                             getFormatMask(l_km_val, TRUE))) || c_K ;
    RETURN l_result;


  ELSIF ( l_display_type = c_M ) THEN  -- million
    l_km_val := (p_val/c_million);
    l_result := getFormatValue(
        p_val => l_km_val
       ,p_format_mask => NVL(l_display_format,
                             getFormatMask(l_km_val, TRUE))) || c_M ;
    RETURN l_result;
  END IF;


  -- all the other types or null
  RETURN getFormatValue(p_val);



END getAKFormatValue;



--============================================================
--    PROCEDURE
--      get_ak_display_format
--
--    PURPOSE
--       By the given region code and attribute code, it
--       sets the display format and display type in the out NOCOPY
--       parameters.
--    PARAMETERS
--
--    HISTORY
--       09-JAN-2002 juwang Created.
--============================================================
PROCEDURE get_ak_display_format(
  p_region_code IN VARCHAR2
 ,p_attribute_code IN VARCHAR2
 ,x_display_format OUT NOCOPY VARCHAR2
 ,x_display_type OUT NOCOPY VARCHAR2
) IS

  CURSOR c_ak_item IS
    SELECT attribute7, attribute14
    FROM ak_region_items
    WHERE
        region_code = p_region_code
    AND attribute_code = p_attribute_code;

  BEGIN

   IF (  (p_region_code IS NULL ) OR
         (p_attribute_code IS NULL ) ) THEN
     x_display_format := NULL;
     x_display_type := NULL;

     RETURN;
   END IF;

   OPEN c_ak_item;
   FETCH c_ak_item INTO x_display_format, x_display_type;
   CLOSE  c_ak_item;

  EXCEPTION
    WHEN OTHERS THEN
      IF  c_ak_item%ISOPEN THEN
          CLOSE  c_ak_item;
      END IF;
END get_ak_display_format;



--============================================================
--    PROCEDURE
--      get_region_code
--
--    PURPOSE
--       By the given measure/indicator id, it sets the out NOCOPY
--       parameters with ak region code and ak attribute code.
--    PARAMETERS
--
--    HISTORY
--       09-JAN-2002 juwang Created.
--============================================================
PROCEDURE get_region_code(
  p_measure_id IN NUMBER
 ,x_region_code OUT NOCOPY VARCHAR2
 ,x_attribute_code OUT NOCOPY VARCHAR2 )
IS
    l_return_status               VARCHAR2(32000);
    l_msg_count                   VARCHAR2(32000);
    l_msg_data                    VARCHAR2(32000);
    l_Measure_ID                  NUMBER ;
    l_Measure_Short_Name          VARCHAR2(30);
    l_Measure_Name                bis_indicators_tl.name%TYPE ;
    l_Description                 bis_indicators_tl.DESCRIPTION%TYPE ;
    l_Dimension1_ID               NUMBER  ;
    l_Dimension2_ID               NUMBER  ;
    l_Dimension3_ID               NUMBER  ;
    l_Dimension4_ID               NUMBER  ;
    l_Dimension5_ID               NUMBER  ;
    l_Dimension6_ID               NUMBER  ;
    l_Dimension7_ID               NUMBER  ;
    l_Unit_Of_Measure_Class       VARCHAR2(10) ;
    l_actual_data_source_type     VARCHAR2(30) ;
    l_actual_data_source          VARCHAR2(240);
    l_function_name               VARCHAR2(240) ;
    l_comparison_source           VARCHAR2(240) ;
    l_increase_in_measure         VARCHAR2(1);


BEGIN
  BIS_PMF_DEFINER_WRAPPER_PVT.Retrieve_Performance_Measure(
      P_MEASURE_ID =>  p_measure_id
     ,x_return_status => l_return_status
     ,x_msg_count => l_msg_count
     ,x_msg_data   => l_msg_data
     ,x_Measure_ID  => l_Measure_ID
     ,x_Measure_Short_Name  => l_Measure_Short_Name
     ,x_Measure_Name      => l_Measure_Name
     ,x_Description       => l_Description
     ,x_Dimension1_ID     => l_Dimension1_ID
     ,x_Dimension2_ID     => l_Dimension2_ID
     ,x_Dimension3_ID     => l_Dimension3_ID
     ,x_Dimension4_ID     => l_Dimension4_ID
     ,x_Dimension5_ID     => l_Dimension5_ID
     ,x_Dimension6_ID     => l_Dimension6_ID
     ,x_Dimension7_ID    => l_Dimension7_ID
     ,x_Unit_Of_Measure_Class    => l_Unit_Of_Measure_Class
     ,x_actual_data_source_type  => l_actual_data_source_type
     ,x_actual_data_source   => l_actual_data_source
     ,x_region_code    =>       x_region_code
     ,x_attribute_code      => x_attribute_code
     ,x_function_name         => l_function_name
     ,x_comparison_source     => l_comparison_source
     ,x_increase_in_measure   => l_increase_in_measure);



EXCEPTION
  WHEN OTHERS THEN

    x_region_code := NULL;
    x_attribute_code := NULL;
END get_region_code;


--============================================================
--    PROCEDURE
--      getFormatValue
--
--    PURPOSE
--      Default format function.
--    PARAMETERS
--
--    HISTORY
--       08JAN-2002 juwang Created.
--=============================================================
FUNCTION getFormatValue(
  p_val IN NUMBER
  ) RETURN VARCHAR2
IS
  l_wh_val NUMBER;
  l_abs_val NUMBER;
BEGIN
  IF ( p_val IS NULL) THEN  -- should not go here
    RETURN BIS_UTILITIES_PVT.Get_FND_Message('BIS_NONE');
  END IF;

  l_abs_val := ABS(p_val);
  l_wh_val := FLOOR(l_abs_val);
--  IF ( l_abs_val >= c_trillion ) THEN
--    RETURN (TO_CHAR(p_val/c_trillion, c_fmt) || c_T);

  IF ( l_abs_val >= c_billion ) THEN
    RETURN getBillionValue(p_val);

  ELSIF ( l_abs_val >= c_million ) THEN

    RETURN (TO_CHAR(p_val/c_million, c_fmt) || c_M);

  END IF;

  -- -1000000 < x < 1000000
  IF ( l_abs_val = l_wh_val ) THEN
    RETURN TO_CHAR(p_val, c_long_nod_fmt);
  END IF;

  RETURN TO_CHAR(p_val, c_longfmt);



END getFormatValue;



--============================================================
FUNCTION getFormatMask(
  p_val IN NUMBER
 ,p_show_decimal IN BOOLEAN
  ) RETURN VARCHAR2
IS

  l_num_digits NUMBER;
  l_num_thou NUMBER;
  l_counter NUMBER := 1;
  l_fmt_mask VARCHAR2(1000):='990';
BEGIN

  IF ( ABS(p_val) < 1 ) THEN
    IF ( p_show_decimal ) THEN
      l_fmt_mask := l_fmt_mask || 'D99';
    END IF;

    RETURN l_fmt_mask;
  END IF;

  l_num_digits := log(10, ABS(p_val));
  l_num_thou := CEIL((l_num_digits/3));

  FOR l_counter IN 1 .. l_num_thou LOOP
    l_fmt_mask :=  '999G' || l_fmt_mask ;
  END LOOP;

  IF ( p_show_decimal ) THEN
    l_fmt_mask := l_fmt_mask || 'D99';
  END IF;

  RETURN l_fmt_mask;

END getFormatMask;



--============================================================
--    PROCEDURE
--      getFormatValue
--
--    PURPOSE
--      Returns the value formatted by the given format mask.
--      If the given value is null, returns 'NONE'.
--      If the given format mask is null, use the default one.
--    PARAMETERS
--
--    HISTORY
--       08JAN-2002 juwang Created
--=============================================================
FUNCTION getFormatValue(
  p_val IN NUMBER
 ,p_format_mask IN VARCHAR2
  ) RETURN VARCHAR2
IS

BEGIN
  IF ( p_val IS NULL) THEN  -- should not go here
    RETURN BIS_UTILITIES_PVT.Get_FND_Message('BIS_NONE');
  END IF;

  IF ( p_format_mask IS NULL) THEN
    RETURN getFormatValue(p_val);
  END IF;

  RETURN TO_CHAR(p_val, p_format_mask);

END getFormatValue;


--============================================================
FUNCTION getBillionValue(
  p_val IN NUMBER
  ) RETURN VARCHAR2
IS
  l_bi_val NUMBER;
  l_wh_val NUMBER;
  l_abs_val NUMBER;
  l_fmt_mask VARCHAR2(100);

BEGIN

  l_bi_val := p_val/c_billion;
  l_abs_val := ABS(l_bi_val);

  IF (l_abs_val < 1) THEN
    RETURN (TO_CHAR(p_val/c_million, c_fmt) || c_M);
  END IF;


  l_wh_val := FLOOR(l_abs_val);
  l_fmt_mask := getBillionFormatMask(l_bi_val);

  IF ( l_abs_val = l_wh_val ) THEN
    RETURN (TO_CHAR( l_bi_val, l_fmt_mask) || c_B);
  END IF;



  RETURN TO_CHAR( l_bi_val, l_fmt_mask||'D99') || c_B ;

END getBillionValue;


--============================================================
-- bug#2172266
FUNCTION getBillionFormatMask(
  p_val IN NUMBER
  ) RETURN VARCHAR2
IS

  l_num_digits NUMBER;
  l_num_thou NUMBER;
  l_counter NUMBER := 1;
  l_fmt_mask VARCHAR2(1000):='990';
BEGIN

  IF ( ABS(p_val) < 1 ) THEN
    RETURN l_fmt_mask;
  END IF;

  l_num_digits := log(10, ABS(p_val));
  l_num_thou := CEIL((l_num_digits/3));

  FOR l_counter IN 1 .. l_num_thou LOOP
    l_fmt_mask :=  '999G' || l_fmt_mask ;
  END LOOP;
  RETURN l_fmt_mask;

END getBillionFormatMask;



--============================================================
PROCEDURE draw_portlet_header(
  p_status_lbl IN VARCHAR2
 ,p_measure_lbl IN VARCHAR2
 ,p_value_lbl IN VARCHAR2
 ,p_change_lbl IN VARCHAR2)
IS
BEGIN

-- style
  htp.p('<STYLE TYPE="text/css">');
  htp.p('A.OraPortletLink:link {COLOR: #663300; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt}');
  htp.p('A.OraPortletLink:active {COLOR: #663300; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt}');
  htp.p('A.OraPortletLink:visited {COLOR: #663300; FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt}');
  htp.p('.OraPortletHeaderSub1 {font-family: Arial, Helvetica, sans-serif; font-size: 9pt; color: #000000;
          background-color: #CCCC99}');
  htp.p('.OraPortletTableCellText {font-family:Arial, Helvetica, Geneva, sans-serif; font-size:9pt; text-align:left;
          background-color:#f7f7e7; color:#000000}');
  htp.p('.OraPortletTableCellNumber {font-family:Arial, Helvetica, Geneva, sans-serif; font-size:9pt; text-align:right;
          background-color:#f7f7e7; color:#000000; text-indent:1}');
  htp.p('.OraPortletBodyTextBlack { FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt}');
  htp.p('.OraPortletBodyTextGreen { FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; color: #009900}');
  htp.p('.OraPortletBodyTextRed { FONT-FAMILY: Arial, Helvetica, Geneva, sans-serif; FONT-SIZE: 9pt; color: #FF0000}');
  htp.p('.OraPortletTableCellTextBand {font-family:Arial, Helvetica, Geneva, sans-serif; font-size:9pt; text-align:left;
          background-color:#ffffff; color:#000000}');
  htp.p('.OraPortletTableCellNumberBand {font-family:Arial, Helvetica, Geneva, sans-serif; font-size:9pt; text-align:right;
          background-color:#ffffff; color:#000000; text-indent:1}');
  htp.p('</STYLE>');

  -- Table
  htp.p('            <table bgcolor=white border=0 cellpadding=3 cellspacing=0 width="100%">');


  htp.p('              <tr> ');
  htp.p('                <th id="'||p_status_lbl||'" class=OraPortletHeaderSub1 ');
  htp.p('                        style="COLOR: #336699;BORDER-TOP: #f7f7e7 1px solid"
                                 align=left  valign=bottom>'||'&nbsp;</th>');
--width="5%"
  htp.p('                <th id="'||p_measure_lbl||'" class=OraPortletHeaderSub1 ');
  htp.p('                        style="BORDER-LEFT: #cccc99 1px solid;COLOR: #336699; BORDER-TOP: #f7f7e7 1px solid" align=left valign=bottom
                                 >'||bis_utilities_pvt.escape_html(p_measure_lbl)||'</th>');
  htp.p('                <th id="'||p_value_lbl||'" class=OraPortletHeaderSub1 ');
--bug#2228061

  htp.p('                        style="BORDER-LEFT: #f7f7e7 1px solid; COLOR: #336699;BORDER-TOP: #f7f7e7 1px solid" align=right valign=bottom> &nbsp;</th>');
  htp.p('                <th id="'||p_change_lbl||'" class=OraPortletHeaderSub1 ');
  htp.p('                        style="BORDER-LEFT: #f7f7e7 1px solid;COLOR: #336699;BORDER-TOP: #f7f7e7 1px solid"
                                 align=right  valign=bottom>'||bis_utilities_pvt.escape_html(p_change_lbl)||'</th>');
  htp.p('                <th id="'||'change_img'||'" class=OraPortletHeaderSub1');
  --htp.p('                        style="BORDER-LEFT: #f7f7e7 1px solid; COLOR: #336699;BORDER-TOP: #f7f7e7 1px solid"
  htp.p('                        style="COLOR: #336699;BORDER-TOP: #f7f7e7 1px solid"  align=left valign=bottom>'||'&nbsp;</th>');
  htp.p('              </tr>');

END draw_portlet_header ;


--===========================================================
FUNCTION get_row_style(
  p_row_style IN VARCHAR2
) RETURN VARCHAR2
IS

BEGIN

  IF (p_row_style = 'Band') THEN
    RETURN NULL;
  ELSE
    RETURN 'Band';
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END get_row_style;



--============================================================
PROCEDURE draw_portlet_footer
IS
BEGIN

  htp.p('            </table>');

END draw_portlet_footer;




--============================================================
--    PROCEDURE
--      draw_status
--
--    PURPOSE
--       p_status_lbl => status header label (for ADA compliant)
--       p_row_style => style of row, white or yellow background
--       p_actual_val => actual value
--       p_target_val => target value
--       p_range1_low_pcnt => percentage for range1 low
--       p_range1_high_pcnt => percentage for range1 high

--    PARAMETERS
--
--    HISTORY
--       22-JAN-2002 juwang Created.
--============================================================
PROCEDURE draw_status(
  p_status_lbl IN VARCHAR2
 ,p_row_style IN VARCHAR2
 ,p_actual_val IN NUMBER
 ,p_target_val IN NUMBER
 ,p_range1_low_pcnt IN NUMBER
 ,p_range1_high_pcnt IN NUMBER
)
IS
  l_range1_low_val  NUMBER(20,2);
  l_range1_high_val NUMBER(20,2);

BEGIN

-- Compute the min, max value of tolerance ranges
  IF ( p_target_val IS NULL ) THEN
    l_range1_low_val := NULL;
    l_range1_high_val := NULL;

  ELSE
    l_range1_low_val := p_target_val-((p_range1_low_pcnt/100)*p_target_val);
    l_range1_high_val:= p_target_val+ ((p_range1_high_pcnt/100)*p_target_val);
  END IF;

-- If actual is inside tolerance range print in forest green color
-- bug#2187778
  IF ( (p_target_val IS NULL) OR
       (l_range1_low_val IS NULL) OR
       (l_range1_high_val IS NULL)) THEN
    draw_status(p_status_lbl, 0, p_row_style);

  -- target, low, high ranges are not null
  ELSIF ((p_actual_val >= NVL(l_range1_low_val, p_target_val)) AND
   (p_actual_val <= NVL(l_range1_high_val, p_target_val))) THEN

    draw_status(p_status_lbl, 1, p_row_style);

  -- If actual is outside tolerance range print in red color
  ELSIF  (p_actual_val < NVL(l_range1_low_val, p_target_val) OR
          p_actual_val > NVL(l_range1_high_val, p_target_val)) THEN

    draw_status(p_status_lbl, 2, p_row_style);

  ELSE
    draw_status(p_status_lbl, 0, p_row_style);

  END IF; -- actual colors
END draw_status;



--============================================================
-- p_status :
-- 0 -> None
-- 1 -> within target range
-- 2 -> outside target range
--============================================================
PROCEDURE draw_status(
  p_status_lbl IN VARCHAR2
 ,p_status IN NUMBER
 ,p_row_style IN VARCHAR2)
IS
  l_range_lbl VARCHAR2(2000); -- incr the size for 2617137
  l_in_range_lbl VARCHAR2(2000);
  l_out_range_lbl VARCHAR2(2000);
  l_gif VARCHAR2(100);
BEGIN

  l_in_range_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_WITHIN_RANGE');
  l_out_range_lbl := BIS_UTILITIES_PVT.Get_FND_Message('BIS_OUTSIDE_RANGE');
  IF ( p_status = 1 ) THEN
    l_gif := 'bisinrng.gif';
    l_range_lbl := l_in_range_lbl;
  ELSIF ( p_status = 2 ) THEN
    l_gif := 'bisourng.gif';
    l_range_lbl := l_out_range_lbl;
  ELSE
    l_gif := 'FNDINVDT.gif';
    l_range_lbl := '';
  END IF;

--width="5%"
  htp.p('                <td headers="'||p_status_lbl||'" class=OraPortletTableCellText'||p_row_style);
  htp.p('                        style="BORDER-LEFT: #cccc99 1px solid; BORDER-BOTTOM: #cccc99 1px solid;  BORDER-TOP: #f7f7e7 1px solid "  align=left> <img src="/OA_MEDIA/' || l_gif || '" width="16" height="16" alt="'||
  ICX_UTIL.replace_alt_quotes(l_range_lbl)||'">');
  htp.p('</td>');

END draw_status;




--============================================================
PROCEDURE draw_measure_name(
  p_actual_url IN VARCHAR2
 ,p_label IN VARCHAR2
 ,p_measure_lbl IN VARCHAR2
 ,p_row_style IN VARCHAR2)
IS
BEGIN
  htp.p('                <td headers="'||p_measure_lbl||'" class=OraPortletTableCellText'||p_row_style);
  htp.p('                        style="BORDER-BOTTOM: #cccc99 1px solid;  BORDER-TOP: #f7f7e7 1px solid " align=left>');
  IF p_actual_url IS NOT NULL THEN
  --htp.p('<a href="' || p_actual_url || '" >' || p_label || ' </a> '); -- 2164190 sashaik --
    htp.p(bis_utilities_pvt.escape_html(LTRIM(p_label)));
  ELSE
    htp.p(bis_utilities_pvt.escape_html(LTRIM(p_label)));
  END IF;
  htp.p('                </td>');
END draw_measure_name;



--============================================================
-- p_formatted_actual -> the value displayed in value column
--============================================================
PROCEDURE draw_actual(
  p_value_lbl IN VARCHAR2
 ,p_formatted_actual IN VARCHAR2
 ,p_row_style IN VARCHAR2)
IS

BEGIN

  htp.p('                <td headers="'|| p_value_lbl ||
  '" class=OraPortletTableCellNumber'|| p_row_style);
  htp.p('                        style="BORDER-BOTTOM: #cccc99 1px solid;BORDER-LEFT: #cccc99 1px solid" width="15%" valign="bottom" align=right nowrap> ');
  htp.p('                  <span class=OraPortletBodyTextBlack>'|| bis_utilities_pvt.escape_html(p_formatted_actual) ||'</span>');
  htp.p('                </td>');
END draw_actual;



--============================================================
--
--============================================================
PROCEDURE draw_change(
  p_change_lbl IN VARCHAR2
 ,p_change IN VARCHAR2
 ,p_img IN VARCHAR2
 ,p_arrow_alt_text IN VARCHAR2
 ,p_row_style IN VARCHAR2
)
IS

BEGIN

  htp.p('                <td headers="'|| p_change_lbl||'" class=OraPortletTableCellNumber'|| p_row_style);
  htp.p('                        style="BORDER-LEFT: #cccc99 1px solid; BORDER-BOTTOM: #cccc99 1px solid; BORDER-TOP: #f7f7e7 1px solid " align="right"  valign="bottom" nowrap>'|| bis_utilities_pvt.escape_html(p_change));
  htp.p('                </td>');

  htp.p('                <td headers="change_img"  class=OraPortletTableCellNumber'|| p_row_style);
  htp.p('                        style="
  BORDER-BOTTOM: #cccc99 1px solid;BORDER-TOP: #f7f7e7 1px solid " align="left"   valign="bottom" nowrap >');

  IF ( p_img IS NOT NULL ) THEN
    htp.p('                <img src='|| p_img||' alt="'|| ICX_UTIL.replace_alt_quotes(p_arrow_alt_text)||'"  height="12" >');
  ELSE
    htp.p('&nbsp;');
  END IF;

  htp.p('</td>');
END draw_change;




--===========================================================
FUNCTION is_authroized(
  p_cur_user_id IN PLS_INTEGER
 ,p_target_level_id IN PLS_INTEGER
) RETURN BOOLEAN

IS
  l_has_access INTEGER;
  CURSOR c1 IS
    SELECT distinct DECODE(b.user_id, NULL, 0, 1)
  FROM
    fnd_user_resp_groups b
    ,bisbv_target_levels d
    ,bis_indicator_resps e
  WHERE
        b.user_id = p_cur_user_id
  AND   d.target_level_id = p_target_level_id
  AND   e.target_level_id = d.target_level_id
  AND   b.responsibility_id = e.responsibility_id
  AND   b.start_date <= sysdate
  AND   (b.end_date IS NULL or b.end_date >= sysdate);



BEGIN

  OPEN c1;
  FETCH c1 INTO l_has_access;
  WHILE c1%FOUND LOOP
    IF ( l_has_access = 1 ) THEN
      CLOSE c1;
      RETURN TRUE;
    END IF;
    FETCH c1 INTO l_has_access;
  END LOOP;

  CLOSE c1;
  RETURN FALSE;




EXCEPTION
  WHEN OTHERS THEN
    IF c1%ISOPEN THEN CLOSE c1; END IF;
    RETURN FALSE;

END is_authroized;



--===========================================================
-- retriving actual and report url
--===========================================================
PROCEDURE get_actual(
  p_target_rec IN  BIS_TARGET_PUB.Target_Rec_Type
 ,x_actual_url OUT NOCOPY VARCHAR2
 ,x_actual_value OUT NOCOPY NUMBER
 ,x_comparison_actual_value OUT NOCOPY NUMBER
 ,x_err OUT NOCOPY VARCHAR2
)
IS

  l_act_in   BIS_ACTUAL_PUB.Actual_rec_type;    -- 2164190 sashaik
  l_act_out   BIS_ACTUAL_PUB.Actual_rec_type;   -- 2164190 sashaik
  l_msg_count     NUMBER;       -- 2164190 sashaik
  l_msg_data      VARCHAR2(32000);      -- 2164190 sashaik
  l_error_tbl     BIS_UTILITIES_PUB.Error_Tbl_Type; -- 2164190 sashaik
  l_return_status VARCHAR2(300);      -- 2164190 sashaik

BEGIN

  l_act_in.Target_level_ID      := p_target_rec.target_level_id;
  l_act_in.Dim1_Level_Value_ID := p_target_rec.dim1_level_value_id;
  l_act_in.Dim2_Level_Value_ID := p_target_rec.dim2_level_value_id;
  l_act_in.Dim3_Level_Value_ID := p_target_rec.dim3_level_value_id;
  l_act_in.Dim4_Level_Value_ID := p_target_rec.dim4_level_value_id;
  l_act_in.Dim5_Level_Value_ID := p_target_rec.dim5_level_value_id;
  l_act_in.Dim6_Level_Value_ID := p_target_rec.dim6_level_value_id;
  l_act_in.Dim7_Level_Value_ID := p_target_rec.dim7_level_value_id;

  bis_actual_pub.Retrieve_Actual
  (  p_api_version      => 1.0
  ,p_all_info           => FND_API.G_FALSE
  ,p_Actual_Rec         => l_act_in
  ,x_Actual_Rec         => l_act_out
  ,x_return_Status      => l_return_status
  ,x_msg_count          => l_msg_count
  ,x_msg_data           => l_msg_data
  ,x_error_tbl          => l_error_tbl
  );

  x_actual_url := l_act_out.Report_URL;
  x_actual_value := l_act_out.ACTUAL;
  x_comparison_actual_value := l_act_out.COMPARISON_ACTUAL_VALUE;

EXCEPTION
  WHEN OTHERS THEN
--  htp.p(l_msg_data);
    x_actual_url := NULL;
    x_actual_value := NULL;
    x_comparison_actual_value := NULL;
    x_err := SQLERRM;

END get_actual;





--===========================================================
-- retriving taget, Note: do not use BIS_TARGET_PUB.Rrieve_Target
-- Procedure.  Bug exists.
--===========================================================
PROCEDURE get_target(
  p_target_in IN  BIS_TARGET_PUB.Target_Rec_Type
 ,x_target OUT NOCOPY NUMBER
 ,x_range1_low OUT NOCOPY NUMBER
 ,x_range1_high OUT NOCOPY NUMBER
 ,x_range2_low OUT NOCOPY NUMBER
 ,x_range2_high OUT NOCOPY NUMBER
 ,x_range3_low OUT NOCOPY NUMBER
 ,x_range3_high OUT NOCOPY NUMBER
 ,x_err OUT NOCOPY VARCHAR2
)
IS

  l_comp_tar_id    NUMBER;

 -- Cursor to get the computing function id
  CURSOR c_comp_tar (p_target_level_id pls_integer) IS
    SELECT computing_function_id
    FROM bisbv_target_levels
    WHERE target_level_id = p_target_level_id;


-- Cursor to get the target ranges
-- mdamle 01/15/2001 - Use Dim6 and Dim7
  CURSOR c_target_range_rec IS
    SELECT
       target
      ,range1_low, range1_high
      ,range2_low, range2_high
      ,range3_low, range3_high
    FROM bisbv_targets  tars
    WHERE tars.target_level_id    = p_target_in.target_level_id
      -- mdamle 01/15/2001
        -- AND   tars.org_level_value_id    = p_target_in.org_level_value_id
        -- AND   NVL(tars.time_level_value_id,'NILL')
        --  = NVL(p_target_in.time_level_value_id, 'NILL')
   AND   tars.plan_id               = p_target_in.plan_id
   AND NVL(tars.dim1_level_value_id, 'NILL')
     = NVL(p_target_in.dim1_level_value_id, 'NILL')
   AND NVL(tars.dim2_level_value_id, 'NILL')
     = NVL(p_target_in.dim2_level_value_id, 'NILL')
   AND NVL(tars.dim3_level_value_id, 'NILL')
     = NVL(p_target_in.dim3_level_value_id, 'NILL')
   AND NVL(tars.dim4_level_value_id, 'NILL')
     = NVL(p_target_in.dim4_level_value_id, 'NILL')
   AND NVL(tars.dim5_level_value_id, 'NILL')
     = NVL(p_target_in.dim5_level_value_id, 'NILL')
   AND NVL(tars.dim6_level_value_id, 'NILL')
     = NVL(p_target_in.dim6_level_value_id, 'NILL')
   AND NVL(tars.dim7_level_value_id, 'NILL')
     = NVL(p_target_in.dim7_level_value_id, 'NILL');

BEGIN

  OPEN c_target_range_rec;
  FETCH c_target_range_rec INTO
    x_target
   ,x_range1_low, x_range1_high
   ,x_range2_low, x_range2_high
   ,x_range3_low, x_range3_high;

   IF c_target_range_rec%NOTFOUND THEN
     x_target := NULL;
     x_range1_low := NULL;
     x_range1_high := NULL;
     x_range2_low := NULL;
     x_range2_high := NULL;
     x_range3_low := NULL;
     x_range3_high := NULL;
   END IF;
   CLOSE c_target_range_rec;

   IF x_target IS NULL THEN

     OPEN c_comp_tar(p_target_in.target_level_id);
     FETCH c_comp_tar INTO l_comp_tar_id;
     CLOSE c_comp_tar;

     IF (l_comp_tar_id IS NOT NULL) THEN
       x_target := BIS_TARGET_PVT.Get_Target(l_comp_tar_id
       , p_target_in);
     END IF;
   END IF;



EXCEPTION

  WHEN OTHERS THEN
    IF c_target_range_rec%ISOPEN THEN CLOSE c_target_range_rec; END IF;
    IF c_comp_tar%ISOPEN THEN CLOSE c_comp_tar; END IF;
    x_target := NULL;
    x_range1_low := NULL;
    x_range1_high := NULL;
    x_range2_low := NULL;
    x_range2_high := NULL;
    x_range3_low := NULL;
    x_range3_high := NULL;
    x_err := SQLERRM;
END get_target;




--===========================================================
-- 1. Find out NOCOPY the time dimension level index and level id
-- 2. If the above exists, find out NOCOPY the current period id
--    and sets it into x_target_rec.dim[n]_level_value_id
-- 3. If the the current period id doesnt have the actual,
--    use the latest actual
-- 4. If the above does not exist, return immediately
--===========================================================
PROCEDURE get_time_dim_index(
  p_ind_selection_id IN NUMBER
 ,x_target_rec IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
 ,x_err OUT NOCOPY VARCHAR2
)
IS
  e_notimevalue EXCEPTION;
  l_time_dimension_level_id NUMBER;
  l_time_dimension_index    NUMBER;
  l_last_period_id          VARCHAR2(80) := NULL; -- bug#2173745
  l_current_period_id       VARCHAR2(32000) := NULL;
  l_current_period_name     VARCHAR2(32000) := NULL;
  isRollingLevel      NUMBER;
  level_short_name      VARCHAR2(3000);

-- meastmon 05/09/2001
-- Cursor to get the index (1 to 7) of the time dimension level and
-- the time dimension level id given a target level id.
-- If the cursor returns no rows or null, then this target level
-- doesn't have a time dimension level

  CURSOR c_time_dimension_index (p_tarid pls_integer) IS
  SELECT
    x.sequence_no,
    decode(x.sequence_no,
           1, z.dimension1_level_id,
           2, z.dimension2_level_id,
           3, z.dimension3_level_id,
           4, z.dimension4_level_id,
           5, z.dimension5_level_id,
           6, z.dimension6_level_id,
           7, z.dimension7_level_id,
           NULL) time_dimension_level_id
  FROM
    bis_indicator_dimensions x
    ,bis_dimensions y
    ,bis_target_levels z
  WHERE  x.dimension_id = y.dimension_id
  AND y.short_name=BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_TL(p_tarid,NULL)
  AND   x.indicator_id = z.indicator_id
  AND   z.target_level_id = p_tarid;



BEGIN

-- Find out NOCOPY which dimension level index corresponds to time
-- dimension level. Also get the time dimension level id

  OPEN c_time_dimension_index(x_target_rec.target_level_id);
  FETCH c_time_dimension_index INTO
    l_time_dimension_index,
    l_time_dimension_level_id;

  IF c_time_dimension_index%NOTFOUND THEN -- no time dimension level
    l_time_dimension_index := -1;
  END IF;
  CLOSE c_time_dimension_index;

  -- no time dimension level
  IF l_time_dimension_index <= 0 THEN
    RETURN;
  END IF;


  SELECT short_name
  INTO   level_short_name
  FROM   bis_levels
  WHERE  level_id = l_time_dimension_level_id;

  isRollingLevel := bis_utilities_pvt.Is_Rolling_Period_Level(level_short_name);

  IF ( isRollingLevel = 0 ) THEN

    -- Set the variable x_target_rec.dimX_level_value_id that correspond
    -- to the time dimension whith the value id of the current period.
    -- target level contain a time dimension.
    -- Get the time level value id and name to be used to get actual and target
    -- Right now this is the current period
    BIS_INDICATOR_REGION_UI_PVT.getCurrentPeriodInfo(
       p_ind_selection_id
      ,x_target_rec.target_level_id
      ,l_time_dimension_level_id
      ,l_current_period_id
      ,l_current_period_name);

    IF l_current_period_id IS NULL THEN
      -- Conflicting!! If there is time level, there is current period
      -- Only in this case we raise an excepion ignore this selection

      RAISE e_notimevalue;
    END IF;


    --bug#2173475, if current period id's actual not exist,
    --use the latest one
    IF ( NOT bis_indicator_region_ui_pvt.use_current_period(x_target_rec
                                  ,l_time_dimension_index
                                  ,l_current_period_id
                                  ,l_last_period_id) ) THEN
        -- should use last period id in query

      l_current_period_id := l_last_period_id;

    END IF;

  END IF;


  assign_time_level_value_id
  ( p_is_rolling_level  => isRollingLevel
  , p_current_period_id => l_current_period_id
  , p_time_dim_idx  => l_time_dimension_index
  , p_target_rec  => x_target_rec
  );


EXCEPTION

  WHEN e_notimevalue THEN
    x_err := 'Time dimension level exists but no current period.';
    RAISE e_notimevalue;

  WHEN OTHERS THEN
    IF c_time_dimension_index%ISOPEN THEN CLOSE c_time_dimension_index; END IF;
    x_err := SQLERRM;
END get_time_dim_index;


--===========================================================
-- Assign time level value id
--===========================================================
PROCEDURE assign_time_level_value_id
(
  p_is_rolling_level    IN NUMBER,
  p_current_period_id IN VARCHAR,
  p_time_dim_idx  IN NUMBER,
  p_target_rec    IN OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
)
IS
BEGIN

  -- Set the variable x_target_rec.dimX_level_value_id that correspond to
  -- the time dimension whith the value id of the current period.

  IF p_time_dim_idx = 1 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim1_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim1_level_value_id := '-1';
    END IF;
  ELSIF p_time_dim_idx = 2 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim2_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim2_level_value_id := '-1';
    END IF;
  ELSIF p_time_dim_idx = 3 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim3_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim3_level_value_id := '-1';
    END IF;
  ELSIF p_time_dim_idx = 4 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim4_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim4_level_value_id := '-1';
    END IF;
  ELSIF p_time_dim_idx = 5 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim5_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim5_level_value_id := '-1';
    END IF;
  ELSIF p_time_dim_idx = 6 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim6_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim6_level_value_id := '-1';
    END IF;
  ELSIF p_time_dim_idx = 7 THEN
    IF ( p_is_rolling_level = 0 ) THEN
      p_target_rec.dim7_level_value_id := p_current_period_id ;
    ELSE
      p_target_rec.dim7_level_value_id := '-1';
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END assign_time_level_value_id;



--===========================================================
-- retriving actual and report url
--===========================================================
PROCEDURE get_change(
  p_actual_value IN NUMBER
 ,p_comp_actual_value IN NUMBER
 ,p_comp_source IN VARCHAR2
 ,p_good_bad IN VARCHAR2
 ,p_improve_msg  IN VARCHAR2
 ,p_worse_msg  IN VARCHAR2
 ,x_change OUT NOCOPY NUMBER
 ,x_img OUT NOCOPY VARCHAR2
 ,x_arrow_alt_text IN OUT NOCOPY VARCHAR2
 ,x_err OUT NOCOPY VARCHAR2
)
IS
  l_long_label VARCHAR2(2000);  --2157402

BEGIN
--  1850860  -- rchandra 22-NOv-2001
-- do not calculate if there is no acutal or comp actual
  IF ( (p_comp_actual_value IS NULL) OR (p_actual_value IS NULL) ) THEN
    x_change := NULL;
    x_img := NULL;
    x_arrow_alt_text := NULL;
    x_err := NULL;
    RETURN;
  END IF;


  l_long_label := NULL;

  IF (p_comp_source IS NOT NULL) THEN  -- comparison source is not null
    BIS_INDICATOR_REGION_UI_PVT.getAKRegionItemLongLabel(p_comp_source,
    l_long_label);
    IF (l_long_label IS NOT NULL) THEN
      x_arrow_alt_text := l_long_label ||'.';
    END IF;

  END IF;



-- calculate the change %
  x_change := ((p_actual_value - p_comp_actual_value)/ ABS(p_comp_actual_value)) * 100;
-- determine the dirction of arrow and the color

  x_change := ROUND(  x_change );   -- 2309916

  IF x_change < 0 THEN
    IF p_good_bad = 'G' THEN

      x_img := c_down_green;
      x_arrow_alt_text := x_arrow_alt_text ||p_improve_msg;--2157402
    ELSIF p_good_bad = 'B' THEN
      x_img := c_down_red;
     x_arrow_alt_text := x_arrow_alt_text ||p_worse_msg; --2157402
    ELSE
      x_img := c_down_black;
    END IF;
  ELSIF x_change > 0 THEN -- 2309916
    IF p_good_bad = 'G' THEN
      x_img := c_up_green;
      x_arrow_alt_text := x_arrow_alt_text ||p_improve_msg;--2157402
    ELSIF p_good_bad = 'B' THEN
      x_img := c_up_red;
      x_arrow_alt_text := x_arrow_alt_text ||p_worse_msg; --2157402
    ELSE
      x_img := c_up_black;
    END IF;

  END IF;



EXCEPTION
  WHEN OTHERS THEN

    x_err := SQLERRM;

END get_change;


--===========================================================
-- end of change by juwang
--===========================================================

-- *******************************************************************
end bis_indicator_region_ui_pvt;

/
