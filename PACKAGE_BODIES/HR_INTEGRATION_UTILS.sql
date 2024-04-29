--------------------------------------------------------
--  DDL for Package Body HR_INTEGRATION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_INTEGRATION_UTILS" AS
/* $Header: hrintutl.pkb 120.3 2008/02/28 08:12:57 dbansal ship $ */
--
--
--
--
----$ Store form name in global variable to be created as a parameter along with
-- where and extra where params when an integrator is launched from forms
g_form_name varchar2(20);
--
-- ---------------------------------------------------------------------------
-- |------------------------< intg_resp_chk >--------------------------------|
-- ---------------------------------------------------------------------------
--
-- Description:
--  Check the Integrator/Responsibility associations table, and if
--   integrator exists in the table - restrict by resp_id
--   integrator does not exist in the table - do not restrict by resp_id
--
-- ---------------------------------------------------------------------------
FUNCTION intg_resp_chk(p_intg_code IN varchar2) RETURN boolean IS
--
  CURSOR csr_chk_resp IS
    SELECT resp_application_id, responsibility_id
      FROM hr_adi_intg_resp
     WHERE intg_application_id || ':' || integrator_code = p_intg_code;
--
  l_curr_resp_id     number := fnd_global.resp_id;
  l_curr_resp_app_id number := fnd_global.resp_appl_id;
  l_found            boolean := false;
  l_count            number := 0;
--
BEGIN
  --
  FOR c1 IN csr_chk_resp LOOP
      -- An entry exists for this integrator, so restrict by resp_id
      l_count := l_count +1;
      IF not l_found THEN
          --
          IF ((c1.resp_application_id = l_curr_resp_app_id) AND
              (c1.responsibility_id = l_curr_resp_id)) THEN
             l_found := TRUE;
          END IF;
          --
       END IF;
  END LOOP;
  --
  IF l_count = 0 THEN
     --
     -- No entries in this table for this integrator, do not restrict
     RETURN TRUE;
  ELSE
     -- Return True/False depending on appropriate resp matching
     RETURN l_found;
  END IF;
END intg_resp_chk;
--
FUNCTION fetch_other_params(p_form_name IN varchar2) RETURN varchar2 IS
--
  TYPE IntCurTyp IS REF CURSOR;
  l_int_csr      IntCurTyp;
  l_other_params varchar2(2000) := 'bne:integrator=';
  l_int_code     varchar2(60);
  l_int_count    integer := 0;
