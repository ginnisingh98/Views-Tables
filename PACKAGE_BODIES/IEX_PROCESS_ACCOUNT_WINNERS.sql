--------------------------------------------------------
--  DDL for Package Body IEX_PROCESS_ACCOUNT_WINNERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_PROCESS_ACCOUNT_WINNERS" AS
/* $Header: iextpawb.pls 120.7.12010000.3 2009/07/31 09:44:53 pnaveenk ship $ */

/*-------------------------------------------------------------------------*
 |                             PRIVATE CONSTANTS
 *-------------------------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30):='IEX_PROCESS_ACCOUNT_WINNERS';
G_FILE_NAME CONSTANT VARCHAR2(12):='iextpawb.pls';
deadlock_detected EXCEPTION;
PRAGMA EXCEPTION_INIT(deadlock_detected, -60);


/*-------------------------------------------------------------------------*
 |                             PRIVATE DATATYPES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PRIVATE VARIABLES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PRIVATE ROUTINES SPECIFICATION
 *-------------------------------------------------------------------------*/


/*-------------------------------------------------------------------------*
 |                             PUBLIC ROUTINES
 *-------------------------------------------------------------------------*/

    TYPE customer_id_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE address_id_list     is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE faf_list            is TABLE of VARCHAR2(1) INDEX BY BINARY_INTEGER;
    TYPE org_id_list         is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE res_type_list       is TABLE of VARCHAR2(60) INDEX BY BINARY_INTEGER;

    TYPE salesforce_id_list  is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE sales_group_id_list is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE person_id_list      is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE src_list            is TABLE of VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE access_id_list      is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE terr_id_list        is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE collector_list      is TABLE of NUMBER INDEX BY BINARY_INTEGER;

    TYPE party_site_id_list  is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE site_use_id_list    is TABLE of NUMBER INDEX BY BINARY_INTEGER;
    TYPE cust_account_id_list is TABLE of NUMBER INDEX BY BINARY_INTEGER;

     l_AssignLevel   VARCHAR2(20); -- Added for bug 8708291 pnaveenk multi level strategy

PROCEDURE CheckCollectors(
	x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
	p_worker_id 	   IN  NUMBER,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS);


PROCEDURE AssignSiteUseCollectors(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS);

PROCEDURE AssignPartyCollectors(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS);

PROCEDURE AssignAccountCollectors(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS);

PROCEDURE CreatePartyProfiles(
   x_errbuf           OUT NOCOPY VARCHAR2,
   x_retcode          OUT NOCOPY VARCHAR2,
   p_worker_id 	   IN  NUMBER,
   p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS);

PROCEDURE CreateSiteUseProfiles(
	x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
	p_worker_id 	   IN  NUMBER,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS);


PROCEDURE Process_Account_Records(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS,
    p_assignlevel      IN  varchar2)  -- Changed for bug 8708291 pnaveenk multi level strategy
IS

    l_limit_flag    BOOLEAN := FALSE;
    l_max_fetches   NUMBER  := 10000;
    l_loop_count    NUMBER  := 0;
    l_src_exists    VARCHAR2(1);
 --   l_AssignLevel   VARCHAR2(20);
    l_var     			NUMBER;
    l_worker_id     	NUMBER;
-------------------------------------------------------------------------------


BEGIN
	IEX_TERR_WINNERS_PUB.Print_Debug('*** iextpawb.pls::IEX_PROCESS_ACCOUNT_WINNERS::Process_Account_Records() ***');

	--l_Assignlevel:= NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY'); -- commented for bug 8708291
	l_Assignlevel := p_assignlevel; -- Added for bug 8708291 pnaveenk multi level strategy
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Process Accounts  Program started');
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Operating Unit Set : ' || MO_GLOBAL.GET_CURRENT_ORG_ID);
	FND_FILE.PUT_LINE(FND_FILE.LOG,'Assignment Level := ' ||l_Assignlevel); -- changed by gnramasa on 29/08/2006 for bug # 5487449

	l_worker_id:=p_terr_globals.worker_id;
	l_var      :=p_terr_globals.bulk_size;
	IEX_TERR_WINNERS_PUB.Print_Debug('bulk size='||l_var);

	IEX_TERR_WINNERS_PUB.Print_Debug('Calling CheckCollectors');
	CheckCollectors(x_errbuf, x_retcode, l_worker_id, p_terr_globals);
	if (x_retcode = 'E') then
	   IEX_TERR_WINNERS_PUB.Print_Debug('CheckCollectors Exception:  in IEX_PROCESS_ACCOUNT_WINNERS::Process_Account_Records');
	   return;
	end if;

    if (l_AssignLevel = 'PARTY') then
		IEX_TERR_WINNERS_PUB.Print_Debug('Calling CreatePartyProfiles');
   	    CreatePartyProfiles(x_errbuf, x_retcode, l_worker_id, p_terr_globals);
		if (x_retcode = 'E') then
		   IEX_TERR_WINNERS_PUB.Print_Debug('CreatePartyProfiles Exception:  in IEX_PROCESS_ACCOUNT_WINNERS::Process_Account_Records');
		   return;
		end if;
        IEX_TERR_WINNERS_PUB.Print_Debug('Calling AssignPartyCollectors');
	   	AssignPartyCollectors(x_errbuf,  x_retcode,  p_terr_globals);
	elsif (l_AssignLevel = 'ACCOUNT') then
	        --Bug4650943. Fix By LKKUMAR on 04-Oct-2005. Start.
        IEX_TERR_WINNERS_PUB.Print_Debug('Calling AssignAccountCollectors');
	   	AssignAccountCollectors(x_errbuf,  x_retcode,  p_terr_globals);
		--Bug4650943. Fix By LKKUMAR on 04-Oct-2005. End.
	else
        IEX_TERR_WINNERS_PUB.Print_Debug('Calling CreateSiteUseProfiles');
	   	CreateSiteUseProfiles(x_errbuf, x_retcode, l_worker_id, p_terr_globals);
		if (x_retcode = 'E') then
		   IEX_TERR_WINNERS_PUB.Print_Debug('CreateSiteuseProfiles Exception:  in IEX_PROCESS_ACCOUNT_WINNERS::Process_Account_Records');
		   return;
		end if;
        IEX_TERR_WINNERS_PUB.Print_Debug('Calling AssignSiteUseCollectors ');
	   	AssignSiteUseCollectors(x_errbuf,  x_retcode,  p_terr_globals);
	end if;
	if (x_retcode = 'E') then
	   return;
	end if;

EXCEPTION

WHEN others THEN
      IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in IEX_PROCESS_ACCOUNT_WINNERS::Process_Account_Records');
      IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      RAISE;
END Process_Account_Records;


PROCEDURE AssignPartyCollectors(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS)
IS
    --  Included 'Collections' Role Check
    CURSOR c_UpdateProfile(c_worker_id number) IS
    SELECT WIN.TRANS_OBJECT_id,
           WIN.RESOURCE_id,
           nvl(WIN.GROUP_ID,-777) GROUP_ID,
           nvl(WIN.org_id,-777) org_id,
           win.resource_type,
           ACC.COLLECTOR_ID
    FROM JTF_TAE_1600_CUST_WINNERS WIN,
		AR_COLLECTORS ACC,
	    JTF_RS_ROLE_RELATIONS jtrr,
		JTF_RS_ROLES_B  jtr
    WHERE   WIN.SOURCE_ID = -1600
      AND WIN.worker_id = c_worker_id
      AND WIN.resource_type in ('RS_EMPLOYEE', 'RS_GROUP')
      -- AND WIN.full_access_flag = 'Y' Bug5043777. Remove the Full_Access_Flag. Fix By LKKUMAR.
      AND ACC.RESOURCE_ID = WIN.RESOURCE_ID
      AND DECODE(ACC.RESOURCE_TYPE,
         'RS_RESOURCE', 'RS_EMPLOYEE',
         'RS_GROUP', 'RS_GROUP', 'RS_EMPLOYEE') = WIN.RESOURCE_TYPE
      AND jtrr.role_resource_id =  WIN.RESOURCE_ID
      AND jtr.ROLE_ID =  jtrr.role_id and jtr.role_type_code = 'COLLECTIONS'
    GROUP BY WIN.TRANS_OBJECT_id,
             WIN.RESOURCE_ID,
             WIN.GROUP_ID,
             WIN.ORG_ID, WIN.RESOURCE_TYPE, ACC.COLLECTOR_ID;

    l_customer_id      customer_id_list;
    l_address_id       address_id_list;
    l_faf              faf_list;
    l_org_id           org_id_list;
    l_res_type        res_type_list;

    l_salesforce_id    salesforce_id_list;
    l_sales_group_id   sales_group_id_list;
    l_person_id        person_id_list;
    l_src              src_list;
    l_collector_id     collector_list;

    l_access_id        access_id_list;
    l_terr_id          terr_id_list;

    l_max_rows         NUMBER := 10000;
    l_attempts         NUMBER := 0;
    l_upd_attempts     NUMBER := 0;
    l_exceptions       BOOLEAN := FALSE;

    l_flag    			BOOLEAN;
    l_first   			NUMBER;
    l_last    			NUMBER;
    l_var     			NUMBER;
    l_worker_id     	NUMBER;


    l_customer_id_empty      customer_id_list;
    l_address_id_empty       address_id_list;
    l_faf_empty              faf_list;
    l_org_id_empty           org_id_list;
    l_salesforce_id_empty    salesforce_id_list;
    l_sales_group_id_empty   sales_group_id_list;
    l_person_id_empty        person_id_list;
    l_src_empty              src_list;
    l_access_id_empty        access_id_list;
    l_terr_id_empty          terr_id_list;
    l_res_type_empty         res_type_list;


    l_limit_flag    BOOLEAN := FALSE;
    l_max_fetches   NUMBER  := 10000;
    l_loop_count    NUMBER  := 0;
    l_src_exists    VARCHAR2(1);
 --   l_AssignLevel   VARCHAR2(20);

    l_WORKER_OVERLIMIT EXCEPTION;
    l_Status        BOOLEAN;

