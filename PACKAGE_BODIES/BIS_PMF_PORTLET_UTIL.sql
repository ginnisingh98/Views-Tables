--------------------------------------------------------
--  DDL for Package Body BIS_PMF_PORTLET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_PORTLET_UTIL" as
/* $Header: BISPDBPB.pls 120.0.12000000.2 2007/01/30 13:09:47 nkishore ship $ */

--==========================================================================+
PROCEDURE get_parent_id(
  p_view_name        IN VARCHAR2
 ,p_current_value_id IN VARCHAR2
 ,p_is_debug         IN BOOLEAN
 ,p_as_of_date       IN DATE
 ,p_is_date_present  IN BOOLEAN
 ,x_parent_id        OUT NOCOPY VARCHAR2
 ,x_debug_text       IN OUT NOCOPY VARCHAR2
) ;
--==========================================================================+
--    PROCEDURE
--       getValue
--
--    PURPOSE
--       For example, given
--         p_key => p2
--         p_parameters => p1=v1&p2=v2&p3=v3&p4=v4
--       This function will return
--         v2
--       If either p_key is null or p_parameters is null, return null
--       Ex:
--       SELECT BIS_PORTLET_PMREGION.getValue('p1','p1=v1&p2=v2&p3=v3&p4=v4') as value FROM dual;
--    PARAMETERS
--
--    HISTORY
--       11-DEC-2001 juwang Created.
--==========================================================================
FUNCTION getValue(
  p_key        IN VARCHAR2
 ,p_parameters IN VARCHAR2
 ,p_delimiter  IN VARCHAR2 := c_amp
) RETURN VARCHAR2

IS
  l_key VARCHAR2(2000);
  l_parameters VARCHAR2(2000);
  l_key_start NUMBER;
  l_value_start NUMBER;
  l_amp_start NUMBER;

  l_val VARCHAR2(2000);
BEGIN
  IF ( (p_key IS NULL) or (p_parameters IS NULL)) THEN

    RETURN NULL;
  END IF;

  l_key := UPPER(p_key);
  l_parameters := UPPER(p_parameters);
--  dbms_output.put_line('p_parameters='|| p_parameters);
  -- first occurance
  l_key_start := INSTRB(l_parameters, RTRIM(l_key)|| c_eq, 1);
--    dbms_output.put_line('l key start='||l_key_start);
  IF (l_key_start = 0) THEN -- key not found
    RETURN NULL;
  END IF;

  -- get the starting position of v2 in "p2=v2"
  l_value_start := l_key_start + LENGTHB(p_key)+1;  -- including c_eq
  l_amp_start :=  INSTRB(p_parameters, p_delimiter, l_value_start);


  IF (l_amp_start = 0) THEN -- the last one or key not found
    l_val := SUBSTRB(p_parameters, l_value_start);
  ELSE
    l_val := SUBSTRB(p_parameters, l_value_start, (l_amp_start - l_value_start));
  END IF;
  RETURN l_val;


EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END getValue;

--==========================================================================+
--    FUNCTION
--       isFunctionFormat
--
--    PURPOSE
--       This function checks if the given parameter is in function format.
--       That is, it is in single quote as following example:
--       'package_name.function_name()' or
--       'package_name.function_name'
--    PARAMETERS
--
--    HISTORY
--       11-DEC-2001 juwang Created.
--==========================================================================

FUNCTION isFunctionFormat(
  p_val IN VARCHAR2
) RETURN BOOLEAN
IS

  l_val VARCHAR2(2000);
  len NUMBER;
BEGIN

  l_val := RTRIM(p_val);
  IF ( l_val IS NULL) THEN
    RETURN FALSE;
  END IF;

  len := LENGTHB(l_val);

  IF ( len <= 2 ) THEN  -- return false if ''
    RETURN FALSE;
  END IF;


  -- checks if the first and last char is in single quote
  IF ( ( INSTRB(l_val, c_squote, 1) = 1   ) AND
     (INSTRB(l_val, c_squote, -1) = len ) ) THEN
     RETURN TRUE;
  END If;


  RETURN FALSE;

END isFunctionFormat;

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
  p_val         IN NUMBER
 ,p_format_mask IN VARCHAR2
  ) RETURN VARCHAR2
IS
  l_scale VARCHAR2(100);
BEGIN
  IF ( p_val IS NULL) THEN  -- should not go here
    RETURN BIS_UTILITIES_PVT.Get_FND_Message('BIS_NONE');
  END IF;

  IF ( p_format_mask IS NULL) THEN
    RETURN getAutoScaleValue(
      p_val => p_val
     ,p_number_scale_rec => NULL
     ,x_scale => l_scale
    );
  END IF;

  RETURN get_nls_numeric_format(p_val, p_format_mask);

END getFormatValue;

