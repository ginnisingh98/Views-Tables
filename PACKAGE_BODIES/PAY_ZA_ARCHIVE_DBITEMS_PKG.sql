--------------------------------------------------------
--  DDL for Package Body PAY_ZA_ARCHIVE_DBITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_ARCHIVE_DBITEMS_PKG" as
/* $Header: pyzaadbi.pkb 120.7 2006/02/15 04:10:33 divicker noship $ */

-------------------------------------------------------------------------
-- This procedure creates the archive routes needed by the
-- create_archive_dbi procedure
-------------------------------------------------------------------------
procedure create_archive_routes is

   l_text                         long;
   l_source_context_id            number;
   l_source_text_context_id       number;
   l_assignment_action_context_id number;
   l_source_number_context_id     number;
   l_exists                       varchar2(1);

begin

   -- Find the Context ID's
   select context_id
   into   l_assignment_action_context_id
   from   ff_contexts
   where  context_name = 'ASSIGNMENT_ACTION_ID';

   select context_id
   into   l_source_context_id
   from   ff_contexts
   where  context_name = 'SOURCE_ID';

   select context_id
   into   l_source_text_context_id
   from   ff_contexts
   where  context_name = 'SOURCE_TEXT';

   select context_id
   into   l_source_number_context_id
   from   ff_contexts
   where  context_name = 'SOURCE_NUMBER';

   -------------------------------------------------------------------------
   -- Define the number archive route
   -------------------------------------------------------------------------
   begin

      l_text :=
'       ff_archive_items target
where  target.user_entity_id = &U1
and    target.context1       = &B1 /* context assignment action id */';

      select 'y'
      into   l_exists
      from   ff_routes
      where  route_name = 'ZA_NUMBER_ARCHIVE_ROUTE';

      update ff_routes
      set    text       = l_text
      where  route_name = 'ZA_NUMBER_ARCHIVE_ROUTE';

   exception when no_data_found then

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
         'ZA_NUMBER_ARCHIVE_ROUTE',
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
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1
      from   dual;

      -- Define the route context usage
      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select ff_routes_s.currval,
             l_assignment_action_context_id,
             1
      from   dual;

   end;

   -------------------------------------------------------------------------
   -- Define the date archive route
   -------------------------------------------------------------------------
   begin

      l_text :=
'       ff_archive_items target
where  target.user_entity_id = &U1
and    target.context1       = &B1 /* context assignment action id */';

      select 'y'
      into   l_exists
      from   ff_routes
      where  route_name = 'ZA_DATE_ARCHIVE_ROUTE';

      update ff_routes
      set    text       = l_text
      where  route_name = 'ZA_DATE_ARCHIVE_ROUTE';

   exception when no_data_found then

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
         'ZA_DATE_ARCHIVE_ROUTE',
         'N',
         'Generic date archive route',
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
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1
      from   dual;

      -- Define the route context usage
      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select ff_routes_s.currval,
             l_assignment_action_context_id,
             1
      from   dual;

   end;

   -------------------------------------------------------------------------
   -- Define the character archive route
   -------------------------------------------------------------------------
   begin

      l_text :=
'       ff_archive_items target
where  target.user_entity_id = &U1
and    target.context1       = &B1 /* context assignment action id */';

      select 'y'
      into   l_exists
      from   ff_routes
      where  route_name = 'ZA_CHARACTER_ARCHIVE_ROUTE';

      update ff_routes
      set    text       = l_text
      where  route_name = 'ZA_CHARACTER_ARCHIVE_ROUTE';

   exception when no_data_found then

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
         'ZA_CHARACTER_ARCHIVE_ROUTE',
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
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1
      from   dual;

      -- Define the route context usage
      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select ff_routes_s.currval,
             l_assignment_action_context_id,
             1
      from   dual;

   end;

   -------------------------------------------------------------------------
   -- Define the Deductions archive route
   -------------------------------------------------------------------------
   begin

      l_text :=
'       ff_archive_items         target,
       ff_archive_item_contexts fac,
       ff_archive_item_contexts fac1
