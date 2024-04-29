--------------------------------------------------------
--  DDL for Package Body IEX_GAR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_GAR_PUB" AS
/* $Header: iextptwb.pls 120.5.12010000.2 2009/07/31 09:37:47 pnaveenk ship $ */

---------------------------------------------------------------------------
--    Start of Comments
---------------------------------------------------------------------------
--    PACKAGE NAME:   IEX_GAR_PUB
--    ---------------------------------------------------------------------
--    PURPOSE
--
--      Main Package for the concurrent program
--      "Generate Access Records".
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package to be called from the concurrent program
--		"Generate Access Records"
--
--    HISTORY
---------------------------------------------------------------------------


/*-------------------------------------------------------------------------+
 |                             PRIVATE CONSTANTS
 +-------------------------------------------------------------------------*/
  G_PKG_NAME  CONSTANT VARCHAR2(30):='IEX_GAR_PUB';
  G_FILE_NAME CONSTANT VARCHAR2(12):='iextptwb.pls';
  G_SORT_AREA_SIZE  CONSTANT NUMBER := 100000000;
  G_HASH_AREA_SIZE  CONSTANT NUMBER := 100000000;
  G_CURSOR_LIMIT    CONSTANT NUMBER := 10000;
  -- for BES enhancement
  G_BUSINESS_EVENT  CONSTANT VARCHAR2(60) := 'oracle.apps.as.tap.batch_mode';


/*-------------------------------------------------------------------------+
 |                             PRIVATE DATATYPES
 +-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PRIVATE VARIABLES
 *-------------------------------------------------------------------------*/
  g_run_mode                      VARCHAR2(7);

/*-------------------------------------------------------------------------*
 |                             PRIVATE ROUTINES SPECIFICATION
 *-------------------------------------------------------------------------*/
PROCEDURE Init(
    p_run_mode        IN  VARCHAR2,
    p_debug_mode      IN  VARCHAR2,
    p_trace_mode      IN  VARCHAR2,
    p_transaction_type     IN  VARCHAR2,
    p_worker_id       IN  VARCHAR2,
    p_actual_workers  IN  VARCHAR2,
    p_prev_request_id IN  NUMBER,
    p_seq_num         IN  NUMBER,
    px_terr_globals  IN OUT NOCOPY IEX_TERR_WINNERS_PUB.TERR_GLOBALS);
FUNCTION exist_subscription(p_event_name IN VARCHAR2) return VARCHAR2;
PROCEDURE RAISE_BES(p_terr_globals IN OUT NOCOPY IEX_TERR_WINNERS_PUB.TERR_GLOBALS);



/*------------------------------------------------------------------------*
 |                              PUBLIC ROUTINES
 *------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  Generate_Access_Records
 |
 | PURPOSE
 |  The main procedure of the concurrent program
 |
 | NOTES
 |
 |
 | HISTORY
 *-------------------------------------------------------------------------*/
PROCEDURE Generate_Access_Records(
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY VARCHAR2,
    p_run_mode        IN  VARCHAR2,
    p_debug_mode      IN  VARCHAR2,
    p_trace_mode      IN  VARCHAR2,
    p_transaction_type IN  VARCHAR2,
    p_worker_id       IN  VARCHAR2,
    p_actual_workers  IN  VARCHAR2,
    p_prev_request_id IN  NUMBER,
    p_seq_num         IN  NUMBER,
    p_assign_level     IN VARCHAR2)  -- Added for bug 8708291 pnaveenk multi level strategy
IS
l_terr_globals   IEX_TERR_WINNERS_PUB.TERR_GLOBALS;
l_status         BOOLEAN;
l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);
l_errbuf         VARCHAR2(4000);
l_retcode        VARCHAR2(255);
l_dyn_str        VARCHAR2(255);
l_temp           NUMBER;
l_sub_exist      VARCHAR2(1); -- to check where subscription exists

-- ffang 110703, enh2737659, New new mode TAP
l_target_type    VARCHAR2(15) := '';
-- end ffang 110703, enh2737659

l_wincount		NUMBER;

l_percent_analysed   NUMBER;
l_acc_count          NUMBER;
l_org_id             NUMBER;