--============================================================
FUNCTION getFormatMask(
  p_val          IN NUMBER
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


--===========================================================

FUNCTION get_fnd_profile_value(
  p_fnd_profile_name IN VARCHAR2
 ,p_default          IN VARCHAR2 := NULL
) RETURN VARCHAR2
IS

BEGIN
  RETURN NVL(FND_PROFILE.Value_Specific(p_fnd_profile_name), p_default);

EXCEPTION
  WHEN OTHERS THEN
    RETURN p_default;
END get_fnd_profile_value;

--===========================================================
FUNCTION get_nls_numeric_format(
  p_val         IN NUMBER
 ,p_format_mask IN VARCHAR2
)RETURN VARCHAR2
IS

BEGIN
-- TRANSLATE() - If , and . are used in ak region flex field, it is replaced with G and D, so that nls numeric format
-- takes effect.
  RETURN ( TO_CHAR(p_val, TRANSLATE(p_format_mask, c_dc_number_format, c_dec_group_sep), 'NLS_NUMERIC_CHARACTERS = ' || get_fnd_profile_value('ICX_NUMERIC_CHARACTERS', c_dc_number_format)) );

EXCEPTION
  WHEN OTHERS THEN
    RETURN TO_CHAR(p_val);

END get_nls_numeric_format;

--=============================================================
-- Used for auto scaling

--=============================================================

FUNCTION getAutoScaleValue(
   p_val              IN NUMBER
  ,p_number_scale_rec IN number_scale_rec_type
  ,x_scale OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2
IS
  l_abs_val_round NUMBER;
BEGIN
  IF ( p_val IS NULL) THEN  -- should not go here
    RETURN BIS_UTILITIES_PVT.Get_FND_Message('BIS_NONE');
  END IF;

  l_abs_val_round := ROUND(ABS(p_val));

  IF ( l_abs_val_round >= c_ten_million_round ) THEN -- 9,999,499 is the last which is represented by thousand (K)
    x_scale := c_M;
    RETURN (get_nls_numeric_format(p_val/c_million, getFormatMask(p_val/c_million, FALSE)) || NVL(p_number_scale_rec.symbol_million, BIS_UTILITIES_PVT.Get_FND_Message(c_sym_million_msg)));

  ELSIF ( l_abs_val_round >= c_ten_thousand ) THEN -- (10K~9,999K)
    x_scale := c_K;
    RETURN (get_nls_numeric_format(p_val/c_thousand, c_auto_fmt) || NVL(p_number_scale_rec.symbol_thousand, BIS_UTILITIES_PVT.Get_FND_Message(c_sym_thousand_msg)));

  END IF;

  RETURN get_nls_numeric_format(p_val, c_auto_fmt);

END getAutoScaleValue;

--==========================================================================+
--    FUNCTION
--       get_pl_value
--
--    PURPOSE
--       This function is called when the value contains a pl/sql
--       function.  This function will execute this pl/sql function
--       and return the result of the pl/sql.  If it is not a
--       pl/sql, it will just return the value immediately as like
--       calling getValue().
--    PARAMETERS
--
--    HISTORY
--       11-DEC-2001 juwang Created.
--==========================================================================
FUNCTION get_pl_value(
  p_key        IN VARCHAR2
 ,p_parameters IN VARCHAR2
) RETURN VARCHAR2

IS
  l_val VARCHAR2(2000);
  l_func_call VARCHAR2(2000);

BEGIN
  l_val := RTRIM(getValue(p_key, p_parameters));

  -- check if this is a pl/sql function
  IF isFunctionFormat(l_val) THEN

    l_func_call := SUBSTRB(l_val, 2, LENGTHB(l_val)-2);
    RETURN exec(l_func_call);

  ELSE
    RETURN l_val;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
--dbms_output.put_line('in get_pl_value exception block');
    RETURN NULL;


END get_pl_value;

--==========================================================================+
--    FUNCTION
--       exec
--
--    PURPOSE
--    PARAMETERS
--
--    HISTORY
--       11-DEC-2001 juwang Created.
--==========================================================================
FUNCTION exec(
  p_call IN VARCHAR2
) RETURN VARCHAR2

IS
  l_val VARCHAR2(2000);
  l_cursor NUMBER;
  l_dummy NUMBER;
  l_stmt VARCHAR2(2000);

BEGIN
  IF ( p_call IS NULL) THEN
    RETURN NULL;
  END IF;

  IF ( LENGTHB(p_call) = 0) THEN -- handling '' case
    RETURN NULL;
  END IF;


  ----------------------------------------
  -- calling pl/sql now
  ----------------------------------------
-- Additional fix for 2378693 starts here

-- The call to DBMS_SQL is to be replace by native dynamic SQL
-- using execute immediate.

  l_stmt := 'SELECT ' || p_call || ' as value FROM dual';
  EXECUTE IMMEDIATE l_stmt INTO l_val;
  RETURN l_val;

/***
  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor, l_stmt, dbms_sql.native);
  dbms_sql.define_column(l_cursor, 1, l_val, 2000);
  IF dbms_sql.execute_and_fetch(l_cursor) > 0 THEN -- row returned
     dbms_sql.column_value(l_cursor, 1, l_val);

  ELSE -- no row returned
    l_val := NULL;
  END IF;

  dbms_sql.close_cursor(l_cursor);
  RETURN l_val;
*/
-- Additional fix for 2378693 ends here

EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('error='|| SQLERRM);
-- Fix for 2378693 starts here
/***
    IF dbms_sql.is_open(l_cursor) THEN
      dbms_sql.close_cursor(l_cursor);
    END IF;
*/
-- Fix for 2378693 ends here
    RETURN NULL;
END exec;


--==========================================================================+
--    FUNCTION
--       get_function_name
--
--    PURPOSE
--
--    PARAMETERS
--
--    HISTORY
--       11-DEC-2001 juwang Created.
--==========================================================================
FUNCTION get_function_name(
  p_reference_path IN VARCHAR2
) RETURN VARCHAR2 IS

  index1 NUMBER;
  index2 NUMBER;
  l_function_name VARCHAR2(30);
BEGIN


  index1 := INSTRB(p_reference_path,'_',1)+1;
  index2 := INSTRB(p_reference_path,'_', -1, 1); -- search backword
  l_function_name := SUBSTRB(SUBSTRB(p_reference_path, 1, index2-1), index1);

--dbms_output.put_line('func name='|| l_function_name);

  RETURN l_function_name;


EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_function_name;


--============================================================
FUNCTION has_demo_rows(
  p_plug_id IN pls_integer
) RETURN BOOLEAN IS

  l_num_rows NUMBER := 0;
  CURSOR c1 is
  SELECT count(1)
  FROM bis_pmf_populate_portlet bpp
  WHERE bpp.PLUG_ID = p_plug_id;

BEGIN

  OPEN c1;
  FETCH c1 INTO l_num_rows;
  CLOSE c1;

  IF ( l_num_rows > 0) THEN
    RETURN TRUE;
  END IF;
  RETURN FALSE;

EXCEPTION

  WHEN OTHERS THEN  -- if no such table exists
    IF c1%ISOPEN THEN
      CLOSE c1;
    END IF;
    RETURN FALSE;
END has_demo_rows;

--============================================================
FUNCTION is_demo_on
 RETURN BOOLEAN IS

  l_bis_env_val VARCHAR2(60);
BEGIN

  l_bis_env_val := FND_PROFILE.Value('BIS_ENVIRONMENT');
  IF ( l_bis_env_val IS NULL) THEN
    RETURN TRUE;
  ELSIF ( UPPER(l_bis_env_val) = 'DEMO') THEN
    RETURN TRUE;
  END IF;


  RETURN FALSE;

EXCEPTION

  WHEN OTHERS THEN
    RETURN FALSE;
END is_demo_on;


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


--===========================================================
FUNCTION has_customized_rows(
  p_plug_id IN PLS_INTEGER
 ,p_user_id IN PLS_INTEGER
 ,x_owner_user_id OUT NOCOPY PLS_INTEGER
) RETURN BOOLEAN

IS
  l_num_rows INTEGER;
  CURSOR c1 IS
    SELECT COUNT(1)
    FROM bis_user_ind_selections
    WHERE plug_id = p_plug_id
    AND   USER_ID = p_user_id;

  CURSOR cPOwner IS
    SELECT USER_ID
    FROM ICX_PORTLET_CUSTOMIZATIONS
    WHERE PLUG_ID = p_plug_id;

BEGIN

  OPEN c1;
  FETCH c1 INTO l_num_rows;
  CLOSE c1;
  IF ( l_num_rows > 0 ) THEN
    RETURN TRUE;
  ELSE
    OPEN cPOwner;
    FETCH cPOwner INTO x_owner_user_id;
    CLOSE cPOwner;

  END IF;

  RETURN FALSE;




EXCEPTION
  WHEN OTHERS THEN

    RETURN FALSE;

END has_customized_rows;


--===========================================================
FUNCTION is_authorized(
  p_cur_user_id     IN PLS_INTEGER
 ,p_target_level_id IN PLS_INTEGER
 ,x_resp_id         OUT NOCOPY VARCHAR2
) RETURN BOOLEAN

IS
  l_resp_id VARCHAR2(100);
  l_has_access INTEGER;
  CURSOR c1 IS
    SELECT distinct DECODE(b.user_id, NULL, 0, 1), e.responsibility_id
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
  FETCH c1 INTO l_has_access, l_resp_id;
  WHILE c1%FOUND LOOP
    IF ( l_has_access = 1 ) THEN
      CLOSE c1;
      x_resp_id := l_resp_id;
      RETURN TRUE;
    END IF;
    FETCH c1 INTO l_has_access, l_resp_id;
  END LOOP;

  CLOSE c1;
  RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
    IF c1%ISOPEN THEN CLOSE c1; END IF;
    RETURN FALSE;

END is_authorized;



--===========================================================
FUNCTION is_authorized(
  p_cur_user_id     IN PLS_INTEGER
 ,p_target_level_id IN PLS_INTEGER
) RETURN BOOLEAN

IS
  l_resp_id VARCHAR2(100);
  l_is_auth BOOLEAN := FALSE;
BEGIN
  l_is_auth := is_authorized(
    p_cur_user_id => p_cur_user_id
   ,p_target_level_id => p_target_level_id
   ,x_resp_id => l_resp_id);

  RETURN l_is_auth;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;

END is_authorized;


--===========================================================
--    FUNCTION
--       has_rows
--
--    PURPOSE
--       Returns TRUE if the owner of the portlet has customized
--       rows in bis_user_ind_selections.  Returns FALSE otherwise.
--    PARAMETERS
--
--    HISTORY
--       29-JAN-2002 juwang Created.
--===========================================================
FUNCTION has_rows(
  p_plug_id       IN PLS_INTEGER
 ,x_owner_user_id OUT NOCOPY PLS_INTEGER
) RETURN BOOLEAN

IS
  l_num_rows INTEGER;
  CURSOR c1 IS
    SELECT COUNT(1)
    FROM
      bis_user_ind_selections bu
     ,ICX_PORTLET_CUSTOMIZATIONS ipc
    WHERE ipc.plug_id = p_plug_id
    AND   bu.plug_id = ipc.plug_id
    AND   bu.user_id = ipc.user_id;

  CURSOR cPOwner IS
    SELECT USER_ID
    FROM ICX_PORTLET_CUSTOMIZATIONS
    WHERE PLUG_ID = p_plug_id;

BEGIN

  OPEN cPOwner;
  FETCH cPOwner INTO x_owner_user_id;
  CLOSE cPOwner;


  OPEN c1;
  FETCH c1 INTO l_num_rows;
  CLOSE c1;
  IF ( l_num_rows > 0 ) THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;




EXCEPTION
  WHEN OTHERS THEN

    RETURN FALSE;

END has_rows;



--===========================================================
PROCEDURE clean_user_ind_sel(
  p_plug_id IN NUMBER
)
IS


BEGIN
  -- deleting the non-existing target level id
  DELETE
  FROM BIS_USER_IND_SELECTIONS
  WHERE  PLUG_ID = p_plug_id
  AND TARGET_LEVEL_ID = FND_API.G_MISS_NUM;


  DELETE
  FROM BIS_USER_IND_SELECTIONS
  WHERE  PLUG_ID = p_plug_id
  AND TARGET_LEVEL_ID NOT IN
    ( SELECT TARGET_LEVEL_ID
      FROM BIS_TARGET_LEVELS
    );

EXCEPTION
  WHEN OTHERS THEN
    htp.p(SQLERRM);

END clean_user_ind_sel;


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
--
-- DO NOT CHANGE this API signature.  This is used by BISPPMRB.pls
--
FUNCTION getAKFormatValue(
  p_measure_id IN NUMBER
 ,p_val        IN NUMBER
  ) RETURN VARCHAR2
IS
  l_region_code VARCHAR2(30);
  l_attribute_code VARCHAR2(30);
  l_is_show_percent BOOLEAN;

BEGIN
--
-- DO NOT CHANGE this API signature.  This is used by BISPPMRB.pls
--

  BIS_PMF_PORTLET_UTIL.get_region_code( p_measure_id => p_measure_id
                  ,x_region_code => l_region_code
                  ,x_attribute_code  => l_attribute_code);

  RETURN BIS_PMF_PORTLET_UTIL.getAKFormatValue(
   p_measure_id =>  p_measure_id
  ,p_region_code => l_region_code
  ,p_attribute_code => l_attribute_code
  ,p_val => p_val
  );


END getAKFormatValue;


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
  p_measure_id     IN NUMBER
 ,x_region_code    OUT NOCOPY VARCHAR2
 ,x_attribute_code OUT NOCOPY VARCHAR2
)
IS

  l_msource_rec BIS_PMF_PORTLET_UTIL.measure_source_rec_type;


BEGIN
  get_region_code(
    p_measure_id => p_measure_id
   ,x_msource_rec => l_msource_rec
  );

  x_region_code := l_msource_rec.region_code;
  x_attribute_code  := l_msource_rec.region_attribute;

EXCEPTION
  WHEN OTHERS THEN
    x_region_code := NULL;
    x_attribute_code := NULL;
END get_region_code;



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
  p_measure_id  IN NUMBER
 ,x_msource_rec OUT NOCOPY BIS_PMF_PORTLET_UTIL.measure_source_rec_type
)
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

    l_comp_source           VARCHAR2(240) ;



