--------------------------------------------------------
--  DDL for Package Body ASN_MIG_SALES_TEAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASN_MIG_SALES_TEAM_PVT" AS
/* $Header: asnvmstb.pls 120.7 2007/12/26 08:22:31 snsarava ship $ */

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   asn_mig_sales_team_pvt
  --
  -- PURPOSE
  --   This package contains migration related code for sales team.
  --
  -- NOTES
  --
  -- HISTORY
  -- sumahali      01/09/2005           Created
  -- **********************************************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):='asn_mig_sales_team_pvt';
G_FILE_NAME CONSTANT VARCHAR2(12):='asnvmscb.pls';

--
--

-- Fix Lead Line and Sales Credits End Day Flags
PROCEDURE FixEnddayFlags (p_lead_id     IN NUMBER, p_debug_flag IN VARCHAR2)
 IS

  l_module_name             CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_team_pvt.FixEnddayFlags';

  TYPE NumTab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE DateTab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE Var1Tab IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

  l_log_ids             NumTab;
  l_lead_line_ids       NumTab;
  l_sales_credit_ids    NumTab;
  l_last_update_dates   DateTab;
  l_endday_log_flags    Var1Tab;

  l_future_date             DATE := sysdate + 1000;
  l_prev_last_update_date   DATE;
  l_last_update_date        DATE;
  l_prev_lead_line_id       NUMBER;
  l_prev_sales_credit_id    NUMBER;
  l_endday_log_flag         VARCHAR2(1);
  l_update_count            NUMBER;

  CURSOR c_lead_line_logs(p_lead_id NUMBER)  IS
    SELECT log_id, lead_line_id, last_update_date
    FROM   as_lead_lines_log
    WHERE  lead_id = p_lead_id
    ORDER BY lead_line_id ASC, last_update_date DESC, log_id DESC;

  CURSOR c_sales_credits_logs(p_lead_id NUMBER)  IS
    SELECT log_id, sales_credit_id, last_update_date
    FROM   as_sales_credits_log
    WHERE  lead_id = p_lead_id
    ORDER BY sales_credit_id ASC, last_update_date DESC, log_id DESC;

BEGIN
  IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'Start Lead Line Logs Log for lead_id=' || p_lead_id);
  END IF;

  OPEN c_lead_line_logs(p_lead_id);
  FETCH c_lead_line_logs BULK COLLECT
  INTO l_log_ids, l_lead_line_ids, l_last_update_dates;
  CLOSE c_lead_line_logs;

  IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'Num Lead Line Logs Logs=' || l_log_ids.COUNT);
  END IF;

  l_update_count := 0;

  IF l_log_ids.COUNT > 0 THEN
    l_prev_lead_line_id := -37;
    FOR i IN l_log_ids.FIRST..l_log_ids.LAST LOOP
      IF l_lead_line_ids(i) <> l_prev_lead_line_id THEN
          l_prev_lead_line_id := l_lead_line_ids(i);
          l_prev_last_update_date := l_future_date;
      END IF;

      l_endday_log_flag := 'Y';
      l_last_update_date := trunc(l_last_update_dates(i));
      IF l_prev_last_update_date = l_last_update_date THEN
          l_endday_log_flag := 'N';
      END IF;

      l_endday_log_flags(i) := l_endday_log_flag;
      l_prev_last_update_date := l_last_update_date;
    END LOOP;

    FORALL i IN l_log_ids.FIRST..l_log_ids.LAST
      UPDATE as_lead_lines_log -- @@
      SET    endday_log_flag = l_endday_log_flags(i)
      WHERE  log_id = l_log_ids(i) AND endday_log_flag IS NULL;

    l_update_count := SQL%ROWCOUNT;
  END IF;

  IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'Num Lead Line Logs Updated=' || l_update_count);
  END IF;

  OPEN c_sales_credits_logs(p_lead_id);
  FETCH c_sales_credits_logs BULK COLLECT
  INTO l_log_ids, l_sales_credit_ids, l_last_update_dates;
  CLOSE c_sales_credits_logs;

  IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'Num Sales Credits Logs=' || l_log_ids.COUNT);
  END IF;

  l_update_count := 0;

  IF l_log_ids.COUNT > 0 THEN
    l_prev_sales_credit_id := -37;
    FOR i IN l_log_ids.FIRST..l_log_ids.LAST LOOP
      IF l_sales_credit_ids(i) <> l_prev_sales_credit_id THEN
          l_prev_sales_credit_id := l_sales_credit_ids(i);
          l_prev_last_update_date := l_future_date;
      END IF;

      l_endday_log_flag := 'Y';
      l_last_update_date := trunc(l_last_update_dates(i));
      IF l_prev_last_update_date = l_last_update_date THEN
          l_endday_log_flag := 'N';
      END IF;

      l_endday_log_flags(i) := l_endday_log_flag;
      l_prev_last_update_date := l_last_update_date;
    END LOOP;

    FORALL i IN l_log_ids.FIRST..l_log_ids.LAST
      UPDATE as_sales_credits_log  -- @@
      SET    endday_log_flag = l_endday_log_flags(i)
      WHERE  log_id = l_log_ids(i) AND endday_log_flag IS NULL;

    l_update_count := SQL%ROWCOUNT;
  END IF;

  IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'End fixlog for Lead id: ' || p_lead_id ||
                   ' Num Sales Credits Updated=' || l_update_count);
  END IF;
END FixEnddayFlags;
--Code added for ASN migration approach suggested by lester  -- Start  -- @@
PROCEDURE Mig_Dup_SalesRep_Opp (
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY NUMBER,
    p_start_id       IN VARCHAR2,
    p_end_id         IN VARCHAR2,
    p_commit_flag    IN VARCHAR2,
    p_batch_size     IN NUMBER,
    p_debug_flag     IN VARCHAR2
    )
 IS

  l_module_name             CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_team_pvt.Mig_Dup_SalesRep_Opp';

  l_uncommitted_opps        NUMBER := 0;
  l_remove_count            NUMBER;
  l_custfix_count           NUMBER;
  l_lead_id                 NUMBER;
  l_customer_id             NUMBER;
  l_access_id               NUMBER;
  l_user_id                 NUMBER;

 /* CURSOR c_opps_in_range(p_start_id NUMBER, p_end_id NUMBER)  IS
    SELECT lead_id, customer_id
    FROM   as_leads_all
    WHERE  lead_id BETWEEN p_start_id AND p_end_id; */

CURSOR c_opps_in_range(p_start_id NUMBER, p_end_id NUMBER)  IS
    SELECT DISTINCT lead_id
    FROM   AS_ACCESSES_ALL_OPP_TEMP
    WHERE  lead_id BETWEEN p_start_id AND p_end_id;

 /* CURSOR c_uniq_steam(p_lead_id NUMBER) IS
    SELECT max(decode(SALESFORCE_ROLE_CODE, NULL, 'N', 'Y') || ACCESS_ID) code_access_id,
           salesforce_id, sales_group_id, partner_customer_id,
           partner_cont_party_id,
           max(nvl(FREEZE_FLAG, 'N')) freeze_flag,
           max(nvl(TEAM_LEADER_FLAG, 'N')) team_leader_flag,
           max(nvl(OWNER_FLAG, 'N')) owner_flag,
           max(nvl(CONTRIBUTOR_FLAG, 'N')) contributor_flag
    FROM   AS_ACCESSES_ALL
    WHERE  lead_id = p_lead_id
    GROUP BY salesforce_id, sales_group_id, partner_customer_id,
             partner_cont_party_id
    HAVING count(access_id) > 1; */

