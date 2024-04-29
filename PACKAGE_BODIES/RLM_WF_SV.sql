--------------------------------------------------------
--  DDL for Package Body RLM_WF_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_WF_SV" as
/*$Header: RLMDPWFB.pls 120.5.12000000.2 2007/04/09 10:12:14 sunilku ship $*/
/*========================== rlm_wf_sv =============================*/

--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);

FUNCTION Notification_ToUser(user_id NUMBER) RETURN VARCHAR2;
FUNCTION Notification_FromUser(responsibility_id NUMBER,
                               resp_appl_id NUMBER) RETURN VARCHAR2;

--
/*Bug 2581117 */
l_comp_start_time  NUMBER;
l_comp_end_time    NUMBER;
l_val_start_time   NUMBER;
l_val_end_time     NUMBER;
l_msg_text         VARCHAR2(32000);
--
PROCEDURE StartDSPProcess( errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY VARCHAR2,
                           p_Header_Id IN NUMBER,
                           v_Sch_rec   IN OUT NOCOPY rlm_interface_headers%ROWTYPE,
                           v_num_child IN NUMBER
)
IS
  --
  v_ItemKey          VARCHAR2(100) := to_char(p_Header_Id);
  v_ItemKeyNew       VARCHAR2(100) := 'END' || to_char(p_header_id) ;
  v_ItemType         VARCHAR2(30) := g_ItemType;
  v_ProcessName      VARCHAR2(30) := g_ProcessName;
  v_ScheduleNum      VARCHAR2(35) ;
  v_Customer         VARCHAR2(30) ;
  v_ScheduleGenDate  DATE;
  v_org_id           NUMBER;
  v_retcode          NUMBER;
  v_count            NUMBER;
    /*Bug 2581117 */
  v_start_time       NUMBER;
  v_end_time         NUMBER;
  v_wf_msg_text      VARCHAR2(32000);
  ---
  e_DSPFailed        EXCEPTION;

BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'StartDSPProcess');
     rlm_core_sv.dlog(C_DEBUG,'p_Header_Id ', p_Header_Id);
  END IF;
  --
  -- fnd_profile.get('ORG_ID', v_org_id);
  --
  g_num_child := v_num_child;
  v_org_id    := v_Sch_rec.org_id;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Org Id ', v_Sch_rec.org_id);
  END IF;
  --
  -- Bug#: 3053299 - Added Schedule Generation Date as argument
  --
  GetScheduleDetails(p_Header_Id, v_ScheduleNum, v_Customer, v_ScheduleGenDate);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'v_ScheduleNum ', v_ScheduleNum);
     rlm_core_sv.dlog(C_DEBUG,'v_Customer ', v_Customer);
  END IF;

  -- Abort the process if it has hung
  --
  BEGIN
  --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Aborting old processes');
    END IF;
    --
    wf_engine.AbortProcess(itemtype => v_ItemType,
                           itemkey => v_ItemKey);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'After abort bad process');
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Did not abort any process');
      END IF;
      --
  END;
  --
  -- Check whether Item has already been run in Workflow and purge it
  -- Bug 2756981: Set force to TRUE to allow child processes to be purged
  --
  wf_purge.Items(itemtype => v_ItemType,
                 itemkey  => v_ItemKey,
                 enddate  => sysdate,
                 docommit => FALSE,
		 force    => TRUE);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'After Purge for Item key ',p_Header_Id);
  END IF;
  --
  wf_engine.CreateProcess(v_ItemType, v_ItemKey, v_ProcessName);

  -- Set various Header Attributes

  wf_engine.SetItemUserKey(v_ItemType, v_ItemKey,v_ScheduleNum);
  --
  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'USER_ID',
                               FND_GLOBAL.USER_ID);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'APPLICATION_ID',
                               FND_GLOBAL.RESP_APPL_ID);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'REQUEST_ID',
                               FND_GLOBAL.CONC_REQUEST_ID);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'RESPONSIBILITY_ID',
                               FND_GLOBAL.RESP_ID);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'ORG_ID',
                               v_org_id);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'HEADER_ID',
                               p_Header_Id);

  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKey,
                               'SCHEDULE_NUMBER',
                               v_ScheduleNum);

  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKey,
                               'CUSTOMER_NAME',
                               v_Customer);

  -- Bug#: 3053299 - Setting the tokens for From User, To User and
  -- Schedule Generation Date
  --
  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKey,
                               'FROM_USER',
                               Notification_FromUser(FND_GLOBAL.RESP_ID,
                                                   FND_GLOBAL.RESP_APPL_ID));

  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKey,
                               'TO_USER',
                               Notification_ToUser(FND_GLOBAL.USER_ID));

  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKey,
                               'SCHED_GEN_DATE',
                               v_ScheduleGenDate);

  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Before Start Process ');
  END IF;
  --
 SELECT hsecs INTO v_start_time from v$timer;

  wf_engine.StartProcess(v_ItemType, v_ItemKey);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'After Start Process ');
  END IF;
  --
  v_retcode := wf_engine.GetItemAttrNumber(v_ItemType,v_ItemKey,'ERRORS_EXIST');
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,' Errors Status: ', v_retcode);
  END IF;
  --
  retcode := g_PROC_SUCCESS;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Before End Process ');
  END IF;
  --
  BEGIN
  --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Aborting old processes');
    END IF;
    --
    wf_engine.AbortProcess(itemtype => v_ItemType,
                           itemkey => v_ItemKeyNew);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'after abort bad process');
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Did not abort any process');
      END IF;
      --
  END;
  --
  -- Bug 2756981: Set force to TRUE to allow child processes to be purged
  --
  wf_purge.Items(itemtype => v_ItemType,
                 itemkey  => v_ItemKeyNew,
                 enddate  => sysdate,
                 docommit => FALSE,
		 force    => TRUE);
  --

  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Creating End Process ');
  END IF;
  --
  wf_engine.CreateProcess(v_ItemType, v_ItemKeyNew, 'RLMEND');
  --
  wf_engine.SetItemParent(v_ItemType,v_ItemKeyNew,v_ItemType,
    to_char(p_Header_Id), to_char(p_Header_Id));
  --
  wf_engine.SetItemUserKey(v_ItemType, v_ItemKeyNew,v_ScheduleNum);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Setting attributes End Process ');
  END IF;
  --
  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKeyNew,
                               'USER_ID',
                               FND_GLOBAL.USER_ID);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKeyNew,
                               'APPLICATION_ID',
                               FND_GLOBAL.RESP_APPL_ID);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKeyNew,
                               'REQUEST_ID',
                               FND_GLOBAL.CONC_REQUEST_ID);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKeyNew,
                               'RESPONSIBILITY_ID',
                               FND_GLOBAL.RESP_ID);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKeyNew,
                               'ORG_ID',
                               v_org_id);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKeyNew,
                               'HEADER_ID',
                               p_Header_Id);

  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKeyNew,
                               'SCHEDULE_NUMBER',
                               v_ScheduleNum);

  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKeyNew,
                               'CUSTOMER_NAME',
                               v_Customer);

-- Bug#: 3053299 - Setting the tokens for From User, To User
--		   and Schedule Generation Date


  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKeyNew,
                               'FROM_USER',
                               Notification_FromUser(FND_GLOBAL.RESP_ID,
                                                   FND_GLOBAL.RESP_APPL_ID));


  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKeyNew,
                               'TO_USER',
                               Notification_ToUser(FND_GLOBAL.USER_ID));

  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKeyNew,
                               'SCHED_GEN_DATE',
                               v_ScheduleGenDate);

  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Start EndProcess ');
  END IF;
  --
  wf_engine.StartProcess(v_ItemType, v_ItemKeyNew);

  -- Set various Header Attributes
/*
 -- Decided to return Sucess even if errors/warnings generated since process itself
 -- is successful according to Kathleen. Consistent with current DSP. Mohana
  retcode := v_retcode;
*/

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;

   SELECT hsecs INTO v_end_time FROM v$timer;
   v_wf_msg_text:= 'Time spent in Work Flow call - '||(v_end_time-v_start_time)/100 ;
   fnd_file.put_line(fnd_file.log,v_wf_msg_text);

EXCEPTION
   WHEN OTHERS THEN
      --
      retcode := g_PROC_ERROR;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Errors found ');
         rlm_core_sv.dlog(C_DEBUG,'Error: ',SUBSTR(SQLERRM,1,1500));
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
    --  rlm_core_sv.stop_debug;
      --
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END StartDSPProcess;


