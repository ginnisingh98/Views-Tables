--------------------------------------------------------
--  DDL for Package Body PJM_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_INSTALL" as
/* $Header: PJMINSTB.pls 120.0.12010000.2 2009/10/20 22:06:14 huiwan ship $ */

---------------------------------------------
-- Global variables
---------------------------------------------
G_Installed         BOOLEAN := NULL;
G_Implemented       BOOLEAN := NULL;
G_Implemented_Org   NUMBER  := NULL;

---------------------------------------------
-- Private Functions
---------------------------------------------
function create_locator_segment (
          p_segment_num          number,
          p_segment_name         varchar2,
          p_column_name          varchar2,
          p_value_set_name       varchar2,
          p_default_type         varchar2,
          p_default_value        varchar2,
          p_qualifier            varchar2)
return boolean is

l_value_set_id          number := -1;
l_seg_value_set_id      number := -2;
l_flexfield             fnd_flex_key_api.flexfield_type;
l_new_flexfield         fnd_flex_key_api.flexfield_type;
l_structure             fnd_flex_key_api.structure_type;
l_new_segment           fnd_flex_key_api.segment_type;

begin
    select flex_value_set_id
    into   l_value_set_id
    from   fnd_flex_value_sets
    where  flex_value_set_name = p_value_set_name;

    begin
        select flex_value_set_id
        into   l_seg_value_set_id
        from   fnd_id_flex_segments
        where  application_id = 401
        and    id_flex_code = 'MTLL'
        and    id_flex_num = 101
        and    application_column_name = p_column_name;

        --
        -- Fixed bug 851461
        --
        -- Previous logic does not handle the case when Project
        -- Manufacturing is installed and the first Inventory Org
        -- is not setup as Project References Enabled.  In this case
        -- the code went ahead and tried to create the segment again,
        -- resulting in failure condition in the AOL Flex API.
        --
        if ( l_seg_value_set_id = l_value_set_id ) then
            --
            -- Segment already correctly defined
            --
            return(TRUE);
        end if;

        --
        -- In previous versions of this function, the following logic
        -- is placed after this sub-block.  It is now moved to this
        -- location which is more logical and in line with the fix
        -- for bug 851461
        --
        if ( l_seg_value_set_id <> l_value_set_id ) then
            --
            -- Segment already in use
            --
            fnd_message.set_name('PJM','INST-SEGMENT IN USE');
            fnd_message.set_token('SEGMENT',p_column_name);
            return(FALSE);
        end if;

    exception
        when no_data_found then
            null;
        when others then
            raise;
    end;

    --
    -- Make sure flexfield allows ID valuesets
    --
    fnd_flex_key_api.set_session_mode('seed_data');
    l_flexfield     := fnd_flex_key_api.find_flexfield('INV','MTLL');
    l_new_flexfield := l_flexfield;
    l_new_flexfield.allow_id_value_sets := 'Y';
    fnd_flex_key_api.modify_flexfield(l_flexfield, l_new_flexfield);

    --
    -- Creating Locator Flexfield Segment
    --
    l_flexfield   := fnd_flex_key_api.find_flexfield('INV','MTLL');
    l_structure   := fnd_flex_key_api.find_structure(l_flexfield,101);
    l_new_segment := fnd_flex_key_api.new_segment(
                     flexfield        => l_flexfield,
                     structure        => l_structure,
                     segment_name     => p_segment_name,
                     description      => p_segment_name,
                     column_name      => p_column_name,
                     segment_number   => p_segment_num,
                     enabled_flag     => 'Y',
                     displayed_flag   => 'Y',
                     indexed_flag     => 'N',
                     value_set        => p_value_set_name,
                     default_type     => p_default_type,
                     default_value    => p_default_value,
                     required_flag    => 'N',
                     security_flag    => 'N',
                     range_code       => NULL,
                     display_size     => 25,
                     description_size => 50,
                     concat_size      => 25,
                     lov_prompt       => p_segment_name,
                     window_prompt    => p_segment_name
                     );

    fnd_flex_key_api.add_segment(
                     flexfield => l_flexfield,
                     structure => l_structure,
                     segment   => l_new_segment
                     );

    fnd_flex_key_api.assign_qualifier(
                     flexfield           => l_flexfield,
                     structure           => l_structure,
                     segment             => l_new_segment,
                     flexfield_qualifier => p_qualifier,
                     enable_flag         => 'Y'
                     );

    --
    -- Deleting Compiled Flexfield information
    --
    -- delete from fnd_compiled_id_flexs
    -- where  application_id = 401
    -- and    id_flex_code   = 'MTLL';

    -- delete from fnd_compiled_id_flex_structs
    -- where  application_id = 401
    -- and    id_flex_code   = 'MTLL'
    -- and    id_flex_num    = 101;

    return(TRUE);