BEGIN

    g_debug_flag := p_debug_mode;
    IEX_TERR_WINNERS_PUB.g_debug_flag := p_debug_mode;
    BEGIN
      SELECT  org_id INTO L_ORG_ID
      FROM fnd_concurrent_requests
      WHERE request_id=p_prev_request_id;
    EXCEPTION WHEN OTHERS THEN
     l_org_id := NULL;
    END;

    IEX_TERR_WINNERS_PUB.Print_Debug('*** Starting  iextptwb.pls::Generate_Access_Records ***');
    --Bug5043777. Fix By LKKUMAR. Start.
    MO_GLOBAL.INIT('IEX');
    IF (l_org_id IS NOT NULL) THEN
        MO_GLOBAL.SET_POLICY_CONTEXT('S',l_org_id);
    ELSE
        MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);
    END IF;

    IF (MO_GLOBAL.GET_CURRENT_ORG_ID IS NULL) THEN
      IEX_TERR_WINNERS_PUB.Print_Debug('Operating Unit Set :  ' || 'All');
    ELSE
      IEX_TERR_WINNERS_PUB.Print_Debug('Operating Unit Set :  ' || MO_GLOBAL.GET_OU_NAME(MO_GLOBAL.GET_CURRENT_ORG_ID));
    END IF;
    --Bug5043777. Fix By LKKUMAR. End.


    l_percent_analysed :=nvl(TO_NUMBER(fnd_profile.value('IEX_TAP_PERCENT_ANALYSED')),20);
    IF p_run_mode = IEX_ATA_PUB.G_TOTAL_MODE THEN
         l_target_type := 'TOTAL';
    ELSIF p_run_mode = IEX_ATA_PUB.G_NEW_MODE THEN
         l_target_type := 'INCREMENTAL';
    END If;


-- Set the Global variables
    Init(
      p_run_mode,
      p_debug_mode,
      p_trace_mode,
      p_transaction_type,
      p_worker_id,
      p_actual_workers,
      p_prev_request_id,
      p_seq_num,
      l_terr_globals);

    COMMIT;

    --

    BEGIN
       IEX_TERR_WINNERS_PUB.Print_Debug('Starting JTY_ASSIGN_BULK_PUB.get_winners for worker '|| p_worker_id);

        JTY_ASSIGN_BULK_PUB.get_winners(
        p_api_version_number    => 1.0,
        p_init_msg_list         => FND_API.G_FALSE,
        p_source_id             => -1600,
        p_trans_id              => -1601,
        p_program_name          => 'COLLECTIONS/CUSTOMER PROGRAM',
        p_mode                  => l_target_type,
        p_percent_analyzed      => l_percent_analysed,
        p_worker_id             => p_worker_id, -- the worker_id
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        ERRBUF                  => l_errbuf,
        RETCODE                 => l_retcode
        );

        IEX_TERR_WINNERS_PUB.Print_Debug('Completed JTY_ASSIGN_BULK_PUB.get_winners for worker '
        || p_worker_id || ' with status ' || l_return_status);

	IEX_TERR_WINNERS_PUB.Print_Debug('Message from JTY_ASSIGN_BULK_PUB.get_winners for worker ' ||
	l_msg_data);

        COMMIT;
       EXCEPTION WHEN OTHERS THEN
        IEX_TERR_WINNERS_PUB.Print_Debug('Error in JTY_ASSIGN_BULK_PUB.get_winners for worker '|| p_worker_id ||
	' '|| SQLERRM);
        IEX_TERR_WINNERS_PUB.Print_Debug('Error buffer ' || l_errbuf);
       END;

       SELECT count(*) INTO  l_acc_count FROM jtf_tae_1600_cust_winners;
       IEX_TERR_WINNERS_PUB.Print_Debug('Number of records in jtf_tae_1600_cust_winners : ' || l_acc_count );


    --

-- Set the Session parameters
   IEX_ATA_PUB.Set_Area_Sizes;

/*   Nothing is done for pre-cleaning.  kasreeni 4/20/2005 */

-- Pre-cleaning of AS_ACCESSES_ALL and AS_TERRITORY_ACCESSES.
   -- This is to be called if the Profile Option for Dup Res Deletion on address_id is enabled.
    IF(l_terr_globals.enable_dups_rs_del = 'Y' ) THEN
      IEX_TERR_ASSIGNMENT_CLEANUP.Cleanup_Duplicate_Resources(
          x_errbuf        => l_errbuf,
          x_retcode       => l_retcode,
          p_terr_globals  => l_terr_globals);
    END IF;

    IF l_terr_globals.transaction_type = 'ACCOUNT' THEN
      IEX_PROCESS_ACCOUNT_WINNERS.Process_Account_Records(
        x_errbuf        => l_errbuf,
        x_retcode       => l_retcode,
        p_terr_globals  => l_terr_globals,
	p_assignlevel =>  p_assign_level );  -- Changed for bug 8708291 pnaveenk multi level strategy
    END IF;



