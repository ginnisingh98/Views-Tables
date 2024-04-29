--------------------------------------------------------
--  DDL for Package Body PV_SLSTEAM_MIGRTN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_SLSTEAM_MIGRTN_PVT" AS
/* $Header: pvslmigb.pls 120.5 2005/09/22 11:22:04 vansub noship $ */


g_ret_code NUMBER := 0;
--=================================== Private Subroutines ================================
PROCEDURE printLog(p_message IN VARCHAR2);
PROCEDURE clean_log;

PROCEDURE printOutput(p_message IN VARCHAR2);
PROCEDURE printReport(p_mode IN VARCHAR2);
PROCEDURE  delete_corrupt_partner;
PROCEDURE  insert_cust_partner;
PROCEDURE  insert_lead_partner;

PROCEDURE  insert_opp_partner;
PROCEDURE  insert_prefrd_partner;
PROCEDURE  insert_saved_partners;
PROCEDURE  insert_assigned_partners;
--=================================== Private Subroutines ================================
PROCEDURE EXT_SLSTEAM_MIGRTN
  ( ERRBUF     OUT NOCOPY   VARCHAR2,
    RETCODE    OUT NOCOPY   VARCHAR2,
    P_MODE     IN           VARCHAR2
  )
IS

   l_api_name            CONSTANT VARCHAR2(30) := 'EXT_SLSTEAM_MIGRTN';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_return_status       VARCHAR2(1);

BEGIN
      printlog('Batch Started at '|| TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));

      clean_log;
      delete_corrupt_partner;
      insert_cust_partner;
      insert_lead_partner;

      insert_opp_partner;
      insert_prefrd_partner;
      insert_saved_partners;
      insert_assigned_partners;

      printReport(p_mode);

      IF  p_mode = 'EVALUATE' THEN
          ROLLBACK;
      END IF;

      printlog('Batch ended at '||   TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));


   RETCODE := 0;
   ERRBUF := fnd_message.get;

  EXCEPTION
    WHEN OTHERS THEN
       printOutput('Database Error:'||sqlcode||' '||sqlerrm);

       IF   g_ret_code > 0 THEN
            RETCODE := g_ret_code;
       ELSE
             RETCODE := 0;
       END IF;
       ERRBUF  := fnd_message.get;
END EXT_SLSTEAM_MIGRTN;

PROCEDURE delete_corrupt_partner
IS

BEGIN

   /* Deleting records in as_accesses_all where partner_customer_id has partner's organization id */

      INSERT INTO pv_access_migration_log
         (
          access_migration_log_id
         ,access_id
         ,action
         ,creation_date
         ,customer_id
         ,address_id
         ,salesforce_id
         ,partner_customer_id
         ,lead_id
         ,org_id
         ,open_flag
         )
     SELECT pv_access_migration_log_s.nextval  access_migration_log_id,
           z.access_id,
           'DELTE_CORRUPT_PF_PARTNER',
           sysdate,
           z.customer_id,
           z.address_id,
           z.resource_id,
           z.incumbent_partner_party_id,
           z.lead_id,
           z.org_id,
           z.open_flag
     FROM (SELECT DISTINCT   d.access_id,
                   x.customer_id,
                   x.address_id,
                   x.resource_id,
                   x.incumbent_partner_party_id,
                   x.lead_id,
                   x.org_id,
                   d.open_flag
           FROM (
                   SELECT distinct a.lead_id,
                                  b.resource_id,
                                  a.customer_id,
                                  a.ADDRESS_ID,
                                  a.org_id ,
                                  a.incumbent_partner_party_id
                  FROM   as_leads_all a, jtf_rs_resource_extns b
                  WHERE  a.incumbent_partner_resource_id IS NOT NULL
                  AND    b.source_id = a.incumbent_partner_party_id
                  MINUS
                  SELECT distinct a.lead_id,
                           c.resource_id ,
                           a.customer_id,
                           a.ADDRESS_ID,
                           a.org_id,
                           a.incumbent_partner_party_id
                  FROM   as_leads_all a,
                         as_accesses_all b,
                         jtf_rs_resource_extns c
                  WHERE a.incumbent_partner_party_id = b.partner_customer_id
                  AND   a.lead_id = b.lead_id
                  AND   a.incumbent_partner_party_id is not null
                  AND   c.source_id = a.incumbent_partner_party_id) x,
             as_accesses_all d
             WHERE x.lead_id = d.lead_id
             AND   d.salesforce_id  = x.resource_id
             AND   x.customer_id = d.customer_id
             AND   x.address_id = d.address_id
             AND   x.org_id = d.org_id) z ;

        -- ----------------------------------------------------------
        -- Deleting the corrupted preferred partners
        --  ----------------------------------------------------------
      DELETE FROM as_accesses_all
      WHERE access_id IN ( SELECT access_id
                           FROM   pv_access_migration_log
                           WHERE  action = 'DELTE_CORRUPT_PF_PARTNER');
     /*
     *
     * Logging the delete activity of corrupted partners
     */

   INSERT INTO pv_access_migration_log
         (
          access_migration_log_id
         ,access_id
         ,action
         ,creation_date
         ,customer_id
         ,address_id
         ,salesforce_id
         ,partner_customer_id
         ,partner_address_id
         ,lead_id
         ,org_id
         ,open_flag
         )
         SELECT  pv_access_migration_log_s.nextval  access_migration_log_id,
                 access_id,
                 'DELETE_CORRUPT_OPP_PARTNER',
                 sysdate,
                 customer_id,
                 address_id,
                 salesforce_id,
                 partner_customer_id,
                 partner_address_id,
                 lead_id,
                 org_id,
                 open_flag
        FROM    ( SELECT  distinct access_id,
                         customer_id,
                         address_id,
                         salesforce_id,
                         partner_customer_id,
                         partner_address_id,
                         lead_id,
                         org_id,
                         open_flag
                 FROM   as_accesses_all a ,
                        pv_partner_profiles pvp
                 WHERE  a.partner_customer_id = pvp.partner_party_id
                 AND    EXISTS ( SELECT partner_customer_id
                                FROM    as_accesses_all acc,
                                        hz_relationships b
                                WHERE sales_lead_id IS  NULL
                                AND   lead_id IS NOT NULL
                                AND   a.customer_id = acc.customer_id
                                AND   b.object_id = pvp.partner_party_id
                                AND   b.party_id = acc.partner_cont_party_id
                                AND   acc.partner_cont_party_id IS NOT NULL)
                 AND    a.sales_lead_id IS NULL
                 AND    a.lead_id IS NOT NULL
		 AND    a.partner_cont_party_id IS NULL);


     INSERT INTO pv_access_migration_log
         (
          access_migration_log_id
         ,access_id
         ,action
         ,creation_date
         ,customer_id
         ,address_id
         ,salesforce_id
         ,partner_customer_id
         ,partner_address_id
         ,sales_lead_id
         ,org_id
         ,open_flag
         )
         SELECT  pv_access_migration_log_s.nextval  access_migration_log_id,
                 access_id,
                 'DELETE_CORRUPT_LEAD_PARTNER',
                 sysdate,
                 customer_id,
                 address_id,
                 salesforce_id,
                 partner_customer_id,
                 partner_address_id,
                 sales_lead_id,
                 org_id,
                 open_flag
        FROM    ( SELECT  distinct access_id,
                         customer_id,
                         address_id,
                         salesforce_id,
                         partner_customer_id,
                         partner_address_id,
                         sales_lead_id,
                         org_id,
                         open_flag
                 FROM   as_accesses_all a ,
                       pv_partner_profiles pvp
                 WHERE  a.partner_customer_id = pvp.partner_party_id
                 AND    EXISTS ( SELECT partner_customer_id
                                FROM   as_accesses_all acc,
                                       hz_relationships b
                                WHERE sales_lead_id IS NOT NULL
                                AND   lead_id IS NULL
                                AND   a.customer_id = acc.customer_id
                                AND   b.object_id = pvp.partner_party_id
                                AND   b.party_id = acc.partner_cont_party_id
                                AND   acc.partner_cont_party_id IS NOT NULL)
                 AND    a.lead_id IS  NULL
                 AND    a.sales_lead_id is not null
		 AND    a.partner_cont_party_id IS NULL);


     INSERT INTO pv_access_migration_log
         (
          access_migration_log_id
         ,access_id
         ,action
         ,creation_date
         ,customer_id
         ,address_id
         ,salesforce_id
         ,partner_customer_id
         ,partner_address_id
         ,org_id
         ,open_flag
         )
         SELECT  pv_access_migration_log_s.nextval  access_migration_log_id,
                 access_id,
                 'DELETE_CORRUPT_CUST_PARTNER',
                 sysdate,
                 customer_id,
                 address_id,
                 salesforce_id,
                 partner_customer_id,
                 partner_address_id,
                 org_id,
                 open_flag
         FROM    (SELECT distinct access_id,
                         customer_id,
                         address_id,
                         salesforce_id,
                         partner_customer_id,
                         partner_address_id,
                         org_id,
                         open_flag
                FROM   as_accesses_all a ,
                       pv_partner_profiles pvp
                WHERE  a.partner_customer_id = pvp.partner_party_id
                AND    EXISTS ( SELECT partner_customer_id
                                FROM   as_accesses_all acc,
                                       hz_relationships b
                                WHERE sales_lead_id IS NULL
                                AND   lead_id IS NULL
                                AND   a.customer_id = acc.customer_id
                                AND   b.object_id = pvp.partner_party_id
                                AND   b.party_id = acc.partner_cont_party_id
                                AND   acc.partner_cont_party_id IS NOT NULL)
                AND    a.lead_id IS  NULL
                AND    a.sales_lead_id is NULL
		AND    a.partner_cont_party_id IS NULL);

        -- ----------------------------------------------------------
        -- Deleting the corrupted partners
        --  ----------------------------------------------------------
      DELETE FROM as_accesses_all
      WHERE access_id IN ( SELECT access_id
                           FROM   pv_access_migration_log
                           WHERE  action IN ('DELETE_CORRUPT_CUST_PARTNER','DELETE_CORRUPT_LEAD_PARTNER','DELETE_CORRUPT_OPP_PARTNER'));
