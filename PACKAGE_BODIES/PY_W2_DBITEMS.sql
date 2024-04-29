--------------------------------------------------------
--  DDL for Package Body PY_W2_DBITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_W2_DBITEMS" as
/* $Header: pymagdbi.pkb 120.0 2005/05/29 06:44:15 appldev noship $ */
 PROCEDURE create_dbi is
  l_text                       long;
  l_tax_unit_context_id        number;
  l_jurisdiction_code_context_id        number;
  l_user_entity_id             number;
  l_context1			number;
  l_context2			number;

  --
  -- ******** local procedure : insert_route_context_usages  ********
  --
  procedure insert_route_context_usages
  (
      p_context_id    in  number,
      p_sequence_no   in  number
  ) is
  begin                       -- [
      hr_utility.set_location('gbstrdbi.insert_route_context_usages', 1);
      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              p_context_id,
              p_sequence_no
      from    dual;
  end insert_route_context_usages;  -- ]
  --
  -- ******** local procedure : insert_user_entity  ********
  --
  procedure insert_user_entity
  (
      p_user_entity_name  in varchar2,
      p_description       in varchar2
  ) is
  begin -- [
      hr_utility.set_location('gbstrdbi.insert_user_entity', 1);
      insert into ff_user_entities
             (user_entity_id,
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
              creation_date)
      --
      values (ff_user_entities_s.nextval,
              null,
              'US',
              ff_routes_s.currval,
              'N',
              p_user_entity_name ,
              0,
              'SEH',               /* SEH */
              p_description,
              sysdate,
              0,
              0,
              0,
              sysdate);
  end insert_user_entity;  -- ]
  --
  -- ******** local procedure : insert_curr_database_item  ********
  --
  procedure insert_curr_database_item
  (
      p_user_name          in varchar2,
      p_definition_text    in varchar2,
      p_description        in varchar2,
      p_data_type          in varchar2,
      p_null_allowed_flag  in varchar2
  ) is
  begin -- [
      hr_utility.set_location('gbstrdbi.insert_curr_database_item', 1);
      hr_utility.trace ('creating : ' || p_user_name);
      insert into ff_database_items (
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
      --
      values (p_user_name,
              ff_user_entities_s.currval,
              p_data_type,
              p_definition_text,
              p_null_allowed_flag,
              p_description,
              sysdate,
              0,
              0,
              0,
              sysdate);
  end insert_curr_database_item;  -- ]

  --
  -- ******** local procedure : insert_database_item  ********
  --
   procedure insert_database_item
  (
      p_user_name          in varchar2,
      p_user_entity_id     in number,
      p_definition_text    in varchar2,
      p_description        in varchar2,
      p_data_type          in varchar2,
      p_null_allowed_flag  in varchar2
  ) is
  begin -- [
      hr_utility.set_location('gbstrdbi.insert_database_item', 1);
      hr_utility.trace ('creating : ' || p_user_name);
      insert into ff_database_items (
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
      --
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
  end insert_database_item;  -- ]
  --
  --
  -- ******** local procedure : insert_route  ********
  --
  procedure insert_route
  (
      p_route_name    in varchar2,
      p_description   in varchar2,
      p_text          in varchar2
  ) is
  begin -- [
      hr_utility.trace ('creating route : ' || p_route_name);
      hr_utility.set_location('gbstrdbi.insert_route', 1);
      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              p_route_name,
              'N',
              p_description,
              p_text,
              sysdate,
              0,
              0,
              0,
              sysdate);
  end insert_route;  -- ]
 --
 ------------------------------ begin -------------------------------
 --
 BEGIN -- [
  --
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --									+
  --	Route for TAX UNIT INFORMATION                                  *
  --									+
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
   select context_id
   into   l_tax_unit_context_id
   from   ff_contexts
  where  context_name = 'TAX_UNIT_ID';

--++   l_text :=
--++   'hr_tax_units_v target
--++    where target.tax_unit_id = B1 ';
   --
--++   insert_route
--++    ('US_TAX_UNIT_INFORMATION',
--++     'Tax unit information',
--++     l_text);
   --
--++   insert_route_context_usages
--++     (l_tax_unit_context_id,1);
   --
--++   insert_user_entity
--++     ('US_TAX_UNIT_INFORMATION',
--++      'Tax unit information');
   --
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   --									+
   --	Database items for TAX UNIT INFORMATION                         *
   --									+
   --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   --
--++   insert_curr_database_item
--++     ('TAX_UNIT_NAME',
--++      'target.name',
--++      'name of tax unit',
--++      'T',
--++      'N');
   --
--++   insert_curr_database_item
--++     ('TAX_UNIT_EMPLOYER_IDENTIFICATION_NUMBER',
--++      'target.employer_identification_number',
--++      'name of tax unit',
--++      'T',
--++      'N');
   --
--++   insert_curr_database_item
--++     ('TAX_UNIT_ADDRESS_LINE_1',
--++      'target.address_line_1',
--++      'address line 1 of tax unit',
--++      'T',
--++      'Y');
   --
--++   insert_curr_database_item
--++     ('TAX_UNIT_ADDRESS_LINE_2',
--++      'target.address_line_2',
--++      'address line 2 of tax unit',
--++      'T',
--++      'Y');
   --
--++   insert_curr_database_item
--++     ('TAX_UNIT_ADDRESS_LINE_3',
--++      'target.address_line_3',
--++      'address line 3 of tax unit',
--++      'T',
--++      'Y');
   --
--++   insert_curr_database_item
--++     ('TAX_UNIT_TOWN_OR_CITY',
--++      'target.town_or_city',
--++      'town or xity of tax unit',
--++      'T',
--++      'Y');
   --
--++   insert_curr_database_item
--++     ('TAX_UNIT_STATE_CODE',
--++      'target.state_code',
--++      'state code of tax unit',
--++      'T',
--++      'Y');
   --
--++   insert_curr_database_item
--++     ('TAX_UNIT_ZIP_CODE',
--++      'target.zip_code',
--++      'zip code of tax unit',
--++      'T',
--++      'Y');
   --
--++   insert_curr_database_item
--++     ('TAX_UNIT_COUNTRY_CODE',
--++      'target.country_code',
--++      'country code of tax unit',
--++      'T',
--++      'Y');

--++    SELECT   user_entity_id
--++    INTO     l_user_entity_id
--++    FROM     ff_user_entities
--++    WHERE    user_entity_name = 'EMPLOYEE_PERSON_ADDRESS_DETAILS';

--++   insert_database_item
--++     ('PER_ADR_COUNTRY_CODE',
--++      l_user_entity_id,
--++      'a.territory_code',
--++      'Person''s country code',
--++      'T',
--++      'Y');



--++   select context_id
--++   into   l_jurisdiction_code_context_id
--++   from   ff_contexts
--++   where  context_name = 'JURISDICTION_CODE';


--++  insert_route
--++  ('SEH_FIPS_CODE_US',
--++   'Derives the fips_code based on Jurisdiction code',
--++   'pay_state_rules rules WHERE substr(rules.jurisdiction_code, 1, 2) = substr(B1, 1, 2)');

--++  insert_route_context_usages
--++  (l_jurisdiction_code_context_id,1);

--++  insert_user_entity
--++  ('SEH_FIPS_CODE_US',
--++   'Derives the fips_code based on Jurisdiction code');

--++  insert_curr_database_item
--++  ('FIPS_CODE_JD',
--++   'rules.fips_code',
--++   'fips code for a specific state',
--++   'N',
--++   'Y');

   select context_id
   into   l_context1
   from   ff_contexts
   where  context_name = 'PAYROLL_ACTION_ID';

   select context_id
   into   l_context2
   from   ff_contexts
   where  context_name = 'TAX_UNIT_ID';

  insert_route
  ('SEH_SQWL_NUM_EMPS_US',
   'Derives the number of employees before you run the report',
   'pay_assignment_actions paa
where  paa.payroll_action_id = B1
and    paa.tax_unit_id       = B2');

  insert_route_context_usages
  (l_context1,1);

  insert_route_context_usages
  (l_context2,2);

  insert_user_entity
  ('SEH_SQWL_NUM_EMPS_US',
  'Number of State Employees for a specific Quarter');

  insert_curr_database_item
  ('SQWL_NUM_EMPS_GRE_PACTID',
  'count(*)',
   'Number of State Employees for a specific Quarter',
   'N',
   'Y');



 END create_dbi; -- ]

PROCEDURE create_archive_route is

  cursor c_check_context(p_route_id number, p_context_id number) is
  select 'Y'
  from ff_route_context_usages frcu
  where route_id = p_route_id
  and   context_id = p_context_id;

  l_text                         long;
  l_tax_unit_context_id          number;
  l_payroll_action_context_id    number;
  l_assignment_action_context_id number;
  l_jurisdiction_context_id      number;
  l_user_entity_id               number;
  l_exists		         VARCHAR2(1);
  l_route_id                     number;

begin      -- [

  -- find the context_ids
     select context_id
     into   l_tax_unit_context_id
     from   ff_contexts
     where  context_name = 'TAX_UNIT_ID';

     select context_id
     into   l_assignment_action_context_id
     from   ff_contexts
     where  context_name = 'ASSIGNMENT_ACTION_ID';

     select context_id
     into   l_payroll_action_context_id
     from   ff_contexts
     where  context_name = 'PAYROLL_ACTION_ID';

     /* For EOY */
     select context_id
     into   l_jurisdiction_context_id
     from   ff_contexts
     where  context_name = 'JURISDICTION_CODE';

   BEGIN

    hr_utility.trace('setting the route text for EMPLOYER_ARCHIVE');

  -- define the employer archive route
     l_text :=
   'ff_archive_item_contexts con2,
    ff_contexts fc2,
    ff_archive_items target
    where target.user_entity_id = &U1
    and target.context1 = to_char(&B1)
			 /* context of payroll action id */
    and fc2.context_name = ''TAX_UNIT_ID''
    and target.archive_item_id = con2.archive_item_id
    and con2.context_id = fc2.context_id
    and ltrim(rtrim(con2.context)) = to_char(&B2)
			/* 2nd context of tax_unit_id */';

    hr_utility.trace('selecting the route_id for EMPLOYER_ARCHIVE');

    select route_id into l_route_id
    from ff_routes where route_name = 'EMPLOYER_ARCHIVE';

    hr_utility.trace('updating the route text for EMPLOYER_ARCHIVE');

    update ff_routes
    set text = l_text
    where route_id = l_route_id;

    hr_utility.trace('deleting ff_route_context_usages for EMPLOYER_ARCHIVE');

    /* delete ff_route_context_usages
    where route_id = l_route_id; */

    open c_check_context(l_route_id,l_tax_unit_context_id);
    fetch c_check_context into l_exists;
    if c_check_context%NOTFOUND then

    hr_utility.trace('inserting ff_route_context_usages for EMPLOYER_ARCHIVE');

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_payroll_action_context_id,
              1);

    hr_utility.trace('inserting ff_route_context_usages for EMPLOYER_ARCHIVE');

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_tax_unit_context_id,
              2 );

    end if;
    close c_check_context;

    EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.trace('inserting ff_routes for EMPLOYER_ARCHIVE');

      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'EMPLOYER_ARCHIVE',
              'N',
              'sql to retrieve GRE based archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
    hr_utility.trace('inserting ff_route_parameters for EMPLOYER_ARCHIVE');

     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1 from dual;

  -- define the route_context usage

    hr_utility.trace('inserting ff_route_context_usages for EMPLOYER_ARCHIVE');

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_payroll_action_context_id,
              1
              from dual;

    hr_utility.trace('inserting ff_route_context_usages for EMPLOYER_ARCHIVE');

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_tax_unit_context_id,
              2
              from dual;

   END;

   BEGIN

  -- define the employer archive route
     l_text :=
   'ff_archive_item_contexts con2,
    ff_contexts fc2,
    ff_archive_items target
    where target.user_entity_id = &U1
    and target.context1 = to_char(&B1)
			  /* context of payroll action id */
    and fc2.context_name = ''TAX_UNIT_ID''
    and target.archive_item_id = con2.archive_item_id
    and con2.context_id = fc2.context_id
    and ltrim(rtrim(con2.context)) = to_char(&B2)
			  /* 2nd context of tax_unit_id */';

    select route_id into l_route_id
    from ff_routes where route_name = 'EMPLOYER_ARCHIVE_DATE';

    update ff_routes
    set text = l_text
    where route_id = l_route_id;

    /* delete ff_route_context_usages
    where route_id = l_route_id; */

    open c_check_context(l_route_id,l_tax_unit_context_id);
    fetch c_check_context into l_exists;
    if c_check_context%NOTFOUND then

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_payroll_action_context_id,
              1);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_tax_unit_context_id,
              2 );
     end if;
    close c_check_context;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'EMPLOYER_ARCHIVE_DATE',
              'N',
              'sql to retrieve GRE based date archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);


  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1 from dual;

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_payroll_action_context_id,
              1
              from dual;

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_tax_unit_context_id,
              2
              from dual;

   END;

   BEGIN

  -- define the employer archive route
     l_text :=
   'ff_archive_item_contexts con2,
    ff_contexts fc2,
    ff_archive_items target
    where target.user_entity_id = &U1
    and target.context1 = to_char(&B1)
							/* context of payroll action id */
    and fc2.context_name = ''TAX_UNIT_ID''
    and target.archive_item_id = con2.archive_item_id
    and con2.context_id = fc2.context_id
    and trim(rtrim(con2.context)) = to_char(&B2)
							/* 2nd context of tax_unit_id */';

    select route_id into l_route_id
    from ff_routes where route_name = 'EMPLOYER_ARCHIVE_NUMBER';

    update ff_routes
    set text = l_text
    where route_id = l_route_id;

    /* delete ff_route_context_usages
    where route_id = l_route_id; */

    open c_check_context(l_route_id,l_tax_unit_context_id);
    fetch c_check_context into l_exists;
    if c_check_context%NOTFOUND then


      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values ( l_route_id,
              l_payroll_action_context_id,
              1);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_tax_unit_context_id,
              2 );
    end if;
    close c_check_context;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN

      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'EMPLOYER_ARCHIVE_NUMBER',
              'N',
              'sql to retrieve GRE based numeric archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);


  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1 from dual;

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_payroll_action_context_id,
              1
              from dual;

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_tax_unit_context_id,
              2
              from dual;

   END;

   BEGIN

  -- define the employer tax unit id archive route
  -- Even though it is employer archive route, it
  -- will accept the context of assignment_action_id and
  -- for the given assignment_action_id , will get the
  -- payroll_action_id. This is being done because the
  -- mag reports will be setting up the assignment_action_id
  -- context as that of year end pre-process but the payroll_
  -- action_id that of the mag report.

    hr_utility.trace('setting route text for EMPLOYER_TAX_UNIT_ARCHIVE_DATE');

     l_text :=
   'ff_archive_item_contexts con2,
    ff_contexts fc2,
    ff_archive_items target
    where target.context1 = &B1
		 /* context of payroll_action_id */
    and target.user_entity_id = &U1
    and fc2.context_name = ''TAX_UNIT_ID''
    and con2.archive_item_id = target.archive_item_id
    and con2.context_id = fc2.context_id
    and ltrim(rtrim(con2.context)) = to_char(&B2)
                 /* 2nd context of tax_unit_id */';

    hr_utility.trace('selecting route id for EMPLOYER_TAX_UNIT_ARCHIVE_DATE');

    select route_id into l_route_id
    from ff_routes where route_name = 'EMPLOYER_TAX_UNIT_ARCHIVE_DATE';

    hr_utility.trace('updating ff_routes for EMPLOYER_TAX_UNIT_ARCHIVE_DATE');

    update ff_routes
    set text = l_text
    where route_id = l_route_id;

    hr_utility.trace('deleting ff_routes for EMPLOYER_TAX_UNIT_ARCHIVE_DATE');

    /* delete ff_route_context_usages
    where route_id = l_route_id; */

    open c_check_context(l_route_id,l_tax_unit_context_id);
    fetch c_check_context into l_exists;
    if c_check_context%NOTFOUND then

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_payroll_action_context_id,
              1);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_tax_unit_context_id,
              2 );
    end if;
    close c_check_context;

    EXCEPTION WHEN NO_DATA_FOUND THEN
      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'EMPLOYER_TAX_UNIT_ARCHIVE_DATE',
              'N',
              'sql to retrieve GRE based employer archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1 from dual;

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_payroll_action_context_id,
              1
              from dual;

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_tax_unit_context_id,
              2
              from dual;

   END;


   BEGIN

  -- define the employer tax unit id archive route
  -- Even though it is employer archive route, it
  -- will accept the context of assignment_action_id and
  -- for the given assignment_action_id , will get the
  -- payroll_action_id. This is being done because the
  -- mag reports will be setting up the assignment_action_id
  -- context as that of year end pre-process but the payroll_
  -- action_id that of the mag report.

    hr_utility.trace('setting route text for EMPLOYER_TAX_UNIT_ARCHIVE_NUMBER');

     l_text :=
   'ff_archive_item_contexts con2,
    ff_contexts fc2,
    ff_archive_items target
    where target.context1 = &B1
                /* context of payroll_action_id */
    and target.user_entity_id = &U1
    and fc2.context_name = ''TAX_UNIT_ID''
    and con2.archive_item_id = target.archive_item_id
    and con2.context_id = fc2.context_id
    and ltrim(rtrim(con2.context)) = to_char(&B2)
                /* 2nd context of tax_unit_id */';

    hr_utility.trace('selecting route_id for EMPLOYER_TAX_UNIT_ARCHIVE_NUMBER');

    select route_id into l_route_id
    from ff_routes where route_name = 'EMPLOYER_TAX_UNIT_ARCHIVE_NUMBER';

    hr_utility.trace('updating route_text for EMPLOYER_TAX_UNIT_ARCHIVE_NUMBER');


    update ff_routes
    set text = l_text
    where route_id = l_route_id;

    hr_utility.trace('deleting ff_route_context_usages for EMPLOYER_TAX_UNIT_ARCHIVE_NUMBER');

    /* delete ff_route_context_usages
    where route_id = l_route_id; */

    open c_check_context(l_route_id,l_tax_unit_context_id);
    fetch c_check_context into l_exists;
    if c_check_context%NOTFOUND then


    hr_utility.trace('inserting ff_route_context_usages for EMPLOYER_TAX_UNIT_ARCHIVE_NUMBER');

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_payroll_action_context_id,
              1);

    hr_utility.trace('inserting ff_route_context_usages for EMPLOYER_TAX_UNIT_ARCHIVE_NUMBER');

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_tax_unit_context_id,
              2 );
    end if;
    close c_check_context;


    EXCEPTION WHEN NO_DATA_FOUND THEN
    hr_utility.trace('inserting ff_routes for EMPLOYER_TAX_UNIT_ARCHIVE_NUMBER');

      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'EMPLOYER_TAX_UNIT_ARCHIVE_NUMBER',
              'N',
              'sql to retrieve GRE based employer archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1 from dual;

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_payroll_action_context_id,
              1
              from dual;

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_tax_unit_context_id,
              2
              from dual;

   END;

   BEGIN

  -- define the employer tax unit id archive route
  -- Even though it is employer archive route, it
  -- will accept the context of assignment_action_id and
  -- for the given assignment_action_id , will get the
  -- payroll_action_id. This is being done because the
  -- mag reports will be setting up the assignment_action_id
  -- context as that of year end pre-process but the payroll_
  -- action_id that of the mag report.

    hr_utility.trace('setting route text for EMPLOYER_TAX_UNIT_ARCHIVE');

     l_text :=
   'ff_archive_item_contexts con2,
    ff_contexts fc2,
    ff_archive_items target
    where target.context1 = &B1
	     /* context of payroll_action_id */
    and target.user_entity_id = &U1
    and fc2.context_name = ''TAX_UNIT_ID''
    and con2.archive_item_id = target.archive_item_id
    and con2.context_id = fc2.context_id
    and ltrim(rtrim(con2.context)) = to_char(&B2)
             /* 2nd context of tax_unit_id */';

    hr_utility.trace('selecting route_id for EMPLOYER_TAX_UNIT_ARCHIVE');

    select route_id into l_route_id
    from ff_routes where route_name = 'EMPLOYER_TAX_UNIT_ARCHIVE';

    hr_utility.trace('updating route_text for EMPLOYER_TAX_UNIT_ARCHIVE');

    update ff_routes
    set text = l_text
    where route_id = l_route_id;

    hr_utility.trace('deleting ff_route_context_usages for EMPLOYER_TAX_UNIT_ARCHIVE');

    /* delete ff_route_context_usages
    where route_id = l_route_id; */

    hr_utility.trace('inserting ff_route_context_usages for EMPLOYER_TAX_UNIT_ARCHIVE');
    open c_check_context(l_route_id,l_tax_unit_context_id);
    fetch c_check_context into l_exists;
    if c_check_context%NOTFOUND then


      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_payroll_action_context_id,
              1);

    hr_utility.trace('inserting ff_route_context_usages for EMPLOYER_TAX_UNIT_ARCHIVE');

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_tax_unit_context_id,
              2 );
    end if;
    close c_check_context;


    EXCEPTION WHEN NO_DATA_FOUND THEN
      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'EMPLOYER_TAX_UNIT_ARCHIVE',
              'N',
              'sql to retrieve GRE based employer archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1 from dual;

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_payroll_action_context_id,
              1
              from dual;

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_tax_unit_context_id,
              2
              from dual;

   END;


   BEGIN

  -- define the employer jurisdiction code archive route
  -- Even though it is employer archive route, it
  -- will accept the context of assignment_action_id and
  -- for the given assignment_action_id , will get the
  -- payroll_action_id. This is being done because the
  -- mag reports will be setting up the assignment_action_id
  -- context as that of year end pre-process but the payroll_
  -- action_id that of the mag report.

     l_text :=
   'ff_archive_item_contexts con3,
    ff_archive_item_contexts con2,
    ff_contexts fc3,
    ff_contexts fc2,
    ff_archive_items target
    where target.context1 = &B1
			 /* context of payroll_action_id */
    and target.user_entity_id = &U1
    and fc2.context_name = ''TAX_UNIT_ID''
    and con2.archive_item_id = target.archive_item_id
    and con2.context_id = fc2.context_id
    and ltrim(rtrim(con2.context)) = to_char(&B2)
                                 /* 2nd context of tax_unit_id */
    and fc3.context_name = ''JURISDICTION_CODE''
    and con3.archive_item_id = target.archive_item_id
    and con3.context_id = fc3.context_id
    and substr(ltrim(rtrim(con3.context)),1,&U2) = substr(&B3,1,&U2)
                                 /* 3rd context of jurisdiction code */';

    select route_id into l_route_id
    from ff_routes where route_name = 'EMPLOYER_JURSD_ARCHIVE';

    update ff_routes
    set text = l_text
    where route_id = l_route_id;

    /* delete ff_route_context_usages
     where route_id = l_route_id; */

    open c_check_context(l_route_id,l_tax_unit_context_id);
    fetch c_check_context into l_exists;
    if c_check_context%NOTFOUND then


      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values  (l_route_id,
              l_payroll_action_context_id,
              1);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_tax_unit_context_id,
              2);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_jurisdiction_context_id,
              3 );
    end if;
    close c_check_context;


    EXCEPTION WHEN NO_DATA_FOUND THEN
      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'EMPLOYER_JURSD_ARCHIVE',
              'N',
              'sql to retrieve GRE based employer archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1 from dual;

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_payroll_action_context_id,
              1
              from dual;

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_tax_unit_context_id,
              2
              from dual;

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_jurisdiction_context_id,
              3
              from dual;
   END;


   BEGIN

  -- define the employer jurisdiction code archive route
  -- Even though it is employer archive route, it
  -- will accept the context of assignment_action_id and
  -- for the given assignment_action_id , will get the
  -- payroll_action_id. This is being done because the
  -- mag reports will be setting up the assignment_action_id
  -- context as that of year end pre-process but the payroll_
  -- action_id that of the mag report.

     l_text :=
   'ff_archive_item_contexts con3,
    ff_archive_item_contexts con2,
    ff_contexts fc3,
    ff_contexts fc2,
    ff_archive_items target
    where target.context1 = &B1
				 /* context of payroll_action_id */
    and target.user_entity_id = &U1
    and fc2.context_name = ''TAX_UNIT_ID''
    and con2.archive_item_id = target.archive_item_id
    and con2.context_id = fc2.context_id
    and ltrim(rtrim(con2.context)) = to_char(&B2)
                                 /* 2nd context of tax_unit_id */
    and fc3.context_name = ''JURISDICTION_CODE''
    and con3.archive_item_id = target.archive_item_id
    and con3.context_id = fc3.context_id
    and substr(ltrim(rtrim(con3.context)),1,&U2) = substr(&B3,1,&U2)
                                 /* 3rd context of jurisdiction code */';

    select route_id into l_route_id
    from ff_routes where route_name = 'EMPLOYER_JURSD_ARCHIVE_DATE';

    update ff_routes
    set text = l_text
    where route_id = l_route_id;

    /* delete ff_route_context_usages
    where route_id = l_route_id; */

    open c_check_context(l_route_id,l_tax_unit_context_id);
    fetch c_check_context into l_exists;
    if c_check_context%NOTFOUND then


      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_payroll_action_context_id,
              1);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_tax_unit_context_id,
              2);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_jurisdiction_context_id,
              3 );
    end if;
    close c_check_context;


    EXCEPTION WHEN NO_DATA_FOUND THEN
      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'EMPLOYER_JURSD_ARCHIVE_DATE',
              'N',
              'sql to retrieve GRE based employer archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1 from dual;

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_payroll_action_context_id,
              1
              from dual;

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_tax_unit_context_id,
              2
              from dual;

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_jurisdiction_context_id,
              3
              from dual;
   END;


   BEGIN

  -- define the employer jurisdiction code archive route
  -- Even though it is employer archive route, it
  -- will accept the context of assignment_action_id and
  -- for the given assignment_action_id , will get the
  -- payroll_action_id. This is being done because the
  -- mag reports will be setting up the assignment_action_id
  -- context as that of year end pre-process but the payroll_
  -- action_id that of the mag report.

     l_text :=
   'ff_archive_item_contexts con3,
    ff_archive_item_contexts con2,
    ff_contexts fc3,
    ff_contexts fc2,
    ff_archive_items target
    where target.context1 = &B1
		/* context of payroll_action_id */
    and target.user_entity_id = &U1
    and fc2.context_name = ''TAX_UNIT_ID''
    and con2.archive_item_id = target.archive_item_id
    and con2.context_id = fc2.context_id
    and ltrim(rtrim(con2.context)) = to_char(&B2)
                                 /* 2nd context of tax_unit_id */
    and fc3.context_name = ''JURISDICTION_CODE''
    and con3.archive_item_id = target.archive_item_id
    and con3.context_id = fc3.context_id
    and substr(ltrim(rtrim(con3.context)),1,&U2) = substr(&B3,1,&U2)
                                 /* 3rd context of jurisdiction code */';

    select route_id into l_route_id
    from ff_routes where route_name = 'EMPLOYER_JURSD_ARCHIVE_NUMBER';

    update ff_routes
    set text = l_text
    where route_id = l_route_id;

    /* delete ff_route_context_usages
    where route_id = l_route_id; */

    open c_check_context(l_route_id,l_tax_unit_context_id);
    fetch c_check_context into l_exists;
    if c_check_context%NOTFOUND then


      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_payroll_action_context_id,
              1);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_tax_unit_context_id,
              2);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (l_route_id,
              l_jurisdiction_context_id,
              3 );
    end if;
    close c_check_context;


    EXCEPTION WHEN NO_DATA_FOUND THEN
      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'EMPLOYER_JURSD_ARCHIVE_NUMBER',
              'N',
              'sql to retrieve GRE based employer archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1 from dual;

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_payroll_action_context_id,
              1
              from dual;

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_tax_unit_context_id,
              2
              from dual;

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_jurisdiction_context_id,
              3
              from dual;
   END;

   BEGIN

  -- define the assignment archive route
     l_text :=
   'ff_archive_items target
    where target.user_entity_id = &U1
    and target.context1 = to_char(&B1)
	     /* context of assignment action id */';

    select route_id into l_route_id
    from ff_routes where route_name = 'ASSIGNMENT_ARCHIVE';

    update ff_routes
    set text = l_text
    where route_id = l_route_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'ASSIGNMENT_ARCHIVE',
              'N',
              'sql to retrieve Assignment based archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1 from dual;

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_assignment_action_context_id,
              1
              from dual;

   END;

   BEGIN

   -- define the assignment archive route
     l_text :=
   'ff_archive_items target
    where target.user_entity_id = &U1
    and target.context1 = to_char(&B1)
					  /* context of assignment action id */';

    select route_id into l_route_id
    from ff_routes where route_name = 'ASSIGNMENT_ARCHIVE_DATE';

    update ff_routes
    set text = l_text
    where route_id = l_route_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'ASSIGNMENT_ARCHIVE_DATE',
              'N',
              'sql to retrieve Assignment based archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1 from dual;

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_assignment_action_context_id,
              1
              from dual;

   END;

   BEGIN

   -- define the assignment archive route
     l_text :=
   'ff_archive_items target
    where target.user_entity_id = &U1
    and target.context1 = to_char(&B1)
					 /* context of assignment action id */';

    select route_id into l_route_id
    from ff_routes where route_name = 'ASSIGNMENT_ARCHIVE_NUMBER';

    update ff_routes
    set text = l_text
    where route_id = l_route_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'ASSIGNMENT_ARCHIVE_NUMBER', 'N',
              'sql to retrieve Assignment based archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1 from dual;

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  ff_routes_s.currval,
              l_assignment_action_context_id,
              1
              from dual;
   END;

   /* For EOY */

   BEGIN

     /* Define the archive route for the db item having
        assignment action id and tax unit id (GRE) as
        contexts. */

     l_text :=
       'ff_archive_item_contexts con2,
        ff_contexts fc2,
        ff_archive_items target
        where target.user_entity_id = &U1
        and target.context1 = to_char(&B1)
	     /* context assignment action id */
        and fc2.context_name = ''TAX_UNIT_ID''
        and con2.archive_item_id = target.archive_item_id
        and con2.context_id = fc2.context_id
        and ltrim(rtrim(con2.context)) = to_char(&B2)
	     /* 2nd context of tax_unit_id */';

     select route_id into l_route_id
     from ff_routes where route_name = 'ASSIGNMENT_GRE_ARCHIVE';

     update ff_routes
     set text = l_text
     where route_id = l_route_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'ASSIGNMENT_GRE_ARCHIVE',
              'N',
              'sql to retrieve Assignment and GRE based archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      values (ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1);

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_assignment_action_context_id,
              1);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_tax_unit_context_id,
              2);

   END;

   /* For EOY */


   BEGIN

     /* Define the archive route for the db item having
        assignment action id and jurisdiction code as
        contexts. */

     l_text :=
       'ff_archive_item_contexts con2,
        ff_contexts fc2,
        ff_archive_items target
        where target.user_entity_id = &U1
        and target.context1 = to_char(&B1)
		/* context assignment action id */
        and fc2.context_name = ''JURISDICTION_CODE''
        and con2.archive_item_id = target.archive_item_id
        and con2.context_id = fc2.context_id
        and substr(con2.context,1,&U2) = substr(&B2,1,&U2)
                  /* 2nd context of jurisdiction code */';

     select route_id into l_route_id
     from ff_routes where route_name = 'ASSIGNMENT_JD_ARCHIVE';

     update ff_routes
     set text = l_text
     where route_id = l_route_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'ASSIGNMENT_JD_ARCHIVE',
              'N',
              'sql to retrieve Assignment and JD based archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      values (ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1);

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_assignment_action_context_id,
              1);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_jurisdiction_context_id,
              2);

   END;
   /* For EOY */

   BEGIN

     /* Define the archive route for the db item having
        assignment action id, tax unit id (GRE) and
        city jurisdiction code as contexts. */

     l_text :=
       'ff_archive_item_contexts con3,
        ff_archive_item_contexts con2,
        ff_contexts fc3,
        ff_contexts fc2,
        ff_archive_items target
        where target.user_entity_id = &U1
        and target.context1 = to_char(&B1)
		/* context assignment action id */
        and fc2.context_name = ''TAX_UNIT_ID''
        and con2.archive_item_id = target.archive_item_id
        and con2.context_id = fc2.context_id
        and ltrim(rtrim(con2.context)) = to_char(&B2)
		/* 2nd context of tax_unit_id */
        and fc3.context_name = ''JURISDICTION_CODE''
        and con3.archive_item_id = target.archive_item_id
        and con3.context_id = fc3.context_id
        and ltrim(rtrim(con3.context)) = &B3
		/* 3rd context of city jurisdiction_code*/';

     select route_id into l_route_id
     from ff_routes where route_name = 'ASSIGNMENT_GRE_CITY_JD_ARCHIVE';

     update ff_routes
     set text = l_text
     where route_id = l_route_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'ASSIGNMENT_GRE_CITY_JD_ARCHIVE',
              'N',
              'sql to retrieve Assignment,GRE and city JD based archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      values (ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1);

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_assignment_action_context_id,
              1);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_tax_unit_context_id,
              2);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_jurisdiction_context_id,
              3);


   END;

   BEGIN

     /* Define the archive route for the db item having
        assignment action id, tax unit id (GRE) and
        county jurisdiction code as contexts. */

     l_text :=
       'ff_archive_item_contexts con3,
        ff_archive_item_contexts con2,
        ff_contexts fc3,
        ff_contexts fc2,
        ff_archive_items target
        where target.user_entity_id = &U1
        and target.context1 = to_char(&B1)
		/* context assignment action id */
        and fc2.context_name = ''TAX_UNIT_ID''
        and con2.archive_item_id = target.archive_item_id
        and con2.context_id = fc2.context_id
        and ltrim(rtrim(con2.context)) = to_char(&B2)
		/* 2nd context of tax_unit_id */
        and fc3.context_name = ''JURISDICTION_CODE''
        and con3.archive_item_id = target.archive_item_id
        and con3.context_id = fc3.context_id
        and substr(con3.context,1,6) = substr(&B3,1,6)
                /* 3rd context of county jurisdiction_code*/';

     select route_id into l_route_id
     from ff_routes where route_name = 'ASSIGNMENT_GRE_COUNTY_JD_ARCHIVE';

     update ff_routes
     set text = l_text
     where route_id = l_route_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'ASSIGNMENT_GRE_COUNTY_JD_ARCHIVE',
              'N',
              'sql to retrieve Assignment,GRE and county JD based archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      values (ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1);

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_assignment_action_context_id,
              1);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_tax_unit_context_id,
              2);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_jurisdiction_context_id,
              3);

   END;

   BEGIN

     /* Define the archive route for the db item having
        assignment action id, tax unit id (GRE) and
        state jurisdiction code as contexts. */

     l_text :=
       'ff_archive_item_contexts con3,
        ff_archive_item_contexts con2,
        ff_contexts fc3,
        ff_contexts fc2,
        ff_archive_items target
        where target.user_entity_id = &U1
        and target.context1 = to_char(&B1)
		/* context assignment action id */
        and fc2.context_name = ''TAX_UNIT_ID''
        and con2.archive_item_id = target.archive_item_id
        and con2.context_id = fc2.context_id
        and ltrim(rtrim(con2.context)) = to_char(&B2)
		/* 2nd context of tax_unit_id */
        and fc3.context_name = ''JURISDICTION_CODE''
        and con3.archive_item_id = target.archive_item_id
        and con3.context_id = fc3.context_id
        and substr(con3.context,1,2) = substr(&B3,1,2)
               /* 3rd context of state jurisdiction_code*/';

     select route_id into l_route_id
     from ff_routes where route_name = 'ASSIGNMENT_GRE_STATE_JD_ARCHIVE';

     update ff_routes
     set text = l_text
     where route_id = l_route_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'ASSIGNMENT_GRE_STATE_JD_ARCHIVE',
              'N',
              'sql to retrieve Assignment,GRE and state JD based archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      values (ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1);

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_assignment_action_context_id,
              1);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_tax_unit_context_id,
              2);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_jurisdiction_context_id,
              3);

   END;

   BEGIN

     /* Define the archive route for the db item having
        assignment action id, tax unit id (GRE) and
        school district jurisdiction code as contexts. */

     l_text :=
       'ff_archive_item_contexts con3,
        ff_archive_item_contexts con2,
        ff_contexts fc3,
        ff_contexts fc2,
        ff_archive_items target
        where target.user_entity_id = &U1
        and target.context1 = to_char(&B1)
                 /* context assignment action id */
        and fc2.context_name = ''TAX_UNIT_ID''
        and con2.archive_item_id = target.archive_item_id
        and con2.context_id = fc2.context_id
        and ltrim(rtrim(con2.context)) = to_char(&B2)
		/* 2nd context of tax_unit_id */
        and fc3.context_name = ''JURISDICTION_CODE''
        and con3.archive_item_id = target.archive_item_id
        and con3.context_id = fc3.context_id
        and substr(con3.context,1,8) = substr(&B3,1,8)
                 /* 3rd context of scholl jurisdiction_code*/';

     select route_id into l_route_id
     from ff_routes where route_name = 'ASSIGNMENT_GRE_SCHOOL_JD_ARCHIVE';

     update ff_routes
     set text = l_text
     where route_id = l_route_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

      insert into ff_routes
             (route_id,
              route_name,
              user_defined_flag,
              description,
              text,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      values (ff_routes_s.nextval,
              'ASSIGNMENT_GRE_SCHOOL_JD_ARCHIVE',
              'N',
              'sql to retrieve Assignment,GRE and school JD based archived items',
              l_text,
              sysdate,
              0,
              0,
              0,
              sysdate);

  -- define the route_parameter
     insert into ff_route_parameters
             (ROUTE_PARAMETER_ID,
              ROUTE_ID,
              DATA_TYPE,
              PARAMETER_NAME,
              SEQUENCE_NO )
      values (ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1);

  -- define the route_context usage

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_assignment_action_context_id,
              1);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_tax_unit_context_id,
              2);

      insert into ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      values (ff_routes_s.currval,
              l_jurisdiction_context_id,
              3);


   END;

 end create_archive_route;       -- ]


