--------------------------------------------------------
--  DDL for Package Body ASN_MIG_SALES_CREDITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASN_MIG_SALES_CREDITS_PVT" AS
/* $Header: asnvmscb.pls 120.1 2007/10/03 09:38:18 snsarava ship $ */

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   asn_mig_sales_credits_pvt
  --
  -- PURPOSE
  --   This package contains migration related code for sales credits.
  --
  -- NOTES
  --
  -- HISTORY
  -- gasriniv      25/10/2004           Changes made for ASN.B support
  --                                    Changes made to Mig_Multi_SalesRep_Opp_sub
  --                                    1)One opportunity can have multiple lines
  --                                    but only on credit recievers  per line
  --                                    2)all non revenue credit percentages should be made 100%
  --                                    3)Salesrep recieving credit should be there in the sales team
  --                                    4)remove duplicate non-quota credit reciever for the same line for the
  --                                      same credit type for the same opporutunity
  --                                    5)set the default_from_owner_flag on the sales line if rep recieving
  --                                      credit is the owner
  -- gasriniv      16/11/2004          BUG FIX 4010812
  --                                   fixed cursor c_add_sales_team to add distinct clause
  -- gasriniv      31/12/2004          Add new requirment for deleting 0 credit lines
  --                                   Changed the logic from creating new opporutunty if there are multiple
  --                                   sales credits to creating a new line if there are multiple sales credits
  -- gasriniv      14/01/2005          Added update of WHO columns
  --                                   Removed check for open status flag while updating forecast date to null
  -- gasriniv      25/01/2005          Cloned the delete of duplicate so that it is fired for all opportunites
  --                                   BUG FIX 4139294
  -- gasriniv      01/02/2005          Default Best Forecast Worst columns for non revenue credits also bug#4151483
  --                                   Update full access flag in as_accesses_all for this opportunity
  --                                   bug#4150276 and as per wenxia's email 28 Jan 2005 18:30:21 -0800
  -- gasriniv      02/02/2005          Added logic to merged duplicate credits if they exists for all opportunities
  -- **********************************************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):='asn_mig_sales_credits_pvt';
G_FILE_NAME CONSTANT VARCHAR2(12):='asnvmscb.pls';

--
--
--
PROCEDURE Mig_SlsCred_Owner_Main
          (
           errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY NUMBER,
           p_num_workers IN NUMBER,
           p_commit_flag IN VARCHAR2,
           p_debug_flag IN VARCHAR2
          )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Mig_SlsCred_Owner_Main';
  l_module_name                  CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_credits_pvt.Mig_SlsCred_Owner_Main';
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);
  l_req_id                       NUMBER;
  l_request_data                 VARCHAR2(30);
  l_max_num_rows                 NUMBER;
  l_rows_per_worker              NUMBER;
  l_start_id                     NUMBER;
  l_end_id                       NUMBER;

  CURSOR c1 IS SELECT as_leads_s.nextval FROM dual;

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
                     'Start:' || 'p_num_workers=' || p_num_workers ||
                     ',p_commit_flag=' || p_commit_flag ||
                     ',p_debug_flag=' || p_debug_flag);
    END IF;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Disable AS_SALES_CREDITS_BIUD trigger');
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
         program     => 'ASN_MIG_SLSCRED_OWNER_SUB_EXE',
         description => null,
         start_time  => sysdate,
         sub_request => true,
         argument1   => l_start_id,
         argument2   => l_end_id,
         argument3   => p_commit_flag,
         argument4   => p_debug_flag,
         argument5   => CHR(0),
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
                     'Re-entering:' || 'p_num_workers=' || p_num_workers ||
                     ',p_commit_flag=' || p_commit_flag ||
                     ',p_debug_flag='||p_debug_flag);
    END IF;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Enable AS_SALES_CREDITS_BIUD trigger');
    END IF;

    errbuf := 'Migration completed';
    retcode := 0;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Done:' || 'p_num_workers=' || p_num_workers ||
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
END Mig_SlsCred_Owner_Main;


--
--
--
PROCEDURE Mig_SlsCred_Owner_Sub
          (
           errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY NUMBER,
           p_start_id IN VARCHAR2,
           p_end_id IN VARCHAR2,
           p_commit_flag IN VARCHAR2,
           p_debug_flag IN VARCHAR2
          )
IS
  TYPE NumTab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE Var30Tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Mig_SlsCred_Owner_Sub';
  l_module_name                  CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_credits_pvt.Mig_SlsCred_Owner_Sub';

  l_credit_type_id               NUMBER;

  l_sales_credit_ids             NumTab;
  l_lead_ids                     NumTab;
  l_customer_ids                 NumTab;
  l_person_ids                   NumTab;
  l_open_flags                   Var30Tab;
  l_owner_salesforce_ids         NumTab;
  l_owner_sales_group_ids        NumTab;
  l_salesforce_ids               NumTab;
  l_sales_group_ids              NumTab;
  l_ranks                        NumTab;

  CURSOR c1(pc_credit_type_id NUMBER,
            pc_start_id NUMBER,
            pc_end_id NUMBER) IS
    SELECT
      SCD.sales_credit_id
      ,SCD.lead_id
      ,SCD.customer_id
      ,SCD.employee_person_id
      ,SCD.opp_open_status_flag
      ,SCD.owner_salesforce_id
      ,SCD.owner_sales_group_id
      ,SCD.salesforce_id
      ,SCD.sales_group_id
      ,RANK () OVER (PARTITION BY SCD.lead_id ORDER BY SCD.sales_credit_id) RK
    FROM
      as_sales_credits_denorm SCD
    WHERE
      SCD.lead_id BETWEEN pc_start_id AND pc_end_id
      AND SCD.credit_type_id = pc_credit_type_id
      AND SCD.salesforce_id IS NOT NULL
      AND SCD.sales_group_id IS NOT NULL
      AND SCD.partner_customer_id IS NULL
      AND NOT EXISTS (SELECT 1 FROM as_sales_credits SC2
                      WHERE SC2.lead_id = SCD.lead_id
                      AND SC2.credit_type_id = pc_credit_type_id
                      AND SC2.sales_credit_id <> SCD.sales_credit_id
                      AND (SC2.salesforce_id <> SCD.salesforce_id
                           OR SC2.salesgroup_id <> SCD.sales_group_id))
      AND (SCD.salesforce_id <> SCD.owner_salesforce_id
           OR SCD.sales_group_id <> SCD.owner_sales_group_id
           OR SCD.owner_salesforce_id IS NULL
           OR SCD.owner_sales_group_id IS NULL);

BEGIN

  -- Log
  IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                   'Start:' || 'p_start_id=' || p_start_id ||
                   ',p_end_id='||p_end_id ||
                   ',p_debug_flag='||p_debug_flag);
  END IF;

  --
  -- Get the value for the Quota (or Revenue) sales credit type id from profile
  -- 'OS: Forecast Sales Credit Type' (AS_FORECAST_CREDIT_TYPE_ID)
  --
  l_credit_type_id :=
    FND_PROFILE.Value_Specific('AS_FORECAST_CREDIT_TYPE_ID', null, null, null);

  -- Log
  IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'l_credit_type_id=' || l_credit_type_id);
  END IF;

  --
  -- Get all rows in as_sales_credits that have one salesrep for the
  -- opportunity, but the salesrep is not the owner
  --

  -- Log
  IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                 'Opening cursor');
  END IF;

  -- Open cursor
  OPEN c1(l_credit_type_id, p_start_id, p_end_id);

  IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'Opened cursor');
  END IF;

  -- Start loop
  LOOP

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     'Inside loop');
    END IF;

    -- Fetch rows
    FETCH c1 BULK COLLECT INTO l_sales_credit_ids
                               ,l_lead_ids
                               ,l_customer_ids
                               ,l_person_ids
                               ,l_open_flags
                               ,l_owner_salesforce_ids
                               ,l_owner_sales_group_ids
                               ,l_salesforce_ids
                               ,l_sales_group_ids
                               ,l_ranks LIMIT 10000;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     'After fetch. Num rows:' ||
                     l_sales_credit_ids.COUNT || ':');
    END IF;

    EXIT WHEN l_sales_credit_ids.COUNT <= 0;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     'After exit and processing number of rows =' ||
                     c1%ROWCOUNT);
    END IF;

    --
    -- Update owner of the opportunity from the sales credit
    --

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     'Updating owner in as_leads_all');
    END IF;

    FORALL i IN l_sales_credit_ids.FIRST..l_sales_credit_ids.LAST
      UPDATE
        as_leads_all ALA
      SET
        ALA.owner_salesforce_id = l_salesforce_ids(i)
        ,ALA.owner_sales_group_id = l_sales_group_ids(i)   ,
        last_updated_by = FND_GLOBAL.user_id,
        last_update_date = sysdate,
        last_update_login = FND_GLOBAL.conc_login_id
      WHERE
        ALA.lead_id = l_lead_ids(i)
        AND l_ranks(i) = 1
        AND (ALA.owner_salesforce_id <> l_salesforce_ids(i)
             OR ALA.owner_sales_group_id <> l_sales_group_ids(i)
             OR ALA.owner_salesforce_id IS NULL
             OR ALA.owner_sales_group_id IS NULL);

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     'Updated owner in as_leads_all: number of rows =' ||
                     sql%ROWCOUNT);
    END IF;

    --
    -- Update as_accesses_all to have owner flag reset for the person
    -- previously marked as owner
    --

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     'Updating as_accesses_all to have owner flag reset');
    END IF;

    FORALL i IN l_sales_credit_ids.FIRST..l_sales_credit_ids.LAST
      UPDATE
        as_accesses_all ACS
      SET
        owner_flag = 'N',
        last_updated_by = FND_GLOBAL.user_id,
   last_update_date = sysdate,
        last_update_login = FND_GLOBAL.conc_login_id
      WHERE
        ACS.lead_id = l_lead_ids(i)
        AND l_ranks(i) = 1
        AND ACS.owner_flag = 'Y';

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     'Updated as_accesses_all to have owner flag reset = ' ||
                     sql%ROWCOUNT);
    END IF;

    --
    -- Update as_accesses_all to have owner flag set for the new owner
    --

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     'Updating as_accesses_all to have owner flag set for new owner');
    END IF;

    FORALL i IN l_sales_credit_ids.FIRST..l_sales_credit_ids.LAST
      UPDATE
        as_accesses_all ACS
      SET
        owner_flag = 'Y'
        ,freeze_flag = 'Y' ,
         last_updated_by = FND_GLOBAL.user_id,
    last_update_date = sysdate,
         last_update_login = FND_GLOBAL.conc_login_id
      WHERE
        ACS.lead_id = l_lead_ids(i)
        AND l_ranks(i) = 1
        AND (ACS.owner_flag = 'N'
             OR ACS.owner_flag IS NULL)
        AND ACS.salesforce_id = l_salesforce_ids(i)
        AND ACS.sales_group_id = l_sales_group_ids(i);

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     'Updated as_accesses_all to have owner flag set for new owner = ' ||
                     sql%ROWCOUNT);
    END IF;

    --
    -- Insert into as_accesses_all if the new owner does not exist in the
    -- sales team
    --

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     'Inserting into as_accesses_all');
    END IF;

    FORALL i IN l_sales_credit_ids.FIRST..l_sales_credit_ids.LAST
      INSERT INTO
        as_accesses_all
      (
      access_id
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,reassign_flag
      ,team_leader_flag
      ,customer_id
      ,salesforce_id
      ,person_id
      ,partner_customer_id
      ,lead_id
      ,sales_group_id
      ,partner_cont_party_id
      ,owner_flag
      ,created_by_tap_flag
      ,open_flag
      ,freeze_flag
      ,org_id
      ,object_version_number
      )
      SELECT
        AS_ACCESSES_S.nextval
        ,sysdate
        ,FND_GLOBAL.USER_ID
        ,sysdate
        ,FND_GLOBAL.USER_ID
        ,FND_GLOBAL.CONC_LOGIN_ID
        ,NULL
        ,'Y'
        ,l_customer_ids(i)
        ,l_salesforce_ids(i)
        ,l_person_ids(i)
        ,NULL
        ,l_lead_ids(i)
        ,l_sales_group_ids(i)
        ,NULL
        ,'Y'
        ,'N'
        ,l_open_flags(i)
        ,'Y'
        ,NULL
        ,1
      FROM
        dual
      WHERE
        l_ranks(i) = 1
        AND NOT EXISTS (SELECT 1 FROM as_accesses_all ACS
                        WHERE ACS.lead_id IS NOT NULL
                        AND ACS.lead_id = l_lead_ids(i)
                        AND l_ranks(i) = 1
                        AND ACS.salesforce_id = l_salesforce_ids(i)
                        AND ACS.sales_group_id = l_sales_group_ids(i));


    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     'Inserted into as_accesses_all = ' ||
                     sql%ROWCOUNT);
    END IF;

    -- Commit
    IF (p_commit_flag = 'Y') THEN

      -- Log
      IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'Committing');
      END IF;

      COMMIT;

    ELSE

      -- Log
      IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'Rolling back');
      END IF;

      ROLLBACK;

    END IF;

  END LOOP;

  CLOSE c1;

  -- Log
  IF (p_debug_flag = 'Y' AND
      FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                   'Done:' || 'p_start_id=' || p_start_id ||
                   ',p_end_id='||p_end_id ||
                   ',p_debug_flag='||p_debug_flag);
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

END Mig_SlsCred_Owner_Sub;


PROCEDURE Link_to_Partners(
            p_orig_lead_id IN NUMBER, p_lead_id IN NUMBER,
            p_debug_flag IN VARCHAR2)
