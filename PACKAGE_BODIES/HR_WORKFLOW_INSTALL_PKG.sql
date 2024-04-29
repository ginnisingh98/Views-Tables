--------------------------------------------------------
--  DDL for Package Body HR_WORKFLOW_INSTALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WORKFLOW_INSTALL_PKG" as
/* $Header: petskflw.pkb 120.1 2005/06/13 04:47:01 rvarshne noship $ */
current_workflow_id        number;
current_nav_unit_id        number;
current_nav_node_id        number;
current_nav_node_usage_id  number;
current_global_usage_id    number;
location                   varchar2(80);
-- ;
-- ;
PROCEDURE taskflow_report  (	  g_workflow_name_width		NUMBER	DEFAULT 30
				, g_from_form_name_width	NUMBER  DEFAULT 20
				, g_from_node_name_width	NUMBER  DEFAULT 20
				, g_to_form_name_width		NUMBER  DEFAULT 20
				, g_to_node_name_width		NUMBER  DEFAULT 20
				, g_sequence_width		NUMBER  DEFAULT 9
				, g_button_label_width		NUMBER  DEFAULT 20)
IS
--
TYPE r_formatted_style IS
TABLE OF  VARCHAR2(100)
INDEX BY BINARY_INTEGER;
--
--
-- The _2 columns are to hold overflow if any of the columns overflow the
-- column width.
--
TYPE r_taskflow_details IS RECORD
 ( workflow_name_1        VARCHAR2(100)
  ,workflow_name_2        VARCHAR2(100)
  ,from_form_name_1       VARCHAR2(100)
  ,from_form_name_2       VARCHAR2(100)
  ,from_node_name_1       VARCHAR2(100)
  ,from_node_name_2       VARCHAR2(100)
  ,to_form_name_1         VARCHAR2(100)
  ,to_form_name_2         VARCHAR2(100)
  ,to_node_name_1         VARCHAR2(100)
  ,to_node_name_2         VARCHAR2(100)
  ,sequence_1             VARCHAR2(100)
  ,sequence_2             VARCHAR2(100)
  ,button_label_1         VARCHAR2(100)
  ,button_label_2         VARCHAR2(100)
  ,second_row_usage       VARCHAR2(10) );
  --
  --
TYPE t_taskflow_details IS
TABLE OF
  r_taskflow_details
INDEX BY BINARY_INTEGER;
  --
CURSOR c_taskflow_details IS
  SELECT  w.workflow_name AS workflow_name,
        nu2.form_name AS from_form_name,
        nn2.name AS from_node_name,
        nu.form_name AS to_form_name,
        nn.name AS to_node_name,
        to_char(p.sequence) AS sequence,
        ptl.override_label AS Button_label
  FROM  hr_navigation_node_usages NNU,
        hr_navigation_node_usages NNU2,
        hr_workflows W,
        hr_navigation_units NU,
        hr_navigation_nodes NN,
        hr_navigation_units NU2,
        hr_navigation_nodes NN2,
        hr_navigation_paths P,
        hr_navigation_paths_tl PTL
  WHERE   nn2.nav_node_id = nnu2.nav_node_id
  AND     nnu2.workflow_id = w.workflow_id
  AND     nn2.nav_unit_id = nu2.nav_unit_id
  AND     p.FROM_NAV_NODE_USAGE_ID = nnu2.nav_node_usage_id
  AND     p.TO_NAV_NODE_USAGE_ID = nnu.nav_node_usage_id
  AND     nn.nav_node_id = nnu.nav_node_id
  AND     nnu.workflow_id = w.workflow_id
  AND     nn.nav_unit_id = nu.nav_unit_id
  AND     p.nav_path_id = ptl.nav_path_id
  AND     ptl.language=userenv('LANG')
  ORDER BY w.workflow_name, from_form_name, from_node_name, p.sequence;
  --
  l_taskflow_details 		t_taskflow_details;
  l_formatted_padded_string	r_formatted_style;
  l_first_row		VARCHAR2(300);
  l_second_row	        VARCHAR2(300);
  l_second_row_used     VARCHAR2(300);
  l_taskflow_rowcount	NUMBER;
  --
  l_workflow_name       VARCHAR2(100);
  l_from_form_name      VARCHAR2(100);
  l_from_node_name      VARCHAR2(100);
  --
