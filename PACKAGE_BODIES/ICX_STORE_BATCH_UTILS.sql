--------------------------------------------------------
--  DDL for Package Body ICX_STORE_BATCH_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_STORE_BATCH_UTILS" AS
/* $Header: ICXSTBUB.pls 115.1 99/07/17 03:26:02 porting shi $ */

-------------------------------------------------------------------
-- This procedure gets one line from the long string and trucates left the
-- the long string after retrieves the line.
-- The line is appended with the field separator.
-------------------------------------------------------------------
PROCEDURE get_line  (p_text IN OUT LONG,
                     p_line IN OUT LONG) IS

  l_position NUMBER := NULL;

BEGIN

  IF p_text IS NULL THEN
     p_line := NULL;
     RETURN;
  END IF;

  l_position := INSTR(p_text, g_line_sep);

  IF (l_position IS NULL) OR (l_position = 0 ) THEN
     p_line := p_text;
     p_text := NULL;
     RETURN;
  END IF;

  p_line := substr(p_text, 1, l_position - 1);
  p_text := substr(p_text, l_position + LENGTH(g_line_sep));

  -- Append the field separator, so the get_field procedure can
  -- retrieve the last filed
  p_line := p_line || g_field_sep;

EXCEPTION
  WHEN OTHERS THEN
    htp.p('Error in get_line : ' || substr(SQLERRM, 1, 512));
    -- icx_util.add_error(substr(SQLERRM, 12, 512));
    -- icx_util.error_page_print;
END get_line;


-------------------------------------------------------------------
-- This procedure gets one field from the long string line and removes
-- the field from the line.
-------------------------------------------------------------------
PROCEDURE get_field  (p_line IN OUT LONG,
                      p_field OUT LONG) IS

  l_position NUMBER := NULL;

BEGIN

  IF p_line IS NULL THEN
     p_field := NULL;
     RETURN;
  END IF;

  l_position := INSTR(p_line, g_field_sep);

  IF (l_position IS NULL) OR (l_position = 0 ) THEN
     p_field := p_line;
     p_line := NULL;
     RETURN;
  END IF;

  p_field := substr(p_line, 1, l_position - 1);
  p_line := substr(p_line, l_position + LENGTH(g_field_sep));


EXCEPTION
  WHEN OTHERS THEN
    htp.p('Error in get_field : ' || substr(SQLERRM, 1, 512));
    -- icx_util.add_error(substr(SQLERRM, 12, 512));
    -- icx_util.error_page_print;
END get_field;

-----------------------------------------------------------
PROCEDURE get_prompts_table  (p_region_code IN VARCHAR2,
                              p_prompts_table OUT item_prompts_table) IS

CURSOR item_prompts IS
        SELECT  ATTRIBUTE_LABEL_LONG,ATTRIBUTE_CODE, DISPLAY_VALUE_LENGTH
        FROM    AK_REGION_ITEMS_VL
        WHERE   REGION_CODE = p_region_code
        AND     (NODE_DISPLAY_FLAG = 'Y'
                 OR ATTRIBUTE_CODE = 'ICX_INVENTORY_ITEM_ID')
        ORDER BY DISPLAY_SEQUENCE;

 i NUMBER := NULL;
BEGIN

  i := 1;
  OPEN item_prompts;
  LOOP
    FETCH item_prompts INTO p_prompts_table(i).attribute_label,
                            p_prompts_table(i).attribute_code,
                            p_prompts_table(i).display_value_length;
    EXIT WHEN item_prompts%NOTFOUND;
    i := i + 1;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    htp.p('Error in get_prompts_table : ' || substr(SQLERRM, 1, 512));
    -- icx_util.add_error(substr(SQLERRM, 12, 512));
    -- icx_util.error_page_print;
END get_prompts_table;

----------------------------------------------------------
-- This procedure returns 'S' when the p_filed string is successfully
-- converted to the given date format or p_field is NULL.
-- Returns 'E' when the conversion fails
----------------------------------------------------------
PROCEDURE convert_to_date  (p_field IN VARCHAR2,
                            p_date_format IN VARCHAR2,
                            p_date OUT DATE,
                            p_error_flag OUT VARCHAR2)
IS

BEGIN

  IF p_field IS NOT NULL THEN
    p_date := TO_DATE(p_field, p_date_format);
    p_error_flag := 'S';
  ELSE
    p_date := NULL;
    p_error_flag := 'S';
  END IF;
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    p_date := NULL;
    p_error_flag := 'E';
    -- htp.p('Error in convert_to_date : ' || substr(SQLERRM, 1, 512));
    -- icx_util.add_error(substr(SQLERRM, 12, 512));
    -- icx_util.error_page_print;
END convert_to_date;


-----------------------------------------------------------
-- This procedure returns the attributes of a given prompt in the region.
-----------------------------------------------------------
PROCEDURE get_prompts_info  (p_prompts_table IN item_prompts_table,
                             p_attribute_code IN VARCHAR2,
                             p_attribute_info_record OUT prompt_rec)
IS

BEGIN

  IF p_prompts_table.COUNT = 0 THEN
     p_attribute_info_record := NULL;
     RETURN;
  END IF;
  FOR i IN p_prompts_table.FIRST..p_prompts_table.LAST LOOP

   IF p_prompts_table(i).attribute_code = p_attribute_code THEN
      p_attribute_info_record.attribute_label := p_prompts_table(i).attribute_label;
      p_attribute_info_record.attribute_code := p_prompts_table(i).attribute_code;
      p_attribute_info_record.display_value_length := p_prompts_table(i).display_value_length;

      RETURN;
   END IF; -- IF p_prompts_table(i)...

  END LOOP; -- FOR i IN p_prompts_table
  -- No match found
  p_attribute_info_record := NULL;
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    htp.p('Error in get_prompts_info : ' || substr(SQLERRM, 1, 512));
    -- icx_util.add_error(substr(SQLERRM, 12, 512));
    -- icx_util.error_page_print;
END get_prompts_info;


---------------------------------------------------------------
-- Function replaces crlf with '\n' and returns the string
---------------------------------------------------------------
FUNCTION replace_crlf (p_string IN VARCHAR2)
 RETURN VARCHAR2 IS

 l_string VARCHAR2(2000) := NULL;

BEGIN

 -- Replace the CR/LF with \n
 l_string := REPLACE(p_string, C_CR_LF, '\n');

 RETURN l_string;

EXCEPTION
  WHEN OTHERS THEN
    htp.p('Error in replace_crlf: ' || substr(SQLERRM, 1, 512));
    -- icx_util.add_error(substr(SQLERRM, 12, 512));
    -- icx_util.error_page_print;
END replace_crlf;

END icx_store_batch_utils;

/
