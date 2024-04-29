--------------------------------------------------------
--  DDL for Package Body IEX_ATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_ATA_PUB" as
/* $Header: iextpinb.pls 120.16.12010000.5 2009/07/31 20:01:27 schekuri ship $ */
PROCEDURE Set_Up(
    px_acct_qual_tbl         IN OUT NOCOPY QUAL_LIST_TBL_TYPE);

PROCEDURE Concurrent_Profile_Options;

PROCEDURE Prepare_Parallel_Processing(
    P_Request_Id                 NUMBER,
    P_Prev_Request_Id            NUMBER,
    P_Run_Mode                   VARCHAR2,
    P_AccountCount               NUMBER,
    P_MinNumParallelProc         NUMBER,
    P_NumChildAccountWorker      NUMBER,
    X_ActualAccountWorkersUsed   OUT NOCOPY NUMBER);


/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC ROUTINES
 |
 *-------------------------------------------------------------------------*/


/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  Assign_Territory_Accesses
 |
 | PURPOSE
 |
 |
 *-------------------------------------------------------------------------*/

PROCEDURE Assign_Territory_Accesses(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    P_ORG_ID              IN NUMBER,
    P_STR_LEVEL           IN VARCHAR2  -- added for bug 8708291 multi level strategy
   )
   --Bug5043777 Removed the parameters which is no longer in use.
IS
    p_debug_mode            VARCHAR2(240);
    p_trace_mode          VARCHAR2(240);
    p_prev_request_id      NUMBER(24);
    p_ext_param1          VARCHAR2(240);
    p_ext_param2           VARCHAR2(240);
    p_ext_param3          VARCHAR2(240);

    p_trans_type_acc  CONSTANT VARCHAR2(30) := 'ACCOUNT';

    -- account qualifiers array of structure
    l_acct_qual_tbl             QUAL_LIST_TBL_TYPE;
    l_req_id	                NUMBER;
    l_msg	                VARCHAR2(2000);
    l_number	                NUMBER := 1;
    l_status                    BOOLEAN;
    p_ActualAccountWorkersUsed  NUMBER :=0;
    l_call_pre_uhk              BOOLEAN;
    l_call_post_uhk             BOOLEAN;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_acc_count                 NUMBER := 0;
    l_return_status             VARCHAR2(30);
    lX_Msg_Count                NUMBER;
    lX_Msg_Data                 VARCHAR2(32767);
    lx_retcode                  VARCHAR2(100);
    lx_errbuf                   VARCHAR2(32767);
    l_temp                      VARCHAR2(3000);

    --l_terr_globals   AS_TERR_WINNERS_PUB.TERR_GLOBALS;
    l_errbuf                    VARCHAR2(4000);
    l_retcode                   VARCHAR2(255);
    l_target_type               VARCHAR2(50);

    l_percent_analysed          NUMBER(15);

    l_debug                     NUMBER(15);
    l_AssignLevel               VARCHAR2(20);  -- Added by gnramasa on 29/08/2006 for bug # 5487449
    l_date_str      VARCHAR2(255);
    --Begin Bug 7697167 27-Jan-2009 barathsr
    l_req_id_lst IEX_UTILITIES.t_numbers;
    cnt number:=0;--23/01
    uphase VARCHAR2(255);
    dphase VARCHAR2(255);
    ustatus VARCHAR2(255);
    dstatus VARCHAR2(255);
    l_bool BOOLEAN;
    message VARCHAR2(32000);
    --End Bug 7697167 27-Jan-2009 barathsr
    l_str_level_count number; -- Added for bug 8708291 pnaveenk multi level strategy
    l_str_status varchar2(1); -- Added for bug 8708291 pnaveenk multi level strategy
 BEGIN
    --Bug5043777 Removed the parameters which is no longer in use. Fix By LKKUMAR. Start.
    MO_GLOBAL.INIT('IEX');

    IF (P_ORG_ID) IS NULL THEN
     MO_GLOBAL.SET_POLICY_CONTEXT('M',NULL);
    ELSE
     MO_GLOBAL.SET_POLICY_CONTEXT('S',P_ORG_ID);
    END IF;

    IEX_DEBUG('Program iextpinb.pls : *** IEX_ATA_PUB.Assign_Territory_Access starts ***');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Program iextpinb.pls : *** IEX_ATA_PUB.Asssign_Territory_Access starts ***');
    FND_FILE.put_line(fnd_file.log, ' Strategy Level' || P_STR_LEVEL);
    l_debug := NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'),20);
    FND_FILE.put_line(fnd_file.log,'Value of Profile IEX: Debug Level(IEX_DEBUG_LEVEL) is : ' || l_debug);
    FND_FILE.put_line(fnd_file.log,'Operating Unit is : ' || MO_GLOBAL.GET_CURRENT_ORG_ID );
    --Start changes by gnramasa on 29/08/2006 for bug # 5487449
    l_Assignlevel:= NVL(FND_PROFILE.VALUE('IEX_ACCESS_LEVEL'),'PARTY');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Territory Assignment Level, Profile IEX: Territory Access Level(IEX_ACCESS_LEVEL) := ' ||l_Assignlevel);

    -- Start for bug 8708291 pnaveenk
