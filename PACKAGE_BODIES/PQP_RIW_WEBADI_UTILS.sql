--------------------------------------------------------
--  DDL for Package Body PQP_RIW_WEBADI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_RIW_WEBADI_UTILS" as
/* $Header: pqpriwadiutl.pkb 120.15.12010000.24 2009/11/10 14:52:39 sravikum ship $ */
g_package  Varchar2(30) := 'PQP_RIW_WEBADI_UTILS.';
g_ins_upd_flag   varchar2(50) := 'D';
g_migration_flag  varchar2(10) := 'N';



-- Cursor to get the XML tags - based on interface code passed
  CURSOR csr_get_xml_tags (c_interface_code  IN VARCHAR2,
                           c_layout_code     IN VARCHAR2) IS
  Select
     fwc.FLXDU_COLUMN_XML_TAG
    ,fwc.FLXDU_SEQ_NUM
    ,fwc.FLXDU_GROUP_NAME
    ,fwc.FLXDU_COLUMN_XML_DATA
    from
     PQP_FLXDU_COLUMNS  fwc,
     bne_layout_cols blc
    where
     blc.INTERFACE_SEQ_NUM  = fwc.FLXDU_SEQ_NUM
     and blc.LAYOUT_CODE =c_layout_code
     and blc.interface_code =c_interface_code
     and blc.INTERFACE_SEQ_NUM in (Select SEQUENCE_NUM from BNE_INTERFACE_cols_b where INTERFACE_CODE =c_interface_code
     and DISPLAY_FLAG ='Y' AND sequence_num not in (19, 62, 93, 124, 155))
     and fwc.DISPLAY_FLAG ='Y'
     and fwc.entity_type in ('PERSON', 'ASSIGNMENT', 'ADDRESS')
     order by blc.sequence_num,blc.BLOCK_ID;


-- Cursor to get the Flexi XML tags - based on group name passed
  CURSOR csr_get_flex_xml_tags (c_flxdu_group_name  IN VARCHAR2 ) IS
  SELECT FLXDU_COLUMN_NAME
        ,FLXDU_COLUMN_XML_TAG
        ,FLXDU_SEQ_NUM
        ,FLXDU_GROUP_NAME
	,flxdu_column_xml_data
  FROM   PQP_FLXDU_COLUMNS
  WHERE  FLXDU_GROUP_NAME = c_flxdu_group_name
    AND  DISPLAY_FLAG ='N'
  ORDER BY FLXDU_SEQ_NUM;


-- =============================================================================
-- ~ Create_RIW_mappings_row:
-- =============================================================================
PROCEDURE Create_RIW_Mappings_row
            (p_application_id    IN   NUMBER
            ,p_new_mapping_code  IN   VARCHAR2
            ,p_user_name         IN   VARCHAR2
            ,p_data_source       IN   VARCHAR2
            ,p_new_intg_code     IN   VARCHAR2
            ,p_entity_name       IN   VARCHAR2 DEFAULT NULL) IS

-- cursor to get mappnigs row
CURSOR c_mapping_row(c_mapping_code in VARCHAR2)
IS
SELECT MAPPING_CODE
      ,OBJECT_VERSION_NUMBER
      ,INTEGRATOR_APP_ID
      ,INTEGRATOR_CODE
      ,REPORTING_FLAG
      ,REPORTING_INTERFACE_APP_ID
      ,REPORTING_INTERFACE_CODE
      ,APPLICATION_ID
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
FROM   BNE_MAPPINGS_B
WHERE  application_id = p_application_id
AND    MAPPING_CODE   = c_mapping_code;

l_mapping_row       c_mapping_row%ROWTYPE;
l_rowid             VARCHAR2(200);
no_default_layout   EXCEPTION;
l_proc              VARCHAR2(72) := g_package||'Create_RIW_Mappings_row';
l_mapping_code       VARCHAR2(50);
BEGIN

  hr_utility.set_location('Entering Mapping Rows ', 30);
  IF p_entity_name IS NULL THEN
      IF p_data_source = 'XML' THEN
         OPEN  c_mapping_row(c_mapping_code => 'PQP_FLEXI_WEBADI_XML_MAP_KEY');
      ELSIF p_data_source = 'CSV' THEN
         OPEN  c_mapping_row(c_mapping_code => 'PQP_FLEXI_WEBADI_CSV_MAP_KEY');
    --$ Take into account the case when data pump mapping has to be created
      ELSIF p_data_source = 'DP' THEN
         OPEN  c_mapping_row(c_mapping_code => 'PQP_FLEXI_WEBADI_DP_MAP_KEY');

      ELSE
         OPEN  c_mapping_row(c_mapping_code => 'PQP_FLEXI_WEBADI_HR_MAP_KEY');
      END IF;
  ELSE
      SELECT description INTO l_mapping_code FROM pqp_flxdu_columns where
      entity_type = p_entity_name and
      flxdu_column_name = 'MAPPING_CODE';
      OPEN  c_mapping_row(c_mapping_code => l_mapping_code);

  END IF;

  FETCH c_mapping_row  INTO l_mapping_row;
  IF c_mapping_row%NOTFOUND THEN
     RAISE no_default_layout;
  END IF;
  CLOSE c_mapping_row;

  -- insert the row
  BNE_MAPPINGS_PKG.insert_row
          (x_rowid                       => l_rowid
          ,x_application_id              => l_mapping_row.application_id
          ,X_MAPPING_CODE                => p_new_mapping_code
          ,x_object_version_number       => 1
          ,X_INTEGRATOR_APP_ID           => l_mapping_row.INTEGRATOR_APP_ID
          ,X_INTEGRATOR_CODE             => p_new_intg_code--l_mapping_row.INTEGRATOR_CODE
          ,X_REPORTING_FLAG              => l_mapping_row.REPORTING_FLAG
          ,X_REPORTING_INTERFACE_APP_ID  => l_mapping_row.REPORTING_INTERFACE_APP_ID
          ,X_REPORTING_INTERFACE_CODE    => l_mapping_row.REPORTING_INTERFACE_CODE
          ,X_USER_NAME                   => p_user_name
          ,X_CREATION_DATE               => Sysdate
          ,X_CREATED_BY                  => l_mapping_row.CREATED_BY
          ,X_LAST_UPDATE_DATE            => Sysdate
          ,X_LAST_UPDATED_BY             => l_mapping_row.CREATED_BY
          ,X_LAST_UPDATE_LOGIN           => l_mapping_row.CREATED_BY);

  hr_utility.set_location('Exiting Mapping rows ', 40);

END Create_RIW_mappings_row;


-- =============================================================================
-- ~ Create_RIW_Mapping_Links_Rows:
-- =============================================================================
PROCEDURE Create_RIW_Mapping_Links_Rows
                        (p_application_id      IN NUMBER
                        ,p_new_mapping_code    IN VARCHAR2
                        ,p_new_interface_code  IN VARCHAR2
                        ,p_data_source         IN VARCHAR2
                        ,p_content_out         IN VARCHAR2
                        ,p_entity_name         IN VARCHAR2 DEFAULT NULL)  IS

-- cursor to get mappings columns
CURSOR c_mapping_cols_row (c_mapping_code IN VARCHAR2)IS
SELECT INTERFACE_CODE
      ,INTERFACE_SEQ_NUM
      ,OBJECT_VERSION_NUMBER
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,LAST_UPDATE_DATE
      ,SEQUENCE_NUM
      ,INTERFACE_APP_ID
      ,CONTENT_CODE
      ,CONTENT_SEQ_NUM
      ,APPLICATION_ID
      ,MAPPING_CODE
      ,CONTENT_APP_ID
      ,DECODE_FLAG
FROM   BNE_MAPPING_LINES
WHERE  application_id  = p_application_id
AND    MAPPING_CODE    = c_mapping_code;

CURSOR c_key_flex_row (c_interface_code IN VARCHAR2
                       ,c_grp_name	IN VARCHAR2)
IS
SELECT SEQUENCE_NUM
FROM BNE_INTERFACE_COLS_B
WHERE  application_id  =  p_application_id
AND    INTERFACE_CODE  =  c_interface_code
AND 	 GROUP_NAME = c_grp_name
AND 	 VAL_TYPE='KEYFLEX';



CURSOR c_intf_cols_row (c_interface_code IN VARCHAR2
												,c_interface_seq_num IN NUMBER)
IS
SELECT APPLICATION_ID
      ,INTERFACE_CODE
      ,OBJECT_VERSION_NUMBER
      ,SEQUENCE_NUM
      ,INTERFACE_COL_TYPE
      ,INTERFACE_COL_NAME
      ,ENABLED_FLAG
      ,REQUIRED_FLAG
      ,DISPLAY_FLAG
      ,READ_ONLY_FLAG
      ,NOT_NULL_FLAG
      ,SUMMARY_FLAG
      ,MAPPING_ENABLED_FLAG
      ,DATA_TYPE
      ,FIELD_SIZE
      ,DEFAULT_TYPE
      ,DEFAULT_VALUE
      ,SEGMENT_NUMBER
      ,GROUP_NAME
      ,OA_FLEX_CODE
      ,OA_CONCAT_FLEX
      ,VAL_TYPE
      ,VAL_ID_COL
      ,VAL_MEAN_COL
      ,VAL_DESC_COL
      ,VAL_OBJ_NAME
      ,VAL_ADDL_W_C
      ,VAL_COMPONENT_APP_ID
      ,VAL_COMPONENT_CODE
      ,OA_FLEX_NUM
      ,OA_FLEX_APPLICATION_ID
      ,DISPLAY_ORDER
      ,UPLOAD_PARAM_LIST_ITEM_NUM
      ,EXPANDED_SQL_QUERY
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,LAST_UPDATE_DATE
      ,LOV_TYPE
      ,OFFLINE_LOV_ENABLED_FLAG
      ,VARIABLE_DATA_TYPE_CLASS
FROM   BNE_INTERFACE_COLS_B
WHERE  application_id  =  p_application_id
AND    INTERFACE_CODE  =  c_interface_code
AND 	 SEQUENCE_NUM = c_interface_seq_num;

l_temp_interface_seq_num BNE_MAPPING_LINES.INTERFACE_SEQ_NUM%TYPE;
l_mapping_cols_row       c_mapping_cols_row%ROWTYPE;
l_intf_cols_row       c_intf_cols_row%ROWTYPE;
l_key_flex_row        c_key_flex_row%ROWTYPE;
l_rowid                  VARCHAR2(100);
l_mapping_code           VARCHAR2(50);
l_interface_code           VARCHAR2(50);
l_kff_flag                 BOOLEAN := FALSE;
l_kff_seg_flag             BOOLEAN := FALSE;

BEGIN

  IF p_entity_name IS NULL THEN
      IF p_data_source = 'XML' THEN
         OPEN  c_mapping_cols_row(c_mapping_code => 'PQP_FLEXI_WEBADI_XML_MAP_KEY');
      ELSIF p_data_source = 'CSV' THEN
         OPEN  c_mapping_cols_row(c_mapping_code => 'PQP_FLEXI_WEBADI_CSV_MAP_KEY');
    --$ Take into account the case when data pump mapping has to be created
      ELSIF p_data_source = 'DP' THEN
         OPEN  c_mapping_cols_row(c_mapping_code => 'PQP_FLEXI_WEBADI_DP_MAP_KEY');

      ELSE
         OPEN  c_mapping_cols_row(c_mapping_code => 'PQP_FLEXI_WEBADI_HR_MAP_KEY');
      END IF;
  ELSE
      SELECT description INTO l_mapping_code FROM pqp_flxdu_columns where
      entity_type = p_entity_name and
      flxdu_column_name = 'MAPPING_CODE';
      OPEN  c_mapping_cols_row(c_mapping_code => l_mapping_code);
      SELECT description INTO l_interface_code FROM pqp_flxdu_columns where
      entity_type = p_entity_name and
      flxdu_column_name = 'INTERFACE_CODE';
      l_kff_flag := FALSE;
  END IF;

      LOOP
         FETCH c_mapping_cols_row INTO l_mapping_cols_row;
         EXIT WHEN c_mapping_cols_row%NOTFOUND;
	 --Checking the base Interface Seq number exist in selected interface number
	 --or by default provided sequence number
	 l_temp_interface_seq_num := l_mapping_cols_row.INTERFACE_SEQ_NUM;
         hr_utility.set_location(l_temp_interface_seq_num, 50);
         IF p_entity_name IS NULL THEN
             IF g_riw_data.EXISTS(l_temp_interface_seq_num) OR l_temp_interface_seq_num IN
	         (59,176,253,254,332,334,335,333,331,330,328,177,19, 62, 93, 124, 155,340,
         	350,351 --$ Include Batch Link and Exception
         	)
	     	or l_temp_interface_seq_num  between 192 and 221  --$ To include People Grp Segments
	                                                       --in mapping to download the data
	         or l_temp_interface_seq_num  between 223 and 252  --$ To include Soft Coded Kff Segments

        	 THEN
            	BNE_MAPPING_LINES_PKG.INSERT_ROW
                	(x_rowid                      => l_rowid
	                ,x_application_id             => p_application_id
        	        ,X_MAPPING_CODE               => p_new_mapping_code
                	,X_INTERFACE_APP_ID           => l_mapping_cols_row.INTERFACE_APP_ID
                	,X_INTERFACE_CODE             => p_new_interface_code
	                ,X_INTERFACE_SEQ_NUM          => l_mapping_cols_row.INTERFACE_SEQ_NUM
        	        ,X_DECODE_FLAG                => l_mapping_cols_row.DECODE_FLAG
                	,X_OBJECT_VERSION_NUMBER      => 1
	                ,X_SEQUENCE_NUM               => l_mapping_cols_row.SEQUENCE_NUM
        	        ,X_CONTENT_SEQ_NUM            => l_mapping_cols_row.CONTENT_SEQ_NUM
                	,X_CONTENT_APP_ID             => l_mapping_cols_row.CONTENT_APP_ID
	                ,X_CONTENT_CODE               => p_content_out--l_mapping_cols_row.CONTENT_CODE
        	        ,X_CREATION_DATE              => sysdate
                	,X_CREATED_BY                 => l_mapping_cols_row.CREATED_BY
	                ,X_LAST_UPDATE_DATE           => Sysdate
        	        ,X_LAST_UPDATED_BY            => l_mapping_cols_row.CREATED_BY
                	,X_LAST_UPDATE_LOGIN          => l_mapping_cols_row.CREATED_BY);
        	 END IF;
         ELSE
					--$ Cursor to get the interface column for the current interface seq num
 	         hr_utility.set_location('l_interface_code'||l_interface_code, 10);
 	         hr_utility.set_location('l_temp_interface_seq_num'||l_temp_interface_seq_num, 20);

		      OPEN  c_intf_cols_row(c_interface_code => l_interface_code
																,c_interface_seq_num => l_temp_interface_seq_num);
	        FETCH c_intf_cols_row INTO l_intf_cols_row;
					--$ Include KFF segments only if the Concatenated segment is included in the layout
	         hr_utility.set_location('l_intf_cols_row.VAL_TYPE'||l_intf_cols_row.VAL_TYPE, 10);
	         hr_utility.set_location('l_intf_cols_row.GROUP_NAME'||l_intf_cols_row.GROUP_NAME, 20);
					if(l_intf_cols_row.VAL_TYPE = 'KEYFLEXSEG') then
					     open c_key_flex_row (c_interface_code =>l_interface_code
                                    ,c_grp_name			 =>l_intf_cols_row.GROUP_NAME);
   						 FETCH c_key_flex_row into l_key_flex_row;

	         hr_utility.set_location('Inside the KEYFLEXSEG IF', 10);
	         hr_utility.set_location('l_key_flex_row.sequence_num'||l_key_flex_row.sequence_num, 20);

		           IF g_riw_data.EXISTS(l_key_flex_row.sequence_num) THEN
										l_kff_seg_flag := TRUE;
							 END IF;
							CLOSE c_key_flex_row;
					end if;
         hr_utility.set_location('Before If ', 30);

         	IF g_riw_data.EXISTS(l_temp_interface_seq_num)
						or l_kff_seg_flag
--							or ((l_temp_interface_seq_num  between 52 and 81) and (p_entity_name='JOB'))
						 THEN
				         hr_utility.set_location('Inside if ', 40);
                  BNE_MAPPING_LINES_PKG.INSERT_ROW
                	(x_rowid                      => l_rowid
	                ,x_application_id             => p_application_id
        	        ,X_MAPPING_CODE               => p_new_mapping_code
                	,X_INTERFACE_APP_ID           => l_mapping_cols_row.INTERFACE_APP_ID
                	,X_INTERFACE_CODE             => p_new_interface_code
	                ,X_INTERFACE_SEQ_NUM          => l_mapping_cols_row.INTERFACE_SEQ_NUM
        	        ,X_DECODE_FLAG                => l_mapping_cols_row.DECODE_FLAG
                	,X_OBJECT_VERSION_NUMBER      => 1
	                ,X_SEQUENCE_NUM               => l_mapping_cols_row.SEQUENCE_NUM
        	        ,X_CONTENT_SEQ_NUM            => l_mapping_cols_row.CONTENT_SEQ_NUM
                	,X_CONTENT_APP_ID             => l_mapping_cols_row.CONTENT_APP_ID
	                ,X_CONTENT_CODE               => p_content_out--l_mapping_cols_row.CONTENT_CODE
        	        ,X_CREATION_DATE              => sysdate
                	,X_CREATED_BY                 => l_mapping_cols_row.CREATED_BY
	                ,X_LAST_UPDATE_DATE           => Sysdate
        	        ,X_LAST_UPDATED_BY            => l_mapping_cols_row.CREATED_BY
                	,X_LAST_UPDATE_LOGIN          => l_mapping_cols_row.CREATED_BY);
         	END IF;
					CLOSE c_intf_cols_row;
         END IF;
         hr_utility.set_location('Before finishing the loop', 60);
				 l_kff_seg_flag := FALSE;
      END LOOP;
      CLOSE c_mapping_cols_row;

END Create_RIW_Mapping_Links_Rows;

--=================================================================================
-- Code to add specific layout columns to the new layout at a given sequence number
--=================================================================================
PROCEDURE Create_Layout_Cols_Spec_Row(p_application_id     IN NUMBER
                        ,p_new_layout_code    IN VARCHAR2
                        ,p_base_layout_code   IN VARCHAR2
                        ,p_new_interface_code IN VARCHAR2
                      --$ Pass Data Source as well to make changes in layout accordingly
                        ,p_data_source        IN VARCHAR2
                        ,p_interface_seq_num  IN NUMBER
                        ,p_layout_seq_num     IN NUMBER
                        ,p_placement_block_id IN NUMBER) IS

CURSOR c_layout_cols_row(c_interface_seq_num in number)  IS
SELECT application_id
      ,layout_code
      ,block_id
      ,interface_app_id
      ,interface_code
      ,interface_seq_num
      ,sequence_num
      ,style
      ,style_class
      ,hint_style
      ,hint_style_class
      ,prompt_style
      ,prompt_style_class
      ,default_type
      ,DEFAULT_VALUE
      ,created_by
      ,last_updated_by
      ,last_update_login
      ,READ_ONLY_FLAG  --$ added new column as in BNE Layout Table
FROM   bne_layout_cols
WHERE  application_id = p_application_id
AND  layout_code = p_base_layout_code
AND  INTERFACE_SEQ_NUM = c_interface_seq_num
ORDER BY block_id;


l_final_seq_number     NUMBER       :=0;
l_layout_cols_row             c_layout_cols_row%ROWTYPE;
l_rowid                VARCHAR2(100);

BEGIN

      OPEN c_layout_cols_row(c_interface_seq_num => p_interface_seq_num);
      LOOP
         FETCH c_layout_cols_row INTO l_layout_cols_row;
         EXIT WHEN c_layout_cols_row%NOTFOUND;
          hr_utility.set_location('Hehehehe ' || l_layout_cols_row.interface_seq_num, 99);

               l_final_seq_number := p_layout_seq_num;

                bne_layout_cols_pkg.insert_row
                (x_rowid                      => l_rowid
                ,x_application_id             => l_layout_cols_row.application_id
                ,x_layout_code                => p_new_layout_code
                ,x_block_id                   => p_placement_block_id
                ,x_sequence_num               => l_final_seq_number --has to change
                ,x_object_version_number      => 1
                ,x_interface_app_id           => l_layout_cols_row.interface_app_id
                ,x_interface_code             => p_new_interface_code
                ,x_interface_seq_num          => l_layout_cols_row.interface_seq_num
                ,x_style_class                => l_layout_cols_row.style_class
                ,x_hint_style                 => l_layout_cols_row.hint_style
                ,x_hint_style_class           => l_layout_cols_row.hint_style_class
                ,x_prompt_style               => l_layout_cols_row.prompt_style
                ,x_prompt_style_class         => l_layout_cols_row.prompt_style_class
                ,x_default_type               => l_layout_cols_row.default_type
                ,x_default_value              => l_layout_cols_row.default_value
                ,x_style                      => l_layout_cols_row.style
                ,x_creation_date              => SYSDATE
                ,x_created_by                 => l_layout_cols_row.created_by
                ,x_last_update_date           => SYSDATE
                ,x_last_updated_by            => l_layout_cols_row.last_updated_by
                ,x_last_update_login          => l_layout_cols_row.last_update_login
                --$ Added New Column as in BNE Layout Table
                ,X_READ_ONLY_FLAG             => l_layout_cols_row.READ_ONLY_FLAG);
hr_utility.trace('layout col'||l_layout_cols_row.interface_seq_num);
      END LOOP;
      CLOSE c_layout_cols_row;

END Create_Layout_Cols_Spec_Row;

-- =============================================================================
-- ~ Create_RIW_Layout_Cols_Row:
-- =============================================================================
PROCEDURE Create_RIW_Layout_Cols_Row
                        (p_application_id     IN NUMBER
                        ,p_new_layout_code    IN VARCHAR2
                        ,p_base_layout_code   IN VARCHAR2
                        ,p_new_interface_code IN VARCHAR2
                      --$ Pass Data Source as well to make changes in layout accordingly
                        ,p_data_source        IN VARCHAR2
                        ,p_entity_name        IN VARCHAR2 DEFAULT NULL) IS