-------------------------------------------------------------------------------


BEGIN
      IEX_TERR_WINNERS_PUB.Print_Debug('*** Started Party Level Collector Assignment ***');

  --     l_Assignlevel:= NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');
	   FND_FILE.PUT_LINE(FND_FILE.LOG,'Territory Assignment Program started');
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Assignment Level when assigning collectors at Party Level := ' ||l_Assignlevel);

       l_worker_id:=p_terr_globals.worker_id;
       -- Bulk Read the Territory Assignments
       l_var          :=p_terr_globals.bulk_size;
       l_max_fetches  := p_terr_globals.cursor_limit;
       IEX_TERR_WINNERS_PUB.Print_Debug('Bulk Size='||l_var);
       IEX_TERR_WINNERS_PUB.Print_Debug('Cursor Fetch Size = ' || l_max_fetches);
       IEX_TERR_WINNERS_PUB.Print_Debug('Updating Profiles started ... ');
       --Bug4650943. Fix By LKKUMAR on 04-Oct-2005. Start.
       OPEN c_UpdateProfile(l_worker_id);
       LOOP
        BEGIN
          FETCH c_UpdateProfile BULK COLLECT INTO
	      l_customer_id, l_salesforce_id, l_sales_group_id, l_org_id, l_Res_type, l_Collector_ID
       	      LIMIT l_max_fetches;
	  IF l_customer_id.count = 0 THEN
  	    IEX_TERR_WINNERS_PUB.Print_Debug('Update Completed. Exiting the update loop');
    	    CLOSE C_UPDATEPROFILE;
	    EXIT;
  	  ELSE
  	    IEX_TERR_WINNERS_PUB.Print_Debug('Total Rows Fetched  ' || l_customer_id.count);
     	    FORALL i in l_customer_id.first..l_customer_id.last
            UPDATE  HZ_CUSTOMER_PROFILES ACC
             SET object_version_number =  nvl(object_version_number,0) + 1,
	     ACC.LAST_UPDATE_DATE = SYSDATE,
	     ACC.LAST_UPDATED_BY = p_terr_globals.user_id,
	     ACC.LAST_UPDATE_LOGIN = p_terr_globals.last_update_login,
	     ACC.REQUEST_ID = p_terr_globals.request_id,
	     ACC.PROGRAM_APPLICATION_ID = p_terr_globals.prog_appl_id,
	     ACC.PROGRAM_ID = p_terr_globals.prog_id,
	     ACC.PROGRAM_UPDATE_DATE = SYSDATE,
	     ACC.COLLECTOR_ID   = l_collector_id(i)
	     WHERE  ACC.PARTY_ID   = l_customer_id(i)
             AND ACC.SITE_USE_ID IS NULL
             AND ACC.CUST_ACCOUNT_ID = -1
	     AND ACC.COLLECTOR_ID <> l_collector_id(i);
	     --Commit When the Bulk commit size is reached.
             IEX_TERR_WINNERS_PUB.Print_Debug('Total Rows Updated ' || l_customer_id.count);
             COMMIT;
	   END IF;
	   EXCEPTION WHEN deadlock_detected THEN
            BEGIN
            IEX_TERR_WINNERS_PUB.Print_Debug('Deadlock encountered during party bulk update.. Performing row update..');
            ROLLBACK;
            FOR i in l_first .. l_last LOOP
	    BEGIN
            UPDATE  HZ_CUSTOMER_PROFILES ACC
             SET object_version_number =  nvl(object_version_number,0) + 1,
	     ACC.LAST_UPDATE_DATE = SYSDATE,
	     ACC.LAST_UPDATED_BY = p_terr_globals.user_id,
	     ACC.LAST_UPDATE_LOGIN = p_terr_globals.last_update_login,
	     ACC.REQUEST_ID = p_terr_globals.request_id,
	     ACC.PROGRAM_APPLICATION_ID = p_terr_globals.prog_appl_id,
	     ACC.PROGRAM_ID = p_terr_globals.prog_id,
	     ACC.PROGRAM_UPDATE_DATE = SYSDATE,
	     ACC.COLLECTOR_ID   = l_collector_id(i)
	     WHERE  ACC.PARTY_ID   = l_customer_id(i)
             AND ACC.SITE_USE_ID IS NULL
             AND ACC.CUST_ACCOUNT_ID = -1
	     AND ACC.COLLECTOR_ID <> l_collector_id(i);	    EXCEPTION
               WHEN OTHERS THEN
                IEX_TERR_WINNERS_PUB.Print_Debug('Others Exception during single row update');
                IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
              END;
            END LOOP;
	   END;
         WHEN OTHERS THEN
          IEX_TERR_WINNERS_PUB.Print_Debug('Exception occured while updating site profile '||sqlerrm);
         END;
	END LOOP;
	IF  C_UPDATEPROFILE%ISOPEN THEN
	  CLOSE C_UPDATEPROFILE;
	END IF;
        --Bug4650943. Fix By LKKUMAR on 04-Oct-2005. Start.
        IEX_TERR_WINNERS_PUB.Print_Debug('*** Finished Party Level Collector Assignment ***');

    l_customer_id.delete;
    l_terr_id.delete;
    l_customer_id := l_customer_id_empty;
    l_address_id := l_address_id_empty;
    l_org_id := l_org_id_empty;
    l_salesforce_id := l_salesforce_id_empty;
    l_sales_group_id := l_sales_group_id_empty;
    l_person_id := l_person_id_empty;
    l_attempts    := 1;
    l_exceptions  := FALSE;

EXCEPTION
WHEN L_WORKER_OVERLIMIT THEN
    x_retcode := FND_API.G_RET_STS_UNEXP_ERROR;
    l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
    RAISE;

WHEN others THEN
      IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in AssignPartyAccountCollectors::Process_Account_Records');
      IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      RAISE;
END AssignPartyCollectors;

