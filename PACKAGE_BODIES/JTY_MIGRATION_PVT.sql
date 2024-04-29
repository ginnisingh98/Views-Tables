--------------------------------------------------------
--  DDL for Package Body JTY_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_MIGRATION_PVT" AS
/* $Header: jtftrmgb.pls 120.6 2006/07/24 19:11:55 solin noship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_MIGRATION_PVT
--    PURPOSE
--
--      Procedures:
--         (see below for specification)
--         This package covers migration of territory data
--
--         The various procedures are for
--          1. Territory Template Migration (add_seeded_territory_types) :
--             This procedure will create the
--             default templates for all the usages and for all the
--             existing organizations and also the Named account territory
--             template with territory type id -1
--          2. Assign territory templates to existing territories (update_terr_type_for_terr) :
--             For the territories where the territory_type_id is null,
--             this procedure will assign default territory template or
--             named account territory template accordingly.
--          3. Migrate the territory end-dates (update_terr_enddate_active) :
--             This procedure will update the territory and resource end_date_active
--             to start_date_active + 10 years
--          4. update the self-service flag (update_self_service_flag) :
--             This procedure will update the self-service flag for exiting geography
--             and Named account territories
--          5. Migration of escalation territories
--          6. Update the access at the transaction type level
--             for every resource. Until 11.5.10 this was set at resource level
--          7. Need to update party_site_id in JTF_TTY_NAMED_ACCTS for existing NAs.
--
--    NOTES
--
--
--    HISTORY
--      08/08/05    JRADHAKR         CREATED
--      01/10/06    ACHANDA          Fix bug # 4886227
--
--    End of Comments
--

--  This procedure will update the enabled_flag to 'Y' for all
--  active extisting templates.
--  In 11.5.10, the enabled_flag column was not used.

Procedure enable_existing_template
IS

BEGIN

  update jtf_terr_types_all
  set enabled_flag = 'Y'
  where sysdate between start_date_active and nvl(end_date_active, sysdate);

  commit;

EXCEPTION
   when FND_API.G_EXC_ERROR then
    -- Add proper error logging
    -- dbms_output.put_line('1 ' || sqlerrm );
    NULL;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
    -- Add proper error logging
    -- dbms_output.put_line('2 ' || sqlerrm );
    NULL;
   when others then
    -- Add proper error logging
    -- dbms_output.put_line('3 ' || sqlerrm );
    NULL;
END enable_existing_template;



--  This procedure will update the access at the transaction type level
--  for every resource. Until 11.5.10 this was set at resource level.

/* this is replaced by the script jtftjtra.sql */
/*
Procedure update_rsc_access
IS

BEGIN

  update jtf_terr_rsc_access_all jtra
  set jtra.trans_access_code = (
    select decode(jtr1.full_access_flag,'Y','FULL_ACCESS','VIEW')
    from jtf_terr_rsc_all jtr1
    where jtr1.TERR_RSC_ID = jtra.terr_rsc_id)
  where jtra.terr_rsc_id in
         (select jtr2.terr_rsc_id
            from jtf_terr_rsc_all jtr2
               , jtf_terr_usgs_all jtu
            where jtr2.terr_id = jtu.terr_id
              and jtu.source_id = -1001)
   and jtra.trans_access_code is null;


  update jtf_terr_rsc_access_all jtra
  set jtra.trans_access_code = (
    select decode(jtr1.primary_contact_flag,'Y','TEAM_LEADER','DEFAULT')
    from jtf_terr_rsc_all jtr1
    where jtr1.TERR_RSC_ID = jtra.terr_rsc_id)
  where jtra.terr_rsc_id in
         (select jtr2.terr_rsc_id
            from jtf_terr_rsc_all jtr2
               , jtf_terr_usgs_all jtu
            where jtr2.terr_id = jtu.terr_id
              and jtu.source_id = -1002)
   and jtra.trans_access_code is null;


  update jtf_terr_rsc_access_all jtra
  set jtra.trans_access_code = (
    select decode(jtr1.primary_contact_flag,'Y','PRIMARY_CONTACT','DEFAULT')
    from jtf_terr_rsc_all jtr1
    where jtr1.TERR_RSC_ID = jtra.terr_rsc_id)
  where jtra.terr_rsc_id in
         (select jtr2.terr_rsc_id
            from jtf_terr_rsc_all jtr2
               , jtf_terr_usgs_all jtu
            where jtr2.terr_id = jtu.terr_id
              and jtu.source_id = -1003)
   and jtra.trans_access_code is null;


  update jtf_terr_rsc_access_all jtra
  set jtra.trans_access_code = 'DEFAULT'
   where  jtra.trans_access_code is null;

  commit;

EXCEPTION
   when FND_API.G_EXC_ERROR then
    NULL;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
    NULL;

   when others then
    NULL;
END update_rsc_access;
*/

