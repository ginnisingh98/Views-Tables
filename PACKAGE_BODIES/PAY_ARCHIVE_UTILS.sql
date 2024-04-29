--------------------------------------------------------
--  DDL for Package Body PAY_ARCHIVE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ARCHIVE_UTILS" as
/* $Header: pyarcutl.pkb 115.5 2001/12/24 05:34:02 pkm ship      $ */
  --
  -------------------------------------------------------------------
  --FUNCTION get_context_id (Private)
  --DESCRIPTION: very simple context_id fetch with error handling.
  -------------------------------------------------------------------
  FUNCTION get_context_id(p_context_name IN VARCHAR2) RETURN NUMBER IS
   --
   l_context_id number;
   --
   cursor c_get_context(c_context_name varchar2) is
   select context_id
   from   ff_contexts
   where context_name = c_context_name;
   --
  begin
   --
      open c_get_context(p_context_name);
      fetch c_get_context into l_context_id;
      close c_get_context;
   --
      if l_context_id is null then
         RAISE NO_DATA_FOUND;
      end if;
   --

  return l_context_id;
   --
  END get_context_id;

   -------------------------------------------------------------------------
   -- FUNCTION get_number_archive_route (Private)
   -- DESCRIPTION: Define the seeded number archive route. Check for
   -- existance, if this does not exist, create as necessary.
   -- This is used by the main procedure, mainly to select the apt
   -- route_id, but on first call, will create the seeded route.
   -------------------------------------------------------------------------
   FUNCTION get_number_archive_route RETURN NUMBER IS
   --
   l_text                         long;
   l_assignment_action_context_id number;
   l_exists                       varchar2(1);
   l_route_id			  number;
   --
   cursor check_exists is
   select route_id from ff_routes
   where route_name = 'ARCHIVE_NUMBER_ROUTE';
   --
   BEGIN
   --
      open check_exists;
      fetch check_exists into l_route_id;
      close check_exists;
   --
      IF l_route_id is null then
      --
      -- Create the route, context and parameter.
      -- First define the text.
      --
      l_text := 'ff_archive_items target
         where target.user_entity_id = &U1
         and target.context1 = &B1 /* context assignment action id */';
      --
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
         (
            ff_routes_s.nextval,
            'ARCHIVE_NUMBER_ROUTE',
            'N',
            'Generic number archive route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
         );

         -- Define the route parameter
         insert into ff_route_parameters
         (
            route_parameter_id,
            route_id,
            data_type,
            parameter_name,
            sequence_no
         )
         select
            ff_route_parameters_s.nextval,
            ff_routes_s.currval,
            'N',
            'User Entity ID',
            1
         from dual;
         --
         -- Define the route context usage after retrieving the context id.
         --
         l_assignment_action_context_id := get_context_id('ASSIGNMENT_ACTION_ID');
         --
         insert into ff_route_context_usages
         (
            route_id,
            context_id,
            sequence_no
         )
         select
            ff_routes_s.currval,
            l_assignment_action_context_id,
            1
         from dual;
         --
         -- set the route_id to be returned
         --
         select ff_routes_s.currval into l_route_id from dual;
         --
      END IF;
   --
   RETURN l_route_id;
   --
   end get_number_archive_route;

   -------------------------------------------------------------------------
   -- FUNCTION get_char_archive_route (Private)
   -- DESCRIPTION: Define the seeded character archive route. Check for
   -- existance, if this does not exist, create as necessary.
   -- Used by main procedure as above.
   -------------------------------------------------------------------------
   FUNCTION get_char_archive_route RETURN NUMBER IS
   --
   l_text                         long;
   l_assignment_action_context_id number;
   l_exists                       varchar2(1);
   l_route_id                     number;
   --
   cursor check_exists is
   select route_id from ff_routes
   where route_name = 'ARCHIVE_CHAR_ROUTE';
   --
   BEGIN
   --
      open check_exists;
      fetch check_exists into l_route_id;
      close check_exists;

      IF l_route_id is null then
         --
         -- Create the route, context and parameter.
         -- First define the route text.
         --
         l_text := 'ff_archive_items target
         where target.user_entity_id = &U1
         and target.context1 = &B1 /* context assignment action id */';
         --
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
         (
            ff_routes_s.nextval,
            'ARCHIVE_CHAR_ROUTE',
            'N',
            'Generic character archive route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
         );

         -- Define the route parameter
         insert into ff_route_parameters
         (
            route_parameter_id,
            route_id,
            data_type,
            parameter_name,
            sequence_no
         )
         select
            ff_route_parameters_s.nextval,
            ff_routes_s.currval,
            'N',
            'User Entity ID',
            1
         from dual;
         --
         -- Define the route context usage.
         -- Get the context_id for the assignment_action context
         --
         l_assignment_action_context_id := get_context_id('ASSIGNMENT_ACTION_ID');
         --
         insert into ff_route_context_usages
         (
            route_id,
            context_id,
            sequence_no
         )
         select
            ff_routes_s.currval,
            l_assignment_action_context_id,
            1
         from dual;
      --
      -- set the route_id to be returned
      --
      select ff_routes_s.currval into l_route_id from dual;
      --
      END IF;
   --
   RETURN l_route_id;
   --
   end get_char_archive_route;
   --
   -------------------------------------------------------------------------
   -- FUNCTION get_two_context_route (Private)
   -- DESCRIPTION: Define the seeded two-context archive route. Check for
   -- existance, if this does not exist, create as necessary.
   -- The first context usage will be assignment action id, the second is
   -- user-defined and is taken in as a parameter here. The
   -- route name is made up using the second context as below, this is
   -- because we cannot use the same route with two DBI's that have different
   -- contexts, due to the route_context_usages.
   -------------------------------------------------------------------------
   FUNCTION get_two_context_route (p_second_context_name IN VARCHAR2)
                                                            RETURN NUMBER IS
   --
   l_text                         long;
   l_second_context_id            number;
   l_assignment_action_context_id number;
   l_route_id			  number;
   l_new_route_name               varchar2(80);
   --
   cursor check_exists(c_route_name varchar2) is
   select route_id from ff_routes
   where route_name = c_route_name;
   --
   BEGIN
   --
      l_new_route_name := 'ARCHIVE_'||p_second_context_name||'_ROUTE';
   --
   --   dbms_output.put_line('route name :'||l_new_route_name);
      open check_exists(l_new_route_name);
      fetch check_exists into l_route_id;
      close check_exists;
   --
   --  dbms_output.put_line('Route id: '||to_char(l_route_id));
      IF l_route_id is null then
      --
      -- Create the route code for two-context route.
      --
      -- dbms_output.put_line('creating route...');
      l_text := 'ff_archive_items target,
         ff_archive_item_contexts fac,
         ff_contexts ffc
         where target.user_entity_id = &U1
         and target.context1 = &B1 /* context assignment action id */
         and fac.archive_item_id = target.archive_item_id
         and ffc.context_id = fac.context_id
         and fac.context = decode(ffc.data_type,''T'',&B2,to_char(&B2)) /*2nd context*/';
      --
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
      (
         ff_routes_s.nextval,
         l_new_route_name,
         'N',
         'Two Context Generic archive route',
         l_text,
         sysdate,
         0,
         0,
         0,
         sysdate
      );

      -- Define the route parameter
      insert into ff_route_parameters
      (
         route_parameter_id,
         route_id,
         data_type,
         parameter_name,
         sequence_no
      )
      select
         ff_route_parameters_s.nextval,
         ff_routes_s.currval,
         'N',
         'User Entity ID',
         1
      from dual;
      --
      -- Define the first route context usage , based on the
      -- Assignment_action_id
      --
      l_assignment_action_context_id := get_context_id('ASSIGNMENT_ACTION_ID');
      --
      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select
         ff_routes_s.currval,
         l_assignment_action_context_id,
         1
      from dual;
      --
      -- Define second route context usage, based on the parameter.
      --
      l_second_context_id := get_context_id(p_second_context_name);
      --
      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select
         ff_routes_s.currval,
         l_second_context_id,
         2
      from dual;
      --
      -- Set the route ID to be returned
      --
      select ff_routes_s.currval into l_route_id from dual;
      --
   END IF;
   --