FUNCTION format_details (whole_string 		IN	VARCHAR2 DEFAULT '.'
		  	,report_column_width 	IN	NUMBER   DEFAULT 30)
RETURN r_formatted_style IS
  --
  -- Local procedure to split input, whole_string, into two columns
  -- to a specified length, report_column_width.  Blank spaces pad
  -- out the extra spaces. If a line start with a blank space, it is
  -- converted to a .
  --
  l_padded_string_rec	r_formatted_style;
BEGIN
  --
  -- If the whole_string is over twice the length of the report_column_with,  the remainer will be truncated.
  l_padded_string_rec(1) := SUBSTR (RPAD (whole_string, (report_column_width * 2)) ,1, report_column_width);
  l_padded_string_rec(2) := SUBSTR (RPAD (whole_string, (report_column_width * 2)) , report_column_width + 1);
  --
  -- If the first char of either string begins with a ' ', then convert it to a '.' as dbms_output ignores
  -- leading spaces.
  --
  IF SUBSTR( l_padded_string_rec(1),1,1) = ' ' THEN
    l_padded_string_rec(1) := '.'|| SUBSTR( l_padded_string_rec(1), 2, LENGTH( l_padded_string_rec(1) ) -1);
  END IF;
  --
  IF SUBSTR( l_padded_string_rec(2),1,1) = ' ' THEN
    l_padded_string_rec(2) := '.'|| SUBSTR( l_padded_string_rec(2), 2, LENGTH( l_padded_string_rec(2) ) -1);
  END IF;
  --
  RETURN l_padded_string_rec;
  --
END format_details;
--
-- Adds the first two rows to the PLSQL table - the name of the column an underscore
PROCEDURE Add_Title
IS
  l_title_string VARCHAR2(100) DEFAULT NULL;
