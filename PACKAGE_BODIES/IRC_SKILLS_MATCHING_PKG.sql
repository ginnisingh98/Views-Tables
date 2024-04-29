--------------------------------------------------------
--  DDL for Package Body IRC_SKILLS_MATCHING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_SKILLS_MATCHING_PKG" AS
/* $Header: irsklpkg.pkb 120.0.12010000.2 2008/12/03 05:29:30 mkjayara ship $ */

--GLOBAL CONSTANTS gco_...
  gco_delim  varchar2(1) :=',';
  gco_delim2 varchar2(1) :='>';

--GLOBAL TYPES gt_...
  --Tie together the corresponding 3 related ID's
  TYPE gt_skill_rec_type IS RECORD (
                          skill_id  PER_COMPETENCES.competence_id%type,
                          max_id    PER_RATING_LEVELS.rating_level_id%TYPE,
                          min_id    PER_RATING_LEVELS.rating_level_id%TYPE,
                          essential PER_COMPETENCE_ELEMENTS.mandatory%TYPE  );

  --Type to hold the set of records tying in the sets of three related input strings
  TYPE gt_skills_tab_type IS TABLE OF gt_skill_rec_type index by binary_integer;


--GLOBAL CURSORS gt_...
  -- Cursor to get a list of skills and levels for a given set of scopes
  CURSOR gc_skills_reqd_list (cp_org  PER_COMPETENCE_ELEMENTS.enterprise_id%TYPE,
                              cp_bgp  PER_COMPETENCE_ELEMENTS.organization_id%TYPE,
                              cp_job  PER_COMPETENCE_ELEMENTS.position_id%TYPE,
                              cp_pos  PER_COMPETENCE_ELEMENTS.position_id%TYPE,
                              cp_eff_date  PER_COMPETENCE_ELEMENTS.effective_date_to%TYPE
                             )  IS
    SELECT pc.name,
       pc.competence_id,
       pc.rating_scale_id,
       MAX(minpr.STEP_VALUE) highest_min_level,
       MIN(maxpr.STEP_VALUE) lowest_max_level,
       pce.MANDATORY
     FROM per_competences pc,
       per_competence_elements pce,
       per_rating_levels minpr,
       per_rating_levels maxpr
     WHERE pc.competence_id = pce.competence_id
     AND   pce.PROFICIENCY_LEVEL_ID = minpr.rating_level_id(+)
     AND   pce.HIGH_PROFICIENCY_LEVEL_ID = maxpr.rating_level_id(+)
     AND   pce.type = 'REQUIREMENT'
     AND   trunc(CP_EFF_DATE)  between trunc(pce.effective_date_from) and trunc (nvl(pce.effective_date_to,CP_EFF_DATE))
     AND (       pce.job_id            = CP_JOB
              or pce.POSITION_ID       = CP_POS
              or pce.ORGANIZATION_ID   = CP_ORG
              or pce.ENTERPRISE_ID     = CP_BGP)
     AND pc.business_group_id is null
     GROUP BY pc.competence_id,
              pc.name,
              pce.MANDATORY,
              pc.rating_scale_id;


 CURSOR gc_rating_level_details(cp_rate_scale  PER_RATING_LEVELS.rating_scale_id%TYPE,
                               cp_step_value1  PER_RATING_LEVELS.step_value%TYPE,
                               cp_step_value2  PER_RATING_LEVELS.step_value%TYPE)  IS
      SELECT rating_level_id --, step_value, name as level_name
      FROM per_rating_levels
      WHERE rating_scale_id = CP_RATE_SCALE
      AND      ( step_value = CP_STEP_VALUE1 or step_value = CP_STEP_VALUE2)
      ORDER BY step_value;

 CURSOR gc_comp_rating_level_details(cp_competence_id  PER_RATING_LEVELS.competence_id%TYPE,
                               cp_step_value1  PER_RATING_LEVELS.step_value%TYPE,
                               cp_step_value2  PER_RATING_LEVELS.step_value%TYPE)  IS
      SELECT rating_level_id --, step_value, name as level_name
      FROM per_rating_levels
      WHERE competence_id = CP_COMPETENCE_ID
      AND      ( step_value = CP_STEP_VALUE1 or step_value = CP_STEP_VALUE2)
      ORDER BY step_value;

 CURSOR gc_get_vac_scopes(cp_vacancy per_all_vacancies.vacancy_id%TYPE,
                           cp_date     per_all_vacancies.date_to%TYPE)  IS
    SELECT organization_id,business_group_id,position_id,job_id
    FROM per_all_vacancies
    WHERE vacancy_id = CP_VACANCY
    AND    CP_DATE between nvl(date_from,trunc(SYSDATE))
                        and nvl(date_to,hr_api.g_eot);

