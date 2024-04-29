--------------------------------------------------------
--  DDL for Package Body GL_FLEXFIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FLEXFIELDS_PKG" AS
/* $Header: glumsflb.pls 120.16 2006/04/03 17:01:52 cma ship $ */


  ---
  --- PRIVATE VARIABLES
  ---

  --- Position of the segment
  seg_num		NUMBER := null;

  -- Chart of accounts for which the position was gotten
  last_coa_id  		NUMBER := null;

  -- Qualifier for which the position was gotten
  last_qual_text	VARCHAR2(100) := null;

  --
  --    To cache description information for the sake of efficiency
  --    2 sets of variables for balancing and drilldown segments.
  --
  -- chart of account id
    g_coa	NUMBER := null;
  -- balancing segment number
    g_seg_num1  NUMBER := null;
  -- drilldown segment number
    g_seg_num2  NUMBER := null;
  -- balancing segment value
    g_seg_val1  VARCHAR2(25) := null;
  -- drilldown segment value
    g_seg_val2  VARCHAR2(25) := null;
  -- balancing segment description
    g_desc1     VARCHAR2(1000) := null;
  -- drilldown segment description
    g_desc2     VARCHAR2(1000) := null;


--
-- PUBLIC FUNCTIONS
--

-- BugFix: 2831551 Added the application id in the below where clause.

  FUNCTION get_account_segment(coa_id NUMBER) RETURN VARCHAR2 IS
    CURSOR get_acct_seg IS
      SELECT fs.segment_name
      FROM   fnd_id_flex_segments fs,
             fnd_segment_attribute_values av
      WHERE  fs.application_column_name = av.application_column_name
      AND    av.id_flex_code = 'GL#'
      AND    fs.id_flex_code = av.id_flex_code
      AND    av.id_flex_num = coa_id
      AND    fs.application_id = 101
      AND    av.application_id = 101
      AND    fs.id_flex_num = av.id_flex_num
      AND    av.segment_attribute_type='GL_ACCOUNT'
      AND    av.attribute_value='Y';
    segname VARCHAR2(40);
  BEGIN
    OPEN get_acct_seg;
    FETCH get_acct_seg INTO segname;

    IF get_acct_seg%FOUND THEN
      CLOSE get_acct_seg;
      RETURN(segname);
    ELSE
      CLOSE get_acct_seg;
      fnd_message.set_name('SQLGL', 'GL_MISSING_ACCOUNT_SEGMENT');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_flexfields_pkg.get_account_segment');
      RAISE;
  END get_account_segment;



  FUNCTION get_description(
	      x_coa_id					NUMBER,
	      x_qual_text				VARCHAR2,
	      x_segment_val				VARCHAR2
	   ) RETURN VARCHAR2 IS
  BEGIN
     IF ((seg_num IS NULL)
        OR (nvl(last_coa_id, -1) <> x_coa_id)
        OR (nvl(last_qual_text, 'X') <> x_qual_text)
        ) THEN
        IF (NOT fnd_flex_apis.get_qualifier_segnum(
                appl_id 		=> 101,
                key_flex_code		=> 'GL#',
      	        structure_number	=> x_coa_id,
	        flex_qual_name		=> x_qual_text,
	        segment_number		=> seg_num)
            ) THEN
            app_exception.raise_exception;
          END IF;

          last_coa_id := x_coa_id;
          last_qual_text := x_qual_text;
      END IF;

    -- Get the description
    IF (fnd_flex_keyval.validate_segs(
          operation => 'CHECK_SEGMENTS',
          appl_short_name => 'SQLGL',
          key_flex_code => 'GL#',
          structure_number => x_coa_id,
          concat_segments => x_segment_val,
          displayable => x_qual_text,
          allow_nulls => TRUE,
          allow_orphans => TRUE)) THEN
      null;
    END IF;

    RETURN(fnd_flex_keyval.segment_description(seg_num));
  END get_description;

  FUNCTION get_any_seg_description(
	      x_coa_id					NUMBER,
	      x_qual_text				VARCHAR2,
	      x_segment_val				VARCHAR2,
              x_seg_num                                 NUMBER
	   ) RETURN VARCHAR2 IS
  BEGIN

    -- Get the description
    IF (fnd_flex_keyval.validate_segs(
          operation => 'CHECK_SEGMENTS',
          appl_short_name => 'SQLGL',
          key_flex_code => 'GL#',
          structure_number => x_coa_id,
          concat_segments => x_segment_val,
          displayable => x_qual_text,
          allow_nulls => TRUE,
          allow_orphans => TRUE)) THEN
      null;
    END IF;

    RETURN(fnd_flex_keyval.segment_description(x_seg_num));
  END get_any_seg_description;

  FUNCTION get_coa_name(coa_id	NUMBER) RETURN VARCHAR2 IS
    coa_name	VARCHAR2(30) ;
  BEGIN
    SELECT id_flex_structure_name
    INTO coa_name
    FROM fnd_id_flex_structures_vl
    WHERE application_id=101
    AND id_flex_code='GL#'
    AND id_flex_num=coa_id;

    RETURN(coa_name);
  END get_coa_name;

