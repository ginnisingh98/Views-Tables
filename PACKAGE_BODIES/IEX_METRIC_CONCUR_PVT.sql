--------------------------------------------------------
--  DDL for Package Body IEX_METRIC_CONCUR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_METRIC_CONCUR_PVT" AS
/* $Header: iexvmtcb.pls 120.4.12010000.3 2009/01/13 12:07:27 barathsr ship $ */

PG_DEBUG NUMBER;

G_PKG_NAME    CONSTANT VARCHAR2(30):= 'IEX_METRIC_CONCUR_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'iexvmtcb.pls';
G_METRIC_BATCH VARCHAR2(30):='BATCH';
G_LOGIN_ID NUMBER;
G_PROGRAM_ID NUMBER;
G_USER_ID NUMBER;

/* this will be called by the concurrent program to metric caculation in batch
 */
Procedure Refresh_All(ERRBUF       OUT NOCOPY VARCHAR2,
                      RETCODE      OUT NOCOPY VARCHAR2,
		      P_ORG_ID     IN  NUMBER)

IS
  l_return_status VARCHAR2(10);
  l_msg_data      VARCHAR2(32767);
  l_msg_count     NUMBER;
  l_obj_count     NUMBER; --Added for Bug 7477844 24-Dec-2008 barathsr

  CURSOR c_party IS
    SELECT distinct p.party_id
    FROM hz_parties p, hz_cust_accounts ca
    WHERE p.status = 'A'
    AND ca.status = 'A'
    AND ca.party_id = p.party_id
    --Begin Bug 7477844 24-Dec-2008 barathsr
    AND EXISTS ( select 1 from IEX_DELINQUENCIES_ALL del
		where del.party_cust_id= p.party_id
		and del.status in ('DELINQUENT', 'PREDELINQUENT'));
    --End Bug 7477844 24-Dec-2008 barathsr

  CURSOR c_account IS
    SELECT ca.cust_account_id, p.party_id
    FROM hz_parties p, hz_cust_accounts ca
    WHERE p.status = 'A'
    AND ca.status = 'A'
    AND ca.party_id = p.party_id
    --Begin Bug 7477844 24-Dec-2008 barathsr
    AND EXISTS ( select 1 from IEX_DELINQUENCIES_ALL del
		where del.cust_account_id= ca.cust_account_id
		and del.status in ('DELINQUENT', 'PREDELINQUENT'));
     --End Bug 7477844 24-Dec-2008 barathsr

  CURSOR c_billto IS
    SELECT site_uses.site_use_id site_use_id, ca.cust_account_id cust_account_id, p.party_id,
    acct_site.org_id
    FROM hz_cust_accounts ca, hz_parties p,
         hz_cust_acct_sites acct_site,hz_cust_site_uses site_uses
    WHERE acct_site.cust_acct_site_id = site_uses.cust_acct_site_id
    AND acct_site.cust_account_id = ca.cust_account_id
    AND ca.party_id = p.party_id
    AND p.status = 'A'
    AND ca.status = 'A'
    AND acct_site.status = 'A'
    AND site_uses.status = 'A'
    --Begin Bug 7477844 24-Dec-2008 barathsr
    AND EXISTS ( select 1 from IEX_DELINQUENCIES_ALL del
		where del.customer_site_use_id= site_uses.site_use_id
		and del.status in ('DELINQUENT', 'PREDELINQUENT'));
    --End Bug 7477844 24-Dec-2008 barathsr

  CURSOR c_del IS
    SELECT delinquency_id, customer_site_use_id, cust_account_id, party_cust_id,org_id
    FROM iex_delinquencies
    WHERE status IN ('DELINQUENT', 'PREDELINQUENT');

  --Moac Changes. Define Cursor for org_id. Start.

  CURSOR c_org IS
    SELECT organization_id from hr_operating_units where
      mo_global.check_access(organization_id) = 'Y'
      AND organization_id = nvl(P_ORG_ID,organization_id);

   --Moac Changes. Define Cursor for org_id. End.

   --Begin Bug 7477844 24-Dec-2008 barathsr
   CURSOR c_comp_count(l_jtf_object_code varchar2) IS
    select count(1)
    from iex_score_comp_types_vl
    where metric_flag='Y'
    and jtf_object_code=l_jtf_object_code
    and active_flag='Y';
   --End Bug 7477844 24-Dec-2008 barathsr

  l_metric_id_tbl iex_metric_pvt.metric_id_tbl_type;
  l_metric_name_tbl iex_metric_pvt.metric_name_tbl_type;
  l_metric_value_tbl iex_metric_pvt.metric_value_tbl_type;
  l_metric_rating_tbl iex_metric_pvt.metric_rating_tbl_type;

  CURSOR c_total_cnt IS
    SELECT count(1)
    FROM iex_metric_summaries;

  l_total_cnt NUMBER;
  i NUMBER;
  l_del_sql VARCHAR2(4000) := 'DELETE FROM iex_metric_summaries';

  TYPE Object_ID_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_party_id_tbl Object_ID_Tbl_Type;
  l_cust_account_id_tbl Object_ID_Tbl_Type;
  l_site_use_id_tbl Object_ID_Tbl_Type;
  l_delinquency_id_tbl Object_ID_Tbl_Type;
  l_org_id_tbl Object_ID_Tbl_Type;
  l_batch_size NUMBER;