--cursor to get layout columns - interface seq is passed
CURSOR c_layout_cols_seq_row(c_interface_seq_num IN NUMBER)  IS
SELECT application_id
      ,layout_code
      ,block_id
      ,interface_app_id
      ,interface_code
      ,interface_seq_num
      ,sequence_num
      ,style
      ,style_class
      ,hint_style
      ,hint_style_class
      ,prompt_style
      ,prompt_style_class
      ,default_type
      ,DEFAULT_VALUE
      ,created_by
      ,last_updated_by
      ,last_update_login
      ,display_width
      ,READ_ONLY_FLAG  --$ added new column as in BNE Layout Table
FROM   bne_layout_cols
WHERE  application_id = p_application_id
AND    layout_code = p_base_layout_code
AND    interface_seq_num =c_interface_seq_num
ORDER BY block_id;


-- cursor to get layout columns
CURSOR c_layout_cols_row  IS
SELECT application_id
      ,layout_code
      ,block_id
      ,interface_app_id
      ,interface_code
      ,interface_seq_num
      ,sequence_num
      ,style
      ,style_class
      ,hint_style
      ,hint_style_class
      ,prompt_style
      ,prompt_style_class
      ,default_type
      ,DEFAULT_VALUE
      ,created_by
      ,last_updated_by
      ,last_update_login
      ,READ_ONLY_FLAG  --$ added new column as in BNE Layout Table
FROM   bne_layout_cols
WHERE  application_id = p_application_id
AND  layout_code = p_base_layout_code
AND  INTERFACE_SEQ_NUM in (59,176,253,254,332,334,335,333,331,330,328,177,19,
62,93,124,155,340
,351 --$ Add Batch Exception as well for correct errors
,350 --$ Add Batch Link value for correct errors
)
ORDER BY block_id;

CURSOR c_layout_cols_row_others(c_seq_num  IN VARCHAR2) IS
SELECT application_id
      ,layout_code
      ,block_id
      ,interface_app_id
      ,interface_code
      ,interface_seq_num
      ,sequence_num
      ,style
      ,style_class
      ,hint_style
      ,hint_style_class
      ,prompt_style
      ,prompt_style_class
      ,default_type
      ,DEFAULT_VALUE
      ,created_by
      ,last_updated_by
      ,last_update_login
      ,READ_ONLY_FLAG  --$ added new column as in BNE Layout Table
FROM   bne_layout_cols
WHERE  application_id = p_application_id
AND  layout_code = p_base_layout_code
AND  INTERFACE_SEQ_NUM = c_seq_num
ORDER BY block_id;


l_layout_cols_seq_row         c_layout_cols_seq_row%ROWTYPE;
l_layout_cols_row             c_layout_cols_row%ROWTYPE;
l_layout_cols_row_others      c_layout_cols_row%ROWTYPE;
l_rowid                VARCHAR2(100);
l_placement_block      NUMBER;
l_default_type         VARCHAR2(20);
l_placement_value      VARCHAR2(20);
l_default_value        BNE_INTERFACE_cols_b.DEFAULT_VALUE%TYPE;
l_context_seq_num      BNE_LAYOUT_COLS.INTERFACE_SEQ_NUM%TYPE;
l_header_seq_num      BNE_LAYOUT_COLS.INTERFACE_SEQ_NUM%TYPE;
l_base_intf_code      VARCHAR2(50);


--Paramaters to handle the display sequence order
l_line_display_seq     NUMBER       :=1600; --$ increase seq num as soft segments have been included
l_head_display_seq     NUMBER       :=1300;
l_context_display_seq  NUMBER       :=1300;

--Paramaters to handle the display sequence order
l_line_exist_seq       NUMBER       :=10;
l_head_exist_seq       NUMBER       :=10;
l_context_exist_seq    NUMBER       :=10;

l_dummy_seq_number     NUMBER       :=0;
l_final_seq_number     NUMBER       :=0;
l_allowance_index      NUMBER       :=0;
l_insert_flag          VARCHAR2(10);
l_proc_name            VARCHAR2(72) :=g_package||'Create_RIW_Layout_Cols_Row';
l_interface_seq_num    NUMBER       :=0;
l_bg_seq_num           NUMBER(10);


BEGIN

      hr_utility.set_location('Inside creating the layout cols',20);
      hr_utility.set_location(p_new_interface_code, 25);
      --Gettting the values for selected seq numbers
      FOR l_interface_index IN g_temp_riw_data.FIRST..g_temp_riw_data.LAST
      LOOP
         l_interface_seq_num := g_temp_riw_data(l_interface_index).interface_seq;
         OPEN c_layout_cols_seq_row(c_interface_seq_num => l_interface_seq_num);
         LOOP
            FETCH c_layout_cols_seq_row INTO l_layout_cols_seq_row;
            EXIT WHEN c_layout_cols_seq_row%NOTFOUND;
            hr_utility.set_location(l_interface_seq_num, 30);
            l_default_value := g_riw_data(l_layout_cols_seq_row.interface_seq_num).default_value;
            l_default_type  := g_riw_data(l_layout_cols_seq_row.interface_seq_num).default_type;

            IF l_default_type ='N' THEN
               l_default_type := NULL;
            ELSIF l_default_type ='C' THEN
               l_default_type := 'CONSTANT';
            ELSIF l_default_type ='E' THEN
               l_default_type := 'ENVIRONMENT';
            ELSIF l_default_type ='P' THEN
               l_default_type := 'PARAMETER';
            ELSIF l_default_type ='S' THEN
               l_default_type := 'SQL';
            END IF;

            IF p_entity_name is NULL then
	        --$ IF "Hire Date" and "Address Date From" then set p_effective_date as default value
	        IF l_layout_cols_seq_row.interface_seq_num in (32,16)THEN
                   l_default_value := l_layout_cols_seq_row.default_value;
                   l_default_type := 'PARAMETER';

                   --
                   --$ When CSV or XML layout then 'Hire Date' should be read only but uploadable
                   IF (l_layout_cols_seq_row.interface_seq_num = 16
                      AND p_base_layout_code = 'PQP_FLEXIBLE_WEBADI_LAYOUT'
                          AND (p_data_source = 'XML' or p_data_source = 'CSV'))THEN
                   l_layout_cols_seq_row.READ_ONLY_FLAG := 'N';
                   END IF;
	        END IF;
            END IF;
            l_placement_value := g_riw_data(l_layout_cols_seq_row.interface_seq_num).placement;
            hr_utility.set_location(l_placement_value, 56);

            IF l_placement_value ='LINE' OR l_placement_value IS NULL THEN
               hr_utility.set_location('The Value is Line', 67);
               l_placement_block   := 3;
               l_line_exist_seq    := l_line_exist_seq+10;
               l_dummy_seq_number  := l_line_exist_seq;
            ELSIF l_placement_value ='HEADER' THEN
               l_placement_block   := 2;
               l_head_exist_seq    := l_head_exist_seq+10;
               l_dummy_seq_number  := l_head_exist_seq;
            ELSE
               hr_utility.set_location('The Value is Line', 67);
               l_placement_block   := 1;
               l_context_exist_seq := l_context_exist_seq+10;
               l_dummy_seq_number  := l_context_exist_seq;
            END IF;

            l_final_seq_number   := l_dummy_seq_number;
            l_dummy_seq_number   := 0;

     -- If the column is any DFF concat segment column then the context column should
     -- be added in the layout before that

         IF p_entity_name is null then

          IF l_interface_seq_num in (181, 190, 179, 180, 178) then

            IF l_interface_seq_num = 181 then
                 Create_Layout_Cols_Spec_Row(p_application_id => p_application_id
                        ,p_new_layout_code  => p_new_layout_code
                        ,p_base_layout_code  => p_base_layout_code
                        ,p_new_interface_code => p_new_interface_code
                        ,p_data_source => p_data_source
                        ,p_interface_seq_num  => 155
                        ,p_layout_seq_num  => l_final_seq_number
                        ,p_placement_block_id => l_placement_block);
            ELSIF l_interface_seq_num = 190 then
                  Create_Layout_Cols_Spec_Row(p_application_id => p_application_id
                        ,p_new_layout_code  => p_new_layout_code
                        ,p_base_layout_code  => p_base_layout_code
                        ,p_new_interface_code => p_new_interface_code
                        ,p_data_source => p_data_source
                        ,p_interface_seq_num  => 62
                        ,p_layout_seq_num  => l_final_seq_number
                        ,p_placement_block_id => l_placement_block);

            ELSIF l_interface_seq_num = 179 THEN
                 Create_Layout_Cols_Spec_Row(p_application_id => p_application_id
                        ,p_new_layout_code  => p_new_layout_code
                        ,p_base_layout_code  => p_base_layout_code
                        ,p_new_interface_code => p_new_interface_code
                        ,p_data_source => p_data_source
                        ,p_interface_seq_num  => 19
                        ,p_layout_seq_num  => l_final_seq_number
                        ,p_placement_block_id => l_placement_block);

            ELSIF l_interface_seq_num = 180 THEN
                 Create_Layout_Cols_Spec_Row(p_application_id => p_application_id
                        ,p_new_layout_code  => p_new_layout_code
                        ,p_base_layout_code  => p_base_layout_code
                        ,p_new_interface_code => p_new_interface_code
                        ,p_data_source => p_data_source
                        ,p_interface_seq_num  => 124
                        ,p_layout_seq_num  => l_final_seq_number
                        ,p_placement_block_id => l_placement_block);

            ELSIF l_interface_seq_num = 178 THEN
                  Create_Layout_Cols_Spec_Row(p_application_id => p_application_id
                        ,p_new_layout_code  => p_new_layout_code
                        ,p_base_layout_code  => p_base_layout_code
                        ,p_new_interface_code => p_new_interface_code
                        ,p_data_source => p_data_source
                        ,p_interface_seq_num  => 93
                        ,p_layout_seq_num  => l_final_seq_number
                        ,p_placement_block_id => l_placement_block);
            END IF;

             IF l_placement_value ='LINE' OR l_placement_value IS NULL THEN
               hr_utility.set_location('The Value is Line', 67);
               l_placement_block   := 3;
               l_line_exist_seq    := l_line_exist_seq+10;
               l_dummy_seq_number  := l_line_exist_seq;
            ELSIF l_placement_value ='HEADER' THEN
               l_placement_block   := 2;
               l_head_exist_seq    := l_head_exist_seq+10;
               l_dummy_seq_number  := l_head_exist_seq;
            ELSE
               hr_utility.set_location('The Value is Line', 67);
               l_placement_block   := 1;
               l_context_exist_seq := l_context_exist_seq+10;
               l_dummy_seq_number  := l_context_exist_seq;
            END IF;

            l_final_seq_number   := l_dummy_seq_number;
            l_dummy_seq_number   := 0;

         END IF;
         ENd IF;


            bne_layout_cols_pkg.insert_row
                (x_rowid                      => l_rowid
                ,x_application_id             => l_layout_cols_seq_row.application_id
                ,x_layout_code                => p_new_layout_code
                ,x_block_id                   => l_placement_block   --has to change
                ,x_sequence_num               => l_final_seq_number  --has to change
                ,x_object_version_number      => 1
                ,x_interface_app_id           => l_layout_cols_seq_row.interface_app_id
                ,x_interface_code             => p_new_interface_code
                ,x_interface_seq_num          => l_layout_cols_seq_row.interface_seq_num
                ,x_style_class                => l_layout_cols_seq_row.style_class
                ,x_hint_style                 => l_layout_cols_seq_row.hint_style
                ,x_hint_style_class           => l_layout_cols_seq_row.hint_style_class
                ,x_prompt_style               => l_layout_cols_seq_row.prompt_style
                ,x_prompt_style_class         => l_layout_cols_seq_row.prompt_style_class
                ,x_default_type               => l_default_type --has to change
                ,x_default_value              => l_default_value --has to change
                ,x_style                      => l_layout_cols_seq_row.style
                ,x_creation_date              => SYSDATE
                ,x_created_by                 => l_layout_cols_seq_row.created_by
                ,x_last_update_date           => SYSDATE
                ,x_last_updated_by            => l_layout_cols_seq_row.last_updated_by
                ,x_last_update_login          => l_layout_cols_seq_row.last_update_login
                ,x_display_width              => l_layout_cols_seq_row.display_width
                --$ Added New Column as in BNE Layout Table
                ,X_READ_ONLY_FLAG             => l_layout_cols_seq_row.READ_ONLY_FLAG);

           hr_utility.set_location('bne package is called', 10);
         END LOOP;
         CLOSE c_layout_cols_seq_row;
      END LOOP;

      IF p_entity_name is NULL THEN
      --This logic to hanlde others which are not selected
      OPEN c_layout_cols_row;
      LOOP
         FETCH c_layout_cols_row INTO l_layout_cols_row;
         EXIT WHEN c_layout_cols_row%NOTFOUND;

          IF g_riw_data.EXISTS(l_layout_cols_row.interface_seq_num) THEN
             Hr_Utility.set_location('NON Exist --Exist Seq Number: '||l_layout_cols_row.interface_seq_num, 5);
          ELSE
 	      /* l_insert_flag := 'false';
	       --Checking to know the flexfields are selected by user
               IF l_layout_cols_row.interface_seq_num = 155 THEN
	          IF g_riw_data.EXISTS(181) THEN
       	             l_insert_flag := 'true';
		  END IF;
	       ELSIF l_layout_cols_row.interface_seq_num = 62 THEN
      	          IF g_riw_data.EXISTS(190) THEN
       	             l_insert_flag := 'true';
		  END IF;
	       ELSIF l_layout_cols_row.interface_seq_num = 19 THEN
      	          IF g_riw_data.EXISTS(179) THEN
       	             l_insert_flag := 'true';
		  END IF;
	       ELSIF l_layout_cols_row.interface_seq_num = 124 THEN
      	          IF g_riw_data.EXISTS(180) THEN
       	             l_insert_flag := 'true';
		  END IF;
	       ELSIF l_layout_cols_row.interface_seq_num = 93 THEN
      	          IF g_riw_data.EXISTS(178) THEN
       	             l_insert_flag := 'true';
		  END IF;
	       ELSE
       	             l_insert_flag := 'true';
	       END IF;*/
              --Insert the data only l_insert_flag is true
	       l_placement_block := l_layout_cols_row.block_id;
               l_default_type    := l_layout_cols_row.default_type;
               l_default_value   := l_layout_cols_row.DEFAULT_VALUE;

               IF l_layout_cols_row.block_id = 3 then
                  l_line_display_seq := l_line_display_seq+10;
                  l_dummy_seq_number := l_line_display_seq;
               ELSIF l_layout_cols_row.block_id = 2 THEN
                  l_head_display_seq := l_head_display_seq+10;
                  l_dummy_seq_number := l_head_display_seq;
               ELSE
                  l_context_display_seq :=l_context_display_seq+10;
                  l_dummy_seq_number    := l_context_display_seq;
               END IF;

               --Defaulting
               l_final_seq_number   := l_dummy_seq_number;
               l_dummy_seq_number   := 0;

                bne_layout_cols_pkg.insert_row
                (x_rowid                      => l_rowid
                ,x_application_id             => l_layout_cols_row.application_id
                ,x_layout_code                => p_new_layout_code
                ,x_block_id                   => l_layout_cols_row.block_id
                ,x_sequence_num               => l_final_seq_number --has to change
                ,x_object_version_number      => 1
                ,x_interface_app_id           => l_layout_cols_row.interface_app_id
                ,x_interface_code             => p_new_interface_code
                ,x_interface_seq_num          => l_layout_cols_row.interface_seq_num
                ,x_style_class                => l_layout_cols_row.style_class
                ,x_hint_style                 => l_layout_cols_row.hint_style
                ,x_hint_style_class           => l_layout_cols_row.hint_style_class
                ,x_prompt_style               => l_layout_cols_row.prompt_style
                ,x_prompt_style_class         => l_layout_cols_row.prompt_style_class
                ,x_default_type               => l_layout_cols_row.default_type
                ,x_default_value              => l_layout_cols_row.default_value
                ,x_style                      => l_layout_cols_row.style
                ,x_creation_date              => SYSDATE
                ,x_created_by                 => l_layout_cols_row.created_by
                ,x_last_update_date           => SYSDATE
                ,x_last_updated_by            => l_layout_cols_row.last_updated_by
                ,x_last_update_login          => l_layout_cols_row.last_update_login
                --$ Added New Column as in BNE Layout Table
                ,X_READ_ONLY_FLAG             => l_layout_cols_row.READ_ONLY_FLAG);
hr_utility.trace('layout col'||l_layout_cols_row.interface_seq_num);
        END IF;
      END LOOP;
      CLOSE c_layout_cols_row;
      ELSE
         SELECT distinct(interface_code) into l_base_intf_code
             from bne_layout_cols where layout_code = p_base_layout_code;
         Select sequence_num into l_context_seq_num from bne_interface_cols_b
            where interface_code = l_base_intf_code and
            interface_col_name = 'P_WEBADI_CONTEXT';
         Select sequence_num into l_header_seq_num from bne_interface_cols_b
            where interface_code = l_base_intf_code and
            interface_col_name = 'P_WEBADI_HEADER';
         Select sequence_num into l_bg_seq_num from bne_interface_cols_b
            where interface_code = l_base_intf_code and
            interface_col_name = 'BUSINESS_GRP_NAME';

      OPEN c_layout_cols_row_others(c_seq_num  => l_context_seq_num);
         FETCH c_layout_cols_row_others
             INTO l_layout_cols_row_others;
	       l_placement_block := l_layout_cols_row_others.block_id;
               l_default_type    := l_layout_cols_row_others.default_type;
               l_default_value   := l_layout_cols_row_others.DEFAULT_VALUE;
               hr_utility.set_location('It is in the loop ', 88);
               IF l_layout_cols_row_others.block_id = 3 then
                  l_line_display_seq := l_line_display_seq+10;
                  l_dummy_seq_number := l_line_display_seq;
               ELSIF l_layout_cols_row_others.block_id = 2 THEN
                  l_head_display_seq := l_head_display_seq+10;
                  l_dummy_seq_number := l_head_display_seq;
               ELSE
                  l_context_display_seq :=l_context_display_seq+10;
                  l_dummy_seq_number    := l_context_display_seq;
               END IF;

               --Defaulting
               l_final_seq_number   := l_dummy_seq_number;
               l_dummy_seq_number   := 0;

                bne_layout_cols_pkg.insert_row
                (x_rowid                      => l_rowid
                ,x_application_id             => l_layout_cols_row_others.application_id
                ,x_layout_code                => p_new_layout_code
                ,x_block_id                   => l_layout_cols_row_others.block_id
                ,x_sequence_num               => l_final_seq_number --has to change
                ,x_object_version_number      => 1
                ,x_interface_app_id           => l_layout_cols_row_others.interface_app_id
                ,x_interface_code             => p_new_interface_code
                ,x_interface_seq_num          => l_layout_cols_row_others.interface_seq_num
                ,x_style_class                => l_layout_cols_row_others.style_class
                ,x_hint_style                 => l_layout_cols_row_others.hint_style
                ,x_hint_style_class           => l_layout_cols_row_others.hint_style_class
                ,x_prompt_style               => l_layout_cols_row_others.prompt_style
                ,x_prompt_style_class         => l_layout_cols_row_others.prompt_style_class
                ,x_default_type               => l_layout_cols_row_others.default_type
                ,x_default_value              => l_layout_cols_row_others.default_value
                ,x_style                      => l_layout_cols_row_others.style
                ,x_creation_date              => SYSDATE
                ,x_created_by                 => l_layout_cols_row_others.created_by
                ,x_last_update_date           => SYSDATE
                ,x_last_updated_by            => l_layout_cols_row_others.last_updated_by
                ,x_last_update_login          => l_layout_cols_row_others.last_update_login
                --$ Added New Column as in BNE Layout Table
                ,X_READ_ONLY_FLAG             => l_layout_cols_row_others.READ_ONLY_FLAG);

      CLOSE c_layout_cols_row_others;

      OPEN c_layout_cols_row_others(c_seq_num  => l_header_seq_num);
         FETCH c_layout_cols_row_others
             INTO l_layout_cols_row_others;
	       l_placement_block := l_layout_cols_row_others.block_id;
               l_default_type    := l_layout_cols_row_others.default_type;
               l_default_value   := l_layout_cols_row_others.DEFAULT_VALUE;
               hr_utility.set_location('It is in the loop ', 88);
               IF l_layout_cols_row_others.block_id = 3 then
                  l_line_display_seq := l_line_display_seq+10;
                  l_dummy_seq_number := l_line_display_seq;
               ELSIF l_layout_cols_row_others.block_id = 2 THEN
                  l_head_display_seq := l_head_display_seq+10;
                  l_dummy_seq_number := l_head_display_seq;
               ELSE
                  l_context_display_seq :=l_context_display_seq+10;
                  l_dummy_seq_number    := l_context_display_seq;
               END IF;

               --Defaulting
               l_final_seq_number   := l_dummy_seq_number;
               l_dummy_seq_number   := 0;

                bne_layout_cols_pkg.insert_row
                (x_rowid                      => l_rowid
                ,x_application_id             => l_layout_cols_row_others.application_id
                ,x_layout_code                => p_new_layout_code
                ,x_block_id                   => l_layout_cols_row_others.block_id
                ,x_sequence_num               => l_final_seq_number --has to change
                ,x_object_version_number      => 1
                ,x_interface_app_id           => l_layout_cols_row_others.interface_app_id
                ,x_interface_code             => p_new_interface_code
                ,x_interface_seq_num          => l_layout_cols_row_others.interface_seq_num
                ,x_style_class                => l_layout_cols_row_others.style_class
                ,x_hint_style                 => l_layout_cols_row_others.hint_style
                ,x_hint_style_class           => l_layout_cols_row_others.hint_style_class
                ,x_prompt_style               => l_layout_cols_row_others.prompt_style
                ,x_prompt_style_class         => l_layout_cols_row_others.prompt_style_class
                ,x_default_type               => l_layout_cols_row_others.default_type
                ,x_default_value              => l_layout_cols_row_others.default_value
                ,x_style                      => l_layout_cols_row_others.style
                ,x_creation_date              => SYSDATE
                ,x_created_by                 => l_layout_cols_row_others.created_by
                ,x_last_update_date           => SYSDATE
                ,x_last_updated_by            => l_layout_cols_row_others.last_updated_by
                ,x_last_update_login          => l_layout_cols_row_others.last_update_login
                --$ Added New Column as in BNE Layout Table
                ,X_READ_ONLY_FLAG             => l_layout_cols_row_others.READ_ONLY_FLAG);

      CLOSE c_layout_cols_row_others;

      OPEN c_layout_cols_row_others(c_seq_num  => l_bg_seq_num);
         FETCH c_layout_cols_row_others
             INTO l_layout_cols_row_others;
	       l_placement_block := l_layout_cols_row_others.block_id;
               l_default_type    := l_layout_cols_row_others.default_type;
               l_default_value   := l_layout_cols_row_others.DEFAULT_VALUE;
               hr_utility.set_location('It is in the loop ', 88);
               IF l_layout_cols_row_others.block_id = 3 then
                  l_line_display_seq := l_line_display_seq+10;
                  l_dummy_seq_number := l_line_display_seq;
               ELSIF l_layout_cols_row_others.block_id = 2 THEN
                  l_head_display_seq := l_head_display_seq+10;
                  l_dummy_seq_number := l_head_display_seq;
               ELSE
                  l_context_display_seq :=l_context_display_seq+10;
                  l_dummy_seq_number    := l_context_display_seq;
               END IF;

               --Defaulting
               l_final_seq_number   := l_dummy_seq_number;
               l_dummy_seq_number   := 0;

                bne_layout_cols_pkg.insert_row
                (x_rowid                      => l_rowid
                ,x_application_id             => l_layout_cols_row_others.application_id
                ,x_layout_code                => p_new_layout_code
                ,x_block_id                   => l_layout_cols_row_others.block_id
                ,x_sequence_num               => l_final_seq_number --has to change
                ,x_object_version_number      => 1
                ,x_interface_app_id           => l_layout_cols_row_others.interface_app_id
                ,x_interface_code             => p_new_interface_code
                ,x_interface_seq_num          => l_layout_cols_row_others.interface_seq_num
                ,x_style_class                => l_layout_cols_row_others.style_class
                ,x_hint_style                 => l_layout_cols_row_others.hint_style
                ,x_hint_style_class           => l_layout_cols_row_others.hint_style_class
                ,x_prompt_style               => l_layout_cols_row_others.prompt_style
                ,x_prompt_style_class         => l_layout_cols_row_others.prompt_style_class
                ,x_default_type               => l_layout_cols_row_others.default_type
                ,x_default_value              => l_layout_cols_row_others.default_value
                ,x_style                      => l_layout_cols_row_others.style
                ,x_creation_date              => SYSDATE
                ,x_created_by                 => l_layout_cols_row_others.created_by
                ,x_last_update_date           => SYSDATE
                ,x_last_updated_by            => l_layout_cols_row_others.last_updated_by
                ,x_last_update_login          => l_layout_cols_row_others.last_update_login
                --$ Added New Column as in BNE Layout Table
                ,X_READ_ONLY_FLAG             => l_layout_cols_row_others.READ_ONLY_FLAG);

      CLOSE c_layout_cols_row_others;

      END IF;

