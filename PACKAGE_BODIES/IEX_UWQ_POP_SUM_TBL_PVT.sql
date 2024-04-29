--------------------------------------------------------
--  DDL for Package Body IEX_UWQ_POP_SUM_TBL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_UWQ_POP_SUM_TBL_PVT" AS
/* $Header: iexvuwpb.pls 120.3.12010000.25 2010/05/27 16:33:13 barathsr ship $ */

g_pkg_name constant VARCHAR2(30) := 'IEX_UWQ_POP_SUM_TBL_PVT';
g_file_name constant VARCHAR2(12) := 'iexvuwpb.pls';
G_LOG_ENABLED                   varchar2(5);
G_MSG_LEVEL                     NUMBER;
G_Batch_Size NUMBER := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '100000'));
--Begin Bug 8707923  27-Jul-2009 barathsr
G_SYSTEM_LEVEL varchar2(100);
G_PARTY_LVL_ENB varchar2(1);
G_OU_LVL_ENB varchar2(1);
G_LEVEL_COUNT number:=0;
--End Bug 8707923  27-Jul-2009 barathsr

/*deadlock_detected EXCEPTION;
PRAGMA EXCEPTION_INIT(deadlock_detected, -60);*/

TYPE number_list is TABLE of NUMBER INDEX BY BINARY_INTEGER;
TYPE varchar_10_list is TABLE of VARCHAR2(10) INDEX BY BINARY_INTEGER;
TYPE varchar_20_list is TABLE of VARCHAR2(20) INDEX BY BINARY_INTEGER;
TYPE varchar_30_list is TABLE of VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE varchar_40_list is TABLE of VARCHAR2(40) INDEX BY BINARY_INTEGER;
TYPE varchar_60_list is TABLE of VARCHAR2(60) INDEX BY BINARY_INTEGER;
TYPE varchar_80_list is TABLE of VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE varchar_240_list is TABLE of VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE varchar_360_list is TABLE of VARCHAR2(360) INDEX BY BINARY_INTEGER;
TYPE varchar_2020_list is TABLE of VARCHAR2(2020) INDEX BY BINARY_INTEGER;
TYPE date_list is TABLE of DATE INDEX BY BINARY_INTEGER;
PROCEDURE populate_aging_info(p_fmode varchar2, p_from_date date,p_org_id number); -- Added for bug#7662453
PROCEDURE populate_contracts_info; -- Added for bug#8261043
PROCEDURE insert_conc_req IS
BEGIN
   DELETE from AR_CONC_PROCESS_REQUESTS
    where CONCURRENT_PROGRAM_NAME = 'IEX_POPULATE_UWQ_SUM';

   INSERT INTO AR_CONC_PROCESS_REQUESTS
     (CONCURRENT_PROGRAM_NAME, REQUEST_ID)
     values ('IEX_POPULATE_UWQ_SUM',FND_GLOBAL.conc_request_id);
   COMMIT;
END insert_conc_req;


Procedure LogMessage(p_msg_level IN NUMBER, p_msg in varchar2)
IS
BEGIN
      if (p_msg_level >= G_MSG_LEVEL) then

          FND_LOG.STRING(p_msg_level, G_PKG_NAME, p_msg);
          if FND_GLOBAL.Conc_Request_Id is not null then
              fnd_file.put_line(FND_FILE.LOG, p_msg);
          end if;

      end if;

EXCEPTION
      WHEN OTHERS THEN
          LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END LogMessage;


--Begin Bug 9597052 28-Apr-2010 barathsr
--Created a new concurrent program IEX: Update AR Transactions Summary Table to call this procedure
--Removed all the calls to this procedure in this package
--This concurrent program should be run everytime before running IEX: Populate Uwq Summary table cp
--Begin Bug 8707932 27-Jul-2009 barathsr
--Moved the update of ar_trx_bal_summ from insert_summary as a separate procedure.
--This procedure gets executed everytime the cp is run.
procedure update_trx_bal_summ_concur( x_errbuf            OUT nocopy VARCHAR2,
                                      x_retcode           OUT nocopy VARCHAR2)

                                    /* (p_mode in varchar2 default 'CP',
                                      p_org_id in number)*/
 is
     --Begin bug#7133605 schekuri 09-Jun-2008
     --Start bug 6876187 gnramasa 14th mar 08
     CURSOR c_cust_account_id_1 IS
     SELECT DISTINCT CUST_ACCOUNT_ID FROM AR_TRX_BAL_SUMMARY ARS
     WHERE ARS.REFERENCE_1 IS Null
     AND EXISTS (SELECT 1 FROM IEX_DELINQUENCIES_ALL IED WHERE
                  IED.STATUS IN ('DELINQUENT', 'PREDELINQUENT')
                  AND ARS.CUST_ACCOUNT_ID = IED.CUST_ACCOUNT_ID);
		--  and ied.org_id=nvl(p_org_id,ied.org_id));

    CURSOR c_cust_account_id_n IS
     SELECT DISTINCT CUST_ACCOUNT_ID FROM AR_TRX_BAL_SUMMARY ARS
     WHERE ARS.REFERENCE_1 = 1
     AND  NOT EXISTS (SELECT 1 FROM IEX_DELINQUENCIES_ALL IED WHERE
                 IED.STATUS IN ('DELINQUENT', 'PREDELINQUENT')
                 AND ARS.CUST_ACCOUNT_ID = IED.CUST_ACCOUNT_ID);
		-- and ied.org_id=nvl(p_org_id,ied.org_id));

    TYPE cust_account_id_list_1    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE cust_account_id_list_n    is TABLE of NUMBER INDEX BY BINARY_INTEGER;

    l_cust_account_id_1 cust_account_id_list_1;
    l_cust_account_id_n cust_account_id_list_n;

     --End bug 6876187 gnramasa 14th mar 08

     CURSOR c_cust_account_id_dln(p_cust_account_id number) IS
     SELECT CUST_ACCOUNT_ID FROM AR_TRX_BAL_SUMMARY ARS
     WHERE ARS.REFERENCE_1 = 1
     AND ARS.CUST_ACCOUNT_ID=P_CUST_ACCOUNT_ID
     AND  NOT EXISTS (SELECT 1 FROM IEX_DELINQUENCIES_ALL IED WHERE
                 IED.STATUS IN ('DELINQUENT', 'PREDELINQUENT')
                 AND ARS.CUST_ACCOUNT_ID = IED.CUST_ACCOUNT_ID)
 	   --      and ied.org_id=nvl(p_org_id,ied.org_id))
		 for update of reference_1 nowait;

     l_cust_account_id_dln cust_account_id_list_n;

     CURSOR C_CUST_ACCOUNT_ID_DL1(p_cust_account_id number) IS
     SELECT CUST_ACCOUNT_ID FROM AR_TRX_BAL_SUMMARY ARS
     WHERE ARS.REFERENCE_1 IS Null
     AND ARS.CUST_ACCOUNT_ID=P_CUST_ACCOUNT_ID
 --   and ars.org_id=nvl(p_org_id,ars.org_id)
     for update of reference_1 nowait;
     TYPE cust_account_id_list_dl1    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
     l_cust_account_id_dl1 cust_account_id_list_n;
     l_cust_account_id1 number;
     --End bug#7133605 schekuri 09-Jun-200

 begin
     /* Begin Kasreeni 3/1/2007 Bug 5905023  We will update everytime instead of once */
 --   if (p_mode = 'CP') then
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Updating Reference_1 of AR_TRX_BAL_SUMMARY for Delinquent Customers');
      --Start bug 6876187 gnramasa 14th mar 08
      --update ar_trx_bal_summary set reference_1 = 1;
      --Begin bug#7133605 schekuri 09-Jun-2008
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Starting to update ar_trx_bal_summary with reference_1 = 1...');
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Starting to update ar_trx_bal_summary with reference_1 = 1...');
      BEGIN
	OPEN c_cust_account_id_1;
	 LOOP
	  FETCH c_cust_account_id_1 BULK COLLECT INTO
	    l_cust_account_id_1 LIMIT G_BATCH_SIZE;
	  IF l_cust_account_id_1.count =  0 THEN

               IEX_DEBUG_PUB.LOGMESSAGE('Exit after Updating ar_trx_bal_summary with reference_1 = 1...');

	    CLOSE c_cust_account_id_1;
	    EXIT;
          ELSE
	   FORALL I IN l_cust_account_id_1.first..l_cust_account_id_1.last
	    UPDATE AR_TRX_BAL_SUMMARY ARS
            SET REFERENCE_1 = '1'
            WHERE CUST_ACCOUNT_ID = l_cust_account_id_1(I)
	    and reference_1 is null;
	    l_cust_account_id_1.delete;

	    commit;

            IEX_DEBUG_PUB.LOGMESSAGE(SQL%ROWCOUNT || ' Rows updated in ar_trx_bal_summary with reference_1 = 1');
	     FND_FILE.PUT_LINE(FND_FILE.LOG, ' Rows updated in ar_trx_bal_summary with reference_1 = 1-->'||l_cust_account_id_1.count);

	   END IF;
	 END LOOP;
        EXCEPTION

	WHEN deadlock_detected THEN
	     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deadlock detected when updating ar_trx_bal_summary.reference to 1' || sqlerrm);
	     LogMessage(FND_LOG.LEVEL_STATEMENT,' Deadlock detected when updating ar_trx_bal_summary.reference to 1.');
	     ROLLBACK;
	     l_cust_account_id_1.delete;
	     if c_cust_account_id_1%ISOPEN then
		close c_cust_account_id_1;
	     end if;
	     OPEN c_cust_account_id_1;
	     LOOP
		FETCH c_cust_account_id_1 BULK COLLECT INTO
		l_cust_account_id_1 LIMIT G_BATCH_SIZE;
		IF l_cust_account_id_1.count =  0 THEN
			IEX_DEBUG_PUB.LOGMESSAGE('Exit after Updating ar_trx_bal_summary with reference_1 = 1 in Deadlock handler');
			CLOSE c_cust_account_id_1;
			EXIT;
	        ELSE
		FOR i IN l_cust_account_id_1.first..l_cust_account_id_1.last
		LOOP
		   BEGIN
			OPEN C_CUST_ACCOUNT_ID_DL1(l_cust_account_id_1(i));
				FETCH C_CUST_ACCOUNT_ID_DL1 into l_cust_account_id1;
				EXIT WHEN C_CUST_ACCOUNT_ID_DL1%NOTFOUND;
				UPDATE AR_TRX_BAL_SUMMARY
		                SET REFERENCE_1 = '1'
				WHERE cust_account_id=l_cust_account_id1
				and REFERENCE_1 is null;
				FND_FILE.PUT_LINE(FND_FILE.LOG,'updated records- '||l_cust_account_id_1.count);

			CLOSE C_CUST_ACCOUNT_ID_DL1;
		   EXCEPTION
		   WHEN LOCKED_BY_ANOTHER_SESSION THEN
			   LogMessage(FND_LOG.LEVEL_STATEMENT,'Records corresponding to account id '||l_cust_account_id_1(i)|| ' are locked by another session');
			   if C_CUST_ACCOUNT_ID_DL1%ISOPEN THEN
				CLOSE C_CUST_ACCOUNT_ID_DL1;
			   END IF;
		   WHEN OTHERS THEN
			   LogMessage(FND_LOG.LEVEL_STATEMENT,'Error while updating reference_1 to 1 in Dead lock handler '||sqlerrm);
			   IF C_CUST_ACCOUNT_ID_DL1%ISOPEN THEN
				CLOSE C_CUST_ACCOUNT_ID_DL1;
			   END IF;
		   END;

	     END LOOP;

             IEX_DEBUG_PUB.LOGMESSAGE(l_cust_account_id_1.count || ' rows updated in ar_trx_bal_summary with reference_1 = 1');
	     l_cust_account_id_1.delete;
	     commit;

	   END IF;
	 END LOOP;
	WHEN locked_by_another_session THEN
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Locked by another session when updating ar_trx_bal_summary.reference to 1');
	if c_cust_account_id_1%ISOPEN then
		close c_cust_account_id_1;
	     end if;
	ROLLBACK;

	WHEN OTHERS THEN
           IEX_DEBUG_PUB.LOGMESSAGE(SQLERRM || ' Error while updating ar_trx_bal_summary with reference_1 = 1');
	END;

        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Starting to update ar_trx_bal_summary with reference_1 = Null...');
	BEGIN
	OPEN c_cust_account_id_n;
	 LOOP
	  FETCH c_cust_account_id_n BULK COLLECT INTO
	    l_cust_account_id_n LIMIT G_BATCH_SIZE;
	  IF l_cust_account_id_n.count =  0 THEN
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Exit after Update ar_trx_bal_summary on complete with reference_1 = Null...');
	  --   FND_FILE.PUT_LINE(FND_FILE.LOG,SQL%ROWCOUNT || ' Rows updated in ar_trx_bal_summary with reference_1 = Null');
	    CLOSE c_cust_account_id_n;
	    EXIT;
          ELSE
	   FORALL I IN l_cust_account_id_n.first..l_cust_account_id_n.last
	    UPDATE AR_TRX_BAL_SUMMARY ARS
            SET REFERENCE_1 = Null
            WHERE CUST_ACCOUNT_ID = l_cust_account_id_n(I)
	     and reference_1='1';
	     l_cust_account_id_n.delete;
             commit;
	     FND_FILE.PUT_LINE(FND_FILE.LOG,' Rows updated in ar_trx_bal_summary with reference_1 = Null->'||l_cust_account_id_n.count);
             LogMessage(FND_LOG.LEVEL_UNEXPECTED,l_cust_account_id_n.count ||  'Rows updated in ar_trx_bal_summary with reference_1 = Null');
	   END IF;
	 END LOOP;
        EXCEPTION
	WHEN deadlock_detected THEN
	     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Deadlock detected when updating ar_trx_bal_summary.reference to null' || sqlerrm);
	     LogMessage(FND_LOG.LEVEL_STATEMENT,' Deadlock detected when updating ar_trx_bal_summary.reference to null.');
	     ROLLBACK;
	     l_cust_account_id_n.delete;
	     if c_cust_account_id_n%ISOPEN then
		close c_cust_account_id_n;
	     end if;
	     OPEN c_cust_account_id_n;
	     LOOP
		FETCH c_cust_account_id_n BULK COLLECT INTO
		l_cust_account_id_n LIMIT G_BATCH_SIZE;
		IF l_cust_account_id_n.count =  0 THEN
			IEX_DEBUG_PUB.LOGMESSAGE('Exit after Updating ar_trx_bal_summary with reference_1 = null in Deadlock handler');
			CLOSE c_cust_account_id_n;
			EXIT;
	        ELSE
		FOR i IN l_cust_account_id_n.first..l_cust_account_id_n.last
		LOOP
		   BEGIN
			OPEN C_CUST_ACCOUNT_ID_DLN(l_cust_account_id_n(i));
				FETCH C_CUST_ACCOUNT_ID_DLN into l_cust_account_id1;
				EXIT WHEN C_CUST_ACCOUNT_ID_DLN%NOTFOUND;
				UPDATE AR_TRX_BAL_SUMMARY
		                SET REFERENCE_1 = null
				WHERE cust_account_id=l_cust_account_id1
				and REFERENCE_1 = '1';
				FND_FILE.PUT_LINE(FND_FILE.LOG,'updated records '||sql%rowcount);

			CLOSE C_CUST_ACCOUNT_ID_DLN;
		   EXCEPTION
		   WHEN LOCKED_BY_ANOTHER_SESSION THEN
			   LogMessage(FND_LOG.LEVEL_STATEMENT,'Records corresponding to account id '||l_cust_account_id_n(i)|| ' are locked by another session');
			   if C_CUST_ACCOUNT_ID_DLN%ISOPEN THEN
				CLOSE C_CUST_ACCOUNT_ID_DLN;
			   END IF;
		   WHEN OTHERS THEN
			   LogMessage(FND_LOG.LEVEL_STATEMENT,'Error while updating reference_1 to 1 in Dead lock handler '||sqlerrm);
			   IF C_CUST_ACCOUNT_ID_DLN%ISOPEN THEN
				CLOSE C_CUST_ACCOUNT_ID_DLN;
			   END IF;
		   END;

	     END LOOP;

             IEX_DEBUG_PUB.LOGMESSAGE(l_cust_account_id_1.count || ' rows updated in ar_trx_bal_summary with reference_1 = 1');
	     l_cust_account_id_1.delete;
	     commit;

	   END IF;
	 END LOOP;
        WHEN locked_by_another_session THEN
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Locked by another session when updating ar_trx_bal_summary.reference to 1');
	if c_cust_account_id_1%ISOPEN then
		close c_cust_account_id_1;
	 end if;
	ROLLBACK;
	WHEN OTHERS THEN
           LogMessage(FND_LOG.LEVEL_UNEXPECTED,SQLERRM || ' Error while updating ar_trx_bal_summary with reference_1 = Null');
	END;

     --End bug 6876187 gnramasa 14th mar 08
     --End bug#7133605 schekuri 09-Jun-2008

      /*update ar_trx_bal_summary set reference_1 = '1'
      where cust_account_id in
        ( select distinct cust_account_id
        from iex_delinquencies_all
        where status in ('DELINQUENT','PREDELINQUENT'));*/
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Done updating Reference_1 of AR_TRX_BAL_SUMMARY ');

  --  end if;
    /* End Kasreeni 3/1/2007 Bug 5905023  We will update everytime instead of once */
  end update_trx_bal_summ_concur;
  --End Bug 8707932 27-Jul-2009 barathsr
  --End Bug 9597052 28-Apr-2010 barathsr


  --Begin Bug 8707932 27-Jul-2009 barathsr
  --Moved delete/truncate from dln_uwq_summary from insert_summary procedure into a separate procedure.
  --This procedure gets executed when from_date is null/not null
  --when from_date not null the corresponding records are deleted and repopulated if there are any updates after the date passed as parameter.
  Procedure delete_rows_from_uwq_summ(from_date in varchar2,
                                      p_org_id in number,
				      p_truncate_table in varchar2
				      )
    is

    CURSOR c_get_table IS
    select OWNER || '.' || TABLE_NAME from sys.all_tables where table_name = 'IEX_DLN_UWQ_SUMMARY';

    CURSOR c_org(c_org_id number) IS
    SELECT organization_id from hr_operating_units where
      mo_global.check_access(organization_id) = 'Y'
      AND organization_id = nvl(c_org_id,organization_id);

 --Begin Bug 8942646 12-Oct-2009 barathsr
      CURSOR c_get_level IS
    SELECT PREFERENCE_VALUE
    FROM IEX_APP_PREFERENCES_B
    WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL'
    and enabled_flag='Y'
    and org_id is null;

    CURSOR c_allowed_levels IS
     SELECT LOOKUP_CODE
     FROM IEX_LOOKUPS_V
     WHERE LOOKUP_TYPE='IEX_RUNNING_LEVEL'
     AND iex_utilities.validate_running_level(LOOKUP_CODE)='Y';

   cursor c_get_ou_biz_lvl(c_org_id number) is
   SELECT PREFERENCE_VALUE
   FROM IEX_APP_PREFERENCES_B
   WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL'
   and (org_id=c_org_id or org_id is null)
   and enabled_flag='Y'
   order by nvl(org_id,0) desc ;

   --End Bug 8942646 12-Oct-2009 barathsr



    l_truncate_table                            VARCHAR2(60);
    l_org_id number;
    l_cnt number;
    l_cnt1 number;
    l_allowed_lvl varchar2(20);
   l_curr_org_id number;
   l_from_date date;
    begin
    --if (l_from_date is null and p_mode = 'CP' and G_LEVEL_COUNT=0 ) then --Bug5691098
   --   LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Fully repopulating IEX_DLN_UWQ_SUMMARY table...');

  /* if p_org_id is null and G_OU_LVL_ENB='Y' then
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Missing Org_id value to set the multi level strategy at OU..Please pass the org_id value' );
       LogMessage(FND_LOG.LEVEL_STATEMENT, 'Missing Org_id value to set the multi level strategy at OU..Please pass the org_id value');
       return;
   end if;*/--will be handled in parameter window

   --Begin Bug 8942646 12-Oct-2009 barathsr
   --Handling when from_date not null also in this proc

   l_from_date := to_date(substr(FROM_DATE, 1, 10), 'YYYY/MM/DD');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Input FROM_DATE = ' || l_from_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Input FROM_DATE = ' || l_from_date);


   if (G_OU_LVL_ENB='Y' or G_PARTY_LVL_ENB='Y') then
        if G_OU_LVL_ENB='Y' then
	   mo_global.init('IEX');
                if p_org_id is null then
		     MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);      -- Multi Org.
		     FND_FILE.PUT_LINE(FND_FILE.LOG, 'MO: Operating Unit=' || 'All');
		     --open c_org(l_org_id);
		else
		   MO_GLOBAL.SET_POLICY_CONTEXT('S',p_ORG_ID);
		end if;

	        for i in c_org(p_org_id) loop
		l_curr_org_id:=i.organization_id;
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'org_id is-->'||l_curr_org_id);
		 if (l_from_date is null and p_truncate_table='Y') then
		      OPEN c_get_table;
		      FETCH c_get_table INTO l_truncate_table;
		      CLOSE c_get_table;
		      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'truncate table ' || l_truncate_table);
		      EXECUTE IMMEDIATE 'truncate table ' || l_truncate_table;
		      LogMessage(FND_LOG.LEVEL_STATEMENT,'Truncated whole table');
		 elsif l_from_date is null then
		    delete from iex_dln_uwq_summary
		    where org_id=l_curr_org_id;
		 elsif l_from_date is not null then

	       FND_FILE.PUT_LINE(FND_FILE.LOG,'records deleted for org_id-'||l_curr_org_id);

		    open c_get_ou_biz_lvl(l_curr_org_id);
		    fetch c_get_ou_biz_lvl into G_SYSTEM_LEVEL;
		    close c_get_ou_biz_lvl;
		     FND_FILE.PUT_LINE(FND_FILE.LOG, 'OU lvl is-->'||G_SYSTEM_LEVEL);

	         for r_allowed_levels in c_allowed_levels loop
	           l_allowed_lvl:=r_allowed_LEVELS.lookup_code;
	           FND_FILE.PUT_LINE(FND_FILE.LOG,'looping for other levels in ou-->'||r_allowed_LEVELS.lookup_code);
	            if (g_party_lvl_enb='N' and l_allowed_lvl=g_system_level) or g_party_lvl_enb='Y' then
			IF l_allowed_lvl = 'CUSTOMER' THEN
                            FND_FILE.PUT_LINE(FND_FILE.LOG,'Deleting records at Customer level--in OU');
			   delete from IEX_DLN_UWQ_SUMMARY where (party_id,org_id) in
			  (select hza.party_id,trb.org_id from ar_trx_bal_summary trb, hz_cust_accounts hza
			  where hza.cust_account_id = trb.cust_account_id and  trunc(trb.LAST_UPDATE_DATE) >= trunc(l_from_date)
			  and trb.org_id=nvl(l_curr_org_id,trb.org_id))
			  and cust_account_id is null and site_use_id is null;--Added for Bug 8707923 27-Jul-2009 barathsr
			  FND_FILE.PUT_LINE(FND_FILE.LOG,'No. of records deleted at Cust level-->'||sql%rowcount);
			ELSIF l_allowed_lvl  = 'ACCOUNT' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,'Deleting records at Account level--in OU');
			  delete from IEX_DLN_UWQ_SUMMARY where (cust_account_id, org_id) in
			 (select cust_account_id, org_id from ar_trx_bal_summary trb where trunc(LAST_UPDATE_DATE) >= trunc(l_from_date)
			  and trb.org_id=nvl(l_curr_org_id,trb.org_id))
			  and site_use_id is null;--Added for Bug 8707923 27-Jul-2009 barathsr
			  FND_FILE.PUT_LINE(FND_FILE.LOG,'No. of records deleted at A/c level-->'||sql%rowcount);
			ELSIF l_allowed_lvl  = 'BILL_TO' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,'Deleting records at BillTo level--in OU');
			  delete from IEX_DLN_UWQ_SUMMARY where (cust_account_id, site_use_id, org_id) in
			 (select cust_account_id, site_use_id, org_id from ar_trx_bal_summary trb where trunc(LAST_UPDATE_DATE) >= trunc(l_from_date)
			  and trb.org_id=nvl(l_curr_org_id,trb.org_id))
			  and site_use_id is not null;--Added for Bug 8707923 27-Jul-2009 barathsr
			  FND_FILE.PUT_LINE(FND_FILE.LOG,'No. of records deleted at Billto level-->'||sql%rowcount);
			END IF;
	            end if;
	         end loop;
	       end if;
	     end loop;


       elsif G_PARTY_LVL_ENB='Y' then

	  if (l_from_date is null and p_truncate_table='Y') then
		      OPEN c_get_table;
		      FETCH c_get_table INTO l_truncate_table;
		      CLOSE c_get_table;
		      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'truncate table ' || l_truncate_table);
		      EXECUTE IMMEDIATE 'truncate table ' || l_truncate_table;
		      LogMessage(FND_LOG.LEVEL_STATEMENT,'Truncated whole table');
          elsif l_from_date is not null then
	      FND_FILE.PUT_LINE(FND_FILE.LOG,'inside party level');
                open c_get_level;
	        fetch c_get_level into G_SYSTEM_LEVEL;
		close c_get_level;
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'party lvl is-->'||G_SYSTEM_LEVEL);
		for r_allowed_levels in c_allowed_levels loop
		 l_allowed_lvl:=r_allowed_LEVELS.lookup_code;
		FND_FILE.PUT_LINE(FND_FILE.LOG,'looping for other levels in party-->'||r_allowed_LEVELS.lookup_code);
		 IF l_allowed_lvl = 'CUSTOMER' THEN
		 FND_FILE.PUT_LINE(FND_FILE.LOG,'Deleting records at Customer level--in party ');
                   delete from IEX_DLN_UWQ_SUMMARY where (party_id,org_id) in
                  (select hza.party_id,trb.org_id from ar_trx_bal_summary trb, hz_cust_accounts hza
                  where hza.cust_account_id = trb.cust_account_id and  trunc(trb.LAST_UPDATE_DATE) >= trunc(l_from_date))
		 -- and trb.org_id=nvl(l_curr_org_id,trb.org_id)
		  and cust_account_id is null and site_use_id is null;--Added for Bug 8707923 27-Jul-2009 barathsr
		   FND_FILE.PUT_LINE(FND_FILE.LOG,'No. of records deleted at Cust level-->'||sql%rowcount);
                ELSIF l_allowed_lvl  = 'ACCOUNT' THEN
		 FND_FILE.PUT_LINE(FND_FILE.LOG,'Deleting records at Account level--in party ');
                  delete from IEX_DLN_UWQ_SUMMARY where (cust_account_id, org_id) in
                 (select cust_account_id, org_id from ar_trx_bal_summary trb where trunc(LAST_UPDATE_DATE) >= trunc(l_from_date))
	         -- and trb.org_id=nvl(l_curr_org_id,trb.org_id)
		  and site_use_id is null;--Added for Bug 8707923 27-Jul-2009 barathsr
		   FND_FILE.PUT_LINE(FND_FILE.LOG,'No. of records deleted at A/C level-->'||sql%rowcount);
                ELSIF l_allowed_lvl  = 'BILL_TO' THEN
		 FND_FILE.PUT_LINE(FND_FILE.LOG,'Deleting records at BillTo level--in party ');
                  delete from IEX_DLN_UWQ_SUMMARY where (cust_account_id, site_use_id, org_id) in
                 (select cust_account_id, site_use_id, org_id from ar_trx_bal_summary trb where trunc(LAST_UPDATE_DATE) >= trunc(l_from_date))
	         -- and trb.org_id=nvl(l_curr_org_id,trb.org_id))
		  and site_use_id is not null;--Added for Bug 8707923 27-Jul-2009 barathsr
		   FND_FILE.PUT_LINE(FND_FILE.LOG,'No. of records deleted at Billto level-->'||sql%rowcount);
                END IF;
	       end loop;
          end if;
	end if;

   else

	   if (l_from_date is null and p_truncate_table='Y') then
		      OPEN c_get_table;
		      FETCH c_get_table INTO l_truncate_table;
		      CLOSE c_get_table;
		      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'truncate table ' || l_truncate_table);
		      EXECUTE IMMEDIATE 'truncate table ' || l_truncate_table;
		      LogMessage(FND_LOG.LEVEL_STATEMENT,'Truncated whole table');
           elsif l_from_date is not null then
	   open c_get_level;
	   fetch c_get_level into G_SYSTEM_LEVEL;
	   FND_FILE.PUT_LINE(FND_FILE.LOG,'inside system level-->'||G_SYSTEM_LEVEL);
	     if G_SYSTEM_LEVEL is not null then
	        IF g_system_level = 'CUSTOMER' THEN
		 FND_FILE.PUT_LINE(FND_FILE.LOG,'Deleting records at Customer level--in sys lvl ');
                   delete from IEX_DLN_UWQ_SUMMARY where (party_id,org_id) in
                  (select hza.party_id,trb.org_id from ar_trx_bal_summary trb, hz_cust_accounts hza
                  where hza.cust_account_id = trb.cust_account_id and  trunc(trb.LAST_UPDATE_DATE) >= trunc(l_from_date))
		 -- and trb.org_id=nvl(l_curr_org_id,trb.org_id)
		  and cust_account_id is null and site_use_id is null;--Added for Bug 8707923 27-Jul-2009 barathsr
                ELSIF g_system_level  = 'ACCOUNT' THEN
		FND_FILE.PUT_LINE(FND_FILE.LOG,'Deleting records at Account level--in sys lvl ');
                  delete from IEX_DLN_UWQ_SUMMARY where (cust_account_id, org_id) in
                 (select cust_account_id, org_id from ar_trx_bal_summary trb where trunc(LAST_UPDATE_DATE) >= trunc(l_from_date))
	         -- and trb.org_id=nvl(l_curr_org_id,trb.org_id)
		  and site_use_id is null;--Added for Bug 8707923 27-Jul-2009 barathsr
                ELSIF g_system_level  = 'BILL_TO' THEN
		FND_FILE.PUT_LINE(FND_FILE.LOG,'Deleting records at BillTo level--in sys lvl');
                  delete from IEX_DLN_UWQ_SUMMARY where (cust_account_id, site_use_id, org_id) in
                 (select cust_account_id, site_use_id, org_id from ar_trx_bal_summary trb where trunc(LAST_UPDATE_DATE) >= trunc(l_from_date))
	        --  and trb.org_id=nvl(l_curr_org_id,trb.org_id))
		and site_use_id is not null;--Added for Bug 8707923 27-Jul-2009 barathsr
                END IF;
	    end if;
	   close c_get_level;
	   end if;
  end if;
  --End Bug 8942646 12-Oct-2009 barathsr
    --Commented for Bug 8942646 12-Oct-2009 barathsr
   /*   if nvl(g_ou_lvl_enb,'N')='N' then
        if from_date is null then
          OPEN c_get_table;
	      FETCH c_get_table INTO l_truncate_table;
	      CLOSE c_get_table;
	      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'truncate table ' || l_truncate_table);

	      EXECUTE IMMEDIATE 'truncate table ' || l_truncate_table;
	      LogMessage(FND_LOG.LEVEL_STATEMENT,'Truncated whole table');
	end if;
      else

        if from_date is null then
	 if p_truncate_table='Y' then

	      OPEN c_get_table;
	      FETCH c_get_table INTO l_truncate_table;
	      CLOSE c_get_table;
	      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'truncate table ' || l_truncate_table);
	      EXECUTE IMMEDIATE 'truncate table ' || l_truncate_table;
	      LogMessage(FND_LOG.LEVEL_STATEMENT,'Truncated whole table');
	  else
	      mo_global.init('IEX');
	      if p_org_id is null then
	             MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);      -- Multi Org.
		     FND_FILE.PUT_LINE(FND_FILE.LOG, 'MO: Operating Unit=' || 'All');
              else
		   MO_GLOBAL.SET_POLICY_CONTEXT('S',p_ORG_ID);
	      end if;
	      for i in c_org(p_org_id) loop
	      l_org_id:=i.organization_id;
		LogMessage(FND_LOG.LEVEL_STATEMENT,'Delete records corresponding to the org_id passed-->'||l_org_id);
		select count(*) into l_cnt
		from iex_dln_uwq_summary where org_id=l_org_id;
		FND_FILE.PUT_LINE(FND_FILE.LOG,'No of rows selected: ' || l_cnt);
		delete from iex_dln_uwq_summary
		where org_id=l_org_id;
		LogMessage(FND_LOG.LEVEL_STATEMENT,'Records deleted for the org_id passed');
		-- LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No of rows deleted: ' || SQL%ROWCOUNT);
		-- FND_FILE.PUT_LINE(FND_FILE.LOG,'No of rows deleted: ' || SQL%ROWCOUNT);
		 select count(*) into l_cnt1
		from iex_dln_uwq_summary where org_id=l_org_id;
		FND_FILE.PUT_LINE(FND_FILE.LOG,'No of rows selected: ' || l_cnt);
		FND_FILE.PUT_LINE(FND_FILE.LOG,'No of rows remaining: ' || l_cnt1);
	      end loop;
          end if;
	 end if;
       end if;*/


     commit;

  exception
  when others then
     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Exception in delete_rows_from_uwq_summ');
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'SQLCODE: ' || to_char(SQLCODE) || ' SQLERRM: ' || sqlerrm);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'SQLERRM: ' || sqlerrm);
  end delete_rows_from_uwq_summ;
  --End Bug 8707923  27-Jul-2009 barathsr

--Included org_id,truncate_table parameters for Bug 8707923
PROCEDURE populate_uwq_sum_concur (
                    x_errbuf            OUT nocopy VARCHAR2,
                    x_retcode           OUT nocopy VARCHAR2,
                    FROM_DATE           IN  VARCHAR2,
		    p_ou_lvl_enb in varchar2 default null,--Begin Bug 8707923  27-Jul-2009 barathsr
		    p_org_id in number,
		    p_truncate_table in varchar2 default 'N')

IS


 CURSOR c_get_level IS
    SELECT PREFERENCE_VALUE
    FROM IEX_APP_PREFERENCES_B
    WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL'
    and enabled_flag='Y'
    and org_id is null;

CURSOR c_allowed_levels IS
SELECT LOOKUP_CODE
FROM IEX_LOOKUPS_V
WHERE LOOKUP_TYPE='IEX_RUNNING_LEVEL'
AND iex_utilities.validate_running_level(LOOKUP_CODE)='Y';

 cursor c_get_ou_biz_lvl(c_org_id number) is
   SELECT PREFERENCE_VALUE
   FROM IEX_APP_PREFERENCES_B
   WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL'
   and (org_id=c_org_id or org_id is null)
   and enabled_flag='Y'
   order by nvl(org_id,0) desc ;

    CURSOR c_org(c_org_id number) IS
    SELECT organization_id from hr_operating_units where
      mo_global.check_access(organization_id) = 'Y'
      AND organization_id = nvl(c_org_id,organization_id);

   l_allowed_lvl varchar2(20);
   l_curr_org_id number;
   l_truncate_table varchar2(5);
   l_return boolean;
BEGIN

IEX_CHECKLIST_UTILITY.UPDATE_MLSETUP;
 --Bug5691098. Start.
 LogMessage(FND_LOG.LEVEL_STATEMENT,' Populate_uwq_sum_concur Started.');
 FND_FILE.PUT_LINE(FND_FILE.LOG,'from date...-->'||from_date);
 FND_FILE.PUT_LINE(FND_FILE.LOG,'org_id...-->'||p_org_id);
 FND_FILE.PUT_LINE(FND_FILE.LOG,'truncate_table...-->'||p_truncate_table);

FND_FILE.PUT_LINE(FND_FILE.LOG,'populate party,ou global vars...');

select DEFINE_PARTY_RUNNING_LEVEL,DEFINE_OU_RUNNING_LEVEL
 into G_PARTY_LVL_ENB,G_OU_LVL_ENB
 from IEX_QUESTIONNAIRE_ITEMS;



 l_truncate_table:=nvl(p_truncate_table,'N');

 --Begin Bug 9079404 04-Nov-2009 barathsr

 if from_date is not null and l_truncate_table='Y' then
   if FND_GLOBAL.Conc_Request_Id is not null then
          l_return := fnd_concurrent.set_completion_status (status  => 'WARNING',
	                                      message => 'Invalid set of parameters..Pl modify the set of parameters provided.');
   end if;
   LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Invalid set of parameters..Pl modify the set of parameters provided.');
   fnd_file.put_line(FND_FILE.LOG,'Invalid set of parameters..Pl modify the set of parameters provided.');
   return;
 end if;

 if from_date is null and l_truncate_table='N' and g_ou_lvl_enb='N' then
     if FND_GLOBAL.Conc_Request_Id is not null then
          l_return := fnd_concurrent.set_completion_status (status  => 'WARNING',
	                                      message => 'Invalid set of parameters..Pl modify the set of parameters provided.');
   end if;
   LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Invalid set of parameters..Pl modify the set of parameters provided.');
   fnd_file.put_line(FND_FILE.LOG,'Invalid set of parameters..Pl modify the set of parameters provided.');
   return;
 end if;

 --End Bug 9079404 04-Nov-2009 barathsr



 delete_rows_from_uwq_summ(from_date,p_org_id,l_truncate_table);



     if (G_OU_LVL_ENB='Y' or G_PARTY_LVL_ENB='Y') then
        if G_OU_LVL_ENB='Y' then
	mo_global.init('IEX');
                if p_org_id is null then

	       	     MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);      -- Multi Org.
		     FND_FILE.PUT_LINE(FND_FILE.LOG, 'MO: Operating Unit=' || 'All');
		     --open c_org(l_org_id);
		else
		   MO_GLOBAL.SET_POLICY_CONTEXT('S',p_ORG_ID);
		end if;

	        for i in c_org(p_org_id) loop
		l_curr_org_id:=i.organization_id;
		 FND_FILE.PUT_LINE(FND_FILE.LOG, 'org_id is-->'||l_curr_org_id);
		 MO_GLOBAL.SET_POLICY_CONTEXT('S',l_curr_org_id );

	--	update_trx_bal_summ('CP',l_curr_org_id);
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'into OU level');

	       open c_get_ou_biz_lvl(l_curr_org_id);
	       fetch c_get_ou_biz_lvl into G_SYSTEM_LEVEL;
	       close c_get_ou_biz_lvl;
	         FND_FILE.PUT_LINE(FND_FILE.LOG, 'OU lvl is-->'||G_SYSTEM_LEVEL);

	       for r_allowed_levels in c_allowed_levels loop
	       l_allowed_lvl:=r_allowed_LEVELS.lookup_code;
	        FND_FILE.PUT_LINE(FND_FILE.LOG,'looping for other levels in ou-->'||r_allowed_LEVELS.lookup_code);
		if (g_party_lvl_enb='N' and l_allowed_lvl=g_system_level) or g_party_lvl_enb='Y' then
		Insert_Summary(x_errbuf,x_retcode,FROM_DATE,l_curr_org_id,l_allowed_lvl,'CP');
		end if;
		G_LEVEL_COUNT:=G_LEVEL_COUNT+1;
	       end loop;
	       end loop;


         elsif G_PARTY_LVL_ENB='Y' then
	--  update_trx_bal_summ('CP',null);
	 FND_FILE.PUT_LINE(FND_FILE.LOG,'inside party level');
                open c_get_level;
	        fetch c_get_level into G_SYSTEM_LEVEL;
		close c_get_level;
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'party lvl is-->'||G_SYSTEM_LEVEL);
		for r_allowed_levels in c_allowed_levels loop
		 l_allowed_lvl:=r_allowed_LEVELS.lookup_code;
		FND_FILE.PUT_LINE(FND_FILE.LOG,'looping for other levels in party-->'||r_allowed_LEVELS.lookup_code);
		Insert_Summary(x_errbuf,x_retcode,FROM_DATE,null,l_allowed_lvl,'CP');
		G_LEVEL_COUNT:=G_LEVEL_COUNT+1;
	       end loop;

	end if;

   else
        --   update_trx_bal_summ('CP',null);
	   open c_get_level;
	   fetch c_get_level into G_SYSTEM_LEVEL;
	   FND_FILE.PUT_LINE(FND_FILE.LOG,'inside system level-->'||G_SYSTEM_LEVEL);
	   if G_SYSTEM_LEVEL is not null then
	    Insert_Summary(x_errbuf,x_retcode,FROM_DATE,null,G_SYSTEM_LEVEL,'CP');
	   end if;
	   close c_get_level;
  end if;
  exception
  when others then
     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Exception in populate_uwq_sum_concur');
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'SQLCODE: ' || to_char(SQLCODE) || ' SQLERRM: ' || sqlerrm);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'SQLERRM: ' || sqlerrm);
  END populate_uwq_sum_concur;

   --End Bug 8707923  27-Jul-2009 barathsr

 PROCEDURE Insert_Summary(
                    x_errbuf            OUT nocopy VARCHAR2,
                    x_retcode           OUT nocopy VARCHAR2,
                    FROM_DATE           IN  VARCHAR2,
		    p_org_id in number,--Added for Bug 8707923  27-Jul-2009 barathsr
		    p_level in varchar2,--Added for Bug 8707923  27-Jul-2009 barathsr
 	            P_MODE              IN  VARCHAR2 DEFAULT 'CP')
IS

--Commented for Bug 8707923  27-Jul-2009 barathsr.Handled in populate_uwq_sum_concur procedure
 -- CURSOR c_get_level IS
   -- SELECT PREFERENCE_VALUE FROM IEX_APP_PREFERENCES_VL WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL';

      --Start of comment for Bug 9597052 28-Apr-2010 barathsr
  --Start bug 6634879 gnramasa 20th Nov 07
 /* CURSOR c_iex_billto_uwq_summary(c_level varchar2,c_org_id number)--Added for Bug 8707923  27-Jul-2009 barathsr --9597052
  IS
    SELECT
    trx_summ.org_id,
    max(ac.collector_id),
    max(ac.resource_id),
    max(ac.resource_type),
    objb.object_function ieu_object_function,
    objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
    '' ieu_media_type_uuid,
    'CUSTOMER_SITE_USE_ID' ieu_param_pk_col,
    to_char(trx_summ.site_use_id) ieu_param_pk_value,
    1 resource_id,
    'RS_EMPLOYEE' resource_type,
    party.party_id party_id,
    party.party_name party_name,
    trx_summ.cust_account_id cust_account_id,
    acc.account_name account_name,
    acc.account_number account_number,
    trx_summ.site_use_id site_use_id,
    site_uses.location location,
    max(gl.CURRENCY_CODE) currency,
    SUM(trx_summ.op_invoices_count) op_invoices_count,
    SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
    SUM(trx_summ.op_deposits_count) op_deposits_count,
    SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
    SUM(trx_summ.op_chargeback_count) op_chargeback_count,
    SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
    SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
    SUM(trx_summ.disputed_inv_count) disputed_inv_count,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
      (SELECT SUM(b.acctd_amount_due_remaining)
     FROM iex_delinquencies_all a,
       ar_payment_schedules_all b
     WHERE a.customer_site_use_id = trx_summ.site_use_id
     AND a.payment_schedule_id = b.payment_schedule_id
     AND b.status = 'OP'
     AND a.status IN('DELINQUENT',    'PREDELINQUENT')
     AND b.org_id = trx_summ.org_id) past_due_inv_value,
    SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
    MAX(trx_summ.last_payment_date) last_payment_date,
    MAX(iex_uwq_view_pkg.get_last_payment_amount(0,   0,   trx_summ.site_use_id)) last_payment_amount,
    max(gl.CURRENCY_CODE) last_payment_amount_curr,
    MAX(iex_uwq_view_pkg.get_last_payment_number(0,   0,   trx_summ.site_use_id)) last_payment_number,
    MAX(trx_summ.last_update_date) last_update_date,
    MAX(trx_summ.last_updated_by) last_updated_by,
    MAX(trx_summ.creation_date) creation_date,
    MAX(trx_summ.created_by) created_by,
    MAX(trx_summ.last_update_login) last_update_login,
      (SELECT COUNT(1)
     FROM iex_delinquencies_all
     WHERE customer_site_use_id = trx_summ.site_use_id
     AND status IN('DELINQUENT',    'PREDELINQUENT')
     AND org_id = trx_summ.org_id)
  number_of_delinquencies,
      (SELECT 1
     FROM dual
     WHERE EXISTS
      (SELECT 1
       FROM iex_delinquencies_all
       WHERE customer_site_use_id = trx_summ.site_use_id
       AND status IN('DELINQUENT',    'PREDELINQUENT')
       AND org_id = trx_summ.org_id
       AND(uwq_status IS NULL OR uwq_status = 'ACTIVE' OR(TRUNC(uwq_active_date) <= TRUNC(sysdate)
       AND uwq_status = 'PENDING')))
    )
  active_delinquencies,
      (SELECT 1
     FROM dual
     WHERE EXISTS
      (SELECT 1
       FROM iex_delinquencies_all
       WHERE customer_site_use_id = trx_summ.site_use_id
       AND status IN('DELINQUENT',    'PREDELINQUENT')
       AND org_id = trx_summ.org_id
       AND(uwq_status = 'COMPLETE'
       AND(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
    )
  complete_delinquencies,
      (SELECT 1
     FROM dual
     WHERE EXISTS
      (SELECT 1
       FROM iex_delinquencies_all where customer_site_use_id = trx_summ.site_use_id
       AND status IN('DELINQUENT',    'PREDELINQUENT')
       AND org_id = trx_summ.org_id
       AND(uwq_status = 'PENDING'
       AND(TRUNC(uwq_active_date) > TRUNC(sysdate))))
    )
  pending_delinquencies,*/ --9597052
  -- Start for the bug#7562130 by PNAVEENK
/*      (SELECT a.score_value
     FROM iex_score_histories a
     WHERE a.creation_date =
      (SELECT MAX(creation_date)
       FROM iex_score_histories
       WHERE score_object_code = 'IEX_BILLTO'
       AND score_object_id = trx_summ.site_use_id)
    AND rownum < 2
     AND a.score_object_code = 'IEX_BILLTO'
     AND a.score_object_id = trx_summ.site_use_id)
  score,*/
   /* to_number(cal_score(trx_summ.site_use_id,'IEX_BILLTO','SCORE_VALUE')) score,  -9597052
    to_number(cal_score(trx_summ.site_use_id,'IEX_BILLTO','SCORE_ID')) score_id,
    cal_score(trx_summ.site_use_id,'IEX_BILLTO','SCORE_NAME') score_name,
    max(decode(ac.resource_type, 'RS_RESOURCE' ,
          (select rs.source_name from jtf_rs_resource_extns rs where rs.resource_id= ac.resource_id),
          (select rg.group_name from JTF_RS_GROUPS_VL rg where rg.group_id=ac.resource_id)
          ) )  collector_resource_name,*/ --9597052
   -- end for the bug#7562130
   -- Start for the bug#8538945 by PNAVEENK
 /*   party.address1 address1,
    party.city city,
    party.state state,
    party.county county,*/
/*    loc.address1 address1,  --9597052
    loc.city city,
    loc.state state,
    loc.county county,
    fnd_terr.territory_short_name country,
 --   party.province province,
 --    party.postal_code postal_code,
    loc.province province,
    loc.postal_code postal_code,
   -- end for the bug#8538945
    phone.phone_country_code phone_country_code,
    phone.phone_area_code phone_area_code,
    phone.phone_number phone_number,
    phone.phone_extension phone_extension,
   (SELECT COUNT(1) FROM iex_bankruptcies bkr
    WHERE bkr.party_id = party.party_id and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')) number_of_bankruptcies, -- Changed for bug#7693986

    (SELECT COUNT(1) FROM iex_promise_details PRO, IEX_DELINQUENCIES_ALL DEL
     WHERE PRO.CUST_ACCOUNT_ID = TRX_SUMM.CUST_ACCOUNT_ID and del.customer_site_use_id = TRX_SUMM.site_use_ID AND
     PRO.STATUS IN ('COLLECTABLE', 'PENDING') AND PRO.STATE = 'BROKEN_PROMISE' AND PRO.AMOUNT_DUE_REMAINING > 0 AND
     PRO.DELINQUENCY_ID = DEL.DELINQUENCY_ID(+)
     AND (DEL.STATUS --(+) Commented for Bug 6446848 06-Jan-2009 barathsr
     NOT IN ('CURRENT', 'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 06-Jan-2009 barathsr
     AND DEL.org_id = trx_summ.org_id) number_of_promises,

    (SELECT SUM(AMOUNT_DUE_REMAINING) FROM iex_promise_details PRO, IEX_DELINQUENCIES_ALL DEL
     WHERE PRO.CUST_ACCOUNT_ID = TRX_SUMM.CUST_ACCOUNT_ID and del.customer_site_use_id = TRX_SUMM.site_use_ID AND
     PRO.STATUS IN ('COLLECTABLE', 'PENDING') AND PRO.STATE = 'BROKEN_PROMISE' AND PRO.AMOUNT_DUE_REMAINING > 0 AND
     PRO.DELINQUENCY_ID = DEL.DELINQUENCY_ID(+)
     AND (DEL.STATUS --(+)  Commented for Bug 6446848 06-Jan-2009 barathsr
     NOT IN ('CURRENT', 'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 06-Jan-2009 barathsr
     AND DEL.org_id = trx_summ.org_id) BROKEN_PROMISE_AMOUNT ,

    (SELECT SUM(PROMISE_AMOUNT) FROM iex_promise_details PRO, IEX_DELINQUENCIES_ALL DEL
     WHERE PRO.CUST_ACCOUNT_ID = TRX_SUMM.CUST_ACCOUNT_ID and del.customer_site_use_id = TRX_SUMM.site_use_ID AND
     PRO.STATUS IN ('COLLECTABLE', 'PENDING') AND PRO.STATE = 'BROKEN_PROMISE' AND PRO.AMOUNT_DUE_REMAINING > 0 AND
     PRO.DELINQUENCY_ID = DEL.DELINQUENCY_ID(+)
     AND (DEL.STATUS --(+) Commented for Bug 6446848 06-Jan-2009 barathsr
     NOT IN ('CURRENT', 'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 06-Jan-2009 barathsr
     AND DEL.org_id = trx_summ.org_id) PROMISE_AMOUNT,

    (SELECT 1 FROM dual WHERE EXISTS
      (SELECT 1 FROM dual WHERE EXISTS
        (SELECT 1
         FROM iex_promise_details PRO, IEX_DELINQUENCIES_ALL DEL
         WHERE pro.cust_account_id = trx_summ.cust_account_id
         and del.customer_site_use_id = TRX_SUMM.site_use_ID
         AND pro.state = 'BROKEN_PROMISE'
         AND(pro.uwq_status IS NULL OR pro.uwq_status = 'ACTIVE' OR(TRUNC(pro.uwq_active_date) <= TRUNC(sysdate)
         AND pro.uwq_status = 'PENDING')))
      )
    ) active_promises,

    (SELECT 1 FROM dual WHERE EXISTS
      (SELECT 1 FROM dual WHERE EXISTS
        (SELECT 1
         FROM iex_promise_details PRO, IEX_DELINQUENCIES_ALL DEL
         WHERE pro.cust_account_id = trx_summ.cust_account_id
         and del.customer_site_use_id = TRX_SUMM.site_use_ID
         AND pro.state = 'BROKEN_PROMISE'
         AND(pro.uwq_status = 'COMPLETE'
         AND(TRUNC(pro.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
      )
    ) complete_promises,

    (SELECT 1 FROM dual WHERE EXISTS
      (SELECT 1 FROM dual WHERE EXISTS
        (SELECT 1
         FROM iex_promise_details PRO, IEX_DELINQUENCIES_ALL DEL
         WHERE pro.cust_account_id = trx_summ.cust_account_id
         and del.customer_site_use_id = TRX_SUMM.site_use_ID
         AND pro.state = 'BROKEN_PROMISE'
         AND(pro.uwq_status = 'PENDING'
         AND(TRUNC(pro.uwq_active_date) > TRUNC(sysdate))))
      )
    ) pending_promises

  FROM ar_trx_bal_summary trx_summ,
    hz_cust_accounts acc,
    hz_parties party,
    hz_party_preferences party_pref,--Added for Bug 8707923  27-Jul-2009 barathsr
    jtf_objects_b objb,
    hz_contact_points phone,
    fnd_territories_tl fnd_terr,
    hz_cust_site_uses_all site_uses,
    hz_customer_profiles prf,
    ar_collectors ac,
    GL_SETS_OF_BOOKS gl,
    AR_SYSTEM_PARAMETERS_all sys,
    -- Added for the bug#8538945 by PNAVEENK
     HZ_CUST_ACCT_SITES_all ACCT_SITE,--Modified for Bug 9487600 23-Mar-2010 barathsr
     HZ_PARTY_SITES PARTY_SITE,
       HZ_LOCATIONS LOC
     -- end for the bug#8538945
  WHERE
   P_MODE = 'CP'
   AND trx_summ.reference_1 = '1'
   -- Added for the bug#8538945 by PNAVEENK
   and PARTY_SITE.LOCATION_ID = LOC.LOCATION_ID
    and ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
   and site_uses.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
   -- end for the bug#8538945
   AND trx_summ.site_use_id = site_uses.site_use_id
   AND trx_summ.cust_account_id = acc.cust_account_id
   AND acc.party_id = party.party_id
   AND objb.object_code = 'IEX_BILLTO'
   and objb.object_code <> 'IEX_DELINQUENCY'--Added for Bug 8707923 27-Jul-2009 barathsr
   AND loc.country = fnd_terr.territory_code(+)  -- Changed for the bug#8538945
   AND fnd_terr.LANGUAGE(+) = userenv('LANG')
   AND phone.owner_table_id(+) = party.party_id
   AND phone.owner_table_name(+) = 'HZ_PARTIES'
   AND phone.contact_point_type(+) = 'PHONE'
   AND phone.primary_by_purpose(+) = 'Y'
   AND phone.contact_point_purpose(+) = 'COLLECTIONS'
   AND phone.phone_line_type(+) NOT IN('PAGER',   'FAX')
   AND phone.status(+) = 'A'
   AND nvl(phone.do_not_use_flag(+),   'N') = 'N'
   and prf.SITE_USE_ID(+) = trx_summ.site_use_id
   and ac.collector_id(+) = prf.collector_id
   and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
   and trx_summ.org_id = sys.org_id
   --Begin Bug 8707923  27-Jul-2009 barathsr
   and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),c_level)='BILL_TO'
   and trx_summ.org_id=nvl(c_org_id,trx_summ.org_id)
   --End Bug 8707923  27-Jul-2009 barathsr
  GROUP BY trx_summ.org_id,
    objb.object_function,
    objb.object_parameters,
    party.party_id,
    party.party_name,
    trx_summ.cust_account_id,
    acc.account_name,
    acc.account_number,
    trx_summ.site_use_id,
    site_uses.location,  /* --9597052
    -- Start for the bug#8538945 by PNAVEENK
  /*  party.address1,
    party.city,
    party.state,
    party.county,*/
 /*    loc.address1,   --9597052
    loc.city,
    loc.state,
    loc.county,
    fnd_terr.territory_short_name,
 --   party.province,
 --   party.postal_code,
    loc.province,
    loc.postal_code,
    -- end for the bug#8538945
    phone.phone_country_code,
    phone.phone_area_code,
    phone.phone_number,
    phone.phone_extension;*/ --9597052
    --End of comment for Bug 9597052 28-Apr-2010 barathsr

    --Begin Bug 9597052 28-Apr-2010 barathsr
    --This cursor fetches column values from ar_trx_bal_summary table and the values are inserted in iex_dln_uwq_summary
    --All the other column values are fetched with small cursors from the respective tables and updated in iex_dln_uwq_summary
    CURSOR c_iex_billto_uwq_summary(c_level varchar2,c_org_id number)
    IS
    SELECT
    trx_summ.org_id,
    objb.object_function ieu_object_function,
    objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
    '' ieu_media_type_uuid,
    'CUSTOMER_SITE_USE_ID' ieu_param_pk_col,
    to_char(trx_summ.site_use_id) ieu_param_pk_value,
    to_number(null) party_id,
    trx_summ.cust_account_id cust_account_id,
    trx_summ.site_use_id site_use_id,
    max(gl.CURRENCY_CODE) currency,
    SUM(trx_summ.op_invoices_count) op_invoices_count,
    SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
    SUM(trx_summ.op_deposits_count) op_deposits_count,
    SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
    SUM(trx_summ.op_chargeback_count) op_chargeback_count,
    SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
    SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
    SUM(trx_summ.disputed_inv_count) disputed_inv_count,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
    SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
    MAX(trx_summ.last_payment_date) last_payment_date,
    MAX(trx_summ.last_update_date) last_update_date,
    MAX(trx_summ.last_updated_by) last_updated_by,
    MAX(trx_summ.creation_date) creation_date,
    MAX(trx_summ.created_by) created_by,
    MAX(trx_summ.last_update_login) last_update_login
    FROM ar_trx_bal_summary trx_summ,
          GL_SETS_OF_BOOKS gl,
          AR_SYSTEM_PARAMETERS_all sys,
	   jtf_objects_b objb,
	    hz_cust_accounts acc,
	   hz_party_preferences party_pref
     where
        P_MODE = 'CP'
   AND trx_summ.reference_1 = '1'
    AND objb.object_code = 'IEX_BILLTO'
   and objb.object_code <> 'IEX_DELINQUENCY'
   and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
   and trx_summ.org_id = sys.org_id
   and trx_summ.org_id=nvl(c_org_id,trx_summ.org_id)
   and trx_summ.cust_account_id=acc.cust_account_id
   and acc.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),c_level)='BILL_TO'
   and trx_summ.site_use_id > 0
   group by trx_summ.org_id,
    objb.object_function,
    objb.object_parameters,
    trx_summ.cust_account_id,
    trx_summ.site_use_id;

    cursor c_billto_deln_cnt is
    SELECT a.customer_site_use_id,
    count(a.delinquency_id) number_of_delinquencies,
    SUM(b.acctd_amount_due_remaining) past_due_inv_value
   FROM iex_delinquencies_all a,
        ar_payment_schedules_all b,
        iex_dln_uwq_summary dln
   WHERE a.customer_site_use_id =dln.site_use_id
    AND a.payment_schedule_id = b.payment_schedule_id
    AND b.status = 'OP'
    AND a.status IN('DELINQUENT',   'PREDELINQUENT')
    AND dln.org_id = a.org_id
   GROUP BY a.customer_site_use_id;


    cursor c_billto_deln_dtls
   is
   select del.CUSTOMER_SITE_USE_ID,
    max(decode(uwq_status,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_delinquencies,
    max(decode(uwq_status,'COMPLETE',(decode(sign(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_delinquencies,
    max(decode(uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_delinquencies
    from iex_delinquencies_all del,
      iex_dln_uwq_summary dln
    WHERE del.customer_site_use_id = dln.site_use_id  AND
    del.org_id = dln.org_id and
    del.status IN('DELINQUENT',    'PREDELINQUENT')
    group by del.CUSTOMER_SITE_USE_ID;


  cursor c_billto_pro_dtls is
   SELECT del.customer_site_use_id,
	COUNT(1) number_of_promises,
	SUM(pd.amount_due_remaining) broken_promise_amount,
	SUM(pd.promise_amount) promise_amount
   FROM iex_promise_details pd,
         iex_delinquencies_all del,
         iex_dln_uwq_summary dln
   WHERE pd.cust_account_id = del.cust_account_id
     AND pd.delinquency_id = del.delinquency_id
     AND pd.status IN('COLLECTABLE',   'PENDING')
     AND pd.state = 'BROKEN_PROMISE'
     AND pd.amount_due_remaining > 0
     AND (del.status NOT IN('CURRENT',   'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))
     and del.customer_site_use_id = dln.site_use_id
     and del.org_id = dln.org_id
   GROUP BY del.customer_site_use_id;

   cursor c_billto_pro_summ is
    select del.CUSTOMER_SITE_USE_ID,
    max(decode(pd.uwq_status,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_promises,
    max(decode(pd.uwq_status,'COMPLETE',(decode(sign(TRUNC(pd.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_promises,
    max(decode(pd.uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_promises
    from iex_promise_details pd,
    IEX_DELINQUENCIES_ALL DEL,
    iex_dln_uwq_summary dln
    WHERE pd.cust_account_id = del.cust_account_id
      and pd.delinquency_id = del.delinquency_id
      and del.customer_site_use_id = dln.site_use_id
      and del.org_id = dln.org_id
      and pd.state = 'BROKEN_PROMISE'
     group by del.CUSTOMER_SITE_USE_ID;


   CURSOR c_billto_site_details IS
    SELECT
    party.party_id party_id,
    party.party_name party_name,
    summ.cust_account_id cust_account_id,
    acc.account_name account_name,
    acc.account_number account_number,
    summ.site_use_id site_use_id,
    site_uses.location location,
    loc.address1 address1,
    loc.city city,
    loc.state state,
    loc.county county,
    fnd_terr.territory_short_name country,
    loc.province province,
    loc.postal_code postal_code
  FROM iex_dln_uwq_summary summ,
    hz_cust_accounts acc,
    hz_parties party,
    hz_party_preferences party_pref,
    fnd_territories_tl fnd_terr,
    hz_cust_site_uses_all site_uses,
    hz_cust_acct_sites_all acct_site,
    hz_party_sites party_site,
    hz_locations loc
  WHERE
   party_site.location_id = loc.location_id
   and acct_site.party_site_id = party_site.party_site_id
   and site_uses.cust_acct_site_id = acct_site.cust_acct_site_id
   AND summ.site_use_id = site_uses.site_use_id
   AND summ.cust_account_id = acc.cust_account_id
   AND acc.party_id = party.party_id
   AND loc.country = fnd_terr.territory_code(+)
   AND fnd_terr.LANGUAGE(+) = userenv('LANG')
   and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   GROUP BY party.party_id,
    party.party_name,
    summ.cust_account_id,
    acc.account_name,
    acc.account_number,
    summ.site_use_id,
    site_uses.location,
    loc.address1,
    loc.city,
    loc.state,
    loc.county,
    fnd_terr.territory_short_name,
    loc.province,
    loc.postal_code;


    CURSOR C_billto_CONTACT_POINT IS
      SELECT summ.party_id,
	phone.phone_country_code phone_country_code,
	phone.phone_area_code phone_area_code,
	phone.phone_number phone_number,
	phone.phone_extension phone_extension
  FROM iex_dln_uwq_summary summ,
	hz_contact_points phone
  WHERE
   phone.owner_table_id = summ.party_id
   AND phone.owner_table_name = 'HZ_PARTIES'
   AND phone.contact_point_type = 'PHONE'
   AND phone.primary_by_purpose = 'Y'
   AND phone.contact_point_purpose = 'COLLECTIONS'
   AND phone.phone_line_type NOT IN('PAGER',   'FAX')
   AND phone.status = 'A'
   AND nvl(phone.do_not_use_flag,   'N') = 'N'
   group by summ.party_id,
    phone.phone_country_code,
    phone.phone_area_code,
    phone.phone_number,
    phone.phone_extension;


    CURSOR C_billto_COLLECTOR_prof IS
      SELECT
       hp.collector_id collector_id,
       ac.resource_id collector_resource_id,
        ac.resource_type COLLECTOR_RES_TYPE,
	decode(ac.resource_type, 'RS_RESOURCE' , rs.source_name , rg.group_name)   collector_resource_name,
        1 resource_id,
        'RS_EMPLOYEE' resource_type,
	 hp.party_id,
	 hp.cust_account_id,
	 hp.site_use_id
      FROM
         hz_customer_profiles hp,
	 ar_collectors ac,
	 iex_dln_uwq_summary temp,
	 JTF_RS_GROUPS_VL rg,
         jtf_rs_resource_extns rs
      WHERE
         hp.site_use_id=temp.site_use_id
	 and hp.collector_id=ac.collector_id
	 and rg.group_id (+) = ac.resource_id
         and rs.resource_id(+) = ac.resource_id;

   cursor c_billto_last_payment_dtls is
   select summ.site_use_id,
         summ.last_payment_amount last_payment_amount,
	 summ.currency last_payment_currency,
	 summ.last_payment_number last_payment_number
   from ar_trx_bal_summary summ,
    gl_sets_of_books gl,
    ar_system_parameters_all sys
   where summ.reference_1='1'
   and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
   and summ.org_id = sys.org_id
   and summ.last_payment_date=(select max(summ1.last_payment_date)
	from iex_dln_uwq_summary summ1
	where summ1.site_use_id=summ.site_use_id);

  cursor c_billto_bankruptcies is
   select summ.party_id,
   COUNT(1) number_of_bankruptcies
   FROM iex_bankruptcies bkr,
   iex_dln_uwq_summary summ
   where bkr.customer_site_use_id=summ.site_use_id
   and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')
   group by summ.party_id;

   cursor c_billto_score is
    SELECT sh.score_object_id,
    sh.score_value score,
    sc.score_id,
    sc.score_name
   FROM iex_score_histories sh,iex_scores sc
   WHERE sc.score_id = sh.score_id
   and sh.score_object_code = 'IEX_BILLTO'
   and (sh.score_object_id,sh.score_object_code,sh.creation_date)
      in (SELECT sh1.score_object_id,sh1.score_object_code,MAX(sh1.creation_date)
          FROM iex_score_histories sh1,
          iex_dln_uwq_summary temp
	WHERE sh1.score_object_code = 'IEX_BILLTO'
   AND sh1.score_object_id = temp.site_use_id
	group by sh1.score_object_id,sh1.score_object_code);
--End Bug 9597052 28-Apr-2010 barathsr


-----------------
   --Start of comment for  Bug 9597052 28-Apr-2010 barathsr
    -- Begin - Andre Araujo - 10/20/06 - Added selection using date
  /*CURSOR c_iex_billto_uwq_dt_sum(p_from_date date,c_level varchar2,c_org_id number)--Added for Bug 8707923 27-Jul-2009 barathsr --9597052
  IS
    SELECT
    trx_summ.org_id,
    max(ac.collector_id),
    max(ac.resource_id),
    max(ac.resource_type),
    objb.object_function ieu_object_function,
    objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
    '' ieu_media_type_uuid,
    'CUSTOMER_SITE_USE_ID' ieu_param_pk_col,
    to_char(trx_summ.site_use_id) ieu_param_pk_value,
    1 resource_id,
    'RS_EMPLOYEE' resource_type,
    party.party_id party_id,
    party.party_name party_name,
    trx_summ.cust_account_id cust_account_id,
    acc.account_name account_name,
    acc.account_number account_number,
    trx_summ.site_use_id site_use_id,
    site_uses.location location,
    max(gl.CURRENCY_CODE) currency,
    SUM(trx_summ.op_invoices_count) op_invoices_count,
    SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
    SUM(trx_summ.op_deposits_count) op_deposits_count,
    SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
    SUM(trx_summ.op_chargeback_count) op_chargeback_count,
    SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
    SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
    SUM(trx_summ.disputed_inv_count) disputed_inv_count,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
      (SELECT SUM(b.acctd_amount_due_remaining)
     FROM iex_delinquencies_all a,
       ar_payment_schedules_all b
     WHERE a.customer_site_use_id = trx_summ.site_use_id
     AND a.payment_schedule_id = b.payment_schedule_id
     AND b.status = 'OP'
     AND a.status IN('DELINQUENT',    'PREDELINQUENT')
     AND b.org_id = trx_summ.org_id) past_due_inv_value,
    SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
    MAX(trx_summ.last_payment_date) last_payment_date,
    MAX(iex_uwq_view_pkg.get_last_payment_amount(0,   0,   trx_summ.site_use_id)) last_payment_amount,
    max(gl.CURRENCY_CODE) last_payment_amount_curr,
    MAX(iex_uwq_view_pkg.get_last_payment_number(0,   0,   trx_summ.site_use_id)) last_payment_number,
    MAX(trx_summ.last_update_date) last_update_date,
    MAX(trx_summ.last_updated_by) last_updated_by,
    MAX(trx_summ.creation_date) creation_date,
    MAX(trx_summ.created_by) created_by,
    MAX(trx_summ.last_update_login) last_update_login,
      (SELECT COUNT(1)
     FROM iex_delinquencies_all
     WHERE customer_site_use_id = trx_summ.site_use_id
     AND status IN('DELINQUENT',    'PREDELINQUENT')
     AND org_id = trx_summ.org_id)
  number_of_delinquencies,
      (SELECT 1
     FROM dual
     WHERE EXISTS
      (SELECT 1
       FROM iex_delinquencies_all
       WHERE customer_site_use_id = trx_summ.site_use_id
       AND status IN('DELINQUENT',    'PREDELINQUENT')
       AND org_id = trx_summ.org_id
       AND(uwq_status IS NULL OR uwq_status = 'ACTIVE' OR(TRUNC(uwq_active_date) <= TRUNC(sysdate)
       AND uwq_status = 'PENDING')))
    )
  active_delinquencies,
      (SELECT 1
     FROM dual
     WHERE EXISTS
      (SELECT 1
       FROM iex_delinquencies_all
       WHERE customer_site_use_id = trx_summ.site_use_id
       AND status IN('DELINQUENT',    'PREDELINQUENT')
       AND org_id = trx_summ.org_id
       AND(uwq_status = 'COMPLETE'
       AND(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
    )
  complete_delinquencies,
      (SELECT 1
     FROM dual
     WHERE EXISTS
      (SELECT 1
       FROM iex_delinquencies_all where customer_site_use_id = trx_summ.site_use_id
       AND status IN('DELINQUENT',    'PREDELINQUENT')
       AND org_id = trx_summ.org_id
       AND(uwq_status = 'PENDING'
       AND(TRUNC(uwq_active_date) > TRUNC(sysdate))))
    )
  pending_delinquencies,*/ --9597052
      -- Start for the bug#7562130 by PNAVEENK
/*      (SELECT a.score_value
     FROM iex_score_histories a
     WHERE a.creation_date =
      (SELECT MAX(creation_date)
       FROM iex_score_histories
       WHERE score_object_code = 'IEX_BILLTO'
       AND score_object_id = trx_summ.site_use_id)
    AND rownum < 2
     AND a.score_object_code = 'IEX_BILLTO'
     AND a.score_object_id = trx_summ.site_use_id)
  score,*/
   /*to_number(cal_score(trx_summ.site_use_id,'IEX_BILLTO','SCORE_VALUE')) score, --9597052
    to_number(cal_score(trx_summ.site_use_id,'IEX_BILLTO','SCORE_ID')) score_id,
    cal_score(trx_summ.site_use_id,'IEX_BILLTO','SCORE_NAME') score_name,
    max(decode(ac.resource_type, 'RS_RESOURCE' ,
          (select rs.source_name from jtf_rs_resource_extns rs where rs.resource_id= ac.resource_id),
          (select rg.group_name from JTF_RS_GROUPS_VL rg where rg.group_id=ac.resource_id)
          ) )  collector_resource_name,*/--9597052
   -- end for the bug#7562130
   -- Start for the bug#8538945 by PNAVEENK
 /*   party.address1 address1,
    party.city city,
    party.state state,
    party.county county,*/
   /* loc.address1 address1, --9597052
    loc.city city,
    loc.state state,
    loc.county county,
    fnd_terr.territory_short_name country,*/ --9597052
 --   party.province province,
 --    party.postal_code postal_code,
   /* loc.province province,  --9597052
    loc.postal_code postal_code,
   -- end for the bug#8538945
    phone.phone_country_code phone_country_code,
    phone.phone_area_code phone_area_code,
    phone.phone_number phone_number,
    phone.phone_extension phone_extension,
   (SELECT COUNT(1) FROM iex_bankruptcies bkr WHERE bkr.party_id = party.party_id and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')) number_of_bankruptcies, -- Changed for bug#7693986

    (SELECT COUNT(1) FROM iex_promise_details PRO, IEX_DELINQUENCIES_ALL DEL
     WHERE PRO.CUST_ACCOUNT_ID = TRX_SUMM.CUST_ACCOUNT_ID and del.customer_site_use_id = TRX_SUMM.site_use_ID AND
     PRO.STATUS IN ('COLLECTABLE', 'PENDING') AND PRO.STATE = 'BROKEN_PROMISE' AND PRO.AMOUNT_DUE_REMAINING > 0 AND
     PRO.DELINQUENCY_ID = DEL.DELINQUENCY_ID(+)
     AND (DEL.STATUS --(+) Commented for Bug 6446848 06-Jan-2009 barathsr
     NOT IN ('CURRENT', 'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV')) --Added for Bug 6446848 06-Jan-2009 barathsr
     AND DEL.org_id = trx_summ.org_id) number_of_promises,

    (SELECT SUM(AMOUNT_DUE_REMAINING) FROM iex_promise_details PRO, IEX_DELINQUENCIES_ALL DEL
     WHERE PRO.CUST_ACCOUNT_ID = TRX_SUMM.CUST_ACCOUNT_ID and del.customer_site_use_id = TRX_SUMM.site_use_ID AND
     PRO.STATUS IN ('COLLECTABLE', 'PENDING') AND PRO.STATE = 'BROKEN_PROMISE' AND PRO.AMOUNT_DUE_REMAINING > 0 AND
     PRO.DELINQUENCY_ID = DEL.DELINQUENCY_ID(+)
     AND (DEL.STATUS --(+) Commented for Bug 6446848 06-Jan-2009 barathsr
     NOT IN ('CURRENT', 'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV')) --Added for Bug 6446848 06-Jan-2009 barathsr
     AND DEL.org_id = trx_summ.org_id) BROKEN_PROMISE_AMOUNT ,

    (SELECT SUM(PROMISE_AMOUNT) FROM iex_promise_details PRO, IEX_DELINQUENCIES_ALL DEL
     WHERE PRO.CUST_ACCOUNT_ID = TRX_SUMM.CUST_ACCOUNT_ID and del.customer_site_use_id = TRX_SUMM.site_use_ID AND
     PRO.STATUS IN ('COLLECTABLE', 'PENDING') AND PRO.STATE = 'BROKEN_PROMISE' AND PRO.AMOUNT_DUE_REMAINING > 0 AND
     PRO.DELINQUENCY_ID = DEL.DELINQUENCY_ID(+)
     AND (DEL.STATUS --(+) Commented for Bug 6446848 06-Jan-2009 barathsr
     NOT IN ('CURRENT', 'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV')) --Added for Bug 6446848 06-Jan-2009 barathsr
     AND DEL.org_id = trx_summ.org_id) PROMISE_AMOUNT,

    (SELECT 1 FROM dual WHERE EXISTS
      (SELECT 1 FROM dual WHERE EXISTS
        (SELECT 1
         FROM iex_promise_details PRO, IEX_DELINQUENCIES_ALL DEL
         WHERE pro.cust_account_id = trx_summ.cust_account_id
         and del.customer_site_use_id = TRX_SUMM.site_use_ID
         AND pro.state = 'BROKEN_PROMISE'
         AND(pro.uwq_status IS NULL OR pro.uwq_status = 'ACTIVE' OR(TRUNC(pro.uwq_active_date) <= TRUNC(sysdate)
         AND pro.uwq_status = 'PENDING')))
      )
    ) active_promises,

    (SELECT 1 FROM dual WHERE EXISTS
      (SELECT 1 FROM dual WHERE EXISTS
        (SELECT 1
         FROM iex_promise_details PRO, IEX_DELINQUENCIES_ALL DEL
         WHERE pro.cust_account_id = trx_summ.cust_account_id
         and del.customer_site_use_id = TRX_SUMM.site_use_ID
         AND pro.state = 'BROKEN_PROMISE'
         AND(pro.uwq_status = 'COMPLETE'
         AND(TRUNC(pro.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
      )
    ) complete_promises,

    (SELECT 1 FROM dual WHERE EXISTS
      (SELECT 1 FROM dual WHERE EXISTS
        (SELECT 1
         FROM iex_promise_details PRO, IEX_DELINQUENCIES_ALL DEL
         WHERE pro.cust_account_id = trx_summ.cust_account_id
         and del.customer_site_use_id = TRX_SUMM.site_use_ID
         AND pro.state = 'BROKEN_PROMISE'
         AND(pro.uwq_status = 'PENDING'
         AND(TRUNC(pro.uwq_active_date) > TRUNC(sysdate))))
      )
    ) pending_promises
  FROM ar_trx_bal_summary trx_summ,
    hz_cust_accounts acc,
    hz_parties party,
    hz_party_preferences party_pref,--Added for Bug 8707923 27-Jul-2009 barathsr
    jtf_objects_b objb,
    hz_contact_points phone,
    fnd_territories_tl fnd_terr,
    hz_cust_site_uses_all site_uses,
    hz_customer_profiles prf,
    ar_collectors ac,
    GL_SETS_OF_BOOKS gl,
    AR_SYSTEM_PARAMETERS_all sys,
     -- Added for the bug#8538945 by PNAVEENK
     HZ_CUST_ACCT_SITES_all ACCT_SITE,--Modified for Bug 9487600 23-Mar-2010 barathsr
     HZ_PARTY_SITES PARTY_SITE,
       HZ_LOCATIONS LOC
     -- end for the bug#8538945
  WHERE
   trx_summ.reference_1 = '1'
    -- Added for the bug#8538945 by PNAVEENK
   and PARTY_SITE.LOCATION_ID = LOC.LOCATION_ID
    and ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
   and site_uses.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
   -- end for the bug#8538945
   AND trx_summ.site_use_id = site_uses.site_use_id
   AND trx_summ.cust_account_id = acc.cust_account_id
   AND acc.party_id = party.party_id
   AND objb.object_code = 'IEX_BILLTO'
   and objb.object_code <> 'IEX_DELINQUENCY'--Added for Bug 8707923 27-Jul-2009 barathsr
   AND loc.country = fnd_terr.territory_code(+)  -- Changed for the bug#8538945
   AND fnd_terr.LANGUAGE(+) = userenv('LANG')
   AND phone.owner_table_id(+) = party.party_id
   AND phone.owner_table_name(+) = 'HZ_PARTIES'
   AND phone.contact_point_type(+) = 'PHONE'
   AND phone.primary_by_purpose(+) = 'Y'
   AND phone.contact_point_purpose(+) = 'COLLECTIONS'
   AND phone.phone_line_type(+) NOT IN('PAGER',   'FAX')
   AND phone.status(+) = 'A'
   AND nvl(phone.do_not_use_flag(+),   'N') = 'N'
   and prf.SITE_USE_ID(+) = trx_summ.site_use_id
   and ac.collector_id(+) = prf.collector_id
   and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
   and trx_summ.org_id = sys.org_id*/ --9597052
   -- start bug 5762888 gnramasa 13-July-2007
  /* and (trx_summ.cust_account_id, trx_summ.site_use_id, trx_summ.org_id) in
       (select cust_account_id, site_use_id, org_id from ar_trx_bal_summary where trunc(LAST_UPDATE_DATE) >= trunc(p_from_date))
    */
 /*  and trunc(trx_summ.last_update_date) >= trunc(p_from_date)--9597052
   -- end bug 5762888 gnramasa 13-July-2007
   --Begin Bug 8707923  27-Jul-2009 barathsr
   and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),c_level)='BILL_TO'
   and trx_summ.org_id=nvl(c_org_id,trx_summ.org_id)
   --End Bug 8707923  27-Jul-2009 barathsr
  GROUP BY trx_summ.org_id,
    objb.object_function,
    objb.object_parameters,
    party.party_id,
    party.party_name,
    trx_summ.cust_account_id,
    acc.account_name,
    acc.account_number,
    trx_summ.site_use_id,
    site_uses.location,*/ --9597052
     -- Start for the bug#8538945 by PNAVEENK
  /*  party.address1,
    party.city,
    party.state,
    party.county,*/
 /*    loc.address1, --9597052
    loc.city,
    loc.state,
    loc.county,
    fnd_terr.territory_short_name,
 --   party.province,
 --   party.postal_code,
    loc.province,
    loc.postal_code,
    -- end for the bug#8538945
    phone.phone_country_code,
    phone.phone_area_code,
    phone.phone_number,
    phone.phone_extension;*/ --9597052
    -- End - Andre Araujo - 10/20/06 - Added selection using date
 --End of comment for Bug 9597052 28-Apr-2010 barathsr
   --Begin Bug 9597052 28-Apr-2010 barathsr
    --This cursor fetches column values from ar_trx_bal_summary table and the values are inserted in iex_dln_uwq_summary for the date specified
    --All the other column values are fetched with small cursors from the respective tables and updated in iex_dln_uwq_summary

    CURSOR c_iex_billto_uwq_dt_sum(p_from_date date,c_level varchar2,c_org_id number)
    IS
    SELECT
    trx_summ.org_id,
    objb.object_function ieu_object_function,
    objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
    '' ieu_media_type_uuid,
    'CUSTOMER_SITE_USE_ID' ieu_param_pk_col,
    to_char(trx_summ.site_use_id) ieu_param_pk_value,
    to_number(null) party_id,
    trx_summ.cust_account_id cust_account_id,
    trx_summ.site_use_id site_use_id,
    max(gl.CURRENCY_CODE) currency,
    SUM(trx_summ.op_invoices_count) op_invoices_count,
    SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
    SUM(trx_summ.op_deposits_count) op_deposits_count,
    SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
    SUM(trx_summ.op_chargeback_count) op_chargeback_count,
    SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
    SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
    SUM(trx_summ.disputed_inv_count) disputed_inv_count,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
    SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
    MAX(trx_summ.last_payment_date) last_payment_date,
    MAX(trx_summ.last_update_date) last_update_date,
    MAX(trx_summ.last_updated_by) last_updated_by,
    MAX(trx_summ.creation_date) creation_date,
    MAX(trx_summ.created_by) created_by,
    MAX(trx_summ.last_update_login) last_update_login
    FROM ar_trx_bal_summary trx_summ,
          GL_SETS_OF_BOOKS gl,
          AR_SYSTEM_PARAMETERS_all sys,
	   jtf_objects_b objb,
	    hz_cust_accounts acc,
	   hz_party_preferences party_pref
     where
        P_MODE = 'CP'
   AND trx_summ.reference_1 = '1'
    AND objb.object_code = 'IEX_BILLTO'
   and objb.object_code <> 'IEX_DELINQUENCY'
   and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
   and trx_summ.org_id = sys.org_id
   and trx_summ.org_id=nvl(c_org_id,trx_summ.org_id)
   and trx_summ.cust_account_id=acc.cust_account_id
   and trunc(trx_summ.last_update_date) >= trunc(p_from_date)
   and acc.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),c_level)='BILL_TO'
   and trx_summ.site_use_id > 0
   group by trx_summ.org_id,
    objb.object_function,
    objb.object_parameters,
    trx_summ.cust_account_id,
    trx_summ.site_use_id;


    cursor c_billto_deln_cnt_dt
    is
    SELECT a.customer_site_use_id,
    count(a.delinquency_id) number_of_delinquencies,
    SUM(b.acctd_amount_due_remaining) past_due_inv_value
   FROM iex_delinquencies_all a,
        ar_payment_schedules_all b,
        iex_dln_uwq_summary dln
   WHERE a.customer_site_use_id =dln.site_use_id
    AND a.payment_schedule_id = b.payment_schedule_id
    AND b.status = 'OP'
    AND a.status IN('DELINQUENT',   'PREDELINQUENT')
    AND dln.org_id = a.org_id
    AND TRUNC(dln.LAST_UPDATE_DATE)=trunc(sysdate)
   GROUP BY a.customer_site_use_id;



   cursor c_billto_deln_dtls_dt
   is
   select del.CUSTOMER_SITE_USE_ID,
    max(decode(uwq_status,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_delinquencies,
    max(decode(uwq_status,'COMPLETE',(decode(sign(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_delinquencies,
    max(decode(uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_delinquencies
    from iex_delinquencies_all del,
      iex_dln_uwq_summary dln
    WHERE del.customer_site_use_id = dln.site_use_id  AND
    del.org_id = dln.org_id and
    del.status IN('DELINQUENT',    'PREDELINQUENT')
    AND TRUNC(dln.LAST_UPDATE_DATE)=trunc(sysdate)
    group by del.CUSTOMER_SITE_USE_ID;



cursor c_billto_pro_dtls_dt is
   SELECT del.customer_site_use_id,
	COUNT(1) number_of_promises,
	SUM(pd.amount_due_remaining) broken_promise_amount,
	SUM(pd.promise_amount) promise_amount
   FROM iex_promise_details pd,
         iex_delinquencies_all del,
         iex_dln_uwq_summary dln
   WHERE pd.cust_account_id = del.cust_account_id
     AND pd.delinquency_id = del.delinquency_id
     AND pd.status IN('COLLECTABLE',   'PENDING')
     AND pd.state = 'BROKEN_PROMISE'
     AND pd.amount_due_remaining > 0
     AND (del.status NOT IN('CURRENT',   'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))
     and del.customer_site_use_id = dln.site_use_id
     and del.org_id = dln.org_id
     and TRUNC(dln.LAST_UPDATE_DATE)=TRUNC(sysdate)
   GROUP BY del.customer_site_use_id;

    cursor c_billto_pro_summ_dt is
    select del.CUSTOMER_SITE_USE_ID,
    max(decode(pd.uwq_status,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_promises,
    max(decode(pd.uwq_status,'COMPLETE',(decode(sign(TRUNC(pd.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_promises,
    max(decode(pd.uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_promises
    from iex_promise_details pd,
    IEX_DELINQUENCIES_ALL DEL,
    iex_dln_uwq_summary dln
    WHERE pd.cust_account_id = del.cust_account_id
      and pd.delinquency_id = del.delinquency_id
      and del.customer_site_use_id = dln.site_use_id
      and del.org_id = dln.org_id
      and pd.state = 'BROKEN_PROMISE'
       AND TRUNC(dln.LAST_UPDATE_DATE)=TRUNC(sysdate)
     group by del.CUSTOMER_SITE_USE_ID;


   CURSOR c_billto_site_details_dt IS
    SELECT
    party.party_id party_id,
    party.party_name party_name,
    summ.cust_account_id cust_account_id,
    acc.account_name account_name,
    acc.account_number account_number,
    summ.site_use_id site_use_id,
    site_uses.location location,
    loc.address1 address1,
    loc.city city,
    loc.state state,
    loc.county county,
    fnd_terr.territory_short_name country,
    loc.province province,
    loc.postal_code postal_code
  FROM iex_dln_uwq_summary summ,
    hz_cust_accounts acc,
    hz_parties party,
    hz_party_preferences party_pref,
    fnd_territories_tl fnd_terr,
    hz_cust_site_uses_all site_uses,
    hz_cust_acct_sites_all acct_site,
    hz_party_sites party_site,
    hz_locations loc
  WHERE
   party_site.location_id = loc.location_id
   and acct_site.party_site_id = party_site.party_site_id
   and site_uses.cust_acct_site_id = acct_site.cust_acct_site_id
   AND summ.site_use_id = site_uses.site_use_id
   AND summ.cust_account_id = acc.cust_account_id
   AND acc.party_id = party.party_id
   AND loc.country = fnd_terr.territory_code(+)
   AND trunc(summ.LAST_UPDATE_DATE) = trunc(sysdate)
   AND fnd_terr.LANGUAGE(+) = userenv('LANG')
   and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   GROUP BY party.party_id,
    party.party_name,
    summ.cust_account_id,
    acc.account_name,
    acc.account_number,
    summ.site_use_id,
    site_uses.location,
    loc.address1,
    loc.city,
    loc.state,
    loc.county,
    fnd_terr.territory_short_name,
    loc.province,
    loc.postal_code;


     CURSOR C_billto_CONTACT_POINT_dt IS
      SELECT summ.party_id,
	phone.phone_country_code phone_country_code,
	phone.phone_area_code phone_area_code,
	phone.phone_number phone_number,
	phone.phone_extension phone_extension
	FROM iex_dln_uwq_summary summ,
		hz_contact_points phone
	WHERE
	   phone.owner_table_id = summ.party_id
	   AND phone.owner_table_name = 'HZ_PARTIES'
	   AND phone.contact_point_type = 'PHONE'
	   AND phone.primary_by_purpose = 'Y'
	   AND phone.contact_point_purpose = 'COLLECTIONS'
	   AND phone.phone_line_type NOT IN('PAGER',   'FAX')
	   AND phone.status = 'A'
	   AND nvl(phone.do_not_use_flag,   'N') = 'N'
	   AND trunc(summ.LAST_UPDATE_DATE) = trunc(sysdate)
	   group by summ.party_id,
	    phone.phone_country_code,
	    phone.phone_area_code,
	    phone.phone_number,
	    phone.phone_extension;

     cursor C_BILLTO_COLLECTOR_PROF_dt is
       SELECT
       hp.collector_id collector_id,
       ac.resource_id collector_resource_id,
        ac.resource_type COLLECTOR_RES_TYPE,
	decode(ac.resource_type, 'RS_RESOURCE' , rs.source_name , rg.group_name)   collector_resource_name,
        1 resource_id,
        'RS_EMPLOYEE' resource_type,
	 hp.party_id,
	 hp.cust_account_id,
	 hp.site_use_id
      FROM
         hz_customer_profiles hp,
	 ar_collectors ac,
	 iex_dln_uwq_summary temp,
	 JTF_RS_GROUPS_VL rg,
         jtf_rs_resource_extns rs
      WHERE
         hp.site_use_id=temp.site_use_id
	 and hp.collector_id=ac.collector_id
	 and rg.group_id (+) = ac.resource_id
         and rs.resource_id(+) = ac.resource_id
	 AND trunc(temp.LAST_UPDATE_DATE) = trunc(sysdate);

     CURSOR c_billto_ch_coll_dt_sum IS
      SELECT
        DISTINCT
        ac.resource_id collector_resource_id,
	ac.resource_type COLLECTOR_RES_TYPE,
	ac.collector_id collector_id,
	hp.site_use_id
      FROM
        ar_collectors ac,
	hz_customer_profiles hp,
	iex_dln_uwq_summary ids
      WHERE
         hp.site_use_id=ids.site_use_id
         and ac.collector_id = hp.collector_id
	 AND ac.resource_id is NOT NULL
	 AND ac.resource_id <> ids.collector_resource_id
	 AND trunc(ids.last_update_date)= TRUNC(SYSDATE);

   cursor c_billto_last_payment_dtls_dt is
   select summ.site_use_id,
         summ.last_payment_amount last_payment_amount,
	 summ.currency last_payment_currency,
	 summ.last_payment_number last_payment_number
   from ar_trx_bal_summary summ,
    gl_sets_of_books gl,
    ar_system_parameters_all sys
   where summ.reference_1='1'
   and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
   and summ.org_id = sys.org_id
   and summ.last_payment_date=(select max(summ1.last_payment_date)
	from iex_dln_uwq_summary summ1
	where summ1.site_use_id=summ.site_use_id
	and trunc(summ1.last_update_date)=trunc(sysdate));


  cursor c_billto_bankruptcies_dt is
   select summ.party_id,
   COUNT(1) number_of_bankruptcies
   FROM iex_bankruptcies bkr,
   iex_dln_uwq_summary summ
   where bkr.customer_site_use_id=summ.site_use_id
   and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')
    AND trunc(summ.last_update_date)=trunc(sysdate)
   group by summ.party_id;

   cursor c_billto_score_dt is
    SELECT sh.score_object_id,
    sh.score_value score,
    sc.score_id,
    sc.score_name
   FROM iex_score_histories sh,iex_scores sc
   WHERE sc.score_id = sh.score_id
   and (sh.score_object_id,sh.score_object_code,sh.creation_date)
      in (SELECT sh1.score_object_id,sh1.score_object_code,MAX(sh1.creation_date)
          FROM iex_score_histories sh1,
          iex_dln_uwq_summary temp
	WHERE sh1.score_object_code = 'IEX_BILLTO'
   AND sh1.score_object_id = temp.site_use_id
   AND trunc(temp.LAST_UPDATE_DATE) = trunc(sysdate)
	group by sh1.score_object_id,sh1.score_object_code);

--End Bug 9597052 28-Apr-2010 barathsr

-------------------------------
--Start of comment for Bug 9597052 28-Apr-2010 barathsr
 /* CURSOR c_iex_acc_uwq_summary(c_level varchar2,c_org_id number) --Added for Bug 8707923 27-Jul-2009 barathsr
  IS
    SELECT
      trx_summ.org_id,
      max(ac.collector_id),
      max(ac.resource_id),
      max(ac.resource_type),
      objb.object_function ieu_object_function,
      objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
      '' ieu_media_type_uuid,
      'CUST_ACCOUNT_ID' ieu_param_pk_col,
      to_char(trx_summ.cust_account_id) ieu_param_pk_value,
      1 resource_id,
      'RS_EMPLOYEE' resource_type,
      party.party_id party_id,
      party.party_name party_name,
      trx_summ.cust_account_id cust_account_id,
      acc.account_name account_name,
      acc.account_number account_number,
      to_number(null) site_use_id,
      null location,
      max(gl.CURRENCY_CODE) currency,
      SUM(trx_summ.op_invoices_count) op_invoices_count,
      SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
      SUM(trx_summ.op_deposits_count) op_deposits_count,
      SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
      SUM(trx_summ.op_chargeback_count) op_chargeback_count,
      SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
      SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
      SUM(trx_summ.disputed_inv_count) disputed_inv_count,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
        (SELECT SUM(b.acctd_amount_due_remaining)
       FROM iex_delinquencies_all a,
         ar_payment_schedules_all b
       WHERE a.cust_account_id = trx_summ.cust_account_id
       AND a.payment_schedule_id = b.payment_schedule_id
       AND b.status = 'OP'
       AND a.status IN('DELINQUENT',    'PREDELINQUENT')
       AND b.org_id = trx_summ.org_id) past_due_inv_value,
      SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
      MAX(trx_summ.last_payment_date) last_payment_date,
      MAX(iex_uwq_view_pkg.get_last_payment_amount(0,   trx_summ.cust_account_id,   0)) last_payment_amount,
      max(gl.CURRENCY_CODE) last_payment_amount_curr,
      MAX(iex_uwq_view_pkg.get_last_payment_number(0,   trx_summ.cust_account_id,   0)) last_payment_number,
      MAX(trx_summ.last_update_date) last_update_date,
      MAX(trx_summ.last_updated_by) last_updated_by,
      MAX(trx_summ.creation_date) creation_date,
      MAX(trx_summ.created_by) created_by,
      MAX(trx_summ.last_update_login) last_update_login,
        (SELECT COUNT(1)
       FROM iex_delinquencies_all
       WHERE cust_account_id = trx_summ.cust_account_id
       AND status IN('DELINQUENT',    'PREDELINQUENT')
       AND org_id = trx_summ.org_id)
    number_of_delinquencies,
        (SELECT 1
       FROM dual
       WHERE EXISTS
        (SELECT 1
         FROM iex_delinquencies_all
         WHERE cust_account_id = trx_summ.cust_account_id
         AND status IN('DELINQUENT',    'PREDELINQUENT')
	 AND org_id = trx_summ.org_id
         AND(uwq_status IS NULL OR uwq_status = 'ACTIVE' OR(TRUNC(uwq_active_date) <= TRUNC(sysdate)
         AND uwq_status = 'PENDING')))
      )
    active_delinquencies,
        (SELECT 1
       FROM dual
       WHERE EXISTS
        (SELECT 1
         FROM iex_delinquencies_all
         WHERE cust_account_id = trx_summ.cust_account_id
         AND status IN('DELINQUENT',    'PREDELINQUENT')
	 AND org_id = trx_summ.org_id
         AND(uwq_status = 'COMPLETE'
         AND(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
      )
    complete_delinquencies,
        (SELECT 1
       FROM dual
       WHERE EXISTS
        (SELECT 1
         FROM iex_delinquencies_all  WHERE cust_account_id = trx_summ.cust_account_id
         AND status IN('DELINQUENT',    'PREDELINQUENT')
	 AND org_id = trx_summ.org_id
         AND(uwq_status = 'PENDING'
         AND(TRUNC(uwq_active_date) > TRUNC(sysdate))))
      )
    pending_delinquencies,

     -- Start for the bug#7562130 by PNAVEENK
/*      (SELECT a.score_value
       FROM iex_score_histories a
       WHERE a.creation_date =
        (SELECT MAX(creation_date)
         FROM iex_score_histories
         WHERE score_object_code = 'IEX_ACCOUNT'
         AND score_object_id = trx_summ.cust_account_id)
      AND rownum < 2
       AND a.score_object_code = 'IEX_ACCOUNT'
       AND a.score_object_id = trx_summ.cust_account_id)
    score,*/
   /* to_number(cal_score(trx_summ.cust_account_id,'IEX_ACCOUNT','SCORE_VALUE')) score,
    to_number(cal_score(trx_summ.cust_account_id,'IEX_ACCOUNT','SCORE_ID')) score_id,
    cal_score(trx_summ.cust_account_id,'IEX_ACCOUNT','SCORE_NAME') score_name,
    max(decode(ac.resource_type, 'RS_RESOURCE' ,
          (select rs.source_name from jtf_rs_resource_extns rs where rs.resource_id= ac.resource_id),
          (select rg.group_name from JTF_RS_GROUPS_VL rg where rg.group_id=ac.resource_id)
          ) )  collector_resource_name,
   -- end for the bug#7562130
      party.address1 address1,
      party.city city,
      party.state state,
      party.county county,
      fnd_terr.territory_short_name country,
      party.province province,
      party.postal_code postal_code,
      phone.phone_country_code phone_country_code,
      phone.phone_area_code phone_area_code,
      phone.phone_number phone_number,
      phone.phone_extension phone_extension,
        (SELECT COUNT(1) FROM iex_bankruptcies bkr  WHERE bkr.party_id = party.party_id and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')) number_of_bankruptcies,  -- Changed for bug#7693986

      (SELECT COUNT(1) FROM iex_promise_details PRO, IEX_DELINQUENCIES_all DEL
       WHERE PRO.CUST_ACCOUNT_ID = TRX_SUMM.CUST_ACCOUNT_ID AND
       PRO.STATUS IN ('COLLECTABLE', 'PENDING') AND PRO.STATE = 'BROKEN_PROMISE' AND PRO.AMOUNT_DUE_REMAINING > 0 AND
       PRO.DELINQUENCY_ID = DEL.DELINQUENCY_ID(+)
       AND (DEL.STATUS --(+) Commented for Bug 6446848 06-Jan-2009 barathsr
       NOT IN ('CURRENT', 'CLOSE')
       or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 06-Jan-2009 barathsr
       AND DEL.org_id = trx_summ.org_id) NUMBER_OF_PROMISES ,

       (SELECT SUM(AMOUNT_DUE_REMAINING) FROM IEX_PROMISE_DETAILS PRO, IEX_DELINQUENCIES_all DEL
       WHERE PRO.CUST_ACCOUNT_ID = TRX_SUMM.CUST_ACCOUNT_ID AND
       PRO.STATUS IN ('COLLECTABLE', 'PENDING') AND PRO.STATE = 'BROKEN_PROMISE' AND PRO.AMOUNT_DUE_REMAINING > 0 AND
       PRO.DELINQUENCY_ID = DEL.DELINQUENCY_ID(+)
       AND (DEL.STATUS --(+) Commented for Bug 6446848 06-Jan-2009 barathsr
       NOT IN ('CURRENT', 'CLOSE')
       or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 06-Jan-2009 barathsr
       AND DEL.org_id = trx_summ.org_id) BROKEN_PROMISE_AMOUNT ,

       (SELECT SUM(PROMISE_AMOUNT) FROM IEX_PROMISE_DETAILS PRO, IEX_DELINQUENCIES_all DEL
       WHERE PRO.CUST_ACCOUNT_ID = TRX_SUMM.CUST_ACCOUNT_ID AND
       PRO.STATUS IN ('COLLECTABLE', 'PENDING') AND PRO.STATE = 'BROKEN_PROMISE' AND PRO.AMOUNT_DUE_REMAINING > 0 AND
       PRO.DELINQUENCY_ID = DEL.DELINQUENCY_ID(+)
       AND (DEL.STATUS --(+) Commented for Bug 6446848 06-Jan-2009 barathsr
       NOT IN ('CURRENT', 'CLOSE')
       or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 06-Jan-2009 barathsr
       AND DEL.org_id = trx_summ.org_id) PROMISE_AMOUNT,

        (SELECT 1 FROM dual WHERE EXISTS
          (SELECT 1 FROM dual WHERE EXISTS
            (SELECT 1
             FROM iex_promise_details
             WHERE cust_account_id = trx_summ.cust_account_id
             AND state = 'BROKEN_PROMISE'
             AND(uwq_status IS NULL OR uwq_status = 'ACTIVE' OR(TRUNC(uwq_active_date) <= TRUNC(sysdate)
             AND uwq_status = 'PENDING')))
          )
        ) active_promises,

        (SELECT 1 FROM dual WHERE EXISTS
          (SELECT 1 FROM dual WHERE EXISTS
            (SELECT 1
             FROM iex_promise_details
             WHERE cust_account_id = trx_summ.cust_account_id
             AND state = 'BROKEN_PROMISE'
             AND(uwq_status = 'COMPLETE'
             AND(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
          )
        ) complete_promises,

        (SELECT 1 FROM dual WHERE EXISTS
          (SELECT 1 FROM dual WHERE EXISTS
            (SELECT 1
             FROM iex_promise_details
             WHERE cust_account_id = trx_summ.cust_account_id
             AND state = 'BROKEN_PROMISE'
             AND(uwq_status = 'PENDING'
             AND(TRUNC(uwq_active_date) > TRUNC(sysdate))))
          )
        ) pending_promises

    FROM ar_trx_bal_summary trx_summ,
      hz_cust_accounts acc,
      hz_parties party,
      hz_party_preferences party_pref,--Added for Bug 8707923 27-Jul-2009 barathsr
      jtf_objects_b objb,
      hz_contact_points phone,
      fnd_territories_tl fnd_terr,
      hz_customer_profiles prf,
      ar_collectors ac,
      GL_SETS_OF_BOOKS gl,
      AR_SYSTEM_PARAMETERS_all sys
    WHERE
     P_MODE = 'CP'
     AND   trx_summ.reference_1 = '1'
     AND trx_summ.cust_account_id = acc.cust_account_id
     AND acc.party_id = party.party_id
     AND objb.object_code = 'IEX_ACCOUNT'
     and objb.object_code <> 'IEX_DELINQUENCY'--Added for Bug 8707923 27-Jul-2009 barathsr
     AND party.country = fnd_terr.territory_code(+)
     AND fnd_terr.LANGUAGE(+) = userenv('LANG')
     AND phone.owner_table_id(+) = party.party_id
     AND phone.owner_table_name(+) = 'HZ_PARTIES'
     AND phone.contact_point_type(+) = 'PHONE'
     AND phone.primary_by_purpose(+) = 'Y'
     AND phone.contact_point_purpose(+) = 'COLLECTIONS'
     AND phone.phone_line_type(+) NOT IN('PAGER',   'FAX')
     AND phone.status(+) = 'A'
     AND nvl(phone.do_not_use_flag(+),   'N') = 'N'
     and prf.CUST_ACCOUNT_ID = trx_summ.CUST_ACCOUNT_ID
     and prf.SITE_USE_ID is null
     and ac.collector_id(+) = prf.collector_id
     and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
     and trx_summ.org_id = sys.org_id
     --Begin Bug 8707923  27-Jul-2009 barathsr
     and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),c_level)='ACCOUNT'
   and trx_summ.org_id=nvl(c_org_id,trx_summ.org_id)
   --End Bug 8707923  27-Jul-2009 barathsr
    GROUP BY  trx_summ.org_id,
      objb.object_function,
      objb.object_parameters,
      party.party_id,
      party.party_name,
      trx_summ.cust_account_id,
      acc.account_name,
      acc.account_number,
      party.address1,
      party.city,
      party.state,
      party.county,
      fnd_terr.territory_short_name,
      party.province,
      party.postal_code,
      phone.phone_country_code,
      phone.phone_area_code,
      phone.phone_number,
      phone.phone_extension;*/
      --End of comment for Bug 9597052 28-Apr-2010 barathsr

    --Begin Bug 9597052 28-Apr-2010 barathsr
    --This cursor fetches column values from ar_trx_bal_summary table and the values are inserted in iex_dln_uwq_summary at Account level
    --All the other column values are fetched with small cursors from the respective tables and updated in iex_dln_uwq_summary

      CURSOR c_iex_acc_uwq_summary(c_level varchar2,c_org_id number) --Added for Bug 8707923 27-Jul-2009 barathsr
    IS
    SELECT
      trx_summ.org_id,
      objb.object_function ieu_object_function,
      objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
      '' ieu_media_type_uuid,
      'CUST_ACCOUNT_ID' ieu_param_pk_col,
      to_char(trx_summ.cust_account_id) ieu_param_pk_value,
      to_number(null) party_id,
      trx_summ.cust_account_id cust_account_id,
      to_number(null) site_use_id,
      max(gl.CURRENCY_CODE) currency,
      SUM(trx_summ.op_invoices_count) op_invoices_count,
      SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
      SUM(trx_summ.op_deposits_count) op_deposits_count,
      SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
      SUM(trx_summ.op_chargeback_count) op_chargeback_count,
      SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
      SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
      SUM(trx_summ.disputed_inv_count) disputed_inv_count,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
      SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
      MAX(trx_summ.last_payment_date) last_payment_date,
      MAX(trx_summ.last_update_date) last_update_date,
      MAX(trx_summ.last_updated_by) last_updated_by,
      MAX(trx_summ.creation_date) creation_date,
      MAX(trx_summ.created_by) created_by,
      MAX(trx_summ.last_update_login) last_update_login
       FROM ar_trx_bal_summary trx_summ,
      hz_cust_accounts acc,
      hz_party_preferences party_pref,--Added for Bug 8707923 27-Jul-2009 barathsr
      jtf_objects_b objb,
      GL_SETS_OF_BOOKS gl,
      AR_SYSTEM_PARAMETERS_all sys
    WHERE
     P_MODE = 'CP'
     AND   trx_summ.reference_1 = '1'
     AND trx_summ.cust_account_id = acc.cust_account_id
--     and trx_summ.site_use_id is null
     AND objb.object_code = 'IEX_ACCOUNT'
     and objb.object_code <> 'IEX_DELINQUENCY'--Added for Bug 8707923 27-Jul-2009 barathsr
     and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
     and trx_summ.org_id = sys.org_id
     --Begin Bug 8707923  27-Jul-2009 barathsr
     and acc.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),c_level)='ACCOUNT'
   and trx_summ.org_id=nvl(c_org_id,trx_summ.org_id)
   --End Bug 8707923  27-Jul-2009 barathsr
    GROUP BY  trx_summ.org_id,
      objb.object_function,
      objb.object_parameters,
      trx_summ.cust_account_id;


   cursor c_acc_deln_cnt is
    SELECT a.cust_account_id,dln.org_id,
    count(a.delinquency_id) number_of_delinquencies,
    SUM(b.acctd_amount_due_remaining) past_due_inv_value
   FROM iex_delinquencies_all a,
        ar_payment_schedules_all b,
        iex_dln_uwq_summary dln
   WHERE a.cust_account_id =dln.cust_account_id
    AND a.payment_schedule_id = b.payment_schedule_id
    AND b.status = 'OP'
    AND a.status IN('DELINQUENT',   'PREDELINQUENT')
    AND dln.org_id = a.org_id
    and dln.site_use_id is null
   GROUP BY a.cust_account_id,dln.org_id;

    cursor c_acc_deln_dtls
   is
   select del.cust_account_ID,dln.org_id,
    max(decode(uwq_status,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_delinquencies,
    max(decode(uwq_status,'COMPLETE',(decode(sign(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_delinquencies,
    max(decode(uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_delinquencies
    from iex_delinquencies_all del,
      iex_dln_uwq_summary dln
    WHERE del.cust_account_id = dln.cust_account_id  AND
    del.org_id = dln.org_id and
    del.status IN('DELINQUENT',    'PREDELINQUENT')
    group by del.Cust_account_id,dln.org_id;

   cursor c_acc_pro_dtls is
   SELECT del.cust_account_id,dln.org_id,
	COUNT(1) number_of_promises,
	SUM(pd.amount_due_remaining) broken_promise_amount,
	SUM(pd.promise_amount) promise_amount
   FROM iex_promise_details pd,
         iex_delinquencies_all del,
         iex_dln_uwq_summary dln
   WHERE dln.cust_account_id = del.cust_account_id
     AND pd.delinquency_id = del.delinquency_id
     AND pd.status IN('COLLECTABLE',   'PENDING')
     AND pd.state = 'BROKEN_PROMISE'
     AND pd.amount_due_remaining > 0
     AND (del.status NOT IN('CURRENT',   'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))
     and dln.site_use_id is null
     and del.org_id = dln.org_id
   GROUP BY del.cust_account_id,dln.org_id;

   cursor c_acc_pro_summ is
    select del.CUST_Account_ID,dln.org_id,
    max(decode(pd.uwq_status,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_promises,
    max(decode(pd.uwq_status,'COMPLETE',(decode(sign(TRUNC(pd.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_promises,
    max(decode(pd.uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_promises
    from iex_promise_details pd,
    IEX_DELINQUENCIES_ALL DEL,
    iex_dln_uwq_summary dln
    WHERE dln.cust_account_id = del.cust_account_id
      and pd.delinquency_id = del.delinquency_id
      and dln.site_use_id is null
      and del.org_id = dln.org_id
      and pd.state = 'BROKEN_PROMISE'
     group by del.CUST_account_ID,dln.org_id;


CURSOR c_acct_details IS
    SELECT
    party.party_id party_id,summ.org_id,
    party.party_name party_name,
    summ.cust_account_id cust_account_id,
    acc.account_name account_name,
    acc.account_number account_number,
    null location,
    party.address1 address1,
    party.city city,
    party.state state,
    party.county county,
    fnd_terr.territory_short_name country,
    party.province province,
    party.postal_code postal_code
  FROM iex_dln_uwq_summary summ,
    hz_cust_accounts acc,
    hz_parties party,
    hz_party_preferences party_pref,
    fnd_territories_tl fnd_terr
  WHERE
       summ.cust_account_id = acc.cust_account_id
   AND acc.party_id = party.party_id
   AND party.country = fnd_terr.territory_code(+)
   AND fnd_terr.LANGUAGE(+) = userenv('LANG')
   and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and summ.site_use_id is null
   GROUP BY party.party_id,
    party.party_name,
    summ.cust_account_id,
    acc.account_name,
    acc.account_number,
    party.address1,
    party.city,
    party.state,
    party.county,
    fnd_terr.territory_short_name,
    party.province,
    party.postal_code,
    summ.org_id;


    CURSOR C_acc_CONTACT_POINT IS
      SELECT summ.party_id,summ.org_id,
	phone.phone_country_code phone_country_code,
	phone.phone_area_code phone_area_code,
	phone.phone_number phone_number,
	phone.phone_extension phone_extension
  FROM iex_dln_uwq_summary summ,
	hz_contact_points phone
  WHERE
      phone.owner_table_id(+) = summ.party_id
     AND phone.owner_table_name(+) = 'HZ_PARTIES'
     AND phone.contact_point_type(+) = 'PHONE'
     AND phone.primary_by_purpose(+) = 'Y'
     AND phone.contact_point_purpose(+) = 'COLLECTIONS'
     AND phone.phone_line_type(+) NOT IN('PAGER',   'FAX')
     AND phone.status(+) = 'A'
     AND nvl(phone.do_not_use_flag(+),   'N') = 'N'
   and summ.site_use_id is null
   group by summ.party_id,
    phone.phone_country_code,
    phone.phone_area_code,
    phone.phone_number,
    phone.phone_extension,
    summ.org_id;


    CURSOR C_acc_COLLECTOR_prof IS
      SELECT
       hp.collector_id collector_id,temp.org_id,
       ac.resource_id collector_resource_id,
        ac.resource_type COLLECTOR_RES_TYPE,
	decode(ac.resource_type, 'RS_RESOURCE' , rs.source_name , rg.group_name)   collector_resource_name,
        1 resource_id,
        'RS_EMPLOYEE' resource_type,
	 hp.party_id,
	 hp.cust_account_id
       FROM
         hz_customer_profiles hp,
	 ar_collectors ac,
	 iex_dln_uwq_summary temp,
	 JTF_RS_GROUPS_VL rg,
         jtf_rs_resource_extns rs
      WHERE
         hp.CUST_ACCOUNT_ID = temp.CUST_ACCOUNT_ID
	 and  ac.collector_id(+) = hp.collector_id
	 and rg.group_id(+)  = ac.resource_id
         and rs.resource_id(+) = ac.resource_id
	 and hp.site_use_id is null
	 and temp.site_use_id is null;

   cursor c_acc_last_payment_dtls is
   select summ.cust_account_id,summ.org_id,
         summ.last_payment_amount last_payment_amount,
	 summ.currency last_payment_currency,
	 summ.last_payment_number last_payment_number
   from ar_trx_bal_summary summ,
    gl_sets_of_books gl,
    ar_system_parameters_all sys
   where gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
   and summ.org_id = sys.org_id
   and summ.last_payment_date=(select max(dln.last_payment_date)
	from iex_dln_uwq_summary dln
	where dln.cust_account_id=summ.cust_account_id
	and dln.org_id=summ.org_id
	and dln.site_use_id is null);


  cursor c_acc_bankruptcies is
   select summ.party_id,summ.org_id,
   COUNT(1) number_of_bankruptcies
   FROM iex_bankruptcies bkr,
   iex_dln_uwq_summary summ
   where bkr.cust_account_id=summ.cust_account_id
   and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')
   group by summ.party_id,summ.org_id;

   cursor c_acc_score is
    SELECT sh.score_object_id,
    sh.score_value score,
    sc.score_id,
    sc.score_name
   FROM iex_score_histories sh,iex_scores sc
   WHERE sc.score_id = sh.score_id
   and sh.score_object_code = 'IEX_ACCOUNT'
   and (sh.score_object_id,sh.score_object_code,sh.creation_date)
      in (SELECT sh1.score_object_id,sh1.score_object_code,MAX(sh1.creation_date)
          FROM iex_score_histories sh1,
          iex_dln_uwq_summary temp
	WHERE sh1.score_object_code = 'IEX_ACCOUNT'
         AND sh1.score_object_id = temp.cust_account_id
	 and temp.site_use_id is null
	group by sh1.score_object_id,sh1.score_object_code);

  --End Bug 9597052 28-Apr-2010 barathsr

    --Start of comment for  Bug 9597052 28-Apr-2010 barathsr
    -- Begin - Andre Araujo - 10/20/06 - Added selection using date
  /*CURSOR c_iex_acc_uwq_dt_sum(p_from_date date,c_level varchar2,c_org_id number)--Added for Bug 8707923 27-Jul-2009 barathsr
  IS
    SELECT
      trx_summ.org_id,
      max(ac.collector_id),
      max(ac.resource_id),
      max(ac.resource_type),
      objb.object_function ieu_object_function,
      objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
      '' ieu_media_type_uuid,
      'CUST_ACCOUNT_ID' ieu_param_pk_col,
      to_char(trx_summ.cust_account_id) ieu_param_pk_value,
      1 resource_id,
      'RS_EMPLOYEE' resource_type,
      party.party_id party_id,
      party.party_name party_name,
      trx_summ.cust_account_id cust_account_id,
      acc.account_name account_name,
      acc.account_number account_number,
      to_number(null) site_use_id,
      null location,
      max(gl.CURRENCY_CODE) currency,
      SUM(trx_summ.op_invoices_count) op_invoices_count,
      SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
      SUM(trx_summ.op_deposits_count) op_deposits_count,
      SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
      SUM(trx_summ.op_chargeback_count) op_chargeback_count,
      SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
      SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
      SUM(trx_summ.disputed_inv_count) disputed_inv_count,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
        (SELECT SUM(b.acctd_amount_due_remaining)
       FROM iex_delinquencies_all a,
         ar_payment_schedules_all b
       WHERE a.cust_account_id = trx_summ.cust_account_id
       AND a.payment_schedule_id = b.payment_schedule_id
       AND b.status = 'OP'
       AND a.status IN('DELINQUENT',    'PREDELINQUENT')
       AND b.org_id = trx_summ.org_id) past_due_inv_value,
      SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
      MAX(trx_summ.last_payment_date) last_payment_date,
      MAX(iex_uwq_view_pkg.get_last_payment_amount(0,   trx_summ.cust_account_id,   0)) last_payment_amount,
      max(gl.CURRENCY_CODE) last_payment_amount_curr,
      MAX(iex_uwq_view_pkg.get_last_payment_number(0,   trx_summ.cust_account_id,   0)) last_payment_number,
      MAX(trx_summ.last_update_date) last_update_date,
      MAX(trx_summ.last_updated_by) last_updated_by,
      MAX(trx_summ.creation_date) creation_date,
      MAX(trx_summ.created_by) created_by,
      MAX(trx_summ.last_update_login) last_update_login,
        (SELECT COUNT(1)
       FROM iex_delinquencies_all
       WHERE cust_account_id = trx_summ.cust_account_id
       AND status IN('DELINQUENT',    'PREDELINQUENT')
       AND org_id = trx_summ.org_id)
    number_of_delinquencies,
        (SELECT 1
       FROM dual
       WHERE EXISTS
        (SELECT 1
         FROM iex_delinquencies_all
         WHERE cust_account_id = trx_summ.cust_account_id
         AND status IN('DELINQUENT',    'PREDELINQUENT')
	 AND org_id = trx_summ.org_id
         AND(uwq_status IS NULL OR uwq_status = 'ACTIVE' OR(TRUNC(uwq_active_date) <= TRUNC(sysdate)
         AND uwq_status = 'PENDING')))
      )
    active_delinquencies,
        (SELECT 1
       FROM dual
       WHERE EXISTS
        (SELECT 1
         FROM iex_delinquencies_all
         WHERE cust_account_id = trx_summ.cust_account_id
         AND status IN('DELINQUENT',    'PREDELINQUENT')
	 AND org_id = trx_summ.org_id
         AND(uwq_status = 'COMPLETE'
         AND(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
      )
    complete_delinquencies,
        (SELECT 1
       FROM dual
       WHERE EXISTS
        (SELECT 1
         FROM iex_delinquencies_all  WHERE cust_account_id = trx_summ.cust_account_id
         AND status IN('DELINQUENT',    'PREDELINQUENT')
	 AND org_id = trx_summ.org_id
         AND(uwq_status = 'PENDING'
         AND(TRUNC(uwq_active_date) > TRUNC(sysdate))))
      )
    pending_delinquencies,
        -- Start for the bug#7562130 by PNAVEENK
/*      (SELECT a.score_value
       FROM iex_score_histories a
       WHERE a.creation_date =
        (SELECT MAX(creation_date)
         FROM iex_score_histories
         WHERE score_object_code = 'IEX_ACCOUNT'
         AND score_object_id = trx_summ.cust_account_id)
      AND rownum < 2
       AND a.score_object_code = 'IEX_ACCOUNT'
       AND a.score_object_id = trx_summ.cust_account_id)
    score,*/
  /*  to_number(cal_score(trx_summ.cust_account_id,'IEX_ACCOUNT','SCORE_VALUE')) score,
    to_number(cal_score(trx_summ.cust_account_id,'IEX_ACCOUNT','SCORE_ID')) score_id,
    cal_score(trx_summ.cust_account_id,'IEX_ACCOUNT','SCORE_NAME') score_name,
    max(decode(ac.resource_type, 'RS_RESOURCE' ,
          (select rs.source_name from jtf_rs_resource_extns rs where rs.resource_id= ac.resource_id),
          (select rg.group_name from JTF_RS_GROUPS_VL rg where rg.group_id=ac.resource_id)
          ) )  collector_resource_name,
   -- end for the bug#7562130
      party.address1 address1,
      party.city city,
      party.state state,
      party.county county,
      fnd_terr.territory_short_name country,
      party.province province,
      party.postal_code postal_code,
      phone.phone_country_code phone_country_code,
      phone.phone_area_code phone_area_code,
      phone.phone_number phone_number,
      phone.phone_extension phone_extension,
         (SELECT COUNT(1) FROM iex_bankruptcies bkr  WHERE bkr.party_id = party.party_id and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')) number_of_bankruptcies,  -- Changed for bug#7693986

      (SELECT COUNT(1) FROM iex_promise_details PRO, IEX_DELINQUENCIES_all DEL
       WHERE PRO.CUST_ACCOUNT_ID = TRX_SUMM.CUST_ACCOUNT_ID AND
       PRO.STATUS IN ('COLLECTABLE', 'PENDING') AND PRO.STATE = 'BROKEN_PROMISE' AND PRO.AMOUNT_DUE_REMAINING > 0 AND
       PRO.DELINQUENCY_ID = DEL.DELINQUENCY_ID(+)
       AND (DEL.STATUS --(+) Commented for Bug 6446848 06-Jan-2009 barathsr
       NOT IN ('CURRENT', 'CLOSE')
       or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 06-Jan-2009 barathsr
       AND DEL.org_id = trx_summ.org_id) NUMBER_OF_PROMISES ,

       (SELECT SUM(AMOUNT_DUE_REMAINING) FROM IEX_PROMISE_DETAILS PRO, IEX_DELINQUENCIES_all DEL
       WHERE PRO.CUST_ACCOUNT_ID = TRX_SUMM.CUST_ACCOUNT_ID AND
       PRO.STATUS IN ('COLLECTABLE', 'PENDING') AND PRO.STATE = 'BROKEN_PROMISE' AND PRO.AMOUNT_DUE_REMAINING > 0 AND
       PRO.DELINQUENCY_ID = DEL.DELINQUENCY_ID(+)
       AND (DEL.STATUS --(+) Commented for Bug 6446848 06-Jan-2009 barathsr
       NOT IN ('CURRENT', 'CLOSE')
       or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 06-Jan-2009 barathsr
       AND DEL.org_id = trx_summ.org_id) BROKEN_PROMISE_AMOUNT ,

       (SELECT SUM(PROMISE_AMOUNT) FROM IEX_PROMISE_DETAILS PRO, IEX_DELINQUENCIES_all DEL
       WHERE PRO.CUST_ACCOUNT_ID = TRX_SUMM.CUST_ACCOUNT_ID AND
       PRO.STATUS IN ('COLLECTABLE', 'PENDING') AND PRO.STATE = 'BROKEN_PROMISE' AND PRO.AMOUNT_DUE_REMAINING > 0 AND
       PRO.DELINQUENCY_ID = DEL.DELINQUENCY_ID(+)
       AND (DEL.STATUS --(+) Commented for Bug 6446848 06-Jan-2009 barathsr
       NOT IN ('CURRENT', 'CLOSE')
       or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 06-Jan-2009 barathsr
       AND DEL.org_id = trx_summ.org_id) PROMISE_AMOUNT,

        (SELECT 1 FROM dual WHERE EXISTS
          (SELECT 1 FROM dual WHERE EXISTS
            (SELECT 1
             FROM iex_promise_details
             WHERE cust_account_id = trx_summ.cust_account_id
             AND state = 'BROKEN_PROMISE'
             AND(uwq_status IS NULL OR uwq_status = 'ACTIVE' OR(TRUNC(uwq_active_date) <= TRUNC(sysdate)
             AND uwq_status = 'PENDING')))
          )
        ) active_promises,

        (SELECT 1 FROM dual WHERE EXISTS
          (SELECT 1 FROM dual WHERE EXISTS
            (SELECT 1
             FROM iex_promise_details
             WHERE cust_account_id = trx_summ.cust_account_id
             AND state = 'BROKEN_PROMISE'
             AND(uwq_status = 'COMPLETE'
             AND(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
          )
        ) complete_promises,

        (SELECT 1 FROM dual WHERE EXISTS
          (SELECT 1 FROM dual WHERE EXISTS
            (SELECT 1
             FROM iex_promise_details
             WHERE cust_account_id = trx_summ.cust_account_id
             AND state = 'BROKEN_PROMISE'
             AND(uwq_status = 'PENDING'
             AND(TRUNC(uwq_active_date) > TRUNC(sysdate))))
          )
        ) pending_promises

    FROM ar_trx_bal_summary trx_summ,
      hz_cust_accounts acc,
      hz_parties party,
      hz_party_preferences party_pref,--Added for Bug 8707923 27-Jul-2009 barathsr
      jtf_objects_b objb,
      hz_contact_points phone,
      fnd_territories_tl fnd_terr,
      hz_customer_profiles prf,
      ar_collectors ac,
      GL_SETS_OF_BOOKS gl,
      AR_SYSTEM_PARAMETERS_all sys

    WHERE
     trx_summ.reference_1 = '1'
     AND trx_summ.cust_account_id = acc.cust_account_id
     AND acc.party_id = party.party_id
     AND objb.object_code = 'IEX_ACCOUNT'
      and objb.object_code <> 'IEX_DELINQUENCY'--Added for Bug 8707923 27-Jul-2009 barathsr
     AND party.country = fnd_terr.territory_code(+)
     AND fnd_terr.LANGUAGE(+) = userenv('LANG')
     AND phone.owner_table_id(+) = party.party_id
     AND phone.owner_table_name(+) = 'HZ_PARTIES'
     AND phone.contact_point_type(+) = 'PHONE'
     AND phone.primary_by_purpose(+) = 'Y'
     AND phone.contact_point_purpose(+) = 'COLLECTIONS'
     AND phone.phone_line_type(+) NOT IN('PAGER',   'FAX')
     AND phone.status(+) = 'A'
     AND nvl(phone.do_not_use_flag(+),   'N') = 'N'
     and prf.CUST_ACCOUNT_ID = trx_summ.CUST_ACCOUNT_ID
     and prf.SITE_USE_ID is null
     and ac.collector_id(+) = prf.collector_id
     and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
     and trx_summ.org_id = sys.org_id
     -- start bug 5762888 gnramasa 13-July-2007
     /* and (trx_summ.cust_account_id, trx_summ.site_use_id, trx_summ.org_id) in */
         /* changed for bug 5677415 by gnramasa on 27/11/2006 */
	 /* (select cust_account_id, site_use_id, org_id from ar_trx_bal_summary where trunc(LAST_UPDATE_DATE) >= trunc(sysdate)) */
 	 /* (select cust_account_id, site_use_id, org_id from ar_trx_bal_summary where trunc(LAST_UPDATE_DATE) >= trunc(p_from_date))  */
 --    and trunc(trx_summ.last_update_date) >= trunc(p_from_date)
   -- end bug 5762888 gnramasa 13-July-2007
   --Begin Bug 8707923 27-Jul-2009 barathsr
 /*  and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),c_level)='ACCOUNT'
   and trx_summ.org_id=nvl(c_org_id,trx_summ.org_id)
   --End Bug 8707923 27-Jul-2009 barathsr
    GROUP BY  trx_summ.org_id,
      objb.object_function,
      objb.object_parameters,
      party.party_id,
      party.party_name,
      trx_summ.cust_account_id,
      acc.account_name,
      acc.account_number,
      party.address1,
      party.city,
      party.state,
      party.county,
      fnd_terr.territory_short_name,
      party.province,
      party.postal_code,
      phone.phone_country_code,
      phone.phone_area_code,
      phone.phone_number,
      phone.phone_extension     ;*/

    -- End - Andre Araujo - 10/20/06 - Added selection using date
      --End of comment for Bug 9597052 28-Apr-2010 barathsr

     --Begin Bug 9597052 28-Apr-2010 barathsr
    --This cursor fetches column values from ar_trx_bal_summary table and the values are inserted in iex_dln_uwq_summary at Account level for a specified date range
    --All the other column values are fetched with small cursors from the respective tables and updated in iex_dln_uwq_summary


    CURSOR c_iex_acc_uwq_dt_sum(p_from_date date,c_level varchar2,c_org_id number)
    IS
    SELECT
      trx_summ.org_id,
      objb.object_function ieu_object_function,
      objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
      '' ieu_media_type_uuid,
      'CUST_ACCOUNT_ID' ieu_param_pk_col,
      to_char(trx_summ.cust_account_id) ieu_param_pk_value,
      to_number(null) party_id,
      trx_summ.cust_account_id cust_account_id,
      to_number(null) site_use_id,
      max(gl.CURRENCY_CODE) currency,
      SUM(trx_summ.op_invoices_count) op_invoices_count,
      SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
      SUM(trx_summ.op_deposits_count) op_deposits_count,
      SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
      SUM(trx_summ.op_chargeback_count) op_chargeback_count,
      SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
      SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
      SUM(trx_summ.disputed_inv_count) disputed_inv_count,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
      SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
       gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
       iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
      SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
      MAX(trx_summ.last_payment_date) last_payment_date,
      MAX(trx_summ.last_update_date) last_update_date,
      MAX(trx_summ.last_updated_by) last_updated_by,
      MAX(trx_summ.creation_date) creation_date,
      MAX(trx_summ.created_by) created_by,
      MAX(trx_summ.last_update_login) last_update_login
       FROM ar_trx_bal_summary trx_summ,
      hz_cust_accounts acc,
      hz_party_preferences party_pref,--Added for Bug 8707923 27-Jul-2009 barathsr
      jtf_objects_b objb,
      GL_SETS_OF_BOOKS gl,
      AR_SYSTEM_PARAMETERS_all sys
    WHERE
     P_MODE = 'CP'
     AND   trx_summ.reference_1 = '1'
     AND trx_summ.cust_account_id = acc.cust_account_id
--     and trx_summ.site_use_id is null
     AND objb.object_code = 'IEX_ACCOUNT'
     and objb.object_code <> 'IEX_DELINQUENCY'--Added for Bug 8707923 27-Jul-2009 barathsr
     and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
     and trx_summ.org_id = sys.org_id
     and trunc(trx_summ.last_update_date) >= trunc(p_from_date)
     --Begin Bug 8707923  27-Jul-2009 barathsr
     and acc.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),c_level)='ACCOUNT'
   and trx_summ.org_id=nvl(c_org_id,trx_summ.org_id)
   --End Bug 8707923  27-Jul-2009 barathsr
    GROUP BY  trx_summ.org_id,
      objb.object_function,
      objb.object_parameters,
      trx_summ.cust_account_id;

       cursor c_acc_deln_cnt_dt is
    SELECT a.cust_account_id,dln.org_id,
    count(a.delinquency_id) number_of_delinquencies,
    SUM(b.acctd_amount_due_remaining) past_due_inv_value
   FROM iex_delinquencies_all a,
        ar_payment_schedules_all b,
        iex_dln_uwq_summary dln
   WHERE a.cust_account_id =dln.cust_account_id
    AND a.payment_schedule_id = b.payment_schedule_id
    AND b.status = 'OP'
    AND a.status IN('DELINQUENT',   'PREDELINQUENT')
    AND dln.org_id = a.org_id
    and dln.site_use_id is null
   GROUP BY a.cust_account_id,dln.org_id;

    cursor c_acc_deln_dtls_dt
   is
   select del.cust_account_ID,dln.org_id,
    max(decode(uwq_status,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_delinquencies,
    max(decode(uwq_status,'COMPLETE',(decode(sign(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_delinquencies,
    max(decode(uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_delinquencies
    from iex_delinquencies_all del,
      iex_dln_uwq_summary dln
    WHERE del.cust_account_id = dln.cust_account_id
    AND     del.org_id = dln.org_id
    and     del.status IN('DELINQUENT',    'PREDELINQUENT')
    AND  trunc(dln.LAST_UPDATE_DATE) = trunc(sysdate)
    group by del.CUst_account_id,dln.org_id;

   cursor c_acc_pro_dtls_dt is
   SELECT del.cust_account_id,dln.org_id,
	COUNT(1) number_of_promises,
	SUM(pd.amount_due_remaining) broken_promise_amount,
	SUM(pd.promise_amount) promise_amount
   FROM iex_promise_details pd,
         iex_delinquencies_all del,
         iex_dln_uwq_summary dln
   WHERE dln.cust_account_id = del.cust_account_id
     AND pd.delinquency_id = del.delinquency_id
     AND pd.status IN('COLLECTABLE',   'PENDING')
     AND pd.state = 'BROKEN_PROMISE'
     AND pd.amount_due_remaining > 0
     AND (del.status NOT IN('CURRENT',   'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))
     and dln.site_use_id is null
     and del.org_id = dln.org_id
     AND  trunc(dln.LAST_UPDATE_DATE) = trunc(sysdate)
   GROUP BY del.cust_account_id,dln.org_id;

   cursor c_acc_pro_summ_dt is
    select del.CUST_Account_ID,dln.org_id,
    max(decode(pd.uwq_status,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_promises,
    max(decode(pd.uwq_status,'COMPLETE',(decode(sign(TRUNC(pd.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_promises,
    max(decode(pd.uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_promises
    from iex_promise_details pd,
    IEX_DELINQUENCIES_ALL DEL,
    iex_dln_uwq_summary dln
    WHERE dln.cust_account_id = del.cust_account_id
      and pd.delinquency_id = del.delinquency_id
      and dln.site_use_id is null
      and del.org_id = dln.org_id
      and pd.state = 'BROKEN_PROMISE'
      AND  trunc(dln.LAST_UPDATE_DATE) = trunc(sysdate)
     group by del.CUST_account_ID,dln.org_id;


CURSOR c_acct_details_dt IS
    SELECT
    party.party_id party_id,summ.org_id,
    party.party_name party_name,
    summ.cust_account_id cust_account_id,
    acc.account_name account_name,
    acc.account_number account_number,
    null location,
    party.address1 address1,
    party.city city,
    party.state state,
    party.county county,
    fnd_terr.territory_short_name country,
    party.province province,
    party.postal_code postal_code
  FROM iex_dln_uwq_summary summ,
    hz_cust_accounts acc,
    hz_parties party,
    hz_party_preferences party_pref,
    fnd_territories_tl fnd_terr
  WHERE
       summ.cust_account_id = acc.cust_account_id
   AND acc.party_id = party.party_id
   AND party.country = fnd_terr.territory_code(+)
   AND fnd_terr.LANGUAGE(+) = userenv('LANG')
   and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and summ.site_use_id is null
   AND  trunc(summ.LAST_UPDATE_DATE) = trunc(sysdate)
   GROUP BY party.party_id,
    party.party_name,
    summ.cust_account_id,
    acc.account_name,
    acc.account_number,
    party.address1,
    party.city,
    party.state,
    party.county,
    fnd_terr.territory_short_name,
    party.province,
    party.postal_code,
    summ.org_id;


    CURSOR C_acc_CONTACT_POINT_dt IS
      SELECT summ.party_id,summ.org_id,
	phone.phone_country_code phone_country_code,
	phone.phone_area_code phone_area_code,
	phone.phone_number phone_number,
	phone.phone_extension phone_extension
  FROM iex_dln_uwq_summary summ,
	hz_contact_points phone
  WHERE
      phone.owner_table_id(+) = summ.party_id
     AND phone.owner_table_name(+) = 'HZ_PARTIES'
     AND phone.contact_point_type(+) = 'PHONE'
     AND phone.primary_by_purpose(+) = 'Y'
     AND phone.contact_point_purpose(+) = 'COLLECTIONS'
     AND phone.phone_line_type(+) NOT IN('PAGER',   'FAX')
     AND phone.status(+) = 'A'
     AND nvl(phone.do_not_use_flag(+),   'N') = 'N'
     and summ.site_use_id is null
     AND  trunc(summ.LAST_UPDATE_DATE) = trunc(sysdate)
   group by summ.party_id,
    phone.phone_country_code,
    phone.phone_area_code,
    phone.phone_number,
    phone.phone_extension,
    summ.org_id;


    CURSOR C_acc_COLLECTOR_prof_dt IS
      SELECT
       hp.collector_id collector_id,temp.org_id,
       ac.resource_id collector_resource_id,
        ac.resource_type COLLECTOR_RES_TYPE,
	decode(ac.resource_type, 'RS_RESOURCE' , rs.source_name , rg.group_name)   collector_resource_name,
        1 resource_id,
        'RS_EMPLOYEE' resource_type,
	 hp.party_id,
	 hp.cust_account_id
       FROM
         hz_customer_profiles hp,
	 ar_collectors ac,
	 iex_dln_uwq_summary temp,
	 JTF_RS_GROUPS_VL rg,
         jtf_rs_resource_extns rs
      WHERE
         hp.CUST_ACCOUNT_ID = temp.CUST_ACCOUNT_ID
	 and  ac.collector_id(+) = hp.collector_id
	 and rg.group_id(+)  = ac.resource_id
         and rs.resource_id(+) = ac.resource_id
	 and hp.site_use_id is null
	 and temp.site_use_id is null
	 AND  trunc(temp.LAST_UPDATE_DATE) = trunc(sysdate);

	 CURSOR c_acc_ch_coll_dt_sum IS
      SELECT
        DISTINCT
        ac.resource_id collector_resource_id,ids.org_id,
	ac.resource_type COLLECTOR_RES_TYPE,
	ac.collector_id collector_id,
	hp.cust_account_id
	FROM
        ar_collectors ac,
	hz_customer_profiles hp,
	iex_dln_uwq_summary ids
      WHERE
         hp.cust_account_id=ids.cust_account_id
         and ac.collector_id(+) = hp.collector_id
	 AND ac.resource_id is NOT NULL
	 AND ac.resource_id <> ids.collector_resource_id
	 and hp.site_use_id is null
	 and ids.site_use_id is null
	 AND trunc(ids.last_update_date)= TRUNC(SYSDATE);

   cursor c_acc_last_payment_dtls_dt is
   select summ.cust_account_id,summ.org_id,
         summ.last_payment_amount last_payment_amount,
	 summ.currency last_payment_currency,
	 summ.last_payment_number last_payment_number
   from ar_trx_bal_summary summ,
    gl_sets_of_books gl,
    ar_system_parameters_all sys
   where gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
   and summ.org_id = sys.org_id
   and summ.last_payment_date=(select max(dln.last_payment_date)
	from iex_dln_uwq_summary dln
	where dln.cust_account_id=summ.cust_account_id
	and dln.org_id=summ.org_id
	and dln.site_use_id is null
	AND  trunc(dln.LAST_UPDATE_DATE) = trunc(sysdate));


  cursor c_acc_bankruptcies_dt is
   select summ.party_id,summ.org_id,
   COUNT(1) number_of_bankruptcies
   FROM iex_bankruptcies bkr,
   iex_dln_uwq_summary summ
   where bkr.cust_account_id=summ.cust_account_id
   and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')
   AND  trunc(summ.LAST_UPDATE_DATE) = trunc(sysdate)
   group by summ.party_id,summ.org_id;

   cursor c_acc_score_dt is
    SELECT sh.score_object_id,
    sh.score_value score,
    sc.score_id,
    sc.score_name
   FROM iex_score_histories sh,iex_scores sc
   WHERE sc.score_id = sh.score_id
   and sh.score_object_code = 'IEX_ACCOUNT'
   and (sh.score_object_id,sh.score_object_code,sh.creation_date)
      in (SELECT sh1.score_object_id,sh1.score_object_code,MAX(sh1.creation_date)
          FROM iex_score_histories sh1,
          iex_dln_uwq_summary temp
	WHERE sh1.score_object_code = 'IEX_ACCOUNT'
         AND sh1.score_object_id = temp.cust_account_id
	 and temp.site_use_id is null
	  AND  trunc(temp.LAST_UPDATE_DATE) = trunc(sysdate)
	group by sh1.score_object_id,sh1.score_object_code);
-------------------
  --Start of comment for Bug 9597052 28-Apr-2010 barathsr
  /*  CURSOR c_iex_cu_uwq_summary(c_level varchar2,c_org_id number)--Added for Bug 8707923 27-Jul-2009 barathsr
    IS
      SELECT
          trx_summ.org_id,
          max(ac.collector_id),
          max(ac.resource_id),
          max(ac.resource_type),
          objb.object_function ieu_object_function,
          objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
          '' ieu_media_type_uuid,
          'PARTY_ID' ieu_param_pk_col,
          to_char(party.party_id) ieu_param_pk_value,
          1 resource_id,
          'RS_EMPLOYEE' resource_type,
          party.party_id party_id,
          party.party_name party_name,
          to_number(null) cust_account_id,
          null account_name,
          null account_number,
          to_number(null) site_use_id,
          null location,
          max(gl.CURRENCY_CODE) currency,
          SUM(trx_summ.op_invoices_count) op_invoices_count,
          SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
          SUM(trx_summ.op_deposits_count) op_deposits_count,
          SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
          SUM(trx_summ.op_chargeback_count) op_chargeback_count,
          SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
          SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
          SUM(trx_summ.disputed_inv_count) disputed_inv_count,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.best_current_receivables,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.best_current_receivables))) best_current_receivables,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_invoices_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_invoices_value))) op_invoices_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_debit_memos_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_debit_memos_value))) op_debit_memos_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_deposits_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_deposits_value))) op_deposits_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_bills_receivables_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_chargeback_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_chargeback_value))) op_chargeback_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_credit_memos_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_credit_memos_value))) op_credit_memos_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.unresolved_cash_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.unresolved_cash_value))) unresolved_cash_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.receipts_at_risk_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.inv_amt_in_dispute,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.pending_adj_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.pending_adj_value))) pending_adj_value,
              (SELECT SUM(b.acctd_amount_due_remaining)
           FROM iex_delinquencies_all a,
               ar_payment_schedules_all b
           WHERE a.party_cust_id = party.party_id
           AND a.payment_schedule_id = b.payment_schedule_id
           AND b.status = 'OP'
           AND a.status IN('DELINQUENT',      'PREDELINQUENT')
	   AND b.org_id = trx_summ.org_id) past_due_inv_value,
          SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
          MAX(trx_summ.last_payment_date) last_payment_date,
          MAX(iex_uwq_view_pkg.get_last_payment_amount(party.party_id,     0,     0)) last_payment_amount,
          max(gl.CURRENCY_CODE) last_payment_amount_curr,
          MAX(iex_uwq_view_pkg.get_last_payment_number(party.party_id,     0,     0)) last_payment_number,
          MAX(trx_summ.last_update_date) last_update_date,
          MAX(trx_summ.last_updated_by) last_updated_by,
          MAX(trx_summ.creation_date) creation_date,
          MAX(trx_summ.created_by) created_by,
          MAX(trx_summ.last_update_login) last_update_login,
              (SELECT COUNT(1)
           FROM iex_delinquencies_all
           WHERE party_cust_id = party.party_id
           AND status IN('DELINQUENT',      'PREDELINQUENT')
	   AND org_id = trx_summ.org_id)
      number_of_delinquencies,
              (SELECT 1
           FROM dual
           WHERE EXISTS
              (SELECT 1
               FROM iex_delinquencies_all
               WHERE party_cust_id = party.party_id
               AND status IN('DELINQUENT',      'PREDELINQUENT')
	       AND org_id = trx_summ.org_id
               AND(uwq_status IS NULL OR uwq_status = 'ACTIVE' OR(TRUNC(uwq_active_date) <= TRUNC(sysdate)
               AND uwq_status = 'PENDING')))
          )
      active_delinquencies,
              (SELECT 1
           FROM dual
           WHERE EXISTS
              (SELECT 1
               FROM iex_delinquencies_all
               WHERE party_cust_id = party.party_id
               AND status IN('DELINQUENT',      'PREDELINQUENT')
	       AND org_id = trx_summ.org_id
               AND(uwq_status = 'COMPLETE'
               AND(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
          )
      complete_delinquencies,
              (SELECT 1
           FROM dual
           WHERE EXISTS
              (SELECT 1
               FROM iex_delinquencies_all
               WHERE party_cust_id = party.party_id
               AND status IN('DELINQUENT',      'PREDELINQUENT')
	       AND org_id = trx_summ.org_id
               AND(uwq_status = 'PENDING'
               AND(TRUNC(uwq_active_date) > TRUNC(sysdate))))
          )
      pending_delinquencies,

      -- Start for the bug#7562130 by PNAVEENK
/*     (SELECT a.score_value
           FROM iex_score_histories a
           WHERE a.creation_date =
              (SELECT MAX(creation_date)
               FROM iex_score_histories
               WHERE score_object_code = 'PARTY'
               AND score_object_id = party.party_id)
          AND rownum < 2
           AND a.score_object_code = 'PARTY'
           AND a.score_object_id = party.party_id)
      score,*/
/*    to_number(cal_score(party.party_id,'PARTY','SCORE_VALUE')) score,
    to_number(cal_score(party.party_id,'PARTY','SCORE_ID')) score_id,
    cal_score(party.party_id,'PARTY','SCORE_NAME') score_name,
    max(decode(ac.resource_type, 'RS_RESOURCE' ,
          (select rs.source_name from jtf_rs_resource_extns rs where rs.resource_id= ac.resource_id),
          (select rg.group_name from JTF_RS_GROUPS_VL rg where rg.group_id=ac.resource_id)
          ) )  collector_resource_name,
   -- end for the bug#7562130
          party.address1 address1,
          party.city city,
          party.state state,
          party.county county,
          fnd_terr.territory_short_name country,
          party.province province,
          party.postal_code postal_code,
          phone.phone_country_code phone_country_code,
          phone.phone_area_code phone_area_code,
          phone.phone_number phone_number,
          phone.phone_extension phone_extension,
          (SELECT COUNT(1) FROM iex_bankruptcies bkr WHERE bkr.party_id = party.party_id and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')) number_of_bankruptcies, -- Changed for bug#7693986

          iex_uwq_view_pkg.get_pro_count(party.party_id,     NULL,     NULL,     NULL, trx_summ.org_id) number_of_promises,
          iex_uwq_view_pkg.get_broken_prm_amt(party.party_id,     NULL,     NULL, trx_summ.org_id) broken_promise_amount,
          iex_uwq_view_pkg.get_prm_amt(party.party_id,     NULL,     NULL, trx_summ.org_id) promise_amount,
              (SELECT 1
           FROM dual
           WHERE EXISTS
              (SELECT 1
               FROM iex_promise_details pd,
                   hz_cust_accounts b
               WHERE b.party_id = party.party_id
               AND pd.cust_account_id = b.cust_account_id
               AND pd.state = 'BROKEN_PROMISE'
               AND(pd.uwq_status IS NULL OR pd.uwq_status = 'ACTIVE' OR(TRUNC(pd.uwq_active_date) <= TRUNC(sysdate)
               AND pd.uwq_status = 'PENDING')))
          )
      active_promises,
              (SELECT 1
           FROM dual
           WHERE EXISTS
              (SELECT 1
               FROM iex_promise_details pd,
                   hz_cust_accounts b
               WHERE b.party_id = party.party_id
               AND pd.cust_account_id = b.cust_account_id
               AND pd.state = 'BROKEN_PROMISE'
               AND(pd.uwq_status = 'COMPLETE'
               AND(TRUNC(pd.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
          )
      complete_promises,
              (SELECT 1
           FROM dual
           WHERE EXISTS
              (SELECT 1
               FROM iex_promise_details pd,
                   hz_cust_accounts b
               WHERE b.party_id = party.party_id
               AND pd.cust_account_id = b.cust_account_id
               and pd.state = 'BROKEN_PROMISE'
               AND(pd.uwq_status = 'PENDING'
               AND(TRUNC(pd.uwq_active_date) > TRUNC(sysdate))))
          )
      pending_promises

      FROM ar_trx_bal_summary trx_summ,
          hz_cust_accounts acc,
          hz_parties party,
	  hz_party_preferences party_pref,--Added for Bug 8707923 27-Jul-2009 barathsr
          jtf_objects_b objb,
          hz_contact_points phone,
          fnd_territories_tl fnd_terr,
            hz_customer_profiles prf,
            ar_collectors ac,
            GL_SETS_OF_BOOKS gl,
            AR_SYSTEM_PARAMETERS_all sys

      WHERE
       P_MODE = 'CP'
       AND trx_summ.reference_1 = '1'
       AND trx_summ.cust_account_id = acc.cust_account_id
       AND acc.party_id = party.party_id
       AND objb.object_code = 'IEX_CUSTOMER'
        and objb.object_code <> 'IEX_DELINQUENCY'--Added for Bug 8707923 27-Jul-2009 barathsr
       AND party.country = fnd_terr.territory_code(+)
       AND fnd_terr.LANGUAGE(+) = userenv('LANG')
       AND phone.owner_table_id(+) = party.party_id
       AND phone.owner_table_name(+) = 'HZ_PARTIES'
       AND phone.contact_point_type(+) = 'PHONE'
       and phone.primary_by_purpose(+) = 'Y'
       AND phone.contact_point_purpose(+) = 'COLLECTIONS'
       AND phone.phone_line_type(+) NOT IN('PAGER',     'FAX')
       AND phone.status(+) = 'A'
       AND nvl(phone.do_not_use_flag(+),     'N') = 'N'
       AND acc.party_id = prf.party_id
       and prf.CUST_ACCOUNT_ID = -1
--       and prf.CUST_ACCOUNT_ID = trx_summ.CUST_ACCOUNT_ID
       and prf.SITE_USE_ID is null
       and ac.collector_id(+) = prf.collector_id
       and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
       and trx_summ.org_id = sys.org_id
       --Begin Bug 8707923 27-Jul-2009 barathsr
       and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),c_level)='CUSTOMER'
   and trx_summ.org_id=nvl(c_org_id,trx_summ.org_id)
   --End Bug 8707923 27-Jul-2009 barathsr
           GROUP BY trx_summ.org_id,
          objb.object_function,
          objb.object_parameters,
          party.party_id,
          party.party_name,
          party.address1,
          party.city,
          party.state,
          party.county,
          fnd_terr.territory_short_name,
          party.province,
          party.postal_code,
          phone.phone_country_code,
          phone.phone_area_code,
          phone.phone_number,
          phone.phone_extension;*/
   --End of comment for Bug 9597052 28-Apr-2010 barathsr


    --Begin Bug 9597052 28-Apr-2010 barathsr
    --This cursor fetches column values from ar_trx_bal_summary table and the values are inserted in iex_dln_uwq_summary at Party level
    --All the other column values are fetched with small cursors from the respective tables and updated in iex_dln_uwq_summary


   CURSOR c_iex_cu_uwq_summary(c_level varchar2,c_org_id number)--Added for Bug 8707923 27-Jul-2009 barathsr
    IS
      SELECT
          trx_summ.org_id,
          objb.object_function ieu_object_function,
          objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
          '' ieu_media_type_uuid,
          'PARTY_ID' ieu_param_pk_col,
          to_char(party.party_id) ieu_param_pk_value,
          party.party_id party_id,
        --  party.party_name party_name,
          to_number(null) cust_account_id,
          to_number(null) site_use_id,
          max(gl.CURRENCY_CODE) currency,
          SUM(trx_summ.op_invoices_count) op_invoices_count,
          SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
          SUM(trx_summ.op_deposits_count) op_deposits_count,
          SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
          SUM(trx_summ.op_chargeback_count) op_chargeback_count,
          SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
          SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
          SUM(trx_summ.disputed_inv_count) disputed_inv_count,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.best_current_receivables,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.best_current_receivables))) best_current_receivables,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_invoices_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_invoices_value))) op_invoices_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_debit_memos_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_debit_memos_value))) op_debit_memos_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_deposits_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_deposits_value))) op_deposits_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_bills_receivables_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_chargeback_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_chargeback_value))) op_chargeback_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_credit_memos_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_credit_memos_value))) op_credit_memos_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.unresolved_cash_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.unresolved_cash_value))) unresolved_cash_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.receipts_at_risk_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.inv_amt_in_dispute,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.pending_adj_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.pending_adj_value))) pending_adj_value,
          SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
          MAX(trx_summ.last_payment_date) last_payment_date,
          MAX(trx_summ.last_update_date) last_update_date,
          MAX(trx_summ.last_updated_by) last_updated_by,
          MAX(trx_summ.creation_date) creation_date,
          MAX(trx_summ.created_by) created_by,
          MAX(trx_summ.last_update_login) last_update_login
          FROM ar_trx_bal_summary trx_summ,
          hz_cust_accounts acc,
          hz_parties party,
	  hz_party_preferences party_pref,--Added for Bug 8707923 27-Jul-2009 barathsr
          jtf_objects_b objb,
          GL_SETS_OF_BOOKS gl,
            AR_SYSTEM_PARAMETERS_all sys

      WHERE
       P_MODE = 'CP'
       AND trx_summ.reference_1 = '1'
       AND trx_summ.cust_account_id = acc.cust_account_id
       AND acc.party_id = party.party_id
       AND objb.object_code = 'IEX_CUSTOMER'
        and objb.object_code <> 'IEX_DELINQUENCY'--Added for Bug 8707923 27-Jul-2009 barathsr
       and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
       and trx_summ.org_id = sys.org_id
       --Begin Bug 8707923 27-Jul-2009 barathsr
       and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),c_level)='CUSTOMER'
   and trx_summ.org_id=nvl(c_org_id,trx_summ.org_id)
   --End Bug 8707923 27-Jul-2009 barathsr
           GROUP BY trx_summ.org_id,
          objb.object_function,
          objb.object_parameters,
          party.party_id;


	  cursor c_cu_deln_cnt is
    SELECT a.party_cust_id,dln.org_id,
    count(a.delinquency_id) number_of_delinquencies,
    SUM(b.acctd_amount_due_remaining) past_due_inv_value
   FROM iex_delinquencies_all a,
        ar_payment_schedules_all b,
        iex_dln_uwq_summary dln
   WHERE a.party_cust_id =dln.party_id
    AND a.payment_schedule_id = b.payment_schedule_id
    AND b.status = 'OP'
    AND a.status IN('DELINQUENT',   'PREDELINQUENT')
    AND dln.org_id = a.org_id
    and dln.site_use_id is null
    and dln.cust_account_id is null
   GROUP BY a.party_cust_id,dln.org_id;

    cursor c_cu_deln_dtls
   is
   select del.party_cust_ID,dln.org_id,
    max(decode(uwq_status,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_delinquencies,
    max(decode(uwq_status,'COMPLETE',(decode(sign(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_delinquencies,
    max(decode(uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_delinquencies
    from iex_delinquencies_all del,
      iex_dln_uwq_summary dln
    WHERE del.party_cust_id = dln.party_id  AND
    del.org_id = dln.org_id and
    del.status IN('DELINQUENT',    'PREDELINQUENT')
    group by del.party_cust_id,dln.org_id;

   cursor c_cu_pro_dtls is
   SELECT del.party_cust_id,dln.org_id,
	COUNT(1) number_of_promises,
	SUM(pd.amount_due_remaining) broken_promise_amount,
	SUM(pd.promise_amount) promise_amount
   FROM iex_promise_details pd,
         iex_delinquencies_all del,
         iex_dln_uwq_summary dln
   WHERE dln.party_id = del.party_cust_id
     AND pd.delinquency_id = del.delinquency_id
     AND pd.status IN('COLLECTABLE',   'PENDING')
     AND pd.state = 'BROKEN_PROMISE'
     AND pd.amount_due_remaining > 0
     AND (del.status NOT IN('CURRENT',   'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))
     and dln.site_use_id is null
     and dln.cust_account_id is null
     and del.org_id = dln.org_id
   GROUP BY del.party_cust_id,dln.org_id;

   cursor c_cu_pro_summ is
    select del.party_cust_ID,dln.org_id,
    max(decode(pd.uwq_status,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_promises,
    max(decode(pd.uwq_status,'COMPLETE',(decode(sign(TRUNC(pd.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_promises,
    max(decode(pd.uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_promises
    from iex_promise_details pd,
    IEX_DELINQUENCIES_ALL DEL,
    iex_dln_uwq_summary dln
    WHERE dln.party_id = del.party_cust_id
      and pd.delinquency_id = del.delinquency_id
      and dln.site_use_id is null
      and dln.cust_account_id is null
      and del.org_id = dln.org_id
      and pd.state = 'BROKEN_PROMISE'
     group by del.party_cust_ID,dln.org_id;


CURSOR c_cust_details IS
    SELECT
    party.party_id party_id,summ.org_id,
    party.party_name party_name,
--    summ.cust_account_id cust_account_id,
    null account_name,
    null account_number,
    null location,
    party.address1 address1,
    party.city city,
    party.state state,
    party.county county,
    fnd_terr.territory_short_name country,
    party.province province,
    party.postal_code postal_code
  FROM iex_dln_uwq_summary summ,
  --  hz_cust_accounts acc,
    hz_parties party,
    hz_party_preferences party_pref,
    fnd_territories_tl fnd_terr
  WHERE
       summ.party_id = party.party_id
   AND party.country = fnd_terr.territory_code(+)
   AND fnd_terr.LANGUAGE(+) = userenv('LANG')
   and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and summ.site_use_id is null
   and summ.cust_account_id is null
   GROUP BY party.party_id,
    party.party_name,
    party.address1,
    party.city,
    party.state,
    party.county,
    fnd_terr.territory_short_name,
    party.province,
    party.postal_code,
    summ.org_id;


    CURSOR C_cu_CONTACT_POINT IS
      SELECT summ.party_id,summ.org_id,
	phone.phone_country_code phone_country_code,
	phone.phone_area_code phone_area_code,
	phone.phone_number phone_number,
	phone.phone_extension phone_extension
  FROM iex_dln_uwq_summary summ,
	hz_contact_points phone
  WHERE
      phone.owner_table_id(+) = summ.party_id
     AND phone.owner_table_name(+) = 'HZ_PARTIES'
     AND phone.contact_point_type(+) = 'PHONE'
     AND phone.primary_by_purpose(+) = 'Y'
     AND phone.contact_point_purpose(+) = 'COLLECTIONS'
     AND phone.phone_line_type(+) NOT IN('PAGER',   'FAX')
     AND phone.status(+) = 'A'
     AND nvl(phone.do_not_use_flag(+),   'N') = 'N'
   and summ.site_use_id is null
   and summ.cust_account_id is null
   group by summ.party_id,
    phone.phone_country_code,
    phone.phone_area_code,
    phone.phone_number,
    phone.phone_extension,
    summ.org_id;


    CURSOR C_cu_COLLECTOR_prof IS
      SELECT
       hp.collector_id collector_id,temp.org_id,
       ac.resource_id collector_resource_id,
        ac.resource_type COLLECTOR_RES_TYPE,
	decode(ac.resource_type, 'RS_RESOURCE' , rs.source_name , rg.group_name)   collector_resource_name,
        1 resource_id,
        'RS_EMPLOYEE' resource_type,
	 hp.party_id
       FROM
         hz_customer_profiles hp,
	 ar_collectors ac,
	 iex_dln_uwq_summary temp,
	 JTF_RS_GROUPS_VL rg,
         jtf_rs_resource_extns rs
      WHERE
         hp.party_id = temp.party_ID
	 and  ac.collector_id(+) = hp.collector_id
	 and rg.group_id(+)  = ac.resource_id
         and rs.resource_id(+) = ac.resource_id
	 and hp.site_use_id is null
	 and temp.site_use_id is null
	 and temp.cust_account_id is null;

   cursor c_cu_last_payment_dtls is
   select hca.party_id,summ.org_id,
         summ.last_payment_amount last_payment_amount,
	 summ.currency last_payment_currency,
	 summ.last_payment_number last_payment_number
   from ar_trx_bal_summary summ,
   hz_cust_accounts hca,
    gl_sets_of_books gl,
    ar_system_parameters_all sys
   where summ.cust_account_id=hca.cust_account_id
   and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
   and summ.org_id = sys.org_id
   and summ.last_payment_date=(select max(dln.last_payment_date)
	from iex_dln_uwq_summary dln
	where dln.party_id=hca.party_id
	and dln.org_id=summ.org_id
	and dln.cust_account_id is null
	and dln.site_use_id is null);


  cursor c_cu_bankruptcies is
   select summ.party_id,summ.org_id,
   COUNT(1) number_of_bankruptcies
   FROM iex_bankruptcies bkr,
   iex_dln_uwq_summary summ
   where bkr.party_id=summ.party_id
   and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')
   and summ.site_use_id is null and summ.cust_account_id is null
   group by summ.party_id,summ.org_id;

   cursor c_cu_score is
    SELECT sh.score_object_id,
    sh.score_value score,
    sc.score_id,
    sc.score_name
   FROM iex_score_histories sh,iex_scores sc
   WHERE sc.score_id = sh.score_id
   and sh.score_object_code = 'PARTY'
   and (sh.score_object_id,sh.score_object_code,sh.creation_date)
      in (SELECT sh1.score_object_id,sh1.score_object_code,MAX(sh1.creation_date)
          FROM iex_score_histories sh1,
          iex_dln_uwq_summary temp
	WHERE sh1.score_object_code = 'PARTY'
         AND sh1.score_object_id = temp.party_id
	 and temp.site_use_id is null
	 and temp.cust_account_id is null
	group by sh1.score_object_id,sh1.score_object_code);

	--End Bug 9597052 28-Apr-2010 barathsr

	-------------
  --Start of comment for Bug 9597052 28-Apr-2010 barathsr
  /*  CURSOR c_iex_cu_uwq_dt_sum(p_from_date date,c_level varchar2,c_org_id number)--Added for Bug 8707923 27-Jul-2009 barathsr
    IS
      SELECT
          trx_summ.org_id,
          max(ac.collector_id),
          max(ac.resource_id),
          max(ac.resource_type),
          objb.object_function ieu_object_function,
          objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
          '' ieu_media_type_uuid,
          'PARTY_ID' ieu_param_pk_col,
          to_char(party.party_id) ieu_param_pk_value,
          1 resource_id,
          'RS_EMPLOYEE' resource_type,
          party.party_id party_id,
          party.party_name party_name,
          to_number(null) cust_account_id,
          null account_name,
          null account_number,
          to_number(null) site_use_id,
          null location,
          max(gl.CURRENCY_CODE) currency,
          SUM(trx_summ.op_invoices_count) op_invoices_count,
          SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
          SUM(trx_summ.op_deposits_count) op_deposits_count,
          SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
          SUM(trx_summ.op_chargeback_count) op_chargeback_count,
          SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
          SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
          SUM(trx_summ.disputed_inv_count) disputed_inv_count,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.best_current_receivables,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.best_current_receivables))) best_current_receivables,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_invoices_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_invoices_value))) op_invoices_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_debit_memos_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_debit_memos_value))) op_debit_memos_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_deposits_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_deposits_value))) op_deposits_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_bills_receivables_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_chargeback_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_chargeback_value))) op_chargeback_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_credit_memos_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_credit_memos_value))) op_credit_memos_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.unresolved_cash_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.unresolved_cash_value))) unresolved_cash_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.receipts_at_risk_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.inv_amt_in_dispute,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.pending_adj_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.pending_adj_value))) pending_adj_value,
              (SELECT SUM(b.acctd_amount_due_remaining)
           FROM iex_delinquencies_all a,
               ar_payment_schedules_all b
           WHERE a.party_cust_id = party.party_id
           AND a.payment_schedule_id = b.payment_schedule_id
           AND b.status = 'OP'
           AND a.status IN('DELINQUENT',      'PREDELINQUENT')
	   AND b.org_id = trx_summ.org_id) past_due_inv_value,
          SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
          MAX(trx_summ.last_payment_date) last_payment_date,
          MAX(iex_uwq_view_pkg.get_last_payment_amount(party.party_id,     0,     0)) last_payment_amount,
          max(gl.CURRENCY_CODE) last_payment_amount_curr,
          MAX(iex_uwq_view_pkg.get_last_payment_number(party.party_id,     0,     0)) last_payment_number,
          MAX(trx_summ.last_update_date) last_update_date,
          MAX(trx_summ.last_updated_by) last_updated_by,
          MAX(trx_summ.creation_date) creation_date,
          MAX(trx_summ.created_by) created_by,
          MAX(trx_summ.last_update_login) last_update_login,
              (SELECT COUNT(1)
           FROM iex_delinquencies_all
           WHERE party_cust_id = party.party_id
           AND status IN('DELINQUENT',      'PREDELINQUENT')
	   AND org_id = trx_summ.org_id)
      number_of_delinquencies,
              (SELECT 1
           FROM dual
           WHERE EXISTS
              (SELECT 1
               FROM iex_delinquencies_all
               WHERE party_cust_id = party.party_id
               AND status IN('DELINQUENT',      'PREDELINQUENT')
	       AND org_id = trx_summ.org_id
               AND(uwq_status IS NULL OR uwq_status = 'ACTIVE' OR(TRUNC(uwq_active_date) <= TRUNC(sysdate)
               AND uwq_status = 'PENDING')))
          )
      active_delinquencies,
              (SELECT 1
           FROM dual
           WHERE EXISTS
              (SELECT 1
               FROM iex_delinquencies_all
               WHERE party_cust_id = party.party_id
               AND status IN('DELINQUENT',      'PREDELINQUENT')
	       AND org_id = trx_summ.org_id
               AND(uwq_status = 'COMPLETE'
               AND(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
          )
      complete_delinquencies,
              (SELECT 1
           FROM dual
           WHERE EXISTS
              (SELECT 1
               FROM iex_delinquencies_all
               WHERE party_cust_id = party.party_id
               AND status IN('DELINQUENT',      'PREDELINQUENT')
	       AND org_id = trx_summ.org_id
               AND(uwq_status = 'PENDING'
               AND(TRUNC(uwq_active_date) > TRUNC(sysdate))))
          )
      pending_delinquencies,
       -- Start for the bug#7562130 by PNAVEENK
/*     (SELECT a.score_value
           FROM iex_score_histories a
           WHERE a.creation_date =
              (SELECT MAX(creation_date)
               FROM iex_score_histories
               WHERE score_object_code = 'PARTY'
               AND score_object_id = party.party_id)
          AND rownum < 2
           AND a.score_object_code = 'PARTY'
           AND a.score_object_id = party.party_id)
      score,*/
/*    to_number(cal_score(party.party_id,'PARTY','SCORE_VALUE')) score,
    to_number(cal_score(party.party_id,'PARTY','SCORE_ID')) score_id,
    cal_score(party.party_id,'PARTY','SCORE_NAME') score_name,
    max(decode(ac.resource_type, 'RS_RESOURCE' ,
          (select rs.source_name from jtf_rs_resource_extns rs where rs.resource_id= ac.resource_id),
          (select rg.group_name from JTF_RS_GROUPS_VL rg where rg.group_id=ac.resource_id)
          ) )  collector_resource_name,
   -- end for the bug#7562130
          party.address1 address1,
          party.city city,
          party.state state,
          party.county county,
          fnd_terr.territory_short_name country,
          party.province province,
          party.postal_code postal_code,
          phone.phone_country_code phone_country_code,
          phone.phone_area_code phone_area_code,
          phone.phone_number phone_number,
          phone.phone_extension phone_extension,
           (SELECT COUNT(1) FROM iex_bankruptcies bkr WHERE bkr.party_id = party.party_id and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')) number_of_bankruptcies, -- Changed for bug#7693986

          iex_uwq_view_pkg.get_pro_count(party.party_id,     NULL,     NULL,     NULL, trx_summ.org_id) number_of_promises,
          iex_uwq_view_pkg.get_broken_prm_amt(party.party_id,     NULL,     NULL, trx_summ.org_id) broken_promise_amount,
          iex_uwq_view_pkg.get_prm_amt(party.party_id,     NULL,     NULL, trx_summ.org_id) promise_amount,
              (SELECT 1
           FROM dual
           WHERE EXISTS
              (SELECT 1
               FROM iex_promise_details pd,
                   hz_cust_accounts b
               WHERE b.party_id = party.party_id
               AND pd.cust_account_id = b.cust_account_id
               AND pd.state = 'BROKEN_PROMISE'
               AND(pd.uwq_status IS NULL OR pd.uwq_status = 'ACTIVE' OR(TRUNC(pd.uwq_active_date) <= TRUNC(sysdate)
               AND pd.uwq_status = 'PENDING')))
          )
      active_promises,
              (SELECT 1
           FROM dual
           WHERE EXISTS
              (SELECT 1
               FROM iex_promise_details pd,
                   hz_cust_accounts b
               WHERE b.party_id = party.party_id
               AND pd.cust_account_id = b.cust_account_id
               AND pd.state = 'BROKEN_PROMISE'
               AND(pd.uwq_status = 'COMPLETE'
               AND(TRUNC(pd.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') > TRUNC(sysdate))))
          )
      complete_promises,
              (SELECT 1
           FROM dual
           WHERE EXISTS
              (SELECT 1
               FROM iex_promise_details pd,
                   hz_cust_accounts b
               WHERE b.party_id = party.party_id
               AND pd.cust_account_id = b.cust_account_id
               and pd.state = 'BROKEN_PROMISE'
               AND(pd.uwq_status = 'PENDING'
               AND(TRUNC(pd.uwq_active_date) > TRUNC(sysdate))))
          )
      pending_promises

      FROM ar_trx_bal_summary trx_summ,
          hz_cust_accounts acc,
          hz_parties party,
	  hz_party_preferences party_pref,--Added for Bug 8707923 27-Jul-2009 barathsr
          jtf_objects_b objb,
          hz_contact_points phone,
          fnd_territories_tl fnd_terr,
            hz_customer_profiles prf,
            ar_collectors ac,
            GL_SETS_OF_BOOKS gl,
            AR_SYSTEM_PARAMETERS_all sys
      WHERE trx_summ.reference_1 = '1'
       AND trx_summ.cust_account_id = acc.cust_account_id
       AND acc.party_id = party.party_id
       AND objb.object_code = 'IEX_CUSTOMER'
        and objb.object_code <> 'IEX_DELINQUENCY'--Added for Bug 8707923 27-Jul-2009 barathsr
       AND party.country = fnd_terr.territory_code(+)
       AND fnd_terr.LANGUAGE(+) = userenv('LANG')
       AND phone.owner_table_id(+) = party.party_id
       AND phone.owner_table_name(+) = 'HZ_PARTIES'
       AND phone.contact_point_type(+) = 'PHONE'
       and phone.primary_by_purpose(+) = 'Y'
       AND phone.contact_point_purpose(+) = 'COLLECTIONS'
       AND phone.phone_line_type(+) NOT IN('PAGER',     'FAX')
       AND phone.status(+) = 'A'
       AND nvl(phone.do_not_use_flag(+),     'N') = 'N'
       AND acc.party_id = prf.party_id
       and prf.CUST_ACCOUNT_ID = -1
--       and prf.CUST_ACCOUNT_ID = trx_summ.CUST_ACCOUNT_ID
       and prf.SITE_USE_ID is null
       and ac.collector_id(+) = prf.collector_id
       and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
       and trx_summ.org_id = sys.org_id
     -- start bug 5762888 gnramasa 13-July-2007
      /* and (trx_summ.cust_account_id, trx_summ.site_use_id, trx_summ.org_id) in */
           /* changed for bug 5677415 by gnramasa on 27/11/2006 */
	   /* (select cust_account_id, site_use_id, org_id from ar_trx_bal_summary where trunc(LAST_UPDATE_DATE) >= trunc(sysdate)) */
	   /* (select cust_account_id, site_use_id, org_id from ar_trx_bal_summary where trunc(LAST_UPDATE_DATE) >= trunc(p_from_date)) */
--       and trunc(trx_summ.last_update_date) >= trunc(p_from_date)
   -- end bug 5762888 gnramasa 13-July-2007
   --Begin Bug 8707923 27-Jul-2009 barathsr
/*   and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),c_level)='CUSTOMER'
   and trx_summ.org_id=nvl(c_org_id,trx_summ.org_id)
    --End Bug 8707923 27-Jul-2009 barathsr
      GROUP BY trx_summ.org_id,
          objb.object_function,
          objb.object_parameters,
          party.party_id,
          party.party_name,
          party.address1,
          party.city,
          party.state,
          party.county,
          fnd_terr.territory_short_name,
          party.province,
          party.postal_code,
          phone.phone_country_code,
          phone.phone_area_code,
          phone.phone_number,
          phone.phone_extension;*/
 --End bug 6634879 gnramasa 20th Nov 07
 --End of comment for Bug 9597052 28-Apr-2010 barathsr

 --Begin Bug 9597052 28-Apr-2010 barathsr
    --This cursor fetches column values from ar_trx_bal_summary table and the values are inserted in iex_dln_uwq_summary at Party level for a specified date range
    --All the other column values are fetched with small cursors from the respective tables and updated in iex_dln_uwq_summary


 CURSOR c_iex_cu_uwq_dt_sum(p_from_date date,c_level varchar2,c_org_id number)
    IS
      SELECT
          trx_summ.org_id,
          objb.object_function ieu_object_function,
          objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
          '' ieu_media_type_uuid,
          'PARTY_ID' ieu_param_pk_col,
          to_char(party.party_id) ieu_param_pk_value,
          party.party_id party_id,
        --  party.party_name party_name,
          to_number(null) cust_account_id,
          to_number(null) site_use_id,
          max(gl.CURRENCY_CODE) currency,
          SUM(trx_summ.op_invoices_count) op_invoices_count,
          SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
          SUM(trx_summ.op_deposits_count) op_deposits_count,
          SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
          SUM(trx_summ.op_chargeback_count) op_chargeback_count,
          SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
          SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
          SUM(trx_summ.disputed_inv_count) disputed_inv_count,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.best_current_receivables,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.best_current_receivables))) best_current_receivables,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_invoices_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_invoices_value))) op_invoices_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_debit_memos_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_debit_memos_value))) op_debit_memos_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_deposits_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_deposits_value))) op_deposits_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_bills_receivables_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_chargeback_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_chargeback_value))) op_chargeback_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_credit_memos_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_credit_memos_value))) op_credit_memos_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.unresolved_cash_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.unresolved_cash_value))) unresolved_cash_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.receipts_at_risk_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.inv_amt_in_dispute,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
          SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.pending_adj_value,
          gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
          iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.pending_adj_value))) pending_adj_value,
          SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
          MAX(trx_summ.last_payment_date) last_payment_date,
          MAX(trx_summ.last_update_date) last_update_date,
          MAX(trx_summ.last_updated_by) last_updated_by,
          MAX(trx_summ.creation_date) creation_date,
          MAX(trx_summ.created_by) created_by,
          MAX(trx_summ.last_update_login) last_update_login
          FROM ar_trx_bal_summary trx_summ,
          hz_cust_accounts acc,
          hz_parties party,
	  hz_party_preferences party_pref,--Added for Bug 8707923 27-Jul-2009 barathsr
          jtf_objects_b objb,
          GL_SETS_OF_BOOKS gl,
            AR_SYSTEM_PARAMETERS_all sys

      WHERE
       P_MODE = 'CP'
       AND trx_summ.reference_1 = '1'
       AND trx_summ.cust_account_id = acc.cust_account_id
       AND acc.party_id = party.party_id
       AND objb.object_code = 'IEX_CUSTOMER'
        and objb.object_code <> 'IEX_DELINQUENCY'--Added for Bug 8707923 27-Jul-2009 barathsr
       and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
       and trx_summ.org_id = sys.org_id
        and trunc(trx_summ.last_update_date) >= trunc(p_from_date)
       --Begin Bug 8707923 27-Jul-2009 barathsr
       and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),c_level)='CUSTOMER'
   and trx_summ.org_id=nvl(c_org_id,trx_summ.org_id)
   --End Bug 8707923 27-Jul-2009 barathsr
           GROUP BY trx_summ.org_id,
          objb.object_function,
          objb.object_parameters,
          party.party_id;


	  cursor c_cu_deln_cnt_dt is
    SELECT a.party_cust_id,dln.org_id,
    count(a.delinquency_id) number_of_delinquencies,
    SUM(b.acctd_amount_due_remaining) past_due_inv_value
   FROM iex_delinquencies_all a,
        ar_payment_schedules_all b,
        iex_dln_uwq_summary dln
   WHERE a.party_cust_id =dln.party_id
    AND a.payment_schedule_id = b.payment_schedule_id
    AND b.status = 'OP'
    AND a.status IN('DELINQUENT',   'PREDELINQUENT')
    AND dln.org_id = a.org_id
    AND  trunc(dln.LAST_UPDATE_DATE) = trunc(sysdate)
    and dln.site_use_id is null
    and dln.cust_account_id is null
   GROUP BY a.party_cust_id,dln.org_id;

    cursor c_cu_deln_dtls_dt
   is
   select del.party_cust_ID,dln.org_id,
    max(decode(uwq_status,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_delinquencies,
    max(decode(uwq_status,'COMPLETE',(decode(sign(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_delinquencies,
    max(decode(uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_delinquencies
    from iex_delinquencies_all del,
      iex_dln_uwq_summary dln
    WHERE del.party_cust_id = dln.party_id  AND
    del.org_id = dln.org_id and
    del.status IN('DELINQUENT',    'PREDELINQUENT')
    and dln.site_use_id is null
    and dln.cust_account_id is null
    AND  trunc(dln.LAST_UPDATE_DATE) = trunc(sysdate)
    group by del.party_cust_id,dln.org_id;

   cursor c_cu_pro_dtls_dt is
   SELECT del.party_cust_id,dln.org_id,
	COUNT(1) number_of_promises,
	SUM(pd.amount_due_remaining) broken_promise_amount,
	SUM(pd.promise_amount) promise_amount
   FROM iex_promise_details pd,
         iex_delinquencies_all del,
         iex_dln_uwq_summary dln
   WHERE dln.party_id = del.party_cust_id
     AND pd.delinquency_id = del.delinquency_id
     AND pd.status IN('COLLECTABLE',   'PENDING')
     AND pd.state = 'BROKEN_PROMISE'
     AND pd.amount_due_remaining > 0
     AND (del.status NOT IN('CURRENT',   'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))
     and dln.site_use_id is null
     and dln.cust_account_id is null
     AND  trunc(dln.LAST_UPDATE_DATE) = trunc(sysdate)
     and del.org_id = dln.org_id
   GROUP BY del.party_cust_id,dln.org_id;

   cursor c_cu_pro_summ_dt is
    select del.party_cust_ID,dln.org_id,
    max(decode(pd.uwq_status,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_promises,
    max(decode(pd.uwq_status,'COMPLETE',(decode(sign(TRUNC(pd.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_promises,
    max(decode(pd.uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_promises
    from iex_promise_details pd,
    IEX_DELINQUENCIES_ALL DEL,
    iex_dln_uwq_summary dln
    WHERE dln.party_id = del.party_cust_id
      and pd.delinquency_id = del.delinquency_id
      and dln.site_use_id is null
      and dln.cust_account_id is null
      AND  trunc(dln.LAST_UPDATE_DATE) = trunc(sysdate)
      and del.org_id = dln.org_id
      and pd.state = 'BROKEN_PROMISE'
     group by del.party_cust_ID,dln.org_id;


CURSOR c_cust_details_dt IS
    SELECT
    party.party_id party_id,summ.org_id,
    party.party_name party_name,
--    summ.cust_account_id cust_account_id,
    null account_name,
    null account_number,
    null location,
    party.address1 address1,
    party.city city,
    party.state state,
    party.county county,
    fnd_terr.territory_short_name country,
    party.province province,
    party.postal_code postal_code
  FROM iex_dln_uwq_summary summ,
  --  hz_cust_accounts acc,
    hz_parties party,
    hz_party_preferences party_pref,
    fnd_territories_tl fnd_terr
  WHERE
       summ.party_id = party.party_id
   AND party.country = fnd_terr.territory_code(+)
   AND fnd_terr.LANGUAGE(+) = userenv('LANG')
   and party.party_id=party_pref.party_id(+)
   and party_pref.module(+)='COLLECTIONS'
   and party_pref.category(+)='COLLECTIONS LEVEL'
   and party_pref.preference_code(+)='PARTY_ID'
   AND  trunc(summ.LAST_UPDATE_DATE) = trunc(sysdate)
   and summ.site_use_id is null
   and summ.cust_account_id is null
   GROUP BY party.party_id,
    party.party_name,
    party.address1,
    party.city,
    party.state,
    party.county,
    fnd_terr.territory_short_name,
    party.province,
    party.postal_code,
    summ.org_id;


    CURSOR C_cu_CONTACT_POINT_dt IS
      SELECT summ.party_id,summ.org_id,
	phone.phone_country_code phone_country_code,
	phone.phone_area_code phone_area_code,
	phone.phone_number phone_number,
	phone.phone_extension phone_extension
  FROM iex_dln_uwq_summary summ,
	hz_contact_points phone
  WHERE
      phone.owner_table_id(+) = summ.party_id
     AND phone.owner_table_name(+) = 'HZ_PARTIES'
     AND phone.contact_point_type(+) = 'PHONE'
     AND phone.primary_by_purpose(+) = 'Y'
     AND phone.contact_point_purpose(+) = 'COLLECTIONS'
     AND phone.phone_line_type(+) NOT IN('PAGER',   'FAX')
     AND phone.status(+) = 'A'
     AND nvl(phone.do_not_use_flag(+),   'N') = 'N'
     AND  trunc(summ.LAST_UPDATE_DATE) = trunc(sysdate)
   and summ.site_use_id is null
   and summ.cust_account_id is null
   group by summ.party_id,
    phone.phone_country_code,
    phone.phone_area_code,
    phone.phone_number,
    phone.phone_extension,
    summ.org_id;


    CURSOR C_cu_COLLECTOR_prof_dt IS
      SELECT
       hp.collector_id collector_id,temp.org_id,
       ac.resource_id collector_resource_id,
        ac.resource_type COLLECTOR_RES_TYPE,
	decode(ac.resource_type, 'RS_RESOURCE' , rs.source_name , rg.group_name)   collector_resource_name,
        1 resource_id,
        'RS_EMPLOYEE' resource_type,
	 hp.party_id
	 FROM
         hz_customer_profiles hp,
	 ar_collectors ac,
	 iex_dln_uwq_summary temp,
	 JTF_RS_GROUPS_VL rg,
         jtf_rs_resource_extns rs
      WHERE
         hp.party_id = temp.party_ID
	 and  ac.collector_id(+) = hp.collector_id
	 and rg.group_id(+)  = ac.resource_id
         and rs.resource_id(+) = ac.resource_id
	 AND  trunc(temp.LAST_UPDATE_DATE) = trunc(sysdate)
	 and hp.cust_account_id=-1
	 and hp.site_use_id is null
	 and temp.site_use_id is null
	 and temp.cust_account_id is null;

	 CURSOR c_cu_ch_coll_dt_sum IS
      SELECT
        DISTINCT
        ac.resource_id collector_resource_id,ids.org_id,
	ac.resource_type COLLECTOR_RES_TYPE,
	ac.collector_id collector_id,
	hp.party_id
	FROM
        ar_collectors ac,
	hz_customer_profiles hp,
	iex_dln_uwq_summary ids
      WHERE
         hp.party_id=ids.party_id
         and ac.collector_id(+) = hp.collector_id
	 AND ac.resource_id is NOT NULL
	 AND ac.resource_id <> ids.collector_resource_id
	 and hp.cust_account_id=-1
	 and hp.site_use_id is null
	 and ids.cust_account_id is null
	 and ids.site_use_id is null
	 AND trunc(ids.last_update_date)= TRUNC(SYSDATE);

   cursor c_cu_last_payment_dtls_dt is
   select hca.party_id,summ.org_id,
         summ.last_payment_amount last_payment_amount,
	 summ.currency last_payment_currency,
	 summ.last_payment_number last_payment_number
   from ar_trx_bal_summary summ,
   hz_cust_accounts hca,
    gl_sets_of_books gl,
    ar_system_parameters_all sys
   where summ.cust_account_id=hca.cust_account_id
   and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
   and summ.org_id = sys.org_id
   and summ.last_payment_date=(select max(dln.last_payment_date)
	from iex_dln_uwq_summary dln
	where dln.party_id=hca.party_id
	and dln.org_id=summ.org_id
	AND  trunc(dln.LAST_UPDATE_DATE) = trunc(sysdate)
	and dln.cust_account_id is null
	and dln.site_use_id is null);


  cursor c_cu_bankruptcies_dt is
   select summ.party_id,summ.org_id,
   COUNT(1) number_of_bankruptcies
   FROM iex_bankruptcies bkr,
   iex_dln_uwq_summary summ
   where bkr.party_id=summ.party_id
   and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')
   and summ.site_use_id is null and summ.cust_account_id is null
   AND  trunc(summ.LAST_UPDATE_DATE) = trunc(sysdate)
   group by summ.party_id,summ.org_id;

   cursor c_cu_score_dt is
    SELECT sh.score_object_id,
    sh.score_value score,
    sc.score_id,
    sc.score_name
   FROM iex_score_histories sh,iex_scores sc
   WHERE sc.score_id = sh.score_id
   and sh.score_object_code = 'PARTY'
   and (sh.score_object_id,sh.score_object_code,sh.creation_date)
      in (SELECT sh1.score_object_id,sh1.score_object_code,MAX(sh1.creation_date)
          FROM iex_score_histories sh1,
          iex_dln_uwq_summary temp
	WHERE sh1.score_object_code = 'PARTY'
         AND sh1.score_object_id = temp.party_id
	 AND  trunc(temp.LAST_UPDATE_DATE) = trunc(sysdate)
	 and temp.site_use_id is null
	 and temp.cust_account_id is null
	group by sh1.score_object_id,sh1.score_object_code);
  --End Bug 9597052 28-Apr-2010 barathsr
------------------------------------

     CURSOR c_strategy_summary(p_level varchar2,p_from_date date,p_org_id number) --Added for Bug 8707923 27-Jul-2009 barathsr
     IS
     select strat.jtf_object_id,
        wkitem.WORK_ITEM_ID,
        wkitem.schedule_start schedule_start,
        wkitem.schedule_end schedule_end,
        stry_temp_wkitem.category_type category,
        stry_temp_wkitem.WORK_TYPE,
        stry_temp_wkitem.PRIORITY_TYPE,
        wkitem.resource_id,
        wkitem.strategy_id,
        strat.strategy_template_id,
        wkitem.work_item_template_id,
        wkitem.status_code,
	strat.status_code,   -- Added for bug#7416344 by PNAVEENK on 2-4-2009
     --   wkitem.creation_date start_time,
        wkitem.execute_start start_time,  -- Added for bug#8306620 by PNAVEENK on 3-4-2009
	wkitem.execute_end end_time, -- snuthala 28/08/2008 bug #6745580
        wkitem.work_item_order wkitem_order,
	wkitem.escalated_yn                   --Added for bug#6981126 by schekuri on 27-Jul-2008
      from iex_strategies strat,
        iex_strategy_work_items wkitem,
        iex_stry_temp_work_items_b stry_temp_wkitem,
        IEX_DLN_UWQ_SUMMARY sum
      where strat.jtf_object_type = decode(p_level, 'CUSTOMER', 'PARTY', 'ACCOUNT', 'IEX_ACCOUNT', 'BILL_TO', 'IEX_BILLTO')
      AND strat.status_code IN('OPEN',   'ONHOLD')
      AND wkitem.strategy_id = strat.strategy_id
      AND wkitem.status_code IN('OPEN',   'ONHOLD')
      AND wkitem.work_item_template_id = stry_temp_wkitem.work_item_temp_id
      AND strat.jtf_object_id = decode(p_level, 'CUSTOMER', sum.PARTY_ID, 'ACCOUNT', sum.CUST_ACCOUNT_ID, 'BILL_TO', sum.SITE_USE_ID)
      AND trunc(sum.LAST_UPDATE_DATE) = trunc(sysdate)
      and sum.org_id=nvl(p_org_id,sum.org_id) --Added for Bug 8707923 27-Jul-2009 barathsr
      and sum.business_level=p_level;--Added for Bug 8707923 27-Jul-2009 barathsr

      --Bug5701973. Start.
      -- Start for the bug#7562130 by PNAVEENK
      CURSOR CHANGED_COLLECTOR(P_FROM_DATE DATE,p_level varchar2,p_org_id number) --Added for Bug 8707923 27-Jul-2009 barathsr
      IS
      SELECT
        DISTINCT
        ar.resource_id,
	ar.resource_type,
	decode(ar.resource_type, 'RS_RESOURCE' , rs.source_name , rg.group_name)   collector_resource_name,
	ar.collector_id
      FROM
        ar_collectors ar,
	iex_dln_uwq_summary ids,
	jtf_rs_resource_extns rs,
        JTF_RS_GROUPS_VL rg
      WHERE
         ar.collector_id = ids.collector_id
	 AND ar.resource_id is NOT NULL
	 AND ar.resource_id <> ids.collector_resource_id
	 AND trunc(ar.last_update_date) >= TRUNC(P_FROM_DATE)
	 and rs.resource_id(+) = ar.resource_id
         and rg.group_id (+) = ar.resource_id
	 and ids.org_id=nvl(p_org_id,ids.org_id)--Added for Bug 8707923 27-Jul-2009 barathsr
         and ids.business_level=p_level;--Added for Bug 8707923 27-Jul-2009 barathsr

      -- end for the bug#7562130


      CURSOR CHANGED_PROFILES(P_FROM_DATE DATE,p_level varchar2,p_org_id number)--Added for Bug 8707923 27-Jul-2009 barathsr
      IS
      SELECT
         hp.collector_id,
	 ids.party_id,
	 ids.cust_account_id,
	 ids.site_use_id
      FROM
         hz_customer_profiles hp,
	 iex_dln_uwq_summary ids
      WHERE
         hp.party_id = ids.party_id
	 AND decode(hp.cust_account_id,null,1,hp.cust_account_id)
	         = decode(ids.cust_account_id,null,1,ids.cust_account_id)
         AND decode(hp.site_use_id,null,1,hp.site_use_id)
	         = decode(ids.site_use_id,null,1,ids.site_use_id)
	 AND hp.collector_id            <> ids.collector_id
	 AND trunc(hp.last_update_date) >= TRUNC(P_FROM_DATE)
	  and ids.org_id=nvl(p_org_id,ids.org_id)--Added for Bug 8707923 27-Jul-2009 barathsr
          and ids.business_level=p_level;--Added for Bug 8707923 27-Jul-2009 barathsr

      CURSOR CHANGED_PARTY(P_FROM_DATE DATE,p_level varchar2,p_org_id number)--Added for Bug 8707923 27-Jul-2009 barathsr
      IS
      SELECT
          party.party_id,
          party.address1 address1,
          party.city city,
          party.state state,
          party.county county,
          fnd_terr.territory_short_name country,
          party.province province,
          party.postal_code postal_code
     FROM
      hz_parties party,
      iex_dln_uwq_summary ids,
      fnd_territories_tl fnd_terr
     WHERE
       party.party_id = ids.party_id
       AND party.country = fnd_terr.territory_code(+)
       AND fnd_terr.LANGUAGE(+) = userenv('LANG')
       AND trunc(party.last_update_date) >= TRUNC(P_FROM_DATE)
       and ids.org_id=nvl(p_org_id,ids.org_id)--Added for Bug 8707923 27-Jul-2009 barathsr
       and ids.business_level=p_level;--Added for Bug 8707923 27-Jul-2009 barathsr

     --Begin Bug 9487600 24-Mar-2010 barathsr
       CURSOR CHANGED_BILLTO_SITES(P_FROM_DATE DATE,p_level varchar2,p_org_id number)
       IS
       SELECT
           hcsua.site_use_id site_use_id,
	   loc.address1||' '||loc.address2||' '||loc.address3 address,
	   loc.city city,
	   loc.state state,
	   loc.county county,
	   loc.country country,
	   loc.province province,
	   loc.postal_code postal_code
	FROM
	 hz_cust_site_uses_all hcsua,
	 hz_cust_acct_sites_all hcasa,
	 hz_party_sites hps,
	 hz_locations loc
	WHERE
	hcsua.cust_acct_site_id=hcasa.cust_acct_site_id
	and hcasa.party_site_id=hps.party_site_id
	and hps.location_id=loc.location_id
	and trunc(loc.last_update_date)>= TRUNC(P_FROM_DATE)
	and hcsua.org_id=nvl(p_org_id,hcsua.org_id);
     --End Bug 9487600 24-Mar-2010 barathsr

      CURSOR CHANGED_CONTACT(P_FROM_DATE DATE,p_level varchar2,p_org_id number) --Added for Bug 8707923 27-Jul-2009 barathsr
      IS
      SELECT
         ids.party_id             party_id,
         phone.phone_country_code phone_country_code,
         phone.phone_area_code    phone_area_code,
         phone.phone_number       phone_number,
         phone.phone_extension    phone_extension
      FROM
         hz_contact_points phone,
         iex_dln_uwq_summary ids
      WHERE
       phone.owner_table_id = ids.party_id
       AND phone.owner_table_name = 'HZ_PARTIES'
       AND phone.contact_point_type = 'PHONE'
       and phone.primary_by_purpose = 'Y'
       AND phone.contact_point_purpose = 'COLLECTIONS'
       AND phone.phone_line_type NOT IN('PAGER',     'FAX')
       AND phone.status = 'A'
       AND nvl(phone.do_not_use_flag, 'N') = 'N'
       AND trunc(phone.last_update_date) >= TRUNC(P_FROM_DATE)
       and ids.org_id=nvl(p_org_id,ids.org_id)--Added for Bug 8707923 27-Jul-2009 barathsr
       and ids.business_level=p_level;--Added for Bug 8707923 27-Jul-2009 barathsr
       --Bug5701973. End.


    L_ORG_ID                                    number_list;
    L_COLLECTOR_ID                              number_list;
    L_COLLECTOR_RESOURCE_ID                     number_list;
    L_COLLECTOR_RES_TYPE                        varchar_30_list;
    L_IEU_OBJECT_FUNCTION                       varchar_30_list;
    L_IEU_OBJECT_PARAMETERS                     varchar_2020_list;
    L_IEU_MEDIA_TYPE_UUID                       varchar_10_list;
    L_IEU_PARAM_PK_COL                          varchar_40_list;
    L_IEU_PARAM_PK_VALUE                        varchar_40_list;
    L_RESOURCE_ID                               number_list;
    L_RESOURCE_TYPE                             varchar_20_list;
    L_PARTY_ID                                  number_list;
    L_PARTY_NAME                                varchar_360_list;
    L_CUST_ACCOUNT_ID                           number_list;
    L_ACCOUNT_NAME                              varchar_240_list;
    L_ACCOUNT_NUMBER                            varchar_30_list;
    L_SITE_USE_ID                               number_list;
    L_LOCATION                                  varchar_60_list;
    L_CURRENCY                                  varchar_20_list;
    L_OP_INVOICES_COUNT                         number_list;
    L_OP_DEBIT_MEMOS_COUNT                      number_list;
    L_OP_DEPOSITS_COUNT                         number_list;
    L_OP_BILLS_RECEIVABLES_COUNT                number_list;
    L_OP_CHARGEBACK_COUNT                       number_list;
    L_OP_CREDIT_MEMOS_COUNT                     number_list;
    L_UNRESOLVED_CASH_COUNT                     number_list;
    L_DISPUTED_INV_COUNT                        number_list;
    L_BEST_CURRENT_RECEIVABLES                  number_list;
    L_OP_INVOICES_VALUE                         number_list;
    L_OP_DEBIT_MEMOS_VALUE                      number_list;
    L_OP_DEPOSITS_VALUE                         number_list;
    L_OP_BILLS_RECEIVABLES_VALUE                number_list;
    L_OP_CHARGEBACK_VALUE                       number_list;
    L_OP_CREDIT_MEMOS_VALUE                     number_list;
    L_UNRESOLVED_CASH_VALUE                     number_list;
    L_RECEIPTS_AT_RISK_VALUE                    number_list;
    L_INV_AMT_IN_DISPUTE                        number_list;
    L_PENDING_ADJ_VALUE                         number_list;
    L_PAST_DUE_INV_VALUE                        number_list;
    L_PAST_DUE_INV_INST_COUNT                   number_list;
    L_LAST_PAYMENT_DATE                         date_list;
    L_LAST_PAYMENT_AMOUNT                       number_list;
    L_LAST_PAYMENT_AMOUNT_CURR                  varchar_20_list;
    L_LAST_PAYMENT_NUMBER                       varchar_30_list;
    L_LAST_UPDATE_DATE                          date_list;
    L_LAST_UPDATED_BY                           number_list;
    L_CREATION_DATE                             date_list;
    L_CREATED_BY                                number_list;
    L_LAST_UPDATE_LOGIN                         number_list;
    L_NUMBER_OF_DELINQUENCIES                   number_list;
    L_ACTIVE_DELINQUENCIES                      number_list;
    L_COMPLETE_DELINQUENCIES                    number_list;
    L_PENDING_DELINQUENCIES                     number_list;
    L_SCORE                                     number_list;
    -- Start for the bug#7562130 by PNAVEENK
    L_SCORE_ID                                  number_list;
    L_SCORE_NAME                                varchar_240_list;
    L_COLLECTOR_RESOURCE_NAME                   varchar_240_list;
    -- End for the bug#7562130
    L_ADDRESS1                                  varchar_240_list;
    L_CITY                                      varchar_60_list;
    L_STATE                                     varchar_60_list;
    L_COUNTY                                    varchar_60_list;
    L_COUNTRY                                   varchar_80_list;
    L_PROVINCE                                  varchar_60_list;
    L_POSTAL_CODE                               varchar_60_list;
    L_PHONE_COUNTRY_CODE                        varchar_10_list;
    L_PHONE_AREA_CODE                           varchar_10_list;
    L_PHONE_NUMBER                              varchar_40_list;
    L_PHONE_EXTENSION                           varchar_20_list;
    L_NUMBER_OF_BANKRUPTCIES                    number_list;
    L_NUMBER_OF_PROMISES                        number_list;
    L_BROKEN_PROMISE_AMOUNT                     number_list;
    L_PROMISE_AMOUNT                            number_list;
    L_ACTIVE_PROMISES                           number_list;
    L_COMPLETE_PROMISES                         number_list;
    L_PENDING_PROMISES                          number_list;
    L_WORK_ITEM_ID                              number_list;
    L_SCHEDULE_START                            date_list;
    L_SCHEDULE_END                              date_list;
    L_WORK_TYPE                                 varchar_30_list;
    L_CATEGORY_TYPE                             varchar_30_list;
    L_PRIORITY_TYPE                             varchar_30_list;
    L_JTF_OBJECT_ID                             number_list;
    l_wkitem_resource_id			number_list;
    l_strategy_id				number_list;
    l_strategy_template_id 			number_list;
    l_work_item_template_id 			number_list;
    l_status_code 				varchar_30_list;
    l_str_status                                varchar_30_list;   -- Added for bug#7416344 by PNAVEENK on 2-4-2009
    l_start_time 				date_list;
    l_end_time 					date_list;
    l_work_item_order 				number_list;
    l_escalated_yn                              varchar_10_list;  --Added for bug#6981126 by schekuri on 27-Jun-2008

    l_max_fetches                               NUMBER;
    l_total                                     NUMBER;
    l_count                                     NUMBER;
    l_return                                    boolean;
    l_from_date                                 DATE;
    l_level                                     VARCHAR2(80);
    l_cash                                      VARCHAR2(240);
    l_enable_work_queue				varchar2(10);



  -------------------------------------------------------------------------------

BEGIN

    -- fix for bug 5936061
    if (p_mode = 'DLN') then
        return;
    end if;

    insert_conc_req;

    l_from_date := to_date(substr(FROM_DATE, 1, 10), 'YYYY/MM/DD');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Input FROM_DATE = ' || l_from_date);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Input FROM_DATE = ' || l_from_date);

    l_max_fetches := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '100000'));
    LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Batch size = ' || l_max_fetches);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Batch size = ' || l_max_fetches);

    l_enable_work_queue	:= nvl(fnd_profile.value('IEX_ENABLE_UWQ_STATUS'), 'N');
	LogMessage(FND_LOG.LEVEL_UNEXPECTED,'l_enable_work_queue = ' || l_enable_work_queue);

  --Commented for Bug 8707923 27-JUl-2009 barathsr
  --the variable l_level ceases to exist and is replaced by p_level wherever used
  --since we added p_level as a parameter to the procedure.
   -- OPEN c_get_level;
    --FETCH c_get_level INTO l_level;
    --CLOSE c_get_level;
    LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Level = ' || p_level);

    IF (p_level = 'DELINQUENCY') THEN
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency level is not implemented at this time. Exiting.');
      return;
    END IF;
     -- changed for bug 9498399 PNAVEENK
   -- l_cash := IEX_UTILITIES.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE', 'SELECT DEFAULT_EXCHANGE_RATE_TYPE FROM AR_CMGT_SETUP_OPTIONS');
   -- l_cash := NVL(FND_PROFILE.VALUE('IEX_EXCHANGE_RATE_TYPE'), 'Corporate');  -- Changed for bug#8630157 by PNAVEENK
    l_cash := IEX_UTILITIES.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE','select NVL(FND_PROFILE.VALUE(''IEX_EXCHANGE_RATE_TYPE''),''Corporate'') from dual');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED,'DEFAULT_EXCHANGE_RATE_TYPE = ' || l_cash);
--Start of comment for Bug 8942646 12-Oct-2009 barathsr
--Moved the from_date not null delete part of the code to delete_from_uwq_summ procedure
 /*   IF (l_from_date is not null and G_LEVEL_COUNT=0) then  --Added for Bug 8707923 27-Jul-2009 barathsr
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Partially repopulating IEX_DLN_UWQ_SUMMARY table...');
      /* Begin gnramasa Modified for bug 5677415 27/11/2006 */
 /*     IF p_level = 'CUSTOMER' THEN
          delete from IEX_DLN_UWQ_SUMMARY where (party_id,org_id) in
             (select hza.party_id,trb.org_id from ar_trx_bal_summary trb, hz_cust_accounts hza
                 where hza.cust_account_id = trb.cust_account_id and  trunc(trb.LAST_UPDATE_DATE) >= trunc(l_from_date)
		 and trb.org_id=nvl(p_org_id,trb.org_id));--Added for Bug 8707923 27-Jul-2009 barathsr
      ELSIF p_level = 'ACCOUNT' THEN
          delete from IEX_DLN_UWQ_SUMMARY where (cust_account_id, org_id) in
             (select cust_account_id, org_id from ar_trx_bal_summary trb where trunc(LAST_UPDATE_DATE) >= trunc(l_from_date)
	      and trb.org_id=nvl(p_org_id,trb.org_id));--Added for Bug 8707923 27-Jul-2009 barathsr
      ELSIF p_level = 'BILL_TO' THEN
          delete from IEX_DLN_UWQ_SUMMARY where (cust_account_id, site_use_id, org_id) in
             (select cust_account_id, site_use_id, org_id from ar_trx_bal_summary trb where trunc(LAST_UPDATE_DATE) >= trunc(l_from_date)
	      and trb.org_id=nvl(p_org_id,trb.org_id));--Added for Bug 8707923 27-Jul-2009 barathsr
      END IF;
      /* delete from IEX_DLN_UWQ_SUMMARY where (cust_account_id, site_use_id, org_id) in
         (select cust_account_id, site_use_id, org_id from ar_trx_bal_summary where trunc(LAST_UPDATE_DATE) >= trunc(l_from_date)); */

  --    LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No of rows deleted: ' || SQL%ROWCOUNT);
      /* End gnramasa Modified for bug 5677415 27/11/2006 */
 --     LogMessage(FND_LOG.LEVEL_STATEMENT,'Deleted rows that will be repopulated');
 --   end if;
 --End of comment for Bug 8942646 12-Oct-2009 barathsr

    -- 1. Fetching and inserting data into the table
    LogMessage(FND_LOG.LEVEL_UNEXPECTED,' ');
    LogMessage(FND_LOG.LEVEL_UNEXPECTED,'1. Fetching and inserting data into the table...');

    l_total := 0;
    l_count := 0;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start open cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

    -- Begin - Andre Araujo - 10/20/06 - Added dynamic sql - Assembling BILL_TO query


    IF p_level = 'CUSTOMER' THEN
        if (l_from_date is null) then
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_level = ' || p_level);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'p_org_id = ' || p_org_id);
            OPEN c_iex_cu_uwq_summary(G_SYSTEM_LEVEL,p_org_id);--Added for Bug 8707923 27-Jul-2009 barathsr
	else
	    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_level = ' || p_level);
             FND_FILE.PUT_LINE(FND_FILE.LOG,'p_org_id = ' || p_org_id);
             FND_FILE.PUT_LINE(FND_FILE.LOG,'from_date = ' || l_from_date);
            OPEN c_iex_cu_uwq_dt_sum(l_from_date,G_SYSTEM_LEVEL,p_org_id);--Added for Bug 8707923 27-Jul-2009 barathsr
	end if;
    ELSIF p_level = 'ACCOUNT' THEN
        -- If the date is not null we will not read only the new/updated records
        if (l_from_date is null) then
            OPEN c_iex_acc_uwq_summary(G_SYSTEM_LEVEL,p_org_id);--Added for Bug 8707923 27-Jul-2009 barathsr
        else
            OPEN c_iex_acc_uwq_dt_sum(l_from_date,G_SYSTEM_LEVEL,p_org_id);--Added for Bug 8707923 27-Jul-2009 barathsr
        end if;
    ELSIF p_level = 'BILL_TO' THEN
        -- If the date is not null we will not read only the new/updated records
        if (l_from_date is null) then
	FND_FILE.PUT_LINE(FND_FILE.LOG,'p_level = ' || p_level);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'p_org_id = ' || p_org_id);
            open c_iex_billto_uwq_summary(G_SYSTEM_LEVEL,p_org_id);--Added for Bug 8707923 27-Jul-2009 barathsr
        else
             FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside BillTo');
	     FND_FILE.PUT_LINE(FND_FILE.LOG,'p_level = ' || p_level);
             FND_FILE.PUT_LINE(FND_FILE.LOG,'p_org_id = ' || p_org_id);
             FND_FILE.PUT_LINE(FND_FILE.LOG,'from_date = ' || l_from_date);
            open c_iex_billto_uwq_dt_sum(l_from_date,G_SYSTEM_LEVEL,p_org_id);--Added for Bug 8707923 27-Jul-2009 barathsr
        end if;
    END IF;

    -- End - Andre Araujo - 10/20/06 - Added dynamic sql - Assembling query
    LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End open cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

    LOOP
        l_count := l_count +1;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'----------');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bulk ' || l_count);

        L_ORG_ID.delete;
        L_COLLECTOR_ID.delete;
        L_COLLECTOR_RESOURCE_ID.delete;
        L_COLLECTOR_RES_TYPE.delete;
        L_IEU_OBJECT_FUNCTION.delete;
        L_IEU_OBJECT_PARAMETERS.delete;
        L_IEU_MEDIA_TYPE_UUID.delete;
        L_IEU_PARAM_PK_COL.delete;
        L_IEU_PARAM_PK_VALUE.delete;
        L_RESOURCE_ID.delete;
        L_RESOURCE_TYPE.delete;
        L_PARTY_ID.delete;
        L_PARTY_NAME.delete;
        L_CUST_ACCOUNT_ID.delete;
        L_ACCOUNT_NAME.delete;
        L_ACCOUNT_NUMBER.delete;
        L_SITE_USE_ID.delete;
        L_LOCATION.delete;
        L_CURRENCY.delete;
        L_OP_INVOICES_COUNT.delete;
        L_OP_DEBIT_MEMOS_COUNT.delete;
        L_OP_DEPOSITS_COUNT.delete;
        L_OP_BILLS_RECEIVABLES_COUNT.delete;
        L_OP_CHARGEBACK_COUNT.delete;
        L_OP_CREDIT_MEMOS_COUNT.delete;
        L_UNRESOLVED_CASH_COUNT.delete;
        L_DISPUTED_INV_COUNT.delete;
        L_BEST_CURRENT_RECEIVABLES.delete;
        L_OP_INVOICES_VALUE.delete;
        L_OP_DEBIT_MEMOS_VALUE.delete;
        L_OP_DEPOSITS_VALUE.delete;
        L_OP_BILLS_RECEIVABLES_VALUE.delete;
        L_OP_CHARGEBACK_VALUE.delete;
        L_OP_CREDIT_MEMOS_VALUE.delete;
        L_UNRESOLVED_CASH_VALUE.delete;
        L_RECEIPTS_AT_RISK_VALUE.delete;
        L_INV_AMT_IN_DISPUTE.delete;
        L_PENDING_ADJ_VALUE.delete;
        L_PAST_DUE_INV_VALUE.delete;
        L_PAST_DUE_INV_INST_COUNT.delete;
        L_LAST_PAYMENT_DATE.delete;
        L_LAST_PAYMENT_AMOUNT.delete;
        L_LAST_PAYMENT_AMOUNT_CURR.delete;
        L_LAST_PAYMENT_NUMBER.delete;
        L_LAST_UPDATE_DATE.delete;
        L_LAST_UPDATED_BY.delete;
        L_CREATION_DATE.delete;
        L_CREATED_BY.delete;
        L_LAST_UPDATE_LOGIN.delete;
        L_NUMBER_OF_DELINQUENCIES.delete;
        L_ACTIVE_DELINQUENCIES.delete;
        L_COMPLETE_DELINQUENCIES.delete;
        L_PENDING_DELINQUENCIES.delete;
        L_SCORE.delete;
	-- Start for the bug#7562130 by PNAVEENK
	L_SCORE_ID.delete;
        L_SCORE_NAME.delete;
        L_COLLECTOR_RESOURCE_NAME.delete;
	-- end for the bug#7562130
        L_ADDRESS1.delete;
        L_CITY.delete;
        L_STATE.delete;
        L_COUNTY.delete;
        L_COUNTRY.delete;
        L_PROVINCE.delete;
        L_POSTAL_CODE.delete;
        L_PHONE_COUNTRY_CODE.delete;
        L_PHONE_AREA_CODE.delete;
        L_PHONE_NUMBER.delete;
        L_PHONE_EXTENSION.delete;
        L_NUMBER_OF_BANKRUPTCIES.delete;
        L_NUMBER_OF_PROMISES.delete;
        L_BROKEN_PROMISE_AMOUNT.delete;
        L_PROMISE_AMOUNT.delete;
        L_ACTIVE_PROMISES.delete;
        L_COMPLETE_PROMISES.delete;
        L_PENDING_PROMISES.delete;

        LogMessage(FND_LOG.LEVEL_STATEMENT,'Inited all arrays');

        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        IF p_level = 'CUSTOMER' THEN
            if (l_from_date is null) then
                FETCH c_iex_cu_uwq_summary bulk collect
                INTO
                    L_ORG_ID,
                    L_IEU_OBJECT_FUNCTION,
                    L_IEU_OBJECT_PARAMETERS,
                    L_IEU_MEDIA_TYPE_UUID,
                    L_IEU_PARAM_PK_COL,
                    L_IEU_PARAM_PK_VALUE,
                    L_PARTY_ID,
                    L_CUST_ACCOUNT_ID,
                    L_SITE_USE_ID,
                    L_CURRENCY,
                    L_OP_INVOICES_COUNT,
                    L_OP_DEBIT_MEMOS_COUNT,
                    L_OP_DEPOSITS_COUNT,
                    L_OP_BILLS_RECEIVABLES_COUNT,
                    L_OP_CHARGEBACK_COUNT,
                    L_OP_CREDIT_MEMOS_COUNT,
                    L_UNRESOLVED_CASH_COUNT,
                    L_DISPUTED_INV_COUNT,
                    L_BEST_CURRENT_RECEIVABLES,
                    L_OP_INVOICES_VALUE,
                    L_OP_DEBIT_MEMOS_VALUE,
                    L_OP_DEPOSITS_VALUE,
                    L_OP_BILLS_RECEIVABLES_VALUE,
                    L_OP_CHARGEBACK_VALUE,
                    L_OP_CREDIT_MEMOS_VALUE,
                    L_UNRESOLVED_CASH_VALUE,
                    L_RECEIPTS_AT_RISK_VALUE,
                    L_INV_AMT_IN_DISPUTE,
                    L_PENDING_ADJ_VALUE,
                    L_PAST_DUE_INV_INST_COUNT,
                    L_LAST_PAYMENT_DATE,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_LOGIN
                    limit l_max_fetches;
            Else
                FETCH c_iex_cu_uwq_dt_sum bulk collect
                INTO
                    L_ORG_ID,
                    L_IEU_OBJECT_FUNCTION,
                    L_IEU_OBJECT_PARAMETERS,
                    L_IEU_MEDIA_TYPE_UUID,
                    L_IEU_PARAM_PK_COL,
                    L_IEU_PARAM_PK_VALUE,
                    L_PARTY_ID,
                    L_CUST_ACCOUNT_ID,
                    L_SITE_USE_ID,
                    L_CURRENCY,
                    L_OP_INVOICES_COUNT,
                    L_OP_DEBIT_MEMOS_COUNT,
                    L_OP_DEPOSITS_COUNT,
                    L_OP_BILLS_RECEIVABLES_COUNT,
                    L_OP_CHARGEBACK_COUNT,
                    L_OP_CREDIT_MEMOS_COUNT,
                    L_UNRESOLVED_CASH_COUNT,
                    L_DISPUTED_INV_COUNT,
                    L_BEST_CURRENT_RECEIVABLES,
                    L_OP_INVOICES_VALUE,
                    L_OP_DEBIT_MEMOS_VALUE,
                    L_OP_DEPOSITS_VALUE,
                    L_OP_BILLS_RECEIVABLES_VALUE,
                    L_OP_CHARGEBACK_VALUE,
                    L_OP_CREDIT_MEMOS_VALUE,
                    L_UNRESOLVED_CASH_VALUE,
                    L_RECEIPTS_AT_RISK_VALUE,
                    L_INV_AMT_IN_DISPUTE,
                    L_PENDING_ADJ_VALUE,
                    L_PAST_DUE_INV_INST_COUNT,
                    L_LAST_PAYMENT_DATE,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_LOGIN
                  limit l_max_fetches;
            End If;

        ELSIF p_level = 'ACCOUNT' THEN

            if (l_from_date is null) then
                FETCH c_iex_acc_uwq_summary bulk collect
                INTO
                    L_ORG_ID,
                    L_IEU_OBJECT_FUNCTION,
                    L_IEU_OBJECT_PARAMETERS,
                    L_IEU_MEDIA_TYPE_UUID,
                    L_IEU_PARAM_PK_COL,
                    L_IEU_PARAM_PK_VALUE,
                    L_PARTY_ID,
                   L_CUST_ACCOUNT_ID,
                   L_SITE_USE_ID,
                   L_CURRENCY,
                    L_OP_INVOICES_COUNT,
                    L_OP_DEBIT_MEMOS_COUNT,
                    L_OP_DEPOSITS_COUNT,
                    L_OP_BILLS_RECEIVABLES_COUNT,
                    L_OP_CHARGEBACK_COUNT,
                    L_OP_CREDIT_MEMOS_COUNT,
                    L_UNRESOLVED_CASH_COUNT,
                    L_DISPUTED_INV_COUNT,
                    L_BEST_CURRENT_RECEIVABLES,
                    L_OP_INVOICES_VALUE,
                    L_OP_DEBIT_MEMOS_VALUE,
                    L_OP_DEPOSITS_VALUE,
                    L_OP_BILLS_RECEIVABLES_VALUE,
                    L_OP_CHARGEBACK_VALUE,
                    L_OP_CREDIT_MEMOS_VALUE,
                    L_UNRESOLVED_CASH_VALUE,
                    L_RECEIPTS_AT_RISK_VALUE,
                    L_INV_AMT_IN_DISPUTE,
                    L_PENDING_ADJ_VALUE,
                    L_PAST_DUE_INV_INST_COUNT,
                    L_LAST_PAYMENT_DATE,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_LOGIN
                  limit l_max_fetches;
            Else
                FETCH c_iex_acc_uwq_dt_sum bulk collect
                INTO
                    L_ORG_ID,
                    L_IEU_OBJECT_FUNCTION,
                    L_IEU_OBJECT_PARAMETERS,
                    L_IEU_MEDIA_TYPE_UUID,
                    L_IEU_PARAM_PK_COL,
                    L_IEU_PARAM_PK_VALUE,
                    L_PARTY_ID,
                     L_CUST_ACCOUNT_ID,
                     L_SITE_USE_ID,
                    L_CURRENCY,
                    L_OP_INVOICES_COUNT,
                    L_OP_DEBIT_MEMOS_COUNT,
                    L_OP_DEPOSITS_COUNT,
                    L_OP_BILLS_RECEIVABLES_COUNT,
                    L_OP_CHARGEBACK_COUNT,
                    L_OP_CREDIT_MEMOS_COUNT,
                    L_UNRESOLVED_CASH_COUNT,
                    L_DISPUTED_INV_COUNT,
                    L_BEST_CURRENT_RECEIVABLES,
                    L_OP_INVOICES_VALUE,
                    L_OP_DEBIT_MEMOS_VALUE,
                    L_OP_DEPOSITS_VALUE,
                    L_OP_BILLS_RECEIVABLES_VALUE,
                    L_OP_CHARGEBACK_VALUE,
                    L_OP_CREDIT_MEMOS_VALUE,
                    L_UNRESOLVED_CASH_VALUE,
                    L_RECEIPTS_AT_RISK_VALUE,
                    L_INV_AMT_IN_DISPUTE,
                    L_PENDING_ADJ_VALUE,
                     L_PAST_DUE_INV_INST_COUNT,
                    L_LAST_PAYMENT_DATE,
                   L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_LOGIN
                    limit l_max_fetches;
            End If;

        ELSIF p_level = 'BILL_TO' THEN

            -- If the date is not null we will not read only the new/updated records
            if (l_from_date is null) then
                FETCH c_iex_billto_uwq_summary bulk collect
                INTO
                    L_ORG_ID,
                    L_IEU_OBJECT_FUNCTION,
                    L_IEU_OBJECT_PARAMETERS,
                    L_IEU_MEDIA_TYPE_UUID,
                    L_IEU_PARAM_PK_COL,
                    L_IEU_PARAM_PK_VALUE,
                    L_PARTY_ID,
                    L_CUST_ACCOUNT_ID,
                    L_SITE_USE_ID,
                    L_CURRENCY,
                    L_OP_INVOICES_COUNT,
                    L_OP_DEBIT_MEMOS_COUNT,
                    L_OP_DEPOSITS_COUNT,
                    L_OP_BILLS_RECEIVABLES_COUNT,
                    L_OP_CHARGEBACK_COUNT,
                    L_OP_CREDIT_MEMOS_COUNT,
                    L_UNRESOLVED_CASH_COUNT,
                    L_DISPUTED_INV_COUNT,
                    L_BEST_CURRENT_RECEIVABLES,
                    L_OP_INVOICES_VALUE,
                    L_OP_DEBIT_MEMOS_VALUE,
                    L_OP_DEPOSITS_VALUE,
                    L_OP_BILLS_RECEIVABLES_VALUE,
                    L_OP_CHARGEBACK_VALUE,
                    L_OP_CREDIT_MEMOS_VALUE,
                    L_UNRESOLVED_CASH_VALUE,
                    L_RECEIPTS_AT_RISK_VALUE,
                    L_INV_AMT_IN_DISPUTE,
                    L_PENDING_ADJ_VALUE,
                     L_PAST_DUE_INV_INST_COUNT,
                    L_LAST_PAYMENT_DATE,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_LOGIN
                    limit l_max_fetches;
            else
                FETCH c_iex_billto_uwq_dt_sum bulk collect
                INTO
                    L_ORG_ID,
                     L_IEU_OBJECT_FUNCTION,
                    L_IEU_OBJECT_PARAMETERS,
                    L_IEU_MEDIA_TYPE_UUID,
                    L_IEU_PARAM_PK_COL,
                    L_IEU_PARAM_PK_VALUE,
                    L_PARTY_ID,
                     L_CUST_ACCOUNT_ID,
                     L_SITE_USE_ID,
                     L_CURRENCY,
                    L_OP_INVOICES_COUNT,
                    L_OP_DEBIT_MEMOS_COUNT,
                    L_OP_DEPOSITS_COUNT,
                    L_OP_BILLS_RECEIVABLES_COUNT,
                    L_OP_CHARGEBACK_COUNT,
                    L_OP_CREDIT_MEMOS_COUNT,
                    L_UNRESOLVED_CASH_COUNT,
                    L_DISPUTED_INV_COUNT,
                    L_BEST_CURRENT_RECEIVABLES,
                    L_OP_INVOICES_VALUE,
                    L_OP_DEBIT_MEMOS_VALUE,
                    L_OP_DEPOSITS_VALUE,
                    L_OP_BILLS_RECEIVABLES_VALUE,
                    L_OP_CHARGEBACK_VALUE,
                    L_OP_CREDIT_MEMOS_VALUE,
                    L_UNRESOLVED_CASH_VALUE,
                    L_RECEIPTS_AT_RISK_VALUE,
                    L_INV_AMT_IN_DISPUTE,
                    L_PENDING_ADJ_VALUE,
                    L_PAST_DUE_INV_INST_COUNT,
                    L_LAST_PAYMENT_DATE,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_LOGIN
                   limit l_max_fetches;
            End If;
        END IF;

        IF L_IEU_OBJECT_FUNCTION.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

        ELSE
           FND_FILE.PUT_LINE(FND_FILE.LOG,'no.of records fetched ' || L_IEU_OBJECT_FUNCTION.COUNT);
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Fetched  ' || L_IEU_OBJECT_FUNCTION.COUNT || ' rows.');
          LogMessage(FND_LOG.LEVEL_STATEMENT,'Inserting...');
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start inserting time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

          forall i IN L_IEU_OBJECT_FUNCTION.FIRST .. L_IEU_OBJECT_FUNCTION.LAST
            INSERT INTO IEX_DLN_UWQ_SUMMARY
                (DLN_UWQ_SUMMARY_ID
                ,ORG_ID
                ,IEU_OBJECT_FUNCTION
                ,IEU_OBJECT_PARAMETERS
                ,IEU_MEDIA_TYPE_UUID
                ,IEU_PARAM_PK_COL
                ,IEU_PARAM_PK_VALUE
                ,PARTY_ID
                ,CUST_ACCOUNT_ID
                ,SITE_USE_ID
                ,CURRENCY
                ,OP_INVOICES_COUNT
                ,OP_DEBIT_MEMOS_COUNT
                ,OP_DEPOSITS_COUNT
                ,OP_BILLS_RECEIVABLES_COUNT
                ,OP_CHARGEBACK_COUNT
                ,OP_CREDIT_MEMOS_COUNT
                ,UNRESOLVED_CASH_COUNT
                ,DISPUTED_INV_COUNT
                ,BEST_CURRENT_RECEIVABLES
                ,OP_INVOICES_VALUE
                ,OP_DEBIT_MEMOS_VALUE
                ,OP_DEPOSITS_VALUE
                ,OP_BILLS_RECEIVABLES_VALUE
                ,OP_CHARGEBACK_VALUE
                ,OP_CREDIT_MEMOS_VALUE
                ,UNRESOLVED_CASH_VALUE
                ,RECEIPTS_AT_RISK_VALUE
                ,INV_AMT_IN_DISPUTE
                ,PENDING_ADJ_VALUE
                ,PAST_DUE_INV_INST_COUNT
                ,LAST_PAYMENT_DATE
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_LOGIN
         	,NUMBER_OF_BANKRUPTCIES
		,BUSINESS_LEVEL)--Added for Bug 8707923 27-Jul-2009 barathsr

            VALUES
                (IEX_DLN_UWQ_SUMMARY_S.nextval,
                L_ORG_ID(i),
                L_IEU_OBJECT_FUNCTION(i),
                L_IEU_OBJECT_PARAMETERS(i),
                L_IEU_MEDIA_TYPE_UUID(i),
                L_IEU_PARAM_PK_COL(i),
                L_IEU_PARAM_PK_VALUE(i),
                L_PARTY_ID(i),
                L_CUST_ACCOUNT_ID(i),
                L_SITE_USE_ID(i),
                L_CURRENCY(i),
                L_OP_INVOICES_COUNT(i),
                L_OP_DEBIT_MEMOS_COUNT(i),
                L_OP_DEPOSITS_COUNT(i),
                L_OP_BILLS_RECEIVABLES_COUNT(i),
                L_OP_CHARGEBACK_COUNT(i),
                L_OP_CREDIT_MEMOS_COUNT(i),
                L_UNRESOLVED_CASH_COUNT(i),
                L_DISPUTED_INV_COUNT(i),
                L_BEST_CURRENT_RECEIVABLES(i),
                L_OP_INVOICES_VALUE(i),
                L_OP_DEBIT_MEMOS_VALUE(i),
                L_OP_DEPOSITS_VALUE(i),
                L_OP_BILLS_RECEIVABLES_VALUE(i),
                L_OP_CHARGEBACK_VALUE(i),
                L_OP_CREDIT_MEMOS_VALUE(i),
                L_UNRESOLVED_CASH_VALUE(i),
                L_RECEIPTS_AT_RISK_VALUE(i),
                L_INV_AMT_IN_DISPUTE(i),
                L_PENDING_ADJ_VALUE(i),
                L_PAST_DUE_INV_INST_COUNT(i),
                L_LAST_PAYMENT_DATE(i),
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.CONC_LOGIN_ID,
                0,
		p_level);--Added for Bug 8707923 27-Jul-2009 barathsr

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End inserting time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Inserted ' || L_IEU_OBJECT_FUNCTION.COUNT || ' rows');

          COMMIT;
          LogMessage(FND_LOG.LEVEL_STATEMENT,'Commited');

          l_total := l_total + L_IEU_OBJECT_FUNCTION.COUNT;
          LogMessage(FND_LOG.LEVEL_STATEMENT,'So far processed ' || l_total || ' rows');

        END IF;

      END LOOP;

      IF c_iex_acc_uwq_summary % ISOPEN    or
         c_iex_acc_uwq_dt_sum % ISOPEN     or
         c_iex_billto_uwq_summary % ISOPEN or
         c_iex_billto_uwq_dt_sum % ISOPEN or
         c_iex_cu_uwq_summary % ISOPEN or
         c_iex_cu_uwq_dt_sum % ISOPEN
      THEN
        -- Begin - Andre Araujo - 10/20/06 - Added dynamic sql
          -- If the date is not null we will not read only the new/updated records

          IF p_level = 'CUSTOMER' THEN
              if (l_from_date is null) then
                CLOSE c_iex_cu_uwq_summary;
		--Begin Bug 9597052 28-Apr-2010 barathsr
		if p_mode='CP' then
		    BEGIN--start 9597052
			OPEN C_cust_DETAILS;
			LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_cust_DETAILS cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_PARTY_ID.delete;
			 L_ORG_ID.delete;
			L_PARTY_NAME.delete;
			L_ACCOUNT_NAME.delete;
			L_ACCOUNT_NUMBER.delete;
			L_LOCATION.delete;
			L_ADDRESS1.delete;
			L_CITY.delete;
			L_STATE.delete;
			L_COUNTY.delete;
			L_COUNTRY.delete;
			L_PROVINCE.delete;
			L_POSTAL_CODE.delete;

		    LOOP
			FETCH C_cust_DETAILS bulk collect
			INTO
			L_PARTY_ID,
			 L_ORG_ID,
			L_PARTY_NAME,
			L_ACCOUNT_NAME,
			L_ACCOUNT_NUMBER,
			L_LOCATION,
			L_ADDRESS1,
			L_CITY,
			L_STATE,
			L_COUNTY,
			L_COUNTRY,
			L_PROVINCE,
			L_POSTAL_CODE
			limit l_max_fetches;
				IF L_party_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_cust_DETAILS ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
				EXIT;
			ELSE

			   forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			     UPDATE IEX_DLN_UWQ_SUMMARY
			     SET --PARTY_ID = L_PARTY_ID(i),
				PARTY_NAME = L_PARTY_NAME(i),
				ACCOUNT_NAME = L_ACCOUNT_NAME(i),
				ACCOUNT_NUMBER = L_ACCOUNT_NUMBER(i),
				LOCATION = L_LOCATION(i),
				ADDRESS1 = L_ADDRESS1(i),
				CITY = L_CITY(i),
				STATE = L_STATE(i),
				COUNTY = L_COUNTY(i),
				COUNTRY = L_COUNTRY(i),
				PROVINCE = L_PROVINCE(i),
				POSTAL_CODE = L_POSTAL_CODE(i)
			     WHERE
			     party_id = L_party_id(i)
			     and org_id= L_ORG_ID(i);
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_cust_DETAILS updated ' || L_cust_account_id.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
		       END IF;
		    END LOOP;
		   IF C_cust_DETAILS % ISOPEN THEN
		       CLOSE C_cust_DETAILS;
		   END IF;

		EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'a/c update received' || SQLERRM);
		END;

		BEGIN
	       OPEN c_cu_contact_point;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened Cursor  c_cu_contact_point  cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_PARTY_ID.delete;
		 L_ORG_ID.delete;
		L_PHONE_COUNTRY_CODE.delete;
		L_PHONE_AREA_CODE.delete;
		L_PHONE_NUMBER.delete;
		L_PHONE_EXTENSION.delete;


	      LOOP
		 FETCH c_cu_contact_point bulk collect
		  INTO
		   L_PARTY_ID, L_ORG_ID,
		   L_PHONE_COUNTRY_CODE,
		   L_PHONE_AREA_CODE,
		   L_PHONE_NUMBER,
		   L_PHONE_EXTENSION

		  limit l_max_fetches;
	      IF L_PARTY_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'c_cu_contact_point  Cursor Fetching end time:   ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

		ELSE

		forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST

			   UPDATE IEX_DLN_UWQ_SUMMARY
			   SET PHONE_COUNTRY_CODE = L_PHONE_COUNTRY_CODE(i),
			       PHONE_AREA_CODE    = L_PHONE_AREA_CODE(i),
			       PHONE_NUMBER       = L_PHONE_NUMBER(i),
			       PHONE_EXTENSION    = L_PHONE_EXTENSION(i),
			       last_update_date   = SYSDATE,
			       last_updated_by    = FND_GLOBAL.USER_ID
			 WHERE PARTY_ID = L_PARTY_ID(i)
			 and  ORG_ID= L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_cu_contact_point Cursor updated ' ||L_PARTY_ID.count || ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;

	      IF c_cu_contact_point % ISOPEN THEN
		       CLOSE c_cu_contact_point;
		   END IF;


	      EXCEPTION WHEN OTHERS THEN
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Contact point raised error ' || SQLERRM);
	      END;

	      BEGIN
	      OPEN C_cu_COLLECTOR_PROF;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_cu_COLLECTOR_PROF cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_RESOURCE_ID.delete;
		L_COLLECTOR_RES_TYPE.delete;
		L_COLLECTOR_RESOURCE_ID.delete  ;
		L_COLLECTOR_RESOURCE_NAME.delete;
		L_COLLECTOR_ID.delete;
		L_RESOURCE_TYPE.delete;
		 L_ORG_ID.delete;
		L_PARTY_ID.delete;
	--	L_CUST_ACCOUNT_ID.delete;
	--	L_SITE_USE_ID.delete;

	      LOOP
		FETCH C_cu_COLLECTOR_PROF bulk collect
		  INTO
		    L_COLLECTOR_ID,L_ORG_ID,
		    L_COLLECTOR_RESOURCE_ID,
		    L_COLLECTOR_RES_TYPE,
		    L_COLLECTOR_RESOURCE_NAME,
		    L_RESOURCE_ID,
		    L_RESOURCE_TYPE,
		    L_PARTY_ID
	--	    L_CUST_ACCOUNT_ID
		 --   L_SITE_USE_ID
		  limit l_max_fetches;
	      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_cu_COLLECTOR_PROF ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
				COLLECTOR_RES_TYPE    = L_COLLECTOR_RES_TYPE(i),
				collector_resource_name = L_COLLECTOR_RESOURCE_NAME(i),
				collector_id = l_collector_id(i),
				resource_id=l_resource_id(i),
				resource_type=l_resource_type(i),
				last_update_date   = SYSDATE,
				last_updated_by    = FND_GLOBAL.USER_ID
			   WHERE
			    party_id = L_party_id(i)
			    and org_id= L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_cu_COLLECTOR_PROF updated ' || L_COLLECTOR_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_cu_COLLECTOR_PROF % ISOPEN THEN
		CLOSE C_cu_COLLECTOR_PROF;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'C_cu_COLLECTOR_PROF update received' || SQLERRM);
	       END;

	       BEGIN
	      OPEN C_cu_PRO_DTLS;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_cu_pro_dtls cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_party_ID.delete; L_ORG_ID.delete;
		L_NUMBER_OF_PROMISES.delete;
		L_BROKEN_PROMISE_AMOUNT .delete;
		L_PROMISE_AMOUNT.delete;

	      LOOP
		FETCH C_cu_PRO_DTLS bulk collect
		  INTO
		    L_party_id, L_ORG_ID,
		    L_NUMBER_OF_PROMISES,
		    L_BROKEN_PROMISE_AMOUNT,
		    L_PROMISE_AMOUNT
		  limit l_max_fetches;
	      IF L_party_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_cu_pro_summ ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET NUMBER_OF_PROMISES     = L_NUMBER_OF_PROMISES(i),
				BROKEN_PROMISE_AMOUNT  = L_BROKEN_PROMISE_AMOUNT(i),
				PROMISE_AMOUNT         = L_PROMISE_AMOUNT(i)
			   WHERE
			    party_ID = L_party_ID(i)
			    and org_id= L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_cu_pro_dtls updated ' || L_party_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_cu_PRO_DTLS % ISOPEN THEN
		CLOSE C_cu_PRO_DTLS;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Broken Promise update received' || SQLERRM);
	       END;

		BEGIN
			OPEN C_cu_DELN_CNT;
			LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_cu_deln_cnt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_party_ID.delete; L_ORG_ID.delete;
			L_NUMBER_OF_DELINQUENCIES.delete;
			L_PAST_DUE_INV_VALUE.delete;

		    LOOP
			FETCH C_cu_DELN_CNT bulk collect
			INTO
			L_party_ID, L_ORG_ID,
			L_NUMBER_OF_DELINQUENCIES,
			L_PAST_DUE_INV_VALUE
			limit l_max_fetches;
			IF L_party_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_cu_deln_cnt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
				EXIT;
			ELSE

			   forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			     UPDATE IEX_DLN_UWQ_SUMMARY
			     SET NUMBER_OF_DELINQUENCIES = L_NUMBER_OF_DELINQUENCIES(i),
				 PAST_DUE_INV_VALUE = L_PAST_DUE_INV_VALUE(i)
			     WHERE
			     party_id = L_party_ID(i)
			     and org_id= L_ORG_ID(i);
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_cu_del_cnt updated ' || L_party_ID.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
		       END IF;
		    END LOOP;
		   IF C_cu_DELN_CNT % ISOPEN THEN
		       CLOSE C_cu_DELN_CNT;
		   END IF;

		EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
		END;

	        if l_enable_work_queue = 'Y' then  --update active,pending and complete nodes of delinquency and promise only when the profile 'IEX: Enable Work Queue Statuses' is set to Yes.
			BEGIN
				OPEN C_cu_DELN_DTLS;
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_cu_deln_dln cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				L_party_ID.delete; L_ORG_ID.delete;
				L_PENDING_DELINQUENCIES.delete;
				L_COMPLETE_DELINQUENCIES.delete;
				L_ACTIVE_DELINQUENCIES.delete;

			    LOOP
				FETCH C_cu_DELN_DTLS bulk collect
				INTO
				L_party_ID, L_ORG_ID,
				L_PENDING_DELINQUENCIES,
				L_COMPLETE_DELINQUENCIES,
				L_ACTIVE_DELINQUENCIES
				limit l_max_fetches;
				IF L_party_ID.COUNT = 0 THEN
					LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_cu_deln_dtls ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
					LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
					EXIT;
				ELSE

				   forall i IN L_party_ID.FIRST .. L_party_ID.LAST
				     UPDATE IEX_DLN_UWQ_SUMMARY
				     SET PENDING_DELINQUENCIES   = L_PENDING_DELINQUENCIES(i),
					 COMPLETE_DELINQUENCIES  = L_COMPLETE_DELINQUENCIES(i),
					 ACTIVE_DELINQUENCIES    = L_ACTIVE_DELINQUENCIES(i)
				     WHERE
				     party_ID = L_party_ID(i)
				     and org_id= L_ORG_ID(i);
				     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_cu_deln_dtls updated ' || L_party_ID.count ||  ' rows ');
				     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
			       END IF;
			    END LOOP;
			   IF C_cu_DELN_DTLS % ISOPEN THEN
			       CLOSE C_cu_DELN_DTLS;
			   END IF;

			EXCEPTION WHEN OTHERS THEN
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
			END;

		      BEGIN
		      OPEN C_cu_PRO_SUMM;
		       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_cu_pro_summ cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_party_ID.delete; L_ORG_ID.delete;
			L_ACTIVE_PROMISES.delete;
			L_COMPLETE_PROMISES.delete;
			L_PENDING_PROMISES.delete;

		      LOOP
			FETCH C_cu_PRO_SUMM bulk collect
			  INTO
			    L_party_ID, L_ORG_ID,
			    L_PENDING_PROMISES,
			    L_COMPLETE_PROMISES,
			    L_ACTIVE_PROMISES
			  limit l_max_fetches;
		      IF L_party_ID.COUNT = 0 THEN

			  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_cu_pro_summ ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
			  EXIT;

		       ELSE

			forall i IN L_party_ID.FIRST .. L_party_ID.LAST
				   UPDATE IEX_DLN_UWQ_SUMMARY
				    SET ACTIVE_PROMISES    = L_ACTIVE_PROMISES(i),
					COMPLETE_PROMISES  = L_COMPLETE_PROMISES(i),
					PENDING_PROMISES   = L_PENDING_PROMISES(i)
				   WHERE
				   party_ID = L_party_ID(i)
				   and org_id= L_ORG_ID(i);
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_cu_pro_summ updated ' || L_party_ID.count ||  ' rows ');
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


		      END IF;
		      END LOOP;

		       IF C_cu_PRO_SUMM % ISOPEN THEN
			CLOSE C_cu_PRO_SUMM;
		       END IF;

		       EXCEPTION WHEN OTHERS THEN
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Promise update received' || SQLERRM);
		       END;
	      end if; --if l_enable_work_queue = 'Y' then

	      BEGIN
	      OPEN C_cu_LAST_PAYMENT_DTLS;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_cu_LAST_PAYMENT_DTLS cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_party_ID.delete; L_ORG_ID.delete;
		L_LAST_PAYMENT_AMOUNT.delete;
		L_LAST_PAYMENT_AMOUNT_CURR.delete;
		L_LAST_PAYMENT_NUMBER.delete;

	      LOOP
		FETCH C_cu_LAST_PAYMENT_DTLS bulk collect
		  INTO
		    L_party_ID, L_ORG_ID,
		    L_LAST_PAYMENT_AMOUNT,
		    L_LAST_PAYMENT_AMOUNT_CURR,
		    L_LAST_PAYMENT_NUMBER
		  limit l_max_fetches;
	      IF L_party_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_cu_last_payment_dtls_ ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET LAST_PAYMENT_AMOUNT = gl_currency_api.convert_amount_sql(L_LAST_PAYMENT_AMOUNT_CURR(i), CURRENCY,
						       sysdate,iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE', ''), L_LAST_PAYMENT_AMOUNT(i)),
				LAST_PAYMENT_AMOUNT_CURR = L_LAST_PAYMENT_AMOUNT_CURR(i),
				LAST_PAYMENT_NUMBER = L_LAST_PAYMENT_NUMBER(i)
			   WHERE
			    party_ID = L_party_ID(i)
			    and org_id= L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_cu_LAST_PAYMENT_dtls updated ' || L_LAST_PAYMENT_AMOUNT.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_cu_LAST_PAYMENT_DTLS % ISOPEN THEN
		CLOSE C_cu_LAST_PAYMENT_DTLS;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Last payment amount update received' || SQLERRM);
	       END;

	      BEGIN
	      OPEN C_cu_BANKRUPTCIES;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_cu_BANKRUPTCIES cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_PARTY_ID.delete;L_ORG_ID.delete;
		L_NUMBER_OF_BANKRUPTCIES.delete;

	      LOOP
		FETCH C_cu_BANKRUPTCIES bulk collect
		  INTO
		    L_PARTY_ID, L_ORG_ID,
		    L_NUMBER_OF_BANKRUPTCIES
		  limit l_max_fetches;
	      IF L_PARTY_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_cu_BANKRUPTCIES ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET NUMBER_OF_BANKRUPTCIES     = L_NUMBER_OF_BANKRUPTCIES(i)
			   WHERE
			    PARTY_ID = L_PARTY_ID(i)
			    and org_id= L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_cu_BANKRUPTCIES updated ' || L_PARTY_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_cu_BANKRUPTCIES % ISOPEN THEN
		CLOSE C_cu_BANKRUPTCIES;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bankruptcy update received' || SQLERRM);
	       END;
              COMMIT;
               LogMessage(FND_LOG.LEVEL_STATEMENT,'Commited');

	      BEGIN
	      OPEN C_cu_SCORE;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_cu_score cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_party_ID.delete;
		L_SCORE.delete;
		L_SCORE_ID.delete;
		L_SCORE_NAME.delete;

	      LOOP
		FETCH C_cu_SCORE bulk collect
		  INTO
		    L_party_ID,
		    L_SCORE,
		    l_score_id,
		    l_score_name
		  limit l_max_fetches;
	      IF L_party_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_cu_score ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET SCORE     = L_SCORE(i),
				score_id=l_score_id(i),
				score_name=l_score_name(i)
			   WHERE
			    party_ID = L_party_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_cu_score updated ' || L_cust_account_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_cu_SCORE % ISOPEN THEN
		CLOSE C_cu_SCORE;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Score update received' || SQLERRM);
	       END;--end 9597052
	    end if;
	  --End Bug 9597052 28-Apr-2010 barathsr
              else
                CLOSE c_iex_cu_uwq_dt_sum;
	 --Begin Bug 9597052 28-Apr-2010 barathsr
		if p_mode='CP' then
		    BEGIN--start 9597052
			OPEN C_cust_DETAILS_dt;
			LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_cust_DETAILS_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_PARTY_ID.delete; L_ORG_ID.delete;
			L_PARTY_NAME.delete;
			L_ACCOUNT_NAME.delete;
			L_ACCOUNT_NUMBER.delete;
			L_LOCATION.delete;
			L_ADDRESS1.delete;
			L_CITY.delete;
			L_STATE.delete;
			L_COUNTY.delete;
			L_COUNTRY.delete;
			L_PROVINCE.delete;
			L_POSTAL_CODE.delete;

		    LOOP
			FETCH C_cust_DETAILS_dt bulk collect
			INTO
			L_PARTY_ID, L_ORG_ID,
			L_PARTY_NAME,
			L_ACCOUNT_NAME,
			L_ACCOUNT_NUMBER,
			L_LOCATION,
			L_ADDRESS1,
			L_CITY,
			L_STATE,
			L_COUNTY,
			L_COUNTRY,
			L_PROVINCE,
			L_POSTAL_CODE
			limit l_max_fetches;
				IF L_party_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_cust_DETAILS_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
				EXIT;
			ELSE

			   forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			     UPDATE IEX_DLN_UWQ_SUMMARY
			     SET --PARTY_ID = L_PARTY_ID(i),
				PARTY_NAME = L_PARTY_NAME(i),
				ACCOUNT_NAME = L_ACCOUNT_NAME(i),
				ACCOUNT_NUMBER = L_ACCOUNT_NUMBER(i),
				LOCATION = L_LOCATION(i),
				ADDRESS1 = L_ADDRESS1(i),
				CITY = L_CITY(i),
				STATE = L_STATE(i),
				COUNTY = L_COUNTY(i),
				COUNTRY = L_COUNTRY(i),
				PROVINCE = L_PROVINCE(i),
				POSTAL_CODE = L_POSTAL_CODE(i)
			     WHERE
			     party_id = L_party_id(i)
			     and org_id= L_ORG_ID(i);
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_cust_DETAILS_dt updated ' || L_party_id.count ||  ' rows ');
			     FND_FILE.PUT_LINE(FND_FILE.LOG, ' C_cust_DETAILS_dt updated ' || L_party_id.count ||  ' rows ') ;
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
		       END IF;
		    END LOOP;
		   IF C_cust_DETAILS_dt % ISOPEN THEN
		       CLOSE C_cust_DETAILS_dt;
		   END IF;

		EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'customer details update received' || SQLERRM);
		END;

		BEGIN
	       OPEN c_cu_contact_point_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened Cursor  c_cu_contact_point_dt  cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_PARTY_ID.delete; L_ORG_ID.delete;
		L_PHONE_COUNTRY_CODE.delete;
		L_PHONE_AREA_CODE.delete;
		L_PHONE_NUMBER.delete;
		L_PHONE_EXTENSION.delete;


	      LOOP
		 FETCH c_cu_contact_point_dt bulk collect
		  INTO
		   L_PARTY_ID, L_ORG_ID,
		   L_PHONE_COUNTRY_CODE,
		   L_PHONE_AREA_CODE,
		   L_PHONE_NUMBER,
		   L_PHONE_EXTENSION

		  limit l_max_fetches;
	      IF L_PARTY_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'c_cu_contact_point_dt  Cursor Fetching end time:   ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

		ELSE

		forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST

			   UPDATE IEX_DLN_UWQ_SUMMARY
			   SET PHONE_COUNTRY_CODE = L_PHONE_COUNTRY_CODE(i),
			       PHONE_AREA_CODE    = L_PHONE_AREA_CODE(i),
			       PHONE_NUMBER       = L_PHONE_NUMBER(i),
			       PHONE_EXTENSION    = L_PHONE_EXTENSION(i),
			       last_update_date   = SYSDATE,
			       last_updated_by    = FND_GLOBAL.USER_ID
			 WHERE PARTY_ID = L_PARTY_ID(i)
			 and org_id= L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_cu_contact_point_dt Cursor updated ' ||L_PARTY_ID.count || ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;

	      IF c_cu_contact_point_dt % ISOPEN THEN
		       CLOSE c_cu_contact_point_dt;
		   END IF;


	      EXCEPTION WHEN OTHERS THEN
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Contact point raised error ' || SQLERRM);
	      END;

	      BEGIN
	      OPEN C_cu_COLLECTOR_PROF_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_cu_COLLECTOR_PROF_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_RESOURCE_ID.delete;
		L_COLLECTOR_RES_TYPE.delete;
		L_COLLECTOR_RESOURCE_ID.delete  ;
		L_COLLECTOR_RESOURCE_NAME.delete;
		L_COLLECTOR_ID.delete;
		L_RESOURCE_TYPE.delete;
		L_PARTY_ID.delete; L_ORG_ID.delete;
	--	L_CUST_ACCOUNT_ID.delete;
	--	L_SITE_USE_ID.delete;

	      LOOP
		FETCH C_cu_COLLECTOR_PROF_dt bulk collect
		  INTO
		    L_COLLECTOR_ID, L_ORG_ID,
		    L_COLLECTOR_RESOURCE_ID,
		    L_COLLECTOR_RES_TYPE,
		    L_COLLECTOR_RESOURCE_NAME,
		    L_RESOURCE_ID,
		    L_RESOURCE_TYPE,
		    L_PARTY_ID
	--	    L_CUST_ACCOUNT_ID
		 --   L_SITE_USE_ID
		  limit l_max_fetches;
	      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_cu_COLLECTOR_PROF_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
				COLLECTOR_RES_TYPE    = L_COLLECTOR_RES_TYPE(i),
				collector_resource_name = L_COLLECTOR_RESOURCE_NAME(i),
				collector_id = l_collector_id(i),
				resource_id=l_resource_id(i),
				resource_type=l_resource_type(i),
				last_update_date   = SYSDATE,
				last_updated_by    = FND_GLOBAL.USER_ID
			   WHERE
			    party_id = L_party_id(i)
			    and org_id= L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_cu_COLLECTOR_PROF_dt updated ' || L_COLLECTOR_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_cu_COLLECTOR_PROF_dt % ISOPEN THEN
		CLOSE C_cu_COLLECTOR_PROF_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'C_cu_COLLECTOR_PROF_dt update received' || SQLERRM);
	       END;

	       BEGIN
	      OPEN C_cu_ch_coll_dt_sum;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_cu_ch_coll_dt_sum cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_COLLECTOR_RES_TYPE.delete;
		L_COLLECTOR_RESOURCE_ID.delete  ;
		L_COLLECTOR_ID.delete;
		L_party_ID.delete; L_ORG_ID.delete;

	      LOOP
		FETCH C_cu_ch_coll_dt_sum bulk collect
		  INTO
		    L_COLLECTOR_RESOURCE_ID,L_ORG_ID,
		    L_COLLECTOR_RES_TYPE,
		    L_COLLECTOR_ID,
		    L_party_ID
		  limit l_max_fetches;
	      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_cu_ch_coll_dt_sum ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
				COLLECTOR_RES_TYPE    = L_COLLECTOR_RES_TYPE(i),
				collector_id = l_collector_id(i),
				last_update_date   = SYSDATE,
				last_updated_by    = FND_GLOBAL.USER_ID
			   WHERE
			    party_id = L_party_ID(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_cu_ch_coll_dt_sum updated ' || L_COLLECTOR_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_cu_ch_coll_dt_sum % ISOPEN THEN
		CLOSE C_cu_ch_coll_dt_sum;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'C_cu_ch_coll_dt_sum update received' || SQLERRM);
	       END;


	       BEGIN
	      OPEN C_cu_PRO_DTLS_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_cu_pro_dtls_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_party_ID.delete;
		L_NUMBER_OF_PROMISES.delete;
		L_BROKEN_PROMISE_AMOUNT .delete;
		L_PROMISE_AMOUNT.delete;L_ORG_ID.delete;

	      LOOP
		FETCH C_cu_PRO_DTLS_dt bulk collect
		  INTO
		    L_party_id,L_ORG_ID,
		    L_NUMBER_OF_PROMISES,
		    L_BROKEN_PROMISE_AMOUNT,
		    L_PROMISE_AMOUNT
		  limit l_max_fetches;
	      IF L_party_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_cu_pro_dtls_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET NUMBER_OF_PROMISES     = L_NUMBER_OF_PROMISES(i),
				BROKEN_PROMISE_AMOUNT  = L_BROKEN_PROMISE_AMOUNT(i),
				PROMISE_AMOUNT         = L_PROMISE_AMOUNT(i)
			   WHERE
			    party_ID = L_party_ID(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_cu_pro_dtls_dt updated ' || L_party_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_cu_PRO_DTLS_dt % ISOPEN THEN
		CLOSE C_cu_PRO_DTLS_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Broken Promise update received' || SQLERRM);
	       END;

		BEGIN
			OPEN C_cu_DELN_CNT_dt;
			LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_cu_deln_cnt_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_party_ID.delete;L_ORG_ID.delete;
			L_NUMBER_OF_DELINQUENCIES.delete;
			L_PAST_DUE_INV_VALUE.delete;

		    LOOP
			FETCH C_cu_DELN_CNT_dt bulk collect
			INTO
			L_party_ID,L_ORG_ID,
			L_NUMBER_OF_DELINQUENCIES,
			L_PAST_DUE_INV_VALUE
			limit l_max_fetches;
			IF L_party_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_cu_deln_cnt_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
				EXIT;
			ELSE

			   forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			     UPDATE IEX_DLN_UWQ_SUMMARY
			     SET NUMBER_OF_DELINQUENCIES = L_NUMBER_OF_DELINQUENCIES(i),
				 PAST_DUE_INV_VALUE = L_PAST_DUE_INV_VALUE(i)
			     WHERE
			     party_id = L_party_ID(i)
			     and org_id=L_ORG_ID(i);
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_cu_del_cnt_dt updated ' || L_party_ID.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
		       END IF;
		    END LOOP;
		   IF C_cu_DELN_CNT_dt % ISOPEN THEN
		       CLOSE C_cu_DELN_CNT_dt;
		   END IF;

		EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
		END;

	        if l_enable_work_queue = 'Y' then  --update active,pending and complete nodes of delinquency and promise only when the profile 'IEX: Enable Work Queue Statuses' is set to Yes.
			BEGIN
				OPEN C_cu_DELN_DTLS_dt;
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_cu_deln_dtls_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				L_party_ID.delete;L_ORG_ID.delete;
				L_PENDING_DELINQUENCIES.delete;
				L_COMPLETE_DELINQUENCIES.delete;
				L_ACTIVE_DELINQUENCIES.delete;

			    LOOP
				FETCH C_cu_DELN_DTLS_dt bulk collect
				INTO
				L_party_ID,L_ORG_ID,
				L_PENDING_DELINQUENCIES,
				L_COMPLETE_DELINQUENCIES,
				L_ACTIVE_DELINQUENCIES
				limit l_max_fetches;
				IF L_party_ID.COUNT = 0 THEN
					LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_cu_deln_dtls_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
					LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
					EXIT;
				ELSE

				   forall i IN L_party_ID.FIRST .. L_party_ID.LAST
				     UPDATE IEX_DLN_UWQ_SUMMARY
				     SET PENDING_DELINQUENCIES   = L_PENDING_DELINQUENCIES(i),
					 COMPLETE_DELINQUENCIES  = L_COMPLETE_DELINQUENCIES(i),
					 ACTIVE_DELINQUENCIES    = L_ACTIVE_DELINQUENCIES(i)
				     WHERE
				     party_ID = L_party_ID(i)
				     and org_id=L_ORG_ID(i);
				     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_cu_deln_dtls_dt updated ' || L_party_ID.count ||  ' rows ');
				     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
			       END IF;
			    END LOOP;
			   IF C_cu_DELN_DTLS_dt % ISOPEN THEN
			       CLOSE C_cu_DELN_DTLS_dt;
			   END IF;

			EXCEPTION WHEN OTHERS THEN
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
			END;

		      BEGIN
		      OPEN C_cu_PRO_SUMM_dt;
		       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_cu_pro_summ_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_party_ID.delete;L_ORG_ID.delete;
			L_ACTIVE_PROMISES.delete;
			L_COMPLETE_PROMISES.delete;
			L_PENDING_PROMISES.delete;

		      LOOP
			FETCH C_cu_PRO_SUMM_dt bulk collect
			  INTO
			    L_party_ID,L_ORG_ID,
			    L_PENDING_PROMISES,
			    L_COMPLETE_PROMISES,
			    L_ACTIVE_PROMISES
			  limit l_max_fetches;
		      IF L_party_ID.COUNT = 0 THEN

			  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_cu_pro_summ_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
			  EXIT;

		       ELSE

			forall i IN L_party_ID.FIRST .. L_party_ID.LAST
				   UPDATE IEX_DLN_UWQ_SUMMARY
				    SET ACTIVE_PROMISES    = L_ACTIVE_PROMISES(i),
					COMPLETE_PROMISES  = L_COMPLETE_PROMISES(i),
					PENDING_PROMISES   = L_PENDING_PROMISES(i)
				   WHERE
				   party_ID = L_party_ID(i)
				   and org_id=L_ORG_ID(i);
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_cu_pro_summ_dt updated ' || L_party_ID.count ||  ' rows ');
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


		      END IF;
		      END LOOP;

		       IF C_cu_PRO_SUMM_dt % ISOPEN THEN
			CLOSE C_cu_PRO_SUMM_dt;
		       END IF;

		       EXCEPTION WHEN OTHERS THEN
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Promise update received' || SQLERRM);
		       END;
	      end if; --if l_enable_work_queue = 'Y' then

	      BEGIN
	      OPEN C_cu_LAST_PAYMENT_DTLS_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_cu_LAST_PAYMENT_DTLS_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_party_ID.delete;L_ORG_ID.delete;
		L_LAST_PAYMENT_AMOUNT.delete;
		L_LAST_PAYMENT_AMOUNT_CURR.delete;
		L_LAST_PAYMENT_NUMBER.delete;

	      LOOP
		FETCH C_cu_LAST_PAYMENT_DTLS_dt bulk collect
		  INTO
		    L_party_ID,L_ORG_ID,
		    L_LAST_PAYMENT_AMOUNT,
		    L_LAST_PAYMENT_AMOUNT_CURR,
		    L_LAST_PAYMENT_NUMBER
		  limit l_max_fetches;
	      IF L_party_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_cu_last_payment_dtls_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET LAST_PAYMENT_AMOUNT = gl_currency_api.convert_amount_sql(L_LAST_PAYMENT_AMOUNT_CURR(i), CURRENCY,
						       sysdate,iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE', ''), L_LAST_PAYMENT_AMOUNT(i)),
				LAST_PAYMENT_AMOUNT_CURR = L_LAST_PAYMENT_AMOUNT_CURR(i),
				LAST_PAYMENT_NUMBER = L_LAST_PAYMENT_NUMBER(i)
			   WHERE
			    party_ID = L_party_ID(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_cu_LAST_PAYMENT_dtls_dt updated ' || L_LAST_PAYMENT_AMOUNT.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_cu_LAST_PAYMENT_DTLS_dt % ISOPEN THEN
		CLOSE C_cu_LAST_PAYMENT_DTLS_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Last payment amount update received' || SQLERRM);
	       END;

	      BEGIN
	      OPEN C_cu_BANKRUPTCIES_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_cu_BANKRUPTCIES_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_PARTY_ID.delete;L_ORG_ID.delete;
		L_NUMBER_OF_BANKRUPTCIES.delete;

	      LOOP
		FETCH C_cu_BANKRUPTCIES_dt bulk collect
		  INTO
		    L_PARTY_ID,L_ORG_ID,
		    L_NUMBER_OF_BANKRUPTCIES
		  limit l_max_fetches;
	      IF L_PARTY_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_cu_BANKRUPTCIES_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET NUMBER_OF_BANKRUPTCIES     = L_NUMBER_OF_BANKRUPTCIES(i)
			   WHERE
			    PARTY_ID = L_PARTY_ID(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_cu_BANKRUPTCIES_dt updated ' || L_PARTY_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_cu_BANKRUPTCIES_dt % ISOPEN THEN
		CLOSE C_cu_BANKRUPTCIES_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bankruptcy update received' || SQLERRM);
	       END;
              COMMIT;
               LogMessage(FND_LOG.LEVEL_STATEMENT,'Commited');

	      BEGIN
	      OPEN C_cu_SCORE_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_cu_score_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_party_ID.delete;
		L_SCORE.delete;
		L_SCORE_ID.delete;
		L_SCORE_NAME.delete;

	      LOOP
		FETCH C_cu_SCORE_dt bulk collect
		  INTO
		    L_party_ID,
		    L_SCORE,
		    l_score_id,
		    l_score_name
		  limit l_max_fetches;
	      IF L_party_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_cu_score_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_party_ID.FIRST .. L_party_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET SCORE     = L_SCORE(i),
				score_id=l_score_id(i),
				score_name=l_score_name(i)
			   WHERE
			    party_ID = L_party_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_cu_score_dt updated ' || L_cust_account_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_cu_SCORE_dt % ISOPEN THEN
		CLOSE C_cu_SCORE_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Score update received' || SQLERRM);
	       END;--end 9597052
	    end if;
	 --End Bug 9597052 28-Apr-2010 barathsr
              end if;
          ELSIF p_level = 'ACCOUNT' THEN
              if (l_from_date is null) then
                CLOSE c_iex_acc_uwq_summary;
		--Begin Bug 9597052 28-Apr-2010 barathsr
		if p_mode='CP' then
		    BEGIN--start 9597052
			OPEN C_acct_DETAILS;
			LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_acct_DETAILS cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_PARTY_ID.delete;L_ORG_ID.delete;
			L_PARTY_NAME.delete;
			L_CUST_ACCOUNT_ID.delete;
			L_ACCOUNT_NAME.delete;
			L_ACCOUNT_NUMBER.delete;
			--L_SITE_USE_ID.delete;
			L_LOCATION.delete;
			L_ADDRESS1.delete;
			L_CITY.delete;
			L_STATE.delete;
			L_COUNTY.delete;
			L_COUNTRY.delete;
			L_PROVINCE.delete;
			L_POSTAL_CODE.delete;

		    LOOP
			FETCH C_acct_DETAILS bulk collect
			INTO
			L_PARTY_ID,L_ORG_ID,
			L_PARTY_NAME,
			L_CUST_ACCOUNT_ID,
			L_ACCOUNT_NAME,
			L_ACCOUNT_NUMBER,
		--	L_SITE_USE_ID,
			L_LOCATION,
			L_ADDRESS1,
			L_CITY,
			L_STATE,
			L_COUNTY,
			L_COUNTRY,
			L_PROVINCE,
			L_POSTAL_CODE
			limit l_max_fetches;
				IF L_cust_account_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_acct_DETAILS ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
				EXIT;
			ELSE

			   forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			     UPDATE IEX_DLN_UWQ_SUMMARY
			     SET PARTY_ID = L_PARTY_ID(i),
				PARTY_NAME = L_PARTY_NAME(i),
			--	CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i),
				ACCOUNT_NAME = L_ACCOUNT_NAME(i),
				ACCOUNT_NUMBER = L_ACCOUNT_NUMBER(i),
				LOCATION = L_LOCATION(i),
				ADDRESS1 = L_ADDRESS1(i),
				CITY = L_CITY(i),
				STATE = L_STATE(i),
				COUNTY = L_COUNTY(i),
				COUNTRY = L_COUNTRY(i),
				PROVINCE = L_PROVINCE(i),
				POSTAL_CODE = L_POSTAL_CODE(i)
			     WHERE
			     cust_account_id = L_cust_account_id(i)
			     and org_id=L_ORG_ID(i);
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_acct_DETAILS updated ' || L_cust_account_id.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
		       END IF;
		    END LOOP;
		   IF C_acct_DETAILS % ISOPEN THEN
		       CLOSE C_acct_DETAILS;
		   END IF;

		EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'a/c update received' || SQLERRM);
		END;

		BEGIN
	       OPEN c_acc_contact_point;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened Cursor  c_acc_contact_point  cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_PARTY_ID.delete;L_ORG_ID.delete;
		L_PHONE_COUNTRY_CODE.delete;
		L_PHONE_AREA_CODE.delete;
		L_PHONE_NUMBER.delete;
		L_PHONE_EXTENSION.delete;


	      LOOP
		 FETCH c_acc_contact_point bulk collect
		  INTO
		   L_PARTY_ID,L_ORG_ID,
		   L_PHONE_COUNTRY_CODE,
		   L_PHONE_AREA_CODE,
		   L_PHONE_NUMBER,
		   L_PHONE_EXTENSION

		  limit l_max_fetches;
	      IF L_PARTY_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'c_acc_contact_point  Cursor Fetching end time:   ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

		ELSE

		forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST

			   UPDATE IEX_DLN_UWQ_SUMMARY
			   SET PHONE_COUNTRY_CODE = L_PHONE_COUNTRY_CODE(i),
			       PHONE_AREA_CODE    = L_PHONE_AREA_CODE(i),
			       PHONE_NUMBER       = L_PHONE_NUMBER(i),
			       PHONE_EXTENSION    = L_PHONE_EXTENSION(i),
			       last_update_date   = SYSDATE,
			       last_updated_by    = FND_GLOBAL.USER_ID
			 WHERE PARTY_ID = L_PARTY_ID(i)
			 and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_acc_contact_point Cursor updated ' ||L_PARTY_ID.count || ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;

	      IF c_acc_contact_point % ISOPEN THEN
		       CLOSE c_acc_contact_point;
		   END IF;


	      EXCEPTION WHEN OTHERS THEN
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Contact point raised error ' || SQLERRM);
	      END;

	      BEGIN
	      OPEN C_acc_COLLECTOR_PROF;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_acc_COLLECTOR_PROF cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_RESOURCE_ID.delete;
		L_COLLECTOR_RES_TYPE.delete;
		L_COLLECTOR_RESOURCE_ID.delete  ;
		L_COLLECTOR_RESOURCE_NAME.delete;
		L_COLLECTOR_ID.delete;
		L_RESOURCE_TYPE.delete;
		L_PARTY_ID.delete;L_ORG_ID.delete;
		L_CUST_ACCOUNT_ID.delete;
	--	L_SITE_USE_ID.delete;

	      LOOP
		FETCH C_acc_COLLECTOR_PROF bulk collect
		  INTO
		    L_COLLECTOR_ID,L_ORG_ID,
		    L_COLLECTOR_RESOURCE_ID,
		    L_COLLECTOR_RES_TYPE,
		    L_COLLECTOR_RESOURCE_NAME,
		    L_RESOURCE_ID,
		    L_RESOURCE_TYPE,
		    L_PARTY_ID,
		    L_CUST_ACCOUNT_ID
		 --   L_SITE_USE_ID
		  limit l_max_fetches;
	      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_acc_COLLECTOR_PROF ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
				COLLECTOR_RES_TYPE    = L_COLLECTOR_RES_TYPE(i),
				collector_resource_name = L_COLLECTOR_RESOURCE_NAME(i),
				collector_id = l_collector_id(i),
				resource_id=l_resource_id(i),
				resource_type=l_resource_type(i),
				last_update_date   = SYSDATE,
				last_updated_by    = FND_GLOBAL.USER_ID
			   WHERE
			    cust_account_id = L_cust_account_id(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_acc_COLLECTOR_PROF updated ' || L_COLLECTOR_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_acc_COLLECTOR_PROF % ISOPEN THEN
		CLOSE C_acc_COLLECTOR_PROF;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'C_acc_COLLECTOR_PROF update received' || SQLERRM);
	       END;

	       BEGIN
	      OPEN C_acc_PRO_DTLS;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_acc_pro_dtls cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_cust_account_ID.delete;L_ORG_ID.delete;
		L_NUMBER_OF_PROMISES.delete;
		L_BROKEN_PROMISE_AMOUNT .delete;
		L_PROMISE_AMOUNT.delete;

	      LOOP
		FETCH C_acc_PRO_DTLS bulk collect
		  INTO
		    L_cust_account_id,L_ORG_ID,
		    L_NUMBER_OF_PROMISES,
		    L_BROKEN_PROMISE_AMOUNT,
		    L_PROMISE_AMOUNT
		  limit l_max_fetches;
	      IF L_cust_account_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_acc_pro_summ ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET NUMBER_OF_PROMISES     = L_NUMBER_OF_PROMISES(i),
				BROKEN_PROMISE_AMOUNT  = L_BROKEN_PROMISE_AMOUNT(i),
				PROMISE_AMOUNT         = L_PROMISE_AMOUNT(i)
			   WHERE
			    cust_account_ID = L_cust_account_ID(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_acc_pro_dtls updated ' || L_cust_account_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_acc_PRO_DTLS % ISOPEN THEN
		CLOSE C_acc_PRO_DTLS;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Broken Promise update received' || SQLERRM);
	       END;

		BEGIN
			OPEN C_acc_DELN_CNT;
			LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_acc_deln_cnt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_cust_account_ID.delete;L_ORG_ID.delete;
			L_NUMBER_OF_DELINQUENCIES.delete;
			L_PAST_DUE_INV_VALUE.delete;

		    LOOP
			FETCH C_acc_DELN_CNT bulk collect
			INTO
			L_cust_account_ID,L_ORG_ID,
			L_NUMBER_OF_DELINQUENCIES,
			L_PAST_DUE_INV_VALUE
			limit l_max_fetches;
			IF L_cust_account_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_acc_deln_cnt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
				EXIT;
			ELSE

			   forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			     UPDATE IEX_DLN_UWQ_SUMMARY
			     SET NUMBER_OF_DELINQUENCIES = L_NUMBER_OF_DELINQUENCIES(i),
				 PAST_DUE_INV_VALUE = L_PAST_DUE_INV_VALUE(i)
			     WHERE
			     cust_account_id = L_cust_account_ID(i)
			     and org_id=L_ORG_ID(i);
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_acc_del_cnt updated ' || L_cust_account_ID.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
		       END IF;
		    END LOOP;
		   IF C_acc_DELN_CNT % ISOPEN THEN
		       CLOSE C_acc_DELN_CNT;
		   END IF;

		EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
		END;

	       if l_enable_work_queue = 'Y' then  --update active,pending and complete nodes of delinquency and promise only when the profile 'IEX: Enable Work Queue Statuses' is set to Yes.
			BEGIN
				OPEN C_acc_DELN_DTLS;
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_acc_deln_dln cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				L_cust_account_ID.delete;L_ORG_ID.delete;
				L_PENDING_DELINQUENCIES.delete;
				L_COMPLETE_DELINQUENCIES.delete;
				L_ACTIVE_DELINQUENCIES.delete;

			    LOOP
				FETCH C_acc_DELN_DTLS bulk collect
				INTO
				L_cust_account_ID,L_ORG_ID,
				L_PENDING_DELINQUENCIES,
				L_COMPLETE_DELINQUENCIES,
				L_ACTIVE_DELINQUENCIES
				limit l_max_fetches;
				IF L_cust_account_ID.COUNT = 0 THEN
					LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_acc_deln_dtls ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
					LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
					EXIT;
				ELSE

				   forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
				     UPDATE IEX_DLN_UWQ_SUMMARY
				     SET PENDING_DELINQUENCIES   = L_PENDING_DELINQUENCIES(i),
					 COMPLETE_DELINQUENCIES  = L_COMPLETE_DELINQUENCIES(i),
					 ACTIVE_DELINQUENCIES    = L_ACTIVE_DELINQUENCIES(i)
				     WHERE
				     cust_account_ID = L_cust_account_ID(i)
				     and org_id=L_ORG_ID(i);
				     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_acc_deln_dtls updated ' || L_cust_account_ID.count ||  ' rows ');
				     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
			       END IF;
			    END LOOP;
			   IF C_acc_DELN_DTLS % ISOPEN THEN
			       CLOSE C_acc_DELN_DTLS;
			   END IF;

			EXCEPTION WHEN OTHERS THEN
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
			END;

		      BEGIN
		      OPEN C_acc_PRO_SUMM;
		       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_acc_pro_summ cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_cust_account_ID.delete;L_ORG_ID.delete;
			L_ACTIVE_PROMISES.delete;
			L_COMPLETE_PROMISES.delete;
			L_PENDING_PROMISES.delete;

		      LOOP
			FETCH C_acc_PRO_SUMM bulk collect
			  INTO
			    L_cust_account_ID,L_ORG_ID,
			    L_PENDING_PROMISES,
			    L_COMPLETE_PROMISES,
			    L_ACTIVE_PROMISES
			  limit l_max_fetches;
		      IF L_cust_account_ID.COUNT = 0 THEN

			  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_acc_pro_summ ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
			  EXIT;

		       ELSE

			forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
				   UPDATE IEX_DLN_UWQ_SUMMARY
				    SET ACTIVE_PROMISES    = L_ACTIVE_PROMISES(i),
					COMPLETE_PROMISES  = L_COMPLETE_PROMISES(i),
					PENDING_PROMISES   = L_PENDING_PROMISES(i)
				   WHERE
				   cust_account_ID = L_cust_account_ID(i)
				   and org_id=L_ORG_ID(i);
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_acc_pro_summ updated ' || L_cust_account_ID.count ||  ' rows ');
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


		      END IF;
		      END LOOP;

		       IF C_acc_PRO_SUMM % ISOPEN THEN
			CLOSE C_acc_PRO_SUMM;
		       END IF;

		       EXCEPTION WHEN OTHERS THEN
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Promise update received' || SQLERRM);
		       END;
	      end if; --if l_enable_work_queue = 'Y' then

	      BEGIN
	      OPEN C_acc_LAST_PAYMENT_DTLS;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_acc_LAST_PAYMENT_DTLS cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_cust_account_ID.delete;L_ORG_ID.delete;
		L_LAST_PAYMENT_AMOUNT.delete;
		L_LAST_PAYMENT_AMOUNT_CURR.delete;
		L_LAST_PAYMENT_NUMBER.delete;

	      LOOP
		FETCH C_acc_LAST_PAYMENT_DTLS bulk collect
		  INTO
		    L_cust_account_ID,L_ORG_ID,
		    L_LAST_PAYMENT_AMOUNT,
		    L_LAST_PAYMENT_AMOUNT_CURR,
		    L_LAST_PAYMENT_NUMBER
		  limit l_max_fetches;
	      IF L_cust_account_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_acc_last_payment_dtls_ ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET LAST_PAYMENT_AMOUNT = gl_currency_api.convert_amount_sql(L_LAST_PAYMENT_AMOUNT_CURR(i), CURRENCY,
						       sysdate,iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE', ''), L_LAST_PAYMENT_AMOUNT(i)),
				LAST_PAYMENT_AMOUNT_CURR = L_LAST_PAYMENT_AMOUNT_CURR(i),
				LAST_PAYMENT_NUMBER = L_LAST_PAYMENT_NUMBER(i)
			   WHERE
			    cust_account_ID = L_cust_account_ID(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_acc_LAST_PAYMENT_dtls updated ' || L_LAST_PAYMENT_AMOUNT.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_acc_LAST_PAYMENT_DTLS % ISOPEN THEN
		CLOSE C_acc_LAST_PAYMENT_DTLS;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Last payment amount update received' || SQLERRM);
	       END;

	      BEGIN
	      OPEN C_acc_BANKRUPTCIES;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_acc_BANKRUPTCIES cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_PARTY_ID.delete;L_ORG_ID.delete;
		L_NUMBER_OF_BANKRUPTCIES.delete;

	      LOOP
		FETCH C_acc_BANKRUPTCIES bulk collect
		  INTO
		    L_PARTY_ID,L_ORG_ID,
		    L_NUMBER_OF_BANKRUPTCIES
		  limit l_max_fetches;
	      IF L_PARTY_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_acc_BANKRUPTCIES ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET NUMBER_OF_BANKRUPTCIES     = L_NUMBER_OF_BANKRUPTCIES(i)
			   WHERE
			    PARTY_ID = L_PARTY_ID(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_acc_BANKRUPTCIES updated ' || L_PARTY_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_acc_BANKRUPTCIES % ISOPEN THEN
		CLOSE C_acc_BANKRUPTCIES;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bankruptcy update received' || SQLERRM);
	       END;
              COMMIT;
               LogMessage(FND_LOG.LEVEL_STATEMENT,'Commited');

	      BEGIN
	      OPEN C_acc_SCORE;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_acc_score cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_cust_account_ID.delete;
		L_SCORE.delete;
		L_SCORE_ID.delete;
		L_SCORE_NAME.delete;

	      LOOP
		FETCH C_acc_SCORE bulk collect
		  INTO
		    L_cust_account_ID,
		    L_SCORE,
		    l_score_id,
		    l_score_name
		  limit l_max_fetches;
	      IF L_cust_account_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_acc_score ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET SCORE     = L_SCORE(i),
				score_id=l_score_id(i),
				score_name=l_score_name(i)
			   WHERE
			    cust_account_ID = L_cust_account_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_acc_score updated ' || L_cust_account_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_acc_SCORE % ISOPEN THEN
		CLOSE C_acc_SCORE;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Score update received' || SQLERRM);
	       END;--end 9597052
	    end if;
	    --End Bug 9597052 28-Apr-2010 barathsr
              else
                CLOSE c_iex_acc_uwq_dt_sum;
		--Begin Bug 9597052 28-Apr-2010 barathsr
		 if p_mode='CP' then
		    BEGIN--start 9597052
			OPEN C_acct_DETAILS_dt;
			LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_acct_DETAILS_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_PARTY_ID.delete;L_ORG_ID.delete;
			L_PARTY_NAME.delete;
			L_CUST_ACCOUNT_ID.delete;
			L_ACCOUNT_NAME.delete;
			L_ACCOUNT_NUMBER.delete;
			--L_SITE_USE_ID.delete;
			L_LOCATION.delete;
			L_ADDRESS1.delete;
			L_CITY.delete;
			L_STATE.delete;
			L_COUNTY.delete;
			L_COUNTRY.delete;
			L_PROVINCE.delete;
			L_POSTAL_CODE.delete;

		    LOOP
			FETCH C_acct_DETAILS_dt bulk collect
			INTO
			L_PARTY_ID,L_ORG_ID,
			L_PARTY_NAME,
			L_CUST_ACCOUNT_ID,
			L_ACCOUNT_NAME,
			L_ACCOUNT_NUMBER,
		--	L_SITE_USE_ID,
			L_LOCATION,
			L_ADDRESS1,
			L_CITY,
			L_STATE,
			L_COUNTY,
			L_COUNTRY,
			L_PROVINCE,
			L_POSTAL_CODE
			limit l_max_fetches;
				IF L_cust_account_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_acct_DETAILS_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
				EXIT;
			ELSE

			   forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			     UPDATE IEX_DLN_UWQ_SUMMARY
			     SET PARTY_ID = L_PARTY_ID(i),
				PARTY_NAME = L_PARTY_NAME(i),
			--	CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i),
				ACCOUNT_NAME = L_ACCOUNT_NAME(i),
				ACCOUNT_NUMBER = L_ACCOUNT_NUMBER(i),
				LOCATION = L_LOCATION(i),
				ADDRESS1 = L_ADDRESS1(i),
				CITY = L_CITY(i),
				STATE = L_STATE(i),
				COUNTY = L_COUNTY(i),
				COUNTRY = L_COUNTRY(i),
				PROVINCE = L_PROVINCE(i),
				POSTAL_CODE = L_POSTAL_CODE(i)
			     WHERE
			     cust_account_id = L_cust_account_id(i)
			     and org_id=L_ORG_ID(i);
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_acct_DETAILS_dt updated ' || L_cust_account_id.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
		       END IF;
		    END LOOP;
		   IF C_acct_DETAILS_dt % ISOPEN THEN
		       CLOSE C_acct_DETAILS_dt;
		   END IF;

		EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'a/c update received' || SQLERRM);
		END;

		BEGIN
	       OPEN c_acc_contact_point_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened Cursor  c_acc_contact_point_dt  cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_PARTY_ID.delete;L_ORG_ID.delete;
		L_PHONE_COUNTRY_CODE.delete;
		L_PHONE_AREA_CODE.delete;
		L_PHONE_NUMBER.delete;
		L_PHONE_EXTENSION.delete;


	      LOOP
		 FETCH c_acc_contact_point_dt bulk collect
		  INTO
		   L_PARTY_ID,L_ORG_ID,
		   L_PHONE_COUNTRY_CODE,
		   L_PHONE_AREA_CODE,
		   L_PHONE_NUMBER,
		   L_PHONE_EXTENSION

		  limit l_max_fetches;
	      IF L_PARTY_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'c_acc_contact_point_dt  Cursor Fetching end time:   ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

		ELSE

		forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST

			   UPDATE IEX_DLN_UWQ_SUMMARY
			   SET PHONE_COUNTRY_CODE = L_PHONE_COUNTRY_CODE(i),
			       PHONE_AREA_CODE    = L_PHONE_AREA_CODE(i),
			       PHONE_NUMBER       = L_PHONE_NUMBER(i),
			       PHONE_EXTENSION    = L_PHONE_EXTENSION(i),
			       last_update_date   = SYSDATE,
			       last_updated_by    = FND_GLOBAL.USER_ID
			 WHERE PARTY_ID = L_PARTY_ID(i)
			 and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_acc_contact_point_dt Cursor updated ' ||L_PARTY_ID.count || ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;

	      IF c_acc_contact_point_dt % ISOPEN THEN
		       CLOSE c_acc_contact_point_dt;
		   END IF;


	      EXCEPTION WHEN OTHERS THEN
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Contact point raised error ' || SQLERRM);
	      END;

	      BEGIN
	      OPEN C_acc_COLLECTOR_PROF_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_acc_COLLECTOR_PROF_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_RESOURCE_ID.delete;
		L_COLLECTOR_RES_TYPE.delete;
		L_COLLECTOR_RESOURCE_ID.delete  ;
		L_COLLECTOR_RESOURCE_NAME.delete;
		L_COLLECTOR_ID.delete;
		L_RESOURCE_TYPE.delete;
		L_PARTY_ID.delete;L_ORG_ID.delete;
		L_CUST_ACCOUNT_ID.delete;
	--	L_SITE_USE_ID.delete;

	      LOOP
		FETCH C_acc_COLLECTOR_PROF_dt bulk collect
		  INTO
		    L_COLLECTOR_ID,L_ORG_ID,
		    L_COLLECTOR_RESOURCE_ID,
		    L_COLLECTOR_RES_TYPE,
		    L_COLLECTOR_RESOURCE_NAME,
		    L_RESOURCE_ID,
		    L_RESOURCE_TYPE,
		    L_PARTY_ID,
		    L_CUST_ACCOUNT_ID
		 --   L_SITE_USE_ID
		  limit l_max_fetches;
	      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_acc_COLLECTOR_PROF_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
				COLLECTOR_RES_TYPE    = L_COLLECTOR_RES_TYPE(i),
				collector_resource_name = L_COLLECTOR_RESOURCE_NAME(i),
				collector_id = l_collector_id(i),
				resource_id=l_resource_id(i),
				resource_type=l_resource_type(i),
				last_update_date   = SYSDATE,
				last_updated_by    = FND_GLOBAL.USER_ID
			   WHERE
			    cust_account_id = L_cust_account_id(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_acc_COLLECTOR_PROF_dt updated ' || L_COLLECTOR_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_acc_COLLECTOR_PROF_dt % ISOPEN THEN
		CLOSE C_acc_COLLECTOR_PROF_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'C_acc_COLLECTOR_PROF_dt update received' || SQLERRM);
	       END;


	        BEGIN
	      OPEN C_acc_ch_coll_dt_sum;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_acc_ch_coll_dt_sum cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_COLLECTOR_RES_TYPE.delete;
		L_COLLECTOR_RESOURCE_ID.delete  ;
		L_COLLECTOR_ID.delete;
		L_cust_account_ID.delete;L_ORG_ID.delete;

	      LOOP
		FETCH C_acc_ch_coll_dt_sum bulk collect
		  INTO
		    L_COLLECTOR_RESOURCE_ID,L_ORG_ID,
		    L_COLLECTOR_RES_TYPE,
		    L_COLLECTOR_ID,
		    L_cust_account_ID
		  limit l_max_fetches;
	      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_acc_ch_coll_dt_sum ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
				COLLECTOR_RES_TYPE    = L_COLLECTOR_RES_TYPE(i),
				collector_id = l_collector_id(i),
				last_update_date   = SYSDATE,
				last_updated_by    = FND_GLOBAL.USER_ID
			   WHERE
			    cust_account_ID = L_cust_account_ID(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_acc_ch_coll_dt_sum updated ' || L_COLLECTOR_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_acc_ch_coll_dt_sum % ISOPEN THEN
		CLOSE C_acc_ch_coll_dt_sum;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'C_acc_ch_coll_dt_sum update received' || SQLERRM);
	       END;


	       BEGIN
	      OPEN C_acc_PRO_DTLS_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_acc_pro_dtls_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_cust_account_ID.delete;L_ORG_ID.delete;
		L_NUMBER_OF_PROMISES.delete;
		L_BROKEN_PROMISE_AMOUNT .delete;
		L_PROMISE_AMOUNT.delete;

	      LOOP
		FETCH C_acc_PRO_DTLS_dt bulk collect
		  INTO
		    L_cust_account_id,L_ORG_ID,
		    L_NUMBER_OF_PROMISES,
		    L_BROKEN_PROMISE_AMOUNT,
		    L_PROMISE_AMOUNT
		  limit l_max_fetches;
	      IF L_cust_account_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_acc_pro_dtls_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET NUMBER_OF_PROMISES     = L_NUMBER_OF_PROMISES(i),
				BROKEN_PROMISE_AMOUNT  = L_BROKEN_PROMISE_AMOUNT(i),
				PROMISE_AMOUNT         = L_PROMISE_AMOUNT(i)
			   WHERE
			    cust_account_ID = L_cust_account_ID(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_acc_pro_dtls_dt updated ' || L_cust_account_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_acc_PRO_DTLS_dt % ISOPEN THEN
		CLOSE C_acc_PRO_DTLS_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Broken Promise update received' || SQLERRM);
	       END;

		BEGIN
			OPEN C_acc_DELN_CNT_dt;
			LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_acc_deln_cnt_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_cust_account_ID.delete;L_ORG_ID.delete;
			L_NUMBER_OF_DELINQUENCIES.delete;
			L_PAST_DUE_INV_VALUE.delete;

		    LOOP
			FETCH C_acc_DELN_CNT_dt bulk collect
			INTO
			L_cust_account_ID,L_ORG_ID,
			L_NUMBER_OF_DELINQUENCIES,
			L_PAST_DUE_INV_VALUE
			limit l_max_fetches;
			IF L_cust_account_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_acc_deln_cnt_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
				EXIT;
			ELSE

			   forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			     UPDATE IEX_DLN_UWQ_SUMMARY
			     SET NUMBER_OF_DELINQUENCIES = L_NUMBER_OF_DELINQUENCIES(i),
				 PAST_DUE_INV_VALUE = L_PAST_DUE_INV_VALUE(i)
			     WHERE
			     cust_account_id = L_cust_account_ID(i)
			     and org_id=L_ORG_ID(i);
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_acc_del_cnt_dt updated ' || L_cust_account_ID.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
		       END IF;
		    END LOOP;
		   IF C_acc_DELN_CNT_dt % ISOPEN THEN
		       CLOSE C_acc_DELN_CNT_dt;
		   END IF;

		EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
		END;

	        if l_enable_work_queue = 'Y' then  --update active,pending and complete nodes of delinquency and promise only when the profile 'IEX: Enable Work Queue Statuses' is set to Yes.
			BEGIN
				OPEN C_acc_DELN_DTLS_dt;
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_acc_deln_dtls_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				L_cust_account_ID.delete;L_ORG_ID.delete;
				L_PENDING_DELINQUENCIES.delete;
				L_COMPLETE_DELINQUENCIES.delete;
				L_ACTIVE_DELINQUENCIES.delete;

			    LOOP
				FETCH C_acc_DELN_DTLS_dt bulk collect
				INTO
				L_cust_account_ID,L_ORG_ID,
				L_PENDING_DELINQUENCIES,
				L_COMPLETE_DELINQUENCIES,
				L_ACTIVE_DELINQUENCIES
				limit l_max_fetches;
				IF L_cust_account_ID.COUNT = 0 THEN
					LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_acc_deln_dtls_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
					LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
					EXIT;
				ELSE

				   forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
				     UPDATE IEX_DLN_UWQ_SUMMARY
				     SET PENDING_DELINQUENCIES   = L_PENDING_DELINQUENCIES(i),
					 COMPLETE_DELINQUENCIES  = L_COMPLETE_DELINQUENCIES(i),
					 ACTIVE_DELINQUENCIES    = L_ACTIVE_DELINQUENCIES(i)
				     WHERE
				     cust_account_ID = L_cust_account_ID(i)
				     and org_id=L_ORG_ID(i);
				     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_acc_deln_dtls_dt updated ' || L_cust_account_ID.count ||  ' rows ');
				     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
			       END IF;
			    END LOOP;
			   IF C_acc_DELN_DTLS_dt % ISOPEN THEN
			       CLOSE C_acc_DELN_DTLS_dt;
			   END IF;

			EXCEPTION WHEN OTHERS THEN
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
			END;

		      BEGIN
		      OPEN C_acc_PRO_SUMM_dt;
		       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_acc_pro_summ_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_cust_account_ID.delete;L_ORG_ID.delete;
			L_ACTIVE_PROMISES.delete;
			L_COMPLETE_PROMISES.delete;
			L_PENDING_PROMISES.delete;

		      LOOP
			FETCH C_acc_PRO_SUMM_dt bulk collect
			  INTO
			    L_cust_account_ID,L_ORG_ID,
			    L_PENDING_PROMISES,
			    L_COMPLETE_PROMISES,
			    L_ACTIVE_PROMISES
			  limit l_max_fetches;
		      IF L_cust_account_ID.COUNT = 0 THEN

			  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_acc_pro_summ_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
			  EXIT;

		       ELSE

			forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
				   UPDATE IEX_DLN_UWQ_SUMMARY
				    SET ACTIVE_PROMISES    = L_ACTIVE_PROMISES(i),
					COMPLETE_PROMISES  = L_COMPLETE_PROMISES(i),
					PENDING_PROMISES   = L_PENDING_PROMISES(i)
				   WHERE
				   cust_account_ID = L_cust_account_ID(i)
				   and org_id=L_ORG_ID(i);
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_acc_pro_summ_dt updated ' || L_cust_account_ID.count ||  ' rows ');
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


		      END IF;
		      END LOOP;

		       IF C_acc_PRO_SUMM_dt % ISOPEN THEN
			CLOSE C_acc_PRO_SUMM_dt;
		       END IF;

		       EXCEPTION WHEN OTHERS THEN
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Promise update received' || SQLERRM);
		       END;
	      end if; --if l_enable_work_queue = 'Y' then

	      BEGIN
	      OPEN C_acc_LAST_PAYMENT_DTLS_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_acc_LAST_PAYMENT_DTLS_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_cust_account_ID.delete;L_ORG_ID.delete;
		L_LAST_PAYMENT_AMOUNT.delete;
		L_LAST_PAYMENT_AMOUNT_CURR.delete;
		L_LAST_PAYMENT_NUMBER.delete;

	      LOOP
		FETCH C_acc_LAST_PAYMENT_DTLS_dt bulk collect
		  INTO
		    L_cust_account_ID,L_ORG_ID,
		    L_LAST_PAYMENT_AMOUNT,
		    L_LAST_PAYMENT_AMOUNT_CURR,
		    L_LAST_PAYMENT_NUMBER
		  limit l_max_fetches;
	      IF L_cust_account_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_acc_last_payment_dtls_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET LAST_PAYMENT_AMOUNT = gl_currency_api.convert_amount_sql(L_LAST_PAYMENT_AMOUNT_CURR(i), CURRENCY,
						       sysdate,iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE', ''), L_LAST_PAYMENT_AMOUNT(i)),
				LAST_PAYMENT_AMOUNT_CURR = L_LAST_PAYMENT_AMOUNT_CURR(i),
				LAST_PAYMENT_NUMBER = L_LAST_PAYMENT_NUMBER(i)
			   WHERE
			    cust_account_ID = L_cust_account_ID(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_acc_LAST_PAYMENT_dtls_dt updated ' || L_LAST_PAYMENT_AMOUNT.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_acc_LAST_PAYMENT_DTLS_dt % ISOPEN THEN
		CLOSE C_acc_LAST_PAYMENT_DTLS_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Last payment amount update received' || SQLERRM);
	       END;

	      BEGIN
	      OPEN C_acc_BANKRUPTCIES_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_acc_BANKRUPTCIES_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_PARTY_ID.delete;L_ORG_ID.delete;
		L_NUMBER_OF_BANKRUPTCIES.delete;

	      LOOP
		FETCH C_acc_BANKRUPTCIES_dt bulk collect
		  INTO
		    L_PARTY_ID,L_ORG_ID,
		    L_NUMBER_OF_BANKRUPTCIES
		  limit l_max_fetches;
	      IF L_PARTY_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_acc_BANKRUPTCIES_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET NUMBER_OF_BANKRUPTCIES     = L_NUMBER_OF_BANKRUPTCIES(i)
			   WHERE
			    PARTY_ID = L_PARTY_ID(i)
			    and org_id=L_ORG_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_acc_BANKRUPTCIES_dt updated ' || L_PARTY_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_acc_BANKRUPTCIES_dt % ISOPEN THEN
		CLOSE C_acc_BANKRUPTCIES_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bankruptcy update received' || SQLERRM);
	       END;
              COMMIT;
               LogMessage(FND_LOG.LEVEL_STATEMENT,'Commited');

	      BEGIN
	      OPEN C_acc_SCORE_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_acc_score_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_cust_account_ID.delete;
		L_SCORE.delete;
		L_SCORE_ID.delete;
		L_SCORE_NAME.delete;

	      LOOP
		FETCH C_acc_SCORE_dt bulk collect
		  INTO
		    L_cust_account_ID,
		    L_SCORE,
		    l_score_id,
		    l_score_name
		  limit l_max_fetches;
	      IF L_cust_account_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_acc_score_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_cust_account_ID.FIRST .. L_cust_account_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET SCORE     = L_SCORE(i),
				score_id=l_score_id(i),
				score_name=l_score_name(i)
			   WHERE
			    cust_account_ID = L_cust_account_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_acc_score_dt updated ' || L_cust_account_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_acc_SCORE_dt % ISOPEN THEN
		CLOSE C_acc_SCORE_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Score update received' || SQLERRM);
	       END;--end 9597052
	    end if;
	    --End Bug 9597052 28-Apr-2010 barathsr
              end if;
          ELSIF p_level = 'BILL_TO' THEN
              if (l_from_date is null) then
                  CLOSE c_iex_billto_uwq_summary;
		  --Begin Bug 9597052 28-Apr-2010 barathsr
		if p_mode='CP' then
		    BEGIN--start 9597052
			OPEN C_BILLTO_SITE_DETAILS;
			LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_site_details cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_PARTY_ID.delete;
			L_PARTY_NAME.delete;
			L_CUST_ACCOUNT_ID.delete;
			L_ACCOUNT_NAME.delete;
			L_ACCOUNT_NUMBER.delete;
			L_SITE_USE_ID.delete;
			L_LOCATION.delete;
			L_ADDRESS1.delete;
			L_CITY.delete;
			L_STATE.delete;
			L_COUNTY.delete;
			L_COUNTRY.delete;
			L_PROVINCE.delete;
			L_POSTAL_CODE.delete;

		    LOOP
			FETCH C_BILLTO_SITE_DETAILS bulk collect
			INTO
			L_PARTY_ID,
			L_PARTY_NAME,
			L_CUST_ACCOUNT_ID,
			L_ACCOUNT_NAME,
			L_ACCOUNT_NUMBER,
			L_SITE_USE_ID,
			L_LOCATION,
			L_ADDRESS1,
			L_CITY,
			L_STATE,
			L_COUNTY,
			L_COUNTRY,
			L_PROVINCE,
			L_POSTAL_CODE
			limit l_max_fetches;
				IF L_SITE_USE_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_BILLTO_SITE_DETAILS ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
				EXIT;
			ELSE

			   forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			     UPDATE IEX_DLN_UWQ_SUMMARY
			     SET PARTY_ID = L_PARTY_ID(i),
				PARTY_NAME = L_PARTY_NAME(i),
				CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i),
				ACCOUNT_NAME = L_ACCOUNT_NAME(i),
				ACCOUNT_NUMBER = L_ACCOUNT_NUMBER(i),
				LOCATION = L_LOCATION(i),
				ADDRESS1 = L_ADDRESS1(i),
				CITY = L_CITY(i),
				STATE = L_STATE(i),
				COUNTY = L_COUNTY(i),
				COUNTRY = L_COUNTRY(i),
				PROVINCE = L_PROVINCE(i),
				POSTAL_CODE = L_POSTAL_CODE(i)
			     WHERE
			     SITE_USE_ID = L_SITE_USE_ID(i);
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_BILLTO_SITE_DETAILS updated ' || L_SITE_USE_ID.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
		       END IF;
		    END LOOP;
		   IF C_BILLTO_SITE_DETAILS % ISOPEN THEN
		       CLOSE C_BILLTO_SITE_DETAILS;
		   END IF;

		EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Site update received' || SQLERRM);
		END;

		BEGIN
	       OPEN c_billto_contact_point;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened Cursor  c_billto_contact_point  cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_PARTY_ID.delete;
		L_PHONE_COUNTRY_CODE.delete;
		L_PHONE_AREA_CODE.delete;
		L_PHONE_NUMBER.delete;
		L_PHONE_EXTENSION.delete;


	      LOOP
		 FETCH c_billto_contact_point bulk collect
		  INTO
		   L_PARTY_ID,
		   L_PHONE_COUNTRY_CODE,
		   L_PHONE_AREA_CODE,
		   L_PHONE_NUMBER,
		   L_PHONE_EXTENSION

		  limit l_max_fetches;
	      IF L_PARTY_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'c_billto_contact_point  Cursor Fetching end time:   ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

		ELSE

		forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST

			   UPDATE IEX_DLN_UWQ_SUMMARY
			   SET PHONE_COUNTRY_CODE = L_PHONE_COUNTRY_CODE(i),
			       PHONE_AREA_CODE    = L_PHONE_AREA_CODE(i),
			       PHONE_NUMBER       = L_PHONE_NUMBER(i),
			       PHONE_EXTENSION    = L_PHONE_EXTENSION(i),
			       last_update_date   = SYSDATE,
			       last_updated_by    = FND_GLOBAL.USER_ID
			 WHERE PARTY_ID = L_PARTY_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_contact_point Cursor updated ' ||L_PARTY_ID.count || ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;

	      IF c_billto_contact_point % ISOPEN THEN
		       CLOSE c_billto_contact_point;
		   END IF;


	      EXCEPTION WHEN OTHERS THEN
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Contact point raised error ' || SQLERRM);
	      END;

	      BEGIN
	      OPEN C_BILLTO_COLLECTOR_PROF;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_BILLTO_COLLECTOR_PROF cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_RESOURCE_ID.delete;
		L_COLLECTOR_RES_TYPE.delete;
		L_COLLECTOR_RESOURCE_ID.delete  ;
		L_COLLECTOR_RESOURCE_NAME.delete;
		L_COLLECTOR_ID.delete;
		L_RESOURCE_TYPE.delete;
		L_PARTY_ID.delete;
		L_CUST_ACCOUNT_ID.delete;
		L_SITE_USE_ID.delete;

	      LOOP
		FETCH C_BILLTO_COLLECTOR_PROF bulk collect
		  INTO
		    L_COLLECTOR_ID,
		    L_COLLECTOR_RESOURCE_ID,
		    L_COLLECTOR_RES_TYPE,
		    L_COLLECTOR_RESOURCE_NAME,
		    L_RESOURCE_ID,
		    L_RESOURCE_TYPE,
		    L_PARTY_ID,
		    L_CUST_ACCOUNT_ID,
		    L_SITE_USE_ID
		  limit l_max_fetches;
	      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_BILLTO_COLLECTOR_PROF ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
				COLLECTOR_RES_TYPE    = L_COLLECTOR_RES_TYPE(i),
				collector_resource_name = L_COLLECTOR_RESOURCE_NAME(i),
				collector_id = l_collector_id(i),
				resource_id=l_resource_id(i),
				resource_type=l_resource_type(i),
				last_update_date   = SYSDATE,
				last_updated_by    = FND_GLOBAL.USER_ID
			   WHERE
			    SITE_USE_ID = L_SITE_USE_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_BILLTO_COLLECTOR_PROF updated ' || L_COLLECTOR_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_BILLTO_COLLECTOR_PROF % ISOPEN THEN
		CLOSE C_BILLTO_COLLECTOR_PROF;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'C_COLLECTOR_PROF update received' || SQLERRM);
	       END;

	       BEGIN
	      OPEN C_BILLTO_PRO_DTLS;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_pro_dtls cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_SITE_USE_ID.delete;
		L_NUMBER_OF_PROMISES.delete;
		L_BROKEN_PROMISE_AMOUNT .delete;
		L_PROMISE_AMOUNT.delete;

	      LOOP
		FETCH C_BILLTO_PRO_DTLS bulk collect
		  INTO
		    L_SITE_USE_ID,
		    L_NUMBER_OF_PROMISES,
		    L_BROKEN_PROMISE_AMOUNT,
		    L_PROMISE_AMOUNT
		  limit l_max_fetches;
	      IF L_SITE_USE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_pro_summ ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET NUMBER_OF_PROMISES     = L_NUMBER_OF_PROMISES(i),
				BROKEN_PROMISE_AMOUNT  = L_BROKEN_PROMISE_AMOUNT(i),
				PROMISE_AMOUNT         = L_PROMISE_AMOUNT(i)
			   WHERE
			    SITE_USE_ID = L_SITE_USE_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_pro_dtls updated ' || L_SITE_USE_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_BILLTO_PRO_DTLS % ISOPEN THEN
		CLOSE C_BILLTO_PRO_DTLS;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Broken Promise update received' || SQLERRM);
	       END;

		BEGIN
			OPEN C_BILLTO_DELN_CNT;
			LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_deln_cnt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_SITE_USE_ID.delete;
			L_NUMBER_OF_DELINQUENCIES.delete;
			L_PAST_DUE_INV_VALUE.delete;

		    LOOP
			FETCH C_BILLTO_DELN_CNT bulk collect
			INTO
			L_SITE_USE_ID,
			L_NUMBER_OF_DELINQUENCIES,
			L_PAST_DUE_INV_VALUE
			limit l_max_fetches;
			IF L_SITE_USE_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_deln_cnt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
				EXIT;
			ELSE

			   forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			     UPDATE IEX_DLN_UWQ_SUMMARY
			     SET NUMBER_OF_DELINQUENCIES = L_NUMBER_OF_DELINQUENCIES(i),
				 PAST_DUE_INV_VALUE = L_PAST_DUE_INV_VALUE(i)
			     WHERE
			     SITE_USE_ID = L_SITE_USE_ID(i);
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_del_cnt updated ' || L_SITE_USE_ID.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
		       END IF;
		    END LOOP;
		   IF C_BILLTO_DELN_CNT % ISOPEN THEN
		       CLOSE C_BILLTO_DELN_CNT;
		   END IF;

		EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
		END;

	        if l_enable_work_queue = 'Y' then  --update active,pending and complete nodes of delinquency and promise only when the profile 'IEX: Enable Work Queue Statuses' is set to Yes.
			BEGIN
				OPEN C_BILLTO_DELN_DTLS;
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_deln_dln cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				L_SITE_USE_ID.delete;
				L_PENDING_DELINQUENCIES.delete;
				L_COMPLETE_DELINQUENCIES.delete;
				L_ACTIVE_DELINQUENCIES.delete;

			    LOOP
				FETCH C_BILLTO_DELN_DTLS bulk collect
				INTO
				L_SITE_USE_ID,
				L_PENDING_DELINQUENCIES,
				L_COMPLETE_DELINQUENCIES,
				L_ACTIVE_DELINQUENCIES
				limit l_max_fetches;
				IF L_SITE_USE_ID.COUNT = 0 THEN
					LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_del_dln ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
					LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
					EXIT;
				ELSE

				   forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
				     UPDATE IEX_DLN_UWQ_SUMMARY
				     SET PENDING_DELINQUENCIES   = L_PENDING_DELINQUENCIES(i),
					 COMPLETE_DELINQUENCIES  = L_COMPLETE_DELINQUENCIES(i),
					 ACTIVE_DELINQUENCIES    = L_ACTIVE_DELINQUENCIES(i)
				     WHERE
				     SITE_USE_ID = L_SITE_USE_ID(i);
				     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_del_dln updated ' || L_SITE_USE_ID.count ||  ' rows ');
				     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
			       END IF;
			    END LOOP;
			   IF C_BILLTO_DELN_DTLS % ISOPEN THEN
			       CLOSE C_BILLTO_DELN_DTLS;
			   END IF;

			EXCEPTION WHEN OTHERS THEN
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
			END;

		      BEGIN
		      OPEN C_BILLTO_PRO_SUMM;
		       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_pro_summ cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_SITE_USE_ID.delete;
			L_ACTIVE_PROMISES.delete;
			L_COMPLETE_PROMISES.delete;
			L_PENDING_PROMISES.delete;

		      LOOP
			FETCH C_BILLTO_PRO_SUMM bulk collect
			  INTO
			    L_SITE_USE_ID,
			    L_PENDING_PROMISES,
			    L_COMPLETE_PROMISES,
			    L_ACTIVE_PROMISES
			  limit l_max_fetches;
		      IF L_SITE_USE_ID.COUNT = 0 THEN

			  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_pro_summ ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
			  EXIT;

		       ELSE

			forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
				   UPDATE IEX_DLN_UWQ_SUMMARY
				    SET ACTIVE_PROMISES    = L_ACTIVE_PROMISES(i),
					COMPLETE_PROMISES  = L_COMPLETE_PROMISES(i),
					PENDING_PROMISES   = L_PENDING_PROMISES(i)
				   WHERE
				    SITE_USE_ID = L_SITE_USE_ID(i);
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_pro_summ updated ' || L_SITE_USE_ID.count ||  ' rows ');
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


		      END IF;
		      END LOOP;

		       IF C_BILLTO_PRO_SUMM % ISOPEN THEN
			CLOSE C_BILLTO_PRO_SUMM;
		       END IF;

		       EXCEPTION WHEN OTHERS THEN
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Promise update received' || SQLERRM);
		       END;
	     end if; --if l_enable_work_queue = 'Y' then

	      BEGIN
	      OPEN C_BILLTO_LAST_PAYMENT_DTLS;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_BILLTO_LAST_PAYMENT_DTLS cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_SITE_USE_ID.delete;
		L_LAST_PAYMENT_AMOUNT.delete;
		L_LAST_PAYMENT_AMOUNT_CURR.delete;
		L_LAST_PAYMENT_NUMBER.delete;

	      LOOP
		FETCH C_BILLTO_LAST_PAYMENT_DTLS bulk collect
		  INTO
		    L_SITE_USE_ID,
		    L_LAST_PAYMENT_AMOUNT,
		    L_LAST_PAYMENT_AMOUNT_CURR,
		    L_LAST_PAYMENT_NUMBER
		  limit l_max_fetches;
	      IF L_SITE_USE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_last_payment_amount ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET LAST_PAYMENT_AMOUNT = gl_currency_api.convert_amount_sql(L_LAST_PAYMENT_AMOUNT_CURR(i), CURRENCY,
						       sysdate,iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE', ''), L_LAST_PAYMENT_AMOUNT(i)),
				LAST_PAYMENT_AMOUNT_CURR = L_LAST_PAYMENT_AMOUNT_CURR(i),
				LAST_PAYMENT_NUMBER = L_LAST_PAYMENT_NUMBER(i)
			   WHERE
			    SITE_USE_ID = L_SITE_USE_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_LAST_PAYMENT_AMOUNT updated ' || L_LAST_PAYMENT_AMOUNT.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_BILLTO_LAST_PAYMENT_DTLS % ISOPEN THEN
		CLOSE C_BILLTO_LAST_PAYMENT_DTLS;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Last payment amount update received' || SQLERRM);
	       END;

	      BEGIN
	      OPEN C_BILLTO_BANKRUPTCIES;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_BILLTO_BANKRUPTCIES cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_PARTY_ID.delete;
		L_NUMBER_OF_BANKRUPTCIES.delete;

	      LOOP
		FETCH C_BILLTO_BANKRUPTCIES bulk collect
		  INTO
		    L_PARTY_ID,
		    L_NUMBER_OF_BANKRUPTCIES
		  limit l_max_fetches;
	      IF L_PARTY_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_BILLTO_BANKRUPTCIES ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET NUMBER_OF_BANKRUPTCIES     = L_NUMBER_OF_BANKRUPTCIES(i)
			   WHERE
			    PARTY_ID = L_PARTY_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_BILLTO_BANKRUPTCIES updated ' || L_PARTY_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_BILLTO_BANKRUPTCIES % ISOPEN THEN
		CLOSE C_BILLTO_BANKRUPTCIES;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bankruptcy update received' || SQLERRM);
	       END;
              COMMIT;
               LogMessage(FND_LOG.LEVEL_STATEMENT,'Commited');

	      BEGIN
	      OPEN C_BILLTO_SCORE;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_score cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_SITE_USE_ID.delete;
		L_SCORE.delete;
		L_SCORE_ID.delete;
		L_SCORE_NAME.delete;

	      LOOP
		FETCH C_BILLTO_SCORE bulk collect
		  INTO
		    L_SITE_USE_ID,
		    L_SCORE,
		    l_score_id,
		    l_score_name
		  limit l_max_fetches;
	      IF L_SITE_USE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_score ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET SCORE     = L_SCORE(i),
				score_id=l_score_id(i),
				score_name=l_score_name(i)
			   WHERE
			    SITE_USE_ID = L_SITE_USE_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_score updated ' || L_SITE_USE_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_BILLTO_SCORE % ISOPEN THEN
		CLOSE C_BILLTO_SCORE;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Score update received' || SQLERRM);
	       END;--end 9597052
	    end if;
	    --End Bug 9597052 28-Apr-2010 barathsr
          else
                  CLOSE c_iex_billto_uwq_dt_sum;
                 --Begin Bug 9597052 28-Apr-2010 barathsr
		  if p_mode='CP' then
		    BEGIN--start 9597052
			OPEN C_BILLTO_SITE_DETAILS_dt;
			LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_site_details cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_PARTY_ID.delete;
			L_PARTY_NAME.delete;
			L_CUST_ACCOUNT_ID.delete;
			L_ACCOUNT_NAME.delete;
			L_ACCOUNT_NUMBER.delete;
			L_SITE_USE_ID.delete;
			L_LOCATION.delete;
			L_ADDRESS1.delete;
			L_CITY.delete;
			L_STATE.delete;
			L_COUNTY.delete;
			L_COUNTRY.delete;
			L_PROVINCE.delete;
			L_POSTAL_CODE.delete;

		    LOOP
			FETCH C_BILLTO_SITE_DETAILS_dt bulk collect
			INTO
			L_PARTY_ID,
			L_PARTY_NAME,
			L_CUST_ACCOUNT_ID,
			L_ACCOUNT_NAME,
			L_ACCOUNT_NUMBER,
			L_SITE_USE_ID,
			L_LOCATION,
			L_ADDRESS1,
			L_CITY,
			L_STATE,
			L_COUNTY,
			L_COUNTRY,
			L_PROVINCE,
			L_POSTAL_CODE
			limit l_max_fetches;
				IF L_SITE_USE_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_BILLTO_SITE_DETAILS_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
				EXIT;
			ELSE

			   forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			     UPDATE IEX_DLN_UWQ_SUMMARY
			     SET PARTY_ID = L_PARTY_ID(i),
				PARTY_NAME = L_PARTY_NAME(i),
				CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i),
				ACCOUNT_NAME = L_ACCOUNT_NAME(i),
				ACCOUNT_NUMBER = L_ACCOUNT_NUMBER(i),
				LOCATION = L_LOCATION(i),
				ADDRESS1 = L_ADDRESS1(i),
				CITY = L_CITY(i),
				STATE = L_STATE(i),
				COUNTY = L_COUNTY(i),
				COUNTRY = L_COUNTRY(i),
				PROVINCE = L_PROVINCE(i),
				POSTAL_CODE = L_POSTAL_CODE(i)
			     WHERE
			     SITE_USE_ID = L_SITE_USE_ID(i);
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_BILLTO_SITE_DETAILS_dt updated ' || L_SITE_USE_ID.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
		       END IF;
		    END LOOP;
		   IF C_BILLTO_SITE_DETAILS_dt % ISOPEN THEN
		       CLOSE C_BILLTO_SITE_DETAILS_dt;
		   END IF;

		EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Site update received' || SQLERRM);
		END;

		BEGIN
	       OPEN c_billto_contact_point_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened Cursor  c_billto_contact_point_dt  cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_PARTY_ID.delete;
		L_PHONE_COUNTRY_CODE.delete;
		L_PHONE_AREA_CODE.delete;
		L_PHONE_NUMBER.delete;
		L_PHONE_EXTENSION.delete;


	      LOOP
		 FETCH c_billto_contact_point_dt bulk collect
		  INTO
		   L_PARTY_ID,
		   L_PHONE_COUNTRY_CODE,
		   L_PHONE_AREA_CODE,
		   L_PHONE_NUMBER,
		   L_PHONE_EXTENSION

		  limit l_max_fetches;
	      IF L_PARTY_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'c_billto_contact_point_dt  Cursor Fetching end time:   ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

		ELSE

		forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST

			   UPDATE IEX_DLN_UWQ_SUMMARY
			   SET PHONE_COUNTRY_CODE = L_PHONE_COUNTRY_CODE(i),
			       PHONE_AREA_CODE    = L_PHONE_AREA_CODE(i),
			       PHONE_NUMBER       = L_PHONE_NUMBER(i),
			       PHONE_EXTENSION    = L_PHONE_EXTENSION(i),
			       last_update_date   = SYSDATE,
			       last_updated_by    = FND_GLOBAL.USER_ID
			 WHERE PARTY_ID = L_PARTY_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_contact_point_dt Cursor updated ' ||L_PARTY_ID.count || ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;

	      IF c_billto_contact_point_dt % ISOPEN THEN
		CLOSE c_billto_contact_point_dt;
	       END IF;


	      EXCEPTION WHEN OTHERS THEN
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Contact point raised error ' || SQLERRM);
	      END;

	      BEGIN
	      OPEN C_BILLTO_COLLECTOR_PROF_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_BILLTO_COLLECTOR_PROF_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_RESOURCE_ID.delete;
		L_COLLECTOR_RES_TYPE.delete;
		L_COLLECTOR_RESOURCE_ID.delete  ;
		L_COLLECTOR_RESOURCE_NAME.delete  ;
		L_COLLECTOR_ID.delete;
		L_RESOURCE_TYPE.delete;
		L_PARTY_ID.delete;
		L_CUST_ACCOUNT_ID.delete;
		L_SITE_USE_ID.delete;

	      LOOP
		FETCH C_BILLTO_COLLECTOR_PROF_dt bulk collect
		  INTO
		    L_COLLECTOR_ID,
		    L_COLLECTOR_RESOURCE_ID,
		    L_COLLECTOR_RES_TYPE,
		    L_COLLECTOR_RESOURCE_NAME,
		    L_RESOURCE_ID,
		    L_RESOURCE_TYPE,
		    L_PARTY_ID,
		    L_CUST_ACCOUNT_ID,
		    L_SITE_USE_ID
		  limit l_max_fetches;
	      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_BILLTO_COLLECTOR_PROF_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
				COLLECTOR_RES_TYPE    = L_COLLECTOR_RES_TYPE(i),
				COLLECTOR_RESOURCE_NAME = L_COLLECTOR_RESOURCE_NAME(I),
				collector_id = l_collector_id(i),
				resource_id=l_resource_id(i),
				resource_type=l_resource_type(i),
				last_update_date   = SYSDATE,
				last_updated_by    = FND_GLOBAL.USER_ID
			   WHERE
			    SITE_USE_ID = L_SITE_USE_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_BILLTO_COLLECTOR_PROF_dt updated ' || L_COLLECTOR_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_BILLTO_COLLECTOR_PROF_dt % ISOPEN THEN
		CLOSE C_BILLTO_COLLECTOR_PROF_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'C_COLLECTOR_PROF update received' || SQLERRM);
	       END;

	       BEGIN
	      OPEN C_BILLTO_ch_coll_dt_sum;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_BILLTO_ch_coll_dt_sum cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_COLLECTOR_RES_TYPE.delete;
		L_COLLECTOR_RESOURCE_ID.delete  ;
		L_COLLECTOR_ID.delete;
		L_SITE_USE_ID.delete;

	      LOOP
		FETCH C_BILLTO_ch_coll_dt_sum bulk collect
		  INTO
		    L_COLLECTOR_RESOURCE_ID,
		    L_COLLECTOR_RES_TYPE,
		    L_COLLECTOR_ID,
		    L_SITE_USE_ID
		  limit l_max_fetches;
	      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_BILLTO_ch_coll_dt_sum ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
				COLLECTOR_RES_TYPE    = L_COLLECTOR_RES_TYPE(i),
				collector_id = l_collector_id(i),
				last_update_date   = SYSDATE,
				last_updated_by    = FND_GLOBAL.USER_ID
			   WHERE
			    SITE_USE_ID = L_SITE_USE_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_BILLTO_ch_coll_dt_sum updated ' || L_COLLECTOR_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_BILLTO_ch_coll_dt_sum % ISOPEN THEN
		CLOSE C_BILLTO_ch_coll_dt_sum;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'C_BILLTO_ch_coll_dt_sum update received' || SQLERRM);
	       END;

	       BEGIN
	      OPEN C_BILLTO_PRO_DTLS_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_pro_dtls_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_SITE_USE_ID.delete;
		L_NUMBER_OF_PROMISES.delete;
		L_BROKEN_PROMISE_AMOUNT .delete;
		L_PROMISE_AMOUNT.delete;

	      LOOP
		FETCH C_BILLTO_PRO_DTLS_dt bulk collect
		  INTO
		    L_SITE_USE_ID,
		    L_NUMBER_OF_PROMISES,
		    L_BROKEN_PROMISE_AMOUNT,
		    L_PROMISE_AMOUNT
		  limit l_max_fetches;
	      IF L_SITE_USE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_BILLTO_PRO_DTLS_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET NUMBER_OF_PROMISES     = L_NUMBER_OF_PROMISES(i),
				BROKEN_PROMISE_AMOUNT  = L_BROKEN_PROMISE_AMOUNT(i),
				PROMISE_AMOUNT         = L_PROMISE_AMOUNT(i)
			   WHERE
			    SITE_USE_ID = L_SITE_USE_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_pro_dtls_dt updated ' || L_SITE_USE_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_BILLTO_PRO_DTLS_dt % ISOPEN THEN
		CLOSE C_BILLTO_PRO_DTLS_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Broken Promise update received' || SQLERRM);
	       END;

		BEGIN
			OPEN C_BILLTO_DELN_CNT_dt;
			LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_deln_cnt_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_SITE_USE_ID.delete;
			L_NUMBER_OF_DELINQUENCIES.delete;
			L_PAST_DUE_INV_VALUE.delete;

		    LOOP
			FETCH C_BILLTO_DELN_CNT_dt bulk collect
			INTO
			L_SITE_USE_ID,
			L_NUMBER_OF_DELINQUENCIES,
			L_PAST_DUE_INV_VALUE
			limit l_max_fetches;
			IF L_SITE_USE_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_del_cnt_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
				EXIT;
			ELSE

			   forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			     UPDATE IEX_DLN_UWQ_SUMMARY
			     SET NUMBER_OF_DELINQUENCIES = L_NUMBER_OF_DELINQUENCIES(i),
				 PAST_DUE_INV_VALUE = L_PAST_DUE_INV_VALUE(i)
			     WHERE
			     SITE_USE_ID = L_SITE_USE_ID(i);
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_deln_cnt_dt updated ' || L_SITE_USE_ID.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
		       END IF;
		    END LOOP;
		   IF C_BILLTO_DELN_CNT_dt % ISOPEN THEN
		       CLOSE C_BILLTO_DELN_CNT_dt;
		   END IF;

		EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
		END;

	       if l_enable_work_queue = 'Y' then  --update active,pending and complete nodes of delinquency and promise only when the profile 'IEX: Enable Work Queue Statuses' is set to Yes.
			BEGIN
				OPEN C_BILLTO_DELN_DTLS_dt;
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_BILLTO_DELN_DTLS_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
				L_SITE_USE_ID.delete;
				L_PENDING_DELINQUENCIES.delete;
				L_COMPLETE_DELINQUENCIES.delete;
				L_ACTIVE_DELINQUENCIES.delete;

			    LOOP
				FETCH C_BILLTO_DELN_DTLS_dt bulk collect
				INTO
				L_SITE_USE_ID,
				L_PENDING_DELINQUENCIES,
				L_COMPLETE_DELINQUENCIES,
				L_ACTIVE_DELINQUENCIES
				limit l_max_fetches;
				IF L_SITE_USE_ID.COUNT = 0 THEN
					LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_BILLTO_DELN_DTLS_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
					LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
					EXIT;
				ELSE

				   forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
				     UPDATE IEX_DLN_UWQ_SUMMARY
				     SET PENDING_DELINQUENCIES   = L_PENDING_DELINQUENCIES(i),
					 COMPLETE_DELINQUENCIES  = L_COMPLETE_DELINQUENCIES(i),
					 ACTIVE_DELINQUENCIES    = L_ACTIVE_DELINQUENCIES(i)
				     WHERE
				     SITE_USE_ID = L_SITE_USE_ID(i);
				     LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_BILLTO_DELN_DTLS_dt ' || L_SITE_USE_ID.count ||  ' rows ');
				     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
			       END IF;
			    END LOOP;
			   IF C_BILLTO_DELN_DTLS_dt % ISOPEN THEN
			       CLOSE C_BILLTO_DELN_DTLS_dt;
			   END IF;

			EXCEPTION WHEN OTHERS THEN
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
			END;

		      BEGIN
		      OPEN C_BILLTO_PRO_SUMM_dt;
		       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_BILLTO_PRO_SUMM_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			L_SITE_USE_ID.delete;
			L_ACTIVE_PROMISES.delete;
			L_COMPLETE_PROMISES.delete;
			L_PENDING_PROMISES.delete;

		      LOOP
			FETCH C_BILLTO_PRO_SUMM_dt bulk collect
			  INTO
			    L_SITE_USE_ID,
			    L_PENDING_PROMISES,
			    L_COMPLETE_PROMISES,
			    L_ACTIVE_PROMISES
			  limit l_max_fetches;
		      IF L_SITE_USE_ID.COUNT = 0 THEN

			  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_BILLTO_PRO_SUMM_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
			  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
			  EXIT;

		       ELSE

			forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
				   UPDATE IEX_DLN_UWQ_SUMMARY
				    SET ACTIVE_PROMISES    = L_ACTIVE_PROMISES(i),
					COMPLETE_PROMISES  = L_COMPLETE_PROMISES(i),
					PENDING_PROMISES   = L_PENDING_PROMISES(i)
				   WHERE
				    SITE_USE_ID = L_SITE_USE_ID(i);
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_BILLTO_PRO_SUMM_dt updated ' || L_SITE_USE_ID.count ||  ' rows ');
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


		      END IF;
		      END LOOP;

		       IF C_BILLTO_PRO_SUMM_dt % ISOPEN THEN
			CLOSE C_BILLTO_PRO_SUMM_dt;
		       END IF;

		       EXCEPTION WHEN OTHERS THEN
			 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Promise update received' || SQLERRM);
		       END;
	      end if; --if l_enable_work_queue = 'Y' then

	      BEGIN
	      OPEN C_BILLTO_LAST_PAYMENT_DTLS_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_BILLTO_LAST_PAYMENT_DTLS_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_SITE_USE_ID.delete;
		L_LAST_PAYMENT_AMOUNT.delete;
		L_LAST_PAYMENT_AMOUNT_CURR.delete;
		L_LAST_PAYMENT_NUMBER.delete;

	      LOOP
		FETCH C_BILLTO_LAST_PAYMENT_DTLS_dt bulk collect
		  INTO
		    L_SITE_USE_ID,
		    L_LAST_PAYMENT_AMOUNT,
		    L_LAST_PAYMENT_AMOUNT_CURR,
		    L_LAST_PAYMENT_NUMBER
		  limit l_max_fetches;
	      IF L_SITE_USE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_last_payment_amount_dtls_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET LAST_PAYMENT_AMOUNT = gl_currency_api.convert_amount_sql(L_LAST_PAYMENT_AMOUNT_CURR(i), CURRENCY,
						       sysdate,iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE', ''), L_LAST_PAYMENT_AMOUNT(i)),
				LAST_PAYMENT_AMOUNT_CURR = L_LAST_PAYMENT_AMOUNT_CURR(i),
				LAST_PAYMENT_NUMBER = L_LAST_PAYMENT_NUMBER(i)
			   WHERE
			    SITE_USE_ID = L_SITE_USE_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_LAST_PAYMENT_dtls_dt updated ' || L_LAST_PAYMENT_AMOUNT.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_BILLTO_LAST_PAYMENT_DTLS_dt % ISOPEN THEN
		CLOSE C_BILLTO_LAST_PAYMENT_DTLS_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Last payment amount update received' || SQLERRM);
	       END;

	      BEGIN
	      OPEN C_BILLTO_BANKRUPTCIES_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_BILLTO_BANKRUPTCIES_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_PARTY_ID.delete;
		L_NUMBER_OF_BANKRUPTCIES.delete;

	      LOOP
		FETCH C_BILLTO_BANKRUPTCIES_dt bulk collect
		  INTO
		    L_PARTY_ID,
		    L_NUMBER_OF_BANKRUPTCIES
		  limit l_max_fetches;
	      IF L_PARTY_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_BILLTO_BANKRUPTCIES_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET NUMBER_OF_BANKRUPTCIES     = L_NUMBER_OF_BANKRUPTCIES(i)
			   WHERE
			    PARTY_ID = L_PARTY_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_BILLTO_BANKRUPTCIES_dt updated ' || L_PARTY_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


	      END IF;
	      END LOOP;
	       IF C_BILLTO_BANKRUPTCIES_dt % ISOPEN THEN
		CLOSE C_BILLTO_BANKRUPTCIES_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bankruptcy update received' || SQLERRM);
	       END;
              COMMIT;
               LogMessage(FND_LOG.LEVEL_STATEMENT,'Commited');

	      BEGIN
	      OPEN C_BILLTO_SCORE_dt;
	       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_score_dt cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		L_SITE_USE_ID.delete;
		L_SCORE.delete;
		L_SCORE_ID.delete;
		L_SCORE_NAME.delete;

	      LOOP
		FETCH C_BILLTO_SCORE_dt bulk collect
		  INTO
		    L_SITE_USE_ID,
		    L_SCORE,
		    l_score_id,
		    l_score_name
		  limit l_max_fetches;
	      IF L_SITE_USE_ID.COUNT = 0 THEN

		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_score_dt ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
		  LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		  EXIT;

	       ELSE

		forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
			   UPDATE IEX_DLN_UWQ_SUMMARY
			    SET SCORE     = L_SCORE(i),
				score_id=l_score_id(i),
				score_name=l_score_name(i)
			   WHERE
			    SITE_USE_ID = L_SITE_USE_ID(i);
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_score_dt updated ' || L_SITE_USE_ID.count ||  ' rows ');
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

	      END IF;
	      END LOOP;
	       IF C_BILLTO_SCORE_dt % ISOPEN THEN
		CLOSE C_BILLTO_SCORE_dt;
	       END IF;

	       EXCEPTION WHEN OTHERS THEN
		 LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Score update received' || SQLERRM);
	       END;--end 9597052
	    end if;
	    --End Bug 9597052 28-Apr-2010 barathsr
              end if;
          END IF;

        -- End - Andre Araujo - 10/20/06 - Added dynamic sql
      END IF;

      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Total inserted ' || l_total || ' rows');
    --  return;
     -- exit;
    If (P_mode = 'CP') THEN --Bug5691098
      -- 2. Fetching and updating table with stategy info
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,' ');
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Fetching and updating table with strategy info...');
      l_total := 0;
      l_count := 0;
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start open cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
      OPEN c_strategy_summary(p_level, l_from_date,p_org_id);
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End open cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
      LOOP
          l_count := l_count +1;
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'----------');
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bulk ' || l_count);

          L_JTF_OBJECT_ID.delete;
          L_WORK_ITEM_ID.delete;
          L_SCHEDULE_START.delete;
          L_SCHEDULE_END.delete;
          L_WORK_TYPE.delete;
          L_CATEGORY_TYPE.delete;
          L_PRIORITY_TYPE.delete;
	  L_wkitem_RESOURCE_ID.delete;  --schekuri
          L_STRATEGY_ID.delete;
	  L_STRATEGY_TEMPLATE_ID.delete;
	  L_WORK_ITEM_TEMPLATE_ID.delete;
	  L_STATUS_CODE.delete;
	  L_STR_STATUS.delete;  -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	  L_START_TIME.delete;
	  L_END_TIME.delete;
	  L_WORK_ITEM_ORDER.delete;
	  L_ESCALATED_YN.delete;  --Added for bug#6981126 by schekuri on 27-Jun-2008

          LogMessage(FND_LOG.LEVEL_STATEMENT,'Inited all arrays');

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          FETCH c_strategy_summary bulk collect
          INTO
            L_JTF_OBJECT_ID,
            L_WORK_ITEM_ID,
            L_SCHEDULE_START,
            L_SCHEDULE_END,
            L_CATEGORY_TYPE,
	    L_WORK_TYPE,
            L_PRIORITY_TYPE,
	    L_WKITEM_RESOURCE_ID,  --schekuri
	    L_STRATEGY_ID,
	    L_STRATEGY_TEMPLATE_ID,
	    L_WORK_ITEM_TEMPLATE_ID,
	    L_STATUS_CODE,
	    L_STR_STATUS,  -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	    L_START_TIME,
	    L_END_TIME,
	    L_WORK_ITEM_ORDER,
	    L_ESCALATED_YN
          limit l_max_fetches;

          IF L_JTF_OBJECT_ID.COUNT = 0 THEN

            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
            CLOSE c_strategy_summary;
            EXIT;

          ELSE

            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Fetched  ' || L_JTF_OBJECT_ID.COUNT || ' rows.');
            LogMessage(FND_LOG.LEVEL_STATEMENT,' Updating table...');
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start updating time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

            IF p_level = 'CUSTOMER' THEN

              forall i IN L_JTF_OBJECT_ID.FIRST .. L_JTF_OBJECT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                   SET WORK_ITEM_ID = L_WORK_ITEM_ID(i),
                    SCHEDULE_START = L_SCHEDULE_START(i),
                    SCHEDULE_END = L_SCHEDULE_END(i),
                    WORK_TYPE = L_WORK_TYPE(i),
                    CATEGORY_TYPE = L_CATEGORY_TYPE(i),
                    PRIORITY_TYPE = L_PRIORITY_TYPE(i),
		    WKITEM_RESOURCE_ID = L_WKITEM_RESOURCE_ID(i),  --schekuri
  	    	    STRATEGY_ID = L_STRATEGY_ID(i),
	    	    STRATEGY_TEMPLATE_ID = L_STRATEGY_TEMPLATE_ID(i),
		    WORK_ITEM_TEMPLATE_ID = L_WORK_ITEM_TEMPLATE_ID(i),
	            STATUS_CODE = L_STATUS_CODE(i),
		    STR_STATUS =  L_STR_STATUS(i),  -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	            START_TIME = L_START_TIME(i),
	            END_TIME = L_END_TIME(i),
	            WORK_ITEM_ORDER = L_WORK_ITEM_ORDER(i),
		    WKITEM_ESCALATED_YN = L_ESCALATED_YN(i)		   --Added for bug#6981126 by schekuri on 27-Jun-2008
                   WHERE PARTY_ID = L_JTF_OBJECT_ID(i);

            ELSIF p_level = 'ACCOUNT' THEN

              forall i IN L_JTF_OBJECT_ID.FIRST .. L_JTF_OBJECT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                   SET WORK_ITEM_ID = L_WORK_ITEM_ID(i),
                    SCHEDULE_START = L_SCHEDULE_START(i),
                    SCHEDULE_END = L_SCHEDULE_END(i),
                    WORK_TYPE = L_WORK_TYPE(i),
                    CATEGORY_TYPE = L_CATEGORY_TYPE(i),
                    PRIORITY_TYPE = L_PRIORITY_TYPE(i),
		    WKITEM_RESOURCE_ID = L_WKITEM_RESOURCE_ID(i),  --schekuri
  	    	    STRATEGY_ID = L_STRATEGY_ID(i),
	    	    STRATEGY_TEMPLATE_ID = L_STRATEGY_TEMPLATE_ID(i),
		    WORK_ITEM_TEMPLATE_ID = L_WORK_ITEM_TEMPLATE_ID(i),
	            STATUS_CODE = L_STATUS_CODE(i),
		    STR_STATUS =  L_STR_STATUS(i),   -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	            START_TIME = L_START_TIME(i),
	            END_TIME = L_END_TIME(i),
	            WORK_ITEM_ORDER = L_WORK_ITEM_ORDER(i),
		    WKITEM_ESCALATED_YN = L_ESCALATED_YN(i)		    --Added for bug#6981126 by schekuri on 27-Jun-2008
                   WHERE CUST_ACCOUNT_ID = L_JTF_OBJECT_ID(i);

            ELSIF p_level = 'BILL_TO' THEN

              forall i IN L_JTF_OBJECT_ID.FIRST .. L_JTF_OBJECT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                   SET WORK_ITEM_ID = L_WORK_ITEM_ID(i),
                    SCHEDULE_START = L_SCHEDULE_START(i),
                    SCHEDULE_END = L_SCHEDULE_END(i),
                    WORK_TYPE = L_WORK_TYPE(i),
                    CATEGORY_TYPE = L_CATEGORY_TYPE(i),
                    PRIORITY_TYPE = L_PRIORITY_TYPE(i),
		    WKITEM_RESOURCE_ID = L_WKITEM_RESOURCE_ID(i),  --schekuri
  	    	    STRATEGY_ID = L_STRATEGY_ID(i),
	    	    STRATEGY_TEMPLATE_ID = L_STRATEGY_TEMPLATE_ID(i),
		    WORK_ITEM_TEMPLATE_ID = L_WORK_ITEM_TEMPLATE_ID(i),
	            STATUS_CODE = L_STATUS_CODE(i),
		    STR_STATUS =  L_STR_STATUS(i),   -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	            START_TIME = L_START_TIME(i),
	            END_TIME = L_END_TIME(i),
	            WORK_ITEM_ORDER = L_WORK_ITEM_ORDER(i),
		    WKITEM_ESCALATED_YN = L_ESCALATED_YN(i)   --Added for bug#6981126 by schekuri on 27-Jun-2008
                 WHERE SITE_USE_ID = L_JTF_OBJECT_ID(i);

            END IF;

            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Updated ' || L_JTF_OBJECT_ID.COUNT || ' rows');
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End updating time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
            COMMIT;
            LogMessage(FND_LOG.LEVEL_STATEMENT,'Commited');

            l_total := l_total + L_JTF_OBJECT_ID.COUNT;
            LogMessage(FND_LOG.LEVEL_STATEMENT,'So far processed ' || l_total || ' rows');

          END IF;

      END LOOP;

      IF c_strategy_summary % ISOPEN THEN
        CLOSE c_strategy_summary;
      END IF;

      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Total updated ' || l_total || ' rows with strategy info');



 End If; --Bug5691098

      --Bug5701973. Start.
    IF (l_from_date IS NOT NULL and p_mode = 'CP' ) THEN --Bug5691098
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'TCA Update Started at :  ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
       if p_level<>'BILL_TO' then --Added for Bug 9487600 24-Mar-2010 barathsr
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Opened Cursor changed_party at : ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        BEGIN
       --Party changes update
       OPEN changed_party(l_from_date,p_level,p_org_id);
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Opened Cursor changed_party at : ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_PARTY_ID.delete;
        L_ADDRESS1.delete;
        L_CITY.delete;
        L_STATE.delete;
        L_COUNTY.delete;
        L_COUNTRY.delete;
        L_PROVINCE.delete;
        L_POSTAL_CODE.delete;

      LOOP
	 FETCH changed_party bulk collect
          INTO
	    L_PARTY_ID,
            L_ADDRESS1,
            L_CITY,
            L_STATE,
            L_COUNTY,
            L_COUNTRY,
	    L_PROVINCE,
            L_POSTAL_CODE
          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Changed_Party  Cursor Fetching end time:   ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

        ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST

                   UPDATE IEX_DLN_UWQ_SUMMARY
                   SET address1           = L_ADDRESS1(i),
                       city               = L_CITY(i),
                       state              = L_STATE(i),
                       county             = L_COUNTY(i),
                       country            = L_COUNTRY(i),
                       province           = L_PROVINCE(i),
                       postal_code        = L_POSTAL_CODE(i),
		       last_update_date   = SYSDATE,
		       last_updated_by    = FND_GLOBAL.USER_ID
                 WHERE PARTY_ID = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Changed_Party  Cursor updated ' ||L_PARTY_ID.count || ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
      COMMIT;
      END IF;
      END LOOP;
        CLOSE changed_party;


      EXCEPTION WHEN OTHERS THEN
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,SQLERRM);
      END;
      end if;--Added for Bug 9487600 24-Mar-2010 barathsr

   --Begin Bug 9487600 24-Mar-2010 barathsr
  --Bill To Site changes update
     IF p_level='BILL_TO' THEN
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'TCA Update Started at :  ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
     BEGIN
     open changed_billto_sites(l_from_date,p_level,p_org_id);
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Opened Cursor changed_billto_sites at : ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_SITE_USE_ID.delete;
        L_ADDRESS1.delete;
        L_CITY.delete;
        L_STATE.delete;
        L_COUNTY.delete;
        L_COUNTRY.delete;
        L_PROVINCE.delete;
        L_POSTAL_CODE.delete;
      loop
      fetch changed_billto_sites bulk collect
      into
      L_SITE_USE_ID,
        L_ADDRESS1,
        L_CITY,
        L_STATE,
        L_COUNTY,
        L_COUNTRY,
        L_PROVINCE,
        L_POSTAL_CODE
	limit l_max_fetches;
	IF l_site_use_id.count=0 then
	   LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: Changed_billto_sites ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE
         forall i in l_site_use_id.first..l_site_use_id.last
	 update iex_dln_uwq_summary
	 set address1=l_address1(i),
	     city               = L_CITY(i),
             state              = L_STATE(i),
             county             = L_COUNTY(i),
             country            = L_COUNTRY(i),
             province           = L_PROVINCE(i),
             postal_code        = L_POSTAL_CODE(i),
	     last_update_date   = SYSDATE,
             last_updated_by    = FND_GLOBAL.USER_ID
           WHERE site_use_id= L_site_use_ID(i);

	   LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Changed_billto_sites  Cursor updated ' ||L_SITE_USE_ID.count || ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
      COMMIT;
      END IF;
      END LOOP;
        CLOSE changed_billto_sites;
      EXCEPTION WHEN OTHERS THEN
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,SQLERRM);
      END;
      end if;

 --End Bug 9487600 24-Mar-2010 barathsr




     --Profile Changes Update
     BEGIN
      OPEN changed_profiles(l_from_date,p_level,p_org_id);
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened changed_profiles cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

        L_PARTY_ID.delete;
	L_CUST_ACCOUNT_ID.delete;
	L_SITE_USE_ID.delete;
	L_COLLECTOR_ID.delete;

      LOOP
        FETCH changed_profiles bulk collect
          INTO
  	    L_COLLECTOR_ID,
	    L_PARTY_ID,
	    L_CUST_ACCOUNT_ID,
	    L_SITE_USE_ID
          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: Changed_Profiles ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                   SET COLLECTOR_ID = L_COLLECTOR_ID(i),
		   last_update_date   = SYSDATE,
		   last_updated_by    = FND_GLOBAL.USER_ID
                 WHERE
		   PARTY_ID = L_PARTY_ID(i)
 		   AND nvl(CUST_ACCOUNT_ID,1) = nvl(L_CUST_ACCOUNT_ID(i),1)
		   AND nvl(SITE_USE_ID,1)     = nvl(L_SITE_USE_ID(i),1);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Changed_profiles updated ' || L_PARTY_ID.count || ' rows ' );
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

      COMMIT;
      END IF;
      END LOOP;
       IF changed_profiles % ISOPEN THEN
        CLOSE changed_profiles;
       END IF;
       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,SQLERRM);
       END;

     --Collector Changes Update
     BEGIN
      OPEN changed_collector(l_from_date,p_level,p_org_id);
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open changed_collector cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_COLLECTOR_RESOURCE_ID.delete  ;
	L_COLLECTOR_RESOURCE_NAME.delete; -- Added for the bug#7562130
	L_COLLECTOR_ID.delete;
	L_RESOURCE_TYPE.delete;

      LOOP
        FETCH changed_collector bulk collect
          INTO
  	    L_COLLECTOR_RESOURCE_ID,
	    L_COLLECTOR_RESOURCE_NAME, -- Added for the bug#7562130
	    L_RESOURCE_TYPE,
	    L_COLLECTOR_ID
          limit l_max_fetches;
      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: Changed_Collector ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_COLLECTOR_ID.FIRST .. L_COLLECTOR_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
		        COLLECTOR_RESOURCE_NAME = L_COLLECTOR_RESOURCE_NAME(i), -- Added for the bug#7562130
		        COLLECTOR_RES_TYPE    = L_RESOURCE_TYPE(i),
			last_update_date   = SYSDATE,
		        last_updated_by    = FND_GLOBAL.USER_ID
                   WHERE
		    COLLECTOR_ID = L_COLLECTOR_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Changed_collector updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

      COMMIT;
      END IF;
      END LOOP;
       IF changed_collector % ISOPEN THEN
        CLOSE changed_collector;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Changed Collector update received' || SQLERRM);
       END;
       --Contact Point  Changes Update
      BEGIN
       OPEN changed_contact(l_from_date,p_level,p_org_id);
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened Cursor  changed_contact  cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_PARTY_ID.delete;
        L_PHONE_COUNTRY_CODE.delete;
        L_PHONE_AREA_CODE.delete;
        L_PHONE_NUMBER.delete;
        L_PHONE_EXTENSION.delete;


      LOOP
	 FETCH changed_contact bulk collect
          INTO
	   L_PARTY_ID,
	   L_PHONE_COUNTRY_CODE,
	   L_PHONE_AREA_CODE,
	   L_PHONE_NUMBER,
	   L_PHONE_EXTENSION

          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Changed_contact  Cursor Fetching end time:   ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

        ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST

                   UPDATE IEX_DLN_UWQ_SUMMARY
                   SET PHONE_COUNTRY_CODE = L_PHONE_COUNTRY_CODE(i),
		       PHONE_AREA_CODE    = L_PHONE_AREA_CODE(i),
		       PHONE_NUMBER       = L_PHONE_NUMBER(i),
		       PHONE_EXTENSION    = L_PHONE_EXTENSION(i),
		       last_update_date   = SYSDATE,
		       last_updated_by    = FND_GLOBAL.USER_ID
                 WHERE PARTY_ID = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Changed_contact  Cursor updated ' ||L_PARTY_ID.count || ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

      COMMIT;
      END IF;
      END LOOP;
        CLOSE changed_contact;


      EXCEPTION WHEN OTHERS THEN
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Contact point raised error ' || SQLERRM);
      END;

      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'TCA Update Finished at :  ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
     END IF;

     --Bug5701973. End.

     -- Start PNAVEENK for bug#7662453 on 22-12-2008
      IF nvl(fnd_profile.value('IEX_SHOW_AGING_IN_UWQ'), 'N') = 'Y' then
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened Cursor  c_aging_summary  cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

     IF p_level = 'CUSTOMER' THEN
      populate_aging_info('PARTY',l_from_date,p_org_id);--Added for Bug 8707923 27-Jul-2009 barathsr
     ELSIF p_level = 'ACCOUNT' THEN
      populate_aging_info('CUST',l_from_date,p_org_id);--Added for Bug 8707923 27-Jul-2009 barathsr
     ELSIF p_level = 'BILL_TO' THEN
      populate_aging_info('BILLTO',l_from_date,p_org_id);--Added for Bug 8707923 27-Jul-2009 barathsr
     end if;

      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Updated aging info in Table IEX_DLN_UWQ_SUMMARY at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

      end if;
     -- End for bug#7662453

     --Begin Bug 8823567 22-Oct-2009 barathsr
    IF nvl(fnd_profile.value('IEX_SHOW_NET_BAL_IN_UWQ'), 'N') = 'Y' then
     if p_level='CUSTOMER' then
       calculate_net_balance('CUSTOMER',l_from_date,p_org_id);
     elsif p_level='ACCOUNT' then
       calculate_net_balance('ACCOUNT',l_from_date,p_org_id);
     elsif p_level='BILL_TO' then
       calculate_net_balance('BILL_TO',l_from_date,p_org_id);
     end if;
     end if;
      --End Bug 8823567 22-Oct-2009 barathsr


     -- Start for bug#8261043 on 3-3-2009
      IF nvl(fnd_profile.value('IEX_SHOW_CONT_IN_UWQ'), 'N') = 'Y' then
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened Cursor  c_contract_summary  cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

      IF l_level in ('CUSTOMER','ACCOUNT','BILL_TO') then
        populate_contracts_info;
      end if;

       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Updated contracts info in Table IEX_DLN_UWQ_SUMMARY at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
       end if;
      -- End for bug#8261043
     DELETE from AR_CONC_PROCESS_REQUESTS
     WHERE REQUEST_ID  = FND_GLOBAL.conc_request_id;
     COMMIT;


EXCEPTION
    WHEN deadlock_detected THEN
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Exception in populate_uwq_sum: deadlock detected');
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'SQLCODE: ' || to_char(SQLCODE) || ' SQLERRM: ' || sqlerrm);
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Total processed ' || l_total || ' rows');
      x_errbuf := sqlerrm;
      x_retcode := SQLCODE;


      -- Begin - Andre Araujo - 10/20/06 - Added dynamic sql
      -- If the date is not null we will not read only the new/updated records
      IF c_iex_acc_uwq_summary % ISOPEN    or
         c_iex_acc_uwq_dt_sum % ISOPEN     or
         c_iex_billto_uwq_summary % ISOPEN or
         c_iex_billto_uwq_dt_sum % ISOPEN or
         c_iex_cu_uwq_summary % ISOPEN or
         c_iex_cu_uwq_summary % ISOPEN
      THEN
          IF p_level = 'CUSTOMER' THEN
              if (l_from_date is null) then
                CLOSE c_iex_cu_uwq_summary;
              else
                CLOSE c_iex_cu_uwq_dt_sum;
              end if;
          ELSIF p_level = 'ACCOUNT' THEN
              if (l_from_date is null) then
                CLOSE c_iex_acc_uwq_summary;
              else
                CLOSE c_iex_acc_uwq_dt_sum;
              end if;
          ELSIF p_level = 'BILL_TO' THEN
              if (l_from_date is null) then
                  CLOSE c_iex_billto_uwq_summary;
              else
                  CLOSE c_iex_billto_uwq_dt_sum;
              end if;
          END IF;
      END IF;

      -- End - Andre Araujo - 10/20/06 - Added dynamic sql
      Rollback;
      DELETE from AR_CONC_PROCESS_REQUESTS
      where REQUEST_ID  = FND_GLOBAL.conc_request_id;
      commit;

      if FND_GLOBAL.Conc_Request_Id is not null then
          l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                      status => 'ERROR',
                      message => 'The process has failed. Please review log file.');
      end if;

    WHEN others THEN
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Exception in populate_uwq_sum: other');
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'SQLCODE: ' || to_char(SQLCODE) || ' SQLERRM: ' || sqlerrm);
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
      LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Total processed ' || l_total || ' rows');
      x_errbuf := sqlerrm;
      x_retcode := SQLCODE;

      -- Begin - Andre Araujo - 10/20/06 - Added dynamic sql
      -- If the date is not null we will not read only the new/updated records

      IF c_iex_acc_uwq_summary % ISOPEN    or
         c_iex_acc_uwq_dt_sum % ISOPEN     or
         c_iex_billto_uwq_summary % ISOPEN or
         c_iex_billto_uwq_dt_sum % ISOPEN or
         c_iex_cu_uwq_summary % ISOPEN or
         c_iex_cu_uwq_summary % ISOPEN
      THEN
          IF p_level = 'CUSTOMER' THEN
              if (l_from_date is null) then
                CLOSE c_iex_cu_uwq_summary;
              else
                CLOSE c_iex_cu_uwq_dt_sum;
              end if;
          ELSIF p_level = 'ACCOUNT' THEN
              if (l_from_date is null) then
                CLOSE c_iex_acc_uwq_summary;
              else
                CLOSE c_iex_acc_uwq_dt_sum;
              end if;
          ELSIF p_level = 'BILL_TO' THEN
              if (l_from_date is null) then
                  CLOSE c_iex_billto_uwq_summary;
              else
                  CLOSE c_iex_billto_uwq_dt_sum;
              end if;
          END IF;
      END IF;

      -- End - Andre Araujo - 10/20/06 - Added dynamic sql
      Rollback;
      DELETE from AR_CONC_PROCESS_REQUESTS
      where REQUEST_ID  = FND_GLOBAL.conc_request_id;
      commit;

      if FND_GLOBAL.Conc_Request_Id is not null then
          l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                      status => 'ERROR',
                      message => 'The process has failed. Please review log file.');
      end if;

END;

PROCEDURE billto_refresh_summary_incr(
                    x_errbuf            OUT nocopy VARCHAR2,
                    x_retcode           OUT nocopy VARCHAR2,
                    FROM_DATE           IN  VARCHAR2,
 	            P_MODE              IN  VARCHAR2 DEFAULT 'CP',
		    p_level in varchar2)--Added for Bug 8707923 27-Jul-2009 barathsr
		    is
l_count number;

CURSOR c_iex_billto_uwq_summary IS
    SELECT
    trx_summ.org_id,
    objb.object_function ieu_object_function,
    objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
    '' ieu_media_type_uuid,
    'CUSTOMER_SITE_USE_ID' ieu_param_pk_col,
    to_char(trx_summ.site_use_id) ieu_param_pk_value,
    1 resource_id,
    'RS_EMPLOYEE' resource_type,
    party.party_id party_id,
    party.party_name party_name,
    trx_summ.cust_account_id cust_account_id,
    acc.account_name account_name,
    acc.account_number account_number,
    trx_summ.site_use_id site_use_id,
    site_uses.location location,
    max(gl.CURRENCY_CODE) currency,
    SUM(trx_summ.op_invoices_count) op_invoices_count,
    SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
    SUM(trx_summ.op_deposits_count) op_deposits_count,
    SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
    SUM(trx_summ.op_chargeback_count) op_chargeback_count,
    SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
    SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
    SUM(trx_summ.disputed_inv_count) disputed_inv_count,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
    SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
    MAX(trx_summ.last_payment_date) last_payment_date,
    --MAX(iex_uwq_view_pkg.get_last_payment_amount(0,   0,   trx_summ.site_use_id)) last_payment_amount,
    max(gl.CURRENCY_CODE) last_payment_amount_curr,
--   MAX(iex_uwq_view_pkg.get_last_payment_number(0,   0,   trx_summ.site_use_id)) last_payment_number,
    MAX(trx_summ.last_update_date) last_update_date,
    MAX(trx_summ.last_updated_by) last_updated_by,
    MAX(trx_summ.creation_date) creation_date,
    MAX(trx_summ.created_by) created_by,
    MAX(trx_summ.last_update_login) last_update_login,
    -- Start for the bug#8538945 by PNAVEENK
 /*   party.address1 address1,
    party.city city,
    party.state state,
    party.county county,
    fnd_terr.territory_short_name country,
    party.province province,
    party.postal_code postal_code */
    loc.address1 address1,
    loc.city city,
    loc.state state,
    loc.county county,
    fnd_terr.territory_short_name country,
    loc.province province,
    loc.postal_code postal_code
   -- end for the bug#8538945
  FROM ar_trx_bal_summary trx_summ,
    hz_cust_accounts acc,
    hz_parties party,
    jtf_objects_b objb,
    fnd_territories_tl fnd_terr,
    hz_cust_site_uses_all site_uses,
    GL_SETS_OF_BOOKS gl,
    AR_SYSTEM_PARAMETERS_all sys,
    -- Added for the bug#8538945 by PNAVEENK
     HZ_CUST_ACCT_SITES_all ACCT_SITE,--Modified for Bug 9487600 23-Mar-2010 barathsr
     HZ_PARTY_SITES PARTY_SITE,
       HZ_LOCATIONS LOC
     -- end for the bug#8538945
  WHERE trx_summ.reference_1 = '1'
    -- Added for the bug#8538945 by PNAVEENK
   and PARTY_SITE.LOCATION_ID = LOC.LOCATION_ID
    and ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
   and site_uses.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID
   -- end for the bug#8538945
   AND trx_summ.site_use_id = site_uses.site_use_id
   AND trx_summ.cust_account_id = acc.cust_account_id
   AND acc.party_id = party.party_id
   AND objb.object_code = 'IEX_BILLTO'
   AND objb.object_code <> 'IEX_DELINQUENCY' --Added for Bug 8707923 27-Jul-2009 barathsr
   AND loc.country = fnd_terr.territory_code(+)  -- Changed for the bug#8538945
   AND fnd_terr.LANGUAGE(+) = userenv('LANG')
   and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
   and trx_summ.org_id = sys.org_id
   and trx_summ.site_use_id in (select temp.object_id from iex_pop_uwq_summ_gt temp where
   temp.org_id=trx_summ.org_id)
  GROUP BY trx_summ.org_id,
    objb.object_function,
    objb.object_parameters,
    party.party_id,
    party.party_name,
    trx_summ.cust_account_id,
    acc.account_name,
    acc.account_number,
    trx_summ.site_use_id,
    site_uses.location,
     -- Start for the bug#8538945 by PNAVEENK
  /*  party.address1,
    party.city,
    party.state,
    party.county,
    fnd_terr.territory_short_name,
    party.province,
    party.postal_code; */
    loc.address1,
    loc.city,
    loc.state,
    loc.county,
    fnd_terr.territory_short_name,
    loc.province,
    loc.postal_code;
     -- end for the bug#8538945

    CURSOR c_strategy_summary IS
     select strat.jtf_object_id,
        wkitem.WORK_ITEM_ID,
        wkitem.schedule_start schedule_start,
        wkitem.schedule_end schedule_end,
        stry_temp_wkitem.category_type category,
        stry_temp_wkitem.WORK_TYPE,
        stry_temp_wkitem.PRIORITY_TYPE,
        wkitem.resource_id,
        wkitem.strategy_id,
        strat.strategy_template_id,
        wkitem.work_item_template_id,
        wkitem.status_code,
	strat.status_code,   -- Added for bug#7416344 by PNAVEENK on 2-4-2009
    --    wkitem.creation_date start_time,
        wkitem.execute_start start_time,  -- Added for bug#8306620 by PNAVEENK on 3-4-2009
	wkitem.execute_end end_time, -- snuthala 28/08/2008 bug #6745580
        wkitem.work_item_order wkitem_order,
	wkitem.escalated_yn                   --Added for bug#6981126 by schekuri on 27-Jul-2008
      from iex_strategies strat,
        iex_strategy_work_items wkitem,
        iex_stry_temp_work_items_b stry_temp_wkitem,
        iex_pop_uwq_summ_gt temp
      where strat.jtf_object_type = temp.object_type
      AND strat.status_code IN('OPEN',   'ONHOLD')
      AND wkitem.strategy_id = strat.strategy_id
      AND wkitem.status_code IN('OPEN',   'ONHOLD')
      AND wkitem.work_item_template_id = stry_temp_wkitem.work_item_temp_id
      AND strat.jtf_object_id = temp.object_id;

       -- Start for the bug#7562130 by PNAVEENK
      CURSOR C_COLLECTOR_PROF IS
      SELECT
         hp.collector_id,
         ac.resource_id,
	 decode(ac.resource_type, 'RS_RESOURCE' , rs.source_name , rg.group_name)   collector_resource_name,
	 ac.resource_type,
	 hp.party_id,
	 hp.cust_account_id,
	 hp.site_use_id
      FROM
         hz_customer_profiles hp,
	 ar_collectors ac,
	 iex_pop_uwq_summ_gt temp,
	 jtf_rs_resource_extns rs,
         JTF_RS_GROUPS_VL rg
      WHERE
         hp.site_use_id=temp.object_id
	 and hp.collector_id=ac.collector_id
	 and rs.resource_id(+) = ac.resource_id
         and rg.group_id (+) = ac.resource_id;
       -- end for the bug#7562130
      CURSOR C_CONTACT_POINT IS
      SELECT
         ids.party_id             party_id,
         phone.phone_country_code phone_country_code,
         phone.phone_area_code    phone_area_code,
         phone.phone_number       phone_number,
         phone.phone_extension    phone_extension
      FROM
         hz_contact_points phone,
	 iex_dln_uwq_summary ids,
         iex_pop_uwq_summ_gt temp
      WHERE
       phone.owner_table_id = ids.party_id
       AND phone.owner_table_name = 'HZ_PARTIES'
       AND phone.contact_point_type = 'PHONE'
       and phone.primary_by_purpose = 'Y'
       AND phone.contact_point_purpose = 'COLLECTIONS'
       AND phone.phone_line_type NOT IN('PAGER',     'FAX')
       AND phone.status = 'A'
       AND nvl(phone.do_not_use_flag, 'N') = 'N'
       AND ids.site_use_id = temp.object_id;

    L_ORG_ID                                    number_list;
    L_COLLECTOR_ID                              number_list;
    L_COLLECTOR_RESOURCE_ID                     number_list;
    L_COLLECTOR_RES_TYPE                        varchar_30_list;
    L_IEU_OBJECT_FUNCTION                       varchar_30_list;
    L_IEU_OBJECT_PARAMETERS                     varchar_2020_list;
    L_IEU_MEDIA_TYPE_UUID                       varchar_10_list;
    L_IEU_PARAM_PK_COL                          varchar_40_list;
    L_IEU_PARAM_PK_VALUE                        varchar_40_list;
    L_RESOURCE_ID                               number_list;
    L_RESOURCE_TYPE                             varchar_20_list;
    L_PARTY_ID                                  number_list;
    L_PARTY_NAME                                varchar_360_list;
    L_CUST_ACCOUNT_ID                           number_list;
    L_ACCOUNT_NAME                              varchar_240_list;
    L_ACCOUNT_NUMBER                            varchar_30_list;
    L_SITE_USE_ID                               number_list;
    L_LOCATION                                  varchar_60_list;
    L_CURRENCY                                  varchar_20_list;
    L_OP_INVOICES_COUNT                         number_list;
    L_OP_DEBIT_MEMOS_COUNT                      number_list;
    L_OP_DEPOSITS_COUNT                         number_list;
    L_OP_BILLS_RECEIVABLES_COUNT                number_list;
    L_OP_CHARGEBACK_COUNT                       number_list;
    L_OP_CREDIT_MEMOS_COUNT                     number_list;
    L_UNRESOLVED_CASH_COUNT                     number_list;
    L_DISPUTED_INV_COUNT                        number_list;
    L_BEST_CURRENT_RECEIVABLES                  number_list;
    L_OP_INVOICES_VALUE                         number_list;
    L_OP_DEBIT_MEMOS_VALUE                      number_list;
    L_OP_DEPOSITS_VALUE                         number_list;
    L_OP_BILLS_RECEIVABLES_VALUE                number_list;
    L_OP_CHARGEBACK_VALUE                       number_list;
    L_OP_CREDIT_MEMOS_VALUE                     number_list;
    L_UNRESOLVED_CASH_VALUE                     number_list;
    L_RECEIPTS_AT_RISK_VALUE                    number_list;
    L_INV_AMT_IN_DISPUTE                        number_list;
    L_PENDING_ADJ_VALUE                         number_list;
    L_PAST_DUE_INV_VALUE                        number_list;
    L_PAST_DUE_INV_INST_COUNT                   number_list;
    L_LAST_PAYMENT_DATE                         date_list;
    L_LAST_PAYMENT_AMOUNT                       number_list;
    L_LAST_PAYMENT_AMOUNT_CURR                  varchar_20_list;
    L_LAST_PAYMENT_NUMBER                       varchar_30_list;
    L_LAST_UPDATE_DATE                          date_list;
    L_LAST_UPDATED_BY                           number_list;
    L_CREATION_DATE                             date_list;
    L_CREATED_BY                                number_list;
    L_LAST_UPDATE_LOGIN                         number_list;
    L_NUMBER_OF_DELINQUENCIES                   number_list;
    L_ACTIVE_DELINQUENCIES                      number_list;
    L_COMPLETE_DELINQUENCIES                    number_list;
    L_PENDING_DELINQUENCIES                     number_list;
    L_SCORE                                     number_list;
     -- Start for the bug#7562130 by PNAVEENK
    L_SCORE_ID                                  number_list;
    L_SCORE_NAME                                varchar_240_list;
    L_COLLECTOR_RESOURCE_NAME                   varchar_240_list;
    -- End for the bug#7562130
    L_ADDRESS1                                  varchar_240_list;
    L_CITY                                      varchar_60_list;
    L_STATE                                     varchar_60_list;
    L_COUNTY                                    varchar_60_list;
    L_COUNTRY                                   varchar_80_list;
    L_PROVINCE                                  varchar_60_list;
    L_POSTAL_CODE                               varchar_60_list;
    L_PHONE_COUNTRY_CODE                        varchar_10_list;
    L_PHONE_AREA_CODE                           varchar_10_list;
    L_PHONE_NUMBER                              varchar_40_list;
    L_PHONE_EXTENSION                           varchar_20_list;
    L_NUMBER_OF_BANKRUPTCIES                    number_list;
    L_NUMBER_OF_PROMISES                        number_list;
    L_BROKEN_PROMISE_AMOUNT                     number_list;
    L_PROMISE_AMOUNT                            number_list;
    L_ACTIVE_PROMISES                           number_list;
    L_COMPLETE_PROMISES                         number_list;
    L_PENDING_PROMISES                          number_list;
    L_WORK_ITEM_ID                              number_list;
    L_SCHEDULE_START                            date_list;
    L_SCHEDULE_END                              date_list;
    L_WORK_TYPE                                 varchar_30_list;
    L_CATEGORY_TYPE                             varchar_30_list;
    L_PRIORITY_TYPE                             varchar_30_list;
    L_JTF_OBJECT_ID                             number_list;
    l_wkitem_resource_id			number_list;
    l_strategy_id				number_list;
    l_strategy_template_id 			number_list;
    l_work_item_template_id 			number_list;
    l_status_code 				varchar_30_list;
    l_str_status                                varchar_30_list;   -- Added for bug#7416344 by PNAVEENK on 2-4-2009
    l_start_time 				date_list;
    l_end_time 					date_list;
    l_work_item_order 				number_list;
    l_escalated_yn                              varchar_10_list;  --Added for bug#6981126 by schekuri on 27-Jun-2008

    l_max_fetches                               NUMBER;
    l_total                                     NUMBER;

    cursor c_billto_del is
    select del.CUSTOMER_SITE_USE_ID,
    count(1) number_of_delinquencies,
    max(decode(uwq_status,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_delinquencies,
    max(decode(uwq_status,'COMPLETE',(decode(sign(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_delinquencies,
    max(decode(uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_delinquencies
    from iex_delinquencies_all del,
    iex_pop_uwq_summ_gt temp
    WHERE del.customer_site_use_id = temp.object_id  AND
    del.org_id = temp.org_id and
    del.status IN('DELINQUENT',    'PREDELINQUENT')
    group by del.CUSTOMER_SITE_USE_ID;

    cursor c_billto_pro is
    select del.CUSTOMER_SITE_USE_ID,
    max(decode(pd.uwq_status,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_promises,
    max(decode(pd.uwq_status,'COMPLETE',(decode(sign(TRUNC(pd.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_promises,
    max(decode(pd.uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_promises
    from iex_promise_details pd,
    IEX_DELINQUENCIES_ALL DEL,
    iex_pop_uwq_summ_gt temp
    WHERE pd.cust_account_id = del.cust_account_id
      and pd.delinquency_id = del.delinquency_id
      and del.customer_site_use_id = temp.object_id
      and del.org_id = temp.org_id
      and pd.state = 'BROKEN_PROMISE'
     group by del.CUSTOMER_SITE_USE_ID;

    cursor c_billto_pro_summ is
    SELECT del.customer_site_use_id,
    COUNT(1) number_of_promises,
    SUM(amount_due_remaining) broken_promise_amount,
    SUM(promise_amount) promise_amount
    FROM iex_promise_details pd,
         iex_delinquencies_all del,
         iex_pop_uwq_summ_gt temp
   WHERE pd.cust_account_id = del.cust_account_id
     AND pd.delinquency_id = del.delinquency_id
     AND pd.status IN('COLLECTABLE',   'PENDING')
     AND pd.state = 'BROKEN_PROMISE'
     AND pd.amount_due_remaining > 0
     AND (del.status NOT IN('CURRENT',   'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 06-Jan-2009 barathsr
     and del.customer_site_use_id = temp.object_id
     and del.org_id = temp.org_id
   GROUP BY del.customer_site_use_id;
   -- Start for the bug#7562130 by PNAVEENK
   cursor c_billto_score is
   SELECT sh.score_object_id, sh.score_value score , sh.score_id, sc.score_name
     FROM iex_score_histories sh,
          iex_pop_uwq_summ_gt temp,
	   iex_scores sc
    WHERE sh.creation_date = (SELECT MAX(creation_date)
                               FROM iex_score_histories sh1
                              WHERE sh1.score_object_code = 'IEX_BILLTO'
                                AND sh1.score_object_id = sh.score_object_id)
     -- AND rownum < 2
      AND sh.score_object_code = 'IEX_BILLTO'
      AND sh.score_object_id = temp.object_id
      and sc.score_id = sh.score_id;
   -- end for the bug#7562130

   cursor c_billto_past_due is
   SELECT a.customer_site_use_id,
   SUM(b.acctd_amount_due_remaining) past_due_inv_value
   FROM iex_delinquencies_all a,
        ar_payment_schedules_all b,
        iex_pop_uwq_summ_gt temp
  WHERE a.customer_site_use_id = temp.object_id
    AND a.payment_schedule_id = b.payment_schedule_id
    AND b.status = 'OP'
    AND a.status IN('DELINQUENT',   'PREDELINQUENT')
    AND temp.org_id = a.org_id
   GROUP BY a.customer_site_use_id;

   cursor c_last_payment_no_amount is
   SELECT o_summ.site_use_id,
          o_summ.last_payment_number last_payment_number,
	  iex_uwq_view_pkg.convert_amount(o_summ.last_payment_amount,o_summ.currency) last_payment_amount
   FROM ar_trx_bal_summary o_summ
   WHERE o_summ.site_use_id in (select object_id from iex_pop_uwq_summ_gt)
   AND o_summ.last_payment_date =  (SELECT MAX(last_payment_date)
                                    FROM ar_trx_bal_summary
                                    WHERE site_use_id = o_summ.site_use_id);

   cursor c_bankruptcies is
   select sua.site_use_id,
          COUNT(1) number_of_bankruptcies
   FROM iex_bankruptcies bkr,hz_cust_accounts ca,
        hz_cust_acct_sites_all cas,--Modified for Bug 9487600 23-Mar-2010 barathsr
	hz_cust_site_uses_all sua
   where sua.site_use_id in (select object_id from iex_pop_uwq_summ_gt)
         and bkr.party_id=ca.party_id
         and ca.cust_account_id=cas.cust_account_id
         and cas.cust_acct_site_id=sua.cust_acct_site_id
	 and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')  -- Changed for bug#7693986
   group by sua.site_use_id;

   -- Bug #6251657 bibeura 25-OCT-2007
   cursor c_billto_del_dln is
    select del.customer_site_use_id,
    sum(decode(del.status,'DELINQUENT',1,'PREDELINQUENT',1,0)) number_of_delinquencies,
    sum(decode(del.status,'DELINQUENT',ps.acctd_amount_due_remaining,'PREDELINQUENT',ps.acctd_amount_due_remaining,0)) past_due_inv_value,
    max(decode(uwq_status,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_delinquencies,
    max(decode(uwq_status,'COMPLETE',(decode(sign(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_delinquencies,
    max(decode(uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_delinquencies,
    del.org_id org_id
    from iex_delinquencies del,
    ar_payment_schedules ps
    WHERE del.payment_schedule_id = ps.payment_schedule_id  AND
    del.org_id = ps.org_id and
    exists(select 1 from iex_delinquencies del1
	    where del1.last_update_date>=trunc(sysdate)
	      and del.customer_site_use_id=del1.customer_site_use_id
	      and del.org_id=del1.org_id)
    group by del.customer_site_use_id, del.org_id;

BEGIN

	l_max_fetches := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '100000'));
	if p_mode='DLN' then
	        LogMessage(FND_LOG.LEVEL_STATEMENT,'Starting..');
		-- Start Bug #6251657 bibeura 25-OCT-2007
		BEGIN
		        OPEN C_BILLTO_DEL_DLN;
		        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_del_dln cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
	                L_SITE_USE_ID.delete;
	        	L_NUMBER_OF_DELINQUENCIES.delete;
	                L_PENDING_DELINQUENCIES.delete;
	        	L_COMPLETE_DELINQUENCIES.delete;
	                L_ACTIVE_DELINQUENCIES.delete;
			L_PAST_DUE_INV_VALUE.delete;
			L_ORG_ID.delete;

  	            LOOP
	                FETCH C_BILLTO_DEL_DLN bulk collect
	                INTO
	                L_SITE_USE_ID,
	                L_NUMBER_OF_DELINQUENCIES,
			L_PAST_DUE_INV_VALUE,
            	        L_PENDING_DELINQUENCIES,
	                L_COMPLETE_DELINQUENCIES,
                        L_ACTIVE_DELINQUENCIES,
			L_ORG_ID
                        limit l_max_fetches;
			FND_FILE.PUT_LINE(FND_FILE.LOG, 'fetched records '||L_SITE_USE_ID.COUNT) ;
			IF L_SITE_USE_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_del_dln ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
	                        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		                EXIT;
			ELSE

	                   forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
		             UPDATE IEX_DLN_UWQ_SUMMARY
			     SET NUMBER_OF_DELINQUENCIES = L_NUMBER_OF_DELINQUENCIES(i),
			         PAST_DUE_INV_VALUE = L_PAST_DUE_INV_VALUE(i),
	       			 ACTIVE_DELINQUENCIES    = L_ACTIVE_DELINQUENCIES(i),
				 COMPLETE_DELINQUENCIES  = L_COMPLETE_DELINQUENCIES(i),
				 PENDING_DELINQUENCIES   = L_PENDING_DELINQUENCIES(i)
			     WHERE
			     SITE_USE_ID = L_SITE_USE_ID(i)
			     AND ORG_ID=L_ORG_ID(i);
		             LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_del_dln updated ' || L_COLLECTOR_ID.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
	               END IF;
	            END LOOP;
	           IF C_BILLTO_DEL_DLN % ISOPEN THEN
		       CLOSE C_BILLTO_DEL_DLN;
                   END IF;

	        EXCEPTION WHEN OTHERS THEN
	         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
	        END;
                -- End Bug #6251657 bibeura 25-OCT-2007

		--Begin Bug 8707923 27-Jul-2009 barathsr

		 FND_FILE.PUT_LINE(FND_FILE.LOG, 'delete frm GT table at billto level');

		delete from iex_pop_uwq_summ_gt;

		 FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert into bill_to gt');
		insert into iex_pop_uwq_summ_gt(object_id,object_type,org_id)
		select del.customer_site_use_id,'IEX_BILLTO',del.org_id from iex_delinquencies del,hz_party_preferences party_pref
		where del.status in ('DELINQUENT','PRE-DELINQUENT')
		             and del.party_cust_id=party_pref.party_id(+)
                             and party_pref.module(+)='COLLECTIONS'
                             and party_pref.category(+)='COLLECTIONS LEVEL'
			     and party_pref.preference_code(+)='PARTY_ID'
			     and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),G_SYSTEM_LEVEL)='BILL_TO'
		and not exists(select 1 from IEX_DLN_UWQ_SUMMARY dus where
		              dus.site_use_id=del.customer_site_use_id
			     and dus.org_id=del.org_id)
		group by customer_site_use_id,del.org_id;
		if sql%rowcount<=0 then
			return;
	        else
		     FND_FILE.PUT_LINE(FND_FILE.LOG,'Inserted into bill_to gt-->'||sql%rowcount);
		end if;
	else
		NULL;
	end if;

	delete from iex_dln_uwq_summary summ
	where exists(select 1
		     from iex_pop_uwq_summ_gt gt,hz_cust_site_uses_all hcsua,hz_cust_acct_sites_all hcasa,hz_cust_accounts hca
		     where gt.object_id=hcsua.site_use_id
		     and hcsua.cust_acct_site_id=hcasa.cust_acct_site_id
		     and hcasa.cust_account_id=hca.cust_account_id
		     and hca.party_id=summ.party_id
		     and gt.org_id=summ.org_id)
	and summ.business_level<>'BILL_TO';

        LogMessage(FND_LOG.LEVEL_STATEMENT,'No. of records deleted at BILL_TO level->' || sql%rowcount);
	commit;

      --End Bug 8707923 27-Jul-2009 barathsr
         open c_iex_billto_uwq_summary;
         loop
	 l_count := l_count +1;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'----------');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bulk ' || l_count);

        L_ORG_ID.delete;
        L_COLLECTOR_ID.delete;
        L_COLLECTOR_RESOURCE_ID.delete;
        L_COLLECTOR_RES_TYPE.delete;
        L_IEU_OBJECT_FUNCTION.delete;
        L_IEU_OBJECT_PARAMETERS.delete;
        L_IEU_MEDIA_TYPE_UUID.delete;
        L_IEU_PARAM_PK_COL.delete;
        L_IEU_PARAM_PK_VALUE.delete;
        L_RESOURCE_ID.delete;
        L_RESOURCE_TYPE.delete;
        L_PARTY_ID.delete;
        L_PARTY_NAME.delete;
        L_CUST_ACCOUNT_ID.delete;
        L_ACCOUNT_NAME.delete;
        L_ACCOUNT_NUMBER.delete;
        L_SITE_USE_ID.delete;
        L_LOCATION.delete;
        L_CURRENCY.delete;
        L_OP_INVOICES_COUNT.delete;
        L_OP_DEBIT_MEMOS_COUNT.delete;
        L_OP_DEPOSITS_COUNT.delete;
        L_OP_BILLS_RECEIVABLES_COUNT.delete;
        L_OP_CHARGEBACK_COUNT.delete;
        L_OP_CREDIT_MEMOS_COUNT.delete;
        L_UNRESOLVED_CASH_COUNT.delete;
        L_DISPUTED_INV_COUNT.delete;
        L_BEST_CURRENT_RECEIVABLES.delete;
        L_OP_INVOICES_VALUE.delete;
        L_OP_DEBIT_MEMOS_VALUE.delete;
        L_OP_DEPOSITS_VALUE.delete;
        L_OP_BILLS_RECEIVABLES_VALUE.delete;
        L_OP_CHARGEBACK_VALUE.delete;
        L_OP_CREDIT_MEMOS_VALUE.delete;
        L_UNRESOLVED_CASH_VALUE.delete;
        L_RECEIPTS_AT_RISK_VALUE.delete;
        L_INV_AMT_IN_DISPUTE.delete;
        L_PENDING_ADJ_VALUE.delete;
        L_PAST_DUE_INV_VALUE.delete;
        L_PAST_DUE_INV_INST_COUNT.delete;
        L_LAST_PAYMENT_DATE.delete;
        L_LAST_PAYMENT_AMOUNT.delete;
        L_LAST_PAYMENT_AMOUNT_CURR.delete;
        L_LAST_PAYMENT_NUMBER.delete;
        L_LAST_UPDATE_DATE.delete;
        L_LAST_UPDATED_BY.delete;
        L_CREATION_DATE.delete;
        L_CREATED_BY.delete;
        L_LAST_UPDATE_LOGIN.delete;
        L_NUMBER_OF_DELINQUENCIES.delete;
        L_ACTIVE_DELINQUENCIES.delete;
        L_COMPLETE_DELINQUENCIES.delete;
        L_PENDING_DELINQUENCIES.delete;
        L_SCORE.delete;
	-- Start for the bug#7562130 by PNAVEENK
        L_SCORE_ID.delete;
        L_SCORE_NAME.delete;
        L_COLLECTOR_RESOURCE_NAME.delete;
        -- end for the bug#7562130
        L_ADDRESS1.delete;
        L_CITY.delete;
        L_STATE.delete;
        L_COUNTY.delete;
        L_COUNTRY.delete;
        L_PROVINCE.delete;
        L_POSTAL_CODE.delete;
        L_PHONE_COUNTRY_CODE.delete;
        L_PHONE_AREA_CODE.delete;
        L_PHONE_NUMBER.delete;
        L_PHONE_EXTENSION.delete;
        L_NUMBER_OF_BANKRUPTCIES.delete;
        L_NUMBER_OF_PROMISES.delete;
        L_BROKEN_PROMISE_AMOUNT.delete;
        L_PROMISE_AMOUNT.delete;
        L_ACTIVE_PROMISES.delete;
        L_COMPLETE_PROMISES.delete;
        L_PENDING_PROMISES.delete;
         LogMessage(FND_LOG.LEVEL_STATEMENT,'Start fetching records...');
	 FETCH c_iex_billto_uwq_summary bulk collect
                INTO
                    L_ORG_ID,
                    L_IEU_OBJECT_FUNCTION,
                    L_IEU_OBJECT_PARAMETERS,
                    L_IEU_MEDIA_TYPE_UUID,
                    L_IEU_PARAM_PK_COL,
                    L_IEU_PARAM_PK_VALUE,
                    L_RESOURCE_ID,
                    L_RESOURCE_TYPE,
                    L_PARTY_ID,
                    L_PARTY_NAME,
                    L_CUST_ACCOUNT_ID,
                    L_ACCOUNT_NAME,
                    L_ACCOUNT_NUMBER,
                    L_SITE_USE_ID,
                    L_LOCATION,
                    L_CURRENCY,
                    L_OP_INVOICES_COUNT,
                    L_OP_DEBIT_MEMOS_COUNT,
                    L_OP_DEPOSITS_COUNT,
                    L_OP_BILLS_RECEIVABLES_COUNT,
                    L_OP_CHARGEBACK_COUNT,
                    L_OP_CREDIT_MEMOS_COUNT,
                    L_UNRESOLVED_CASH_COUNT,
                    L_DISPUTED_INV_COUNT,
                    L_BEST_CURRENT_RECEIVABLES,
                    L_OP_INVOICES_VALUE,
                    L_OP_DEBIT_MEMOS_VALUE,
                    L_OP_DEPOSITS_VALUE,
                    L_OP_BILLS_RECEIVABLES_VALUE,
                    L_OP_CHARGEBACK_VALUE,
                    L_OP_CREDIT_MEMOS_VALUE,
                    L_UNRESOLVED_CASH_VALUE,
                    L_RECEIPTS_AT_RISK_VALUE,
                    L_INV_AMT_IN_DISPUTE,
                    L_PENDING_ADJ_VALUE,
                    L_PAST_DUE_INV_INST_COUNT,
                    L_LAST_PAYMENT_DATE,
                    L_LAST_PAYMENT_AMOUNT_CURR,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_LOGIN,
                    L_ADDRESS1,
                    L_CITY,
                    L_STATE,
                    L_COUNTY,
                    L_COUNTRY,
                    L_PROVINCE,
                    L_POSTAL_CODE
                limit l_max_fetches;

		IF L_IEU_OBJECT_FUNCTION.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

        ELSE

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Fetched  ' || L_IEU_OBJECT_FUNCTION.COUNT || ' rows.');
          LogMessage(FND_LOG.LEVEL_STATEMENT,'Inserting...');
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start inserting time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_STATEMENT,'inserting records..');
          forall i IN L_IEU_OBJECT_FUNCTION.FIRST .. L_IEU_OBJECT_FUNCTION.LAST
            INSERT INTO IEX_DLN_UWQ_SUMMARY
                (DLN_UWQ_SUMMARY_ID
                ,ORG_ID
                ,IEU_OBJECT_FUNCTION
                ,IEU_OBJECT_PARAMETERS
                ,IEU_MEDIA_TYPE_UUID
                ,IEU_PARAM_PK_COL
                ,IEU_PARAM_PK_VALUE
                ,RESOURCE_ID
                ,RESOURCE_TYPE
                ,PARTY_ID
                ,PARTY_NAME
                ,CUST_ACCOUNT_ID
                ,ACCOUNT_NAME
                ,ACCOUNT_NUMBER
                ,SITE_USE_ID
                ,LOCATION
                ,CURRENCY
                ,OP_INVOICES_COUNT
                ,OP_DEBIT_MEMOS_COUNT
                ,OP_DEPOSITS_COUNT
                ,OP_BILLS_RECEIVABLES_COUNT
                ,OP_CHARGEBACK_COUNT
                ,OP_CREDIT_MEMOS_COUNT
                ,UNRESOLVED_CASH_COUNT
                ,DISPUTED_INV_COUNT
                ,BEST_CURRENT_RECEIVABLES
                ,OP_INVOICES_VALUE
                ,OP_DEBIT_MEMOS_VALUE
                ,OP_DEPOSITS_VALUE
                ,OP_BILLS_RECEIVABLES_VALUE
                ,OP_CHARGEBACK_VALUE
                ,OP_CREDIT_MEMOS_VALUE
                ,UNRESOLVED_CASH_VALUE
                ,RECEIPTS_AT_RISK_VALUE
                ,INV_AMT_IN_DISPUTE
                ,PENDING_ADJ_VALUE
                ,PAST_DUE_INV_INST_COUNT
                ,LAST_PAYMENT_DATE
                ,LAST_PAYMENT_AMOUNT_CURR
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_LOGIN
                ,ADDRESS1
                ,CITY
                ,STATE
                ,COUNTY
                ,COUNTRY
                ,PROVINCE
                ,POSTAL_CODE
		,NUMBER_OF_DELINQUENCIES
		,NUMBER_OF_PROMISES
		,NUMBER_OF_BANKRUPTCIES
		,BUSINESS_LEVEL)  --Added for Bug 8707923 27-Jul-2009 barathsr
            VALUES
                (IEX_DLN_UWQ_SUMMARY_S.nextval,
                L_ORG_ID(i),
                L_IEU_OBJECT_FUNCTION(i),
                L_IEU_OBJECT_PARAMETERS(i),
                L_IEU_MEDIA_TYPE_UUID(i),
                L_IEU_PARAM_PK_COL(i),
                L_IEU_PARAM_PK_VALUE(i),
                L_RESOURCE_ID(i),
                L_RESOURCE_TYPE(i),
                L_PARTY_ID(i),
                L_PARTY_NAME(i),
                L_CUST_ACCOUNT_ID(i),
                L_ACCOUNT_NAME(i),
                L_ACCOUNT_NUMBER(i),
                L_SITE_USE_ID(i),
                L_LOCATION(i),
                L_CURRENCY(i),
                L_OP_INVOICES_COUNT(i),
                L_OP_DEBIT_MEMOS_COUNT(i),
                L_OP_DEPOSITS_COUNT(i),
                L_OP_BILLS_RECEIVABLES_COUNT(i),
                L_OP_CHARGEBACK_COUNT(i),
                L_OP_CREDIT_MEMOS_COUNT(i),
                L_UNRESOLVED_CASH_COUNT(i),
                L_DISPUTED_INV_COUNT(i),
                L_BEST_CURRENT_RECEIVABLES(i),
                L_OP_INVOICES_VALUE(i),
                L_OP_DEBIT_MEMOS_VALUE(i),
                L_OP_DEPOSITS_VALUE(i),
                L_OP_BILLS_RECEIVABLES_VALUE(i),
                L_OP_CHARGEBACK_VALUE(i),
                L_OP_CREDIT_MEMOS_VALUE(i),
                L_UNRESOLVED_CASH_VALUE(i),
                L_RECEIPTS_AT_RISK_VALUE(i),
                L_INV_AMT_IN_DISPUTE(i),
                L_PENDING_ADJ_VALUE(i),
                L_PAST_DUE_INV_INST_COUNT(i),
                L_LAST_PAYMENT_DATE(i),
                L_LAST_PAYMENT_AMOUNT_CURR(i),
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.CONC_LOGIN_ID,
                L_ADDRESS1(i),
                L_CITY(i),
                L_STATE(i),
                L_COUNTY(i),
                L_COUNTRY(i),
                L_PROVINCE(i),
                L_POSTAL_CODE(i),
		0,
		0,
		0,
		'BILL_TO');--Added for Bug 8707923 27-Jul-2009 barathsr

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End inserting time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Inserted ' || L_IEU_OBJECT_FUNCTION.COUNT || ' rows for business lvl-->'||p_level);

          l_total := l_total + L_IEU_OBJECT_FUNCTION.COUNT;
          LogMessage(FND_LOG.LEVEL_STATEMENT,'So far processed ' || l_total || ' rows');


        END IF;

      END LOOP;
      close c_iex_billto_uwq_summary;

      OPEN c_strategy_summary;
      LOOP
          l_count := l_count +1;
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'----------');
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bulk ' || l_count);

          L_JTF_OBJECT_ID.delete;
          L_WORK_ITEM_ID.delete;
          L_SCHEDULE_START.delete;
          L_SCHEDULE_END.delete;
          L_WORK_TYPE.delete;
          L_CATEGORY_TYPE.delete;
          L_PRIORITY_TYPE.delete;
	  L_wkitem_RESOURCE_ID.delete;
          L_STRATEGY_ID.delete;
	  L_STRATEGY_TEMPLATE_ID.delete;
	  L_WORK_ITEM_TEMPLATE_ID.delete;
	  L_STATUS_CODE.delete;
	  L_STR_STATUS.delete;   -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	  L_START_TIME.delete;
	  L_END_TIME.delete;
	  L_WORK_ITEM_ORDER.delete;
	  L_ESCALATED_YN.delete;   --Added for bug#6981126 by schekuri on 27-Jun-2008

          LogMessage(FND_LOG.LEVEL_STATEMENT,'Inited all arrays');

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          FETCH c_strategy_summary bulk collect
          INTO
            L_JTF_OBJECT_ID,
            L_WORK_ITEM_ID,
            L_SCHEDULE_START,
            L_SCHEDULE_END,
            L_CATEGORY_TYPE,
	    L_WORK_TYPE,
            L_PRIORITY_TYPE,
	    L_WKITEM_RESOURCE_ID,
	    L_STRATEGY_ID,
	    L_STRATEGY_TEMPLATE_ID,
	    L_WORK_ITEM_TEMPLATE_ID,
	    L_STATUS_CODE,
	    L_STR_STATUS,   -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	    L_START_TIME,
	    L_END_TIME,
	    L_WORK_ITEM_ORDER,
	    L_ESCALATED_YN  --Added for bug#6981126 by schekuri on 27-Jun-2008
          limit l_max_fetches;

	  LogMessage(FND_LOG.LEVEL_STATEMENT,L_JTF_OBJECT_ID.COUNT);

          IF L_JTF_OBJECT_ID.COUNT = 0 THEN

            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
            CLOSE c_strategy_summary;
            EXIT;

          ELSE

            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Fetched  ' || L_JTF_OBJECT_ID.COUNT || ' rows.');
            LogMessage(FND_LOG.LEVEL_STATEMENT,' Updating table...');
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start updating time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

               forall i IN L_JTF_OBJECT_ID.FIRST .. L_JTF_OBJECT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                   SET WORK_ITEM_ID = L_WORK_ITEM_ID(i),
                    SCHEDULE_START = L_SCHEDULE_START(i),
                    SCHEDULE_END = L_SCHEDULE_END(i),
                    WORK_TYPE = L_WORK_TYPE(i),
                    CATEGORY_TYPE = L_CATEGORY_TYPE(i),
                    PRIORITY_TYPE = L_PRIORITY_TYPE(i),
		    WKITEM_RESOURCE_ID = L_WKITEM_RESOURCE_ID(i),
  	    	    STRATEGY_ID = L_STRATEGY_ID(i),
	    	    STRATEGY_TEMPLATE_ID = L_STRATEGY_TEMPLATE_ID(i),
		    WORK_ITEM_TEMPLATE_ID = L_WORK_ITEM_TEMPLATE_ID(i),
	            STATUS_CODE = L_STATUS_CODE(i),
		    STR_STATUS = L_STR_STATUS(i),  -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	            START_TIME = L_START_TIME(i),
	            END_TIME = L_END_TIME(i),
	            WORK_ITEM_ORDER = L_WORK_ITEM_ORDER(i),
		    WKITEM_ESCALATED_YN = L_ESCALATED_YN(i)--Added for bug#6981126 by schekuri on 27-Jun-2008
                 WHERE SITE_USE_ID = L_JTF_OBJECT_ID(i);


            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Updated ' || L_JTF_OBJECT_ID.COUNT || ' rows');
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End updating time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

            l_total := l_total + L_JTF_OBJECT_ID.COUNT;
            LogMessage(FND_LOG.LEVEL_STATEMENT,'So far processed ' || l_total || ' rows');

          END IF;

      END LOOP;

      IF c_strategy_summary % ISOPEN THEN
        CLOSE c_strategy_summary;
      END IF;

      BEGIN
      OPEN C_COLLECTOR_PROF;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open C_COLLECTOR_PROF cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_COLLECTOR_RESOURCE_ID.delete  ;
	L_COLLECTOR_RESOURCE_NAME.delete;  -- Added for the bug#7562130
	L_COLLECTOR_ID.delete;
	L_RESOURCE_TYPE.delete;
	L_PARTY_ID.delete;
	L_CUST_ACCOUNT_ID.delete;
	L_SITE_USE_ID.delete;

      LOOP
        FETCH C_COLLECTOR_PROF bulk collect
          INTO
	    L_COLLECTOR_ID,
  	    L_COLLECTOR_RESOURCE_ID,
	    L_COLLECTOR_RESOURCE_NAME,  -- Added for the bug#7562130
	    L_RESOURCE_TYPE,
	    L_PARTY_ID,
            L_CUST_ACCOUNT_ID,
	    L_SITE_USE_ID
          limit l_max_fetches;
      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: C_COLLECTOR_PROF ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
		        COLLECTOR_RESOURCE_NAME = L_COLLECTOR_RESOURCE_NAME(i), -- Added for the bug#7562130
		        COLLECTOR_RES_TYPE    = L_RESOURCE_TYPE(i),
			collector_id = l_collector_id(i),
			last_update_date   = SYSDATE,
		        last_updated_by    = FND_GLOBAL.USER_ID
                   WHERE
		    SITE_USE_ID = L_SITE_USE_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' C_COLLECTOR_PROF updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_COLLECTOR_PROF % ISOPEN THEN
        CLOSE C_COLLECTOR_PROF;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'C_COLLECTOR_PROF update received' || SQLERRM);
       END;

     BEGIN
       OPEN c_contact_point;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened Cursor  c_contact_point  cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_PARTY_ID.delete;
        L_PHONE_COUNTRY_CODE.delete;
        L_PHONE_AREA_CODE.delete;
        L_PHONE_NUMBER.delete;
        L_PHONE_EXTENSION.delete;


      LOOP
	 FETCH c_contact_point bulk collect
          INTO
	   L_PARTY_ID,
	   L_PHONE_COUNTRY_CODE,
	   L_PHONE_AREA_CODE,
	   L_PHONE_NUMBER,
	   L_PHONE_EXTENSION

          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'c_contact_point  Cursor Fetching end time:   ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

        ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST

                   UPDATE IEX_DLN_UWQ_SUMMARY
                   SET PHONE_COUNTRY_CODE = L_PHONE_COUNTRY_CODE(i),
		       PHONE_AREA_CODE    = L_PHONE_AREA_CODE(i),
		       PHONE_NUMBER       = L_PHONE_NUMBER(i),
		       PHONE_EXTENSION    = L_PHONE_EXTENSION(i),
		       last_update_date   = SYSDATE,
		       last_updated_by    = FND_GLOBAL.USER_ID
                 WHERE PARTY_ID = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_contact_point Cursor updated ' ||L_PARTY_ID.count || ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
        CLOSE c_contact_point;


      EXCEPTION WHEN OTHERS THEN
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Contact point raised error ' || SQLERRM);
      END;
-- gnramasa
      BEGIN
      OPEN C_BILLTO_DEL;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_del cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_SITE_USE_ID.delete;
	L_NUMBER_OF_DELINQUENCIES.delete;
        L_PENDING_DELINQUENCIES.delete;
	L_COMPLETE_DELINQUENCIES.delete;
        L_ACTIVE_DELINQUENCIES.delete;

      LOOP
        FETCH C_BILLTO_DEL bulk collect
          INTO
	    L_SITE_USE_ID,
  	    L_NUMBER_OF_DELINQUENCIES,
	    L_PENDING_DELINQUENCIES,
	    L_COMPLETE_DELINQUENCIES,
            L_ACTIVE_DELINQUENCIES
          limit l_max_fetches;
      IF L_SITE_USE_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_del ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET NUMBER_OF_DELINQUENCIES = L_NUMBER_OF_DELINQUENCIES(i),
		        ACTIVE_DELINQUENCIES    = L_ACTIVE_DELINQUENCIES(i),
			COMPLETE_DELINQUENCIES  = L_COMPLETE_DELINQUENCIES(i),
			PENDING_DELINQUENCIES   = L_PENDING_DELINQUENCIES(i)
                   WHERE
		    SITE_USE_ID = L_SITE_USE_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_del updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_BILLTO_DEL % ISOPEN THEN
        CLOSE C_BILLTO_DEL;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_BILLTO_PRO;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_pro cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_SITE_USE_ID.delete;
	L_ACTIVE_PROMISES.delete;
        L_COMPLETE_PROMISES.delete;
        L_PENDING_PROMISES.delete;

      LOOP
        FETCH C_BILLTO_PRO bulk collect
          INTO
	    L_SITE_USE_ID,
  	    L_PENDING_PROMISES,
	    L_COMPLETE_PROMISES,
	    L_ACTIVE_PROMISES
          limit l_max_fetches;
      IF L_SITE_USE_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_pro ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET ACTIVE_PROMISES    = L_ACTIVE_PROMISES(i),
			COMPLETE_PROMISES  = L_COMPLETE_PROMISES(i),
			PENDING_PROMISES   = L_PENDING_PROMISES(i)
                   WHERE
		    SITE_USE_ID = L_SITE_USE_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_pro updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_BILLTO_PRO % ISOPEN THEN
        CLOSE C_BILLTO_PRO;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Promise update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_BILLTO_PRO_SUMM;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_pro_summ cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_SITE_USE_ID.delete;
	L_NUMBER_OF_PROMISES.delete;
        L_BROKEN_PROMISE_AMOUNT .delete;
        L_PROMISE_AMOUNT.delete;

      LOOP
        FETCH C_BILLTO_PRO_SUMM bulk collect
          INTO
	    L_SITE_USE_ID,
  	    L_NUMBER_OF_PROMISES,
	    L_BROKEN_PROMISE_AMOUNT,
	    L_PROMISE_AMOUNT
          limit l_max_fetches;
      IF L_SITE_USE_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_pro_summ ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET NUMBER_OF_PROMISES     = L_NUMBER_OF_PROMISES(i),
			BROKEN_PROMISE_AMOUNT  = L_BROKEN_PROMISE_AMOUNT(i),
			PROMISE_AMOUNT         = L_PROMISE_AMOUNT(i)
                   WHERE
		    SITE_USE_ID = L_SITE_USE_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_pro_summ updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_BILLTO_PRO_SUMM % ISOPEN THEN
        CLOSE C_BILLTO_PRO_SUMM;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Broken Promise update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_BILLTO_SCORE;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_score cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_SITE_USE_ID.delete;
	L_SCORE.delete;
	L_SCORE_ID.delete;  -- Added for the bug#7562130
	L_SCORE_NAME.delete; -- Added for the bug#7562130

      LOOP
        FETCH C_BILLTO_SCORE bulk collect
          INTO
	    L_SITE_USE_ID,
  	    L_SCORE,
	    L_SCORE_ID,  -- Added for the bug#7562130
	    L_SCORE_NAME  -- Added for the bug#7562130
          limit l_max_fetches;
      IF L_SITE_USE_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_score ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET SCORE     = L_SCORE(i),
		        SCORE_ID = L_SCORE_ID(i),  -- Added for the bug#7562130
			SCORE_NAME = L_SCORE_NAME(i)  -- Added for the bug#7562130

                   WHERE
		    SITE_USE_ID = L_SITE_USE_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_score updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_BILLTO_SCORE % ISOPEN THEN
        CLOSE C_BILLTO_SCORE;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Score update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_BILLTO_PAST_DUE;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_billto_past_due cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_SITE_USE_ID.delete;
	L_PAST_DUE_INV_VALUE.delete;

      LOOP
        FETCH C_BILLTO_PAST_DUE bulk collect
          INTO
	    L_SITE_USE_ID,
  	    L_PAST_DUE_INV_VALUE
          limit l_max_fetches;
      IF L_SITE_USE_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_billto_past_due ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET PAST_DUE_INV_VALUE     = L_PAST_DUE_INV_VALUE(i)
		    WHERE
		    SITE_USE_ID = L_SITE_USE_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_billto_past_due updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_BILLTO_PAST_DUE % ISOPEN THEN
        CLOSE C_BILLTO_PAST_DUE;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Past due invoice update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_LAST_PAYMENT_NO_AMOUNT;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_last_payment_no_amount cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_SITE_USE_ID.delete;
        L_LAST_PAYMENT_NUMBER.delete;
	L_LAST_PAYMENT_AMOUNT.delete;

      LOOP
        FETCH C_LAST_PAYMENT_NO_AMOUNT bulk collect
          INTO
	    L_SITE_USE_ID,
  	    L_LAST_PAYMENT_NUMBER,
	    L_LAST_PAYMENT_AMOUNT
          limit l_max_fetches;
      IF L_SITE_USE_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_last_payment_no_amount ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET LAST_PAYMENT_NUMBER     = L_LAST_PAYMENT_NUMBER(i),
		        LAST_PAYMENT_AMOUNT     = L_LAST_PAYMENT_AMOUNT(i)
                   WHERE
		    SITE_USE_ID = L_SITE_USE_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_last_payment_no_amount updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_LAST_PAYMENT_NO_AMOUNT % ISOPEN THEN
        CLOSE C_LAST_PAYMENT_NO_AMOUNT;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Last payment no and amount update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_BANKRUPTCIES;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_bankruptcies cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_SITE_USE_ID.delete;
        L_NUMBER_OF_BANKRUPTCIES.delete;

      LOOP
        FETCH C_BANKRUPTCIES bulk collect
          INTO
	    L_SITE_USE_ID,
  	    L_NUMBER_OF_BANKRUPTCIES
          limit l_max_fetches;
      IF L_SITE_USE_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_bankruptcies ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_SITE_USE_ID.FIRST .. L_SITE_USE_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET NUMBER_OF_BANKRUPTCIES     = L_NUMBER_OF_BANKRUPTCIES(i)
                   WHERE
		    SITE_USE_ID = L_SITE_USE_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_bankruptcies updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_BANKRUPTCIES % ISOPEN THEN
        CLOSE C_BANKRUPTCIES;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Last payment no and amount update received' || SQLERRM);
       END;


COMMIT;
LogMessage(FND_LOG.LEVEL_STATEMENT,'Commited');

EXCEPTION
WHEN OTHERS THEN
LogMessage(FND_LOG.LEVEL_STATEMENT,sqlerrm);
END BILLTO_REFRESH_SUMMARY_INCR;

PROCEDURE account_refresh_summary_incr(
                    x_errbuf            OUT nocopy VARCHAR2,
                    x_retcode           OUT nocopy VARCHAR2,
                    FROM_DATE           IN  VARCHAR2,
 	            P_MODE              IN  VARCHAR2 DEFAULT 'CP',
		    p_level in varchar2)--Added for Bug 8707923 27-Jul-2009 barathsr
		    is
l_count number;

CURSOR c_iex_account_uwq_summary IS
    SELECT
    trx_summ.org_id,
    objb.object_function ieu_object_function,
    objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
    '' ieu_media_type_uuid,
    'CUST_ACCOUNT_ID' ieu_param_pk_col,
    to_char(trx_summ.cust_account_id) ieu_param_pk_value,
    1 resource_id,
    'RS_EMPLOYEE' resource_type,
    party.party_id party_id,
    party.party_name party_name,
    trx_summ.cust_account_id cust_account_id,
    acc.account_name account_name,
    acc.account_number account_number,
    to_number(null) site_use_id,
    null location,
    max(gl.CURRENCY_CODE) currency,
    SUM(trx_summ.op_invoices_count) op_invoices_count,
    SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
    SUM(trx_summ.op_deposits_count) op_deposits_count,
    SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
    SUM(trx_summ.op_chargeback_count) op_chargeback_count,
    SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
    SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
    SUM(trx_summ.disputed_inv_count) disputed_inv_count,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.best_current_receivables,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.best_current_receivables))) best_current_receivables,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_invoices_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_invoices_value))) op_invoices_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_debit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_debit_memos_value))) op_debit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_deposits_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_deposits_value))) op_deposits_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_bills_receivables_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_chargeback_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_chargeback_value))) op_chargeback_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.op_credit_memos_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.op_credit_memos_value))) op_credit_memos_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.unresolved_cash_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.unresolved_cash_value))) unresolved_cash_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.receipts_at_risk_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.inv_amt_in_dispute,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
    SUM(decode(trx_summ.currency,   gl.CURRENCY_CODE,   trx_summ.pending_adj_value,
     gl_currency_api.convert_amount_sql(trx_summ.currency,   gl.CURRENCY_CODE,   sysdate,
     iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',   ''),   trx_summ.pending_adj_value))) pending_adj_value,
    SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
    MAX(trx_summ.last_payment_date) last_payment_date,
    max(gl.CURRENCY_CODE) last_payment_amount_curr,
    MAX(trx_summ.last_update_date) last_update_date,
    MAX(trx_summ.last_updated_by) last_updated_by,
    MAX(trx_summ.creation_date) creation_date,
    MAX(trx_summ.created_by) created_by,
    MAX(trx_summ.last_update_login) last_update_login,
    party.address1 address1,
    party.city city,
    party.state state,
    party.county county,
    fnd_terr.territory_short_name country,
    party.province province,
    party.postal_code postal_code
    FROM ar_trx_bal_summary trx_summ,
    hz_cust_accounts acc,
    hz_parties party,
    jtf_objects_b objb,
    fnd_territories_tl fnd_terr,
    GL_SETS_OF_BOOKS gl,
    AR_SYSTEM_PARAMETERS_all sys
    WHERE
     trx_summ.reference_1 = '1'
     AND trx_summ.cust_account_id = acc.cust_account_id
     AND acc.party_id = party.party_id
     AND objb.object_code = 'IEX_ACCOUNT'
     AND objb.object_code <> 'IEX_DELINQUENCY' --Added for Bug 8707923 27-Jul-2009 barathsr
     AND party.country = fnd_terr.territory_code(+)
     AND fnd_terr.LANGUAGE(+) = userenv('LANG')
     and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
     and trx_summ.org_id = sys.org_id
     and trx_summ.cust_account_id in (select temp.object_id from iex_pop_uwq_summ_gt temp where
       temp.org_id=trx_summ.org_id)
    GROUP BY  trx_summ.org_id,
    objb.object_function,
    objb.object_parameters,
    party.party_id,
    party.party_name,
    trx_summ.cust_account_id,
    acc.account_name,
    acc.account_number,
    party.address1,
    party.city,
    party.state,
    party.county,
    fnd_terr.territory_short_name,
    party.province,
    party.postal_code;

     CURSOR c_strategy_summary IS
     select strat.jtf_object_id,
        wkitem.WORK_ITEM_ID,
        wkitem.schedule_start schedule_start,
        wkitem.schedule_end schedule_end,
        stry_temp_wkitem.category_type category,
        stry_temp_wkitem.WORK_TYPE,
        stry_temp_wkitem.PRIORITY_TYPE,
        wkitem.resource_id,
        wkitem.strategy_id,
        strat.strategy_template_id,
        wkitem.work_item_template_id,
        wkitem.status_code,
	strat.status_code,   -- added for bug#7416344 by PNAVEENK on 2-4-2009
     --   wkitem.creation_date start_time,
        wkitem.execute_start start_time,  -- Added for bug#8306620 by PNAVEENk on 3-4-2009
	wkitem.execute_end end_time,-- snuthala 28/08/2008 bug #6745580
        wkitem.work_item_order wkitem_order,
	wkitem.escalated_yn                   --Added for bug#6981126 by schekuri on 27-Jul-2008
      from iex_strategies strat,
        iex_strategy_work_items wkitem,
        iex_stry_temp_work_items_b stry_temp_wkitem,
        iex_pop_uwq_summ_gt temp
      where strat.jtf_object_type = temp.object_type
      AND strat.status_code IN('OPEN',   'ONHOLD')
      AND wkitem.strategy_id = strat.strategy_id
      AND wkitem.status_code IN('OPEN',   'ONHOLD')
      AND wkitem.work_item_template_id = stry_temp_wkitem.work_item_temp_id
      AND strat.jtf_object_id = temp.object_id;

       -- Start for the bug#7562130 by PNAVEENK
      CURSOR C_COLLECTOR_PROF IS
      SELECT
         hp.collector_id,
         ac.resource_id,
         decode(ac.resource_type, 'RS_RESOURCE' , rs.source_name , rg.group_name)   collector_resource_name,
	 ac.resource_type,
	 hp.party_id,
	 hp.cust_account_id
      FROM
         hz_customer_profiles hp,
	 ar_collectors ac,
	 iex_pop_uwq_summ_gt temp,
	 jtf_rs_resource_extns rs,
         JTF_RS_GROUPS_VL rg
      WHERE
         hp.site_use_id is null
	 and hp.cust_account_id=temp.object_id
	 and hp.collector_id=ac.collector_id
	 and rs.resource_id(+) = ac.resource_id
         and rg.group_id (+) = ac.resource_id;
     -- end for the bug#7562130

      CURSOR C_CONTACT_POINT IS
      SELECT
         ids.party_id             party_id,
         phone.phone_country_code phone_country_code,
         phone.phone_area_code    phone_area_code,
         phone.phone_number       phone_number,
         phone.phone_extension    phone_extension
      FROM
         hz_contact_points phone,
	 iex_dln_uwq_summary ids,
         iex_pop_uwq_summ_gt temp
      WHERE
       phone.owner_table_id = ids.party_id
       AND phone.owner_table_name = 'HZ_PARTIES'
       AND phone.contact_point_type = 'PHONE'
       and phone.primary_by_purpose = 'Y'
       AND phone.contact_point_purpose = 'COLLECTIONS'
       AND phone.phone_line_type NOT IN('PAGER',     'FAX')
       AND phone.status = 'A'
       AND nvl(phone.do_not_use_flag, 'N') = 'N'
       AND ids.cust_account_id = temp.object_id;

    L_ORG_ID                                    number_list;
    L_COLLECTOR_ID                              number_list;
    L_COLLECTOR_RESOURCE_ID                     number_list;
    L_COLLECTOR_RES_TYPE                        varchar_30_list;
    L_IEU_OBJECT_FUNCTION                       varchar_30_list;
    L_IEU_OBJECT_PARAMETERS                     varchar_2020_list;
    L_IEU_MEDIA_TYPE_UUID                       varchar_10_list;
    L_IEU_PARAM_PK_COL                          varchar_40_list;
    L_IEU_PARAM_PK_VALUE                        varchar_40_list;
    L_RESOURCE_ID                               number_list;
    L_RESOURCE_TYPE                             varchar_20_list;
    L_PARTY_ID                                  number_list;
    L_PARTY_NAME                                varchar_360_list;
    L_CUST_ACCOUNT_ID                           number_list;
    L_ACCOUNT_NAME                              varchar_240_list;
    L_ACCOUNT_NUMBER                            varchar_30_list;
    L_SITE_USE_ID                               number_list;
    L_LOCATION                                  varchar_60_list;
    L_CURRENCY                                  varchar_20_list;
    L_OP_INVOICES_COUNT                         number_list;
    L_OP_DEBIT_MEMOS_COUNT                      number_list;
    L_OP_DEPOSITS_COUNT                         number_list;
    L_OP_BILLS_RECEIVABLES_COUNT                number_list;
    L_OP_CHARGEBACK_COUNT                       number_list;
    L_OP_CREDIT_MEMOS_COUNT                     number_list;
    L_UNRESOLVED_CASH_COUNT                     number_list;
    L_DISPUTED_INV_COUNT                        number_list;
    L_BEST_CURRENT_RECEIVABLES                  number_list;
    L_OP_INVOICES_VALUE                         number_list;
    L_OP_DEBIT_MEMOS_VALUE                      number_list;
    L_OP_DEPOSITS_VALUE                         number_list;
    L_OP_BILLS_RECEIVABLES_VALUE                number_list;
    L_OP_CHARGEBACK_VALUE                       number_list;
    L_OP_CREDIT_MEMOS_VALUE                     number_list;
    L_UNRESOLVED_CASH_VALUE                     number_list;
    L_RECEIPTS_AT_RISK_VALUE                    number_list;
    L_INV_AMT_IN_DISPUTE                        number_list;
    L_PENDING_ADJ_VALUE                         number_list;
    L_PAST_DUE_INV_VALUE                        number_list;
    L_PAST_DUE_INV_INST_COUNT                   number_list;
    L_LAST_PAYMENT_DATE                         date_list;
    L_LAST_PAYMENT_AMOUNT                       number_list;
    L_LAST_PAYMENT_AMOUNT_CURR                  varchar_20_list;
    L_LAST_PAYMENT_NUMBER                       varchar_30_list;
    L_LAST_UPDATE_DATE                          date_list;
    L_LAST_UPDATED_BY                           number_list;
    L_CREATION_DATE                             date_list;
    L_CREATED_BY                                number_list;
    L_LAST_UPDATE_LOGIN                         number_list;
    L_NUMBER_OF_DELINQUENCIES                   number_list;
    L_ACTIVE_DELINQUENCIES                      number_list;
    L_COMPLETE_DELINQUENCIES                    number_list;
    L_PENDING_DELINQUENCIES                     number_list;
    L_SCORE                                     number_list;
     -- Start for the bug#7562130 by PNAVEENK
    L_SCORE_ID                                  number_list;
    L_SCORE_NAME                                varchar_240_list;
    L_COLLECTOR_RESOURCE_NAME                   varchar_240_list;
    -- End for the bug#7562130
    L_ADDRESS1                                  varchar_240_list;
    L_CITY                                      varchar_60_list;
    L_STATE                                     varchar_60_list;
    L_COUNTY                                    varchar_60_list;
    L_COUNTRY                                   varchar_80_list;
    L_PROVINCE                                  varchar_60_list;
    L_POSTAL_CODE                               varchar_60_list;
    L_PHONE_COUNTRY_CODE                        varchar_10_list;
    L_PHONE_AREA_CODE                           varchar_10_list;
    L_PHONE_NUMBER                              varchar_40_list;
    L_PHONE_EXTENSION                           varchar_20_list;
    L_NUMBER_OF_BANKRUPTCIES                    number_list;
    L_NUMBER_OF_PROMISES                        number_list;
    L_BROKEN_PROMISE_AMOUNT                     number_list;
    L_PROMISE_AMOUNT                            number_list;
    L_ACTIVE_PROMISES                           number_list;
    L_COMPLETE_PROMISES                         number_list;
    L_PENDING_PROMISES                          number_list;
    L_WORK_ITEM_ID                              number_list;
    L_SCHEDULE_START                            date_list;
    L_SCHEDULE_END                              date_list;
    L_WORK_TYPE                                 varchar_30_list;
    L_CATEGORY_TYPE                             varchar_30_list;
    L_PRIORITY_TYPE                             varchar_30_list;
    L_JTF_OBJECT_ID                             number_list;
    l_wkitem_resource_id			number_list;
    l_strategy_id				number_list;
    l_strategy_template_id 			number_list;
    l_work_item_template_id 			number_list;
    l_status_code 				varchar_30_list;
    l_str_status                                varchar_30_list;   -- Added for bug#7416344 by PNAVEENK on 2-4-2009
    l_start_time 				date_list;
    l_end_time 					date_list;
    l_work_item_order 				number_list;
    l_escalated_yn                              varchar_10_list;  --Added for bug#6981126 by schekuri on 27-Jun-2008

    l_max_fetches                               NUMBER;
    l_total                                     NUMBER;

    cursor c_account_del is
    select del.cust_account_id,
    count(1) number_of_delinquencies,
    max(decode(uwq_status,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_delinquencies,
    max(decode(uwq_status,'COMPLETE',(decode(sign(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_delinquencies,
    max(decode(uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_delinquencies
    from iex_delinquencies_all del,
    iex_pop_uwq_summ_gt temp
    WHERE del.cust_account_id = temp.object_id  AND
    del.org_id = temp.org_id and
    del.status IN('DELINQUENT',    'PREDELINQUENT')
    group by del.cust_account_id;

    cursor c_account_pro is
    select del.cust_account_id,
    max(decode(pd.uwq_status,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_promises,
    max(decode(pd.uwq_status,'COMPLETE',(decode(sign(TRUNC(pd.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_promises,
    max(decode(pd.uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_promises
    from iex_promise_details pd,
    IEX_DELINQUENCIES_ALL DEL,
    iex_pop_uwq_summ_gt temp
    WHERE pd.cust_account_id = del.cust_account_id
      and pd.delinquency_id = del.delinquency_id
      and del.cust_account_id = temp.object_id
      and del.org_id = temp.org_id
      and pd.state = 'BROKEN_PROMISE'
     group by del.cust_account_id;

    cursor c_account_pro_summ is
    SELECT del.cust_account_id,
    COUNT(1) number_of_promises,
    SUM(amount_due_remaining) broken_promise_amount,
    SUM(promise_amount) promise_amount
    FROM iex_promise_details pd,
         iex_delinquencies_all del,
         iex_pop_uwq_summ_gt temp
   WHERE pd.cust_account_id = del.cust_account_id
     AND pd.delinquency_id = del.delinquency_id
     AND pd.status IN('COLLECTABLE',   'PENDING')
     AND pd.state = 'BROKEN_PROMISE'
     AND pd.amount_due_remaining > 0
     AND (del.status NOT IN('CURRENT',   'CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 06-Jan-2009 barathsr
     and del.cust_account_id = temp.object_id
     and del.org_id = temp.org_id
   GROUP BY del.cust_account_id;
   -- Start for the bug#7562130 by PNAVEENK
   cursor c_account_score is
   SELECT sh.score_object_id, sh.score_value score,sh.score_id, sc.score_name
     FROM iex_score_histories sh,
          iex_pop_uwq_summ_gt temp,
	  iex_scores sc
    WHERE sh.creation_date = (SELECT MAX(creation_date)
                               FROM iex_score_histories sh1
                              WHERE sh1.score_object_code = 'IEX_ACCOUNT'
                                AND sh1.score_object_id = sh.score_object_id)
     -- AND rownum < 2
      AND sh.score_object_code = 'IEX_ACCOUNT'
      AND sh.score_object_id = temp.object_id
      and sc.score_id = sh.score_id;
   -- end for the bug#7562130
   cursor c_account_past_due is
   SELECT a.cust_account_id,
   SUM(b.acctd_amount_due_remaining) past_due_inv_value
   FROM iex_delinquencies_all a,
        ar_payment_schedules_all b,
        iex_pop_uwq_summ_gt temp
  WHERE a.cust_account_id = temp.object_id
    AND a.payment_schedule_id = b.payment_schedule_id
    AND b.status = 'OP'
    AND a.status IN('DELINQUENT',   'PREDELINQUENT')
    AND temp.org_id = a.org_id
   GROUP BY a.cust_account_id;

   cursor c_last_payment_no_amount is
   SELECT o_summ.cust_account_id,
          o_summ.last_payment_number last_payment_number,
	  iex_uwq_view_pkg.convert_amount(o_summ.last_payment_amount,o_summ.currency) last_payment_amount
   FROM ar_trx_bal_summary o_summ
   WHERE o_summ.cust_account_id in (select object_id from iex_pop_uwq_summ_gt)
   AND o_summ.last_payment_date =  (SELECT MAX(last_payment_date)
                                    FROM ar_trx_bal_summary
                                    WHERE cust_account_id = o_summ.cust_account_id);

   cursor c_bankruptcies is
   select ca.cust_account_id,
          COUNT(1) number_of_bankruptcies
   FROM iex_bankruptcies bkr,hz_cust_accounts ca
   where ca.cust_account_id in (select object_id from iex_pop_uwq_summ_gt)
         and bkr.party_id=ca.party_id
	 and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')  -- Changed for bug#7693986
   group by ca.cust_account_id;

   -- Bug #6251657 bibeura 25-OCT-2007
   cursor c_account_del_dln is
    select del.cust_account_id,
    sum(decode(del.status,'DELINQUENT',1,'PREDELINQUENT',1,0)) number_of_delinquencies,
    sum(decode(del.status,'DELINQUENT',ps.acctd_amount_due_remaining,'PREDELINQUENT',ps.acctd_amount_due_remaining,0)) past_due_inv_value,
    max(decode(uwq_status,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_delinquencies,
    max(decode(uwq_status,'COMPLETE',(decode(sign(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_delinquencies,
    max(decode(uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_delinquencies,
    del.org_id org_id
    from iex_delinquencies del,
    ar_payment_schedules ps
    WHERE del.payment_schedule_id = ps.payment_schedule_id  AND
    del.org_id = ps.org_id and
    exists(select 1 from iex_delinquencies del1
		    where del1.last_update_date>=trunc(sysdate)
		    and del.cust_account_id=del1.cust_account_id
		    and del.org_id=del1.org_id)
    group by del.cust_account_id, del.org_id;


BEGIN
	l_max_fetches := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '100000'));
	if p_mode='DLN' then
	        LogMessage(FND_LOG.LEVEL_STATEMENT,'Starting..');
		-- Start Bug #6251657 bibeura 25-OCT-2007
		BEGIN
			OPEN c_account_del_dln;
		        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_account_del_dln cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
	                L_CUST_ACCOUNT_ID.delete;
	        	L_NUMBER_OF_DELINQUENCIES.delete;
	                L_PENDING_DELINQUENCIES.delete;
	        	L_COMPLETE_DELINQUENCIES.delete;
	                L_ACTIVE_DELINQUENCIES.delete;
			L_PAST_DUE_INV_VALUE.delete;
			L_ORG_ID.delete;

  	            LOOP
	                FETCH c_account_del_dln bulk collect
	                INTO
	                L_CUST_ACCOUNT_ID,
	                L_NUMBER_OF_DELINQUENCIES,
			L_PAST_DUE_INV_VALUE,
            	        L_PENDING_DELINQUENCIES,
	                L_COMPLETE_DELINQUENCIES,
                        L_ACTIVE_DELINQUENCIES,
			L_ORG_ID
                        limit l_max_fetches;
			IF L_CUST_ACCOUNT_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_account_del_dln ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
	                        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		                EXIT;
			ELSE

	                   forall i IN L_CUST_ACCOUNT_ID.FIRST .. L_CUST_ACCOUNT_ID.LAST
		             UPDATE IEX_DLN_UWQ_SUMMARY
			     SET NUMBER_OF_DELINQUENCIES = L_NUMBER_OF_DELINQUENCIES(i),
			         PAST_DUE_INV_VALUE = L_PAST_DUE_INV_VALUE(i),
	       			 ACTIVE_DELINQUENCIES    = L_ACTIVE_DELINQUENCIES(i),
				 COMPLETE_DELINQUENCIES  = L_COMPLETE_DELINQUENCIES(i),
				 PENDING_DELINQUENCIES   = L_PENDING_DELINQUENCIES(i)
			     WHERE
			     CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i)
       		             AND ORG_ID=L_ORG_ID(i);
		             LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_account_del_dln updated ' || L_COLLECTOR_ID.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
	               END IF;
	            END LOOP;
	           IF c_account_del_dln % ISOPEN THEN
		       CLOSE c_account_del_dln;
                   END IF;

	        EXCEPTION
		   WHEN OTHERS THEN
	               LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
	        END;

		 --Begin Bug 8707923 27-Jul-2009 barathsr
		FND_FILE.PUT_LINE(FND_FILE.LOG,'deleting rows from A/C gt table');

				delete from iex_pop_uwq_summ_gt;
		-- End Bug #6251657 bibeura 25-OCT-2007
		FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert into account gt');
		insert into iex_pop_uwq_summ_gt(object_id,object_type,org_id)
		select del.cust_account_id,'IEX_ACCOUNT',del.org_id from iex_delinquencies del,hz_party_preferences party_pref
		where del.status in ('DELINQUENT','PRE-DELINQUENT')
		             and del.party_cust_id=party_pref.party_id(+)
                             and party_pref.module(+)='COLLECTIONS'
                             and party_pref.category(+)='COLLECTIONS LEVEL'
			     and party_pref.preference_code(+)='PARTY_ID'
			     and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),G_SYSTEM_LEVEL)='ACCOUNT'
		and not exists(select 1 from IEX_DLN_UWQ_SUMMARY dus where dus.cust_account_id=del.cust_account_id
			     and dus.site_use_id is null
			     and dus.org_id=del.org_id)
		group by del.cust_account_id,del.org_id;
		if sql%rowcount<=0 then
			return;
			else
			FND_FILE.PUT_LINE(FND_FILE.LOG,'Inserted into account gt-->'||sql%rowcount);
		end if;
	else
		null;
	end if;

	delete from iex_dln_uwq_summary summ
	where exists(select 1
		     from iex_pop_uwq_summ_gt gt,hz_cust_accounts hca
		     where gt.object_id=hca.cust_account_id
		     and hca.party_id=summ.party_id
		     and summ.site_use_id is null
		     and gt.org_id=summ.org_id)
	and summ.business_level<>'ACCOUNT';
	LogMessage(FND_LOG.LEVEL_STATEMENT,'No. of records deleted at ACCOUNT level->' || sql%rowcount);

	commit;

	--End Bug 8707923 27-Jul-2009 barathsr

         open c_iex_account_uwq_summary;
         loop
	 l_count := l_count +1;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'----------');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bulk ' || l_count);

        L_ORG_ID.delete;
        L_COLLECTOR_ID.delete;
        L_COLLECTOR_RESOURCE_ID.delete;
        L_COLLECTOR_RES_TYPE.delete;
        L_IEU_OBJECT_FUNCTION.delete;
        L_IEU_OBJECT_PARAMETERS.delete;
        L_IEU_MEDIA_TYPE_UUID.delete;
        L_IEU_PARAM_PK_COL.delete;
        L_IEU_PARAM_PK_VALUE.delete;
        L_RESOURCE_ID.delete;
        L_RESOURCE_TYPE.delete;
        L_PARTY_ID.delete;
        L_PARTY_NAME.delete;
        L_CUST_ACCOUNT_ID.delete;
        L_ACCOUNT_NAME.delete;
        L_ACCOUNT_NUMBER.delete;
        L_SITE_USE_ID.delete;
        L_LOCATION.delete;
        L_CURRENCY.delete;
        L_OP_INVOICES_COUNT.delete;
        L_OP_DEBIT_MEMOS_COUNT.delete;
        L_OP_DEPOSITS_COUNT.delete;
        L_OP_BILLS_RECEIVABLES_COUNT.delete;
        L_OP_CHARGEBACK_COUNT.delete;
        L_OP_CREDIT_MEMOS_COUNT.delete;
        L_UNRESOLVED_CASH_COUNT.delete;
        L_DISPUTED_INV_COUNT.delete;
        L_BEST_CURRENT_RECEIVABLES.delete;
        L_OP_INVOICES_VALUE.delete;
        L_OP_DEBIT_MEMOS_VALUE.delete;
        L_OP_DEPOSITS_VALUE.delete;
        L_OP_BILLS_RECEIVABLES_VALUE.delete;
        L_OP_CHARGEBACK_VALUE.delete;
        L_OP_CREDIT_MEMOS_VALUE.delete;
        L_UNRESOLVED_CASH_VALUE.delete;
        L_RECEIPTS_AT_RISK_VALUE.delete;
        L_INV_AMT_IN_DISPUTE.delete;
        L_PENDING_ADJ_VALUE.delete;
        L_PAST_DUE_INV_VALUE.delete;
        L_PAST_DUE_INV_INST_COUNT.delete;
        L_LAST_PAYMENT_DATE.delete;
        L_LAST_PAYMENT_AMOUNT.delete;
        L_LAST_PAYMENT_AMOUNT_CURR.delete;
        L_LAST_PAYMENT_NUMBER.delete;
        L_LAST_UPDATE_DATE.delete;
        L_LAST_UPDATED_BY.delete;
        L_CREATION_DATE.delete;
        L_CREATED_BY.delete;
        L_LAST_UPDATE_LOGIN.delete;
        L_NUMBER_OF_DELINQUENCIES.delete;
        L_ACTIVE_DELINQUENCIES.delete;
        L_COMPLETE_DELINQUENCIES.delete;
        L_PENDING_DELINQUENCIES.delete;
        L_SCORE.delete;
        L_ADDRESS1.delete;
        L_CITY.delete;
        L_STATE.delete;
        L_COUNTY.delete;
        L_COUNTRY.delete;
        L_PROVINCE.delete;
        L_POSTAL_CODE.delete;
        L_PHONE_COUNTRY_CODE.delete;
        L_PHONE_AREA_CODE.delete;
        L_PHONE_NUMBER.delete;
        L_PHONE_EXTENSION.delete;
        L_NUMBER_OF_BANKRUPTCIES.delete;
        L_NUMBER_OF_PROMISES.delete;
        L_BROKEN_PROMISE_AMOUNT.delete;
        L_PROMISE_AMOUNT.delete;
        L_ACTIVE_PROMISES.delete;
        L_COMPLETE_PROMISES.delete;
        L_PENDING_PROMISES.delete;
         LogMessage(FND_LOG.LEVEL_STATEMENT,'Start fetching records...');
	 FETCH c_iex_account_uwq_summary bulk collect
                INTO
                    L_ORG_ID,
                    L_IEU_OBJECT_FUNCTION,
                    L_IEU_OBJECT_PARAMETERS,
                    L_IEU_MEDIA_TYPE_UUID,
                    L_IEU_PARAM_PK_COL,
                    L_IEU_PARAM_PK_VALUE,
                    L_RESOURCE_ID,
                    L_RESOURCE_TYPE,
                    L_PARTY_ID,
                    L_PARTY_NAME,
                    L_CUST_ACCOUNT_ID,
                    L_ACCOUNT_NAME,
                    L_ACCOUNT_NUMBER,
                    L_SITE_USE_ID,
                    L_LOCATION,
                    L_CURRENCY,
                    L_OP_INVOICES_COUNT,
                    L_OP_DEBIT_MEMOS_COUNT,
                    L_OP_DEPOSITS_COUNT,
                    L_OP_BILLS_RECEIVABLES_COUNT,
                    L_OP_CHARGEBACK_COUNT,
                    L_OP_CREDIT_MEMOS_COUNT,
                    L_UNRESOLVED_CASH_COUNT,
                    L_DISPUTED_INV_COUNT,
                    L_BEST_CURRENT_RECEIVABLES,
                    L_OP_INVOICES_VALUE,
                    L_OP_DEBIT_MEMOS_VALUE,
                    L_OP_DEPOSITS_VALUE,
                    L_OP_BILLS_RECEIVABLES_VALUE,
                    L_OP_CHARGEBACK_VALUE,
                    L_OP_CREDIT_MEMOS_VALUE,
                    L_UNRESOLVED_CASH_VALUE,
                    L_RECEIPTS_AT_RISK_VALUE,
                    L_INV_AMT_IN_DISPUTE,
                    L_PENDING_ADJ_VALUE,
                    L_PAST_DUE_INV_INST_COUNT,
                    L_LAST_PAYMENT_DATE,
                    L_LAST_PAYMENT_AMOUNT_CURR,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_LOGIN,
                    L_ADDRESS1,
                    L_CITY,
                    L_STATE,
                    L_COUNTY,
                    L_COUNTRY,
                    L_PROVINCE,
                    L_POSTAL_CODE
                limit l_max_fetches;

		IF L_IEU_OBJECT_FUNCTION.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

        ELSE

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Fetched  ' || L_IEU_OBJECT_FUNCTION.COUNT || ' rows.');
          LogMessage(FND_LOG.LEVEL_STATEMENT,'Inserting...');
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start inserting time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_STATEMENT,'inserting records..');
          forall i IN L_IEU_OBJECT_FUNCTION.FIRST .. L_IEU_OBJECT_FUNCTION.LAST
            INSERT INTO IEX_DLN_UWQ_SUMMARY
                (DLN_UWQ_SUMMARY_ID
                ,ORG_ID
                ,IEU_OBJECT_FUNCTION
                ,IEU_OBJECT_PARAMETERS
                ,IEU_MEDIA_TYPE_UUID
                ,IEU_PARAM_PK_COL
                ,IEU_PARAM_PK_VALUE
                ,RESOURCE_ID
                ,RESOURCE_TYPE
                ,PARTY_ID
                ,PARTY_NAME
                ,CUST_ACCOUNT_ID
                ,ACCOUNT_NAME
                ,ACCOUNT_NUMBER
                ,SITE_USE_ID
                ,LOCATION
                ,CURRENCY
                ,OP_INVOICES_COUNT
                ,OP_DEBIT_MEMOS_COUNT
                ,OP_DEPOSITS_COUNT
                ,OP_BILLS_RECEIVABLES_COUNT
                ,OP_CHARGEBACK_COUNT
                ,OP_CREDIT_MEMOS_COUNT
                ,UNRESOLVED_CASH_COUNT
                ,DISPUTED_INV_COUNT
                ,BEST_CURRENT_RECEIVABLES
                ,OP_INVOICES_VALUE
                ,OP_DEBIT_MEMOS_VALUE
                ,OP_DEPOSITS_VALUE
                ,OP_BILLS_RECEIVABLES_VALUE
                ,OP_CHARGEBACK_VALUE
                ,OP_CREDIT_MEMOS_VALUE
                ,UNRESOLVED_CASH_VALUE
                ,RECEIPTS_AT_RISK_VALUE
                ,INV_AMT_IN_DISPUTE
                ,PENDING_ADJ_VALUE
                ,PAST_DUE_INV_INST_COUNT
                ,LAST_PAYMENT_DATE
                ,LAST_PAYMENT_AMOUNT_CURR
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_LOGIN
                ,ADDRESS1
                ,CITY
                ,STATE
                ,COUNTY
                ,COUNTRY
                ,PROVINCE
                ,POSTAL_CODE
		,NUMBER_OF_DELINQUENCIES
		,NUMBER_OF_PROMISES
		,NUMBER_OF_BANKRUPTCIES
		,BUSINESS_LEVEL)  --Added for Bug 8707923 27-Jul-2009 barathsr
            VALUES
                (IEX_DLN_UWQ_SUMMARY_S.nextval,
                L_ORG_ID(i),
                L_IEU_OBJECT_FUNCTION(i),
                L_IEU_OBJECT_PARAMETERS(i),
                L_IEU_MEDIA_TYPE_UUID(i),
                L_IEU_PARAM_PK_COL(i),
                L_IEU_PARAM_PK_VALUE(i),
                L_RESOURCE_ID(i),
                L_RESOURCE_TYPE(i),
                L_PARTY_ID(i),
                L_PARTY_NAME(i),
                L_CUST_ACCOUNT_ID(i),
                L_ACCOUNT_NAME(i),
                L_ACCOUNT_NUMBER(i),
                L_SITE_USE_ID(i),
                L_LOCATION(i),
                L_CURRENCY(i),
                L_OP_INVOICES_COUNT(i),
                L_OP_DEBIT_MEMOS_COUNT(i),
                L_OP_DEPOSITS_COUNT(i),
                L_OP_BILLS_RECEIVABLES_COUNT(i),
                L_OP_CHARGEBACK_COUNT(i),
                L_OP_CREDIT_MEMOS_COUNT(i),
                L_UNRESOLVED_CASH_COUNT(i),
                L_DISPUTED_INV_COUNT(i),
                L_BEST_CURRENT_RECEIVABLES(i),
                L_OP_INVOICES_VALUE(i),
                L_OP_DEBIT_MEMOS_VALUE(i),
                L_OP_DEPOSITS_VALUE(i),
                L_OP_BILLS_RECEIVABLES_VALUE(i),
                L_OP_CHARGEBACK_VALUE(i),
                L_OP_CREDIT_MEMOS_VALUE(i),
                L_UNRESOLVED_CASH_VALUE(i),
                L_RECEIPTS_AT_RISK_VALUE(i),
                L_INV_AMT_IN_DISPUTE(i),
                L_PENDING_ADJ_VALUE(i),
                L_PAST_DUE_INV_INST_COUNT(i),
                L_LAST_PAYMENT_DATE(i),
                L_LAST_PAYMENT_AMOUNT_CURR(i),
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.CONC_LOGIN_ID,
                L_ADDRESS1(i),
                L_CITY(i),
                L_STATE(i),
                L_COUNTY(i),
                L_COUNTRY(i),
                L_PROVINCE(i),
                L_POSTAL_CODE(i),
		0,
		0,
		0,
		'ACCOUNT');--Added for Bug 8707923 27-Jul-2009 barathsr

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End inserting time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Inserted ' || L_IEU_OBJECT_FUNCTION.COUNT || ' rows at biz lvl-->'||p_level);


          l_total := l_total + L_IEU_OBJECT_FUNCTION.COUNT;
          LogMessage(FND_LOG.LEVEL_STATEMENT,'So far processed ' || l_total || ' rows');


        END IF;

      END LOOP;
      close c_iex_account_uwq_summary;

      OPEN c_strategy_summary;
      LOOP
          l_count := l_count +1;
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'----------');
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bulk ' || l_count);

          L_JTF_OBJECT_ID.delete;
          L_WORK_ITEM_ID.delete;
          L_SCHEDULE_START.delete;
          L_SCHEDULE_END.delete;
          L_WORK_TYPE.delete;
          L_CATEGORY_TYPE.delete;
          L_PRIORITY_TYPE.delete;
	  L_wkitem_RESOURCE_ID.delete;
          L_STRATEGY_ID.delete;
	  L_STRATEGY_TEMPLATE_ID.delete;
	  L_WORK_ITEM_TEMPLATE_ID.delete;
	  L_STATUS_CODE.delete;
	  L_STR_STATUS.delete;  -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	  L_START_TIME.delete;
	  L_END_TIME.delete;
	  L_WORK_ITEM_ORDER.delete;
	  L_ESCALATED_YN.delete;   --Added for bug#6981126 by schekuri on 27-Jun-2008

          LogMessage(FND_LOG.LEVEL_STATEMENT,'Inited all arrays');

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          FETCH c_strategy_summary bulk collect
          INTO
            L_JTF_OBJECT_ID,
            L_WORK_ITEM_ID,
            L_SCHEDULE_START,
            L_SCHEDULE_END,
            L_CATEGORY_TYPE,
	    L_WORK_TYPE,
            L_PRIORITY_TYPE,
	    L_WKITEM_RESOURCE_ID,
	    L_STRATEGY_ID,
	    L_STRATEGY_TEMPLATE_ID,
	    L_WORK_ITEM_TEMPLATE_ID,
	    L_STATUS_CODE,
	    L_STR_STATUS,  -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	    L_START_TIME,
	    L_END_TIME,
	    L_WORK_ITEM_ORDER,
	    L_ESCALATED_YN  --Added for bug#6981126 by schekuri on 27-Jun-2008
          limit l_max_fetches;

	  LogMessage(FND_LOG.LEVEL_STATEMENT,L_JTF_OBJECT_ID.COUNT);

          IF L_JTF_OBJECT_ID.COUNT = 0 THEN

            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
            CLOSE c_strategy_summary;
            EXIT;

          ELSE

            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Fetched  ' || L_JTF_OBJECT_ID.COUNT || ' rows.');
            LogMessage(FND_LOG.LEVEL_STATEMENT,' Updating table...');
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start updating time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

               forall i IN L_JTF_OBJECT_ID.FIRST .. L_JTF_OBJECT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                   SET WORK_ITEM_ID = L_WORK_ITEM_ID(i),
                    SCHEDULE_START = L_SCHEDULE_START(i),
                    SCHEDULE_END = L_SCHEDULE_END(i),
                    WORK_TYPE = L_WORK_TYPE(i),
                    CATEGORY_TYPE = L_CATEGORY_TYPE(i),
                    PRIORITY_TYPE = L_PRIORITY_TYPE(i),
		    WKITEM_RESOURCE_ID = L_WKITEM_RESOURCE_ID(i),
  	    	    STRATEGY_ID = L_STRATEGY_ID(i),
	    	    STRATEGY_TEMPLATE_ID = L_STRATEGY_TEMPLATE_ID(i),
		    WORK_ITEM_TEMPLATE_ID = L_WORK_ITEM_TEMPLATE_ID(i),
	            STATUS_CODE = L_STATUS_CODE(i),
		    STR_STATUS = L_STR_STATUS(i),  -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	            START_TIME = L_START_TIME(i),
	            END_TIME = L_END_TIME(i),
	            WORK_ITEM_ORDER = L_WORK_ITEM_ORDER(i),
		    WKITEM_ESCALATED_YN = L_ESCALATED_YN(i)    --Added for bug#6981126 by schekuri on 27-Jun-2008
                 WHERE cust_account_id = L_JTF_OBJECT_ID(i);


            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Updated ' || L_JTF_OBJECT_ID.COUNT || ' rows');
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End updating time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));



            l_total := l_total + L_JTF_OBJECT_ID.COUNT;
            LogMessage(FND_LOG.LEVEL_STATEMENT,'So far processed ' || l_total || ' rows');

          END IF;

      END LOOP;

      IF c_strategy_summary % ISOPEN THEN
        CLOSE c_strategy_summary;
      END IF;

      BEGIN
      OPEN C_COLLECTOR_PROF;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_collector_prof cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_COLLECTOR_RESOURCE_ID.delete  ;
	L_COLLECTOR_RESOURCE_NAME.delete; -- Added for the bug#7562130
	L_COLLECTOR_ID.delete;
	L_RESOURCE_TYPE.delete;
	L_PARTY_ID.delete;
	L_CUST_ACCOUNT_ID.delete;

      LOOP
        FETCH C_COLLECTOR_PROF bulk collect
          INTO
	    L_COLLECTOR_ID,
  	    L_COLLECTOR_RESOURCE_ID,
	    L_COLLECTOR_RESOURCE_NAME, -- Added for the bug#7562130
	    L_RESOURCE_TYPE,
	    L_PARTY_ID,
            L_CUST_ACCOUNT_ID
          limit l_max_fetches;
      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_collector_prof ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_CUST_ACCOUNT_ID.FIRST .. L_CUST_ACCOUNT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
		        COLLECTOR_RESOURCE_NAME = L_COLLECTOR_RESOURCE_NAME(i), -- Added for the bug#7562130
		        COLLECTOR_RES_TYPE    = L_RESOURCE_TYPE(i),
			collector_id = l_collector_id(i),
			last_update_date   = SYSDATE,
		        last_updated_by    = FND_GLOBAL.USER_ID
                   WHERE
		    CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_collector_prof updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_COLLECTOR_PROF % ISOPEN THEN
        CLOSE C_COLLECTOR_PROF;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Collector profile update received' || SQLERRM);
       END;

     BEGIN
       OPEN c_contact_point;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened Cursor  c_contact_point  cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_PARTY_ID.delete;
        L_PHONE_COUNTRY_CODE.delete;
        L_PHONE_AREA_CODE.delete;
        L_PHONE_NUMBER.delete;
        L_PHONE_EXTENSION.delete;


      LOOP
	 FETCH c_contact_point bulk collect
          INTO
	   L_PARTY_ID,
	   L_PHONE_COUNTRY_CODE,
	   L_PHONE_AREA_CODE,
	   L_PHONE_NUMBER,
	   L_PHONE_EXTENSION

          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'c_contact_point  Cursor Fetching end time:   ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

        ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST

                   UPDATE IEX_DLN_UWQ_SUMMARY
                   SET PHONE_COUNTRY_CODE = L_PHONE_COUNTRY_CODE(i),
		       PHONE_AREA_CODE    = L_PHONE_AREA_CODE(i),
		       PHONE_NUMBER       = L_PHONE_NUMBER(i),
		       PHONE_EXTENSION    = L_PHONE_EXTENSION(i),
		       last_update_date   = SYSDATE,
		       last_updated_by    = FND_GLOBAL.USER_ID
                 WHERE PARTY_ID = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Contact point  Cursor updated ' ||L_PARTY_ID.count || ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
        CLOSE c_contact_point;


      EXCEPTION WHEN OTHERS THEN
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Contact point raised error ' || SQLERRM);
      END;
-- gnramasa
      BEGIN
      OPEN C_ACCOUNT_DEL;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_account_del cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_CUST_ACCOUNT_ID.delete;
	L_NUMBER_OF_DELINQUENCIES.delete;
        L_PENDING_DELINQUENCIES.delete;
	L_COMPLETE_DELINQUENCIES.delete;
        L_ACTIVE_DELINQUENCIES.delete;

      LOOP
        FETCH C_ACCOUNT_DEL bulk collect
          INTO
	    L_CUST_ACCOUNT_ID,
  	    L_NUMBER_OF_DELINQUENCIES,
	    L_PENDING_DELINQUENCIES,
	    L_COMPLETE_DELINQUENCIES,
            L_ACTIVE_DELINQUENCIES
          limit l_max_fetches;
      IF L_CUST_ACCOUNT_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_account_del ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_CUST_ACCOUNT_ID.FIRST .. L_CUST_ACCOUNT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET NUMBER_OF_DELINQUENCIES = L_NUMBER_OF_DELINQUENCIES(i),
		        ACTIVE_DELINQUENCIES    = L_ACTIVE_DELINQUENCIES(i),
			COMPLETE_DELINQUENCIES  = L_COMPLETE_DELINQUENCIES(i),
			PENDING_DELINQUENCIES   = L_PENDING_DELINQUENCIES(i)
                   WHERE
		    CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_account_del updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_ACCOUNT_DEL % ISOPEN THEN
        CLOSE C_ACCOUNT_DEL;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_ACCOUNT_PRO;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_account_pro cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_CUST_ACCOUNT_ID.delete;
	L_ACTIVE_PROMISES.delete;
        L_COMPLETE_PROMISES.delete;
        L_PENDING_PROMISES.delete;

      LOOP
        FETCH C_ACCOUNT_PRO bulk collect
          INTO
	    L_CUST_ACCOUNT_ID,
  	    L_PENDING_PROMISES,
	    L_COMPLETE_PROMISES,
	    L_ACTIVE_PROMISES
          limit l_max_fetches;
      IF L_CUST_ACCOUNT_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_account_pro ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_CUST_ACCOUNT_ID.FIRST .. L_CUST_ACCOUNT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET ACTIVE_PROMISES    = L_ACTIVE_PROMISES(i),
			COMPLETE_PROMISES  = L_COMPLETE_PROMISES(i),
			PENDING_PROMISES   = L_PENDING_PROMISES(i)
                   WHERE
		    CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_account_pro updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_ACCOUNT_PRO % ISOPEN THEN
        CLOSE C_ACCOUNT_PRO;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Promise update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_ACCOUNT_PRO_SUMM;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_account_pro_summ cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_CUST_ACCOUNT_ID.delete;
	L_NUMBER_OF_PROMISES.delete;
        L_BROKEN_PROMISE_AMOUNT .delete;
        L_PROMISE_AMOUNT.delete;

      LOOP
        FETCH C_ACCOUNT_PRO_SUMM bulk collect
          INTO
	    L_CUST_ACCOUNT_ID,
  	    L_NUMBER_OF_PROMISES,
	    L_BROKEN_PROMISE_AMOUNT,
	    L_PROMISE_AMOUNT
          limit l_max_fetches;
      IF L_CUST_ACCOUNT_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_account_pro_summ ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_CUST_ACCOUNT_ID.FIRST .. L_CUST_ACCOUNT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET NUMBER_OF_PROMISES     = L_NUMBER_OF_PROMISES(i),
			BROKEN_PROMISE_AMOUNT  = L_BROKEN_PROMISE_AMOUNT(i),
			PROMISE_AMOUNT         = L_PROMISE_AMOUNT(i)
                   WHERE
		    CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_account_pro_summ updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_ACCOUNT_PRO_SUMM % ISOPEN THEN
        CLOSE C_ACCOUNT_PRO_SUMM;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Broken Promise update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_ACCOUNT_SCORE;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_account_score cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_CUST_ACCOUNT_ID.delete;
	L_SCORE.delete;
	L_SCORE_ID.delete;  -- Added for the bug#7562130
	L_SCORE_NAME.delete; -- Added for the bug#7562130

      LOOP
        FETCH C_ACCOUNT_SCORE bulk collect
          INTO
	    L_CUST_ACCOUNT_ID,
  	    L_SCORE,
	    L_SCORE_ID,  -- Added for the bug#7562130
	    L_SCORE_NAME  -- dded for the bug#7562130
          limit l_max_fetches;
      IF L_CUST_ACCOUNT_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_account_score ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_CUST_ACCOUNT_ID.FIRST .. L_CUST_ACCOUNT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET SCORE     = L_SCORE(i),
		        SCORE_ID = L_SCORE_ID(i), -- Added for the bug#7562130
			SCORE_NAME = L_SCORE_NAME(i) -- Added for the bug#7562130
                   WHERE
		    CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_account_score updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_ACCOUNT_SCORE % ISOPEN THEN
        CLOSE C_ACCOUNT_SCORE;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Score update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_ACCOUNT_PAST_DUE;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_account_past_due cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_CUST_ACCOUNT_ID.delete;
	L_PAST_DUE_INV_VALUE.delete;

      LOOP
        FETCH C_ACCOUNT_PAST_DUE bulk collect
          INTO
	    L_CUST_ACCOUNT_ID,
  	    L_PAST_DUE_INV_VALUE
          limit l_max_fetches;
      IF L_CUST_ACCOUNT_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_account_past_due ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_CUST_ACCOUNT_ID.FIRST .. L_CUST_ACCOUNT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET PAST_DUE_INV_VALUE     = L_PAST_DUE_INV_VALUE(i)
                   WHERE
		    CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_account_past_due updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_ACCOUNT_PAST_DUE % ISOPEN THEN
        CLOSE C_ACCOUNT_PAST_DUE;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Past due invoice update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_LAST_PAYMENT_NO_AMOUNT;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_last_payment_no_amount cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_CUST_ACCOUNT_ID.delete;
        L_LAST_PAYMENT_NUMBER.delete;
	L_LAST_PAYMENT_AMOUNT.delete;

      LOOP
        FETCH C_LAST_PAYMENT_NO_AMOUNT bulk collect
          INTO
	    L_CUST_ACCOUNT_ID,
  	    L_LAST_PAYMENT_NUMBER,
	    L_LAST_PAYMENT_AMOUNT
          limit l_max_fetches;
      IF L_CUST_ACCOUNT_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_last_payment_no_amount ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_CUST_ACCOUNT_ID.FIRST .. L_CUST_ACCOUNT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET LAST_PAYMENT_NUMBER     = L_LAST_PAYMENT_NUMBER(i),
		        LAST_PAYMENT_AMOUNT     = L_LAST_PAYMENT_AMOUNT(i)
                   WHERE
		    CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_last_payment_no_amount updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_LAST_PAYMENT_NO_AMOUNT % ISOPEN THEN
        CLOSE C_LAST_PAYMENT_NO_AMOUNT;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Last payment no and amount update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_BANKRUPTCIES;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_bankruptcies cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_CUST_ACCOUNT_ID.delete;
        L_NUMBER_OF_BANKRUPTCIES.delete;

      LOOP
        FETCH C_BANKRUPTCIES bulk collect
          INTO
	    L_CUST_ACCOUNT_ID,
  	    L_NUMBER_OF_BANKRUPTCIES
          limit l_max_fetches;
      IF L_CUST_ACCOUNT_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_bankruptcies ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_CUST_ACCOUNT_ID.FIRST .. L_CUST_ACCOUNT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET NUMBER_OF_BANKRUPTCIES     = L_NUMBER_OF_BANKRUPTCIES(i)
                   WHERE
		    CUST_ACCOUNT_ID = L_CUST_ACCOUNT_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_bankruptcies updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');


      END IF;
      END LOOP;
       IF C_BANKRUPTCIES % ISOPEN THEN
        CLOSE C_BANKRUPTCIES;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Last payment no and amount update received' || SQLERRM);
       END;


      --gnramasa
COMMIT;
LogMessage(FND_LOG.LEVEL_STATEMENT,'Commited');

EXCEPTION
WHEN OTHERS THEN
LogMessage(FND_LOG.LEVEL_STATEMENT,sqlerrm);
END ACCOUNT_REFRESH_SUMMARY_INCR;

PROCEDURE customer_refresh_summary_incr(
                    x_errbuf            OUT nocopy VARCHAR2,
                    x_retcode           OUT nocopy VARCHAR2,
                    FROM_DATE           IN  VARCHAR2,
 	            P_MODE              IN  VARCHAR2 DEFAULT 'CP',
		    p_level in varchar2)--Added for Bug 8707923 27-Jul-2009 barathsr
		    is
l_count number;

CURSOR c_iex_customer_uwq_summary IS
    SELECT trx_summ.org_id,
    objb.object_function ieu_object_function,
    objb.object_parameters || ' DISPLAYCBO=IEXTRMAN' ieu_object_parameters,
    '' ieu_media_type_uuid,
    'PARTY_ID' ieu_param_pk_col,
    to_char(party.party_id) ieu_param_pk_value,
    1 resource_id,
    'RS_EMPLOYEE' resource_type,
    party.party_id party_id,
    party.party_name party_name,
    to_number(null) cust_account_id,
    null account_name,
    null account_number,
    to_number(null) site_use_id,
    null location,
    max(gl.CURRENCY_CODE) currency,
    SUM(trx_summ.op_invoices_count) op_invoices_count,
    SUM(trx_summ.op_debit_memos_count) op_debit_memos_count,
    SUM(trx_summ.op_deposits_count) op_deposits_count,
    SUM(trx_summ.op_bills_receivables_count) op_bills_receivables_count,
    SUM(trx_summ.op_chargeback_count) op_chargeback_count,
    SUM(trx_summ.op_credit_memos_count) op_credit_memos_count,
    SUM(trx_summ.unresolved_cash_count) unresolved_cash_count,
    SUM(trx_summ.disputed_inv_count) disputed_inv_count,
    SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.best_current_receivables,
    gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
    iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.best_current_receivables))) best_current_receivables,
    SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_invoices_value,
    gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
    iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_invoices_value))) op_invoices_value,
    SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_debit_memos_value,
    gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
    iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_debit_memos_value))) op_debit_memos_value,
    SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_deposits_value,
    gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
    iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_deposits_value))) op_deposits_value,
    SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_bills_receivables_value,
    gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
    iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_bills_receivables_value))) op_bills_receivables_value,
    SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_chargeback_value,
    gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
    iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_chargeback_value))) op_chargeback_value,
    SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.op_credit_memos_value,
    gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
    iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.op_credit_memos_value))) op_credit_memos_value,
    SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.unresolved_cash_value,
    gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
    iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.unresolved_cash_value))) unresolved_cash_value,
    SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.receipts_at_risk_value,
    gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
    iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.receipts_at_risk_value))) receipts_at_risk_value,
    SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.inv_amt_in_dispute,
    gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
    iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.inv_amt_in_dispute))) inv_amt_in_dispute,
    SUM(decode(trx_summ.currency,     gl.CURRENCY_CODE,     trx_summ.pending_adj_value,
    gl_currency_api.convert_amount_sql(trx_summ.currency,     gl.CURRENCY_CODE,     sysdate,
    iex_utilities.get_cache_value('DEFAULT_EXCHANGE_RATE_TYPE',     ''),     trx_summ.pending_adj_value))) pending_adj_value,
    SUM(trx_summ.past_due_inv_inst_count) past_due_inv_inst_count,
    MAX(trx_summ.last_payment_date) last_payment_date,
    max(gl.CURRENCY_CODE) last_payment_amount_curr,
    MAX(trx_summ.last_update_date) last_update_date,
    MAX(trx_summ.last_updated_by) last_updated_by,
    MAX(trx_summ.creation_date) creation_date,
    MAX(trx_summ.created_by) created_by,
    MAX(trx_summ.last_update_login) last_update_login,
    party.address1 address1,
    party.city city,
    party.state state,
    party.county county,
    fnd_terr.territory_short_name country,
    party.province province,
    party.postal_code postal_code
    FROM ar_trx_bal_summary trx_summ,
    hz_cust_accounts acc,
    hz_parties party,
    jtf_objects_b objb,
    fnd_territories_tl fnd_terr,
    GL_SETS_OF_BOOKS gl,
    AR_SYSTEM_PARAMETERS_all sys
    WHERE trx_summ.reference_1 = '1'
     AND trx_summ.cust_account_id = acc.cust_account_id
     AND acc.party_id = party.party_id
     AND objb.object_code = 'IEX_CUSTOMER'
     AND objb.object_code <> 'IEX_DELINQUENCY' --Added for Bug 8707923 27-Jul-2009 barathsr
     AND party.country = fnd_terr.territory_code(+)
     AND fnd_terr.LANGUAGE(+) = userenv('LANG')
     and gl.SET_OF_BOOKS_ID = sys.SET_OF_BOOKS_ID
     and trx_summ.org_id = sys.org_id
     and acc.party_id in
	   (select temp.object_id from iex_pop_uwq_summ_gt temp where temp.org_id=trx_summ.org_id)
    GROUP BY trx_summ.org_id,
    objb.object_function,
    objb.object_parameters,
    party.party_id,
    party.party_name,
    party.address1,
    party.city,
    party.state,
    party.county,
    fnd_terr.territory_short_name,
    party.province,
    party.postal_code;

     CURSOR c_strategy_summary IS
     select strat.jtf_object_id,
        wkitem.WORK_ITEM_ID,
        wkitem.schedule_start schedule_start,
        wkitem.schedule_end schedule_end,
        stry_temp_wkitem.category_type category,
        stry_temp_wkitem.WORK_TYPE,
        stry_temp_wkitem.PRIORITY_TYPE,
        wkitem.resource_id,
        wkitem.strategy_id,
        strat.strategy_template_id,
        wkitem.work_item_template_id,
        wkitem.status_code,
	strat.status_code,  -- Added for bug#7416344 by PNAVEENK on 2-4-2009
    --    wkitem.creation_date start_time,
        wkitem.execute_start start_time,  -- Added for bug#8306620 by PNAVEENK on 3-4-2009
	wkitem.execute_end end_time,-- snuthala 28/08/2008 bug #6745580
        wkitem.work_item_order wkitem_order,
	wkitem.escalated_yn                   --Added for bug#6981126 by schekuri on 27-Jul-2008
      from iex_strategies strat,
        iex_strategy_work_items wkitem,
        iex_stry_temp_work_items_b stry_temp_wkitem,
        iex_pop_uwq_summ_gt temp
      where strat.status_code IN('OPEN',   'ONHOLD')
      AND wkitem.strategy_id = strat.strategy_id
      AND wkitem.status_code IN('OPEN',   'ONHOLD')
      AND wkitem.work_item_template_id = stry_temp_wkitem.work_item_temp_id
      AND strat.jtf_object_id = temp.object_id;

      -- Start for the bug#7562130 by PNAVEENK
      CURSOR C_COLLECTOR_PROF IS
      SELECT
         hp.collector_id,
         ac.resource_id,
	 decode(ac.resource_type, 'RS_RESOURCE' , rs.source_name , rg.group_name)   collector_resource_name,
	 ac.resource_type,
	 hp.party_id
      FROM
         hz_customer_profiles hp,
	 ar_collectors ac,
	 iex_pop_uwq_summ_gt temp,
	 jtf_rs_resource_extns rs,
         JTF_RS_GROUPS_VL rg
      WHERE
         hp.cust_account_id = -1
         and hp.site_use_id is null
	 and hp.party_id=temp.object_id
	 and hp.collector_id=ac.collector_id
	 and rs.resource_id(+) = ac.resource_id
         and rg.group_id (+) = ac.resource_id;
      -- end for the bug#7562130

      CURSOR C_CONTACT_POINT IS
      SELECT
         phone.owner_table_id     party_id,
         phone.phone_country_code phone_country_code,
         phone.phone_area_code    phone_area_code,
         phone.phone_number       phone_number,
         phone.phone_extension    phone_extension
      FROM
         hz_contact_points phone,
	 iex_pop_uwq_summ_gt temp
      WHERE
       phone.owner_table_id = temp.object_id
       AND phone.owner_table_name = 'HZ_PARTIES'
       AND phone.contact_point_type = 'PHONE'
       and phone.primary_by_purpose = 'Y'
       AND phone.contact_point_purpose = 'COLLECTIONS'
       AND phone.phone_line_type NOT IN('PAGER',     'FAX')
       AND phone.status = 'A'
       AND nvl(phone.do_not_use_flag, 'N') = 'N';

    L_ORG_ID                                    number_list;
    L_COLLECTOR_ID                              number_list;
    L_COLLECTOR_RESOURCE_ID                     number_list;
    L_COLLECTOR_RES_TYPE                        varchar_30_list;
    L_IEU_OBJECT_FUNCTION                       varchar_30_list;
    L_IEU_OBJECT_PARAMETERS                     varchar_2020_list;
    L_IEU_MEDIA_TYPE_UUID                       varchar_10_list;
    L_IEU_PARAM_PK_COL                          varchar_40_list;
    L_IEU_PARAM_PK_VALUE                        varchar_40_list;
    L_RESOURCE_ID                               number_list;
    L_RESOURCE_TYPE                             varchar_20_list;
    L_PARTY_ID                                  number_list;
    L_PARTY_NAME                                varchar_360_list;
    L_CUST_ACCOUNT_ID                           number_list;
    L_ACCOUNT_NAME                              varchar_240_list;
    L_ACCOUNT_NUMBER                            varchar_30_list;
    L_SITE_USE_ID                               number_list;
    L_LOCATION                                  varchar_60_list;
    L_CURRENCY                                  varchar_20_list;
    L_OP_INVOICES_COUNT                         number_list;
    L_OP_DEBIT_MEMOS_COUNT                      number_list;
    L_OP_DEPOSITS_COUNT                         number_list;
    L_OP_BILLS_RECEIVABLES_COUNT                number_list;
    L_OP_CHARGEBACK_COUNT                       number_list;
    L_OP_CREDIT_MEMOS_COUNT                     number_list;
    L_UNRESOLVED_CASH_COUNT                     number_list;
    L_DISPUTED_INV_COUNT                        number_list;
    L_BEST_CURRENT_RECEIVABLES                  number_list;
    L_OP_INVOICES_VALUE                         number_list;
    L_OP_DEBIT_MEMOS_VALUE                      number_list;
    L_OP_DEPOSITS_VALUE                         number_list;
    L_OP_BILLS_RECEIVABLES_VALUE                number_list;
    L_OP_CHARGEBACK_VALUE                       number_list;
    L_OP_CREDIT_MEMOS_VALUE                     number_list;
    L_UNRESOLVED_CASH_VALUE                     number_list;
    L_RECEIPTS_AT_RISK_VALUE                    number_list;
    L_INV_AMT_IN_DISPUTE                        number_list;
    L_PENDING_ADJ_VALUE                         number_list;
    L_PAST_DUE_INV_VALUE                        number_list;
    L_PAST_DUE_INV_INST_COUNT                   number_list;
    L_LAST_PAYMENT_DATE                         date_list;
    L_LAST_PAYMENT_AMOUNT                       number_list;
    L_LAST_PAYMENT_AMOUNT_CURR                  varchar_20_list;
    L_LAST_PAYMENT_NUMBER                       varchar_30_list;
    L_LAST_UPDATE_DATE                          date_list;
    L_LAST_UPDATED_BY                           number_list;
    L_CREATION_DATE                             date_list;
    L_CREATED_BY                                number_list;
    L_LAST_UPDATE_LOGIN                         number_list;
    L_NUMBER_OF_DELINQUENCIES                   number_list;
    L_ACTIVE_DELINQUENCIES                      number_list;
    L_COMPLETE_DELINQUENCIES                    number_list;
    L_PENDING_DELINQUENCIES                     number_list;
    L_SCORE                                     number_list;
     -- Start for the bug#7562130 by PNAVEENK
    L_SCORE_ID                                  number_list;
    L_SCORE_NAME                                varchar_240_list;
    L_COLLECTOR_RESOURCE_NAME                   varchar_240_list;
    -- End for the bug#7562130
    L_ADDRESS1                                  varchar_240_list;
    L_CITY                                      varchar_60_list;
    L_STATE                                     varchar_60_list;
    L_COUNTY                                    varchar_60_list;
    L_COUNTRY                                   varchar_80_list;
    L_PROVINCE                                  varchar_60_list;
    L_POSTAL_CODE                               varchar_60_list;
    L_PHONE_COUNTRY_CODE                        varchar_10_list;
    L_PHONE_AREA_CODE                           varchar_10_list;
    L_PHONE_NUMBER                              varchar_40_list;
    L_PHONE_EXTENSION                           varchar_20_list;
    L_NUMBER_OF_BANKRUPTCIES                    number_list;
    L_NUMBER_OF_PROMISES                        number_list;
    L_BROKEN_PROMISE_AMOUNT                     number_list;
    L_PROMISE_AMOUNT                            number_list;
    L_ACTIVE_PROMISES                           number_list;
    L_COMPLETE_PROMISES                         number_list;
    L_PENDING_PROMISES                          number_list;
    L_WORK_ITEM_ID                              number_list;
    L_SCHEDULE_START                            date_list;
    L_SCHEDULE_END                              date_list;
    L_WORK_TYPE                                 varchar_30_list;
    L_CATEGORY_TYPE                             varchar_30_list;
    L_PRIORITY_TYPE                             varchar_30_list;
    L_JTF_OBJECT_ID                             number_list;
    l_wkitem_resource_id			number_list;
    l_strategy_id				number_list;
    l_strategy_template_id 			number_list;
    l_work_item_template_id 			number_list;
    l_status_code 				varchar_30_list;
    l_str_status                                varchar_30_list;   -- Added for bug#7416344 by PNAVEENK on 2-4-2009
    l_start_time 				date_list;
    l_end_time 					date_list;
    l_work_item_order 				number_list;
    l_escalated_yn                              varchar_10_list;  --Added for bug#6981126 by schekuri on 27-Jun-2008

    l_max_fetches                               NUMBER;
    l_total                                     NUMBER;

    cursor c_customer_del is
    select del.party_cust_id,
    count(1) number_of_delinquencies,
    max(decode(uwq_status,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_delinquencies,
    max(decode(uwq_status,'COMPLETE',(decode(sign(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_delinquencies,
    max(decode(uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_delinquencies
    from iex_delinquencies_all del,
    iex_pop_uwq_summ_gt temp
    WHERE del.party_cust_id = temp.object_id  AND
    del.org_id = temp.org_id and
    del.status IN('DELINQUENT',    'PREDELINQUENT')
    group by del.party_cust_id;

    cursor c_customer_pro is
    select del.party_cust_id,
    max(decode(pd.uwq_status,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_promises,
    max(decode(pd.uwq_status,'COMPLETE',(decode(sign(TRUNC(pd.uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_promises,
    max(decode(pd.uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(pd.uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_promises
    from iex_promise_details pd,
    IEX_DELINQUENCIES_ALL DEL,
    iex_pop_uwq_summ_gt temp
    WHERE pd.cust_account_id = del.cust_account_id
      AND pd.delinquency_id = del.delinquency_id
      and del.party_cust_id = temp.object_id
      and del.org_id = temp.org_id
      and pd.state = 'BROKEN_PROMISE'
     group by del.party_cust_id;

    cursor c_customer_pro_summ is
    SELECT del.party_cust_id,
    COUNT(1) number_of_promises,
    SUM(amount_due_remaining) broken_promise_amount,
    SUM(promise_amount) promise_amount
    FROM iex_promise_details pd,
         iex_delinquencies_all del,
         iex_pop_uwq_summ_gt temp
   WHERE pd.cust_account_id = del.cust_account_id
     AND pd.delinquency_id = del.delinquency_id
     AND pd.status IN('COLLECTABLE','PENDING')
     AND pd.state = 'BROKEN_PROMISE'
     AND pd.amount_due_remaining > 0
     AND (del.status NOT IN('CURRENT','CLOSE')
     or (del.status='CURRENT' and  del.source_program_name='IEX_CURR_INV'))--Added for Bug 6446848 06-Jan-2009 barathsr
     and del.party_cust_id = temp.object_id
     and del.org_id = temp.org_id
   GROUP BY del.party_cust_id;
   -- Start for the bug#7562130 by PNAVEENK
   cursor c_customer_score is
   SELECT sh.score_object_id, sh.score_value score, sh.score_id, sc.score_name
     FROM iex_score_histories sh,
          iex_pop_uwq_summ_gt temp,
	  iex_scores sc
    WHERE sh.creation_date = (SELECT MAX(creation_date)
                               FROM iex_score_histories sh1
                              WHERE sh1.score_object_code = 'PARTY'
                                AND sh1.score_object_id = sh.score_object_id)
      AND sh.score_object_code = 'PARTY'
      AND sh.score_object_id = temp.object_id
      and sc.score_id = sh.score_id;
   -- end for the bug#7562130
   cursor c_customer_past_due is
   SELECT a.party_cust_id,
   SUM(b.acctd_amount_due_remaining) past_due_inv_value
   FROM iex_delinquencies_all a,
        ar_payment_schedules_all b,
        iex_pop_uwq_summ_gt temp
  WHERE a.party_cust_id = temp.object_id
    AND a.payment_schedule_id = b.payment_schedule_id
    AND b.status = 'OP'
    AND a.status IN('DELINQUENT',   'PREDELINQUENT')
    AND temp.org_id = a.org_id
   GROUP BY a.party_cust_id;

   cursor c_last_payment_no_amount is
   SELECT o_acc.party_id,
          o_summ.last_payment_number last_payment_number,
	  iex_uwq_view_pkg.convert_amount(o_summ.last_payment_amount,o_summ.currency) last_payment_amount
   FROM ar_trx_bal_summary o_summ,
        hz_cust_accounts o_acc
   WHERE o_summ.cust_account_id = o_acc.cust_account_id
   and o_acc.party_id in (select object_id from iex_pop_uwq_summ_gt)
   AND o_summ.last_payment_date =  (SELECT MAX(summ.last_payment_date)
                                    FROM ar_trx_bal_summary summ,
				         hz_cust_accounts acc
                                    WHERE acc.cust_account_id = summ.cust_account_id
				    and acc.party_id=o_acc.party_id);

   cursor c_bankruptcies is
   select bkr.party_id,
          COUNT(1) number_of_bankruptcies
   FROM iex_bankruptcies bkr
   where bkr.party_id in (select object_id from iex_pop_uwq_summ_gt)
   and NVL(BKR.DISPOSITION_CODE,'GRANTED') in ('GRANTED','NEGOTIATION')  -- Changed for bug#7693986
   group by bkr.party_id;

   -- Bug #6251657 bibeura 25-OCT-2007
   cursor c_customer_del_dln is
    select del.party_cust_id,
    sum(decode(del.status,'DELINQUENT',1,'PREDELINQUENT',1,0)) number_of_delinquencies,
    sum(decode(del.status,'DELINQUENT',ps.acctd_amount_due_remaining,'PREDELINQUENT',ps.acctd_amount_due_remaining,0)) past_due_inv_value,
    max(decode(uwq_status,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),1,1)))) pending_delinquencies,
    max(decode(uwq_status,'COMPLETE',(decode(sign(TRUNC(uwq_complete_date) + fnd_profile.VALUE('IEX_UWQ_COMPLETION_DAYS') - TRUNC(sysdate)),1,1)))) complete_delinquencies,
    max(decode(uwq_status,NULL,1,'ACTIVE',1,'PENDING',(decode(sign(TRUNC(uwq_active_date) - TRUNC(sysdate)),-1,1,0,1)))) active_delinquencies,
    del.org_id org_id
    from iex_delinquencies del,
    ar_payment_schedules ps
    WHERE del.payment_schedule_id = ps.payment_schedule_id  AND
    del.org_id = ps.org_id and
    exists(select 1 from iex_delinquencies del1
		    where del1.last_update_date>=trunc(sysdate)
		    and del.party_cust_id = del1.party_cust_id
		    and del1.org_id=del.org_id)
    group by del.party_cust_id, del.org_id;

BEGIN
	l_max_fetches := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '100000'));
	if p_mode='DLN' then
	        LogMessage(FND_LOG.LEVEL_STATEMENT,'Starting..');
		-- Start Bug #6251657 bibeura 25-OCT-2007
		BEGIN
			OPEN c_customer_del_dln;
		        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_customer_del_dln cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
	                L_PARTY_ID.delete;
	        	L_NUMBER_OF_DELINQUENCIES.delete;
	                L_PENDING_DELINQUENCIES.delete;
	        	L_COMPLETE_DELINQUENCIES.delete;
	                L_ACTIVE_DELINQUENCIES.delete;
			L_PAST_DUE_INV_VALUE.delete;
			L_ORG_ID.delete;

  	            LOOP
	                FETCH c_customer_del_dln bulk collect
	                INTO
	                L_PARTY_ID,
	                L_NUMBER_OF_DELINQUENCIES,
			L_PAST_DUE_INV_VALUE,
            	        L_PENDING_DELINQUENCIES,
	                L_COMPLETE_DELINQUENCIES,
                        L_ACTIVE_DELINQUENCIES,
			L_ORG_ID
                        limit l_max_fetches;
			IF L_PARTY_ID.COUNT = 0 THEN
				LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_customer_del_dln ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
	                        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
		                EXIT;
			ELSE

	                   forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
		             UPDATE IEX_DLN_UWQ_SUMMARY
			     SET NUMBER_OF_DELINQUENCIES = L_NUMBER_OF_DELINQUENCIES(i),
			         PAST_DUE_INV_VALUE = L_PAST_DUE_INV_VALUE(i),
	       			 ACTIVE_DELINQUENCIES    = L_ACTIVE_DELINQUENCIES(i),
				 COMPLETE_DELINQUENCIES  = L_COMPLETE_DELINQUENCIES(i),
				 PENDING_DELINQUENCIES   = L_PENDING_DELINQUENCIES(i)
			     WHERE
			     PARTY_ID = L_PARTY_ID(i)
            		     AND ORG_ID=L_ORG_ID(i);
		             LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_customer_del_dln updated ' || L_COLLECTOR_ID.count ||  ' rows ');
			     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');
	               END IF;
	            END LOOP;
	           IF c_customer_del_dln%ISOPEN THEN
		       CLOSE c_customer_del_dln;
                   END IF;

	        EXCEPTION WHEN OTHERS THEN
	         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
	        END;
		--End Bug #6251657 bibeura 25-OCT-2007

		--Begin Bug 8707923 27-Jul-2009 barathsr

               FND_FILE.PUT_LINE(FND_FILE.LOG,'delete rows from customer gt');
               delete from iex_pop_uwq_summ_gt;
		FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert into customer gt');

		insert into iex_pop_uwq_summ_gt(object_id,object_type,org_id)
		select del.party_cust_id,'PARTY',del.org_id from iex_delinquencies del,hz_party_preferences party_pref
		where del.status in ('DELINQUENT','PRE-DELINQUENT')
		             and del.party_cust_id=party_pref.party_id(+)
                             and party_pref.module(+)='COLLECTIONS'
                             and party_pref.category(+)='COLLECTIONS LEVEL'
			     and party_pref.preference_code(+)='PARTY_ID'
			     and nvl(decode(G_PARTY_LVL_ENB,'Y',party_pref.VALUE_VARCHAR2,null),G_SYSTEM_LEVEL)='CUSTOMER'
		and not exists(select 1 from IEX_DLN_UWQ_SUMMARY dus where dus.party_id=del.party_cust_id
			     and dus.cust_account_id is null and
			       dus.org_id=del.org_id)
		group by del.party_cust_id,del.org_id;
		if sql%rowcount<=0 then
			return;
			else
			FND_FILE.PUT_LINE(FND_FILE.LOG,'Inserted into customer gt-->'||sql%rowcount);
		end if;
	else
		null;
	end if;

	delete from iex_dln_uwq_summary summ
	where exists(select 1
		     from iex_pop_uwq_summ_gt gt
		     where gt.object_id=summ.party_id
		     and summ.cust_account_id is null
		     and summ.site_use_id is null
		     and gt.org_id=summ.org_id)
	and summ.business_level<>'CUSTOMER';
	LogMessage(FND_LOG.LEVEL_STATEMENT,'No. of records deleted at CUSTOMER level->' || sql%rowcount);

	commit;
          --End Bug 8707923 27-Jul-2009 barathsr
         open c_iex_customer_uwq_summary;
         loop
	 l_count := l_count +1;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'----------');
        LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bulk ' || l_count);

        L_ORG_ID.delete;
        L_COLLECTOR_ID.delete;
        L_COLLECTOR_RESOURCE_ID.delete;
        L_COLLECTOR_RES_TYPE.delete;
        L_IEU_OBJECT_FUNCTION.delete;
        L_IEU_OBJECT_PARAMETERS.delete;
        L_IEU_MEDIA_TYPE_UUID.delete;
        L_IEU_PARAM_PK_COL.delete;
        L_IEU_PARAM_PK_VALUE.delete;
        L_RESOURCE_ID.delete;
        L_RESOURCE_TYPE.delete;
        L_PARTY_ID.delete;
        L_PARTY_NAME.delete;
        L_CUST_ACCOUNT_ID.delete;
        L_ACCOUNT_NAME.delete;
        L_ACCOUNT_NUMBER.delete;
        L_SITE_USE_ID.delete;
        L_LOCATION.delete;
        L_CURRENCY.delete;
        L_OP_INVOICES_COUNT.delete;
        L_OP_DEBIT_MEMOS_COUNT.delete;
        L_OP_DEPOSITS_COUNT.delete;
        L_OP_BILLS_RECEIVABLES_COUNT.delete;
        L_OP_CHARGEBACK_COUNT.delete;
        L_OP_CREDIT_MEMOS_COUNT.delete;
        L_UNRESOLVED_CASH_COUNT.delete;
        L_DISPUTED_INV_COUNT.delete;
        L_BEST_CURRENT_RECEIVABLES.delete;
        L_OP_INVOICES_VALUE.delete;
        L_OP_DEBIT_MEMOS_VALUE.delete;
        L_OP_DEPOSITS_VALUE.delete;
        L_OP_BILLS_RECEIVABLES_VALUE.delete;
        L_OP_CHARGEBACK_VALUE.delete;
        L_OP_CREDIT_MEMOS_VALUE.delete;
        L_UNRESOLVED_CASH_VALUE.delete;
        L_RECEIPTS_AT_RISK_VALUE.delete;
        L_INV_AMT_IN_DISPUTE.delete;
        L_PENDING_ADJ_VALUE.delete;
        L_PAST_DUE_INV_VALUE.delete;
        L_PAST_DUE_INV_INST_COUNT.delete;
        L_LAST_PAYMENT_DATE.delete;
        L_LAST_PAYMENT_AMOUNT.delete;
        L_LAST_PAYMENT_AMOUNT_CURR.delete;
        L_LAST_PAYMENT_NUMBER.delete;
        L_LAST_UPDATE_DATE.delete;
        L_LAST_UPDATED_BY.delete;
        L_CREATION_DATE.delete;
        L_CREATED_BY.delete;
        L_LAST_UPDATE_LOGIN.delete;
        L_NUMBER_OF_DELINQUENCIES.delete;
        L_ACTIVE_DELINQUENCIES.delete;
        L_COMPLETE_DELINQUENCIES.delete;
        L_PENDING_DELINQUENCIES.delete;
        L_SCORE.delete;
        L_ADDRESS1.delete;
        L_CITY.delete;
        L_STATE.delete;
        L_COUNTY.delete;
        L_COUNTRY.delete;
        L_PROVINCE.delete;
        L_POSTAL_CODE.delete;
        L_PHONE_COUNTRY_CODE.delete;
        L_PHONE_AREA_CODE.delete;
        L_PHONE_NUMBER.delete;
        L_PHONE_EXTENSION.delete;
        L_NUMBER_OF_BANKRUPTCIES.delete;
        L_NUMBER_OF_PROMISES.delete;
        L_BROKEN_PROMISE_AMOUNT.delete;
        L_PROMISE_AMOUNT.delete;
        L_ACTIVE_PROMISES.delete;
        L_COMPLETE_PROMISES.delete;
        L_PENDING_PROMISES.delete;
         LogMessage(FND_LOG.LEVEL_STATEMENT,'Start fetching records...');
	 FETCH c_iex_customer_uwq_summary bulk collect
                INTO
                    L_ORG_ID,
                    L_IEU_OBJECT_FUNCTION,
                    L_IEU_OBJECT_PARAMETERS,
                    L_IEU_MEDIA_TYPE_UUID,
                    L_IEU_PARAM_PK_COL,
                    L_IEU_PARAM_PK_VALUE,
                    L_RESOURCE_ID,
                    L_RESOURCE_TYPE,
                    L_PARTY_ID,
                    L_PARTY_NAME,
                    L_CUST_ACCOUNT_ID,
                    L_ACCOUNT_NAME,
                    L_ACCOUNT_NUMBER,
                    L_SITE_USE_ID,
                    L_LOCATION,
                    L_CURRENCY,
                    L_OP_INVOICES_COUNT,
                    L_OP_DEBIT_MEMOS_COUNT,
                    L_OP_DEPOSITS_COUNT,
                    L_OP_BILLS_RECEIVABLES_COUNT,
                    L_OP_CHARGEBACK_COUNT,
                    L_OP_CREDIT_MEMOS_COUNT,
                    L_UNRESOLVED_CASH_COUNT,
                    L_DISPUTED_INV_COUNT,
                    L_BEST_CURRENT_RECEIVABLES,
                    L_OP_INVOICES_VALUE,
                    L_OP_DEBIT_MEMOS_VALUE,
                    L_OP_DEPOSITS_VALUE,
                    L_OP_BILLS_RECEIVABLES_VALUE,
                    L_OP_CHARGEBACK_VALUE,
                    L_OP_CREDIT_MEMOS_VALUE,
                    L_UNRESOLVED_CASH_VALUE,
                    L_RECEIPTS_AT_RISK_VALUE,
                    L_INV_AMT_IN_DISPUTE,
                    L_PENDING_ADJ_VALUE,
                    L_PAST_DUE_INV_INST_COUNT,
                    L_LAST_PAYMENT_DATE,
                    L_LAST_PAYMENT_AMOUNT_CURR,
                    L_LAST_UPDATE_DATE,
                    L_LAST_UPDATED_BY,
                    L_CREATION_DATE,
                    L_CREATED_BY,
                    L_LAST_UPDATE_LOGIN,
                    L_ADDRESS1,
                    L_CITY,
                    L_STATE,
                    L_COUNTY,
                    L_COUNTRY,
                    L_PROVINCE,
                    L_POSTAL_CODE
                limit l_max_fetches;

		IF L_IEU_OBJECT_FUNCTION.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

        ELSE

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Fetched  ' || L_IEU_OBJECT_FUNCTION.COUNT || ' rows.');
          LogMessage(FND_LOG.LEVEL_STATEMENT,'Inserting...');
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start inserting time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_STATEMENT,'inserting records..');
          forall i IN L_IEU_OBJECT_FUNCTION.FIRST .. L_IEU_OBJECT_FUNCTION.LAST
            INSERT INTO IEX_DLN_UWQ_SUMMARY
                (DLN_UWQ_SUMMARY_ID
                ,ORG_ID
                ,IEU_OBJECT_FUNCTION
                ,IEU_OBJECT_PARAMETERS
                ,IEU_MEDIA_TYPE_UUID
                ,IEU_PARAM_PK_COL
                ,IEU_PARAM_PK_VALUE
                ,RESOURCE_ID
                ,RESOURCE_TYPE
                ,PARTY_ID
                ,PARTY_NAME
                ,CUST_ACCOUNT_ID
                ,ACCOUNT_NAME
                ,ACCOUNT_NUMBER
                ,SITE_USE_ID
                ,LOCATION
                ,CURRENCY
                ,OP_INVOICES_COUNT
                ,OP_DEBIT_MEMOS_COUNT
                ,OP_DEPOSITS_COUNT
                ,OP_BILLS_RECEIVABLES_COUNT
                ,OP_CHARGEBACK_COUNT
                ,OP_CREDIT_MEMOS_COUNT
                ,UNRESOLVED_CASH_COUNT
                ,DISPUTED_INV_COUNT
                ,BEST_CURRENT_RECEIVABLES
                ,OP_INVOICES_VALUE
                ,OP_DEBIT_MEMOS_VALUE
                ,OP_DEPOSITS_VALUE
                ,OP_BILLS_RECEIVABLES_VALUE
                ,OP_CHARGEBACK_VALUE
                ,OP_CREDIT_MEMOS_VALUE
                ,UNRESOLVED_CASH_VALUE
                ,RECEIPTS_AT_RISK_VALUE
                ,INV_AMT_IN_DISPUTE
                ,PENDING_ADJ_VALUE
                ,PAST_DUE_INV_INST_COUNT
                ,LAST_PAYMENT_DATE
                ,LAST_PAYMENT_AMOUNT_CURR
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_LOGIN
                ,ADDRESS1
                ,CITY
                ,STATE
                ,COUNTY
                ,COUNTRY
                ,PROVINCE
                ,POSTAL_CODE
		,NUMBER_OF_DELINQUENCIES
		,NUMBER_OF_PROMISES
		,NUMBER_OF_BANKRUPTCIES
		,BUSINESS_LEVEL)  --Added for Bug 8707923 27-Jul-2009 barathsr
            VALUES
                (IEX_DLN_UWQ_SUMMARY_S.nextval,
                L_ORG_ID(i),
                L_IEU_OBJECT_FUNCTION(i),
                L_IEU_OBJECT_PARAMETERS(i),
                L_IEU_MEDIA_TYPE_UUID(i),
                L_IEU_PARAM_PK_COL(i),
                L_IEU_PARAM_PK_VALUE(i),
                L_RESOURCE_ID(i),
                L_RESOURCE_TYPE(i),
                L_PARTY_ID(i),
                L_PARTY_NAME(i),
                L_CUST_ACCOUNT_ID(i),
                L_ACCOUNT_NAME(i),
                L_ACCOUNT_NUMBER(i),
                L_SITE_USE_ID(i),
                L_LOCATION(i),
                L_CURRENCY(i),
                L_OP_INVOICES_COUNT(i),
                L_OP_DEBIT_MEMOS_COUNT(i),
                L_OP_DEPOSITS_COUNT(i),
                L_OP_BILLS_RECEIVABLES_COUNT(i),
                L_OP_CHARGEBACK_COUNT(i),
                L_OP_CREDIT_MEMOS_COUNT(i),
                L_UNRESOLVED_CASH_COUNT(i),
                L_DISPUTED_INV_COUNT(i),
                L_BEST_CURRENT_RECEIVABLES(i),
                L_OP_INVOICES_VALUE(i),
                L_OP_DEBIT_MEMOS_VALUE(i),
                L_OP_DEPOSITS_VALUE(i),
                L_OP_BILLS_RECEIVABLES_VALUE(i),
                L_OP_CHARGEBACK_VALUE(i),
                L_OP_CREDIT_MEMOS_VALUE(i),
                L_UNRESOLVED_CASH_VALUE(i),
                L_RECEIPTS_AT_RISK_VALUE(i),
                L_INV_AMT_IN_DISPUTE(i),
                L_PENDING_ADJ_VALUE(i),
                L_PAST_DUE_INV_INST_COUNT(i),
                L_LAST_PAYMENT_DATE(i),
                L_LAST_PAYMENT_AMOUNT_CURR(i),
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.CONC_LOGIN_ID,
                L_ADDRESS1(i),
                L_CITY(i),
                L_STATE(i),
                L_COUNTY(i),
                L_COUNTRY(i),
                L_PROVINCE(i),
                L_POSTAL_CODE(i),
		0,
		0,
		0,
		'CUSTOMER');  --Added for Bug 8707923 27-Jul-2009 barathsr

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End inserting time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Inserted ' || L_IEU_OBJECT_FUNCTION.COUNT || ' rows for biz lvl-->'||p_level);


          l_total := l_total + L_IEU_OBJECT_FUNCTION.COUNT;
          LogMessage(FND_LOG.LEVEL_STATEMENT,'So far processed ' || l_total || ' rows');



        END IF;

      END LOOP;
      close c_iex_customer_uwq_summary;

      OPEN c_strategy_summary;
      LOOP
          l_count := l_count +1;
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'----------');
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Bulk ' || l_count);

          L_JTF_OBJECT_ID.delete;
          L_WORK_ITEM_ID.delete;
          L_SCHEDULE_START.delete;
          L_SCHEDULE_END.delete;
          L_WORK_TYPE.delete;
          L_CATEGORY_TYPE.delete;
          L_PRIORITY_TYPE.delete;
	  L_wkitem_RESOURCE_ID.delete;
          L_STRATEGY_ID.delete;
	  L_STRATEGY_TEMPLATE_ID.delete;
	  L_WORK_ITEM_TEMPLATE_ID.delete;
	  L_STATUS_CODE.delete;
	  L_STR_STATUS.delete;  -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	  L_START_TIME.delete;
	  L_END_TIME.delete;
	  L_WORK_ITEM_ORDER.delete;
	  L_ESCALATED_YN.delete;   --Added for bug#6981126 by schekuri on 27-Jun-2008

          LogMessage(FND_LOG.LEVEL_STATEMENT,'Inited all arrays');

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          FETCH c_strategy_summary bulk collect
          INTO
            L_JTF_OBJECT_ID,
            L_WORK_ITEM_ID,
            L_SCHEDULE_START,
            L_SCHEDULE_END,
            L_CATEGORY_TYPE,
	    L_WORK_TYPE,
            L_PRIORITY_TYPE,
	    L_WKITEM_RESOURCE_ID,
	    L_STRATEGY_ID,
	    L_STRATEGY_TEMPLATE_ID,
	    L_WORK_ITEM_TEMPLATE_ID,
	    L_STATUS_CODE,
	    L_STR_STATUS,  -- Added for bug#7416344 by PNAVEENK on 2-4-2009
	    L_START_TIME,
	    L_END_TIME,
	    L_WORK_ITEM_ORDER,
	    L_ESCALATED_YN  --Added for bug#6981126 by schekuri on 27-Jun-2008
          limit l_max_fetches;

	  LogMessage(FND_LOG.LEVEL_STATEMENT,L_JTF_OBJECT_ID.COUNT);

          IF L_JTF_OBJECT_ID.COUNT = 0 THEN

            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
            CLOSE c_strategy_summary;
            EXIT;

          ELSE

            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Fetched  ' || L_JTF_OBJECT_ID.COUNT || ' rows.');
            LogMessage(FND_LOG.LEVEL_STATEMENT,' Updating table...');
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Start updating time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

               forall i IN L_JTF_OBJECT_ID.FIRST .. L_JTF_OBJECT_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                   SET WORK_ITEM_ID = L_WORK_ITEM_ID(i),
                    SCHEDULE_START = L_SCHEDULE_START(i),
                    SCHEDULE_END = L_SCHEDULE_END(i),
                    WORK_TYPE = L_WORK_TYPE(i),
                    CATEGORY_TYPE = L_CATEGORY_TYPE(i),
                    PRIORITY_TYPE = L_PRIORITY_TYPE(i),
		    WKITEM_RESOURCE_ID = L_WKITEM_RESOURCE_ID(i),
  	    	    STRATEGY_ID = L_STRATEGY_ID(i),
	    	    STRATEGY_TEMPLATE_ID = L_STRATEGY_TEMPLATE_ID(i),
		    WORK_ITEM_TEMPLATE_ID = L_WORK_ITEM_TEMPLATE_ID(i),
	            STATUS_CODE = L_STATUS_CODE(i),
		    STR_STATUS = L_STR_STATUS(i),  -- Added fro bug#7416344 by PNAVEENK on 2-4-2009
	            START_TIME = L_START_TIME(i),
	            END_TIME = L_END_TIME(i),
	            WORK_ITEM_ORDER = L_WORK_ITEM_ORDER(i),
		    WKITEM_ESCALATED_YN = L_ESCALATED_YN(i)    --Added for bug#6981126 by schekuri on 27-Jun-2008
                 WHERE party_id = L_JTF_OBJECT_ID(i);


            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Updated ' || L_JTF_OBJECT_ID.COUNT || ' rows');
            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End updating time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));

            l_total := l_total + L_JTF_OBJECT_ID.COUNT;
            LogMessage(FND_LOG.LEVEL_STATEMENT,'So far processed ' || l_total || ' rows');

          END IF;

      END LOOP;

      IF c_strategy_summary % ISOPEN THEN
        CLOSE c_strategy_summary;
      END IF;

      BEGIN
      OPEN C_COLLECTOR_PROF;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_collector_prof cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_COLLECTOR_RESOURCE_ID.delete  ;
	L_COLLECTOR_RESOURCE_NAME.delete; -- Added for the bug#7562130
	L_COLLECTOR_ID.delete;
	L_RESOURCE_TYPE.delete;
	L_PARTY_ID.delete;

      LOOP
        FETCH C_COLLECTOR_PROF bulk collect
          INTO
	    L_COLLECTOR_ID,
  	    L_COLLECTOR_RESOURCE_ID,
	    L_COLLECTOR_RESOURCE_NAME, -- Added for the bug#7562130
	    L_RESOURCE_TYPE,
	    L_PARTY_ID
          limit l_max_fetches;
      IF L_COLLECTOR_RESOURCE_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_collector_prof ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET COLLECTOR_RESOURCE_ID = L_COLLECTOR_RESOURCE_ID(i),
		        COLLECTOR_RESOURCE_NAME = L_COLLECTOR_RESOURCE_NAME(i) , -- Added for the bug#7562130
		        COLLECTOR_RES_TYPE    = L_RESOURCE_TYPE(i),
			collector_id = l_collector_id(i),
			last_update_date   = SYSDATE,
		        last_updated_by    = FND_GLOBAL.USER_ID
                   WHERE
		    party_id = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_collector_prof updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

      END IF;
      END LOOP;
       IF C_COLLECTOR_PROF % ISOPEN THEN
        CLOSE C_COLLECTOR_PROF;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Collector profile update received' || SQLERRM);
       END;

     BEGIN
       OPEN c_contact_point;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Opened Cursor  c_contact_point  cursor at time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_PARTY_ID.delete;
        L_PHONE_COUNTRY_CODE.delete;
        L_PHONE_AREA_CODE.delete;
        L_PHONE_NUMBER.delete;
        L_PHONE_EXTENSION.delete;


      LOOP
	 FETCH c_contact_point bulk collect
          INTO
	   L_PARTY_ID,
	   L_PHONE_COUNTRY_CODE,
	   L_PHONE_AREA_CODE,
	   L_PHONE_NUMBER,
	   L_PHONE_EXTENSION
          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'c_contact_point  Cursor Fetching end time:   ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

        ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST

                   UPDATE IEX_DLN_UWQ_SUMMARY
                   SET PHONE_COUNTRY_CODE = L_PHONE_COUNTRY_CODE(i),
		       PHONE_AREA_CODE    = L_PHONE_AREA_CODE(i),
		       PHONE_NUMBER       = L_PHONE_NUMBER(i),
		       PHONE_EXTENSION    = L_PHONE_EXTENSION(i),
		       last_update_date   = SYSDATE,
		       last_updated_by    = FND_GLOBAL.USER_ID
                 WHERE PARTY_ID = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_contact_point  Cursor updated ' ||L_PARTY_ID.count || ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

      END IF;
      END LOOP;
        CLOSE c_contact_point;


      EXCEPTION WHEN OTHERS THEN
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,' Contact point raised error ' || SQLERRM);
      END;
      BEGIN
      OPEN C_CUSTOMER_DEL;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_customer_del cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_PARTY_ID.delete;
	L_NUMBER_OF_DELINQUENCIES.delete;
        L_PENDING_DELINQUENCIES.delete;
	L_COMPLETE_DELINQUENCIES.delete;
        L_ACTIVE_DELINQUENCIES.delete;

      LOOP
        FETCH C_CUSTOMER_DEL bulk collect
          INTO
	    L_PARTY_ID,
  	    L_NUMBER_OF_DELINQUENCIES,
	    L_PENDING_DELINQUENCIES,
	    L_COMPLETE_DELINQUENCIES,
            L_ACTIVE_DELINQUENCIES
          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_customer_del ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET NUMBER_OF_DELINQUENCIES = L_NUMBER_OF_DELINQUENCIES(i),
		        ACTIVE_DELINQUENCIES    = L_ACTIVE_DELINQUENCIES(i),
			COMPLETE_DELINQUENCIES  = L_COMPLETE_DELINQUENCIES(i),
			PENDING_DELINQUENCIES   = L_PENDING_DELINQUENCIES(i)
                   WHERE
		    PARTY_ID = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_customer_del updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

      END IF;
      END LOOP;
       IF C_CUSTOMER_DEL % ISOPEN THEN
        CLOSE C_CUSTOMER_DEL;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_CUSTOMER_PRO;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_customer_pro cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_PARTY_ID.delete;
	L_ACTIVE_PROMISES.delete;
        L_COMPLETE_PROMISES.delete;
        L_PENDING_PROMISES.delete;

      LOOP
        FETCH C_CUSTOMER_PRO bulk collect
          INTO
	    L_PARTY_ID,
  	    L_PENDING_PROMISES,
	    L_COMPLETE_PROMISES,
	    L_ACTIVE_PROMISES
          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_customer_pro ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET ACTIVE_PROMISES    = L_ACTIVE_PROMISES(i),
			COMPLETE_PROMISES  = L_COMPLETE_PROMISES(i),
			PENDING_PROMISES   = L_PENDING_PROMISES(i)
                   WHERE
		    PARTY_ID = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_customer_pro updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

      END IF;
      END LOOP;
       IF C_CUSTOMER_PRO % ISOPEN THEN
        CLOSE C_CUSTOMER_PRO;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Promise update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_CUSTOMER_PRO_SUMM;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_customer_pro_summ cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_PARTY_ID.delete;
	L_NUMBER_OF_PROMISES.delete;
        L_BROKEN_PROMISE_AMOUNT .delete;
        L_PROMISE_AMOUNT.delete;

      LOOP
        FETCH C_CUSTOMER_PRO_SUMM bulk collect
          INTO
	    L_PARTY_ID,
  	    L_NUMBER_OF_PROMISES,
	    L_BROKEN_PROMISE_AMOUNT,
	    L_PROMISE_AMOUNT
          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_customer_pro_summ ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET NUMBER_OF_PROMISES     = L_NUMBER_OF_PROMISES(i),
			BROKEN_PROMISE_AMOUNT  = L_BROKEN_PROMISE_AMOUNT(i),
			PROMISE_AMOUNT         = L_PROMISE_AMOUNT(i)
                   WHERE
		    PARTY_ID = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_customer_pro_summ updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

      END IF;
      END LOOP;
       IF C_CUSTOMER_PRO_SUMM % ISOPEN THEN
        CLOSE C_CUSTOMER_PRO_SUMM;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Broken Promise update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_CUSTOMER_SCORE;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_customer_score cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_PARTY_ID.delete;
	L_SCORE.delete;
	L_SCORE_ID.delete;  -- Added for the bug#7562130
        L_SCORE_NAME.delete; -- Added for the bug#7562130

      LOOP
        FETCH C_CUSTOMER_SCORE bulk collect
          INTO
	    L_PARTY_ID,
  	    L_SCORE,
	    L_SCORE_ID,  -- Added for the bug#7562130
	    L_SCORE_NAME  -- Added for the bug#7562130
          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_customer_score ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET SCORE     = L_SCORE(i),
		        SCORE_ID = L_SCORE_ID(i),  -- Added for the bug#7562130
			SCORE_NAME = L_SCORE_NAME(i) -- Added for the bug#7562130
                   WHERE
		    PARTY_ID = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_customer_score updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

      END IF;
      END LOOP;
       IF C_CUSTOMER_SCORE % ISOPEN THEN
        CLOSE C_CUSTOMER_SCORE;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Score update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_CUSTOMER_PAST_DUE;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_customer_past_due cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_PARTY_ID.delete;
	L_PAST_DUE_INV_VALUE.delete;

      LOOP
        FETCH C_CUSTOMER_PAST_DUE bulk collect
          INTO
	    L_PARTY_ID,
  	    L_PAST_DUE_INV_VALUE
          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_customer_past_due ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET PAST_DUE_INV_VALUE     = L_PAST_DUE_INV_VALUE(i)
                   WHERE
		    PARTY_ID = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_customer_past_due updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

      END IF;
      END LOOP;
       IF C_CUSTOMER_PAST_DUE % ISOPEN THEN
        CLOSE C_CUSTOMER_PAST_DUE;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Past due invoice update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_LAST_PAYMENT_NO_AMOUNT;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_last_payment_no_amount cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_PARTY_ID.delete;
        L_LAST_PAYMENT_NUMBER.delete;
	L_LAST_PAYMENT_AMOUNT.delete;

      LOOP
        FETCH C_LAST_PAYMENT_NO_AMOUNT bulk collect
          INTO
	    L_PARTY_ID,
  	    L_LAST_PAYMENT_NUMBER,
	    L_LAST_PAYMENT_AMOUNT
          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_last_payment_no_amount ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET LAST_PAYMENT_NUMBER     = L_LAST_PAYMENT_NUMBER(i),
		        LAST_PAYMENT_AMOUNT     = L_LAST_PAYMENT_AMOUNT(i)
                   WHERE
		    PARTY_ID = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_last_payment_no_amount updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

      END IF;
      END LOOP;
       IF C_LAST_PAYMENT_NO_AMOUNT % ISOPEN THEN
        CLOSE C_LAST_PAYMENT_NO_AMOUNT;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Last payment no and amount update received' || SQLERRM);
       END;

      BEGIN
      OPEN C_BANKRUPTCIES;
       LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Open c_bankruptcies cursor time: ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
        L_PARTY_ID.delete;
        L_NUMBER_OF_BANKRUPTCIES.delete;

      LOOP
        FETCH C_BANKRUPTCIES bulk collect
          INTO
	    L_PARTY_ID,
  	    L_NUMBER_OF_BANKRUPTCIES
          limit l_max_fetches;
      IF L_PARTY_ID.COUNT = 0 THEN

          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'End fetching time: c_bankruptcies ' || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'));
          LogMessage(FND_LOG.LEVEL_UNEXPECTED,'No records found - processing complete. Exiting the loop');
          EXIT;

       ELSE

        forall i IN L_PARTY_ID.FIRST .. L_PARTY_ID.LAST
                   UPDATE IEX_DLN_UWQ_SUMMARY
                    SET NUMBER_OF_BANKRUPTCIES     = L_NUMBER_OF_BANKRUPTCIES(i)
                   WHERE
		    PARTY_ID = L_PARTY_ID(i);
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,' c_bankruptcies updated ' || L_COLLECTOR_ID.count ||  ' rows ');
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'------------------------');

      END IF;
      END LOOP;
       IF C_BANKRUPTCIES % ISOPEN THEN
        CLOSE C_BANKRUPTCIES;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Last payment no and amount update received' || SQLERRM);
       END;
      --gnramasa
COMMIT;
LogMessage(FND_LOG.LEVEL_STATEMENT,'Commited');

EXCEPTION
WHEN OTHERS THEN
LogMessage(FND_LOG.LEVEL_STATEMENT,sqlerrm);
END CUSTOMER_REFRESH_SUMMARY_INCR;

PROCEDURE refresh_summary_incr(
                    x_errbuf            OUT nocopy VARCHAR2,
                    x_retcode           OUT nocopy VARCHAR2,
                    FROM_DATE           IN  VARCHAR2,
 	            P_MODE              IN  VARCHAR2 DEFAULT 'CP') is

 --Begin Bug 8707923 27-Jul-2009 barathsr
  l_level varchar2(20);
  l_org_id number;
  l_curr_org_id number;
  l_allowed_level varchar2(20);

   CURSOR c_get_level(c_org_id number) IS
   SELECT PREFERENCE_VALUE
   FROM IEX_APP_PREFERENCES_B
   WHERE PREFERENCE_NAME = 'COLLECTIONS STRATEGY LEVEL'
   and (org_id=c_org_id or org_id is null)
   and enabled_flag='Y'
   order by nvl(org_id,0) desc ;

CURSOR c_allowed_levels IS
SELECT LOOKUP_CODE
FROM IEX_LOOKUPS_V
WHERE LOOKUP_TYPE='IEX_RUNNING_LEVEL'
AND iex_utilities.validate_running_level(LOOKUP_CODE)='Y';

CURSOR c_org(c_org_id number) IS
    SELECT organization_id from hr_operating_units where
      mo_global.check_access(organization_id) = 'Y'
      AND organization_id = nvl(c_org_id,organization_id);

BEGIN

IEX_CHECKLIST_UTILITY.UPDATE_MLSETUP;


select DEFINE_PARTY_RUNNING_LEVEL,DEFINE_OU_RUNNING_LEVEL
into G_PARTY_LVL_ENB,G_OU_LVL_ENB
from IEX_QUESTIONNAIRE_ITEMS;

 FND_FILE.PUT_LINE(FND_FILE.LOG,'g_ou_lvl_enb-->'||g_ou_lvl_enb);
 FND_FILE.PUT_LINE(FND_FILE.LOG,'g_party_lvl_enb-->'||g_party_lvl_enb);



if (G_OU_LVL_ENB='Y' or G_PARTY_LVL_ENB='Y') then
          if G_OU_LVL_ENB='Y' then
		  MO_GLOBAL.INIT('IEX');
		--l_org_id:=mo_global.get_current_org_id;
		select org_id
		into l_org_id
		from fnd_concurrent_requests
		where request_id=FND_GLOBAL.CONC_REQUEST_ID;

		if l_org_id is null then
		     MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);      -- Multi Org.
		     FND_FILE.PUT_LINE(FND_FILE.LOG, 'MO: Operating Unit=' || 'All');
		     --open c_org(l_org_id);
		else
		   MO_GLOBAL.SET_POLICY_CONTEXT('S',l_ORG_ID);
		end if;
	     for i in c_org(l_org_id) loop
		l_curr_org_id:=i.organization_id;
		 MO_GLOBAL.SET_POLICY_CONTEXT('S',l_curr_org_id );
               FND_FILE.PUT_LINE(FND_FILE.LOG,'into OU level');
	       FND_FILE.PUT_LINE(FND_FILE.LOG,'into OU level-->'||l_curr_org_id);
	       open c_get_level(l_curr_org_id);
	       fetch c_get_level into G_SYSTEM_LEVEL;
	       close c_get_level;
	         FND_FILE.PUT_LINE(FND_FILE.LOG, 'OU lvl is-->'||G_SYSTEM_LEVEL);

	       for r_allowed_levels in c_allowed_levels loop
	       l_allowed_level:=r_allowed_LEVELS.lookup_code;
	       FND_FILE.PUT_LINE(FND_FILE.LOG,'looping for other levels in ou-->'||r_allowed_LEVELS.lookup_code);
                if (g_party_lvl_enb='N' and l_allowed_level=g_system_level) or g_party_lvl_enb='Y' then
                 IF l_allowed_level = 'CUSTOMER' THEN

		 FND_FILE.PUT_LINE(FND_FILE.LOG, 'call customer cursor for lvl enb at OU-->'||l_allowed_level);

	                customer_refresh_summary_incr(x_errbuf,
	                                              x_retcode,
				                     from_date,
				                     p_mode,
						     l_allowed_level);
	 --Begin Bug 8823567 22-Oct-2009 barathsr
	  IF nvl(fnd_profile.value('IEX_SHOW_NET_BAL_IN_UWQ'), 'N') = 'Y' then
             calculate_net_balance(l_allowed_level,from_date,l_curr_org_id);
	  end if;
         --End Bug 8823567 22-Oct-2009 barathsr

	         ELSIF l_allowed_level = 'ACCOUNT' THEN
		 FND_FILE.PUT_LINE(FND_FILE.LOG, 'call account cursor for lvl enb at OU-->'||l_allowed_level);
                        account_refresh_summary_incr(x_errbuf,
						    x_retcode,
						    from_date,
						    p_mode,
						    l_allowed_level);
	 --Begin Bug 8823567 22-Oct-2009 barathsr
	  IF nvl(fnd_profile.value('IEX_SHOW_NET_BAL_IN_UWQ'), 'N') = 'Y' then
             calculate_net_balance(l_allowed_level,from_date,l_curr_org_id);
	   end if;
         --End Bug 8823567 22-Oct-2009 barathsr
                 ELSIF l_allowed_level = 'BILL_TO' THEN
		 FND_FILE.PUT_LINE(FND_FILE.LOG, 'call billto cursor for lvl enb at OU-->'||l_allowed_level);
			billto_refresh_summary_incr(x_errbuf,
						    x_retcode,
						    from_date,
						    p_mode,
						    l_allowed_level);
		     --Begin Bug 8823567 22-Oct-2009 barathsr
	     IF nvl(fnd_profile.value('IEX_SHOW_NET_BAL_IN_UWQ'), 'N') = 'Y' then
             calculate_net_balance(l_allowed_level,from_date,l_curr_org_id);
	     end if;
         --End Bug 8823567 22-Oct-2009 barathsr
	         ELSE
	            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency level is not implemented at this time. Exiting.');
	             return;
		 end if;
		 end if;
		  FND_FILE.PUT_LINE(FND_FILE.LOG, 'end of allowed level loop');
	       end loop;
	       FND_FILE.PUT_LINE(FND_FILE.LOG, 'end of org_id loop');
	       end loop;

          elsif G_PARTY_LVL_ENB='Y' then
	     FND_FILE.PUT_LINE(FND_FILE.LOG,'inside party level');
                open c_get_level(null);
	        fetch c_get_level into G_SYSTEM_LEVEL;
		close c_get_level;
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'party lvl is-->'||G_SYSTEM_LEVEL);
		for r_allowed_levels in c_allowed_levels loop
		 l_allowed_level:=r_allowed_LEVELS.lookup_code;
		 FND_FILE.PUT_LINE(FND_FILE.LOG,'looping for other levels in party-->'||r_allowed_LEVELS.lookup_code);
		 IF l_allowed_level = 'CUSTOMER' THEN
		 FND_FILE.PUT_LINE(FND_FILE.LOG, 'call customer cursor for lvl enb at party-->'||l_allowed_level);
	                customer_refresh_summary_incr(x_errbuf,
	                                              x_retcode,
				                     from_date,
				                     p_mode,
						     l_allowed_level);
	  --Begin Bug 8823567 22-Oct-2009 barathsr
	   IF nvl(fnd_profile.value('IEX_SHOW_NET_BAL_IN_UWQ'), 'N') = 'Y' then
             calculate_net_balance(l_allowed_level,from_date,null);
	   end if;
         --End Bug 8823567 22-Oct-2009 barathsr

	         ELSIF l_allowed_level = 'ACCOUNT' THEN
		 FND_FILE.PUT_LINE(FND_FILE.LOG, 'call account cursor for lvl enb at party-->'||l_allowed_level);
                        account_refresh_summary_incr(x_errbuf,
						    x_retcode,
						    from_date,
						    p_mode,
						    l_allowed_level);
	   --Begin Bug 8823567 22-Oct-2009 barathsr
	    IF nvl(fnd_profile.value('IEX_SHOW_NET_BAL_IN_UWQ'), 'N') = 'Y' then
             calculate_net_balance(l_allowed_level,from_date,null);
	    end if;
         --End Bug 8823567 22-Oct-2009 barathsr
                 ELSIF l_allowed_level = 'BILL_TO' THEN
		 FND_FILE.PUT_LINE(FND_FILE.LOG, 'call billto cursor for lvl enb at party-->'||l_allowed_level);
			billto_refresh_summary_incr(x_errbuf,
						    x_retcode,
						    from_date,
						    p_mode,
						    l_allowed_level);
	      --Begin Bug 8823567 22-Oct-2009 barathsr
	      IF nvl(fnd_profile.value('IEX_SHOW_NET_BAL_IN_UWQ'), 'N') = 'Y' then
             calculate_net_balance(l_allowed_level,from_date,null);
	     end if;
         --End Bug 8823567 22-Oct-2009 barathsr
		 ELSE
	            LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency level is not implemented at this time. Exiting.');
	             return;
		end if;
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'end of allowed level loop');
		end loop;

	end if;

   else
           open c_get_level(null);
	   fetch c_get_level into G_SYSTEM_LEVEL;
	   FND_FILE.PUT_LINE(FND_FILE.LOG,'inside system level-->'||G_SYSTEM_LEVEL);
	 --  l_allowed_level:=G_SYSTEM_LEVEL;
	   IF G_SYSTEM_LEVEL= 'CUSTOMER' THEN
	   FND_FILE.PUT_LINE(FND_FILE.LOG, 'call customer cursor for lvl enb at system-->'||G_SYSTEM_LEVEL);
	                customer_refresh_summary_incr(x_errbuf,
	                                              x_retcode,
				                     from_date,
				                     p_mode,
						     G_SYSTEM_LEVEL);
		 --Begin Bug 8823567 22-Oct-2009 barathsr
	 IF nvl(fnd_profile.value('IEX_SHOW_NET_BAL_IN_UWQ'), 'N') = 'Y' then
             calculate_net_balance(G_SYSTEM_LEVEL,from_date,null);
	 end if;
         --End Bug 8823567 22-Oct-2009 barathsr

	   ELSIF G_SYSTEM_LEVEL = 'ACCOUNT' THEN
	    FND_FILE.PUT_LINE(FND_FILE.LOG, 'call account cursor for lvl enb at system-->'||G_SYSTEM_LEVEL);
                        account_refresh_summary_incr(x_errbuf,
						    x_retcode,
						    from_date,
						    p_mode,
						    G_SYSTEM_LEVEL);
		 --Begin Bug 8823567 22-Oct-2009 barathsr
	     IF nvl(fnd_profile.value('IEX_SHOW_NET_BAL_IN_UWQ'), 'N') = 'Y' then
             calculate_net_balance(G_SYSTEM_LEVEL,from_date,null);
	     end if;
         --End Bug 8823567 22-Oct-2009 barathsr

           ELSIF G_SYSTEM_LEVEL = 'BILL_TO' THEN
	    FND_FILE.PUT_LINE(FND_FILE.LOG, 'call billto cursor for lvl enb at system-->'||G_SYSTEM_LEVEL);
			billto_refresh_summary_incr(x_errbuf,
						    x_retcode,
						    from_date,
						    p_mode,
						    G_SYSTEM_LEVEL);

		 --Begin Bug 8823567 22-Oct-2009 barathsr
             IF nvl(fnd_profile.value('IEX_SHOW_NET_BAL_IN_UWQ'), 'N') = 'Y' then
             calculate_net_balance(G_SYSTEM_LEVEL,from_date,null);
	     end if;
         --End Bug 8823567 22-Oct-2009 barathsr
	   ELSE
	     LogMessage(FND_LOG.LEVEL_UNEXPECTED,'Delinquency level is not implemented at this time. Exiting.');
	     return;
	   end if;
	   close c_get_level;
  end if;

    FND_FILE.PUT_LINE(FND_FILE.LOG, 'end of a level');

EXCEPTION
WHEN OTHERS THEN
LogMessage(FND_LOG.LEVEL_STATEMENT,sqlerrm);
END;
--End Bug 8707923 27-Jul-2009 barathsr
-- Start PNAVEENK for bug#7662453 on 22-12-2008
-- This procedure will be called whenever "IEX: Populate UWQ Summary Table" cp runs.
-- This Procedure updates the IEX_DLN_UWQ_SUMMARY table aging columns with values calculated using IEX_AGING_BUCKETS_PKG package.
-- The package IEX_AGING_BUCKETS_PKG calculates aging summary on current values respective to PARTY/ACCOUNT/BILLTO.
-- Start PNAVEENK for bug#7662453 on 22-12-2008
PROCEDURE populate_aging_info(p_fmode varchar2, p_from_date date,p_org_id number)--Added for Bug 8707923 27-Jul-2009 barathsr
IS

  l_default_bucket                            varchar2(100);
  l_default_bucket_id                         number;
  l_max_fetches                               NUMBER;
  l_bucket_lines_tbl	IEX_AGING_BUCKETS_PKG.bucket_Lines_Tbl;

  type l_aging_tbl_type is table of number  Index By Binary_Integer;
  l_amount1 l_aging_tbl_type;
  l_count1 l_aging_tbl_type;
  l_amount2 l_aging_tbl_type;
  l_count2 l_aging_tbl_type;
  l_amount3 l_aging_tbl_type;
  l_count3 l_aging_tbl_type;
  l_amount4 l_aging_tbl_type;
  l_count4 l_aging_tbl_type;
  l_amount5 l_aging_tbl_type;
  l_count5 l_aging_tbl_type;
  l_amount6 l_aging_tbl_type;
  l_count6 l_aging_tbl_type;
  l_amount7 l_aging_tbl_type;
  l_count7 l_aging_tbl_type;
  l_IEU_PARAM_PK_VALUE l_aging_tbl_type;
  l_org_id l_aging_tbl_type;
  -- start for bug 8924594 PNAVEENK
  l_party_id l_aging_tbl_type;
  l_cust_account_id l_aging_tbl_type;
  l_site_use_id l_aging_tbl_type;
  -- end for bug 8924594
  var1 varchar2(30);
  var2 number;
  var3 varchar2(30);
  k number;
  j number;

  --Begin Bug 8707923 27-Jul-2009 barathsr
  CURSOR C_ORGS IS
  select distinct org_id
  from iex_dln_uwq_summary
  where org_id=nvl(p_org_id,org_id);
  --End Bug 8707923 27-Jul-2009 barathsr

  CURSOR c_aging_summary(p_org_id number) IS
  select ieu_param_pk_value , party_id, cust_account_id , site_use_id
  FROM iex_dln_uwq_summary
  where org_id=p_org_id
--  AND last_update_date >= nvl( p_from_date, last_update_date);
  AND last_update_date >= trunc(sysdate);


  Begin

  l_max_fetches := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '100000'));
  l_default_bucket := fnd_profile.value('IEX_COLLECTIONS_BUCKET_NAME') ;
  select aging_bucket_id into l_default_bucket_id from ar_aging_buckets where bucket_name = l_default_bucket;

    -- Loop runs for each operating unit once and each time loops for all IEU_PARAM_PK_VALUE values
    for r_org in c_orgs loop

		mo_global.set_policy_context('S',r_org.org_id);
		j := 1;
		for r_aging in c_aging_summary(r_org.org_id) loop

                             IEX_AGING_BUCKETS_PKG.QUERY_AGING_LINES(p_api_version      => 1.0,
                                                              p_init_msg_list    => 'T',
                                                              p_commit           => 'F',
                                                              p_validation_level => 100,
                                                                x_return_status    => var1,
                                                                x_msg_count        => var2,
                                                                x_msg_data         => var3,
                                                                p_filter_mode      => p_fmode,
	                                                        p_filter_id        => r_aging.IEU_PARAM_PK_VALUE,
                                                                p_customer_site_use_id=> NULL,
                                                                p_bucket_id        => l_default_bucket_id,
                                                                p_credit_option    => 'AGE',
                                                                p_using_paying_rel => 'N',
                                                                x_bucket_lines_tbl => l_bucket_lines_tbl);

                               k := l_bucket_lines_tbl.count;

                              while k < 8
                              loop
                                 l_bucket_lines_tbl(k).amount := null;
                                 l_bucket_lines_tbl(k).invoice_count :=null;
                                 l_bucket_lines_tbl(k).dm_count :=null;
				 l_bucket_lines_tbl(k).cb_count := null;
                                 l_bucket_lines_tbl(k).consolidated_invoices :=null;
                                 k := k + 1;
                              end loop;
                      l_amount1(j) := l_bucket_lines_tbl(1).amount;
                      l_count1(j) := l_bucket_lines_tbl(1).invoice_count+l_bucket_lines_tbl(1).dm_count+l_bucket_lines_tbl(1).cb_count+l_bucket_lines_tbl(1).consolidated_invoices;
                      l_amount2(j) := l_bucket_lines_tbl(2).amount;
                      l_count2(j) := l_bucket_lines_tbl(2).invoice_count+l_bucket_lines_tbl(2).dm_count+l_bucket_lines_tbl(2).cb_count+l_bucket_lines_tbl(2).consolidated_invoices;
                      l_amount3(j) := l_bucket_lines_tbl(3).amount;
                      l_count3(j) := l_bucket_lines_tbl(3).invoice_count+l_bucket_lines_tbl(3).dm_count+l_bucket_lines_tbl(3).cb_count+l_bucket_lines_tbl(3).consolidated_invoices;
                      l_amount4(j) := l_bucket_lines_tbl(4).amount;
                      l_count4(j) := l_bucket_lines_tbl(4).invoice_count+l_bucket_lines_tbl(4).dm_count+l_bucket_lines_tbl(4).cb_count+l_bucket_lines_tbl(4).consolidated_invoices;
                      l_amount5(j) := l_bucket_lines_tbl(5).amount;
                      l_count5(j) := l_bucket_lines_tbl(5).invoice_count+l_bucket_lines_tbl(5).dm_count+l_bucket_lines_tbl(5).cb_count+l_bucket_lines_tbl(5).consolidated_invoices;
                      l_amount6(j) := l_bucket_lines_tbl(6).amount;
                      l_count6(j) := l_bucket_lines_tbl(6).invoice_count+l_bucket_lines_tbl(6).dm_count+l_bucket_lines_tbl(6).cb_count+l_bucket_lines_tbl(6).consolidated_invoices;
                      l_amount7(j) := l_bucket_lines_tbl(7).amount;
                      l_count7(j) := l_bucket_lines_tbl(7).invoice_count+l_bucket_lines_tbl(7).dm_count+l_bucket_lines_tbl(7).cb_count+l_bucket_lines_tbl(7).consolidated_invoices;
                      l_IEU_PARAM_PK_VALUE(j) := r_aging.IEU_PARAM_PK_VALUE;
                      l_org_id(j) := r_org.org_id;

		      -- start for bug 8924594 PNAVEENK
		      l_party_id(j) := r_aging.party_id;
                      l_cust_account_id(j) := r_aging.cust_account_id;
                      l_site_use_id(j) := r_aging.site_use_id;
		      -- end for bug 8924594

                      if j = l_max_fetches then

		      if p_fmode = 'PARTY' then

                      forall n in l_amount1.FIRST .. l_amount1.LAST
                                update IEX_DLN_UWQ_SUMMARY set
                                AGING_amount1 = nvl(l_amount1(n),0),
                                AGING_COUNT1  = nvl(l_count1(n),0),
                                AGING_amount2 = nvl(l_amount2(n),0),
                                AGING_COUNT2  = nvl(l_count2(n),0),
                                AGING_amount3 = nvl(l_amount3(n),0),
                                AGING_COUNT3  = nvl(l_count3(n),0),
                                AGING_amount4 = nvl(l_amount4(n),0),
                                AGING_COUNT4  = nvl(l_count4(n),0),
                                AGING_amount5 = nvl(l_amount5(n),0),
                                AGING_COUNT5  = nvl(l_count5(n),0),
                                AGING_amount6 = nvl(l_amount6(n),0),
                                AGING_COUNT6  = nvl(l_count6(n),0),
                                AGING_amount7 = nvl(l_amount7(n),0),
                                AGING_COUNT7 = nvl(l_count7(n),0)
                                where party_id = l_party_id(n)
                                and cust_account_id is null
				and site_use_id is null
                                AND org_id = l_org_id(n);
                      elsif p_fmode = 'CUST' then
		                 forall n in l_amount1.FIRST .. l_amount1.LAST
		                 update IEX_DLN_UWQ_SUMMARY set
                                AGING_amount1 = nvl(l_amount1(n),0),
                                AGING_COUNT1  = nvl(l_count1(n),0),
                                AGING_amount2 = nvl(l_amount2(n),0),
                                AGING_COUNT2  = nvl(l_count2(n),0),
                                AGING_amount3 = nvl(l_amount3(n),0),
                                AGING_COUNT3  = nvl(l_count3(n),0),
                                AGING_amount4 = nvl(l_amount4(n),0),
                                AGING_COUNT4  = nvl(l_count4(n),0),
                                AGING_amount5 = nvl(l_amount5(n),0),
                                AGING_COUNT5  = nvl(l_count5(n),0),
                                AGING_amount6 = nvl(l_amount6(n),0),
                                AGING_COUNT6  = nvl(l_count6(n),0),
                                AGING_amount7 = nvl(l_amount7(n),0),
                                AGING_COUNT7 = nvl(l_count7(n),0)
                                where party_id = l_party_id(n)
                                and  cust_account_id = l_cust_account_id(n)
				and site_use_id is null
                                AND org_id = l_org_id(n);
		    else
		         forall n in l_amount1.FIRST .. l_amount1.LAST
				update IEX_DLN_UWQ_SUMMARY set
                                AGING_amount1 = nvl(l_amount1(n),0),
                                AGING_COUNT1  = nvl(l_count1(n),0),
                                AGING_amount2 = nvl(l_amount2(n),0),
                                AGING_COUNT2  = nvl(l_count2(n),0),
                                AGING_amount3 = nvl(l_amount3(n),0),
                                AGING_COUNT3  = nvl(l_count3(n),0),
                                AGING_amount4 = nvl(l_amount4(n),0),
                                AGING_COUNT4  = nvl(l_count4(n),0),
                                AGING_amount5 = nvl(l_amount5(n),0),
                                AGING_COUNT5  = nvl(l_count5(n),0),
                                AGING_amount6 = nvl(l_amount6(n),0),
                                AGING_COUNT6  = nvl(l_count6(n),0),
                                AGING_amount7 = nvl(l_amount7(n),0),
                                AGING_COUNT7 = nvl(l_count7(n),0)
                                where party_id = l_party_id(n)
                                and  cust_account_id = l_cust_account_id(n)
                                and  site_use_id = l_site_use_id(n)
				AND org_id = l_org_id(n);
		    end if;

                      j := 0;
                      l_amount1.DELETE;
                      l_count1.DELETE;
                      l_amount2.DELETE;
                      l_count2.DELETE;
                      l_amount3.DELETE;
                      l_count3.DELETE;
                      l_amount4.DELETE;
                      l_count4.DELETE;
                      l_amount5.DELETE;
                      l_count5.DELETE;
                      l_amount6.DELETE;
                      l_count6.DELETE;
                      l_amount7.DELETE;
                      l_count7.DELETE;
                      l_IEU_PARAM_PK_VALUE.DELETE;
                      l_org_id.DELETE;

		      -- start for bug 8924594 PNAVEENK
		      l_party_id.DELETE;
                      l_cust_account_id.DELETE;
                      l_site_use_id.DELETE;
		      -- end for bug 8924594

                      end if;


                      j := j + 1;
                      l_bucket_lines_tbl.DELETE;
               end loop; --r_aging
            if l_amount1.count> 0  then
                 j :=1;
                  if p_fmode = 'PARTY' then
                  forall n in l_amount1.FIRST .. l_amount1.LAST
                                update IEX_DLN_UWQ_SUMMARY set
                                AGING_amount1 = nvl(l_amount1(n),0),
                                AGING_COUNT1  = nvl(l_count1(n),0),
                                AGING_amount2 = nvl(l_amount2(n),0),
                                AGING_COUNT2  = nvl(l_count2(n),0),
                                AGING_amount3 = nvl(l_amount3(n),0),
                                AGING_COUNT3  = nvl(l_count3(n),0),
                                AGING_amount4 = nvl(l_amount4(n),0),
                                AGING_COUNT4  = nvl(l_count4(n),0),
                                AGING_amount5 = nvl(l_amount5(n),0),
                                AGING_COUNT5  = nvl(l_count5(n),0),
                                AGING_amount6 = nvl(l_amount6(n),0),
                                AGING_COUNT6  = nvl(l_count6(n),0),
				AGING_amount7 = nvl(l_amount7(n),0),
                                AGING_COUNT7  = nvl(l_count7(n),0)
                                where party_id = l_party_id(n)
                                and cust_account_id is null
				and site_use_id is null
                                AND org_id = l_org_id(n);

		elsif p_fmode = 'CUST' then
		   forall n in l_amount1.FIRST .. l_amount1.LAST
		                 update IEX_DLN_UWQ_SUMMARY set
                                AGING_amount1 = nvl(l_amount1(n),0),
                                AGING_COUNT1  = nvl(l_count1(n),0),
                                AGING_amount2 = nvl(l_amount2(n),0),
                                AGING_COUNT2  = nvl(l_count2(n),0),
                                AGING_amount3 = nvl(l_amount3(n),0),
                                AGING_COUNT3  = nvl(l_count3(n),0),
                                AGING_amount4 = nvl(l_amount4(n),0),
                                AGING_COUNT4  = nvl(l_count4(n),0),
                                AGING_amount5 = nvl(l_amount5(n),0),
                                AGING_COUNT5  = nvl(l_count5(n),0),
                                AGING_amount6 = nvl(l_amount6(n),0),
                                AGING_COUNT6  = nvl(l_count6(n),0),
                                AGING_amount7 = nvl(l_amount7(n),0),
                                AGING_COUNT7 = nvl(l_count7(n),0)
                                where party_id = l_party_id(n)
                                and  cust_account_id = l_cust_account_id(n)
				and site_use_id is null
                                AND org_id = l_org_id(n);
		    else
		     forall n in l_amount1.FIRST .. l_amount1.LAST
		                update IEX_DLN_UWQ_SUMMARY set
                                AGING_amount1 = nvl(l_amount1(n),0),
                                AGING_COUNT1  = nvl(l_count1(n),0),
                                AGING_amount2 = nvl(l_amount2(n),0),
                                AGING_COUNT2  = nvl(l_count2(n),0),
                                AGING_amount3 = nvl(l_amount3(n),0),
                                AGING_COUNT3  = nvl(l_count3(n),0),
                                AGING_amount4 = nvl(l_amount4(n),0),
                                AGING_COUNT4  = nvl(l_count4(n),0),
                                AGING_amount5 = nvl(l_amount5(n),0),
                                AGING_COUNT5  = nvl(l_count5(n),0),
                                AGING_amount6 = nvl(l_amount6(n),0),
                                AGING_COUNT6  = nvl(l_count6(n),0),
                                AGING_amount7 = nvl(l_amount7(n),0),
                                AGING_COUNT7 = nvl(l_count7(n),0)
                                where party_id = l_party_id(n)
                                and  cust_account_id = l_cust_account_id(n)
                                and  site_use_id = l_site_use_id(n)
				AND org_id = l_org_id(n);
		    end if;


            end if;
      end loop; --r_org




  EXCEPTION
  WHEN OTHERS THEN
  LogMessage(FND_LOG.LEVEL_STATEMENT,sqlerrm);

END populate_aging_info;
-- End for bug#7662453 by PNAVEENK
-- Start for the bug#7562130 by PNAVEENK
function cal_score(p_object_id number, p_object_type varchar2, p_select_column varchar2) return varchar2 is
cursor c_score (p_object_id number , p_object_type varchar2) is
SELECT a.score_value, a.score_id, b.score_name
FROM iex_score_histories a, iex_scores b
           WHERE a.creation_date =
              (SELECT MAX(creation_date)
               FROM iex_score_histories
               WHERE score_object_code = p_object_type
               AND score_object_id = p_object_id)
           AND rownum < 2
           AND a.score_object_code = p_object_type
           AND a.score_object_id = p_object_id
           and a.score_id = b.score_id;

Begin
   If p_object_id = g_object_id and p_object_type = g_object_type then
      null;
   else
      g_object_id := p_object_id;
      g_object_type := p_object_type;
      open c_score (g_object_id, g_object_type);
      fetch c_score into g_score_value,g_score_id,g_score_name;
      close c_score;
   end if;
    if p_select_column = 'SCORE_VALUE' then
        return to_char(g_score_value);
    elsif p_select_column = 'SCORE_ID' then
         return to_char(g_score_id);
    else
         return g_score_name;
    end if;

End cal_score;
-- end for the bug#7562130
-- Start for bug#8261043 by PNAVEENK
-- Procedure updates contracts and case columns in IEX_DLN_UWQ_SUMMARY table

Procedure populate_contracts_info IS
  CURSOR C_ORGS IS
  select distinct org_id
  from iex_dln_uwq_summary;

  CURSOR c_contract_summary(p_org_id number) IS
  select party_id
  FROM iex_dln_uwq_summary
  where last_update_date >= trunc(sysdate)
  and org_id= p_org_id;
  type l_count is table of number index by binary_integer;
  l_cases_count l_count;
  l_del_cases_count l_count;
  l_contracts_count l_count;
  l_del_contracts_count l_count;
  l_party_id l_count;
  l_org_id l_count;
  l_max_fetches number;
  temp number;
 Begin
    l_max_fetches := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '100000'));
  for r_org in c_orgs loop
           temp := 1;
       for r_contract in c_contract_summary(r_org.org_id) loop
       select count(*) into l_cases_count(temp) from iex_cases_all_b where party_id=r_contract.party_id and org_id=r_org.org_id;
       select count(*) into l_del_cases_count(temp) from iex_cases_all_b where party_id=r_contract.party_id  and org_id=r_org.org_id and status_code='DELINQUENT';
       select count(*) into l_contracts_count(temp) from iex_case_objects where cas_id in (select cas_id from iex_cases_all_b where party_id=r_contract.party_id and org_id = r_org.org_id);
       select count(*) into l_del_contracts_count(temp) from iex_case_objects where delinquency_status='DELINQUENT' and cas_id in (select cas_id from iex_cases_all_b where party_id=r_contract.party_id and org_id=r_org.org_id );
       l_party_id(temp) := r_contract.party_id;
       l_org_id(temp) := r_org.org_id;
       temp := temp+1;

       if temp = l_max_fetches then
       forall i in l_cases_count.FIRST .. l_cases_count.LAST
         update iex_dln_uwq_summary set
         cases_count = nvl(l_cases_count(i),0),
         del_cases_count = nvl(l_del_cases_count(i),0),
         contracts_count = nvl(l_contracts_count(i),0),
         del_contracts_count = nvl(l_del_contracts_count(i),0)
         where party_id = l_party_id(i)
         and org_id = l_org_id(i);
        l_cases_count.delete;
        l_del_cases_count.delete;
        l_contracts_count.delete;
        l_del_contracts_count.delete;
        l_party_id.delete;
        l_org_id.delete;

        temp :=1;
       end if;

        end loop;  -- end loop r_contract
        forall i in l_cases_count.FIRST .. l_cases_count.LAST
         update iex_dln_uwq_summary set
         cases_count = nvl(l_cases_count(i),0),
         del_cases_count = nvl(l_del_cases_count(i),0),
         contracts_count = nvl(l_contracts_count(i),0),
         del_contracts_count = nvl(l_del_contracts_count(i),0)
         where party_id = l_party_id(i)
         and org_id = l_org_id(i);

        l_cases_count.delete;
        l_del_cases_count.delete;
        l_contracts_count.delete;
        l_del_contracts_count.delete;
        l_party_id.delete;
        l_org_id.delete;
 end loop;  -- end loop r_org

  EXCEPTION
  WHEN OTHERS THEN
  LogMessage(FND_LOG.LEVEL_STATEMENT,sqlerrm);

End populate_contracts_info;

-- End for bug#8261043

--Begin Bug 8823567 22-Oct-2009 barathsr

procedure calculate_net_balance(p_fmode varchar2, p_from_date date,p_org_id number) is

  CURSOR C_ORGS IS
  select distinct org_id
  from iex_dln_uwq_summary
  where org_id=nvl(p_org_id,org_id);

  CURSOR c_get_details(p_org_id number) IS
  select party_id, cust_account_id , site_use_id,org_id
  FROM iex_dln_uwq_summary
  where org_id= p_org_id
 -- AND last_update_date >= nvl( p_from_date, last_update_date);
  AND last_update_date >= trunc(sysdate);
  l_party_id number_list;
  l_cust_acct_id number_list;
  l_site_use_id number_list;
  l_org_id number_list;
  l_batch_size number:=1000;
  begin
    for i in c_orgs loop
    FND_FILE.PUT_LINE(FND_FILE.LOG,'net bal calc--inside org loop--'||i.org_id);
    open c_get_details(i.org_id);
    l_party_id.delete;
    l_cust_acct_id.delete;
    l_site_use_id.delete;
    l_org_id.delete;
    loop
    FETCH c_get_details BULK COLLECT INTO
	    l_party_id,l_cust_acct_id,l_site_use_id,l_org_id LIMIT G_BATCH_SIZE;
	  IF l_party_id.count =  0 and l_cust_acct_id.count=0 and l_site_use_id.count=0 THEN

               IEX_DEBUG_PUB.LOGMESSAGE('Exit after Updating iex_dln_uwq_summ...');

	    CLOSE c_get_details;
	    EXIT;
          ELSE
	  if p_fmode='CUSTOMER' then
	   FORALL cnt IN l_party_id.first..l_party_id.last
	      update iex_dln_uwq_summary dln_summ
	      set net_balance=(select SUM(NVL(aps.acctd_amount_due_remaining,0))
	                 from ar_payment_schedules aps,hz_cust_accounts hca
                   where aps.customer_id=hca.cust_account_id
			and aps.org_id=l_org_id(cnt)
			 and aps.status='OP'
	       and hca.party_id=l_party_id(cnt))
	    --  and nvl(aps.customer_id,1)=nvl(l_cust_acct_id(cnt),1)
		 --  and nvl(aps.customer_site_use_id,1)=nvl(l_site_use_id(cnt),1))
	     where party_id=l_party_id(cnt)
	     and dln_summ.ieu_param_pk_col='PARTY_ID'
		and cust_account_id is null
		and site_use_id is null
		and dln_summ.org_id=l_org_id(cnt);
	--	and business_level=p_fmode;
		 FND_FILE.PUT_LINE(FND_FILE.LOG,'rows updated-'||sql%rowcount);
		 FND_FILE.PUT_LINE(FND_FILE.LOG,'inside customer');
          elsif p_fmode='ACCOUNT' then
	     FORALL cnt IN l_cust_acct_id.first..l_cust_acct_id.last
	      update iex_dln_uwq_summary dln_summ
	      set net_balance=(select SUM(NVL(aps.acctd_amount_due_remaining,0))
	                 from ar_payment_schedules aps,hz_cust_accounts hca--,ar_system_parameters asp
			 where aps.customer_id=hca.cust_account_id
			and aps.org_id=l_org_id(cnt)
			 and aps.status='OP'
	       and hca.party_id=l_party_id(cnt)
	       and aps.customer_id=l_cust_acct_id(cnt))
	    --  and nvl(aps.customer_site_use_id,1)=nvl(l_site_use_id(cnt),1))
		where party_id=l_party_id(cnt)
		and cust_account_id=l_cust_acct_id(cnt)
		and site_use_id is null
		and dln_summ.ieu_param_pk_col='CUST_ACCOUNT_ID'
		--and nvl(site_use_id,1)=nvl(l_site_use_id(cnt),1)
		and dln_summ.org_id=l_org_id(cnt);
	--	and business_level=p_fmode;
		 FND_FILE.PUT_LINE(FND_FILE.LOG,'rows_updated-'||sql%rowcount);
		 FND_FILE.PUT_LINE(FND_FILE.LOG,'inside account');
	 elsif p_fmode='BILL_TO' then
             FORALL cnt IN l_party_id.first..l_party_id.last
	      update iex_dln_uwq_summary dln_summ
	      set net_balance=(select SUM(NVL(aps.acctd_amount_due_remaining,0))
	                 from ar_payment_schedules aps,hz_cust_accounts hca--,ar_system_parameters asp
			 where aps.customer_id=hca.cust_account_id
			and aps.org_id=l_org_id(cnt)
			 and aps.status='OP'
	       and hca.party_id=l_party_id(cnt)
	       and aps.customer_id=l_cust_acct_id(cnt)
	       and aps.customer_site_use_id=l_site_use_id(cnt))
		where party_id=l_party_id(cnt)
		and cust_account_id=l_cust_acct_id(cnt)
		and site_use_id=l_site_use_id(cnt)
		and dln_summ.ieu_param_pk_col='CUSTOMER_SITE_USE_ID'
		and org_id=l_org_id(cnt);
		--and business_level=p_fmode;
		 FND_FILE.PUT_LINE(FND_FILE.LOG,'rows_updated-'||sql%rowcount);
		 FND_FILE.PUT_LINE(FND_FILE.LOG,'inside billto');
        else
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Net Balance calculation--Delinquency level is not implemented at this time');
  end if;
  end if;
  end loop;
  end loop;
   IF c_get_details % ISOPEN THEN
        CLOSE C_get_details;
   END IF;


  exception
  when others then
  FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in net balance calculation--'||sqlerrm);
   LogMessage(FND_LOG.LEVEL_STATEMENT,sqlerrm);
  end ;

--End Bug 8823567 22-Oct-2009 barathsr

BEGIN
    G_LOG_ENABLED := 'N';
    G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;

    /* getting msg logging info */
    G_LOG_ENABLED := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
    if (G_LOG_ENABLED = 'N') then
       G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;
    else
       G_MSG_LEVEL := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_MSG_LEVEL: ' || G_MSG_LEVEL);
END;


/
