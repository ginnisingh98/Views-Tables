--------------------------------------------------------
--  DDL for Package Body PAY_CA_DBI_ROE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_DBI_ROE" as
/* $Header: pycamagd.pkb 120.1 2006/03/28 20:52:11 ssmukher noship $ */

 /*===================================================================+
 |               Copyright (c) 1995 Oracle Corporation                |
 |                  Redwood Shores, California, USA                   |
 |                       All rights reserved.                         |
 +====================================================================+

     Date          Ver      Name                 Description
     ----                   ----                 -----------
     27-AUG-1999    110.0   P. Ganguly         Created.
     23-NOV-1999    110.1   jgoswami           Added function Create_format_item
     29-NOV-1999    110.2   jgoswami           Added code for setting
                                               Update_flag = 'N'
                                               in Create_format_item function
     30-NOV-1999    110.3   jgoswami           Update = 'N' for
                                               ROE_TAX_UNIT_CITY
     17-FEB-2000    115.0   P.Ganguly          Changed the date format for
                                               11i.
     10-APR-2000    115.1   P.Ganguly          Changed the route create
                                               function, it updates if route
                                               already exists (route text).
     14-MAY-2000    115.2   P.Ganguly	       Changed the report_format_item
                                               procedure.
     29-JUN-2000    115.3   P.Ganguly          Corrected the procedure to
                                               create_user_entities, if the
                                               user_entity already exists and
                                               creator_type is 'SEH' then
                                               update it to 'X', else create a
                                               new one with 'X'.
     15-JAN-2004   115.4  P.Ganguly  3353868  Fixed the statement which was
                                               flagged in the 11.5.9 Drop 18
                                               perf Repository.
     29-Mar-2006   115.5  ssmukher   5042797   Fixed the performance issue by
                                               removing the Full table scan
                                               from the cursor query cur_database_item_exists.
                                               Removed the use of UPPER function from the cursor query.
 ====================================================================*/

function create_route(
			p_route_name	varchar2,
			p_description	varchar2,
			p_text		varchar2)  return number is
begin

declare

	cursor cur_route_exists is
	select route_id from ff_routes
	where route_name =  p_route_name;

	cursor cur_ff_routes_s is
	select ff_routes_s.nextval
	from   dual;

	l_route_id		ff_routes.route_id%TYPE;

begin

	open 	cur_route_exists;

	fetch 	cur_route_exists
	into  	l_route_id;

	if cur_route_exists%notfound then

		close cur_route_exists;

	 	open  cur_ff_routes_s;
	 	fetch cur_ff_routes_s
	 	into  l_route_id;
	 	close cur_ff_routes_s;

      		insert into ff_routes
             	(
		route_id,
              	route_name,
              	user_defined_flag,
              	description,
              	text,
              	last_update_date,
              	last_updated_by,
              	last_update_login,
              	created_by,
              	creation_date
		)
        	values
		(l_route_id,
              	p_route_name,
              	'N',
              	p_description,
              	p_text,
              	sysdate,
              	0,
              	0,
              	0,
              	sysdate);

		return l_route_id;
	else

		close cur_route_exists;

		hr_utility.trace(p_route_name || ' route already exists.');
		hr_utility.trace('Updating route .... ' || p_route_name);

		update ff_routes
		set    text = p_text
		where  route_id = l_route_id;

		return l_route_id;

	end if;
end ;
end create_route;

function create_user_entities(
	p_user_entity_name	varchar2,
	p_route_id		number,
	p_notfound_allowed_flag	varchar2,
	p_entity_description	varchar2) return number is
begin
declare

	cursor cur_user_entity_exists is
	select  user_entity_id ,
                creator_type
	from 	ff_user_entities
	where	user_entity_name = p_user_entity_name
	and     legislation_code = 'CA';

	cursor cur_user_entity_id is
	select ff_user_entities_s.nextval
	from dual;

	l_user_entity_id	number;
        l_creator_type		ff_user_entities.creator_type%TYPE;
