--------------------------------------------------------
--  DDL for Package Body GL_AUTO_ALLOC_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTO_ALLOC_WF_PKG" AS
/*  $Header: glwfalcb.pls 120.15.12010000.2 2009/01/30 08:46:12 akhanapu ship $  */



PROCEDURE Start_AutoAllocation_Workflow( p_request_Id  IN NUMBER) IS
Begin
        -- generate item key
           GL_AUTO_ALLOC_WF_PKG.p_item_key := to_char(p_request_Id);
       If (diagn_debug_msg_flag) AND
                     G_DIR is NOT NULL then
              initialize_debug;
--              dbms_output.put_line('Log Directory:='||G_DIR);
--              dbms_output.put_line('Log File:='||G_FILE);
       End If;

       Create_And_Start_Wf(p_request_Id);

 EXCEPTION
    WHEN OTHERS THEN
       Wf_Core.Context('GL_AUTO_ALLOCATION_WF_PKG',
                      'Start_AutoAllocation_Workflow', p_item_type, p_item_key);
       Wf_Core.Get_Error(err_name,err_msg,err_stack);
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Start_AutoAllocation_Workflow: ' || err_msg ||'*'||err_stack);
       END IF;
      Raise;

 End Start_AutoAllocation_Workflow;


PROCEDURE Create_And_Start_Wf( p_request_Id IN NUMBER
				) IS

--      Local variables
        l_ALLOCATION_SET_ID                Number;
        l_ALLOCATION_SET_NAME              Varchar2(40);
        l_OWNER                            Varchar2(100);
        l_ACCESS_SET_ID                    Number;
        l_LEDGER_ID	                   Number;
        l_LEDGER_CURRENCY                  Varchar2(15);
        l_PERIOD_NAME                      Varchar2(15);
        l_BUDGET_VERSION_ID                Number;
        l_BALANCING_SEGMENT_VALUE          Varchar2(25);
        l_JOURNAL_EFFECTIVE_DATE           Date;
        l_CALCULATION_EFFECTIVE_DATE       Date;
        l_USAGE_CODE			   Varchar2(1);
        l_GL_PERIOD_NAME		   Varchar2(15);
        l_PA_PERIOD_NAME		   Varchar2(15);
	l_EXPENDITURE_ITEM_DATE		   Date;
        l_LAST_UPDATE_LOGIN                Number;
        l_CREATED_BY  	                   Number;
        l_LAST_UPDATED_BY                  Number;
        l_CHART_OF_ACCOUNTS_ID             NUMBER;
        l_monitor_url                      VARCHAR2(500);
        l_rollback_allowed                 VARCHAR2(1);
        l_resp_id                          NUMBER;
        l_user_id                          NUMBER;
        l_org_id                           NUMBER;
        l_resp_appl_id                     NUMBER;
        l_business_group_id                NUMBER;
        l_gl_allow_preparer_approval       Varchar2(30);
        l_continue_next_step               Varchar2(1);
        l_value       fnd_profile_option_values.profile_option_value%TYPE;
        l_WorkFlow_Launch                   Boolean;
        fnd_user_name                      Varchar2(100);
  Cursor c_set_name IS
    Select
    ALLOCATION_SET_ID
   ,ALLOCATION_SET_NAME
   ,OWNER
   ,ACCESS_SET_ID
   ,LEDGER_ID
   ,LEDGER_CURRENCY
   ,PERIOD_NAME
   ,BUDGET_VERSION_ID
   ,BALANCING_SEGMENT_VALUE
   ,JOURNAL_EFFECTIVE_DATE
   ,CALCULATION_EFFECTIVE_DATE
   ,USAGE_CODE
   ,GL_PERIOD_NAME
   ,PA_PERIOD_NAME
   ,EXPENDITURE_ITEM_DATE
   ,CREATED_BY
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_LOGIN
   ,ORG_ID
    From GL_AUTO_ALLOC_SET_HISTORY
    Where REQUEST_ID = p_request_Id;


   Cursor f_user_name IS
   SELECT user_name
   FROM fnd_user
   WHERE user_id = l_user_id;

   Cursor coa_id IS
   SELECT chart_of_accounts_id
   FROM GL_ACCESS_SETS
   WHERE access_set_id = l_access_set_id;

 Begin
   Open c_set_name;
   Fetch c_set_name into
    l_ALLOCATION_SET_ID
   ,l_ALLOCATION_SET_NAME
   ,l_OWNER
   ,l_ACCESS_SET_ID
   ,l_LEDGER_ID
   ,l_LEDGER_CURRENCY
   ,l_PERIOD_NAME
   ,l_BUDGET_VERSION_ID
   ,l_BALANCING_SEGMENT_VALUE
   ,l_JOURNAL_EFFECTIVE_DATE
   ,l_CALCULATION_EFFECTIVE_DATE
   ,l_USAGE_CODE
   ,l_GL_PERIOD_NAME
   ,l_PA_PERIOD_NAME
   ,l_EXPENDITURE_ITEM_DATE
   ,l_CREATED_BY
   ,l_LAST_UPDATED_BY
   ,l_LAST_UPDATE_LOGIN
   ,l_org_id;

   Close c_set_name;


    If l_allocation_set_id IS NULL Then
        l_WorkFlow_Launch := FALSE;
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Fatal error:No Allocation set='||to_char(p_request_Id));
        END IF;
    End If;


    If contain_Projects(p_item_key) Then
      If Not GL_PA_AUTOALLOC_PKG.valid_run_period(
                         l_ALLOCATION_SET_ID
                        ,l_PA_PERIOD_NAME
                        ,l_GL_PERIOD_NAME) Then
          l_WorkFlow_Launch := FALSE;
         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('Create_And_Start_Wf: ' || 'Workflow not started as required PA or GL period is not specified');
         END IF;
      Else
            l_WorkFlow_Launch := TRUE;
      End If;

        l_rollback_allowed := 'N' ;
    Else
        l_WorkFlow_Launch :=  TRUE;
        FND_PROFILE.GET('GL_AUTO_ALLOC_ROLLBACK_ALLOWED', l_value);
        If l_value = 'Y' Then
              l_rollback_allowed := 'Y';
        Else
              l_rollback_allowed := 'N';
        End If;

    End If;

    If (l_WorkFlow_Launch ) Then
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Create_And_Start_Wf: ' || 'Executing Start_Approval_Workflow for request_id '||
                                  to_char(p_request_Id));
       END IF;
       wf_engine.CreateProcess(  itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 process  => 'GL_SD_ALLOCATION_PROCESS' );

       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Create_And_Start_Wf: ' || 'Process for GL_SD_ALLOCATION_PROCESS created');
       END IF;

        OPEN coa_id;
        Fetch coa_id into l_chart_of_accounts_id;
        CLOSE coa_id;

        -- Set item user key
        wf_engine.SetItemUserKey( itemtype => p_item_type,
                                  itemkey  => p_item_key,
                                  userkey  => l_allocation_set_name );


        wf_engine.SetItemAttrText(itemtype => p_item_type,
                                  itemkey   => p_item_key,
                                  aname     => 'SET_NAME',
                                  avalue    => l_allocation_set_name );

        wf_engine.SetItemAttrNumber( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'SET_REQ_ID',
                                   avalue       => p_request_Id );

        FND_PROFILE.GET('USER_ID', l_user_id);
        if(l_org_id is null) then
           FND_PROFILE.GET('ORG_ID',  l_org_id);
        end if;
        FND_PROFILE.GET('RESP_ID', l_resp_id);
        FND_PROFILE.GET('RESP_APPL_ID', l_resp_appl_id);
        FND_PROFILE.GET('PER_BUSINESS_GROUP_ID', l_business_group_id);
        FND_PROFILE.GET('GL_ALLOW_PREPARER_APPROVAL', l_gl_allow_preparer_approval);

         -- Get AOL user name
         Open f_user_name;
         fetch f_user_name into fnd_user_name;
         close f_user_name;

          -- Set the process owner
          wf_engine.SetItemOwner( itemtype => p_item_type,
                                  itemkey  => p_item_key,
                                  owner    => fnd_user_name );

        FND_PROFILE.GET('GL_JRNL_REVW_REQUIRED', l_value);
        wf_engine.SetItemAttrText( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'GL_JRNL_REVW_REQUIRED',
                                   avalue       => l_value );

        -- Bug 2043415
        FND_PROFILE.GET('GL_AUTO_ALLOC_CONTINUE_NEXT_STEP', l_value);

        If l_value = 'Y' Then
              l_continue_next_step := 'Y';
        Else
              l_continue_next_step := 'N';
        End If;

        wf_engine.SetItemAttrText( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'CONTINUE_NEXT_STEP',
                                   avalue       => l_continue_next_step);

        wf_engine.SetItemAttrNumber( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'USER_ID',
                                   avalue       => l_user_id );

        wf_engine.SetItemAttrNumber( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'ORG_ID',
                                   avalue       => l_org_id );

        wf_engine.SetItemAttrNumber( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'RESP_ID',
                                   avalue       => l_resp_id );

        wf_engine.SetItemAttrNumber( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'BUSINESS_GROUP_ID',
                                   avalue       => l_business_group_id );

        wf_engine.SetItemAttrText( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'GL_ALLOW_PREPARER_APPROVAL',
                                   avalue       => l_gl_allow_preparer_approval );

        wf_engine.SetItemAttrNumber( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'RESP_APPL_ID',
                                   avalue       => l_resp_appl_id );


        -- Get the monitor URL
        begin
          l_monitor_url :=
                  wf_monitor.GetUrl(wf_core.translate('WF_WEB_AGENT'),
                                     p_item_type, p_item_key,'YES');
         Exception
             When others then
               l_monitor_url := 'Invalid URL';
        end;
        wf_engine.SetItemAttrText( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'MONITOR_URL',
                                   avalue          => l_monitor_url);
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'm_url='||l_monitor_url);
        END IF;
        UPDATE GL_AUTO_ALLOC_SET_HISTORY
        SET MONITOR_URL = l_monitor_url
        Where Request_Id = to_number(p_item_key);


        wf_engine.SetItemAttrText( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'ROLLBACK_ALLOWED',
                                   avalue          => l_rollback_allowed);

        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute Roolback_Allowed = ' ||l_rollback_allowed);
        END IF;

        --wf_engine.SetItemAttrText( itemtype        => p_item_type,
        --                           itemkey         => p_item_key,
        --                            aname           => 'BUD_CONTROL_FLAG',
        --                           avalue          => l_ENABLE_BUDGETARY_CON_FLAG);

        --wf_engine.SetItemAttrText( itemtype        => p_item_type,
        --                           itemkey         => p_item_key,
        --                           aname           => 'AUTOMATIC_TAX_FLAG',
        --                           avalue          => l_ENABLE_AUTOMATIC_TAX_FLAG);

        --wf_engine.SetItemAttrNumber( itemtype        => p_item_type,
        --                           itemkey         => p_item_key,
        --                           aname           => 'LATEST_ENCUMBRANCE_YEAR',
        --                           avalue          => l_LATEST_ENCUMBRANCE_YEAR);


        wf_engine.SetItemAttrText( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'STEP_CONTACT',
                                   avalue          => l_OWNER);

        wf_engine.SetItemAttrNumber( itemtype        => p_item_type,
                                     itemkey         => p_item_key,
                                     aname           => 'LEDGER_ID',
                                     avalue          => l_LEDGER_ID);

        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute LEDGER_ID = ' || to_char(l_LEDGER_ID));
        END IF;

        wf_engine.SetItemAttrText( itemtype        => p_item_type,
                                     itemkey         => p_item_key,
                                     aname           => 'LEDGER_CURRENCY',
                                     avalue          => l_LEDGER_CURRENCY);

        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute LEDGER_CURRENCY = ' || l_LEDGER_CURRENCY);
        END IF;

        wf_engine.SetItemAttrNumber( itemtype        => p_item_type,
                                     itemkey         => p_item_key,
                                     aname           => 'ACCESS_SET_ID',
                                     avalue          => l_ACCESS_SET_ID);

        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute ACCESS_SET_ID = ' || to_char(l_ACCESS_SET_ID));
        END IF;

        wf_engine.SetItemAttrText( itemtype        => p_item_type,
                                     itemkey         => p_item_key,
                                     aname           => 'BALANCING_SEGMENT_VALUE',
                                     avalue          => l_BALANCING_SEGMENT_VALUE);

        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute BALANCING_SEGMENT_VALUE = ' || l_BALANCING_SEGMENT_VALUE);
        END IF;

        wf_engine.SetItemAttrNumber( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'CHART_OF_ACCOUNTS_ID',
                                   avalue          => l_CHART_OF_ACCOUNTS_ID);

        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute CHART_OF_ACCOUNTS_ID = ' || to_char(l_CHART_OF_ACCOUNTS_ID));
        END IF;

        wf_engine.SetItemAttrText( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'PERIOD_NAME',
                                   avalue          => l_PERIOD_NAME);
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute PERIOD_NAME = ' ||l_PERIOD_NAME);
        END IF;

        wf_engine.SetItemAttrNumber( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'BUDGET_VERSION_ID',
                                   avalue          => l_BUDGET_VERSION_ID);

        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute BUDGET_VERSION_ID = ' ||
                            to_char(l_BUDGET_VERSION_ID));
        END IF;

        wf_engine.SetItemAttrDate( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'JOURNAL_EFFECTIVE_DATE',
                                   avalue          => l_JOURNAL_EFFECTIVE_DATE);
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute JOURNAL_EFFECTIVE_DATE = ' ||
                           to_char(l_JOURNAL_EFFECTIVE_DATE));
        END IF;

        wf_engine.SetItemAttrDate( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'CALCULATION_EFFECTIVE_DATE',
                                   avalue          => l_CALCULATION_EFFECTIVE_DATE);
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute CALCULATION_EFFECTIVE_DATE = ' ||
                         to_char(l_CALCULATION_EFFECTIVE_DATE));
        END IF;

        wf_engine.SetItemAttrDate( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'EXPENDITURE_ITEM_DATE',
                                   avalue          => l_EXPENDITURE_ITEM_DATE);
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute EXPENDITURE_ITEM_DATE = ' ||
                           to_char(l_EXPENDITURE_ITEM_DATE));
        END IF;

        wf_engine.SetItemAttrText( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'USAGE_CODE',
                                   avalue          => l_USAGE_CODE);
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute USAGE_CODE = ' ||l_USAGE_CODE);
        END IF;

        wf_engine.SetItemAttrText( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'GL_PERIOD_NAME',
                                   avalue          => l_GL_PERIOD_NAME);
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute GL_PERIOD_NAME = ' ||l_GL_PERIOD_NAME);
        END IF;


        wf_engine.SetItemAttrText( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'PA_PERIOD_NAME',
                                   avalue          => l_PA_PERIOD_NAME);
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute PA_PERIOD_NAME =  ' ||l_PA_PERIOD_NAME);
        END IF;

        wf_engine.SetItemAttrNumber( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'CREATED_BY',
                                   avalue          => l_CREATED_BY);
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute CREATED_BY =  ' ||to_char(l_CREATED_BY));
        END IF;

        wf_engine.SetItemAttrNumber( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'LAST_UPDATED_BY',
                                   avalue          => l_LAST_UPDATED_BY);
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute CREATED_BY = ' ||to_char(l_LAST_UPDATED_BY));
        END IF;


        wf_engine.SetItemAttrNumber( itemtype        => p_item_type,
                                   itemkey         => p_item_key,
                                   aname           => 'LAST_UPDATE_LOGIN',
                                   avalue          => l_LAST_UPDATE_LOGIN);
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Attribute LAST_UPDATE_LOGIN = ' ||to_char(l_LAST_UPDATE_LOGIN));
        	diagn_debug_msg('Create_And_Start_Wf: ' || 'Process GL_SD_ALLOCATION_PROCESS starting');
        END IF;
        wf_engine.StartProcess( itemtype => p_item_type,
                                itemkey  => p_item_key );


  End If;
  EXCEPTION
    WHEN OTHERS THEN
     Wf_Core.Context('GL_AUTO_ALLOCATION_WF_PKG',
                      'set_wf_variables', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Create_And_Start_Wf: ' || err_msg ||'*'||err_stack);
     END IF;
     Raise;
End Create_And_Start_Wf;

procedure Next_Step_Type(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result OUT NOCOPY VARCHAR2) Is

f_step_number         NUMBER;
f_batch_id            NUMBER;
f_batch_type_code     VARCHAR2(1);
f_allocation_method_code   VARCHAR2(1);
f_owner                    VARCHAR2(100);
f_batch_name               VARCHAR2(100);


Cursor step_detail ( l_step_number NUMBER) IS
      Select
            STEP_NUMBER
         ,  BATCH_ID
         ,  BATCH_TYPE_CODE
         ,  ALLOCATION_METHOD_CODE
         ,  OWNER
   From   GL_AUTO_ALLOC_BATCH_HISTORY
   Where REQUEST_ID  = to_number(p_item_key)
   AND   Step_number > l_step_number
   Order by Step_number ASC;


  l_step                Number;
  l_gen_batch_id        Number;
  l_batch_id            Number;
  l_status              Varchar2(1);
  l_batch_type_code     Varchar2(2);
  l_fail_flag           Varchar2(1) := 'N';
  l_batch_generated     Varchar2(1) := 'N';
  l_fail_batches        Varchar2(2000);

  Cursor get_je_batch_status_C IS
  Select jb.status, jb.je_batch_id
  FROM GL_JE_BATCHES jb,
       GL_AUTO_ALLOC_BATCH_HISTORY bh
  WHERE bh.request_id = to_number(p_item_key)
  AND   bh.step_number = l_step
  AND   jb.je_batch_id = bh.generated_je_batch_id;

Begin

If p_funcmode = 'RUN' THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Executing: Next_Step_Type');
   END IF;
   l_step := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');

   -- verify that previous step is completed
   If l_step Is Not Null  AND
      l_step <> 0 Then
      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Next_Step_Type: ' || 'Previous step = '||To_Char(l_step));
      END IF;
      l_batch_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'BATCH_ID');

      l_batch_type_code := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'BATCH_TYPE_CODE');

      --Verify that batch is posted i.e. present step is completed before fetching next step
      OPEN get_je_batch_status_C;
      LOOP
        fetch get_je_batch_status_C into l_status, l_gen_batch_id;
        EXIT WHEN get_je_batch_status_C%NOTFOUND;

        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Next_Step_Type: ' || 'Gen_Batch_Id = '||to_char(l_gen_batch_id)|| ' Code = '||l_batch_type_code);
        END IF;

        IF l_gen_batch_id IS NOT NULL THEN

          l_batch_generated := 'Y';

          If l_status = 'P' Then
             IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
             	diagn_debug_msg('Next_Step_Type: ' || 'Batch ' ||to_char(l_gen_batch_id) ||' is posted');
             END IF;
          ELSE
             IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
             	diagn_debug_msg('Next_Step_Type: ' || 'Batch ' ||to_char(l_gen_batch_id) ||' is not posted');
             END IF;
             l_fail_flag := 'Y';
             l_fail_batches := l_fail_batches || '*' || to_char(l_gen_batch_id);
          END IF;
        END IF;

      END LOOP;
      close get_je_batch_status_C;


      IF l_batch_generated = 'N' THEN
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Next_Step_Type: ' || 'Allocation Batch '||to_char(l_batch_id)||' is not generated');
        END IF;
      ELSE
        IF  l_fail_flag = 'N' THEN
           IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
           	diagn_debug_msg('Next_Step_Type: ' || 'Batch is posted. Mark step as complete');
           END IF;
           Update GL_AUTO_ALLOC_BATCH_HISTORY
           Set COMPLETE_FLAG = 'Y'
           Where REQUEST_ID = to_number(p_item_key)
           And STEP_NUMBER  = l_step;
           --And BATCH_ID     = l_batch_id
           --And BATCH_TYPE_CODE = l_batch_type_code;

           If SQL%FOUND Then
             diagn_debug_msg('Rows updated='||to_char(SQL%ROWCOUNT));
           Else
             IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
             	diagn_debug_msg('Next_Step_Type: ' || 'No update any row for complete flag = Y');
             END IF;
           End If;
        ELSE
           IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
           	diagn_debug_msg('Next_Step_Type: ' || 'Batches= '|| l_fail_batches || ' generated but not posted');
           END IF;
        END IF;

      END IF;
   End If; /* l_step is not null or 0 */

   Open step_detail(l_step);

   Fetch step_detail
   Into
     f_step_number
   , f_batch_id
   , f_batch_type_code
   , f_allocation_method_code
   , f_owner;

  Close step_detail;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Next_Step_Type: ' || '***********************************************');
   	diagn_debug_msg('Next_Step_Type: ' || 'FETCHED NEXT STEP = '||to_char(f_step_number)||
                     ' Batch_Type_Code = '||f_batch_type_code);
   	diagn_debug_msg('Next_Step_Type: ' || '***********************************************');
   END IF;
   wf_engine.SetItemAttrNumber(
             itemtype => p_item_type,
             ITEMkey  => p_item_key,
             aname    => 'STEP_NUMBER',
             avalue   => f_step_number );

   wf_engine.SetItemAttrtext(
             itemtype => p_item_type,
             itemkey  => p_item_key,
             aname   => 'BATCH_TYPE_CODE',
             avalue   => f_batch_type_code );

   wf_engine.SetItemAttrNumber(
             itemtype => p_item_type,
             itemkey  => p_item_key,
             aname    =>  'BATCH_ID',
             avalue   => f_batch_id );

   wf_engine.SetItemAttrtext(
             itemtype => p_item_type,
             itemkey  => p_item_key,
             aname    => 'ALLOCATION_METHOD_CODE',
             avalue   => f_allocation_method_code );

    wf_engine.SetItemAttrtext(
             itemtype => p_item_type,
             itemkey  => p_item_key,
             aname    => 'STEP_CONTACT',
             avalue   => f_owner );

      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Next_Step_Type: ' || 'Step Contact = ' ||f_owner);
      END IF;
   If f_batch_id Is Not Null Then
     f_batch_name := gl_auto_alloc_vw_pkg.Get_Batch_Name(
                     BATCH_TYPE_CODE => f_batch_type_code
                    ,BATCH_ID => f_batch_id
                 );
    Else
       f_batch_name := NULL;
   End If;

   wf_engine.SetItemAttrtext(
             itemtype => p_item_type,
             itemkey  => p_item_key,
             aname    => 'BATCH_NAME',
             avalue   => f_batch_name  );

   If f_step_number IS NULL Then
      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Next_Step_Type: ' || 'Autoallocation completed sucessfully.');
      END IF;
      p_result := 'COMPLETE:COMPLETE';
   Elsif f_batch_type_code in ('A', 'B', 'E', 'R') then
      p_result := 'COMPLETE:GL';
   Elsif f_batch_type_code = 'P' then
    p_result := 'COMPLETE:PA';
   End If;
    return;
 ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
 End If;

EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Next_Step_Type', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Next_Step_Type: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,f_step_number
                    ,'UFE'
                    );
    Raise;
End Next_Step_Type;

procedure Find_Je_Batch_Type(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result  OUT NOCOPY VARCHAR2) Is
l_Batch_Type_Code  VARCHAR2(1);
l_definition_form  Varchar2(500)  := NULL;
l_batch_id         Number;
l_step_number      Number;

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started Find_Je_Batch_Type');
   END IF;

    l_Batch_Type_Code := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'BATCH_TYPE_CODE');
    l_batch_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'BATCH_ID');
    l_step_number  := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');

     l_definition_form := NULL;

     If l_Batch_Type_Code in ('A','B','E') then
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Find_Je_Batch_Type: ' || 'Batch type = MassAllocations');
       END IF;
       If l_Batch_Type_Code In( 'A','E')  Then
           l_definition_form := 'GLXMADEF_A: ALLOC_BATCH_ID='|| to_char(l_batch_id);
       ElsIf l_Batch_Type_Code = 'B' Then
           l_definition_form := 'GLXMADEF_B: ALLOC_BATCH_ID='|| to_char(l_batch_id);
       End If;
       p_result := 'COMPLETE:MA';
     Elsif l_Batch_Type_Code = 'R' Then
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Find_Je_Batch_Type: ' || 'Batch Type = Recurring');
       END IF;
       l_definition_form := 'GLXRJDEF_A: PARM_BATCH_ID='|| to_char(l_batch_id);
       p_result := 'COMPLETE:R';
     Else
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Find_Je_Batch_Type: ' || 'Incorrect batch type = '||l_Batch_Type_Code);
       END IF;
     End if;

      wf_engine.SetItemAttrText
                  ( itemtype    => p_item_type,
                    itemkey     => p_item_key,
                    aname       => 'DEFINITION_FORM',
                    avalue      => l_definition_form );

 ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
 End If;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Find_Je_Batch_Type', p_item_type, p_item_key);
    Wf_Core.Get_Error(err_name,err_msg,err_stack);
    IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
    	diagn_debug_msg('Find_Je_Batch_Type: ' || err_msg ||'*'||err_stack);
    END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );

    Raise;
End Find_Je_Batch_Type;

Procedure Is_Review_Required(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result OUT NOCOPY VARCHAR2) Is

l_batch_review_required  fnd_profile_option_values.profile_option_value%TYPE;
l_step_number Number;
l_rollback_allowed Varchar2(1);
l_message_Name Varchar2(150);

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started Is_Review_Required');
   END IF;
   l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                        'STEP_NUMBER');

   l_rollback_allowed := WF_ENGINE.GetItemAttrText(
                           p_item_type,
                           p_item_key,
                           'ROLLBACK_ALLOWED');

   l_batch_review_required := WF_ENGINE.GetItemAttrText(
                           p_item_type,
                           p_item_key,
                           'GL_JRNL_REVW_REQUIRED');


   If l_batch_review_required = 'Y' Then
      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Is_Review_Required: ' || 'Review required before posting. Sending Notification');
      END IF;
      If l_rollback_allowed = 'Y' Then
          l_message_name := 'GLALLOC:BATCH_REVIEW_REQUIRED';
      Else
         l_message_name := 'GLALLOC:BATCH_REVIEW_REQUIRED_NRB';
      End If;

      wf_engine.SetItemAttrText(itemtype => p_item_type,
                                  itemkey   => p_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => l_message_Name );

      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Is_Review_Required: ' || 'Message_name = '||l_message_Name);
      END IF;

      Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'JRP'
                    );
     p_result := 'COMPLETE:Y';
   Else
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Review_Required: ' || 'Review required before posting:= No');
     END IF;
     -- making  sure that status is generation complete
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'GC'
                    );
     p_result := 'COMPLETE:N';
   End If;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Is_Review_Required', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Review_Required: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );

     Raise;
End Is_Review_Required;

Procedure Is_Approval_Required(p_item_type      IN VARCHAR2,
                               p_item_key       IN VARCHAR2,
                               p_actid          IN NUMBER,
                               p_funcmode       IN VARCHAR2,
                               p_result OUT NOCOPY VARCHAR2) Is
 l_gen_batch_id      Number;
 l_step_number       Number;
 l_approval_code     Varchar2(1);
 l_approval_flag     Varchar2(1) := 'N';
 l_approval_batch    Varchar2(2000);

 Cursor jrnl_approval_required_C IS
 Select JB.APPROVAL_STATUS_CODE,JB.JE_BATCH_ID
 FROM GL_JE_BATCHES jb,
 GL_AUTO_ALLOC_BATCH_HISTORY bh
 WHERE bh.request_id = to_number(p_item_key)
 AND   bh.step_number = l_step_number
 AND   jb.je_batch_id = bh.generated_je_batch_id;

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started Is_Approval_Required');
   END IF;
   --l_gen_batch_id := WF_ENGINE.GetItemAttrNumber
   --                     (p_item_type,
   --                      p_item_key,
   --                     'GEN_BATCH_ID');
   l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                        'STEP_NUMBER');

   OPEN jrnl_approval_required_C;
   LOOP
     fetch jrnl_approval_required_C into l_approval_code,l_gen_batch_id;
     EXIT WHEN jrnl_approval_required_C%NOTFOUND;

     If l_approval_code  <> 'Z' Then
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Is_Approval_Required: ' || 'Journal approval require for '||to_char(l_gen_batch_id));
       END IF;
       l_approval_flag := 'Y';
       l_approval_batch := l_approval_batch || '*'|| to_char(l_gen_batch_id);
     Else
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Is_Approval_Required: ' || 'Journal approval not require for '||to_char(l_gen_batch_id));
       END IF;
     End If;
   END LOOP;
   CLOSE jrnl_approval_required_C;

   IF l_approval_flag = 'Y' THEN
     -- some batches require journal approval
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Approval_Required: ' || 'Journal approval required batches = '|| l_approval_batch);
     END IF;
     --Set status as journal approval pending
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'JAP'
                    );
     p_result := 'COMPLETE:Y';
     return;
   ELSE
     --making sure that status is generation completed.
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'GC'
                    );
     p_result := 'COMPLETE:N';
     return;
   END IF;

ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Is_Approval_Required', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Approval_Required: ' || err_msg ||'*'||err_stack);
     END IF;
     -- set status code to unexpected fatal error
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );

    Raise;
End Is_Approval_Required;

Procedure Launch_JE_Approval(p_item_type  IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode       IN VARCHAR2,
                         p_result OUT NOCOPY VARCHAR2) Is
l_gen_batch_id         Number;
l_gen_batch_name       Varchar2(100);
l_approval_code        Varchar2(1);
l_user_id              Number;
l_resp_id              Number;
l_step_number          Number;
l_org_id               NUMBER;
l_resp_appl_id         NUMBER;
l_business_group_id    NUMBER;
l_gl_allow_preparer_approval  Varchar2(30);

Cursor jrnl_approval_status_C IS
 Select JB.APPROVAL_STATUS_CODE,JB.NAME,JB.JE_BATCH_ID
 FROM GL_JE_BATCHES jb,
 GL_AUTO_ALLOC_BATCH_HISTORY bh
 WHERE bh.request_id = to_number(p_item_key)
 AND   bh.step_number = l_step_number
 AND   jb.je_batch_id = bh.generated_je_batch_id;

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started Launch_JE_Approval');
   END IF;

   l_step_number   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');

   l_user_id   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'USER_ID');

   l_resp_id   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'RESP_ID');

   l_org_id   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'ORG_ID');


   l_resp_appl_id   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'RESP_APPL_ID');

   l_business_group_id   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'BUSINESS_GROUP_ID');

   l_gl_allow_preparer_approval   := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'GL_ALLOW_PREPARER_APPROVAL');


   FND_PROFILE.put('ORG_ID', l_org_id);
   FND_PROFILE.put('USER_ID', l_user_id );
   FND_PROFILE.put('RESP_ID', l_resp_id);
   FND_PROFILE.put('RESP_APPL_ID', l_resp_appl_id);
   FND_PROFILE.put('PER_BUSINESS_GROUP_ID', l_business_group_id);
   FND_PROFILE.put('GL_ALLOW_PREPARER_APPROVAL', l_gl_allow_preparer_approval);

   OPEN jrnl_approval_status_C;
   LOOP
     fetch jrnl_approval_status_C into l_approval_code, l_gen_batch_name,l_gen_batch_id;
     EXIT WHEN jrnl_approval_status_C%NOTFOUND;

     If l_approval_code In ( 'Z','A','I') Then
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Launch_JE_Approval: ' || 'Journal already approved. Journal approval not launched');
       END IF;
     Elsif l_approval_code = 'R' Then
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Launch_JE_Approval: ' || 'Launching journal approval process');
       END IF;
       GL_WF_JE_APPROVAL_PKG.start_approval_workflow
                  ( p_je_batch_id          => l_gen_batch_id
                   ,p_preparer_fnd_user_id => l_user_id
                   ,p_preparer_resp_id     => l_resp_id
                   ,p_je_batch_name        => l_gen_batch_name
                  );
    End If;
  END LOOP;
  CLOSE jrnl_approval_status_C;

ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Launch_JE_Approval', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Launch_JE_Approval: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );
    Raise;