/*    If iex_utilities.validate_running_level(l_Assignlevel) <> 'Y' then
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Territory Assignment Level at Profile IEX: Territory Level not exists in the Strategy Level set up');
    End if; */

    Begin

    SELECT count(*) into l_str_level_count
    FROM IEX_LOOKUPS_V
    WHERE LOOKUP_TYPE='IEX_RUNNING_LEVEL'
    AND iex_utilities.validate_running_level(LOOKUP_CODE)='Y';

    select iex_utilities.validate_running_level(decode(P_STR_LEVEL,'PARTY','CUSTOMER','ACCOUNT','ACCOUNT','BILLTOSITE','BILL_TO','BILL_TO'))
    into l_str_status
    from dual;

    If l_str_level_count > 1 then
       If P_STR_LEVEL is null then
          FND_FILE.PUT_LINE(FND_FILE.LOG, ' Multiple Strategy Levels being used.');
          FND_FILE.PUT_LINE(FND_FILE.LOG, ' Please select the value for Parameter Territory Level');
	  return;
       end if;

       if l_str_status = 'Y' then
	  l_Assignlevel := P_STR_LEVEL;
       else
          FND_FILE.put_line(fnd_file.log, p_str_level || ' is not a valid level');
	  return;
       end if;
    end if;

    Exception
    When Others then
      IEX_DEBUG(' Exception in finding strategy levels count');
    End;

     FND_FILE.PUT_LINE(FND_FILE.LOG, ' Territory Running Level is ' || l_Assignlevel);
    -- End for bug 8708291 pnaveenk


    IF (l_debug <10) THEN
      P_debug_mode := 'Y';
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Debug is Enabled , IEX: Debug Level(IEX_DEBUG_LEVEL) :' || l_debug);
    ELSE
      P_debug_mode := 'N';
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Debug is not Enabled , Profile IEX: Debug Level(IEX_DEBUG_LEVEL) : ' || l_debug || '. Please set this profile value < 10 to enable debug ');
    END IF;

    IF (l_debug =1) THEN
      P_trace_mode := 'Y';
    ELSE
      P_trace_mode := 'N';
    END IF;

    G_debug_flag := P_debug_mode;
    G_trace_mode := P_trace_mode;

    IF p_trace_mode = 'Y' THEN
        l_temp := 'alter session set events = ''10046 trace name context forever, level 8'' ';
        EXECUTE IMMEDIATE l_temp;
	FND_FILE.PUT_LINE(FND_FILE.LOG,'SQL Trace is Enabled , IEX: Debug Level(IEX_DEBUG_LEVEL) = 1');
    ELSE
        FND_FILE.PUT_LINE(FND_FILE.LOG,'SQL Trace is not Enabled , IEX: Debug Level(IEX_DEBUG_LEVEL) <> 1');
    END IF;
   --End changes by gnramasa on 29/08/2006 for bug # 5487449
   --Bug5043777 Removed the parameters which is no longer in use. Fix By LKKUMAR. End.

    iex_ata_pub.g_debug_flag := p_debug_mode;


    l_call_pre_uhk := JTF_USR_HKS.Ok_to_execute('IEX_ATA_PUB',
                                                'Assign_Territory_Accesses',
                                                'B','C');
    IF l_call_pre_uhk THEN
        IEX_DEBUG('Call pre user hook is true');
        AS_ATA_UHK.ATA_Pre (
            p_api_version_number    =>  2.0,
            p_init_msg_list         =>  FND_API.G_FALSE,
            p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
            p_commit                =>  FND_API.G_FALSE,
            p_param1                =>  p_ext_param1,
            p_param2                =>  p_ext_param2,
            p_param3                =>  p_ext_param3,
            x_return_status         =>  l_return_status,
            x_msg_count             =>  l_msg_count,
            x_msg_data              =>  l_msg_data);
    END IF;

    -- call SetUp() to verify parameters and set global variables and arrays
    Set_Up(l_acct_qual_tbl);

    g_request_id      := TO_NUMBER(fnd_profile.value('CONC_REQUEST_ID'));
    g_debug_flag      := p_debug_mode;
    g_run_mode        := 'TOTAL'; --Bug5043777
    g_prev_request_id := p_prev_request_id;


    Set_Area_Sizes;
    COMMIT;