BEGIN
  FOR l_counter IN 1 .. 2 LOOP

    IF l_counter = 2 THEN l_title_string := RPAD('-',g_workflow_name_width,'-'); END IF;
    l_formatted_padded_string  :=  format_details ( whole_string 	=> NVL( l_title_string,'WORKFLOW_NAME ')
						  , report_column_width => g_workflow_name_width);
    l_taskflow_details(l_counter).workflow_name_1 := l_formatted_padded_string(1);
    l_taskflow_details(l_counter).workflow_name_2 := l_formatted_padded_string(2);
    --
    IF l_counter = 2 THEN l_title_string := RPAD('-',g_from_form_name_width,'-'); END IF;
    l_formatted_padded_string  :=  format_details ( whole_string 	=> NVL( l_title_string,'FROM_FORM_NAME ')
						  , report_column_width => g_from_form_name_width);
    l_taskflow_details(l_counter).from_form_name_1 := l_formatted_padded_string(1);
    l_taskflow_details(l_counter).from_form_name_2 := l_formatted_padded_string(2);
    --
    IF l_counter = 2 THEN l_title_string := RPAD('-',g_from_node_name_width,'-'); END IF;
    l_formatted_padded_string  :=  format_details ( whole_string 	=> NVL( l_title_string, 'FROM_NODE_NAME ')
						  , report_column_width => g_from_node_name_width);
    l_taskflow_details(l_counter).from_node_name_1 := l_formatted_padded_string(1);
    l_taskflow_details(l_counter).from_node_name_2 := l_formatted_padded_string(2);
    --
    IF l_counter = 2 THEN l_title_string := RPAD('-',g_to_form_name_width,'-'); END IF;
    l_formatted_padded_string  :=  format_details ( whole_string 	=> NVL( l_title_string, 'TO_FORM_NAME ')
						  , report_column_width => g_to_form_name_width);
    l_taskflow_details(l_counter).to_form_name_1 := l_formatted_padded_string(1);
    l_taskflow_details(l_counter).to_form_name_2 := l_formatted_padded_string(2);
    --
    IF l_counter = 2 THEN l_title_string := RPAD('-',g_to_node_name_width,'-'); END IF;
    l_formatted_padded_string  :=  format_details ( whole_string 	=> NVL( l_title_string, 'TO_NODE_NAME ')
						  , report_column_width => g_to_node_name_width);
    l_taskflow_details(l_counter).to_node_name_1 := l_formatted_padded_string(1);
    l_taskflow_details(l_counter).to_node_name_2 := l_formatted_padded_string(2);
    --
    IF l_counter = 2 THEN l_title_string := RPAD('-',g_sequence_width,'-'); END IF;
    l_formatted_padded_string  :=  format_details ( whole_string 	=> NVL( l_title_string, 'SEQUENCE ')
						  , report_column_width => g_sequence_width);
    l_taskflow_details(l_counter).sequence_1 := l_formatted_padded_string(1);
    l_taskflow_details(l_counter).sequence_2 := l_formatted_padded_string(2);
    --
    IF l_counter = 2 THEN l_title_string := RPAD('-',g_button_label_width,'-'); END IF;
    l_formatted_padded_string  :=  format_details ( whole_string 	=> NVL( l_title_string, 'BUTTON_LABEL ')
						  , report_column_width => g_button_label_width);
    l_taskflow_details(l_counter).button_label_1 := l_formatted_padded_string(1);
    l_taskflow_details(l_counter).button_label_2 := l_formatted_padded_string(2);
    --
    -- Check whether the second row is used or not (. were inserted by the format_details function)
    --
    l_second_row :=  l_taskflow_details(l_counter).workflow_name_2
		  || l_taskflow_details(l_counter).from_form_name_2
	          || l_taskflow_details(l_counter).from_node_name_2
		  || l_taskflow_details(l_counter).to_form_name_2
	          || l_taskflow_details(l_counter).to_node_name_2
	          || l_taskflow_details(l_counter).sequence_2
 	          || l_taskflow_details(l_counter).button_label_2;
    l_second_row_used := NVL(RTRIM(REPLACE(l_second_row,'.'),' '),'NOT_USED');
    IF l_second_row_used <> 'NOT_USED' THEN
      l_second_row_used := 'USED';
    END IF;
  END LOOP;
    --
END Add_Title;