--Code added for ASN migration approach suggested by lester  -- Start
CURSOR c_uniq_steam(p_lead_id NUMBER) IS
SELECT lead_id,max(code_access_id) code_access_id,
           salesforce_id, sales_group_id, partner_customer_id,
           partner_cont_party_id,
           max(FREEZE_FLAG) freeze_flag,
           max(TEAM_LEADER_FLAG) team_leader_flag,
           max(OWNER_FLAG) owner_flag,
           max(CONTRIBUTOR_FLAG) contributor_flag
    FROM  AS_ACCESSES_ALL_OPP_TEMP  -- AS_ACCESSES_ALL
    WHERE  lead_id = p_lead_id
    GROUP BY lead_id,salesforce_id, sales_group_id, partner_customer_id,
             partner_cont_party_id;

CURSOR c1 IS SELECT as_leads_s.nextval FROM dual;
l_max_num_rows NUMBER;
--Code added for ASN migration approach suggested by lester  -- End

BEGIN

    -- Log
    IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
          'Begin OSO->ASN Duplicate Sales Rep Opportunity Data Migration.');
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                 'Start:' || 'p_start_id=' || p_start_id ||
                 ',p_end_id='||p_end_id ||
                 ',p_debug_flag='||p_debug_flag);
    END IF;

    l_user_id := FND_GLOBAL.user_id;

    IF l_user_id IS NULL THEN
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module_name,
              'Opportunities: Error: Global User Id is not set');
      END IF;
      RETURN;
    END IF;

    OPEN c1;
    FETCH c1 INTO l_max_num_rows;
    CLOSE c1;

    FOR opp_rec in c_opps_in_range(p_start_id, p_end_id) LOOP -- start Main opportunity loop  -- @@
      BEGIN
        savepoint CURR_OPP;

        l_lead_id := opp_rec.lead_id; -- @@

      --  FixEnddayFlags(l_lead_id, p_debug_flag);

        l_remove_count := 0;
        -- Will return one of Sales Team members of duplicates grouped by
        -- Salesforce id, Sales Group id, union of flags (i.e flag is Y if
        -- any one of duplicate members has it as Y, else  N), returns
        -- access_id of a record with SALESFORCE_ROLE_CODE non null
        -- if available else any access_id prefixed with Y or N
         FOR uniq_steam_rec in c_uniq_steam(l_lead_id) LOOP

          IF (p_debug_flag = 'Y' AND
            FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'Opportunities: Cleaning up duplicates for coded_access_id: ' ||
                uniq_steam_rec.code_access_id ||
                ' sf_id ' || uniq_steam_rec.salesforce_id ||
                ' sg_id ' || uniq_steam_rec.sales_group_id ||
                ' freeze_flag ' || uniq_steam_rec.freeze_flag ||
                ' team_leader_flag ' || uniq_steam_rec.team_leader_flag ||
                ' owner_flag ' || uniq_steam_rec.owner_flag ||
                ' contributor_flag ' || uniq_steam_rec.contributor_flag);
          END IF;

          l_access_id := substr(uniq_steam_rec.code_access_id, 2);
          UPDATE AS_ACCESSES_ALL_ALL -- @@
          SET DELETE_FLAG = 'Y',
              LAST_UPDATED_BY = l_user_id,
              LAST_UPDATE_DATE = sysdate,
              LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id
          WHERE lead_id = l_lead_id AND  -- @@
                salesforce_id = uniq_steam_rec.salesforce_id AND
                nvl(sales_group_id, -37) = nvl(uniq_steam_rec.sales_group_id, -37) AND
                nvl(partner_customer_id, -37) = nvl(uniq_steam_rec.partner_customer_id, -37) AND
                nvl(partner_cont_party_id, -37) = nvl(uniq_steam_rec.partner_cont_party_id, -37) AND
                access_id <> l_access_id AND
                delete_flag IS NULL;

          l_remove_count := l_remove_count + SQL%ROWCOUNT;

          UPDATE AS_ACCESSES_ALL -- @@
          SET FREEZE_FLAG = uniq_steam_rec.freeze_flag,
              TEAM_LEADER_FLAG = uniq_steam_rec.team_leader_flag,
              OWNER_FLAG = uniq_steam_rec.owner_flag,
              CONTRIBUTOR_FLAG = uniq_steam_rec.contributor_flag,
              LAST_UPDATED_BY = l_user_id,
              LAST_UPDATE_DATE = sysdate,
              LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id
          WHERE access_id = l_access_id;
        END  LOOP;
---- @@
 IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
              'Successfully processed Opp Id: ' || l_lead_id || ' Entries removed ' || l_remove_count);
          IF l_custfix_count > 0 THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
              'Opp Id: ' || l_lead_id || ' CUSTOMER_ID fixes ' || l_custfix_count);
          END IF;
        END IF;


        l_uncommitted_opps := l_uncommitted_opps + 1;

        IF l_uncommitted_opps >= p_batch_size THEN
          IF p_commit_flag = 'Y' THEN
            IF (p_debug_flag = 'Y' AND
                FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'Calling Commit after processing ' || l_uncommitted_opps || ' Opportunities');
            END IF;
            COMMIT;
          ELSE
            ROLLBACK;
          END IF;
          l_uncommitted_opps := 0;
        END IF;

        EXCEPTION
        WHEN OTHERS then
            Rollback to CURR_OPP;
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                        'Error Processing Opp Id : ' || l_lead_id);
                FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                        'SQL Error Msg, opp_id: ' || l_lead_id || ': '
                        || substr(SQLERRM, 1, 1950));
            END IF;
      END;
    END LOOP; -- end Main opportunity loop  -- @@

	--Logic needs to be changed -- @@ START

          IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
              'Successfully processed Opp Id: ' || l_lead_id || ' Entries removed ' || l_remove_count);
        END IF;

	--Logic needs to be changed -- @@ --END
    -- Commit
    IF (p_commit_flag = 'Y') THEN
      -- Log
      IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'Opprtunities: Committing');
      END IF;
      COMMIT;
    ELSE
      -- Log
      IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'Opportunities: Rolling back');
      END IF;
       ROLLBACK;
    END IF;

    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name, 'End of OSO->ASN Duplicate Sales Team Opportunity Data Migration.');
    END IF;

End Mig_Dup_SalesRep_Opp;
--Code added for ASN migration approach suggested by lester  -- End    --  @@

--
--
--Code added for ASN migration approach suggested by lester  -- Start -- @@
--lead sub
PROCEDURE Mig_Dup_SalesRep_Lead (
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY NUMBER,
    p_start_id       IN VARCHAR2,
    p_end_id         IN VARCHAR2,
    p_commit_flag    IN VARCHAR2,
    p_batch_size     IN NUMBER,
    p_debug_flag     IN VARCHAR2
    )
 IS

  l_module_name             CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_team_pvt.Mig_Dup_SalesRep_Lead';

  l_uncommitted_leads       NUMBER := 0;
  l_remove_count            NUMBER;
  l_updated_flag            BOOLEAN;
  l_sales_lead_id           NUMBER;
  l_access_id               NUMBER;
  l_user_id                 NUMBER;

  CURSOR c_leads_in_range(p_start_id NUMBER, p_end_id NUMBER)  IS
    SELECT DISTINCT sales_lead_id
    FROM   AS_ACCESSES_ALL_LEAD_TEMP
    WHERE  sales_lead_id BETWEEN p_start_id AND p_end_id;