PROCEDURE ValidateDemand(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  --
  v_header_id          NUMBER;
  v_status             NUMBER;
  retcode              NUMBER;
  errbuf               VARCHAR2(2000);
  v_Progress           VARCHAR2(3) := '010';
  e_DPFailed           EXCEPTION;
  --

BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ValidateDemand');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;

    IF  (FUNCMODE = 'RUN') THEN
    -- Executable Statements
       v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
         rlm_core_sv.dlog(C_DEBUG,' Before Validate');
       END IF;
       --
       -- Bug 2868593
       SAVEPOINT s_ValidateDemand;
       --
       SELECT hsecs INTO l_val_start_time from v$timer;
       --
       rlm_validatedemand_sv.GroupValidateDemand(v_header_id, v_status);
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' After Validate v_status: ', v_status);
          rlm_core_sv.dlog(C_DEBUG,'g_schedule_PS', RLM_VALIDATEDEMAND_SV.g_schedule_PS);
       END IF;

       SELECT hsecs INTO l_val_end_time FROM v$timer;
       --
       IF v_status <> rlm_core_sv.k_PROC_ERROR THEN
       --
          IF RLM_VALIDATEDEMAND_SV.g_schedule_PS <> rlm_core_sv.k_PS_ERROR
          THEN
          --
            -- Archive Demand
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'Archiving');
            END IF;
	    --
            resultout :=  'COMPLETE:CONT';
            --
          ELSE
            -- No Archiving
            --
  	    IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'Not Archiving');
            END IF;
	    --
            resultout :=  'COMPLETE:ABT';
            --
          END IF;
          --
       ELSE
       --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'Not Archiving');
          END IF;
	  --
          resultout :=  'COMPLETE:ABT';
          --
       END IF;
       --

       IF (v_status = rlm_core_sv.k_PROC_ERROR) OR (rlm_validatedemand_sv.g_schedule_PS = rlm_core_sv.k_PS_ERROR) THEN
          --
          RAISE e_DPFailed;
          --
       END IF;
       --

       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_SDEBUG);
       END IF;
       ---
       RETURN;
       --
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','ValidateDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:ABT';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN e_DPFailed THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Validate Demand failed');
      END IF;
      --
      ROLLBACK TO s_ValidateDemand; /* Bug 2868593 */
      --
      rlm_dp_sv.UpdateGroupPS(v_header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR,
                        'ALL');
      --
      rlm_dp_sv.UpdateHeaderPS(v_header_id,
                     g_Sch_rec.schedule_header_id);
      --
      rlm_message_sv.dump_messages(v_header_id);
      rlm_message_sv.initialize_messages;
      --
      COMMIT;
      --
      wf_core.context('RLM_WF_SV','ValidateDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:ABT';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      --
      wf_core.context('RLM_WF_SV','ValidateDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:ABT';
      --
      rlm_dp_sv.UpdateGroupPS(v_header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR,
                        'ALL');
      --
      rlm_dp_sv.UpdateHeaderPS(v_header_id,
                     g_Sch_rec.schedule_header_id);
      --
      rlm_message_sv.sql_error('rlm_dp_sv.DemandProcessor', v_Progress);
      --
      rlm_message_sv.dump_messages(v_header_id);
      rlm_message_sv.initialize_messages;
      --
      COMMIT;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      --RAISE;

END ValidateDemand;

PROCEDURE ManageDemand(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  --
  v_header_id          NUMBER;
  v_status             NUMBER;
  e_DPFailed           EXCEPTION;
  /*Bug 2581117 */
  v_md_start_time      NUMBER;
  v_md_end_time        NUMBER;
  v_md_total           NUMBER :=0;
  v_md_msg_text        VARCHAR2(32000);
BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ManageDemand');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;
    --
    IF  (FUNCMODE = 'RUN') THEN
    -- Executable Statements
       v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
       END IF;
       --
       SAVEPOINT s_child_process;

       SELECT hsecs INTO v_md_start_time FROM v$timer;

       rlm_manage_demand_sv.ManageDemand(v_header_id,
                                          g_Sch_rec,
                                          g_Grp_rec,
                                          v_status);
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' After ManageDemand v_status: ', v_status);
       END IF;
       --
        SELECT hsecs INTO v_md_end_time FROM v$timer;
        v_md_total:=v_md_total+(v_md_end_time-v_md_start_time)/100;

          IF v_status = rlm_core_sv.k_PROC_ERROR THEN
          --
            RAISE e_DPFailed;
            --
          END IF;
          --
       resultout :=  'COMPLETE:SUCCESS';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_SDEBUG);
       END IF;
       --
       v_md_msg_text :='Total Time spent in Managedemand call - '|| v_md_total;
       fnd_file.put_line(fnd_file.log,v_md_msg_text);

       RETURN;
       --
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','ManageDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN e_DPFailed THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Manage Demand failed');
      END IF;
      --
      ROLLBACK TO s_child_process;
      --
      rlm_dp_sv.UpdateGroupPS(g_Sch_rec.header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR);
      COMMIT;
      wf_core.context('RLM_WF_SV','ManageDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF NOT rlm_dp_sv.LockHeader(v_header_id, g_Sch_rec) THEN
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Cannot lock header in MD.e_DPFailed');
       END IF;
       --
       RAISE e_LockH;
      END IF;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      wf_core.context('RLM_WF_SV','ManageDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --RAISE;

END ManageDemand;

PROCEDURE ManageForecast(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  --
  v_header_id          NUMBER;
  v_status             NUMBER;
  e_DPFailed           EXCEPTION;
   /*Bug 2581117 */
  v_mf_start_time  NUMBER;
  v_mf_end_time    NUMBER;
  v_mf_total       NUMBER:=0;
  v_mf_msg_text  VARCHAR2(32000);

BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ManageForecast');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;

    IF  (FUNCMODE = 'RUN') THEN
    -- Executable Statements
       v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
          rlm_core_sv.dlog(C_DEBUG,' ManageForecast');
       END IF;
       --
       SELECT hsecs INTO v_mf_start_time FROM  v$timer;

       rlm_forecast_sv.ManageForecast(v_header_id,
                                      g_Sch_rec,
                                      g_Grp_rec,
                                      v_status);
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' After ManageForecast v_status: ', v_status);
       END IF;
       --
       SELECT hsecs INTO v_mf_end_time FROM v$timer;
       v_mf_total:=v_mf_total+(v_mf_end_time-v_mf_start_time)/100;

       IF v_status = rlm_core_sv.k_PROC_ERROR THEN
            --
            RAISE e_DPFailed;
            --
         END IF;
         --
       resultout :=  'COMPLETE:SUCCESS';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_SDEBUG);
       END IF;
       --
          v_mf_msg_text:='Total Time spent in Manageforecast call - '|| v_mf_total ;
          fnd_file.put_line(fnd_file.log, v_mf_msg_text);
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','ManageForecast',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN e_DPFailed THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Manage Forecast failed');
      END IF;
      --
      ROLLBACK TO s_child_process;
      --
      rlm_dp_sv.UpdateGroupPS(g_Sch_rec.header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR);
      COMMIT;

      wf_core.context('RLM_WF_SV','ManageForecast',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF NOT rlm_dp_sv.LockHeader(v_header_id, g_Sch_rec) THEN
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Cannot lock header in FD.e_DPFailed');
       END IF;
       --
       RAISE e_LockH;
      END IF;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      wf_core.context('RLM_WF_SV','ManageForecast',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --RAISE;

END ManageForecast;

PROCEDURE ReconcileDemand(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  --
  v_header_id          NUMBER;
  v_status             NUMBER;
  e_DPFailed           EXCEPTION;
   /*Bug 2581117*/
  v_rd_start_time      NUMBER;
  v_rd_end_time        NUMBER;
  v_rd_total           NUMBER:=0;
  v_rd_msg_text  VARCHAR2(32000);
BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ReconcileDemand');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;
    --
    IF  (FUNCMODE = 'RUN') THEN
     -- Executable Statements
     v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
     --
     IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
     END IF;
     --
     SELECT hsecs INTO v_rd_start_time from v$timer;
     --
     rlm_rd_sv.RecDemand(v_header_id,
                         g_Sch_rec,
                         g_Grp_rec,
                         v_status);
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,' After ReconcileDemand v_status: ', v_status);
     END IF;
     --
     SELECT hsecs INTO v_rd_end_time FROM v$timer;
     v_rd_total :=v_rd_total+(v_rd_end_time-v_rd_start_time)/100;
     --
     IF v_status = rlm_core_sv.k_PROC_ERROR THEN
      --
      RAISE e_DPFailed;
      --
     END IF;
     --
     rlm_dp_sv.UpdateGroupPS(g_Sch_rec.header_id,
                             g_Sch_rec.schedule_header_id,
                             g_Grp_rec,
                             rlm_core_sv.k_PS_PROCESSED);
     --
     COMMIT;
     --
     IF NOT rlm_dp_sv.LockHeader(v_header_id, g_Sch_rec) THEN
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Unable to lock header after processing grp');
      END IF;
      --
      RAISE e_LockH;
      --
     END IF;
     --
     resultout :=  'COMPLETE:SUCCESS';
     --
     IF (l_debug <> -1) THEN
      rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     v_rd_msg_text:='Total Time spent in RecDemand call - '|| v_rd_total ;
     fnd_file.put_line(fnd_file.log, v_rd_msg_text);
     --
     RETURN;
     --
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','ReconcileDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN e_DPFailed THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Reconcile Demand failed');
      END IF;
      --
      IF g_Sch_rec.schedule_type <> RLM_DP_SV.k_SEQUENCED THEN
       --
       ROLLBACK TO s_child_process;
       --
       rlm_dp_sv.UpdateGroupPS(g_Sch_rec.header_id,
                               g_Sch_rec.schedule_header_id,
                               g_Grp_rec,
                               rlm_core_sv.k_PS_ERROR);
      END IF;
      --
      COMMIT;
      wf_core.context('RLM_WF_SV','ReconcileDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      --
      resultout :=  'COMPLETE:FAILURE';
      --
      IF NOT rlm_dp_sv.LockHeader(v_header_id, g_Sch_rec) THEN
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Cannot lock header in RD.e_DPFailed');
       END IF;
       --
       RAISE e_LockH;
      END IF;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      wf_core.context('RLM_WF_SV','ReconcileDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --RAISE;

END ReconcileDemand;

PROCEDURE PurgeInterface(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  --
  v_header_id          NUMBER;
  v_status             NUMBER;
  e_DPFailed           EXCEPTION;
  --
BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'PurgeInterface');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;
    --
    IF  (FUNCMODE = 'RUN') THEN
    -- Executable Statements
       v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
       END IF;
       --
       rlm_message_sv.dump_messages(v_header_id);
       rlm_dp_sv.PurgeInterfaceLines(v_header_id);
       rlm_message_sv.initialize_messages;
       COMMIT;
       --
       resultout :=  'COMPLETE:SUCCESS';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_SDEBUG);
       END IF;
       --
       RETURN;
       --
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','PurgeInterface',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      wf_core.context('RLM_WF_SV','PurgeInterface',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RAISE;

END PurgeInterface;

PROCEDURE CheckErrors(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  -- Bug #: 3291401
	CURSOR c_process_status_schedule(p_header_id IN NUMBER) is
	SELECT process_status
	FROM rlm_schedule_headers
	WHERE header_id = p_header_id;

	CURSOR c_process_status_interface(p_header_id IN NUMBER) is
	SELECT process_status
	FROM rlm_interface_headers
	WHERE header_id = p_header_id;

	v_process_status  NUMBER;

  --
  v_header_id          NUMBER;
  v_request_id         NUMBER;
  v_schedule_num          VARCHAR2(50);
  x_errors             NUMBER := -1;
  x_real_errors        NUMBER := -1;
  v_status             NUMBER;
  e_DPFailed           EXCEPTION;

BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'CheckErrors');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;
    --
    IF  (FUNCMODE = 'RUN') THEN
       -- Executable Statements
       v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
       END IF;
       --
       v_request_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'REQUEST_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Request Id :', v_request_id);
       END IF;
       --
       v_schedule_num := wf_engine.GetItemAttrText(itemtype,itemkey,'SCHEDULE_NUMBER');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Schedule Number :', v_schedule_num);
       END IF;
       --
       rlm_message_sv.dump_messages(v_header_id);
       rlm_message_sv.initialize_messages;
       --
       --  Check for Errors
       -- After PurgeInterface, the succesfully processed schedule
       -- should have been deleted from interface tables.
       --
       SELECT COUNT(*)
       INTO   x_errors
       FROM   rlm_interface_headers
       WHERE  header_id = v_header_id;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' No of Errors :', x_errors);
       END IF;
       --
       IF (x_errors = 0) then
        --
        -- Bug# 3291401 - Start
	-- Incase there is not data in the interface tables, checking for
	-- the schedule header status.
       	OPEN c_process_status_schedule(v_header_id);
        --
	FETCH c_process_status_schedule INTO v_process_status;
        --
	IF (c_process_status_schedule%NOTFOUND) THEN
         --
	 OPEN c_process_status_interface(v_header_id);
	 FETCH c_process_status_interface INTO v_process_status;
         --
	 IF (c_process_status_interface%NOTFOUND) THEN
	   resultout :=  'COMPLETE:ABT';
	 END IF;
         --
	 IF (v_process_status IS NOT NULL AND
            (v_process_status = rlm_core_sv.k_PS_PARTIAL_PROCESSED OR
             v_process_status = RLM_CORE_SV.k_PS_ERROR) ) THEN
           --
	   -- Setting the x_errors to be more than one
           -- so that correct return value can be set
	   x_errors := 1;
	 END IF ;
         --
	 CLOSE c_process_status_interface;
         --
	ELSIF (v_process_status IS NOT NULL AND
              (v_process_status = rlm_core_sv.k_PS_PARTIAL_PROCESSED OR
               v_process_status = RLM_CORE_SV.k_PS_ERROR) ) THEN
	 -- Setting the x_errors to be more than one
         -- so that correct return value can be set
	 x_errors := 1;
	END IF;
	--
	CLOSE c_process_status_schedule;
	--
	-- Bug# 3291401 - End
        --
        wf_engine.SetItemAttrNumber( itemtype,
                                      itemkey,
                                      'ERRORS_EXIST',
                                       g_PROC_SUCCESS);        ---No Errors
        --
       ELSE
         --
         wf_engine.SetItemAttrNumber( itemtype,
                                      itemkey,
                                      'ERRORS_EXIST',
                                      g_PROC_ERROR);        ---Errors Exist
         --
       END IF;
       --
       IF (x_errors > 0 ) THEN
         resultout :=  'COMPLETE:ERRORS';
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,' resultout :', resultout);
            rlm_core_sv.dpop(C_SDEBUG);
         END IF;
         --
         RETURN;
       ELSE
         resultout :=  'COMPLETE:N';
	 --
  	 IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,' resultout :', resultout);
            rlm_core_sv.dpop(C_SDEBUG);
         END IF;
	 --
         RETURN;
      END IF;
      --
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','CheckErrors',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:ABT';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      wf_core.context('RLM_WF_SV','CheckErrors',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:ABT';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RAISE;

END CheckErrors;

PROCEDURE RunReport(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  --
  v_header_id          NUMBER;
  v_status             NUMBER;
  v_org_id             NUMBER;
  v_request_id         NUMBER := -1;
  v_sched_num          VARCHAR2(50);
  x_request_id         NUMBER := -1;
  x_errors             NUMBER := -1;
  x_no_copies          NUMBER :=0;
  x_print_style        VARCHAR2(30);
  x_printer            VARCHAR2(30);
  x_save_output_flag   VARCHAR2(1);
  x_result             BOOLEAN;
  e_DPFailed           EXCEPTION;
  --
BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'RunReport');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;
    --
    IF  (FUNCMODE = 'RUN') THEN
    -- Executable Statements
       v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
       END IF;
       --
       v_org_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORG_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Org Id :', v_org_id);
       END IF;
       --
       v_request_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'REQUEST_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Request Id :', v_request_id);
       END IF;
       --
       v_sched_num := wf_engine.GetItemAttrText(itemtype,itemkey,'SCHEDULE_NUMBER');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Schedule Number :', v_sched_num);
       END IF;