/*
-- Cleanup AS_TERRITORY_ACCESSES Records. Overload this procedure if LEAD Processing Goes Away.
   -- Cleanup Terr Accesses for Lead, if the Lead Processing is Enabled-AS_DISABLE_BATCH_LEAD_TERR_ASSIGNMENT
    IEX_TERR_ASSIGNMENT_CLEANUP.Cleanup_Terrritory_Accesses(
          x_errbuf        => l_errbuf,
          x_retcode       => l_retcode,
          p_terr_globals  => l_terr_globals);

-- Delete Unqualified Access Records for Account,Oppot,Lead.
IF l_terr_globals.transaction_type = 'ACCOUNT' THEN
    -- ffang 110703, enh2737659, New new mode TAP
    IEX_TERR_WINNERS_PUB.Print_Debug('Clean up for Accounts');
    IF p_run_mode = IEX_ATA_PUB.G_TOTAL_MODE THEN
        IEX_TERR_ASSIGNMENT_CLEANUP.Perform_Account_Cleanup(
              x_errbuf        => l_errbuf,
              x_retcode       => l_retcode,
              p_terr_globals  => l_terr_globals);
    END IF;
    -- end ffang 110703, enh 2737659

    -- BES enhancement

/**  Start Bug 4419234 07/08/2005  No business events for H release **/
/**
     l_sub_exist := iex_gar_pub.exist_subscription(G_BUSINESS_EVENT);

     IF ((l_return_status = 'S')  AND (l_sub_exist = 'Y')) THEN

		IEX_TERR_WINNERS_PUB.Print_Debug('--- Event subscription exists... ');
		IEX_TERR_WINNERS_PUB.Print_Debug('--- Event subscription raised from Account... ');

		RAISE_BES(l_terr_globals);


    END If;
**/

/**  End Bug 4419234 07/08/2005  No business events for H release **/

EXCEPTION
WHEN others THEN
      IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in IEX_GAR_PUB::Generate_Access_Records');
      IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || SQLERRM );
      errbuf := SQLERRM;
      retcode := SQLCODE;
      --retcode := FND_API.G_RET_STS_UNEXP_ERROR;
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END Generate_Access_Records;

/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  Init
 |
 | PURPOSE
 |  Initialize the global session variables
 |
 | NOTES
 |
 | HISTORY
 |
 *-------------------------------------------------------------------------*/


PROCEDURE Init(
    p_run_mode        IN  VARCHAR2,
    p_debug_mode      IN  VARCHAR2,
    p_trace_mode      IN  VARCHAR2,
    p_transaction_type     IN  VARCHAR2,
    p_worker_id       IN  VARCHAR2,
    p_actual_workers  IN  VARCHAR2,
    p_prev_request_id IN  NUMBER,
    p_seq_num         IN  NUMBER,
    px_terr_globals IN OUT NOCOPY IEX_TERR_WINNERS_PUB.TERR_GLOBALS)
IS
    l_ata_request_id_of_failed_gar number := -1;
    l_temp varchar(300) ;

BEGIN


-- Set the Global variables

    px_terr_globals.debug_flag := p_debug_mode;
    px_terr_globals.run_mode := p_run_mode;
    px_terr_globals.transaction_type := p_transaction_type;
    px_terr_globals.worker_id:=p_worker_id;


