--------------------------------------------------------
--  DDL for Package Body HR_CONSTRAINT_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CONSTRAINT_CHECK" AS
/*$Header: hrconchk.pkb 115.3 2004/02/13 04:37:54 mroberts ship $*/
--
-- Package variables
g_number   number default 0;
--
-- |--------------------------------------------------------------------------|
-- |------------------------------< get_schema >------------------------------|
-- |--------------------------------------------------------------------------|
FUNCTION get_schema(p_product IN VARCHAR2) RETURN VARCHAR2 IS
--
l_value BOOLEAN;
l_out_status VARCHAR2(30);
l_out_industry VARCHAR2(30);
l_out_oracle_schema VARCHAR2(30);

--
BEGIN
--

  l_value := FND_INSTALLATION.GET_APP_INFO (p_product, l_out_status,
                                          l_out_industry, l_out_oracle_schema);


  RETURN(l_out_oracle_schema);

-- error handling
EXCEPTION
WHEN OTHERS THEN
  RAISE;

END get_schema;
--
-- ----------------------------------------------------------------------------
-- |------------------------< build_constraint_list >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE build_constraint_list (p_prod IN varchar2
				,p_list IN OUT NOCOPY ConsList) IS
--
cursor csr_find_ben_constraints (c_per_owner in varchar2,
                                 c_ben_owner in varchar2) is
  select table_name,
         constraint_name
    from all_constraints
   where table_name like 'BEN_%'
      and constraint_name not like 'SYS_%'
      and ((owner = c_per_owner) or
           (owner = c_ben_owner))
    order by table_name, constraint_name;
--
cursor csr_find_per_constraints (c_per_owner in varchar2) is
  select table_name,
         constraint_name
    from all_constraints
   where ((table_name like 'PER_%') or
          ((table_name like 'HR_%') and
           (table_name not like 'HRI_%')))
      and constraint_name not like 'SYS_%'
      and owner = c_per_owner
    order by table_name, constraint_name;
--
cursor csr_find_hri_constraints (c_owner in varchar2) is
  select table_name,
         constraint_name
    from all_constraints
   where ((table_name like 'HR_EDW%') or
          (table_name like 'HRI_%'))
      and constraint_name not like 'SYS_%'
      and owner = c_owner
    order by table_name, constraint_name;
--
cursor csr_find_constraints(c_prod in varchar2,
                            c_owner in varchar2) is
  select table_name,
	 constraint_name
    from all_constraints
   where table_name like c_prod
     and constraint_name not like 'SYS_%'
     and owner = c_owner
   order by table_name, constraint_name;
--
cursor csr_find_applications is
  select application_id, application_short_name
    from fnd_application
   order by application_short_name;