EXCEPTION
      WHEN OTHERS THEN
        printOutput('Database Error in deleting from logs : '||sqlerrm);
        g_ret_code := 2;
        RAISE;
END delete_corrupt_partner;

PROCEDURE clean_log
IS

BEGIN
       DELETE FROM  pv_access_migration_log;
EXCEPTION
      WHEN OTHERS THEN
        printOutput('Database Error in deleting from logs : '||sqlerrm);
        g_ret_code := 2;
        RAISE;
END;





PROCEDURE insert_cust_partner
IS

BEGIN
      BEGIN
         INSERT INTO pv_access_migration_log
         (
          access_migration_log_id
         ,access_id
         ,action
         ,creation_date
         ,access_type
         ,freeze_flag
         ,reassign_flag
         ,team_leader_flag
         ,customer_id
         ,address_id
         ,salesforce_id
         ,partner_customer_id
         ,partner_address_id
         ,lead_id
         ,salesforce_role_code
         ,org_id
         ,sales_group_id
         ,internal_update_access
         ,sales_lead_id
         ,partner_cont_party_id
         ,owner_flag
         ,created_by_tap_flag
         ,prm_keep_flag
         ,open_flag
         )
         SELECT  pv_access_migration_log_s.nextval  access_migration_log_id,
                 as_accesses_s.nextval access_id,
                 'INSERT_CUST_PARTY' action,
                  sysdate creation_date,
                  'X' access_type ,
                  'Y' freeze_flag,
                  'N' reassign_flag,
                  'Y' team_leader_flag,
                   customer_id,
                   address_id ,
                   resource_id salesforce_id,
                   partner_id partner_customer_id,
                   NULL partner_address_id,
                   NULL  ,
                   NULL salesforce_role_code,
                   NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99) ,
                   NULL salesgroup_id,
                   1 internal_update_access,
                   NULL sales_lead_id,
                   NULL parnter_cont_party_id,
                   'N' owner_flag,
                   'N' created_by_tap_flag,
                   'Y' prm_keep_flag ,
                    open_flag
         FROM  (
               SELECT sales_lead_id,
                        open_flag,
                        partner_id,
                        x.customer_id,
                        x.address_id,
                        org_id,
                        resource_id
               FROM (
                       SELECT distinct ACC.sales_lead_id,
                               acc.open_flag,
                               first_value(pvp.partner_id) over ( partition by ACC.lead_id, hz1.object_id order by pvp.status ASC,pvp.partner_id  desc) partner_id,
                               acc.customer_id,
                               acc.address_id,
                               acc.org_id
                        FROM   as_accesses_all ACC,
                               hz_relationships hz1,
                               pv_partner_profiles pvp
                        WHERE  ACC.partner_cont_party_id IS NOT NULL
                        AND    ACC.person_id IS NULL
                        AND    ACC.lead_id is null
                        AND    acc.sales_lead_id is null
                        AND    not exists (SELECT NULL
                                           FROM as_accesses_all acc2,
                                                pv_partner_profiles PVPP,
                                                hz_relationships hz
                                           WHERE acc2.customer_id = acc.customer_id
                                           AND acc2.partner_customer_id = PVPP.partner_id
                                           AND hz.object_id = pvpp.partner_party_id
                                           AND pvp.partner_party_id = pvpp.partner_party_id
                                           AND acc.partner_cont_party_id = hz.party_id
                                           AND ACC2.person_id IS NULL
                                           AND ACC2.lead_id is null
                                           AND acc2.sales_lead_id is null)
                        AND    ACC.partner_cont_party_id = hz1.party_id
                        AND    hz1.object_id = pvp.partner_party_id
                         ) x,
                          jtf_rs_resource_extns ext
                WHERE x.partner_id = ext.source_id
                AND   ext.category = 'PARTNER');
         printLog('No of Partners inserted into customer external sales team  :'||SQL%ROWCOUNT ||'- insert into access');

       EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK;
           printOutput('Database Error in insert partner logging to lead sales team : '||sqlerrm);
           g_ret_code := 2;
           RAISE;
       END;

       INSERT INTO as_accesses_all
        ( access_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          access_type,
          freeze_flag,
          reassign_flag,
          team_leader_flag,
          customer_id,
          address_id,
          salesforce_id,
          partner_customer_id,
          partner_address_id,
          lead_id,
          salesforce_role_code,
          org_id,
          sales_group_id,
          internal_update_access,
          partner_cont_party_id,
          owner_flag,
          created_by_tap_flag,
          prm_keep_flag,
          open_flag,
          object_version_number
        )
        SELECT  access_id,
          sysdate,
          FND_GLOBAL.user_id,
          sysdate,
          FND_GLOBAL.user_id,
          FND_GLOBAL.Conc_Login_Id,
          access_type,
          freeze_flag,
          reassign_flag,
          team_leader_flag,
          customer_id,
          address_id,
          salesforce_id,
          partner_customer_id,
          partner_address_id,
          lead_id,
          salesforce_role_code,
          org_id,
          sales_group_id,
          internal_update_access,
          NULL parnter_cont_party_id,
          owner_flag,
          created_by_tap_flag,
          prm_keep_flag,
          open_flag,
          NULL
        FROM pv_access_migration_log
        WHERE action = 'INSERT_CUST_PARTY';
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         printOutput('Database Error in inserting partners to customer external sales team '||sqlerrm);
         g_ret_code := 2;
         RAISE;
  END insert_cust_partner;

