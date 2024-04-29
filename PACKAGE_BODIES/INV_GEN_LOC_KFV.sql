--------------------------------------------------------
--  DDL for Package Body INV_GEN_LOC_KFV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_GEN_LOC_KFV" AS
  /* $Header: INVLKFFB.pls 120.3.12000000.2 2007/01/31 05:19:31 varajago ship $ */

G_compatibility_mode_1157 VARCHAR2(6) := '1157';  --Added for bug#5744890 /* For value 1157, ID to value conversion will happen for locator segments, if defined.*/
G_compatibility_mode_1158 VARCHAR2(6) := '1158';  --Added for bug#4345239
G_compatibility_mode_1159 VARCHAR2(6) := '1159';  --Added for bug#4345239


-- This regenerates WMS_ITEM_LOCATIONS_KFV with new Segment definitions if any.

PROCEDURE GENERATE_LOCATOR_KFF_VIEW(x_errbuf	         OUT NOCOPY VARCHAR2
                                   ,x_retcode	      OUT NOCOPY NUMBER
				   ,p_compatibility IN VARCHAR2)  IS --Added for bug#4345239

  l_view_text VARCHAR2(10000);
  l_concat_segments VARCHAR2(500);
  l_debug NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  --
  CURSOR c_cur_seg (p_compatibility VARCHAR2) IS
    SELECT application_column_name
      FROM fnd_id_flex_segments ffs
    WHERE application_id = 401 -- 'INV'
        AND id_flex_code = 'MTLL'
        AND id_flex_num = 101    -- 'STOCK_LOCATORS'
        AND enabled_flag = 'Y'
        AND display_flag = 'Y'
        AND (application_column_name not in ('SEGMENT19','SEGMENT20')
             OR p_compatibility = G_compatibility_mode_1158) --Added for bug#4345239
    ORDER BY segment_num;

	--
   CURSOR c_delim is
    SELECT concatenated_segment_delimiter
    FROM fnd_id_flex_structures
    WHERE id_flex_code = 'MTLL'
    AND ROWNUM = 1;
	--
	l_segment_name VARCHAR2(50);
	l_delim        VARCHAR2(1);
	l_sqlid        INTEGER;
	l_execute      INTEGER;
        l_compatibility VARCHAR2(10) := NVL( p_compatibility, '1159');  --Bug#4345239.Set the default Value
        l_proj_task_segments VARCHAR2(20);  --Added Bug#4345239
