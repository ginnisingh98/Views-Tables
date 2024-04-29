--------------------------------------------------------
--  DDL for Package Body PAY_MX_ARCHIVE_DBI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_ARCHIVE_DBI_PKG" AS
/* $Header: pymxarchdbipkg.pkb 120.0 2005/09/29 13:59:54 vmehta noship $ */

-------------------------------------------------------------------------
-- This procedure creates the archive routes needed by the
-- create_archive_dbi procedure
-------------------------------------------------------------------------
PROCEDURE create_archive_routes IS

   l_text                         LONG;
   l_gre_context_id               NUMBER;
   l_assignment_action_context_id NUMBER;
   l_exists                       VARCHAR2(1);

BEGIN

   -- Find the Context ID's
   SELECT context_id
   INTO   l_assignment_action_context_id
   FROM   ff_contexts
   WHERE  context_name = 'ASSIGNMENT_ACTION_ID';

   SELECT context_id
   INTO   l_gre_context_id
   FROM   ff_contexts
   WHERE  context_name = 'TAX_UNIT_ID';

   -------------------------------------------------------------------------
   -- Define the Balances archive route
   -------------------------------------------------------------------------
   BEGIN

      l_text :=
'      ff_archive_items         target,
       ff_archive_item_contexts fac
where  target.user_entity_id = &U1
and    target.context1       = &B1 /* context assignment action id */
and    fac.archive_item_id   = target.archive_item_id
and    fac.context           = &B2 /* 2nd context of tax_unit_id */';

      SELECT 'Y'
      INTO   l_exists
      FROM   ff_routes
      WHERE  route_name = 'MX_BALANCES_ARCHIVE_ROUTE';

      UPDATE ff_routes
      SET    text       = l_text
      WHERE  route_name = 'MX_BALANCES_ARCHIVE_ROUTE';

   EXCEPTION WHEN NO_DATA_FOUND THEN

      INSERT INTO ff_routes
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
      VALUES
      (
         ff_routes_s.NEXTVAL,
         'MX_BALANCES_ARCHIVE_ROUTE',
         'N',
         'MX Year End Balances Archive Route',
         l_text,
         SYSDATE,
         0,
         0,
         0,
         SYSDATE
      );

      -- Define the route parameter
      INSERT INTO ff_route_parameters
      (
         route_parameter_id,
         route_id,
         data_type,
         parameter_name,
         sequence_no
      )
      SELECT ff_route_parameters_s.NEXTVAL,
             ff_routes_s.CURRVAL,
             'N',
             'User Entity ID',
             1
      FROM   dual;

      -- Define the route context usage
      INSERT INTO ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      SELECT ff_routes_s.CURRVAL,
             l_assignment_action_context_id,
             1
      FROM   dual;

      INSERT INTO ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      SELECT ff_routes_s.CURRVAL,
             l_gre_context_id,
             2
      from   dual;

   END;


END create_archive_routes;

-------------------------------------------------------------------------
-- This procedure creates an archive database item, for the live database
-- item that is passed as a parameter
-- Note: p_item_name should be A_ and then the name of the live database
--       item
-------------------------------------------------------------------------
PROCEDURE create_archive_dbi(p_item_name VARCHAR2) is

-- Find the attributes from the live database item and create an
-- arcive version of it

l_dbi_null_allowed_flag      VARCHAR2(1);
l_dbi_description            VARCHAR2(240);
l_dbi_data_type              VARCHAR2(1);
l_dbi_user_name              VARCHAR2(240);
l_ue_notfound_allowed_flag   VARCHAR2(1);
l_ue_creator_type            VARCHAR2(30);
l_ue_entity_description      VARCHAR2(240);
l_user_entity_seq            NUMBER;
l_user_entity_id             NUMBER;
l_route_parameter_id         NUMBER;
l_dummy_id                   NUMBER;
l_route_id                   NUMBER;
l_live_route_id              NUMBER;
l_balances_route             NUMBER;
l_definition_text            VARCHAR2(240);

BEGIN

   BEGIN

      -- Check whether the MX database item exists
      SELECT ue.notfound_allowed_flag,
             ue.creator_type,
             ue.entity_description,
             ue.route_id,
             dbi.null_allowed_flag,
             dbi.description ,
             dbi.data_type,
             dbi.user_name
      INTO   l_ue_notfound_allowed_flag,
             l_ue_creator_type,
             l_ue_entity_description,
             l_live_route_id,
             l_dbi_null_allowed_flag,
             l_dbi_description,
             l_dbi_data_type,
             l_dbi_user_name
      FROM   ff_database_items dbi,
             ff_user_entities  ue
      WHERE  dbi.user_name    = SUBSTR(p_item_name, 3, LENGTH(p_item_name) - 2)
      AND    dbi.user_entity_id   = ue.user_entity_id
      AND    ue.legislation_code  = 'MX'
      AND    ue.business_group_id IS NULL;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         -- Check whether the core database item exists
         SELECT ue.notfound_allowed_flag,
                ue.creator_type,
                ue.entity_description,
                ue.route_id,
                dbi.null_allowed_flag,
                dbi.description,
                dbi.data_type,
                dbi.user_name
         INTO   l_ue_notfound_allowed_flag,
                l_ue_creator_type,
                l_ue_entity_description,
                l_live_route_id,
                l_dbi_null_allowed_flag,
                l_dbi_description,
                l_dbi_data_type,
                l_dbi_user_name
         FROM   ff_database_items dbi,
                ff_user_entities  ue
         WHERE  dbi.user_name  = SUBSTR(p_item_name, 3, LENGTH(p_item_name) - 2)
         AND    dbi.user_entity_id   = ue.user_entity_id
         AND    ue.legislation_code  IS NULL
         AND    ue.business_group_id IS NULL;

   END;