BEGIN
  BIS_PMF_DEFINER_WRAPPER_PVT.Retrieve_Performance_Measure(
      P_MEASURE_ID =>  p_measure_id
     ,x_return_status => l_return_status
     ,x_msg_count => l_msg_count
     ,x_msg_data   => l_msg_data
     ,x_Measure_ID  => x_msource_rec.measure_id
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
     ,x_region_code    =>       x_msource_rec.region_code
     ,x_attribute_code      => x_msource_rec.region_attribute
     ,x_function_name         => x_msource_rec.function_name
     ,x_comparison_source     => l_comp_source
     ,x_increase_in_measure   => x_msource_rec.increase_in_measure
     ,x_enable_link           => x_msource_rec.enable_link --2440739
     );
  x_msource_rec.measure_id := p_measure_id;
  x_msource_rec.comp_region_code := SUBSTR(l_comp_source,1,(INSTR(l_comp_source,'.')-1));
  x_msource_rec.comp_region_attribute:=SUBSTR(l_comp_source,(INSTR(l_comp_source,'.')+1));

--  print('In get_region_code: x_region_code =' || x_region_code);
--  print('In get_region_code: l_comp_source =' || l_comp_source);

EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END get_region_code;



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
  p_measure_id     IN NUMBER
 ,p_region_code    IN VARCHAR2
 ,p_attribute_code IN VARCHAR2
 ,p_val            IN NUMBER
 ) RETURN VARCHAR2
