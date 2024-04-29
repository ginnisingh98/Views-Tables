--------------------------------------------------------
--  DDL for Package Body HR_SUIT_MATCH_UTILITY_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SUIT_MATCH_UTILITY_WEB" AS
/* $Header: hrsmutlw.pkb 120.3 2005/12/13 13:44:26 svittal noship $ */

  g_package             constant varchar2(31) := 'hr_suit_match_utility_web.';
  g_region_application_id   constant integer
                                    := hr_util_misc_web.g_region_application_id;

  c_title       hr_util_misc_web.g_title%TYPE;
  g_prompts     hr_util_misc_web.g_prompts%TYPE;
  c_person_id   per_people_f.person_id%type;
  c_language_code              varchar2(5);
  c_legislation_code           varchar2(5);
  g_person_rec	per_people_f%ROWTYPE;

-- ---------------------------------------------------------------------------
-- get_option_header
-- ---------------------------------------------------------------------------
FUNCTION get_option_header(p_mode in varchar2)
RETURN varchar2 IS
BEGIN
  IF p_mode = hr_suit_match_utility_web.g_select_people_work_mode THEN
    fnd_message.set_name('PER', 'HR_WEB_SM_MENU_1');
  ELSIF p_mode = hr_suit_match_utility_web.g_match_peope_role_mode THEN
    fnd_message.set_name('PER', 'HR_WEB_SM_MENU_2');
  ELSIF p_mode = hr_suit_match_utility_web.g_match_successors_pos_mode THEN
    fnd_message.set_name('PER', 'HR_WEB_SM_MENU_3');
  ELSIF p_mode = hr_suit_match_utility_web.g_match_applicants_van_mode THEN
    fnd_message.set_name('PER', 'HR_WEB_SM_MENU_4');
  ELSIF p_mode = hr_suit_match_utility_web.g_work_vacancies_fast_path THEN
    fnd_message.set_name('PER', 'HR_WEB_SM_MENU_5');
  ELSIF p_mode = hr_suit_match_utility_web.g_work_successions_fast_path THEN
    fnd_message.set_name('PER', 'HR_WEB_SM_MENU_6');
  ELSIF p_mode = hr_suit_match_utility_web.g_work_deployments_fast_path THEN
    fnd_message.set_name('PER', 'HR_WEB_SM_MENU_7');
  ELSIF p_mode = hr_suit_match_utility_web.g_match_work_mode THEN
    fnd_message.set_name('PER', 'HR_WEB_SM_MENU_8');
  ELSE
    RETURN null;
  END IF;
  RETURN fnd_message.get;
END get_option_header;

-- ---------------------------------------------------------------------------
-- get_lookup_meaning
-- ---------------------------------------------------------------------------
FUNCTION get_lookup_meaning
  (p_lookup_type  in varchar2
  ,p_lookup_code  in varchar2
  ,p_schema       in varchar2 default 'HR')
RETURN varchar2 IS

  CURSOR csr_hr_lookup IS
  SELECT meaning
    FROM hr_lookups
   WHERE lookup_type = p_lookup_type
     AND lookup_code = p_lookup_code;

  CURSOR csr_fnd_lookup IS
  SELECT meaning
    FROM fnd_common_lookups
   WHERE lookup_type = p_lookup_type
     AND lookup_code = p_lookup_code;

  l_meaning   varchar2(2000);

BEGIN

  IF p_schema = 'HR' THEN
    OPEN csr_hr_lookup;
    FETCH csr_hr_lookup INTO l_meaning;
    CLOSE csr_hr_lookup;
  ELSIF p_schema = 'FND' THEN
    OPEN csr_fnd_lookup;
    FETCH csr_fnd_lookup INTO l_meaning;
    CLOSE csr_fnd_lookup;
  END IF;

  RETURN l_meaning;

END get_lookup_meaning;
-- ---------------------------------------------------------------------------
-- get_max_step_value
-- ---------------------------------------------------------------------------

FUNCTION get_max_step_value
  (p_competence_id in hr_util_misc_web.g_varchar2_tab_type)

RETURN number IS

  l_dynamic_sql 	varchar2(32000);
  l_sql_cursor		integer;
  l_rows            integer;
  l_max_step_value	number;
  c_id				number;
  l_ids             varchar2(32000);
  c_name            varchar2(240);

BEGIN

  l_ids := build_items(p_id => p_competence_id);

  l_dynamic_sql :=
    'SELECT max(count(step_value))'
     ||' FROM per_competence_levels_v'
     ||' WHERE competence_id IN ('||l_ids||')'
     ||' GROUP BY competence_id';

  l_sql_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_sql_cursor, l_dynamic_sql, dbms_sql.v7);
  dbms_sql.define_column(l_sql_cursor, 1, c_id, 15);
  l_rows := dbms_sql.execute(l_sql_cursor);

  IF dbms_sql.fetch_rows(l_sql_cursor) > 0 THEN
    dbms_sql.column_value(l_sql_cursor, 1, c_name);
    l_max_step_value := to_number(c_name);
  END IF;

  dbms_sql.close_cursor(l_sql_cursor);

  RETURN l_max_step_value;

EXCEPTION
  WHEN OTHERS THEN
    IF dbms_sql.is_open(l_sql_cursor) THEN
      dbms_sql.close_cursor(l_sql_cursor);
    END IF;
    RETURN 0;
END get_max_step_value;
-- ---------------------------------------------------------------------------
-- encode_competence_table
-- ---------------------------------------------------------------------------
PROCEDURE encode_competence_table
  (p_competence_id    		in  hr_util_misc_web.g_varchar2_tab_type
  ,p_competence_name  		in  hr_util_misc_web.g_varchar2_tab_type
  ,p_low_rating_level_id    in  hr_util_misc_web.g_varchar2_tab_type
  ,p_high_rating_level_id   in  hr_util_misc_web.g_varchar2_tab_type
  ,p_mandatory    			in  hr_util_misc_web.g_varchar2_tab_type
  ,p_competence_table 	 out nocopy g_competence_table
  ,p_essential_count        out nocopy number
  ,p_desirable_count        out nocopy number) IS
BEGIN
  p_essential_count := 0;
  p_desirable_count := 0;

  FOR i IN 1..NVL(p_competence_id.count,0) LOOP
    p_competence_table(i).competence_id := p_competence_id(i);
    p_competence_table(i).competence_name := p_competence_name(i);
    p_competence_table(i).low_rating_level_id := p_low_rating_level_id(i);
    p_competence_table(i).high_rating_level_id := p_high_rating_level_id(i);
    p_competence_table(i).low_step_value :=
      hr_suit_match_utility_web.get_step_value
        (p_rating_level_id	=> p_low_rating_level_id(i));
    p_competence_table(i).high_step_value :=
      hr_suit_match_utility_web.get_step_value
       (p_rating_level_id	=> p_high_rating_level_id(i));
    p_competence_table(i).mandatory := p_mandatory(i);
    IF p_mandatory(i) = 'Y' THEN
      p_essential_count := p_essential_count + 1;
    ELSE
      p_desirable_count := p_desirable_count + 1;
    END IF;
  END LOOP;
END encode_competence_table;
-- ---------------------------------------------------------------------------
-- decode_competence_table
-- ---------------------------------------------------------------------------
PROCEDURE decode_competence_table
  (p_competence_table 		in g_competence_table
  ,p_competence_id    	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_competence_name  	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_low_rating_level_id    out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_high_rating_level_id   out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_mandatory   out nocopy hr_util_misc_web.g_varchar2_tab_type) IS
BEGIN
  FOR i IN 1..NVL(p_competence_table.count,0) LOOP
    p_competence_id(i) := p_competence_table(i).competence_id;
    p_competence_name(i) := p_competence_table(i).competence_name;
    p_low_rating_level_id(i) := p_competence_table(i).low_rating_level_id;
    p_high_rating_level_id(i) := p_competence_table(i).high_rating_level_id;
    p_mandatory(i) := p_competence_table(i).mandatory;
  END LOOP;
END decode_competence_table;

-- ---------------------------------------------------------------------------
-- get_work_detail_name
-- ---------------------------------------------------------------------------

FUNCTION get_work_detail_name
  (p_search_type in varchar2
  ,p_search_id   in varchar2)
RETURN varchar2 IS

  l_dynamic_sql varchar2(32000);
  l_id			hr_util_misc_web.g_varchar2_tab_type;
  l_name		hr_util_misc_web.g_varchar2_tab_type;
  l_count		number default 0;

BEGIN
  l_dynamic_sql := hr_suit_match_utility_web.build_sql
                     (p_search_type => p_search_type
                     ,p_ids => p_search_id);
  hr_suit_match_utility_web.get_id_name
  	           (p_dynamic_sql => l_dynamic_sql
  	           ,p_id => l_id
  	           ,p_name => l_name
  	           ,p_count => l_count);

  IF l_count > 0 THEN
    RETURN l_name(1);
  ELSE
    RETURN null;
  END IF;

END get_work_detail_name;
-- ---------------------------------------------------------------------------
-- get_person_info
-- ---------------------------------------------------------------------------
PROCEDURE get_person_info
  (p_id		    	in number
  ,p_person_table   out nocopy g_person_table) IS

  l_id  hr_util_misc_web.g_varchar2_tab_type;
  l_count number;

BEGIN

  l_id(1) := p_id;
  get_people_info(p_id => l_id
                 ,p_person_table => p_person_table
                 ,p_count => l_count);

END get_person_info;

-- ---------------------------------------------------------------------------
-- get_people_info
-- ---------------------------------------------------------------------------

PROCEDURE get_people_info
  (p_id		    	in hr_util_misc_web.g_varchar2_tab_type
  ,p_person_table   out nocopy g_person_table
  ,p_count          out nocopy number) IS

  l_dynamic_sql 	varchar2(32000);
  l_sql_cursor		integer;
  l_rows            integer;
  l_index 			number;
  c_id				varchar2(15);
  c_name			varchar2(240);
  c_type            varchar2(240);
  c_phone           varchar2(240);
  c_location        varchar2(240);
  c_employee_number varchar2(30);
  c_applicant_number varchar2(30);
  c_hire_date       varchar2(30);
  l_ids             varchar2(32000);

BEGIN

  hr_util_misc_web.validate_session(p_person_id => c_person_id);
  c_legislation_code := hr_misc_web.get_legislation_code
    (p_person_id => c_person_id);


  l_ids := build_items(p_id => p_id);

-- bug# 2447224.
-- Bug#3374753 begin
  l_dynamic_sql :=
    'SELECT distinct ppf.person_id';
    l_dynamic_sql := l_dynamic_sql
    ||',ppf.full_name name';
  l_dynamic_sql := l_dynamic_sql
     ||',hr_person_type_usage_info.get_user_person_type(trunc(sysdate),ppf.person_id) user_person_type'
     ||',hr_general.get_work_phone(ppf.person_id)'
     ||',ppf.internal_location'
     ||',ppf.employee_number'
     ||',ppf.applicant_number'
     ||',decode (ppf.current_employee_flag ,''Y'',ppos.date_start,null)'
     ||',ppf.order_name'
     ||' FROM per_people_f ppf'
     ||',per_periods_of_service ppos'
     ||' WHERE ppf.person_id IN ('||l_ids||')'
-- Bug # 2670769 fix begins.
-- Bug#3282680 start
  --   ||' AND (ppf.current_employee_flag = ''Y'''
  --   ||' OR ppf.current_applicant_flag = ''Y'')'
     ||' AND TRUNC(sysdate) BETWEEN ppf.effective_start_date '
     ||' AND ppf.effective_end_date'
     ||' AND ppos.person_id(+) = ppf.person_id'
     ||' AND ((ppf.current_employee_flag = ''Y'''
     ||' AND ppf.effective_start_date between ppos.date_start'
     ||' AND nvl(ppos.actual_termination_date,ppf.effective_start_date))'
     ||' OR ((ppf.current_employee_flag is null)'
     ||' AND (ppf.current_applicant_flag = ''Y'')))'
  --   ||' AND ppf.effective_start_date between ppos.date_start(+)'
  --   ||' AND nvl(ppos.actual_termination_date,ppf.effective_start_date)'
-- Bug#32382680 end
-- Bug#3374753 end
-- Bug #2667216 Fix begins
--     ||' AND ppos.date_start(+) BETWEEN ppf.effective_start_date '
--     ||' AND ppf.effective_end_date'
-- Bug #2667216 Fix ends.
-- Bug # 2670769 fix ends.
-- Bug# 2388754 Fix
     --||' AND (ppos.actual_termination_date is null '
     --||' or ppos.actual_termination_date > trunc(sysdate))'
-- Bug# 2388754 Fix
     ||' AND ppos.business_group_id(+) = ppf.business_group_id';
  IF c_legislation_code = g_japan_legislation_code THEN
    l_dynamic_sql := l_dynamic_sql
    ||' ORDER BY ppf.last_name,ppf.first_name';
  ELSE
    l_dynamic_sql := l_dynamic_sql
     ||' ORDER BY NVL(ppf.order_name, ppf.full_name)';
  END IF;

  l_sql_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_sql_cursor, l_dynamic_sql, dbms_sql.v7);
  dbms_sql.define_column(l_sql_cursor, 1, c_id, 15);
  dbms_sql.define_column(l_sql_cursor, 2, c_name, 240);
  dbms_sql.define_column(l_sql_cursor, 3, c_type, 2000);
  dbms_sql.define_column(l_sql_cursor, 4, c_phone, 240);
  dbms_sql.define_column(l_sql_cursor, 5, c_location, 240);
  dbms_sql.define_column(l_sql_cursor, 6, c_employee_number, 30);
  dbms_sql.define_column(l_sql_cursor, 7, c_applicant_number, 30);
  dbms_sql.define_column(l_sql_cursor, 8, c_hire_date, 30);
  l_rows := dbms_sql.execute(l_sql_cursor);
  l_index := 0;
  WHILE dbms_sql.fetch_rows(l_sql_cursor) > 0 LOOP
    l_index := l_index + 1;
    dbms_sql.column_value(l_sql_cursor, 1, c_id);
    dbms_sql.column_value(l_sql_cursor, 2, p_person_table(l_index).name);
    dbms_sql.column_value(l_sql_cursor, 3, p_person_table(l_index).person_type);
    dbms_sql.column_value(l_sql_cursor, 4, p_person_table(l_index).work_phone);
    dbms_sql.column_value
        (l_sql_cursor, 5, p_person_table(l_index).location_code);
    dbms_sql.column_value
        (l_sql_cursor, 6, p_person_table(l_index).employee_number);
    dbms_sql.column_value
        (l_sql_cursor, 7, p_person_table(l_index).applicant_number);
    dbms_sql.column_value
        (l_sql_cursor, 8, c_hire_date);
    p_person_table(l_index).person_id := c_id;
    p_person_table(l_index).hire_date := c_hire_date;
  END LOOP;

  dbms_sql.close_cursor(l_sql_cursor);

  p_count := l_index;

EXCEPTION
  WHEN others THEN
    IF dbms_sql.is_open(l_sql_cursor) THEN
      dbms_sql.close_cursor(l_sql_cursor);
    END IF;
END get_people_info;

-- ---------------------------------------------------------------------------
-- keyflex_select_where_clause
-- ---------------------------------------------------------------------------
PROCEDURE keyflex_select_where_clause
  (p_business_group_id	in number
  ,p_keyflex_code 		in varchar2
  ,p_filter_clause      in varchar2 default null
  ,p_select_clause      out nocopy varchar2
  ,p_where_clause       out nocopy varchar2) IS

  l_mapped_col_names	hr_util_misc_web.g_varchar2_tab_type;
  l_segment_separator	varchar2(10);
  l_count               number;
  l_table_short_name    varchar2(10);

