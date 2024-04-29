--------------------------------------------------------
--  DDL for Package Body PAY_RULES_DBI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RULES_DBI_PKG" as
/* $Header: pywatdbi.pkb 120.0 2005/05/29 10:16:39 appldev noship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pywatdbi.pkb
--
   DESCRIPTION

     This package is used to create a database item for every column in a
     table.  This is currently to be used by garnishments and the legislative
     rules which will be held in tables.  This package will be generic,
     however, such that any table can have simple dbi created from its'
     columns.

     The target audience for using this package would be any table containing
     data which would be found usefule in a payroll formula or calculation.
     The data in this table could originate external to Oracle Payroll, yet
     be immediately usable within a payroll run via this mechanism.  The only
     requirement being that the table is somehow keyed off one of the contexts
     available to payroll run formulae.  As an example, the legislative rules
     required to process garnishments are "legislation dependent" - ie. are
     keyed by Jurisdiction.

     Also required is the route text to alias the "source table" as "target".
     Feel free to extend the parameters in this package if additional context
     values are required - currently accept 4.

     The create_db_item procedure provides a single function interface for
     the creation of database items.  New routes may be created, or old
     ones may be re-used (created originally by S Panwar).
--
  MODIFIED (DD-MON-YYYY)
  H Parichabutr 14-NOV-1995     Created
  A.Myers       13-FEB-1998	Knock on fix from bug 602851, extra parameter
				and logic associated with call to procedure
				hrdyndbi.insert_user_entity
  S.Doshi       31-MAR-1999     Flexible Dates Conversion
rem    110.1   19 jun 99        i harding       added ; to exit
  A.Logue       14-FEB-2000     Utf8 Support.

*/
--
-- Procedures
--
PROCEDURE create_db_item(p_name                    VARCHAR2,
                         p_description             VARCHAR2 DEFAULT NULL,
                         p_data_type               VARCHAR2,
                         p_null_allowed            VARCHAR2,
			 p_definition_text         VARCHAR2,
                         p_user_entity_name        VARCHAR2,
			 p_user_entity_description VARCHAR2 DEFAULT NULL,
                         p_route_name              VARCHAR2,
                         p_param_value1            VARCHAR2 DEFAULT NULL,
			 p_param_value2            VARCHAR2 DEFAULT NULL,
                         p_route_description       VARCHAR2 DEFAULT NULL,
			 p_route_text              VARCHAR2 DEFAULT NULL,
			 p_context_name1           VARCHAR2 DEFAULT NULL,
			 p_context_name2           VARCHAR2 DEFAULT NULL,
			 p_context_name3           VARCHAR2 DEFAULT NULL,
			 p_context_name4           VARCHAR2 DEFAULT NULL,
                         p_param_name1             VARCHAR2 DEFAULT NULL,
			 p_param_type1             VARCHAR2 DEFAULT NULL,
			 p_param_name2             VARCHAR2 DEFAULT NULL,
                         p_param_type2             VARCHAR2 DEFAULT NULL
   ) IS
--
l_route_id         NUMBER;
l_user_entity_id   NUMBER;
l_record_inserted  BOOLEAN;
--
BEGIN
--
--  Get the route id.  Create a route if necessary.
--
  BEGIN
--
    SELECT route_id
    INTO   l_route_id
    FROM   ff_routes
    WHERE  route_name = upper(p_route_name);
--
  EXCEPTION WHEN NO_DATA_FOUND THEN
--
--  Create the route, context usages, and parameters
--
    INSERT INTO ff_routes
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
    VALUES
      (ff_routes_s.nextval,
       upper(p_route_name),
       'N',
       p_route_description,
       p_route_text,
       sysdate,
       0,
       0,
       0,
      sysdate);
--
    SELECT ff_routes_s.currval
    INTO   l_route_id
    FROM   dual;
--
--  Insert any context usages
--
    IF p_context_name1 is not null THEN
--
      INSERT INTO ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  l_route_id,
              FFC.context_id,
              1
      from    ff_contexts FFC
      where   context_name = p_context_name1;
--
    END IF;
--
    IF p_context_name2 is not null THEN
--
      INSERT INTO ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  l_route_id,
              FFC.context_id,
              2
      from    ff_contexts FFC
      where   context_name = p_context_name2;
--
    END IF;
--
    IF p_context_name3 is not null THEN
--
      INSERT INTO ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  l_route_id,
              FFC.context_id,
              3
      from    ff_contexts FFC
      where   context_name = p_context_name3;
--
    END IF;
--
    IF p_context_name4 is not null THEN
--
      INSERT INTO ff_route_context_usages
             (route_id,
              context_id,
              sequence_no)
      select  l_route_id,
              FFC.context_id,
              4
      from    ff_contexts FFC
      where   context_name = p_context_name4;
--
    END IF;
--
-- Insert any route parameters
--
    IF p_param_name1 is not null THEN