End Launch_JE_Approval;

Procedure Is_Batch_Approved(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result  OUT NOCOPY VARCHAR2) Is

 l_gen_batch_id      Number;
 l_step_number       Number;
 l_approval_code     Varchar2(1);
 l_rollback_allowed  Varchar2(1);
 l_message_Name      Varchar2(150);
 l_fail_flag         Varchar2(1);
 l_fail_batches      Varchar2(2000);

Cursor jrnl_approval_status_C IS
 Select JB.APPROVAL_STATUS_CODE,JB.JE_BATCH_ID
 FROM GL_JE_BATCHES jb,
      GL_AUTO_ALLOC_BATCH_HISTORY bh
 WHERE bh.request_id = to_number(p_item_key)
 AND   bh.step_number = l_step_number
 AND   jb.je_batch_id = bh.generated_je_batch_id;

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started Is_Batch_Approved');
   END IF;

   l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                        'STEP_NUMBER');
   l_rollback_allowed := WF_ENGINE.GetItemAttrText(
                           p_item_type,
                           p_item_key,
                           'ROLLBACK_ALLOWED');


   OPEN jrnl_approval_status_C;
   LOOP
     FETCH jrnl_approval_status_C into l_approval_code, l_gen_batch_id;
     EXIT WHEN jrnl_approval_status_C%NOTFOUND;

     If l_approval_code in ('Z' , 'A') Then
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Is_Batch_Approved: ' || 'Journal batch '||to_char(l_gen_batch_id)||' is approved');
        END IF;
     Else
        -- If l_approval_code in ('I','R') Then
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Is_Batch_Approved: ' || 'Journal batch '||to_char(l_gen_batch_id)||
                     ' not yet approved. Sending Notification');
        END IF;
        l_fail_flag := 'Y';
        l_fail_batches := l_fail_batches || '*' || to_char(l_gen_batch_id) || 'approval failed';
    END IF;
  END LOOP;
  CLOSE jrnl_approval_status_C;

  if l_fail_flag = 'Y' THEN
      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Is_Batch_Approved: ' || 'Failed batches = '|| l_fail_batches|| 'Sending Notification');
      END IF;

      If l_rollback_allowed = 'Y' Then
          l_message_name := 'GLALLOC:JOURNAL_APPROVAL_REQUIRED';
      Else
          l_message_name := 'GLALLOC:JOURNAL_APPROVAL_REQUIRED_NRB';
      End If;

      wf_engine.SetItemAttrText(itemtype => p_item_type,
                                itemkey   => p_item_key,
                                aname     => 'MESSAGE_NAME',
                                avalue    => l_message_Name );

      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Is_Batch_Approved: ' || 'Message_name = '||l_message_Name);
      END IF;
      -- status Journal Approval Pending
      Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'JAP'
                       );
      p_result := 'COMPLETE:N';
      return;
   ELSE
      -- make sure that status is generation complete
      Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'GC'
                      );
      p_result := 'COMPLETE:Y';
      return;
   End If;

ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Is_Approval_Required', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Batch_Approved: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );

    Raise;
End Is_Batch_Approved;


Procedure Is_Batch_Generated(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result OUT NOCOPY VARCHAR2) Is

 l_batch_id              Number;
 l_access_set_id         Number;
 l_step_number           Number;
 l_batch_type_code       Varchar2(1);
 l_rollback_allowed      Varchar2(1);
 l_message_Name          Varchar2(150);
 l_generated_je_batch_id NUMBER := NULL;
 l_generated_batch_name  Varchar2(100) := NULL;
 l_enter_journals        VARCHAR2(500);
 l_generated_flag        VARCHAR2(1) := 'N';

 Cursor get_gen_batch_id_C Is
 Select A.GENERATED_JE_BATCH_ID,
        JEB.Name
 From GL_JE_BATCHES JEB
     ,GL_AUTO_ALLOC_BATCH_HISTORY A
 Where JEB.JE_BATCH_ID = A.GENERATED_JE_BATCH_ID
 AND   A.REQUEST_ID      = to_number(p_item_key)
 AND   A.STEP_NUMBER     = l_step_number;

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started Is_Batch_Generated');
   END IF;

   l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                        'STEP_NUMBER');

   l_access_set_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                        'ACCESS_SET_ID');


   l_batch_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                        'BATCH_ID');

   l_batch_type_code := WF_ENGINE.GetItemAttrText(
                           p_item_type,
                           p_item_key,
                           'BATCH_TYPE_CODE');


   l_rollback_allowed := WF_ENGINE.GetItemAttrText(
                           p_item_type,
                           p_item_key,
                           'ROLLBACK_ALLOWED');

   Open get_gen_batch_id_C;
   LOOP
     Fetch get_gen_batch_id_C into
       l_generated_je_batch_id,
       l_generated_batch_name;
     EXIT WHEN get_gen_batch_id_C%NOTFOUND;

     If (l_batch_type_code = 'E') THEN
          l_enter_journals := 'GLXJEENT_E:autoquery_level=' || '"' || 'BATCH' || '"' ||
                               ' autoquery_coordination=' || '"' || 'INITIAL' || '"' ||
                               ' autoquery_criteria=' || to_char(l_generated_je_batch_id) ||
                                 ' autoquery_access_set_id=' || to_char(l_access_set_id);
     ELSE
         l_enter_journals := 'GLXJEENT_A:autoquery_level=' || '"' || 'BATCH' ||
                             '"' || ' autoquery_coordination=' || '"' || 'INITIAL' ||
                             '"' || ' autoquery_criteria=' || to_char(l_generated_je_batch_id) ||
                             ' autoquery_access_id=' || to_char(l_access_set_id);
     END IF;

     wf_engine.SetItemAttrText ( itemtype    => p_item_type,
                                    itemkey     => p_item_key,
                                    aname       => 'ENTER_JOURNALS_FORM',
                                    avalue      => l_enter_journals );

     If l_generated_je_batch_id IS NOT NULL Then
         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('Is_Batch_Generated: ' || 'Generated batch='||To_char(l_generated_je_batch_id)||' found');
         END IF;
         l_generated_flag := 'Y';
     Else
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Is_Batch_Generated: ' || 'Batch not Generated or Not found in GL_JE_BATCHES. Sending Notification');
        END IF;
     End IF;
   END LOOP;
   CLOSE get_gen_batch_id_C;

   IF l_generated_flag = 'N' THEN
      --If l_rollback_allowed = 'Y' Then
      --    l_message_name := 'GLALLOC:NO_BATCH_GENERATED';
      --Else
      --    l_message_name := 'GLALLOC:NO_BATCH_GENERATED_NRB';
      --End If;

      --wf_engine.SetItemAttrText(itemtype => p_item_type,
      --                          itemkey   => p_item_key,
      --                          aname     => 'MESSAGE_NAME',
      --                          avalue    => l_message_Name );

      --IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     -- 	diagn_debug_msg('Is_Batch_Generated: ' || 'Message_name = '||l_message_Name);
      --END IF;
      -- set status code to Batch Not Generated
      --Update_Status(to_number(p_item_key)
      --              ,l_step_number
      --              ,'BNG'
      --                );
      p_result := 'COMPLETE:N';
      return;
   ELSE
      Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'GC'
                    );
      p_result := 'COMPLETE:Y';
      return;
   End IF;

ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Is_Batch_Generated', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Batch_Generated: ' || err_msg ||'*'||err_stack);
     END IF;
    -- set status code to unexpected fatal error
    Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );
    Raise;
End Is_Batch_Generated;

Procedure Select_And_Validate_Batch(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result OUT NOCOPY VARCHAR2) Is

 l_result                Varchar2(1);
 l_error_msg             Varchar2(2000);
 l_gen_batch_id          Number;
 l_step_number           Number;
 l_rollback_allowed      Varchar2(1);
 l_message_Name          Varchar2(150);
 l_batches_not_valid     Varchar2(32000) := NULL;

CURSOR get_all_batches_C IS
SELECT jb.je_batch_id
FROM GL_JE_BATCHES jb,
     GL_AUTO_ALLOC_BATCH_HISTORY bh
WHERE bh.request_id = to_number(p_item_key)
AND   bh.step_number = l_step_number
AND   jb.je_batch_id = bh.generated_je_batch_id
AND   jb.status NOT IN ('P','I','S');

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started Select_And_Validate_Batch');
   END IF;

   l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                        'STEP_NUMBER');
   l_rollback_allowed := WF_ENGINE.GetItemAttrText(
                           p_item_type,
                           p_item_key,
                           'ROLLBACK_ALLOWED');
   OPEN get_all_batches_C;
   LOOP
     FETCH get_all_batches_C into l_gen_batch_id;
     EXIT WHEN get_all_batches_C%NOTFOUND;

     Is_JE_Valid_For_Posting
                     ( itemtype          => p_item_type
                      ,itemkey           => p_item_key
                      ,l_je_batch_id     => l_gen_batch_id
                      ,l_invalid_error   => l_error_msg
                      ,result            => l_result
                    );
     If l_result  In ('Y', 'P') Then
        If l_result = 'P' Then
           IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
           	diagn_debug_msg('Select_And_Validate_Batch: ' || 'Batch '||to_char(l_gen_batch_id)||' is already posted');
           END IF;
        Else
           IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
           	diagn_debug_msg('Select_And_Validate_Batch: ' || 'Batch  '||to_char(l_gen_batch_id)||' is valid for posting');
           END IF;
        End If;
     Else
        l_batches_not_valid := l_batches_not_valid ||'Batch_Id='||
             to_char(l_gen_batch_id)||'*'||substrb(l_error_msg,1,80);
     End If;
   END LOOP;
   CLOSE get_all_batches_C;

   IF l_batches_not_valid IS NULL THEN
        -- making sure that status is generation complete
        Update_Status(to_number(p_item_key)
                      ,l_step_number
                      ,'GC'
                      );

        p_result := 'COMPLETE:PASS';
        return;
   ELSE
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Select_And_Validate_Batch: ' || 'Sending Notification. '||l_error_msg);
        END IF;
         -- status Batch Not postable

        If l_rollback_allowed = 'Y' Then
          l_message_name := 'GLALLOC:GEN_BATCH_NOT_POSTABLE';
        Else
          l_message_name := 'GLALLOC:GEN_BATCH_NOT_POSTABLE_NRB';
        End If;

        wf_engine.SetItemAttrText(itemtype => p_item_type,
                                  itemkey   => p_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => l_message_Name );

        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Select_And_Validate_Batch: ' || 'Message_name = '||l_message_Name);
        END IF;

        l_batches_not_valid := substrb(l_batches_not_valid,1,2000);

        wf_engine.SetItemAttrText(
                itemtype  => p_item_type,
                itemkey   => p_item_key,
                aname     => 'ERROR_BATCHES',
                avalue    => l_batches_not_valid );

        -- Rollback batch not postable
        Update_Status(to_number(p_item_key)
                      ,l_step_number
                      ,'BNP'
                      );

        p_result := 'COMPLETE:FAIL';
        return;
   End If;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS  THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Select_And_Validate_Batch', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Select_And_Validate_Batch: ' || err_msg ||'*'||err_stack);
     END IF;
     -- set status code to unexpected fatal error
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );
     Raise;
End Select_And_Validate_Batch;

Procedure Is_Batch_Posted(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result OUT NOCOPY VARCHAR2) Is


l_gen_batch_id          Number;
l_step_number           Number;
l_status                Varchar2(1);
l_rollback_allowed      Varchar2(1);
l_message_Name          Varchar2(150);
l_fail_flag             Varchar2(1) := 'N';
l_fail_batches          Varchar2(150);

Cursor check_JE_batch_status_C IS
  Select jb.je_batch_id, jb.status
  From GL_JE_BATCHES jb,
       GL_AUTO_ALLOC_BATCH_HISTORY bh
  Where bh.request_id = to_number(p_item_key)
  And   bh.step_number = l_step_number
  And   jb.je_batch_id = bh.generated_je_batch_id;

Begin
 If ( p_funcmode = 'RUN' ) THEN
    GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
    IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
    	diagn_debug_msg('Started Is_Batch_Posted');
    END IF;

    l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                        'STEP_NUMBER');
    l_rollback_allowed := WF_ENGINE.GetItemAttrText(
                          p_item_type,
                          p_item_key,
                          'ROLLBACK_ALLOWED');

    open check_JE_batch_status_C;
    LOOP
      fetch check_JE_batch_status_C into l_gen_batch_id,l_status;
      EXIT WHEN  check_JE_batch_status_C%NOTFOUND;

      If l_status In ('P') Then
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Is_Batch_Posted: ' || 'Batch '||to_char(l_gen_batch_id)||' is posted successfully');
        END IF;
      Else
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Is_Batch_Posted: ' || 'Sending Notification. Batch '||to_char(l_gen_batch_id)|| ' posting failed. Status= '||l_status);
        END IF;
        l_fail_flag := 'Y';
        l_fail_batches := l_fail_batches || '*' || to_char(l_gen_batch_id);
      End if;
    END LOOP;
    CLOSE check_JE_batch_status_C;

    IF l_fail_flag = 'Y' Then
      -- Some batches are not posted
      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Is_Batch_Posted: ' || 'Failed batches = ' || l_fail_batches || 'Sending Notification ');
      END IF;

      If l_rollback_allowed = 'Y' Then
          l_message_name := 'GLALLOC:GEN_BATCH_NOT_POSTED';
      Else
         l_message_name := 'GLALLOC:GEN_BATCH_NOT_POSTED_NRB';
      End If;

      wf_engine.SetItemAttrText(itemtype => p_item_type,
                                  itemkey   => p_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => l_message_Name );
      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Is_Batch_Posted: ' || 'Message_name = '||l_message_Name);
      END IF;

      --journal batch not posted  status
      Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'JBNP'
                     );
      p_result := 'COMPLETE:N';
   ELSE
      Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'PC'
                    );

       p_result := 'COMPLETE:Y';
   END IF;

ELSIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Is_Batch_Posted', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Batch_Posted: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );
    Raise;
End Is_Batch_Posted;

Procedure Delete_Batch(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result OUT NOCOPY VARCHAR2) Is

l_step_number            Number;
l_batch_id               Number;
l_batch_type_code        Varchar2(1);
l_gen_batch_Id           Number;
l_gen_batch_name         Varchar2(100);
l_complete_flag          Varchar2(1);
l_status                 Varchar2(1);

Cursor Verify_Delete_C IS
Select
 H.Step_Number
,H.Batch_Id
,H.BATCH_TYPE_CODE
,H.GENERATED_JE_BATCH_ID
,H.COMPLETE_FLAG
,JEB.Name
,JEB.Status
From GL_JE_BATCHES JEB
    ,GL_AUTO_ALLOC_BATCH_HISTORY H
