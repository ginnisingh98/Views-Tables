--------------------------------------------------------
--  DDL for Package Body JTF_TTY_POP_TERR_ADMIN_BIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_POP_TERR_ADMIN_BIN_PVT" AS
/* $Header: jtfvuabb.pls 120.2 2006/03/23 15:11:13 chchandr ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_POP_TERR_ADMIN_BIN_PVT
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
--      09/15/02    JRADHAKR         CREATED
--
--
--    End of Comments
--

Procedure populate_catch_all_bin_info
( x_return_status                                OUT NOCOPY  VARCHAR2
, x_error_message                               OUT NOCOPY  VARCHAR2
)
IS

  CURSOR c_terr_list
  IS select terr_id
          , terr_group_id
     from jtf_terr_all
     WHERE CATCH_ALL_FLAG = 'Y';

 L_USER_ID             NUMBER := FND_GLOBAL.USER_ID();
 L_SYSDATE             DATE;
 L_LEADS               NUMBER;
 L_OPPORTUNITIES       NUMBER;
 L_ACCOUNTS            NUMBER;

BEGIN
  L_SYSDATE := SYSDATE;
  JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('In populate_catch_all_bin_info Procedure ');

  Update jtf_tty_admin_bin_summ jtabs
  set  LEADS                  = 0
     , OPPORTUNITIES          = 0
     , ACCOUNTS               = 0
     , CATCH_ALL_UPDATE_DATE  = L_SYSDATE
     , LAST_UPDATED_BY        = L_USER_ID
     , LAST_UPDATE_DATE       = L_SYSDATE
    ;

  for l_list in c_terr_list
  loop

    --
    --Accounts
    SELECT /*+ INDEX (AAA as_accesses_u1) */ COUNT(*)
    INTO L_ACCOUNTS
    FROM
      as_accesses_all AAA
    , as_territory_accesses ATA
    WHERE AAA.ACCESS_ID = ATA.ACCESS_ID
      AND ATA.TERRITORY_ID = l_list.terr_id
      AND LEAD_ID IS NULL
      AND SALES_LEAD_ID IS NULL
      AND CUSTOMER_ID IS NOT NULL;

    -- Leads
    SELECT /*+ INDEX (AAA as_accesses_u1) */  COUNT(*)
    INTO L_LEADS
    FROM
      as_accesses_all AAA
    , as_territory_accesses ATA
    WHERE AAA.ACCESS_ID = ATA.ACCESS_ID
      AND ATA.TERRITORY_ID = l_list.terr_id
      AND LEAD_ID IS NULL
      AND SALES_LEAD_ID IS NOT NULL;


    -- Opportunities
    SELECT /*+ INDEX (AAA as_accesses_u1) */ COUNT(*)
    INTO L_OPPORTUNITIES
    FROM
      as_accesses_all AAA
    , as_territory_accesses ATA
    WHERE AAA.ACCESS_ID = ATA.ACCESS_ID
      AND ATA.TERRITORY_ID = l_list.terr_id
      AND LEAD_ID IS NOT NULL
      AND SALES_LEAD_ID IS NULL;


   Update jtf_tty_admin_bin_summ jtabs
    set  LEADS                  = L_LEADS
       , OPPORTUNITIES          = L_OPPORTUNITIES
       , ACCOUNTS               = L_ACCOUNTS
   where terr_group_id = l_list.terr_group_id;

  end loop;



EXCEPTION
   when FND_API.G_EXC_ERROR then
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('Exception others in populate_catch_all_bin_information '||SQLERRM);
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log ('Exception others in populate_catch_all_bin_information '||SQLERRM);
      RETURN;
   when others then
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log ('Exception others in populate_catch_all_bin_information '||SQLERRM);
      RETURN;

END populate_catch_all_bin_info;


Procedure populate_kpi_bin_info
( x_return_status                               OUT NOCOPY  VARCHAR2
, x_error_message                               OUT NOCOPY  VARCHAR2
)
IS

 L_USER_ID             NUMBER := FND_GLOBAL.USER_ID();
 L_SYSDATE             DATE;