IS
   l_module_name               CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_credits_pvt.Link_to_Partners';

   l_lead_workflow_rec         pv_assign_util_pvt.lead_workflow_rec_type;
   l_assignment_rec            pv_assign_util_pvt.ASSIGNMENT_REC_TYPE;
   l_party_notify_rec          pv_assign_util_pvt.party_notify_rec_type;
   l_assignment_id             number;
   l_party_notification_id     number;
   l_orig_itemKey              varchar2(30);
   l_itemKey                   varchar2(30);

   l_user_id                   number := fnd_global.user_id();

   l_return_status             varchar2(1);
   l_msg_count                 number;
   l_msg_data                  varchar2(2000);

   CURSOR lc_get_lwf(pc_lead_id number) is
   SELECT wf_item_type, wf_item_key, wf_status, matched_due_date,
          offered_due_date, bypass_cm_ok_flag, routing_status, routing_type
   FROM pv_lead_workflows
   WHERE lead_id = pc_lead_id and latest_routing_flag = 'Y'
         AND entity = 'OPPORTUNITY';

   CURSOR lc_get_la(pc_itemtype varchar2, pc_itemkey varchar2) is
   SELECT partner_id, assign_sequence, lead_id, status, status_date,
          wf_item_type, wf_item_key, source_type, related_party_id,
          partner_access_code, reason_code, related_party_access_code,
          lead_assignment_id
   FROM pv_lead_assignments
   WHERE wf_item_type = pc_itemtype AND wf_item_key = pc_itemkey;

   CURSOR lc_get_pn(pc_assignment_id NUMBER) IS
   SELECT notification_type, lead_assignment_id, user_id, user_name,
          resource_id, decision_maker_flag, resource_response, response_date
   FROM pv_party_notifications WHERE lead_assignment_id = pc_assignment_id;

BEGIN

    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
        'Start Link_to_Partners');
    END IF;

    OPEN lc_get_lwf(pc_lead_id => p_orig_lead_id);
    FETCH lc_get_lwf INTO
    l_lead_workflow_rec.wf_item_type, l_orig_itemkey,
    l_lead_workflow_rec.wf_status, l_lead_workflow_rec.matched_due_date,
    l_lead_workflow_rec.offered_due_date, l_lead_workflow_rec.bypass_cm_ok_flag,
    l_lead_workflow_rec.routing_status, l_lead_workflow_rec.routing_type;

    IF lc_get_lwf%found THEN

        l_lead_workflow_rec.lead_id             := p_lead_id;
        l_lead_workflow_rec.created_by          := l_user_id;
        l_lead_workflow_rec.last_updated_by     := l_user_id;
        l_lead_workflow_rec.entity              := 'OPPORTUNITY';
        l_lead_workflow_rec.latest_routing_flag := 'Y';

        PV_ASSIGN_UTIL_PVT.Create_lead_workflow_row (
           p_api_version_number  => 1.0,
           p_init_msg_list       => FND_API.G_TRUE,
           p_commit              => FND_API.G_FALSE,
           p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
           p_workflow_rec        => l_lead_workflow_rec,
           x_ItemKey             => l_itemkey,
           x_return_status       => l_return_status,
           x_msg_count           => l_msg_count,
           x_msg_data            => l_msg_data);

        if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
            RAISE FND_API.G_EXC_ERROR;
        end if;

        IF (p_debug_flag = 'Y' AND
            FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'Lead workflow id: ' || l_itemkey);
        END IF;

        FOR c1 IN lc_get_la(pc_itemtype => l_lead_workflow_rec.wf_item_type,
                            pc_itemkey  => l_orig_itemkey)
        LOOP
            l_assignment_rec.lead_id                   := p_lead_id;
            l_assignment_rec.related_party_id          := c1.related_party_id;
            l_assignment_rec.related_party_access_code := c1.related_party_access_code;
            l_assignment_rec.partner_id                := c1.partner_id;
            l_assignment_rec.assign_sequence           := c1.assign_sequence;
            l_assignment_rec.source_type               := c1.source_type;
            l_assignment_rec.reason_code               := c1.reason_code;
            l_assignment_rec.object_version_number     := 0;
            l_assignment_rec.status_date               := c1.status_date;
            l_assignment_rec.status                    := c1.status;
            l_assignment_rec.partner_access_code       := c1.partner_access_code;
            l_assignment_rec.wf_item_type              := c1.wf_item_Type;
            l_assignment_rec.wf_item_key               := l_itemKey;

            pv_assign_util_pvt.Create_lead_assignment_row (
               p_api_version_number  => 1.0,
               p_init_msg_list       => FND_API.G_FALSE,
               p_commit              => FND_API.G_FALSE,
               p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
               p_assignment_rec      => l_assignment_rec,
               x_lead_assignment_id  => l_assignment_id,
               x_return_status       => l_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data);

            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (p_debug_flag = 'Y' AND
                FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                'Lead assignment id: ' || l_assignment_id);
            END IF;

            FOR c2 IN lc_get_pn(pc_assignment_id => c1.lead_assignment_id) LOOP

                l_party_notify_rec.WF_ITEM_TYPE        := l_assignment_rec.wf_item_type;
                l_party_notify_rec.WF_ITEM_KEY         := l_assignment_rec.wf_item_key;
                l_party_notify_rec.LEAD_ASSIGNMENT_ID  := l_assignment_id;
                l_party_notify_rec.NOTIFICATION_TYPE   := c2.notification_type;
                l_party_notify_rec.RESOURCE_ID         := c2.resource_id;
                l_party_notify_rec.USER_ID             := c2.user_id;
                l_party_notify_rec.USER_NAME           := c2.user_name;
                l_party_notify_rec.RESOURCE_RESPONSE   := c2.resource_response;
                l_party_notify_rec.RESPONSE_DATE       := c2.response_date;
                l_party_notify_rec.DECISION_MAKER_FLAG := c2.decision_maker_flag;

                pv_assign_util_pvt.create_party_notification(
                   p_api_version_number     => 1.0
                  ,p_init_msg_list         => FND_API.G_FALSE
                  ,p_commit                => FND_API.G_FALSE
                  ,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
                  ,P_party_notify_Rec      => l_party_notify_rec
                  ,x_party_notification_id => l_party_notification_id
                  ,x_return_status         => l_return_status
                  ,x_msg_count             => l_msg_count
                  ,x_msg_data              => l_msg_data);

                IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                IF (p_debug_flag = 'Y' AND
                    FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                    'Party Notification id: ' || l_party_notification_id);
                END IF;

            END LOOP;
        END LOOP;

    END IF;
    CLOSE lc_get_lwf;

    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
        'End Link_to_Partners');
    END IF;
END Link_to_Partners;


-- Step 3.f.ii Updates Sales Credits so that only the quota credits of a
-- single Sales Rep are retained and changed to 100%. The line amounts are
-- changed to the Sales Credit amounts.
PROCEDURE Update_sc_for_rep (
    p_lead_id           IN NUMBER,
    p_sf_id             IN NUMBER,
    p_sg_id             IN NUMBER,
    p_credit_type_id    IN NUMBER,
    p_identity_sf_id    IN NUMBER,
    p_debug_flag        IN VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    )
 IS
  l_module_name     CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_credits_pvt.Update_sc_for_rep';

  l_sc_tbl          AS_OPPORTUNITY_PUB.Sales_Credit_Tbl_Type;
  l_sc_out_tbl      AS_OPPORTUNITY_PUB.Sales_Credit_Out_Tbl_Type;

  l_sc_amount       NUMBER;

  l_ll_tbl          AS_OPPORTUNITY_PUB.Line_Tbl_Type;
  l_ll_tbl_count    NUMBER;
  l_ll_out_tbl      AS_OPPORTUNITY_PUB.Line_Out_Tbl_Type;

  l_header_rec      AS_OPPORTUNITY_PUB.Header_Rec_Type;

  CURSOR c_rep_quota_credits(p_lead_id NUMBER, p_credit_type_id NUMBER,
            p_sf_id NUMBER, p_sg_id NUMBER) IS
    SELECT * FROM as_sales_credits
    WHERE lead_id = p_lead_id
          AND credit_type_id = p_credit_type_id
          AND nvl(salesforce_id, -37) = nvl(p_sf_id, -37)
          AND nvl(salesgroup_id, -37) = nvl(p_sg_id, -37)
    ORDER BY lead_line_id;

  l_sc_select_rec       c_rep_quota_credits%ROWTYPE;
  l_sc_next_select_rec  c_rep_quota_credits%ROWTYPE;

  CURSOR c_lead_line(p_lead_line_id NUMBER, p_sc_amount NUMBER) IS
    SELECT *
    FROM as_lead_lines
    WHERE lead_line_id = p_lead_line_id AND total_amount <> p_sc_amount;