/*
    IF g_run_mode = G_TOTAL_MODE THEN
	IEX_DEBUG('Calling IEX_ATA_TOTAL.Load_All');
        IEX_ATA_TOTAL.Load_All(
            g_user_id, g_last_update_login, g_prog_appl_id, g_prog_id,
            g_request_id, g_num_rollup_days, g_conversion_type);
    END IF;
*/
    l_call_post_uhk := JTF_USR_HKS.Ok_to_execute('IEX_ATA_PUB',
                                                 'Assign_Territory_Accesses',
                                                 'A','C');

    IF l_call_post_uhk THEN
        IEX_DEBUG('Call post user hook is true');

        AS_ATA_UHK.ATA_Post (
            p_api_version_number    =>  2.0,
            p_init_msg_list         =>  FND_API.G_FALSE,
            p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
            p_commit                =>  FND_API.G_FALSE,
            p_param1                =>  p_ext_param1,
            p_param2                =>  p_ext_param2,
            p_param3                =>  p_ext_param3,
            p_request_id            =>  g_request_id,
            x_return_status         =>  l_return_status,
            x_msg_count             =>  l_msg_count,
            x_msg_data              =>  l_msg_data);

        IEX_DEBUG('user hook return: ' || l_return_status);
    END IF;

    g_min_num_parallel_proc:=nvl(TO_NUMBER(fnd_profile.value('IEX_TERR_MIN_NUM_PARALLEL_PROC')),1);
    IEX_DEBUG('Min records for Parallel Processing (IEX_TERR_MIN_NUM_PARALLEL_PROC)=' || g_min_num_parallel_proc);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Profile IEX: Territory Minimum Number of Records for Parallel Processing : ' || g_min_num_parallel_proc);

    g_NumChildAccountWorker:=nvl(TO_NUMBER(fnd_profile.value('IEX_TAP_NUM_CHILD_ACCOUNT_WORKERS')),1);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Profile IEX: Number of Child Account Workers for TAP : ' || g_NumChildAccountWorker);
    if g_NumChildAccountWorker < 1  then
       g_NumChildAccountWorker:=1;
    elsif g_NumChildAccountWorker > 10  then
       g_NumChildAccountWorker:=10;
       IEX_DEBUG('Max no. of Parallel Account Workers allowed for TAP is:' || g_NumChildAccountWorker);
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Max no. of Parallel Account Workers allowed for TAP is : ' || g_NumChildAccountWorker);
    end if;
    IEX_DEBUG('Max Parallel Account Workers (IEX_TAP_NUM_CHILD_ACCOUNT_WORKERS)=' || g_NumChildAccountWorker);

    l_percent_analysed :=nvl(TO_NUMBER(fnd_profile.value('IEX_TAP_PERCENT_ANALYSED')),20);
    l_target_type := 'TOTAL';

     BEGIN
      IEX_DEBUG('Starting JTY_ASSIGN_BULK_PUB.collect_trans_data...');
      select to_char( sysdate, 'DD-Mon-YYYY HH24:MI:SS') into l_date_str from dual;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'---' || l_date_str || '--------------------------');
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Starting JTY_ASSIGN_BULK_PUB.collect_trans_data...');
      JTY_ASSIGN_BULK_PUB.collect_trans_data(
       p_api_version_number    => 1.0,
       p_init_msg_list         => FND_API.G_FALSE,
       p_source_id             => -1600,
       p_trans_id              => -1601,
       p_program_name          => 'COLLECTIONS/CUSTOMER PROGRAM',
       p_mode                  => l_target_type,
       p_where                 => null,
       p_no_of_workers         => g_NumChildAccountWorker,
       p_percent_analyzed      => l_percent_analysed,
       p_request_id            => g_request_id,
       x_return_status         => l_return_status,
       x_msg_count             => lx_msg_count,
       x_msg_data              => lx_msg_data,
       ERRBUF                  => lx_errbuf,
       RETCODE                 => lx_retcode);
       IEX_DEBUG('Completed JTY_ASSIGN_BULK_PUB.collect_trans_data with status  ' || l_return_status);
       IEX_DEBUG('Message from JTY_ASSIGN_BULK_PUB.collect_trans_data ' ||lx_msg_data);
      select to_char( sysdate, 'DD-Mon-YYYY HH24:MI:SS') into l_date_str from dual;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Ending JTY_ASSIGN_BULK_PUB.collect_trans_data...');
       FND_FILE.PUT_LINE(FND_FILE.LOG,'---' || l_date_str || '--------------------------');
      EXCEPTION WHEN OTHERS THEN
       IEX_DEBUG('Error occured JTY_ASSIGN_BULK_PUB.collect_trans_data' ||SQLERRM);
       IEX_DEBUG('Error buffer ' || lx_errbuf);
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error occured JTY_ASSIGN_BULK_PUB.collect_trans_data' ||SQLERRM);
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error buffer ' || lx_errbuf);
      END;


     SELECT count(*) INTO  l_acc_count FROM jtf_tae_1600_cust_trans;
     IEX_DEBUG('Number of records in jtf_tae_1600_cust_trans : ' || l_acc_count );
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number of records in jtf_tae_1600_cust_trans : ' || l_acc_count );

     IEX_DEBUG('Analyse values and Prepare Parallel Processing ...' );
     -- populate worker_id in TRANS or NM_TRANS tables
      Prepare_Parallel_Processing(
       P_Request_Id                => g_request_id,
       P_Prev_Request_Id           => g_prev_request_id,
       P_Run_Mode                  => g_run_mode,
       P_AccountCount              => l_acc_count,
       P_MinNumParallelProc        => g_min_num_parallel_proc,
       P_NumChildAccountWorker     => g_NumChildAccountWorker,
       X_ActualAccountWorkersUsed  => p_ActualAccountWorkersUsed);
     IEX_DEBUG('Parallel Processing values analysed successfully...');

     IF (p_ActualAccountWorkersUsed = 0) THEN
       IEX_DEBUG('No Records in JTF Trans Table, Do the Setup and then run this program');
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Do the setup and run this program ');
     END IF;

     SELECT count(*) INTO  l_acc_count FROM jtf_tae_1600_cust_WINNERS;
     IEX_DEBUG('Number of records in jtf_tae_1600_cust_winners : ' || l_acc_count );
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number of records in jtf_tae_1600_cust_winners : ' || l_acc_count );

     -- submit concurrent request IEXGAR for ACCOUNT
     FOR i in 1..p_ActualAccountWorkersUsed LOOP
        --Bug5043777. Fix By LKKUMAR. Set the Context for Spawn Program. Start.
        fnd_request.set_org_id(mo_global.get_current_org_id);
        FND_FILE.put_line(fnd_file.log,'Operating Unit Before Submitting IEXGAR is : ' || mo_global.get_current_org_id  );
     --Bug5043777. Fix By LKKUMAR. Set the Context for Spawn Program. Start.

        IEX_DEBUG('Submiting IEXGAR(iextptwb.pls IEX_GAR_PUB.Generate_Access_Records)');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Submiting IEXGAR(iextptwb.pls IEX_GAR_PUB.Generate_Access_Records) ');
        l_req_id := FND_REQUEST.SUBMIT_REQUEST('IEX',
             'IEXGAR',
             'Generate Access Records Collections',
             '',
             FALSE,
             'TOTAL', --Bug5043777
             p_debug_mode,
             'N',
             p_trans_type_acc,
             i, -- worker id
             p_ActualAccountWorkersUsed,
             g_request_id,
             l_number ,
         --    CHR(0),
	     l_Assignlevel);  -- Changed for bug 8708291 multi level strategy

     commit;--Added for Bug 7697167 28-Jan-2009 barathsr

	IF l_req_id = 0 THEN
            l_msg:=FND_MESSAGE.GET;
            IEX_DEBUG(l_msg);
        END IF;
 	IEX_DEBUG('Submitted request for IEXGAR :' || l_req_id|| '  Worker Id:'||i);
 	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Submitted request for IEXGAR :' || l_req_id|| '  Worker Id:'||i);
	l_req_id_lst(i):=l_req_id;--Added for Bug 7697167 28-Jan-2009 barathsr

    END LOOP;