/*
       -- Needs to be used once DSP concurrent program sets print options parameters
       x_result :=fnd_concurrent.get_request_print_options(fnd_global.conc_request_id,
						x_no_copies   ,
						x_print_style ,
						x_printer  ,
						x_save_output_flag );
        IF (x_result =TRUE) then
	    x_result :=fnd_request.set_print_options(x_printer,
				      x_print_style,
				      x_no_copies,
				      NULL,
				      'N');
        END IF;
*/
        --
        fnd_request.set_org_id(v_org_id);
        --
        x_request_id := fnd_request.submit_request ('RLM',
					  'RLMDPDER',
					  NULL,
					  NULL,
					  FALSE,
					  v_org_id,
					  v_request_id,
					  v_request_id,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL, --v_sched_num
					  NULL, --v_sched_num
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL,
					  NULL);
 --     END IF;
 --     commit;

       resultout :=  'COMPLETE:SUCCESS';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_SDEBUG);
       END IF;
       --
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','RunReport',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      wf_core.context('RLM_WF_SV','RunReport',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RAISE;

END RunReport;

PROCEDURE GetScheduleDetails( x_Header_Id     IN  NUMBER,
                              x_Schedule_Num  OUT NOCOPY VARCHAR2,
                              x_Customer_Name OUT NOCOPY VARCHAR2,
                              x_Schedule_Gen_Date OUT NOCOPY DATE)