where  target.user_entity_id = &U1
and    target.context1       = &B1 /* context assignment action id */
and    fac.archive_item_id   = target.archive_item_id
and    fac.context           = to_char(&B2) /* 2nd context of source_id (SARS code) */
and    fac1.archive_item_id  = target.archive_item_id
and    fac1.context          = &B3 /* 3rd context of clearance no */';

      select 'y'
      into   l_exists
      from   ff_routes
      where  route_name = 'ZA_IRP5_DEDUCTIONS_ARCHIVE_ROUTE';

      update ff_routes
      set    text       = l_text
      where  route_name = 'ZA_IRP5_DEDUCTIONS_ARCHIVE_ROUTE';

   exception when no_data_found then

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
         'ZA_IRP5_DEDUCTIONS_ARCHIVE_ROUTE',
         'N',
         'IRP5 Deductions archive route',
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
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1
      from   dual;

      -- Define the route context usage
      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select ff_routes_s.currval,
             l_assignment_action_context_id,
             1
      from   dual;

      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select ff_routes_s.currval,
             l_source_context_id,
             2
      from   dual;

      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select ff_routes_s.currval,
             l_source_text_context_id,
             3
      from   dual;

   end;

   -------------------------------------------------------------------------
   -- Define the 4001_4003 archive route
   -------------------------------------------------------------------------
   begin

      l_text :=
'       ff_archive_items         target,
       ff_archive_item_contexts fac
where  target.user_entity_id = &U1
and    target.context1       = &B1 /* context assignment action id */
and    fac.archive_item_id   = target.archive_item_id
and    fac.context           = &B2 /* 2nd context of clearance no */';

      select 'y'
      into   l_exists
      from   ff_routes
      where  route_name = 'ZA_IRP5_4001_4003_ARCHIVE_ROUTE';

      update ff_routes
      set    text       = l_text
      where  route_name = 'ZA_IRP5_4001_4003_ARCHIVE_ROUTE';

   exception when no_data_found then

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
         'ZA_IRP5_4001_4003_ARCHIVE_ROUTE',
         'N',
         'IRP5 4001 to 4003 archive route',
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
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1
      from   dual;

      -- Define the route context usage
      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select ff_routes_s.currval,
             l_assignment_action_context_id,
             1
      from   dual;

      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select ff_routes_s.currval,
             l_source_text_context_id,
             2
      from   dual;

   end;

      -------------------------------------------------------------------------
   -- Define the LMPSM number archive route with Source_Text context
   -------------------------------------------------------------------------
   begin

 l_text :=
      ' ff_archive_items target,
      ff_archive_item_contexts faic,
      ff_contexts              fc
      where  target.user_entity_id = &U1
      and    target.context1       = &B1 /* context assignment action id */
      And    target.archive_item_id = faic.archive_item_id
      and  fc.context_name = ''SOURCE_TEXT''
      and  faic.context_id = fc.context_id
      AND  faic.CONTEXT = &B2 /* context SOURCE_TEXT for lump sums */';

      select 'y'
      into   l_exists
      from   ff_routes
      where  route_name = 'ZA_LMPSM_ARCHIVE_ROUTE';

      update ff_routes
      set    text       = l_text
      where  route_name = 'ZA_LMPSM_ARCHIVE_ROUTE';

   exception when no_data_found then

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
         'ZA_LMPSM_ARCHIVE_ROUTE',
         'N',
         'Generic number archive route with SOURCE_TEXT context',
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
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1
      from   dual;

      -- Define the route context usage
      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select ff_routes_s.currval,
             l_assignment_action_context_id,
             1
      from   dual;

      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select ff_routes_s.currval,
             l_source_text_context_id,
             2
      from   dual;

   end;

   -------------------------------------------------------------------------
   -- Define the CLRNO number archive route with Source_Number context
   -------------------------------------------------------------------------
   begin

 l_text :=
      ' ff_archive_items target,
      ff_archive_item_contexts faic,
      ff_contexts              fc
      where  target.user_entity_id = &U1
      and    target.context1       = &B1 /* context assignment action id */
      And    target.ARCHIVE_ITEM_ID = faic.ARCHIVE_ITEM_ID
      and  fc.context_name = ''SOURCE_NUMBER''
      and  faic.context_id = fc.context_id
      AND  faic.CONTEXT = TO_CHAR(&B2) /* context SOURCE_NUMBER for Clearance Number */';

      select 'y'
      into   l_exists
      from   ff_routes
      where  route_name = 'ZA_CLRNO_ARCHIVE_ROUTE';

      update ff_routes
      set    text       = l_text
      where  route_name = 'ZA_CLRNO_ARCHIVE_ROUTE';

   exception when no_data_found then

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
         'ZA_CLRNO_ARCHIVE_ROUTE',
         'N',
         'Generic number archive route with SOURCE_NUMBER context',
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
      select ff_route_parameters_s.nextval,
             ff_routes_s.currval,
             'N',
             'User Entity ID',
             1
      from   dual;

      -- Define the route context usage
      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select ff_routes_s.currval,
             l_assignment_action_context_id,
             1
      from   dual;

      insert into ff_route_context_usages
      (
         route_id,
         context_id,
         sequence_no
      )
      select ff_routes_s.currval,
             l_source_number_context_id,
             2
      from   dual;

   end;

--End Added for balance feed Enhancement and Context balance functionality