--
BEGIN
  --
  -- Open cursor
  OPEN l_int_csr FOR
    'SELECT pli.string_value ' ||
    '  FROM bne_param_lists_tl  plt ' ||
    '     , bne_param_list_items pli ' ||
    ' WHERE plt.application_id = 800 ' ||
    '   AND plt.user_name = ''' || p_form_name || ''' ' ||
    '   AND pli.application_id = plt.application_id ' ||
    '   AND pli.param_list_code = plt.param_list_code ';

    -- '  FROM bne_param_list_tl plt ' ||
    -- '     , bne_param_list_items pli ' ||
    -- '     , bne_object_properties_tl opt ' ||
    -- '     , bne_integrators i ' ||
    -- ' WHERE upper(plt.param_list_name) = ''' || p_form_name ||
    -- ''' ' ||
    -- '   AND plt.param_list_id = pli.param_list_id ' ||
    -- '   AND upper(pli.string_value) = upper(opt.value) ' ||
    -- '   AND opt.object_id = i.integrator_id ';
  --
  LOOP
     --
     FETCH l_int_csr INTO l_int_code;
     EXIT WHEN l_int_csr%NOTFOUND;
     --
     IF intg_resp_chk(l_int_code) THEN
        IF l_int_count <> 0 THEN
           --
           l_other_params := l_other_params || ',';
           --
        END IF;
        --
        l_other_params := l_other_params || l_int_code;
        l_int_count := l_int_count + 1;
        --
     END IF;
  END LOOP;
  --
  CLOSE l_int_csr;
  --
  IF l_int_count = 0 THEN
     l_other_params := 'ERROR';
  ELSE
     l_other_params := l_other_params||'&'||'bne:noreview=true' ;
  END IF;
  --
    --$ Assign value to global variable
  g_form_name := p_form_name;

  RETURN l_other_params;
  --
END fetch_other_params;
--
FUNCTION fetch_other_letter_params(p_letter IN varchar2) RETURN varchar2 IS
--
  TYPE IntCurTyp IS REF CURSOR;
  l_int_csr      IntCurTyp;
  l_other_params varchar2(2000) := 'bne:integrator=';
  l_int_code     varchar2(60);
  l_int_count    integer := 0;
--
BEGIN
  --
  -- Open cursor
  --OPEN l_int_csr FOR
    --'SELECT i.integrator_id ' ||
    --'  FROM bne_param_list_tl plt ' ||
    --'     , bne_param_list_items pli ' ||
    --'     , bne_object_properties_tl opt1 ' ||
    --'     , bne_integrators i ' ||
    --'     , bne_layouts bl ' ||
    --'     , bne_object_properties_tl opt2 ' ||
    --' WHERE upper(plt.param_list_name) = ''LETTER'' ' ||
    --'   AND plt.param_list_id = pli.param_list_id ' ||
    --'   AND upper(pli.string_value) = upper(opt1.value) ' ||
    --'   AND opt1.object_id = i.integrator_id ' ||
    --'   AND i.integrator_id = bl.integrator_id ' ||
    --'   AND bl.layout_id = opt2.object_id ' ||
    --'   AND upper(opt2.value) = upper(''' || p_letter || ''')';
  hr_utility.set_location('L:'||p_letter,5);
  OPEN l_int_csr FOR
    'SELECT pli.string_value ' ||
    '  FROM bne_param_lists_b plb ' ||
    '     , bne_param_list_items pli ' ||
    '     , bne_layouts_b lb ' ||
    '     , bne_layouts_tl lt ' ||
    ' WHERE plb.application_id = 800 ' ||
    '   AND plb.param_list_code = ''HR_LETTER'' ' ||
    '   AND pli.application_id = plb.application_id ' ||
    '   AND pli.param_list_code = plb.param_list_code ' ||
    '   AND lb.integrator_app_id = ' ||
    '       substr(pli.string_value,0,instr(pli.string_value,'':'')-1) ' ||
    '   AND lb.integrator_code = ' ||
    '       substr(pli.string_value,instr(pli.string_value,'':'')+1) ' ||
    '   AND lt.application_id = lb.application_id ' ||
    '   AND lt.layout_code = lb.layout_code ' ||
    '   AND lt.user_name = ''' || p_letter || ''' ';
  --
  LOOP
     --
     FETCH l_int_csr INTO l_int_code;
     EXIT WHEN l_int_csr%NOTFOUND;
     --
     IF intg_resp_chk(l_int_code) THEN
        --
        IF l_int_count <> 0 THEN
           --
           l_other_params := l_other_params || ',';
           --
        END IF;
        --
        l_other_params := l_other_params || l_int_code;
        l_int_count := l_int_count + 1;
        --
     END IF;
  END LOOP;
  --
  CLOSE l_int_csr;
  --
  IF l_int_count = 0 THEN
     l_other_params := 'ERROR';
  END IF;
  --
  --$ Assign value to global variable
  g_form_name := 'HR_LETTER';

  RETURN l_other_params;
  --
END fetch_other_letter_params;
--
FUNCTION store_sql(p_sql IN varchar2, p_date IN varchar2) RETURN varchar2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
--
--$ Pass form name as an additional argument to add into param list
  l_sql  varchar2(4000) := 'begin ' ||
                           '  :1 := hr_passed_sql.get_passed_sql_id(:2,:3,:4); ' ||
                           'end;';
  l_return_code varchar2(60);
--
BEGIN
hr_utility.trace('Form_name ='||g_form_name||'--');
  EXECUTE IMMEDIATE l_sql
    USING out l_return_code,
          in  p_sql,
          in  p_date,
          in  g_form_name;
  COMMIT;
  RETURN l_return_code;
END store_sql;
--
-- -------------------------------------------------------------------------
-- |----------------------< add_or_update_session >------------------------|
-- -------------------------------------------------------------------------
PROCEDURE add_or_update_session(p_sess_date in date) is
  PRAGMA AUTONOMOUS_TRANSACTION;
--
CURSOR csr_find_row IS
  SELECT 'Y'
    FROM fnd_sessions
   WHERE session_id = userenv('sessionid');
--
l_exists varchar2(1);
BEGIN
  --
--  hr_utility.trace_on;
  hr_utility.set_location('ADD_OR_UPDATE_SESSION',10);
  --
  open csr_find_row;
  fetch csr_find_row into l_exists;
  IF csr_find_row%NOTFOUND THEN
     --
     hr_utility.set_location('ADD_OR_UPDATE_SESSION - NO ROW',20);
     --
     -- Row does not exist, so add
     INSERT INTO fnd_sessions (session_id, effective_date)
     VALUES (userenv('sessionid'), p_sess_date);
     --
     hr_utility.set_location('ADD_OR_UPDATE_SESSION - ROW ADDED',30);
     --
  ELSE
     --
     hr_utility.set_location('ADD_OR_UPDATE_SESSION - ROW EXISTS',40);
     -- Row exists, so update date
     UPDATE fnd_sessions
        SET effective_date = p_sess_date
      WHERE session_id = userenv('sessionid');
     hr_utility.set_location('ADD_OR_UPDATE_SESSION - ROW UPDATE',50);
     --
  END IF;
  close csr_find_row;
  --
  commit;
--  hr_utility.trace_off;
END add_or_update_session;
--
-- -------------------------------------------------------------------------
-- |------------------< add_hr_param_list_to_content >---------------------|
-- -------------------------------------------------------------------------
PROCEDURE add_hr_param_list_to_content(p_application_id in number
                                      ,p_content_code   in varchar2) IS
--
l_param_list_name varchar2(30) := 'HR_STANDARD';
l_update_sql      varchar2(2000);
--
BEGIN
  --
  l_update_sql :=
    'BEGIN ' ||
    'UPDATE BNE_CONTENTS_B ' ||
    '  SET param_list_app_id = 800' ||
    '      , param_list_code = :1 ' ||
    ' WHERE application_id = :2 ' ||
    '   AND content_code = :3 ; ' ||
    'END;';
  --
  EXECUTE IMMEDIATE l_update_sql
    USING IN l_param_list_name,
          IN to_char(p_application_id),
          IN p_content_code;
  --
END add_hr_param_list_to_content;
--
-- -------------------------------------------------------------------------
-- |-------------------< add_hr_upload_list_to_integ >---------------------|
-- -------------------------------------------------------------------------
PROCEDURE add_hr_upload_list_to_integ(p_application_id in number
                                     ,p_integrator_code   in varchar2) IS
--
l_param_list_name varchar2(30) := 'HR_UPLOAD';
l_update_sql      varchar2(2000);
--
BEGIN
  --
  l_update_sql :=
    'BEGIN ' ||
    'UPDATE BNE_INTEGRATORS_B ' ||
    '  SET upload_param_list_app_id = 800 ' ||
    '      , upload_param_list_code = :1 ' ||
    '      , upload_serv_param_list_app_id = 231 ' ||
    '      , upload_serv_param_list_code = ''UPL_SERV_JNLS'' ' ||
    ' WHERE application_id = :2 ' ||
    '   AND integrator_code = :3 ; ' ||
    'END;';
  --
  EXECUTE IMMEDIATE l_update_sql
    USING IN l_param_list_name,
          IN to_char(p_application_id),
          IN p_integrator_code;
  --
END add_hr_upload_list_to_integ;
--
-- ------------------------------------------------------------------------
-- | -----------------< register_integrator_to_form >---------------------|
-- ------------------------------------------------------------------------
PROCEDURE register_integrator_to_form(p_integrator    in varchar2
                                     ,p_form_name     in varchar2) IS
--
l_plsql      varchar2(2000);
l_desc_value varchar2(100) := 'Integrator for use on this form';
l_id             number;
l_app_id         number;
l_list_code      varchar2(60);
l_list_key       varchar2(60);
l_persistent     varchar2(1) := 'Y';
l_count          number;
--
BEGIN
  l_list_code := 'HR_' || p_form_name;
  l_app_id := 800;

  l_plsql := 'BEGIN ' ||
             '  SELECT count(*) ' ||
             '    INTO :1 ' ||
             '    FROM bne_param_lists_tl ' ||
             '   WHERE user_name = :2 ' ||
             '     AND param_list_code = :3 ' ||
             '     AND application_id = 800; ' ||
             'END;';
  --
  EXECUTE IMMEDIATE l_plsql
    USING out l_count,
          in  p_form_name,
          in  l_list_code;
  --
  IF l_count = 0 THEN
     --
     -- Need to create Param List
     --
     -- Create the Form Parameter List
     l_plsql :=
        'BEGIN ' ||
        '  :1 := BNE_PARAMETER_UTILS.CREATE_PARAM_LIST_ALL' ||
        '          (p_application_id    => 800 ' ||
        '          ,p_param_list_code   => :2 ' ||
        '          ,p_persistent        => :3 ' ||
        '          ,p_comments          => null ' ||
        '          ,p_attribute_app_id  => null ' ||
        '          ,p_attribute_code    => null ' ||
        '          ,p_list_resolver     => null ' ||
        '          ,p_prompt_left       => null ' ||
        '          ,p_prompt_above      => :4 ' ||
        '          ,p_user_name         => :5 ' ||
        '          ,p_user_tip          => null ' ||
        '          ); ' ||
        'END; ';
     --
     EXECUTE IMMEDIATE l_plsql
     USING out l_list_key,
           IN l_list_code,
           IN l_persistent,
           IN p_form_name || ' Integrators ',
           IN p_form_name;
     --
  END IF;
  --
  --
  l_plsql := 'BEGIN ' ||
             '	:1 := BNE_PARAMETER_UTILS.CREATE_LIST_ITEMS_ALL ' ||
             '          (p_application_id => :2  ' ||
             '          ,p_param_list_code => :3 ' ||
             '          ,p_param_defn_app_id => null ' ||
             '          ,p_param_defn_code => null ' ||
             '          ,p_param_name => ''' || 'Integrator' || ''' ' ||
             '          ,p_attribute_app_id => null ' ||
             '          ,p_attribute_code   => null ' ||
             '          ,p_string_val       => :4  ' ||
             '          ,p_date_val         => null ' ||
             '          ,p_number_val    => null ' ||
             '          ,p_boolean_val   => null ' ||
             '          ,p_formula       => null ' ||
             '          ,p_desc_val      => :5 ' ||
             '          ); ' ||
             ' END;';
  --
  EXECUTE IMMEDIATE l_plsql
    USING out l_id,
          IN to_char(l_app_id),
          IN l_list_code,
          IN p_integrator,
          IN l_desc_value;
  --
END register_integrator_to_form;
--
-- ------------------------------------------------------------------------
-- | ---------------------< process_where_clause >------------------------|
-- ------------------------------------------------------------------------
FUNCTION process_where_clause(p_where_clause IN varchar2) RETURN varchar2 IS
--
  l_base_table_temp varchar2(100);
  l_base_table_alias varchar2(100);
  l_base_table varchar2(30);
  l_temp_sql   varchar2(4000);
  l_return_sql varchar2(4000);
  l_upper_sql  varchar2(4000);
  l_start      integer;
  l_pos        integer;
--
BEGIN
  --
  -- Determine base table
  l_base_table_temp := substr(p_where_clause, 7,
                         instr(upper(p_where_clause),'WHERE')-8);
  --
  -- Check for Alias
  IF (instr(l_base_table_temp, ' ') > 0) THEN
     --
     -- Alias found
     l_base_table := substr(l_base_table_temp,1,instr(l_base_table_temp,' ')-1);
     l_base_table_alias := substr(l_base_table_temp,instr(l_base_table_temp,' ')+1);
     --
  ELSE
     --
     -- No alias.
     l_base_table := l_base_table_temp;
     l_base_table_alias := '';
  END IF;
  --
  -- build up WHERE clause
  l_temp_sql := substr(p_where_clause, instr(upper(p_where_clause),'WHERE'));
  l_temp_sql := ' ADI1 ' || l_temp_sql;
  --
  -- Replace table name, which may be in upper or lower case
  l_upper_sql := upper(l_temp_sql);
  l_start := 1;
  --
  WHILE (instr(l_upper_sql,upper(l_base_table)|| '.',l_start) > 0) LOOP
  --
     l_pos := instr(l_upper_sql,upper(l_base_table) || '.',l_start);
     hr_utility.set_location('Found at: ' || l_pos,10);
     --
     l_temp_sql := substr(l_temp_sql,1,l_pos-1) || 'ADI1.' ||
                   substr(l_temp_sql,l_pos + length(l_base_table || '.'));
     hr_utility.set_location('replaced',11);
     --
     l_upper_sql := upper(l_temp_sql);
     --
     -- l_start := l_pos + length(l_base_table || '.');
     -- hr_utility.set_location('start:'||l_start,12);
     --
  END LOOP;
  --
  -- replace Alias which may be in upper or lower case
  l_upper_sql := upper(l_temp_sql);
  l_start := 1;
  --
  WHILE (instr(l_upper_sql, ' ' || upper(l_base_table_alias) || '.', l_start) > 0) LOOP
    --
    l_pos := instr(l_upper_sql, ' '||upper(l_base_table_alias) || '.', l_start);
    hr_utility.set_location('Alias found at: ' || l_pos,13);
    --
    l_temp_sql := substr(l_temp_sql,1,l_pos-1) || ' ADI1.' ||
                  substr(l_temp_sql,l_pos + length(' '||l_base_table_alias||'.'));
    hr_utility.set_location('Alias replaced',14);
    --
    l_upper_sql := upper(l_temp_sql);
    --
  END LOOP;
  --
  -- replace Alias which may be in upper or lower case
  l_upper_sql := upper(l_temp_sql);
  l_start := 1;
  --
  WHILE (instr(l_upper_sql, '(' || upper(l_base_table_alias) || '.', l_start) > 0) LOOP
    --
    l_pos := instr(l_upper_sql, '('||upper(l_base_table_alias) || '.', l_start);
    hr_utility.set_location('Alias found at: ' || l_pos,13);
    --
    l_temp_sql := substr(l_temp_sql,1,l_pos-1) || '(ADI1.' ||
                  substr(l_temp_sql,l_pos + length('('||l_base_table_alias||'.'));
    hr_utility.set_location('Alias replaced',14);
    --
    l_upper_sql := upper(l_temp_sql);
    --
  END LOOP;
  --
  -- l_return_sql := replace(upper(l_temp_sql),upper(l_base_table)||'.','ADI1.');
  l_return_sql := l_temp_sql;
  --
  -- Return modified WHERE clause
  --
  RETURN l_return_sql;
  --
END process_where_clause;
--
-- -------------------------------------------------------------------------
-- |-------------------< create_param_list_for_content >-------------------|
-- -------------------------------------------------------------------------
PROCEDURE create_param_list_for_content
  (p_content_code     in     varchar
  ,p_application_id   in     number
  ,p_param_list_code     out NOCOPY varchar2) IS
  --
  TYPE CSR_TYP IS REF CURSOR;
  csr_int CSR_TYP;
  --
  -- Local variables
  l_param_list_code varchar2(30);
  l_attribute_code  varchar2(30);
  l_persistent      varchar2(1) := 'Y';
  l_prompt_above    varchar2(240):= 'Download parameters';
  l_list_name       varchar2(240);
  l_list_key        varchar2(30);
  l_sequence        number;
  l_param_defn_code varchar2(30);
  l_plsql           varchar2(4000);
  --
BEGIN
  --
  --
  l_param_list_code := substr(p_content_code, 1, 27) || '_PL';
  --
  -- Check if a param list already exists, if so, return param list code
  --
  OPEN csr_int FOR
    'SELECT param_list_code ' ||
    '  FROM bne_param_lists_b ' ||
    ' WHERE param_list_code = ''' || l_param_list_code || ''' ' ||
    '   AND application_id  = ' || p_application_id || ' ';
  --
  FETCH csr_int INTO l_param_list_code;
  --
  IF csr_int%NOTFOUND THEN
    -- Create Param List
    --
    l_list_name    := l_prompt_above || ': ' || l_param_list_code;
    l_prompt_above := fnd_message.get_string('PER','HR_DOWNLOAD_PARAM_LABEL');
    --
    l_plsql := 'BEGIN ' ||
               '  :1 := BNE_PARAMETER_UTILS.CREATE_PARAM_LIST_ALL' ||
               '          (p_application_id    => :2 ' ||
               '          ,p_param_list_code   => :3 ' ||
               '          ,p_persistent        => :4 ' ||
               '          ,p_comments          => null ' ||
               '          ,p_attribute_app_id  => null ' ||
               '          ,p_attribute_code    => null ' ||
               '          ,p_list_resolver     => null ' ||
               '          ,p_prompt_left       => null ' ||
               '          ,p_prompt_above      => :5 ' ||
               '          ,p_user_name         => :6 ' ||
               '          ,p_user_tip          => null ' ||
               '          ); ' ||
               'END; ';
    --
    EXECUTE IMMEDIATE l_plsql
      USING out l_list_key,
            IN p_application_id,
            IN l_param_list_code,
            IN l_persistent,
            IN l_prompt_above,
            IN l_list_name;
    --
    --  Create 3 param list items for this param list
    --    1. hr:sessionDate
    --    2. hr:where
    --    3. hr:extra
    --
    l_param_defn_code := 'HR_STANDARD_SESS_DATE';
    l_attribute_code  := 'HR_STANDARD_NO_SAVE';
    --
    l_plsql := 'BEGIN ' ||
               '  :1 := BNE_PARAMETER_UTILS.CREATE_LIST_ITEMS_ALL' ||
               '          (p_application_id    => :2 ' ||
               '          ,p_param_list_code   => :3 ' ||
               '          ,p_param_defn_app_id => 800 ' ||
               '          ,p_param_defn_code   => :4 ' ||
               '          ,p_param_name        => ''hr:sessionDate'' ' ||
               '          ,p_attribute_app_id  => 800 ' ||
               '          ,p_attribute_code    => :5 ' ||
               '          ,p_string_val        => '''' ' ||
               '          ,p_date_val          => '''' ' ||
               '          ,p_number_val        => '''' ' ||
               '          ,p_boolean_val       => '''' ' ||
               '          ,p_formula           => '''' ' ||
               '          ,p_desc_val          => '''' ' ||
               '          ); ' ||
               'END; ';
    --
    EXECUTE IMMEDIATE l_plsql
      USING out l_sequence,
            IN p_application_id,
            IN l_param_list_code,
            IN l_param_defn_code,
            IN l_attribute_code;
    --
    l_param_defn_code := 'HR_STANDARD_WHERE';
    l_attribute_code  := 'HR_STANDARD_NO_SAVE';
    --
    l_plsql := 'BEGIN ' ||
               '  :1 := BNE_PARAMETER_UTILS.CREATE_LIST_ITEMS_ALL' ||
               '          (p_application_id    => :2 ' ||
               '          ,p_param_list_code   => :3 ' ||
               '          ,p_param_defn_app_id => 800 ' ||
               '          ,p_param_defn_code   => :4 ' ||
               '          ,p_param_name        => ''hr:where'' ' ||
               '          ,p_attribute_app_id  => 800 ' ||
               '          ,p_attribute_code    => :5 ' ||
               '          ,p_string_val        => '''' ' ||
               '          ,p_date_val          => '''' ' ||
               '          ,p_number_val        => '''' ' ||
               '          ,p_boolean_val       => '''' ' ||
               '          ,p_formula           => '''' ' ||
               '          ,p_desc_val          => '''' ' ||
               '          ); ' ||
               'END; ';
    --
    EXECUTE IMMEDIATE l_plsql
      USING out l_sequence,
            IN p_application_id,
            IN l_param_list_code,
            IN l_param_defn_code,
            IN l_attribute_code;
    --
    l_param_defn_code := 'HR_STANDARD_EXTRA';
    l_attribute_code  := 'HR_STANDARD_NO_SAVE';
    --
    l_plsql := 'BEGIN ' ||
               '  :1 := BNE_PARAMETER_UTILS.CREATE_LIST_ITEMS_ALL' ||
               '          (p_application_id    => :2 ' ||
               '          ,p_param_list_code   => :3 ' ||
               '          ,p_param_defn_app_id => 800 ' ||
               '          ,p_param_defn_code   => :4 ' ||
               '          ,p_param_name        => ''hr:extra'' ' ||
               '          ,p_attribute_app_id  => 800 ' ||
               '          ,p_attribute_code    => :5 ' ||
               '          ,p_string_val        => '''' ' ||
               '          ,p_date_val          => '''' ' ||
               '          ,p_number_val        => '''' ' ||
               '          ,p_boolean_val       => '''' ' ||
               '          ,p_formula           => '''' ' ||
               '          ,p_desc_val          => '''' ' ||
               '          ); ' ||
               'END; ';
    --
    EXECUTE IMMEDIATE l_plsql
      USING out l_sequence,
            IN p_application_id,
            IN l_param_list_code,
            IN l_param_defn_code,
            IN l_attribute_code;
    --
  END IF;
  CLOSE csr_int;
  --
  -- Return param list code
  p_param_list_code := l_param_list_code;
  --
END create_param_list_for_content;
--
-- -------------------------------------------------------------------------
-- |----------------------< create_param_list_item >-----------------------|
-- -------------------------------------------------------------------------
PROCEDURE create_param_list_item
  (p_param_list_code    in varchar2
  ,p_application_id     in number
  ,p_param_name         in varchar2
  ,p_param_type         in number
  ,p_param_prompt       in varchar2) IS
  --
  -- Local variable
  l_param_defn_code     varchar2(30);
  l_return_code         varchar2(30);
  l_attribute_code      varchar2(30);
  l_plsql               varchar2(4000);
  l_default_string      varchar2(10) := '';
  l_max_size            number := 20;
  l_display_size        number := 10;
  l_format_mask         varchar2(10);
  l_sequence            number;
  --
BEGIN
  --
  -- Determine if a param defn already exists
  --
  l_plsql := 'BEGIN ' ||
             '  :1 := BNE_PARAMETER_UTILS.GET_PARAM_DEFN_ID ' ||
             '          (P_APPLICATION_ID  => :2 ' ||
             '          ,P_PARAM_DEFN_NAME => :3 ' ||
             '          ,P_PARAM_SOURCE    => ''HR:Download'' ' ||
             '          ); ' ||
             'END; ';
  --
  EXECUTE IMMEDIATE l_plsql
    USING out l_param_defn_code,
          IN p_application_id,
          IN p_param_name;
  --
  IF l_param_defn_code IS NULL THEN
     --
     -- Create parameter definition
     --
     l_param_defn_code := upper(replace(p_param_name,':','_'));
     --
     IF p_param_type = 1 THEN
        l_default_string := '%';
        l_max_size := 80;
        l_display_size := 30;
     ELSIF p_param_type = 3 THEN
        l_format_mask := 'yyyy/MM/dd';
     END IF;
     --
     l_plsql := 'BEGIN ' ||
                ' :1 := BNE_PARAMETER_UTILS.CREATE_PARAM_ALL ' ||
                '         (P_APPLICATION_ID   => :2 ' ||
                '         ,P_PARAM_CODE       => :3 ' ||
                '         ,P_PARAM_NAME       => :4 ' ||
                '         ,P_PARAM_SOURCE     => ''HR:Download'' ' ||
                '         ,P_CATEGORY         => 5 ' ||
                '         ,P_DATA_TYPE        => :5 ' ||
                '         ,P_ATTRIBUTE_APP_ID => '''' ' ||
                '         ,P_ATTRIBUTE_CODE   => '''' ' ||
                '         ,P_PARAM_RESOLVER   => '''' ' ||
                '         ,P_REQUIRED         => ''N'' ' ||
                '         ,P_VISIBLE          => ''Y'' ' ||
                '         ,P_MODIFYABLE       => ''Y'' ' ||
                '         ,P_DEFAULT_STRING   => :6 ' ||
                '         ,P_DEFAULT_DATE     => '''' ' ||
                '         ,P_DEFAULT_NUM      => '''' ' ||
                '         ,P_DEFAULT_BOOLEAN  => '''' ' ||
                '         ,P_DEFAULT_FORMULA  => '''' ' ||
                '         ,P_VAL_TYPE         => 1 ' ||
                '         ,P_VAL_VALUE        => '''' ' ||
                '         ,P_MAXIMUM_SIZE     => :7 ' ||
                '         ,P_DISPLAY_TYPE     => 4 ' ||
                '         ,P_DISPLAY_STYLE    => 1 ' ||
                '         ,P_DISPLAY_SIZE     => :8 ' ||
                '         ,P_HELP_URL         => '''' ' ||
                '         ,P_FORMAT_MASK      => :9 ' ||
                '         ,P_DEFAULT_DESC     => '''' ' ||
                '         ,P_PROMPT_LEFT      => :10 ' ||
                '         ,P_PROMPT_ABOVE     => '''' ' ||
                '         ,P_USER_NAME        => :11 ' ||
                '         ,P_USER_TIP         => '''' ' ||
                '         ,P_ACCESS_KEY       => '''' ' ||
                '         ); ' ||
                'END; ';
     --
     EXECUTE IMMEDIATE l_plsql
       USING out l_return_code,
             IN p_application_id,
             IN l_param_defn_code,
             IN p_param_name,
             IN p_param_type,
             IN l_default_string,
             IN l_max_size,
             IN l_display_size,
             IN l_format_mask,
             IN p_param_prompt,
             IN p_param_name;
     --
  ELSE
     -- Have param_defn_code in format <appid>:<code>
     l_param_defn_code := substr(l_param_defn_code,instr(l_param_defn_code,':')+1);
  END IF;
  --
  -- Have param defn, now define item in list
  --
  l_attribute_code  := 'HR_STANDARD_NO_SAVE';
  --
  l_plsql := 'BEGIN ' ||
             '  :1 := BNE_PARAMETER_UTILS.CREATE_LIST_ITEMS_ALL' ||
             '          (p_application_id    => :2 '||
             '          ,p_param_list_code   => :3 ' ||
             '          ,p_param_defn_app_id => :4 ' ||
             '          ,p_param_defn_code   => :5 ' ||
             '          ,p_param_name        => :6 ' ||
             '          ,p_attribute_app_id  => 800 ' ||
             '          ,p_attribute_code    => :7 ' ||
             '          ,p_string_val        => '''' ' ||
             '          ,p_date_val          => '''' ' ||
             '          ,p_number_val        => '''' ' ||
             '          ,p_boolean_val       => '''' ' ||
             '          ,p_formula           => '''' ' ||
             '          ,p_desc_val          => '''' ' ||
             '          ); ' ||
             'END; ';
  --
  EXECUTE IMMEDIATE l_plsql
    USING out l_sequence,
          IN p_application_id,
          IN p_param_list_code,
          IN p_application_id,
          IN l_param_defn_code,
          IN p_param_name,
          IN l_attribute_code;
  --