--Bug4650943. Fix By LKKUMAR on 04-Oct-2005. Start.
PROCEDURE AssignAccountCollectors(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS)
IS
    --  Included 'Collections' Role Check
    CURSOR c_UpdateProfile(c_worker_id number) IS
    SELECT WIN.TRANS_OBJECT_id,
           WIN.RESOURCE_id,
           nvl(WIN.GROUP_ID,-777) GROUP_ID,
           nvl(WIN.org_id,-777) org_id,
           win.resource_type,
           ACC.COLLECTOR_ID
    FROM JTF_TAE_1600_CUST_WINNERS WIN,
	  AR_COLLECTORS ACC,
	  JTF_RS_ROLE_RELATIONS jtrr,
	  JTF_RS_ROLES_B  jtr
    WHERE   WIN.SOURCE_ID = -1600
      AND WIN.worker_id = c_worker_id
      AND WIN.resource_type in ('RS_EMPLOYEE', 'RS_GROUP')
      --AND WIN.full_access_flag = 'Y' Bug5043777. Remove the Full_Access_Flag
      AND ACC.RESOURCE_ID = WIN.RESOURCE_ID
      AND DECODE(ACC.RESOURCE_TYPE,
         'RS_RESOURCE', 'RS_EMPLOYEE',
         'RS_GROUP', 'RS_GROUP', 'RS_EMPLOYEE') = WIN.RESOURCE_TYPE
      AND jtrr.role_resource_id =  WIN.RESOURCE_ID
      AND jtr.ROLE_ID =  jtrr.role_id and jtr.role_type_code = 'COLLECTIONS'
      GROUP BY WIN.TRANS_OBJECT_id,
             WIN.RESOURCE_ID,
             WIN.GROUP_ID,
             WIN.ORG_ID, WIN.RESOURCE_TYPE, ACC.COLLECTOR_ID;

    l_customer_id      customer_id_list;
    l_address_id       address_id_list;
    l_faf              faf_list;
    l_org_id           org_id_list;
    l_res_type        res_type_list;

    l_salesforce_id    salesforce_id_list;
    l_sales_group_id   sales_group_id_list;
    l_person_id        person_id_list;
    l_src              src_list;
    l_collector_id     collector_list;

    l_access_id        access_id_list;
    l_terr_id          terr_id_list;

    l_max_rows         NUMBER := 10000;
    l_attempts         NUMBER := 0;
    l_upd_attempts     NUMBER := 0;
    l_exceptions       BOOLEAN := FALSE;

    l_flag    			BOOLEAN;
    l_first   			NUMBER;
    l_last    			NUMBER;
    l_var     			NUMBER;
    l_worker_id     	NUMBER;


    l_customer_id_empty      customer_id_list;
    l_address_id_empty       address_id_list;
    l_faf_empty              faf_list;
    l_org_id_empty           org_id_list;
    l_salesforce_id_empty    salesforce_id_list;
    l_sales_group_id_empty   sales_group_id_list;
    l_person_id_empty        person_id_list;
    l_src_empty              src_list;
    l_access_id_empty        access_id_list;
    l_terr_id_empty          terr_id_list;
    l_res_type_empty         res_type_list;


    l_limit_flag    BOOLEAN := FALSE;
    l_max_fetches   NUMBER  := 10000;
    l_loop_count    NUMBER  := 0;
    l_src_exists    VARCHAR2(1);
 --   l_AssignLevel   VARCHAR2(20);

    l_WORKER_OVERLIMIT EXCEPTION;
    l_Status        BOOLEAN;

-------------------------------------------------------------------------------


BEGIN
       IEX_TERR_WINNERS_PUB.Print_Debug('*** Started Account Level Collector Assignment ***');

   --    l_Assignlevel:= NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');
	   FND_FILE.PUT_LINE(FND_FILE.LOG,'Territory Assignment Program started');
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Assignment Level when assigning collectors at Account Level := ' ||l_Assignlevel);

       l_worker_id:=p_terr_globals.worker_id;
       -- Bulk Read the Territory Assignments
       l_var          :=p_terr_globals.bulk_size;
       l_max_fetches  := p_terr_globals.cursor_limit;
       IEX_TERR_WINNERS_PUB.Print_Debug('Bulk Size='||l_var);
       IEX_TERR_WINNERS_PUB.Print_Debug('Cursor Fetch Size = ' || l_max_fetches);
       IEX_TERR_WINNERS_PUB.Print_Debug('Updating Profiles started ... ');

       OPEN c_UpdateProfile(l_worker_id);
       LOOP
        BEGIN
          FETCH c_UpdateProfile BULK COLLECT INTO
	      l_customer_id, l_salesforce_id, l_sales_group_id, l_org_id, l_Res_type, l_Collector_ID
       	      LIMIT l_max_fetches;
	  IF l_customer_id.count = 0 THEN
  	    IEX_TERR_WINNERS_PUB.Print_Debug('Update Completed. Exiting the update loop');
    	    CLOSE C_UPDATEPROFILE;
	    EXIT;
  	  ELSE
  	    IEX_TERR_WINNERS_PUB.Print_Debug('Total Rows Fetched  ' || l_customer_id.count);
     	    FORALL i in l_customer_id.first..l_customer_id.last
            UPDATE  HZ_CUSTOMER_PROFILES ACC
             SET object_version_number    =  nvl(object_version_number,0) + 1,
	     ACC.LAST_UPDATE_DATE         = SYSDATE,
	     ACC.LAST_UPDATED_BY          = p_terr_globals.user_id,
	     ACC.LAST_UPDATE_LOGIN        = p_terr_globals.last_update_login,
	     ACC.REQUEST_ID               = p_terr_globals.request_id,
	     ACC.PROGRAM_APPLICATION_ID   = p_terr_globals.prog_appl_id,
	     ACC.PROGRAM_ID               = p_terr_globals.prog_id,
	     ACC.PROGRAM_UPDATE_DATE      = SYSDATE,
	     ACC.COLLECTOR_ID             = l_collector_id(i)
	     WHERE  ACC.PARTY_ID          = l_customer_id(i)
             AND ACC.SITE_USE_ID          IS NULL
             AND ACC.CUST_ACCOUNT_ID      <> -1
	     AND ACC.COLLECTOR_ID         <> l_collector_id(i);
	     --Commit When the Bulk commit size is reached.
             IEX_TERR_WINNERS_PUB.Print_Debug('Total Rows Updated ' || l_customer_id.count);
             COMMIT;
	   END IF;
	   EXCEPTION WHEN deadlock_detected THEN
            BEGIN
            IEX_TERR_WINNERS_PUB.Print_Debug('Deadlock encountered during bulk update.. Performing row update..');
            ROLLBACK;
            FOR i in l_first .. l_last LOOP
	    BEGIN
            UPDATE  HZ_CUSTOMER_PROFILES ACC
             SET object_version_number    =  nvl(object_version_number,0) + 1,
	     ACC.LAST_UPDATE_DATE         = SYSDATE,
	     ACC.LAST_UPDATED_BY          = p_terr_globals.user_id,
	     ACC.LAST_UPDATE_LOGIN        = p_terr_globals.last_update_login,
	     ACC.REQUEST_ID               = p_terr_globals.request_id,
	     ACC.PROGRAM_APPLICATION_ID   = p_terr_globals.prog_appl_id,
	     ACC.PROGRAM_ID               = p_terr_globals.prog_id,
	     ACC.PROGRAM_UPDATE_DATE      = SYSDATE,
	     ACC.COLLECTOR_ID             = l_collector_id(i)
	     WHERE  ACC.PARTY_ID          = l_customer_id(i)
             AND ACC.SITE_USE_ID          IS NULL
             AND ACC.CUST_ACCOUNT_ID      <> -1
	     AND ACC.COLLECTOR_ID         <> l_collector_id(i);
	     EXCEPTION  WHEN OTHERS THEN
                IEX_TERR_WINNERS_PUB.Print_Debug('Others Exception during single row update');
                IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
              END;
            END LOOP;
	   END;
         WHEN OTHERS THEN
          IEX_TERR_WINNERS_PUB.Print_Debug('Exception occured while updating site profile '||sqlerrm);
         END;
	END LOOP;
	IF  C_UPDATEPROFILE%ISOPEN THEN
	  CLOSE C_UPDATEPROFILE;
	END IF;

    IEX_TERR_WINNERS_PUB.Print_Debug('*** Completed Account Level Collector Assignment ***');
    l_loop_count    := 0;

    l_customer_id.delete;
    l_terr_id.delete;
    l_customer_id := l_customer_id_empty;
    l_address_id := l_address_id_empty;
    l_org_id := l_org_id_empty;
    l_salesforce_id := l_salesforce_id_empty;
    l_sales_group_id := l_sales_group_id_empty;
    l_person_id := l_person_id_empty;

    l_attempts    := 1;
    l_exceptions  := FALSE;

EXCEPTION
WHEN L_WORKER_OVERLIMIT THEN
    x_retcode := FND_API.G_RET_STS_UNEXP_ERROR;
    l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
    RAISE;

WHEN others THEN
      IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in AssignPartyAccountCollectors::Process_Account_Records');
      IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      RAISE;
END AssignAccountCollectors;
--Bug4650943. Fix By LKKUMAR on 04-Oct-2005. End.


PROCEDURE AssignSiteUseCollectors(
    x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS)