-- For Restart Mode, the prev_request_id is not the CURRENT ATA Request_id,
-- Rather it the request_id of the Failed GAR's ATA Request_id and so determine
-- the MODE and assign the value for px_terr_globals.prev_request_id accordingly.
-- Note: the Restart is applicable for the Failed GAR ONLY.
    --px_terr_globals.prev_request_id := p_prev_request_id;

    px_terr_globals.sequence := p_seq_num;

    px_terr_globals.bulk_size:= nvl(to_number(fnd_profile.value('AS_BULK_COMMIT_SIZE')),10000);

    /*** Not needed now
    if px_terr_globals.bulk_size < 10000 then
     px_terr_globals.bulk_size:= 10000;
    end if;
    **/

    IF p_trace_mode = 'Y'
    THEN
        l_temp := 'alter session set events = ''10046 trace name context forever, level 8'' ';
        EXECUTE IMMEDIATE l_temp;
    END IF;

    begin
      px_terr_globals.cursor_limit := nvl(to_number(fnd_profile.value('AS_TERR_RECORDS_TO_OPEN')) ,G_CURSOR_LIMIT);
      if px_terr_globals.cursor_limit < 1 then
         px_terr_globals.cursor_limit := G_CURSOR_LIMIT;
      end if;
    exception
    when others then
      px_terr_globals.cursor_limit := G_CURSOR_LIMIT;
    end;


    -- get profile option - USER_ID
    px_terr_globals.user_id := to_number(fnd_profile.value('USER_ID'));

    px_terr_globals.prog_appl_id := FND_GLOBAL.PROG_APPL_ID;

    -- get profile option -- CONC_PROGRAM_ID
    px_terr_globals.prog_id := to_number(fnd_profile.value('CONC_PROGRAM_ID'));

    -- get profile option -- CONC_LOGIN_ID
    px_terr_globals.last_update_login := to_number(fnd_profile.value('CONC_LOGIN_ID'));

    -- get profile option -- CONC_REQUEST_ID
    px_terr_globals.request_id := to_number(fnd_profile.value('CONC_REQUEST_ID'));

    -- If request_id = 0, select directly from sequence
    IF px_terr_globals.request_id = 0 OR px_terr_globals.request_id IS NULL
    THEN
        -- Get concurrent sequence
        IEX_TERR_WINNERS_PUB.Print_Debug('request_id is 0, get from sequence');
        SELECT fnd_concurrent_requests_s.nextval into px_terr_globals.request_id from dual;
    END IF;

    -- Get the profile option for AS_ENABLE_DUPS_RS_DELETION
    -- OS: Enable Duplicate Resource Deletion
    -- For Now this is asssumed to be 'Y'
    px_terr_globals.enable_dups_rs_del := 'Y';
    px_terr_globals.disable_lead_processing := FND_PROFILE.Value('AS_DISABLE_BATCH_LEAD_TERR_ASSIGNMENT') ;

    IF p_run_mode = 'RESTART' THEN
       --Fetch the p_prev_request_id from JTF_TAE_1001_ACCOUNT_TRANS
     begin
       select REQUEST_ID into l_ata_request_id_of_failed_gar from jtf_tae_1001_account_trans
       where request_id is not null and rownum < 2 ;
     exception
       when others then
       IEX_TERR_WINNERS_PUB.Print_Debug('Cannot restart- JTF_TAE_1001_ACCOUNT_TRANS is Empty');
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end;
     px_terr_globals.prev_request_id := l_ata_request_id_of_failed_gar;
    ELSE
       px_terr_globals.prev_request_id := p_prev_request_id;
    END IF;


-- Print the Global variables

    COMMIT;

EXCEPTION
WHEN others THEN
      IEX_TERR_WINNERS_PUB.Print_Debug('Exception: others in AS_GAR_PUB::Init');
      IEX_TERR_WINNERS_PUB.Print_Debug('SQLCODE ' || to_char(SQLCODE) ||
                           ' SQLERRM ' || SQLERRM);
      RAISE;
END Init;

/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  exist_subscription
 |
 | PURPOSE
 |  The purpose of this function is to check if a subscription exists for a
 |  given event. Returns 'Y' if the subscription exist.
 |
 | NOTES
 |
 | HISTORY
 *-------------------------------------------------------------------------*/

FUNCTION exist_subscription(p_event_name IN VARCHAR2) RETURN VARCHAR2

IS
 --Bug4930397. Commented this as we don't have events now. Fix by LKKUMAR ON 10-JAN-2006. Start.
 /*
 CURSOR c1 IS
 SELECT count(*)
 FROM   wf_events eve,
        wf_event_subscriptions sub
 WHERE  eve.name = p_event_name
 AND    eve.status = 'ENABLED'
 AND    eve.guid = sub.event_filter_guid
 AND    sub.status = 'ENABLED'
 AND    sub.source_type = 'LOCAL';


l_count NUMBER;
l_yn  VARCHAR2(1);

BEGIN

 open c1;

 fetch c1 into l_count;

 if l_count > 0 then
 l_yn := 'Y';
 end if;

 close c1;
  RETURN l_yn;
*/ --Bug4930397. Commented this as we don't have events now. Fix by LKKUMAR ON 10-JAN-2006. End.


BEGIN