end create_locator_segment;


---------------------------------------------
-- Public Functions
---------------------------------------------
function CHECK_IMPLEMENTATION_STATUS
( P_Organization_ID  NUMBER
) return boolean is

cursor c is
  select organization_id
  from   pjm_org_parameters
  where  organization_id = P_organization_id;

cursor c2 is
  select organization_id
  from   pjm_org_parameters
  where  organization_id > 0;

dummy     number;

begin
  --
  -- PJM not implemented if not installed
  --
  if NOT check_install then
    return false;
  end if;

  if ( G_Implemented is null
     --
     -- Make sure cached value matches current inquiry
     --
     OR ( G_Implemented_Org <> P_Organization_ID )
     --
     -- Special case: no need to recache if cache value indicates PJM is already
     -- implemented in a specific org (NULL org means any org)
     --
     OR ( P_Organization_ID is null AND G_Implemented_Org <> 0 AND NOT G_Implemented )
     ) then
    if ( P_Organization_ID is not null ) then
      open c;
      fetch c into dummy;
      G_Implemented := NOT ( c%notfound );
      close c;
      G_Implemented_Org := P_Organization_ID;
    else
      open c2;
      fetch c2 into dummy;
      G_Implemented := NOT ( c2%notfound );
      close c2;
      G_Implemented_Org := 0;
    end if;
  end if;
  return G_Implemented;
exception
when others then
    return false;
end CHECK_IMPLEMENTATION_STATUS;


function CHECK_INSTALL
return boolean is
l_status            varchar2(1);
l_industry          varchar2(1);
l_ora_schema        varchar2(30);
l_return_code       boolean;
begin
  if ( G_Installed is NULL ) then
    --
    -- Call FND routine to figure out installation status
    --
    -- If the license status is not 'I', Project Manufacturing is
    -- not installed.
    --
    l_return_code := fnd_installation.get_app_info('PJM',
                                                   l_status,
                                                   l_industry,
                                                   l_ora_schema);

-- this is the old code which CHECK_INSTALL always return TRUE, comment out
 --    if (l_return_code = FALSE) then
   --     G_Installed := FALSE;
   -- end if;
    -- if (l_status <> 'I') then
      --  G_Installed := FALSE;
   --  end if;
    -- G_Installed := TRUE;
  -- end if;
 --  return G_Installed;

/* New code for fixing bug 8969284 */
    if (l_return_code = FALSE) then
        G_Installed := FALSE;
        return G_Installed;
    end if;

    if (l_status = 'I') then
      G_Installed := TRUE;
    else
      G_Installed := FALSE;
    end if;
  end if;
  return G_Installed;
/* end of bug 8969284 */

end CHECK_INSTALL;