PROCEDURE insert_lead_partner
IS

BEGIN
      BEGIN
         INSERT INTO pv_access_migration_log
         (
          access_migration_log_id
         ,access_id
         ,action
         ,creation_date
         ,access_type
         ,freeze_flag
         ,reassign_flag
         ,team_leader_flag
         ,customer_id
         ,address_id
         ,salesforce_id
         ,partner_customer_id
         ,partner_address_id
         ,lead_id
         ,salesforce_role_code
         ,org_id
         ,sales_group_id
         ,internal_update_access
         ,sales_lead_id
         ,partner_cont_party_id
         ,owner_flag
         ,created_by_tap_flag
         ,prm_keep_flag
         ,open_flag
         )
         SELECT  pv_access_migration_log_s.nextval  access_migration_log_id,
                 as_accesses_s.nextval access_id,
                 'INSERT_LEAD_PARTY' action,
                  sysdate creation_date,
                  'X' access_type ,
                  'Y' freeze_flag,
                  'N' reassign_flag,
                  'Y' team_leader_flag,
                   customer_id,
                   address_id ,
                   resource_id salesforce_id,
                   partner_id partner_customer_id,
                   NULL partner_address_id,
                   NULL  ,
                   NULL salesforce_role_code,
                   org_id ,
                   NULL salesgroup_id,
                   1 internal_update_access,
                   sales_lead_id sales_lead_id,
                   NULL parnter_cont_party_id,
                   'N' owner_flag,
                   'N' created_by_tap_flag,
                   'Y' prm_keep_flag ,
                    open_flag
         FROM  (
                 SELECT sales_lead_id,
                        open_flag,
                        partner_id,
                        x.customer_id,
                        x.address_id,
                        org_id,
                        resource_id
                 FROM  ( SELECT distinct ACC.sales_lead_id,
                         acc.open_flag,
                         FIRST_VALUE(pvp.partner_id) OVER ( PARTITION BY ACC.lead_id, hz1.object_id  ORDER BY pvp.status ASC, pvp.partner_id DESC) partner_id,
                         asl.customer_id,
                         asl.address_id,
                         acc.org_id
                         FROM   as_accesses_all ACC,
                                hz_relationships hz1,
                                pv_partner_profiles pvp,
                                as_sales_leads asl
                         WHERE  ACC.sales_lead_id is not null
                         AND    ACC.partner_cont_party_id is not null
                         AND    ACC.person_id is null
                         AND    ASL.sales_lead_id = ACC.sales_lead_id
                         AND    not exists (SELECT NULL
                                            FROM as_accesses_all ACC2,
                                                 pv_partner_profiles PVPP,
                                                 hz_relationships HZ
                                            WHERE ACC2.sales_lead_id = ACC.sales_lead_id
                                            AND ACC2.partner_customer_id = PVPP.partner_id
                                            AND HZ.object_id = PVPP.partner_party_id
                                            AND PVP.partner_party_id = PVPP.partner_party_id
                                            AND ACC.partner_cont_party_id = HZ.party_id
                                            AND ACC2.person_id IS NULL
                                            AND ACC2.lead_id is null
                                            AND acc2.sales_lead_id is not null)
                         AND   ACC.partner_cont_party_id = hz1.party_id
                         AND   hz1.object_id = pvp.partner_party_id
                          ) x,
                          jtf_rs_resource_extns ext
                WHERE x.partner_id = ext.source_id
                AND   ext.category = 'PARTNER');

                printLog('No of Partners inserted into lead external sales team  :'||SQL%ROWCOUNT ||'- insert into access');

       EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK;
           printOutput('Database Error in insert partner logging to lead sales team : '||sqlerrm);
           g_ret_code := 2;
           RAISE;
       END;

       INSERT INTO as_accesses_all
        ( access_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          access_type,
          freeze_flag,
          reassign_flag,
          team_leader_flag,
          customer_id,
          address_id,
          salesforce_id,
          partner_customer_id,
          partner_address_id,
          sales_lead_id,
          salesforce_role_code,
          org_id,
          sales_group_id,
          internal_update_access,
          partner_cont_party_id,
          owner_flag,
          created_by_tap_flag,
          prm_keep_flag,
          open_flag,
          object_version_number
        )
        SELECT  access_id,
          sysdate,
          FND_GLOBAL.user_id,
          sysdate,
          FND_GLOBAL.user_id,
          FND_GLOBAL.Conc_Login_Id,
          access_type,
          freeze_flag,
          reassign_flag,
          team_leader_flag,
          customer_id,
          address_id,
          salesforce_id,
          partner_customer_id,
          partner_address_id,
          sales_lead_id,
          salesforce_role_code,
          org_id,
          sales_group_id,
          internal_update_access,
          NULL,
          owner_flag,
          created_by_tap_flag,
          prm_keep_flag,
          open_flag,
          NULL
        FROM pv_access_migration_log
        WHERE action = 'INSERT_LEAD_PARTY';
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         printOutput('Database Error in inserting partners to lead external sales team '||sqlerrm);
         g_ret_code := 2;
         RAISE;
  END insert_lead_partner;

--    --
--    Inserting partners into  opportunity External Sales team
--    when routing status of opportunity is active and
--    there are no partners associated with contacts in the sales team
--    --

PROCEDURE insert_opp_partner
IS