-- Bug#: 3053299 - Added Schedule Generation Date as argument
IS
BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'GetScheduleDetails');
       rlm_core_sv.dlog(C_DEBUG,'x_Header_Id ', x_Header_Id);
    END IF;
    --
    select schedule_reference_num, cust_name_ext, sched_generation_date
    into x_Schedule_Num, x_Customer_Name , x_Schedule_Gen_Date
    from rlm_interface_headers
    where header_id = x_Header_Id ;
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,' Schedule Generation Date :',
                TO_CHAR(x_Schedule_Gen_Date));
      rlm_core_sv.dlog(C_DEBUG,' Successful select');
      rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG, 'No Data Found');
      END IF;
      --
   WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG, 'Other Errors');
      END IF;

END GetScheduleDetails;


PROCEDURE StartDSPLoop(   errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY VARCHAR2,
                           p_Header_Id IN NUMBER,
                           p_Line_id IN NUMBER,
                           v_Sch_rec   IN rlm_interface_headers%ROWTYPE,
                           v_Grp_rec   IN rlm_dp_sv.t_Group_rec)
IS
  --
  v_ItemKey          VARCHAR2(100) := to_char(p_Header_Id)||
  '+' || to_char(p_Line_id);
  v_ItemType         VARCHAR2(30) := g_ItemType;
  v_ProcessName      VARCHAR2(30) := g_ProcessNameLoop;
  v_ScheduleNum      VARCHAR2(35) ;
  v_Customer         VARCHAR2(30) ;
  v_ScheduleGenDate  DATE ;
  v_org_id           NUMBER;
  v_retcode          NUMBER;
  v_count            NUMBER;
  v_dummy            NUMBER DEFAULT 0;
  e_DSPFailed        EXCEPTION;
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'StartDSPLoop');
     rlm_core_sv.dlog(C_DEBUG,'p_Header_Id ', p_Header_Id);
     rlm_core_sv.dlog(C_DEBUG,'Starting process:',v_ItemKey);
     rlm_core_sv.dlog(C_DEBUG,'Org ID', v_org_id);
  END IF;
  --
  -- fnd_profile.get('ORG_ID', v_org_id);
  --
  v_org_id := v_Sch_rec.org_id;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Org Id ', v_org_id);
  END IF;
  --
  -- Bug#: 3053299 - Added Schedule Generation Date as argument
  GetScheduleDetails(p_Header_Id, v_ScheduleNum, v_Customer, v_ScheduleGenDate);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'v_ScheduleNum ', v_ScheduleNum);
     rlm_core_sv.dlog(C_DEBUG,'v_Customer ', v_Customer);
  END IF;
  --
  -- Set various Header Attributes

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'USER_ID',
                               FND_GLOBAL.USER_ID);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'APPLICATION_ID',
                               FND_GLOBAL.RESP_APPL_ID);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'REQUEST_ID',
                               FND_GLOBAL.CONC_REQUEST_ID);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'RESPONSIBILITY_ID',
                               FND_GLOBAL.RESP_ID);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'ORG_ID',
                               v_org_id);

  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'HEADER_ID',
                               p_Header_Id);

  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKey,
                               'SCHEDULE_NUMBER',
                               v_ScheduleNum);

  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKey,
                               'CUSTOMER_NAME',
                               v_Customer);
  wf_engine.SetItemAttrNumber( v_ItemType,
                               v_ItemKey,
                               'ERRORS_EXIST',
                               v_dummy);

  -- Bug#: 3053299 - Setting the tokens for From User,
  --		     To User and Schedule Generation Date


  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKey,
                               'FROM_USER',
                               Notification_FromUser(FND_GLOBAL.RESP_ID,
                                               FND_GLOBAL.RESP_APPL_ID));


  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKey,
                               'TO_USER',
                               Notification_ToUser(FND_GLOBAL.USER_ID));

  wf_engine.SetItemAttrText( v_ItemType,
                               v_ItemKey,
                               'SCHED_GEN_DATE',
                               v_ScheduleGenDate);

  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Before Start Process DSP Loop');
  END IF;
  --
  wf_engine.StartProcess(v_ItemType, v_ItemKey);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'After Start Process DSP Loop ');
  END IF;
  --
  v_retcode := wf_engine.GetItemAttrNumber(v_ItemType,v_ItemKey,'ERRORS_EXIST');
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,' Errors Status: ', v_retcode);
  END IF;
  --
  retcode := g_PROC_SUCCESS;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
   --
   WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Errors found ');
         rlm_core_sv.dlog(C_DEBUG,'Error: ',SUBSTR(SQLERRM,1,1500));
      END IF;
      --
      retcode := g_PROC_ERROR;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
    --  rlm_core_sv.stop_debug;
      --
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END StartDSPLoop;




PROCEDURE CreateDSPLoop( errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY VARCHAR2,
                           p_Header_Id IN NUMBER,
                           p_Line_id IN NUMBER)
IS
  --
  v_ItemKey          VARCHAR2(100) := to_char(p_Header_Id)||
  '+' || to_char(p_Line_id);
  v_ItemType         VARCHAR2(30) := g_ItemType;
  v_ProcessName      VARCHAR2(30) := g_ProcessNameLoop;
  v_org_id           NUMBER;
  v_retcode          NUMBER;
  v_count            NUMBER;
  v_dummy            NUMBER DEFAULT 0;
  e_DSPFailed        EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'CreateDSPLoop');
     rlm_core_sv.dlog(C_DEBUG,'p_Header_Id ', p_Header_Id);
     rlm_core_sv.dlog(C_DEBUG,'Creating Loop:',v_ItemKey);
     rlm_core_Sv.dlog(C_DEBUG, 'v_ItemType', v_ItemType);
  END IF;
  --
  -- fnd_profile.get('ORG_ID', v_org_id);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'Org Id ', MO_GLOBAL.get_current_org_id);
  END IF;
  --
  -- Abort the process if it has hung
  BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Aborting old processes');
    END IF;
    --
    wf_engine.AbortProcess(itemtype => v_ItemType,
                           itemkey => v_ItemKey);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'after abort bad process');
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Did not abort any process');
      END IF;
      --
  END;
  --
  -- Check whether Item has already been run in Workflow and purge it
  -- Bug 2756981: Set force to TRUE to allow child processes to be purged
  --
  wf_purge.Items(itemtype => v_ItemType,
                 itemkey  => v_ItemKey,
                 enddate  => sysdate,
                 docommit => FALSE,
		 force    => TRUE);
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'After Purge for Item key ',v_ItemKey);
  END IF;
  --
  wf_engine.CreateProcess(v_ItemType, v_ItemKey, v_ProcessName);
  wf_engine.SetItemParent(v_ItemType,v_ItemKey,v_ItemType,to_char(p_Header_Id),
  to_char(p_Header_Id));
  --
  wf_engine.SetItemUserKey(v_ItemType, v_ItemKey,
        g_Sch_rec.schedule_reference_num);

  --
  retcode := g_PROC_SUCCESS;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'After Create Process DSP Loop ');
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Errors found ');
         rlm_core_sv.dlog(C_DEBUG,'Error: ',SUBSTR(SQLERRM,1,1500));
      END IF;
      --
      retcode := g_PROC_ERROR;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
    --  rlm_core_sv.stop_debug;
      --
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END CreateDSPLoop;