BEGIN

    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
        'Begin Update_sc_for_rep');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Update Sales Credits to only those which the rep
    -- is getting.
    l_sc_amount := 0;
    l_ll_tbl.DELETE;
    l_ll_tbl_count := 0;
    OPEN c_rep_quota_credits(p_lead_id,
                    p_credit_type_id, p_sf_id,
                    p_sg_id);
    FETCH c_rep_quota_credits INTO l_sc_next_select_rec;
    WHILE c_rep_quota_credits%FOUND LOOP
        l_sc_select_rec := l_sc_next_select_rec;
        -- Prefetching to detect last row
        FETCH c_rep_quota_credits INTO l_sc_next_select_rec;
        l_sc_amount := l_sc_amount +
                       l_sc_select_rec.credit_amount;

        -- If the next sales credit is not for the same line(duplicate) or if
        -- we have reached the last record then add it to the list of Sales
        -- Credits.
        IF c_rep_quota_credits%NOTFOUND OR
           (l_sc_select_rec.lead_line_id
            <> l_sc_next_select_rec.lead_line_id) THEN
            l_sc_tbl.DELETE;
            -- last_update_date should be passed as such to Update API's.
            -- Passing sysdate will result in an error asking to requery
            -- the (Dirty) Record
            l_sc_tbl(1).last_update_date := l_sc_select_rec.last_update_date;
            l_sc_tbl(1).last_updated_by := FND_GLOBAL.user_id;
            l_sc_tbl(1).creation_Date := l_sc_select_rec.creation_Date;
            l_sc_tbl(1).created_by := FND_GLOBAL.user_id;
            l_sc_tbl(1).last_update_login := FND_GLOBAL.conc_login_id;
            l_sc_tbl(1).request_id := FND_GLOBAL.conc_request_id;
            l_sc_tbl(1).program_application_id := FND_GLOBAL.prog_appl_id;
            l_sc_tbl(1).program_id := FND_GLOBAL.conc_program_id;
            l_sc_tbl(1).program_update_date := sysdate;
            l_sc_tbl(1).sales_credit_id := l_sc_select_rec.sales_credit_id;
            l_sc_tbl(1).original_sales_credit_id := l_sc_select_rec.original_sales_credit_id;
            l_sc_tbl(1).lead_id := l_sc_select_rec.lead_id;
            l_sc_tbl(1).lead_line_id := l_sc_select_rec.lead_line_id;
            l_sc_tbl(1).salesforce_id := l_sc_select_rec.salesforce_id;
            l_sc_tbl(1).person_id := l_sc_select_rec.person_id;
            l_sc_tbl(1).salesgroup_id := l_sc_select_rec.salesgroup_id;
            l_sc_tbl(1).partner_customer_id := l_sc_select_rec.partner_customer_id;
            l_sc_tbl(1).partner_address_id := l_sc_select_rec.partner_address_id;
            l_sc_tbl(1).revenue_amount := l_sc_select_rec.revenue_amount;
            l_sc_tbl(1).revenue_percent := l_sc_select_rec.revenue_percent;
            l_sc_tbl(1).quota_credit_amount := l_sc_select_rec.quota_credit_amount;
            l_sc_tbl(1).quota_credit_percent := l_sc_select_rec.quota_credit_percent;
            l_sc_tbl(1).MANAGER_REVIEW_FLAG := l_sc_select_rec.MANAGER_REVIEW_FLAG;
            l_sc_tbl(1).MANAGER_REVIEW_DATE := l_sc_select_rec.MANAGER_REVIEW_DATE;
            l_sc_tbl(1).credit_type_id := l_sc_select_rec.credit_type_id;
            l_sc_tbl(1).credit_amount := l_sc_amount;
            l_sc_tbl(1).credit_percent := 100;
            l_sc_tbl(1).attribute_category := l_sc_select_rec.attribute_category;
            l_sc_tbl(1).attribute1 := l_sc_select_rec.attribute1;
            l_sc_tbl(1).attribute2 := l_sc_select_rec.attribute2;
            l_sc_tbl(1).attribute3 := l_sc_select_rec.attribute3;
            l_sc_tbl(1).attribute4 := l_sc_select_rec.attribute4;
            l_sc_tbl(1).attribute5 := l_sc_select_rec.attribute5;
            l_sc_tbl(1).attribute6 := l_sc_select_rec.attribute6;
            l_sc_tbl(1).attribute7 := l_sc_select_rec.attribute7;
            l_sc_tbl(1).attribute8 := l_sc_select_rec.attribute8;
            l_sc_tbl(1).attribute9 := l_sc_select_rec.attribute9;
            l_sc_tbl(1).attribute10 := l_sc_select_rec.attribute10;
            l_sc_tbl(1).attribute11 := l_sc_select_rec.attribute11;
            l_sc_tbl(1).attribute12 := l_sc_select_rec.attribute12;
            l_sc_tbl(1).attribute13 := l_sc_select_rec.attribute13;
            l_sc_tbl(1).attribute14 := l_sc_select_rec.attribute14;
            l_sc_tbl(1).attribute15 := l_sc_select_rec.attribute15;

            AS_OPPORTUNITY_PUB.Modify_Sales_Credits(
                p_api_version_number        => 2.0,
                p_init_msg_list             => FND_API.G_FALSE,
                p_commit                    => FND_API.G_FALSE,
                p_validation_level          => 90,
                p_identity_salesforce_id    => p_identity_sf_id,
                p_sales_credit_tbl          => l_sc_tbl,
                p_check_access_flag         => 'N',
                p_admin_flag                => 'N',
                p_admin_group_id            => NULL,
                p_partner_cont_party_id     => NULL,
                x_sales_credit_out_tbl      => l_sc_out_tbl,
                x_return_status             => x_return_status,
                x_msg_count                 => x_msg_count,
                x_msg_data                  => x_msg_data
            );

            -- There will be atmost one looping of the below FOR LOOP
            FOR ll_select_rec IN
                c_lead_line(l_sc_tbl(1).lead_line_id, l_sc_amount)
            LOOP
                l_ll_tbl_count := l_ll_tbl_count + 1;

                -- last_update_date should be passed as such to Update API's.
                -- Passing sysdate will result in an error asking to requery
                -- the (Dirty) Record
                l_ll_tbl(l_ll_tbl_count).last_update_date := ll_select_rec.last_update_date;
                l_ll_tbl(l_ll_tbl_count).last_updated_by := FND_GLOBAL.user_id;
                l_ll_tbl(l_ll_tbl_count).creation_Date := ll_select_rec.creation_Date;
                l_ll_tbl(l_ll_tbl_count).created_by := ll_select_rec.created_by;
                l_ll_tbl(l_ll_tbl_count).last_update_login := FND_GLOBAL.conc_login_id;
                l_ll_tbl(l_ll_tbl_count).request_id := FND_GLOBAL.conc_request_id;
                l_ll_tbl(l_ll_tbl_count).program_application_id := FND_GLOBAL.prog_appl_id;
                l_ll_tbl(l_ll_tbl_count).program_id := FND_GLOBAL.conc_program_id;
                l_ll_tbl(l_ll_tbl_count).program_update_date := sysdate;
                l_ll_tbl(l_ll_tbl_count).lead_id := ll_select_rec.lead_id;
                l_ll_tbl(l_ll_tbl_count).lead_line_id := ll_select_rec.lead_line_id;
                l_ll_tbl(l_ll_tbl_count).original_lead_line_id := ll_select_rec.original_lead_line_id;
                l_ll_tbl(l_ll_tbl_count).interest_type_id := ll_select_rec.interest_type_id;
                l_ll_tbl(l_ll_tbl_count).interest_status_code := ll_select_rec.interest_status_code;
                l_ll_tbl(l_ll_tbl_count).primary_interest_code_id := ll_select_rec.primary_interest_code_id;
                l_ll_tbl(l_ll_tbl_count).secondary_interest_code_id := ll_select_rec.secondary_interest_code_id;
                l_ll_tbl(l_ll_tbl_count).inventory_item_id := ll_select_rec.inventory_item_id;
                l_ll_tbl(l_ll_tbl_count).organization_id := ll_select_rec.organization_id;
                l_ll_tbl(l_ll_tbl_count).uom_code := ll_select_rec.uom_code;
                l_ll_tbl(l_ll_tbl_count).quantity := ll_select_rec.quantity;
                l_ll_tbl(l_ll_tbl_count).ship_date := ll_select_rec.ship_date;
                l_ll_tbl(l_ll_tbl_count).total_amount := l_sc_amount;
                l_ll_tbl(l_ll_tbl_count).sales_stage_id := ll_select_rec.sales_stage_id;
                l_ll_tbl(l_ll_tbl_count).win_probability := ll_select_rec.win_probability;
                l_ll_tbl(l_ll_tbl_count).status_code := ll_select_rec.status_code;
                l_ll_tbl(l_ll_tbl_count).decision_date := ll_select_rec.decision_date;
                l_ll_tbl(l_ll_tbl_count).channel_code := ll_select_rec.channel_code;
                l_ll_tbl(l_ll_tbl_count).price := ll_select_rec.price;
                l_ll_tbl(l_ll_tbl_count).price_volume_margin := ll_select_rec.price_volume_margin;
                l_ll_tbl(l_ll_tbl_count).quoted_line_flag := ll_select_rec.quoted_line_flag;
                l_ll_tbl(l_ll_tbl_count).Source_Promotion_Id := ll_select_rec.Source_Promotion_Id;
                l_ll_tbl(l_ll_tbl_count).forecast_date := ll_select_rec.forecast_date;
                l_ll_tbl(l_ll_tbl_count).rolling_forecast_flag := ll_select_rec.rolling_forecast_flag;
                l_ll_tbl(l_ll_tbl_count).Offer_Id := ll_select_rec.Offer_Id;
                l_ll_tbl(l_ll_tbl_count).ORG_ID := ll_select_rec.ORG_ID;
                l_ll_tbl(l_ll_tbl_count).product_category_id := ll_select_rec.product_category_id;
                l_ll_tbl(l_ll_tbl_count).product_cat_set_id := ll_select_rec.product_cat_set_id;
                l_ll_tbl(l_ll_tbl_count).attribute_category := ll_select_rec.attribute_category;
                l_ll_tbl(l_ll_tbl_count).attribute1 := ll_select_rec.attribute1;
                l_ll_tbl(l_ll_tbl_count).attribute2 := ll_select_rec.attribute2;
                l_ll_tbl(l_ll_tbl_count).attribute3 := ll_select_rec.attribute3;
                l_ll_tbl(l_ll_tbl_count).attribute4 := ll_select_rec.attribute4;
                l_ll_tbl(l_ll_tbl_count).attribute5 := ll_select_rec.attribute5;
                l_ll_tbl(l_ll_tbl_count).attribute6 := ll_select_rec.attribute6;
                l_ll_tbl(l_ll_tbl_count).attribute7 := ll_select_rec.attribute7;
                l_ll_tbl(l_ll_tbl_count).attribute8 := ll_select_rec.attribute8;
                l_ll_tbl(l_ll_tbl_count).attribute9 := ll_select_rec.attribute9;
                l_ll_tbl(l_ll_tbl_count).attribute10 := ll_select_rec.attribute10;
                l_ll_tbl(l_ll_tbl_count).attribute11 := ll_select_rec.attribute11;
                l_ll_tbl(l_ll_tbl_count).attribute12 := ll_select_rec.attribute12;
                l_ll_tbl(l_ll_tbl_count).attribute13 := ll_select_rec.attribute13;
                l_ll_tbl(l_ll_tbl_count).attribute14 := ll_select_rec.attribute14;
                l_ll_tbl(l_ll_tbl_count).attribute15 := ll_select_rec.attribute15;
            END LOOP;
            l_sc_amount := 0;
        END IF;
    END LOOP;
    CLOSE c_rep_quota_credits;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Update Lead Line Amounts
    l_header_rec.lead_id := p_lead_id;

    IF l_ll_tbl_count > 0 THEN
        AS_OPPORTUNITY_PUB.Update_Opp_Lines(
            p_api_version_number        => 2.0,
            p_init_msg_list             => FND_API.G_FALSE,
            p_commit                    => FND_API.G_FALSE,
            p_validation_level          => 90,
            p_identity_salesforce_id    => p_identity_sf_id,
            p_line_tbl                  => l_ll_tbl,
            p_header_rec                => l_header_rec,
            p_check_access_flag         => 'N',
            p_admin_flag                => 'N',
            p_admin_group_id            => NULL,
            p_partner_cont_party_id     => NULL,
            x_line_out_tbl              => l_ll_out_tbl,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
        );
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
        'End Update_sc_for_rep');
    END IF;

    EXCEPTION
    WHEN OTHERS then
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                        'In When others (Update_sc_for_rep). lead_id: '
                        || p_lead_id || ' Exception SQlerr is : ' ||
                        substr(SQLERRM, 1, 1950));
        END IF;

End Update_sc_for_rep;


--
--
--
-- Step 3.f.ii Updates Sales Credits so that only the quota credits of a
-- single Sales Rep are retained and changed to 100%. The line amounts are
-- changed to the Sales Credit amounts.
PROCEDURE Update_sc_for_rep_line (
    p_lead_id           IN NUMBER,
    p_lead_line_id      IN NUMBER,
    p_sf_id             IN NUMBER,
    p_sg_id             IN NUMBER,
    p_credit_type_id    IN NUMBER,
    p_identity_sf_id    IN NUMBER,
    p_debug_flag        IN VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    )
 IS
  l_module_name     CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_credits_pvt.Update_sc_for_rep';

  l_sc_tbl          AS_OPPORTUNITY_PUB.Sales_Credit_Tbl_Type;
  l_sc_out_tbl      AS_OPPORTUNITY_PUB.Sales_Credit_Out_Tbl_Type;

  l_sc_amount       NUMBER;

  l_ll_tbl          AS_OPPORTUNITY_PUB.Line_Tbl_Type;
  l_ll_tbl_count    NUMBER;
  l_ll_out_tbl      AS_OPPORTUNITY_PUB.Line_Out_Tbl_Type;

  l_header_rec      AS_OPPORTUNITY_PUB.Header_Rec_Type;

  CURSOR c_rep_quota_credits(p_lead_id NUMBER,p_lead_line_id NUMBER, p_credit_type_id NUMBER,
            p_sf_id NUMBER, p_sg_id NUMBER) IS
    SELECT * FROM as_sales_credits
    WHERE lead_id = p_lead_id
          AND lead_line_id = p_lead_line_id
          AND credit_type_id = p_credit_type_id
          AND nvl(salesforce_id, -37) = nvl(p_sf_id, -37)
          AND nvl(salesgroup_id, -37) = nvl(p_sg_id, -37)
    ORDER BY lead_line_id;

  l_sc_select_rec       c_rep_quota_credits%ROWTYPE;
  l_sc_next_select_rec  c_rep_quota_credits%ROWTYPE;

  CURSOR c_lead_line(p_lead_line_id NUMBER, p_sc_amount NUMBER) IS
    SELECT *
    FROM as_lead_lines
    WHERE lead_line_id = p_lead_line_id AND total_amount <> p_sc_amount;