--
l_list       integer := 0;
l_owner      varchar2(30);
l_per_owner  varchar2(30);
l_prod       varchar2(50);
--
BEGIN
  --
  -- Get PER schema now as it is used in multiple places
  l_per_owner := get_schema('PER');
  --
  IF p_prod = 'PER' THEN
     -- PER is a special case - involves HR and PER tables
     FOR c1 IN csr_find_per_constraints(l_per_owner) LOOP
	 p_list(l_list).constraint_name := c1.constraint_name;
	 p_list(l_list).table_name := c1.table_name;
         -- Increment list counter
	 l_list := l_list + 1;
     END LOOP;
  ELSIF p_prod =  'HRI' THEN
     -- HRI is a special case as they deliver HR_EDW tables
     l_owner := get_schema('HRI');
     FOR c1 IN csr_find_hri_constraints(l_owner) LOOP
         p_list(l_list).constraint_name := c1.constraint_name;
         p_list(l_list).table_name := c1.table_name;
         -- Increment list counter
         l_list := l_list + 1;
     END LOOP;
  ELSIF p_prod =  'BEN' THEN
     -- BEN is a special case as they deliver tables in both BEN and PER
     -- schema
     l_owner := get_schema('BEN');
     FOR c1 IN csr_find_ben_constraints(l_per_owner, l_owner) LOOP
         p_list(l_list).constraint_name := c1.constraint_name;
         p_list(l_list).table_name := c1.table_name;
         -- Increment list counter
         l_list := l_list + 1;
     END LOOP;
  ELSIF p_prod = 'ALL' THEN
     -- Find all products
     FOR c1 in csr_find_applications LOOP
         IF hr_general.chk_application_id(c1.application_id) = 'TRUE' THEN
            IF c1.application_short_name = 'PER' THEN
               FOR c1 IN csr_find_per_constraints(l_per_owner) LOOP
                 p_list(l_list).constraint_name := c1.constraint_name;
                 p_list(l_list).table_name := c1.table_name;
                 -- Increment list counter
                 l_list := l_list + 1;
               END LOOP;
            ELSIF c1.application_short_name = 'HRI' THEN
               l_owner := get_schema('HRI');
               FOR c1 IN csr_find_hri_constraints(l_owner) LOOP
                 p_list(l_list).constraint_name := c1.constraint_name;
                 p_list(l_list).table_name := c1.table_name;
                 -- Increment list counter
                 l_list := l_list + 1;
               END LOOP;
            ELSIF c1.application_short_name = 'BEN' THEN
               l_owner := get_schema('BEN');
               FOR c1 IN csr_find_ben_constraints(l_per_owner,l_owner) LOOP
                 p_list(l_list).constraint_name := c1.constraint_name;
                 p_list(l_list).table_name := c1.table_name;
                 -- Increment list counter
                 l_list := l_list + 1;
               END LOOP;
            ELSE
               l_owner := get_schema(c1.application_short_name);
               l_prod := c1.application_short_name || '_%';
               FOR c1 IN csr_find_constraints(l_prod, l_owner) LOOP
                 p_list(l_list).constraint_name := c1.constraint_name;
                 p_list(l_list).table_name := c1.table_name;
                 -- Increment list counter
                 l_list := l_list + 1;
               END LOOP;
            END IF;
         END IF;
     END LOOP;
  ELSE
     l_owner := get_schema(p_prod);
     l_prod := p_prod || '_%';
     FOR c1 IN csr_find_constraints(l_prod, l_owner) LOOP
         p_list(l_list).constraint_name := c1.constraint_name;
         p_list(l_list).table_name := c1.table_name;
         -- Increment list counter
         l_list := l_list + 1;
     END LOOP;
  END IF;
  --
  p_list(l_list).constraint_name := null;
  --
END build_constraint_list;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< add_result >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  Adds a result of the constraint checking to the results table, for later
--  output.
--
-- In Paremeters:
--  p_constraint - the name of the constraint.
--  p_table - the table upon which the constraint has been defined.
--  p_case - 'Y' if the constraint is defined in CASE, otherwise 'N'.
--  p_db - 'Y' if the constraint is defined in the Db, otherwise 'Y'.
--
-- ----------------------------------------------------------------------------
PROCEDURE add_result (p_constraint IN varchar2
                     ,p_table      IN varchar2
                     ,p_case       IN varchar2
                     ,p_db         IN varchar2) IS
--
  l_text varchar2(80);
  l_number integer;
--
BEGIN
  hr_utility.set_location('Adding to hr_api_user_hook_reports',99);
  --
  hr_utility.set_location('Adding for line: '||to_char(g_number),1);
  --
  IF p_constraint = 'HEADER' and p_table = 'HEADER' THEN
     l_text :=
      'TABLE                          CONSTRAINT                     CODE STATUS';
     --
     -- Insert report header
     insert into hr_api_user_hook_reports
      (session_id,
       line,
       text)
     values
      (userenv('SESSIONID'),
       g_number,
       l_text);
     -- Increment line counter
     g_number := g_number + 1;
     l_text :=
      '-----------------------------------------------------------------------------';
     insert into hr_api_user_hook_reports
      (session_id,
       line,
       text)
     values
      (userenv('SESSIONID'),
       g_number,
       l_text);
     -- Increment line counter
  ELSIF p_constraint = 'FOOTER' and p_table = 'FOOTER' THEN
     l_text :=
      'End of Report ';
     insert into hr_api_user_hook_reports
      (session_id,
       line,
       text)
     values
      (userenv('SESSIONID'),
       g_number,
       l_text);
     g_number := g_number + 1;
     insert into hr_api_user_hook_reports
      (session_id,
       line,
       text)
     values
      (userenv('SESSIONID'),
       g_number+1,
       '    ');
  ELSE
    l_text := rpad(p_table,30) || ' ' || rpad(p_constraint,30) || ' ';
    IF p_case = 'N' THEN
       l_text := l_text || '0    DB Only';
    END IF;
    IF p_db = 'N' THEN
       l_text := l_text || '1    Not in DB';
    END IF;
    -- Insert values into results table
    --
    insert into hr_api_user_hook_reports
      (session_id,
       line,
       text)
    values
      (userenv('SESSIONID'),
       g_number,
       l_text);
    --
  END IF;
  g_number := g_number + 1;
