--------------------------------------------------------
--  DDL for Package Body BSC_SIMULATION_VIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SIMULATION_VIEW_PVT" AS
/* $Header: BSCSIMVB.pls 120.6.12000000.1 2007/07/17 07:44:29 appldev noship $ */

FUNCTION Get_Default_Node
(
  p_indicator  IN    BSC_KPIS_B.indicator%TYPE
)RETURN NUMBER IS
 l_node_id       BSC_SYS_DATASETS_VL.dataset_id%TYPE;
BEGIN

  SELECT property_value
  INTO   l_node_id
  FROM   bsc_kpi_properties
  WHERE  indicator =  p_indicator
  AND    property_code = BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID;

  RETURN l_node_id;

EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END  Get_Default_Node;



FUNCTION Get_Format
(
  p_format_Id    IN    VARCHAR2
) RETURN VARCHAR2 IS

  l_attribute7         AK_REGION_ITEMS_VL.attribute7%TYPE;
  l_number_format      v$nls_parameters.value%TYPE;
  l_replace_format     VARCHAR2(10);
  l_Sql                VARCHAR2(32000);
  l_cursor             BSC_BIS_LOCKS_PUB.t_cursor;
  l_id                 NUMBER;
  l_name               VARCHAR(100);
  l_grouping_separator VARCHAR2(10);
  l_decimal_separator  VARCHAR2(10);


BEGIN

  l_Sql:=' SELECT format_id, '||
         ' name, '||
         ' REPLACE(FORMAT,''$'',( '||
         '                      SELECT NVL(PROPERTY_VALUE,''$'') NLS_CURRENCY '||
         '                      FROM   BSC_SYS_INIT '||
         '                      WHERE  PROPERTY_CODE =''NLS_CURRENCY'') '||
         '         ) format '||
         'FROM (  '||
         '  SELECT format_id, '||
         '         name,REPLACE(DECODE(dotpos,0,REPLACE(format,'','',:1), '||
         '         REPLACE(SUBSTR(format,0,dotpos-1),'','',:2) || REPLACE(SUBSTR(format,dotpos),''.'',:3)),''#'',''9'')FORMAT '||
         '  FROM (SELECT format_id,name,format,INSTR(format,''||l_replace_format||'') dotpos  '||
         '  FROM bsc_sys_formats)) '||
         ' WHERE format_id ='||p_format_Id;

  SELECT value
  INTO   l_number_format
  FROM  v$nls_parameters
  WHERE parameter = 'NLS_NUMERIC_CHARACTERS';

  IF(l_number_format IS NOT NULL) THEN
    l_decimal_separator   :=   SUBSTR(TRIM(l_number_format),0,1);
    l_grouping_separator  :=   SUBSTR(TRIM(l_number_format),2,2);

  ELSE
    l_grouping_separator := BSC_SIMULATION_VIEW_PVT.C_COMMA;
    l_decimal_separator  := BSC_SIMULATION_VIEW_PVT.C_DOT;
  END IF;

  OPEN l_cursor FOR l_sql USING l_grouping_separator,l_grouping_separator,
                                l_decimal_separator;
  LOOP
   FETCH l_cursor INTO l_id,l_name,l_attribute7 ;
   EXIT WHEN l_cursor%NOTFOUND;
  END LOOP;

  --PMVs requirement is to replace , with G and . with D

  l_attribute7 := REPLACE(l_attribute7,BSC_SIMULATION_VIEW_PVT.C_COMMA,'G');
  l_attribute7 := REPLACE(l_attribute7,BSC_SIMULATION_VIEW_PVT.C_DOT,'D');

  RETURN l_attribute7;

END Get_Format;


FUNCTION Get_dup_dataset_id
(
    p_tarInd              IN    NUMBER
  , p_attribute_code      IN    AK_REGION_ITEMS_VL.attribute_code%TYPE
)RETURN NUMBER IS

 l_attribute_code     AK_REGION_ITEMS_VL.attribute_code%TYPE;
 l_region_Code        AK_REGION_ITEMS_VL.region_code%TYPE;
 l_Actual_Data_Source BIS_INDICATORS.ACTUAL_DATA_SOURCE%TYPE;
 l_short_name         AK_REGION_ITEMS_VL.attribute2%TYPE;
 l_dataset_id         BSC_SYS_DATASETS_VL.dataset_id%TYPE;
BEGIN
    SELECT short_name
    INTO   l_region_Code
    FROM   bsc_kpis_b
    WHERE  config_Type =BSC_SIMULATION_VIEW_PUB.c_TYPE
    AND    indicator =  p_tarInd;

    SELECT dat.dataset_id
    INTO   l_dataset_id
    FROM   ak_region_items_vl ak
          ,bis_indicators dat
    WHERE  dat.short_name = ak.attribute2
    AND    ak.region_code =l_region_Code
    AND    ak.attribute1 ='MEASURE_NOTARGET'
    AND    ak.attribute_code = p_attribute_code;

    RETURN l_dataset_id;

EXCEPTION
  WHEN OTHERS THEN
  RETURN NULL;
END  Get_dup_dataset_id;


PROCEDURE Init_Sim_Tables_Array
(
   p_copy_Ak_Tables          IN          VARCHAR
  ,x_Table_Number            OUT NOCOPY  NUMBER
  ,x_kpi_metadata_tables     OUT NOCOPY  BSC_DESIGNER_PVT.t_kpi_metadata_tables
)
IS
  BEGIN
  x_Table_Number := 0;

  x_Table_Number := x_Table_Number + 1;
  x_kpi_metadata_tables(x_Table_Number).table_name   := 'BSC_SYS_IMAGES_MAP_TL';
  x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_SYSTEM_TABLE ;
  x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_SOURCE_CODE;
  x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
  x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.YES;


  x_Table_Number := x_Table_Number + 1;
  x_kpi_metadata_tables(x_Table_Number).table_name   := 'BSC_SYS_IMAGES';
  x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_SYSTEM_TABLE;
  x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_IMAGE_ID;
  x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
  x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.NO;


  x_Table_Number := x_Table_Number + 1;
  x_kpi_metadata_tables(x_Table_Number).table_name   := 'BSC_TAB_VIEW_LABELS_B';
  x_kpi_metadata_tables(x_Table_Number).table_type   :=  BSC_SIMULATION_VIEW_PVT.C_TAB_VIEW_TABLE ;
  x_kpi_metadata_tables(x_Table_Number).table_column :=  BSC_SIMULATION_VIEW_PVT.C_TAB_VIEW ;
  x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
  x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.NO;

  x_Table_Number := x_Table_Number + 1;
  x_kpi_metadata_tables(x_Table_Number).table_name   := 'BSC_TAB_VIEW_LABELS_TL';
  x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_TAB_VIEW_TABLE;
  x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_TAB_VIEW;
  x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
  x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.YES;

  x_Table_Number := x_Table_Number + 1;
  x_kpi_metadata_tables(x_Table_Number).table_name   := 'BSC_KPI_TREE_NODES_B';
  x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_KPI_TABLE ;
  x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_INDICATOR ;
  x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
  x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.NO;


  x_Table_Number := x_Table_Number + 1;
  x_kpi_metadata_tables(x_Table_Number).table_name   := 'BSC_KPI_TREE_NODES_TL';
  x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_KPI_TABLE ;
  x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_INDICATOR ;
  x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
  x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.YES;

  IF(p_copy_Ak_Tables=FND_API.G_TRUE)THEN

    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'AK_REGIONS';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.NO;


    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'AK_REGIONS_TL';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.YES;


    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'AK_REGION_ITEMS';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.NO;


    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'AK_REGION_ITEMS_TL';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.YES;

    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'AK_CUSTOMIZATIONS';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.NO;


    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'AK_CUSTOMIZATIONS_TL';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.YES;


    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'AK_CUSTOM_REGIONS';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.NO;


    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'AK_CUSTOM_REGIONS_TL';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.YES;

    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'AK_CUSTOM_REGION_ITEMS';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.NO;


    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'AK_CUSTOM_REGION_ITEMS_TL';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.YES;


    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'BIS_AK_CUSTOM_REGION_ITEMS';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.NO;

    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'BIS_AK_CUSTOM_REGIONS';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.NO;

    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'BIS_AK_REGION_EXTENSION';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.NO;

    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'BIS_AK_REGION_ITEM_EXTENSION';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_AK_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_AK_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.NO;


    --////////////Fnd form functions table //////////////
    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'FND_FORM_FUNCTIONS';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_FORM_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_FORM_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.NO;


    x_Table_Number := x_Table_Number + 1;
    x_kpi_metadata_tables(x_Table_Number).table_name   := 'FND_FORM_FUNCTIONS_TL';
    x_kpi_metadata_tables(x_Table_Number).table_type   := BSC_SIMULATION_VIEW_PVT.C_FORM_TABLE ;
    x_kpi_metadata_tables(x_Table_Number).table_column := BSC_SIMULATION_VIEW_PVT.C_FORM_COLUMN ;
    x_kpi_metadata_tables(x_Table_Number).duplicate_data := bsc_utility.YES;
    x_kpi_metadata_tables(x_Table_Number).mls_table    := bsc_utility.YES;

 END IF;