--Begin Bug 7697167 27-Jan-2009 barathsr
cnt:=l_req_id_lst.count;
IEX_DEBUG('Count of req_ids:' ||l_req_id_lst.count);
FND_FILE.PUT_LINE(FND_FILE.LOG,'Count of req_ids:' ||l_req_id_lst.count);
while cnt > 0 loop
   for k in l_req_id_lst.first..l_req_id_lst.last
   loop
     if l_req_id_lst(k)<>-1 then
          l_bool := FND_CONCURRENT.wait_for_request(
                                   request_id =>l_req_id_lst(k),
                                   interval   =>30,
                                   max_wait   =>144000,
                                   phase      =>uphase,
                                   status     =>ustatus,
                                   dev_phase  =>dphase,
                                   dev_status =>dstatus,
                                   message    =>message);
           IF dphase = 'COMPLETE'  then
             l_req_id_lst(k):=-1;
             cnt:=cnt-1;
           END If; --dphase
    end if;
   end loop;
end loop;
--End Bug 7697167 27-Jan-2009 barathsr



    IEX_DEBUG('Program iextpinb.pls : *** IEX_ATA_PUB.Assign_Territory_Access Ends ***');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Program iextpinb.pls : *** IEX_ATA_PUB.Assign_Territory_Access Ends ***');
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IEX_DEBUG('Cannot Start');

    WHEN others THEN
        IEX_DEBUG('Exception: others in Assign_Territory_Accesses');
        IEX_DEBUG('SQLCODE ' || to_char(SQLCODE) ||
                 ' SQLERRM ' || substr(SQLERRM, 1, 100));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception: others in Assign_Territory_Accesses');
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'SQLCODE ' || to_char(SQLCODE) ||
                 ' SQLERRM ' || substr(SQLERRM, 1, 100));

        errbuf := SQLERRM;
        retcode := FND_API.G_RET_STS_UNEXP_ERROR;
        l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);