BEGIN

  IF p_keyflex_code = 'JOB' THEN
    l_table_short_name := 'pjd';
  ELSIF p_keyflex_code = 'POS' THEN
    l_table_short_name := 'ppd';
  ELSIF p_keyflex_code = 'GRD' THEN
    l_table_short_name := 'pgd';
  END IF;

  get_keyflex_mapped_column_name
    (p_business_group_id => p_business_group_id
    ,p_keyflex_code => p_keyflex_code
    ,p_mapped_col_names	=> l_mapped_col_names
    ,p_segment_separator => l_segment_separator
    ,p_count  => l_count);


  FOR i IN 1..l_count LOOP
    IF p_select_clause IS null THEN
      p_select_clause :=  l_table_short_name
                        ||l_segment_separator
                        ||l_mapped_col_names(i);
      IF p_filter_clause IS NOT null THEN
        p_where_clause := 'UPPER('||  l_table_short_name
                        ||l_segment_separator
                        ||l_mapped_col_names(i) ||')'
                        ||' '
                        ||p_filter_clause;
      END IF;
    ELSE
      p_select_clause := p_select_clause
                        ||'||'
                        ||l_table_short_name
                        ||l_segment_separator
                        ||l_mapped_col_names(i);
      IF p_filter_clause IS NOT null THEN
        p_where_clause := p_where_clause
                        ||' OR '
                        ||'UPPER('||l_table_short_name
                        ||l_segment_separator
                        ||l_mapped_col_names(i) || ')'
                        ||' '
                        ||p_filter_clause;
      END IF;
    END IF;
  END LOOP;

  IF p_select_clause IS NOT null THEN
    p_select_clause := p_select_clause ||' name';
  ELSE
    p_select_clause := substr(l_table_short_name,1,2)||'.name name';
  END IF;
  IF p_filter_clause IS NOT null THEN
    IF p_where_clause IS NOT null THEN
      p_where_clause := '(' || p_where_clause || ')';
    ELSE
      p_where_clause := 'UPPER('||substr(l_table_short_name,1,2)||'.name) '
        ||p_filter_clause;
    END IF;
  END IF;



END keyflex_select_where_clause;
-- ---------------------------------------------------------------------------
-- get_keyflex_mapped_column_name
-- ---------------------------------------------------------------------------
PROCEDURE get_keyflex_mapped_column_name
  (p_business_group_id	in number
  ,p_keyflex_code 		in varchar2
  ,p_mapped_col_names out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_segment_separator out nocopy varchar2
  ,p_count              out nocopy number) IS

  l_mapped_col_name1	varchar2(60);
  l_mapped_col_name2	varchar2(60);
  l_id_flex_num			number;

  l_warning             varchar2(2000);

BEGIN

  p_count := 0;

  hr_util_flex_web.get_keyflex_mapped_column_name
    (p_business_group_id => p_business_group_id
    ,p_keyflex_code => p_keyflex_code
    ,p_mapped_col_name1 => l_mapped_col_name1
    ,p_mapped_col_name2 => l_mapped_col_name2
    ,p_keyflex_id_flex_num => l_id_flex_num
    ,p_segment_separator => p_segment_separator
    ,p_warning => l_warning);

  IF l_warning IS NOT null THEN
    return;
  END IF;

  IF l_mapped_col_name1 IS NOT null THEN
    p_mapped_col_names(1) := l_mapped_col_name1;
    p_count := p_count + 1;
  END IF;

  IF l_mapped_col_name2 IS NOT null THEN
    p_mapped_col_names(2) := l_mapped_col_name2;
    p_count := p_count + 1;
  END IF;

EXCEPTION
  WHEN others THEN
    return;

END get_keyflex_mapped_column_name;
-- ---------------------------------------------------------------------------
-- get_search_count
-- ---------------------------------------------------------------------------

FUNCTION get_search_count
  (p_mode				    in varchar2
  ,p_person_type_id         in varchar2 default null
  ,p_assignment_type 		in varchar2 default null
  ,p_pre_search_type  		in varchar2
  ,p_pre_search_ids 		in varchar2
  ,p_search_type 			in varchar2
  ,p_filer_match 			in varchar2
  ,p_search_criteria 		in varchar2)
RETURN number IS

  l_dynamic_sql 	varchar2(32000);
  l_id			hr_util_misc_web.g_varchar2_tab_type;
  l_name		hr_util_misc_web.g_varchar2_tab_type;
  l_count		number default 0;

BEGIN

  l_dynamic_sql := hr_suit_match_utility_web.build_sql
                              (p_mode => p_mode
                              ,p_person_type_id => p_person_type_id
                              ,p_assignment_type => p_assignment_type
                              ,p_pre_search_type => p_pre_search_type
  	   		      ,p_pre_search_ids => p_pre_search_ids
  			  ,p_search_type => p_search_type
  			  ,p_filer_match => p_filer_match
  			  ,p_search_criteria => p_search_criteria);

  hr_suit_match_utility_web.get_id_name
  	           (p_dynamic_sql => l_dynamic_sql
  	           ,p_id => l_id
  	           ,p_name => l_name
  	           ,p_count => l_count);

  RETURN l_count;

END get_search_count;
-- ---------------------------------------------------------------------------
-- get_step_value
-- ---------------------------------------------------------------------------

FUNCTION get_step_value
  (p_rating_level_id in number)
RETURN per_rating_levels.step_value%TYPE IS

  CURSOR csr_step_value IS
  SELECT step_value
    FROM per_competence_levels_v
   WHERE rating_level_id = p_rating_level_id;

  l_step_value		  per_rating_levels.step_value%TYPE;

BEGIN

  OPEN csr_step_value;
  FETCH csr_step_value INTO l_step_value;
  CLOSE csr_step_value;

  RETURN l_step_value;

END get_step_value;
-- ---------------------------------------------------------------------------
-- get_competence_name
-- ---------------------------------------------------------------------------

FUNCTION get_competence_name
  (p_competence_id in number)
RETURN per_competences_tl.name%type  IS

  CURSOR csr_competence_name IS
  SELECT name
    FROM per_competences_tl
   WHERE competence_id = p_competence_id
   AND   language      = userenv('LANG') ;

  l_name		per_competences_tl.name%TYPE;

BEGIN

  OPEN csr_competence_name;
  FETCH csr_competence_name INTO l_name;
  CLOSE csr_competence_name;

  RETURN l_name;

END get_competence_name;

-- ---------------------------------------------------------------------------
-- get_drived_org_job
-- ---------------------------------------------------------------------------

PROCEDURE get_drived_org_job
  (p_pos_id 	in number
  ,p_org_id    out nocopy number
  ,p_job_id    out nocopy number) IS

  CURSOR csr_position IS
  SELECT organization_id, job_id
    FROM hr_positions_f
   WHERE position_id = p_pos_id
	AND TRUNC(SYSDATE) BETWEEN effective_start_date
	    AND effective_end_date;

BEGIN

   OPEN csr_position;
   FETCH csr_position INTO p_org_id, p_job_id;
   CLOSE csr_position;

END get_drived_org_job;
-- ---------------------------------------------------------------------------
-- get_item
-- ---------------------------------------------------------------------------

FUNCTION get_item
  (p_ids	in varchar2
  ,p_index 	in number)
RETURN varchar2 IS
  l_value	varchar2(2000);
  l_start	integer;
  l_end 	integer;
  l_temp    varchar2(32000);
BEGIN
  l_temp := ','||p_ids||',';
  l_start := instr (l_temp, ',', 1, p_index);
  l_end := instr (l_temp, ',', 1, p_index+1);
  IF l_start = 0 or l_end = 0 THEN
    RETURN null;
  ELSE
    l_value := (rtrim (ltrim(substr(l_temp, l_start + 1,
                      l_end - l_start - 1))));
  END IF;


  RETURN (l_value);


END get_item;
-- ---------------------------------------------------------------------------
-- build_items
-- ---------------------------------------------------------------------------

FUNCTION build_items
  (p_id				in hr_util_misc_web.g_varchar2_tab_type
  ,p_start_index 	in number default 1)
RETURN varchar2 IS
  l_ids				varchar2(32000);
  l_index   		number;
  l_temp            varchar2(2000);
BEGIN
  l_index := p_start_index;
  BEGIN
    LOOP
      IF p_id(l_index) IS null THEN
        l_temp := 'null';
      ELSE
        l_temp := p_id(l_index);
      END IF;
      IF l_ids IS null THEN
        l_ids := l_temp;
      ELSIF (length(l_ids)) < (32000 - 30) THEN
        l_ids := l_ids ||','||l_temp;
      ELSE
        EXIT;
      END IF;
      l_index := l_index + 1;
    END LOOP;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
  END;

  RETURN l_ids;

END build_items;

-- ---------------------------------------------------------------------------
-- build_grade_sql
-- ---------------------------------------------------------------------------

FUNCTION build_grade_sql
  (p_search_type 	in varchar2
  ,p_id 			in number)
RETURN varchar2 IS

  l_dynamic_sql varchar2(32000);
  l_flex_select_clause  varchar2(2000);
  l_flex_where_clause   varchar2(2000);

  l_business_group  varchar2(2000);

BEGIN

  l_business_group := hr_util_misc_web.get_business_group_id;

  keyflex_select_where_clause
    (p_business_group_id => l_business_group
    ,p_keyflex_code => 'GRD'
    ,p_select_clause => l_flex_select_clause
    ,p_where_clause => l_flex_where_clause);

  IF p_search_type = g_job_type THEN
    l_dynamic_sql := 'SELECT distinct(pvg.valid_grade_id),'
                    ||l_flex_select_clause
                    ||' FROM per_valid_grades pvg,'
                    ||' per_grades pg, per_grade_definitions pgd'
                    ||' WHERE pvg.job_id = '||p_id
                    ||'   AND pvg.grade_id = pg.grade_id'
                    ||'   AND pg.grade_definition_id = pgd.grade_definition_id';
  ELSIF p_search_type = g_position_type THEN
    l_dynamic_sql := 'SELECT distinct(pvg.valid_grade_id),'
                    ||l_flex_select_clause
                    ||' FROM per_valid_grades pvg,'
                    ||' per_grades pg, per_grade_definitions pgd'
                    ||' WHERE pvg.position_id = '||p_id
                    ||'   AND pvg.grade_id = pg.grade_id'
                    ||'   AND pg.grade_definition_id = pgd.grade_definition_id';
  ELSE
    RETURN null;
  END IF;
  l_dynamic_sql := l_dynamic_sql || ' ORDER BY 2';
  RETURN l_dynamic_sql;
END build_grade_sql;
-- ---------------------------------------------------------------------------
-- build_sql
-- ---------------------------------------------------------------------------

FUNCTION build_sql
  (p_search_type 	in varchar2
  ,p_ids 			in varchar2)
RETURN varchar2 IS

  l_dynamic_sql varchar2(32000);
  l_flex_select_clause  varchar2(2000);
  l_flex_where_clause   varchar2(2000);

  l_business_group  varchar2(2000);

BEGIN

  hr_util_misc_web.validate_session(p_person_id => c_person_id);
  c_legislation_code := hr_misc_web.get_legislation_code
    (p_person_id => c_person_id);

  l_business_group := hr_util_misc_web.get_business_group_id;

  IF p_search_type = g_location_type THEN	--location
    l_dynamic_sql := 'SELECT location_id, location_code'
                    ||' FROM hr_locations_all'
                    ||' WHERE location_id IN ('
                    ||p_ids
                    ||')';
  ELSIF p_search_type = g_organization_type THEN	--org
    l_dynamic_sql := 'SELECT organization_id, name'
                    ||' FROM hr_organization_units'
                    ||' WHERE organization_id IN ('
                    ||p_ids
                    ||')';
  ELSIF p_search_type = g_job_type THEN	--job

    keyflex_select_where_clause
    (p_business_group_id => l_business_group
    ,p_keyflex_code => 'JOB'
    ,p_select_clause => l_flex_select_clause
    ,p_where_clause => l_flex_where_clause);

    l_dynamic_sql := 'SELECT pj.job_id,'
                    ||l_flex_select_clause
                    ||' FROM per_jobs_vl pj, per_job_definitions pjd'
                    ||' WHERE pj.job_definition_id = pjd.job_definition_id'
                    ||' AND pj.job_id IN ('
                    ||p_ids
                    ||')';
  ELSIF p_search_type = g_position_type THEN

    keyflex_select_where_clause
    (p_business_group_id => l_business_group
    ,p_keyflex_code => 'POS'
    ,p_select_clause => l_flex_select_clause
    ,p_where_clause => l_flex_where_clause);

    l_dynamic_sql := 'SELECT pp.position_id,'
                    ||l_flex_select_clause
                    ||' FROM hr_positions_f pp, per_position_definitions ppd'
              ||' WHERE TRUNC(SYSDATE) BETWEEN pp.effective_start_date'
		    ||' AND pp.effective_end_date'
  		    ||' AND pp.position_definition_id = ppd.position_definition_id'
                    ||' AND pp.position_id IN ('
                    ||p_ids
                    ||')';
  ELSIF p_search_type = g_vacancy_type THEN	--vacancy
    l_dynamic_sql := 'SELECT pv.vacancy_id'
                    ||',pv.name || '' (''||pr.name||'')'' name'
                    ||' FROM per_vacancies pv, per_requisitions pr'
                    ||' WHERE pv.vacancy_id IN ('
                    ||p_ids
                    ||')'
                    ||' AND pv.requisition_id = pr.requisition_id';
  ELSIF p_search_type = g_grade_type THEN	--grade

    keyflex_select_where_clause
    (p_business_group_id => l_business_group
    ,p_keyflex_code => 'GRD'
    ,p_select_clause => l_flex_select_clause
    ,p_where_clause => l_flex_where_clause);

    l_dynamic_sql := 'SELECT pg.grade_id,'
                    ||l_flex_select_clause
                    ||' FROM per_grades pg, per_grade_definitions pgd'
                    ||' WHERE pg.grade_definition_id = pgd.grade_definition_id'
                    ||' AND pg.grade_id IN ('
                    ||p_ids
                    ||')';
  ELSIF p_search_type = g_class_type THEN	--class
    l_dynamic_sql := 'SELECT activity_version_id, version_name'
                    ||' FROM ota_activity_versions'
                    ||' WHERE activity_version_id IN ('
                    ||p_ids
                    ||')';
  ELSIF p_search_type = g_people_type THEN	--people
    l_dynamic_sql := 'SELECT ppf.person_id';
      l_dynamic_sql := l_dynamic_sql
        ||',ppf.full_name name';
    l_dynamic_sql := l_dynamic_sql
      ||' FROM per_people_f ppf'
      ||' WHERE ppf.person_id IN ('
      ||p_ids
      ||')';
  ELSE
    RETURN null;
  END IF;

  l_dynamic_sql := l_dynamic_sql || ' ORDER BY 2';
  RETURN  l_dynamic_sql;

END build_sql;

FUNCTION get_system_person_type(p_person_type_id in number)
RETURN varchar2 IS

  CURSOR csr_sys_person_type IS
  SELECT system_person_type
    FROM per_person_types
   WHERE person_type_id = p_person_type_id;

  l_sys_person_type        varchar2(2000);

BEGIN

  OPEN csr_sys_person_type;
  FETCH csr_sys_person_type INTO l_sys_person_type;
  CLOSE csr_sys_person_type;

  RETURN l_sys_person_type;

END get_system_person_type;
-- ---------------------------------------------------------------------------
-- build_sql
-- ---------------------------------------------------------------------------

FUNCTION build_sql
  (p_mode				    in varchar2
  ,p_person_type_id         in varchar2 default null
  ,p_assignment_type 		in varchar2 default null
  ,p_pre_search_type  		in varchar2
  ,p_pre_search_ids 		in varchar2
  ,p_search_type 			in varchar2
  ,p_filer_match 			in varchar2
  ,p_search_criteria 		in varchar2)
RETURN varchar2 IS


  CURSOR csr_all_emp_person_type_id(p_business_group_id in number) IS
  SELECT person_type_id
    FROM per_person_types
   WHERE (system_person_type = 'EMP' )
     AND business_group_id = p_business_group_id;

  CURSOR csr_all_apl_person_type_id(p_business_group_id in number) IS
  SELECT person_type_id
    FROM per_person_types
   WHERE system_person_type = 'APL'
     AND business_group_id = p_business_group_id;



  l_dynamic_sql varchar2(32000);
  l_filter_clause  varchar2(2000);
  l_business_group  varchar2(2000);
  l_job_flex_select_clause  varchar2(2000);
  l_job_flex_where_clause  varchar2(2000);
  l_pos_flex_select_clause  varchar2(2000);
  l_pos_flex_where_clause  varchar2(2000);
  l_grd_flex_select_clause  varchar2(2000);
  l_grd_flex_where_clause  varchar2(2000);

  l_assignment_type        varchar2(2000);
  l_sys_person_type        varchar2(2000);
  l_person_type_ids        varchar2(2000);