--
       INSERT INTO ff_route_parameters
         (route_parameter_id,
          route_id,
          sequence_no,
          parameter_name,
          data_type)
       VALUES
         (ff_route_parameters_s.nextval,
          l_route_id,
          1,
          p_param_name1,
          p_param_type1);
--
    END IF;
--
    IF p_param_name2 is not null THEN
--
       INSERT INTO ff_route_parameters
         (route_parameter_id,
          route_id,
          sequence_no,
          parameter_name,
          data_type)
       VALUES
         (ff_route_parameters_s.nextval,
          l_route_id,
          1,
          p_param_name2,
          p_param_type2);
--
    END IF;
--
  END;
--
--  Get the user entity id.  Create a user entity if necessary.
--
  BEGIN
--
    SELECT user_entity_id
    INTO   l_user_entity_id
    FROM   ff_user_entities
    WHERE  user_entity_name = upper(p_user_entity_name);
--
  EXCEPTION WHEN NO_DATA_FOUND THEN
--
-- Create the user entity
--
    hrdyndbi.insert_user_entity (
                p_route_name =>         p_route_name,
                p_user_entity_name  =>  p_user_entity_name,
                p_entity_description => p_user_entity_description,
                p_not_found_flag =>     'Y',
                p_creator_type =>       'SEH',
                p_creator_id =>         0,
                p_business_group_id =>  NULL,
                p_legislation_code =>   'US',
                p_created_by =>         0,
                p_last_login =>         0,
		p_record_inserted =>	l_record_inserted
                );
--
    SELECT user_entity_id
    INTO   l_user_entity_id
    FROM   ff_user_entities
    WHERE  user_entity_name = p_user_entity_name;
--
-- Add any route parameter values
--
    IF p_param_value1 is not null AND l_record_inserted THEN
--
      INSERT into ff_route_parameter_values
        (route_parameter_id,
         user_entity_id,
         value)
      SELECT route_parameter_id,
             l_user_entity_id,
             p_param_value1
      FROM   ff_route_parameters
      where  route_id = l_route_id
      and    sequence_no = 1;
--
    END IF;
--
    IF p_param_value2 is not null AND l_record_inserted THEN
--
      INSERT into ff_route_parameter_values
        (route_parameter_id,
         user_entity_id,
         value)
      SELECT route_parameter_id,
             l_user_entity_id,
             p_param_value2
      FROM   ff_route_parameters
      where  route_id = l_route_id
      and    sequence_no = 2;
--
    END IF;
--
  END;
--
--  Now build db item
--
  IF l_record_inserted THEN
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
  values (p_name,
          l_user_entity_id,
          p_data_type,
          p_definition_text,
          p_null_allowed,
          p_description,
          sysdate,
          0,
          0,
          0,
          sysdate);
  END IF;
--
END create_db_item;
--

PROCEDURE create_table_column_dbi (	p_table_name		VARCHAR2,
					p_table_short_name	VARCHAR2,
					p_route_sql		VARCHAR2,
					p_key_context1		VARCHAR2,
					p_key_context2		VARCHAR2,
					p_key_context3		VARCHAR2,
					p_key_context4		VARCHAR2) IS

CURSOR get_column_details (p_tab_name IN VARCHAR2) IS
  SELECT column_name,
         decode(data_type, 'CHAR', 	'T',
			   'VARCHAR2', 	'T',
			   'LONG', 	'N',
			   'LONG RAW', 	'N',
			   'NUMBER', 	'N',
			   'DATE', 	'D',
			   'ROWID', 	'T',	'T'),
         nullable
  FROM   user_tab_columns
  WHERE  table_name = p_tab_name;

  l_data_type		VARCHAR2(1);
  l_nullable		VARCHAR2(1);
  l_column_name		VARCHAR2(30);
  l_defn_text		VARCHAR2(240);
  l_dbi_name		VARCHAR2(240);
  l_desc		VARCHAR2(240);

BEGIN

/*
   Having the route text and contexts, we only need to set up the following
   params for each call to create_db_item:
*  p_name		=> Table's column name.
*  p_data_type		=> Column data type.
*  p_null_allowed	=> columns' nullable setting.
*  p_definition_text	=> We build as 'SELECT target.'||column_name
   p_user_entity_name	=> Use table short name, serves as "root" for dbiname.
   p_user_entity_desc	=> Use table name.
   p_route_name		=> We have.
   p_context_name1	=> We have, as well as contexts 2,3,4 if needed.
   p_param_value1	=> NULL
   p_param_name1	=> NULL
   p_param_type1	=> NULL

   Database item names should never exceed 80 characters since table and
   column names are limited to 30 characters each.

   Column information can be found in the table USER_TAB_COLUMNS.
*/

OPEN get_column_details (p_table_name);

 LOOP

  FETCH get_column_details
  INTO  l_column_name, l_data_type, l_nullable;
  EXIT when get_column_details%NOTFOUND;

  l_defn_text := 'SELECT target.'||l_column_name;

  l_dbi_name := UPPER(p_table_short_name||'_'||l_column_name);