END Create_RIW_Layout_Cols_Row;



-- =============================================================================
-- ~ Create_RIW_Layout_Blocks_Row:
-- =============================================================================
PROCEDURE Create_RIW_Layout_Blocks_Row
            (p_application_id   IN   NUMBER
            ,p_new_layout_code  IN   VARCHAR2
            ,p_base_layout_code IN   VARCHAR2
            ,p_user_name        IN   VARCHAR2) IS

CURSOR c_layout_blocks_row  IS
SELECT application_id
      ,block_id
      ,parent_id
      ,layout_element
      ,style_class
      ,style
      ,row_style_class
      ,row_style
      ,col_style_class
      ,col_style
      ,prompt_displayed_flag
      ,prompt_style_class
      ,prompt_style
      ,hint_displayed_flag
      ,hint_style_class
      ,hint_style
      ,orientation
      ,layout_control
      ,display_flag
      ,BLOCKSIZE
      ,minsize
      ,MAXSIZE
      ,sequence_num
      ,prompt_colspan
      ,hint_colspan
      ,row_colspan
      ,summary_style_class
      ,summary_style
      ,created_by
      ,last_updated_by
      ,last_update_login
      ,user_name
FROM   bne_layout_blocks_vl
WHERE  application_id = p_application_id
AND    layout_code = p_base_layout_code
ORDER BY block_id;

l_layout_blocks_row     c_layout_blocks_row%ROWTYPE;
l_rowid                 VARCHAR2(200);

BEGIN
  OPEN c_layout_blocks_row;
  LOOP
     FETCH c_layout_blocks_row  INTO l_layout_blocks_row;
     EXIT WHEN c_layout_blocks_row%NOTFOUND;

     bne_layout_blocks_pkg.insert_row
            (x_rowid                      => l_rowid
            ,x_application_id             => l_layout_blocks_row.application_id
            ,x_layout_code                => p_new_layout_code
            ,x_block_id                   => l_layout_blocks_row.block_id
            ,x_object_version_number      => 1
            ,x_parent_id                  => l_layout_blocks_row.parent_id
            ,x_layout_element             => l_layout_blocks_row.layout_element
            ,x_style_class                => l_layout_blocks_row.style_class
            ,x_style                      => l_layout_blocks_row.style
            ,x_row_style_class            => l_layout_blocks_row.row_style_class
            ,x_row_style                  => l_layout_blocks_row.row_style
            ,x_col_style_class            => l_layout_blocks_row.col_style_class
            ,x_col_style                  => l_layout_blocks_row.col_style
            ,x_prompt_displayed_flag      => l_layout_blocks_row.prompt_displayed_flag
            ,x_prompt_style_class         => l_layout_blocks_row.prompt_style_class
            ,x_prompt_style               => l_layout_blocks_row.prompt_style
            ,x_hint_displayed_flag        => l_layout_blocks_row.hint_displayed_flag
            ,x_hint_style_class           => l_layout_blocks_row.hint_style_class
            ,x_hint_style                 => l_layout_blocks_row.hint_style
            ,x_orientation                => l_layout_blocks_row.orientation
            ,x_layout_control             => l_layout_blocks_row.layout_control
            ,x_display_flag               => l_layout_blocks_row.display_flag
            ,x_blocksize                  => l_layout_blocks_row.BLOCKSIZE
            ,x_minsize                    => l_layout_blocks_row.minsize
            ,x_maxsize                    => l_layout_blocks_row.MAXSIZE
            ,x_sequence_num               => l_layout_blocks_row.sequence_num
            ,x_prompt_colspan             => l_layout_blocks_row.prompt_colspan
            ,x_hint_colspan               => l_layout_blocks_row.hint_colspan
            ,x_row_colspan                => l_layout_blocks_row.row_colspan
            ,x_summary_style_class        => l_layout_blocks_row.summary_style_class
            ,x_summary_style              => l_layout_blocks_row.summary_style
            ,x_user_name                  => l_layout_blocks_row.user_name
            ,x_creation_date              => SYSDATE
            ,x_created_by                 => l_layout_blocks_row.created_by
            ,x_last_update_date           => SYSDATE
            ,x_last_updated_by            => l_layout_blocks_row.last_updated_by
            ,x_last_update_login          => l_layout_blocks_row.last_update_login);
  END LOOP;

CLOSE c_layout_blocks_row;
END Create_RIW_Layout_Blocks_Row;



-- =============================================================================
-- ~ Create_RIW_Interface_Row:
-- =============================================================================
PROCEDURE Create_RIW_Interface_Row
            (p_application_id      IN  NUMBER
            ,p_new_interface_code  IN  VARCHAR2
            ,p_base_interface_code IN  VARCHAR2
            ,p_user_name           IN  VARCHAR2
            ,p_new_intg_code       IN  VARCHAR2) IS

CURSOR c_interface_row
IS
SELECT APPLICATION_ID
      ,INTERFACE_CODE
      ,OBJECT_VERSION_NUMBER
      ,INTEGRATOR_APP_ID
      ,INTEGRATOR_CODE
      ,INTERFACE_NAME
      ,UPLOAD_TYPE
      ,UPLOAD_OBJ_NAME
      ,UPLOAD_PARAM_LIST_APP_ID
      ,UPLOAD_PARAM_LIST_CODE
      ,UPLOAD_ORDER
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,LAST_UPDATE_DATE
FROM   BNE_INTERFACES_B
WHERE  application_id = p_application_id
AND    INTERFACE_CODE = p_base_interface_code;

l_interface_row     c_interface_row%ROWTYPE;
l_rowid             VARCHAR2(200);
no_default_layout   EXCEPTION;
VV_INTERFACE_CODE   BNE_INTERFACES_B.INTERFACE_CODE%TYPE;
l_proc_name         VARCHAR2(72) := g_proc_name||'Create_RIW_Interface_Row';

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  OPEN  c_interface_row;
  FETCH c_interface_row  INTO l_interface_row;
  IF c_interface_row%NOTFOUND THEN
     RAISE no_default_layout;
  END IF;
  CLOSE c_interface_row;

  -- Check that the OBJECT_CODE for this Interface is unique for the Application ID.
  BEGIN
      SELECT INTERFACE_CODE
      INTO   VV_INTERFACE_CODE
      FROM   BNE_INTERFACES_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = p_new_interface_code;
  EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
  END;

    -- Create the interface in the BNE_INTERFACES_B table
    IF (VV_INTERFACE_CODE IS NULL) THEN
       INSERT INTO BNE_INTERFACES_B
       (APPLICATION_ID
       ,INTERFACE_CODE
       ,OBJECT_VERSION_NUMBER
       ,INTEGRATOR_APP_ID
       ,INTEGRATOR_CODE
       ,INTERFACE_NAME
       ,UPLOAD_TYPE
       ,UPLOAD_PARAM_LIST_APP_ID
       ,UPLOAD_PARAM_LIST_CODE
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE)
      VALUES
        (l_interface_row.APPLICATION_ID
        ,p_new_interface_code
        ,1
        ,l_interface_row.APPLICATION_ID
        ,p_new_intg_code--l_interface_row.INTEGRATOR_CODE
        ,l_interface_row.INTERFACE_NAME
        ,l_interface_row.UPLOAD_TYPE
        ,l_interface_row.UPLOAD_PARAM_LIST_APP_ID
        ,l_interface_row.UPLOAD_PARAM_LIST_CODE
        ,l_interface_row.CREATED_BY
        ,SYSDATE
        ,l_interface_row.CREATED_BY
        ,SYSDATE);

       -- Create the interface in the BNE_INTERFACES_TL table
       INSERT INTO BNE_INTERFACES_TL
       (APPLICATION_ID
       ,INTERFACE_CODE
       ,LANGUAGE
       ,SOURCE_LANG
       ,USER_NAME
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE)
      VALUES
       (l_interface_row.APPLICATION_ID
       ,p_new_interface_code
       ,userenv('LANG')
       ,userenv('LANG')
       ,p_user_name
       ,l_interface_row.CREATED_BY
       ,SYSDATE
       ,l_interface_row.CREATED_BY
       ,SYSDATE);
    END IF;
Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END Create_RIW_Interface_Row;


-- =============================================================================
-- ~ Create_RIW_Interface_Col_Rows:
-- =============================================================================
PROCEDURE Create_RIW_Interface_Col_Rows
            (p_application_id      IN   NUMBER
            ,p_new_interface_code  IN   VARCHAR2
            ,p_base_interface_code IN   VARCHAR2
            ,p_entity_name         IN VARCHAR2  DEFAULT NULL) IS

CURSOR c_interface_cols_row
IS
SELECT APPLICATION_ID
      ,INTERFACE_CODE
      ,OBJECT_VERSION_NUMBER
      ,SEQUENCE_NUM
      ,INTERFACE_COL_TYPE
      ,INTERFACE_COL_NAME
      ,ENABLED_FLAG
      ,REQUIRED_FLAG
      ,DISPLAY_FLAG
      ,READ_ONLY_FLAG
      ,NOT_NULL_FLAG
      ,SUMMARY_FLAG
      ,MAPPING_ENABLED_FLAG
      ,DATA_TYPE
      ,FIELD_SIZE
      ,DEFAULT_TYPE
      ,DEFAULT_VALUE
      ,SEGMENT_NUMBER
      ,GROUP_NAME
      ,OA_FLEX_CODE
      ,OA_CONCAT_FLEX
      ,VAL_TYPE
      ,VAL_ID_COL
      ,VAL_MEAN_COL
      ,VAL_DESC_COL
      ,VAL_OBJ_NAME
      ,VAL_ADDL_W_C
      ,VAL_COMPONENT_APP_ID
      ,VAL_COMPONENT_CODE
      ,OA_FLEX_NUM
      ,OA_FLEX_APPLICATION_ID
      ,DISPLAY_ORDER
      ,UPLOAD_PARAM_LIST_ITEM_NUM
      ,EXPANDED_SQL_QUERY
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,LAST_UPDATE_DATE
      ,LOV_TYPE
      ,OFFLINE_LOV_ENABLED_FLAG
      ,VARIABLE_DATA_TYPE_CLASS
FROM   BNE_INTERFACE_COLS_B
WHERE  application_id  =  p_application_id
AND    INTERFACE_CODE  =  p_base_interface_code;


CURSOR c_interface_tl_cols_row(c_seq_num Number , user_lang varchar2)
IS
SELECT APPLICATION_ID
      ,INTERFACE_CODE
      ,SEQUENCE_NUM
      ,LANGUAGE
      ,SOURCE_LANG
      ,USER_HINT
      ,PROMPT_LEFT
      ,USER_HELP_TEXT
      ,PROMPT_ABOVE
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
FROM   BNE_INTERFACE_COLS_TL
WHERE  application_id = p_application_id
AND    INTERFACE_CODE = p_base_interface_code
AND    SEQUENCE_NUM   = c_seq_num
AND    LANGUAGE = user_lang;


l_interface_cols_row       c_interface_cols_row%ROWTYPE;
l_interface_tl_cols_row    c_interface_tl_cols_row%ROWTYPE;
l_rowid                    VARCHAR2(200);
no_default_layout          EXCEPTION;
l_proc_name                VARCHAR2(72) := g_package||'Create_RIW_Interface_Col_Rows';
VN_NO_INTERFACE_COL_FLAG   NUMBER ;
l_display                  VARCHAR2(1);
l_default_type             BNE_INTERFACE_COLS_B.default_type%TYPE;
l_default_value            BNE_INTERFACE_COLS_B.default_value%TYPE;
l_prompt_left              BNE_INTERFACE_COLS_TL.PROMPT_LEFT%TYPE;
l_prompt_above             BNE_INTERFACE_COLS_TL.PROMPT_ABOVE%TYPE;
l_crt_upd_seq_num          BNE_INTERFACE_COLS_B.SEQUENCE_NUM%TYPE;


BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  --  Check the BNE_INTERFACE_COLS_B table to ensure that the record
  --  does not already exist
  VN_NO_INTERFACE_COL_FLAG := 0;

  SELECT sequence_num INTO l_crt_upd_seq_num FROM BNE_INTERFACE_COLS_B WHERE
  INTERFACE_CODE = p_base_interface_code AND
  INTERFACE_COL_NAME = 'P_CRT_UPD';

  BEGIN
      SELECT 1
      INTO   VN_NO_INTERFACE_COL_FLAG
      FROM   BNE_INTERFACE_COLS_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = p_new_interface_code;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
  END;

  hr_utility.set_location('Loop Outside', 90);
  --  If the Interface Column was not found then create
  IF (VN_NO_INTERFACE_COL_FLAG = 0) THEN
     OPEN c_interface_cols_row;
     LOOP
         FETCH c_interface_cols_row  INTO l_interface_cols_row;
         EXIT WHEN c_interface_cols_row%NOTFOUND;
      hr_utility.set_location(l_interface_cols_row.sequence_num, 78);
      IF p_entity_name IS NULL then
          IF l_interface_cols_row.SEQUENCE_NUM IN (352) THEN
              l_default_type := 'CONSTANT';
              l_default_value := g_ins_upd_flag;
          ELSE
              l_default_type := l_interface_cols_row.DEFAULT_TYPE;
              l_default_value := l_interface_cols_row.DEFAULT_VALUE;
          END IF;

          IF g_riw_data.EXISTS(l_interface_cols_row.SEQUENCE_NUM) THEN
             l_display := 'Y';
          ELSIF l_interface_cols_row.SEQUENCE_NUM IN (59,176,253,254,332,334,335,333,
          331,330,328,177,340, --Displaying cols like Business Group Id, Batch ID,
                           --Batch name , Instructions etc.
          351, --$ Display P_BATCH_EXCEPTION also
          350  --$ Display P_BATCH_LINK also as read only column
          ) THEN
          l_display := l_interface_cols_row.DISPLAY_FLAG;
          ELSIF g_riw_data.EXISTS(181) AND l_interface_cols_row.SEQUENCE_NUM IN (155) THEN
             l_display := 'Y';
          ELSIF g_riw_data.EXISTS(190) AND l_interface_cols_row.SEQUENCE_NUM IN (62) THEN
             l_display := 'Y';
          ELSIF g_riw_data.EXISTS(179) AND l_interface_cols_row.SEQUENCE_NUM IN (19) THEN
             l_display := 'Y';
          ELSIF g_riw_data.EXISTS(180) AND l_interface_cols_row.SEQUENCE_NUM IN (124) THEN
             l_display := 'Y';
          ELSIF g_riw_data.EXISTS(178) AND l_interface_cols_row.SEQUENCE_NUM IN (93) THEN
             l_display := 'Y';
          ELSE
             l_display := 'N';
          END IF;
      ELSE

          IF l_interface_cols_row.SEQUENCE_NUM IN (l_crt_upd_seq_num) THEN
              hr_utility.set_location('The Flag in cols row is ' || g_ins_upd_flag, 89);
              l_default_type := 'CONSTANT';
              l_default_value := g_ins_upd_flag;
          ELSE
              l_default_type := l_interface_cols_row.DEFAULT_TYPE;
              l_default_value := l_interface_cols_row.DEFAULT_VALUE;
          END IF;
          IF g_riw_data.EXISTS(l_interface_cols_row.SEQUENCE_NUM) THEN
             l_display := 'Y';
          ELSE
              IF l_interface_cols_row.interface_col_name = 'P_WEBADI_CONTEXT'
                OR l_interface_cols_row.interface_col_name = 'P_WEBADI_HEADER'
                 OR l_interface_cols_row.interface_col_name = 'BUSINESS_GRP_NAME' THEN
                    l_display := l_interface_cols_row.DISPLAY_FLAG;
              ELSE
                    l_display := 'N';
              END IF;
              IF l_interface_cols_row.interface_col_name = 'P_INTERFACE_CODE' THEN
                    l_default_type := 'CONSTANT';
                    l_default_value := p_new_interface_code;
              END IF;
              IF l_interface_cols_row.interface_col_name = 'P_MIGRATION_FLAG' THEN
                    l_default_type := 'CONSTANT';
                    l_default_value := g_migration_flag;
              END IF;
          END IF;
      END IF;

         --  l_display := l_interface_cols_row.DISPLAY_FLAG;
         --  Insert the required row in BNE_INTERFACE_COLS_B
       INSERT INTO BNE_INTERFACE_COLS_B
         (APPLICATION_ID
         ,INTERFACE_CODE
         ,OBJECT_VERSION_NUMBER
         ,SEQUENCE_NUM
         ,INTERFACE_COL_TYPE
         ,INTERFACE_COL_NAME
         ,ENABLED_FLAG
         ,REQUIRED_FLAG
         ,DISPLAY_FLAG
         ,READ_ONLY_FLAG
         ,NOT_NULL_FLAG
         ,SUMMARY_FLAG
         ,MAPPING_ENABLED_FLAG
         ,DATA_TYPE
         ,FIELD_SIZE
         ,DEFAULT_TYPE
         ,DEFAULT_VALUE
         ,SEGMENT_NUMBER
         ,GROUP_NAME
         ,OA_FLEX_CODE
         ,OA_CONCAT_FLEX
         ,VAL_TYPE
         ,VAL_ID_COL
         ,VAL_MEAN_COL
         ,VAL_DESC_COL
         ,VAL_OBJ_NAME
         ,VAL_ADDL_W_C
         ,VAL_COMPONENT_APP_ID
         ,VAL_COMPONENT_CODE
         ,OA_FLEX_NUM
         ,OA_FLEX_APPLICATION_ID
         ,DISPLAY_ORDER
         ,UPLOAD_PARAM_LIST_ITEM_NUM
         ,EXPANDED_SQL_QUERY
         ,LOV_TYPE
         ,OFFLINE_LOV_ENABLED_FLAG
         ,VARIABLE_DATA_TYPE_CLASS
         ,CREATED_BY
         ,CREATION_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_DATE)
       VALUES
         (l_interface_cols_row.APPLICATION_ID
         ,p_new_interface_code
         ,1
         ,l_interface_cols_row.SEQUENCE_NUM
         ,l_interface_cols_row.INTERFACE_COL_TYPE
         ,l_interface_cols_row.INTERFACE_COL_NAME
         ,l_interface_cols_row.ENABLED_FLAG
         ,l_interface_cols_row.REQUIRED_FLAG
         ,l_display --have to change based on layout selection
         ,NVL(l_interface_cols_row.READ_ONLY_FLAG,'N')
         ,l_interface_cols_row.NOT_NULL_FLAG
         ,NVL(l_interface_cols_row.SUMMARY_FLAG,'N')
         ,l_interface_cols_row.MAPPING_ENABLED_FLAG
         ,l_interface_cols_row.DATA_TYPE
         ,l_interface_cols_row.FIELD_SIZE
         ,l_default_type
         ,l_default_value
         ,l_interface_cols_row.SEGMENT_NUMBER
         ,l_interface_cols_row.GROUP_NAME
         ,l_interface_cols_row.OA_FLEX_CODE
         ,l_interface_cols_row.OA_CONCAT_FLEX
         ,l_interface_cols_row.VAL_TYPE
         ,l_interface_cols_row.VAL_ID_COL
         ,l_interface_cols_row.VAL_MEAN_COL
         ,l_interface_cols_row.VAL_DESC_COL
         ,l_interface_cols_row.VAL_OBJ_NAME
         ,l_interface_cols_row.VAL_ADDL_W_C
         ,l_interface_cols_row.VAL_COMPONENT_APP_ID
         ,l_interface_cols_row.VAL_COMPONENT_CODE
         ,l_interface_cols_row.OA_FLEX_NUM
         ,l_interface_cols_row.OA_FLEX_APPLICATION_ID
         ,l_interface_cols_row.DISPLAY_ORDER
         ,l_interface_cols_row.UPLOAD_PARAM_LIST_ITEM_NUM
         ,l_interface_cols_row.EXPANDED_SQL_QUERY
         ,l_interface_cols_row.LOV_TYPE
         ,l_interface_cols_row.OFFLINE_LOV_ENABLED_FLAG
         ,l_interface_cols_row.VARIABLE_DATA_TYPE_CLASS
         ,l_interface_cols_row.CREATED_BY
         ,SYSDATE
         ,l_interface_cols_row.CREATED_BY
         ,SYSDATE);
         hr_utility.set_location('The cols_b got created successfully', 79) ;

        --  Insert the required row in BNE_INTERFACE_COLS_TL only if P_LANGUAGE is populated

           OPEN c_interface_tl_cols_row(l_interface_cols_row.SEQUENCE_NUM , userenv('LANG'));
           FETCH c_interface_tl_cols_row into l_interface_tl_cols_row;
           hr_utility.set_location(l_interface_tl_cols_row.sequence_num, 80);
           IF c_interface_tl_cols_row%NOTFOUND THEN
              RAISE no_default_layout;
           END IF;
           CLOSE c_interface_tl_cols_row;

           IF g_riw_data.EXISTS(l_interface_cols_row.SEQUENCE_NUM) THEN
              l_prompt_left  :=  g_riw_data(l_interface_cols_row.SEQUENCE_NUM).xml_tag ;
              l_prompt_above := l_prompt_left;
           ELSE
              l_prompt_left := l_interface_tl_cols_row.PROMPT_LEFT;
              l_prompt_above := l_prompt_left;
           END IF;

           INSERT INTO BNE_INTERFACE_COLS_TL
             (APPLICATION_ID
             ,INTERFACE_CODE
             ,SEQUENCE_NUM
             ,LANGUAGE
             ,SOURCE_LANG
             ,USER_HINT
             ,PROMPT_LEFT
             ,USER_HELP_TEXT
             ,PROMPT_ABOVE
             ,CREATED_BY
             ,CREATION_DATE
             ,LAST_UPDATED_BY
             ,LAST_UPDATE_DATE)
           VALUES
             (l_interface_tl_cols_row.APPLICATION_ID
             ,p_new_interface_code
             ,l_interface_tl_cols_row.SEQUENCE_NUM
             ,userenv('LANG')
             ,userenv('LANG')
             ,l_interface_tl_cols_row.USER_HINT
             ,l_prompt_left --have to change based on layout selection
             ,l_interface_tl_cols_row.USER_HELP_TEXT
             ,l_prompt_above --have to change based on layout selection
             ,l_interface_cols_row.CREATED_BY
             ,SYSDATE
             ,l_interface_cols_row.CREATED_BY
             ,SYSDATE);
             hr_utility.set_location('TL Records succes', 81);