PROCEDURE UpdateHeaderPS(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  --
  v_header_id		NUMBER;
  --
BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'UpdateHeaderPS');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;
    --
    IF  (FUNCMODE = 'RUN') THEN
    -- Executable Statements
       --
       v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'WF Header_id :',v_header_id);
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', g_Sch_rec.header_id);
          rlm_core_sv.dlog(C_DEBUG,'schedule_header_id',
           g_Sch_rec.schedule_header_id);

      END IF;
       --
       IF g_Sch_rec.header_id IS NULL THEN
       --
          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'Assigning the global variable.');
          END IF;
          --
          SELECT * INTO g_Sch_rec
          FROM rlm_interface_headers
          WHERE header_id = v_header_id;
       --
       END IF;
       rlm_dp_sv.UpdateHeaderPS(g_Sch_rec.header_id,
                          g_Sch_rec.schedule_header_id);

       --
       resultout :=  'COMPLETE:SUCCESS';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_SDEBUG);
       END IF;
       --
       RETURN;
       --
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','UpdateHeaderPS',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'When Others');
      END IF;
      --
      wf_core.context('RLM_WF_SV','UpdateHeaderPS',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --RAISE;
END UpdateHeaderPS;


PROCEDURE ProcessGroupDemand(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  --
  v_header_id          NUMBER;
  v_status             NUMBER;
  e_MDFailed           EXCEPTION;
  e_MFFailed           EXCEPTION;
  e_RDFailed           EXCEPTION;
   /*Bug 2581117 */
  v_md_start_time      NUMBER;
  v_md_end_time        NUMBER;
  v_md_total           NUMBER :=0;
  v_rd_start_time      NUMBER;
  v_rd_end_time        NUMBER;
  v_rd_total           NUMBER:=0;
  v_mf_start_time      NUMBER;
  v_mf_end_time        NUMBER;
  v_mf_total           NUMBER:=0;
  v_msg_text           VARCHAR2(32000);

  --
BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ProcessGroupDemand');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;
    --
    IF  (FUNCMODE = 'RUN') THEN
    -- Executable Statements
       v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
       END IF;
       --
       SAVEPOINT s_child_process;
       SELECT hsecs INTO v_md_start_time FROM v$timer;
       rlm_manage_demand_sv.ManageDemand(v_header_id,
                                          g_Sch_rec,
                                          g_Grp_rec,
                                          v_status);
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' After ManageDemand v_status: ', v_status);
       END IF;
       --
        SELECT hsecs INTO v_md_end_time FROM v$timer;
        v_md_total:=v_md_total+(v_md_end_time-v_md_start_time)/100;

      IF v_status = rlm_core_sv.k_PROC_ERROR THEN
          --
          RAISE e_MDFailed;
          --
       END IF;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'Before Manage Forecast');
       END IF;
       --
       SELECT hsecs INTO v_mf_start_time FROM v$timer;

       rlm_forecast_sv.ManageForecast(v_header_id,
                                      g_Sch_rec,
                                      g_Grp_rec,
                                      v_status);
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' After ManageForecast v_status: ', v_status);
       END IF;
       --
        SELECT hsecs INTO v_mf_end_time FROM v$timer;
        v_mf_total:=v_mf_total+(v_mf_end_time-v_mf_start_time)/100;

      IF v_status = rlm_core_sv.k_PROC_ERROR THEN
          --
          RAISE e_MFFailed;
          --
       END IF;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'Before Reconcile Demand');
       END IF;
       --
       SELECT hsecs INTO v_rd_start_time FROM v$timer;

       rlm_rd_sv.RecDemand(v_header_id,
                           g_Sch_rec,
                           g_Grp_rec,
                           v_status);

       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'After ReconcileDemand v_status', v_status);
       END IF;
       --
       SELECT hsecs INTO v_rd_end_time FROM v$timer;
       v_rd_total :=v_rd_total+(v_rd_end_time-v_rd_start_time)/100;
       --
       IF v_status = rlm_core_sv.k_PROC_ERROR THEN
          --
          RAISE e_RDFailed;
          --
       END IF;
       --
       rlm_dp_sv.UpdateGroupPS(g_Sch_rec.header_id,
                            g_Sch_rec.schedule_header_id,
                            g_Grp_rec,
                            rlm_core_sv.k_PS_PROCESSED);

       COMMIT;
       --
       resultout :=  'COMPLETE:SUCCESS';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_SDEBUG);
       END IF;
       --
       l_msg_text:='Total Time spent in Validatedemand call - '||
                  (l_val_end_time-l_val_start_time)/100;
       fnd_file.put_line(fnd_file.log,l_msg_text);

       l_msg_text:='Time spent in CompareSched call - '||
                  (l_comp_end_time-l_comp_start_time)/100 ;
       fnd_file.put_line(fnd_file.log,l_msg_text);

       v_msg_text:='Total Time spent in Managedemand call - '|| v_md_total;
       fnd_file.put_line(fnd_file.log, v_msg_text);

       v_msg_text:='Total Time spent in Manageforecast call - '|| v_mf_total ;
       fnd_file.put_line(fnd_file.log,v_msg_text);

       v_msg_text:='Total Time spent in RecDemand call - '|| v_rd_total ;
       fnd_file.put_line(fnd_file.log,v_msg_text);

      RETURN;
    --
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','ProcessGroupDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN e_MDFailed THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Manage Demand failed');
      END IF;
      --
      ROLLBACK TO s_child_process;
      --
      rlm_dp_sv.UpdateGroupPS(g_Sch_rec.header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR);

      -- Bug#: 2771756 - Start
      -- Bug: 4198330 added grouping info
      rlm_message_sv.removeMessages(
               p_header_id       => v_header_id,
               p_message         => 'RLM_RSO_CREATION_INFO',
               p_message_type    => 'I',
               p_ship_from_org_id => g_Grp_rec.ship_from_org_id,
               p_ship_to_address_id => g_Grp_rec.ship_to_address_id,
               p_customer_item_id => g_Grp_rec.customer_item_id,
               p_inventory_item_id => g_Grp_rec.inventory_item_id);
      -- Bug#: 2771756 - End

      wf_core.context('RLM_WF_SV','ProcessGroupDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      --
      resultout := 'COMPLETE:FAILURE';
      COMMIT;
      --
      IF NOT rlm_dp_sv.LockHeader(v_header_id, g_Sch_rec) THEN
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Unable to lock header in e_MDFailed');
       END IF;
       --
       RAISE e_LockH;
       --
      END IF;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN e_MFFailed THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Manage Forecast failed');
      END IF;
      --
      ROLLBACK TO s_child_process;
      --
      rlm_dp_sv.UpdateGroupPS(g_Sch_rec.header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR);

      -- Bug#: 2771756 - Start
      -- Bug: 4198330 added grouping info
      rlm_message_sv.removeMessages(
               p_header_id       => v_header_id,
               p_message         => 'RLM_RSO_CREATION_INFO',
               p_message_type    => 'I',
               p_ship_from_org_id => g_Grp_rec.ship_from_org_id,
               p_ship_to_address_id => g_Grp_rec.ship_to_address_id,
               p_customer_item_id => g_Grp_rec.customer_item_id,
               p_inventory_item_id => g_Grp_rec.inventory_item_id);
      -- Bug#: 2771756 - End

      wf_core.context('RLM_WF_SV','ProcessGroupDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      COMMIT;
      --
      IF NOT rlm_dp_sv.LockHeader(v_header_id, g_Sch_rec) THEN
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Unable to lock header in e_FDFailed');
       END IF;
       --
       RAISE e_LockH;
       --
      END IF;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN e_RDFailed THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Reconcile Demand failed');
      END IF;
      --
      ROLLBACK TO s_child_process;
      --
      rlm_dp_sv.UpdateGroupPS(g_Sch_rec.header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR);
      -- Bug#: 2771756 - Start
      -- Bug: 4198330 added grouping info
      rlm_message_sv.removeMessages(
               p_header_id       => v_header_id,
               p_message         => 'RLM_RSO_CREATION_INFO',
               p_message_type    => 'I',
               p_ship_from_org_id => g_Grp_rec.ship_from_org_id,
               p_ship_to_address_id => g_Grp_rec.ship_to_address_id,
               p_customer_item_id => g_Grp_rec.customer_item_id,
               p_inventory_item_id => g_Grp_rec.inventory_item_id);
      -- Bug#: 2771756 - End

      wf_core.context('RLM_WF_SV','ProcessGroupDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      --
      resultout :=  'COMPLETE:FAILURE';
      COMMIT;
      --
      IF NOT rlm_dp_sv.LockHeader(v_header_id, g_Sch_rec) THEN
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Unable to lock header in e_RDFailed');
       END IF;
       --
       RAISE e_LockH;
       --
      END IF;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN e_LockH THEN
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'e_LockH exception in ProcessGroupdemand');
       rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      rlm_dp_sv.UpdateGroupPS(g_Sch_rec.header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR,
                         'ALL');
      --
      rlm_message_sv.app_error(
              x_ExceptionLevel => rlm_message_sv.k_error_level,
              x_MessageName => 'RLM_HEADER_LOCK_NOT_OBTAINED',
              x_InterfaceHeaderId => v_header_id,
              x_InterfaceLineId => NULL,
              x_OrderLineId => NULL,
              x_Token1 => 'SCHED_REF',
              x_Value1 => rlm_core_sv.get_schedule_reference_num(v_header_id));
      --
      COMMIT;
      resultout := 'COMPLETE:FAILURE';
      --
   WHEN OTHERS THEN

     -- Bug 2771756 : Added the rollback statement.
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'ProcessGroupDemand when others',
        SUBSTR(SQLERRM,1,1500));
     END IF;
     --
     ROLLBACK TO s_child_process;
     --
     rlm_dp_sv.UpdateGroupPS(g_Sch_rec.header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR);

      -- Bug#: 2771756 - Start
      -- Bug: 4198330 added grouping info
      rlm_message_sv.removeMessages(
               p_header_id       => v_header_id,
               p_message         => 'RLM_RSO_CREATION_INFO',
               p_message_type    => 'I',
               p_ship_from_org_id => g_Grp_rec.ship_from_org_id,
               p_ship_to_address_id => g_Grp_rec.ship_to_address_id,
               p_customer_item_id => g_Grp_rec.customer_item_id,
               p_inventory_item_id => g_Grp_rec.inventory_item_id);
      -- Bug#: 2771756 - End

      wf_core.context('RLM_WF_SV','ProcessGroupDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      COMMIT;
      --
      IF NOT rlm_dp_sv.LockHeader(v_header_id, g_Sch_rec) THEN
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Unable to lock header in when others');
        rlm_core_sv.dpop(C_SDEBUG);
       END IF;
       --
       RAISE e_LockH;
       --
      END IF;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      --RAISE;

END ProcessGroupDemand;


PROCEDURE ArchiveDemand(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  --
  v_status             NUMBER;
  v_schedulePS         NUMBER;
  retcode              NUMBER;
  errbuf               VARCHAR2(2000);
  v_Progress           VARCHAR2(3) := '020';
  v_header_id          NUMBER;
  e_DPFailed           EXCEPTION;
  e_ConfirmationSchedule EXCEPTION;
  --

BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'ArchiveDemand');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;
    --
    IF  (FUNCMODE = 'RUN') THEN
    -- Executable Statements
      --
      v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
         rlm_core_sv.dlog(C_DEBUG,'Before Archive_Demand');
      END IF;
      --
      RLM_TPA_SV.PostValidation;
      --
      IF RLM_VALIDATEDEMAND_SV.g_header_rec.process_status  =
        rlm_core_sv.k_PS_ERROR THEN
      --
         resultout := 'COMPLETE:ABT';
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'resultout',resultout);
         END IF;
         --
      ELSE
      --
         resultout := 'COMPLETE:CONT';
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'resultout',resultout);
         END IF;
         --
      END IF;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','ArchiveDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:ABT';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'ArchiveDemand when others',
        SUBSTR(SQLERRM,1,1500));
      END IF;
      --
      rlm_dp_sv.UpdateGroupPS(v_header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR,
                        'ALL');
      --
      rlm_dp_sv.UpdateHeaderPS(v_header_id,
                     g_Sch_rec.schedule_header_id);
      --
      rlm_message_sv.sql_error('rlm_wf_sv.ArchiveDemand', v_Progress);
      --
      rlm_message_sv.dump_messages(v_header_id);
      rlm_message_sv.initialize_messages;
      --
      COMMIT;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      wf_core.context('RLM_WF_SV','ArchiveDemand',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:ABT';
      --

      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END ArchiveDemand;

/* Bug 2554058: Added the following procedure */

PROCEDURE Testschedule(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
 v_header_id            NUMBER;
 e_wftestschedule       EXCEPTION;

BEGIN
 --
  v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');

  IF RLM_DP_SV.edi_test_indicator = 'T' then
    --
        rlm_core_sv.dlog(C_DEBUG,'Test schedule found');
        raise e_wftestschedule;
    --
  ELSE
    --
         resultout :=  'F';
    --
  END IF;
    --
EXCEPTION
  WHEN e_wftestschedule THEN
    --
    rlm_message_sv.app_error(
              x_ExceptionLevel => rlm_message_sv.k_warn_level,
              x_MessageName => 'RLM_TEST_SCHEDULE_DETECTED',
              x_InterfaceHeaderId => v_header_id,
              x_InterfaceLineId => NULL,
              x_OrderLineId => NULL,
              x_Token1 => 'SCHED_REF',
              x_Value1 =>rlm_core_sv.get_schedule_reference_num(v_header_id));

    resultout :=  'T';
    COMMIT;
    --
END Testschedule;


PROCEDURE CallProcessGroup(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  --
  v_header_id          NUMBER;
  v_tmp_status         NUMBER;
  v_count              NUMBER;
  retcode              NUMBER;
  errbuf               VARCHAR2(2000);
  v_num_child          NUMBER;
  v_child_req_id       rlm_dp_sv.g_request_tbl;

-- 4299804: Added min_start_date_time and ship_to_customer_id to the
-- select stmt.

  CURSOR c_group_cur (v_hdr_id IN  VARCHAR2) IS
    SELECT   rih.customer_id,
             ril.ship_from_org_id,
             ril.ship_to_address_id,
             ril.ship_to_site_use_id,
             ril.ship_to_org_id,
             ril.customer_item_id,
             ril.inventory_item_id,
             ril.intrmd_ship_to_id,       --Bugfix 5911991
   	     ril.intmed_ship_to_org_id,   --Bugfix 5911991
             ril.industry_attribute15,
             ril.order_header_id,
             ril.blanket_number,
             min(ril.start_date_time),
             ril.ship_to_customer_id
    FROM     rlm_interface_headers rih,
             rlm_interface_lines_all ril
    WHERE    ril.header_id = v_hdr_id
    AND      ril.org_id = rih.org_id
    AND      ril.header_id = rih.header_id
    AND      ril.process_status in ( rlm_core_sv.k_PS_AVAILABLE,
                                     rlm_core_sv.k_PS_PARTIAL_PROCESSED)
    GROUP BY rih.customer_id,
             ril.ship_from_org_id,
             ril.ship_to_address_id,
             ril.ship_to_site_use_id,
             ril.ship_to_org_id,
             ril.customer_item_id,
             ril.inventory_item_id,
             ril.industry_attribute15,
             ril.intrmd_ship_to_id,       --Bugfix 5911991
  	     ril.intmed_ship_to_org_id,   --Bugfix 5911991
             ril.order_header_id,
             ril.blanket_number,
             ril.ship_to_customer_id
    ORDER BY min(ril.start_date_time),
             ril.ship_to_address_id,
             ril.customer_item_id;
  --

BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'CallProcessGroup');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;
    --
    IF  (FUNCMODE = 'RUN') THEN
    -- Executable Statements
       v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
       END IF;
       --
       SELECT process_status
       INTO v_tmp_status
       FROM rlm_interface_headers
       WHERE header_id = v_Header_Id;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'process status =', v_tmp_status);
       END IF;
       --

         --
         IF v_tmp_status <> rlm_core_sv.k_PROC_ERROR THEN
           --
           v_num_child := g_num_child;
           --
           IF v_num_child > 1 THEN /* Parallel DSP */
             --
             /* submit concurrent program requests*/

             rlm_dp_sv.CreateChildGroups (v_header_id,
                                v_num_child);
             --
             IF NOT RLM_DP_SV.LockHeader(v_header_id, g_Sch_rec) THEN
              --
              IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG, 'Cannot lock header after CreateChildGroups');
              END IF;
              --
              RAISE e_LockH;
              --
             END IF;
             --
             IF (v_num_child > 1) THEN /*Parallelize if more than 1 group found */

               --
               rlm_dp_sv.SubmitChildRequests(v_header_id,
                                 v_num_child,
                                 v_child_req_id);
               --
               rlm_dp_sv.ProcessChildRequests(v_header_id,
                                  v_child_req_id);



               v_child_req_id.delete;
               --
             ELSE
               --
               rlm_dp_sv.ProcessGroups (g_Sch_rec,
                              v_header_id,
                              1, rlm_dp_sv.k_PARALLEL_DSP);
               --
             END IF;
             --
           ELSE  /*sequencial processing*/
             --
             v_count := 1;
             --
             OPEN c_group_cur(v_header_id);
             --
             LOOP
               --
               BEGIN
                --
                -- 4299804: Added min_start_date_time and
                -- ship_to_customer_id to the fetch stmt.

                FETCH c_group_cur INTO
                   g_Grp_rec.customer_id,
                   g_Grp_rec.ship_from_org_id,
                   g_Grp_rec.ship_to_address_id,
                   g_Grp_rec.ship_to_site_use_id,
                   g_Grp_rec.ship_to_org_id,
                   g_Grp_rec.customer_item_id,
                   g_Grp_rec.inventory_item_id,
                   g_Grp_rec.industry_attribute15,
                   g_Grp_rec.intrmd_ship_to_id,       --Bugfix 5911991
                   g_Grp_rec.intmed_ship_to_org_id,   --Bugfix 5911991
                   g_Grp_rec.order_header_id,
                   g_Grp_rec.blanket_number,
                   g_Grp_rec.min_start_date_time,
                   g_Grp_rec.ship_to_customer_id;

                --
                EXIT WHEN c_group_cur%NOTFOUND;
                --
                -- Setting the global vars
                IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG,'Create loop',v_count);
                END IF;
		--
                IF v_count > 1 THEN
                 --
                 IF NOT rlm_dp_sv.LockHeader(v_header_id, g_Sch_rec) THEN
                  --
                  IF (l_debug <> -1) THEN
                   rlm_core_sv.dlog(C_DEBUG, 'Cannot lock header');
                  END IF;
                  --
                  resultout := 'COMPLETE:FAILURE';
                  RAISE e_LockH;
                  --
                 END IF;
                END IF;
                --
                rlm_wf_sv.CreateDSPLoop(errbuf,
                                       retcode,
                                       v_header_id,
                                       v_count);
                --
  		IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'start loop',v_count);
		  rlm_core_sv.dlog(C_DEBUG, '***** Processing new group *****');
		  rlm_core_sv.dlog(C_DEBUG, 'Blanket Number', g_Grp_rec.blanket_number);
                END IF;
		--
                rlm_wf_sv.StartDSPLoop(errbuf,
                                       retcode,
                                       v_header_id,
                                       v_count,
                                       g_Sch_rec,
                                       g_Grp_rec);
                --
                v_count:= v_count+1;
               --
              END;
             --
             END LOOP;
             --
             CLOSE c_group_cur;
             --
           END IF;
           --
           resultout :=  'COMPLETE:SUCCESS';
           --
         ELSE
            --
            resultout :=  'COMPLETE:FAILURE';
            --
         END IF;
         --
  	 IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_SDEBUG);
         END IF;
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','CallProcessGroup',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN e_LockH THEN
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'e_LockH exception in CallProcessGroup');
       rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      rlm_dp_sv.UpdateGroupPS(g_Sch_rec.header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR,
                         'ALL');
      --
      rlm_message_sv.app_error(
              x_ExceptionLevel => rlm_message_sv.k_error_level,
              x_MessageName => 'RLM_HEADER_LOCK_NOT_OBTAINED',
              x_InterfaceHeaderId => v_header_id,
              x_InterfaceLineId => NULL,
              x_OrderLineId => NULL,
              x_Token1 => 'SCHED_REF',
              x_Value1 => rlm_core_sv.get_schedule_reference_num(v_header_id));
      --
      COMMIT;
      resultout := 'COMPLETE:FAILURE';
      --
   WHEN OTHERS THEN
      wf_core.context('RLM_WF_SV','CallProcessGroup',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CallProcessGroup;



PROCEDURE PostValidate(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  --
  v_header_id          NUMBER;
  retcode              NUMBER;
  errbuf               VARCHAR2(2000);
  v_Progress           VARCHAR2(3) := '030';
  e_ConfirmationSchedule EXCEPTION;
  v_replace_status     BOOLEAN DEFAULT FALSE;
  e_ReplaceSchedule    EXCEPTION;
  --

BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'PostValidate');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;
    --
    IF  (FUNCMODE = 'RUN') THEN
    -- Executable Statements
       v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
       END IF;
       --
      -- Lock the headers and Populate g_Sch_rec
      IF NOT rlm_dp_sv.LockHeader(v_header_Id, g_Sch_rec) THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'header not locked');
         END IF;
         --
         raise e_LockH;
         --
      END IF;
      --
      IF g_Sch_rec.schedule_purpose = rlm_dp_sv.k_CONFIRMATION THEN
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'RLM_CONF_SCH_RCD');
         END IF;
	 --
         raise e_ConfirmationSchedule;
         --
      END IF;
      --
      --
      -- Call Sweeper Program here
      -- (Enhancement bug# 1062039)
      --

      SELECT hsecs INTO l_comp_start_time FROM v$timer;

      RLM_REPLACE_SV.CompareReplaceSched(g_Sch_rec,
                                         RLM_DP_SV.g_warn_replace_schedule,
                                         v_replace_status);

       --
      SELECT hsecs INTO l_comp_end_time FROM v$timer;


      IF v_replace_status = FALSE THEN
        --
        RAISE e_ReplaceSchedule;
        --
      END IF;
      --
      resultout :=  'COMPLETE:SUCCESS';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','PostValidate',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN e_LockH THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'PostValidate failed Lock header');
      END IF;
      --
      rlm_dp_sv.UpdateGroupPS(v_header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR,
                        'ALL');
      --
      rlm_dp_sv.UpdateHeaderPS(v_header_id,
                     g_Sch_rec.schedule_header_id);
      --
      rlm_message_sv.dump_messages(v_header_id);
      rlm_message_sv.initialize_messages;
      --

      wf_core.context('RLM_WF_SV','PostValidate',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN e_ConfirmationSchedule THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'RLM_CONF_SCH_RCD');
      END IF;
      --
      rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_warn_level,
           x_MessageName => 'RLM_CONF_SCH_RCD',
           x_InterfaceHeaderId => g_Sch_rec.header_id,
           x_InterfaceLineId => null,
           x_ScheduleHeaderId => g_Sch_rec.schedule_header_id,
           x_ScheduleLineId => NULL,
           x_OrderHeaderId => g_Grp_rec.setup_terms_rec.header_id,
           x_OrderLineId => NULL,
           x_Token1 => 'SCHED_REF',
           x_Value1 => g_Sch_rec.schedule_reference_num);
      --
      rlm_dp_sv.UpdateGroupPS(g_Sch_rec.header_id,
                    g_Sch_rec.Schedule_header_id,
                    g_Grp_rec,
                    rlm_core_sv.K_PS_PROCESSED,
                    'ALL');
      --
      rlm_dp_sv.UpdateHeaderPS(g_Sch_rec.header_id,
                     g_Sch_rec.Schedule_header_id);
      --
      rlm_message_sv.dump_messages(v_header_id);
      rlm_message_sv.initialize_messages;
      --
      COMMIT;
      -- Bug#: 3053299 -- Setting the output
      resultout :=  'COMPLETE:SUCCESS';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;

   WHEN e_ReplaceSchedule THEN
      --
      wf_core.context('RLM_WF_SV','PostValidate',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      rlm_dp_sv.UpdateGroupPS(v_header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR,
                        'ALL');
      --
      rlm_dp_sv.UpdateHeaderPS(v_header_id,
                     g_Sch_rec.schedule_header_id);
      --
      -- Bug 2930695: Frontport bug 2912996
      -- rlm_message_sv.sql_error('rlm_dp_sv.DemandProcessor', v_Progress);
      --
      rlm_message_sv.dump_messages(v_header_id);
      rlm_message_sv.initialize_messages;
      --
      COMMIT;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;

   WHEN OTHERS THEN
      wf_core.context('RLM_WF_SV','PostValidate',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:FAILURE';
      --
      rlm_dp_sv.UpdateGroupPS(v_header_id,
                        g_Sch_rec.schedule_header_id,
                        g_Grp_rec,
                        rlm_core_sv.k_PS_ERROR,
                        'ALL');
      --
      rlm_dp_sv.UpdateHeaderPS(v_header_id,
                     g_Sch_rec.schedule_header_id);
      --
      rlm_message_sv.sql_error('rlm_dp_sv.DemandProcessor', v_Progress);
      --
      rlm_message_sv.dump_messages(v_header_id);
      rlm_message_sv.initialize_messages;
      --
      COMMIT;
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --RAISE ;

END PostValidate;


PROCEDURE CHeckStatus(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS
  --
  v_header_id          NUMBER;
  v_request_id         NUMBER;
  v_schedule_num          VARCHAR2(50);
  x_errors             NUMBER := -1;
  x_real_errors        NUMBER := -1;
  v_status             NUMBER;
  e_DPFailed           EXCEPTION;
BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'CHeckStatus');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;
    --
    IF  (FUNCMODE = 'RUN') THEN
    -- Executable Statements
       v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
       END IF;
       --
       v_request_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'REQUEST_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Request Id :', v_request_id);
       END IF;
       --
       v_schedule_num := wf_engine.GetItemAttrText(itemtype,itemkey,'SCHEDULE_NUMBER');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Schedule Number :', v_schedule_num);
       END IF;
       --
       rlm_message_sv.dump_messages(v_header_id);
       rlm_message_sv.initialize_messages;

       --  Check for Errors

       wf_engine.SetItemAttrNumber( itemtype,
                                    itemkey,
                                    'ERRORS_EXIST',
                                    g_PROC_ERROR);        ---Errors Exist

       resultout :=  'COMPLETE:ERR';
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_SDEBUG);
       END IF;
       --
       RETURN;

    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE';
       RETURN;
    END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'NO data found ');
      END IF;
      --
      wf_core.context('RLM_WF_SV','CHeckStatus',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:N';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
   WHEN OTHERS THEN
      wf_core.context('RLM_WF_SV','CHeckStatus',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:N';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RAISE;

END CHeckStatus;

  -- Bug#: 3053299 - Start of the functions

/*=============================================================================

  FUNCTION NAME:  Notification_ToUser

  DESCRIPTION:  This function returns the To User to whom the notifications
  		are to be send. The To User is set as an attribute in the Work
  		Flow. The To User is retrieved from the FND_USER table.

  PARAMETERS:     user_id          IN NUMBER

  RETURN:	  VARCHAR2

 ============================================================================*/

FUNCTION Notification_ToUser(user_id IN NUMBER) RETURN VARCHAR2 is
  --
  CURSOR c_user(v_user_id IN NUMBER) is
  SELECT user_name
  FROM fnd_user
  WHERE user_id = v_user_id;
  --
  v_ToUserName fnd_user.user_name%TYPE;
  e_UserNotFound EXCEPTION;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'Notification_ToUser');
     rlm_core_sv.dlog(C_DEBUG, 'User Id :', user_id);
  END IF;
  --
  OPEN c_user(user_id);
  FETCH c_user INTO v_ToUserName;
  --
  IF (c_user%NOTFOUND) THEN
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG,'Notification_ToUser :: No Data Found');
   END IF;
   --
   RAISE e_UserNotFound;
   --
  END IF;
  --
  CLOSE c_user;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'To User', v_ToUserName);
    rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  RETURN v_ToUserName;
  --
  EXCEPTION
    --
    WHEN e_UserNotFound THEN
      --
      rlm_message_sv.sql_error('RLM_WF_SV.Notification_ToUser',user_id);
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'Exception : e_UserNotFound');
       rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RAISE;
      --