END Assign_Territory_Accesses;


/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  Set_Up
 |
 | PURPOSE
 |  Set up global variables and arrays
 |
 *-------------------------------------------------------------------------*/

PROCEDURE Set_Up(
    px_acct_qual_tbl         IN OUT NOCOPY QUAL_LIST_TBL_TYPE
)
IS
    l_profile_value    VARCHAR2(240);
BEGIN
    IEX_DEBUG('Started doing the Set Up');

    Concurrent_Profile_Options;

    -- get profile option - AS_MC_MAX_ROLL_DAYS
    /*
    l_profile_value := fnd_profile.value('AS_MC_MAX_ROLL_DAYS');
    IF RTRIM(l_profile_value) IS NULL THEN
        g_num_rollup_days := 0;
    ELSE
        g_num_rollup_days := TO_NUMBER(l_profile_value);
    END IF;

    -- get profile option - AS_MC_DAILY_CONVERSION_TYPE
    g_conversion_type := fnd_profile.value('AS_MC_DAILY_CONVERSION_TYPE');
    */
    -- get profile option - number of child process
    g_num_child_processes :=
          TO_NUMBER(fnd_profile.value('IEX_TERR_NUM_CHILD_PROCESSES'));
    IEX_DEBUG('Mininum Child Process ' || g_num_child_processes);
    -- get profile option - min number for parallel processing
    g_min_num_parallel_proc :=
          TO_NUMBER(NVL(fnd_profile.value('IEX_TERR_MIN_NUM_PARALLEL_PROC'), 3));
    IEX_DEBUG('Minimum Number of Prallel Proc ' || g_min_num_parallel_proc);

    -- fill in Account Qualifier Array
    --Bug4654733. Fix by LKKUMAR on 06-Sep-2005. Remove AS dependency. Start
    /*
    AS_Tata_Process_Changed_Terr.Load_Acct_Qual_Array;
    g_num_acct_qual := AS_Tata_Process_Changed_Terr.G_Account_Qualifier_Count; */
    --Bug4654733. Fix by LKKUMAR on 06-Sep-2005. Remove AS dependency. End.

