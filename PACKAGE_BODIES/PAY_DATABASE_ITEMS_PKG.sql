--------------------------------------------------------
--  DDL for Package Body PAY_DATABASE_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DATABASE_ITEMS_PKG" as
/* $Header: pycadbis.pkb 120.0 2005/05/29 03:28:45 appldev noship $ */
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pycadbip.pkb
--
   DESCRIPTION
      Provides a single function interface for the creation of database
      items.  New routes may be created, or old ones may be re-used.
--
  MODIFIED (DD-MON-YYYY)
  RThirlby  20_JUL-1999      	Created (copy of pyusdbip.pkb, but with new
                                legislation_code parameter.
  RThirlby  09-NOV-1999         Commented out if l_record_inserted clause
                                around create_db_item, so that dbi is
                                created even if user entity was previously
                                created.
  RThirlby  29-FEB-2000         No changes required for 11i upport
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
                         p_param_type2             VARCHAR2 DEFAULT NULL,
                         p_legislation_code        VARCHAR2
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
  hr_utility.set_location ('pay_database_items_pkg.create_db_item', 1);
  hr_utility.trace ('p_name: ' || p_name);
  hr_utility.trace ('p_description: ' || p_description);
  hr_utility.trace ('p_data_type: ' || p_data_type);
  hr_utility.trace ('p_null_allowed: ' || p_null_allowed);
  hr_utility.trace ('p_definition_text: ' || p_definition_text);
  hr_utility.trace ('p_user_entity_name: ' || p_user_entity_name);
  hr_utility.trace ('p_user_entity_description: ' || p_user_entity_description);
  hr_utility.trace ('p_route_name: ' || p_route_name);
  hr_utility.trace ('p_route_description: ' || p_route_description);
  hr_utility.trace ('p_route_text: ' || p_route_text);
  hr_utility.trace ('p_context_name1: ' || p_context_name1);
  hr_utility.trace ('p_context_name2: ' || p_context_name2);
  hr_utility.trace ('p_legislation_code: ' || p_legislation_code);
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
                p_route_name =>         upper(p_route_name),
                p_user_entity_name  =>  p_user_entity_name,
                p_entity_description => p_user_entity_description,
                p_not_found_flag =>     'Y',
                p_creator_type =>       'SEH',
                p_creator_id =>         0,
                p_business_group_id =>  NULL,
                p_legislation_code =>   p_legislation_code,
                p_created_by =>         0,
                p_last_login =>         0,
                p_record_inserted =>	l_record_inserted);
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
--  IF l_record_inserted THEN
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
  --
--  ELSE
  --
--    hr_utility.trace('Database_item already exists, so not reinserted');
    --
--  END IF;
--
END create_db_item;
--
end pay_database_items_pkg;

/
