--------------------------------------------------------
--  DDL for Package Body JTF_TTY_CATCHALL_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_CATCHALL_WORKFLOW" AS
/* $Header: jtfvwkfb.pls 120.0 2005/06/02 18:23:15 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_CATCHALL_WORKFLOW
--    PURPOSE
--
--      Procedures:
--         (see below for specification)
--
--
--
--
--    NOTES
--
--
--
--
--    HISTORY
--      12/15/02    JRADHAKR         CREATED
--
--
--    End of Comments
--

Procedure Process_catch_all_rec
    ( x_return_status         OUT NOCOPY  VARCHAR2
    , x_error_message         OUT NOCOPY  VARCHAR2
    )
  IS

  l_wf_item_key   NUMBER;

  CURSOR c_territory_list IS
    SELECT TERR_ID
        ,  TERR_GROUP_ID
    FROM jtf_terr_all
    WHERE CATCH_ALL_FLAG = 'Y';

  CURSOR c_catchall_list (l_terr_id number) IS
          select          -- Leads
               AAA.ACCESS_ID
               , ATA.TERRITORY_ID
		,upper(PARTY.party_name) party_name
               , LOC.state               state
               , LOC.postal_code         postal_code
               , PARTY.party_id          party_id
           from  HZ_PARTY_SITES   SITE
               , HZ_LOCATIONS     LOC
               , HZ_PARTIES       PARTY
               , as_accesses_all  AAA
               , as_territory_accesses ATA
               , AS_SALES_LEADS   SL
           where SITE.party_id = PARTY.party_id
             and LOC.location_id = SITE.location_id
             and SL.customer_id = PARTY.party_id
             and SL.address_id = SITE.party_site_id
             and AAA.ACCESS_ID = ATA.ACCESS_ID
             and ATA.TERRITORY_ID = l_terr_id
             and AAA.CUSTOMER_ID = SL.CUSTOMER_ID
             AND AAA.LEAD_ID IS NULL
             AND AAA.SALES_LEAD_ID IS NOT NULL
          UNION ALL
          select       -- Opportunities
               AAA.ACCESS_ID
             , ATA.TERRITORY_ID
             , upper(PARTY.party_name) party_name
             , LOC.state               state
             , LOC.postal_code         postal_code
             , PARTY.party_id          party_id
           from  HZ_PARTY_SITES   SITE
               , HZ_LOCATIONS     LOC
               , HZ_PARTIES       PARTY
               , AS_LEADS_ALL     LEAD
               , as_accesses_all  AAA
               , as_territory_accesses ATA
           where SITE.party_id     = PARTY.party_id
             and LOC.location_id   = SITE.location_id
             and LEAD.customer_id  = PARTY.party_id
             and LEAD.address_id   = SITE.party_site_id
             AND AAA.ACCESS_ID     = ATA.ACCESS_ID
             AND ATA.TERRITORY_ID  = l_terr_id
             AND AAA.CUSTOMER_ID   = LEAD.CUSTOMER_ID
             AND AAA.LEAD_ID IS NOT NULL
             AND AAA.SALES_LEAD_ID IS NULL
         UNION ALL
         select       -- Account
              AAA.ACCESS_ID
            , ATA.TERRITORY_ID
            , upper(PARTY.party_name) party_name
            , LOC.state               state
            , LOC.postal_code         postal_code
            , PARTY.party_id          party_id
          from  HZ_PARTY_SITES      SITE
              , HZ_LOCATIONS        LOC
              , HZ_PARTIES          PARTY
              , as_accesses_all     AAA
              , as_territory_accesses ATA
          where  SITE.party_id    = PARTY.party_id
            and LOC.location_id  = SITE.location_id
            AND AAA.ACCESS_ID    = ATA.ACCESS_ID
            AND ATA.TERRITORY_ID = l_terr_id
            AND AAA.CUSTOMER_ID  = PARTY.PARTY_ID
            AND AAA.LEAD_ID IS NULL
            AND AAA.SALES_LEAD_ID IS NULL
            AND AAA.CUSTOMER_ID IS NOT NULL;

  l_workflow_param  JTF_TTY_CATCHALL_WORKFLOW.workflow_param_rec_type;
  l_item_type       varchar2(30);
  l_wf_process      varchar2(30);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate item type and process
  --

  for l_terr_list in c_territory_list
  loop
    --
   JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('Processing Territory Group ' || l_terr_list.TERR_GROUP_ID);

    JTF_TTY_CATCHALL_WORKFLOW.Get_workflow_details
    ( p_TERR_GROUP_ID         => l_terr_list.TERR_GROUP_ID
    , x_WORKFLOW_ITEM_TYPE    => l_item_type
    , x_WORKFLOW_PROCESS_NAME => l_wf_process
    , x_return_status         => x_return_status
    , x_error_message         => x_error_message
    );

    if nvl(x_error_message,'DATA') <> 'NODATA' then
    --

      for l_list in c_catchall_list(l_terr_list.terr_id)
      loop
      --
         JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('Processing Catch All Territory  ' || l_terr_list.TERR_ID);

         l_workflow_param.ACCESS_ID     := l_list.ACCESS_ID;
         l_workflow_param.NAME          := l_list.Party_name;
         l_workflow_param.POSTAL_CODE   := l_list.Postal_code;
         l_workflow_param.STATE         := l_list.STATE;
         l_workflow_param.TERRGROUP_ID  := l_terr_list.TERR_GROUP_ID;
         l_workflow_param.PARTY_ID      := l_list.Party_id;

         JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('   Access Id  : ' || l_workflow_param.ACCESS_ID );
         JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('   Party Name  : ' || l_workflow_param.NAME );
         JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('   Postal Code  : ' || l_workflow_param.POSTAL_CODE );
         JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('   State : ' || l_workflow_param.STATE );
         JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('   TerrGroup Id : ' || l_workflow_param.TERRGROUP_ID );
         JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('   Party Id  : ' || l_workflow_param.PARTY_ID );


         JTF_TTY_CATCHALL_WORKFLOW.Start_Workflow_Process
         ( p_item_type       =>  l_item_type
          ,p_wf_process      =>  l_wf_process
          ,p_wf_params       =>  l_workflow_param
          ,x_return_status   =>  x_return_status
          );

      end loop;
      --
    end if;
    --
  end loop;

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Process_catch_all_rec;

Procedure  Get_workflow_details
    ( p_TERR_GROUP_ID         IN  NUMBER
    , x_WORKFLOW_ITEM_TYPE    OUT NOCOPY  VARCHAR2
    , x_WORKFLOW_PROCESS_NAME OUT NOCOPY  VARCHAR2
    , x_return_status         OUT NOCOPY  VARCHAR2
    , x_error_message         OUT NOCOPY  VARCHAR2
    )
  IS

  l_wf_process      varchar2(30);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  select WORKFLOW_ITEM_TYPE
       , WORKFLOW_PROCESS_NAME
  INTO x_WORKFLOW_ITEM_TYPE
       , x_WORKFLOW_PROCESS_NAME
  FROM jtf_tty_terr_groups
  where TERR_GROUP_ID = p_TERR_GROUP_ID;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_error_message := 'NODATA';
  WHEN OTHERS THEN
    x_error_message := 'NODATA';
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_workflow_details;

Procedure Start_Workflow_Process
  ( p_item_type         IN Varchar2
   ,p_wf_process        IN Varchar2
   ,p_wf_params         IN JTF_TTY_CATCHALL_WORKFLOW.workflow_param_rec_type
   ,x_return_status     OUT NOCOPY  VARCHAR2
  )
  IS

  l_wf_item_key   NUMBER;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate item type and process
  --

  IF p_item_type IS NULL
    OR p_wf_process IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

         JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('      No Workflow or process found ' );

    RETURN;
  END IF;

  SELECT jtf_tty_workflow_s.nextval
  INTO l_wf_item_key
  FROM dual;

  -- create a new workflow process
  --

  wf_engine.CreateProcess(itemtype=>p_item_type
                         ,itemkey =>l_wf_item_key
                         ,process =>p_wf_process);

  -- set the workflow attributes
  --
  wf_engine.SetItemAttrText(itemtype=>p_item_type
                ,itemkey =>l_wf_item_key
                ,aname=>'STATE'
                ,avalue=>p_wf_params.STATE);

  wf_engine.SetItemAttrText(itemtype=>p_item_type
                ,itemkey =>l_wf_item_key
                ,aname=>'KEYWORD'
                ,avalue=>p_wf_params.NAME);

  wf_engine.SetItemAttrText(itemtype=>p_item_type
                ,itemkey =>l_wf_item_key
                ,aname=>'POSTAL_CODE'
                ,avalue=>p_wf_params.POSTAL_CODE);

  wf_engine.SetItemAttrNumber(itemtype=>p_item_type
                ,itemkey =>l_wf_item_key
                ,aname=>'TERRGROUP_ID'
                ,avalue=>p_wf_params.TERRGROUP_ID);

  wf_engine.SetItemAttrNumber(itemtype=>p_item_type
                ,itemkey =>l_wf_item_key
                ,aname=>'ACCESS_ID'
                ,avalue=>p_wf_params.ACCESS_ID);

  wf_engine.SetItemAttrNumber(itemtype=>p_item_type
                ,itemkey =>l_wf_item_key
                ,aname=>'PARTY_ID'
                ,avalue=>p_wf_params.PARTY_ID);

  JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('  Processing WORKFLOW : ' || p_item_type || '  ' || p_wf_process);

  wf_engine.StartProcess(itemtype=>p_item_type
                        ,itemkey => l_wf_item_key);


  commit;

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log ('Erro Stating workflow '||SQLERRM);

END Start_Workflow_Process;


END  JTF_TTY_CATCHALL_WORKFLOW;

/