begin
	open cur_user_entity_exists;
	fetch cur_user_entity_exists
	into  l_user_entity_id,
              l_creator_type;

	if cur_user_entity_exists%found then
	  close cur_user_entity_exists;
          if l_creator_type = 'SEH' then
            update ff_user_entities
            set    creator_type = 'X'
            where  user_entity_id =  l_user_entity_id
            and    creator_type = 'SEH';
          end if;
	  return l_user_entity_id;
	else

	  close cur_user_entity_exists;

	  open 	cur_user_entity_id;
	  fetch cur_user_entity_id
	  into  l_user_entity_id;
	  close cur_user_entity_id;

	  insert into ff_user_entities
          (
	    user_entity_id,
            business_group_id,
            legislation_code,
            route_id,
            notfound_allowed_flag,
            user_entity_name,
            creator_id,
            creator_type,
            entity_description,
            last_update_date,
            last_updated_by,
            last_update_login,
            created_by,
            creation_date
	  )
          values
	  (
	    l_user_entity_id,
            null,
            'CA',
            p_route_id,
            'N',
            p_user_entity_name ,
            0,
            'X',
            p_entity_description,
            sysdate,
            0,
            0,
            0,
            sysdate
	  );
	  return l_user_entity_id;
	end if;

end;
end create_user_entities;


function create_route_parameters(
	p_route_id		number,
	p_parameter_name	varchar2,
	p_sequence_no		number,
	p_data_type		varchar2
	) return number is
begin
declare
	cursor cur_route_parameter_exists is
	select route_parameter_id from ff_route_parameters
	where  route_id= p_route_id
        and    parameter_name = p_parameter_name;

	cursor cur_route_parameters is
	select ff_route_parameters_s.nextval
	from dual;

	l_route_parameter_id	ff_route_parameters.route_parameter_id%TYPE;
begin

	  open  cur_route_parameter_exists;
	  fetch cur_route_parameter_exists
	  into  l_route_parameter_id;

	  if cur_route_parameter_exists%found then

	    close cur_route_parameter_exists;

	  else

	    close cur_route_parameter_exists;

	    open  cur_route_parameters;

	    fetch cur_route_parameters
	    into  l_route_parameter_id;

	    close cur_route_parameters;

            insert into ff_route_parameters
             (route_parameter_id,
              route_id,
              data_type,
              parameter_name,
              sequence_no )
	    values
	      (l_route_parameter_id,
	      p_route_id,
	      p_data_type,
	      p_parameter_name,
	      p_sequence_no );

	  end if;

	  return l_route_parameter_id;

end;

end create_route_parameters;

procedure create_route_parameter_values(p_route_parameter_id  number,
                            p_user_entity_id      number,
                            p_parameter_value     varchar2) is
begin

declare

	cursor cur_route_parameter_values is
	select 'x' from ff_route_parameter_values
	where  route_parameter_id = p_route_parameter_id
	and    user_entity_id    = p_user_entity_id;

	dummy		char(1);

begin
	open cur_route_parameter_values;
        fetch cur_route_parameter_values
        into dummy;

	if cur_route_parameter_values%found then

	   close cur_route_parameter_values;

	else

	  close cur_route_parameter_values;

	  insert into ff_route_parameter_values
	  (
	    route_parameter_id,
	    user_entity_id,
	    value,
	    last_update_date,
	    last_updated_by,
	    last_update_login,
	    created_by,
	    creation_date
	  )
	  values
	  (
	   p_route_parameter_id,
	   p_user_entity_id,
	   p_parameter_value,
	   sysdate,
	   0,
	   0,
	   0,
	   sysdate
	  );

	  end if;

end;

end create_route_parameter_values;

procedure create_route_context(
	p_route_id	number,
	p_context_name	varchar2,
	p_sequence_no	number) is
begin
declare

	cursor cur_context_id is
	select context_id from ff_contexts
	where ltrim(rtrim(context_name)) = ltrim(rtrim(p_context_name));

	l_context_id	ff_contexts.context_id%TYPE;

	cursor cur_route_context_usages is
	select 'x'
	from   ff_route_context_usages
	where  route_id = p_route_id
	and    context_id = l_context_id;

	dummy		char(1);

begin
	open 	cur_context_id;
	fetch 	cur_context_id
	into	l_context_id;
	close 	cur_context_id;

	open cur_route_context_usages;
	fetch cur_route_context_usages
	into  dummy;

	if cur_route_context_usages%found then

	  close cur_route_context_usages;

	else

	  close cur_route_context_usages;
          insert into ff_route_context_usages
          (
	    route_id,
            context_id,
            sequence_no
    	  )
          values
	  (
	    p_route_id,
            l_context_id,
            p_sequence_no
	  );

	end if;

end;

end create_route_context;

function create_database_item(p_user_name             varchar2,
                                p_user_entity_id        number,
                                p_data_type             varchar2,
                                p_definition_text       varchar2,
                                p_null_allowed_flag     varchar2,
                                p_description           varchar2) return number is
begin
declare
	cursor cur_database_item_exists is
	select 'x'
	from   ff_database_items fdi
	where  fdi.user_name = p_user_name;

	dummy	char(1);
	ret	number(1);