BEGIN
--
   l_view_text := 'CREATE OR REPLACE VIEW WMS_ITEM_LOCATIONS_KFV AS SELECT';
   l_view_text := l_view_text||' ROWID ROW_ID ,INVENTORY_LOCATION_ID,ORGANIZATION_ID,DROPPING_ORDER, SUBINVENTORY_CODE, LOCATION_WEIGHT_UOM_CODE, MAX_WEIGHT, VOLUME_UOM_CODE, ';
   l_view_text := l_view_text||' MAX_CUBIC_AREA, X_COORDINATE, Y_COORDINATE, Z_COORDINATE, INVENTORY_ACCOUNT_ID, SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, SEGMENT5, SEGMENT6, ';
   l_view_text := l_view_text||' SEGMENT7, SEGMENT8, SEGMENT9, SEGMENT10, SEGMENT11, SEGMENT12, SEGMENT13, SEGMENT14, SEGMENT15, SEGMENT16, SEGMENT17, SEGMENT18, SEGMENT19, SEGMENT20, ';
   l_view_text := l_view_text||' SUMMARY_FLAG, ENABLED_FLAG, START_DATE_ACTIVE, END_DATE_ACTIVE, ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ';
   l_view_text := l_view_text||' ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, REQUEST_ID, PROGRAM_APPLICATION_ID, ';
   l_view_text := l_view_text||' PROGRAM_ID, PROGRAM_UPDATE_DATE, PROJECT_ID, TASK_ID, PHYSICAL_LOCATION_ID, PICK_UOM_CODE, DIMENSION_UOM_CODE, LENGTH, WIDTH, HEIGHT, LOCATOR_STATUS, ';
   l_view_text := l_view_text||' STATUS_ID, CURRENT_CUBIC_AREA, AVAILABLE_CUBIC_AREA, CURRENT_WEIGHT, AVAILABLE_WEIGHT, LOCATION_CURRENT_UNITS, LOCATION_AVAILABLE_UNITS, INVENTORY_ITEM_ID, ';
   l_view_text := l_view_text||' SUGGESTED_CUBIC_AREA, SUGGESTED_WEIGHT, LOCATION_SUGGESTED_UNITS, EMPTY_FLAG, MIXED_ITEMS_FLAG, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,';
   l_view_text := l_view_text||' DESCRIPTION, DESCRIPTIVE_TEXT, DISABLE_DATE, INVENTORY_LOCATION_TYPE, PICKING_ORDER, PHYSICAL_LOCATION_CODE, LOCATION_MAXIMUM_UNITS, ALIAS, ';

   IF (l_debug = 1) THEN
     inv_log_util.TRACE('Created the SQL to create the new VIEW ', 'INVLOC', 9);
   END IF;
   --
   --Forming the concatenated segments\
   --Fetchng the segment delimter
   --
   OPEN c_delim;
   FETCH c_delim INTO l_delim;
   CLOSE c_delim;

   IF (l_debug = 1) THEN
     inv_log_util.TRACE('Opened the cursor c_delim ', 'INVLOC', 9);
   END IF;
   ---Fetching the concatenated segments
   OPEN c_cur_seg(l_compatibility);
   FETCH c_cur_seg INTO l_segment_name;

   IF (l_debug = 1) THEN
     inv_log_util.TRACE('Opened the cursor c_cur_seg ', 'INVLOC', 9);
   END IF;
   --
   IF c_cur_seg%NOTFOUND THEN

     CLOSE c_cur_seg;
	 l_concat_segments:=l_concat_segments||''''||' X '||'''';
	 GOTO concat_segs;

   ELSIF l_segment_name in ('SEGMENT19','SEGMENT20') THEN  --Added bug#4345239.
     l_proj_task_segments := ''''||l_delim||'''' ;
   ELSE
     l_concat_segments:=l_concat_segments||l_segment_name ;
   END IF;

   IF (l_debug = 1) THEN
     inv_log_util.TRACE('About to loop on cursor c_cur_seg to get the concatenated segment.', 'INVLOC', 9);
   END IF;
   --
   --Forming the concatenated segments
   LOOP
    FETCH c_cur_seg INTO l_segment_name;
    EXIT WHEN c_cur_seg%NOTFOUND;
    IF l_segment_name  in ('SEGMENT19','SEGMENT20') THEN  --bug#4345239.Added IF Block.
       l_proj_task_segments := l_proj_task_segments || '||'||''''||l_delim||'''' ;
    ELSE
       l_concat_segments := l_concat_segments||'||'||''''||l_delim||''''||'||'||l_segment_name;
    END IF;
   END LOOP;
   CLOSE c_cur_seg;
   --
   <<concat_segs>>

 -- l_concat_segments := l_concat_segments||l_proj_task_segments||' CONCATENATED_SEGMENTS '; --Bug4345239.commented.

   IF (l_debug = 1) THEN
     inv_log_util.TRACE('The concatenated segment is '||l_concat_segments, 'INVLOC', 9);
     inv_log_util.TRACE('The proj/task segments :  '||l_proj_task_segments, 'INVLOC', 9);
   END IF;
   --


   IF (l_compatibility <> g_compatibility_mode_1157) THEN
	l_view_text := l_view_text||l_concat_segments||l_proj_task_segments||' CONCATENATED_SEGMENTS '; --Bug4345239.
	l_view_text := l_view_text|| ','||l_concat_segments||' LOCATOR_SEGMENTS '; --Bug4345239.
   ELSE
	l_view_text := l_view_text||l_concat_segments||l_proj_task_segments||' CONCATENATED_SEGMENTS '; --Bug4345239
	l_view_text := l_view_text|| ', INV_PROJECT.GET_LOCSEGS(INVENTORY_LOCATION_ID, ORGANIZATION_ID) LOCATOR_SEGMENTS '; --Bug5744890
   END IF;

l_view_text := l_view_text||' FROM MTL_ITEM_LOCATIONS ';
   --
   l_sqlid := dbms_sql.open_cursor;
   dbms_sql.parse(l_sqlid,l_view_text,dbms_sql.native);
   --
   l_execute := dbms_sql.execute(l_sqlid);
   dbms_sql.close_cursor(l_sqlid);
   --
   IF (l_debug = 1) THEN
     inv_log_util.TRACE('Successfully Recompiled the View.', 'INVLOC', 9);
   END IF;
   x_errbuf := null;
   x_retcode := retcode_success;

 EXCEPTION
  WHEN OTHERS THEN
	 --
	 if c_cur_seg%ISOPEN then
	   CLOSE c_cur_seg;
	 end if;
	 if c_delim%ISOPEN then
	   CLOSE c_delim;
	 end if;
	--
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('An Error has occurred ErrNum='||TO_CHAR(SQLCODE)||', Error Msg='||SQLERRM, 'INVLOC', 9);
        END IF;
	x_errbuf := SQLERRM;
        x_retcode := retcode_error;
        RAISE;
END GENERATE_LOCATOR_KFF_VIEW;

END INV_GEN_LOC_KFV;

/