END LOOP;
CLOSE c_interface_cols_row;
END IF;
Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END Create_RIW_Interface_Col_Rows;


-- =============================================================================
-- ~ Create_RIW_Layout_Row:
-- =============================================================================
PROCEDURE Create_RIW_Layout_Row
            (p_application_id   IN  NUMBER
            ,p_new_layout_code  IN  VARCHAR2
            ,p_base_layout_code IN  VARCHAR2
            ,p_user_name        IN  VARCHAR2
            ,p_new_intg_code    IN  VARCHAR2) IS


CURSOR c_layout_row
IS
SELECT application_id
      ,object_version_number
      ,stylesheet_app_id
      ,stylesheet_code
      ,integrator_app_id
      ,integrator_code
      ,style
      ,style_class
      ,reporting_flag
      ,reporting_interface_app_id
      ,reporting_interface_code
      ,created_by
      ,last_updated_by
      ,last_update_login
      ,create_doc_list_app_id
      ,create_doc_list_code
FROM   bne_layouts_b
WHERE  application_id = p_application_id
AND    layout_code = p_base_layout_code;

l_layout_row         c_layout_row%ROWTYPE;
l_rowid              VARCHAR2(200);
no_default_layout    EXCEPTION;
l_proc_name          VARCHAR2(72) := g_package||'Create_RIW_Layout_Row';

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

  OPEN  c_layout_row;
  FETCH c_layout_row  INTO l_layout_row;
  IF c_layout_row%NOTFOUND THEN
     RAISE no_default_layout;
  END IF;
  CLOSE c_layout_row;

  bne_layouts_pkg.insert_row
          (x_rowid                           => l_rowid
          ,x_application_id                  => l_layout_row.application_id
          ,x_layout_code                     => p_new_layout_code
          ,x_object_version_number           => 1
          ,x_stylesheet_app_id               => l_layout_row.stylesheet_app_id
          ,x_stylesheet_code                 => l_layout_row.stylesheet_code
          ,x_integrator_app_id               => l_layout_row.integrator_app_id
          ,x_integrator_code                 => p_new_intg_code--l_layout_row.integrator_code
          ,x_style                           => l_layout_row.style
          ,x_style_class                     => l_layout_row.style_class
          ,x_reporting_flag                  => l_layout_row.reporting_flag
          ,x_reporting_interface_app_id      => l_layout_row.reporting_interface_app_id
          ,x_reporting_interface_code        => l_layout_row.reporting_interface_code
          ,x_user_name                       => p_user_name
          ,x_creation_date                   => SYSDATE
          ,x_created_by                      => l_layout_row.created_by
          ,x_last_update_date                => SYSDATE
          ,x_last_updated_by                 => l_layout_row.last_updated_by
          ,x_last_update_login               => l_layout_row.last_update_login
          ,x_create_doc_list_app_id          => l_layout_row.create_doc_list_app_id
          ,x_create_doc_list_code            => l_layout_row.create_doc_list_code);
Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END Create_RIW_Layout_Row;



-- =============================================================================
-- ~ Create_RIW_OAF_Function:
-- =============================================================================
PROCEDURE Create_RIW_OAF_Function
            (p_application_id     IN  NUMBER
            ,p_function_name      IN  VARCHAR2
            ,p_base_function_name IN  VARCHAR2
            ,p_action_type        IN  VARCHAR2
            ,p_data_source        IN  VARCHAR2
            ,p_func_parameters    IN  VARCHAR2
            ,p_user_function_name IN  VARCHAR2
            ,p_new_interface_code IN  VARCHAR2
	    ,p_new_layout_code    IN  VARCHAR2) IS

CURSOR c_function_row (c_function_name IN  VARCHAR2)
IS
SELECT WEB_ICON
      ,WEB_HOST_NAME
      ,WEB_AGENT_NAME
      ,WEB_HTML_CALL
      ,WEB_ENCRYPT_PARAMETERS
      ,WEB_SECURED
      ,OBJECT_ID
      ,REGION_APPLICATION_ID
      ,REGION_CODE
      ,FUNCTION_ID
      ,FUNCTION_NAME
      ,APPLICATION_ID
      ,FORM_ID
      ,PARAMETERS
      ,TYPE
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,MAINTENANCE_MODE_SUPPORT
      ,CONTEXT_DEPENDENCE
      ,JRAD_REF_PATH
FROM   FND_FORM_FUNCTIONS
WHERE  FUNCTION_NAME  = c_function_name;

l_function_row       c_function_row%ROWTYPE;
l_rowid              VARCHAR2(200);
no_default_layout    EXCEPTION;
l_fun_id             NUMBER;
l_func_parameters    VARCHAR2(1000);
l_function_name      VARCHAR2(30);
l_blob               BLOB;
l_text               VARCHAR2(32767);
poXML                CLOB;
l_xml_tag_name       VARCHAR2(150);
l_xml_seq_num        VARCHAR2(150);
l_seg_xml_tag_name   VARCHAR2(150);
L_GROUP_NAME         VARCHAR2(150);
l_FLXDU_COLUMN_XML_DATA VARCHAR2(150);
l_seg_column_xml_data   VARCHAR2(150);
l_proc_name          VARCHAR2(72) := g_package||'Create_RIW_OAF_Function';

BEGIN
Hr_Utility.set_location('Entering: '||l_proc_name, 5);

IF p_action_type = 'Update' THEN
   SELECT fff.function_name into l_function_name
   FROM   fnd_form_functions fff, fnd_form_functions_tl ffft
   WHERE  fff.FUNCTION_ID = ffft.FUNCTION_ID
   AND    ffft.SOURCE_LANG = userenv('LANG')
   AND    ffft.LANGUAGE = userenv('LANG')
   AND    ffft.USER_FUNCTION_NAME = p_user_function_name;

   OPEN  c_function_row(c_function_name => l_function_name);
   FETCH c_function_row  INTO l_function_row;
   IF c_function_row%NOTFOUND THEN
      RAISE no_default_layout;
   END IF;
   CLOSE c_function_row;
ELSE
   OPEN  c_function_row(c_function_name => p_base_function_name);
   FETCH c_function_row  INTO l_function_row;
   IF c_function_row%NOTFOUND THEN
      RAISE no_default_layout;
   END IF;
   CLOSE c_function_row;
END IF;


l_func_parameters := replace(p_func_parameters,'$','&');

IF p_action_type = 'Update' THEN

     l_func_parameters     := l_func_parameters||'$pFunctionId='|| l_function_row.FUNCTION_ID;
     l_func_parameters := replace(l_func_parameters,'$','&');


      fnd_form_functions_pkg.UPDATE_ROW
       (X_FUNCTION_ID              => l_function_row.FUNCTION_ID
       ,X_WEB_HOST_NAME            => l_function_row.WEB_HOST_NAME
       ,X_WEB_AGENT_NAME           => l_function_row.WEB_AGENT_NAME
       ,X_WEB_HTML_CALL            => l_function_row.WEB_HTML_CALL --can be changed later
       ,X_WEB_ENCRYPT_PARAMETERS   => l_function_row.WEB_ENCRYPT_PARAMETERS
       ,X_WEB_SECURED              => l_function_row.WEB_SECURED
       ,X_WEB_ICON                 => l_function_row.WEB_ICON
       ,X_OBJECT_ID                => l_function_row.OBJECT_ID
       ,X_REGION_APPLICATION_ID    => l_function_row.REGION_APPLICATION_ID
       ,X_REGION_CODE              => l_function_row.REGION_CODE
       ,X_FUNCTION_NAME            => l_function_row.FUNCTION_NAME
       ,X_APPLICATION_ID           => l_function_row.APPLICATION_ID
       ,X_FORM_ID                  => l_function_row.FORM_ID
       ,X_PARAMETERS               => l_func_parameters --can be changed later
       ,X_TYPE                     => l_function_row.TYPE
       ,X_USER_FUNCTION_NAME       => p_user_function_name --can be changed later
       ,X_DESCRIPTION              => p_user_function_name --can be changed later
       ,X_LAST_UPDATE_DATE         => sysdate
       ,X_LAST_UPDATED_BY          => l_function_row.CREATED_BY
       ,X_LAST_UPDATE_LOGIN        => 0);

    --$ Update Metadata ( FLXDU_FUNC_INTEGRATOR_CODE in PQP_FLXDU_FUNC_ATTRIBUTES)
       update PQP_FLXDU_FUNC_ATTRIBUTES
       set FLXDU_FUNC_INTEGRATOR_CODE  = p_new_interface_code
       where flxdu_func_attribute_id = l_function_row.FUNCTION_ID
        and flxdu_func_name = l_function_row.FUNCTION_NAME;
ELSE

       SELECT  fnd_form_functions_s.nextval
       INTO    l_fun_id
       FROM    dual;
      l_func_parameters     := l_func_parameters||'$pFunctionId='|| l_fun_id;
      l_func_parameters := replace(l_func_parameters,'$','&');

      fnd_form_functions_pkg.INSERT_ROW
       (X_ROWID                    => l_rowid
       ,X_FUNCTION_ID              => l_fun_id
       ,X_WEB_HOST_NAME            => l_function_row.WEB_HOST_NAME
       ,X_WEB_AGENT_NAME           => l_function_row.WEB_AGENT_NAME
       ,X_WEB_HTML_CALL            => l_function_row.WEB_HTML_CALL--can be changed later
       ,X_WEB_ENCRYPT_PARAMETERS   => l_function_row.WEB_ENCRYPT_PARAMETERS
       ,X_WEB_SECURED              => l_function_row.WEB_SECURED
       ,X_WEB_ICON                 => l_function_row.WEB_ICON
       ,X_OBJECT_ID                => l_function_row.OBJECT_ID
       ,X_REGION_APPLICATION_ID    => l_function_row.REGION_APPLICATION_ID
       ,X_REGION_CODE              => l_function_row.REGION_CODE
       ,X_FUNCTION_NAME            => p_function_name
       ,X_APPLICATION_ID           => p_application_id
       ,X_FORM_ID                  => l_function_row.FORM_ID
       ,X_PARAMETERS               => l_func_parameters --can be changed later
       ,X_TYPE                     => l_function_row.TYPE
       ,X_USER_FUNCTION_NAME       => p_user_function_name --can be changed later
       ,X_DESCRIPTION              => p_user_function_name --can be changed later
       ,X_CREATION_DATE            => Sysdate
       ,X_CREATED_BY               => l_function_row.CREATED_BY
       ,X_LAST_UPDATE_DATE         => sysdate
       ,X_LAST_UPDATED_BY          => l_function_row.CREATED_BY
       ,X_LAST_UPDATE_LOGIN        => 0
       ,X_MAINTENANCE_MODE_SUPPORT => l_function_row.MAINTENANCE_MODE_SUPPORT
       ,X_CONTEXT_DEPENDENCE       => l_function_row.CONTEXT_DEPENDENCE
       ,X_JRAD_REF_PATH            => l_function_row.JRAD_REF_PATH);

END IF;

       IF p_data_source = 'XML' THEN
          poXML := '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
                    <DataList>
                    <Data>';
          FOR csr_xml_tags_rec IN csr_get_xml_tags
                                 (c_interface_code   => p_new_interface_code
                                 ,c_layout_code      => p_new_layout_code)
          LOOP
              l_xml_tag_name := csr_xml_tags_rec.FLXDU_COLUMN_XML_TAG;
              l_xml_seq_num  := csr_xml_tags_rec.FLXDU_SEQ_NUM;
              l_group_name   := csr_xml_tags_rec.FLXDU_GROUP_NAME;
              l_flxdu_column_xml_data := csr_xml_tags_rec.flxdu_column_xml_data;

	      IF l_flxdu_column_xml_data IS NULL THEN
                 l_flxdu_column_xml_data := '';
	      END IF;
              --Looping for Flexi context and segments
              IF l_group_name is not null THEN
                 poXML := poXML ||
                 '<'||l_xml_tag_name||'>';
                 FOR csr_get_xml_tags_rec IN csr_get_flex_xml_tags
                                     (c_flxdu_group_name   => l_group_name)
                 LOOP
                     l_seg_xml_tag_name := csr_get_xml_tags_rec.FLXDU_COLUMN_XML_TAG;
		     l_seg_column_xml_data := csr_get_xml_tags_rec.flxdu_column_xml_data;
   	             IF l_seg_column_xml_data IS NULL THEN
                        l_seg_column_xml_data := '';
	             END IF;
                     poXML := poXML ||
                     '<'||l_seg_xml_tag_name||'> '||l_seg_column_xml_data||' </'|| l_seg_xml_tag_name||'>';
                 END LOOP;
                 poXML := poXML ||
                 '</'|| l_xml_tag_name||'>';
              ELSE
                  poXML := poXML ||
                  '<'||l_xml_tag_name||'> '||l_flxdu_column_xml_data||' </'|| l_xml_tag_name||'>';
              END IF;
          END LOOP;

              poXML :=poXML || '</Data>
                     </DataList>';
       END IF;

 IF p_action_type = 'Update' THEN

     update PQP_FLXDU_FUNC_ATTRIBUTES set flxdu_func_xml_data = poXML
       where flxdu_func_attribute_id = l_function_row.FUNCTION_ID
        and flxdu_func_name = l_function_row.FUNCTION_NAME;
 ELSE
      INSERT INTO PQP_FLXDU_FUNC_ATTRIBUTES
        (FLXDU_FUNC_ATTRIBUTE_ID
        ,FLXDU_FUNC_NAME
        ,FLXDU_FUNC_SOURCE_TYPE
        ,FLXDU_FUNC_INTEGRATOR_CODE
        ,FLXDU_FUNC_XML_DATA
        ,LEGISLATION_CODE
        ,DESCRIPTION
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,OBJECT_VERSION_NUMBER)
        VALUES
        (l_fun_id
        ,p_function_name
        ,p_data_source
        ,p_new_interface_code
        ,poXML
        ,'US'
        ,p_user_function_name
        ,l_function_row.CREATED_BY
        ,SYSDATE
        ,l_function_row.CREATED_BY
        ,SYSDATE
        ,l_function_row.CREATED_BY
        ,1);
 END IF;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END Create_RIW_OAF_Function;




-- =============================================================================
-- ~ Create_RIW_Menu_Entries:
-- =============================================================================
PROCEDURE Create_RIW_Menu_Entries
            (p_application_id     IN  NUMBER
            ,p_menu_id            IN  NUMBER
            ,p_function_name      IN VARCHAR2
            ,p_user_function_name IN VARCHAR2) IS


l_rowid            VARCHAR2(200);
no_default_layout  EXCEPTION;
l_fun_id           NUMBER;
l_ENTRY_SEQUENCE   NUMBER := 0;
l_proc_name        VARCHAR2(72) := g_package||'Create_RIW_Menu_Entries';

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

  SELECT function_id
  INTO   l_fun_id
  FROM   fnd_form_functions
  WHERE  function_name = p_function_name;

  SELECT max(ENTRY_SEQUENCE)
  INTO   l_ENTRY_SEQUENCE
  FROM   fnd_menu_entries
  WHERE  MENU_ID= p_menu_id ;

  fnd_menu_entries_pkg.insert_row
        (X_ROWID              => l_rowid
        ,X_MENU_ID            => p_menu_id
        ,X_ENTRY_SEQUENCE     => l_ENTRY_SEQUENCE+1
        ,X_SUB_MENU_ID        => null
        ,X_FUNCTION_ID        => l_fun_id
        ,X_GRANT_FLAG         => 'Y'
        ,X_PROMPT             => p_user_function_name --Can be change later
        ,X_DESCRIPTION        => p_user_function_name --can be change later
        ,X_CREATION_DATE      => sysdate
        ,X_CREATED_BY         => 1
        ,X_LAST_UPDATE_DATE   => sysdate
        ,X_LAST_UPDATED_BY    => 1
        ,X_LAST_UPDATE_LOGIN  => 0);

Hr_Utility.set_location('Leaving: '||l_proc_name, 5);
END Create_RIW_Menu_Entries;





-- =============================================================================
-- ~ Delete_riw_integrator:
-- =============================================================================
PROCEDURE Delete_riw_integrator(p_LAYOUT_CODE     IN VARCHAR2 default null
                                ,p_MAPPING_CODE    IN VARCHAR2 default null
                                ,p_INTERFACE_CODE  IN VARCHAR2
                                ,p_application_id  IN NUMBER ) IS

  --$ get Integrator Code to delete entire integrator setup in one shot using
  -- Function bne_integrator_utils.DELETE_INTEGRATOR
  CURSOR csr_get_integrator_code is
  select integrator_code from bne_interfaces_b where interface_code
  = p_INTERFACE_CODE and application_id = p_application_id;

  l_proc   varchar2(72) := g_package||'Delete_riw_integrator';
  l_intg_code varchar2(30);
  l_param_list_code varchar2(30);
  cnt number;

BEGIN

    --$ Use bne_integrator_utils.DELETE_INTEGRATOR to delete entire setup
     OPEN csr_get_integrator_code;
     fetch csr_get_integrator_code into l_intg_code;
     Close csr_get_integrator_code;

     l_param_list_code := l_intg_code || '_DP';
     DELETE FROM BNE_PARAM_LISTS_TL WHERE PARAM_LIST_CODE = l_param_list_code and application_id = p_application_id;
     DELETE FROM BNE_PARAM_LISTS_B WHERE PARAM_LIST_CODE = l_param_list_code and application_id = p_application_id;

     cnt := bne_integrator_utils.DELETE_INTEGRATOR
                        ( P_INTEGRATOR_CODE => l_intg_code,
                          P_APPLICATION_ID => p_application_id);

    --$ COMMENT MANUAL DELETION STEPS
   /*   DELETE
      FROM   BNE_MAPPING_LINES
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    MAPPING_CODE = p_MAPPING_CODE
      AND    INTERFACE_CODE =p_INTERFACE_CODE;

      DELETE
      FROM   BNE_MAPPINGS_tl
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    MAPPING_CODE = p_MAPPING_CODE;

      DELETE
      FROM   BNE_MAPPINGS_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    MAPPING_CODE = p_MAPPING_CODE;


      DELETE
      FROM   BNE_LAYOUT_COLS
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    LAYOUT_CODE = p_LAYOUT_CODE;

      DELETE
      FROM   bne_layout_blocks_tl
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    LAYOUT_CODE = p_LAYOUT_CODE;

      DELETE
      FROM   bne_layout_blocks_b
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    LAYOUT_CODE = p_LAYOUT_CODE;

      DELETE
      FROM   bne_layouts_tl
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    LAYOUT_CODE = p_LAYOUT_CODE;

      DELETE
      FROM   bne_layouts_b
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    LAYOUT_CODE = p_LAYOUT_CODE;

      DELETE
      FROM   BNE_INTERFACE_cols_tl
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = p_INTERFACE_CODE;

      DELETE
      FROM   BNE_INTERFACE_cols_b
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = p_INTERFACE_CODE;

      DELETE
      FROM   BNE_INTERFACES_tl
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = p_INTERFACE_CODE;

      DELETE
      FROM   BNE_INTERFACES_B
      WHERE  APPLICATION_ID = P_APPLICATION_ID
      AND    INTERFACE_CODE = p_INTERFACE_CODE; */
EXCEPTION
    WHEN OTHERS   THEN
    hr_utility.set_location('ERROR occured',30);
    Null;
END Delete_riw_integrator;


-- =============================================================================
-- ~ Create_RIW_Integrator_Row:
-- =============================================================================
PROCEDURE Create_RIW_Integrator_Row
            (p_application_id      IN  NUMBER
            ,p_new_intg_code       IN  VARCHAR2
            ,p_base_intg_code      IN  VARCHAR2
            ,p_integrator_name     IN  VARCHAR2) IS