END create_param_list_item;
--
-- ---------------------------------------------------------------------------
-- |---------------------------< add_sql_to_content >------------------------|
-- ---------------------------------------------------------------------------
PROCEDURE add_sql_to_content
  (p_application_id    in number
  ,p_intg_user_name    in varchar2
  ,p_sql               in varchar2
  ,p_param1_name       in varchar2 default NULL
  ,p_param1_type       in varchar2 default NULL
  ,p_param1_prompt     in varchar2 default NULL
  ,p_param2_name       in varchar2 default NULL
  ,p_param2_type       in varchar2 default NULL
  ,p_param2_prompt     in varchar2 default NULL
  ,p_param3_name       in varchar2 default NULL
  ,p_param3_type       in varchar2 default NULL
  ,p_param3_prompt     in varchar2 default NULL
  ,p_param4_name       in varchar2 default NULL
  ,p_param4_type       in varchar2 default NULL
  ,p_param4_prompt     in varchar2 default NULL
  ,p_param5_name       in varchar2 default NULL
  ,p_param5_type       in varchar2 default NULL
  ,p_param5_prompt     in varchar2 default NULL
  ) IS
  --
  TYPE CSR_TYP IS REF CURSOR;
  csr_int CSR_TYP;
  --
  -- Local variables
  --
  l_integrator_code    varchar2(30);
  l_content_code       varchar2(30);
  l_user_id            number;
  l_param_list_code    varchar2(30);
  l_plsql              varchar2(2000);
  --