Where
JEB.JE_BATCH_ID  = H.GENERATED_JE_BATCH_ID
AND H.REQUEST_ID = to_number(p_item_key)
AND H.GENERATED_JE_BATCH_ID IS Not Null
AND JEB.Status  <> 'P'
Order By H.STEP_NUMBER Desc;

Cursor Set_Status_C IS
Select step_number
From GL_AUTO_ALLOC_BATCH_HISTORY
Where
    REQUEST_ID= to_number(p_item_key)
AND GENERATED_JE_BATCH_ID IS NULL
AND STATUS_CODE <> 'NS';

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Rollback:Started Delete_Batch');
   END IF;

    Open Verify_Delete_C;
    LOOP
      Fetch Verify_Delete_C Into
          l_step_number
          ,l_batch_id
          ,l_batch_type_code
          ,l_gen_batch_Id
          ,l_complete_flag
          ,l_gen_batch_name
          ,l_status;

      If Verify_Delete_C%NOTFOUND Then
         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('Delete_Batch: ' || 'Rollback:No Batch to delete');
         END IF;
         open  Set_Status_C;
         fetch Set_Status_C into l_step_number;
         If Set_Status_C%FOUND Then
             --set status to Rollback Not Required
             Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RNR'
                    );
         End If;
         close Set_Status_C;
         exit;
      Else
         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('Delete_Batch: ' || 'Rollback:Deleting Batch= '||to_char(l_gen_batch_Id));
         END IF;
         -- Delete all of the lines in that batch
             DELETE gl_je_lines
             WHERE  je_header_id IN (SELECT je_header_id
                            FROM   gl_je_headers
                            WHERE  je_batch_id = l_gen_batch_Id);

             -- Delete all of the headers in that batch
                DELETE gl_je_headers
                WHERE  je_batch_id = l_gen_batch_Id;

             -- Delete gl_je_batch
                DELETE gl_je_batches
                WHERE  je_batch_id = l_gen_batch_Id;

          IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
          	diagn_debug_msg('Delete_Batch: ' || 'Rollback:Batch deleted');
          END IF;
          --set status to Rollback Completed for this step
          Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RC'
                    );
    End IF;
  END LOOP;
  Close Verify_Delete_C;
      --set status to rollback pending for all step for which
      -- where status is NOT [Not started, Rollback Not Required, Rollback Completed]
      Update_Status(to_number(p_item_key)
                    ,-1
                    ,'RP'
                    );

  Return;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Delete_Batch', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Delete_Batch: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RUFE'
                    );
    Raise;
End Delete_Batch;

Procedure Are_More_JE_Reverse(p_item_type  IN VARCHAR2,
                         p_item_key        IN VARCHAR2,
                         p_actid           IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result          OUT NOCOPY VARCHAR2) Is

l_step_number            Number;
l_gen_batch_id           Number;
l_je_header_id           Number;
f_je_header_id           Number;

Cursor Get_Batches_C IS
Select
 Step_Number
,GENERATED_JE_BATCH_ID
From GL_AUTO_ALLOC_BATCH_HISTORY
WHERE REQUEST_ID = to_number(p_item_key)
And COMPLETE_FLAG = 'Y'
And Nvl(ALL_HEADERS_REVERSED,'N') <>  'Y'
And STEP_NUMBER  <=  l_step_number
Order by STEP_NUMBER desc;

Cursor Get_Headers_C IS
Select JE.JE_HEADER_ID
FROM GL_JE_HEADERS JE
WHERE JE.JE_BATCH_ID = l_gen_batch_id
AND NOT EXISTS ( SELECT RB.JE_HEADER_ID
                FROM GL_AUTO_ALLOC_REV_BATCHES RB
                WHERE RB.PARENT_REQUEST_ID = to_number(p_item_key)
                AND   RB.JE_HEADER_ID = JE.JE_HEADER_ID);

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Rollback:Started Are_More_JE_Reverse');
   END IF;
   l_step_number :=   WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');


   l_gen_batch_id :=   WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'GEN_BATCH_ID');

   IF l_gen_batch_id IS NOT NULL THEN
     Open  Get_Headers_C;
     Fetch Get_Headers_C Into f_je_header_id;
     Close Get_Headers_C;

     If f_je_header_id IS NOT NULL Then
          WF_ENGINE.SetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'JE_HEADER_ID'
                         ,f_je_header_id);

          IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
          	diagn_debug_msg('Are_More_JE_Reverse: ' || 'Rollback:header = '||to_char(f_je_header_id)||' to be reversed');
          END IF;

          --set status to rollback reversal pending for this step
          Update_Status(to_number(p_item_key)
                        ,l_step_number
                        ,'RRP');

          p_result := 'COMPLETE:Y';
          return;
     Else
          IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
          	diagn_debug_msg('Are_More_JE_Reverse: ' || '*********************************************************');
          	diagn_debug_msg('Are_More_JE_Reverse: ' || 'ROLLBACK: All HEADERS ARE REVERSED FOR STEP '||to_char(l_step_number)|| ' GEN BATCH '||to_char(l_gen_batch_id));
          	diagn_debug_msg('Are_More_JE_Reverse: ' || '*********************************************************');
          END IF;
          UPDATE GL_AUTO_ALLOC_BATCH_HISTORY
          Set ALL_HEADERS_REVERSED = 'Y'
          WHERE REQUEST_ID = to_number(p_item_key)
          And GENERATED_JE_BATCH_ID = l_gen_batch_id;
          diagn_debug_msg('Rows updated = '||to_char(SQL%ROWCOUNT));

          --set status to rollback reversal completed for this step
          Update_Status(to_number(p_item_key)
                        ,l_step_number
                        ,'RRC');

     End If; /* f_je_header_id is not null */

   Loop
      l_step_number :=   WF_ENGINE.GetItemAttrNumber
                  (p_item_type,
                   p_item_key,
                  'STEP_NUMBER');

      l_gen_batch_id := WF_ENGINE.GetItemAttrNumber
                   (p_item_type,
                    p_item_key,
                   'GEN_BATCH_ID');

      Open  Get_Batches_C;
      Fetch Get_Batches_C into l_step_number, l_gen_batch_id;

      wf_engine.SetItemAttrNumber( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'GEN_BATCH_ID',
                                   avalue       => l_gen_batch_id );

      wf_engine.SetItemAttrNumber( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'STEP_NUMBER',
                                   avalue       => l_step_number );

      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Are_More_JE_Reverse: ' || 'Step Number = '||to_char(l_step_number)||
                           ' Gen Batch id = '||to_char(l_gen_batch_id));
      END IF;

      If  Get_Batches_C%NOTFOUND Then
         --no more batches to be reversed
         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('Are_More_JE_Reverse: ' || '*************************************');
         	diagn_debug_msg('Are_More_JE_Reverse: ' || 'Rollback: No more batches to reverse');
         	diagn_debug_msg('Are_More_JE_Reverse: ' || '*************************************');
         END IF;
         Close Get_Batches_C;
         exit;
      Else
         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('Are_More_JE_Reverse: ' || 'Rollback:get header id for batch '||to_char(l_gen_batch_id));
         END IF;
         Open  Get_Headers_C;
         Fetch Get_Headers_C Into f_je_header_id;
         Close Get_Headers_C;
         If f_je_header_id IS NOT NULL Then
            WF_ENGINE.SetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'JE_HEADER_ID'
                         ,f_je_header_id);
            IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
            	diagn_debug_msg('Are_More_JE_Reverse: ' || 'Rollback: Header '||to_char(f_je_header_id)||
                                   ' More Headers to reverse');
            END IF;
            Close Get_Batches_C;
            --set status to rollback reversal pending for this step
            Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RRP');

            p_result := 'COMPLETE:Y';
            return;
         Else
            IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
            	diagn_debug_msg('Are_More_JE_Reverse: ' || '*********************************************************');
            	diagn_debug_msg('Are_More_JE_Reverse: ' || '*ROLLBACK: All HEADERS ARE REVERSED FOR STEP '||
                               to_char(l_step_number)|| ' GEN BATCH '||to_char(l_gen_batch_id));
            	diagn_debug_msg('Are_More_JE_Reverse: ' || '*********************************************************');
            END IF;
            UPDATE GL_AUTO_ALLOC_BATCH_HISTORY
            Set ALL_HEADERS_REVERSED = 'Y'
            WHERE REQUEST_ID = to_number(p_item_key)
            And GENERATED_JE_BATCH_ID = l_gen_batch_id;
            diagn_debug_msg('Rollback:Rows updated = '||to_char(SQL%ROWCOUNT));
            Close Get_Batches_C;
             --set status to rollback reversal completed for this step
            Update_Status(to_number(p_item_key)
                         ,l_step_number
                         ,'RRC');

       End If;
     End if;
   End Loop;
 Else
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Are_More_JE_Reverse: ' || 'Reversal Completed');
     END IF;
 End If;

 -- set status to rollback reversal completed for all step where status is NOT
 -- Not started, Rollback Not Required, Rollback Completed
 Update_Status(to_number(p_item_key)
               ,-1
               ,'RRC');

 p_result := 'COMPLETE:N';
 return;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN NO_DATA_FOUND Then
     Null;
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Are_More_JE_Reverse', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Are_More_JE_Reverse: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RUFE'
                    );

    Raise;
End Are_More_JE_Reverse;

Procedure Is_Posting_Required(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result         OUT NOCOPY VARCHAR2) Is

l_reversal_je_header_id   NUMBER;


Cursor verify_rev_batch_C IS
Select R.REVERSAL_JE_HEADER_ID
From GL_JE_BATCHES JEB
    ,GL_AUTO_ALLOC_REV_BATCHES R
Where JEB.JE_BATCH_ID = R.REVERSAL_JE_BATCH_ID
AND   JEB.STATUS Not In ('P','I')
AND    R.PARENT_REQUEST_ID = to_number(p_item_key);

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started Is_Posting_Required');
   END IF;
   Open verify_rev_batch_C;
   Fetch verify_rev_batch_C into l_reversal_je_header_id;
   If verify_rev_batch_C%FOUND Then
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Posting_Required: ' || 'Rollback:Posting is required for reverse batch(es)');
     END IF;
     Close verify_rev_batch_C;
     --set status to rollback posting pending for all step for which
     -- where status is NOT Not started, Rollback Not Required, Rollback Completed

         Update_Status(to_number(p_item_key)
                    ,-1
                    ,'RPP');

     p_result := 'COMPLETE:Y';
     return;
   Else
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Posting_Required: ' || 'Rollback Completed: Posting not required ');
     END IF;
       --set status to rollback  completed for all step for which
       -- where status is NOT Not started, Rollback Not Required, Rollback Completed

         Update_Status(to_number(p_item_key)
                    ,-1
                    ,'RC');


     p_result := 'COMPLETE:N';
     Close verify_rev_batch_C;
     return;
   End If;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Is_Posting_Required', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Posting_Required: ' || err_msg ||'*'||err_stack);
     END IF;
    Raise;
End Is_Posting_Required ;


Procedure Is_Jrnl_Reversed(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result         OUT NOCOPY VARCHAR2) Is

l_je_header_id           Number;
l_step_number            Number;
l_rev_header_id          Number;
l_status                 Varchar2(1);
l_message_Name           Varchar2(150);


Cursor verify_reversal_C IS
 Select
 Accrual_rev_status
,Accrual_rev_je_header_id
From GL_JE_HEADERS
Where JE_HEADER_ID = l_je_header_id;

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started Is_Jrnl_Reversed');
   END IF;
    l_je_header_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'JE_HEADER_ID');
    l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');

    If l_je_header_id is Not Null Then
       open verify_reversal_C;
       fetch verify_reversal_C into l_status,l_rev_header_id;
       close verify_reversal_C;
       If l_status = 'R' then
         p_result := 'COMPLETE:Y';
         return;
       Else
         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('Is_Jrnl_Reversed: ' || 'Sending Notification. Journal not reversed');
         END IF;

         l_message_Name := 'GLALLOC:JRNL_NOT_REVERSED';
         wf_engine.SetItemAttrText(itemtype => p_item_type,
                                  itemkey   => p_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => l_message_Name );

         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('Is_Jrnl_Reversed: ' || 'Message_name = '||l_message_Name);
         END IF;
         --step status to Rollback Journal Not Reversed for this step
         Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RJNR');

         p_result := 'COMPLETE:N';
         return;
       End If;
   Else
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Jrnl_Reversed: ' || 'Je_Header_Id is null');
     END IF;
   End If;

ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Is_Jrnl_Reversed', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Jrnl_Reversed: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RUFE'
                    );

    Raise;
End Is_Jrnl_Reversed ;

Procedure Select_And_Validate_AllBatches(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode       IN VARCHAR2,
                         p_result         OUT NOCOPY VARCHAR2) Is

l_reversal_je_batch_id   NUMBER;
l_step_number            NUMBER;
l_batches_not_valid      VARCHAR2(32000) := NULL;
l_error_msg              Varchar2(2000);
l_result                 Varchar2(2);
l_message_Name           Varchar2(150);

Cursor get_all_rev_batches_C IS
Select
  GLAARV.REVERSAL_JE_BATCH_ID
 ,BH.step_Number
FROM GL_JE_BATCHES GLB
    ,GL_AUTO_ALLOC_BATCH_HISTORY BH
    ,GL_AUTO_ALLOC_REV_BATCHES GLAARV
Where GLB.JE_BATCH_ID = GLAARV.REVERSAL_JE_BATCH_ID
  AND GLAARV.JE_BATCH_ID = BH.GENERATED_JE_BATCH_ID
  AND GLB.STATUS NOT In ('P','I','S')
  AND BH.REQUEST_ID            = to_number(p_item_key)
  AND GLAARV.PARENT_REQUEST_ID = to_number(p_item_key);

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Rollback:Started Select_And_Validate_AllBatches');
   END IF;
   Open get_all_rev_batches_C;
   LOOP
     FETCH get_all_rev_batches_C into
     l_reversal_je_batch_id
     ,l_step_number;
     Exit WHEN get_all_rev_batches_C%NOTFOUND;
     If l_reversal_je_batch_id IS NOT NULL Then
         Is_JE_Valid_For_Posting
                     ( itemtype          => p_item_type
                      ,itemkey           => p_item_key
                      ,l_je_batch_id     => l_reversal_je_batch_id
                      ,l_invalid_error   => l_error_msg
                      ,result            => l_result
                    );
               If l_result = 'Y' Then
                  IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
                  	diagn_debug_msg('Select_And_Validate_AllBatches: ' || 'Rollback: '||to_char(l_reversal_je_batch_id)||
                                   ' Batch is valid for posting');
                  END IF;
               ElsIf l_result = 'P' Then
                  IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
                  	diagn_debug_msg('Select_And_Validate_AllBatches: ' || 'Rollback:Batch '||to_char(l_reversal_je_batch_id)||
                            ' is already posted');
                  END IF;
               Else
                  l_batches_not_valid := l_batches_not_valid ||'Batch_Id='||
                                         to_char(l_reversal_je_batch_id)||'*'||substrb(l_error_msg,1,80);
                   -- Rollback batch not postable
                     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RBNP');

               End If;
     End If;
   End Loop;
   If l_batches_not_valid IS NULL Then
      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Select_And_Validate_AllBatches: ' || '*************************************');
      	diagn_debug_msg('Select_And_Validate_AllBatches: ' || 'Rollback:All reverse batches valid for posting');
      	diagn_debug_msg('Select_And_Validate_AllBatches: ' || '*************************************');
      END IF;

     --set status to rollback posting pending for all step for which
     -- where status is NOT [Not started, Rollback Not Required, Rollback Completed]
       Update_Status(to_number(p_item_key)
                    ,-1
                    ,'RPP');
      p_result := 'COMPLETE:PASS';
      return;
   Else
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Select_And_Validate_AllBatches: ' || 'Rollback:Batches not valid for posting = '||l_batches_not_valid||
                     ' Sending Notification' );
     END IF;
      l_message_name := 'GLALLOC:JE_BATCHES_NOT_POSTABLE';
      wf_engine.SetItemAttrText(itemtype => p_item_type,
                                  itemkey   => p_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => l_message_Name );
         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('Select_And_Validate_AllBatches: ' || 'Message_name = '||l_message_Name);
         END IF;

      --max length for text variable in WF is 2000
      l_batches_not_valid := substrb(l_batches_not_valid,1,2000);
      wf_engine.SetItemAttrText(itemtype => p_item_type,
                                  itemkey   => p_item_key,
                                  aname     => 'ERROR_BATCHES',
                                  avalue    => l_batches_not_valid );
     p_result := 'COMPLETE:FAIL';
     return;
   End If;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Select_And_Validate_AllBatches', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Select_And_Validate_AllBatches: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RUFE'
                    );

    Raise;