BEGIN
  -- DBMS_OUTPUT.ENABLE(1000000);
  -- Include the title as the first row in the PL/SQL table
  --
  Add_Title;
  --
  -- NOTE: 2 is added to the row count as the first two rows are for the title
  FOR l_details IN  c_taskflow_details
  LOOP
    --
    l_formatted_padded_string  :=  format_details ( whole_string 	=> l_details.workflow_name
						  , report_column_width => g_workflow_name_width);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).workflow_name_1 := l_formatted_padded_string(1);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).workflow_name_2 := l_formatted_padded_string(2);
    --
    l_formatted_padded_string  :=  format_details ( whole_string 	=> l_details.from_form_name
						  , report_column_width => g_from_form_name_width);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).from_form_name_1 := l_formatted_padded_string(1);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).from_form_name_2 := l_formatted_padded_string(2);
    --
    l_formatted_padded_string  :=  format_details ( whole_string 	=> l_details.from_node_name
						  , report_column_width => g_from_node_name_width);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).from_node_name_1 := l_formatted_padded_string(1);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).from_node_name_2 := l_formatted_padded_string(2);
    --
    l_formatted_padded_string  :=  format_details ( whole_string 	=> l_details.to_form_name
						  , report_column_width => g_to_form_name_width);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).to_form_name_1 := l_formatted_padded_string(1);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).to_form_name_2 := l_formatted_padded_string(2);
    --
    l_formatted_padded_string  :=  format_details ( whole_string 	=> l_details.to_node_name
						  , report_column_width => g_to_node_name_width);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).to_node_name_1 := l_formatted_padded_string(1);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).to_node_name_2 := l_formatted_padded_string(2);
    --
    l_formatted_padded_string  :=  format_details ( whole_string 	=> l_details.sequence
						  , report_column_width => g_sequence_width);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).sequence_1 := l_formatted_padded_string(1);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).sequence_2 := l_formatted_padded_string(2);
    --
    l_formatted_padded_string  :=  format_details ( whole_string 	=> l_details.button_label
						  , report_column_width => g_button_label_width);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).button_label_1 := l_formatted_padded_string(1);
    l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).button_label_2 := l_formatted_padded_string(2);
    --
    -- Check whether the second row is used or not (. were inserted by the format_details function)
    --
    l_second_row :=  l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).workflow_name_2
		  || l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).from_form_name_2
	          || l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).from_node_name_2
		  || l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).to_form_name_2
	          || l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).to_node_name_2
	          || l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).sequence_2
 	          || l_taskflow_details(c_taskflow_details%ROWCOUNT + 2).button_label_2;
    l_second_row_used := NVL(RTRIM(REPLACE(l_second_row,'.'),' '),'NOT_USED');
    IF l_second_row_used <> 'NOT_USED' THEN
      l_second_row_used := 'USED';
    END IF;
    --
    l_taskflow_details(c_taskflow_details%ROWCOUNT).second_row_usage := l_second_row_used;
  END LOOP;
  --
  -- The tf details now exist in a PL/SQL table, so print them. Only print the second row if
  -- it exists.
  --
  -- Display_Title;
  --
  IF l_taskflow_details.EXISTS(1) THEN
    FOR l_counter IN 1 .. l_taskflow_details.COUNT LOOP
      l_first_row := l_taskflow_details(l_counter).workflow_name_1
		  || l_taskflow_details(l_counter).from_form_name_1
	          || l_taskflow_details(l_counter).from_node_name_1
		  || l_taskflow_details(l_counter).to_form_name_1
	          || l_taskflow_details(l_counter).to_node_name_1
	          || l_taskflow_details(l_counter).sequence_1
 	          || l_taskflow_details(l_counter).button_label_1;
      --
      -- Bug#885806
      -- dbms_output.put_line(l_first_row);
      hr_utility.trace(l_first_row);
      --
      IF l_taskflow_details(l_counter).second_row_usage = 'USED' THEN
        l_second_row :=  l_taskflow_details(l_counter).workflow_name_2
  		  || l_taskflow_details(l_counter).from_form_name_2
	          || l_taskflow_details(l_counter).from_node_name_2
		  || l_taskflow_details(l_counter).to_form_name_2
	          || l_taskflow_details(l_counter).to_node_name_2
	          || l_taskflow_details(l_counter).sequence_2
 	          || l_taskflow_details(l_counter).button_label_2;
        -- Bug#885806
        -- dbms_output.put_line(l_second_row);
        hr_utility.trace(l_second_row);
      END IF;
    END LOOP;
  ELSE
    -- Bug#885806
    -- dbms_output.put_line('No Taskflow details to print');
    hr_utility.trace('No Taskflow details to print');
  END IF;
  --
END taskflow_report;
--
-- Outputs a message
procedure log_message ( p_msg in varchar2 ) is
begin

   -- Bug#885806
   -- dbms_output.put_line( p_msg ) ;
   hr_utility.trace( p_msg ) ;

end log_message ;

-- Returns the name of the given workflow if it exists otherwise
-- returns null.
function find_workflow_name( p_workflow_id in number ) return varchar2 is
cursor c1 is
  select workflow_name
  from   hr_workflows
  where  workflow_id = p_workflow_id ;