END Init_Sim_Tables_Array;

--//Copy_Ak_Record_Table

PROCEDURE Copy_Ak_Record_Table
( p_table_name        IN  VARCHAR2
, p_table_type        IN  VARCHAR2
, p_table_column      IN  VARCHAR2
, p_Src_kpi           IN  NUMBER
, p_Trg_kpi           IN  NUMBER
, p_new_region_code   IN  VARCHAR2
, p_new_form_function IN VARCHAR2
, p_DbLink_Name       IN VARCHAR2 := NULL
)IS


h_colum             VARCHAR2(100);
h_key_name          VARCHAR2(30);
h_condition         VARCHAR2(1000);
h_sql               VARCHAR2(32000);
x_arr_columns       BSC_UPDATE_UTIL.t_array_of_varchar2;
x_num_columns       NUMBER;
l_new_region_code   AK_REGIONS.region_code%TYPE;
l_region_code       AK_REGIONS.region_code%TYPE;
l_count             NUMBER;
l_owner             all_tab_columns.owner%TYPE;
l_new_function_id   FND_FORM_FUNCTIONS.function_id%TYPE;
l_old_function_id   FND_FORM_FUNCTIONS.function_id%TYPE;
l_parameters        FND_FORM_FUNCTIONS.parameters%TYPE;
cd                  BSC_BIS_LOCKS_PUB.t_cursor;


CURSOR c_column IS
SELECT column_name
FROM   all_tab_columns
WHERE  table_name = p_table_name
AND    owner = l_owner
ORDER  BY column_name;