-- ----------------------------------------------------------------------------
-- |-----------------------< SKILLS_MATCH_PERCENT  >--------------------------|
-- ----------------------------------------------------------------------------

--Take a list of esse[ntial] and pref[erred] skills, (and min/max low level_id for each)
--and return a percentage figure for how well a given person matches.
--if not all essential skills matched then return -1.
FUNCTION SKILLS_MATCH_PERCENT  ( p_esse_sk_list_str VARCHAR2,
                                 p_esse_sk_mins_str VARCHAR2,
                                 p_esse_sk_maxs_str VARCHAR2,
                                 p_pref_sk_list_str VARCHAR2,
                                 p_pref_sk_mins_str VARCHAR2,
                                 p_pref_sk_maxs_str VARCHAR2,
                                 p_person_id number)     RETURN VARCHAR2


IS

BEGIN
  -- Call main program setting get_value to true, i.e. interested in getting a final numerical result
  return skills_match( p_esse_sk_list_str,
                       p_esse_sk_mins_str,
                       p_esse_sk_maxs_str,
                       p_pref_sk_list_str,
                       p_pref_sk_mins_str,
                       p_pref_sk_maxs_str,
                       p_person_id,
                       true);
END SKILLS_MATCH_PERCENT;


-- ----------------------------------------------------------------------------
-- |-----------------------< SKILLS_MATCH_TEST  >--------------------------|
-- ----------------------------------------------------------------------------

--Take a list of esse[ntial] and pref[erred] skills, (and min/max low level_id for each)
--and return a percentage figure for how well a given person matches.
--if not all essentall skills matched then return -1.
FUNCTION SKILLS_MATCH_TEST  ( p_esse_sk_list_str VARCHAR2,
                                 p_esse_sk_mins_str VARCHAR2,
                                 p_esse_sk_maxs_str VARCHAR2,
                                 p_person_id number)     RETURN BOOLEAN


IS
l_value VARCHAR2(3);
BEGIN
  -- Call main program setting get_value to false, i.e. quit as soon as we know person has got the essential skills
  l_value :=  skills_match( p_esse_sk_list_str,
                       p_esse_sk_mins_str,
                       p_esse_sk_maxs_str,
                       '',
                       '',
                       '',
                       p_person_id,
                       false);

  if to_number(l_value) = -1 then return false;
  else return true;
  end if;
END SKILLS_MATCH_TEST;

-- ----------------------------------------------------------------------------
-- |----------------------------< SKILLS_MATCH  >-----------------------------|
-- ----------------------------------------------------------------------------

--Take a list of esse[ntial] and pref[erred] skills, (and min/max low level_id for each)
--and return a percentage figure for how well a given person matches.
--if not all essentall skills matched then return -1.
FUNCTION SKILLS_MATCH  ( p_esse_sk_list_str VARCHAR2,
                         p_esse_sk_mins_str VARCHAR2,
                         p_esse_sk_maxs_str VARCHAR2,
                         p_pref_sk_list_str VARCHAR2,
                         p_pref_sk_mins_str VARCHAR2,
                         p_pref_sk_maxs_str VARCHAR2,
                         p_person_id NUMBER,
                         p_get_percent_flag BOOLEAN)     RETURN VARCHAR2