BEGIN

    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
        'Begin Update_sc_for_rep');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Update Sales Credits to only those which the rep
    -- is getting.
    l_sc_amount := 0;
    l_ll_tbl.DELETE;
    l_ll_tbl_count := 0;
    OPEN c_rep_quota_credits(p_lead_id,p_lead_line_id,
                    p_credit_type_id, p_sf_id,
                    p_sg_id);
    FETCH c_rep_quota_credits INTO l_sc_next_select_rec;
    WHILE c_rep_quota_credits%FOUND LOOP
        l_sc_select_rec := l_sc_next_select_rec;
        -- Prefetching to detect last row
        FETCH c_rep_quota_credits INTO l_sc_next_select_rec;
        l_sc_amount := l_sc_amount +
                       l_sc_select_rec.credit_amount;

        -- If the next sales credit is not for the same line(duplicate) or if
        -- we have reached the last record then add it to the list of Sales
        -- Credits.
        IF c_rep_quota_credits%NOTFOUND OR
           (l_sc_select_rec.lead_line_id
            <> l_sc_next_select_rec.lead_line_id) THEN
            l_sc_tbl.DELETE;
            -- last_update_date should be passed as such to Update API's.
            -- Passing sysdate will result in an error asking to requery
            -- the (Dirty) Record
            l_sc_tbl(1).last_update_date := l_sc_select_rec.last_update_date;
            l_sc_tbl(1).last_updated_by := FND_GLOBAL.user_id;
            l_sc_tbl(1).creation_Date := l_sc_select_rec.creation_Date;
            l_sc_tbl(1).created_by := FND_GLOBAL.user_id;
            l_sc_tbl(1).last_update_login := FND_GLOBAL.conc_login_id;
            l_sc_tbl(1).request_id := FND_GLOBAL.conc_request_id;
            l_sc_tbl(1).program_application_id := FND_GLOBAL.prog_appl_id;
            l_sc_tbl(1).program_id := FND_GLOBAL.conc_program_id;
            l_sc_tbl(1).program_update_date := sysdate;
            l_sc_tbl(1).sales_credit_id := l_sc_select_rec.sales_credit_id;
            l_sc_tbl(1).original_sales_credit_id := l_sc_select_rec.original_sales_credit_id;
            l_sc_tbl(1).lead_id := l_sc_select_rec.lead_id;
            l_sc_tbl(1).lead_line_id := l_sc_select_rec.lead_line_id;
            l_sc_tbl(1).salesforce_id := l_sc_select_rec.salesforce_id;
            l_sc_tbl(1).person_id := l_sc_select_rec.person_id;
            l_sc_tbl(1).salesgroup_id := l_sc_select_rec.salesgroup_id;
            l_sc_tbl(1).partner_customer_id := l_sc_select_rec.partner_customer_id;
            l_sc_tbl(1).partner_address_id := l_sc_select_rec.partner_address_id;
            l_sc_tbl(1).revenue_amount := l_sc_select_rec.revenue_amount;
            l_sc_tbl(1).revenue_percent := l_sc_select_rec.revenue_percent;
            l_sc_tbl(1).quota_credit_amount := l_sc_select_rec.quota_credit_amount;
            l_sc_tbl(1).quota_credit_percent := l_sc_select_rec.quota_credit_percent;
            l_sc_tbl(1).MANAGER_REVIEW_FLAG := l_sc_select_rec.MANAGER_REVIEW_FLAG;
            l_sc_tbl(1).MANAGER_REVIEW_DATE := l_sc_select_rec.MANAGER_REVIEW_DATE;
            l_sc_tbl(1).credit_type_id := l_sc_select_rec.credit_type_id;
            l_sc_tbl(1).credit_amount := l_sc_amount;
            l_sc_tbl(1).credit_percent := 100;
            l_sc_tbl(1).attribute_category := l_sc_select_rec.attribute_category;
            l_sc_tbl(1).attribute1 := l_sc_select_rec.attribute1;
            l_sc_tbl(1).attribute2 := l_sc_select_rec.attribute2;
            l_sc_tbl(1).attribute3 := l_sc_select_rec.attribute3;
            l_sc_tbl(1).attribute4 := l_sc_select_rec.attribute4;
            l_sc_tbl(1).attribute5 := l_sc_select_rec.attribute5;
            l_sc_tbl(1).attribute6 := l_sc_select_rec.attribute6;
            l_sc_tbl(1).attribute7 := l_sc_select_rec.attribute7;
            l_sc_tbl(1).attribute8 := l_sc_select_rec.attribute8;
            l_sc_tbl(1).attribute9 := l_sc_select_rec.attribute9;
            l_sc_tbl(1).attribute10 := l_sc_select_rec.attribute10;
            l_sc_tbl(1).attribute11 := l_sc_select_rec.attribute11;
            l_sc_tbl(1).attribute12 := l_sc_select_rec.attribute12;
            l_sc_tbl(1).attribute13 := l_sc_select_rec.attribute13;
            l_sc_tbl(1).attribute14 := l_sc_select_rec.attribute14;
            l_sc_tbl(1).attribute15 := l_sc_select_rec.attribute15;

            AS_OPPORTUNITY_PUB.Modify_Sales_Credits(
                p_api_version_number        => 2.0,
                p_init_msg_list             => FND_API.G_FALSE,
                p_commit                    => FND_API.G_FALSE,
                p_validation_level          => 90,
                p_identity_salesforce_id    => p_identity_sf_id,
                p_sales_credit_tbl          => l_sc_tbl,
                p_check_access_flag         => 'N',
                p_admin_flag                => 'N',
                p_admin_group_id            => NULL,
                p_partner_cont_party_id     => NULL,
                x_sales_credit_out_tbl      => l_sc_out_tbl,
                x_return_status             => x_return_status,
                x_msg_count                 => x_msg_count,
                x_msg_data                  => x_msg_data
            );

            -- There will be atmost one looping of the below FOR LOOP
            FOR ll_select_rec IN
                c_lead_line(l_sc_tbl(1).lead_line_id, l_sc_amount)
            LOOP
                l_ll_tbl_count := l_ll_tbl_count + 1;

                -- last_update_date should be passed as such to Update API's.
                -- Passing sysdate will result in an error asking to requery
                -- the (Dirty) Record
                l_ll_tbl(l_ll_tbl_count).last_update_date := ll_select_rec.last_update_date;
                l_ll_tbl(l_ll_tbl_count).last_updated_by := FND_GLOBAL.user_id;
                l_ll_tbl(l_ll_tbl_count).creation_Date := ll_select_rec.creation_Date;
                l_ll_tbl(l_ll_tbl_count).created_by := ll_select_rec.created_by;
                l_ll_tbl(l_ll_tbl_count).last_update_login := FND_GLOBAL.conc_login_id;
                l_ll_tbl(l_ll_tbl_count).request_id := FND_GLOBAL.conc_request_id;
                l_ll_tbl(l_ll_tbl_count).program_application_id := FND_GLOBAL.prog_appl_id;
                l_ll_tbl(l_ll_tbl_count).program_id := FND_GLOBAL.conc_program_id;
                l_ll_tbl(l_ll_tbl_count).program_update_date := sysdate;
                l_ll_tbl(l_ll_tbl_count).lead_id := ll_select_rec.lead_id;
                l_ll_tbl(l_ll_tbl_count).lead_line_id := ll_select_rec.lead_line_id;
                l_ll_tbl(l_ll_tbl_count).original_lead_line_id := ll_select_rec.original_lead_line_id;
                l_ll_tbl(l_ll_tbl_count).interest_type_id := ll_select_rec.interest_type_id;
                l_ll_tbl(l_ll_tbl_count).interest_status_code := ll_select_rec.interest_status_code;
                l_ll_tbl(l_ll_tbl_count).primary_interest_code_id := ll_select_rec.primary_interest_code_id;
                l_ll_tbl(l_ll_tbl_count).secondary_interest_code_id := ll_select_rec.secondary_interest_code_id;
                l_ll_tbl(l_ll_tbl_count).inventory_item_id := ll_select_rec.inventory_item_id;
                l_ll_tbl(l_ll_tbl_count).organization_id := ll_select_rec.organization_id;
                l_ll_tbl(l_ll_tbl_count).uom_code := ll_select_rec.uom_code;
                l_ll_tbl(l_ll_tbl_count).quantity := ll_select_rec.quantity;
                l_ll_tbl(l_ll_tbl_count).ship_date := ll_select_rec.ship_date;
                l_ll_tbl(l_ll_tbl_count).total_amount := l_sc_amount;
                l_ll_tbl(l_ll_tbl_count).sales_stage_id := ll_select_rec.sales_stage_id;
                l_ll_tbl(l_ll_tbl_count).win_probability := ll_select_rec.win_probability;
                l_ll_tbl(l_ll_tbl_count).status_code := ll_select_rec.status_code;
                l_ll_tbl(l_ll_tbl_count).decision_date := ll_select_rec.decision_date;
                l_ll_tbl(l_ll_tbl_count).channel_code := ll_select_rec.channel_code;
                l_ll_tbl(l_ll_tbl_count).price := ll_select_rec.price;
                l_ll_tbl(l_ll_tbl_count).price_volume_margin := ll_select_rec.price_volume_margin;
                l_ll_tbl(l_ll_tbl_count).quoted_line_flag := ll_select_rec.quoted_line_flag;
                l_ll_tbl(l_ll_tbl_count).Source_Promotion_Id := ll_select_rec.Source_Promotion_Id;
                l_ll_tbl(l_ll_tbl_count).forecast_date := ll_select_rec.forecast_date;
                l_ll_tbl(l_ll_tbl_count).rolling_forecast_flag := ll_select_rec.rolling_forecast_flag;
                l_ll_tbl(l_ll_tbl_count).Offer_Id := ll_select_rec.Offer_Id;
                l_ll_tbl(l_ll_tbl_count).ORG_ID := ll_select_rec.ORG_ID;
                l_ll_tbl(l_ll_tbl_count).product_category_id := ll_select_rec.product_category_id;
                l_ll_tbl(l_ll_tbl_count).product_cat_set_id := ll_select_rec.product_cat_set_id;
                l_ll_tbl(l_ll_tbl_count).attribute_category := ll_select_rec.attribute_category;
                l_ll_tbl(l_ll_tbl_count).attribute1 := ll_select_rec.attribute1;
                l_ll_tbl(l_ll_tbl_count).attribute2 := ll_select_rec.attribute2;
                l_ll_tbl(l_ll_tbl_count).attribute3 := ll_select_rec.attribute3;
                l_ll_tbl(l_ll_tbl_count).attribute4 := ll_select_rec.attribute4;
                l_ll_tbl(l_ll_tbl_count).attribute5 := ll_select_rec.attribute5;
                l_ll_tbl(l_ll_tbl_count).attribute6 := ll_select_rec.attribute6;
                l_ll_tbl(l_ll_tbl_count).attribute7 := ll_select_rec.attribute7;
                l_ll_tbl(l_ll_tbl_count).attribute8 := ll_select_rec.attribute8;
                l_ll_tbl(l_ll_tbl_count).attribute9 := ll_select_rec.attribute9;
                l_ll_tbl(l_ll_tbl_count).attribute10 := ll_select_rec.attribute10;
                l_ll_tbl(l_ll_tbl_count).attribute11 := ll_select_rec.attribute11;
                l_ll_tbl(l_ll_tbl_count).attribute12 := ll_select_rec.attribute12;
                l_ll_tbl(l_ll_tbl_count).attribute13 := ll_select_rec.attribute13;
                l_ll_tbl(l_ll_tbl_count).attribute14 := ll_select_rec.attribute14;
                l_ll_tbl(l_ll_tbl_count).attribute15 := ll_select_rec.attribute15;
            END LOOP;
            l_sc_amount := 0;
        END IF;
    END LOOP;
    CLOSE c_rep_quota_credits;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Update Lead Line Amounts
    l_header_rec.lead_id := p_lead_id;

    IF l_ll_tbl_count > 0 THEN
        AS_OPPORTUNITY_PUB.Update_Opp_Lines(
            p_api_version_number        => 2.0,
            p_init_msg_list             => FND_API.G_FALSE,
            p_commit                    => FND_API.G_FALSE,
            p_validation_level          => 90,
            p_identity_salesforce_id    => p_identity_sf_id,
            p_line_tbl                  => l_ll_tbl,
            p_header_rec                => l_header_rec,
            p_check_access_flag         => 'N',
            p_admin_flag                => 'N',
            p_admin_group_id            => NULL,
            p_partner_cont_party_id     => NULL,
            x_line_out_tbl              => l_ll_out_tbl,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
        );
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
        'End Update_sc_for_rep');
    END IF;

    EXCEPTION
    WHEN OTHERS then
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
                        'In When others (Update_sc_for_rep). lead_id: '
                        || p_lead_id || ' Exception SQlerr is : ' ||
                        substr(SQLERRM, 1, 1950));
        END IF;

End Update_sc_for_rep_line;

PROCEDURE Copy_Opportunity_Line
(   p_api_version_number            IN    NUMBER,
    p_init_msg_list                 IN    VARCHAR2      :=FND_API.G_FALSE,
    p_commit                        IN    VARCHAR2      := FND_API.G_FALSE,
    p_validation_level              IN    NUMBER        := FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                       IN    NUMBER,
    p_forecast_credit_type_id       IN    NUMBER,
    p_win_probability               IN    NUMBER,
    p_win_loss_indicator            IN    VARCHAR2,
    p_forecast_rollup_flag          IN    VARCHAR2,
    p_lead_line_id                  IN    NUMBER,
    p_sales_credit_amount           IN    NUMBER,
    p_identity_salesforce_id        IN    NUMBER,
    p_salesgroup_id                 IN    NUMBER    := NULL,
    x_return_status                 OUT   NOCOPY   VARCHAR2,
    x_msg_count                     OUT   NOCOPY   NUMBER,
    x_msg_data                      OUT   NOCOPY   VARCHAR2,
    x_lead_line_id                  OUT   NOCOPY   NUMBER
)
IS
l_api_name                    CONSTANT VARCHAR2(30) := 'Copy_Opportunity_Line';
l_api_version_number          CONSTANT NUMBER   := 2.0;
l_index                       NUMBER;
l_rowid                       ROWID;
l_lead_line_id                NUMBER;
l_sales_credit_id             NUMBER;
l_lead_competitor_id          NUMBER;
l_close_competitor_id         NUMBER;
l_lead_competitor_prod_id     NUMBER;
l_lead_decision_factor_id     NUMBER;
l_new_sales_methodology_id    NUMBER;



l_customer_id                 NUMBER;
l_new_status                  VARCHAR2(30);
l_default_status              VARCHAR2(30)    := fnd_profile.value('AS_OPP_STATUS');
l_new_total_amount            NUMBER;
l_tot_revenue_opp_forecast_amt NUMBER := FND_API.G_MISS_NUM; -- Added for ASNB
l_sales_credit_rec         AS_OPPORTUNITY_PUB.Sales_Credit_Rec_type;

l_forecast_credit_type_id     NUMBER := FND_PROFILE.Value('AS_FORECAST_CREDIT_TYPE_ID');
l_val                         NUMBER;
l_date                        DATE;
l_temp_lead_id                NUMBER;
l_cre_st_for_sc_flag          VARCHAR2(1) := 'N';
l_insert                      BOOLEAN;
l_new_sales_credit_amount     NUMBER;
l_temp_bool                   BOOLEAN;

CURSOR c_customer(c_lead_id NUMBER) IS
    SELECT customer_id
    FROM AS_LEADS_ALL
    WHERE lead_id = c_lead_id;

CURSOR c_lines(c_lead_id NUMBER,c_lead_line_id NUMBER) IS
    SELECT *
    FROM AS_LEAD_LINES_ALL
    WHERE lead_id = c_lead_id
    AND   lead_line_id = c_lead_line_id;

CURSOR c_sales_credits(c_lead_id NUMBER, c_lead_line_id NUMBER ,  c_salesforce_id NUMBER ,c_salesgroup_id NUMBER ) IS
    SELECT *
    FROM AS_SALES_CREDITS
    WHERE lead_id = c_lead_id
    AND  lead_line_id = c_lead_line_id
    AND ( salesforce_id = c_salesforce_id and salesgroup_id  = c_salesgroup_id and credit_type_id = p_forecast_credit_type_id )
    AND rowNum < 2
    UNION
    SELECT *
        FROM AS_SALES_CREDITS
        WHERE lead_id = c_lead_id
        AND  lead_line_id = c_lead_line_id
        AND  credit_type_id <> p_forecast_credit_type_id ;

CURSOR c_competitor_products (c_lead_line_id NUMBER) IS
    SELECT *
    FROM AS_LEAD_COMP_PRODUCTS
    WHERE lead_line_id = c_lead_line_id;

CURSOR c_decision_factors(c_lead_line_id NUMBER) IS
    SELECT *
    FROM AS_LEAD_DECISION_FACTORS
    WHERE lead_line_id = c_lead_line_id;

l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