End Select_And_Validate_AllBatches ;

Procedure Are_All_Batches_Posted(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result         OUT NOCOPY VARCHAR2) Is

l_status                Varchar2(1);
l_fail_flag             Varchar2(1) := 'N';
l_je_batch_id           Number;
l_fail_batches          Varchar2(2000);
l_step_number           Number;
l_message_Name          Varchar2(150);

Cursor check_JE_batch_status_C IS
  Select JEB.Status
  ,JEB.JE_Batch_Id
  ,BH.Step_Number
   From GL_JE_BATCHES JEB
     ,GL_AUTO_ALLOC_BATCH_HISTORY BH
     ,GL_AUTO_ALLOC_REV_BATCHES RB
  Where JEB.JE_BATCH_ID = RB.REVERSAL_JE_BATCH_ID
   And RB.JE_BATCH_ID   = BH.GENERATED_JE_BATCH_ID
   AND BH.REQUEST_ID        = to_number(p_item_key)
   And RB.PARENT_REQUEST_ID = to_number(p_item_key);

Begin
 If ( p_funcmode = 'RUN' ) THEN
    GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
    IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
    	diagn_debug_msg('Rollback:Started Are_All_Batches_Posted');
    END IF;
    open check_JE_batch_status_C;
    Loop
        fetch check_JE_batch_status_C into l_status,l_je_batch_id,l_step_number;
        Exit When check_JE_batch_status_C%NOTFOUND;
        If l_status In ('P') Then
            IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
            	diagn_debug_msg('Are_All_Batches_Posted: ' || 'Rollback:Batch '||to_char(l_je_batch_id)||' is posted successfully');
            END IF;
        Else
           IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
           	diagn_debug_msg('Are_All_Batches_Posted: ' || 'Rollback:Batch '||to_char(l_je_batch_id)||' posting failed ');
           END IF;
           l_fail_flag := 'Y';
           l_fail_batches := l_fail_batches ||'*'||to_char(l_je_batch_id);
          --here set status to Rollback Posting Failed for this step
          Update_status(
             to_number(p_item_key)
                    ,l_step_number
                    ,'RJBNP');

        End If;
    End Loop;

   If l_fail_flag = 'Y' Then
     -- some batches are not posted
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Are_All_Batches_Posted: ' || 'Rollback:Failed batches = '||l_fail_batches||' Sending Notification ');
       END IF;
       l_message_name := 'GLALLOC:GEN_BATCHES_NOT_POSTED';
       wf_engine.SetItemAttrText(itemtype => p_item_type,
                                  itemkey   => p_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => l_message_Name );
         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('Are_All_Batches_Posted: ' || 'Message_name = '||l_message_Name);
         END IF;

       p_result := 'COMPLETE:N';
       return;
   Else
      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Are_All_Batches_Posted: ' || '*************************************************************');
      	diagn_debug_msg('Are_All_Batches_Posted: ' || 'Rollback Completed: All reversed batches posted successfully');
      	diagn_debug_msg('Are_All_Batches_Posted: ' || '*************************************************************');
      END IF;
       -- set status to rollback completed for all step for which
       -- where status is NOT [Not started, Rollback Not Required, Rollback Completed]
      Update_Status(to_number(p_item_key)
                    ,-1
                    ,'RC');
      p_result := 'COMPLETE:Y';
      return;
  End If;

ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Are_All_Batches_Posted', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Are_All_Batches_Posted: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RUFE'
                    );

    Raise;
End Are_All_Batches_Posted ;


Procedure Is_Rollback_Allowed(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result         OUT NOCOPY VARCHAR2) Is

l_rollback_allowed       Varchar2(1);
l_message_Name           Varchar2(150);

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started Is_Rollback_Allowed');
   END IF;
   l_Rollback_Allowed := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'ROLLBACK_ALLOWED');

   If l_Rollback_Allowed = 'N' Then
       p_result := 'COMPLETE:N';
   Else
       p_result := 'COMPLETE:Y';
   End If;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Is_Rollback_Allowed: ' || 'rollback Allowed = '||l_Rollback_Allowed);
   END IF;
   return;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Is_Rollback_Allowed', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_Rollback_Allowed: ' || err_msg ||'*'||err_stack);
     END IF;
    Raise;
End Is_Rollback_Allowed ;

Procedure SUBMIT_MA_PROGRAM(p_item_type   IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode       IN VARCHAR2,
                         p_result         OUT NOCOPY VARCHAR2) Is

submit_request_id             NUMBER;
l_step_number                 NUMBER;
t_allocation_method_code      Varchar2(1);
l_allocation_method_code      Varchar2(1);
l_usage_code                  Varchar2(1);
l_access_set_id               Number;
l_ledger_id                   Number;
l_ledger_currency             Varchar2(15);
l_balancing_segment_value     Varchar2(25);
l_period_name                 Varchar2(15);
l_journal_effective_date      Date;
l_calc_effective_date         Date;
l_batch_id                    Number;
l_parent_req_id               Number := to_number(p_item_key);
l_usage_num                   Number;

Begin
If ( p_funcmode = 'RUN' ) THEN
    GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
    IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
    	diagn_debug_msg('Started SUBMIT_MA_PROGRAM');
    END IF;

   l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');

   l_usage_code := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'USAGE_CODE');

   If l_usage_code = 'Y' Then
      l_usage_num := 1;
   Else
      l_usage_num := 0;
   End if;

   t_allocation_method_code := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'ALLOCATION_METHOD_CODE');

   If t_allocation_method_code = 'I' Then
     l_allocation_method_code := 'Y' ;
   Else
     l_allocation_method_code := 'N';
   End If;

   l_access_set_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'ACCESS_SET_ID');

   l_ledger_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'LEDGER_ID');

   l_ledger_currency := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'LEDGER_CURRENCY');

   l_balancing_segment_value := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'BALANCING_SEGMENT_VALUE');

   l_batch_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'BATCH_ID');

   l_period_name := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'PERIOD_NAME');
   l_journal_effective_date :=  WF_ENGINE.GetItemAttrDate
                        (p_item_type,
                         p_item_key,
                         'JOURNAL_EFFECTIVE_DATE');
   l_calc_effective_date :=  WF_ENGINE.GetItemAttrDate
                        (p_item_type,
                         p_item_key,
                         'CALCULATION_EFFECTIVE_DATE');

    Submit_Request(  l_parent_req_id
                    ,l_step_number
                    ,'GLAMAS'
                    ,'C'
                    ,to_char(l_access_set_id)
                    ,l_allocation_method_code
                    ,to_char(l_usage_num)
                    ,to_char(l_ledger_id)
                    ,l_ledger_currency
                    ,l_balancing_segment_value
                    ,to_char(l_batch_id)
                    ,l_period_name
                    ,to_char(l_journal_effective_date,'YYYY/MM/DD HH24:MI:SS')
                    ,to_char(l_calc_effective_date,'YYYY/MM/DD HH24:MI:SS')
                    ,chr(0)
                    ,submit_request_id);

    If submit_request_id = 0  Then
       p_result := 'COMPLETE:FAIL';
    Else
       --Generation pending status
       Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'GP'
                    );
       p_result := 'COMPLETE:PASS';
    End If;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;

EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'SUBMIT_MA_PROGRAM', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('SUBMIT_MA_PROGRAM: ' || err_msg ||'*'||err_stack);
     END IF;
     -- set status code to unexpected fatal error
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );
    Raise;
End SUBMIT_MA_PROGRAM ;


Procedure SUBMIT_POSTING_PROGRAM(p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result         OUT NOCOPY VARCHAR2) Is

submit_request_id       NUMBER;
l_operating_mode        Varchar2(1);
l_coa_id                Number;
l_posting_run_id        Number;
l_parent_req_id         Number := to_number(p_item_key);
l_step_number           Number;
l_gen_batch_id          Number;
l_batch_request_id	Number;
l_access_set_id         Number;
l_post_flag           VARCHAR2(1) := 'Y';

CURSOR get_request_id_c IS
          SELECT jb.request_id,bh.generated_je_batch_id
          FROM GL_JE_BATCHES jb,
               GL_AUTO_ALLOC_BATCH_HISTORY bh
          WHERE bh.request_id = to_number(p_item_key)
          AND   bh.step_number = l_step_number
          AND   jb.je_batch_id = bh.generated_je_batch_id;

Begin
If ( p_funcmode = 'RUN' ) THEN
    GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
    IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
    	diagn_debug_msg('Started SUBMIT_POSTING_PROGRAM');
    END IF;

    l_operating_mode := wf_engine.GetItemAttrText
                           ( itemtype        => p_item_type,
                             itemkey         => p_item_key,
                             aname           => 'OPERATING_MODE');

    l_coa_id :=  WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'CHART_OF_ACCOUNTS_ID');

   l_access_set_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'ACCESS_SET_ID');

   If l_operating_mode = 'R' then
       l_step_number := -1;
   Else
       l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');
   End If;

   -- Bug fix 1887834
   -- Before submit the batch for posting, check and see if it has
   -- already been submitted before.  This check will be performed
   -- on all operating_mode except R.
   -- If the batch has been submitted for posting before, just put
   -- the request_id into the workflow process and not submit
   -- another posting run here.
   IF (l_operating_mode <> 'R') THEN
     OPEN  get_request_id_c;
     LOOP
       FETCH get_request_id_c into l_batch_request_id,l_gen_batch_id;
       EXIT WHEN get_request_id_C%NOTFOUND;

       IF(l_batch_request_id IS NOT NULL) THEN
         -- put request_id into workflow process, then return.
         -- in this way, the deferred thread will late pick this
         -- up and check for the posting status.
         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('SUBMIT_POSTING_PROGRAM: ' || 'Inserting req id = '||to_char(l_batch_request_id)||
                            ' into histroy detail');
         END IF;

         wf_engine.SetItemAttrText(
                    itemtype  => p_item_type,
                    itemkey   => p_item_key,
                    aname     => 'CONC_PRG_CODE',
                    avalue    => 'GLPPOS');

         wf_engine.SetItemAttrNumber( itemtype     => p_item_type,
                                      itemkey      => p_item_key,
                                      aname        => 'CONC_REQUEST_ID',
                                      avalue       => l_batch_request_id );

         INSERT_BATCH_HIST_DET(
                  p_REQUEST_ID        => l_batch_request_id
                 ,p_PARENT_REQUEST_ID => l_parent_req_id
                 ,p_STEP_NUMBER       => l_step_number
                 ,p_PROGRAM_NAME_CODE => 'GLPPOS'
                 ,p_RUN_MODE          => l_operating_mode);
       ELSE
          l_post_flag := 'N';
       END IF;
     END LOOP;

     CLOSE get_request_id_c;

     IF l_post_flag = 'Y' THEN
        return;
     END IF;

   END IF;

   l_posting_run_id := gl_je_batches_post_pkg.get_unique_id;

   Submit_Request( l_parent_req_id
                    ,l_step_number
                    ,'GLPPOS'
                    , to_char(-99)
                    , to_char(l_access_set_id)
                    , to_char(l_coa_id)
                    , To_Char(l_posting_run_id)
                    , chr(0)
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , submit_request_id);

   If submit_request_id = 0  Then
      p_result := 'COMPLETE:FAIL';
   Else
      If l_operating_mode = 'R' Then
               Update GL_JE_BATCHES
               Set Posting_Run_Id = l_posting_run_id
                ,Status = 'S'
                Where JE_BATCH_ID in ( Select GLAARV.REVERSAL_JE_BATCH_ID
                                  From GL_JE_BATCHES GLB
                                      ,GL_AUTO_ALLOC_REV_BATCHES GLAARV
                                  Where GLB.JE_BATCH_ID = GLAARV.REVERSAL_JE_BATCH_ID
                                  AND GLB.STATUS NOT In ('P','I','S')
                                  AND GLAARV.PARENT_REQUEST_ID = to_number(p_item_key) );

                 --set status to rollback posting pending for all step for which
                 -- where status is NOT
                 --[Not started, Rollback Not Required, Rollback Completed]

                 Update_Status(to_number(p_item_key)
                       ,-1
                        ,'RPP'
                       );
      Else
                Update GL_JE_BATCHES
                Set Posting_Run_Id = l_posting_run_id,
                    Status = 'S'
                Where JE_BATCH_ID IN
                        ( SELECT bh.generated_je_batch_id
                          FROM GL_AUTO_ALLOC_BATCH_HISTORY bh,
                               GL_JE_BATCHES jb
                          WHERE bh.request_id = to_number(p_item_key)
                          AND   bh.step_number = l_step_number
                          AND   jb.je_batch_id = bh.generated_je_batch_id
                          AND   jb.status NOT IN ('P','I','S')

                         );

                --Posting Pending
               Update_Status(to_number(p_item_key)
                       ,l_step_number
                       ,'PP'
                       );
      End If;
      p_result := 'COMPLETE:PASS';

   End If ; /* submit_request_id <> 0 */
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'SUBMIT_POSTING_PROGRAM', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('SUBMIT_POSTING_PROGRAM: ' || err_msg ||'*'||err_stack);
     END IF;
        Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );
    Raise;
End SUBMIT_POSTING_PROGRAM ;

PROCEDURE Is_je_valid_for_posting(itemtype  IN VARCHAR2,
                      itemkey   IN VARCHAR2,
                      l_je_batch_id   IN Number,
                      l_invalid_error OUT NOCOPY VARCHAR2,
                      result    OUT NOCOPY VARCHAR2 ) IS

l_gen_batch_id                   NUMBER;
l_batch_name                    VARCHAR2(100);
l_untaxed_cursor                VARCHAR2(20);
l_balance_type                  VARCHAR2(1);
l_automatic_tax_flag            VARCHAR2(1);
l_budgetary_status              VARCHAR2(1);
l_control_total                 NUMBER;
l_running_total_dr              NUMBER;
l_running_total_cr              NUMBER;
l_ledger_id               NUMBER;
l_period_name                    VARCHAR2(15);
l_period_status                 VARCHAR2(1);
l_start_date                    DATE;
l_end_date                      DATE;
l_period_num                    NUMBER;
l_period_year                   NUMBER;
l_latest_encumbrance_year       NUMBER;
l_budget_version_id             NUMBER;
l_status                        VARCHAR2(1);
l_operating_mode                VARCHAR2(1);
l_approval_status_code          VARCHAR2(1);
c_je_batch_id                   VARCHAR2(240) := to_char(l_je_batch_id);