--  This procedure will update the territory and resource end_date_active
--  to start_date_active + 10 years

/* replaced by the script jtftterr.sql(jtf_terr_all) and jtftjtrr.sql(jtf_terr_rsc_all) */
/*
Procedure update_terr_enddate_active
IS

BEGIN

  Update jtf_terr_all jterr
  set jterr.end_date_active = jterr.start_date_active  + 3652
  where jterr.end_date_active is null;

  Update jtf_terr_rsc_all jtr
  set jtr.end_date_active = jtr.start_date_active  + 3652
  where jtr.end_date_active is null;

  commit;

EXCEPTION
   when FND_API.G_EXC_ERROR then
    NULL;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
    NULL;
   when others then
    NULL;
END update_terr_enddate_active;
*/

-- This procedure will update the self-service flag for exiting geography
-- and Named account territories

/* replaced by the script jtftterr.sql */
/*
Procedure update_self_service_flag
IS

BEGIN

  Update jtf_terr_all jtabs
  set enable_self_service = 'Y'
  where (GEO_TERR_FLAG = 'Y' or NAMED_ACCOUNT_FLAG = 'Y')
         and enable_self_service is null;

  commit;

EXCEPTION
   when FND_API.G_EXC_ERROR then
    NULL;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
    NULL;
   when others then
    NULL;
END update_self_service_flag;
*/


-- For the territories where the territory_type_id is null,
-- this procedure will assign default territory template or
-- named account territory template accordingly.

/* replaced by the script jtftterr.sql */
/*
Procedure update_terr_type_for_terr
IS

BEGIN

   -- Update the named account terrtories with territory template

   update jtf_terr_all jt
   set jt.territory_type_id = -1
   where jt.named_account_flag = 'Y'
       and jt.territory_type_id is null;

   -- Update the self service geo  terrtories with territory template

   update jtf_terr_all jt
   set jt.territory_type_id = -2
   where jt.GEO_TERR_FLAG = 'Y'
       and jt.territory_type_id is null;

   -- Update non named account terrtories with territory template

   update jtf_terr_all jt
   set jt.territory_type_id =
    (select jttu.terr_type_id
      from  jtf_terr_type_usgs_all jttu
          , jtf_terr_usgs_all jtu
      where jttu.source_id = jtu.source_id
        and jt.terr_id = jtu.terr_id
        and jttu.created_by = 2        -- territory templates shipped by Oracle
        and jttu.terr_type_id not in (-1, -2)    -- Eliminate named account
        and jtu.org_id = jttu.org_id)
   where jt.territory_type_id is null
     and jt.terr_id <> 1;

   commit;

EXCEPTION
   when FND_API.G_EXC_ERROR then
    NULL;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
    NULL;
   when others then
    NULL;
END update_terr_type_for_terr;
*/


-- Delete the Resource transaction type

Procedure delete_resource_trx_type
IS

BEGIN

--      delete from jtf_qual_usgs_all where qual_type_usg_id
--      in (select qual_type_usg_id
--          from jtf_qual_type_usgs_all
--	  where qual_type_id = -1001);

      delete from  jtf_qual_type_usgs_all
	where qual_type_id = -1001;

      delete from  jtf_qual_types_all
	where qual_type_id = -1001;

  commit;