/*  CURSOR c_uniq_steam(p_sales_lead_id NUMBER) IS
    SELECT max(decode(SALESFORCE_ROLE_CODE, NULL, 'N', 'Y') || ACCESS_ID) code_access_id,
           salesforce_id, sales_group_id,
           max(nvl(FREEZE_FLAG, 'N')) freeze_flag,
           max(nvl(TEAM_LEADER_FLAG, 'N')) team_leader_flag,
           max(nvl(OWNER_FLAG, 'N')) owner_flag,
           max(nvl(CONTRIBUTOR_FLAG, 'N')) contributor_flag
    FROM   AS_ACCESSES_ALL
    WHERE  sales_lead_id = p_sales_lead_id
    GROUP BY salesforce_id, sales_group_id
    HAVING count(access_id) > 1; */ -- @@

--Code added for ASN migration approach suggested by lester  -- Start

CURSOR c_uniq_steam(p_sales_lead_id NUMBER) IS
SELECT sales_lead_id,max(code_access_id) code_access_id,
           salesforce_id, sales_group_id,
           max(FREEZE_FLAG) freeze_flag,
           max(TEAM_LEADER_FLAG) team_leader_flag,
           max(OWNER_FLAG) owner_flag,
           max(CONTRIBUTOR_FLAG) contributor_flag
    FROM   AS_ACCESSES_ALL_LEAD_TEMP -- AS_ACCESSES_ALL
    WHERE  sales_lead_id = p_sales_lead_id
    GROUP BY salesforce_id, sales_group_id;

--Code added for ASN migration approach suggested by lester  -- End

BEGIN

    -- Log
    IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
          'Begin OSO->ASN Duplicate Sales Rep Sales Lead Data Migration.');
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                 'Start:' || 'p_start_id=' || p_start_id ||
                 ',p_end_id='||p_end_id ||
                 ',p_debug_flag='||p_debug_flag);
    END IF;

    l_user_id := FND_GLOBAL.user_id;

    IF l_user_id IS NULL THEN
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module_name,
              'Leads: Error: Global User Id is not set');
      END IF;
      RETURN;
    END IF;

    FOR lead_rec in c_leads_in_range(p_start_id, p_end_id) LOOP -- start Main lead loop  -- @@
      BEGIN
        savepoint CURR_LEAD;

        l_updated_flag := false;

        l_sales_lead_id := lead_rec.sales_lead_id; -- @@

        l_remove_count := 0;
        -- Will return one of Sales Team members of duplicates grouped by
        -- Salesforce id, Sales Group id, union of flags (i.e flag is Y if
        -- any one of duplicate members has it as Y, else  N), returns
        -- access_id of a record with SALESFORCE_ROLE_CODE non null
        -- if available else any access_id prefixed with Y or N
        FOR uniq_steam_rec in c_uniq_steam(l_sales_lead_id) LOOP  -- @@
          IF (p_debug_flag = 'Y' AND
            FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'Leads: Cleaning up duplicates for code_access_id: ' ||
                uniq_steam_rec.code_access_id ||
                ' sf_id ' || uniq_steam_rec.salesforce_id ||
                ' sg_id ' || uniq_steam_rec.sales_group_id ||
                ' freeze_flag ' || uniq_steam_rec.freeze_flag ||
                ' team_leader_flag ' || uniq_steam_rec.team_leader_flag ||
                ' owner_flag ' || uniq_steam_rec.owner_flag ||
                ' contributor_flag ' || uniq_steam_rec.contributor_flag);
          END IF;

          l_updated_flag := true;

          l_access_id := substr(uniq_steam_rec.code_access_id, 2);
          UPDATE AS_ACCESSES_ALL_ALL -- @@
          SET DELETE_FLAG = 'Y',
              LAST_UPDATED_BY = l_user_id,
              LAST_UPDATE_DATE = sysdate,
              LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id
          WHERE sales_lead_id =  l_sales_lead_id AND  -- @@
                salesforce_id = uniq_steam_rec.salesforce_id AND
                nvl(sales_group_id, -37) = nvl(uniq_steam_rec.sales_group_id, -37) AND
                access_id <> l_access_id AND
                delete_flag IS NULL;

          l_remove_count := l_remove_count + SQL%ROWCOUNT;

          UPDATE AS_ACCESSES_ALL   -- @@
          SET FREEZE_FLAG = uniq_steam_rec.freeze_flag,
              TEAM_LEADER_FLAG = uniq_steam_rec.team_leader_flag,
              OWNER_FLAG = uniq_steam_rec.owner_flag,
              CONTRIBUTOR_FLAG = uniq_steam_rec.contributor_flag,
              LAST_UPDATED_BY = l_user_id,
              LAST_UPDATE_DATE = sysdate,
              LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id
          WHERE access_id = l_access_id;
        END  LOOP;

        IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
              'Successfully processed Sales Lead Id: ' || l_sales_lead_id || ' Entries removed ' || l_remove_count);
        END IF;

        IF l_updated_flag THEN
            l_uncommitted_leads := l_uncommitted_leads + 1;
        END IF;
        IF l_uncommitted_leads >= p_batch_size THEN
          IF p_commit_flag = 'Y' THEN
            IF (p_debug_flag = 'Y' AND
                FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'Calling Commit after processing ' || l_uncommitted_leads || ' Sales Leads');
            END IF;
            COMMIT;
          ELSE
            ROLLBACK;
          END IF;
          l_uncommitted_leads := 0;
        END IF;

        EXCEPTION
        WHEN OTHERS then
            Rollback to CURR_LEAD;
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                        'Error Processing Lead Id : ' || l_sales_lead_id);
                FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                        'SQL Error Msg, lead_id: ' || l_sales_lead_id || ': '
                        || substr(SQLERRM, 1, 1950));
            END IF;
      END;
     END LOOP; -- end Main lead loop  -- @@

    -- Commit
    IF (p_commit_flag = 'Y') THEN
      -- Log
      IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'Leads: Committing');
      END IF;
      COMMIT;
    ELSE
      -- Log
      IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'Leads: Rolling back');
      END IF;
       ROLLBACK;
    END IF;

    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name, 'Leads: End of OSO->ASN Duplicate Sales Team Sales Lead Data Migration.');
    END IF;

End Mig_Dup_SalesRep_Lead;
--Code added for ASN migration approach suggested by lester  -- End -- @@

--
--
--Procedure modified for ASN migration approach suggested by lester  -- Start  --  @@
--cust main
PROCEDURE Mig_Dup_SalesRep_Main
          (
           errbuf          OUT NOCOPY VARCHAR2,
           retcode         OUT NOCOPY NUMBER,
           p_num_workers   IN NUMBER,
           p_commit_flag   IN VARCHAR2,
           p_debug_flag    IN VARCHAR2
          )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Mig_Dup_SalesRep_Main';
  l_module_name                  CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_team_pvt.Mig_Dup_SalesRep_Main';
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);
  l_req_id                       NUMBER;
  l_request_data                 VARCHAR2(30);
  l_max_num_rows                 NUMBER;
  l_rows_per_worker              NUMBER;
  l_rows_per_worker1              NUMBER;
  l_start_id                     NUMBER;
  l_end_id                       NUMBER;
  l_batch_size                   CONSTANT NUMBER := 10000;

  CURSOR c1 IS SELECT hz_parties_s.nextval FROM dual;