CURSOR c_intg_row
IS
SELECT APPLICATION_ID
      ,INTEGRATOR_CODE
      ,OBJECT_VERSION_NUMBER
      ,ENABLED_FLAG
      ,UPLOAD_PARAM_LIST_APP_ID
      ,UPLOAD_PARAM_LIST_CODE
      ,UPLOAD_SERV_PARAM_LIST_APP_ID
      ,UPLOAD_SERV_PARAM_LIST_CODE
      ,IMPORT_PARAM_LIST_APP_ID
      ,IMPORT_PARAM_LIST_CODE
      ,UPLOADER_CLASS
      ,DATE_FORMAT
      ,IMPORT_TYPE
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,LAST_UPDATE_DATE
      ,CREATE_DOC_LIST_APP_ID
      ,CREATE_DOC_LIST_CODE
      ,NEW_SESSION_FLAG
FROM   BNE_INTEGRATORS_B
WHERE  application_id  = p_application_id
AND    INTEGRATOR_CODE = p_base_intg_code;

l_intg_row               c_intg_row%ROWTYPE;
l_rowid                  VARCHAR2(200);
no_default_layout        EXCEPTION;
VV_INTEGRATOR_CODE       BNE_INTEGRATORS_B.INTEGRATOR_CODE%TYPE;
l_proc_name              VARCHAR2(72) := g_package||'Create_RIW_Integrator_Row';

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);
  OPEN  c_intg_row;
  FETCH c_intg_row  INTO l_intg_row;
  IF c_intg_row%NOTFOUND THEN
     RAISE no_default_layout;
  END IF;
  CLOSE c_intg_row;

   BEGIN
      SELECT INTEGRATOR_CODE
      INTO   VV_INTEGRATOR_CODE
      FROM   BNE_INTEGRATORS_B
      WHERE  APPLICATION_ID  = P_APPLICATION_ID
      AND    INTEGRATOR_CODE = p_new_intg_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

    -- If the Integrator does not exist then

    IF ( VV_INTEGRATOR_CODE IS NULL) THEN

      INSERT INTO BNE_INTEGRATORS_B
       (APPLICATION_ID
       ,INTEGRATOR_CODE
       ,OBJECT_VERSION_NUMBER
       ,ENABLED_FLAG
       ,UPLOAD_PARAM_LIST_APP_ID
       ,UPLOAD_PARAM_LIST_CODE
       ,UPLOAD_SERV_PARAM_LIST_APP_ID
       ,UPLOAD_SERV_PARAM_LIST_CODE
       ,IMPORT_PARAM_LIST_APP_ID
       ,IMPORT_PARAM_LIST_CODE
       ,UPLOADER_CLASS
       ,DATE_FORMAT
       ,IMPORT_TYPE
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN
       ,LAST_UPDATE_DATE
       ,CREATE_DOC_LIST_APP_ID
       ,CREATE_DOC_LIST_CODE
       ,NEW_SESSION_FLAG       )
      VALUES
       (l_intg_row.APPLICATION_ID
       ,p_new_intg_code
       ,1
       ,l_intg_row.ENABLED_FLAG
       ,l_intg_row.UPLOAD_PARAM_LIST_APP_ID
       ,l_intg_row.UPLOAD_PARAM_LIST_CODE
       ,l_intg_row.UPLOAD_SERV_PARAM_LIST_APP_ID
       ,l_intg_row.UPLOAD_SERV_PARAM_LIST_CODE
       ,l_intg_row.IMPORT_PARAM_LIST_APP_ID
       ,l_intg_row.IMPORT_PARAM_LIST_CODE
       ,l_intg_row.UPLOADER_CLASS
       ,l_intg_row.DATE_FORMAT
       ,l_intg_row.IMPORT_TYPE
       ,l_intg_row.CREATED_BY
       ,SYSDATE
       ,l_intg_row.LAST_UPDATED_BY
       ,l_intg_row.LAST_UPDATE_LOGIN
       ,SYSDATE
       ,l_intg_row.CREATE_DOC_LIST_APP_ID
       ,l_intg_row.CREATE_DOC_LIST_CODE
       ,l_intg_row.NEW_SESSION_FLAG
        );

      INSERT INTO BNE_INTEGRATORS_TL
       (APPLICATION_ID
       ,INTEGRATOR_CODE
       ,LANGUAGE
       ,SOURCE_LANG
       ,USER_NAME
       ,UPLOAD_HEADER
       ,UPLOAD_TITLE_BAR
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_DATE)
      VALUES
       (l_intg_row.APPLICATION_ID
       ,p_new_intg_code
       ,userenv('LANG')
       ,userenv('LANG')
       ,p_integrator_name
       ,'Upload Parameters'
       ,'Upload Parameters'
       ,l_intg_row.CREATED_BY
       ,SYSDATE
       ,l_intg_row.LAST_UPDATED_BY
       ,SYSDATE);



       BNE_SECURITY_UTILS_PKG.ADD_OBJECT_RULES (
          P_APPLICATION_ID =>l_intg_row.APPLICATION_ID,
          P_OBJECT_CODE    =>p_new_intg_code,
          P_OBJECT_TYPE    =>'INTEGRATOR',
          P_SECURITY_CODE  =>p_new_intg_code,
          P_SECURITY_TYPE  =>'FUNCTION',
          P_SECURITY_VALUE =>'PQP_FLEXIBLE_WEBADI_CREATE_DOC',
          P_USER_ID        =>1);
     END IF;
  Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END Create_RIW_Integrator_Row;




-- =============================================================================
-- ~ Create_RIW_Content_Row:
-- =============================================================================
PROCEDURE Create_RIW_Content_Row
            (p_application_id      IN  NUMBER
            ,p_new_content_code    IN  VARCHAR2
            ,p_base_content_code   IN  VARCHAR2
            ,p_intg_code           IN  VARCHAR2
            ,p_content_name        IN  VARCHAR2
            ,p_entity_name         IN  VARCHAR2  DEFAULT NULL
            ,p_content_out         OUT NOCOPY VARCHAR2
--$ Data Pump Correct Errors Content Code
            ,p_ce_content_out      OUT NOCOPY VARCHAR2) IS


CURSOR c_content_row(c_base_content_code in VARCHAR2) --$ based upon content code
                                   -- properties will be fetched as we have to create
                                   -- two contents -> hr/xml/csv and other is for
                                   -- correct errors for Data Pump
IS
SELECT APPLICATION_ID
      ,CONTENT_CODE
      ,OBJECT_VERSION_NUMBER
      ,INTEGRATOR_APP_ID
      ,INTEGRATOR_CODE
      ,PARAM_LIST_APP_ID
      ,PARAM_LIST_CODE
      ,CONTENT_CLASS
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
FROM   bne_contents_b
WHERE  application_id = p_application_id
AND    CONTENT_CODE = c_base_content_code;

l_content_row          c_content_row%ROWTYPE;
l_rowid                VARCHAR2(200);
no_default_layout      EXCEPTION;
VV_INTEGRATOR_CODE     BNE_INTEGRATORS_B.INTEGRATOR_CODE%TYPE;
l_content_out          VARCHAR2(50);
--$ For Data Pump Correct Errors
l_ce_content_out          VARCHAR2(50);

l_temp_val             VARCHAR2(4000);
l_proc_name            VARCHAR2(72) := g_package||'Create_RIW_Content_Row';

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

  OPEN  c_content_row(c_base_content_code => p_base_content_code); --$ create non data pump content
  FETCH c_content_row  INTO l_content_row;
  IF c_content_row%NOTFOUND THEN
     RAISE no_default_layout;
  END IF;
  CLOSE c_content_row;

  --Creating content for HR
  l_temp_val := 'BatchId,';
  --$ In case of XML use EffectiveDate as Content Column name to map it to the
  -- tag in "Sample Download XML" which is stored in PQP_FLXDU_COLUMNS table
  IF (p_base_content_code = 'PQP_FLEXI_WEBADI_XML_CNT') then
  l_temp_val := l_temp_val||'EffectiveDate,';
  ELSE
  l_temp_val := l_temp_val||'DateOfHire,';
  END IF;
  l_temp_val := l_temp_val||'LastName,Sex,PerComments,DateEmpDataVerified,DateOfBirth,EmailAddr,EmpNumber,';

  l_temp_val := l_temp_val ||' ExpenseCheckSendToAddr,FirstName,PreferredName,MaritalStatus,MiddleName,Nationality,NationalIdentifier,PreviousLastName,';
  l_temp_val := l_temp_val ||'RegisteredDisabledFlag,Prefix,WorkTelephoneNumber,PplAttrCategory,PplAttr1,PplAttr2,PplAttr3,PplAttr4,PplAttr5,PplAttr6,';
  l_temp_val := l_temp_val ||'PplAttr7,PplAttr8,PplAttr9,PplAttr10,PplAttr11,PplAttr12,PplAttr13,PplAttr14,PplAttr15,PplAttr16,PplAttr17,PplAttr18,';
  l_temp_val := l_temp_val ||'PplAttr19,PplAttr20,PplAttr21,PplAttr22,PplAttr23,PplAttr24,PplAttr25,PplAttr26,PplAttr27,PplAttr28,PplAttr29,PplAttr30,';
  l_temp_val := l_temp_val ||'PerInfCategory,PerInf1,PerInf2,PerInf3,PerInf4,PerInf5,PerInf6,PerInf7,PerInf8,PerInf9,PerInf10,PerInf11,PerInf12,PerInf13,';
  l_temp_val := l_temp_val ||'PerInf14,PerInf15,PerInf16,PerInf17,PerInf18,PerInf19,PerInf20,PerInf21,PerInf22,PerInf23,PerInf24,PerInf25,PerInf26,PerInf27,';
  l_temp_val := l_temp_val ||'PerInf28,PerInf29,PerInf30,DateOfDeath,BackgroundCheckStatus,BackgroundCheckDate,BloodType,FastPathEmp,FTECapacity,Honours,';
  l_temp_val := l_temp_val ||'InternalLocation,LastMedicalTestBy,LastMedicalTestDate,MailStop,OfficeNumber,MilitaryService,Title,RehireRecommandation,';
  l_temp_val := l_temp_val ||'ProjectedStartDate,ResumeExists,ResumeLastUpdated,SecondPassportExists,StudentStatus,WorkSchedule,Suffix,';
  l_temp_val := l_temp_val ||'DeathCertificateRcptDate,CoordBenMedicalPlanNumber,CoordBenNoCVGFlag,CoordBenMedicalExtensionER,CoordBenMedicalPLName,';
  l_temp_val := l_temp_val ||'CoordBenInsuranceCRName,CoordBenInsuranceCRRIdentity,CoordBenInsuranceCVGStartDate,CoordBenInsuranceCVGEndDate,';
  l_temp_val := l_temp_val ||'TobaccoUsageFlag,DependentAdoptionDate,DependentVoluntaryServiceFlag,OriginalDateOfHire,AdjustedServiceDate,';
  l_temp_val := l_temp_val ||'TownOfBirth,RegionOfBirth,CountryOfBirth,GlobalPerId,UserPerType,VendorId,CorrespondenceLanguage,BenefitGroupId,';
  l_temp_val := l_temp_val ||'StudentNumber,PartyId,PrimaryAddrOverrideFlag,PrimaryAddrFlag,AddrStyle,AddrInfo1,AddrInfo2,';
  l_temp_val := l_temp_val ||'AddrInfo3,AddrInfo4,AddrInfo5,AddrInfo6,AddrInfo7,AddrInfo8,';
  l_temp_val := l_temp_val ||'AddrInfo9,AddrInfo10,AddrInfo11,AddrInfo12,AddrInfo13,AddrInfo14,AddrInfo15,AddrInfo16,';
  l_temp_val := l_temp_val ||'AddrInfo17,AddrInfo18,AddrInfo19,AddrInfo20,AddrType,AddrDateFrom,AddrDateTo,';
  l_temp_val := l_temp_val ||'AddrAttrCategory,AddrAttr1,AddrAttr2,AddrAttr3,AddrAttr4,AddrAttr5,AddrAttr6,AddrAttr7,AddrAttr8,AddrAttr9,AddrAttr10,';
  l_temp_val := l_temp_val ||'AddrAttr11,AddrAttr12,AddrAttr13,AddrAttr14,AddrAttr15,AddrAttr16,AddrAttr17,AddrAttr18,AddrAttr19,AddrAttr20,AddrComments,';
  l_temp_val := l_temp_val ||'AssgNumber,ChangeReason,AssgComments,ProbationEndDate,Frequency,InternalAddrLine,ManagerFlag,NormalHours,PerfReviewPeriod,';
  l_temp_val := l_temp_val ||'PerfReviewPeriodFrequency,ProbationPeriod,';
  l_temp_val := l_temp_val ||'ProbationUnit,SalaryReviewPeriod,SalaryReviewPeriodFrequency,SourceType,TimeNormalFinish,';
  l_temp_val := l_temp_val ||'TimeNormalStart,BargainingUnitCode,LabourUnionMemberFlag,HourlySalariedCode,AssgAttrCategory,AssgAttr1,AssgAttr2,';
  l_temp_val := l_temp_val ||'AssgAttr3,AssgAttr4,AssgAttr5,AssgAttr6,AssgAttr7,AssgAttr8,AssgAttr9,AssgAttr10,AssgAttr11,AssgAttr12,AssgAttr13,';
  l_temp_val := l_temp_val ||'AssgAttr14,AssgAttr15,AssgAttr16,AssgAttr17,AssgAttr18,AssgAttr19,AssgAttr20,AssgAttr21,AssgAttr22,AssgAttr23,';
  l_temp_val := l_temp_val ||'AssgAttr24,AssgAttr25,AssgAttr26,AssgAttr27,AssgAttr28,AssgAttr29,AssgAttr30,PplSeg1,PplSeg2,PplSeg3,PplSeg4,';
  l_temp_val := l_temp_val ||'PplSeg5,PplSeg6,PplSeg7,PplSeg8,PplSeg9,PplSeg10,PplSeg11,PplSeg12,PplSeg13,PplSeg14,PplSeg15,PplSeg16,PplSeg17,';
  l_temp_val := l_temp_val ||'PplSeg18,PplSeg19,PplSeg20,PplSeg21,PplSeg22,PplSeg23,PplSeg24,PplSeg25,PplSeg26,PplSeg27,PplSeg28,PplSeg29,';
  l_temp_val := l_temp_val ||'PplSeg30,Grade,Position,Job,Payroll,Location,Organization,SalaryBasis,Loc,ContactType,PrimaryContact,';
  l_temp_val := l_temp_val ||'PersnlRelationship,ContactName,DataPumpBatchLineId,PersnlAddrInfo,AddtnlAddrDtls,FurtherPerInfo,AddtnlPersnlDtls,';
  l_temp_val := l_temp_val ||'AddtnlAssgDtls,Status,AssgCategory,CollectiveAgreement,EmployeeCategory,';

  -- For XML the content column GRE should be same as XML Tag used in
  -- PQP_FLXDU_COLUMNS
  IF (p_base_content_code = 'PQP_FLEXI_WEBADI_XML_CNT') then
  l_temp_val := l_temp_val || 'SoftKeySegment1,';
  else
  l_temp_val := l_temp_val || 'GRE,';
  end if;

  l_temp_val := l_temp_val || 'SupervisorName,DefaultCodeCombinationId,SetOfBooksId,';
  l_temp_val := l_temp_val ||'ApplNum,ApplAssgNum,CntgntWrkNum';
  --$Content for Soft Coded KFF columns
  -- For XML the content columns should be same as XML Tags used in
  -- PQP_FLXDU_COLUMNS
  IF (p_base_content_code = 'PQP_FLEXI_WEBADI_XML_CNT') then
  l_temp_val := l_temp_val || ',SoftKeySegment2,SoftKeySegment3,SoftKeySegment4,SoftKeySegment5,SoftKeySegment6,SoftKeySegment7,SoftKeySegment8,';
  l_temp_val := l_temp_val || 'SoftKeySegment9,SoftKeySegment10,SoftKeySegment11,SoftKeySegment12,SoftKeySegment13,SoftKeySegment14,SoftKeySegment15,SoftKeySegment16,';
  l_temp_val := l_temp_val || 'SoftKeySegment17,SoftKeySegment18,SoftKeySegment19,SoftKeySegment20,SoftKeySegment21,SoftKeySegment22,SoftKeySegment23,SoftKeySegment24,';
  l_temp_val := l_temp_val || 'SoftKeySegment25,SoftKeySegment26,SoftKeySegment27,SoftKeySegment28,SoftKeySegment29,SoftKeySegment30';
  else
  l_temp_val := l_temp_val ||',sclSeg2,sclSeg3,sclSeg4,'; -- sclSeg1 or GRE is already included
  l_temp_val := l_temp_val ||'sclSeg5,sclSeg6,sclSeg7,sclSeg8,sclSeg9,sclSeg10,sclSeg11,sclSeg12,sclSeg13,sclSeg14,sclSeg15,sclSeg16,sclSeg17,';
  l_temp_val := l_temp_val ||'sclSeg18,sclSeg19,sclSeg20,sclSeg21,sclSeg22,sclSeg23,sclSeg24,sclSeg25,sclSeg26,sclSeg27,sclSeg28,sclSeg29,sclSeg30';
  end if;
  -- New column added to download Assignment effective start date and DupPerson
  l_temp_val := l_temp_val || ',AssgEfftDateFrom,DupPerson,';
  if (p_base_content_code = 'PQP_FLEXI_WEBADI_HR_CNT') then
     l_temp_val := l_temp_val || 'AssgId';
  end if;

  BNE_CONTENT_UTILS.CREATE_CONTENT_DYNAMIC_SQL
        (P_APPLICATION_ID   =>l_content_row.APPLICATION_ID
        ,P_OBJECT_CODE      =>p_new_content_code
        ,P_INTEGRATOR_CODE  =>p_intg_code
        ,P_CONTENT_DESC     =>p_content_name
        ,P_CONTENT_CLASS    =>l_content_row.CONTENT_CLASS
        ,P_COL_LIST         =>l_temp_val
        ,P_LANGUAGE         =>userenv('LANG')
        ,P_SOURCE_LANGUAGE  =>userenv('LANG')
        ,P_USER_ID          =>1
        ,P_CONTENT_CODE     =>l_content_out);

update bne_contents_b
   set param_list_code = l_content_row.param_list_code
      ,param_list_app_id =  l_content_row.param_list_app_id
 where content_code =l_content_out;

--$ If XML, CSV or HR Content then 'Effective Date' and 'Assignment Effective Start
-- Date' column should be uploadable and read only.
if (p_base_content_code = 'PQP_FLEXI_WEBADI_XML_CNT' OR
    p_base_content_code = 'PQP_FLEXI_WEBADI_CSV_CNT' OR
    p_base_content_code = 'PQP_FLEXI_WEBADI_HR_CNT') then
    update bne_content_cols_b set read_only_flag  = 'Y' where content_code =
   l_content_out and sequence_num in (2,316,317, 318);
end if;

p_content_out := l_content_out;

--$ Add Code to create Content for Correct Errors Spreadsheet for Data Pump
  OPEN  c_content_row(c_base_content_code => 'PQP_FLEXI_WEBADI_CE_CNT'); --$ create
                                                             -- data pump content
  FETCH c_content_row  INTO l_content_row;
  IF c_content_row%NOTFOUND THEN
     RAISE no_default_layout;
  END IF;
  CLOSE c_content_row;

l_temp_val := 'bid,h_dt,l_name,sex,p_com,dt_emdt_vrfd,dob,email,empno,xpns_snd_add,fname,pname,p_mar_stts,mname,ntnlty,';
l_temp_val := l_temp_val||
'ni,pre_lname,rgst_disbl_flg,prfx,wrktel,atr_cat,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,';
l_temp_val := l_temp_val||
'a20,a21,a22,a23,a24,a25,a26,a27,a28,a29,a30,prinf_cat,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,';
l_temp_val := l_temp_val||
'p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,dof_death,bkgrnd_ck_stts,bkgrnd_dt_ck,bld_type,fst_pth_emp,fte_cap,';
l_temp_val := l_temp_val||
'hnrs,int_loc,lst_med_tst_by,lst_med_tst_dt,mlstop,offno,on_mil_ser,title,rehire_reco,prj_st_dt,res_xst,res_lst_upd,';
l_temp_val := l_temp_val||
'scnd_psp_ex,std_stts,wrk_schd,sffx,rcpt_dth_cert_dt,co_ben_med_pln_no,co_ben_no_cvg_flg,co_ben_med_ext_er,';
l_temp_val := l_temp_val||
'co_ben_med_pl_nm,co_ben_med_insr_crr_nm,co_ben_med_insr_crr_idnt,co_ben_med_cvg_st_dt,co_ben_med_cvg_end_dt,';
l_temp_val := l_temp_val||
'us_tobacc_flg,dpdnt_adopt_dt,dpdnt_vlntry_svc_flg,org_dt_hire,adj_svc_dt,to_birth,ro_birth,co_birth,glb_perid,';
l_temp_val := l_temp_val||
'uper_type,ven_nm,cors_lang,ben_grp,stno,perid,pradd_ovlp_ovrride,pr_flg,style,adlin1,adlin2,adlin3,town,';
l_temp_val := l_temp_val||
'reg1,reg2,reg3,postcode,cntry,tno1,tno2,tno3,d13,d14,d15,d16,d17,d18,d19,d20,ad_type,dt_from,dt_to,ad_at_cat,';
l_temp_val := l_temp_val||
'b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,a_com,assignno,chng_rsn,as_com,dt_prob_end,';
l_temp_val := l_temp_val||
'freq,int_ad_line,mg_flg,nrml_hrs,perf_rev_prd,perf_rev_frq,prob_prd,prob_unit,sal_rev_prd,sal_rev_frq,src_type,';
l_temp_val := l_temp_val||
'time_nrml_fin,time_nrml_strt,bargunit_code,lbr_un_memb_flg,hrly_sal_code,asatr_cat,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,';
l_temp_val := l_temp_val||
's12,s13,s14,s15,s16,s17,s18,s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,';
l_temp_val := l_temp_val||
'k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,grdname,posname,jbname,payname,loccode,';
l_temp_val := l_temp_val||
'orgname,paybasis,loc,cnt_type,prm_cnt_flg,per_flg,cnt_name,';