BEGIN

  BSC_APPS.Init_Bsc_Apps;

  IF(INSTR(p_table_name,'BIS')>0)THEN
     SELECT DECODE(USER,BSC_APPS.get_user_schema('APPS'),BSC_APPS.get_user_schema('BIS'),USER)
     INTO l_owner FROM DUAL;
  ELSIF(INSTR(p_table_name,'FND')>0) THEN
     SELECT DECODE(USER,BSC_APPS.get_user_schema('APPS'),BSC_APPS.get_user_schema('FND'),USER)
     INTO l_owner FROM DUAL;
  ELSE
     SELECT DECODE(USER,BSC_APPS.get_user_schema('APPS'),BSC_APPS.get_user_schema('AK'),USER)
     INTO l_owner FROM DUAL;
  END IF;


  IF(p_Src_kpi IS NOT NULL AND p_Trg_kpi IS NOT NULL) THEN

     IF p_DbLink_Name IS NULL THEN
       h_sql := 'SELECT short_name FROM bsc_kpis_b WHERE  indicator = :1';
     ELSE
       h_sql := 'SELECT short_name FROM bsc_kpis_b@'|| p_DbLink_Name || ' WHERE  indicator = :1';
     END IF;
     OPEN cd FOR h_sql USING p_Src_kpi;
     FETCH cd INTO l_region_code;
     CLOSE cd;

     l_new_region_code := p_new_region_code;
     IF(p_table_type =BSC_SIMULATION_VIEW_PVT.C_FORM_TABLE)THEN
       h_key_name       := 'FUNCTION_NAME';
       l_new_function_id := p_new_form_function;
       h_condition := 'FUNCTION_NAME =''' || l_region_code || '''';

       IF(p_table_name = 'FND_FORM_FUNCTIONS_TL')THEN
         IF p_DbLink_Name IS NULL THEN
           h_sql := 'SELECT function_id FROM fnd_form_functions_vl WHERE function_name = :1';
         ELSE
           h_sql := 'SELECT function_id FROM fnd_form_functions_vl@'|| p_DbLink_Name || ' WHERE function_name = :1';
         END IF;
         OPEN cd FOR h_sql USING l_region_code;
         FETCH cd INTO l_old_function_id;
         CLOSE cd;

         h_condition := 'FUNCTION_ID ='|| l_old_function_id;
       END IF;
     ELSE
       h_key_name  := 'REGION_CODE';
       h_condition := 'REGION_CODE =''' || l_region_code || '''';
     END IF;

     x_num_columns :=0;
     OPEN c_column;
     FETCH c_column INTO h_colum;
     WHILE c_column%FOUND LOOP
       x_num_columns := x_num_columns + 1;
       x_arr_columns(x_num_columns) := h_colum;
       FETCH c_column INTO h_colum;
     END LOOP;
     CLOSE c_column;

     IF x_num_columns > 0 THEN

        h_sql:= 'INSERT INTO ( SELECT ';
        FOR i IN 1..x_num_columns LOOP
           IF i <> 1 THEN
               h_sql:= h_sql || ',';
           END IF;
               h_sql:= h_sql || x_arr_columns(i);
        END LOOP;
        h_sql:= h_sql || ' FROM  ' || p_table_name;
        h_sql:= h_sql || ' )';
        h_sql:= h_sql || ' SELECT ';
        FOR i IN 1..x_num_columns LOOP
           IF i <> 1 THEN
               h_sql:= h_sql || ',';
           END IF;

           IF UPPER(x_arr_columns(i)) = h_key_name THEN
               h_sql:= h_sql || ''''||l_new_region_code ||''''|| ' AS ' || x_arr_columns(i);
           ELSIF(UPPER(x_arr_columns(i)) = 'FUNCTION_ID') THEN
               h_sql:= h_sql || l_new_function_id || ' AS ' || x_arr_columns(i);
           ELSE
               h_sql:= h_sql || x_arr_columns(i) || ' AS ' || x_arr_columns(i);
           END IF;
        END LOOP;
        IF p_DbLink_Name IS NULL THEN
          h_sql:= h_sql || ' FROM  ' || p_table_name;
        ELSE
          h_sql:= h_sql || ' FROM  ' || p_table_name || '@'||p_DbLink_Name;
        END IF;
        h_sql:= h_sql || ' WHERE ' || h_condition;

        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
     END IF;

     IF(p_table_name = 'FND_FORM_FUNCTIONS')THEN
       UPDATE FND_FORM_FUNCTIONS
       SET PARAMETERS = REPLACE(PARAMETERS,''||l_region_code||'',''|| l_new_region_code || '')
       WHERE FUNCTION_ID =  l_new_function_id;
     END IF;

   END IF;
END Copy_Ak_Record_Table;

--/////////////////////////////////End for copy of ak tables////////////////////////

PROCEDURE Copy_Record_Table
( p_table_name      IN  VARCHAR2
, p_table_type      IN  VARCHAR2
, p_table_column    IN  VARCHAR2
, p_Src_kpi         IN  NUMBER
, p_Trg_kpi         IN  NUMBER
)IS

CURSOR c_column IS
SELECT column_name
FROM   all_tab_columns
WHERE  table_name = p_table_name
AND    owner = DECODE(USER,BSC_APPS.get_user_schema('APPS'),BSC_APPS.get_user_schema,USER)
ORDER  BY column_name;

h_colum          VARCHAR2(100);
h_key_name       VARCHAR2(30);
h_condition      VARCHAR2(1000);
h_sql            VARCHAR2(32000);
x_arr_columns    BSC_UPDATE_UTIL.t_array_of_varchar2;
x_num_columns    NUMBER;
l_next_image_id  BSC_SYS_IMAGES_MAP_TL.image_id%TYPE;
l_image_id       BSC_SYS_IMAGES_MAP_TL.image_id%TYPE;


BEGIN

  BSC_APPS.Init_Bsc_Apps;

  h_key_name := 'TAB_VIEW_ID';
  IF( p_table_column = BSC_SIMULATION_VIEW_PVT.C_SOURCE_CODE )THEN
    h_key_name := 'SOURCE_CODE';
  ELSIF (p_table_column = BSC_SIMULATION_VIEW_PVT.C_INDICATOR) THEN
    h_key_name := 'INDICATOR';
  END IF;



  x_num_columns :=0;
  OPEN c_column;
  FETCH c_column INTO h_colum;
  WHILE c_column%FOUND LOOP
     x_num_columns := x_num_columns + 1;
     x_arr_columns(x_num_columns) := h_colum;
     FETCH c_column INTO h_colum;
  END LOOP;
  CLOSE c_column;

  IF x_num_columns > 0 THEN
    IF(h_key_name = 'SOURCE_CODE') THEN
      h_condition := 'SOURCE_TYPE = 2 AND ' || h_key_name || '=' || p_Src_kpi;
    ELSIF(h_key_name = 'INDICATOR') THEN
      h_condition := 'INDICATOR =' || p_Src_kpi;
    ELSE
      h_condition := 'TAB_ID =-999 AND '|| p_table_column ||' = ' || p_Src_kpi;
    END IF;

    h_sql:= 'INSERT INTO ( SELECT ';
    FOR i IN 1..x_num_columns LOOP
       IF i <> 1 THEN
           h_sql:= h_sql || ',';
       END IF;
           h_sql:= h_sql || x_arr_columns(i);
    END LOOP;
    h_sql:= h_sql || ' FROM  ' || p_table_name;
    h_sql:= h_sql || ' )';
    h_sql:= h_sql || ' SELECT ';
    FOR i IN 1..x_num_columns LOOP
       IF i <> 1 THEN
           h_sql:= h_sql || ',';
       END IF;

       IF(p_table_name='BSC_SYS_IMAGES_MAP_TL' AND UPPER(x_arr_columns(i)) = 'IMAGE_ID') THEN

         SELECT bsc_sys_image_id_s.nextval
         INTO l_next_image_id
         FROM dual;
         h_sql:= h_sql || l_next_image_id || ' AS ' || x_arr_columns(i);
       ELSIF(p_table_name='BSC_SYS_IMAGES' AND UPPER(x_arr_columns(i)) = 'IMAGE_ID' )THEN

         SELECT DISTINCT image_id
         INTO   l_image_id
         FROM   BSC_SYS_IMAGES_MAP_TL
         WHERE SOURCE_TYPE =2
         AND   SOURCE_CODE =p_Src_kpi;

         h_condition := p_table_column ||' = ' || l_image_id;

         SELECT distinct image_id
         INTO   l_image_id
         FROM   BSC_SYS_IMAGES_MAP_TL
         WHERE SOURCE_TYPE =2
         AND   SOURCE_CODE =p_Trg_kpi;

         h_sql:= h_sql || l_image_id || ' AS ' || x_arr_columns(i);


       ELSIF UPPER(x_arr_columns(i)) = h_key_name THEN
               h_sql:= h_sql || p_Trg_kpi || ' AS ' || x_arr_columns(i);
       ELSE
           h_sql:= h_sql || x_arr_columns(i) || ' AS ' || x_arr_columns(i);
       END IF;
    END LOOP;
    h_sql:= h_sql || ' FROM  ' || p_table_name;
    h_sql:= h_sql || ' WHERE ' || h_condition;

   BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

  END IF;
END Copy_Record_Table;



PROCEDURE Duplicate_sim_metadata
(
   p_source_kpi         IN        NUMBER
  ,p_target_kpi         IN        NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
)IS

   l_Table_Number            NUMBER;
   l_kpi_metadata_tables     BSC_DESIGNER_PVT.t_kpi_metadata_tables;
   l_count                   NUMBER;
   l_link_id                 NUMBER;
   l_type                    BIS_INDICATORS.measure_type%TYPE;
   l_short_name              BIS_INDICATORS.short_name%TYPE;
   l_attribute_code          AK_REGION_ITEMS_VL.attribute_code%TYPE;
   l_region_Code             AK_REGION_ITEMS_VL.region_code%TYPE;
   l_Actual_Data_Source      BIS_INDICATORS.actual_data_source%TYPE;
   l_dataset_id              BIS_INDICATORS.dataset_id%TYPE;
   l_node_id                 BIS_INDICATORS.dataset_id%TYPE;

   CURSOR c_cust_labels IS
   SELECT DISTINCT link_id
   FROM   bsc_tab_view_labels_vl
   WHERE  tab_id =BSC_SIMULATION_VIEW_PUB.c_TAB_ID
   AND    tab_view_id =  p_source_kpi
   AND    label_type
   IN    ( BSC_CUSTOM_VIEW_UI_WRAPPER.c_type_measure,
           BSC_CUSTOM_VIEW_UI_WRAPPER.c_type_measure_actual,BSC_CUSTOM_VIEW_UI_WRAPPER.c_type_measure_change,BSC_SIMULATION_VIEW_PUB.c_TYPE_MEASURE_COLOR,BSC_CUSTOM_VIEW_UI_WRAPPER.c_type_measure_slider
         );


BEGIN
  SAVEPOINT Duplicatekpimetadata;
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  --Need to check if the records already exists for duplicate objective
  --if yes then don't need to copy any records

   SELECT COUNT(0)
   INTO   l_count
   FROM  bsc_tab_view_labels_vl
   WHERE tab_id =BSC_SIMULATION_VIEW_PUB.c_TAB_ID
   AND   tab_view_id =  p_target_kpi;

   IF( l_count =0 )THEN
      BSC_APPS.Init_Bsc_Apps;

      BSC_SIMULATION_VIEW_PVT.Init_Sim_Tables_Array
      (
         p_copy_Ak_Tables          =>  FND_API.G_FALSE
        ,x_Table_Number            =>  l_Table_Number
        ,x_kpi_metadata_tables     =>  l_kpi_metadata_tables
      );


      FOR i_index IN 1..l_Table_Number LOOP
          IF(l_kpi_metadata_tables(i_index).duplicate_data = bsc_utility.YES) THEN
             Copy_Record_Table(l_kpi_metadata_tables(i_index).table_name,l_kpi_metadata_tables(i_index).table_type,l_kpi_metadata_tables(i_index).table_column, p_source_kpi, p_target_kpi);
          END IF;
      END LOOP;

      --Here we need to update the link id of duplicate objective with the dataset ids of
      -- of the calculated kpis which were created for the duplicate objective

      SELECT short_name
      INTO   l_region_Code
      FROM   bsc_kpis_b
      WHERE  config_Type =BSC_SIMULATION_VIEW_PUB.c_TYPE
      AND    indicator =  p_source_kpi;

      FOR cd IN c_cust_labels LOOP
        l_link_id := cd.link_id;

        SELECT measure_type,actual_data_source
        INTO   l_type,l_Actual_Data_Source
        FROM   bis_indicators
        WHERE  dataset_id =  l_link_id;

        IF(l_type=BSC_SIMULATION_VIEW_PUB.c_CALCULATED_KPI)THEN

            l_attribute_code := SUBSTR(l_Actual_Data_Source, INSTR(l_Actual_Data_Source, '.') + 1,LENGTH(l_Actual_Data_Source));
            l_dataset_id := Get_dup_dataset_id
                            (
                                p_tarInd          => p_target_kpi
                              , p_attribute_code  => l_attribute_code
                            );
            IF(l_dataset_id IS NULL) THEN
               l_dataset_id:= l_link_id;
            END IF;

            UPDATE bsc_tab_view_labels_b
            SET    link_id= l_dataset_id
            WHERE  tab_id = BSC_SIMULATION_VIEW_PUB.c_TAB_ID
            AND    tab_view_id = p_target_kpi
            AND    link_id =l_link_id
            AND    label_type
            IN     ( BSC_CUSTOM_VIEW_UI_WRAPPER.c_type_measure,
                     BSC_CUSTOM_VIEW_UI_WRAPPER.c_type_measure_actual,BSC_CUSTOM_VIEW_UI_WRAPPER.c_type_measure_change,BSC_SIMULATION_VIEW_PUB.c_TYPE_MEASURE_COLOR,BSC_CUSTOM_VIEW_UI_WRAPPER.c_type_measure_slider
                   );

            UPDATE bsc_kpi_tree_nodes_b
            SET    node_id =l_dataset_id
            WHERE  indicator =p_target_kpi
            AND    node_id =l_link_id;

            UPDATE bsc_kpi_tree_nodes_tl
            SET    node_id =l_dataset_id
            WHERE  indicator =p_target_kpi
            AND    node_id =l_link_id;
        END IF;
      END LOOP;

      --now set the default node id for the duplicate objective

      SELECT a.source ,a.dataset_id
      INTO   l_type ,l_node_id
      FROM   bsc_sys_datasets_b a
            ,bsc_kpi_properties b
      WHERE  b.property_code = BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID
      AND    b.property_value =a.dataset_id
      AND    indicator =p_source_kpi;

      l_dataset_id :=  l_node_id;

      IF(l_type=BSC_SIMULATION_VIEW_PUB.c_CALC_KPI)THEN

         SELECT actual_data_source
         INTO   l_Actual_Data_Source
         FROM   bis_indicators
         WHERE  dataset_id =  l_node_id;

         l_attribute_code := SUBSTR(l_Actual_Data_Source, INSTR(l_Actual_Data_Source, '.') + 1,LENGTH(l_Actual_Data_Source));
         l_dataset_id := Get_dup_dataset_id
                         (
                             p_tarInd          => p_target_kpi
                           , p_attribute_code  => l_attribute_code
                         );
         IF(l_dataset_id IS NULL) THEN
            l_dataset_id:= l_node_id;
         END IF;
      END IF;

       BSC_SIMULATION_VIEW_PVT.set_default_node
       (
        p_indicator      =>  p_target_kpi
       ,p_default_node   =>  1
       ,p_dataset_id     =>  l_dataset_id
       ,x_return_status  =>  x_return_status
       ,x_msg_count      =>  x_msg_count
       ,x_msg_data       =>  x_msg_data
       );
        IF(x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Duplicatekpimetadata;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Duplicatekpimetadata;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
      ROLLBACK TO Duplicatekpimetadata;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Duplicate_kpi_metadata ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Duplicate_kpi_metadata ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     ROLLBACK TO Duplicatekpimetadata;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Duplicate_kpi_metadata ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Duplicate_kpi_metadata ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Duplicate_sim_metadata;


PROCEDURE Add_Or_Update_YTD
(
   p_indicator            IN      NUMBER
  ,p_YTD                  IN      VARCHAR2
  ,p_prev_YTD             IN      VARCHAR2
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
)IS
  l_count          NUMBER;
  l_region_code    ak_regions.region_code%TYPE;
  l_region_app_id  ak_regions.region_application_id%TYPE;
  l_YTD            bis_ak_region_extension.attribute21%TYPE;

  l_attribute21     bis_ak_region_extension.attribute21%TYPE;

  CURSOR c_kpi IS
  SELECT A.region_code,A.region_application_id
  FROM   bsc_kpis_b B,
         ak_regions A
  WHERE  A.region_code =B.short_name
  AND    B.indicator = p_indicator
  AND    B.config_type = BSC_SIMULATION_VIEW_PUB.c_TYPE;

BEGIN
  SAVEPOINT AddOrUpdateYTD;
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_YTD :=p_YTD;

  --We need to check if the record exists in BIS_AK_REGION_EXTENSION table
  -- if not then we need to create the record else update the record
  FOR cd IN c_kpi LOOP

    IF(cd.region_code IS NOT NULL) THEN
      SELECT COUNT(0)
      INTO   l_count
      FROM   BIS_AK_REGION_EXTENSION
      WHERE  region_code =cd.region_code;

      IF(l_YTD IS NULL) THEN
        l_YTD := BSC_SIMULATION_VIEW_PUB.c_YEAR_TO_DATE_DISABLED;
      END IF;


      IF(l_count=0) THEN

        BIS_REGION_EXTENSION_PVT.CREATE_REGION_EXTN_RECORD
        (
             p_commit     =>  FND_API.G_FALSE
            ,pRegionCode  =>  cd.region_code
            ,pRegionAppId =>  cd.region_application_id
            ,pAttribute16 =>  NULL
            ,pAttribute17 =>  NULL
            ,pAttribute18 =>  NULL
            ,pAttribute19 =>  NULL
            ,pAttribute20 =>  NULL
            ,pAttribute21 =>  l_YTD
            ,pAttribute22 =>  NULL
            ,pAttribute23 =>  NULL
            ,pAttribute24 =>  NULL
            ,pAttribute25 =>  NULL
            ,pAttribute26 =>  NULL
            ,pAttribute27 =>  NULL
            ,pAttribute28 =>  NULL
            ,pAttribute29 =>  NULL
            ,pAttribute30 =>  NULL
            ,pAttribute31 =>  NULL
            ,pAttribute32 =>  NULL
            ,pAttribute33 =>  NULL
            ,pAttribute34 =>  NULL
            ,pAttribute35 =>  NULL
            ,pAttribute36 =>  NULL
            ,pAttribute37 =>  NULL
            ,pAttribute38 =>  NULL
            ,pAttribute39 =>  NULL
            ,pAttribute40 =>  NULL
        );

      ELSE
         BIS_REGION_EXTENSION_PVT.UPDATE_REGION_EXTN_RECORD
         (
            p_commit     =>  FND_API.G_FALSE
           ,pRegionCode  =>  cd.region_code
           ,pRegionAppId =>  cd.region_application_id
           ,pAttribute16 =>  NULL
           ,pAttribute17 =>  NULL
           ,pAttribute18 =>  NULL
           ,pAttribute19 =>  NULL
           ,pAttribute20 =>  NULL
           ,pAttribute21 =>  l_YTD
           ,pAttribute22 =>  NULL
           ,pAttribute23 =>  NULL
           ,pAttribute24 =>  NULL
           ,pAttribute25 =>  NULL
           ,pAttribute26 =>  NULL
           ,pAttribute27 =>  NULL
           ,pAttribute28 =>  NULL
           ,pAttribute29 =>  NULL
           ,pAttribute30 =>  NULL
           ,pAttribute31 =>  NULL
           ,pAttribute32 =>  NULL
           ,pAttribute33 =>  NULL
           ,pAttribute34 =>  NULL
           ,pAttribute35 =>  NULL
           ,pAttribute36 =>  NULL
           ,pAttribute37 =>  NULL
           ,pAttribute38 =>  NULL
           ,pAttribute39 =>  NULL
           ,pAttribute40 =>  NULL
        );
       -- update the record
      END IF;

      --Changing the YTD will set the prototype_flag to 7 for both production mode
      --objectives and kpis

      IF(l_count=0 AND NOT (l_YTD = BSC_SIMULATION_VIEW_PUB.c_YEAR_TO_DATE_DISABLED))THEN
         BSC_DESIGNER_PVT.ActionFlag_Change(p_indicator, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color);
      ELSIF(l_count>0 AND p_prev_YTD <> l_YTD) THEN
         BSC_DESIGNER_PVT.ActionFlag_Change(p_indicator, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color);
      END IF;
      --For simulation only 1 calculation is enabled and that is
      --Year To Date

      UPDATE bsc_kpi_calculations
      SET    user_level0 =BSC_SIMULATION_VIEW_PUB.c_HIDE
            ,user_level1 =BSC_SIMULATION_VIEW_PUB.c_HIDE
      WHERE indicator =  p_indicator;

      UPDATE bsc_kpi_calculations
      SET    user_level0 =BSC_SIMULATION_VIEW_PUB.c_VISIBLE
            ,user_level1 =BSC_SIMULATION_VIEW_PUB.c_VISIBLE
      WHERE indicator =  p_indicator
      AND   calculation_id =BSC_SIMULATION_VIEW_PUB.c_YTD_CALC;

    END IF;
  END LOOP;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO AddOrUpdateYTD;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO AddOrUpdateYTD;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
      ROLLBACK TO AddOrUpdateYTD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Add_Or_Update_YTD ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Add_Or_Update_YTD ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     ROLLBACK TO AddOrUpdateYTD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Add_Or_Update_YTD ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Add_Or_Update_YTD ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Add_Or_Update_YTD;


PROCEDURE Set_Kpi_Color_Flag
(
   p_indicator            IN      NUMBER
  ,p_dataset_id           IN      NUMBER
  ,p_color_flag           IN      VARCHAR2
  ,p_color_by_total       IN      NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
)IS
  l_kpi_measure_id      bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE;
  l_kpi_measure_rec     BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec;
BEGIN
  SAVEPOINT SetKpiColorFlag;
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_kpi_measure_id := BSC_SIMULATION_VIEW_PUB.Get_Kpi_Measure_Id
                      (
                          p_indicator     =>  p_indicator
                        , p_dataset_id    =>  p_dataset_id
                      );
  --'T' Means color is disabled and 'F' means it is not disbaled
  --so Change 1 to 'F' and 0 to 'T'
  --This flag is used to show the color of the sim node in the objective layout page.
  --As of now I am passing the value as 'F' i.e to show the color always.
  --DECODE(p_color_flag,1,'F','Y')

  SELECT  DECODE(p_color_flag,1,BSC_SIMULATION_VIEW_PVT.C_SHOW_COLOR,BSC_SIMULATION_VIEW_PVT.C_DISABLE_COLOR)
  INTO    l_kpi_measure_rec.disable_color
  FROM DUAL;

  l_kpi_measure_rec.objective_id     := p_indicator;
  l_kpi_measure_rec.kpi_measure_id   := l_kpi_measure_id;
  l_kpi_measure_rec.apply_color_flag := 1;
  l_kpi_measure_rec.color_by_total   := p_color_by_total;


  BSC_KPI_MEASURE_PROPS_PUB.Update_Kpi_Measure_Props (
    p_commit           => FND_API.G_FALSE
  , p_kpi_measure_rec  => l_kpi_measure_rec
  , p_cascade_shared   => TRUE
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  );

  IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS)THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO SetKpiColorFlag;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO SetKpiColorFlag;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
      ROLLBACK TO SetKpiColorFlag;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Set_Kpi_Color_Flag ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Set_Kpi_Color_Flag ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     ROLLBACK TO SetKpiColorFlag;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Set_Kpi_Color_Flag ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Set_Kpi_Color_Flag ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Set_Kpi_Color_Flag;



PROCEDURE Set_Kpi_Color_Method
(
   p_indicator            IN      NUMBER
  ,p_dataset_id           IN      NUMBER
  ,p_color_method         IN      NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
)IS

 CURSOR c_def_node IS
 SELECT property_value
 FROM   bsc_kpi_properties
 WHERE  indicator =p_indicator
 AND    property_code =BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID;

 l_count               NUMBER;
 l_kpi_measure_id      bsc_kpi_analysis_measures_b.kpi_measure_id%TYPE;

BEGIN
  SAVEPOINT SetKpiColorMethod;
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_count :=0;

  SELECT COUNT(0)
  INTO   l_count
  FROM   bsc_sys_datasets_b
  WHERE  dataset_id= p_dataset_id
  AND    color_method =p_color_method;

  UPDATE  bsc_sys_datasets_b
  SET     color_method =p_color_method
  WHERE   dataset_id = p_dataset_id;

  l_kpi_measure_id := BSC_SIMULATION_VIEW_PUB.Get_Kpi_Measure_Id
                      (
                          p_indicator     =>  p_indicator
                        , p_dataset_id    =>  p_dataset_id
                      );
  --If the color method has been changed then set the kpi prototype_flag to 7
  -- if it also the default node then change the prototype_flag of objective to 7
  FOR cd IN c_def_node LOOP
     IF( l_count =0)THEN

      BSC_KPI_COLOR_PROPERTIES_PUB.Kpi_Prototype_Flag_Change
      (
          p_objective_id    => p_indicator
        , p_kpi_measure_id  => l_kpi_measure_id
        , p_prototype_flag  => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
        , x_return_status   => x_return_status
        , x_msg_count       => x_msg_count
        , x_msg_data        => x_msg_data
      );

      IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF(cd.property_value =p_dataset_id) THEN
        BSC_KPI_COLOR_PROPERTIES_PUB.Obj_Prototype_Flag_Change
        (
            p_objective_id   => p_indicator
          , p_prototype_flag => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
          , x_return_status  => x_return_status
          , x_msg_count      => x_msg_count
          , x_msg_data       => x_msg_data
        );
        IF(x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

     END IF;
  END LOOP;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO SetKpiColorMethod;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO SetKpiColorMethod;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
      ROLLBACK TO SetKpiColorMethod;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Set_Kpi_Color_Method ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Set_Kpi_Color_Method ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     ROLLBACK TO SetKpiColorMethod;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Set_Kpi_Color_Method ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Set_Kpi_Color_Method ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Set_Kpi_Color_Method;



PROCEDURE set_default_node
(
    p_indicator       IN         NUMBER
   ,p_default_node    IN         NUMBER
   ,p_dataset_id      IN         NUMBER
   ,x_return_status   OUT NOCOPY VARCHAR2
   ,x_msg_count       OUT NOCOPY NUMBER
   ,x_msg_data        OUT NOCOPY VARCHAR2
)IS
  l_prev_default_node     NUMBER;
  l_count                 NUMBER;
BEGIN
    IF(p_default_node=1) THEN
       SELECT COUNT(0)
       INTO   l_count
       FROM   bsc_kpi_properties
       WHERE  indicator = p_indicator
       AND    property_code  =BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID;

       IF(l_count =0)THEN
           -- INSERT DEFAULT NODE
          INSERT INTO bsc_kpi_properties
          (   indicator
            , property_code
            , property_value
            , secondary_value
          ) VALUES
          (  p_indicator
            ,BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID
            ,p_dataset_id
            ,NULL
          );
       ELSE
          SELECT property_value
          INTO   l_prev_default_node
          FROM   bsc_kpi_properties
          WHERE  indicator =p_indicator
          AND    property_code =BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID;

          IF(l_prev_default_node <> p_dataset_id) THEN
            UPDATE bsc_kpi_properties
            SET   property_value = p_dataset_id
            WHERE indicator =p_indicator
            AND   property_code =BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID;

            --BSC_DESIGNER_PVT.ActionFlag_Change(p_indicator, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color);
            --Changing the default node should only set the prototype_flag of the objective
            -- and not of the kpis.

            BSC_KPI_COLOR_PROPERTIES_PUB.Obj_Prototype_Flag_Change
            (
                p_objective_id   => p_indicator
              , p_prototype_flag => BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
              , x_return_status  => x_return_status
              , x_msg_count      => x_msg_count
              , x_msg_data       => x_msg_data
            );
            IF(x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

          END IF;
       END IF;
    END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.set_default_node ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.set_default_node ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.set_default_node ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.set_default_node ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END set_default_node;



PROCEDURE copy_sim_metadata
(
   p_source_kpi         IN        NUMBER
  ,p_target_kpi         IN        NUMBER
  ,x_return_status    OUT NOCOPY  VARCHAR2
  ,x_msg_count        OUT NOCOPY  NUMBER
  ,x_msg_data         OUT NOCOPY  VARCHAR2
)IS

l_Table_Number            NUMBER;
l_kpi_metadata_tables     BSC_DESIGNER_PVT.t_kpi_metadata_tables;
l_new_region_code         AK_REGIONS.region_code%TYPE;
l_count                   NUMBER;

CURSOR c_sim_nodes IS
SELECT node_id
FROM   bsc_kpi_tree_nodes_vl
WHERE  indicator =p_target_kpi;

l_new_function_id   FND_FORM_FUNCTIONS.function_id%TYPE;


BEGIN
  SAVEPOINT copysimmetadata;
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_APPS.Init_Bsc_Apps;

  BSC_SIMULATION_VIEW_PVT.Init_Sim_Tables_Array
  (
     p_copy_Ak_Tables          =>  FND_API.G_TRUE
    ,x_Table_Number            =>  l_Table_Number
    ,x_kpi_metadata_tables     =>  l_kpi_metadata_tables
  );

  l_new_region_code := BSC_BIS_KPI_CRUD_PUB.Generate_Unique_Region_Code();

  SELECT FND_FORM_FUNCTIONS_S.NEXTVAL
  INTO l_new_function_id
  FROM dual;


  FOR cd IN c_sim_nodes LOOP
   BSC_KPI_TREE_NODES_PKG.DELETE_ROW
   (
       X_INDICATOR =>  p_target_kpi
      ,X_NODE_ID   =>  cd.node_id
   );
  END LOOP;

  FOR i_index IN 1..l_Table_Number LOOP

    IF(l_kpi_metadata_tables(i_index).duplicate_data = bsc_utility.YES AND (l_kpi_metadata_tables(i_index).table_type<>BSC_SIMULATION_VIEW_PVT.C_AK_TABLE AND l_kpi_metadata_tables(i_index).table_type<>BSC_SIMULATION_VIEW_PVT.C_FORM_TABLE)) THEN
       Copy_Record_Table(l_kpi_metadata_tables(i_index).table_name,l_kpi_metadata_tables(i_index).table_type,l_kpi_metadata_tables(i_index).table_column, p_source_kpi, p_target_kpi);
    ELSIF(l_kpi_metadata_tables(i_index).duplicate_data = bsc_utility.YES AND l_kpi_metadata_tables(i_index).table_type=BSC_SIMULATION_VIEW_PVT.C_AK_TABLE) THEN
       Copy_Ak_Record_Table(l_kpi_metadata_tables(i_index).table_name,l_kpi_metadata_tables(i_index).table_type,l_kpi_metadata_tables(i_index).table_column, p_source_kpi, p_target_kpi,l_new_region_code,NULL);
    ELSIF(l_kpi_metadata_tables(i_index).duplicate_data = bsc_utility.YES AND l_kpi_metadata_tables(i_index).table_type=BSC_SIMULATION_VIEW_PVT.C_FORM_TABLE)THEN
       Copy_Ak_Record_Table(l_kpi_metadata_tables(i_index).table_name,l_kpi_metadata_tables(i_index).table_type,l_kpi_metadata_tables(i_index).table_column, p_source_kpi, p_target_kpi,l_new_region_code,l_new_function_id);
    END IF;
  END LOOP;

  UPDATE bsc_kpis_b
  SET    short_name =l_new_region_code
  WHERE  indicator =p_target_kpi;

  UPDATE ak_regions
  SET    attribute8 = p_target_kpi || '.'||BSC_SIMULATION_VIEW_PVT.C_DEFAULT_ANA_OPTION
  WHERE  region_code =l_new_region_code;

  UPDATE bsc_kpi_analysis_options_b
  SET    short_name  =l_new_region_code
  WHERE  indicator =p_target_kpi;

END copy_sim_metadata;


PROCEDURE Set_Ak_Format_Id
(
  p_indicator      IN          BSC_KPIS_B.indicator%TYPE
 ,p_dataset_Id     IN          BSC_SYS_DATASETS_VL.dataset_id%TYPE
 ,p_format_Id      IN          BSC_KPI_TREE_NODES_VL.format_id%TYPE
 ,x_return_status  OUT NOCOPY  VARCHAR2
 ,x_msg_count      OUT NOCOPY  NUMBER
 ,x_msg_data       OUT NOCOPY  VARCHAR2
) IS
 l_region_code      AK_REGIONS.region_code%TYPE;
 l_attribute_code   AK_REGION_ITEMS_VL.attribute_code%TYPE;
 l_meas_short_name  BIS_INDICATORS.short_name%TYPE;
 l_number_format    v$nls_parameters.value%TYPE;
 l_replace_format   VARCHAR2(10);
 l_attribute7       AK_REGION_ITEMS_VL.attribute7%TYPE;

  CURSOR c_ind IS
  SELECT short_name
  FROM   bsc_kpis_vl
  WHERE  indicator =p_indicator;

  CURSOR c_ak_items IS
  SELECT a.attribute_code,b.attribute_code AS childAttrCode
  FROM   ak_region_items_vl a,ak_region_items_vl b
  WHERE  a.region_code =b.region_code
  AND    b.attribute2(+)=a.attribute_code
  AND    a.REGION_CODE = l_region_code
  AND    a.attribute1=BSC_SIMULATION_VIEW_PVT.C_MEASURE_NOTARGET
  AND    a.attribute2= l_meas_short_name;

BEGIN
    SAVEPOINT SetAkFormatId;
    FND_MSG_PUB.INITIALIZE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR cd IN c_ind LOOP

      l_region_code := cd.short_name;
      SELECT short_name
      INTO   l_meas_short_name
      FROM   bis_indicators
      WHERE  dataset_id =p_dataset_Id;

      l_attribute7 := Get_Format(p_format_Id => p_format_Id);

      FOR cd_c IN c_ak_items LOOP

        UPDATE ak_region_items
        SET    attribute7=  l_attribute7
        WHERE  region_code =l_region_code
        AND    attribute_code= cd_c.attribute_code;


        UPDATE ak_region_items
        SET    attribute7=  l_attribute7
        WHERE  region_code =l_region_code
        AND    attribute_code= cd_c.childAttrCode;

      END LOOP;

    END LOOP;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO SetAkFormatId;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO SetAkFormatId;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
      ROLLBACK TO SetAkFormatId;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Set_Ak_Format_Id ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Set_Ak_Format_Id ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     ROLLBACK TO SetAkFormatId;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Set_Ak_Format_Id ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Set_Ak_Format_Id ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END  Set_Ak_Format_Id;



PROCEDURE Handle_Shared_Objectives
(
   p_indicator      IN          BSC_KPIS_B.indicator%TYPE
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
) IS

 CURSOR  c_kpi_ids IS
 SELECT  indicator,short_name
 FROM    BSC_KPIS_B
 WHERE   Source_Indicator  =  p_indicator
 AND     config_type =7
 AND     Prototype_Flag  <>  2;

l_Bsc_Kpi_Entity_Rec    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
l_Table_Number          NUMBER;
l_kpi_metadata_tables   BSC_DESIGNER_PVT.t_kpi_metadata_tables;
l_region_code           AK_REGIONS.region_code%TYPE;
l_function_id           FND_FORM_FUNCTIONS.function_id%TYPE;
l_source_kpi            BSC_KPIS_B.indicator%TYPE;
l_target_kpi            BSC_KPIS_B.indicator%TYPE;
l_default_node          BSC_SYS_DATASETS_VL.dataset_id%TYPE;
l_count                 NUMBER;
l_shared_Obj_Tbl        BSC_SIMULATION_VIEW_PVT.Bsc_Shared_Obj_Tbl_Type ;
l_function_name         FND_FORM_FUNCTIONS.function_name%TYPE;

BEGIN

 --First delete the entries from bsc_tab_view_labels,bsc_kpi_tree_nodes,ak_region tables
  --
  --then copy the data to the shared objectives
  --flag the objective to the same flag as master
  -- also copy the default node value to the shared objective
   SAVEPOINT HandleSharedObject;
   FND_MSG_PUB.INITIALIZE;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_count := 0;

   FOR cd IN c_kpi_ids LOOP

     l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := cd.indicator;
     l_shared_Obj_Tbl(l_count).region_code  := cd.short_name;
     l_shared_Obj_Tbl(l_count).target_kpi   := l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

     l_shared_Obj_Tbl(l_count).function_id  := BSC_BIS_KPI_CRUD_PUB.Get_Function_Id_By_Name
                                               (
                                                  p_kpi_portlet_function_name =>  cd.short_name
                                               );
     l_count := l_count + 1;

     BSC_KPI_PUB.Delete_Sim_Tree_Data
     (
         p_commit                => FND_API.G_FALSE
       , p_Bsc_Kpi_Entity_Rec    => l_Bsc_Kpi_Entity_Rec
       , x_return_status         => x_return_status
       , x_msg_count             => x_msg_count
       , x_msg_data              => x_msg_data
     );

     IF (x_return_status IS NOT NULL AND x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

   END LOOP;

   IF(l_count >0) THEN

    --Now we will initialize the tables from where we need to copy the data to sim objectives

     BSC_APPS.Init_Bsc_Apps;

     BSC_SIMULATION_VIEW_PVT.Init_Sim_Tables_Array
     (
        p_copy_Ak_Tables          =>  FND_API.G_TRUE
       ,x_Table_Number            =>  l_Table_Number
       ,x_kpi_metadata_tables     =>  l_kpi_metadata_tables
     );

     l_source_kpi   := p_indicator;
     l_default_node := Get_Default_Node(p_indicator => p_indicator);

     FOR i IN 0..l_shared_Obj_Tbl.COUNT - 1 LOOP
       l_region_code :=  l_shared_Obj_Tbl(i).region_code;
       l_target_kpi  :=  l_shared_Obj_Tbl(i).target_kpi;
       l_function_id :=  l_shared_Obj_Tbl(i).function_id ;

       FOR i_index IN 1..l_Table_Number LOOP
           IF(l_kpi_metadata_tables(i_index).duplicate_data = bsc_utility.YES AND (l_kpi_metadata_tables(i_index).table_type<>BSC_SIMULATION_VIEW_PVT.C_AK_TABLE AND l_kpi_metadata_tables(i_index).table_type<>BSC_SIMULATION_VIEW_PVT.C_FORM_TABLE)) THEN
             Copy_Record_Table(l_kpi_metadata_tables(i_index).table_name,l_kpi_metadata_tables(i_index).table_type,l_kpi_metadata_tables(i_index).table_column, l_source_kpi, l_target_kpi);
           ELSIF(l_kpi_metadata_tables(i_index).duplicate_data = bsc_utility.YES AND l_kpi_metadata_tables(i_index).table_type=BSC_SIMULATION_VIEW_PVT.C_AK_TABLE) THEN
             Copy_Ak_Record_Table(l_kpi_metadata_tables(i_index).table_name,l_kpi_metadata_tables(i_index).table_type,l_kpi_metadata_tables(i_index).table_column, l_source_kpi, l_target_kpi,l_region_code,NULL);
           ELSIF(l_kpi_metadata_tables(i_index).duplicate_data = bsc_utility.YES AND l_kpi_metadata_tables(i_index).table_type=BSC_SIMULATION_VIEW_PVT.C_FORM_TABLE)THEN
             Copy_Ak_Record_Table(l_kpi_metadata_tables(i_index).table_name,l_kpi_metadata_tables(i_index).table_type,l_kpi_metadata_tables(i_index).table_column, l_source_kpi, l_target_kpi,l_region_code,l_function_id);
           END IF;
      END LOOP;

      UPDATE ak_regions
      SET    attribute8 = l_target_kpi || '.'||BSC_SIMULATION_VIEW_PVT.C_DEFAULT_ANA_OPTION
      WHERE  region_code =l_region_code;

      IF(l_default_node IS NOT NULL) THEN

        l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Code   :=  BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID;
        l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Value  :=  l_default_node;
        l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Secondary_Value :=  BSC_SIMULATION_VIEW_PUB.C_EMPTY;
        l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id              :=  l_target_kpi;

        BSC_KPI_PVT.Update_Kpi_Properties
        (    p_commit              => FND_API.G_FALSE
            ,p_Bsc_Kpi_Entity_Rec  => l_Bsc_Kpi_Entity_Rec
            ,x_return_status       => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data
        );
        IF (x_return_status IS NOT NULL AND x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;
 END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO HandleSharedObject;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO HandleSharedObject;
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
     ROLLBACK TO HandleSharedObject;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Handle_Shared_Objectives ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Handle_Shared_Objectives ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     ROLLBACK TO HandleSharedObject;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Handle_Shared_Objectives ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Handle_Shared_Objectives ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Handle_Shared_Objectives;

/************************************************************************************
--  API name  : Copy_Dimension_Group
--  Type    : Private
--  Function  :
--      This API creates the dimension group for the Simulation Report
--      It will also attach all the chosen dimension objects to this group
************************************************************************************/

PROCEDURE Copy_Dimension_Group (
  p_commit           IN    VARCHAR2 := FND_API.G_FALSE
, p_Indicator        IN    NUMBER
, p_Region_Code      IN    VARCHAR2
, p_Old_Region_Code  IN    VARCHAR2
, p_New_Dim_Levels   IN    FND_TABLE_OF_NUMBER
, p_DbLink_Name      IN    VARCHAR2
, x_return_status    OUT   NOCOPY  VARCHAR2
, x_msg_count        OUT   NOCOPY  NUMBER
, x_msg_data         OUT   NOCOPY  VARCHAR2
) IS
  l_Count NUMBER := 0;
  l_colum        VARCHAR2(100);
  l_key_name     VARCHAR2(30);
  l_table_name   all_tables.table_name%TYPE;
  l_condition    VARCHAR2(1000);
  l_arr_columns  BSC_UPDATE_UTIL.t_array_of_varchar2;
  l_num_columns  NUMBER;
  i              NUMBER;
  l_Dim_Group_Id NUMBER;
  l_sql VARCHAR2(32000);
  TYPE c_cur_type IS REF CURSOR;
  c_cursor c_cur_type;
  l_DimObj_Sht_Names VARCHAR2(32000);
  l_kpi_metadata_tables     BSC_DESIGNER_PVT.t_kpi_metadata_tables;
  l_Bsc_Group_Id bsc_sys_dim_groups_tl.dim_group_id%TYPE;
  l_Bis_Group_Id bis_dimensions.dimension_id%TYPE;


  CURSOR c_DimObjShtNames IS
  SELECT
    short_name
  FROM
    bsc_sys_dim_levels_vl
  WHERE
    dim_level_id IN (SELECT DISTINCT
                       column_value
                     FROM
                       TABLE(CAST(p_New_Dim_Levels AS FND_TABLE_OF_NUMBER)));

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscSimCopyDimGrp;

  SELECT
    COUNT(1)
  INTO
    l_Count
  FROM
    bsc_sys_dim_groups_vl
  WHERE
    short_name = p_Region_Code;

  IF l_Count > 0 THEN
    BSC_APPS.Write_Line_Log('Dimension with short Name[ ' ||p_Region_Code||'] already exists' , BSC_APPS.OUTPUT_FILE);
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_BIS_DIMENSION_PUB.Create_Dimension (
    p_commit                =>  FND_API.G_FALSE
   ,p_dim_short_name        =>  p_Region_Code
   ,p_display_name          =>  p_Region_Code
   ,p_description           =>  p_Region_Code
   ,p_dim_obj_short_names   =>  NULL
   ,p_application_id        =>  271
   ,p_create_view           =>  1
   ,p_hide                  =>  FND_API.G_TRUE
   ,x_return_status         =>  x_return_status
   ,x_msg_count             =>  x_msg_count
   ,x_msg_data              =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FOR cd IN c_DimObjShtNames LOOP
    IF l_DimObj_Sht_Names IS NULL THEN
      l_DimObj_Sht_Names := cd.short_name || ',';
    ELSE
      l_DimObj_Sht_Names := l_DimObj_Sht_Names || cd.short_name || ',';
    END IF;
  END LOOP;
  IF LENGTH(l_DimObj_Sht_Names) > 1 THEN

    BSC_BIS_DIMENSION_PUB.Assign_Dimension_Objects (
      p_commit                =>  FND_API.G_FALSE
     ,p_dim_short_name        =>  p_Region_Code
     ,p_dim_obj_short_names   =>  l_DimObj_Sht_Names
     ,p_create_view           =>  1
     ,p_Restrict_Dim_Validate =>  NULL
     ,x_return_status         =>  x_return_status
     ,x_msg_count             =>  x_msg_count
     ,x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscSimCopyDimGrp;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscSimCopyDimGrp;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscSimCopyDimGrp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' ->BSC_SIMULATION_VIEW_PVT.Copy_Dimension_Group ';
    ELSE
      x_msg_data := SQLERRM || 'at BSC_SIMULATION_VIEW_PVT.Copy_Dimension_Group ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscSimCopyDimGrp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' ->BSC_SIMULATION_VIEW_PVT.Copy_Dimension_Group ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_SIMULATION_VIEW_PVT.Copy_Dimension_Group ';
    END IF;
END Copy_Dimension_Group;

/***************************************
 Set_Sim_Key_Values : API used to set the key item value for the simulation tree
 input              : Takes Sim Objective short_name
 creator            : ashankar 26-03-07
/****************************************/

PROCEDURE Set_Sim_Key_Values
(
   p_ind_Sht_Name   IN          BSC_KPIS_B.short_name%TYPE
  ,p_indicator      IN          BSC_KPIS_B.indicator%TYPE
  ,x_return_status  OUT NOCOPY  VARCHAR2
  ,x_msg_count      OUT NOCOPY  NUMBER
  ,x_msg_data       OUT NOCOPY  VARCHAR2
) IS

  CURSOR c_form_functions IS
  SELECT parameters
  FROM   fnd_form_functions_vl
  WHERE  function_name =p_ind_Sht_Name;

  l_parameters          FND_FORM_FUNCTIONS_VL.parameters%TYPE;
  l_dim_dimobjs_record  BSC_BIS_KPI_CRUD_PUB.BSC_VARCHAR2_TBL_TYPE;
  l_non_time_counter    NUMBER;
  l_attribute2          ak_region_items_vl.attribute2%TYPE;
  l_default_value       NUMBER;
  l_dim_sht_name        BSC_SYS_DIM_GROUPS_VL.short_name%TYPE;
  l_dim_obj_sht_name    BSC_SYS_DIM_LEVELS_VL.short_name%TYPE;
  l_dim_set_id          NUMBER :=0;

BEGIN
  FND_MSG_PUB.INITIALIZE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF(p_ind_Sht_Name IS NOT NULL)THEN

    FOR cd IN c_form_functions LOOP
      l_parameters := cd.parameters;
    END LOOP;
    IF(l_parameters IS NOT NULL)THEN

      BSC_BIS_KPI_CRUD_PUB.Get_Non_Time_Dim_And_DimObjs
      (
         p_region_code           => p_ind_Sht_Name
        ,x_non_time_dim_dimObjs  => l_dim_dimobjs_record
        ,x_non_time_counter      => l_non_time_counter
      );
      IF(l_non_time_counter >0)THEN
        FOR l_Index IN 1..l_non_time_counter LOOP
         l_attribute2 := l_dim_dimobjs_record(l_Index);
         l_default_value :=  BIS_UTIL.Get_Default_Value_From_Params
                             (
                               p_parameters  => l_parameters
                              ,p_attribute2  => l_attribute2
                             );
           --IF  l_default_value IS NULL it means key items are removed.
           l_dim_obj_sht_name:=SUBSTR(l_attribute2,INSTR(l_attribute2,BIS_UTIL.
                               C_CHAR_PLUS)+1,LENGTH(l_attribute2));

           BSC_DEFAULT_KEY_ITEM_PUB.Set_Key_Item_Value
           (
              p_indicator       => p_indicator
            , p_dim_id          => BSC_SIMULATION_VIEW_PUB.c_SIM_DIM_SET
            , p_dim_obj_sht_name=> l_dim_obj_sht_name
            , p_key_value       => l_default_value
            , x_return_status   => x_return_status
            , x_msg_count       => x_msg_count
            , x_msg_data        => x_msg_data
           );

           IF(x_return_status IS NOT NULL AND x_return_status <>FND_API.G_RET_STS_SUCCESS)THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END LOOP;
      END IF;
    END IF;
  END IF;
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
  WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Set_Sim_Key_Values ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Set_Sim_Key_Values ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_SIMULATION_VIEW_PUB.Set_Sim_Key_Values ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_SIMULATION_VIEW_PUB.Set_Sim_Key_Values ';
     END IF;
     ----DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);

END Set_Sim_Key_Values;

END BSC_SIMULATION_VIEW_PVT;

/