--Code added for ASN migration approach suggested by lester  -- Start
ls_create_temp varchar2(1000);
l_dup_count_cust NUMBER;
l_dup_count_Lead NUMBER;
l_dup_count_Opp NUMBER;

l_dup_min_cust NUMBER;
l_dup_min_Lead NUMBER;
l_dup_min_Opp NUMBER;

ls_program  VARCHAR2(100);

TYPE num_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
l_id_list num_list;

l_dummy NUMBER:=0;

CURSOR c_opps_in_range(p_start_id NUMBER, p_end_id NUMBER)  IS
    SELECT lead_id, customer_id
    FROM   as_leads_all
    WHERE  lead_id BETWEEN p_start_id AND p_end_id;

    CURSOR c2 IS SELECT as_leads_s.nextval FROM dual;

  l_lead_id                 NUMBER;
  l_customer_id             NUMBER;
  l_custfix_count           NUMBER;
  l_user_id                 NUMBER;
  l_max_id			NUMBER;

--Code added for ASN migration approach suggested by lester  -- End

BEGIN

--Code added for ASN migration approach suggested by lester  -- Start
 /*--Bug#5816258:- we should have the single, top level
parent program fire 3 parallel query, full scan sqls
  on as_accesses to insert into 3 tables the few thousand dups of each type
(cust, leads, opps) ..parallel full scans even of the
  large as_accesses_all table should just take a few minutes.
- then proceed to launch the worker programs to query up thier respective dup
set from the above tables, and do the corresponding updates.  */
BEGIN
 IF (fnd_conc_global.request_data IS NULL) THEN

--Create temp table for customer  -- @@
INSERT /*+ APPEND PARALLEL(CUST) */
into AS_ACCESSES_ALL_CUST_TEMP CUST
(customer_id,
code_access_id,
salesforce_id,
sales_group_id,
partner_customer_id,
partner_cont_party_id,
freeze_flag,
team_leader_flag,
owner_flag,
contributor_flag)
Select /*+ PARALLEL(A)*/
customer_id,max(decode(SALESFORCE_ROLE_CODE, NULL, 'N', 'Y') || ACCESS_ID) code_access_id,
           salesforce_id, sales_group_id, partner_customer_id,
           partner_cont_party_id,
           max(nvl(FREEZE_FLAG, 'N')) freeze_flag,
           max(nvl(TEAM_LEADER_FLAG, 'N')) team_leader_flag,
           max(nvl(OWNER_FLAG, 'N')) owner_flag,
           max(nvl(CONTRIBUTOR_FLAG, 'N')) contributor_flag
    FROM   AS_ACCESSES_ALL A ---- @@
    WHERE   lead_id IS NULL AND sales_lead_id IS NULL
    GROUP BY customer_id,salesforce_id, sales_group_id, partner_customer_id,
             partner_cont_party_id
    HAVING count(access_id) > 1;
COMMIT;

INSERT /*+ APPEND PARALLEL(CUST) */ into AS_ACCESSES_ALL_LEAD_TEMP CUST
(sales_lead_id,
code_access_id,
salesforce_id,
sales_group_id,
freeze_flag,
team_leader_flag,
owner_flag,
contributor_flag)
Select /*+ PARALLEL(A)*/
sales_lead_id,max(decode(SALESFORCE_ROLE_CODE, NULL, 'N', 'Y') || ACCESS_ID),
           salesforce_id, sales_group_id,
           max(nvl(FREEZE_FLAG, 'N')) freeze_flag,
           max(nvl(TEAM_LEADER_FLAG, 'N')) team_leader_flag,
           max(nvl(OWNER_FLAG, 'N')) owner_flag,
           max(nvl(CONTRIBUTOR_FLAG, 'N')) contributor_flag
    FROM   AS_ACCESSES_ALL A  ---- @@
    WHERE sales_lead_id IS NOT NULL
    GROUP BY sales_lead_id,salesforce_id, sales_group_id
    HAVING count(access_id) > 1;
    COMMIT;

INSERT /*+ APPEND PARALLEL(CUST) */ into AS_ACCESSES_ALL_OPP_TEMP CUST
(lead_id,
code_access_id,
salesforce_id,
sales_group_id,
partner_customer_id,
partner_cont_party_id,
freeze_flag,
team_leader_flag,
owner_flag,
contributor_flag)
Select /*+ PARALLEL(A)*/
Lead_id,max(decode(SALESFORCE_ROLE_CODE, NULL, 'N', 'Y') || ACCESS_ID) ,
           salesforce_id, sales_group_id, partner_customer_id,partner_cont_party_id,
           max(nvl(FREEZE_FLAG, 'N')) freeze_flag,
           max(nvl(TEAM_LEADER_FLAG, 'N')) team_leader_flag,
           max(nvl(OWNER_FLAG, 'N')) owner_flag,
           max(nvl(CONTRIBUTOR_FLAG, 'N')) contributor_flag
    FROM   AS_ACCESSES_ALL  A ---- @@
    WHERE Lead_id IS NOT NULL
    GROUP BY lead_id,salesforce_id, sales_group_id, partner_customer_id,
             partner_cont_party_id
    HAVING count(access_id) > 1;
    COMMIT;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Customers: Start:' || 'p_num_workers=' || p_num_workers ||
                     ',p_commit_flag=' || p_commit_flag ||
                     ',p_debug_flag=' || p_debug_flag);
    END IF;

FOR i IN 1..3 LOOP ---First loop start -- @ @

l_id_list.delete;
IF i=1 THEN --Opp
	Select count(DISTINCT lead_id),min(lead_id),max(lead_id)
	into l_dup_count_opp,l_dup_min_opp,l_max_id
	From  AS_ACCESSES_ALL_OPP_TEMP;

	l_max_num_rows := l_dup_count_opp;
	l_start_id := l_dup_min_opp-1;
	ls_program     := 'ASN_MIG_DUP_ST_OPP_PRG';

	Select distinct lead_id
	BULK COLLECT INTO
	l_id_list
	FROM AS_ACCESSES_ALL_OPP_TEMP
	ORDER BY lead_id;

ELSIF i=2 THEN --cust

	Select count(DISTINCT customer_id),min(customer_id),max(customer_id)
	into l_dup_count_cust,l_dup_min_cust,l_max_id
	From  AS_ACCESSES_ALL_CUST_TEMP;

	l_max_num_rows := l_dup_count_cust;
	l_start_id := l_dup_min_cust-1;
	ls_program     := 'ASN_MIG_DUP_ST_CUST_PRG';

	Select distinct customer_id
	BULK COLLECT INTO
	l_id_list
	FROM AS_ACCESSES_ALL_CUST_TEMP
	ORDER BY customer_id;
ELSE -- lead
	Select count(DISTINCT sales_lead_id),min(sales_lead_id),max(sales_lead_id)
	into l_dup_count_lead,l_dup_min_lead,l_max_id
	From  AS_ACCESSES_ALL_LEAD_TEMP;

	l_max_num_rows := l_dup_count_lead;
	l_start_id := l_dup_min_lead-1;
	ls_program     := 'ASN_MIG_DUP_ST_LEAD_PRG';
	Select distinct sales_lead_id
	BULK COLLECT INTO
	l_id_list
	FROM AS_ACCESSES_ALL_LEAD_TEMP
	ORDER BY sales_lead_id;