/*   SELECT route_id
   INTO   l_number_archive_route_id
   FROM   ff_routes
   WHERE  route_name = 'MX_NUMBER_ARCHIVE_ROUTE';

   SELECT route_id
   INTO   l_date_archive_route_id
   FROM   ff_routes
   WHERE  route_name = 'MX_DATE_ARCHIVE_ROUTE';

   SELECT route_id
   INTO   l_character_archive_route_id
   FROM   ff_routes
   WHERE  route_name = 'MX_CHARACTER_ARCHIVE_ROUTE';
*/
   SELECT route_id
   INTO   l_balances_route
   FROM   ff_routes
   WHERE  route_name = 'MX_BALANCES_ARCHIVE_ROUTE';

   -- Choose the archive route, based on the live db item's data type
   IF l_dbi_data_type = 'N' THEN

        l_definition_text := 'to_number(target.value)';
        l_route_id        := l_balances_route;

   END IF;

   -- Find the User Entity Route parameter that goes with the archive route
   SELECT route_parameter_id
   INTO   l_route_parameter_id
   FROM   ff_route_parameters
   WHERE  parameter_name = 'User Entity ID'
   AND    route_id       = l_route_id;

   BEGIN

      -- Check to see if the archive database item already exist
      SELECT user_entity_id
      INTO   l_user_entity_seq
      FROM   ff_user_entities
      WHERE  user_entity_name  = p_item_name
      AND    legislation_code  = 'MX'
      AND    business_group_id IS NULL;

-- Commented because FF_USER_ENTITIES_BRU doesn't allow update
--
--      UPDATE ff_user_entities
--      SET    route_id              = l_route_id,
--             notfound_allowed_flag = 'Y',   -- l_ue_notfound_allowed_flag,
--             entity_description    = SUBSTR('Archive of ' ||
--                                             l_ue_entity_description, 1, 240)
--      WHERE  user_entity_name      = p_item_name
--      AND    legislation_code      = 'MX'
--      AND    business_group_id     IS NULL;

      BEGIN

         SELECT route_parameter_id
         INTO   l_dummy_id
         FROM   ff_route_parameter_values
         WHERE  route_parameter_id = l_route_parameter_id
         AND    user_entity_id     = l_user_entity_seq;

         UPDATE ff_route_parameter_values
         SET    value              = l_user_entity_seq
         WHERE  route_parameter_id = l_route_parameter_id
         AND    user_entity_id     = l_user_entity_seq;

      EXCEPTION WHEN NO_DATA_FOUND THEN

         INSERT INTO ff_route_parameter_values
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
         VALUES
         (
            l_route_parameter_id,
            l_user_entity_seq,
            l_user_entity_seq,
            SYSDATE,
            0,
            0,
            0,
            SYSDATE
         );

      END;

      UPDATE ff_database_items
      SET    user_entity_id    = l_user_entity_seq,
             data_type         = l_dbi_data_type,
             definition_text   = l_definition_text,
             null_allowed_flag = 'Y',   -- l_dbi_null_allowed_flag,
             description       = SUBSTR('Archive of item ' ||
                                        l_dbi_description, 1, 240)
      WHERE  user_name         = p_item_name;

   EXCEPTION WHEN NO_DATA_FOUND THEN

      -- Create the archive database item
      SELECT ff_user_entities_s.NEXTVAL
      INTO   l_user_entity_seq
      FROM   dual;

      INSERT INTO ff_user_entities
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
      VALUES
      (
         l_user_entity_seq,                      -- user_entity_id
         NULL,                                   -- business_group_id
         'MX',                                   -- legislation_code
         l_route_id,                             -- route_id
         'Y',                                    -- l_ue_notfound_allowed_flag,
         p_item_name,                            -- user_entity_name
         0,                                      -- creator_id
         'X',                                    -- archive extract creator_type
         SUBSTR('Archive of ' ||
                l_ue_entity_description, 1, 240),-- entity_description
         SYSDATE,                                -- last_update_date
         0,                                      -- last_updated_by
         0,                                      -- last_update_login
         0,                                      -- created_by
         SYSDATE                                 -- creation_date
      );

      INSERT INTO ff_route_parameter_values
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
      VALUES
      (
         l_route_parameter_id,
         l_user_entity_seq,
         l_user_entity_seq,
         SYSDATE,
         0,
         0,
         0,
         SYSDATE
      );

      INSERT INTO ff_database_items
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
      VALUES
      (
         p_item_name,
         l_user_entity_seq,
         l_dbi_data_type,
         l_definition_text,
         'Y',   -- l_dbi_null_allowed_flag,
         SUBSTR('Archive of item ' || l_dbi_description, 1, 240),
         SYSDATE,
         0,
         0,
         0,
         SYSDATE
      );

   END;

END create_archive_dbi;

END pay_mx_archive_dbi_pkg;

/