BEGIN
  L_SYSDATE                := SYSDATE;

  JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('In populate_kpi_bin_info Procedure ');

  Update jtf_tty_admin_bin_summ jtabs
  set TOTAL_NAMED_ACCOUNT    = '0.0%'
     , MAPPED_NAMED_ACC_PER   = '0.0%'
     , ASSIGNED_NAMED_ACC_PER = '0.0%'
     , KPI_UPDATE_DATE        = L_SYSDATE
     , LAST_UPDATED_BY        = L_USER_ID
     , LAST_UPDATE_DATE       = L_SYSDATE
    ;

  Update jtf_tty_admin_bin_summ jtabs
  set (TOTAL_NAMED_ACCOUNT
     , MAPPED_NAMED_ACC_PER
     , ASSIGNED_NAMED_ACC_PER
    )
   = (select
       to_char(tot.named_accounts) total
     , nvl(to_char(map.mapped/tot.named_accounts * 100,'9999.9'),'0.0') || '%' mapPer
     , nvl(to_char(ass.assigned/tot.named_accounts * 100 ,'9999.9'),'0.0') || '%' assPer
  from ( select jga.terr_group_id
          , count(*) assigned
         from jtf_tty_terr_grp_accts jga
         where  jga.DN_JNR_ASSIGNED_FLAG = 'Y'
            group by  jga.terr_group_id) ASS,
        ( select jga.terr_group_id, jtg.terr_group_name
           , count(*) named_accounts
          from jtf_tty_terr_grp_accts jga
             , jtf_tty_terr_groups jtg
          where jga.terr_group_id  = jtg.terr_group_id
             group by  jga.terr_group_id, jtg.terr_group_name ) tot,
        ( select
              jga.terr_group_id
            , count(*) mapped
       from jtf_tty_terr_grp_accts jga
       where jga.dn_jna_mapping_complete_flag = 'Y'
       group by  jga.terr_group_id ) map
  where ass.terr_group_id (+)  = tot.terr_group_id
  and map.terr_group_id (+)  = tot.terr_group_id
  and jtabs.terr_group_id = tot.terr_group_id );


EXCEPTION
   when FND_API.G_EXC_ERROR then
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('Exception others in populate_kpi_bin_information '||SQLERRM);
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log ('Exception others in populate_kpi_bin_information '||SQLERRM);
      RETURN;
   when others then
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log ('Exception others in populate_kpi_bin_information '||SQLERRM);
      RETURN;

END populate_kpi_bin_info;

Procedure Sync_terr_group
( x_return_status                               OUT NOCOPY  VARCHAR2
, x_error_message                               OUT NOCOPY  VARCHAR2
)
IS

 L_USER_ID             NUMBER := FND_GLOBAL.USER_ID();
 L_SYSDATE             DATE;


BEGIN
 L_SYSDATE             := SYSDATE;

  JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('Synchronizing the SUMM table with TERR_GROUPS table');
  /* take care of the logic moved from web adi admin excel */

   UPDATE JTF_TTY_TERR_GRP_ACCTS
   SET DN_JNR_ASSIGNED_FLAG = 'Y'
   WHERE TERR_GROUP_ACCOUNT_ID IN
       (select  /*+ INDEX_FFS(NARSC JTF_TTY_NAMED_ACCT_RSC_N8 )*/ narsc.terr_group_account_id
        from jtf_tty_named_acct_rsc narsc
        where assigned_flag = 'Y');

   UPDATE JTF_TTY_TERR_GRP_ACCTS
   SET DN_JNR_ASSIGNED_FLAG = 'N'
   WHERE TERR_GROUP_ACCOUNT_ID NOT IN
       (select  /*+ INDEX_FFS(NARSC JTF_TTY_NAMED_ACCT_RSC_N8 )*/ narsc.terr_group_account_id
        from jtf_tty_named_acct_rsc narsc
        where assigned_flag = 'Y');


    delete from jtf_tty_admin_bin_summ
      where TERR_GROUP_ID not in (
         select TERR_GROUP_ID from jtf_tty_terr_groups
             Where TRUNC(active_from_date) <= TRUNC(SYSDATE)
               AND TRUNC(NVL(active_to_date, SYSDATE)) >= TRUNC(SYSDATE)
          );

    update jtf_tty_admin_bin_summ jtabs
      set jtabs.TERR_GROUP_NAME = (select jtg.TERR_GROUP_NAME
       from jtf_tty_terr_groups jtg
       where jtg.TERR_GROUP_ID = jtabs.TERR_GROUP_ID);


    insert into jtf_tty_admin_bin_summ jtabs
       ( ADMIN_BIN_TERR_GRP_ID
       , OBJECT_VERSION_NUMBER
       , TERR_GROUP_ID
       , TERR_GROUP_NAME
       , CREATED_BY
       , CREATION_DATE
       , LAST_UPDATED_BY
       , LAST_UPDATE_DATE )
     select TERR_GROUP_ID
       , 1
       , TERR_GROUP_ID
       , TERR_GROUP_NAME
       , L_USER_ID
       , L_SYSDATE
       , L_USER_ID
       , L_SYSDATE
     from jtf_tty_terr_groups
     where TERR_GROUP_ID not in
      (select TERR_GROUP_ID
       from jtf_tty_admin_bin_summ)
      AND self_service_type = 'NAMED_ACCOUNT'
      AND TRUNC(active_from_date) <= TRUNC(SYSDATE)
      AND TRUNC(NVL(active_to_date, SYSDATE)) >= TRUNC(SYSDATE) ;


     COMMIT;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log (' Error in Synchronizing the SUMM table' || SQLERRM );
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log (' Error in Synchronizing the SUMM table' || SQLERRM );
      RETURN;
   when others then
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log (' Error in Synchronizing the SUMM table' || SQLERRM );
      RETURN;

END Sync_terr_group;


END  JTF_TTY_POP_TERR_ADMIN_BIN_PVT;

/