BEGIN
      BEGIN
         INSERT INTO pv_access_migration_log
         (
          access_migration_log_id
         ,access_id
         ,action
         ,creation_date
         ,access_type
         ,freeze_flag
         ,reassign_flag
         ,team_leader_flag
         ,customer_id
         ,address_id
         ,salesforce_id
         ,partner_customer_id
         ,partner_address_id
         ,lead_id
         ,salesforce_role_code
         ,org_id
         ,sales_group_id
         ,internal_update_access
         ,sales_lead_id
         ,partner_cont_party_id
         ,owner_flag
         ,created_by_tap_flag
         ,prm_keep_flag
         ,open_flag
         )
         SELECT  pv_access_migration_log_s.nextval  access_migration_log_id,
                 as_accesses_s.nextval access_id,
                 'INSERT_OPP_PARTY' action,
                  sysdate creation_date,
                  'X' access_type ,
                  'Y' freeze_flag,
                  'N' reassign_flag,
                  'Y' team_leader_flag,
                   customer_id,
                   address_id ,
                   resource_id salesforce_id,
                   partner_id partner_customer_id,
                   NULL partner_address_id,
                   lead_id  ,
                   NULL salesforce_role_code,
                   org_id ,
                   NULL salesgroup_id,
                   1 internal_update_access,
                   NULL sales_lead_id,
                   NULL parnter_cont_party_id,
                   'N' owner_flag,
                   'N' created_by_tap_flag,
                   'Y' prm_keep_flag ,
                    open_flag
         FROM  (
                 SELECT lead_id,
                        open_flag,
                        partner_id,
                        x.customer_id,
                        x.address_id,
                        org_id,
                        resource_id
                 FROM  ( SELECT distinct ACC.lead_id,
                         acc.open_flag,
                         CASE WHEN ass.partner_id is null
                              THEN FIRST_VALUE(pvp.partner_id) OVER ( PARTITION BY ACC.lead_id, hz1.object_id  ORDER BY pvp.status ASC, pvp.partner_id DESC)
                              WHEN ass.partner_id is not null
                                   and ass.status in ('LOST_CHANCE','PT_REJECTED','PT_TIMEOUT','OFFER_WITHDRAWN','MATCH_WITHDRAWN','ACTIVE_WITHDRAWN')
                              THEN NULL
                         ELSE ass.partner_id
                         END partner_id,
                         asl.customer_id,
                         asl.address_id,
                         asl.org_id
                         FROM   as_accesses_all ACC,
                                hz_relationships hz1,
                                pv_partner_profiles pvp,
                                as_leads_all asl,
                                pv_lead_assignments ass,
                                pv_lead_workflows pvw
                         WHERE  ACC.lead_id is not null
                         AND    ACC.partner_cont_party_id is not null
                         AND    ACC.person_id is null
                         AND    asl.lead_id = acc.lead_id
                         AND    not exists (SELECT NULL
                                            FROM as_accesses_all acc2,
                                                 pv_partner_profiles PVPP,
                                                 hz_relationships hz
                                            WHERE acc2.lead_id = acc.lead_id
                                            AND acc2.partner_customer_id = PVPP.partner_id
                                            AND hz.object_id = pvpp.partner_party_id
                                            AND pvp.partner_party_id = pvpp.partner_party_id
                                            AND acc.partner_cont_party_id = hz.party_id
                                            AND acc2.person_id IS NULL
                                            AND acc2.lead_id is not null
                                            AND acc2.sales_lead_id is null)
                        AND   not exists ( SELECT NULL
                                            FROM as_accesses_all acc3
                                            WHERE acc3.partner_customer_id = ass.partner_id
                                            AND   acc3.lead_id = ass.lead_id)
                         AND   ACC.partner_cont_party_id = hz1.party_id
                         AND   hz1.object_id = pvp.partner_party_id
                         AND   asl.lead_id = ass.lead_id(+)
                         AND   asl.lead_id = pvw.lead_ID(+)
                 AND   pvw.latest_routing_flag(+) = 'Y') x,
                          jtf_rs_resource_extns ext
                WHERE x.partner_id = ext.source_id
                AND   ext.category = 'PARTNER'
                AND   x.partner_id is not null);

         printLog('No of Partners inserted into active routed opportunity''s external sales team  :'||SQL%ROWCOUNT ||'- insert into access');

       EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK;
           printOutput('Database Error in insert partner logging to opportunity sales team : '||sqlerrm);
           g_ret_code := 2;
           RAISE;
       END;

       INSERT INTO as_accesses_all
        ( access_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          access_type,
          freeze_flag,
          reassign_flag,
          team_leader_flag,
          customer_id,
          address_id,
          salesforce_id,
          partner_customer_id,
          partner_address_id,
          lead_id,
          salesforce_role_code,
          org_id,
          sales_group_id,
          internal_update_access,
          partner_cont_party_id,
          owner_flag,
          created_by_tap_flag,
          prm_keep_flag,
          open_flag,
          object_version_number
        )
        SELECT  access_id,
          sysdate,
          FND_GLOBAL.user_id,
          sysdate,
          FND_GLOBAL.user_id,
          FND_GLOBAL.Conc_Login_Id,
          access_type,
          freeze_flag,
          reassign_flag,
          team_leader_flag,
          customer_id,
          address_id,
          salesforce_id,
          partner_customer_id,
          partner_address_id,
          lead_id,
          salesforce_role_code,
          org_id,
          sales_group_id,
          internal_update_access,
          partner_cont_party_id,
          owner_flag,
          created_by_tap_flag,
          prm_keep_flag,
          open_flag,
          NULL
        FROM pv_access_migration_log
        WHERE action = 'INSERT_OPP_PARTY';
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         printOutput('Database Error in inserting partners to opportunity external sales team '||sqlerrm);
         g_ret_code := 2;
         RAISE;
  END insert_opp_partner;

--    --
--    Inserting preferred partners from as_leads_all into  opportunity External Sales team
--    --

PROCEDURE insert_prefrd_partner
IS
   l_lead_id number;
BEGIN
    BEGIN
       INSERT INTO pv_access_migration_log
       (
        access_migration_log_id
       ,access_id
       ,action
       ,creation_date
       ,access_type
       ,freeze_flag
       ,reassign_flag
       ,team_leader_flag
       ,customer_id
       ,address_id
       ,salesforce_id
       ,partner_customer_id
       ,partner_address_id
       ,lead_id
       ,salesforce_role_code
       ,org_id
       ,sales_group_id
       ,internal_update_access
       ,sales_lead_id
       ,partner_cont_party_id
       ,owner_flag
       ,created_by_tap_flag
       ,prm_keep_flag
       ,open_flag
       )
       SELECT  pv_access_migration_log_s.nextval  access_migration_log_id,
              as_accesses_s.nextval access_id,
              'INSERT_OPP_PRFRD_PT' action,
               sysdate creation_date,
               'X' access_type ,
               'Y' freeze_flag,
               'N' reassign_flag,
               'Y' team_leader_flag,
                x.customer_id,
                x.address_id ,
                x.resource_id salesforce_id,
                x.incumbent_partner_party_id partner_id,
                NULL partner_address_id,
                x.lead_id  ,
                NULL salesforce_role_code,
                x.org_id ,
                NULL salesgroup_id,
                1 internal_update_access,
                NULL sales_lead_id,
                NULL parnter_cont_party_id,
                'N' owner_flag,
                'N' created_by_tap_flag,
                'Y' prm_keep_flag ,
                 NULL
       FROM  (
            SELECT distinct a.lead_id,
                   incumbent_partner_party_id,
                   c.resource_id ,
                   a.customer_id ,
                   a.address_id ,
                   a.org_id
            FROM   as_leads_all a,
                   jtf_rs_resource_extns c
            WHERE a.incumbent_partner_party_id is not null
            AND   c.category = 'PARTNER'
            AND   c.source_id = a.incumbent_partner_party_id
            MINUS
            SELECT distinct a.lead_id,
                   incumbent_partner_party_id,
                   c.resource_id ,
                   a.customer_id ,
                   a.address_id ,
                   a.org_id
            FROM   as_leads_all a,
                   as_accesses_all b,
                   jtf_rs_resource_extns c
            WHERE a.incumbent_partner_party_id = b.partner_customer_id
            AND   a.lead_id = b.lead_id
            AND   a.incumbent_partner_party_id is not null
            AND   c.category = 'PARTNER'
            AND   c.source_id = a.incumbent_partner_party_id  ) x
        WHERE NOT EXISTS ( SELECT NULL FROM as_accesses_all
                           where partner_customer_id = x.incumbent_partner_party_id
                           and lead_id = x.lead_id
                           and   salesforce_id = x.resource_id);
       EXCEPTION
         WHEN OTHERS THEN
          ROLLBACK;
          printOutput('Database Error in insert preferred partner logging to opportunity sales team : '||sqlerrm);
          g_ret_code := 2;
          RAISE;
       END;

       INSERT INTO as_accesses_all
       ( access_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         access_type,
         freeze_flag,
         reassign_flag,
         team_leader_flag,
         customer_id,
         address_id,
         salesforce_id,
         partner_customer_id,
         partner_address_id,
         lead_id,
         salesforce_role_code,
         org_id,
         sales_group_id,
         internal_update_access,
         partner_cont_party_id,
         owner_flag,
         created_by_tap_flag,
         prm_keep_flag,
         open_flag,
         object_version_number
       )
       SELECT  access_id,
         sysdate,
         FND_GLOBAL.user_id,
         sysdate,
         FND_GLOBAL.user_id,
         FND_GLOBAL.Conc_Login_Id,
         access_type,
         freeze_flag,
         reassign_flag,
         team_leader_flag,
         customer_id,
         address_id,
         salesforce_id,
         partner_customer_id,
         partner_address_id,
         lead_id,
         salesforce_role_code,
         org_id,
         sales_group_id,
         internal_update_access,
         partner_cont_party_id,
         owner_flag,
         created_by_tap_flag,
         prm_keep_flag,
         open_flag,
         NULL
       FROM pv_access_migration_log
       WHERE action = 'INSERT_OPP_PRFRD_PT';