RETURN l_route_id;
--
end get_two_context_route;

-------------------------------------------------------------------------
-- PROCEDURE: create_archive_dbi (Public)
-- DESCRIPTION: This procedure creates an archive database item,
-- for the live database item that is passed as a parameter.
-- This first checks that the routes have been set up, then
-- creates the archive Database Item.
-- If the procedure is to use a second context in addition to
-- the Assignment Action, this is passed as the secondary context
-- name.
-- If the procedure is called with a predefined route name, that route
-- has to be set up with it's contexts and parameter previously.
--
-------------------------------------------------------------------------
procedure create_archive_dbi(p_live_dbi_name          VARCHAR2,
                             p_archive_route_name     VARCHAR2 DEFAULT NULL,
                             p_secondary_context_name VARCHAR2 DEFAULT NULL) is

-- Find the attributes from the live database item and create an
-- archive version of it

l_dbi_null_allowed_flag      varchar2(1);
l_dbi_description            varchar2(240);
l_dbi_data_type              varchar2(1);
l_dbi_user_name              varchar(240);
l_ue_notfound_allowed_flag   varchar2(1);
l_ue_creator_type            varchar2(30);
l_ue_entity_description      varchar2(240);
l_ue_legislation_code        varchar2(4);
l_ue_business_group_id       number;
l_user_entity_seq            number;
l_user_entity_id             number;
l_route_parameter_id         number;
l_dummy_id                   number;
l_route_id                   number;
l_live_route_id              number;
l_character_archive_route_id number;
l_number_archive_route_id    number;
l_definition_text            varchar2(240);
l_archive_dbi_name           varchar2(80);