l_return_value hr_workflows.workflow_name%type := null ;
begin
   open c1 ;
   fetch c1 into l_return_value ;
   close c1 ;

   return ( l_return_value ) ;
end find_workflow_name ;

-- Returns the id for a given workflow
function find_workflow_id( p_workflow_name in varchar2 ) return number is
cursor c1 is
  select workflow_id
  from   hr_workflows
  where  workflow_name = p_workflow_name ;
l_return_value number := null ;
begin
   open c1 ;
   fetch c1 into l_return_value ;
   close c1 ;

   return ( l_return_value ) ;
end find_workflow_id ;

procedure get_workflow_id (p_workflow_name varchar2) is
	cursor id is
		select	workflow_id
		from	hr_workflows
		where	workflow_name = p_workflow_name;
	begin
	if p_workflow_name is not null then
	  open id;
	  fetch id into current_workflow_id;
	  if id%notfound then
     current_workflow_id := null ;
   end if;
	  close id;
	else
	  current_workflow_id := null;
	end if;
	end get_workflow_id;
procedure get_nav_unit_id (p_form_name varchar2,
				p_block_name varchar2 default null) is
	cursor id is
		select	nav_unit_id
		from	hr_navigation_units
		where	form_name = p_form_name
			and nvl(block_name,'-9999')=nvl(p_block_name,'-9999');
	begin
	open id;
	fetch id into current_nav_unit_id;
	close id;
	end get_nav_unit_id;
procedure get_nav_node_id (p_name varchar2) is
	cursor id is
		select	nav_node_id
		from	hr_navigation_nodes
		where	name = p_name;
	begin
	open id;
	fetch id into current_nav_node_id;
	close id;
	end get_nav_node_id;
procedure get_node_usage_id is
	cursor id is
		select	nav_node_usage_id
		from	hr_navigation_node_usages
		where	nav_node_id = current_nav_node_id
		and	workflow_id = current_workflow_id;
	begin
	open id;
	fetch id into current_nav_node_usage_id;
	close id;
	end get_node_usage_id;
procedure new_workflow (p_name varchar2) is
	begin
 get_workflow_id(p_name);
 if ( current_workflow_id is null ) then
	   insert into hr_workflows (workflow_id, workflow_name)
	   values (hr_workflows_s.nextval,	 p_name);
    get_workflow_id (p_name);
 end if;
	end new_workflow;
procedure new_nav_unit (
	p_application_abbrev	varchar2,
	p_form_name		varchar2,
	p_default_label		varchar2,
	p_max_no_of_buttons	number,
	p_block_name		varchar2) is
    l_current_language varchar2(3);
    l_nav_unit_id      number;
	begin

       insert into hr_navigation_units (
		nav_unit_id,
		application_abbrev,
		default_label,
		form_name,
		max_number_of_nav_buttons,
		block_name)
	values (
		hr_navigation_units_s.nextval,
		p_application_abbrev,
		p_default_label,
		p_form_name,
		p_max_no_of_buttons,
		p_block_name);

	get_nav_unit_id (p_form_name,p_block_name);

 		select	nav_unit_id
        into    l_nav_unit_id
		from	hr_navigation_units
		where	form_name = p_form_name
    	and nvl(block_name,'-9999')=nvl(p_block_name,'-9999');

     select L.language_code
     into   l_current_language
     from   FND_LANGUAGES L
     where L.INSTALLED_FLAG in ('I', 'B')
     and not exists
    (select NULL
     from HR_NAVIGATION_UNITS_TL T
     where T.NAV_UNIT_ID = L_NAV_UNIT_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);

   insert into hr_navigation_units_tl (
    nav_unit_id
   ,language
   ,source_lang
   ,default_label
   )
  select b.nav_unit_id
        ,l_current_language
        ,userenv('LANG')
        ,b.default_label
  from hr_navigation_units b
  where not exists
    (select '1'
     from hr_navigation_units_tl t
     where t.nav_unit_id = b.nav_unit_id
       and t.language = l_current_language);
       end new_nav_unit;