IS

  --Start of definition
  --Weakly defined cursor
  TYPE lt_dyn_query_cur_type is ref cursor;
  --Instances
  lc_dyn_query_cur      lt_dyn_query_cur_type;

  --Store for the valid numbers used to ease the latter dynamic queries
  TYPE lt_rating_level_tab_type is table of per_rating_levels.step_value%type index by binary_integer;
  --Instances
  l_rating_level_tab   lt_rating_level_tab_type;

  --Tie together the corresponding 3 related ID's
  TYPE lr_input_rec_type IS RECORD (
                          skill_id       PER_COMPETENCES.competence_id%type,
                          max_level_num  PER_RATING_LEVELS.step_value%TYPE,
                          min_level_num  PER_RATING_LEVELS.step_value%TYPE  );

  --Type to hold the set of records tying in the sets of three related input strings
  TYPE lt_input_tab_type IS TABLE OF lr_input_rec_type index by binary_integer;
  --Instances
  l_essential_tab      lt_input_tab_type;
  l_preferred_tab      lt_input_tab_type;


  --Type for temp store used to eliminate repeating skills
  Type lt_temp_tab_type is table of number index by binary_integer;
  l_temp_tab lt_temp_tab_type;

  l_t1 lt_temp_tab_type;
  l_t2 lt_temp_tab_type;
  l_t3 lt_temp_tab_type;
  l_len binary_integer := 0;

  -- Reads parameters in to global variables
  l_esse_sk_list_str  varchar2(4000) := p_esse_sk_list_str;
  l_esse_sk_mins_str  varchar2(4000) := p_esse_sk_mins_str;
  l_esse_sk_maxs_str  varchar2(4000) := p_esse_sk_maxs_str;
  l_pref_sk_list_str  varchar2(4000) := p_pref_sk_list_str;
  l_pref_sk_mins_str  varchar2(4000) := p_pref_sk_mins_str;
  l_pref_sk_maxs_str  varchar2(4000) := p_pref_sk_maxs_str;
  l_person_id          number := p_person_id;


  --Dynamic SQL variables (will be used 3 times)
  l_sql_select VARCHAR2(32000) :='';
  l_sql_from   VARCHAR2(32000) :='';
  l_sql_where  VARCHAR2(32000):='';
  l_sql_query  VARCHAR2(32000):='';

  --Total holders
  l_tot_esse_skills       NUMBER := 0;
  l_tot_pref_skills       NUMBER := 0;
  l_tot_skills            NUMBER := 0;
  l_tot_esse_skills_held  NUMBER := 0;
  l_tot_pref_skills_held  NUMBER := 0;
  l_tot_skills_held       NUMBER := 0;
  l_tot_percentage_match  NUMBER(3,0) := -1;

  --Miscellaneous
  l_concats   VARCHAR2(1000):='';
  l_rowcount  number;
  l_rating_level_id_temp    per_rating_levels.rating_level_id%type;
  l_step_value_temp         per_rating_levels.step_value%type;

  INCONSISTENT_INPUT_LENGTHS EXCEPTION;

  --SUB FUNCTION, turn input comma-delimeted list in to table
   FUNCTION string_to_table ( id_list IN VARCHAR2)
     RETURN lt_temp_tab_type
   IS
    i                  NUMBER := 1;
    l_value            VARCHAR2(100) :='';
    l_pos_of_ith_comma NUMBER := -1;
    l_pos_last_comma   NUMBER := 0;
    l_temp_table       lt_temp_tab_type;

   BEGIN
     <<next_comma_loop>>
     WHILE l_pos_of_ith_comma <> 0
     LOOP
       l_pos_of_ith_comma := nvl(instr(id_list,',',1,i),0);

       -- Take substring between commas or to end if no last comma
       if (l_pos_of_ith_comma <> 0) then
         l_value := SUBSTR(id_list,l_pos_last_comma +1,
                                   l_pos_of_ith_comma - l_pos_last_comma -1 );
       else l_value := SUBSTR(id_list,l_pos_last_comma +1);
       end if;
       if (l_value = '' or l_value is null) then l_value := '-1'; end if;
       l_temp_table(i) := to_number(l_value);
       l_pos_last_comma := l_pos_of_ith_comma;
       i := i + 1;

       l_pos_last_comma := l_pos_of_ith_comma;
     END LOOP next_comma_loop;
     RETURN l_temp_table;

     RETURN l_temp_table;

   END;

  --SUB FUNCTION
  --This is called twice, once for essential, once for preferred
  --sees how many skills a person matches on given a list and a min/max level
   FUNCTION get_number_of_skill_matches ( table_of_ids IN lt_input_tab_type)
     RETURN NUMBER
   IS
   BEGIN
     l_rowcount    := 0;
     l_sql_query   :='';
     l_sql_select  :=' SELECT  count(*)';
     l_sql_from    :=' FROM   per_competence_elements pce';
     l_sql_where   :=' WHERE pce.person_id = :1 '
                   ||' AND trunc(sysdate) between pce.effective_date_from and nvl(pce.effective_date_to,sysdate)'
                   ||' AND (    ( ';
     FOR l IN table_of_ids.first .. table_of_ids.last
     LOOP
       l_sql_where := l_sql_where||
         ' pce.competence_id='||table_of_ids(l).skill_id;

       if table_of_ids(l).min_level_num <> '-1'
         and table_of_ids(l).max_level_num <> '-1'
       then
         l_sql_where := l_sql_where|| ' AND  exists (select 1 from per_rating_levels  where rating_level_id=pce.proficiency_level_id'||
                 '  and step_value between ' || table_of_ids(l).min_level_num || ' and ' ||
  		      table_of_ids(l).max_level_num || ' ) )';
       elsif table_of_ids(l).min_level_num <> '-1'
       then
         l_sql_where := l_sql_where|| ' AND  exists (select 1 from per_rating_levels  where rating_level_id=pce.proficiency_level_id'||
                 '  and ' || '(step_value >= ' || table_of_ids(l).min_level_num  || ' ) ) )';
       elsif table_of_ids(l).max_level_num <> '-1'
       then
         l_sql_where := l_sql_where|| ' AND  exists (select 1 from per_rating_levels  where rating_level_id=pce.proficiency_level_id'||
                 '  and ' || '(step_value <= ' || table_of_ids(l).max_level_num || ' ) ) )';
       else
         l_sql_where := l_sql_where|| ' )';
       end if;
       if l <> table_of_ids.last   then l_sql_where := l_sql_where||'   or (';  end if;
     --
     END LOOP;
     l_sql_where := l_sql_where||'   )  ';
     l_sql_query := l_sql_select||l_sql_from||l_sql_where;
     execute immediate l_sql_query into l_rowcount using l_person_id ;

    RETURN l_rowcount;
  END;