begin

   begin
      --
      -- Get all the required information from the
      -- Live database item, and it's associated user entity
      --
      select
         ue.notfound_allowed_flag,
         ue.creator_type,
         ue.entity_description,
         ue.route_id,
         ue.legislation_code,
         ue.business_group_id,
         dbi.null_allowed_flag,
         dbi.description ,
         dbi.data_type,
         dbi.user_name
      into
         l_ue_notfound_allowed_flag,
         l_ue_creator_type,
         l_ue_entity_description,
         l_live_route_id,
         l_ue_legislation_code,
         l_ue_business_group_id,
         l_dbi_null_allowed_flag,
         l_dbi_description,
         l_dbi_data_type,
         l_dbi_user_name
      from
         ff_database_items dbi,
         ff_user_entities  ue
      where dbi.user_name = p_live_dbi_name
      and   dbi.user_entity_id = ue.user_entity_id
      and   ue.business_group_id is null;
--
-- Note that for USER-DEFINED DBI's to be archived, the above line should
-- be removed.
--
   end;
   --
   -- Set the Archive DBI's name. If concatenation is > 80,
   -- This will error with ORA-6502, rather than trying to
   -- insert into the DB later.
   --
   l_archive_dbi_name := 'A_'||p_live_dbi_name;
   --
   -- Calculate which Definition Text to use based on the DBI's Data Type
   --
   IF l_dbi_data_type = 'N' then
      l_definition_text := 'fnd_number.canonical_to_number(target.value)';
   ELSIF l_dbi_data_type = 'D' then
      l_definition_text := 'fnd_date.canonical_to_date(target.value)';
   ELSE
      l_definition_text := 'target.value';
   END IF;
   --
   -- ROUTE CREATION/CHECK CODE.
   -- Check to see whether the call has been made without an archive route
   --
   IF p_archive_route_name is null then
      --
      -- Check for the secondary context, if this does not exist
      -- Choose the seeded single archive route, based once again on the live
      -- db item's data type. Check Existance and create if necessary.
      --
      IF p_secondary_context_name is null then
      --
         IF l_dbi_data_type = 'N' OR l_dbi_data_type = 'D' then
            --
            -- Use the Number Route
            l_route_id := get_number_archive_route;
         ELSE
            --
            -- Use the Character Route
            l_route_id := get_char_archive_route;
         END IF;
      ELSE
         --
         -- There are two contexts, create the route
         l_route_id := get_two_context_route(p_secondary_context_name);
      END IF;
   --
   ELSE
      --
      -- The route is provided, so this procedure does not
      -- have to create it, or its context usages or params.
      -- If supplied route name does not exist, allow NO_DATA_FOUND
      -- to be raised within this anonymous block.
      --
      BEGIN
         --
         select route_id
         into l_route_id
         from ff_routes where
         route_name = p_archive_route_name;
         --
      END;
   --
   END IF; -- END OF ROUTE CREATION/CHECK CODE.
   --
   -- Find the User Entity Route parameter that goes with the archive route
   --
   select route_parameter_id
   into   l_route_parameter_id
   from   ff_route_parameters
   where  parameter_name = 'User Entity ID'
   and    route_id = l_route_id;

   BEGIN
      --
      -- Check to see if the archive database item already exists.
      -- This will raise an EXCEPTION if it doesn't exist, which
      -- will cause the INSERT (below). If it does exist, update description
      -- etc.
      --
      select user_entity_id
      into   l_user_entity_seq
      from   ff_user_entities
      where  user_entity_name = l_archive_dbi_name
      and    business_group_id is null;