BEGIN

  l_business_group := hr_util_misc_web.get_business_group_id;

  l_filter_clause := hr_suit_match_utility_web.process_filter
                        (p_filter_match => p_filer_match
                        ,p_search_criteria => p_search_criteria);

  keyflex_select_where_clause
    (p_business_group_id => l_business_group
    ,p_keyflex_code => 'JOB'
    ,p_filter_clause => l_filter_clause
    ,p_select_clause => l_job_flex_select_clause
    ,p_where_clause => l_job_flex_where_clause);

  keyflex_select_where_clause
    (p_business_group_id => l_business_group
    ,p_keyflex_code => 'POS'
    ,p_filter_clause => l_filter_clause
    ,p_select_clause => l_pos_flex_select_clause
    ,p_where_clause => l_pos_flex_where_clause);

  keyflex_select_where_clause
    (p_business_group_id => l_business_group
    ,p_keyflex_code => 'GRD'
    ,p_filter_clause => l_filter_clause
    ,p_select_clause => l_grd_flex_select_clause
    ,p_where_clause => l_grd_flex_where_clause);

  IF p_mode = g_person_search_mode THEN
    IF p_person_type_id = '-1' THEN  --all employees
      l_person_type_ids := '(-1';     --'-1' is dummy number;
      FOR v_person_type_id IN csr_all_emp_person_type_id(l_business_group) LOOP
        l_person_type_ids := l_person_type_ids ||','
                            ||v_person_type_id.person_type_id;
      END LOOP;
      l_person_type_ids := l_person_type_ids ||')';
      l_assignment_type := 'paf.assignment_type';
    ELSIF p_person_type_id = '-2' THEN --all applicants
      l_person_type_ids := '(-1';     --'-1' is dummy number;
      FOR v_person_type_id IN csr_all_apl_person_type_id(l_business_group) LOOP
        l_person_type_ids := l_person_type_ids ||','
                            ||v_person_type_id.person_type_id;
      END LOOP;
      l_person_type_ids := l_person_type_ids ||')';
      l_assignment_type := 'paf.assignment_type';
    ELSE
      l_person_type_ids := '('||p_person_type_id||')';
      l_sys_person_type := get_system_person_type(p_person_type_id);
      IF l_sys_person_type = 'EMP_APL' THEN
        l_assignment_type := 'paf.assignment_type';
      ELSE
        l_assignment_type := ''''|| p_assignment_type ||'''';
      END IF;
    END IF;
    IF p_search_type = g_location_type THEN
      l_dynamic_sql := 'SELECT DISTINCT(paf.location_id) id'
                    ||' ,hl.location_code name'
                    ||' FROM per_assignments_f paf'
                    ||'     ,per_people_f ppf'
                    ||'     ,per_person_type_usages_f ptu'
                    ||'     ,hr_locations_all hl'
                    ||' WHERE paf.business_group_id = '
                    ||l_business_group
                    ||' AND paf.assignment_type = '||l_assignment_type
                    ||' AND ppf.person_id = ptu.person_id '
                    ||' AND ppf.person_type_id IN '||l_person_type_ids
                    ||' AND TRUNC(sysdate) BETWEEN ptu.effective_start_date '
                    ||' AND ptu.effective_end_date'
                    ||' AND TRUNC(sysdate) BETWEEN ppf.effective_start_date'
                    ||'     AND ppf.effective_end_date'
                    ||' AND ppf.person_id = paf.person_id'
                    ||' AND TRUNC(sysdate) BETWEEN paf.effective_start_date'
                    ||'     AND paf.effective_end_date'
                    ||' AND paf.location_id = hl.location_id'
                    ||' AND UPPER(hl.location_code) '
                    || l_filter_clause;
      IF p_pre_search_type IS NOT null THEN
	    IF p_pre_search_type = g_organization_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.organization_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_job_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.job_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_grade_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.grade_id IN '
                        || '('||p_pre_search_ids||')';
        END IF;
      END IF;
    ELSIF p_search_type = g_organization_type THEN
      l_dynamic_sql := 'SELECT DISTINCT(paf.organization_id) id'
                    ||' ,hou.name name'
                    ||' FROM per_assignments_f paf'
                    ||'     ,per_people_f ppf'
                    ||'     ,per_person_type_usages_f ptu'
                    ||'     ,hr_organization_units hou'
                    ||' WHERE paf.business_group_id = '
                    ||l_business_group
                    ||' AND paf.assignment_type = '||l_assignment_type
                    ||' AND ppf.person_id = ptu.person_id '
                    ||' AND ppf.person_type_id IN '||l_person_type_ids
                    ||' AND TRUNC(sysdate) between ptu.effective_start_date'
                    ||' AND ptu.effective_end_date'
                    ||' AND TRUNC(sysdate) BETWEEN paf.effective_start_date'
                    ||'     AND paf.effective_end_date'
                    ||' AND ppf.person_id = paf.person_id'
                    ||' AND TRUNC(sysdate) BETWEEN ppf.effective_start_date'
                    ||'     AND ppf.effective_end_date'
                    ||' AND paf.organization_id = hou.organization_id'
                    ||' AND UPPER(hou.name) '
                    || l_filter_clause;
      IF p_pre_search_type IS NOT null THEN
        IF p_pre_search_type = g_location_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.location_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_job_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.job_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_grade_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.grade_id IN '
                        || '('||p_pre_search_ids||')';
        END IF;
      END IF;
    ELSIF p_search_type = g_job_type THEN
      l_dynamic_sql := 'SELECT DISTINCT(paf.job_id) id'
                    ||','|| l_job_flex_select_clause
                    ||' FROM per_assignments_f paf'
                    ||'     ,per_people_f ppf'
                    ||'     ,per_person_type_usages_f ptu'
                    ||'     ,per_jobs_vl pj'
                    ||'     ,per_job_definitions pjd'
                    ||' WHERE paf.business_group_id = '
                    ||l_business_group
                    ||' AND paf.assignment_type = '||l_assignment_type
                    ||' AND ppf.person_id = ptu.person_id '
                    ||' AND ppf.person_type_id IN '||l_person_type_ids
                    ||' AND TRUNC(sysdate) between ptu.effective_start_date'
                    ||' AND ptu.effective_end_date'
                    ||' AND TRUNC(sysdate) BETWEEN paf.effective_start_date'
                    ||'     AND paf.effective_end_date'
                    ||' AND ppf.person_id = paf.person_id'
                    ||' AND TRUNC(sysdate) BETWEEN ppf.effective_start_date'
                    ||'     AND ppf.effective_end_date'
                    ||' AND paf.job_id = pj.job_id'
                    ||' AND pj.job_definition_id = pjd.job_definition_id'
                    ||' AND '
                    ||l_job_flex_where_clause;
      IF p_pre_search_type IS NOT null THEN
        IF p_pre_search_type = g_location_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.location_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_organization_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.organization_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_grade_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.grade_id IN '
                        || '('||p_pre_search_ids||')';
        END IF;
      END IF;

    ELSIF p_search_type = g_position_type THEN
      l_dynamic_sql := 'SELECT DISTINCT(paf.position_id) id'
                    ||','|| l_pos_flex_select_clause
                    ||' FROM per_assignments_f paf'
                    ||'     ,per_people_f ppf'
                    ||'     ,per_person_type_usages_f ptu'
                    ||'     ,hr_positions_f pp'
                    ||'     ,per_position_definitions ppd'
                    ||' WHERE paf.business_group_id = '
                    ||l_business_group
                    ||' AND paf.assignment_type = '||l_assignment_type
                    ||' AND ppf.person_id = ptu.person_id '
                    ||' AND ppf.person_type_id IN '||l_person_type_ids
                    ||' AND TRUNC(sysdate) between ptu.effective_start_date'
                    ||' AND ptu.effective_end_date'
                    ||' AND TRUNC(sysdate) BETWEEN paf.effective_start_date'
                    ||'     AND paf.effective_end_date'
                    ||' AND ppf.person_id = paf.person_id'
                    ||' AND TRUNC(sysdate) BETWEEN ppf.effective_start_date'
                    ||'     AND ppf.effective_end_date'
                    ||' AND paf.position_id = pp.position_id'
                 ||' AND TRUNC(SYSDATE) BETWEEN pp.effective_start_date'
			  ||' AND pp.effective_end_date'
                 ||' AND pp.position_definition_id = ppd.position_definition_id'
                 ||' AND (pp.status is null OR pp.status <> ''INVALID'')'
                    ||' AND '
                    ||l_pos_flex_where_clause;
      IF p_pre_search_type IS NOT null THEN
        IF p_pre_search_type = g_location_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.location_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_organization_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.organization_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_job_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.job_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_grade_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.grade_id IN '
                        || '('||p_pre_search_ids||')';
        END IF;
      END IF;
    ELSIF p_search_type = g_vacancy_type THEN
      l_dynamic_sql := 'SELECT DISTINCT(paf.vacancy_id) id'
                    ||',pv.name || '' (''||pr.name||'')'' name'
                    ||' FROM per_assignments_f paf'
                    ||'     ,per_people_f ppf'
                    ||'     ,per_person_type_usages_f ptu'
                    ||'     ,per_vacancies pv'
                    ||'     ,per_requisitions pr'
                    ||' WHERE paf.business_group_id = '
                    ||l_business_group
                    ||' AND paf.assignment_type = '||l_assignment_type
                    ||' AND ppf.person_id = ptu.person_id '
                    ||' AND ppf.person_type_id IN '||l_person_type_ids
                    ||' AND TRUNC(sysdate) between ptu.effective_start_date'
                    ||' AND ptu.effective_end_date'
                    ||' AND TRUNC(sysdate) BETWEEN paf.effective_start_date'
                    ||'     AND paf.effective_end_date'
                    ||' AND ppf.person_id = paf.person_id'
                    ||' AND TRUNC(sysdate) BETWEEN ppf.effective_start_date'
                    ||'     AND ppf.effective_end_date'
                    ||' AND paf.vacancy_id = pv.vacancy_id'
                    ||' AND pv.requisition_id = pr.requisition_id'
                    ||' AND UPPER(pv.name) '
                    || l_filter_clause;
      IF p_pre_search_type IS NOT null THEN
        IF p_pre_search_type = g_location_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.location_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_organization_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.organization_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_job_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.job_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_position_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.position_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_grade_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.grade_id IN '
                        || '('||p_pre_search_ids||')';
        END IF;
      END IF;
    ELSIF p_search_type = g_grade_type THEN
      l_dynamic_sql := 'SELECT DISTINCT(paf.grade_id) id'
                    ||','|| l_grd_flex_select_clause
                    ||' FROM per_assignments_f paf'
                    ||'     ,per_people_f ppf'
                    ||'     ,per_person_type_usages_f ptu'
                    ||'     ,per_grades pg'
                    ||'     ,per_grade_definitions pgd'
                    ||' WHERE paf.business_group_id = '
                    ||l_business_group
                    ||' AND paf.assignment_type = '||l_assignment_type
                    ||' AND ppf.person_id = ptu.person_id '
                    ||' AND ppf.person_type_id IN '||l_person_type_ids
                    ||' AND TRUNC(sysdate) between ptu.effective_start_date'
                    ||' AND ptu.effective_end_date'
                    ||' AND TRUNC(sysdate) BETWEEN paf.effective_start_date'
                    ||'     AND paf.effective_end_date'
                    ||' AND ppf.person_id = paf.person_id'
                    ||' AND TRUNC(sysdate) BETWEEN ppf.effective_start_date'
                    ||'     AND ppf.effective_end_date'
                    ||' AND paf.grade_id = pg.grade_id'
                    ||' AND pg.grade_definition_id = pgd.grade_definition_id'
                    ||' AND '
                    ||l_grd_flex_where_clause;
      IF p_pre_search_type IS NOT null THEN
        IF p_pre_search_type = g_location_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.location_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_organization_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.organization_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_job_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.job_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_position_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.position_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_vacancy_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND paf.vacancy_id IN '
                        || '('||p_pre_search_ids||')';
        END IF;
      END IF;
    END IF;
  ELSE
    IF p_search_type = g_location_type THEN
      l_dynamic_sql := 'SELECT location_id, location_code'
                    ||' FROM hr_locations_all'
                    ||' WHERE UPPER(location_code) '
                    || l_filter_clause;
    ELSIF p_search_type = g_organization_type THEN
      l_dynamic_sql := 'SELECT distinct(hou.organization_id), hou.name'
                    ||' FROM hr_organization_units hou,'
					||' hr_organization_information hoi'
                    ||' WHERE hou.business_group_id = '
                    ||l_business_group
		||' AND TRUNC(sysdate) BETWEEN hou.date_from AND'
		||' NVL(hou.date_to, TRUNC(sysdate))'
		||' AND hou.organization_id = hoi.organization_id'
		||' AND hoi.org_information_context = ''CLASS'''
                ||' AND hoi.org_information1 IN (''HR_BG'',''HR_ORG'')'
                    ||' AND UPPER(hou.name) '
                    || l_filter_clause;
      IF p_pre_search_type IS NOT null THEN
        IF p_pre_search_type = g_location_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND location_id IN '
                        || '('||p_pre_search_ids||')';
        END IF;
      END IF;
    ELSIF p_search_type = g_job_type THEN	--job
      l_dynamic_sql := 'SELECT job_id, name'
                    ||' FROM per_jobs_vl'
                    ||' WHERE business_group_id = '
                    ||l_business_group
					||' AND TRUNC(sysdate) BETWEEN date_from AND'
					||' NVL(date_to,TRUNC(sysdate))'
                    ||' AND UPPER(name) '
                    || l_filter_clause;
    ELSIF p_search_type = g_position_type THEN
      l_dynamic_sql := 'SELECT position_id, name'
                    ||' FROM hr_positions_f'
                    ||' WHERE business_group_id = '
                    ||l_business_group
          ||' AND TRUNC(sysdate) BETWEEN effective_start_date'
		||' AND effective_end_date'
		||' AND TRUNC(sysdate) BETWEEN date_effective AND'
		||' NVL(date_end, TRUNC(sysdate))'
                ||' AND (status is null OR status <> ''INVALID'')'
                    ||' AND UPPER(name) '
                    || l_filter_clause;
      IF p_pre_search_type IS NOT null THEN
        IF p_pre_search_type = g_location_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND location_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_job_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND job_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_organization_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND organization_id IN '
                        || '('||p_pre_search_ids||')';
        END IF;
      END IF;
    ELSIF p_search_type = g_vacancy_type THEN
      l_dynamic_sql := 'SELECT pv.vacancy_id'
                    ||',pv.name || '' (''||pr.name||'')'' name'
                    ||' FROM per_vacancies pv, per_requisitions pr'
                    ||' WHERE pv.business_group_id = '
                    ||l_business_group
	            ||' AND TRUNC(sysdate) BETWEEN pv.date_from AND'
		    ||' NVL(pv.date_to, TRUNC(sysdate))'
                    ||' AND UPPER(pv.name) '
                    || l_filter_clause
                    ||' AND pv.requisition_id = pr.requisition_id';
      IF p_pre_search_type IS NOT null THEN
        IF p_pre_search_type = g_location_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND location_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_job_type THEN -- job
          l_dynamic_sql := l_dynamic_sql
                        || ' AND job_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_organization_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND organization_id IN '
                        || '('||p_pre_search_ids||')';
        ELSIF p_pre_search_type = g_position_type THEN
          l_dynamic_sql := l_dynamic_sql
                        || ' AND position_id IN '
                        || '('||p_pre_search_ids||')';
        END IF;
      END IF;
    ELSE
      RETURN null;
    END IF;
  END IF;

  l_dynamic_sql := l_dynamic_sql || ' ORDER BY 2';

  RETURN  l_dynamic_sql;

END build_sql;

-- ---------------------------------------------------------------------------
-- get_id_name
-- ---------------------------------------------------------------------------

PROCEDURE get_id_name
  (p_dynamic_sql 	in varchar2
  ,p_id		     out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name		 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count        out nocopy number) IS

  l_sql_cursor		integer;
  l_rows            integer;
  l_index 			number;
  c_id				number;
  c_name			varchar2(240);