l_temp_val := l_temp_val||'rid,'; -- row id or link value

l_temp_val := l_temp_val||
'concat_hr_add,cnct_hr_add2,cnct_per_info_df,cnct_per_attr_df,cnct_per_ass_df,Status,AssgCategory,CollectiveAgreement,EmployeeCategory,GRE,SupervisorName,';
l_temp_val := l_temp_val||
'DefaultCodeCombinationId,SetOfBooksId,ApplNum,ApplAssgNum,CntgntWrkNum,sclSeg2,sclSeg3,sclSeg4,sclSeg5,sclSeg6,';
l_temp_val := l_temp_val||
'sclSeg7,sclSeg8,sclSeg9,sclSeg10,sclSeg11,sclSeg12,sclSeg13,sclSeg14,sclSeg15,sclSeg16,sclSeg17,sclSeg18,sclSeg19,';
l_temp_val := l_temp_val||
'sclSeg20,sclSeg21,sclSeg22,sclSeg23,sclSeg24,sclSeg25,sclSeg26,sclSeg27,sclSeg28,sclSeg29,sclSeg30,';
l_temp_val := l_temp_val||'exp'; -- for batch exception

  -- New column added to download Assignment effective start date and DupPerson
  l_temp_val := l_temp_val || ',AssgEfftDateFrom,DupPerson, AssgId';

 BNE_CONTENT_UTILS.CREATE_CONTENT_DYNAMIC_SQL
        (P_APPLICATION_ID   => 8303 --l_content_row.APPLICATION_ID
        ,P_OBJECT_CODE      => p_new_content_code||'_CE'
        ,P_INTEGRATOR_CODE  => p_intg_code
        ,P_CONTENT_DESC     => p_content_name||'_CE'
        ,P_CONTENT_CLASS    => l_content_row.CONTENT_CLASS
        ,P_COL_LIST         => l_temp_val
        ,P_LANGUAGE         =>userenv('LANG')
        ,P_SOURCE_LANGUAGE  =>userenv('LANG')
        ,P_USER_ID          =>1
        ,P_CONTENT_CODE     =>l_ce_content_out);

   update bne_contents_b
       set param_list_code = l_content_row.param_list_code
      ,param_list_app_id =  l_content_row.param_list_app_id
       where content_code = l_ce_content_out;

p_ce_content_out := l_ce_content_out;

-- $ to make  "Effective Date",'Assignment Effective Start Date' and "Batch Link"
-- Read Only but Uploadable field at the same time
-- set Read Only flag to 'Y' in Content instead of Layout
 update bne_content_cols_b set read_only_flag = 'Y' where content_code in
 (l_ce_content_out) and sequence_num in (2,317,318, 319);
  update bne_content_cols_b set read_only_flag = 'Y' where content_code in
 (l_ce_content_out) and sequence_num = 270;


--------
Hr_Utility.set_location('Leaving: '||l_proc_name, 5);

END Create_RIW_Content_Row;

-- =============================================================================
-- ~ Create_RIW_BLNK_CONTENT_ROW
-- =============================================================================
PROCEDURE Create_RIW_BLNK_Content_row
               (p_application_id          IN  NUMBER
               ,p_new_blnk_content_code   IN  VARCHAR2
               ,p_intg_code               IN  VARCHAR2
               ,p_content_name            IN  VARCHAR2
               ,p_blnk_content_out             OUT NOCOPY VARCHAR2) IS

       l_blnk_content_out     VARCHAR2(50);
BEGIN
       BNE_CONTENT_UTILS.CREATE_CONTENT_DYNAMIC_SQL
        (P_APPLICATION_ID   =>p_application_id
        ,P_OBJECT_CODE      =>p_new_blnk_content_code
        ,P_INTEGRATOR_CODE  =>p_intg_code
        ,P_CONTENT_DESC     =>p_new_blnk_content_code
        ,P_CONTENT_CLASS    =>null
        ,P_COL_LIST         =>null
        ,P_LANGUAGE         =>userenv('LANG')
        ,P_SOURCE_LANGUAGE  =>userenv('LANG')
        ,P_USER_ID          =>1
        ,P_CONTENT_CODE     =>l_blnk_content_out);

        p_blnk_content_out  := l_blnk_content_out;

END Create_RIW_BLNK_Content_row;

-- =============================================================================
-- ~ Create_Derived_Param_List:
-- =============================================================================
PROCEDURE Create_Derived_Param_List
            (p_application_id        IN NUMBER
            ,p_param_list_code       IN VARCHAR2
            ,p_parameter_value       IN VARCHAR2) IS

          l_sequence_num      Number;
          l_param_list_code   VARCHAR2(50);
          l_pl_sql varchar2(4000);
BEGIN
          l_param_list_code := BNE_PARAMETER_UTILS.CREATE_PARAM_LIST_ALL(P_APPLICATION_ID => p_application_id
                      ,P_PARAM_LIST_CODE => p_param_list_code
                      ,P_PERSISTENT => 'Y'
                      ,P_COMMENTS => ''
                      ,P_ATTRIBUTE_APP_ID => ''
                      ,P_ATTRIBUTE_CODE => ''
                      ,P_LIST_RESOLVER => ''
                      ,P_PROMPT_LEFT => ''
                      ,P_PROMPT_ABOVE => ''
                      ,P_USER_NAME => p_parameter_value
                      ,P_USER_TIP => '');

end Create_Derived_Param_List;


PROCEDURE Create_RIW_Content_Row_Others
            (p_application_id      IN  NUMBER
            ,p_new_content_code    IN  VARCHAR2
            ,p_base_content_code   IN  VARCHAR2
            ,p_intg_code           IN  VARCHAR2
            ,p_content_name        IN  VARCHAR2
            ,p_entity_name         IN  VARCHAR2  DEFAULT NULL
            ,p_content_out         OUT NOCOPY VARCHAR2) IS


CURSOR c_content_row(c_base_content_code in VARCHAR2) --$ based upon content code
                                   -- properties will be fetched as we have to create
                                   -- two contents -> hr/xml/csv and other is for
                                   -- correct errors for Data Pump
IS
SELECT APPLICATION_ID
      ,CONTENT_CODE
      ,OBJECT_VERSION_NUMBER
      ,INTEGRATOR_APP_ID
      ,INTEGRATOR_CODE
      ,PARAM_LIST_APP_ID
      ,PARAM_LIST_CODE
      ,CONTENT_CLASS
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
FROM   bne_contents_b
WHERE  application_id = p_application_id
AND    CONTENT_CODE = c_base_content_code;

CURSOR c_content_cols_row(c_base_content_code IN VARCHAR2)
IS
SELECT col_name, read_only_flag, sequence_num
FROM bne_content_cols_b
WHERE application_id = p_application_id
AND content_code = c_base_content_code
ORDER BY sequence_num;

l_content_row          c_content_row%ROWTYPE;
l_rowid                VARCHAR2(200);
no_default_layout      EXCEPTION;
VV_INTEGRATOR_CODE     BNE_INTEGRATORS_B.INTEGRATOR_CODE%TYPE;
l_content_out          VARCHAR2(50);
l_first                boolean := true;
l_column               bne_content_cols_b.col_name%TYPE;
--$ For Data Pump Correct Errors
l_ce_content_out          VARCHAR2(50);

l_temp_val             VARCHAR2(4000);
l_proc_name            VARCHAR2(72) := g_package||'Create_RIW_Content_Row';
l_read_only_flag       varchar2(3);
l_sequence_num    number(5);

BEGIN
  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

  OPEN  c_content_row(c_base_content_code => p_base_content_code); --$ create non data pump content
  FETCH c_content_row  INTO l_content_row;
  IF c_content_row%NOTFOUND THEN
     RAISE no_default_layout;
  END IF;
  CLOSE c_content_row;

  OPEN c_content_cols_row(p_base_content_code);
    LOOP
         FETCH c_content_cols_row  INTO l_column, l_read_only_flag, l_sequence_num;
         EXIT WHEN c_content_cols_row%NOTFOUND;

         IF l_first then
           l_temp_val := l_temp_val || l_column;
         ELSE
           l_temp_val := l_temp_val || ',' || l_column;
         END IF;
         l_first := false;
     END LOOP;
  CLOSE c_content_cols_row;

  hr_utility.set_location(l_temp_val, 44);
  BNE_CONTENT_UTILS.CREATE_CONTENT_DYNAMIC_SQL
        (P_APPLICATION_ID   =>l_content_row.APPLICATION_ID
        ,P_OBJECT_CODE      =>p_new_content_code
        ,P_INTEGRATOR_CODE  =>p_intg_code
        ,P_CONTENT_DESC     =>p_content_name
        ,P_CONTENT_CLASS    =>l_content_row.CONTENT_CLASS
        ,P_COL_LIST         =>l_temp_val
        ,P_LANGUAGE         =>userenv('LANG')
        ,P_SOURCE_LANGUAGE  =>userenv('LANG')
        ,P_USER_ID          =>1
        ,P_CONTENT_CODE     =>l_content_out);

 hr_utility.set_location('The content got created sucessfully ' || l_content_out, 55);

update bne_contents_b
   set param_list_code = l_content_row.param_list_code
      ,param_list_app_id =  l_content_row.param_list_app_id
 where content_code =l_content_out;

  OPEN c_content_cols_row(p_base_content_code);
    LOOP
         FETCH c_content_cols_row  INTO l_column, l_read_only_flag, l_sequence_num;
         EXIT WHEN c_content_cols_row%NOTFOUND;
    update bne_content_cols_b set read_only_flag = l_read_only_flag
     where content_code = l_content_out
      and sequence_num = l_sequence_num;

     END LOOP;
  CLOSE c_content_cols_row;

 hr_utility.set_location('The content got created sucessfully ' || l_content_out, 55);
 p_content_out := l_content_out;

END Create_RIW_Content_Row_Others;
--Added by sravikum
-------------------------------------------------------------------------
--Code to make the columns read only that the user wants to be read only
-------------------------------------------------------------------------
PROCEDURE Convert_Columns_Read_Only
            (p_content_code        IN  VARCHAR2
            ,p_interface_code      IN  VARCHAR2
            ,p_mapping_code        IN  VARCHAR2) IS

temp_content_seq_num           NUMBER(3) default null;
temp_content_ro_value          VARCHAR2(5);
temp_interface_seq_num         NUMBER(3);

BEGIN
    hr_utility.set_location('Entered the procedure Convert_Columns_Read_Only', 78);
    FOR l_interface_index IN g_temp_riw_data.FIRST..g_temp_riw_data.LAST
    LOOP
         temp_interface_seq_num := g_temp_riw_data(l_interface_index).interface_seq;
         temp_content_ro_value := g_temp_riw_data(l_interface_index).read_only;
				 temp_content_seq_num :=null;
     hr_utility.set_location('temp_interface_seq_num: '||temp_interface_seq_num, 5);
     hr_utility.set_location('temp_content_ro_value: '||temp_content_ro_value, 5);
     hr_utility.set_location('p_content_code: '||p_content_code, 5);
     hr_utility.set_location('p_interface_code: '||p_interface_code, 5);
     hr_utility.set_location('p_mapping_code: '||p_mapping_code, 5);
      begin
         select cont.sequence_num into temp_content_seq_num
         from bne_content_cols_b cont,
              bne_interface_cols_b intf,
              bne_mapping_lines map
         where
              map.interface_code = intf.interface_code
         and  cont.content_code = map.content_code
         and  intf.sequence_num = temp_interface_seq_num
         and  intf.interface_code = p_interface_code
         and  cont.content_code = p_content_code
         and  map.mapping_code = p_mapping_code
         and  map.interface_seq_num =intf.sequence_num
         and  map.content_seq_num = cont.sequence_num;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN NULL;
  			end;

         IF temp_content_seq_num is not null then
	         update bne_content_cols_b
		 set read_only_flag = temp_content_ro_value
	         where content_code = p_content_code
         and sequence_num = temp_content_seq_num;
         END IF;
    END LOOP;

END Convert_Columns_Read_Only;
-- =============================================================================
-- ~ Create_RIW_Webadi_Setup:
-- =============================================================================
PROCEDURE Create_RIW_Webadi_Setup
              (p_application_id       IN NUMBER
              ,p_data_source          IN VARCHAR2
              ,p_user_function_name   IN VARCHAR2
              ,p_menu_id              IN NUMBER
              ,p_seq_params           IN VARCHAR2
              ,p_intrfce_seq_params   IN VARCHAR2
              ,p_xml_tag_params       IN pqp_prompt_array_tab
              ,p_defalut_type_params  IN VARCHAR2
              ,p_defalut_value_params IN pqp_default_array_tab
              ,p_placement_params     IN VARCHAR2
              ,p_group_params         IN VARCHAR2
	      ,p_read_only_params     IN VARCHAR2
              ,p_action_type          IN VARCHAR2
              ,p_upd_layout_code      IN VARCHAR2
              ,p_upd_interface_code   IN VARCHAR2
              ,p_upd_mapping_code     IN VARCHAR2
              ,p_ins_upd_datapmp_flag IN VARCHAR2
              ,p_entity_name          IN VARCHAR2 DEFAULT NULL
              ,p_return_status        OUT NOCOPY VARCHAR2) IS

  l_seq_params           VARCHAR2(3000);
  l_intrfce_seq_params   VARCHAR2(3000);
  l_defalut_type_params  VARCHAR2(3000);
  l_placement_params     VARCHAR2(3000);
  l_group_params         VARCHAR2(3000);
  l_read_only_params     VARCHAR2(3000);
  l_seq_param_len        NUMBER(3);
  l_intr_param_len       NUMBER(3);
  l_typ_param_len        NUMBER(3);
  l_pla_param_len        NUMBER(3);
  l_grp_param_len        NUMBER(3);
  l_read_only_param_len  NUMBER(3);
  l_sq_location          NUMBER(3);
  l_inter_location       NUMBER(3);
  l_type_location        NUMBER(3);
  l_place_location       NUMBER(3);
  l_group_location       NUMBER(3);
  l_read_only_location   NUMBER(3);
  l_seq_value            VARCHAR2(1000);
  l_intr_value           VARCHAR2(1000);
  l_xml_value            VARCHAR2(200);
  l_type_value           VARCHAR2(2000);
  l_def_value            VARCHAR2(2000);
  l_pla_value            VARCHAR2(1000);
  l_grp_value            VARCHAR2(1000);
  l_read_only_value      VARCHAR2(1000);
  l_new_intrfc_code      VARCHAR2(30);
  l_new_layout_code      VARCHAR2(30);
  l_new_mapping_code     VARCHAR2(30);
  l_new_intg_code        VARCHAR2(30);
  l_user_name            VARCHAR2(30);
  l_function_name        VARCHAR2(30);
  l_func_parameters      VARCHAR2(1000);
  l_riw_seq_id           NUMBER;
  l_count                NUMBER :=1;
  l_ovn                  NUMBER;
  l_seq                  NUMBER;
  l_out_content_code     VARCHAR2(50);
  l_out_blnk_content_code    VARCHAR2(50);
  l_base_content_code    VARCHAR2(50);
  l_new_content_code     VARCHAR2(50);
  l_new_blnk_content_code   VARCHAR2(50);
  l_ins_upd_datapmp_flag   VARCHAR2(50);
  l_ins_upd_datapmp_flag_len NUMBER;
  l_derived_param_list_code  VARCHAR2(50);
  l_allow_insert     VARCHAR2(10);
  l_allow_update     VARCHAR2(10);
  l_allow_data_pump  VARCHAR2(10);
  l_allow_insert_loc NUMBER;
  l_allow_update_loc NUMBER;
  l_allow_data_pump_loc NUMBER;
  l_migration_flag_loc NUMBER(2);
  l_migration_flag   VARCHAR2(10);
  l_proc_name  constant  VARCHAR2(150) := g_proc_name ||'Create_RIW_Webadi_Setup';
  l_base_intg_code      VARCHAR2(50);
  l_base_intf_code      VARCHAR2(50);
  l_base_layout_code    VARCHAR2(50);
  l_base_blnk_content_code  VARCHAR2(50);
  l_entity_name         VARCHAR2(20);
  l_flag1               VARCHAR2(20);

 --Integration with RI Run Data Pump and Correct Errors Page
  l_setup_sub_task_action varchar2(520) :=
  'form_function=PER_RI_CREATE_DOCUMENT&APP_ID=800&bne:page=BneCreateDoc'||
  '&bne:reporting=N&bne:noreview=Y&';
  l_out_ce_content_code VARCHAR2(50);
  l_new_dp_mapping_code VARCHAR2(30);
  l_new_ce_layout_code  VARCHAR2(50);

  no_code_found         EXCEPTION;
  l_func_type           VARCHAR2(50);
  l_search              VARCHAR2(10);
  l_security_func_name  VARCHAR2(100);