end create_archive_routes;

-------------------------------------------------------------------------
-- This procedure creates an archive database item, for the live database
-- item that is passed as a parameter
-- Note: p_item_name should be A_ and then the name of the live database
--       item
-------------------------------------------------------------------------
procedure create_archive_dbi(p_item_name varchar2) is

-- Find the attributes from the live database item and create an
-- arcive version of it

l_dbi_null_allowed_flag      varchar2(1);
l_dbi_description            varchar2(240);
l_dbi_data_type              varchar2(1);
l_dbi_user_name              varchar(240);
l_ue_notfound_allowed_flag   varchar2(1);
l_ue_creator_type            varchar2(30);
l_ue_entity_description      varchar2(240);
l_user_entity_seq            number;
l_user_entity_id             number;
l_route_parameter_id         number;
l_dummy_id                   number;
l_route_id                   number;
l_live_route_id              number;
l_character_archive_route_id number;
l_number_archive_route_id    number;
l_date_archive_route_id      number;
l_irp5_deductions_route      number;
l_4001_4003_archive_route_id number;
l_lmpsm_archive_route_id     number;
l_clrno_archive_route_id     number;
l_old_route_id               number;
l_definition_text            varchar2(240);

type t_number_tbl is table of number index by binary_integer;
l_fast_formula_id_tbl            t_number_tbl;