CURSOR check_untaxed IS
          SELECT 'untaxed journals'
          FROM DUAL
          WHERE EXISTS
              (SELECT 'UNTAXED'
               FROM   GL_JE_HEADERS JEH,
                      GL_LEDGERS LGR
               WHERE  JEH.je_batch_id = l_je_batch_id
               AND    JEH.tax_status_code = 'R'
               AND    JEH.currency_code <> 'STAT'
               AND    JEH.je_source = 'Manual'
               AND    LGR.ledger_id = JEH.ledger_id
               AND    LGR.ledger_category_code <> 'NONE'
               AND    LGR.enable_automatic_tax_flag = 'Y');

Cursor get_je_batch_attributes_C IS
Select
  NAME
 ,CONTROL_TOTAL
 ,RUNNING_TOTAL_DR
 ,RUNNING_TOTAL_CR
 ,DEFAULT_PERIOD_NAME
 ,ACTUAL_FLAG
 ,BUDGETARY_CONTROL_STATUS
 ,STATUS
 ,APPROVAL_STATUS_CODE
From GL_JE_BATCHES
Where JE_BATCH_ID = l_je_batch_id;


CURSOR get_je_header_attributes_C IS
SELECT
jh.LEDGER_ID,
jh.BUDGET_VERSION_ID,
lgr.LATEST_ENCUMBRANCE_YEAR
FROM GL_JE_HEADERS jh, GL_LEDGERS lgr
WHERE jh.JE_BATCH_ID = l_je_batch_id
AND   lgr.LEDGER_ID = jh.LEDGER_ID
AND   lgr.LEDGER_CATEGORY_CODE <> 'NONE';

Begin

    Open  get_je_batch_attributes_C;
    Fetch get_je_batch_attributes_C into
     l_batch_name
    ,l_control_total
    ,l_running_total_dr
    ,l_running_total_cr
    ,l_period_name
    ,l_balance_type
    ,l_budgetary_status
    ,l_status
    ,l_approval_status_code;

     If get_je_batch_attributes_C%NOTFOUND Then
       Close get_je_batch_attributes_C;
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Is_je_valid_for_posting: ' || 'Generated JE batch not found '||c_je_batch_id);
       END IF;
       FND_MESSAGE.Set_Name('SQLGL', 'GL_JE_BATCH_NOT_FOUND');
       FND_MESSAGE.Set_Token('BATCH',l_batch_name);
       l_invalid_error := FND_MESSAGE.Get;
       result := 'N';
       return;
     Elsif l_approval_status_code = 'R'  Then
        l_operating_mode := wf_engine.GetItemAttrText
                           ( itemtype        => p_item_type,
                             itemkey         => p_item_key,
                             aname           => 'OPERATING_MODE');
        If l_operating_mode = 'R' Then
          --during rollback, we don't require approval
          Update GL_JE_BATCHES
          Set approval_status_code = 'Z'
          Where je_batch_id = l_je_batch_id;

          result := 'Y';
       Else
          IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
          	diagn_debug_msg('Is_je_valid_for_posting: ' || 'Batch  approval require before posting');
          END IF;
          FND_MESSAGE.Set_Name('SQLGL', 'GL_JE_BATCH_APPROVAL_REQ');
          FND_MESSAGE.Set_Token('BATCH',l_batch_name);
          l_invalid_error := FND_MESSAGE.Get;
          result := 'N';
          return;
       End If;
     Elsif l_approval_status_code = 'I'  Then
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Is_je_valid_for_posting: ' || 'Batch '||To_char(l_je_batch_id)||
                       ' approval launched but batch is not yet approved');
       END IF;
       FND_MESSAGE.Set_Name('SQLGL', 'GL_APPROVAL_NOT_COMPLETE');
       FND_MESSAGE.Set_Token('BATCH',l_batch_name);
       l_invalid_error := FND_MESSAGE.Get;
       result := 'N';
       return;
     ElsIf l_status = 'P' then
        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('Is_je_valid_for_posting: ' || 'Batch already posted '||to_char(l_je_batch_id));
        END IF;
        result := 'P';
        return;
     ElsIf l_budgetary_status = 'I' then
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Is_je_valid_for_posting: ' || 'Batch '||To_char(l_je_batch_id)||
                       ' fund checker is in process');
       END IF;
       FND_MESSAGE.Set_Name('SQLGL', 'GL_FUND_CHECK_IN_PROCESS');
       FND_MESSAGE.Set_Token('BATCH',l_batch_name);
       l_invalid_error := FND_MESSAGE.Get;
       result := 'N';
       return;
     End If;

     -- Check whether the batch contains untaxed journals or unreserved
     -- funds.
    IF l_balance_type = 'A' THEN
      OPEN check_untaxed ;
      FETCH check_untaxed INTO l_untaxed_cursor;

      IF check_untaxed%FOUND THEN
        CLOSE check_untaxed;
        FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_INVALID_UNTAXED');
        l_invalid_error := FND_MESSAGE.Get;
         result := 'N';
         return;
     ELSE
        CLOSE check_untaxed;
      END IF;
    END IF;


    -- Check for the postability of the batch
    OPEN get_je_header_attributes_C;
    LOOP
      FETCH get_je_header_attributes_C into l_ledger_id, l_budget_version_id, l_latest_encumbrance_year;
      EXIT when get_je_header_attributes_C%NOTFOUND;

      -- Get the period year
      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Is_je_valid_for_posting: ' || 'Ledger = '||to_char(l_ledger_id)||' Period = '||l_period_name );
      END IF;
      GL_PERIOD_STATUSES_PKG.select_columns(
            101,
            l_ledger_id,
            l_period_name,
            l_period_status,
            l_start_date,
            l_end_date,
            l_period_num,
            l_period_year);

      IF ( l_balance_type = 'A') THEN
        -- Check that the batch period is open for actual batches
        BEGIN
          IF (nvl(l_period_status,'X') NOT IN ('O', 'F')) THEN
            FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_INVALID_PERIOD_NOT_OPEN');
            l_invalid_error := FND_MESSAGE.Get;
            result := 'N';
            return;
          END IF;
        END;

      ELSIF (l_balance_type = 'B') THEN
        -- Check that the budget is valid, budget year is open and
        -- the period is within the valid range of periods.
        DECLARE
          CURSOR chk_budgets IS
            SELECT max(decode(bud.status, 'I', 1, 'F', 1, 0)),
                   max(l_period_year - bud.latest_opened_year)
            FROM   GL_BUDGET_VERSIONS BV,
                   GL_BUDGETS BUD
            WHERE  BV.budget_version_id = l_budget_version_id
            AND    BUD.budget_type = BV.budget_type
            AND    BUD.budget_name = BV.budget_name;

            frozen_budget    NUMBER;
            year_violation   NUMBER;
        BEGIN
          OPEN chk_budgets;
          FETCH chk_budgets INTO frozen_budget,
                                 year_violation;
          CLOSE chk_budgets;

          IF (frozen_budget = 1) THEN
            FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_INVALID_FROZEN_BUDGET');
            l_invalid_error := FND_MESSAGE.Get;
            result := 'N';
            return;
          ELSIF (year_violation = 1) THEN
            FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_INVALID_BUDGET_PERIOD');
            l_invalid_error := FND_MESSAGE.Get;
            result := 'N';
            return;
          END IF;
        END ;

      ELSE
        -- Make sure that for encumbrance batches, the
        -- batch is within an open encumbrance year
        IF (l_period_year > l_latest_encumbrance_year) THEN
          FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_INVALID_ENC_YEAR');
          l_invalid_error := FND_MESSAGE.Get;
          result := 'N';
          return;
        END IF;

      END IF;

    END LOOP;
    CLOSE get_je_header_attributes_C;

    -- Make sure the control total matches the
    -- running totals
    IF (   (l_control_total IS NULL)
        OR ( (l_balance_type IN ('A', 'E'))
              AND (l_running_total_dr = l_control_total))
        OR ( (l_balance_type = 'B')
              AND (greatest(l_running_total_cr, l_running_total_dr)
                     = l_control_total))

     ) THEN
        null;
    ELSE
      FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_INVALID_CONTROL_TOTAL');
      l_invalid_error := FND_MESSAGE.Get;
      result := 'N';
      return;
    END IF;

    -- If the batch passes all the above checks, then its valid.
    result := 'Y';

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_WF_JE_APPROVAL_PKG', 'is_je_valid_for_posting', itemtype, itemkey);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Is_je_valid_for_posting: ' || err_msg ||'*'||err_stack);
     END IF;
    Raise;
END is_je_valid_for_posting;


Procedure SUBMIT_RJE_PROGRAM(p_item_type  IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode       IN VARCHAR2,
                         p_result         OUT NOCOPY VARCHAR2) Is

submit_request_id             NUMBER;
l_usage_code                  Varchar2(1);
l_access_set_id               Number;
l_batch_id                    Number;
l_step_number                 Number;
l_period_name                 Varchar2(15);
l_journal_effective_date      Date;
l_calc_effective_date         Date;
l_budget_version_id           Number;
l_parent_req_id               Number := to_number(p_item_key);
Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started SUBMIT_RJE_PROGRAM');
   END IF;

    l_usage_code := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'USAGE_CODE');
   l_access_set_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'ACCESS_SET_ID');
   l_batch_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'BATCH_ID');
   l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                        'STEP_NUMBER');
  l_period_name := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'PERIOD_NAME');
  l_journal_effective_date :=  WF_ENGINE.GetItemAttrDate
                        (p_item_type,
                         p_item_key,
                         'JOURNAL_EFFECTIVE_DATE');
  l_calc_effective_date :=  WF_ENGINE.GetItemAttrDate
                        (p_item_type,
                         p_item_key,
                         'CALCULATION_EFFECTIVE_DATE');

  l_budget_version_id := wf_engine.getItemAttrNumber
                          ( p_item_type,
                            p_item_key,
                            'BUDGET_VERSION_ID');
     Submit_Request( l_parent_req_id
                    ,l_step_number
                    , 'GLPRJE'
                    , to_char(l_batch_id)
                    , l_period_name
                    , to_char(l_access_set_id)
                    , to_char(l_budget_version_id)
                    , to_char(l_calc_effective_date,'YYYY/MM/DD')
                    , to_char(l_journal_effective_date,'YYYY/MM/DD')
                    , l_usage_code
                    , chr(0)
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , submit_request_id);

   If submit_request_id = 0  Then
       p_result := 'COMPLETE:FAIL';
       Return;
   Else
       --Generation pending status
       Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'GP'
                    );
       p_result := 'COMPLETE:PASS';
       Return;
   End If;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'SUBMIT_RJE_PROGRAM', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('SUBMIT_RJE_PROGRAM: ' || err_msg ||'*'||err_stack);
     END IF;
    -- set status code to unexpected fatal error
    Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );

    Raise;
End SUBMIT_RJE_PROGRAM ;

Procedure SUBMIT_REV_PROGRAM(p_item_type  IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode       IN VARCHAR2,
                         p_result         OUT NOCOPY VARCHAR2) Is

submit_request_id        NUMBER;
l_step_number            Number;
reversal_req_id          Number;
l_je_header_id           Number;
l_access_set_id          Number;
l_period_name            Varchar2(15);
l_parent_req_id          Number := to_number(p_item_key);
Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started SUBMIT_REV_PROGRAM');
   END IF;

   l_access_set_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                        'ACCESS_SET_ID');

   l_je_header_id := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'JE_HEADER_ID');
   l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');

     Submit_Request( l_parent_req_id
                    ,l_step_number
                    ,'GLPREV'
                    , to_char(l_access_set_id)
                    , to_char(l_je_header_id)
                    , chr(0)
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , submit_request_id);

    If submit_request_id = 0  Then
       p_result := 'COMPLETE:FAIL';
       Return;
    Else
       l_period_name := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'PERIOD_NAME');

        IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
        	diagn_debug_msg('SUBMIT_REV_PROGRAM: ' || 'Updating accrual_rev_period_name = '||l_period_name);
        END IF;

        Update GL_JE_HEADERS
        Set accrual_rev_flag = 'Y'
          , accrual_rev_period_name = l_period_name
          , accrual_rev_effective_date = decode(actual_flag,'A',
                            default_effective_date,accrual_rev_effective_date)
         Where je_header_id = l_je_header_id;

        --Rollback reversal pending status for this step
        Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RRP'
                    );
      p_result := 'COMPLETE:PASS';
      Return;
   End If;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'SUBMIT_REV_PROGRAM', p_item_type, p_item_key);
    Wf_Core.Get_Error(err_name,err_msg,err_stack);
    IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
    	diagn_debug_msg('SUBMIT_REV_PROGRAM: ' || err_msg ||'*'||err_stack);
    END IF;
    -- set status code to unexpected fatal error
    Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RUFE'
                    );
    Raise;
End SUBMIT_REV_PROGRAM ;

Procedure WAITING_TO_COMPLETE(p_item_type      IN VARCHAR2,
                         p_item_key        IN VARCHAR2,
                         p_actid           IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result          OUT NOCOPY VARCHAR2) Is

l_request_id             Number;
p_phase                  Varchar2(80);
p_status                 Varchar2(80);
p_dev_phase              Varchar2(80);
p_dev_status             Varchar2(80);
p_message                Varchar2(240) ;
l_call_status            Boolean;
l_step_number            Number;
l_conc_prg_code          Varchar2(15);
l_status_code            Varchar2(15);
l_rollback_allowed       Varchar2(1);
l_message_Name           Varchar2(150);

l_user_id                Number;
l_org_id                 Number;
l_resp_id                Number;
l_resp_appl_id           Number;

l_profile_value          Number;