EXCEPTION
    WHEN others THEN
        IEX_DEBUG('Exception: others in set_up');
        IEX_DEBUG('SQLCODE ' || to_char(SQLCODE) ||
                 ' SQLERRM ' || substr(SQLERRM, 1, 100));

        RAISE;
END Set_Up;


/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  Concurrent_Profile_Options
 |
 | PURPOSE
 |  Get concurrent profile options
 |
 *-------------------------------------------------------------------------*/

PROCEDURE Concurrent_Profile_Options
IS
    l_temp_seq    NUMBER;
    l_retvalue    VARCHAR2(20);

    CURSOR c_get_conseq_cur IS
        SELECT fnd_concurrent_requests_s.nextval
        FROM   dual;
BEGIN


    -- get profile option - USER_ID
    g_user_id := TO_NUMBER(fnd_profile.value('USER_ID'));

    -- get profile option -- CONC_PROGRAM_APPLICATION_ID
    g_prog_appl_id := FND_GLOBAL.PROG_APPL_ID;

    -- get profile option -- CONC_PROGRAM_ID
    g_prog_id := TO_NUMBER(fnd_profile.value('CONC_PROGRAM_ID'));

    -- get profile option -- CONC_LOGIN_ID
    g_last_update_login := TO_NUMBER(fnd_profile.value('CONC_LOGIN_ID'));

    -- get profile option -- CONC_REQUEST_ID
    g_request_id := TO_NUMBER(fnd_profile.value('CONC_REQUEST_ID'));


    -- If g_request_id = 0, select directly from sequence
    IF g_request_id = 0
    THEN
        -- Get concurrent sequence
        OPEN c_get_conseq_cur;
        FETCH c_get_conseq_cur INTO l_temp_seq;
        CLOSE c_get_conseq_cur;

        g_request_id := l_temp_seq;
    END IF;
EXCEPTION
    WHEN others THEN
        IEX_DEBUG('Exception: others in concurrent_profile_options');
        IEX_DEBUG('SQLCODE ' || to_char(SQLCODE) ||
                 ' SQLERRM ' || substr(SQLERRM, 1, 100));

        RAISE;
END Concurrent_Profile_Options;

/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  IEX_DEBUG
 |
 | PURPOSE
 |  write debug message
 *-------------------------------------------------------------------------*/

PROCEDURE IEX_DEBUG( msg in VARCHAR2)
IS
    l_length        NUMBER;
    l_start         NUMBER := 1;
    l_substring     VARCHAR2(255);

    l_base          VARCHAR2(12);
    l_date_str      VARCHAR2(255);

BEGIN
    IF g_debug_flag = 'Y'
    THEN
        select to_char( sysdate, 'DD-Mon-YYYY HH24:MI:SS') into l_date_str from dual;
        FND_FILE.PUT_LINE(FND_FILE.LOG,'---' || l_date_str || '--------------------------');

        -- chop the message to 255 long
        l_length := length(msg);
        WHILE l_length > 255 LOOP
            l_substring := substr(msg, l_start, 255);
            FND_FILE.PUT_LINE(FND_FILE.LOG, l_substring);
            --Bug4221324. Fix by LKKUMAR on 06-Dec-2005. Start.
            IEX_DEBUG_PUB.logmessage(l_substring);
            --Bug4221324. Fix by LKKUMAR on 06-Dec-2005. End.
            -- dbms_output.put_line(l_substring);

            l_start := l_start + 255;
            l_length := l_length - 255;
        END LOOP;

        l_substring := substr(msg, l_start);
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_substring);
       --Bug4221324. Fix by LKKUMAR on 06-Dec-2005. Start.
        IEX_DEBUG_PUB.logmessage(l_substring);
        --Bug4221324. Fix by LKKUMAR on 06-Dec-2005. End.
        -- dbms_output.put_line(l_substring);
    END IF;