EXCEPTION
   when FND_API.G_EXC_ERROR then
    -- Add proper error logging
    -- dbms_output.put_line('10' || sqlerrm );
    NULL;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
    -- Add proper error logging
    -- dbms_output.put_line('11' || sqlerrm );
    NULL;
   when others then
    -- Add proper error logging
    -- dbms_output.put_line('12' || sqlerrm );
    NULL;

END delete_resource_trx_type;

-- This procedure will create the
-- default templates for all the usages and for all the
-- existing organizations and also the Named account territory
-- template with territory type id -1

Procedure add_seeded_territory_types
IS
  l_migration_complete varchar2(1);
BEGIN


  -- sql to check whethe migration script already ran
  -- on this environment

  BEGIN
    select 'Y'
    into l_migration_complete
    from jtf_terr_types_all
    where substr(name,1,7) = 'General'
      and created_by = 2
      and rownum < 2;
  EXCEPTION
     when FND_API.G_EXC_ERROR then
      -- Add proper error logging
      -- dbms_output.put_line('21' || sqlerrm );
      NULL;
     when FND_API.G_EXC_UNEXPECTED_ERROR then
      -- Add proper error logging
      -- dbms_output.put_line('22' || sqlerrm );
      NULL;
     when others then
      -- Add proper error logging
      -- dbms_output.put_line('23' || sqlerrm );
      l_migration_complete := 'N';
      NULL;
  END;

  -- If the migration script already executed on this env
  -- then delete the records.

  if l_migration_complete <> 'Y' then

    -- Insert territory types for all the usages
    -- and org_id

    BEGIN
      insert into jtf_terr_types_all
      ( TERR_TYPE_ID
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , CREATED_BY
      , CREATION_DATE
      , APPLICATION_SHORT_NAME
      , NAME
      , ENABLED_FLAG
      , DESCRIPTION
      , START_DATE_ACTIVE
      , ORG_ID
      , ORIG_SYSTEM_REFERENCE_ID)
      select  jtf_terr_types_s.nextval
      , 2
      , sysdate
      , 2
      , sysdate
      , 'JTF'
      , 'General ' || meaning -- Will work with NLS team to check how to do translation.
      , 'Y'
      , 'General ' || meaning
      , sysdate
      , org_id
      , source_id
      from (select distinct jtu.org_id
             , jtu.source_id
             , jsa.meaning
        from jtf_terr_usgs_all jtu
           , jtf_sources_all jsa
        where jsa.source_id = jtu.source_id);
    EXCEPTION
       when FND_API.G_EXC_ERROR then
        -- Add proper error logging
        -- dbms_output.put_line('24' || sqlerrm );
        NULL;
       when FND_API.G_EXC_UNEXPECTED_ERROR then
        -- Add proper error logging
        -- dbms_output.put_line('26' || sqlerrm );
        NULL;
       when others then
        -- Add proper error logging
        -- dbms_output.put_line('27' || sqlerrm );
        NULL;
    END;

    BEGIN

      -- insert territory templates for
      -- named accounts
      insert into jtf_terr_types_all
      ( TERR_TYPE_ID
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , CREATED_BY
      , CREATION_DATE
      , APPLICATION_SHORT_NAME
      , NAME
      , ENABLED_FLAG
      , DESCRIPTION
      , START_DATE_ACTIVE
      , ORG_ID
      , ORIG_SYSTEM_REFERENCE_ID)
      select -1
      , 2
      , sysdate
      , 2
      , sysdate
      , 'JTF'
      , 'Named Account'
      , 'Y'
      , 'Named Account Territories'
      , sysdate
      , organization_id
      , -1001
      from (select distinct organization_id
            from hr_operating_units);