BEGIN
      -- Standard Start of API savepoint
   SAVEPOINT COPY_OPPORTUNITY_PVT;

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


   -- Debug Message
   IF l_debug THEN
   AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
               'Private API: ' || l_api_name || ' start');
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- Copy Opportunity Lines and line details - Sales Credits,
   -- Competitor Products and Decision Factors
   --

   FOR lr IN c_lines(p_lead_id , p_lead_line_id) LOOP
       l_lead_line_id := null;

      -- Copy lines
      AS_LEAD_LINES_PKG.Insert_Row(
         px_LEAD_LINE_ID         => l_LEAD_LINE_ID,
         p_LAST_UPDATE_DATE      => SYSDATE,
         p_LAST_UPDATED_BY       => FND_GLOBAL.USER_ID,
         p_CREATION_DATE         => SYSDATE,
         p_CREATED_BY            => FND_GLOBAL.USER_ID,
         p_LAST_UPDATE_LOGIN     => FND_GLOBAL.CONC_LOGIN_ID,
         p_REQUEST_ID            => lr.REQUEST_ID,
         p_PROGRAM_APPLICATION_ID   => lr.PROGRAM_APPLICATION_ID,
         p_PROGRAM_ID            => lr.PROGRAM_ID,
         p_PROGRAM_UPDATE_DATE   => lr.PROGRAM_UPDATE_DATE,
         p_LEAD_ID               => p_lead_id,
         p_INTEREST_TYPE_ID      => lr.INTEREST_TYPE_ID,
         p_PRIMARY_INTEREST_CODE_ID    => lr.PRIMARY_INTEREST_CODE_ID,
         p_SECONDARY_INTEREST_CODE_ID  => lr.SECONDARY_INTEREST_CODE_ID,
         p_INTEREST_STATUS_CODE  => lr.INTEREST_STATUS_CODE,
         p_INVENTORY_ITEM_ID     => lr.INVENTORY_ITEM_ID,
         p_ORGANIZATION_ID       => lr.ORGANIZATION_ID,
         p_UOM_CODE              => lr.UOM_CODE,
         p_QUANTITY              => lr.QUANTITY,
         p_TOTAL_AMOUNT          => p_sales_credit_amount,
         p_SALES_STAGE_ID        => lr.SALES_STAGE_ID,
         p_WIN_PROBABILITY       => lr.WIN_PROBABILITY,
         p_DECISION_DATE         => lr.DECISION_DATE,
         p_ORG_ID                => lr.ORG_ID,
         p_ATTRIBUTE_CATEGORY    => lr.ATTRIBUTE_CATEGORY,
         p_ATTRIBUTE1            => lr.ATTRIBUTE1,
         p_ATTRIBUTE2            => lr.ATTRIBUTE2,
         p_ATTRIBUTE3            => lr.ATTRIBUTE3,
         p_ATTRIBUTE4            => lr.ATTRIBUTE4,
         p_ATTRIBUTE5            => lr.ATTRIBUTE5,
         p_ATTRIBUTE6            => lr.ATTRIBUTE6,
         p_ATTRIBUTE7            => lr.ATTRIBUTE7,
         p_ATTRIBUTE8            => lr.ATTRIBUTE8,
         p_ATTRIBUTE9            => lr.ATTRIBUTE9,
         p_ATTRIBUTE10           => lr.ATTRIBUTE10,
         p_ATTRIBUTE11           => lr.ATTRIBUTE11,
         p_ATTRIBUTE12           => lr.ATTRIBUTE12,
         p_ATTRIBUTE13           => lr.ATTRIBUTE13,
         p_ATTRIBUTE14           => lr.ATTRIBUTE14,
         p_ATTRIBUTE15           => lr.ATTRIBUTE15,
         p_STATUS_CODE           => lr.STATUS_CODE,
         p_CHANNEL_CODE          => lr.CHANNEL_CODE,
         p_QUOTED_LINE_FLAG      => lr.QUOTED_LINE_FLAG,
         p_PRICE                 => lr.PRICE,
         p_PRICE_VOLUME_MARGIN   => lr.PRICE_VOLUME_MARGIN,
         p_SHIP_DATE             => lr.SHIP_DATE,
         p_FORECAST_DATE         => lr.FORECAST_DATE,
         p_ROLLING_FORECAST_FLAG => lr.ROLLING_FORECAST_FLAG,
         p_SOURCE_PROMOTION_ID   => lr.SOURCE_PROMOTION_ID,
         p_OFFER_ID              => lr.OFFER_ID,
         p_PRODUCT_CATEGORY_ID   => lr.PRODUCT_CATEGORY_ID,
         p_PRODUCT_CAT_SET_ID    => lr.PRODUCT_CAT_SET_ID);

      IF l_lead_line_id is null THEN
         IF l_debug THEN
                   AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: as_lead_lines_pkg.insert_row fail');
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            '  Private API: as_lead_lines_pkg.insert_row '|| l_lead_line_id);
         END IF;
      END IF;

      -- Copy Sales Credits
      FOR scr IN c_sales_credits(p_lead_id, lr.lead_line_id ,p_identity_salesforce_id,p_salesgroup_id) LOOP

         l_sales_credit_id := null;

         -- removing condition for defaulting only for forecast_credit types
         -- bug#4151483
          l_new_sales_credit_amount := p_sales_credit_amount;
          l_temp_bool := AS_OPP_SALES_CREDIT_PVT.Apply_Forecast_Defaults(P_win_probability,
                    P_win_loss_indicator, 'N', -11, P_win_probability,
                    P_win_loss_indicator, P_forecast_rollup_flag,
                    l_new_sales_credit_amount, 'ON-INSERT',
                    l_sales_credit_rec.OPP_WORST_FORECAST_AMOUNT,
                    l_sales_credit_rec.OPP_FORECAST_AMOUNT,
                    l_sales_credit_rec.OPP_BEST_FORECAST_AMOUNT);



         AS_SALES_CREDITS_PKG.Insert_Row(
                px_SALES_CREDIT_ID  => l_SALES_CREDIT_ID,
                p_LAST_UPDATE_DATE  => SYSDATE,
                p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
                p_CREATION_DATE  => SYSDATE,
                p_CREATED_BY  => FND_GLOBAL.USER_ID,
                p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
                p_REQUEST_ID  => scr.REQUEST_ID,
                p_PROGRAM_APPLICATION_ID  => scr.PROGRAM_APPLICATION_ID,
                p_PROGRAM_ID  => scr.PROGRAM_ID,
                p_PROGRAM_UPDATE_DATE  => scr.PROGRAM_UPDATE_DATE,
                p_LEAD_ID  => P_LEAD_ID,
                p_LEAD_LINE_ID  => l_LEAD_LINE_ID,
                p_SALESFORCE_ID  => scr.SALESFORCE_ID,
                p_PERSON_ID  => scr.PERSON_ID,
                p_SALESGROUP_ID  => scr.SALESGROUP_ID,
                p_PARTNER_CUSTOMER_ID  => scr.PARTNER_CUSTOMER_ID,
                p_PARTNER_ADDRESS_ID  => scr.PARTNER_ADDRESS_ID,
                p_REVENUE_AMOUNT  => scr.REVENUE_AMOUNT,
                p_REVENUE_PERCENT  => scr.REVENUE_PERCENT,
                p_QUOTA_CREDIT_AMOUNT  => scr.QUOTA_CREDIT_AMOUNT,
                p_QUOTA_CREDIT_PERCENT  => scr.QUOTA_CREDIT_PERCENT,
                p_ATTRIBUTE_CATEGORY  => scr.ATTRIBUTE_CATEGORY,
                p_ATTRIBUTE1  => scr.ATTRIBUTE1,
                p_ATTRIBUTE2  => scr.ATTRIBUTE2,
                p_ATTRIBUTE3  => scr.ATTRIBUTE3,
                p_ATTRIBUTE4  => scr.ATTRIBUTE4,
                p_ATTRIBUTE5  => scr.ATTRIBUTE5,
                p_ATTRIBUTE6  => scr.ATTRIBUTE6,
                p_ATTRIBUTE7  => scr.ATTRIBUTE7,
                p_ATTRIBUTE8  => scr.ATTRIBUTE8,
                p_ATTRIBUTE9  => scr.ATTRIBUTE9,
                p_ATTRIBUTE10  => scr.ATTRIBUTE10,
                p_ATTRIBUTE11  => scr.ATTRIBUTE11,
                p_ATTRIBUTE12  => scr.ATTRIBUTE12,
                p_ATTRIBUTE13  => scr.ATTRIBUTE13,
                p_ATTRIBUTE14  => scr.ATTRIBUTE14,
                p_ATTRIBUTE15  => scr.ATTRIBUTE15,
                p_MANAGER_REVIEW_FLAG  => scr.MANAGER_REVIEW_FLAG,
                p_MANAGER_REVIEW_DATE  => scr.MANAGER_REVIEW_DATE,
                p_ORIGINAL_SALES_CREDIT_ID  => scr.ORIGINAL_SALES_CREDIT_ID,
                p_CREDIT_PERCENT  => 100,
                p_CREDIT_AMOUNT  => l_new_sales_credit_amount,
                p_CREDIT_TYPE_ID  => scr.CREDIT_TYPE_ID,
            -- The following fields are not passed before ASNB
                p_OPP_WORST_FORECAST_AMOUNT  => l_sales_credit_rec.OPP_WORST_FORECAST_AMOUNT,
                p_OPP_FORECAST_AMOUNT  => l_sales_credit_rec.OPP_FORECAST_AMOUNT,
                p_OPP_BEST_FORECAST_AMOUNT => l_sales_credit_rec.OPP_BEST_FORECAST_AMOUNT,
                P_DEFAULTED_FROM_OWNER_FLAG =>scr.DEFAULTED_FROM_OWNER_FLAG -- Added for ASNB
            );

         IF l_sales_credit_id is null THEN
             IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: as_sales_credits_pkg.insert_row fail');
             END IF;

             RAISE FND_API.G_EXC_ERROR;
         ELSE
            IF l_debug THEN
               AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
               'Private API: as_sales_credits_pkg.insert_row '|| l_sales_credit_id);
            END IF;
         END IF;

      END LOOP; -- SC loop




      -- Copy Competitor Products
      FOR cpdr IN c_competitor_products(lr.lead_line_id) LOOP
         l_lead_competitor_prod_id := NULL;
         -- Invoke table handler(AS_LEAD_COMP_PRODUCTS_PKG.Insert_Row)
         AS_LEAD_COMP_PRODUCTS_PKG.Insert_Row(
               p_ATTRIBUTE15  => cpdr.ATTRIBUTE15,
               p_ATTRIBUTE14  => cpdr.ATTRIBUTE14,
               p_ATTRIBUTE13  => cpdr.ATTRIBUTE13,
               p_ATTRIBUTE12  => cpdr.ATTRIBUTE12,
               p_ATTRIBUTE11  => cpdr.ATTRIBUTE11,
               p_ATTRIBUTE10  => cpdr.ATTRIBUTE10,
               p_ATTRIBUTE9  => cpdr.ATTRIBUTE9,
               p_ATTRIBUTE8  => cpdr.ATTRIBUTE8,
               p_ATTRIBUTE7  => cpdr.ATTRIBUTE7,
               p_ATTRIBUTE6  => cpdr.ATTRIBUTE6,
               p_ATTRIBUTE4  => cpdr.ATTRIBUTE4,
               p_ATTRIBUTE5  => cpdr.ATTRIBUTE5,
               p_ATTRIBUTE2  => cpdr.ATTRIBUTE2,
               p_ATTRIBUTE3  => cpdr.ATTRIBUTE3,
               p_ATTRIBUTE1  => cpdr.ATTRIBUTE1,
               p_ATTRIBUTE_CATEGORY  => cpdr.ATTRIBUTE_CATEGORY,
               p_PROGRAM_ID  => cpdr.PROGRAM_ID,
               p_PROGRAM_UPDATE_DATE  => cpdr.PROGRAM_UPDATE_DATE,
               p_PROGRAM_APPLICATION_ID  => cpdr.PROGRAM_APPLICATION_ID,
               p_REQUEST_ID  => cpdr.REQUEST_ID,
               p_WIN_LOSS_STATUS  => cpdr.WIN_LOSS_STATUS,
               p_COMPETITOR_PRODUCT_ID  => cpdr.COMPETITOR_PRODUCT_ID,
               p_LEAD_LINE_ID  => l_LEAD_LINE_ID,
               p_LEAD_ID  => P_LEAD_ID,
               px_LEAD_COMPETITOR_PROD_ID  => l_LEAD_COMPETITOR_PROD_ID,
               p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
               p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
               p_LAST_UPDATE_DATE  => SYSDATE,
               p_CREATED_BY  => FND_GLOBAL.USER_ID,
               p_CREATION_DATE  => SYSDATE);

         IF l_lead_competitor_prod_id is null THEN
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
         'Private API: as_lead_comp_products_pkg.insert_row fail');
         END IF;

             RAISE FND_API.G_EXC_ERROR;
         ELSE
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
         'Private API: as_lead_comp_products_pkg.insert_row '|| l_lead_competitor_prod_id);
         END IF;

         END IF;
         END LOOP; -- CPD loop

         -- Copy Decision Factors
         FOR dfcr IN c_decision_factors(lr.lead_line_id) LOOP
         l_lead_decision_factor_id := NULL;
         AS_LEAD_DECISION_FACTORS_PKG.Insert_Row(
               p_ATTRIBUTE15  => dfcr.ATTRIBUTE15,
               p_ATTRIBUTE14  => dfcr.ATTRIBUTE14,
               p_ATTRIBUTE13  => dfcr.ATTRIBUTE13,
               p_ATTRIBUTE12  => dfcr.ATTRIBUTE12,
               p_ATTRIBUTE11  => dfcr.ATTRIBUTE11,
               p_ATTRIBUTE10  => dfcr.ATTRIBUTE10,
               p_ATTRIBUTE9  => dfcr.ATTRIBUTE9,
               p_ATTRIBUTE8  => dfcr.ATTRIBUTE8,
               p_ATTRIBUTE7  => dfcr.ATTRIBUTE7,
               p_ATTRIBUTE6  => dfcr.ATTRIBUTE6,
               p_ATTRIBUTE5  => dfcr.ATTRIBUTE5,
               p_ATTRIBUTE4  => dfcr.ATTRIBUTE4,
               p_ATTRIBUTE3  => dfcr.ATTRIBUTE3,
               p_ATTRIBUTE2  => dfcr.ATTRIBUTE2,
               p_ATTRIBUTE1  => dfcr.ATTRIBUTE1,
               p_ATTRIBUTE_CATEGORY  => dfcr.ATTRIBUTE_CATEGORY,
               p_PROGRAM_UPDATE_DATE  => dfcr.PROGRAM_UPDATE_DATE,
               p_PROGRAM_ID  => dfcr.PROGRAM_ID,
               p_PROGRAM_APPLICATION_ID  => dfcr.PROGRAM_APPLICATION_ID,
               p_REQUEST_ID  => dfcr.REQUEST_ID,
               p_DECISION_RANK  => dfcr.DECISION_RANK,
               p_DECISION_PRIORITY_CODE  => dfcr.DECISION_PRIORITY_CODE,
               p_DECISION_FACTOR_CODE  => dfcr.DECISION_FACTOR_CODE,
               px_LEAD_DECISION_FACTOR_ID  => l_LEAD_DECISION_FACTOR_ID,
               p_LEAD_LINE_ID  => l_LEAD_LINE_ID,
               p_CREATE_BY  => FND_GLOBAL.USER_ID,
               p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
               p_LAST_UPDATE_DATE  => SYSDATE,
               p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
               p_CREATION_DATE  => SYSDATE);

         IF l_lead_decision_factor_id is null THEN
            IF l_debug THEN
               AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
               'Private API: as_lead_decision_factors_pkg.insert_row fail');
         END IF;

             RAISE FND_API.G_EXC_ERROR;
         ELSE
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
         'Private API: as_lead_decision_factors_pkg.insert_row '|| l_lead_decision_factor_id );
         END IF;
         END IF;
      END LOOP; -- DFC loop

   END LOOP; -- line loop




EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Copy_Opportunity_Line;

--
--
PROCEDURE Mig_Multi_SalesRep_Opp_Main
          (
           errbuf          OUT NOCOPY VARCHAR2,
           retcode         OUT NOCOPY NUMBER,
           p_num_workers   IN NUMBER,
           p_commit_flag   IN VARCHAR2,
           p_debug_flag    IN VARCHAR2
          )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Mig_Multi_SalesRep_Opp_Main';
  l_module_name                  CONSTANT VARCHAR2(256) :=
    'asn.plsql.asn_mig_sales_credits_pvt.Mig_Multi_SalesRep_Opp_Main';
  l_msg_count                    NUMBER;
  l_msg_data                     VARCHAR2(2000);
  l_req_id                       NUMBER;
  l_request_data                 VARCHAR2(30);
  l_max_num_rows                 NUMBER;
  l_rows_per_worker              NUMBER;
  l_start_id                     NUMBER;
  l_end_id                       NUMBER;
  l_batch_size                   CONSTANT NUMBER := 10000;

  CURSOR c1 IS SELECT as_leads_s.nextval FROM dual;

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
                     'Start:' || 'p_num_workers=' || p_num_workers ||
                     ',p_commit_flag=' || p_commit_flag ||
                     ',p_debug_flag=' || p_debug_flag);
    END IF;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Disable AS_SALES_CREDITS_BIUD trigger');
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
         program     => 'ASN_MIG_MULTI_SR_OPP_SUB_PRG',
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
                     'Re-entering:' || 'p_num_workers=' || p_num_workers ||
                     ',p_commit_flag=' || p_commit_flag ||
                     ',p_debug_flag='||p_debug_flag);
    END IF;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Enable AS_SALES_CREDITS_BIUD trigger');
    END IF;

    errbuf := 'Migration completed';
    retcode := 0;

    -- Log
    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                     'Done:' || 'p_num_workers=' || p_num_workers ||
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

END Mig_Multi_SalesRep_Opp_Main;