BEGIN
  l_sql_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_sql_cursor, p_dynamic_sql, dbms_sql.v7);
  dbms_sql.define_column(l_sql_cursor, 1, c_id, 15);
  dbms_sql.define_column(l_sql_cursor, 2, c_name, 240);
  l_rows := dbms_sql.execute(l_sql_cursor);
  l_index := 0;
  WHILE dbms_sql.fetch_rows(l_sql_cursor) > 0 LOOP
    l_index := l_index + 1;
    dbms_sql.column_value(l_sql_cursor, 1, p_id(l_index));
    dbms_sql.column_value(l_sql_cursor, 2, p_name(l_index));
  END LOOP;
  p_count := l_index;

  dbms_sql.close_cursor(l_sql_cursor);

EXCEPTION
  WHEN others THEN
    IF dbms_sql.is_open(l_sql_cursor) THEN
      dbms_sql.close_cursor(l_sql_cursor);
    END IF;
END get_id_name;

-- ---------------------------------------------------------------------------
-- get_header
-- ---------------------------------------------------------------------------

PROCEDURE get_job_info
  (p_search_type 	in varchar2
  ,p_id 		   	in varchar2
  ,p_name           out nocopy varchar2
  ,p_org_name       out nocopy varchar2
  ,p_location_code  out nocopy varchar2) IS

  CURSOR csr_org_info IS
  SELECT hou.name, hl.location_code
    FROM hr_organization_units hou,
         hr_locations_all hl
   WHERE hou.organization_id = p_id
     AND hou.location_id = hl.location_id(+);

  CURSOR csr_pos_info IS
  SELECT hou.name, hl.location_code
    FROM hr_positions_f pp,
         hr_organization_units hou,
         hr_locations_all hl
   WHERE pp.position_id = p_id
	AND TRUNC(SYSDATE) BETWEEN pp.effective_start_date
	    AND pp.effective_end_date
     AND pp.organization_id = hou.organization_id
     AND hou.location_id = hl.location_id(+);

  CURSOR csr_vac_info IS
  SELECT pv.name || ' (' || pr.name ||')'
        ,hou.name
        ,hl.location_code
    FROM per_vacancies pv,
         per_requisitions pr,
         hr_organization_units hou,
         hr_locations_all hl
   WHERE pv.vacancy_id = p_id
     AND pv.requisition_id = pr.requisition_id
     AND pv.organization_id = hou.organization_id(+)
     AND hou.location_id = hl.location_id(+);

  l_dynamic_sql varchar2(32000);
  l_id			hr_util_misc_web.g_varchar2_tab_type;
  l_name		hr_util_misc_web.g_varchar2_tab_type;
  l_count		number;

BEGIN

  IF p_search_type IS null THEN
    return;
  END IF;

  l_dynamic_sql := hr_suit_match_utility_web.build_sql
                        (p_search_type => p_search_type
  	        			,p_ids => p_id);

  IF p_search_type = g_organization_type THEN
    OPEN csr_org_info;
    FETCH csr_org_info INTO p_name, p_location_code;
    CLOSE csr_org_info;
  ELSIF p_search_type = g_position_type THEN
    hr_suit_match_utility_web.get_id_name
  	           (p_dynamic_sql => l_dynamic_sql
  	           ,p_id => l_id
  	           ,p_name => l_name
  	           ,p_count => l_count);
  	IF l_count > 0 THEN
  	  p_name := l_name(1);
  	  OPEN csr_pos_info;
      FETCH csr_pos_info INTO p_org_name, p_location_code;
      CLOSE csr_pos_info;
  	END IF;
  ELSIF p_search_type = g_job_type THEN
    hr_suit_match_utility_web.get_id_name
  	           (p_dynamic_sql => l_dynamic_sql
  	           ,p_id => l_id
  	           ,p_name => l_name
  	           ,p_count => l_count);
  	IF l_count > 0 THEN
  	  p_name := l_name(1);
  	END IF;
  ELSIF p_search_type = g_vacancy_type THEN
    OPEN csr_vac_info;
    FETCH csr_vac_info INTO p_name, p_org_name, p_location_code;
    CLOSE csr_vac_info;
  END IF;

END get_job_info;
FUNCTION  process_filter
  (p_filter_match in varchar2
  ,p_search_criteria in varchar2)
RETURN varchar2 IS

  l_filter_clause  varchar2(2000);
  l_search_criteria varchar2(2000);