-- SOLIN, bug 5117193
-- Don't insert org_id -3113, so jtfmorsd.sql won't replicate Named Account
-- to other Orgs.
--            union
--            select -3113
--            from sys.dual);


      insert into jtf_terr_types_all
      ( TERR_TYPE_ID
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , CREATED_BY
      , CREATION_DATE
      , APPLICATION_SHORT_NAME
      , NAME
      , ENABLED_FLAG
      , DESCRIPTION
      , START_DATE_ACTIVE
      , ORG_ID
      , ORIG_SYSTEM_REFERENCE_ID)
      select -2
      , 2
      , sysdate
      , 2
      , sysdate
      , 'JTF'
      , 'Geography'
      , 'Y'
      , 'Geography Territories'
      , sysdate
      , org_id
      , -1001
      from (select distinct org_id
          from jtf_terr_all
          where geo_terr_flag = 'Y');

    EXCEPTION
       when FND_API.G_EXC_ERROR then
        -- Add proper error logging
        -- dbms_output.put_line('28' || sqlerrm );
        NULL;
       when FND_API.G_EXC_UNEXPECTED_ERROR then
        -- Add proper error logging
        -- dbms_output.put_line('29' || sqlerrm );
        NULL;
       when others then
        -- Add proper error logging
        -- dbms_output.put_line('30' || sqlerrm );
        NULL;
    END;

    BEGIN
      -- For every row in jtf_terr_type_all table
      -- insert a corresponding row in
      -- jtf_terr_type_usgs_all table

      insert into jtf_terr_type_usgs_all
      ( TERR_TYPE_USG_ID
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , CREATED_BY
      , CREATION_DATE
      , TERR_TYPE_ID
      , SOURCE_ID
      , ORG_ID
      )
      select jtf_terr_type_usgs_s.nextval
      , 2
      , sysdate
      , 2
      , sysdate
      , terr_type_id
      , ORIG_SYSTEM_REFERENCE_ID    -- Used this column to temp store source_id
      , org_id
      from jtf_terr_types_all
      where  ORIG_SYSTEM_REFERENCE_ID is not null
        and  CREATED_BY = 2;

    EXCEPTION
       when FND_API.G_EXC_ERROR then
        -- Add proper error logging
        -- dbms_output.put_line('31' || sqlerrm );
        NULL;
       when FND_API.G_EXC_UNEXPECTED_ERROR then
        -- Add proper error logging
        -- dbms_output.put_line('32' || sqlerrm );
        NULL;
       when others then
        -- Add proper error logging
        -- dbms_output.put_line('33' || sqlerrm );
        NULL;
    END;

    BEGIN

      -- populate jtf_type_qtype_usgs_all table with
      -- qual_type_usg_id and terr_type_id
      -- intersection table for  jtf_qual_type_usgs_all and
      -- jtf_terr_types_all tables

      insert into jtf_type_qtype_usgs_all
       ( TYPE_QTYPE_USG_ID
       , LAST_UPDATED_BY
       , LAST_UPDATE_DATE
       , CREATED_BY
       , CREATION_DATE
       , last_update_login
       , TERR_TYPE_ID
       , QUAL_TYPE_USG_ID
       , ORG_ID)
       select jtf_type_qtype_usgs_s.nextval
           , 2
           , sysdate
           , 2
           , sysdate
           , 2
           , jttu.terr_type_id
           , jqtu.qual_type_usg_id
           , jttu.org_id
       from jtf_terr_type_usgs_all jttu
          , jtf_qual_type_usgs_all jqtu
       where jqtu.source_id = jttu.source_id
       and jqtu.qual_type_usg_id <> -1005  -- Exclude service account transaction type
       and jttu.created_by = 2;

    EXCEPTION
       when FND_API.G_EXC_ERROR then
        -- Add proper error logging
        -- dbms_output.put_line('34' || sqlerrm );
        NULL;
       when FND_API.G_EXC_UNEXPECTED_ERROR then
        -- Add proper error logging
        -- dbms_output.put_line('35' || sqlerrm );
        NULL;
       when others then
        -- Add proper error logging
        -- dbms_output.put_line('36' || sqlerrm );
        NULL;
    END;

    BEGIN

       -- populate jtf_terr_type_qual_all table with
       -- QUAL_USG_ID and terr_type_id
       -- intersection table for  jtf_qual_usgs_all and
       -- jtf_terr_types_all tables
       insert into jtf_terr_type_qual_all
          (TERR_TYPE_QUAL_ID
           , LAST_UPDATED_BY
           , LAST_UPDATE_DATE
           , CREATED_BY
           , CREATION_DATE
           , QUAL_USG_ID
           , TERR_TYPE_ID
           , ORG_ID)
       select jtf_terr_type_qual_s.nextval
         , 2
         , sysdate
         , 2
         , sysdate
         , jqu.QUAL_USG_ID
         , jttu.terr_type_id
         , jttu.org_id
       from jtf_terr_type_usgs_all jttu
          , jtf_qual_type_usgs_all jqtu
          , jtf_qual_usgs_all jqu
       where jttu.created_by = 2
       and jqu.QUAL_TYPE_USG_ID = jqtu.qual_type_usg_id
       and jqtu.source_id = jttu.source_id
       and jttu.org_id = jqu.org_id
       and jttu.terr_type_id <> -1 -- For NA territories this table is not populated
       and jqu.ENABLED_FLAG = 'Y';

    EXCEPTION
       when FND_API.G_EXC_ERROR then
        -- Add proper error logging
        -- dbms_output.put_line('37' || sqlerrm );
        NULL;
       when FND_API.G_EXC_UNEXPECTED_ERROR then
        -- Add proper error logging
        -- dbms_output.put_line('38' || sqlerrm );
        NULL;
       when others then
        -- Add proper error logging
        -- dbms_output.put_line('39' || sqlerrm );
        NULL;
    END;

  end if;

  commit;