--
-- Check that dbi name will not exceed 240 characters.
--
  IF LENGTH(l_dbi_name) > 240 THEN

    -- DBI name too long !?

    EXIT;

  END IF;

  l_desc := 'Generated from '||p_table_name||' table';
  create_db_item (
		p_name 		=> l_dbi_name,
		p_description	=> l_desc,
		p_data_type 	=> l_data_type,
		p_null_allowed	=> l_nullable,
		p_definition_text	=> l_defn_text,
		p_user_entity_name	=> p_table_short_name,
		p_user_entity_description 	=> p_table_name,
		p_route_name	=> NULL,
		p_route_text	=> p_route_sql,
		p_context_name1	=> p_key_context1,
		p_context_name2	=> p_key_context2,
		p_context_name3	=> p_key_context3,
		p_context_name4	=> p_key_context4);
 END LOOP;

CLOSE get_column_details;

END create_table_column_dbi;


PROCEDURE create_garntab_dbi IS

  TYPE text_table IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  TYPE sql_table IS TABLE OF VARCHAR2(20000) INDEX BY BINARY_INTEGER;

  dbi_table_source	text_table;
  dbi_table_shorts	text_table;
  route_sql		sql_table;

  l_date_earned_ctx	VARCHAR2(30)	:= 'DATE_EARNED';
  l_jurisdiction_ctx	VARCHAR2(30)	:= 'JURISDICTION_CODE';
  l_element_type_ctx	VARCHAR2(30)	:= 'ELEMENT_TYPE_ID';

  l_num_sources		number;
  i			number;

BEGIN

/* ------------------------------------------------------------------------ */
  dbi_table_source(1)	:= 'PAY_GARN_EXEMPTION_RULES';
  dbi_table_shorts(1)	:= 'GARN_EXEMPTION';
  route_sql(1)		:=
'     PAY_GARN_EXEMPTION_RULES target,
      PAY_ELEMENT_TYPES_F pet
WHERE target.state_code = substr(1,2,&B1)
AND   target.garn_category = pet.element_information1
AND   &B3          BETWEEN target.effective_start_date
                        AND target.effective_end_date
AND   pet.element_type_id = &B2
AND   &B3          BETWEEN pet.effective_start_date
                        AND pet.effective_end_date';
/* ------------------------------------------------------------------------ */


/* ------------------------------------------------------------------------ */
  dbi_table_source(2)	:= 'PAY_GARN_ARREARS_RULES';
  dbi_table_shorts(2)	:= 'GARN_ARREARS';
  route_sql(2) :=
'     PAY_GARN_EXEMPTION_RULES target,
      PAY_ELEMENT_TYPES_F pet
WHERE target.state_code = substr(1,2,&B1)
AND   target.garn_category = pet.element_information1
AND   &B3          BETWEEN target.effective_start_date
                        AND target.effective_end_date
AND   pet.element_type_id = &B2
AND   &B3          BETWEEN pet.effective_start_date
                        AND pet.effective_end_date';
/* ------------------------------------------------------------------------ */


/* ------------------------------------------------------------------------ */
  dbi_table_source(3)	:= 'PAY_GARN_FEE_RULES';
  dbi_table_shorts(3)	:= 'GARN_FEE';
  route_sql(3) :=
'     PAY_GARN_EXEMPTION_RULES target,
      PAY_ELEMENT_TYPES_F pet
WHERE target.state_code = substr(1,2,&B1)
AND   target.garn_category = pet.element_information1
AND   &B3          BETWEEN target.effective_start_date
                        AND target.effective_end_date
AND   pet.element_type_id = &B2
AND   &B3          BETWEEN pet.effective_start_date
                        AND pet.effective_end_date';
/* ------------------------------------------------------------------------ */


/* ------------------------------------------------------------------------ */
  dbi_table_source(4)	:= 'PAY_GARN_LIMIT_RULES';
  dbi_table_shorts(4)	:= 'GARN_LIMIT';
  route_sql(4) :=
'     PAY_GARN_EXEMPTION_RULES target,
      PAY_ELEMENT_TYPES_F pet
WHERE target.state_code = substr(1,2,&B1)
AND   target.garn_category = pet.element_information1
AND   &B3          BETWEEN target.effective_start_date
                        AND target.effective_end_date
AND   pet.element_type_id = &B2
AND   &B3          BETWEEN pet.effective_start_date
                        AND pet.effective_end_date';
/* ------------------------------------------------------------------------ */


  for i in 1..l_num_sources LOOP

    pay_rules_dbi_pkg.create_table_column_dbi(
	p_table_name	=> dbi_table_source(i),
	p_table_short_name => dbi_table_shorts(i),
        p_route_sql	=> route_sql(i),
	p_key_context1	=> l_jurisdiction_ctx,
	p_key_context2	=> l_element_type_ctx,
	p_key_context3	=> l_date_earned_ctx,
	p_key_context4	=> NULL);

  END LOOP;

END create_garntab_dbi;

end pay_rules_dbi_pkg;

/