IS

  l_display_format VARCHAR2(150);
  l_display_type VARCHAR2(150);
  l_scale VARCHAR2(100);
BEGIN

  IF ( p_val IS NULL) THEN  -- should not go here
    RETURN BIS_UTILITIES_PVT.Get_FND_Message('BIS_NONE');
  END IF;



  BIS_PMF_PORTLET_UTIL.get_ak_display_format(
     p_region_code => p_region_code
    ,p_attribute_code => p_attribute_code
    ,x_display_format => l_display_format
    ,x_display_type => l_display_type );

--2429318
  RETURN BIS_PMF_PORTLET_UTIL.get_formatted_value(
     p_val => p_val
    ,p_display_format => l_display_format
    ,p_display_type => l_display_type
    ,p_enable_auto_scaling => c_enable_auto_scale
    ,p_number_scale_rec => NULL
    ,x_scale => l_scale -- not used here
  );

END getAKFormatValue;


--====================================================================

FUNCTION get_formatted_value(
   p_val                 IN NUMBER
  ,p_display_format      IN VARCHAR2
  ,p_display_type        IN VARCHAR2
  ,p_enable_auto_scaling IN VARCHAR2
  ,p_number_scale_rec    IN number_scale_rec_type
  ,x_scale               OUT NOCOPY VARCHAR2
) RETURN VARCHAR2
IS
  l_km_val NUMBER;

