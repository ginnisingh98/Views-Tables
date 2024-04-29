--------------------------------------------------------
--  DDL for Package Body BIS_RKPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RKPI" as
/*$Header: BISRKPIB.pls 120.2 2006/01/03 22:34:52 akoduri noship $*/


FUNCTION GET_PMF_DIM_L_SN(
	p_ak_region_code IN VARCHAR2,
  p_filter_time_dl IN VARCHAR2 := 'T'
) RETURN VARCHAR2
IS
   TYPE t_cursor IS REF CURSOR;
   h_cursor t_cursor;
   h_name AK_REGION_ITEMS.region_code%TYPE;
   h_group AK_REGION_ITEMS.region_code%TYPE;
   h_sql VARCHAR2(32700);
   h_sn_comb VARCHAR2(32700);
BEGIN

-- avoid using OR
   h_sql := 'SELECT DISTINCT sn, gr FROM '||
   -- non nested items
   		'((SELECT SUBSTR(A.attribute2,'||
		' INSTR(A.attribute2, ''+'') + 1,'||
		' LENGTH(A.attribute2)-INSTR(A.attribute2, ''+''))'||
		' AS sn,'||
		' SUBSTR(A.attribute2,'||
		' 1,'||
		' INSTR(A.attribute2, ''+'') - 1)'||
		' AS gr'||
        ' FROM AK_REGION_ITEMS A'||
    	' WHERE A.region_code = :1'||
	    ' AND A.item_style <> ''NESTED_REGION'''||
        ' AND A.attribute1 IN (''DIM LEVEL SINGLE VALUE'', '||
		'''DIMENSION LEVEL'', ''HIDE DIMENSION LEVEL'', '||
		'''HIDE PARAMETER'', ''HIDE VIEW BY DIMENSION'', '||
		'''HIDE_VIEW_BY_DIM_SINGLE'', ''COMPARE TO DIMENSION LEVEL'', '||
		'''VIEWBY PARAMETER'')'||
		' AND A.attribute2 IS NOT NULL)'||
		' UNION '||
	-- nested items
		'(SELECT SUBSTR(A.attribute2,'||
		' INSTR(A.attribute2, ''+'') + 1,'||
		' LENGTH(A.attribute2)-INSTR(A.attribute2, ''+''))'||
		' AS sn,'||
		' SUBSTR(A.attribute2,'||
		' 1,'||
		' INSTR(A.attribute2, ''+'') - 1)'||
		' AS gr'||
        ' FROM AK_REGION_ITEMS A'||
    	' WHERE A.region_code IN '||
			'(SELECT B.nested_region_code '||
					'FROM AK_REGION_ITEMS B '||
					'WHERE B.region_code = :2 '||
					'AND B.ITEM_STYLE = ''NESTED_REGION'')'||
        ' AND A.attribute1 IN (''DIM LEVEL SINGLE VALUE'', '||
		'''DIMENSION LEVEL'', ''HIDE DIMENSION LEVEL'', '||
		'''HIDE PARAMETER'', ''HIDE VIEW BY DIMENSION'', '||
		'''HIDE_VIEW_BY_DIM_SINGLE'', ''COMPARE TO DIMENSION LEVEL'', '||
		'''VIEWBY PARAMETER'')'||
		' AND A.attribute2 IS NOT NULL))'||
        ' ORDER BY sn';

   OPEN h_cursor FOR h_sql USING p_ak_region_code, p_ak_region_code;
   LOOP
       FETCH h_cursor INTO h_name, h_group;
       EXIT WHEN h_cursor%NOTFOUND;

       -- exclude time dimension
       IF ((p_filter_time_dl IS NULL) OR (p_filter_time_dl <> 'T') OR
           (p_filter_time_dl = 'T' AND h_group <> 'TIME' AND h_group <> 'EDW_TIME_M' AND h_group <> 'TIME_COMPARISON_TYPE')) THEN
         IF (h_sn_comb IS NULL) THEN
           h_sn_comb := ','||h_name||',';
         ELSE
           h_sn_comb := h_sn_comb||','||h_name||',';
         END IF;
    	 END IF;
   END LOOP;
   CLOSE h_cursor;

   IF h_sn_comb IS NULL THEN
	 RETURN ' ';
   END IF;

   RETURN h_sn_comb;
   EXCEPTION
	 WHEN OTHERS THEN
	   IF (h_cursor%ISOPEN) THEN
		CLOSE h_cursor;
	   END IF;
       RETURN NULL;
END GET_PMF_DIM_L_SN;



FUNCTION GET_PMF_DIM_L_COMB(
	p_dim_level_list IN VARCHAR2,
	p_lang IN VARCHAR2
) RETURN VARCHAR2
IS
   TYPE t_cursor IS REF CURSOR;
   h_cursor t_cursor;
   h_sql VARCHAR2(32700);
	-- current shortname position in the list
   h_start_pos NUMBER;
   h_end_pos NUMBER;
   h_strlen NUMBER;
   h_sn AK_REGION_ITEMS.attribute2%TYPE;
   h_name BIS_LEVELS_VL.name%TYPE;
   h_name_comb VARCHAR2(32767);