-- lifted from GL_FORMSINFO package
  PROCEDURE get_coa_info (x_chart_of_accounts_id    IN     NUMBER,
                          x_segment_delimiter       IN OUT NOCOPY VARCHAR2,
                          x_enabled_segment_count   IN OUT NOCOPY NUMBER,
                          x_segment_order_by        IN OUT NOCOPY VARCHAR2,
                          x_accseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_accseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_accseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_balseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_balseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_balseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_ieaseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_ieaseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_ieaseg_left_prompt      IN OUT NOCOPY VARCHAR2) IS

    CURSOR seg_count IS
      SELECT segment_num, application_column_name
      FROM fnd_id_flex_segments
      WHERE application_id = 101
      AND   id_flex_code   = 'GL#'
      AND   enabled_flag   = 'Y'
      AND   id_flex_num    = x_chart_of_accounts_id
      ORDER BY segment_num;

    dumdum BOOLEAN := FALSE;
    x_seg_name VARCHAR2(30);
    x_value_set VARCHAR2(60);

  BEGIN

    -- Identify the natural account and balancing segments
    dumdum := FND_FLEX_APIS.get_qualifier_segnum(
                101, 'GL#', x_chart_of_accounts_id,
                'GL_ACCOUNT', x_accseg_segment_num);
    dumdum := FND_FLEX_APIS.get_qualifier_segnum(
                101, 'GL#', x_chart_of_accounts_id,
                'GL_BALANCING', x_balseg_segment_num);
    dumdum := FND_FLEX_APIS.get_qualifier_segnum(
                101, 'GL#', x_chart_of_accounts_id,
                'GL_INTERCOMPANY', x_ieaseg_segment_num);

    -- Get the segment delimiter
    x_segment_delimiter := FND_FLEX_APIS.get_segment_delimiter(
                             101, 'GL#', x_chart_of_accounts_id);

    -- Count 'em up and string 'em together
    x_enabled_segment_count := 0;
    FOR r IN seg_count LOOP
      -- How many enabled segs are there?
      x_enabled_segment_count := seg_count%ROWCOUNT;
      -- Record the order by string
      IF seg_count%ROWCOUNT = 1 THEN
        x_segment_order_by      := r.application_column_name;
      ELSE
        x_segment_order_by      := x_segment_order_by||
                                   ','||
                                   r.application_column_name;
      END IF;
      -- If this is either the accseg or balseg, get more info
      IF    r.segment_num = x_accseg_segment_num THEN
        IF (FND_FLEX_APIS.get_segment_info(
              101, 'GL#', x_chart_of_accounts_id,
              r.segment_num, x_accseg_app_col_name,
              x_seg_name, x_accseg_left_prompt, x_value_set)) THEN
          null;
        END IF;
      ELSIF r.segment_num = x_balseg_segment_num THEN
        IF (FND_FLEX_APIS.get_segment_info(
              101, 'GL#', x_chart_of_accounts_id,
              r.segment_num, x_balseg_app_col_name,
              x_seg_name, x_balseg_left_prompt, x_value_set)) THEN
          null;
        END IF;
      ELSIF r.segment_num = x_ieaseg_segment_num THEN
        IF (FND_FLEX_APIS.get_segment_info(
              101, 'GL#', x_chart_of_accounts_id,
              r.segment_num, x_ieaseg_app_col_name,
              x_seg_name, x_ieaseg_left_prompt, x_value_set)) THEN
          null;
        END IF;
      END IF;
    END LOOP;

  EXCEPTION
   WHEN OTHERS THEN
     app_exception.raise_exception;
  END get_coa_info;


  FUNCTION get_sd_description_sql (
                        x_coa_id        IN NUMBER,
                        x_pos           IN NUMBER,
                        x_seg_num       IN NUMBER,
                        x_seg_val       IN VARCHAR2 ) RETURN VARCHAR2 IS
        seg_desc       VARCHAR2(1000);
  BEGIN
    /* Summarized rows have segment number as '-1'. They don't have any
       descriptions. So, returns null. */
    if (x_seg_num = -1) then
        if (x_pos = 1) then
            /* caching for balancing */
            g_coa := x_coa_id;
            g_seg_num1 := x_seg_num;
            g_seg_val1 := x_seg_val;
            g_desc1 := '';
        else
            /* caching for drilldown */
            g_coa := x_coa_id;
            g_seg_num2 := x_seg_num;
            g_seg_val2 := x_seg_val;
            g_desc2 := '';
        end if;
        return null;
    end if;

    /* Check if the current row has the exact same values as the previous
       one. If so, we just pass back the cached description. */
    if (x_pos = 1) then
        if (    g_coa = x_coa_id
            and g_seg_num1 = x_seg_num
            and g_seg_val1 = x_seg_val) then
            return g_desc1;
        else
            /* caching for balancing */
            g_coa := x_coa_id;
            g_seg_num1 := x_seg_num;
            g_seg_val1 := x_seg_val;
        end if;
    else
        if (    g_coa = x_coa_id
            and g_seg_num2 = x_seg_num
            and g_seg_val2 = x_seg_val) then
            return g_desc2;
        else
            /* caching for drilldown */
            g_coa := x_coa_id;
            g_seg_num2 := x_seg_num;
            g_seg_val2 := x_seg_val;
        end if;
    end if;

    /* No match with previous row. Need to get description from SQL. */
    seg_desc := get_description_sql(x_coa_id, x_seg_num, x_seg_val);

    /* cache up the segment value description */
    if (x_pos = 1) then
        g_desc1 := seg_desc;
    else
        g_desc2 := seg_desc;
    end if;

    return seg_desc;

  END get_sd_description_sql;


  FUNCTION get_description_sql (
                        x_coa_id        IN NUMBER,
                        x_seg_num       IN NUMBER,
                        x_seg_val       IN VARCHAR2 ) RETURN VARCHAR2 IS
        v_vsid		NUMBER;
        v_type		VARCHAR2(1);
        v_desc_table   VARCHAR2(240);
        v_val_col      VARCHAR2(240);
        v_desc_col     VARCHAR2(240);
        v_desc_sql     VARCHAR2(500);
        desc_cursor    INTEGER;
        seg_desc       VARCHAR2(1000);
        dummy          NUMBER;
        row_count      NUMBER := 0;
        v_sql_stmt     VARCHAR2(2000) ;
	v_cursor       INTEGER;
	v_return       INTEGER;

	l_seg_num      number;
	l_coa_id       number;
	l_seg_val      varchar2(240);
	l_vset_id      number;

  BEGIN
        BEGIN
            /* Retrieve the value set id and validation type
               for the segment */
            SELECT S.flex_value_set_id,
                   VS.validation_type
            INTO   v_vsid,
                   v_type
            FROM   FND_ID_FLEX_SEGMENTS S,
                   FND_FLEX_VALUE_SETS VS
            WHERE  S.id_flex_num = x_coa_id
            AND	   S.application_id = 101
            AND	   S.id_flex_code = 'GL#'
            AND	   S.segment_num = x_seg_num
            AND	   S.enabled_flag = 'Y'
            AND	   VS.flex_value_set_id = S.flex_value_set_id;
        EXCEPTION
            /* Wrong combination of chart of accout id and
               segment number. */
            WHEN no_data_found THEN
                raise INVALID_SEGNUM;
        END;

        /* Determine the relevant tables to obtain the segment value
           description. */
        IF ( v_type = 'F' ) THEN
            /* table validation segment */
            SELECT application_table_name,
                   value_column_name,
                   meaning_column_name
            INTO   v_desc_table,
                   v_val_col,
                   v_desc_col
            FROM   FND_FLEX_VALIDATION_TABLES
            WHERE  flex_value_set_id = v_vsid;

            /* if no description column is defined,
               just return null. */
            IF ( v_desc_col is null ) THEN
                return (NULL);
            END IF;
        ELSE
            /* dependent or independent segment */
            v_desc_table := 'FND_FLEX_VALUES_VL';
            v_val_col := 'flex_value';
            v_desc_col := 'description';
        END IF;

        /* Retrieve the segment value description. */
        v_desc_sql :=
            'SELECT	' || v_desc_col ||
            ' FROM	' || v_desc_table ||
            ' WHERE	' || v_val_col || ' = :seg_val ';
        /* For FND_FLEX_VALUES table, we have to filter values by
           flex_value_set_id */
        IF ( v_type <> 'F' ) THEN
            v_desc_sql := v_desc_sql ||
                'AND	flex_value_set_id = :vset_id';
        END IF;

        BEGIN

	    /* Introduced the cursor to fix bug# 3051914  */

	     v_cursor := dbms_sql.open_cursor;
       	dbms_sql.parse( v_cursor, v_desc_sql, dbms_sql.native);
        dbms_sql.bind_variable(v_cursor, 'seg_val' , x_seg_val );

	 IF ( v_type <> 'F' ) THEN
	   dbms_sql.bind_variable(v_cursor, 'vset_id' , v_vsid );

         END IF;


	dbms_sql.define_column(v_cursor ,1,seg_desc,1000);
	v_return := dbms_sql.execute (v_cursor ) ;
        v_return := dbms_sql.fetch_rows ( v_cursor );

	if v_return = 0 then
              raise no_data_found;
        end if;

        dbms_sql.column_value(v_cursor,1,seg_desc);

         /*   EXECUTE IMMEDIATE v_desc_sql
            INTO seg_desc
            USING x_seg_val; */

       dbms_sql.close_cursor(v_cursor);

        EXCEPTION
            WHEN no_data_found THEN
                dbms_sql.close_cursor(v_cursor);
                return (NULL);
            WHEN OTHERS THEN
                dbms_sql.close_cursor(v_cursor);
	        return (NULL);
        END;

        RETURN seg_desc;

  END get_description_sql;

  FUNCTION get_summary_flag (x_value_set_id   NUMBER,
                             x_segment_value  VARCHAR2) RETURN VARCHAR2 IS
    sum_flag   VARCHAR2(2);

    val_type   VARCHAR2(1);
    val_table  VARCHAR2(240);
    val_col    VARCHAR2(240);
    sum_col    VARCHAR2(240);
    stmt       VARCHAR2(500);
  BEGIN
    SELECT validation_type
    INTO   val_type
    FROM   fnd_flex_value_sets
    WHERE  flex_value_set_id = x_value_set_id;

    IF (val_type = 'F') THEN
      -- table validated segment
      SELECT application_table_name, value_column_name, summary_column_name
      INTO   val_table, val_col, sum_col
      FROM   fnd_flex_validation_tables
      WHERE  flex_value_set_id = x_value_set_id;

      -- if no summary column is defined, return 'N'
      IF (sum_col = 'N') THEN
        return ('N');
      END IF;
    ELSE
      -- dependent or independent segment
      val_table := 'FND_FLEX_VALUES';
      val_col := 'flex_value';
      sum_col := 'summary_flag';
    END IF;

    -- get the summary flag
    stmt := 'SELECT ' || sum_col ||
            ' FROM ' || val_table ||
            ' WHERE ' || val_col || ' = :seg_val';
    -- for FND_FLEX_VALUES, need to filter by flex_value_set_id
    IF (val_type <> 'F') THEN
      stmt := stmt || ' AND  flex_value_set_id = :vs_id';
      EXECUTE IMMEDIATE stmt INTO sum_flag
                             USING x_segment_value, x_value_set_id;
    ELSE
      EXECUTE IMMEDIATE stmt INTO sum_flag USING x_segment_value;
    END IF;

    RETURN sum_flag;
  END get_summary_flag;

  FUNCTION get_parent_from_children(
			vs_id		IN NUMBER,
			ancestor	IN VARCHAR2,
			child_low	IN VARCHAR2,
			child_high	IN VARCHAR2,
			parent_num	IN NUMBER) RETURN VARCHAR2 IS
    CURSOR get_single_parent IS
      SELECT min(parent_flex_value), count(*)
      FROM fnd_flex_value_norm_hierarchy
      WHERE flex_value_set_id = vs_id
      AND   child_flex_value_low = child_low
      AND   child_flex_value_high = child_high
      AND   range_attribute = 'C';

    CURSOR get_parent IS
      SELECT parent_flex_value
      FROM fnd_flex_value_norm_hierarchy
      WHERE flex_value_set_id = vs_id
      AND   child_flex_value_low = child_low
      AND   child_flex_value_high = child_high
      AND   range_attribute = 'C'
      AND   (parent_flex_value, child_flex_value_low,
             child_flex_value_high) IN
               (SELECT parent_flex_value, child_flex_value_low,
                       child_flex_value_high
                FROM fnd_flex_value_norm_hierarchy
                START with     flex_value_set_id = vs_id
                           AND parent_flex_value = ancestor
                CONNECT BY     flex_value_set_id = vs_id
                AND parent_flex_value BETWEEN PRIOR child_flex_value_low
                                      AND PRIOR child_flex_value_high
                AND PRIOR range_attribute = 'P')
      ORDER BY parent_flex_value;

    flexval       VARCHAR2(25);
    num_possibles NUMBER;
    last_flexval  VARCHAR2(25);
  BEGIN
    OPEN get_single_parent;
    FETCH get_single_parent INTO flexval, num_possibles;
    CLOSE get_single_parent;

    IF (num_possibles < 2) THEN
      RETURN(flexval);
    END IF;

    OPEN get_parent;

    FOR i IN 1..parent_num LOOP
      FETCH get_parent INTO flexval;

      EXIT WHEN get_parent%NOTFOUND;
      last_flexval := flexval;
    END LOOP;

    IF (get_parent%NOTFOUND) THEN
      CLOSE get_parent;
      RETURN(last_flexval);
    ELSE
      CLOSE get_parent;
      RETURN(flexval);
    END IF;
  END get_parent_from_children;

  FUNCTION Get_Concat_Description(
                     x_coa_id                 NUMBER,
                     x_ccid                   NUMBER,
                     x_enforce_value_security VARCHAR2
                     ) RETURN VARCHAR IS
    l_descp VARCHAR2(4000);
    l_delimiter VARCHAR2(1);
    l_num_segs NUMBER;
    l_security_code VARCHAR2(10);
  BEGIN
    IF (x_enforce_value_security = 'N') THEN
      l_security_code := 'IGNORE';
    ELSE
      l_security_code := 'ENFORCE';
    END IF;

    IF (NOT fnd_flex_keyval.validate_ccid(
              appl_short_name => 'SQLGL',
              key_flex_code => 'GL#',
              structure_number => x_coa_id,
              combination_id => x_ccid,
--              security => 'ENFORCE')) THEN
              security=>l_security_code)) THEN
      -- return something unlikely to be valid that the caller can check
      return ('=====#####=====');
    END IF;

    l_delimiter := fnd_flex_keyval.segment_delimiter;
    l_num_segs := fnd_flex_keyval.segment_count;
    l_descp := '';

    FOR i IN 1..l_num_segs LOOP
      IF i <> 1 THEN
        l_descp := l_descp || l_delimiter;
      END IF;
      l_descp := l_descp || fnd_flex_keyval.segment_description(i);
    END LOOP;

    return(l_descp);

  END Get_Concat_Description;


  FUNCTION get_qualifier_segnum(
                      x_key_flex_code        VARCHAR2,
                      x_chart_of_accounts_id NUMBER,
                      x_flex_qual_name       VARCHAR2
                      ) RETURN NUMBER IS
    l_seg_pos NUMBER;
    flag      BOOLEAN := FALSE;
  BEGIN
    flag := FND_FLEX_APIS.get_qualifier_segnum(
                                    101,
                                    x_key_flex_code,
                                    x_chart_of_accounts_id,
                                    x_flex_qual_name,
                                    l_seg_pos
                                    );

    IF (flag = FALSE) THEN
      RETURN 0;
    ELSE
      return l_seg_pos;
    END IF;
  END get_qualifier_segnum;


  FUNCTION get_validation_error_message(x_coa_id    NUMBER,
                                        x_ccid      NUMBER) RETURN VARCHAR IS
  BEGIN
    IF (NOT fnd_flex_keyval.validate_ccid(
              appl_short_name => 'SQLGL',
              key_flex_code => 'GL#',
              structure_number => x_coa_id,
              combination_id => x_ccid,
              security => 'ENFORCE')) THEN
      -- return the error message
      RETURN fnd_flex_keyval.error_message;
    END IF;

    RETURN NULL;

  END get_validation_error_message;

END gl_flexfields_pkg;

/