EXCEPTION
    WHEN OTHERS THEN
          ROLLBACK;
          printOutput('Database Error in insert preferred partner logging to opportunity sales team : '||sqlerrm);
          g_ret_code := 2;
          RAISE;
END insert_prefrd_partner;
--    --
--    Inserting matched partners into  opportunity External Sales team
--    --
PROCEDURE insert_saved_partners
IS
BEGIN

    BEGIN
       INSERT INTO pv_access_migration_log
       (
        access_migration_log_id
       ,access_id
       ,action
       ,creation_date
       ,access_type
       ,freeze_flag
       ,reassign_flag
       ,team_leader_flag
       ,customer_id
       ,address_id
       ,salesforce_id
       ,partner_customer_id
       ,partner_address_id
       ,lead_id
       ,salesforce_role_code
       ,org_id
       ,sales_group_id
       ,internal_update_access
       ,sales_lead_id
       ,partner_cont_party_id
       ,owner_flag
       ,created_by_tap_flag
       ,prm_keep_flag
       ,open_flag
       )
       SELECT   pv_access_migration_log_s.nextval  access_migration_log_id,
                as_accesses_s.nextval access_id,
                'INSERT_OPP_SAVED_PT' action,
                sysdate creation_date,
                'X' access_type ,
                'Y' freeze_flag,
                'N' reassign_flag,
                'Y' team_leader_flag,
                 z.customer_id,
                 z.address_id ,
                 z.resource_id salesforce_id,
                 z.partner_id,
                 NULL partner_address_id,
                 z.lead_id  ,
                 NULL salesforce_role_code,
                 z.org_id ,
                 NULL salesgroup_id,
                 1 internal_update_access,
                 NULL sales_lead_id,
                 NULL parnter_cont_party_id,
                 'N' owner_flag,
                 'N' created_by_tap_flag,
                 'Y' prm_keep_flag ,
                 NULL
       FROM  (SELECT distinct x.customer_id,
                     x.address_id,
                     y.resource_id,
                     c.partner_id,
                     x.lead_id,
                     x.org_id
              FROM   pv_lead_assignments c,
                     as_leads_all x,
                     jtf_rs_resource_extns y
              WHERE  wf_item_type IS NULL
              AND    NOT EXISTS ( SELECT NULL
                                  FROM   pv_lead_assignments a, as_accesses_all b
                                  WHERE  a.partner_id = b.partner_customer_id
                                  AND    a.lead_id    = b.lead_id
                                  AND    c.lead_id    = a.lead_id
                                  AND    c.partner_id = b.partner_customer_id
                                  AND    salesforce_id = y.resource_id)
              AND    x.lead_id = c.lead_id
              AND    c.partner_id = y.source_id
              AND    y.category = 'PARTNER' ) z;

       EXCEPTION
         WHEN OTHERS THEN
          ROLLBACK;

          printOutput('Database Error in insert saved partner logging to opportunity sales team : '||sqlerrm);
          g_ret_code := 2;
          RAISE;
       END;

       INSERT INTO as_accesses_all
       ( access_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         access_type,
         freeze_flag,
         reassign_flag,
         team_leader_flag,
         customer_id,
         address_id,
         salesforce_id,
         partner_customer_id,
         partner_address_id,
         lead_id,
         salesforce_role_code,
         org_id,
         sales_group_id,
         internal_update_access,
         partner_cont_party_id,
         owner_flag,
         created_by_tap_flag,
         prm_keep_flag,
         open_flag,
         object_version_number
       )
       SELECT  access_id,
         sysdate,
         FND_GLOBAL.user_id,
         sysdate,
         FND_GLOBAL.user_id,
         FND_GLOBAL.Conc_Login_Id,
         access_type,
         freeze_flag,
         reassign_flag,
         team_leader_flag,
         customer_id,
         address_id,
         salesforce_id,
         partner_customer_id,
         partner_address_id,
         lead_id,
         salesforce_role_code,
         org_id,
         sales_group_id,
         internal_update_access,
         partner_cont_party_id,
         owner_flag,
         created_by_tap_flag,
         prm_keep_flag,
         open_flag,
         NULL
       FROM pv_access_migration_log
       WHERE action = 'INSERT_OPP_SAVED_PT';
EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK;
       printOutput('Database Error in insert saved partner to opportunity sales team : '||sqlcode||' : '||sqlerrm);
       g_ret_code := 2;
       RAISE;
END insert_saved_partners;

PROCEDURE insert_assigned_partners
IS
BEGIN

    BEGIN
       INSERT INTO pv_access_migration_log
       (
        access_migration_log_id
       ,access_id
       ,action
       ,creation_date
       ,access_type
       ,freeze_flag
       ,reassign_flag
       ,team_leader_flag
       ,customer_id
       ,address_id
       ,salesforce_id
       ,partner_customer_id
       ,partner_address_id
       ,lead_id
       ,salesforce_role_code
       ,org_id
       ,sales_group_id
       ,internal_update_access
       ,sales_lead_id
       ,partner_cont_party_id
       ,owner_flag
       ,created_by_tap_flag
       ,prm_keep_flag
       ,open_flag
       )
       SELECT   pv_access_migration_log_s.nextval  access_migration_log_id,
                as_accesses_s.nextval access_id,
                'INSERT_OPP_ASSIGNED_PT' action,
                sysdate creation_date,
                'X' access_type ,
                'Y' freeze_flag,
                'N' reassign_flag,
                'Y' team_leader_flag,
                 z.customer_id,
                 z.address_id ,
                 z.resource_id salesforce_id,
                 z.partner_id,
                 NULL partner_address_id,
                 z.lead_id  ,
                 NULL salesforce_role_code,
                 z.org_id ,
                 NULL salesgroup_id,
                 1 internal_update_access,
                 NULL sales_lead_id,
                 NULL parnter_cont_party_id,
                 'N' owner_flag,
                 'N' created_by_tap_flag,
                 'Y' prm_keep_flag ,
                 NULL
       FROM  (SELECT distinct x.customer_id,
                     x.address_id,
                     y.resource_id,
                     c.partner_id,
                     x.lead_id,
                     x.org_id
              FROM   pv_lead_assignments c,
                     as_leads_all x,
                     jtf_rs_resource_extns y
              WHERE  c.status = 'ASSIGNED'
              AND    NOT EXISTS ( SELECT NULL
                                  FROM   as_accesses_all b
                                  WHERE  c.lead_id    = b.lead_id
                                  AND    c.partner_id = b.partner_customer_id
                                  AND    b.salesforce_id = y.resource_id)
              AND    x.lead_id = c.lead_id
              AND    c.partner_id = y.source_id
              AND    y.category = 'PARTNER' ) z;

       EXCEPTION
         WHEN OTHERS THEN
          ROLLBACK;
          printOutput('Database Error in insert saved partner logging to opportunity sales team : '||sqlerrm);
          g_ret_code := 2;
          RAISE;
       END;

       INSERT INTO as_accesses_all
       ( access_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         access_type,
         freeze_flag,
         reassign_flag,
         team_leader_flag,
         customer_id,
         address_id,
         salesforce_id,
         partner_customer_id,
         partner_address_id,
         lead_id,
         salesforce_role_code,
         org_id,
         sales_group_id,
         internal_update_access,
         partner_cont_party_id,
         owner_flag,
         created_by_tap_flag,
         prm_keep_flag,
         open_flag,
         object_version_number
       )
       SELECT  access_id,
         sysdate,
         FND_GLOBAL.user_id,
         sysdate,
         FND_GLOBAL.user_id,
         FND_GLOBAL.Conc_Login_Id,
         access_type,
         freeze_flag,
         reassign_flag,
         team_leader_flag,
         customer_id,
         address_id,
         salesforce_id,
         partner_customer_id,
         partner_address_id,
         lead_id,
         salesforce_role_code,
         org_id,
         sales_group_id,
         internal_update_access,
         partner_cont_party_id,
         owner_flag,
         created_by_tap_flag,
         prm_keep_flag,
         open_flag,
         NULL
       FROM pv_access_migration_log
       WHERE action = 'INSERT_OPP_ASSIGNED_PT';
EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK;
       printOutput('Database Error in insert assigned partner to opportunity sales team : '||sqlcode||' : '||sqlerrm);
       g_ret_code := 2;
       RAISE;
END insert_assigned_partners;


PROCEDURE printReport(p_mode IN VARCHAR2)
IS

  l_temp_msg VARCHAR2(2000);
  l_count    NUMBER := 0;
  i          NUMBER := 0;
  l_title    VARCHAR2(200);
  l_migration_tbl migration_tbl_TYPE;



begin
  fnd_message.set_name('PV','PV_ACCESS_MIG_DESC');
  l_temp_msg := fnd_message.get;
  printOutput(RPAD('=',120,'='));
  printOutput(RPAD(' ',(120-length(l_temp_msg))/2,' ')||l_temp_msg);
  printOutput(RPAD('=',120,'='));
  printOutput(RPAD(' ',120,' '));
   -- Running Mode

  FOR x IN (
     SELECT decode(lookup_code,'EVALUATE','Evaluation',
                               'Execution') meaning
     FROM   fnd_lookup_values
     WHERE  lookup_type = 'PV_MIGRATION_RUN_MODE'
     AND    lookup_code = p_mode)
  LOOP
    fnd_message.set_name('PV','PV_CONCURRENT_MODE');
    fnd_message.set_token('P_MODE',x.meaning);
  END LOOP;


  l_temp_msg := fnd_message.get ;
  printOutput(RPAD(' ',(120-length(l_temp_msg))/2,' ')||l_temp_msg);
  printOutput(RPAD(' ',120,' '));
  printOutput(RPAD(' ',120,' '));
  printOutput(RPAD(' ',120,' '));
  BEGIN
          SELECT count(action)
          INTO   l_count
          FROM   pv_access_migration_log
          WHERE  action = 'DELTE_CORRUPT_PF_PARTNER';

          fnd_message.set_name('PV','PV_DEL_CRPT_PF_PT');
          l_temp_msg := fnd_message.get ||'  '||l_count;

          printOutput(RPAD('',(120-length(l_temp_msg))/2,' ')||l_temp_msg);
          printOutput(RPAD('-',120,'-'));
          IF l_count > 0 THEN
             FOR x in
            ( select distinct asl.description entity,
                     asl.lead_number entity_id,
                     b.party_name ,
                     a.salesforce_id
              from   pv_access_migration_log a,
                     hz_parties b,
                     pv_partner_profiles pvpp ,
                     as_leads_all asl
              where  a.partner_customer_id = pvpp.partner_id
              and    pvpp.partner_party_id = b.party_id
              and    asl.lead_id = a.lead_id
              and    a.action =  'DELTE_CORRUPT_PF_PARTNER' )
              loop
                  i := i + 1;
                  l_migration_tbl(i).entity := x.entity;
                  l_migration_tbl(i).entity_id := x.entity_id;
                  l_migration_tbl(i).party_name := x.party_name;
                  l_migration_tbl(i).resource_id := x.salesforce_id;
              end loop;
              fnd_message.set_name('PV','PV_OPP_NAME_ATTR');
              l_title := RPAD(fnd_message.get,50,' ');
              fnd_message.set_name('PV','PV_OPP_NUMBER_ATTR');
              l_title := l_title || RPAD(fnd_message.get,18,' ');
              fnd_message.set_name('PV','PV_PARTNER_NAME');
              l_title := l_title || RPAD(fnd_message.get,40,' ');
              fnd_message.set_name('PV','PV_RESOURCE_ID_ATTR');
              l_title := l_title || RPAD(fnd_message.get,13,' ');

              printOutput ( l_title);
              printOutput(RPAD('-',120,'-'));

              FOR j in 1 .. l_migration_tbl.count
              LOOP
                 printOutput( rpad(l_migration_tbl(j).entity,48,' ')||'  '||rpad(l_migration_tbl(j).entity_id,16,' ')||'  '||rpad(l_migration_tbl(j).party_name,38,' ')||'  '||rpad(l_migration_tbl(j).resource_id,11,' '));
              END LOOP;
              printOutput(RPAD('=',120,'='));
              l_migration_tbl.delete;
              l_count := 0;
              i := 0;
          END IF;
 EXCEPTION
   WHEN OTHERS THEN
     printOutput('Database Error in generating report for  deletion of preferred partners : '||sqlerrm);
 END;
      printOutput(RPAD(' ',120,' '));
      printOutput(RPAD(' ',120,' '));
      printOutput(RPAD(' ',120,' '));
  BEGIN
          SELECT count(action)
          INTO   l_count
          FROM   pv_access_migration_log
          WHERE  action = 'DELETE_CORRUPT_CUST_PARTNER';

          fnd_message.set_name('PV','PV_DEL_CUR_CUST_ESLSTM');
          l_temp_msg := fnd_message.get ||'  '||l_count;

          printOutput(RPAD('',(120-length(l_temp_msg))/2,' ')||l_temp_msg);
          printOutput(RPAD('-',120,'-'));
          IF l_count > 0 THEN
             FOR x in
            ( select d.party_name entity, d.party_number entity_id,
                     b.party_name , a.salesforce_id
              from   pv_access_migration_log a,
                     hz_parties b,
                     pv_partner_profiles pvpp ,
                     hz_parties d
              where  a.partner_customer_id = pvpp.partner_party_id
              and    pvpp.partner_party_id = b.party_id
              and    a.customer_id = d.party_id
              and    a.action = 'DELETE_CORRUPT_CUST_PARTNER' )
              loop
                  i := i + 1;
                  l_migration_tbl(i).entity := x.entity;
                  l_migration_tbl(i).entity_id := x.entity_id;
                  l_migration_tbl(i).party_name := x.party_name;
                  l_migration_tbl(i).resource_id := x.salesforce_id;
              end loop;
              fnd_message.set_name('PV','PV_CUSTOMER_NAME_ATTR');
              l_title := RPAD(fnd_message.get,50,' ');
              fnd_message.set_name('PV','PV_CUSTOMER_ID_ATTR');
              l_title := l_title || RPAD(fnd_message.get,18,' ');
              fnd_message.set_name('PV','PV_PARTNER_NAME');
              l_title := l_title || RPAD(fnd_message.get,40,' ');
              fnd_message.set_name('PV','PV_RESOURCE_ID_ATTR');
              l_title := l_title || RPAD(fnd_message.get,13,' ');

              printOutput ( l_title);
              printOutput(RPAD('-',120,'-'));

              FOR j in 1 .. l_migration_tbl.count
              LOOP
                 printOutput( rpad(l_migration_tbl(j).entity,48,' ')||'  '||rpad(l_migration_tbl(j).entity_id,16,' ')||'  '||rpad(l_migration_tbl(j).party_name,38,' ')||'  '||rpad(l_migration_tbl(j).resource_id,11,' '));
              END LOOP;
              printOutput(RPAD('=',120,'='));

              l_migration_tbl.delete;
              l_count := 0;
              i := 0;
          END IF;
 EXCEPTION
   WHEN OTHERS THEN
     printOutput('Database Error in generating report for customer external sales team partners : '||sqlerrm);
 END;
      printOutput(RPAD(' ',120,' '));
      printOutput(RPAD(' ',120,' '));
      printOutput(RPAD(' ',120,' '));
 BEGIN

          SELECT count(action)
          INTO   l_count
          FROM   pv_access_migration_log
          WHERE  action = 'DELETE_CORRUPT_LEAD_PARTNER';

          fnd_message.set_name('PV','PV_DEL_PTR_LEAD_ESLSTM');
          l_temp_msg := fnd_message.get ||'  '||l_count;

          printOutput(RPAD('',(120-length(l_temp_msg))/2,' ')||l_temp_msg);
          printOutput(RPAD('-',120,'-'));
          IF l_count > 0 THEN
             FOR x in
            ( select asl.description entity, asl.lead_number entity_id,
               b.party_name , a.salesforce_id
              from   pv_access_migration_log a,
                     hz_parties b,
                     pv_partner_profiles pvpp ,
                     as_sales_leads asl
              where  a.partner_customer_id = pvpp.partner_party_id
              and    pvpp.partner_party_id = b.party_id
              and    asl.sales_lead_id = a.sales_lead_id
              and    a.action = 'DELETE_CORRUPT_LEAD_PARTNER' )
              loop
                  i := i + 1;
                  l_migration_tbl(i).entity := x.entity;
                  l_migration_tbl(i).entity_id := x.entity_id;
                  l_migration_tbl(i).party_name := x.party_name;
                  l_migration_tbl(i).resource_id := x.salesforce_id;
              end loop;

              fnd_message.set_name('PV','PV_LEAD_NAME_ATTR');
              l_title := RPAD(fnd_message.get,50,' ');
              fnd_message.set_name('PV','PV_LEAD_ID_ATTR');
              l_title := l_title || RPAD(fnd_message.get,18,' ');
              fnd_message.set_name('PV','PV_PARTNER_NAME');
              l_title := l_title || RPAD(fnd_message.get,40,' ');
              fnd_message.set_name('PV','PV_RESOURCE_ID_ATTR');
              l_title := l_title || RPAD(fnd_message.get,13,' ');

              printOutput ( l_title);
              printOutput(RPAD('-',120,'-'));

              FOR j in 1 .. l_migration_tbl.count
              LOOP
                 printOutput( rpad(l_migration_tbl(j).entity,48,' ')||'  '||rpad(l_migration_tbl(j).entity_id,16,' ')||'  '||rpad(l_migration_tbl(j).party_name,38,' ')||'  '||rpad(l_migration_tbl(j).resource_id,11,' '));
              END LOOP;
              printOutput(RPAD('=',120,'='));
             l_migration_tbl.delete;
             l_count := 0;
             i := 0;
          END IF;
 EXCEPTION
    WHEN OTHERS THEN
     printOutput('Database Error in generating report for lead external sales team partners : '||sqlerrm);
 END;

  printOutput(RPAD(' ',120,' '));
  printOutput(RPAD(' ',120,' '));
  printOutput(RPAD(' ',120,' '));