BEGIN

  RETCODE := 0;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('Metric_Concur: ' || 'IEX_METRIC: metricConcur: Refresh started');
    IEX_DEBUG_PUB.logMessage('Metric_Concur: ' || 'IEX_METRIC: metricConcur: Start time:'|| TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Metric Calculation Method=' || G_METRIC_BATCH);
  l_batch_size := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '1000'));
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch size=' || l_batch_size);

  --Moac Changes. Commented the profile value. Start.
  --l_org_id := TO_NUMBER(NVL(FND_PROFILE.VALUE('ORG_ID'), -1));
  --FND_FILE.PUT_LINE(FND_FILE.LOG, 'MO: Operating Unit=' || l_org_id);
  --Moac Changes. Commented the profile value. End.

  --Moac Changes. Initilize set the Policy. Start

   MO_GLOBAL.INIT('IEX');
   IF P_ORG_ID IS NOT NULL THEN
    MO_GLOBAL.SET_POLICY_CONTEXT('S',P_ORG_ID);  -- Single Org.
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'MO: Operating Unit=' || p_org_id);
   ELSE
    MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);      -- Multi Org.
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'MO: Operating Unit=' || 'All');
   END IF;

  --Moac Changes. Initilize,set the Policy. End.


  IF G_METRIC_BATCH = 'BATCH' THEN
   -- Begin fix bug #4941239-jypark-delete records only of current operating unit

   -- Moac Changes . Delete from synonym iex_metric_summaries. Start.
   -- DELETE FROM iex_metric_summaries_all;
   -- DELETE FROM iex_metric_summaries;
   -- Moac Changes . Delete from synonym iex_metric_summaries. End.

    l_del_sql := l_del_sql || ' WHERE rownum >= 0 and rownum < ' || l_batch_size;

    OPEN c_total_cnt;
    FETCH c_total_cnt INTO l_total_cnt;
    CLOSE c_total_cnt;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Purging old metric records(' || l_total_cnt || ')');
    i := 0;

    LOOP
       EXECUTE IMMEDIATE l_del_sql;
       COMMIT;

       i := i + l_batch_size;
    EXIT WHEN i > l_total_cnt;
    END LOOP;

    EXECUTE IMMEDIATE l_del_sql;
    COMMIT;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Purge complete>>>>>');
    -- End fix bug #5009901-JYPARK-delete records by batch size for performance


--Begin Bug 7477844 24-Dec-2008 barathsr
    OPEN c_comp_count('PARTY');
    fetch c_comp_count into l_obj_count;
    close c_comp_count;
    if  l_obj_count > 0 then