BEGIN

  IF ( p_val IS NULL) THEN  -- should not go here --prob
    RETURN BIS_UTILITIES_PVT.Get_FND_Message('BIS_NONE');
  END IF;

  IF ( p_display_type = c_I ) THEN   -- Integer
    RETURN getFormatValue(p_val => p_val,
          p_format_mask => NVL(p_display_format, getFormatMask(p_val, FALSE)));

  ELSIF ( p_display_type = c_F ) THEN -- Float
    RETURN getFormatValue(p_val => p_val,
          p_format_mask => NVL(p_display_format, getFormatMask(p_val, TRUE)));

  ELSIF ( p_display_type = c_K ) THEN -- thousand
    l_km_val := (p_val/c_thousand);
    x_scale := c_K;
    RETURN getFormatValue(
        p_val => l_km_val
       ,p_format_mask => NVL(p_display_format,
                             getFormatMask(l_km_val, TRUE))) || NVL(p_number_scale_rec.symbol_thousand, BIS_UTILITIES_PVT.Get_FND_Message(c_sym_thousand_msg)); --c_K ;

  ELSIF ( p_display_type = c_M ) THEN  -- million
    l_km_val := (p_val/c_million);
    x_scale := c_M;
    RETURN getFormatValue(
        p_val => l_km_val
       ,p_format_mask => NVL(p_display_format,
                             getFormatMask(l_km_val, TRUE))) || NVL(p_number_scale_rec.symbol_million, BIS_UTILITIES_PVT.Get_FND_Message(c_sym_million_msg));--c_M ;

  ELSIF ( p_display_type = c_IP ) THEN   -- Integer Percent bug#2372033

    RETURN getFormatValue(p_val => p_val,
      p_format_mask => NVL(p_display_format, getFormatMask(p_val, FALSE))) || c_percent;

  ELSIF ( p_display_type = c_FP ) THEN -- Float Percent  bug#2372033
    RETURN getFormatValue(p_val => p_val,
      p_format_mask => NVL(p_display_format, getFormatMask(p_val, TRUE))) || c_percent;

  ELSIF (p_display_type = c_AS) THEN -- No auto scaling for rollover (p_enable_auto_scaling = 'N'). Also,auto scaling, when enabled by user. default is YES

    IF ( (NVL(p_enable_auto_scaling,'Y') = 'Y') AND (is_get_fnd_profile(p_fnd_profile_name => 'BIS_AUTO_FACTOR', p_default => 'Y')) ) THEN

      RETURN getAutoScaleValue(
		p_val => p_val
	       ,p_number_scale_rec => p_number_scale_rec
	       ,x_scale => x_scale
	     );
    ELSE -- Integer type with specified format/default if (a)profile off OR (b)rollover.

      RETURN getFormatValue(p_val => p_val
	     ,p_format_mask => NVL(p_display_format, getFormatMask(p_val, FALSE)));
    END IF;

  ELSE --2580762
    RETURN getFormatValue(p_val => p_val
	     ,p_format_mask => NVL(p_display_format, getFormatMask(p_val, FALSE)));

  END IF;

END get_formatted_value;


--===========================================================

FUNCTION is_get_fnd_profile(
  p_fnd_profile_name IN VARCHAR2
 ,p_default          IN VARCHAR2
) RETURN BOOLEAN
IS

BEGIN
  IF ( UPPER(NVL(FND_PROFILE.Value_Specific(p_fnd_profile_name),NVL(p_default,'N'))) = 'Y' ) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (UPPER(NVL(p_default,'N')) = 'Y') THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
END is_get_fnd_profile;

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
  p_region_code    IN VARCHAR2
 ,p_attribute_code IN VARCHAR2
 ,x_display_format OUT NOCOPY VARCHAR2
 ,x_display_type   OUT NOCOPY VARCHAR2
) IS

  CURSOR c_ak_item IS
    SELECT attribute7, attribute14
    FROM ak_region_items
    WHERE
        region_code = p_region_code
    AND attribute_code = p_attribute_code;

BEGIN

  IF ( (p_region_code IS NULL ) OR
       (p_attribute_code IS NULL ) ) THEN
    RETURN;
  END IF;

  OPEN c_ak_item;
  FETCH c_ak_item INTO x_display_format, x_display_type;
  CLOSE  c_ak_item;


EXCEPTION
  WHEN OTHERS THEN
    IF  c_ak_item%ISOPEN THEN
      CLOSE c_ak_item;
    END IF;