BEGIN
          SELECT count(action)
          INTO   l_count
          FROM   pv_access_migration_log
          WHERE  action = 'DELETE_CORRUPT_OPP_PARTNER';

          fnd_message.set_name('PV','PV_DEL_PTR_OPP_ESLSTM');
          l_temp_msg := fnd_message.get ||'  '||l_count;


          printOutput(RPAD('',(120-length(l_temp_msg))/2,' ')||l_temp_msg);
          printOutput(RPAD('-',120,'-'));


          IF l_count > 0 THEN
             FOR x in
            ( select distinct asl.description entity,
                     asl.lead_number entity_id,
                     b.party_name ,
                     a.salesforce_id
              from   pv_access_migration_log a,
                     hz_parties b,
                     pv_partner_profiles pvpp ,
                     as_leads_all asl
              where  a.partner_customer_id = pvpp.partner_party_id
              and    pvpp.partner_party_id = b.party_id
              and    asl.lead_id = a.lead_id
              and    a.action = 'DELETE_CORRUPT_OPP_PARTNER')
              loop
                  i := i + 1;
                  l_migration_tbl(i).entity := x.entity;
                  l_migration_tbl(i).entity_id := x.entity_id;
                  l_migration_tbl(i).party_name := x.party_name;
                  l_migration_tbl(i).resource_id := x.salesforce_id;
              end loop;

              fnd_message.set_name('PV','PV_OPP_NAME_ATTR');
              l_title := RPAD(fnd_message.get,50,' ');
              fnd_message.set_name('PV','PV_OPP_NUMBER_ATTR');
              l_title := l_title || RPAD(fnd_message.get,18,' ');
              fnd_message.set_name('PV','PV_PARTNER_NAME');
              l_title := l_title || RPAD(fnd_message.get,40,' ');
              fnd_message.set_name('PV','PV_RESOURCE_ID_ATTR');
              l_title := l_title || RPAD(fnd_message.get,13,' ');

              printOutput ( l_title);
              printOutput(RPAD('-',120,'-'));

              FOR j in 1 .. l_migration_tbl.count
              LOOP
                 printOutput( rpad(l_migration_tbl(j).entity,48,' ')||'  '||rpad(l_migration_tbl(j).entity_id,16,' ')||'  '||rpad(l_migration_tbl(j).party_name,38,' ')||'  '||rpad(l_migration_tbl(j).resource_id,11,' '));
              END LOOP;
              printOutput(RPAD('=',120,'='));

             l_migration_tbl.delete;
             l_count := 0;
             i := 0;
          END IF;
 EXCEPTION
    WHEN OTHERS THEN
     printOutput('Database Error in generating report for Opportunity external sales team partners : '||sqlerrm);
 END;
      printOutput(RPAD(' ',120,' '));
      printOutput(RPAD(' ',120,' '));
      printOutput(RPAD(' ',120,' '));

  BEGIN
          SELECT count(action)
          INTO   l_count
          FROM   pv_access_migration_log
          WHERE  action = 'INSERT_CUST_PARTY';

          fnd_message.set_name('PV','PV_INS_PTR_CUST_ESLSTM');
          l_temp_msg := fnd_message.get ||'  '||l_count;

          printOutput(RPAD('',(120-length(l_temp_msg))/2,' ')||l_temp_msg);
          printOutput(RPAD('-',120,'-'));
          IF l_count > 0 THEN
             FOR x in
            ( select d.party_name entity, d.party_number entity_id,
                     b.party_name , a.salesforce_id
              from   pv_access_migration_log a,
                     hz_parties b,
                     pv_partner_profiles pvpp ,
                     hz_parties d
              where  a.partner_customer_id = pvpp.partner_id
              and    pvpp.partner_party_id = b.party_id
              and    a.customer_id = d.party_id
              and    a.action = 'INSERT_CUST_PARTY' )
              loop
                  i := i + 1;
                  l_migration_tbl(i).entity := x.entity;
                  l_migration_tbl(i).entity_id := x.entity_id;
                  l_migration_tbl(i).party_name := x.party_name;
                  l_migration_tbl(i).resource_id := x.salesforce_id;
              end loop;
              fnd_message.set_name('PV','PV_CUSTOMER_NAME_ATTR');
              l_title := RPAD(fnd_message.get,50,' ');
              fnd_message.set_name('PV','PV_CUSTOMER_ID_ATTR');
              l_title := l_title || RPAD(fnd_message.get,18,' ');
              fnd_message.set_name('PV','PV_PARTNER_NAME');
              l_title := l_title || RPAD(fnd_message.get,40,' ');
              fnd_message.set_name('PV','PV_RESOURCE_ID_ATTR');
              l_title := l_title || RPAD(fnd_message.get,13,' ');

              printOutput ( l_title);
              printOutput(RPAD('-',120,'-'));

              FOR j in 1 .. l_migration_tbl.count
              LOOP
                 printOutput( rpad(l_migration_tbl(j).entity,48,' ')||'  '||rpad(l_migration_tbl(j).entity_id,16,' ')||'  '||rpad(l_migration_tbl(j).party_name,38,' ')||'  '||rpad(l_migration_tbl(j).resource_id,11,' '));
              END LOOP;
              printOutput(RPAD('=',120,'='));

              l_migration_tbl.delete;
              l_count := 0;
              i := 0;
          END IF;
 EXCEPTION
   WHEN OTHERS THEN
     printOutput('Database Error in generating report for customer external sales team partners : '||sqlerrm);
 END;
      printOutput(RPAD(' ',120,' '));
      printOutput(RPAD(' ',120,' '));
      printOutput(RPAD(' ',120,' '));
 BEGIN

          SELECT count(action)
          INTO   l_count
          FROM   pv_access_migration_log
          WHERE  action = 'INSERT_LEAD_PARTY';

          fnd_message.set_name('PV','PV_INS_PTR_LEAD_ESLSTM');
          l_temp_msg := fnd_message.get ||'  '||l_count;

          printOutput(RPAD('',(120-length(l_temp_msg))/2,' ')||l_temp_msg);
          printOutput(RPAD('-',120,'-'));
          IF l_count > 0 THEN
             FOR x in
            ( select asl.description entity, asl.lead_number entity_id,
               b.party_name , a.salesforce_id
              from   pv_access_migration_log a,
                     hz_parties b,
                     pv_partner_profiles pvpp ,
                     as_sales_leads asl
              where  a.partner_customer_id = pvpp.partner_id
              and    pvpp.partner_party_id = b.party_id
              and    asl.sales_lead_id = a.sales_lead_id
              and    a.action = 'INSERT_LEAD_PARTY' )
              loop
                  i := i + 1;
                  l_migration_tbl(i).entity := x.entity;
                  l_migration_tbl(i).entity_id := x.entity_id;
                  l_migration_tbl(i).party_name := x.party_name;
                  l_migration_tbl(i).resource_id := x.salesforce_id;
              end loop;

              fnd_message.set_name('PV','PV_LEAD_NAME_ATTR');
              l_title := RPAD(fnd_message.get,50,' ');
              fnd_message.set_name('PV','PV_LEAD_ID_ATTR');
              l_title := l_title || RPAD(fnd_message.get,18,' ');
              fnd_message.set_name('PV','PV_PARTNER_NAME');
              l_title := l_title || RPAD(fnd_message.get,40,' ');
              fnd_message.set_name('PV','PV_RESOURCE_ID_ATTR');
              l_title := l_title || RPAD(fnd_message.get,13,' ');

              printOutput ( l_title);
              printOutput(RPAD('-',120,'-'));

              FOR j in 1 .. l_migration_tbl.count
              LOOP
                 printOutput( rpad(l_migration_tbl(j).entity,48,' ')||'  '||rpad(l_migration_tbl(j).entity_id,16,' ')||'  '||rpad(l_migration_tbl(j).party_name,38,' ')||'  '||rpad(l_migration_tbl(j).resource_id,11,' '));
              END LOOP;
              printOutput(RPAD('=',120,'='));
             l_migration_tbl.delete;
             l_count := 0;
             i := 0;
          END IF;
 EXCEPTION
    WHEN OTHERS THEN
     printOutput('Database Error in generating report for lead external sales team partners : '||sqlerrm);
 END;

  printOutput(RPAD(' ',120,' '));
  printOutput(RPAD(' ',120,' '));
  printOutput(RPAD(' ',120,' '));