IS
   /*CURSOR c_UpdateProfile(c_worker_id number) IS
		SELECT WIN.TRANS_OBJECT_id,
			WIN.TRANS_DETAIL_OBJECT_ID,
			WIN.RESOURCE_id,
			nvl(WIN.GROUP_ID,-777) GROUP_ID,
			nvl(WIN.org_id,-777) org_id,
			win.resource_type,
			ACC.COLLECTOR_ID,
			cust_acct.cust_account_id,
			hzp.SITE_USE_ID
		FROM JTF_TAE_1600_CUST_WINNERS WIN,
			AR_COLLECTORS ACC,
			JTF_RS_ROLE_RELATIONS jtrr,
			JTF_RS_ROLES_B  jtr,
			HZ_CUST_SITE_USES_ALL hzp,
			HZ_CUST_ACCT_SITES_ALL acct_site,
			HZ_CUST_ACCOUNTS cust_acct
		WHERE WIN.SOURCE_ID = -1600
			AND   WIN.worker_id = c_worker_id
			AND   WIN.resource_type in ('RS_EMPLOYEE', 'RS_GROUP')
			--AND   WIN.full_access_flag = 'Y'
			AND   ACC.RESOURCE_ID = WIN.RESOURCE_ID
			AND   DECODE(ACC.RESOURCE_TYPE,
			'RS_RESOURCE', 'RS_EMPLOYEE',
			'RS_GROUP', 'RS_GROUP', 'RS_EMPLOYEE') = WIN.RESOURCE_TYPE
			AND jtrr.role_resource_id =  WIN.RESOURCE_ID
			AND jtr.ROLE_ID =  jtrr.role_id
			and jtr.role_type_code = 'COLLECTIONS'
			--AND win.trans_detail_object_id is not null
			--AND acct_site.party_site_id = win.trans_detail_object_id
			AND WIN.TRANS_OBJECT_ID = CUST_ACCT.PARTY_ID
			AND CUST_ACCT.cust_account_id = ACCT_SITE.cust_account_id
			AND acct_site.cust_acct_site_id = hzp.cust_acct_site_id
			AND hzp.SITE_USE_CODE = 'BILL_TO'
			AND WIN.ORG_ID = acct_site.ORG_ID
			AND acct_site.ORG_ID = hzp.ORG_ID
		GROUP BY WIN.TRANS_OBJECT_id,
			WIN.TRANS_DETAIL_OBJECT_ID,
			WIN.RESOURCE_ID,
			WIN.GROUP_ID,
			WIN.ORG_ID,
			WIN.RESOURCE_TYPE,
			ACC.COLLECTOR_ID,
			cust_acct.cust_account_id,
			hzp.SITE_USE_ID;*/
    CURSOR c_UpdateProfile(c_worker_id number) IS
    SELECT WIN.TRANS_OBJECT_id,
           WIN.TRANS_DETAIL_OBJECT_ID,
           WIN.RESOURCE_id,
           nvl(WIN.GROUP_ID,-777) GROUP_ID,
           nvl(WIN.org_id,-777) org_id,
           win.resource_type,
           ACC.COLLECTOR_ID,
	   acct_site.cust_account_id,
           hzp.SITE_USE_ID
    FROM JTF_TAE_1600_CUST_WINNERS WIN, AR_COLLECTORS ACC,
	  JTF_RS_ROLE_RELATIONS jtrr, JTF_RS_ROLES_B  jtr,
	  HZ_CUST_SITE_USES hzp,
    HZ_CUST_ACCT_SITES acct_site
    WHERE   WIN.SOURCE_ID = -1600
    AND   WIN.worker_id = c_worker_id
    AND   WIN.resource_type in ('RS_EMPLOYEE', 'RS_GROUP')
    --AND   WIN.full_access_flag = 'Y' Bug5043777. Remove the Full_Access_Flag.
    AND   win.org_id = hzp.org_id
    AND   ACC.RESOURCE_ID = WIN.RESOURCE_ID
    AND   DECODE(ACC.RESOURCE_TYPE,
         'RS_RESOURCE', 'RS_EMPLOYEE',
         'RS_GROUP', 'RS_GROUP', 'RS_EMPLOYEE') = WIN.RESOURCE_TYPE
    AND jtrr.role_resource_id =  WIN.RESOURCE_ID
    AND jtr.ROLE_ID =  jtrr.role_id and jtr.role_type_code = 'COLLECTIONS'
    AND win.trans_detail_object_id is not null
    AND acct_site.party_site_id = win.trans_detail_object_id
    AND acct_site.cust_acct_site_id = hzp.cust_acct_site_id
    AND hzp.SITE_USE_CODE = 'BILL_TO'
    GROUP BY WIN.TRANS_OBJECT_id,
    		 WIN.TRANS_DETAIL_OBJECT_ID,
             WIN.RESOURCE_ID,
             WIN.GROUP_ID,
             WIN.ORG_ID, WIN.RESOURCE_TYPE,
             ACC.COLLECTOR_ID,
	     acct_site.cust_account_id,
             hzp.SITE_USE_ID;

    l_customer_id      customer_id_list;
    l_address_id       address_id_list;
    l_faf              faf_list;
    l_org_id           org_id_list;
    l_res_type        res_type_list;

    l_salesforce_id    salesforce_id_list;
    l_sales_group_id   sales_group_id_list;
    l_person_id        person_id_list;
    l_src              src_list;
    l_collector_id     collector_list;
    l_siteuse_id	   site_use_id_list;
    l_partysite_id     party_site_id_list;
    l_cust_account_id cust_account_id_list;

    l_access_id        access_id_list;
    l_terr_id          terr_id_list;

    l_max_rows         NUMBER := 10000;
    l_attempts         NUMBER := 0;
    l_exceptions       BOOLEAN := FALSE;

    l_flag    			BOOLEAN;
    l_first   			NUMBER;
    l_last    			NUMBER;
    l_var     			NUMBER;
    l_worker_id     	NUMBER;

    l_customer_id_empty      customer_id_list;
    l_address_id_empty       address_id_list;
    l_faf_empty              faf_list;
    l_org_id_empty           org_id_list;
    l_salesforce_id_empty    salesforce_id_list;
    l_sales_group_id_empty   sales_group_id_list;
    l_person_id_empty        person_id_list;
    l_src_empty              src_list;
    l_access_id_empty        access_id_list;
    l_terr_id_empty          terr_id_list;
    l_res_type_empty         res_type_list;
    l_cust_account_id_empty cust_account_id_list;

    l_limit_flag    BOOLEAN := FALSE;
    l_max_fetches   NUMBER  := 10000;
    l_loop_count    NUMBER  := 0;
    l_src_exists    VARCHAR2(1);
  --  l_AssignLevel   VARCHAR2(20);

    l_WORKER_OVERLIMIT EXCEPTION;
    l_Status        BOOLEAN;
-------------------------------------------------------------------------------

BEGIN
        IEX_TERR_WINNERS_PUB.Print_Debug('*** Started Site Level Collector Assignment ***');