BEGIN
     --Hr_Utility.trace_on(null,'RI_Trace');
     hr_utility.set_location('Entering: '||l_proc_name, 5);
     hr_utility.set_location('The flag is ' ||p_ins_upd_datapmp_flag, 6);
     hr_utility.set_location(p_seq_params || ' First', 10);
     hr_utility.set_location(p_intrfce_seq_params || ' Second', 15);
  --   hr_utility.set_location(p_xml_tag_params || ' Third', 10);
     hr_utility.set_location(p_defalut_type_params || ' Fourth', 10);
  --   hr_utility.set_location(p_defalut_value_params || ' Fifth', 10);
     hr_utility.set_location(p_placement_params || ' Sixth', 10);
     -- get next seq value : INTERFACE_SEQ
     hr_utility.set_location(p_entity_name, 15);

     BEGIN
       SELECT description into l_func_type
        FROM pqp_flxdu_columns WHERE
         entity_type = p_entity_name AND
         flxdu_column_name = 'PQP_TYPE_FLAG';
     EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
     END;

     IF l_func_type IS NOT NULL THEN
         l_search := SUBSTR(l_func_type, 11, 1);
     ELSE
         l_search := 'T';
     END IF;
     hr_utility.set_location('The search Value is  ' || l_search, 99);

     SELECT PQP_FLXDU_FUNCTIONS_S.nextval
     INTO   l_riw_seq_id
     FROM   dual;

     IF p_entity_name IS NOT NULL THEN
      BEGIN
         SELECT description INTO l_base_intg_code FROM PQP_FLXDU_COLUMNS WHERE
         FLXDU_COLUMN_NAME = 'INTEGRATOR_CODE' and
     	 ENTITY_TYPE = p_entity_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         raise no_code_found;
      END;

      BEGIN
         SELECT description INTO l_base_layout_code FROM PQP_FLXDU_COLUMNS WHERE
     	 FLXDU_COLUMN_NAME = 'LAYOUT_CODE' and
     	 ENTITY_TYPE = p_entity_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         raise no_code_found;
      END;

      IF l_search = 'T' THEN
        BEGIN
       	 SELECT description INTO l_base_content_code FROM PQP_FLXDU_COLUMNS WHERE
     	 FLXDU_COLUMN_NAME = 'CONTENT_CODE' and
    	 ENTITY_TYPE = p_entity_name;
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
         raise no_code_found;
        END;
      END IF;

      BEGIN
   	 SELECT description INTO l_base_blnk_content_code FROM PQP_FLXDU_COLUMNS WHERE
   	 FLXDU_COLUMN_NAME = 'BLANK_CONTENT_CODE' and
   	 ENTITY_TYPE = p_entity_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         raise no_code_found;
      END;

      BEGIN
    	 SELECT description INTO l_base_intf_code FROM PQP_FLXDU_COLUMNS WHERE
   	 FLXDU_COLUMN_NAME = 'INTERFACE_CODE' and
  	 ENTITY_TYPE = p_entity_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         raise no_code_found;
      END;
     END IF;

     l_new_intg_code       := 'PQP_RIW'||l_riw_seq_id||'_INTG';
     l_derived_param_list_code := l_new_intg_code || '_DP';
     l_new_intrfc_code     := 'PQP_RIW'||l_riw_seq_id||'_DATA_INTF';
     l_new_layout_code     := 'PQP_RIW'||l_riw_seq_id||'_DATA_LAYOUT';
     l_new_mapping_code    := 'PQP_RIW'||l_riw_seq_id||'_DATA_MAP_KEY';
     l_entity_name := p_entity_name;

     --$ Mapping for Data Pump Correct Errors
     l_new_dp_mapping_code    := 'PQP_RIW'||l_riw_seq_id||'_DP_MAP_KEY';

     l_new_content_code    := 'PQP_RIW'||l_riw_seq_id||'_CON';
     l_new_blnk_content_code    := 'PQP_RIW_BLNK'||l_riw_seq_id||'_CON';
     l_function_name       := 'PQP_RIW'||l_riw_seq_id||'_SEED_FUNC';
     l_func_parameters     := 'pIntegrator='||l_new_intg_code||'$pLayout=';
     l_func_parameters     := l_func_parameters||l_new_layout_code||'$pInterface=';
     l_func_parameters     := l_func_parameters||l_new_intrfc_code||'$pMapping=';
     l_func_parameters     := l_func_parameters||l_new_mapping_code||'$pDatasource='||p_data_source;
     l_user_name           := l_new_mapping_code;
     l_seq_params          := p_seq_params;
     l_intrfce_seq_params  := p_intrfce_seq_params;
     l_defalut_type_params := p_defalut_type_params;
     l_placement_params    := p_placement_params;
     l_group_params        := p_group_params;
     l_read_only_params    := p_read_only_params;
     l_ins_upd_datapmp_flag := p_ins_upd_datapmp_flag;
     l_seq_param_len       := LENGTH(l_seq_params);
     l_intr_param_len      := LENGTH(l_intrfce_seq_params);
     l_typ_param_len       := LENGTH(l_defalut_type_params);
     l_pla_param_len       := LENGTH(l_placement_params);
     l_grp_param_len       := LENGTH(l_group_params);
     l_read_only_param_len := LENGTH(l_read_only_params);
     l_ins_upd_datapmp_flag_len := LENGTH(l_ins_upd_datapmp_flag);
     l_flag1 := l_ins_upd_datapmp_flag;
     l_allow_insert_loc := INSTR(l_ins_upd_datapmp_flag, ':');
     l_allow_insert := SUBSTR(l_ins_upd_datapmp_flag, 1, l_allow_insert_loc-1);
     l_flag1 := SUBSTR(l_ins_upd_datapmp_flag, l_allow_insert_loc+1, LENGTH(l_ins_upd_datapmp_flag));
     hr_utility.set_location('Allow First Is '|| l_ins_upd_datapmp_flag, 5);
     l_migration_flag_loc := INSTR(l_flag1, ':');
     hr_utility.set_location('Allow Second Is '|| l_migration_flag_loc, 6);
     l_migration_flag :=  SUBSTR(l_flag1, 3);
     g_migration_flag :=  l_migration_flag;
     hr_utility.set_location('Allow Third Is '|| l_migration_flag, 6);
     hr_utility.set_location('Allow Insert Is '|| l_allow_insert, 7);
     hr_utility.set_location('Allow Migration Is '|| l_migration_flag, 8);
     IF l_allow_insert = 'Create' THEN
          g_ins_upd_flag := 'C';
          IF p_entity_name is NULL THEN
              g_ins_upd_flag := g_ins_upd_flag||':'||l_migration_flag;
          ELSE
             IF p_entity_name = 'CLASS' OR p_entity_name = 'COURSE'
                 OR p_entity_name = 'OFFERING'
                  OR p_entity_name = 'ENROLLMENT' THEN
                g_ins_upd_flag := g_ins_upd_flag||':'||l_new_intrfc_code;
             END IF;
          END IF;
     END IF;
     IF l_allow_insert = 'Update' THEN
          g_ins_upd_flag := 'U';
          IF p_entity_name is NULL THEN
              g_ins_upd_flag := g_ins_upd_flag||':'||l_migration_flag;
          ELSE
             IF p_entity_name = 'CLASS' OR p_entity_name = 'COURSE'
                 OR p_entity_name = 'OFFERING'
                  OR p_entity_name = 'ENROLLMENT' THEN
                g_ins_upd_flag := g_ins_upd_flag||':'||l_new_intrfc_code;
             END IF;
          END IF;
     END IF;
     IF l_allow_insert = 'Download' THEN
	  g_ins_upd_flag := 'D';
          IF p_entity_name is NULL THEN
              g_ins_upd_flag := g_ins_upd_flag||':'||l_migration_flag;
          ELSE
             IF p_entity_name = 'CLASS' OR p_entity_name = 'COURSE'
                 OR p_entity_name = 'OFFERING'
                  OR p_entity_name = 'ENROLLMENT' THEN
                g_ins_upd_flag := g_ins_upd_flag||':'||l_new_intrfc_code;
             END IF;
          END IF;
     END IF;
     hr_utility.set_location('Allow Insert Is '|| g_ins_upd_flag, 7);

     hr_utility.set_location('Before PL/SQL Records', 5);
     LOOP
         l_sq_location    := INSTR(l_seq_params, '+');
         l_inter_location := INSTR(l_intrfce_seq_params, '+');
         l_type_location  := INSTR(l_defalut_type_params, '+');
         l_place_location := INSTR(l_placement_params, '+');
         l_group_location := INSTR(l_group_params, '+');
	 l_read_only_location := INSTR(l_read_only_params, '+');

         -- Sequence number
         l_seq_value := SUBSTR(l_seq_params, 1, l_sq_location - 1);
         IF l_sq_location = 0  THEN
            l_seq_value := l_seq_params;
         END IF;
         l_seq_params     := SUBSTR(l_seq_params, l_sq_location + 1, l_seq_param_len);

         -- Interface Number
         l_intr_value := SUBSTR(l_intrfce_seq_params, 1, l_inter_location - 1);
         IF l_inter_location = 0  THEN
            l_intr_value := l_intrfce_seq_params;
         END IF;
         l_intrfce_seq_params     := SUBSTR(l_intrfce_seq_params, l_inter_location + 1, l_intr_param_len);

         -- Xml tags
         IF p_xml_tag_params(l_count) <> '+' THEN
            l_xml_value := p_xml_tag_params(l_count);
         ELSE
            l_xml_value := null;
         END IF;

         --Default types
         l_type_value := SUBSTR(l_defalut_type_params, 1, l_type_location - 1);
         IF l_type_location = 0  THEN
            l_type_value := l_defalut_type_params;
         END IF;
         l_defalut_type_params     := SUBSTR(l_defalut_type_params, l_type_location + 1, l_typ_param_len);

         --Default Values
         IF  p_defalut_value_params(l_count) <> '+' THEN
            l_def_value := p_defalut_value_params(l_count);
         ELSE
            l_def_value := null;
         END IF;

         --Placements
         l_pla_value := SUBSTR(l_placement_params, 1, l_place_location - 1);
         IF l_place_location = 0  THEN
            l_pla_value := l_placement_params;
         END IF;
         l_placement_params     := SUBSTR(l_placement_params, l_place_location + 1, l_pla_param_len);

         --Group Name
         l_grp_value := SUBSTR(l_group_params, 1, l_group_location - 1);
         IF l_group_location = 0  THEN
            l_grp_value := l_group_params;
         END IF;
         l_group_params     := SUBSTR(l_group_params, l_group_location + 1, l_grp_param_len);
	 l_read_only_value := SUBSTR(l_read_only_params, 1, l_read_only_location -1);
         IF l_read_only_location = 0 THEN
            l_read_only_value := l_read_only_params;
         END IF;
         l_read_only_params := SUBSTR(l_read_only_params, l_read_only_location + 1, l_read_only_param_len);

         g_riw_data(TO_NUMBER(l_intr_value)).sequence       := TO_NUMBER(l_seq_value);
         g_riw_data(TO_NUMBER(l_intr_value)).interface_seq  := TO_NUMBER(l_intr_value);
         g_riw_data(TO_NUMBER(l_intr_value)).xml_tag        := l_xml_value;
         g_riw_data(TO_NUMBER(l_intr_value)).default_type   := l_type_value;
         g_riw_data(TO_NUMBER(l_intr_value)).default_value  := l_def_value;
         g_riw_data(TO_NUMBER(l_intr_value)).placement      := l_pla_value;
         g_riw_data(TO_NUMBER(l_intr_value)).group_name     := l_grp_value;
	 g_riw_data(TO_NUMBER(l_intr_value)).read_only      := l_read_only_value;

         --Index by  Sequence
         g_temp_riw_data(l_count).sequence       := TO_NUMBER(l_seq_value);
         g_temp_riw_data(l_count).interface_seq  := TO_NUMBER(l_intr_value);
         g_temp_riw_data(l_count).xml_tag        := l_xml_value;
         g_temp_riw_data(l_count).default_type   := l_type_value;
         g_temp_riw_data(l_count).default_value  := l_def_value;
         g_temp_riw_data(l_count).placement      := l_pla_value;
         g_temp_riw_data(l_count).group_name     := l_grp_value;
	 g_temp_riw_data(l_count).read_only      := l_read_only_value;

         l_count :=l_count+1;

         EXIT WHEN l_sq_location = 0;
      END LOOP;

    hr_utility.set_location('Before Calling functions', 5);
    IF p_action_type ='Update' THEN
    hr_utility.trace('Inside Update:');
      Delete_riw_integrator
                 (p_LAYOUT_CODE         => p_upd_layout_code
                 ,p_MAPPING_CODE        => p_upd_mapping_code
                 ,p_INTERFACE_CODE      => p_upd_interface_code
                 ,p_application_id      => p_application_id ) ;
    END IF;

      --Create Integrator related stuff
      IF p_entity_name IS NULL then
         l_base_intg_code := 'PQP_FLEXIBLE_WEBADI_INTG';
      END IF;
      Create_RIW_Integrator_Row
                 (p_application_id      =>p_application_id
                 ,p_new_intg_code       =>l_new_intg_code
                 ,p_base_intg_code      =>l_base_intg_code
                 ,p_integrator_name     =>p_user_function_name);

      --Create Interface related stuff
      IF p_entity_name IS NULL then
           l_base_intf_code := 'PQP_FLEXIBLE_WEBADI_INTF';
      END IF;
      Create_RIW_Interface_Row
                 (p_application_id      => p_application_id
                 ,p_new_interface_code  => l_new_intrfc_code
                 ,p_base_interface_code => l_base_intf_code
                 ,p_user_name           => p_user_function_name
                 ,p_new_intg_code       => l_new_intg_code);

      --Create Interface related stuff
      Create_RIW_Interface_Col_Rows
                 (p_application_id      => p_application_id
                 ,p_new_interface_code  => l_new_intrfc_code
                 ,p_base_interface_code => l_base_intf_code
                 ,p_entity_name => l_entity_name);


     --Create Context related
     IF l_search = 'T' THEN
     IF p_entity_name IS NULL then
         IF p_data_source = 'HR' THEN
            l_base_content_code :='PQP_FLEXI_WEBADI_HR_CNT';
         ELSIF p_data_source = 'XML' THEN
            l_base_content_code :='PQP_FLEXI_WEBADI_XML_CNT';
         ELSIF p_data_source = 'CSV' THEN
            l_base_content_code :='PQP_FLEXI_WEBADI_CSV_CNT';
         END IF;
         Create_RIW_Content_Row
                 (p_application_id       =>p_application_id
                 ,p_new_content_code     =>l_new_content_code
                 ,p_base_content_code    =>l_base_content_code
                 ,p_intg_code            =>l_new_intg_code
                 ,p_content_name         =>p_user_function_name
                 ,p_content_out          =>l_out_content_code
                 --$ Data Pump Correct Errors Content
                 ,p_ce_content_out          =>l_out_ce_content_code);
     ELSE
         Create_RIW_Content_Row_Others
                 (p_application_id       =>p_application_id
                 ,p_new_content_code     =>l_new_content_code
                 ,p_base_content_code    =>l_base_content_code
                 ,p_intg_code            =>l_new_intg_code
                 ,p_content_name         =>p_user_function_name
                 ,p_entity_name          =>l_entity_name
                 ,p_content_out          =>l_out_content_code);
         hr_utility.set_location('Outside the call  ' || l_out_content_code, 76);
     END IF;
     END IF;



     l_func_parameters     := l_func_parameters||'$pContent='||l_out_content_code;

     IF p_data_source = 'HR' THEN
         Create_RIW_BLNK_Content_row(p_application_id           =>p_application_id
                                    ,p_new_blnk_content_code    =>l_new_blnk_content_code
                                    ,p_intg_code                =>l_new_intg_code
                                    ,p_content_name             =>p_user_function_name||' BLNK'
                                    ,p_blnk_content_out         =>l_out_blnk_content_code);

         l_func_parameters := l_func_parameters||'$pBlnkContent='||l_out_blnk_content_code;
     ELSE
         l_func_parameters := l_func_parameters||'$pBlnkContent='||'null';
     END IF;


     --Create Layout Stuff
     IF p_entity_name IS NULL THEN
         l_base_layout_code := 'PQP_FLEXIBLE_WEBADI_LAYOUT';
     END IF;

     Create_RIW_Layout_Row
                 (p_application_id       => p_application_id
                 ,p_new_layout_code      => l_new_layout_code
                 ,p_base_layout_code     => l_base_layout_code
                 ,p_user_name            => p_user_function_name
                 ,p_new_intg_code        => l_new_intg_code);

     Create_RIW_Layout_Blocks_Row
                 (p_application_id       => p_application_id
                 ,p_new_layout_code      => l_new_layout_code
                 ,p_base_layout_code     => l_base_layout_code
                 ,p_user_name            => p_user_function_name);
     hr_utility.set_location('Executed block API', 50);
     Create_RIW_Layout_Cols_Row
                 (p_application_id       => p_application_id
                 ,p_new_layout_code      => l_new_layout_code
                 ,p_base_layout_code     => l_base_layout_code
                 ,p_new_interface_code   => l_new_intrfc_code
                 --$ Pass Data Source as well to make changes in layout accordingly
                 ,p_data_source          => p_data_source
                 ,p_entity_name          => l_entity_name);

     --$ Create Correct Errors Layout (Only for Person/Assignment/Address)
     IF p_entity_name IS NULL THEN
         l_new_ce_layout_code     := 'PQP_RIW'||l_riw_seq_id||'_CE_LAYOUT';

         Create_RIW_Layout_Row
                 (p_application_id       => p_application_id
                 ,p_new_layout_code      => l_new_ce_layout_code
                 ,p_base_layout_code     => 'PQP_FLEXIBLE_WEBADI_CE_LAYOUT'
                 ,p_user_name            => p_user_function_name||' CE'
                 ,p_new_intg_code        => l_new_intg_code);

         Create_RIW_Layout_Blocks_Row
                 (p_application_id       => p_application_id
                 ,p_new_layout_code      => l_new_ce_layout_code
                 ,p_base_layout_code     => 'PQP_FLEXIBLE_WEBADI_CE_LAYOUT'
                 ,p_user_name            => p_user_function_name||' CE');

         Create_RIW_Layout_Cols_Row
                 (p_application_id       => p_application_id
                 ,p_new_layout_code      => l_new_ce_layout_code
                 ,p_base_layout_code     => 'PQP_FLEXIBLE_WEBADI_CE_LAYOUT'
                 ,p_new_interface_code   => l_new_intrfc_code
                 --$
                 ,p_data_source          => p_data_source);
     END IF;
     --
     --Create Mappings Stuff
     IF l_search = 'T' THEN
     Create_RIW_mappings_row
                 (p_application_id       => p_application_id
                 ,p_new_mapping_code     => l_new_mapping_code
                 ,p_user_name            => p_user_function_name
                 ,p_data_source          => p_data_source
                 ,p_new_intg_code        => l_new_intg_code
                 ,p_entity_name          => l_entity_name);

     hr_utility.set_location(l_out_content_code, 56);
     Create_RIW_Mapping_Links_Rows
                 (p_application_id       => p_application_id
                 ,p_new_mapping_code     => l_new_mapping_code
                 ,p_new_interface_code   => l_new_intrfc_code
                 ,p_data_source          => p_data_source
                 ,p_content_out          => l_out_content_code
                 ,p_entity_name          => l_entity_name);

      IF p_entity_name IS NULL THEN
               --$ For Data Pump Correct Errors , Create another Mapping
      Create_RIW_mappings_row
                 (p_application_id       => p_application_id
                 ,p_new_mapping_code     => l_new_dp_mapping_code
                 ,p_user_name            => p_user_function_name||' CE MAP'
                 ,p_data_source          => 'DP'
                 ,p_new_intg_code        =>l_new_intg_code);

      Create_RIW_Mapping_Links_Rows
                 (p_application_id       => p_application_id
                 ,p_new_mapping_code     => l_new_dp_mapping_code
                 ,p_new_interface_code   => l_new_intrfc_code
                 ,p_data_source          => 'DP'
                 ,p_content_out          => l_out_ce_content_code);
              --
      END IF;
      END IF;


--  For P_OUT_CONTENT
 Convert_Columns_Read_Only
                 (p_content_code     => l_out_content_code
                 ,p_interface_code   => l_new_intrfc_code
                 ,p_mapping_code     => l_new_mapping_code);
 -- For CE Content
  Convert_Columns_Read_Only
                 (p_content_code     => l_out_ce_content_code
                 ,p_interface_code   => l_new_intrfc_code
                 ,p_mapping_code     => l_new_dp_mapping_code);

if (l_base_content_code = 'PQP_FLEXI_WEBADI_XML_CNT' OR
    l_base_content_code = 'PQP_FLEXI_WEBADI_CSV_CNT' OR
    l_base_content_code = 'PQP_FLEXI_WEBADI_HR_CNT') then
    update bne_content_cols_b set read_only_flag  = 'Y' where content_code =
   l_out_content_code and sequence_num in (2,316,317,318);
end if;

IF p_entity_name IS NULL THEN
  update bne_content_cols_b set read_only_flag = 'Y' where content_code in
 (l_out_ce_content_code) and sequence_num in (2,317,318,270);
end if;


     Create_RIW_OAF_Function
                 (p_application_id       =>p_application_id
                 ,p_function_name        =>l_function_name
                 ,p_base_function_name   =>'PQPRIWSEEDFUNC'
                 ,p_action_type          => p_action_type
                 ,p_data_source          => p_data_source
                 ,p_func_parameters      => l_func_parameters
                 ,p_user_function_name   => p_user_function_name
                 ,p_new_interface_code   => l_new_intrfc_code
		 ,p_new_layout_code      => l_new_layout_code);

   SELECT fff.function_name into l_security_func_name
   FROM   fnd_form_functions fff, fnd_form_functions_tl ffft
   WHERE  fff.FUNCTION_ID = ffft.FUNCTION_ID
   AND    ffft.SOURCE_LANG = userenv('LANG')
   AND    ffft.LANGUAGE = userenv('LANG')
   AND    ffft.USER_FUNCTION_NAME = p_user_function_name;

    update bne_security_rules set security_value = l_security_func_name
     where security_code = l_new_intg_code;

--Integration with RI data pump mechanism
-- After second '#' correct errors content,layout and mapping code have to be inserted

l_setup_sub_task_action := l_setup_sub_task_action || 'bne:integrator='||l_new_intg_code
 ||'#bne:layout='||l_new_layout_code||'&bne:content='||l_out_content_code
 ||'&bne:map='||l_new_mapping_code
 ||'#bne:layout='||l_new_ce_layout_code||'&bne:content='||l_out_ce_content_code
 ||'&bne:map='||l_new_dp_mapping_code;

   --$In case of update, update setup_sub_task_action in per_ri_setup_sub_tasks

   IF p_action_type = 'Update' THEN

   SELECT fff.function_name into l_function_name
   FROM   fnd_form_functions fff, fnd_form_functions_tl ffft
   WHERE  fff.FUNCTION_ID = ffft.FUNCTION_ID
   AND    ffft.SOURCE_LANG = userenv('LANG')
   AND    ffft.LANGUAGE = userenv('LANG')
   AND    ffft.USER_FUNCTION_NAME = p_user_function_name;

   SELECT object_version_number
   into   l_ovn
   FROM   per_ri_setup_sub_tasks
   WHERE  setup_sub_task_code = l_function_name;

   per_ri_setup_sub_task_api.update_setup_sub_task(
    p_validate => false
   ,p_setup_sub_task_code      => l_function_name
   ,p_setup_sub_task_action => l_setup_sub_task_action
   ,p_effective_date => sysdate
   ,p_object_version_number    => l_ovn
   );

   END IF;

    IF p_action_type <> 'Update' THEN
       Create_RIW_Menu_Entries
                  (p_application_id      =>p_application_id
                  ,p_menu_id             =>p_menu_id
                  ,p_function_name       =>l_function_name
                  ,p_user_function_name  =>p_user_function_name);

       SELECT max(SETUP_SUB_TASK_SEQUENCE)
       INTO   l_seq
       FROM   per_ri_setup_sub_tasks
       WHERE  SETUP_TASK_CODE='LOAD_EMPLOYEE_DETAILS';


       per_ri_setup_sub_task_api.create_setup_sub_task
                  (p_validate                     => false
                  ,p_setup_sub_task_code          => l_function_name
                  ,p_setup_sub_task_name          => p_user_function_name
                  ,p_setup_sub_task_description   => p_user_function_name
                  ,p_setup_task_code              => p_user_function_name --'LOAD_EMPLOYEE_DETAILS'
                  ,p_setup_sub_task_sequence      => l_seq+1
                  ,p_setup_sub_task_status        => 'NOT_STARTED'
                  ,p_setup_sub_task_type          => NULL
                  ,p_setup_sub_task_dp_link       => 'SPREADSHEET_LOADER' --NULL
                  ,p_setup_sub_task_action        => l_setup_sub_task_action --l_function_name
                  ,p_setup_sub_task_creation_date => sysdate
                  ,p_setup_sub_task_last_mod_date => sysdate
                  ,p_legislation_code             => NULL
                  ,p_language_code                => 'US'
                  ,p_effective_date               => sysdate
                  ,p_object_version_number        => l_ovn );

    END IF;
   g_temp_riw_data.DELETE;
   g_riw_data.DELETE;
   p_return_status := 'Y';
   hr_utility.set_location('Leaving: '||l_proc_name, 5);

   Create_Derived_Param_List(p_application_id => p_application_id
                               ,p_param_list_code => l_derived_param_list_code
                               ,p_parameter_value => l_ins_upd_datapmp_flag);
Exception
when others then
     hr_utility.set_location('Error: '||l_proc_name, 5);
     g_temp_riw_data.DELETE;
     g_riw_data.DELETE;
     hr_utility.set_location('sqlerrm:'||substr(sqlerrm,1,50), 100);
     hr_utility.set_location('sqlerrm:'||substr(sqlerrm,51,100), 101);
     hr_utility.set_location('sqlerrm:'||substr(sqlerrm,101,150), 102);
     p_return_status := 'E';
END Create_RIW_Webadi_Setup;



-- =============================================================================
-- ~ Delete_RIW_Webadi_Setup:
-- =============================================================================
PROCEDURE Delete_RIW_Webadi_Setup
              (p_function_id          IN NUMBER
              ,p_menu_id              IN NUMBER) IS

   CURSOR csr_get_fun_name IS
   SELECT setup_sub_task_code
         ,object_version_number
   FROM   per_ri_setup_sub_tasks
   WHERE  setup_sub_task_code --$ setup_sub_task_action
   = (SELECT  FLXDU_FUNC_NAME
                                     FROM  PQP_FLXDU_FUNC_ATTRIBUTES
                                     WHERE FLXDU_FUNC_ATTRIBUTE_ID = p_function_id );

   --$ To fetch Interface Code from function id
   CURSOR csr_get_interface_code IS
   select flxdu_func_integrator_code from
    PQP_FLXDU_FUNC_ATTRIBUTES where FLXDU_FUNC_ATTRIBUTE_ID = p_function_id;

l_ENTRY_SEQUENCE        NUMBER;
l_menu_id               NUMBER;
l_count                 NUMBER;
l_setup_sub_task_code   VARCHAR2(60);
l_ovn                   NUMBER;
l_proc_name             VARCHAR2(72) := g_package||'Delete_RIW_Webadi_Setup';

 --$
 l_intf_code VARCHAR2(30);

BEGIN
 -- hr_utility.trace_on(null,'TTT');
-- get the count of function_id from fnd_menu_entries
SELECT count(function_id)
INTO   l_count
FROM   fnd_menu_entries
WHERE  function_id = p_function_id;


   --$ Call Delete_riw_integrator to delete entire integrator setup
   OPEN csr_get_interface_code;
   FETCH csr_get_interface_code into l_intf_code;
   CLOSE csr_get_interface_code;