END Notification_ToUser;

/*=============================================================================

  FUNCTION NAME:  Notification_FromUser

  DESCRIPTION:  This function returns the From User from whom the notifications
  		are sent. The From User is set as an attribute in the Work
  		Flow item.  We call an FND API in order to obtain the
                internal responsibility-based role name for a given
                responsibility.
                Modifications made as a part of bug 3764527.

  PARAMETERS:     responsibility_id          IN NUMBER
                  resp_appl_id             IN NUMBER

  RETURN:	  VARCHAR2

 ============================================================================*/

FUNCTION Notification_FromUser(responsibility_id NUMBER,
                               resp_appl_id      NUMBER) RETURN VARCHAR2 is
  --
  /*
   * Bug 3680168 : Do not need this cursor anymore
   * We now call an FND API to get the role name
   *
  CURSOR c_user(v_resp_id IN NUMBER, v_appl_id IN NUMBER) is
  SELECT display_name
  FROM wf_roles
  WHERE name =
	(
	SELECT 'FND_RESP' || r.application_id || ':' || r.responsibility_id
	FROM fnd_responsibility_vl r
	WHERE r.responsibility_id = v_resp_id
	AND r.application_id = v_appl_id);
  */
  --
  v_FromUserName     wf_roles.name%type;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(C_SDEBUG, 'Notification_FromUser');
    rlm_core_sv.dlog(C_DEBUG, 'Responsibility Id :', responsibility_id);
    rlm_core_sv.dlog(C_DEBUG, 'Application Id :', resp_appl_id);
  END IF;
  --
  v_FromUserName := FND_USER_RESP_GROUPS_API. upgrade_resp_role
                    (respid => responsibility_id,
                     appid => resp_appl_id);
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Internal Role Name', v_FromUserName);
    rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  RETURN v_FromUserName;
  --
  EXCEPTION
    --
    WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('RLM_WF_SV.Notification_FromUser',
                              SUBSTRB(SQLERRM, 1, 200));
     --
     IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG, 'When Others - ' || SUBSTRB(SQLERRM, 1, 200));
      rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     RAISE;
     --