--	l_Assignlevel  := NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');
	l_worker_id    :=p_terr_globals.worker_id;
	l_var          :=p_terr_globals.bulk_size;
	l_max_fetches  := p_terr_globals.cursor_limit;


	FND_FILE.PUT_LINE(FND_FILE.LOG,'Assignment Level when assigning collectors at Bill To Level := ' ||l_Assignlevel);
        IEX_TERR_WINNERS_PUB.Print_Debug('Bulk Size          ='  ||l_var);
	IEX_TERR_WINNERS_PUB.Print_Debug('Cursor Fetch Size  =' ||l_max_fetches);

	CheckCollectors(x_errbuf, x_retcode, l_worker_id, p_terr_globals);
	if (x_retcode = 'E') then
          IEX_TERR_WINNERS_PUB.Print_Debug('Error While creating Collectors, Not able to create collector');
          IEX_TERR_WINNERS_PUB.Print_Debug('Not able to proceed with update, returning back');
          return;
	end if;
       IEX_TERR_WINNERS_PUB.Print_Debug('Updating Profiles started ... ');
       --Bug4613487. Fix by lkkumar on 29-Sep-2005. Start.
       OPEN c_UpdateProfile(l_worker_id);
       LOOP
        BEGIN
          FETCH c_UpdateProfile BULK COLLECT INTO
                l_customer_id, l_partysite_id, l_salesforce_id, l_sales_group_id,
		l_org_id, l_Res_type, l_Collector_ID,l_cust_account_id, l_siteuse_id
        	LIMIT l_max_fetches;
	  IF l_customer_id.count = 0 THEN
  	    IEX_TERR_WINNERS_PUB.Print_Debug('Update Completed. Exiting the update loop');
    	    CLOSE C_UPDATEPROFILE;
	    EXIT;
  	  ELSE
  	    IEX_TERR_WINNERS_PUB.Print_Debug('Total Rows Fetched  ' || l_customer_id.count);
     	    FORALL i in l_customer_id.first..l_customer_id.last
             UPDATE  HZ_CUSTOMER_PROFILES ACC
	     SET object_version_number  =  nvl(object_version_number,0) + 1,
	     ACC.LAST_UPDATE_DATE       = SYSDATE,
 	     ACC.LAST_UPDATED_BY        = p_terr_globals.user_id,
	     ACC.LAST_UPDATE_LOGIN      = p_terr_globals.last_update_login,
   	     ACC.REQUEST_ID             = p_terr_globals.request_id,
	     ACC.PROGRAM_APPLICATION_ID = p_terr_globals.prog_appl_id,
	     ACC.PROGRAM_ID             = p_terr_globals.prog_id,
	     ACC.PROGRAM_UPDATE_DATE    = SYSDATE,
             ACC.COLLECTOR_ID           = l_collector_id(i)
 	     WHERE  ACC.PARTY_ID        = l_customer_id(i)
	     AND ACC.CUST_ACCOUNT_ID    = l_cust_account_id(i)
      	     AND ACC.SITE_USE_ID        = l_siteuse_id(i)
	     AND ACC.COLLECTOR_ID       <> l_collector_id(i);
	     --Commit When the Bulk commit size is reached.
             IEX_TERR_WINNERS_PUB.Print_Debug('Total Rows Updated ' || l_customer_id.count);
             COMMIT;
	   END IF;
	   EXCEPTION WHEN deadlock_detected THEN
            BEGIN
            IEX_TERR_WINNERS_PUB.Print_Debug('Deadlock encountered during bulk update.. Performing row update..');
            ROLLBACK;
            FOR i in l_first .. l_last LOOP
	    BEGIN
		UPDATE  HZ_CUSTOMER_PROFILES ACC
	        SET object_version_number  =  nvl(object_version_number,0) + 1,
		ACC.LAST_UPDATE_DATE       = SYSDATE,
		ACC.LAST_UPDATED_BY        = p_terr_globals.user_id,
		ACC.LAST_UPDATE_LOGIN      = p_terr_globals.last_update_login,
		ACC.REQUEST_ID             = p_terr_globals.request_id,
		ACC.PROGRAM_APPLICATION_ID = p_terr_globals.prog_appl_id,
		ACC.PROGRAM_ID             = p_terr_globals.prog_id,
		ACC.PROGRAM_UPDATE_DATE    = SYSDATE,
	        ACC.COLLECTOR_ID           = l_collector_id(i)
	 	WHERE  ACC.PARTY_ID        = l_customer_id(i)
		AND ACC.CUST_ACCOUNT_ID    = l_cust_account_id(i)
                AND ACC.SITE_USE_ID        = l_siteuse_id(i)
		AND ACC.COLLECTOR_ID       <> l_collector_id(i);
	    EXCEPTION
               WHEN OTHERS THEN
                IEX_TERR_WINNERS_PUB.Print_Debug('Others Exception during single row update');
                IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
              END;
            END LOOP;
	   END;
         WHEN OTHERS THEN
          IEX_TERR_WINNERS_PUB.Print_Debug('Exception occured while updating site profile '||sqlerrm);
         END;
	END LOOP;
	IF  C_UPDATEPROFILE%ISOPEN THEN
	  CLOSE C_UPDATEPROFILE;
	END IF;
        --Bug4613487. Fix by lkkumar on 29-Sep-2005. End.
    IEX_TERR_WINNERS_PUB.Print_Debug('*** Completed Site Level Collector Assignment ***');

    l_limit_flag    := FALSE;
    l_loop_count    := 0;

    l_customer_id.delete;
    l_terr_id.delete;
    l_customer_id := l_customer_id_empty;
    l_address_id := l_address_id_empty;
    l_org_id := l_org_id_empty;
    l_salesforce_id := l_salesforce_id_empty;
    l_sales_group_id := l_sales_group_id_empty;
    l_person_id := l_person_id_empty;
    l_cust_account_id:= l_cust_account_id_empty;

    l_attempts    := 1;
    l_exceptions  := FALSE;

EXCEPTION
WHEN L_WORKER_OVERLIMIT THEN
    x_retcode := FND_API.G_RET_STS_UNEXP_ERROR;
    l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
    RAISE;
WHEN others THEN
      IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in IEX_PROCESS_ACCOUNT_WINNERS::AssignSiteUseCollectors');
      IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      RAISE;
END AssignSiteUseCollectors;

PROCEDURE CheckCollectors(
	x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
	p_worker_id 	   IN  NUMBER,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS) AS

    l_missSF_id      salesforce_id_list;    -- Missed Sales Force ID
    l_missSG_id      sales_group_id_list;   -- Missed Sales Group ID
    l_missPer_ID     person_id_list;        -- Missed Person ID
    l_missOrg_ID     org_id_list;
    l_missResType    res_type_list;         -- Missed Resource Type

    l_max_fetches    NUMBER;
    l_limit_flag     boolean;
    l_loop_count     NUMBER;
    l_attempts       number;
    l_exceptions     boolean;

    l_flag    			BOOLEAN;
    l_first   			NUMBER;
    l_last    			NUMBER;
    l_var     			NUMBER;

    l_source_id         NUMBER;
    l_Resource_name     VARCHAR2(300);

    CURSOR c_MissedCollectors(c_worker_id number) IS
    SELECT DISTINCT WIN.RESOURCE_id,
           nvl(WIN.GROUP_ID,-777) GROUP_ID,
           nvl(WIN.org_id,-777) org_id,
           win.resource_type,
		   WIN.PERSON_ID
    FROM  JTF_TAE_1600_CUST_WINNERS WIN,
    	  JTF_RS_ROLE_RELATIONS jtrr, JTF_RS_ROLES_B  jtr
	WHERE WIN.SOURCE_ID = -1600
    AND   WIN.worker_id = c_worker_id
    AND   WIN.RESOURCE_TYPE IN ('RS_EMPLOYEE', 'RS_GROUP')
    AND jtrr.role_resource_id =  WIN.RESOURCE_ID
    AND jtr.ROLE_ID =  jtrr.role_id and jtr.role_type_code = 'COLLECTIONS'
    AND NOT EXISTS
   	   (SELECT RESOURCE_ID, RESOURCE_TYPE FROM AR_COLLECTORS acc
   	      WHERE ACC.RESOURCE_ID = WIN.RESOURCE_ID AND
   	            ACC.RESOURCE_TYPE = DECODE(WIN.RESOURCE_TYPE, 'RS_EMPLOYEE', 'RS_RESOURCE',  WIN.RESOURCE_TYPE));