EXCEPTION
    WHEN others THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception: others in IEX_DEBUG');
        FND_FILE.PUT_LINE(FND_FILE.LOG,
                          'SQLCODE ' || to_char(SQLCODE) ||
                          ' SQLERRM ' || substr(SQLERRM, 1, 100));
END IEX_DEBUG;


/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  Set_Area_Sizes
 |
 | PURPOSE
 |  Set profile option values for sort area size and hash area size
 *-------------------------------------------------------------------------*/

PROCEDURE Set_Area_Sizes
IS
    st varchar2(500);
    sort_size NUMBER := 100000000;
    hash_size NUMBER := 100000000;
    s number;

BEGIN
    -- Alter session to set sort area size and hash area size
    sort_size := fnd_profile.value('IEX_SORT_AREA_SIZE_FOR_TAP');
    IF sort_size is not NULL and sort_size > 0 THEN
        st := 'ALTER SESSION SET SORT_AREA_SIZE = ' || sort_size;
        EXECUTE IMMEDIATE st;
        select value into s from V$PARAMETER where name = 'sort_area_size';
    END IF;
    IEX_DEBUG('Sort Area Size ' || s );

    hash_size := fnd_profile.value('IEX_HASH_AREA_SIZE_FOR_TAP');
    IF hash_size is not NULL and hash_size > 0 THEN
        st := 'ALTER SESSION SET HASH_AREA_SIZE = ' || hash_size;
        EXECUTE IMMEDIATE st;
        select value into s from V$PARAMETER where name = 'hash_area_size';
    END IF;
    IEX_DEBUG('Hash Area Size ' || s );
END Set_Area_Sizes;

/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  Prepare_Parallel_Processing
 |
 | PURPOSE
 |  Prepare the TRANS tables for parallel processing
 *-------------------------------------------------------------------------*/
PROCEDURE Prepare_Parallel_Processing(
    P_Request_Id                 NUMBER,
    P_Prev_Request_Id            NUMBER,
    P_Run_Mode                   VARCHAR2,
    P_AccountCount               NUMBER,
    P_MinNumParallelProc         NUMBER,
    P_NumChildAccountWorker      NUMBER,
    X_ActualAccountWorkersUsed   OUT NOCOPY NUMBER)
IS
    l_ActualWorker     NUMBER := 0;
    l_WorkerLoad       NUMBER := 0;

BEGIN

    IEX_DEBUG('*** Prepare_Parallel_Processing() *** - Start - ');
    X_ActualAccountWorkersUsed := 0;

    l_ActualWorker   := 0;
    l_WorkerLoad     := 0;

    l_WorkerLoad := CEIL(P_AccountCount / P_NumChildAccountWorker);
    If l_WorkerLoad < P_MinNumParallelProc then
        l_WorkerLoad := P_MinNumParallelProc;
    End If;

    l_ActualWorker := CEIL(P_AccountCount/l_WorkerLoad);
    IEX_DEBUG('Actual Worker Assigned : '||l_ActualWorker);

/*
    IF p_run_mode = G_TOTAL_MODE THEN
        UPDATE JTF_TAE_1001_ACCOUNT_TRANS
            SET worker_id = mod (trans_object_id, l_ActualWorker) + 1;
        IEX_DEBUG('UPDATE JTF_TAE_1001_ACCOUNT_TRANS.worker_id');
    ELSIF p_run_mode = G_NEW_MODE THEN
        UPDATE JTF_TAE_1001_ACCOUNT_NM_TRANS
            SET worker_id = mod (trans_object_id, l_ActualWorker) + 1;
        IEX_DEBUG('UPDATE JTF_TAE_1001_ACCOUNT_NM_TRANS.worker_id');
    END IF;
*/
    X_ActualAccountWorkersUsed := l_ActualWorker;

EXCEPTION
    WHEN others THEN
       IEX_DEBUG('Exception: others in Prepare_Parallel_Processing');
       IEX_DEBUG('SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || substr(SQLERRM, 1, 100));

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception: others in Prepare_Parallel_Processing');
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || substr(SQLERRM, 1, 100));
END Prepare_Parallel_Processing;


END IEX_ATA_PUB;

/