PROCEDURE Mig_Multi_SalesRep_Opp_sub (
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
    'asn.plsql.asn_mig_sales_credits_pvt.Mig_Multi_SalesRep_Opp_sub';

  l_org_owner_sf_id         NUMBER;
  l_org_owner_sg_id         NUMBER;
  l_org_owner_person_id     NUMBER;
  l_open_flag               VARCHAR2(1);
  l_steam_sf_id             NUMBER;
  l_steam_sg_id             NUMBER;
  l_steam_owner_flag        VARCHAR2(1);
  l_found_steam             BOOLEAN;

  l_forecast_credit_type_id NUMBER;
  l_new_lead_id             NUMBER;
  l_first_sf_id             NUMBER;
  l_first_sg_id             NUMBER;
  l_access_id               NUMBER;
  l_sf_id                   NUMBER;
  l_sg_id                   NUMBER;
  l_user_id                 NUMBER;
  l_uncommitted_opps        NUMBER := 0;
  l_i                       NUMBER;
  l_found                   BOOLEAN;
  l_found_owner             BOOLEAN;
  l_proceed_with_opp        BOOLEAN;
  l_total_percent           NUMBER;
  l_total_credit            NUMBER;
  l_line_amount             NUMBER;

  l_ll_tbl          AS_OPPORTUNITY_PUB.Line_Tbl_Type;
  l_ll_tbl_count    NUMBER;
  l_ll_out_tbl      AS_OPPORTUNITY_PUB.Line_Out_Tbl_Type;

  l_obstacle_tbl          AS_OPPORTUNITY_PUB.Obstacle_Tbl_Type;
  l_obstacle_tbl_count    NUMBER;
  l_obstacle_out_tbl      AS_OPPORTUNITY_PUB.Obstacle_Out_Tbl_Type;

  l_lead_line_id        NUMBER;
  l_new_lead_line_id        NUMBER;
  l_note_id             NUMBER;
  l_new_note_context_id NUMBER;
  l_lead_opp_id         NUMBER;

  l_header_rec          AS_OPPORTUNITY_PUB.Header_Rec_Type;

  l_return_status       VARCHAR2(16);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(1024);

  l_error_count         NUMBER;
  l_error_msg           VARCHAR2(1024);

  l_access_pk_id           NUMBER;

  TYPE srepgrp_tbl_type IS TABLE OF varchar2(100) INDEX BY BINARY_INTEGER;
  l_srepgrp_tbl           srepgrp_tbl_type;

  l_index_number         number(15);
  l_process_lead_first    varchar2(1);
  l_first_rep_group    varchar2(100);
  l_rep_exist_in_line    number;


  TYPE NUMBER_TT IS TABLE OF NUMBER;
  v_deleted_sfids NUMBER_TT;
  v_deleted_sgids NUMBER_TT;


  -- Added for ASN.B migration changes
  -- Cursor to get all leads.
  CURSOR c_leads_in_range(p_credit_type_id NUMBER, p_start_id NUMBER,
                            p_end_id NUMBER)  IS
    SELECT distinct lead_id
     FROM as_sales_credits
     WHERE lead_id BETWEEN p_start_id AND p_end_id;


  -- Selects Opps which have Lines with multiple quota Sales Credits.
  -- Also includes Opportunities with one or more partner quota credits.
  -- This is achieved by sum(decode... in the  GROUP BY
  -- Only if one line has multiple sales credits will it be selected.
  CURSOR c_multicredit_opps(p_lead_id NUMBER,p_credit_type_id NUMBER) IS
    SELECT lead_id ,lead_line_id from
     (SELECT lead_id,lead_line_id,count(1) numofsalescredit ,
             SUM(decode(partner_customer_id, NULL, 0, 1)) isPartnerCredit
      FROM as_sales_credits
      WHERE lead_id = p_lead_id
            AND credit_type_id = p_credit_type_id
      GROUP BY lead_id, lead_line_id
               ) inlinetab
    where isPartnerCredit > 0 or numofsalescredit> 1 order by lead_line_id asc;

  CURSOR c_lead(p_lead_id NUMBER) IS
    SELECT lead.description, lead.customer_id, lead.address_id, lead.owner_salesforce_id,
           lead.owner_sales_group_id, lead.status ,lead.win_probability, status.win_loss_indicator,
           status.forecast_rollup_flag ,status.OPP_OPEN_STATUS_FLAG
    FROM   as_leads_all lead, as_statuses_vl status
    WHERE lead_id = p_lead_id
    AND   lead.status = status.status_code(+);

  -- Ordering by preferred candidates for owner in Sales Team
  CURSOR c_salesteam(p_lead_id NUMBER) IS
    SELECT access_id, salesforce_id, sales_group_id, owner_flag
    FROM as_accesses_all
    WHERE lead_id = p_lead_id AND partner_customer_id IS NULL
          AND partner_cont_party_id IS NULL
    ORDER BY nvl(owner_flag, 'N') DESC,
             nvl(team_leader_flag, 'N') DESC,
             nvl(freeze_flag, 'N') DESC;

  CURSOR c_person_id(p_salesforce_id NUMBER) IS
    SELECT employee_person_id FROM as_salesforce_v
    WHERE salesforce_id = p_salesforce_id;

  CURSOR c_partnerqcredits(p_lead_id NUMBER, p_credit_type_id NUMBER)
  IS
    SELECT salesforce_id FROM as_sales_credits
    WHERE lead_id = p_lead_id AND credit_type_id = p_credit_type_id
          AND partner_customer_id IS NOT NULL;

  -- get those credit revievers who belong to leads lines which
  -- have more than one credit lines
  CURSOR c_credit_receivers(p_lead_id NUMBER, p_lead_line_id NUMBER,p_credit_type_id NUMBER) IS
    SELECT  salesforce_id, salesgroup_id ,sum(credit_amount) credit_amount
    FROM  as_sales_credits
    WHERE lead_id = p_lead_id
    AND lead_line_id = p_lead_line_id
    AND credit_type_id = p_credit_type_id
    and exists (select 'x'
                FROM     as_sales_credits
                WHERE    lead_id = p_lead_id
                AND      lead_line_id = p_lead_line_id
                AND      credit_type_id = p_credit_type_id
                GROUP BY lead_id, lead_line_id
                HAVING   count(*) > 1)
   GROUP BY salesforce_id, salesgroup_id ;


  CURSOR c_lead_denorm_credits(p_lead_id NUMBER, p_credit_type_id NUMBER) IS
    SELECT salesforce_id, sales_group_id, employee_person_id, opp_open_status_flag
    FROM  as_sales_credits_denorm
    WHERE lead_id = p_lead_id AND credit_type_id = p_credit_type_id
          AND partner_customer_id IS NULL;

  CURSOR c_bad_opp(p_lead_id NUMBER, p_credit_type_id NUMBER) IS
    SELECT sc.lead_line_id, sum(sc.credit_percent) total_percent,
           sum(sc.credit_amount) total_credit,
           max(ll.total_amount) line_amount
    FROM as_sales_credits sc, as_lead_lines ll
    WHERE sc.lead_id = p_lead_id
          AND sc.credit_type_id = p_credit_type_id
          AND ll.lead_line_id(+) = sc.lead_line_id
    GROUP BY sc.lead_line_id
    HAVING (sum(sc.credit_percent) <> 100
            OR sum(sc.credit_amount) <> max(ll.total_amount));

  CURSOR c_lead_opp_links(p_lead_id NUMBER) IS
    SELECT * FROM as_sales_lead_opportunity
    WHERE opportunity_id = p_lead_id;

   CURSOR c_get_access_id IS
   SELECT AS_ACCESSES_S.NEXTVAL
   FROM   SYS.DUAL;

   -- Add person to sales team if he is recieving credits
   -- not checking for address or sales role as this is not
   -- enterable field in ASN UI
   CURSOR c_add_sales_team (p_lead_id NUMBER , p_credit_type_id NUMBER) IS
   SELECT DISTINCT opps.lead_id, opps.customer_id, opps.address_id,
        ascr.salesforce_id, ascr.person_id,
        ascr.SALESGROUP_ID
   FROM as_leads_all opps, as_sales_credits ascr
   WHERE opps.lead_id = ascr.lead_id
   AND   opps.lead_id = p_lead_id
   --AND ascr.credit_type_id = p_credit_type_id --- both quota and non-revenue credit receivers should be in the sales team
   AND NOT EXISTS (
       SELECT 'x'
       FROM   as_accesses_all acc
       WHERE  opps.lead_id = acc.lead_id
       AND    acc.SALESFORCE_ID = ascr.SALESFORCE_ID
       and    NVL(acc.SALES_GROUP_ID,-99) = NVL(ascr.SALESGROUP_ID,-99));

--Code added for ASN MIGRATION PERFORMANCE ---Start
l_MAX_fetches   NUMBER  := 10000;
TYPE num_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
  l_lead_id num_list;

TYPE char_list            is TABLE of VARCHAR2(4000) INDEX BY BINARY_INTEGER;
TYPE date_list            is TABLE of DATE INDEX BY BINARY_INTEGER;

l_description		char_list;
l_customer_id		num_list;
l_address_id		num_list;
l_org_owner_sf_id1	num_list;
l_org_owner_sg_id1	num_list;
l_status		char_list;
l_win_probability	num_list;
l_win_loss_indicator	char_list;
l_forecast_rollup_flag  char_list;
l_open_status_flag      char_list;
--l_org_owner_person_id	num_list;
l_employee_person_id	num_list;

l_lead_id_multicredit		num_list;
l_lead_line_id_multicredit		num_list;
l_sf_id1     num_list;

l_opps_lead_id			num_list;
l_opp_rec_lead_id		num_list;
l_opp_rec_customer_id		num_list;
l_opp_rec_address_id		num_list;
l_opp_rec_salesforce_id		num_list;
l_opp_rec_person_id		num_list;
l_opp_rec_SALESGROUP_ID		num_list;
--l_access_pk_id			num_list;

l_bulk_errors			NUMBER;
l_bulk_errors_idx			NUMBER;

BEGIN

 -- Log
      IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
            'Begin OSO->ASN Multiple Sales Credits Opportunity Data Migration.');
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name,
                   'Start:' || 'p_start_id=' || p_start_id ||
                   ',p_end_id='||p_end_id ||
                   ',p_debug_flag='||p_debug_flag);
      END IF;

      l_user_id := FND_GLOBAL.user_id;

      IF l_user_id IS NULL THEN
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module_name,
                'Error: Global User Id is not set');
        END IF;
        RETURN;
      END IF;

      -- Step 1. Initialize p_credit_type_id (l_forecast_credit_type_id in code)
      l_forecast_credit_type_id := FND_PROFILE.Value('AS_FORECAST_CREDIT_TYPE_ID');
      IF l_forecast_credit_type_id IS NULL THEN
        IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module_name,
                'Error: Profile AS_FORECAST_CREDIT_TYPE_ID is not set');
        END IF;
        RETURN;
      END IF;

      -- Log
      IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                   'l_forecast_credit_type_id =' || l_forecast_credit_type_id);
      END IF;

      -- Step 1.a. Set profile options to avoid errors during Copy Opp.
      FND_PROFILE.PUT('AS_COMPETITOR_REQUIRED', 'N');
      FND_PROFILE.PUT('AS_OPP_SOURCE_CODE_REQUIRED', 'N');
      FND_PROFILE.PUT('AS_OPP_ADDRESS_REQUIRED', 'N');
      FND_PROFILE.PUT('AS_ENABLE_OPP_ONLINE_TAP', 'N');
      FND_PROFILE.PUT('AS_ALLOW_UPDATE_FROZEN_OPP', 'Y');
      FND_PROFILE.PUT('AS_MAX_DAY_CLOSE_OPPORTUNITY', 1000000);
      -- To avoid API_NO_ACC_MGR_PRIVILEGE error in AS_ACCESS_PVT when copying
      -- Sales Team with 'AM' as role.
      FND_PROFILE.PUT('AS_CUST_ACCESS', 'F');


      -- Added for ASN.B migration changes
      -- Go thru all leads getting credit , as we need to update the sales team to sync
      -- with the persons gettting credit as well update the non revenue to 100%

      OPEN c_leads_in_range(l_forecast_credit_type_id, p_start_id, p_end_id);
        LOOP

	  FETCH c_leads_in_range BULK COLLECT INTO l_lead_id LIMIT l_MAX_fetches;

          -- Step 2. Identify Opportunities with multiple Sales Reps getting quota
          -- Sales Credits
          BEGIN

          savepoint CURR_OPP;
          l_process_lead_first := 'Y';

	  l_org_owner_person_id := NULL;

	   FOR I IN l_lead_id.first..l_lead_id.last LOOP

	OPEN c_lead(l_lead_id(i));
        FETCH c_lead INTO l_description(i), l_customer_id(i), l_address_id(i),
         l_org_owner_sf_id1(i), l_org_owner_sg_id1(i), l_status(i),l_win_probability(i),
	 l_win_loss_indicator(i),l_forecast_rollup_flag(i),l_open_status_flag(i);
         l_proceed_with_opp := c_lead%FOUND;
        CLOSE c_lead;

	If l_org_owner_sf_id1.count >0 then
	 OPEN c_person_id(l_org_owner_sf_id1(i));
         FETCH c_person_id INTO l_employee_person_id(i);
         CLOSE c_person_id;
	end if;
      END LOOP;

	FORALL I IN l_lead_id.first..l_lead_id.last
	  update as_lead_lines_all
            set forecast_date = NULL, rolling_forecast_flag = 'N' ,
                last_updated_by = FND_GLOBAL.user_id,
                last_update_date = sysdate,
                last_update_login = FND_GLOBAL.conc_login_id
            where lead_id = l_lead_id(i) and rolling_forecast_flag = 'Y';

	--Place for Bad Data --- Start
	FOR I IN l_lead_id.first..l_lead_id.last
	LOOP
        -- Check for bad data
            OPEN c_bad_opp(l_lead_id(i), l_forecast_credit_type_id);
            FETCH c_bad_opp INTO l_lead_line_id, l_total_percent,
            l_total_credit, l_line_amount;
            l_proceed_with_opp := c_bad_opp%NOTFOUND;
            CLOSE c_bad_opp;
            IF NOT l_proceed_with_opp THEN
               IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module_name,
                  'Error: Skipping Opp Id: ' || l_lead_id(i)
                  || 'with bad Sales Credits. For Line Id: '
                  || l_lead_line_id || ', Total Credit Percent: '
                  || l_total_percent || ' <> 100 OR Total Credit Amount: '
                  || l_total_credit || ' <> Line amount: ' || l_line_amount);
               END IF;
            RETURN;
            END IF;
     END LOOP;
	--Place for Bad Data --- End

	FOR I IN l_lead_id.first..l_lead_id.last LOOP
		IF (p_debug_flag = 'Y' AND
		FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
		'processing lead_id '||l_lead_id(i));
		END IF;
	   END LOOP;

        -- make sure all non quota credits are 100% for the existing opportunity
	FORALL I IN l_lead_id.first..l_lead_id.last
         update as_sales_Credits ascr
         set CREDIT_PERCENT = 100 ,
         CREDIT_AMOUNT  = (select total_amount
         from   as_lead_lines oppl
         where  oppl.lead_id = ascr.lead_id
         and    oppl.lead_line_id =  ascr.lead_line_id ),
         last_updated_by = FND_GLOBAL.user_id,
	 last_update_date = sysdate,
         last_update_login = FND_GLOBAL.conc_login_id
         where ascr.lead_id = l_lead_id(i)         and NVL(CREDIT_PERCENT,0) <> 100
         and   CREDIT_TYPE_ID  in
         ( select  SALES_CREDIT_TYPE_ID
         from    oe_sales_credit_types
         where    QUOTA_FLAG = 'N');

         -- delete duplicate non quota credits
         -- This is repeated inside the loop to
         -- ensure that if partner migration causes
         -- duplicate it is removed again .
    	   FORALL I IN l_lead_id.first..l_lead_id.last
           DELETE FROM as_sales_credits where sales_credit_id IN
            (SELECT sales_credit_id
             FROM as_sales_credits ascr,
               (
                SELECT lead_id,lead_line_id,
                       salesforce_id,salesgroup_id,
                       credit_type_id,
                       max(sales_credit_id) maxid
                FROM   as_sales_credits ascr1
                WHERE  ascr1.lead_id = l_lead_id(i)
                AND    ascr1.credit_type_id  in
                  ( SELECT  sales_credit_type_id
                    FROM    oe_sales_credit_types
                    WHERE    quota_flag = 'N')
                GROUP BY lead_id,lead_line_id,salesforce_id,salesgroup_id,credit_type_id
                HAVING COUNT(sales_credit_id) > 1
              ) duplines
               WHERE ascr.lead_id = duplines.lead_id
               AND ascr.lead_line_id = duplines.lead_line_id
               AND ascr.salesforce_id = duplines.salesforce_id
               AND ascr.salesgroup_id = duplines.salesgroup_id
               AND ascr.credit_type_id = duplines.credit_type_id
               AND ascr.SALES_CREDIT_ID <> maxid);

     -- Update full access flag in as_accesses_all for this opportunity
     -- bug#4150276 and as per wenxia's email 28 Jan 2005 18:30:21 -0800
	 FORALL I IN l_lead_id.first..l_lead_id.last
		UPDATE as_accesses_all acc
		SET acc.team_leader_flag = 'Y',
		last_updated_by = FND_GLOBAL.user_id,
		last_update_date = sysdate,
		last_update_login = FND_GLOBAL.conc_login_id
		WHERE acc.lead_id is not null
		AND acc.lead_id  = l_lead_id(i)
		AND nvl(acc.team_leader_flag,'N') <> 'Y'
		AND (
		EXISTS
		( SELECT 1
		FROM  as_sales_credits asc1
		WHERE asc1.lead_id = acc.lead_id
		AND   asc1.salesforce_id = acc.salesforce_id
		AND   asc1.salesgroup_id = acc.sales_group_id )
		OR    acc.owner_flag = 'Y');

		-- delete 0% quota credits
		FORALL I IN l_lead_id.first..l_lead_id.last
	        DELETE FROM as_sales_credits
		WHERE lead_id = l_lead_id(i)
		AND   credit_type_id  = l_forecast_credit_type_id
		AND   NVL(CREDIT_PERCENT,0) = 0 ;


        FOR J IN l_lead_id.first..l_lead_id.last LOOP
        l_process_lead_first := 'Y';
        l_org_owner_sf_id     :=l_org_owner_sf_id1(j);
        l_org_owner_person_id := l_employee_person_id(j);
        l_org_owner_sg_id      :=l_org_owner_sg_id1(j);

        FOR multicredit_opps_rec IN c_multicredit_opps(l_lead_id(j),l_forecast_credit_type_id)
         LOOP

            IF (p_debug_flag = 'Y' AND
               FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
               'processing lead_id line id'||multicredit_opps_rec.lead_line_id);
            END IF;

                  IF (p_debug_flag = 'Y' AND
                     FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                     'Processing Opp Id: ' || l_lead_id(j));
                  END IF;

                   IF l_process_lead_first = 'Y' THEN
                     l_process_lead_first := 'N';

                     OPEN c_partnerqcredits(l_lead_id(j), l_forecast_credit_type_id);
                     FETCH c_partnerqcredits INTO l_sf_id;
                     l_found := c_partnerqcredits%FOUND;
                     CLOSE c_partnerqcredits;

                     IF l_found THEN
                     -- Step 3.b.i If the opportunity owner is NULL then assign a
                     -- a person from the Sales Team as the owner.
                     IF l_org_owner_sf_id1(j)  IS NULL THEN

                           l_found_owner := FALSE;
                           -- First query Sales Team and check if owner is present
                           OPEN c_salesteam(l_lead_id(j));
                           FETCH c_salesteam INTO l_access_id, l_steam_sf_id,
                                   l_steam_sg_id, l_steam_owner_flag;
                           l_found_steam := c_salesteam%FOUND;
                           CLOSE c_salesteam;


                            IF l_found_steam AND l_steam_owner_flag = 'Y' THEN
                              l_org_owner_sf_id := l_steam_sf_id;
                              l_org_owner_sg_id := l_steam_sg_id;
                              l_found_owner := TRUE;
                           END IF;

                        -- Then try to assign a quota credit holder from the
                        -- Sales Credits Denorm Table
                           IF NOT l_found_owner THEN

                              OPEN c_lead_denorm_credits(l_lead_id(j),
                              l_forecast_credit_type_id);
                              FETCH c_lead_denorm_credits
                              INTO l_sf_id, l_sg_id,
                              l_org_owner_person_id, l_open_flag;
                              l_found_owner := c_lead_denorm_credits%FOUND;
                              CLOSE c_lead_denorm_credits;

                             IF l_found_owner THEN

                                 l_org_owner_sf_id := l_sf_id;
                                 l_org_owner_sg_id := l_sg_id;
                                 -- Reset current owner flag.
                                 UPDATE as_accesses_all
                                 SET   owner_flag = 'N' ,
                                    last_updated_by = FND_GLOBAL.user_id,
                                    last_update_date = sysdate,
                                    last_update_login = FND_GLOBAL.conc_login_id
                                 WHERE lead_id = l_lead_id(j) AND owner_flag = 'Y';

                                 -- Reassign owner flag;
                                 UPDATE as_accesses_all
                                 SET owner_flag = 'Y', team_leader_flag = 'Y',
                                 freeze_flag = 'Y',
                                 last_updated_by = FND_GLOBAL.user_id,
                                 last_update_date = sysdate,
                                 last_update_login = FND_GLOBAL.conc_login_id
                                 WHERE lead_id = l_lead_id(j) AND
                                 salesforce_id = l_org_owner_sf_id AND
                                 nvl(sales_group_id, -37) = nvl(l_org_owner_sg_id, -37);

                                IF SQL%NOTFOUND THEN

                                 INSERT INTO
                                    as_accesses_all
                                    (
                                    access_id
                                    ,last_update_date
                                    ,last_updated_by
                                    ,creation_date
                                    ,created_by
                                    ,last_update_login
                                    ,reassign_flag
                                    ,team_leader_flag
                                    ,customer_id
                                    ,salesforce_id
                                    ,person_id
                                    ,partner_customer_id
                                    ,lead_id
                                    ,sales_group_id
                                    ,partner_cont_party_id
                                    ,owner_flag
                                    ,created_by_tap_flag
                                    ,open_flag
                                    ,freeze_flag
                                    ,org_id
                                    ,object_version_number
                                    )
                                    VALUES(
                                    AS_ACCESSES_S.nextval
                                    ,sysdate
                                    ,FND_GLOBAL.user_id
                                    ,sysdate
                                    ,FND_GLOBAL.user_id
                                    ,FND_GLOBAL.conc_login_id
                                    ,NULL
                                    ,'Y'
                                    ,l_customer_id(j)
                                    ,l_org_owner_sf_id
                                    ,l_org_owner_person_id
                                    ,NULL
                                    ,l_lead_id(j)
                                    ,l_org_owner_sg_id
                                    ,NULL
                                    ,'Y'
                                    ,'N'
                                    ,l_open_flag
                                    ,'Y'
                                    ,NULL
                                    ,1
                                    );
                                   END IF;
                             END IF;
                           END IF;


                            IF NOT l_found_owner THEN
                           -- If No owner in SalesTeam found and No
                           -- quota credit holder found in Sales Credits
                           -- Denorm table then pick someone from the
                           -- Sales Team as the owner

                              IF l_found_steam THEN

                                 l_found_owner := TRUE;
                                 l_org_owner_sf_id := l_steam_sf_id;
                                 l_org_owner_sg_id := l_steam_sg_id;

                                 UPDATE AS_ACCESSES_ALL
                                 SET owner_flag = 'Y', team_leader_flag = 'Y',
                                 freeze_flag = 'Y',
                                 last_updated_by = FND_GLOBAL.user_id,
                                 last_update_date = sysdate,
                                 last_update_login = FND_GLOBAL.conc_login_id
                                 WHERE access_id = l_access_id;
                              END IF;
                           END IF;

                           IF l_found_owner THEN

                              UPDATE as_leads_all
                              SET owner_salesforce_id = l_org_owner_sf_id,
                              owner_sales_group_id = l_org_owner_sg_id,
                              last_updated_by = FND_GLOBAL.user_id,
                              last_update_date = sysdate,
                              last_update_login = FND_GLOBAL.conc_login_id
                              WHERE lead_id = l_lead_id(j);

                              IF (p_debug_flag = 'Y' AND
                                 FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                                 'Successfully Assigned Salesforce Id: '
                                 || l_org_owner_sf_id || ' SlsGrp Id: '
                                 || l_org_owner_sg_id
                                 || ' For NULL owner in Opp Header');
                              END IF;
                           ELSE

                              -- Log error message and continue to next Opportunity
                              -- if owner could not be assigned.
                              IF l_org_owner_sf_id IS NULL THEN
                                 IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING(FND_LOG.LEVEL_ERROR, l_module_name,
                                     'Error: Cannot reassign Partner Credits for Opportunity Id'
                                     || l_lead_id(j)
                                     || '. It does not have an owner or an employee in the SalesTeam who can be assigned as the owner');
                                 END IF;
                                 RAISE FND_API.G_EXC_ERROR;
                              END IF;
                           END IF;
                      END IF;

                     -- Step 3.b.ii Reassign partner quota credits to Opp owner
                     UPDATE as_sales_credits
                     SET salesforce_id = l_org_owner_sf_id,
                     salesgroup_id = l_org_owner_sg_id,
                     person_id = l_org_owner_person_id,
                     partner_customer_id = NULL, partner_address_id = NULL,
                     last_updated_by = FND_GLOBAL.user_id,
                     last_update_date = sysdate,
                     last_update_login = FND_GLOBAL.conc_login_id
                     WHERE lead_id = l_lead_id(j)
                     AND credit_type_id = l_forecast_credit_type_id
                     AND partner_customer_id IS NOT NULL;
                      END IF;
                    END IF;


               -- Step 3.c Get the different salesrep and sales group on the
               -- opportunity in this line and loop
               l_first_sf_id := -37;

               --loop thru thoses lines for this opportunity which have more then one credit recievers

               FOR credit_receiver_rec IN
               c_credit_receivers(l_lead_id(j),multicredit_opps_rec.lead_line_id, l_forecast_credit_type_id)
               LOOP

                  l_sf_id := credit_receiver_rec.salesforce_id;
                  l_sg_id := credit_receiver_rec.salesgroup_id;

                  IF (p_debug_flag = 'Y' AND
                  FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                  'Processing SalesForceId: ' || l_sf_id ||
                  ', SalesGroupId: ' || l_sg_id);
                  END IF;


                  -- Check if we are processing the first line for the first time for this lead
                  -- if so then this salesrep id is our first salesrep id and he will given
                  -- priority in all lines from here
                  IF l_first_sf_id = -37   THEN
                     l_first_sf_id := l_sf_id;
                     l_first_sg_id := l_sg_id;

                     IF (p_debug_flag = 'Y' AND
                        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'firstsf-37 lprocess lead first Y '||multicredit_opps_rec.lead_line_id||'-' ||l_sf_id);
                     END IF;

                  ELSE

                  -- Step 3.e For each subsequent salesreps (p_sf_id(i)) and
                  -- salesgroups (p_sg_id(i)), do
                  -- Step 3.e.i Copy Opportunity

                     Copy_Opportunity_Line
                     (   p_api_version_number            => 2.0,
                     p_init_msg_list                 => FND_API.G_FALSE,
                     p_commit                        => FND_API.G_FALSE,
                     p_validation_level              => 90,
                     p_lead_id                       => l_lead_id(j),
                     p_forecast_credit_type_id       => l_forecast_credit_type_id,
                     p_win_probability               => l_win_probability(j),
                     p_win_loss_indicator            => l_win_loss_indicator(j),
                     p_forecast_rollup_flag          => l_forecast_rollup_flag(j),
                     p_lead_line_id                  => multicredit_opps_rec.lead_line_id ,
                     p_sales_credit_amount           => credit_receiver_rec.credit_amount,
                     p_identity_salesforce_id        => credit_receiver_rec.salesforce_id,
                     p_salesgroup_id                 => credit_receiver_rec.salesgroup_id,
                     x_return_status                 => l_return_status,
                     x_msg_count                     => l_msg_count,
                     x_msg_data                      => l_msg_data,
                     x_lead_line_id                  => l_new_lead_line_id
                     );



                     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

                     IF (p_debug_flag = 'Y' AND
                        FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                        'Got Copied Opp Id: ' || l_new_lead_id);
                     END IF;



                  END IF;
               END LOOP;


               -- Step 4. Process Original Opportunity
               IF l_first_sf_id <> -37 THEN

                    Update_sc_for_rep_line (l_lead_id(j),multicredit_opps_rec.lead_line_id, l_first_sf_id, l_first_sg_id,
                        l_forecast_credit_type_id, l_org_owner_sf_id,
                        p_debug_flag, l_return_status, l_msg_count, l_msg_data);

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                    END IF;
               END IF;


         END LOOP;


         -- for the existing opportunity check and make sure that all peopl recieving sales credits
         -- are there in the sales team.
         FOR opp_rec IN c_add_sales_team(l_lead_id(j) ,l_forecast_credit_type_id) LOOP
             OPEN c_get_access_id;
             FETCH c_get_access_id INTO l_access_pk_id;
             CLOSE c_get_access_id;

             INSERT INTO AS_ACCESSES_ALL
                       (ACCESS_ID,
                        ACCESS_TYPE,
                        SALESFORCE_ID,
                        SALES_GROUP_ID,
                        PERSON_ID,
                        CUSTOMER_ID,
                        ADDRESS_ID,
                        LEAD_ID,
                        FREEZE_FLAG,
                        REASSIGN_FLAG,
                        TEAM_LEADER_FLAG,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        PROGRAM_APPLICATION_ID,
                        PROGRAM_ID,
                        PROGRAM_UPDATE_DATE,
                        object_version_number,
                        OPEN_FLAG)
             VALUES
                       (l_access_pk_id,
                        'X',
                        opp_rec.salesforce_id,
                        opp_rec.salesgroup_id,
                        opp_rec.person_id,
                        opp_rec.customer_id,
                        opp_rec.address_id,
                        opp_rec.lead_id,
                        'Y',
                        'N',
                        'Y',
                        SYSDATE,
                        FND_GLOBAL.USER_ID,
                        SYSDATE,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.CONC_LOGIN_ID,
                        FND_GLOBAL.PROG_APPL_ID,
                        FND_GLOBAL.CONC_PROGRAM_ID,
                        SYSDATE,
                        1.0,
                        l_open_status_flag(j));
         END LOOP;

         -- Reassign partner non-quota credits to Opp owner
            IF l_org_owner_sf_id IS NOT NULL and l_org_owner_sg_id IS NOT NULL THEN
                UPDATE as_sales_credits
                SET salesforce_id = l_org_owner_sf_id,
                salesgroup_id = l_org_owner_sg_id,
                person_id = l_org_owner_person_id,
                partner_customer_id = NULL, partner_address_id = NULL,
                last_updated_by = FND_GLOBAL.user_id,
                last_update_date = sysdate,
                last_update_login = FND_GLOBAL.conc_login_id
                WHERE lead_id = l_lead_id(j)
                AND credit_type_id <> l_forecast_credit_type_id
                AND partner_customer_id IS NOT NULL;
            END IF;

         END LOOP;

          -- make sure all sales credit line of the owner of the opp
          -- has the DEFAULTED_FROM_OWNER_FLAG flag set
	    FORALL I IN l_lead_id.first..l_lead_id.last
	    update as_sales_Credits ascr
            set DEFAULTED_FROM_OWNER_FLAG = 'Y',
            last_updated_by = FND_GLOBAL.user_id,
            last_update_date = sysdate,
            last_update_login = FND_GLOBAL.conc_login_id
            where ascr.lead_id = l_lead_id(i)
            and    NVL(DEFAULTED_FROM_OWNER_FLAG,'N') <> 'Y'
            and (SALESFORCE_ID  ,SALESGROUP_ID) in
            (SELECT owner_salesforce_id,owner_sales_group_id
            FROM as_leads_all ala
            WHERE ala.lead_id = l_lead_id(i)  )
            and credit_type_id = l_forecast_credit_type_id;

             -- Reassign partner non-quota credits to Opp owner
	        --added inside loop above.

            -- delete duplicate non quota credits
	    FORALL I IN l_lead_id.first..l_lead_id.last
            DELETE FROM as_sales_credits where sales_credit_id IN
               (SELECT sales_credit_id
                FROM as_sales_credits ascr,
                  (
                   SELECT lead_id,lead_line_id,
                          salesforce_id,salesgroup_id,
                          credit_type_id,
                          max(sales_credit_id) maxid
                   FROM   as_sales_credits ascr1
                   WHERE  ascr1.lead_id = l_lead_id(i)
                   AND    ascr1.credit_type_id  in
                     ( SELECT  sales_credit_type_id
                       FROM    oe_sales_credit_types
                       WHERE    quota_flag = 'N')
                       GROUP BY lead_id,lead_line_id,salesforce_id,salesgroup_id,credit_type_id
                       HAVING COUNT(sales_credit_id) > 1
                 ) duplines
                  WHERE ascr.lead_id = duplines.lead_id
                  AND ascr.lead_line_id = duplines.lead_line_id
                  AND ascr.salesforce_id = duplines.salesforce_id
                  AND ascr.salesgroup_id = duplines.salesgroup_id
                  AND ascr.credit_type_id = duplines.credit_type_id
                  AND ascr.SALES_CREDIT_ID <> maxid);

	FOR I IN l_lead_id.first..l_lead_id.last LOOP
		IF (p_debug_flag = 'Y' AND
		FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
		  'Successfully processed Opp Id: ' || l_lead_id(i));
		END IF;
		 l_uncommitted_opps := l_uncommitted_opps + 1;
		IF l_uncommitted_opps >= p_batch_size THEN
			IF   p_commit_flag = 'Y' THEN
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
		END LOOP;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        Rollback to CURR_OPP;

          IF (p_debug_flag = 'Y' AND
				FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                l_bulk_errors := SQL%BULK_EXCEPTIONS.COUNT;
		FOR i IN 1..l_bulk_errors LOOP
		    l_bulk_errors_idx :=SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
		    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
		    'Ignoring Non Existent Opp Id: ' || l_lead_id(l_bulk_errors_idx));
                COMMIT;
                END LOOP;
	  END IF;
	WHEN OTHERS then
	Rollback to CURR_OPP;

	  l_bulk_errors := SQL%BULK_EXCEPTIONS.COUNT;
	FOR i IN 1..l_bulk_errors LOOP
	l_bulk_errors_idx :=SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;

	IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
	'Error Processing Opp Id : ' || l_lead_id(l_bulk_errors_idx));

	FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
	'Begin Error Info, lead_id: ' || l_lead_id(l_bulk_errors_idx));

	fnd_msg_pub.count_and_get( p_encoded    => 'F'
	,p_count      => l_error_count
	,p_data       => l_error_msg);

	l_i := 0;

	IF l_error_count > 0 THEN
	  IF l_error_count > 10 THEN
	    l_i := l_error_count - 10;
	    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
	    'Last 10 API Messages, lead_id:' || l_lead_id(l_bulk_errors_idx));

   	  ELSE
	   FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
	   l_module_name,
	   'API Messages, lead_id:' || l_lead_id(l_bulk_errors_idx));
	  END IF;
	END IF;

	WHILE l_i < l_error_count LOOP

	l_i := l_i + 1;
	l_error_msg := fnd_msg_pub.get(p_msg_index => l_i,
           p_encoded => 'F');
	FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
	l_module_name, '(lead_id: ' || l_lead_id(l_bulk_errors_idx) ||
				'): ' || substr(l_error_msg,1,1950));

	END LOOP;

	  FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
	  'SQL Error Msg, lead_id: ' || l_lead_id(l_bulk_errors_idx) || ': '
	  || substr(SQLERRM, 1, 1950));

	  FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
	  'End Error Info, lead_id: ' || l_lead_id(l_bulk_errors_idx));

	  FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, l_module_name,
	  'ERROR PROCESSING Opp Id: ' || l_lead_id(l_bulk_errors_idx));

	END IF;

	END LOOP;
	END;

	EXIT WHEN c_leads_in_range%NOTFOUND;
      END LOOP;
      CLOSE c_leads_in_range;

        --Commit;
    IF (p_commit_flag = 'Y') THEN
      -- Log
      IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'Committing');
      END IF;

      COMMIT;
    ELSE
      -- Log
      IF (p_debug_flag = 'Y' AND
          FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
                       'Rolling back');
      END IF;
       ROLLBACK;
    END IF;

    IF (p_debug_flag = 'Y' AND
        FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module_name, 'End of OSO->ASN Multiple Sales Credits Opportunity Data Migration.');
    END IF;

End Mig_Multi_SalesRep_Opp_sub;

END asn_mig_sales_credits_pvt;

/