BEGIN

  l_search_criteria := REPLACE(p_search_criteria, '''', '''''');

  IF p_filter_match = 1 THEN	--is
    l_filter_clause := 'like '''||UPPER(l_search_criteria)||'''';
  ELSIF p_filter_match = 2 THEN	--is not
    IF p_search_criteria is null THEN
      l_filter_clause := 'is not null';
    ELSE
      l_filter_clause := 'not like '''||UPPER(l_search_criteria)||'''';
    END IF;
  ELSIF p_filter_match = 3 THEN	--contains
    l_filter_clause := 'like '''||'%'||UPPER(l_search_criteria)||'%''';
  ELSIF p_filter_match = 4 THEN	--starts with
    l_filter_clause := 'like '''||UPPER(l_search_criteria)||'%''';
  ELSIF p_filter_match = 5 THEN	--ends with
    l_filter_clause := 'like '''||'%'||UPPER(l_search_criteria)||'''';
  END IF;

  RETURN l_filter_clause;

END process_filter;

-- ---------------------------------------------------------------------------
-- get_vac_competencies
-- ---------------------------------------------------------------------------

PROCEDURE get_vac_competencies
  (p_vacancy_id in number
  ,p_effective_date in date default sysdate
  ,p_include_core_competencies in varchar2 default 'N'
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number
  ,p_essential_count out nocopy number
  ,p_desirable_count out nocopy number) IS

  CURSOR  csr_vacancy IS
  SELECT  business_group_id
         ,organization_id
         ,job_id
         ,position_id
         ,grade_id
    FROM per_vacancies
   WHERE vacancy_id = p_vacancy_id;

  l_vacancy_rec csr_vacancy%rowtype;

BEGIN

  OPEN csr_vacancy;
  FETCH csr_vacancy INTO l_vacancy_rec;
  CLOSE csr_vacancy;

  IF l_vacancy_rec.position_id IS NOT null THEN
    get_all_pos_competencies(p_pos_id => l_vacancy_rec.position_id
                    ,p_grade_id => l_vacancy_rec.grade_id
                    ,p_include_core_competencies => p_include_core_competencies
                    ,p_competence_table => p_competence_table
                      ,p_competence_count => p_competence_count
                      ,p_essential_count => p_essential_count
                      ,p_desirable_count => p_desirable_count);
  ELSIF l_vacancy_rec.job_id IS NOT null THEN
    get_job_competencies(p_job_id => l_vacancy_rec.job_id
                      ,p_grade_id => l_vacancy_rec.grade_id
                     ,p_include_core_competencies => p_include_core_competencies
                      ,p_competence_table => p_competence_table
                      ,p_competence_count => p_competence_count
                      ,p_essential_count => p_essential_count
                      ,p_desirable_count => p_desirable_count);
  ELSIF l_vacancy_rec.organization_id IS NOT null THEN
    get_org_competencies(p_org_id => l_vacancy_rec.organization_id
                     ,p_include_core_competencies => p_include_core_competencies
                      ,p_competence_table => p_competence_table
                      ,p_competence_count => p_competence_count
                      ,p_essential_count => p_essential_count
                      ,p_desirable_count => p_desirable_count);
  ELSIF l_vacancy_rec.business_group_id IS NOT null THEN
    get_org_competencies(p_org_id => l_vacancy_rec.business_group_id
                     ,p_include_core_competencies => p_include_core_competencies
                      ,p_competence_table => p_competence_table
                      ,p_competence_count => p_competence_count
                      ,p_essential_count => p_essential_count
                      ,p_desirable_count => p_desirable_count);
  END IF;

END get_vac_competencies;

-- ---------------------------------------------------------------------------
-- get_core_competencies
-- ---------------------------------------------------------------------------

PROCEDURE get_core_competencies
  (p_business_group_id in number default null
  ,p_effective_date in date default sysdate
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number
  ,p_essential_count out nocopy number
  ,p_desirable_count out nocopy number) IS

  CURSOR csr_competencies_by_core(p_core_id in number) IS
   SELECT pce.competence_element_id,
          pce.effective_date_from,
          pce.proficiency_level_id,
          pce.high_proficiency_level_id,
          pce.mandatory,
          cpl.competence_id,
          cpl.name,
          r1.step_value  low_step_value,
          r2.step_value  high_step_value,
          rtx1.name low_step_name,
          rtx2.name high_step_name
     FROM per_competence_elements pce,
          per_competences_tl cpl,
          per_rating_levels r1,
          per_rating_levels r2,
          per_rating_levels_tl rtx1,
          per_rating_levels_tl rtx2
    WHERE pce.ENTERPRISE_ID = p_core_id
      AND pce.type = 'REQUIREMENT'
      AND pce.organization_id IS null
      AND pce.job_id IS null
      AND pce.position_id IS null
      AND p_effective_date BETWEEN pce.effective_date_from AND
          NVL(pce.effective_date_to, p_effective_date)
      AND pce.competence_id = cpl.competence_id
      AND cpl.language = userenv('LANG')
      AND pce.proficiency_level_id = r1.rating_level_id(+)
      AND pce.high_proficiency_level_id = r2.rating_level_id(+)
      AND pce.proficiency_level_id = rtx1.rating_level_id(+)
      AND pce.high_proficiency_level_id = rtx2.rating_level_id(+)
      AND rtx1.language(+) = userenv('LANG')
      AND rtx2.language(+) = userenv('LANG')
    ORDER BY cpl.name;

  l_business_group_id hr_organization_units.business_group_id%type;

  l_core_competence_table 	g_competence_table;
  l_core_count	number;
  l_core_e_count	number;
  l_core_d_count	number;

BEGIN

  IF p_business_group_id IS null THEN
    l_business_group_id := hr_util_misc_web.get_business_group_id;
  ELSE
    l_business_group_id := p_business_group_id;
  END IF;

  p_competence_count := 0;
  p_essential_count := 0;
  p_desirable_count := 0;

  FOR v_competence IN csr_competencies_by_core(l_business_group_id) LOOP

    p_competence_count := p_competence_count +1;
    p_competence_table(p_competence_count).competence_element_id :=
        v_competence.competence_element_id;
    p_competence_table(p_competence_count).effective_date_from :=
        v_competence.effective_date_from;
    p_competence_table(p_competence_count).competence_id :=
        v_competence.competence_id;
    p_competence_table(p_competence_count).competence_name :=
        v_competence.name;
    p_competence_table(p_competence_count).low_rating_level_id :=
        v_competence.proficiency_level_id;
    p_competence_table(p_competence_count).high_rating_level_id :=
        v_competence.high_proficiency_level_id;
    p_competence_table(p_competence_count).low_step_value :=
        v_competence.low_step_value;
    p_competence_table(p_competence_count).low_step_name :=
        v_competence.low_step_name;
    p_competence_table(p_competence_count).high_step_value :=
        v_competence.high_step_value;
    p_competence_table(p_competence_count).high_step_name :=
        v_competence.high_step_name;
    p_competence_table(p_competence_count).mandatory :=
        v_competence.mandatory;
    IF v_competence.mandatory = 'Y' THEN
      p_essential_count := p_essential_count + 1;
    ELSE
      p_desirable_count := p_desirable_count + 1;
    END IF;

  END LOOP;

END get_core_competencies;
-- ---------------------------------------------------------------------------
-- get_org_competencies
-- ---------------------------------------------------------------------------
PROCEDURE get_org_competencies
  (p_org_id in number
  ,p_effective_date in date
  ,p_include_core_competencies in varchar2 default 'N'
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number
  ,p_essential_count out nocopy number
  ,p_desirable_count out nocopy number) IS

  CURSOR csr_competencies_by_org IS
   SELECT pce.competence_element_id,
          pce.effective_date_from,
          pce.proficiency_level_id,
          pce.high_proficiency_level_id,
          pce.mandatory,
          cpl.competence_id,
          cpl.name,
          r1.step_value  low_step_value,
          rtx1.name low_step_name,
          r2.step_value  high_step_value,
          rtx2.name high_step_name
     FROM per_competence_elements pce,
          per_competences_tl cpl,
          per_rating_levels r1,
          per_rating_levels r2,
          per_rating_levels_tl rtx1,
          per_rating_levels_tl rtx2
    WHERE pce.organization_id = p_org_id
      AND pce.type = 'REQUIREMENT'
      AND p_effective_date BETWEEN pce.effective_date_from AND
          NVL(pce.effective_date_to, p_effective_date)
      AND pce.competence_id = cpl.competence_id
      AND cpl.language = userenv('LANG')
      AND pce.proficiency_level_id = r1.rating_level_id(+)
      AND pce.high_proficiency_level_id = r2.rating_level_id(+)
      AND pce.proficiency_level_id = rtx1.rating_level_id(+)
      AND pce.high_proficiency_level_id = rtx2.rating_level_id(+)
      AND rtx1.language(+) = userenv('LANG')
      AND rtx2.language(+) = userenv('LANG')
    ORDER BY cpl.name;

  l_core_competence_table 	g_competence_table;
  l_core_count	number;
  l_core_e_count	number;
  l_core_d_count	number;

BEGIN

  p_competence_count := 0;
  p_essential_count := 0;
  p_desirable_count := 0;

  FOR v_competence IN csr_competencies_by_org LOOP

    p_competence_count := p_competence_count +1;
    p_competence_table(p_competence_count).competence_element_id :=
        v_competence.competence_element_id;
    p_competence_table(p_competence_count).effective_date_from :=
        v_competence.effective_date_from;
    p_competence_table(p_competence_count).competence_id :=
        v_competence.competence_id;
    p_competence_table(p_competence_count).competence_name :=
        v_competence.name;
    p_competence_table(p_competence_count).low_rating_level_id :=
        v_competence.proficiency_level_id;
    p_competence_table(p_competence_count).high_rating_level_id :=
        v_competence.high_proficiency_level_id;
    p_competence_table(p_competence_count).low_step_value :=
        v_competence.low_step_value;
    p_competence_table(p_competence_count).low_step_name :=
        v_competence.low_step_name;
    p_competence_table(p_competence_count).high_step_value :=
        v_competence.high_step_value;
    p_competence_table(p_competence_count).high_step_name :=
        v_competence.high_step_name;
    p_competence_table(p_competence_count).mandatory :=
        v_competence.mandatory;
    IF v_competence.mandatory = 'Y' THEN
      p_essential_count := p_essential_count + 1;
    ELSE
      p_desirable_count := p_desirable_count + 1;
    END IF;

  END LOOP;

  IF p_include_core_competencies = 'Y' THEN
    get_core_competencies
      (p_competence_table => l_core_competence_table
      ,p_competence_count => l_core_count
      ,p_essential_count => l_core_e_count
      ,p_desirable_count => l_core_d_count);

    process_exclusive_competence
      (p_checked_competence_table => l_core_competence_table
      ,p_against_competence_table => p_competence_table
      ,p_competence_count         => p_competence_count
      ,p_essential_count          => p_essential_count
      ,p_desirable_count          => p_desirable_count);

  END IF;

END get_org_competencies;
-- ---------------------------------------------------------------------------
-- get_job_competencies
-- ---------------------------------------------------------------------------
PROCEDURE get_job_competencies
  (p_job_id in number
  ,p_grade_id in number
  ,p_effective_date in date
  ,p_include_core_competencies in varchar2 default 'N'
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number
  ,p_essential_count out nocopy number
  ,p_desirable_count out nocopy number) IS

  CURSOR csr_competencies_by_job IS
   SELECT pce.competence_element_id,
          pce.effective_date_from,
          pce.proficiency_level_id,
          pce.high_proficiency_level_id,
          pce.mandatory,
          cpl.competence_id,
          cpl.name,
          r1.step_value  low_step_value,
          rtx1.name low_step_name,
          r2.step_value  high_step_value,
          rtx2.name high_step_name
     FROM per_competence_elements pce,
          per_competences_tl cpl,
          per_rating_levels r1,
          per_rating_levels r2,
          per_rating_levels_tl rtx1,
          per_rating_levels_tl rtx2
    WHERE pce.job_id = p_job_id
      AND (pce.valid_grade_id IS null
            -- OR pce.valid_grade_id = p_grade_id)
           OR pce.valid_grade_id in (select pvg.valid_grade_id
              from per_valid_grades pvg
              where pvg.grade_id = p_grade_id
              and trunc(sysdate) between pvg.DATE_FROM and
              nvl(pvg.DATE_TO, trunc(sysdate))))
      AND pce.type = 'REQUIREMENT'
      AND p_effective_date BETWEEN pce.effective_date_from AND
          NVL(pce.effective_date_to, p_effective_date)
      AND pce.competence_id = cpl.competence_id
      AND cpl.language = userenv('LANG')
      AND pce.proficiency_level_id = r1.rating_level_id(+)
      AND pce.high_proficiency_level_id = r2.rating_level_id(+)
      AND pce.proficiency_level_id = rtx1.rating_level_id(+)
      AND pce.high_proficiency_level_id = rtx2.rating_level_id(+)
      AND rtx1.language(+) = userenv('LANG')
      AND rtx2.language(+) = userenv('LANG')
    ORDER BY cpl.name;

  l_core_competence_table 	g_competence_table;
  l_core_count	number;
  l_core_e_count	number;
  l_core_d_count	number;

BEGIN

  p_competence_count := 0;
  p_essential_count := 0;
  p_desirable_count := 0;

  FOR v_competence IN csr_competencies_by_job LOOP

    p_competence_count := p_competence_count +1;
    p_competence_table(p_competence_count).competence_element_id :=
        v_competence.competence_element_id;
    p_competence_table(p_competence_count).effective_date_from :=
        v_competence.effective_date_from;
    p_competence_table(p_competence_count).competence_id :=
        v_competence.competence_id;
    p_competence_table(p_competence_count).competence_name :=
        v_competence.name;
    p_competence_table(p_competence_count).low_rating_level_id :=
        v_competence.proficiency_level_id;
    p_competence_table(p_competence_count).high_rating_level_id :=
        v_competence.high_proficiency_level_id;
    p_competence_table(p_competence_count).low_step_value :=
        v_competence.low_step_value;
    p_competence_table(p_competence_count).low_step_name :=
        v_competence.low_step_name;
    p_competence_table(p_competence_count).high_step_value :=
        v_competence.high_step_value;
    p_competence_table(p_competence_count).high_step_name :=
        v_competence.high_step_name;
    p_competence_table(p_competence_count).mandatory :=
        v_competence.mandatory;
    IF v_competence.mandatory = 'Y' THEN
      p_essential_count := p_essential_count + 1;
    ELSE
      p_desirable_count := p_desirable_count + 1;
    END IF;

  END LOOP;

  IF p_include_core_competencies = 'Y' THEN

    get_core_competencies
      (p_competence_table => l_core_competence_table
      ,p_competence_count => l_core_count
      ,p_essential_count => l_core_e_count
      ,p_desirable_count => l_core_d_count);

    process_exclusive_competence
      (p_checked_competence_table => l_core_competence_table
      ,p_against_competence_table => p_competence_table
      ,p_competence_count         => p_competence_count
      ,p_essential_count          => p_essential_count
      ,p_desirable_count          => p_desirable_count);

  END IF;

END get_job_competencies;
-- ---------------------------------------------------------------------------
-- get_pos_competencies
-- ---------------------------------------------------------------------------
PROCEDURE get_pos_competencies
  (p_pos_id in number
  ,p_grade_id in number
  ,p_effective_date in date
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number
  ,p_essential_count out nocopy number
  ,p_desirable_count out nocopy number) IS

  CURSOR csr_competencies_by_pos IS
   SELECT pce.competence_element_id,
          pce.effective_date_from,
          pce.proficiency_level_id,
          pce.high_proficiency_level_id,
          pce.mandatory,
          cpl.competence_id,
          cpl.name,
          r1.step_value  low_step_value,
          rtx1.name low_step_name,
          r2.step_value  high_step_value,
          rtx2.name high_step_name
     FROM per_competence_elements pce,
          per_competences_tl cpl,
          per_rating_levels r1,
          per_rating_levels r2,
          per_rating_levels_tl rtx1,
          per_rating_levels_tl rtx2
    WHERE pce.position_id = p_pos_id
      AND (pce.valid_grade_id IS null
              -- OR pce.valid_grade_id = p_grade_id)
           OR pce.valid_grade_id in (select pvg.valid_grade_id
              from per_valid_grades pvg
              where pvg.grade_id = p_grade_id
              and trunc(sysdate) between pvg.DATE_FROM and
              nvl(pvg.DATE_TO, trunc(sysdate))))
      AND pce.type = 'REQUIREMENT'
      AND p_effective_date BETWEEN pce.effective_date_from AND
          NVL(pce.effective_date_to, p_effective_date)
      AND pce.competence_id = cpl.competence_id
      AND cpl.language = userenv('LANG')
      AND pce.proficiency_level_id = r1.rating_level_id(+)
      AND pce.high_proficiency_level_id = r2.rating_level_id(+)
      AND pce.proficiency_level_id = rtx1.rating_level_id(+)
      AND pce.high_proficiency_level_id = rtx2.rating_level_id(+)
      AND rtx1.language(+) = userenv('LANG')
      AND rtx2.language(+) = userenv('LANG')
    ORDER BY cpl.name;

BEGIN

  p_competence_count := 0;
  p_essential_count := 0;
  p_desirable_count := 0;

  FOR v_competence IN csr_competencies_by_pos LOOP
    p_competence_count := p_competence_count +1;
    p_competence_table(p_competence_count).competence_element_id :=
        v_competence.competence_element_id;
    p_competence_table(p_competence_count).effective_date_from :=
        v_competence.effective_date_from;
    p_competence_table(p_competence_count).competence_id :=
        v_competence.competence_id;
    p_competence_table(p_competence_count).competence_name :=
        v_competence.name;
    p_competence_table(p_competence_count).low_rating_level_id :=
        v_competence.proficiency_level_id;
    p_competence_table(p_competence_count).high_rating_level_id :=
        v_competence.high_proficiency_level_id;
    p_competence_table(p_competence_count).low_step_value :=
        v_competence.low_step_value;
    p_competence_table(p_competence_count).low_step_name :=
        v_competence.low_step_name;
    p_competence_table(p_competence_count).high_step_value :=
        v_competence.high_step_value;
    p_competence_table(p_competence_count).high_step_name :=
        v_competence.high_step_name;
    p_competence_table(p_competence_count).mandatory :=
        v_competence.mandatory;
    IF v_competence.mandatory = 'Y' THEN
      p_essential_count := p_essential_count + 1;
    ELSE
      p_desirable_count := p_desirable_count + 1;
    END IF;

  END LOOP;

END get_pos_competencies;
-- ---------------------------------------------------------------------------
-- get_all_pos_competencies
--
-- For each competence required by the position then
--   use the low, high and matching level from the position requirements.
--
-- For each competence required by the position's organization or position's
-- job that is not
-- explicitely required by the position then
--
-- 1. if the competence is required by job only, then
--     use the low, high and matching level from the job requirements.
-- 2. if the competence is required by org only, then
--     use the low, high and matching level from the org requirements.
-- 3. if the competence is essential for org and job or desirable for org
--    and job, then
--     use greatest (org low, job low), least (org high, job high) and
--     matching level.
-- 4. if the competence is essential for org and desirable for job or
--    essential for job and desirable
-- for org, then 2 requirements are used. One from the org requirements
-- and one from job requirements.
-- ---------------------------------------------------------------------------
PROCEDURE get_all_pos_competencies
  (p_pos_id in number
  ,p_grade_id in number
  ,p_effective_date in date
  ,p_include_core_competencies in varchar2 default 'N'
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number
  ,p_essential_count out nocopy number
  ,p_desirable_count out nocopy number) IS

  l_org_id		hr_organization_units.organization_id%TYPE;
  l_job_id      per_jobs.job_id%TYPE;

  l_core_competence_table 	g_competence_table;
  l_core_count	number;
  l_core_e_count	number;
  l_core_d_count	number;

  l_org_competence_table 	g_competence_table;
  l_org_count	number;
  l_org_e_count	number;
  l_org_d_count	number;

  l_job_competence_table 	g_competence_table;
  l_job_count	number;
  l_job_e_count	number;
  l_job_d_count	number;

  l_pos_competence_table 	g_competence_table;
  l_pos_count	number;
  l_pos_e_count	number;
  l_pos_d_count	number;

  l_found		BOOLEAN;

BEGIN

  IF p_include_core_competencies = 'Y' THEN
    get_core_competencies
      (p_competence_table => l_core_competence_table
      ,p_competence_count => l_core_count
      ,p_essential_count => l_core_e_count
      ,p_desirable_count => l_core_d_count);
  END IF;

  get_drived_org_job(p_pos_id => p_pos_id
                    ,p_org_id => l_org_id
                    ,p_job_id => l_job_id);

  get_org_competencies(p_org_id => l_org_id
                      ,p_competence_table => l_org_competence_table
                      ,p_competence_count => l_org_count
                      ,p_essential_count => l_org_e_count
                      ,p_desirable_count => l_org_d_count);

  get_job_competencies(p_job_id => l_job_id
                      ,p_competence_table => l_job_competence_table
                      ,p_competence_count => l_job_count
                      ,p_essential_count => l_job_e_count
                      ,p_desirable_count => l_job_d_count);
  get_pos_competencies(p_pos_id => p_pos_id
                      ,p_grade_id => p_grade_id
                      ,p_competence_table => l_pos_competence_table
                      ,p_competence_count => l_pos_count
                      ,p_essential_count => l_pos_e_count
                      ,p_desirable_count => l_pos_d_count);

  --
  --check duplicate competence: core vs pos,core vs org,core vs job
  --
  IF p_include_core_competencies = 'Y' THEN
    get_core_competencies
      (p_competence_table => l_core_competence_table
      ,p_competence_count => l_core_count
      ,p_essential_count => l_core_e_count
      ,p_desirable_count => l_core_d_count);
    process_duplicate_competence
      (p_checked_competence_table => l_core_competence_table
      ,p_against_competence_table => l_pos_competence_table);
    process_duplicate_competence
      (p_checked_competence_table => l_core_competence_table
      ,p_against_competence_table => l_org_competence_table);
    process_duplicate_competence
      (p_checked_competence_table => l_core_competence_table
      ,p_against_competence_table => l_job_competence_table);
  END IF;
  --
  --check duplicate competence: org vs pos
  --
  process_duplicate_competence
    (p_checked_competence_table => l_org_competence_table
    ,p_against_competence_table => l_pos_competence_table);

  --
  --check duplicate competence: job vs pos
  --
  process_duplicate_competence
    (p_checked_competence_table => l_job_competence_table
    ,p_against_competence_table => l_pos_competence_table);

  --
  --check exclusive competence: org vs job
  --add exclusive org competencies to pos
  --
  p_competence_count := l_pos_count;
  p_essential_count := l_pos_e_count;
  p_desirable_count := l_pos_d_count;

  FOR v_org_index IN 1..l_org_count LOOP
    IF l_org_competence_table(v_org_index).checked IS null THEN
      l_found := FALSE;
      FOR v_job_index IN 1..l_job_count LOOP
        IF l_job_competence_table(v_job_index).checked IS null THEN
          IF l_org_competence_table(v_org_index).competence_id =
            l_job_competence_table(v_job_index).competence_id then
            l_found := TRUE;
            EXIT;
          END IF;
        END IF;
      END LOOP;
      IF l_found = FALSE THEN

        FOR i IN 1..NVL(l_pos_competence_table.count,0) LOOP
          IF l_org_competence_table(v_org_index).competence_name <=
            l_pos_competence_table(i).competence_name THEN
            FOR j IN REVERSE i..NVL(l_pos_competence_table.count,0) LOOP
              l_pos_competence_table(j+1) := l_pos_competence_table(j);
            END LOOP;
            l_pos_competence_table(i) := l_org_competence_table(v_org_index);
            l_found := TRUE;
            EXIT;
          END IF;
        END LOOP;
        IF l_found = FALSE THEN
          l_pos_competence_table(NVL(l_pos_competence_table.count,0)+1) :=
            l_org_competence_table(v_org_index);
        END IF;

        p_competence_count := p_competence_count + 1;

        IF l_org_competence_table(v_org_index).mandatory = 'Y' THEN
          p_essential_count := p_essential_count + 1;
        ELSE
          p_desirable_count := p_desirable_count + 1;
        END IF;
        l_org_competence_table(v_org_index).checked := 'Y';
      END IF;
    END IF;
  END LOOP;
  --
  --check exclusive competence: job vs org
  --add exclusive job competencies to pos
  --
  FOR v_job_index IN 1..l_job_count LOOP
    IF l_job_competence_table(v_job_index).checked IS null THEN
      l_found := FALSE;
      FOR v_org_index IN 1..l_org_count LOOP
        IF l_org_competence_table(v_org_index).checked IS null THEN
          IF l_org_competence_table(v_org_index).competence_id =
            l_job_competence_table(v_job_index).competence_id then
            l_found := TRUE;
            EXIT;
          END IF;
        END IF;
      END LOOP;
      IF l_found = FALSE THEN

        FOR i IN 1..NVL(l_pos_competence_table.count,0) LOOP
          IF l_job_competence_table(v_job_index).competence_name <=
            l_pos_competence_table(i).competence_name THEN
            FOR j IN REVERSE i..NVL(l_pos_competence_table.count,0) LOOP
              l_pos_competence_table(j+1) := l_pos_competence_table(j);
            END LOOP;
            l_pos_competence_table(i) := l_job_competence_table(v_job_index);
            l_found := TRUE;
            EXIT;
          END IF;
        END LOOP;
        IF l_found = FALSE THEN
          l_pos_competence_table(NVL(l_pos_competence_table.count,0)+1) :=
            l_job_competence_table(v_job_index);
        END IF;

        p_competence_count := p_competence_count + 1;

        IF l_job_competence_table(v_job_index).mandatory = 'Y' THEN
          p_essential_count := p_essential_count + 1;
        ELSE
          p_desirable_count := p_desirable_count + 1;
        END IF;

        l_job_competence_table(v_job_index).checked := 'Y';

      END IF;
    END IF;
  END LOOP;
  --
  --check duplicate competence: org vs job
  --
  FOR v_org_index IN 1..l_org_count LOOP
    IF l_org_competence_table(v_org_index).checked IS null THEN
      FOR v_job_index IN 1..l_job_count LOOP
        IF l_job_competence_table(v_job_index).checked IS null THEN
          IF l_org_competence_table(v_org_index).competence_id =
            l_job_competence_table(v_job_index).competence_id THEN
            IF l_org_competence_table(v_org_index).mandatory =
              l_job_competence_table(v_job_index).mandatory THEN
              p_competence_count := p_competence_count + 1;
              l_pos_competence_table(p_competence_count) :=
                l_org_competence_table(v_org_index);
              IF l_org_competence_table(v_org_index).low_step_value >
                 l_job_competence_table(v_job_index).low_step_value THEN
               l_pos_competence_table(p_competence_count).low_rating_level_id :=
                l_org_competence_table(v_org_index).low_rating_level_id;
                l_pos_competence_table(p_competence_count).low_step_value :=
                l_org_competence_table(v_org_index).low_step_value;
              ELSE
               l_pos_competence_table(p_competence_count).low_rating_level_id :=
                l_job_competence_table(v_job_index).low_rating_level_id;
                l_pos_competence_table(p_competence_count).low_step_value :=
                l_job_competence_table(v_job_index).low_step_value;
              END IF;
              IF l_org_competence_table(v_org_index).high_step_value <
                 l_job_competence_table(v_job_index).high_step_value THEN
              l_pos_competence_table(p_competence_count).high_rating_level_id :=
                l_org_competence_table(v_org_index).high_rating_level_id;
                l_pos_competence_table(p_competence_count).high_step_value :=
                l_org_competence_table(v_org_index).high_step_value;
              ELSE
              l_pos_competence_table(p_competence_count).high_rating_level_id :=
                l_job_competence_table(v_job_index).high_rating_level_id;
                l_pos_competence_table(p_competence_count).high_step_value :=
                l_job_competence_table(v_job_index).high_step_value;
              END IF;
              IF l_org_competence_table(v_org_index).mandatory = 'Y' THEN
                p_essential_count := p_essential_count + 1;
              ELSE
                p_desirable_count := p_desirable_count + 1;
              END IF;
            ELSE
              p_competence_count := p_competence_count + 1;
              l_pos_competence_table(p_competence_count) :=
                 l_org_competence_table(v_org_index);
              IF l_org_competence_table(v_org_index).mandatory = 'Y' THEN
                p_essential_count := p_essential_count + 1;
              ELSE
                p_desirable_count := p_desirable_count + 1;
              END IF;
              p_competence_count := p_competence_count + 1;
              l_pos_competence_table(p_competence_count) :=
                 l_job_competence_table(v_job_index);
              IF l_job_competence_table(v_job_index).mandatory = 'Y' THEN
                p_essential_count := p_essential_count + 1;
              ELSE
                p_desirable_count := p_desirable_count + 1;
              END IF;
            END IF;
            l_job_competence_table(v_job_index).checked := 'Y';
            l_org_competence_table(v_org_index).checked := 'Y';
            EXIT;
          END IF;
        END IF;
      END LOOP;
    END IF;
  END LOOP;
  --
  --process exclusive competence: core vs pos
  --add exclusive core competencies to pos
  --
  IF p_include_core_competencies = 'Y' THEN
    process_exclusive_competence
      (p_checked_competence_table => l_core_competence_table
      ,p_against_competence_table => l_pos_competence_table
      ,p_competence_count         => p_competence_count
      ,p_essential_count          => p_essential_count
      ,p_desirable_count          => p_desirable_count);
  END IF;

  p_competence_table := l_pos_competence_table;

END get_all_pos_competencies;
-- ---------------------------------------------------------------------------
-- get_person_competencies
-- ---------------------------------------------------------------------------
PROCEDURE get_person_competencies
  (p_person_id in number
  ,p_effective_date in date
  ,p_competence_table out nocopy g_competence_table
  ,p_competence_count out nocopy number) IS

  CURSOR csr_competencies_by_person IS
   SELECT cpl.competence_id,
          pce.competence_element_id,
          pce.effective_date_from,
          pce.proficiency_level_id,
          pce.high_proficiency_level_id,
          pce.mandatory,
          cpl.name,
          r1.step_value  low_step_value,
          rtx1.name low_step_name,
          r2.step_value  high_step_value,
          rtx2.name high_step_name
     FROM per_competence_elements pce,
          per_competences_tl cpl,
          per_rating_levels r1,
          per_rating_levels r2,
          per_rating_levels_tl rtx1,
          per_rating_levels_tl rtx2
    WHERE pce.person_id = p_person_id
      AND pce.type = 'PERSONAL'
      AND p_effective_date BETWEEN pce.effective_date_from AND
          NVL(pce.effective_date_to, p_effective_date)
      AND pce.competence_id = cpl.competence_id
      AND cpl.language = userenv('LANG')
      AND pce.proficiency_level_id = r1.rating_level_id(+)
      AND pce.high_proficiency_level_id = r2.rating_level_id(+)
      AND pce.proficiency_level_id = rtx1.rating_level_id(+)
      AND pce.high_proficiency_level_id = rtx2.rating_level_id(+)
      AND rtx1.language(+) = userenv('LANG')
      AND rtx2.language(+) = userenv('LANG')
    ORDER BY cpl.name;

BEGIN

  p_competence_count := 0;

  FOR v_competence IN csr_competencies_by_person LOOP

    p_competence_count := p_competence_count +1;
    p_competence_table(p_competence_count).competence_element_id :=
        v_competence.competence_element_id;
    p_competence_table(p_competence_count).competence_id :=
        v_competence.competence_id;
    p_competence_table(p_competence_count).effective_date_from :=
        v_competence.effective_date_from;
    p_competence_table(p_competence_count).competence_name :=
        v_competence.name;
    p_competence_table(p_competence_count).low_rating_level_id :=
        v_competence.proficiency_level_id;
    p_competence_table(p_competence_count).high_rating_level_id :=
        v_competence.high_proficiency_level_id;
    p_competence_table(p_competence_count).low_step_value :=
        v_competence.low_step_value;
    p_competence_table(p_competence_count).low_step_name :=
        v_competence.low_step_name;
    p_competence_table(p_competence_count).high_step_value :=
        v_competence.high_step_value;
    p_competence_table(p_competence_count).high_step_name :=
        v_competence.high_step_name;
    p_competence_table(p_competence_count).mandatory :=
        v_competence.mandatory;

  END LOOP;

END get_person_competencies;

-- ---------------------------------------------------------------------------
-- process_duplicate_competence
-- ---------------------------------------------------------------------------
PROCEDURE process_duplicate_competence
  (p_checked_competence_table in out nocopy g_competence_table
  ,p_against_competence_table in out nocopy g_competence_table) IS
BEGIN

  FOR v_checked_index IN 1..NVL(p_checked_competence_table.count,0) LOOP
    FOR v_against_index IN 1..NVL(p_against_competence_table.count,0) LOOP
      IF p_checked_competence_table(v_checked_index).competence_id =
         p_against_competence_table(v_against_index).competence_id then
        p_checked_competence_table(v_checked_index).checked := 'Y';
        EXIT;
      END IF;
    END LOOP;
  END LOOP;

END process_duplicate_competence;

-- ---------------------------------------------------------------------------
-- process_exclusive_competence
-- ---------------------------------------------------------------------------

PROCEDURE process_exclusive_competence
  (p_checked_competence_table in out nocopy g_competence_table
  ,p_against_competence_table in out nocopy g_competence_table
  ,p_competence_count         in out nocopy number
  ,p_essential_count          in out nocopy number
  ,p_desirable_count          in out nocopy number) IS

  l_found  boolean;

BEGIN
  FOR v_checked_index IN 1..NVL(p_checked_competence_table.count,0) LOOP
    IF p_checked_competence_table(v_checked_index).checked IS null THEN
      l_found := FALSE;
      FOR v_against_index IN 1..NVL(p_against_competence_table.count,0) LOOP
        IF p_checked_competence_table(v_checked_index).competence_id =
          p_against_competence_table(v_against_index).competence_id then
          l_found := TRUE;
          EXIT;
        END IF;
      END LOOP;
      IF l_found = FALSE THEN
        FOR i IN 1..NVL(p_against_competence_table.count,0) LOOP
          IF p_checked_competence_table(v_checked_index).competence_name <=
            p_against_competence_table(i).competence_name THEN
            FOR j IN REVERSE i..NVL(p_against_competence_table.count,0) LOOP
              p_against_competence_table(j+1) := p_against_competence_table(j);
            END LOOP;
            p_against_competence_table(i) :=
               p_checked_competence_table(v_checked_index);
            l_found := TRUE;
            EXIT;
          END IF;
        END LOOP;
        IF l_found = FALSE THEN
          p_against_competence_table
            (NVL(p_against_competence_table.count,0)+1) :=
            p_checked_competence_table(v_checked_index);
        END IF;
        p_competence_count := p_competence_count + 1;

        IF p_checked_competence_table(v_checked_index).mandatory = 'Y' THEN
          p_essential_count := p_essential_count + 1;
        ELSE
          p_desirable_count := p_desirable_count + 1;
        END IF;
        p_checked_competence_table(v_checked_index).checked := 'Y';
      END IF;
    END IF;
  END LOOP;
END process_exclusive_competence;


-- ---------------------------------------------------------------------------
-- ranking:
--
--For any competence requirement the following must be true for a match to occur
--
-- if the requirement low and high levels are both null then
--    the person must have an effective competence entry for the competence
--
-- if the requirement low level is not null and the high level is null
--    the person must have an effective competence entry for the competence with
--     level >= required low level
--
-- if the requirement low level is null and the high level is not null
--    the person must have an effective competence entry for the competence with
--     level <= required high level
--
-- if the requirement low level is not null and the high level is not null
--    the person must have an effective competence entry for the competence with
--     required low level <= level <= required high level
--
-- The match is either essential or desirable depending upon the matching level
-- of the requirement.
-- ---------------------------------------------------------------------------

PROCEDURE ranking
  (p_person_id in number
  ,p_effective_date in date
  ,p_competence_table in g_competence_table
  ,p_competence_count	in number
  ,p_match_essential_count out nocopy number
  ,p_match_desirable_count out nocopy number) IS

  l_person_competence_table 	g_competence_table;
  l_person_count	number;

BEGIN

  p_match_essential_count := 0;
  p_match_desirable_count := 0;

  get_person_competencies(p_person_id => p_person_id
                      ,p_competence_table => l_person_competence_table
                      ,p_competence_count => l_person_count);
  --
  --matching competence
  --
  FOR v_person_index IN 1..l_person_count LOOP
    FOR v_index IN 1..p_competence_count LOOP
      IF l_person_competence_table(v_person_index).competence_id =
         p_competence_table(v_index).competence_id then
        IF p_competence_table(v_index).low_rating_level_id IS null AND
           p_competence_table(v_index).high_rating_level_id IS null THEN
          IF p_competence_table(v_index).mandatory = 'Y' THEN
            p_match_essential_count := p_match_essential_count + 1;
          ELSE
            p_match_desirable_count := p_match_desirable_count + 1;
          END IF;
        ELSIF p_competence_table(v_index).low_rating_level_id IS NOT null AND
              p_competence_table(v_index).high_rating_level_id IS null THEN
          IF l_person_competence_table(v_person_index).low_step_value >=
             p_competence_table(v_index).low_step_value THEN
            IF p_competence_table(v_index).mandatory = 'Y' THEN
              p_match_essential_count := p_match_essential_count + 1;
            ELSE
              p_match_desirable_count := p_match_desirable_count + 1;
            END IF;
          END IF;
        ELSIF p_competence_table(v_index).low_rating_level_id IS null AND
              p_competence_table(v_index).high_rating_level_id IS NOT null THEN
          IF l_person_competence_table(v_person_index).low_step_value <=
             p_competence_table(v_index).high_step_value THEN
            IF p_competence_table(v_index).mandatory = 'Y' THEN
              p_match_essential_count := p_match_essential_count + 1;
            ELSE
              p_match_desirable_count := p_match_desirable_count + 1;
            END IF;
          END IF;
        ELSIF p_competence_table(v_index).low_rating_level_id IS NOT null AND
              p_competence_table(v_index).high_rating_level_id IS NOT null THEN
          IF l_person_competence_table(v_person_index).low_step_value >=
             p_competence_table(v_index).low_step_value AND
             l_person_competence_table(v_person_index).low_step_value <=
             p_competence_table(v_index).high_step_value THEN
            IF p_competence_table(v_index).mandatory = 'Y' THEN
              p_match_essential_count := p_match_essential_count + 1;
            ELSE
              p_match_desirable_count := p_match_desirable_count + 1;
            END IF;
          END IF;
        END IF;
        EXIT;
      END IF;
    END LOOP;
  END LOOP;

END ranking;

-- ---------------------------------------------------------------------------
-- ranking
-- ---------------------------------------------------------------------------

PROCEDURE ranking
  (p_type					in varchar2
  ,p_id         			in number
  ,p_grade_id   			in number
  ,p_person_id  			in number
  ,p_effective_date 		in date default sysdate
  ,p_essential_count 	 out nocopy number
  ,p_desirable_count 	 out nocopy number
  ,p_match_essential_count  out nocopy number
  ,p_match_desirable_count  out nocopy number) IS

  l_competence_table	g_competence_table;
  l_competence_count	number;

BEGIN

  IF p_type = g_organization_type THEN
    get_org_competencies(p_org_id => p_id
                      ,p_effective_date => p_effective_date
                      ,p_competence_table => l_competence_table
                      ,p_competence_count => l_competence_count
                      ,p_essential_count => p_essential_count
                      ,p_desirable_count => p_desirable_count);
  ELSIF p_type = g_job_type THEN
    get_job_competencies(p_job_id => p_id
                      ,p_grade_id => p_grade_id
                      ,p_effective_date => p_effective_date
                      ,p_competence_table => l_competence_table
                      ,p_competence_count => l_competence_count
                      ,p_essential_count => p_essential_count
                      ,p_desirable_count => p_desirable_count);
  ELSIF p_type = g_position_type THEN
    get_all_pos_competencies(p_pos_id => p_id
                      ,p_grade_id => p_grade_id
                      ,p_effective_date => p_effective_date
                      ,p_competence_table => l_competence_table
                      ,p_competence_count => l_competence_count
                      ,p_essential_count => p_essential_count
                      ,p_desirable_count => p_desirable_count);
  ELSIF p_type = g_vacancy_type THEN
    get_vac_competencies(p_vacancy_id => p_id
                      ,p_effective_date => p_effective_date
                      ,p_competence_table => l_competence_table
                      ,p_competence_count => l_competence_count
                      ,p_essential_count => p_essential_count
                      ,p_desirable_count => p_desirable_count);
  END IF;

  ranking(p_person_id => p_person_id
         ,p_effective_date => p_effective_date
         ,p_competence_table => l_competence_table
         ,p_competence_count => l_competence_count
         ,p_match_essential_count => p_match_essential_count
         ,p_match_desirable_count => p_match_desirable_count);

END ranking;

-- ---------------------------------------------------------------------------
-- sort_rank_list
-- ---------------------------------------------------------------------------

PROCEDURE sort_rank_list
  (p_rank_table 		in out nocopy g_rank_table
  ,p_rank_table_count	in number) IS

  l_rank_table 	g_rank_table;
  l_found   	boolean;
  l_temp_str1  	varchar2(2000);
  l_temp_str2  	varchar2(2000);

BEGIN

  FOR i IN 1..NVL(p_rank_table.count, 0) LOOP
    l_temp_str1 := lpad(to_char(p_rank_table(i).match_e_count),4)
              ||lpad(to_char(p_rank_table(i).match_d_count),4);
    l_found := FALSE;
    FOR j IN 1..NVL(l_rank_table.count, 0) LOOP
      l_temp_str2 := lpad(to_char(l_rank_table(j).match_e_count),4)
              ||lpad(to_char(l_rank_table(j).match_d_count),4);
      IF l_temp_str1 > l_temp_str2 THEN
        FOR k IN REVERSE j..l_rank_table.count LOOP
          l_rank_table(k+1) := l_rank_table(k);
        END LOOP;
        l_rank_table(j) := p_rank_table(i);
        l_found := TRUE;
        EXIT;
      END IF;
    END LOOP;
    IF l_found = FALSE THEN
      l_rank_table(i) := p_rank_table(i);
    END IF;
  END LOOP;

  p_rank_table := l_rank_table;

END sort_rank_list;
-- ---------------------------------------------------------------------------
-- get_people_by_vacancy
-- ---------------------------------------------------------------------------

PROCEDURE get_people_by_vacancy
  (p_vacancy_id 	in number
  ,p_effective_date	in date
  ,p_person_name  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_type out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 		 out nocopy number) IS

  CURSOR csr_people_by_vacancy IS
  SELECT distinct(paf.person_id) person_id
        ,ppf.full_name name
        ,hr_person_type_usage_info.get_user_person_type
         (p_effective_date, paf.person_id) type
        ,ppf.order_name
    FROM per_assignments_f paf
        ,per_people_f ppf
   WHERE paf.vacancy_id = p_vacancy_id
     AND p_effective_date BETWEEN paf.effective_start_date
         AND NVL(paf.effective_end_date, p_effective_date)
     AND paf.person_id = ppf.person_id
     AND p_effective_date BETWEEN ppf.effective_start_date
         AND NVL(ppf.effective_end_date, p_effective_date)
   ORDER BY NVL(ppf.order_name,ppf.full_name);

  --legislatioon_code = 'JP'
  CURSOR csr_jp_people_by_vacancy IS
  SELECT distinct(paf.person_id) person_id
        ,ppf.full_name name
        ,hr_person_type_usage_info.get_user_person_type
           (p_effective_date, paf.person_id) type
        ,ppf.last_name
        ,ppf.first_name
    FROM per_assignments_f paf
        ,per_people_f ppf
   WHERE paf.vacancy_id = p_vacancy_id
     AND p_effective_date BETWEEN paf.effective_start_date
         AND NVL(paf.effective_end_date, p_effective_date)
     AND paf.person_id = ppf.person_id
     AND p_effective_date BETWEEN ppf.effective_start_date
         AND NVL(ppf.effective_end_date, p_effective_date)
   ORDER BY ppf.last_name, ppf.first_name;

BEGIN

  hr_util_misc_web.validate_session(p_person_id => c_person_id);
  c_legislation_code := hr_misc_web.get_legislation_code
    (p_person_id => c_person_id);

  p_count := 0;
  IF c_legislation_code = g_japan_legislation_code THEN
    FOR v_people_by_vacancy IN csr_jp_people_by_vacancy LOOP
      p_count := p_count + 1;
      p_person_id(p_count) := v_people_by_vacancy.person_id;
      p_person_name(p_count) := v_people_by_vacancy.name;
      p_person_type(p_count) := v_people_by_vacancy.type;
    END LOOP;
  ELSE
    FOR v_people_by_vacancy IN csr_people_by_vacancy LOOP
      p_count := p_count + 1;
      p_person_id(p_count) := v_people_by_vacancy.person_id;
      p_person_name(p_count) := v_people_by_vacancy.name;
      p_person_type(p_count) := v_people_by_vacancy.type;
    END LOOP;
  END IF;

END get_people_by_vacancy;

-- ---------------------------------------------------------------------------
-- get_vacancies_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_vacancies_by_person
  (p_person_id 		in number
  ,p_effective_date in date
  ,p_vacancy_id  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name 		 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 		 out nocopy number) IS

 CURSOR csr_vacanies_by_person IS
   SELECT pasf.vacancy_id
         ,pv.name ||' ('||pr.name||')' name
     FROM per_assignments_f pasf,
          per_assignment_status_types past,
          per_vacancies pv,
          per_requisitions pr
    WHERE pasf.person_id = p_person_id
      AND p_effective_date BETWEEN pasf.effective_start_date
          AND pasf.effective_end_date
      AND pasf.vacancy_id = pv.vacancy_id
      AND pv.requisition_id = pr.requisition_id
      AND pasf.assignment_status_type_id = past.assignment_status_type_id
      AND pasf.assignment_type = 'A'
      AND past.per_system_status in ('ACTIVE_APL');

BEGIN

  p_count := 0;
  FOR v_vacanies_by_person IN csr_vacanies_by_person LOOP
    p_count := p_count + 1;
    p_vacancy_id(p_count) := v_vacanies_by_person.vacancy_id;
    p_name(p_count) := v_vacanies_by_person.name;
  END LOOP;

END get_vacancies_by_person;

-- ---------------------------------------------------------------------------
-- get_succession_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_succession_by_person
  (p_person_id 		in number
  ,p_effective_date in date default sysdate
  ,p_position_id  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name 		 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 		 out nocopy number) IS

  CURSOR csr_succession_by_person IS
  SELECT * FROM (
   SELECT psp.position_id, pp.name
     FROM per_succession_planning psp,
          hr_positions_f pp
    WHERE psp.person_id = p_person_id
      AND p_effective_date <= NVL(psp.end_date, p_effective_date)
      AND psp.position_id = pp.position_id
	 AND TRUNC(p_effective_date) BETWEEN pp.effective_start_date
		AND pp.effective_end_date
  UNION
   SELECT pp.position_id, pp.name
     FROM hr_positions_f pp
    WHERE pp.position_id = (SELECT pp2.successor_position_id
          FROM hr_positions_f pp2,
               per_assignments_f paf
          WHERE paf.person_id = p_person_id
          AND p_effective_date BETWEEN paf.effective_start_date
              AND paf.effective_end_date
          AND paf.position_id = pp2.position_id
          AND p_effective_date BETWEEN pp2.effective_start_date
              AND pp2.effective_end_date)
     AND TRUNC(p_effective_date) BETWEEN pp.effective_start_date
                AND pp.effective_end_date)
  ORDER BY name;

BEGIN

  p_count := 0;
  FOR v_succession_by_person IN csr_succession_by_person LOOP
    p_count := p_count + 1;
    p_position_id(p_count) := v_succession_by_person.position_id;
    p_name(p_count) := v_succession_by_person.name;
  END LOOP;

END get_succession_by_person;

-- ---------------------------------------------------------------------------
-- get_deployment_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_deployment_by_person
  (p_person_id 		in number
  ,p_effective_date     in date
  ,p_assignment_id      out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_position_id  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_grade_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 	 out nocopy number) IS

  CURSOR csr_deployment_by_person IS
   SELECT pasf.assignment_id, pasf.position_id, pasf.grade_id, pp.name
     FROM per_assignments_f pasf,
          per_assignment_status_types past,
          hr_positions_f pp
    WHERE pasf.person_id = p_person_id
      AND p_effective_date BETWEEN pasf.effective_start_date
          AND pasf.effective_end_date
      AND pasf.position_id = pp.position_id
	 AND TRUNC(SYSDATE) BETWEEN pp.effective_start_date
		AND pp.effective_end_date
      --AND pasf.vacancy_id is null
      AND pasf.assignment_status_type_id = past.assignment_status_type_id
      AND (pasf.assignment_type = 'E' AND
           past.per_system_status in ('ACTIVE_ASSIGN')
          OR pasf.assignment_type = 'A' AND
           past.per_system_status in ('ACCEPTED', 'OFFER', 'ACTIVE_APL'));

BEGIN

  p_count := 0;
  FOR v_deployment_by_person IN csr_deployment_by_person LOOP
    p_count := p_count + 1;
    p_assignment_id(p_count) := v_deployment_by_person.assignment_id;
    p_position_id(p_count) := v_deployment_by_person.position_id;
    p_grade_id(p_count) := v_deployment_by_person.grade_id;
    p_name(p_count) := v_deployment_by_person.name;
  END LOOP;

END get_deployment_by_person;

-- ---------------------------------------------------------------------------
-- get_job_deployment_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_job_deployment_by_person
  (p_person_id 		in number
  ,p_effective_date     in date
  ,p_assignment_id      out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_job_id      out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_grade_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 	 out nocopy number) IS

  CURSOR csr_deployment_by_person IS
   SELECT pasf.assignment_id, pasf.job_id, pasf.grade_id, pj.name
     FROM per_assignments_f pasf,
          per_assignment_status_types past,
          per_jobs_vl pj
    WHERE pasf.person_id = p_person_id
      AND p_effective_date BETWEEN pasf.effective_start_date
          AND pasf.effective_end_date
      AND pasf.job_id = pj.job_id
	  AND pasf.position_id is null
      --    AND pasf.vacancy_id is null
      AND pasf.assignment_status_type_id = past.assignment_status_type_id
      AND (pasf.assignment_type = 'E' AND
           past.per_system_status in ('ACTIVE_ASSIGN')
          OR pasf.assignment_type = 'A' AND
           past.per_system_status in ('ACCEPTED', 'OFFER', 'ACTIVE_APL'));

BEGIN

  p_count := 0;
  FOR v_deployment_by_person IN csr_deployment_by_person LOOP
    p_count := p_count + 1;
    p_assignment_id(p_count) := v_deployment_by_person.assignment_id;
    p_job_id(p_count) := v_deployment_by_person.job_id;
    p_grade_id(p_count) := v_deployment_by_person.grade_id;
    p_name(p_count) := v_deployment_by_person.name;
  END LOOP;

END get_job_deployment_by_person;

-- ---------------------------------------------------------------------------
-- get_org_deployment_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_org_deployment_by_person
  (p_person_id 		in number
  ,p_effective_date     in date default sysdate
  ,p_assignment_id      out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_org_id 	        out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 	 out nocopy number) IS

CURSOR csr_deployment_by_person IS
   SELECT pasf.assignment_id, pasf.organization_id, hou.name
     FROM per_assignments_f pasf,
          per_assignment_status_types past,
          hr_organization_units hou
    WHERE pasf.person_id = p_person_id
      AND p_effective_date BETWEEN pasf.effective_start_date
          AND pasf.effective_end_date
      AND pasf.organization_id = hou.organization_id
	  AND pasf.position_id is null
	  AND pasf.job_id is null
      --    AND pasf.vacancy_id is null
      AND pasf.assignment_status_type_id = past.assignment_status_type_id
      AND (pasf.assignment_type = 'E' AND
           past.per_system_status in ('ACTIVE_ASSIGN')
          OR pasf.assignment_type = 'A' AND
           past.per_system_status in ('ACCEPTED', 'OFFER', 'ACTIVE_APL'));

BEGIN

  p_count := 0;
  FOR v_deployment_by_person IN csr_deployment_by_person LOOP
    p_count := p_count + 1;
    p_assignment_id(p_count) := v_deployment_by_person.assignment_id;
    p_org_id(p_count) := v_deployment_by_person.organization_id;
    p_name(p_count) := v_deployment_by_person.name;
  END LOOP;
END get_org_deployment_by_person;

-- ---------------------------------------------------------------------------
-- get_vac_deployment_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_vac_deployment_by_person
  (p_person_id          in number
  ,p_effective_date     in date default sysdate
  ,p_assignment_id      out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_vac_id             out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name               out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count              out nocopy number) IS

  CURSOR csr_deployment_by_person IS
   SELECT pasf.assignment_id
         ,pasf.vacancy_id
         ,pv.name||' ('||pr.name||')' name
     FROM per_assignments_f pasf,
          per_assignment_status_types past,
          per_vacancies pv,
          per_requisitions pr
    WHERE pasf.person_id = p_person_id
      AND p_effective_date BETWEEN pasf.effective_start_date
          AND pasf.effective_end_date
      AND pasf.vacancy_id = pv.vacancy_id
      AND pv.requisition_id = pr.requisition_id
      AND pasf.assignment_status_type_id = past.assignment_status_type_id
      AND pasf.assignment_type = 'A'
      AND past.per_system_status in ('ACCEPTED', 'OFFER', 'ACTIVE_APL');

BEGIN

  p_count := 0;
  FOR v_deployment_by_person IN csr_deployment_by_person LOOP
    p_count := p_count + 1;
    p_assignment_id(p_count) := v_deployment_by_person.assignment_id;
    p_vac_id(p_count) := v_deployment_by_person.vacancy_id;
    p_name(p_count) := v_deployment_by_person.name;
  END LOOP;

END get_vac_deployment_by_person;

-- ---------------------------------------------------------------------------
-- get_succesors_by_position
-- ---------------------------------------------------------------------------

PROCEDURE get_succesors_by_position
  (p_pos_id 		in number
  ,p_effective_date in date default sysdate
  ,p_person_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_name  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_type out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 		 out nocopy number) IS

-- Bug# 2447224.

  CURSOR csr_succesors_by_position IS
  SELECT * FROM (
   SELECT distinct(psp.person_id) person_id
         ,ppf.full_name name
         ,hr_person_type_usage_info.get_user_person_type
             (p_effective_date, ppf.person_id) type
         ,ppf.order_name
     FROM per_succession_planning psp
         ,per_people_f ppf
    WHERE psp.position_id = p_pos_id
      AND p_effective_date <=
          NVL(psp.end_date, p_effective_date)
      AND psp.person_id = ppf.person_id
      AND p_effective_date BETWEEN ppf.effective_start_date
          AND ppf.effective_end_date
  UNION
   select paf.person_id
      ,ppf.full_name name
      ,hr_person_type_usage_info.get_user_person_type
          (p_effective_date, ppf.person_id) type
      ,ppf.order_name
   from hr_positions_f ps,
     per_assignments_f paf
    ,per_people_f ppf
   where ps.successor_position_id = p_pos_id
   AND p_effective_date BETWEEN ps.effective_start_date
   AND ps.effective_end_date
   and paf.position_id = ps.position_id
   AND paf.person_id = ppf.person_id
   AND p_effective_date BETWEEN ppf.effective_start_date
   AND ppf.effective_end_date
   AND p_effective_date BETWEEN paf.effective_start_date
   AND paf.effective_end_date)
  ORDER BY NVL(order_name,name);

  CURSOR csr_jp_succesors_by_position IS
  SELECT * FROM (
   SELECT distinct(psp.person_id) person_id
         ,ppf.full_name name
         ,hr_person_type_usage_info.get_user_person_type
             (p_effective_date, ppf.person_id) type
         ,ppf.last_name
         ,ppf.first_name
     FROM per_succession_planning psp
         ,per_people_f ppf
    WHERE psp.position_id = p_pos_id
      AND p_effective_date <=
          NVL(psp.end_date, p_effective_date)
      AND psp.person_id = ppf.person_id
      AND p_effective_date BETWEEN ppf.effective_start_date
          AND NVL(ppf.effective_end_date, p_effective_date)
  UNION
   select paf.person_id
      ,ppf.full_name name
      ,hr_person_type_usage_info.get_user_person_type
          (p_effective_date, ppf.person_id) type
      ,ppf.last_name
      ,ppf.first_name
   from hr_positions_f ps,
     per_assignments_f paf
    ,per_people_f ppf
   where ps.successor_position_id = p_pos_id
   AND p_effective_date BETWEEN ps.effective_start_date
   AND ps.effective_end_date
   and paf.position_id = ps.position_id
   AND paf.person_id = ppf.person_id
   AND p_effective_date BETWEEN ppf.effective_start_date
   AND ppf.effective_end_date
   AND p_effective_date BETWEEN paf.effective_start_date
   AND paf.effective_end_date)
  ORDER BY last_name, first_name;

BEGIN

  hr_util_misc_web.validate_session(p_person_id => c_person_id);
  c_legislation_code := hr_misc_web.get_legislation_code
    (p_person_id => c_person_id);

  p_count := 0;
  IF c_legislation_code = g_japan_legislation_code THEN
    FOR v_succesors_by_position IN csr_jp_succesors_by_position LOOP
      p_count := p_count + 1;
      p_person_id(p_count) := v_succesors_by_position.person_id;
      p_person_name(p_count) := v_succesors_by_position.name;
      p_person_type(p_count) := v_succesors_by_position.type;
    END LOOP;
  ELSE
    FOR v_succesors_by_position IN csr_succesors_by_position LOOP
      p_count := p_count + 1;
      p_person_id(p_count) := v_succesors_by_position.person_id;
      p_person_name(p_count) := v_succesors_by_position.name;
      p_person_type(p_count) := v_succesors_by_position.type;
    END LOOP;
  END IF;

END get_succesors_by_position;

-- ---------------------------------------------------------------------------
-- get_people_by_role
-- ---------------------------------------------------------------------------

PROCEDURE get_people_by_role
  (p_pre_search_type   in varchar2
  ,p_pre_search_id     in varchar2
  ,p_search_type       in varchar2
  ,p_search_id         in varchar2
  ,p_grade_id          in number default null
  ,p_person_id         out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_name       out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_type       out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count             out nocopy number) IS

  l_dynamic_sql     varchar2(32000);
  l_business_group  varchar2(2000);
  l_grade_id        number;

  l_sql_cursor      integer;
  l_rows            integer;
  l_index           number;
  c_id              number;
  c_name            varchar2(240);
  c_type            varchar2(80);

BEGIN

  hr_util_misc_web.validate_session(p_person_id => c_person_id);
  c_legislation_code := hr_misc_web.get_legislation_code
    (p_person_id => c_person_id);

  l_business_group := hr_util_misc_web.get_business_group_id;

-- Bug# 2447224.

  l_dynamic_sql :=
    'SELECT distinct(paf.person_id) person_id';
    l_dynamic_sql := l_dynamic_sql
    ||',ppf.full_name name';
  l_dynamic_sql := l_dynamic_sql
    ||',hr_person_type_usage_info.get_user_person_type(trunc(sysdate),paf.person_id) type'
    ||' FROM per_assignments_f paf'
    ||'     ,per_people_f ppf'
    ||'     ,per_periods_of_service ppos'
    ||' WHERE paf.business_group_id = '
    ||l_business_group
    ||' AND paf.assignment_type = ''E'''
    ||' AND TRUNC(sysdate) BETWEEN paf.effective_start_date'
    ||'     AND NVL(paf.effective_end_date,sysdate)'
    ||' AND paf.person_id = ppf.person_id'
    ||' AND ppos.person_id(+) = ppf.person_id'
    ||' AND (ppos.actual_termination_date is null '
    ||' or ppos.actual_termination_date > trunc(sysdate))'
    ||' AND TRUNC(sysdate) BETWEEN ppf.effective_start_date'
    ||'     AND  NVL(ppf.effective_end_date,sysdate)';

  IF p_search_type = g_location_type THEN
    l_dynamic_sql := l_dynamic_sql
      ||' AND paf.location_id = '
      ||p_search_id;
  ELSIF p_search_type = g_organization_type THEN
    l_dynamic_sql := l_dynamic_sql
      ||' AND paf.organization_id = '
      ||p_search_id;
  ELSIF p_search_type = g_job_type THEN
    l_dynamic_sql := l_dynamic_sql
      ||' AND paf.job_id = '
      ||p_search_id;
    IF p_grade_id IS NOT null THEN
      l_dynamic_sql := l_dynamic_sql
        ||' AND paf.grade_id = '
        ||' (SELECT pvg.grade_id'
        ||'    FROM per_valid_grades pvg'
        ||'   WHERE pvg.valid_grade_id = '
        ||p_grade_id||')';
    END IF;
  ELSIF p_search_type = g_position_type THEN
    l_dynamic_sql := l_dynamic_sql
      ||' AND paf.position_id = '
      ||p_search_id;
    IF p_grade_id IS NOT null THEN
      l_dynamic_sql := l_dynamic_sql
        ||' AND paf.grade_id = '
        ||' (SELECT pvg.grade_id'
        ||'    FROM per_valid_grades pvg'
        ||'   WHERE pvg.valid_grade_id = '
        ||p_grade_id||')';
    END IF;
  END IF;

  IF p_pre_search_type = g_location_type THEN
    l_dynamic_sql := l_dynamic_sql
      ||' AND paf.location_id = '
      ||p_pre_search_id;
  ELSIF p_pre_search_type = g_organization_type THEN
    l_dynamic_sql := l_dynamic_sql
      ||' AND paf.organization_id = '
      ||p_pre_search_id;
  ELSIF p_pre_search_type = g_job_type THEN
    l_dynamic_sql := l_dynamic_sql
      ||' AND paf.job_id = '
      ||p_pre_search_id;
    IF p_grade_id IS NOT null THEN
      l_dynamic_sql := l_dynamic_sql
        ||' AND paf.grade_id = '
        ||' (SELECT pvg.grade_id'
        ||'    FROM per_valid_grades pvg'
        ||'   WHERE pvg.valid_grade_id = '
        ||p_grade_id||')';
    END IF;
  ELSIF p_pre_search_type = g_position_type THEN
    l_dynamic_sql := l_dynamic_sql
      ||' AND paf.position_id = '
      ||p_pre_search_id;
    IF p_grade_id IS NOT null THEN
      l_dynamic_sql := l_dynamic_sql
        ||' AND paf.grade_id = '
        ||' (SELECT pvg.grade_id'
        ||'    FROM per_valid_grades pvg'
        ||'   WHERE pvg.valid_grade_id = '
        ||p_grade_id||')';
    END IF;
  END IF;

  l_dynamic_sql := l_dynamic_sql || ' ORDER BY 2';

  l_sql_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_sql_cursor, l_dynamic_sql, dbms_sql.v7);
  dbms_sql.define_column(l_sql_cursor, 1, c_id, 15);
  dbms_sql.define_column(l_sql_cursor, 2, c_name, 240);
  dbms_sql.define_column(l_sql_cursor, 3, c_name, 80);
  l_rows := dbms_sql.execute(l_sql_cursor);
  l_index := 0;
  WHILE dbms_sql.fetch_rows(l_sql_cursor) > 0 LOOP
    l_index := l_index + 1;
    dbms_sql.column_value(l_sql_cursor, 1, p_person_id(l_index));
    dbms_sql.column_value(l_sql_cursor, 2, p_person_name(l_index));
    dbms_sql.column_value(l_sql_cursor, 3, p_person_type(l_index));
  END LOOP;
  p_count := l_index;

  dbms_sql.close_cursor(l_sql_cursor);