BEGIN
          SELECT count(action)
          INTO   l_count
          FROM   pv_access_migration_log
          WHERE  action IN ('INSERT_OPP_PARTY','INSERT_OPP_PRFRD_PT','INSERT_OPP_SAVED_PT','INSERT_OPP_ASSIGNED_PT');

          fnd_message.set_name('PV','PV_INS_PTR_OPP_ESLSTM');
          l_temp_msg := fnd_message.get ||'  '||l_count;


          printOutput(RPAD('',(120-length(l_temp_msg))/2,' ')||l_temp_msg);
          printOutput(RPAD('-',120,'-'));


          IF l_count > 0 THEN
             FOR x in
            ( select distinct asl.description entity,
                     asl.lead_number entity_id,
                     b.party_name ,
                     a.salesforce_id
              from   pv_access_migration_log a,
                     hz_parties b,
                     pv_partner_profiles pvpp ,
                     as_leads_all asl
              where  a.partner_customer_id = pvpp.partner_id
              and    pvpp.partner_party_id = b.party_id
              and    asl.lead_id = a.lead_id
              and    a.action IN ('INSERT_OPP_PARTY','INSERT_OPP_PRFRD_PT','INSERT_OPP_SAVED_PT','INSERT_OPP_ASSIGNED_PT'))
              loop
                  i := i + 1;
                  l_migration_tbl(i).entity := x.entity;
                  l_migration_tbl(i).entity_id := x.entity_id;
                  l_migration_tbl(i).party_name := x.party_name;
                  l_migration_tbl(i).resource_id := x.salesforce_id;
              end loop;

              fnd_message.set_name('PV','PV_OPP_NAME_ATTR');
              l_title := RPAD(fnd_message.get,50,' ');
              fnd_message.set_name('PV','PV_OPP_NUMBER_ATTR');
              l_title := l_title || RPAD(fnd_message.get,18,' ');
              fnd_message.set_name('PV','PV_PARTNER_NAME');
              l_title := l_title || RPAD(fnd_message.get,40,' ');
              fnd_message.set_name('PV','PV_RESOURCE_ID_ATTR');
              l_title := l_title || RPAD(fnd_message.get,13,' ');

              printOutput ( l_title);
              printOutput(RPAD('-',120,'-'));

              FOR j in 1 .. l_migration_tbl.count
              LOOP
                 printOutput( rpad(l_migration_tbl(j).entity,48,' ')||'  '||rpad(l_migration_tbl(j).entity_id,16,' ')||'  '||rpad(l_migration_tbl(j).party_name,38,' ')||'  '||rpad(l_migration_tbl(j).resource_id,11,' '));
              END LOOP;
              printOutput(RPAD('=',120,'='));
             l_migration_tbl.delete;
             l_count := 0;
             i := 0;
          END IF;
 EXCEPTION
    WHEN OTHERS THEN
     printOutput('Database Error in generating report for Opportunity external sales team partners : '||sqlerrm);
 END;

END printReport;

PROCEDURE printLog(p_message IN VARCHAR2)
IS
BEGIN
   FND_FILE.PUT_LINE(FND_FILE.LOG,p_message);
END printLog;

PROCEDURE printOutput(p_message IN VARCHAR2)
IS
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_message);
--  printOutput(p_message);
END printOutput;

END PV_SLSTEAM_MIGRTN_PVT;

/