-- Removed as you are not allowed to update this table.
--      update ff_user_entities
--      set    route_id = l_route_id,
--             notfound_allowed_flag = 'Y',   -- l_ue_notfound_allowed_flag,
--             entity_description = substr('Archive of ' || l_ue_entity_description, 1, 240)
--      where  user_entity_name = l_archive_dbi_name
--      and    business_group_id is null;
      --
      -- Does the route parameter exist
      --
      begin

         select route_parameter_id
         into   l_dummy_id
         from   ff_route_parameter_values
         where  route_parameter_id = l_route_parameter_id
         and    user_entity_id = l_user_entity_seq;

         update ff_route_parameter_values
         set    value = l_user_entity_seq
         where  route_parameter_id = l_route_parameter_id
         and    user_entity_id = l_user_entity_seq;

      exception when no_data_found then
         --
         -- route parameter does not exist so cause insert
         --
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
            l_route_parameter_id,
            l_user_entity_seq,
            l_user_entity_seq,
            sysdate,
            0,
            0,
            0,
            sysdate
         );

      end;

      update ff_database_items
      set    user_entity_id = l_user_entity_seq,
             data_type = l_dbi_data_type,
             definition_text = l_definition_text,
             null_allowed_flag = 'Y',   -- l_dbi_null_allowed_flag,
             description = substr('Archive of ' || l_dbi_description, 1, 240)
      where  user_name = l_archive_dbi_name;

   EXCEPTION WHEN NO_DATA_FOUND THEN
      --
      -- Archive DBI does not exist, so create the User Entity,
      -- Route Parameter, and DBI.
      --
      select ff_user_entities_s.nextval into l_user_entity_seq from dual;

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
         l_user_entity_seq,                     /* user_entity_id */
         null,
         --l_ue_business_group_id,                /* business_group_id */
         l_ue_legislation_code,                 /* legislation_code */
         l_route_id,                            /* route_id */
         'Y',
--         l_ue_notfound_allowed_flag,          /* notfound_allowed_flag */
         l_archive_dbi_name,                    /* user_entity_name */
         0,                                     /* creator_id */
         'X',                                   /* archive extract creator_type */
         substr('Archive of ' || l_ue_entity_description, 1, 240),   /* entity_description */
         sysdate,                               /* last_update_date */
         0,                                     /* last_updated_by */
         0,                                     /* last_update_login */
         0,                                     /* created_by */
         sysdate                                /* creation_date */
      );

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
         l_route_parameter_id,
         l_user_entity_seq,
         l_user_entity_seq,
         sysdate,
         0,
         0,
         0,
         sysdate
      );

      insert into ff_database_items
      (
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
         creation_date
      )
      values
      (
         l_archive_dbi_name,
         l_user_entity_seq,
         l_dbi_data_type,
         l_definition_text,
         'Y',
--         l_dbi_null_allowed_flag,
         substr('Archive of item ' || l_dbi_description, 1, 240),
         sysdate,
         0,
         0,
         0,
         sysdate
      );

   end;