--End Bug 7477844 24-Dec-2008 barathsr
    FOR I_ORG IN C_ORG LOOP   -- Moac Changes. Loop through for Party.
    MO_GLOBAL.SET_POLICY_CONTEXT('S',I_ORG.organization_id); -- Moac Changes. Set Org.
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside Party Loop, Operating Unit Set =' ||I_ORG.organization_id);

    i := 0;
    FOR r_party IN c_party LOOP
      i := i + 1;
      l_party_id_tbl(i) := r_party.party_id;
    END LOOP;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total Party Count=' || i);

    FOR idx1 IN l_party_id_tbl.FIRST..l_party_id_tbl.LAST LOOP

      iex_metric_pvt.get_metric_info(p_api_version         => 1.0,
                                    p_init_msg_list        => FND_API.G_TRUE,
                                    p_commit               => FND_API.G_TRUE,
                                    p_validation_level     => 100,
                                    x_return_status        => l_return_status,
                                    x_msg_count            => l_msg_count,
                                    x_msg_data             => l_msg_data,
                                    p_party_id             => l_party_id_tbl(idx1),
                                    p_cust_account_id      => TO_NUMBER(''),
                                    p_customer_site_use_id => TO_NUMBER(''),
                                    p_delinquency_id       => TO_NUMBER(''),
                                    x_metric_id_tbl        => l_metric_id_tbl,
                                    p_filter_by_object     => 'PARTY',
                                    x_metric_name_tbl      => l_metric_name_tbl,
                                    x_metric_value_tbl     => l_metric_value_tbl,
                                    x_metric_rating_tbl    => l_metric_rating_tbl);

      IF l_metric_id_tbl.count > 0 THEN

        FORALL idx2 IN l_metric_name_tbl.FIRST..l_metric_name_tbl.LAST
          INSERT INTO iex_metric_summaries_all
	  (object_id, object_type, org_id, score_comp_type_id, metric_value,
	  creation_date, created_by, last_update_date, last_updated_by,
	  last_update_login, metric_rating)
          VALUES(l_party_id_tbl(idx1), 'PARTY',
	  --l_org_id, Moac Changes. Insert the Org_id from current set.
	  I_ORG.organization_id,
	  l_metric_id_tbl(idx2), l_metric_value_tbl(idx2), SYSDATE, G_USER_ID,
	  SYSDATE, G_USER_ID, G_LOGIN_ID, l_metric_rating_tbl(idx2));

        COMMIT;
      END IF;

     END LOOP;
    END LOOP; -- Moac Changes. Org Loop.
      end if; --Added for Bug 7477844 24-Dec-2008 barathsr



     --Moac Changes. Re-Initialize after the Party Loop is complete. Start.
    IF P_ORG_ID IS NOT NULL THEN
      MO_GLOBAL.SET_POLICY_CONTEXT('S',P_ORG_ID);  -- Single Org.
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Reset after party loop, Operating Unit=' || p_org_id);
    ELSE
      MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);      -- Multi Org.
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Reset after party loop, Operating Unit=' || 'All');
    END IF;
    --Moac Changes. Re-Initialize after the Party Loop is complete. Start.

   --Begin Bug 7477844 24-Dec-2008 barathsr
   OPEN c_comp_count('IEX_ACCOUNT');
     fetch c_comp_count into l_obj_count;
    close c_comp_count;
    if  l_obj_count > 0 then
    --End Bug 7477844 24-Dec-2008 barathsr
        FOR I_ORG IN C_ORG LOOP   -- Moac Changes. Loop through for Party.
     MO_GLOBAL.SET_POLICY_CONTEXT('S',I_ORG.organization_id); -- Moac Changes. Set Org.
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside Account Loop, Operating Unit Set =' ||I_ORG.organization_id);
     i := 0;
     l_party_id_tbl.DELETE;

     FOR r_account IN c_account LOOP
       i := i + 1;
       l_cust_account_id_tbl(i) := r_account.cust_account_id;
       l_party_id_tbl(i) := r_account.party_id;
     END LOOP;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total Account Count=' || i);

    FOR idx1 IN l_cust_account_id_tbl.FIRST..l_cust_account_id_tbl.LAST LOOP

      iex_metric_pvt.get_metric_info(p_api_version          => 1.0,
                                    p_init_msg_list         => FND_API.G_TRUE,
                                    p_commit                => FND_API.G_TRUE,
                                    p_validation_level      => 100,
                                    x_return_status         => l_return_status,
                                    x_msg_count             => l_msg_count,
                                    x_msg_data              => l_msg_data,
                                    p_party_id              => l_party_id_tbl(idx1),
                                    p_cust_account_id       => l_cust_account_id_tbl(idx1),
                                    p_customer_site_use_id  => '',
                                    p_delinquency_id        => '',
                                    p_filter_by_object      => 'IEX_ACCOUNT',
                                    x_metric_id_tbl         => l_metric_id_tbl,
                                    x_metric_name_tbl       => l_metric_name_tbl,
                                    x_metric_value_tbl      => l_metric_value_tbl,
                                    x_metric_rating_tbl     => l_metric_rating_tbl);

      IF l_metric_id_tbl.count > 0 THEN
        FORALL idx2 IN l_metric_name_tbl.FIRST..l_metric_name_tbl.LAST
          INSERT INTO iex_metric_summaries_all(object_id, object_type,
	  org_id, score_comp_type_id, metric_value, creation_date,
	  created_by, last_update_date, last_updated_by,
	  last_update_login, metric_rating)
          VALUES(l_cust_account_id_tbl(idx1), 'ACCOUNT',
	  --l_org_id, Moac Changes. Insert Org_id from current set.
	  I_ORG.organization_id,
	  l_metric_id_tbl(idx2),
	  l_metric_value_tbl(idx2), SYSDATE, G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID,
	  l_metric_rating_tbl(idx2));

        COMMIT;
      END IF;

     END LOOP;

    END LOOP; --Moac Change. Org Loop.
    end if; --Added for Bug 7477844 24-Dec-2008 barathsr

  --Moac Changes. Re-Initilize,set the Policy. Start
  IF P_ORG_ID IS NOT NULL THEN
    MO_GLOBAL.SET_POLICY_CONTEXT('S',P_ORG_ID);  -- Single Org.
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Reset after Account loop, Operating Unit=' || p_org_id);
  ELSE
    MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);      -- Multi Org.
  END IF;
  --Moac Changes. Initilize, set the Policy. End.
   --Begin Bug 7477844 24-Dec-2008 barathsr
    OPEN c_comp_count('IEX_BILLTO');
    fetch c_comp_count into l_obj_count;
    close c_comp_count;
  if  l_obj_count > 0 then
  --End Bug 7477844 24-Dec-2008 barathsr
    i := 0 ;
    l_cust_account_id_tbl.DELETE;
    l_party_id_tbl.DELETE;

    FOR r_billto IN c_billto LOOP
      i := i + 1;
      l_site_use_id_tbl(i) := r_billto.site_use_id;
      l_org_id_tbl(i) := r_billto.org_id;

      -- Begin bug#7304169 snuthala 04-Aug-2008
      l_cust_account_id_tbl(i) := r_billto.cust_account_id;
      l_party_id_tbl(i) := r_billto.party_id;
      -- End bug#7304169 snuthala 04-Aug-2008
    END LOOP;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total BillTo Count=' || i);

    FOR idx1 IN l_site_use_id_tbl.FIRST..l_site_use_id_tbl.LAST LOOP

      iex_metric_pvt.get_metric_info(p_api_version           => 1.0,
                                    p_init_msg_list          => FND_API.G_TRUE,
                                    p_commit                 => FND_API.G_TRUE,
                                    p_validation_level       => 100,
                                    x_return_status          => l_return_status,
                                    x_msg_count              => l_msg_count,
                                    x_msg_data               => l_msg_data,
                                    p_party_id      => l_party_id_tbl(idx1),
                                    p_cust_account_id => l_cust_account_id_tbl(idx1),
                                    p_customer_site_use_id => l_site_use_id_tbl(idx1),
                                    p_delinquency_id         => '',
                                    p_filter_by_object       => 'IEX_BILLTO',
                                    x_metric_id_tbl          => l_metric_id_tbl,
                                    x_metric_name_tbl        => l_metric_name_tbl,
                                    x_metric_value_tbl       => l_metric_value_tbl,
                                    x_metric_rating_tbl      => l_metric_rating_tbl);

      IF l_metric_id_tbl.count > 0 THEN
        FORALL idx2 IN l_metric_name_tbl.FIRST..l_metric_name_tbl.LAST
          INSERT INTO iex_metric_summaries_all(object_id, object_type, org_id,
	  score_comp_type_id, metric_value, creation_date, created_by, last_update_date,
	  last_updated_by,last_update_login, metric_rating)
          VALUES(l_site_use_id_tbl(idx1), 'BILL_TO',
	  --l_org_id,  Moac Changes. Insert Org_id from cursor.
	  l_org_id_tbl(idx1),
	  l_metric_id_tbl(idx2), l_metric_value_tbl(idx2), SYSDATE,
	  G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID, l_metric_rating_tbl(idx2));

        COMMIT;
     END IF;

    END LOOP;
    end if; --Added for Bug 7477844 24-Dec-2008 barathsr

    --Begin Bug 7477844 24-Dec-2008 barathsr
    OPEN c_comp_count('IEX_DELINQUENCY');
    fetch c_comp_count into l_obj_count;
    close c_comp_count;
    if  l_obj_count > 0 then
     --End Bug 7477844 24-Dec-2008 barathsr
    i := 0;
    l_site_use_id_tbl.DELETE;
    l_cust_account_id_tbl.DELETE;
    l_party_id_tbl.DELETE;

    FOR r_del IN c_del LOOP
      i := i + 1;
      l_delinquency_id_tbl(i) := r_del.delinquency_id;
      l_site_use_id_tbl(i) := r_del.customer_site_use_id;
      l_cust_account_id_tbl(i) := r_del.cust_account_id;
      l_party_id_tbl(i) := r_del.party_cust_id;
      l_org_id_tbl(i) := r_del.org_id;

    END LOOP;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total Delinquency Count=' || i);

    FOR idx1 IN l_delinquency_id_tbl.FIRST..l_delinquency_id_tbl.LAST LOOP

      iex_metric_pvt.get_metric_info(p_api_version          => 1.0,
                                    p_init_msg_list         => FND_API.G_TRUE,
                                    p_commit                => FND_API.G_TRUE,
                                    p_validation_level      => 100,
                                    x_return_status         => l_return_status,
                                    x_msg_count             => l_msg_count,
                                    x_msg_data              => l_msg_data,
                                    p_party_id      => l_party_id_tbl(idx1),
                                    p_cust_account_id => l_cust_account_id_tbl(idx1),
                                    p_customer_site_use_id => l_site_use_id_tbl(idx1),
                                    p_delinquency_id => l_delinquency_id_tbl(idx1),
                                    p_filter_by_object      => 'IEX_DELINQUENCY',
                                    x_metric_id_tbl         => l_metric_id_tbl,
                                    x_metric_name_tbl       => l_metric_name_tbl,
                                    x_metric_value_tbl      => l_metric_value_tbl,
                                    x_metric_rating_tbl     => l_metric_rating_tbl);



      IF l_metric_id_tbl.count > 0 THEN
        FORALL idx2 IN l_metric_name_tbl.FIRST..l_metric_name_tbl.LAST
          INSERT INTO iex_metric_summaries_all(object_id, object_type, org_id,
	  score_comp_type_id, metric_value, creation_date, created_by,
	  last_update_date, last_updated_by, last_update_login, metric_rating)
          VALUES(l_delinquency_id_tbl(idx1), 'DELINQUENCY',
	  --l_org_id, Moac Changes. Insert Org_id from cursor.
	  l_org_id_tbl(idx1),
	  l_metric_id_tbl(idx2), l_metric_value_tbl(idx2), SYSDATE,
	  G_USER_ID, SYSDATE, G_USER_ID, G_LOGIN_ID, l_metric_rating_tbl(idx2));

        COMMIT;
      END IF;

    END LOOP;
    end if;  --Added for Bug 7477844 24-Dec-2008 barathsr


  END IF;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.logMessage('Metric_Concur: ' || 'IEX_METRIC: metricConcur: End time:'|| TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
  END IF;
/*
Exception
  WHEN FND_API.G_EXC_ERROR THEN
    RETCODE := -1;
    ERRBUF := l_msg_data;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.logMessage('IEX_METRIC: metricConcur: Expected Error ' || sqlerrm);
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR: '  || sqlerrm);

  WHEN OTHERS THEN
    RETCODE := -1;
    ERRBUF := l_msg_data;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.logMessage('IEX_METRIC: metricConcur: Unexpected Error ' || sqlerrm);
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR IN CONCUR: ' || sqlerrm);
*/
Exception
  WHEN OTHERS THEN
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR : '  || sqlerrm);
END Refresh_All;
BEGIN
  G_LOGIN_ID  := FND_GLOBAL.Conc_Login_Id;
  G_USER_ID  := FND_GLOBAL.User_Id;
  PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_METRIC_BATCH := NVL(fnd_profile.value('IEX_METRIC_ALLOW_BATCH'), 'REALTIME');
END IEX_METRIC_CONCUR_PVT;

/