l_userenv_lang           VARCHAR2(50);
l_client_info            Varchar2(240);
l_wait_error             Varchar2(240);

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started WAITING_TO_COMPLETE');
   END IF;

    l_request_id :=  WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'CONC_REQUEST_ID');
   l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');

   l_conc_prg_code := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'CONC_PRG_CODE');
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('WAITING_TO_COMPLETE: ' || 'l_conc_prg_code = '||l_conc_prg_code);
   END IF;
   l_rollback_allowed := WF_ENGINE.GetItemAttrText(
                           p_item_type,
                           p_item_key,
                           'ROLLBACK_ALLOWED');

  l_user_id   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'USER_ID');

  l_org_id   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'ORG_ID');

  l_resp_id   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'RESP_ID');

  l_resp_appl_id   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'RESP_APPL_ID');

    select userenv('LANG') into l_userenv_lang from dual;
    IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
    	diagn_debug_msg('WAITING_TO_COMPLETE: ' || 'LANG='||l_userenv_lang);
    END IF;
    select userenv('CLIENT_INFO') into l_client_info from dual;
    IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
    	diagn_debug_msg('WAITING_TO_COMPLETE: ' || 'CLINT_INFO='||l_client_info);
    END IF;

    FND_PROFILE.put('ORG_ID', l_org_id);
    FND_PROFILE.put('USER_ID', l_user_id );
    FND_PROFILE.put('RESP_ID', l_resp_id);
    FND_PROFILE.put('RESP_APPL_ID', l_resp_appl_id);

    FND_PROFILE.get('STEP_DOWN_INTERVAL',l_profile_value);

    IF (l_profile_value is NULL) THEN
        l_profile_value := 30;
    END IF;

      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('WAITING_TO_COMPLETE: ' || 'Con Request Id = '||to_char(l_request_id));
      END IF;
      l_call_status :=
              Fnd_Concurrent.Wait_For_Request(
                  request_id   => l_request_id
                 ,Interval     => l_profile_value
                 ,Max_wait     => 360000
                 ,phase        => p_phase
                 ,status       => p_status
                 ,dev_phase    => p_dev_phase
                 ,dev_status   => p_dev_status
                 ,message      => p_message );
       If p_dev_phase = 'COMPLETE' AND
           p_dev_status In ('NORMAL','WARNING' ) Then
           IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
           	diagn_debug_msg('WAITING_TO_COMPLETE: ' || 'Completed concurrent program = '||to_char(l_request_id) );
           END IF;

           -- set status code program completed
            Get_Status_and_Message(l_conc_prg_code
                           ,'COMPLETE'
                           ,l_rollback_allowed
                           ,l_status_code
                           ,l_message_name);

            Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,l_status_code
                    );

           p_result := 'COMPLETE:PASS';
           return;
      Else
         If  NOT  (l_call_status ) Then
             l_wait_error := fnd_message.get;
             IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
             	diagn_debug_msg('WAITING_TO_COMPLETE: ' || 'Wait failure message='||l_wait_error);
             END IF;
         End If;
         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('WAITING_TO_COMPLETE: ' || 'Sending Notification. Concurrent program not completed  = '||
                           to_char(l_request_id) );
         	diagn_debug_msg('WAITING_TO_COMPLETE: ' || 'message='||p_message||'Dev_Phase = '
                         ||p_dev_phase||' Dev_Status ='||p_dev_status);
         	diagn_debug_msg('WAITING_TO_COMPLETE: ' || 'Phase = '||p_phase||' Status ='||p_status);
         END IF;
          Get_Status_and_Message(l_conc_prg_code
                           ,'ERROR'
                           ,l_rollback_allowed
                           ,l_status_code
                           ,l_message_name);

          -- Program Error
          Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,l_status_code
                    );

         wf_engine.SetItemAttrText(itemtype => p_item_type,
                                  itemkey   => p_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => l_message_name );

         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('WAITING_TO_COMPLETE: ' || 'Message_name = '||l_message_Name);
         END IF;

         p_result := 'COMPLETE:FAIL';
         return;
     End If;
 ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  When Others Then
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'WAITING_TO_COMPLETE', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('WAITING_TO_COMPLETE: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );

    Raise;

End WAITING_TO_COMPLETE ;

Procedure VAL_SET_FOR_ROLLBACK(p_item_type  IN VARCHAR2,
                         p_item_key         IN VARCHAR2,
                         p_actid            IN NUMBER,
                         p_funcmode         IN VARCHAR2,
                         p_result           OUT NOCOPY VARCHAR2) Is

l_step_number            Number;
l_batch_id               Number;
l_batch_type_code        Varchar2(1);
l_gen_Batch_Id           Number;
l_complete_flag          Varchar2(1);
no_rows                  Varchar2(1) := 'Y';
l_status                 Varchar2(1);
gen_but_not_posted       BOOLEAN  := FALSE;
l_gen_batch_name         Varchar2(100);

Cursor Validate_Steps_C IS
Select
 H.Step_Number
,H.Batch_Id
,H.BATCH_TYPE_CODE
,H.GENERATED_JE_BATCH_ID
,H.COMPLETE_FLAG
,JEB.Status
From GL_JE_BATCHES JEB
    ,GL_AUTO_ALLOC_BATCH_HISTORY H
Where
 JEB.JE_BATCH_ID = H.GENERATED_JE_BATCH_ID
AND H.REQUEST_ID = to_number(p_item_key)
Order By H.STEP_NUMBER Desc;

Cursor Set_Rollback_Context_C IS
Select
 H.Step_Number
,H.Batch_Id
,H.BATCH_TYPE_CODE
,H.GENERATED_JE_BATCH_ID
,JEB.Name
From GL_JE_BATCHES JEB
    ,GL_AUTO_ALLOC_BATCH_HISTORY H
Where JEB.JE_BATCH_ID = H.GENERATED_JE_BATCH_ID
AND H.REQUEST_ID = to_number(p_item_key)
AND H.COMPLETE_FLAG = 'Y'
Order By H.STEP_NUMBER Desc;

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('***************************************');
   	diagn_debug_msg('Rollback Started VAL_SET_FOR_ROLLBACK');
   	diagn_debug_msg('***************************************');
   END IF;
   wf_engine.SetItemAttrText( itemtype        => p_item_type,
                               itemkey         => p_item_key,
                               aname           => 'OPERATING_MODE',
                               avalue          => 'R');
   Open Validate_Steps_C;
   LOOP
      Fetch Validate_Steps_C Into
        l_step_number
        ,l_batch_id
        ,l_batch_type_code
        ,l_gen_batch_Id
        ,l_complete_flag
        ,l_status;

       If Validate_Steps_C%NOTFOUND Then
          If No_Rows = 'Y' Then
             IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
             	diagn_debug_msg('VAL_SET_FOR_ROLLBACK: ' || 'No batch is generated. Rollback is not necessary');
             END IF;
          End If;
          Close Validate_Steps_C;
          Exit;
       Else
            No_Rows := 'N';
            If l_status = 'P' Then
                 IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
                 	diagn_debug_msg('VAL_SET_FOR_ROLLBACK: ' || 'Batch was posted');
                 END IF;
                 If l_complete_flag <> 'Y' OR
                    l_complete_flag IS NULL Then
                    --shouldn't happen but still not a fatal error
                     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
                     	diagn_debug_msg('VAL_SET_FOR_ROLLBACK: ' || 'Batch is posted.Complete flag=N .Marking step as completed');
                     END IF;
                     Update GL_AUTO_ALLOC_BATCH_HISTORY
                     Set COMPLETE_FLAG = 'Y'
                     Where REQUEST_ID = to_number(p_item_key)
                     And   STEP_NUMBER = l_step_number;
                     --And BATCH_ID     = l_batch_id
                     --And BATCH_TYPE_CODE = l_batch_type_code;
                 End IF;
           Else
            If NOT gen_but_not_posted Then
               IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
               	diagn_debug_msg('VAL_SET_FOR_ROLLBACK: ' || 'Found first batch generated but not posted');
               END IF;
               gen_but_not_posted := TRUE;
            Else
              IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
              	diagn_debug_msg('VAL_SET_FOR_ROLLBACK: ' || ' More then one step is generated but not posted');
              END IF;
            End If;
          End If; /*l_Status*/
    End IF; /*Validate_Steps_C*/
  End LOOP;

     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('VAL_SET_FOR_ROLLBACK: ' || 'Verified all steps.');
     END IF;
     Open Set_Rollback_Context_C;
     Fetch Set_Rollback_Context_C into
       l_step_number
      ,l_batch_id
      ,l_batch_type_code
      ,l_gen_batch_id
      ,l_gen_batch_name;

       If Set_Rollback_Context_C%NOTFOUND Then
          l_batch_id := NULL;
          l_batch_type_code := NULL;
          l_gen_batch_id := NULL;
          l_gen_batch_name := NULL;
          IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
          	diagn_debug_msg('VAL_SET_FOR_ROLLBACK: ' || 'No step for reversal');
          END IF;
       End If;

      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('VAL_SET_FOR_ROLLBACK: ' || 'Setting up context now');
      END IF;
       wf_engine.SetItemAttrNumber(
             itemtype => p_item_type,
             itemkey  => p_item_key,
             aname    =>  'BATCH_ID',
             avalue   => l_batch_id );

       wf_engine.SetItemAttrtext(
             itemtype => p_item_type,
             itemkey  => p_item_key,
              aname   => 'BATCH_TYPE_CODE',
             avalue   => l_batch_type_code );

       wf_engine.SetItemAttrNumber(
             itemtype => p_item_type,
             ITEMkey  => p_item_key,
             aname    => 'STEP_NUMBER',
             avalue   => l_step_number );

       wf_engine.SetItemAttrNumber(
             itemtype => p_item_type,
             itemkey  => p_item_key,
             aname    =>  'GEN_BATCH_ID',
             avalue   => l_gen_batch_id );

       wf_engine.SetItemAttrtext(
             itemtype => p_item_type,
             itemkey  => p_item_key,
              aname   => 'GEN_BATCH_NAME',
             avalue   => l_gen_batch_name );

    Close Set_Rollback_Context_C;
    IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
    	diagn_debug_msg('VAL_SET_FOR_ROLLBACK: ' || 'Rollback: Set is validated for rollback');
    	diagn_debug_msg('VAL_SET_FOR_ROLLBACK: ' || 'Rollback Context: Step = '||To_char(l_step_number)||
                     ' Batch_id = '||To_char(l_batch_id)||
                     ' Gen_Batch_Id = '||To_char(l_Gen_Batch_Id));
    END IF;

   Return;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'VAL_SET_FOR_ROLLBACK', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('VAL_SET_FOR_ROLLBACK: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RUFE'
                    );

    Raise;
End VAL_SET_FOR_ROLLBACK ;

Procedure End_Fail(p_item_type      IN VARCHAR2,
                   p_item_key       IN VARCHAR2,
                   p_actid          IN NUMBER,
                   p_funcmode       IN VARCHAR2,
                   p_result         OUT NOCOPY VARCHAR2) Is

l_step_number        Number;
l_operating_mode     Varchar2(1);

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Entering end_fail');
   END IF;
   l_operating_mode := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'OPERATING_MODE');
   l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'STEP_NUMBER');

    If l_operating_mode = 'R' Then
        Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'RST'
                    );
   Else
        Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'ST'
                    );
   End If;

   Return;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'END_FAIL', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('End_Fail: ' || err_msg ||'*'||err_stack);
     END IF;
    Raise;
End End_Fail ;

procedure Selector_Func (p_item_type      IN VARCHAR2,
                         p_item_key       IN VARCHAR2,
                         p_actid          IN NUMBER,
                         p_funcmode        IN VARCHAR2,
                         p_result         OUT NOCOPY VARCHAR2)  IS
Begin
If ( p_funcmode = 'RUN' ) THEN
    NULL;
ElsIf ( p_funcmode = 'SET_CTX') Then
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Entering Selector_Func');
   END IF;
--   If diagn_debug_msg_flag Then
--     DBMS_SESSION.SET_SQL_TRACE(TRUE);
--   End If;
End If;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'SELECTOR_FUNC', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Selector_Func: ' || err_msg ||'*'||err_stack);
     END IF;
    Raise;
End Selector_Func ;



Procedure INSERT_BATCH_HIST_DET(
           p_request_id        IN NUMBER
          ,p_parent_request_id IN NUMBER
          ,p_step_number       IN NUMBER
          ,p_program_name_code IN VARCHAR2
          ,p_run_mode          IN VARCHAR2
          ,p_allocation_type   IN VARCHAR2 DEFAULT 'GL'
	  ,p_created_by        IN NUMBER DEFAULT   -1
          ,p_last_updated_by   IN NUMBER DEFAULT   -1
          ,p_last_update_login IN NUMBER DEFAULT   -1
          ) IS

 l_CREATED_BY        NUMBER;
 l_LAST_UPDATED_BY   NUMBER;
 l_LAST_UPDATE_LOGIN NUMBER;

 f_step_number       NUMBER;

 Cursor get_steps_C IS
 Select step_number
 From GL_AUTO_ALLOC_BATCH_HISTORY
 WHERE request_Id = p_PARENT_REQUEST_ID
 AND Status_Code Not In ( 'NS','RNR','RC');

Begin
  If p_allocation_type = 'GL' Then
      get_standard_who(l_CREATED_BY
                     ,l_LAST_UPDATED_BY
                     ,l_LAST_UPDATE_LOGIN
                     );
  Else
     l_created_by        := p_created_by;
     l_last_updated_by   := p_last_updated_by;
     l_last_update_login := p_last_update_login ;
  End If;

If p_STEP_NUMBER <> -1 AND p_STEP_NUMBER IS NOT NULL Then
     Insert Into GL_AUTO_ALLOC_BAT_HIST_DET
          (REQUEST_ID
           ,PARENT_REQUEST_ID
           ,STEP_NUMBER
           ,PROGRAM_NAME_CODE
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
           ,CREATION_DATE
           ,CREATED_BY
           ,STATUS_CODE
           ,RUN_MODE
          )
          Values
          (p_REQUEST_ID
          ,p_PARENT_REQUEST_ID
          ,p_STEP_NUMBER
          ,p_PROGRAM_NAME_CODE
          ,sysdate
          ,l_LAST_UPDATED_BY
          ,l_LAST_UPDATE_LOGIN
          ,sysdate
          ,l_CREATED_BY
          ,NULL
          ,p_RUN_MODE);
ElsIf p_STEP_NUMBER = -1 Then
   -- this request id need to be inserted for each step
   -- This happenns for rollback posting process only
     Open  get_steps_C;
     LOOP
       Fetch get_steps_C into f_step_number;
       EXIT WHEN get_steps_C%NOTFOUND;
       Insert Into GL_AUTO_ALLOC_BAT_HIST_DET
             (REQUEST_ID
           ,PARENT_REQUEST_ID
           ,STEP_NUMBER
           ,PROGRAM_NAME_CODE
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
           ,CREATION_DATE
           ,CREATED_BY
           ,STATUS_CODE
           ,RUN_MODE
          )
          Values
          (p_REQUEST_ID
          ,p_PARENT_REQUEST_ID
          ,f_step_number
          ,p_PROGRAM_NAME_CODE
          ,sysdate
          ,l_LAST_UPDATED_BY
          ,l_LAST_UPDATE_LOGIN
          ,sysdate
          ,l_CREATED_BY
          ,NULL
          ,p_RUN_MODE);
    End Loop;
  End If;
End INSERT_BATCH_HIST_DET ;

Procedure get_standard_who (
            l_CREATED_BY           OUT NOCOPY NUMBER
            ,l_LAST_UPDATED_BY     OUT NOCOPY NUMBER
            ,l_LAST_UPDATE_LOGIN   OUT NOCOPY NUMBER ) IS
 Begin
          l_CREATED_BY:=  WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'CREATED_BY');

         l_LAST_UPDATED_BY:=   WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'LAST_UPDATED_BY');

         l_LAST_UPDATE_LOGIN:= WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'LAST_UPDATE_LOGIN');

 End get_standard_who;

 Function Contain_Projects(
                     X_Request_Id           IN          NUMBER
                    )  RETURN BOOLEAN IS

      l_batch_type VARCHAR2(1);
      l_Contain_Project  BOOLEAN;
      CURSOR get_type_h IS
        SELECT batch_type_code
        FROM   gl_auto_alloc_batch_history
        WHERE  Request_Id = X_Request_Id;
  BEGIN
    l_Contain_Project := FALSE;

    OPEN get_type_h;

    LOOP
        FETCH get_type_h INTO l_batch_type;
        EXIT WHEN get_type_h%NOTFOUND;

        IF (l_batch_type = 'P') THEN
            l_Contain_Project := TRUE;
        END IF;

    END LOOP;
    CLOSE get_type_h;
    return(l_Contain_Project);

END Contain_Projects;

Procedure Update_Status(
       l_request_id     IN Number
      ,l_step_number    IN Number
      ,l_status_code    IN Varchar2 ) IS

f_step_number         NUMBER;
f_status_code         Varchar2(30);

Cursor status_code_C IS
Select
 STATUS_CODE
,STEP_NUMBER
FROM GL_AUTO_ALLOC_BATCH_HISTORY
WHERE REQUEST_ID = l_request_id
AND ( STEP_NUMBER = l_step_number OR
      -1 = l_step_number) ;