end create_archive_dbi;
------------------------------------------------------------------------------------
-- PROCEDURE:   create_archive_dbi (Public, overloaded)
-- DESCRIPTION: This procedure creates an EXTRACT type Archive DBI, which
--              is prefixed with 'X_'. The extract DBI's name is a parameter
--              to the procedure, whereas the above procedure uses the live DBI
--              name as a parameter. In this case there is no live DBI, and the
--              route_id must always be passed in and (implicitly!) pre-defined.
------------------------------------------------------------------------------------
--
procedure create_archive_dbi(p_extract_item_name     VARCHAR2,
                             p_route_id              NUMBER,
                             p_data_type             VARCHAR2,
                             p_legislation_code      VARCHAR2,
                             p_null_allowed_flag     VARCHAR2 DEFAULT 'Y',
                             p_notfound_allowed_flag VARCHAR2 DEFAULT 'Y') IS
--
cursor get_valid_route (c_route_id number) is
  select route_id
  from ff_routes
  where route_id = c_route_id;
--
cursor get_user_entity_id (c_user_entity_name varchar2) is
  select user_entity_id
  from ff_user_entities
  where user_entity_name = c_user_entity_name;
--
cursor get_route_parameter_id (c_route_id number) is
  select route_parameter_id
  from ff_route_parameters
  where parameter_name = 'User Entity ID'
  and route_id = c_route_id;
--

l_definition_text varchar2(240);
l_description varchar2(12) := 'Extract Item';
l_dummy number;
l_user_entity_id number;
l_route_parameter_id number;
--
BEGIN
   --
   -- Calculate which Definition Text to use based on the Data Type
   --
   if p_data_type = 'N' then
      l_definition_text := 'fnd_number.canonical_to_number(target.value)';
   elsif p_data_type = 'D' then
       l_definition_text := 'fnd_date.canonical_to_date(target.value)';
   else
       l_definition_text := 'target.value';
   end if;
   --
   -- Validate Route ID and ensure route parameter exists
   --
   open get_valid_route(p_route_id);
   fetch get_valid_route into l_dummy;
   if get_valid_route%NOTFOUND then
      RAISE NO_DATA_FOUND;
   end if;
   close get_valid_route;
   --
   open get_route_parameter_id(p_route_id);
   fetch get_route_parameter_id into l_route_parameter_id;
   if get_route_parameter_id%NOTFOUND then
      RAISE NO_DATA_FOUND;
   end if;
   close get_route_parameter_id;
   --
   -- Check to see if User entity exists
   --
   open get_user_entity_id (p_extract_item_name);
   fetch get_user_entity_id into l_user_entity_id;
   close get_user_entity_id;
   --
   IF l_user_entity_id is null then
     --
     -- Create a new User Entity and DBI, and Route Parameter Value.
     --
     BEGIN
     --
     select ff_user_entities_s.nextval into l_user_entity_id from dual;
     --
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
         p_legislation_code,
         p_route_id,
         p_notfound_allowed_flag,
         p_extract_item_name,
         0,
         'X',  -- SUBJECT TO CHECKING
         l_description,
         sysdate,
         0,
         0,
         0,
         sysdate
      );
      --
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
         l_route_parameter_id,
         l_user_entity_id,
         l_user_entity_id,
         sysdate,
         0,
         0,
         0,
         sysdate
      );
      --
     insert into ff_database_items
      (
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
         creation_date
      )
      values
      (
         p_extract_item_name,
         l_user_entity_id,
         p_data_type,
         l_definition_text,
         p_null_allowed_flag,
         l_description,
         sysdate,
         0,
         0,
         0,
         sysdate
      );
     END;
     --
  --
  -- NB cannot update ff_user_entities.
  --
  END IF;
--
end create_archive_dbi;
--
end pay_archive_utils;

/