BEGIN
--  MAIN FUNCTION LOGIC
-- [1] Get neat table of all step levels referenced by a passed in rating_level_id
--     (dynamic sql as cant use "IN 'string_list'" in cursor)
-- [2] Get two neat table of inputs, (one for essential skills, one for preferable, turning ID's into step values using [1]
-- [3] Test user has all essential skills at required levels -Get count of total- dynamic sql based on [1] and [2]
--     if no value then end function, return -1
-- [4] Count number of preferable skills user has at required levels -dynamic sql based on [1] and [2]
-- [5] Calculate % Figure depending on totals from sizes in [1], and user attained in [3] and [4]
--         Return x %, where x = (100 / total_skills) * number_of_skills_held.    0 <= x <= 100

-- ########
-- ######## Phase [1] Get table of step levels
-- ########

  --Build Query; Use cursor to populate table of skill_levels indexed by id
  -- Get decent comma-delimited list of ids referenced
  if p_esse_sk_mins_str is not null then
    l_concats := p_esse_sk_mins_str||',';
  else
    l_concats := '-1,';
  end if;
  --
  if p_esse_sk_maxs_str is not null then
     l_concats := l_concats || p_esse_sk_maxs_str||',';
  else
    l_concats := l_concats || '-1,';
  end if;
  --
  if p_pref_sk_mins_str is not null then
    l_concats := l_concats || p_pref_sk_mins_str||',';
  else
    l_concats := l_concats || '-1,';
  end if;
  --
  if p_pref_sk_maxs_str is not null then
    l_concats := l_concats || p_pref_sk_maxs_str;
  else
    l_concats := l_concats || '-1';
  end if;
-- Got list, now build dynamic query

    l_sql_select  :='SELECT  rl.rating_level_id,rl.step_value';
    l_sql_from    :=' FROM   per_rating_levels rl';
    l_sql_where   :=' WHERE rl.rating_level_id IN ('||l_concats||') ';
    l_sql_query := l_sql_select||l_sql_from||l_sql_where;
    --NB Appears cant put :1 in where clause and use "open l_rating_cur for g_sql_query using g_concats;"
    open lc_dyn_query_cur for l_sql_query;
    LOOP
      fetch lc_dyn_query_cur into l_rating_level_id_temp,l_step_value_temp;
      exit when lc_dyn_query_cur%NOTFOUND;
      l_rating_level_tab(l_rating_level_id_temp):=l_step_value_temp;
    END LOOP;
    close lc_dyn_query_cur;
   --Can now reference the value of a step given its ID by using g_rating_level_tab(id);
   --If no level is used, an arbitrary value of -1 is used so add this to this quick lookup table
   l_rating_level_tab(-1):=-1;

   --End of Phase 1


-- ######## Phase [2] Get tables of input
-- ########
  --Turn 3 input strings (related to ESSENTIAL skills) in to 3 tables
  IF l_esse_sk_list_str is not null
  THEN
    l_t1 := string_to_table(l_esse_sk_list_str);
    l_len := l_t1.count;
    l_t2 := string_to_table(l_esse_sk_mins_str);
    if l_len <> l_t2.count then raise INCONSISTENT_INPUT_LENGTHS; end if;
    l_t3 := string_to_table(l_esse_sk_maxs_str);
    if l_len <> l_t3.count then raise INCONSISTENT_INPUT_LENGTHS; end if;
    l_temp_tab.delete;

    --Consolidate 3 tables in to one, if duplicates then restrict to tightest range
    for j in 1..l_len loop
      -- If ID for skill exists then replace min/max to form tightest boundaries
      -- else insert new information in g_essential_tab (if previous min was -1 defo use new min level)
      if l_temp_tab.exists(l_t1(j)) then
        if ( l_essential_tab( l_temp_tab(l_t1(j)) ).min_level_num <  l_rating_level_tab(l_t2(j))
           OR l_rating_level_tab(l_t2(j)) = -1) then
           l_essential_tab( l_temp_tab(l_t1(j)) ).min_level_num := l_rating_level_tab( l_t2(j) );
        end if;
        if l_essential_tab( l_temp_tab(l_t1(j)) ).max_level_num >  l_rating_level_tab( l_t3(j) ) then
           l_essential_tab( l_temp_tab(l_t1(j)) ).max_level_num := l_rating_level_tab( l_t3(j) );
        end if;
      else
        l_temp_tab(l_t1(j)):=j;  --make record of anything, index by skill_id
        l_essential_tab(j).skill_id      := l_t1(j);
        l_essential_tab(j).min_level_num := l_rating_level_tab( l_t2(j) );
        l_essential_tab(j).max_level_num := l_rating_level_tab( l_t3(j) );
      end if;
    end loop;
    if l_essential_tab(1).skill_id <> '-1' then
      l_tot_esse_skills:= l_essential_tab.count;
    end if;

  END IF;

  IF l_pref_sk_list_str is not null
  THEN
    --Turn 3 input strings (related to PREFERRED skills) in to 3 tables
    l_t1 := string_to_table(l_pref_sk_list_str);
    l_len := nvl(l_t1.count,0);
    l_t2 := string_to_table(l_pref_sk_mins_str);
    if l_len <> l_t2.count then raise INCONSISTENT_INPUT_LENGTHS; end if;
    l_t3 := string_to_table(l_pref_sk_maxs_str);
    if l_len <> l_t3.count then raise INCONSISTENT_INPUT_LENGTHS; end if;
    l_temp_tab.delete;

    for j in 1..l_len loop
      if l_temp_tab.exists(l_t1(j)) then
        if l_preferred_tab( l_temp_tab(l_t1(j)) ).min_level_num <  l_rating_level_tab( l_t2(j) ) then
           l_preferred_tab( l_temp_tab(l_t1(j)) ).min_level_num := l_rating_level_tab( l_t2(j) );
        end if;
        if l_preferred_tab( l_temp_tab(l_t1(j)) ).max_level_num >  l_rating_level_tab( l_t3(j) ) then
           l_preferred_tab( l_temp_tab(l_t1(j)) ).max_level_num := l_rating_level_tab( l_t3(j) );
        end if;
      else
        l_temp_tab(l_t1(j)):=j;
        l_preferred_tab(j).skill_id      := l_t1(j);
        l_preferred_tab(j).min_level_num := l_rating_level_tab( l_t2(j) );
        l_preferred_tab(j).max_level_num := l_rating_level_tab( l_t3(j) );
      end if;
    end loop;
    if l_preferred_tab(1).skill_id <> '-1' then
      l_tot_pref_skills:= l_preferred_tab.count;
    end if;
  END IF;
  -- Set totals for tracking and scoring
  l_tot_skills := l_tot_esse_skills + l_tot_pref_skills;

 -- ########
 -- ######## Phase [3] Test user has essential skills AND they're at the right level
 -- ########
  if l_tot_esse_skills <> 0 then
      l_tot_esse_skills_held := get_number_of_skill_matches(l_essential_tab);
  end if;

 -- ######## Phase [4] Count number of preferred skills held at correct level
 -- ########
   -- only need to do the remaining code (getting preferred results and scoring) if person
   -- has ALL of the essential skills
   IF l_tot_esse_skills_held = l_tot_esse_skills
   THEN
     if p_get_percent_flag then --Want exact percentage so find out about preferred skills
       if l_tot_pref_skills <> 0
       then
         l_tot_pref_skills_held := get_number_of_skill_matches(l_preferred_tab);
       end if;
       --End of Phase 4

       -- ######## Phase [5] Calculate percentage figure
       -- ########
       l_tot_skills_held := l_tot_esse_skills_held + l_tot_pref_skills_held;
       if l_tot_skills <> 0 then
         l_tot_percentage_match := (100 / l_tot_skills) *l_tot_skills_held;
       else l_tot_percentage_match := 100;
       end if;
     else  --Dont want exact percent, so skip the extra calculations
      l_tot_percentage_match := 1;
     end if;
   ELSE
     l_tot_percentage_match := -1;
   END IF;


  RETURN l_tot_percentage_match;

EXCEPTION
WHEN INCONSISTENT_INPUT_LENGTHS then
  hr_utility.set_message(800, 'IRC_INCONSISTENT_LIST_LENGTHS');
  hr_utility.raise_error;

END SKILLS_MATCH; --end main function


-- ----------------------------------------------------------------------------
-- |-----------------------< GET_SKILLS_FOR_SCOPE_TABLE  >--------------------------|
-- ----------------------------------------------------------------------------

-- Take a set of ID's and return a completed table, then calling function can manipulate as required.
-- This is called by get_skills_for_scope and vacancy_match_percent
FUNCTION GET_SKILLS_FOR_SCOPE_TABLE  (
                                p_org_id  number default 0,
                                p_bgp_id  number default 0,
                                p_job_id  number default 0,
                                p_pos_id  number default 0,
                                p_eff_date  date   default sysdate)     RETURN gt_skills_tab_type


IS
  -- Reads parameters in to local variables
  l_org_id number := p_org_id;
  l_bgp_id number := p_bgp_id;
  l_job_id number := p_job_id;
  l_pos_id number := p_pos_id;
  l_eff_date  date        := p_eff_date;
  l_counter number := 1;

l_table gt_skills_tab_type;
BEGIN
--  MAIN FUNCTION LOGIC


  FOR l_skill_rec IN gc_skills_reqd_list(l_org_id,l_bgp_id,l_job_id,l_pos_id,l_eff_date) LOOP
    --Set first information, eg competence_id and mandatory
    l_table(l_counter).skill_id := l_skill_rec.competence_id;
    l_table(l_counter).essential := l_skill_rec.mandatory;
    if l_skill_rec.rating_scale_id is NULL then
      open gc_comp_rating_level_details(l_skill_rec.competence_id,l_skill_rec.highest_min_level,l_skill_rec.lowest_max_level);
      --set min val (result of first fetch), and max (2nd row)
      fetch gc_comp_rating_level_details into l_table(l_counter).min_id;
      fetch gc_comp_rating_level_details into l_table(l_counter).max_id;
      close gc_comp_rating_level_details;
    else
      open gc_rating_level_details(l_skill_rec.rating_scale_id,l_skill_rec.highest_min_level,l_skill_rec.lowest_max_level);
      --set min val (result of first fetch), and max (2nd row)
      fetch gc_rating_level_details into l_table(l_counter).min_id;
      fetch gc_rating_level_details into l_table(l_counter).max_id;
      close gc_rating_level_details;
    end if;

    if l_skill_rec.highest_min_level = l_skill_rec.lowest_max_level then l_table(l_counter).max_id := l_table(l_counter).min_id; end if;

    if l_table(l_counter).min_id is null then l_table(l_counter).min_id := -1;  end if;
    if l_table(l_counter).max_id is null then l_table(l_counter).max_id := -1;  end if;

    l_counter := l_counter + 1;
  END LOOP;
 RETURN l_table;

END GET_SKILLS_FOR_SCOPE_TABLE;


-- ----------------------------------------------------------------------------
-- |-----------------------< GET_SKILLS_FOR_SCOPE  >--------------------------|
-- ----------------------------------------------------------------------------

--Take a set of ID's and return the skill requirements
FUNCTION GET_SKILLS_FOR_SCOPE  (
                                p_org_id  number default 0,
                                p_bgp_id  number default 0,
                                p_job_id  number default 0,
                                p_pos_id  number default 0,
                                p_eff_date  date   default sysdate)     RETURN VARCHAR2


IS
l_got_skill_ids_tab      gt_skills_tab_type;
l_result_str VARCHAR2(2000) := '';

BEGIN
--  MAIN FUNCTION LOGIC
--Get table of skills, and then format as required
l_got_skill_ids_tab := GET_SKILLS_FOR_SCOPE_TABLE(p_org_id,p_bgp_id,p_job_id,p_pos_id,p_eff_date);

-- Format to return is
-- "competence_id,mandatory,min-level_id,max-level_id>competence_id,mandatory,min-level_id,max-level_id>..."

  FOR item IN 1..l_got_skill_ids_tab.count LOOP
    if item <> 1 then l_result_str := l_result_str ||gco_delim2;
    end if;
    l_result_str := l_result_str||l_got_skill_ids_tab(item).skill_id||gco_delim||l_got_skill_ids_tab(item).essential
                                ||gco_delim||l_got_skill_ids_tab(item).min_id||gco_delim||l_got_skill_ids_tab(item).max_id;
  END LOOP;

  if (l_result_str = '') then l_result_str := '-1';  end if;

RETURN l_result_str;

END GET_SKILLS_FOR_SCOPE;

-- ----------------------------------------------------------------------------
-- |-----------------------< GET_SKILLS_FOR_VAC  >--------------------------|
-- ----------------------------------------------------------------------------

--Take a set of ID's and return the requirements
FUNCTION GET_SKILLS_FOR_VAC  (
                                p_vacancy_id  varchar2 default 0,
                                p_eff_date  date   default sysdate)     RETURN VARCHAR2


IS
  -- Reads parameters in to local variables
  l_org_id  varchar2(240) := '0';
  l_bgp_id  varchar2(240) := '0';
  l_job_id  varchar2(240) := '0';
  l_pos_id  varchar2(240) := '0';
l_result_str VARCHAR2(2000) := '';
l_got_skill_ids_tab      gt_skills_tab_type;

BEGIN
--  MAIN FUNCTION LOGIC
-- [1] Get scopes associated with vacancy
-- [2] Get skills required for scopes
-- [3] Turn results in to required format

  -- ######## Phase [1] Get scopes associated with vacancy
  -- ########
  open gc_get_vac_scopes(p_vacancy_id, p_eff_date);
  fetch gc_get_vac_scopes into l_org_id,l_bgp_id,l_pos_id,l_job_id;
  close gc_get_vac_scopes;

  -- ######## Phase [2] Get skills required for scopes
  -- ########
  l_got_skill_ids_tab := GET_SKILLS_FOR_SCOPE_TABLE(l_org_id,l_bgp_id,l_job_id,l_pos_id,p_eff_date);

  -- ######## Phase [3] Turn table in to preferred format
  -- ########
    -- "competence_id,mandatory,min-level_id,max-level_id>competence_id,mandatory,min-level_id,max-level_id>..."
  FOR item IN 1..l_got_skill_ids_tab.count LOOP
    if item <> 1 then l_result_str := l_result_str ||gco_delim2;
    end if;
    l_result_str := l_result_str||l_got_skill_ids_tab(item).skill_id||gco_delim||l_got_skill_ids_tab(item).essential
                                ||gco_delim||l_got_skill_ids_tab(item).min_id||gco_delim||l_got_skill_ids_tab(item).max_id;
  END LOOP;

  RETURN l_result_str;

END GET_SKILLS_FOR_VAC;

-- ----------------------------------------------------------------------------
-- |-----------------------< VACANCY_MATCH_PERCENT  >--------------------------|
-- ----------------------------------------------------------------------------

FUNCTION VACANCY_MATCH_PERCENT  (
                                p_person_id  number,
                                p_vacancy_id  varchar2,
                                p_eff_date  date  default sysdate)     RETURN VARCHAR2

IS

CURSOR lc_get_vac_requirements(cp_vacancy_id per_all_vacancies.vacancy_id%TYPE) IS
  select competence_id,
         nvl(mandatory,'N')                as mandatory,
         nvl(proficiency_level_id,-1)      as proficiency_level_id,
         nvl(high_proficiency_level_id,-1) as high_proficiency_level_id
  from per_competence_elements
  where object_name = 'VACANCY'
  and object_id = CP_VACANCY_ID;

  l_esse_sk_list_str  varchar2(4000);
  l_esse_sk_mins_str  varchar2(4000);
  l_esse_sk_maxs_str  varchar2(4000);
  l_pref_sk_list_str  varchar2(4000);
  l_pref_sk_mins_str  varchar2(4000);
  l_pref_sk_maxs_str  varchar2(4000);

  l_delim  varchar2(1) :='';
  l_delimp varchar2(1) :='';

l_percentage varchar2(3);

BEGIN
--  MAIN FUNCTION LOGIC -VACANCY_MATCH_PERCENT
-- [1] Get skills required for vacancy
-- [2] Reformat in to strings so can...
-- [3] call skills_match_percent

 -- ######## Phase [1], [2] Get skills associated with vacancy and place in strings
 -- ########
  l_percentage := -1;

  FOR l_skill_requirement_rec IN lc_get_vac_requirements(p_vacancy_id) LOOP
    if l_skill_requirement_rec.mandatory = 'Y' then
      l_esse_sk_list_str := l_esse_sk_list_str||l_delim||l_skill_requirement_rec.competence_id;
      l_esse_sk_mins_str := l_esse_sk_mins_str||l_delim||l_skill_requirement_rec.proficiency_level_id;
      l_esse_sk_maxs_str := l_esse_sk_maxs_str||l_delim||l_skill_requirement_rec.high_proficiency_level_id;
      l_delim := gco_delim;
    else
      l_pref_sk_list_str := l_pref_sk_list_str||l_delimp||l_skill_requirement_rec.competence_id;
      l_pref_sk_mins_str := l_pref_sk_mins_str||l_delimp||l_skill_requirement_rec.proficiency_level_id;
      l_pref_sk_maxs_str := l_pref_sk_maxs_str||l_delimp||l_skill_requirement_rec.high_proficiency_level_id;
      l_delimp := gco_delim;
    end if;
  END LOOP;


  -- ######## Phase [3] Get Percentage using lists of skills and levels
  -- ########
  l_percentage := IRC_SKILLS_MATCHING_PKG.skills_match_percent(
                          l_esse_sk_list_str,l_esse_sk_mins_str,l_esse_sk_maxs_str,
                          l_pref_sk_list_str,l_pref_sk_mins_str,l_pref_sk_maxs_str,    p_person_id);
  return l_percentage;

END VACANCY_MATCH_PERCENT;

END IRC_SKILLS_MATCHING_PKG;

/