END IF;
--Code added for ASN migration approach suggested by lester --Bug#5816258 -- End
--
  -- If this is first time parent is called, then split the rows
  -- among workers and put the parent in paused state
  --


    --
    -- Get maximum number of possible rows in as_leads_all
    --
   /* OPEN c1;
    FETCH c1 INTO l_max_num_rows;
    CLOSE c1; */ -- @@

    --
    -- Compute row range to be assigned to each worker
    --
    l_rows_per_worker := ROUND(l_max_num_rows/p_num_workers) + 1;

    --
    -- Assign rows to each worker
    --

    -- Initialize start ID value
   -- l_start_id := 0; -- @@

      l_rows_per_worker1 :=0;
     FOR i IN 1..p_num_workers LOOP ----I

      -- Initialize end ID value
     -- l_end_id := l_start_id + l_id_list(l_rows_per_worker);
	begin
	l_end_id := l_id_list(l_rows_per_worker+l_rows_per_worker1);
	exception
	When NO_DATA_FOUND then
	l_end_id := l_max_id;
	end;



      -- Submit the request
      l_req_id :=
        fnd_request.submit_request
        (
         application => 'ASN',
         --program     => 'ASN_MIG_DUP_ST_CUST_SUB_PRG',
	 program     => ls_program,  -- @@
         description => null,
         start_time  => sysdate,
         sub_request => true,
         argument1   => l_start_id,
         argument2   => l_end_id,
         argument3   => p_commit_flag,
         argument4   => l_batch_size,
         argument5   => p_debug_flag,
         argument6   => CHR(0),
         argument7   => CHR(0),
         argument8   => CHR(0),
         argument9   => CHR(0),
         argument10  => CHR(0),
         argument11  => CHR(0),
         argument12  => CHR(0),
         argument13  => CHR(0),
         argument14  => CHR(0),
         argument15  => CHR(0),
         argument16  => CHR(0),
         argument17  => CHR(0),
         argument18  => CHR(0),
         argument19  => CHR(0),
         argument20  => CHR(0),
         argument21  => CHR(0),
         argument22  => CHR(0),
         argument23  => CHR(0),
         argument24  => CHR(0),
         argument25  => CHR(0),
         argument26  => CHR(0),
         argument27  => CHR(0),
         argument28  => CHR(0),
         argument29  => CHR(0),
         argument30  => CHR(0),
         argument31  => CHR(0),
         argument32  => CHR(0),
         argument33  => CHR(0),
         argument34  => CHR(0),
         argument35  => CHR(0),
         argument36  => CHR(0),
         argument37  => CHR(0),
         argument38  => CHR(0),
         argument39  => CHR(0),
         argument40  => CHR(0),
         argument41  => CHR(0),
         argument42  => CHR(0),
         argument43  => CHR(0),
         argument44  => CHR(0),
         argument45  => CHR(0),
         argument46  => CHR(0),
         argument47  => CHR(0),
         argument48  => CHR(0),
         argument49  => CHR(0),
         argument50  => CHR(0),
         argument51  => CHR(0),
         argument52  => CHR(0),
         argument53  => CHR(0),
         argument54  => CHR(0),
         argument55  => CHR(0),
         argument56  => CHR(0),
         argument57  => CHR(0),
         argument58  => CHR(0),
         argument59  => CHR(0),
         argument60  => CHR(0),
         argument61  => CHR(0),
         argument62  => CHR(0),
         argument63  => CHR(0),
         argument64  => CHR(0),
         argument65  => CHR(0),
         argument66  => CHR(0),
         argument67  => CHR(0),
         argument68  => CHR(0),
         argument69  => CHR(0),
         argument70  => CHR(0),
         argument71  => CHR(0),
         argument72  => CHR(0),
         argument73  => CHR(0),
         argument74  => CHR(0),
         argument75  => CHR(0),
         argument76  => CHR(0),
         argument77  => CHR(0),
         argument78  => CHR(0),
         argument79  => CHR(0),
         argument80  => CHR(0),
         argument81  => CHR(0),
         argument82  => CHR(0),
         argument83  => CHR(0),
         argument84  => CHR(0),
         argument85  => CHR(0),
         argument86  => CHR(0),
         argument87  => CHR(0),
         argument88  => CHR(0),
         argument89  => CHR(0),
         argument90  => CHR(0),
         argument91  => CHR(0),
         argument92  => CHR(0),
         argument93  => CHR(0),
         argument94  => CHR(0),
         argument95  => CHR(0),
         argument96  => CHR(0),
         argument97  => CHR(0),
         argument98  => CHR(0),
         argument99  => CHR(0),
         argument100  => CHR(0)
        );

      --
      -- If request submission failed, exit with error.
      --
      IF (l_req_id = 0) THEN

        errbuf := fnd_message.get;
        retcode := 2;
        RETURN;

      END IF;

      -- Set start ID value
     -- l_start_id := l_end_id + 1;  -- @@
     l_rows_per_worker1:=l_rows_per_worker+l_rows_per_worker1;
     begin
     l_start_id:= l_id_list(l_rows_per_worker1-1);
     exception
     when no_data_found then
     null;
     end;

     END LOOP;-------I


END LOOP;  ---First loop End -- @ @
 --
    -- After submitting request for all workers, put the parent
    -- in paused state. When all children are done, the parent
    -- would be called again, and then it will terminate
    --
     fnd_conc_global.set_req_globals
    (
     conc_status         => 'PAUSED',
     request_data        => to_char(l_req_id) --,
--     conc_restart_time   => to_char(sysdate),
--     release_sub_request => 'N'
    );


    ELSE

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Customers: Re-entering:' || 'p_num_workers=' || p_num_workers ||
                     ',p_commit_flag=' || p_commit_flag ||
                     ',p_debug_flag='||p_debug_flag);

    END IF;
 END IF;
    END;
EXCEPTION

   WHEN OTHERS THEN

     ROLLBACK;

     IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, l_module_name, true);
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                      l_api_name||':'||sqlcode||':'||sqlerrm);
    END IF;

END Mig_Dup_SalesRep_Main;

--Procedure modified for ASN migration approach suggested by lester  -- End -- @@
--Procedure modified for ASN migration approach suggested by lester  -- Start -- @@