Begin
	-- Bulk Read the Non-existents in AR_COLLECTORS
	l_loop_count := 0;
	l_max_fetches := p_terr_globals.cursor_limit;
	LOOP
		if (l_limit_flag) then
			EXIT;
		End If;
		l_loop_count := l_loop_count + 1;
		IEX_TERR_WINNERS_PUB.Print_Debug('*** Check Resources not in AR Collectors. LOOPING Count -> :'||l_loop_count);

		--------------------------------
		l_attempts    := 1;
		l_exceptions  := FALSE;
		WHILE l_attempts < 3 LOOP  --  Bulk read Collectors. attempts < 3
		BEGIN
        	IEX_TERR_WINNERS_PUB.Print_Debug('--- Attemp No: '||l_attempts);
        	OPEN c_MissedCollectors(p_worker_id);
        	FETCH c_MissedCollectors BULK COLLECT INTO
                l_missSF_id, l_missSG_id, l_missOrg_ID, l_MissResType, l_missPer_ID
         	LIMIT l_max_fetches;
        	CLOSE c_MissedCollectors;
			l_attempts := 3;
			l_exceptions  := FALSE;
		EXCEPTION
			WHEN Others THEN
				IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) || ' SQLERRM: ' || SQLERRM);
				l_attempts := l_attempts +1;
				l_exceptions  := TRUE;
				if c_MissedCollectors%ISOPEN then
					CLOSE c_MissedCollectors;
				end if;
				if l_attempts > 2 then
					x_errbuf  := SQLERRM;
					x_retcode := SQLCODE;
         			RAISE;
			end if;
      	END;
		END LOOP;  -- End Bulk read Sales Force ID. attempts < 3
		IEX_TERR_WINNERS_PUB.Print_Debug('--- Read Missed Collectors End-Attempts: '||l_attempts);

		-- Initialize variables
		if l_missSF_id.count < l_max_fetches then
			l_limit_flag := TRUE;
		end if;

		IEX_TERR_WINNERS_PUB.Print_Debug('--- Start INSERT OF AR_COLLECTORS = . ' || l_missSF_id.count);

		IF  l_missSF_id.count > 0 THEN  -- if l_SalesForce_id.count > 0

			l_attempts    := 1;
 		    IEX_TERR_WINNERS_PUB.Print_Debug('Inside IF, --- While Flag Loop -----');

			WHILE l_attempts < 3 LOOP  /* Update While loop; l_attempts < 3 */
			BEGIN

   		        IEX_TERR_WINNERS_PUB.Print_Debug('Inside IF, --- While Attempts Loop -----' || l_attempts);

				FOR i in 1 .. l_missSF_id.count LOOP
		    	BEGIN
					     IF (l_missResType(i) = 'RS_GROUP') THEN
						      SELECT GROUP_NAME
					    	  INTO l_resource_name
						      FROM jtf_rs_groups_vl
						      WHERE group_id = l_missSF_id(i);
					    ELSE
						      SELECT resource_name, source_id
						      INTO l_resource_name, l_source_id
						      FROM jtf_rs_resource_extns_vl
						      WHERE resource_id = l_missSF_id(i);
					    END IF;
    		        	IEX_TERR_WINNERS_PUB.Print_Debug('After selecting Resource_name = '|| l_resource_name );

					    INSERT INTO AR_COLLECTORS
					     (COLLECTOR_ID      ,
					      LAST_UPDATED_BY    ,
					      LAST_UPDATE_DATE   ,
					      LAST_UPDATE_LOGIN  ,
					      CREATION_DATE      ,
					      CREATED_BY         ,
					      NAME               ,
					      EMPLOYEE_ID        ,
					      DESCRIPTION        ,
					      STATUS             ,
					      RESOURCE_ID        ,
					      RESOURCE_TYPE       )
					     VALUES
					     (AR_COLLECTORS_S.NEXTVAL     ,
					      p_terr_globals.user_id ,
					      sysdate             ,
					      p_terr_globals.last_update_login ,
					      sysdate             ,
					      p_terr_globals.user_id  ,
					      substr(l_resource_name,1, 30),
					      l_source_id    ,
				    	  l_resource_name      ,
					      'A',
					      l_missSF_id(i),
					      decode(l_missResType(i),'RS_GROUP','RS_GROUP','RS_RESOURCE' )) ;

					      FND_FILE.PUT_LINE(FND_FILE.LOG, '    Inserted to the AR_COLLECTORS.  Collector_ID ');

						EXCEPTION
							WHEN OTHERS THEN
						      FND_FILE.PUT_LINE(FND_FILE.LOG,'  Error while selecting resource/groupname' );
						END;
		            COMMIT;
		        END LOOP;
      			l_attempts := 3;
      			IEX_TERR_WINNERS_PUB.Print_Debug('Records Updated: ' || l_first || '-'|| l_last);
			EXCEPTION
				WHEN deadlock_detected THEN
				begin
						IEX_TERR_WINNERS_PUB.Print_Debug('Deadlock encountered during bulk update-'||l_attempts);
						rollback;
						l_attempts := l_attempts +1;
						if l_attempts = 3 then
							FOR i in 1 .. l_missSF_id.count LOOP  /*Inside deadlock detected loop */
              				BEGIN
						     IF (l_missResType(i) = 'RS_GROUP') THEN
							      SELECT GROUP_NAME
						    	  INTO l_resource_name
							      FROM jtf_rs_groups_vl
							      WHERE group_id = l_missSF_id(i);
						    ELSE
							      SELECT resource_name, source_id
							      INTO l_resource_name, l_source_id
							      FROM jtf_rs_resource_extns_vl
							      WHERE resource_id = l_missSF_id(i);
						    END IF;

					    INSERT INTO AR_COLLECTORS
					     (COLLECTOR_ID      ,
					      LAST_UPDATED_BY    ,
					      LAST_UPDATE_DATE   ,
					      LAST_UPDATE_LOGIN  ,
					      CREATION_DATE      ,
					      CREATED_BY         ,
					      NAME               ,
					      EMPLOYEE_ID        ,
					      DESCRIPTION        ,
					      STATUS             ,
					      RESOURCE_ID        ,
					      RESOURCE_TYPE       )
					     VALUES
					     (AR_COLLECTORS_S.NEXTVAL     ,
					      p_terr_globals.user_id  ,
					      sysdate             ,
					      p_terr_globals.last_update_login ,
					      sysdate             ,
					      p_terr_globals.user_id  ,
					      substr(l_resource_name,1,30)     ,
					      l_source_id    ,
				    	  l_resource_name      ,
					      'A',
					      l_missSF_id(i),
					      decode(l_missResType(i),'RS_GROUP','RS_GROUP','RS_RESOURCE' )) ;

					      FND_FILE.PUT_LINE(FND_FILE.LOG, '             After Inserting in to the AR_COLLECTORS');

              				EXCEPTION
               				WHEN OTHERS THEN
                				IEX_TERR_WINNERS_PUB.Print_Debug('Others Exception during single row update');
                				IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                        	   		' SQLERRM: ' || SQLERRM);
              				END;
							END LOOP; /* End Inside deadlock detected loop */
							COMMIT;
						end if;
					end; -- end of deadlock exception

				WHEN OTHERS THEN
					IEX_TERR_WINNERS_PUB.Print_Debug('Exception : In others');
					IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                          ' SQLERRM: ' || SQLERRM);
					x_errbuf  := SQLERRM;
					x_retcode := SQLCODE;
					RAISE;
				END;
			END LOOP; /* Update While loop; l_attempts < 3 */

		END IF; --l_salesforce.count > 0
    	IEX_TERR_WINNERS_PUB.Print_Debug('---Check Collectors Account.End-'|| l_missSF_id.count||' Rows Updated.');
		--------------------------------
	END LOOP;  -- End Bulk read non-existent Collector ID. attempts < 3

EXCEPTION
	WHEN others THEN
      IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in IEX_PROCESS_ACCOUNT_RECORDS::CheckCollectors');
      IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      RAISE;
END CheckCollectors;


PROCEDURE CreatePartyProfiles(
	x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
	p_worker_id 	   IN  NUMBER,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS) AS

    l_missCustomer     customer_id_list;    -- Missed Customer Profiles

    l_max_fetches    NUMBER;
    l_limit_flag     boolean;
    l_loop_count     NUMBER;
    l_attempts       number;
    l_exceptions     boolean;

    l_customer_profile_id           NUMBER;
    l_return_status    VARChar2(10);
    l_msg_count      NUMBER;
    l_msg_data		 VARCHAR2(2000);


    l_flag    			BOOLEAN;
    l_first   			NUMBER;
    l_last    			NUMBER;
    l_var     			NUMBER;

    l_source_id         NUMBER;
    l_Resource_name     VARCHAR2(300);
	l_old_customer_profile_rec     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;

    CURSOR c_MissedProfiles(c_worker_id number) IS
    SELECT WIN.TRANS_OBJECT_id
    FROM JTF_TAE_1600_CUST_WINNERS WIN,
		AR_COLLECTORS ACC,
	    JTF_RS_ROLE_RELATIONS jtrr,
		JTF_RS_ROLES_B  jtr
    WHERE   WIN.SOURCE_ID = -1600
      AND WIN.worker_id = c_worker_id
      AND WIN.resource_type in ('RS_EMPLOYEE', 'RS_GROUP')
      -- AND WIN.full_access_flag = 'Y' Bug5043777. Remove the Full_Access_Flag. Fix By LKKUMAR.
      AND ACC.RESOURCE_ID = WIN.RESOURCE_ID
      AND DECODE(ACC.RESOURCE_TYPE,
         'RS_RESOURCE', 'RS_EMPLOYEE',
         'RS_GROUP', 'RS_GROUP', 'RS_EMPLOYEE') = WIN.RESOURCE_TYPE
      AND jtrr.role_resource_id =  WIN.RESOURCE_ID
      AND jtr.ROLE_ID =  jtrr.role_id and jtr.role_type_code = 'COLLECTIONS'
     AND NOT EXISTS
   	   (SELECT 1 FROM HZ_CUSTOMER_PROFILES hcp
   	      WHERE hcp.CUST_ACCOUNT_ID  = -1 AND
   	            hcp.PARTY_ID  = WIN.TRANS_OBJECT_ID AND
   	            hcp.site_use_id is null  )
    GROUP BY WIN.TRANS_OBJECT_id;
    l_profile_id NUMBER;

