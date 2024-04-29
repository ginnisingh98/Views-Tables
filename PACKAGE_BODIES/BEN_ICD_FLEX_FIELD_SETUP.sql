--------------------------------------------------------
--  DDL for Package Body BEN_ICD_FLEX_FIELD_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ICD_FLEX_FIELD_SETUP" AS
/* $Header: beicdflexsetup.pkb 120.4.12010000.2 2009/01/21 11:43:23 vkodedal ship $ */
g_package  varchar2(30) :='BEN_ICD_FLEX_FIELD_SETUP.';
ICD_ELE_CTXT_CD_PREFIX varchar2(30) := 'ICD_ELE_TYPE_';
FUNCTION lowest_seq_input_value(
	P_ELEMENT_TYPE_ID IN VARCHAR2,
	P_EFFECTIVE_DATE IN DATE
	) return NUMBER is
cursor c_input_value is
	select input_value_id
	from pay_input_values_f
	where element_type_id = p_element_type_id
	and p_effective_date between effective_start_date and effective_end_date
	order by display_sequence asc;

l_proc varchar2(100) := g_package||'lowest_seq_input_value';
l_lowest_seq_input_value_id NUMBER;

begin
hr_utility.set_location('Entering: '||l_proc,10);

	for l_input_value in c_input_value loop
		l_lowest_seq_input_value_id := l_input_value.input_value_id;
		exit;
	end loop;

	hr_utility.set_location('Leaving: '||l_proc,20);

	return l_lowest_seq_input_value_id;
end lowest_seq_input_value;

FUNCTION create_lookup_valueset(
	P_LOOKUP_TYPE IN VARCHAR2,
	P_VIEW_APPLICATION_ID IN NUMBER,
	P_FORMAT_TYPE IN VARCHAR2
	) return varchar2 is

l_proc varchar2(100) := g_package||'create_lookup_valueset';
l_description varchar2(150);
l_value_set_name varchar2(40);
l_where_clause1 varchar2(250);
l_where_clause2 varchar2(250);
l_where_clause varchar2(500);

begin
hr_utility.set_location('Entering: '||l_proc,10);

	fnd_flex_val_api.set_session_mode('customer_data');
	l_value_set_name := 'ICD_'||p_lookup_type;
	l_description := 'ICD Value set for lookup type '||p_lookup_type;

/* When creating a value set for a Lookup, always enable "POPLIST" option for Valueset
This makes the corresponding segment appear as a POPLIST on the details page */