procedure new_nav_node (p_name				varchar2,
			p_customized_restriction_id	number default null) is
	begin
	insert into hr_navigation_nodes (
		nav_node_id,
		nav_unit_id,
		name,
		customized_restriction_id)
	values (
		hr_navigation_nodes_s.nextval,
		current_nav_unit_id,
		p_name,
		p_customized_restriction_id);
	get_nav_node_id (p_name);
	end new_nav_node;
procedure new_nav_node_usage (
	p_top_node	varchar2) is
	begin
	insert into hr_navigation_node_usages (
		nav_node_usage_id,
		workflow_id,
		nav_node_id,
		top_node)
	values (
		hr_navigation_node_usages_s.nextval,
		current_workflow_id,
		current_nav_node_id,
		p_top_node);
	get_node_usage_id;
	end new_nav_node_usage;

procedure new_path (
	p_to_name		varchar2,
	p_nav_button_required	varchar2,
	p_sequence		number,
	p_override_label	varchar2
    ) is
	l_current_nav_node_usage_id	number;
	l_from			number;
	l_to			number;
    l_current_language varchar2(3);
    l_nav_path_id   number;
	begin


	l_current_nav_node_usage_id := current_nav_node_usage_id;
	l_from := current_nav_node_usage_id;
	get_nav_node_id (p_to_name);
	get_node_usage_id;
	l_to := current_nav_node_usage_id;
	current_nav_node_usage_id := l_current_nav_node_usage_id;

	insert into hr_navigation_paths (
		nav_path_id,
		from_nav_node_usage_id,
		to_nav_node_usage_id,
		nav_button_required,
		sequence,
		override_label)
	values (
		hr_navigation_paths_s.nextval,
		l_from,
		l_to,
		p_nav_button_required,
		p_sequence,
		p_override_label);

  select nav_path_id
  into   l_nav_path_id
  from   hr_navigation_paths
  where  from_nav_node_usage_id = l_from
  and    to_nav_node_usage_id = l_to;

    select L.language_code
    into   l_current_language
    from   FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
    (select NULL
    from HR_NAVIGATION_PATHS_TL T
    where T.NAV_PATH_ID = L_NAV_PATH_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

    insert into hr_navigation_paths_tl (
    nav_path_id
   ,language
   ,source_lang
   ,override_label
   )
  select b.nav_path_id
        ,l_current_language
        ,userenv('LANG')
        ,b.override_label
        from hr_navigation_paths b
  where not exists
    (select '1'
     from hr_navigation_paths_tl t
     where t.nav_path_id = b.nav_path_id
       and t.language = l_current_language);

	end new_path;

procedure get_global_usage_id (p_global_name varchar2) is
	cursor id is
		select	global_usage_id
		from hr_nav_unit_global_usages
		where	global_name = p_global_name
		and	nav_unit_id = current_nav_unit_id;
	begin
	open id;
	fetch id into current_global_usage_id;
	close id;
	end get_global_usage_id;
procedure new_global_usage (
	p_global_name	varchar2,
	p_in_or_out	varchar2,
	p_mandatory_flag	varchar2) is
	begin
	insert into hr_nav_unit_global_usages (
		global_usage_id,
		nav_unit_id,
		global_name,
		in_or_out,
		mandatory_flag)
	values (
		hr_nav_unit_global_usages_s.nextval,
		current_nav_unit_id,
		p_global_name,
		p_in_or_out,
		p_mandatory_flag);
	get_global_usage_id (p_global_name);
	end new_global_usage;
procedure new_context_rule (
	p_evaluation_type_code	varchar2,
	p_value			varchar2) is
	begin
	insert into hr_navigation_context_rules (
		nav_context_rule_id,
		global_usage_id,
		evaluation_type_code,
		value)
	values (
		hr_navigation_context_rules_s.nextval,
		current_global_usage_id,
		p_evaluation_type_code,
		p_value);
	end new_context_rule;
end;

/