END Notification_FromUser;

  -- Bug#: 3053299 - End of the functions

  -- Bug#: 3291401 - Start
/*=============================================================================

  Procedure NAME:  GetScheduleStatus

  DESCRIPTION:	    This procedure checks for the schedule status.

  PARAMETERS:       itemtype    IN VARCHAR2,
                    itemkey     IN VARCHAR2,
                    actid       IN NUMBER,
                    funcmode    IN VARCHAR2,
                    resultout   OUT NOCOPY VARCHAR2`

 ============================================================================*/


PROCEDURE GetScheduleStatus(
        itemtype    IN VARCHAR2,
        itemkey     IN VARCHAR2,
        actid       IN NUMBER,
        funcmode    IN VARCHAR2,
        resultout   OUT NOCOPY VARCHAR2)
IS

	CURSOR c_process_status_schedule(p_header_id IN NUMBER) is
	SELECT process_status
	FROM rlm_schedule_headers
	WHERE header_id = p_header_id;

	CURSOR c_process_status_interface(p_header_id IN NUMBER) is
	SELECT process_status
	FROM rlm_interface_headers
	WHERE header_id = p_header_id;

  --
  v_header_id          NUMBER;
  v_process_status     NUMBER;
BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'GetScheduleStatus');
       rlm_core_sv.dlog(C_DEBUG,'itemtype ', itemtype);
       rlm_core_sv.dlog(C_DEBUG,'itemkey ', itemkey);
       rlm_core_sv.dlog(C_DEBUG,'actid ', actid);
       rlm_core_sv.dlog(C_DEBUG,'funcmode ', funcmode);
    END IF;
    --
    IF  (FUNCMODE = 'RUN') THEN
    -- Executable Statements
       v_header_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,' Header_id :', v_header_id);
       END IF;
       --

       	OPEN c_process_status_schedule(g_Sch_rec.schedule_header_id); --Bug# 3567538

	FETCH c_process_status_schedule INTO v_process_status;

	IF (c_process_status_schedule%NOTFOUND) THEN

	       	OPEN c_process_status_interface(v_header_id);

		FETCH c_process_status_interface INTO v_process_status;

		IF (c_process_status_interface%NOTFOUND) THEN
			resultout :=  'COMPLETE:ERROR';
		END IF;

		IF (v_process_status IS NOT NULL AND v_process_status = RLM_CORE_SV.k_PS_PARTIAL_PROCESSED) THEN
			resultout :=  'COMPLETE:PARTIAL_PROCESS';
		ELSE
			resultout :=  'COMPLETE:ERROR';
		END IF ;

		CLOSE c_process_status_interface;
	END IF;

	IF (v_process_status IS NOT NULL AND v_process_status = RLM_CORE_SV.k_PS_PARTIAL_PROCESSED) THEN
		resultout :=  'COMPLETE:PARTIAL_PROCESS';
	ELSE
		resultout :=  'COMPLETE:ERROR';
	END IF;


	CLOSE c_process_status_schedule;

       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_SDEBUG);
       END IF;
       --
       RETURN;

    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE:ERROR';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'RESPOND') THEN
    -- Executable Statements
       resultout :=  'COMPLETE:ERROR';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'FORWARD') THEN
    -- Executable Statements
       resultout :=  'COMPLETE:ERROR';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TRANSFER') THEN
    -- Executable Statements
       resultout :=  'COMPLETE:ERROR';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'TIMEOUT') THEN
    -- Executable Statements
       resultout :=  'COMPLETE:ERROR';
       RETURN;
    END IF;

    IF  (FUNCMODE = 'CANCEL') THEN
    -- Executable Statements
       resultout :=  'COMPLETE:ERROR';
       RETURN;
    END IF;

EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('RLM_WF_SV','GetScheduleStatus',
                       itemtype, itemkey,TO_CHAR(actid),funcmode);
      resultout :=  'COMPLETE:ERROR';
      --
      IF (l_debug <> -1) THEN
         rlm_core_sv.dpop(C_SDEBUG);
      END IF;
      --
      RAISE;

END GetScheduleStatus;
-- Bug#: 3291401 - End

END RLM_WF_SV;

/