EXCEPTION
  WHEN others THEN
    IF dbms_sql.is_open(l_sql_cursor) THEN
      dbms_sql.close_cursor(l_sql_cursor);
    END IF;


END get_people_by_role;
-- ---------------------------------------------------------------------------
-- get_people_by_role_org
-- ---------------------------------------------------------------------------

PROCEDURE get_people_by_role_org
  (p_org_id 		in number
  ,p_effective_date in date
  ,p_person_id 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_name  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_type out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 		 out nocopy number) IS

  CURSOR csr_people_by_role_org IS
   SELECT distinct(paf.person_id) person_id
         ,ppf.full_name name
         ,hr_person_type_usage_info.get_user_person_type
           (p_effective_date, ppf.person_id) type
         ,ppf.order_name
     FROM per_assignments_f paf
         ,per_people_f ppf
    WHERE paf.organization_id = p_org_id
      AND paf.assignment_type = 'E'
      AND p_effective_date BETWEEN paf.effective_start_date
          AND NVL(paf.effective_end_date, p_effective_date)
      AND paf.person_id = ppf.person_id
      AND p_effective_date BETWEEN ppf.effective_start_date
          AND NVL(ppf.effective_end_date, p_effective_date)
    ORDER BY NVL(ppf.order_name,ppf.full_name);

  CURSOR csr_jp_people_by_role_org IS
   SELECT distinct(paf.person_id) person_id
         ,ppf.full_name name
         ,hr_person_type_usage_info.get_user_person_type
             (p_effective_date,ppf.person_id) type
         ,ppf.last_name
         ,ppf.first_name
     FROM per_assignments_f paf
         ,per_people_f ppf
    WHERE paf.organization_id = p_org_id
      AND paf.assignment_type = 'E'
      AND p_effective_date BETWEEN paf.effective_start_date
          AND NVL(paf.effective_end_date, p_effective_date)
      AND paf.person_id = ppf.person_id
      AND p_effective_date BETWEEN ppf.effective_start_date
          AND NVL(ppf.effective_end_date, p_effective_date)
    ORDER BY ppf.last_name, ppf.first_name;