END get_ak_display_format;




--=============================================================
--
-- Returns the parent id given the id
--

PROCEDURE get_parent_id(
  p_view_name        IN VARCHAR2
 ,p_current_value_id IN VARCHAR2
 ,p_is_debug         IN BOOLEAN
 ,p_as_of_date       IN DATE
 ,p_is_date_present  IN BOOLEAN
 ,x_parent_id        OUT NOCOPY VARCHAR2
 ,x_debug_text       IN OUT NOCOPY VARCHAR2
)
IS
  l_parent_id VARCHAR2(500):= NULL;
  TYPE ref_cursor_type IS REF CURSOR;
  c_parent_id ref_cursor_type;
  l_sql VARCHAR2(32000) := NULL;
  l_sql_group VARCHAR2(2000) := NULL;
BEGIN
  l_sql_group := ' GROUP BY parent_id ';
  IF (c_parent_id%ISOPEN) THEN
    close c_parent_id;
  END IF;

  l_sql := ' SELECT parent_id FROM '|| p_view_name || ' WHERE id= :bind_id ';
  IF (p_is_date_present) THEN
    l_sql := l_sql || ' AND TRUNC(:bind_as_of_date) BETWEEN TRUNC(NVL(START_DATE, :bind_as_of_date)) AND TRUNC(NVL(END_DATE, :bind_as_of_date)) ' || l_sql_group;
    OPEN c_parent_id FOR l_sql USING p_current_value_id, p_as_of_date, p_as_of_date, p_as_of_date;
  ELSE
    l_sql := l_sql || l_sql_group;
    OPEN c_parent_id FOR l_sql USING p_current_value_id;
  END IF;

  LOOP
    FETCH c_parent_id INTO l_parent_id;

    EXIT WHEN c_parent_id%NOTFOUND;

    IF (l_parent_id <> p_current_value_id) THEN -- If the parent Id is other than its Id, then it has a parent
      IF ( p_is_debug) THEN
	add_debug_text(p_text => ' Has parent id=' || l_parent_id ,x_debug_text => x_debug_text);
      END IF;

      EXIT; -- the first one found is the parent.
    END IF;

  END LOOP;
  CLOSE c_parent_id;

  x_parent_id := l_parent_id; -- if parent id is same as id, then the same is returned, else first parent is returned

EXCEPTION
  WHEN OTHERS THEN
    IF ( ((SQLCODE = -904) OR (SQLCODE= -942)) AND p_is_debug) THEN
      add_debug_text(p_text => 'Error - Check if view: ' || p_view_name || ' exists or parent_id column exists ',x_debug_text => x_debug_text);
    ELSIF ( p_is_debug) THEN
      add_debug_text(p_text => 'Error occured getting parent id '|| p_current_value_id || '=>' || p_view_name,x_debug_text => x_debug_text);
    END IF;
    IF (c_parent_id%ISOPEN) THEN
      CLOSE c_parent_id;
    END IF;
END get_parent_id;


--============================================================
PROCEDURE add_debug_text(
  p_text IN VARCHAR
 ,x_debug_text IN OUT NOCOPY VARCHAR2
) IS

BEGIN
  x_debug_text := x_debug_text || ' <br> ' || p_text;

END add_debug_text;


--===========================================================
-- PURPOSE
-- Returns the parent id and parent value given the view and child id.
-- For a non-top mode, multiple records may be present with parent id same as child id.
-- These are filtered out and actual parent is returned.
-- For a top node, the parent returned is same as the child.
--================================================================
PROCEDURE get_parent_value(
  p_view_name        IN VARCHAR2
 ,p_current_value_id IN VARCHAR2
 ,p_as_of_date       IN DATE
 ,x_parent_id        OUT NOCOPY VARCHAR2
 ,x_parent_value     OUT NOCOPY VARCHAR2
)
IS
  l_debug_text  VARCHAR2(32000);
BEGIN
  get_parent_value(
    p_view_name => p_view_name
   ,p_current_value_id => p_current_value_id
   ,p_is_debug => FALSE
   ,p_as_of_date => p_as_of_date
   ,p_is_date_present => (p_as_of_date IS NOT NULL)
   ,x_parent_id => x_parent_id
   ,x_parent_value => x_parent_value
   ,x_debug_text => l_debug_text
  );
END get_parent_value;

--================================================================

PROCEDURE get_parent_value(
  p_view_name        IN VARCHAR2
 ,p_current_value_id IN VARCHAR2
 ,p_is_debug         IN BOOLEAN
 ,p_as_of_date       IN DATE
 ,p_is_date_present  IN BOOLEAN
 ,x_parent_id        OUT NOCOPY VARCHAR2
 ,x_parent_value     OUT NOCOPY VARCHAR2
 ,x_debug_text       IN OUT NOCOPY VARCHAR2
)
IS
  l_sql VARCHAR2(2000) := NULL;