PROCEDURE Mig_Dup_SalesRep_Cust (
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY NUMBER,
    p_start_id       IN VARCHAR2,
    p_end_id         IN VARCHAR2,
    p_commit_flag    IN VARCHAR2,
    p_batch_size     IN NUMBER,
    p_debug_flag     IN VARCHAR2
    )
 IS

  l_module_name             CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_team_pvt.Mig_Dup_SalesRep_Cust';

  l_uncommitted_parties     NUMBER := 0;
  l_remove_count            NUMBER;
  l_updated_flag            BOOLEAN;
  l_party_id                NUMBER;
  l_access_id               NUMBER;
  l_user_id                 NUMBER;

 /* CURSOR c_parties_in_range(p_start_id NUMBER, p_end_id NUMBER)  IS
    SELECT party_id
    FROM   hz_parties
    WHERE  party_id BETWEEN p_start_id AND p_end_id
           AND party_type IN ('ORGANIZATION', 'PERSON');*/

   CURSOR c_parties_in_range(p_start_id NUMBER, p_end_id NUMBER)  IS
   SELECT distinct temp.customer_id
   FROM  AS_ACCESSES_ALL_cust_TEMP temp ,hz_parties hz
	WHERE  temp.customer_id  BETWEEN p_start_id AND p_end_id
           AND hz.party_type IN ('ORGANIZATION', 'PERSON')
		AND temp.customer_id=hz.party_id ;

 /* CURSOR c_uniq_steam(p_party_id NUMBER) IS
    SELECT max(decode(SALESFORCE_ROLE_CODE, NULL, 'N', 'Y') || ACCESS_ID) code_access_id,
           salesforce_id, sales_group_id, partner_customer_id,
           partner_cont_party_id,
           max(nvl(FREEZE_FLAG, 'N')) freeze_flag,
           max(nvl(TEAM_LEADER_FLAG, 'N')) team_leader_flag,
           max(nvl(OWNER_FLAG, 'N')) owner_flag,
           max(nvl(CONTRIBUTOR_FLAG, 'N')) contributor_flag
    FROM   AS_ACCESSES_ALL
    WHERE  customer_id = p_party_id AND lead_id IS NULL AND sales_lead_id IS NULL
    GROUP BY salesforce_id, sales_group_id, partner_customer_id,
             partner_cont_party_id
    HAVING count(access_id) > 1; */ -- @@

--Code added for ASN migration approach suggested by lester  -- Start
--CURSOR c_uniq_steam IS
CURSOR c_uniq_steam(p_party_id NUMBER) IS
    SELECT customer_id,max(code_access_id) code_access_id,
           salesforce_id, sales_group_id, partner_customer_id,
           partner_cont_party_id,
           max(FREEZE_FLAG) freeze_flag,
           max(TEAM_LEADER_FLAG) team_leader_flag,
           max(OWNER_FLAG) owner_flag,
           max(CONTRIBUTOR_FLAG) contributor_flag
    FROM   AS_ACCESSES_ALL_CUST_TEMP -- AS_ACCESSES_ALL
WHERE  customer_id = p_party_id
    GROUP BY customer_id,salesforce_id, sales_group_id, partner_customer_id,
             partner_cont_party_id;
--Code added for ASN migration approach suggested by lester  -- End

BEGIN

    -- Log
    IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
          'Begin OSO->ASN Duplicate Sales Rep Customer Data Migration.');
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                 'Start:' || 'p_start_id=' || p_start_id ||
                 ',p_end_id='||p_end_id ||
                 ',p_debug_flag='||p_debug_flag);
    END IF;

    l_user_id := FND_GLOBAL.user_id;

    IF l_user_id IS NULL THEN
      IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module_name,
              'Customers: Error: Global User Id is not set');
      END IF;
      RETURN;
    END IF;

    FOR party_rec in c_parties_in_range(p_start_id, p_end_id) LOOP -- start Main party loop -- @@
      BEGIN
        savepoint CURR_PARTY;

        l_updated_flag := false;

        --l_party_id := party_rec.party_id; -- @@
	l_party_id := party_rec.customer_id ; -- @@

        l_remove_count := 0;
        -- Will return one of Sales Team members of duplicates grouped by
        -- Salesforce id, Sales Group id, union of flags (i.e flag is Y if
        -- any one of duplicate members has it as Y, else  N), returns
        -- access_id of a record with SALESFORCE_ROLE_CODE non null
        -- if available else any access_id prefixed with Y or N
        FOR uniq_steam_rec in c_uniq_steam(l_party_id) LOOP -- @@
          IF (p_debug_flag = 'Y' AND
            FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'Customers: Cleaning up duplicates for coded_access_id: ' ||
                uniq_steam_rec.code_access_id ||
                ' sf_id ' || uniq_steam_rec.salesforce_id ||
                ' sg_id ' || uniq_steam_rec.sales_group_id ||
                ' freeze_flag ' || uniq_steam_rec.freeze_flag ||
                ' team_leader_flag ' || uniq_steam_rec.team_leader_flag ||
                ' owner_flag ' || uniq_steam_rec.owner_flag ||
                ' contributor_flag ' || uniq_steam_rec.contributor_flag);
          END IF;

          l_updated_flag := true;

          l_access_id := substr(uniq_steam_rec.code_access_id, 2);
          UPDATE AS_ACCESSES_ALL_ALL   -- @@
          SET DELETE_FLAG = 'Y',
              LAST_UPDATED_BY = l_user_id,
              LAST_UPDATE_DATE = sysdate,
              LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id
          WHERE customer_id = l_party_id AND  -- @@
	        lead_id IS NULL AND
                sales_lead_id IS NULL AND
                salesforce_id = uniq_steam_rec.salesforce_id AND
                nvl(sales_group_id, -37) = nvl(uniq_steam_rec.sales_group_id, -37) AND
                nvl(partner_customer_id, -37) = nvl(uniq_steam_rec.partner_customer_id, -37) AND
                nvl(partner_cont_party_id, -37) = nvl(uniq_steam_rec.partner_cont_party_id, -37) AND
                access_id <> l_access_id AND
                delete_flag IS NULL;

          l_remove_count := l_remove_count + SQL%ROWCOUNT;

          UPDATE AS_ACCESSES_ALL -- @@
          SET FREEZE_FLAG = uniq_steam_rec.freeze_flag,
              TEAM_LEADER_FLAG = uniq_steam_rec.team_leader_flag,
              OWNER_FLAG = uniq_steam_rec.owner_flag,
              CONTRIBUTOR_FLAG = uniq_steam_rec.contributor_flag,
              LAST_UPDATED_BY = l_user_id,
              LAST_UPDATE_DATE = sysdate,
              LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id
          WHERE access_id = l_access_id;
        END  LOOP;

        IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
              'Successfully processed Party Id: ' || l_party_id || ' Entries removed ' || l_remove_count);
        END IF;

        IF l_updated_flag THEN
            l_uncommitted_parties := l_uncommitted_parties + 1;
        END IF;

        IF l_uncommitted_parties >= p_batch_size THEN
          IF p_commit_flag = 'Y' THEN
            IF (p_debug_flag = 'Y' AND
                FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'Calling Commit after processing ' || l_uncommitted_parties || ' Customers');
            END IF;
            COMMIT;
          ELSE
            ROLLBACK;
          END IF;
          l_uncommitted_parties := 0;
        END IF;

        EXCEPTION
        WHEN OTHERS then
            Rollback to CURR_PARTY;
            IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                        'Error Processing Party Id : ' || l_party_id);
                FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                        'SQL Error Msg, party_id: ' || l_party_id || ': '
                        || substr(SQLERRM, 1, 1950));
            END IF;
      END;
    END LOOP; -- end Main customer loop  -- @@

    -- Commit
    IF (p_commit_flag = 'Y') THEN
      -- Log
      IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'Customers: Committing');
      END IF;
      COMMIT;
    ELSE
      -- Log
      IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'Customers: Rolling back');
      END IF;
       ROLLBACK;
    END IF;

    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name, 'End of OSO->ASN Duplicate Sales Team Customer Data Migration.');
    END IF;

End Mig_Dup_SalesRep_Cust;
--Procedure modified for ASN migration approach suggested by lester  -- End -- @@