BEGIN

  hr_util_misc_web.validate_session(p_person_id => c_person_id);
  c_legislation_code := hr_misc_web.get_legislation_code
    (p_person_id => c_person_id);

  p_count := 0;
  IF c_legislation_code = g_japan_legislation_code THEN
    FOR v_people_by_role_org IN csr_jp_people_by_role_org LOOP
      p_count := p_count + 1;
      p_person_id(p_count) := v_people_by_role_org.person_id;
      p_person_name(p_count) := v_people_by_role_org.name;
      p_person_type(p_count) := v_people_by_role_org.type;
    END LOOP;
  ELSE
    FOR v_people_by_role_org IN csr_people_by_role_org LOOP
      p_count := p_count + 1;
      p_person_id(p_count) := v_people_by_role_org.person_id;
      p_person_name(p_count) := v_people_by_role_org.name;
      p_person_type(p_count) := v_people_by_role_org.type;
    END LOOP;
  END IF;

END get_people_by_role_org;

-- ---------------------------------------------------------------------------
-- get_people_by_role_job
-- ---------------------------------------------------------------------------

PROCEDURE get_people_by_role_job
  (p_job_id 			in number
  ,p_grade_id 			in number
  ,p_effective_date 	in date
  ,p_person_id 		 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_name 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_type	    out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 			 out nocopy number) IS

  CURSOR csr_people_by_role_job IS
   SELECT distinct(paf.person_id) person_id
         ,ppf.full_name name
         ,hr_person_type_usage_info.get_user_person_type
             (p_effective_date,ppf.person_id) type
         ,ppf.order_name
     FROM per_assignments_f paf
         ,per_people_f ppf
    WHERE paf.job_id = p_job_id
      AND paf.assignment_type = 'E'
      AND (p_grade_id is null or paf.grade_id = p_grade_id)
      AND p_effective_date BETWEEN paf.effective_start_date
          AND NVL(paf.effective_end_date, p_effective_date)
      AND paf.person_id = ppf.person_id
      AND p_effective_date BETWEEN ppf.effective_start_date
          AND NVL(ppf.effective_end_date, p_effective_date)
    ORDER BY NVL(ppf.order_name,ppf.full_name);

  CURSOR csr_jp_people_by_role_job IS
   SELECT distinct(paf.person_id) person_id
         ,ppf.full_name name
         ,hr_person_type_usage_info.get_user_person_type
            (p_effective_date,ppf.person_id) type
         ,ppf.last_name
         ,ppf.first_name
     FROM per_assignments_f paf
         ,per_people_f ppf
    WHERE paf.job_id = p_job_id
      AND paf.assignment_type = 'E'
      AND (p_grade_id is null or paf.grade_id = p_grade_id)
      AND p_effective_date BETWEEN paf.effective_start_date
          AND NVL(paf.effective_end_date, p_effective_date)
      AND paf.person_id = ppf.person_id
      AND p_effective_date BETWEEN ppf.effective_start_date
          AND NVL(ppf.effective_end_date, p_effective_date)
    ORDER BY ppf.last_name, ppf.first_name;