BEGIN

  IF (p_view_name IS NOT NULL) THEN
    -- get parent id for this id
    get_parent_id(
      p_view_name        => p_view_name
     ,p_current_value_id => p_current_value_id
     ,p_is_debug         => p_is_debug
     ,p_as_of_date       => p_as_of_date
     ,p_is_date_present  => p_is_date_present
     ,x_parent_id        => x_parent_id -- OUT
     ,x_debug_text       => x_debug_text
    );
    IF ( p_is_debug) THEN
       add_debug_text (p_text => ' The parent id got is ' || x_parent_id, x_debug_text => x_debug_text);
    END IF;

    l_sql := ' SELECT value FROM '|| p_view_name || ' WHERE id= :bind_id and rownum < 2 GROUP BY value ';
    IF (x_parent_id IS NOT NULL) THEN
      EXECUTE IMMEDIATE l_sql INTO x_parent_value USING x_parent_id; -- OUT
    END IF;

  ELSE -- p_view_name IS NULL
    IF ( p_is_debug) THEN
       add_debug_text (p_text => ' View source for this short name is NULL ', x_debug_text => x_debug_text);
    END IF;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF ( p_is_debug) THEN
      add_debug_text(p_text => 'Error - no data found for '|| x_parent_id || '=>' || p_view_name, x_debug_text => x_debug_text);
    END IF;
    x_parent_id := NULL;
    x_parent_value := NULL;
  WHEN OTHERS THEN
    IF ( ((SQLCODE = -904) OR (SQLCODE= -942)) AND p_is_debug) THEN
      add_debug_text(p_text => 'Error - Check if view: ' || p_view_name || ' exists exists ',x_debug_text => x_debug_text);
    ELSIF ( p_is_debug) THEN
      add_debug_text(p_text => 'Error - getting parent '|| p_current_value_id || '=>' || p_view_name, x_debug_text => x_debug_text);
    END IF;
END get_parent_value;


--===========================================================

PROCEDURE get_rank_level_info(
  p_dim_level_sname      IN VARCHAR2
  ,p_is_debug            IN BOOLEAN
  ,x_view_name           OUT NOCOPY VARCHAR2
  ,x_is_pa_child_related OUT NOCOPY BOOLEAN
  ,x_is_date_present     OUT NOCOPY BOOLEAN
  ,x_debug_text          IN OUT NOCOPY VARCHAR2
)
IS

  l_view_name  bis_levels.level_values_view_name%TYPE;
  l_col_name VARCHAR2(500);
  l_sql VARCHAR2(32000);
  l_id_name VARCHAR2(2000);
  l_value_name VARCHAR2(2000);
  l_time_level VARCHAR2(2000);
  l_return_status VARCHAR2(2000);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_is_start_date BOOLEAN := FALSE;
  l_is_end_date BOOLEAN := FALSE;
  CURSOR c_column_names IS
    SELECT column_name FROM user_tab_columns
    WHERE table_name = l_view_name;

BEGIN
  x_is_date_present := FALSE;
  x_is_pa_child_related := FALSE;

  BIS_PMF_GET_DIMLEVELS_PVT.GET_DIMLEVEL_SELECT_STRING(
     p_DimLevelName         => p_dim_level_sname
    ,x_Select_String        => l_sql
    ,x_table_name           => l_view_name
    ,x_id_name              => l_id_name
    ,x_value_name           => l_value_name
    ,x_time_level           => l_time_level
    ,x_return_status        => l_return_status
    ,x_msg_count            => l_msg_count
    ,x_msg_data             => l_msg_data
  );

  x_view_name := l_view_name;
  IF (l_view_name IS NOT NULL) THEN

    IF (c_column_names%ISOPEN) THEN
      CLOSE c_column_names;
    END IF;

    OPEN c_column_names;
    LOOP
      FETCH c_column_names INTO l_col_name;
        EXIT WHEN c_column_names%NOTFOUND;
      IF (UPPER(l_col_name) = 'PARENT_ID') THEN
        x_is_pa_child_related := TRUE;
      ELSIF (UPPER(l_col_name) = 'START_DATE') THEN
        l_is_start_date := TRUE;
      ELSIF (UPPER(l_col_name) = 'END_DATE') THEN
        l_is_end_date := TRUE;
      END IF;
    END LOOP;
    CLOSE c_column_names ;

    IF (l_is_start_date AND l_is_end_date) THEN
      x_is_date_present := TRUE;
    END IF;

  ELSE
    IF (p_is_debug) THEN
      add_debug_text(
         p_text => ' Error, dimension level view name not exist '
        ,x_debug_text => x_debug_text
      );
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_is_date_present := FALSE;
    x_is_pa_child_related := FALSE;
    IF (c_column_names%ISOPEN) THEN
      CLOSE c_column_names;
    END IF;
    IF (p_is_debug) THEN
      add_debug_text(
         p_text => ' Error in getting rank level info '
        ,x_debug_text => x_debug_text
      );
    END IF;

END get_rank_level_info;

--===========================================================

PROCEDURE get_rank_level_info(
  p_dim_level_sname      IN VARCHAR2
 ,x_view_name           OUT NOCOPY VARCHAR2
 ,x_is_pa_child_related OUT NOCOPY VARCHAR2 -- 'Y' or 'N'
 ,x_is_date_present     OUT NOCOPY VARCHAR2 -- 'Y' or 'N'
)
IS
  l_debug_text          VARCHAR2(32000);
  l_is_pa_child_related BOOLEAN;
  l_is_date_present     BOOLEAN;