BEGIN
  --
  -- Determine integrator code
  OPEN csr_int FOR
    'SELECT b.integrator_code ' ||
    '  FROM bne_integrators_tl t ' ||
    '     , bne_integrators_b b ' ||
    ' WHERE t.application_id = ' || p_application_id ||
    '   AND t.user_name = ''' || p_intg_user_name  || '''' ||
    '   AND t.integrator_code = b.integrator_code ' ||
    '   AND t.application_id = b.application_id ' ||
    '   AND t.integrator_code like ''GENERAL%'' ' ||
    '   AND b.enabled_flag = ''Y'' ';
  FETCH csr_int INTO l_integrator_code;
  --
  IF csr_int%NOTFOUND THEN
    --
    CLOSE csr_int;
    fnd_message.set_name('PER','PER_289428_ADI_INTG_NOT_EXIST');
    fnd_message.raise_error;
    --
  END IF;
  --
  CLOSE csr_int;
  --
  -- Determine content code for this integrator;
  OPEN csr_int FOR
     'SELECT content_code ' ||
     '  FROM bne_contents_b ' ||
     ' WHERE integrator_app_id = ' || p_application_id ||
     ' AND integrator_code = ''' || l_integrator_code || '''';
  FETCH csr_int INTO l_content_code;
  --
  IF csr_int%NOTFOUND THEN
    --
    CLOSE csr_int;
    fnd_message.set_name('PER','PER_289505_ADI_CONT_NOT_EXIST');
    fnd_message.raise_error;
    --
  END IF;
  CLOSE csr_int;
  --
  -- Get user
  SELECT fnd_global.user_id
  INTO l_user_id
  FROM dual;
  --
  -- Store SQL in BNE schema
  l_plsql := 'BEGIN ' ||
             '  bne_content_utils.upsert_stored_sql_statement ' ||
             '    (p_application_id => :1 ' ||
             '    ,p_content_code   => :2 ' ||
             '    ,p_query          => :3 ' ||
             '    ,p_user_id        => :4 ' ||
             '    ); ' ||
             'END; ';
  --
  EXECUTE IMMEDIATE l_plsql
    USING IN p_application_id,
          IN l_content_code,
          IN p_sql,
          IN l_user_id;
  --
  --
  -- Create standard parameter list with hr:session_date and hr:where
  -- parameters, and then assign to content
  create_param_list_for_content(l_content_code,
                                p_application_id,
                                l_param_list_code);
  --
  -- Create param list items for each parameter in SQL
  IF p_param1_name IS NOT NULL THEN
     --
     create_param_list_item(l_param_list_code
                           ,p_application_id
                           ,p_param1_name
                           ,p_param1_type
                           ,p_param1_prompt);
     --
  END IF;
  --
  IF p_param2_name IS NOT NULL THEN
     --
     create_param_list_item(l_param_list_code
                           ,p_application_id
                           ,p_param2_name
                           ,p_param2_type
                           ,p_param2_prompt);
     --
  END IF;
  --
  IF p_param3_name IS NOT NULL THEN
     --
     create_param_list_item(l_param_list_code
                           ,p_application_id
                           ,p_param3_name
                           ,p_param3_type
                           ,p_param3_prompt);
     --
  END IF;
  --
  IF p_param4_name IS NOT NULL THEN
     --
     create_param_list_item(l_param_list_code
                           ,p_application_id
                           ,p_param4_name
                           ,p_param4_type
                           ,p_param4_prompt);
     --
  END IF;
  --
  IF p_param5_name IS NOT NULL THEN
     --
     create_param_list_item(l_param_list_code
                           ,p_application_id
                           ,p_param5_name
                           ,p_param5_type
                           ,p_param5_prompt);
     --
  END IF;
  --
  -- Have param list and param list items - now assign
  -- to our content
  --
  l_plsql := 'BEGIN ' ||
             '  bne_content_utils.assign_param_list_to_content ' ||
             '    (P_CONTENT_APP_ID    => :1 ' ||
             '    ,P_CONTENT_CODE      => :2 ' ||
             '    ,P_PARAM_LIST_APP_ID => :3 ' ||
             '    ,P_PARAM_LIST_CODE   => :4 ' ||
             '    ); ' ||
             'END; ';
  --
  EXECUTE IMMEDIATE l_plsql
    USING IN p_application_id,
          IN l_content_code,
          IN p_application_id,
          IN l_param_list_code;
  --
END add_sql_to_content;
--
--
-- ------------------------------------------------------------------------
-- |----------------------< hr_disable_integrator >-----------------------|
-- ------------------------------------------------------------------------
--
-- Description:
--
--  Allows a customer to disable any customer defined integrator, by
--  setting its enabled flag, and altering the user integrator name.
--  The integrator will also be removed from any parameter lists.
--
-- -----------------------------------------------------------------------
PROCEDURE hr_disable_integrator
  (p_application_short_name in varchar2
  ,p_integrator_user_name   in varchar2
  ,p_disable                in varchar2) IS
--
  TYPE IntCurTyp IS REF CURSOR;
  l_int_csr      IntCurTyp;
  l_intg_code      varchar2(30);
  l_int_user_name  varchar2(240);
  l_sql            varchar2(2000);
  l_application_id number;
--
  CURSOR csr_find_app_id IS
   SELECT application_id
     FROM fnd_application
    WHERE upper(application_short_name) = upper(p_application_short_name);
--
BEGIN
  --
  -- Find application_id for given app_short_name
  OPEN csr_find_app_id;
  FETCH csr_find_app_id INTO l_application_id;
  IF csr_find_app_id%NOTFOUND THEN
     CLOSE csr_find_app_id;
     --
     -- Unable to determine Application ID for given short name
     fnd_message.set_name('PER','PER_289189_HR_DISBLE_INVAL_APP');
     fnd_message.raise_error;
     --
  END IF;
  CLOSE csr_find_app_id;
  --
  -- If application id is an hrms application then error, as these should
  -- not be removed.
  --
  IF (hr_general.chk_application_id(l_application_id) = 'TRUE') THEN
     --
     -- Integrator belongs to HRMS, so disabling it is not allowed
     fnd_message.set_name('PER','PER_289190_NO_DISABLE_HR_INTG');
     fnd_message.raise_error;
     --
  END IF;
  --
  -- Have integrator user name - determine integrator code
  --
  -- Open cursor (should only be 1 integrator with this particular
  -- user name).
  OPEN l_int_csr FOR
    'SELECT integrator_code ' ||
    '  FROM bne_integrators_tl ' ||
    ' WHERE user_name = ''' || p_integrator_user_name || ''' ' ||
    '   AND application_id = ' || l_application_id;
  --
  FETCH l_int_csr INTO l_intg_code;
  --
  IF l_int_csr%NOTFOUND THEN
     --
     CLOSE l_int_csr;
     fnd_message.set_name('PER','PER_289428_ADI_INTG_NOT_EXIST');
     fnd_message.raise_error;
     --
  END IF;
  CLOSE l_int_csr;
  --
  -- Have integrator code, now set to disable
  l_sql := 'BEGIN ' ||
           ' UPDATE bne_integrators_b ' ||
           '    SET enabled_flag = ''N'' ' ||
           '  WHERE integrator_code = :1 ' ||
           '    AND application_id = :2 ; ' ||
           'END; ';
  --
  EXECUTE IMMEDIATE l_sql
    USING IN l_intg_code,
             l_application_id;
  --
  -- Now alter integrator user name to reflect this change
  --
  l_sql := 'BEGIN ' ||
           ' UPDATE bne_integrators_tl ' ||
           '    SET user_name = :1 ' ||
           '  WHERE integrator_code = :2 ' ||
           '    AND application_id = :3; ' ||
           'END;';
  --
  EXECUTE IMMEDIATE l_sql
    USING IN p_integrator_user_name || ' (DISABLED)',
             l_intg_code,
             l_application_id;
  --
  -- Integrator has been disabled.  Now we want to remove it from any
  -- parameter lists that it may exist on (for forms integration).
  l_sql := 'BEGIN ' ||
           ' DELETE ' ||
           '   FROM bne_param_list_items ' ||
           '  WHERE string_value like :1 ' ||
           '    AND application_id = 800 ' ||
           '    AND param_list_code like ''HR%''; ' ||
           'END ;';
  --
  EXECUTE IMMEDIATE l_sql
    USING IN l_application_id || ':' || l_intg_code;
  --
END hr_disable_integrator;
--
-- ----------------------------------------------------------------------------
-- |-------------------< hr_create_resp_association >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Called to populate an entry in the HR_ADI_INTG_RESP table, which is
--   a table holding associations between integrators and responsibilities.
--
-- ----------------------------------------------------------------------------
PROCEDURE hr_create_resp_association
  (p_intg_application     IN varchar2
  ,p_integrator_user_name IN varchar2
  ,p_resp_application     IN varchar2
  ,p_responsibility_name  IN varchar2) IS
--
  TYPE IntCurTyp IS REF CURSOR;
  l_int_csr      IntCurTyp;
  l_intg_application_id number;
  l_resp_application_id number;
  l_integrator_code     varchar2(30);
  l_responsibility_id   number;
--
-- Cursor to determine app_id
CURSOR csr_get_app_id(l_app_short_name IN varchar) IS
  SELECT application_id
    FROM fnd_application
   WHERE upper(application_short_name) = upper(l_app_short_name);
--
-- Cursor to determine resp_id
CURSOR csr_get_resp_id(l_app_id IN number, l_resp_name IN varchar2) IS
  SELECT responsibility_id
    FROM fnd_responsibility_vl
   WHERE application_id = l_app_id
     AND responsibility_name = l_resp_name;
--
BEGIN
  -- Determine app_id for integrator
  OPEN csr_get_app_id(p_intg_application);
  FETCH csr_get_app_id INTO l_intg_application_id;
  IF csr_get_app_id%NOTFOUND THEN
     --
     CLOSE csr_get_app_id;
     -- Invalid application short name
     fnd_message.set_name('PER','PER_289514_ADI_INVAL_INTG_APPL');
     fnd_message.raise_error;
  END IF;
  CLOSE csr_get_app_id;
  --
  -- Determine app_id for responsibility
  OPEN csr_get_app_id(p_resp_application);
  FETCH csr_get_app_id INTO l_resp_application_id;
  IF csr_get_app_id%NOTFOUND THEN
     --
     CLOSE csr_get_app_id;
     -- Invalid application_short_name
     fnd_message.set_name('PER','PER_289516_ADI_INVAL_RESP_APPL');
     fnd_message.raise_error;
  END IF;
  CLOSE csr_get_app_id;
  --
  -- Now check if integrator exists
  OPEN l_int_csr FOR
    'SELECT integrator_code ' ||
    '  FROM bne_integrators_vl ' ||
    ' WHERE user_name = ''' || p_integrator_user_name || ''' ' ||
    '   AND application_id = ' || l_intg_application_id;
  --
  FETCH l_int_csr INTO l_integrator_code;
  IF l_int_csr%NOTFOUND THEN
     --
     CLOSE l_int_csr;
     fnd_message.set_name('PER','PER_289428_ADI_INTG_NOT_EXIST');
     fnd_message.raise_error;
     --
  END IF;
  CLOSE l_int_csr;
  --
  --
  -- Now check responsibility exists
  OPEN csr_get_resp_id(l_resp_application_id, p_responsibility_name);
  FETCH csr_get_resp_id INTO l_responsibility_id;
  IF csr_get_resp_id%NOTFOUND THEN
     --
     CLOSE csr_get_resp_id;
     --
     fnd_message.set_name('PER','PER_289517_ADI_INVAL_RESP');
     fnd_message.raise_error;
  END IF;
  CLOSE csr_get_resp_id;
  --
  -- Now have a valid app_id/integrator_code and app_id/resp_id
  -- combination, so create an entry in the HR_ADI_INTG_RESP table
  --
  INSERT INTO hr_adi_intg_resp
    (resp_association_id,
     intg_application_id,
     integrator_code,
     resp_application_id,
     responsibility_id)
  VALUES
    (hr_adi_intg_resp_s.nextval
    ,l_intg_application_id
    ,l_integrator_code
    ,l_resp_application_id
    ,l_responsibility_id);
  --
END hr_create_resp_association;
--
-- ----------------------------------------------------------------------------
-- |--------------------< hr_upd_or_del_resp_association >--------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Called to update or delete an entry in the HR_ADI_INTG_RESP table.  If
--   the resp associated with an integrator is updated to NULL, then it is
--   removed from the table.  Otherwise, the resp_application_id and resp_name
--   fields are updated.
--
-- ----------------------------------------------------------------------------
PROCEDURE hr_upd_or_del_resp_association
  (p_resp_association_id IN number
  ,p_resp_application    IN varchar2 default null
  ,p_responsibility_name IN varchar2 default null
  ) IS
--
  l_exists            varchar2(1);
  l_application_id    number;
  l_responsibility_id number;
  --
  CURSOR csr_chk_exists IS
    SELECT 'Y'
      FROM hr_adi_intg_resp
     WHERE resp_association_id = p_resp_association_id;
  --
  CURSOR csr_chk_app_exists IS
   SELECT application_id
     FROM fnd_application
    WHERE upper(application_short_name) = upper(p_resp_application);
  --
  CURSOR csr_chk_resp_exists(l_app_id IN number, l_resp_name IN varchar2) IS
     SELECT responsibility_id
       FROM fnd_responsibility_vl
      WHERE application_id = l_app_id
        AND responsibility_name = l_resp_name;
  --
BEGIN
  --
  -- Check entry exists
  OPEN csr_chk_exists;
  FETCH csr_chk_exists INTO l_exists;
  IF csr_chk_exists%NOTFOUND THEN
     --
     CLOSE csr_chk_exists;
     fnd_message.set_name('PER','PER_449900_ADI_INVAL_RESP_ASSC');
     fnd_message.raise_error;
     --
  END IF;
  CLOSE csr_chk_exists;
  --
  -- Handle delete case
  --
  IF ((p_resp_application IS NULL)
      and (p_responsibility_name IS NULL)) THEN
     --
     -- Delete row from hr_adi_intg_resp
     DELETE FROM hr_adi_intg_resp
      WHERE resp_association_id = p_resp_association_id;
     --
  ELSE
     -- Update required
     IF ((p_resp_application IS NULL) or
         (p_responsibility_name IS NULL)) THEN
         --
         -- Invalid combination - must both have a value to update
         fnd_message.set_name('PER','PER_449901_ADI_RESP_VAL_NULL');
         fnd_message.raise_error;
     END IF;
     --
     -- Check resp_app_id exists
     OPEN csr_chk_app_exists;
     FETCH csr_chk_app_exists INTO l_application_id;
     IF csr_chk_app_exists%NOTFOUND THEN
        --
        CLOSE csr_chk_app_exists;
        fnd_message.set_name('PER','PER_289516_ADI_INVAL_RESP_APPL');
        fnd_message.raise_error;
     END IF;
     CLOSE csr_chk_app_exists;
     --
     -- Check resp exists
     OPEN csr_chk_resp_exists(l_application_id, p_responsibility_name);
     FETCH csr_chk_resp_exists INTO l_responsibility_id;
     IF csr_chk_resp_exists%NOTFOUND THEN
        --
        -- No matching resp, so error
        CLOSE csr_chk_resp_exists;
        fnd_message.set_name('PER','PER_289517_ADI_INVAL_RESP');
        fnd_message.raise_error;
     END IF;
     CLOSE csr_chk_resp_exists;
     --
     -- Update the resp
     UPDATE hr_adi_intg_resp
     SET resp_application_id = l_application_id,
         responsibility_id = l_responsibility_id
     WHERE resp_association_id = p_resp_association_id;
     --
  END IF;
END hr_upd_or_del_resp_association;
--
--
-- +--------------------------------------------------------------------------+
-- |--------------------< hr_maint_form_func_association >--------------------|
-- +--------------------------------------------------------------------------+
--
-- Description:
--   Called to create, update or delete entries in the BNE tables that link
--   form functions with integrators.
--
-- +--------------------------------------------------------------------------+
PROCEDURE hr_maint_form_func_association
  (p_intg_application     IN varchar2
  ,p_integrator_user_name IN varchar2
  ,p_security_value       IN varchar2
  ) IS
--
  TYPE IntCurTyp IS REF CURSOR;
  l_int_csr           IntCurTyp;
  l_plsql             varchar2(2000);
  l_intg_app_id       number;
  l_integrator_code   varchar2(30);
  l_exists            varchar2(1);
  l_security_app_id   number;
  l_security_code     varchar2(30);
  l_user_id           number;
  --
  --
  CURSOR csr_chk_app_exists IS
   SELECT application_id
     FROM fnd_application
    WHERE upper(application_short_name) = upper(p_intg_application);
  --
 --
BEGIN
  --
  --
  SELECT fnd_global.user_id
  INTO   l_user_id
  FROM   dual;
  --
  -- Check for NULLS - Both Application and Integrator Name must have
  --                   a value
  --
  IF p_intg_application IS NULL THEN
     fnd_message.set_name('PER','PER_289514_ADI_INVAL_INTG_APPL');
     fnd_message.raise_error;
  END IF;
  --
  IF p_integrator_user_name IS NULL THEN
     fnd_message.set_name('PER','PER_289428_ADI_INTG_NOT_EXIST');
     fnd_message.raise_error;
  END IF;
  --
  -- Check Integrator App  exists
  --
  OPEN csr_chk_app_exists;
  FETCH csr_chk_app_exists INTO l_intg_app_id;
  IF csr_chk_app_exists%NOTFOUND THEN
  --
     CLOSE csr_chk_app_exists;
     fnd_message.set_name('PER','PER_289514_ADI_INVAL_INTG_APPL');
     fnd_message.raise_error;
  END IF;
  CLOSE csr_chk_app_exists;
  --
  -- Check Integrator exists
  --
  OPEN l_int_csr FOR
    'SELECT integrator_code ' ||
    '  FROM bne_integrators_vl ' ||
    ' WHERE user_name = ''' || p_integrator_user_name || ''' ' ||
    '  AND application_id = ' || l_intg_app_id;
  --
  FETCH l_int_csr INTO l_integrator_code;
  IF l_int_csr%NOTFOUND THEN
  --
     CLOSE l_int_csr;
     fnd_message.set_name('PER','PER_289428_ADI_INTG_NOT_EXIST');
     fnd_message.raise_error;
  END IF;
  CLOSE l_int_csr;
  --
  -- Check if Form Function rules exist for this Integrator
  --
  OPEN l_int_csr FOR
  'SELECT security_rule_app_id ' ||
  '     , security_rule_code ' ||
  '  FROM bne_secured_objects ' ||
  ' WHERE application_id = ' || l_intg_app_id ||
  '   AND object_code = ''' || l_integrator_code || ''' ' ||
  '   AND object_type = ''INTEGRATOR''';
  --
  FETCH l_int_csr INTO
          l_security_app_id
      ,   l_security_code;
  IF l_int_csr%NOTFOUND THEN
    l_exists := 'N';
  ELSE
    l_exists := 'Y';
  END IF;
  CLOSE l_int_csr;
  --
  IF (p_security_value IS NULL) THEN
    IF (l_exists = 'Y') THEN
      --
      -- p_security_value being NULL means that we are deleting a rule.
      -- Note that in this case, if l_exists were to be  'N' then we would
      -- be trying to delete a rule that does not exist so no action required
      -- hence there is no code here for
      --     p_security_value IS NULL and l_exists = 'N'
      --
      l_plsql :=
       'BEGIN ' ||
       'BNE_SECURITY_UTILS_PKG.DELETE_OBJECT_RULES' ||
       '   (p_object_app_id   => :1 ' ||
       '   ,p_object_code     => :2 ' ||
       '   ,p_object_type     => ''' || 'INTEGRATOR' || ''' ' ||
       '   ,p_security_app_id => :3 ' ||
       '   ,p_security_code   => :4 ' ||
       '   ); ' ||
       'END; ';
      --
      EXECUTE IMMEDIATE l_plsql
      USING IN l_intg_app_id,
            IN l_integrator_code,
            IN l_security_app_id,
            IN l_security_code;
    END IF;
    --
  ELSE
    IF (l_exists = 'Y') THEN
      --
      -- This means that user is updating a rule
      --
      l_plsql :=
       'BEGIN ' ||
       'BNE_SECURITY_UTILS_PKG.UPDATE_OBJECT_RULES' ||
       '   (p_object_app_id   => :1 ' ||
       '   ,p_object_code     => :2 ' ||
       '   ,p_object_type     => ''' || 'INTEGRATOR' || ''' ' ||
       '   ,p_security_app_id => :3 ' ||
       '   ,p_security_code   => :4 ' ||
       '   ,P_SECURITY_TYPE   => ''' || 'FUNCTION' || ''' ' ||
       '   ,P_SECURITY_VALUE  => :5 ' ||
       '   ,P_USER_ID         => :6 ' ||
       '   ); ' ||
       'END; ';
      --
      EXECUTE IMMEDIATE l_plsql
      USING IN l_intg_app_id,
            IN l_integrator_code,
            IN l_security_app_id,
            IN l_security_code,
            IN p_security_value,
            IN l_user_id;
    --
    ELSE
      --
      --  This means that user is creating a rule
      --
      l_plsql :=
       'BEGIN ' ||
       'BNE_SECURITY_UTILS_PKG.ADD_OBJECT_RULES' ||
       '    (p_application_id  => :1 ' ||
       '    ,p_object_code     => :2 ' ||
       '    ,p_object_type     => ''' || 'INTEGRATOR' || ''' ' ||
       '    ,p_security_code   => :3 ' ||
       '    ,P_SECURITY_TYPE   => ''' || 'FUNCTION' || ''' ' ||
       '    ,P_SECURITY_VALUE  => :4 ' ||
       '    ,P_USER_ID         => :5 ' ||
       '    ); ' ||
       'END; ';
      --
      EXECUTE IMMEDIATE l_plsql
      USING IN l_intg_app_id,
            IN l_integrator_code,
            IN l_integrator_code,
            IN p_security_value,
            IN l_user_id;
    --
    END IF;
  END IF;
END hr_maint_form_func_association;
--
FUNCTION fetchname
  (p_number IN number
  ,p_application_id IN number
  ,p_param_list_code IN varchar2) RETURN varchar2 IS
--
  TYPE IntCurTyp IS REF CURSOR;
  l_int_csr      IntCurTyp;
  --
  l_param_name  varchar2(240);
  l_datatype    number;
  l_prompt      varchar2(240);
  --
  l_return      varchar2(240);
--
BEGIN
  --
  OPEN l_int_csr FOR
    'SELECT i.param_name, d.datatype, t.prompt_left ' ||
    '  FROM bne_param_list_items i, bne_param_defns_b d, bne_param_defns_tl t ' ||
    ' WHERE i.application_id = ' || p_application_id ||
    '   AND i.param_list_code = ''' || p_param_list_code || ''' ' ||
    '   AND i.sequence_num = ' || p_number ||
    '   AND i.param_defn_code = d.param_defn_code ' ||
    '   AND i.param_defn_app_id = d.application_id ' ||
    '   AND i.param_defn_code = t.param_defn_code ' ||
    '   AND i.param_defn_app_id = t.application_id ';
  --
  FETCH l_int_csr INTO l_param_name, l_datatype, l_prompt;
  --
  IF l_int_csr%NOTFOUND THEN
     l_return := '';
  ELSE
     l_return := l_param_name;
  END IF;
  CLOSE l_int_csr;
  --
  RETURN l_return;
  --
END fetchname;
--
FUNCTION fetchtype
  (p_number IN number
  ,p_application_id IN number
  ,p_param_list_code IN varchar2) RETURN varchar2 IS
--
  TYPE IntCurTyp IS REF CURSOR;
  l_int_csr      IntCurTyp;
  --
  l_param_name  varchar2(240);
  l_datatype    varchar2(240);
  l_prompt      varchar2(240);
  --
  l_return      varchar2(240);
--
BEGIN
  --
/*  MODIFIED THIS CURSOR FOR FIXING BUG#4080461
  OPEN l_int_csr FOR
    'SELECT i.param_name, decode(d.datatype,1,''Varchar2'',' ||
    '                            2,''Number'',3,''Date'',''Varchar2''), t.prompt_left ' ||
    '  FROM bne_param_list_items i, bne_param_defns_b d, bne_param_defns_tl t ' ||
    ' WHERE i.application_id = ' || p_application_id ||
    '   AND i.param_list_code = ''' || p_param_list_code || ''' ' ||
    '   AND i.sequence_num = ' || p_number ||
    '   AND i.param_defn_code = d.param_defn_code ' ||
    '   AND i.param_defn_app_id = d.application_id ' ||
    '   AND i.param_defn_code = t.param_defn_code ' ||
    '   AND i.param_defn_app_id = t.application_id ';
*/
  OPEN l_int_csr FOR
    'SELECT i.param_name, decode(d.datatype, '||
    '                            1,hr_general.decode_lookup(''HR_WEB_ADI_TYPES'',''1''), '||
    '                            2,hr_general.decode_lookup(''HR_WEB_ADI_TYPES'',''2''), '||
    '                            3,hr_general.decode_lookup(''HR_WEB_ADI_TYPES'',''3''), '||
    '                            hr_general.decode_lookup(''HR_WEB_ADI_TYPES'',''1'')), '||
    '                            t.prompt_left ' ||
    '  FROM bne_param_list_items i, bne_param_defns_b d, bne_param_defns_tl t ' ||
    ' WHERE i.application_id = ' || p_application_id ||
    '   AND i.param_list_code = ''' || p_param_list_code || ''' ' ||
    '   AND i.sequence_num = ' || p_number ||
    '   AND i.param_defn_code = d.param_defn_code ' ||
    '   AND i.param_defn_app_id = d.application_id ' ||
    '   AND i.param_defn_code = t.param_defn_code ' ||
    '   AND i.param_defn_app_id = t.application_id ';

  --
  FETCH l_int_csr INTO l_param_name, l_datatype, l_prompt;
  --
  IF l_int_csr%NOTFOUND THEN
     l_return := '';
  ELSE
     l_return := l_datatype;
  END IF;
  CLOSE l_int_csr;
  --
  RETURN l_return;
  --
END fetchtype;
--
FUNCTION fetchprompt
  (p_number IN number
  ,p_application_id IN number
  ,p_param_list_code IN varchar2) RETURN varchar2 IS
--
  TYPE IntCurTyp IS REF CURSOR;
  l_int_csr      IntCurTyp;
  --
  l_param_name  varchar2(240);
  l_datatype    number;
  l_prompt      varchar2(240);
  --
  l_return      varchar2(240);
--
BEGIN
  --
  OPEN l_int_csr FOR
    'SELECT i.param_name, d.datatype, t.prompt_left ' ||
    '  FROM bne_param_list_items i, bne_param_defns_b d, bne_param_defns_tl t ' ||
    ' WHERE i.application_id = ' || p_application_id ||
    '   AND i.param_list_code = ''' || p_param_list_code || ''' ' ||
    '   AND i.sequence_num = ' || p_number ||
    '   AND i.param_defn_code = d.param_defn_code ' ||
    '   AND i.param_defn_app_id = d.application_id ' ||
    '   AND i.param_defn_code = t.param_defn_code ' ||
    '   AND i.param_defn_app_id = t.application_id ';
  --
  FETCH l_int_csr INTO l_param_name, l_datatype, l_prompt;
  --
  IF l_int_csr%NOTFOUND THEN
     l_return := '';
  ELSE
     l_return := l_prompt;
  END IF;
  CLOSE l_int_csr;
  --
  RETURN l_return;
  --
END fetchprompt;
--

--
END hr_integration_utils;

/