function ENABLE_INSTALL
return boolean is
l_return_code       boolean;
l_orgcount          number;
l_segment_name      varchar2(30);
begin

    --
    -- If Project Manufacturing is not installed, immediately get out
    --
    if (not pjm_install.check_install) then
       return TRUE;
    end if;

    select count(*)
    into   l_orgcount
    from   pjm_org_parameters
    where  project_reference_enabled = 'Y'
    and    organization_id <> FND_PROFILE.VALUE('MFG_ORGANIZATION_ID');

    if (l_orgcount > 0) then
        --
        -- There are already project enabled orgs.  We don't need
        -- to do anything else
        --
        return(TRUE);
    end if;

    savepoint pre_insert;

    fnd_message.set_name('PA','PA_TKN_PRJ');
    l_segment_name := fnd_message.get;
    l_return_code := create_locator_segment(
           19,
           l_segment_name,
           'SEGMENT19',
           'PJM_PROJECT',
           'S',
           'select pjm_project_locator.Proj_Seg_Default from sys.dual',
           'PJM_PROJECT'
           );
    if (l_return_code = FALSE) then
        rollback to savepoint pre_insert;
        return(FALSE);
    end if;

    fnd_message.set_name('PA','PA_TKN_TSK');
    l_segment_name := fnd_message.get;
    l_return_code := create_locator_segment(
           20,
           l_segment_name,
           'SEGMENT20',
           'PJM_TASK',
           'S',
           'select pjm_project_locator.Task_Seg_Default from sys.dual',
           'PJM_TASK'
           );
    if (l_return_code = FALSE) then
        rollback to savepoint pre_insert;
        return(FALSE);
    end if;
    return(TRUE);

end enable_install;


procedure maintain_locator_valuesets is

--
-- Making this procedure as AUTONOMOUS transaction
--
-- pragma autonomous_transaction;

cursor c is
  select ou.oracle_username
  from   fnd_product_installations pi
  ,      fnd_oracle_userid ou
  where  ou.oracle_id = pi.oracle_id
  and    application_id = 0;

cursor c2 is
  select decode( min( seiban_number_flag ) , 1 , 'Y' , 'N' ) seiban_used
  ,      decode( max( seiban_number_flag ) , 2 , 'Y' , 'N' ) project_used
  from   pjm_project_parameters;

seiban_used      varchar2(1);
project_used     varchar2(1);
applsys_schema   varchar2(30);
target_name      varchar2(30);

  procedure create_synonym
  ( X_synonym_name  in  varchar2
  , X_table_name    in  varchar2
  ) is

  sqlstmt          varchar2(240);
  curr_table_name  varchar2(30);
  create_flag      varchar2(1);

  cursor s ( c_name varchar2 ) is
    select table_name
    from   user_synonyms
    where  synonym_name = c_name;

  begin
    --
    -- Check with existence of synonym first
    --
    open s ( X_synonym_name );
    fetch s into curr_table_name;
    if ( s%notfound ) then
      --
      -- If synonym not found, we need to create it
      --
      close s;
      --
      -- Drop the view just in case
      --
      ad_ddl.do_ddl( applsys_schema
                   , 'PJM'
                   , ad_ddl.drop_view
                   , 'DROP VIEW ' || X_synonym_name
                   , X_synonym_name );

      create_flag := 'Y';
    else
      close s;
      if ( curr_table_name <> X_table_name ) then
        --
        -- Synonym exists but points to a different object.  We need to drop
        -- the existing synonym first before recreating the new one
        --
        ad_ddl.do_ddl( applsys_schema
                     , 'PJM'
                     , ad_ddl.drop_synonym
                     , 'DROP SYNONYM ' || X_synonym_name
                     , X_synonym_name );
        create_flag := 'Y';
      else
        --
        -- Existing synonym is what we want, no need to do anything
        --
        create_flag := 'N';
      end if;
    end if;
    if ( create_flag = 'Y' ) then
      sqlstmt := 'CREATE SYNONYM ' || X_synonym_name || ' FOR ' || X_table_name;
      ad_ddl.do_ddl( applsys_schema
                   , 'PJM'
                   , ad_ddl.create_synonym
                   , sqlstmt
                   , X_synonym_name );
    end if;
  end create_synonym;

begin

  open c;
  fetch c into applsys_schema;
  close c;

  open c2;
  fetch c2 into seiban_used , project_used;
  close c2;

  if ( project_used = 'Y' and seiban_used = 'Y' ) then
    target_name := 'PJM_PROJECTS_MTLL_PSV';
  elsif ( project_used = 'Y' ) then
    target_name := 'PJM_PROJECTS_MTLL_PV';
  else
    target_name := 'PJM_PROJECTS_MTLL_SV';
  end if;

  create_synonym( 'PJM_PROJECTS_MTLL_V' , target_name );

end maintain_locator_valuesets;

end PJM_INSTALL;

/