BEGIN

   h_strlen := LENGTH(p_dim_level_list);

   IF (h_strlen <= 1) THEN
	RETURN ' ';
   END IF;

   -- start position of the input list
   h_start_pos := 2;

   h_sql := 'SELECT b2.name'||
            ' FROM BIS_LEVELS_TL b2, BIS_LEVELS b1'||
            ' WHERE b1.SHORT_NAME = :1'||
		' AND b1.LEVEL_ID = b2.LEVEL_ID'||
	      ' AND b2.language = :2';

   LOOP
      EXIT WHEN h_start_pos >= h_strlen;

	h_end_pos := INSTR(p_dim_level_list, ',' , h_start_pos, 1);
	h_sn := SUBSTR(p_dim_level_list, h_start_pos, h_end_pos-h_start_pos);
	OPEN h_cursor FOR h_sql USING h_sn, p_lang;
      FETCH h_cursor INTO h_name;
	CLOSE h_cursor;

      IF (h_name_comb IS NULL) THEN
           h_name_comb := h_name;
      ELSE
           h_name_comb := h_name_comb||', '||h_name;
      END IF;

	h_start_pos := h_end_pos + 2;

   END LOOP;

   RETURN h_name_comb;
   EXCEPTION
	 WHEN OTHERS THEN
	   IF (h_cursor%ISOPEN) THEN
		CLOSE h_cursor;
	   END IF;
       RETURN NULL;
END GET_PMF_DIM_L_COMB;


FUNCTION REMOVE_COMMON_PARAMS(
	p_dim_level_list IN VARCHAR2,
	p_common_params IN VARCHAR2
) RETURN VARCHAR2
IS
   TYPE t_cursor IS REF CURSOR;

	-- current shortname position in the list
   h_start_pos NUMBER;
   h_end_pos NUMBER;
   h_strlen NUMBER;

   h_com_start_pos NUMBER;
   h_com_end_pos NUMBER;
   h_com_strlen NUMBER;

   h_sn AK_REGION_ITEMS.attribute2%TYPE;
   h_com_sn AK_REGION_ITEMS.attribute2%TYPE;

   h_sn_comb VARCHAR2(32767);

BEGIN
-- loop until p_dim_level_list or p_common_params reaches the end

	h_strlen := LENGTH(p_dim_level_list);
	IF (h_strlen <= 1) THEN
		RETURN ' ';
	END IF;
	-- start position of the input list
	h_start_pos := 2;

	h_com_strlen := LENGTH(p_common_params);
	IF (h_com_strlen <= 1) THEN
		RETURN p_dim_level_list;
	END IF;
	-- start position of the input list
	h_com_start_pos := 2;

   LOOP
      EXIT WHEN ((h_start_pos >= h_strlen) OR (h_com_start_pos >= h_com_strlen));

	  h_end_pos := INSTR(p_dim_level_list, ',' , h_start_pos, 1);
	  h_sn := SUBSTR(p_dim_level_list, h_start_pos, h_end_pos-h_start_pos);

	  h_com_end_pos := INSTR(p_common_params, ',' , h_com_start_pos, 1);
	  h_com_sn := SUBSTR(p_common_params, h_com_start_pos, h_com_end_pos-h_com_start_pos);


        IF (h_sn < h_com_sn) THEN
	    h_start_pos := h_end_pos + 2;
    	    IF (h_sn_comb IS NULL) THEN
      	h_sn_comb := ','||h_sn||',';
          ELSE
          	h_sn_comb := h_sn_comb||','||h_sn||',';
	    END IF;
        ELSIF (h_sn > h_com_sn) THEN
	    h_com_start_pos := h_com_end_pos + 2;
        ELSE
	    -- they are equal
	    h_start_pos := h_end_pos + 2;
	    h_com_start_pos := h_com_end_pos + 2;
       END IF;
   END LOOP;

   -- if p_dim_level_list has not reach the end
   -- copy the rest
   IF (h_start_pos < h_strlen) THEN
	h_sn := SUBSTR(p_dim_level_list, h_start_pos, h_strlen-h_start_pos+1);
      IF (h_sn_comb IS NULL) THEN
		h_sn_comb := ','||h_sn;
      ELSE
		h_sn_comb := h_sn_comb||','||h_sn;
      END IF;
   END IF;

   IF (h_sn_comb IS NULL) THEN
	h_sn_comb := ' ';
   END IF;

   RETURN h_sn_comb;

   EXCEPTION
	  WHEN OTHERS THEN
          RETURN NULL;
END REMOVE_COMMON_PARAMS;

END BIS_RKPI;

/