IF l_count = 1 THEN

   -- get menu id and  entry seq from fnd_menu_entries
   SELECT ENTRY_SEQUENCE
         ,MENU_ID
   INTO   l_ENTRY_SEQUENCE
         ,l_menu_id
   FROM   fnd_menu_entries
   WHERE  function_id = p_function_id;

   -- delete row for menu id , entry seq
   FND_MENU_ENTRIES_PKG.DELETE_ROW(
       X_MENU_ID         => l_menu_id
      ,X_ENTRY_SEQUENCE  => l_ENTRY_SEQUENCE);

   OPEN csr_get_fun_name;
   FETCH csr_get_fun_name INTO l_setup_sub_task_code ,l_ovn;
   CLOSE csr_get_fun_name;

   IF l_setup_sub_task_code IS NOT NULL THEN
    per_ri_setup_sub_task_api.delete_setup_sub_task
     (p_validate                 => false
     ,p_setup_sub_task_code      => l_setup_sub_task_code
     ,p_object_version_number    => l_ovn);
   END IF;

   DELETE
   FROM   PQP_FLXDU_FUNC_ATTRIBUTES
   WHERE  FLXDU_FUNC_ATTRIBUTE_ID = p_function_id;

   FND_FORM_FUNCTIONS_PKG.DELETE_ROW(
         X_FUNCTION_ID => p_function_id);


hr_utility.trace('DELETE: INTERFACE='|| l_intf_code);

   if l_intf_code IS NOT NULL then
   Delete_riw_integrator(p_INTERFACE_CODE => l_intf_code
                          ,p_application_id  => 8303 );
   end if;

/*ELSE

   SELECT ENTRY_SEQUENCE INTO l_ENTRY_SEQUENCE
   FROM   fnd_menu_entries
   WHERE  MENU_ID = l_menu_id
   AND    function_id = p_function_id;

    FND_MENU_ENTRIES_PKG.DELETE_ROW(
        X_MENU_ID	      => p_menu_id
       ,X_ENTRY_SEQUENCE  => l_ENTRY_SEQUENCE);
*/
END IF;

END Delete_RIW_Webadi_Setup;




-- =============================================================================
-- ~ Create_RIW_XML_Tags: to create / update user defined XML Tags
-- =============================================================================
PROCEDURE Create_RIW_XML_Tags
            (p_field_id           IN NUMBER
            ,p_xml_tag_id         IN NUMBER
            ,p_xml_tag_name       IN VARCHAR2
            ,p_business_group_id  IN VARCHAR2 ) IS


l_riw_xml_id     NUMBER := 0;
l_count          NUMBER;
l_proc           VARCHAR2(72) := g_package||'Create_RIW_XML_Tags';

BEGIN

  -- get next sequence value
  SELECT PQP_FLXDU_XML_TAGS_S.nextval
  INTO   l_riw_xml_id
  FROM   dual;

  -- get the count of FLXDU_XML_TAG_ID in PQP_FLXDU_XML_TAGS
  SELECT count(FLXDU_XML_TAG_ID)
  INTO   l_count
  FROM   PQP_FLXDU_XML_TAGS
  WHERE  BUSINESS_GROUP_ID   = p_business_group_id
  AND    FLXDU_COLUMN_ID     = p_field_id;

 -- if count = 0 , then insert into PQP_FLXDU_XML_TAGS
 IF l_count = 0 THEN
  IF p_xml_tag_name IS NOT NULL THEN
  insert into PQP_FLXDU_XML_TAGS
        (FLXDU_COLUMN_ID
        ,FLXDU_XML_TAG_ID
        ,FLXDU_XML_TAG_NAME
        ,BUSINESS_GROUP_ID
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        ,OBJECT_VERSION_NUMBER)
      values
        (p_field_id
        ,l_riw_xml_id
        ,p_xml_tag_name
        ,p_business_group_id
        ,1
        ,sysdate
        ,1
        ,sysdate
        ,1
        ,1);
    END IF;
 -- if count > 0 then
 ELSE
   -- update PQP_FLXDU_XML_TAGS if p_xml_tag_name is not null
   IF p_xml_tag_name IS NOT NULL THEN
     UPDATE PQP_FLXDU_XML_TAGS
     SET    FLXDU_XML_TAG_NAME = p_xml_tag_name
     WHERE  FLXDU_XML_TAG_ID = p_xml_tag_id;
   -- delete frm PQP_FLXDU_XML_TAGS if p_xml_tag_name is null
   ELSE
     DELETE
     FROM   PQP_FLXDU_XML_TAGS
     WHERE  FLXDU_XML_TAG_ID = p_xml_tag_id;
   END IF;
 END IF;
END Create_RIW_XML_Tags;




-- =============================================================================
-- ~ Delete_RIW_XML_Tag:
-- =============================================================================
PROCEDURE Delete_RIW_XML_Tag
              (p_xml_tag_id          IN NUMBER
              ,p_business_group_id   IN NUMBER) IS

l_count        NUMBER;
l_proc         VARCHAR(72) := g_package||'Delete_RIW_XML_Tag';

BEGIN

    -- delete mxl tag from PQP_FLXDU_XML_TAGS for tagId and bgId passed
    DELETE
    FROM   PQP_FLXDU_XML_TAGS
    WHERE  FLXDU_XML_TAG_ID  = p_xml_tag_id
    AND    BUSINESS_GROUP_ID = p_business_group_id;


END Delete_RIW_XML_Tag;

-- =============================================================================
-- ~ Get Concatenated Exception for the linked batch lines:
-- =============================================================================
FUNCTION Get_concatenated_exception(p_batch_id in number,p_batch_link in number)
return varchar2
is
concatstr varchar2(1000) := '';
cursor csr_exp is
  select exception_text from hr_pump_batch_exceptions where source_id  in (select
   batch_line_id from hr_pump_batch_lines where batch_id = p_batch_id and
   link_value = p_batch_link);
begin
 for rec_exp in csr_exp loop
     concatstr := concatstr||rec_exp.exception_text||' ';
end loop;
return concatstr;
end;
-- =============================================================================
-- ~ Get Descriptive Flexfield concatanated data:
-- =============================================================================
FUNCTION Get_Concatanated_DFF_Segments
              (p_dff_name       IN VARCHAR2
              ,p_app_id         IN NUMBER
	      ,p_context        IN VARCHAR2
              ,p_effective_date IN DATE
	      ,p_entity         IN VARCHAR2
	      ,p_entity_id      IN NUMBER
              ,p_table_name     IN VARCHAR2 default null
              ,p_column         IN VARCHAR2 default null)
RETURN Varchar2 IS

  -- Cursor to get Delimiter and the Context for a given DFF
  CURSOR csr_get_delimiter_and_context (c_dff_name IN VARCHAR2
                                       ,c_app_id   IN NUMBER) IS
  SELECT concatenated_segment_delimiter, context_column_name
    FROM fnd_descriptive_flexs
   WHERE descriptive_flexfield_name = (SELECT descriptive_flexfield_name
                                            FROM fnd_descriptive_flexs_tl
                                           WHERE title = c_dff_name
					     AND language = 'US')
     AND application_id = c_app_id;

  -- Cursor to get the global segments and the context specific segments for the DFF
  CURSOR csr_get_dff_segments (c_dff_name IN VARCHAR2
			      ,c_context  IN VARCHAR2) IS
  SELECT fd.application_column_name
    FROM fnd_descr_flex_column_usages fd,
         fnd_descr_flex_col_usage_tl fdtl
   WHERE fd.descriptive_flexfield_name = fdtl.descriptive_flexfield_name
     AND fd.descriptive_flex_context_code=fdtl.descriptive_flex_context_code
     AND fd.descriptive_flexfield_name = (SELECT descriptive_flexfield_name
                                            FROM fnd_descriptive_flexs_tl
                                           WHERE title = c_dff_name
					     AND language = 'US')
     AND fd.descriptive_flex_context_code in (c_context)
     AND fd.application_column_name = fdtl.application_column_name
     AND fdtl.language = userenv('LANG')
     AND fd.ENABLED_FLAG = 'Y'             --Changed by pkagrawa
--     AND fd.DISPLAY_FLAG = 'Y'             --Changed by pkagrawa
ORDER BY fd.column_seq_num;

CURSOR csr_get_dff_segment_count (c_dff_name IN VARCHAR2
			      ,c_context  IN VARCHAR2) IS
  SELECT count(*)
    FROM fnd_descr_flex_column_usages fd,
         fnd_descr_flex_col_usage_tl fdtl
   WHERE fd.descriptive_flexfield_name = fdtl.descriptive_flexfield_name
     AND fd.descriptive_flex_context_code=fdtl.descriptive_flex_context_code
     AND fd.descriptive_flexfield_name = (SELECT descriptive_flexfield_name
                                            FROM fnd_descriptive_flexs_tl
                                           WHERE title = c_dff_name
					     AND language = 'US')
     AND fd.descriptive_flex_context_code in (c_context)
     AND fd.application_column_name = fdtl.application_column_name
     AND fdtl.language = userenv('LANG')
     AND fd.ENABLED_FLAG = 'Y'
     AND fd.DISPLAY_FLAG = 'Y';

  r_delim_ctx_rec           r_delim_contxt;
  r_segment_list_rec        r_segment_list;
  l_func_name   CONSTANT    VARCHAR2(150) := g_package || 'Get_Concatanated_DFF_Segments';
 -- l_segment_list            VARCHAR2(1000);
  l_concat_segments         VARCHAR2(300);
   l_concat_values          varchar2(600);
  l_concat_segment_ids      varchar2(600);

  l_delimiter               fnd_descriptive_flexs.concatenated_segment_delimiter%TYPE;
  l_dff_ctx_val             fnd_descr_flex_column_usages.descriptive_flex_context_code%TYPE;

  l_dyn_sql_qry             Varchar(4000);
  l_dyn_context_qry       varchar2(4000);
  l_effective_date          DATE;

  cc_valid          Boolean;
  message   varchar2(1000);
  app_name       varchar2(10);

  -- Dynamic Ref Cursor
  TYPE ref_cur_typ IS REF CURSOR;
  csr_get_cnct_segs         ref_cur_typ;
  csr_get_ctx               ref_cur_typ;

  l_segment_count           NUMBER       :=0;
  l_string_length           NUMBER       :=0;

  --$1
  -- Escape delimiter and '\' in each segment's value
   replace_prefix varchar2(50) := 'replace(replace(';
   replace_suffix1  varchar2(50) := ',''\'',''\\''),''';
  -- ||l_delimiter||
   replace_suffix2  varchar2(50) := ''',''\';
  -- ||l_delimiter||
   replace_suffix3 varchar2(10) := ''')';
  -- replace_prefix|| csr_get_dff_segments_rec.application_column_name || replace_suffix1 || l_delimiter ||
  -- replace_suffix2 ||l_delimiter|| replace_suffix3
  -- increase size of segment list variable
  l_segment_list            VARCHAR2(3000);

  flexfield_name            varchar2(100);
  l_global_segment_count    number;
  l_user_override           varchar2(10);
  l_global_part             varchar2(1000);
  l_sensitive_part          varchar2(2000);
  l_context_value           varchar2(50);
  l_global_only_flag 				varchar2(10) :='N';

BEGIN

--  hr_utility.trace_on(null, 'Seg_Trace');
  -- Get the Delimiter and Context for the given DFF
  OPEN  csr_get_delimiter_and_context(c_dff_name => p_dff_name
                                     ,c_app_id   => p_app_id);

  FETCH csr_get_delimiter_and_context INTO r_delim_ctx_rec;

  -- If Delimiter is not found then that means the passed DFF doesn't exist for
  -- the passed application id. Raise an Error
  IF csr_get_delimiter_and_context%NOTFOUND THEN
     CLOSE csr_get_delimiter_and_context;
     Hr_Utility.raise_error;
  END IF;
  CLOSE csr_get_delimiter_and_context;

  l_delimiter := r_delim_ctx_rec.con_seg_delim;
  l_dff_ctx_val := r_delim_ctx_rec.con_col_name;

  --Initialize the segment list with the global segments
  l_segment_list := '''' || '''' || '''' || '''' || '||';
  FOR csr_get_dff_segments_rec IN csr_get_dff_segments(c_dff_name => p_dff_name
			                              ,c_context  => 'Global Data Elements')
  LOOP
      l_segment_count := l_segment_count +1;
--      l_segment_list := l_segment_list || csr_get_dff_segments_rec.application_column_name || '||''' || l_delimiter || '''||';
--$2
          l_segment_list := l_segment_list ||
      replace_prefix|| csr_get_dff_segments_rec.application_column_name || replace_suffix1 || l_delimiter ||
    replace_suffix2 ||l_delimiter|| replace_suffix3 || '||''' || l_delimiter || '''||';

  END LOOP;

  -- If there are no global segments defined, and the context is null, then return empty string
  -- as there is no data in the DFF
  IF (l_segment_count = 0) AND ((p_context = 'Global Data Elements') OR (p_context IS NULL) OR (p_context = ''))  THEN
--  IF (l_segment_count = 0) AND ((p_context IS NULL) OR (p_context = ''))  THEN
     RETURN '';
  END IF;



 --IF condition added by pkagrawa to check for non global data context
 IF p_context <> 'Global Data Elements' THEN

hr_utility.trace('Inside non global condition');

  --$3
  l_segment_count := l_segment_count +1; -- keeping no of delimiters and segments in sync

  --Append the context soon after the global segments
  l_segment_list := l_segment_list || l_dff_ctx_val;

  --Append the context specific segments
  FOR csr_get_dff_segments_rec IN csr_get_dff_segments(c_dff_name => p_dff_name
			                              ,c_context  => p_context)
  LOOP
      l_segment_count := l_segment_count +1;
 --     l_segment_list := l_segment_list || '||''' || l_delimiter || '''||' || csr_get_dff_segments_rec.application_column_name;
 --$4
   l_segment_list := l_segment_list || '||''' || l_delimiter || '''||' ||
      replace_prefix|| csr_get_dff_segments_rec.application_column_name || replace_suffix1 || l_delimiter ||
    replace_suffix2 ||l_delimiter|| replace_suffix3 ;

  END LOOP;
 ELSE
 -- remove the added delimiter for context value ( '||''' || l_delimiter || '''||' )
 -- i.e.  ( ||'.'|| )from the end
 --l_segment_list := SUBSTR(l_segment_list,1,LENGTH(l_segment_list)-7);
l_segment_list := l_segment_list || l_dff_ctx_val;
l_global_only_flag :='Y';
 END IF;
--  l_effective_date := fnd_date.canonical_to_date(p_effective_date);
  l_effective_date := p_effective_date;
  --hr_utility.set_location('The list is '||l_segment_list, 90);

  --insert into log_table values(l_segment_list);
  IF p_entity = 'PERSON' THEN
     l_dyn_sql_qry := ' SELECT ' || l_segment_list ||
                      '   FROM per_people_f ' ||
                      '  WHERE person_id = :p_entity_id' ||
		      '    AND :dt BETWEEN effective_start_date AND effective_end_date';

     l_dyn_context_qry := ' SELECT ' || l_dff_ctx_val ||
                      '   FROM per_people_f ' ||
                      '  WHERE person_id = :p_entity_id' ||
		      '    AND :dt BETWEEN effective_start_date AND effective_end_date';

  ELSIF p_entity = 'ASSIGNMENT' THEN
     l_dyn_sql_qry := ' SELECT ' || l_segment_list ||
                      '   FROM per_assignments_f ' ||
                      '  WHERE assignment_id = :p_entity_id' ||
		      '    AND :dt BETWEEN effective_start_date AND effective_end_date';

     l_dyn_context_qry := ' SELECT ' || l_dff_ctx_val ||
                      '   FROM per_assignments_f ' ||
                      '  WHERE assignment_id = :p_entity_id' ||
		      '    AND :dt BETWEEN effective_start_date AND effective_end_date';

  ELSIF p_entity = 'ENROLLMENT' THEN
     l_dyn_sql_qry := ' SELECT ' || l_segment_list ||
                      '   FROM ota_delegate_bookings ' ||
                      '  WHERE booking_id = :p_entity_id';

     l_dyn_context_qry := ' SELECT ' || l_dff_ctx_val ||
                      '   FROM ota_delegate_bookings ' ||
                      '  WHERE booking_id = :p_entity_id';
  ELSE
     l_dyn_sql_qry := ' SELECT ' || l_segment_list ||
                      '   FROM per_addresses ' ||
                      '  WHERE address_id = :p_entity_id';

     l_dyn_context_qry := ' SELECT ' || l_dff_ctx_val ||
                      '   FROM per_addresses ' ||
                      '  WHERE address_id = :p_entity_id';
  END IF;

  IF p_table_name is not null AND p_column is not null THEN
  hr_utility.trace('p_table_name '||p_table_name);
  hr_utility.trace('p_column '||p_column);
      l_dyn_sql_qry := ' SELECT ' || l_segment_list ||
                       ' FROM ' || p_table_name ||
                       ' where ' || p_column || ' = :p_entity_id';

      l_dyn_context_qry := ' SELECT ' || l_dff_ctx_val ||
                       ' FROM ' || p_table_name ||
                       ' where ' || p_column || ' = :p_entity_id';
   hr_utility.trace('Reaching here');
      --create_log(l_dyn_sql_qry);
  END IF;

  IF p_entity = 'PERSON' OR p_entity = 'ASSIGNMENT' THEN
     OPEN  csr_get_cnct_segs FOR  l_dyn_sql_qry USING p_entity_id, p_effective_date;
     OPEN  csr_get_ctx FOR  l_dyn_context_qry USING p_entity_id, p_effective_date;
  ELSE
     OPEN  csr_get_cnct_segs FOR  l_dyn_sql_qry USING p_entity_id;
     OPEN  csr_get_ctx FOR  l_dyn_context_qry USING p_entity_id;
  END IF;

  FETCH csr_get_cnct_segs INTO l_concat_segments;
  FETCH csr_get_ctx INTO l_context_value;

  --Check if all the segments are blank. If so, return empty string
  l_string_length := LENGTH(REPLACE(l_concat_segments,p_context,''));
 -- IF l_segment_count + 1 = l_string_length THEN

-- $5
 -- IF l_segment_count + 1 = l_string_length THEN
 -- All the segments would be null implies the concatenated string contains only delimiters
 -- As between every two segments (including context value. e.g. a.b.context.d) we have added one delimiter
 -- so after replacing context value with '' , l_segment_count (4 here) should be equal to (l_string_length(3 here) + 1)
 -- for a null DFF concatenated segments
  --insert into log_table values(l_segment_count);
  --insert into log_table values(l_string_length);
  IF l_segment_count = (l_string_length ) THEN
     RETURN '';
  END IF;

  begin
    select descriptive_flexfield_name into flexfield_name from fnd_descriptive_flexs_tl
      where title = p_dff_name;
    select application_short_name into app_name
      from fnd_application where application_id = p_app_id;

  exception
  when no_data_found then
     flexfield_name := null;
  end;


  l_concat_segment_ids := substr(l_concat_segments, 2);
  --insert into log_table values(l_concat_segments);
  hr_utility.set_location(l_concat_segments, 101);
hr_utility.trace('Before printing id ');
  hr_utility.set_location(l_concat_segment_ids, 105);
--  insert into log_table values (l_concat_segment_ids);
     CC_VALID := FND_FLEX_DESCVAL.VAL_DESC(
            APPL_SHORT_NAME=>'PER',
            DESC_FLEX_NAME=>flexfield_name,
            CONCAT_SEGMENTS=>l_concat_segment_ids,
            VALUES_OR_IDS=>'I');
  if(cc_valid = true) then
      l_concat_values := FND_FLEX_DESCVAL.CONCATENATED_VALUES;
       if l_global_only_flag = 'Y' then
					l_concat_values := ''''||l_concat_values;
					RETURN l_concat_values;
       end if;
      begin
         select CONTEXT_USER_OVERRIDE_FLAG into l_user_override
           from fnd_descriptive_flexs
              where DESCRIPTIVE_FLEXFIELD_NAME = flexfield_name;
      exception when no_data_found then
          l_user_override := 'N';
      end;
      OPEN  csr_get_dff_segment_count(c_dff_name => p_dff_name
                                     ,c_context  => 'Global Data Elements');

       FETCH csr_get_dff_segment_count INTO l_segment_count;
       CLOSE csr_get_dff_segment_count;
      if l_user_override <> 'Y' then

      if l_segment_count > 0 then
         l_global_part :=  substr(l_concat_values,1, instr(l_concat_values,l_delimiter,1,l_segment_count));
         l_sensitive_part :=  substr(l_concat_values,instr(l_concat_values,l_delimiter,1,l_segment_count));
         l_concat_values := '';
         l_concat_values := l_global_part || l_context_value || l_sensitive_part;
      else
         l_concat_values := l_context_value || l_delimiter || l_concat_values;
      end if;
      else
          l_global_part := '';
          if l_segment_count > 0 then
             l_global_part :=  substr(l_concat_values,1, instr(l_concat_values,l_delimiter,1,l_segment_count));
          end if;
          l_sensitive_part :=  substr(l_concat_values,instr(l_concat_values,l_delimiter,1,l_segment_count+1));
          l_concat_values := '';
          l_concat_values := l_global_part || l_context_value || l_sensitive_part;
      end if;

      l_concat_values := '''' || l_concat_values;
      hr_utility.set_location(l_concat_values, 110);
      hr_utility.set_location('The value is true', 12);
      RETURN l_concat_values;
  else
      hr_utility.set_location('The value is false', 13);
      if l_global_only_flag = 'Y' then
			l_concat_segments :=  substr(l_concat_segments,1, instr(l_concat_segments,l_delimiter,1,l_segment_count));
      l_concat_segments := SUBSTR(l_concat_segments,1,LENGTH(l_concat_segments)-1);
 			end if;
      RETURN l_concat_segments;
 end if;



Exception
when others then
     hr_utility.set_location('sqlerrm:'||substr(sqlerrm,1,50), 100);
     hr_utility.set_location('sqlerrm:'||substr(sqlerrm,51,100), 101);
     hr_utility.set_location('sqlerrm:'||substr(sqlerrm,101,150), 102);

END Get_Concatanated_DFF_Segments;

END PQP_RIW_WEBADI_UTILS;

/