--Newly added for concurrent program ASN Post Upgrade Log and Customer Update  -- Start
PROCEDURE Mig_Customerid_Enddaylog_Main
          (
           errbuf          OUT NOCOPY VARCHAR2,
           retcode         OUT NOCOPY NUMBER,
           p_num_workers   IN NUMBER,
           p_commit_flag   IN VARCHAR2,
           p_debug_flag    IN VARCHAR2
          )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Mig_Customerid_Enddaylog_Main';
  l_module_name                  CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_team_pvt.Mig_Customerid_Enddaylog_Main';
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);
  l_req_id                       NUMBER;
  l_request_data                 VARCHAR2(30);
  l_max_num_rows                 NUMBER;
  l_rows_per_worker              NUMBER;
  l_start_id                     NUMBER;
  l_end_id                       NUMBER;
  l_batch_size                   CONSTANT NUMBER := 10000;

 -- CURSOR c1 IS SELECT as_leads_s.nextval FROM dual;
 CURSOR c1 IS SELECT count(lead_id) FROM as_leads_all;

BEGIN

  --
  -- If this is first time parent is called, then split the rows
  -- among workers and put the parent in paused state
  --
  IF (fnd_conc_global.request_data IS NULL) THEN

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Opportunities: Start:' || 'p_num_workers=' || p_num_workers ||
                     ',p_commit_flag=' || p_commit_flag ||
                     ',p_debug_flag=' || p_debug_flag);
    END IF;

    --
    -- Get maximum number of possible rows in as_leads_all
    --
    OPEN c1;
    FETCH c1 INTO l_max_num_rows;
    CLOSE c1;

    --
    -- Compute row range to be assigned to each worker
    --
    l_rows_per_worker := ROUND(l_max_num_rows/p_num_workers) + 1;

    --
    -- Assign rows to each worker
    --

    -- Initialize start ID value
    l_start_id := 0;
    FOR i IN 1..p_num_workers LOOP

      -- Initialize end ID value
      l_end_id := l_start_id + l_rows_per_worker;

      -- Submit the request
      l_req_id :=
        fnd_request.submit_request
        (
         application => 'ASN',
         program     => 'ASN_UPG_LOG_CUSTOMER_SUB_PRG',
         description => null,
         start_time  => sysdate,
         sub_request => true,
         argument1   => l_start_id,
         argument2   => l_end_id,
         argument3   => p_commit_flag,
         argument4   => l_batch_size,
         argument5   => p_debug_flag,
         argument6   => CHR(0),
         argument7   => CHR(0),
         argument8   => CHR(0),
         argument9   => CHR(0),
         argument10  => CHR(0),
         argument11  => CHR(0),
         argument12  => CHR(0),
         argument13  => CHR(0),
         argument14  => CHR(0),
         argument15  => CHR(0),
         argument16  => CHR(0),
         argument17  => CHR(0),
         argument18  => CHR(0),
         argument19  => CHR(0),
         argument20  => CHR(0),
         argument21  => CHR(0),
         argument22  => CHR(0),
         argument23  => CHR(0),
         argument24  => CHR(0),
         argument25  => CHR(0),
         argument26  => CHR(0),
         argument27  => CHR(0),
         argument28  => CHR(0),
         argument29  => CHR(0),
         argument30  => CHR(0),
         argument31  => CHR(0),
         argument32  => CHR(0),
         argument33  => CHR(0),
         argument34  => CHR(0),
         argument35  => CHR(0),
         argument36  => CHR(0),
         argument37  => CHR(0),
         argument38  => CHR(0),
         argument39  => CHR(0),
         argument40  => CHR(0),
         argument41  => CHR(0),
         argument42  => CHR(0),
         argument43  => CHR(0),
         argument44  => CHR(0),
         argument45  => CHR(0),
         argument46  => CHR(0),
         argument47  => CHR(0),
         argument48  => CHR(0),
         argument49  => CHR(0),
         argument50  => CHR(0),
         argument51  => CHR(0),
         argument52  => CHR(0),
         argument53  => CHR(0),
         argument54  => CHR(0),
         argument55  => CHR(0),
         argument56  => CHR(0),
         argument57  => CHR(0),
         argument58  => CHR(0),
         argument59  => CHR(0),
         argument60  => CHR(0),
         argument61  => CHR(0),
         argument62  => CHR(0),
         argument63  => CHR(0),
         argument64  => CHR(0),
         argument65  => CHR(0),
         argument66  => CHR(0),
         argument67  => CHR(0),
         argument68  => CHR(0),
         argument69  => CHR(0),
         argument70  => CHR(0),
         argument71  => CHR(0),
         argument72  => CHR(0),
         argument73  => CHR(0),
         argument74  => CHR(0),
         argument75  => CHR(0),
         argument76  => CHR(0),
         argument77  => CHR(0),
         argument78  => CHR(0),
         argument79  => CHR(0),
         argument80  => CHR(0),
         argument81  => CHR(0),
         argument82  => CHR(0),
         argument83  => CHR(0),
         argument84  => CHR(0),
         argument85  => CHR(0),
         argument86  => CHR(0),
         argument87  => CHR(0),
         argument88  => CHR(0),
         argument89  => CHR(0),
         argument90  => CHR(0),
         argument91  => CHR(0),
         argument92  => CHR(0),
         argument93  => CHR(0),
         argument94  => CHR(0),
         argument95  => CHR(0),
         argument96  => CHR(0),
         argument97  => CHR(0),
         argument98  => CHR(0),
         argument99  => CHR(0),
         argument100  => CHR(0)
        );

      --
      -- If request submission failed, exit with error.
      --
      IF (l_req_id = 0) THEN

        errbuf := fnd_message.get;
        retcode := 2;
        RETURN;

      END IF;

      -- Set start ID value
      l_start_id := l_end_id + 1;

    END LOOP; -- end i

    --
    -- After submitting request for all workers, put the parent
    -- in paused state. When all children are done, the parent
    -- would be called again, and then it will terminate
    --
    fnd_conc_global.set_req_globals
    (
     conc_status         => 'PAUSED',
     request_data        => to_char(l_req_id) --,
--     conc_restart_time   => to_char(sysdate),
--     release_sub_request => 'N'
    );

  ELSE

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Opportunities: Re-entering:' || 'p_num_workers=' || p_num_workers ||
                     ',p_commit_flag=' || p_commit_flag ||
                     ',p_debug_flag='||p_debug_flag);
    END IF;

    errbuf := 'Migration completed';
    retcode := 0;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Opportunities: Done:' || 'p_num_workers=' || p_num_workers ||
                     ',p_commit_flag=' || p_commit_flag ||
                     ',p_debug_flag='||p_debug_flag);
    END IF;

  END IF;

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK;

     IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, l_module_name, true);
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                      l_api_name||':'||sqlcode||':'||sqlerrm);
    END IF;

END Mig_Customerid_Enddaylog_Main;


PROCEDURE Mig_Customerid_Enddaylog_Sub (
   errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY NUMBER,
    p_start_id       IN VARCHAR2,
    p_end_id         IN VARCHAR2,
    p_commit_flag    IN VARCHAR2,
    p_batch_size     IN NUMBER,
    p_debug_flag     IN VARCHAR2)
    IS