BEGIN

  hr_util_misc_web.validate_session(p_person_id => c_person_id);
  c_legislation_code := hr_misc_web.get_legislation_code
    (p_person_id => c_person_id);

  p_count := 0;
  IF c_legislation_code = g_japan_legislation_code THEN
    FOR v_people_by_role_job IN csr_jp_people_by_role_job LOOP
      p_count := p_count + 1;
      p_person_id(p_count) := v_people_by_role_job.person_id;
      p_person_name(p_count) := v_people_by_role_job.name;
      p_person_type(p_count) := v_people_by_role_job.type;
    END LOOP;
  ELSE
    FOR v_people_by_role_job IN csr_people_by_role_job LOOP
      p_count := p_count + 1;
      p_person_id(p_count) := v_people_by_role_job.person_id;
      p_person_name(p_count) := v_people_by_role_job.name;
      p_person_type(p_count) := v_people_by_role_job.type;
    END LOOP;
  END IF;

END get_people_by_role_job;

-- ---------------------------------------------------------------------------
-- get_people_by_role_pos
-- ---------------------------------------------------------------------------

PROCEDURE get_people_by_role_pos
  (p_pos_id 			in number
  ,p_grade_id 			in number
  ,p_effective_date 	in date
  ,p_person_id 		 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_name 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_person_type 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 			 out nocopy number) IS

  CURSOR csr_people_by_role_pos IS
   SELECT distinct(paf.person_id) person_id
         ,ppf.full_name name
         ,hr_person_type_usage_info.get_user_person_type
            (p_effective_date,ppf.person_id) type
         ,ppf.order_name
     FROM per_assignments_f paf
         ,per_people_f ppf
    WHERE paf.position_id = p_pos_id
      AND paf.assignment_type = 'E'
      AND (p_grade_id is null or paf.grade_id = p_grade_id)
      AND p_effective_date BETWEEN paf.effective_start_date
          AND NVL(paf.effective_end_date, p_effective_date)
      AND paf.person_id = ppf.person_id
      AND p_effective_date BETWEEN ppf.effective_start_date
          AND NVL(ppf.effective_end_date, p_effective_date)
    ORDER BY NVL(ppf.order_name,ppf.full_name);

  CURSOR csr_jp_people_by_role_pos IS
   SELECT distinct(paf.person_id) person_id
         ,ppf.full_name name
         ,hr_person_type_usage_info.get_user_person_type
            (p_effective_date,ppf.person_id) type
         ,ppf.last_name
         ,ppf.first_name
     FROM per_assignments_f paf
         ,per_people_f ppf
    WHERE paf.position_id = p_pos_id
      AND paf.assignment_type = 'E'
      AND (p_grade_id is null or paf.grade_id = p_grade_id)
      AND p_effective_date BETWEEN paf.effective_start_date
          AND NVL(paf.effective_end_date, p_effective_date)
      AND paf.person_id = ppf.person_id
      AND p_effective_date BETWEEN ppf.effective_start_date
          AND NVL(ppf.effective_end_date, p_effective_date)
    ORDER BY ppf.last_name, ppf.first_name;

BEGIN

  hr_util_misc_web.validate_session(p_person_id => c_person_id);
  c_legislation_code := hr_misc_web.get_legislation_code
    (p_person_id => c_person_id);

  p_count := 0;
  IF c_legislation_code = g_japan_legislation_code THEN
    FOR v_people_by_role_pos IN csr_jp_people_by_role_pos LOOP
      p_count := p_count + 1;
      p_person_id(p_count) := v_people_by_role_pos.person_id;
      p_person_name(p_count) := v_people_by_role_pos.name;
      p_person_type(p_count) := v_people_by_role_pos.type;
    END LOOP;
  ELSE
    FOR v_people_by_role_pos IN csr_people_by_role_pos LOOP
      p_count := p_count + 1;
      p_person_id(p_count) := v_people_by_role_pos.person_id;
      p_person_name(p_count) := v_people_by_role_pos.name;
      p_person_type(p_count) := v_people_by_role_pos.type;
    END LOOP;
  END IF;

END get_people_by_role_pos;

-- ---------------------------------------------------------------------------
-- get_course_by_person
-- ---------------------------------------------------------------------------

PROCEDURE get_course_by_person
  (p_person_id				in number
  ,p_activity_version_id  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name		 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 				 out nocopy number) IS

  CURSOR csr_course_by_person IS
  SELECT distinct(oe.activity_version_id) activity_version_id
        ,oav.version_name
    FROM ota_events oe
     	,ota_delegate_bookings odb
     	,ota_activity_versions oav
   WHERE odb.delegate_person_id = p_person_id
     AND odb.event_id = oe.event_id
     AND oe.activity_version_id = oav.activity_version_id;

BEGIN

  p_count := 0;
  FOR v_course_by_person IN csr_course_by_person LOOP
    p_count := p_count + 1;
    p_activity_version_id(p_count) := v_course_by_person.activity_version_id;
    p_name(p_count) := v_course_by_person.version_name;
  END LOOP;

END  get_course_by_person;

-- ---------------------------------------------------------------------------
-- get_people_by_course
-- ---------------------------------------------------------------------------

PROCEDURE get_people_by_course
  (p_activity_version_id 	in number
  ,p_person_id 		 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 		 out nocopy number) IS

  CURSOR csr_people_by_course IS
   SELECT odb.delegate_person_id  person_id
     FROM ota_delegate_bookings odb
    WHERE odb.event_id IN
         (SELECT oe.event_id
            FROM ota_events oe
           WHERE oe.activity_version_id = p_activity_version_id);

BEGIN

  p_count := 0;
  FOR v_people_by_course IN csr_people_by_course LOOP
    p_count := p_count + 1;
    p_person_id(p_count) := v_people_by_course.person_id;
  END LOOP;

END  get_people_by_course;

-- ---------------------------------------------------------------------------
-- get_rating_scale_by_competence
-- ---------------------------------------------------------------------------

PROCEDURE get_rating_scale_by_competence
  (p_competence_id 		in number
  ,p_rating_level_id  out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_step_value 	 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_name 			 out nocopy hr_util_misc_web.g_varchar2_tab_type
  ,p_count 			 out nocopy number) IS

  CURSOR csr_rating_level_by_scale IS
  SELECT prl.rating_level_id, prl.step_value, rtx.name
    FROM per_rating_levels prl
        ,per_competences pc
        ,per_rating_levels_tl rtx
   WHERE pc.competence_id = p_competence_id
     AND pc.rating_scale_id = prl.rating_scale_id
     AND prl.rating_level_id = rtx.rating_level_id
     AND rtx.language = userenv('LANG')
   ORDER BY step_value;

  CURSOR csr_rating_level_by_competence IS
  SELECT prl.rating_level_id, prl.step_value, rtx.name
    FROM per_rating_levels prl
        ,per_competences pc
        ,per_rating_levels_tl rtx
   WHERE pc.competence_id = p_competence_id
     AND pc.competence_id = prl.competence_id
     AND prl.rating_level_id = rtx.rating_level_id
     AND rtx.language = userenv('LANG')
   ORDER BY step_value;

BEGIN

  p_count := 0;
  FOR v_rating_level_by_scale IN csr_rating_level_by_scale LOOP
    p_count := p_count + 1;
    p_rating_level_id(p_count) := v_rating_level_by_scale.rating_level_id;
    p_step_value(p_count) := v_rating_level_by_scale.step_value;
    p_name(p_count) := v_rating_level_by_scale.name;
  END LOOP;
  IF p_count = 0 THEN
    FOR v_rating_level_by_competence IN csr_rating_level_by_competence LOOP
      p_count := p_count + 1;
     p_rating_level_id(p_count) := v_rating_level_by_competence.rating_level_id;
      p_step_value(p_count) := v_rating_level_by_competence.step_value;
      p_name(p_count) := v_rating_level_by_competence.name;
    END LOOP;
  END IF;

END get_rating_scale_by_competence;
------------------------------------------------------------------------------

END hr_suit_match_utility_web;

/