PROCEDURE create_archive_dbi ( p_item_name VARCHAR2 ) is
-- find the attributes from the live database item and create an
-- arcive version of it
  l_dbi_null_allowed_flag      		VARCHAR2(1);
  l_dbi_description             	VARCHAR2(240);
  l_dbi_data_type              		VARCHAR2(1);
  l_ue_notfound_allowed_flag    	VARCHAR2(1);
  l_ue_creator_type             	VARCHAR2(30);
  l_ue_entity_description       	VARCHAR2(240);
  l_user_entity_seq             	NUMBER;
  l_user_entity_id              	NUMBER;
  l_route_parameter_id          	NUMBER;
  l_route_id                    	NUMBER;
  l_live_route_id                    	NUMBER;
  l_er_archive_route_id   		NUMBER;
  l_er_archive_date_route_id   		NUMBER;
  l_er_archive_number_route_id   	NUMBER;
  l_ass_archive_route_id 		NUMBER;
  l_ass_archive_date_route_id 		NUMBER;
  l_ass_archive_number_route_id 	NUMBER;
  l_asg_count                   	NUMBER;
  l_definition_text             	VARCHAR2(240);

begin      -- [
begin -- [
  select ue.notfound_allowed_flag,
         ue.creator_type,
         ue.entity_description,
         ue.route_id,
         dbi.null_allowed_flag,
         dbi.description ,
         dbi.data_type
         into l_ue_notfound_allowed_flag,
         l_ue_creator_type,
         l_ue_entity_description,
         l_live_route_id,
         l_dbi_null_allowed_flag,
         l_dbi_description,
         l_dbi_data_type
         from ff_database_items dbi,
              ff_user_entities ue
         where dbi.user_name = SUBSTR(p_item_name,3,LENGTH(p_item_name)-2)
         and dbi.user_entity_id = ue.user_entity_id;
     --    and ue.business_group_id is null;
end; -- ]
--
 select count(1) into l_asg_count from ff_route_context_usages rc,
                      ff_contexts c
        where rc.context_id = c.context_id
        and rc.route_id = l_live_route_id
        and context_name like 'ASSIGNMENT%';

 select ff_user_entities_s.nextval into l_user_entity_seq
        from dual;


 select route_id into l_er_archive_route_id
        from ff_routes where
        route_name = 'EMPLOYER_ARCHIVE';

 select route_id into l_er_archive_date_route_id
        from ff_routes where
        route_name = 'EMPLOYER_ARCHIVE_DATE';

 select route_id into l_er_archive_number_route_id
        from ff_routes where
        route_name = 'EMPLOYER_ARCHIVE_NUMBER';

 select route_id into l_ass_archive_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_ARCHIVE';

 select route_id into l_ass_archive_date_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_ARCHIVE_DATE';

 select route_id into l_ass_archive_number_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_ARCHIVE_NUMBER';

if l_dbi_data_type = 'N' then
   l_definition_text := 'fnd_number.canonical_to_number(target.value)';
   	if l_asg_count = 0 then
	   l_route_id := l_er_archive_number_route_id;
        else l_route_id := l_ass_archive_number_route_id;
        end if;
   elsif l_dbi_data_type = 'D' then
           l_definition_text := 'fnd_date.canonical_to_date(target.value)';
   	if l_asg_count = 0 then
           l_route_id := l_er_archive_date_route_id;
        else l_route_id := l_ass_archive_date_route_id;
        end if;
   else l_definition_text := 'target.value';
   	if l_asg_count = 0 then
           l_route_id := l_er_archive_route_id;
        else l_route_id := l_ass_archive_route_id;
        end if;
   end if;

 select ROUTE_PARAMETER_ID into l_route_parameter_id
        from ff_route_parameters
        where parameter_name = 'User Entity ID'
        and route_id = l_route_id;

 insert into ff_user_entities
             (user_entity_id,
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
              creation_date)
      values( l_user_entity_seq,              /* user_entity_id */
              null,			     /* business_group_id */
              'US',			     /* legislation_code */
              l_route_id,		     /* route_id */
              l_ue_notfound_allowed_flag,    /* notfound_allowed_flag */
              p_item_name,		     /* user_entity_name */
              0,			     /* creator_id */
              'X',               	     /* archive extract creator_type */
	      substr('Archive of '||l_ue_creator_type||' entity '||
              l_ue_entity_description,1,240),/* entity_description */
              sysdate,			     /* last_update_date */
              0,			     /* last_updated_by */
              0,			     /* last_update_login */
              0,			     /* created_by */
              sysdate);          	     /* creation_date */

        insert into ff_route_parameter_values (
              route_parameter_id,
              user_entity_id,
              value,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
      --
      values( l_route_parameter_id,
              l_user_entity_seq,
              l_user_entity_seq,
              sysdate,
              0,
              0,
              0,
              sysdate);

        insert into ff_database_items (
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
      --
      values( p_item_name,
              l_user_entity_seq,
              l_dbi_data_type,
              l_definition_text,
              l_dbi_null_allowed_flag,
              substr('Archive of item '||l_dbi_description,1,240),
              sysdate,
              0,
              0,
              0,
              sysdate);

 end create_archive_dbi;       -- ]


PROCEDURE create_eoy_archive_dbi ( p_item_name VARCHAR2 ) is

 /* Find the attributes from the live database item and create an
    archive version of it. */

  l_dbi_null_allowed_flag      		VARCHAR2(1);
  l_dbi_description             	VARCHAR2(240);
  l_dbi_data_type              		VARCHAR2(1);
  l_ue_notfound_allowed_flag    	VARCHAR2(1);
  l_ue_creator_type             	VARCHAR2(30);
  l_ue_entity_description       	VARCHAR2(240);
  l_user_entity_seq             	NUMBER;
  l_user_entity_id              	NUMBER;
  l_route_parameter_id          	NUMBER;
  l_route_id                    	NUMBER;
  l_exist_route_id                    	NUMBER;
  l_live_route_id                    	NUMBER;
  l_er_archive_route_id   		NUMBER;
  l_er_archive_date_route_id   		NUMBER;
  l_er_archive_number_route_id   	NUMBER;
  l_ass_archive_route_id 		NUMBER;
  l_ass_archive_date_route_id 		NUMBER;
  l_ass_archive_number_route_id 	NUMBER;
  l_asg_count                   	NUMBER;
  l_definition_text             	VARCHAR2(240);
  l_context_name                        VARCHAR2(240);
  l_context_id                          NUMBER;
  l_sequence_no                         NUMBER;
  l_count                               NUMBER := 0;
  lt_context_name                       char240_data_type_table;
  lt_context_id                         numeric_data_type_table;
  lt_sequence_no                        numeric_data_type_table;
  l_ass_gre_archive_route_id            NUMBER;
  l_ass_jd_archive_route_id            NUMBER;
  l_ass_gre_jd_archive_route_id         NUMBER;
  l_ass_gre_ct_jd_arch_route_id         NUMBER;
  l_ass_gre_cn_jd_arch_route_id         NUMBER;
  l_ass_gre_st_jd_arch_route_id         NUMBER;
  l_ass_gre_sd_jd_arch_route_id         NUMBER;
  l_found_asg_action                    BOOLEAN := FALSE;
  l_found_tax_unit                      BOOLEAN := FALSE;
  l_found_jursd                         BOOLEAN := FALSE;
  l_live_bal_db_id                      number;
  l_jursd_level                         number;
  l_er_tax_unit_arch_rid                number;
  l_er_tax_unit_arch_date_rid           number;
  l_er_tax_unit_arch_number_rid         number;
  l_er_jursd_arch_rid                number;
  l_er_jursd_arch_date_rid           number;
  l_er_jursd_arch_number_rid         number;

  cursor get_live_db_details is
  select ue.notfound_allowed_flag,
         ue.creator_type,
         ue.entity_description,
         ue.route_id,
         dbi.null_allowed_flag,
         dbi.description ,
         dbi.data_type
         from ff_database_items dbi,
              ff_user_entities ue
         where dbi.user_name = SUBSTR(p_item_name,3,LENGTH(p_item_name)-2)
         and dbi.user_entity_id = ue.user_entity_id;

  cursor get_context is
  select c.context_name,
         rc.context_id,
         rc.sequence_no
         from ff_route_context_usages rc,
         ff_contexts c
         where rc.context_id = c.context_id
         and rc.route_id= l_live_route_id
         order by 3;

  cursor get_user_entity is
         select user_entity_id,
                route_id
         from ff_user_entities
         where user_entity_name = p_item_name;

  cursor csr_get_jursd_level (p_defined_balance_id number) is
         select jurisdiction_level
         from pay_balance_types pbt,
              pay_defined_balances pdb
         where pbt.balance_type_id = pdb.balance_type_id
         and   pdb.defined_balance_id = p_defined_balance_id;

  begin

--        hr_utility.trace_on(null,'ORACLE');

        hr_utility.trace('getting route ids');

 	select route_id into l_er_archive_route_id
        from ff_routes where
        route_name = 'EMPLOYER_ARCHIVE';

 	select route_id into l_er_archive_date_route_id
        from ff_routes where
        route_name = 'EMPLOYER_ARCHIVE_DATE';

 	select route_id into l_er_archive_number_route_id
        from ff_routes where
        route_name = 'EMPLOYER_ARCHIVE_NUMBER';

 	select route_id into l_er_tax_unit_arch_rid
        from ff_routes where
        route_name = 'EMPLOYER_TAX_UNIT_ARCHIVE';

 	select route_id into l_er_tax_unit_arch_date_rid
        from ff_routes where
        route_name = 'EMPLOYER_TAX_UNIT_ARCHIVE_DATE';

 	select route_id into l_er_tax_unit_arch_number_rid
        from ff_routes where
        route_name = 'EMPLOYER_TAX_UNIT_ARCHIVE_NUMBER';

 	select route_id into l_er_jursd_arch_rid
        from ff_routes where
        route_name = 'EMPLOYER_JURSD_ARCHIVE';

 	select route_id into l_er_jursd_arch_date_rid
        from ff_routes where
        route_name = 'EMPLOYER_JURSD_ARCHIVE_DATE';

 	select route_id into l_er_jursd_arch_number_rid
        from ff_routes where
        route_name = 'EMPLOYER_JURSD_ARCHIVE_NUMBER';

 	select route_id into l_ass_archive_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_ARCHIVE';

 	select route_id into l_ass_archive_date_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_ARCHIVE_DATE';

 	select route_id into l_ass_archive_number_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_ARCHIVE_NUMBER';

 	select route_id into l_ass_gre_archive_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_GRE_ARCHIVE';

 	select route_id into l_ass_jd_archive_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_JD_ARCHIVE';

/*
select route_id into l_ass_gre_jd_archive_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_GRE_JD_ARCHIVE';
*/
 	select route_id into l_ass_gre_ct_jd_arch_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_GRE_CITY_JD_ARCHIVE';

 	select route_id into l_ass_gre_cn_jd_arch_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_GRE_COUNTY_JD_ARCHIVE';

 	select route_id into l_ass_gre_st_jd_arch_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_GRE_STATE_JD_ARCHIVE';

 	select route_id into l_ass_gre_sd_jd_arch_route_id
        from ff_routes where
        route_name = 'ASSIGNMENT_GRE_SCHOOL_JD_ARCHIVE';

hr_utility.trace('got route');

      open get_live_db_details;
      fetch get_live_db_details into
         l_ue_notfound_allowed_flag,
         l_ue_creator_type,
         l_ue_entity_description,
         l_live_route_id,
         l_dbi_null_allowed_flag,
         l_dbi_description,
         l_dbi_data_type ;

      if get_live_db_details%NOTFOUND then

         close get_live_db_details;
         hr_utility.trace('Live database item does not exist : ' ||
                              SUBSTR(p_item_name,3,LENGTH(p_item_name)-2));
         raise_application_error(-20008,'Live database item does not exist : '
                       ||SUBSTR(p_item_name,3,LENGTH(p_item_name)-2));

      else
hr_utility.trace('processing database item : ' || p_item_name);

        open get_context;
        loop
          fetch get_context into l_context_name,
                                 l_context_id,
                                 l_sequence_no;

          exit when get_context%NOTFOUND;
          if l_context_name = 'ASSIGNMENT_ACTION_ID' or
               l_context_name = 'ASSIGNMENT_ID' then
             hr_utility.trace ('Assignment action id context found');
             l_found_asg_action := TRUE;
          elsif l_context_name = 'TAX_UNIT_ID' then
             hr_utility.trace ('Tax Unit id context found');
             l_found_tax_unit := TRUE;
          elsif l_context_name = 'JURISDICTION_CODE' then
             hr_utility.trace ('Jurisdiction code context found');
             l_found_jursd := TRUE;
          end if;
          /*
          l_count := l_count + 1;
          lt_context_name(l_count) := l_context_name;
          lt_context_id(l_count)   := l_context_id;
          lt_sequence_no(l_count)  := l_sequence_no;
          */
        end loop;
        close get_context;


        /* Form the definition text depending upon the data type
           of the database item */

        if l_dbi_data_type = 'N' then
           l_definition_text := 'fnd_number.canonical_to_number(target.value)';
        elsif l_dbi_data_type = 'D' then
           l_definition_text := 'fnd_date.canonical_to_date(target.value)';
        else
           l_definition_text := 'target.value';
        end if;

        if l_found_asg_action and l_found_tax_unit and l_found_jursd then

             /* get the defined balance id of the live database item */

             l_live_bal_db_id := pay_us_magtape_reporting.bal_db_item(SUBSTR(p_item_name,3,LENGTH(p_item_name)-2));
             /* Now get the jurisdiction level of the balance */

             open csr_get_jursd_level(l_live_bal_db_id);
             fetch csr_get_jursd_level into l_jursd_level;
             if csr_get_jursd_level%NOTFOUND then
                l_jursd_level := 0;
             end if;
             close csr_get_jursd_level;

             if l_jursd_level = 11 then
              /* city level jurisdiction */
              l_route_id := l_ass_gre_ct_jd_arch_route_id;
             elsif l_jursd_level = 6 then
              /* county level jurisdiction */
              l_route_id := l_ass_gre_cn_jd_arch_route_id;
             elsif l_jursd_level = 2 then
              /* city state jurisdiction */
              l_route_id := l_ass_gre_st_jd_arch_route_id;
             elsif l_jursd_level = 8 then
              /* school level jurisdiction */
              l_route_id := l_ass_gre_sd_jd_arch_route_id;
             end if;

        elsif l_found_asg_action and l_found_tax_unit and
              not(l_found_jursd) then

              l_route_id := l_ass_gre_archive_route_id;

        elsif l_found_asg_action and not(l_found_tax_unit) and
              l_found_jursd then

              l_route_id := l_ass_jd_archive_route_id;

        elsif l_found_asg_action and not(l_found_tax_unit) and
              not(l_found_jursd) then

              if l_dbi_data_type = 'N' then
                 l_route_id := l_ass_archive_number_route_id;
              elsif l_dbi_data_type = 'D' then
                 l_route_id := l_ass_archive_date_route_id;
              else
                 l_route_id := l_ass_archive_route_id;
              end if;

        elsif not(l_found_asg_action) and not(l_found_tax_unit) and
              not(l_found_jursd) then

              if l_dbi_data_type = 'N' then
                 l_route_id := l_er_archive_number_route_id;
              elsif l_dbi_data_type = 'D' then
                 l_route_id := l_er_archive_date_route_id;
              else
                 l_route_id := l_er_archive_route_id;
              end if;

        elsif not(l_found_asg_action) and l_found_tax_unit and
              not(l_found_jursd) then

              if l_dbi_data_type = 'N' then
                 l_route_id := l_er_tax_unit_arch_number_rid;
              elsif l_dbi_data_type = 'D' then
                 l_route_id := l_er_tax_unit_arch_date_rid;
              else
                 l_route_id := l_er_tax_unit_arch_rid;
              end if;

        elsif not(l_found_asg_action) and l_found_tax_unit and
              l_found_jursd then

              if l_dbi_data_type = 'N' then
                 l_route_id := l_er_jursd_arch_number_rid;
              elsif l_dbi_data_type = 'D' then
                 l_route_id := l_er_jursd_arch_date_rid;
              else
                 l_route_id := l_er_jursd_arch_rid;
              end if;

        elsif not(l_found_asg_action) and not(l_found_tax_unit) and
              l_found_jursd then

              if l_dbi_data_type = 'N' then
                 l_route_id := l_er_jursd_arch_number_rid;
              elsif l_dbi_data_type = 'D' then
                 l_route_id := l_er_jursd_arch_date_rid;
              else
                 l_route_id := l_er_jursd_arch_rid;
              end if;

         end if;


      hr_utility.trace('getting  route parameter id for ' || to_char(l_route_id));

      select ROUTE_PARAMETER_ID into l_route_parameter_id
      from ff_route_parameters
      where parameter_name = 'User Entity ID'
      and route_id = l_route_id;

      hr_utility.trace('got route parameter id');


      open get_user_entity;
      fetch get_user_entity into l_user_entity_id,
                                 l_exist_route_id;
      if get_user_entity%FOUND then

         /* Update the route id if required */
         if l_route_id <> l_exist_route_id then

             hr_utility.trace ('Existing Route  id : '||
                                to_char(l_exist_route_id));
             hr_utility.trace ('New Route  id : '||
                                to_char(l_route_id));
             hr_utility.trace ('User Entity id : '||
                                to_char(l_user_entity_id));
            update ff_user_entities
            set route_id = l_route_id
            where user_entity_id = l_user_entity_id;

            update ff_route_parameter_values
            set route_parameter_id = l_route_parameter_id
            where user_entity_id = l_user_entity_id;

         end if;

      else

 	 select ff_user_entities_s.nextval
         into l_user_entity_seq
         from dual;

         insert into ff_user_entities
              (user_entity_id,
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
              creation_date)
          values( l_user_entity_seq,         /* user_entity_id */
              null,			     /* business_group_id */
              'US',			     /* legislation_code */
              l_route_id,		     /* route_id */
              l_ue_notfound_allowed_flag,    /* notfound_allowed_flag */
              p_item_name,		     /* user_entity_name */
              0,			     /* creator_id */
              'X',               	     /* archive extract creator_type */
	      substr('Archive of '||l_ue_creator_type||' entity '||
              l_ue_entity_description,1,240),/* entity_description */
              sysdate,			     /* last_update_date */
              0,			     /* last_updated_by */
              0,			     /* last_update_login */
              0,			     /* created_by */
              sysdate);          	     /* creation_date */

          insert into ff_route_parameter_values (
              route_parameter_id,
              user_entity_id,
              value,
              last_update_date,
              last_updated_by,
              last_update_login,
              created_by,
              creation_date)
          values( l_route_parameter_id,
              l_user_entity_seq,
              l_user_entity_seq,
              sysdate,
              0,
              0,
              0,
              sysdate);

          insert into ff_database_items (
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
          values( p_item_name,
              l_user_entity_seq,
              l_dbi_data_type,
              l_definition_text,
              l_dbi_null_allowed_flag,
              substr('Archive of item '||l_dbi_description,1,240),
              sysdate,
              0,
              0,
              0,
              sysdate);
        end if;
        close get_user_entity;

       end if;

 end create_eoy_archive_dbi;       -- ]

end py_w2_dbitems; --

/