l_api_name                     CONSTANT VARCHAR2(30) :=
'Mig_Customerid_Enddaylog_Sub';
  l_module_name             CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_team_pvt.Mig_Customerid_Enddaylog_Sub';

  TYPE NumTab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE DateTab IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE Var1Tab IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

  l_log_ids             NumTab;
  l_lead_line_ids       NumTab;
  l_sales_credit_ids    NumTab;
  l_last_update_dates   DateTab;
  l_endday_log_flags    Var1Tab;

  l_future_date             DATE := sysdate + 1000;
  l_prev_last_update_date   DATE;
  l_last_update_date        DATE;
  l_prev_lead_line_id       NUMBER;
  l_prev_sales_credit_id    NUMBER;
  l_endday_log_flag         VARCHAR2(1);
  l_update_count            NUMBER;


--    CURSOR c_opps_in_range(p_start_id NUMBER, p_end_id NUMBER)  IS
CURSOR c_opps_in_range  IS
    SELECT lead_id, customer_id
    FROM   as_leads_all;

    CURSOR c_lead_line_logs(p_lead_id NUMBER)  IS
    SELECT log_id, lead_line_id, last_update_date
    FROM   as_lead_lines_log
    WHERE  lead_id = p_lead_id
    ORDER BY lead_line_id ASC, last_update_date DESC, log_id DESC;

  CURSOR c_sales_credits_logs(p_lead_id NUMBER)  IS
    SELECT log_id, sales_credit_id, last_update_date
    FROM   as_sales_credits_log
    WHERE  lead_id = p_lead_id
    ORDER BY sales_credit_id ASC, last_update_date DESC, log_id DESC;

 TYPE num_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
l_lead_id num_list;
l_customer_id  num_list;
l_MAX_fetches   NUMBER  := 10000;
l_user_id NUMBER;
l_CUSTFIX_COUNT NUMBER;
l_uncommitted_opps        NUMBER := 0;

BEGIN
l_custfix_count := 0;
l_user_id := FND_GLOBAL.user_id;
IF l_user_id IS NULL THEN
		IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module_name,
		'Opportunities: Error: Global User Id is not set');
		END IF;
		RETURN;
END IF;
OPEN c_opps_in_range;
	LOOP
		BEGIN
			savepoint CURR_OPP_CUS;
			FETCH c_opps_in_range BULK COLLECT into l_lead_id, l_customer_id LIMIT l_MAX_fetches;

			FOR I IN l_lead_id.first..l_lead_id.last LOOP


				IF (p_debug_flag = 'Y' AND
				FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
					'Start Lead Line Logs Log for lead_id=' || l_lead_id(i));
				END IF;

				    OPEN c_lead_line_logs(l_lead_id(i));
			   	    FETCH c_lead_line_logs BULK COLLECT
			            INTO l_log_ids, l_lead_line_ids, l_last_update_dates;
			            CLOSE c_lead_line_logs;

				    IF (p_debug_flag = 'Y' AND
					      FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
			                   'Num Lead Line Logs Logs=' || l_log_ids.COUNT);
				    END IF;
					l_update_count := 0;
					 IF l_log_ids.COUNT > 0 THEN
						l_prev_lead_line_id := -37;
						FOR i IN l_log_ids.FIRST..l_log_ids.LAST LOOP
							IF l_lead_line_ids(i) <> l_prev_lead_line_id THEN
						          l_prev_lead_line_id := l_lead_line_ids(i);
						          l_prev_last_update_date := l_future_date;
							END IF;

						        l_endday_log_flag := 'Y';
							l_last_update_date := trunc(l_last_update_dates(i));
						      IF l_prev_last_update_date = l_last_update_date THEN
							l_endday_log_flag := 'N';
						      END IF;

							l_endday_log_flags(i) := l_endday_log_flag;
							l_prev_last_update_date := l_last_update_date;
						END LOOP;
						FORALL i IN l_log_ids.FIRST..l_log_ids.LAST
						UPDATE as_lead_lines_log -- @@
						SET    endday_log_flag = l_endday_log_flags(i)
						WHERE  log_id = l_log_ids(i) AND endday_log_flag IS NULL;

						l_update_count := SQL%ROWCOUNT;
						END IF;
						IF (p_debug_flag = 'Y' AND
							FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
							    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
					                   'Num Lead Line Logs Updated=' || l_update_count);
						END IF;

				OPEN c_sales_credits_logs(l_lead_id(i));
				FETCH c_sales_credits_logs BULK COLLECT
				INTO l_log_ids, l_sales_credit_ids, l_last_update_dates;
				CLOSE c_sales_credits_logs;

				 IF (p_debug_flag = 'Y' AND
				      FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
			                   'Num Sales Credits Logs=' || l_log_ids.COUNT);
				END IF;

				l_update_count := 0;

				IF l_log_ids.COUNT > 0 THEN
				    l_prev_sales_credit_id := -37;
				    FOR i IN l_log_ids.FIRST..l_log_ids.LAST LOOP
				      IF l_sales_credit_ids(i) <> l_prev_sales_credit_id THEN
				          l_prev_sales_credit_id := l_sales_credit_ids(i);
				          l_prev_last_update_date := l_future_date;
				      END IF;

					l_endday_log_flag := 'Y';
				        l_last_update_date := trunc(l_last_update_dates(i));
				      IF l_prev_last_update_date = l_last_update_date THEN
					l_endday_log_flag := 'N';
					END IF;

					l_endday_log_flags(i) := l_endday_log_flag;
					l_prev_last_update_date := l_last_update_date;
					END LOOP;

					FORALL i IN l_log_ids.FIRST..l_log_ids.LAST
					UPDATE as_sales_credits_log  -- @@
					SET    endday_log_flag = l_endday_log_flags(i)
					WHERE  log_id = l_log_ids(i) AND endday_log_flag IS NULL;

					l_update_count := SQL%ROWCOUNT;
				END IF;


				IF (p_debug_flag = 'Y' AND
					FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
					FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
						'End fixlog for Lead id: ' || l_lead_id(i) ||
					' Num Sales Credits Updated=' || l_update_count);
				END IF;

			l_uncommitted_opps := l_uncommitted_opps + 1;

		END LOOP;

			--Customer Id updation
				--Customer Id updation
			FORALL I IN l_lead_id.first..l_lead_id.last
				-- Fix Customer Id in Opp Sales Team
				UPDATE AS_ACCESSES_ALL
				SET CUSTOMER_ID = l_customer_id(i),
				LAST_UPDATED_BY = l_user_id,
				LAST_UPDATE_DATE = sysdate,
				LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id
				WHERE LEAD_ID = l_lead_id(i) AND
				nvl(CUSTOMER_ID, -37) <> l_customer_id(i);
				l_custfix_count := SQL%ROWCOUNT;

        IF l_uncommitted_opps >= p_batch_size THEN
          IF p_commit_flag = 'Y' THEN
            IF (p_debug_flag = 'Y' AND
                FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'Calling Commit after processing ' || l_uncommitted_opps || ' Opportunities');
            END IF;
            COMMIT;
          ELSE
            ROLLBACK;
          END IF;
          l_uncommitted_opps := 0;
        END IF;


		END;
	END LOOP;
CLOSE c_opps_in_range;

EXCEPTION

   WHEN OTHERS THEN
     ROLLBACK;

     IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, l_module_name, true);
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                      l_api_name||':'||sqlcode||':'||sqlerrm);
    END IF;

END  Mig_Customerid_Enddaylog_Sub;
--Newly added for concurrent program ASN Post Upgrade Log and Customer Update  -- End

END asn_mig_sales_team_pvt;

/