Begin
	-- Bulk Read the Non-existents in AR_COLLECTORS
	l_loop_count := 0;
	l_max_fetches := p_terr_globals.cursor_limit;
	LOOP
		if (l_limit_flag) then
			EXIT;
		End If;
		l_loop_count := l_loop_count + 1;
		IEX_TERR_WINNERS_PUB.Print_Debug('*** Getting Parties with no profiles. LOOPING Count -> :'||l_loop_count);

		--------------------------------
		l_attempts    := 1;
		l_exceptions  := FALSE;
		WHILE l_attempts < 3 LOOP  --  Bulk read Party list. attempts < 3
		BEGIN
        	IEX_TERR_WINNERS_PUB.Print_Debug('--- Attemp No: '||l_attempts);
        	OPEN c_MissedProfiles(p_worker_id);
        	FETCH c_MissedProfiles BULK COLLECT INTO l_missCustomer
        	  LIMIT l_max_fetches;
        	CLOSE c_MissedProfiles;
			l_attempts := 3;
			l_exceptions  := FALSE;
		EXCEPTION
			WHEN Others THEN
				IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) || ' SQLERRM: ' || SQLERRM);
				l_attempts := l_attempts +1;
				l_exceptions  := TRUE;
				if c_MissedProfiles%ISOPEN then
					CLOSE c_MissedProfiles;
				end if;
				if l_attempts > 2 then
					x_errbuf  := SQLERRM;
					x_retcode := SQLCODE;
         			RAISE;
			end if;
      	END;
		END LOOP;  -- End Bulk read Party list. attempts < 3
		IEX_TERR_WINNERS_PUB.Print_Debug('--- Select Parties with no profiles. End -Attempts: '||l_attempts);

		-- Initialize variables
		if l_missCustomer.count < l_max_fetches then
			l_limit_flag := TRUE;
		end if;

		IEX_TERR_WINNERS_PUB.Print_Debug('--- Start. Creating customer Profiles  = . ' || l_missCustomer.count);

		IF  l_missCustomer.count > 0 THEN  -- if Missed Customer Profiles .count > 0

 		    IEX_TERR_WINNERS_PUB.Print_Debug('Inside IF, --- While Flag Loop -----');
			l_attempts    := 1;

			WHILE l_attempts < 3 LOOP  /* Update While loop; l_attempts < 3 */
			BEGIN

   		        IEX_TERR_WINNERS_PUB.Print_Debug('Inside IF, --- While Attempts Loop -----' || l_attempts);

			     FOR i in 1 .. l_missCustomer.count LOOP
			     --Bug4574749. Fix By LKKUMAR on 12-Oct-2005. Start.
			      BEGIN
	 			SELECT CUST_ACCOUNT_PROFILE_ID
				INTO l_profile_id
				FROM HZ_CUSTOMER_PROFILES hcp
   	                        WHERE hcp.CUST_ACCOUNT_ID  = -1
				AND  hcp.PARTY_ID  = l_missCustomer(i)
   	                        AND  hcp.site_use_id is null;
				EXCEPTION WHEN NO_DATA_FOUND THEN
				  BEGIN
                 		            IEX_TERR_WINNERS_PUB.Print_Debug('Creating profile for Customer ID  = '|| l_missCustomer(i) );
				            l_old_customer_profile_rec.party_id            := l_missCustomer(i);
                                	    l_old_customer_profile_rec.created_by_module   := 'IEX';
					    l_old_customer_profile_rec.site_use_id 			:= NULL;
					    l_old_customer_profile_rec.cust_account_id 		:= NULL;

					    HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile (
					    p_customer_profile_rec     => l_old_customer_profile_rec,
					    x_cust_account_profile_id  => l_customer_profile_id,
					    x_return_status            => l_return_status,
					    x_msg_count                => l_msg_count,
					    x_msg_data                 => l_msg_data);

					    IEX_TERR_WINNERS_PUB.Print_Debug('                  Return data after create profile API ' || l_return_status || l_msg_count);
					    IEX_TERR_WINNERS_PUB.Print_Debug('                  Created Profile Id ' || l_customer_profile_id);

				  EXCEPTION
							WHEN OTHERS THEN
						      FND_FILE.PUT_LINE(FND_FILE.LOG,'  Error while selecting resource/groupname' );
				   END;
			     END;
			     --Bug4574749. Fix By LKKUMAR on 12-Oct-2005. END.
		        END LOOP;
		        COMMIT;
      			l_attempts := 3;
      			IEX_TERR_WINNERS_PUB.Print_Debug('Records Updated: ' || l_first || '-'|| l_last);
			EXCEPTION
				WHEN deadlock_detected THEN
				begin
					IEX_TERR_WINNERS_PUB.Print_Debug('Deadlock encountered during bulk update-'||l_attempts);
					rollback;
					l_attempts := l_attempts +1;
					if l_attempts = 3 then
  				        FOR i in 1 .. l_missCustomer.count LOOP  /*Inside deadlock detected loop */
    				        --Bug4574749. Fix By LKKUMAR on 12-Oct-2005. Start.
					BEGIN
		 			SELECT CUST_ACCOUNT_PROFILE_ID
					INTO l_profile_id
					FROM HZ_CUSTOMER_PROFILES hcp
   				        WHERE hcp.CUST_ACCOUNT_ID  = -1
					AND  hcp.PARTY_ID  = l_missCustomer(i)
	   	                        AND  hcp.site_use_id is null;
					EXCEPTION WHEN NO_DATA_FOUND THEN
					BEGIN
    		        			IEX_TERR_WINNERS_PUB.Print_Debug('Creating profile for Customer ID  = '|| l_missCustomer(i) );
				 			l_old_customer_profile_rec.party_id            := l_missCustomer(i);
					    		l_old_customer_profile_rec.created_by_module   := 'IEX';

					   		HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile (
					 		    p_customer_profile_rec     => l_old_customer_profile_rec,
							    x_cust_account_profile_id  => l_customer_profile_id,
							    x_return_status            => l_return_status,
							    x_msg_count                => l_msg_count,
							    x_msg_data                 => l_msg_data);

							    IEX_TERR_WINNERS_PUB.Print_Debug('                  Return data after create profile API ' || l_return_status || l_msg_count);
								IEX_TERR_WINNERS_PUB.Print_Debug('                  Created Profile Id ' || l_customer_profile_id);

              				 EXCEPTION
               				 WHEN OTHERS THEN
                				IEX_TERR_WINNERS_PUB.Print_Debug('Others Exception Profile creation API  update');
                				IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                        	   		' SQLERRM: ' || SQLERRM);
              				 END;
					END;
                                        --Bug4574749. Fix By LKKUMAR on 12-Oct-2005. End.

							END LOOP; /* End Inside deadlock detected loop */
							COMMIT;
						end if;
					end; -- end of deadlock exception

				WHEN OTHERS THEN
					IEX_TERR_WINNERS_PUB.Print_Debug('Exception : In others');
					IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                          ' SQLERRM: ' || SQLERRM);
					x_errbuf  := SQLERRM;
					x_retcode := SQLCODE;
					RAISE;
				END;
			END LOOP; /* Update While loop; l_attempts < 3 */

		END IF; --l_missCustomer .count > 0
    	IEX_TERR_WINNERS_PUB.Print_Debug('---Create Customer Profile.End-'|| l_missCustomer.count||' Rows Updated.');
		--------------------------------
	END LOOP;  -- End Bulk read non-existent Customer Profiles attempts < 3

EXCEPTION
	WHEN others THEN
      IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in IEX_PROCESS_ACCOUNT_RECORDS::CreatePartyProfiles.');
      IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      RAISE;
END CreatePartyProfiles;