RETURN ('N');
/*Bug4930397. Function Should return a value So, returning 'N'. We Shall remove this once we have
decided to have events for terrirory assignment*/


END exist_subscription;

/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  RAISE_BES
 |
 | PURPOSE
 |  Raises the event
 |
 | NOTES
 |
 | HISTORY
 *-------------------------------------------------------------------------*/

PROCEDURE RAISE_BES(p_terr_globals IN OUT NOCOPY IEX_TERR_WINNERS_PUB.TERR_GLOBALS) IS

l_mode                  VARCHAR2(7);
l_request_id            NUMBER;
l_ata_request_id        NUMBER;
l_worker_id             NUMBER;
l_transaction_type      VARCHAR2(30);
l_total_num_gar_workers NUMBER;
l_event_id              NUMBER;
x_errbuf                VARCHAR2(4000);
x_retcode               VARCHAR2(4000);
l_param_list            wf_parameter_list_t;
l_event_key             VARCHAR2(100);
l_msg                   VARCHAR2(4000);

BEGIN
/**  Start Bug 4419234 07/08/2005  No business events for H release **/
/**  nullifying the code
        l_mode := p_terr_globals.run_mode;
        l_request_id := p_terr_globals.request_id;
        l_ata_request_id := p_terr_globals.prev_request_id;
        l_worker_id := p_terr_globals.worker_id;
        l_transaction_type := p_terr_globals.transaction_type;

	SELECT count(*) into l_total_num_gar_workers
	FROM   fnd_concurrent_requests
	WHERE  parent_request_id = l_ata_request_id;

	 WF_EVENT.AddParameterToList(
                p_name => 'RUN_MODE',
                p_value => l_mode,
                p_parameterlist => l_param_list);

        WF_EVENT.AddParameterToList(
                p_name => 'REQUEST_ID',
                p_value => l_request_id,
                p_parameterlist => l_param_list);

        WF_EVENT.AddParameterToList(
                p_name => 'ATA_REQ_ID',
                p_value => l_ata_request_id,
                p_parameterlist => l_param_list);

        WF_EVENT.AddParameterToList(
                p_name => 'WORKER_ID',
                p_value => l_worker_id,
                p_parameterlist => l_param_list);

        WF_EVENT.AddParameterToList(
                p_name => 'TRANS_TYPE',
                p_value => l_transaction_type,
 		p_parameterlist => l_param_list);

        WF_EVENT.AddParameterToList(
                p_name => 'TOTAL_WORKERS',
                p_value => l_total_num_gar_workers,
                p_parameterlist => l_param_list);

	     begin

                SELECT AS_BUSINESS_EVENT_S.nextval INTO l_event_id FROM dual;

        	IEX_TERR_WINNERS_PUB.Print_Debug(' --- CALL WF_EVENT.RAISE.Start...');
        	IEX_TERR_WINNERS_PUB.Print_Debug(' --- l_event_id = '||l_event_id);
        	IEX_TERR_WINNERS_PUB.Print_Debug(' --- l_mode = '||l_mode);
        	IEX_TERR_WINNERS_PUB.Print_Debug(' --- l_request_id = '||l_request_id);
        	IEX_TERR_WINNERS_PUB.Print_Debug(' --- l_ata_request_id = '||l_ata_request_id);
        	IEX_TERR_WINNERS_PUB.Print_Debug(' --- l_worker_id = '||l_worker_id);
        	IEX_TERR_WINNERS_PUB.Print_Debug(' --- l_transaction_type = '||l_transaction_type);
        	IEX_TERR_WINNERS_PUB.Print_Debug(' --- l_total_num_gar_workers = '||l_total_num_gar_workers);


        	wf_event.raise (
                	p_event_name => G_BUSINESS_EVENT,
                	p_event_key => l_event_id,
                	p_parameters => l_param_list);

        	EXCEPTION

                WHEN others THEN

                        x_errbuf := SQLERRM;
                        x_retcode := SQLCODE;

        	IEX_TERR_WINNERS_PUB.Print_Debug(' --- x_errbuf = '||x_errbuf||' , x_retcode = '||x_retcode);

		end;

	l_param_list.DELETE;
	IEX_TERR_WINNERS_PUB.Print_Debug(' --- CALL WF_EVENT.RAISE.End...');

  **/

  null;

/**  End  Bug 4419234 07/08/2005  No business events for H release **/

END RAISE_BES;

END IEX_GAR_PUB;

/
