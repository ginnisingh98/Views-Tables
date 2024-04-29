--------------------------------------------------------
--  DDL for Package Body JTY_TERR_SPARES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_TERR_SPARES_PVT" AS
/* $Header: jtftsprmgb.pls 120.0.12010000.4 2010/03/10 09:16:41 rajukum noship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TERR_SPARES_PVT
--    PURPOSE
--
--      Procedures:
--         (see below for specification)
--         This package covers migration of territory data
--
--         The various procedures are for
--          1. Territory Type Creation for Spares (add_seeded_territory_types) :
--             This procedure will create the
--             geographic territory type for use by Spares
--
--    NOTES
--
--
--    HISTORY
--      03/03/2010    RAJUKUM         CREATED
--
--    End of Comments
--





-- This procedure will create the
-- territory types for spares use for service usages and for all the
-- existing organizations

Procedure add_seeded_territory_types
IS
  l_migration_complete varchar2(1);
  l_description varchar2(240);
BEGIN


  -- sql to check whethe migration script already ran
  -- on this environment

  BEGIN
    select 'Y'
    into l_migration_complete
    from jtf_terr_types_all
    where terr_type_id = -9
      and created_by = 9
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

    BEGIN

    l_description := 'Territory Type defined to create other Territories to be used by Spares Management ' ||
                     'Advanced Return Routing Rules';

    -- Insert territory types for service usages
    -- and org_id

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
      select -9
      , 9
      , sysdate
      , 9
      , sysdate
      , 'CSP'
      , 'Spares Management Return Routing'
      , 'Y'
      , l_description
      , sysdate
      , -3113
      , -1002
      from dual;


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
      , 9
      , sysdate
      , 9
      , sysdate
      , terr_type_id
      , ORIG_SYSTEM_REFERENCE_ID    -- Used this column to temp store source_id
      , org_id
      from jtf_terr_types_all
      where  ORIG_SYSTEM_REFERENCE_ID is not null
        and  terr_type_id = -9
        and  CREATED_BY = 9;

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
           , 9
           , sysdate
           , 9
           , sysdate
           , 9
           , jttu.terr_type_id
           , jqtu.qual_type_usg_id
           , jttu.org_id
       from jtf_terr_type_usgs_all jttu
          , jtf_qual_type_usgs_all jqtu
       where jqtu.source_id = jttu.source_id
       and  jttu.source_id = -1002
       and jttu.terr_type_id = -9
       and jqtu.qual_type_usg_id <> -1005  -- Exclude service account transaction type
       and jttu.created_by = 9;

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
         , 9
         , sysdate
         , 9
         , sysdate
         , jqu.QUAL_USG_ID
         , jttu.terr_type_id
         , jttu.org_id
       from jtf_terr_type_usgs_all jttu
          , jtf_qual_type_usgs_all jqtu
          , jtf_qual_usgs_all jqu
       where jttu.created_by = 9
       and jttu.terr_type_id = -9
       and jttu.source_id = -1002
       and jqu.QUAL_TYPE_USG_ID = jqtu.qual_type_usg_id
       and jqtu.source_id = jttu.source_id
       and jttu.org_id = jqu.org_id
       and jqu.hierarchy_type = 'GEOGRAPHY'
       and jttu.terr_type_id <> -1 ;-- For NA territories this table is not populated
       --and jqu.ENABLED_FLAG = 'Y';

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

    commit;
  end if;

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


-- Main procedure that will run all the
-- necessary procedures for creations R12 seeded data for Spares.

Procedure run_r12_seeded_terr_for_spares
IS

BEGIN


 add_seeded_territory_types;


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
END run_r12_seeded_terr_for_spares;

 -- ***************************************************
  --    API Specifications
  -- ***************************************************
  --    api name       : Process_match_terr_spares
  --    type           : public.
  --    function       : Called by spares  APIs
  --    pre-reqs       : Territories needs to be setup first
  --    notes          :
  --
  PROCEDURE process_match_terr_spares
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_TerrServReq_Rec          IN    JTF_TERRITORY_PUB.JTF_Serv_Req_rec_type,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    p_plan_start_date          IN          DATE DEFAULT NULL,
    p_plan_end_date            IN          DATE DEFAULT NULL,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2
)
AS
  l_api_name                   CONSTANT VARCHAR2(30) := 'process_match_terr_spares';
  l_api_version_number         CONSTANT NUMBER       := 1.0;

  l_Counter                    NUMBER;

  lx_winners_rec   JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;
BEGIN

  -- debug message
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jtf_terr_service_pub.process_match_terr_spares.start',
                   'Start of the procedure jtf_terr_service_pub.process_match_terr_spares');
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  --
  -- API body
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- debug message
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                   'jtf.plsql.JTY_TERR_SPARES_PVT.process_match_terr_spares.parameters',
                   'Country : ' || p_TerrServReq_Rec.COUNTRY || ' City : ' || p_TerrServReq_Rec.CITY ||
                   ' Postal Code : ' || p_TerrServReq_Rec.POSTAL_CODE || ' State : ' || p_TerrServReq_Rec.STATE ||
                   ' Area Code : ' || p_TerrServReq_Rec.AREA_CODE || ' County : ' || p_TerrServReq_Rec.COUNTY ||
                   ' Company Name Range : ' || p_TerrServReq_Rec.COMP_NAME_RANGE || ' Province : ' || p_TerrServReq_Rec.PROVINCE ||
                   ' Problem Code : ' || p_TerrServReq_Rec.PROBLEM_CODE ||
                   ' sr creation channel : ' || p_TerrServReq_Rec.SR_CREATION_CHANNEL ||
                   ' vip customer : ' || p_TerrServReq_Rec.squal_char11 || ' sr problem code : ' || p_TerrServReq_Rec.squal_char12 ||
                   ' sr customer contact preference : ' || p_TerrServReq_Rec.squal_char13 ||
                   ' sr service contact coverage : ' || p_TerrServReq_Rec.squal_char21 ||
                   ' sr language : ' || p_TerrServReq_Rec.squal_char20 ||
                   ' Number of Employees : ' || p_TerrServReq_Rec.NUM_OF_EMPLOYEES || ' Party ID : ' || p_TerrServReq_Rec.PARTY_ID ||
                   ' Party Site ID : ' || p_TerrServReq_Rec.PARTY_SITE_ID ||
                   ' Incident Type ID : ' || p_TerrServReq_Rec.INCIDENT_TYPE_ID ||
                   ' Incident severity ID : ' || p_TerrServReq_Rec.INCIDENT_SEVERITY_ID ||
                   ' Incident urgency ID : ' || p_TerrServReq_Rec.INCIDENT_URGENCY_ID ||
                   ' Incident status ID : ' || p_TerrServReq_Rec.INCIDENT_STATUS_ID ||
                   ' platform ID : ' || p_TerrServReq_Rec.PLATFORM_ID || ' Support Site ID : ' || p_TerrServReq_Rec.SUPPORT_SITE_ID ||
                   ' Cust Site ID : ' || p_TerrServReq_Rec.CUSTOMER_SITE_ID ||
                   ' Inventory Item ID : ' || p_TerrServReq_Rec.INVENTORY_ITEM_ID ||
                   ' SR Platform Inventory Item ID : ' || p_TerrServReq_Rec.SQUAL_NUM12 ||
                   ' SR Platform Org ID : ' || p_TerrServReq_Rec.SQUAL_NUM13 ||
                   ' SR Product Category ID : ' || p_TerrServReq_Rec.SQUAL_NUM14 ||
                   ' PCS Inventory Item ID : ' || p_TerrServReq_Rec.SQUAL_NUM15 ||
                   ' PCS Org ID : ' || p_TerrServReq_Rec.SQUAL_NUM16 ||
                   ' PCS Component ID : ' || p_TerrServReq_Rec.SQUAL_NUM23 ||
                   ' PCS Subcomponent ID : ' || p_TerrServReq_Rec.SQUAL_NUM24 ||
                   ' SR Group Owner ID : ' || p_TerrServReq_Rec.SQUAL_NUM17 ||
                   ' SSI Inventory Item ID : ' || p_TerrServReq_Rec.SQUAL_NUM18 ||
                   ' SSI Org ID : ' || p_TerrServReq_Rec.SQUAL_NUM19||
                   ' p_plan_start_date: ' || p_plan_start_date ||
                   ' p_plan_end_date: ' || p_plan_end_date||
                   ' Day OF Week : ' || p_TerrServReq_Rec.DAY_OF_WEEK ||
                   ' Time OF Day : ' || p_TerrServReq_Rec.TIME_OF_DAY);

  END IF;

  /* delete and insert all the attributes into the trans table as name - value pair */
  DELETE jty_terr_nvp_trans_gt;
  INSERT INTO jty_terr_nvp_trans_gt (
     attribute_name
    ,num_value
    ,char_value
    ,date_value )
  ( SELECT 'COUNTRY'                  attribute_name
          ,null                       num_value
          ,p_TerrServReq_Rec.COUNTRY  char_value
          ,null                       date_value
    FROM  DUAL
    UNION ALL
    SELECT 'CITY'                  attribute_name
          ,null                    num_value
          ,p_TerrServReq_Rec.CITY  char_value
          ,null                    date_value
    FROM  DUAL
    UNION ALL
    SELECT 'POSTAL_CODE'                  attribute_name
          ,null                           num_value
          ,p_TerrServReq_Rec.POSTAL_CODE  char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'STATE'                  attribute_name
          ,null                     num_value
          ,p_TerrServReq_Rec.STATE  char_value
          ,null                     date_value
    FROM  DUAL
    UNION ALL
    SELECT 'AREA_CODE'                  attribute_name
          ,null                         num_value
          ,p_TerrServReq_Rec.AREA_CODE  char_value
          ,null                         date_value
    FROM  DUAL
    UNION ALL
    SELECT 'COUNTY'                  attribute_name
          ,null                      num_value
          ,p_TerrServReq_Rec.COUNTY  char_value
          ,null                      date_value
    FROM  DUAL
    UNION ALL
    SELECT 'COMP_NAME_RANGE'                  attribute_name
          ,null                               num_value
          ,p_TerrServReq_Rec.COMP_NAME_RANGE  char_value
          ,null                               date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PROVINCE'                  attribute_name
          ,null                        num_value
          ,p_TerrServReq_Rec.PROVINCE  char_value
          ,null                        date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PROBLEM_CODE'                  attribute_name
          ,null                            num_value
          ,p_TerrServReq_Rec.PROBLEM_CODE  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_CREATION_CHANNEL'                  attribute_name
          ,null                                   num_value
          ,p_TerrServReq_Rec.SR_CREATION_CHANNEL  char_value
          ,null                                   date_value
    FROM  DUAL
    UNION ALL
    SELECT 'VIP_CUSTOMER'                  attribute_name
          ,null                            num_value
          ,p_TerrServReq_Rec.squal_char11  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_PROBLEM_CODE'               attribute_name
          ,null                            num_value
          ,p_TerrServReq_Rec.squal_char12  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_CUST_CNTCT_PREF'            attribute_name
          ,null                            num_value
          ,p_TerrServReq_Rec.squal_char13  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_SRVC_CNTCT_CVG'             attribute_name
          ,null                            num_value
          ,p_TerrServReq_Rec.squal_char21  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_LANGUAGE'                   attribute_name
          ,null                            num_value
          ,p_TerrServReq_Rec.squal_char20  char_value
          ,null                            date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PARTY_ID'                  attribute_name
          ,p_TerrServReq_Rec.PARTY_ID  num_value
          ,null                        char_value
          ,null                        date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PARTY_SITE_ID'                  attribute_name
          ,p_TerrServReq_Rec.PARTY_SITE_ID  num_value
          ,null                             char_value
          ,null                             date_value
    FROM  DUAL
    UNION ALL
    SELECT 'NUM_OF_EMPLOYEES'                  attribute_name
          ,p_TerrServReq_Rec.NUM_OF_EMPLOYEES  num_value
          ,null                                char_value
          ,null                                date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INCIDENT_TYPE_ID'                  attribute_name
          ,p_TerrServReq_Rec.INCIDENT_TYPE_ID  num_value
          ,null                                char_value
          ,null                                date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INCIDENT_SEVERITY_ID'                  attribute_name
          ,p_TerrServReq_Rec.INCIDENT_SEVERITY_ID  num_value
          ,null                                    char_value
          ,null                                    date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INCIDENT_URGENCY_ID'                  attribute_name
          ,p_TerrServReq_Rec.INCIDENT_URGENCY_ID  num_value
          ,null                                   char_value
          ,null                                   date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INCIDENT_STATUS_ID'                  attribute_name
          ,p_TerrServReq_Rec.INCIDENT_STATUS_ID  num_value
          ,null                                  char_value
          ,null                                  date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PLATFORM_ID'                  attribute_name
          ,p_TerrServReq_Rec.PLATFORM_ID  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SUPPORT_SITE_ID'                  attribute_name
          ,p_TerrServReq_Rec.SUPPORT_SITE_ID  num_value
          ,null                               char_value
          ,null                               date_value
    FROM  DUAL
    UNION ALL
    SELECT 'CUSTOMER_SITE_ID'                  attribute_name
          ,p_TerrServReq_Rec.CUSTOMER_SITE_ID  num_value
          ,null                                char_value
          ,null                                date_value
    FROM  DUAL
    UNION ALL
    SELECT 'INVENTORY_ITEM_ID'                  attribute_name
          ,p_TerrServReq_Rec.INVENTORY_ITEM_ID  num_value
          ,null                                 char_value
          ,null                                 date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SRP_INVENTORY_ITEM_ID'        attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM12  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SRP_ORG_ID'                  attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM13 num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SPC_CATEGORY_ID'                  attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM14      num_value
          ,null                               char_value
          ,null                               date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PCS_INVENTORY_ITEM_ID'        attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM15  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PCS_ORG_ID'                  attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM16 num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PCS_COMPONENT_ID'            attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM23 num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'PCS_SUBCOMPONENT_ID'          attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM24  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SR_GROUP_OWNER_ID'               attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM17  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SSI_INVENTORY_ITEM_ID'        attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM18  num_value
          ,null                           char_value
          ,null                           date_value
    FROM  DUAL
    UNION ALL
    SELECT 'SSI_ORG_ID'                  attribute_name
          ,p_TerrServReq_Rec.SQUAL_NUM19 num_value
          ,null                          char_value
          ,null                          date_value
    FROM  DUAL
    UNION ALL
    SELECT 'DAY_OF_WEEK'                    attribute_name
          ,null                             num_value
          --,p_TerrServReq_Rec.DAY_OF_WEEK   char_value
          , DECODE(p_TerrServReq_Rec.DAY_OF_WEEK,FND_API.G_MISS_CHAR,null,
                   p_TerrServReq_Rec.DAY_OF_WEEK)   char_value
          ,null                             date_value
    FROM  DUAL
    UNION ALL
    SELECT 'TIME_OF_DAY'                  attribute_name
          , null                            num_value
          --, p_TerrServReq_Rec.TIME_OF_DAY   char_value
          , DECODE(p_TerrServReq_Rec.TIME_OF_DAY,FND_API.G_MISS_CHAR,null,
                   p_TerrServReq_Rec.TIME_OF_DAY)   char_value
          ,null                             date_value
    FROM  DUAL

  );


  JTY_ASSIGN_REALTIME_PUB.process_match (
         p_source_id     => -1002
        ,p_trans_id      => -1005
        ,p_program_name  => 'SERVICE/SERVICE REQUEST PROGRAM'
        ,p_mode          => 'REAL TIME:RESOURCE'
        ,x_return_status => x_return_status
        ,x_msg_count     => x_msg_count
        ,x_msg_data      => x_msg_data);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_SPARES_PVT.process_match_terr_spares.process_match',
                     'API JTY_ASSIGN_REALTIME_PUB.process_match has failed');
    END IF;
    RAISE	FND_API.G_EXC_ERROR;
  END IF;

  -- debug message
  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_EVENT,
                   'jtf.plsql.jtf_terr_service_pub.process_match_terr_spares.process_match',
                   'Finish calling procedure JTY_ASSIGN_REALTIME_PUB.process_match');
  END IF;



EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.JTY_TERR_SPARES_PVT.process_match_terr_spares.other',
                     substr(x_msg_data, 1, 4000));
    END IF;
  END process_match_terr_spares;

END  JTY_TERR_SPARES_PVT;

/