-- This splitting and joining the where clause is to avoid the GSCC chksql 6 error
l_where_clause1 := 'where lookup_type = '''||P_LOOKUP_TYPE||''' and language = USERENV(''LANG'') AND view_application_id = '|| P_VIEW_APPLICATION_ID ||'  AND security_group_id = ';
l_where_clause2 := ' fnd_global.lookup_security_group('''|| P_LOOKUP_TYPE ||''','||P_VIEW_APPLICATION_ID||') ORDER BY meaning';
l_where_clause := l_where_clause1 || l_where_clause2;

    if(NOT fnd_flex_val_api.valueset_exists(l_value_set_name)) then
    hr_utility.set_location('Creating valueset: '||l_value_set_name,20);
      fnd_flex_val_api.create_valueset_table(
	/* basic parameters */
	value_set_name		        => l_value_set_name,
	description			=> l_description,
	security_available		=> 'N', -- FLEX_VST_SECURITY_ENABLED_FLAG
	enable_longlist			=> 'X', -- POPLIST
	format_type			=> P_FORMAT_TYPE,
	maximum_size   			=> 60,
	numbers_only 			=> 'N',
	uppercase_only     		=> 'N',
	right_justify_zero_fill		=> 'N',
	min_value			=> NULL,
	max_value 			=> NULL,
        /* Table validation parameters */
	table_application		=> 'Application Object Library',
	table_appl_short_name           => 'FND',
	table_name			=> 'FND_LOOKUP_VALUES',
	allow_parent_values		=> 'N',
	value_column_name		=> 'MEANING',
	value_column_type		=> 'V',
	value_column_size		=> 80,
	id_column_name			=> 'LOOKUP_CODE',
	id_column_type			=> 'V',
	id_column_size			=> 30,
	where_order_by  		=> l_where_clause
);
    end if;

hr_utility.set_location('Leaving: '||l_proc,30);

    return l_value_set_name;

end create_lookup_valueset;


FUNCTION create_minmax_valueset(
	P_VIEW_APPLICATION_ID IN NUMBER,
	P_FORMAT_TYPE IN VARCHAR2,
	P_MIN_VALUE IN VARCHAR2,
	P_MAX_VALUE IN VARCHAR2
	) return varchar2 is

l_proc varchar2(100) := g_package||'create_minmax_valueset';
l_description varchar2(150);
l_value_set_name varchar2(40);

begin
hr_utility.set_location('Entering: '||l_proc,10);

	fnd_flex_val_api.set_session_mode('customer_data');
	l_value_set_name := 'ICD_'||P_MIN_VALUE||P_MAX_VALUE;
	l_description := 'ICD Value set for Min Max Input Value: '||l_value_set_name;

  if(NOT fnd_flex_val_api.valueset_exists(l_value_set_name)) then
  hr_utility.set_location('Creating valueset: '||l_value_set_name,20);
    fnd_flex_val_api.create_valueset_none(
	/* basic parameters */
	value_set_name		        => l_value_set_name,
	description			=> l_description,
	security_available		=> 'N',
	enable_longlist			=> 'N',
	format_type			=> P_FORMAT_TYPE,
	maximum_size   			=> 30,
--	precision 		        IN NUMBER    DEFAULT NULL,
	numbers_only 			=> 'N',
	uppercase_only     		=> 'N',
	right_justify_zero_fill		=> 'N',
	min_value			=> P_MIN_VALUE,
        max_value 			=> P_MAX_VALUE
	);
  end if;
hr_utility.set_location('Leaving: '||l_proc,30);

	return l_value_set_name;

end create_minmax_valueset;

FUNCTION create_data_format_valueset(
	 p_FORMAT_TYPE IN VARCHAR2
	,P_maximum_size IN NUMBER
	,P_NUMBER_PRECISION IN NUMBER
	,P_INPUT_VALUE_UOM IN VARCHAR2
	) return varchar2 is

l_proc varchar2(100) := g_package||'create_data_format_valueset';
l_description varchar2(150);
l_value_set_name varchar2(40);
l_format_type_name varchar2(100);
l_format_type varchar2(10);
begin
hr_utility.set_location('Entering: '||l_proc,10);
	fnd_flex_val_api.set_session_mode('customer_data');
    l_value_set_name := 'ICD_DFF_'||P_INPUT_VALUE_UOM;
	l_description := 'Only for internal use within ICD Developer Descriptive Flex Field';

  if(NOT fnd_flex_val_api.valueset_exists(l_value_set_name)) then
  hr_utility.set_location('Creating Valueset: '||l_value_set_name,20);
    fnd_flex_val_api.create_valueset_none(
	/* basic parameters */
	value_set_name		    => l_value_set_name,
	description				=> l_description,
	security_available		=> 'N',
	enable_longlist			=> 'N',
	format_type				=> p_FORMAT_TYPE,
	maximum_size   			=> P_maximum_size,
	precision 		        => P_NUMBER_PRECISION,
	numbers_only 			=> 'N',
	uppercase_only     		=> 'N',
	right_justify_zero_fill	=> 'N',
	min_value				=> NULL,
    max_value 				=> NULL
	);
  end if;
hr_utility.set_location('Leaving: '||l_proc,30);

	return l_value_set_name;

end create_data_format_valueset;

procedure CREATE_ICD_CONFIG
     (
      P_ELEMENT_TYPE_ID IN NUMBER,
      P_EFFECTIVE_DATE IN DATE
      ) is

/* Always order the Input Values by Id in asc */
cursor c_input_values(p_element_type_id number) is
select * from
pay_input_values_f
where element_type_id = p_element_type_id
and p_effective_date between effective_start_date and effective_end_date
order by input_value_id asc;

cursor c_element_type(p_element_type_id number) is
select * from
pay_element_types_f
where element_type_id = p_element_type_id
and p_effective_date between effective_start_date and effective_end_date;

i Number;
j Number;
n Number;
l_proc varchar2(100) := g_package||'create_icd_config';
l_element_type_id pay_element_types_f.element_type_id%TYPE;
l_element_entry_id number;
l_context_code FND_DESCR_FLEX_CONTEXTS.DESCRIPTIVE_FLEX_CONTEXT_CODE%TYPE;
l_element_type pay_element_types_f%ROWTYPE;
l_value_set_name fnd_flex_value_sets.flex_value_set_name%TYPE;
l_lookup_value_set_name fnd_flex_value_sets.flex_value_set_name%TYPE;
l_minmax_value_set_name fnd_flex_value_sets.flex_value_set_name%TYPE;
l_dataformat_value_set_name fnd_flex_value_sets.flex_value_set_name%TYPE;
l_segment_display_size fnd_descr_flex_column_usages.display_size%TYPE;
l_value_set_format_type fnd_flex_value_sets.format_type%TYPE;
l_value_set_maximum_size fnd_flex_value_sets.maximum_size%TYPE;
l_value_set_number_precision fnd_flex_value_sets.number_precision%TYPE;
l_user_enterable_flag ben_icd_ss_config.USER_ENTERABLE_FLAG%TYPE;
l_show_on_overview_flag ben_icd_ss_config.SHOW_ON_OVERVIEW_flag%TYPE;
l_context_exists_flag boolean;
l_ss_config_exists_flag boolean;
l_lowest_seq_input_value_id number;
l_required varchar2(1);
l_input_value_id pay_input_values_f.input_value_id%TYPE;

begin
hr_utility.set_location('Entering: '||l_proc,10);

  l_context_exists_flag := true;

  -- fetch Element Type Id

/*  Un comment this if you have to create context based on Element_Link_Id
select element_type_id into l_element_type_id
  from PAY_ELEMENT_LINKS_F
  where element_link_id = P_ELEMENT_LINK_ID
  and p_effective_date between effective_start_date and effective_end_date; */

-- Comment the below line if you have to create context based on Element_Link_Id
  l_element_type_id := p_element_type_id;

  -- Copy the element entry row if it already exists
  -- Create a new transaction row if it is new

  -- Create a new context for the Element Type


  open c_element_type(l_element_type_id);
    fetch c_element_type into l_element_type;
  close c_element_type;

  fnd_flex_dsc_api.set_session_mode('customer_data');

  begin
    select DESCRIPTIVE_FLEX_CONTEXT_CODE into l_context_code
    from FND_DESCR_FLEX_CONTEXTS
    where application_id = 805
    and DESCRIPTIVE_FLEXFIELD_NAME = 'Ben ICD Developer DF'
    and DESCRIPTIVE_FLEX_CONTEXT_CODE = to_char(l_element_type.element_type_id);
  EXCEPTION
	when no_data_found then
	  l_context_exists_flag := false;
  end;

  if(NOT l_context_exists_flag) then
  begin
  hr_utility.set_location('Creating Context: '||to_char(l_element_type.element_type_id),20);
    fnd_flex_dsc_api.create_context(
	/* identification */
	appl_short_name       => 'BEN',
	flexfield_name        => 'Ben ICD Developer DF',
	/* data */
	context_code          => to_char(l_element_type.element_type_id),
	context_name          => l_element_type.element_name,
    description           => l_element_type.reporting_name,
    enabled               => 'Y',
    global_flag           => 'N'
	);

    i := 1;
    l_lowest_seq_input_value_id := lowest_seq_input_value(p_element_type_id,p_effective_date);
   for l_input_value in c_input_values(l_element_type_id) loop
      hr_utility.set_location('Beginning processing InputValue: '||to_char(l_input_value.input_value_id),30);
      l_ss_config_exists_flag := true;

      /* Converting Input Value Data formats to Value Set Data format types */
      if('C'=l_input_value.UOM) then
          l_value_set_format_type :='C';
  		  l_value_set_maximum_size:= 60;
          l_value_set_number_precision:=null;
          l_segment_display_size := 30;
      elsif('D'=l_input_value.UOM) then
          l_value_set_format_type := 'X' ;
  		  l_value_set_maximum_size:= 11;
          l_value_set_number_precision:=null;
          l_segment_display_size := 11;
      elsif('H_DECIMAL1'=l_input_value.UOM) then
          l_value_set_format_type := 'N';
  		  l_value_set_maximum_size:=  16;
          l_value_set_number_precision:= 1;
          l_segment_display_size := 17;
      elsif('H_DECIMAL2'=l_input_value.UOM) then
          l_value_set_format_type := 'N' ;
  		  l_value_set_maximum_size:= 17;
          l_value_set_number_precision:= 2;
          l_segment_display_size := 18;
      elsif('H_DECIMAL3'=l_input_value.UOM) then
          l_value_set_format_type := 'N';
  		  l_value_set_maximum_size:= 18;
          l_value_set_number_precision:= 3;
          l_segment_display_size := 19;
      elsif('H_HH'=l_input_value.UOM) then
          l_value_set_format_type := 'N';
  		  l_value_set_maximum_size:= 38 ;
          l_value_set_number_precision:= 0;
          l_segment_display_size := 30;
      elsif('H_HHMM'=l_input_value.UOM) then
          l_value_set_format_type := 'C';
  		  l_value_set_maximum_size:= 40;
          l_value_set_number_precision:=0;
          l_segment_display_size := 30;
      elsif('H_HHMMSS'=l_input_value.UOM) then
          l_value_set_format_type := 'C';
  		  l_value_set_maximum_size:= 40;
          l_value_set_number_precision:=null;
          l_segment_display_size := 30;
      elsif('I'=l_input_value.UOM) then
          l_value_set_format_type := 'N';
  		  l_value_set_maximum_size:= 20;
          l_value_set_number_precision:= 0;
          l_segment_display_size := 20;
      elsif('M'=l_input_value.UOM) then
          l_value_set_format_type := 'N';
  		  l_value_set_maximum_size:= 38;
          l_value_set_number_precision:= null;
          l_segment_display_size := 30;
      elsif('N'=l_input_value.UOM) then
          l_value_set_format_type := 'N';
  		  l_value_set_maximum_size:= 38;
          l_value_set_number_precision:= null;
          l_segment_display_size := 30;
      elsif('ND' =l_input_value.UOM) then
          l_value_set_format_type := 'N';
  		  l_value_set_maximum_size:=  38;
          l_value_set_number_precision:= null;
          l_segment_display_size := 30;
      elsif('T'=l_input_value.UOM) then
          l_value_set_format_type := 'I';
  		  l_value_set_maximum_size:=  5;
          l_value_set_number_precision:= null;
          l_segment_display_size := 5;
      end if;
/*
      if( 'C' = l_input_value.UOM OR 'D' = l_input_value.UOM OR  'N' = l_input_value.UOM) then
		l_value_set_format_type := l_input_value.UOM;
	  elsif ('M' = l_input_value.UOM) then
      	l_value_set_format_type := 'N';
      elsif ('I' = l_input_value.UOM) then
		l_value_set_format_type := 'N'; -- For now, converting Integer to Number
      else
		l_value_set_format_type := 't'; -- For now, converting all other Date / Time formats in Input Value to Time format of ValueSet
      end if;
*/
 	if(l_input_value.mandatory_flag = 'Y') then
 		l_required := 'Y';
  	else
	    l_required := 'N';
  	end if;


    if(l_input_value.value_set_id is not null) then
      begin
 		begin
			SELECT
	   		flex_value_set_name,maximum_size into l_value_set_name,l_value_set_maximum_size
        		FROM fnd_flex_value_sets
        		WHERE flex_value_set_id =l_input_value.value_set_id;
        Exception
	 	 	When No_Data_Found Then
	  		RAISE;
	  		When others then
	 		RAISE;
        end;

        if(l_segment_display_size <=  l_value_set_maximum_size) then
              l_segment_display_size:=l_value_set_maximum_size;
		end if ;
        	hr_utility.set_location('Fetched valueset: '||l_value_set_name,31);
			hr_utility.set_location('Creating Segment for InputValue: '||to_char(l_input_value.input_value_id),32);
        	fnd_flex_dsc_api.create_segment(
	 		/* identification */
	  		appl_short_name         => 'BEN',
	  		flexfield_name	  => 'Ben ICD Developer DF',
		    context_name            => to_char(l_element_type.element_type_id),
	  		/* data */
	  		   --vkodedal 7827903 - append string to input value id
  		    name			=> 'ICD_'||l_input_value.input_value_id,
	  		column	        => 'INPUT_VALUE'||i,
	 		description		=> 'INPUT_VALUE'||i,
	  		sequence_number => l_input_value.display_sequence,
	  		enabled			=> 'Y',
	  		displayed		=> 'Y',
	  		/* validation */
	  		value_set		=> l_value_set_name,
	  		default_type	=> '',
	  		default_value	=> '',
	  		required		=> l_required,
	  		security_enabled=> 'N',
	  		/* sizes */
	  		display_size	=> l_segment_display_size,
	  		description_size=> 50,
	  		concatenated_description_size   => 25,
	  		list_of_values_prompt        	=> l_input_value.name,
	  		window_prompt	                => l_input_value.name
			--	range                           => NULL,
			--      srw_parameter                   => NULL
        	);
      end;
    elsif(l_input_value.LOOKUP_TYPE is not null) then
      begin
		l_lookup_value_set_name := create_lookup_valueset(l_input_value.LOOKUP_TYPE,3,l_value_set_format_type);
		hr_utility.set_location('Creating Segment for InputValue: '||to_char(l_input_value.input_value_id),33);
		fnd_flex_dsc_api.create_segment(
		/* identification */
		appl_short_name         => 'BEN',
		flexfield_name		=> 'Ben ICD Developer DF',
		context_name            => to_char(l_element_type.element_type_id),
		/* data */
		   --vkodedal 7827903 - append string to input value id
   		name			=> 'ICD_'||l_input_value.input_value_id,
		column	                => 'INPUT_VALUE'||i,
		description		=> 'INPUT_VALUE'||i,
		sequence_number         => l_input_value.display_sequence,
		enabled			=> 'Y',
		displayed		=> 'Y',
		/* validation */
		value_set		=> l_lookup_value_set_name,
		default_type		=> '',
		default_value		=> '',
		required		=> l_required,
		security_enabled	=> 'N',
		/* sizes */
		display_size		=> 30,
		description_size	=> 50,
		concatenated_description_size   => 25,
		list_of_values_prompt        	=> l_input_value.name,
		window_prompt	                => l_input_value.name
		--	range                           => NULL,
		--  srw_parameter                   => NULL
        );

     end;
  /*this can not be created on element because links may have a different min max and defaults therefore leaving
	this validation for the payroll apis. Still we need to create the proper format for the data type.

   elsif(l_input_value.MIN_VALUE is not null or l_input_value.MAX_VALUE is not null)  then
 	 begin
	l_minmax_value_set_name := create_minmax_valueset(3,l_value_set_format_type,l_input_value.MIN_VALUE,l_input_value.MAX_VALUE);
	hr_utility.set_location('Creating Segment for InputValue: '||to_char(l_input_value.input_value_id),34);
	fnd_flex_dsc_api.create_segment(
	appl_short_name         => 'BEN',
	flexfield_name		=> 'Ben ICD Developer DF',
	context_name            => to_char(l_element_type.element_type_id),
	name			=> to_char(l_input_value.input_value_id),
	column	                => 'INPUT_VALUE'||i,
	description		=> 'INPUT_VALUE'||i,
	sequence_number         => l_input_value.display_sequence,
	enabled			=> 'Y',
	displayed		=> 'Y',
	value_set		=> l_minmax_value_set_name,
	default_type		=> '',
	default_value		=> '',
	required		=> l_required,
	security_enabled	=> 'N',
	display_size		=> 50,
	description_size	=> 50,
	concatenated_description_size   => 25,
	list_of_values_prompt        	=> l_input_value.name,
	window_prompt	                => l_input_value.name
--	range                           => NULL,
--      srw_parameter                   => NULL
        );
      end;
	*/


   else
      begin
	l_dataformat_value_set_name :=
	create_data_format_valueset(l_value_set_format_type,l_value_set_maximum_size,l_value_set_number_precision,l_input_value.UOM);

	hr_utility.set_location('Creating Segment for InputValue: '||to_char(l_input_value.input_value_id),35);
	fnd_flex_dsc_api.create_segment(
	/* identification */
	appl_short_name         => 'BEN',
	flexfield_name			=> 'Ben ICD Developer DF',
	context_name            => to_char(l_element_type.element_type_id),
	/* data */
	   --vkodedal 7827903 - append string to input value id
   	name					=> 'ICD_'||l_input_value.input_value_id,
	column	                => 'INPUT_VALUE'||i,
	description				=> 'INPUT_VALUE'||i,
	sequence_number         => l_input_value.display_sequence,
	enabled					=> 'Y',
	displayed				=> 'Y',
	/* validation */
	value_set				=> l_dataformat_value_set_name,
	default_type			=> '',
	default_value			=> '',
	required				=> l_required,
	security_enabled		=> 'N',
	/* sizes */
	display_size			=> l_segment_display_size,
	description_size		=> 50,
	concatenated_description_size   => 25,
	list_of_values_prompt        	=> l_input_value.name,
	window_prompt	                => l_input_value.name
--	range                           => NULL,
--      srw_parameter                   => NULL
	);
      end;
   end if;

      -- Create a row in SS_CONFIG
	if('Pay Value' = l_input_value.name) then
		l_show_on_overview_flag := 'Y';
	else
		l_show_on_overview_flag := 'N';
	end if;

	if(l_input_value.mandatory_flag = 'Y' or l_input_value.mandatory_flag = 'N') then
		l_user_enterable_flag := 'Y';
	else
		l_user_enterable_flag := 'N';
	end if;

	-- Create the SS CONFIG information for this Input Value

	begin
		select input_value_id into l_input_value_id
		from ben_icd_ss_config
		where input_value_id = l_input_value.input_value_id;
	EXCEPTION
		when no_data_found then
			l_ss_config_exists_flag := false;
	end;

	if(NOT l_ss_config_exists_flag) then
	hr_utility.set_location('Creating Config Information',36);
		insert into ben_icd_ss_config(element_type_id,input_value_id,uom,show_on_overview_flag,user_enterable_flag,input_value_id_char,order_num)
		values(l_element_type_id,l_input_value.input_value_id,l_input_value.uom,l_show_on_overview_flag,l_user_enterable_flag,to_char(l_input_value.input_value_id),i);
	else
	hr_utility.set_location('Updating Config Information',37);
		update ben_icd_ss_config
		set
			uom = l_input_value.uom
			,show_on_overview_flag = l_show_on_overview_flag
			,user_enterable_flag = l_user_enterable_flag
		where input_value_id = l_input_value.input_value_id;
	end if;

      i := i + 1;

    end loop;
    --flag an input value as show on overview if none is flagged by now.
       update ben_icd_ss_config
	    set show_on_overview_flag = 'Y'
		where input_value_id =  l_lowest_seq_input_value_id
		and not exists (select 'Y' from ben_icd_ss_config
		                 where element_type_id = p_element_type_id
						 and show_on_overview_flag = 'Y');
  end;
 end if;
hr_utility.set_location('Leaving: '||l_proc,40);
end CREATE_ICD_CONFIG;

procedure UPDATE_ICD_CONFIG(
	P_ELEMENT_TYPE_ID IN NUMBER,
	P_INPUT_VALUE_ID IN NUMBER,
	P_COLUMN_SEQ_NUM IN NUMBER,
	P_SELF_SERVICE_DISPLAY_PROMPT IN VARCHAR2,
	P_HIDDEN_IN_SELFSERVICE IN VARCHAR2,
	P_USER_ENTERABLE_FLAG IN VARCHAR2,
	P_SHOW_ON_OVERVIEW_FLAG IN VARCHAR2
	) is

cursor c_input_value_segment is
	select *
	from	fnd_descr_flex_column_usages
	where application_id = 805
	and descriptive_flexfield_name = 'Ben ICD Developer DF'
	and descriptive_flex_context_code = to_char(p_element_type_id)
	   --vkodedal 7827903 - append string to input value id
	and end_user_column_name = 'ICD_'||p_input_value_id;

cursor c_value_set_name(p_value_set_id number) is
	select flex_value_set_name
	from fnd_flex_value_sets
	where flex_value_set_id = p_value_set_id;

cursor c_check_show_on_overview(P_ELEMENT_TYPE_ID NUMBER,P_INPUT_VALUE_ID number) is
    select input_value_id from ben_icd_ss_config
	where element_type_id = p_element_type_id
	and show_on_overview_flag = 'Y'
    and input_value_id <> P_INPUT_VALUE_ID;

l_proc varchar2(100) := g_package||'update_icd_config';
l_display fnd_descr_flex_column_usages.display_flag%TYPE;
l_value_set_name fnd_flex_value_sets.flex_value_set_name%TYPE;
l_input_value_segment c_input_value_segment%ROWTYPE;
l_input_value_id number;
begin
hr_utility.set_location('Entering: '||l_proc,10);

  -- test that any other input value has check_on_overview flag checked

   if('Y' = P_SHOW_ON_OVERVIEW_FLAG) then
        open c_check_show_on_overview(P_ELEMENT_TYPE_ID,P_INPUT_VALUE_ID);
        fetch c_check_show_on_overview into l_input_value_id;
        if( c_check_show_on_overview%found) then
           update ben_icd_ss_config
	         set show_on_overview_flag = 'N'
	       where input_value_id = l_input_value_id;
        end if;
        close c_check_show_on_overview;
    end if;

    fnd_flex_dsc_api.set_session_mode('customer_data');

	open c_input_value_segment;
		fetch c_input_value_segment into l_input_value_segment;
	close c_input_value_segment;

	if(P_HIDDEN_IN_SELFSERVICE = 'Y') then
		l_display := 'N';
	else l_display := 'Y';
	end if;

	open c_value_set_name(l_input_value_segment.flex_value_set_id);
		fetch c_value_set_name into l_value_set_name;
	close c_value_set_name;

	hr_utility.set_location('modifying the segment afresh',30);
	-- Create the segment afresh with the new configuration options


  fnd_flex_dsc_api.modify_segment(
   p_appl_short_name  => 'BEN',
   p_flexfield_name   => 'Ben ICD Developer DF',
   p_context_code     => to_char(p_element_type_id),
   --vkodedal 7827903 - append string to input value id
   p_segment_name     => 'ICD_'||p_input_value_id,
  -- p_column_name      => l_input_value_segment.application_column_name,
   p_sequence_number  => P_COLUMN_SEQ_NUM,
   p_displayed        => l_display,
   p_lov_prompt       => P_SELF_SERVICE_DISPLAY_PROMPT ,
   p_window_prompt    => P_SELF_SERVICE_DISPLAY_PROMPT
   );


	hr_utility.set_location('Updating SS Config info',40);
   --	if( 'Y' = p_show_on_overview_flag) then
	 /*check if there is any other checked already then error*/

	update ben_icd_ss_config
	  set user_enterable_flag = p_user_enterable_flag,
	      show_on_overview_flag = p_show_on_overview_flag
	  where input_value_id = p_input_value_id;

hr_utility.set_location('Leaving: '||l_proc,10);
exception
  when others then
  raise;
end UPDATE_ICD_CONFIG;


procedure REFRESH_ICD_CONFIG (
      P_ELEMENT_TYPE_ID IN NUMBER,
      P_EFFECTIVE_DATE IN DATE
      ) is
l_proc varchar2(100) := g_package||'refresh_icd_config';
begin
hr_utility.set_location('Entering: '||l_proc,10);
  -- Refresh is invoked when user has made some changes
  -- to the Element Type definition and wants to
  -- see those changes in ICD too. So, first
  -- delete all the previous ICD specific data
  -- created for Element Type and create them again
hr_utility.set_location('Deleting the existing flex setup of '||to_char(p_element_type_id),20);
	delete_icd_config(p_element_type_id,p_effective_date);

hr_utility.set_location('Creating the flex setup afresh for '||to_char(p_element_type_id),30);
-- Create Icd Config data afresh for the element type
  CREATE_ICD_CONFIG (
      P_ELEMENT_TYPE_ID => p_element_type_id
      ,P_EFFECTIVE_DATE => p_effective_date
      );
hr_utility.set_location('Leaving: '||l_proc,40);
end REFRESH_ICD_CONFIG;

procedure DELETE_ICD_CONFIG (
	 P_ELEMENT_TYPE_ID IN NUMBER,
         P_EFFECTIVE_DATE IN DATE
        ) is
l_proc varchar2(100) := g_package||'delete_icd_config';
begin
hr_utility.set_location('Entering: '||l_proc,10);

	-- Deleting the existing Descriptive Flex information of this Element Type
	hr_utility.set_location('Deleting flex context of: '||to_char(p_element_type_id),20);
	fnd_flex_dsc_api.delete_context(
		appl_short_name  => 'BEN',
		 flexfield_name	  => 'Ben ICD Developer DF',
		 context          => to_char(p_element_type_id));
	hr_utility.set_location('Deleting ss config info of: '||to_char(p_element_type_id),30);
	-- Delete the existing SS Config information
	  delete from ben_icd_ss_config
	  where element_type_id = p_element_type_id;

hr_utility.set_location('Leaving: '||l_proc,40);
end DELETE_ICD_CONFIG;

END BEN_ICD_FLEX_FIELD_SETUP;

/