BEGIN
  get_rank_level_info(
    p_dim_level_sname => p_dim_level_sname
   ,p_is_debug => FALSE
   ,x_view_name => x_view_name
   ,x_is_pa_child_related => l_is_pa_child_related
   ,x_is_date_present => l_is_date_present
   ,x_debug_text => l_debug_text
  );

  IF (l_is_pa_child_related) THEN
    x_is_pa_child_related := 'Y';
  ELSE
    x_is_pa_child_related := 'N';
  END IF;

  IF (l_is_date_present) THEN
    x_is_date_present := 'Y';
  ELSE
    x_is_date_present := 'N';
  END IF;
END get_rank_level_info;


--===========================================================================================================

PROCEDURE retrieve_dim_level_value(
  p_dim_level_id          IN NUMBER
 ,p_dim_level_value_id    IN VARCHAR2
 ,x_dim_level_value_name  OUT NOCOPY VARCHAR2
 ,x_return_status         OUT NOCOPY VARCHAR2
)
IS
  l_dim_value_rec BIS_DIM_LEVEL_VALUE_PUB.dim_level_value_rec_type;
  l_dim_value_rec_p BIS_DIM_LEVEL_VALUE_PUB.dim_level_value_rec_type;
  l_error_tbl     BIS_UTILITIES_PUB.error_tbl_type;
BEGIN
  l_dim_value_rec.dimension_level_id := p_dim_level_id;
  l_dim_value_rec.dimension_level_value_id := p_dim_level_value_id;

  l_dim_value_rec_p := l_dim_value_rec;

  BIS_DIM_LEVEL_VALUE_PVT.dimensionx_id_to_value(
    p_api_version => 1.0
	 ,p_dim_level_value_rec => l_dim_value_rec_p
	 ,x_dim_level_value_rec => l_dim_value_rec
	 ,x_return_status => x_return_status
	 ,x_error_tbl => l_error_tbl
	);

  x_dim_level_value_name := l_dim_value_rec.dimension_level_value_name;
END retrieve_dim_level_value;
--===========================================================================================================
FUNCTION get_application_name(
  p_type       IN VARCHAR2
 ,p_parameters IN VARCHAR2
) RETURN VARCHAR2

IS
  l_val VARCHAR2(2000);
  l_key VARCHAR(100);
  l_code VARCHAR2(8);
  l_ret VARCHAR(100);
  l_pos INTEGER;
  l_pos_end INTEGER;

  CURSOR c1 is
  SELECT application_name
  FROM fnd_application_vl app
  WHERE app.application_short_name = upper(l_code);

BEGIN
  IF (upper(p_type) = 'PAGE') THEN
    l_key := 'pageName';
  ELSE
    IF (upper(p_type) = 'KPILIST') THEN
        l_key := 'pXMLDefinition';
    ELSE
        RETURN NULL;
    END IF;
  END IF;

  l_val := RTRIM(getValue(l_key, p_parameters));

  l_pos := INSTR(l_val, '/oracle/apps/');

  IF (l_pos > 0) THEN
  	-- bug3722756, get the length of the code
    l_pos_end := INSTR(l_val, '/', l_pos + 13, 1);
    l_code := SUBSTR(l_val, l_pos + 13, l_pos_end-(l_pos + 13) );
    OPEN c1;
    FETCH c1 INTO l_ret;
    CLOSE c1;
  ELSE
    l_ret := NULL;
  END IF;

  -- bug 3640563
  l_pos := INSTR(l_val, '/oracle/apps/bis/temp');
  IF (l_pos > 0) THEN
  	RETURN NULL;
  END IF;

  RETURN l_ret;

EXCEPTION
  WHEN OTHERS THEN
--dbms_output.put_line('in get_pl_value exception block');
    RETURN NULL;


END get_application_name;

--===========================================================================================================
FUNCTION get_application_id(
  p_type       IN VARCHAR2
 ,p_parameters IN VARCHAR2
) RETURN VARCHAR2

IS
  l_val VARCHAR2(2000);
  l_key VARCHAR(100);
  l_code VARCHAR2(8);
  l_ret INTEGER;
  l_pos INTEGER;
  l_pos_end INTEGER;

  CURSOR c1 is
  SELECT application_id
  FROM fnd_application_vl app
  WHERE app.application_short_name = upper(l_code);

BEGIN
  IF (upper(p_type) = 'PAGE') THEN
    l_key := 'pageName';
  ELSE
    IF (upper(p_type) = 'KPILIST') THEN
        l_key := 'pXMLDefinition';
    ELSE
        RETURN 0;
    END IF;
  END IF;

  l_val := RTRIM(getValue(l_key, p_parameters));

  l_pos := INSTR(l_val, '/oracle/apps/');

  IF (l_pos > 0) THEN
    -- bug3722756, get the length of the code
    l_pos_end := INSTR(l_val, '/', l_pos + 13, 1);
    l_code := SUBSTR(l_val, l_pos + 13, l_pos_end-(l_pos+13) );
    OPEN c1;
    FETCH c1 INTO l_ret;
    CLOSE c1;
  ELSE
    l_ret := 0;
  END IF;

  l_pos := INSTR(l_val, '/oracle/apps/bis/temp');
  IF (l_pos > 0) THEN
  	RETURN 0;
  END IF;

  RETURN l_ret;

EXCEPTION
  WHEN OTHERS THEN
--dbms_output.put_line('in get_pl_value exception block');
    RETURN 0;


END get_application_id;


--===========================================================================================================

END BIS_PMF_PORTLET_UTIL;

/