PROCEDURE CreateSiteUseProfiles(
	x_errbuf           OUT NOCOPY VARCHAR2,
    x_retcode          OUT NOCOPY VARCHAR2,
	p_worker_id 	   IN  NUMBER,
    p_terr_globals     IN  IEX_TERR_WINNERS_PUB.TERR_GLOBALS) AS

    l_missCustomer     customer_id_list;    -- Missed Customer Profiles
    l_missSiteUse      site_use_id_list;
    l_missAccount      cust_account_id_list;

    l_max_fetches    NUMBER;
    l_limit_flag     boolean;
    l_loop_count     NUMBER;
    l_attempts       number;
    l_exceptions     boolean;

	l_customer_profile_id           NUMBER;
	l_return_status    VARChar2(10);
	l_msg_count      NUMBER;
	l_msg_data		 VARCHAR2(2000);

    l_flag    			BOOLEAN;
    l_first   			NUMBER;
    l_last    			NUMBER;
    l_var     			NUMBER;

    l_source_id         NUMBER;
    l_Resource_name     VARCHAR2(300);
	l_old_customer_profile_rec     HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;

    CURSOR c_MissedProfiles(c_worker_id number) IS
        SELECT win.trans_object_id, hzp.SITE_USE_ID,
          acct_site.cust_account_id
    FROM JTF_TAE_1600_CUST_WINNERS WIN, AR_COLLECTORS ACC,
	  JTF_RS_ROLE_RELATIONS jtrr, JTF_RS_ROLES_B  jtr,
	  HZ_CUST_SITE_USES hzp,
    HZ_CUST_ACCT_SITES acct_site
    WHERE   WIN.SOURCE_ID = -1600
     AND   WIN.worker_id = c_worker_id
      AND   WIN.resource_type in ('RS_EMPLOYEE', 'RS_GROUP')
      -- AND   WIN.full_access_flag = 'Y' Bug5043777. Remove the Full_Access_Flag. Fix By LKKUMAR.
      AND   ACC.RESOURCE_ID = WIN.RESOURCE_ID
      AND   DECODE(ACC.RESOURCE_TYPE,
         'RS_RESOURCE', 'RS_EMPLOYEE',
         'RS_GROUP', 'RS_GROUP', 'RS_EMPLOYEE') = WIN.RESOURCE_TYPE
      AND jtrr.role_resource_id =  WIN.RESOURCE_ID
      AND jtr.ROLE_ID =  jtrr.role_id and jtr.role_type_code = 'COLLECTIONS'
      AND win.trans_detail_object_id is not null
      AND acct_site.party_site_id = win.trans_detail_object_id
      AND hzp.cust_acct_site_id = acct_site.cust_acct_site_id
      AND win.org_id = hzp.org_id
      and hzp.SITE_USE_CODE = 'BILL_TO'
	  AND NOT EXISTS
   	   (SELECT 1 FROM HZ_CUSTOMER_PROFILES hcp
   	      WHERE hcp.PARTY_ID  = WIN.TRANS_OBJECT_ID AND
   	            hcp.site_use_id = HZP.site_use_id )
    GROUP BY WIN.TRANS_OBJECT_ID, acct_site.cust_account_id, hzp.SITE_USE_ID;

Begin
	-- Bulk Read the Non-existents in HZ_CUSTOMER_PROFILES Customer Sites
	l_loop_count := 0;
	l_max_fetches := p_terr_globals.cursor_limit;
	LOOP
		if (l_limit_flag) then
			EXIT;
		End If;
		l_loop_count := l_loop_count + 1;
		IEX_TERR_WINNERS_PUB.Print_Debug('*** Getting Parties with no profiles. LOOPING Count -> :'||l_loop_count);

		--------------------------------
		l_attempts    := 1;
		l_exceptions  := FALSE;
		WHILE l_attempts < 3 LOOP  --  Bulk read Party list. attempts < 3
		BEGIN
       	 	IEX_TERR_WINNERS_PUB.Print_Debug('--- Attemp No: '||l_attempts);
        	OPEN c_MissedProfiles(p_worker_id);
        	FETCH c_MissedProfiles BULK COLLECT INTO l_missCustomer,
            l_missSiteUse, l_missAccount LIMIT l_max_fetches;
        	CLOSE c_MissedProfiles;
			l_attempts := 3;
			l_exceptions  := FALSE;
		EXCEPTION
			WHEN Others THEN
				IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) || ' SQLERRM: ' || SQLERRM);
				l_attempts := l_attempts +1;
				l_exceptions  := TRUE;
				if c_MissedProfiles%ISOPEN then
					CLOSE c_MissedProfiles;
				end if;
				if l_attempts > 2 then
					x_errbuf  := SQLERRM;
					x_retcode := SQLCODE;
         			RAISE;
			end if;
      	END;
		END LOOP;  -- End Bulk read Party list. attempts < 3
		IEX_TERR_WINNERS_PUB.Print_Debug('--- Select Parties with no profiles.End-Attempts: '||l_attempts);

		-- Initialize variables
		if l_missCustomer.count < l_max_fetches then
			l_limit_flag := TRUE;
		end if;

		IEX_TERR_WINNERS_PUB.Print_Debug('--- Start. Create  = . ' || l_missCustomer.count);

		IF  l_missCustomer.count > 0 THEN  -- if Missed Customer Profiles .count > 0

			l_attempts    := 1;
 	    IEX_TERR_WINNERS_PUB.Print_Debug('Inside IF, --- While Flag Loop -----');

			WHILE l_attempts < 3 LOOP  /* Update While loop; l_attempts < 3 */
			BEGIN

   		        IEX_TERR_WINNERS_PUB.Print_Debug('Inside IF, --- While Attempts Loop -----' || l_attempts);

				FOR i in 1 .. l_missCustomer.count LOOP
		    	BEGIN
    		        	IEX_TERR_WINNERS_PUB.Print_Debug('Creating profile for Customer ID  = '|| l_missCustomer(i) );

					    l_old_customer_profile_rec.party_id    := l_missCustomer(i);
					    l_old_customer_profile_rec.cust_account_id := l_missAccount(i);
					    l_old_customer_profile_rec.site_use_id := l_missSiteUse(i);
					    l_old_customer_profile_rec.created_by_module   := 'IEX';

					    HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile (
					    p_customer_profile_rec     => l_old_customer_profile_rec,
						x_cust_account_profile_id  => l_customer_profile_id,
					    x_return_status            => l_return_status,
					    x_msg_count                => l_msg_count,
					    x_msg_data                 => l_msg_data);

					    IEX_TERR_WINNERS_PUB.Print_Debug('                  Return data after create profile API ' || l_return_status || ' msg_count ' || l_msg_count || ' msg_data ' || l_msg_data);
						IEX_TERR_WINNERS_PUB.Print_Debug('                  Created Profile Id ' || l_customer_profile_id);

				EXCEPTION
							WHEN OTHERS THEN
						      FND_FILE.PUT_LINE(FND_FILE.LOG,'  Error while selecting resource/groupname' );
						END;
		            COMMIT;
		        END LOOP;
      			l_attempts := 3;
      			IEX_TERR_WINNERS_PUB.Print_Debug('Records Updated: ' || l_first || '-'|| l_last);
			EXCEPTION
				WHEN deadlock_detected THEN
				begin
						IEX_TERR_WINNERS_PUB.Print_Debug('Deadlock encountered during bulk update-'||l_attempts);
						rollback;
						l_attempts := l_attempts +1;
						if l_attempts = 3 then
							FOR i in 1 .. l_missCustomer.count LOOP  /*Inside deadlock detected loop */
              				BEGIN

    		        			IEX_TERR_WINNERS_PUB.Print_Debug('Creating profile for Customer ID  = '|| l_missCustomer(i) );

					 			l_old_customer_profile_rec.party_id  := l_missCustomer(i);
							    l_old_customer_profile_rec.site_use_id := l_missSiteUse(i);
					 			l_old_customer_profile_rec.created_by_module   := 'IEX';
							    l_old_customer_profile_rec.cust_account_id := l_missAccount(i);

					    		HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile (
							    p_customer_profile_rec     => l_old_customer_profile_rec,
								x_cust_account_profile_id  => l_customer_profile_id,
							    x_return_status            => l_return_status,
							    x_msg_count                => l_msg_count,
							    x_msg_data                 => l_msg_data);

							    IEX_TERR_WINNERS_PUB.Print_Debug('  Return after create profile API ' || l_return_status ||
                  ' msg_count ' || l_msg_count || ' msg_data ' || l_msg_data);
								IEX_TERR_WINNERS_PUB.Print_Debug('                  Created Profile Id ' || l_customer_profile_id);

              				EXCEPTION
               				WHEN OTHERS THEN
                				IEX_TERR_WINNERS_PUB.Print_Debug('Others Exception Profile creation API  update');
                				IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                        	   		' SQLERRM: ' || SQLERRM);
              				END;
							END LOOP; /* End Inside deadlock detected loop */
							COMMIT;
						end if;
					end; -- end of deadlock exception

				WHEN OTHERS THEN
					IEX_TERR_WINNERS_PUB.Print_Debug('Exception : In others');
					IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                          ' SQLERRM: ' || SQLERRM);
					x_errbuf  := SQLERRM;
					x_retcode := SQLCODE;
					RAISE;
				END;
			END LOOP; /* Update While loop; l_attempts < 3 */

		END IF; --l_missCustomer .count > 0
    	IEX_TERR_WINNERS_PUB.Print_Debug('---Create SiteUse Profile.End-'|| l_missCustomer.count||' Rows Updated.');
		--------------------------------
	END LOOP;  -- End Bulk read non-existent Customer Profiles attempts < 3

EXCEPTION
	WHEN others THEN
      IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in IEX_PROCESS_ACCOUNT_RECORDS::CreatePartyProfiles.');
      IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE: ' || to_char(SQLCODE) ||
                           ' SQLERRM: ' || SQLERRM);
      x_errbuf  := SQLERRM;
      x_retcode := SQLCODE;
      RAISE;
END CreateSiteUseProfiles;

END IEX_PROCESS_ACCOUNT_WINNERS;

/