Begin
   Open status_code_C;
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Update_Status: ' || 'Status_code = '||l_status_code||
                  ' Step_number = '||to_char(l_step_number));
   END IF;
   If l_step_number = -1 Then
     LOOP
       Fetch status_code_C into
          f_status_code
          ,f_step_number;
       Exit WHEN status_code_C%NOTFOUND;
       If f_status_code <> l_status_code AND
          f_status_code not in ('RC','NS','RNR') Then
           UPDATE GL_AUTO_ALLOC_BATCH_HISTORY
           SET STATUS_CODE = l_status_code
           WHERE REQUEST_ID = l_request_id
           AND STEP_NUMBER = f_step_number;
       End If;
     End Loop;

  Else
       Fetch status_code_C into
          f_status_code
          ,f_step_number;
      If f_status_code <> l_status_code Or
         f_status_code IS NULL Then
         UPDATE GL_AUTO_ALLOC_BATCH_HISTORY
         SET STATUS_CODE = l_status_code
         WHERE REQUEST_ID = l_request_id
         AND STEP_NUMBER =  l_step_number;
      End If;

  End If;
  close status_code_C;
End Update_Status;

Procedure Get_Status_and_Message(
          conc_prg_code    IN  Varchar2
         ,ptype             IN  Varchar2
         ,rollback_allowed IN Varchar2
         ,status_code      OUT NOCOPY Varchar2
         ,message_name     OUT NOCOPY Varchar2 ) Is

l_operating_mode   Varchar2(2);

Begin
 l_operating_mode := WF_ENGINE.GetItemAttrText
                        (p_item_type,
                         p_item_key,
                         'OPERATING_MODE');
  IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
  	diagn_debug_msg('Get_Status_and_Message: Prg_Code = '||
                   Conc_Prg_Code||' Type = '||ptype);
  END IF;
 If ptype = 'COMPLETE' Then
    If l_operating_mode = 'R' Then  --Rollback mode
        If conc_prg_code = 'GLPPOS' Then
           --Rollback:Posting Program Completed
           status_code := 'RPPC';
        Elsif conc_prg_code = 'GLPREV' Then
           --Rollback: Reversal Program  Completed
           status_code := 'RRPC';
        End If;
    Else -- Normal mode
       IF conc_prg_code In ( 'GLAMAS','GLPRJE') Then
           --Generation program completed
           status_code := 'GPC';
       Elsif conc_prg_code = 'GLPPOS' Then
           --Posting completed
           status_code := 'PPC';
       End If;
    End If;
 ElsIf ptype = 'ERROR' Then
    If l_operating_mode = 'R' Then  --Rollback mode
       If conc_prg_code = 'GLPPOS' Then
           --Rollback:Posting Program Failed
           status_code := 'RPF';
           message_name := 'GLALLOC:POSTING_PRG_FAILED';
       Elsif conc_prg_code = 'GLPREV' Then
           --Rollback: Reversal Program  Completed
           status_code := 'RRF';
           message_name := 'GLALLOC:REV_JE_PRG_FAILED';
       End If;
   Else -- Normal mode
       If conc_prg_code In ( 'GLAMAS','GLPRJE') Then
           --Generation program completed
           status_code := 'GF';
          If rollback_allowed = 'Y' Then
             message_name := 'GLALLOC:MA_PRG_FAILED';
          Else
             message_name := 'GLALLOC:MA_PRG_FAILED_NRB';
          End If;
      Elsif conc_prg_code = 'GLPPOS' Then
           --Posting completed
           status_code := 'PF';
          If rollback_allowed = 'Y' Then
             message_name := 'GLALLOC:POSTING_PRG_FAILED';
          Else
             message_name := 'GLALLOC:POSTING_PRG_FAILED_NRB';
          End If;
        End If;
    End If;
End If;
IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
	diagn_debug_msg('Get_Status_and_Message: ' || 'Message_name = '||message_name||' Status_Code = '||status_code);
END IF;
 return;
End Get_Status_and_Message;

Procedure Submit_Request(
          p_parent_request_id  IN NUMBER
         ,p_step_number        IN NUMBER
         ,Prog_Code            IN VARCHAR2
         ,p_attribute1         IN VARCHAR2 DEFAULT NULL
         ,p_attribute2         IN VARCHAR2 DEFAULT NULL
         ,p_attribute3         IN VARCHAR2 DEFAULT NULL
         ,p_attribute4         IN VARCHAR2 DEFAULT NULL
         ,p_attribute5         IN VARCHAR2 DEFAULT NULL
         ,p_attribute6         IN VARCHAR2 DEFAULT NULL
         ,p_attribute7         IN VARCHAR2 DEFAULT NULL
         ,p_attribute8         IN VARCHAR2 DEFAULT NULL
         ,p_attribute9         IN VARCHAR2 DEFAULT NULL
         ,p_attribute10        IN VARCHAR2 DEFAULT NULL
         ,p_attribute11        IN VARCHAR2 DEFAULT NULL
         ,p_attribute12        IN VARCHAR2 DEFAULT NULL
         ,p_sub_req_id         OUT NOCOPY NUMBER) Is
l_parent_req_id               Number := p_parent_request_id;
l_operating_mode              Varchar2(1);
l_userenv_lang                Varchar2(10);
l_client_info                 Varchar2(240);
l_conc_prg_name               Varchar2(240);
l_user_id                     Number;
l_org_id                      Number;
l_resp_id                     Number;
l_resp_appl_id                Number;
l_status_code                 Varchar2(15);
l_rollback_allowed            Varchar2(1);
l_message_Name                Varchar2(150);
l_submit_request_id           NUMBER;
Cursor conc_prog_name_C  IS
Select USER_CONCURRENT_PROGRAM_NAME
From fnd_concurrent_programs_vl
Where APPLICATION_ID = 101
AND CONCURRENT_PROGRAM_NAME = Prog_Code;
Begin
   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Inside SUBMIT_REQUEST');
   	diagn_debug_msg('Submit_Request: ' || 'p_attribute1='||p_attribute1);
   	diagn_debug_msg('Submit_Request: ' || 'p_attribute2='||p_attribute2);
   	diagn_debug_msg('Submit_Request: ' || 'p_attribute3='||p_attribute3);
   	diagn_debug_msg('Submit_Request: ' || 'p_attribute4='||p_attribute4);
   	diagn_debug_msg('Submit_Request: ' || 'p_attribute5='||p_attribute5);
   	diagn_debug_msg('Submit_Request: ' || 'p_attribute6='||p_attribute6);
   	diagn_debug_msg('Submit_Request: ' || 'p_attribute7='||p_attribute7);
   	diagn_debug_msg('Submit_Request: ' || 'p_attribute8='||p_attribute8);
   	diagn_debug_msg('Submit_Request: ' || 'p_attribute9='||p_attribute9);
   	diagn_debug_msg('Submit_Request: ' || 'p_attribute10='||p_attribute10);
   	diagn_debug_msg('Submit_Request: ' || 'p_attribute11='||p_attribute11);
        diagn_debug_msg('Submit_Request: ' || 'p_attribute12='||p_attribute12);
   	diagn_debug_msg('Submit_Request: ' || 'Prog_Code='||Prog_Code);
   END IF;

   l_operating_mode := wf_engine.GetItemAttrText
                           ( itemtype        => p_item_type,
                             itemkey         => p_item_key,
                             aname           => 'OPERATING_MODE');


   l_rollback_allowed := WF_ENGINE.GetItemAttrText(
                           p_item_type,
                           p_item_key,
                           'ROLLBACK_ALLOWED');

  l_user_id   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'USER_ID');

  l_org_id     := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'ORG_ID');

  l_resp_id   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'RESP_ID');

  l_resp_appl_id   := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                         'RESP_APPL_ID');

    --Bug fix 1971413
    FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);

    FND_PROFILE.put('ORG_ID', l_org_id);
    FND_PROFILE.put('USER_ID', l_user_id );
    FND_PROFILE.put('RESP_ID', l_resp_id);
    FND_PROFILE.put('RESP_APPL_ID', l_resp_appl_id);

    select userenv('LANG') into l_userenv_lang from dual;
    IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
    	diagn_debug_msg('Submit_Request: ' || 'LANG='||l_userenv_lang);
    END IF;
    select userenv('CLIENT_INFO') into l_client_info from dual;
    IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
    	diagn_debug_msg('Submit_Request: ' || 'CLINT_INFO='||l_client_info);
    END IF;

    l_submit_request_id :=
             FND_REQUEST.SUBMIT_REQUEST(
                'SQLGL',
                Prog_Code,
                '',
                '',
                FALSE,
                p_attribute1,
                p_attribute2,
                p_attribute3,
                p_attribute4,
                p_attribute5,
                p_attribute6,
                p_attribute7,
                p_attribute8,
                p_attribute9,
                p_attribute10,
                p_attribute11,
                p_attribute12,
                '','','','','','','','','','',
                '','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','',
                '','','','','','','','','','','','','','','',
                '','','');

        wf_engine.SetItemAttrText(
                itemtype  => p_item_type,
                itemkey   => p_item_key,
                aname     => 'CONC_PRG_CODE',
                avalue    => Prog_Code );

        select nvl(userenv('LANG'),'US') into l_userenv_lang from dual;
        Open conc_prog_name_C;
        Fetch conc_prog_name_C into l_conc_prg_name;
        Close conc_prog_name_C;

        wf_engine.SetItemAttrText(
                itemtype  => p_item_type,
                itemkey   => p_item_key,
                aname     => 'CONC_PRG_NAME',
                avalue    => l_conc_prg_name );


    If l_submit_request_id = 0 Then
       -- Request Submission failed
       IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
       	diagn_debug_msg('Submit_Request: ' || 'Sending Notification.Fatal Error: Conc program not submitted');
       END IF;
       wf_engine.SetItemAttrNumber( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'CONC_REQUEST_ID',
                                   avalue       => -1 );

        Get_Status_and_Message(Prog_Code
                           ,'ERROR'
                           ,l_rollback_allowed
                           ,l_status_code
                           ,l_message_name);

          -- Program Error
          Update_Status(to_number(p_item_key)
                    ,p_step_number
                    ,l_status_code
                    );

         wf_engine.SetItemAttrText(itemtype => p_item_type,
                                  itemkey   => p_item_key,
                                  aname     => 'MESSAGE_NAME',
                                  avalue    => l_message_name );
         IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
         	diagn_debug_msg('Submit_Request: ' || 'Message_name = '||l_message_Name);
         END IF;
        p_sub_req_id := 0;

   Else /* l_submit_request_id <> 0 */
      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Inserting req id = '||to_char(l_submit_request_id)||
                            ' into histroy detail');
      END IF;
       wf_engine.SetItemAttrNumber( itemtype     => p_item_type,
                                   itemkey      => p_item_key,
                                   aname        => 'CONC_REQUEST_ID',
                                   avalue       => l_submit_request_id );

       INSERT_BATCH_HIST_DET(
                p_REQUEST_ID        => l_submit_request_id
               ,p_PARENT_REQUEST_ID => l_parent_req_id
               ,p_STEP_NUMBER       => p_step_number
               ,p_PROGRAM_NAME_CODE => Prog_Code
               ,p_RUN_MODE          => l_operating_mode);

     p_sub_req_id := l_submit_request_id;
   End If;
End Submit_Request;

-- ****************************************************************************
-- Private procedure: Display diagnostic message
-- ****************************************************************************

Procedure initialize_debug IS
 Begin
          G_FILE := GL_AUTO_ALLOC_WF_PKG.p_item_key ||'.dbg';
          If utl_file.Is_Open(G_FILE_PTR) Then
            utl_file.fclose(G_FILE_PTR);
          End If;
          G_FILE_PTR := utl_file.fopen(G_DIR, G_FILE, 'a');
  Exception
    When Others Then
       Wf_Core.Context('GL_AUTO_ALLOCATION_WF_PKG',
                      'initialize_debug', 'GLALLOC', p_item_key);
       Wf_Core.Get_Error(err_name,err_msg,err_stack);
       diagn_debug_msg_flag := FALSE;
       --Raise;
 End initialize_debug;

Procedure diagn_debug_msg(debug_message in Varchar2) Is
 Begin
 If (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) then
   If debug_message is not null then
     If  NOT utl_file.Is_Open(G_FILE_PTR) OR
         G_FILE <> GL_AUTO_ALLOC_WF_PKG.p_item_key ||'.dbg' OR
         G_FILE  IS NULL   Then
      initialize_debug;
     End If;
     utl_file.put_line(G_FILE_PTR, debug_message);
     utl_file.fflush(G_FILE_PTR);
   End if;
 End If;
Exception
WHEN UTL_FILE.INVALID_PATH OR
     UTL_FILE.WRITE_ERROR  OR
     UTL_FILE.INVALID_FILEHANDLE  THEN
     diagn_debug_msg_flag := FALSE;
     null;
WHEN OTHERS THEN
     Wf_Core.Context('GL_AUTO_ALLOCATION_WF_PKG',
                      'diagn_debug_msg', 'GLALLOC', p_item_key);
     diagn_debug_msg_flag := FALSE;
     null;
End diagn_debug_msg;

Procedure Continue_Next_Step(p_item_type      IN VARCHAR2,
                             p_item_key       IN VARCHAR2,
                             p_actid          IN NUMBER,
                             p_funcmode        IN VARCHAR2,
                             p_result         OUT NOCOPY VARCHAR2) Is
l_continue_next_step  Varchar2(1);
l_step_number Number;
l_rollback_allowed Varchar2(1);
l_message_Name Varchar2(150);

Begin
If ( p_funcmode = 'RUN' ) THEN
   GL_AUTO_ALLOC_WF_PKG.p_item_key := p_item_key;

   IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
   	diagn_debug_msg('Started Continue_Next_Step');
   END IF;

   l_step_number := WF_ENGINE.GetItemAttrNumber
                        (p_item_type,
                         p_item_key,
                        'STEP_NUMBER');

   l_rollback_allowed := WF_ENGINE.GetItemAttrText(
                           p_item_type,
                           p_item_key,
                           'ROLLBACK_ALLOWED');

   l_continue_next_step := WF_ENGINE.GetItemAttrText(
                           p_item_type,
                           p_item_key,
                           'CONTINUE_NEXT_STEP');

   If l_continue_next_step = 'Y' Then
      IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
      	diagn_debug_msg('Continue_Next_Step: ' || 'Continue to process next step');
      END IF;
      -- set status code to Batch Not Generated
      Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'BNG'
                    );
      p_result := 'COMPLETE:Y';
   Else
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Continue_Next_Step: ' || 'Stop to process next step. Sending notification');
     END IF;

     If l_rollback_allowed = 'Y' Then
         l_message_name := 'GLALLOC:NO_BATCH_GENERATED';
     Else
        l_message_name := 'GLALLOC:NO_BATCH_GENERATED_NRB';
     End If;

     wf_engine.SetItemAttrText(itemtype => p_item_type,
                                 itemkey   => p_item_key,
                                 aname     => 'MESSAGE_NAME',
                                 avalue    => l_message_Name );

     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Continue_Next_Step: ' || 'Message_name = '||l_message_Name);
     END IF;
     -- set status code to Batch Not Generated
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'BNG'
                    );
      p_result := 'COMPLETE:N';
      return;
   END IF;
ElsIf ( p_funcmode = 'CANCEL' ) THEN
    NULL;
End If;
EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('GL_AUTO_ALLOC_WF_PKG', 'Continue_Next_Step', p_item_type, p_item_key);
     Wf_Core.Get_Error(err_name,err_msg,err_stack);
     IF (diagn_debug_msg_flag) AND (G_DIR is NOT NULL ) THEN
     	diagn_debug_msg('Continue_Next_Step: ' || err_msg ||'*'||err_stack);
     END IF;
     Update_Status(to_number(p_item_key)
                    ,l_step_number
                    ,'UFE'
                    );

     Raise;
End Continue_Next_Step;


End GL_AUTO_ALLOC_WF_PKG;

/