end add_result;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< find_missing_constraints >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE find_missing_constraints
  (p_db_list   IN hr_constraint_check.ConsList
  ,p_case_list IN hr_constraint_check.ConsList
  ) IS
  --
  l_db_index integer := 0;
  l_case_index integer := 0;
BEGIN
  --
  WHILE ((p_db_list(l_db_index).constraint_name IS NOT NULL) or
         (p_case_list(l_case_index).constraint_name IS NOT NULL)) LOOP
  --
    IF ((p_db_list(l_db_index).constraint_name
      = p_case_list(l_case_index).constraint_name) and
	(p_db_list(l_db_index).table_name
      = p_case_list(l_case_index).table_name))THEN
      -- Both constraints exist, advance both counters
      l_db_index := l_db_index +1;
      l_case_index := l_case_index +1;
    ELSIF ((p_case_list(l_case_index).constraint_name IS NULL) and
           (p_db_list(l_db_index).constraint_name IS NOT NULL)) or
          ((p_db_list(l_db_index).table_name <
            p_case_list(l_case_index).table_name)) THEN
      -- Have found a db constraint that does not exist in CASE
      -- because table does not exist in CASE ie. may be a development table
      -- Advance counter
      l_db_index := l_db_index + 1;
    ELSIF ((p_db_list(l_db_index).constraint_name IS NULL) and
           (p_case_list(l_case_index).constraint_name IS NOT NULL)) or
          ((p_case_list(l_case_index).table_name =
            p_db_list(l_db_index).table_name) and
           (p_case_list(l_case_index).constraint_name <
            p_db_list(l_db_index).constraint_name)) or
          ((p_case_list(l_case_index).table_name <
            p_db_list(l_db_index).table_name)) THEN
      -- Have found a CASE constraint that does not exist in DB
      add_result(p_constraint => p_case_list(l_case_index).constraint_name
                ,p_table      => p_case_list(l_case_index).table_name
                ,p_case       => 'Y'
                ,p_db         => 'N');
      -- Advance counter
      l_case_index := l_case_index + 1;
    ELSIF ((p_case_list(l_case_index).table_name =
            p_db_list(l_db_index).table_name) and
           (p_db_list(l_db_index).constraint_name <
            p_case_list(l_case_index).constraint_name)) THEN
      -- Have found a db constraint that does not exist in CASE, but the
      -- table does exist in CASE
      add_result(p_constraint => p_db_list(l_db_index).constraint_name
                ,p_table      => p_db_list(l_db_index).table_name
                ,p_case       => 'N'
                ,p_db         => 'Y');
      -- Advance counter
      l_db_index := l_db_index + 1;
    ELSE
      add_result(p_constraint => 'Error...'
                ,p_table      => 'Error...'
                ,p_case       => 'X'
                ,p_db         => 'X');
    END IF;
  END LOOP;
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
END find_missing_constraints;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< add_case_constraint >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_case_constraint
  (p_case_list  IN OUT NOCOPY hr_constraint_check.ConsList
  ,p_constraint IN varchar2
  ,p_table      IN varchar2
  ,p_index      IN OUT NOCOPY integer) IS
--
BEGIN
  p_case_list(p_index).constraint_name := p_constraint;
  p_case_list(p_index).table_name := p_table;
  p_index := p_index + 1;
  p_case_list(p_index).constraint_name := null;
END add_case_constraint;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< add_header >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_header IS
BEGIN
  -- Add column headers
  --
  add_result(p_constraint => 'HEADER'
            ,p_table      => 'HEADER'
            ,p_case       => 'Y'
            ,p_db         => 'Y');
  --
END add_header;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< add_footer >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE add_footer IS
BEGIN
  -- Add column headers
  --
  add_result(p_constraint => 'FOOTER'
            ,p_table      => 'FOOTER'
            ,p_case       => 'Y'
            ,p_db         => 'Y');
  --
END add_footer;
--
END hr_constraint_check;

/