begin

   begin

   SELECT formula_id
   BULK COLLECT INTO l_fast_formula_id_tbl
   FROM  ff_fdi_usages_f
   WHERE item_name = p_item_name
   AND   usage = 'D';

   FOR i IN 1..l_fast_formula_id_tbl.count
   LOOP
      DELETE
      FROM  ff_compiled_info_f
      WHERE formula_id = l_fast_formula_id_tbl(i);
   END LOOP;

   delete from ff_fdi_usages_f
   where item_name = p_item_name
   and   usage = 'D';

      -- Check whether the ZA database item exists
      select ue.notfound_allowed_flag,
             ue.creator_type,
             ue.entity_description,
             ue.route_id,
             dbi.null_allowed_flag,
             dbi.description ,
             dbi.data_type,
             dbi.user_name
      into   l_ue_notfound_allowed_flag,
             l_ue_creator_type,
             l_ue_entity_description,
             l_live_route_id,
             l_dbi_null_allowed_flag,
             l_dbi_description,
             l_dbi_data_type,
             l_dbi_user_name
      from   ff_database_items dbi,
             ff_user_entities  ue
      where  dbi.user_name        = substr(p_item_name, 3, length(p_item_name) - 2)
      and    dbi.user_entity_id   = ue.user_entity_id
      and    ue.legislation_code  = 'ZA'
      and    ue.business_group_id is null;

   exception
      when no_data_found then
         -- Check whether the core database item exists
         select ue.notfound_allowed_flag,
                ue.creator_type,
                ue.entity_description,
                ue.route_id,
                dbi.null_allowed_flag,
                dbi.description,
                dbi.data_type,
                dbi.user_name
         into   l_ue_notfound_allowed_flag,
                l_ue_creator_type,
                l_ue_entity_description,
                l_live_route_id,
                l_dbi_null_allowed_flag,
                l_dbi_description,
                l_dbi_data_type,
                l_dbi_user_name
         from   ff_database_items dbi,
                ff_user_entities  ue
         where  dbi.user_name        = substr(p_item_name, 3, length(p_item_name) - 2)
         and    dbi.user_entity_id   = ue.user_entity_id
         and    ue.legislation_code  is null
         and    ue.business_group_id is null;

   end;

   select route_id
   into   l_number_archive_route_id
   from   ff_routes
   where  route_name = 'ZA_NUMBER_ARCHIVE_ROUTE';

   select route_id
   into   l_date_archive_route_id
   from   ff_routes
   where  route_name = 'ZA_DATE_ARCHIVE_ROUTE';

   select route_id
   into   l_character_archive_route_id
   from   ff_routes
   where  route_name = 'ZA_CHARACTER_ARCHIVE_ROUTE';

   select route_id
   into   l_irp5_deductions_route
   from   ff_routes
   where  route_name = 'ZA_IRP5_DEDUCTIONS_ARCHIVE_ROUTE';

   select route_id
   into   l_4001_4003_archive_route_id
   from   ff_routes
   where  route_name = 'ZA_IRP5_4001_4003_ARCHIVE_ROUTE';

   select route_id
   into   l_lmpsm_archive_route_id
   from   ff_routes
   where  route_name = 'ZA_LMPSM_ARCHIVE_ROUTE';

   select route_id
   into   l_clrno_archive_route_id
   from   ff_routes
   where  route_name = 'ZA_CLRNO_ARCHIVE_ROUTE';

   -- Choose the archive route, based on the live db item's data type
   if l_dbi_data_type = 'N' then

     if l_dbi_user_name = 'ZA_IRP5_DEDUCTIONS' then

        l_definition_text := 'to_number(target.value)';
        l_route_id        := l_irp5_deductions_route;

     elsif l_dbi_user_name in
        (
           'ZA_IRP5_CUR_PENSION',
           'ZA_IRP5_ANN_PENSION',
           'ZA_IRP5_ARR_PENSION',
           'ZA_IRP5_CUR_PROVIDENT',
           'ZA_IRP5_ANN_PROVIDENT'
        )  then

        l_definition_text := 'to_number(target.value)';
        l_route_id        := l_4001_4003_archive_route_id;

     elsif instr(l_dbi_user_name,'_ASG_LMPSM_',1) > 0 Then
        l_definition_text := 'to_number(target.value)';
        l_route_id        := l_lmpsm_archive_route_id;


     elsif instr(l_dbi_user_name,'_ASG_CLRNO_',1) > 0 Then
        l_definition_text := 'to_number(target.value)';
        l_route_id        := l_clrno_archive_route_id;

     else

        l_definition_text := 'to_number(target.value)';
        l_route_id        := l_number_archive_route_id;

     end if;

   elsif l_dbi_data_type = 'D' then

      l_definition_text := 'fnd_date.canonical_to_date(target.value)';
      l_route_id        := l_date_archive_route_id;

   else

      l_definition_text := 'target.value';
      l_route_id        := l_character_archive_route_id;

   end if;

   -- Find the User Entity Route parameter that goes with the archive route
   select route_parameter_id
   into   l_route_parameter_id
   from   ff_route_parameters
   where  parameter_name = 'User Entity ID'
   and    route_id       = l_route_id;

   begin

      -- Check to see if the archive database item already exist
      select user_entity_id, route_id
      into   l_user_entity_seq, l_old_route_id
      from   ff_user_entities
      where  user_entity_name  = p_item_name
      and    legislation_code  = 'ZA'
      and    business_group_id is null;

     IF l_old_route_id <> l_route_id then
          DELETE FROM ff_route_parameter_values
            where user_entity_id     = l_user_entity_seq
            AND route_parameter_id <> l_route_parameter_id;

     END if;

      update ff_user_entities
      set    route_id              = l_route_id,
             notfound_allowed_flag = 'Y',   -- l_ue_notfound_allowed_flag,
             entity_description    = substr('Archive of ' || l_ue_entity_description, 1, 240)
      where  user_entity_name      = p_item_name
      and    legislation_code      = 'ZA'
      and    business_group_id     is null;

      begin

         select route_parameter_id
         into   l_dummy_id
         from   ff_route_parameter_values
         where  route_parameter_id = l_route_parameter_id
         and    user_entity_id     = l_user_entity_seq;

         update ff_route_parameter_values
         set    value              = l_user_entity_seq
         where  route_parameter_id = l_route_parameter_id
         and    user_entity_id     = l_user_entity_seq;

      exception when no_data_found then

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
      set    user_entity_id    = l_user_entity_seq,
             data_type         = l_dbi_data_type,
             definition_text   = l_definition_text,
             null_allowed_flag = 'Y',   -- l_dbi_null_allowed_flag,
             description       = substr('Archive of item ' || l_dbi_description, 1, 240)
      where  user_name         = p_item_name;

   exception when no_data_found then

      -- Create the archive database item
      select ff_user_entities_s.nextval
      into   l_user_entity_seq
      from   dual;

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
         l_user_entity_seq,                                          -- user_entity_id
         null,                                                       -- business_group_id
         'ZA',                                                       -- legislation_code
         l_route_id,                                                 -- route_id
         'Y',   -- l_ue_notfound_allowed_flag,                       -- notfound_allowed_flag
         p_item_name,                                                -- user_entity_name
         0,                                                          -- creator_id
         'X',                                                        -- archive extract creator_type
         substr('Archive of ' || l_ue_entity_description, 1, 240),   -- entity_description
         sysdate,                                                    -- last_update_date
         0,                                                          -- last_updated_by
         0,                                                          -- last_update_login
         0,                                                          -- created_by
         sysdate                                                     -- creation_date
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
         p_item_name,
         l_user_entity_seq,
         l_dbi_data_type,
         l_definition_text,
         'Y',   -- l_dbi_null_allowed_flag,
         substr('Archive of item ' || l_dbi_description, 1, 240),
         sysdate,
         0,
         0,
         0,
         sysdate
      );

   end;

end create_archive_dbi;

end pay_za_archive_dbitems_pkg;

/