EXCEPTION
   when FND_API.G_EXC_ERROR then
    -- Add proper error logging
    -- dbms_output.put_line('13' || sqlerrm );
    NULL;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
    -- Add proper error logging
    -- dbms_output.put_line('14' || sqlerrm );
    NULL;
   when others then
    -- Add proper error logging
    -- dbms_output.put_line('15' || sqlerrm );
    NULL;

END add_seeded_territory_types;

-- added 07/10/2006, bug 5193133
-- removed lead/opportunity expected purchase
Procedure remove_expected_purchase_qual
IS

  l_count number := 0;
BEGIN

  select count(*) into l_count
  from jtf_terr_qual_all
  where qual_usg_id in (-1023,-1018);

  if (l_count = 0) then
    delete from jtf_seeded_qual_all_b
    where seeded_qual_id in (-1024, -1019);

    delete from jtf_seeded_qual_all_tl
    where seeded_qual_id in (-1024, -1019);

    delete from jtf_qual_usgs_all
    where qual_usg_id in (-1023,-1018);
  end if;

  commit;

EXCEPTION
   when FND_API.G_EXC_ERROR then
    -- Add proper error logging
    -- dbms_output.put_line('1 ' || sqlerrm );
    NULL;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
    -- Add proper error logging
    -- dbms_output.put_line('2 ' || sqlerrm );
    NULL;
   when others then
    -- Add proper error logging
    -- dbms_output.put_line('3 ' || sqlerrm );
    NULL;
END remove_expected_purchase_qual;


-- Main procedure that will run all the
-- necessary procedures for R12 migration.

Procedure run_r12_migation_procedures
IS

BEGIN

 -- dbms_output.put_line('Inside Migration Script' );

 enable_existing_template;

 delete_resource_trx_type;

 --update_terr_enddate_active;

 --update_self_service_flag;

 add_seeded_territory_types;

 -- added 07/10/2006, bug 5193133
 remove_expected_purchase_qual;

 --update_terr_type_for_terr;

-- update_rsc_access;

 commit;

EXCEPTION
   when FND_API.G_EXC_ERROR then
    -- Add proper error logging
    -- dbms_output.put_line('16' || sqlerrm );
    NULL;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
    -- Add proper error logging
    -- dbms_output.put_line('17' || sqlerrm );
    NULL;
   when others then
    -- Add proper error logging
    -- dbms_output.put_line('18' || sqlerrm );
    NULL;
END run_r12_migation_procedures;

END  JTY_MIGRATION_PVT;

/