begin
      open cur_database_item_exists;

      fetch cur_database_item_exists
      into  dummy;

      if cur_database_item_exists%notfound then


	close cur_database_item_exists;

        insert into ff_database_items(
              user_name,
              user_entity_id,
              data_type,
              definition_text,
              null_allowed_flag,
              description,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
        values (p_user_name,
              p_user_entity_id,
              p_data_type,
              p_definition_text,
              p_null_allowed_flag,
              p_description,
              sysdate,
              0,
              0,
              0,
              sysdate);

	ret := 1;

      else

	close cur_database_item_exists;
	ret := -1;

      end if;

	return ret;

end;

end create_database_item;

function create_format_item(p_user_name             varchar2,
                            p_display_sequence        number) return number is
begin
declare
 start_of_time constant date := to_date('0001/01/01','YYYY/MM/DD');
 end_of_time   constant date := to_date('4712/12/31','YYYY/MM/DD');

 l_user_entity_id		ff_user_entities.user_entity_id%TYPE;
 l_report_type		        pay_report_format_mappings_f.report_type%TYPE;
 l_archive_type			pay_report_format_items_f.archive_type%TYPE;
 l_updatable_flag		pay_report_format_items_f.updatable_flag%TYPE;

  cursor cur_format_item is
  select fue.user_entity_id
  from   ff_user_entities fue
  where  upper(fue.user_entity_name) = upper(p_user_name);

  ret	number := 0;

  cursor cur_format_items_exists is
  select 'x'
  from   pay_report_format_items_f
  where  report_type = 'ROE' and
         report_qualifier = 'ROEQ' and
	 report_category  = 'ROEC' and
	 user_entity_id   = l_user_entity_id and
	 effective_start_date = start_of_time and
	 effective_end_date   = end_of_time;

  dummy		varchar2(1);

begin
      open cur_format_item;
      fetch cur_format_item
      into  l_user_entity_id;

      if cur_format_item%notfound then
        close cur_format_item;
	return -1;
      else

	close cur_format_item;

        if p_user_name in ('ROE_PAYROLL_ID',
		      'ROE_ASSIGNMENT_ID',
		      'ROE_GRE_ID',
		      'PREV_ROE_DATE',
		      'ROE_DATE') then

         l_archive_type := 'AAC';
         l_updatable_flag := Null;

        elsif p_user_name in ( 'ROE_TAX_UNIT_NAME',
  			 'ROE_TAX_UNIT_PROVINCE',
  			 'ROE_TAX_UNIT_POSTAL_CODE',
  			 'ROE_TAX_UNIT_ADDRESS_LINE_1',
  			 'ROE_TAX_UNIT_ADDRESS_LINE_2',
  			 'ROE_TAX_UNIT_ADDRESS_LINE_3',
  			 'ROE_TAX_UNIT_CITY',
  			 'ROE_TAX_UNIT_COUNTRY',
  			 'ROE_CANADA_EMPLOYER_IDENTIFICATION_ORG_BUSINESS_NUMBER',
  			 'ROE_PER_SOCIAL_INSURANCE_NUMBER',
  			 'ROE_PER_FIRST_NAME',
  			 'ROE_PER_LAST_NAME') then

	 l_archive_type := 'AAP';
     	 l_updatable_flag := 'N';

       else

         l_archive_type := 'AAP';
         l_updatable_flag := 'Y';

       end if;

       open cur_format_items_exists;
       fetch cur_format_items_exists into dummy;
       if cur_format_items_exists%found then

	 close cur_format_items_exists;

	 update pay_report_format_items_f
	 set updatable_flag = l_updatable_flag,
	     archive_type = l_archive_type,
	     display_sequence = p_display_sequence
         where
	     report_type = 'ROE' and
	     report_qualifier = 'ROEQ' and
	     report_category = 'ROEC' and
	     user_entity_id = l_user_entity_id and
	     effective_start_date = start_of_time and
	     effective_end_date   = end_of_time;

     	     ret := 1;

             return ret;
      else

        close cur_format_items_exists;

       insert into pay_report_format_items_f
   	(
	report_type,
      	report_qualifier,
      	report_category,
      	user_entity_id,
	effective_start_date,
	effective_end_date,
      	archive_type,
	updatable_flag,
	display_sequence
	)
        values
       (
	'ROE',
	'ROEQ',
	'ROEC',
	l_user_entity_id,
	 start_of_time,
	 end_of_time,
	l_archive_type,
	l_updatable_flag,
        p_display_sequence
	);

      end if;

     ret := 1;

     return ret;

    end if;
end;

end create_format_item;

end pay_ca_dbi_roe;


/
