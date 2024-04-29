--------------------------------------------------------
--  DDL for Package Body AS_GAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_GAR" AS
/* $Header: asxgarpb.pls 120.2 2005/08/22 01:42 subabu noship $ */
---------------------------------------------------------------------------
--    Start of Comments
---------------------------------------------------------------------------
--    PACKAGE NAME:   AS_GAR
--    ---------------------------------------------------------------------
--    NOTES
--    -----
--    1: This package contains all the common procedures and functions
--       called from within the individual entity packages.
---------------------------------------------------------------------------
/*-------------------------------------------------------------------------+
 |                             PRIVATE CONSTANTS
 +-------------------------------------------------------------------------*/
 G_CURSOR_LIMIT    CONSTANT NUMBER := 10000;
 G_BUSINESS_EVENT  CONSTANT VARCHAR2(60) := 'oracle.apps.as.tap.batch_mode';
/*-------------------------------------------------------------------------+
 |                             PRIVATE DATATYPES
 +-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*
 |                             PRIVATE VARIABLES
 *-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------*
 |                             PRIVATE ROUTINES SPECIFICATION
 *-------------------------------------------------------------------------*/
/*------------------------------------------------------------------------*
 |                              PUBLIC ROUTINES
 *------------------------------------------------------------------------*/

/************* Start Init ***********************************************/

PROCEDURE Init(
    p_run_mode        IN  VARCHAR2,
    p_worker_id       IN  VARCHAR2,
    px_terr_globals IN OUT NOCOPY AS_GAR.TERR_GLOBALS)
IS
    l_ata_request_id_of_failed_gar number := -1;
    l_temp varchar(300) ;

BEGIN
    AS_GAR.LOG('*** (GAR) asxgarpb.pls::AS_GAR::Init() ***');

-- Set the Global variables

    px_terr_globals.run_mode := p_run_mode;
    px_terr_globals.worker_id :=p_worker_id;
    px_terr_globals.bulk_size := nvl(to_number(fnd_profile.value('AS_BULK_COMMIT_SIZE')),10000);
    px_terr_globals.cursor_limit := nvl(to_number(fnd_profile.value('AS_TERR_RECORDS_TO_OPEN')) ,10000);
    px_terr_globals.user_id := to_number(fnd_profile.value('USER_ID'));
    px_terr_globals.prog_appl_id := FND_GLOBAL.PROG_APPL_ID;
    px_terr_globals.prog_id := to_number(fnd_profile.value('CONC_PROGRAM_ID'));
    px_terr_globals.last_update_login := to_number(fnd_profile.value('CONC_LOGIN_ID'));
    px_terr_globals.request_id := to_number(fnd_profile.value('CONC_REQUEST_ID'));

    -- If request_id = 0, select directly from sequence
    IF px_terr_globals.request_id = 0 OR px_terr_globals.request_id IS NULL
    THEN
        -- Get concurrent sequence
        AS_GAR.LOG('request_id is 0, get from sequence');
        SELECT fnd_concurrent_requests_s.nextval into px_terr_globals.request_id from dual;
    END IF;

    COMMIT;

EXCEPTION
WHEN others THEN
      AS_GAR.LOG('Exception: others in AS_GAR_PUB::Init');
      AS_GAR.LOG('SQLCODE ' || to_char(SQLCODE) ||
                           ' SQLERRM ' || SQLERRM);
      RAISE;
END Init;

/*************   End Init ***********************************************/

/************* Start Exist Subscription *********************************/

FUNCTION exist_subscription(p_event_name IN VARCHAR2) RETURN VARCHAR2

IS

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

END exist_subscription;

/*************   End Exist Subscription *********************************/

/************* Start Raise_BE *******************************************/

PROCEDURE Raise_BE(p_terr_globals IN OUT NOCOPY AS_GAR.TERR_GLOBALS) IS

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

        l_mode := p_terr_globals.run_mode;
        l_request_id := p_terr_globals.request_id;
        l_worker_id := p_terr_globals.worker_id;


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
                p_name => 'WORKER_ID',
                p_value => l_worker_id,
                p_parameterlist => l_param_list);

	     begin

                SELECT AS_BUSINESS_EVENT_S.nextval INTO l_event_id FROM dual;

        	AS_GAR.LOG(' --- CALL WF_EVENT.RAISE.Start...');
        	AS_GAR.LOG(' --- l_event_id = '||l_event_id);
        	AS_GAR.LOG(' --- l_mode = '||l_mode);
        	AS_GAR.LOG(' --- l_request_id = '||l_request_id);
        	AS_GAR.LOG(' --- l_worker_id = '||l_worker_id);


        	wf_event.raise (
                	p_event_name => G_BUSINESS_EVENT,
                	p_event_key => l_event_id,
                	p_parameters => l_param_list);

        	EXCEPTION

                WHEN others THEN

                        x_errbuf := SQLERRM;
                        x_retcode := SQLCODE;

        	AS_GAR.LOG(' --- x_errbuf = '||x_errbuf||' , x_retcode = '||x_retcode);

		end;

	l_param_list.DELETE;
	AS_GAR.LOG(' --- CALL WF_EVENT.RAISE.End...');


END Raise_BE;

/*************   End Raise_BE *******************************************/


PROCEDURE LOG_EXCEPTION (msg IN VARCHAR2, errbuf IN VARCHAR2, retcode IN VARCHAR2) IS
BEGIN
   --dbms_output.put_line(Message Exception : '|| msg||errbuf||retcode);
   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'SALES_TAP', msg||errbuf||retcode);
   END IF;
END;

PROCEDURE LOG (msg IN VARCHAR2) IS
BEGIN
   IF AS_GAR.G_DEBUG_FLAG = 'Y' THEN
   -- dbms_output.put_line('msg '|| msg);
     IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
  	     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'SALES_TAP', msg );
     END IF;
   END IF;
END;

PROCEDURE SETTRACE IS
	l_str VARCHAR2(500);
BEGIN
    l_str := 'ALTER SESSION SET EVENTS = ''10046 TRACE NAME CONTEXT FOREVER, LEVEL 8'' ';
    EXECUTE IMMEDIATE l_str;
END;


PROCEDURE SET_AREA_SIZES
IS
    st varchar2(500);
    sort_size NUMBER := 100000000;
    hash_size NUMBER := 100000000;
    s number;

BEGIN
    -- Alter session to set sort area size and hash area size
    sort_size := fnd_profile.value('AS_SORT_AREA_SIZE_FOR_TAP');
    IF sort_size is not NULL and sort_size > 0 THEN
        st := 'ALTER SESSION SET SORT_AREA_SIZE = ' || sort_size;
        EXECUTE IMMEDIATE st;
        select value into s from V$PARAMETER where name = 'sort_area_size';
	AS_GAR.LOG( AS_GAR.G_SETAREASIZE || AS_GAR.G_PROCESS ||' Sort Area Size' || s);
    END IF;

    hash_size := fnd_profile.value('AS_HASH_AREA_SIZE_FOR_TAP');
    IF hash_size is not NULL and hash_size > 0 THEN
        st := 'ALTER SESSION SET HASH_AREA_SIZE = ' || hash_size;
        EXECUTE IMMEDIATE st;
        select value into s from V$PARAMETER where name = 'hash_area_size';
	AS_GAR.LOG( AS_GAR.G_SETAREASIZE || AS_GAR.G_PROCESS ||' Hash Area size' || s);
    END IF;
END Set_Area_Sizes;
END AS_GAR;

/
